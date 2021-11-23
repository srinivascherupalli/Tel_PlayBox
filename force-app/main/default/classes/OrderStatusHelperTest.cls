@isTest
public class OrderStatusHelperTest{
     @isTest static void testMethod1()  {
    
        Account acc=new Account();
        acc.Name='Test Account';
        acc.CIDN__c='987654321';
        acc.ABN__c='1235';
        acc.Customer_Status__c='ACTIVE';
        insert acc;
            
     cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        //basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
        cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description ';
        config.cscfga__Contract_Term__c = 36;
        config.cscfga__Configuration_Status__c = 'Valid';
        
        List<cscfga__Product_Configuration__c> configList = new List<cscfga__Product_Configuration__c>{config};
            update configList;
       
        csord__Order_Request__c orderReq = new csord__Order_Request__c();
        orderReq.name = 'OR-12121';
        orderReq.csord__Module_Name__c = 'TestReq';
        orderReq.csord__Module_Version__c = '12';
        insert orderReq;
        
        csord__Order__c  pord = new csord__Order__c();
        pord.name = 'TestOrder';
        pord.csord__Account__c = acc.id;
        pord.csord__Status2__c = 'Created';
        pord.csord__Order_Request__c = orderReq.Id;
        pord.csord__Identification__c = 'IDE1322';
        pord.stage__c = 'Being Fulfilled';  
        pord.isMSISDNReserved__c= true;    
        pord.RecordType= [SELECT id  FROM RecordType WHERE DeveloperName = 'MSISDN_Reserved'];      
        insert pord;
        
        
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Primary_Order__c=pord.id;
        ord.csord__Account__c = acc.id;
        ord.csord__Status2__c = 'Created';
        ord.csord__Order_Request__c = orderReq.Id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';       
        insert ord;
                
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.name = 'TestOrder';
        subs.csord__Account__c = acc.id;
        subs.csord__Order__c = ord.id;
        subs.csord__Identification__c = 'IDE1322';
        subs.csord__Order_Request__c = orderReq.id;
        insert subs;
        
        csord__Service__c ser = new csord__Service__c();
        ser.name = 'TestOrder';
        ser.csord__Order__c = ord.id;
        ser.csord__Subscription__c = subs.id;
        ser.csord__Identification__c =  'IDE1322';
        ser.csord__Order_Request__c = orderReq.id;
        ser.Model__c = 'TestOrder';
        ser.Appointment_Required__c = 'false';
        ser.csordtelcoa__Product_Configuration__c = config.id;
        ser.TechnologyType__c = 'Mobile Access';
        insert ser;
         
         csord__Service__c ser1 = new csord__Service__c();
        ser1.name = 'TestOrder1';
        ser1.csord__Order__c = ord.id;
        ser1.csord__Subscription__c = subs.id;
        ser1.csord__Identification__c =  'IDE1322';
        ser1.csord__Order_Request__c = orderReq.id;
        ser1.Model__c = 'TestOrder1';
        ser1.Appointment_Required__c = 'true';
        ser1.csordtelcoa__Product_Configuration__c = config.id;
        ser1.TechnologyType__c = 'Mobile Access';
        insert ser1;
       
        List<Id> orchesIds= new List<Id>();
        List<sObject> result = new List<sObject>();
        List<Id> orderIdList = new List<Id>();
        orderIdList.ADD(pord.id);
        List<RecordType> orderRecordTypeList =[SELECT Id, Name FROM RecordType WHERE SObjectType = 'csord__Order__c'];
        Map<String, Id> orderRecordTypeNameToIdMap = new Map<String, Id>();
        for(RecordType recTypeInstance : orderRecordTypeList){
            orderRecordTypeNameToIdMap.put(recTypeInstance.Name, recTypeInstance.Id);      
        }

        Map<Id, csord__Order__c> orderMap = new Map<Id, csord__Order__c>([Select Id, Name, csord__Primary_Order__c, csord__Order_Request__c, csordtelcoa__Opportunity__c,isMSISDNRequired__c, isMSISDNReserved__c, isAppointmentCompleted__c  from csord__Order__c where Id IN:orderIdList OR csord__Primary_Order__c IN:orderIdList]);
        Map<Id, csord__Service__c> serviceMap = new Map<Id, csord__Service__c>([Select Id, Name, csord__Service__c, SiteId__c,modelChange__c, csord__Subscription__c,Serviceability_Location__c,Contract_Term__c, Appointment_Required__c, TechnologyType__c, csord__Order_Request__c, csordtelcoa__Replaced_Service__c, csord__Order__r.csordtelcoa__Opportunity__c,csord__Order__r.isMSISDNRequired__c, csord__Order__r.isMSISDNReserved__c, csord__Order__r.isAppointmentCompleted__c,csord__Order__r.csord__Primary_Order__r.isAppointmentCompleted__c from csord__Service__c where csord__service__c = null and csord__Order__r.csord__Primary_Order__c IN:orderIdList]);
        OrderStatusHandler.changeOrderStatus(orderIdList);

        
        List<Id> serviceid= new List<Id>();
        serviceid.add(ser.id);
        serviceid.add(ser1.id);
       
      
       Test.startTest();
       OrderStatusHelper.OrderFieldUpdateExecute(serviceMap, orderMap, orderRecordTypeNameToIdMap, false);
       OrderStatusHelper.OrderFieldUpdateExecute(serviceMap, orderMap, orderRecordTypeNameToIdMap, true);

       MSISDNReserveMobileAccess.MSISDNReserve(serviceid);
        Test.stopTest();
        
        system.assert(!orderRecordTypeList.isEmpty());
      
    
    
    }
    }
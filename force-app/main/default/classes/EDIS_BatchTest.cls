@isTest 
public class EDIS_BatchTest {
    
    
    
    @Testsetup
    static void dataSetup() {
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;   
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        

        
        List<csord__Order_Request__c> ordRequestList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordRequestList.add(ordReq);  
        insert ordRequestList;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        List<csord__Subscription__c> subList =new List<csord__Subscription__c>();
        csord__Subscription__c subRes=new csord__Subscription__c();
        subRes.name  = 'sub1';
        subRes.csord__Identification__c = 'sub1';
        subRes.csord__Order__c = ord.Id;
        subRes.Sub_status__c = 'Active';
        subRes.csord__Status__c='Provisioned';
        subRes.triggerBill_RTB__c=true;
        subRes.csordtelcoa__Product_Configuration__c = userPC.id;
        subList.add(subRes);
        
        csord__Subscription__c subRes1=new csord__Subscription__c();
        subRes1.name  = 'sub2';
        subRes1.csord__Identification__c = 'sub2';
        subRes1.csord__Order__c = ord.Id;
        subRes1.Sub_status__c = 'Active';
        subRes1.csord__Status__c='Provisioned';
        subRes1.triggerBill_RTB__c=true;
        subRes1.csordtelcoa__Product_Configuration__c = userPC.id;
    subRes1.eventId__c ='91d3e2ba-2d65-4752-837a-7b5193c5f1c5';
        subList.add(subRes1);
        insert subList; 
        
        List<csord__Service__c> servList = new List<csord__Service__c >();
        csord__Service__c servRe = new csord__Service__c();
        servRe.name ='tst servRe';
        servRe.csord__Identification__c  = 'test servRe';
        servRe.csord__Subscription__c = subRes.Id;
        servRe.csord__Status__c = 'Connected';
        servRe.csord__Order__c = ord.Id;
        servRe.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe);
        
        csord__Service__c servRe1 = new csord__Service__c();
        servRe1.name ='tst servRe';
        servRe1.csord__Identification__c  = 'test servRe';
        servRe1.csord__Subscription__c = subRes1.Id;
        servRe1.csord__Status__c = 'Connected';
        servRe1.csord__Order__c = ord.Id;
        servRe1.csordtelcoa__Product_Configuration__c = userPC.id;
        servList.add(servRe1);
        insert servList;
        
        List<Number__c> numList = new List<Number__c>();
        Number__c num=new Number__c();
        num.name='Num test4';
        num.Subscription_number__c=subRes.csordtelcoa__Subscription_Number__c;
        num.Type__c='New';
        num.Service_Number__c='61474850547';
        num.Status__c='Provsioned';
        num.Product_Configuration__c = userPC.id;
        num.Service_Id__c = servRe.csordtelcoa__Service_Number__c;
        num.Status_LastModifiedDate__c = Datetime.now();
        numList.add(num);
        
        Number__c num1=new Number__c();
        num1.name='Num test8';
        num1.Subscription_number__c=subRes1.csordtelcoa__Subscription_Number__c;
        num1.Type__c='New';
        num1.Service_Number__c='61474850548';
        num1.Status__c='Provsioned';
        num1.Product_Configuration__c = userPC.id;
        num1.Service_Id__c = servRe1.csordtelcoa__Service_Number__c;
        num1.Status_LastModifiedDate__c = Datetime.now();
        numList.add(num1);
        
        insert numList;
        
   
            }
    
    static testMethod void edisBatchtest() 
    {
        Test.startTest();
        
        EDIS_Batch obj = new EDIS_Batch();
        Id dbID= DataBase.executeBatch(obj); 
        
        AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: dbID ];
        System.assertEquals(aaj.Id,dbID);  
        Test.stopTest();
    }
    

}
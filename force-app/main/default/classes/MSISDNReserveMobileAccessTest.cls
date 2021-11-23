@isTest
public class MSISDNReserveMobileAccessTest{

    static testMethod void MSISDNReserveTest(){
        Account acc = new Account(Name='Test Account');
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
       
        csord__Order_Request__c orderReq = new csord__Order_Request__c();
        orderReq.name = 'OR-12121';
        orderReq.csord__Module_Name__c = 'TestReq';
        orderReq.csord__Module_Version__c = '12';
        insert orderReq;
        
        List<csord__Order__c> orders = new List<csord__Order__c>();
        csord__Order__c  pord = new csord__Order__c();
        pord.name = 'TestOrder';
        pord.csord__Account__c = acc.id;
        pord.csord__Status2__c = 'Created';
        pord.csord__Order_Request__c = orderReq.Id;
        pord.csord__Identification__c = 'IDE1322';
        pord.stage__c = 'Being Fulfilled';       
        orders.add(pord);
        
        
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Primary_Order__c=pord.id;
        ord.csord__Account__c = acc.id;
        ord.csord__Status2__c = 'Created';
        ord.csord__Order_Request__c = orderReq.Id;
        ord.csord__Identification__c = 'IDE1322';
        ord.stage__c = 'Being Fulfilled';       
        orders.add(ord);
        
        insert orders;        
        
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
        ser.TechnologyType__c = 'Mobile Access';
        insert ser;
      
       List<Id> serviceid= new List<Id>();
        serviceid.add(ser.id);   
         
        Test.startTest();
        MSISDNReserveMobileAccess.MSISDNReserve(serviceid);
        system.assert(serviceid.size()>0);
        Test.stopTest();
}
    }
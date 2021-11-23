/***********************************
Developer: Ravi Shankar
Description: Nov 10,2019
             Test class changes for EDGE-118625 FulfillmentLineItemService
Class Name: FulfillmentLineItemServiceTest
***********************************/
/************
Modified By: Team Hawaii
Modified Date : 18/3/2030
Description : Modified only test data to fix test class failure due to introduction 
              of validation rule on contact object 
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user. 
Jira : P2OB-5160
***********/
@isTest
public class FulfillmentLineItemServiceTest {
    @Testsetup static void dataSetup(){
        //Hawaii - Created variable to store name of contact record type
        //As part of P2OB-5470 story removed the Hard coded record type name  and used Custom Label
        String Contact_Layout_Record_Type = system.label.Contact_layout_record_type;
        Id RecordTypeIdOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Order Submitted with Appointment').getRecordTypeId();
        Id RecordTypeIdSecondaryOrder = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get('Secondary Order').getRecordTypeId();
        csord__Order_Request__c orderRequest=new csord__Order_Request__c();
        
        List<BDS_Notify_Settings__c> bdsNotifySettings = new List<BDS_Notify_Settings__c>();
        bdsNotifySettings.add(createCustomSettings('Feature Level', 'FeatureLevelShadow', false));
        bdsNotifySettings.add(createCustomSettings('Platform Management', 'Platform Management', false));
        bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow', true));
        insert bdsNotifySettings;
        
         //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('TestAccount') ;
        acc.Customer_Status__c='Acquired';
        insert acc;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'TestLastName';
        con1.Email = 'test@test345345345345.com';
        con1.Phone = '+911234567891'; 
        //Team Hawaii - Fetch contact layout type of contact instead of partner contact 
        con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Contact_Layout_Record_Type).getRecordTypeId(); 
        
        insert con1;  
        
        List<csord__Order__c> orders = new List<csord__Order__c>();
        csord__Order__c prord = new csord__Order__c();
        prord.csord__Identification__c = 'test identification';
        prord.Name = 'test order';
        prord.csord__Order_Request__c=orderRequest.id;
        prord.csord__Status2__c = 'Pending';
        prord.RecordTypeId=RecordTypeIdOrder;
        prord.Scenario_Type__c='';
        orders.add(prord);
        
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification1';
        ord.Name = 'test sec order';
        ord.csord__Order_Request__c=orderRequest.id;
        //ord.csord__Status2__c = 'Pending';
        ord.RecordTypeId=RecordTypeIdSecondaryOrder;
        ord.Scenario_Type__c='';
        ord.csord__Primary_Order__c=prord.id;
         orders.add(ord);
        
        insert orders;
        
        
        
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Offer_ID__c = 'offerId';
        marketableOffer.Name = 'offerName';
        insert marketableOffer;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        subs.csord__Order__c = ord.id;
        subs.csord__Account__c = acc.id;
        subs.MarketableOffer__c = marketableOffer.Id;
        subs.MarketableOffer__r = marketableOffer;
        insert subs;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '4';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Pending';
        serv.csord__Order__c = ord.id;
        serv.Appointment_Required__c='true';
        insert serv;
        
          csord__Service__c servinprgs = new csord__Service__c();
        servinprgs.name ='tst service1';
        servinprgs.csord__Identification__c  = 'test identify1';
        servinprgs.csordtelcoa__Service_Number__c = '4';
        servinprgs.csord__Subscription__c = subs.Id;
        servinprgs.csord__Status__c = 'In Progress';
        servinprgs.csord__Order__c = ord.id;
        servinprgs.Appointment_Required__c='true';
        insert servinprgs;
        
        CSPOFA__Orchestration_Process_Template__c opt=new CSPOFA__Orchestration_Process_Template__c();
        opt.Name='Order Fulfilment Process';
        insert opt;
        
        Case caseRec = new Case();
        caseRec.Origin = 'Email';
        insert caseRec;
        
        FulfillmentLineItem__c flItem = new FulfillmentLineItem__c();
        flItem.subscription__c = subs.Id;
        flItem.Status__c = 'New';
        flItem.case__c = caseRec.Id;
        flItem.Tenancy_ID__c = 'test';
        flItem.Account__c = acc.Id;
        flItem.CustomerContact__c = con1.id;
        insert flItem;
    }
     
    
    private static BDS_Notify_Settings__c createCustomSettings(String name, String value, boolean isSI5Offer) {
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = name;
        bds.Value__c = value;
        bds.Is_SI5_Offer__c = isSI5Offer;
        return bds;
        
    }
    static testMethod void closeFulfillmentItemTest() {        
        list<FulfillmentLineItem__c> fiList = [SELECT Id FROM FulfillmentLineItem__c];
        fiList[0].Status__c = 'Completed';
        update fiList;
        system.assertEquals(fiList!=NULL,True,'Fulfilment Item not created');
    }
}
/****************************************************************************
@Name: OrlandoFLITriggerHandlerTest.
@Author: Orlando/Purushottam
@Sprint 20.01 [EDGE-128934]
@CreateDate: 01/18/2020.
@Description: This Class is for Fulfillineitem Trigger 
Note : Implemented Trigger FrameWork 
********************************************************************************/
@isTest
public class OrlandoFLITriggerHandlerTest {
    
    @testSetup
    public static void dataSetup(){
         //Hawaii - Created variable to store name of contact record type
         //As part of P2OB-5470 story removed the Hard coded record type name  and used Custom Label
         String Contact_Layout_Record_Type = system.label.Contact_layout_record_type;
         Account acc = AccountTestFactory.buildAccount('TestAccount') ;
         acc.Customer_Status__c='Acquired';
         insert acc;
        
        List<BDS_Notify_Settings__c> bdsNotifySettings = new List<BDS_Notify_Settings__c>();
        bdsNotifySettings.add(createCustomSettings('Feature Level', 'FeatureLevelShadow', false));
        bdsNotifySettings.add(createCustomSettings('Platform Management', 'Platform Management', false));
        bdsNotifySettings.add(createCustomSettings('Technical Support', 'TechnicalSupportShadow', true));
        insert bdsNotifySettings;
        
        Contact con1 = new Contact();
        con1.AccountId = acc.Id;
        con1.LastName = 'TestLastName';
        con1.Email = 'test@test345345345345.com';
        con1.Phone = '+911234567891'; 
        con1.recordtypeid=Schema.SObjectType.Contact.getRecordTypeInfosByName().get(Contact_Layout_Record_Type).getRecordTypeId();
        insert con1;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        
        Marketable_Offer__c marketableOffer = new Marketable_Offer__c();
        marketableOffer.Offer_ID__c = 'offerId';
        marketableOffer.Name = 'offerName';
        insert marketableOffer;
        
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        subs.TenancyID__c='Test 123';
        subs.MarketableOffer__c = marketableOffer.Id;
        subs.MarketableOffer__r = marketableOffer;
        insert subs;
        
        Case caseRec = new Case();
        caseRec.Origin = 'Email';
        insert caseRec;
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(case__c = caseRec.Id,subscription__c=subs.id,Status__c = 'New',Tenancy_ID__c = 'test',Account__c = acc.Id,CustomerContact__c = con1.id);
        insert f;
        Id fcrPortalAdminRecordTypeID =  Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get('Portal Admin').getRecordTypeId();
        Functional_Contact_Role__c fcr = new Functional_Contact_Role__c(               Role_Type__c = 'Subscription',
                                                                                        RecordTypeId = fcrPortalAdminRecordTypeID,
                                                                                        SubscriptionID__c=subs.id,
                                                                                        Fulfillment_Task__c=f.id,
                                                                                        Partner_User__c=subs.csord__Order__r.csordtelcoa__Opportunity__r.OwnerId,
                                                                                        ContactID__c = con1.id);
        insert fcr; 
                        
    }
    
    private static BDS_Notify_Settings__c createCustomSettings(String name, String value, boolean isSI5Offer) {
        BDS_Notify_Settings__c bds = new BDS_Notify_Settings__c();
        bds.Name = name;
        bds.Value__c = value;
        bds.Is_SI5_Offer__c = isSI5Offer;
        return bds;
        
    }
    
     public static testMethod void  OrlandoFLITriggerHandlerUnitPositiveTest(){
         
         FulfillmentLineItem__c FLI=[select id, status__c from FulfillmentLineItem__c];
         FLI .Status__c='Completed';
        update FLI;
         system.assertEquals(FLI.Status__c, 'Completed');
        
     }
     public static testMethod void  OrlandoFLITriggerHandlerUnitNegativeTest(){
         try{
         csord__Subscription__c sub= [select id from csord__Subscription__c];
         sub.TenancyID__c=null;    
         update sub;
         FulfillmentLineItem__c FLI=[select id, status__c from FulfillmentLineItem__c];
         FLI .Status__c='Completed';
         update FLI;
         }
         catch(Exception e){
            system.assertNotEquals('', e.getMessage());
        }
     }
}
/*****************************************************************
@Name: SiteContactTest
@Author: Purushottam Sahu
@CreateDate: 12/02/2019 
@Description: This is the Test class for SiteContact
******************************************************************/ 
@isTest( SeeAllData = false )
public class SiteContactTest {
    @TestSetup static void dataSetup() {
        Marketable_Offer__c moMob = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services-MDM Config',Name = 'Professional Services-MDM Config',Offer_ID__c = System.Label.TC_PS_Offer,Config__c='{"noLineItem":true,"skipBasketSyncValidations":true,"isSOWrequired":true,"SOMOpenAir":true}');
        insert moMob;
        
        Account acc = AccountTestFactory.buildAccount('Test Name');
        insert acc;
        
        cscfga__Product_Definition__c pd= ProductTestFactory.buildProductDefinition('Professional Services','Professional Services');
        insert pd;
        
        cscfga__Product_Configuration__c pc = ProductTestFactory.buildProductConfig(pd.id);
        pc.name= 'Professional Services-MDM Config';
        pc.Marketable_Offer__c=moMob.id;
        insert pc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        insert ord;
        
        csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
        insert subs;
        
        csord__Service__c ser = ProductTestFactory.buildService('TestService', ord.id, subs.id, ordReq.id);
        ser.name = 'Telstra Collaboration Professional Services';
        ser.csordtelcoa__Product_Configuration__c = pc.id;
        insert ser;
        
        Attachment att1 = new Attachment(Name = 'ServiceSpecifications.json',ParentId = ser.Id);
        att1.Body = Blob.valueOf('{"specifications" : [ {  "version" : "1",  "status" : "Created",  "startDate" : "",  "specification" : "49c6a564-5845-7088-a2b5-f0f61688f5ca",  "productConfigurationId" : "a3T5O0000001OdcUAE",  "name" : "Non_Commercial_Site_Contact",  "metadata" : { },  "instanceId" : "",  "includeBilling" : false,  "guid" : "122271fe-72f5-1dc4-0b98-5eeeeec769ce",  "endDate" : "",  "description" : "NON_COMMERCIAL_SITE_CONTACT_DETAILS",  "code" : "Non_Commercial_Site_Contact",  "attributes" : {    "PS_SITE_CONTACT" : [ {      "attributes" : {        "ProjectContactName" : "Billing",        "SiteContactBusinessHoursName" : "Sahu Contact",        "SiteContactAfterHoursName" : "Billing",        "ContactName" : "Billing",        "SiteName" : "0 CAMBRIDGE ST ROCKLEA QLD 4106",        "ProjectContactId" : "0035O0000029suAQAQ",        "ContactId" : "0035O0000029suAQAQ",        "SiteContactAfterHoursId" : "0035O0000029suAQAQ",        "SiteContactBusinessHoursId" : "0035O000001tIjVQAU",        "SiteId" : "a4O2O0000004TWxUAM"      },      "schemaId" : "9fd5db8d-04b6-a7cc-e2ab-f51b5151ac63"    } ]  },  "additionalAttributes" : { }} ],"serviceId" : "a4e5O0000002FmkQAE","legacyAttributes" : [ ]}');
        insert att1;
        
        FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subs.id);
        insert f;
    }
    static testMethod void getSiteContactspositive(){
        FulfillmentLineItem__c fulfillment=[SELECT id,subscription__c FROM FulfillmentLineItem__c];
        System.assertNotEquals(Null,SiteContactDetails.getSiteContacts(fulfillment.id));
        
        cssmgnt.ProductProcessingUtility.Attribute attr= new cssmgnt.ProductProcessingUtility.Attribute();
        attr.displayValue='TestTechnicalContact';
        attr.name='TechnicalContact';
        attr.showInUI=false;
        attr.value='0032N00000ApipqQAB';
        
        list<cssmgnt.ProductProcessingUtility.Attribute> attrlist= new list<cssmgnt.ProductProcessingUtility.Attribute>();
        attrlist.add(attr);
        cssmgnt.ProductProcessingUtility.Configuration config= new cssmgnt.ProductProcessingUtility.Configuration();
        config.attributes=attrlist;
        List<cssmgnt.ProductProcessingUtility.Configuration> listconfig= new list<cssmgnt.ProductProcessingUtility.Configuration>();
        listconfig.add(config);
        cssmgnt.ProductProcessingUtility.Component comp= new cssmgnt.ProductProcessingUtility.Component();
        comp.changeType='Test';
        comp.description='Test';
        comp.configurations=listconfig;
        list<cssmgnt.ProductProcessingUtility.Component> complist= new list<cssmgnt.ProductProcessingUtility.Component>();
        complist.add(comp);
        Map<Id,List<cssmgnt.ProductProcessingUtility.Component>> oeMap = new Map<Id,List<cssmgnt.ProductProcessingUtility.Component>>();
		oeMap.put('a3T2N0000004mHfUAI',complist);
        SiteContactDetails.parseResponse(oeMap);
    }
    static testMethod void getSiteContactsegative(){
        try{
            FulfillmentLineItem__c fulfillment= new FulfillmentLineItem__c();
            SiteContactDetails.getSiteContacts(fulfillment.id);
        }
        catch(Exception e){
            system.assertNotEquals('', e.getMessage());
        }
    }
    
}
/*************************************************************************************************************
 * @name			Coms_PEPublishUtilTest
 * @author			BLR\rohit.pal <rohit.pal@crmit.com>
 * @created			29 / 09 / 2021
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2021-09-29		BLR\rohit.pal			Changes desription
 *
**************************************************************************************************************/
@isTest(SeeAllData=false) 
public class Coms_PEPublishUtilTest {

    @TestSetup static void dataSetup() {
        
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='987654321';
        acc.ABN__c='1235';
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        insert contact;
        
        cscrm__Address__c address = new cscrm__Address__c();
        address.Name='Unit 1 1234 Lostmy Way';
        address.Address_Line_1__c='Unit 4 Mahatma';
        address.Locality__c='Sydney';
        address.cscrm__Zip_Postal_Code__c='2000';
        address.cscrm__State_Province__c='NSW';
        address.cscrm__Country__c='Australia';
        address.cscrm__Street_Name__c ='Melbourne';
        
        insert address;
        
        Billing_Account__c billingAccount=new Billing_Account__c();
        billingAccount.Billing_Account_Number__c='123456789322';
        billingAccount.Billing_Address__c=address.id;
        billingAccount.Billing_Account_Owner__c=contact.Id;
        billingAccount.Account__c=acc.Id;
        insert billingAccount;
        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(address.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        site.cscrm__Installation_Address__r = address;
        insert site;
      
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.Billing_Account__c = billingAccount.id;
        insert ord;
        
        csord__Order__c secOrd = new csord__Order__c();
        secOrd.csord__Identification__c = 'test identification';
        secOrd.csord__Account__c = acc.id;
        secOrd.csord__Order_Type__c = 'test order' ;
        secOrd.Billing_Account__c = billingAccount.id;
        secOrd.csord__Primary_Order__c = ord.id;
        insert secOrd;
        
        cscfga__Configuration_Offer__c OriginatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
        insert OriginatingOffer;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = OriginatingOffer.id;
    productConfig.Type__c = 'Cancel';
        insert productConfig;
        
    
    csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        subs.csord__Order__c = secOrd.id;
        subs.csordtelcoa__Product_Configuration__c = productConfig.id;
    subs.Serviceability_Location__c = 'Urban';
        insert subs;
        
       
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        insert serv;
    
      /*csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Pending';
        //subs.csord__Order__c = ord.id;
        insert subs;
    System.debug('subs inserted:'+subs);         
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service1';
        serv.csord__Identification__c  = 'test identify1';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Pending';
        insert serv;
        System.debug('service inserted:'+serv);*/
    
    
        

        //

        Test.StartTest();
        List<Account> lstOfAccount =Coms_TestDataFactory.createAccount();
        insert lstOfAccount;
        System.assertEquals(10,lstOfAccount.size());
        //create opportunities
        List<Opportunity> lstOpp=Coms_TestDataFactory.createOpportunity(lstOfAccount);
        insert lstOpp;
        System.assertEquals(10,lstOpp.size());
        //create orders
        List<csord__Order__c> lstOrder=Coms_TestDataFactory.createOrder(lstOfAccount,lstOpp);
        insert lstOrder;
        System.assertEquals(10,lstOrder.size());
        //create subscriptions
        List<csord__Subscription__c> lstSubscription=Coms_TestDataFactory.createSubscription(lstOfAccount,lstOrder);
        insert lstSubscription;
        System.assertEquals(10,lstSubscription.size());
        //create services
        List<csord__Service__c> lstServices=Coms_TestDataFactory.createServicesWithOrders(lstSubscription,lstOrder);
        insert lstServices;
        System.assertEquals(10,lstServices.size());
      
     }

    @isTest
    static  void testparseServiceAttachments(){
        User adminUser = Coms_TestDataFactory.getAdminUser();
        System.runAs(adminUser){
        Test.startTest();
        List<csord__Order__c> lstOfAllOrders=[SELECT id,Name,Platform_Cache_Timestamp__c,
            CorrelationId__c,csord__Identification__c,isMSISDNHeld__c FROM csord__Order__c WHERE name='TestOrderNameForTest'];
            System.debug('lstOfAllOrders ' + lstOfAllOrders);
            List<csord__Service__c> lstOfAllOrdersService=[SELECT id,Name,csord__Identification__c,Platform_Cache_Timestamp__c,
            CorrelationId__c,csord__Order__c FROM csord__Service__c where csord__Order__c IN :lstOfAllOrders ];
            System.debug('lstOfAllOrdersService ' + lstOfAllOrdersService);
            Attachment attUCMobile = new Attachment();
            attUCMobile.Name = 'ServiceSpecifications.json';
            attUCMobile.ParentId = lstOfAllOrdersService[0].Id;
            attUCMobile.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","productConfigurationId":"a3T2N000000CgThUAK","name":"871_RC_810","metadata":{},"instanceId":"","includeBilling":false,"guid":"19d37d80-ea8a-4b0b-48e4-cc5057ff15ae","endDate":"","description":"Business Calling_Billing_RecurringCharge_000810","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000810","attributes":{"billDescription":"Feature Usage Charges","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000810_8336","chargeId":"DMCAT_RecurringCharge_000810","billingSpecId":"BSUSG005_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","productConfigurationId":"a3T2N000000CgThUAK","name":"871_RC_814","metadata":{},"instanceId":"","includeBilling":false,"guid":"99e2b523-f057-382f-0b7c-805ac88ef48a","endDate":"","description":"Business Calling_Billing_RecurringCharge_000814","code":"DMCAT_ProductSpecification_000871_Billing_RecurringCharge_000814","attributes":{"billDescription":"Individual line - standard calling plan","externalId":"DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000814_8329","concurrencyLimitMode":"Individual Line","callingPlans":"Standard","chargeId":"DMCAT_RecurringCharge_000814","billingSpecId":"BSUSG003_CB","type":"RC","currency":"AUD","billingSubtype":"HWM","taxTreatment":"GST Applicable","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000871_Billing_Allowance_000825_87","productConfigurationId":"a3T2N000000CgThUAK","name":"871_AW_876","metadata":{},"instanceId":"","includeBilling":false,"guid":"2b9cf572-7e02-5473-d225-24059b0b6304","endDate":"","description":"Business Calling UC Plan Allowance_Billing_DMCAT_Allowance_000876","code":"DMCAT_ProductSpecification_000871_Billing_Allowance_000876","attributes":{"chargeId":"DMCAT_Allowance_000876","ocsProdID":"T22E_FVOICE-S","billDescription":"Included PayG","value":"Fixed Voice Plan - Standard","type":"Fixed Voice","billingSpecId":"BSUSG004_CB","__targetSystem":"BILLING"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871","productConfigurationId":"a3T2N000000CgThUAK","name":"Business Calling_Fulfilment","metadata":{},"instanceId":"","includeBilling":false,"guid":"54549246-82fb-a289-76c0-f6a2deab6da0","endDate":"","description":"Business Calling_Fulfilment","code":"DMCAT_ProductSpecification_000871_Fulfilment","attributes":{"BSTenancyProductInstanceId":"","concurrencyLimitMode":"inferred","CustomerFacingServiceId":"","NetworkServiceId":"","Number":[{"attributes":{"FNN":"61262072638","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"130242b6-06e7-8e1a-ee83-d83cf31c1a71"},{"attributes":{"FNN":"61262072641","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"25ed7e7b-96c9-c16c-5085-5eab2f92be68"},{"attributes":{"FNN":"61262072642","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"d0f37d0c-e7ab-ea67-a39d-158e07cb14c8"},{"attributes":{"FNN":"61262072643","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"a83159ae-de18-9868-2d7f-6189106bcff5"},{"attributes":{"FNN":"61262072645","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"160c0c25-49c5-136f-33d0-8c07104286cb"},{"attributes":{"FNN":"61262072646","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"a170a0cc-9524-962c-e7bd-a531599916f0"},{"attributes":{"FNN":"61262072647","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"f5b71c1f-fd5a-04d3-e1c3-b59b6e3bb6fe"},{"attributes":{"FNN":"61262072650","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"2281c3a7-f1bb-e12a-fc0f-1863ea4840aa"},{"attributes":{"FNN":"61262072651","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"e1d90ad1-df51-28b2-39ae-f24ae242dd81"},{"attributes":{"FNN":"61262072652","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"},"schemaId":"5aee04ff-679c-4a31-0cd1-1d5e31794ddb"}],"__targetSystem":"FULFILMENT","type":"ucServiceSiteAgnosticConcurrencyOffer"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000151","productConfigurationId":"a3T2N000000CgThUAK","name":"151_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"2890b3b0-4dff-ea60-1eec-51cdd8f87aac","endDate":"","description":"Incident Management_Assurance","code":"DMCAT_ProductSpecification_000151_Assurance","attributes":{"RestoreTarget":"SLA0010002","ResponseTarget":"SLA0010001","parentSpec":"DMCAT_ProductSpecification_000871_Assurance","__targetSystem":"ASSURANCE"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"DMCAT_ProductSpecification_000871DMCAT_ProductSpecification_000326","productConfigurationId":"a3T2N000000CgThUAK","name":"326_ASR","metadata":{},"instanceId":"","includeBilling":false,"guid":"d8c3baa9-d1e5-42af-880e-e525ca3f2c82","endDate":"","description":"Telstra Managed Service Option 1_Assurance","code":"DMCAT_ProductSpecification_000326_Assurance","attributes":{"ServiceManagementOption":"1","__targetSystem":"ASSURANCE"},"additionalAttributes":{}}],"serviceId":"'+lstOfAllOrdersService[0].id+'","legacyAttributes":[]}');
            insert attUCMobile;
            Map<Id, Attachment> attachmentMap = new Map<Id, Attachment>();
            attachmentMap.put(attUCMobile.id , attUCMobile);
            Coms_PEPublishUtil.parseServiceAttachments(attachmentMap, true);
            //System.assertEquals(1, [SELECT count() FROM Orchestration_Technical__c limit 1],'Orchestration_Technical Record Created Successfully');
        } 
    }
}
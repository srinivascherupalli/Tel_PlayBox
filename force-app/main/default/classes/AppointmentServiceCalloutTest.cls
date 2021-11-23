/*-------------------------
Author: Ila Anmol Verma
US: EDGE-66239/66226
Description: Test Class for Generate appointment pre requisite for BOM 
---------------------------------*/

@isTest
public class AppointmentServiceCalloutTest {
    
    @testsetup static void dataSetup(){
        
        Account acc=new Account();
        acc.Name='testacc';
        acc.CIDN__c='987654321';
        acc.ABN__c='1235';
        acc.Customer_Status__c='ACTIVE';
        insert acc;
        
        Contact contact = TestUtil.createContact('Joe', 'Bloggs');
        contact.MobilePhone = '0445678006';
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
        
        
        cscrm__Site__c site = new cscrm__Site__c();
        site.cscrm__Account__c = acc.id;
        site.cscrm__Installation_Address__c = address.id;
        site.name = 'Sydney harbour house';
        site.Composite_Key__c = '1211010101010';
        upsert site;
      
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification primary';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.Billing_Account__c = billingAccount.id;
        insert ord;
        
        /*csord__Order__c secOrd = new csord__Order__c();	
        secOrd.csord__Identification__c = 'test identification';
        secOrd.csord__Account__c = acc.id;
        secOrd.csord__Order_Type__c = 'test order' ;
        secOrd.Billing_Account__c = billingAccount.id;
        secOrd.id = ord.id;
        insert secOrd;*/
        
        cscfga__Configuration_Offer__c originatingOffer = new cscfga__Configuration_Offer__c(name ='Test Originating offer');
        insert originatingOffer;
        
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.Offer_Reference__c = originatingOffer.id;
        productConfig.Type__c = 'Cancel';
        insert productConfig;
        
        
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        subs.csord__Order__c = ord.Id;
        subs.csord__Status__c='Subscription Created';
        subs.csordtelcoa__Subscription_Number__c = 'SN-000003199';
        //subs.csord__Order__c = ord.id;
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
        
        csord__Service__c servModify = new csord__Service__c();
        servModify.name ='User - Fixed Seat - Zone';
        servModify.csord__Identification__c  = 'test identify';
        servModify.csord__Subscription__c  = subs.id;
        servModify.csord__Order__c = ord.id;
        servModify.csordtelcoa__Service_Number__c = '3';
        insert servModify;
        
        csord__Service__c serviceUCMobile = new csord__Service__c();
        serviceUCMobile.name ='User - Fixed Seat - Zone';
        serviceUCMobile.csord__Identification__c  = 'test identify';
        serviceUCMobile.csord__Subscription__c  = subs.id;
        serviceUCMobile.csord__Order__c = ord.id;
        serviceUCMobile.csordtelcoa__Service_Number__c = 'SVC-313263';
        serviceUCMobile.csordtelcoa__Product_Configuration__c = productConfig.id;
        serviceUCMobile.Cust_Req_Disconn_Date__c= Date.newInstance(2019,12,9) ;
        serviceUCMobile.Zone__c = '1';
        insert serviceUCMobile;
        
        Attachment attUCMobile = new Attachment();
        attUCMobile.Name = 'ServiceSpecifications.json';
        attUCMobile.ParentId = serviceUCMobile.Id;
        attUCMobile.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serviceUCMobile.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"77ddbd9d-2b08-f941-491e-c86350c5f817"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","__targetSystem":"FULFILMENT","VoicePlan":"Complete Premium","id":"","CustomerFacingServiceId":"","Number":[{"schemaId":"6d1fd19b-8016-d07f-7c62-2c8561b9b0d1","attributes":{"FNN":"0895840676","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"LE"}},{"schemaId":"eacd50ce-d229-6138-b178-a577baeb1dad","attributes":{"FNN":"0895840678","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}},{"schemaId":"6169e889-4dc8-3c3d-5b62-29344d34b93a","attributes":{"FNN":"0895840679","rangeFrom":null,"rangeTo":null,"status":"RESERVED","listCode":"No Entry Line"}}]},"code":"DMCAT_ProductSpecification_000313_Fulfilment","description":"","endDate":"","guid":"2c9e42f7-3409-6465-7ff7-0ffdda328faa","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Fulfilment","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"77ddbd9d-2b08-f941-491e-c86350c5f817"},"attributes":{"__targetSystem":"FULFILMENT","name":"Hosted UC","CustomerFacingServiceId":"","id":"","parentSpec":"DMCAT_ProductSpecification_000322_Fulfilment","Quantity":"3"},"code":"DMCAT_ProductSpecification_000315_Fulfilment","description":"","endDate":"","guid":"0018c986-dbb5-d021-2342-cef0b2ebd84a","includeBilling":false,"instanceId":"","metadata":{},"name":"Feature Packs_Fulfilment","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000315","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"BSServiceTypeProductInstanceID":"DMCAT_ProductSpecification_000312_Fulfilment","__targetSystem":"FULFILMENT","CustomerFacingServiceId":"","CustomerPreferredName":"","DMCAT_ProductSpecification_000322_CPEDeliveryDate":""},"code":"DMCAT_ProductSpecification_000322_Fulfilment","description":"","endDate":"","guid":"77ddbd9d-2b08-f941-491e-c86350c5f817","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Site_Fulfilment","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000322","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","UserProtectionType":"Web and Mail","InternetProtectionSolutionProductInstanceID":"DMCAT_ProductSpecification_000163_Fulfilment","Quantity":"3"},"code":"DMCAT_ProductSpecification_000162_Fulfilment","description":"","endDate":"","guid":"045e20d0-79b5-84a9-e9e2-d4315cb175ac","includeBilling":false,"instanceId":"","metadata":{},"name":"Web and Mail Internet Protection User_Fulfilment","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000162","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"ASSURANCE","ServiceManagementOption ":"1"},"code":"DMCAT_ProductSpecification_000326_Assurance","description":"","endDate":"","guid":"298d3145-c33c-1f99-9acf-fa6ebe663e14","includeBilling":false,"instanceId":"","metadata":{},"name":"Telstra Managed Service Option 1_Assurance","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000326","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"298d3145-c33c-1f99-9acf-fa6ebe663e14"},"attributes":{"__targetSystem":"ASSURANCE","parentSpec":"DMCAT_ProductSpecification_000326_Assurance","ResponseTarget":"SLA0010001","RestoreTarget":"SLA0010002"},"code":"DMCAT_ProductSpecification_000151_Assurance","description":"","endDate":"","guid":"8b887c5b-2dcc-cc77-a1a4-3824fa9dba33","includeBilling":false,"instanceId":"","metadata":{},"name":"Incident Management_Assurance","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductSpecification_000326DMCAT_ProductSpecification_000151","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"batteryBackup":"FALSE","__targetSystem":"FULFILMENT","serviceRestorationSLA":"Enhanced - 8 (24/7)","CustomerFacingServiceId":"","CustomerPreferredName":"","IPVPNProductInstanceID":"DMCAT_ProductSpecification_000028_Fulfilment","AccessRole":"Primary","MulticastEnabled":"FALSE","NBNTechnologyType":"FTTP","BandwidthType":"standard","ServiceabilityClass":"2","NBNBandwidth":"50M/20M"},"code":"DMCAT_ProductSpecification_000549_Fulfilment","description":"","endDate":"","guid":"9f7b7588-1415-ec1c-75fd-13da63f99772","includeBilling":false,"instanceId":"","metadata":{},"name":"NBN IP Access_Fulfilment","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductOffering_000304DMCAT_ProductSpecification_000549","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","billingSpecId":"BSUSG001_CB","ocsProdID":"ocsProd3","type":"Dummy ngUC","unitofMeasure":"GB","value":"Unlimited","RoutingServiceType":"Voice","billDescription":"ngUC Dummy Usage Specification Allowance"},"code":"DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4","description":"","endDate":"","guid":"73dfac9c-4af8-f32e-243f-9470ca298b4f","includeBilling":false,"instanceId":"","metadata":{},"name":"UC Numbers_Bill_AW","productConfigurationId":"a3T2O000000J7NeUAK","specification":"DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313_Billing_Allowance_000512_4","startDate":"","status":"Created","version":"1"}]}');
        insert attUCMobile;
       
}
    
    @istest 
    public static void testAppointmentSuccess(){
        Test.startTest();
         //List<csord__Subscription__c> sub = [select id, Site__r.Display_Name__c,Primary_Order__r.csord__Order_Number__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where name = 'test subs'];

        List<csord__Subscription__c> sub = [select id,Site__c,toBeCancelled__c,csord__Order__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.cscrm__Installation_Address_Details__c,site__r.Address__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where name = 'test subs'];

        string subid = sub[0].id;
		String orderId = [Select id from csord__Order__c where csord__Identification__c = 'test identification primary'].id;
        AppointmentServiceCallout.getSubscriptionIds(orderId);
        //AppointmentServiceCallout.generateAppointmentForErrorScenario(orderId,subid);
        
        String json='{"status":200,"time":"2019-02-01T12:45:10","correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","path":"/v1/appointments/appointment-bom","method":"POST","data":{"transactionReferenceID":"MyOrderNumber123","callingSystemID":"b2b","bomID":"BOM0000000009","numberOfAppointmentsRequired":2,"requiredAppointments":[{"arrayItemNumber":1,"appointmentCategory":"NBN","appointmentType":"STANDARD INSTALL","appointmentSubType":"STANDARD","suggestedStartDate":"2019-06-03T00:05:00","minimumStartDate":"2019-02-04T00:05:00","baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000027","productInstanceID":"463949fd-e9b7-f459-b34f-4bcdb7d5b8d2"}]},{"arrayItemNumber":2,"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"CUST PREMISES","suggestedStartDate":"2019-06-14T00:05:00","minimumStartDate":"2019-02-04T00:05:00","dependencies":[{"dependentArrayItemNumber":1,"leadTimeDaysApplied":3}],"baseRuleProducts":[{"productID":"DMCAT_ProductSpecification_000073","productInstanceID":"397949fd-e6a7-f459-b34f-4bcdb7d5b5c1"}]}]}}';
		AppointmentResponseDTO resJson = AppointmentResponseDTO.parse(json);
        AppointmentServiceCallout.saveAppointment(resJson,orderId,subid);
        AppointmentServiceCallout calloutobj = new AppointmentServiceCallout();
        calloutobj.generateAppointmentForErrorScenario(orderId,subid);
        AppointmentServiceCallout.nextOrderStatus(orderId);
        AppointmentServiceCallout.getSuggestedDate(subid,'NBN');
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo'));
         String jobId1 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        System.assertEquals((jobId1!=null), true, 'Enqueued');
         Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo1'));
        String jobId5 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo2'));
		String jobId2 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo3'));
		String jobId3 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('success_GenerateAppo4'));
		String jobId4 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        Test.stopTest();
        }
    
     @istest 
    public static void testAppointmentError(){
           Test.startTest();
          List<csord__Subscription__c> sub = [select id, Site__r.Display_Name__c,Primary_Order__r.csord__Order_Number__c,csordtelcoa__Replacement_Subscription__c,csordtelcoa__Product_Configuration__r.Type__c,site__r.cscrm__Installation_Address_Details__c,site__r.Address__c,Serviceability_Location__c,csord__Order__r.csord__Order_Number__c from csord__Subscription__c where name = 'test subs' LIMIT 1];
		String orderId = [Select id from csord__Order__c where csord__Identification__c = 'test identification primary'].id;
          Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('Error'));
         String jobId2 = System.enqueueJob(new AppointmentServiceCalloutQ(sub,orderId));
        Test.stopTest();
          System.assertNotEquals(jobId2, NULL);
    }
  
}
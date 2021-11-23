/*
===============================================================================================================================
Class : CPEDeliveryDateUpdateForMACTest
Developer Name : Manish Kumar 
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Manish Kumar        15/06/2018    Test Class for CPEDeliveryDateUpdateForMACTest(EDGE-12496)
===============================================================================================================================
@LastModified:	Modified by Sri, team SFO on 16/01/2020 
				P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  
*/

@isTest
public Class CPEDeliveryDateUpdateForMACTest{

    @isTest
    static void addCPEAttr(){

        Profile pf = [SELECT Id,Name FROM Profile WHERE name ='Sales Enterprise B2B'];
        User usr = new User(Alias = 'standt', Email='standarduser@telestra.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = pf.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@telestra.com',phone='+121231231234');
        insert usr;

        System.runAs(usr) {
            Test.startTest();
            List<cscfga__Attribute__c> attrList= new List<cscfga__Attribute__c>();
            List<Attachment> attList = new List<Attachment>();

            Account acc = new Account(Name = 'TestAccount');
			acc.Pref_Comm_Method__c = 'Phone';
            acc.Phone = '0478956236';
			//Modified by Sri, team SFO on 16/01/2020
			//P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            acc.Imported__c = true;
			insert acc;
            
            cscfga__Product_Definition__c pd= ProductTestFactory.buildProductDefinition('Testdef','Testdef');
            insert pd;

            cscfga__Product_Configuration__c pc = ProductTestFactory.buildProductConfig(pd.id);
            pc.name= 'IP Site';
            insert pc;

            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('ChangeType', 'Upgrade', pc.Id);
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('IPSiteConfigurationChanged', '', pc.Id);
            attrList.add(attr1);
            attrList.add(attr2);
            insert attrList;

            csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
            insert ordReq;
            csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
            insert ord;
            csord__Subscription__c subs = ProductTestFactory.buildSubscription('TestSub', acc.id, ord.id, ordReq.id);
            insert subs;
            csord__Service__c ser = ProductTestFactory.buildService('TestService', ord.id, subs.id, ordReq.id);
            ser.name = 'IP Site';
            ser.csordtelcoa__Product_Configuration__c = pc.id;
            insert ser;

            Attachment att1 = new Attachment();
            att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"80577323-8623-d45a-8041-f6a3134c55f7","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VPN","instanceId":"ef2af0e2-e668-a8e5-e889-ddc868fdbc98","guid":"ef2af0e2-e668-a8e5-e889-ddc868fdbc98","endDate":"","description":"","code":"PS_000028","attributes":{"CPE":"12/05/2020"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"25a45c3e-f49c-c83f-fdb4-e59e8005c7ab","productConfigurationId":"a3T2O0000002CCjUAM","name":"IP VAS Internet Port","instanceId":"46ef0d1a-323b-271a-0706-84df9ee8d080","guid":"46ef0d1a-323b-271a-0706-84df9ee8d080","endDate":"","description":"","code":"PS_000106","attributes":{},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"8fcc67fc-feb4-2ae9-79a5-b8a3c42e22b0","productConfigurationId":"a3T2O0000002CCjUAM","name":"Enterprise Internet","instanceId":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","guid":"da1c712f-8764-c7c3-acd4-c3121bdc44oo","endDate":"","description":"","code":"PS_000114","attributes":{},"additionalAttributes":{}}],"serviceId":"'+ser.Id+'","legacyAttributes":[]}');
            att1.Name = 'ServiceSpecifications.json';
            att1.ParentId = ser.Id;
            attList.add(att1);

            Attachment att2 = new Attachment();
            att2.Body = Blob.valueOf('{"subscriptions":[{"subscriptionId":"a4g2O0000000O1lQAE","services":[{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"1dc6e0f9-b1f3-151d-da28-1b52c66cf55c","productConfigurationId":"a3T2O0000000yJUUAY","name":"Managed Device","instanceId":"1234","guid":"92b54a6b-1bbd-2bd5-ce7c-8a15a96f52bd","endDate":"","description":"Managed Device","code":"CFS_00005","attributes":{"ModuleInstanceId":"MODULE_INSTANCE_ID"},"additionalAttributes":{}}],"serviceId":"a4e2O0000000IGoQAM","legacyAttributes":[]}]}],"orderId":"a4b2O0000000GQPQA2"}');
            att2.Name = 'OrderSpecifications.json';
            att2.ParentId = ord.Id;
            attList.add(att2);
            insert attList;

            CPEDeliveryDateUpdateForMAC.addCPEAttr(new List<Id>{ser.Id});
            
            Test.stopTest();

            Map<Id, List<CS_SpecificationDTO.ServiceSpecification>> updatesSpecMap = CPEDeliveryDateUpdateForMAC.getOrderSpecs(new List<Id>{ord.Id});
            for(List<CS_SpecificationDTO.ServiceSpecification> updatedSpecs : updatesSpecMap.values()) {
                for(CS_SpecificationDTO.ServiceSpecification updatedSpec : updatedSpecs) {
                    if(updatedSpec.guid == 'ef2af0e2-e668-a8e5-e889-ddc868fdbc98'){
                        System.assertEquals(1, updatedSpec.additionalAttributes.size());
                    }
                }
            }
        }
    }
}
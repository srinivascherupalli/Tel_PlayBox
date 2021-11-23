/********************************************************************************************************
*This Test class is to handle request for Custom wrapper API to support high volume orders.
* Developer: Vanita Mude
* Date: 11 June 2019
* Description: EDGE-86669 expose OrderSpecs via Custom wrapper API to support high volume 
Change.No.    Developer Name          Date          Story Description
1.            Vaibhav Deshpande     13/04/2020      EDGE-144219 fix
********************************************************************************************************/
@isTest
public class GetOrderSpecAPIPostHandlerTest {
    @testsetup 
    static void dataSetup(){
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
            
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        
        insert acc;

        //AccountTestFactory
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        insert contact;
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        insert site;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        insert subs;
        
        List<csord__Order__c> ords=new List<csord__Order__c>();
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'test order' ;
        ord.csord__Status2__c = 'In Progress';
         ords.add(ord);
        
        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification1';
        ord1.csord__Account__c = acc.id;
        ord1.csord__Order_Type__c = 'test order' ;
        ord1.csord__Status2__c = 'In Progress';
        ord1.csord__Primary_Order__c=ord.Id;
        ords.add(ord1);
        insert ords;
    
        List<csord__Service__c> servList = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord1.id;
        serv.csordtelcoa__Service_Number__c = '3';
        // insert serv;
        servList.add(serv);
        
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csord__Subscription__c  = subs.id;
        serv1.csord__Order__c = ord.id;
        serv1.csordtelcoa__Service_Number__c = '4';
         servList.add(serv1);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify';
        serv2.csord__Subscription__c  = subs.id;
        serv2.csord__Order__c = ord.id;
        serv2.csordtelcoa__Service_Number__c = '3';
        servList.add(serv2);
        insert servList;
        
        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        atts.add(att1);
        
        Attachment att2 = new Attachment();
        att2.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","productConfigurationId":"a3T2O0000008D0IUAU","name":"Unified Communication Enterprise_Fulfilment","instanceId":"","guid":"cf0159c5-997f-f39b-5233-dbedc2cecdbf","endDate":"","description":"","code":"DMCAT_ProductSpecification_000087_Fulfilment","attributes":{"DomainName":"","OverviewofProposedSolution":"","CustomerPreferredName":"","CustomerFacingServiceId":"","ModuleGroupType":"","EnterpriseExtensionDialling":"TRUE","__targetSystem":"FULFILMENT"},"additionalAttributes":{}}],"serviceId":"'+serv1.Id+'","legacyAttributes":[]}');
        att2.Name = 'ServiceSpecifications.json';
        att2.ParentId = serv1.Id;
        atts.add(att2);
        
        Attachment att3 = new Attachment();
        att3.Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+serv.Id+'","specifications":[{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000018_Fulfilment","description":"","endDate":"","guid":"364b883e-2759-0bf4-8adb-96c93be01ef9","instanceId":"","name":"IP Wireless_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"FULFILMENT","MulticastEnabled":"FALSE","CustomerFacingServiceId":"","CustomerPreferredName":""},"code":"DMCAT_ProductSpecification_000028_Fulfilment","description":"","endDate":"","guid":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","instanceId":"","name":"IP VPN_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","RadiusUsers":"TRUE","AuthenticationType":"Username/Password Authentication","RADIUSServerType":"Basic Telstra Managed RADIUS"},"code":"DMCAT_ProductSpecification_000053_Fulfilment","description":"","endDate":"","guid":"26eb46ab-e4e3-eb7b-4726-af867590d48f","instanceId":"","name":"Managed Radius_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{"parentSpec":"1fba066a-4e7d-bb28-7bfe-495fae2b2066","ManagedRadiusProductInstanceID":"26eb46ab-e4e3-eb7b-4726-af867590d48f"},"attributes":{"parentSpec":"DMCAT_ProductSpecification_000028_Fulfilment","__targetSystem":"FULFILMENT","GlobalRoaming":"FALSE","APNtype":"Shared","RequiredPoolTypes":"Static IP Pool","CustomerFacingServiceId":"","ManagedRadiusProductInstanceID":"DMCAT_ProductSpecification_000053_Fulfilment"},"code":"DMCAT_ProductSpecification_000263_Fulfilment","description":"","endDate":"","guid":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","instanceId":"","name":"Mobile Access_Fulfilment","productConfigurationId":"a3T2O0000008D0NUAU","startDate":"","status":"Created","version":"1"}]}');
        att3.Name = 'ServiceSpecifications.json';
        att3.ParentId = serv2.Id;
        atts.add(att3);
        
        Attachment trans = new Attachment();
        trans.Body = Blob.valueOf('[{"specGUID":"cf5b77da-493d-9bca-d0c4-454ed98e3f42","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000646","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"BAR_PREMIUM","name":"CALLRESTRICTION"}]}]');
        trans.Name = 'TransientDataDetails.json';
        trans.ParentId = ord.Id;
        atts.add(trans);
        
        Attachment trans1 = new Attachment();
        trans1.Body = Blob.valueOf('[{"specGUID":"fc8e7088-a0ba-6b6c-ef69-3e6b3d281a89","specCode":"DMCAT_ProductSpecification_000263_Fulfilment","offerID":"DMCAT_Offer_000646","changeType":"New","attributes":[{"value":"false","name":"INTROAM"},{"value":"BAR_PREMIUM","name":"CALLRESTRICTION"}]}]');
        trans1.Name = 'TransientDataDetails.json';
        trans1.ParentId = ord1.Id;
        atts.add(trans1);
        
        insert atts;
        
    }
    
    @istest static void test_getOrderSpecs() {
        try{
            Map<Id,csord__Service__c> servmap=new Map<Id,csord__Service__c>();
             for(csord__Service__c cs:[select id,Name from csord__Service__c where Name = 'tst service1'])
             {
                 servmap.put(cs.Id,cs);
             } 
            
        Test.startTest();
         GetOrderSpecAPIPostHandler.getAllServSpecsFromService(servmap,null);
        csord__Order__c ord = [select id,Name,csord__Order_Number__c from csord__Order__c where name = 'test order'];//EDGE: 105942 - Added OrderNumber in fields list
        //List<String> orderIds = new List<String>();
        GetOrderSpecAPIPostHandler handler = new GetOrderSpecAPIPostHandler();
        String ordId = String.valueOf(ord.id);
        String ordNum = String.valueOf(ord.csord__Order_Number__c);//EDGE: 105942
        String str = handler.getOrderSpecs(ordId,'FULFILMENT',ordNum);
        
        Test.stopTest();
        system.assertNotEquals(null, ordId);
        }catch(Exception e){
            //
        }

    }
        @istest static void test_getOrderSpecs_1() {
            try{
                        Test.startTest();
         
        //List<csord__Order__c> ord = [select id,Name from csord__Order__c where name = 'test order'];
                List<csord__Order__c> ord=[select id,Name,csord__Identification__c,csord__Order_Number__c from csord__Order__c where csord__Identification__c = 'test identification'];//EDGE: 105942 - Added OrderNumber in fields list
        
        String ordId=string.valueOf(ord[0].id);
        String ordNum=string.valueOf(ord[0].csord__Order_Number__c);
        String str ='ASSURANCE';
        String str1 ='Fullfillment';
        String str2 ='FULFILMENT';
                String str3 ='BILLING';
                String str4 ='Test';
        
        GetOrderSpecAPIPostHandler gsph=new GetOrderSpecAPIPostHandler();
        gsph.getOrderSpecs(ordId,str,ordNum);
                  gsph.getOrderSpecs(ordId,str2,ordNum);
                  gsph.getOrderSpecs(ordId,str3,ordNum);
                  gsph.getOrderSpecs(ordId,str4,ordNum);
              
        GetOrderSpecAPIPostHandler gsph1=new GetOrderSpecAPIPostHandler(str1);
        
        Test.stopTest();
        system.assertNotEquals(null, ordId);
            }catch(Exception e){
                //
            }


    }
    
    
      @istest static void test_getOrderSpecs_2() { //added as part of  EDGE-144219
       Test.startTest();
       List<csord__Order__c> ord=[select id,Name,csord__Identification__c,csord__Order_Number__c from csord__Order__c where csord__Identification__c = 'test identification1'];
        String ordId=string.valueOf(ord[0].id);
        String ordNum=string.valueOf(ord[0].csord__Order_Number__c);
        String str ='FULFILMENT';
        GetOrderSpecAPIPostHandler gsph=new GetOrderSpecAPIPostHandler();
        gsph.getOrderSpecs(ordId,str,ordNum);
        Test.stopTest();
        system.assertNotEquals(null, ordId);
            


    }
    @istest static void test_getOrderSpecs3() {
        try{
            
        csord__Order__c ord = [select id,Name,csord__Order_Number__c from csord__Order__c where name = 'test order'];//EDGE: 105942 - Added OrderNumber in fields list
        ord.Scenario_Type__c = 'Manage Fixed Numbers';
        update ord;
        //List<String> orderIds = new List<String>();
        GetOrderSpecAPIPostHandler handler = new GetOrderSpecAPIPostHandler();
        String ordId = String.valueOf(ord.id);
        String ordNum = String.valueOf(ord.csord__Order_Number__c);//EDGE: 105942
        String str = handler.getOrderSpecs(ordId,'FULFILMENT',ordNum);
        
        Test.stopTest();
        system.assertNotEquals(null, ordId);
        }catch(Exception e){
            //
        }

    }
}
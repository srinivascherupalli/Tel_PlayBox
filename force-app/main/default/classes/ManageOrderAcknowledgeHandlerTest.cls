@isTest
private class ManageOrderAcknowledgeHandlerTest {
    

    @testsetup 
    static void dataSetup(){
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};

        Account acc = new Account();
        acc.Name = 'test Account' ; 
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c='ACTIVE';
        /*acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        //acc.Account_Status__c='ACTIVE';
        */
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
        //opp.Pricebook2 = pb;
        opp.StageName = 'Committed';
        opp.CloseDate = System.today();
        /*opp.name='opp1';
        //opp.StageName='Closed Won';
        opp.StageName='Propose';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;*/
        insert opp;
        
        
        //AccountTestFactory
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        //Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        //insert contact;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='+61123456789';
        contact.email='k@gmail.com';
        //contact.AccountId = acc.id;
        insert contact;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        insert ocr;
        
        
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        site.Primary_Contact__c = contact.Id;
        insert site;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.Site__c = site.Id;
        subs.csord__Status__c = 'Pending';
        insert subs;

        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();

        csord__Order_Request__c ordReq = new csord__Order_Request__c();
        ordReq.name = 'OR1-12121';
        ordReq.csord__Module_Name__c = 'TestReq1';
        ordReq.csord__Module_Version__c = '121';
        ordReqList.add(ordReq);

        csord__Order_Request__c ordReq2 = new csord__Order_Request__c();
        ordReq2.name = 'OR2-12121';
        ordReq2.csord__Module_Name__c = 'TestReq2';
        ordReq2.csord__Module_Version__c = '122';
        ordReqList.add(ordReq2);

        csord__Order_Request__c ordReq3 = new csord__Order_Request__c();
        ordReq3.name = 'OR3-12121';
        ordReq3.csord__Module_Name__c = 'TestReq3';
        ordReq3.csord__Module_Version__c = '123';
        ordReqList.add(ordReq3);

        insert ordReqList;
        
        List<csord__Order__c> orders = new List<csord__Order__c>();
        csord__Order__c ord = new csord__Order__c();
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c = acc.id;
        ord.csord__Order_Type__c = 'Test order' ;
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Status2__c = 'In Progress';
        ord.csordtelcoa__Opportunity__c = opp.id;
        orders.add(ord);
        System.debug('ord 1:::'+ord);

        csord__Order__c ord1 = new csord__Order__c();
        ord1.csord__Identification__c = 'test identification1';
        ord1.csord__Account__c = acc.id;
        ord1.csord__Order_Type__c = 'Amend' ;
        ord1.csord__Order_Request__c = ordReq2.Id;
        ord1.csord__Status2__c = 'In Progress';
        ord1.csordtelcoa__Opportunity__c = opp.id;
        
        orders.add(ord1);
        System.debug('ord 1:::'+ord1);

        csord__Order__c ord2 = new csord__Order__c();
        ord2.csord__Identification__c = 'test identification2';
        ord2.csord__Account__c = acc.id;
        ord2.csord__Order_Request__c = ordReq3.Id;
        ord2.Fulfilment_Order_Version__c = 0 ;
        ord2.csord__Order_Type__c = 'Amend' ;
        ord2.csord__Status2__c = 'In Progress';
        ord2.csordtelcoa__Opportunity__c = opp.id;
        orders.add(ord2);
        System.debug('ord 1:::'+ord2);

        csord__Order__c ord3 = new csord__Order__c();
        ord3.csord__Identification__c = 'test identification2 Secondary';
        ord3.csord__Account__c = acc.id;
        ord3.csord__Order_Request__c = ordReq3.Id;
        ord3.Fulfilment_Order_Version__c = 0 ;
        ord3.csord__Order_Type__c = 'Amend' ;
        ord3.csord__Status2__c = 'In Progress';
        //ord3.csordtelcoa__Opportunity__c = opp.id;
        orders.add(ord3);

        csord__Order__c ord4 = new csord__Order__c();
        ord4.csord__Identification__c = 'Rejected';
        ord4.csord__Account__c = acc.id;
        ord4.csord__Order_Request__c = ordReq3.Id;
        ord4.csord__Status2__c = 'Amend Rejected';
        ord4.csord__Order_Type__c = 'Order' ;
        orders.add(ord4);
        System.debug('ord 1:::'+ord3);

        
        insert orders;
    
        List<csord__Service__c> srvcs = new List<csord__Service__c>();
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c  = subs.id;
        serv.csord__Order__c = ord.id;
        serv.csordtelcoa__Service_Number__c = '3';
        srvcs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csord__Subscription__c  = subs.id;
        serv1.csord__Order__c = ord3.id;
        serv1.csordtelcoa__Service_Number__c = '4';
        srvcs.add(serv1);
        
        insert srvcs;

        List<Attachment> atts = new List<Attachment>();
        Attachment att1 = new Attachment();
        //att1.Body = Blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a0b0Y000001oXmtQAE","name":"CWPSpec","instanceId":"1234","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"CWP CFS Specification","code":"CWPSpec01","attributes":{"Zone":"Zone 3","TotalMRC":1500,"Seat":5,"complexIPAccess":[{"attributes":{"complexAttrPort":8080,"complexAttrTech":"Fibre"},"productConfigurationId":"a0b0Y000001oXmyQAE"},{"attributes":{"complexAttrPort":9090,"complexAttrTech":"Ethernet"},"productConfigurationId":"a0b0Y000001oXn3QAE"}],"constantName":"contantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXmyQAE","name":"IPAccessSpec","instanceId":"3456","guid":"3df57fcf-7c28-c50a-140b-0d21e80714e7","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":8080,"Technology":"Fibre","constantAttr":"constantValue"}},{"version":"1","status":"Created","startDate":"","specification":"13bbe8ea-1d7d-19cf-dca2-aa107bd0718f","productConfigurationId":"a0b0Y000001oXn3QAE","name":"IPAccessSpec","instanceId":"6789","guid":"495bbebb-5166-6dce-24cd-648084f6241c","endDate":"","description":"IP Access Specification","code":"IPAccessSpec01","attributes":{"Port":9090,"Technology":"Ethernet","constantAttr":"constantValue"}}],"serviceId":"a1B0Y000001EnjrUAC","legacyAttributes":[]}');
        att1.Body = blob.valueOf('{"specifications":[{"version":"1","status":"Created","startDate":"","specification":"30a0f36c-b496-185e-6330-c7a9c317d22c","productConfigurationId":"a3T2O0000002CCjUAM","name":"Telstra Fibre","instanceId":"","guid":"3072dad2-5546-eb71-8e13-bd04b7f9824a","endDate":"","description":"","code":"PS_000027","attributes":{"__targetSystem":"FULFILMENT","PS_000027_ feasibilityNumber":22,"Appointment_EndDateTime":"11:50","Appointment_StartDateTime":"10:20","Appointment_Category":"Standard","Appointment_ID":"007","parentSpec":"PS_000028"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"95f3f970-3828-4bae-b219-b8b2089ddf02","productConfigurationId":"a3T2O0000002CCjUAM","name":"Port","instanceId":"","guid":"085d571e-c9dc-86f9-d25a-816ec4a7cb8b","endDate":"","description":"","code":"PS_000030","attributes":{"__targetSystem":"FULFILMENT","parentSpec":"PS_000028"},"additionalAttributes":{}},{"version":"1","status":"Created","startDate":"","specification":"901e7c04-7568-4bdb-99cb-d65a141da925","productConfigurationId":"a3T2O0000002CCjUAM","name":"Unified Communication Site","instanceId":"","guid":"3a338ad9-6c6e-abf5-ca34-857ad7304b86","endDate":"","description":"","code":"PS_000095","attributes":{"__targetSystem":"FULFILMENT","Service Assurance Level":"EndOfNextBusinessDay","reliesOn":"PS_000007","Customer Preferred Name":"","Customer Facing Service Id":"","childSpec":"PS_000074"},"additionalAttributes":{}}],"serviceId":"'+serv.Id+'","legacyAttributes":[]}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;
        
    }

    @isTest static void testOrderAcknowledgementsSuccess() {
        csord__Order__c ord = [SELECT Id, Name from csord__Order__c WHERE csord__Identification__c = 'test identification' limit 1];
        Map<Id, String> ordStatusMap = new Map<Id, String>();
        ordStatusMap.put(ord.id,'Success');
        Test.startTest();
        ManageOrderAcknowledgeHandler.processAcknowledgements(ordStatusMap);
        Test.stopTest();
        csord__Order__c ord1 = [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Identification__c = 'test identification' limit 1][0];
        System.assertnotEquals(null, ord1.csord__Status2__c);
    }

    @isTest static void testOrderAcknowledgementsFailure() {
        csord__Order__c ord = [SELECT Id, Name from csord__Order__c  WHERE csord__Identification__c = 'test identification1'  limit 1][0];
        Map<Id, String> ordStatusMap = new Map<Id, String>();
        ordStatusMap.put(ord.Id,'');
        Test.startTest();
        ManageOrderAcknowledgeHandler.processAcknowledgements(ordStatusMap);
        Test.stopTest();
        csord__Order__c ord1 = [SELECT Id, Name, csord__Status2__c from csord__Order__c WHERE csord__Identification__c = 'test identification1' limit 1][0];

        System.assertEquals('In Error', ord1.csord__Status2__c);
    }

    @isTest static void testOrderAcknowledgementsAmend() {
        csord__Order__c ord = [SELECT Id, Name from csord__Order__c  WHERE csord__Identification__c = 'test identification2'  limit 1][0];
        Map<Id, String> ordStatusMap = new Map<Id, String>();
        ordStatusMap.put(ord.id,'Success');
        ManageOrderAcknowledgeHandler.processAcknowledgements(ordStatusMap);
        Test.startTest();
        csord__Order__c ord1 = [SELECT Id, Name, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c from csord__Order__c WHERE csord__Identification__c = 'test identification2' limit 1][0];
        System.assertnotEquals(null, ord1.csord__Status2__c);
     
        //System.assertEquals(1, ord1.Fulfilment_Order_Version__c);
        csord__Order__c ordSecondary = [SELECT Id, Name, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c from csord__Order__c WHERE csord__Identification__c = 'test identification2 Secondary' limit 1];
        System.assertEquals('In Progress', ordSecondary.csord__Status2__c);
        //System.assertEquals(1, ordSecondary.Fulfilment_Order_Version__c);
        Test.stopTest();
    }
    
    @isTest static void processAcknowledgementsMSUpdateTest() {
        List<csord__Order__c> ordList = [SELECT Id, Name,csord__Identification__c, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate,csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c from csord__Order__c ];
        Map<Id, String> orderStatusMap=new Map<Id, String>();
    Map<Id,Boolean> ordIdisSuspendResumeMap=new Map<Id,Boolean>();
    
    for(csord__Order__c ord:ordList)
    {
      if(ord.csord__Identification__c=='test identification')
      {
        orderStatusMap.put(ord.id,'Success');
        ordIdisSuspendResumeMap.put(ord.id,false);
      }else
      {
        orderStatusMap.put(ord.id,'In Progress');
        ordIdisSuspendResumeMap.put(ord.id,false);
      }
    }

        Test.startTest();
    
      ManageOrderAcknowledgeHandler.processAcknowledgementsMSUpdate(ordList,orderStatusMap,ordIdisSuspendResumeMap);
        System.assertnotEquals(null, ordList[0].csord__Identification__c);
        Test.stopTest();
    }
    
    @isTest static void testRejectedOrder() { //added as part of EDGE-170550
      List<csord__Order__c> ordList = [SELECT Id, Name,csord__Identification__c, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate,csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c from csord__Order__c where csord__Identification__c = 'Rejected'];
      Map<Id, String> orderStatusMap=new Map<Id, String>();
      Map<Id,Boolean> ordIdisSuspendResumeMap=new Map<Id,Boolean>();
      for(csord__Order__c ord :ordList)
      {
        orderStatusMap.put(ord.id,'Success');
        ordIdisSuspendResumeMap.put(ord.id,false);
      }
     Test.startTest();
  
    ManageOrderAcknowledgeHandler.processAcknowledgementsMSUpdate(ordList,orderStatusMap,ordIdisSuspendResumeMap);
    csord__Order__c ord1 = [SELECT Id, Name,csord__Identification__c, csord__Order_Number__c, csord__Primary_Order__c, CreatedDate,csord__Order_Request__c, csord__Status2__c, Fulfilment_Order_Version__c,csord__Order_Type__c,csordtelcoa__Opportunity__c from csord__Order__c where csord__Identification__c = 'Rejected'];
      System.assertnotEquals('In Progress',ord1.csord__Status2__c);
      Test.stopTest();
  }
    
    
}
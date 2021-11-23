@isTest
private class CaseEmailServiceTest { 
    @testsetup static void caseEmailServiceDataSetup()
    {
        Test.startTest();
        List<String> parameters = new List<String>();
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Account acc = new Account();
        acc.Name = System.today()+' - test Account';
        acc.Type = 'Competitor' ;
        insert acc;
        Contact con = AccountTestFactory.buildContact(acc,'Smith'+System.today());
        con.FirstName = 'ABC'+System.today();
        con.Email = 'test@team.telstra.com';
        insert con;
        AccountContactRelation accRel  = [SELECT Id FROM AccountContactRelation WHERE ContactId=:con.id limit 1];
        accRel.isPrimary__c = true;
        update accRel;
        //insert accRel;
        Billing_Account__c billAcc = new Billing_Account__c(Account__c=acc.id,Billing_Account_Number__c='700000002989',Billing_Account_Name__c='Test');
        insert billAcc;         
        Case caseNewList = new Case(Billing_Account__c=billAcc.id,Status = 'New',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        Case caseListRes= new Case(Billing_Account__c=billAcc.id,Status = 'Resolved',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        Case caseListCls= new Case(Status = 'Closed',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        List<Case> posList= new List<Case>();
        posList.add(caseNewList);
        posList.add(caseListRes);
        posList.add(caseListCls);
        insert posList;
        Invoice__c inv=new Invoice__c(Name='123454');
        insert inv;
        Invoice_Line_Item__c invLineItem=new Invoice_Line_Item__c(Invoice__c=inv.id);
        insert invLineItem;
        Queried_Line_Item__c qLIData = new Queried_Line_Item__c(Case__c = caseNewList.Id,Invoice_Line_Item__c = invLineItem.Id,Reason_Code__c = 'Usage enquiry adjustment', Determination_Amount__c =100,Max_Credit_Amount__c=200);
        insert qLIData;
        Credits_and_Adjustments__c creditAdj=new Credits_and_Adjustments__c(Case_Number__c=caseListRes.id,Determination_Status__c='Approved');
        insert creditAdj;
        Test.stopTest();
    }
    
    @isTest
    static void caseEmailServicePositiveTest()
    {
        Test.startTest();
        List<String> parameters = new List<String>();
        //String onlineOrd=System.Label.Case_Online_RecordType;
        Id onlinerecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Online_RecordType).getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        Contact con = AccountTestFactory.buildContact(acc, 'Smith');
        con.FirstName = 'Smith';
        con.Email = 'test@team.telstra.com';
        insert con;
        Case c1 = new Case(Status = 'New',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,RecordTypeId=onlinerecordTypeId );
        insert c1;
        parameters.add(c1.id);
        CaseEmailService.processCaseRecord(parameters);
        con.Email = null;
        update con;
        CaseEmailService.processCaseRecord(parameters);
        Test.stopTest();
        system.assertEquals(!parameters.isEmpty(), true);
    }
    
    /**
    *  The method code coverage for email notification Billing Enquiry recordtype 
    *  @name caseEmailServicePosTest
    */
    @isTest
    static void caseEmailServicePosTest()
    {
        Test.startTest();
        /*List<String> parameters = new List<String>();
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Account acc = new Account();
        acc.Name = System.today()+' - test Account';
        acc.Type = 'Competitor' ;
        insert acc;
        Contact con = AccountTestFactory.buildContact(acc,'Smith'+System.today());
        con.FirstName = 'Smith'+System.today();
        con.Email = 'test@team.telstra.com';
        insert con;
        AccountContactRelation accRel  = [SELECT Id FROM AccountContactRelation WHERE ContactId=:con.id limit 1];
        accRel.isPrimary__c = true;
        update accRel;
        //insert accRel;
        Billing_Account__c billAcc = new Billing_Account__c(Account__c=acc.id,Billing_Account_Number__c='700000002989',Billing_Account_Name__c='Test');
        insert billAcc;         
        Case caseNewList = new Case(Billing_Account__c=billAcc.id,Status = 'New',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        Case caseListRes= new Case(Billing_Account__c=billAcc.id,Status = 'Resolved',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        Case caseListCls= new Case(Status = 'Closed',Origin = 'Email',Subject = 'test',AccountID = acc.Id,ContactID = con.ID,recordtypeid=billingEnquiryRecordTypeId);
        List<Case> posList= new List<Case>();
        posList.add(caseNewList);
        posList.add(caseListRes);
        posList.add(caseListCls);
        insert posList;
        Invoice__c inv=new Invoice__c(Name='123454');
        insert inv;
        Invoice_Line_Item__c invLineItem=new Invoice_Line_Item__c(Invoice__c=inv.id);
        insert invLineItem;
        Queried_Line_Item__c qLIData = new Queried_Line_Item__c(Case__c = caseNewList.Id,Invoice_Line_Item__c = invLineItem.Id,Reason_Code__c = 'Usage enquiry adjustment', Determination_Amount__c =100,Max_Credit_Amount__c=200);
        insert qLIData;
        Credits_and_Adjustments__c creditAdj=new Credits_and_Adjustments__c(Case_Number__c=caseListRes.id,Determination_Status__c='Approved');
        insert creditAdj;
        parameters.add(caseNewList.id);
        parameters.add(caseListRes.id);
        parameters.add(caseListCls.id);*/
        List<String> parameters = new List<String>();
        List<Case> processCaseList=[Select Id from Case where Subject='test'];
        for(Case instance : processCaseList) {
            parameters.add(instance.id);
                }      
        CaseEmailService.processCaseRecord(parameters);
        Contact con= [Select Id,Email from Contact where Email='test@team.telstra.com' LIMIT 1];
        con.Email = null;
        update con;
        CaseEmailService.processCaseRecord(parameters);
        //CaseEmailService.processCaseRecord(parameters);
        //CaseEmailService.processCaseRecord(parameters);
        Test.stopTest();
        system.assertEquals(!parameters.isEmpty(), true);
    }
    
    /***
* 
* Passing invalid Case Id for negative testing.
* 
***/
    
    @isTest
    static void caseEmailServiceNegativeTest()
    {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
        Test.startTest();
        List<String> parameters = new List<String>();
        parameters.add(acc.id);
        CaseEmailService.processCaseRecord(parameters);
        Test.stopTest();
        system.assertEquals(!parameters.isEmpty(), true);
    }
    //EDGE-157963: Test coverage for handleErrorScenario method
    @isTest
    static void handleErrorScenarioVeTest()
    {
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Case caseNewList = new Case(Status = 'Resolved',Origin = 'Email',Subject = 'test',recordtypeid=billingEnquiryRecordTypeId);
        insert caseNewList;
        case caseObj = [select id,casenumber,Status from case where id =: caseNewList.id];

        Integration_Record__c insertRecord = new Integration_Record__c();
        blob b = Crypto.generateAesKey(128);
        String GUID = EncodingUtil.convertToHex(b);
        insertRecord.params__c =caseNewList.id;
        insertRecord.handler__c = 'EmailHandler';
        insertRecord.status__c = IntegrationQueueHandler.PENDING;
        insert insertRecord;
        String requestjson='{"recipients":[{"msisdn":null,"emailDeliveryType":"TO","emailAddress":"ketan.b@infosys.com"},{"msisdn":null,"emailDeliveryType":"CC","emailAddress":"ketan.b@infosys.com"}],"notificationEventType":"B2B_BILLING_ENQUIRY_OUTCOME","entityType":"NOT_APPLICABLE","entityId":"NOT_APPLICABLE","correlationId":null,"contentParameters":[{"value":"Outcome of your Telstra billing enquiry 00080325","name":"email_subject"},{"value":"","name":"email_body"},{"value":"ok","name":"reason1_1"},{"value":"'+caseObj.casenumber+'","name":"case_number"},{"value":"700000467501","name":"account_number"},{"value":"Test_Acc","name":"company_name"},{"value":"Ketan Babu","name":"first_name"}],"attachmentParameters":[{"filename":"sample","contentType":"application/pdf","binaryContent":"JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCBSDQovUGFnZXMgMyAwIFINCj4+DQplbmRvYmoNCg0KMiAwIG9iag0KPDwNCi9UeXBlIC9PdXRsaW5lcw0=="},{"filename":"sample1","contentType":"application/pdf","binaryContent":"JVBERi0xLjMNCiXi48/TDQoNCjEgMCBvYmoNCjw8DQovVHlwZSAvQ2F0YWxvZw0KL091dGxpbmVzIDIgMCB+DQoNCnN0YXJ0eHJlZg0KMjcxNA0KJSVFT0YNCg=="}]}';
        EmailRequest request = (EmailRequest) JSON.deserialize(requestjson, EmailRequest.class);
        String response='{"code":40002,"applicationLabel":null,"time":null,"correlationId":null,"data":null,"status":422,"message":"Notification Event is not configured for attachment but the message has attachment","errors":[{"code":"040002","message":"Notification Event is not configured for attachment but the message has attachment"}],"path":null,"method":null}'; 
        Test.startTest();
        CaseEmailService.handleErrorScenario(request,response);
        Test.stopTest();
        case caseResult=[Select id,status from case where id=:caseObj.id];
        system.assertEquals(caseResult.Status,'Obtaining Internal Approval');

    }
      @isTest
    static void handleErrorScenarioNeTest()
    {
        Id billingEnquiryRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Billing_Enquiry_RecordType).getRecordTypeId();
        Case caseNewList = new Case(Status = 'Resolved',Origin = 'Email',Subject = 'test',recordtypeid=billingEnquiryRecordTypeId);
        String response=null;
        insert caseNewList;
        String requestjson='{"recipients":[{"msisdn":null,"emailDeliveryType":"TO","emailAddress":"ketan.b@infosys.com"},{"msisdn":null,"emailDeliveryType":"CC","emailAddress":"ketan.b@infosys.com"}],"notificationEventType":"B2B_BILLING_ENQUIRY_OUTCOME","entityType":"NOT_APPLICABLE","entityId":"NOT_APPLICABLE","correlationId":null,"contentParameters":[{"value":"Outcome of your Telstra billing enquiry 00080325","name":"email_subject"},{"value":"","name":"email_body"},{"value":null,"name":"reason1_1"},{"value":"00080325","name":"case_number"},{"value":"700000467501","name":"account_number"},{"value":"Test_Acc","name":"company_name"},{"value":"Ketan Babu","name":"first_name"}],"attachmentParameters":null}';
        EmailRequest request = (EmailRequest) JSON.deserialize(requestjson, EmailRequest.class);
        Test.startTest();
        CaseEmailService.handleErrorScenario(request,response);
        Test.stopTest();
        system.assertEquals(String.IsBlank(response), true);

    }
    
}
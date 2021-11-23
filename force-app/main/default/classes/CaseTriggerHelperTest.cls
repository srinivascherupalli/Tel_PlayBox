/*****************************************************************************
@Author: Sandeep
@CreateDate: 27/03/2019
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage of CaseTriggerHelper
CaseTriggerHelper = 75%
******************************************************************************
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.         Shubhi                   02-06-2021       EDGE-216407 /DIGI-13373  
2.         Shubhi                   13-9-2021        fdr test class fix
====================================================================================================================*/
@isTest
public class CaseTriggerHelperTest {
    
    public static String recId_SalesChildSupport= Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public static String recId_BulkRecChannelCare= workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_Bulk_Request').getRecordTypeId();
    
    /**
      * This method is used to create the cases as required in the test methods.
      * @Author: Chandrakant
      * @Date: 08-Aug-2020
      */
    @testSetup public static void DataSetup() {
        
        //P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
        List<Account> AccountList=new List<Account>();
        Account customerAccount=TestUtil.createAccount('Testacc');
        AccountList.add(customerAccount);
        Account accountData=TestUtil.createAccount('Testacc1');
        AccountList.add(accountData);
        insert AccountList;
        
        Integer NumberOfCases = 5;
        Integer NumberOfWorkOrders =5;
        List<Case> CasesOfService = new List<Case>();
        List<WorkOrder> WODetails = new List<WorkOrder>();
        Case caseObj = null;
        for(Integer i=0;i<NumberOfCases;i++){
            caseObj = new Case();
            caseObj.subject = 'Test Case Record '+i;
            caseObj.Status = 'New';
            caseObj.soc_SFD_Offshore_Restricted__c =true;
            caseObj.description = 'Test Case description';
            caseObj.salesup_No_of_sites_or_services__c= 35;
            caseObj.AccountId=customerAccount.id;//P2OB-6277 : Account mandatory for channel care cases removed UI layout validation and kept validation rule
            caseObj.RecordTypeId = recId_SalesChildSupport;
            CasesOfService.add(caseObj);
        }
        //added by shubhi for Edge-216407
        Id recIdBillingEnquiry = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId(); 
        test.startTest();
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.email='abc@gmail.com';
        insert contactData;
            Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        insert billingAccountData;
        Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,
        RecordTypeId = recIdBillingEnquiry,Billing_Account__c = billingAccountData.Id);
        caseData.AccountId = accountData.Id;
        caseData.ContactId = contactData.Id;
        caseData.Type      = System.Label.Case_Type;
        CasesOfService.add(caseData); 

        insert CasesOfService;
        test.stopTest();
        for(Integer i=0;i<NumberOfWorkOrders;i++){
        WorkOrder woObj = new WorkOrder();
        woObj.Status = 'New';
        woObj.description = 'Test Case description'+i;
        woObj.cusdl_work_order_type__c = 'Commercial';
        woObj.CaseId = caseObj.Id;
        woObj.RecordTypeId = workorder.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Channel_Care_Bulk_Request').getRecordTypeId();    
        WODetails.add(woObj);
        }
        insert WODetails;
    
        //added by Shubhi for EDGE-216407 start 
        Profile pf = [select id from profile where name ='Assurance Service Agent'];
        Profile pf_bill = [select id from profile where name ='Billing Consultant'];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        List<User> userList=new List<User>();
        User agent= new User(alias = 'agent',email='agentuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='agent', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf.id,
                                      timezonesidkey='Australia/Sydney',
                                      username=uniquename+'agentuser@testagent.com',phone='+121231231234');
        userList.add(agent);
    
        User billConsultant= new User(alias = 'bill',email='billUser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='user', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf_bill.id,
                                      timezonesidkey='Australia/Sydney',
                                      username=uniquename+'billUser@testagent.com',phone='+121231231234');
        userList.add(billConsultant);
        insert userList;
    
        String json = '{"customerAddress":{"companyName":"MLC Company Ltd.","addressLine1":"Unit 1 1234 Lostmy Way","addressCity":"Sydney","stateAndPostalCode":"NSW 2000"},"invoiceDetails":{"accountNumber":"700000002978","invoiceNumber":"9900000202350","invoiceIssueDate":"24 Jul 19","invoicePeriod":"01 Mar 19 - 31 Mar 19","ariaInvoiceNumber":"148512498"},"paymentSummary":{"balanceCarriedForward":-603.02,"totalDue":298.98,"paymentsAndAdjustments":603.02,"dueDate":"07 Aug 19","newCharges":902},"serviceSummary":{"listOfOffers":[{"offerName":"Connected Workplace","offerTotalExcludingGstCost":590,"offerTotalIncludingGstCost":902,"invoiceDef":1,"listOfProducts":[{"physicalLocationName":"400 George St Sydney NSW","siteExcludingGstCost":590,"siteIncludingGstCost":902,"listOfChargesAndCredits":{"planCharges":[{"serviceType":"Bandwidth Bolt On","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4261,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":5,"invoiceTransactionId":197352167,"chargeExcludingGST":50,"chargeIncludingGST":55}]},{"serviceType":"Apple iPhone 8 64GB Monthly Repayment Charge","quantity":2,"excludingGstCost":110,"includingGstCost":110,"sigmaSpecId":"BSRO001_CB","isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4274,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":7,"invoiceTransactionId":197352169,"chargeExcludingGST":55,"chargeIncludingGST":55},{"invoiceLineNumber":6,"invoiceTransactionId":197352168,"chargeExcludingGST":55,"chargeIncludingGST":55}],"drillDownInputAttribute":{"statementNumber":"9900000202350","chargeId":4274},"drillDownEndpoint":"Repayment details"},{"serviceType":"Fixed Seat (Zone 1)","quantity":1,"excludingGstCost":50,"includingGstCost":55,"sigmaSpecId":"BSRC001_CB","startDate":"01 Apr","endDate":"30 Apr","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4260,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":8,"invoiceTransactionId":197352170,"chargeExcludingGST":50,"chargeIncludingGST":55}]}],"onceOffChargesAndCredits":[{"serviceType":"Jabra Stealth UC","quantity":1,"excludingGstCost":30,"includingGstCost":33,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4269,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":11,"invoiceTransactionId":197352173,"chargeExcludingGST":30,"chargeIncludingGST":33}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":35,"includingGstCost":38.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4268,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":12,"invoiceTransactionId":197352174,"chargeExcludingGST":35,"chargeIncludingGST":38.5}]},{"serviceType":"Polaris Soundpro Touch 790","quantity":1,"excludingGstCost":135,"includingGstCost":148.5,"sigmaSpecId":"BSOTC001_CB","isAggregated":false,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4267,"chargeType":"OnceOffCharge","disputeAttributes":[{"invoiceLineNumber":13,"invoiceTransactionId":197352175,"chargeExcludingGST":135,"chargeIncludingGST":148.5}]},{"serviceType":"Polaris Soundpro SW10ND","quantity":3,"excludingGstCost":420,"includingGstCost":462,"sigmaSpecId":"BSOTC001_CB","isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":true,"chargeIdentifier":4275,"chargeType":"RecurringCharge","disputeAttributes":[{"invoiceLineNumber":14,"invoiceTransactionId":197352176,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":10,"invoiceTransactionId":197352172,"chargeExcludingGST":140,"chargeIncludingGST":154},{"invoiceLineNumber":9,"invoiceTransactionId":197352171,"chargeExcludingGST":140,"chargeIncludingGST":154}]},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":2400,"includingGstCost":2640,"isAggregated":true,"isTaxable":true,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4277,"chargeType":"OnceOffCharge"},{"serviceType":"Apple iPhone 8 64GB","quantity":2,"excludingGstCost":-2640,"includingGstCost":-2640,"isAggregated":true,"isTaxable":false,"isQueryable":true,"isDisputable":false,"chargeIdentifier":4276,"chargeType":"CreditCharge"}]}}]}],"accountLevelChargesAndCredits":{"adjustmentsExcludingGstCost":0,"adjustmentsIncludingGstCost":0,"grossTotalBill":902,"amountOfGstIncludedInGrossTotalBill":312,"totalNewChargesInThisBill":902,"gstFreeItemsIncludedInNewCharges":110,"gstIncludedInNewCharges":312,"adjustmentsTotal":-603.02,"gstIncludedInAdjustments":-54.82}},"adjustmentSummary":{"totalAdjustmentsCost":-603.02,"totalGSTIncludedInAdjustments":-54.82,"adjustments":[{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.38,"gstIncludedInAdjustments":-13.67,"isQueryable":true,"isDisputable":false,"chargeIdentifier":80,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":78,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":true,"isDisputable":false,"chargeIdentifier":79,"chargeType":"CreditCharge"},{"adjustmentDescription":"Compensation Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-150.66,"gstIncludedInAdjustments":-13.7,"isQueryable":true,"isDisputable":false,"chargeIdentifier":77,"chargeType":"CreditCharge"},{"adjustmentDescription":"Goodwill Credit","adjustmentDate":"24 Jul 19","adjustmentsCost":-100.66,"gstIncludedInAdjustments":-9.15,"isQueryable":false,"isDisputable":false,"chargeIdentifier":76,"chargeType":"CreditCharge"}]}}';
        InvoiceResponseDTO obj = InvoiceResponseDTO.parse(json);
        Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
        insert invdata;
        Invoice_Line_Item__c ILI=new Invoice_Line_Item__c(
          Invoice__c=invdata.id,
          Invoice_Line_Number__c=13432233, 
          Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',
          Invoice_Transaction_ID__c=26022460,
          Line_Item_Identifier__c='43242342',
          charge_identifier__c=12453);
        insert ILI;
        List<Queried_Line_Item__c> qlilist=new List<Queried_Line_Item__c>();
        Queried_Line_Item__c sobj = new Queried_Line_Item__c(
          Queried_Amount__c = 34.99,                      // Queried Amount (ex GST)
          Line_Item_Identifier__c = 'RecurringCharge100',  // Line Item Identifier
          Case__c = caseData.id,                    // Case
          Invoice_Line_Item__c = ILI.id                   // Invoice Line Item 
        );
        qlilist.add(sobj);
        insert qlilist;
        //EDGE-216407
        EnvironmentVariable__c featureToggle=new EnvironmentVariable__c();
        featureToggle.name='enableBillingEnquiry1663';
        featureToggle.value__c='true';
        insert featureToggle;

        SharedDisplayMessage__c custset= new SharedDisplayMessage__c();
        custset.Name='case ms validation';
        custset.value__c='Case cannot be progressed to next stage until all queried line items are populated with unique ids';
        insert custSet;


        //added by Shubhi for EDGE-216407 end  

       
    }
    
    static testMethod void runAssignmentRuleTest(){
        Case caseObj = new Case();
        caseObj.subject = 'Test Case Record';
        caseObj.Status = 'New';
        caseObj.description = 'Test Case description';
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Management').getRecordTypeId();    
        
        test.StartTest();
        insert caseObj;
        test.StopTest();             
        Case ca = [SELECT ID, OwnerId FROM Case where id=:caseObj.id];
        //validate case owner has been update or not.
        System.assert(ca.OwnerId==UserInfo.getUserId());
    }
    
      /*
    Team Melbourne, Chandrakant :: sprint 20.11, P2OB-5217  
    Testmethod to cover checkBulkCaseTypeSelected method
    Main class is CaseTriggerHelper
    */
    static testMethod void checkBulkCaseTypeSelectedTest(){
        
        test.StartTest();
        Integer NumberOfCases = 20;
        String errorMsg = Label.BulkCaseTypeRequiredError;
        List<Case> CasesOfService = [SELECT Id,salesup_isBulkApproved__c FROM Case LIMIT :NumberOfCases];
        try{
            for(Case CaseOfService: CasesOfService){
                CaseOfService.salesup_isBulkApproved__c = true;
            }
            update CasesOfService;
        }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(errorMsg),TRUE);
        }
        test.StopTest();
    }
    
    /*
    Team Jaipur, Chandrakant :: sprint 21.08, P2OB-13762
    Testmethod to cover setAdditionalSkillSetNewRecord method
    Main class is CaseTriggerHelper
    */
    static testMethod void setAdditionalSkillSetRecordTest(){
        
        test.startTest();
            Account customerAccount=TestUtil.createAccount('Testacc');
            insert customerAccount;   
            Group ebQueue = [select id,developername from group where developername='Pending_Einstein_Processing_Do_not_use']; 
            List<Case> CasesOfService = new List<Case>();
            Case caseObj = null;
            for(Integer i=0;i<5;i++){
                caseObj = new Case();
                caseObj.subject = 'Test Case Record '+i;
                caseObj.Status = 'New';
                caseObj.ss_Type__c = 'Billing';
                caseObj.description = 'Test Case description';
                caseObj.AccountId=customerAccount.id;
                caseObj.RecordTypeId = recId_SalesChildSupport;
                CasesOfService.add(caseObj);
            }
            insert CasesOfService;

            List<Case> newCase = [SELECT Id,cpe_CPE_Skills_Set__c,ss_Type__c,status,soc_SFD_Offshore_Restricted__c FROM Case where ss_Type__c='Billing' LIMIT 5];
            System.assertEquals(newCase[0].cpe_CPE_Skills_Set__c,'Billing Consenting');
        
            List<Case> updatedCasesOfService = new List<Case>();
            for(Case cs : newCase){
                cs.ownerId = ebQueue.id;
                cs.soc_SFD_Offshore_Restricted__c = true;
                updatedCasesOfService.add(cs);
            }
            update updatedCasesOfService;
            List<Case> updatedCase = [SELECT Id,cpe_CPE_Skills_Set__c,soc_SFD_Offshore_Restricted__c,ss_Type__c,status FROM Case where ss_Type__c='Billing' LIMIT 5];
            
            System.assertEquals(updatedCase[0].cpe_CPE_Skills_Set__c,'Billing Non-Consenting');
        test.stopTest();
    }

    /*
    Team Melbourne, Chandrakant :: sprint 20.11, P2OB-13762
    Testmethod to cover handleDefaultCaseSkill method
    Main class is CaseTriggerHelper
    */
    static testMethod void handleDefaultCaseSkillTest(){
        
        test.StartTest();
        Integer NumberOfCases = 5;
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c FROM Case LIMIT :NumberOfCases];
        Group gr = [select Id,developername from Group where Type = 'Queue' AND developername ='eb_Enterprise_Billing'];
        Group newGroupId = [select Id,developername from Group where Type = 'Queue' AND developername ='Enterprise_Billing_WFC_Consenting'];
        
        for(Case CaseOfService: CasesOfService){
            CaseOfService.OwnerId = gr.Id;
        }
        update CasesOfService;
        
        List<Case> upCasesOfService = [SELECT Id,OwnerId FROM Case LIMIT 1];
        System.assertEquals(upCasesOfService[0].OwnerId,newGroupId.Id);
        
        test.StopTest();
    }    
   
    /*
    Team Jaipur, Mofit :: sprint 21.08, P2OB-14367
    Testmethod to cover handleDefaultCaseSkill method for CPE case
    Main class is CaseTriggerHelper
    */
    static testMethod void handleDefaultCaseSkillCPETest(){
        
        test.StartTest();
        Integer NumberOfCases = 5;
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c FROM Case LIMIT :NumberOfCases];
        Group gr = [select Id,developername from Group where Type = 'Queue' AND developername ='cpe_Ordering_Hardware'];
        Group newGroupId = [select Id,developername from Group where Type = 'Queue' AND developername ='cpe_Telstra_Purple_WF_Coordinator'];
        
        for(Case CaseOfService: CasesOfService){
            CaseOfService.salesup_Support_Type__c = 'CPE Hardware And Services';
            CaseOfService.OwnerId = gr.Id;
        }
        update CasesOfService;
        
        List<Case> upCasesOfService = [SELECT Id,OwnerId FROM Case LIMIT 1];
        System.assertEquals(upCasesOfService[0].OwnerId,newGroupId.Id);
        
        test.StopTest();
    }    
    
    /*
    Team Jaipur, Mofit :: sprint 21.08, P2OB-14367
    Testmethod to cover handleDefaultCaseSkill method for CPE case
    Main class is CaseTriggerHelper
    */
    static testMethod void handleDefaultCaseSkillMobileTest(){
        
        test.StartTest();
        Integer NumberOfCases = 5;
        List<Case> CasesOfService = [SELECT Id,OwnerId,soc_SFD_Offshore_Restricted__c FROM Case LIMIT :NumberOfCases];
        Group gr = [select Id,developername from Group where Type = 'Queue' AND developername ='mm_Enterprise_Mobile_Support_Queue'];
        Group newGroupId = [select Id,developername from Group where Type = 'Queue' AND developername ='mm_customer_request_queue'];
        
        for(Case CaseOfService: CasesOfService){
            CaseOfService.salesup_Support_Type__c = 'Mobile Support Requests';
            CaseOfService.OwnerId = gr.Id;
        }
        update CasesOfService;
        
        List<Case> upCasesOfService = [SELECT Id,OwnerId FROM Case LIMIT 1];
        System.assertEquals(upCasesOfService[0].OwnerId,newGroupId.Id);
        
        test.StopTest();
    }    
    
    /*
    Team Melbourne, Chandrakant :: sprint 20.11, P2OB-5217  
    Testmethod to cover negative scenario checkBulkCaseTypeSelected method
    Main class is CaseTriggerHelper
    */
    static testMethod void checkBulkCaseTypeSelectedTest_negative(){
        
        test.StartTest();
        Integer NumberOfCases = 20;
        String errorMsg = Label.BulkCaseTypeRequiredError;
        List<Case> CasesOfService = [SELECT Id,salesup_isBulkApproved__c FROM Case LIMIT :NumberOfCases];
        try{
            for(Case CaseOfService: CasesOfService){
                CaseOfService.salesup_Bulk_Case_Type__c = 'Complex';
                CaseOfService.salesup_isBulkApproved__c = true;
            }
            update CasesOfService;
        }
        //To cover Add error method in handler
        catch(DMLException Ex){
            Boolean expectedExceptionThrown =  (Ex.getMessage().contains((errorMsg) )) ? true : false; 
            System.assertEquals(expectedExceptionThrown,false);
            }
        
        test.StopTest();
    }
    /*
    Melbourne :: Sanjay Thakur
    Sprint & US: 20.11 & P2OB-8345
    Testmethod to cover checkWorkOrderStatus method
    Main class is CaseTriggerHelper
     */    
    static testMethod void checkWorkOrderStatusTestPositive(){
        test.StartTest();
        Integer NumberOfCases = 20;
        Integer NumberOfWorkOrder = 20;
        String errorMsg = Label.OpenWorkOrderError;
        List<Case> CasesOfService = [SELECT Id,Status FROM Case LIMIT :NumberOfCases];
        List<WorkOrder> WoRecord = [SELECT id,Status,Case.Status from workorder where CaseId IN:CasesOfService LIMIT :NumberOfWorkOrder];
        try{
            for(workorder WORec: WoRecord){
                WORec.Case.Status = 'Closed';
                WORec.Status = 'New';
            }
            update WoRecord;
        }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(errorMsg),TRUE);
        }
        test.StopTest();
    }
   /*
    Melbourne :: Sanjay Thakur
    Sprint & US: 20.11 & P2OB-8345
    Testmethod to cover Negative Scenario of checkWorkOrderStatus method
    Main class is CaseTriggerHelper
     */    
    static testMethod void checkWorkOrderStatusTestNegative(){
        test.StartTest();
        Integer NumberOfCases = 20;
        Integer NumberOfWorkOrder = 20;
        String errorMsg = Label.OpenWorkOrderError;
        List<Case> CasesOfService = [SELECT Id,Status FROM Case LIMIT :NumberOfCases];
        List<WorkOrder> WoRecord = [SELECT id,Status,Case.Status from workorder where CaseId IN:CasesOfService LIMIT :NumberOfWorkOrder];
        try{
            for(workorder WORec: WoRecord){
                WORec.Case.Status = 'Closed';
                WORec.Status = 'Closed';
            }
            update WoRecord;
        }
        //To cover Add error method in handler
        catch(DMLException Ex){
            System.assertEquals(Ex.getMessage().contains(errorMsg),TRUE);
        }
        test.StopTest();
    }
       /*
    Melbourne :: Chandrakant Wani
    Sprint & US: 20.15 & P2OB-10425
    Testmethod to cover Negative Scenario of updateCaseSlaMilestone method
    Main class is CaseTriggerHelper
     */    
    static testMethod void updateCaseSlaMilestoneTest(){
        
        test.StartTest();
        
        Account customerAccount=TestUtil.createAccount('Testacc');
        insert customerAccount;
        Entitlement ent = new entitlement(name = 'Channel Care Case SLAs', AccountId = customerAccount.Id);
        insert ent;
        
        Case caseObj = new Case();
        caseObj.subject = 'Test Case Record';
        caseObj.Status = 'New';
        caseObj.description = 'Test Case description';
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        caseObj.EntitlementId = ent.Id;   //P2OB-10425: Entitlemnet record assigned to new case
        caseObj.srvsup_Categories__c = 'Billing';
        caseObj.salesup_Work_Required__c = 'Invalid Charges';
        caseObj.AccountId=customerAccount.id;
        insert caseObj;
        
        //update Case status to Close
        caseObj.status = 'Closed';
        update caseObj;
        
        test.StopTest();
        
        Case ca = [SELECT ID, status FROM Case where id=:caseObj.id];
        //validate case status has been updated or not.
        System.assert(ca.status=='Closed');
    }
    
    /*
    Jaipur :: Pravin
    Sprint & US: 21.06 & P2OB-14113
    Testmethod to cover Scenario of adding case Owner as Case Team Member with R access
    Main class is CaseTriggerHelper
     */    
    static testMethod void addRequestorAsCaseTeamMemberTest(){
        
        Account customerAccount=TestUtil.createAccount('Testacc');
        insert customerAccount;
        
        test.StartTest();
        
        Case caseObj = new Case();
        caseObj.subject = 'Test Case Record';
        caseObj.Status = 'New';
        caseObj.description = 'Test Case description';
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
        caseObj.ss_Type__c = 'Reports';
        caseObj.ss_Category__c = 'Request a Flexcab 130 or 140 Report';
        caseObj.ss_Work_Required__c = 'Flexcab 130/140 Report';
        caseObj.AccountId=customerAccount.id;
        caseObj.salesup_Routing_Enabled__c = true;
        insert caseObj;
        system.assert(caseObj.Id != null);
        system.debug('caseObj=='+caseObj);
        
        test.stopTest();
        
        Id roleId = [select Id from CaseTeamRole where Name = 'SOC Case View Access' limit 1].Id;
        List<CaseTeamMember> lstCTM = [Select Id,MemberId,ParentId,TeamRoleId From CaseTeamMember Where ParentId = :caseObj.Id LIMIT 1];
        system.assert(lstCTM != null);
        system.assertEquals(lstCTM[0].ParentId, caseObj.Id);
        system.assertEquals(lstCTM[0].TeamRoleId, roleId);
    }

    //Added By Shubhi for EDGE-216407  starts 
  
  @isTest static void CaseNonAssitedPositive() {
    Test.startTest();
    String invoiceNumber = '1232';
        String errorMsg='Case cannot be progressed to next stage until all queried line items are populated with unique ids';
        Id recIdBillingEnquiry = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId(); 
        Case caseData=[Select id,status from case where recordTypeId= :recIdBillingEnquiry limit 1];
        User sales = [select name,id, lastname from  User where email='billUser@testsales.com' limit 1 ];
        try{
            caseData.status='Closed';
            update caseData;
        }catch(DMLException Ex){
            system.debug('error -->'+Ex.getMessage());
            System.assert(Ex.getMessage().contains((errorMsg)));
        }
    Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c];
        System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    Test.stopTest();
  }

  @isTest static void CaseNonAssitedNegative() {
    Test.startTest();
    String invoiceNumber = '1232';
        String errorMsg='Case cannot be progressed to next stage until all queried line items are populated with unique ids';
        Id recIdBillingEnquiry = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Billing_Enquiry').getRecordTypeId(); 
        Case caseData=[Select id from case where recordTypeId != :recIdBillingEnquiry limit 1];
    User sales = [select name,id, lastname from  User where email='billUser@testsales.com' limit 1 ];
    System.runAS(sales){
      try{
                caseData.status='Closed';
                update caseData;
                case updatedcasedata=[select id,status from case where id=:caseData.id];
                System.assert(updatedcasedata.status=='Closed');

            }catch(DMLException Ex){
                System.assert(Ex.getMessage().contains((errorMsg))==false);
            }
    }
    Test.stopTest();
  }
  //Added By Shubhi for  EDGE-216407  ends
}
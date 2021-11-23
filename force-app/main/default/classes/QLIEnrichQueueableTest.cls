/*******************************************************************************************************************
Class Name : EnqueueCaseQLITest
Description :  When ever user clicks on Invoice Callout quick action in case it will enqueue the job with caseId and set of invoices.
====================================================================================================================
Sr.No.    Developer Name               Date          Story Description
1.        Shubhi V                  10/05/2021       Edge-212404(new created)
2.        Vamsi Krishna Vaddipalli    02/06/2021       Edge-219120
2.         Shubhi                  02-06-2021       EDGE-216407
====================================================================================================================
********************************************************************************************************************/
@isTest
public class QLIEnrichQueueableTest{

  @testSetup static void setup(){
    
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
    Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
    Account accountData = TestDataFactory.generateAccount();
    Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
    contactData.email='abc@gmail.com';
    insert contactData;
    Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
    insert billingAccountData;
    Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
    caseData.AccountId = accountData.Id;
    caseData.ContactId = contactData.Id;
    caseData.Type      = System.Label.Case_Type;
    insert caseData;        
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

    
  }

  @isTest static void testPositiveQLIEnrichQueueable() {
    Test.startTest();
    String invoiceNumber = '1232';
        Case caseData=[Select id from case limit 1];
    User sales = [select name,id, lastname from  User where email='agentuser@testsales.com' limit 1 ];
    System.runAS(sales){
      System.enqueueJob(new QLIEnrichQueueable(''+caseData.id,'1232'));
    }
    Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c];
    System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    Test.stopTest();
  }

  @isTest static void testNositiveQLIEnrichQueueable() {
    Test.startTest();
    String invoiceNumber = '1232';
        Case caseData=[Select id from case limit 1];
    User sales = [select name,id, lastname from  User where email='agentuser@testsales.com' limit 1 ];
    System.runAS(sales){
      System.enqueueJob(new QLIEnrichQueueable(''+caseData.id,'1232'));
    }
    Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c];
    System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    Test.stopTest();
  }
    
    //Added By Vamsi for EDGE-219120 on 03JUN2021 starts 
  @isTest static void testenqueueQLI()
    {
        Case caseData=[Select id from case limit 1];
        List<Invoice__c> invoiceNum = [SELECT Name FROM Invoice__c];
        Set<String> invoiceSet = new Set<String>();
        for(Invoice__c obj:invoiceNum)
            invoiceSet.add(obj.Name);
        
        System.enqueueJob(new QLIEnrichQueueable(''+caseData.id,invoiceSet));
        Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c LIMIT 1];
        System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    }
  //Added By Vamsi for EDGE-219120 on 03JUN2021 ends


    //Added By Shubhi for EDGE-216407  starts 
  
  @isTest static void QLIQueueableNonAssitedPositive() {
    Test.startTest();
    String invoiceNumber = '1232';
        Case caseData=[Select id from case limit 1];
    Map<String,Set<String>> caseToInvoicenumListMap=new Map<String,Set<String>>();
        for(Queried_Line_Item__c qli:[SELECT Id,Case__r.Billing_Account__r.Billing_Account_Number__c,Invoice_Line_Item__r.Invoice__r.Aria_Invoice_Number__c,Invoice_Line_Item__r.Charge_Identifier__c,Invoice_Line_Item__r.Charge_Type__c,Invoice_Line_Item__r.Invoice_Line_Number__c ,Invoice_Line_Item__r.Invoice__r.name,processedByMS__c
        FROM Queried_Line_Item__c WHERE  Case__c = : caseData.id]){
            if(qli.processedByMS__c!=1){
                Set<String> invoiceNumSet=new Set<String>();
                if(caseToInvoicenumListMap!=null && caseToInvoicenumListMap.containskey(qli.Case__c)){
                    invoiceNumSet.addAll(caseToInvoicenumListMap.get(qli.Case__c));
                }
                invoiceNumSet.add(qli.Invoice_Line_Item__r.Invoice__r.name);
                caseToInvoicenumListMap.put(qli.Case__c,invoiceNumSet);
            }
        }
    User sales = [select name,id, lastname from  User where email='billUser@testsales.com' limit 1 ];
    System.runAS(sales){
      System.enqueueJob(new QLIEnrichQueueable(caseToInvoicenumListMap));
    }
    Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c];
        System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    Test.stopTest();
  }

  @isTest static void QLIQueueableNonAssitedNegative() {
    Test.startTest();
    String invoiceNumber = '1232';
    Map<String,Set<String>> caseToInvoicenumListMap=new Map<String,Set<String>>();
    User sales = [select name,id, lastname from  User where email='billUser@testsales.com' limit 1 ];
    System.runAS(sales){
      System.enqueueJob(new QLIEnrichQueueable(caseToInvoicenumListMap));
    }
    Invoice_Line_Item__c ILI=[Select id,Invoice__r.Aria_Invoice_Number__c from Invoice_Line_Item__c];
        System.assert(ILI.Invoice__r.Aria_Invoice_Number__c=='1232');
    Test.stopTest();
  }
  //Added By Shubhi for  EDGE-216407  ends
}
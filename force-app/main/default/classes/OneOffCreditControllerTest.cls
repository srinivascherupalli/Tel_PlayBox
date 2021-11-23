/*------------------------------------------------------------------------ 
Author: Mahima Gandhe 
Company: Telstra 
Description: A test class created to validate the OneOffCreditComponent
Tests executed: 
1 - SaveCreditAdjustmentRec_Test() 
Submits the form and get successfull creation of Credits_And_Adjustments__c record and initials API callout.
2 - updateCaseDetails_Test() 
Update the Case and Credits_And_Adjustments__c data after success and failure response.

History 
<16-04-2019> <Mahima Gandhe> <EDGE-64232>  
----------------------------------------------------------------------------*/

@isTest
private class OneOffCreditControllerTest {
    
    private static  Account acc=null;
    private static  Case cs=null;
        private static  Case cs2=null;
    private static Non_Marketable_Product__c nmp= null;
    
    
    /*------------------------------------------------------------ 
    Metohd: createAccount
    Description: method to create account as test data
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    private static void createAccount(String name, String cidn){
        acc = new Account(Name = name,CIDN__c=cidn);        
        insert acc;
    }
    
    /*------------------------------------------------------------ 
    Metohd: createCase
    Description: method to create case as test data
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    private static void createCase(String accId){
        Id stExam = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing Credit or Debit Adjustment').getRecordTypeId();
        cs = new Case(accountId=accId);
        cs.Status='New';
        cs.RecordTypeId= stExam;
        cs.Description='test class';
        // cs.Sub_Type__c='General';
        insert cs;
        
        cs2 = new Case(accountId=accId);
        cs2.Status='New';
        cs2.RecordTypeId= stExam;
        cs2.Description='test class';
        // cs.Sub_Type__c='General';
        insert cs2;
        
    }
    
    /*------------------------------------------------------------ 
    Metohd: createnonMarkprod
    Description: method to create Non_Marketable_Product__c as test data
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    private static void createnonMarkprod(){
        nmp = new Non_Marketable_Product__c(currency__c='AUD',specId__c='prod-1234',productDescription__c='test',taxTreatment__c='GST Applicable');
        
        insert nmp;
        
    }
    
    /*------------------------------------------------------------ 
    Metohd: SaveCreditAdjustmentRec_Test
    Description: Test method for SaveCreditAdjustmentRec  and makeCallout
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    @isTest static void SaveCreditAdjustmentRec_Test()
    {
        createAccount('Testing account 1','121');
        createCase(acc.id);
        createnonMarkprod();
        Boolean isPredebt=true;
        Boolean isdebt=false;
        String caseRecord='Insolvency_Management';
        String caseNumber;
        Map<String, String> credAdj= new Map<string, string>();
        credAdj.put('Non_Marketable_Product__c',nmp.id);
        credAdj.put('Reason_Code__c','Compensation Credits – Telstra Issue');
        credAdj.put('Credit_Change_Amount__c','23');       
        credAdj.put('Date_when_credit_was_given_to_customer__c','2019-04-09T00:00:00.000Z');
        test.startTest();
        Credits_and_Adjustments__c credit= OneOffCreditController.SaveCreditAdjustmentRec(credAdj,cs.id, null);
        OneOffCreditController.makeCallout(credit,isPredebt,caseRecord,caseNumber);
        Map<string, string> result=OneOffCreditController.makeCallout(credit,isdebt,caseRecord,caseNumber);
        test.stopTest();
        System.assertEquals(credit.Credit_Change_Amount__c,23);
        
    }
    
    
    /*------------------------------------------------------------ 
    Metohd: updateCaseDetails_Test
    Description: Test method for updateCaseDetails
    History 
    <16-04-2019> <Mahima Gandhe>
    ------------------------------------------------------------*/
    @isTest static void updateCaseDetails_Test()
    {
        createAccount('Testing account 1','121');
        String caseRecord;
        createCase(acc.id);
        createnonMarkprod();
        String caseRecords;
        Map<String, String> credAdj= new Map<string, string>();
        credAdj.put('Non_Marketable_Product__c',nmp.id);
        credAdj.put('Reason_Code__c','Compensation Credits – Telstra Issue');
        credAdj.put('Credit_Change_Amount__c','23');
        //credAdj.put('Billing_Account_Number_BAN__c','a8z2O000000008PQAQ');
        credAdj.put('Date_when_credit_was_given_to_customer__c','2019-04-09T00:00:00.000Z');
        test.startTest();
        Credits_and_Adjustments__c credit= OneOffCreditController.SaveCreditAdjustmentRec(credAdj,cs.id, null);
        OneOffCreditController.updateCaseDetails(cs.id,credit.id,'',caseRecords);
        credAdj.put('Id',credit.id);
        Credits_and_Adjustments__c credit2= OneOffCreditController.SaveCreditAdjustmentRec(credAdj,cs2.id, null);        
        OneOffCreditController.updateCaseDetails(cs2.id,credit2.id,'Test failed',caseRecords);
        test.stopTest();
        List<Case> result=[select status from case where id=:cs.id];
        System.assertEquals(result[0].status,'Closed');
    }
        /*------------------------------------------------------------ 
    Metohd: checkPredebtAccountTest 
    Description: EDGE-149630:Code coverage for checkPredebtAccount
    Returns: return boolean value 
    ------------------------------------------------------------*/
    @isTest
       public static void checkPredebtAccountTest()
       {
    Account accountData = new Account();
        accountData.Customer_Status__c='ACTIVE'; 
        accountData.Name='Test';
        insert accountData;
        Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
        contactData.Authority__c='Full Authority';
        insert contactData;
        Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
        billingAccountData.PreDebt__c=true;
    insert billingAccountData;
    Test.startTest();
    Boolean result=OneOffCreditController.checkPredebtAccount(billingAccountData.id);
    Test.stopTest();
    System.assertEquals(result,true);
    }
    @isTest
       public static void checkPredebtAccountTestNegative()
       {
        String billingId='';
        Test.startTest();
        Boolean result=OneOffCreditController.checkPredebtAccount(billingId);
    Test.stopTest();
    System.assertEquals(result,false);
       }
        /*------------------------------------------------------------ 
    Metohd: getselectOptionsTest 
    Description: EDGE-149471:Code coverage for getselectOptions
    Returns: return List of String values 
    ------------------------------------------------------------*/ 
     @isTest
       public static void getselectOptionsTest()
       {
        Credits_and_Adjustments__c Obj=new Credits_and_Adjustments__c();
        String fieldname='Reason_Code__c';  
        Test.startTest();
        List<String> result=OneOffCreditController.getselectOptions(Obj,fieldname);
        Test.stopTest();
        System.assertEquals(result.contains('Insolvent Credit'),true);
       }
     /*------------------------------------------------------------ 
    Metohd: getselectOptionsTest 
    Description: EDGE-149471:Code coverage for getselectOptions
    Returns: return List of String values 
    ------------------------------------------------------------*/ 
    @isTest
       public static void getselectOptionsTestNegtive()
       {
        Credits_and_Adjustments__c Obj=new Credits_and_Adjustments__c();
        String fieldname='Reason_Code__c';
        Test.startTest();
        List<String> result=OneOffCreditController.getselectOptions(Obj,fieldname);
        Test.stopTest();  
        System.assertEquals(result.contains('Insolvent'),false);
       }
    
        /*------------------------------------------------------------ 
    Metohd: getselectOptionsTest 
    Description: EDGE-158381:Code coverage for getSelectedProduct
    Returns: return Map values 
        ----------------------------------------------------------- */
    @isTest
       public static void getSelectedProductPostive()
       {
      Non_Marketable_Product__c nonMarkatable = new Non_Marketable_Product__c(currency__c='AUD',specId__c='DMCAT_StandaloneProduct_001243',productDescription__c='test',taxTreatment__c='GST Applicable');
      insert nonMarkatable;
      Test.startTest();
      Map<String,List<Non_Marketable_Products__mdt>> result=OneOffCreditController.getSelectedProduct(nonMarkatable.id,'Insolvency_Management');
      Test.stopTest();
      system.debug('final result'+result);     
      List<Non_Marketable_Products__mdt> resultList=result.get('selectedProduct');
      System.assertEquals(resultList[0].DeveloperName,'DMCAT_StandaloneProduct_001243');
       }
     @isTest
       public static void getSelectedProductNegative()
       {
       Non_Marketable_Product__c nonMarkatable = new Non_Marketable_Product__c(currency__c='AUD',specId__c='DMCAT_StandaloneProduct_00143',productDescription__c='test',taxTreatment__c='GST Applicable');
       insert nonMarkatable;
       Test.startTest();
       Map<String,List<Non_Marketable_Products__mdt>> result=OneOffCreditController.getSelectedProduct(nonMarkatable.id,'Insolvency_Management');
       Test.stopTest();
       List<Non_Marketable_Products__mdt> resultList=result.get('selectedProduct');
       System.assertEquals(resultList.isEmpty(),true);
       }
    	@isTest
       public static void getSelectedProductNameTest()
       {
       Non_Marketable_Product__c nonMarkatable = new Non_Marketable_Product__c(currency__c='AUD',specId__c='DMCAT_StandaloneProduct_00143',productDescription__c='test',taxTreatment__c='GST Applicable');
       insert nonMarkatable;
       Test.startTest();
       String productItem = OneOffCreditController.getSelectedProductName(nonMarkatable.id);
       Test.stopTest();
		System.assertEquals(productItem,nonMarkatable.id);
       }
    
}
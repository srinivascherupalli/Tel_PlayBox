/*************************************************************************************************
Name : FundReversalhandlerTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Shubhi/vamsi      4-Feb-2021        EDGE-193068(New class)
2.         shubhi            23-08-2021        fdr test validation fix 
===============================================================================================================================
***************************************************************************************************/
@isTest
public class FundReversalhandlerTest {
    public static Id AllocationRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();   
   // public static id committedFundRecId = Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Committed').getRecordTypeId();
  @TestSetup
  public static void testSetup(){
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        List<User> listOfUsers = new List<User>();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'saleEnt', Email='SalesEnterpriseUnified@test.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles',UserName=uniquename+'testpermissionsetuser@test.com');
        listOfUsers.add(u);

        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                  lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                                  profileid = pf.id,
                                  timezonesidkey='Australia/Sydney',
                                  username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        listOfUsers.add(sales);
        Insert listOfUsers;
        System.runAs(u){
            
                      List<PermissionSet> psList = [SELECT Id FROM PermissionSet WHERE Name IN ('OneFund_Admin')];
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for(PermissionSet ps: psList){
                PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = sales.id, PermissionSetId = ps.Id);
                psaList.add(psa);
            }   
            if(!psaList.isEmpty()){
                insert psaList; 
            }
         }
        //////////////////////////////
    //Account accountRecord = APTPS_TestClassData.accountRecord('Fund Trigger Test','1233211231');
    Account accountRecord = AccountTestFactory.buildAccount ('testAccount');
        accountRecord.CIDN__c='1233211231';
        insert accountRecord;
        ////////
        Billing_Account__c OneFundRBillingAccount =new Billing_Account__c(Account__c=accountRecord.id, Billing_Account_Name__c='TestOneFund',Billing_Account_Number__c='221298645728');
        insert OneFundRBillingAccount;
    ///////////////
    OneFund__c OneFundRecord = new OneFund__c(Contract_Duration__c = '24',
                                                Customer_Commitment__c = '1000', 
                                                /*RecordTypeId = committedFundRecId,*/Billing_Account__c=OneFundRBillingAccount.id,
                                                CIDN__c = accountRecord.id);
        insert OneFundRecord;   
    ///////////////////
    //////////////
        List<Contact> listOfContacts = new List<Contact>();
        Contact cont1 = new Contact(OwnerId=sales.Id,FirstName = 'TestCont1',LastName = 'TestCont1',AccountId=accountRecord.Id,Email='testcont1@test.com',Phone='0424289156',MobilePhone='0424289156');
        listOfContacts.add(cont1);
        insert listOfContacts;
        cscfga__Product_Definition__c prodDef= new cscfga__Product_Definition__c();
        prodDef.name='Inactive SIM';
        prodDef.cscfga__Description__c='Inactive SIM';
        prodDef.product_Specification__c='DMCAT_ProductSpecification_000753';
        insert prodDef;
        //////////////////////////////////////////////////////////////////////////////////
        list<cscfga__Product_Basket__c> prodBasList= new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c prodBas1= new cscfga__Product_Basket__c();
        prodBas1.name='Test2';
        prodBas1.Order_Requester__c = cont1.Id;
        prodBas1.referencenumber__c='ABC000000000';
        prodBas1.csbb__Account__c=accountRecord.id;
        prodBasList.add(prodBas1);              
        insert prodBasList;
        //////////////////////////////////////////////////////////////////////////////////
        List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.name = 'prod config';
        config.Quantity_Product_Configuration__c=201;
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__Product_Definition__c=prodDef.id;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c=prodBas1.id;
        prodConfigLst.add(config);
    cscfga__Product_configuration__c config1 = new cscfga__Product_configuration__c();
    config1.name = 'prod config1';
    config1.cscfga__Contract_Term__c = 12;
    config1.cscfga__Product_Definition__c=prodDef.id;
    config1.cscfga__total_contract_value__c = 325;
    config1.cscfga__Product_Basket__c=prodBas1.id;
    prodconfigLst.add(config1);
        insert prodConfigLst;
    /////////////////////////////////////////////////////////////////////////////////
    List <cscfga__Attribute__c> listTestAttribute = new List <cscfga__Attribute__c>();
        cscfga__Attribute__c testAttribute = new cscfga__Attribute__c();
        testAttribute.Name = 'Redeemfund';
        testAttribute.cscfga__Product_Configuration__c = config.Id;
        testAttribute.cscfga__is_active__c = true;
        testAttribute.cscfga__Value__c = '100';
        listTestAttribute.add (testAttribute); // Added as part of EDGE-133414
        cscfga__Attribute__c testChargeAttribute = new cscfga__Attribute__c();
        testChargeAttribute.Name = 'Redeemfund';
        testChargeAttribute.cscfga__Product_Configuration__c = config1.Id;
        testChargeAttribute.cscfga__is_active__c = true;
        testChargeAttribute.cscfga__Value__c = '59.09';
        listTestAttribute.add (testChargeAttribute); // Added as part of EDGE-185438
        insert listTestAttribute; 
        //////////////////////
        List<cscfga__Attribute_Field__c> attrFieldList= new  List<cscfga__Attribute_Field__c>();
        cscfga__Attribute_Field__c attrField=new cscfga__Attribute_Field__c();
        attrField.name ='OneFundAction';
        attrField.cscfga__Attribute__c=testAttribute.id;
        attrField.cscfga__Value__c='Debit';
        attrFieldList.add(attrField);
        cscfga__Attribute_Field__c attrField1=new cscfga__Attribute_Field__c();
        attrField1.name ='OneFundAction';
        attrField1.cscfga__Attribute__c=testChargeAttribute.id;
        attrField1.cscfga__Value__c='Credit';
        attrFieldList.add(attrField1);
        insert attrFieldList;
        
  }
    //EDGE-193068 method to test positive scenario
    @IsTest
    public static void getBasketFundDetailsTest(){
        Test.startTest();
          User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com' limit 1];
            System.runAs(sales){
            list<cscfga__Product_Basket__c> prodBasketList=[select id,csbb__Account__c,csbb__Account__r.CIDN__c,csbb__Account__r.Parent_CIDN__c,csbb__Account__r.Ultimate_Parent_CIDN__c 
                                                            from cscfga__Product_Basket__c];
            Set<String> pdIdset=new Set<String>();                                                
            for(cscfga__Product_Basket__c pb:prodBasketList){
                pdIdset.add(pb.id);    
            }
        FundReversalhandler.insertTransactions(pdIdset,prodBasketList);
        List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();
                transactionList=[Select id,Transaction_Amount__c from OneFund_Transactions__c where Sub_Type__c ='POS'];
        System.assertEquals(true, transactionList.size()==0);          
            }
        Test.stopTest();
    }
     //EDGE-193068 method to test negative scenario
    @IsTest
    public static void getBasketFundDetailsTestNegative(){
        Test.startTest();
           User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com'];      
            System.runAs(sales){
            list<cscfga__Product_Basket__c> prodBasketLst=new  list<cscfga__Product_Basket__c>();
            Set<String> pdIdset=new Set<String>();
        FundReversalhandler.insertTransactions(pdIdset,prodBasketLst);
        List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();
                transactionList=[Select id,Transaction_Amount__c from OneFund_Transactions__c where Sub_Type__c IN('POS','Reversal')];
        System.assertEquals(true, transactionList.size()==0);          
            }
        Test.stopTest();
    }

}
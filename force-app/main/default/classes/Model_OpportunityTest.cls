/****************************************************************************************************************************************************
Main Class : Model_Opportunity
Test Class : Model_OpportunityTest
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           24/09/2020      EDGE-148667    20.09(New Class)     To collate all the queries related to Price Item Object
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_OpportunityTest{
   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
      Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId(); 
       
    Opportunity testOppty = new Opportunity();
    List<Opportunity> opptyLst = new List<Opportunity>();
    testOppty.name = 'Test Oppty';
    testOppty.Type = 'Migration';
    testOppty.StageName = 'Develop';
    testOppty.CloseDate = date.today().addDays(30);
    testOppty.Revenue_Impact_Date__c = testOppty.CloseDate + 15;
    testOppty.Product_Type__c = 'Modular';
    testOppty.Product_Domain__c = 'other';
    testOppty.Billing_Solution__c = 'Standard';
    testOppty.RecordTypeId = standardID;
    opptyLst.add(testOppty);
    insert opptyLst;
       system.debug('New Oppty'+opptyLst);
    
   }
    @IsTest
  private static void getOpportunityTest(){
        Opportunity opp = [SELECT Id, Name, Type, StageName, CloseDate, Revenue_Impact_Date__c, Product_Type__c, Product_Domain__c, RecordTypeId, CreatedDate FROM Opportunity];
        Model_Opportunity mdOppty = new Model_Opportunity();
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        //System.runAs(sales){
            Opportunity oppNew = mdOppty.getOpportunity(opp.id);
            System.assertEquals('Modular',oppNew.Product_Type__c);
        //}       
        Test.stopTest();
    }
}
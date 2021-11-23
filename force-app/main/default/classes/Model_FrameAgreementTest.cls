/****************************************************************************************************************************************************
Main Class : Model_FrameAgreement
Test Class : Model_FrameAgreementTest
Sr.No.    Developer Name           Date            Story          Sprint               Description
1.     Vamsi Krishna Vaddipalli  18NOV2021      EDGE-11211    20.16(New Class)     To collate all the queries related to FrameAgreement Object
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_FrameAgreementTest {

   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;

       Opportunity oppty = TestDataFactory.generateOpportunity();
       csconta__Frame_Agreement__c frmAgrmt = new csconta__Frame_Agreement__c();
       frmAgrmt.Opportunity__c = oppty.id;
       insert frmAgrmt;
       
}
    
        @IsTest
  private static void getFAMTest(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];   
      csconta__Frame_Agreement__c framelist = new csconta__Frame_Agreement__c();
        System.runAs(sales){
           csconta__Frame_Agreement__c frame = [SELECT id,Name FROM csconta__Frame_Agreement__c LIMIT 1]; 
           String famID = frame.id;
            framelist = Model_FrameAgreement.getFrameAgreements(famID); 
        }     
      system.assertNotEquals(null, framelist);
        Test.stopTest();
    }
}
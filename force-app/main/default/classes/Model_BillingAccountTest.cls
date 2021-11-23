/****************************************************************************************************************************************************
Main Class : Model_BillingAccount
Test Class : Model_BillingAccountTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story          Sprint               Description
1.        Aman Soni           07/07/2020      EDGE-147513    20.09(New Class)     To cover Model_BillingAccount functionality
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class Model_BillingAccountTest{
   @TestSetup
   public static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    String str1 = '';
    String str2 = '';
    String statusValues=System.Label.BillingAccountStatus;
    Set<String> billingAccStatusSet=new Set<String>(statusValues.split(','));
    if(billingAccStatusSet.contains('Pending Finalisation'))
    str1 = 'Pending Finalisation';

    if(billingAccStatusSet.contains('Final'))
    str2 = 'Final';
    
    List<Billing_Account__c> billAccLst= new List<Billing_Account__c>();
    Billing_Account__c bilAcc1 = new Billing_Account__c();
    bilAcc1.Billing_Account_Number__c = '700000567151';
    bilAcc1.Status__c = str1 ;
    billAccLst.add(bilAcc1);
    
    Billing_Account__c bilAcc2 = new Billing_Account__c();
    bilAcc2.Billing_Account_Number__c = '700000567152';
    bilAcc2.Status__c = str2;
    billAccLst.add(bilAcc2);
    insert billAccLst; 
   }
    static testmethod void getBillingAccountOnStatusPositive(){       
        List<Billing_Account__c> billAccLst = [SELECT id, Billing_Account_Number__c, Status__c FROM Billing_Account__c];
        List<String> billAccStrLst = new List<String>();
        for(Billing_Account__c billAcc :billAccLst){
            billAccStrLst.add(billAcc.id);
        }
        Set<String> billAccStrSet = new Set<String>(billAccStrLst);
        String AccId = '00356789fghjk';
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            Map<String,Billing_Account__c> billAccMap = Model_BillingAccount.getBillingAccountOnStatus(AccId, billAccStrSet);
            System.assert(true, !billAccMap.isEmpty()); 
        }       
        Test.stopTest();
    }
    static testmethod void getBillingAccountOnStatusNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];     
        System.runAs(sales){
            Map<String,Billing_Account__c> billAccMap = Model_BillingAccount.getBillingAccountOnStatus(null, null);
            System.assert(true, billAccMap.isEmpty()); 
        }
        Test.stopTest();
    }

}
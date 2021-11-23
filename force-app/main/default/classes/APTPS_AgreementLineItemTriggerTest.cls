//description: test Class fot APTPS_AgreementLineItemTrigger
//createdDate: 27-02-2019
//usedBy: APTPS_AgreementLineItemTrigger
//author: Kunal Dixit
//JIRA : EDGE-63495
//-------------------------------------------------------------------------------------

@isTest(SeeAllData=false)
public class APTPS_AgreementLineItemTriggerTest {

    @testSetup static void testAgreementSetup(){
        Account testAccount=APTPS_TestClassData.accountRecord('Test_Account','1234567899');
        Contact testContact=APTPS_TestClassData.contactRecord('Testing', 'Contact', testAccount.Id);
        List<Apttus__APTS_Agreement__c> agmtList=new List<Apttus__APTS_Agreement__c>();
        List<String> statusCatList=new List<String>{'In Signatures','In Effect','In Effect','In Effect','In Effect','In Effect','Terminated','Amended','Cancelled'};
        List<String> statusList=new List<String>{'Fully Signed','Activated','Being Amended','Being Renewed','Being Terminated','Rolling','Terminated','Superseded','Cancelled Request'};
        List<Apttus__AgreementLineItem__c> agmtLineItemList=new List<Apttus__AgreementLineItem__c>();
        List<Apttus__APTS_Agreement__c> childAgmtList = APTPS_TestClassData.createNumberOfAgreement(testAccount.Id, 'Schedule',statusList.size());
        for(Integer i=0;i<childAgmtList.size();i++){
        	childAgmtList[i].Apttus__Contract_End_Date__c=Date.newInstance(2019,3,21+i);
         	childAgmtList[i].Apttus__Status_Category__c=statusCatList.get(i);
            childAgmtList[i].Apttus__Status__c=statusList.get(i);
        }
        update childAgmtList;
    }
    
    
    @istest
    public static void beforeDeleteEventTriggerEnabledTest(){
		List<Apttus__APTS_Agreement__c> agmtIdList=[select Id from Apttus__APTS_Agreement__c where Apttus__Account__c IN (select Id from Account where Name='Test_Account')];
        List<Apttus__AgreementLineItem__c> agmtLineItemList=[select Id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c IN :agmtIdList];
        
        Test.startTest();
        Database.DeleteResult[] result=Database.delete(agmtLineItemList,false);
        boolean condition=false;
        for(Integer i=0;i<agmtLineItemList.size();i++){
            if(! result.get(i).isSuccess()) condition=true;
            system.assertEquals(true, condition,'Agremenet Line Item got deleted check error');
        }
        Test.stopTest();
        
     }
    
    @isTest
    public static void beforeDeleteEventTriggerDisabledTest(){
        Test.startTest();
        Environment_Configurations__c settings=new Environment_Configurations__c();
        settings.No_Triggers__c=true;
        insert settings;
        
        EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('APTPS_AgreementLineItemTrigger');
        List<Apttus__APTS_Agreement__c> agmtIdList=[select Id from Apttus__APTS_Agreement__c where Apttus__Account__c IN (select Id from Account where Name='Test_Account')];
        List<Apttus__AgreementLineItem__c> agmtLineItemList=[select Id from Apttus__AgreementLineItem__c where Apttus__AgreementId__c IN :agmtIdList];
        
        Database.DeleteResult[] result=Database.delete(agmtLineItemList,false);
        boolean condition=false;
        for(Integer i=0;i<agmtLineItemList.size();i++){
            if(! result.get(i).isSuccess()) condition=true;
            system.assertEquals(false, condition,'Agremenet Line Item wasn\'t deleted check error');
        }
        Test.stopTest();
    }
}
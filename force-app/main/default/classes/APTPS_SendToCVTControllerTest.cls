/*****************************************************************
@Name: APTPS_SendToCVTControllerTest
@Author: Akanksha Trivedi
@CreateDate:22/03/2017 
@Description: This is the Test class for APTPS_SendToCVTController
******************************************************************/ 
@isTest
public with sharing class APTPS_SendToCVTControllerTest {
 static testMethod void testData(){
        Apttus__ComplySystemProperties__c complyCustomSettings = new Apttus__ComplySystemProperties__c();
        complyCustomSettings.APTPS_Mass_Activation_Page_Size__c = 1;
        complyCustomSettings.Name = 'System Properties';
        insert complyCustomSettings;
        
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Id recordtypeID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c(Name= 'Test Agreement', Apttus__Account__c = acct.id, RecordTypeId =recordtypeID);
        agmt.Apttus__Agreement_Number__c = '2323';
        agmt.Apttus__Company_Signed_Date__c = Date.today();
        agmt.APTPS_Is_Eligible_For_CVT_Transfer__c= true;
        insert agmt;
        system.assertNotEquals(null, agmt.Id);
    }
    
     static testMethod void testAPTPS_SendToCVTController(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name from Apttus__APTS_Agreement__c limit 1];
        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SendToCVTController controller = new APTPS_SendToCVTController(stdCon);
        controller.createListForAgreementsToBeSent(); 
        controller.updatePage();
        system.assert(controller.genericList != null);  
        Test.stopTest();
    }
    
      static testMethod void testAPTPS_SendToCVTController1(){
        testData();
        Apttus__APTS_Agreement__c agmt= [SELECT Id, name,Apttus__Account__r.Name,
                                                    Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                    Apttus__Status__c,  Apttus__Agreement_Category__c,APTPS_Agreement_Subcategory__c,   Apttus__Subtype__c, 
                                                    Apttus__Parent_Agreement__c, createddate,
                                                    Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, Apttus__Contract_End_Date__c, APTPS_Is_Eligible_For_CVT_Transfer__c,
                                                    APTPS_Send_Message_To_CVT_Manually__c, APTPS_Is_Custom_Update__c from Apttus__APTS_Agreement__c limit 1];
        
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(agmt);
        APTPS_SendToCVTController controller = new APTPS_SendToCVTController(stdCon);
       
        APTPS_AgreementSelection wrapperOneParam = new APTPS_AgreementSelection(agmt);
        List<APTPS_AgreementSelection> wrapperOneParamList= new List<APTPS_AgreementSelection>();
        wrapperOneParamList.add(wrapperOneParam);
        APTPS_AgreementSelection wrapperOneParam1 = new APTPS_AgreementSelection(agmt);
        List<APTPS_AgreementSelection> wrapperOneParamList1= new List<APTPS_AgreementSelection>();
        wrapperOneParamList1.add(wrapperOneParam1);  
        List<List<APTPS_AgreementSelection>> wrapperOneParamListOfList= new List<List<APTPS_AgreementSelection>>();  
        wrapperOneParamListOfList.add(wrapperOneParamList);
        wrapperOneParamListOfList.add(wrapperOneParamList1);  
        controller.fullGenericList= wrapperOneParamListOfList;
        controller.nextPage();
        controller.previousPage();
        system.assert(controller.genericList != null);   
        Test.stopTest();
    }
}
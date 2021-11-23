/*************************************************************************************************************************
@Name: APTS_AgreementBatchTest
@Author: Lokesh D
@Created Date: 07/03/2020
@Descripton: Rolling status functionality.
*************************************************************************************************************************/
@istest
private Without sharing class APTS_AgreementBatchTest {
    
    static testMethod void testMethod1() {
       
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';      
        insert acc;  
        system.assertNotEquals(null, acc.Id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);
        Date tempDateoflastday = Date.valueOf(System.today()-1);
        agmt.Apttus__Auto_Renewal__c=true;       
        agmt.APTPS_Effective_End_Date__c=Date.valueOf(System.today()-1);        
        agmt.Apttus__Status__c='Activated';        
        update agmt;
        
         Test.startTest();
        APTS_AgreementBatch custPrimContactBatch = New APTS_AgreementBatch();
        database.executeBatch(custPrimContactBatch);        
        Test.stopTest();
    }
    static testMethod void testMethod2() {
      
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';    
        insert acc;  
        system.assertNotEquals(null, acc.Id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);
        Date tempDateoflastday = Date.valueOf(System.today()-1);
        agmt.Apttus__Auto_Renewal__c=true;       
        agmt.APTPS_Effective_End_Date__c=Date.valueOf(System.today()-1);        
        agmt.Apttus__Status__c='Rolling';        
        update agmt;
        
        Test.startTest();
        APTS_AgreementBatch custPrimContactBatch = New APTS_AgreementBatch();
        database.executeBatch(custPrimContactBatch);        
        Test.stopTest();
    }
    static testMethod void testMethod3() {
       
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';   
        insert acc;  
        system.assertNotEquals(null, acc.Id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);
        Date tempDateoflastday = Date.valueOf(System.today()-1);
        agmt.Apttus__Auto_Renewal__c=false;       
        agmt.APTPS_Effective_End_Date__c=Date.valueOf(System.today()-1);       
        agmt.Apttus__Status__c='Rolling';       
        agmt.Apttus__Auto_Renew_Term_Months__c=null;       
        update agmt;
        
        Test.startTest();
        APTS_AgreementBatch custPrimContactBatch = New APTS_AgreementBatch();
        database.executeBatch(custPrimContactBatch);        
        Test.stopTest();
    }
    static testMethod void testMethod4() {
   
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';      
        insert acc;  
        system.assertNotEquals(null, acc.Id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);       
        agmt.Apttus__Auto_Renewal__c=true;       
        agmt.APTPS_Effective_End_Date__c=Date.valueOf(System.today()-2);        
        agmt.Apttus__Status__c='Activated';
         update agmt;
        
        Test.startTest();
        APTS_AgreementBatch custPrimContactBatch = New APTS_AgreementBatch();
        database.executeBatch(custPrimContactBatch);  
        Test.stopTest();
    }
    
     static testMethod void testMethod5() {
       
        Account acc = new Account();
        acc.name = 'TestAccount1';
        acc.CIDN__c = '9878467453';
        acc.Customer_ID__c = '2021945565';
        acc.Customer_status__c = 'ACTIVE';
        acc.Portfolio_Code__c = 'XYZ';
        acc.TCM_MasterID__c ='10000257090';     
        insert acc;  
        system.assertNotEquals(null, acc.Id);
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementRecord(acc.id);        
        agmt.Apttus__Auto_Renewal__c=true;      
        agmt.APTPS_Effective_End_Date__c=Date.valueOf(System.today()-10);        
        agmt.Apttus__Status__c='Activated'; 
        update agmt;
        
        Test.startTest();
        APTS_AgreementBatch custPrimContactBatch = New APTS_AgreementBatch();
        database.executeBatch(custPrimContactBatch);        
        Test.stopTest();
    }
   
}
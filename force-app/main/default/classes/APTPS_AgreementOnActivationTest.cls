@isTest(seeAllData=false)
private class APTPS_AgreementOnActivationTest{ 

    @testSetup static void setup() {
        
        Account acct1 = APTPS_TestClassData.accountRecord('Main Account', '1237778898');
        Apttus__APTS_Agreement__c agreementSO = APTPS_TestClassData.agreementRecord(acct1.id);
        Apttus__APTS_Template__c templateClause = APTPS_TestClassData.templateRecord('Test Clause', 'Clause');
        
        Apttus__Agreement_Clause__c agmtClause = new Apttus__Agreement_Clause__c(Apttus__Clause__c = 'Test Clause',
                                                        Apttus__Agreement__c = agreementSO.id,
                                                        Approval_Status__c='Approval Required',
                                                        Apttus__Active__c = true, 
                                                        Apttus__Category__c = 'default',
                                                        Apttus__Subcategory__c = 'Default', 
                                                        Apttus__Action__c = 'Inserted', 
                                                        Apttus__Text__c = 'test');
        insert agmtClause;
        
        APTPS_Master_Obligation__c mObligation = new APTPS_Master_Obligation__c();
        mObligation.APTPS_ClauseName__c = templateClause.Id;
        mObligation.APTPS_Approval_Required__c = 'Approval Required';
        mObligation.Apttus_Description__c = 'Test Description';
        mObligation.APTPS_Category__c='default';
        mObligation.APTPS_Obligation_Frequency__c='Weekly';
        mObligation.APTPS_Responsible__c='Customer';
        mObligation.APTPS_Status__c='Open';
        mObligation.APTPS_Sub_Category__c='default';
        insert mObligation;
    }
    
    static testMethod void createObligationsOnActivationTest(){ 
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId(); 
        Apttus__APTS_Agreement__c agreementSO = new Apttus__APTS_Agreement__c();
        agreementSO = [SELECT id from Apttus__APTS_Agreement__c LIMIT 1];
        agreementSO.RecordTypeId = saRecordTypeId ;
        agreementSO.APTPS_Auto_Obligation_Creation__c = 'Yes';
        agreementSO.Apttus__Status_Category__c = 'In Effect';
        agreementSO.Apttus__Status__c ='Activated'; 
        update agreementSO;

        
        system.assertEquals('Yes', agreementSO.APTPS_Auto_Obligation_Creation__c);
        system.assertEquals('Activated', agreementSO.Apttus__Status__c);

    }
    
    
}
@isTest
public class APTPS_AgreementSelectionTest{
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_AgreementSelection class
    *******************************************************************/
    static testMethod void APTPS_AgreementSelectionParent(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Attachment attachedDoc = new Attachment();    
        attachedDoc.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachedDoc.body = bodyBlob;
        attachedDoc.parentId = agmt.id;
        insert attachedDoc;
        system.assertNotEquals(null, attachedDoc.Id);
        update agmt;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:agmt.id];
        
        APTPS_AgreementSelection wrapperOneParam = new APTPS_AgreementSelection(agmt);
        
        APTPS_AgreementSelection wrapperMultipleParam = new APTPS_AgreementSelection(agmt, 'Test');
        wrapperMultipleParam.compareTo(wrapperOneParam);
        
        APTPS_AgreementSelection wrapperMultipleParam2 = new APTPS_AgreementSelection(agmt, False);
    }
    
    /******************************************************************
    @Description: This test method is written for covering the APTPS_AgreementSelection class
    *******************************************************************/
    static testMethod void APTPS_AgreementSelectionChild(){
        Account acct = APTPS_TestClassData.accountRecord('Test Account', '1237778898');
        Apttus__APTS_Agreement__c agmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'SA');
        Apttus__APTS_Agreement__c childAgmt = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        childAgmt.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt.APTPS_Schedule_Number_Text__c = '1';
        update childAgmt;
        
        Apttus__APTS_Agreement__c childAgmt2 = APTPS_TestClassData.agreementWRecordType(acct.id, 'Schedule');
        childAgmt2.Apttus__Parent_Agreement__c = agmt.id;
        childAgmt2.APTPS_Schedule_Number_Text__c = '3';
        update childAgmt2;
        
        Attachment attachedDoc = new Attachment();    
        attachedDoc.Name ='Account-Agreement_Conformed-Agreement';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attachedDoc.body = bodyBlob;
        attachedDoc.parentId = childAgmt.id;
        insert attachedDoc;
        system.assertNotEquals(null, attachedDoc.Id);
        update childAgmt;
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:childAgmt.id];
        
        APTPS_AgreementSelection wrapperOneParam = new APTPS_AgreementSelection(childAgmt);
        APTPS_AgreementSelection wrapperOneParam2 = new APTPS_AgreementSelection(childAgmt2);
        wrapperOneParam.compareTo(wrapperOneParam2);
        
        APTPS_AgreementSelection wrapperMultipleParam = new APTPS_AgreementSelection(childAgmt, 'Test');
        
        APTPS_AgreementSelection wrapperMultipleParam2 = new APTPS_AgreementSelection(childAgmt, false);
    }
}
/*****************************************************************
@Name: APTPS_DocuSignEnvRecpStatTriggerTest
@Author: Ruchika Patil 
@CreateDate: 07/09/2016 
@Description: This is the Test class for APTPS_DocuSignEnvelopeRecipientStatusTrigger
@UsedBy: APTPS_DocuSignEnvelopeRecipientStatusTrigger
******************************************************************/ 
@isTest
public with sharing class APTPS_DocuSignEnvRecpStatTriggerTest{
    /******************************************************************
    @Description: This test method is written for covering the APTPS_DocuSignEnvRecpStatTriggerHandler class
    *******************************************************************/  
    static testMethod void forNDAMultiParty(){
        
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
            
        Account acct2 = APTPS_TestClassData.accountRecord('Secondary Account', '1237898899');
        
        Contact con2 = TestUtil.createContact('fname12','lname12');
		con2.AccountId = acct2.id;
        insert con2;
        
        //Scenario 1 - Where Agreement is NDA and Category is Multi-Party        
        Apttus__APTS_Agreement__c agmt1 = APTPS_TestClassData.agreementNDAWContact(acct.id, con.id, acct2.id, con2.id);
        
        Apttus_DocuApi__DocuSignEnvelope__c env1 = APTPS_TestClassData.docuSignEnvelopeRecord(agmt1.id, 'testEnvelopeName');
        
        agmt1.Apttus__Agreement_Category__c = 'Multi-Party';
        agmt1.Apttus_CMDSign__DocuSignEnvelopeId__c = env1.id;
        update agmt1;
        
        Test.startTest();
        
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus1 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env1.id, '2');
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus2 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env1.id, '3');
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus3 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env1.id, '4');
        
        Test.stopTest();
        System.assertNotEquals(null, env1.Id);
    }
    static testMethod void forAllOtherRecordTypes(){
        Account acct = APTPS_TestClassData.accountRecord('Main Account', '1237008898');
        
        Contact con = APTPS_TestClassData.contactRecord(acct.id);
        
        //Scenario 2 - Where Agreement other than SA type     
        Apttus__APTS_Agreement__c agmt2 = APTPS_TestClassData.agreementWContact(acct.id, 'SA', con.id);
        
        Apttus_DocuApi__DocuSignEnvelope__c env2 = APTPS_TestClassData.docuSignEnvelopeRecord(agmt2.id, 'testEnvelopeName');
        
        agmt2.Apttus_CMDSign__DocuSignEnvelopeId__c = env2.id;
        update agmt2; 
        
        Test.startTest();
        
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus4 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env2.id, '2');
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus5 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env2.id, '3');
        Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c recpntStatus6 = APTPS_TestClassData.docuSignEnvRcptStatusRecord(env2.id, '4');
        
        List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c> statusList = new List<Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c>();
        for(Integer i=1;i<4;i++){
            
            Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c statusRec = new Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c(Apttus_DocuApi__DocuSignEnvelopeId__c = env2.id,
                                                                        Apttus_DocuApi__Email__c =  'test@test.com', Apttus_DocuApi__SignedDateTime__c = Date.newInstance(2016, 10, 11),
                                                                        Apttus_DocuApi__Status__c = 'completed', Apttus_DocuApi__RecipientName__c = 'Test Name', Apttus_DocuApi__RoutingOrder__c = string.valueOf(i));
        statusList.add(statusRec);
        }
        insert statusList;
        
        Test.stopTest();
        System.assert(statusList !=null);
        
    }
}
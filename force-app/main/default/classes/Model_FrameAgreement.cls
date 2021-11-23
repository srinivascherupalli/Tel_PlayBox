/****************************************************************************************************************************************************
Main Class : Model_FrameAgreement
Test Class : Model_FrameAgreementTest
Sr.No.        Developer Name      Date            Story          Sprint               Description
1.      Vamsi Krishna Vaddipalli  18NOV2021          20.16(New Class)     To collate all the queries related to Frame Agreement Object
******************************************************************************************************************************************************/
public with sharing class Model_FrameAgreement {
    
    @AuraEnabled
    public static csconta__Frame_Agreement__c getFrameAgreements(Id famId){
        csconta__Frame_Agreement__c frmAgrmt = new csconta__Frame_Agreement__c();
        if(String.isNotBlank(famId))
        {
            frmAgrmt = [SELECT id,Name,Opportunity__c FROM csconta__Frame_Agreement__c WHERE id =: famId ];
        }
        return frmAgrmt;
    }

}
/*************************************************************************************************************************
 @Name: APTPS_CheckCompanySignedDateController
 @Author: Shishir Bose
 @Created Date: 
 @Descripton: 
 @Used By: 
*************************************************************************************************************************/
public with sharing class APTPS_CheckCompanySignedDateController {
public id agmtId = apexpages.currentpage().getparameters().get('id');
    public APTPS_CheckCompanySignedDateController(ApexPages.StandardController controller) {

    }
    public Pagereference validationsOnActivate(){
        if(agmtId != null){
            Apttus__APTS_Agreement__c agmt = [Select id, Apttus__Company_Signed_Date__c , Apttus_Approval__Approval_Status__c from Apttus__APTS_Agreement__c where Id =: agmtId];
            Boolean dateNull, statusIncorrect;
            dateNull = statusIncorrect  = false;
            if(agmt.Apttus__Company_Signed_Date__c == null){
                 dateNull = true;
            }
            if(agmt.Apttus_Approval__Approval_Status__c == 'Approval Required' || agmt.Apttus_Approval__Approval_Status__c == 'Pending Approval' || agmt.Apttus_Approval__Approval_Status__c == 'Rejected'){
                statusIncorrect = true;
            }
            if(dateNull && statusIncorrect){
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.fatal,'Company Signed Date must be populated before activating the agreement.');
                ApexPages.addMessage(myMsg1);  
                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.fatal,'Agreements cannot be Activated when the Approval Status is in "Approval Required", "Pending Approval" or "Rejected".');
                ApexPages.addMessage(myMsg2);  
                return null;
            }
            else if(dateNull && !statusIncorrect){
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.fatal,'Company Signed Date must be populated before activating the agreement.');
                ApexPages.addMessage(myMsg1);   
                return null;
            }
            else if(!dateNull && statusIncorrect){ 
                ApexPages.Message myMsg2 = new ApexPages.Message(ApexPages.Severity.fatal,'Agreements cannot be Activated when the Approval Status is in "Approval Required", "Pending Approval" or "Rejected".');
                ApexPages.addMessage(myMsg2);  
                return null;
            }
            PageReference homePage= new PageReference('/apex/Apttus__AgreementActivate?id='+agmtId); 
            homePage.setRedirect(true);
            return homePage;
        }
        else{
            return null;
        }
    }
}
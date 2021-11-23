public with sharing class APTPS_ValidationOnESignatureController {
public id agmtId = apexpages.currentpage().getparameters().get('id');
    public APTPS_ValidationOnESignatureController(ApexPages.StandardController controller) {

    }
    public PageReference validationsOnESignature(){
        if(agmtId != null){
            List<Apttus__APTS_Agreement__c> agmtList = [Select id, RecordType.Name, Apttus__Term_Months__c, Apttus_Approval__Approval_Status__c, Apttus__Parent_Agreement__c,Apttus__Contract_End_Date__c from Apttus__APTS_Agreement__c where Id =: agmtId];
            for(Apttus__APTS_Agreement__c agmt : agmtList){
                if(agmt.id == agmtId && agmt.Apttus__Contract_End_Date__c == null && agmt.Apttus__Term_Months__c == null && agmt.RecordType.Name != 'NDA' && agmt.RecordType.Name != 'Supporting Agreement' && agmt.RecordType.Name != 'Agency Recognition' && agmt.RecordType.Name != 'Teaming'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Term(Months) or Original End Date must be populated before eSigning the Agreement'));
                }
                /*if(agmt.id != agmtId && agmt.Apttus_Approval__Approval_Status__c != 'Approved' && agmt.Apttus_Approval__Approval_Status__c != 'No Approval Needed'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error, 'Approvals are required for some Schedules associated with this head terms, please obtain the approvals before proceeding for eSignature'));
                }    */
            }
            if (ApexPages.hasMessages(ApexPages.Severity.error)) {
                return null;
            }
            else
            {
                PageReference eSignPage = new PageReference('/apex/APTPS_SentByESignatureButton?id='+agmtId); 
                eSignPage.setRedirect(true);
                return eSignPage;
            }
        }
        else{
            return null;
        }
    }

}
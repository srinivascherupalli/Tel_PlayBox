public with sharing class APTPS_SendforWetSignaturesController {
    
    public Id parentAgreementId {get;set;}
    public string actionButton {get;set;}
    
    public APTPS_SendforWetSignaturesController()
    {
        parentAgreementId = System.currentPageReference().getParameters().get('Id');   
        actionButton = System.currentPageReference().getParameters().get('action');          
    }
    
    public PageReference updateAgreementAndRedirect()
    {
        Apttus__APTS_Agreement__c agreement = [select Id, APTPS_Sent_for_Wet_Signatures__c from Apttus__APTS_Agreement__c where Id =:parentAgreementId];
        //agreement.APTPS_Sent_for_Wet_Signatures__c = true;
        agreement.APTPS_Send_Signatures_Wet_Sign_Button__c = true;
        update agreement;
        
        PageReference pageRef = new PageReference('/apex/SendEmailPreProcess?id='+parentAgreementId + '&action=Send_To_Other_Party_For_Signatures');
        ///apex/SendEmailPreProcess?id="&Id & "&action=Send_To_Other_Party_For_Signatures"
        return pageRef;
    }


}
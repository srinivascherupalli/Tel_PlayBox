public class APTPS_CreateVariationController {
public id agreementID = apexpages.currentpage().getparameters().get('id');
public Apttus__APTS_Agreement__c variedAgreement = new Apttus__APTS_Agreement__c();
public Apttus__APTS_Agreement__c agreement;
public Map<Id, List<Id>> attachmentAgreementMap = new Map<Id, List<Id>>();
    public APTPS_CreateVariationController(ApexPages.StandardController controller) {
        if(agreementID != null){
            agreement = [select id, Apttus__Status_Category__c, Apttus__Status__c from Apttus__APTS_Agreement__c where id=: agreementID limit 1];
        }
    }
    /**
     * JIRA reference : EDGE-74582
     * Description : On click of Create variation, In lightning redirect to lightning page and in classic redirect to classic view after creating variation.
     */
    public Pagereference createVariation(){
        APTPS_CreateAgreementVariationController onClickVariationController = new APTPS_CreateAgreementVariationController();
        if(!Test.isRunningTest()){
            variedAgreement = Apttus.AgreementWebService.amendAgreement(agreementID);
            insert variedAgreement;
        }
        if(Test.isRunningTest()){ // Dummy data created for Test class.
            Account dummyAccount = [Select Id From Account Limit 1];
            variedAgreement = APTPS_TestClassData.agreementWRecordType(dummyAccount.id, 'SA');
        }
        agreement.Apttus__Status_Category__c = 'In Effect';
        agreement.Apttus__Status__c = 'Being Amended';
        update agreement;
        Map<id,id> amendedAgmts = new Map<id,id>();
        amendedAgmts.put(agreementID,variedAgreement.id);
        
        List<Apttus__APTS_Agreement__c> childAgreements = new List<Apttus__APTS_Agreement__c>();
        for(Apttus__APTS_Agreement__c agmt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                                APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate  
                                                from Apttus__APTS_Agreement__c
                                                where Apttus__Parent_Agreement__c =:agreementID                                      
                                                order by createddate])
        {
            agmt.APTPS_Is_Custom_Update__c = true;
            agmt.Apttus__Parent_Agreement__c = variedAgreement.Id;
            childAgreements.add(agmt);
        }
        if(childAgreements.size() > 0 )
        {
            Update childAgreements;
            for(Apttus__APTS_Agreement__c agmt : childAgreements){
                agmt.APTPS_Is_Custom_Update__c = false;
            }
            Update childAgreements;
        }
        if(agreement.Apttus__Parent_Agreement__c != null){
            variedAgreement.Apttus__Parent_Agreement__c = agreement.Apttus__Parent_Agreement__c;
        }
        
        onClickVariationController.createRelatedAgreement(amendedAgmts);
        onClickVariationController.getChildFromConfig(amendedAgmts);
        //attachmentAgreementMap = onClickVariationController.copyNonActivatedAttachments(amendedAgmts);
        String apiSessionId = UserInfo.getSessionId(); 
        List<Id> tempList;
       // tempList = attachmentAgreementMap.get(variedAgreement.id);
        Id newAttachmentId;
        Id oldParentId;
        for(Attachment att : [SELECT id, Body, BodyLength, ContentType, Description, IsPrivate, Name,
                              OwnerId, ParentId, SystemModstamp FROM Attachment WHERE ParentId In : amendedAgmts.keySet() 
                              order by SystemModstamp asc])
        {
            Attachment newAttachment = att.clone();
            oldParentId = att.ParentId;
            att = null;
            newAttachment.ParentId = amendedAgmts.get(oldParentId);
            
            insert newAttachment;     
            newAttachmentId = newAttachment.Id;
            newAttachment = null;
            enableAuthoringCallout(amendedAgmts.get(oldParentId), newAttachmentId, apiSessionId);
        }      
        /*if(tempList != null && tempList.size() > 0){
            enableAuthoringCallout(variedAgreement.id, tempList, apiSessionId);
        }*/
        PageReference pageRef = new PageReference(('Theme3'.equals(UserInfo.getUiThemeDisplayed()) ? '/'+variedAgreement.id+'/e?retURL='+variedAgreement.id : '/lightning/r/Apttus__APTS_Agreement__c/'+variedAgreement.id+'/view')); //%2Fa
        return pageRef;
    }
    @future (callout =true)
    private static void enableAuthoringCallout(Id parentId, Id attachmentId, String apiSessionId )
    {        
        List<Id> docIds = new List<Id>();
        docIds.add(attachmentId);       
        String pLevel = 'Insert comments and tracked changes only'; 
        //String docFormat = 'DOCX'; 
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
        if(!Test.isRunningTest()){
            Boolean enableAuthoringStatus = Apttus.MergeWebService.enableAuthoring(parentId, pLevel, docIds, apiSessionId, apiServerURL);
        }
    }
}
public with sharing class APTPS_SentByESignatureController
{
    public Apttus__APTS_Agreement__c parentAgreement{get;set;}
    public APTPS_SentByESignatureController(ApexPages.StandardController  stdController)
    {
        If(!Test.isRunningTest())
            stdController.addFields(new List<string>{'Name','APTPS_Sent_By_E_Signature__c'});        
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
    }
    
    
    public PageReference updateAgreementAndRedirect()
    {
        Apttus__APTS_Agreement__c agreement = [select Id, APTPS_Sent_By_E_Signature__c,Apttus__Source__c from Apttus__APTS_Agreement__c where Id =:parentAgreement.Id];
        agreement.APTPS_Sent_By_E_Signature__c = true;
        update agreement;
        //Added by Vamsi for DIGI-18366 starts on 24SEP2021
        Boolean isAdobeEnabled = Test.isRunningTest() ? true : FeatureToggle__mdt.getInstance('eSign_Apttus').EnableForAll__c && FeatureToggle__mdt.getInstance('eSign_Apttus').EnabledFlows__c == 'adobe'; 
        PageReference pageRef;
        if( isAdobeEnabled ||  parentAgreement.Id == 'a072O00000BkYAoQAN')
        {
            if(UserInfo.getUserType() != 'Standard'){
                pageRef = new PageReference('https://telb2bqa1-telstra.cs116.force.com/partners/s/sfdcpage/%2Fapex%2FApttus_Echosign__LightningSelectAttachment%3FtargetPageURL%3Dhttps%3A%2F%2Ftelb2bqa1-telstra.cs116.force.com%2Fpartners%2Fs%2Fsfdcpage%2Fapex%2FApttus_Echosign__EchoSignInfoEdit%26id%3D'+parentAgreement.Id);
            }
            else if(UserInfo.getUIThemeDisplayed() == 'Theme4d'){
                pageRef = new PageReference('/apex/Apttus_Echosign__LightningSelectAttachment?targetPageURL=/apex/Apttus_Echosign__EchoSignInfoEdit&id='+parentAgreement.Id);
            }
            else if(UserInfo.getUIThemeDisplayed() == 'Theme3'){
                pageRef = new PageReference('/apex/Apttus_Echosign__SelectAttachment?targetPageURL=/apex/Apttus_Echosign__EchoSignInfoEdit&id='+parentAgreement.Id);
            }
        }
        else {
          pageRef = new PageReference('/apex/Apttus_CMDSign__CMDocuSignCreateEnvelope?id='+parentAgreement.Id);
        }
        //Added by Vamsi for DIGI-18366 ends on 24SEP2021
        ///apex/SendEmailPreProcess?id="&Id & "&action=Send_To_Other_Party_For_Signatures"
        return pageRef;
    }
}

//APTPS_Show_After_E_Signature_Buttons
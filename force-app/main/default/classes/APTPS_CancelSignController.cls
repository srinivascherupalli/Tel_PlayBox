/*************************************************************************************************************************
 @Name: APTPS_CancelSignController
 @Author: Akanksha Trivedi
 @Created Date: 01/24/2017
 @Descripton: This controller is created for handling the cancelation of Signatures
 @Used By: APTPS_Init_CancelSign VF page
*************************************************************************************************************************/
public with sharing class APTPS_CancelSignController
{
     public Apttus__APTS_Agreement__c parentAgreement{get;set;}
     public Id parentAgreementId{get;set;}
     public APTPS_CancelSignController(ApexPages.StandardController  stdController)
   
    {
         parentAgreementId = stdController.getId();
         if(!test.isRunningTest()){
         stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
         }    
         parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord(); 
         
    }
    public PageReference updateAgreement()
    {   
        PageReference pageRef = new PageReference('/home/home.jsp');
        pageRef = new PageReference('/'+parentAgreementId);        
        pageRef.setredirect(true);
        try{
            parentAgreement.Apttus__Status_Category__c = APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY;
            parentAgreement.Apttus__Status__c = APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS; 
            parentAgreement.APTPS_Sent_for_Wet_Signatures__c = false;
            update parentAgreement;
            return pageRef;
        }
        catch(Exception e)
        {
            System.debug('CaLMs System exception caught: ' + e.getMessage());                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,e.getMessage()));   
            return null;
        }
        
       
    }
}
//description: Service class for APTPS_AgreementLineItemTriggerHandler class
//createdDate: 25-02-2018
//usedBy: APTPS_AgreementLineItemTriggerHandler
//author: Kunal Dixit
//JIRA : EDGE-63495 BatchCustomerPrimaryContactAssignment
public with sharing class APTPS_AgreementLineItemTriggerService {
    Boolean hasCustomPermission = FeatureManagement.checkPermission('Ignore_Workflow_Rules');
    public void beforeDeleteValidation(Map<Id,Apttus__AgreementLineItem__c> parentIdMap){
       
        for(Apttus__APTS_Agreement__c agreement : [select Apttus__Status_Category__c,Apttus__Status__c from Apttus__APTS_Agreement__c where Id IN :parentIdMap.keySet()]){
            if( !(hasCustomPermission)&& ((APTPS_Constants.IN_EFFECT_STATUS_CATEGORY.equals(agreement.Apttus__Status_Category__c) &&
                 (APTPS_Constants.IN_EFFECT_STATUS.equals(agreement.Apttus__Status__c) || 
                  APTPS_Constants.BEINGAMENDED_STATUS.equals(agreement.Apttus__Status__c) ||
                  APTPS_Constants.BEINGRENEWED_STATUS.equals(agreement.Apttus__Status__c) || 
                  APTPS_Constants.BEINGTERMINATED_STATUS.equals(agreement.Apttus__Status__c) ||
                  APTPS_Constants.ROLLING_STATUS.equals(agreement.Apttus__Status__c))) ||
               (APTPS_Constants.TERMINATED_STATUS_CATEGORY.equals(agreement.Apttus__Status_Category__c) && APTPS_Constants.TERMINATED_STATUS.equals(agreement.Apttus__Status__c)) || 
               ('Amended'.equals(agreement.Apttus__Status_Category__c) && APTPS_Constants.SUPERSEDED_STATUS.equals(agreement.Apttus__Status__c)) || 
               (APTPS_Constants.CANCELLED_STATUS_CATEGORY.equals(agreement.Apttus__Status_Category__c) && 'Cancelled Request'.equals(agreement.Apttus__Status__c)) ||
               (APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY.equals(agreement.Apttus__Status_Category__c) && APTPS_Constants.FULLY_SIGNED_STATUS.equals(agreement.Apttus__Status__c))
              )){
                  if(parentIdMap.get(agreement.Id)!=null){
                      //Add Error in Custom label.
                      parentIdMap.get(agreement.Id).addError(System.Label.Agreement_Line_Item_Delete_error);
                  }
              }
        }
        
    }

}
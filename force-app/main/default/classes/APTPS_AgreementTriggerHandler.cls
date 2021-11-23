/******************************************************************
@Name: APTPS_AgreementTriggerHandler
@Author: Ruchika Patil 
@CreateDate: 14/03/2016 
@Description: This is the handler class for trigger APTPS_AgreementTrigger to perform activities on insert/update of agreement record.
@UsedBy: Agreement 
******************************************************************/ 
public with sharing class APTPS_AgreementTriggerHandler {
    
    APTPS_AgreementTriggerService agreementService = new APTPS_AgreementTriggerService();
    Transient Id serviceTrialRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Service Trial').getRecordTypeId();
    Transient Id supportingAgreementRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Supporting Agreement').getRecordTypeId();
    Transient Id agencyRecognitionRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Agency Recognition').getRecordTypeId();
    Transient Map<Id,Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>> agreementDocusignRecipients =  null;
    
    Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
    Transient Id panelRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Panel').getRecordTypeId();
    
    public void handleAfterUpdateEvents(Map<id,Apttus__APTS_Agreement__c > mapNewAgreement, List<Apttus__APTS_Agreement__c> agreementList, Map<id,Apttus__APTS_Agreement__c > mapOldAgreement)
    {
        Transient Set<Id> agrmntIdSetCopyObligationFrmTemplateObligation = new Set<Id>();     
        Transient List<Id> listIdTerminateObligation = new List<Id>();
        Transient Set<Id> agreementIdSetActivateLegacyAgreement = new Set<Id>();
        Transient Set<Id> agreementIdSetMinimumSpendEntries = new Set<Id>();
        Transient List<Id> salesAccountExecutiveIds = new List<Id>();
        Transient Map<Id,Id> salesAccountExecutiveMap = new Map<Id,Id>() ;
        Transient List<Id> agreementPrimaryContactIds = new List<Id>(); 
        Transient Map<Id,Id> agreementPrimaryContactMap = new Map<Id,Id>();
        Transient Map<Id,Id> agreementOpportunityMap = new Map<Id,Id>();
        Transient List<Id> agreementSecondaryContactIds = new List<Id>(); 
        Transient Map<Id,Id> agreementSecondaryContactMap = new Map<Id,Id>() ;
        Transient List<Apttus__APTS_Agreement__c> agreementListForDocuSignRecipients = new List<Apttus__APTS_Agreement__c>();
        Transient List<Apttus__APTS_Agreement__c> agreementListForPricingSpecialists = new List<Apttus__APTS_Agreement__c>();
        Transient List<Id> agreementCreatedByUsers = new List<Id>(); 
        Transient Map<Id,Id> agreementNewOwnersMap = new Map<Id,Id>() ;
        Transient List<Apttus__APTS_Agreement__c> agreementsOwnerChanged = new List<Apttus__APTS_Agreement__c>();        
        Transient List<Apttus__APTS_Agreement__c> agreementListToReCreateDocuSignRecipients = new List<Apttus__APTS_Agreement__c>();
        Transient List<Id> salesAccountExecutiveIdsToReCreateDocuSignRecipients = new List<Id>();
        Transient List<Id> agreementPrimaryContactIdsToReCreateDocuSignRecipients = new List<Id>(); 
        Transient List<Id> agreementSecondaryContactIdsToReCreateDocuSignRecipients = new List<Id>();
        Transient Map<Id, Apttus__APTS_Agreement__c> agreementsWithSalesAcExecChange = new Map<Id, Apttus__APTS_Agreement__c>();
        Transient Map<Id, Apttus__APTS_Agreement__c> agreementsWithPriContcChange = new Map<Id, Apttus__APTS_Agreement__c>();
        Transient Id ndaRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('NDA').getRecordTypeId(); 
        Transient Set<Id> variedAgreements = new Set<Id>();
        Transient List<Apttus__APTS_Agreement__c> agreementListForFunds = new List<Apttus__APTS_Agreement__c>();
        //Transient Set<Id> agreementIdSetMinSpendEntriesRollOver = new Set<Id>();
        
        //Start of DIGI-20843 added by Gautam Kumar. Consolidating docusign variable references
        Boolean adobeDigitalEnabled = FeatureToggle__mdt.getInstance('eSign_Apttus').EnableForAll__c && 
                                      FeatureToggle__mdt.getInstance('eSign_Apttus').EnabledFlows__c == 'adobe' ;
        Boolean docuSignEnabled =  Test.isRunningTest() ? true : !adobeDigitalEnabled;
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignRecipientsUpdate = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignRecipientsAEOpportunity = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignRecipientsAccountExecutive = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignRecipientsPrimaryContact = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignRecipientsSecondaryContact = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignMap = null;
        Map<Id,Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>> docuSignDefaultReceipts = getAgreementDocusignRecipients(mapNewAgreement);
        // End of docusing variable consolidation for DIGI-20843
        
        APTPS_IAgreementService agreementOnActivation = new APTPS_AgreementOnActivation(mapNewAgreement,mapOldAgreement);
        agreementOnActivation.execute();
        Transient Group[] ccoCentral = [Select Id from Group where Type = 'Queue' AND Name =: APTPS_Constants.CCO_CENTRAL_QUEUE];
        for(Apttus__APTS_Agreement__c agreement: agreementList) { 
            //Obligation creation will be only triggered on change of status to Fully Signed.
            //Creating the set for Coping obligations from template obligations
            if(agreement.Apttus__Status__c == APTPS_Constants.FULLY_SIGNED_STATUS && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.FULLY_SIGNED_STATUS) {                          
                agrmntIdSetCopyObligationFrmTemplateObligation.add(agreement.Id);                       
            } 
            
            
            //Creating the list of obligations to be terminated on agreement expiry or termination  
            if(mapOldAgreement.Get(agreement.Id) != null
            && ((agreement.Apttus__Status_Category__c == APTPS_Constants.TERMINATED_STATUS 
            && agreement.Apttus__Status__c == APTPS_Constants.TERMINATED_STATUS 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.TERMINATED_STATUS 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.TERMINATED_STATUS) 
            || (agreement.Apttus__Status_Category__c == APTPS_Constants.EXPIRED_STATUS && agreement.Apttus__Status__c == APTPS_Constants.EXPIRED_STATUS  
            && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.EXPIRED_STATUS && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.EXPIRED_STATUS))){
                listIdTerminateObligation.add(agreement.id);
            }   
            
            //Creating the set for activating legacy agreements
            if(agreement.APTPS_Legacy_Agreement__c  && agreement.Apttus__Status_Category__c == 'In Filing')
            {
                agreementIdSetActivateLegacyAgreement.add(agreement.Id);
            }
            
            
            //Creating the set for the agreements for Minimum Spend entries. REFACTORED for APTPS_AgreementOnActivation
            /**if(mapOldAgreement.Get(agreement.Id) != null
            && (agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
            && agreement.Apttus__Status__c == APTPS_Constants.IN_EFFECT_STATUS 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.IN_EFFECT_STATUS) 
            && agreement.Apttus__Parent_Agreement__c != null
            )
            {
                agreementIdSetMinimumSpendEntries.add(agreement.Id); 
            }*/
            
            if(mapOldAgreement.Get(agreement.Id) != null                
            && agreement.APTPS_Sales_Account_Executive__c != null 
            && mapOldAgreement.Get(agreement.Id).APTPS_Sales_Account_Executive__c != agreement.APTPS_Sales_Account_Executive__c 
            && agreement.RecordTypeId == saRecordTypeId){
                agreementsWithSalesAcExecChange.put(agreement.Id, agreement);
            }
            
            if(mapOldAgreement.Get(agreement.Id) != null                 
            && agreement.APTPS_Customer_Primary_Contact__c != null 
            && mapOldAgreement.Get(agreement.Id).APTPS_Customer_Primary_Contact__c != agreement.APTPS_Customer_Primary_Contact__c 
            && agreement.RecordTypeId == saRecordTypeId){
                agreementsWithPriContcChange.put(agreement.Id, agreement);
            }
            
            // For changing child owners
            if(mapOldAgreement.Get(agreement.Id) != null
            && mapOldAgreement.Get(agreement.Id).OwnerId != agreement.OwnerId)
            {
                //Transient Group[] ccoCentral = [Select Id from Group where Type = 'Queue' AND Name =: APTPS_Constants.CCO_CENTRAL_QUEUE];
                if(!ccoCentral.isEmpty() && ccoCentral[0].Id == mapOldAgreement.Get(agreement.Id).OwnerId)
                {
                    agreementNewOwnersMap.put(agreement.Id,agreement.OwnerId);        
                }
            }
            
            if(agreement.Apttus__Status__c == APTPS_Constants.FULLY_SIGNED_STATUS 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.FULLY_SIGNED_STATUS
            && agreement.Apttus__Version_Number__c > 0 && agreement.APTPS_Validation_on_Fully_Signed__c) 
            {                          
                variedAgreements.add(agreement.Id);  
                
            }
            
            //Start of DIGI-20843 added by Gautam Kumar. Consolidating docusign code
            if(docuSignEnabled){
                
                //For updating docusign recipients Sales Account Executive
                if(mapOldAgreement.Get(agreement.Id) != null                
                && agreement.APTPS_Sales_Account_Executive__c != null 
                && mapOldAgreement.Get(agreement.Id).APTPS_Sales_Account_Executive__c != agreement.APTPS_Sales_Account_Executive__c 
                && docuSignDefaultReceipts.get(agreement.Id) != null)
                {
                    docuSignMap = docuSignDefaultReceipts.get(agreement.Id);
                    if(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_1) != null && agreement.Apttus__Related_Opportunity__c == null)
                    {
                        docuSignRecipientsAccountExecutive.add(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_1));                             
                        salesAccountExecutiveMap.put(agreement.Id,agreement.APTPS_Sales_Account_Executive__c);
                    }
                    if(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_3) != null)
                    {
                        docuSignRecipientsAccountExecutive.add(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_3));                      
                    }
                    if(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_4) != null)
                    {
                        docuSignRecipientsAccountExecutive.add(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_4));                      
                    }
                    
                }
                
                //For updating docusing recipients w.r.to Opportunity Owner
                if(mapOldAgreement.Get(agreement.Id) != null && 
                agreement.Apttus__Related_Opportunity__c != null && 
                docuSignDefaultReceipts.get(agreement.Id) != null && 
                docuSignDefaultReceipts.get(agreement.Id).get(APTPS_Constants.DOCUSIGN_SIGNER_1) != null)
                {
                    docuSignMap = docuSignDefaultReceipts.get(agreement.Id);
                    agreementOpportunityMap.put(agreement.Id,agreement.Apttus__Related_Opportunity__c);
                    docuSignRecipientsAEOpportunity.add(docuSignDefaultReceipts.get(agreement.Id).get(APTPS_Constants.DOCUSIGN_SIGNER_1));
                }
                //For updating docusign recipients Primary Contact
                if(mapOldAgreement.Get(agreement.Id) != null                 
                && agreement.APTPS_Customer_Primary_Contact__c != null 
                && mapOldAgreement.Get(agreement.Id).APTPS_Customer_Primary_Contact__c != agreement.APTPS_Customer_Primary_Contact__c 
                && docuSignDefaultReceipts.get(agreement.Id) != null)
                {
                    docuSignMap = docuSignDefaultReceipts.get(agreement.Id);
                    if(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_2) != null)
                    {
                        docuSignRecipientsPrimaryContact.add(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_2));       
                        agreementPrimaryContactMap.put(agreement.Id, agreement.APTPS_Customer_Primary_Contact__c);
                        
                    }
                    
                }
                
                //For updating docusign recipients Secondary Contact
                if(mapOldAgreement.Get(agreement.Id) != null                 
                && agreement.APTPS_SecAcnt_Primary_Contact__c != null 
                && mapOldAgreement.Get(agreement.Id).APTPS_SecAcnt_Primary_Contact__c != agreement.APTPS_SecAcnt_Primary_Contact__c
                && agreement.RecordTypeId ==  ndaRecordTypeId  
                && agreement.Apttus__Agreement_Category__c == APTPS_Constants.NDA_MULTI_PARTY
                && agreement.Apttus__Agreement_Category__c == mapOldAgreement.Get(agreement.Id).Apttus__Agreement_Category__c
                && docuSignDefaultReceipts.get(agreement.Id) != null)
                {
                    docuSignMap = docuSignDefaultReceipts.get(agreement.Id);
                    if(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_3) != null)
                    {
                        docuSignRecipientsSecondaryContact.add(docuSignMap.get(APTPS_Constants.DOCUSIGN_SIGNER_3));       
                        agreementSecondaryContactMap.put(agreement.Id,agreement.APTPS_Customer_Primary_Contact__c);
                    }
                    
                }            
                
                
                // For creating docusign recipients
                if(mapOldAgreement.Get(agreement.Id) != null                        
                && agreement.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY
                && agreement.Apttus__Status__c == APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS
                && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY 
                && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS
                && docuSignDefaultReceipts.get(agreement.Id) == null
                )
                {
                    agreementListForDocuSignRecipients.add(agreement);
                    salesAccountExecutiveIds.add(agreement.APTPS_Sales_Account_Executive__c);
                    agreementPrimaryContactIds.add(agreement.APTPS_Customer_Primary_Contact__c);
                    agreementSecondaryContactIds.add(agreement.APTPS_SecAcnt_Primary_Contact__c);
                }
                
                //Handling Change of Category for Docusign recipients
                if(mapOldAgreement.Get(agreement.Id) != null                 
                && agreement.Apttus__Agreement_Category__c != mapOldAgreement.Get(agreement.Id).Apttus__Agreement_Category__c
                && (agreement.RecordTypeId == ndaRecordTypeId || agreement.RecordTypeId == serviceTrialRecordTypeId
                || agreement.RecordTypeId == supportingAgreementRecordTypeId || agreement.RecordTypeId == agencyRecognitionRecordTypeId)
                && docuSignDefaultReceipts.get(agreement.Id) != null)
                {
                    //agreementNewOwnersMap.put(agreement.Id,agreement.OwnerId); 
                    agreementListToReCreateDocuSignRecipients.add(agreement);
                    salesAccountExecutiveIdsToReCreateDocuSignRecipients.add(agreement.APTPS_Sales_Account_Executive__c);
                    agreementPrimaryContactIdsToReCreateDocuSignRecipients.add(agreement.APTPS_Customer_Primary_Contact__c);
                    agreementSecondaryContactIdsToReCreateDocuSignRecipients.add(agreement.APTPS_SecAcnt_Primary_Contact__c);
                }
                
                //Special case for Supporting Agreement and Agency Recognization which do not have any recipients for certain category
                if(mapOldAgreement.Get(agreement.Id) != null                    
                && agreement.Apttus__Agreement_Category__c != mapOldAgreement.Get(agreement.Id).Apttus__Agreement_Category__c
                && (agreement.RecordTypeId == supportingAgreementRecordTypeId || agreement.RecordTypeId == agencyRecognitionRecordTypeId)
                && ((agreement.Apttus__Agreement_Category__c != 'MOU' && mapOldAgreement.Get(agreement.Id).Apttus__Agreement_Category__c == 'MOU') 
                || (agreement.Apttus__Agreement_Category__c != 'Facilities Manager' && mapOldAgreement.Get(agreement.Id).Apttus__Agreement_Category__c == 'Facilities Manager')) 
                && docuSignDefaultReceipts.get(agreement.Id) == null)
                {
                    //agreementNewOwnersMap.put(agreement.Id,agreement.OwnerId); 
                    agreementListToReCreateDocuSignRecipients.add(agreement);
                    salesAccountExecutiveIdsToReCreateDocuSignRecipients.add(agreement.APTPS_Sales_Account_Executive__c);
                    agreementPrimaryContactIdsToReCreateDocuSignRecipients.add(agreement.APTPS_Customer_Primary_Contact__c);
                    agreementSecondaryContactIdsToReCreateDocuSignRecipients.add(agreement.APTPS_SecAcnt_Primary_Contact__c);
                }
                
                
                
                //Creating the list of agreements for fund entries. REFACTORED for APTPS_AgreementOnActivation
                /**if(mapOldAgreement.Get(agreement.Id) != null
                && (agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                && agreement.Apttus__Status__c == APTPS_Constants.IN_EFFECT_STATUS 
                && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.IN_EFFECT_STATUS))
                {
                    agreementListForFunds.add(agreement);
                }
                if(agreement.Auto_Created_by_Basket__c == true)
                agreementService.updateAgreementBasketStage(agreement.Related_Basket__c,agreement.Apttus__Status_Category__c,agreement.Apttus__Status__c);
                **/
            }
            //End of DIGI-20843 added by Gautam Kumar. Consolidating docusign code
        } 
        
        agreementOnActivation.commitTransactions();
        agreementService.copyObligationFromTemplateObligation(agrmntIdSetCopyObligationFrmTemplateObligation);
        agreementService.terminateObligation(listIdTerminateObligation);
        agreementService.activateLegacyAgreement(agreementIdSetActivateLegacyAgreement);
        agreementService.updateChildOwners(agreementNewOwnersMap);
        //agreementService.createMinimumSpendEntries(agreementIdSetMinimumSpendEntries);
        //agreementService.createMinimumSpendEntries(agreementIdSetMinimumSpendEntries);
        //agreementService.createMinimumSpendEntries(agreementIdSetMinSpendEntriesRollOver, true);
        
        //Start of DIGI-20843 added by Gautam Kumar. Consolidating docusign code
        if(docuSignEnabled){
            
            agreementService.createDocuSignRecipients(salesAccountExecutiveIds, agreementPrimaryContactIds, agreementSecondaryContactIds,
            agreementListForDocuSignRecipients, ndaRecordTypeId, serviceTrialRecordTypeId, supportingAgreementRecordTypeId, agencyRecognitionRecordTypeId);
            agreementService.reCreateDocuSignRecipients(salesAccountExecutiveIdsToReCreateDocuSignRecipients, agreementPrimaryContactIdsToReCreateDocuSignRecipients,
            agreementSecondaryContactIdsToReCreateDocuSignRecipients,agreementListToReCreateDocuSignRecipients, 
            ndaRecordTypeId, serviceTrialRecordTypeId, supportingAgreementRecordTypeId, agencyRecognitionRecordTypeId, docuSignDefaultReceipts);           
            
            List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> returnDocuSignRecipientsUpdate = null;
            //Docusign Receipts w.r.to Agreement Opportunity Owner
            //agreementOpportunityMap
            returnDocuSignRecipientsUpdate = agreementService.updateDocuSignAEAsOpportunityOwner(docuSignRecipientsAEOpportunity,agreementList,agreementOpportunityMap);
            if(returnDocuSignRecipientsUpdate != null && !returnDocuSignRecipientsUpdate.isEmpty()){
                docuSignRecipientsUpdate.addAll(returnDocuSignRecipientsUpdate);
            }
            //Sales Account Executive
            returnDocuSignRecipientsUpdate = null;
            returnDocuSignRecipientsUpdate = agreementService.updateDocuSignAccountSalesExecutive(docuSignRecipientsAccountExecutive, salesAccountExecutiveMap);
            if(returnDocuSignRecipientsUpdate != null && returnDocuSignRecipientsUpdate.size() > 0){
                docuSignRecipientsUpdate.addAll(returnDocuSignRecipientsUpdate);
            }
            
            //Primary Contact update
            returnDocuSignRecipientsUpdate = null;
            returnDocuSignRecipientsUpdate = agreementService.updateDocuSignAccountContacts(docuSignRecipientsPrimaryContact, agreementPrimaryContactMap);
            if(returnDocuSignRecipientsUpdate != null && returnDocuSignRecipientsUpdate.size() > 0){
                docuSignRecipientsUpdate.addAll(returnDocuSignRecipientsUpdate);
            }
            
            //Secondary Contact update
            returnDocuSignRecipientsUpdate = null;
            returnDocuSignRecipientsUpdate = agreementService.updateDocuSignAccountContacts(docuSignRecipientsSecondaryContact, agreementSecondaryContactMap);
            if(returnDocuSignRecipientsUpdate != null && returnDocuSignRecipientsUpdate.size() > 0){
                docuSignRecipientsUpdate.addAll(returnDocuSignRecipientsUpdate);
            }
            
            if(docuSignRecipientsUpdate.size() > 0){
                update docuSignRecipientsUpdate;
            }
        }
        //End of DIGI-20843 added by Gautam Kumar. Consolidating docusign code
        
        //Copy obligations after variations
        if(variedAgreements.size() > 0){
            agreementService.reparentObjectsForAmendment(variedAgreements);       
        }
        /**if(agreementListForFunds.size()>0){
            agreementService.updateFundRecords(agreementListForFunds);
        }*/
        
        if(agreementsWithSalesAcExecChange.size() > 0){
            agreementService.updateSalesAccountExecutiveOnSchedules(agreementsWithSalesAcExecChange);
        }
        
        if(agreementsWithPriContcChange.size() > 0){
            agreementService.updatePrimaryContactOnSchedules(agreementsWithPriContcChange);
        }
    }
    
    private Map<Id,Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>> getAgreementDocusignRecipients(Map<id,Apttus__APTS_Agreement__c > mapNewAgreement)
    {
        Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c> docuSignMap = null;
        if(agreementDocusignRecipients == null)
        {
            agreementDocusignRecipients = new Map<Id,Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>>();
            for(Apttus_DocuApi__DocuSignDefaultRecipient2__c recipient : [select Id, Apttus_DocuApi__FirstName__c, Apttus_DocuApi__LastName__c,
            Apttus_DocuApi__Email__c, Apttus_DocuApi__EmailTemplateUniqueName__c, Apttus_DocuApi__RoleName__c, 
            RecordTypeId, Apttus_DocuApi__RecipientType__c, Apttus_DocuApi__SigningOrder__c, 
            Apttus_CMDSign__AgreementId__c from Apttus_DocuApi__DocuSignDefaultRecipient2__c 
            where Apttus_CMDSign__AgreementId__c in : mapNewAgreement.keySet()])
            {
                if(agreementDocusignRecipients.get(recipient.Apttus_CMDSign__AgreementId__c) == null)
                {
                    docuSignMap = new Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
                    docuSignMap.put(recipient.Apttus_DocuApi__RoleName__c,recipient);
                    agreementDocusignRecipients.put(recipient.Apttus_CMDSign__AgreementId__c, docuSignMap);
                }
                else
                {
                    docuSignMap = agreementDocusignRecipients.get(recipient.Apttus_CMDSign__AgreementId__c);
                    docuSignMap.put(recipient.Apttus_DocuApi__RoleName__c,recipient);
                    agreementDocusignRecipients.remove(recipient.Apttus_CMDSign__AgreementId__c);
                    agreementDocusignRecipients.put(recipient.Apttus_CMDSign__AgreementId__c, docuSignMap);
                }
                
            }
        }
        
        return agreementDocusignRecipients;
        
        
    }
    public void handleBeforeUpdateEvents(List<Apttus__APTS_Agreement__c> agreementList, Map<id,Apttus__APTS_Agreement__c > mapOldAgreement)
    {
        Transient List<Apttus__APTS_Agreement__c> updatedAgmtList = new List<Apttus__APTS_Agreement__c>();
        Transient Set<id> accountIdSet = new Set<Id>();
        Transient Set<id> contactIdSet = new Set<Id>();
        Transient List<Id> terminateListIDs = new List<Id>();
        Transient List<Apttus__APTS_Agreement__c> updateEffectiveEndDateList = new List<Apttus__APTS_Agreement__c>();
        Transient List<Apttus__APTS_Agreement__c> agreementsSetESignature = new List<Apttus__APTS_Agreement__c>();
        Transient List<Apttus__APTS_Agreement__c> agreementsScheduleNumberUpdated = new List<Apttus__APTS_Agreement__c>();
        Transient List<Apttus__APTS_Agreement__c> updateCompanySignedBy = new List<Apttus__APTS_Agreement__c>();
        Transient List<Apttus__APTS_Agreement__c> updateOtherPartySignedBy = new List<Apttus__APTS_Agreement__c>();
        Transient boolean callPopulateUSer = false;
        Transient boolean callUpdateSignedBy = false;
        Transient Set<Id> variedAgreements = new Set<Id>(); 
        //ruchika start
        Transient List<String> fieldNames = new List<String>();
        Schema.SObjectType objectType  = Schema.getGlobalDescribe().get('Apttus__APTS_Agreement__c');
        Schema.DescribesObjectResult metadata = objectType.getDescribe();
        Schema.DescribeFieldResult fldMetadata;
        Transient List<Apttus__APTS_Agreement__c> childAgmtList = new List<Apttus__APTS_Agreement__c>();
        Transient Set<Id> parentAgreementIds = new Set<Id>();
        Transient Map<Id, Apttus__APTS_Agreement__c> agreementIdSetMinSpendEntriesRollOver = new Map<Id, Apttus__APTS_Agreement__c>();
        
        Transient Map<Id, Date> agreementIdAndContractEndDate = new Map<Id, Date>();
        Transient Map<Id, Id> agreementWithParent = new Map<Id, Id>(); // Added for testing the Case 00215748
        List<Id> agreementIdEDs = new List<Id>();//EDGE-76047
        for (Schema.SObjectField field : metadata.fields.getMap().values()) {
            fldMetadata = field.getDescribe();
            if (fldMetadata!= null && fldMetadata.isUpdateable()) {
                fieldNames.add(fldMetadata.getName());
            }
        } 
        for(Apttus__APTS_Agreement__c agreement: agreementList){
            
            if(agreement.Apttus__Status__c == APTPS_Constants.FULLY_SIGNED_STATUS 
            && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.FULLY_SIGNED_STATUS
            && agreement.Apttus__Version_Number__c > 0
            && (agreement.APTPS_Obligations_Copied_After_Variation__c == null 
            || !agreement.APTPS_Obligations_Copied_After_Variation__c)) 
            {       
                variedAgreements.add(agreement.Id);  
                agreement.APTPS_Obligations_Copied_After_Variation__c = true;
                agreement.APTPS_Validation_on_Fully_Signed__c = true;
            }
            
            Set<String> editableFields = new Set<String>{
                'ED_Filter_Checklist_Required__c', 
                'APTPS_References_to_any_foreign_currency__c',
                /*EDGE-76047 - added field in BSA layout of agreement object*/
                'APTPS_Effective_End_Date__c',
                'Reason_Rolling_Past_Original_End_Date__c', 
                'Reason_for_Rolling_Other__c' , 
                'OwnerId' , 
                'APTPS_Billing_Implementation_Date__c',
                'APTPS_Lump_Sum_Motif_on_Parent__c',
                'APTPS_MOTIF_Total_Amt__c',
                'APTPS_MOTIF_YR_1__c',
                'APTPS_MOTIF_YR_2__c',  
                'APTPS_MOTIF_YR_3__c',
                'APTPS_Sales_Account_Executive__c',					
                'APTPS_MOTIF_YR_4__c',  
                'APTPS_MOTIF_YR_5__c',  
                'APTPS_Funds_on_Agreement__c',
                'APTPS_Is_Eligible_For_CVT_Transfer__c',
                'APTPS_Send_Message_To_CVT_Manually__c'};
                if((agreement.Apttus__Status__c == 'Fully Signed' || agreement.Apttus__Status__c == 'Terminated' || agreement.Apttus__Status__c == 'Activated' ) &&
                agreement.Apttus__Is_System_Update__c == false && agreement.APTPS_Is_Custom_Update__c == false && 
                agreement.Apttus__Status_Category__c == mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c && 
                agreement.Apttus__Status__c == mapOldAgreement.Get(agreement.Id).Apttus__Status__c && 
                agreement.APTPS_Is_Custom_Update__c == mapOldAgreement.Get(agreement.Id).APTPS_Is_Custom_Update__c && !FeatureManagement.checkPermission(APTPS_Constants.preventWorkflowAlerts))
                {
                    if(agreement.Apttus__Status__c == 'Fully Signed' && (agreement.RecordTypeId == serviceTrialRecordTypeId || agreement.RecordTypeId == supportingAgreementRecordTypeId || agreement.RecordTypeId == agencyRecognitionRecordTypeId)){
                        editableFields.add('Apttus__Company_Signed_Date__c');
                        editableFields.add('APTPS_Company_Signed_By__c');
                        for(string fieldName : fieldNames){
                            if(agreement.get(fieldName) != trigger.oldMap.get(agreement.Id).get(fieldName) && editableFields.contains(fieldName) == false && !agreement.APTPS_Validation_on_Fully_Signed__c){
                                agreement.adderror('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available11.');
                                break;
                            }
                        }
                    }
                    else if(agreement.Apttus__Status__c == 'Terminated' || agreement.Apttus__Status__c == 'Activated' ||  (agreement.Apttus__Status__c == 'Fully Signed' && agreement.RecordTypeId != serviceTrialRecordTypeId && agreement.RecordTypeId != supportingAgreementRecordTypeId && agreement.RecordTypeId != agencyRecognitionRecordTypeId )){
                        if(((agreement.Apttus__Status_Category__c == 'In Effect' && agreement.Apttus__Status__c == 'Activated') || agreement.Apttus__Status__c == 'Terminated' || agreement.Apttus__Status__c == 'Fully Signed') && agreement.Auto_Created_by_Basket__c != true )
                        { 
                            
                            system.debug('inside');
                            editableFields.add('Apttus__Termination_Date__c');
                            editableFields.add('Apttus__TerminationComments__c');
                            //editableFields.add('Update_Offshore_Restricted__c');
                            editableFields.add('Apttus__Is_System_Update__c');
                            editableFields.add('APTPS_Off_Shore_Restricted__c');
                            editableFields.add('Offshore_Restricted__c');
                            /*EDGE-61392 - edit "Title" field at Agreement level*/
                            editableFields.add('APTPS_Title__c');
                        }
                        for(string fieldName : fieldNames){
                            if(agreement.get(fieldName) != trigger.oldMap.get(agreement.Id).get(fieldName) && editableFields.contains(fieldName) == false  && !agreement.APTPS_Validation_on_Fully_Signed__c
                            && agreement.APTPS_Lump_Sum_Motif_on_Parent__c == mapOldAgreement.get(agreement.Id).APTPS_Lump_Sum_Motif_on_Parent__c
                            && agreement.APTPS_MOTIF_Total_Amt__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_Total_Amt__c
                            && agreement.APTPS_MOTIF_YR_1__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_YR_1__c
                            && agreement.APTPS_MOTIF_YR_2__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_YR_2__c
                            && agreement.APTPS_MOTIF_YR_3__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_YR_3__c
                            && agreement.APTPS_MOTIF_YR_4__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_YR_4__c
                            && agreement.APTPS_MOTIF_YR_5__c == mapOldAgreement.get(agreement.Id).APTPS_MOTIF_YR_5__c
                            && agreement.APTPS_Funds_on_Agreement__c == mapOldAgreement.get(agreement.Id).APTPS_Funds_on_Agreement__c && agreement.Auto_Created_by_Basket__c != true ){
                                system.debug('inside3'+fieldName);
                                agreement.adderror('This record cannot be edited because it has been either Fully Signed, Activated or Terminated. To make changes to this contract create a new record using Create Variation, Clone, Renew buttons available.');
                                break;
                            }
                        }
                    }
                }
                
                //ruchika end
                
                //repopulates Agreement Start Date based on any changes in Company signed date.
                //if(agreement.Apttus__Company_Signed_Date__c != mapOldAgreement.Get(agreement.Id).Apttus__Company_Signed_Date__c){ // Added for testing the Case 00215748
                    //  agreement.Apttus__Contract_Start_Date__c = agreement.Apttus__Company_Signed_Date__c; // Added for testing the Case 00215748
                    // Calculate term months from effective end date and start date 
                    if(agreement.APTPS_Effective_End_Date__c != null && agreement.Apttus__Contract_Start_Date__c != null && agreement.Apttus__Status_Category__c != 'In Effect' && agreement.Apttus__Status_Category__c != 'Amended'  && agreement.Auto_Created_by_Basket__c != true) // Two conditions added for case 00215748 - Removed for testing // && agreement.Apttus__Status_Category__c != 'In Effect' && agreement.Apttus__Status_Category__c != 'Amended' // Two conditions added for case 00215748 - Removed for testing // && agreement.Apttus__Status_Category__c != 'In Effect' && agreement.Apttus__Status_Category__c != 'Amended'
                    {
                        Integer monthBetween=  (agreement.Apttus__Contract_Start_Date__c).monthsBetween(agreement.Apttus__Contract_End_Date__c) ;
                        agreement.Apttus__Term_Months__c = (Double)monthBetween ;
                    }
                    //} // Added for testing the Case 00215748
                    //to check if Term or Effective end date is filled
                    
                    if(agreement.Apttus__Contract_Start_Date__c != null && agreement.Apttus__Term_Months__c == null 
                    && agreement.Apttus__Contract_End_Date__c != null){
                        agreement.APTPS_Effective_End_Date__c = agreement.Apttus__Contract_End_Date__c;
                    }
                    //When Agmt Start date or Terms months are changed.
                    else if(agreement.Apttus__Contract_Start_Date__c != null  && agreement.Apttus__Term_Months__c != null 
                    && (mapOldAgreement.Get(agreement.Id).Apttus__Contract_Start_Date__c != agreement.Apttus__Contract_Start_Date__c 
                    || mapOldAgreement.Get(agreement.Id).Apttus__Term_Months__c != agreement.Apttus__Term_Months__c)
                    )
                    { 
                        //&& agreement.Apttus__Status_Category__c != APTPS_Constants.IN_EFFECT_STATUS_CATEGORY
                        agreement.Apttus__Contract_End_Date__c = agreement.Apttus__Contract_Start_Date__c.addMonths(agreement.Apttus__Term_Months__c.intValue());
                        if(mapOldAgreement.Get(agreement.Id).APTPS_Effective_End_Date__c == null 
                        || (mapOldAgreement.Get(agreement.Id).APTPS_Effective_End_Date__c == mapOldAgreement.Get(agreement.Id).Apttus__Contract_End_Date__c))
                        { 
                            agreement.APTPS_Effective_End_Date__c = agreement.Apttus__Contract_End_Date__c;
                        }
                    }
                    
                    
                    //When Agmt Start date is changed and term month is null.
                    else if(agreement.Apttus__Contract_Start_Date__c != null && agreement.APTPS_Effective_End_Date__c != null 
                    && (mapOldAgreement.Get(agreement.Id).Apttus__Contract_Start_Date__c != agreement.Apttus__Contract_Start_Date__c)
                    )
                    { 
                        // Calculate term months from effective end date and start date 
                        Integer monthBetween=  (agreement.Apttus__Contract_Start_Date__c).monthsBetween(agreement.APTPS_Effective_End_Date__c) ;
                        agreement.Apttus__Term_Months__c = (Double)monthBetween ;
                        
                    }
                    
                    
                    if(agreement.Apttus__Account__c != null && 
                    agreement.Apttus__Account__c != mapOldAgreement.Get(agreement.Id).Apttus__Account__c
                    && (agreement.APTPS_Commercial_Manager__c == null 
                    || agreement.APTPS_Contract_Manager__c == null
                    || agreement.APTPS_Sales_Account_Executive__c == null
                    || agreement.APTPS_Customer_Primary_Contact__c == null) 
                    && agreement.Apttus__Parent_Agreement__c == null){
                        accountIdSet.add(agreement.Apttus__Account__c);
                        updatedAgmtList.add(agreement);
                        callPopulateUSer = true;
                    }
                    
                    
                    
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && ((agreement.Apttus__Status_Category__c == APTPS_Constants.TERMINATED_STATUS 
                    && agreement.Apttus__Status__c == APTPS_Constants.TERMINATED_STATUS 
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.TERMINATED_STATUS 
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.TERMINATED_STATUS) 
                    || (agreement.Apttus__Status_Category__c == APTPS_Constants.EXPIRED_STATUS 
                    && agreement.Apttus__Status__c == APTPS_Constants.EXPIRED_STATUS  
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.EXPIRED_STATUS 
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.EXPIRED_STATUS))){
                        terminateListIDs.add(agreement.id);
                    }      
                    
                    
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && (agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                    && agreement.Apttus__Status__c == APTPS_Constants.IN_EFFECT_STATUS 
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.IN_EFFECT_STATUS
                    && agreement.Apttus__Parent_Agreement__c == null) 
                    )
                    {
                        updateEffectiveEndDateList.add(agreement);
                        agreementIdEDs.add(agreement.Id);// Condition updated EDGE-76047,19.05  APTPS_ED_Filter_Checklist_Required__c flag to true 
                        if((agreement.RecordTypeId == panelRecordTypeId  && agreement.Apttus__Total_Contract_Value__c > 30000000) || agreement.APTPS_References_to_any_foreign_currency__c == true)
                        {
                            agreement.APTPS_ED_Filter_Checklist_Required__c = true;
                        }
                        agreement.APTPS_Active_Agreements__c = agreement.Apttus__Account__c;
                    }
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && (agreement.Apttus__Status_Category__c == APTPS_Constants.IN_SIGNATURES_STATUS_CATEGORY 
                    && agreement.Apttus__Status__c == APTPS_Constants.OTHER_PARTY_SIGNATURES_STATUS                    
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != APTPS_Constants.OTHER_PARTY_SIGNATURES_STATUS
                    && agreement.APTPS_Sent_By_E_Signature__c) 
                    )
                    {
                        agreement.APTPS_Show_After_E_Signature_Buttons__c = true;
                    }
                    
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && (agreement.APTPS_Schedule_Number_Text__c != mapOldAgreement.Get(agreement.Id).APTPS_Schedule_Number_Text__c)) 
                    {
                        agreementsScheduleNumberUpdated.add(agreement);
                    } 
                    
                    if(agreement.Apttus__Company_Signed_By__c != null && mapOldAgreement.Get(agreement.Id) != null
                    && mapOldAgreement.Get(agreement.Id).Apttus__Company_Signed_By__c != agreement.Apttus__Company_Signed_By__c )
                    {
                        contactIdSet.add(agreement.Apttus__Company_Signed_By__c);
                        updateCompanySignedBy.add(agreement);
                        callUpdateSignedBy = true;
                    }
                    
                    if(agreement.Apttus__Other_Party_Signed_By__c != null && mapOldAgreement.Get(agreement.Id) != null
                    && mapOldAgreement.Get(agreement.Id).Apttus__Other_Party_Signed_By__c != agreement.Apttus__Other_Party_Signed_By__c )
                    {
                        contactIdSet.add(agreement.Apttus__Other_Party_Signed_By__c);
                        updateOtherPartySignedBy.add(agreement);
                        callUpdateSignedBy = true;
                    }
                    
                    
                    
                    if(agreement.Apttus__Status__c == APTPS_Constants.IN_AUTHOR_CONTRACT_STATUS 
                    && agreement.Apttus__Status_Category__c == APTPS_Constants.IN_AUTHORING_STATUS_CATEGORY
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c == 'Fully Signed - Migrated'
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c == 'In Signatures'
                    ) 
                    {                          
                        agreement.Apttus__Status__c = 'Fully Signed - Migrated';
                        agreement.Apttus__Status_Category__c = 'In Signatures';
                    }
                    
                    //Creating the set for the agreements for Minimum Spend entries
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                    && agreement.Apttus__Status__c == 'Rolling'
                    && agreement.Apttus__Parent_Agreement__c != null
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != 'Rolling'
                    && agreement.APTPS_Effective_End_Date_For_Min_Spend__c == null)
                    {
                        agreementIdAndContractEndDate.put(agreement.Id, agreement.Apttus__Contract_End_Date__c);
                        agreementIdSetMinSpendEntriesRollOver.put(agreement.Id, agreement); 
                    }
                    
                    // Added for testing the Case 00215748
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                    && agreement.Apttus__Status__c == 'Rolling'
                    && agreement.Apttus__Parent_Agreement__c == null
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != 'Rolling'
                    )
                    {
                        agreement.APTPS_Rolling_Status__c = 'Rolling';
                    }
                    
                    if(agreement.Apttus__Parent_Agreement__c != null && 
                    (agreement.APTPS_Commercial_Manager__c == null 
                    || agreement.APTPS_Contract_Manager__c == null
                    || agreement.APTPS_Sales_Account_Executive__c == null
                    || agreement.APTPS_Customer_Primary_Contact__c == null
                    || agreement.Apttus__Parent_Agreement__c != mapOldAgreement.Get(agreement.Id).Apttus__Parent_Agreement__c) 
                    )
                    {
                        childAgmtList.add(agreement);
                        if(!parentAgreementIds.contains(agreement.Apttus__Parent_Agreement__c))
                        {
                            parentAgreementIds.add(agreement.Apttus__Parent_Agreement__c);
                        }
                        
                    }
                    
                    // Added for testing the Case 00215748
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && agreement.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY 
                    && agreement.Apttus__Status__c == 'Rolling'
                    && agreement.Apttus__Parent_Agreement__c != null
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c == 'Rolling'
                    && agreement.APTPS_Effective_End_Date__c != mapOldAgreement.Get(agreement.Id).APTPS_Effective_End_Date__c
                    && agreement.APTPS_Effective_End_Date_For_Min_Spend__c < agreement.APTPS_Effective_End_Date__c)
                    {
                        agreementIdAndContractEndDate.put(agreement.Id, agreement.APTPS_Effective_End_Date_For_Min_Spend__c);
                        agreementIdSetMinSpendEntriesRollOver.put(agreement.Id, agreement); 
                    }
                    
                    //Handling Cancel Request
                    if(mapOldAgreement.Get(agreement.Id) != null
                    && agreement.Apttus__Status_Category__c == 'Cancelled'
                    && agreement.Apttus__Status__c == 'Cancelled Request'  
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status_Category__c != 'Cancelled'                  
                    && mapOldAgreement.Get(agreement.Id).Apttus__Status__c != 'Cancelled Request')
                    {
                        if(agreement.Apttus__Version_Number__c > 0) 
                        {                          
                            agreementWithParent.put(agreement.Id, agreement.APTPS_Parent_Agreement_Id__c);
                        }
                    }
                    
                }
                
                
                // Condition updated EDGE-76047,19.05  APTPS_ED_Filter_Checklist_Required__c flag to true for non-std BSA and non-std CSA
                agreementService.updateEDFilterchecklistFlag(agreementList,agreementIdEDs);
                
                agreementService.updateEffectiveEndDatesandMinimumSpend(updateEffectiveEndDateList);
                if(callPopulateUSer)
                {
                    agreementService.populateUserFields(updatedAgmtList, accountIdSet);
                }
                // agreementService.terminateChildAgreements(terminateListIDs);
                agreementService.checkScheduleNumber(agreementsScheduleNumberUpdated);
                
                if(callUpdateSignedBy)
                {
                    agreementService.updateSignedByFields(updateCompanySignedBy, updateOtherPartySignedBy, contactIdSet);
                }
                
                //Copy obligations after variations
                if(variedAgreements.size() > 0)
                {
                    agreementService.copyObligationFromParentAgreement(variedAgreements);       
                }
                
                if(childAgmtList.size() > 0)
                {
                    agreementService.populateUserFieldsFromParent(childAgmtList, parentAgreementIds);
                }
                if(agreementIdSetMinSpendEntriesRollOver.size() > 0)
                {
                    APTPS_AgreementMSEService agreementMSEService = new APTPS_AgreementMSEService();
                    agreementMSEService.createMinimumSpendEntriesAtRollover(agreementIdSetMinSpendEntriesRollOver, agreementIdAndContractEndDate);
                }
                
                
                // Added for testing the Case 00215748
                if(agreementWithParent.size() > 0) 
                {
                    agreementService.reparentChildAgreementToParent(agreementWithParent);
                }  
                
                // US-14746     
                set<String> fieldSetBasket_Controlled = new Set<String>();
                //dynamically get the fields from the field set and then use the same for comparison in the trigger
                for(Schema.FieldSetMember fields :Schema.SObjectType.Apttus__APTS_Agreement__c.fieldSets.getMap().get('Basket_Controlled').getFields()){
                    fieldSetBasket_Controlled.add(fields.getFieldPath());
                }
                System.debug('Basket_Controlled'+fieldSetBasket_Controlled);
                
                for(Apttus__APTS_Agreement__c a: agreementList){
                    system.debug('agrement record:'+a);
                    if(a.Auto_Created_by_Basket__c){
                        set<String> changedFieldSet  = new Set<String>();
                        for(string field: fieldSetBasket_Controlled){
                            if(a.get(field) != trigger.oldMap.get(a.Id).get(field)){
                                changedFieldSet.add(field);//adding fields whose value changed
                            }
                        }
                        if(changedFieldSet.size()>0){
                            System.debug('Basket_Controlled field updated');   
                            a.adderror('This record cannot be edited because it has been generated from basket.');
                        }
                    }
                    
                }
            }    
            
            public void handleBeforeInsertEvents(List<Apttus__APTS_Agreement__c> agreementList)
            {
                Transient List<Apttus__APTS_Agreement__c> childAgmtList = new List<Apttus__APTS_Agreement__c>();
                Transient Set<Id> parentAgreementIds = new Set<Id>();
                
                for(Apttus__APTS_Agreement__c agreement: agreementList)
                {
                    if(agreement.Apttus__Parent_Agreement__c != null && 
                    (agreement.APTPS_Commercial_Manager__c == null 
                    || agreement.APTPS_Contract_Manager__c == null
                    || agreement.APTPS_Sales_Account_Executive__c == null
                    || agreement.APTPS_Customer_Primary_Contact__c == null ) 
                    )
                    {
                        childAgmtList.add(agreement);
                        if(!parentAgreementIds.contains(agreement.Apttus__Parent_Agreement__c))
                        {
                            parentAgreementIds.add(agreement.Apttus__Parent_Agreement__c);
                        }
                        
                    }
                }
                
                
                if(childAgmtList.size()>0)
                {
                    agreementService.populateUserFieldsFromParent(childAgmtList, parentAgreementIds);
                }                 
            }
            public void handleBeforeDeleteEvents(List<Apttus__APTS_Agreement__c> agreementList)
            {
                Map<Id, Id> agreementWithParent = new Map<Id, Id>();  
                for(Apttus__APTS_Agreement__c agreement: agreementList) 
                { 
                    if(agreement.Apttus__Version_Number__c > 0)
                    {                          
                        agreementWithParent.put(agreement.Id, agreement.APTPS_Parent_Agreement_Id__c);
                    }
                    
                }
                if(agreementWithParent.size() > 0) 
                {
                    agreementService.reparentChildAgreementToParent(agreementWithParent);
                }                   
            }
        }
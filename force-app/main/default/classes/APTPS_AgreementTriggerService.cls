/*****************************************************************
@Name: APTPS_AgreementTriggerService
@Author: Shishir Bose
@CreateDate: 14/03/2016 
@Description: This is the service class to handle functionality for Agreement Trigger
@UsedBy: AgreementTriggerHandler 
******************************************************************/ 
public class APTPS_AgreementTriggerService{
    
    /******************************************************************
    @Description:This method copies Obligations records from Template Obligations records associated to the template of type Clause for all the agreement clauses related to the agreement. 
    *******************************************************************/  
    public void copyObligationFromTemplateObligation(Set<Id> agreementIDSet) {      
        
        Transient List<Apttus_SRM__SRMObligation__c> obligationsList;      
        if(!agreementIDSet.isEmpty()){  
            //fetching all the agreement clauses associated to the agreements.                
            List<Apttus__Agreement_Clause__c> agreementClauseList = [SELECT Id,Apttus__Template__c,Apttus__Agreement__c,Apttus__Agreement__r.Apttus__Account__c FROM Apttus__Agreement_Clause__c WHERE Apttus__Agreement__c IN :agreementIDSet];       
            Set<Id> templateIDSet  = new Set<Id>();            
            for(Apttus__Agreement_Clause__c agmtClause : agreementClauseList) {
                //list of all Templates associated to the Agreement clauses.     
                templateIDSet.add(agmtClause.Apttus__Template__c);       
            } 
            //fetching all the Template Obligation master data associated to the Templates.    
            Transient List<Apttus__APTS_Template__c> templateList = [SELECT Id, (SELECT id, APTPS_Description__c, APTPS_SRM_Active__c, APTPS_Acceptance_Criteria__c, APTPS_Accountable1__c, APTPS_Actual__c,  
                                                                           APTPS_Consulted__c, APTPS_Guidance__c, APTPS_Informed__c, APTPS_Article_Sub_Reference__c, APTPS_Comments__c, APTPS_Responsible__r.name,
                                                                           APTPS_Obligation_Frequency__c, APTPS_Sub_Category__c, APTPS_Obligation_Type__c, APTPS_Category__c, APTPS_Payment_Terms__c  
                                                                           FROM Template_Obligations__r) 
                                                              FROM Apttus__APTS_Template__c WHERE Id IN : templateIDSet];       
            Transient Map<Id,Apttus__APTS_Template__c> templateMap = new Map<Id,Apttus__APTS_Template__c>(templateList);      
            Transient List<Apttus_SRM__SRMObligation__c> obligationList = new List<Apttus_SRM__SRMObligation__c>();
            //fetching all existing Obligations associated to the agreement.       
            obligationsList = [SELECT Id,APTPS_Auto_Obligation__c FROM Apttus_SRM__SRMObligation__c  WHERE Apttus_SRM__AgreementId__c IN :agreementIDSet];      
            //checks for all the obligations created by trigger amongst the existing obligations and deletes all those.
            if(obligationsList.size() > 0) {
                List<Apttus_SRM__SRMObligation__c> autoObligationList = new List<Apttus_SRM__SRMObligation__c>();
                for(Apttus_SRM__SRMObligation__c obligation : obligationsList){
                    if(obligation.APTPS_Auto_Obligation__c == true){
                        autoObligationList.add(obligation);
                    }
                }
                if(!autoObligationList.isEmpty()){         
                    APTPS_AgreementTriggerHelper.deleteAutoObligation(autoObligationList);
                }                 
            } 
            //mapping of values from Yemplate obligations to Obligations record.    
            for(Apttus__Agreement_Clause__c agmtClause : agreementClauseList) {       
                if(templateMap.containskey(agmtClause.Apttus__Template__c)) {               
                    for(APTPS_Template_Obligations__c tempObligation : templateMap.get(agmtClause.Apttus__Template__c).Template_Obligations__r) {
                        Apttus_SRM__SRMObligation__c obligation = new Apttus_SRM__SRMObligation__c(); 
                        obligation.Apttus_SRM__Description__c = tempObligation.APTPS_Description__c;                       
                        obligation.Apttus_SRM__Active__c = tempObligation.APTPS_SRM_Active__c;  
                        obligation.Apttus_SRM__AgreementId__c = agmtClause.Apttus__Agreement__c;
                        obligation.APTPS_Agreement_Clause__c = obligation.Apttus_SRM__AgreementClauseId__c = agmtClause.id; //remove one of the Agreement clause fields
                        obligation.APTPS_Customer__c = agmtClause.Apttus__Agreement__r.Apttus__Account__c;     
                        obligation.APTPS_Auto_Obligation__c = true;                        
                        obligation.Apttus_SRM__Accountable__c = tempObligation.APTPS_Accountable1__c;                         
                        obligation.Apttus_SRM__Comments__c = tempObligation.APTPS_Comments__c;  
                        obligation.Apttus_SRM__Consulted__c = tempObligation.APTPS_Consulted__c;         
                        obligation.Apttus_SRM__Guidance__c = tempObligation.APTPS_Guidance__c;   
                        obligation.Apttus_SRM__Informed__c = tempObligation.APTPS_Informed__c;                                                   
                        obligation.Apttus_SRM__Responsible__c = tempObligation.APTPS_Responsible__r.name; 
                        obligation.APTPS_Category__c = tempObligation.APTPS_Category__c;
                        obligation.APTPS_Sub_Category__c = tempObligation.APTPS_Sub_Category__c;
                        obligation.APTPS_Status__c = 'Open';
                        obligation.APTPS_Responsible__c = 'Customer';
                        obligation.APTPS_Obligation_Frequency__c = 'Once-off';
                        obligation.APTPS_Clause_Name__c = 'Test';
                        obligation.APTPS_Approval_Required__c = 'No Approval Required';
                        obligationList.add(obligation);                 
                    }              
                }      
            }  
            //inserts the Obligations   
            if(!obligationList.isEmpty()) {          
                APTPS_AgreementTriggerHelper.insertObligation(obligationList);                   
            } 
        }  
    }
    
    /******************************************************************
    @Description:This method will be triggered on Termination of Agreement which in turn will terminate the associated obligations and delete all of their tasks.
    *******************************************************************/  
    public void terminateObligation(List<Id> listIDs) {
        Transient List<Apttus_SRM__SRMObligation__c> OblgList = new List<Apttus_SRM__SRMObligation__c>(); 
        Transient List<Apttus_SRM__SRMObligation__c> updatedOblgList = new List<Apttus_SRM__SRMObligation__c>(); 
        Transient List<Task> taskList = new List<Task>();     
       
       
        if(listIDs.size()>0 && !listIDs.isEmpty()){
            OblgList = [Select Id, Name, APTPS_Status__c, Apttus_SRM__AgreementId__c, APTPS_Category__c FROM Apttus_SRM__SRMObligation__c WHERE Apttus_SRM__AgreementId__c In : listIDs];   
            
            //changes the status of associated obligations to Terminated.
            if(!OblgList.isEmpty() && OblgList.size()>0){
                for(Apttus_SRM__SRMObligation__c oblgn : OblgList){
                    if(oblgn.APTPS_Category__c == APTPS_Constants.POST_TERMINATION_ACTIVITY_STATUS ){
                        oblgn.APTPS_Status__c = APTPS_Constants.PENDING_STATUS; 
                    }
                    else{
                        oblgn.APTPS_Status__c = APTPS_Constants.TERMINATED_STATUS;
                        updatedOblgList.add(oblgn);
                    }
                }
                APTPS_AgreementTriggerHelper.updateObligation(OblgList); 
                taskList = [Select id, status, WhatId FROM Task WHERE WhatId In : updatedOblgList];
                
                 //deletes all the associated tasks of those obligations.
                if(!taskList.isEmpty() && taskList.size()>0 )
                {
                    APTPS_AgreementTriggerHelper.deleteObTasks(taskList);
                }
            }
           
        }
        
    }
    
    
     public void activateLegacyAgreement(Set<Id> agreementIds)
     {
         if(agreementIds.size() > 0)
         {
             Id batchInstanceId = Database.executeBatch(new APTPS_PerformAgreementActivationBatch(agreementIds), 10);
         }
     }
    
     /*************************************************************************************************************************
     @Name: createMinimumSpendEntries
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method creates minimum spend entries for the schedules
    *************************************************************************************************************************/
    /**public void createMinimumSpendEntries(Set<Id> agreementIds)
    {
       Transient Apttus__APTS_Agreement__c[] childAgreements ;
       Transient List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
       
        //Get Child Agreements for each parent agreement and create minimum spend entries
       
        if(agreementIds.size() > 0)
        {
            childAgreements = [select Id, Name,Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, APTPS_Effective_End_Date_For_Min_Spend__c, (select Id, Name,APTPS_Product_Minimum_Spend__c, APTPS_frequency__c from Apttus__AgreementLineItems__r 
                                                                                                        where APTPS_Product_Minimum_Spend__c!= null and APTPS_frequency__c != null )  
                               from Apttus__APTS_Agreement__c                                                      
                               where Id in : agreementIds and Apttus__Term_Months__c != null];



            if(!childAgreements.isEmpty())
            {
                for(Apttus__APTS_Agreement__c childAgreement: childAgreements)
                {
                    if(childAgreement.Apttus__AgreementLineItems__r != null && childAgreement.Apttus__AgreementLineItems__r.size() > 0)
                    {
                        for(Apttus__AgreementLineItem__c lineItem : childAgreement.Apttus__AgreementLineItems__r)
                        {
                            minimumSpendEntries.addAll(insertMinimumSpendEntries(integer.valueOf(childAgreement.Apttus__Term_Months__c)
                                                                                     , childAgreement.Apttus__Contract_Start_Date__c,lineItem, false));
                        }
                    }

                }
                
                if(minimumSpendEntries.size() > 0)
                {
                    insert minimumSpendEntries;
                }
            }
            
        }
    }**/
    
    /**public void createMinimumSpendEntriesAtRollover(Map<Id,Apttus__APTS_Agreement__c> childAgreementsToBeUpdated,
                                                        Map<Id, Date> agreementIdAndContractEndDate)
    {
       Transient Apttus__APTS_Agreement__c[] childAgreements ;
       Transient List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
       Set<Id> agreementSet = new Set<Id>();
        //Get Child Agreements for each parent agreement and create minimum spend entries
        Set<Id> agreementLineItemsId = new Set<Id>();
        if(childAgreementsToBeUpdated.size() > 0)
        {
            childAgreements = [select Id, Name,Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, APTPS_Effective_End_Date_For_Min_Spend__c, (select Id, Name,APTPS_Product_Minimum_Spend__c, APTPS_frequency__c from Apttus__AgreementLineItems__r 
                                                                                                        where APTPS_Product_Minimum_Spend__c!= null and APTPS_frequency__c != null )  
                               from Apttus__APTS_Agreement__c                                                      
                               where Id in : childAgreementsToBeUpdated.keySet() and Apttus__Term_Months__c != null];



            if(!childAgreements.isEmpty())
            {
                for(Apttus__APTS_Agreement__c childAgreement: childAgreements)
                {
                    if(childAgreement.Apttus__AgreementLineItems__r != null && childAgreement.Apttus__AgreementLineItems__r.size() > 0)
                    {
                        for(Apttus__AgreementLineItem__c lineItem : childAgreement.Apttus__AgreementLineItems__r)
                        {
                            agreementLineItemsId.add(lineItem.Id);
                                minimumSpendEntries.addAll(insertMinimumSpendEntries(3
                                                                                     , agreementIdAndContractEndDate.get(childAgreement.Id),lineItem,true));
                                if(!agreementSet.contains(childAgreement.Id))
                                {
                                    agreementSet.add(childAgreement.Id);
                                }  
                        }
                    }

                }
                
                if(agreementLineItemsId.size() > 0)
                {
                    List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntriesToBeUpdated = new List<APTPS_Minimum_Spend_Entry__c>();
                    
                    for(APTPS_Minimum_Spend_Entry__c entry : [select Id, APTPS_Agreement_Line_Item__c, APTPS_To_be_sent_to_CVT__c from APTPS_Minimum_Spend_Entry__c where APTPS_Agreement_Line_Item__c in : agreementLineItemsId and APTPS_To_be_sent_to_CVT__c = true])
                    {
                        entry.APTPS_To_be_sent_to_CVT__c = false;
                        minimumSpendEntriesToBeUpdated.add(entry);
                    }
                    
                    if(minimumSpendEntriesToBeUpdated.size() > 0)
                    {
                        update minimumSpendEntriesToBeUpdated;
                    }
                }
                if(minimumSpendEntries.size() > 0)
                {
                    insert minimumSpendEntries;
                }
                
                
                if(agreementSet.size() > 0)
                {
                   for(Id agreementId : agreementSet)
                    {
                        if(childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c != null)
                        {   
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c = childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c.addMonths(3);
                        }
                        else
                        {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c =
                                agreementIdAndContractEndDate.get(agreementId).addMonths(3);
                        }
                        
                        
                        //Setting the Rolling and Recurring Rolling Status
                        if(agreementIdAndContractEndDate.get(agreementId) == childAgreementsToBeUpdated.get(agreementId).Apttus__Contract_End_Date__c)
                        {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Rolling_Status__c = 'Rolling';
                        }
                        else
                        {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Rolling_Status__c = 'RecurringRolling';
                        }
                        childAgreementsToBeUpdated.get(agreementId).APTPS_Send_Message_for_Rec_Rolling__c = true;
                    }             
                }
            }
            
        }
    }**/
    
    /**private List<APTPS_Minimum_Spend_Entry__c> insertMinimumSpendEntries(integer term, date contractStartDate,Apttus__AgreementLineItem__c lineItem, boolean isForRolling)
    {
        Transient List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
        Transient List<APTPS_Minimum_Spend_Entry__c> temporary = new List<APTPS_Minimum_Spend_Entry__c>();
        Transient APTPS_Minimum_Spend_Entry__c entry = null;
        Transient integer quarterNumber = 1;
        Transient integer yearNumber = 1;
        Transient string recordName;
        Transient integer monthNumber = 1;
        Transient date dateToBePopulated = contractStartDate;
        TRansient date firstDateForTerm ;
        for(integer index = 0; index < term; index++)
        {
            entry = new APTPS_Minimum_Spend_Entry__c();
            //Add month for each entry
            dateToBePopulated = dateToBePopulated.addMonths(1);
           
            //Handle Frequency "Quarterly"
            if(lineItem.APTPS_frequency__c == 'Quarter')
            {
                //For the last month of term, reset the Minimim Spend Due date               
                if(index !=0 && math.mod((index), 3) == 0)
                {
                     
                    quarterNumber = quarterNumber + 1;
                    monthNumber = 1;
                    
                    dateToBePopulated = dateToBePopulated.addMonths(-1);                    
                    
                    for(APTPS_Minimum_Spend_Entry__c tempData: temporary)
                    {
                        tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
                        minimumSpendEntries.add(tempData);
                    }
                     
                    temporary = new List<APTPS_Minimum_Spend_Entry__c>();
                    dateToBePopulated = dateToBePopulated.addMonths(1);
                   
                }                
                
                //Create Record NAmes Like : Q1M1, Q1M2, Q1M3, Q2M4
                recordName = 'Q' + quarterNumber + 'M' + monthNumber;
            }
            
            //Handle Frequency "Annual"
            if(lineItem.APTPS_frequency__c == 'Annual')
            {
                //For the last month of term, reset the Minimim Spend Due date                     
                if(index !=0 && math.mod((index), 12) == 0)
                {
                    yearNumber = yearNumber + 1;
                    monthNumber = 1;
                    
                    dateToBePopulated = dateToBePopulated.addMonths(-1);
                    
                    
                     for(APTPS_Minimum_Spend_Entry__c tempData: temporary)
                     {
                         tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
                         minimumSpendEntries.add(tempData);
                     }
                    
                    temporary = new List<APTPS_Minimum_Spend_Entry__c>();
                    dateToBePopulated = dateToBePopulated.addMonths(1);
                }
                
                //Create Record NAme: Y1M1, Y1M2,....Y1M12, Y2M1
                recordName = 'Y' + yearNumber + 'M' + monthNumber;
            }
            
            //Handle MOntly frequency 
            if(lineItem.APTPS_frequency__c == 'Month')
            {                         
                //Record NAme as M1,M2..
                recordName = 'M' + monthNumber;
            }
            
            monthNumber = monthNumber + 1;
            entry.Name = recordName;
            entry.APTPS_Agreement_Line_Item__c = lineItem.Id;
            entry.APTPS_Minimum_Spend_Month__c = dateToBePopulated;
            entry.APTPS_Minimum_Spend_obligation_amount__c = lineItem.APTPS_Product_Minimum_Spend__c;
            entry.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
            if(isForRolling)
            {
                entry.APTPS_To_be_sent_to_CVT__c = true;
            }
            else
            {
                entry.APTPS_To_be_sent_to_CVT__c = false;
            }
            temporary.Add(entry);
        }
        
        //If the term is not the exact multiple of the frequency, handle the temporary data
        for(APTPS_Minimum_Spend_Entry__c tempData: temporary)
        {
            //dateToBePopulated = dateToBePopulated.addMonths(-1);
            if(lineItem.APTPS_frequency__c != 'Month')
            {
                tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
            }
            minimumSpendEntries.add(tempData);
        }
        return minimumSpendEntries;
    }**/
    
     /*************************************************************************************************************************
     @Name: reCreateDocuSignRecipients
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method re creates docusign entries when the agreement sub ctaegory is changed which affects the number 
    of docusign recipients
    *************************************************************************************************************************/
    public void reCreateDocuSignRecipients(List<Id> salesAccountExecutiveIds,  List<Id> agreementPrimaryContactIds, 
                                         List<Id> agreementSecondaryContactIds ,List<Apttus__APTS_Agreement__c> agreementList,
                                         Id ndaRecordTypeId, Id serviceTrialRecordTypeId, Id supportingAgreementRecordTypeId,
                                         Id agencyRecognitionRecordTypeId, Map<Id,Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>> agreementDocusignRecipients)
    {
        List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> recipientsToBeDeleted = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c> recipientsOfAgreemnt = null;
        for(Apttus__APTS_Agreement__c agreement: agreementList)
        {
            recipientsOfAgreemnt = new Map<string,Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
            recipientsOfAgreemnt = agreementDocusignRecipients.get(agreement.Id);
            if(recipientsOfAgreemnt != null)
            {
                recipientsToBeDeleted.addAll(recipientsOfAgreemnt.values());
            }
        }
        
        delete recipientsToBeDeleted;
        
        createDocuSignRecipients(salesAccountExecutiveIds, agreementPrimaryContactIds, agreementSecondaryContactIds, agreementList, ndaRecordTypeId, 
                                 serviceTrialRecordTypeId, supportingAgreementRecordTypeId, agencyRecognitionRecordTypeId);
    }
    
     /*************************************************************************************************************************
     @Name: createDocuSignRecipients
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method creates docusign entries for the agreement
    *************************************************************************************************************************/
     public void createDocuSignRecipients(List<Id> salesAccountExecutiveIds,  List<Id> agreementPrimaryContactIds, 
                                         List<Id> agreementSecondaryContactIds ,List<Apttus__APTS_Agreement__c> agreementList,
                                         Id ndaRecordTypeId, Id serviceTrialRecordTypeId, Id supportingAgreementRecordTypeId,
                                         Id agencyRecognitionRecordTypeId)
    {
        if(agreementList.size() == 0)
        {
            return;
        }
        Transient Id emailRecordTypeForDocusignRecipient = Schema.SObjectType.Apttus_DocuApi__DocuSignDefaultRecipient2__c.getRecordTypeInfosByName().get('Email').getRecordTypeId();
        Transient Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignsalesAccountExecutiveReSigner = null;
        Transient Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignsalesAccountExecutive = null;
        Transient Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignPrimaryContact = null;
        Transient Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignSecondaryContact = null;
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docusignRecipients = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        Transient List<Opportunity> Product_Basket_Opportunity_Owner = new List<Opportunity>();
        Transient Map<Id, User> salesAccountExecutives = getUserMapforDocuSign(salesAccountExecutiveIds);
        Transient Map<Id, Contact> agreementPrimaryContacts = GetAgreementContacts(agreementPrimaryContactIds);
        Transient Map<Id, Contact> agreementSecondaryContacts = GetAgreementContacts(agreementSecondaryContactIds);
         Map<Id,Opportunity> opportunityOwner = findByOpportunityOwner(agreementList);

        for(Apttus__APTS_Agreement__c agreement: agreementList) {
            //Do not create any receipients
            if((agreement.RecordTypeId ==  supportingAgreementRecordTypeId && agreement.Apttus__Agreement_Category__c == 'MOU')
               || (agreement.RecordTypeId ==  agencyRecognitionRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Facilities Manager')) {
                continue;
            }
            //Sales Account Executive
            if(agreement.Auto_Created_by_Basket__c == true || agreement.Apttus__Related_Opportunity__c != null) {
                if(opportunityOwner != null && opportunityOwner.get(agreement.Apttus__Related_Opportunity__c) != null){
                    docusignRecipients.add(loadDocuSignReceipts(null,opportunityOwner.get(agreement.Apttus__Related_Opportunity__c).Owner,'DocuSign_for_AE','Signer 1',emailRecordTypeForDocusignRecipient,'Signer',1,agreement.Id));
                }
            } else if(salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c) != null) {
                docusignRecipients.add(loadDocuSignReceipts(null,salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c),'DocuSign_for_AE','Signer 1',emailRecordTypeForDocusignRecipient,'Signer',1,agreement.Id));
            }
            
            //Create just one receipient
             if((agreement.RecordTypeId ==  supportingAgreementRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Revert to OCT')
               || (agreement.RecordTypeId ==  agencyRecognitionRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Optus')) {
                continue;
            }
            
            //Primary Contact
            if(agreementPrimaryContacts.get(agreement.APTPS_Customer_Primary_Contact__c) != null) {
                docusignRecipients.add(loadDocuSignReceipts(agreementPrimaryContacts.get(agreement.APTPS_Customer_Primary_Contact__c),null,'DocuSign_for_Send_to_Customer','Signer 2',emailRecordTypeForDocusignRecipient,'Signer',2,agreement.Id));
            }
            
            //Create just 2 reciepients
            if((agreement.RecordTypeId ==  serviceTrialRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Short Form')
               || (agreement.RecordTypeId ==  supportingAgreementRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Letter of Intent')) {
                continue;
            }

            //Account executuve - Resign -- Changed to Account executive
            if(agreement.RecordTypeId ==  ndaRecordTypeId && agreement.Apttus__Agreement_Category__c == 'Multi-Party') {
                if(agreementSecondaryContacts.get(agreement.APTPS_SecAcnt_Primary_Contact__c) != null){
                    docusignRecipients.add(loadDocuSignReceipts(null,salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c),'DocuSign_for_Send_to_Customer','Signer 3',emailRecordTypeForDocusignRecipient,'Signer',3,agreement.Id));
                }
                if(salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c) != null){
                    docusignRecipients.add(loadDocuSignReceipts(null,salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c),'DocuSign_for_Send_to_Customer','Signer 4',emailRecordTypeForDocusignRecipient,'Signer',4,agreement.Id));
                }
            } else {
                if(salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c) != null){
                    docusignRecipients.add(loadDocuSignReceipts(null,salesAccountExecutives.get(agreement.APTPS_Sales_Account_Executive__c),'DocuSign_for_Send_to_Telstra','Signer 3',emailRecordTypeForDocusignRecipient,'Signer',3,agreement.Id));
                }
            }
        }
        
        if(docusignRecipients.size() > 0){
            insert docusignRecipients;
        }
        return; 
    }
    
    private Map<Id,Opportunity> findByOpportunityOwner(List<Apttus__APTS_Agreement__c> agreementList){
        List<Id> opportunityIds = new List<Id>();
        Map<Id,Opportunity> opportunityMap = null;
        if(agreementList != null){
            for(Apttus__APTS_Agreement__c agreement: agreementList) {
                if(agreement.Apttus__Related_Opportunity__c != null){
                    opportunityIds.add(agreement.Apttus__Related_Opportunity__c);
                }
            }
            opportunityMap = new Map<Id,Opportunity>([SELECT Id, Owner.Id, Owner.FirstName, Owner.LastName, Owner.Email FROM Opportunity where Id in :opportunityIds]);
        }
        return opportunityMap;
    }
    
    private Apttus_DocuApi__DocuSignDefaultRecipient2__c loadDocuSignReceipts(Contact contactInfo, User docuSignReceiptUser, String emailTemplate, String roleName, Id emailRecordType, String receiptType, Integer signOrder, Id agreementId){
        Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignReceipt = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();       
        docuSignReceipt.Apttus_DocuApi__FirstName__c = (contactInfo != null) ? contactInfo.FirstName : docuSignReceiptUser.FirstName;
        docuSignReceipt.Apttus_DocuApi__LastName__c = (contactInfo != null) ? contactInfo.LastName : docuSignReceiptUser.LastName;
        docuSignReceipt.Apttus_DocuApi__Email__c = (contactInfo != null) ? contactInfo.Email : docuSignReceiptUser.Email;
        docuSignReceipt.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplate;
        docuSignReceipt.Apttus_DocuApi__RoleName__c = roleName;
        docuSignReceipt.RecordTypeId = emailRecordType;
        docuSignReceipt.Apttus_DocuApi__RecipientType__c = receiptType;
        docuSignReceipt.Apttus_DocuApi__SigningOrder__c = signOrder;
        docuSignReceipt.Apttus_CMDSign__AgreementId__c = agreementId;
        docuSignReceipt.Apttus_DocuApi__IsTransient__c = false;
        return docuSignReceipt;
    }
    
    private Map<Id, User> getUserMapforDocuSign(List<Id> salesAccountExecutiveIds){
        return (salesAccountExecutiveIds != null && salesAccountExecutiveIds.isEmpty()) ? new Map<Id,User>() : new Map<Id,User>([SELECT Id, LastName, FirstName, Email FROM User where Id in :salesAccountExecutiveIds]);
    }
    
    private Map<Id, Contact> GetAgreementContacts(List<Id> agreementContactIds){
        Transient Map<Id, Contact> agreementContacts = new Map<Id, Contact>();
        if(agreementContactIds.size() > 0){
            for(Contact primaryContact : [select Id, FirstName, LastName, Email from Contact where Id in : agreementContactIds]){
               agreementContacts.put(primaryContact.Id, primaryContact);
            }
        }
        return agreementContacts;
    }
    
    /*************************************************************************************************************************
     @Name: updateDocuSignAccountSalesExecutive
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method updates the Account Sales Executive docusign recipeint if it changes
    *************************************************************************************************************************/
    public List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> updateDocuSignAccountSalesExecutive(List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> agreementDocusignRecipients,
                                                    Map<Id,Id> salesAccountExecutiveMap )
    {
        
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> recipientsToBeUpdated = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        if(agreementDocusignRecipients.size() > 0)
        {
           Map<Id, User> salesAccountExecutives = getUserMapforDocuSign(salesAccountExecutiveMap.values());
           User salesAccountExecutive = null;
           Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient = null;
           
            
           for(Apttus_DocuApi__DocuSignDefaultRecipient2__c recipient : agreementDocusignRecipients)
           {
             salesAccountExecutive = salesAccountExecutives.get(salesAccountExecutiveMap.get(recipient.Apttus_CMDSign__AgreementId__c));
             If(salesAccountExecutive != null){
                 recipient.Apttus_DocuApi__FirstName__c = salesAccountExecutive.FirstName ;
                 recipient.Apttus_DocuApi__LastName__c = salesAccountExecutive.LastName;
                 recipient.Apttus_DocuApi__Email__c = salesAccountExecutive.Email;
                 recipientsToBeUpdated.add(recipient);
             }
           }
        }
        return recipientsToBeUpdated;
    }
    
   
    public List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> updateDocuSignAEAsOpportunityOwner(List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> agreementDocusignRecipients,
                                                    List<Apttus__APTS_Agreement__c> agreementList, Map<Id,Id> accountExecutiveMap){
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> recipientsToBeUpdated = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        if(!agreementDocusignRecipients.isEmpty()){
            Map<Id, Opportunity> agreementOpportunityOwner = findByOpportunityOwner(agreementList);
            for(Apttus_DocuApi__DocuSignDefaultRecipient2__c recipient : agreementDocusignRecipients)
            {
                Opportunity oppOwner = agreementOpportunityOwner.get(accountExecutiveMap.get(recipient.Apttus_CMDSign__AgreementId__c));
                if(!oppOwner.Owner.Email.equalsIgnoreCase(recipient.Apttus_DocuApi__Email__c)){
                    recipient.Apttus_DocuApi__FirstName__c = oppOwner.Owner.FirstName ;
                    recipient.Apttus_DocuApi__LastName__c = oppOwner.Owner.LastName;
                    recipient.Apttus_DocuApi__Email__c = oppOwner.Owner.Email;
                    recipientsToBeUpdated.add(recipient);                    
                }
            }                                       
        }
        return recipientsToBeUpdated;
    }
    
    /*************************************************************************************************************************
     @Name: updateDocuSignAccountContacts
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method updates the Account Primary ans secondary docusign recipeint if it changes
    *************************************************************************************************************************/
    public List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> updateDocuSignAccountContacts(List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> agreementDocusignRecipients,
                                                    Map<Id,Id> agreementContactMap)
    {
        Transient List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> recipientsToBeUpdated = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>(); 
        if(agreementDocusignRecipients.size() > 0)
        {
            
           Map<Id, Contact> agreementContacts =  GetAgreementContacts(agreementContactMap.values());
           Contact agreementContact = null;
           Apttus_DocuApi__DocuSignDefaultRecipient2__c docuSignRecipient = null;
           
            
           for(Apttus_DocuApi__DocuSignDefaultRecipient2__c recipient : agreementDocusignRecipients)
           {
             agreementContact = agreementContacts.get(agreementContactMap.get(recipient.Apttus_CMDSign__AgreementId__c));
             recipient.Apttus_DocuApi__FirstName__c = agreementContact.FirstName;
             recipient.Apttus_DocuApi__LastName__c = agreementContact.LastName;
             recipient.Apttus_DocuApi__Email__c = agreementContact.Email;
               
             recipientsToBeUpdated.add(recipient);
           }
        }
        
        return recipientsToBeUpdated;
        
    }
    
    
    
    /******************************************************************
    @Description:This method populates Sales Account Executive, Contract Manager & Commercial Manager from Account object
    *******************************************************************/  
    public void populateUserFields(List<Apttus__APTS_Agreement__c> agreementList, Set<id> accountIdSet){
        Transient Account[] accounts;
        accounts = [SELECT id,APTPS_Sales_Account_Executive__c,OwnerId, APTPS_Commercial_Manager__r.id, APTPS_Contract_Manager__r.id,(select id,APTPS_Role__c from Contacts)
                                     APTPS_Sales_Account_Executive__c
                                                FROM Account
                                                WHERE id IN : accountIdSet]; 
        
        if(accounts.isEmpty())
        {
            return;
        }
        
        Transient List<Account> accountList = accounts;
        Transient Map<Id,Account> accountMap = new Map<Id,Account>(accountList);    
        system.debug('******>>> '+ accountMap);
        system.debug('******>>>agreementList '+ agreementList);
        for(Apttus__APTS_Agreement__c agreement: agreementList){
            if(accountMap.get(agreement.Apttus__Account__c) != null && accountMap.get(agreement.Apttus__Account__c).APTPS_Commercial_Manager__r.id != null && agreement.APTPS_Commercial_Manager__c == null){
                agreement.APTPS_Commercial_Manager__c = accountMap.get(agreement.Apttus__Account__c).APTPS_Commercial_Manager__r.id; 
            }
            if(accountMap.get(agreement.Apttus__Account__c) != null && accountMap.get(agreement.Apttus__Account__c).APTPS_Contract_Manager__r.id != null && agreement.APTPS_Contract_Manager__c == null){
                agreement.APTPS_Contract_Manager__c = accountMap.get(agreement.Apttus__Account__c).APTPS_Contract_Manager__r.id; 
            }
            
           /* if(accountMap.get(agreement.Apttus__Account__c) != null && accountMap.get(agreement.Apttus__Account__c).APTPS_Sales_Account_Executive__c != null && agreement.APTPS_Sales_Account_Executive__c == null){  */
            if(accountMap.get(agreement.Apttus__Account__c) != null && agreement.APTPS_Sales_Account_Executive__c == null){    
                 system.debug('******>>> inside '+ agreement);
                agreement.APTPS_Sales_Account_Executive__c = accountMap.get(agreement.Apttus__Account__c).OwnerId;
            }
            
            if(accountMap.get(agreement.Apttus__Account__c) != null && accountMap.get(agreement.Apttus__Account__c) != null && agreement.APTPS_Customer_Primary_Contact__c == null){
                Contact[] accountContacts = accountMap.get(agreement.Apttus__Account__c).contacts;
                
                
                if(!accountContacts.isEmpty())
                {
                    for(Contact cnt : accountContacts)
                    {
                        agreement.APTPS_Customer_Primary_Contact__c = cnt.Id;
                        if(cnt.APTPS_Role__c == 'Primary Contact')
                        {
                           break; 
                        }
                    } 
                }
            }
        }   
    }
    
    
    /*************************************************************************************************************************
     @Name: terminateChildAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method terminates the child agreement when the Parent agreement is terminated
    *************************************************************************************************************************/
    public void terminateChildAgreements(List<Id> listIDs)
    {
        Transient Apttus__APTS_Agreement__c[] childAgreements;
        if(listIDs.size()>0 && !listIDs.isEmpty())
         {
             childAgreements = [select Id, Name, Apttus__Status_Category__c, Apttus__Status__c, Apttus__Parent_Agreement__c 
                                from Apttus__APTS_Agreement__c  where Apttus__Parent_Agreement__c In : listIDs];
             
             if(!childAgreements.isEmpty())
                {
                    for(Apttus__APTS_Agreement__c agrmnt : childAgreements)
                    {
                        agrmnt.Apttus__Status_Category__c = APTPS_Constants.TERMINATED_STATUS;
                        agrmnt.Apttus__Status__c = APTPS_Constants.TERMINATED_STATUS;
                    }

                    update childAgreements;
                }
         }
                
    }
    //Modified for EDGE-28691 & EDGE-70438//Updated method for Embedded Derivatives 
     public void updateEffectiveEndDatesandMinimumSpend(List<Apttus__APTS_Agreement__c> agreementList)
     {
        Transient Id saRecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
    
         if(agreementList.size() > 0)
         {
             Decimal minimumSpend = 0 ;
             
             Apttus__APTS_Agreement__c[] childAgreements ;
             for(Apttus__APTS_Agreement__c agreement: agreementList){
                 boolean hasEmbededDerivaticeCriteriahasMeet = false;
                 minimumSpend = 0;
                 //checks all the agreements whose status has changed to Terminated/terminated or Expired/expired.
                 childAgreements = [select Id, APTPS_Effective_End_Date__c,APTPS_Schedule_Minimum_Spend_Rollup__c,Apttus__Agreement_Category__c,Apttus__Total_Contract_Value__c from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: agreement.Id and Apttus__Term_Months__c != null];


                     /*lineItems = [select Id, Name, APTPS_Product_Minimum_Spend__c, APTPS_frequency__c  from Apttus__AgreementLineItem__c 
                                     where APTPS_Product_Minimum_Spend__c != null and APTPS_frequency__c != null and Apttus__AgreementId__c 
                                     in (select Id from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: agreement.Id)]; */

                     if(!childAgreements.isEmpty())
                     {
                                 for(Apttus__APTS_Agreement__c childAgreement: childAgreements)
                                 { 
                                      if(childAgreement.APTPS_Effective_End_Date__c > agreement.APTPS_Effective_End_Date__c)
                                      {
                                         agreement.APTPS_Effective_End_Date__c = childAgreement.APTPS_Effective_End_Date__c;                          
                                      }
                                                 
                                      if(childAgreement.APTPS_Schedule_Minimum_Spend_Rollup__c != null)
                                      { 
                                         minimumSpend = minimumSpend + childAgreement.APTPS_Schedule_Minimum_Spend_Rollup__c;
                                      }
                                      
                                      if(agreement.RecordTypeId == saRecordTypeID && childAgreement.Apttus__Agreement_Category__c == 'Global Services' && childAgreement.Apttus__Total_Contract_Value__c > 10000000)
                                      {
                                         hasEmbededDerivaticeCriteriahasMeet = true;
                                      }
                                }
								if(hasEmbededDerivaticeCriteriahasMeet)
                            	{
                					agreement.APTPS_ED_Filter_Checklist_Required__c = true;
								}

                                 
                         }
                         
                         agreement.APTPS_Total_Agrmnt_Minimum_Spend__c = minimumSpend;
                     }
             
       
         
         
         }
         
         }
     
     /*************************************************************************************************************************
     @Name: updateEDFilterchecklistFlag
     @Author: Abhishek Rao K
     @Created Date: 11/04/2019
     @Descripton: EDGE-76047,19.05  APTPS_ED_Filter_Checklist_Required__c flag to true .This method used to populate the EDfilterchecklist flag based on conditions evaluated
    *************************************************************************************************************************/
    public void updateEDFilterchecklistFlag(List<Apttus__APTS_Agreement__c> agreementList, List<Id> agreementIdEDs)
    {                          
        Map<Id,Apttus__APTS_Agreement__c> aggrClauseListMap = new Map<Id,Apttus__APTS_Agreement__c>([Select Id,Apttus__Total_Contract_Value__c,APTPS_ED_Filter_Checklist_Required__c,(Select Id, APTPS_Non_Standard_Legal_Language__c from R00N50000001os4tEAA__r where APTPS_Non_Standard_Legal_Language__c= true) 
                                                         from Apttus__APTS_Agreement__c WHERE id IN:agreementIdEDs AND (Apttus__Agreement_Category__c = 'Business Services' OR Apttus__Agreement_Category__c = 'Corporate Services Agreement') AND Apttus__Total_Contract_Value__c > 30000000 ]);
         for (Apttus__APTS_Agreement__c aggr: agreementList ){
           if(aggrClauseListMap != null && aggrClauseListMap.get(aggr.Id) != null 
             && !aggrClauseListMap.get(aggr.Id).R00N50000001os4tEAA__r.isEmpty())
             { 
                 aggr.APTPS_ED_Filter_Checklist_Required__c = true;
              }
           if ((aggr.Apttus__Total_Contract_Value__c > 30000000) && (aggr.Apttus__Agreement_Category__c== 'Managed Services')&& (aggr.Apttus__Status__c == 'Activated' && aggr.Apttus__Status_Category__c == 'In Effect')){
                aggr.APTPS_ED_Filter_Checklist_Required__c = true;
            }
           
           if ((aggr.Apttus__Total_Contract_Value__c > 10000000) && (aggr.Apttus__Agreement_Category__c == 'Business Services' || aggr.Apttus__Agreement_Category__c == 'Corporate Services Agreement')&& (aggr.Apttus__Status__c == 'Activated' && aggr.Apttus__Status_Category__c == 'In Effect')) {
                aggr.APTPS_ED_Filter_Checklist_Required__c = true;
            }
                
        }  
        
    }

    
    
    /*************************************************************************************************************************
     @Name: updateChildOwners
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method updates the child agreement owner when the Parent agreement owner is changed
    *************************************************************************************************************************/
    public void updateChildOwners(Map<Id,Id> agreementNewOwnersMap)
    {
         if(agreementNewOwnersMap.size()  > 0 )
         {
             Apttus__APTS_Agreement__c[] childAgreements;
             childAgreements = [select Id, Name, Apttus__Status_Category__c, Apttus__Status__c, Apttus__Parent_Agreement__c 
                                from Apttus__APTS_Agreement__c  where Apttus__Parent_Agreement__c In : agreementNewOwnersMap.keySet()];
             
             if(!childAgreements.isEmpty())
                {
                    for(Apttus__APTS_Agreement__c agrmnt : childAgreements)
                    {
                        agrmnt.OwnerId = agreementNewOwnersMap.get(agrmnt.Apttus__Parent_Agreement__c);
                        agrmnt.APTPS_Is_Custom_Update__c = true;
                    }

                    update childAgreements;
                    for(Apttus__APTS_Agreement__c agmt : childAgreements){
                        agmt.APTPS_Is_Custom_Update__c = false;
                    }
                    update childAgreements;
                }
         }
    }
    
    /*************************************************************************************************************************
     @Name: checkScheduleNumber
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method validates that for one Parent Agreement the schedule number of schedules cannot be same
    *************************************************************************************************************************/
    public void checkScheduleNumber(List<Apttus__APTS_Agreement__c> agreementsScheduleNumberUpdated)
    {
        Transient Set<Id> parentAgreementIds = new Set<Id>();
        Transient Map<Id, List<Apttus__APTS_Agreement__c>> childScheduleMap = new Map<Id, List<Apttus__APTS_Agreement__c>>();
        Transient string errorMessage;
        for(Apttus__APTS_Agreement__c agrmnt : agreementsScheduleNumberUpdated)
        {
            if(agrmnt.Apttus__Parent_Agreement__c != null)
            {
                if(!parentAgreementIds.contains(agrmnt.Apttus__Parent_Agreement__c))
                {
                    parentAgreementIds.add(agrmnt.Apttus__Parent_Agreement__c);
                }
            }
        }
        
        if(parentAgreementIds.size() == 0)
        {
            return;
        }
        
        Transient List<Apttus__APTS_Agreement__c> childSchedules;
        //Start:Niranjan Mehta : EDGE-13251//Updated query-- Added 2 new parameters  //Apttus Added fields for case 00220130   //Apttus Added Condition for case 00220130 
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, APTPS_Schedule_Number_Text__c, Apttus__Parent_Agreement__c, Apttus__Status_Category__c, APTPS_Agreement_Subcategory__c from 
                                                          Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c in : parentAgreementIds])
        {
            if(childScheduleMap.get(agrmnt.Apttus__Parent_Agreement__c) != null)
            {
                childSchedules = childScheduleMap.get(agrmnt.Apttus__Parent_Agreement__c);
                childSchedules.add(agrmnt);
                childScheduleMap.remove(agrmnt.Apttus__Parent_Agreement__c);
                childScheduleMap.put(agrmnt.Apttus__Parent_Agreement__c, childSchedules);
            }
            else
            {
                childSchedules = new List<Apttus__APTS_Agreement__c>();
                childSchedules.add(agrmnt);
                childScheduleMap.put(agrmnt.Apttus__Parent_Agreement__c, childSchedules);
            }
        }
        
        for(Apttus__APTS_Agreement__c agrmnt : agreementsScheduleNumberUpdated)
        {
            if(agrmnt.Apttus__Parent_Agreement__c != null)
            {
                childSchedules = childScheduleMap.get(agrmnt.Apttus__Parent_Agreement__c);
                
                if(childSchedules != null && childSchedules.size() > 0)
                {
                    for(Apttus__APTS_Agreement__c sibAgreemnt : childSchedules)
                    {
                    //Start:Niranjan Mehta : EDGE-13251//Updated if condition--- Added 2 new checks for status category  //Apttus Added Condition for case 00220130  
                     if(sibAgreemnt.Id != agrmnt.Id && sibAgreemnt.APTPS_Schedule_Number_Text__c!= null 
                        && sibAgreemnt.APTPS_Schedule_Number_Text__c.equalsIgnoreCase(agrmnt.APTPS_Schedule_Number_Text__c)
                        && (sibAgreemnt.Apttus__Status_Category__c != 'Cancelled' && sibAgreemnt.Apttus__Status_Category__c != 'Terminated')
                       )
                        {
                            errorMessage = 'Schedule number ' + agrmnt.APTPS_Schedule_Number_Text__c + ' is used by Schdeule ' + sibAgreemnt.Name +'. Please use a different Schedule number.';
                            agrmnt.addError(errorMessage);
                            break;
                        }
                    }
                }
            }
        }
        
    }
    public void updateSignedByFields(List<Apttus__APTS_Agreement__c> updateCompanySignedBy, List<Apttus__APTS_Agreement__c> updateOtherPartySignedBy, Set<Id> contactIdSet)
    {
        Transient List<Contact> contactList = [Select Id, Name from Contact where id In : contactIdSet];
        Transient Map<Id, Contact> contactMap = new Map<Id, Contact>(contactList);
        for(Apttus__APTS_Agreement__c agmt : updateCompanySignedBy){
            agmt.APTPS_Company_Signed_By__c = contactMap.get(agmt.Apttus__Company_Signed_By__c).Name;
            
        }
        for(Apttus__APTS_Agreement__c agmt : updateOtherPartySignedBy){
            agmt.APTPS_Other_Party_Signed_By__c = contactMap.get(agmt.Apttus__Other_Party_Signed_By__c).Name;
            
        }
    }
    
    /*************************************************************************************************************************
     @Name: copyObligationFromParentAgreement
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method copies obligations and tasks from Parent Agreement to the varied agreement, when the varied 
    agreement is in status category ans status "In Signatures" and "Fully Signed" respectively
    *************************************************************************************************************************/
    public void copyObligationFromParentAgreement(Set<Id> variedAgreementIds)
    {
        Map<Id, Id> agreementWithChild = new Map<Id, Id>();               
        
        Apttus__APTS_Related_Agreement__c[] relatedAgreements;
        //Create Maps for future handling
        /*Map<Id, Apttus__APTS_Agreement__c> agrmntMap = new Map<Id, Apttus__APTS_Agreement__c>();
        
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name 
                                                   from Apttus__APTS_Agreement__c where Id in : variedAgreementIds
                                                   ])
        {
            agrmntMap.put(agrmnt.Id, agrmnt);
        }*/
        
        
        
        for(Apttus__APTS_Agreement__c agreement : [select Id, Name,(select Apttus__APTS_Contract_From__c, 
                                                    Apttus__APTS_Contract_To__c, 
                                                    Apttus__APTS_Contract_From__r.Apttus__Version_Number__c
                                                    from R00N50000001Xl0KEAS order by 
                                                    Apttus__APTS_Contract_From__r.Apttus__Version_Number__c desc limit 1) 
                                                   from Apttus__APTS_Agreement__c where Id in : variedAgreementIds
                                                   ])
        {
            relatedAgreements = agreement.R00N50000001Xl0KEAS;              
            if(!relatedAgreements.isEmpty())
            {
                agreementWithChild.put(relatedAgreements[0].Apttus__APTS_Contract_From__c, agreement.Id);
            }
            
        }
        
        List<String> sObjectFields = new List<String>{};
        Schema.SObjectType objectType  = Schema.getGlobalDescribe().get('Apttus_SRM__SRMObligation__c');
        sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
        String allSObjectFieldsQuery = ' ' + sObjectFields.get(0);
        //Get all the obligation fields                
        for (Integer i=1 ; i < sObjectFields.size() ; i++)
        {
            allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
        }
        
        string query = 'Select '+allSObjectFieldsQuery;
        
        string subQuery = ', (Select Id, WhatId from tasks )';
        query = query + subQuery;   
        
        
        Set<Id> agreementIdSet = agreementWithChild.keySet();
        query = query + ' from Apttus_SRM__SRMObligation__c  where Apttus_SRM__AgreementId__c In : agreementIdSet';
        
        List<Apttus_SRM__SRMObligation__c> sobjList = Database.query(query);
        List<Task> tasks = null;
        Map<Id, List<Task>> tasksForObligations = new Map<Id, List<Task>>();
        List<Apttus_SRM__SRMObligation__c> newObligations = new List<Apttus_SRM__SRMObligation__c>();
        Apttus_SRM__SRMObligation__c clonedObligation;        
        //Clone Obligations
        for(Apttus_SRM__SRMObligation__c obligation : sobjList)
        {
            clonedObligation = obligation.clone(false, true, false, false);
            clonedObligation.Apttus_SRM__AgreementId__c = agreementWithChild.get(obligation.Apttus_SRM__AgreementId__c);
            clonedObligation.APTPS_Parent_Obligation_Id__c = obligation.Id;
           
            if(obligation.APTPS_Agreement_Clause__c != null)
            {
                clonedObligation.APTPS_Agreement_Clause__c = null;                
            }
            newObligations.add(clonedObligation);
            
            tasks = obligation.Tasks;
            if(tasks != null && tasks.size() > 0)
            {
                tasksForObligations.put(obligation.Id, tasks);
            }
        }
        
        //Reparenting Tasks
        if(newObligations.size() > 0)
        {
            insert newObligations;
            List<Task> tasksToBeReparented = new List<Task>();            
            for(Apttus_SRM__SRMObligation__c obligation : newObligations)
            {
                if(tasksForObligations.get(obligation.APTPS_Parent_Obligation_Id__c) != null 
                   && tasksForObligations.get(obligation.APTPS_Parent_Obligation_Id__c).size() > 0)
                {
                    for(Task oblTask : tasksForObligations.get(obligation.APTPS_Parent_Obligation_Id__c))
                    {
                        oblTask.WhatId = obligation.Id;
                        tasksToBeReparented.add(oblTask);
                    }
                }
            }
            
            update tasksToBeReparented;
        }
            
        
    }
    
    public void reparentObjectsForAmendment(Set<Id> variedAgreementIds)
    {
        
        Map<Id, Id> agreementWithChild = new Map<Id, Id>();               
        
        Apttus__APTS_Related_Agreement__c[] relatedAgreements;
        Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agreement : [select Id, Name,(select Apttus__APTS_Contract_From__c, 
                                                    Apttus__APTS_Contract_To__c, 
                                                    Apttus__APTS_Contract_From__r.Apttus__Version_Number__c
                                                    from R00N50000001Xl0KEAS order by 
                                                    Apttus__APTS_Contract_From__r.Apttus__Version_Number__c desc limit 1) 
                                                   from Apttus__APTS_Agreement__c where Id in : variedAgreementIds
                                                   ])
        {
            relatedAgreements = agreement.R00N50000001Xl0KEAS;              
            if(!relatedAgreements.isEmpty())
            {
                agreementWithChild.put(relatedAgreements[0].Apttus__APTS_Contract_From__c, agreement.Id);
            }
            
        }
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, APTPS_Validation_on_Fully_Signed__c
                                                   from Apttus__APTS_Agreement__c where Id in : variedAgreementIds
                                                   ])
        {
            agrmnt.APTPS_Validation_on_Fully_Signed__c = false;
            agrmnt.APTPS_Is_Custom_Update__c = true;
            agreementMap.put(agrmnt.Id, agrmnt);
        }
        
        Set<Id> agreementIdSet = agreementWithChild.keySet();
        
        List<Apttus__APTS_Admin__c> variationConfig = [select Id, Name,Apttus__Code__c from Apttus__APTS_Admin__c where Name ='APTS_VariationConfig' Limit 1];
            
        
        if(variationConfig.size() != 0)
        {
            string query;
            String variationConfigXML = variationConfig[0].Apttus__Code__c;
            Dom.Document doc = new Dom.Document();
            doc.load(variationConfigXML);
            
            
         
           //Retrieve the root element for this document.
            Dom.XMLNode variationsConfig = doc.getRootElement();
           
            
            //Reparented Objects
            Dom.XMLNode reparentedObjects = variationsConfig.getChildElement('ReparentedObjects', null);  
            List<sObject> updatedChildSObject = new List<sObject>();         
            for(Dom.XMLNode child : reparentedObjects.getChildElements()) 
            {
                string childObjectApi = child.getChildElement('Name', null).getText();
                string childRelationField = child.getChildElement('RelationField', null).getText();    
                              
                query = 'Select id, '+childRelationField+' from '+childObjectApi+' where '+childRelationField+' In : agreementIdSet';
                
                List<sObject> sobjList1 = Database.query(query);
                
                for(sObject obj : sobjList1)
                {
                    Id originalId = Id.valueOf(string.valueOf(obj.get(childRelationField)));
                    obj.put(childRelationField, agreementWithChild.get(originalId));
                    
                    updatedChildSObject.add(obj);
                }
            }
             
            if(updatedChildSObject.size() > 0)
            {
                update updatedChildSObject;
            }
            
        }
        
        if(agreementMap.size() > 0)
        {
            update agreementMap.values();
        }
        
    }
    public void reparentChildAgreementToParent(Map<Id, Id> agreementWithParent)
    {
        Transient Apttus__APTS_Agreement__c[] childAgreements ;
        Transient List<Apttus__APTS_Agreement__c> childAgreementsToBeUpdate = new List<Apttus__APTS_Agreement__c>();
        Transient Set<Id> parentAgreementIds = new Set<Id>();
       
       childAgreements = [select Id, Name, Apttus__Parent_Agreement__c from Apttus__APTS_Agreement__c
                                                where Apttus__Parent_Agreement__c  in : agreementWithParent.keySet()];


         
        if(!childAgreements.isEmpty())
        {
            for(Apttus__APTS_Agreement__c agrmnt : childAgreements)
            {
                agrmnt.Apttus__Parent_Agreement__c = agreementWithParent.get(agrmnt.Apttus__Parent_Agreement__c);
                agrmnt.APTPS_Is_Custom_Update__c = true;
                childAgreementsToBeUpdate.add(agrmnt);
                if(!parentAgreementIds.contains(agrmnt.Apttus__Parent_Agreement__c))
                {
                    parentAgreementIds.add(agrmnt.Apttus__Parent_Agreement__c);
                }
            }   
        }
        

        if(childAgreementsToBeUpdate.size() > 0)
        {
            update childAgreementsToBeUpdate;
            
            if(parentAgreementIds.size() > 0)
            {
                List<Apttus__APTS_Agreement__c> parentAgreementsToBeUpdate = [select Id, Apttus__Status__c from Apttus__APTS_Agreement__c where Id in : parentAgreementIds];    
                
                for(Apttus__APTS_Agreement__c agrmnt : parentAgreementsToBeUpdate)
                {
                    agrmnt.Apttus__Status__c = APTPS_Constants.IN_EFFECT_STATUS;
                }
                
                update parentAgreementsToBeUpdate;
            }
            
        }
        
    }
    // Code to Update fund start date and expiry date on agreement activation. REFACTORED for APTPS_AgreementOnActivation
    /**public void updateFundRecords(List<Apttus__APTS_Agreement__c> agreementList)
    {
        // map to contain list of fund against agreement id 
        Map<ID,List<Fund__c>> fundDataMap= new Map<ID,List<Fund__c>>();
        List<Fund__c> fundDataListToUpsert= new List<Fund__c>();
        
        // code for fund start and end date
         for(Apttus__APTS_Agreement__c agreement: agreementList)
         {   
            fundDataMap.put(agreement.id,new List<Fund__c>());
         }
         Fund__c[] fundList= [select id ,APTPS_Start_Date__c, APTPS_Expiry_Date__c,Agreement__c from Fund__c  where Agreement__c in :fundDataMap.keySet()];
        
        if(!fundList.isEmpty())
        {       
            for(Fund__c fund: fundList){
                fundDataMap.get(fund.Agreement__c).add(fund);
            } 

            List<Fund__c> fundDataList ;
            for(Apttus__APTS_Agreement__c agreement: agreementList)
            {   
                 fundDataList = fundDataMap.get(agreement.Id);
                 for(Fund__c fundData: fundDataList){
                     if(!agreement.APTPS_Variation__c){
                    fundData.APTPS_Start_Date__c= agreement.Apttus__Contract_Start_Date__c;
                    Date endDate=agreement.Apttus__Contract_End_Date__c;  
                    if(endDate !=null) {
                        fundData.APTPS_Expiry_Date__c = endDate.addDays(30);  
                    }   
                     }
                    fundDataListToUpsert.add(fundData);
                 }
            }
             
             if(fundDataListToUpsert.size() > 0)
             {
                upsert fundDataListToUpsert; 
             }
             
        }       
    }**/
    
    /******************************************************************
    @Description:This method populates Sales Account Executive, Contract Manager & Commercial Manager from Account object
    *******************************************************************/  
    public void populateUserFieldsFromParent(List<Apttus__APTS_Agreement__c> agreementList, Set<id> agreementIdSet){
       
       Transient Map<Id, Apttus__APTS_Agreement__c> parentAgreements = new Map<Id, Apttus__APTS_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agrmnt : [SELECT id, APTPS_Commercial_Manager__c, APTPS_Contract_Manager__c, APTPS_Sales_Account_Executive__c, APTPS_Customer_Primary_Contact__c from Apttus__APTS_Agreement__c where Id in : agreementIdSet])
        {
            parentAgreements.put(agrmnt.Id, agrmnt);
        }
       
        
        if(parentAgreements.size() == 0)
        {
            return;
        }
        
        for(Apttus__APTS_Agreement__c agreement: agreementList)
        {
            agreement.APTPS_Commercial_Manager__c = parentAgreements.get(agreement.Apttus__Parent_Agreement__c).APTPS_Commercial_Manager__c;
            
            agreement.APTPS_Contract_Manager__c = parentAgreements.get(agreement.Apttus__Parent_Agreement__c).APTPS_Contract_Manager__c;
            
          agreement.APTPS_Sales_Account_Executive__c = parentAgreements.get(agreement.Apttus__Parent_Agreement__c).APTPS_Sales_Account_Executive__c;
           
            agreement.APTPS_Customer_Primary_Contact__c = parentAgreements.get(agreement.Apttus__Parent_Agreement__c).APTPS_Customer_Primary_Contact__c;
        }   
    }
    
    public void updateSalesAccountExecutiveOnSchedules(Map<Id, Apttus__APTS_Agreement__c> agreementsMap)
    {
        Transient List<Apttus__APTS_Agreement__c> childAgreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, APTPS_Sales_Account_Executive__c, 
                                                Apttus__Status_Category__c, Apttus__Status__c,                              Apttus__Parent_Agreement__c 
                                                from Apttus__APTS_Agreement__c  
                                                where Apttus__Status__c != 'Activated'
                                                and Apttus__Status__c != 'Fully Signed'
                                                and Apttus__Parent_Agreement__c In : agreementsMap.keySet()])
        {
            agrmnt.APTPS_Sales_Account_Executive__c = agreementsMap.get(agrmnt.Apttus__Parent_Agreement__c).APTPS_Sales_Account_Executive__c;
            
            childAgreementsToBeUpdated.add(agrmnt);
        }
        
        if(childAgreementsToBeUpdated.size() > 0)
        {
            update childAgreementsToBeUpdated;
        }
    }
    
    public void updatePrimaryContactOnSchedules(Map<Id, Apttus__APTS_Agreement__c> agreementsMap)
    {
        Transient List<Apttus__APTS_Agreement__c> childAgreementsToBeUpdated = new List<Apttus__APTS_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, APTPS_Customer_Primary_Contact__c, 
                                                Apttus__Status_Category__c, Apttus__Status__c,                              Apttus__Parent_Agreement__c 
                                                from Apttus__APTS_Agreement__c  
                                                where Apttus__Status__c != 'Activated'
                                                and Apttus__Status__c != 'Fully Signed'
                                                and Apttus__Parent_Agreement__c In : agreementsMap.keySet()])
        {
            agrmnt.APTPS_Customer_Primary_Contact__c = agreementsMap.get(agrmnt.Apttus__Parent_Agreement__c).APTPS_Customer_Primary_Contact__c;
            
            childAgreementsToBeUpdated.add(agrmnt);
        }
        
        if(childAgreementsToBeUpdated.size() > 0)
        {
            update childAgreementsToBeUpdated;
        }
    }
    /**public void updateAgreementBasketStage(string basketId,string StatusCategory,string Status)
    {
        cscfga__product_basket__c prodBas = [Select id,csordtelcoa__Basket_Stage__c from cscfga__product_basket__c where id =:basketId];
        if(prodBas.csordtelcoa__Basket_Stage__c.equalsIgnoreCase(CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c))
        {
            String queryStr = 'SELECT DeveloperName,Label FROM CALMS_Contract_Status_Category__mdt';
            List<CALMS_Contract_Status_Category__mdt> statusCatRecList = Database.query(queryStr);
            
            queryStr = 'SELECT DeveloperName,Label FROM CALMS_Contract_Status__mdt';
            List<CALMS_Contract_Status__mdt> statusRecList = Database.query(queryStr);
            
            for (CALMS_Contract_Status_Category__mdt statusCatRec : statusCatRecList) {
                for (CALMS_Contract_Status__mdt statusRec : statusRecList) 
                { 
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('Request') && (statusRec.DeveloperName.equalsIgnoreCase('In_Amendment')
                                                                                                                                                                                     || statusRec.DeveloperName.equalsIgnoreCase('Request') || statusRec.DeveloperName.equalsIgnoreCase('Request_Approval') || statusRec.DeveloperName.equalsIgnoreCase('Submit_Request')
                                                                                                                                                                                    ))
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Authoring') && (statusRec.DeveloperName.equalsIgnoreCase('Author_Contract')
                                                                                                                                                                                          || statusRec.DeveloperName.equalsIgnoreCase('Internal_Review') || statusRec.DeveloperName.equalsIgnoreCase('Language_Approval') || statusRec.DeveloperName.equalsIgnoreCase('Language_Approved')
                                                                                                                                                                                          || statusRec.DeveloperName.equalsIgnoreCase('Other_Party_Review') || statusRec.DeveloperName.equalsIgnoreCase('Penidng_Approvals') || statusRec.DeveloperName.equalsIgnoreCase('Signature_Declined') 
                                                                                                                                                                                          || statusRec.DeveloperName.equalsIgnoreCase('Superseded') || statusRec.DeveloperName.equalsIgnoreCase('In_billing_Review') ))
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Signatures') && statusRec.DeveloperName.equalsIgnoreCase('Fully_signed')) 
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c;             
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Signatures') && (statusRec.DeveloperName.equalsIgnoreCase('Internal_Signatures')
                                                                                                                                                                                           || statusRec.DeveloperName.equalsIgnoreCase('Other_Party_Signatures') || statusRec.DeveloperName.equalsIgnoreCase('Ready_For_Signatures') )) 
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractInitiate').Enrichment_Basket_Stage__c;             
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Signatures') && statusRec.DeveloperName.equalsIgnoreCase('Signature_Declined'))
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractRejected').Enrichment_Basket_Stage__c;
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Effect') && statusRec.DeveloperName.equalsIgnoreCase('Activated'))
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c;     
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('In_Filing') && (statusRec.DeveloperName.equalsIgnoreCase('Fully_signed_Migrated') 
                                                                                                                                                                                       || statusRec.DeveloperName.equalsIgnoreCase('To_Be_Activated') ))
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractAccepted').Enrichment_Basket_Stage__c;     
                    
                    if(StatusCategory.equalsIgnoreCase(statusCatRec.Label) && Status.equalsIgnoreCase(statusRec.Label) && statusCatRec.DeveloperName.equalsIgnoreCase('Cancelled') && statusRec.DeveloperName.equalsIgnoreCase('Cancelled_request'))
                        
                        prodBas.csordtelcoa__Basket_Stage__c =  CustomConfigurationOptions__c.getValues('ContractRejected').Enrichment_Basket_Stage__c;
                    
                }
            }   
            
            update prodBas;
        }
    }**/
}
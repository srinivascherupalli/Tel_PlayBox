public with sharing class APTPS_AgreementMSEService {

    private List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = null;

    public APTPS_AgreementMSEService() {
        minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
    }

    public void createMSERecords(Set<Id> agreementIds){
        List<Apttus__APTS_Agreement__c> agreementsWithALI = loadAgreementLineItems(agreementIds);
        for(Apttus__APTS_Agreement__c agreement : agreementsWithALI){
            if(agreement.Apttus__AgreementLineItems__r != null){
                for(Apttus__AgreementLineItem__c lineItem : agreement.Apttus__AgreementLineItems__r){
                    minimumSpendEntries.addAll(insertMinimumSpendEntries(Integer.valueOf(agreement.Apttus__Term_Months__c),
                                                                        agreement.Apttus__Contract_Start_Date__c,lineItem, false));
                }
            }
        }
        if(!minimumSpendEntries.isEmpty()){
            insert minimumSpendEntries;
        }
    }

    public void createMinimumSpendEntriesAtRollover(Map<Id,Apttus__APTS_Agreement__c> childAgreementsToBeUpdated,
                                                        Map<Id, Date> agreementIdAndContractEndDate) {
        Transient Apttus__APTS_Agreement__c[] childAgreements ;
        Transient List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
        Set<Id> agreementSet = new Set<Id>();
        //Get Child Agreements for each parent agreement and create minimum spend entries
        Set<Id> agreementLineItemsId = new Set<Id>();
        if(childAgreementsToBeUpdated.size() > 0) {
            childAgreements = loadAgreementLineItems(childAgreementsToBeUpdated.keySet());
            if(!childAgreements.isEmpty()) {
                for(Apttus__APTS_Agreement__c childAgreement: childAgreements) {
                    if(childAgreement.Apttus__AgreementLineItems__r != null) {
                        for(Apttus__AgreementLineItem__c lineItem : childAgreement.Apttus__AgreementLineItems__r) {
                            agreementLineItemsId.add(lineItem.Id);
                                minimumSpendEntries.addAll(insertMinimumSpendEntries(3,
                                            agreementIdAndContractEndDate.get(childAgreement.Id),lineItem,true));
                                if(!agreementSet.contains(childAgreement.Id)){
                                    agreementSet.add(childAgreement.Id);
                                }
                        }
                    }
                }
                if(agreementLineItemsId.size() > 0){
                    List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntriesToBeUpdated = new List<APTPS_Minimum_Spend_Entry__c>();
                    for(APTPS_Minimum_Spend_Entry__c entry : [select Id, APTPS_Agreement_Line_Item__c, APTPS_To_be_sent_to_CVT__c from APTPS_Minimum_Spend_Entry__c where APTPS_Agreement_Line_Item__c in : agreementLineItemsId and APTPS_To_be_sent_to_CVT__c = true])
                    {
                        entry.APTPS_To_be_sent_to_CVT__c = false;
                        minimumSpendEntriesToBeUpdated.add(entry);
                    }
                    if(minimumSpendEntriesToBeUpdated.size() > 0) {
                        update minimumSpendEntriesToBeUpdated;
                    }
                }
                if(minimumSpendEntries.size() > 0) {
                    insert minimumSpendEntries;
                }
                
                
                if(agreementSet.size() > 0) {
                   for(Id agreementId : agreementSet) {
                        if(childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c != null)
                        {   
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c = childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c.addMonths(3);
                        } else {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Effective_End_Date_For_Min_Spend__c =
                                agreementIdAndContractEndDate.get(agreementId).addMonths(3);
                        }
                        //Setting the Rolling and Recurring Rolling Status
                        if(agreementIdAndContractEndDate.get(agreementId) == childAgreementsToBeUpdated.get(agreementId).Apttus__Contract_End_Date__c) {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Rolling_Status__c = 'Rolling';
                        } else {
                            childAgreementsToBeUpdated.get(agreementId).APTPS_Rolling_Status__c = 'RecurringRolling';
                        }
                        childAgreementsToBeUpdated.get(agreementId).APTPS_Send_Message_for_Rec_Rolling__c = true;
                    }             
                }
            }
        }
    }

    private List<Apttus__APTS_Agreement__c> loadAgreementLineItems(Set<Id> agreementIds){
        return [select Id, Name,Apttus__Contract_Start_Date__c, Apttus__Term_Months__c, APTPS_Effective_End_Date_For_Min_Spend__c,
                        (select Id, Name,APTPS_Product_Minimum_Spend__c, APTPS_frequency__c from Apttus__AgreementLineItems__r 
                            where APTPS_Product_Minimum_Spend__c!= null and APTPS_frequency__c != null)  
                    from Apttus__APTS_Agreement__c                                                      
                    where Id in : agreementIds and Apttus__Term_Months__c != null];
    }

    private List<APTPS_Minimum_Spend_Entry__c> insertMinimumSpendEntries(Integer term, Date contractStartDate, 
                                                            Apttus__AgreementLineItem__c lineItem, boolean isForRolling){
        Transient List<APTPS_Minimum_Spend_Entry__c> minimumSpendEntries = new List<APTPS_Minimum_Spend_Entry__c>();
        Transient List<APTPS_Minimum_Spend_Entry__c> temporary = new List<APTPS_Minimum_Spend_Entry__c>();
        Transient Integer quarterNumber = 1;
        Transient Integer yearNumber = 1;
        Transient string recordName;
        Transient Integer monthNumber = 1;
        Transient Date dateToBePopulated = contractStartDate;
        TRansient Date firstDateForTerm ;
        for(Integer index = 0; index < term; index++) {
            APTPS_Minimum_Spend_Entry__c entry = new APTPS_Minimum_Spend_Entry__c();
            //Add month for each entry
            dateToBePopulated = dateToBePopulated.addMonths(1);
            switch on lineItem.APTPS_frequency__c {
                when 'Quarter'{
                    //For the last month of term, reset the Minimim Spend Due date               
                    if(index !=0 && math.mod((index), 3) == 0){
                        quarterNumber = quarterNumber + 1;
                        monthNumber = 1;
                        dateToBePopulated = dateToBePopulated.addMonths(-1);                    
                        for(APTPS_Minimum_Spend_Entry__c tempData: temporary) {
                            tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
                            minimumSpendEntries.add(tempData);
                        }
                        temporary = new List<APTPS_Minimum_Spend_Entry__c>();
                        dateToBePopulated = dateToBePopulated.addMonths(1);
                    }                
                    //Create Record NAmes Like : Q1M1, Q1M2, Q1M3, Q2M4
                    recordName = 'Q' + quarterNumber + 'M' + monthNumber;    
                }
                when 'Annual' {
                    //For the last month of term, reset the Minimim Spend Due date                     
                    if(index !=0 && math.mod((index), 12) == 0) {
                        yearNumber = yearNumber + 1;
                        monthNumber = 1;
                        dateToBePopulated = dateToBePopulated.addMonths(-1);
                        for(APTPS_Minimum_Spend_Entry__c tempData: temporary) {
                            tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
                            minimumSpendEntries.add(tempData);
                        }
                        temporary = new List<APTPS_Minimum_Spend_Entry__c>();
                        dateToBePopulated = dateToBePopulated.addMonths(1);
                    }
                    //Create Record NAme: Y1M1, Y1M2,....Y1M12, Y2M1
                    recordName = 'Y' + yearNumber + 'M' + monthNumber;    
                }
                when 'Month' {
                    //Record NAme as M1,M2..
                    recordName = 'M' + monthNumber;
                }
            }
            monthNumber = monthNumber + 1;
            entry.Name = recordName;
            entry.APTPS_Agreement_Line_Item__c = lineItem.Id;
            entry.APTPS_Minimum_Spend_Month__c = dateToBePopulated;
            entry.APTPS_Minimum_Spend_obligation_amount__c = lineItem.APTPS_Product_Minimum_Spend__c;
            entry.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
            entry.APTPS_To_be_sent_to_CVT__c = isForRolling;
            temporary.Add(entry);
        }
        
        //If the term is not the exact multiple of the frequency, handle the temporary data
        for(APTPS_Minimum_Spend_Entry__c tempData: temporary){
            //dateToBePopulated = dateToBePopulated.addMonths(-1);
            if(lineItem.APTPS_frequency__c != 'Month') {
                tempData.APTPS_Minimum_Spend_Due_Date__c = dateToBePopulated.toStartOfMonth();
            }
            minimumSpendEntries.add(tempData);
        }
        return minimumSpendEntries;
    }

}
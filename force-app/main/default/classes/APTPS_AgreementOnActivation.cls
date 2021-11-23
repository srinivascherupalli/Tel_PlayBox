/**
 * @author : ChandrakanthReddy Badvel.
 * @JIRA : EDGE-93285
 * @description : Operations to be performed when User activate the Agreement.
 * List of Operations : 1. Create Minimum Spend Entry records
 *                      2. Update Fund Start date and Expiry Date from Agreement records when Fund Status is Pending Activation.
 *                      3. Create set of obligations records when the agreement is activated
 */
public with sharing class APTPS_AgreementOnActivation implements APTPS_IAgreementService{

    private static Boolean runOnce = true;
    private Set<Id> updateFundOnAgreementActivation = null;
    private Set<Id> minimumSpendEntry = null;
    private Map<Id,Apttus__APTS_Agreement__c> newAgreementMap = null;
    private Map<Id,Apttus__APTS_Agreement__c> oldAgreementMap = null;
    private Set<Id> activatedAgreementIds = null;   

    public APTPS_AgreementOnActivation(Map<Id,Apttus__APTS_Agreement__c> newAgreementMap, Map<Id,Apttus__APTS_Agreement__c> oldAgreementMap){
        minimumSpendEntry = new Set<Id>();
        this.newAgreementMap = newAgreementMap;
        this.oldAgreementMap = oldAgreementMap;
        updateFundOnAgreementActivation = new Set<Id>();
        activatedAgreementIds = new Set<Id>();
    }

    /**
     * Filter Agreement records which are Activated.
     */
    public void execute(){
        for(Id agreementId: newAgreementMap.keySet()){
            if(oldAgreementMap.get(agreementId) != null
                && (newAgreementMap.get(agreementId).Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY
                && newAgreementMap.get(agreementId).Apttus__Status__c == APTPS_Constants.IN_EFFECT_STATUS
                && oldAgreementMap.get(agreementId).Apttus__Status_Category__c != APTPS_Constants.IN_EFFECT_STATUS_CATEGORY
                && oldAgreementMap.get(agreementId).Apttus__Status__c != APTPS_Constants.IN_EFFECT_STATUS)){
                    if(newAgreementMap.get(agreementId).Apttus__Parent_Agreement__c != null){
                        minimumSpendEntry.add(agreementId);
                    }
                    if(newAgreementMap.get(agreementId).APTPS_Auto_Obligation_Creation__c == APTPS_Constants.CONST_YES) {
                        activatedAgreementIds.add(agreementId);
                    }
                    updateFundOnAgreementActivation.add(agreementId);
                    
                }
        }
    }

    /**
     * Commit transactions. Minimum Spend Entry and Fund Records.
     */
    public void commitTransactions(){
        if(runOnce){
            runOnce = false;
            APTPS_AgreementMSEService agreementMSEService = new APTPS_AgreementMSEService();
            agreementMSEService.createMSERecords(minimumSpendEntry);
            if(!updateFundOnAgreementActivation.isEmpty()){
                updateFundOnAgreementActivation();
            }
            if(!activatedAgreementIds.isEmpty()) {
                createObligationsOnActivation();
            }
        }
    }
    

    /**
     * Update Start date and End date on Agreement activation.
     */
    private void updateFundOnAgreementActivation(){
        List<Fund__c> updateFundStartAndEndDate = new List<Fund__c>();
        for(Fund__c fund :[SELECT Id,APTPS_Start_Date__c,APTPS_Expiry_Date__c,Agreement__c,APTPS_Fund_Status__c FROM Fund__c
                                WHERE Agreement__c IN :updateFundOnAgreementActivation]){
            Apttus__APTS_Agreement__c agreement = newAgreementMap.get(fund.Agreement__c);
            if(agreement.APTPS_Variation__c && fund.APTPS_Fund_Status__c != 'Active'){
                fund.APTPS_Start_Date__c = (fund.APTPS_Start_Date__c == NULL) ?  agreement.Apttus__Contract_Start_Date__c : fund.APTPS_Start_Date__c;
                fund.APTPS_Expiry_Date__c = (agreement.Apttus__Contract_End_Date__c !=null && fund.APTPS_Expiry_Date__c == NULL) ? agreement.Apttus__Contract_End_Date__c.addDays(30) : fund.APTPS_Expiry_Date__c;
            } else if(!agreement.APTPS_Variation__c){
                fund.APTPS_Start_Date__c = agreement.Apttus__Contract_Start_Date__c;
                if(agreement.Apttus__Contract_End_Date__c !=null) {
                    fund.APTPS_Expiry_Date__c = agreement.Apttus__Contract_End_Date__c.addDays(30);
                }
            }
            updateFundStartAndEndDate.add(fund);
        }
        if(!updateFundStartAndEndDate.isEmpty()){
            upsert updateFundStartAndEndDate;
        }
    }
    
    /**
     * @Author: Apttus
     * JIRA: EDGE-56126
     * @description: Create set of obligations records when the agreement is activated
     * The data will comes from the Master Obligation based on the clause names
     * @param: set<Id> agreementsIds
     * @return: void
     */

    public void createObligationsOnActivation() {
        
        Map<Id,Set<String>> clauseNamesWrtAgreementIds                       = new Map<Id,Set<String>>();
        Set<String> allClauseNamesSet                                        = new Set<String>();
        Map<String,List<APTPS_Master_Obligation__c>> masterObligationWrtClauseName = new Map<String,List<APTPS_Master_Obligation__c>>();
        List<Apttus_SRM__SRMObligation__c> obligationsNew                    = new List<Apttus_SRM__SRMObligation__c>();
        List<Schema.FieldSetMember> obligationFields                         = SObjectType.APTPS_Master_Obligation__c.fieldSets.APTPS_ObligationFieldsToCopy.getFields();
        String queryStr                                                      = 'SELECT ';
        String apiName                                                        = '';

        for(Apttus__Agreement_Clause__c clauseSO : [SELECT Apttus__Clause__c,Apttus__Agreement__c
                                                    FROM Apttus__Agreement_Clause__c
                                                    WHERE Apttus__Agreement__c IN : activatedAgreementIds
                                                    AND Apttus__Clause__c != NULL]) {

            if(clauseNamesWrtAgreementIds.containsKey(clauseSO.Apttus__Agreement__c)){
                clauseNamesWrtAgreementIds.get(clauseSO.Apttus__Agreement__c).add(clauseSO.Apttus__Clause__c.toUpperCase());
            }  else {
                clauseNamesWrtAgreementIds.put(clauseSO.Apttus__Agreement__c,new Set<String>{clauseSO.Apttus__Clause__c.toUpperCase()});
            }
            allClauseNamesSet.add(clauseSO.Apttus__Clause__c.toUpperCase());
        }

        for(Schema.FieldSetMember fieldAPI : obligationFields){
            queryStr += fieldAPI.getFieldPath() + ', ';
        }

        queryStr += 'Id FROM APTPS_Master_Obligation__c WHERE APTPS_Clause_Name__c IN : allClauseNamesSet';

        for(APTPS_Master_Obligation__c masterObligation : Database.query(queryStr)) {
            if(!masterObligationWrtClauseName.containsKey(masterObligation.APTPS_Clause_Name__c.toUpperCase())){
                masterObligationWrtClauseName.put(masterObligation.APTPS_Clause_Name__c.toUpperCase(), new List<APTPS_Master_Obligation__c>{masterObligation});
            } else {
                masterObligationWrtClauseName.get(masterObligation.APTPS_Clause_Name__c.toUpperCase()).add(masterObligation);
            }
        }

        for(Id agreementId : activatedAgreementIds) {

            for(String clauseName : clauseNamesWrtAgreementIds.get(agreementId)) {

                if(masterObligationWrtClauseName.containsKey(clauseName)) {

                    for(APTPS_Master_Obligation__c masterObligationSO : masterObligationWrtClauseName.get(clauseName)) {

                        Apttus_SRM__SRMObligation__c obligationSO = new Apttus_SRM__SRMObligation__c();
                        obligationSO.Apttus_SRM__AgreementId__c = agreementId;

                        for(Schema.FieldSetMember fieldAPI :  obligationFields) {

                            apiName = fieldAPI.getFieldPath();
                            obligationSO.put(apiName,masterObligationSO.get(apiName));
                        }
                        obligationsNew.add(obligationSO);
                    }
                }
            }
        }

        if(obligationsNew.size()>0) {
            try {
                insert obligationsNew;
            }
            catch(DmlException e) {
                System.debug('error occured while creating obligation records. Message: ' + e.getMessage());
            }
        }
            
    }

}
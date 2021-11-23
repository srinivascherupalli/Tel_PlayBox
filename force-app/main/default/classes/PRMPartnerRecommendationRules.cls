/*
* Version     Author                         Last Modified Date      Description
* v1.0        Vivian Charlie (Team Hawaii)   24 Aug 2020             P2OB-5498 : Find Lead Partner Recommendations based on accreditation and state coverage

* v1.1        Vivian Charlie (Team Hawaii)   30 Oct 2020             P2OB-6781 : Domain mapping changes

*/
public with sharing class PRMPartnerRecommendationRules {
    @auraEnabled public list<PartnerResults> lstRecommendedPartners;
    
    // Find recommended partners based on partner state and accreditation
    @AuraEnabled
    public static list <PartnerResults> findRecommendation(String leadId) {
        system.debug('current leadId********'+leadId);
        list<PartnerResults> PartnerResultslist = new list<PartnerResults>();
        String PrimaryDomain;
        String AccreditationField;
        String targetPartner;
        
        // fetch current lead details
        map<Id,Lead> mapLead = new map<id,Lead>([Select Id, Primary_Domain__c, PartnerAccountId, Customer_Name__c, Customer_Name__r.BillingState from Lead where Id =: leadId]);
        
        // if domain is populated check for recommended partners
        if(mapLead.ContainsKey(leadId) && mapLead.get(leadId).Primary_Domain__c != null) {
            PrimaryDomain = mapLead.get(leadId).Primary_Domain__c ;
            targetPartner = mapLead.get(leadId).PartnerAccountId;
            system.debug('findRecommedation *****'+PrimaryDomain );
            // fetch domain -> accreditation mapping
            list <Lead_Domain_Partner_Accreditation__mdt> mappingList = [select id, Accreditation_Field__c, Accreditation_Status__c, Lead_Domain__c FROM Lead_Domain_Partner_Accreditation__mdt WHERE Lead_Domain__c =: PrimaryDomain];
            
            /*state should not be null for recommended partners */
            if (mappingList.size() > 0 && mapLead.get(leadId).Customer_Name__c != null 
            && mapLead.get(leadId).Customer_Name__r.Billingstate!= null) {
                String stateCoverage = mapLead.get(leadId).Customer_Name__r.Billingstate;
                // invoke recommended partners logic
                PartnerResultslist = returnRecommendedPartners(leadId,mappingList[0].Accreditation_Status__c,mappingList[0].Accreditation_Field__c,stateCoverage,targetPartner);
            } // else portion to be added
        }
        system.debug('PartnerResultslist*****'+PartnerResultslist);
        return PartnerResultslist;
    }
    
    public static list <PartnerResults> returnRecommendedPartners(String recordId, String accreditationStatus, String accreditationField, String stateCoverage, String targetPartner){
        list<PartnerResults> PartnerResultslist = new list<PartnerResults>();
        Logger2 logger = Logger2.getLogger('PRMPartnerRecommendationRules.returnRecommendedPartners');
        try{
            list <Account> AccountList = new list <Account>();
            String statusActive = String.escapeSingleQuotes(PRMConstants.STATUS_ACTIVE);
            list <sortingwrapperRecomm> sortingwrapperRecommlist = new list <sortingwrapperRecomm> ();
            map<string,sortingwrapperRecomm> sortingwrapperRecommmap= new map<string,sortingwrapperRecomm>();
            list <sortingwrapperRecomm> sortingwrapperRecommlistsliced = new list <sortingwrapperRecomm> ();
            
            list<string> AccridationList = String.escapeSingleQuotes(accreditationStatus).split(','); // mappingList[0].Accreditation_Status__c.split(',');
            AccreditationField = accreditationField; // mappingList[0].Accreditation_Field__c;

            String query = 'SELECT Id, Name, State_Coverage__c, Customer_Trading_Name__c, Overall_Accreditation__c, Cloud_Accreditation__c,Collaboration_Accreditation__c,Data_Security_Accreditation__c,Mobility_Accreditation__c,Services_Accreditation__c,Security_Accreditation__c,Users_on_Account__c FROM Account WHERE ' + String.escapeSingleQuotes(AccreditationField) + ' in :AccridationList AND Account_Status__c=:statusActive AND State_Coverage__c INCLUDES(\''+String.escapeSingleQuotes(stateCoverage)+'\')';

            system.debug('query' + query);
            AccountList = Database.query(query);
            
            /*set values to wrapper to display in UI*/
            for(Account acc: AccountList) {
                PartnerResults partnerrec = new PartnerResults();
                sortingwrapperRecomm OpsWrapper = new sortingwrapperRecomm();
                partnerrec.account = acc;
                //GCP added 2 variable for data table
                partnerrec.accountName = acc.Name;
                partnerrec.TradingName=acc.Customer_Trading_Name__c;
                partnerrec.Id = acc.Id;
                partnerrec.isPartner = 'Yes';

                system.debug('object get********'+acc.get(AccreditationField));
                system.debug('STRING********'+(String)acc.get(AccreditationField));
                /*get the different positive accreditation values of the account */
                partnerrec.accreditation = acc.get(AccreditationField) != null ? (String)acc.get(AccreditationField) : '';
                system.debug('partnerrec.accreditation********'+partnerrec.accreditation);
                /*

                switch on AccreditationField {
                     when 'Cloud_Accreditation__c' {
                         partnerrec.accreditation=acc.Cloud_Accreditation__c ;
                     }
                     when 'Collaboration_Accreditation__c' {
                         partnerrec.accreditation=acc.Collaboration_Accreditation__c ;
                     }
                     when 'Data_Security_Accreditation__c' {
                         partnerrec.accreditation=acc.Data_Security_Accreditation__c;
                     }
                     when 'Mobility_Accreditation__c' {
                         partnerrec.accreditation=acc.Mobility_Accreditation__c;
                     }
                     when 'Services_Accreditation__c' {
                         partnerrec.accreditation=acc.Services_Accreditation__c; // adding mapping for service accreditation
                     }
                     when else {
                         partnerrec.accreditation='';
                     }
                 }

                 */

                 partnerrec.stateCoverage = acc.State_Coverage__c;
                 OpsWrapper.PartnerResults = partnerrec;
                 if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_PLATINUM){
                     OpsWrapper.AccreditationLevel=5;
                 }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_GOLD){
                     OpsWrapper.AccreditationLevel=4;
                 }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_SILVER){
                     OpsWrapper.AccreditationLevel=3;
                 }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_APPROVED){
                     OpsWrapper.AccreditationLevel=2;
                 }
                 
                 OpsWrapper.AccountName=acc.Name;
                 system.debug('***OpsWrapper***'+OpsWrapper);
                 sortingwrapperRecommmap.put(acc.id,OpsWrapper);
            }

            system.debug('***recordId***'+recordId);
            /* Accounts appearing in incumbent list to be excluded FROM display in Recommended List */
            if(recordId.startsWith('006')){
                list <PartnerResults > PartnerResultslistinc =  PRMSubmitToPartnerRules.findIncumbentPartners(recordId);
                for(PartnerResults prec:PartnerResultslistinc){
                   if(sortingwrapperRecommmap.containsKey(prec.Id)){
                      system.debug('excluding*****'+sortingwrapperRecommmap.get(prec.Id));
                      sortingwrapperRecommmap.remove(prec.Id);
                    }
                }
            }else if(recordId.startsWith('00Q') && targetPartner != null && sortingwrapperRecommmap.containsKey(targetPartner)){

                sortingwrapperRecommmap.remove(targetPartner);
            }
            sortingwrapperRecommlist=sortingwrapperRecommmap.values();
            /* logic to display only 5 partner accounts chosen in random. currently NUMBER_OF_PARTNERS = 5 */
            if(sortingwrapperRecommlist.size()>PRMConstants.NUMBER_OF_PARTNERS){
                for(integer i = 0; i < PRMConstants.NUMBER_OF_PARTNERS; i++) {
                    Integer randomNumber = Integer.valueof((Math.random() * sortingwrapperRecommlist.size()));
                    sortingwrapperRecommlistsliced.add(sortingwrapperRecommlist[randomNumber]);
                    sortingwrapperRecommlist.remove(randomNumber);
                }
            }else{
                sortingwrapperRecommlistsliced.addall(sortingwrapperRecommlist);
            }
            /*add the sorted partners to a list which is used to display the list in ui component */
            sortingwrapperRecommlistsliced.sort();
            for(integer i = 0; i < sortingwrapperRecommlistsliced.size(); i++) {
                PartnerResultslist.add(sortingwrapperRecommlistsliced[i].PartnerResults);
            }
        }catch(exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }finally{
            logger.exitLogger();
        }
        return PartnerResultslist;
    } // end of returnRecommendedPartners method
} // end of class
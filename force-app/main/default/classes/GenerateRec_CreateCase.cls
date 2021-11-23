/*******************************************************************
@Class Name     :   GenerateRec_CreateCase
@Sprint         :   P2OB-5084 Sprint 21.12
@Author         :   Hawaii Team 
@CreateDate     :   23/08/2021
@Description    :   To fetch the NBA recommendations for Case 	
*********************************************************************/
global class GenerateRec_CreateCase {
    public static Map<String,List<String>> DomainAndRecommendationsMap;
    
    @InvocableMethod
    global static List<List<Recommendation>> getRecommendations(List<String> inputData){
        List<List<Recommendation>> outputs = new List<List<Recommendation>>();
        try{
            getMapData();
            List<Recommendation> recs = new List<Recommendation>();
            
            Case caseRec = [SELECT Id, Additional_Domains__c, ss_Category__c, RecordTypeId, RecordType.DeveloperName, OpportunityId__c, OpportunityId__r.Product_Domain__c FROM Case WHERE  Id =:inputData[0] AND RecordType.DeveloperName = 'Presales_Solution' LIMIT 1 ];
        
            Set<String> recommendationsSet = new Set<String>();
            String AdditionalDomains = caseRec.Additional_Domains__c == null ? '' : caseRec.Additional_Domains__c;
            if(AdditionalDomains != ''){
                for(String ad : AdditionalDomains.split(';')){
                    if(DomainAndRecommendationsMap.containsKey(ad)){
                        recommendationsSet.addAll(DomainAndRecommendationsMap.get(ad));
                    }
                }
            }
            
            String productDomain = caseRec.OpportunityId__r.Product_Domain__c == null ? '' : caseRec.OpportunityId__r.Product_Domain__c;
            if(productDomain != ''){
                for(String ad : productDomain.split(';')){
                    if(DomainAndRecommendationsMap.containsKey(ad)){
                        recommendationsSet.addAll(DomainAndRecommendationsMap.get(ad));
                    }
                }
            }
            
            for(case cs : [ SELECT Id, ss_Category__c FROM Case WHERE OpportunityId__c =: caseRec.OpportunityId__c AND ss_Category__c IN: recommendationsSet ]){
                recommendationsSet.remove(cs.ss_Category__c);
            }
            
            List<Case_Types_Configuration__mdt> mtdList = new List<Case_Types_Configuration__mdt>();
            mtdList = [ SELECT Id, Category__c, Screen_Flow__c, Recommendation_Description__c FROM Case_Types_Configuration__mdt WHERE Category__c =: recommendationsSet AND ( Context__c LIKE '%Desktop%' OR Context__c LIKE '%Mobile%' ) ];
            
            Map<String, Case_Types_Configuration__mdt> requestTypeMap = new Map<String, Case_Types_Configuration__mdt>();
            for(Case_Types_Configuration__mdt cmdt : mtdList){
                requestTypeMap.put(cmdt.Category__c,cmdt);
            }
        	
            for(String arec : recommendationsSet){
                Recommendation rec = new Recommendation();
                rec.Name 						= arec == null ? '' : arec;
                rec.Description					= requestTypeMap.get(arec).Recommendation_Description__c == null ? '' : requestTypeMap.get(arec).Recommendation_Description__c;
                rec.ActionReference				= requestTypeMap.get(arec).Screen_Flow__c == null ? '' : requestTypeMap.get(arec).Screen_Flow__c;
                rec.AcceptanceLabel				= 'Raise Case';
                rec.RejectionLabel				= 'Dismiss';
                recs.add(rec);
            }
            outputs.add(recs);
        }catch(exception e){
            System.debug(e.getMessage());
        }
        return outputs;
    }
    
    public static void getMapData(){
        DomainAndRecommendationsMap = new Map<String, List<String>>();
        DomainAndRecommendationsMap.put('DATA & IP',new List<String>{'Lookup service details','Raise a feasibility request','Request an address remediation','Request a Customer Service Report','Request a CDR Report','Request an early termination charges (ETC)','Request a Usage [T-Analyst] Report','Request a Magpie Network Report','Request an ION Print Report'});
        DomainAndRecommendationsMap.put('MDN',new List<String>{'Lookup service details','Request an early termination charges (ETC)','Raise a feasibility request','Request an address remediation','Request a Customer Service Report','Request an ION Print Report','Request a Magpie Network Report','Request a Usage [T-Analyst] Report','Request a CDR Report'});
        DomainAndRecommendationsMap.put('SECURITY',new List<String>{'Request an early termination charges (ETC)','Lookup service details','Request an address remediation','Request a Billing Snapshot Report','Request a Customer Service Report','Request a TIF/MOTIF Report','Request an ION Print Report','Request a Magpie Network Report'});
        DomainAndRecommendationsMap.put('MOBILES',new List<String>{'Request support for Telstra online tools','Request changes to customer account','Request an early termination charges (ETC)','Complex request','Request support for non-catalogued activity','Lookup service details','Raise a feasibility request','Fund redemptions','Fund anniversary top-ups','All4Biz','Create a new fund account','Request an Agreed Accounts List','Request a Billing Snapshot Report','Request a Flexcab 130 or 140 Report','Request a MIDAS Mobile Report','Request a TIF/MOTIF Report','Request a CDR Report'});
        DomainAndRecommendationsMap.put('MOBILES - HARDWARE',new List<String>{'Request support for Telstra online tools','Request changes to customer account','Request an early termination charges (ETC)','Complex request','Request support for non-catalogued activity','Lookup service details','Raise a feasibility request','Fund redemptions','Fund anniversary top-ups','All4Biz','Create a new fund account','Request an Agreed Accounts List','Request a Billing Snapshot Report','Request a Flexcab 130 or 140 Report','Request a MIDAS Mobile Report','Request a TIF/MOTIF Report','Request a CDR Report'});
        DomainAndRecommendationsMap.put('IoT',new List<String>{'Request support for Telstra online tools','Request changes to customer account','Request an early termination charges (ETC)','Portfolio management','Complex request','Request support for non-catalogued activity','Lookup service details','Raise a feasibility request','Fund redemptions','Fund anniversary top-ups','Create a new fund account','Request an Agreed Accounts List','Request a Billing Snapshot Report','Request a Flexcab 130 or 140 Report','Request a MIDAS Mobile Report','Request a TIF/MOTIF Report','Request a CDR Report'});
        DomainAndRecommendationsMap.put('UNIFIED COMMUNICATIONS',new List<String>{'Request an early termination charges (ETC)','Complex request','Lookup service details','Raise a feasibility request','Request a Customer Service Report','Request a Usage [T-Analyst] Report','Request a CDR Report'});
        DomainAndRecommendationsMap.put('CLOUD SERVICES',new List<String>{'Request an early termination charges (ETC)','Lookup service details','Request an address remediation','Request a Billing Snapshot Report','Request a Customer Service Report','Request a TIF/MOTIF Report','Request an ION Print Report','Request a Magpie Network Report'});
    }
}
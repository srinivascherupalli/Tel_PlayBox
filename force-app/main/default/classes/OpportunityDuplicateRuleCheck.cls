/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Invoked from Opportunity Duplicate Rule LWC Component and CloseOppFlowOppDupCheck Class(CloseOpportunity Flow)
Author      	- Amar Chakka. 
************************************************************************************************************ */

public without sharing class OpportunityDuplicateRuleCheck {
    
    public static oppInfo op = new oppInfo();
	public static decimal asvPerCalMin;
	public static decimal asvPerCalMax;
	public static decimal revenueValueSum;
	public static Integer calMonth;
	public static boolean oppNameDupCheck;

/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Method Invoked from Opportunity Duplicate Rule LWC Component and CloseOppFlowOppDupCheck Class(CloseOpportunity Flow)
Author      	- Amar Chakka. 
************************************************************************************************************ */
    @AuraEnabled(cacheable=true)
    public static oppInfo dupOppCheck(string oppId){
        boolean duplicateOpp;
        
		try{
			Opportunity opp = [SELECT Id,Name,product_type__c,accountId,createddate,ASV__c,Once_Off_Revenue_Rollup__c,New_Income_Revenue_Rollup__c,Renewal_Revenue_Rollup__c,Technology_Transformation_Revenue__c from Opportunity where id =:oppId LIMIT 1];
			if(opp.product_type__c == Label.Opp_ProductType_NonModular){
				calMonth = opp.createddate.month();
				revenueValueSum = opp.Once_Off_Revenue_Rollup__c+opp.New_Income_Revenue_Rollup__c+opp.Renewal_Revenue_Rollup__c+opp.Technology_Transformation_Revenue__c;
				if(opp.ASV__c > 0){
					asvPerCalMax = opp.ASV__c+((opp.ASV__c*10)/100);
					asvPerCalMin = opp.ASV__c-((opp.ASV__c*10)/100);
				}
				oppNameDupCheck = opp.Name.containsIgnoreCase('Renew') || opp.Name.containsIgnoreCase('Renewal') || opp.Name.containsIgnoreCase('Resign') || opp.Name.containsIgnoreCase('Re-Sign') || opp.Name.containsIgnoreCase('Re-Contract') || opp.Name.containsIgnoreCase('Recontract');
				
			    if(oppNameDupCheck && opp.New_Income_Revenue_Rollup__c > 0){  //AC-4.Check for Opportunity Name and Incremental Anunity Revenue. 
					op.duplicateOpp = true;
				}
				else{
					//Revenue Comparision Computation start.
					oppDuplicateCheck(opp);
				}
				
			}else{
				op.duplicateOpp = false;
			}
		}catch(Exception ex){
			system.debug('Exception:::: OpportunityDuplicateRuleCheck :::: dupOppCheck Method'+ Ex.getMessage());
		}
		return op;
    }
/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Method which Computes Logice for Ac-1, AC-2 and AC-4. Revenue Values Comparision.
Author      	- Amar Chakka. 
************************************************************************************************************ */
	public static void oppDuplicateCheck(opportunity opp){
	    list<Opportunity> oppList = new list<Opportunity>();
		oppList = [SELECT Id,Name,product_type__c,Createddate,ASV__c,New_Income_Revenue_Rollup__c,Once_Off_Revenue_Rollup__c,Renewal_Revenue_Rollup__c,Technology_Transformation_Revenue__c from Opportunity where product_type__c =: Label.Opp_ProductType_NonModular and accountId =:opp.AccountId and CALENDAR_MONTH(createddate) =:calMonth];
		for(Opportunity oppDup : oppList){    //start of for Loop. Checking AC-1, AC-2 and AC-4. 
			decimal revenueValueoppDup = oppDup.Once_Off_Revenue_Rollup__c+oppDup.New_Income_Revenue_Rollup__c+oppDup.Renewal_Revenue_Rollup__c+oppDup.Technology_Transformation_Revenue__c;
			boolean revenueValCheck = ((oppDup.ASV__c == opp.ASV__c && opp.ASV__c > 0) || (opp.ASV__c > 0 && oppDup.ASV__c >=asvPerCalMin && oppDup.ASV__c <=asvPerCalMax) ||  (revenueValueSum > 0 && revenueValueSum == revenueValueoppDup));
			if(!oppList.isEmpty() && oppList.size() > 1 && oppDup.Id != opp.id && (revenueValCheck)){
				op.duplicateOpp = true;
				break;
			}else{
				op.duplicateOpp = false;
			}
		}	// End of for loop.
	}

/* **********************************************************************************************************
Sprint        	- SFO Sprint 20.17, P2OB-11314.
Component     	- OpportunityDuplicateRuleCheck
Descriptionc	- Wrapper class which returns value to LWC Component
Author      	- Amar Chakka. 
************************************************************************************************************ */

    public class OppInfo{
        @AuraEnabled public boolean duplicateOpp{get;set;}
    }
	
	
}
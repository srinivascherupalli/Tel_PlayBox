/*
    AUTHOR : Lok Jackson
    DESCRIPTION : Reassigns Accounts based on Portfolio Owner in the Active Territory Model 
                    then calls Batch Apex class BatchOpportunityAssignment to reassign open Opportunities
                    Needs to run following the activation of a new Territory Model (either via anonymous apex or apex scheduler)
	@Updated  : 20.12  & P2OB-8608 , All accounts with no portfolio code or if the portfolio code is not present in the territory the owner gets reassigned to phoenix adminuser. 
	@Last Modified        : 07/01/2021 21.01 by Chhaveel, Team SFO
        				                as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

global Without sharing class BatchAccountAssignment implements Database.Batchable<SObject> {

    private Map<String, Id> portCodeOwnerMap;
    private List<String> activePortCodes;
    private Id phoenixAdminUserId;
	public static boolean isBatchAccountAssignment=false;
    private Map<String, String> portCodeTierMap;
	private	Map<String, string> portCodeVertical; //Added as part of P2OB-11782	 Sprint 21.08

    global BatchAccountAssignment() {
        portCodeOwnerMap = new Map<String,Id>();
        portCodeTierMap = new Map<String, String>();
        portCodeVertical = new Map<String, string>(); //Added as part of P2OB-11782	 Sprint 21.08
        activePortCodes = new List<String>();
        // 20.12  & P2OB-8608 Fetching Phoenix Admin user id stored in Phoenix_Configurations__c Custom Settings
        Phoenix_Configurations__c phoenixConfigs = Phoenix_Configurations__c.getInstance();
        if(phoenixConfigs.BatchAccountOwnerUserID__c != null)
        phoenixAdminUserId = [SELECT Id FROM User WHERE id =: phoenixConfigs.BatchAccountOwnerUserID__c LIMIT 1 ].id;

        for(UserTerritory2Association portOwners : [select UserId, Territory2.Name,RoleInTerritory2 from UserTerritory2Association where Territory2.Territory2Model.State = 'Active' and RoleInTerritory2 = 'Owner' order by LastModifiedDate ASC]){
            portCodeOwnerMap.put(portOwners.Territory2.Name, portOwners.UserId);
        }
        for(Territory2 ter : [SELECT id,DeveloperName FROM Territory2 where Territory2Model.State = 'Active' ]){
            activePortCodes.add(ter.DeveloperName);
        }
        
		for(Portfolio_Code__c portCode : [select Name, Tier__c, Vertical__c from Portfolio_Code__c]){
            portCodeTierMap.put(portCode.Name, portCode.Tier__c);
			portCodeVertical.put(portcode.Name,portcode.Vertical__c); //Added as part of P2OB-11782	 Sprint 21.08
        }
    }
    
    /**
     * @description gets invoked when the batch job starts
     * @param context contains the job ID
     * @returns the record set as a QueryLocator object that will be batched for execution
     */ 
    global Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator('SELECT Id, Name, OwnerId, CIDN__c, TCM_MasterID__c, Portfolio_Code__c, APTPS_Tier__c, Vertical__c FROM Account WHERE CIDN__c != null and TCM_MasterID__c != null');
    }

    /**
     * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
     * @Updating account record when the owner is changed only, to avoid DML updates. 25/Sep/2018 - Chandra
     * @param context contains the job ID
     * @param scope contains the batch of records to process.
     */ 
    global void execute(Database.BatchableContext context, List<Account> scope) {
        isBatchAccountAssignment=true;
        List<Account> accsToUpdate = new List<Account>();
        Boolean flag = false;
        for(Account a : scope){ 
            flag = false;
            // 20.12  & P2OB-8608 Adding check for portfolio codes which are not present in territory model
            Id accOwnerId = (String.isNotBlank(a.Portfolio_Code__c) && portCodeOwnerMap.containsKey(a.Portfolio_Code__c)) ? portCodeOwnerMap.get(a.Portfolio_Code__c) : phoenixAdminUserId;
            //20.12  & P2OB-8608 In case territory is present in territory model but do not have owner assigned
			if(String.isNotBlank(a.Portfolio_Code__c) && accOwnerId == phoenixAdminUserId && activePortCodes.contains(a.Portfolio_Code__c))   {
                accOwnerId =null;
            }   
	
			if(accOwnerId != null && a.OwnerId != accOwnerId){
                a.OwnerId = accOwnerId;
                flag = true;
            }
        /* P2OB-1684 : Updating the Account segment from respected Portfolio Code Objects Segment Field */            
            if(String.isNotBlank(a.Portfolio_Code__c) && portCodeTierMap.containsKey(a.Portfolio_Code__c) &&  portCodeTierMap.get(a.Portfolio_Code__c) != a.APTPS_Tier__c){
				a.APTPS_Tier__c = portCodeTierMap.get(a.Portfolio_Code__c);	
				flag = true;
			}
			//Added as part of P2OB-11782	 Sprint 21.08
            if(String.isNotBlank(a.Portfolio_Code__c) && portCodeVertical.containsKey(a.Portfolio_Code__c) &&  portCodeVertical.get(a.Portfolio_Code__c) != a.Vertical__c){
				a.Vertical__c = portCodeVertical.get(a.Portfolio_Code__c);	
				flag = true;
			}
            if(flag){
				accsToUpdate.add(a); 
			}
        } 
        if(!accsToUpdate.isEmpty()){
			update accsToUpdate;
        }
    }
    
    /**
     * @description gets invoked when the batch job finishes. Place any clean up code in this method.
     * @param context contains the job ID
     */ 
    global void finish(Database.BatchableContext context) {
        //Once done, kickoff Opportunity Reassignment
        /* EDGE-12042 : Calling Eureka Batch class to update Sales Account Executive field from agreement object*/
        String UpdateSalesAccExecutive = EnvironmentVariable__c.getValues('UpdateSalesAccExecutive').Value__c;
        if(UpdateSalesAccExecutive != null && UpdateSalesAccExecutive == 'true'){
            BatchAgmtSalesAccExecutiveUpdate salesAccExecBatch = New BatchAgmtSalesAccExecutiveUpdate();
            database.executeBatch(salesAccExecBatch,200);
        }
    }
}
/****************************************************************************
@Name			: SFOCIDNRevenueTargetsTriggerHandler
@TestCoverage   : SFOCIDNRevenueTargetsTriggerHandlerTest
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: This Class is for CIDNRevenueTargetsTrigger Trigger
Note 			: Implemented Trigger FrameWork
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: 
********************************************************************************/
public without sharing class SFOCIDNRevenueTargetsTriggerHandler  extends ATF_AbstractDomainHandler {
    /****************************************************************************
@Method Name	: handleBeforeInsert
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: This Method is triggered before insert 
********************************************************************************/    
    public override void handleBeforeInsert (){
            checkDuplicateAccountRecords();
    }
    
    /****************************************************************************
@Method Name	: handleBeforeUpdate
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: This Method is triggered before update 
********************************************************************************/  
    public override void handleBeforeUpdate (Map<id,SObject> oldTagetsObjectMap){
            checkDuplicateAccountRecords();
    }
    /****************************************************************************
@Method Name	: checkDuplicateAccountRecords
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: This Method is called from before insert and update to check whether Account_Name__c is unique or not 
********************************************************************************/  
    private void checkDuplicateAccountRecords(){
        try{
            Set<id> setCIDNRevTargets = new Set<id>();
            Set<id> duplicateAccountRecord = new Set<id>();
            //To not consider the current record as duplicate
            for(CIDN_Revenue_Targets__c varCIDNRevTarget : [SELECT id, Account_Name__c FROM CIDN_Revenue_Targets__c where id NOT IN : Trigger.new]){
                setCIDNRevTargets.add(varCIDNRevTarget.Account_Name__c);
            }
            for(CIDN_Revenue_Targets__c varCIDNRevTarget : (List<CIDN_Revenue_Targets__c>)Trigger.new){
                //To check the duplicates in new lsit
                if(duplicateAccountRecord.contains(varCIDNRevTarget.Account_Name__c)){
                    varCIDNRevTarget.addError(System.Label.CIDNRevenueTargetsErrorMsg);
                }else
                {
                    duplicateAccountRecord.add(varCIDNRevTarget.Account_Name__c);
                }
                if(!setCIDNRevTargets.isEmpty() && setCIDNRevTargets.contains(varCIDNRevTarget.Account_Name__c)){
                    varCIDNRevTarget.addError(System.Label.CIDNRevenueTargetsErrorMsg);
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOCIDNRevenueTargetsTriggerHandler Class:::: checkDuplicateAccountRecords Method'+ Ex.getMessage());
        }        
    }
    
}
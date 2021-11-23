/****************************************************************************
@Name			: PortfolioAlignmentHelper.
@Author			: SFO/Sri , Sravanthi.
@CreateDate		: 30/01/2018.
@UpdatedDate	: 30/09/2019[P2OB-2214].
@Description	: This Class is for PortfolioAlignment Trigger - EDGE-62548, EDGE-91973 P2OB-2214
@Modified 		: 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
@Last Modified	: 07/01/2020 21.01 by Sri, Team SFO
				  as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified	: 
********************************************************************************/
public with sharing class PortfolioAlignmentHelper {
     
    /****************************************************************************
@Name: roleNameRoleIdAssignment.
@Author: SFO/Sravanthi
@Sprint : 19.13 [P2OB-2214]
@CreateDate: 30/09/2019.
@Description: This Method is triggered before insert & before update to populate 
Role_Name__c ,Role_Id__c appropriately  
@Modified : 30/10/2019 Sravanthi, 
P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
********************************************************************************/
    public void roleNameRoleIdAssignment(List<Portfolio_Alignment__c> newPortfolioAlgnmt,Map<id,Portfolio_Alignment__c> oldPortfolioRAMap){
        try{        
            // Below check is used to restricting while lighting component(SelectRole) getting call
            if(SFOReferenceDataRoleNameId.isLightningRun == false){
                
                SFOReferenceDataRoleNameId refDataRoleIns = new SFOReferenceDataRoleNameId();
                If(newPortfolioAlgnmt.size()>0){
                    // for-loop start
                    for(Portfolio_Alignment__c portfolioRoleAlignRec : newPortfolioAlgnmt){
                        //Stores the final field values of Role Id Role Name Parent Role Name
                        Map<String,String> roleNameRoleIdMap = new Map<String,String>();
                        
                        Map<String,String> fieldsNameValueMap = new Map<String,String>();
                        fieldsNameValueMap.put('Role_Name__c', portfolioRoleAlignRec.Role_Name__c);
                        fieldsNameValueMap.put('Role_Id__c', portfolioRoleAlignRec.Role_Id__c);
                        //On Update
                        if(oldPortfolioRAMap!=null){
                            fieldsNameValueMap.put('oldRole_Name__c', oldPortfolioRAMap.get(portfolioRoleAlignRec.id).Role_Name__c);
                            fieldsNameValueMap.put('oldRole_Id__c', oldPortfolioRAMap.get(portfolioRoleAlignRec.id).Role_Id__c);
                            roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId(fieldsNameValueMap,
                                                                                oldPortfolioRAMap,
                                                                                refDataRoleIns.userRoleMap,
                                                                                refDataRoleIns.userRoleParentMap);
                        }
                        //On Insert
                        else if(oldPortfolioRAMap == null){
                            roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId(fieldsNameValueMap,
                                                                                null,
                                                                                refDataRoleIns.userRoleMap,
                                                                                refDataRoleIns.userRoleParentMap);
                        }
                        if(roleNameRoleIdMap.containsKey('Role_Name__c')){
                            portfolioRoleAlignRec.Role_Name__c=roleNameRoleIdMap.get('Role_Name__c');
                        }
                        if(roleNameRoleIdMap.containsKey('Role_Id__c')){
                            portfolioRoleAlignRec.Role_Id__c=roleNameRoleIdMap.get('Role_Id__c');
                        }
                        if(roleNameRoleIdMap.containsKey('X1_Up_Role_Name__c') ){
                            portfolioRoleAlignRec.X1_up_Role_Text__c=roleNameRoleIdMap.get('X1_Up_Role_Name__c');
                        }
                    }//for-loop end
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: PortfolioAlignmentHelper Class:::: roleNameRoleIdAssignment Method'+ Ex.getMessage());
        }
    }
}
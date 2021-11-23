/****************************************************************************
@Name: SFONPSSRoleAlignmentTriggerHandler.
@Author: SFO(SanFrancisco)/Sravanthi
@CreateDate: 30/09/2019.
@Description: This Class is for SFONPSSRoleAlignmentTrigger Trigger - P2OB-2214
Note : Implemented Trigger FrameWork
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
********************************************************************************/
public without sharing class SFONPSSRoleAlignmentTriggerHandler extends ATF_AbstractDomainHandler  {
    
    
    
    /****************************************************************************
@Method Name: handleBeforeInsert.
@Author: SFO/Sravanthi
@Sprint : 19.13[P2OB-2214]
@CreateDate: 30/09/2019.
@Description: This Method is triggered before insert to populate Role_Name__c ,
Role_Id__c appropriately 
@Modified : 30/10/2019 Sravanthi, 
P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
********************************************************************************/    
    public override void handleBeforeInsert (){
        try{
            // Below check is used to restricting while lighting component(SelectRole) getting call
            if(SFOReferenceDataRoleNameId.isLightningRun == false){
                
                
                SFOReferenceDataRoleNameId refDataRoleIns = new SFOReferenceDataRoleNameId();
                // for-loop start
                for(NPSS_Role_Alignment__c npssRoleAlignmentRec : (List<NPSS_Role_Alignment__c>)Trigger.new){
                    Map<String,String> fieldsNameValueMap = new Map<String,String>();
                    fieldsNameValueMap.put('Role_Name__c', npssRoleAlignmentRec.Role_Name__c);
                    fieldsNameValueMap.put('Role_Id__c', npssRoleAlignmentRec.Role_Id__c);
                    Map<String,String> roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId(fieldsNameValueMap,
                                                                                           null,
                                                                                           refDataRoleIns.userRoleMap,
                                                                                           refDataRoleIns.userRoleParentMap);
                    if(roleNameRoleIdMap.containsKey('Role_Name__c') ){
                        npssRoleAlignmentRec.Role_Name__c=roleNameRoleIdMap.get('Role_Name__c');
                    }
                    if(roleNameRoleIdMap.containsKey('Role_Id__c') ){
                        npssRoleAlignmentRec.Role_Id__c=roleNameRoleIdMap.get('Role_Id__c');
                    }
                    if(roleNameRoleIdMap.containsKey('X1_Up_Role_Name__c') ){
                        npssRoleAlignmentRec.X1_up_Role__c=roleNameRoleIdMap.get('X1_Up_Role_Name__c');
                    }
                }// for-loop end
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFONPSSRoleAlignmentTriggerHandler Class:::: handleBeforeInsert Method'+ Ex.getMessage());
        }
    }
    
    /****************************************************************************
@Method Name: handleBeforeUpdate.
@Author: SFO/Sravanthi
@Sprint : 19.13[P2OB-2214]
@CreateDate: 30/09/2019.
@Description: This Method is triggered before update to populate Role_Name__c ,
Role_Id__c appropriately  
@Modified : 30/10/2019 Sravanthi, 
P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
********************************************************************************/  
    public override void handleBeforeUpdate (Map<id,SObject> oldNPSSRAMap){
        try{
            // Below check is used to restricting while lighting component(SelectRole) getting call
            if(SFOReferenceDataRoleNameId.isLightningRun == false){
                Map<id,NPSS_Role_Alignment__c> oldNPSSRAnewMap = (Map<id,NPSS_Role_Alignment__c>)oldNPSSRAMap;
                
                SFOReferenceDataRoleNameId refDataRoleIns = new SFOReferenceDataRoleNameId();
                // for-loop start
                for(NPSS_Role_Alignment__c npssRoleAlignmentRec : (List<NPSS_Role_Alignment__c>)Trigger.new){
                    Map<String,String> fieldsNameValueMap = new Map<String,String>();
                    fieldsNameValueMap.put('Role_Name__c', npssRoleAlignmentRec.Role_Name__c);
                    fieldsNameValueMap.put('Role_Id__c', npssRoleAlignmentRec.Role_Id__c);
                    if(oldNPSSRAnewMap!=null){
                        fieldsNameValueMap.put('oldRole_Name__c', oldNPSSRAnewMap.get(npssRoleAlignmentRec.id).Role_Name__c);
                        fieldsNameValueMap.put('oldRole_Id__c', oldNPSSRAnewMap.get(npssRoleAlignmentRec.id).Role_Id__c);
                    }
                    Map<String,String> roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId(fieldsNameValueMap,
                                                                                           oldNPSSRAMap,
                                                                                           refDataRoleIns.userRoleMap,
                                                                                           refDataRoleIns.userRoleParentMap);
                    
                    if(roleNameRoleIdMap.containsKey('Role_Name__c') ){
                        npssRoleAlignmentRec.Role_Name__c=roleNameRoleIdMap.get('Role_Name__c');}
                    if(roleNameRoleIdMap.containsKey('Role_Id__c') ){
                        npssRoleAlignmentRec.Role_Id__c=roleNameRoleIdMap.get('Role_Id__c');
                    }
                    if(roleNameRoleIdMap.containsKey('X1_Up_Role_Name__c') ){
                        npssRoleAlignmentRec.X1_up_Role__c=roleNameRoleIdMap.get('X1_Up_Role_Name__c');
                    }
                }// for-loop end
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFONPSSRoleAlignmentTriggerHandler Class:::: handleBeforeUpdate Method'+ Ex.getMessage());
        }
    }
    
}
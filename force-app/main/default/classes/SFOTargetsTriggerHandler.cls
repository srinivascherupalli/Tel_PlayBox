/****************************************************************************
@Name: SFOTargetsTriggerHandler.
@Author: SFO(SanFrancisco)/Sravanthi
@CreateDate: 14/10/2019.
@Description: This Class is for TargetsTrigger Trigger - P2OB-3297
Note : Implemented Trigger FrameWork
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] Modified according to the parameter changes in SFOReferenceDataRoleNameId
********************************************************************************/
public without sharing class SFOTargetsTriggerHandler  extends ATF_AbstractDomainHandler {
    /****************************************************************************
@Method Name: handleBeforeInsert.
@Author: SFO/Sravanthi
@Sprint : 19.14[P2OB-3297]
@CreateDate: 14/10/2019.
@Description: This Method is triggered before insert to populate Role_Name__c ,
Role_Id__c,X1_Up_Role_Name__c appropriately 
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15] 
********************************************************************************/    
    public override void handleBeforeInsert (){
        try{
            // Below check is used to restricting while lighting component(SelectRole) getting call
            if(SFOReferenceDataRoleNameId.isLightningRun == false){
                
                SFOReferenceDataRoleNameId refDataRoleIns = new SFOReferenceDataRoleNameId();
                for(Targets__c targetRec : (List<Targets__c>)Trigger.new){
                    Map<String,String> fieldsNameValueMap = new Map<String,String>();
                    fieldsNameValueMap.put('Role_Name__c', targetRec.Role_Name__c);
                    fieldsNameValueMap.put('Role_Id__c', targetRec.Role_Id__c);
                    //Below call returns Role Id and 1 Up Role Name for the passed Role Name
                    Map<String,String> roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId( fieldsNameValueMap,
                                                                                           null,
                                                                                           refDataRoleIns.userRoleMap,
                                                                                           refDataRoleIns.userRoleParentMap);
                    
                    if(roleNameRoleIdMap.containsKey('Role_Id__c') ){
                        targetRec.Role_Id__c=roleNameRoleIdMap.get('Role_Id__c');
                    }
                    if(roleNameRoleIdMap.containsKey('X1_Up_Role_Name__c') ){
                        targetRec.X1_Up_Role_Name__c=roleNameRoleIdMap.get('X1_Up_Role_Name__c');
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOTargetsTriggerHandler Class:::: handleBeforeInsert Method'+ Ex.getMessage());
        }
    }
    
    /****************************************************************************
@Method Name: handleBeforeUpdate.
@Author: SFO/Sravanthi
@Sprint : 19.14[P2OB-3297]
@CreateDate: 14/10/2019.
@Description: This Method is triggered before update to populate Role_Name__c ,
Role_Id__c ,X1_Up_Role_Name__c appropriately  
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15]  
********************************************************************************/  
    public override void handleBeforeUpdate (Map<id,SObject> oldTagetsObjectMap){
        try{
            // Below check is used to restricting while lighting component(SelectRole) getting call
            if(SFOReferenceDataRoleNameId.isLightningRun == false){
                Map<id,Targets__c> oldTagetsMap = (Map<id,Targets__c>)oldTagetsObjectMap;
                
                SFOReferenceDataRoleNameId refDataRoleIns = new SFOReferenceDataRoleNameId();         
                for(Targets__c targetRec : (List<Targets__c>)Trigger.new){
                    Map<String,String> fieldsNameValueMap = new Map<String,String>();
                    fieldsNameValueMap.put('Role_Name__c', targetRec.Role_Name__c);
                    fieldsNameValueMap.put('Role_Id__c', targetRec.Role_Id__c);
                    if(oldTagetsMap!=null){
                        fieldsNameValueMap.put('oldRole_Name__c', oldTagetsMap.get(targetRec.id).Role_Name__c);
                        fieldsNameValueMap.put('oldRole_Id__c', oldTagetsMap.get(targetRec.id).Role_Id__c);
                    }
                    //Below call returns Role Id and 1 Up Role Name for the passed Role Name
                    Map<String,String> roleNameRoleIdMap =refDataRoleIns.getRoleNameRoleId(fieldsNameValueMap,
                                                                                           oldTagetsMap,
                                                                                           refDataRoleIns.userRoleMap,
                                                                                           refDataRoleIns.userRoleParentMap);
                    
                    
                    if(roleNameRoleIdMap.containsKey('Role_Id__c') ){
                        targetRec.Role_Id__c=roleNameRoleIdMap.get('Role_Id__c');
                    }
                    if(roleNameRoleIdMap.containsKey('X1_Up_Role_Name__c') ){
                        targetRec.X1_Up_Role_Name__c=roleNameRoleIdMap.get('X1_Up_Role_Name__c');
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOTargetsTriggerHandler Class:::: handleBeforeUpdate Method'+ Ex.getMessage());
        }
    }
}
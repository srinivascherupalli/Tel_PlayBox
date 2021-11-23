/****************************************************************************
@Name: SFOReferenceDataRoleNameId.
@Author: SFO/Sravanthi
@Sprint : 19.13
@CreateDate: 30/09/2019.
@Description: This Class is used to populated Role Name and Role ID fields in 
NPSS Role Allignment , SFOTargetsTriggerHandler and Portfolio Alignment P2OB-2214 , P2OB-3297
@Modified Date & Description: 14/10/2019, To accomodate 1 up role population in Targets Trigger P2OB-3297 && Fix bug P2OB-3372 
@Modified : 30/10/2019 Sravanthi, 
P2OB:3659[Sprint 19.15] to Accomodate 1Up Role Name population according to Role Name
********************************************************************************/
public without sharing class SFOReferenceDataRoleNameId {
    // Below isLightningRun variable is used to restricting while lighting component(SelectRole) getting call.
    public static boolean isLightningRun = false;  
    public Map<Id, UserRole> mapOfRoleIdToObj = new Map<Id, UserRole>() ;
    public Map<String,id> userRoleMap = new Map<String,id>();
    public Map<String,String> userRoleParentMap = new Map<String,String>();
    
    public SFOReferenceDataRoleNameId(){
        mapOfRoleIdToObj = new Map<Id, UserRole>([SELECT Id,Name,ParentRoleId FROM UserRole WHERE PortalType!=: Label.Partner]);
        for(UserRole uRole : mapOfRoleIdToObj.values()){
            userRoleMap.put(uRole.Name,uRole.id);
            if(mapOfRoleIdToObj.get(uRole.ParentRoleId) != null){       
                userRoleParentMap.put(uRole.Name,mapOfRoleIdToObj.get(uRole.ParentRoleId).Name);
            }
        }
    }
    /****************************************************************************
@Name: getRoleNameRoleId.
@Author: SFO/Sravanthi
@Sprint : 19.13
@CreateDate: 30/09/2019.
@Description: This Method is used to populate Role Name And Role ID , return to trigger helpers object P2OB-2214
@Modified Date & Description: 14/10/2019, To accomodate 1 up role population in Targets Trigger P2OB-3297 && Fix bug P2OB-3372 
@Modified : 30/10/2019 Sravanthi, P2OB:3659[Sprint 19.15]
********************************************************************************/    
    public Map<String,String> getRoleNameRoleId(Map<String,String> fieldsNameValueMap,
                                                Map<id,SObject> oldNPSSRAnewMap,
                                                Map<String,id> roleNameIdMap,
                                                Map<String,String> roleNameParentMap){
        Map<String,String> roleNameRoleIdMap =New Map<String,String>();
        try{
            if(fieldsNameValueMap.size()>0){
                String roleName=fieldsNameValueMap.get('Role_Name__c');
                String oldRoleName=fieldsNameValueMap.get('oldRole_Name__c');
                String oldRoleId = fieldsNameValueMap.get('oldRole_Id__c');
                String roleId = fieldsNameValueMap.get('Role_Id__c');
                //For OnInsert and On Update of Role Name Change
                if(roleName != oldRoleName && fieldsNameValueMap.size()!=null){
                    
                    //When Role Name is  valid  & Changed, populating  1 up role  && Role id .            
                    if(roleName != null && (String)roleNameIdMap.get(roleName) != null){
                        
                        roleNameRoleIdMap.put('Role_Id__c', roleNameIdMap.get(roleName));
                        
                        if(roleNameParentMap.get(roleName) != null){
                            roleNameRoleIdMap.put('X1_Up_Role_Name__c',roleNameParentMap.get(roleName));
                        }
                    }
                    //When Role Name is in valid or Role name is null  making Role name && Role id empty.            
                    else if(roleName == null||(String)roleNameIdMap.get(roleName) == null){
                        roleNameRoleIdMap.put('Role_Id__c', '');
                        roleNameRoleIdMap.put('Role_Name__c', '');
                    }
                }
                
                // When Role ID is changed and is invalid for the given role name populated the correct role id           
                else if(roleId != oldRoleId && roleName == oldRoleName){              
                    if(roleId  != (String)roleNameIdMap.get(roleName) && roleNameIdMap.get(roleName) != null ){
                        roleNameRoleIdMap.put('Role_Id__c', roleNameIdMap.get(roleName));
                    }
                }
            }
        }
        catch(Exception ex){
            system.debug('Exception:::: SFOReferenceDataRoleNameId Class:::: getRoleNameRoleId Method'+ Ex.getMessage());
        }
        return roleNameRoleIdMap;
    }
}
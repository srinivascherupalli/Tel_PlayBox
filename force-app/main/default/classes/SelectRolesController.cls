/*****************************************************************************
@Name: SelectRolesController
@Author: SFO Team /Shaik Mahaboob Subani
@CreateDate: 20/09/2019
@Sprint : 19.13 [P2OB-1659.]
@Description: This class is Controller for Select Role Lightning Component.
			  It will Fetch All role and parent role 
@LastModified:Subani and Sravanthi[P2OB-3297]
@Modified : 30/10/2019 Sravanthi, 
            P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
*******************************************************************************/
public without sharing class SelectRolesController {
    
    /****************************************************************************
    @Method Name: getRolesList.
    @Author: SFO Team/Subani,Amar
    @Sprint : 19.13 [P2OB-1659]
    @CreateDate: 30/09/2019.
    @Description: This Method is used to get all Roles along with Parent Role Details
	@Modified : 30/10/2019 Sravanthi, 
            P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
    ********************************************************************************/
    @AuraEnabled  (cacheable=true)
    public static List<RoleDetails> getRolesList(){  
        List<RoleDetails> records = new List<RoleDetails>();
        Set<Id> parentRoleIds = new Set<Id>();
        try{
            // Getting Non Partner Roles
            Map<Id, UserRole> mapOfRoleIdToObj = new Map<Id, UserRole>([SELECT Id,Name,ParentRoleId FROM UserRole WHERE PortalType!=: Label.Partner]);
            //For Loop Start
            for(UserRole roleRec : mapOfRoleIdToObj.values()){
                RoleDetails rd = new RoleDetails(roleRec.Id, roleRec.Name, roleRec.ParentRoleId,mapOfRoleIdToObj.get(roleRec.ParentRoleId).Name); 
                records.add(rd);
            }// For loop end
        }catch(Exception Ex){
            system.debug('Exception:--------->Class : SelectRolesController--------->Method : saveSelectedRadio' + Ex.getMessage());
        }
        return records;
    }
    
    /****************************************************************************
    @Method Name: saveSelectedRadio.
    @Author: SFO Team/Subhani,Amar
    @Sprint : 19.13 [P2OB-1659]
    @CreateDate: 30/09/2019.
    @Description: Method which saves Role Id and RoleName on Portfolio Alignment 
    Object and NPSS Role Alignment Object and Targets
    @LastModified:Subani and Sravanthi[P2OB-3297]
	@Modified : 30/10/2019 Sravanthi, 
            P2OB:3659[Sprint 19.15] To add logic to populate 1 up role based on role name .
    ********************************************************************************/
    @AuraEnabled  
    public static void saveSelectedRadio(Id recordId , string rolerec){
        try{
            //string null check which is came from client side
            if((rolerec != null && rolerec != '')){
                // Deserializes single record which is received from Client Controller
                RoleDetails rdj = (RoleDetails)JSON.deserialize(rolerec, RoleDetails.class); 
                String sobjectType = recordId.getSObjectType().getDescribe().getName();
                // Sobject type check NPSS_Role_Alignment
                if(sobjectType == Label.NPSS_Role_Alignment){
                    NPSS_Role_Alignment__c rec = new NPSS_Role_Alignment__c();
                    rec.id = recordId;
                    rec.Role_Id__c = string.valueof(rdj.roleId);
                    rec.Role_Name__c = string.valueof(rdj.roleName);
                    rec.X1_up_Role__c = string.valueof(rdj.parentRoleName);
                    // To Prevent Trigger not to fire on below update.
                    SFOReferenceDataRoleNameId.isLightningRun=True; 
                    update rec;
                }
                // Sobject type check Portfolio_Alignment
                if(sobjectType == Label.Portfolio_Alignment){
                    Portfolio_Alignment__c rec = new Portfolio_Alignment__c();
                    rec.id = recordId;
                    rec.Role_Id__c = string.valueof(rdj.roleId);
                    rec.Role_Name__c = string.valueof(rdj.roleName);
                    rec.X1_up_Role_Text__c = string.valueof(rdj.parentRoleName);
                    // To Prevent Trigger not to fire on below update.
                    SFOReferenceDataRoleNameId.isLightningRun=True; 
                    update rec; 
                }
                // Sobject type check Targets__c
                if(sobjectType == 'Targets__c'){
                    Targets__c rec = new Targets__c();
                    rec.id = recordId;
                    rec.Role_Id__c = string.valueof(rdj.roleId);
                    rec.Role_Name__c = string.valueof(rdj.roleName);
                    rec.X1_Up_Role_Name__c = string.valueof(rdj.parentRoleName);
                    // To Prevent Trigger not to fire on below update.
                    SFOReferenceDataRoleNameId.isLightningRun=True; 
                    update rec; 
                }
            }
       }catch(DMLException Ex){
            system.debug('DML Exception:---------> Class :  SelectRolesController--------->Method : saveSelectedRadio'+ Ex.getMessage());
            throw new AuraHandledException(Ex.getMessage());
        }catch(Exception Ex){
            system.debug('Exception:---------> Class :  SelectRolesController--------->Method : saveSelectedRadio' + Ex.getMessage());
        }	
    }
    
    /*****************************************************************************
    @Name: RoleDetails (Wrapper class)
    @Author: SFO Team/Shaik Mahaboob Subani
    @CreateDate: 20/09/2019
    @Sprint : 19.13 [P2OB-1659.]
    @Description: Wrapper class to get Role Details along with Parent Role Details 
    *******************************************************************************/
    public class RoleDetails{
        @AuraEnabled public Id roleId {get;set;}
        @AuraEnabled public String roleName {get;set;}
        @AuraEnabled public Id parentRoleId {get;set;}
        @AuraEnabled public String parentRoleName {get;set;}
        
        public RoleDetails(Id roleId,String roleName,Id parentRoleId,String parentRoleName){
            this.roleId = roleId;               
            this.roleName = roleName;
            this.parentRoleId = parentRoleId;
            this.parentRoleName = parentRoleName;
        }
    }
}
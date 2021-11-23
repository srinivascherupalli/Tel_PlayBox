/****************************************************************************
@Name: PortfolioAlignmentHelper.
@Author: SFO/Sri , Sravanthi
@CreateDate: 30/01/2018.
@UpdatedDate: 30/09/2019.
@Description: This Trigger is for PortfolioAlignment Object - EDGE-62548 P2OB-2214
********************************************************************************/
trigger PortfolioAlignmentTrigger on Portfolio_Alignment__c (before insert,before Update) {

    PortfolioAlignmentHelper prtfolioAlgnmetHelper = new PortfolioAlignmentHelper();
    if((trigger.isBefore && Trigger.isInsert)){
        // Commenting as per P2OB-1659 AC-1. Role Hierarchy and Role Alignment along with their references should be dormant. 
        //prtfolioAlgnmetHelper.RoleAnd1upRoleAssignment(trigger.new);
        //P2OB-2214 : 19.13 To udpate Role Name and Role ID appropriately
        prtfolioAlgnmetHelper.roleNameRoleIdAssignment(Trigger.new,null);
    }
    
    else if(Trigger.isBefore && Trigger.isUpdate){
        // Commenting as per P2OB-1659 AC-1. Role Hierarchy and Role Alignment along with their references should be dormant. 
        //prtfolioAlgnmetHelper.RoleAnd1upRoleAssignment(trigger.new);
        //P2OB-2214 : 19.13 To udpate Role Name and Role ID appropriately
        prtfolioAlgnmetHelper.roleNameRoleIdAssignment(Trigger.new,Trigger.oldMap);
    }
}
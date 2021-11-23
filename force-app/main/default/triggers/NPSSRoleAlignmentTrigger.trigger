/****************************************************************************
@Name: NPSSRoleAlignmentTrigger.
@Author: SFO/ Sravanthi
@CreateDate: 30/09/2019.
@Description: This Trigger is for NPSS Role Alignment Object - P2OB-2214
********************************************************************************/
trigger NPSSRoleAlignmentTrigger on NPSS_Role_Alignment__c (before insert, 
                                                            before update,
                                                            before delete,
                                                            after insert,
                                                            after update,
                                                            after delete)
{
       //Implemeted Trigger framework 
       fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}
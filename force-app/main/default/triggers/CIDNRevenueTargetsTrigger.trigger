/****************************************************************************
@Name			: CIDNRevenueTargetsTrigger
@Author			: SFO(SanFrancisco)/Sri
@Sprint 		: 20.08[P2OB-6264]
@CreateDate		: 15/06/2020
@Description	: This Trigger is for CIDN_Revenue_Targets__c Object - P2OB-6264
*****************************************************************************/
trigger CIDNRevenueTargetsTrigger on CIDN_Revenue_Targets__c (before insert, 
                             before update,
                             before delete,
                             after insert,
                             after update,
                             after delete){
                                 //Implemeted Trigger framework
                                 fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
                             }
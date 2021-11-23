/*****************************************************************************
@Name: OpportunityContactRoleTrigger
@Author: SFO Team : Chhaveel
@CreateDate: 19/05/2021
@Description: This Class checks if Account and Contact associated with Opportunity are connected or not.
@creted as a part of P2OB-13775
*******************************************************************************/
trigger OpportunityContactRoleTrigger on OpportunityContactRole (before insert, 
                                                                 before update,
                                                                 before delete,
                                                                 after insert,
                                                                 after update,
                                                                 after delete) {          
        if(EnvironmentalSettings.isTriggerDisabled('OpportunityContactRoleTrigger')) {
               return;
         }
        //Implemeted Trigger framework
  		fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}
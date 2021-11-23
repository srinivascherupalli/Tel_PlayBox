/****************************************************************************
@Author: Shambo Ray
@CreateDate: 24/04/2018.
@Description: AccountIndustryRelationshipTrigger For Microservice
********************************************************************************/
trigger AccountIndustryRelationshipTrigger on Account_Industry_Relationship__c (after update,after insert) {
    AccountIndustryRelationshipHandler air=new AccountIndustryRelationshipHandler();
    if(Trigger.isafter && Trigger.isinsert){
        air.onAfterInsert(Trigger.new);
    }
   	if(Trigger.isafter && Trigger.isUpdate){
        air.onAfterUpdate(Trigger.new);
    }
}
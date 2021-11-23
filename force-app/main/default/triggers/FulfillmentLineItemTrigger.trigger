/*@CreateDate: 01/18/2020.
@Description: This trigger is for Fulfillineitem Object 
Note : Implemented Trigger FrameWork 
********************************************************************************/
trigger FulfillmentLineItemTrigger on FulfillmentLineItem__c (before insert,after insert, after update, before update) {
    
    //Implemeted Trigger framework 
       fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class); //EDGE-128934
}
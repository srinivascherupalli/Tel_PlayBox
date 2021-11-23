/*-------------------------------------------------------- 
EDGE-80751
Trigger: MSISDNAccountDuplicate
Description:  Trigger to check for unique Account and MSISDN key
Author:Ila
--------------------------------------------------------*/
trigger MSISDNAccountDuplicate on Service_Qualification__c(before insert){
MSISDNAccountDuplicateHandler.onBeforeInsert(Trigger.new);	 
}
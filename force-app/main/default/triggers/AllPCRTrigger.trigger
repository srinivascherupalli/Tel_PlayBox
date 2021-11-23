/*************************************************************************************************
Name : AllPCRTrigger
Description : 
1. US : EDGE-8185
	a. If user select a legacy site for the product then mark basket as legacy basket so that 
	   comparison utility UI can work based on this flag.
	b. To create a site record based on the data got from Replicator if the site is not present in Replicator
***************************************************************************************************/
trigger AllPCRTrigger on csbb__Product_Configuration_Request__c (after insert) {
	if(EnvironmentalSettings.isTriggerDisabled('AllPCRTrigger')) {
        return;
    }
    PCRTriggerHandler handler = new PCRTriggerHandler();
    
    if(Trigger.isAfter){
        //for Description item 1.a
        //handler.updateBasketLegacyStatusAfterPCRCreation(Trigger.new);
        //for Desciption item 1.b
        //handler.insertLegacySiteReplicator(Trigger.new);
    }
}
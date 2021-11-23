//description: Before delete Trigger to check validation whether agreement is activated or not, if activated, don't allow users to delete Agreement Line items
//createdDate: 22-02-2019
//author: Kunal Dixit
//JIRA : EDGE-63495
//------------------------------------------------------------------------------------------------------------------------------------

trigger APTPS_AgreementLineItemTrigger on Apttus__AgreementLineItem__c (before delete) {

    if(EnvironmentalSettings.isTriggerDisabled('APTPS_AgreementLineItemTrigger')) {
        return;
    }
    APTPS_AgreementLineItemTriggerHandler handler=new APTPS_AgreementLineItemTriggerHandler();
    if(trigger.isDelete){
        handler.beforeDeleteEvent(trigger.old);
    }

}
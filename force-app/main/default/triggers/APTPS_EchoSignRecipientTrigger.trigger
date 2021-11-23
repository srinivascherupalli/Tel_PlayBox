/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 14/09/2021 
* @Type         : Apex Trigger
* @Description  : Trigger on echosign_dev1__SIGN_Recipients__c object 
*
**/
trigger APTPS_EchoSignRecipientTrigger on echosign_dev1__SIGN_Recipients__c (after update) {
    if(EnvironmentalSettings.isTriggerDisabled('APTPS_EchoSignRecipientTrigger')){
        return;
    } 
    new APTPS_EchoSignRecipientTriggerHandler(echosign_dev1__SIGN_Recipients__c.sObjectType).run();
}
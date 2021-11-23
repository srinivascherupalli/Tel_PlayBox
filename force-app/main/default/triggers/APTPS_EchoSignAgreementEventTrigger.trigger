/**
* 
* @author       : Gautam Kumar
* @version      : 1.0
* @createdDate  : 07/10/2021 
* @Type         : Apex Trigger
* @Test Class   : APTPS_EchoSignAgreementEventTrigger
* @Description  : trigger on echosign_dev1__SIGN_AgreementEvent__c object
*
**/
trigger APTPS_EchoSignAgreementEventTrigger on echosign_dev1__SIGN_AgreementEvent__c (after insert) {
    if(EnvironmentalSettings.isTriggerDisabled('APTPS_EchoSignAgreementEventTrigger')){
        return;
    } 
    system.debug('G*G agreement event trigger called');
    new APTPS_EchoSignAgreementEventTrgHandler(echosign_dev1__SIGN_AgreementEvent__c.sObjectType).run();
}
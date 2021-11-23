/**========================================================================================
* @Author :      Tejasvi K S, Charan
* @Description : This Trigger is defined to Handle echosign_dev1__SIGN_Agreement__c events
* @CreatedDate : 10/1/2021
* @Last Modified : Lokesh Thathuru - Date:10/1/2021
* @Last Modified : Lokesh Thathuru - Date:10/12/2021 added Try catch to Exception Log creation
============================================================================================*/
trigger APTPS_AdobeAgreementTrigger on echosign_dev1__SIGN_Agreement__c (after update, after insert) {
    APTPS_AdobeAgreementTriggerHandler handler = new APTPS_AdobeAgreementTriggerHandler();
    public static boolean runOnce = true;
    if(FeatureEligibilityChecker.determineFeatureEligiblity('APTPS_AdobeAgreementTrigger_TED_383', 'adobe')){
        //This condition helps to handle the after Insert Event
        if(Trigger.isAfter){
            try{ // Added Exception Logging (10/12/2021)
                if(Trigger.isInsert && runOnce){
                    APTPS_AdobeAgreementTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
                }
                if(Trigger.isUpdate && runOnce){    
                    
                    APTPS_AdobeAgreementTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
                }
                runOnce = false;
            }catch(AgreementException agreementExceptionInstance){
                Agreementutilities.logException(agreementExceptionInstance.methodName,agreementExceptionInstance.referenceNumber,'',agreementExceptionInstance.errorMessage,agreementExceptionInstance.businessDescription);
            }
        }
    }
}
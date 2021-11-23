/*
 * Created by: Ivan Aerlic
 */
trigger UserTriggerFramework on User (before insert, before update, after update) {
    if(!EnvironmentalSettings.isTriggerDisabled('UserTriggerFramework')) 
    		fflib_SObjectDomain.triggerHandler(ATF_SObjectDomain.class);
}
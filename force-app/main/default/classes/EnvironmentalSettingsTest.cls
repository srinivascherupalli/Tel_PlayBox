@IsTest
public class EnvironmentalSettingsTest {

    @isTest static void testIsNoTriggerDisabled() {
        
        Test.startTest();
        Environment_Configurations__c settings = new Environment_Configurations__c();
        settings.No_Triggers__c = True;
        insert settings;
        
        Environment_Configurations__c settinghy = Environment_Configurations__c.getOrgDefaults();
				settinghy.Exclude_Integration_Handlers__c = 'Some Value';
				upsert settinghy Environment_Configurations__c.Id;
        
        EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('testTriggerName');
        EnvironmentalSettings.isLoggingEnabled();
        EnvironmentalSettings.isValidHandler('TestHandlerName');
        Test.stopTest();
        
        System.assert(EnvironmentalSettings.isTriggerDisabled('testTriggerName'), 'Error: Trigger is not disabled' );
    }

    @isTest static void testIsSpecificTriggerDisabled() {
        System.assert(!EnvironmentalSettings.isTriggerDisabled('testTriggerName'), 'Error: Trigger is disabled' );
        
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'testTriggerName';
        insert disabledTriggersProfile;
        
        System.assert(EnvironmentalSettings.isTriggerDisabled('testTriggerName'), 'Error: Trigger is not disabled' );
        
        Disabled_Triggers__c disabledTriggersUser = new Disabled_Triggers__c();
        disabledTriggersUser.SetupOwnerId = UserInfo.getUserId();
        disabledTriggersUser.Trigger_Name_List1__c = 'Trigger1,Trigger2';
        insert disabledTriggersUser;
        
        EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('testTriggerName');
        EnvironmentalSettings.isLoggingEnabled();
        EnvironmentalSettings.isValidHandler('TestHandlerName');

        System.assert(!EnvironmentalSettings.isTriggerDisabled('testTriggerName'), 'Error: Trigger is disabled' );
    }

    @isTest static void testNegatives() {
        System.assert(!EnvironmentalSettings.isTriggerDisabled('testTriggerName'), 'Error: Trigger is disabled' );
        
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'testTriggerName';
        insert disabledTriggersProfile;
        
        EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('testTriggerName');
        EnvironmentalSettings.isLoggingEnabled();
        EnvironmentalSettings.isValidHandler('TestHandlerName');
        
        System.assert(!EnvironmentalSettings.isTriggerDisabled('testTriggerName2'), 'Error: Trigger2 is disabled' );
   }
    
   /* static testmethod void callingmethods(){
        
        EnvironmentalSettings es = new EnvironmentalSettings();
        EnvironmentalSettings.isTriggerDisabled('testTriggerName');
        EnvironmentalSettings.isLoggingEnabled();
        EnvironmentalSettings.isValidHandler('TestHandlerName');
        
    }*/
}
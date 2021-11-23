public class EnvironmentalSettings {
    
    public static Boolean isTriggerDisabled(String triggerName) {
        return (isAllTriggersDisabled() || 
        isSpecificTriggerDisabled(triggerName));
    }

    private static Boolean isAllTriggersDisabled() {
        Environment_Configurations__c environmentConfig = Environment_Configurations__c.getInstance();
        return (environmentConfig != null && environmentConfig.No_Triggers__c);
    }

    private static Boolean isSpecificTriggerDisabled(String triggerName) {
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Disabled_Triggers__c.fields.getMap();
        List<String> triggerListFieldNames = new List<String>();
        Set<String> disabledTriggerSet = new Set<String>(); 

        Disabled_Triggers__c disabledTriggersRecord = Disabled_Triggers__c.getInstance();        
        for(String fld : fieldMap.keySet()) {
            if(fld.contains('trigger_name_list')) { 
                triggerListFieldNames.add(fld);
            }
        }

        for(String fldName : triggerListFieldNames) {
            String fldVal = (String)disabledTriggersRecord.get(fldName);
            if(!String.isBlank(fldVal)) {
                List<String> tempTriggerNameList = fldVal.split(',');
                for(String tName : tempTriggerNameList) {
                    disabledTriggerSet.add(tName.trim()); 
                }
            }
            System.debug('DisabledTriggerSet: ' + disabledTriggerSet);
        }
    
        if(disabledTriggerSet.contains(triggerName.trim())) {
            return true;
        }    

        return false;
    }
    
     public  static Boolean isLoggingEnabled() {
        Environment_Configurations__c environmentConfig = Environment_Configurations__c.getInstance();
        return (environmentConfig != null && environmentConfig.Custom_Logging__c);
    }
    public  static Boolean isSeedingEnabled() {        
        Environment_Configurations__c environmentConfig = Environment_Configurations__c.getInstance();
        return (environmentConfig != null && environmentConfig.SeedingEnabled__c);
    }
    
    
    
    @TestVisible
    public static Boolean isValidHandler(String handlerName) {                  
		List<String> excludedHandlerList;
		Set<String> excludedHandlerSet = new Set<String>();
		Logger log = Logger.getLogger(handlerName);

        Environment_Configurations__c environmentalSettings = Environment_Configurations__c.getInstance(UserInfo.getUserId());
		String excludedHandlers;
		Boolean isValidHandler = true;

        try {
	        excludedHandlers = environmentalSettings.Exclude_Integration_Handlers__c;
	        
			if (String.isNotEmpty(excludedHandlers)) {
				excludedHandlerList = excludedHandlers.split(',');
				
				if (excludedHandlerList != null && !excludedHandlerList.isEmpty()) {					
					for (String handler : excludedHandlerList) {
						excludedHandlerSet.add(handler.trim());
					}			
				}						
			}

	        if (excludedHandlerSet.contains(handlerName)) {
      			isValidHandler = false;
	        }
	        
	        system.debug('IsValidHandler: ' + isValidHandler);
        } catch (Exception e) {
            log.debug(e);
            throw e;
        }       
        Logger.exitLogger();
        return isValidHandler;           
    }    
}
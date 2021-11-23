/******************************************************************************************************
    *Class Name     : SourceSubscriptions
    *Decription     : Observer class for logic to filter source subscriptions in chown
    *Test Class     : MigrateSubscriptionsTest

********************************************************************************************************/

public with sharing class SourceSubscriptions implements MigrateSubscriptionObserver{


    public Map<String, Object> executeLogic(Map<String, Object> inputMap) {
    
        Map<String, Object> outputMap = MigrateSubscriptionCustomUtility.filterSubscriptions(inputMap);
        return outputMap;
	}

}
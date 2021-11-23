/******************************************************************************************************
    *Class Name     : TargetAccounts
    *Decription     : Observer class for logic to filter target accounts in chown
    *Test Class     : MigrateSubscriptionsTest

********************************************************************************************************/

public with sharing class TargetAccounts implements MigrateSubscriptionObserver{


    public Map<String, Object> executeLogic(Map<String, Object> inputMap) {
    
        Map<String, Object> outputMap = MigrateSubscriptionCustomUtility.filterAccounts(inputMap);
        return outputMap;
  }

}
/******************************************************************************************************
    *Class Name     : TargetSolutions
    *Decription     : Observer class for logic to filter target solutions in chown
    *Test Class     : MigrateSubscriptionsTest

********************************************************************************************************/

public with sharing class TargetSolutions implements MigrateSubscriptionObserver{

    public Map<String, Object> executeLogic(Map<String, Object> inputMap) {
        system.debug('inputMap==>'+inputMap);
        Map<String, Object> outputMap = MigrateSubscriptionCustomUtility.filterTargetSolutions(inputMap);

        return outputMap;
  }

}
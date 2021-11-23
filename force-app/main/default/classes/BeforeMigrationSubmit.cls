/******************************************************************************************************
    *Class Name     : BeforeMigrationSubmit
    *Decription     : Observer class for logic before migration submit in chown
    *Test Class     : MigrateSubscriptionsTest

********************************************************************************************************/

public with sharing class BeforeMigrationSubmit implements MigrateSubscriptionObserver{

     public Map<String, Object> executeLogic(Map<String, Object> inputMap) {
        Map<String, Object> outputMap = MigrateSubscriptionCustomUtility.beforeMigrationSubmission(inputMap);
        return outputMap;
  }
}
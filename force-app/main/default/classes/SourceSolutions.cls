/******************************************************************************************************
    *Class Name     : SourceSolutions
    *Decription     : Observer class for logic to filter source solutions in chown
    *Test Class     : MigrateSubscriptionsTest

********************************************************************************************************/

public with sharing class SourceSolutions implements MigrateSubscriptionObserver{


    public Map<String, Object> executeLogic(Map<String, Object> inputMap) {
    
        Map<String, Object> outputMap = MigrateSubscriptionCustomUtility.filterSolutions(inputMap);
        return outputMap;
	}

}
public class MigrateSubscriptionCustomLogic implements MigrateSubscriptionObserver {
  
    public Map<String, Object> executeLogic(Map<String, Object> inputMap){
        system.debug('inputMap in observer!! '+inputMap);

        system.debug('basket1 in observer!! '+inputMap.get('basket1'));
        system.debug('basket2 in observer!! '+inputMap.get('basket2'));
        List<Id> solList = (List<Id>) inputMap.get('basket1');
        if (inputMap.get('basket2') != null) {
			//List<Id> targetSolution = (List<Id>) inputMap.get('basket2');
            //solList.add(targetSolution);
        }
        system.debug('solList in observer!! '+solList);

       /* Map<String, Object> basketMap = new Map<String, Object>{
            'basket1' => solList
        };*/

		Map<String, Map<String, Object>> outputMap = new Map<String, Map<String, Object>>{
            'allbaskets' => inputMap
        };

        return outputMap;

    }
  
}
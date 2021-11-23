/******************************************************************************************************
    *Class Name     : CustomCollectionUtility
    *Test Class     : CustomCollectionUtilityTest
    *Description : Class that contains utility method to translate collections

Ch.No.    Developer Name          Date          Story Description
_________________________________________________________________
1.        Vamsi Krishna Vaddipalli 25.MAR.2021   EDGE-178892

*******************************************************************************************************/

public with sharing class CustomCollectionUtility {
	public static Map<String,List<Id>> copyMap(Map<String,List<Id>> returnMap,Map<String,List<Id>> fromMap){
        if(fromMap != null && !fromMap.isEmpty())
        {
            for(String fromKey : fromMap.keySet())
            {
            List<Id> objList ;
            if(returnMap != null && !returnMap.isEmpty() && returnMap.containsKey(fromKey))
                objList = returnMap.get(fromKey);
            else
                objList = new List<Id>();
            objList.addAll(fromMap.get(fromKey));
            returnMap.put(fromKey,objList);
        }
        }

        return returnMap;
    }
}
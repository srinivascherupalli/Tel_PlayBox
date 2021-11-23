public with sharing class FeatureFlagUtility {
    private static Map<String, Feature_Flag__mdt> togglineFeatureMap;
    Static{
        togglineFeatureMap = new Map<String, Feature_Flag__mdt>();
        For(Feature_Flag__mdt  ft: [Select Id, DeveloperName, IsActive__c, Permission_Set_Name__c, Profile_Name__c from Feature_Flag__mdt ]){
            togglineFeatureMap.put(ft.DeveloperName, ft);
        }
    }
    
    public static Feature_Flag__mdt getFeatureTogglingByName(String featureName){
        if(togglineFeatureMap != null && togglineFeatureMap.containsKey(featureName)){
            return togglineFeatureMap.get(featureName);
        }
        return null;
    }
}
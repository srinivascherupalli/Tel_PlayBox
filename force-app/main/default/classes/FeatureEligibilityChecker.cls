public without sharing class FeatureEligibilityChecker { 
    
    @testVisible private static Map<String, List<SObject>> customMetadataRecordsMap = new Map<String, List<SObject>> ();
    @testVisible
    private static List<SObject> getCustomMetadataRecords(String developerName, String flow) {
    	
        customMetadataRecordsMap = new Map<String, List<SObject>> (); //DEFECT DIG-20654  
        
        if(flow==null && developerName == null){
            return null;
        }
        FeatureToggle__mdt mdtRec = FeatureToggle__mdt.getInstance(developerName);
        if(mdtRec==null){
            return null;
        }
        if(flow == null || flow == ''){
            return new List<SObject>{mdtRec};
                }
        if (customMetadataRecordsMap.containsKey(flow)) {
            return customMetadataRecordsMap.get(flow);
        }
        if(String.isEmpty(mdtRec?.EnabledFlows__c)){
            return null;
        }
        else{
            if(mdtRec?.EnabledFlows__c.split(',').contains(flow)){
                customMetadataRecordsMap.put(flow,new List<SObject>{mdtRec});
            } 
        }
        
        //customMetadataRecordsMap.put(flow, [SELECT EnableForAll__c, EnabledFlows__c, EnableOnlyForBVT__c, EnableOnlyForSelectPS__c, DeveloperName FROM FeatureToggle__mdt WHERE(EnabledFlows__c LIKE: flow or EnabledFlows__c LIKE 'All')]);
        return customMetadataRecordsMap.get(flow);
    }
    
    public static Boolean determineFeatureEligiblity(String developerName, String flow) {
        
        Map<String, Object> enabledFeatures = new Map<String, Object> ();
        List<FeatureToggle__mdt> listOfEnabledFeatures = getCustomMetadataRecords(developerName,flow);
        String userType;
        Boolean enabledFeaturesFlag = false;
        if (listOfEnabledFeatures == null || listOfEnabledFeatures.size()== 0) {
            return false;
        }
        try {
            Id currentUser =  UserInfo.getUserId();      
            for (FeatureToggle__mdt f: listOfEnabledFeatures) {
                if(f.EnableForAll__c){
                    enabledFeaturesFlag = f.EnableForAll__c;
                }else{
                    if(userType == null){
                        userType = checkUserType(currentUser);
                    } 
                    if (userType.equals('BVTUser')) {
                        enabledFeaturesFlag = f.EnableOnlyForBVT__c; //true,false
                    }else if (userType.equals('PSUser')) {
                        enabledFeaturesFlag = f.EnableOnlyForSelectPS__c; //true,false
                    } 
                }  
            } 
        }        
        catch (Exception e) {
            enabledFeaturesFlag = false;  
        }
        system.debug('SOQL Limits::'+ Limits.getQueries());
        return enabledFeaturesFlag;
    }
    
    public static String checkUserType(Id currentUserId) {
        String userType = '';
        Set<String> userAssignedPSList;
        userAssignedPSList = getUserPermissionSet(currentUserId);
        if (userAssignedPSList.isEmpty()){
            return userType;
        }
        if (userAssignedPSList.contains('PS_EnablePilotFeature')) {
            userType = 'PSUser';
        }
        if(userAssignedPSList.contains('PS_BVT_User')){
            userType = 'BVTUser';
        }
        return userType;
    }
    
    public static Set<String> getUserPermissionSet(Id currentUser) {
        Set<String> userAssignedPS = new Set<String> ();
        List<PermissionSetAssignment> permissionSetName = (List<PermissionSetAssignment>) Cache.Org.get(PermissionSetInfoCache.class, currentUser);
        //List<PermissionSetAssignment> permissionSetName = [SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =: currentUser];
        
        for (PermissionSetAssignment p: permissionSetName) {
            userAssignedPS.add(p.PermissionSet.Name);
        }
        return userAssignedPS;
    }
    @InvocableMethod(label='BlankActionMethod' description='To suppress processbuilder execution in case metadata is turned off as part of feature toggling.')
    public static void BlankActionMethod() {
        system.debug('Entered BlankActionMethod');
    }
    
    class PermissionSetInfoCache implements Cache.CacheBuilder {
    public Object doLoad(String userid) {
        List<PermissionSetAssignment> permissionSets = (List<PermissionSetAssignment>)[SELECT PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId =:userId];
        return (permissionSets!= null?permissionSets:new List<PermissionSetAssignment>());
    }
}
    
    
    
}
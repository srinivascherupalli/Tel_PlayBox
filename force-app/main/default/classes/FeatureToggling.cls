/*****************************************************************************
@Name: FeatureToggling
@Author: Murali Nunna
@CreateDate: 02/07/2018
@Description: This Class is used for enable/disable the permission for specific functinality 
			  to the users as per profile or permissionset
*******************************************************************************/
public with sharing class FeatureToggling {
    
    private static Map<String,Feature_Flags__mdt> togglingSettingMap;
    private static Map<String,Feature_Flags__mdt> togglingSettingMapByID;
    private static Map<String,Integration_Handler__mdt> intigriHandlerMap;
    static{
        togglingSettingMap=new Map<String,Feature_Flags__mdt> ();
        togglingSettingMapByID=new Map<String,Feature_Flags__mdt> ();
        List<Feature_Flags__mdt> featureFlagList=[SELECT Active__c,DeveloperName,Id,
                                                  Permission_Set__c,
                                                  Profile__c FROM Feature_Flags__mdt];
        for(Feature_Flags__mdt ff: featureFlagList){
            togglingSettingMap.put(ff.DeveloperName,ff);
            togglingSettingMapByID.put(ff.id,ff);
        }
        intigriHandlerMap=new Map<String,Integration_Handler__mdt> ();
        /*List<Integration_Handler__mdt> integriHandlerList=[SELECT DeveloperName,Feature_Flags__c,Id,
                                                           Label FROM Integration_Handler__mdt];
        for(Integration_Handler__mdt Ih: integriHandlerList){
            intigriHandlerMap.put(ih.DeveloperName,Ih);
        }*/
        
    }
    //Pass FeatureName As INPUT and get the Feature_Flags__mdt record
    public static Feature_Flags__mdt getFeatuteTogglingByName(String featureName){
        if(togglingSettingMap!=null && !togglingSettingMap.isEmpty() && togglingSettingMap.containsKey(featureName)){
            return togglingSettingMap.get(featureName);
        }
        return null;
    }
    
    //Pass FeatureName As INPUT and get the list Feature_Flags__mdt records tsrats with feature name
    public static List<Feature_Flags__mdt> getListOfFeatuteTogglingByName(String featureName){
        system.debug('<--------FeatureFlagName-------->'+featureName);
        List<Feature_Flags__mdt> listFeatureFlags;
        if(togglingSettingMap!=null && !togglingSettingMap.isEmpty()){
            listFeatureFlags=new List<Feature_Flags__mdt>();
            Set<String> allFeatureFlagNames=togglingSettingMap.keySet();
            for(String feName : allFeatureFlagNames){
                if(feName!=null && feName.startsWithIgnoreCase(featureName)){
                    if(togglingSettingMap.containsKey(feName)){
                        listFeatureFlags.add(togglingSettingMap.get(feName));
                    }
                }
            }
            
            return listFeatureFlags;
        }
        return null;
    }
    //Pass Handler As INPUT and get the Integration_Handler__mdt record
    /* public static Integration_Handler__mdt getIntegrationHandlerByName(String handler){
if(intigriHandlerMap!=null && !intigriHandlerMap.isEmpty() && intigriHandlerMap.containsKey(handler)){
return intigriHandlerMap.get(handler);
}
return null;
}*/
    public static boolean featureUtility(String featureFlagDeveloperName){
        //try{			
        // To get Current logIn User ProfileID 
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        // To get Current logIn User Profile Name 
        
        List<PermissionSetAssignment> pss=[select PermissionSet.Name,Assignee.Name,Assignee.Id,Assignee.IsActive
                                           from PermissionSetAssignment WHERE Assignee.IsActive=:TRUE AND Assignee.Name=:UserInfo.getName()];
        
        //Checking intiHandler and featureFlagDeveloperName value either null or NOT IF not null went in 
        if(featureFlagDeveloperName!=null && featureFlagDeveloperName!='' && !String.isEmpty(featureFlagDeveloperName)){  //intiHandler!=null &&
            //To get featureFlagDeveloperName record related to the handler.
            //Feature_Flags__mdt FeatureFlaName=getFeatuteTogglingByName(featureFlagDeveloperName);
            List<Feature_Flags__mdt> listFeatureFlaName=getListOfFeatuteTogglingByName(featureFlagDeveloperName);
            Boolean value=FALSE;
            for(Feature_Flags__mdt FeatureFlaName : listFeatureFlaName){
                if(utility(FeatureFlaName,pss,profileName) ==TRUE){
                    value= TRUE;
                    system.debug('@@@@@@@@@@@@@@@@@@@@--->TRUE');
                    break;
                }
                
                
            }
            if(value){
                return true;
            }
            // if(FeatureFlaName==null ){
            //    system.debug('<------FeatureFlag is Empty----->');
            //    return false;
            //    }
        }
        //intigrationHandler or featureFlags value is null then return false
        //return false;
        //}
        //catch(Exception Ex){
        //    system.debug('Exception in FutureToggling class-->'+Ex.getMessage());
        // }
        return false;
    }
    
    public static List<String> getUserPermissionSets(List<PermissionSetAssignment> permissionSetAssignment){
        map<Id,List<String>> userPermissionSetMap=new map<Id,List<String>>();
        for(PermissionSetAssignment psa : permissionSetAssignment){
            if(psa!=null){
                List<String> listpsa=userPermissionSetMap.get(psa.Assignee.Id);
                if(null==listpsa){
                    listpsa=new List<String>(); 
                    userPermissionSetMap.put(psa.Assignee.Id, listpsa);
                }
                listpsa.add(psa.PermissionSet.Name);
            }
        }
        return userPermissionSetMap.get(UserInfo.getUserId());
        
    }
    /* Checking permissiionsetName invoked in featureFlaNameActive Method.
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: permissiionsetName(string)
        Output Param: boolean 
        */
    public static boolean isPermissiionsetNameEmpty(String permissiionsetName){
        if(permissiionsetName=='NONE' || permissiionsetName=='' || String.isEmpty(permissiionsetName)){
            return true;
        }
		return false;
    }
    /* Checking userPermissionSets invoked in featureFlaNameActive Method.
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: userPermissionSets(List<String>)
				     permissiionsetName(string)
        Output Param: boolean
        */
    public static boolean isUserPermissionSetsNotEmpty(List<String> userPermissionSets,String permissiionsetName){
        if(userPermissionSets!=null && userPermissionSets.size()>0 && !userPermissionSets.isEmpty()) {
            if(userPermissionSets.contains(permissiionsetName)) {
                return true;
            }
            return false;
        }
        return false;
    }
    /* Checking FeatureFlaName.Profile__c invoked in featureFlaNameActive Method.
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: FeatureFlaName(Feature_Flags__mdt)
        Output Param: boolean 
        */
    public static boolean isFeatureFlagProfileEmpty(Feature_Flags__mdt FeatureFlaName){
        if(FeatureFlaName.Profile__c=='NONE'|| FeatureFlaName.Profile__c =='' || String.isEmpty(FeatureFlaName.Profile__c)) {
            return true;
        }
		return false;
    }
     /* Checking FeatureFlaName.Permission_Set__c invoked in featureFlaNameActive Method.
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: FeatureFlaName(Feature_Flags__mdt)
        Output Param: booelan
        */
    public static boolean isFeatureFlagPermissionSetsNotEmpty(Feature_Flags__mdt FeatureFlaName){
        if(FeatureFlaName.Permission_Set__c!='NONE' || FeatureFlaName.Permission_Set__c!=''|| !String.isEmpty(FeatureFlaName.Permission_Set__c)){
            return true;
        }
            return false;
    }
     /* Checking profileName and FeatureFlaDeveloperName.profile__c invoked in featureFlaNameActive Method.
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: profileName(string)
                     FeatureFlaDeveloperName(string)
        Output Param: boolean 
        */
    public static boolean isSameProfileNames(String profileName,String FeatureFlaDeveloperName){
        if(profileName==getFeatuteTogglingByName(FeatureFlaDeveloperName).Profile__c) {
            return true;
        }
        return false;
    }
    /* 
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: FeatureFlaName(Feature_Flags__md)
                     permissionSetAssignment (List<PermissionSetAssignment>)
                     profileName(string)
        Output Param: boolean 
        */
    public static boolean utility(Feature_Flags__mdt FeatureFlaName,List<PermissionSetAssignment> permissionSetAssignment,String profileName){
        
        system.debug('<------Profile Name----->'+profileName);
        //Getting current login User assigned Permissinsets by userID
        List<String> userPermissionSets=getUserPermissionSets(permissionSetAssignment);
        // featureFlagDeveloperName record is not equals to NULL
        if(FeatureFlaName!=null ){
            system.debug('*********Flag record NOT null Then***************'+FeatureFlaName.DeveloperName);
            //getting permissionset from Related FeatureFlag record
            String permissiionsetName=FeatureFlaName.Permission_Set__c;
            //Checking is Active flag is TRUE or Flase
            if(FeatureFlaName.Active__c){
                return featureFlaNameActive(FeatureFlaName,permissionSetAssignment,profileName);
            }
            return false;
        }
        return false;	
    } 
    /* 
        Sprint 19.17, P2OB-4310 Seperated to reduce cyclomatic complexity
        Input Param: FeatureFlaName(Feature_Flags__mdt)
                     permissionSetAssignment(List<PermissionSetAssignment>)
                     profileName(string)
        Output Param: boolean 
        */
    public static boolean featureFlaNameActive(Feature_Flags__mdt FeatureFlaName,List<PermissionSetAssignment> permissionSetAssignment,String profileName){
        String permissiionsetName=FeatureFlaName.Permission_Set__c;
        List<String> userPermissionSets=getUserPermissionSets(permissionSetAssignment);        
        system.debug('***********Is feature Flag Is Active*************'+FeatureFlaName.Active__c);
        //In Future Flag Record, Profile VAlue is equal to ALL return TRUE
        if(FeatureFlaName.Profile__c=='ALL'){
            system.debug('<----------Profile Name is ALL----------->');
            return true;
        }
        //In Future Flag Record, Profile,permission VAlue is equal to NONE  return FALSE
        if(isFeatureFlagProfileEmpty(FeatureFlaName)){
            if(isPermissiionsetNameEmpty(permissiionsetName)){ 
                system.debug('<----------Profile Name and permission Set is NONE----------->');
                return false;
            }
            if(!isPermissiionsetNameEmpty(permissiionsetName)){
				//return isUserPermissionSetsNotEmpty(userPermissionSets);
				return isUserPermissionSetsNotEmpty(userPermissionSets,permissiionsetName);
            }
        }
        if(isPermissiionsetNameEmpty(permissiionsetName)){
            return isSameProfileNames(profileName,FeatureFlaName.DeveloperName);                    
        }
        if((!isFeatureFlagProfileEmpty(FeatureFlaName)) || (isFeatureFlagPermissionSetsNotEmpty(FeatureFlaName))){
            if(isUserPermissionSetsNotEmpty(userPermissionSets,permissiionsetName)) {
                return true;
            }
			return isSameProfileNames(profileName,FeatureFlaName.DeveloperName);                                
        }
		return false;
	}    
}
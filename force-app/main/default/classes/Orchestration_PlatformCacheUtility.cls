/**================================================================
 * Name: Orchestration_PlatformCacheUtility
 * Description: Utility Class to insert or update platformcache
==================================================================*/
public class Orchestration_PlatformCacheUtility {
    public static integer seq = 0;
    
    public static void updatePlatformCache(list<sobject> listSObject){
        try{
            Coms_PlatformCacheUtil.insertSobjectsToPlatformCache(listSObject);                   
        }
        catch(Exception ex){
            system.debug('Update Platform Cache Failed' + ex);
        }
    }
    // Input List<object> 
   /* public static Map<string , string> convertObjecttoserviceslist(List<Object> obj , string fieldName){
        Set<ID> idSet = new Set<ID>{'a4e2N0000006lhTQAQ' ,'a4A2N0000001y66'};
        Map<string, string> mapFieldWithValues = new Map<string, string>();
        Map<id, Map<string , string>> mapName = new Map<id, Map<string , string>>();
        List<csord__service__c> servList = new List<csord__service__c>();
        List<Object>serviceList1=Coms_PlatformCacheUtil.getListOfServicesFromCache(idSet);
        system.debug('convertObjecttoserviceslist :: found serviceList1-- > ' + serviceList1);
        for(object service:serviceList1){
            Map<String, Object> s1=(Map<String, Object>)service;
            if(s1.containsKey(fieldName)){
                mapFieldWithValues.put(fieldName , String.valueof(s1.get(fieldName)));
                system.debug('convertObjecttoserviceslist :: found iteratorBiilingAccount-- > ' + mapFieldWithValues);
            }
        }        
        System.debug('Orchestration_PlatformCacheUtility :: convertObjecttoserviceslist :: found mapFieldWithValues ---> ' + mapFieldWithValues);

        List<csord__service__c> serviceList = new List<csord__service__c>();
        return mapFieldWithValues;
    }*/

    /**
    * @description 
    * @author Rohit Pal | 09-23-2021 
    * @param obj 
    * @param strRelationshipObject 
    * @return List<object> 
    **/
/*    public static List<object> getRelatedObjectInfo(List<Object> obj , string strRelationshipObject){
        Set<ID> idSet = new Set<ID>{'a4e2N0000006lhTQAQ' ,'a4A2N0000001y66'};
        Map<string, string> mapFieldWithValues = new Map<string, string>();
        List<Object> listRelatedObjets = new List<Object>();
        Map<id, Map<string , string>> mapName = new Map<id, Map<string , string>>();
        List<csord__service__c> servList = new List<csord__service__c>();
        List<Object>serviceList1=Coms_PlatformCacheUtil.getListOfServicesFromCache(idSet);
        system.debug('convertObjecttoserviceslist :: found serviceList1-- > ' + serviceList1);
        for(object service:serviceList1){
            Map<String, Object> s1=(Map<String, Object>)service;
            if(s1.containsKey(strRelationshipObject)){
                system.debug('convertObjecttoserviceslist :: found s1-- > ' + s1);
                Map<String,Object> s21 = (Map<String,Object>)(s1.get(strRelationshipObject));
                listRelatedObjets.addAll(s21.values());
                system.debug('getRelatedObjectInfo==== ' +s21);
            }
        }        
        System.debug('Orchestration_PlatformCacheUtility :: getRelatedObjectInfo :: found listRelatedObjets ---> ' + listRelatedObjets);
        return listRelatedObjets;
    }

    public List<csord__subscription__c> convertObjecttosubslist(List<Object> obj){
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        return subsList;
    }
    public List<csord__Subscription__c> convertObjecttotechObjList(List<Object> obj){
        List<csord__Subscription__c> tobjList = new List<csord__Subscription__c>();
        return tobjList;
    }
    public List<csord__Order__c> convertObjecttoOrderList(List<Object> obj){
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        return orderList;
    }*/

    /**
    * @description 
    * @author Rohit Pal | 09-22-2021 
    * @return set<id> 
    **/
   /* public static set<id> getRelatedObjectIds(List<Object> obj , string fieldName , string strRelationshipObject){
        Set<ID> idSet = new Set<ID>{'a4e2N0000006lhTQAQ' ,'a4A2N0000001y66'};
        Map<string, string> mapFieldWithValues = new Map<string, string>();
        Map<id, Map<string , string>> mapName = new Map<id, Map<string , string>>();
        List<csord__service__c> servList = new List<csord__service__c>();
        Set<id> setRelatedIds = new Set<id>();
        List<Object>serviceList1=Coms_PlatformCacheUtil.getListOfServicesFromCache(idSet);
        system.debug('convertObjecttoserviceslist :: found serviceList1-- > ' + serviceList1);
        for(object service:serviceList1){
            Map<String, Object> s1=(Map<String, Object>)service;
            if(s1.containsKey(fieldName)){
                mapFieldWithValues.put(fieldName , String.valueof(s1.get(fieldName)));
                system.debug('convertObjecttoserviceslist :: found iteratorBiilingAccount-- > ' + mapFieldWithValues);
            }else if(s1.containsKey(strRelationshipObject)){
                system.debug('convertObjecttoserviceslist :: found s1-- > ' + s1);
                Map<String,Object> s21 = (Map<String,Object>)(s1.get(strRelationshipObject));
                system.debug('convertObjecttoserviceslist :: found s21-- > ' + s21);
                for(string iteratorBiilingAccount : s21.keySet() ){
                    // this can be dynamic based on Id , Billing_Account_Owner__c  RecordTypeId etc. using a variable
                    if(iteratorBiilingAccount == 'Id'){
                        setRelatedIds.add(String.valueof(s21.get(iteratorBiilingAccount)));
                    }
                    system.debug('convertObjecttoserviceslist :: found iteratorBiilingAccount-- > ' + iteratorBiilingAccount);
                }
            }
        }        
        System.debug('Orchestration_PlatformCacheUtility :: convertObjecttoserviceslist :: found setRelatedIds ---> ' + setRelatedIds);
        return setRelatedIds;
    }*/
}
public class OrchestrationCacheBackupManager {

    public static String get(String key) {
        List<OrchestrationCacheBackup__c> backup = [SELECT Id, Key__c, Value__c FROM OrchestrationCacheBackup__c WHERE Key__c = :key LIMIT 1];
        if(!backup.isEmpty()) {
            return backup[0].Value__c;
        }else {
            return null;
        }
    }
     
    public static void put(Map<String,Object> mapKeyVsBackupData) {
        List<OrchestrationCacheBackup__c> listOfBackupResult = new List<OrchestrationCacheBackup__c>();
        for(String key : mapKeyVsBackupData.keySet()){
            listOfBackupResult.add(initializeRecord(key, JSON.serialize(mapKeyVsBackupData.get(key))));
        }
        upsert listOfBackupResult;
    }
    
    private static OrchestrationCacheBackup__c initializeRecord(String key, String value){
        OrchestrationCacheBackup__c backupResult = new OrchestrationCacheBackup__c();
        backupResult.Key__c = key;
        backupResult.Value__c = value;
        return backupResult;
    }
    
    public static void remove(Set<String> key) {
        List<OrchestrationCacheBackup__c> backupResults = [SELECT Id, Key__c, Value__c FROM OrchestrationCacheBackup__c 
                                                           WHERE Key__c IN :key];
        delete backupResults;
    }

}
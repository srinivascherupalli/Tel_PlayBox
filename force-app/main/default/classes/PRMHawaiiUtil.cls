/*
Version     Team        Author              Description
1.0         Hawaii      Vivian Charlie      Initial Draft : DIGI-15298
*/
public without sharing class PRMHawaiiUtil {
    // DIGI-15298 Replacing custom labels with metadata records
    @AuraEnabled
    public static String returnMetadataRecord(String recordName){
        return ConstantMetadataUtility__mdt.getInstance(recordName).Value__c;
    }
}
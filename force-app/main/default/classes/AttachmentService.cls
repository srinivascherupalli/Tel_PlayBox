public with sharing class AttachmentService {
    private static Set<String> prefixIds = new Set<String>();
    private Static Set<String> lstObjNames = new Set<String>();
	/*
     * This method will except the Object Name  and return the Prefix of the record id
      */
    Public Static Set<String> getKeyPrefix(Set<String> lstObjNames){
        if(prefixIds.isEmpty()){
            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe();        
             if(!lstObjNames.isEmpty()){
                for(String objName : lstObjNames){
                    Schema.SObjectType sobjType = gd.get(objName);
                    Schema.DescribeSObjectResult r = sobjType.getDescribe();
                    prefixIds.add(r.getKeyPrefix());
                }
                
            }
        }
        
		return prefixIds;
    }
    
    /*
     * This method will return the Prefix of the Object
      */
    Public Static Set<String> getallObjectName(){
        if(lstObjNames.isEmpty()){
            List<Allow_For_Attachment__c> allRecords = Allow_For_Attachment__c.getall().values();
            if(!allRecords.isEmpty()){
                for(Allow_For_Attachment__c s : allRecords){
                	lstObjNames.add(s.Name);
            	}
            }            
        }        
		return lstObjNames;
    }
    
    public static void deleteAttachment(List<Attachment> lstAttachment){
        if(!lstAttachment.isEmpty())
            delete lstAttachment;
        
    }
}
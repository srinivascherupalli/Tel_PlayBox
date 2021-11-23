global with sharing class CS_DRCRecord extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["OpptyId"]';
    }
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
        System.debug('***searchFields.get(OpptyId)****' +searchFields.get('OpptyId'));
        system.debug('***searchFields.containsKey(OpptyId)***'+searchFields.containsKey('OpptyId'));
        List<Deal_Support_Request__c> dsrList= new List<Deal_Support_Request__c>();
        
        if(searchFields.get('OpptyId')!=null)
        {
            dsrList = [SELECT id,Name,Status__c from Deal_Support_Request__c where Opportunity__c=: searchFields.get('OpptyId')];
            system.debug('**dsrList**'+dsrList);
        }
        return dsrList;
    } 
}
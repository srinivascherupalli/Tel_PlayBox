global with sharing class CS_CaseRecord extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["OpptyId"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
        Integer pageOffset, Integer pageLimit){
     
        if (searchFields != null) {
        	System.debug('***searchFields.get(OpptyId)****' +searchFields.get('OpptyId'));
        	system.debug('***searchFields.containsKey(OpptyId)***'+searchFields.containsKey('OpptyId'));
               
            if(searchFields.get('OpptyId')!=null)
            {
                List<Case>  caseList= [SELECT CaseNumber,Status from Case where OpportunityId__c=: searchFields.get('OpptyId') and RecordType.developername=:Label.Case_Record_Type_For_Waiver ];
                system.debug('**caseList**'+caseList);
                if (caseList != null)
                    return caseList;
            }
        }
        return null;
    } 
}
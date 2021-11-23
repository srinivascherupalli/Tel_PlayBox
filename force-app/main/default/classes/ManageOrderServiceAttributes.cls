public with sharing class ManageOrderServiceAttributes
{
	public static List<String> getExclusionAttribute(String exclusionType)
	{
		List<String> excludeAttributeList = new List<String>();
		List<Excluded_Spec_Attributes__mdt> excludedSpecAttList = [Select Exclusion_Name__c from Excluded_Spec_Attributes__mdt where Exclusion_Type__c =: exclusionType];
        for(Excluded_Spec_Attributes__mdt excludeAttr : excludedSpecAttList){
			excludeAttributeList.add(excludeAttr.Exclusion_Name__c);
		}
        
        return excludeAttributeList;
	}
}
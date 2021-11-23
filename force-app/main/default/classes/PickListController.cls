public with sharing class PickListController {
    private static PickListController singleton = new PickListController( );   
	/* A private Constructor prevents any other
    * class from instantiating.
    */
	private PickListController() { }
   /* Static 'instance' method */
  	public static PickListController getInstance( ) {
      return singleton;
   	}
@AuraEnabled        
public static List<String> getPickListValuesIntoList(String objectType, String selectedField){
    List<String> pickListValuesList = new List<String>();
    Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
    Schema.DescribeSObjectResult res = convertToObj.getDescribe();
    Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
        pickListValuesList.add(pickListVal.getLabel());
    }     
    return pickListValuesList;
}

}
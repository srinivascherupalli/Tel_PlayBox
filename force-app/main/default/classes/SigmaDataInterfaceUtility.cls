/* Class Name: SigmaDataInterfaceUtility

ChagneSet No    Name            Date                    Description
CH-1            Vijaya         04/10/2019             EDGE-70343 Sigma-CS interface code refactoring - Update logic for Price Item, Attribute LoV and EDM mappings. 
         
*/
public with sharing class SigmaDataInterfaceUtility {
	/* Method to check if the return the value of Price__c metadata */
	public static Boolean isPriceChangeOnly()
	{
        Boolean PriceChangeOnly = false;

        List<SigmaLaunchChangeSet__mdt> SigmaLaunchChangeSetList = [SELECT Price__c, Id
                                                                        FROM SigmaLaunchChangeSet__mdt
                                                                        LIMIT 1];
        if(SigmaLaunchChangeSetList != null && SigmaLaunchChangeSetList.size() > 0) {
            PriceChangeOnly = SigmaLaunchChangeSetList[0].Price__c;
        }
        return PriceChangeOnly;
    }
}
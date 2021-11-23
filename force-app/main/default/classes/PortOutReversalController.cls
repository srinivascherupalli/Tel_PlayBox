/*************************************************************************************************
Name  		: PortOutReversalHelper
Description : Helper class for port otu reversal
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
public with sharing class PortOutReversalController {
/*************************************************************************************************
Name 		: getProductConfigDetails
Description : get product config details
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled
    public  static List<PortOutReversalHelper.ProductConfigWrapper> getProductConfigDetails(String basketid){
        System.debug('Inside getProductConfigDetails: ');
        return PortOutReversalHelper.getProductConfigDetails(basketid);
    }
/*************************************************************************************************
Name 		: removeSelected
Description : remove number to PC association
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled
    public  static String removeSelected(String selectedPCid){
        return PortOutReversalHelper.removeSelected(selectedPCid);
    }
/*************************************************************************************************
Name 		: getSIMnumber
Description : get SIM number
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled
    public static PortOutReversalHelper.NumberWithDaysLeft getSIMnumber(String selectedNumber){
       // EDGE-150425
        //return PortOutReversalHelper.getSIMnumber(selectedNumber);
        return PortOutReversalHelper.getSimAndImsiNumber(selectedNumber);
      
    }
/*************************************************************************************************
Name 		: isNumberValid
Description : check if number exisits in SFDC
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled(cacheable=true)
    public static Boolean isNumberValid(String selectedNumber){
        return PortOutReversalHelper.isNumberValid(selectedNumber);
    }
/*************************************************************************************************
Name 		: createNumberRecord
Description : create number records
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled
	public static String createNumberRecord(String selectedNumber, String pcid, String sim, String imsi, String simType, String simAvailability, String neworExistingSIM){
		system.debug('@V@ neworExistingSIM ' +neworExistingSIM);
        system.debug('@V@ neworExistingSIM ' +sim);
        return PortOutReversalHelper.createNumberRecord(selectedNumber, pcid, sim, imsi, simType, simAvailability, neworExistingSIM);
	}
/*************************************************************************************************
Name 		: finishReservation
Description : finish reservation validaton
Author		: Kalashree Borgaonkar
Story		: EDGE-142347
***************************************************************************************************/
    @AuraEnabled
    public static Boolean finishReservation(String basketid){
        return PortOutReversalHelper.finishReservation(basketid);
    }
    
}
/**
 *  @description Controller for Quick Action
 *  @author      Olivier Rachon
 *  @date        2017-10-18
 */
public class ServicesQuickSearchController {

    @AuraEnabled
    public static String getServices (String searchTerm) {
        
        List<WC_CSSA_ServicesFunction_VW__x> services = ExternalSearchServiceRequest.findByServiceDescription(searchTerm);
                                                                                                              
        if (services != null && services.size() > 0)
        {
            List<TelstraService> tServices = new List<TelstraService>();
       
			for (WC_CSSA_ServicesFunction_VW__x service: services)
        	{
            	TelstraService tService = new TelstraService();
            	tService.billingAccount = service.Billing_Account_Info__c;
            	tService.singleBiller = service.SingleBilled__c;
            	tService.silentLine = service.Silent__c;
            	tService.plan = service.Plan1__c;
            	tService.serviceAddress = service.Address__c;
            	tService.dataPlan = service.DataPlan__c;
            	tService.serviceNumber = service.VisibleSvcDescription__c;
            	tService.cidn = service.CIDN__c;
            	tServices.add(tService);
        	}
        	
            if (tServices != null && tServices.size() > 0)
        	{
            	String JSONString = JSON.serialize(tServices);
            	return JSONString;
        	}
        }
        return null;
    }
}
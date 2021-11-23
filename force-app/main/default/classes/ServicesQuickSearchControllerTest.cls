@isTest
public class ServicesQuickSearchControllerTest {

	static testMethod void testController() {
		Test.startTest();
    	WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
        Billing_Account_Info__c ='Flexcab',
        SingleBilled__c = 'N',
        Silent__c = 'N',
        Plan1__c = 'Plan',
        Address__c = 'Address',
        CIDN__C = '0102030405',
        DataPlan__c = '',
        VisibleSvcDescription__c = '0357224435');

    	ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
    	String result = ServicesQuickSearchController.getServices(mockedRequest.VisibleSvcDescription__c);
        Test.stopTest();
        
        System.assert(result != null);
    }
    
	static testMethod void testControllerByEmail() {
		Test.startTest();
    	WC_CSSA_ServicesFunction_VW__x mockedRequest = new WC_CSSA_ServicesFunction_VW__x(
        Billing_Account_Info__c ='Flexcab',
        SingleBilled__c = 'N',
        Silent__c = 'N',
        Plan1__c = 'Plan',
        Address__c = 'Address',
        CIDN__C = '0102030405',
        DataPlan__c = '',
        VisibleSvcDescription__c = 'aura@bigpond.com.au');
        
        ExternalSearchServiceRequest.mockedRequests.add(mockedRequest);
    	String result = ServicesQuickSearchController.getServices(mockedRequest.VisibleSvcDescription__c);
        Test.stopTest();
        
        System.assert(result != null);
    }

	static testMethod void testControllerNothingFound() {
		String result = ServicesQuickSearchController.getServices('0257224435');  
        System.assert(result == null);
    }
    
    static testMethod void testControllerNull() {
		String result = ServicesQuickSearchController.getServices(null); 
        System.assert(result == null);
    }

}
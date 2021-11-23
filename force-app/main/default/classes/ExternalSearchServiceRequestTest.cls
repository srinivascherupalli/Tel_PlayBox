/**
 *  @description Request Unit Test
 *  @author      Olivier Rachon
 *  @date        2017-10-18
 */
@isTest
public class ExternalSearchServiceRequestTest {

    static testMethod void testFindByServiceDescription()
    {
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
    	List<WC_CSSA_ServicesFunction_VW__x> requests = ExternalSearchServiceRequest.findByServiceDescription(mockedRequest.VisibleSvcDescription__c);
    	Test.stopTest();

    	System.assertEquals('0102030405', requests[0].CIDN__C);
    	System.assertEquals('Flexcab', requests[0].Billing_Account_Info__c);
	}
}
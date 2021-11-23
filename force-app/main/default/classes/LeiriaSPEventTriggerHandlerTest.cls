/****************************************************************************
@Name: LeiriaSPEventTriggerHandlerTest
@Author: Leirie/Ravi Dodiya
@CreateDate: 20/07/2021
@Sprint : 21.10[DIGI-458]
@Description: This Class is for SharePointEvent Trigger - DIGI-458, to get the test coverage 
			  using the class LeiriaSPEventTriggerHandlerTest
@Last Modified        : 
*****************************************************************************/
@isTest
public class LeiriaSPEventTriggerHandlerTest{
	@isTest
    static void testSharepointHVPEPublish(){
		        Account acc = new Account(name ='Test SharePointEvent HVPE',Account_Status__c = 'Active',CIDN__C = '1234567890');
				Insert acc;
				
				SharePointEvent__c spe = [select Id,Related_Account__c from SharePointEvent__c where Related_Account__c =: acc.id limit 1];
				System.assertEquals(acc.id, spe.Related_Account__c);

	}

}
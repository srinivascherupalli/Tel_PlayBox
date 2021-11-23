/**
 * @description       : Site Trigger Test class
 * @author            : Unknown
 * @group             : 
 * @last modified on  : 10-07-2021
 * @last modified by  : Omkar Jante
 * 
 * Notes:
 *  	* Changes made for DIGI-26327 in setup method
**/
/*
	Story Number: DIGI-15723
	Modified By: Ajith Kumar
	Description: Added Mock response to the test class
	@Param: 
    */
@isTest
private class SiteTriggerTest {
	@testsetup static void setup(){
		Account acc = TestUtil.createAccount('TestAcct');
		insert acc;

		Contact ct1 = TestUtil.createContact(acc.id,'James', 'Bond');
		insert ct1;

		Contact ct2 = TestUtil.createContact(acc.id,'Jason', 'Roy');
		insert ct2;

		// Changes made for DIGI-26327 
		List<cscrm__Site__c> sitesList = new List<cscrm__Site__c>();
		cscrm__Address__c objAddress = TestUtil.createAddress();
		objAddress.cscrm__External_ID__c = objAddress.cscrm__External_ID__c;
		objAddress.NBN_Location_Id__c = 'LOC00014519312'; 
		insert objAddress;

		for(Integer i=0; i<200; i++){
			cscrm__Site__c newSite = TestUtil.createSite(ct1.id, ct2.id, acc.id);
			newSite.cscrm__Installation_Address__c = objAddress.Id;
			sitesList.add(newSite);
		}       	
		insert sitesList;
		//DIGI-15723 Adding Mock response 
        Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
	}
	
	@isTest static void testMassInsert() {
        Test.startTest();
		Account acc = [Select id from Account where name = 'TestAcct' LIMIT 1];
		System.assert(acc!=null);

		Contact ct1 = [Select id from Contact where FirstName = 'James' LIMIT 1];
		Contact ct2 = [Select id from Contact where FirstName = 'Jason' LIMIT 1];

		System.assert(ct1!=null);
		System.assert(ct2!=null);

		List<cscrm__Site__c> sites  = [Select id,name, cscrm__Account__c, NBN_Location_ID__c from cscrm__Site__c where cscrm__Account__c =:acc.id];
		System.assertEquals(sites.size(),200);
		System.assertEquals(sites[0].NBN_Location_ID__c, 'LOC00014519312');

		List<Site_Contact_Role__c> roles = [Select Contact_Type__c,Contact__c from Site_Contact_Role__c where Site__c =:sites.get(0).id];
		System.assertEquals(roles.size(),2);

		for(Site_Contact_Role__c rlt : roles){
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_PRIMARY){
				System.assertEquals(rlt.Contact__c, ct1.id);
			}
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_SECONDARY){
				System.assertEquals(rlt.Contact__c, ct2.id);
			}
		}
        Test.stopTest();
	}
	
	@isTest static void testMassUpdate() {
		Account acc = [Select id from Account where name = 'TestAcct' LIMIT 1];
		System.assert(acc!=null);

		Contact ct1 = [Select id from Contact where FirstName = 'James' LIMIT 1];
		Contact ct2 = [Select id from Contact where FirstName = 'Jason' LIMIT 1];

		System.assert(ct1!=null);
		System.assert(ct2!=null);

		List<cscrm__Site__c> sites  = [Select id,name, cscrm__Account__c from cscrm__Site__c where cscrm__Account__c =:acc.id];
		System.assertEquals(sites.size(),200);

		List<Site_Contact_Role__c> roles = [Select Contact_Type__c,Contact__c from Site_Contact_Role__c where Site__c =:sites.get(0).id];
		System.assertEquals(roles.size(),2);

		for(Site_Contact_Role__c rlt : roles){
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_PRIMARY){
				System.assertEquals(rlt.Contact__c, ct1.id);
			}
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_SECONDARY){
				System.assertEquals(rlt.Contact__c, ct2.id);
			}
		}

		//NOW UPDATE THE SITES WITH DIFFERENT PRIMARY AND SECONDARY CONTACT..
		for(cscrm__Site__c sit : sites){
			sit.Primary_Contact__c = ct2.id;
        	sit.Secondary_Contact__c = ct1.id;
		}
		Test.startTest();
		//DIGI-15723 Adding Mock response 
        Test.setMock(HttpCalloutMock.class, new MockChargeZoneResponseGenerator('mockBody'));
		update sites;
		Test.stopTest();

		roles = [Select Contact_Type__c,Contact__c from Site_Contact_Role__c where Site__c =:sites.get(0).id];
		System.assertEquals(roles.size(),2);
		for(Site_Contact_Role__c rlt : roles){
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_PRIMARY){
				System.assertEquals(rlt.Contact__c, ct2.id);
			}
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_SECONDARY){
				System.assertEquals(rlt.Contact__c, ct1.id);
			}
		}
	}

	@isTest static void testMassDelete() {
		Account acc = [Select id from Account where name = 'TestAcct' LIMIT 1];
		System.assert(acc!=null);

		Contact ct1 = [Select id from Contact where FirstName = 'James' LIMIT 1];
		Contact ct2 = [Select id from Contact where FirstName = 'Jason' LIMIT 1];

		System.assert(ct1!=null);
		System.assert(ct2!=null);

		List<cscrm__Site__c> sites  = [Select id,name, cscrm__Account__c from cscrm__Site__c where cscrm__Account__c =:acc.id];
		System.assertEquals(sites.size(),200);

		List<Site_Contact_Role__c> roles = [Select Contact_Type__c,Contact__c from Site_Contact_Role__c where Site__c =:sites.get(0).id];
		System.assertEquals(roles.size(),2);

		for(Site_Contact_Role__c rlt : roles){
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_PRIMARY){
				System.assertEquals(rlt.Contact__c, ct1.id);
			}
			if(rlt.Contact_Type__c == SiteTriggerHelper.ROLE_SECONDARY){
				System.assertEquals(rlt.Contact__c, ct2.id);
			}
		}

		Id deletedID = sites.get(0).id;
		//NOW Delete sites
		Test.startTest();
		delete sites;
		Test.stopTest();
		roles = [Select Contact_Type__c,Contact__c from Site_Contact_Role__c where Site__c =:deletedID];
		System.assertEquals(roles.size()==0,true);
	}
}
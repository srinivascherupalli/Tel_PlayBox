@isTest
public with sharing class MaintainAccountCIDNRelationshipTest {
	@testSetup
	static void setUpTestData(){
		List<Account> lstAccount = new List<Account>();
		Account A;
		for(integer x=0;x<4;x++){
            A = AccountTestFactory.buildAccount('Test Account - ' + x);
			A.CIDN__c = '1234334' + x;
            a.Loc__c='123'+x;
			//A.Parent_CIDN__c = '220090' + x;
			lstAccount.add(A);
		}
		insert lstAccount;
	}

	static testmethod void testRelationshipUpdateOnInsert(){
		List<Account> lstAccount = new List<Account>();
		Map<String, Account> mapCIDNToAccount = new Map<String, Account>();
		Map<String, String> mapCIDNToParentCIDN = new Map<String, String>();
		Map<String, Id> mapCIDNToParentId = new Map<String, Id>();
		Account A;
		Test.startTest();
		for(integer x=0; x<50; x++){
			A = AccountTestFactory.buildAccount('Test Account - ' + x);
			A.CIDN__c = '220090' + x;
            a.Loc__c='123596'+x;
			if(x < 10){
				A.Parent_CIDN__c = '12343340';
                A.Ultimate_Parent_CIDN__c = '12343340';
			}
			else if(x>10 && x < 20){
				A.Parent_CIDN__c = '12343341';	
                A.Ultimate_Parent_CIDN__c = '12343341';
			}
			else if(x>20 && x < 30){
				A.Parent_CIDN__c = '12343342';	
                A.Ultimate_Parent_CIDN__c = '12343342';
			}
			lstAccount.add(A);
		}
		insert lstAccount;

		Test.stopTest();

		for(Account AA : [select Id, CIDN__c, ParentId, Parent_CIDN__c,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c IN ('2200901','22009012','22009022','22009034')]){
			mapCIDNToParentCIDN.put(AA.CIDN__c, AA.Parent_CIDN__c);
			mapCIDNToAccount.put(AA.CIDN__c, AA);
			//mapCIDNToParentId(AA.CIDN__c, AA.ParentId);
		}

		for(Account AAA : [select Id, CIDN__c from Account where CIDN__c IN ('12343340', '12343341', '12343342')]){
			mapCIDNToParentId.put(AAA.CIDN__c, AAA.Id);
		}

		System.debug('x == ' + mapCIDNToAccount.get('2200901').ParentId);
		System.debug('y == ' + mapCIDNToParentId.get(mapCIDNToParentCIDN.get('2200901')));
		System.assert(mapCIDNToAccount.get('2200901').ParentId == mapCIDNToParentId.get(mapCIDNToParentCIDN.get('2200901')));
		System.assert(mapCIDNToAccount.get('22009012').ParentId == mapCIDNToParentId.get(mapCIDNToParentCIDN.get('22009012')));
		System.assert(mapCIDNToAccount.get('22009022').ParentId == mapCIDNToParentId.get(mapCIDNToParentCIDN.get('22009022')));
		System.assert(mapCIDNToAccount.get('22009034').ParentId == null); 

		
	}

	static testmethod void testRelationshipUpdateOnUpdate(){
		List<Account> lstAccount = new List<Account>();
		Account parentAccount = new Account();
		Account A;
		Test.startTest();
		for(integer x=0; x<50; x++){
			A = AccountTestFactory.buildAccount('Test Account - ' + x);
			A.CIDN__c = '220090' + x;
            a.Loc__c='12356'+x;
			if(x < 10){
				A.Parent_CIDN__c = '12343340';
                A.Ultimate_Parent_CIDN__c = '12343340';
			}
			else if(x>10 && x < 20){
				A.Parent_CIDN__c = '12343341';	
                A.Ultimate_Parent_CIDN__c ='12343341';
			}
			else if(x>20 && x < 30){
				A.Parent_CIDN__c = '12343342';
                A.Ultimate_Parent_CIDN__c = '12343342';
			}
			lstAccount.add(A);
		}
		insert lstAccount;

		lstAccount.clear();
		lstAccount = [select Id, CIDN__c, ParentId, Parent_CIDN__c,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c IN ('2200900', '2200901','22009015')];
		for(Account AA : lstAccount){
			AA.Parent_CIDN__c = '12343343';
            AA.Ultimate_Parent_CIDN__c = '';
		}
		update lstAccount;

		parentAccount = [select Id from Account where CIDN__c = '12343343'].get(0);
		Test.stopTest();

		for(Account A1 : [select Id, CIDN__c, ParentId, Parent_CIDN__c,Ultimate_Parent_CIDN__c,Ultimate_Parent_Account__c from Account where CIDN__c IN ('2200900', '2200901','22009015')]){
			System.assert(A1.ParentId == parentAccount.Id);
		}
		
	}
}
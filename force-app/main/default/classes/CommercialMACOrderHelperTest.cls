/******************************************************************************************************************************
Class Name : CommercialMACOrderHelper
Test Class : TestCommercialMACOrderHelper 
===============================================================================================================================
Sr.No.  Developer                 Date          Story Description                Sprint
1.      Aman Soni/Shubhi V        08/07/2020    EDGE-224786(New Class)           21.09
******************************************************************************************************************************/
@isTest
public class CommercialMACOrderHelperTest{
	
	private static final String OPPORTUNITY_REC_TYPE = 'Enterprise - In Contract';
    private static final String OPPORTUNITY_STAGE = 'Develop';
    private static final String OPPORTUNITY_TYPE_MAC = 'MACs (Moves, Adds & Change)';
    private static final String OPPORTUNITY_TYPE_DISCONNECT = 'Disconnect';
    private static final String OPPORTUNITY_PRODUCT_TYPE = 'Modular';
    private static final String OPPORTUNITY_PRIMARY_DOMAIN = 'Other';
    private static final String OPPORTUNITY_IN_CONTRACT = 'Yes';
    private static final String CHANGE_TYPE_MODIFY = 'Modify';
    private static final String CHANGE_TYPE_CANCEL = 'Cancel';
    private static final String CHANGE_TYPE = 'Change Solution';

	@testSetup public static void setup(){
		List<Account> accLst = new List<Account>();
		Account customerAccount=TestUtil.createAccount('Testacc');
		accLst.add(customerAccount);
        insert accLst;
		
        List<Contact> conLst = new List<Contact>();
		Contact con = new Contact();
        con.LastName = 'test last name';
        con.FirstName = 'Fname';
        con.AccountId = customerAccount.Id;
		conLst.add(con);
        insert conLst;	 
	}

	@isTest public static void testcreateDynamicOpportunity(){
		Test.startTest();
			Account acc=[select id,name from account limit 1];
			Map<String,string> oppFieldValueMap=new Map<String,string>();
			oppFieldValueMap.put('Name','MACD Solution'+ String.valueOf(Date.Today().format()));
			oppFieldValueMap.put('AccountId',acc.id);
			oppFieldValueMap.put('StageName',OPPORTUNITY_STAGE);
			oppFieldValueMap.put('Incremental_Revenue__c',String.valueof(10.00));
			oppFieldValueMap.put('Contract_Term__c',String.valueof(12));
			oppFieldValueMap.put('CloseDate',String.valueof(date.today().addDays(30)));
			oppFieldValueMap.put('Revenue_Impact_Date__c',String.valueof(date.today().addDays(45)));
			oppFieldValueMap.put('Product_Type__c',OPPORTUNITY_PRODUCT_TYPE);
			oppFieldValueMap.put('Product_Domain__c',OPPORTUNITY_PRIMARY_DOMAIN);
			Id oppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();       
			oppFieldValueMap.put('RecordTypeId',oppRecordTypeId);
			if(!oppFieldValueMap.isEmpty()){
				String opportunityId = CommercialMACOrderHelper.createDynamicOpportunity(oppFieldValueMap);
				System.assert(opportunityId!=null); 
			}							
		Test.stopTest();
	}

	@isTest public static void testcreateDynamicProductBasket() {
		Test.startTest();
			Account acc=[select id,name from account limit 1];
			Map<String,string> oppFieldValueMap=new Map<String,string>();
			oppFieldValueMap.put('Name','MACD Solution' + String.valueOf(Date.Today().format()));
			oppFieldValueMap.put('AccountId',acc.id);
			oppFieldValueMap.put('StageName',OPPORTUNITY_STAGE);
			oppFieldValueMap.put('CloseDate',String.valueof(date.today().addDays(30)));
			oppFieldValueMap.put('Revenue_Impact_Date__c',String.valueof(date.today().addDays(45)));
			oppFieldValueMap.put('Product_Type__c',OPPORTUNITY_PRODUCT_TYPE);
			oppFieldValueMap.put('Product_Domain__c',OPPORTUNITY_PRIMARY_DOMAIN);
			Id oppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();       
			oppFieldValueMap.put('RecordTypeId',oppRecordTypeId);
			String opportunityId=CommercialMACOrderHelper.createDynamicOpportunity(oppFieldValueMap);

			Map<String,string> basketFieldValueMap=new Map<String,string>();
			basketFieldValueMap.put('csordtelcoa__Change_Type__c',CHANGE_TYPE);
			basketFieldValueMap.put('csbb__Account__c',acc.id);
			basketFieldValueMap.put('cscfga__Opportunity__c',opportunityId);

			if(!basketFieldValueMap.isEmpty()){
				String sourceBasketId = CommercialMACOrderHelper.createDynamicProductBasket(basketFieldValueMap);
				System.assert(sourceBasketId!=null);
			}              	
		Test.stopTest();	 
	}
	
	@isTest public static void testcreateOpptyContactRole(){
		Test.startTest();
			Account acc=[select id,name from account limit 1];
			Contact contact=[Select id from contact limit 1];
			Map<String,string> oppFieldValueMap=new Map<String,string>();
			oppFieldValueMap.put('Name','MACD Solution' + String.valueOf(Date.Today().format()));
			oppFieldValueMap.put('AccountId',acc.id);
			oppFieldValueMap.put('StageName',OPPORTUNITY_STAGE);
			oppFieldValueMap.put('CloseDate',String.valueof(date.today().addDays(30)));
			oppFieldValueMap.put('Revenue_Impact_Date__c',String.valueof(date.today().addDays(45)));
			oppFieldValueMap.put('Product_Type__c',OPPORTUNITY_PRODUCT_TYPE);
			oppFieldValueMap.put('Product_Domain__c',OPPORTUNITY_PRIMARY_DOMAIN);
			Id oppRecordTypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();       
			oppFieldValueMap.put('RecordTypeId',oppRecordTypeId);
			oppFieldValueMap.put('In_Contract_MAC__c',OPPORTUNITY_IN_CONTRACT);
			oppFieldValueMap.put('csordtelcoa__Change_Type__c',CHANGE_TYPE);
			oppFieldValueMap.put('IS_MACD__c','true');
			oppFieldValueMap.put('Type',OPPORTUNITY_TYPE_MAC);	
			if(!oppFieldValueMap.isEmpty()){
				String opportunityId=CommercialMACOrderHelper.createDynamicOpportunity(oppFieldValueMap);
				if(String.isNotBlank(opportunityId)){
					List<OpportunityContactRole> ocrLst = new List<OpportunityContactRole>();
					OpportunityContactRole ocr = new OpportunityContactRole();
					ocr.OpportunityId=opportunityId;
					ocr.ContactId = contact.id;
					ocrLst.add(ocr);
					insert ocrLst;
					CommercialMACOrderHelper.createOpptyContactRole(opportunityId,contact.Id);
					System.assert(contact.Id!=null);
				}
			}   
		Test.stopTest();
	}
}
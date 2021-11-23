@isTest
private class QliTriggerHandlerTest{

	@testSetup static void setup(){
		Profile pf = [select id from profile where name ='Assurance Service Agent'];
		Profile pf_bill = [select id from profile where name ='Billing Consultant'];
		String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
       	List<User> userList=new List<User>();
		User agent= new User(alias = 'agent',email='agentuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='agent', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf.id,
                                      timezonesidkey='Australia/Sydney',
                                      username=uniquename+'agentuser@testagent.com',phone='+121231231234');
		userList.add(agent);
		
        User billConsultant= new User(alias = 'bill',email='billUser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                                      lastname='user', languagelocalekey='en_US',localesidkey='en_US',
                                      profileid = pf_bill.id,
                                      timezonesidkey='Australia/Sydney',
                                      username=uniquename+'billUser@testagent.com',phone='+121231231234');
		userList.add(billConsultant);
		insert userList;
		Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.Label.Case_Record_Type).getRecordTypeId();
		Account accountData = TestDataFactory.generateAccount();
		Contact contactData = TestDataFactory.generateContact('Test FirstName', accountData.id,'Active','Test LastName',System.today(),'Mobile');
		contactData.email='abc@gmail.com';
		insert contactData;
		Billing_Account__c billingAccountData = TestDataFactory.generateBillingAccount('700000002978','Created',accountData.Id, contactData.Id);
		insert billingAccountData;
		Case caseData      = new Case(AccountId = accountData.Id,ContactId = contactData.Id,Status = 'New',Type = System.Label.Case_Type,RecordTypeId = caseRecordTypeId,Billing_Account__c = billingAccountData.Id);
		caseData.AccountId = accountData.Id;
		caseData.ContactId = contactData.Id;
		caseData.Type      = System.Label.Case_Type;
		insert caseData;        
		Invoice__c invdata= new Invoice__c(Name='123434',Aria_Invoice_Number__c='1232');
		insert invdata;
		Invoice_Line_Item__c ILI=new Invoice_Line_Item__c(
			Invoice__c=invdata.id,
			Invoice_Line_Number__c=13432233, 
			Charge_Excluding_GST__c = 1214,Charge_Type__c= 'RecurringCharge',
			Invoice_Transaction_ID__c=26022460,Service_Type__c='Test 12334',
			Line_Item_Identifier__c='43242342',Offer_Name__c='Test AM',
			charge_identifier__c=12453);
		insert ILI;
	}

	@isTest static void testMethodInsert() {
		// code_block
		Invoice_Line_Item__c ILI=[Select id,Service_Type__c from Invoice_Line_Item__c where Service_Type__c='Test 12334' ];
		case caseData=[Select id from case limit 1];
		List<Queried_Line_Item__c> qlilist=new List<Queried_Line_Item__c>();
		Queried_Line_Item__c sobj = new Queried_Line_Item__c(
			Queried_Amount__c = 34.99,                      // Queried Amount (ex GST)
			Line_Item_Identifier__c = 'RecurringCharge100',  // Line Item Identifier
			Case__c = caseData.id,                    // Case
			Invoice_Line_Item__c = ILI.id                   // Invoice Line Item 
		);
		qlilist.add(sobj);
		insert qlilist;
		Queried_Line_Item__c qli=[Select id,ChargeDescription__c from Queried_Line_Item__c limit 1];
		system.assert(qli.ChargeDescription__c==ili.Service_Type__c);
	}
	
	@isTest static void testMethodNegative() {
		// code_block
		Test.startTest();
			Invoice_Line_Item__c ILI=[Select id,Service_Type__c from Invoice_Line_Item__c where Service_Type__c='Test 12334' ];
			List<case> caseList=[Select id from case ];
			List<Queried_Line_Item__c> qlilist=new List<Queried_Line_Item__c>();
			Queried_Line_Item__c sobj = new Queried_Line_Item__c(
				Queried_Amount__c = 34.99,                      // Queried Amount (ex GST)
				Line_Item_Identifier__c = 'RecurringCharge100',  // Line Item Identifier
				Case__c = caseList[0].id                    // Case
			);
			qlilist.add(sobj);
			insert qlilist;
			Queried_Line_Item__c qli=[Select id,ChargeDescription__c from Queried_Line_Item__c limit 1];
			system.assert(qli.ChargeDescription__c!=ILI.Service_Type__c);
		Test.stopTest();
	}


	

}
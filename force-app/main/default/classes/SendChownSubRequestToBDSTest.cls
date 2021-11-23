//DIGI-30045
@isTest(SeeAllData=false)
public class SendChownSubRequestToBDSTest {
    
    @Testsetup static void dataSetup(){
		EnvironmentVariable__c ev = new EnvironmentVariable__c(Name = 'MaxBDSChgInstances', Value__c = '1');
		insert ev;
		
        Account acc=new Account();
        acc.name='Testaccount';
        acc.Type='Company';
        acc.Title__c='';
        acc.CIDN__c='65432213';
        acc.Email__c='abc@gmail.com';
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp; 
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        //contact.MobilePhone='9876543210';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        insert ocr;

        Billing_Account__c bAcc = new Billing_Account__c();
        bAcc.Billing_Account_Owner__c = contact.Id;
        bAcc.Account__c = acc.Id;
		bAcc.Status__c = 'Allocated';
        bAcc.Billing_Account_Number__c = '000000000002';
        //bAcc.CreatedDate = system.today()-2;
        insert bAcc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = new csord__Order__c();
        ord.name = 'TestOrder';
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Identification__c = 'test identification';
        ord.csord__Account__c=acc.Id;
        ord.csord__Start_Date__c=Date.today();
        ord.Telstra_Committed_Date__c=Date.today();
        ord.csord__Customer_Order_Number__c='7654387';
        
        ord.csordtelcoa__Opportunity__c =opp.id;
        insert ord;
        
        csord__Order__c ordd = new csord__Order__c();
        ordd.name = 'TestOrder1';
        ordd.csord__Order_Request__c = ordReq.Id;
        ordd.csord__Identification__c = 'test identification1';
        ordd.csord__Account__c=acc.Id;
        ordd.csord__Start_Date__c=Date.today();
        ordd.Telstra_Committed_Date__c=Date.today();
        ordd.csord__Customer_Order_Number__c='7654388';
        ordd.csordtelcoa__Opportunity__c =opp.id;
        ordd.csord__Primary_Order__c=ord.Id;
        ordd.csord__Status2__c ='Incomplete';

        insert ordd;
        
        //Contact contact = AccountTestFactory.buildContact(acc, 'Smiths');
        //insert contact;
        
        cscrm__Address__c address =new cscrm__Address__c();
        address.Address_ID__c='675439';
        address.cscrm__Account__c=acc.id;  
        insert address;
        
        cscrm__Account_Address_Relationship__c add= new cscrm__Account_Address_Relationship__c();
        add.cscrm__Address__c=address.id;
        add.cscrm__Account__c=acc.id;
        add.cscrm__Active__c=true;
        add.cscrm__Address_Type__c='Primary Address';
        insert add;
        
        Functional_Contact_Role__c FCR = new Functional_Contact_Role__c();
        FCR.OrderID__c = ord.id;
        FCR.Role_Type__c = 'Order';
        FCR.ContactID__c =contact.id;
        
        insert FCR;
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Telstra Collaboration' ;
        mo.Name = 'Telstra Collaboration';
        mo.Offer_ID__c = 'DMCAT_Offer_000618';
        insert mo;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'testSubscription';
        subs.csord__Identification__c = 'testIdentity';
        subs.csord__Order__c = ordd.Id;
        subs.MarketableOffer__c = mo.Id;
        subs.csordtelcoa__Subscription_Number__c='SN-000238528';
        subs.Sub_status__c = 'Active';
		subs.Billing_Account__c = bAcc.Id;
        insert subs;
        
        Number__c num = new Number__c();
        num.Subscription_number__c = subs.csordtelcoa__Subscription_Number__c;
        num.Service_Id__c = '12345';
        num.Service_Number__c = 'SN-000238528';
        num.Mobile__c = 'Fixed';
        Insert num;
		
        csord__Service__c serv = new csord__Service__c();
        serv.name = 'IP Site';
		serv.Payment_Type__c ='Hardware Repayment';
        serv.csord__Identification__c  = 'testIdentify_1';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'In Progress';
        serv.csord__Order__c = ordd.Id;
        serv.Forecasted_Delivery_Date__c = Date.today()+2;
        serv.Telstra_Committed_Date__c = Date.today()+2;
        insert serv;
        
        subs.Contract_Term__c = '12';
        update subs;

		Orchestration_Technical__c ot = new Orchestration_Technical__c();
		ot.Process_Name__c = 'Order';
		ot.Service__c = serv.Id;
		ot.Field_9__c = 'aaaabbbbccccdddd';
		insert ot;
		
		Migration_Change_Request__c mcr = new Migration_Change_Request__c();
		mcr.selected_subscription_ids__c = subs.Id;
		mcr.macd_basket_ids__c = subs.Id+','+subs.Id;
        mcr.migration_status__c = 'Basket Created';
		insert mcr;
    }
	
	@isTest
	static void SendRequestToBDSTest(){
		List<Migration_Change_Request__c> mcrLst = [SELECT Id, selected_subscription_ids__c, macd_basket_ids__c FROM Migration_Change_Request__c];
        for(Migration_Change_Request__c mcrObj : mcrLst){
            mcrObj.migration_status__c = 'Basket ready for submission';
        }
        update mcrLst;
        
		Test.startTest();
			Test.setMock(HttpCalloutMock.class, new MockChownReqToBDSRespGenerator());
			SendChownSubRequestToBDS scsrToBDS = new SendChownSubRequestToBDS();
			scsrToBDS.createBDSRequest(mcrLst);
		Test.stopTest();
        List<Orchestration_Technical__c> otLst = [SELECT Id, Field_29__c FROM Orchestration_Technical__c WHERE Process_Name__c = 'FetchPayoutDetails'];
        system.assert(otLst.size() > 0);
		delete otLst;
		scsrToBDS = new SendChownSubRequestToBDS(); //negative test
		scsrToBDS.createBDSRequest(null);	
		List<Orchestration_Technical__c> otLst2 = [SELECT Id, Field_29__c FROM Orchestration_Technical__c WHERE Process_Name__c = 'FetchPayoutDetails'];
        system.assert(otLst2.size() == 0);
	}    
}
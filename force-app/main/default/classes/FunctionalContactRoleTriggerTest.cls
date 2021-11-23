/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 29/06/2018
@Story: EDGE-25250
@Description: FunctionalContactRoleTriggerTest test covrage class for covering FunctionalContactRoleTrigger Trigger,FunctionalContactRoleTriggerHandler and FunctionalContactRoleTriggerHelper Class.
@Trigger&ClassesCovered: Trigger-"FunctionalContactRoleTrigger", Classes - "FunctionalContactRoleTriggerHandler","FunctionalContactRoleTriggerHelper"
@ChangeLog: v1: Created
@LastModified:	Modified by Sri, team SFO on 16/01/2020 
				P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation  
********************************************************************************/
@isTest
public class FunctionalContactRoleTriggerTest {
    @testSetup static void setup() {
        Test.loadData(Account.sObjectType, 'FCR_Account');
        Test.loadData(Contact.sObjectType, 'FCR_Contact');
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
    }
    
    @isTest
    static void testFCRCBillingContactRole(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        Test.startTest();

        Billing_Account__c billAcc = new Billing_Account__c(Account__c=lstAcc[0].id,Billing_Account_Number__c='123456789102',Billing_Account_Owner__c=lstCon[1].id);
        Insert billAcc;
        system.assert(billAcc.id!=null);
        
        Functional_Contact_Role__c fcrbill1 = new Functional_Contact_Role__c();
        fcrbill1.ContactID__c = lstCon[1].Id;
        fcrbill1.Billing_Account_Number__c = billAcc.Id;
        fcrbill1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Billing Account Role');
        try{
            Insert fcrbill1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.FCR_BillingAccount_NonAuthorised_ErrorMsg)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        AccountContactRelation acr1=new AccountContactRelation(accountid=lstAcc[0].id,contactid=lstCon[1].Id,roles='Billing Contact');
        Insert acr1;
        system.assert(acr1.id !=null);
        AccountContactRelation acr2=new AccountContactRelation(accountid=lstAcc[0].id,contactid=lstCon[2].Id,roles='Billing Contact');
        Insert acr2;
        system.assert(acr2.id !=null);
        
        List<Functional_Contact_Role__c> lstFcrBill = new List<Functional_Contact_Role__c>();
 
        Functional_Contact_Role__c fcrbill2 = new Functional_Contact_Role__c();
        fcrbill2.ContactID__c = lstCon[1].Id;
        fcrbill2.Billing_Account_Number__c = billAcc.Id;
        fcrbill2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Billing Account Role');
        lstFcrBill.add(fcrbill2);
        
		Functional_Contact_Role__c fcrbill3 = new Functional_Contact_Role__c();
        fcrbill3.ContactID__c = lstCon[2].Id;
        fcrbill3.Billing_Account_Number__c = billAcc.Id;
        fcrbill3.RecordTypeId = fcrHelper.getFCRRecordTypeId('Billing Account Role');
        lstFcrBill.add(fcrbill3);
        
		Insert lstFcrBill;
        system.assert([Select Id from Functional_Contact_Role__c].size() == 2);
		
        AccountContactRelation acr3=new AccountContactRelation(accountid=lstAcc[0].id,contactid=lstCon[3].Id,roles='Non-Authorised');
        Insert acr3;
        system.assert(acr3.id !=null);
        
        Functional_Contact_Role__c fcrbill4 = new Functional_Contact_Role__c();
        fcrbill4.ContactID__c = lstCon[3].Id;
        fcrbill4.Billing_Account_Number__c = billAcc.Id;
        fcrbill4.RecordTypeId = fcrHelper.getFCRRecordTypeId('Billing Account Role');
        
        try{
            Insert fcrbill4;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.FCR_BillingAccount_NonAuthorised_ErrorMsg)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        test.stopTest();
    }
    @isTest
    static void testContractFCRContactRole(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        DateTime myDateTime = DateTime.newInstance(2018, 7,23, 8, 6, 16);
        Test.startTest();
        
        Opportunity opp=new Opportunity(Name='TestOpp', StageName='Define', CloseDate=myDateTime.date(),AccountId = lstAcc[0].id);
      	insert opp;
        
        ContractJunction__c ContractAcc = new ContractJunction__c(Account__c=lstAcc[0].id,Name='TestCj',Related_Opportunity__c = opp.id);
        Insert ContractAcc;
        system.assert(ContractAcc.id!=null);
        
        Functional_Contact_Role__c fcrContract1 = new Functional_Contact_Role__c();
        fcrContract1.ContactID__c = lstCon[1].Id;
        fcrContract1.Contract__c = ContractAcc.Id;
        fcrContract1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Contract Role');
        try{
            Insert fcrContract1;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.FCR_Contract_NonAuthorisation_ErrorMsg)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        AccountContactRelation acr1=new AccountContactRelation(accountid=lstAcc[0].id,contactid=lstCon[1].Id,roles='Non-Authorised');
        Insert acr1;
        system.assert(acr1.id !=null);
        
 		Functional_Contact_Role__c fcrContract2 = new Functional_Contact_Role__c();
        fcrContract2.ContactID__c = lstCon[1].Id;
        fcrContract2.Contract__c = ContractAcc.Id;
        fcrContract2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Contract Role');
               
        try{
            Insert fcrContract2;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.FCR_Contract_NonAuthorisation_ErrorMsg)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
		
        AccountContactRelation acr2=new AccountContactRelation(accountid=lstAcc[0].id,contactid=lstCon[2].Id,roles='Full Authority');
        Insert acr2;
        system.assert(acr2.id !=null);
        
       	Functional_Contact_Role__c fcrContract3 = new Functional_Contact_Role__c();
        fcrContract3.ContactID__c = lstCon[2].Id;
        fcrContract3.Contract__c = ContractAcc.Id;
        fcrContract3.RecordTypeId = fcrHelper.getFCRRecordTypeId('Contract Role');
        
         try{
            Insert fcrContract3;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  (e.getMessage().contains(System.Label.FCR_Contract_NonAuthorisation_ErrorMsg)) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
        test.stopTest();
    }
        
    @isTest
    static void testFCRCSiteRole(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        Test.startTest();

        cscrm__Site__c site1 = new cscrm__Site__c(cscrm__Account__c=lstAcc[0].Id,Name='test FCR Site1');
        Insert site1;
        system.assert(site1.Id != null);
        cscrm__Site__c site2 = new cscrm__Site__c(cscrm__Account__c=lstAcc[1].Id,Name='test FCR Site2');
        Insert site2;
        system.assert(site2.Id != null);
        
        Functional_Contact_Role__c fcrSite1 = new Functional_Contact_Role__c();
        fcrSite1.ContactID__c = lstCon[1].Id;
        fcrSite1.SiteID__c = site1.Id;
        fcrSite1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Site Role');
        Insert fcrSite1;
        system.assert([Select Id from Functional_Contact_Role__c].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
       	List<Functional_Contact_Role__c> lstFcrSite = new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcrSite2 = new Functional_Contact_Role__c();
        fcrSite2.ContactID__c = lstCon[2].Id;
        fcrSite2.SiteID__c = site2.Id;
        fcrSite2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Site Role');
        lstFcrSite.add(fcrSite2);
        
		Functional_Contact_Role__c fcrSite3 = new Functional_Contact_Role__c();
        fcrSite3.ContactID__c = lstCon[1].Id;
        fcrSite3.SiteID__c = site1.Id;
        fcrSite3.RecordTypeId = fcrHelper.getFCRRecordTypeId('Site Role');
        lstFcrSite.add(fcrSite3);
        
		Insert lstFcrSite;
		system.assert([select id from AccountContactRelation where accountid = :lstAcc[1].Id and contactid = :lstCon[2].id].size() == 1);        
        
        Test.stopTest();
    }
    
    @isTest
    static void testFCROrderBasketRole(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        Test.startTest();
        
        csord__Order__c order1 = new csord__Order__c(Name='fcr Test Order1',csord__Account__c=lstAcc[0].id,csord__Identification__c='test1');
        Insert order1;
        system.assert(order1.id != null);
        csord__Order__c order2 = new csord__Order__c(Name='fcr Test Order2',csord__Account__c=lstAcc[1].id,csord__Identification__c='test2');
        Insert order2;
        system.assert(order2.id != null);
        
        Functional_Contact_Role__c fcrOrder1 = new Functional_Contact_Role__c();
        fcrOrder1.ContactID__c = lstCon[1].Id;
        fcrOrder1.OrderID__c = order1.Id;
        fcrOrder1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
        Insert fcrOrder1;
        system.assert([Select Id from Functional_Contact_Role__c].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
        List<Functional_Contact_Role__c> lstFcrOrder = new List<Functional_Contact_Role__c>();
        
		Functional_Contact_Role__c fcrOrder2 = new Functional_Contact_Role__c();
        fcrOrder2.ContactID__c = lstCon[2].Id;
        fcrOrder2.OrderID__c = order2.Id;
        fcrOrder2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
        lstFcrOrder.add(fcrOrder2);

        Functional_Contact_Role__c fcrOrder3 = new Functional_Contact_Role__c();
        fcrOrder3.ContactID__c = lstCon[1].Id;
        fcrOrder3.OrderID__c = order1.Id;
        fcrOrder3.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
        lstFcrOrder.add(fcrOrder3);

        Insert lstFcrOrder;
		system.assert([select id from AccountContactRelation where accountid = :lstAcc[1].Id and contactid = :lstCon[2].id].size() == 1);        
        
        Test.stopTest();
    }
    
    @isTest
    static void testFCRSubscriptionRole(){
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        List<sobject> lstAcc=[Select id from account];
        List<sobject> lstCon=[Select id from contact];
        
        Test.startTest();

        csord__Subscription__c subRole1 = new csord__Subscription__c(Name='Test FCR Sub1', csord__Account__c=lstAcc[0].id,csord__Identification__c='testSub1');
        Insert subRole1;
        system.assert(subRole1.id != null);
        csord__Subscription__c subRole2 = new csord__Subscription__c(Name='Test FCR Sub1', csord__Account__c=lstAcc[1].id,csord__Identification__c='testSub1');
        Insert subRole2;
        system.assert(subRole2.id != null);
        
        Functional_Contact_Role__c fcrSub1 = new Functional_Contact_Role__c();
        fcrSub1.ContactID__c = lstCon[1].Id;
        fcrSub1.SubscriptionID__c = subRole1.Id;
        fcrSub1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Subscription Role');
        Insert fcrSub1;
        system.assert([Select Id from Functional_Contact_Role__c].size() == 1);
        system.assert([select id from AccountContactRelation where accountid = :lstAcc[0].Id and contactid = :lstCon[1].id].size() == 1);
        
        List<Functional_Contact_Role__c> lstFcrSub = new List<Functional_Contact_Role__c>();
        Functional_Contact_Role__c fcrSub2 = new Functional_Contact_Role__c();
        fcrSub2.ContactID__c = lstCon[2].Id;
        fcrSub2.SubscriptionID__c = subRole2.Id;
        fcrSub2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Subscription Role');
        lstFcrSub.add(fcrSub2);
        
        Functional_Contact_Role__c fcrSub3 = new Functional_Contact_Role__c();
        fcrSub3.ContactID__c = lstCon[1].Id;
        fcrSub3.SubscriptionID__c = subRole1.Id;
        fcrSub3.RecordTypeId = fcrHelper.getFCRRecordTypeId('Subscription Role');
        lstFcrSub.add(fcrSub3);
        
        Insert lstFcrSub;
		system.assert([select id from AccountContactRelation where accountid = :lstAcc[1].Id and contactid = :lstCon[2].id].size() == 1);        
        
        Test.stopTest();
    } 
	//EDGE - 41494 AC3
     @isTest
    static void testvalidateOrderPrimaryContact(){
        //User salesUser = [SELECT Id, Username, ProfileId FROM User where ProfileId  in (select id from profile where name=:Label.Profile_SalesEnterpriseB2B) and isactive=true limit 1]; // EDGE-85331
        // In test method users should be create insted of  user getting from system, this is causing the issue in PreprodTel on 12-May-2020 Full test run
        // so we commented above line and created user from TestUtil and Sales Enterprise B2B profile assigned .
        // on resquest change/Fix done by SFO for 20.06 FDR deployment 
        User salesUser = TestUtil.createUser('salesB2B@test.com.LaTest','SalesB2B',Label.Profile_SalesEnterpriseB2B);
        salesUser.Phone = '0444423454';        
        insert salesUser;       
        FunctionalContactRoleTriggerHelper fcrHelper = new FunctionalContactRoleTriggerHelper();
        system.runAs(salesUser){            
            ProfileName__c pName = new ProfileName__c();
            pName.Name=Label.Profile_SalesEnterpriseB2B; //EDGE-85331 :: 'Sales Enterprise B2B';
            insert pName;
            
			//Modified by Sri, team SFO on 16/01/2020
            //P2OB-4278: Addded 'Imported__c = True'  to bypass the validation rule 'SalesUsers_not_allowed_to_Import_Accs' on account creation
            Account acc = new Account(Name='TestACRAcc', Imported__c = true,Pref_Comm_Method__c='eMail',Email__c='ndtestacc@nirtest.com');
			Insert acc;
			//Contact con = new Contact(FirstName='TestFirstName',LastName='TestAcrCon',AccountId=acc.id,Pref_Comm_Method__c='eMail',Email='ndtest@nirtest.com',Phone='798964827');
			Contact con =TestUtil.createContact(acc.id,'TestFirstName','TestAcrCon');
            con.OwnerId=salesUser.id;
            con.MobilePhone = '0445678001';
            con.Pref_Comm_Method__c = 'eMail';
            con.email='test@email.com';
            con.Authority__c = System.Label.FullAuthority;
            Insert con;
            Test.startTest();
            csord__Order__c ord = new csord__Order__c();
            ord.csord__Identification__c = 'test identification';
            ord.csord__Account__c = acc.id;
            ord.csord__Order_Type__c = 'test order' ;
            ord.csord__Status2__c = 'In Progress';
            insert ord;
            Functional_Contact_Role__c fcrOrder1 = new Functional_Contact_Role__c();
            fcrOrder1.ContactID__c = con.Id;
            fcrOrder1.OrderID__c = ord.Id;
            fcrOrder1.Role__c = 'Order Primary Contact';
            fcrOrder1.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
            Insert fcrOrder1;
            Functional_Contact_Role__c fcr = [SELECT id FROM Functional_Contact_Role__c WHERE Role__c ='Order Primary Contact'];
            //System.assertEquals((fcr!=null),true,'Inserted');
            Functional_Contact_Role__c fcrOrder2 = new Functional_Contact_Role__c();
            fcrOrder2.ContactID__c = con.Id;
            fcrOrder2.OrderID__c = ord.Id;
            fcrOrder2.Role__c = 'Order Primary Contact';
            fcrOrder2.RecordTypeId = fcrHelper.getFCRRecordTypeId('Basket/Order Role');
            String error;
            try{
            	Insert fcrOrder2;
            }
            catch(DmlException de){
                error = de.getStackTraceString();
            }
            System.assertEquals((error!=null),true,'Error');
            Test.stopTest();
        }
    }
}
@istest
public class PRMManagePartnerPermissionsTest {
    public static Account acc;
    public static Account partneracc;
    @testSetup static void setup() {
        
          Map<String,id> profileMap = new Map<String,id>();
        Profile[] partnerProfile = [Select id,Name from Profile where Name IN ('PRM Community User - Australia','System Administrator')];
        
        for(Profile prof : partnerProfile){
            profileMap.put(prof.Name,prof.Id);
        }
        
        
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User uSysAdmin = new User(alias = 'Con123', email = 'ContactTr8wrw98@noemail.com', emailencodingkey = 'UTF-8', lastname = 'Testing', languagelocalekey = 'en_US', localesidkey = 'en_US', profileid = profileMap.get('System Administrator'), country = 'United States', IsActive = true, timezonesidkey = 'America/Los_Angeles', username = 'Cont987657awqas@noemail.com', userroleid = r.id);
        insert uSysAdmin;
        system.debug('uSysAdmin***********'+uSysAdmin);
        System.runAs(uSysAdmin) {
            id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
            id accRecordTypeIdpartner = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            Contact contact = new Contact(
            LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
			
            list < Account > lstA = new list < Account > ();
            acc = new Account();
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.RecordTypeId = accRecordTypeId;
            acc.Migrated_Customer__c = true;
            acc.Customer_status__c = 'ACTIVE';
            acc.BillingState = 'VIC';
            acc.Account_Status__c = 'Active';
            lstA.add(acc);
            partneracc = new Account();
            partneracc.RecordTypeId = accRecordTypeIdpartner;
            partneracc.Name = 'Partner Acc';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c = 'aaaa';
            partneracc.ACN__c = 'ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c = 'Partner';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone = '0412354323';
            partneracc.Overall_Accreditation__c = 'Platinum';
            partneracc.Mobility_Accreditation__c = 'Platinum';
            partneracc.Cloud_Accreditation__c = 'Platinum';
            partneracc.Data_Security_Accreditation__c = 'Platinum';
            partneracc.Collaboration_Accreditation__c = 'Platinum';
            partneracc.PartnerPrincipalContact__c = Contact.id;
           lstA.add(partneracc);
            Insert lstA;
            
            partneracc.IsPartner = true;
            update partneracc;
            
                 List<Contact> conList = new List<Contact>();
                Contact con = new Contact();
                   con.FirstName = 'Test Account';
                    con.LastName='Last Name';
                    con.AccountId=partneracc.Id;
                conList.add(con);
            
                Contact con1 = new Contact();
                   con1.FirstName = 'Test Account1';
                    con1.LastName='Last Name1';
                    con1.AccountId=partneracc.Id;
                conList.add(con1);
                insert conList;
            
		
              List<User> userList = new List<User>();
            User partUser = new User(alias = 'PART', email='test@noemail345555.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = profileMap.get('PRM Community User - Australia'), country='United States',IsActive =true,
                        ContactId = con.Id,isPRMSuperUser=True, 
                        timezonesidkey='America/Los_Angeles', username='test@noemai44l213.com');
                        userList.add(partUser);
            
          User partUser1 = new User(alias = 'PART', email='test@noemail34555511.com',
                        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                        localesidkey='en_US', profileid = profileMap.get('PRM Community User - Australia'), country='United States',IsActive =true,
                        ContactId = con1.Id,isPRMSuperUser=True, 
                        timezonesidkey='America/Los_Angeles', username='test@noemail4521311.com');
                        userList.add(partUser1);
             
            insert userList;
       
            PermissionSet ps= [select id from PermissionSet where PermissionSet.Name=:PRMConstants.PARTNER_COMMUNITY_USER_PERMISSION_NAME limit 1];

            PermissionSetAssignment psa= new PermissionSetAssignment();
            psa.PermissionSetid=ps.id;
            psa.AssigneeId=partUser.id;
            insert psa;
            
            Group pgroup=[select id from Group where DeveloperName=:PRMConstants.PUBLIC_GROUP_NO_CHATTER_CAPABILITY limit 1];
            list<GroupMember> gmlist=new list<GroupMember>();
            GroupMember gm= new GroupMember();
            gm.UserOrGroupId=partUser.id;
            gm.GroupId=pgroup.id;
            gmlist.add(gm);
            GroupMember gm1= new GroupMember();
            gm1.UserOrGroupId=uSysAdmin.id;
            gm1.GroupId=pgroup.id;
            gmlist.add(gm1);
            insert gmlist;           
		
            list<Opportunity> opplist= new list<Opportunity>();
            Opportunity opp = new Opportunity();
            opp.AccountId = acc.Id;
            opp.recordTypeId=oppRecordTypeId ;
            opp.Name = 'Test Opp';
            opp.Proposal_Required_Date__c = System.today() + 2;
            opp.CloseDate = System.today() + 10;
            opp.StageName = 'Develop';
            opp.Description__c = 'Test';
            opp.Product_Domain__c = 'MOBILES';
            opp.Shared_Opportunity__c = True;
            opp.PartnerAccountId = partneracc.id;
            opp.Partner_Opportunity_Verification__c = 'Approved';
            opp.SubmittoPartnerStatus__c = 'Approved';
            opplist.add(opp);
            
            Opportunity opp1 = new Opportunity();
            opp1.AccountId = acc.Id;
            opp1.recordTypeId=oppRecordTypeId ;
            opp1.Name = 'Test Opp1';
            opp1.Proposal_Required_Date__c = System.today() + 2;
            opp1.CloseDate = System.today() + 10;
            opp1.StageName = 'Develop';
            opp1.Description__c = 'Test';
            opp1.Product_Domain__c = 'MOBILES';
            opp1.Shared_Opportunity__c = True;
            opp1.PartnerAccountId = partneracc.id;
            opp1.Partner_Opportunity_Verification__c = 'Approved';
            opp1.SubmittoPartnerStatus__c = 'Approved';
            
             opplist.add(opp1);
            insert opplist;
			
            list<Opportunityteammember> opteamlist= new list<Opportunityteammember>();
			Opportunityteammember optm= new Opportunityteammember();
			optm.UserId=partUser.id;
			optm.OpportunityId=opp.id;
			optm.OpportunityAccessLevel='Edit';
            opteamlist.add(optm);
            Opportunityteammember optm1= new Opportunityteammember();
			optm1.UserId=partUser1.id;
			optm1.OpportunityId=opp1.id;
			optm1.OpportunityAccessLevel='Edit';
            opteamlist.add(optm1);
			insert opteamlist;			
        }
    }
	
	@istest
    public static void getPartnerPermTest() {
	opportunity opp=[select id,Account.Name from opportunity where name='Test Opp' limit 1];	
	test.starttest();
	 list<PRMManagePartnerPermissions.flowOutputs> flowoutputs=PRMManagePartnerPermissions.getpartneruserList(new list<string>{opp.id});
	test.stoptest();
        system.debug('flowoutputs[0].opteamids'+flowoutputs[0].opteamids);
	system.assert(flowoutputs[0].opteamids.size()==0);
     }
    
   	@istest
    public static void getPartnerPermETestsc1() {
	opportunity opp=[select id,Account.Name from opportunity where name='Test Opp1' limit 1];	
	test.starttest();
	 list<PRMManagePartnerPermissions.flowOutputs> flowoutputs=PRMManagePartnerPermissions.getpartneruserList(new list<string>{opp.id});
	test.stoptest();
	system.assert(flowoutputs[0].opteamids.size()>0);
     }
    	
}
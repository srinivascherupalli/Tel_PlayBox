@IsTest
public class updatePORstatusBatch_test {
    @IsTest
    public static void updatePOR(){
        account acc = new account();
        acc.name='test name';
        acc.Customer_Status__c = 'Active';
        insert acc;
        
        Partner_of_Record__c POR = new Partner_of_Record__c();
        POR.Customer__c = acc.id;
        POR.POR_End_Date__c = system.today().addDays(-3);
        POR.Status__c = 'Active';
        insert POR;  
        
        Partner_of_Record__c POR1= new Partner_of_Record__c();
        POR1.Customer__c = acc.id;
        POR1.POR_End_Date__c = system.today().addDays(-4);
        POR1.Status__c = 'Active';
        insert POR1;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Closed Lost';
        opp.AccountId = acc.Id;
        opp.isPOROpportunity__c = true;
        opp.Name = 'test Opp';
        opp.CloseDate = system.today().addDays(-4);
        insert opp;
        
        test.starttest();
        updatePORstatusBatch Bt = new updatePORstatusBatch();
        database.executeBatch(Bt);
        test.stopTest();
        
        Partner_of_Record__c[] porList = [SELECT Id, Name,Status__c FROM Partner_of_Record__c];
        Opportunity opps = [SELECT Id,name,isPOROpportunity__c  FROM Opportunity];
        system.debug('opps***'+opps);
        System.assertEquals(false, opps.isPOROpportunity__c);
        System.assertEquals('Expired', porList[0].Status__c);
        
    }
    @IsTest
    public static void updatePORNegative(){
        account acc = new account();
        acc.name='test name';
        acc.Customer_Status__c = 'Active';
        insert acc;
        
        Partner_of_Record__c POR = new Partner_of_Record__c();
        POR.Customer__c = acc.id;
        POR.POR_End_Date__c = system.today().addDays(+3);
        POR.Status__c = 'Active';
        insert POR;  
        
        Partner_of_Record__c POR1= new Partner_of_Record__c();
        POR1.Customer__c = acc.id;
        POR1.POR_End_Date__c = system.today().addDays(+4);
        POR1.Status__c = 'Active';
        insert POR1;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Closed Lost';
        opp.AccountId = acc.Id;
        opp.isPOROpportunity__c = true;
        opp.Name = 'test Opp';
        opp.CloseDate = system.today().addDays(-4);
        insert opp;
        
        test.startTest();
        updatePORstatusBatch Bt = new updatePORstatusBatch();
        database.executeBatch(Bt);
        test.stopTest();
        
        Partner_of_Record__c[] porList = [SELECT Id, Name,Status__c FROM Partner_of_Record__c];
        System.assertEquals('Active', porList[0].Status__c);
        
    }
	
    @IsTest
    public static void updatePORList(){
        account acc = new account();
        acc.name='test name';
        acc.Customer_Status__c = 'Active';
        insert acc;
        list<Partner_of_Record__c> porList = new list<Partner_of_Record__c>();
        for(integer i = 0;i<=100 ;i++){
            Partner_of_Record__c POR = new Partner_of_Record__c();
            POR.Customer__c = acc.id;
            POR.POR_End_Date__c = system.today().addDays(-3);
            POR.Status__c = 'Active';
            porList.add(POR); 
        }
        insert porList;
        Partner_of_Record__c POR1= new Partner_of_Record__c();
        POR1.Customer__c = acc.id;
        POR1.POR_End_Date__c = system.today().addDays(-4);
        POR1.Status__c = 'Active';
        insert POR1;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Closed Lost';
        opp.AccountId = acc.Id;
        opp.isPOROpportunity__c = true;
        opp.Name = 'test Opp';
        opp.CloseDate = system.today().addDays(-4);
        insert opp;
        
        test.starttest();
        updatePORstatusBatch Bt = new updatePORstatusBatch();
        database.executeBatch(Bt);
        test.stopTest();
        
        Partner_of_Record__c[] listRec = [SELECT Id, Name,Status__c FROM Partner_of_Record__c];
        System.assertEquals('Expired', listRec[0].Status__c);
    }
    @istest
    public static void testPORChatter(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        profile pSysAdmin = [select id,name from Profile where Name =:'System Administrator'];
        User uSysAdmin = new User(alias = 'Con123', email='ContactTr8wrw98@noemail.com',
                                  emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                  localesidkey='en_US', profileid =pSysAdmin.id, country='United States',IsActive =true,                
                                  timezonesidkey='America/Los_Angeles', username='Cont987657awqas@noemail.com', userroleid=r.id);
        id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
        insert uSysAdmin;
        
        System.runAs(uSysAdmin){  
            
            list<account> acclist= new list<account>();
            id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
            id PartnerrecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
            Contact contact = new Contact(
                LastName = 'Last', FirstName = 'First', Contact_Role__c = 'Consultant', OTP_Mobile_Phone_Number__c = '+612345678', Email = 'test@tele2.com', Contact_Status__c = 'Active');
            EnvironmentalSettings.isTriggerDisabled('ContactTrigger');
            Insert contact;
            
            account partneracc = new Account();
            partneracc.RecordTypeId = PartnerrecordTypeId ;
            partneracc.Name='Partner acc';
            partneracc.Account_Status__c = 'Active';
            partneracc.Customer_Trading_Name__c = 'Test';
            partneracc.ABN__c='aaaa';
            partneracc.ACN__c='ccc';
            partneracc.State_Coverage__c = 'VIC';
            partneracc.Partner_Type__c='Partner';
            partneracc.Website = 'www.vsygqwoci.com';
            partneracc.Phone='0412354323';
            partneracc.Overall_Accreditation__c='Platinum';
            partneracc.Mobility_Accreditation__c='Platinum';
            partneracc.Cloud_Accreditation__c='Platinum';
            partneracc.Data_Security_Accreditation__c='Platinum';
            partneracc.Collaboration_Accreditation__c='Platinum';
            partneracc.PartnerPrincipalContact__c = Contact.id;
            
            Account EnterPriseacc = AccountTestFactory.buildAccount('Test Enterprise');
            EnterPriseacc.Customer_Status__c = 'ACTIVE';    
            EnterPriseacc.recordTypeId=recordTypeId;
            
            acclist.add(Partneracc);
            acclist.add(EnterPriseacc);
            insert acclist;               
            
            Contact con = new Contact(LastName ='testCon',AccountId = Partneracc.Id,Partner_Role__c='MDM Operations User', Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
            insert con; 
            
            Partner_of_Record__c POR2 = new Partner_of_Record__c();
            POR2.customer__c = Partneracc.Id;
            por2.Partner__c = Partneracc.Id;
            POR2.Partner_Signatories__c = con.id;
            POR2.POR_End_Date__c = system.today().addDays(+30);
            POR2.Status__c = 'Active';
            insert POR2;
            
            test.starttest();
            PORChatterRemainder_Batch Bt = new PORChatterRemainder_Batch();
            database.executeBatch(Bt);
            test.stopTest();
            list<Partner_of_Record__c> por = [select id from Partner_of_Record__c where Partner_Signatories__c!=''];
            system.assert(por.size()>0);
        }
    }
}
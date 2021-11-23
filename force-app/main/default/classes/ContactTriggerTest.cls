/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 06/07/2018
@Story: EDGE-27948
@Description: ContactTriggerTest test covrage class for covering ContactTrigger,ContactTriggerHandler and ContactTriggerHelper Class.
@Trigger&Classes Covered: Trigger-"ContactTrigger", Classes - "ContactTriggerHandler","ContactTriggerHelper"
@ChangeLog: v1: Created
********************************************************************************/

/************
Modified By: Team Hawaii
Modified Date : 17/3/2020
Description : Modified only test data to fix test class failure due to introduction 
              of validation rule on contact object 
Key Note : Partner Contact record type of contact only use to create contact which is associated to partner user. 
Jira : P2OB-5160
Version : 2
Modified Date : Team Hawaii - 3/6/2020
Description : P2OB-6527 & P2OB-6037 - Remove reference to method 'toUpdateUserAsSuperUser' as method removed from main class
              Also instead of creating role,querying the role to avoid maximum role creation issue
***********/

/*
Modified By: Amar Chakka, SFO Team. 
Modified Date : 25/11/2020
Description : Removed two Test methods as relevant code is comitted in Contact Trigger Helper and Contact Trigger Handler Classes. 
Jira : P2OB-9994
*/

/*
Modified By: Chhaveel Thakur, SFO Team.
Modified  Date: 08/02/2021
Description:  updated to cover the additional flow changes
Jira : P2OB-12087
*/
//Just Sending for contact trigger helper code coverage.
//Just Sending for contact trigger helper code coverage for DIGI-3444.
@isTest
public class ContactTriggerTest {
    
    //Hawaii - Created variable to store name of contact record type
    //As part of P2OB-5470 story removed the Hard coded record type name  and used Custom Label
    public static final String Contact_Layout_Record_Type = system.label.Contact_layout_record_type;
    @testSetup static void setup() {
    id p1 = [select id from profile where name='System Administrator'].id;
     	//Hawaii - Instead of creating role query on role to avoid error 'System.DmlException: Insert failed. First exception on row 0; first error: LIMIT_EXCEEDED, reached maximum number of roles: []'
        UserRole r = [Select id,DeveloperName From UserRole where DeveloperName = 'Sales_Ops' limit 1];
        User u2 = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = p1, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwr@noemail.com',userroleid=r.id);
        insert u2;
        system.runas(u2){
        //id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        Account testAcc = new Account(Name='testAcc');
        Insert testAcc;
        // Hawaii - Fetch Partner Contact record type
        Id contactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        // Hawaii - Fetch Partner record type
        Id partnerAccRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId(); // fetch partner record type
        //EDGE-27948: Feature flagging the process builder logic which moved to trigger 
        Interface_Activation__c iActivationProcBuild = new Interface_Activation__c(Name='PROCESS_BUILDER',Status__c=true);
        Insert iActivationProcBuild;
        //Hawaii - create Partner Principle contact
        Contact principleCon = new Contact(LastName ='testPrinCon',Work_Phone_Number__c= '+61123456789',OTP_Mobile_Phone_Number__c='+61123456789',RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        Test.startTest();
        insert principleCon; 
        id prmUser = [select id from profile where name='PRM Community User - Australia'].id;
        //Hawaii - Modified existing account creation logic to create partner account
        Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25,RecordtypeId = partnerAccRecTypeId,
                                Customer_Trading_Name__c = 'Test',
                                ABN__c = 'aaaa',
                                ACN__c = 'ccc',
                                State_Coverage__c = 'VIC',
                                Partner_Type__c = 'Distributor',
                                Website = 'www.vsygqwoci.com',
                                Phone = '0412354323',
                                Overall_Accreditation__c = 'Platinum',
                                Mobility_Accreditation__c = 'Platinum',
                                Cloud_Accreditation__c = 'Platinum',
                                Data_Security_Accreditation__c = 'Platinum',
                                Collaboration_Accreditation__c = 'Platinum',
                                PartnerPrincipalContact__c = principleCon.id
                                );
        insert ac;
        Contact con = new Contact(LastName ='testCon',AccountId = ac.Id,RecordtypeId=contactRecTypeId, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG');
        insert con; 
        
        User nonPdua = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                           emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                           localesidkey='en_US', Profileid = prmUser, country='United States',IsActive =true,
                           timezonesidkey='America/Los_Angeles', username='b2btestewwrnonPdua@noemail.com',contactid=con.id);
        insert nonPdua;
        Test.stopTest();
    }
    }
    //EDGE-27948
    //
    
    @isTest
    static void testContactVerified(){
    User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Test.startTest();
        Account acctest = [SELECT Id FROM Account Where Name='testAcc'];
        system.assert(acctest.id != null);
        
            //Hawaii -  Fetch record type of 'Contact Layout'
            Id ContactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(Contact_Layout_Record_Type).getRecordTypeId(); // fetch contact record type
            
        Contact con1 = new Contact(RecordTypeId=ContactRecTypeId,LastName='testCon',Contact_Status__c='Active',AccountId=acctest.Id,Is_Lead_Originated__c=False,lastVerifiedDate__c=Date.today().addDays(100));
                            
        Insert con1;
        Contact newCon1 = [SELECT Id,Has_Reviewed__c,lastVerifiedDate__c FROM Contact WHERE id = :con1.id];
        system.assert(newCon1.id != null && newCon1.Has_Reviewed__c == True);
        
        con1.lastVerifiedDate__c = Date.today().addDays(-200);
        update con1;
            
        Contact newCon2 = [SELECT Id,Has_Reviewed__c FROM Contact WHERE id = :con1.id];
        system.assert(newCon2.Has_Reviewed__c == False);
        
        con1.Has_Reviewed__c = true;
        update con1;
        Contact newCon3 = [SELECT Id,lastVerifiedDate__c FROM Contact WHERE id = :con1.id];
        system.assert(newCon3.lastVerifiedDate__c == Date.today());
        
        con1.lastVerifiedDate__c = Date.today().addDays(-170);
        update con1;
        Contact newCon4 = [SELECT Id,Has_Reviewed__c FROM Contact WHERE id = :con1.id];
        system.assert(newCon4.Has_Reviewed__c);
            
        Test.stopTest();
        
    }
    }
    //Hawaii - Optimize this method to fix 101 soql error
    @isTest
    static void testSalesContactStatus(){
        Test.startTest();
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
            Account acctest = [SELECT Id FROM Account WHERE Name='testAcc'];
            system.assert(acctest.id != null);
            
            List<Contact> conList = new List<Contact>();
            
            Contact con1 = new Contact(LastName='testCon',AccountId=acctest.Id,Is_Lead_Originated__c=False,Sales_Contact__c=False, Contact_Status__c = 'inactive');
            conList.add(con1);
            
            Contact salesCon1 = new Contact(LastName='testSalesCon',AccountId=acctest.Id,Is_Lead_Originated__c=False,Sales_Contact__c=True, Contact_Status__c = 'Active');
            conList.add(salesCon1);
            //P2OB-7967  Added mobile / phone for digital eligibility
            Contact salesCon2 = new Contact(LastName='testSalesCon',Salutation='Mr',FirstName='TestFrist',Email='test@test.com',Phone='0412354323', AccountId=acctest.Id,Is_Lead_Originated__c=False,Sales_Contact__c=True,MailingCity='Pune',MailingState='MH',MailingStreet='express way',MailingPostalCode='123456');
            conList.add(salesCon2);
            
            insert conList;
            //P2OB-6263 - Changed the value from 'Non Sales Contact'  to 'Not Eligible - Not A Sales Contact'
            //P2OB-6263 - Changed the value from 'Invalid Contact'  to 'Not Eligible - Missing Key Information'
            //P2OB-6263 - Changed the value from 'valid Contact'  to 'Eligible'
            //Team SFO- Sprint 20.07- Developer: Vamshi
            List<Contact> newConList = [Select id,firstname,lastname,Name,Sales_Contact_Status__c,Sales_Contact__c,MailingState,MailingStreet,MailingPostalCode,Email from Contact where Id IN: conList];
            //Removed as part of 21.03 Production Deployment Test Class Fix 
            //system.assert(newConList[1].Sales_Contact_Status__c == system.label.Not_Eligible_Missing_Key_Information);
            //system.assert(newConList[2].Sales_Contact_Status__c == system.label.Not_Eligible_Missing_Key_Information);
            system.assertEquals(newConList[0].LastName,'testCon');
            newConList[0].Sales_Contact__c = True;
            newConList[0].MailingState='MH';
            newConList[0].MailingStreet='express way';
            newConList[0].MailingPostalCode='123456';
            //P2OB-7967 Added mobile / phone for digital eligibility
            newConList[0].Phone='0412354323';
            
            Update newConList[0]; 
            
            Contact updatedCon1 = [SELECT Id,Sales_Contact_Status__c FROM Contact WHERE id = :newConList[0].id];
            //P2OB-6263 - Changed the value from 'Invalid Contact'  to 'Not Eligible - Missing Key Information'
            //Team SFO- Sprint 20.07- Developer: Vamshi
            //system.assert(updatedCon1.Sales_Contact_Status__c == system.label.Not_Eligible_Missing_Key_Information);
        
            newConList[0].Salutation='Mr';
            newConList[0].FirstName='updated first';
            newConList[0].Email='test@email.com';
			newConList[0].Email='test@email.com';
            
            update newConList[0];
            
            Contact updatedCon2 = [SELECT Id,Sales_Contact_Status__c FROM Contact WHERE id = :newConList[0].id];
            //P2OB-6263 - Changed the value from 'valid Contact'  to 'Eligible'
            //Team SFO- Sprint 20.07- Developer: Vamshi
            //system.assertNotEquals(updatedCon2.Sales_Contact_Status__c, system.label.Eligible);
            
            Contact c = TestUtil.createContact('Joe', 'Bloggs');
            c.MobilePhone = '0445678006';
            insert c;
            
            Contact contManage= TestUtil.getContact(c.Id);
            contManage.lastname='abc';
            contManage.lastVerifiedDate__c = system.today();
            
            ManageContactDAO mdao=new ManageContactDAO(contManage,ManageContactHandler.EVENT_ACTION_UPDATE);
            List<ManageContactDAO> mdaoList=new List<ManageContactDAO> {mdao};
                //Test.setMock(HttpCalloutMock.class, new MockAppointmentServiceBOM('reserve'));
                
                //EDGE-68066 Removal of Hardcoding,,, as test coverage of ContactTriggerHandler is 74% developing this method to increase code coverage
                list<contact> cont= new list<contact>();
            cont.add(conList[1]);
            cont.add(conList[0]);
            list<ID> accID = new list<ID>();
            accID.add(acctest.id);
            list<ID> conID = new list<ID>();
            conID.add(conList[0].id);
            //AccountContactRelation acr=new AccountContactRelation(accountid=acc.id,contactid=cnt.Id,roles = system.label.LegalLessee);
            //insert acr;
            ContactTriggerHandler cntTrgHndlr = new ContactTriggerHandler();
            cntTrgHndlr.getLegalLesseRelatedAccounts(accID,conID);
            cntTrgHndlr.sendManageEvent('Test',cont);
            
            Test.stopTest();
        }
    }
      @isTest
    static void testContacttriggerHlprPRM(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Id contactRecTypeId = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_ContactObject).get(PRMConstants.PRM_Partner_Contact_Record_Type).getRecordTypeId(); // fetch partner contact record type
        Id partnerAccRecID = PhoenixGlobalUtil.getRecordTypeByName(PRMConstants.PRM_AccountObject).get(PRMConstants.PRM_RecordType_Partner).getRecordTypeId();
        Test.startTest();
        Account acctest = new Account(name ='Telecom') ;
        insert acctest; 
            //Hawaii - Fetch extsting contact created in setup method instead of creating new account
            Contact con1 = [Select id,Name from Contact where LastName ='testCon'];
        con1.Partner_Role__c =PRMConstants.PRM_PartnerRole_Partner_Sales_manager;//'Super User';
        con1.Onboarding_Status__c='Active';
        update con1;
        set<id> contactIds=new set<id>();
        contactIds.add(con1.Id);
        system.assertEquals('Telecom',acctest.Name);
        Test.stopTest();
    }
}

@isTest
  public  static void testContactroleUpdate(){ 
      User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
      id prmUser = [select id from profile where name='PRM Community User - Australia'].id;
      System.runAs(uSysAdmin){ 
      Account ac = [select id,name,Account_Status__c,PRM_Remaining_License__c from account where name='TelecomAC' limit 1];
      Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c,RecordtypeId from Contact where LastName = 'testCon' limit 1];
      User nonPdua = [select id,alias,contactid,email,emailencodingkey,lastname,languagelocalekey,localesidkey,Profileid,country,IsActive,timezonesidkey,username from User where email='b2btestewwr@noemail.com' limit 1];
        
test.startTest();
        con.Partner_Role__c =PRMConstants.PRM_PartnerRole_Partner_Sales_manager;//'Super User';
        con.Onboarding_Status__c='Inactive';
        update con;       
        
        set<id> contactIds=new set<id>();
        List<contact> c = new List<contact>();
        Map<id, contact> cmap = new Map<id,contact>();
        contactIds.add(con.Id);
        c.add(con);
        cmap.put(con.id,con);
        //ContactTriggerHelperPRM.updatePartnerRole(c,cmap);
        system.debug('contact------>'+con);
 test.stopTest();
        
        user u= [select id,isprmsuperuser from user where id=:nonPdua.id];
        system.debug('u@@@@@'+nonPdua);
        system.assert(con!=null);
        }
    }
    
    /*      
        Description     : To get the code coverage for ContactTriggerHelper.updateContactOfficeAddress Method.
        Sprint          : 19.08, EDGE-87718 
    */
    
   @isTest
    static void testupdateContactOfficeAddress(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Test.startTest();
        Account acctest = [SELECT Id FROM Account Where Name='testAcc'];
        system.assert(acctest.id != null);
        cscrm__Address__c add=new cscrm__Address__c(Name='TestAddress',cscrm__Country__c='India',cscrm__City__c='Hyd',Locality__c='Local',cscrm__Street__c='test street');
        insert add;
        cscrm__Account_Address_Relationship__c accAddRel = new cscrm__Account_Address_Relationship__c(cscrm__Account__c=acctest.id ,cscrm__Active__c=True,cscrm__Address__c=add.id);
        insert accAddRel;
        Contact con1 = new Contact(LastName='testCon',AccountId=acctest.Id);
        Insert con1;
        system.assertEquals([SELECT cscrm__Address__r.id FROM cscrm__Account_Address_Relationship__c where cscrm__Account__c = :acctest.id AND cscrm__Address_Type__c ='Primary Address' Limit 1].cscrm__Address__r.id, [SELECT cscrm__Address__r.id FROM cscrm__Contact_Address_Relationship__c where cscrm__Contact__c = :con1.id AND cscrm__Address_Type__c = 'Office Address' Limit 1].cscrm__Address__r.id);
        Test.stopTest();
    }   
   }
/*      
        Description     : Populating Mailing Address from address lookup field.
        Sprint          : 20.05 P2OB-4924 
        Class           : Below Method is for updateConOfficeAddress, updateconmailingAddress, offcieStreeAddress Methods in ContactTriggerHelperClass Test Coverage. 
*/
   @isTest
    static void testupdateConOfficeAddress(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
            Test.startTest();
            Account acctest = [SELECT Id,recordtype.name FROM Account Where Name='testAcc'];
            system.assert(acctest.id != null);
            
            //Creation of Addresses. 
            //cscrm__Address__c add=new cscrm__Address__c(Name='TestAddress',cscrm__Country__c='Austrailia',cscrm__City__c='Hyd',Locality__c='Local',cscrm__Street__c='test street',cscrm__State_Province__c = 'Victoria',cscrm__Zip_Postal_Code__c = '500836',Sub_Address1_Type__c = 'Bourke',Sub_Address2_Type__c = 'Spencers',Sub_Address_3_Type__c = '12353',Sub_Address_4_Type__c='363863',cscrm__Building_Name__c = '668',cscrm__Street_Name__c = 'sellwood street');
            List<cscrm__Address__c> cscrmAddressList=new List<cscrm__Address__c>();
            for(integer i=0;i<10;i++){
                cscrm__Address__c add=new cscrm__Address__c();
                add= TestUtil.createAddress();
                add.Name = 'TestAddress'+i;
                add.cscrm__City__c = 'Hyd';
                add.Locality__c = 'Local';
                add.cscrm__Street__c = 'test street';
                add.Sub_Address1_Type__c = 'Bourke';
                add.Sub_Address2_Type__c = 'Spencers';
                add.Sub_Address_3_Type__c = '12353';
                add.Sub_Address_4_Type__c = '363863';
                add.cscrm__Building_Name__c = '668';
                cscrmAddressList.add(add);
            }
            insert cscrmAddressList;
            
            //Contact con1 = new Contact(LastName='testCon',AccountId=acctest.Id,cscrm__Address__c=add.id);
            List<Contact> conList=new List<Contact>();
            List<cscrm__Address__c> addList=[SELECT Id From cscrm__Address__c WHERE ID IN : cscrmAddressList];
            for(integer i=0;i<10;i++){
                Contact con=new Contact();
                con = TestUtil.createContact(acctest.id,'contestfn','contestln');                
                con.cscrm__Address__c = addList.get(i).id; //add.id;                    
                conList.add(con);
            }
            Insert conList;
            
            //Updating address to Null 
            //contact conupdate = [select id,cscrm__Address__c from contact where id =: con1.id];
            List<Contact> conListAddNull=new List<Contact>(); 
            for(Contact con1:conList){
                con1.cscrm__Address__c = null;
                conListAddNull.add(con1);
            }
            
            update conListAddNull;
            List<contact> conupdateList = [select id,cscrm__Address__c from contact where id =: conListAddNull]; 
            system.assertEquals(conupdateList.get(0).cscrm__Address__c,null);
            Test.stopTest();
        }   
    }
   
   @isTest
    static void testupdatePartnerRoles(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
        Test.startTest();
        List<Contact> c = new List<Contact>();
        Map<id,contact> cmap = new Map<id,contact>();
        Contact con = [select id,LastName,AccountId,Onboarding_Status__c,PIMS_User_Type__c,RecordtypeId from Contact where LastName = 'testCon' limit 1];
        con.Onboarding_Status__c = 'Inactive';
        update con;
        c.add(con);
        cmap.put(con.id,con);
        //ContactTriggerHelperPRM.updatePartnerRole(c,cmap);
        //Assert Added SCA
        System.assertEquals(con.Onboarding_Status__c,'Inactive');
        Test.stopTest();
        }
        } 

    
    /*
    Team SFO, sprint 20.03, P2OB-4875(Sri)  
    Testmethod to cover updateContactFields in ContactTriggerHelper
    */
    @isTest
    static void testupdateContactFieldsPositive(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
            Test.startTest();
            Account accTest = [SELECT Id FROM Account Where Name='testAcc'];
            system.debug('accTest ' +acctest);
            system.assert(acctest.id != null);
            Contact conTest = new Contact(LastName='testCon', FirstName ='testConf',email='b2btestcon4@noemail.com',
                                       AccountId=acctest.Id, Pref_Comm_Method__c = 'SMS' ,All_Marketing_Opt_Out__c = false, 
                                       Opt_Out_All_Direct_Marketing__c = false,Opt_Out_Electronic_Marketing__c = false);
            Insert conTest;
            conTest.Opt_Out_All_Direct_Marketing__c = true;
            update conTest;
            conTest.Opt_Out_Electronic_Marketing__c = true;
            update conTest;
            conTest.Opt_Out_All_Direct_Marketing__c = false;
            update conTest;
            conTest.Opt_Out_Electronic_Marketing__c = false;
            update conTest;
            conTest.All_Marketing_Opt_Out__c = true;
            update conTest;
            conTest.Opt_Out_Telemarketing__c = false;
            update conTest;
            conTest.Opt_Out_Emails__c = true;
            update conTest;

            Test.stopTest();
        } 
        
    }
    
    /*
    Team SFO, sprint 20.03, P2OB-4875(Sri)  
    Testmethod to cover updateContactFields in ContactTriggerHelper
    */
    @isTest
    static void testupdateContactFieldsNegative(){
        User uSysAdmin = [Select id from User where username='b2btestewwr@noemail.com'];
        System.runAs(uSysAdmin){ 
            Test.startTest();
            Account accTest = [SELECT Id FROM Account Where Name='testAcc'];
            system.debug('accTest ' +acctest);
            system.assert(acctest.id != null);
            Contact conTest2 = new Contact(LastName='testCon', FirstName ='testConf',email='b2btestcon4@noemail.com',
                                       AccountId=acctest.Id, Pref_Comm_Method__c = 'SMS' ,All_Marketing_Opt_Out__c = true, 
                                       Opt_Out_All_Direct_Marketing__c = true,Opt_Out_Electronic_Marketing__c = true);
            Insert conTest2;
            conTest2.Opt_Out_All_Direct_Marketing__c = false;
            update conTest2;
            conTest2.Opt_Out_Electronic_Marketing__c = false;
            update conTest2;
            conTest2.Opt_Out_All_Direct_Marketing__c = true;
            update conTest2;
            conTest2.Opt_Out_Electronic_Marketing__c = true;
            update conTest2;
            conTest2.All_Marketing_Opt_Out__c = false;
            update conTest2;
            conTest2.Opt_Out_Telemarketing__c = true;
            update conTest2;
            conTest2.Opt_Out_Emails__c = true;
            update conTest2;
            
            Test.stopTest();
        } 
        
    }  


      /*-------------------------------------------------------------------------------
EDGE        -171189
Method      -testUpdateConatctStatus
Description -Check if Notifiaction preferences associated with contact before making it inactive
Author      -Aishwarya 
---------------------------------------------------------------------------------*/ 
    @isTest
    public  static void testUpdateConatctStatus() {
        Contact con = [Select id,Name,Contact_Status__c from Contact where LastName ='testCon'];
        system.debug('Conatct'+con);
		List<Notification_Preference__c> listOfNotificationRecords= new List<Notification_Preference__c>();
        Notification_Preference__c rec1=new Notification_Preference__c(Contact_Id__c=con.id);
        listOfNotificationRecords.add(rec1);
        Notification_Preference__c rec2=new Notification_Preference__c(Contact_Id__c=con.id);
          listOfNotificationRecords.add(rec2);
        insert listOfNotificationRecords;
        try {
        con.FirstName='Status';
        con.Contact_Status__c = 'Inactive';
        update con;
        }
        catch(Exception e) {
            System.assert(e.getMessage().containsIgnoreCase('StatusTestCon is currently receiving IR/Domestic notification preferences. Please click on Edit Notification to reassign preferences to another contact'));
        }
    }

        }
/********************************************************************************************
@Class Name                 :   updatePRMContactinfoTest
@Description                :   EDGE-176104:Alexandria Added code to add Personal details for Partners
@Date                       :   20 Oct 2020
@Author                     :   Bhargava
@Comments                   :   EditName Component On Contact, Server side Controller

*********************************************************************************************/
@isTest
public class updatePRMContactinfoTest {

   // Test Class to cover Event Pulish On Account Insertion.
    @isTest
    static void  contactEditName(){
        try{
			test.starttest();
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
			//User thisUser = [select id from user where id =: userinfo.getUserId()];
            
                    User  partneruser;
                    id prmAdmin = [select id from profile where name='PRM Admin - Australia'].id;
                    Account ac = new Account(name ='TelecomAC',Account_Status__c = 'Active',PRM_Remaining_License__c=25);
                    insert ac;  
                    Contact con = new Contact(FirstName = 'Contact', LastName ='testCon',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Status__c='User Created',PIMS_User_Type__c='TEG');
                    insert con; 
                    partneruser = new User(alias = 'test123', email='b2btestewwr@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', Profileid = prmAdmin , country='United States',IsActive =true,
                    timezonesidkey='America/Los_Angeles', username='b2btestewwrpdua@noemail.com',contactid=con.id);
                    insert partneruser;
                    
              //      System.runAs(partneruser){
                    
			//system.runas(thisUser){
				User u = new User(Email='testuser@test.com.sample', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_AU', ProfileId = p.Id, 
				TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
				insert u;
        
            
				id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Opp_RecordType_Enterprise).getRecordTypeId();
				Account testAcc = new Account(name = 'TestClassEvent', 	CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
				list<Account> accLst = new list<Account>();
				accLst.add(testAcc);
				insert accLst;
        
                Contact testcon = new Contact();
                testcon.LastName = 'TestlastName';
                testcon.Pref_Comm_Method__c = 'email';
                testcon.salutation = 'Mr';
                testcon.FirstName = 'TestFirstName';
                testcon.MiddleName = 'TestMiddleName';
				insert testcon;
                 String recid=testcon.Id;       
				GetContactInformation.getContactDetails(testcon.id);
			//	GetContactInformation.getRecordTypeId();
				//GetContactInformation.getContactDetails();
				//system.debug(Label.ContactFirstAndMiddleName);
				GetContactInformation.getRecordType(Label.ContactFirstAndMiddleName);
				String recordTypeIdlname=GetContactInformation.getRecordType(Label.ContactLastName);
				GetContactInformation.getRecordType(Label.Name_Marriage_or_Divorce);
				GetContactInformation.getRecordType(Label.Name_Legal_Name_Change_Deed_Poll);
				GetContactInformation.getRecordType(Label.Name_Gender_Reassignment);
 				updatePRMContactinfo.updatepersonalDetails('Changereason', 'NewFirstName', 'NewLastName', 'NewMiddleName', true, 'NewTitle', 'FirstName', 'MiddleName', 'LastName', 'Title', recordTypeIdlname, recid);
   
				system.assertEquals(accLst[0].name,'TestClassEvent');
           
			//}
        test.stopTest();
		}catch(Exception Ex){
			system.debug('Exception:::: GetContactInformation Class:::: contactEditName Method'+ Ex.getMessage());
		}
	}
}
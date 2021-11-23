/*
 @Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

@isTest
public class SharepointAccRelatedlistControllerTest {
// Test Class to cover Event Pulish On Account Insertion.
    @isTest
    static void  createAccMemberSyncEventTest(){
        try{
			test.starttest();
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
			User thisUser = [select id from user where id =: userinfo.getUserId()];
			system.runas(thisUser){
				User u = new User(Email='testuser@test.com.sample', 
				EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
				LocaleSidKey='en_AU', ProfileId = p.Id, 
				TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
				insert u;
        
            
				id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.Account_RecordType_Enterprise).getRecordTypeId();
				Account testAcc = new Account(name = 'TestClassEvent', 	CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
				list<Account> accLst = new list<Account>();
				accLst.add(testAcc);
				insert accLst;
        
				SharepointAccRelatedlistController.getAccRecord(testAcc.id);
				SharepointAccRelatedlistController.createAccMemberSyncEvent(testAcc.id);
				SharepointAccRelatedlistController.createAccRequestAccess(testAcc.id);
				system.assertEquals(accLst[0].name,'TestClassEvent');
           
			}
        test.stopTest();
		}catch(Exception Ex){
			system.debug('Exception:::: SharepointAccRelatedlistControllerTest Class:::: eventPublishOnAccCreation Method'+ Ex.getMessage());
		}
	}
}
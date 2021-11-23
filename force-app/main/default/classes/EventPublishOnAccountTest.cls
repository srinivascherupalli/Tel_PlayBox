@isTest
public class EventPublishOnAccountTest {
    
    // Test Class to cover Event Pulish On Account Insertion.
    @isTest
    static void  eventPublishOnAccCreationTest(){
        test.starttest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [select id from user where id =: userinfo.getUserId()];
        system.runas(thisUser){
        User u = new User(Email='testuser@test.com.sample', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_AU', ProfileId = p.Id, 
            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
        
        insert u;
        
         PermissionSet ps = new PermissionSet();
            ps.Name = 'TestPermission';
            ps.Label = 'Test';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'SharePointAccountCreate'][0].Id;
            insert sea;
            /*PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa;*/
            
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        Account testAcc = new Account(name = 'TestClassEvent', 	CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
        list<Account> accLst = new list<Account>();
        accLst.add(testAcc);
        insert accLst;
        //system.debug('The Value of Inserted Account is'+ testAcc);
        //system.debug('The Value of Inserted User is'+u);
        system.assertEquals(accLst[0].name,'TestClassEvent');
            
            //AccountTriggerHelper accTrgHlpr = new AccountTriggerHelper();
            //accTrgHlpr.eventPublishOnAccCreation(testAcc);
            
        }
        test.stopTest();
    }


 @isTest
    static void  eventPublishOnAccUpdateTest(){
        test.starttest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User thisUser = [select id from user where id =: userinfo.getUserId()];
        system.runas(thisUser){
        User u = new User(Email='testuser@test.com.sample', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_AU', ProfileId = p.Id, 
            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T');
        
        insert u;
        
         PermissionSet ps = new PermissionSet();
            ps.Name = 'TestPermission';
            ps.Label = 'Test';
            insert ps;
            SetupEntityAccess sea = new SetupEntityAccess();
            sea.ParentId = ps.Id;
            sea.SetupEntityId = [select Id from CustomPermission where DeveloperName = 'SharePointAccountChange'][0].Id;
            
            insert sea;
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa;
            
        id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
        Account testAcc = new Account(name = 'TestClassEvent', 	CIDN__c = 'ASDF1234', recordTypeId = recordTypeId);
        list<Account> accLst = new list<Account>();
        accLst.add(testAcc);
        insert accLst;
        list<Account> accUpdLst = new list<Account>();
        Account accUpd = [select id from account where id  =:accLst[0].id];
        accUpd.Name = 'TestEventUpdation';
        accUpdLst.add(accUpd);
        update accUpdLst;
        
        //system.debug('The Value of Inserted Account is'+ testAcc);
        //system.debug('The Value of Inserted User is'+u);
        system.assertEquals(accUpdLst[0].name,'TestEventUpdation');
            
            //AccountTriggerHelper accTrgHlpr = new AccountTriggerHelper();
            //accTrgHlpr.eventPublishOnAccCreation(testAcc);
            
        }
        test.stopTest();
    }
}
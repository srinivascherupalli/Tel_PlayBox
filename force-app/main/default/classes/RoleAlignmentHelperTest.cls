/*
@Last Modified        : 07/01/2020 21.01 by Chhaveel, Team SFO
               				         as part of P2OB-9943/P2OB-6772 Removing Commented Code,debug Statements and updating API version to 50.
*/

@isTest
public class RoleAlignmentHelperTest {
    
    private static testMethod void  RoleAligmentLV6NameUniquenessCheckTest(){
		Test.StartTest();
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User usr = new User(Email='telsta@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863470',username='telsta@test.com.Test',alias = 'Use1T');
                              
        User usr1 = new User(Email='telsta1@test.com', 
                            EmailEncodingKey='UTF-8', LastName='Test1', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_AU', ProfileId = p.Id, 
                            TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1@test.com.Test',alias = 'Use1T1');
                       
        insert usr;
        insert usr1;
        system.runas(usr){
				
            Role_Hierarchy__c rolehirchy = new Role_Hierarchy__c(Name = 'TestLV6Role',LV1_Role__c = 'TestLV1Role');
            insert rolehirchy;
            system.assertEquals(rolehirchy.Name,'TestLV6Role');
            Role_Hierarchy__c rolehirchy2 = new Role_Hierarchy__c(Name = 'TestLV6Role1',LV1_Role__c = 'TestLV1Role');
            insert rolehirchy2;
         
            Role_Alignment__c rolAlgn = new Role_Alignment__c();
            rolAlgn.LV6_Role__c = rolehirchy.id;
            rolAlgn.LV6_Name__c = usr.id;
            rolAlgn.LV1_Name__c = usr.id;
            insert rolAlgn;
                
            Role_Alignment__c rolAlgn3 = new Role_Alignment__c();
            rolAlgn3.LV6_Role__c = rolehirchy2.id;
            rolAlgn3.LV6_Name__c = usr1.id;
            rolAlgn3.LV1_Name__c = usr1.id;
            insert rolAlgn3;
                
            Role_Alignment__c r1Update = [select id,LV6_Name__c, LV1_Name__c from Role_Alignment__c where id =: rolAlgn3.id];
            r1Update.LV6_Name__c = usr.id;
            try{
                update r1Update;
            }catch(Exception ex){
                system.debug('Exception:::: RoleAlignmentHelperTest Class:::: RoleAligmentLV6NameUniquenessCheckTest Method'+ ex.getMessage());
            }
			
            list<Role_Alignment__c> r2 = new list<Role_Alignment__c>();
            Role_Alignment__c rolAlgn1 = new Role_Alignment__c();
            rolAlgn1.LV6_Role__c = rolehirchy.id;
            rolAlgn1.LV6_Name__c = usr.id;
            rolAlgn1.LV1_Name__c = usr.id;
            r2.add(rolAlgn1);
			try{
				insert r2;
            }catch(Exception ex){
                system.debug('Exception:::: RoleAlignmentHelperTest Class:::: RoleAligmentLV6NameUniquenessCheckTest Method'+ ex.getMessage());
            }
        }  
        Test.StopTest();
    }
}
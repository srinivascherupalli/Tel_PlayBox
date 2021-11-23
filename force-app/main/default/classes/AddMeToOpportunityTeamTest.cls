/********************************************************************************************
@Class Name                 :   AddMeToOpportunityTeamTest
@Description                :   Sprint_19.03,EDGE-63675
@Date                       :   27th Feb, 2019
@Author                     :   Team SFO(Amar Chakka)
@Comments                   :   Test Class

@Last Modified By           :   Srikanth (Team SFO) for test coverage
@Last Modified Date         :   24/06/2021
@Last Modified Comments     :   P2OB-13741 Sprint 21.09           

*********************************************************************************************/
@isTest
public class AddMeToOpportunityTeamTest {
        
        @isTest static void oppTeamMemberInsertionTest() {
        test.startTest();
                
                Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
               userRole R1 = [SELECT Id FROM UserRole where DeveloperName = : System.label.UserRole];

            User thisUser = [select id from user where id =: userinfo.getUserId()];
            system.runas(thisUser){
                User u = new User(Email='testuser@test.com.sample', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_AU', ProfileId = p.Id, 
                TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D878586',username='UseT55145@noemail.com',alias = 'Use1T',UserRoleId = R1.Id);
                insert u;
        
            
                id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
                Account testAcc = new Account(name = 'TestClassEvent',  CIDN__c = 'ASDF1234', recordTypeId = recordTypeId,Customer_Status__c='Active');
                insert testAcc;
        
                /*** To Cover invokeLocalMethodTeamMemberDelete Method ***/
                AccountTeamMember accTeamMem = new AccountTeamMember(accountId = testAcc.id, userId = u.id);
                insert accTeamMem;
                
                Contact testcon = new Contact();
                testcon.LastName = 'TestlastName';
                testcon.Pref_Comm_Method__c = 'email';
                testcon.salutation = 'Mr';
                testcon.FirstName = 'TestFirstName';
                testcon.MiddleName = 'TestMiddleName';
                testcon.Contact_Status__c='Active';
                testcon.AccountID=testAcc.id;
                insert testcon;
                
                Opportunity opp=new Opportunity();
                opp.AccountId=testAcc.Id;
                opp.Name='TestOppCreateForEventCreate';            
                opp.Proposal_Required_Date__c=System.today()+2;
                opp.CloseDate=System.today()+10;
                opp.StageName='Develop';
                opp.Description__c='Test';
                opp.Product_Domain__c='MOBILES';
                opp.Shared_Opportunity__c=True;
                insert opp;
                system.assertEquals(opp.Name,'TestOppCreateForEventCreate');
                
                /*** To Cover invokeLocalMethodTeamMemberDelete Method ***/
                OpportunityTeamMember oppTeamMem = new OpportunityTeamMember();
                oppTeamMem.opportunityId = opp.id;
                oppTeamMem.UserId = u.id;
                insert oppTeamMem;
                
                AddMeToOpportunityTeam.flowInputs fInpsCls = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls.methodExecution = 'oppTeamMemberCreate';
                fInpsCls.oppId = opp.id;
                //fInpsCls.oppAccessLevel = 'Edit';
                fInpsCls.oppAccessLevel = True;
                fInpsCls.teamMemberRole = 'Sales Rep';
                
                
                list<AddMeToOpportunityTeam.flowInputs> lflowInput = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput.add(fInpsCls);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput);
                
                
                AddMeToOpportunityTeam.flowInputs fInpsCls2 = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls2.methodExecution = 'oppTeamMemberCreate';
                fInpsCls2.oppId = opp.id;
               // fInpsCls2.oppAccessLevel = 'Edit';
               //fInpsCls2.oppAccessLevel = True;
                fInpsCls2.teamMemberRole = 'Sales Rep';
                fInpsCls2.userId = u.id;
                
                list<AddMeToOpportunityTeam.flowInputs> lflowInput2 = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput2.add(fInpsCls2);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput2);
                
                
                AddMeToOpportunityTeam.flowInputs fInpsCls1 = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls1.methodExecution = 'UserRoleCheck';
                
                
                list<AddMeToOpportunityTeam.flowInputs> lflowInput1 = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput1.add(fInpsCls1);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput1);
                
                
                
                AddMeToOpportunityTeam.flowInputs fInpsCls4 = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls4.methodExecution = 'UserRoleCheck';
                fInpsCls4.userRole = R1.id;
                
                list<AddMeToOpportunityTeam.flowInputs> lflowInput4 = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput4.add(fInpsCls4);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput4);
                
                AddMeToOpportunityTeam.flowInputs fInpsCls5 = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls5.methodExecution = 'OppTeamMemberRemoval';
                fInpsCls5.accTeamMemberID = accTeamMem.id;
                fInpsCls5.oppTeamMemberID = oppTeamMem.id;
                fInpsCls5.accTeamMemberToDeleteYes = 'Yes';
                list<AddMeToOpportunityTeam.flowInputs> lflowInput5 = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput5.add(fInpsCls5);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput5);
                
                AddMeToOpportunityTeam.flowInputs fInpsCls6 = new AddMeToOpportunityTeam.flowInputs();
                fInpsCls6.methodExecution = 'OppTeamMemberRemoval';
                //fInpsCls5.accTeamMemberID = accTeamMem.id;
                fInpsCls6.oppTeamMemberID = accTeamMem.id;
                fInpsCls6.accTeamMemberToDeleteYes = 'Yes';
                list<AddMeToOpportunityTeam.flowInputs> lflowInput6 = new list<AddMeToOpportunityTeam.flowInputs>();
                lflowInput6.add(fInpsCls6);
                AddMeToOpportunityTeam.invokeFromAddToTeamMember(lflowInput6);
                
                test.stopTest();
                 
            }
        }
}
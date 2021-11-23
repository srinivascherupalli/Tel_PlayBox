/*******************************************************************
@Class Name     :   SFOGenerateRecommendations_CBSnSFDTest
@Sprint         :   P2OB-14469 & P2OB-15094, Sprint 21.10
@Author         :   SFO Team (Sri)
@CreateDate     :   20/07/2021
@Description    :   Test class for SFOGenerateRecommendations_CBSnSFD
@Last Modified  : 	

*********************************************************************/
@IsTest
public class SFOGenerateRecommendations_CBSnSFDTest {
    @testSetup
    static void setup(){
        try{
            Profile pf = [select id from profile where name =:Label.Profile_SalesEnterprise]; 
            Profile pfAdmin = [select id from profile where name =:Label.Profile_SystemAdmin]; 
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
            List<user> userList = new List<user>();
           User sales = TestUtil.createTestUser(r.id,pf.id,'standt','Testing');
            sales.username='salesuser@testsales.com';
            sales.email='salesuser@testsales.com';
            sales.phone='+121231231234';
            User admin = TestUtil.createTestUser(r.id,pfAdmin.id,'admin','admmintest');
            admin.username='admin@testadmin.com';
            admin.email='admin@testadmin.com';
            admin.phone='+121231231234';
            userList.add(sales);
            userList.add(admin);
            insert userList;
            System.runAs(admin){
                Account customerAccount=TestUtil.createAccount('Test Account');
                customerAccount.ownerId = sales.id;
                insert customerAccount;
                Id myRecordTypeStandard  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
                // User salesUser = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];

                Opportunity opp = TestUtil.createOpportunity(customerAccount.Id);
                opp.Name='standard opportunity';
                opp.RecordTypeId = myRecordTypeStandard;
                opp.Type = 'Renewal';
                opp.stagename = 'Propose';
                opp.Billing_Solution__c = 'Standard';
                opp.Product_Domain__c = 'CLOUD SERVICES';
                opp.Product_Type__c = 'Non Modular';
                opp.ownerId = sales.id;
                insert opp;
            }
            
        }
        catch (Exception ex) {
            system.debug('Exception:::: SFOGenerateRecommendations_CBSnSFDTest :::: setup Method'+ ex.getMessage());
        }
    }
    
    /*
@Method Name: testGetRecommendations
@Description: P2OB-14469 & P2OB-15094, Sprint 21.10
To test a sceanrio where opp needs show two recommendations
@Author		: Sri (Team SFO)
*/
    @isTest
    public static void testGetRecommendations(){
        try{
            User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
            System.runAs(sales){
                Opportunity opp = [select id from Opportunity ];
                List<String> inputData = new List<String>();
                inputData.add(opp.id);
                Test.startTest();
                List<List<Recommendation>> recs = SFOGenerateRecommendations_CBSnSFD.getRecommendations(inputData);
                Test.stopTest();
                system.assertEquals(2, recs[0].size());
            }
            
        }
        catch (Exception ex) {
            system.debug('Exception:::: SFOGenerateRecommendations_CBSnSFDTest :::: testGetRecommendations Method'+ ex.getMessage());
        }
    }
    
    /*
@Method Name: testCheckCaseExistence
@Description: P2OB-14469 & P2OB-15094, Sprint 21.10
To test a sceanrio where opp needs show no recommendations
@Author		: Sri (Team SFO)
*/
    @isTest
    public static void testCheckCaseExistence(){
        try{
            User sales = [Select id,IsActive from user where lastname ='Testing' and IsActive =true Limit 1 ];
            System.runAs(sales){
                Id cbsRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
                Id sfdRecordTypeId  = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SFD_Request').getRecordTypeId();
                Opportunity opp = [select id from Opportunity];
                List<String> inputData = new List<String>();
                inputData.add(opp.id);
                
                List<Case> caseList =  new List<Case>();
                Case cbsCase = TestUtil.createCaseEnterprise(cbsRecordTypeId,null,opp.id,'CBS Case');
                cbsCase.srvsup_Categories__c = 'Billing Solution Contract Implementation';
                caseList.add(cbsCase);
                Case sfdCase = TestUtil.createCaseEnterprise(sfdRecordTypeId,null,opp.id,'SFD Case');
                caseList.add(sfdCase);
                
                Test.startTest();
                insert caseList;
                Test.stopTest();
                
                List<List<Recommendation>> recs = SFOGenerateRecommendations_CBSnSFD.getRecommendations(inputData);
                system.assertEquals(0, recs[0].size());
            }
            
        }
        catch (Exception ex) {
            system.debug('Exception:::: SFOGenerateRecommendations_CBSnSFDTest :::: testCheckCaseExistence Method'+ ex.getMessage());
        }
    }
}
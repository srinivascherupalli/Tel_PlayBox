/*
 * CreatedBy : Team Hawaii
 * CreatedDate : 4/1/2021
 * Jira Number : P2OB-11683
 * Description : Test class for 'CaseTeamMemberPlugin; class
 * */
@isTest(SeeAllData=false)
public class CaseTeamMemberPluginTest {
    //Create test data
    @testSetup
    static void createTestData(){
        
        List<User> lstuser = new List<User>();
        List<CaseTeamMember> lstCaseTeamMember = new List<CaseTeamMember>();
        List<Account> lstAcc = new List<Account>();
        List<Case> lstCase = new List<Case>();
        List<Opportunity> lstOpp=new List<Opportunity>();
        //get presales solution record Type id for case
        Id preSalesCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        //get opportunity record Type if for opportunity
        Id standardRecordTyped = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        //get Account record type for account
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        //get case team member role
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID, Name FROM CaseTeamRole WHERE Name in ('Sales Rep', 'Qualification Lead','Account Manager')];
        //get system administrator profile 
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        //create user 
        lstuser = soc_TestUtility.createListUser(10, p.Id);
        insert lstuser;
        //validate lstuser should not be null and size should be grater than zero.
        if(lstuser!=null && lstuser.size() > 0){
            //run as user
            System.runAs(lstuser.get(0)){
                lstAcc = soc_TestUtility.createListAccount(1, accRecordTypeId);
                if(lstAcc!=null && lstAcc.size()>0){
                    Insert lstAcc;
                    //create opportunity
                    lstOpp = soc_TestUtility.createListOpportunity(1, standardRecordTyped, lstAcc.get(0).id);
                    if(lstOpp !=null && lstOpp.size() > 0){
                        insert lstOpp;
                        //create case
                        lstCase = soc_TestUtility.createListCase(1, preSalesCaseRecordTypeId, lstAcc.get(0).id, lstOpp.get(0).id);
                        insert lstCase;
                    }
                }
            }
        }
    }
    
    //test CaseTeamMemberPlugin method
    public static testMethod void testGetCaseIdNotCaseTeam(){
        List<Case> caseList = [Select id FROM Case];
        List<user> userList = [Select id from User where createdDate = today AND isActive = true limit 1];
        //pass input parameters
        List<CaseTeamMemberPlugin.FlowInputParameter> flowInputs = new List<CaseTeamMemberPlugin.FlowInputParameter>();
        CaseTeamMemberPlugin.FlowInputParameter input = new CaseTeamMemberPlugin.FlowInputParameter();
        input.sobjectList = caseList;
        input.userId = !userList.isEmpty() ? userList.get(0).Id : UserInfo.getUserId();
        flowInputs.add(input);
        //get flow output
        List<CaseTeamMemberPlugin.FlowOutputParameter> flowOutputs = CaseTeamMemberPlugin.getCaseIdNoCaseTeamMember(flowInputs);
        System.assert(!flowOutputs.isEmpty());        
    }
}
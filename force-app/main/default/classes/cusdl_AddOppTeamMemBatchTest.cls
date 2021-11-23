/**
  * Author: Sandeep Soni
  * Team: Jaipur
  * Sprint: 20.06
  * JIRA Story: P2OB-6036
  * Date: 22 April 2020
  * Class Name: cusdl_AddOppTeamMemBatchTest 
  * Description: This Test class will test all test scenario of batch class.
  **/
/**
 * Modified Date : 15/12/2020
 * Team : Hawaii
 * Sprint: 20:17(P2OB-11249)
 * Date : 15 December 2020
 * Description : Added 'executeTestWithOffShoreRestrictedForPresalesSolution' method to test 'PreSales Solution'logic

 * Hawaii - 01/07/2021 - Fixes for failure INACTIVE_OWNER_OR_USER issue

**/
 

@isTest(SeeAllData=false)
public class cusdl_AddOppTeamMemBatchTest {
    public static integer recordCount = 11;
    /*
     * For Creating test data
    */
    @testSetup
    static void createTestData(){
        List<Opportunity> combineOpptyList = new List<Opportunity>();
        List<Case> combineCaseList = new List<Case>();
        List<Opportunity> lstOpp=new List<Opportunity>();
        List<Opportunity> lstOppStandard=new List<Opportunity>();
        List<Case> lstCase = new List<Case>();
        List<Case> lstCaseStandard = new List<Case>();
        List<Account> lstAcc = new List<Account>();
        List<User> lstuser = new List<User>();
        Map<Id,CaseTeamMember> mapCTM = new Map<Id, CaseTeamMember>();
        List<CaseTeamMember> lstCaseTeamMember = new List<CaseTeamMember>();
        Set<Id> usrSet = new Set<Id>();
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom').getRecordTypeId();
        Id roleId = new List<Id>(GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName)).get(0);
        //Hawaii : get standard record Type id opportunity
        Id standardRecordTyped = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        ////Hawaii : get presales solution record Type id for case
        Id preSalesCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID, Name FROM CaseTeamRole WHERE Name in ('Sales Rep', 'Qualification Lead','Account Manager')];
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        lstuser = soc_TestUtility.createListUser(recordCount, p.Id);
        //Fetching offshore restricted roles id from public group
        if(roleId !=null){
            //We are creating a user that have offshorerestricted type role.
            lstuser.get(10).UserRoleId = roleId;
        }
        insert lstuser;
        //validate lstuser should not be null and size should be grater than zero.
        if(lstuser!=null && lstuser.size() > 0){
            System.runAs(lstuser.get(0)){
                lstAcc = soc_TestUtility.createListAccount(1, accRecordTypeId);
                if(lstAcc!=null && lstAcc.size()>0){
                    Insert lstAcc;
                    lstOpp = soc_TestUtility.createListOpportunity(1, oppRecordTypeId, lstAcc.get(0).id);
                    //Hawaii : Create standard opportunity
                    lstOppStandard = soc_TestUtility.createListOpportunity(1, standardRecordTyped, lstAcc.get(0).id);
                    combineOpptyList.addAll(lstOpp);
                    combineOpptyList.addAll(lstOppStandard);
                    if(combineOpptyList !=null && combineOpptyList.size() > 0){
                        insert combineOpptyList;
                        lstCase = soc_TestUtility.createListCase(1, caseRecordTypeId, lstAcc.get(0).id, combineOpptyList.get(0).id);
                        //Hawaii : Create presales case
                        lstCaseStandard = soc_TestUtility.createListCase(1, preSalesCaseRecordTypeId, lstAcc.get(0).id, combineOpptyList.get(1).id);
                        combineCaseList.addAll(lstCase);
                        combineCaseList.addAll(lstCaseStandard);
                        insert combineCaseList;
                    }
                }
                //storing userid in a set variable
                for(User user : lstUser){
                    usrSet.add(user.id);
                }
                //fetching caseteammembers that are already added on caseteam when case was created.
                if(usrSet!=null && usrSet.size()>0){
                    for(CaseTeamMember ctm: [SELECT ID,MemberId FROM CaseTeamMember WHERE MemberId=:usrSet]){
                        mapCTM.put(ctm.MemberId, ctm); 
                    }
                }
                /*We are manually adding users in case team member*/
                for(integer i=0;i<lstuser.size();i++){
                    //validate member is already exist or not.
                    if(mapCTM!=null && !mapCTM.containsKey(lstuser.get(i).Id) && combineCaseList!=null && combineCaseList.size()>0 
                    && lstuser!=null && lstuser.size()>0 && lstCaseTeamRole!=null && lstCaseTeamRole.size()>0){
                        lstCaseTeamMember.add(soc_TestUtility.createCaseTeamMember(i, combineCaseList.get(0).Id,  lstuser.get(i).Id, lstCaseTeamRole.get(0).Id));
                        //Hawaii : Create case team member record for presales solution
                        lstCaseTeamMember.add(soc_TestUtility.createCaseTeamMember(i, combineCaseList.get(1).Id,  lstuser.get(i).Id, lstCaseTeamRole.get(0).Id));
                    }
                } 
                //validate lstCaseTeamMember is not null and size is grater than zero.
                if(lstCaseTeamMember!=null && lstCaseTeamMember.size()>0){
                    insert lstCaseTeamMember;
                }
                
                List<OpportunityTeamMember> oppTeamMemberList = new List<OpportunityTeamMember>();
                if(lstCaseTeamRole!=null && lstCaseTeamRole.size()>0 && lstOpp!=null && lstOpp.size()>0 && lstUser!=null && 
                lstUser.size()>0 && lstCaseTeamRole!=null && lstCaseTeamRole.size()>0){
                    List<OpportunityTeamMember> lstOTM = soc_TestUtility.createListOpportunityTeamMember(1, combineOpptyList.get(0).id, 
                    lstUser.get(0).id, lstCaseTeamRole.get(0).Name, 'Edit');
                    oppTeamMemberList.addAll(lstOTM);
                    //Hawaii : Add opportunity team member
                    List<OpportunityTeamMember> lstOTM1 = soc_TestUtility.createListOpportunityTeamMember(1, combineOpptyList.get(1).id, 
                    lstUser.get(0).id, lstCaseTeamRole.get(0).Name, 'Edit');
                    oppTeamMemberList.addAll(lstOTM1);
                    insert oppTeamMemberList ;
                }
            }
        }
    }
    
    /*For call to execute method of batch class without offshore restricted account and user*/
    static testMethod void executeTestWithoutOffShoreRestricted(){
        cusdl_AddOppTeamMemBatch addOppTeamBatch = new cusdl_AddOppTeamMemBatch();
        Test.startTest();
        //execute batch class when account is not offshore.
        DataBase.executeBatch(addOppTeamBatch);
        Test.StopTest();
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        lstOppTeamMember = [SELECT ID FROM OpportunityTeamMember];
        if(lstOppTeamMember!=null){
			System.assert(lstOppTeamMember.size()==22);
        }
    }
    /*For call to execute method of batch class with offshore restricted account and user*/
    static testMethod void executeTestWithOffShoreRestricted(){
        CaseTeamMember ctm = new CaseTeamMember();
        List<Case> lstCase = new List<Case>();
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID FROM CaseTeamRole WHERE Name in ('Sales Rep', 'Qualification Lead','Account Manager')];
        List<Account> lstAcc = [SELECT ID, APTPS_Off_Shore_Restricted__c FROM Account limit 1];
        List<User> lstOffshoreUser = [SELECT ID FROM User where UserRoleId !=null  AND isActive = true limit 1];// Hawaii - fixes of INACTIVE_OWNER_OR_USER
     
        if(lstAcc !=null && lstAcc.size()>0){
            lstAcc.get(0).APTPS_Off_Shore_Restricted__c = true;
            Update lstAcc;
            lstCase = [SELECT ID,OpportunityId__c FROM Case WHERE AccountId=:lstAcc.get(0).id limit 1];
            if(lstOffshoreUser!=null && lstOffshoreUser.size()>0 && lstCase!=null && lstCase.size()>0){
           
            ctm.MemberId = lstOffshoreUser.get(0).id;
            ctm.ParentId = lstCase.get(0).id;
            if(lstCaseTeamRole!=null && lstCaseTeamRole.size()>0)
            {    
                ctm.TeamRoleId = lstCaseTeamRole.get(0).id;
            }
            insert ctm;
        }
        }
        cusdl_AddOppTeamMemBatch addOppTeamBatch = new cusdl_AddOppTeamMemBatch();
        Test.startTest();
        DataBase.executeBatch(addOppTeamBatch);
        Test.StopTest();
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        lstOppTeamMember = [SELECT ID, opportunityid FROM OpportunityTeamMember WHERE OpportunityId=:lstCase.get(0).OpportunityId__c];
        Map<Id,CaseTeamMember> mapCaseTeamMember= new Map<Id,CaseTeamMember>([SELECT ID,parentid FROM CaseTeamMember where ParentId=:lstCase.get(0).id]);
        //validate opportunity team member has 10 members
        if(lstOppTeamMember!=null)
            System.assert(lstOppTeamMember.size()==11);
        //validate caseteammember and opportunity member has same count of members
        if(mapCaseTeamMember!=null)
            System.assert(mapCaseTeamMember.size()==lstOppTeamMember.size());
    }
    
    /*For Error part*/
    static testMethod void executeBatchForException(){
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID, AccessLevel FROM CaseTeamRole WHERE Name in ('SOC Case View Access')];
        Account acc = new Account();
        Case cs = [SELECT ID,OpportunityId__c FROM Case limit 1];
        CaseTeamMember ctm = new CaseTeamMember();
        ctm.MemberId = userInfo.getUserId();
        ctm.ParentId = null;
        Test.startTest();
        try{
            if(lstCaseTeamRole !=null && lstCaseTeamRole.size()>0){
                lstCaseTeamRole.get(0).AccessLevel = 'Update';
                update lstCaseTeamRole;
            }
            if(lstCaseTeamRole!=null && lstCaseTeamRole.size()>0)
            {    
                ctm.TeamRoleId = lstCaseTeamRole.get(0).id;
            }
            insert ctm;
            cusdl_AddOppTeamMemBatch addOppTeamBatch = new cusdl_AddOppTeamMemBatch();
            DataBase.executeBatch(addOppTeamBatch);
        }
        catch(Exception ex){
            System.assert(ex.getMessage()!=null);
        }
        Test.StopTest();
    }
    
    /*For This Method will schedule the batch job cover the else part of start method that will fetch the caseteammember from last batch run*/
    static testMethod void executeBatchSchedule(){
        cusdl_AddOppTeamMemBatchSchedule sch = new cusdl_AddOppTeamMemBatchSchedule();
        Test.startTest();
        String CRON_EXP = '0 0 0,3,8,12,16,20 * * ?';
        String jobId =  System.schedule('cusdl_AddOppTeamMemBatch', CRON_EXP, sch);
        cusdl_AddOppTeamMemBatch addOppTeamBatch = new cusdl_AddOppTeamMemBatch();
        DataBase.executeBatch(addOppTeamBatch);
        System.assert(jobId !=null);
        Test.stopTest();
    }
    
    //Hawaii : Test method to test pre sales solution opportunity team member insert logic
    /*For call to execute method of batch class with offshore restricted account and user*/
    static testMethod void executeTestWithOffShoreRestrictedForPresalesSolution(){
        CaseTeamMember ctm = new CaseTeamMember();
        List<Case> lstCase = new List<Case>();
        List<CaseTeamRole> lstCaseTeamRole = [SELECT ID FROM CaseTeamRole WHERE Name in ('Sales Rep', 'Qualification Lead','Account Manager')];
        List<Account> lstAcc = [SELECT ID, APTPS_Off_Shore_Restricted__c FROM Account limit 1];
        List<User> lstOffshoreUser = [SELECT ID FROM User where UserRoleId !=null limit 1];
     
        if(lstAcc !=null && lstAcc.size()>0){
            lstAcc.get(0).APTPS_Off_Shore_Restricted__c = true;
            Update lstAcc;
            lstCase = [SELECT ID,OpportunityId__c,OpportunityId__r.RecordType.DeveloperName FROM Case WHERE AccountId=:lstAcc.get(0).id AND RecordType.DeveloperName ='Presales_Solution' limit 1];
            if(lstOffshoreUser!=null && lstOffshoreUser.size()>0 && lstCase!=null && lstCase.size()>0){
           
            ctm.MemberId = lstOffshoreUser.get(0).id;
            ctm.ParentId = lstCase.get(0).id;
            if(lstCaseTeamRole!= null && lstCaseTeamRole.size()>0)
            {    
                ctm.TeamRoleId = lstCaseTeamRole.get(0).id;
            }
            insert ctm;
        }
        }
        cusdl_AddOppTeamMemBatch addOppTeamBatch = new cusdl_AddOppTeamMemBatch();
        Test.startTest();
        DataBase.executeBatch(addOppTeamBatch);
        Test.StopTest();
        List<OpportunityTeamMember> lstOppTeamMember = new List<OpportunityTeamMember>();
        lstOppTeamMember = [SELECT ID, opportunityid FROM OpportunityTeamMember WHERE OpportunityId=:lstCase.get(0).OpportunityId__c];
        Map<Id,CaseTeamMember> mapCaseTeamMember= new Map<Id,CaseTeamMember>([SELECT ID,parentid FROM CaseTeamMember where ParentId=:lstCase.get(0).id]);
        //validate opportunity team member has 10 members
        if(lstOppTeamMember!=null)
            System.assert(lstOppTeamMember.size()==11);
        //validate caseteammember and opportunity member has same count of members
        if(mapCaseTeamMember!=null)
            System.assert(mapCaseTeamMember.size()==lstOppTeamMember.size());
    }
}
/**
* Author: Sandeep Soni
* Team: Jaipur
* Sprint: 20.07
* JIRA Story: P2OB-6376
* Date: 22 April 2020
* Class Name: cusdl_WorkOrderTriggerHandlerTest
* Description: This Test class will test all test scenario of batch class.
DIGI-37522 : Vivian Charlie : 15 Nov 2021 : Adding test method to verify OpenAir notifications for Purple presales WO
**/

@isTest(SeeAllData=false)
public class cusdl_WorkOrderTriggerHandlerTest {
    public static integer recordCount = 10;
    /*
* For Creating test data
*/
    @testSetup
    static void createTestData(){
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
        Id SFDcaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('SFD_Request').getRecordTypeId();
        Id cusdlRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
        Id SFDWORecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('SFD_Work_Order_Request').getRecordTypeId();
        Set<Id> roleids = new set<id>();
        String roleId = null;
        List<User> lstuser = new List<User>();
        Opportunity opp=new Opportunity();
        Account acc = new Account();
        Case caseObj = null;
        Case caseObj1 = null;
        List<WorkOrder> lstWorkOrder = new List<WorkOrder>();

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' limit 1];
        roleids=GroupMembership.getRoleIdsFromGroup(System.Label.GroupMembershipOffshoreGroupName);
        List<Id> lstRoles = new List<Id>(roleids);
        if(lstRoles !=null && lstRoles.size()>0){
            roleId = lstRoles.get(0);
        }
        UserRole usrRole = [SELECT ID FROM UserRole where name='Customer Success & Delivery' limit 1];
        id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        for(integer i=0; i<recordCount;i++){
            User usr1 = new User(Email='telsta1'+i+'@test.com',
                                 EmailEncodingKey='UTF-8', LastName='Test'+i, LanguageLocaleKey='en_US',
                                 LocaleSidKey='en_AU', ProfileId = p.Id,
                                 TimeZoneSidKey='Australia/Sydney',FederationIdentifier='D863471',username='telsta1'+i+'@test.com.Test',alias = 'Use1T1');

            lstuser.add(usr1);

        }
        lstuser.get(0).UserRoleId = roleId;
        lstuser.get(0).lastName = 'OffShoreRestrictedUser';
        lstUser.get(3).UserRoleId = usrRole.id;
        lstUser.get(3).LastName = 'OnShoreRoleUser';
        insert lstuser;
        System.runAs(lstuser.get(0)){
            acc.name = 'TestClassEvent';
            acc.CIDN__c = 'ASDF1234';
            acc.Customer_Status__c = 'ACTIVE';
            acc.RecordTypeId = accRecordTypeId;
            acc.APTPS_Off_Shore_Restricted__c = false;
            Insert acc;

            id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom').getRecordTypeId();
            opp.AccountId=acc.Id;
            opp.recordTypeId=oppRecordTypeId;
            opp.Name='TestOppCreateForEventCreate';
            opp.Proposal_Required_Date__c=System.today()+2;
            opp.CloseDate=System.today()+10;
            opp.StageName=System.Label.Opp_Stage_Develop;
            opp.Description__c='Test';
            opp.Product_Domain__c='MOBILES';
            opp.Shared_Opportunity__c=True;
            insert opp;
            caseObj= new Case(Subject='Custom Deal Test', RecordTypeId=caseRecordTypeId,
                              AccountId=acc.id,
                              Description='Test',
                              cusdl_Techscore__c =8,
                              OpportunityId__c=opp.id,
                              cusdl_Opty_been_Identified_Qualifieds__c='test option',
                              cusdl_The_Compelling_Events__c='test',
                              cusdl_Customer_s_current_environment__c='test option',
                              cusdl_Technical_or_service_issues__c='test',
                              cusdl_Key_Deliverables_and_Milestones__c='test',
                              cusdl_Billing_Requirements__c='test option',
                              cusdl_Third_Party_Engagement__c='test',
                              cusdl_Carriage_and_standard_product__c=100,
                              cusdl_Third_parties__c=100,
                              cusdl_Once_off_costs__c=30,
                              cusdl_Telstra_services__c=50,
                              cusdl_Pricing_Type__c='firm',
                              cusdl_Benchmarking_Requirements__c='Yes',
                              cusdl_Detail__c='test',
                              cusdl_non_standard_contract_pricing_oct__c='OCT Pricing'
                             );
            insert caseObj;
            for(integer i=0;i<recordcount;i++){
                WorkOrder wo = new WorkOrder();
                wo.AccountId = acc.id;
                wo.CaseId = caseObj.id;
                wo.RecordTypeId = cusdlRecordTypeId;
                wo.Status = 'New';
                wo.Subject = 'Test WO'+i;
                wo.Domain__c = 'Mobiles';
                wo.cusdl_isAutoCreatedWO__c = false;
                wo.cusdl_opportunityId__c = opp.id;
                wo.cusdl_work_order_type__c = 'Commercial';
                wo.OwnerId = lstuser.get(i).id;
                lstWorkOrder.add(wo);

            }

            caseObj1= new Case(Subject='SFD CASE Test', RecordTypeId=SFDcaseRecordTypeId,
                              AccountId=acc.id,
                              Description='Test',
                              OpportunityId__c=opp.id
                             );
            insert caseObj1;
            for(integer i=0;i<recordcount;i++){
                WorkOrder wo1 = new WorkOrder();
                wo1.AccountId = acc.id;
                wo1.CaseId = caseObj.id;
                wo1.RecordTypeId = SFDWORecordTypeId;
                wo1.Status = 'New';
                wo1.Subject = 'Test WO'+i;
                wo1.Domain__c = 'Mobiles';
                wo1.OwnerId = lstuser.get(i).id;
                wo1.cusdl_work_order_type__c = 'Commercial';
                lstWorkOrder.add(wo1);

            }

            lstWorkOrder.get(3).subject = 'OnShoreRoleWO';
            insert lstWorkOrder;
        }


    }
    /* If workorder change. */
    static testMethod void validateWorkOrderOwnerCheckNegativeTest(){
        Id woId = null;
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();

        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Account acc = [SELECT ID,APTPS_Off_Shore_Restricted__c FROM Account WHERE Name='TestClassEvent' and APTPS_Off_Shore_Restricted__c =false];
        acc.APTPS_Off_Shore_Restricted__c = true;
        Update acc;
        Map<Id, WorkOrder> oldMapWORecord = new Map<Id, WorkOrder>([SELECT ID, ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER]);
        for(WorkOrder wo : oldMapWORecord.values()){
            woId = wo.id;
            wo.OwnerId = lstUser.get(0).id;
            mapnewWORecord.put(wo.id, wo);
        }
        Test.startTest();
        try{
            update mapnewWORecord.values();
        }
        catch(Exception ex){

            System.assert(ex.getMessage().contains(System.Label.cusdl_OffshoreRestrictedRoleErrorMessage));
        }
        Test.StopTest();
    }
    /* If workorder change. */
    /*
    static testMethod void validateWorkOrderOwnerAccountNullCheck(){
        Id woId = null;
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();
        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Map<Id, WorkOrder> oldMapWORecord = new Map<Id, WorkOrder>([SELECT ID, ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER]);
        for(WorkOrder wo : oldMapWORecord.values()){
            woId = wo.id;
            wo.OwnerId = lstUser.get(0).id;
            wo.AccountId = null;
            mapnewWORecord.put(wo.id, wo);
        }
        Test.startTest();
        update mapnewWORecord.values();
        System.assert(mapnewWORecord.get(woId).OwnerId == lstUser.get(0).id);
        Test.StopTest();
    }
    */
    /* If workorder change. */
    static testMethod void validateWorkOrderOwnerCheckPositiveTest(){
        Id woId = null;
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();
        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Map<Id, WorkOrder> oldMapWORecord = new Map<Id, WorkOrder>([SELECT ID, ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER limit 1]);
        for(WorkOrder wo : oldMapWORecord.values()){
            woId = wo.id;
            wo.OwnerId = lstUser.get(0).id;
            mapnewWORecord.put(wo.id, wo);
        }
        Test.startTest();
        update mapnewWORecord.values();
        System.assert(mapnewWORecord.get(woId).ownerid == lstUser.get(0).id);
        Test.StopTest();
    }
    //validate workorder owner is already assigned to resolve group or not. Negative test scenario
    static testMethod void isWOOwnerAlreadyAssigToResolveGroupTest(){
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();
        Id cusdlRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Map<Id, WorkOrder> mapWORecord = new Map<Id, WorkOrder>([SELECT ID, caseid,accountid,ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER]);
        Id oldWOID;
        for(WorkOrder wo : mapWORecord.values()){
            wo.status='Closed';
            oldWOID = wo.id;
        }
        WorkOrder wo = new WorkOrder();
        wo.AccountId = mapWORecord.get(oldWOID).Accountid;
        wo.CaseId = mapWORecord.get(oldWOID).Caseid;
        wo.RecordTypeId = cusdlRecordTypeId;
        wo.Status = 'New';
        wo.Subject = 'Test WO';
        wo.Domain__c = 'Mobiles';
        wo.cusdl_isAutoCreatedWO__c = false;
        wo.cusdl_opportunityId__c = mapWORecord.get(oldWOID).cusdl_opportunityId__c;
        wo.cusdl_work_order_type__c = 'Commercial';
        wo.OwnerId = lstuser.get(0).id;
        Test.startTest();
        try{
            //new work order not created successfully
            insert wo;
        }catch(Exception ex){

           System.assert(ex.getMessage()!=null);
        }
        Test.stopTest();
    }
    //validate workorder owner is already assigned to resolve group or not. Positive1 test scenario
    static testMethod void isWOOwnerResolveGroupPositive1Test(){
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();
        Id cusdlRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Map<Id, WorkOrder> mapWORecord = new Map<Id, WorkOrder>([SELECT ID, caseid,accountid,ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER]);
        Id oldWOID;
        for(WorkOrder wo : mapWORecord.values()){
            wo.status='Closed';
            oldWOID = wo.id;
        }
        WorkOrder wo = new WorkOrder();
        wo.AccountId = mapWORecord.get(oldWOID).Accountid;
        wo.CaseId = mapWORecord.get(oldWOID).Caseid;
        wo.RecordTypeId = cusdlRecordTypeId;
        wo.Status = 'New';
        wo.Subject = 'Test WO';
        wo.Domain__c = 'Mobiles';
        wo.cusdl_isAutoCreatedWO__c = false;
        wo.cusdl_opportunityId__c = mapWORecord.get(oldWOID).cusdl_opportunityId__c;
        wo.cusdl_work_order_type__c = 'Commercial';
        wo.OwnerId = lstuser.get(0).id;
        Test.startTest();
        try{
            update mapWORecord.values();
            insert wo;
            //new work order created successfully
            System.assert(wo.id!=null);
        }catch(Exception ex){
           System.assert(ex.getMessage()!=null);
        }
        Test.stopTest();
        System.assert(wo.id!=null);
    }
    //validate workorder owner is already assigned to resolve group or not. Positive test scenario
    static testMethod void isWOOwnerAlreadyAssigToResolveGroupPositive2Test(){
        Map<Id, WorkOrder> mapnewWORecord = new Map<Id,WorkOrder>();
        Id cusdlRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('cusdl_custom_deal_work_order').getRecordTypeId();
        List<User> lstUser = [SELECT ID, UserRoleId FROM User Where lastname='OffShoreRestrictedUser'];
        Map<Id, WorkOrder> mapWORecord = new Map<Id, WorkOrder>([SELECT ID,caseid,accountid, ownerId,cusdl_opportunityId__c, Account.APTPS_Off_Shore_Restricted__c FROM WORKORDER]);
        Id oldWOID;
        for(WorkOrder wo : mapWORecord.values()){
            wo.status='Closed';
            oldWOID = wo.id;
        }
        WorkOrder wo = new WorkOrder();
        wo.AccountId = mapWORecord.get(oldWOID).Accountid;
        wo.CaseId = mapWORecord.get(oldWOID).Caseid;
        wo.RecordTypeId = cusdlRecordTypeId;
        wo.Status = 'New';
        wo.Subject = 'Test WO';
        wo.Domain__c = 'Mobiles';
        wo.cusdl_isAutoCreatedWO__c = false;
        wo.cusdl_opportunityId__c = mapWORecord.get(oldWOID).cusdl_opportunityId__c;
        wo.cusdl_work_order_type__c = 'Legal';
        wo.OwnerId = lstuser.get(0).id;
        Test.startTest();
        try{
            insert wo;
            //new work order created successfully
            System.assert(wo.id!=null);
        }catch(Exception ex){

           System.assert(ex.getMessage()!=null);
        }
        Test.stopTest();
        System.assert(wo.id!=null);
    }
    
    /*Adding test method to verify OpenAir notifications for Purple presales WO*/
    static testMethod void testOpenAirNotification(){
        Id presalesrectypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
        Id accountId = [Select Id from Account limit 1].Id;
        Id opportunityId = [Select Id from Opportunity limit 1].Id;
        Test.startTest();
        list<Case> lC = PRMTestUtility.createCases(1,presalesrectypeId);
        lC[0].OpportunityId__c = opportunityId;
        lC[0].AccountId = accountId;
        lC[0].Stage__c = 'Queued';
        lC[0].Technology_Specialisation__c = 'Digital';
        insert lC;
        
        Id woRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosByDeveloperName().get('Presales_Solution_Work_Order').getRecordTypeId();
        WorkOrder wo = new WorkOrder();
        wo.CaseId = lC[0].Id;
        wo.RecordtypeId = woRecordTypeId;
        wo.Status = 'New';
        wo.Subject = 'New WO';
        wo.AccountId = accountId;
        wo.cusdl_work_order_type__c = 'Qualification';
        insert wo;
        Test.stopTest();
        wo.OwnerId = UserInfo.getUserId();
        update wo;
    }
}
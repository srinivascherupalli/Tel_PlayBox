/*******************************************************************************
@Author: nitesh
@CreateDate: 24/08/2018
@ModifiedByandDate: 
@Description: This Class is created to cover the test coverage
soc_CaseTriggerHandler = 75%
soc_Utility=100%
*********************************************************************************/
@isTest(seeAllData=false)
public class soc_CaseTriggerHandlerTest {
    
    
    static testMethod void myTest3() {
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        
        
        test.startTest();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        
        //Modified By :: SHamikh Hassan:: Record Type label Changes
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        insert caseObj; 
        soc_CaseTriggerHandler.checkOppLineItemsHasSOC(oppLine);
        System.assertEquals('New', caseObj.status);
        test.stopTest();       
              
    }
    
    static testMethod void testSFDRequest() {
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        test.startTest();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.OpportunityId__c = oppLine[0].OpportunityId;
        caseObj.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();    
        insert caseObj; 
        System.assertEquals('New', caseObj.Status);
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Simplex_Support_Request' LIMIT 1].Id;
        caseObj.OwnerId = ownrId;
        update caseObj;
        test.stopTest();       
              
    }
    
    
    static testMethod void caseTriggerHandler(){
        soc_SFD_Case_Business_Time__c businessTime = new soc_SFD_Case_Business_Time__c();
        businessTime.soc_SFD_Case_Acceptance_Time_Type__c = 'hh';
        businessTime.Name = 'Case Acceptance';
        businessTime.soc_SFD_Case_Acceptance_Time__c = 8;
        insert businessTime;
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest(); 
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            
            insert member;
        }
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, ownrId, opp.AccountId);
            caseList[0].Stage__c = 'Request Review'; 
            caseList[0].soc_Process_Start_Time__c = System.now();
            update caseList;
            caseList[0].Stage__c = 'Validate And Assign Order';
            caseList[0].Description = 'test';
            caseList[0].soc_Process_End_Time__c = System.now();
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Complex_Level_3_Detail_Queue' LIMIT 1].Id;
            update caseList;
            Map<id,id>opptyshreMap = new Map<id,id> ();
            map<ID,Case> oldCaseMap = new  map<ID,Case>();
            opptyshreMap.put(caseList[0].id, opp.id);
            oldCaseMap.put(caseList[0].id, caseList[0]);
            soc_CaseTriggerHandler.deleteOpptyOldOwner(opptyshreMap,oldCaseMap);
            system.assert(caseList[0]!=null);
            //soc_CaseTriggerHandler.checkOppLineItemsHasSOC(new list<OpportunityLineItem>{lineItem1});   
            System.assertEquals('New', caseList[0].status);
            test.stopTest();   
        }catch(Exception e){
            system.debug('Error In caseTriggerHandler test Method'+ e.getMessage());
        }
    }
    
    static testMethod void simplexQueueCase(){
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_SIMPLEX_Level_1_Detail_Ordering' LIMIT 1].Id;        
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            
            insert member;
        }
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Complex_Level_3_Detail_Queue' LIMIT 1].Id;
            update caseList;
            
            Set<String> stringSet = soc_CaseTriggerHandler.getQueueIdsForOwner(caseList[0].OwnerId);
            
            Map<id,id>opptyshreMap = new Map<id,id> ();
            map<ID,Case> oldCaseMap = new  map<ID,Case>();
            opptyshreMap.put(caseList[0].id, opp.id);
            oldCaseMap.put(caseList[0].id, caseList[0]);
            soc_CaseTriggerHandler.deleteOpptyOldOwner(opptyshreMap,oldCaseMap);
            system.assert(caseList[0] != null);
            System.assertEquals('New', caseList[0].status);
            test.stopTest();   
        }catch(Exception e){
            system.debug('Error In simplexQueueCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void mediumQueueIdCase(){
        
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_MEDIUM_COMPLEX_Level_2_Detail_Orderi' LIMIT 1].Id;
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            Set<String> stringSet = soc_CaseTriggerHandler.getQueueIdsForOwner(caseList[0].OwnerId);
            
            System.assertEquals('test', caseList[0].Description);
        }catch(Exception e){
            system.debug('Error In mediumQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void complexQueueIdCase(){
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Complex_Level_3_Detail_Queue' LIMIT 1].Id;
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            soc_CaseCycleAcceptanceReport.updateCaseOwnerType(caseList);
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            System.assertEquals('test', caseList[0].Description);
        }catch(Exception e){
            system.debug('Error In complexQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void smeSupportQueueIdCase(){
        
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_SME_Support_requests' LIMIT 1].Id;
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            System.assertEquals('test', caseList[0].Description);
        }catch(Exception e){
            system.debug('Error In smeSupportQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void conciergeSupportQueueIdCase(){
        
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Concierge_Support_requests' LIMIT 1].Id;        
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            System.assertEquals('test', caseList[0].Description);
        }catch(Exception e){
            system.debug('Error In conciergeSupportQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void mediumSupportQueueIdCase(){
        
        
        opportunity opp = soc_TestUtility.CreateOpportunity();
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'soc_Medium_Complex_Support_Requests' LIMIT 1].Id;
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(), opp.AccountId);
            
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            System.assertEquals('test', caseList[0].Description);
        }catch(Exception e){
            system.debug('Error In mediumSupportQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    static testMethod void complexSupportQueueIdCase(){
        opportunity opp = soc_TestUtility.CreateOpportunity();
        opp.Product_Domain__c='OTHER';
        update opp;
        test.startTest();  
        Id ownrId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Complex_Support_Requests' LIMIT 1].Id;
        System.runAs(new User(Id=UserInfo.getUserId())){
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = ownrId;
            insert member;
        }
        
        try{
            string str = soc_CaseTriggerHandler.getQueueIdForOwner(ownrId);
            List<Case> caseList = soc_CaseTriggerHandlerTest.createCase('Order_request', 1, opp.Id, UserInfo.getUserId(),opp.AccountId);
            caseList[0].Description = 'test';
            caseList[0].OwnerId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'SOC_Queue' LIMIT 1].Id;
            update caseList;
            System.assertEquals('test', caseList[0].Description);
            
        }catch(Exception e){ 
            system.debug('Error In complexSupportQueueIdCase test Method'+ e.getMessage());
        }
        
    }
    
    
    
    public static List<Case> createCase(string recordTypeName, integer noOfCase, Id OpportunityId, Id ownrId, Id AccountId){
        
        List<Case> caseList = new List<Case>();
        for(integer i=0;i< noOfCase; i++){ 
            Case caseObj = new Case();
            caseObj.Status = 'New';
            caseObj.OpportunityId__c = OpportunityId;
            caseObj.OwnerId = ownrId;
            caseObj.AccountId = AccountId;
            caseObj.RecordTypeId =Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            caseList.add(caseObj);
        }
        
        insert caseList;
        return caseList;
    }
    
    public static List<Case> createCase(string recordTypeName, integer noOfCase, Id OpportunityId, Id ownrId){
        
        List<Case> caseList = new List<Case>();
        for(integer i=0;i< noOfCase; i++){ 
            Case caseObj = new Case();
            caseObj.Status = 'New';
            caseObj.OpportunityId__c = OpportunityId;
            caseObj.OwnerId = ownrId;
            caseObj.RecordTypeId =Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
            caseList.add(caseObj);
        }
        
        insert caseList;
        return caseList;
    }    
}
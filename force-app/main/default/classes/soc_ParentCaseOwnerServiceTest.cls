/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 15 Jan 2018
@ModifiedByandDate: 
@Description: Test class for soc_ParentCaseOwnerService. 
@References
Epic :EDGE- 57480: Parent Case Ownership 
Story:EDGE-40183
*******************************************************************************/
@isTest
public class soc_ParentCaseOwnerServiceTest {
    
    @TestSetup
    static void createTestData(){
        Map<Id,Group> mapDetailerSpecialistCTSQueues = new Map<Id,Group>([select Id from Group where Type = 'Queue' AND (DeveloperNAME != 'soc_SFD_Concierge_Offshore' 
                                                                                                                      AND DeveloperNAME != 'SOC_Queue' 
                                                                                                                      AND DeveloperNAME != 'soc_Concierge_Support_requests'  
                                                                                                                      AND DeveloperNAME != 'soc_Concierge_Offshore_Support_request')]);
        List<GroupMember> grpMembersDetailerSpecCTS = [Select GroupId,UserOrGroupId From GroupMember Where GroupId IN :mapDetailerSpecialistCTSQueues.KeySet()];
        List<OpportunityLineItem> oppLine = soc_TestUtility.createOpportunityLineItem();
        String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
        Case parCase1 = new Case();
        parCase1.Status = 'New';
        parCase1.stage__c = 'Request Review';
        parCase1.OpportunityId__c = oppLine[0].OpportunityId;//Modified by Kritika Bhati on 10April 2019
        parCase1.Child_Case_Count__c = 0;
        parCase1.soc_isParentOwner__c = true;
        parCase1.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        Case parCase2 = new Case();
        parCase2.Status = 'New';
        parCase2.stage__c = 'Request Review';
        parCase2.OpportunityId__c = oppLine[0].OpportunityId;//Modified by Kritika Bhati on 10April 2019
        parCase2.Child_Case_Count__c = 0;
        parCase2.soc_isParentOwner__c = true;
        parCase2.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        Case parCase3 = new Case();
        parCase3.Status = 'New';
        parCase3.stage__c = 'Request Review';
        parCase3.OpportunityId__c = oppLine[0].OpportunityId;//Modified by Kritika Bhati on 10April 2019
        parCase3.Child_Case_Count__c = 0;
        parCase3.soc_isParentOwner__c = true;
        parCase3.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();    
        List<Case> lstCase = new List<CAse>();
        lstCase.add(parCase1);
        lstCase.add(parCase2);
        lstCase.add(parCase3);
        insert lstCase;
        Case childCase1 = new Case();
        childCase1.RecordTypeId = recId_SFD_ProductType;
        childCase1.ownerId = grpMembersDetailerSpecCTS.get(0).UserOrGroupId;
        childCase1.ParentId = lstCase.get(0).id;
        childCase1.soc_isParentOwner__c = true;
        
        Case childCase2 = new Case();
        childCase2.RecordTypeId = recId_SFD_ProductType;
        childCase2.ownerId = grpMembersDetailerSpecCTS.get(0).UserOrGroupId;
        childCase2.ParentId = lstCase.get(0).id;
        childCase2.soc_isParentOwner__c = true;
        
        
        Case childCase3 = new Case();
        childCase3.RecordTypeId = recId_SFD_ProductType;
        childCase3.ownerId = grpMembersDetailerSpecCTS.get(0).UserOrGroupId;
        childCase3.ParentId = lstCase.get(0).id;
        childCase3.soc_isParentOwner__c = true;
        List<CAse> lstCasere = new List<Case>();
        lstCasere.add(childCase1);
        lstCasere.add(childCase2);
        lstCasere.add(childCase3);
        insert lstCasere;          
    }
    public static testMethod void updateParentOwnerAndCountTest(){
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT ID,OwnerId,RecordTypeId,Child_Case_Count__c FROM Case]);
        Map<Id, Case> childCaseMap = new Map<Id,Case>();
        String recId_SFD_ProductType=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
   
        List<Id> lstIds = new List<Id>();
        for(Case cs : caseMap.values()){ 
            cs.soc_isParentOwner__c = true;
            if(cs.RecordTypeId==recId_SFD_ProductType){
                cs.Child_Case_Count__c = 1; 
                childCaseMap.put(cs.id, cs);
            }
            lstIds.add(cs.id);
        }
        Test.startTest();
        system.assert(childCaseMap!=null);
        update childCaseMap.values(); 
        soc_ParentCaseOwnerService.updateParentCaseOwner(childCaseMap);
        soc_ParentCaseOwnerService.updateParentOwnerAndCount(childCaseMap);
        Test.stopTest();
    }
    
    public static testMethod void handleRequestTest1(){
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT ID,OwnerId FROM Case]);
        List<Id> lstIds = new List<Id>();
        for(Case cs : caseMap.values()){
            cs.soc_isParentOwner__c = true; 
            lstIds.add(cs.id);
        }
        Test.startTest();
        system.assert(caseMap !=null);
        soc_ParentCaseOwnerService.handleRequest(lstIds);
        Test.stopTest();
    }
	
    public static testMethod void updateParentCaseOwnerDirTest(){
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT ID,OwnerId FROM Case]);
        List<Id> lstIds = new List<Id>();
        for(Case cs : caseMap.values()){
            cs.soc_isParentOwner__c = true; 
            lstIds.add(cs.id);
        }
        Test.startTest();
        system.assert(caseMap !=null);
        soc_ParentCaseOwnerService.updateParentCaseOwnerDir(caseMap);
        soc_ParentCaseOwnerService.updateParentOwnerAndCount(caseMap);
        Test.stopTest();
    }
    
    public static testMethod void changeParentOwnerOnChildCloseTest(){
        Map<Id, Case> caseMap = new Map<Id, Case>([SELECT ID,OwnerId FROM Case]);
        List<Id> lstIds = new List<Id>();
        for(Case cs : caseMap.values()){
            cs.soc_isParentOwner__c = true; 
            lstIds.add(cs.id);
        }
        Test.startTest();
        system.assert(caseMap !=null);
        soc_ParentCaseOwnerService.changeParentOwnerOnChildClose(lstIds);
        Test.stopTest();
    }
    
    
}
/*****************************************************************************
@Author: Pravin Sonawane
@CreateDate: 22/01/2019
@ModifiedByandDate: 09/04/2019
@Description: This class is test class for soc_ManageProductController class
*******************************************************************************/
@isTest
public class soc_ManageProductController_Test {
    
    public static String OrderRequestRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId(); 
    public static String ProductRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    
    /**
    * This method created the test records which is used by multiple test methods.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    @testSetup static void createTestRecords() {
        
        
        
        List<OpportunityLineItem> lstoppLineItems = soc_TestUtility.createOpportunityLineItem();
        system.assertNotEquals(null, lstoppLineItems.size() > 0);
        system.debug('LineItemsSize=='+lstoppLineItems.size());
        
        
        
        List<Case> lstParentCases = new List<Case>();
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.stage__c = 'Request Review';
        
        caseObj.OpportunityId__c = lstoppLineItems[0].OpportunityId;
        caseObj.RecordTypeId = OrderRequestRecordTypeId;
        insert caseObj;        
        system.assertNotEquals(null, caseObj.Id);        
        Test.startTest();
        caseObj.Stage__c='Validate And Assign Order';
        update caseObj;
        
        system.assertEquals('Validate And Assign Order', caseObj.Stage__c);
        
        Test.stopTest();

    }
    
    /**
    * This method covers the getcaseLineItems and fetchCloneCase method.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    static testMethod void test_childClonecaseCreation() {     
        Test.startTest();
        
        List<Case> lstParentCases = [Select Id, ParentId From Case Where RecordTypeId = :OrderRequestRecordTypeId];
        System.assertEquals(1, lstParentCases.size());
        
        
        List<Case> lstChildCases = [Select Id,ParentId,(select id,Name,soc_order_number__c,soc_ProductId__c,
                                                soc_CaseId__c,soc_ProductId__r.Name,soc_CaseId__r.caseNumber
                                                from Case_Line_Items__r) From Case Where RecordTypeId = :ProductRecordTypeId AND  ParentId = :lstParentCases[0].Id];
        
        system.debug('lstChildCases='+lstChildCases);
        system.debug('lstChildCases='+lstChildCases.size());
        system.assertNotEquals(null, lstChildCases.size() > 0);        
        
        List<soc_Case_Line_Item__c> lstLineItems = soc_ManageProductController.getCaseLineItems(lstChildCases[0].Id);
        system.AssertNotEquals(null,lstLineItems.size() > 0);
         system.debug('lstLineItems='+lstLineItems.size());
        
        Map<String,Object> mapCloneCase  = soc_ManageProductController.fetchClonedCase(lstChildCases[0].Id);
        Case cloneCase = (Case)mapCloneCase.get('case');     
        system.assertNotEquals(null, cloneCase.Subject);
        
        test.stopTest();          
    }
    
    /**
    * This method covers the cloneCase method of else condition.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    static testMethod void test_childClonecaseTest() {
        List<Case> lstParentCases = [Select Id, ParentId From Case Where RecordTypeId = :OrderRequestRecordTypeId];
        System.assertEquals(1, lstParentCases.size());
       
              
        List<Case> lstChildCases = [SELECT Id,caseNumber,opportunityId__c,Subject,Status,
                           RecordTypeId,Stage__c,Primary_Domain__c,OwnerId,CIDN__c,soc_Domain__c,
                           srvsup_Parent_CIDN__c,srvsup_Ultimate_CIDN__c,Requestor__c,
                           AccountId,ContactId,Description,RecordType.Name,ParentId,
                           soc_Billing_Account_Number__c,MDN_Network_FNN__c,Network_FNN__c,
                           soc_FNNs__c,soc_Number_of_Sites__c,soc_SFD_Offshore_Restricted__c,Child_Case_Count__c,
                           soc_Product__c,soc_Additional_Technical_Contact__c,soc_Additional_Technical_Contact_Email__c,
                           soc_Additional_Technical_Contact_Phone__c,(select id,Name,soc_order_number__c,soc_ProductId__c,
                                                soc_CaseId__c,soc_ProductId__r.Name,soc_CaseId__r.caseNumber
                                                from Case_Line_Items__r) From Case Where RecordTypeId = :ProductRecordTypeId AND ParentId =:lstParentCases[0].Id];
        system.debug('lstChildCases='+lstChildCases);
        system.assertNotEquals(null, lstChildCases.size() > 0);
        
        Map<String,Object> mapCloneCase  = soc_ManageProductController.fetchClonedCase(lstChildCases[0].Id);
        Case newClonedCase = (Case)mapCloneCase.get('case');     
        system.assertNotEquals(null, newClonedCase.Subject);
        
        List<soc_Case_Line_Item__c> lstLineItems = soc_ManageProductController.getCaseLineItems(lstChildCases[0].Id);
        system.AssertNotEquals(null,lstLineItems.size() > 0);
        system.debug('lstLineItems='+lstLineItems.size());
        system.debug('lstLineItems='+lstLineItems);
        
        Test.startTest();
        
        Case newCreatedClonedCase = soc_ManageProductController.cloneCase(newClonedCase, lstLineItems,false,lstLineItems[0].soc_CaseId__c);
        system.assert(newCreatedClonedCase!=null); 
        system.debug('newCreatedClonedCase='+newCreatedClonedCase);
        
        
        test.stopTest(); 
    }
    
    /**
    * This method covers the cloneCase method of If condition.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    static testMethod void test_childClonecaseTest1() {
              
        List<Case> lstChildCases = [SELECT Id,caseNumber,opportunityId__c,Subject,Status,
                           RecordTypeId From Case Where RecordTypeId = :ProductRecordTypeId];
        system.debug('lstChildCases**'+lstChildCases);
        system.assertNotEquals(null, lstChildCases.size() > 0);
                
        Map<String,Object> mapCloneCase  = soc_ManageProductController.fetchClonedCase(lstChildCases[1].Id);
        system.debug('mapCloneCase**'+mapCloneCase);
        Case newClonedCase = (Case)mapCloneCase.get('case');
        Boolean cliSizeOne = (Boolean)mapCloneCase.get('cliSizeOne');
        system.debug('newClonedCase**'+newClonedCase);
        system.assertNotEquals(null, newClonedCase.Subject);
        
        List<soc_Case_Line_Item__c> lstLineItems = soc_ManageProductController.getCaseLineItems(lstChildCases[1].Id);
        system.AssertNotEquals(null,lstLineItems.size() > 0);
        system.debug('lstLineItems**'+lstLineItems.size());
        system.debug('lstLineItems**'+lstLineItems);
        
        List<Object> lstObj = new List<Object>();
        for(soc_Case_Line_Item__c cli : lstLineItems){
            lstObj.add((Object)cli.Id);    
        }
        system.debug('lstObj**'+lstObj);
        system.debug('lstObj**'+lstLineItems[0].soc_CaseId__c);
        Test.startTest();
        
        Case newClonedCase2 = soc_ManageProductController.cloneCase(newClonedCase, lstObj,cliSizeOne,lstLineItems[0].soc_CaseId__c);
        system.assert(newClonedCase2!=null); 
        system.debug('newClonedCase2='+newClonedCase2);
        
       
        
        test.stopTest();
    }
    
    /**
    * This method covers the cloneCase method of else condition.
    * @Author: Pravin Sonawane
    * @Date: 9-APR-2019
    */
    static testMethod void test_childClonecaseTest2() {
        List<Case> lstParentCases = [Select Id, ParentId From Case Where RecordTypeId = :OrderRequestRecordTypeId];
        System.assertEquals(1, lstParentCases.size());
       
              
        List<Case> lstChildCases = [SELECT Id,caseNumber,opportunityId__c,Subject,Status,
                           RecordTypeId,Stage__c,Primary_Domain__c,OwnerId,CIDN__c,soc_Domain__c,
                           srvsup_Parent_CIDN__c,srvsup_Ultimate_CIDN__c,Requestor__c,
                           AccountId,ContactId,Description,RecordType.Name,ParentId,
                           soc_Billing_Account_Number__c,MDN_Network_FNN__c,Network_FNN__c,
                           soc_FNNs__c,soc_Number_of_Sites__c,soc_SFD_Offshore_Restricted__c,Child_Case_Count__c,
                           soc_Product__c,soc_Additional_Technical_Contact__c,soc_Additional_Technical_Contact_Email__c,
                           soc_Additional_Technical_Contact_Phone__c,(select id,Name,soc_order_number__c,soc_ProductId__c,
                                                soc_CaseId__c,soc_ProductId__r.Name,soc_CaseId__r.caseNumber
                                                from Case_Line_Items__r) From Case Where RecordTypeId = :ProductRecordTypeId AND ParentId =:lstParentCases[0].Id];
        system.debug('lstChildCases='+lstChildCases);
        system.assertNotEquals(null, lstChildCases.size() > 0);
        
        Map<String,Object> mapCloneCase  = soc_ManageProductController.fetchClonedCase(lstChildCases[0].Id);
        Case newClonedCase = (Case)mapCloneCase.get('case');     
        system.assertNotEquals(null, newClonedCase.Subject);
        
        List<soc_Case_Line_Item__c> lstLineItems = soc_ManageProductController.getCaseLineItems(lstChildCases[0].Id);
        system.AssertNotEquals(null,lstLineItems.size() > 0);
        system.debug('lstLineItems='+lstLineItems.size());
        system.debug('lstLineItems='+lstLineItems);
        
        lstLineItems.remove(0);
        system.debug('lstLineItems$$$'+lstLineItems);
        
        List<Object> lstObj = new List<Object>();
        for(soc_Case_Line_Item__c cli : lstLineItems){
            lstObj.add((Object)cli.Id);    
        }
        
        Test.startTest();
        
        Case newCreatedClonedCase = soc_ManageProductController.cloneCase(newClonedCase, lstObj,false,lstLineItems[0].soc_CaseId__c);
        system.assert(newCreatedClonedCase.Id!=null); 
        
        test.stopTest(); 
    }
}
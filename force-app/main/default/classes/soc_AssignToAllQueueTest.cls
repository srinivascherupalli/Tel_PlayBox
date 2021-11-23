@isTest
public class soc_AssignToAllQueueTest {
    
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
        
        
        Case caseObj = new Case();
        caseObj.Status = 'New';
        caseObj.stage__c = 'Request Review';
        caseObj.OpportunityId__c = lstoppLineItems[0].OpportunityId;
        caseObj.RecordTypeId = OrderRequestRecordTypeId;
        insert caseObj;  
        system.debug('<<<LIMIT>>>'+Limits.getQueries());    
           
        system.assertNotEquals(null, caseObj.Id);
        
        Test.startTest();
        
        caseObj.Stage__c='Validate And Assign Order';
        update caseObj;
		system.debug('<<<LIMIT>>>'+Limits.getQueries());        
        system.assertEquals('Validate And Assign Order', caseObj.Stage__c);
        
        Test.stopTest();

    }
    
     @isTest
    public  static void test_visible(){        
        Case c = new Case(Status='New',Origin ='Email');
        //List<Case> caseNew = [Select Id,Status,Origin From Case Where Status = 'New' LIMIT 1];
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignToAllQueue.initialize(c.id);
        Case cas=(Case)results.get('case');
        System.assert(cas!=null);        
        test.stopTest();        
    }
    
    @isTest
    public  static void test_assignCase(){        
        Case c = new Case(Status='New',Origin ='Email');
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignToAllQueue.assignCase(c.id,'SOC_Queue');
         System.debug('>>>>>>>results>>>>>>>>>>');
        System.debug(results);
        Case cas=(Case)results.get('response');
        System.assert(cas!=null);        
        test.stopTest();        
    }
    
    
    @isTest
    public  static void test_assignCaseNegative(){        
        Case c = new Case(Status='New',Origin ='Email');
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignToAllQueue.assignCase(c.id,null);
         System.debug('>>>>>>>results>>>>>>>>>>');
        System.debug(results);
        String cas=(String)results.get('response');
        System.assert(cas!=null);        
        test.stopTest();        
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
        
        Map<String,Object> mapChildCase = soc_AssignToAllQueue.initialize(lstChildCases[0].Id);
        system.AssertNotEquals(null,mapChildCase.size() > 0);
       
        
        Map<String,Object> mapCloneCase  = soc_AssignToAllQueue.fetchClonedCase(lstChildCases[0].Id);
        Case cloneCase = (Case)mapCloneCase.get('case');     
        system.assertNotEquals(null, cloneCase.Subject);
        
        test.stopTest();          
    }

}
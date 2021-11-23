@isTest
public class soc_CreateSOCRequestControllerTest {
    @isTest
    public  static void test_socNullCreation(){
        
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.createSOCRequest('123444');
        String status=(String)results.get('status');
        Test.stoptest();
        system.assert(status!=null);
    }
    
    @isTest
    public  static void test_socCreation(){
        
        Opportunity o=soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.createSOCRequest(o.id);
        String status=(String)results.get('status');
        Test.stoptest();
        system.assert(status!=null);
    }
    
    @isTest
    public  static void test_socSupportNullCreation(){     
        Test.startTest();
        Map<String,Object> results= soc_CreateSOCRequestController.createSOCSupportRequest('123444','General', 'asdasd');
        String status=(String)results.get('status');
        Test.stoptest();
        system.assert(status!=null);
    }
    
    
    @isTest
    public  static void test_socSupportCreation(){      
        Opportunity o=soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.createSOCSupportRequest(o.id, 'General', 'asdasd');
        String status=(String)results.get('status');
        Test.stoptest();
        system.assert(status!=null);
    }
    
    @isTest
    public  static void test_getPicklisttest(){
        
        Test.startTest();
        List<String> listValues=soc_CreateSOCRequestController.picklist_values('Case', 'soc_Support_Category_WO__c');
        Test.stoptest();
        system.assert(listValues.size()>1);
        
    }
    
    @isTest
    public static void test_checkOpportunityClosedWonForPartners(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.checkOpportunityClosedWonForPartners(optyObj.id);        
        Test.stoptest();
        system.assert((String)results.get('status') != null);
    }
    
    @isTest
    public static void checkExistingCBSCaseValidation(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.existingCBSCaseValidation(optyObj.id);
        System.assertEquals(results.get('CaseAlreadyExist'), 'no');
        Test.stoptest();
    }
    @isTest
    public static void checkExistingCBSCaseContractValidation(){
        Opportunity optyObj = soc_TestUtility.CreateOpportunity();
        Test.startTest();
        Map<String,Object> results=soc_CreateSOCRequestController.ExistingCBSCaseContractValidation(optyObj.id);
        System.assertEquals(results.get('CaseAlreadyExist'), 'no');
        Test.stoptest();
    }
}
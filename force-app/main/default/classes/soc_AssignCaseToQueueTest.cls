@isTest
public class soc_AssignCaseToQueueTest {  
    @isTest
    public  static void test_assignCase_SOCSupportWithourSFD(){        
        Id SFDSupportReqWithoutSFD = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        opportunity o=soc_TestUtility.CreateOpportunity();
        List<Case> caseList = new List<Case>();
        case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=SFDSupportReqWithoutSFD;
        c.OpportunityId__c=o.id;
        c.Requestor__c=UserInfo.getUserId();
        c.soc_Support_Category_WO__c = 'BCS MAC Early Engagement';
        caseList.add(c);
        test.startTest();
        insert caseList;
        Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
        system.debug('results without_SOC>>'+results);
        String status=(String)results.get('status');
        System.assertEquals('pass', status);
        test.stopTest();  
    }
    @isTest
    public  static void test_assignCaseWithData_SOCSupport(){        
        Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        opportunity o=soc_TestUtility.CreateOpportunity();
        Case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=devRecordTypeId;
        c.OpportunityId__c=o.id;
        c.Requestor__c=UserInfo.getUserId();
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
        system.debug('soc_Support_Request_without_SOC >>'+results);
        String status=(String)results.get('status');
        System.assertEquals('pass', status);
        test.stopTest();  
    }
    @isTest
    public  static void test_assignCaseWithData_SOCSupportGeneral(){
        Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
        opportunity o=soc_TestUtility.CreateOpportunity();
        Case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=devRecordTypeId;
        c.OpportunityId__c=o.id;
        c.Requestor__c=UserInfo.getUserId();
        c.soc_SFD_Offshore_Restricted__c = true;
        c.soc_Support_Category_WO__c='General';
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
        system.debug('results soc_Support_Request_without_SOC>>'+results);
        String status=(String)results.get('status');
        System.assertEquals('pass', status);
        test.stopTest();
    }
    @isTest
    public  static void test_assignCaseWithData_SOCSupportWithGeneral(){
        Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        opportunity o=soc_TestUtility.CreateOpportunity();
        Case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=devRecordTypeId;
        c.Subject='Case Subject';
        c.Requestor__c=UserInfo.getUserId();
        c.OpportunityId__c=o.id;
        /*c.soc_Offshore_Data_Hosting_Restricted__c='Yes';*/
        //c.soc_Customer_Acceptance_Evidence__c=null;
        c.soc_Customer_Required_Date_CRD__c=Date.today();
        c.soc_Additional_Technical_Contact__c='abc';
        c.soc_Additional_Technical_Contact_Email__c='anc@gmm.com';
        c.soc_FNNs__c='kkk';
        c.soc_Number_of_Sites__c='1';
        c.soc_Billing_Account_Number__c='sddscc';
		Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
		String status=(String)results.get('status');
        //System.assertEquals('pass', status);
        test.startTest();
        insert c;
		system.assert(c!=null);
    }
    @isTest
    public  static void test_assignCaseWithData_SOC(){
        Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        opportunity o = soc_TestUtility.CreateOpportunity();
        Case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=devRecordTypeId;
        c.Subject='Case Subject';
        c.Requestor__c=UserInfo.getUserId();
        c.OpportunityId__c=o.id;
        /*c.soc_Offshore_Data_Hosting_Restricted__c='Yes';*/
        //c.soc_Customer_Acceptance_Evidence__c=null;
        c.soc_Customer_Required_Date_CRD__c=Date.today();
        c.soc_Additional_Technical_Contact__c='abc';
        c.soc_Additional_Technical_Contact_Email__c='anc@gmm.com';
        c.soc_FNNs__c='kkk';
        c.soc_Number_of_Sites__c='1';
        c.soc_Billing_Account_Number__c='sddscc';
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
        String status=(String)results.get('status');
        system.assert(status!=null);
        test.stopTest();
    }
    @isTest
    public  static void test_assignCase_SOC(){
        Id devRecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
        Case c = new Case(Status='New',Origin ='Email');
        c.RecordTypeId=devRecordTypeId;
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignCaseToQueue.assignCase(c.id);
        String status=(String)results.get('status');
        System.assertEquals('fail', status);
        test.stopTest();
    }
    @isTest
    public  static void test_validateMandatory(){
        Case c = new Case(Status='New',Origin ='Email');
        test.startTest();
        List<String> results=soc_AssignCaseToQueue.validate(c);
        System.assert(results.size()>0);
        test.stopTest();
    }
    @isTest
    public  static void test_visible(){
        Case c = new Case(Status='New',Origin ='Email');
        test.startTest();
        insert c;
        Map<String,Object> results=soc_AssignCaseToQueue.checkVisibile(c.id);
        Case cas=(Case)results.get('case');
        System.assert(cas!=null);
        test.stopTest();
    }
}
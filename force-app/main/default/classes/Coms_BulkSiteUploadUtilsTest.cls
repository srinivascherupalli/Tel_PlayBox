/**
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : Test class for Coms_BulkSiteUploadUtils class
@ DIGI-10971
******************************************************** CHANGE LOG ********************************************************
 * SL.No    Developer Name      Date            Description
 * 1.       Omkar Jante      07/Oct/2021     DIGI-28081 : Updated logic for soft delete 
*/
@isTest
public class Coms_BulkSiteUploadUtilsTest {
    @testSetup
	public static void setup(){
	Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;

        List<Orchestration_Technical__c> objOrchTech = new List<Orchestration_Technical__c>();
        Orchestration_Technical__c objOrchestrationTechnical = new Orchestration_Technical__c();
        objOrchestrationTechnical.External_Id_1__c=acc.Id;
        objOrchestrationTechnical.Field_4__c='12341';
        objOrchestrationTechnical.Field_2__c='Test';
        objOrchestrationTechnical.Field_3__c='New';
        objOrchestrationTechnical.Field_1__c='Test Site';
        objOrchestrationTechnical.Field_7__c='FALSE';
        objOrchestrationTechnical.Process_Name__c='Bulk_Site_Upload';
        objOrchestrationTechnical.CorrelationId__c=GuidUtil.NewGuid();
        objOrchTech.add(objOrchestrationTechnical);
        insert objOrchTech;
	}
    public static testMethod void ValidateInsertOrchestrationTechnicals(){
        Map<String,Map<String,String>> siteDataMap=new Map<String,Map<String,String>>();
        List<SiteDataWrapper> siteWrapperList=new  List<SiteDataWrapper>();
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        for(Integer i=1;i<5;i++){
            SiteDataWrapper wrapperObject = new SiteDataWrapper();
            wrapperObject.accountId =acc.id;
            wrapperObject.siteName = 'Test Site name';
            wrapperObject.adborId = '1234'+i;
            wrapperObject.address = 'Test'+i;
            wrapperObject.status = 'New';
            wrapperObject.isDelete = 'FALSE';
            siteWrapperList.add(wrapperObject);        
            siteDataMap.put('SiteDataWrapper'+i,new Map<String,String>{'accountId'=>wrapperObject.accountId,'siteName'=>wrapperObject.siteName,'adborId'=>wrapperObject.adborId,'address'=>wrapperObject.address,'status'=>wrapperObject.status, 'isDelete'=>wrapperObject.isDelete}); 
       }
        Test.startTest();
        String isSiteInserted=Coms_BulkSiteUploadUtils.insertOrchestrationTechnicals(siteDataMap);
        System.assertEquals('Success', isSiteInserted);
        Test.stopTest();
    }
    public static testMethod void ValidateUpdateOrchestrationTechnicals(){
        List<Orchestration_Technical__c> objOrchTech=[select Id,External_Id_1__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,CorrelationId__c from Orchestration_Technical__c where Process_Name__c='Bulk_Site_Upload'];
        Test.startTest();
        String isSiteUpserted=Coms_BulkSiteUploadUtils.updateOrchestrationTechnicals(objOrchTech);
        System.assertEquals('Success', isSiteUpserted);
        Test.stopTest();
    }
    public static testMethod void ValidateDeleteOrchestrationTechnicals(){
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        List<Orchestration_Technical__c> objOrchTech=[select Id,External_Id_1__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,CorrelationId__c from Orchestration_Technical__c where Process_Name__c='Bulk_Site_Upload'];
        Test.startTest();
        String correlationId=objOrchTech[0].CorrelationId__c;
        String isSiteDelete=Coms_BulkSiteUploadUtils.deleteOrchestrationTechnicals(correlationId,null);
        System.assertEquals('Success', isSiteDelete);
        Test.stopTest();
    }
    public static testMethod void ValidateDeleteAllOrchestrationTechnicals(){
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        List<Orchestration_Technical__c> objOrchTech=[select Id,External_Id_1__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,CorrelationId__c from Orchestration_Technical__c where Process_Name__c='Bulk_Site_Upload'];
        Test.startTest();
        String correlationId=objOrchTech[0].CorrelationId__c;
        String isSiteDelete=Coms_BulkSiteUploadUtils.deleteOrchestrationTechnicals(null,acc.Id);
        System.assertEquals('Success', isSiteDelete);
        Test.stopTest();
    }
    public static testMethod void ValidategetAllOrchestrationTechnicalRecords(){
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        string query='LIMIT 1';
        Test.startTest();
        List<Orchestration_Technical__c> orchTechlist=Coms_BulkSiteUploadUtils.getAllOrchestrationTechnicalRecords(acc.id,null,null,1,0);
        system.assertEquals(true,orchTechlist.size()>0);
        Test.stopTest();
    } 
}
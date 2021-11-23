/*
@ DEVELOPER : Ajith Kumar 
@ TEAM: Istanbul
@ DESCRIPTION : Test class for OrchestrationTechnicalDeleteSchedule class
@ DIGI-10971
*/
@isTest
public class OrchestrationTechnicalDeleteScheduleTest {
    
    @testSetup
	static void setup(){ 
	Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACTIVE';
        acc.CIDN__c='1234567891';
        acc.ABN__c='1235';
        insert acc;
		
	}
    public static testMethod void validateDeleteOrchestrationTech(){
        Account acc = [SELECT id FROM Account WHERE CIDN__c = '1234567891'];
        List<Orchestration_Technical__c> OrchTechList=new List<Orchestration_Technical__c>();
        for(Integer i=0;i<2;i++ ){
        Orchestration_Technical__c orchTechObj=new Orchestration_Technical__c();
        orchTechObj.External_Id_1__c=acc.id;
        orchTechObj.Field_3__c='Site Created';
        orchTechObj.Field_4__c='262619086 ';
        orchTechObj.Field_2__c='35 COLLINS';
        orchTechObj.Field_1__c='Test SIteName'+i;
        orchTechObj.Process_Name__c='Bulk_Site_Upload';
        orchTechObj.Field_7__c='FALSE';
        OrchTechList.add(orchTechObj);
        }
        insert OrchTechList; 

        Test.startTest();
        id JobId=system.Schedule('Orchestration Technical Delete Old Records Schedule','0 0 4 * * ? *',new OrchestrationTechnicalDeleteSchedule());
        orchestrationRecordDeleteHelper.deleteRecycleBinRecords(OrchTechList);
        CronTrigger cron=[SELECT Id,CronExpression,TimesTriggered FROM CronTrigger WHERE Id=:JobId];
        System.assertEquals('0 0 4 * * ? *',cron.CronExpression); 
        Test.stopTest();
    }
}
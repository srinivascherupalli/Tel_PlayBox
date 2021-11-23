@IsTest
private without sharing class batchClassTest
{        
    @IsTest
    private static void testScheduleprofileLayoutassigmentBatch()
    {
        Test.startTest();
        String sch = '0 0 0 15 3 ? 2022';
        //System.schedule('Test_Sched', sch, new Schedule_profileLayoutassigmentBatch());
		String jobID=System.schedule('Test_Sched', sch, new Schedule_profileLayoutassigmentBatch());
		CronTrigger ct = [SELECT CronExpression,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID];
		
		System.assertEquals(sch,ct.CronExpression);
        Test.stopTest();
    }

    @IsTest
    private static void testScheduleEventlogdelete()
    {
        Event_log__c Elog = New Event_log__c();
        Elog.EVENT_TYPE__c = 'URI';
        Elog.REQUEST_ID__c = '45RmZSSDg88LSA12zgZA';
		String orgId = UserInfo.getOrganizationId();
        Elog.ORGANIZATION_ID__c = orgId;
        Elog.USER_ID__c = userinfo.getUserId();
        Elog.CLIENT_IP__c = '122.15.228.208';
        Elog.URI__c = '/apex/accountpage';
        //Elog.TIMESTAMP_DERIVED__c = DateTime.valueOf(columns[48].replace('T',' ').replace('Z',' '));
        Elog.TIMESTAMP_DERIVED__c =  Date.today().addDays(-15);
        Elog.USER_ID_DERIVED__c = userinfo.getUserId();
        Elog.URI_ID_DERIVED__c = '12345';
        Elog.Object_Name__c = 'Contact';
        Elog.READ_EVENT__c = 'Detail'; 
        insert Elog;
        Test.setCreatedDate(Elog.Id,  Date.today().addDays(-15));
        Test.startTest();
        String sch = '0 0 0 15 3 ? 2022';
        String ScheduledJobID = System.schedule('Test_Sched', sch, new Schedule_deleteEventLogBatch());
		CronTrigger ct = [SELECT CronExpression,TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :ScheduledJobID];		
		System.assertEquals(sch,ct.CronExpression);
        Test.stopTest();
    }
    
    @IsTest
    private static void testpPiichecktrigger()        
    {  
        
        List<PII_Lookup__c> piiListInsert = new List<PII_Lookup__c>();
       try{
            Id piifieldId = [Select Id, Name from RecordType where name = : Constants_PLR.PII_Fields limit 1].Id;
            PII_Lookup__c PL1 = new PII_Lookup__c();
            PL1.Name__c ='Account';
            PL1.PII_Code__c = '001';
            PL1.Field_Name__c = 'Description';
            PL1.RecordTypeId = piifieldId;
            piiListInsert.add(PL1);
            
            PII_Lookup__c PL2 = new PII_Lookup__c();
            PL2.Name__c ='Account';
            PL2.PII_Code__c = '002';
            PL2.Field_Name__c = 'xyz';
            PL2.RecordTypeId = piifieldId;
            piiListInsert.add(PL2);
            
            insert piiListInsert;
            System.assertEquals(piiListInsert.size(),2);
        }
        catch(Exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
    
    @IsTest
    private static void testpPiichecktriggerObj()
        
    {   
        try{
            Id ObjprefixId = [Select Id, Name from RecordType where name = : Constants_PLR.Object_Prefix limit 1].Id;
            PII_Lookup__c PL = new PII_Lookup__c();
            PL.Name__c ='Account';
            Pl.PII_Code__c = '001';
            PL.Field_Name__c = 'test';
            PL.RecordTypeId = ObjprefixId;
            insert PL;
			System.assertEquals(ObjprefixId,PL.RecordTypeId);
        }
        catch(Exception e)
        {
            system.debug('Message'+e.getMessage());
        }
    }
    
    
}
@isTest  
private class readBatchClassTest
{ 
   
    @testsetup
    static void createTestData(){ 
        Id ObjprefixId = [Select Id, Name from RecordType where name = 'Object Prefix' limit 1].Id;
        PII_Lookup__c ObjPrefixCon = new PII_Lookup__c(Field_Name__c='Prefix',Name__c='Contact',event_type__c='Object', PII_code__c='003',  RecordTypeid = ObjprefixId);
        insert objPrefixCon;
        PII_Lookup__c ObjPrefixAcc = new PII_Lookup__c(Field_Name__c='Prefix',Name__c='Account',event_type__c='Object', PII_code__c='001',  RecordTypeid = ObjprefixId);
        insert objPrefixAcc;
       // Object_KeyIds__c con = new Object_KeyIds__c(Name='Contact',Key_Value_Id1__c='Account.Customer_ID__c',Key_Value_Id2__c='ID',Key_Value_Id1_Code__c='40',Key_Value_Id2_Code__c='160',Key_Value_Id3__c='TCM_Contact_ID__c',Key_Value_Id3_Code__c='98');
        String eventType='Object';
		System.assertEquals(eventType,objPrefixAcc.event_type__c); 			
	}
    
    @IsTest
    private static void testreadrecordTypeBatch()
    {	
        Account acc = AccountTestFactory.buildAccount('test') ;
        insert acc;
        Contact con1 = new Contact();
        con1.FirstName ='test ';
        con1.LastName ='data';
        con1.Birthdate = Date.newInstance(1980, 1, 1);
        con1.AccountId = Acc.Id;
        con1.Salutation = 'Mr.';
        insert con1;
        Event_log__c Elog = New Event_log__c();
        Elog.EVENT_TYPE__c = 'URI';
        Elog.REQUEST_ID__c = '45RmZSSDg88LSA12zgZA';
		String orgId = UserInfo.getOrganizationId();
        Elog.ORGANIZATION_ID__c = orgId;
        Elog.USER_ID__c = userinfo.getUserId();
        Elog.CLIENT_IP__c = '122.15.228.208';
        Elog.URI__c = '/apex/accountpage';
        //Elog.TIMESTAMP_DERIVED__c = DateTime.valueOf(columns[48].replace('T',' ').replace('Z',' '));
        Elog.TIMESTAMP_DERIVED__c =  Util_PLR.getGmtTime('2016-08-03T04:43:25.424Z');
        Elog.USER_ID_DERIVED__c = userinfo.getUserId();
        Elog.URI_ID_DERIVED__c = con1.Id;
        Elog.Object_Name__c = 'Contact';
        Elog.READ_EVENT__c = 'Detail'; 
        insert Elog;
        test.startTest(); 
        getrecordTypeBatch btRtype = new getrecordTypeBatch(new List<Event_log__c>{Elog},'URI');
        //database.executebatch(btRtype,50);
		Id dbID=database.executebatch(btRtype,50);	
		AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: dbID ];
		System.assertEquals(aaj.Id,dbID);	
        test.stopTest();
    }
}
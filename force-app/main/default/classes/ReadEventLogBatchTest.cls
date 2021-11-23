@IsTest
public class ReadEventLogBatchTest {
    static String testUserID1 = '005O0000002uSER';
    static String testUserID2 = '005O0000002uSERSER';
	private static final String ACCOUNT_PII_CODE = '001';
    
    @testsetup
    static void createTestData(){
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        Id recTypeId = Schema.SObjectType.PII_Lookup__c.getRecordTypeInfosByName().get('Object Prefix').getRecordTypeId();
        
        List<PII_Lookup__c> pLookupList = new List<PII_Lookup__c>();
        PII_Lookup__c pLookup1 = new PII_Lookup__c();
        pLookup1.RecordTypeId = recTypeId;
        pLookup1.Name__c = Constants_PLR.CONTACT_LABEL; 
        pLookup1.Field_Name__c = 'Prefix';
        pLookup1.PII_Code__c = '003';
        pLookup1.Is_Active__c = true;
        pLookupList.add(pLookup1);
        
        PII_Lookup__c pLookup2 = new PII_Lookup__c();
        pLookup2.RecordTypeId = recTypeId;
        pLookup2.Name__c = Constants_PLR.ACCOUNT_LABEL; 
        pLookup2.Field_Name__c = 'Prefix';
        pLookup2.PII_Code__c = ACCOUNT_PII_CODE;
        pLookup2.Is_Active__c = true;
        pLookupList.add(pLookup2);
    
        insert pLookupList;
        
        User plrUser = new User(Alias = 'TestPLR', Email='testplr@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='PrivacyUser', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_AU', ProfileId = adminProfile.Id, CommunityNickname = 'TUCM',
        TimeZoneSidKey='Australia/Sydney', UserName='testPrivacy18@testorg.com');
        
        insert plrUser;    
		System.assertEquals('testplr@testorg.com',plrUser.Email);
    }
    
    /*
    *   Test creating a Event Log records against URI Event Type records
    */
    @isTest
    static void readEventLogBatchTest_URI() {
        User plrTestUser = [SELECT Id FROM User WHERE UserName='testPrivacy18@testorg.com'];
        String userId = plrTestUser.Id;
        System.debug('plrTestUser: ' + userId);
        
        Test.startTest();
            ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.URI);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID2, userId);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID1, userId.substring(0,15));            
            System.debug('CSVFile4: ' + btRead.m_csvFile);
            Database.executebatch(btRead,1000);            
        Test.stopTest();
        
        //Validate that the Event Log records are created
        List<Event_Log__c> elList = new List<Event_Log__c>([SELECT id, EVENT_TYPE__c, USER_ID__c, PROFILE_NAME__c, URI_ID_DERIVED__c, Object_Name__c 
                                                            FROM Event_Log__c WHERE USER_ID_DERIVED__c =: plrTestUser.id]);
        System.assertEquals(2, elList.size(), 'Error: Unexpected count of Event Log records');
        
        for(Event_Log__c el : elList) {
            System.assertEquals(Constants_PLR.URI, el.EVENT_TYPE__c , 'Error: Unexpected event type');
            System.assert(el.USER_ID__c != null, 'Error: Missing User Id');
            System.assert(el.PROFILE_NAME__c != null, 'Error: Missing Profile Name');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: Missing URI ID DERIVED');
            
            String prefix = el.URI_ID_DERIVED__c.mid(0,3); 
            if(ACCOUNT_PII_CODE.equals(prefix)) {
                System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Incorrct Object Name');               
            }
            else {
                System.assertEquals(el.Object_Name__c, Constants_PLR.CONTACT_LABEL, 'Error: Incorrct Object Name for Contact');   
            }           
        }
    }
    
    /*
    *   Test creating a Event Log records against Visualforce Request Event Type records
    */
    @isTest
    static void readEventLogBatchTest_VisualforceRequest() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String userId = plrTestUser.Id;
        
        Test.startTest();
            ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.VF_PAGE);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID2, userId);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID1, userId.substring(0,15));
            System.debug('CSVFile1: ' + btRead.m_csvFile);
            Database.executebatch(btRead,1000);
        Test.stopTest();
        
        //Validate that the Event Log records are created
        List<Event_Log__c> elList = new List<Event_Log__c>([SELECT id, EVENT_TYPE__c, USER_ID__c, PROFILE_NAME__c, URI_ID_DERIVED__c, Object_Name__c 
                                                            FROM Event_Log__c WHERE USER_ID_DERIVED__c =: plrTestUser.id]);
        System.assertEquals(1, elList.size(), 'Error: Unexpected number of Event Log records');
        
        for(Event_Log__c el : elList) {
            System.assertEquals(Constants_PLR.VF_PAGE, el.EVENT_TYPE__c , 'Error: Unexpected event type');
            System.assert(el.USER_ID__c != null, 'Error: User Id missing');
            System.assert(el.PROFILE_NAME__c != null, 'Error: Profile Name missing');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: URI ID DERIVED missing');
            
            String prefix = el.URI_ID_DERIVED__c.mid(0,3); 
            if(ACCOUNT_PII_CODE.equals(prefix)) {
                System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Incorrct Object Name for Account');               
            }
            else {
                System.assertEquals(el.Object_Name__c, Constants_PLR.CONTACT_LABEL, 'Error: Incorrct Object Name for Contact');   
            }           
        }
    }

    /*
    *   Test creating a Event Log records against UITracking Event Type records
    */
    @isTest
    static void readEventLogBatchTest_UITracking() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String userId = plrTestUser.Id;
        
        Test.startTest();
            ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.UI_TRACKING);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID2, userId);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID1, userId.substring(0,15));
            System.debug('CSVFile2: ' + btRead.m_csvFile);
            Database.executebatch(btRead,1000);
        Test.stopTest();
        
        //Validate that the Event Log records are created
        List<Event_Log__c> elList = new List<Event_Log__c>([SELECT id, EVENT_TYPE__c, USER_ID__c, PROFILE_NAME__c, URI_ID_DERIVED__c, Object_Name__c 
                                                            FROM Event_Log__c WHERE USER_ID_DERIVED__c =: plrTestUser.id]);
        System.assertEquals(1, elList.size(), 'Error: Unexpected Event Log records count');
        
        for(Event_Log__c el : elList) {
            System.assertEquals(Constants_PLR.UI_TRACKING, el.EVENT_TYPE__c , 'Error: Unexpected event type');
            System.assert(el.USER_ID__c != null, 'Error: User Id is null');
            System.assert(el.PROFILE_NAME__c != null, 'Error: Profile Name is missng');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: URI ID DERIVED is null');
            System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Unexpected Object Name for Account');               
        }
    }    

    /*
    *   Test creating a Event Log records against Lightning Interaction Event Type records
    */
    @isTest
    static void readEventLogBatchTest_LightningInteraction() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String userId = plrTestUser.Id;
        
        Test.startTest();
            ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.LIGHTNING_INTERACTION);
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID2, userId);            
            btRead.m_csvFile = btRead.m_csvFile.replace(testUserID1, userId.substring(0,15));
            System.debug('CSVFile3: ' + btRead.m_csvFile);
            Database.executebatch(btRead,1000);
        Test.stopTest();
        
        //Validate that the Event Log records are created
        List<Event_Log__c> elList = new List<Event_Log__c>([SELECT id, EVENT_TYPE__c, USER_ID__c, PROFILE_NAME__c, URI_ID_DERIVED__c, Object_Name__c 
                                                            FROM Event_Log__c WHERE USER_ID_DERIVED__c =: plrTestUser.id]);
        System.assertEquals(2, elList.size(), 'Error: Event Log records count incorrect');
        
        for(Event_Log__c el : elList) {
            System.assertEquals(Constants_PLR.URI, el.EVENT_TYPE__c , 'Error: Unexpected event type');
            System.assert(el.USER_ID__c != null, 'Error: Missing User Id');
            System.assert(el.PROFILE_NAME__c != null, 'Error: Missing Profile Name');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: Missing URI ID DERIVED');
            
            String prefix = el.URI_ID_DERIVED__c.mid(0,3); 
            if(ACCOUNT_PII_CODE.equals(prefix)) {
                System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Unexpected Object Name');               
            }
            else {
                System.assertEquals(el.Object_Name__c, Constants_PLR.CONTACT_LABEL, 'Error: Incorrct Object Name for Contact');   
            }           
        }
    }

    /*
	* This method is read event log file stored in static resource for testing purpose
	* 
	*/
    public static string getreadTestData(string EventType)
    {
        string name = 'TestData'+EventType;
        StaticResource defaultResource = [Select  s.Body From StaticResource s where s.Name =:name];
        blob tempB = defaultResource.Body;
        return tempB.toString();
    }
}
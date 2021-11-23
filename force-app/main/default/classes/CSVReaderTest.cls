@IsTest
public class CSVReaderTest {
    private static final String ACCOUNT_PII_CODE = '001';

    @testsetup
    static void createTestData(){
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

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator'];

        User plrUser = new User(Alias = 'TestPLR', Email='testplr@testorg.com',
        EmailEncodingKey='UTF-8', LastName='PrivacyUser', LanguageLocaleKey='en_US',
        LocaleSidKey='en_AU', ProfileId = adminProfile.Id, CommunityNickname = 'TUCM',
        TimeZoneSidKey='Australia/Sydney', UserName='testPrivacy18@testorg.com');

        insert plrUser;
    }

    /*
    *   Test creating a Event Log records against URI Event Type records
    */
    @isTest
    static void readURILogTest() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String fileData_URI = '\"EVENT_TYPE\",\"TIMESTAMP\",\"REQUEST_ID\",\"ORGANIZATION_ID\",\"USER_ID\",\"RUN_TIME\",\"CPU_TIME\",\"CLIENT_IP\",\"URI\",\"SESSION_KEY\",\"LOGIN_KEY\",\"REQUEST_STATUS\",\"DB_TOTAL_TIME\",\"DB_BLOCKS\",\"DB_CPU_TIME\",\"REFERRER_URI\",\"TIMESTAMP_DERIVED\",\"USER_ID_DERIVED\",\"URI_ID_DERIVED\"' + '\n' +
                              '\"URI\",\"20170728000400.526\",\"4CKKeYs8gaQ80zIdp7r43-\",\"00D0k000000CnCq\",\"' + plrTestUser.Id + '\",\"53\",\"37\",\"1.152.96.221\",\"/0010k000002TZAq\",\"PIgTTHbIGYlh0YpZ\",\"voYOOiKKva1jXzoA\",\"S\",\"11987599\",\"664\",\"10\",\"https-//telstrab2b--nfbdev03-cs57-my-salesforce-com/0010k000002TZAq\",\"2017-07-28T00:04:00.526Z\",\"' + plrTestUser.Id + '\",\"0010k000002TZAqAAO\"' + '\n' +
                              '\"URI\",\"20170728043835.306\",\"4CKZdUtqrC-2Ke-qbwHtB-\",\"00D0k000000CnCq\",\"' + plrTestUser.Id + '\",\"405\",\"67\",\"203.35.82.168\",\"/0030k00000AceU0\",\"lGSD1atlqe+phYJR\",\"sfJvObQs1z/PRnGM\",\"S\",\"330790405\",\"1355\",\"120\",\"https-//telstrab2b--nfbdev03-cs57-my-salesforce-com/0010k000002TZAq\",\"2017-07-28T04:38:35.306Z\",\"' + plrTestUser.Id + '\",\"0030k00000AceU0AAJ\"' + '\n' +
                              '\"URI\",\"20170728043810.271\",\"4CKZc35_zcYGXEIdp7r43-\",\"00D0k000000CnCq\",\"' + plrTestUser.Id + '\",\"12\",\"5\",\"203.35.82.168\",\"/ui/common/MRUHoverLoader\",\"lGSD1atlqe+phYJR\",\"sfJvObQs1z/PRnGM\",\"S\",\"4895396\",\"90\",\"0\",\"https-//telstrab2b--nfbdev03-cs57-my-salesforce-com/0010k000002TZAq\",\"2017-07-28T04:38:10.271Z\",\"' + plrTestUser.Id + '\",\"\"';

        List<String> eventLogFileList = fileData_URI.split(Constants_PLR.NEWLINE_CHAR);
        System.assertEquals(eventLogFileList.size(), 4, 'Error: Unexpected number of lines in this data file');
        List<Event_Log__c> eventLogList = new List<Event_Log__c>(CSVReader.readURIlog(eventLogFileList));
        System.debug('EventLogList: ' + eventLogList );
        System.assertEquals(eventLogList.size(), 2, 'Error: Unexpected number of Event Log records');

        for(Event_Log__c el : eventLogList) {
            System.assertEquals(Constants_PLR.URI, el.EVENT_TYPE__c , 'Error: Unexpected event type detected');
            System.assert(el.REQUEST_ID__c != null, 'Error: Request Id is null');
            System.assert(el.ORGANIZATION_ID__c != null, 'Error: Organization Id is null');
            System.assert(el.USER_ID__c != null, 'Error: User Id is null');
            System.assert(el.CLIENT_IP__c != null, 'Error: Client IP is null');
            //System.assert(el.PROFILE_NAME__c != null, 'Error: Profile Name is null');
            System.assert(el.URI__c != null, 'Error: URI is null');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: URI ID DERIVED is null');
            System.assertEquals('Detail', el.READ_EVENT__c, 'Error: Unexpected Read Event');

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
    *   Test creating a Event Log records against Visualforce Request Event Type records
    */
    @isTest
    static void readVisualforceRequestLogTest() {
        String fileData_URI = '\"EVENT_TYPE\",\"TIMESTAMP\",\"REQUEST_ID\",\"ORGANIZATION_ID\",\"USER_ID\",\"RUN_TIME\",\"CPU_TIME\",\"CLIENT_IP\",\"URI\",\"SESSION_KEY\",\"LOGIN_KEY\",\"REQUEST_STATUS\",\"DB_TOTAL_TIME\",\"PAGE_NAME\",\"REQUEST_TYPE\",\"IS_FIRST_REQUEST\",\"QUERY\",\"HTTP_METHOD\",\"USER_AGENT\",\"REQUEST_SIZE\",\"RESPONSE_SIZE\",\"VIEW_STATE_SIZE\",\"CONTROLLER_TYPE\",\"MANAGED_PACKAGE_NAMESPACE\",\"IS_AJAX_REQUEST\",\"DB_BLOCKS\",\"DB_CPU_TIME\",\"TIMESTAMP_DERIVED\",\"USER_ID_DERIVED\",\"URI_ID_DERIVED\"' + '\n' +
                              '\"VisualforceRequest\",\"20170727000818.039\",\"4CJ6JOP8nmy7Bu-qbwB1l-\",\"00D0k000000CnCq\",\"0050k000000RHY0\",\"240\",\"80\",\"101.53.164.8\",\"/apex/AccountValidateABN\",\"aQMi+0OPxB4Jindr\",\"RxCbHLgvk2gAALO5\",\"S\",\"117360720\",\"/apex/AccountValidateABN\",\"content_UI\",\"1\",\"?inline=1&id=0010k000002TZAq\",\"GET\",\"13059000\",\"-1\",\"17842\",\"5765\",\"1\",\"\",\"0\",\"1153\",\"20\",\"2017-07-27T00:08:18.039Z\",\"0050k000000RHY0AAO\",\"\"' + '\n' +
                              '\"VisualforceRequest\",\"20170727000827.771\",\"4CJ6JyAy_hyUqe-qbwHnE-\",\"00D0k000000CnCq\",\"0050k000000RHY0\",\"100\",\"31\",\"120.21.124.192\",\"/apex/csbb__CSBasketRedirect\",\"kcRKQ4p0sWPKaWkd\",\"RxCbHLgvk2gAALO5\",\"S\",\"66934924\",\"/apex/csbb__CSBasketRedirect\",\"page\",\"1\",\"?id=a3Q0k00000008Ye&sfdc.override=1\",\"GET\",\"13059000\",\"-1\",\"54672\",\"1943\",\"1\",\"csbb\",\"0\",\"218\",\"0\",\"2017-07-27T00:08:27.771Z\",\"0050k000000RHY0AAO\",\"\"';
        List<String> eventLogFileList = fileData_URI.split(Constants_PLR.NEWLINE_CHAR);
        System.assertEquals(eventLogFileList.size(), 3, 'Error: Unexpected number of lines in the file');
        List<Event_Log__c> eventLogList = new List<Event_Log__c>(CSVReader.readVFlog(eventLogFileList));
        System.debug('EventLogList: ' + eventLogList );
        System.assertEquals(eventLogList.size(), 1, 'Error: Unexpected number of Event Log records');

        for(Event_Log__c el : eventLogList) {
            System.assertEquals(Constants_PLR.VF_PAGE, el.EVENT_TYPE__c , 'Error: Unexpected event type');
            System.assert(el.REQUEST_ID__c != null, 'Error: Missing Request Id');
            System.assert(el.ORGANIZATION_ID__c != null, 'Error: Missing Organization Id');
            System.assert(el.USER_ID__c != null, 'Error: Missing User Id');
            System.assert(el.CLIENT_IP__c != null, 'Error: Missing Client IP');
            //System.assert(el.PROFILE_NAME__c != null, 'Error: Missing Profile Name');
            System.assert(el.URI__c != null, 'Error: Missing URI');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: Missing URI ID DERIVED');

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
    static void readUITrackingLogTest() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String fileData_URI = '\"EVENT_TYPE\",\"TIMESTAMP,REQUEST_ID\",\"ORGANIZATION_ID\",\"USER_ID\",\"CLIENT_ID\",\"SESSION_ID\",\"NETWORK_ID\",\"USER_TYPE\",\"USER_AGENT\",\"BROWSER_NAME\",\"BROWSER_VERSION\",\"OS_NAME\",\"OS_VERSION\",\"CLIENT\",\"SDK_VERSION\",\"SDK_MODEL\",\"SDK_APP_NAME\",\"SDK_APP_VERSION\",\"SDK_APP_TYPE\",\"REFERRER\",\"REQUEST_METHOD\",\"APP_NAME\",\"CLIENT_IP\",\"LOCATION\",\"ACTION\",\"OBJECT_TYPE\",\"RECORD_ID\",\"RECORD_TYPE_ID\",\"PAGE_OPTION\",\"ACTION_TYPE\",\"ACTION_LOCATION\",\"TARGET\",\"TARGET2\",\"NUMBER1\",\"NUMBER2\",\"STATUS\",\"DEVICE_ID\",\"CONNECTION_TYPE\",\"SIGNAL_STRENGTH\",\"CARRIER\",\"LATITUDE\",\"LONGITUDE\",\"USAGE_TIMESTAMP\",\"START_TIME\",\"END_TIME\",\"DELTA\",\"UNIQUE_PAGE_ID\",\"TIMESTAMP_DERIVED\",\"USER_ID_DERIVED\"' + '\n' +
                              '\"UITracking\",\"2.01607E+13\",\"TID:285807000000e975db\",\"00DO0000004u0WC\",\"' + plrTestUser.Id + '\",\"\",\"[C@4230dc2a\",\"\",\"Standard\",\"Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML; like Gecko) Chrome/50.0.2661.102 Safari/537.36\",\"CHROME\",\"50\",\"WINDOWS\",\"7\",\"one:one:LARGE\",\"Mozilla/5.0\",\"KHTML; like Gecko\",\"Chrome\",\"50.0.2661.102\",\"Safari/537.36\",\"https://cs5.lightning.force.com/lightning?source=aloha\",\"POST\",\"one:one\",\"122.15.228.208\",\"one:recordHomeFlexipage\",\"PageView\",\"Account\",\"001O000000yQO07IAG\",\"\",\"\",\"\",\"\",\"\",\"\",\"0\",\"0\",\"\",\"\",\"\",\"\",\"\",\"\",\"\",\"2.01607E+13\",\"1.46979E+12\",\"1.46979E+12\",\"31\",\"00DO0000004u0WC_005O0000002uEAL_one:recordHomeFlexipage_1469792095389\",\"2016-07-29T11:38:24.891Z\",\"' + plrTestUser.Id + '\"';
        List<String> eventLogFileList = fileData_URI.split(Constants_PLR.NEWLINE_CHAR);
        System.assertEquals(eventLogFileList.size(), 2, 'Error: Unexpected number of lines in the data file');
        List<Event_Log__c> eventLogList = new List<Event_Log__c>(CSVReader.readUIlog(eventLogFileList));
        System.debug('EventLogList: ' + eventLogList );
        System.assertEquals(eventLogList.size(), 1, 'Error: Unexpected number of Event Log records');

        for(Event_Log__c el : eventLogList) {
            System.assertEquals(Constants_PLR.UI_TRACKING, el.EVENT_TYPE__c , 'Error: Unexpected event type present');
            System.assert(el.REQUEST_ID__c != null, 'Error: Request Id is unavailable');
            System.assert(el.ORGANIZATION_ID__c != null, 'Error: Organization Id is unavailable');
            System.assert(el.USER_ID__c != null, 'Error: User Id is unavailable');
            System.assert(el.CLIENT_IP__c != null, 'Error: Client IP is unavailable');
            //System.assert(el.PROFILE_NAME__c != null, 'Error: Profile Name is unavailable');
            System.assert(el.URI__c != null, 'Error: URI is unavailable');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: URI ID DERIVED is unavailable');
            System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Incorrct Object Name for Account');
            System.assertEquals('Detail', el.READ_EVENT__c, 'Error: Unexpected Read Event');
        }
    }

    /*
    *   Test creating a Event Log records against Lightning Interaction Event Type records
    */
    @isTest
    static void readLightningInteractionLogTest() {
        User plrTestUser = [SELECT Id FROM User WHERE Alias = 'TestPLR'];
        String fileData_URI = '\"EVENT_TYPE\",\"TIMESTAMP\",\"REQUEST_ID\",\"ORGANIZATION_ID\",\"USER_ID\",\"CLIENT_ID\",\"SESSION_KEY\",\"LOGIN_KEY\",\"USER_TYPE\",\"APP_NAME\",\"DEVICE_PLATFORM\",\"SDK_APP_VERSION\",\"OS_NAME\",\"OS_VERSION\",\"USER_AGENT\",\"BROWSER_NAME\",\"BROWSER_VERSION\",\"SDK_VERSION\",\"DEVICE_MODEL\",\"DEVICE_ID\",\"SDK_APP_TYPE\",\"CLIENT_IP\",\"CONNECTION_TYPE\",\"UI_EVENT_ID\",\"UI_EVENT_TYPE\",\"UI_EVENT_SOURCE\",\"UI_EVENT_TIMESTAMP\",\"PAGE_START_TIME\",\"DURATION\",\"DEVICE_SESSION_ID\",\"UI_EVENT_SEQUENCE_NUM\",\"PAGE_ENTITY_ID\",\"PAGE_ENTITY_TYPE\",\"PAGE_CONTEXT\",\"TARGET_UI_ELEMENT\",\"PARENT_UI_ELEMENT\",\"GRANDPARENT_UI_ELEMENT\",\"TIMESTAMP_DERIVED\",\"USER_ID_DERIVED\"' + '\n' +
                              '\"LightningInteraction\",\"20170728033425.481\",\"TID:14822622000052a70a\",\"00D0k000000CnCq\",\"' + plrTestUser.Id + '\",\"\",\"n6yqJPnDjcyRqwOk\",\"rFfoie7suZBK560F\",\"Standard\",\"one:one\",\"SFX:BROWSER:DESKTOP\",\"\",\"WINDOWS\",\"7\",\"\"\"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36\"\"\",\"CHROME\",\"59\",\"\",\"\",\"\",\"\",\"203.35.82.171\",\"\",\"ltng:interaction\",\"crud\",\"read\",\"1501212861829\",\"1501212716712\",\"\",\"70bce0697b3265bf946102f09024b7996164ab6d\",\"10\",\"\",\"Account\",\"force:objectHomeDesktop\",\"read\",\"force_record\",\"\",\"2017-07-28T03:34:25.481Z\",\"' + plrTestUser.Id + '\"' + '\n' +
                              '\"LightningInteraction\",\"20170728033425.498\",\"TID:14822622000052a70a\",\"00D0k000000CnCq\",\"' + plrTestUser.Id + '\",\"\",\"n6yqJPnDjcyRqwOk\",\"rFfoie7suZBK560F\",\"Standard\",\"one:one\",\"SFX:BROWSER:DESKTOP\",\"\",\"WINDOWS\",\"7\",\"\"\"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36\"\"\",\"CHROME\",\"59\",\"\",\"\",\"\",\"\",\"203.35.82.171\",\"\",\"ltng:interaction\",\"crud\",\"read\",\"1501212861854\",\"1501212716712\",\"\",\"70bce0697b3265bf946102f09024b7996164ab6d\",\"11\",\"0010k000002TZAqAAO\",\"Account\",\"one:recordHomeFlexipage\",\"read\",\"force_record\",\"\",\"2017-07-28T03:34:25.498Z\",\"' + plrTestUser.Id + '\"' + '\n' +
                              '\"LightningInteraction\",\"20170713043807.987\",\"TID:20326900000ada7952\",\"00D0k000000Cv4v\",\"' + plrTestUser.Id + '\",\"\",\"/qI3Rn88Kfv92Ip3\",\"rGKkiHOMpGKgo+zq\",\"Standard\",\"one:one\",\"SFX:BROWSER:DESKTOP\",\"\",\"WINDOWS\",\"7\",\"\"\"Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.115 Safari/537.36\"\"\",\"CHROME\",\"59\",\"\",\"\",\"\",\"\",\"203.35.135.165\",\"\",\"ltng:interaction\",\"crud\",\"read\",\"1499920679455\",\"1499920666739\",\"\",\"1d2c83428fb2531ab0a2b0de84d34dacf3b5069b\",\"5\",\"0030k000009rZycAAE\",\"Contact\",\"one:recordHomeFlexipage\",\"read\",\"force_record\",\"\",\"2017-07-13T04:38:07.987Z\",\"' + plrTestUser.Id + '\"';
        List<String> eventLogFileList = fileData_URI.split(Constants_PLR.NEWLINE_CHAR);
        System.assertEquals(eventLogFileList.size(), 4, 'Error: Unexpected number of lines');
        List<Event_Log__c> eventLogList = new List<Event_Log__c>(CSVReader.readLightningInteractionLog(eventLogFileList));
        System.debug('EventLogList: ' + eventLogList );
        System.assertEquals(eventLogList.size(), 2, 'Error: Unexpected number of Event Log records');

        for(Event_Log__c el : eventLogList) {
            System.assertEquals(Constants_PLR.URI, el.EVENT_TYPE__c , 'Error: Unexpected event type returned');
            System.assert(el.REQUEST_ID__c != null, 'Error: Request Id not populated');
            System.assert(el.ORGANIZATION_ID__c != null, 'Error: Organization Id not populated');
            System.assert(el.USER_ID__c != null, 'Error: User Id is not populated ');
            System.assert(el.CLIENT_IP__c != null, 'Error: Client IP is not present');
            //System.assert(el.PROFILE_NAME__c != null, 'Error: Profile Name is not present');
            System.assert(el.URI__c != null, 'Error: URI is not populated');
            System.assert(el.URI_ID_DERIVED__c != null, 'Error: URI ID DERIVED is missing');

            String prefix = el.URI_ID_DERIVED__c.mid(0,3);
            if(ACCOUNT_PII_CODE.equals(prefix)) {
                System.assertEquals(el.Object_Name__c, Constants_PLR.ACCOUNT_LABEL, 'Error: Incorrct Object Name for Account');
            }
            else {
                System.assertEquals(el.Object_Name__c, Constants_PLR.CONTACT_LABEL, 'Error: Incorrct Object Name for Contact');
            }
        }
    }
}
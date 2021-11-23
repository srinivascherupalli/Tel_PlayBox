public with sharing class Constants_PLR {
    
    public static string URI = 'URI';
    public static string VF_PAGE = 'VisualforceRequest';
    public static string UI_TRACKING ='UITracking';
    public static string LIGHTNING_INTERACTION ='LightningInteraction';
    public static string NEWLINE_CHAR =  '\n';
    public static string Read_EventLog_Batch =  'ReadEventLogBatch ';
    public static string GET_RECORDTYPE_BATCH =  'getrecordTypeBatch ';
    public static string profileLayoutassigment_Batch =  'profileLayoutassigmentBatch ';
    public static string describePageLayout_Batch =  'describePageLayoutBatch ';
    public static string deleteEventLog_Batch ='deleteEventLogBatch ';
    public static string DELETE_BATCH_QUERY = 'SELECT  Id, CreatedDate,TIMESTAMP_DERIVED__c FROM Event_Log__c where TIMESTAMP_DERIVED__c <= :dt';
    public static string  Object_Prefix =  'Object Prefix';
    public static string PII_Fields = 'PII Fields';
    public static string PREFIX = 'Prefix';
    public static string TRIGGER_ERROR = 'Object prefix record cant have field name other than Prefix';
    public static string TRIGGER_ERROR01 = 'Object or field name invalid';
    public static string PROFILE = 'Profile';
    public static string PROFILE_QUERY = 'Select Name From Profile ';
    public static string TEST_LIMIT = ' Limit 1';
    public static string LAYOUT = 'Layout';
    public static string ID ='Id';
    public static string RECORD_TYPE = 'recordtypeid';
    public static String NS_SOAP = 'http://schemas.xmlsoap.org/soap/envelope/';
    public static String NS_SF = 'urn:partner.soap.sforce.com';
	public static final String ACCOUNT_LABEL = 'Account';
	public static final String CONTACT_LABEL = 'Contact';
    
}
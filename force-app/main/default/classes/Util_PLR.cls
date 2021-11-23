/*
@Author 
@name Util_PLR
@CreateDate 07/22/2016
@Description - all utility methods used in batch classes

*/ 

public without sharing class Util_PLR { 
    
    private static Map<ID, User> mapUserProfile;
    public static string AUDIT_LOG_STATUS_STARTED = 'Started';
    public static string AUDIT_LOG_STATUS_FAILED = 'Failed';
    public static string AUDIT_LOG_STATUS_SUCCESS = 'Success';
    
    /*
* This method is to check if sobject column combination is valid or not
* If the combination is valid it returns true else false
*/ 
    Public static  Boolean checkSobjectColumn(string sobjectName, string columnName)
    {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if(schemaMap.containsKey(sobjectName))
        {
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sobjectName).getDescribe().fields.getMap();
            return fieldMap.containsKey(columnName);
        }
        else
        {
            return false;
        }
        
    }
    
    /*
* This method is to retrieve event log file from EventLogFile sObject for a specific event type
* This method takes eventType as argument and returns List<EventLogFile >
*/ 
    Public static  List<EventLogFile > getEventLog(string eventType)
    {        
        System.debug('EventType: ' + eventType);
        Integer logdays = Integer.valueOf(getBatchSetting().Import_log_days__c);
        List<EventLogFile > elf=[SELECT LogFile, Id, CreatedDate, LastModifiedDate, EventType, LogDate FROM EventLogFile where EventType = :eventType AND CreatedDate >= :Date.today().addDays(-logdays) order by CreatedDate DESC];
        System.debug('ELF: ' + elf);        
        return elf;
    }
    
    /*
* This method is to retrieve batch class settings from custom metadataType
* This method takes no argument and returns Batch_setting__mdt record
*/ 
    Public static  Batch_setting__mdt getBatchSetting()
    {
        List<Batch_setting__mdt> batchSetting = [SELECT Id, DeveloperName, Import_log_days__c, delete_log_days__c, Admin_email__c FROM Batch_setting__mdt where DeveloperName ='Read_batch_setting'];
        return batchSetting[0];
    }
    /*
* This method is to send email to admin in case of batch class failure 
* 
*/ /* EDGE-52698: moved this email send functionality to process builder.
    Public static  void Sendemail(string body)
    {
        List<String> SetToList=new List<String>();
        SetToList.add(getBatchSetting().Admin_email__c);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();        
        email.setToAddresses(SetToList);
        email.setSubject('Batch Error-PLR Dev');     
        email.setHtmlBody(body);
        email.setSenderDisplayName('PLR Admin');
        Messaging.SendEmailResult[] result = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email } ); 
    } */
    
    /*
* This method is to log batch class failure in PLRAudit_log__c sobject 
* 
*/ 
    Public static  void logerror(exception e,PLRAudit_log__c log)
    {
        log.Status__c = Util_PLR.AUDIT_LOG_STATUS_FAILED;
        log.Error_Description__c = 'Type: ' + e.getTypeName() + '\n' + 'Cause: ' + e.getCause() + '\n' + 'Message: ' 
            + e.getMessage() + '\n' + 'Line #: ' + e.getLineNumber() + '\n' + e.getStackTraceString() ;
        log.End_Date__c = system.now();
        update log; 
        //EDGE-52698: moved this email send functionality to process builder.
        //Sendemail(log.Error_Description__c);
    }
    /*
* This method is to log batch class success in PLRAudit_log__c sobject 
* 
*/ 
    Public static  void logSuccess(PLRAudit_log__c log, Integer records)
    {
        log.Status__c = Util_PLR.AUDIT_LOG_STATUS_SUCCESS;
        log.Error_Description__c = records + '  Records Inserted/updated';
        log.End_Date__c = system.now();
        update log; 
    }
    /*
* This method is to log batch class start in PLRAudit_log__c sobject 
* 
*/ 
    Public static  PLRAudit_log__c logbatchstart(string batchname)
    {
        PLRAudit_log__c log = new PLRAudit_log__c();
        log.Batch_Name__c = batchname;
        log.Status__c = Util_PLR.AUDIT_LOG_STATUS_STARTED;
        log.Start_Date__c = system.now();
        insert log; 
        return log;
    }
    /*
* This method is to retrieve object Key ids from custom metadataType
* This method takes object name as  argument and returns object Key ids as list of strings
*/ 
    Public static  List<string> getObjectkeyIds(string name)
    {
        List<Object_Key_Ids__mdt> objKeys = [SELECT  DeveloperName, Label, Key_Value_Id1__c, Key_Value_Id1_Code__c, Key_Value_Id2__c, Key_Value_Id2_Code__c, Key_Value_Id3__c, Key_Value_Id3_Code__c FROM Object_Key_Ids__mdt where DeveloperName =: name];
        list<string> ObjectkeyIds = new list<string>{objKeys[0].Key_Value_Id1__c,objKeys[0].Key_Value_Id2__c,objKeys[0].Key_Value_Id3__c,objkeys[0].Key_Value_Id1_Code__c,objkeys[0].Key_Value_Id2_Code__c,objkeys[0].Key_Value_Id3_Code__c};
            return ObjectkeyIds;
    }
    
    /*
* This method is to retrieve user profile mapping
* This method takes no  argument and returns map of user id and profile
*/ 
    public static Map<Id, User> getuserProfilemap()
    {
        If(mapUserProfile == null)
        {
            mapUserProfile = new Map<ID, User>([Select Id,Profile.Name From User]) ;
        }
        return mapUserProfile;
    }
    
    /*
* This method is to retrieve object prefix stored in PII_lookup sobject
* This method takes no argument and returns map of object name and prefix eg. 'Account','001'
*/ 
    public static Map<string, String> getObjPrefixmap()
    {
        List<PII_Lookup__c> lstObjPrefix = [Select Name__c, PII_Code__c From PII_Lookup__c where RecordType.name ='Object Prefix'];
        Map<string,String> mapObjPrefix = New Map<String,String>();
        for(PII_Lookup__c ObjPrefix:lstObjPrefix)
        {
            mapObjPrefix.put(ObjPrefix.PII_code__c, ObjPrefix.Name__c);
        }
        System.debug('MapObjPrefix: ' + mapObjPrefix);
        return mapObjPrefix;
    }
    
    /*
* This method is to retrieve MetadataService.MetadataPort class instance and set class variables 
* 
*/ 
    public static MetadataService.MetadataPort getMetadataService(String sessionId)
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sessionid;  
        service.timeout_x = 120000;  
        return service;
    }
    
    /*
* This method is to convert string date into DateTime type and return GMt dateTime
* 
*/ 
    public static DateTime getGmtTime(string strdt)
    {
        String dt = strdt.substringbefore('T');
        string tm = strdt.substringBetween('T','Z');
        string[] dts=dt.split('-');
        string[] tms=tm.split(':');
        Date myDate = Date.newInstance(Integer.valueOf(dts[0]),Integer.valueOf(dts[1]), Integer.valueOf(dts[2]));
        Time myTime = Time.newInstance(Integer.valueOf(tms[0]), Integer.valueOf(tms[1]), Integer.valueOf(tms[2].substringbefore('.')), Integer.valueOf(tms[2].substringafter('.')));
        return DateTime.newInstancegmt(myDate, myTime);
        
    }
    
    /*
* This method is check if FLS is enabled for a perticular field
* 
*/ 
    public static boolean checkFieldFls(string sobjectName, string fieldName)
    {
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get(sobjectName).getDescribe().fields.getMap();
        return !fieldMap.get(fieldName).getDescribe().isPermissionable();
    } 
    
      /*
* This method is to get peofile metadata from metadata api
* 
*/ 
    public static MetadataService.Profile[] getprofilemetadata(string sessionid , string[] profileList)
    {
        //setting MetadataService.MetadataPort class variables
        MetadataService.MetadataPort service = getMetadataService(sessionid);
        // Invoking readMetadata method from MetadataService.MetadataPort class to retrieve profile metadata
        return (MetadataService.Profile[]) service.readMetadata(Constants_PLR.PROFILE, profileList).getRecords();
        
    }
    
    /*
* This method is to get layout metadata from metadata api
* 
*/ 
    public static MetadataService.Layout[] getlayoutmetadata(string sessionid , string[] layoutnames)
    {
        //setting MetadataService.MetadataPort class variables
        MetadataService.MetadataPort service = Util_PLR.getMetadataService(sessionid);
        // Invoking readMetadata method from MetadataService.MetadataPort class to retrieve Layout metadata
        return (MetadataService.Layout[]) service.readMetadata(Constants_PLR.LAYOUT, layoutnames).getRecords();
        
    }
    
    /*
* This method is to get session id for api callout
* 
*/ 
    public static string getSessionId(){
        try{
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');   
        req.setTimeout(60000);
        req.setEndpoint('callout:PLRMetadataFetch/services/Soap/u/31.0');
        req.setHeader('Content-Type', 'text/xml;charset=UTF-8');        
        req.setHeader('SOAPAction', '""');
        req.setBody('<Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/"><Header/><Body><login xmlns="urn:partner.soap.sforce.com"><username>' + '{!$Credential.UserName}' + '</username><password>' + '{!$Credential.Password}' + '</password></login></Body></Envelope>');        
        HttpResponse res =  new Http().send(req);
        System.debug('res:>> ' + res);
        if(res.getStatusCode() != 200){
            Dom.Document responseDocument = res.getBodyDocument();
            Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
            Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', Constants_PLR.NS_SOAP); // soapenv:Body 
            Dom.Xmlnode faultElm = bodyElm.getChildElement('Fault', Constants_PLR.NS_SOAP); // soapenv:Fault
            
        }
        Dom.Document responseDocument = res.getBodyDocument();
        Dom.Xmlnode rootElm = responseDocument.getRootElement(); // soapenv:Envelope
        Dom.Xmlnode bodyElm = rootElm.getChildElement('Body', Constants_PLR.NS_SOAP); // soapenv:Body 
        Dom.Xmlnode loginResponseElm = bodyElm.getChildElement('loginResponse', Constants_PLR.NS_SF); // loginResponse
        Dom.Xmlnode resultElm = loginResponseElm.getChildElement('result', Constants_PLR.NS_SF); // result
        Dom.Xmlnode sessionIdElm = resultElm.getChildElement('sessionId', Constants_PLR.NS_SF); // sessionId
        
        return sessionIdElm.getText();
        }
        catch(Exception e){
        	System.debug('Exception: ' + e.getStackTraceString());
            return null;
        }
    }  
    
}
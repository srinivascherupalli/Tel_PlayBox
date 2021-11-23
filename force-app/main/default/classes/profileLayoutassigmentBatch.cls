global Without sharing class profileLayoutassigmentBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful 
{
    /**
@Author 
@name profileLayoutassigmentBatch
@CreateDate 07/11/2016
@Description Batch to retrieve  assoiciated page layouts with profiles  

*/ 
    //This is the sessionid of user invoking batch. it is used to call metadata api
    String sessionId;
    //This list to store object prefix
    Set<String> lstobjprefix;
    
    Map<string,String> mapProfileMeta;
    Map<string,String> mapMetaProfile;
    
    //List<Profile_Mapping__mdt> lstprfoileMapping;
    List<Profile_Layout__c> lstpflLayout;
    
    PLRAudit_log__c auditLog;
    Integer ErrorCount ;
    Exception errorExeption;
    
    global profileLayoutassigmentBatch() {
        this.sessionId = Util_PLR.getSessionId();
        system.debug('sessionId >> ' + sessionId);        
        lstobjprefix = new Set<string>();
        ErrorCount = 0;
        lstobjprefix.addAll(Util_PLR.getObjPrefixmap().values());
        // lstprfoileMapping = [SELECT Id, Label, Profile_Metadata_Name__c FROM Profile_Mapping__mdt];
        mapProfileMeta = new Map<string,String>();
        mapMetaProfile = new Map<string,String>();
        For(Profile_Mapping__mdt pm:[SELECT Id, Label, Profile_Metadata_Name__c FROM Profile_Mapping__mdt])
        {
            mapProfileMeta.put(pm.Label, pm.Profile_Metadata_Name__c);
            mapMetaProfile.put(pm.Profile_Metadata_Name__c, pm.Label);
        }
        lstpflLayout = New List<Profile_Layout__c>(); 
    }
    
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
        //Logging batch start into PLRAudit_log__c sObject
        auditLog = Util_PLR.logbatchstart(Constants_PLR.profileLayoutassigment_Batch);
        String query = Constants_PLR.PROFILE_QUERY + (Test.isRunningTest() ? Constants_PLR.TEST_LIMIT : '');
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext batchableContext, List<Profile> scope) 
    {	System.debug('Number of Profile :' + scope.size());
        //Savepoint sp = Database.setSavepoint();
        try
        {
            
            string[] profileList = new List<String>();
            MetadataService.Profile[] profiles;
            For(Profile p :scope)
            {
                If(mapProfileMeta.containsKey(p.Name))
                {
                    profileList.add(mapProfileMeta.get(p.Name));
                }
                else
                {
                    profileList.add(p.Name); 
                }
            }
            // calling metdata api to retrieve profile metadata
            Try
            {
                // Invoking readMetadata method from MetadataService.MetadataPort class to retrieve profile metadata
                System.debug('ProfileList: ' + profileList);
                profiles = Util_PLR.getprofilemetadata(sessionid ,profileList);
                System.debug('Profiles: ' + profiles);
            }
            catch(Exception e)
            {
                If(e.getMessage().contains('INVALID_SESSION_ID'))
                {
                    sessionid = Util_PLR.getSessionId();
                    profiles = Util_PLR.getprofilemetadata(sessionid ,profileList);
                }
                else
                {
                    throw e;
                }
            }
            //Iterating over profiles retrieved
            for(MetadataService.Profile pf:profiles)
            {
                if(pf.layoutAssignments!= null)
                {
                    //Iterating over layouts available on profile
                    for(MetadataService.ProfileLayoutAssignment Pl: pf.layoutAssignments)
                    {
                        // Check to ensure that only tracking objects Layouts are saved
                        If(lstobjprefix.contains(EncodingUtil.urlDecode(pl.layout,'UTF-8').substringBefore('-')))
                        {
                            Profile_Layout__c Pa = new Profile_Layout__c();
                            If(mapMetaProfile.containsKey(pf.fullName))
                            {
                                Pa.Profile__c = mapMetaProfile.get(pf.fullName);
                            }
                            else
                            {
                                Pa.Profile__c = pf.fullName;                    
                            }
                            //Checking if Contact has recordtype NULL
           					If((EncodingUtil.urlDecode(pl.layout,'UTF-8').substringBefore('-')=='Contact') && (pl.recordType == NULL))
                            {
                                Pa.RecordType__c ='NA';
                            }
							else
                            {
                            Pa.RecordType__c = pl.recordType; 
                            }
                            Pa.Layout__c = EncodingUtil.urlDecode(pl.layout,'UTF-8');
                            Pa.Profile_Key__c = EncodingUtil.urlDecode(pl.layout,'UTF-8').substringBefore('-') + '-'+pf.fullName+'-'+((pl.recordType != NULL ) ? pl.recordType: '');
                            lstpflLayout.add(Pa);
                        }
                    } 
                }
            }
            
        }
        
        // Logging error in case of any exception
        catch (Exception e) {
            //ErrorCount = ErrorCount + 1 ;
            errorExeption = e;
            // Database.rollback(sp);
        }
    }   
    
    global void finish(Database.BatchableContext batchableContext) 
    {
        //Creating savepoint 
        Savepoint sp = Database.setSavepoint();
        try
        {
            if(ErrorCount > 0)
            {
                Util_PLR.logerror(errorExeption,auditLog);
                
            }
            else
            {
                Database.upsert(lstpflLayout,Profile_Layout__c.Fields.Profile_Key__c,true);
                //Logging success if batch runs successfully
                Util_PLR.logSuccess(auditLog,lstpflLayout.size()) ;
                //Invoking describePageLayoutBatch to retrieve layout information
                describePageLayoutBatch btldetail= new describePageLayoutBatch(sessionId);
                database.executebatch(btldetail,5);
            }
            
        }
        // Logging error in case of any exception
        catch (Exception e) 
        {
            Database.rollback(sp);
            Util_PLR.logerror(e,auditLog);
        }
        
    }
}
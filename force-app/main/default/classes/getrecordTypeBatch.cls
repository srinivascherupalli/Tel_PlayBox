global with sharing class getrecordTypeBatch implements Database.batchable<String>, Database.Stateful
{
    /**
@Author 
@name getrecordTypeBatch
@CreateDate 07/28/2016
@Description Batch to populate recordType , Layout, KeyIds to Event_Log__c records generated

*/ 
    //map to store RecordtypeId column availability on objects
    private Map<string,boolean> maprecordtypecheck;
    
    List<Event_log__c> lstElog; 
    List<Event_log__c> lstEl;
    boolean isSuccess;
    PLRAudit_log__c auditLog;
    String m_eventType;
    
    Public getrecordTypeBatch(List<Event_log__c> elog, string eventType){
        //retrieve Object prefix and store in a list lstObjPrefix
        //List<PII_Lookup__c> lstObjPrefix = [Select Name__c, PII_code__c From PII_Lookup__c where RecordType.name = : Constants_PLR.Object_Prefix];
        m_eventType = eventType;
        maprecordtypecheck = New Map<string,boolean>();
        for(PII_Lookup__c ObjPrefix:[Select Name__c, PII_code__c From PII_Lookup__c where RecordType.name = : Constants_PLR.Object_Prefix])
        {
            //Adding values to maprecordtypecheck map for all retrieve objects
            maprecordtypecheck.put(ObjPrefix.Name__c, Util_PLR.checkSobjectColumn(ObjPrefix.Name__c,Constants_PLR.RECORD_TYPE));
        }
        lstElog = elog;
        lstEl = New List<Event_log__c>();
    }
    
    global Iterable<String> start(Database.batchableContext batchableContext) {
        //Logging batch start into PLRAudit_log__c sObject
        auditLog = Util_PLR.logbatchstart(Constants_PLR.GET_RECORDTYPE_BATCH);
        isSuccess = true;
        List<String> lstobjs = new List<string>();
        lstobjs.addAll(maprecordtypecheck.keySet());
        return lstobjs;
    }
    
    global void execute(Database.BatchableContext batchableContext, List<String> scope){
        Savepoint sp = Database.setSavepoint();
        try
        {
            String query = '' ;
            //lstElog = [ Select ID,Object_Name__c,URI_ID_DERIVED__c,Record_Type__c,PROFILE_NAME__c From Event_log__c where  Object_Name__c in :scope];
            If(lstElog != null && lstElog.size() > 0)
            {
                Map<Id,sObject> mapRecordType = New Map<Id,sObject>();
                List<string> lstobjkeyId = new List<string>();
                For(String obj:scope)
                {
                    //retrieve Layout from Profile layout object
                    Map<string,String> mapProfilelayout = New map<string,string>();
                    //List<Profile_Layout__c> plst = [ select Profile__c , Object__c,DerivedRecordType__c , Layout__c from Profile_Layout__c where Object__c = :obj];
                    
                    For(Profile_Layout__c p: [select Profile__c , Object__c,DerivedRecordType__c , Layout__c from Profile_Layout__c where Object__c = :obj])
                    {
                        string profileKey = p.Profile__c + p.Object__c  + (p.DerivedRecordType__c != NULL  ? p.DerivedRecordType__c : '');
                        mapProfilelayout.put(profileKey,p.Layout__c);
                    }
                    //get object key Id columns from custom setting
                    Set<string> lstrec = New Set<string>();
                    String objkeyIds='';
                    lstobjkeyId = Util_PLR.getObjectkeyIds(obj);
                    For(Integer i =0;i<3;i++ )
                    {
                        If(lstobjkeyId[i] != '' && lstobjkeyId[i] != null && Util_PLR.checkSobjectColumn(obj,lstobjkeyId[i]) && !lstobjkeyId[i].equalsIgnoreCase('Id'))
                        {
                            objkeyIds += ','+'%'+lstobjkeyId[i]+'%' ;
                        }
                        else
                        {
                            If(lstobjkeyId[i].contains('.'))
                            {
                                If(Util_PLR.checkSobjectColumn(lstobjkeyId[i].substringbefore('.'),lstobjkeyId[i].substringafter('.')))
                                {
                                    objkeyIds += ','+lstobjkeyId[i] ;
                                }
                            }
                        }
                    }
                    for(Event_log__c el:lstElog)
                    {
                        if(el.Object_Name__c == obj)
                        {
                            lstrec.add(el.URI_ID_DERIVED__c);
                        }
                    }
					if(maprecordtypecheck.get(obj))
                    {
                        query = ' Select id , recordtype.Developername, recordtype.NamespacePrefix ' + objkeyIds +' from ' + string.escapesinglequotes(obj);
                    }
                    else
                    {
                        query = ' Select id  ' + objkeyIds +' from '+ string.escapesinglequotes(obj);
                    }
					query+='Where id IN :lstrec ALL ROWS'; 

                    for(sobject s:Database.query(query))
                    {
                        mapRecordType.put(string.valueOf(s.get('id')),s);
                    }
                    for(Event_log__c el:lstElog)
                    {
                        if(el.Object_Name__c == obj && mapRecordType.get(el.URI_ID_DERIVED__c) != null)
                        {
                            string profileKey = el.PROFILE_NAME__c + obj;
                            
                            //slst.add(el.Object_Name__c);
                            if(maprecordtypecheck.get(el.Object_Name__c) )
                            {
                                
                                el.Record_Type__c = string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject('recordtype').get('DeveloperName'));
                                if(String.isNotBlank(String.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject('recordtype').get('NamespacePrefix')))) {
                                	el.Record_Type__c = String.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject('recordtype').get('NamespacePrefix')) + '__' + el.Record_Type__c;
                                }
                                System.debug('Record_Type: ' + el.Record_Type__c);
                                profileKey += el.Record_Type__c;
                            }
                            
                            If(lstobjkeyId[0] != NULL && lstobjkeyId[0].contains('.'))
                            {
                                el.Key_Value_Id1__c = string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject(lstobjkeyId[0].substringbefore('.')).get(lstobjkeyId[0].substringafter('.')));
                            }
                            else
                            {
                                el.Key_Value_Id1__c      = ((lstobjkeyId[0] != NULL ) ? string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).get(lstobjkeyId[0])): ''); 
                                
                            }
                            If(lstobjkeyId[1] != NULL && lstobjkeyId[1].contains('.'))
                            {
                                el.Key_Value_Id2__c = string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject(lstobjkeyId[1].substringbefore('.')).get(lstobjkeyId[1].substringafter('.')));
                            }
                            else
                            {
                                el.Key_Value_Id2__c      = ((lstobjkeyId[1] != NULL ) ? string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).get(lstobjkeyId[1])): '');
                            }
                            If(lstobjkeyId[2] != NULL && lstobjkeyId[2].contains('.'))
                            {
                                el.Key_Value_Id3__c = string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).getsobject(lstobjkeyId[2].substringbefore('.')).get(lstobjkeyId[2].substringafter('.')));
                            }
                            else
                            {
                                el.Key_Value_Id3__c      =  ((lstobjkeyId[2] != NULL ) ? string.valueOf(mapRecordType.get(el.URI_ID_DERIVED__c).get(lstobjkeyId[2])): '');
                            }
                            el.Key_Value_Id1_Code__c = lstobjkeyId[3];
                            el.Key_Value_Id2_Code__c = lstobjkeyId[4];
                            el.Key_Value_Id3_Code__c = lstobjkeyId[5];
                            el.Layout__c = mapProfilelayout.get(profileKey);
                            lstEl.add(el);
                        }
                    }
                    System.debug(lstEl);
                }
                
            }   
            
            If(lstEl.size()>0)
            {
                update lstEl;
                isSuccess = true;
            }
        }
        // Logging error in case of any exception
        catch (Exception e) 
        {
            Database.rollback(sp);
            isSuccess = false;
            Util_PLR.logerror(e,auditLog);
            system.abortJob(batchableContext.getJobId());
            
        }
    }
    
    global void finish(Database.BatchableContext batchableContext){
        Try
        {
            If(isSuccess)
            {
                //Logging success if batch runs successfully
                Util_PLR.logSuccess(auditLog,lstEl.size()) ;
                if(m_eventType == Constants_PLR.URI)
                {
                    
                    ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.VF_PAGE);
                    database.executebatch(btRead,1000); 
                }
                else if(m_eventType == Constants_PLR.VF_PAGE)
                {
                    
                    ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.UI_TRACKING);
                    database.executebatch(btRead,1000); 
                }
                else if(m_eventType == Constants_PLR.UI_TRACKING)
                {
                    
                    ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.LIGHTNING_INTERACTION);
                    database.executebatch(btRead,1000); 
                }
            }
        }
        // Logging error in case of any exception
        catch (Exception e) 
        {
            Util_PLR.logerror(e,auditLog);
        }
    }
}
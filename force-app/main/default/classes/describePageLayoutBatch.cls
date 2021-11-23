global without sharing class describePageLayoutBatch implements Database.Batchable<AggregateResult> , Database.AllowsCallouts, Database.Stateful 
{
    /**
@Author 
@name describePageLayoutBatch
@CreateDate 07/15/2016
@Description Batch to retrieve  fields available on page layouts and mini page layouts

*/ 
    //This is the sessionid of user invoking batch. it is used to call metadata api
    String sessionId;
    
    List<Layout_detail__c> lstlLayout;
    
    PLRAudit_log__c auditLog;
    Integer ErrorCount ;
    Exception errorExeption;
    global describePageLayoutBatch( String sessionId ) {
        this.sessionId = sessionId;
        lstlLayout = New List<Layout_detail__c>();
    }
    
    global Iterable<AggregateResult> start(Database.BatchableContext batchableContext) {
        System.debug('Start describePageLayoutBatch');
        ErrorCount = 0 ;
        //Logging batch start into PLRAudit_log__c sObject
        auditLog = Util_PLR.logbatchstart('BATCH02_describePageLayout');
        return new AggregateResultIterator();
    }
    
    global void execute(Database.BatchableContext batchableContext, List<Sobject> scope) {
        // Savepoint sp = Database.setSavepoint();
        System.debug('Execute describePageLayoutBatch');
        try
        {
            MetadataService.Layout[] Layouts;
            // Set to store Page layout fields
            Set<string> str ;
            // Set to store mini Page layout fields
            Set<string> strmini;
            // Set to store all the fields available on page layout and Mini page layout
            Set<String> strall ;
            // striing array to store layout names foe metadata api call
            string[] layoutnames= New List<string>();
            //Iterating over layouts retrieved from batch scope and adding it to layoutlist
            for (Sobject so : scope)  
            {
                AggregateResult ar = (AggregateResult) so;
                layoutnames.add(String.valueof(ar.get('Layout__c')));
            }
            
            // calling metdata api to retrieve layout metadata
            Try
            {
                Layouts = Util_PLR.getlayoutmetadata(sessionid ,layoutnames);
                System.debug('Layouts: ' + Layouts);
            }
            catch(Exception e)
            {
                If(e.getMessage().contains('INVALID_SESSION_ID'))
                {
                    sessionid = Util_PLR.getSessionId();
                    Layouts = Util_PLR.getlayoutmetadata(sessionid ,layoutnames);
                }
                else
                {
                    throw e;
                }
            }
            
            //Iterating over layouts retrieved
            for(MetadataService.Layout Ly:Layouts)
            {
                str = new Set<String>();
                strmini = new Set<String>();
                strall = new Set<String>();
                //Iterating over layouts sections
                if(ly.layoutSections!= null)
                {
                    for(MetadataService.layoutSection ls: ly.layoutSections)
                    {
                        // Detail layout fields 
                        if(ls.layoutColumns!= null)
                        {
                            for(MetadataService.layoutColumn lc: ls.layoutColumns)
                            {
                                if(lc.layoutItems!= null)
                                {
                                    for(MetadataService.layoutItem li: lc.layoutItems)
                                    {
                                        if(li.field != null)
                                        {
                                            str.add(li.field.removeEndIgnoreCase(Constants_PLR.ID)); 
                                        }
                                        
                                    }
                                }
                            }
                        } 
                        // mini layout fields
                        if(ly.miniLayout!= null)
                        {
                            for(String  MiniField: ly.miniLayout.fields)
                            {
                                strmini.add(MiniField.removeEndIgnoreCase(Constants_PLR.ID));
                                
                            }
                        }
                    }
                }
                
                strall.addall(str);
                strall.addall(strmini);
                System.debug('Strall: ' + strall);
                // Inserting all Layout fields into Layout_detail__c sObject
                for(String s: strall)
                {
                    Layout_detail__c ld = New Layout_detail__c();
                    ld.Layout_name__c = Ly.fullName;
                    ld.Layout_field__c = s;
                    if(strmini.contains(s))
                    {
                        ld.Mini_Page_Layout__c = true;
                    }
                    if(str.contains(s))
                    {
                        ld.Available_on_layout__c = true;
                    }
                    ld.Layout_key__c = Ly.fullName+'-'+s;
                    
                    lstlLayout.add(ld);   
                }
                
            }
            System.debug('LstlLayout: ' + lstlLayout);
            //upsert lstlLayout Layout_key__c ;
            
        }
        // Logging error in case of any exception
        catch (Exception e) 
        {
            ErrorCount = ErrorCount + 1 ;
            errorExeption = e;
            // Database.rollback(sp);
        }
    } 
    
    global void finish(Database.BatchableContext batchableContext) {
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
                Database.upsert(lstlLayout,Layout_detail__c.Fields.Layout_key__c,true);
                
                List<Layout_detail__c> lstlLayoutDel = [ Select Id From Layout_detail__c where lastmodifiedDate != TODAY];
                Database.delete(lstlLayoutDel,true); 
                //Logging success if batch runs successfully
                Util_PLR.logSuccess(auditLog,lstlLayout.size()) ;  
                // As per EDGE-44293 this batch and Event_Log__c object is not in use anymore hence commenting out the batch call. 
                //ReadEventLogBatch btRead = new ReadEventLogBatch(Constants_PLR.URI);
                //database.executebatch(btRead,1000); 
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
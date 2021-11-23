public with sharing class APTPS_TemplateTriggerHandler {
	public static boolean isExecutingInsert = false;
    
    public String updateClausewithApttusTemplate(Map<Id, Apttus__APTS_Template__c> templateClauseMap){
        if( APTPS_TemplateTriggerHandler.isExecutingInsert){
            system.debug('in return');
            return 'Success';
		}
        
        Map<Id,String> templateIds =  new Map<Id,String>();
    	try{
            List<Clause__c> clauses1 = new List<Clause__c>();
            Map<Apttus__APTS_Template__c,Clause__c> templateClauses = new Map<Apttus__APTS_Template__c,Clause__c>(); 
     		for(Apttus__APTS_Template__c template : templateClauseMap.values())
    		{
        		if(template.Apttus__Type__c == 'Clause' && template.Clause__c!=null )
        			templateIds.put(template.Clause__c,template.Apttus__TextContent__c);
                else if(template.Apttus__Type__c == 'Clause' && template.Clause__c==null )
                {
                    Clause__c clause = new Clause__c();
                	clause.Name = template.Name;
                	clause.Content__c = template.Apttus__TextContent__c ;
                    clause.Clause_Number__c = template.Template_NumberText__c;
                	clauses1.add(clause);
                    templateClauses.put(template,clause);
                }
                    
    		}
        insert clauses1;
        if(templateClauses.size()>0){
       		for(Apttus__APTS_Template__c templateClause:templateClauses.keySet()){
                
                templateClause.Clause__c = templateClauses.get(templateClause).Id;
                System.debug('Updating:'+templateClause+' clause:'+templateClauses.get(templateClause).Id);
           }            
        }  
    	List<Clause__c> clauses=[Select id,Content__c from Clause__c where id IN: templateIds.keySet()];
        if(clauses.size()>0)
    		for(Clause__c clause:clauses){
        	clause.Content__c = templateIds.get(clause.Id);
    	}
    
    	update clauses;
    	System.debug('SFclauses Updated successfully');    
        
        return 'Success';
    	}
    	catch(Exception e){
        	System.debug('Exception:'+e.getMessage()+e.getLineNumber());
    	}
        
		return 'Error';
        
    }
    
    public String insertClausewithApttusTemplate(Map<Id, Apttus__APTS_Template__c> templateClauseMap){
       
    	try{     		
        System.debug('Here in insert');    
    	List<Clause__c> clauses = new List<Clause__c>();
        Map<Apttus__APTS_Template__c,Clause__c> templateClauses = new Map<Apttus__APTS_Template__c,Clause__c>();    
            for(Apttus__APTS_Template__c templateClause:templateClauseMap.values()){
                if(templateClause.Apttus__Type__c == 'Clause'){
                    System.debug('Here in clause');
                	Clause__c clause = new Clause__c();
                	clause.Name = templateClause.Name;
                	clause.Content__c = templateClause.Apttus__TextContent__c ;
                    clause.Clause_Number__c = templateClause.Template_Number__c;
                	clauses.add(clause);
                    Apttus__APTS_Template__c t = new Apttus__APTS_Template__c(Id = templateClause.Id);
                    templateClauses.put(t,clause);                	
                }
                
            }
           insert clauses;
           APTPS_TemplateTriggerHandler.isExecutingInsert = true ;
           for(Apttus__APTS_Template__c templateClause:templateClauses.keySet()){
                templateClause.Clause__c = templateClauses.get(templateClause).Id;
           }
           
           List<Apttus__APTS_Template__c> templatesToUpdate = new List<Apttus__APTS_Template__c>();
           templatesToUpdate.addAll(templateClauses.keySet());
           update templatesToUpdate;
           System.debug('SFclauses inserted successfully'); 
           return 'Success'; 
    	}
        catch(Exception e){
        System.debug('Exception:'+e.getMessage());
        }
        return 'Error'; 
    }
 
    public void insertAndCopyAutoNumber(Map<Id, Apttus__APTS_Template__c> templateMap){
        List<Apttus__APTS_Template__c> templatesToUpdate = new List<Apttus__APTS_Template__c>();
        for(Apttus__APTS_Template__c template:templateMap.values()){
        	Apttus__APTS_Template__c t = new Apttus__APTS_Template__c(Id = template.Id);
             t.Template_NumberText__c = template.Template_Number__c;
            templatesToUpdate.add(t);
        }
        APTPS_TemplateTriggerHandler.isExecutingInsert = true ;
        System.debug('update:'+templatesToUpdate);
        update templatesToUpdate;
        
    }
    
     public void updateAndCopyAutoNumber(Map<Id, Apttus__APTS_Template__c> templateMap){
        if( APTPS_TemplateTriggerHandler.isExecutingInsert){
            system.debug('in return');
            return;
		}
        List<Apttus__APTS_Template__c> templatesToUpdate = new List<Apttus__APTS_Template__c>();
        for(Apttus__APTS_Template__c t:templateMap.values()){
             t.Template_NumberText__c = t.Template_Number__c;           
        }
    }
    
}
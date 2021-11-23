/*
 * EDGE-1616331- Created for contact role creation
 * 
 * */

public with sharing class contactRolecontroller {
 
    
     @AuraEnabled
    public static OpportunityContactRole getOpptyContactRole(Id opptyconroleId)
    {
     OpportunityContactRole opptyconrole = [select Id,Role,IsPrimary   from  OpportunityContactRole WHERE Id =: opptyconroleId limit 1];   
       return opptyconrole;
    }
    
 
     @AuraEnabled
    public static OpportunityContactRole getOpptyrolefromcontactoppty(String opptyId,String contactId)
    {
         OpportunityContactRole opptyconroleobj=new OpportunityContactRole();
       
             
            OpportunityContactRole[] opptyconrole = [select Id,Role,IsPrimary,OpportunityId,ContactId   from  OpportunityContactRole WHERE (OpportunityId =: opptyId AND ContactId=:contactId)];   
            system.debug('opptyconrole'+opptyconrole);
            if(opptyconrole.Size()>0)
            {
             opptyconroleobj= opptyconrole[0];
            } 
          
			return 	opptyconroleobj;
        //return oppty;
    }
  
    
     @AuraEnabled
    public static void createOpptyContactRole(String opptyconroleId,String changedRole,boolean primaryflag,String CustContactId)
    {
      //  try{    
        
      // OpportunityContactRole opptyconrole = [select Id,Contact.Name,Contact.Email,Role,IsPrimary   from  OpportunityContactRole WHERE Id =: opptyconroleId limit 1];   
      if( CustContactId != null )
      {
           OpportunityContactRole opptyrole=new OpportunityContactRole();
          
          OpportunityContactRole[] OptyroleId=[SELECT Id,ContactId,OpportunityId,Role,IsPrimary FROM OpportunityContactRole where (ContactId=:CustContactId AND OpportunityId=: opptyconroleId)];
          if(OptyroleId.Size()>0)
          {
              OptyroleId[0].IsPrimary=primaryflag;
              OptyroleId[0].Role=changedRole;
              UPDATE OptyroleId[0];
              system.debug('opptyrole.Role'+changedRole);
          }
          else{
              opptyrole.ContactId=CustContactId;
              opptyrole.OpportunityId=opptyconroleId;
              opptyrole.IsPrimary=primaryflag;
              opptyrole.Role=changedRole;
                system.debug('opptyrole.Role'+opptyrole);
              Database.upsert(opptyrole,false);  
          }
      
           system.debug(opptyrole.Id);
      		}
            /*
    		}
            catch(Exception e)
            {
              String errorMessage = 'ERROR => ' + e.getLineNumber() + '-' + e.getMessage() + '\n';
                System.debug('createOpptyContactRole'+errorMessage);
            }
            */
      
        
        
     
      
      // return opptyconrole;
         //return oppty;
    }
    
     @AuraEnabled
    public static Opportunity getOpptydetails(Id opptyconroleId)
    {
     Opportunity opptyconrole = [select Id,AccountId   from  Opportunity WHERE Id =: opptyconroleId limit 1];   
       return opptyconrole;
         //return oppty;
    }

     @AuraEnabled
    public static void updateOpptyContactRole(String opptyconroleId,String changedRole,boolean primaryflag)
    {
       OpportunityContactRole[] opptyconrole = [select Id,Contact.Name,Contact.Email,Role,IsPrimary   from  OpportunityContactRole WHERE Id =: opptyconroleId limit 1];   
     if(opptyconrole.Size()>0)
      {
           opptyconrole[0].Role=changedRole;
       }
        if(primaryflag != null)
      {
        opptyconrole[0].IsPrimary=primaryflag;
      }
       Update opptyconrole;
     
       system.debug(opptyconrole);
      // return opptyconrole;
         //return oppty;
    }
    
 @AuraEnabled
    public static String[] picklist_values(String object_name, String field_name) {
        String[] values = new String[]{};
            String[] types = new String[]{object_name};
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        for(Schema.DescribeSobjectResult res : results) {
            for (Schema.PicklistEntry entry : res.fields.getMap().get(field_name).getDescribe().getPicklistValues()) {
                if (entry.isActive()) {values.add(entry.getValue());}
            }
        }
        return values;
    }
	
	}
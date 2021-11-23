public without sharing class OpptyConflictRecordPB {
   
   @invocableMethod
   public  Static void CreateConflictRecPB(list<id> newOpp)
   {
     String PRMCommunityUser=Label.PRM_Community_User;
      
     list<opportunity> newPBOppty=[SELECT Id,CloseDate,AccountId,Product_Domain__c,account.owner.Id,account.Owner.Email FROM 
                                   opportunity where Id=:newOpp];
         system.debug('newOpp'+newOpp);
   if(newPBOppty[0].Id!=null)
   {
    Id pid= [select id from profile where name=:PRMCommunityUser].id;
    Id adminProfile= [select id from profile where name='System Administrator'].id;
    //user adminuser =[select Id  from user where ProfileId=:adminProfile];
   	PRM_Default__c Prmdfault = PRM_Default__c.getInstance(pid);
   	Boolean EnableOptyCheck = Prmdfault.Enable_Partner_Opp_Conflict_Checking__c;
    Decimal PratConflictDays =Prmdfault.Partner_Opp_Conflict_Number_of_Days__c;
    String loggedinUserId = UserInfo.getUserId();
    String loggedinProfileId = UserInfo.getProfileId();
    //String optyCreatedby=newOpp.CreatedBy;
    // System.debug('optyCreatedby'+optyCreatedby); 
         	User logeduser = [SELECT Id, IsPortalEnabled, IsPrmSuperUser, ProfileId
                                          FROM User
                                          WHERE Id = :loggedinUserId];
	System.debug('EnableOptyCheck'+EnableOptyCheck);
       //First Check to Check teh flag
       
       if(EnableOptyCheck==true)
       {
           System.debug('Flag is True');
    	//Check if the user is a Partner user
		if(logeduser.IsPortalEnabled==true)
     	{
            list<Partner_Opportunity_Conflict__c> newOppShare=new list<Partner_Opportunity_Conflict__c>();
           
           
               String newOpptyId=newPBOppty[0].Id;
               Date OpptyClosedateadd=newPBOppty[0].CloseDate.addDays(Integer.valueOf(PratConflictDays));
               Date OpptyClosedateless=newPBOppty[0].CloseDate.addDays(Integer.valueOf(-PratConflictDays));
                
                system.debug('OpptyClosedateadd'+newPBOppty[0].CloseDate);
                system.debug('OpptyClosedateadd'+OpptyClosedateadd);
                system.debug('OpptyClosedateless'+OpptyClosedateless);
                system.debug('Product_Domain__c'+newPBOppty[0].Product_Domain__c);
                system.debug('Account'+newPBOppty[0].AccountId);
                
              	  list <opportunity> existingoppty=[SELECT Id,AccountId,Product_Domain__c,account.owner.Id,account.Owner.Email FROM opportunity where 
                                                IsClosed  =false 
                                                AND AccountId=:newPBOppty[0].AccountId
                                                AND Product_Domain__c=:newPBOppty[0].Product_Domain__c	 
                								AND Id<>:newOpptyId
                								AND (CloseDate>:OpptyClosedateless
                								AND CloseDate< :OpptyClosedateadd)];
					
                                                
                
                   system.debug(existingoppty);
                        if(existingoppty!= null)
                        {
                         for (opportunity createlist:existingoppty)
                        {	
                              system.debug(createlist);
                           	Partner_Opportunity_Conflict__c jobShr  = new Partner_Opportunity_Conflict__c();
                           	jobShr.Existing_Opportunity__c=createlist.Id;
                           	jobShr.New_Opportunity__c=newOpptyId;
                        	jobShr.OwnerId=createlist.account.owner.Id;
                            jobShr.Status__c='New';
                          //  jobShr.Existing_Opportunity_Mgr_Email__c=createlist.account.Owner.Email;
                            //jobShr.New_Oppty_Channel_Mgr_Email__c=newOpptyId.;
                            newOppShare.add(jobShr);
			                system.debug(newOppShare);      
                        }
                
                     
                      }//if not null
                
                
          //  }//for close
         	 Database.SaveResult[] sr = Database.insert(newOppShare,false);
           	 system.debug(sr);
   // list <Partner_Opportunity_Conflict__c> ConflictObj=new list<Partner_Opportunity_Conflict__c>(); 

   		 }//if IsPortalEnabled close
       
       }//if close
   }//if Id !=null close
       
   }//Create Opty Conflict record.

}
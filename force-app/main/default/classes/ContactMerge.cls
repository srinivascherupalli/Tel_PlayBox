public without sharing class ContactMerge implements RecordMerge {
            public CustomerObject.Customer selectedCustomer;
            public JSON2TCMCustomerContactObject customerContact;
            public ContactObject contacts {get;set;}
            map<String,String > oErrorMsg = new map <String ,String> ();
            //public list<ContactObject.CustomerAccount> custacc;
            public String params{get;set;}
            public String result {get;set;}
            private static Integer upper_limit = 10;
            public static Integer offset = 0;
            List<ContactObject.Contact> contactList =  new List<ContactObject.Contact>();    
            List<Merge_Request__c> mergeRequest = new List<Merge_Request__c>();
   			//Fix for Production issue P2OB-11879     Seprating Callout and DML to avoid system.calloutException     
    		List<Merge_Request__c> mergeRequestCalloutException = new List<Merge_Request__c>();
    		List<ApplicationLog__c> applicationLogRecords = new List<ApplicationLog__c>();

    // #MergeRequesrIssueFix : Store  Request and Response for  Target Missing UUID
				map<String , HttpRequest> targetMissingRequest =  new map<String , HttpRequest>();
				map<String , HttpResponse> targetMissingResponse =  new map<String , HttpResponse>();
        public static final String Certificate_name = EnvironmentVariable.get('certificate_name');

    
            public ContactMerge(Merge_Request__c mergeRecords){
                mergeRequest.add(mergeRecords);
            }
            public ContactMerge(list<Merge_Request__c> mergeRecords){
                mergeRequest = mergeRecords;
            }
            public ContactMerge(){}
            
            public boolean executeMerge()
            {	system.debug('Contact merge executeMerge started...calling validateMergeRecords with mergeRequest count :'+mergeRequest.size());
                list<Merge_Request__c> validatedRecord = validateMergeRecords(mergeRequest);
                system.debug('validationerror++' +validatedRecord);
                boolean result =  false;
				if(validatedRecord.size() > 0){
				
					map<String,Contact> sourceRecords =  querySourceRecords(validatedRecord);
					map<String,Contact> targetRecords =  queryTargetRecords(validatedRecord);
					Map<String,Contact> mergeMap = new Map<String,Contact>();
					List<AccountContactRelation> ToDeleteContactRel = new List<AccountContactRelation>();
					List<cscrm__Site__c> ToDeleteContactsiteRel = new List<cscrm__Site__c>();
					List<cscrm__Site__c> inssiteRel = new List<cscrm__Site__c>();
					List<AccountContactRelation> insContactRel = new List<AccountContactRelation>();
					List<cscrm__Contact_Address_Relationship__c> ToDeleteAddress = new List<cscrm__Contact_Address_Relationship__c>();
					Set<AccountContactRelation> sContactRel = new Set<AccountContactRelation>();
					Id targAccId;
					Id targConId;
					Id targsiteConId;
					
					for(Contact cont:[SELECT Id,  AccountId,  Phone,  Email, Birthdate, Online_Flag__c, Other_Address_Ext__c,Pref_Comm_Method__c, Product_Contact__c, Send_Create_Event__c, UUID__c, accountUuid__c, addressId__c, country__c, eNews__c, eOffers__c, lastVerifiedDate__c, numberInHousehold__c, timeZone__c, Merge_Lock__c FROM Contact  WHERE UUID__c IN:sourceRecords.Keyset() or UUID__c IN:targetRecords.Keyset() ])
					{    
						mergeMap.put(cont.UUID__c,cont);
					} 
					for(Merge_Request__c  mr: validatedRecord)
					{
						Contact targetCon =  targetRecords.get(mr.Target_Id__c);
						Contact sourceCon =  sourceRecords.get(mr.Source_Id__c);
                        system.debug('targetcontact'+targetCon.Id);
						system.debug('sourceCon.AccountContactRelations==='+sourceCon.AccountContactRelations);
						system.debug('targetCon.AccountContactRelations==='+targetCon.AccountContactRelations);
						if(sourceCon!=NULL){
						if((sourceCon.AccountContactRelations != null && sourceCon.AccountContactRelations.size() > 0) || (targetCon.AccountContactRelations != null && targetCon.AccountContactRelations.size() > 0)){ 
						for(AccountContactRelation srcacR : sourceCon.AccountContactRelations)
						{
							Boolean ISExists= False;
						 
							 for(AccountContactRelation taracR:targetCon.AccountContactRelations)
							 {
									System.debug('dd++');
									targConId =taracR.ContactId;
									System.debug('ee++' +targAccId);
								   
									if((srcacR.AccountId == taracR.AccountId))
									{
										System.Debug('second For Source Contact Id'+srcacR.ContactId);
										System.Debug('Seconf For Target Contact Id'+taracR.ContactId);
										ToDeleteContactRel.add(srcacR);
										ISExists =True;
									}
								}  
								//if(targConId != null)
                                    targConId = targetCon.Id;
                            		System.debug('targConId++'+targConId);
								if(!ISExists) 
								{
									System.debug('ff++');
									system.debug('Inside IsExists'+srcacR.AccountId);
									AccountContactRelation  conaccrel = new AccountContactRelation();
									conaccrel.AccountId=srcacR.AccountId;
									conaccrel.ContactId=targConId;
									conaccrel.Contact_Type__c=srcacR.Contact_Type__c;
									conaccrel.Contact_Usage__c=srcacR.Contact_Usage__c;
									
									conaccrel.Relationship_End_Date__c=srcacR.Relationship_End_Date__c;
									insContactRel.add(conaccrel);
								}      
								
						   }
                        } 
                            
					   } 
						System.debug('insContactRel>>>'+insContactRel);
						if(insContactRel.size() !=NULL && !insContactRel.isEmpty()){
						for(AccountContactRelation srcacRt : insContactRel)
						{
							sContactRel.add(srcacRt);
						}
						}
						insContactRel.clear();
						insContactRel.addAll(sContactRel);
						system.debug('sites of source con'+sourceCon.Sites__r);
						for(cscrm__Site__c scrSite: sourceCon.Sites__r){
							Boolean ISExistssite= False;
							for(cscrm__Site__c tarsite: targetCon.Sites__r){
								
								targsiteConId =tarsite.Secondary_Contact__c;
								
								if(scrSite.cscrm__Installation_Address__c == tarsite.cscrm__Installation_Address__c && scrSite.cscrm__Account__c == tarsite.cscrm__Account__c){
									ToDeleteContactsiteRel.add(scrSite);
									ISExistssite =True;
								}   
							}
							
							if(!ISExistssite) 
							{
								
								cscrm__Site__c site = new cscrm__Site__c();
								site.Secondary_Contact__c = targsiteConId;
								site.cscrm__Account__c = scrSite.cscrm__Account__c;
								site.cscrm__Installation_Address__c =scrSite.cscrm__Installation_Address__c;
								inssiteRel.add(site);
								
							}   
						 }
						
						
					}
		 
				   
					
					if(ToDeleteContactsiteRel.size() > 0){
						 
						List <Database.DeleteResult> deleteResults = Database.delete(ToDeleteContactsiteRel, false);
						for (Database.DeleteResult delResult : deleteResults)
						{
							if (delResult.isSuccess() == true)
							{
								
							}
							else
							{
								// Failed
								for(Database.Error error : delResult.getErrors())
								{
									
									System.debug('Something went wrong with the record ID ' + delResult.getId() + ' : ' + delResult.getErrors());
									cscrm__Site__c resultAcrel = [Select Id, Secondary_Contact__r.UUID__c, cscrm__Account__c, cscrm__Installation_Address__c From cscrm__Site__c WHERE Id=:delResult.getId() Limit 1];
									Merge_Request__c  mr = [Select Id from Merge_Request__c where Source_Id__c=:resultAcrel.Secondary_Contact__r.UUID__c ];
									mr.Status__c = 'Failed';
									mr.Error_Message__c =error.getMessage();
									update mr;
									return false;
								}
							}
						}
					}
					
					if(inssiteRel.size() > 0){
						//insert inssiteRel;
						List <Database.SaveResult> saveResults = Database.insert(inssiteRel, false);
						for (Database.SaveResult saveResult : saveResults)
						{
							if (saveResult.isSuccess() == true)
							{
								// Successfully inserted contact
								// do something 
							}
							else
							{
								// Failed
								for(Database.Error error : saveResult.getErrors())
								{
									System.debug('Something went wrong with the record ID ' + saveResult.getId() + ' : ' + error.getStatusCode() + ' - ' + error.getMessage());
									cscrm__Site__c resultAcrel = [Select Id, Secondary_Contact__r.UUID__c, cscrm__Account__c, cscrm__Installation_Address__c From cscrm__Site__c WHERE Id=:saveResult.getId() Limit 1];
									Merge_Request__c  mr = [Select Id from Merge_Request__c where Source_Id__c=:resultAcrel.Secondary_Contact__r.UUID__c ];
									mr.Status__c = 'Failed';
									mr.Error_Message__c =error.getMessage();
									update mr;
									return false;
									
								}
							}
						}
					}
								   
					
					
					for(Merge_Request__c cm:validatedRecord)
					{
						system.debug('mergeRequest+='+mergeRequest);
						system.debug('cm+='+cm);
					   if (cm.Target_Id__c != NULL)
					   {
							Database.MergeResult mergeresult = Database.merge(mergeMap.get(cm.Target_Id__c),mergeMap.get(cm.Source_Id__c), false);
							System.debug('mergeresult<<<'+mergeresult);
							if (mergeresult.isSuccess()) 
							{   
								 // Get the master ID from the result and validate it
								System.debug('Master record ID: ' + mergeresult.getId());
															
								// Get the IDs of the merged records and display them
								List<Id> mergedIds = mergeresult.getMergedRecordIds();
								System.debug('IDs of merged records: ' + mergedIds);  
								System.debug('Reparented record ID: ' + mergeresult.getUpdatedRelatedIds());
							
								cm.Status__c ='Success';
							}
							else
							{
								Database.Error error = mergeresult.getErrors().get(0);
								cm.Status__c ='Failed';
								cm.Error_Code__c='';
								cm.Error_Message__c=error.getMessage();
							}               
						}
					} 
					
					/*if(insContactRel.Size()>0)
					{
						System.debug('ii++' +insContactRel);
						//insert insContactRel;
						List <Database.SaveResult> saveResults = Database.insert(insContactRel, false);
						for (Database.SaveResult saveResult : saveResults)
						{
							if (saveResult.isSuccess() == true)
							{
								// Successfully inserted contact
								// do something 
							}
							else
							{
								// Failed
								for(Database.Error error : saveResult.getErrors())
								{
									System.debug('Something went wrong with the record ID ' + saveResult.getId() + ' : ' + error.getStatusCode() + ' - ' + error.getMessage());
									AccountContactRelation resultAcrel = [SELECT Id,Contact.UUID__c,AccountId FROM AccountContactRelation WHERE Id=:saveResult.getId() Limit 1];
									Merge_Request__c  mr = [Select Id from Merge_Request__c where Source_Id__c=:resultAcrel.Contact.UUID__c ];
									mr.Status__c = 'Failed';
									mr.Error_Message__c =error.getMessage();
									update mr;
									return false;
									
								}
							}
						}
					}*/
                    
                    if(insContactRel.Size()>0)
					{
						System.debug('ii++' +insContactRel);
						//insert insContactRel;
						List <Database.SaveResult> saveResults = Database.insert(insContactRel, false);
						for (Integer i = 0; i < insContactRel.size(); i++) {
                        Database.SaveResult s = saveResults[i];
                        AccountContactRelation origRecord = insContactRel[i];
                        if (!s.isSuccess()) {
                            Contact targetcon = [SELECT Id,UUID__c from COntact WHERE Id=:origRecord.ContactId Limit 1];

                           // AccountContactRelation resultAcrel = [SELECT Id,Contact.UUID__c,AccountId FROM AccountContactRelation WHERE Id=:origRecord.Id Limit 1];
							system.debug('test'+targetcon);
                            system.debug('test'+targetcon.UUID__c);
                            Merge_Request__c  mr = [Select Id from Merge_Request__c where Target_Id__c=:targetcon.UUID__c ];
							mr.Status__c = 'Failed';
							mr.Error_Message__c =s.getErrors()[0].getMessage();
							update mr;
							return false;
                         } 
                        
					}
						
					}
					update mergeRequest;
				}
                return result;
            }
            
               Private map<String,Contact> querySourceRecords(list<Merge_Request__c> mergeRecords){
                Map<String, Contact> sourceMap =  new Map<String, Contact>();
                List<contact> conlist = new List<contact>();
                Set<String> SourceID =new Set<String>();
                for(Merge_Request__c cusrec : mergeRecords){
                     SourceID.add(cusrec.Source_Id__c);
                }
                System.debug('SourceID>>>'+SourceID);
                   
                for(Contact con:[SELECT id ,Merge_Status__c,UUID__c,ReferenceMessage__c,(Select id, EndDate,ContactId, IsDirect,AccountId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations),  (Select Id,Secondary_Contact__c,cscrm__Account__c,cscrm__Installation_Address__c From Sites__r) FROM Contact WHERE UUID__c IN: SourceID])
                {	system.debug('in the query');
                    sourceMap.put(con.UUID__c,con);
					if(con.Merge_Status__c == 'PENDING' || con.Merge_Status__c =='In Progress	'){
                        con.ReferenceMessage__c=  'Source will be merged with Target Contact Id';
                        conlist.add(con);
                    }
   				 }
                 update conlist;
                System.debug('Source Map>>>'+sourceMap);
                return sourceMap;
            }
            
            Private map<String,Contact> queryTargetRecords(list<Merge_Request__c> mergeRecords){
                Map<String, Contact> targetMap =  new Map<String, Contact>();
                Set<String> targetID =new Set<String>();
                for(Merge_Request__c cusrec : mergeRecords){
                    targetID.add(cusrec.Target_Id__c);
                }
                
                for(Contact con:[SELECT id ,UUID__c,(Select id, EndDate,ContactId, IsDirect,AccountId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations),  (Select Id,Secondary_Contact__c,cscrm__Account__c,cscrm__Installation_Address__c From Sites__r)   FROM Contact WHERE UUID__c IN: targetID]){
                    targetMap.put(con.UUID__c,con);
                }
                
                
                return targetMap;
            }
            
            public void lockRecords(List<Merge_Request__c> mergeRecords)
            {
                List<String> SourceIds=new List<String>();
                 for(Merge_Request__c mr: mergeRecords)
                 {
                    SourceIds.add(mr.Source_Id__c);
                   
                 }
                list<Contact> conList =  new list<Contact>();
                for(Contact con: [Select UUID__c,Id,Merge_Lock__c From Contact where UUID__c = :SourceIds]){
                    if(con.Merge_Lock__c == false){
                        con.Merge_Lock__c = true;
                        conList.add(con);
                    }
                }
                update conList;
                
            }
            
            public static void unlockRecords(List<Merge_Request__c> mergeRecords)
            {
                
            }
            
            Private List<Merge_Request__c> validateMergeRecords(list<Merge_Request__c> mergeRecords){
                 System.debug(' Inside validation>>'+mergeRecords);
                 List<String> SourceIds=new List<String>();
                 for(Merge_Request__c mr: mergeRecords)
                 {
                     
                    SourceIds.add(mr.Source_Id__c);
                    SourceIds.add(mr.Target_Id__c);
                 }
                map<String, Contact> UUIDtoContact = new map<String, Contact>();
                for(Contact con: [Select UUID__c,Id From Contact where UUID__c = :SourceIds ] )
                {
                    UUIDtoContact.put(con.UUID__c,con);
                }
                System.debug(' Available Contact with matching UUIDs Total Count is :'+UUIDtoContact.size());
                System.debug(' Available Contact in UUIDtoContact  :'+UUIDtoContact);
                list<Merge_Request__c> updatedRecord =  new list<Merge_Request__c>();
                list<Merge_Request__c> validatedRecord =  new list<Merge_Request__c>();
                list<Merge_Request__c> lockSourcerec =  new list<Merge_Request__c>();
				map<String , list<Merge_Request__c>> targetMissing =  new map<String , list<Merge_Request__c>>();
                for(Merge_Request__c mr : mergeRecords){
                    if( !UUIDtoContact.containsKey(mr.Source_Id__c)){
                         mr.Status__c='FAILED';
                         mr.Error_Message__c='SOURCE CONTACT DOES NOT EXIST IN SFDC';
                         mr.Error_Code__c='0501'; 
                         updatedRecord.add(mr);
                         // lockSourcerec.add(mr);
                    } else if(!UUIDtoContact.containsKey(mr.Target_Id__c)){
                        if(targetMissing.containsKey(mr.Target_Id__c)){
                           targetMissing.get(mr.Target_Id__c). add(mr);
                          
                        }else{
                             targetMissing.put(mr.Target_Id__c, new List<Merge_Request__c>{mr});
                        }
                       
                    } else{
                        validatedRecord.add(mr);
                    }
                    
                }
                System.debug(' Target Missing Total Count is :'+targetMissing.size());
                
				if(targetMissing.size() > 0){
                     system.debug('Retriving targetMissing==='+targetMissing);
                    
                    Map<String,Contact> savedcontacts = retrieveMissingRecord(targetMissing);
                        system.debug('Completed Retriving targetMissing and savedcontacts size :'+savedcontacts.size());
                        system.debug('savedcontacts are :'+savedcontacts);

					for(String key: savedcontacts.keySet()){
						if(savedcontacts.get(key)!= null && savedcontacts.get(key).UUID__c != null){
							validatedRecord.addAll(targetMissing.get(key));
						}else{
							lockSourcerec.addAll(targetMissing.get(key));
						}
					}
                }
				
				if(updatedRecord.size() > 0)
                update updatedRecord;
                
                if(lockSourcerec.size() > 0){
                    lockRecords(lockSourcerec);
                }
                return validatedRecord;
            }
   			//Fix for Production issue P2OB-11879     Seprating Callout and DML to avoid system.calloutException     
            public  Map<String,Contact> retrieveMissingRecord(Map<String,list<Merge_Request__c>> targetmissing){
				Map<String,Contact> returnContacts = new Map<String,Contact>();
				Boolean CalloutComplete = retrieveMissingRecordCallout(targetmissing);
                // Generating an Application Logs for all the callouts
                if(applicationLogRecords.size()>0){
                    insert applicationLogRecords;
                }
                // Process all the callouts
                if(mergeRequestCalloutException.size()==0){
	                returnContacts = processRetrievedRecords(targetmissing);                  
                }else{
                    update mergeRequestCalloutException;
                }

                return returnContacts;
				
            }
		   /*  This method will retrive missing Target from TCM by doing Only Callout for each UUID.
			   It will store each Request and Response in targetMissingRequest and targetMissingResponse Respectively
			*/
           public  Boolean retrieveMissingRecordCallout(Map<String,list<Merge_Request__c>> targetmissing){

                System.debug('!@#$% Starting Callout process to retrive Target Missing UUID Details from TCM');
              
				for(String key: targetmissing.keySet()){
                System.debug('!@#$% Callout process started for UUID : ' + key);
                System.debug('!@#$% Total Merge Request Records for current UUID : ' + targetmissing.get(key).size());
                    for(Merge_Request__c mergeRecord : targetmissing.get(key)){
                                Http h = new Http();
                                HttpRequest req = new HttpRequest();
                                HttpResponse res = new HttpResponse();                             
                        try{

                             if(!targetMissingRequest.containsKey(key)){
                        		params = '/'+key;
                                params = params + '?include=customer-accounts&limit='+upper_limit+'&offset='+offset;
                                String token = TCMApiHelper.getTCMContactToken();
                                String url = EnvironmentVariable.get('tcm_contactEndpoint');
				      
                                System.debug('!@#$% @param url : ' + url+params);
                                System.debug('!@#$% @param token : ' + token);

                                // Set endpoint & method
                                req.setEndpoint(url+params);
                                req.setMethod('GET');
                                req.setTimeout(120000);
                                //Set Certificate
                                 if(Certificate_name != null){
                                  req.setClientCertificateName(Certificate_name);
                                }
                                // Set headers
                                req.setHeader('Authorization', 'Bearer ' + token);
                                req.setHeader('Content-Type', 'application/json');
                               
                                System.debug('!@#$% Request : ' + req);
                                
                                    res = h.send(req);
                        
                                    System.debug('!@#$% Response : ' + res);
                                    System.debug('!@#$% Response Body : ' + res.getBody());
                        
                                    
                                    // Doing Callout again to verify Token is expireded and due to that Callout Failed                        
                                    if(res.getStatusCode() == 401) {
                                        token = TCMApiHelper.getToken();
                                        req.setHeader('Authorization', 'Bearer ' + token);
                                        res = h.send(req);
                                        if(token != null && token != '') {
                                            EnvironmentVariable.put('tcm_access_token', token);
                                        }

                                    }
                                    
                                    /*Saving The Request and Response.so that it can be processed Later 
									to avoid System.CalloutException*/
                                        if(res.getStatusCode() == 200){
                                            system.debug('You are here error code 200 :'+key);
                                            applicationLogRecords.add(generateApplicationLog(key,req,res,'SUCCESS'));
                                
                                        } else{
                                            applicationLogRecords.add(generateApplicationLog(key,req,res,'FAILED'));
    
                                        }
                                 
                                        targetMissingRequest.put(key,req);
                                        targetMissingResponse.put(Key,res);
                                      
                                    }
                                    

                                } catch (Exception e){
                                    system.debug('you need to check for this exception');
                                	Logger2 logger = Logger2.getLogger('TCMInterface');
                                    logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                                    logger.exitLogger();
                                    // For unknown exception for callout
                                  	  mergeRecord.Status__c='FAILED';
                                      mergeRecord.Error_Message__c ='Exception while Callout for Retriving Target from TCM';
                                      mergeRequestCalloutException.add(mergeRecord);
                                    
                                }

                    }
                }
               system.debug('Callout for all the Target Missing UUID completed and Response stored in Global Variable');
               system.debug('Total Callout Request is :'+targetMissingRequest.size());
               system.debug('Total Callout Response is :'+targetMissingResponse.size());
               system.debug('Total Exception During Callout request is :'+mergeRequestCalloutException.size());
              return true;
				
            }
		   /*  This method will process Target Missing Callout Request and Response stored inside 
			   targetMissingRequest and targetMissingResponse Respectively
			*/
           public  Map<String,Contact> processRetrievedRecords(Map<String,list<Merge_Request__c>> targetmissing){
				Map<String,Contact> returnContacts = new Map<String,Contact>();
                list<Merge_Request__c> updateMerge =  new list<Merge_Request__c>();
               
                list<Exception__c> exceptionRecords =  new list<Exception__c>();
                map<String, ContactObject> contactInsert =  new map<String, ContactObject>();
                system.debug('Processing of Each Request and Response is started now');
				for(String key: targetmissing.keySet()){
                    for(Merge_Request__c mergeRecord : targetmissing.get(key)){
                                
                                //Logger2 logger = Logger2.getLogger('TCMInterface');
                                HttpRequest req = targetMissingRequest.get(key);
                                HttpResponse res= targetMissingResponse.get(key);
                        		
                                if(res.getStatusCode() == 200){
                                   	system.debug('You are here error code 200 :'+key);
                                    //logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
                                    applicationLogRecords.add(generateApplicationLog(key,req,res,'SUCCESS'));
                            
                                } else{
                                    //logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
                                    applicationLogRecords.add(generateApplicationLog(key,req,res,'FAILED'));

                                }
                        
                        /// Processing of Target Missing Callout Response started
					   String body = res.getBody();
					   System.debug('!@#$% HTTP Response Body : ' + body);
					   result = body;
					   JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(result, JSON2TCMCustomerContactObject.ErrorMessage.class);    
			
					   set<String> TechErrorCodes =  new set<String>{'WS0001','WS0002','FUNC-MAP-0003','FUNC-MAP-0002','FUNC-DAT-0111','GEN-0001'};
					   set<String> FuncErrorCodes =  new set<String>{'BTC0016','BTC0017','BTC0018','BTC0019','BTC0036','BTC0119','BTC0120','BTC0121'};
					   if(errorcodeobj.code != null){
					   	system.debug('errorcodeobj=='+errorcodeobj);
					 
						if(TechErrorCodes.contains(errorcodeobj.code)){
                               if(mergeRecord.Status__c!='FAILED RETRY'){
                                mergeRecord.Status__c='FAILED RETRY';
                               }else{
                                mergeRecord.Status__c='FAILED';
                               }
                              mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                              updateMerge.add(mergeRecord);
                          
                               Exception__c e = new Exception__c();
                               e.Status__c = 'Unresolved';
                               e.Fault_Code__c = errorcodeobj.code;
                               e.Fault_String__c = errorcodeobj.message;
                               e.Fault_String__c = errorcodeobj.message;
                               e.Fault_Actor__c = 'TCMCustomerSearch';
                               exceptionRecords.add(e);
						}
						else if(FuncErrorCodes.contains(errorcodeobj.code)){
						  mergeRecord.Status__c='FAILED';
						  mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
						  updateMerge.add(mergeRecord);
                         }
                           
                       else{
                              mergeRecord.Status__c='FAILED';
						  	 mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
						     updateMerge.add(mergeRecord);
                         }

						//update mergeRecord;
						//return null;
				  } else{
				  
				  ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class);
				  System.debug('contacts11++==' +contacts);              
					// ContactObject contacts = (ContactObject)JSON.deserialize(result, ContactObject.class);
				  ContactObject contactobj =  new ContactObject() ; 
				  contactobj = contacts;
				  //System.debug('contactobj===='+contactobj); 
				  //System.debug('!@#$% Converted Object : ' + contacts);
				   
				 
				  if(contacts != null && contacts.data != null){
					 contactList = contacts.data.contacts;
					 System.debug('first>>');
					 contactInsert.put(key,contactobj);
					 //Contact con =  insertContact(contacts,mergeRecord);
				 }else{
                 	mergeRecord.Status__c='FAILED';
					mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
					updateMerge.add(mergeRecord);
                  }
                }	
				}
				}
               	system.debug('ProcessRetrievedRecords Update contactInsert.size() :'+contactInsert.size());
                if(contactInsert.size() > 0){
					returnContacts = insertContact(contactInsert,targetmissing);
                }
               	system.debug('ProcessRetrievedRecords Update updateMerge.size() :'+updateMerge.size());
                if(updateMerge.size() > 0){
                    update updateMerge;
                }
               	system.debug('ProcessRetrievedRecords Update exceptionRecord.size() :'+exceptionRecords.size());
                if(exceptionRecords.size() > 0){
                    Insert exceptionRecords;
                }                
               return returnContacts;
				
            }
   			//Fix for Production issue P2OB-11879     Seprating Callout and DML to avoid system.calloutException     		
            public ApplicationLog__c generateApplicationLog(String uuid,HttpRequest req,HttpResponse res,String reason){
                

            String errorCode = '';
            String response = res.getBody();
            String request = req.getBody();
            String truncatedResponse = response;
            String truncatedRequest = request;
                if(reason != 'SUCCESS'){
            			 errorCode = res.getStatus()+': '+res.getStatusCode() ;                
                }
            String statusCode = String.valueOf(res.getStatusCode()) ;

            if(response.length() > 131070){
                truncatedResponse = truncatedResponse.substring(0, 131070); 
            }
            if(request.length() > 131070){
                truncatedRequest = truncatedRequest.substring(0, 131070); 
            } 

            ApplicationLog__c appLog = new ApplicationLog__c(Reference_Info__c = 'TCMInterface', 
                                                             Debug_Level__c = 'Integration',  
                                                             Request_Message__c = truncatedRequest,
                                                             Message__c = truncatedResponse, 
                                                             Error_Code__c = errorCode,
                                                             Timer__c = System.now(),
                                                             User__c=UserInfo.getUserId(),
                                                             Http_Code__c = statusCode,
                                                             UUID__c = uuid);
                
            return appLog;
            }
            public  Map<String,Contact> insertContact(Map<String, ContactObject> contactInsert, Map<String,list<Merge_Request__c>> targetmissing)
            {  
				Map<String,Contact> returnList =  new Map<String,Contact>();
				List<Contact> conList =  new List<Contact>();
				for(String key : contactInsert.keySet()){
					list<ContactObject.Contact> con =  contactInsert.get(key).data.contacts;
					for(ContactObject.Contact contacts : con){
						Contact c = new Contact();
                          c.Salutation = contacts.title;
						  c.FirstName = contacts.firstName;
						  c.LastName = contacts.LastName;
						  c.MiddleName = contacts.middleName;
						  c.UUID__c = contacts.id;
						  if(contacts.birthDate != null && contacts.birthDate != ''){
							  c.Birthdate = Date.valueOf(contacts.birthDate);    
						 }
						 c.Contact_Status__c = contacts.status;
						 list<ContactObject.CustomerAccount> custacc = contacts.customerAccounts;
                         c.AccountId = findAccountByUUID(custacc[0].accountUuid);
                        system.debug('testacc'+c.AccountId);
						 c.Imported__c = true;
						 c.Home_Email__c = contacts.homeContact.emailAddress;
						 c.Home_Fax__c = contacts.homeContact.faxNumber;
						 c.HomePhone__c = contacts.homeContact.phoneNumber;
						 c.Mobile_Phone_Number__c = contacts.homeContact.mobileNumber;
						 c.HomePhone__c = contacts.homeContact.phoneNumber;
						 c.HomePhone__c = contacts.homeContact.phoneNumber;
						 conList.add(c);
					}
				}
				
				
				if(conList.size() > 0){
					List <Database.SaveResult> saveResults = Database.insert(conList, false);
					for (Integer i = 0; i < conList.size(); i++) {
                        Database.SaveResult s = saveResults[i];
                        Contact origRecord = conList[i];
                        if (!s.isSuccess()) {
                            system.debug('saveResult.getErrors()=='+s.getErrors());
                            system.debug(s.getId()); // I get null here
                            system.debug(origRecord.UUID__c); //This should be the Id you're looking for
                            list<Merge_Request__c> mr = targetmissing.get(origRecord.UUID__c);
                          	for(Merge_Request__c rec : mr){
                              rec.Status__c = 'Failed';
                              rec.Error_Message__c =s.getErrors()[0].getMessage();
                              update rec;
                          	}
                            returnList.put(origRecord.UUID__c,null);
                         } 
                        else{
                            system.debug(origRecord.UUID__c);
                            system.debug('saveResult.getErrors()=='+s);
                            returnList.put(origRecord.UUID__c,origRecord);
                        }
					}
					}
					system.debug('returnList=='+returnList);
            		return returnList;
			}
    
    		private static Id findAccountByUUID(String accountUUID) {
                System.debug('!@#$% Querying for account using Account UUID : ' + accountUUID);
                Account accountObject = null;
                try{
                    accountObject = [SELECT Id, Name FROM Account WHERE Account_UUID__c = :accountUUID LIMIT 1][0];            
                    return accountObject.Id;
                } catch(Exception e){
                    return null;
                }
            }
        
        
}
public without sharing class CustomerMerge implements RecordMerge {
            public CustomerObject.Customer selectedCustomer;
            public JSON2TCMCustomerContactObject customerContact;
            public String params{get;set;}
            public String result {get;set;}    
            List<Merge_Request__c> mergeRequest = new List<Merge_Request__c>();
            public CustomerMerge(Merge_Request__c mergeRecords){
                mergeRequest.add(mergeRecords);
            }
            public CustomerMerge(list<Merge_Request__c> mergeRecords){
                mergeRequest = mergeRecords;
            }
            public CustomerMerge(){}
            
            public boolean executeMerge(){
                system.debug('1st mergeRequest=='+mergeRequest);
                list<Merge_Request__c> validatedRecord = validateMergeRecords(mergeRequest); 
                system.debug('validationerror=='+validatedRecord);
                boolean result =  false;
                boolean redundantACRDeleted =  True;
                
         
                if(validatedRecord.size() > 0){
                    map<String,Account> sourceRecords =  querySourceRecords(validatedRecord);
                    map<String,Account> targetRecords =  queryTargetRecords(validatedRecord);
                    Map<String,Account> mergeMap = new Map<String,Account>();
                    Id targConId;
                    // Account Merge Issue P2OB-13763 , This will remove common ACR between Source and Target
                    
                    // Create a savepoint before removing redundant ACR
					Savepoint sp = Database.setSavepoint();
                    redundantACRDeleted = removeRedundantRelationships(sourceRecords,targetRecords,validatedRecord);
                    if(!redundantACRDeleted){
                        // Rollback to the previous before remove redundant Relationship state
						Database.rollback(sp);
                    }
                    for(Account aact:[SELECT ShippingStreet, Id, Name, Type, ParentId, UCIDN__c, CIDN__c, ABN__c, Legacy_ROU__c, Customer_Trading_Name__c, Legacy_SOU__c, ABN_Status__c, ABN_Type__c, ACN__c, Account_UUID__c, Customer_ID__c, Customer_Effective_Start_Date__c, Email__c, End_Date__c, Error_description__c, FraudFlag__c, Imported__c, Managed__c, Parent_CIDN__c, Primary__c, PriorityAssist__c, Protect__c, SOU__c, Start_Date__c, TCM_MasterID__c,Trading_As_Names__c, Ultimate_CIDN__c, Ultimate_Parent_CIDN__c, birthDate__c, Merge_Lock__c FROM Account WHERE CIDN__c IN:sourceRecords.Keyset() or CIDN__c IN:targetRecords.Keyset() ])
                    {    
                        mergeMap.put(aact.CIDN__c,aact);
                    } 
                    
                    for(Merge_Request__c cm: validatedRecord)
                    {
                        
                        Database.MergeResult mergeresult = Database.merge(mergeMap.get(cm.Target_Id__c),mergeMap.get(cm.Source_Id__c), false);
                        //for(Database.MergeResult res : mergeresult) {
                            if (mergeresult.isSuccess()) {
                                 cm.Status__c ='Success';
                            }
                            else{
                                   Database.Error error = mergeresult.getErrors().get(0);
                                   cm.Status__c ='Failed';
                                   cm.Error_Code__c='';
                                   cm.Error_Message__c=error.getMessage();
                                   
                            }
                        //}
                                    
                     }  
                    update mergeRequest;
                }
                return result;
            }
            
               Private map<String,Account> querySourceRecords(list<Merge_Request__c> mergeRecords){
                Map<String, Account> sourceMap =  new Map<String, Account>();
                List<Account> acclist = new List<Account>();
                Set<String> SourceID =new Set<String>();
                for(Merge_Request__c cusrec : mergeRecords){
                    SourceID.add(cusrec.Source_Id__c);
                }
                System.debug('SourceID>>>'+SourceID);
                   
                for(Account acc:[SELECT id ,CIDN__c,TCM_Merge_Status__c,ReferenceMessage__c,(Select id, EndDate,AccountId, IsDirect,ContactId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations), (Select Id, cscrm__Account__c, cscrm__Address__c, cscrm__End_Date__c, NBN_Status__c, cscrm__Start_Date__c,cscrm__Active__c From cscrm__Account_Address_Relationships__r)  FROM Account WHERE CIDN__c IN: SourceID]){
                    sourceMap.put(acc.CIDN__c,acc);
                    if(acc.TCM_Merge_Status__c == 'PENDING' || acc.TCM_Merge_Status__c =='In Progress   '){
                        acc.ReferenceMessage__c=  'Source will be merged with Target Contact Id';
                        acclist.add(acc);
                    }
                }
                update acclist;
                System.debug('Source Map>>>'+sourceMap);
                return sourceMap;
            }
            
            Private map<String,Account> queryTargetRecords(list<Merge_Request__c> mergeRecords){
                Map<String, Account> targetMap =  new Map<String, Account>();
                Set<String> targetID =new Set<String>();
                for(Merge_Request__c cusrec : mergeRecords){
                    targetID.add(cusrec.Target_Id__c);
                }
                
                for(Account acc:[SELECT id ,CIDN__c,(Select id, EndDate,AccountId, IsDirect,ContactId,Contact_Type__c,Contact_Usage__c,InActive__c,Relationship_End_Date__c from AccountContactRelations), (Select Id, cscrm__Account__c, cscrm__Address__c, cscrm__End_Date__c, NBN_Status__c, cscrm__Start_Date__c,cscrm__Active__c From cscrm__Account_Address_Relationships__r)  FROM Account WHERE CIDN__c IN: targetID]){
                    targetMap.put(acc.CIDN__c,acc);
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
                list<Account> accList =  new list<Account>();
                for(Account acc: [Select CIDN__c,Id,Name,Merge_Lock__c From Account where CIDN__c = :SourceIds]){
                    if(acc.Merge_Lock__c == false){
                        acc.Merge_Lock__c = true;
                        accList.add(acc);
                    }
                }
                update accList;
                
                
            }
            
            private void unlockRecords(List<Merge_Request__c> mergeRecords)
            {
                
            }
            
            Private List<Merge_Request__c> validateMergeRecords(list<Merge_Request__c> mergeRecords){
                 System.debug(' In validation>>');
                 List<String> SourceIds=new List<String>();
                 for(Merge_Request__c mr: mergeRecords)
                 {
                    SourceIds.add(mr.Source_Id__c);
                    SourceIds.add(mr.Target_Id__c);
                 }
                map<String, Account> CIDNtoAccount = new map<String, Account>();
                for(Account acc: [Select CIDN__c,Id,Name From Account where CIDN__c = :SourceIds] ){
                    CIDNtoAccount.put(acc.CIDN__c,acc);
                }
                list<Merge_Request__c> updatedRecord =  new list<Merge_Request__c>();
                list<Merge_Request__c> validatedRecord =  new list<Merge_Request__c>();
                list<Merge_Request__c> lockSourcerec =  new list<Merge_Request__c>();
                map<String , list<Merge_Request__c>> targetMissing =  new map<String , list<Merge_Request__c>>();
                for(Merge_Request__c mr : mergeRecords){
                    if( !CIDNtoAccount.containsKey(mr.Source_Id__c)){
                         mr.Status__c='FAILED';
                         mr.Error_Message__c='SOURCE CUSTOMER ACCOUNT DOES NOT EXIST IN SFDC';
                         mr.Error_Code__c='0366'; 
                         updatedRecord.add(mr);
                         //lockSourcerec.add(mr);
                    } else if(!CIDNtoAccount.containsKey(mr.Target_Id__c)){
                         if(targetMissing.containsKey(mr.Target_Id__c)){
                           targetMissing.get(mr.Target_Id__c). add(mr);
                          
                        }else{
                             targetMissing.put(mr.Target_Id__c, new List<Merge_Request__c>{mr});
                        }
                    } else{
                        validatedRecord.add(mr);
                    }
                }
                 if(targetMissing.size() > 0){
                     system.debug('targetMissing==='+targetMissing);
                    Map<String,Account> savedAccs = retrieveMissingRecordss(targetMissing);
                        system.debug('savedAccs==='+savedAccs);
                    for(String key: savedAccs.keySet()){
                        if(savedAccs.get(key)!= null && savedAccs.get(key).CIDN__c != null){
                            validatedRecord.addAll(targetMissing.get(key));
                        }else{
                            lockSourcerec.addAll(targetMissing.get(key));
                        }
                    }
                }
                system.debug('validatedRecord==='+validatedRecord);
                if(updatedRecord.size() > 0)
                update updatedRecord;
                
                if(lockSourcerec.size() > 0){
                    lockRecords(lockSourcerec);
                }
                
                return validatedRecord;
            }
            
           
            public Map<String,Account> retrieveMissingRecordss(Map<String,list<Merge_Request__c>> targetmissing ){
                Map<String,Account> returnAccounts = new Map<String,Account>();
                list<Merge_Request__c> updateMerge =  new list<Merge_Request__c>();
                map<String, CustomerObject.Customer> acountInsert =  new map<String, CustomerObject.Customer>();
                map<String,JSON2TCMCustomerContactObject> contactinsert = new map<String,JSON2TCMCustomerContactObject>();
                  for(String key: targetmissing.keySet()){
                    for(Merge_Request__c mergeRecord : targetmissing.get(key)){
                        String masterId ;
                        params ='?cidn='+key;
                        CustomerObject.Customer selectedCustomer;
                        JSON2TCMCustomerContactObject customerContact;
                        //Calling to TCM to get Customer Details
                        String callresult= doCalloutss(true,params);
                        system.debug('result==='+callresult);
                        JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(callresult, JSON2TCMCustomerContactObject.ErrorMessage.class);    
                
                        system.debug('errorcodeobj=='+errorcodeobj);
                        set<String> TechErrorCodes =  new set<String>{'WS0001','WS0002','FUNC-MAP-0003','FUNC-MAP-0002','FUNC-DAT-0111','GEN-0001'};
                        set<String> FuncErrorCodes =  new set<String>{'BTC0016','BTC0017','BTC0018','BTC0019','BTC0036','BTC0119','BTC0120','BTC0121'};
                        if(errorcodeobj.code != null){
                         
                          if(TechErrorCodes.contains(errorcodeobj.code)){
                             if(mergeRecord.Status__c!= 'FAILED RETRY'){
                                 mergeRecord.Status__c='FAILED RETRY';
                                  mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                             } else{
                                 mergeRecord.Status__c='FAILED';
                                  mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                             }
                              //update mergeRecord;
                              updateMerge.add(mergeRecord);
                          }
                          else if(FuncErrorCodes.contains(errorcodeobj.code)){
                              mergeRecord.Status__c='FAILED';
                               mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                               //update mergeRecord;
                               updateMerge.add(mergeRecord);
                          } else{
                              mergeRecord.Status__c='FAILED';
                             mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                             updateMerge.add(mergeRecord);
                         }
                             
                         
                        }
                        else{
                        CustomerObject convertedObj = (CustomerObject)JSON.deserialize(callresult, CustomerObject.class); 
                        system.debug('convertedObj==='+convertedObj);
                        if(convertedObj != null && convertedObj.data != null && convertedObj.data.customers != null){
                             system.debug('convertedObj.data.customers=='+convertedObj.data.customers);
                            for(CustomerObject.Customer cust : convertedObj.data.customers){
                                system.debug('cust=='+cust);
                                if(cust.customerAccount != null){
                                    masterId = cust.masterID;
                                    selectedCustomer = cust;
                                    system.debug('acountInsert=='+acountInsert);
                                    acountInsert.put(key,selectedCustomer);
                                }
                            }
                        } else{
                              mergeRecord.Status__c='FAILED';
                             mergeRecord.Error_Message__c ='RETRIEVE TARGET FAILED IN SFDC';
                             updateMerge.add(mergeRecord);
                         }
                        
                        if(masterId != null && masterId != ''){
                            system.debug('masterId=='+masterId);
                             String masterParams = '/'+masterId + '?include=contacts';
                             String conresult= doCalloutss(true,masterParams);
                            
                             JSON2TCMCustomerContactObject customerContactdata = (JSON2TCMCustomerContactObject)JSON.deserialize(conresult, JSON2TCMCustomerContactObject.class); 
                             customerContact = customerContactdata;
							 contactinsert.put(key,customerContact);
                            system.debug('customerContact=='+customerContact);
                                
                        }
                        
                        }
                    }
                
                }
                system.debug('updateMerge==='+updateMerge);
                system.debug('acountInsert==='+acountInsert);
                 system.debug('acountInsert==='+contactinsert);
                if(acountInsert.size() > 0){
                    system.debug('acountInsert===='+acountInsert);
                    returnAccounts = insertAccountNContact(acountInsert,targetmissing, contactinsert);
                }
                if(updateMerge.size() > 0){
                    update updateMerge;
                }
                return returnAccounts;
            }
           
            
            public String doCalloutss(Boolean appendParams, String params){
                System.debug('!@#$% Attempting to do a callout to TCM');
                Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
                Boolean calloutUnsuccesful = false;
                String token = TCMSearchManager.getTCMToken();
                system.debug('i am failing here after Token'+ token);
                String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
                String url;
                
                Integer offset;
                IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
                if(is.EnableMocks__c){
                    url = MOCK_URL;
                }
                else 
                {
                    url = EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
                    system.debug('i am failing here in URL'+ url);
                }
                
                if(offset == null)
                {
                    offset = 0;
                }
                
                if(appendParams) 
                {
                    params = params + '&limit='+upper_limit+'&offset='+offset;
                }
                else 
                {
                    params = params + '?limit='+upper_limit+'&offset='+offset;
                }
                
                HttpResponse resp = TCMSearchService.callout(url+params, token);
                System.debug('===+++resp'+resp);    
                String body = resp.getBody();
                //this.result =  body;
                System.debug('!@#$% HTTP Response Body : ' + body);
                return body;
               
            }
            
            
            
        public Map<String,Account> insertAccountNContact(Map<String, CustomerObject.Customer> acountInsert, Map<String,list<Merge_Request__c>> targetmissing, map<String,JSON2TCMCustomerContactObject> contactInsert){
                 Map<String, Account> accInsertList = new Map<String, Account>();
				 Map<String,Account> returnList =  new Map<String,Account>();
                 List<Account> accList =  new List<Account>();
				 List<Contact> conList =  new List<Contact>();
				 Map<String , Contact> conMap = new Map<String, Contact>();
				 
            	system.debug('acountInsert in insertAccountNContact==='+acountInsert);
            system.debug('acountInsert in insertAccountNContact==='+contactInsert);
            system.debug('targetmissing in insertAccountNContact==='+targetmissing);
            	TCMGetCustomer getCustomerObj = new TCMGetCustomer();
            	TCMGetCustomerContact getContactObj = new TCMGetCustomerContact();
                for(String key : acountInsert.keySet()){
                    CustomerObject.Customer selectedCustomer = acountInsert.get(key);
                    Account a = getCustomerObj.getAccount(selectedCustomer);
	                accList.add(a);
                }
                
                if(accList.size() > 0){
                    system.debug('accList=='+accList);
                    List <Database.SaveResult> saveResults = Database.insert(accList, false);
                    for (Integer i = 0; i < accList.size(); i++) {
                        Database.SaveResult s = saveResults[i];
                        system.debug('sss='+s);
                        Account origRecord = accList[i];
                        if (!s.isSuccess()) {
                            system.debug('origRecord='+origRecord);
                            system.debug('saveResult.getErrors()=='+s.getErrors());
                            system.debug(s.getId()); // I get null here
                            system.debug(origRecord.CIDN__c); //This should be the Id you're looking for
                            list<Merge_Request__c> mr = targetmissing.get(origRecord.CIDN__c);
                            for(Merge_Request__c rec : mr){
                              rec.Status__c = 'Failed';
                              rec.Error_Message__c =s.getErrors()[0].getMessage();
                              update rec;
                            }
                            returnList.put(origRecord.CIDN__c,null);
                         } 
                        else{
                            system.debug(origRecord.CIDN__c);
                            system.debug('saveResult.getErrors()=='+s);
                            returnList.put(origRecord.CIDN__c,origRecord);
							JSON2TCMCustomerContactObject customerContact = contactInsert.get(origRecord.CIDN__c);
							system.debug('customerContact+'+customerContact);
							if(customerContact != null && customerContact.data != null && customerContact.data.id != null && customerContact.data.id != ''){
							if(customerContact.data.contacts != null && customerContact.data.contacts.size()>0){
								for(JSON2TCMCustomerContactObject.Contacts contact : customerContact.data.contacts) {   
									// Contact
									Contact c = getContactObj.getContact(contact,s.getId());
									conList.add(c);
								}
							  }	
						   }
                        }
                    }
                    }
					
					if(conList.size() > 0){
						List <Database.SaveResult> saveResults = Database.insert(conList, false);
						for (Integer i = 0; i < conList.size(); i++) {
                        Database.SaveResult s = saveResults[i];
                        system.debug('sss='+s);
                        Contact origRecord = conList[i];
                        if (!s.isSuccess()) {
                            system.debug('origRecord='+origRecord);
                            system.debug('saveResult.getErrors()=='+s.getErrors());
                            system.debug(s.getId()); // I get null here
                            system.debug(origRecord.AccountId); //This should be the Id you're looking for
							Account acc = [Select CIDN__c from Account where Id=:origRecord.AccountId Limit 1];
                            list<Merge_Request__c> mr = targetmissing.get(acc.CIDN__c);
                            for(Merge_Request__c rec : mr){
                              rec.Status__c = 'Failed';
                              rec.Error_Message__c =s.getErrors()[0].getMessage();
                              update rec;
                            }
                            returnList.put(acc.CIDN__c,null);
                         }
						}
					}
                    system.debug('returnList=='+returnList);
                    return returnList;
                }
    		Private Boolean removeRedundantRelationships(map<String,Account> SourceCIDN ,map<String,Account> TargetCIDN,list<Merge_Request__c> validatedRecord){
			
				List<Id> removeACRForContact = new List<Id>();
				Boolean sourceACRUpdateRequired = False;
				List<AccountContactRelation> Delete_ACR = new List<AccountContactRelation>();
				Map<Id,Id> removeSourceDirectRelationship = new Map<Id,Id>();
				
                try{
                        // Get all the conflicted Contact ID and Count of ACR
                        AggregateResult[] groupedResults = [select ContactId,Count(Id)total
                                                            from AccountContactRelation 
                                                            where Account.CIDN__c IN:SourceCIDN.Keyset() or Account.CIDN__c IN:TargetCIDN.Keyset()
                                                            group by ContactId having count(Id) > 1];
						
						// Check if conflicting ACR are present for Merge Account
						if(groupedResults.size() > 0) {
						
									for (AggregateResult ar : groupedResults)  {
											System.debug('Contact ID' + ar.get('ContactId'));
											System.debug('Total Count' + ar.get('total'));
												removeACRForContact.add((Id)ar.get('ContactId'));
											}
										
										
									
									List<AccountContactRelation> All_Source_ACR = [select Id,ContactId,AccountId,IsDirect,Account.CIDN__c
																			from AccountContactRelation
																			where Account.CIDN__c IN:SourceCIDN.Keyset()
																			and ContactId =: removeACRForContact];
																			
									List<AccountContactRelation> All_Target_ACR = [select Id,ContactId,AccountId,IsDirect,Account.CIDN__c
																			from AccountContactRelation
																			where Account.CIDN__c IN:TargetCIDN.Keyset()
																			and ContactId =: removeACRForContact];

                                    for(Merge_Request__c mergeRecord : validatedRecord){
                                        for(AccountContactRelation sourceACR : All_Source_ACR)	{
                                            for(AccountContactRelation targetACR : All_Target_ACR) {
                                                if(sourceACR.ContactId == targetACR.ContactId && mergeRecord.Source_Id__c == sourceACR.Account.CIDN__c && mergeRecord.Target_Id__c == targetACR.Account.CIDN__c){
                                                    if (sourceACR.IsDirect == True && targetACR.IsDirect == False){
                                                        // Change source into indirect relationships by making target as direct and remove source relationships
                                                        removeSourceDirectRelationship.put(sourceACR.ContactId,targetACR.AccountId);
                                                        if(!Delete_ACR.contains(sourceACR)){
                                                                Delete_ACR.add(sourceACR);
                                                        }
                                                        sourceACRUpdateRequired = True;
                                                    }else{
                                                        // Source Has indirect relationships , it can be deleted.
                                                        if(!Delete_ACR.contains(sourceACR)){
                                                                Delete_ACR.add(sourceACR);
                                                        }
                                                    }
                                                }
                                            }
                                    
                                        }
                                    }
									if(sourceACRUpdateRequired){
										List<Contact> updatePrimaryAcc = [Select Id,AccountId
																		From Contact
																		Where Id IN:removeSourceDirectRelationship.keySet()];
										// Make Target in Direct Relationship with Contact
										For(Contact con : updatePrimaryAcc){
											con.AccountId = removeSourceDirectRelationship.get(con.Id);
										}
										update updatePrimaryAcc;
									}
									if(Delete_ACR.size() > 0){
										delete Delete_ACR;
									}
							
						}
                    return True;
                }catch(DmlException e) {
                        System.debug('The following exception has occurred: ' + e.getMessage());
                    return False;
                }
				
				}
            }
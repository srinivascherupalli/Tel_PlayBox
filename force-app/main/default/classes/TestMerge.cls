public class TestMerge implements RecordMerge {
            public CustomerObject.Customer selectedCustomer;
            public JSON2TCMCustomerContactObject customerContact;
            public String params{get;set;}
            public String result {get;set;}    
            List<Merge_Request__c> mergeRequest = new List<Merge_Request__c>();
            public TestMerge(Merge_Request__c mergeRecords){
                mergeRequest.add(mergeRecords);
            }
            public TestMerge(list<Merge_Request__c> mergeRecords){
                mergeRequest = mergeRecords;
            }
            public TestMerge(){}
            
            public boolean executeMerge(){
                list<Merge_Request__c> validatedRecord = validateMergeRecords(mergeRequest); 
                system.debug('validationerror=='+validatedRecord);
                boolean result =  false;
         
                if(validatedRecord.size() > 0){
                    map<String,Account> sourceRecords =  querySourceRecords(validatedRecord);
                    map<String,Account> targetRecords =  queryTargetRecords(validatedRecord);
                    Map<String,Account> mergeMap = new Map<String,Account>();
                    Id targConId;
                    
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
            
            private void lockRecords(List<Merge_Request__c> mergeRecords)
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
                             targetMissing.put(mr.Target_Id__c, new List<Merge_Request__c>{mr} );
                        }
                    } else{
                        validatedRecord.add(mr);
                    }
                }
                 if(targetMissing.size() > 0){
                    retrieveMissingRecordss(targetMissing);
                }
                if(updatedRecord.size() > 0)
                update updatedRecord;
                
                if(lockSourcerec.size() > 0){
                    lockRecords(lockSourcerec);
                }
                
                return validatedRecord;
            }
            
            public Account retrieveMissingRecord(String targetCIDN, Merge_Request__c mergeRecord){
                String masterId ;
                params ='?cidn='+targetCIDN;
                //Calling to TCM to get Customer Details
                doCallout(true,params);
                system.debug('result==='+result);
                JSON2TCMCustomerContactObject.ErrorMessage errorcodeobj = (JSON2TCMCustomerContactObject.ErrorMessage)JSON.deserialize(result, JSON2TCMCustomerContactObject.ErrorMessage.class);    
        
                system.debug('errorcodeobj=='+errorcodeobj);
                set<String> TechErrorCodes =  new set<String>{'WS0001','WS0002','FUNC-MAP-0003','FUNC-MAP-0002','FUNC-DAT-0111','GEN-0001'};
                set<String> FuncErrorCodes =  new set<String>{'BTC0016','BTC0017','BTC0018','BTC0019','BTC0036','BTC0119','BTC0120','BTC0121'};
                if(errorcodeobj.code != null){
                 
                  if(TechErrorCodes.contains(errorcodeobj.code)){
                     if(mergeRecord.Status__c!= 'FAILED RETRY'){
                         mergeRecord.Status__c='FAILED RETRY';
                          mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                     } else{
                         mergeRecord.Status__c='FAILED';
                          mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                     }
                      update mergeRecord;
                  }
                  else if(FuncErrorCodes.contains(errorcodeobj.code)){
                      mergeRecord.Status__c='FAILED';
                       mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                       update mergeRecord;
                  }
                           
                  return null;
                }
                else{
                CustomerObject convertedObj = (CustomerObject)JSON.deserialize(result, CustomerObject.class); 
                system.debug('convertedObj==='+convertedObj);
                if(convertedObj != null && convertedObj.data != null && convertedObj.data.customers != null){
                    for(CustomerObject.Customer cust : convertedObj.data.customers){
                        if(cust.customerAccount != null){
                            masterId = cust.masterID;
                            selectedCustomer = cust;
                            Account acc =  insertAccountNContact(mergeRecord);
                            return acc;
                        }
                    }
                }
                return null;
                }
                return null;
            }
    
            public void retrieveMissingRecordss(Map<String,list<Merge_Request__c>> targetmissing ){
                Map<String,Account> returnAccounts = new Map<String,Account>();
                list<Merge_Request__c> updateMerge =  new list<Merge_Request__c>();
                map<String, CustomerObject.Customer> acountInsert =  new map<String, CustomerObject.Customer>();
                
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
                                  mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                             } else{
                                 mergeRecord.Status__c='FAILED';
                                  mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                             }
                              //update mergeRecord;
                              updateMerge.add(mergeRecord);
                          }
                          else if(FuncErrorCodes.contains(errorcodeobj.code)){
                              mergeRecord.Status__c='FAILED';
                               mergeRecord.Error_Message__c ='Source will be relinked with Target Contact Id';
                               //update mergeRecord;
                               updateMerge.add(mergeRecord);
                          }
                             
                         
                        }
                        else{
                        CustomerObject convertedObj = (CustomerObject)JSON.deserialize(callresult, CustomerObject.class); 
                        system.debug('convertedObj==='+convertedObj);
                        if(convertedObj != null && convertedObj.data != null && convertedObj.data.customers != null){
                            for(CustomerObject.Customer cust : convertedObj.data.customers){
                                if(cust.customerAccount != null){
                                    masterId = cust.masterID;
                                    selectedCustomer = cust;
                                    acountInsert.put(key,selectedCustomer);
                                }
                            }
                        }
                        
                        }
                    }
                
                }
                system.debug('updateMerge==='+updateMerge);
                system.debug('acountInsert==='+acountInsert);
            }
            public void doCallout(Boolean appendParams1, String params1){
                System.debug('!@#$% Attempting to do a callout to TCM');
                Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
                Boolean calloutUnsuccesful = false;
                String token = TCMSearchManager.getTCMToken();
                system.debug('i am failing here after Token'+ token);
                String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
                String url;
                
				Boolean appendParams=appendParams1; 
				String params=params1;
                Integer offset=null;
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
                this.result =  body;
                System.debug('!@#$% HTTP Response Body : ' + body);
               
            }
            
            public String doCalloutss(Boolean appendParams1, String params1){
                System.debug('!@#$% Attempting to do a callout to TCM');
                Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
                Boolean calloutUnsuccesful = false;
                String token = TCMSearchManager.getTCMToken();
                system.debug('i am failing here after Token'+ token);
                String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
                String url;
                
				Boolean appendParams=appendParams1;
				String params=params1;
                Integer offset=null;
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
            
            
            public Account insertAccountNContact(Merge_Request__c mergeRecord){
                
                //Savepoint sp = Database.setSavepoint();
                Account a = new Account();
                a.Name = selectedCustomer.customerAccount.lastName;
                a.ABN__c = selectedCustomer.customerAccount.abn;
                a.ACN__c = selectedCustomer.customerAccount.acn;
                a.Business_Unit__c = selectedCustomer.businessUnit;
                a.Market_Segment__c = selectedCustomer.marketSegment;
                a.Legacy_SOU__c = selectedCustomer.servicingOrgUnit;
                a.CIDN__c = selectedCustomer.cidn;
                a.Type = selectedCustomer.customerType;
                a.Pref_Comm_Method__c = selectedCustomer.customerAccount.preferredMethod;
                a.Language_Preference__c = selectedCustomer.languagePreference;
                a.Customer_Status__c = selectedCustomer.accountStatus;
                a.Customer_ID__c = selectedCustomer.cac;
                a.Account_UUID__c = selectedCustomer.customerAccount.accountUuid;
                a.birthDate__c=selectedCustomer.customerAccount.birthDate;
                a.TCM_MasterID__c = selectedCustomer.masterID;
                if(selectedCustomer.customerManagedFlag != null && selectedCustomer.customerManagedFlag != ''){
                    if(selectedCustomer.customerManagedFlag == 'Y'){
                        a.Managed__c = true;
                    } else {
                        a.Managed__c = false;
                    }
                }
                a.Customer_Last_Verified_Date__c = system.today();
                a.Imported__c = true;
                
                a.Data_Sovereign_Status__c = 'SFDC Integration';
                
                try {
                    insert a;
                    System.debug('!@#$% Account created : ' + a.Id);    
                }catch(DmlException e){
                    String errorMessage = e.getMessage();
                    if(!errorMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
                        if(mergeRecord.Status__c!='FAILED RETRY'){
                                mergeRecord.Status__c='FAILED RETRY';
                            }else{
                                mergeRecord.Status__c='FAILED';
                            }
                        mergeRecord.Error_Message__c='Field Validation Failed In SFDC ';
                        mergeRecord.Error_Code__c='0382';
                                
                        update mergeRecord;
                    }else{
                        if(mergeRecord.Status__c!='FAILED RETRY'){
                                mergeRecord.Status__c='FAILED RETRY';
                            }else{
                                mergeRecord.Status__c='FAILED';
                            }
                        mergeRecord.Error_Message__c='Any problem with a DML statement, such as an insert statement missing a required field on a record. ';
                        mergeRecord.Error_Code__c='0383';
                                
                        update mergeRecord;
                    }
                                
                }
                catch(Exception e) {
                    System.debug('!@#$% Account creation exception !');
            if(mergeRecord.Status__c!='FAILED RETRY'){
                mergeRecord.Status__c='FAILED RETRY';
            }else{
                mergeRecord.Status__c='FAILED';
            }
                
                    mergeRecord.Error_Message__c='Exception occurred while Merging Customer -'+e.getMessage();
                    mergeRecord.Error_Code__c='0387';
                    
                    update mergeRecord; 
                    return null;
                }
                
                if(a.Id != null && customerContact != null && customerContact.data != null && customerContact.data.id != null && customerContact.data.id != ''){
                    if(customerContact.data.contacts != null && customerContact.data.contacts.size()>0){
                        for(JSON2TCMCustomerContactObject.Contacts contact : customerContact.data.contacts) {   
                            // Contact
                            Contact c = new Contact();
                            c.AccountId = a.Id;
                            c.Salutation = contact.title;
                            c.FirstName = contact.firstName;
                            c.LastName = contact.LastName;
                            c.UUID__c = contact.id;
                            if(contact.birthDate != null && contact.birthDate != ''){
                                c.Birthdate = Date.valueOf(contact.birthDate);    
                            }
                            c.Contact_Status__c = 'Active';
                            //c.Contact_Type__c = contact.contactType;
                            c.Imported__c = true;
                            try {
                                insert c; 
                                System.debug('!@#$% Contact created');  
                            }catch(DmlException e){
                                String errorMessage = e.getMessage();
                                if(!errorMessage.contains('FIELD_FILTER_VALIDATION_EXCEPTION')){
                                    if(mergeRecord.Status__c!='FAILED RETRY'){
                                            mergeRecord.Status__c='FAILED RETRY';
                                        }else{
                                            mergeRecord.Status__c='FAILED';
                                        }
                                    mergeRecord.Error_Message__c='Field Validation Failed In SFDC';
                                    mergeRecord.Error_Code__c='0382';
                                
                                    update mergeRecord;
                                }else{
                                    if(mergeRecord.Status__c!='FAILED RETRY'){
                                            mergeRecord.Status__c='FAILED RETRY';
                                        }else{
                                            mergeRecord.Status__c='FAILED';
                                        }
                                    
                                    mergeRecord.Error_Message__c='Any problem with a DML statement, such as an insert statement missing a required field on a record';
                                    mergeRecord.Error_Code__c='0383';
                                
                                    update mergeRecord;
                                }
                                
                            }catch(Exception e) {
                                System.debug('!@#$% Contact data creation exception !');
                                //Database.rollback(sp);
                                System.debug('!@#$% Account creation exception !');
                                if(mergeRecord.Status__c!='FAILED RETRY'){
                                        mergeRecord.Status__c='FAILED RETRY';
                                    }else{
                                        mergeRecord.Status__c='FAILED';
                                    }
                                mergeRecord.Error_Message__c='Exception occurred while Merging Customer -'+ e.getMessage();
                                mergeRecord.Error_Code__c='0387';
                                
                                update mergeRecord; 
                                return null;
                            }
                        }
                    }
                }
                return  a;
            }
        }
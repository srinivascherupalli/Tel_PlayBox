/*******************************************************************
@Class Name			: BatchSyncContactOptOuts
@Sprint 			: 21.08  & P2OB-13388
@Author				: SFO Team (Pallavi B)
@CreateDate			: 21/06/2021
@description		: Updates all contact records with same email/mobilephone/phone along with check of Opt Out Email/Opt out SMS as true.
@Related Test Class : BatchSyncContactOptOutsTest
@updated 			: 
@Last Modified      : 
*********************************************************************/
global Without sharing class BatchSyncContactOptOuts implements Database.Batchable<SObject> ,Database.Stateful{
    
    Private static final List<ApplicationLog__c> lstApplicationLog = new List<ApplicationLog__c>();
    
    //Constructor
    global BatchSyncContactOptOuts() {
        
    }
    
    //Start Method
    global Database.QueryLocator start(Database.BatchableContext context) {
    // collect the batches of contact records that are modified in last 7 days with status as active and opt out email/opt out sms as true to be passed to execute
    return Database.getQueryLocator('SELECT Id, Opt_Out_SMS_MMS__c, Opt_Out_Emails__c, Email, Phone, MobilePhone FROM Contact WHERE SystemModStamp >= LAST_N_DAYS:7 AND (Opt_Out_SMS_MMS__c = True OR Opt_Out_Emails__c = True) AND Contact_Status__c = \'Active\'');
    }
    
    //Execute Method
    global void execute(Database.BatchableContext context, List<Contact> scope) {
        Map<Id,Contact> mapOfContactsToBeUpdated = new Map<Id,Contact>();
        List<String> emailList = new List<String>();
        List<String> phoneMobileList = new List<String>();
        try{
        for(Contact conRecord : scope){
            //Stores records with opt out email as true and not blank.
            if(conRecord.Opt_Out_Emails__c && String.isNotBlank(conRecord.Email)){
            	emailList.add(conRecord.Email); 
            } 
            //Stores records with Opt Out SMS as true and Phone not blank.
            if(conRecord.Opt_Out_SMS_MMS__c && String.isNotBlank(conRecord.Phone)){
            	phoneMobileList.add(conRecord.Phone);
            } 
            //Stores records with Opt Our email as true and MobilePhone not blank.
            if(conRecord.Opt_Out_SMS_MMS__c && String.isNotBlank(conRecord.MobilePhone)){
            	phoneMobileList.add(conRecord.MobilePhone);
            }  
        }
            
            //Collects corresponding contacts that have same Email 
            
           if(!emailList.isEmpty()){
            for(Contact emailMatchContact :[SELECT Id,Opt_Out_Emails__c,Opt_Out_SMS_MMS__c from Contact where Opt_Out_Emails__c =false AND Email IN : emailList AND Contact_Status__c = 'Active']){
                if(mapOfContactsToBeUpdated.get(emailMatchContact.Id) != null){
                	mapOfContactsToBeUpdated.get(emailMatchContact.Id).Opt_Out_Emails__c = True;    
                }else{
                    emailMatchContact.Opt_Out_Emails__c = True; 
                    mapOfContactsToBeUpdated.put(emailMatchContact.Id, emailMatchContact);
                }
            }
           }
            
            //Collects corresponding contacts that have same Phone and MobilePhone
         if(!phoneMobileList.isEmpty()){
            for(Contact phoneMatchContact :[SELECT Id,Opt_Out_SMS_MMS__c from Contact where Opt_Out_SMS_MMS__c =false AND (Phone IN : phoneMobileList OR MobilePhone IN : phoneMobileList) AND Contact_Status__c = 'Active']){
                if(mapOfContactsToBeUpdated.get(phoneMatchContact.Id) != null){
                	mapOfContactsToBeUpdated.get(phoneMatchContact.Id).Opt_Out_SMS_MMS__c = True;    
                }else{
                    phoneMatchContact.Opt_Out_SMS_MMS__c = True; 
                    mapOfContactsToBeUpdated.put(phoneMatchContact.Id, phoneMatchContact);
                }
            }
         }
            if(!mapOfContactsToBeUpdated.values().isEmpty()){
                //Updates the Contact Records with match criteria
                Database.SaveResult[] saveResult = Database.update(mapOfContactsToBeUpdated.values(),false);
            // Iterate through each returned result
                for (Database.SaveResult sr : saveResult) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');  
                                lstApplicationLog.add(new ApplicationLog__c(
                                        Reference_Info__c = 'SFO-BatchSyncContactOptOuts_P2OB-13388' + System.now(),
                                        Timer__c = System.now(),
                                        Debug_Level__c = 'Exception',
                                        Error_Category__c= 'Technical',
                                        Error_Type__c ='Error',
                                        Request_Message__c= 'Update failed with error '+err.getStatusCode()+' :'+ err.getMessage()));
                            
                            }
                        }
                }
                insert lstApplicationLog;
            }
        }catch(Exception e){
                system.debug('Exception'+ e);
                }

    }
    
    //finish Method
    global void finish(Database.BatchableContext context) {}
}
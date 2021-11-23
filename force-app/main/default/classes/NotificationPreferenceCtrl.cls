public with sharing class NotificationPreferenceCtrl {
    @AuraEnabled
    public static Wrapperdata getPreferences(String accountId, String contactId,String orderId,String type,string serviceNum){
        string field = '';
        string whereCondition = '';
        Set<Id> serviceIds = null;
        map<string,list<Notification_Preference__c>> returnValues = new map<string,list<Notification_Preference__c>>();
        if(!String.isEmpty(accountId)) {
            field = 'Account_Id__c = \''+String.escapeSingleQuotes(accountId.trim())+'\'and ';    
        }if(!String.isEmpty(contactId)) {
            field += 'Contact_Id__c = \''+String.escapeSingleQuotes(contactId.trim())+'\' and ';    
        }if(!String.isEmpty(orderId)) {
            Map<id,csord__Service__c> serviceMap  = new Map<Id,csord__Service__c>([select id from csord__Service__c where csord__Order__c = :orderId]);
            serviceIds = serviceMap.keySet();    
            field += 'Service_Id__c IN :serviceIds and '; 
        }if(!String.isEmpty(type) && type !='All') {
            field += 'Notification_Type__c = \''+String.escapeSingleQuotes(type.trim())+'\' and ';    
        }if(!String.isEmpty(serviceNum)) {
            field += 'service_MSISDN__c  = \''+String.escapeSingleQuotes(serviceNum.trim())+'\' and ';    
        }
       if(String.isEmpty(accountId) && !String.isEmpty(serviceNum)){
            Notification_Preference__c pref = [select account_id__c from Notification_Preference__c where service_MSISDN__c =: serviceNum limit 1];
            accountId = pref.account_id__c;
        }
        if(!String.isEmpty(field)){
        string selectQ = ' select id,Contact_Id__c,IsActive__c,Notification_Type__c,service_MSISDN__c,Communication_Method__c from Notification_Preference__c';
        string whereC = ' where ';
        whereC += field ;//+ ' and ' + whereCondition; 
        whereC = selectQ+whereC;
        whereC = whereC.Substring(0, whereC.Length()-4);
        // EDGE 192237
        // whereC += ' and (NOT Service_Id__r.csord__Order__r.csordtelcoa__Opportunity__r.Type LIKE \'CHOWN%\')';
        // whereC += ' and Service_Id__r.csord__status__c != \'Disconnected\' '; 
        whereC += ' limit 500';
        System.debug('whereC: '+ whereC);
        List <Notification_Preference__c> preference = database.query(whereC);
        returnValues.put(accountId,preference);
        return new Wrapperdata(accountId , preference);
        }
        else{
            return null;
        }
    }
    public class Wrapperdata
    {
        @AuraEnabled
        public id accId {get; set;}
        @AuraEnabled
        public List<Notification_Preference__c> notificationList {get; set;}
        public Wrapperdata(Id acc, List<Notification_Preference__c> notifi )
        {
            accId = acc ;
            notificationList = notifi ;
        }
    }

     @AuraEnabled
    public static list<sObject> getServiceNumbers(String searchKey){
        list<sObject> prefObj = new list<sObject>();
       if(searchKey.length() >= 3){
        String key = '%' + searchKey + '%';
        prefObj = [select id,service_MSISDN__c from Notification_Preference__c where service_MSISDN__c like :key limit 5];
        System.debug(prefObj+'@@@@@@@@@');
       }
        return prefObj;
    }
    /*----------------------------------------------------------------
Method : updateBulkNotifications
Author: Kalashree Borgaonkar
Story: EDGE-171180,EDGE-172362
Descripton : update notification preferences in bulk
-------------------------------------------------------------------------------------*/
    @AuraEnabled
   public static String updateBulkNotifications(String selectedNotifications,String updateDetails){
        String result='Success';        
        List<Notification_Preference__c> selectedNotificationsList;    
        try{
            selectedNotificationsList = (List<Notification_Preference__c>)System.JSON.deserialize(selectedNotifications, List<Notification_Preference__c>.Class);
            UpdateDetails details = (UpdateDetails)System.JSON.deserialize(updateDetails, UpdateDetails.Class);
            System.debug('selectedNotificationsList: '+selectedNotificationsList);
            //EDGE-170965:Added check for contact email validation
            Set<id> contactIDs=new Set<id>();
            Map<id,String> mapContactIdtoComType= new Map<id,String>();
            for(Notification_Preference__c rec : selectedNotificationsList){
                
                mapContactIdtoComType.put(rec.id,rec.Communication_Method__c);
            }
           
            if(details!=null){
                if(details.contactId !=null){
                    Contact con=[SELECT id,Email,Email_status__c FROM Contact WHERE id=: details.contactId];
                    
                    if((con.Email == Null || con.Email_status__c)){
                        result=Label.EmailRequired;   
                         return result;
                    }
                   
                }
                List<Notification_Preference__c> listOfNotificationRecords=[SELECT id,Contact_Id__c,Service_Id__c,Communication_Method__c, IsActive__c,
                                                                            Contact_Id__r.Email,Contact_Id__r.Email_status__c from Notification_Preference__c WHERE id IN :selectedNotificationsList];
                
                for(Notification_Preference__c notify : listOfNotificationRecords){
                    if(mapContactIdtoComType.get(notify.id)=='Email' && (notify.Contact_Id__r.Email == NULL || notify.Contact_Id__r.Email_status__c))
                        result=Label.EmailRequired;   
                    else{
                        notify.Contact_Id__c = (details.contactId!=null)?details.contactId:notify.Contact_Id__c;
                        notify.IsActive__c = details.optin;
                        notify.Communication_Method__c = (details.ComMethod!=null)?details.ComMethod:notify.Communication_Method__c ;
                    }
                }
                 System.debug('listOfNotificationRecords: '+listOfNotificationRecords);
                if(!listOfNotificationRecords.isEmpty()){
                    update listOfNotificationRecords;
                }
                
            }
            
        }
        catch(Exception e){
            System.debug('Exception in updateNotifications'+e.getStackTraceString());
            result= e.getMessage();
        }
        
        return result;
    }
     /*----------------------------------------------------------------
Method : inlineUpdateNotifications
Author: Kalashree Borgaonkar
Story: EDGE-171180,EDGE-172362
Descripton : update notification preferences in inline datatable
-------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String inlineUpdateNotifications(String selectedNotifications){
        String result='Success';
        try{
            List<Notification_Preference__c> selectedNotificationsList = (List<Notification_Preference__c>)System.JSON.deserialize(selectedNotifications, List<Notification_Preference__c>.Class);
            System.debug('selectedNotificationsList: '+selectedNotificationsList); 
            //EDGE-170965:Added check for contact email validation
            Set<id> contactIDs=new Set<id>();
            for(Notification_Preference__c rec :selectedNotificationsList){
                contactIDs.add(rec.Contact_Id__c);
            }
            if(!selectedNotificationsList.isEmpty()){
                List<Contact> listOfContact=[SELECT id,Email,Email_status__c FROM Contact WHERE id IN :contactIDs];
              
               
                if(!listOfContact.isEmpty()){
                    for(Notification_Preference__c rec :selectedNotificationsList){
                        if((listOfContact[0].Email == Null ||listOfContact[0].Email_status__c)&& rec.Communication_Method__c =='EMAIL' ){
                        result=Label.EmailRequired;
                         }
                    }
                }
                if(result=='Success'){
                update selectedNotificationsList;
                    system.debug('selectedNotificationsList after update'+selectedNotificationsList); 
                }
                
                
            }
        }
        catch(Exception e){
            System.debug('Exception in inlineUpdateNotifications: '+e.getStackTraceString());
            result = e.getMessage();
        }
        
        return result;
    }
      @AuraEnabled public static Boolean checkForPartnerUser(){
      return ConstantMetadataUtility.checkForPartnerUser();
        
    }
    //Track updates on bulk updation
    public class UpdateDetails{
        @AuraEnabled
        public Boolean optin;
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String ComMethod;
    }
}
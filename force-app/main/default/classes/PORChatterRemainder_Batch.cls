global with sharing class PORChatterRemainder_Batch implements Database.Batchable<sObject> {
    // date dt = Date.today().addDays(12);
    List<string> val = System.Label.End_Date_Days.Split(',');  
    Set<Date> dateSet = new Set<Date>();
    
    //EDGE-203922- Post chatter reminder for End_Date_Days value.
    //Code works for Generic condition based on End_Date_Days label value. 
    public PORChatterRemainder_Batch(){
        for(String s:val){
            integer days = integer.valueOf(s);
            DateTime dt = System.now().addDays(days);
            Date d = dt.date();
            dateSet.add(d);     
        } 
    }
    
    //String dtFormatted = dt.format('YYYY-MM-dd');
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String soql = 'SELECT id,end_Date__c,name,Customer__c,Partner__r.PartnerPrincipalContact__c,Customer__r.Name,Partner_Signatories__c,Partner_Signatories__r.Onboarding_Status__c FROM Partner_of_Record__c WHERE end_Date__c in: dateSet ' ;
        return Database.getQueryLocator(soql);
    }    
    global void execute(Database.BatchableContext bc, List<Partner_of_Record__c> recs) {
        Network network = [SELECT Id, Name FROM network WHERE Name = 'EDGE Partners'];
        Set<Id> partnerContactIds  = new Set<Id>();
        //EDGE-203922- Modified the code to handle limits effeciently
        for(Partner_of_Record__c por  : recs){         
            if(por.Partner__r.PartnerPrincipalContact__c != null){
                partnerContactIds.add(por.Partner__r.PartnerPrincipalContact__c);
            }
            if(por.Partner_Signatories__r.Onboarding_Status__c == 'Active'){
                partnerContactIds.add(por.Partner_Signatories__c);       
            } 
            system.debug('partnerContactIds '+partnerContactIds);
        }
        List<User> usrDetail = [SELECT Id from User where IsActive = TRUE and contactId IN:partnerContactIds];
        //EDGE-203922- Post chatter reminder for End_Date_Days value   
        for(Partner_of_Record__c por  : recs){   
            for(String dl : val){
                Integer days = Integer.valueOf(dl);
                Date dendDate = por.end_Date__c.addDays(-days);
                for( User user : usrDetail){ 
                    if(system.today() == dendDate && !Test.isRunningTest()){
                        ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + user.Id + '}, A Partner of Record Agreement is due for renewal within '+ days +' days for ' + por.Customer__r.Name + ' , please review and renew the Agreement {record:' +por.id+ '}.');  
                    } 
                }
            }
        }     
    }
    
    global void finish(Database.BatchableContext bc) {
    }
    
}
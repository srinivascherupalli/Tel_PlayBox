public with sharing class searchSubscriptions {
    @auraEnabled
    public static list<csord__Subscription__c> getSubscriptions(string customerAccount,string partnerAccount,string CIDN,string partnerCode,datetime startDate,datetime endDate,string type){
        string field = '';
        string whereCondition = '';
        system.debug('********'+type);
        if(!String.isEmpty(customerAccount)) {
            field = 'csord__Account__c = \''+String.escapeSingleQuotes(customerAccount.trim())+'\' and ';    
        }if(!String.isEmpty(partnerAccount)) {
            field += 'PartnerAccount__c = \''+String.escapeSingleQuotes(partnerAccount.trim())+'\' and ';    
        }if(!String.isEmpty(CIDN)) {
            field += 'csord__Account__r.CIDN__c = \''+String.escapeSingleQuotes(CIDN.trim())+'\' and ';    
        }if(!string.isEmpty(partnerCode)) {
            field += 'PartnerAccount__r.Mobile_Code__c = \''+String.escapeSingleQuotes(partnerCode.trim())+'\' and ';
        }if(startDate!=null) {
            field +='createddate >' + startDate.format('yyyy-MM-dd')+'T00:00:00.000+0000'+' and ';
        }if(endDate!=null) {
            field += 'createddate  <'+ endDate.format('yyyy-MM-dd')+'T00:00:00.000+0000'+' and ';
        }
        string solutions = 'SolutionComponent';
        if(type !='All') {
            field += 'csordtelcoa__Product_Configuration__r.ConfigurationType1__c = \''+String.escapeSingleQuotes(solutions.trim())+'\' and ';    
        }
        string status = 'Active';
        List <csord__Subscription__c> subscriptions=new List <csord__Subscription__c>();
        if(!String.isEmpty(field)){
            string selectQ = ' select id,csordtelcoa__Subscription_Number__c,partnerAccount__r.Name,csord__Account__c,csord__Account__r.CIDN__c,partnerAccount__r.Mobile_Code__c,partnerAccount__r.Partner_Code__c,name,MarketableOffer__r.name,csord__Account__r.Name,MarketableOffer__r.Product_Family__c,csord__Status__c,createddate,lastmodifieddate from csord__Subscription__c';
            string whereC = ' where csord__Status__c = \''+String.escapeSingleQuotes(status.trim())+'\' and '; 
            whereC += field ;
            whereC = selectQ+whereC;
            whereC = whereC.Substring(0, whereC.Length()-4);
            whereC += ' limit 500';
            subscriptions = database.query(whereC);
            system.debug('****FinalResult****'+subscriptions.size());
        }
            return subscriptions;
    }
    @AuraEnabled
    public static String updatePartner(List<ID> subList,Id accountId){
        String result='Success';
        set<String> subscriptionNumberList= new set<String>();
        List<csord__Subscription__c> updateSub= new List<csord__Subscription__c>();
        try{
            for(csord__Subscription__c subscription:[SELECT id,csordtelcoa__Subscription_Number__c FROM csord__Subscription__c where id IN :subList]){
                subscriptionNumberList.add(subscription.csordtelcoa__Subscription_Number__c);
            }
            for(csord__Subscription__c sub:[SELECT id,PartnerAccount__c FROM csord__Subscription__c where csordtelcoa__Subscription_Number__c IN :subscriptionNumberList AND csordtelcoa__Product_Configuration__r.ConfigurationType1__c = 'SolutionComponent'] ){
                sub.partnerAccount__c=accountId;
                updateSub.add(sub);
            }
            update updateSub;
        }catch(Exception e){
            System.debug('Exception in updatePartner'+e.getStackTraceString());
            result= e.getMessage();
        }
        return result;
    }
}
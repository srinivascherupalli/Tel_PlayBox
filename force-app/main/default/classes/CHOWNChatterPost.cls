public with sharing class CHOWNChatterPost implements Database.Batchable<SObject>{

    public Database.QueryLocator Start(Database.BatchableContext BC)
     {
         List<Orchestration_Technical__c> Tecnical =new LIst<Orchestration_Technical__c>();
         Tecnical=[SELECT Id, Name, Field_29__c,Field_19__c FROM Orchestration_Technical__c WHERE Field_29__c='Response Received from BDS'];
     Map<String, Orchestration_Technical__c> uniqueBasketMap = new Map<String, Orchestration_Technical__c>();
         for(Orchestration_Technical__c tecnicaldata:Tecnical){
             uniqueBasketMap.put(tecnicaldata.Field_19__c,tecnicaldata);
            }  
         Set<String> keys =uniqueBasketMap.keySet();
      String query = 'SELECT Id, Name, Field_29__c,Field_19__c FROM Orchestration_Technical__c WHERE Field_19__c IN :keys';
         
      return Database.getQueryLocator(query);
     }
    
     public void execute(Database.BatchableContext BC, List<Orchestration_Technical__c > lstOrchTech){
          Map<String, Orchestration_Technical__c> uniqueBasketidMap = new Map<String, Orchestration_Technical__c>();
         Map<String, Orchestration_Technical__c> responcerecived = new Map<String, Orchestration_Technical__c>();
         For(Orchestration_Technical__c basketdata:lstOrchTech)   {
             if(basketdata.Field_29__c !='Response Received from BDS'){
                 uniqueBasketidMap.put(basketdata.Field_19__c,basketdata);
                }
             else {
                 responcerecived.put(basketdata.Field_19__c,basketdata);
             }
          } 
         
         for(String basketvalue :responcerecived.keyset()){
             if(!uniqueBasketidMap.containsKey(basketvalue)){
           List<Orchestration_Technical__c> updatestatus = new List< Orchestration_Technical__c>();
            updatestatus= [SELECT Id, Name,	Field_29__c FROM Orchestration_Technical__c WHERE Field_19__c =:basketvalue]; 
                 for(Integer i = 0; i < updatestatus.size(); i++){
                        updatestatus[i].Field_29__c='Chatter sent to User';
                            }
                 
             update updatestatus;
         cscfga__Product_Basket__c basketdetails =   [ SELECT Id,CreatedById,Bakset_Number_Format__c FROM cscfga__Product_Basket__c WHERE id=:basketvalue];   
         String currentUserId=basketdetails.CreatedById;
         String Basketnumber =basketdetails.Bakset_Number_Format__c;
             String feedMessage='Remaining term(s) and amount(s) are available on click of Get Term and Amount button in the CHOWN Incoming product basket {0} ';
                 List<String> params1 = new List<String>{'{'+Basketnumber+'}'};
                String parameterizedLabel1   =   String.format(feedMessage, params1);
                 if (!Test.isRunningTest()){
                 ConnectApiHelper.postFeedItemWithMentions(Null,currentUserId,parameterizedLabel1);
                 }
         }
         }
                 
     }
    public void finish(Database.BatchableContext BC){
    }
    
    
    }
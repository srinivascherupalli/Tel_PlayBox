global class BatchUpdateProgramRecords implements Database.Batchable<sObject> {
    @TestVisible public static List<BatchUpdateProgramRecords.OrderHistoryWrapper> orderHistoryWrap;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('---------BatchUpdateProgramRecords-----------');
        //collect the batches of records or objects to be passed to execute
        Id generalRecTypeId = Schema.SObjectType.Program_Account__c.getRecordTypeInfosByName().get('General').getRecordTypeId();
        List<csord__Order__History> orderHistoryList = [SELECT Id,OldValue,NewValue,ParentId,Field FROM csord__Order__History WHERE CreatedDate = TODAY And Field = 'csord__Status2__c'];
        system.debug('---------orderHistoryList-----------'+orderHistoryList);
        Set<Id> orderIdSet = new Set<Id>();
        system.debug('---------orderHistoryWrap-----------'+orderHistoryWrap);
        
            if(orderHistoryWrap == null){
                for(csord__Order__History ordHistory: orderHistoryList){
                    if(ordHistory.NewValue == 'Completed'){
                        orderIdSet.add(ordHistory.ParentId);
                    }
                }
            }
            else{
                for(OrderHistoryWrapper historyWrap: orderHistoryWrap){
                    if(historyWrap.NewValue == 'Completed'){
                        orderIdSet.add(historyWrap.ParentId);
                    }
                }
            }
            system.debug('---------orderIdSet-----------'+orderIdSet);
            
         
        Set<Id> accountIdSet = new Set<Id>();
        for(csord__Order__c ord: [SELECT Id, csord__Account__c FROM csord__Order__c WHERE Id IN :orderIdSet]){
            accountIdSet.add(ord.csord__Account__c);
        }
        system.debug('---------accountIdSet-----------'+accountIdSet);
        String query = 'SELECT Id, Account__c, Digital_Program_Type__c, Digital_Products_Start_Date__c FROM Program_Account__c WHERE Account__c IN :accountIdSet AND Enable_to_digital_products__c=TRUE';
        query = query+' AND RecordType.DeveloperName=\'General\'';
        query = query+' AND (Digital_Program_Type__c = \'Transition\' OR Digital_Program_Type__c = \'Migration\')';
        query = query+' AND Status__c!=\'Completed\''; 
        system.debug('---------query-----------'+Database.Query(query));
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext BC, List<Program_Account__c> programAccList) {
        
        List<Program_Account__c> programAccountListToupdate = new List<Program_Account__c>();
        for(Program_Account__c programAcc : programAccList) {    
            system.debug('---------programAcc.Digital_Products_Start_Date__c-----------'+programAcc.Digital_Products_Start_Date__c);     
            if(programAcc.Digital_Products_Start_Date__c != null){
                programAcc.Status__c = 'Completed';
                programAccountListToupdate.add(programAcc);
            }
           system.debug('---------programAccountListToupdate-----------'+programAccountListToupdate);     
        }
        try {
            system.debug('---------try-----------'+programAccountListToupdate); 
            if(!programAccountListToupdate.isEmpty()){
                update programAccountListToupdate;
            }
        system.debug('---------programAccountListToupdate-----------'+programAccountListToupdate);
        } catch(Exception e) {
             System.debug('------ex-----'+e);
        }
         
    }   
     
    global void finish(Database.BatchableContext BC) {
        
    }

    @TestVisible
    public class OrderHistoryWrapper{
        public String oldValue{get;set;}
        public String newValue{get;set;}
        public Id parentId{get;set;}
        public String field{get;set;}

        public OrderHistoryWrapper(String oldValue, String newValue, Id parentId, String field){
            this.oldValue = oldValue;
            this.newValue = newValue;
            this.parentId = parentId;
            this.field = field;
        }
    }
}
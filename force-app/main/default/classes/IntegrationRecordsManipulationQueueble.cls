public with sharing class IntegrationRecordsManipulationQueueble  {
    List<Integration_Record__c> records;
    Boolean isInsert;
    public IntegrationRecordsManipulationQueueble(List<Integration_Record__c> records,Boolean isInsert) {
            this.records= records;
            this.isInsert = isInsert;
    }
    public  void executeIntegrationRecords(){
        List<Integration_Record__c> insertRecs = new List<Integration_Record__c>();
        List<Integration_Record__c> updateRecs = new List<Integration_Record__c>();
        List<String> params = new List<String>();
        List<String> handlers = new List<String>();
        List<String> payload = new List<String>();
        for(Integration_Record__c ir : this.records){
            params.add(ir.Params__c);
            handlers.add(ir.Handler__c);
            payload.add(ir.paramPayload__c);
        }
        Map<String, Integration_Record__c> mapIntegrationRecs = new Map<String, Integration_Record__c>();
        for (Integration_Record__c ir2 : [Select Id, Params__c, Handler__c, paramPayload__c,Status__c From Integration_Record__c 
        Where Params__c IN :params AND Handler__c IN :handlers]){
            mapIntegrationRecs.put(ir2.Handler__c + ir2.Params__c + ir2.paramPayload__c, ir2);
        }
        for (Integration_Record__c ir3 : this.records){
            Integration_Record__c ir = mapIntegrationRecs.get(ir3.Handler__c + ir3.Params__c + ir3.paramPayload__c);
            if (ir != null){
                ir3.Id = ir.Id;
                if(ir.Status__c != IntegrationQueueHandler.PENDING && ir3.Status__c == IntegrationQueueHandler.PENDING){
                    updateRecs.add(ir3);
                }
            }
            else{
                insertRecs.add(ir3);
            }
        }
        if(insertRecs.size() > 0){    
            Insert insertRecs;
        }
        if (updateRecs.size() > 0){
            Update updateRecs;
        } 
    }
}
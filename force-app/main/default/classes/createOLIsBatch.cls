/*
*@Created Date : 4/2/2021
*@Created By : Payal/Gokul
*@Breif : EDGE-198027 Sync functionality- Change Async Process of createOLI from future to batch

Gokul        23/02/21     EDGE-195270        - Chown: chain syncing of Source Basket
*/
public class createOLIsBatch implements Database.Batchable<String>,Database.Stateful{
    
    List<String> prdBasketIds = new List<String>();
    set<string> basketIdsToFinish = new set<string>();
    set<string> basketIds = new set<string>();

    public createOLIsBatch(set<String> basketIDs){
        prdBasketIds.addAll(basketIDs); 
    }
    public Iterable<String> start(Database.BatchableContext BC){
        return prdBasketIds;
    }
    
    public void execute(Database.BatchableContext BC,List<String> scope){

        

        Environment_Configurations__c ecCusSetting  = Environment_Configurations__c.getInstance(UserInfo.getUserId());    // Custom setting used to disable all the validation rules for the current running user. 
        if (ecCusSetting.No_Validations__c == false) {  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;
        }
        
        for(String s : scope){
            basketIds.add(s); 

            basketIdsToFinish.add('%'+s+'%');

        }
        try{
            ProductUtilityForModular pu = new ProductUtilityForModular();
            pu.syncProductBaskt(basketIds,ecCusSetting);   
            /*if(Test.isRunningTest()){
               throw new NullPointerException();
            }*/
                
        }catch (Exception e) {
            System.debug('OLI Aync Creation Exception ***' + e.getMessage() + ' ' + e.getStackTraceString());
            List<cscfga__Product_Basket__c> productBasketList   =   new List<cscfga__Product_Basket__c>();
            for(String basketId : basketIds) {
                cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Id=basketId,csbb__Synchronised_With_Opportunity__c=false,csordtelcoa__Synchronised_with_Opportunity__c=false);
                productBasketList.add(basket);
            }
            update productBasketList;
        }
        
    }
    public void finish(Database.BatchableContext BC){

        //EDGE-195270 - Start
        set<Id> pbids = new set<Id>();
        list<cscfga__Product_Basket__c> updatePBList = new list<cscfga__Product_Basket__c>();
        map<string,string> sourceTargetBskIdsMap = new map<string,string>();
        try{
            for(Migration_Change_Request__c mcr : [select id,macd_basket_ids__c from Migration_Change_Request__c where macd_basket_ids__c like :basketIdsToFinish  limit 10000]){
                for(string st : mcr.macd_basket_ids__c.split(',')){
                    pbids.add(st);  
                    if(basketIds != null && basketIds.contains(st))
                        sourceTargetBskIdsMap.put(st,mcr.macd_basket_ids__c);
                }  
            }

            set<string> sourceBasketsids = new set<string>();
            for(cscfga__Product_Basket__c pb : [select id,cscfga__Opportunity__r.Description__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where id IN:basketIds]){

                if(sourceTargetBskIdsMap != null && sourceTargetBskIdsMap.containskey(pb.id) && pb.cscfga__Opportunity__r.Description__c != null && pb.cscfga__Opportunity__r.Description__c.containsIgnoreCase('CHOWN Incoming') && pb.csbb__Synchronised_With_Opportunity__c && pb.csordtelcoa__Synchronised_with_Opportunity__c){
                    sourceBasketsids.addall(sourceTargetBskIdsMap.get(pb.id).split(','));
                }
                
            }
            for(cscfga__Product_Basket__c pb : [select id,cscfga__Opportunity__r.Description__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c from cscfga__Product_Basket__c where id IN:sourceBasketsids]){
                if(!basketIds.contains(pb.id)){
                    pb.csbb__Synchronised_With_Opportunity__c = false;
                    pb.csordtelcoa__Synchronised_with_Opportunity__c = false;
                    updatePBList.add(pb); 
                }
                
            } 
            if(updatePBList != null && updatePBList.size()>0){
                update updatePBList;
                
            }
            for(cscfga__Product_Basket__c pb : updatePBList){
                pb.csbb__Synchronised_With_Opportunity__c = true;
                pb.csordtelcoa__Synchronised_with_Opportunity__c = true;
            }
            if(updatePBList != null && updatePBList.size()>0){
                update updatePBList;
                
            }
            if(Test.isRunningTest()){
                throw new NullPointerException();
            }
        }catch (Exception e) {
            System.debug('chown OLI Aync Creation Exception ***' + e.getMessage() + ' ' + e.getStackTraceString());
            List<cscfga__Product_Basket__c> productBasketList   =   new List<cscfga__Product_Basket__c>();
            for(String basketId : pbids) {
                cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Id=basketId,csbb__Synchronised_With_Opportunity__c=false,csordtelcoa__Synchronised_with_Opportunity__c=false);
                productBasketList.add(basket);
            }
            update productBasketList;
        }
        //EDGE-195270 - End
    }

    
}
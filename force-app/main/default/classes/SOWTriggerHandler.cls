/****
 * Created By: Ravi Shankar
 * Date: 09/25/2019
 * Description: Handler class for handling trigger on SOW Object.
 * *****/
 public without sharing class SOWTriggerHandler {
    //EDGE-111293 handler method to update basket stage
    public static void updateBasketStage(Map<Id, SOW__c> oldMap, Map<Id, SOW__c> newMap){
        set<Id> sowSet = new set<Id>();
        set<Id> bsktSet = new set<Id>();
        cscfga__Product_Basket__c bsktRec;
        list<cscfga__Product_Basket__c> bsktLst = new list<cscfga__Product_Basket__c>();
        for(SOW__c sow :newMap.values()){
            if(sow.Status__c != null && sow.Status__c == 'Approved' && (sow.Status__c != oldMap.get(sow.Id).Status__c)){
                sowSet.add(sow.Id);
                bsktSet.add(sow.Basket__c);
            }
        }
        if(bsktSet.size()>0){
            List<Id> bsktIdLst = new List<Id>(bsktSet);
            list<SOW__c> sowLst = [SELECT Id, Basket__c FROM SOW__c WHERE Status__c NOT IN ('Approved') AND Basket__c IN :bsktIdLst];
            if(sowLst != null && sowLst.size()>0){
                for(SOW__c sow :sowLst){
                    if(bsktSet.contains(sow.Basket__c))
                        bsktSet.remove(sow.Basket__c);
                }
            }
        }
        if(bsktSet.size()>0){
            for(Id bsktId :bsktSet){
                bsktRec = new cscfga__Product_Basket__c();
                bsktRec.Id = bsktId;
                bsktRec.csordtelcoa__Basket_Stage__c = 'SOW Approved';
                bsktLst.add(bsktRec);
            }
            try{
                update bsktLst;
            }
            catch(Exception ex){
                system.debug('Error occurred in SOWTriggerHandlerTest:'+ex.getMessage());
            }
        }
    }
 }
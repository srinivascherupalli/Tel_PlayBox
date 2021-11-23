/*****************************************************************************
@Name: DealSupportRequestTriggerHandler
@Author: Sravanthi Velegapudi
@CreateDate: 10/04/2018
@Description: This Class is Helper for DealSupportRequestTrigger Trigger
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*******************************************************************************/
public with sharing class DealSupportRequestTriggerHandler {
    
    /*This Method used while new dsr is created with RecordType name='Pricing Support' 
*and if dsr record already exist with same record type throws Error message
* 
* */
    public  void PricingSupportDSRCheck(list<Deal_Support_Request__c> newList ){
        list<Deal_Support_Request__c> dsrId = new list<Deal_Support_Request__c>();
        map<ID,list<Deal_Support_Request__c>> dsrOppMap=dsrCheck(newList);
        
        List<RecordType> RecType = [Select id, name From RecordType];
        map<Id,String> tecMap=new Map<Id,String>();
        for(RecordType rt:RecType){            
            tecMap.put(rt.Id, rt.Name);
        }
        for (Deal_Support_Request__c newdsr : newList){
            if(tecMap.containsKey(newdsr.RecordTypeId)){
                list<Deal_Support_Request__c> oldDsrlist = new list<Deal_Support_Request__c>();                           
                if(dsrOppMap.containsKey(newdsr.Opportunity__c)){
                    oldDsrlist=dsrOppMap.get(newdsr.Opportunity__c);    
                    if(!oldDsrlist.isEmpty() && oldDsrlist.size()!=0 && oldDsrlist!=null){
                        for(Deal_Support_Request__c olddsr :oldDsrlist){    
                            if(olddsr!=null){
                                if(newdsr.RecordTypeId==olddsr.RecordTypeId && newdsr.Opportunity__c==olddsr.Opportunity__c){
                                    if((olddsr.Pricing_Request_Status__c=='Assessment Not Started' || olddsr.Pricing_Request_Status__c=='On Hold' || olddsr.Pricing_Request_Status__c=='Assessment Complete') ){
                                        if((newdsr.Pricing_Request_Status__c=='Assessment Not Started' || newdsr.Pricing_Request_Status__c=='On Hold' || newdsr.Pricing_Request_Status__c=='Assessment Complete') ){
                                            newdsr.adderror('A new Pricing Request cannot be created as there is already an In Progress Pricing DSR for this opportunity');
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }     
        
    }
    
    /* This method returns the list of DSR's associated with Opportunity whrere DSR Recordtype is Pricing Support
* and new dsr's not in existing list
* */
    public  map<ID,list<Deal_Support_Request__c>> dsrCheck(list<Deal_Support_Request__c> newList ){
        list<Deal_Support_Request__c> oldDsrlist=[Select id,Pricing_Request_Status__c,Opportunity__c,RecordTypeId from Deal_Support_Request__c where id Not in :newList and RecordType.name='Pricing Support'];
        map<ID,list<Deal_Support_Request__c>> oppDSRMap=new map<ID,list<Deal_Support_Request__c>>();
        if(oldDsrlist.size()>0){
            for(Deal_Support_Request__c dsr : oldDsrlist){
                list<Deal_Support_Request__c> dsrlist=oppDSRMap.get(dsr.Opportunity__c);
                if(null==dsrlist){
                    dsrlist= new list<Deal_Support_Request__c>();
                    oppDSRMap.put(dsr.Opportunity__c,dsrlist);
                }
                dsrlist.add(dsr);
            }
        }
        return oppDSRMap;
    }
    
    public void updateCompletedDate(List<Deal_Support_Request__c> listDSR){
        set<Id> oppsetIdsdsr=new set<Id>();
        for(Deal_Support_Request__c dsr : listDSR){
			oppsetIdsdsr.add(dsr.Opportunity__c);            
        }
        List<Opportunity> opps=[SELECT Id,StageName FROM Opportunity WHERE  Id in : oppsetIdsdsr];
        set<Id> oppsetIds=new set<Id>();
        for(Opportunity op : opps){
            if(op.StageName != 'Closed Won' || op.StageName != 'Closed Lost'){
            	oppsetIds.add(op.Id);
            }
        }
        for(Deal_Support_Request__c dsr : listDSR){
            if(oppsetIds.contains(dsr.Opportunity__c)){
                if(dsr.Status__c=='Completed'){
                    dsr.Completed_Date__c=Date.today();
                }
            }
        }   
    }
}
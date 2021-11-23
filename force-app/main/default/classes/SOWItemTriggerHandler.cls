/*****************************************************************
@Name: SOWItemTriggerHandler
@Author: Ravi Shankar
@JIRA Reference: EDGE-136074
@CreateDate: 18/03/2020
@Description: Trigger handler class for SOW Items object
******************************************************************/
public without sharing class SOWItemTriggerHandler{
    //EDGE-136074 handler to check the Approval Required flag based on update of Deliverables field
    public static void updateSOWApprovalRequired(map<ID,SOW_Items__c> oldSowItemMap,map<ID,SOW_Items__c> newSowItemMap){
        try{
            set<id> sowItemSet = new set<id>();
            list<string> delStr = new list<string>();
            list<integer> lstSeq = new list<integer>();
            map<integer,list<string>> mpDeliverables = new map<integer,list<string>>();
            for(SOW_Items__c c : newSowItemMap.values()) {
                if(oldSowItemMap.get(c.Id).Comment__c != c.Comment__c){
                    sowItemSet.add(c.Id);
                    lstSeq.add(integer.valueOf(c.Sequence__c));
                }
            }
            if(sowItemSet.size()>0){
                //query for all child clauses to build a map
                list<Clauses__c> clausesLst = [SELECT Id, ParentId__r.Sequence__c, Comment__c from Clauses__c WHERE ParentId__c != NULL 
                                               AND ParentId__r.Sequence__c IN :lstSeq];
                if(clausesLst != null && clausesLst.size()>0){
                    for(Clauses__c cl :clausesLst){
                        if(cl.Comment__c != null && cl.Comment__c != ''){
                            if(!(mpDeliverables.containsKey(integer.valueof(cl.ParentId__r.Sequence__c)))){
                                mpDeliverables.put(integer.valueof(cl.ParentId__r.Sequence__c), new list<string>{cl.Comment__c});
                            }
                            else{
                                delStr = mpDeliverables.get(integer.valueof(cl.ParentId__r.Sequence__c));
                                delStr.add(cl.Comment__c);
                                mpDeliverables.put(integer.valueof(cl.ParentId__r.Sequence__c), delStr);
                            }
                        }    
                    }
                }
                for(SOW_Items__c c : newSowItemMap.values()) {//conditionally update Approval Required flag
                    if(sowItemSet.contains(c.Id)){
                        if(c.Comment__c == null || c.Comment__c == ''){
                            c.Approval_Required__c = false;
                        }
                        else if(oldSowItemMap.get(c.id).Comment__c != c.Comment__c) {
                            if((mpDeliverables.get(integer.valueof(c.Sequence__c))).contains(c.Comment__c)){
                                c.Approval_Required__c = false;
                                c.Included__c = true;
                            }
                            else{
                                c.Approval_Required__c = true;
                                c.Included__c = true;
                            }
                        }
                    }
                }
            }
        } 
        catch(Exception e) {
            System.debug('Exception >>>>>>>>'+e.getLineNumber());
        }
    }
}
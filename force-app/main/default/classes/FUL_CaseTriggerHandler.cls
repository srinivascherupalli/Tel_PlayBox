/*Case Trigger Handler for handling fulfillment cases related logic*/
public without sharing class FUL_CaseTriggerHandler { //EDGE-128933
    public static void validateFulfilmentCaseClosure(List<Case> newCasesLst, Map<id,case> newCases,Map<id,case> oldCases){
        system.debug('inside validateFulfilmentCaseClosure::'+newCasesLst);
        set<id> caseIds = new set<id>();
        List<id> caseIdLst;
        String recordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Fulfillment').RecordTypeId;       
        for(id ids :newCases.keySet()){
            if(newCases.get(ids).status != oldCases.get(ids).status && newCases.get(ids).status.equalsIgnoreCase('Closed') && newCases.get(ids).Recordtypeid == recordtypeid){
                caseIds.add(ids);
            }
        }
        if(!caseIds.isEmpty()){
            caseIdLst = new List<id> (caseIds);
            List<FulfillmentLineItem__c> fulItemLst = [SELECT Id, case__c FROM FulfillmentLineItem__c WHERE Status__c != 'Completed' AND case__c IN :caseIdLst];
            if(!fulItemLst.isEmpty()){
                caseIds = new set<id>();
                for(FulfillmentLineItem__c fli :fulItemLst){
                    caseIds.add(fli.case__c);
                }
                for(Case caseRec:newCasesLst){
                    if(caseIds.contains(caseRec.Id)){
                        caseRec.addError('Ensure you close each fulfilment task to close the Case automatically.');
                    }
                }
            }
        }
    }
    
  public static void shareFulfillmentCasesToEnggUsers(Map<id,case> newCases){ //EDGE-128917
        try{
            String recordTypeId  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Fulfillment').RecordTypeId;
            set<id> caseIds = new set<id>();
            list<id> caseIdLst;
            list<Case> caseRecLst;
            list<User> userRecLst;
            map<Id,List<User>> mpAccUsr = new map<Id,List<User>>();
            map<Id,List<Case>> mpAccCs = new map<Id,List<Case>>();
            CaseShare CaseShareRecord;
            List<CaseShare> CaseShareRecordList = new List<CaseShare>();
            for(id ids: newCases.keyset()){
                if(newCases.get(ids).Recordtypeid== recordTypeId){
                    caseIds.add(ids);
                }
            }
            if(!caseIds.isEmpty()){
                caseIdLst = new list<Id>(caseIds);
                for(Case cs : [SELECT Id, OpportunityId__r.PartnerAccountId FROM Case WHERE OpportunityId__c != null AND Id IN :caseIdLst]){
                    if(cs.OpportunityId__r.PartnerAccountId != null){
                        if(mpAccCs.ContainsKey(cs.OpportunityId__r.PartnerAccountId)){
                            caseRecLst = mpAccCs.get(cs.OpportunityId__r.PartnerAccountId);
                            caseRecLst.add(cs);
                            mpAccCs.put(cs.OpportunityId__r.PartnerAccountId, caseRecLst);
                        }
                        else{
                            mpAccCs.put(cs.OpportunityId__r.PartnerAccountId, new List<Case> {cs});
                        }
                    }
                }
                if(mpAccCs.size()>0){
                    for(User usr : [SELECT Id, contact.AccountId FROM User WHERE Contactid != null AND contact.AccountId IN :mpAccCs.KeySet() AND contact.Partner_Role__c INCLUDES ('Telstra Collaboration Operations User', 'MDM Operations User', 'Engineering User')]){
                        if(mpAccUsr.ContainsKey(usr.contact.AccountId)){
                            userRecLst = mpAccUsr.get(usr.contact.AccountId);
                            userRecLst.add(usr);
                            mpAccUsr.put(usr.contact.AccountId, userRecLst);
                        }
                        else{
                            mpAccUsr.put(usr.contact.AccountId, new List<User> {usr});
                        }
                    }
                }
                if(mpAccUsr.size()>0){
                    for(Id acc :mpAccCs.KeySet()){
                        if(mpAccUsr.KeySet().Contains(acc)){
                            for(case css:mpAccCs.get(acc)){
                                for(User usr: mpAccUsr.get(acc)){
                                    CaseShareRecord=new CaseShare();
                                    CaseShareRecord.CaseId=css.Id;
                                    CaseShareRecord.UserOrGroupId=usr.Id;
                                    CaseShareRecord.CaseAccessLevel='Edit';
                                    CaseShareRecordList.add(CaseShareRecord);
                                    //system.debug('CaseShareRecordList::::'+CaseShareRecordList);
                                }
                            }
                        }
                    }
                }
                if(CaseShareRecordList.size()>0){
                    //system.debug('testtest::::testtest');
                    insert CaseShareRecordList;
                }               
            }
        }
        catch(Exception e){
            system.debug('Error in CaseTriggerHandler.shareFulfillmentCasesToEnggUsers::' + e.getMessage());
        }
  }
     
}
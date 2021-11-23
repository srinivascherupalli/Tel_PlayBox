/*
 * History of Modifications : 
 * 1. 9-April-2020  :   Ritika Jaiswal  :   Team Hawaii - P2OB-26 : Reverted Commented a contact-role validation rule. The validation rule showing message 'label.PRM_PARTNER_OPPORTUNITY_VERIFICATION_MESSAGE', is not functioning as expected and need to be handled differently. 
 * 2. 6-May-2020    :   Ritika Jaiswal : P2OB-26 : Reverted changes on validation-rule
 * */

public without sharing class OpportunityTriggernewHelper {
    /* public static boolean isRec = false;
public  void errormsg(Opportunity[] newOpportunities){
if(isRec==false){
if(AccountsOpportunityUpdates.IsAccountTrigger==false)
{
for(opportunity opp:newOpportunities)
{
if(opp.IsActiveAccount__c==False){                        
opp.addError('Opportunity can only be created/updated if it belongs to an Active or Acquired account');
}
}  
}
isRec = true;   
}
}*/
    // EDGE-151595 Code to trigger on Before Insert and Before Update
    // to check if Partner and Customer have an active POR
    // and accordingly auto approve the Opportunity
    public void updatePORStatus(List<Opportunity> newOpps,Map<Id,Opportunity> oldMapOpps){
        system.debug('inside updatePORStatus');
        set<Id> accIdSet = new set<Id>();
        set<Id> prtnrIdSet = new set<Id>();
        list<Id> accIdLst = new list<Id>();
        list<Id> prtnrIdLst = new list<Id>();
        String profileName;      
        boolean isPOR = false;
        set<Id> oppIdsSet = new set<Id>();
        Id profileId= userinfo.getProfileId();
        Id usrId = userinfo.getUserId();
        list<Partner_of_Record__c> lstPOR = new list<Partner_of_Record__c>();
        try{
            if(oldMapOpps == null){//Before Insert Scenario
                profileName=[SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
                if(profileName == label.PRM_Community_User || profileName == label.PRM_CommunityAdmin_User){
                    list<User> usrLst = [SELECT Id, Contact.AccountId FROM User WHERE Id = :usrId];
                    prtnrIdSet.add(usrLst[0].Contact.AccountId);
                    for(Opportunity opp :newOpps){
                        accIdSet.add(opp.AccountId);
                    }                       
                }
            }
            else{//Before Update Scenario
                for(Opportunity opp :newOpps){
                    if(opp.PartnerAccountId != null && 
                       (opp.PartnerAccountId != oldMapOpps.Get(opp.Id).PartnerAccountId ||
                        opp.Product_Type__c != oldMapOpps.Get(opp.Id).Product_Type__c)){
                        prtnrIdSet.add(opp.PartnerAccountId);
                        accIdSet.add(opp.AccountId);
                    }
                }
            }
            if(accIdSet.size()>0){
                //system.debug('prtnrIdLst::::'+prtnrIdLst);
                //system.debug('accIdLst::::'+accIdLst);
                prtnrIdLst = new list<Id>(prtnrIdSet);
                accIdLst = new list<Id>(accIdSet);
                //search for all related active PORs
                lstPOR = [SELECT Id,Customer__c,Partner__c FROM Partner_of_Record__c WHERE 
                                              (Customer__c IN :accIdLst OR Partner__c IN :prtnrIdLst) AND Status__c='Active'];                                           
                if(lstPOR.size()>0){
                    for(Opportunity opp: newOpps){
                        isPOR = false;
                        if(opp.Product_Type__c == 'Modular'){
                            for(Partner_of_Record__c p :lstPOR){
                                //system.debug('lstPOR::::'+lstPOR);
                                if(p.Customer__c == opp.AccountId && ((oldMapOpps == null && p.Partner__c == prtnrIdLst[0]) ||
                                (oldMapOpps != null && opp.PartnerAccountId!= null && p.Partner__c == opp.PartnerAccountId))){
                                    opp.isPOROpportunity__c = true;
                                    opp.Partner_Opportunity_Verification__c = 'Approved';//Auto Approve if active POR
                                    isPOR = true;                                              
                                    break;
                                }
                            }
                            if(!isPOR)
                                opp.isPOROpportunity__c = false;
                        }
                        else{
                            opp.isPOROpportunity__c = false;
                        }
                    }
                }
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpportunityTriggernewHelper Class, updatePORStatus Method'+ Ex.getMessage());
        }
    }

    // Related to PRM (Team Orlando)
    public  void validateContactrole(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps,List<Opportunity> newOpps){
        map<id,boolean> OppContactRoleMap= new map<id,boolean>();
        list<id> oppidlist= new list<id>();
      //  Id profileId=userinfo.getProfileId();
      //  String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
     //   system.debug('loggedin user'+profileName);
        try{
            if(!newMapOpps.isEmpty() && newMapOpps.size()>0){
                if(!oldMapOpps.isEmpty() && oldMapOpps.size()>0){
                    if(newMapOpps.values().size()>0){
                        for(Opportunity opp : newMapOpps.values()){
                            oppidlist.add(opp.id);
                        }
                        
                        OppContactRoleMap=OpportunityTriggerHelper.checkOppContactRole(oppidlist);
                        
                        for(Opportunity opp : newMapOpps.values()){
                            opportunity oldOpp = oldMapOpps.get(opp.ID);
                            
                            //EDGE-151595 Bypassing below validations if Opportunity has an active POR
                            //EDGE-71787 Replacing the custom field Partner_Account__c with salesforce OOTB field PartnerAccountId
                           //if(opp.PartnerAccountId!=null && opp.PartnerAccountId!=oldOpp.PartnerAccountId && OppContactRoleMap.containsKey(opp.id) &&  OppContactRoleMap.get(opp.id)==true && ((profileName != PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA) || (profileName != PRMConstants.PRM_PROFILE_PRM_Admin_Australia))){
                           if(opp.isPOROpportunity__c == false && opp.PartnerAccountId!=null && opp.PartnerAccountId!=oldOpp.PartnerAccountId && OppContactRoleMap.containsKey(opp.id) &&  OppContactRoleMap.get(opp.id)==true && opp.Opportunity_Source__c != 'Partner'){
                                     opp.addError(label.PRM_PARTNER_OPPORTUNITY_VERIFICATION_MESSAGE);
                                
                           }
                            else if(opp.isPOROpportunity__c == false && opp.Partner_Opportunity_Verification__c!=null && opp.Partner_Opportunity_Verification__c!=oldOpp.Partner_Opportunity_Verification__c && OppContactRoleMap.containsKey(opp.id) && opp.Partner_Opportunity_Verification__c==PRMConstants.PRM_APPROVED_STATUS &&  OppContactRoleMap.get(opp.id)==true){
                                opp.addError(label.PRM_SUBMIT_TO_PARTNER_MESSAGE);
                                
                            }
                        }
                    }
                }
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpportunityTriggerHandler Class, onBeforepdate Method'+ Ex.getMessage());
            
        }
    }
}
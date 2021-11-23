/**
* Trigger ON ACR object  For EDGE-38 AC2 
* @Description : EDGE 38. Custom Invoking Manage Interface Dynamically
* @Author : Shambo Ray
* @Date : 01/01/2018
* @Story : EDGE-38 : Invoking Manage Interface Dynamically
* @Story : EDGE-52 : New Method For EDGE-52 : Roles validation Modified Date: 24/02/2018
***/
/*
 * Modified By : Team Lisbon
 * Date : 22/10/2020
 * Jira : P2OB-9530 
 * Description : making changes in After update trigger hander of Contact and AccountContactRelation Object. 
				 So that specific field update for this object will trigger CustomerMS event. To Monitor Fields we have 
				 created CustomMetadata.Utility Class check Update against specific Field: FieldUpdateIdentifier
 * Updates :
	11/02/2020 : P2OB-10463 : Correcting Operation type when new ACR is created
* Updates  :
		16/05/2021 : DIGI-4057

*/
public without sharing class  AccountContactRelationshipTriggerHandler {
    //EDGE-52: Validation on AccountContactRelation
    //public static boolean UIUpdate = true;
    private static Boolean run = true;
    public static Boolean importFlag=false;
    public static Boolean insertFlag=false;
    private AccountContactRelationshipTriggerHelper acrHelper = null;
    private IntegrationSettings__c iSettings = null;   
    public static boolean stopRecursivebeforeupdate = false;
    
    private static Boolean isAfterInsert=false;
     private static Boolean isAfterUpdate=false;
    
	public static Boolean isFirstTime = true;
    public AccountContactRelationshipTriggerHandler(){
        acrHelper = new AccountContactRelationshipTriggerHelper();
        iSettings = IntegrationSettings__c.getOrgDefaults(); 
    }
    
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
    
     public void onAfterInsert(Map<ID,AccountContactRelation> newMap){
         if(!isAfterInsert){
             List<AccountContactRelation> acrListToPublish  = fetchACRforPublish(newMap);
             system.debug('>>>>>>>>>acrMap '+acrListToPublish);
             //P2OB-10463 : Correcting Operation type when new ACR is created
             acrHelper.publishCreateEvents(acrListToPublish,EventConstants.CREATE_OPERATION);
         }
         isAfterInsert=true;
    }
    
    public void onAfterUpdate(List<AccountContactRelation> newList,Map<ID,AccountContactRelation> oldMap,Map<ID,AccountContactRelation> newMap){
        if(!isAfterUpdate){
            List<AccountContactRelation> acrListToPublish  = fetchACRforPublish(newMap);
            system.debug('>>>>>>>>>acrMap '+acrListToPublish);
            acrHelper.trackHistoryOfACRToACRHistoryObj(oldMap,newMap);
            //acrHelper.publishCreateEvents(acrListToPublish,EventConstants.UPDATE_OPERATION);
            // acrHelper.makeContactasInactive(newMap,oldMap);//EDGE-36365(AC5) Keeping Dormant
            
            //Below Lines are just for Testing ,,, need to remove this.
            /*DataReplicationbtwConAndACR dracrToCon = new DataReplicationbtwConAndACR();
				dracrToCon.copyFromACRToCon(oldMap, newList);
				*/
            //P2OB-9530 : CustomerMS event for only for specific field Update
             List<AccountContactRelation> CustomerMS_ACR_List = new List<AccountContactRelation>();

             if(acrListToPublish.size()>0){
                    FieldUpdateIdentifier fui = new FieldUpdateIdentifier(AccountContactRelation.SobjectType,Label.CustomerMS_Integration);
                    Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(newMap, oldMap);
                    system.debug('Match Contact Record :'+matches);                  
        
                    for(AccountContactRelation acr:acrListToPublish){              
                                if(matches.containsKey(acr.Id)){
                                    CustomerMS_ACR_List.add(acr);                        
                                }
                    }
                   
                    if(CustomerMS_ACR_List!=null && !CustomerMS_ACR_List.isEmpty()){
                        acrHelper.publishCreateEvents(CustomerMS_ACR_List, EventConstants.UPDATE_OPERATION);
                    }
                
                }
        	}
        isAfterUpdate=true;
    }
    
    public void onBeforeInsert(List<AccountContactRelation> newList){
        acrHelper.updateACRFields(newList,null); //Sprint 20.03,Team SFO,Added as per the User Story P2OB-4875

        //List<AccountContactRelation> acrList = (List<AccountContactRelation>)newList;
        if(iSettings!=null && System.UserInfo.getUserName() != iSettings.Integration_API_User__c && !AccountContactRelationshipTriggerHandler.importFlag){
            acrHelper.onBeforeLegallesse(newList);  
        }
    }
    
    public void onBeforeUpdate(Map<Id,AccountContactRelation> newACRMap,Map<Id,AccountContactRelation> oldACRMap){   
        // SFO: below logic for update field values before Update, so skipped for including in Recursive : comment added in 20.05
        acrHelper.updateACRFields(newACRMap.values(),oldACRMap); //Sprint 20.03,Team SFO,Added as per the User Story P2OB-4875
        // SFO: Above logic for update field values before Update, so skipped for including in Recursive : comment added in 20.05
        
        if(!stopRecursivebeforeupdate){  // Nirvana Production Fix Case Number : 00018544            
            //acrHelper.validationForActiveFCR(newACRMap,oldACRMap);//Kala, EDGE - 35520 Keeping Dormant
            if(AccountContactRelationshipTriggerHandler.runOnce()){
                
                if(!AccountContactRelationshipTriggerHandler.insertFlag && System.UserInfo.getUserName() != iSettings.Integration_API_User__c && !AccountContactRelationshipTriggerHandler.importFlag){
                    acrHelper.onBeforeLegallesse(newACRMap.values());
                }
                if(iSettings.EnableManageInterfaces__c && !AccountTriggerHelper.isAsyncJob() && System.UserInfo.getUserName() != iSettings.Integration_API_User__c){
                    acrHelper.sendManageContact(newACRMap,oldACRMap);
                }
                if(System.UserInfo.getUserName() == iSettings.Integration_API_User__c){
                    Set<Id> contactIds = new Set<Id>();
                    Boolean isTrackingHistoryRequest = false;
                    for(Id acrId : newACRMap.keySet()){
                        AccountContactRelation acrNotify  = newACRMap.get(acrId);
                        if(acrNotify.Relationship_End_Date__c != null && acrNotify.Relationship_End_Date__c == Date.today()){
                            contactIds.add(acrNotify.ContactId);
                            isTrackingHistoryRequest = true;
                        }
                    }
                    if(isTrackingHistoryRequest){
                        acrHelper.trackHistoryOfACRToACRHistoryObj(oldACRMap,newACRMap);
                    }
                    if(!contactIds.isEmpty()){
                        acrHelper.updateACRRoleandCleanRelEndDate(contactIds,newACRMap);
                    }
                }
            }            
        }
        stopRecursivebeforeupdate = true;
    }
    private List<AccountContactRelation>  fetchACRforPublish(Map<ID,AccountContactRelation> newMap){
        Map<ID,AccountContactRelation> acrMap = new Map<ID,AccountContactRelation>([SELECT AccountId,  createddate, contact.createddate, lastmodifieddate, contact.lastmodifieddate, Account_Name__c FROM AccountContactRelation where Id IN :newMap.keySet()]);
        List<AccountContactRelation> acrListToPublish = new List<AccountContactRelation> ();
        
        for(Id acrId : acrMap.keyset()){
            AccountContactRelation acr = acrMap.get(acrId);
            if((acr.lastmodifieddate).minute() != (acr.contact.lastmodifieddate).minute()){
                acrListToPublish.add(newMap.get(acrId));
            }
        }
        return acrListToPublish;
    }
    
    /* Description : TO check if the contact is being deactivated or Remove "Billing or create and edit user permissions" is not last contact with this access on Account
Team           : SFO 
Sprint         : 21.11 
Stroy          : DIGI-4057 
Author         : Chhaveel Thakur
*/ 
    public void onBeforeDelete(Map<ID,AccountContactRelation> oldMap){
        acrHelper.onACRDelete(oldMap);
    }
    
}
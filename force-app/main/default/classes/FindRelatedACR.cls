/*******************************************************************
@Class Name:FindRelatedACR
@Description:Sprint 19.07 , EDGE-84140
@Date:30-05-2019
@Author:SFO Team (Subani & Sravanthi)
@Comments:To Fetch primary ACR for the contact passed lightning component EditPrimaryACR.

@Last Modified By: Sri Chittoori(Team SFO)              
@Last Modified Comments: EDGE-104316             

*********************************************************************/
public without sharing class FindRelatedACR {
    
    @AuraEnabled  
    public static String getPrimaryACRData(Id recordId) {  
        try{
        System.debug('Contact record: ' + recordId);        
        AccountContactRelation data = [SELECT Id, Contact.Name, Account.Name, ContactId, AccountId, IsDirect, Job_Description__c, Seniority_Level__c, Relationship_End_Date__c FROM AccountContactRelation WHERE contactId = :recordId AND IsDirect = True];
        System.debug('data ' + data);
        return JSON.serialize(data); 
        }
        catch(QueryException e){
            return e.getMessage();
        }
    }
    
    //to check the records access for the user :: EDGE-104316   
    @AuraEnabled  
	public static Boolean getACRRecordAccess(Id recordId) {  
        try{
        System.debug('Contact record: ' + recordId);
        AccountContactRelation data = [SELECT Id FROM AccountContactRelation WHERE contactId = :recordId AND IsDirect = True];
        List<UserRecordAccess>  editAccess =[SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =:UserInfo.getUserId() AND RecordId = :data.Id Limit 1];
        System.debug('data ' + data);
        return editAccess[0].HasEditAccess; 
        }
        catch(QueryException e){
            return FALSE;
        }
    }
}
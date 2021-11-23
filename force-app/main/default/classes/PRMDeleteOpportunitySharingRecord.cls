/*******************************************************************
Created By          :   Team Hawaii (Paresh)
Created Date        :   30/8/2019
Desc                :   This Class is called from Flow 'PRM Share Opportunity Record with Partner Principle Contact' which delete existing opportunity share record to partner users                                 
***********************************************************************/

public class PRMDeleteOpportunitySharingRecord {
  
    @InvocableMethod
    public static void deleteExistingSharingRecordWithPartner(List<Id> Id){
        
        if(Id.Size() > 0){
        
             List<OpportunityShare> opptyShareRecords = new List<OpportunityShare>([SELECT id, opportunityId, UserOrGroupId,userOrGroup.Profile.UserType FROM OpportunityShare WHERE opportunityId in :Id AND RowCause = 'Manual' and userOrGroup.Type = 'User' AND userOrGroup.Profile.UserType = 'PowerPartner']);
             if(opptyShareRecords.size() > 0){
                 Delete opptyShareRecords; 
             }
        }
    }
}
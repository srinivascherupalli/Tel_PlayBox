/*******************************************************************
Created By          :   Team Hawaii
Created Date        :   1/4/2020
Desc                :   Partner Users are not able to chatter using standard Post to Chatter action.So created custom logic to
                        Chatter on Internal User using Partner User.This Class is Called from Process Builder 'PRM Lead Submit to Partner'
Jira                :   P2OB-5510 And P2OB-5535
***********************************************************************/
public without sharing class PRMChatterToInternalUser{
    private static final String Share_With_Partner_Approved = 'Approved';
    private static final String Share_With_Partner_Rejected = 'Rejected';
    private static final String Share_With_Partner_Submitted = 'Submitted';
    private static final String Status_Rejected = 'Rejected';
    private static final String Status_Recycled = 'Recycled';
    private static final String  Lead_Name = '<Lead Name>';
    private static final String  Lead_Account_Name = '<Lead Account Name>';
    private static final String  Partner_Name = '<Partner Name>';
    private static final String  Decline_Reason = '<Declined Reason>';
    @InvocableMethod
    public static void addChatter(List<Id> leadIds){
        if(leadIds != Null && leadIds.size() > 0){
            List<Lead> leadList = [Select id,Name,Status,Share_with_Partner_Status__c,FirstName,LastName,Please_Specify__c,PRM_Reject_Recycle_Reason__c,Declined_Comments__c,Declined_Reason__c,Customer_Name__c,Shared_By__c,Customer_Name__r.Name,OwnerId,PartnerAccountId,PartnerAccount.Name from Lead where Id IN : leadIds];
            List<FeedItem> lstPosts = new List<FeedItem>();
            for(Lead le : leadList){
                if(le.Share_with_Partner_Status__c != Null && le.Customer_Name__c != Null && le.Shared_By__c != Null && le.PartnerAccountId != Null){
                    String Body = '';
                    FeedItem newPost = new FeedItem();
                    newPost.ParentId = le.Id;
                    newPost.createdById = UserInfo.getUserId();
                    newPost.type = 'TextPost';
                    if(le.Status != Null && le.Status == Status_Rejected && String.IsNotBlank(le.PRM_Reject_Recycle_Reason__c)){
                        Body = Label.PRM_Notification_On_Rejected_Status;
                        Body = Body.replace(Lead_Name, le.FirstName + ' '+ le.LastName);
                        Body = Body.replace(Lead_Account_Name, le.Customer_Name__r.Name);
                        Body = Body.replace(Partner_Name, le.PartnerAccount.Name);
                        String reason = String.IsNotBlank(le.Please_Specify__c) ? le.PRM_Reject_Recycle_Reason__c + ' ' + le.Please_Specify__c : le.PRM_Reject_Recycle_Reason__c;
                        Body = Body.replace(Decline_Reason, reason);
                    }else if(le.Status != Null && le.Status == Status_Recycled && String.IsNotBlank(le.PRM_Reject_Recycle_Reason__c)){
                        Body = Label.PRM_Notification_On_Recycled_Status;
                        Body = Body.replace(Lead_Name, le.FirstName + ' '+ le.LastName);
                        Body = Body.replace(Lead_Account_Name, le.Customer_Name__r.Name);
                        Body = Body.replace(Partner_Name, le.PartnerAccount.Name);
                        String reason = String.IsNotBlank(le.Please_Specify__c) ? le.PRM_Reject_Recycle_Reason__c + ' ' + le.Please_Specify__c : le.PRM_Reject_Recycle_Reason__c;
                        Body = Body.replace(Decline_Reason, reason);
                    }
                    else if(le.Share_with_Partner_Status__c == Share_With_Partner_Approved){
                        Body = Label.PRM_Notification_On_Approved;
                        Body = Body.replace(Lead_Name, le.FirstName + ' '+ le.LastName);
                        Body = Body.replace(Lead_Account_Name, le.Customer_Name__r.Name);
                        Body = Body.replace(Partner_Name, le.PartnerAccount.Name);
                    }else if(le.Share_with_Partner_Status__c == Share_With_Partner_Rejected){
                        Body = Label.PRM_Notification_On_Rejected;
                        Body = Body.replace(Lead_Name, le.FirstName + ' '+ le.LastName);
                        Body = Body.replace(Lead_Account_Name, le.Customer_Name__r.Name);
                        Body = Body.replace(Partner_Name, le.PartnerAccount.Name);
                        if(String.IsNotBlank(le.Declined_Reason__c)){
                            String reason = String.IsNotBlank(le.Declined_Comments__c) ? le.Declined_Reason__c + ' ' + le.Declined_Comments__c : le.Declined_Reason__c;
                            Body = Body.replace(Decline_Reason, reason);
                        }
                    }else if(le.Share_with_Partner_Status__c == Share_With_Partner_Submitted){
                        Body = Label.PRM_Notification_On_Recalled;
                        Body = Body.replace(Lead_Name, le.FirstName + ' '+ le.LastName);
                        Body = Body.replace(Lead_Account_Name, le.Customer_Name__r.Name);
                    }
                    newPost.Body = Body;
                    lstPosts.add(newPost);
                }
            }
            if(!lstPosts.isEmpty()){
                insert lstPosts;
            }
        }
    }
}
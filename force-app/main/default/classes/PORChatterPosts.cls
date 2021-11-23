/* EDGE-150894 : As a Partner Admin/Manager, AE/CE/ I want Partner Of Record Approval and Rejection Chatter Notifications
B2B-1443 :Team Alexandria 
@createdBy    - Sri Ramya
@ModifiedBy - Karthik for EDGE-203922 on 20-May-2021
*/

public class PORChatterPosts {
    
    /**
*  The method will execute from the "POR Status Updates" Process Builder.
*  @name processCaseRecord
*  @param porId - List of POR's
*/
    @InvocableMethod
    public static void sendPORStatusChatter(List<Id> porId){
        try{
        Network n = [SELECT Id, Name FROM network WHERE Name = 'EDGE Partners'];
        String Networkid=Network.getnetworkid();
        Boolean statusFlag = false;
        //  for(  Partner_of_Record__c porquery : porList)
        //   {  
        Partner_of_Record__c por = [SELECT id, Name,Account_Executive__r.id,Account_Executive__r.name, Status__c,Sub_Status__c,Customer__r.Account_Owner__c,Partner__c,Cancelled_User__r.Name, OwnerId,Owner.name, Account_Executive__c,Partner_Signatories__c, Customer__c, Customer__r.Name,Customer__r.APTPS_DocuSign_Restricted__c,Customer__r.APTPS_Off_Shore_Restricted__c, CreatedDate, Is_Domain_Cancelled__c from Partner_of_Record__c WHERE Id =: porId];     //get the partner of record details
        
        //EDGE-203922 - posting chatter for  ICM / POR approval group
        List<GroupMember> grpMembr = [SELECT Id,UserOrGroupId FROM GroupMember WHERE GroupId in (select Id from Group Where name='Partner of Record Approvers' AND Type = 'Queue' )];  
        if(por.Status__c == 'Modification in progress' &&  por.Sub_Status__c != 'Partner Review' && por.Sub_Status__c == 'Pending Approval'){        
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id ,'Hi {' + por.Account_Executive__c + '}, A modified Partner of Record Agreement has been submitted by ' + por.Owner.name + ' for ' +por.Customer__r.name+ ', please review and action the Agreement {record:' +por.Id+ '}.'); 
            //ConnectApiHelper.postFeedItemWithMentions(n.id, 'Account_Executive__c' ,'Hi A modified Partner of Record Agreement has been submitted by ');  
            for(GroupMember gp : grpMembr){
                ConnectApiHelper.postFeedItemWithMentions(n.id, gp.UserOrGroupId ,'Hi {' + gp.UserOrGroupId + '}, A modified Partner of Record Agreement has been submitted by ' + por.Owner.name + ' for ' +por.Customer__r.name+ ', please review and action the Agreement ' +por.Name+ '.');   
               // ConnectApiHelper.postFeedItemWithMentions(null, por.Id ,'Hi {' + gm.UserOrGroupId + '}, A modified Partner of Record Agreement has been submitted by');     
            } 
            statusFlag = true;
        }
        
        
        if(por.Status__c == 'Pending Approval' ) {
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.Account_Executive__c + '}, A new Partner of Record Agreement has been submitted by {' + por.OwnerId + '} for {record:' +por.Customer__c+ '}, please review and action the Agreement {record:' +por.Id+ '}.');
        }
        //EDGE-203922 - added not equal to modification condition to avoid duplicate notifications
        if(por.Sub_Status__c == 'Pending Approval' && por.Status__c != 'Modification in progress') { //EDGE-167051 Renew POR
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.Account_Executive__c + '}, A Partner of Record Agreement has been submitted for renewal by {' + por.OwnerId + '} for {record:' +por.Customer__c+ '}, please review and action the Agreement {record:' +por.Id+ '}.');
        }
        if((por.Status__c == 'Declined' || por.Sub_Status__c == 'Declined') && !Test.isRunningTest() && !statusFlag){
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement submitted on  ' + por.CreatedDate + ' for ' + por.Customer__r.Name + ' , has been declined. Review the Agreement {record:' +por.Id+ '} for details.'); 
        }
        //Added as part of EDGE-207102 to send chatter for user 
        if((por.Status__c == 'Customer Review' || por.Sub_Status__c == 'Customer Review') && por.Is_Domain_Cancelled__c == false) {
            
            if(por.Customer__r.APTPS_DocuSign_Restricted__c == TRUE )
            {
                ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.OwnerId + '}, Partner of Record Agreement {record:' +por.Id+ '}, for {record:' +por.Customer__c+ '} has been approved. This customer is DocuSign Restricted. Please refer to the QRG link and follow the manual process for signatures.');
                
            }
            if(por.Customer__r.APTPS_Off_Shore_Restricted__c == TRUE && !por.Customer__r.APTPS_DocuSign_Restricted__c == TRUE){
                
                ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.OwnerId + '}, Partner of Record Agreement {record:' +por.Id+ '} has been approved. Please refer to the QRG and follow the manual process for signatures as the {record:' +por.Customer__c+ '} is Offshore Restricted.');
   
            }
            else
            {
                ConnectApiHelper.postFeedItemWithMentions(null, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement  {record:' +por.Id+ '} , for ' + por.Customer__r.Name + ' has been approved. The customer has now been requested to review and sign.');
            }
        }
        if(por.Status__c == 'Partner Review' || por.Sub_Status__c == 'Partner Review') {
            ConnectApiHelper.postFeedItemWithMentions(null, por.Account_Executive__c,'Hi {' + por.Account_Executive__c + '}, Partner of Record Agreement {record:' +por.id+ '} for {record:' +por.Customer__c+ '}, has been signed by the Customer. {' + por.OwnerId + '} has now been requested to countersign.');
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement  {record:' +por.Id+ '}  for ' + por.Customer__r.Name + ', has been signed by the Customer. You {' + por.OwnerId + '} have now been requested to countersign.');
            //EDGE-203922 - posting chatter for  ICM / POR approval group 
            for(GroupMember gp:grpMembr){
                ConnectApiHelper.postFeedItemWithMentions(null, gp.UserOrGroupId,  'Hi {' + gp.UserOrGroupId + '}, Partner of Record Agreement  {record:' +por.Id+ '}  for ' + por.Customer__r.Name + ', has been signed by the Customer. You {' + por.OwnerId + '} have now been requested to countersign.');
            }    
        }
        if((por.Status__c == 'Customer Declined' || por.Sub_Status__c == 'Customer Declined') ) {
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.Account_Executive__c + '}, Partner of Record Agreement {record:' +por.id+ '} for {record:' +por.Customer__c+ '}, has been declined by the customer.');
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement  {record:' +por.Id+ '} for ' + por.Customer__r.Name + ' has been declined by the customer.');
            //EDGE-203922 - posting chatter for  ICM / POR approval group 
            for(GroupMember gp:grpMembr){
                ConnectApiHelper.postFeedItemWithMentions(null, gp.UserOrGroupId,'Hi {' + gp.UserOrGroupId + '}, Partner of Record Agreement {record:' +por.id+ '} for ' + por.Customer__r.Name + ', has been declined by the customer.');
            }     
        }
        if(por.Status__c == 'Partner Declined' || por.Sub_Status__c == 'Partner Declined') {
            ConnectApiHelper.postFeedItemWithMentions(null, por.Account_Executive__c,'Hi {' + por.Account_Executive__c + '}, Partner of Record Agreement {record:' +por.id+ '} for {record:' +por.Customer__c+ '}, has been declined by {' + por.OwnerId + '}.');
            //EDGE-203922 - posting chatter for  ICM / POR approval group 
            for(GroupMember gp:grpMembr){
                ConnectApiHelper.postFeedItemWithMentions(null, gp.UserOrGroupId,'Hi {' + gp.UserOrGroupId + '}, Partner of Record Agreement {record:' +por.id+ '} for ' + por.Customer__r.Name + ', has been declined by {' + por.OwnerId + '}.');    
            }    
        }   
        if(((por.Status__c == 'Active' && por.Sub_Status__c == null)|| por.Sub_Status__c == 'Active') && por.Is_Domain_Cancelled__c == false) {
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.Account_Executive__c + '}, Partner of Record Agreement {record:' +por.id+ '} for {record:' +por.Customer__c+ '}, has been signed by the customer and partner.');
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement  {record:' +por.id+ '} for ' + por.Customer__r.Name + ', has been signed by the customer and partner.');
            //EDGE-203922 - posting chatter for  ICM / POR approval group 
            for(GroupMember gp:grpMembr){
                ConnectApiHelper.postFeedItemWithMentions(null, gp.UserOrGroupId,  'Hi {' + gp.UserOrGroupId + '}, Partner of Record Agreement  {record:' +por.id+ '} for ' + por.Customer__r.Name + ', has been signed by the customer and partner.');
            }   
        }
        if(por.Status__c == 'Cancelled'){
            ConnectApiHelper.postFeedItemWithMentions(null, por.Id,'Hi {' + por.Account_Executive__c + '}, Partner of Record Agreement {record:' +por.id+ '} for {record:' +por.Customer__c+ '} has been cancelled by {' + por.Cancelled_User__c + '}.');
            //ConnectApiHelper.postFeedItemWithMentions(n.Id, por.Id,  'Hi {' + por.OwnerId + '}, Partner of Record Agreement  ' + por.Name + ' for ' + por.Customer__r.Name + ', has been cancelled as requested.');
            ConnectApiHelper.postFeedItemWithMentions(n.Id, por.Id,  'Hi {' + por.Cancelled_User__c + '}, Partner of Record Agreement  ' + por.Name + ' for ' + por.Customer__r.Name + ', has been cancelled as requested.');
            
        }
        }  
            Catch(Exception e){
            system.debug('exception line '+e.getLineNumber()+'exception os '+e.getMessage());
            
        } 
    
     }  
}
/*****************************************************************************
@Author: Shamikh Hassan
@CreateDate: 1-APR-2019
@ModifiedByandDate: Shamikh Hassan:: 24-APR-2019 :: Comments added inside methods
@Description: This class contains   trigger handler logic for child case and Case Line Items. 
@References
Epic :EDGE-53259 ::SF&D Reporting & Additional Enhancements
Story:EDGE-53126:As a SFD Manager, I need to be alerted by email & chatter if any of the SFD queues have 10 or more requests open

*******************************************************************************/
public without sharing class soc_QueueLimitNotification {
    
    //Maximum number of cases allowed in queue
    public static final Integer LIMIT_CASES=Integer.valueOf(System.label.soc_Queue_Limit_Number);
    public static final String EMAIL_SUBJECT=System.label.soc_Queue_Limit_Email_Subject;
    public static final String SLA_MANAGER_GRP_NAME=System.label.soc_SLA_Mgr_public_Grp_Name;
    //Comma separated Queue name where Queue Notification is applied
    public static List<String> queueDeveloperNames = System.Label.soc_SFD_Queue_Developer_Names.split(',');


     /**
      * This method triggers the alert process. Scheduled in soc_QueueLimitNotificationScheduler
      * @Author: Shamikh Hassan
      * @Date: 1-APR-2019
      */
     public static void triggerQueueLimitNotification() {
         
         try{
             //Getting all queues where limit has exceeded
          List < group > groupsExceedingLimit = findQueuesExceedinglimit();
             if(groupsExceedingLimit.size()>0){
                 //Sending Email to SLA Managers group
                notifySLAmanagerEmail(groupsExceedingLimit);
             }
         }
         catch(Exception e){
             system.debug('Exception >>>>>');
             system.debug(e.getMessage());
             system.debug(e.getLineNumber());  
         }
     }
    
     /**
      * This method return the Queues that have exceeded the case limit
      * @Author: Shamikh Hassan
      * @Date: 1-APR-2019
      */
     /*public static List < group > findQueuesExceedinglimit() {    
      List < group > groupsExceedingLimit = new List < group > ();     
      Map < ID, group > m = new Map < ID, group > ([SELECT Id, DeveloperName, Name FROM group where Type = 'Queue' and
       DeveloperName in: queueDeveloperNames
      ]);    
      for (group g: m.values()) {
       List < Case > queueCases = [select id, ownerId from
        case where ownerid =: g.id limit: LIMIT_CASES
       ];
       if (queueCases.size() == LIMIT_CASES) {
        groupsExceedingLimit.add(g);
       }
      }
      return groupsExceedingLimit;
    
     }*/
    /**
      * This method return the Queues that have exceeded the case limit
      * @Author: Shamikh Hassan
      * @Date: 1-APR-2019
      * @ModifiedDate : 19-JUL-2019 :: Removed SOQL inside for loop
      */
    public static List < group > findQueuesExceedinglimit() {    
      List < group > groupsExceedingLimit = new List < group > ();     
      Map < ID, group > m = new Map < ID, group > ([SELECT ID, DeveloperName, Name FROM GROUP WHERE Type = 'Queue' AND
       DeveloperName IN: queueDeveloperNames
      ]);
        Set<Id> groupIds=m.keyset(); 
        
      AggregateResult[] results=[SELECT owner.Id ownerId, COUNT(Id) cnt FROM case  GROUP BY ROLLUP(owner.Id)];
        
        for(AggregateResult ag:results){
            String ownerId=String.valueOf(ag.get('ownerId'));
            Integer count=Integer.valueOf(ag.get('cnt'));
            if(groupIds.contains(ownerId) && count>=LIMIT_CASES){
                groupsExceedingLimit.add(m.get(ownerId));
            }
        }
        
      system.debug('groupsExceedingLimit');
      system.debug(groupsExceedingLimit);
      return groupsExceedingLimit;
        
    
     }
    
     /**
      * This method formats the email and send the email to the SLA MAnagers
      * @Author: Shamikh Hassan
      * @Date: 1-APR-2019
      */
     public static void notifySLAmanagerEmail(List < Group > groupsExceedingLimit) {
    
      List < Messaging.SingleEmailMessage > mails = new List < Messaging.SingleEmailMessage > ();
      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      String allQueues = '';
      Integer i = 1;
      for (Group g: groupsExceedingLimit) {
    
       allQueues = allQueues + '<b>' + i + '.  ' + g.name + '</b></br>';
       i = i + 1;
      }
         //Getting email body from custom label
      mail.setHtmlBody(string.format(Label.soc_Queue_Limit_Email_Body, new List<String>{allQueues}));
      //mail.setHtmlBody('Dear Team, <br/><br/> The following queues <br/><br/><b>' + allQueues + '</b><br/> has ten or more cases open as all agents have work assigned to their maximum capacity. Kindly add new members or manually assign cases to any person of your choice. <br/><br/> Thanks, <br/>Salesforce Admin');
      mail.setSubject(EMAIL_SUBJECT);
      mail.setToAddresses(getMailAddresses());
      mails.add(mail);
         mail.setReplyTo('do-not-reply-phoenix@team.telstra.com');
  		 mail.setSenderDisplayName('Do Not Reply Phoenix');
      Messaging.sendEmail(mails);    
     }
    
    
     /**
      * This utility method return the email adresses of SLA Managers
      * @Author: Shamikh Hassan
      * @Date: 1-APR-2019
      */
     public static List < String > getMailAddresses() {
      List < String > idList = new List < String > ();
      List < String > mailToAddresses = new List < String > ();
    
      Group gp = [SELECT(SELECT UserOrGroupId FROM GroupMembers) FROM Group WHERE developerName = :SLA_MANAGER_GRP_NAME];
      for (GroupMember gm: gp.GroupMembers) {
       idList.add(gm.UserOrGroupId);
      }
      List < User > userList = [SELECT Email FROM User WHERE Id IN: idList];
      for (User u: userList) {
       mailToAddresses.add(u.email);
      }
      //Returning email adresses of all the SLA manager group members
      return mailToAddresses;
     }
     
 
}
/**
   *  Description : To send Audit Log details over email
   *@ <Jira Story Ref>EDGE-96588<Jira Story Ref>
*/

public with Sharing class AuditLogsScanner {

    // lookback period
    public static integer lookbackHoursPeriod = Integer.valueof(System.Label.AudittrailLogHours);
    // List of Salesforce user ids to send the email to
    public static List<String> sendEmailto = getEmails();
    // List of sections to ignore from the audit log events
    public static Set<String> includeSections = getSectionNames();
    // List of users to monitor
    public static List<String> usersNotToMonitor = getUsersToExclude();
    // Email subject
    public static String emailSubject = 'Audit Log - '+UserInfo.getUserName().substringAfterLast('.'); 
    //Table headers
    public static List<String> tableHeaders = new List<String>{'User', 'Section', 'Action', 'Details','Created Date'};
     
    /*
        Get Section Names from Custom Settings

        @param body
        Set of Strings for Section Names
    */
    public static Set<String> getSectionNames(){
        Set<String> sectionNames = new Set<String>();
        for (AuditTrail_Sections__c setting : AuditTrail_Sections__c.getAll().values()){
            sectionNames.add(setting.Name);
        }
        return sectionNames;
    }
    /*
        Get Email List from Custom Settings

        @param body
        List of Strings for Emails
    */
    public static List<String> getEmails(){
        List<String> emailList = new List<String>();
        for (AuditTrail_Emails__c setting : AuditTrail_Emails__c.getAll().values()){
            emailList.add(setting.Email__c);
        }
        return emailList;
    }
    /*
        Get User Names from Custom Settings

        @param body
        List of Strings for User Names
    */
    public static List<String> getUsersToExclude(){
        List<String> usersList = new List<String>();
        for (AuditTrail_UsersToExclude__c setting : AuditTrail_UsersToExclude__c.getAll().values()){
            usersList.add(setting.User_Name__c);
        }
        return usersList;
    }
    /*
        Sends an email to the Salesforce users defined by sendEmailTo

        @param body
        List of Strings to create the body of the email
    */
        
    public void sendEmailMessage(List<String> body) {
        if (body == NULL || body.isEmpty()) {
            return;
        }

        // Construct the Single Email Message and HTML table

        String tableContent = '<table border="1"><tr>';
        for( String row : tableHeaders){
            tableContent = tableContent + '<th>' + row + '</th>';
        }
        tableContent = tableContent + '</tr>';
        body.add(0, tableContent);
        body.add('</table>');
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = sendEmailto;
        message.subject = emailSubject;
        String messageBody = String.join(body, '\n\n');
        message.htmlbody = messageBody;

        try {
            // Do not check for errors as nothing to do in that case
            // We just want to bail out gracefully
            if(!Test.isRunningTest()){
            	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {message});
            }
        } catch(System.CalloutException e) {
            System.debug('ERROR:' + e);
        }
    }

    /*
        Get the audit log events that occured in a lookback 
        period and were triggered by specific users
        
        The default lookback period (lookbackHoursPeriod) is one hour
        This method calls sendEmailMessage to send an email with the events
    */
    public void parseAuditLogs() {
        DateTime dt = System.Now().addHours(lookbackHoursPeriod);

        // run SOQL on SetupAuditTrail for filtering
        List<SetupAuditTrail> queryResults = [SELECT CreatedDate, CreatedBy.UserName, CreatedBy.Name,
                                                  Action, Section, Display  
                                                  FROM SetupAuditTrail 
                                                  WHERE CreatedBy.UserName NOT IN :usersNotToMonitor 
                                                  AND CreatedDate >=:dt 
                                                  ORDER BY CreatedDate DESC
                                                  LIMIT 50000
                                             ];
        if (queryResults.isEmpty()) {
            return;
        }

        // parse the query to build the body for the email
        List<String> emailBodyList = new List<String>();
        for (SetupAuditTrail log: queryResults) {
            if (includeSections.contains(log.section)) {
                String tableRow = '<tr><td>' + log.CreatedBy.Name 
                                   + ' </td><td>' + log.Section + ' </td><td> ' 
                                   + log.Action + ' </td><td> ' + log.Display + '</td><td>' + log.CreatedDate + '</td></tr>';
                emailBodyList.add(tableRow);
            }
        }
        if (!emailBodyList.isEmpty() && sendEmailto != null && !sendEmailto.isEmpty()) {
            sendEmailMessage(emailBodyList);
        }
    }
}
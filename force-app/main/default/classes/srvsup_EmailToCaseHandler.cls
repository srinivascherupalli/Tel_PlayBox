/*****************************************************************************
@Author: Kritika Bhati
@CreateDate: 6-June-2019
@ModifiedByandDate: <5th July 2019> |Kritika Bhati
@Description: This class contains handler logic for Email to Case creation. 
@References
Epic :EDGE-75536: Email To Case Creation (No auto forward) for Sales, Certitude, Service
@ModifiedByandDate: <14th Feb 2020> Shreyansh Sharma(Team Jaipur)
@Updateddescription: Adding Mobile MAC support for Email to Case
@ModifiedByandDate: <18th May 2020> |Karan Jugtawat((Team Jaipur) | P2OB-6002
@ModifiedByandDate: <20th Sep 2020> |Karan Jugtawat((Team Jaipur) | P2OB-6050
@ModifiedByandDate: <17th Feb 2021> |Pravin Sonawane((Team Jaipur) | P2OB-12032
@ModifiedByandDate: <31st Mar 2021> |Pravin Sonawane((Team Jaipur) | P2OB-13616
*******************************************************************************/
global without sharing class srvsup_EmailToCaseHandler implements Messaging.InboundEmailHandler{
    
    Static String recId_ServiceSupport  =  Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('srvsup_Service_Support').getRecordTypeId();
    Static String recId_SalesSupport    =  Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    Static String recId_MobileSupport   = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('mm_Mobile_Support_Request').getRecordTypeId();
    Static String recId_CPE_Requests    = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CPE_Requests').getRecordTypeId();
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String emailAddress = envelope.fromAddress;
        String subject = email.subject;
        String myPlainText = email.plainTextBody;
        List<Contact> contactList = new List<Contact>();
        List<String> contactEmails = new List<String>(); 
        List<Group> queueRecord = null;
        Case newCase = null;
        Case existingCase = null;
        try{   
            // Retrieves content from the email Body
            Matcher m = Pattern.compile('[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+').matcher(myPlainText);
            // Matcher m = Pattern.compile('[a-zA-Z0-9_.+-]@[a-zA-Z0-9-].[a-zA-Z0-9-.]+').matcher(myPlainText);
            while (m.find()) {
                string contactEmail = m.group();
                if((!contactEmail.contains(Label.salesup_Sales_Support)) || (!contactEmail.contains(Label.srvsup_Service_Support)) || (!contactEmail.contains(Label.mm_mobile_Support_email))){
                    contactEmails.add(contactEmail);
                }
            }
            //Check of refrence(ThreadId) in Email body for existing case : P2OB-6050
            String RefIdFromEmail = myPlainText.substringBetween('ref:', ':ref');
            system.debug('RefIdFromEmail=='+RefIdFromEmail);
            if(RefIdFromEmail != null && RefIdFromEmail != '') {
                try{id varCaseId = Cases.getCaseIdFromEmailThreadId(RefIdFromEmail);
                    system.debug('varCaseId=='+varCaseId);
                        
                    for(Case c : [Select Id, OwnerId,Owner.Type,Subject,CaseNumber,ContactId,Contact.Name from case where Id =: varCaseId]){existingCase = c;}
                   }
                catch(Exception e){logErrorMethod(e);}
            } 
            
            If(existingCase == null){
                
                //Search contact based on Customer Email Address
                if(!contactEmails.isEmpty()){
                    try {
                        contactList = [SELECT Id, Name, Email, AccountId FROM Contact WHERE Email IN :contactEmails];
                    }
                    catch (QueryException e) {
                        logErrorMethod(e);
                    }
                }
                
                
                //Create a new case
                newCase = new Case();
                if(emailAddress == Label.srvsup_Service_Support){
                    newCase.RecordTypeId = recId_ServiceSupport;
                    queueRecord = [select Id, name from Group where DeveloperNAME = 'srvsup_workflow_co_ordinator' AND Type = 'Queue'];
                    if(queueRecord.size()>0)
                    { newCase.OwnerId = queueRecord.get(0).Id; }
                }
                else if(emailAddress == Label.salesup_Sales_Support){
                    newCase.RecordTypeId = recId_SalesSupport;
                }
                else if(emailAddress == Label.mm_mobile_Support_email){
                    newCase.RecordTypeId = recId_MobileSupport;
                    queueRecord = [select Id, name from Group where DeveloperNAME = 'mm_customer_request_queue' AND Type = 'Queue'];
                    if(queueRecord.size() > 0)
                    { newCase.OwnerId = queueRecord.get(0).Id; }
                }
                else if(emailAddress == Label.cpe_Purple_Quote_Request_Email){
                    newCase.RecordTypeId = recId_CPE_Requests;
                    newCase.Type = 'CPE Purple';
                    newCase.salesup_Support_Type__c = Label.CPE_Hardware_And_Services;
                    newCase.srvsup_Categories__c = Label.Pricing_And_Quote_Support;
                    queueRecord = [select Id, name from Group where DeveloperNAME = 'cpe_Telstra_Purple_WF_Coordinator' AND Type = 'Queue'];
                    if(queueRecord.size() > 0)
                    { newCase.OwnerId = queueRecord.get(0).Id; }
                }
                else if(emailAddress == Label.cpe_Purple_Order_Request_Email){
                    newCase.RecordTypeId = recId_CPE_Requests;
                    newCase.Type = 'CPE Purple';
                    newCase.salesup_Support_Type__c = Label.CPE_Hardware_And_Services;
                    newCase.srvsup_Categories__c = Label.Ordering_Hardware_Services;
                    queueRecord = [select Id, name from Group where DeveloperNAME = 'cpe_Telstra_Purple_WF_Coordinator' AND Type = 'Queue'];
                    if(queueRecord.size() > 0)
                    { newCase.OwnerId = queueRecord.get(0).Id; }
                }
                else if(emailAddress == Label.cpe_Service_Desk_Email){
                    newCase.RecordTypeId = recId_CPE_Requests;
                    newCase.Type = 'CPE Core';
                    newCase.salesup_Support_Type__c = Label.CPE_Hardware_And_Services;
                    newCase.srvsup_Categories__c = Label.Ordering_Hardware_Services;
                    newCase.salesup_Work_Required__c = Label.Service_Desk_Orders;
                    queueRecord = [select Id, name from Group where DeveloperNAME = 'cpe_Ordering_Hardware' AND Type = 'Queue'];
                    if(queueRecord.size() > 0)
                    { newCase.OwnerId = queueRecord.get(0).Id; }
                }
                
                newCase.Subject = subject;
                newCase.Description = myPlainText;
                newCase.salesup_E2C_Mailbox__c = emailAddress;
                if(!contactList.isEmpty()){
                    newCase.ContactId = contactList[0].Id;
                    newCase.AccountId = contactList[0].AccountId;
                }
                //Karan Jugtawat (Team Jaipur) | P2OB-6002
                if(!contactEmails.isEmpty()){
                    newCase.salesup_From_Email_Add__c = contactEmails[0];   
                }
                
                newCase.Status = 'New';
                newCase.Origin = 'Email';
                insert newCase;
                
                system.debug('newCase=='+newCase);
                
                List<ContentVersion> fileRecList = new List<ContentVersion>();
                List<Id> fileIdList = new List<Id>();
                List<ContentDocumentLink> caseFileLinkList = new List<ContentDocumentLink>();
               
                try{
                    // Added null pointer check : Pravin
                    if(email.binaryAttachments != null){
                        for(Messaging.Inboundemail.binaryAttachment bAttachment : email.binaryAttachments){
                            //Create ContentVersion
                            ContentVersion cVersion = new ContentVersion();
                            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
                            cVersion.PathOnClient = bAttachment.fileName;//File name with extention
                            cVersion.Title = bAttachment.fileName;//Name of the file
                            cVersion.VersionData = bAttachment.body;//File content
                            fileRecList.add(cVersion);
                            
                        }
                        system.debug('fileRecList=='+fileRecList);
                        if(fileRecList.size() > 0){
                            insert fileRecList;
                        }
                     }
                }
                catch(Exception e){
                    logErrorMethod(e);
                }
                for(ContentVersion cv: fileRecList){
                    fileIdList.add(cv.Id);
                }
               
                try{
                    for(ContentVersion cv: [Select ContentDocumentId from ContentVersion where Id IN: fileIdList]){
                        //Insert ContentDocumentLink
                        ContentDocumentLink cDocLink = new ContentDocumentLink();
                        cDocLink.ContentDocumentId = cv.ContentDocumentId;//Add ContentDocumentId
                        cDocLink.LinkedEntityId = newCase.Id;//Add attachment parentId
                        cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
                        cDocLink.Visibility = 'AllUsers';//AllUsers, InternalUsers, SharedUsers
                        caseFileLinkList.add(cDocLink);
                    }
                    if(caseFileLinkList.size() > 0){
                        insert caseFileLinkList;
                    } 
                }
                catch(Exception e){
                    logErrorMethod(e);
                }
                result.success = true;
            }
            else{
                // P2OB-12032 - Alerts for email to case threading required
                // Modified by Pravin : 17th FEB 2021
                try{
                    if(existingCase != null && existingCase.Owner.Type == 'User'){
                        // Create FeedItem record to post notification to Case Owner
                        FeedItem post = new FeedItem();
                        post.ParentId = existingCase.OwnerId;
                        post.IsRichText = true;
                        string caseIdUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/'+existingCase.Id;
                        String strBody = 'A new email has been received from '+ existingCase.Contact.Name + ' and added to case <a href=\"' + caseIdUrl + '\">' + existingCase.CaseNumber + '</a> - '+ existingCase.Subject + '.  As the Case Owner please review and action as appropriate.';
                        post.Body = strBody;
                        insert post;
                        // Updating case last chatter post P2OB-13441
                        existingCase.srvsup_Last_Chatter_Post__c = strBody;
                        update existingCase;
                    }
                }
                catch(Exception e){
                    logErrorMethod(e);
                }
                result.success = true;
            }
            
            Task emailTask = new Task();
            emailTask.Subject = email.subject;
            emailTask.OwnerId = userInfo.getUserId();
            emailTask.TaskSubtype = 'Email';
            emailTask.WhatId = existingCase == null? newCase.id : existingCase.Id ;
            emailTask.Description = email.plainTextBody;
            emailTask.Status = 'Completed';
            emailTask.Priority = 'Normal';
            emailTask.RecordTypeId = Task.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('General').getRecordTypeId();
            insert emailTask;
            
            EmailMessage msg = new EmailMessage();
            msg.FromAddress = email.fromAddress;
            msg.FromName = email.fromName;
            msg.ToAddress = email.toAddresses[0];
            msg.Subject = email.subject;
            msg.TextBody = email.plainTextBody;
            msg.HtmlBody = email.htmlBody;
            msg.ParentId = existingCase == null? newCase.id : existingCase.Id ;
            msg.ActivityId = emailTask.Id;
            msg.Incoming = True;
            insert msg;
            
            System.debug('######## >' + emailTask.Id);
            System.debug('######## >' + msg.Id);
            
            
        }
        catch(Exception e){
            logErrorMethod(e);
        }
        
        return result;
        
    }
    public static void logErrorMethod(Exception e){
        ApplicationLog__c logger =new ApplicationLog__c();
        logger.Entity_Name__c = 'Email Service - ServiceSupport';
        logger.Debug_Level__c = 'Exception';
        logger.Error_Category__c = 'Technical';
        logger.Message__c = 'Email2Case - ' + e;
        insert logger;
        
    }
    
}
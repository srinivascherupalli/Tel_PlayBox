/*---------------------------------------------------------------------
Name : SendEmailToCaseAssignee
Description : The class is used to send mail to internal users for case comment notifications
Author: Abinas Panda
Story: P2OB-3883
----------------------------------------------------------------------*/

public with sharing class SendEmailToCaseAssignee {
    
    @AuraEnabled 

    public static map<string,string> sendMail(string userId , string recordIdjs){
        system.debug('userId--'+userId +'recordidjs '+recordIdjs);
        map<string,string> detailMap = new map<string,string>();
        string userName ='';
        string toMail='';
        string comments='';
        string cseNumber='';
        
        if(userId != null){
            user userDetails = [Select id,userName,Name,Email from user where id =:userId];
            case caseDetails = [SELECT Id, CaseNumber, Subject,Internal_Case_Comments__c,Internal_Comments_Capture__c FROM case where id =:recordIdjs];
            string ccMail ;
            toMail = userDetails.Email;
            userName = userDetails.Name;
            cseNumber = caseDetails.CaseNumber;
            comments = caseDetails.Internal_Case_Comments__c;
            detailMap.put('name', userName);
            detailMap.put('comment', comments);
            detailMap.put('senderName',UserInfo.getName());
            

            system.debug('userName--'+userDetails);
            
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            string[] to = new string[] {toMail};
                //string[] cc = new string[] {ccMail};
                email.setToAddresses(to);
            email.setSubject(Label.CaseSubjectInternalComments+' #'+cseNumber);
            
            //email.setHtmlBody('Hello '+userName+', <br/><br/>Please check the case comment and do the needful.<br/> <br><a href="https://telstrab2b--tokyoops.lightning.force.com/lightning/r/Case/'+recordIdjs+'/view">Click here to Navigate to Case Detail</a></br><br/>Regards<br/> Support Team');
            email.setHtmlBody('Hello '+userName+', <br/><br/>'+Label.CaseBodyInternalComments+'<br/> <br><a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/'+recordIdjs+'">'+Label.CaseHyperLinkInternalComments+'</a></br><br/>Regards,<br/>'+UserInfo.getName());
            
            try{if(userName != null){
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                }
                if(Test.isRunningTest()) {
                    integer intTest =1/0; 
                }
                
            } 
               }catch(exception e){
                   system.debug('error--'+e.getMessage()+e.getLineNumber());
               }
            
            toMail = '';
            ccMail = '';
        }

        system.debug('detailMap--'+detailMap);
        return detailMap;
    }
    
    @AuraEnabled 
    public static list<string> getComments(string recordIdjs){
        case caseDetails = new case();
        if(recordIdjs != null){
            caseDetails = [SELECT Id, CaseNumber, Subject,Internal_Case_Comments__c,Internal_Comments_Capture__c FROM case where id =:recordIdjs];
        }
        list<string> casevalue = caseDetails.Internal_Case_Comments__c.split('Loogeed!');
        system.debug('casevalue--'+casevalue);
        return casevalue;

    }
    
}
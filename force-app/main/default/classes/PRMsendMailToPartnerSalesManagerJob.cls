/********************************************************************************
* Class Name  : PRMsendMailToPartnerSalesManagerJob
* Description : This class is used for PRM Master for Partner Opportunity process builder logic
* Created By  : Gaurav Chopra 
* Change Log  : Created
********************************************************************************/
public class PRMsendMailToPartnerSalesManagerJob implements Queueable {
    public Set<String> oppIds;
    Map<Id, Opportunity> oppRecMap = new Map<Id, Opportunity>();
    
    public PRMsendMailToPartnerSalesManagerJob(Set<String> oppIds){
        this.oppRecMap = getOppRecInfo(oppIds);
        
    }
    
    public void execute(QueueableContext context) {
    
        System.Debug('PRMsendMailToPartnerSalesManagerJob execute() ==> ' + context );
    
    
        Map<Id, Id> oppAccMap = new Map<Id, Id>();
        Map<Id, Account> oppAccountMap; 
        //Opportunity Account record Map
        for(Opportunity opp : oppRecMap.values()){
            if(opp.Associated_Distributor__c != null){
                oppAccMap.put(opp.Id, Opp.AccountId); 
            }
        }
        // Account Contact record map
        Map<Id, Id> accConMap = new Map<Id, Id>();
            for(Account acc : [Select Id, Name, PartnerPrincipalContact__c FROM Account WHERE ID IN: oppAccMap.values()]){
                if(acc.PartnerPrincipalContact__c != null){
                    accConMap.put(acc.Id, acc.PartnerPrincipalContact__c);
                }
            }
            //Map of Account and Associated Users
            //
           List<User> testUser = [Select Id, Email, AccountId, ContactId, Contact.Onboarding_Status__c,
                            Contact.Partner_Role__c
                            FROM USER 
                            WHERE AccountId IN : oppAccMap.values()];
        system.debug('@@testuser:'+testUser);
            Map<Id, List<User>> accUserMap = new Map<Id, List<User>>();
            for(User usr : [Select Id, Email, AccountId, ContactId, Contact.Onboarding_Status__c,
                            Contact.Partner_Role__c
                            FROM USER 
                            WHERE AccountId IN : oppAccMap.values()
                            AND IsActive = true
                            AND IsPrmSuperUser = true ]){
                                if(accUserMap.containsKey(usr.AccountId)){
                                    accUserMap.get(usr.AccountId).add(usr); 
                                } else{
                                    accUserMap.put(usr.AccountId, new List<user>{usr});
                                }
                            }
            //Iterate on the Opportunity records and create a member list to send mail for each Opportunity 
            Map<Id, List<String>> oppMailMap = new Map<Id, List<String>>();
            for(Id oppId : oppAccMap.keySet()){
                if(accUserMap.containsKey(oppAccMap.get(oppId))){
                    for(User usr : accUserMap.get(oppAccMap.get(oppId))){
                        if(usr?.Contact?.Onboarding_Status__c == 'Active' && usr?.Contact?.Partner_Role__c == 'Partner Sales Manager'
                           && usr?.ContactId != accConMap.get(oppAccMap.get(oppId))){
                               if(oppMailMap.containsKey(oppId)){
                                   oppMailMap.get(oppId).add(usr.Email); 
                               }else{
                                   oppMailMap.put(oppId, new List<String>{usr.Email});
                               }  
                           }
                    } 
                }
            }
            
            
            if(!oppMailMap.isEmpty()){
                Map<String, EmailTemplate> mapTemplateNameVsDetails = PRMUtilityClass.getEmailTemplateDetails();
                Map<String, String> mapOwdNameVsId = PRMUtilityClass.getOwdId(); 
                List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();
                for(Id oppId : oppMailMap.keyset()){
                    Opportunity oppRecToLink = oppRecMap.get(oppId);
                    String gesHtmlValue = getGesHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.GES_TEMPLATE)?.HtmlValue, oppRecToLink);
                    String gesHtmlSubject = getGesHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.GES_TEMPLATE)?.Subject, oppRecToLink);
                    PRMUtilityClass.EmailParameter param = new PRMUtilityClass.EmailParameter();
                    param.owdId = mapOwdNameVsId.get(PRMUtilityClass.OWD_DO_NOT_REPLY);
                    //param.whatId = oppRecToLink?.PartnerAccount?.PartnerPrincipalContact__c;
                    param.templateId = mapTemplateNameVsDetails?.get(PRMUtilityClass.GES_TEMPLATE)?.Id;
                    param.targetObjectId = oppRecToLink?.PartnerAccount?.PartnerPrincipalContact__c;
                    if(oppMailMap.containskey(oppId)){
                        param.toAddressList = oppMailMap.get(oppId); 
                    }
                    param.htmlSubject = gesHtmlSubject;
                    param.htmlBody = gesHtmlValue;
                    //PRM Email
                    listOfEmail.add(PRMUtilityClass.assignEmail(param));
                }
                
                //Send Email here
                try{
                    if(!listOfEmail.isEmpty()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(listOfEmail);
                    }
                    
                }catch(Exception ex){
                    PRMUtilityClass.createException(ex);
                }
                
            }
            
        
    }

    /***************************************************************************************
    * Author - Gaurav 
    * Method Name - getGesHtmlValue
    * Description - This method is used to update Email template merge fields.
    ****************************************************************************************/
    
    private static String getGesHtmlValue(String body, Opportunity opp){
        String htmlBody = body;
        htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Account}', opp?.Account?.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Product_Domain__c}', 
                                    opp?.Product_Domain__c != null ? opp.Product_Domain__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Contract_Term__c}', 
                                    String.valueOf(opp?.Contract_Term__c) != null ? String.valueOf(opp.Contract_Term__c) : '');
        htmlBody = htmlBody.replace('{!Opportunity.Description__c}', 
                                    opp?.Description__c != null ? opp.Description__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Id}', opp.Id);
        htmlBody = htmlBody.replace('{!Opportunity.CloseDate}', String.valueOf(opp?.CloseDate));
        htmlBody = htmlBody.replace('{!$Label.PRM_ENV_URL}', Label.PRM_ENV_URL);
        return htmlBody;
    }
    
    //Query fields on the Opportunity records required for processing
    public static Map<Id, Opportunity> getOppRecInfo(Set<String> oppIds){
        system.debug('@@input Opp:'+oppIds);
        List<Opportunity> oppRecList = [Select Id, Name, Account.Name, Domain__c,
                                        Contract_Term__c, Product_Domain__c,Description__c, Opportunity_Number__c,
                                        CloseDate, DCHOwnerEmail__c, DCHOwner__r.Name,
                                        Associated_Distributor__c,PartnerAccount.PartnerPrincipalContact__c
                                        FROM Opportunity WHERE ID IN:oppIds];   
        Map<Id, Opportunity> oppRecMap = new Map<Id, Opportunity>(oppRecList);
        return oppRecMap;
    }
    
    
    
}
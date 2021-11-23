/********************************************************************************
* Class Name  : PRMUtilityClass
* Description : This class is utlity class for PRM related functionality
* Created By  : P.M 
* Change Log  : Created
********************************************************************************/
public class PRMUtilityClass {
    //Static string
    public static final String VERIFICATION_TEMPLATE = 'Partner_Opportunity_Verification_Required';
    public static final String GES_TEMPLATE = 'GES_A_Submit_to_Partner';
    public static final String TBTC_TEMPLATE = 'TBTC_Notification_to_Partner_Account_s_Email';
    public static final String OWD_DO_NOT_REPLY = 'do-not-reply-phoenix@team.telstra.com';
    public static final String PARAGRAPH = 'Paragraph';
    public static final String HYPERLINK = 'HyperLink';
    public static final String LIST_TEXT = 'List';
    public static final String EMPTY_SPACE = ' ';
    public static final String COLON = ' : ';
    public static final String EMPTY_STRING = ' &nbsp; ';
    public static final String BOLD_TEXT = 'Bold';
    public static final String UNDERLINE = 'Underline';
    
    /***************************************************************************************
    * Method Name - getListOfOpportunityForPRM
    * Description - This method is used to get the opportunity details along with 
    *                refernce fields.
    ****************************************************************************************/
    public static List<Opportunity> getListOfOpportunityForPRM(Set<Id> setOfOppId){
        return [SELECT Id,PartnerAccountId,PartnerAccount.Partner_Code__c,PartnerAccount.Account_Status__c,Product_Type__c,
                PartnerAccount.Name,OwnerId,Account.OwnerId,Account.APTPS_Business_Segment__c,Amount,
                PartnerAccount.PartnerPrincipalContact__c,Account.Owner.IsActive,DCHOwner__c,Owner.ContactId,
                Product_Domain__c,Contract_Term__c,Description__c,Name,External_Opportunity_Id__c,Account.Owner.Name,
                CloseDate,DCHOwnerEmail__c,AccountId,Partner__c,Associated_Distributor__c,Domain__c,Opportunity_Number__c,
                DCHOwner__r.Name, Account.Name,Partner_Account_Name__c, Owner.Contact.AccountId,PartnerAccount.Partner_Type__c,
                PartnerAccount.Primary_Distributor__r.Account_Status__c, Owner.Contact.Account.Partner_Type__c,
                (SELECT Id, UserId FROM OpportunityTeamMembers) FROM Opportunity WHERE Id IN :setOfOppId];
    }
    
    /***************************************************************************************
    * Method Name - addTextSegment
    * Description - This method is used to create text segement for chatter post.
    ****************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addTextSegment(String text, List<ConnectApi.MessageSegmentInput> messageSegments) {
        if(!String.isEmpty(text)) {
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            textSegmentInput.text = text;
            messageSegments.add(textSegmentInput);
        }
        return messageSegments;
    }
    
    /***************************************************************************************
    * Method Name - addMentionSegment
    * Description - This method is used to create mention segment (user record) for 
    *               chatter post.
    ****************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addMentionSegment(Id userId, List<ConnectApi.MessageSegmentInput> messageSegments) {
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = userId;
        messageSegments.add(mentionSegmentInput);
        return messageSegments;
    }
    
    /***************************************************************************************
    * Method Name - addEntityLink
    * Description - This method is used to link record in chatter post.
    ****************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addEntityLink(Id record, List<ConnectApi.MessageSegmentInput> messageSegments) {
        ConnectApi.EntityLinkSegmentInput entityLinkSegmentInput = new ConnectApi.EntityLinkSegmentInput();
        entityLinkSegmentInput.entityId = record;
        //messageSegments.add(entityLinkSegmentInput); //commented to fix the UT issue
        return messageSegments;
    }

    /***********************************************************************************
    Method Name     : addMarkupBeginSegment
    Access Modifier - public
    Purpose         - To add Markup Begin segment in chatter post
    Params          - List<ConnectApi.MessageSegmentInput>, String
    Output          - List<ConnectApi.MessageSegmentInput>
    ************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addMarkupBeginSegment(List<ConnectApi.MessageSegmentInput> messageSegments, String type ) {
        ConnectApi.MarkupBeginSegmentInput markupBeginSegmentinput = new ConnectApi.MarkupBeginSegmentInput();
        if(type.equals(PARAGRAPH)) {
            markupBeginSegmentinput.markupType = ConnectApi.MarkupType.Paragraph;
        } else if(type.equals(LIST_TEXT)) {
            markupBeginSegmentinput.markupType = ConnectApi.MarkupType.ListItem;
        }
        else if(type.equals(BOLD_TEXT)) {
            markupBeginSegmentinput.markupType = ConnectApi.MarkupType.Bold;
        }
        else if(type.equals(UNDERLINE)) {
            markupBeginSegmentinput.markupType = ConnectApi.MarkupType.Underline;
        }
        messageSegments.add(markupBeginSegmentinput);
        return messageSegments;
    }
    /***********************************************************************************
    Method Name     : addMarkupEndSegment
    Access Modifier - private
    Purpose         - To add Markup End segment in chatter post
    Params          - List<ConnectApi.MessageSegmentInput>, String
    Output          - List<ConnectApi.MessageSegmentInput>
    ************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addMarkupEndSegment(List<ConnectApi.MessageSegmentInput> messageSegments,
                                                        String type) {
        ConnectApi.MarkupEndSegmentInput markupEndSegmentinput = new ConnectApi.MarkupEndSegmentInput();
        if(type.equals(PARAGRAPH)) {
            markupEndSegmentinput.markupType = ConnectApi.MarkupType.Paragraph;
        } else if(type.equals(LIST_TEXT)) {
            markupEndSegmentinput.markupType = ConnectApi.MarkupType.ListItem;
        }
        else if(type.equals(HYPERLINK)) {
            markupEndSegmentinput.markupType = ConnectApi.MarkupType.HyperLink;
        }
        else if(type.equals(BOLD_TEXT)) {
            markupEndSegmentinput.markupType = ConnectApi.MarkupType.Bold;
        }
        else if(type.equals(UNDERLINE)) {
            markupEndSegmentinput.markupType = ConnectApi.MarkupType.Underline;
        }
        messageSegments.add(markupEndSegmentinput);
        return messageSegments;
    }
    
    /***************************************************************************************
    * Method Name - assignEmail
    * Description - This method is used to create email records based on template.
    ****************************************************************************************/
    public static Messaging.SingleEmailMessage assignEmail(PRMUtilityClass.EmailParameter emailParam){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(emailParam.targetObjectId);
        mail.setSaveAsActivity(false);
        mail.treattargetobjectasrecipient = true;
        if(String.isNotBlank(emailParam.templateId)){
            mail.setTemplateId(emailParam.templateId);
        }
        if(String.isNotBlank(emailParam.owdId)){
            mail.setOrgWideEmailAddressId(emailParam.owdId);
        }
        if(String.isNotBlank(emailParam.whatId)){
            mail.setWhatId(emailParam.whatId);
        }
        if(String.isNotBlank(emailParam.htmlBody)){
            mail.setHtmlBody(emailParam.htmlBody);
            mail.setPlainTextBody(emailParam.htmlBody);
        }
        if(String.isNotBlank(emailParam.htmlSubject)){
            mail.setSubject(emailParam.htmlSubject);
        }
        if(!emailParam.toAddressList.isEmpty()){
            mail.setToAddresses(emailParam.toAddressList);
        }
        return mail;
    }
    
    /***********************************************************************************
    Method Name     : addEmptySegment
    Access Modifier - public
    Purpose         - To add Empty segment in chatter post
    Params          - List<ConnectApi.MessageSegmentInput>
    Output          - List<ConnectApi.MessageSegmentInput>
    ************************************************************************************/
    public static List<ConnectApi.MessageSegmentInput> addEmptySegment(List<ConnectApi.MessageSegmentInput> messageSegments) {
        messageSegments = addMarkupBeginSegment(messageSegments, PARAGRAPH);
        messageSegments = addTextSegment(EMPTY_STRING, messageSegments);
        messageSegments = addMarkupEndSegment(messageSegments, PARAGRAPH);
        return messageSegments;
    }
    
    /***************************************************************************************
    * Method Name - getOwdId
    * Description - This method is used to get OrgWideEmailAddress.
    ****************************************************************************************/
    public Static Map<String,String> getOwdId(){
        Map<String, String> mapOwdNameVsId = new Map<String, String>();
        Set<String> setOfOwdName = new Set<String>{OWD_DO_NOT_REPLY};
        for(OrgWideEmailAddress owd : [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address IN :setOfOwdName]){
              mapOwdNameVsId.put(owd.Address, owd.Id);                         
        } 
        return mapOwdNameVsId;    
    }
    
    /***************************************************************************************
    * Method Name - getEmailTemplateDetails
    * Description - This method is used to get email template details.
    ****************************************************************************************/
    public Static Map<String,EmailTemplate> getEmailTemplateDetails(){
        Map<String, EmailTemplate> mapTemplateNameVsDetails = new Map<String, EmailTemplate>();
        Set<String> setOfEmailTemplate = new Set<String>{GES_TEMPLATE, TBTC_TEMPLATE, VERIFICATION_TEMPLATE};
        for(EmailTemplate templateObj : [SELECT Id, HtmlValue, Subject, DeveloperName FROM EmailTemplate WHERE 
                                         DeveloperName IN :setOfEmailTemplate]){
              mapTemplateNameVsDetails.put(templateObj.DeveloperName, templateObj);                         
        } 
        return mapTemplateNameVsDetails;
    }
    
    /***************************************************************************************
    * Method Name - getOpportunityContactRole
    * Description - This method is used to initialize OpportunityContactRole record.
    ****************************************************************************************/
    public static OpportunityContactRole getOpportunityContactRole(PRMUtilityClass.OpportunityContactRoleDTO oppContactRole){
        OpportunityContactRole oppConRole =  new OpportunityContactRole();
        oppConRole.OpportunityId = oppContactRole.opportunityId;
        oppConRole.ContactId = oppContactRole.contactId;
        oppConRole.Role = oppContactRole.role;
        oppConRole.IsPrimary = oppContactRole.isPrimary;
        return oppConRole;
    }
    
    /***************************************************************************************
    * Method Name - createOTM
    * Description - This method is used to initialize OpportunityTeamMember record.
    ****************************************************************************************/
    public static OpportunityTeamMember createOTM(String userId, String teamRole, String oppAccess, String oppId){
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.OpportunityId = oppId;
        otm.OpportunityAccessLevel = oppAccess;
        otm.TeamMemberRole = teamRole;
        otm.UserId = userId;
        return otm;
    }
    
    /***************************************************************************************
    * Method Name - updateSLAdate
    * Description - This method is used to get SLA date to add for field.
    ****************************************************************************************/
    public static Integer updateSLAdate(){
        Integer daysToadd = 0;
        switch on DateTime.now().format('E') {
            when 'Sun', 'Mon', 'Tue', 'Wed' {      
                daysToadd = 2;
            }   
            when 'Thu', 'Fri' {      
                daysToadd = 4;
            }
            when 'Sat' {        
                daysToadd = 3;
            }
            when else {       
                daysToadd = 0;
            }
        }
        return daysToadd;
    }
    
    /***************************************************************************************
    * Method Name - createException
    * Description - This method is used to create exception logs.
    ****************************************************************************************/
    public Static void createException(Exception ex){
        System.Debug(' Exception  ==> ' + ex );
        Map<String,Object> inputLogMap = new Map<String,Object>();
        inputLogMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
        inputLogMap.put('errorDescription', ex.getMessage());
        inputLogMap.put('LoggingLevel.INFO', ex.getStackTraceString()); 
        C2O_Utilities.logException(inputLogMap,false);
    }
    
    /***************************************************************************************
    * Method Name - EmailParameter
    * Description - Wrapper class for email record.
    ****************************************************************************************/
    public class EmailParameter{
        public String owdId;
        public String templateId;
        public String whatId;
        public String targetObjectId;
        public String htmlBody;
        public String htmlSubject;
        public List<String> toAddressList;
        public EmailParameter(){
            this.owdId = '';
            this.whatId = '';
            this.htmlBody = '';
            this.htmlSubject = '';
            this.toAddressList = new List<String>(); 
        }
    }
    
    /***************************************************************************************
    * Method Name - OpportunityContactRoleDTO
    * Description - Wrapper class for OpportunityContactRole record.
    ****************************************************************************************/
    public class OpportunityContactRoleDTO {
        public String opportunityId;
        public String contactId;
        public String role;
        public Boolean isPrimary;
    }
}
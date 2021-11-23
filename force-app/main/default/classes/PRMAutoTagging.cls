/********************************************************************************
* Class Name  : PRMAutoTagging
* Description : This class is used for PRM Auto Tagging process builder logic
* Created By  : P.M
* Change Log  : Created
********************************************************************************/
public class PRMAutoTagging {


    @testVisible
    private static Boolean doChainJob = true;
    /***************************************************************************************
    * Method Name - prmAutoTaggingPartner
    * Description - This method is used to update opportunity record, send an email and
    *               chatter post for Partner account.
    ****************************************************************************************/
    public static void prmAutoTaggingPartner(Set<Id> setOfOppId){
        List<Opportunity> listOfOpportunity = PRMUtilityClass.getListOfOpportunityForPRM(setOfOppId);
        Map<Id,Opportunity> mapOppIdVsDetails = new Map<Id,Opportunity>();
        Set<Id> setOfPartnerConId = new Set<Id>();
        PRM_Opportunity_Partner_Auto_Tagging__c prmAutoTagging = PRM_Opportunity_Partner_Auto_Tagging__c.getInstance();

        for(Opportunity opp : listOfOpportunity){
            if(String.isNotBlank(opp.PartnerAccountId) && String.isNotBlank(opp?.PartnerAccount?.Account_Status__c) &&
               opp?.PartnerAccount?.Account_Status__c == opptyConstants.ACCOUNT_ACTIVE){
                   setOfPartnerConId.add(opp?.PartnerAccount?.PartnerPrincipalContact__c);
               }
            if(prmAutoTagging?.isActive__c && String.isNotBlank(opp.PartnerAccountId) &&
               String.isNotBlank(opp?.PartnerAccount?.Partner_Code__c) && String.isNotBlank(opp?.PartnerAccount?.Account_Status__c) &&
               String.isNotBlank(opp?.Product_Type__c) && opp?.PartnerAccount?.Account_Status__c == opptyConstants.ACCOUNT_ACTIVE &&
               opp.Product_Type__c == opptyConstants.ACCOUNT_NON_MODULAR){
                   mapOppIdVsDetails.put(opp.Id, opp);
               }
            if(prmAutoTagging?.isActive__c && String.isNotBlank(opp.PartnerAccountId) &&
               opp?.PartnerAccount?.Account_Status__c != opptyConstants.ACCOUNT_ACTIVE &&
               opp?.PartnerAccount?.Partner_Type__c == opptyConstants.NOMINATE &&
               opp?.PartnerAccount?.Primary_Distributor__r.Account_Status__c != opptyConstants.ACCOUNT_ACTIVE &&
               (opp?.Owner?.Contact?.Account.Partner_Type__c != opptyConstants.DISTRIBUTOR ||
                String.isBlank(opp?.Owner?.ContactId))){
                   setOfPartnerConId.add(opp?.PartnerAccount?.PartnerPrincipalContact__c);
               }
        }

        if(!mapOppIdVsDetails.isEmpty()){
            System.enqueueJob(new PRMAutoTaggingOliUpdate(mapOppIdVsDetails));
        }
        if(!setOfPartnerConId.isEmpty()){
            System.enqueueJob(new SubmitToPartner(listOfOpportunity, setOfPartnerConId));
        }
    }

    /***************************************************************************************
    * Method Name - PRMAutoTaggingOliUpdate
    * Description - This method is used to create opportunity line item creation for partner
    *               account.
    ****************************************************************************************/
    public class PRMAutoTaggingOliUpdate implements Queueable {
        public List<OpportunityLineItem> listOfOli;
        public Map<Id,Opportunity> mapOppIdVsDetails;

        public PRMAutoTaggingOliUpdate(Map<Id,Opportunity> mapOppIdVsDetails){
            this.mapOppIdVsDetails = mapOppIdVsDetails;
            this.listOfOli = [SELECT Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN :mapOppIdVsDetails.keyset()];
        }

        public void execute(QueueableContext context) {
            if(!this.listOfOli.isEmpty()){
                List<OpportunityLineItem> listOfOliToUpdate = new List<OpportunityLineItem>();
                for(OpportunityLineItem oli : this.listOfOli){
                    Opportunity opp = this.mapOppIdVsDetails?.get(oli?.OpportunityId);
                    oli.Channel__c = opptyConstants.CHANNEL_INDIRECT;
                    oli.Dealer_Code__c = opp?.PartnerAccount?.Partner_Code__c;
                    oli.Partner_Info__c = opp?.PartnerAccount?.Name;
                    oli.Tagged_Partner__c = opp?.PartnerAccountId;
                    listOfOliToUpdate.add(oli);
                }
                try{
                    update listOfOliToUpdate;
                } catch(Exception ex){
                    PRMUtilityClass.createException(ex);
                }
            }
        }
    }

    /***************************************************************************************
    * Method Name - SubmitToPartner
    * Description - This method is used to update the opportunity and submit the approval
    *               process for partner account.
    ****************************************************************************************/
    public class SubmitToPartner implements Queueable {
        public Map<Id,User> mapContactIdVsUserDetails;
        public List<Opportunity> listOfOpp;
        public List<Opportunity> ownerUpdates;

        public SubmitToPartner(List<Opportunity> listOfOpp, Set<Id> setOfContactId){
            this.mapContactIdVsUserDetails =  new Map<Id,User>();
            this.listOfOpp = listOfOpp;
            for(User usr : [SELECT Id, ContactId, Email FROM User WHERE ContactId IN :setOfContactId]){
                this.mapContactIdVsUserDetails.put(usr.ContactId, usr);
            }
        }

        public void execute(QueueableContext context) {
            List<Opportunity> listOfOppToUpdate = new List<Opportunity>();
            ownerUpdates = New List<Opportunity> ();
            Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            Date slaDate = (Date.today()).addDays(PRMUtilityClass.updateSLAdate());
            for(Opportunity opp : this.listOfOpp){
                opp.DCHOwner__c = opp.OwnerId;
                
                if(this.mapContactIdVsUserDetails.containsKey(opp?.PartnerAccount?.PartnerPrincipalContact__c)){
                    User usr = this.mapContactIdVsUserDetails.get(opp?.PartnerAccount?.PartnerPrincipalContact__c);
                    opp.Partner_Account_Email__c = usr.Email;
                    opp.Partner__c = usr.Id;
                }
                
                if(opp?.Account?.APTPS_Business_Segment__c != opptyConstants.BUSINESS_PLUS){
                    opp.SLA_date__c = slaDate;
                     
                    if(opp.Partner__c != null){
                        Approval.ProcessSubmitRequest approval = new Approval.ProcessSubmitRequest();
                        approval.setSubmitterId(opp.OwnerId);
                        approval.setProcessDefinitionNameOrId(opptyConstants.APPROVAL_PROCESS_NAME);
                        approval.setObjectId(opp.id);
                        approval.setSkipEntryCriteria(true);
                        requestList.add(approval);
                    } 
                }
                
                if(this.mapContactIdVsUserDetails.containsKey(opp?.PartnerAccount?.PartnerPrincipalContact__c)){
                    User usr = this.mapContactIdVsUserDetails.get(opp?.PartnerAccount?.PartnerPrincipalContact__c);
                    ownerUpdates.add(New Opportunity(Id = opp.Id,OwnerId = usr.Id ));
                }
                opp.Partner_Account__c = opp.PartnerAccountId;
                opp.SubmittoPartnerStatus__c = (opp?.Account?.APTPS_Business_Segment__c == opptyConstants.BUSINESS_PLUS)
                                                ? opptyConstants.APPROVED : opptyConstants.SUBMITTED;
                listOfOppToUpdate.add(opp);
            }

            try{
                
                
                if(!listOfOppToUpdate.isEmpty()){
                    update listOfOppToUpdate;
                }
                if(!requestList.isEmpty()){
                    Approval.ProcessResult[] result = Approval.process(requestList);
                }
                if(!ownerUpdates.isEmpty()){
                    update ownerUpdates;
                }
                if(doChainJob) {
                    System.enqueueJob(new AddOTMForPartnerOwnedOpp(listOfOppToUpdate));
                }
            } catch(Exception ex){
                PRMUtilityClass.createException(ex);
            }
        }
    }

    /***************************************************************************************
    * Method Name - AddOTMForPartnerOwnedOpp
    * Description - This method is used to insert opportunity team member based on the account
    *               team memeber records.
    ****************************************************************************************/
    public class AddOTMForPartnerOwnedOpp implements Queueable {
        public List<Opportunity> listOfOpp;

        public AddOTMForPartnerOwnedOpp(List<Opportunity> listOfOpp){
           this.listOfOpp = listOfOpp;
        }

        public void execute(QueueableContext context) {
            List<OpportunityTeamMember> listOfOtm = new List<OpportunityTeamMember>();
            Set<Id> setOfOppId = new Set<Id>();
            Map<String,List<AccountTeamMember>> mapAccIdVsTeamMembers = new Map<String,List<AccountTeamMember>>();

            for(Opportunity opp : this.listOfOpp){
                mapAccIdVsTeamMembers.put(opp.AccountId, new List<AccountTeamMember>());
                setOfOppId.add(opp.Id);
            }

            for(AccountTeamMember atm : [SELECT Id, UserId, TeamMemberRole, AccountId, OpportunityAccessLevel
                                         FROM AccountTeamMember WHERE AccountId IN :mapAccIdVsTeamMembers.keySet()]){
                if(mapAccIdVsTeamMembers.containsKey(atm.AccountId)){
                    mapAccIdVsTeamMembers.get(atm.AccountId).add(atm);
                }
            }

            for(Opportunity opp : this.listOfOpp){
                if(!mapAccIdVsTeamMembers.get(opp.AccountId).isEmpty()){
                    for(AccountTeamMember atm : mapAccIdVsTeamMembers.get(opp.AccountId)){
                        listOfOtm.add(PRMUtilityClass.createOTM(atm.UserId, atm.TeamMemberRole, atm.OpportunityAccessLevel, opp.Id));
                    }
                }
                if(opp.Account.Owner.IsActive){
                    listOfOtm.add(PRMUtilityClass.createOTM(opp?.Account?.OwnerId, opptyConstants.ACC_MANAGER, 'Edit', opp.Id));
                }
                if(String.isNotBlank(opp.DCHOwner__c)){
                    listOfOtm.add(PRMUtilityClass.createOTM(opp.DCHOwner__c, opptyConstants.SALES_REP, 'Edit', opp.Id));
                }
            }
            try{
                if(!listOfOtm.isEmpty()){
                    insert listOfOtm;
                }
                if(doChainJob) {
                    System.enqueueJob(new AddPermissionSetToAccountOwner(setOfOppId));
                }
            } catch(Exception ex){
                PRMUtilityClass.createException(ex);
            }

        }
    }

    /***************************************************************************************
    * Method Name - AddPermissionSetToAccountOwner
    * Description - This method is used to insert permission set, sent an email and chatter
    *               post for partner account.
    ****************************************************************************************/
    public class AddPermissionSetToAccountOwner implements Queueable {
        public List<Opportunity> listOfOpp;
        public Boolean isAssocitaed;

        public AddPermissionSetToAccountOwner(Set<Id> setOfOppId){
           this.listOfOpp = PRMUtilityClass.getListOfOpportunityForPRM(setOfOppId);
           this.isAssocitaed = false;
        }

        public void execute(QueueableContext context) {
            List<PermissionSetAssignment> listOfPsaToInsert = new List<PermissionSetAssignment>();
            List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();
            Map<String, EmailTemplate> mapTemplateNameVsDetails = PRMUtilityClass.getEmailTemplateDetails();
            Map<String, String> mapOwdNameVsId = PRMUtilityClass.getOwdId();
            Set<Id> setOfUserId = new Set<Id>();
            Set<Id> setOfUserWithPM = new Set<Id>();
            Set<Id> setOfGroupMember = new Set<Id>();
            Set<Id> setOfPartnerAccId = new Set<Id>();

            for(Opportunity opp : this.listOfOpp){
                setOfPartnerAccId.add(opp.PartnerAccountId);
                setOfUserId.addAll(new Set<Id>{opp?.Account?.OwnerId, opp?.DCHOwner__c});
                for(OpportunityTeamMember otm : opp.OpportunityTeamMembers){
                    setOfUserId.add(otm.UserId);
                }
            }

            List<User> listOfUser = [SELECT Id,ContactId,Email,AccountId,ProfileId,IsPrmSuperUser,Contact.Onboarding_Status__c,
                                     Contact.Partner_Role__c FROM User WHERE AccountId IN :setOfPartnerAccId AND IsActive = true];
            Map<Id,List<User>> mapAccountIdVsListOfUser = new Map<Id,List<User>>();
            if(!listOfUser.isEmpty()){
                for(User usr : listOfUser){
                    if(mapAccountIdVsListOfUser.containsKey(usr.AccountId)){
                        mapAccountIdVsListOfUser.get(usr.AccountId).add(usr);
                    } else {
                        mapAccountIdVsListOfUser.put(usr.AccountId,new List<User>{usr});
                    }
                }
            }
            for(GroupMember gm : [SELECT UserOrGroupId FROM GroupMember WHERE UserOrGroupId IN :setOfUserId AND
                                  GroupId = :opptyConstants.QUEUE_USER_WITHOUT_CHATTER_PERM]){
                setOfGroupMember.add(gm.UserOrGroupId);
            }

            for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE AssigneeId IN :setOfUserId
                                               AND PermissionSetId = :opptyConstants.PERMISSSION_SET_PCS]){
                setOfUserWithPM.add(psa.AssigneeId);
            }
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for(Opportunity opp : this.listOfOpp){
                String gesHtmlValue = getGesHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.GES_TEMPLATE)?.HtmlValue, opp);
                String gesHtmlSubject = getGesHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.GES_TEMPLATE)?.Subject, opp);
                String tbtcHtmlValue = getTbtcHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.TBTC_TEMPLATE)?.HtmlValue, opp);
                String tbtcHtmlSubject = getTbtcHtmlValue(mapTemplateNameVsDetails.get(PRMUtilityClass.TBTC_TEMPLATE)?.Subject, opp);

                if(opp?.Account?.OwnerId != null && !setOfGroupMember.contains(opp?.Account?.OwnerId) &&
                   !setOfUserWithPM.contains(opp?.Account?.OwnerId) ){
                    listOfPsaToInsert.add(new PermissionSetAssignment(AssigneeId = opp.Account.OwnerId, PermissionSetId = opptyConstants.PERMISSSION_SET_PCS));
                }
                if(opp.Account.OwnerId != opp.DCHOwner__c){
                    if(opp?.DCHOwner__c != null && !setOfGroupMember.contains(opp?.DCHOwner__c) && !setOfUserWithPM.contains(opp?.DCHOwner__c)){
                        listOfPsaToInsert.add(new PermissionSetAssignment(AssigneeId = opp.DCHOwner__c, PermissionSetId = opptyConstants.PERMISSSION_SET_PCS));
                    }
                }
                for(OpportunityTeamMember otm : opp.OpportunityTeamMembers){
                    if(otm.UserId != opp?.Account?.OwnerId && otm.UserId != opp.DCHOwner__c){
                        if(!setOfGroupMember.contains(otm.UserId) && !setOfUserWithPM.contains(otm.UserId)){
                            listOfPsaToInsert.add(new PermissionSetAssignment(AssigneeId = otm.UserId, PermissionSetId = opptyConstants.PERMISSSION_SET_PCS));
                        }
                    }
                }

                if(mapAccountIdVsListOfUser.containsKey(opp.PartnerAccountId)){
                    Set<Id> setOfMentionIds = new Set<Id>();
                    List<User> listOfUserForEmail = mapAccountIdVsListOfUser.get(opp.PartnerAccountId);
                    for(User usr : listOfUserForEmail){
                        if(usr.ContactId != opp?.PartnerAccount?.PartnerPrincipalContact__c && usr.IsPrmSuperUser &&
                           usr?.Contact?.Onboarding_Status__c == opptyConstants.ONBOARDING_ACTIVE &&
                           (usr?.Contact?.Partner_Role__c).contains(opptyConstants.PARTNER_SM)){
                               PRMUtilityClass.EmailParameter param = new PRMUtilityClass.EmailParameter();
                               param.owdId = mapOwdNameVsId.get(PRMUtilityClass.OWD_DO_NOT_REPLY);
                               param.whatId = opp?.PartnerAccount?.PartnerPrincipalContact__c;
                               param.templateId = mapTemplateNameVsDetails?.get(PRMUtilityClass.GES_TEMPLATE)?.Id;
                               param.targetObjectId = usr.Id;
                               param.htmlSubject = gesHtmlSubject;
                               param.htmlBody = gesHtmlValue;
                               listOfEmail.add(PRMUtilityClass.assignEmail(param));
                        }
                        if(usr.ProfileId == OpptyConstants.TBTC_Partner_Admin ||
                           (usr.ProfileId == OpptyConstants.TBTC_Partner_User && usr.IsPrmSuperUser)){
                               setOfMentionIds.add(usr.Id);
                               PRMUtilityClass.EmailParameter param = new PRMUtilityClass.EmailParameter();
                               param.owdId = mapOwdNameVsId.get(PRMUtilityClass.OWD_DO_NOT_REPLY);
                               param.whatId = opp?.PartnerAccount?.PartnerPrincipalContact__c;
                               param.templateId = mapTemplateNameVsDetails?.get(PRMUtilityClass.TBTC_TEMPLATE)?.Id;
                               param.targetObjectId = usr.Id;
                               param.htmlSubject = tbtcHtmlSubject;
                               param.htmlBody = tbtcHtmlValue;
                               listOfEmail.add(PRMUtilityClass.assignEmail(param));
                        }
                    }
                    if(!setOfMentionIds.isEmpty()){
                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(createChatterPost(opp, setOfMentionIds));
                        batchInputs.add(batchInput);
                        if(batchInputs.size() == 500){
                            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                            batchInputs = new List<ConnectApi.BatchInput>();
                        }
                    }
                }
            }

            try{
                if(!listOfPsaToInsert.isEmpty()){
                    insert listOfPsaToInsert;
                }
                if(!listOfEmail.isEmpty()){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(listOfEmail);
                }
                if(!batchInputs.isEmpty()){
                    ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
                }

            }catch(Exception ex){
                PRMUtilityClass.createException(ex);
            }
        }
    }

    /***************************************************************************************
    * Method Name - createChatterPost
    * Description - This method is used to create chatter body.
    ****************************************************************************************/
    @testVisible
    private Static ConnectApi.FeedItemInput createChatterPost(Opportunity opp, Set<Id> setOfUserId){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = opp.Id;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        Integer count = 0;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
            count++;
            if(count ==  25){
                break;
            }
        }
        messageSegments = PRMUtilityClass.addTextSegment(', ', messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment('The Opportunity ', messageSegments);
        messageSegments = PRMUtilityClass.addEntityLink(opp.Id, messageSegments);
        messageSegments = PRMUtilityClass.addTextSegment(' has been assigned to TBTC ', messageSegments);
        if(opp?.Partner_Account_Name__c != null){
            messageSegments = PRMUtilityClass.addEntityLink(opp?.Owner?.Contact?.AccountId, messageSegments);
            messageSegments = PRMUtilityClass.addTextSegment('.', messageSegments);
        }
        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }

    /***************************************************************************************
    * Method Name - getGesHtmlValue
    * Description - This method is used override the merge fields of email template.
    ****************************************************************************************/
    private static String getGesHtmlValue(String body, Opportunity opp){
        String htmlBody = body;
        htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Account}', opp?.Account?.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Product_Domain__c}', opp?.Product_Domain__c != null ? opp.Product_Domain__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Contract_Term__c}',
                                    String.valueOf(opp?.Contract_Term__c) != null ? String.valueOf(opp.Contract_Term__c) : '');
        htmlBody = htmlBody.replace('{!Opportunity.Description__c}', opp?.Description__c != null ? opp.Description__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Id}', opp.Id);
        htmlBody = htmlBody.replace('{!Opportunity.CloseDate}', String.valueOf(opp?.CloseDate));
        htmlBody = htmlBody.replace('{!$Label.PRM_ENV_URL}', OpptyConstants.PRM_ENV_URL);
        return htmlBody;
    }

    /***************************************************************************************
    * Method Name - getTbtcHtmlValue
    * Description - This method is used override the merge fields of email template.
    ****************************************************************************************/
    private static String getTbtcHtmlValue(String body, Opportunity opp){
        String htmlBody = body;
        htmlBody = htmlBody.replace('{!Opportunity.Name}', opp.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Account}', opp?.Account?.Name);
        htmlBody = htmlBody.replace('{!Opportunity.Domain__c}', opp?.Domain__c != null ? opp.Domain__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Contract_Term__c}',
                                    String.valueOf(opp?.Contract_Term__c) != null ? String.valueOf(opp.Contract_Term__c) : '');
        htmlBody = htmlBody.replace('{!Opportunity.Description__c}', opp?.Description__c != null ? opp.Description__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.Opportunity_Number__c}', opp?.Opportunity_Number__c);
        htmlBody = htmlBody.replace('{!Opportunity.CloseDate}', String.valueOf(opp?.CloseDate));
        htmlBody = htmlBody.replace('{!Opportunity.DCHOwnerEmail__c}', opp?.DCHOwnerEmail__c != null ? opp.DCHOwnerEmail__c : '');
        htmlBody = htmlBody.replace('{!Opportunity.DCHOwner__c}', opp?.DCHOwner__r?.Name != null ? opp.DCHOwner__r.Name : '');
        htmlBody = htmlBody.replace('{!$Label.PRM_ENV_URL}', OpptyConstants.PRM_ENV_URL);
        return htmlBody;
    }
}
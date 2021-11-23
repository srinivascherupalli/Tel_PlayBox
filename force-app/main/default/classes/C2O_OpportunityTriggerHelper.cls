/********************************************************************************
* Class Name  : Opportunity Trigger Helper
* Description : Opportunity Trigger Helperruns logic on Opportunity records which are filtered
*               based on certain filter conditions which are defined in handler
* Created By  : Gaurav/Palash
* Change Log  : Created 
********************************************************************************/

Public class C2O_OpportunityTriggerHelper{

    /***************************************************************************************
    * Author - Gaurav
    * Method Name - updateRevenue
    * Description - This method is used to update revene fields on Opportunity from Rollup.
    ****************************************************************************************/
    Public static void updateRevenue(set<Id> oppIdset){

        try{
            // LOCAL VARIABLES
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            List<Id> oppIdList = new List<Id>();
            oppIdList.addAll(oppIdset);

            List<Opportunity> oppRecList = [Select Id, Name, Incremental_Revenue_Rollup__c,
                                            Renewal_Revenue_Rollup__c, ASV__c, ASV_History__c,
                                            Incremental_Revenue__c, Renewal_Revenue__c
                                            FROM Opportunity
                                            WHERE ID IN: oppIdList];

            for(Opportunity opp : oppRecList){

                if(opp.Incremental_Revenue_Rollup__c != opp.Incremental_Revenue__c){
                    opp.Incremental_Revenue__c = opp.Incremental_Revenue_Rollup__c;
                }

                if(opp.Renewal_Revenue_Rollup__c != opp.Renewal_Revenue__c){
                    opp.Renewal_Revenue__c = opp.Renewal_Revenue_Rollup__c;
                }

                if(opp.ASV__c != opp.ASV_History__c){
                    opp.ASV_History__c = opp.ASV__c;
                }

                oppToUpdateList.add(opp);
            }

            if( !oppToUpdateList.isEmpty() ){
                update oppToUpdateList;
            }

        }catch(Exception e){
            //LOG EXCEPTION
            PRMUtilityClass.createException(e);
        }
    }

    /***************************************************************************************
    * Author - Sarv
    * Method Name - nullifyNonDistributerOppty
    * Description - This method is used to empty the field values for non Distributer Opportunity records.
    ****************************************************************************************/
    Public static void nullifyNonDistributerOppty(List<Opportunity> oppty){
        try{
            for (Opportunity opp :oppty){
                opp.Associated_Distributor_Name__c = null;
                opp.Associated_Distributor__c = null;
                opp.Distributor_Contact__c = null;
                opp.OwnerId = opp.DCHOwner__c;
                opp.PartnerAccountId = null;
                opp.PartnerAccount = null;
                opp.Partner__c = null;
            }
        }catch(Exception e){
            //LOG EXCEPTION
            PRMUtilityClass.createException(e);
        }
    }

    /***************************************************************************************
    * Author - Sarv
    * Method Name - nullifyDistributerOppty
    * Description - This method is used to empty the field values for Distributer Opportunity records.
    ****************************************************************************************/
    Public static void nullifyDistributerOppty(List<Opportunity> oppty){
        try{
            for (Opportunity opp :oppty){
                opp.OwnerId = opp.DCHOwner__c;
                opp.PartnerAccountId = null;
                opp.PartnerAccount = null;
                opp.Partner__c = null;
            }
        }catch(Exception e){
            //LOG EXCEPTION
            PRMUtilityClass.createException(e);
        }
    }


    /***************************************************************************************
    * Author - Gaurav
    * Method Name - Author - Gaurav
    * Description - This method is used to remove Partner Users from Opportunity teams.
    ****************************************************************************************/
    public static void remPartUsrFrmOpptyTeam(Map<Id,Id> mapOppIdVsPartnerId){
        
        List<Opportunity> newOppList = getOppRecInfo(mapOppIdVsPartnerId.keySet());
        Map<Id, Id> oppPartnerMap = new Map<Id, Id>();
        for(Opportunity opp : newOppList){
            if(opp?.DCHOwner__r?.ContactId != null && opp?.DCHOwner__r?.Contact?.AccountId != null &&
               opp?.DCHOwner__r?.Contact?.Account?.Partner_Type__c == opptyConstants.DISTRIBUTOR){
                oppPartnerMap.put(opp.Id, mapOppIdVsPartnerId.get(opp.Id));
            }else if(opp?.DCHOwner__r?.ContactId == null){
                oppPartnerMap.put(opp.Id, mapOppIdVsPartnerId.get(opp.Id));
            }
        }
        if(!oppPartnerMap.isEmpty()){
            OpptyUtils.removeOpportunityTeamMember(oppPartnerMap);
        }

    }

    /***************************************************************************************
    * Author - Gaurav
    * Method Name - getOppRecInfo
    * Description - This method is used to get Opportunity record field values.
    ****************************************************************************************/
    public static List<Opportunity> getOppRecInfo(Set<Id> oppIdSet){
        return [Select Id, Name, SubmittoPartnerStatus__c, DCHOwner__c, DCHOwner__r.ContactId,
                DCHOwner__r.Contact.AccountId, DCHOwner__r.Contact.Account.Partner_Type__c,
                PartnerAccountId, Account.OwnerId, Account.Owner.IsActive, Partner__c
                FROM Opportunity WHERE ID IN:oppIdSet];
    }

    /***************************************************************************************
    * Author - Gaurav
    * Method Name - updateSLAdateTo2days
    * Description - This method is used to update SLA date to next 2 working days.
    ****************************************************************************************/
    public static void updateSLAdateTo2days(List<Opportunity> newOppList){
        Integer daysToadd = PRMUtilityClass.updateSLAdate();
        for(Opportunity opp : newOppList){
            opp.SLA_date__c = System.now().addDays(daysToadd);
        }
    }

    /***************************************************************************************
    * Author - P.M
    * Method Name - updateChangeType
    * Description - This method is used to update csordtelcoa__Change_Type__c fields newly
    *               created opportunity record.
    ****************************************************************************************/
    public static void updateChangeType(List<Opportunity> newOppList){
        for(Opportunity opp : newOppList){
             opp.csordtelcoa__Change_Type__c = opptyConstants.CHANGE_SOLUTION;
        }
    }
    
    /***************************************************************************************
    * Author - P.M
    * Method Name - update Bid and Resource Mgmt Required
    * Description - This method is used to update Bid and Resource Mgmt Required.
    ****************************************************************************************/
    public static void updateBidnResMgmtReq(List<Opportunity> newOppList){
        for(Opportunity opp : newOppList){
             opp.Requires_Bid_Management__c = opptyConstants.IN_CONTRACT_YES;
        }
    }
    
    /***************************************************************************************
    * Author - P.M
    * Method Name - updateRetiedAccOpp
    * Description - This method is used to update RetiedAccOpp.
    ****************************************************************************************/
    public static void UpdateRetiedAccOpp(List<Opportunity> newOppList){
        for(Opportunity opp : newOppList){
             opp.RetiedAccOpp__c     = opptyConstants.isFALSE;
        }
    }

    /***************************************************************************************
    * Author - P.M
    * Method Name - createOpportunityContactRole
    * Description - This method is used to create OpportunityContactRole for newly created
    *         opportunity record.
    ****************************************************************************************/
    public static void createOpportunityContactRole(List<Opportunity> listOfOpportunity){
        Map<String,Id> mapCompositeKeyVsContactId = new Map<String,String>();
        List<OpportunityContactRole> listOfOCR = new List<OpportunityContactRole>();
        Set<Id> setOfAccountId = new Set<Id>();
        Set<String> setOfContactEmail = new Set<String>();
        for(Opportunity opp : listOfOpportunity){
            setOfAccountId.add(opp.AccountId);
            setOfContactEmail.add(opp.Customer_Contact_Email__c);
        }

        List<Contact> listOfContact = [ SELECT Id, AccountId, Email FROM Contact WHERE
                                       RecordType.DeveloperName = :opptyConstants.PARTNER_CONTACT AND
                                       Contact_Status__c != :opptyConstants.ContactStatus_INACTIVE AND
                                       AccountId IN :setOfAccountId AND Email IN :setOfContactEmail ORDER BY CreatedDate DESC ];

        if(!listOfContact.isEmpty()){
            for(Contact con : listOfContact){
                mapCompositeKeyVsContactId.put(con.AccountId+'-'+con.Email, con.Id);
            }
            String key = '';
            for(Opportunity opp : listOfOpportunity){
                key = opp.AccountId + '-' + opp.Customer_Contact_Email__c;
                if(mapCompositeKeyVsContactId.containsKey(key)){
                    PRMUtilityClass.OpportunityContactRoleDTO oppContactRole =  new PRMUtilityClass.OpportunityContactRoleDTO();
                    oppContactRole.OpportunityId = opp.Id;
                    oppContactRole.ContactId = mapCompositeKeyVsContactId.get(key);
                    oppContactRole.Role = opptyConstants.BUYER;
                    oppContactRole.IsPrimary = true;
                    listOfOCR.add(PRMUtilityClass.getOpportunityContactRole(oppContactRole));
                }
            }

            if(!listOfOCR.isEmpty()){
                try{
                    insert listOfOCR;
                } catch(Exception ex){
                    PRMUtilityClass.createException(ex);
                }
            }
        }
    }

    /***************************************************************************************
    * Author - P.M
    * Method Name - sentPartnerVerificationEmail
    * Description - This method is used to sent an email newly created opportunity record.
    ****************************************************************************************/
    public static void sentPartnerVerificationEmail(Set<Id> setOfOppId){

        PRM_Default__c prmDefault = PRM_Default__c.getInstance();
        Set<String> setOfProfileName = new Set<String> {OpptyConstants.TBTCProfile1, OpptyConstants.TBTCProfile2, OpptyConstants.TBTCProfile3};
            if(prmDefault.Partner_Opportunity_Verification__c && setOfProfileName.contains(UserInfo.getProfileId()))  {
                System.enqueueJob(new PartnerOpportunityVerificationEmail(setOfOppId, PRMUtilityClass.VERIFICATION_TEMPLATE));
            }
    }

    /***************************************************************************************
    * Author - P.M
    * Method Name - PartnerOpportunityVerificationEmail
    * Description - This queueable class is used to send an email account owner.
    ****************************************************************************************/
    public class PartnerOpportunityVerificationEmail implements Queueable {
        public List<Opportunity> listOfOpportunity;
        public String owdId;
        public EmailTemplate templateDetails;

        public PartnerOpportunityVerificationEmail(Set<Id> setOfOppId, String templateName){
            this.listOfOpportunity = PRMUtilityClass.getListOfOpportunityForPRM(setOfOppId);
            this.templateDetails = PRMUtilityClass.getEmailTemplateDetails()?.get(templateName);
            this.owdId = '';
        } 

        public void execute(QueueableContext context) {
            List<Messaging.SingleEmailMessage> listOfEmail = new List<Messaging.SingleEmailMessage>();

            for(Opportunity opp : this.listOfOpportunity){
                if(opp?.Account?.Owner?.Isactive == true){
                    PRMUtilityClass.EmailParameter param = new PRMUtilityClass.EmailParameter();
                    if(String.isNotBlank(this.owdId)){
                        param.owdId = this.owdId;
                    }
                    param.htmlSubject = this.templateDetails?.Subject;
                    param.templateId = this.templateDetails?.Id;
                    param.whatId = opp.Id;
                    param.targetObjectId = opp?.Account?.OwnerId;
                    if(this.templateDetails.DeveloperName == PRMUtilityClass.VERIFICATION_TEMPLATE){
                        String htmlBody = this.templateDetails.HtmlValue;
                        htmlBody = htmlBody.replace('{!Opportunity.Link}', OpptyConstants.PRM_ENV_URL+'/'+opp.Id);
                        htmlBody = htmlBody.replace('{!Account.OwnerFullName}', opp?.Account?.Owner?.Name);
                        htmlBody = htmlBody.replace('{!Opportunity.Partner_Account_Name__c}',
                                                    opp?.Partner_Account_Name__c != null ? opp.Partner_Account_Name__c : '');
                        htmlBody = htmlBody.replace('{!Opportunity.Amount}',
                                                    String.valueOf(opp?.Amount) != null ? String.valueOf(opp.Amount) : '');
                        htmlBody = htmlBody.replace('{!$Label.PRM_ENV_URL}', OpptyConstants.PRM_ENV_URL);
                        param.htmlBody = htmlBody;
                    }
                    listOfEmail.add(PRMUtilityClass.assignEmail(param));
                }
            }

            if(!listOfEmail.isEmpty()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(listOfEmail);
            }
        }
    }

    /***************************************************************************************
    * Author - Gaurav
    * Method Name - submitToDistributor
    * Description - This method is used to submit the opportunities for the Approval.
    ****************************************************************************************/
    
    //Public Static void submitToDistributorASYNC(Map<String,String> opptyId_UserId){
      //  opptyId_UserId
   // }
    
    @future
    public static void submitToDistributor(Map<String,String> opptyId_UserId){
    
        //Call an Approval Process for each Opp rec
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            for(String oppId : opptyId_UserId.keyset()){
                if ( !Approval.isLocked(oppId) ) {
                Approval.ProcessSubmitRequest approval = new Approval.ProcessSubmitRequest();
                approval.setSubmitterId(opptyId_UserId.get(oppId));  
                //approval.setSubmitterId('0055P000000ooZg'); 
                approval.setProcessDefinitionNameOrId(opptyConstants.PARTNER_MULTITIER_APPROVAL_PROCESS);
                approval.setObjectId(oppId);
                requestList.add(approval);
            }
        }
            
        if(!requestList.isEmpty()){
            Approval.ProcessResult[] result = Approval.process(requestList);
        }

        System.enqueueJob(new PRMsendMailToPartnerSalesManagerJob( opptyId_UserId.keySet() ));
    }
    
    
    /***************************************************************************************
    * Author - Gaurav
    * Method Name - submitToPartner
    * Description - This method is used to submit the opportunities for the Approval.
    ****************************************************************************************/
     
    
    @future
    public static void submitToPartner(Map<String,String> opptyId_UserId){
            
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            
        for ( Opportunity a : [SELECT Id, Partner__c, SubmittoPartnerStatus__c, Distributor_Contact__c 
                                   FROM opportunity WHERE ID IN : opptyId_UserId.keySet()]){
                                       
        if ( !Approval.isLocked(a.Id) ) {                           
            Approval.ProcessSubmitRequest approval = new Approval.ProcessSubmitRequest();
            approval.setSubmitterId(a.Distributor_Contact__c);  
            approval.setProcessDefinitionNameOrId(opptyConstants.SUBMIT_TO_PARTNER_PROCESS);
            approval.setObjectId(a.Id);
            approval.setNextApproverIds(new Id[] {a.Partner__c});
            requestList.add(approval);
        }
    }
        //Call an Approval Process for each Opp rec
             
        if(!requestList.isEmpty()){
            Approval.ProcessResult[] result = Approval.process(requestList);
        }

        System.enqueueJob(new PRMsendMailToPartnerSalesManagerJob( opptyId_UserId.keySet() ));
    }


    /***************************************************************************************
    * Author - Sudheendra
    * Wrapper Class - ChatterFeedInfo
    * Description - This wrapper class is meant for holding the Chatter Feed details (Parent Record Id, mentionIds, and Chatter Message) .
    ****************************************************************************************/
    public class ChatterFeedInfo{
        public String parentRecId {get; set;}
        public set<Id> mentionIds{get; set;}
        public String chatterFeedText{get; set;}
        public ChatterFeedInfo(String parId, Set<Id> mentionIds, String feed){
            this.parentRecId = parId;
            this.mentionIds = mentionIds;
            this.chatterFeedText = feed;
        }
    }

    // Create Oppty Contact Role for update scenario in queueable mode...
    public class CreateOpptyContactRole implements Queueable{
        List<Opportunity> opptyList;

        public createOpptyContactRole(List<Opportunity> oppList){
            this.opptyList = oppList;
        }
        public void execute(QueueableContext context) {
            Map<String, String> opptyCustContactEmailMap = new Map<String, String> ();
            Map<String, String> contOptyMap = new Map<String,String>();
            Map<String, String> contRoleOpprtyContMap = new Map<String,String>();
            Map<String, String> createOCRMap = new Map<String, String>();
            List<OpportunityContactRole> updateOcrRoleList = new List<OpportunityContactRole>();
            List<OpportunityContactRole> CreateOcrRoleList = new List<OpportunityContactRole>();

            for(Opportunity o:opptyList){
                opptyCustContactEmailMap.put(o.AccountId,o.Id+'#'+o.Customer_Contact_Email__c); // (AccountId, OpptyId#CustomerContactEmail)
            }
            Map<String, Contact> opptyContactMap = new Map<String, Contact> ();
            for(Contact c: [Select Id,AccountId, email from contact where AccountId IN : opptyCustContactEmailMap.keySet() AND Contact_Status__c!='Inactive' AND RecordType.DeveloperName='Partner_Contact']){

                if(c.Email == opptyCustContactEmailMap.get(c.AccountId)?.split('#')[1]){
                    contOptyMap.put(c.Id, opptyCustContactEmailMap.get(c.AccountId).split('#')[0]); //(ContactId, OpptyId)
                }
            }
            if(!contOptyMap.isempty()){
                for(OpportunityContactRole ocr: [select id,COntactId, OpportunityId from OpportunityContactRole where ContactId IN : contOptyMap.keyset()]){
                    contRoleOpprtyContMap.put(ocr.Id, ocr.COntactId+'#'+ocr.OpportunityId);      // (OptyContactRoleId, ContactId#OpptyId)
                }
                
                for(String ocrid: contRoleOpprtyContMap.keyset()){
                    String tmpcntOppRole = contRoleOpprtyContMap.get(ocrid); // [ContactId, OpptyId]
                    
                    if(contOptyMap.get(tmpcntOppRole.split('#')[0]) == tmpcntOppRole.split('#')[1]){

                        OpportunityContactRole tmprole = new OpportunityContactRole();
                        tmprole.Id=ocrid;
                        tmprole.Role=opptyConstants.BUYER;
                        updateOcrRoleList.add(tmprole);
                    }
                }

                if(updateOcrRoleList.size()>0){
                    try{
                        update updateOcrRoleList;
                    }
                    catch(Exception ex){
                        PRMUtilityClass.createException(ex);
                    }

                }
            }

        }


    }


    // Create Bulk Chatter Feeds in Queuable mode...
    public class InvokeBulkChatterFeedQueueable implements Queueable {
        List<C2O_OpportunityTriggerHelper.ChatterFeedInfo> listOfChatterFeedInfo;

        public InvokeBulkChatterFeedQueueable(List<C2O_OpportunityTriggerHelper.ChatterFeedInfo> listOfChatterinfo){
            this.listOfChatterFeedInfo = listOfChatterinfo;
        }

        public void execute(QueueableContext context) {
            if(!this.listOfChatterFeedInfo.isEmpty()){
                List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
                for(C2O_OpportunityTriggerHelper.ChatterFeedInfo feed: listOfChatterFeedInfo){
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(createChatterPost(feed.parentRecId, feed.mentionIds,  feed.chatterFeedText));
                    batchInputs.add(batchInput);
                    if(batchInputs.size() <= 500){
                        try{
                            ConnectApi.ChatterFeeds.postFeedElementBatch(opptyConstants.EDGE_PARTNERS_NETWORK_ID, batchInputs);
                        }
                        catch(Exception ex){
                            PRMUtilityClass.createException(ex);
                        }
                    }
                    else{
                        batchInputs = new List<ConnectApi.BatchInput>();
                    }
                }
            }
        }
    }
     /*************************************************************************************** 
    * Author - Sudheendra
    * Method - createChatterPost
    * Description - This Method returns the ChatterFeedInstance that will be used in invoke bulk chatter feed queuable class.
    ****************************************************************************************/
    public Static ConnectApi.FeedItemInput createChatterPost(Id parentRecordId, Set<Id> setOfUserId, String chatterTxtMsg){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        List<ConnectApi.MessageSegmentInput> messageSegments = new List<ConnectApi.MessageSegmentInput>();
        feedItemInput.subjectId = parentRecordId;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        Integer count = 0;
        for(Id userId : setOfUserId) {
            messageSegments = PRMUtilityClass.addMentionSegment(userId, messageSegments);
            count++;
            if(count ==  25){
                break;
            }
        }
        messageSegments = PRMUtilityClass.addTextSegment(chatterTxtMsg, messageSegments);

        messageBodyInput.messageSegments = messageSegments;
        feedItemInput.body = messageBodyInput;
        return feedItemInput;
    }


}
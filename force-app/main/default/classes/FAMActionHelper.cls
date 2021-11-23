/*****************************************************************************************
* ModifiedBy     ModifiedDate     Edge          Description
* Payal Popat    28/10/2020       EDGE-185605   Created new method for quoteGeneration

* Aarathi Iyer   08/12/2020       EDGE 184803   Parent DPR OLI and Child DPR OLI instantiation
* Vishal Arbune  09/12/2020       EDGE-188898   Changes to FA status and date fields when Agreement status is updated to "In Effect"
* Manish Berad   11/12/2020       EDGE-177929   Create DPR Offer line items for AM Device during Frame Agreement configuration
* Sunil N   15/12/2020            EDGE-177926   Create DPR Offer line items for AM Plan & Device addOn's during Frame Agreement configuration
* Vishal Arbune  15/12/2020       EDGE-186881   Changes to Deal escalation flow for Partner users for Frame Agreement as per Final Delegation outcome
* Manuga Kale    12/18/2020       EDGE-188476   partner user should be able to create a Frame Agreement and make a Deal Score Call 
* Manish Berad   31/01/2021       EDGE-196353 & EDGE-200473
* Manish Berad    11/03/2021         EDGE-199307    As a Sales/Partner user when I have created Deal Opportunity, Then  I MUST capture "Opportunity Primary Contact role" (Validation) while creating a New Frame Agreement 
* Vishal Arbune  10/03/2021       EDGE-203940   <FA Delegation> As a Deal Approver I should be able to Re-score a Deal
* Shashank Jadhav   11/03/2021    EDGE-203808   Changes related to the FundConsole Tab Functionality
* Kamlesh Kumar  17/03/2021       EDGE-200438   In getQueueUsers Replacing Enterprise_Pricing_User_3 with Enterprise_Pricing_User_1 in the soql to fetch the users from the right queue
* Shivaprasad    07/04/2021       EDGE-205066   Advance fund payment frequency allocation

* Parmanand Shete    20/04/2021    EDGE-211114    Added Minimum Spent per Month Manual calculation 
* Manish Berad      26/04/2021   EDGE-211115 & EDGE-211116 Create DPR Rate Card record in backend to store Rate Card Lines (Rate value and Negotiated Rate value) per tier from FA configuration.
* Pradeep Mudenur    28/05/2021  EDGE-216677     Created two new methods updateDPRtoScored and updateFA as part of this requirement
* Shashidhar Kumar  24/06/2021  EDGE-219471   Updated for Field from Contract_Term to PF_Contract_Term
* Shivaprasad    25/06/2021     EDGE-219475   Added Fund Expiry(Fund Term) field 
* Shashank Jadhav:  13/07/2021    EDGE-221893-Insert Exception Log records with Exception Log Frameworks
* Ankush Rana    19/07/2021       DIGI-720     Logic change to stop deriving User.Delegation_role__c based on Profile.Name = ‘Pricing Admin’, instead populate DelegationRole__c = Customized Pricing for every ‘Pricing Admin’ user
* Shivaprasad       10/08/2021  DIGI-2608       As a Sales or Partner users, the FA escalation recall button should be available when certain conditions are met. This is so that I can recall only when work has not started on the case
* Manish Berad   01/09/2021     DIGI-9984: As a Sales or Partner user, I would like the system to warn me if one of the companies cannot be added to the related BSA so that I adhere to the business rules
************************************************************************************************************************************************/

global with sharing class FAMActionHelper implements csfam.RemoteActionDataProvider {
    
   
        
    //EDGE-203808-Initialized required variables-Start
    public static Map<String,List<Marketable_Offer__c>> productFamilyToMO   = new Map<String,List<Marketable_Offer__c>>();//EDGE-203808-Get the product family with list of MO's    
    //EDGE-203808-End
    global Object performAction(String param) {

        Map <String, Object> inputMap = (Map <String, Object>) JSON.deserializeUntyped(param);

        if ((String) inputMap.get('method') == 'refreshDelegatedPricing') {
            //we need to create Delegated price request records
            String faId = (String) inputMap.get('faId');

            Object res = refreshDelegatedPricing((Id)faId);
            return JSON.serialize(res).unescapeHtml4();
        } else if ((String) inputMap.get('method') == 'beforeActivationValidation') {
            String faId = (String) inputMap.get('faId');
            return beforeActivationValidation((Id)faId);
        } else if ((String) inputMap.get('method') == 'cancelFrameAgreement') {
            String faId = (String) inputMap.get('faId');
            return cancelFrameAgreement((Id)faId);
        } else if ((String) inputMap.get('method') == 'getUserDetails') {
            return userDetails();
        } else if ((String) inputMap.get('method') == 'generateOpportunityTeamMember') {
            String faId = (String) inputMap.get('faId');
            return generateOpportunityTeamMember(faId);
        } else if ((String) inputMap.get('method') == 'getDealApproverDetails') {
            String dealApproverId = (String) inputMap.get('dealApproverId');
            return getDealApproverDetails(dealApproverId);
        } else if ((String) inputMap.get('method') == 'getQueueUsers') {
            return getQueueUsers();
        } else if ((String) inputMap.get('method') == 'activateFrameAgreement') {
            String faId = (String) inputMap.get('faId');
            return activateFrameAgreement(faId);
       }else if ((String) inputMap.get('method') == 'validateOnBeforeCreateFrameAgreement') {
     String OppId = (String) inputMap.get('OppId');
           return BeforeCreateFrameAgreementHandler.validationOnBeforeCreateFA(OppId);//EDGE-203284 && EDGE-203941

      }else if ((String) inputMap.get('method') == 'quoteGeneration') { // Added this else if condition for quoteGeneration Method check as a part of EDGE-185605

        String faId = (String) inputMap.get('faId');
        return JSON.serialize(GenerateDelegatedPricingQuote.createQuote(faId));
      }else if ((String) inputMap.get('method') == 'CustomContractSync') {// Edge-185053:- Added this else if condition for CustomContractSync
            String faId = (String) inputMap.get('faId');
            return CustomContractSync((Id)faId);
      }else if((String) inputMap.get('method') == 'updateDPRtoDraft'){// EDGE-196353
            String faId = (String) inputMap.get('faId');
            return updateDPRtoDraft((Id)faId);
            //START OF EDGE-216677:Mapping the new method updateDPRtoScored:Osaka:PradeepM
      }else if((String) inputMap.get('method') == 'updateDPRtoScored'){
            String faId = (String) inputMap.get('faId');
            return updateDPRtoScored((Id)faId);
      }else if((String) inputMap.get('method') == 'updateFA'){
            String faId = (String) inputMap.get('faId');
            return updateFA((Id)faId);
            //END OF EDGE-216677
      }else if((String) inputMap.get('method') == 'createDealOppAndOppContactRol'){// EDGE-196353
            String faId = (String) inputMap.get('faId');
            return CreateDealOppAndOppContact.updateFARevisionFields((Id)faId);



      }else if ((String) inputMap.get('method') == 'getDPRRecords') {//EDGE-203808-Start
            String faId = (String) inputMap.get('faId');
            return FAM_DPR_Utility.getDPRRecords(faId);
      }//EDGE-203808-End


      else if ((String) inputMap.get('method') == 'getIsDealEscalatedFlag') { //EDGE-203940
            String faId = (String) inputMap.get('faId');
            return getIsDealEscalatedFlag(faId);
       }
       else if ((String) inputMap.get('method') == 'setIsDealEscalatedFlag') { //EDGE-203940
            String faId = (String) inputMap.get('faId');
            return setIsDealEscalatedFlag(faId);
       }else if((String) inputMap.get('method') == 'ValidateInitiateContractAction'){
            String FrameId = (String) inputMap.get('FrameId');
            return CreateDealOppAndOppContact.ValidateInitiateContractAction(FrameId);//ValidateInitiateContractAction(FrameId);
        }
        return null;
    }
    
    //EDGE-200473 & EDGE-196353
    public string updateDPRtoDraft(Id frameAgreementId){
        String responseMsg = 'success';
        //currnent FA
        if(frameAgreementId!= null){
            csconta__Frame_Agreement__c fa = [SELECT Id, Opportunity__c, Delegated_Pricing_Request__c
                                              FROM csconta__Frame_Agreement__c
                                              WHERE Id = :frameAgreementId limit 1];
            if (fa.Delegated_Pricing_Request__c != null) {
                Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
                    Id             =fa.Delegated_Pricing_Request__c,
                    Deal_Status__c = 'Draft',
                    Synchronise_With_Opportunity__c =false,
                    isPrimary__c=false);
                update dpr;
            }            
        }
        return responseMsg;
    }
    
        //START OF EDGE-216677: Creating the New Method updateDPRtoScored: Osaka: PradeepM
    public string updateDPRtoScored(Id frameAgreementId){
        String responseMsg = 'success';
        //current FA
        if(frameAgreementId!= null){
            csconta__Frame_Agreement__c fa = [SELECT Id, Opportunity__c, Delegated_Pricing_Request__c
                                              FROM csconta__Frame_Agreement__c
                                              WHERE Id = :frameAgreementId limit 1];
            if (fa.Delegated_Pricing_Request__c != null) {
                Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
                    Id             =fa.Delegated_Pricing_Request__c,
                    Deal_Status__c = 'Scored',
                    Synchronise_With_Opportunity__c =false,
                    isPrimary__c=false);
                update dpr;
               
            }   
        }
        return responseMsg;
    }
    
    public static String updateFA(String frameId)  {
        String responseMsg = 'success';
        csconta__Frame_Agreement__c frameRec = new csconta__Frame_Agreement__c();
        
        csconta__Frame_Agreement__c frameRecUpdate = new csconta__Frame_Agreement__c();
        
        frameRec = [select id,Final_Delegation_Outcome__c,csconta__Status__c from csconta__Frame_Agreement__c frameRec where id = :frameId];  if(frameRec!= null){
            
            frameRecUpdate.Id = frameRec.id;
            
            frameRecUpdate.Final_Delegation_Outcome__c = 'BOH Quality Check';
            
            frameRecUpdate.csconta__Status__c = 'Scored';
             frameRecUpdate.isPrimary__c = true;
            
            update frameRecUpdate;
        }  
        return responseMsg;
    }
 
//END OF EDGE-216677
          
        public String beforeActivationValidation(Id frameAgreementId) {
        String responseMsg = '';
        //currnent FA

        List<csconta__Frame_Agreement__c> lstFa = [SELECT Id, Opportunity__c, Delegated_Pricing_Request__c,csconta__Account__r.Id,csconta__Account__c

                                                   FROM csconta__Frame_Agreement__c
                                                   WHERE Id = :frameAgreementId AND csconta__replaced_frame_agreement__c=null];
        if(!lstFa.isEmpty()){
            //find if there are other FA on that Opp that are already active, excluding current FA
            List<csconta__Frame_Agreement__c> activeFAs = [SELECT Id, Name, csconta__Agreement_Name__c
                                                           FROM csconta__Frame_Agreement__c

                                                           WHERE csconta__Account__c= :lstFa[0].csconta__Account__r.Id AND csconta__Status__c = 'Active' AND Id != :lstFa[0].Id];

            if (!activeFAs.isEmpty()) {
                responseMsg =Label.Active_Frame_Agreement_Message +'  '+ activeFAs[0].csconta__Agreement_Name__c;
            }
        }
        return responseMsg;
    }
    




    /**
     * Cancel FA and ensure that DPR is also cancelled
     */
    public String cancelFrameAgreement(Id frameAgreementId) {
        String responseMsg = 'success';
        //currnent FA
        csconta__Frame_Agreement__c fa = [SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c
                                          FROM csconta__Frame_Agreement__c
                                          WHERE Id = :frameAgreementId];
        //update statuses
        fa.csconta__Status__c = 'Cancelled';
        update fa;
        if (fa.Delegated_Pricing_Request__c != null) {
            Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
                Id             = fa.Delegated_Pricing_Request__c,
                Deal_Status__c = 'Cancelled');
            update dpr;
        }

        return responseMsg;
    }

    /**
     * FA activation also updates DPR to Active
     */
    public String activateFrameAgreement(Id frameAgreementId) {
        String responseMsg = 'success';
        //currnent FA
        csconta__Frame_Agreement__c fa = [SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c, Delegated_Pricing_Request__r.Replaced_DPR__c
                                          FROM csconta__Frame_Agreement__c
                                          WHERE Id = :frameAgreementId];

        //EDGE-188898
        if(fa.csconta__Status__c == 'Active'){
            csconta__Frame_Agreement__c faAgreement = new csconta__Frame_Agreement__c(Id = fa.ID, Contract_Acceptance_Date__c = DateTime.now());
            update faAgreement;         
        }

        if (fa.Delegated_Pricing_Request__c != null) {
            List<Delegated_Pricing_Request__c> listDpr = new List<Delegated_Pricing_Request__c>();
            Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(Id = fa.Delegated_Pricing_Request__c, Deal_Status__c = 'Active');
            listDpr.add(dpr);
            If(fa.Delegated_Pricing_Request__r.Replaced_DPR__c  != null){
                Delegated_Pricing_Request__c oldDpr = new Delegated_Pricing_Request__c();
                oldDpr.id = fa.Delegated_Pricing_Request__r.Replaced_DPR__c;
                oldDpr.Deal_Status__c = 'Closed';
                listDpr.add(oldDpr);
            }
            update listDpr;
        } else {
            responseMsg = 'No DPR record found!';
        }
        
        //Start EDGE-219476: Moved PRESyncInvoker.futureSynchronise() call from FrameAgreementTrigger
        FAM_PRGRA_Handler handler=new FAM_PRGRA_Handler();
        String responseFromPGPPR=handler.preparePricingGroupsPerProductFamily(fa.Id);
        if(!Test.isRunningTest() && responseFromPGPPR == 'Success'){//Added Success condition
            System.debug('$$$$$Entered in isRunningTest'+responseFromPGPPR);
            PRESyncInvoker.futureSynchronise();
        }
        //End EDGE-219476
        
        // Start EDGE-205066
        System.debug('Called from FAMAction... OneFundRecordCreation.createOneFundRecord:::'+fa.Id);
        OneFundRecordCreation.createOneFundRecord(fa.Id);
        // End EDGE-205066
        
        return responseMsg;
    }

    //EDGE-203940
    public String getIsDealEscalatedFlag(Id frameAgreementId) {     
        String responseMsg = 'true';
        
        csconta__Frame_Agreement__c fa = [SELECT Id, is_Deal_Escalated__c FROM csconta__Frame_Agreement__c WHERE Id = :frameAgreementId];

        if (fa != null) {
            responseMsg = String.valueOf(fa.is_Deal_Escalated__c);
        }
        return responseMsg;
    }
    public String setIsDealEscalatedFlag(Id frameAgreementId) {     
        String responseMsg = 'true';
        csconta__Frame_Agreement__c fa = new csconta__Frame_Agreement__c();
        fa.Id = frameAgreementId ;
        fa.is_Deal_Escalated__c = true;
        System.debug('fa.is_Deal_Escalated__c::'+fa.is_Deal_Escalated__c);
        update fa;
        System.debug('fa.is_Deal_Escalated__c::'+fa.is_Deal_Escalated__c+'responseMsg::'+responseMsg);
        return responseMsg;
    }

    public String escalateFAM(Id frameAgreementId) {
        String responseMsg = 'success';
        //currnent FA
        csconta__Frame_Agreement__c fa = [SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c
                                          FROM csconta__Frame_Agreement__c
                                          WHERE Id = :frameAgreementId];
        //update statuses
        //  fa.csconta__Status__c = 'Escalate';
        fa.is_Deal_Escalated__c = true;

        update fa;
        if (fa.Delegated_Pricing_Request__c != null) {
            Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
                Id                   = fa.Delegated_Pricing_Request__c,
                is_Deal_Escalated__c = true);
            update dpr;

        }

        return responseMsg;
    }
    // Method to return the user details to the FAM
    //DIGI-720 Removed If block
    public String userDetails(){
        User u = [SELECT id,name,Delegation_Role__c,Profile.name FROM user WHERE id =: userInfo.getUserId()];
        return JSON.serialize(u);
    }
    // Method to return the user details to the FAM
    public String getDealApproverDetails(String dealApproverId){
        User u = [SELECT id,name,Delegation_Role__c,Profile.name FROM user WHERE id =: dealApproverId];
        return JSON.serialize(u);
    }
    //Method to return queue members
    //EDGE-200438 - Replace Enterprise_Pricing_User_3 with Enterprise_Pricing_User_1 in the soql
    public String getQueueUsers() {
        Map<Id, User> userMap = new Map<Id, User>([SELECT id,name,Delegation_Role__c,Profile.name
                                                   FROM User
                                                   Where Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = 'Enterprise_Pricing_User_1')]);
        return JSON.serialize(userMap);
    }
    // Add Deal approver to opportunity team member
    public String generateOpportunityTeamMember(Id frameAgreementId) {
        String responseMsg = 'success';
        //currnent FA
        List<csconta__Frame_Agreement__c> famList = [SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c,Deal_Approver__c,Deal_Approver__r.Delegation_Role__c,Final_Delegation_Outcome__c,Delegated_Pricing_Request__r.Final_Delegation_Outcome__c
                                                     FROM csconta__Frame_Agreement__c
                                                     WHERE Id = :frameAgreementId];

        List<OpportunityTeamMember> OppTeamMember = new List<OpportunityTeamMember>();
        for (csconta__Frame_Agreement__c fam:famList) {
            if (fam.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c == 'Sales Specialist' || fam.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c == 'Sales Manager' || fam.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c == 'Sales General Manager' || fam.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c == 'Account Executive' || fam.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c == 'BOH Quality Check') {
                OpportunityTeamMember opp = new OpportunityTeamMember();
                //EDGE-186881 Changes to Deal escalation flow for Partner users
                if(fam.Deal_Approver__r.Delegation_Role__c != null && fam.Deal_Approver__r.Delegation_Role__c == 'Account Executive'){
          Opp.UserId         = fam.Deal_Approver__c;
          Opp.OpportunityId  = fam.Opportunity__c;
          Opp.TeamMemberRole = 'Account Executive';
          OppTeamMember.add(Opp);
        }else{
          Opp.UserId         = fam.Deal_Approver__c;
          Opp.OpportunityId  = fam.Opportunity__c;
          Opp.TeamMemberRole = 'Opportunity Team Member';
          OppTeamMember.add(Opp);
        }
            }
        }
        upsert OppTeamMember;

        return responseMsg;
    }

    /**
     * Will refresh whole DPR structure for given FA only if FA is in Status = Draft
     * Runs proper update update logic i.e. supports modify (not doing simply delete all + create all)
     */
    public Boolean refreshDelegatedPricing(Id frameAgreementId) {
        System.debug('@@1');
        //one combined list for all the records we need to delete
        List<sObject> recordsToDelete = new List<sObject>();
        //existing records so we can support update
        Map<Id,DPR_Offer__c> existingOffers = new Map<Id,DPR_Offer__c>();
        Map<Id,DPR_Rate_Card__c> mapOfExistingRateCard = new Map<Id,DPR_Rate_Card__c>();
        Map<Id,DPR_Rate_Card__c> mapOfExistingRateCardLine = new Map<Id,DPR_Rate_Card__c>();
        //Marketable offer to DPR Offer map so that we can reuse it when adding new DPR OLIs
        Map<Id,DPR_Offer__c> existingMoIdToDprOffer                               = new Map<Id,DPR_Offer__c>();
        Map<Id,DPR_Offer_Line_Item__c> existingDPROLI                             = new Map<Id,DPR_Offer_Line_Item__c>();
        Map<Id, DPR_Offer_Line_Item__c> commercialProductIdToExistingParentOliMap = new Map<Id, DPR_Offer_Line_Item__c>();
        Delegated_Pricing_Request__c dpr;
        try{//EDGE-221893: Added try block
            //Load needed FA data


            csconta__Frame_Agreement__c fa = [SELECT Id, Opportunity__c, Delegated_Pricing_Request__c,csconta__replaced_frame_agreement__r.Delegated_Pricing_Request__c, csconta__Status__c,csconta__replaced_by__c,Mark_as_Variation__c,is_Deal_Escalated__c,Deal_Approver__c
                                              FROM csconta__Frame_Agreement__c
                                              WHERE Id = :frameAgreementId]; // EDGE-203808-Fetching Mark_as_Variation__c field
            System.debug('@@2');
            //if the FA status is not Draft then deal score affecting change did not happen so do not refresh DPR!
            if (fa.csconta__Status__c != 'Draft') {
                return true;
            }
            //extract commercial products Ids and volumes from attachment, volumes not used yet but this is usefull to get what products we need
            FAM_Utility famUtil                                                = new FAM_Utility(fa.Id);
            Map<Id, FAM_Utility.VolumeAndPricing> productToVolumeAndPricingMap = famUtil.getProductToVolumeAndPricingMap();
            //sanity check
            Map<String, FAM_Utility.FundData> fundConsoleRecordsMap= famUtil.getFundConsoleCustomMap(); // EDGE-203808-fundConsoleRecordsMap from FA JSON attachment file
            if (productToVolumeAndPricingMap.isEmpty() && fa.Delegated_Pricing_Request__c != null) {
                System.debug('@@3');
                //no products then we need to delete everything.
                dpr = [SELECT Id, Deal_Status__c,
                       (SELECT Id FROM Delegated_Pricing_Request_Offers__r),
                       (SELECT Id FROM DPR_Offer_Line_Items__r),
                       (SELECT Id FROM DPR_GBB_Report_Detailes__r),
                       (SELECT Id FROM Delegated_Outcomes__r)
                       FROM Delegated_Pricing_Request__c
                       WHERE Id = :fa.Delegated_Pricing_Request__c];
                //clean it all up in reverse order
                delete dpr.Delegated_Outcomes__r;
                delete dpr.DPR_GBB_Report_Detailes__r;
                delete dpr.DPR_Offer_Line_Items__r;
                delete dpr.Delegated_Pricing_Request_Offers__r;
                //stop any other logic
                return false; //TODO we might need more info
            } else if (fa.Delegated_Pricing_Request__c != null && fa.csconta__Status__c == 'Draft') {//EDGE-200473 start
                System.debug('@@4 ');
                
                //DIGI-2608 Start
                if (!fa.is_Deal_Escalated__c){
                    System.debug('Setting deal approver null:::'+fa.is_Deal_Escalated__c);
                     fa.Deal_Approver__c = null;
                    update fa;
                }
                //DIGI-2608 End
                
                //DRP not null & DRP status Draft  then we need to delete PRE response.
                dpr = [SELECT Id, Deal_Status__c,Opportunity__c,Opportunity__r.Contract_Term__c,
                       (SELECT Id,Fund_Amount__c FROM Delegated_Pricing_Request_Offers__r),
                       (SELECT Id FROM DPR_Offer_Line_Items__r),
                       (SELECT Id FROM DPR_GBB_Report_Detailes__r),
                       (SELECT Id FROM Delegated_Outcomes__r)
                       FROM Delegated_Pricing_Request__c
                       WHERE Id = :fa.Delegated_Pricing_Request__c];
                //EDGE-203808-Added Fund_Amount__c in Query
                //clean it all up in reverse order
                delete dpr.Delegated_Outcomes__r;
                delete dpr.DPR_GBB_Report_Detailes__r;
                
                for (DPR_Offer__c DPROffer :dpr.Delegated_Pricing_Request_Offers__r){

                    DPROffer.ActualOfferPrice__c = null;
                    DPROffer.BestMaxValue__c = null;
                    DPROffer.BetterBestValue__c = null;
                    DPROffer.GoodBetterValue__c = null;
                    DPROffer.MarginalGoodValue__c = null;
                    DPROffer.MinimalMarginalValue__c = null;
                    DPROffer.PoorMinimalValue__c = null;
                    DPROffer.Fund_Amount__c = null;//EDGE-203808-Setting Fund_Amount__c as null

                    DPROffer.Minimum_Spent_per_Month_Manual__c = null;//EDGE-211114

                }
                //update fa.Deal_Approver__c = null;
                update dpr.Delegated_Pricing_Request_Offers__r;
                //EDGE-200473 end
                
            }
           System.debug('@@4');
            //get DPR data as we need it anyway
            if (fa.Delegated_Pricing_Request__c == null) {
                 Delegated_Pricing_Request__c tmpDPR;
               tmpDPR = DPRVariationHelper.updateDPRVariation(fa);
                dpr = [SELECT Id, Opportunity__c, Deal_Status__c, Opportunity__r.Contract_Term__c
                       FROM Delegated_Pricing_Request__c
                        WHERE Id = :tmpDPR.Id];
            } else {
                //Load and populate all variables needed to implement update scenario
                dpr = [SELECT Id, Opportunity__c, Deal_Status__c, Opportunity__r.Contract_Term__c
                       FROM Delegated_Pricing_Request__c
                       WHERE Id = :fa.Delegated_Pricing_Request__c];
                //offers and lines
                existingOffers = new Map<Id,DPR_Offer__c>([SELECT Id, Name, Marketable_Offer__c, PF_Contract_Term__c, Product_Family__c, Delegated_Pricing_Request__c FROM DPR_Offer__c WHERE Delegated_Pricing_Request__c = : dpr.Id]);
                existingDPROLI = new Map<Id,DPR_Offer_Line_Item__c>(
                    [SELECT Id, Name, Delegated_Pricing_Request__c, DPR_Offer__c, cspmb_Price_Item__c, Parent_DPR_Offer_Line_Item_Id__c,
                     List_Price__c, Overridden_Unit_price__c, Quantity__c, Recontracting_Quantity__c, Total_Recurring_Charge__c,
                     Marketable_Offer__c, Offer_Type__c,Offer_Type_Name__c, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Unit_Type__c, DPR_Offer_Line_Item_Value__c,
                     Fund_Allocation__c,Portfolio_Margin__c,Marketable_Offer__r.Fund_Allocation_Percentage__c,Marketable_Offer__r.Portfolio_Margin_Percentage__c,
                     (SELECT Id FROM DPR_Offer_Line_Items__r) //just subquery so we can easily find child record, expecting only 1 record
                     FROM DPR_Offer_Line_Item__c
                     WHERE Delegated_Pricing_Request__c = : dpr.Id]);
                
                //EDGE-211115 & EDGE-211116 ....Start
                List<DPR_Rate_Card__c> dprRateCard=[Select Id,Delegated_Pricing_Request__c,DPR_Rate_Card_Type__c,Parent_DPR_OLI_id__c,
                                                    Parent_DPR_Rate_Card_ID__c,Rate_Card__c,Rate_Card_Line__c
                                                    From DPR_Rate_Card__c 
                                                    Where Delegated_Pricing_Request__c=:dpr.Id];
                //EDGE-211115 & EDGE-211116 ....end
                
                //populate map so we can find existing DPR Offer when creating new DPR OLI
                for (DPR_Offer__c dprO : existingOffers.values()) {
                    if(dprO.Marketable_Offer__c != null)//EDGE-203808-Added null check
                    existingMoIdToDprOffer.put(dprO.Marketable_Offer__c, dprO);
                }
                //populate map so we can find parent DPR OLI line by commercial product id
                for (DPR_Offer_Line_Item__c oli :existingDPROLI.values()) {
                    //adding only parent lines as we have child ones in subquery and in existingDPROLI
                    if (oli.Parent_DPR_Offer_Line_Item_Id__c == null) {
                        commercialProductIdToExistingParentOliMap.put(oli.cspmb_Price_Item__c, oli);
                    }
                }
                
                //EDGE-211115 & EDGE-211116 ....Start
                if(!dprRateCard.isEmpty()){
                    for(DPR_Rate_Card__c rc:dprRateCard){
                        if(rc.DPR_Rate_Card_Type__c=='Rate Card'){
                            mapOfExistingRateCard.put(rc.Rate_Card__c,rc);
                        }else{
                            mapOfExistingRateCardLine.put(rc.Rate_Card_Line__c,rc);
                        }
                    }
                }
                //EDGE-211115 & EDGE-211116 ....end
            }
        
            //load commercial products and organize them per offer names

            List<cspmb__Price_Item__c> cpList = [SELECT Id, Name, Offer_Id__c, cspmb__Recurring_Charge__c,
                                                 cspmb__One_Off_Charge__c, Plan__c,Type__c,cspmb__Is_Recurring_Discount_Allowed__c,
                                                 cspmb__Is_One_Off_Discount_Allowed__c,ProdSpecId__c,Model__c,ChargeType__c,IsContributing__c
                                                 FROM cspmb__Price_Item__c
                                                 WHERE Id IN :productToVolumeAndPricingMap.keySet()
                                            ];// AND Offer_Id__c = 'DMCAT_Offer_001233' AND Name = 'Enterprise Mobility'
                                            //EDGE-203808Added IsContributing__c in SOQL
            
            /** EDGE-177926 Start **/
            Set<String> setOfAddOnAssIds=new Set<String>();
            Map<String,FAM_Utility.AddOnPricing> mapOfAddOn=New Map<String,FAM_Utility.AddOnPricing>();
            Map<Id, Map<Id, Decimal>> mapOfRCvsRCL=new Map<Id, Map<Id, Decimal>>();
            for(Id vp:productToVolumeAndPricingMap.keyset()){
                FAM_Utility.VolumeAndPricing vPobj=productToVolumeAndPricingMap.get(vp);
                Map<String,FAM_Utility.AddOnPricing> mapOfAddOnPrice=vPobj.addOnAssociationToPricingMap;
                system.debug('mapOfAddOnPrice-->'+mapOfAddOnPrice);
                if(mapOfAddOnPrice!=null){
                for(String addOnKey:mapOfAddOnPrice.keySet()){                
                      FAM_Utility.AddOnPricing addOnWrapp=mapOfAddOnPrice.get(addOnKey);
                      mapOfAddOn.put(addOnKey,addOnWrapp);   
                    }
                }
                //EDGE-211115 & EDGE-211116 ....Start
                Map<Id, Map<Id, Decimal>> rCToRCLinesMap=vPobj.rateCardToRateCardLinesMap;
                system.debug('rCToRCLinesMap-->'+rCToRCLinesMap);
                if(rCToRCLinesMap!=null){
                    for(String rcKey:rCToRCLinesMap.keySet()){
                        Map<Id, Decimal> mapOfRCL=rCToRCLinesMap.get(rcKey);
                        mapOfRCvsRCL.put(rcKey,mapOfRCL);
                    }
                }
                //EDGE-211115 & EDGE-211116 ....end
                setOfAddOnAssIds.addAll(mapOfAddOn.keySet());
            }
            //System.debug('setOfAddOnAssIds'+setOfAddOnAssIds);
            //System.debug('mapOfAddOn'+mapOfAddOn);
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstOfPriceItenAddOnAss=[SELECT Id, AddOnName__c,cspmb__Price_Item__c, cspmb__Add_On_Price_Item__c,cspmb__Add_On_Price_Item__r.cspmb__Is_Recurring_Discount_Allowed__c,
                                                                                             cspmb__Recurring_Charge__c,cspmb__One_Off_Charge__c,cspmb__Add_On_Price_Item__r.cspmb__Is_One_Off_Discount_Allowed__c
                                                                                             FROM cspmb__Price_Item_Add_On_Price_Item_Association__c 
                                                                                             Where ID IN:setOfAddOnAssIds
                                                                                             AND cspmb__Price_Item__r.Check_todays_date__c = true 
                                                                                             AND cspmb__Add_On_Price_Item__r.check_todays_date__c = true];
            //System.debug('setOfAddOnAssIds'+lstOfPriceItenAddOnAss);
            Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> > mapOfPriceItemVsPIA = new Map<String, List<cspmb__Price_Item_Add_On_Price_Item_Association__c> >();
            if(!lstOfPriceItenAddOnAss.isEmpty()){
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c PIA:lstOfPriceItenAddOnAss){
                    if (!mapOfPriceItemVsPIA.containsKey(PIA.cspmb__Price_Item__c)) {
                        mapOfPriceItemVsPIA.put(PIA.cspmb__Price_Item__c, new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>());
                    }
                    mapOfPriceItemVsPIA.get(PIA.cspmb__Price_Item__c).add(PIA);
                    
                }
            }
            //System.debug('mapOfPriceItemVsPIA'+mapOfPriceItemVsPIA);

            
            //EDGE-211115 & EDGE-211116 ....Start
            //Load Commercial Product Rate Card 
            Map<String,cspmb__Price_Item_Rate_Card_Association__c> mapOfCPvsRCAssociation=new Map<String,cspmb__Price_Item_Rate_Card_Association__c>();
            List<cspmb__Price_Item_Rate_Card_Association__c> lstRateCardAssociation = [SELECT Id,Name,cspmb__Price_Item__c,
                                                                                       cspmb__default__c,External_Id__c,cspmb__group__c,cspmb__max__c,cspmb__min__c,cspmb__Rate_Card__c
                                                                                       FROM cspmb__Price_Item_Rate_Card_Association__c
                                                                                       WHERE cspmb__Price_Item__c IN :productToVolumeAndPricingMap.keySet()
                                                                                      ];
            Set<String> setOfRCIds=new Set<String>();
            if(!lstRateCardAssociation.isEmpty()){
                for(cspmb__Price_Item_Rate_Card_Association__c rca:lstRateCardAssociation){
                    if(rca.cspmb__Price_Item__c!=null){

                        mapOfCPvsRCAssociation.put(rca.Id,rca);

                        setOfRCIds.add(rca.cspmb__Rate_Card__c);
                    }
                }
            }
            Map<String,cspmb__Rate_Card_Line__c> mapOfRCL=new Map<String,cspmb__Rate_Card_Line__c>();
            if(setOfRCIds!=null){
                List<cspmb__Rate_Card_Line__c> lstOfRCL=[Select Id,cspmb__rate_value__c,cspmb__Rate_Card__c 
                                                         From cspmb__Rate_Card_Line__c 
                                                         Where cspmb__Rate_Card__c IN:setOfRCIds];
                if(!lstOfRCL.isEmpty()){
                    for(cspmb__Rate_Card_Line__c rcl:lstOfRCL){
                        mapOfRCL.put(rcl.Id,rcl);
                    }
                }
                
            }
             //EDGE-211115 & EDGE-211116 ....end
             

         /*- EDGE-177926 end-*/
            //organize the data per offer name
            Map<String, List<cspmb__Price_Item__c> > offerNameToCP = new Map<String, List<cspmb__Price_Item__c> >();
            for (cspmb__Price_Item__c cp :cpList) {
                //initialize the map for offer nam
                if (!offerNameToCP.containsKey(cp.Offer_Id__c)) {
                    offerNameToCP.put(cp.Offer_Id__c, new List<cspmb__Price_Item__c>());
                }
                offerNameToCP.get(cp.Offer_Id__c).add(cp);
            }
            //get all needed Marketable offers
            List<Marketable_Offer__c> marketableOffers = [SELECT Id, Offer_ID__c, Name, Product_Family__c,Fund_Allocation_Percentage__c,Portfolio_Margin_Percentage__c
                                                          FROM Marketable_Offer__c
                                                          WHERE Offer_ID__c IN :offerNameToCP.keySet()]; //EDGE-203808-Added Product_Family__c in SOQL
            //System.debug('$$##:marketableOffers='+marketableOffers);
            Map<String,Marketable_Offer__c> offerNameToMO = new Map<String,Marketable_Offer__c>();
            Map<String,Marketable_Offer__c> offerIdToMO   = new Map<String,Marketable_Offer__c>();
            //Map<String,List<Marketable_Offer__c>> productFamilyToMO=FAM_DPR_Utility.getProductFamilyToMO();
            
            for (Marketable_Offer__c mo :marketableOffers) {
                offerNameToMO.put(mo.Offer_ID__c, mo);
                offerIdToMO.put(mo.Id, mo);
                //EDGE-203808- Start
                if(!productFamilyToMO.containsKey(mo.Product_Family__c))
                    productFamilyToMO.put(mo.Product_Family__c, new List<Marketable_Offer__c> {mo});
                else
                    productFamilyToMO.get(mo.Product_Family__c).add(mo);
                // EDGE-203808-End
            }
            System.debug('@@SS::productFamilyToMO='+productFamilyToMO);
            System.debug('@@SS::dpr='+dpr);
            System.debug('@@SS::existingMoIdToDprOffer='+existingMoIdToDprOffer);
            System.debug('@@SS::offerIdToMO='+offerIdToMO);
            System.debug('@@SS::productFamilyToMO='+productFamilyToMO);
            //data generation
            //1. Find DPR Offers that are missing (should be created) and those that are no longer needed (should be deleted)
            //List<DPR_Offer__c> dprOffers = new List<DPR_Offer__c>(); //master list where we have missing ones created and no longer needed ones removed
            List<DPR_Offer__c> dprOffers = FAM_DPR_Utility.createDPROffers(dpr,existingMoIdToDprOffer,offerIdToMO,productFamilyToMO); //master list where we have missing ones created and no longer needed ones removed
            //System.debug('@@SS:dprOffers: insert' + dprOffers);
            
            Map<String,DPR_Offer__c> mapOfProductFamilyToDPROffer=new Map<String,DPR_Offer__c>();//Not used we check to delete this mapOfProductFamilyToDPROffer
            
            //update existing Map so we can detect not needed ones
          /*  Set<Id> createdOfferIds = new Set<Id>();
            if(dprOffers != null && !dprOffers.isEmpty()){
            for (DPR_Offer__c dprOffer : dprOffers) {
                    //System.debug('@SS:dprOffer-->'+dprOffer);
                    // EDGE-203808-iterate on productFamilyToMO logic-Start
                    if(productFamilyToMO.containsKey(dprOffer.Name)){
                        for(Marketable_Offer__c mo:productFamilyToMO.get(dprOffer.Name)){
                            //System.debug('@@SS**>o-->'+mo);
                            existingMoIdToDprOffer.put(mo.id, dprOffer);
                            createdOfferIds.add(mo.id);//better than to depend on Set keeping only unique records as it doesn't work reliably for sObjects
                        }
                    }// EDGE-203808-iterate on productFamilyToMO logic-End
                }
            }
            for (Id moId : existingMoIdToDprOffer.keySet()) {
                if (!offerIdToMO.containsKey(moId)) {
                    //not needed, adding DPR Offer to delete list
                    recordsToDelete.add(existingMoIdToDprOffer.get(moId));
                } else if (!createdOfferIds.contains(moId)) {
                    //still needed, adding to master list
                    dprOffers.add(existingMoIdToDprOffer.get(moId));
                }
            }*/

            //for each offer update or create its DPR Offer Line Item
            List<DPR_Offer_Line_Item__c> dprOLIForUpsert = FAM_DPR_Utility.createDPROfferLineItems(dprOffers,commercialProductIdToExistingParentOliMap,productToVolumeAndPricingMap,offerNameToCP,offerIdToMO,fa.Mark_as_Variation__c,productFamilyToMO,fundConsoleRecordsMap);
            //prepare and upsert child OLIs
            //child ones that need to inserted have to be seperate DML i.e. after the 1st upsert as we need to have parent Ids
            Map<Id,DPR_Offer_Line_Item__c> neededOLIs = FAM_DPR_Utility.updateChildDPROfferLineItemsForAddonsAndDiscounts(dprOLIForUpsert,commercialProductIdToExistingParentOliMap,existingDPROLI,mapOfPriceItemVsPIA,mapOfAddOn,fa.Mark_as_Variation__c);
                

             //EDGE-211115 & EDGE-211116 Start
            FAM_DPR_Utility.upsertRateCardAndRateCardLineItems(dprOLIForUpsert,mapOfRCvsRCL,mapOfCPvsRCAssociation,mapOfRCL,mapOfExistingRateCard,mapOfExistingRateCardLine);    
            //EDGE-211115 & EDGE-211116.. End
            

           // neededOLIs.putAll(childDprOLIForAddOnUpsert);
            for (DPR_Offer_Line_Item__c oli :existingDPROLI.values()) {
                if (!neededOLIs.containsKey(oli.Id)) {
                    recordsToDelete.add(oli);
                }
            }
            //delete what has been marked for deletion (DPR Offers and Lines)
            if (!recordsToDelete.isEmpty()) {
                //System.debug('deleterecordsToDelete'+recordsToDelete);
                Database.delete(recordsToDelete,false);//EDGE-196353
                //delete recordsToDelete;
            }
            //reset DPR status back to draft to signal that deals scores are out of date
            dpr.Deal_Status__c = 'Draft';
            dpr.Opportunity__c = fa.Opportunity__c;
            dpr.Final_Delegation_Outcome__c = '';
            update dpr;
            //all done
            //EDGE-203808-Upodate the DPR offers from the FundData-Start
            if(!fundConsoleRecordsMap.isEmpty() && fundConsoleRecordsMap != null && fa.Delegated_Pricing_Request__c != null)
                return FAM_DPR_Utility.updateDPROffersForFundData(fa.Delegated_Pricing_Request__c,fundConsoleRecordsMap);
            //EDGE-203808-End
        }catch(Exception ex){//EDGE-221893-Start
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Frame Agreement','refreshDelegatedPricing', '', frameAgreementId, ex.getMessage(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End
        return true;
    }

    /*EDGE:123784 | Generate the pricing contract after the deal has been approved.
       public Static Id cJOrderFormRecordType = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
       @AuraEnabled

       public static String insertContJunc(Id frameAgreementId){

        List<csconta__Frame_Agreement__c> famList = [SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c,Deal_Approver__c,Final_Delegation_Outcome__c FROM csconta__Frame_Agreement__c
                                                     WHERE Id = :frameAgreementId LIMIT 1];
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c(
            Id                   = famList[0].Delegated_Pricing_Request__c,
            is_Deal_Escalated__c = true,
            Deal_Status__c       = 'Contract Initiated');
        update dpr;

        Opportunity oppRecord = [Select Id, Name, StageName,AccountId from Opportunity Where id =: famList[0].Opportunity__c LIMIT 1][0];
        oppRecord.StageName = 'propose';
        update oppRecord;

        List<ContractJunction__c> contJuncList = [Select Id from ContractJunction__c where Related_Deal__c =: dpr.Id];
        if (!contJuncList.isEmpty()) {
            delete contJuncList;
        }
        //System.debug('==============>'+dpRequest.Name);
        ContractJunction__c contractRecord = new ContractJunction__c();
        contractRecord.Name                   = 'CN' + famList[0].Name.substring(2);
        contractRecord.RecordTypeId           = cJOrderFormRecordType;
        contractRecord.Status__c              = 'Initiated';
        contractRecord.Related_Deal__c        = dpr.id;
        contractRecord.Related_Opportunity__c = oppRecord.id;
        contractRecord.Account__c             = oppRecord.AccountId;
        insert contractRecord;
        String contJuncId = contractRecord.Id;
        return contJuncId;

       }*/
    
    /*----------------------------------------------------------------------------------------------------
EDGE        - Edge-185053
Method      - CustomContractSync
Description - <B2B-1567>Sync Contract to have Fame Agreement Line Items Synced to Contract
Author      - Jayghosh Mishra
--------------------------------------------------------------------------------------------------------*/
    
    public String CustomContractSync(Id frameAgreementId) {
        System.debug('CustomContractSync called');
        String responseMsg = 'success';
        // Checking for recordType
        Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();
        csconta__Frame_Agreement__c fa = [SELECT Id, Name, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c, csconta__Account__c FROM csconta__Frame_Agreement__c WHERE Id = :frameAgreementId];
       
        String existingDPRId = updateFaStatus(fa);
        System.debug('!!!existingDPRId ' + existingDPRId);
        String faAssociatedAccount = fa.csconta__Account__c;
        String dsaId = fetchExistingDSA(faAssociatedAccount);
        System.debug('dsaId ' + dsaId);
        createFaAssociationRecord(dsaId, frameAgreementId);
        
         if(dsaId != NULL){
                // Schedule type agrrement based on parent SA agreement 
                 List<Apttus__APTS_Agreement__c> pricingAgreementWithDSA = [SELECT Id, RecordTypeId,Name,  Apttus__Parent_Agreement__c, Apttus__Agreement_Category__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where  RecordTypeId =: AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Parent_Agreement__c =: dsaId];
                 System.debug('pricingAgreementWithDSA ' + pricingAgreementWithDSA);
                 String schAgreementId = '';
                 // Scheduleprice Agreement is 
                 for(Apttus__APTS_Agreement__c pa : pricingAgreementWithDSA){
                    schAgreementId = pa.ID;
                     System.debug('@@schAgreementId ' + schAgreementId);
                 }
                 if(existingDPRId != ''){
                     String prodFamily = '';
                     Set<String> productFamily = new Set<String> ();
                     Set<Id> dprOfferId = new Set<Id> ();
                     List<DPR_Offer_Line_Item__c> dprOliRecords = new List<DPR_Offer_Line_Item__c>();
                     List<DPR_Offer__c> dprOffer = [Select id, Name, Product_Family__c, Delegated_Pricing_Request__c,Marketable_Offer__c, isNegotiableCount__c from DPR_Offer__c where Delegated_Pricing_Request__c =: existingDPRId AND isNegotiableCount__c > 0];
                     for(DPR_Offer__c filteredDprOfferId : dprOffer){
                         dprOfferId.add(filteredDprOfferId.id);
                     }
                     System.debug('&&dprOfferId for Line Item ' + dprOfferId);
                     System.debug('!!!dprOffer ' + dprOffer);
                     if(!dprOffer.isEmpty()){
                         dprOliRecords = [Select Id, Name, DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__C, DPR_Offer_Line_Item_Value__c, Marketable_Offer__r.Product_Family__c from  DPR_Offer_Line_Item__c where DPR_Offer_Line_Item_Type__c = 'plan' AND DPR_Offer__c IN: dprOfferId];
                         for(DPR_Offer_Line_Item__c filteredProdFamily : dprOliRecords){
                             prodFamily = filteredProdFamily.Marketable_Offer__r.Product_Family__c;
                             productFamily.add(prodFamily);
                         }
                         System.debug('New productFamily added' + productFamily);
                         System.debug('###dprOliRecords ' + dprOliRecords);
                         System.debug('schAgreementId ' + schAgreementId);

                         //createAgreementLineItem(schAgreementId, dprOliRecords, productFamily); EDGE-205979
                         

                     }
                 }
             }
         
        return responseMsg;
    }  
    
    public static void createAgreementLineItem(String agreementId, List<DPR_Offer_Line_Item__c> dprOliRecords, set<String> productFamily){
        System.debug('@@@@createAgreementLineItem Called  ');
        System.debug('agreementId ' + agreementId);
        String productId = fetchProductIds(productFamily);
                // Agreement line item creation
                Apttus__AgreementLineItem__c newLineAgreement = new Apttus__AgreementLineItem__c();
                newLineAgreement.Apttus__AgreementId__c = agreementId;
                newLineAgreement.Apttus__ProductId__c = productId;
                System.debug('newLineAgreement created ' + newLineAgreement);
    upsert newLineAgreement;
    List<APTPS_Component__c> attributeValues = new List<APTPS_Component__c> ();
        String agmtId = '';
    List<Apttus__AgreementLineItem__c> agreementLineItemIds = new List<Apttus__AgreementLineItem__c> ();
    agreementLineItemIds = [Select Id, Name,Apttus__productid__c, Apttus__productid__r.Name from Apttus__AgreementLineItem__c where  Apttus__AgreementId__c =: agreementId];
           agmtId = agreementLineItemIds[0].Id;
    
        System.debug('@@New ALIs Inserted ' + agmtId);
     
        for(Integer dprOliCount = 0; dprOliCount < dprOliRecords.size(); dprOliCount++){
            System.debug('Inside dprOli For ');
            // Creation of new attribute record
            APTPS_Component__c newAttValue  = new APTPS_Component__c ();
            newAttValue.APTPS_Attribute__c      = dprOliRecords[dprOliCount].Name;
            newAttValue.APTPS_Original_Value__c = dprOliRecords[dprOliCount].Offer_Type_Name__c;
            Double dprOliValue                  = dprOliRecords[dprOliCount].DPR_Offer_Line_Item_Value__c;
            newAttValue.Value__c                =  String.valueOf(dprOliValue);
            newAttValue.Type__c                 = dprOliRecords[dprOliCount].Offer_Type__r.Type__C;
            newAttValue.Agreement_Line_Item__c  = agmtId;
            attributeValues.add(newAttValue);
            System.debug('$$$attributeValues Newly Created ' + attributeValues);
        
        }
        System.debug('attributeValues upserted' + attributeValues);
        upsert attributeValues;
    }
    
    // Updating status fa status as Contract Synched
    public static String updateFaStatus(csconta__Frame_Agreement__c fa){
        System.debug('updateFaStatus called');
        //currnent FA
        String existingDPRId = '';
        
        //update statuses
        fa.csconta__Status__c = 'Contract Synched';
        String faName = fa.Id;
        System.debug('fa.Id ' + faName);
        System.debug('frame agreement New Status ' + fa.csconta__Status__c);
        update fa;
        if(fa != NULL){
        existingDPRId = fa.Delegated_Pricing_Request__c;
        System.debug('existingDPRId in updateFaStatus ' + existingDPRId);
        }
        return existingDPRId;
    }
    // fetch Existing active DSA with SA recordType related to frameagreement
    public static String fetchExistingDSA (String faAssociatedAccount){
        Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        System.debug('fetchExistingDSA Called ');
        String dsaId = '';
        List<Apttus__APTS_Agreement__c> existingDSA = [SELECT Id, RecordTypeId,name,  Apttus__Parent_Agreement__c, Apttus__Agreement_Category__c, Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c = 'In Effect'  AND Apttus__Status__c !='Cancelled Request' AND RecordTypeId =: AGREEMENT_SA_RECORDTYPEID AND Apttus__Agreement_Category__c =: 'Digital Services' AND Apttus__Account__c =: faAssociatedAccount];
        
        for(Apttus__APTS_Agreement__c dsaExxistingagmt : existingDSA){
            dsaId = dsaExxistingagmt.Id;
        }
        System.debug('@@@@Existing dsaId ' + dsaId);
        return dsaId;
    }
    // Create FAAssociation based on existing DSA and frameagreement 
    public static void createFaAssociationRecord(String dsaId, Id frameAgreementId ){
        System.debug('createFaAssociationRecord Called ');
        FA_Agreement_Association__c faAgreementAssociation = new FA_Agreement_Association__c ();
        faAgreementAssociation.Agreement__c=dsaId;
        faAgreementAssociation.FA__c=frameAgreementId;
        insert faAgreementAssociation;
        System.debug('New faAgreementAssociation association ' + faAgreementAssociation);
    }
    
    /*public static set<String> fetchAssociatedDsaForFa(Id frameAgreementId){
    System.debug('fetchAssociatedDsaForFa called');
    // Checking for DSA agreement through junction object
         List<FA_Agreement_Association__c> faAssociation = [select id, Name, Agreement__c, FA__c from FA_Agreement_Association__c where FA__c =: frameAgreementId];
        System.debug('faAssociation junction' + faAssociation);
         Set<String> agreementIds = new Set<String> ();
         for(FA_Agreement_Association__c filteredFAAssociation: faAssociation){
             System.debug('Inside first For checking association ');
             if(filteredFAAssociation.Agreement__c != NULL){
                 System.debug('@@Inside association If ');
                 agreementIds.add(filteredFAAssociation.Agreement__c);
             }
         }
         System.debug('agreementIds in new method ' + agreementIds);
         return agreementIds;
    }*/
    // Get product based on dprOffer marketOffer
    public static String fetchProductIds(set<String> productFamily){
        System.debug('fetchProductIds Called');
        String  productId = '';
        list<Product2> prodReclst = [SELECT Id, Name FROM Product2 where name  =: productFamily];
    System.debug('New prodReclst ' + prodReclst);
     
    Set<Product2> prodrec = new Set<Product2>(prodReclst);
        System.debug('prodrec set ' + prodrec);
        
        
        for(Product2 prod: prodrec){
             productId =prod.Id;
        }
        System.debug('productId in new method ' + productId);
        return productId;
    }
      
}
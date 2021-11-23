/********************************************************************************
* Class Name  : Opportunity Trigger Handler
* Description : This class is Handler Class to call the helper to execute the logic.
* Created By  : Gaurav/Palash
* Change Log  : Created
@Last Modified      : 
No.       Developer Name        Date            Story Description 
01.       Sravanthi         01/11/2021     Sprint 21.15 - DIGI-24459  Updated to prevent duplicate chatter to closure approver

********************************************************************************/

Public class C2O_OpportunityTriggerHandler extends SYS_TriggerHandler {

    //DECLARE GLOBAL VARIABLES
    //private Allow_Execution__mdt allowExec = Allow_Execution__mdt.getInstance('Opportunity');
    private Map<Id, Opportunity> newOppMap;
    private Map<Id, Opportunity> oldOppMap;
    private List<Opportunity> newOppList;
    private List<Opportunity> oldOppList;
    private String entCustomRecordTypeId = Schema.Sobjecttype.Opportunity.getRecordTypeInfosByDeveloperName().get('Custom').getRecordTypeId();
    private Account partnerAcc = New Account();
    private Account dchOwnerAcc = New Account();
    
    //LIFT and SHIFT
    Set<Id> ClosedLostDealOppIdSet = new Set<Id>();  
    Set<Id> closedLostOppIdSet = new Set<Id>();
    Set<Id> closedWonOppIdSet = new Set<Id>();
    Set<Id> developOppIdSet = new Set<Id>();
    Set<Id> closedWonOrProposeIdNonModularSet = new Set<Id>();
    Set<Id> oppIdSet = new Set<Id>();
    
    BsktStageUpdateForClosedOppsTrigHandler  can = new BsktStageUpdateForClosedOppsTrigHandler();
    OpportunityTriggerHandler handler=new OpportunityTriggerHandler();


    public C2O_OpportunityTriggerHandler() {
        this.setHandlerName('SYS_OpportunityTriggerHandler');
        this.newOppMap = (Map<Id, Opportunity>) Trigger.newMap;
        this.oldOppMap = (Map<Id, Opportunity>) Trigger.oldMap;
        this.newOppList = Trigger.new;
        this.oldOppList = Trigger.old;

    }

    /***************************************************************************************
    * Method Name - beforeInsert
    * Description - This method is used to call the before Insert operation on record.
    ****************************************************************************************/
    public override void beforeInsert() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Opportunity','triggerBeforeInsert')){
            List<Opportunity> listOfOpportunityForChangeType = new List<Opportunity>();
            List<Opportunity> BidnResMgmtReqList = new List<Opportunity>();
            List<Opportunity> RetiedAccOppList = new List<Opportunity>();
            
            for(Opportunity opp : (List<Opportunity>)Trigger.new){
                if(UserInfo.getUserType() == opptyConstants.PARTNER_USERTYPE && opp.In_Contract_MAC__c == opptyConstants.IN_CONTRACT_YES){
                    listOfOpportunityForChangeType.add(opp);
                }
                if( opp.RecordTypeId == entCustomRecordTypeId && (opp.StageName <> 'Closed Won' || opp.StageName <> 'Closed Lost') ){
                     BidnResMgmtReqList.add(opp);
                }
                if( opp.RetiedAccOpp__c && opp.StageName <> 'Closed Lost' && !opp.IsActiveAccount__c ){
                     RetiedAccOppList.add(opp);
                }
            }
            //Calling csordtelcoa__Change_Type__c field logic
            if(!listOfOpportunityForChangeType.isEmpty()){
                C2O_OpportunityTriggerHelper.updateChangeType(listOfOpportunityForChangeType);
            }
            
            if ( !BidnResMgmtReqList.isEmpty() ) {
                C2O_OpportunityTriggerHelper.updateBidnResMgmtReq(BidnResMgmtReqList);
            }
            
            if ( !RetiedAccOppList.isEmpty() ) {
                C2O_OpportunityTriggerHelper.UpdateRetiedAccOpp(RetiedAccOppList);
            }
        }
        
         /*** LIFT AND SHIFT STARTS ***/
        if(!EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger')){
         for(Opportunity opp : (List<Opportunity>)Trigger.new){
            
            //get the opp ids which are moved to Closed Won
            if(opp.stageName == 'Closed Won')
                closedWonOppIdSet.add(opp.id);
            //get the opp ids which are moved to Develop
            if(opp.stageName == 'Develop'&& opp.Pricing_Method__c == 'Delegated Pricing')//Modified by Rishabh Dhamu
                developOppIdSet.add(opp.id);
          } 
         
        
            //before Closing the opp Won, checking if atleast one basket is synced and enriched
            if(!closedWonOppIdSet.isEmpty())
            can.validateClosedWon(closedWonOppIdSet,this.newOppList);
        
            if(!developOppIdSet.isEmpty())
            can.validateDevelopOppty(developOppIdSet,this.newOppList);
            
            handler.OnBeforeInsert(this.newOppList);
        }
        /*** LIFT AND SHIFT ENDS ***/
    }

    /***************************************************************************************
    * Method Name - beforeUpdate
    * Description - This method is used to call the before Update operation on record.
    ****************************************************************************************/
    public override void beforeUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Opportunity','triggerBeforeUpdate')){
            // LOCAL VARIABLES
            partnerAcc = opptyUtils.getPartnerAccount(userinfo.getUserId());
            List<String> changesToMonitor = new List<String>{'Associated_Distributor__c','Partner_Account__c','PartnerAccountId','SubmittoPartnerStatus__c'};
            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);

            List<Opportunity> distributerOpptyList = new List<Opportunity>();
            List<Opportunity> nondistributerOpptyList = new List<Opportunity>();
            List<Opportunity> populateSLAlist = new List<Opportunity>();
            List<Opportunity> BidnResMgmtReqList = new List<Opportunity>();
            List<Opportunity> RetiedAccOppList = new List<Opportunity>();
            List<Opportunity> submitToDist = new List<Opportunity>();
            Map<String,String> opptyId_UserId = New Map<String,String> ();
            Map<String,String> opptyId_PartnerId = New Map<String,String> ();
            Map<String,String> opptyId_DistributorId = New Map<String,String> ();
            
            String currentUserId = userinfo.getUserId() ;
            Account distAccType = New Account () ;
            Account partnerAccType = New Account () ;

            for(Opportunity opp : (List<Opportunity>)Trigger.new){
            
                if ( opp.Associated_Distributor__c <> NULL ) {
                    distAccType = OpptyUtils.getAccountType(opp.Associated_Distributor__c) ;
                } 
                if ( opp.Partner_Account__c <> NULL ) {
                    partnerAccType = OpptyUtils.getAccountType(opp.Partner_Account__c) ;
                }
                /*
                System.debug(' opp.isInApprovalProcess__c ==> ' + opp.isInApprovalProcess__c );
                System.debug(' opp.SubmittoPartnerStatus__c ==> ' + opp.SubmittoPartnerStatus__c );
                System.Debug(' recordsWithChanges SubmittoPartnerStatus__c ==> ' + recordsWithChanges.get(opp.Id)?.contains('SubmittoPartnerStatus__c') );
                System.Debug(' recordsWithChanges Associated_Distributor__c  ==> ' + recordsWithChanges.get(opp.Id)?.contains('Associated_Distributor__c ') );
                System.Debug(' recordsWithChanges Partner_Account__c ==> ' + recordsWithChanges.get(opp.Id)?.contains('Partner_Account__c') );
                
                System.Debug('opp.Associated_Distributor__c ==> ' + opp.Associated_Distributor__c );
                System.Debug('distAccType  ==> ' + distAccType );
                System.Debug('opp.Distributor_Contact__c  ==> ' + opp.Distributor_Contact__c );
                
                System.Debug('opp.Partner_Account__c ==> ' + opp.Partner_Account__c );
                System.Debug('opp.Partner__c ==> ' + opp.Partner__c );
                System.Debug('partnerAccType  ==> ' + partnerAccType );
                
                System.Debug('currentUserId ==> ' + currentUserId );
                
                
                
                if ( opp.isInApprovalProcess__c == FALSE && opp.SubmittoPartnerStatus__c <> null && 
                     String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.SUBMITTED)  ) {
                

                    
                    // 2. Internal User to Distributor 
                    
                    if ( UserInfo.getUserType().equalsIgnoreCase(opptyConstants.POWERPARTNER) ) {
                        // CURRENT USER == PARTNER 
                        
                        // 1. Distributor User to Nominate partner 
                        if( opp.Associated_Distributor__c <> NULL && opp.Distributor_Contact__c <> NULL  && 
                            opp.Partner__c <> NULL && recordsWithChanges.get(opp.Id)?.contains('Partner_Account__c') &&
                            distAccType.Partner_Type__c == 'Distributor'  && currentUserId == opp.Distributor_Contact__c ) {
                       
                            System.Debug(' ENTERED 1. Distributor User to Nominate partner ==>');
                            opptyId_PartnerId.put(opp.id,opp.Distributor_Contact__c);
                           
                        }  
                        
                    
                    }  else {
                        // CURRENT USER == INTERNAL 
                    	
                        if( opp.Partner__c <> NULL && recordsWithChanges.get(opp.Id)?.contains('Partner_Account__c') &&
                            partnerAccType.Partner_Type__c == 'Partner'    ) {
                       
                            System.Debug(' ENTERED 2. INTERNAL User to Nominate partner ==>');
                            opptyId_PartnerId.put(opp.id,currentUserId);
                           
                        } else if( opp.Associated_Distributor__c <> NULL && opp.Distributor_Contact__c <> NULL  && 
                             	   recordsWithChanges.get(opp.Id)?.contains('Partner_Account__c') &&
                            	   distAccType.Partner_Type__c == 'Distributor'  ) {
                       
                            System.Debug(' ENTERED 3. INTERNAL User to Distributor partner ==>');
                            opptyId_PartnerId.put(opp.id,opp.Distributor_Contact__c);
                           
                        }  
                    
                    }
                    
                    
                    
                    
                    
                
                } // APPROVALS 
                
                
                /*** Submit to Distributor ***/
                
                
                
                
                
                /*** Submit to Partner 
                //1. Distributor User to Nominate PARTNER
                //2. Distributor User to Direct PARTNER
                //3. Internal User to Direct PARTNER
                //4. Internal user to Nominate PARTNER
                if(opp.Partner__c <> NULL   &&  opp.Partner_Account__c <> NULL && opp.SubmittoPartnerStatus__c <> null && 
                   String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.SUBMITTED)  && 
                    && recordsWithChanges.get(opp.Id)?.contains('SubmittoPartnerStatus__c') ) {
                       
                       System.Debug('submitToPartner ENTERED ==>');
                       opptyId_PartnerId.put(opp.id,userinfo.getUserId());
                } ***/
                
                
                dchOwnerAcc = opptyUtils.getPartnerAccount(opp.DCHOwner__c);
                
                if( opp.SubmittoPartnerStatus__c != null && opp.SubmittoPartnerStatus__c.equalsIgnoreCase(opptyConstants.APPROVED) &&
                    recordsWithChanges.get(opp.Id)?.contains('SubmittoPartnerStatus__c') &&  
                    UserInfo.getUserType().equalsIgnoreCase(opptyConstants.PARTNER_USERTYPE) && 
                    dchOwnerAcc <> NULL && dchOwnerAcc.Partner_Type__c <> NULL && dchOwnerAcc.Partner_Type__c <> opptyConstants.PARTNER  ){
                    
                    opp.OwnerId = UserInfo.getUserId();
                }
                
                
                if( UserInfo.getUserType().equalsIgnoreCase(opptyConstants.POWERPARTNER) && opp.isInApprovalProcess__c == FALSE &&
                    recordsWithChanges.get(opp.Id)?.contains('Associated_Distributor__c') &&
                    opp.SubmittoPartnerStatus__c <> null && opp.Distributor_Contact__c <> NULL && 
                    String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.SUBMITTED) ) {
                    
                    
                    if ( partnerAcc <> NULL && partnerAcc.Partner_Type__c <> NULL && partnerAcc.Partner_Type__c == opptyConstants.PARTNER ) {
                        
                        opptyId_DistributorId.put(opp.id,opp.ownerId);
                    }
                    
                } 

                if ( opptyConstants.SET_SUBMITSTATUS.contains(opp.SubmittoPartnerStatus__c) && opp.DCHOwner__c <> NULL &&
                    opp.DCHOwner__r.ContactId  <> NULL &&  opp.DCHOwner__r.Contact.AccountId <> NULL &&
                    opp?.DCHOwner__r?.Contact?.Account.Partner_Type__c == opptyConstants.DISTRIBUTOR) {
                        distributerOpptyList.add(opp);
                }

                if ( opptyConstants.SET_SUBMITSTATUS.contains(opp.SubmittoPartnerStatus__c) && ((opp.DCHOwner__c <> NULL &&
                       opp.DCHOwner__r.ContactId  <> NULL &&  opp.DCHOwner__r.Contact.AccountId <> NULL &&
                       opp?.DCHOwner__r?.Contact?.Account.Partner_Type__c == opptyConstants.DISTRIBUTOR) || 
                        (opp.DCHOwner__c <> NULL && opp.DCHOwner__r.ContactId == NULL) )  ) {
                       nondistributerOpptyList.add(opp);
                }
                
                if( opp.SubmittoPartnerStatus__c != null && opp.SubmittoPartnerStatus__c?.equalsIgnoreCase(opptyConstants.SUBMITTED) &&
                   opp.Associated_Distributor__c <> NULL && recordsWithChanges.get(opp.Id)?.contains('Associated_Distributor__c') &&
                   opp.PartnerAccountId <> NULL && recordsWithChanges.get(opp.Id)?.contains('PartnerAccountId')){
                       populateSLAlist.add(opp);
                   }
                
                if( opp.RecordTypeId == entCustomRecordTypeId && (opp.StageName <> 'Closed Won' || opp.StageName <> 'Closed Lost') ){
                     BidnResMgmtReqList.add(opp);
                }
                  
                if( opp.RetiedAccOpp__c && opp.StageName <> 'Closed Lost' && !opp.IsActiveAccount__c ){
                     RetiedAccOppList.add(opp);
                }
            }//FOR LOOP ENDS
            
            if(!opptyId_DistributorId.isEmpty()){
                C2O_OpportunityTriggerHelper.submitToDistributor(opptyId_DistributorId);
            }
            
            
            if(!opptyId_PartnerId.isEmpty()){
                C2O_OpportunityTriggerHelper.submitToPartner(opptyId_PartnerId);
            }    


            if ( !distributerOpptyList.isEmpty() ){
                C2O_OpportunityTriggerHelper.nullifyDistributerOppty(distributerOpptyList);
            }

            if ( !nondistributerOpptyList.isEmpty() ){
                C2O_OpportunityTriggerHelper.nullifyNonDistributerOppty(nondistributerOpptyList);
            }
            //Added by P.M
            if ( !populateSLAlist.isEmpty() ) {
                C2O_OpportunityTriggerHelper.updateSLAdateTo2days(populateSLAlist);
            }
            
            if ( !BidnResMgmtReqList.isEmpty() ) {
                C2O_OpportunityTriggerHelper.updateBidnResMgmtReq(BidnResMgmtReqList);
            }
            
            if ( !RetiedAccOppList.isEmpty() ) {
                C2O_OpportunityTriggerHelper.UpdateRetiedAccOpp(RetiedAccOppList);
            }
        }
        
        
         /*** LIFT AND SHIFT STARTS ***/
        if(!EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger')){
         for(Opportunity opp : (List<Opportunity>)Trigger.new){
            
            //get the opp ids which are moved to Closed Won
            if(opp.stageName == 'Closed Won')
                closedWonOppIdSet.add(opp.id);
            //get the opp ids which are moved to Develop
            if(opp.stageName == 'Develop'&& opp.Pricing_Method__c == 'Delegated Pricing')//Modified by Rishabh Dhamu
                developOppIdSet.add(opp.id);
          } 
         
        
            //before Closing the opp Won, checking if atleast one basket is synced and enriched
            if(!closedWonOppIdSet.isEmpty())
            can.validateClosedWon(closedWonOppIdSet,this.newOppList);
        
            if(!developOppIdSet.isEmpty())
            can.validateDevelopOppty(developOppIdSet,this.newOppList);
            
            handler.onBeforeUpdate(this.newOppList,this.newOppMap,this.oldOppList,this.oldOppMap); 
        }
        /*** LIFT AND SHIFT ENDS ***/
    }


    /***************************************************************************************
    * Method Name - afterInsert
    * Description - This method is used to call the after Insert operation on record.
    ****************************************************************************************/
    public override void afterInsert() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Opportunity','triggerAfterInsert')){
            // LOCAL VARIABLES
            PRM_Default__c prmDefault = PRM_Default__c.getInstance();
            List<String> createOTMlist = new List<String>();
            List<Opportunity> listOfOpportunityForContactRole = new List<Opportunity>();
            Set<Id> setOfOppIdForVerificationEmail = new Set<Id>();
            Set<Id> setOfOppWithPowerPartner = new Set<Id>();
            

            for(Opportunity opp : (List<Opportunity>)Trigger.new){  
                if( opp.Name <> NULL && opp.AccountId <> NULL){
                    createOTMlist.add(opp.Id); 
                } 
                if (UserInfo.getUserType() == opptyConstants.PARTNER_USERTYPE){
                    setOfOppWithPowerPartner.add(opp.Id);
                    if(String.isNotBlank(opp.Customer_Contact_Email__c) && String.isNotBlank(opp.Customer_Contact_Email__c)){
                        listOfOpportunityForContactRole.add(opp);
                    }
                    if(opp.Opportunity_Source__c == opptyConstants.PARTNER && opp.Amount >= prmDefault.Partner_Opportunity_Amount__c){
                        setOfOppIdForVerificationEmail.add(opp.Id);
                    }
                }
            }

            //CREATE THE OPPORUNITY TEAM MEMBER
            if ( !createOTMlist.isEmpty() ){
                OpptyUtils.addOpportunityTeamMember(createOTMlist);
            }
            //Calling createOpportunityContactRole logic
            if(!listOfOpportunityForContactRole.isEmpty()){
                C2O_OpportunityTriggerHelper.createOpportunityContactRole(listOfOpportunityForContactRole);
            }
            //Calling sentPartnerVerificationEmail logic
            if(!setOfOppIdForVerificationEmail.isEmpty()){
                C2O_OpportunityTriggerHelper.sentPartnerVerificationEmail(setOfOppIdForVerificationEmail);
            }

            if(!setOfOppWithPowerPartner.isEmpty()){
                PRMCreatedByPartnerUser.addPermissionSetToAO(setOfOppWithPowerPartner);
                PRMCreatedByPartnerUser.addOppTeamToPartnerOpp(setOfOppWithPowerPartner);
            }
        }
        
         /*** LIFT AND SHIFT STARTS ***/
        if(!EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger')){
         for(Opportunity opp : (List<Opportunity>)Trigger.new){
            
             //get the opp ids which are moved to Closed Lost and pricing method as 'delegated Pricing' 
            if(opp.stageName == 'Closed Lost' && opp.Pricing_Method__c == 'Delegated Pricing')          //Modified as part of EDGE-205345
                ClosedLostDealOppIdSet.add(opp.id);
                 
            //get the opp ids which are moved to Closed Won
            if(opp.stageName == 'Closed Won')
                closedWonOppIdSet.add(opp.id);
            
        }    
        
            if(!closedLostOppIdSet.isEmpty())
                can.cancelBasketStage(closedLostOppIdSet);
            
            if(!closedWonOppIdSet.isEmpty())
                can.submitBasketStage(closedWonOppIdSet);
             
             //Modified as part of EDGE-205345
             if(!ClosedLostDealOppIdSet.isEmpty())
                can.cancelDPRStage(ClosedLostDealOppIdSet); 
                
                handler.onAfterInsert(this.newOppList); 
            
        }
        /*** LIFT AND SHIFT ENDS ***/
    }

    /***************************************************************************************
    * Method Name - afterUpdate
    * Description - This method is used to call the after Update operation on record.
    ****************************************************************************************/
    public override void afterUpdate() {
        if(FeatureEligibilityChecker.determineFeatureEligiblity('Opportunity','triggerAfterUpdate')){
            // LOCAL VARIABLES
            List<String> changesToMonitor = new List<String>{'Associated_Distributor__c','PartnerAccountId','Partner__c','Submit_for_Closure_Status__c','Customer_Contact_Email__c', 'SubmittoPartnerStatus__c','OwnerId'};
            List<String> trackOldFields = new List<String>{'Customer_Contact_Email__c','Submit_for_Closure_Status__c', 'Partner__c'};

            Map<Id,Set<String>> recordsWithChanges = SYS_UtilityClass.getChangedFields(Trigger.oldMap,Trigger.newMap,changesToMonitor);
            Map<Id,Map<String, String>> oldFieldValuesMap = SYS_UtilityClass.getOldValuesMap(Trigger.oldMap,trackOldFields);

            C2O_OpportunityTriggerHelper.ChatterFeedInfo feedInfo;
            List<C2O_OpportunityTriggerHelper.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_OpportunityTriggerHelper.ChatterFeedInfo>();
            List<Opportunity> createdbyPartnerUserFromLeadsList = new List<Opportunity>();
            Map<Id,Id> mapOppIdVsPartnerIdForOtmRemoval = new Map<Id,Id>();
            Map<Id, Opportunity> prmTagPartnerOpptyMap = new Map<Id,Opportunity>();
            List<Opportunity> submitToDist = new List<Opportunity>();
            Set<Id> prmAutoTaggingIdSet = new Set<Id>();
            Map<String,String> opptyId_UserId = New Map<String,String> ();
            Map<String,String> approvalOpptyId_UserId = New Map<String,String> ();
            Map<String,String> opptyId_PartnerId = New Map<String,String> ();
            Map<String,String> opptyId_DistributorId = New Map<String,String> ();
            
            
            String currentUserId = userinfo.getUserId() ;
            Account distAccType = New Account () ;
            Account partnerAccType = New Account () ;

            for(Opportunity opp : this.newOppList){
            
                if ( opp.Associated_Distributor__c <> NULL ) {
                    distAccType = OpptyUtils.getAccountType(opp.Associated_Distributor__c) ;
                } 
                if ( opp.Partner_Account__c <> NULL ) {
                    partnerAccType = OpptyUtils.getAccountType(opp.Partner_Account__c) ;
                }

            
                
                
               if ( opp.isInApprovalProcess__c == FALSE && opp.SubmittoPartnerStatus__c <> null && 
                     String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.SUBMITTED)  ) {
                     
                        // CURRENT USER == PARTNER 
                        
                        // 1. Distributor User to Nominate partner 
                        if( opp.Associated_Distributor__c <> NULL && opp.Distributor_Contact__c <> NULL 
                            && !UserInfo.getUserType().equalsIgnoreCase(opptyConstants.POWERPARTNER) ) { 
                           //&&  distAccType.Partner_Type__c == 'Distributor'  && currentUserId == opp.Distributor_Contact__c ) {
                       
                            opptyId_DistributorId.put(opp.id,currentUserId);
                           
                        }  
                         
                } // APPROVALS 
                 
            
                if(recordsWithChanges.get(opp.Id)?.contains('OwnerId') && opp.Name <> NULL && opp.AccountId <> NULL){
                    opptyId_UserId.put(opp.Id,opp.OwnerId);
                }
                
                
                if( opp.Submit_for_Closure_Status__c <> NULL && recordsWithChanges.get(opp.Id)?.contains('Submit_for_Closure_Status__c')  ){   
                     
                    feedInfo = null;
                    //DIGI-24459, Sprint 21.15 SFO To prevent duplicate chatter to closure approver, chatter being sent via sendNotificationToPartnerOppCurrentAppr in Opprtunitytriggerhelper
                    if(opp.Submit_for_Closure_Status__c?.equalsIgnoreCase(opptyConstants.SUBMITTED) && opp.Current_Approver_ID__c == null){
                        feedInfo = new C2O_OpportunityTriggerHelper.ChatterFeedInfo(opp.Id,new set<Id>{opp.Closure_approver__c},OpptyConstants.PRM_Chatter_Request_to_Close_Opportunity);
                    }
                    if(opp.Submit_for_Closure_Status__c.equalsIgnoreCase(opptyConstants.APPROVED)){
                        feedInfo = new C2O_OpportunityTriggerHelper.ChatterFeedInfo(opp.Id,new set<Id>{opp.OwnerId},OpptyConstants.PRM_Chatter_Opportunity_Closure_Approved);
                    }
                    if(opp.Submit_for_Closure_Status__c.equalsIgnoreCase(opptyConstants.REJECTED)){
                        feedInfo = new C2O_OpportunityTriggerHelper.ChatterFeedInfo(opp.Id,new set<Id>{opp.OwnerId},OpptyConstants.PRM_Chatter_Opportunity_Closure_Rejected);
                    }
                    if(feedInfo!=null){
                        listOfchatterFeeds.add(feedInfo);
                    }
                }

                if(recordsWithChanges.get(opp.Id)?.contains('Customer_Contact_Email__c') && !String.isBlank(opp.Customer_Contact_Email__c) &&
                   String.isBlank(oldFieldValuesMap.get(opp.Id)?.get('Customer_Contact_Email__c')) && UserInfo.getUserType().equalsIgnoreCase(opptyConstants.POWERPARTNER)
                   && opp.LeadSource?.equalsIgnoreCase(opptyConstants.CAMPAIGN)){
                       createdbyPartnerUserFromLeadsList.add(opp);
                   }
                   

                if( !opp.isInApprovalProcess__c && String.isNotBlank(opp.PartnerAccountId) && recordsWithChanges.get(opp.Id).contains('PartnerAccountId')){
                       prmAutoTaggingIdSet.add(opp.Id);
                   }

               if(recordsWithChanges.get(opp.Id).contains('SubmittoPartnerStatus__c') &&
                  String.isNotBlank(oldFieldValuesMap.get(opp.Id)?.get('Partner__c')) &&
                  (String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.REJECTED) ||
                   String.valueOf(opp.SubmittoPartnerStatus__c).equalsIgnoreCase(opptyConstants.RECALLED))) {
                   
                   mapOppIdVsPartnerIdForOtmRemoval.put(opp.Id, oldFieldValuesMap.get(opp.Id)?.get('Partner__c'));
               }
               
            } 
            
            if(!opptyId_DistributorId.isEmpty()){
                C2O_OpportunityTriggerHelper.submitToDistributor(opptyId_DistributorId);
            }
            
            if(!opptyId_PartnerId.isEmpty()){
                C2O_OpportunityTriggerHelper.submitToPartner(opptyId_PartnerId);
            }   
            
            if (!opptyId_UserId.isEmpty() ) {
                OpptyUtils.addOpportunityTeamMember(opptyId_UserId);
            } 
            

            if (!createdbyPartnerUserFromLeadsList.isEmpty() ) {
                System.enqueueJob(new C2O_OpportunityTriggerHelper.CreateOpptyContactRole(createdbyPartnerUserFromLeadsList));
            }
            if (!listOfchatterFeeds.isEmpty() ) {
                System.enqueueJob(new C2O_OpportunityTriggerHelper.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
            }
            
            if(!approvalOpptyId_UserId.isEmpty()){
                C2O_OpportunityTriggerHelper.submitToDistributor(approvalOpptyId_UserId);
            }
            
            //Calling PRM Auto tagging logic
            if ( !prmAutoTaggingIdSet.isEmpty() ) {
                PRMAutoTagging.prmAutoTaggingPartner(prmAutoTaggingIdSet);
            }
            if(!mapOppIdVsPartnerIdForOtmRemoval.isEmpty()){
                C2O_OpportunityTriggerHelper.remPartUsrFrmOpptyTeam(mapOppIdVsPartnerIdForOtmRemoval);
            }
            system.debug('Beforethelogs---->+');
            if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
            system.debug('insertOpportunityTransactionLogs---->+');
            insertOpportunityTransactionLogs(oldOppMap, newOppList);
            }

        }
        
         /*** LIFT AND SHIFT STARTS ***/
        if(!EnvironmentalSettings.isTriggerDisabled('OpportunityTrigger')){
         for(Opportunity opp : (List<Opportunity>)Trigger.new){
            
            //get the opp ids which are moved to Closed Lost and pricing method as 'delegated Pricing' 
            if(opp.stageName == 'Closed Lost' && opp.Pricing_Method__c == 'Delegated Pricing')          //Modified as part of EDGE-205345
                ClosedLostDealOppIdSet.add(opp.id);
                 
            //get the opp ids which are moved to Closed Won
            if(opp.stageName == 'Closed Won')
                closedWonOppIdSet.add(opp.id);
            
         }//FOR LOOP ENDS 
            
            if(!closedLostOppIdSet.isEmpty())
                can.cancelBasketStage(closedLostOppIdSet);
            
            if(!closedWonOppIdSet.isEmpty())
                can.submitBasketStage(closedWonOppIdSet);
             
             //Modified as part of EDGE-205345
             if(!ClosedLostDealOppIdSet.isEmpty())
                can.cancelDPRStage(ClosedLostDealOppIdSet); 
                
            handler.OnAfterUpdate(this.oldOppList,this.oldOppMap,this.newOppList,this.newOppMap); 
            
        } //  EnvironmentalSettings.isTriggerDisabled
        /*** LIFT AND SHIFT ENDS ***/ 
    
    }
    //To insert transaction logs for opportunity on after update DIGI-28873
public static void insertOpportunityTransactionLogs(Map<Id,Opportunity> oldOppMap, List<Opportunity> newOppMap) {
            
    Set<String> parentOpportunityIdSet = new Set<String>();
    Map<String,Object> loggerdetailsMap=new Map<String,Object>();
    
    //fetch relevant opportunities
    for(Opportunity opps: newOppMap){
        if((oldOppMap.get(opps.id).StageName !='Closed Won') && (oldOppMap.get(opps.id).StageName !='Cancelled') && opps.StageName !=oldOppMap.get(opps.id).StageName && (opps.StageName =='Closed Won' || opps.StageName == 'Cancelled') ){
            parentOpportunityIdSet.add(Opps.Id);
        }
    }
    //get basket records
    for(cscfga__Product_Basket__c  basket: [Select Id, cscfga__Opportunity__c, cscfga__Opportunity__r.Type, cscfga__Opportunity__r.Name
    From cscfga__Product_Basket__c  
    Where cscfga__Opportunity__c In: parentOpportunityIdSet
    And csordtelcoa__Synchronised_with_Opportunity__c= true
    And Primary_Basket__c=true
    LIMIT 10000]){
        
        String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + basket.cscfga__Opportunity__c;
        String event = 'Order generation initiated';
        
        //create entries for loggerdetails map
       // String oppId = basket.cscfga__Opportunity__c != null && String.ValueOf(basket.cscfga__Opportunity__c).length()>=15 ?
        //String.ValueOf(basket.cscfga__Opportunity__c).subString(0,15) : '';
        String basketId = basket.Id != null && String.ValueOf(basket.Id).length()>= 15?
        String.ValueOf(basket.Id).subString(0,15) : '';
        string correlationId = basket.cscfga__Opportunity__c +'-'+ basketId;
        loggerdetailsMap.put('event',event);
        loggerdetailsMap.put('OrderType',basket.cscfga__Opportunity__r.Type);
        loggerdetailsMap.put('Name',basket.cscfga__Opportunity__r.Name);
        loggerdetailsMap.put('URL',URL);
        TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'C2O_OpportunityTriggerHandler');

    }
    
    //if(!loggerdetailsMap.isEmpty() && !loggerdetailsMap.keyset().isEmpty()) TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'OpportunityTriggerHandler');
    
}
}
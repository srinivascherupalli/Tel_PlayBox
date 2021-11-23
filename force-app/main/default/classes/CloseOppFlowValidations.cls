/*
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Ch.No.  Developer Name               Date             Story Description
1.      Aman Soni                    18/09/2020       EDGE-167800
2.      Srikanth                     20/07/2021       P2OB-14469,P2OB-15094
3.      Shubhi V					 17/09/2021		  DIGI-14084
4.      Purushottam                  06/09/2021       DIGI-16205
4.      Sri                  		 29/10/2021       DIGI-14959
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*/
public without sharing class CloseOppFlowValidations {
    public static string userProfileName; // SFO Sprint 20.14 P2OB-10150. Variable which holds User Profile Name. 
    public static map<string,Sobject> customMetadataNameValueMap=ConstantMetadataUtility.getConstantMetadataUtilityRecords('ConstantMetadataUtility__mdt');//EDGE-EDGE-196343-Dheeraj Bhatt- Get the constant value from metadata
    
    @InvocableMethod(label = 'Invoke Apex')
    public static list<flowOutputs> invokeThisFromFlowValidations(list<flowInputs> flwip){
        list<flowOutputs> lflowotps = new list<flowOutputs>();
        try{
            for(flowInputs str : flwip){
                if(str.getClosureApprover){
                    lflowotps.add(getClosureApprover(str));
                    return lflowotps;
                }
                if(str.closureReason == 'Won'){
                    lflowotps.add(invokeLocalMethodWon(str));
                }
                else{
                    flowOutputs flops = new flowOutputs();
                    flops.clousureReason_ApexOutput = str.closureReason;
                    lflowotps.add(flops);
                }
        /*      else if(str.closureReason == 'Lost'){
                    lflowotps.add(invokeLocalMethodLost(str));
                } */ //Commented as part of P2OB-6586
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: invokeThisFromFlowValidations Method'+ Ex.getMessage());
        }
        return lflowotps;
    }
    
    /********** Method For Lost Opportunities Validations*************/
    //Start Commented as part of P2OB-6586
    /*public static flowOutputs invokeLocalMethodLost(flowInputs req){
        flowOutputs flops = new flowOutputs();
        try{
            if(req.OppProductCount != req.OppProductCountLost){
                flops.finalErrorMsg_ApxOut = Label.CloseOppLostProductStatusErrorMsg;
                flops.isErrorLostProductStatus = True;
                flops.clousureReason_ApexOutput = req.closureReason;
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: invokeLocalMethodLost Method'+ Ex.getMessage());
        }
        return flops;
    }   
    */ //END Commented as part of P2OB-6586
    
    /************** Method Of Won Opportunities Validations ******************/
    public static flowOutputs invokeLocalMethodWon(flowInputs req){
        System.debug('req: flowinputs variable'+req);
        flowOutputs flops = new flowOutputs();
        integer errorCounter = 0;
        list<string> lstr = new list<string>();
        try{
            /************ Check for Propose stage  **********************/
            system.debug(req.oppStageName + req.OppRecordType);
            if((req.OppRecordType == 'Enterprise - Custom') && (req.oppStageName != 'Propose' && req.oppStageName != 'Negotiate')){
                flops.OppStageNameErrorCustomOpp_ApxOut = Label.CloseOppProposeNegoiateStageError;
                system.debug('Inside IF Condition'+req.oppStageName + req.OppRecordType);
                flops.isErrorStageNameCustomOpp = True;
                errorCounter++;
                lstr.add(flops.OppStageNameErrorCustomOpp_ApxOut);
            }
            if(req.OppRecordType != 'Enterprise - Custom' && req.oppStageName != 'Propose'){
                flops.OppStageNameError_ApxOut = Label.CloseOppProposeStageError;
                flops.isErrorStageName = True;
                errorCounter++;
                lstr.add(flops.OppStageNameError_ApxOut);
            }
            
            /************ Check For No.Of Won Products Non-Modular  ******************/
            if(req.oppProductType == 'Non Modular' && req.OppProductCountWon == 0){
                flops.OppProductWonCountError_ApxOut = Label.CloseOppProductstatusWonNonModular;
                flops.isErrorWonProductCount = True;
                errorCounter++;
                lstr.add(flops.OppProductWonCountError_ApxOut);
            }
            
            /********* Check if files uploaded, for Non - Modular Product ***************/
            if((req.oppAttachmentCountForNonModularWon == 0 || string.valueOf((req.oppAttachmentCountForNonModularWon)) == null || string.valueOf(req.oppAttachmentCountForNonModularWon) == '') && req.oppProductType == 'Non Modular'){
                flops.OppAttachmentError_ApxOut = Label.CloseOppDocAttachErrorNonModular;
                flops.isErrorAttachment = True;
                errorCounter++;
                lstr.add(flops.OppAttachmentError_ApxOut);
            }
            
			/*********Sprint 20.11 - SFO - P2OB-8378 Check if Revenue Impact Date is Greater than or equal to Close Date, for Non - Modular Product
             *        Sprint 21.10 - SFO - P2OB-14468 Removing the check for records close date as this is invoked from close opp and the close date during closure would be updated to todays date ***************/   
            //DIGI-4646 : Reopen Opportunities to consider close date           
			if(req.oppProductType == Label.Opp_ProductType_NonModular && (string.valueOf(req.oppRevenueImpactDate) == null || string.valueOf(req.oppRevenueImpactDate) == '' || req.oppRevenueImpactDate <= req.oppCloseDate)){
                flops.oppRevenueDateError_ApxOut = Label.CloseOppRevenueImpactDateError;
                flops.isErrorOppRevenueImpactDate = True;
                errorCounter++;
                lstr.add(flops.oppRevenueDateError_ApxOut);
            }
                        
			/********** Sprint 20.15 - SFO - P2OB-10150 Check Alliance For Purple Opportunities. Below Validation will be fired when Alliance is blank for Non-Modular Purple Opportuntiy ************/
			getUserProfileInfo(); //Gets user Profile Info
			if(req.oppProductType == Label.Opp_ProductType_NonModular && (string.valueOf(req.oppAlliance) == null || string.valueOf(req.oppAlliance) == '') && req.isPurpleOpp && (userProfileName != Label.PRM_CommunityAdmin_User && userProfileName != Label.PRM_Community_User_Australia && userProfileName != Label.PRM_Community_Basic_User)) {
                    flops.purpleOppError_ApxOut = Label.CloseOppPurpleOppErrorMsg;
				    flops.isErrorPurpleOppAllianceCheck = True;
				    errorCounter++;
				    lstr.add(flops.purpleOppError_ApxOut);
			        
			 }
			
            //Added by Aman Soni for EDGE-167800 || Start
            //Sprint 21.10 - SFO - P2OB-14468, updated the validation criteria to use system.today() instead of req.oppCloseDate 
            //if(req.oppProductType == Label.Opp_ProductType_Modular && ((req.oppRevenueImpactDate < req.oppCloseDate) || (string.valueOf(req.oppRevenueImpactDate) == null) || (string.valueOf(req.oppRevenueImpactDate) == ''))){
            //added = for DIGI-14084
            if(req.oppProductType == Label.Opp_ProductType_Modular && ((req.oppRevenueImpactDate < =System.today()) || (string.valueOf(req.oppRevenueImpactDate) == null) || (string.valueOf(req.oppRevenueImpactDate) == ''))){
                flops.oppRevenueDateError_ApxOut = Label.CloseOppRevenueImpactDateErrorModular;
                flops.isErrorOppRevenueImpactDate = True;
                errorCounter++;
                lstr.add(flops.oppRevenueDateError_ApxOut);
                system.debug('Hey M Inside Modular--'+lstr);
            } 
            //Added by Aman Soni for EDGE-167800 || End
            
            /********* Check if  Product Basket is synced and to check stage of the product basket For Modular Product Opportunities **************/
            //Modified by Rishabh - EDGE:123785 - to remove this validation for delegated Pricing, added - && req.PricingMethod != 'Delegated Pricing'
            if(req.oppProductType == 'Modular' && req.PricingMethod != 'Delegated Pricing'){
                //list<cscfga__Product_Basket__c> lProductBasket = new list<cscfga__Product_Basket__c>();
                //lProductBasket = [SELECT csbb__Synchronised_With_Opportunity__c,Basket_Number__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where cscfga__Opportunity__c = :req.oppId and csbb__Synchronised_With_Opportunity__c = True and csordtelcoa__Synchronised_with_Opportunity__c  = True];
                List<cscfga__Product_Basket__c> lProductBasket = new List<cscfga__Product_Basket__c> ([SELECT csbb__Synchronised_With_Opportunity__c,Basket_Number__c,csordtelcoa__Basket_Stage__c FROM cscfga__Product_Basket__c where cscfga__Opportunity__c = :req.oppId and csbb__Synchronised_With_Opportunity__c = True and csordtelcoa__Synchronised_with_Opportunity__c  = True]);
               
                if(!lProductBasket.isEmpty()){
                    for(cscfga__Product_Basket__c lpb : lProductBasket){
                        if(lpb.csordtelcoa__Basket_Stage__c != 'Enriched'){
                            flops.OppProductBasketStateError_ApxOut = Label.CloseoppModularProductBasketErrorMsg;
                            flops.isErrorProductBasketState = True;
                            errorCounter++;
                            lstr.add(flops.OppProductBasketStateError_ApxOut);
                        }
                    }
                }
                
                else{
                    flops.OppProductBasketStateError_ApxOut = Label.CloseoppModularProductBasketEmptyErrorMsg;
                    flops.isErrorProductBasketState = True;
                    errorCounter++;
                    lstr.add(flops.OppProductBasketStateError_ApxOut);
                }  
            }
            /**********EDGE:123785 - Primary synced Delegated Pricing Request is in the "Active" status ***************/
            if(req.oppProductType == 'Modular' && req.PricingMethod == 'Delegated Pricing'){
            /*    List<Delegated_Pricing_Request__c> delPriReqList = new List<Delegated_Pricing_Request__c>(); // commented as part of EDGE :204335
                delPriReqList = [SELECT Id, Name, Deal_Status__c FROM Delegated_Pricing_Request__c
                                 WHERE Opportunity__c =: req.oppId AND Synchronise_With_Opportunity__c = TRUE
                                 AND isPrimary__c = TRUE AND Deal_Status__c = 'Active'];
                if(delPriReqList.isEmpty()){
                    String errMsg = Label.NoActiveDelPriReq;
                    lstr.add(errMsg);
                }
			*/	
			/******EDGE :204335 -validate Active FA instead of Active DPR associated to Opportunity *************/
				    List<csconta__frame_agreement__c> ActiveFAList = new List<csconta__frame_agreement__c>();
                ActiveFAList = [SELECT Id, csconta__Status__c FROM csconta__frame_agreement__c WHERE Opportunity__c =: req.oppId AND Synchronise_With_Opportunity__c = TRUE
                                 AND is_Primary__c = TRUE AND csconta__Status__c = 'Active'];
                if(ActiveFAList.isEmpty()){
				    flops.NoactivefaError_ApxOut = Label.NoActiveDelPriReq;
					flops.isErroractivefa = True;
                    errorCounter++;
                    lstr.add(flops.NoactivefaError_ApxOut);
					}
            }
            
            /********** Check For Modular Product Opportunities If Contract Document is attached. ***************/
            if(req.oppProductType == 'Modular'  && req.PricingMethod != 'Delegated Pricing' && (req.OppContractAttachmentCountModular == 0 || string.valueOf(req.OppContractAttachmentCountModular) == null || string.valueOf(req.OppContractAttachmentCountModular) == '')){
                //Start of EDGE:97613 - If express order flag is checked then count of contract ttachment can be 0
                //Modified bu Rishabh Dhamu - 4/2/20 - changed "lProductBasket1" from object to list because of null pointer   
                List<cscfga__Product_Basket__c> lProductBasket1 = new List<cscfga__Product_Basket__c>();
                lProductBasket1 = [SELECT Express_Flow__c,Primary_Basket__c,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Basket_Stage__c,cscfga__Opportunity__r.Type FROM cscfga__Product_Basket__c WHERE cscfga__Opportunity__c = :req.oppId AND Primary_Basket__c = True AND csbb__Synchronised_With_Opportunity__c = True AND csordtelcoa__Synchronised_with_Opportunity__c  = True LIMIT 1];
                Opportunity opportunityRec = [SELECT isInsolvencyCancel__c,In_Contract_MAC__c FROM Opportunity WHERE id = :req.oppId LIMIT 1];
                //EDGE-196343-Dheeraj Bhatt-Added condition to bypass validtion for Migration order
                if(!lProductBasket1.isEmpty() && !opportunityRec.isInsolvencyCancel__c){  //DIGI-16205 isInsolvencyCancel__c check added by Purushottam
                    if(lProductBasket1[0].Express_Flow__c == False && lProductBasket1[0].Primary_Basket__c == True && opportunityRec.In_Contract_MAC__c == 'Yes' && customMetadataNameValueMap.containsKey('Migration') && lProductBasket1[0].cscfga__Opportunity__r.Type != customMetadataNameValueMap.get('Migration').get('Value__c')){
                        //End of Edge:97613
                        flops.OppContractAttach_ApexOut = Label.CloseOppContractDocModularError;
                        flops.isErrorOppContractAttachModular = True;
                        errorCounter++;
                        lstr.add(flops.OppContractAttach_ApexOut);
                    }
                }
            }
            
            /**********EDGE:123785 | Check For Modular Product Opportunities with Delegated Pricing Method, if Contract Document is attached. ***************/
			// Commenting as part of EDGE :204335
           /* if(req.oppProductType == 'Modular' && req.PricingMethod == 'Delegated Pricing'  &&  (req.OppContractAttachmentCountModular == 0 || string.valueOf(req.OppContractAttachmentCountModular) == null || string.valueOf(req.OppContractAttachmentCountModular) == '')){
            
                flops.OppContractAttach_ApexOut = Label.CloseOppContractDocModularError;
                flops.isErrorOppContractAttachModular = True;
                errorCounter++;
                lstr.add(flops.OppContractAttach_ApexOut);
            }
			*/
			
			//P2OB-14468 //DIGI-9239 Insolvency check
			list<OpportunityContactRole> lOppContRole = new list<OpportunityContactRole>();
			list<Opportunity> lstOpp = [Select Id,isInsolvencyCancel__c,(select Id from OpportunityContactRoles) from Opportunity where Id =: req.oppId];
            if(!lstOpp[0].isInsolvencyCancel__c){
				lOppContRole = lstOpp[0].OpportunityContactRoles;
				if(lOppContRole == null || lOppContRole.isEmpty()){
					flops.OppContactRoleError_ApxOut = Label.CloseOppCustomerContactError;
					flops.isErrorOppContactRole = True;
					errorCounter++;
					lstr.add(flops.OppContactRoleError_ApxOut);
				}
			}
        
            if(req.OppRecordType == 'Enterprise - Custom' && req.OppTaskStatus != 'Completed'&& req.OppTaskSubject == 'Deal Handover Meeting Scheduled and Conducted'){
                flops.OppCustomTaskError_ApxOut = Label.CloseOppCustomDealsErrorMsg;
                flops.isErrorCustomOppTaskStatus = True;
                errorCounter++;
                lstr.add(flops.OppCustomTaskError_ApxOut);
            }

            /*********START Sprint 21.10 - SFO - P2OB-14469 & P2OB-15094 ***************/ 
            if(req.ownerUserType != 'PowerPartner' && req.oppProductType == Label.Opp_ProductType_NonModular && isCBSValidation(req)){
                String errMsg = '* Unable to change the status to won. Custom Billing Solutions (CBS) must be engaged for opportunities with custom pricing. Click "Engage CBS"';
                errorCounter++;
                lstr.add(errMsg);
            }
            if(req.ownerUserType != 'PowerPartner' && req.oppProductType == Label.Opp_ProductType_NonModular && isSFDValidation(req)){
                String errMsg = '* Unable to close. Sales Facilitation & Design (SFD) must be engaged for opportunities with data & IP, UC, or security products.';
                errorCounter++;
                lstr.add(errMsg);
            }
            /*********END Sprint 21.10 - SFO - P2OB-14469 & P2OB-15094 ***************/                        


            if(errorCounter > 0){
                flops.ErrorMsgGeneric_ApxOut = Label.CloseOppGenericErrorMsg;
                string y = '';
                for(string x : lstr){
                    y = y + x + ', and' + '\n';
                }
                y = y.substring(0,y.length()-6);
                flops.finalErrorMsg_ApxOut = y;
                flops.clousureReason_ApexOutput = req.closureReason;
            }
        }catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: invokeLocalMethodWon Method'+ Ex.getMessage());
        }
        return flops;
    }
    
    /*********START Sprint 21.10 - SFO - P2OB-14469 ***************/ 
    public static  boolean isCBSValidation(flowInputs req){
        boolean result = false;
        boolean isCBSCaseExists = false;
        boolean isPRICINGCaseExists = false;
        try{
            for(Case oppCase: [select id,recordType.developername from case where (OpportunityId__c =:req.oppId) AND ((Recordtype.developername = 'Enterprise_Pricing' and Pricing_Request_Status__c IN ('Completed via PET','Completed via Customised PA')) OR (Recordtype.developername = 'CBS' and srvsup_Categories__c = 'Billing Solution Contract Implementation'))]){
                if(oppCase.recordType.developername == 'CBS' && oppCase.srvsup_Categories__c == 'Billing Solution Contract Implementation'){
                    isCBSCaseExists = true;
                }
                if(oppCase.recordType.developername == 'Enterprise_Pricing'){
                    isPRICINGCaseExists = true;
                }
            }
            // Pricing team have been engaged with Pricing Request Status as ‘Completed via PET' or 'Completed via Customised Pricing'
            // And CBS team have not been engaged(no CBS case) 
            if(!isCBSCaseExists && isPRICINGCaseExists){
                result = true; 
            }
        }
        catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: isCBSValidation Method'+ Ex.getMessage());
        }
        return result;
    }
    
    /*********START Sprint 21.10 - SFO - P2OB-15094 ***************/ 
    public static  boolean isSFDValidation(flowInputs req){
        boolean result = false;
        try{
            List<Case> sfdCases = [select id from case where (OpportunityId__c =:req.oppId) AND (Recordtype.developername = 'SFD_Request')]; 
            List<opportunitylineitem> sfdOppLineItems = [select id from opportunitylineitem where (OpportunityId =:req.oppId) AND (Domain__C IN ('Data & IP', 'MDM', 'Security', 'Unified Comms','UNIFIED COMMUNICATIONS'))];
            //Opportunity has product basket has a SFD supported product(Domain__C IN 'Data & IP', 'MDM', 'Security', 'Unified Comms','UNIFIED COMMUNICATIONS')
            //And no justification(sfd_Opt_Out_Reason__c) is provided
            //And SFD team have not been engaged(no SFD Case) 
            if(sfdCases.isEmpty() && String.isBlank(req.sfdOptOutReason) && !sfdOppLineItems.isEmpty() ){
                result = true; 
            }
        }
        catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: isCBSValidation Method'+ Ex.getMessage());
        }
        return result;
    }
/*
    @Method Name: getClosureApprover
    @Description: DIGI-6044, Sprint 21.12
				  To get ClosureApprover for the given opportunity
    @Author		: Sri (Team SFO)
    */
    public static flowOutputs getClosureApprover(flowInputs req){
        flowOutputs flowOutPut = new flowOutputs();
        Account act = [select id, name, Portfolio_Code__c, ownerId from Account where id =:req.actId limit 1];
        try{
            //get the AccountTeamMembers for the mentioned opportunity's account with the role Opportunity Approver
            for(AccountTeamMember actTeamMem : SFO_TeamMemberUtil.getAccountTeamMembers(new set<id>{req.actId}, Label.ClosureApproverAccountTeamMemRole)){
                flowOutPut.closureApprover = actTeamMem.userId;
            }
            
            //if there is no Opportunity Approver TeamMember need to look for the Operations Manager role Territory user for the account's portcode
            if(flowOutPut.closureApprover == null){
                //act = [select id, name, Portfolio_Code__c, ownerId from Account where id =:req.actId limit 1];
                
                for(UserTerritory2Association user : SFO_TerritoryUtil.getTerritoryUsersByRole(act?.Portfolio_Code__c, Label.ClosureApproverTerritoryUserRole, true)){
                    flowOutPut.closureApprover = user.userId;
                }
            }
            
            //if there is no Opportunity Approver TeamMember and Operations Manager role Territory user then need to set the opportunity's account owner
            if(flowOutPut.closureApprover == null){
                flowOutPut.closureApprover = act.ownerId;
            }
            system.debug(' get Closure Approver Queries ran '+ Limits.getQueries() +' out of '+ Limits.getLimitQueries());
            
            //for delegatedApprover get the General Manager role Territory user for the account's portcode
            if(flowOutPut.delegatedApprover == null ){
                for(UserTerritory2Association user : SFO_TerritoryUtil.getTerritoryUsersByRole(act?.Portfolio_Code__c, Label.DelegatedApproverTerritoryUserRole, true)){
                    flowOutPut.delegatedApprover = user.userId;
                }
            }
            if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')){
            insertOpportunityTransactionLogsPRM(req.oppId);
            }
            system.debug(' get Delegated Approver Queries ran '+ Limits.getQueries() +' out of '+ Limits.getLimitQueries());
        }
        catch(Exception Ex){
            system.debug('Exception:::: CloseOppFlowValidations :::: getClosureApprover Method'+ Ex.getMessage());
        }
        
        return flowOutPut;
    }
        
    /************** Wrapper Class to get flow inputs  ***************/
    public class flowInputs{

        
        @InvocableVariable
        public string oppStageName;
        @InvocableVariable
        public string oppId;
        @InvocableVariable
        public string closureReason;
        @InvocableVariable
        public string PricingMethod;
        /*************** Variables to Check Attachment Count **********/
        @InvocableVariable
        public integer oppAttachmentCountForNonModularWon;
        @InvocableVariable
        public string oppProductType;
        @InvocableVariable
        public integer OppProductCountWon;
        @InvocableVariable
        public integer OppContractAttachmentCountModular;
        @InvocableVariable
        public string OppRecordType;
        @InvocableVariable
        public string OppTaskStatus;
        @InvocableVariable
        public string OppTaskSubject;
        @InvocableVariable
        public string OppProductCount;
        @InvocableVariable
        public string OppProductCountLost;
        @InvocableVariable
        public date oppRevenueImpactDate; //Sprint 20.11 - SFO - P2OB-8378 Variable to hold Opportunities Revenue Impact date
        @InvocableVariable
        public date oppCloseDate; //Sprint 20.11 - SFO - P2OB-8378 Variable to hold Opportunities Close Date 
		@InvocableVariable
		public boolean isPurpleOpp; // Sprint 20.14 - SFO - P2OB-10150 Variable to hold Purple Opportunity Check
		@InvocableVariable
		public string oppAlliance; // Sprint 20.14 - SFO - P2OB-10150 Vairable to hold Opportunity Alliance Check
		@InvocableVariable
		public string sfdOptOutReason; // 21.10 - SFO - P2OB-15094 Vairable to hold sfd_Opt_Out_Reason__c value for this Opportunity
		@InvocableVariable
		public string ownerUserType; // 21.10 - SFO - P2OB-15094 Vairable to hold the opp owner(user) type
        @InvocableVariable
        public boolean getClosureApprover = false; //DIGI-6044 : Sprint 21.12- used to specify whether getClosureApprover method need to run or not
        @InvocableVariable
        public string actId; //DIGI-6044 : Sprint 21.12- to hold the accountId for the opportunity

    }
    /***************** Wrapper Class To Set Flow Variables ******************/
    public class flowOutputs{
        @InvocableVariable
        public string OppStageNameError_ApxOut;
        @InvocableVariable
        public string OppStageNameErrorCustomOpp_ApxOut;
        @InvocableVariable
        public string OppAttachmentError_ApxOut;
        @InvocableVariable
        public string OppProductWonCountError_ApxOut;
        @InvocableVariable
        public string OppContactRoleError_ApxOut;
        @InvocableVariable
        public string OppContractAttach_ApexOut;
        @InvocableVariable
        public boolean isErrorStageName;
        @InvocableVariable
        public boolean isErrorStageNameCustomOpp;
        @InvocableVariable
        public boolean isErrorAttachment;
        @InvocableVariable
        public boolean isErrorWonProductCount;
        @InvocableVariable
        public boolean isErrorOppContactRole;
        @InvocableVariable
        public boolean isErrorOppContractAttachModular;
        @InvocableVariable
        public string ErrorMsgGeneric_ApxOut;
        @InvocableVariable
        public string finalErrorMsg_ApxOut;
        @InvocableVariable
        public string OppCustomTaskError_ApxOut;
        @InvocableVariable
        public boolean isErrorCustomOppTaskStatus;
        @InvocableVariable
        public string OppProductBasketStateError_ApxOut;
        @InvocableVariable
        public boolean isErrorProductBasketState;
        @InvocableVariable
        public boolean isErrorLostProductStatus;
        @InvocableVariable
        public string clousureReason_ApexOutput;
        @InvocableVariable
        public boolean isErrorOppRevenueImpactDate; //Sprint 20.11 - SFO - P2OB-8378 Variable to hold Revenue Impaact date validation Error Check. 
        @InvocableVariable
        public string oppRevenueDateError_ApxOut;  //Sprint 20.11 - SFO - P2OB-8378 Variable to hold Revenue Impaact date validation Error Message. 
	    @InvocableVariable
	    public boolean isErrorPurpleOppAllianceCheck; //Sprint 20.14 - SFO - P2OB-10150 Variable to hold Purple Opp Alliance Check
	    @InvocableVariable
	    public string purpleOppError_ApxOut; //Sprint 20.14 - SFO - P2OB-10150 Variable to hold purple Opp Alliance Valiation Error Message. 
		@InvocableVariable
        public boolean isErroractivefa; //Sprint 21.04- Added as part of EDGE-204335
		@InvocableVariable
        public string NoactivefaError_ApxOut; //Sprint 21.04- Added as part of EDGE-204335
        @InvocableVariable
        public string closureApprover; //DIGI-6044 : Sprint 21.12- used to return the closureApprover userId
        @InvocableVariable
        public string delegatedApprover; //DIGI-14979 : Sprint 21.15- used to return the delegatedApprover(user in territory with Role as ‘General Manager) userId

	    
	}
	
/*******************************************************************
@Class Name     :   CloseOppFlowValidations
@Sprint         :   20.14 (P2OB-10150)
@Author         :   Amar (Team SFO)
@CreateDate     :   11/03/2020
@Description    :   Method Which Returns User Profile Info
@References     :   CloseOppFlowValidations
@TestCoverage   :   CloseOppFlowValidationsTest
*********************************************************************/
	public static string getUserProfileInfo(){
	 
	    Id profileId = userinfo.getProfileId();
	    userProfileName = [SELECT Id, Name FROM Profile where Id =:profileId].Name;
	    return userProfileName;
    }
    //To insert transaction logs for opportunity on after update
    public static void insertOpportunityTransactionLogsPRM(string OppId) {
            
        Set<String> parentOpportunityIdSet = new Set<String>();
        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
        
        //get basket records
        for(cscfga__Product_Basket__c  basket: [Select Id, cscfga__Opportunity__c, cscfga__Opportunity__r.Type, cscfga__Opportunity__r.Name,cscfga__Opportunity__r.StageName
        From cscfga__Product_Basket__c  
        Where cscfga__Opportunity__c =: OppId
        And csordtelcoa__Synchronised_with_Opportunity__c= true
        And Primary_Basket__c=true
        LIMIT 10000]){
            
           // String URL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + basket.cscfga__Opportunity__c;
            String event = 'Opportunity Closure Initiated';
            
            //create entries for loggerdetails map
           // String oppId = basket.cscfga__Opportunity__c != null && String.ValueOf(basket.cscfga__Opportunity__c).length()>=15 ?
            //String.ValueOf(basket.cscfga__Opportunity__c).subString(0,15) : '';
            String basketId = basket.Id != null && String.ValueOf(basket.Id).length()>= 15?
            String.ValueOf(basket.Id).subString(0,15) : '';
            string correlationId = basket.cscfga__Opportunity__c +'-'+ basketId;
            loggerdetailsMap.put('event',event);
            loggerdetailsMap.put('OpportunityName',basket.cscfga__Opportunity__r.Name);
            loggerdetailsMap.put('OpportunityType',basket.cscfga__Opportunity__r.Type);
            loggerdetailsMap.put('OpportunityStage',basket.cscfga__Opportunity__r.StageName);
            //loggerdetailsMap.put('URL',URL);
            TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'CloseOppFlowValidations');
    
        }
        
        //if(!loggerdetailsMap.isEmpty() && !loggerdetailsMap.keyset().isEmpty()) TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'OpportunityTriggerHandler');
        
    }
}
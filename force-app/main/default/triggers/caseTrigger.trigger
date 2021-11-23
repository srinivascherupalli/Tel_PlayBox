trigger caseTrigger on Case (before insert,after insert, after update, before update) {
    
    /*Jaipur :: Mofit Pathan
    Sprint & US: 21.09 & P2OB-10140
    Description: Custom setting to disable the trigger*/
    Environment_Configurations__c env =  Environment_Configurations__c.getInstance(UserInfo.getUserId());
    if(env.No_Triggers__c)
    {   
        System.debug('Trigger bypassed');
        return;
    }
    public static String recId_OrderRequest= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_request').getRecordTypeId();
    public static String recId_SupportRequest= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('soc_Support_Request').getRecordTypeId();
    public static String recId_SupportRequestWO= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('soc_Support_Request_without_SOC').getRecordTypeId();
    public static String recId_SFD_Product = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('soc_SFD_Product').getRecordTypeId();
    public static String recId_salesSupportChild=Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('salesup_Sales_Child_Support').getRecordTypeId();
    public static String recId_CustomDeal = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('cusdl_Custom_Deal').getRecordTypeId();
    public static String recId_Covid19 = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('COVID_19_Financial_Hardship').getRecordTypeId();
    public static String recId_CBS = Case.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
    
    public list <case> newCase = new  list<case>();
    public map<id, case> newMapCase = new map<id, case>();
    public map<id, case> oldMapCase = new map<id, case>();
    System.debug('Enter in case trigger:isAfter::'+trigger.isAfter+'isInsert'+trigger.isInsert+' isUpdate'+trigger.isUpdate);
    System.debug('trigger isBefore'+trigger.isBefore);
    
    for(case cs : trigger.new){
        system.debug('in record type'+cs);
        if(cs.RecordTypeid == recId_OrderRequest || cs.RecordTypeid== recId_SupportRequest || cs.RecordTypeid == recId_SupportRequestWO || cs.RecordTypeid == recId_SFD_Product 
          ){
              newCase.add(cs);
              newMapCase.put(cs.id, cs);
              if( trigger.isUpdate){
                  case caseOld = trigger.oldmap.get(cs.id);
                  oldMapCase.put(cs.id, caseOld);    
              }
              
          }
        
    }
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate) && prm_CaseTriggerHelper.flagCase){
        prm_CaseTriggerHelper.executeORBApproval(Trigger.New);
    }
    //EDGE-175758 added by team amsterdam
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        CaseTriggerHandler.truncateActualAmountApproved(Trigger.New);
    }
    
    if(trigger.isAfter && trigger.isInsert){
        // P2OB-14113 - adding case owner as requestor in case Team as Read access
        CaseTriggerHelper.addRequestorAsCaseTeamMember(Trigger.newMap);
        CaseTriggerHelper.runAssignmentRule(trigger.new);
        //DIGI-27314 Invoice record apex sharing
        JPRCaseTriggerHelper.addInvoiceApexShareRecord(trigger.new,null);
                
        FUL_CaseTriggerHandler.shareFulfillmentCasesToEnggUsers(Trigger.newMap);//EDGE-128917
        if(newCase.size() >0){
            //soc_CaseTriggerHandler.updateValidateOnCaseCreation(trigger.new);
            soc_CaseTriggerHandler.updateValidateOnCaseCreation(newCase);
            // soc_CaseTriggerHandler.initializeProductsOnCaseCreation(newCase);
        }
        
    }
    //EDGE-35565 Close child cases when Parent close is closed
    if(trigger.isUpdate && trigger.isAfter ){
        //EDGE-57886    ::  SLA For SFD Cases    
        System.debug('After Update');
        CaseTriggerHandler.updateChildCases(Trigger.newMap, Trigger.OldMAp);
        CaseTriggerHelper.notifyCaseOwnerOnCaseClose(Trigger.new, Trigger.OldMAp); //EDGE-198374  - call this method to notify case creator on case close

        //P2OB-14466 : 21.07 Team Hawaii
        CaseTriggerHandler.createOpenAirNotification(Trigger.newMap, Trigger.OldMAp);
        //DIGI-2050 : Updates Rules to ensure record sharing is done in a way onshore and offshore
        JPRCaseTriggerHelper.handleOffshoreCase(trigger.new,Trigger.OldMap);
        //DIGI-2050 : Update Work Order Sharing
        JPRCaseTriggerHelper.handleWorkOrder(trigger.new,Trigger.OldMap);
        //DIGI-27314 Invoice record apex sharing
        JPRCaseTriggerHelper.addInvoiceApexShareRecord(trigger.new,Trigger.OldMap);
    }
    if(newCase.size() >0){ 
        System.debug('newCase.size()::'+newCase.size());
        if(trigger.isAfter && trigger.isUpdate){
            soc_CaseTriggerHandler.resolveAccessesOnCaseUpdation(oldMapCase, newMapCase);
            soc_ParentChildCaseHandler.initiateChildCreation(Trigger.oldMap, Trigger.newMap);
            soc_ParentChildCaseHandler.changeParentOwnerOnChildCaseClose(Trigger.oldMap, Trigger.New);//kb
            System.debug('<<<<<<<<SOQL Count Start>>>>>>>>>>' + Limits.getQueries());
            soc_ParentChildCaseHandler.validateParentChildCloseCase(oldMapCase, newMapCase);
            System.debug('<<<<<<<<SOQL Count Start>>>>>>>>>>' + Limits.getQueries());
            //  soc_ParentChildCaseHandler.changeParentOwnerOnChildCaseChange(Trigger.oldMap, Trigger.New);
        }
        if(trigger.isBefore && trigger.isUpdate){
            System.debug('Before Update');
            soc_CaseTriggerHandler.cycleReportForSFDCase(Trigger.oldMap, Trigger.newMap); 
            soc_CaseTriggerHandler.sfdCaseAssignmentTimeReport(Trigger.oldMap, Trigger.newMap); //Kritika Bhati :: EDGE-68484 :: 8-MAR-2018
            soc_CaseTriggerHandler.updateTimestampforSOCCalculations(oldMapCase, newMapCase);
            soc_ParentChildCaseHandler.checkOwnerOfChildCase(Trigger.oldMap, Trigger.New);  //kb
            soc_ParentChildCaseHandler.updateMilestone(Trigger.oldMap, Trigger.newMap);
            System.debug('<<<<<<<<SOQL Count Start>>>>>>>>>>' + Limits.getQueries());
            soc_ParentChildCaseHandler.updateChildCaseStatus(Trigger.oldMap, Trigger.newMap);
        }
        
        if(trigger.isBefore && trigger.isInsert){
            soc_CaseTriggerHandler.initializeSFDCases(newCase); 
        }
    }
    
    //P2OB-9770 : Karan : Populate Head of Busiess(HOB) field on case with recordtype CBS & COVID_19_Financial_Hardship
    if(trigger.isBefore && trigger.isInsert){
        List<String> validCaseRecordType = new List<String>{recId_Covid19,recId_CBS};
            GroupMembership.filterCaseToPopulateHOB(Trigger.new,validCaseRecordType);       
            //Team Jaipur Harshita Verma :: DIGI-12392 Channel Care Tconnect
            JPRCaseTriggerHelper.handleTelstraConnectCases(Trigger.new);     
    }
    
    
    if(Trigger.isBefore && Trigger.isUpdate){
        
        //Shreyansh Sharma :: P2OB-3854 : Custom Deal Case
        //Shreyansh Sharma :: P2OB-11801 : removing Bid obj reference
        CustomDealCaseTriggerHandler.updateCustomDealCase(Trigger.new, Trigger.oldMap);
        
        //Preeti Malik :: EDGE-84328 : Service Support
        srvsup_ServiceCaseHandler.assignCaseToServiceEscalationsQueue(Trigger.oldMap, Trigger.newMap);
        FUL_CaseTriggerHandler.validateFulfilmentCaseClosure(Trigger.New, Trigger.newMap, Trigger.oldMap);//EDGE-128933
        
        //Melbourne Team : Chandrakant Wani :: P2OB-5217 : LP Process Approval vlaidation
        CaseTriggerHelper.checkBulkCaseTypeSelected(Trigger.new,Trigger.oldMap);
        
        //Melbourne Team : Sanjay Thakur : P2OB-8345 : LP Work Order Status Verification
        CaseTriggerHelper.checkWorkOrderStatus(Trigger.new,Trigger.oldMap);
        
        //Melbourne Team : Chandrakant Wani ::P2OB-10425:Update CaseMilestone completion date if case is closed
        CaseTriggerHelper.updateCaseSlaMilestone(Trigger.new);
        
        //Colombo team: Shubhi Edge-2216407
        Map<string,EnvironmentVariable__c> featureToggleMap=EnvironmentVariable__c.getAll();
        if(featureToggleMap!=null && featureToggleMap.containsKey('enableBillingEnquiry1663') && featureToggleMap.get('enableBillingEnquiry1663').value__c=='true'){
            CaseTriggerHelper.validateQLIProcessed(Trigger.new,Trigger.oldMap);
        }
    }
       
    
    // This invokes priority automation class
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        IR_CasePriorityFieldUtility.setPriority(Trigger.New);
        //Start : SFO Team : EDGE-63998 :Error on  Modular ETC Waiver Case for same opportunity 
        if(Trigger.isInsert){
            CaseTriggerHandler.existingCaseCheck(Trigger.New,Null);
            
            //Jaipur Team : P2OB-13762 Set Additional Skill set to new Case
            CaseTriggerHelper.setAdditionalSkillSetNewRecord(Trigger.new);
			
			//Jaipur Team : DIGI-9990 Set basektNumber,contract set to new Case
            JPRCaseTriggerHelper.handlePartnerCase(Trigger.new, Null);
        }
        else if(Trigger.isUpdate){
            CaseTriggerHandler.existingCaseCheck(Trigger.New,Trigger.OldMap);
            
            //Jaipur Team : P2OB-13762 Set Additional Skillset to existing Case
            CaseTriggerHelper.setAdditionalSkillSetExistingRecord(Trigger.new,Trigger.OldMap);
            CaseTriggerHelper.handleDefaultCaseSkill(Trigger.new,Trigger.OldMap);
            
            //SFO P2OB-6268 & P2OB-6275, based on the approval process need to assign the case owner
            if (!CaseTriggerHandler.isRecursive){
                CaseTriggerHandler.assignCaseOwner(Trigger.New,Trigger.OldMap); 
            } 
             //SFO P2OB-14319(BUG) To synch final revenue target with suggested revenue target
            CaseTriggerHandler.synchSuggestedRevenueTargetAndHisTrack(Trigger.New,Trigger.OldMap);
            //EDGE-218373 
            CaseTriggerHandler.validateRedemptionApprovalStatus(Trigger.New,Trigger.NewMap,Trigger.OldMap);
			
			//Jaipur Team : DIGI-9990 Set basektNumber,contract set to new Case
            JPRCaseTriggerHelper.handlePartnerCase(Trigger.new,Trigger.OldMap);
        }
        //END : SFO Team : EDGE-63998 :Error on  Modular ETC Waiver Case for same opportunity 
    }
}
//END OF Trigger..
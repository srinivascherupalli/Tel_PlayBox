/********************************************************************************************
@Class Name                 :   CaseTriggerHandler
@Description                :   EDGE -35565 AC8,Sprint-19.17,P2OB-4310
@Author                     :   Kalashree Borgaonkar,Team SFO(Sravanthi Velagapudi)
@Comments                   :   This class has functionality to close all child feedback cases ,
                                Throw error when theres an existing enterprise case open and new one is created 
                                for same opportunity.
@Modified                   :   Kamlesh(Istanbul) EDGE: 205667, Updating updateChildCases method to call the CustomerCommsOnCoBACompletion.sendCoBACaseClosureEmail 
                                Commenting this user story code as notification type parameter is not provided for EmailDTO.
								
								20-05-2021 : Tirth Shah : P2OB-14466 - Create Platform Events when Owner is changed.
                                03-06-2021 :Pallavi B (SFO)  : P2OB-14319(Bug) :: Sprint 21.07   
*********************************************************************************************/
public without sharing class CaseTriggerHandler {
    /*Sprint & US: 19.17 & P2OB-4310  
      Description: Used in getNewCaseListofEnterpriseCases for case list of Enterprise record types and related oppids .
                 Modularized for Cyclomatic Complexity.*/
    private static List<Id> oppIds = new List<Id>();
    private static List<Id> accIds = new List<Id>();
    private static Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Case.getRecordTypeInfosById();
    public static boolean existingCaseCheckRecursion=True;
    public static boolean getChildCasesRecursionCheck=true;
    private static map<ID,list<Case>> oppCaseETCMap = new map<ID,list<Case>>();
    private static map<ID,list<Case>> oppCaseEPMap = new map<ID,list<Case>>();
    private static map<ID,list<Case>> oppCaseConstractSupport = new map<ID,list<Case>>();

    private static map<ID,list<Case>> accCaseChannelCareMap = new map<ID,list<Case>>();
    private static map<ID,list<Case>> accNewCaseChannelCareMap = new map<ID,list<Case>>();
    private static map<ID,integer> accNewCaseCreated = new map<ID,integer>();
    private static Map<Id,Case> oldCaseMap= new Map<Id,Case>();

    public static void updateChildCases(Map<id,case> newCases,Map<id,case> oldCases){
        String recordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Feedback').RecordTypeId;
        //EDGE: 205667 Commenting as notification type parameter is not provided for EmailDTO.
        //String recordtypeChangeBillingid  = Schema.SObjectType.Case.RecordTypeInfosByDeveloperName.get('Change_of_Billing_Account').RecordTypeId;
        list<case> childcaseToUpdate = new list<case>();
        set<id> caseIds = new set<id>();
        //EDGE: 205667 Commenting as notification type parameter is not provided for EmailDTO.
        //set<id> caseClosedChangeOfBillingIds = new set<id>();
        for(id ids: newCases.keyset()){
            System.debug('newCases.get(ids).Recordtyename'+newCases.get(ids).Recordtypeid);
            if(newCases.get(ids).status != oldCases.get(ids).status && newCases.get(ids).status.equalsIgnoreCase('Closed') && newCases.get(ids).Recordtypeid== recordtypeid){
                caseIds.add(ids);
            }
            //EDGE: 205667 Commenting as notification type parameter is not provided for EmailDTO.
           /*else if(newCases.get(ids).Recordtypeid == recordtypeChangeBillingid && newCases.get(ids).status != oldCases.get(ids).status && newCases.get(ids).status.equalsIgnoreCase('Closed')) {
               caseClosedChangeOfBillingIds.add(ids);
            }*/
        }
        //EDGE: 205667 Commenting as notification type parameter is not provided for EmailDTO
        /*
        if(!caseClosedChangeOfBillingIds.isEmpty()) {
            CustomerCommsOnCoBACompletion.sendCoBACaseClosureEmail(caseClosedChangeOfBillingIds);
        }*/
        if(!caseIds.isEmpty()){
            childcaseToUpdate= getChildCases(caseIds);
        }
            if(!childcaseToUpdate.isEmpty()){
                update childcaseToUpdate;
            }  
    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: Returns all the child cases to the given case list .Modularized for Cyclomatic Complexity.
     */
    public static list<case> getChildCases(set<id> caseIds){
        list<case> childcaseToUpdate = new list<case>(); // To populate the List of child cases to close
        if(getChildCasesRecursionCheck){
            getChildCasesRecursionCheck=false;
            Map<id,case> mapParentToChild =new map<id,case>( [SELECT Id,status,Feedback_Closure_Details__c,Reason, (SELECT Id,status,Feedback_Closure_Details__c,Reason FROM Cases WHERE status!='Closed') FROM Case WHERE id IN :caseIds]);
            for(id ids : mapParentToChild.keyset()){
                if(!mapParentToChild.get(ids).cases.isEmpty()){
                list<case> childCases = mapParentToChild.get(ids).cases;
                    for(Case childCase : childCases){
                        childCase.status = mapParentToChild.get(ids).status;
                        childCase.Feedback_Closure_Details__c = mapParentToChild.get(ids).Feedback_Closure_Details__c;
                        childCase.Reason = mapParentToChild.get(ids).Reason; // Added As per story EDGE- 49413 Added Reason field in above Query
                        childcaseToUpdate.add(childCase);
                    }
                }
            }
        }
        return childcaseToUpdate;
            }
    /*
    Description : Methods checks for existing cases of refering to same opportunity for Modular RTC Waiver,Pricing Support and Contract Support Cases.
    Modified Comments : SFO Team (Sravanthi Velagapudi,Subani): 
                        EDGE-63998 :Error on  Modular ETC Waiver Case for same opportunity 
                        EDGE-69764 : Error on  Enterprise Pricing Case for same opportunity
                        P2OB-2833 Making Pricing Support Live
                        P2OB-4310 Modularized for Cyclomatic Complexity.
     */
    public static void existingCaseCheck(List<Case> newCases,Map<id,case> oldCases){  
        if(existingCaseCheckRecursion){
            existingCaseCheckRecursion=false;
        Boolean salesProfile = (FeatureManagement.checkPermission(System.label.Sales_and_Marketing_Custom_Permission) || FeatureManagement.checkPermission(System.label.Operations_Custom_Permission) || FeatureManagement.checkPermission(System.label.Sales_B2B_Permission) || FeatureManagement.checkPermission(System.label.Pricing_Support_Case_Custom_Permission));
            List<Case> newCaseETCEnterprice = getNewCaseListofEnterpriseCases(newCases,oldCases);
            
            if(!newCaseETCEnterprice.isEmpty() && (!oppIds.isEmpty() || !accIds.isEmpty())){
            // oppo id with list of Existing ETC cases
                existingCases(newCaseETCEnterprice,oppIds,new list<String> { System.label.Case_Status_Closed , System.label.Case_Status_Rejected},accIds,new List<String>{System.label.Case_Status_Closed ,System.label.Case_Status_Rejected,System.label.Case_Status_Withdrawn},new List<String>{System.label.Case_RecordType_ContractSupport ,System.label.Case_RecordType_PricingETCWaiver,System.label.Case_RecordType_EnterprisePricing});
            //19.17 & P2OB-4310 : To throw error for case create or edit in case of same opportunity is populated for both . Modularized for Cyclomatic Complexity.
            existingCaseCheckPricingETCWaiver(newCases,oldCases,oppCaseETCMap);
            if(salesProfile){

                     /*uncommenting below line, as functionslity should go live as per P2OB-2833
                     oppo id with list of Existing Contract Support cases && oppo id with list of Existing Enterprise Pricing cases*/
                    existingCaseCheckContractSupport(newCases,oldCases,oppCaseConstractSupport);
                    existingCaseCheckPricingSupport(newCases,oldCases,oppCaseEPMap);
                }
                //20.15 & P2OB-10544 throws error if any existing portfolio mangement case with same account
                if(oldCases == null){
                    existingCaseCheckChannelCare(newCases,oldCases,accCaseChannelCareMap);}
                

        }
    }
    }
    /*
    Sprint & US: 19.17 & P2OB-4310 && 20.15 P2OB-10544
    Description:    Returns all the cases of Modular RTC Waiver,Pricing Support and Contract Support.
                    Modularized for Cyclomatic Complexity.
                    added boolean var for Cyclomatic Complexity.
     */
    public static List<Case> getNewCaseListofEnterpriseCases(List<Case> newCases,Map<id,case> oldCases){
        List<Case> newCaseETCEnterprice = new List<Case>();
        if(newCases != null && !newCases.isEmpty()){
            //For-loop, start Getting all cases matching criterion of changed opportunity and enterprise record types cases
            for(Case cs : newCases){
                Boolean channelCareCheck =  rtMap.get(cs.RecordTypeId).getDeveloperName() ==System.label.Case_RecordType_salesup_Sales_Child_Support && cs.salesup_Work_Required__c == System.label.WorkRequired_PortfolioManagement && cs.AccountId != null;
                Boolean enterpriseCaseCheck =  rtMap.get(cs.RecordTypeId).getName() ==System.label.Case_RecordType_PricingETCWaiver || rtMap.get(cs.RecordTypeId).getName() ==System.label.Case_RecordType_EnterprisePricing || rtMap.get(cs.RecordTypeId).getName() ==System.label.Case_RecordType_ContractSupport;
                if(enterpriseCaseCheck){
                    if(oldCases == null && rtMap.get(cs.RecordTypeId).getName() != System.label.Case_RecordType_salesup_Sales_Child_Support){
                        newCaseETCEnterprice.add(cs);
                        oppIds.add(cs.OpportunityId__c);
                    }
                    else if(!oldCases.isEmpty() && oldCases.get(cs.id).OpportunityId__c != cs.OpportunityId__c  && rtMap.get(cs.RecordTypeId).getName() != System.label.Case_RecordType_salesup_Sales_Child_Support){
                    newCaseETCEnterprice.add(cs);
                    oppIds.add(cs.OpportunityId__c);
                }
                }
                //20.15 & P2OB-10544 all related accounts for portfolio managemnt cases
                else if(channelCareCheck){
                    accIds.add(cs.AccountId);
                    newCaseETCEnterprice.add(cs);
                    list<Case> channelCareCaseList = accNewCaseChannelCareMap.get(cs.AccountId);
                    if(null == channelCareCaseList){
                    channelCareCaseList = new list<case>();
                    accNewCaseChannelCareMap.put(cs.AccountId,channelCareCaseList);
                    }

                    channelCareCaseList.add(cs);
                }
            }//For-loop End
        }
        return newCaseETCEnterprice;
    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description:EDGE-63998 :Throws error if the refered opportunity has another Modular RTC Waiver case open.
                Modularized for Cyclomatic Complexity.
     */  
    public static void existingCaseCheckPricingETCWaiver(List<Case> newCases,Map<id,case> oldCases,map<ID,list<Case>> oppCaseETCMap){
        if(!oppCaseETCMap.isEmpty()){
            //Error message for PricingETCWaiver
            //for -START, Looping through cases(insert/update) to throw error when theres already an existing case of same record type
            for(Case cs : newCases) 
            {
                    if(oppCaseETCMap.get(cs.OpportunityId__c) != null && (oppCaseETCMap.get(cs.OpportunityId__c)).size() > 0 && rtMap.get(cs.RecordTypeId).getName()==System.label.Case_RecordType_PricingETCWaiver){
                        if(oldCases==null){
                                cs.addError(System.label.Case_Error_For_Existing_ETC_Case_WIth_Same_Opp);
                            }
                    else if(!oldCases.isEmpty() && oldCases.get(cs.id).OpportunityId__c != cs.OpportunityId__c  ){
                                    cs.addError(System.label.Case_Error_For_Existing_ETC_Case_WIth_Same_Opp);
                                }
                            }
            }//for -END
                        }
                    }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description:EDGE-69764 :Throws error if the refered opportunity has another Enterprise Pricing case open.
                            Modularized for Cyclomatic Complexity.
    Modified Comments:  Sprint19.08 EDGE-88444: Removed hard coded values for Custom permission 
                        P2OB-4303 Sprint 19.16 : Added common custom permission used for this record type. 
     */
    public static void existingCaseCheckPricingSupport(List<Case> newCases,Map<id,case> oldCases,map<ID,list<Case>> oppCaseEPMap){
        if(!oppCaseEPMap.isEmpty()){
                //Error message for Enterprise Pricing
            //for -START, Looping through cases(insert/update) to throw error when theres already an existing case of same record type
            for(Case cs : newCases){
                        if(oppCaseEPMap.get(cs.OpportunityId__c) != null && (oppCaseEPMap.get(cs.OpportunityId__c)).size() > 0 && rtMap.get(cs.RecordTypeId).getName() == System.label.Case_RecordType_EnterprisePricing){
                            if(oldCases==null){
                                    cs.addError(System.label.Case_Error_For_Existing_EP_Case_WIth_Same_Opp);
                                }
                    else if(!oldCases.isEmpty() && oldCases.get(cs.id).OpportunityId__c != cs.OpportunityId__c){
                                        cs.addError(System.label.Case_Error_For_Existing_EP_Case_WIth_Same_Opp);
                                    }
                        }
            }//for -END
        }
                }
    /*
    Sprint & US: 19.17 & P2OB-4310
    Description: 19.08 & EDGE-88444 :   Throws error if the refered opportunity has another Contract Support Case open.
                                        Modularized for Cyclomatic Complexity.
     */    
    public static void existingCaseCheckContractSupport(List<Case> newCases,Map<id,case> oldCases,map<ID,list<Case>> oppCaseConstractSupport){
        if(!oppCaseConstractSupport.isEmpty()){
                    //For-loop start, Looping through cases(insert/update) to throw error when theres already an existing case of same record type
                    for(Case cs : newCases){
                        if(oppCaseConstractSupport.get(cs.OpportunityId__c) != null && (oppCaseConstractSupport.get(cs.OpportunityId__c)).size() > 0 && rtMap.get(cs.RecordTypeId).getName() == System.label.Case_RecordType_ContractSupport){
                            if(oldCases==null){
                                    cs.addError(System.label.Case_Error_For_Existing_CS_Case_With_Same_Opp);
                                }
                    else if(!oldCases.isEmpty() && oldCases.get(cs.id).OpportunityId__c != cs.OpportunityId__c ){
                                        cs.addError(System.label.Case_Error_For_Existing_CS_Case_With_Same_Opp);
                                    }
                                }
            }//For-loop End
                            }
                        }

    /*
    Sprint & US: 20.15 & P2OB-10544
    Description:  Throws error if the refered Account has another Channel Care Case open.
     */   
    public static void existingCaseCheckChannelCare(List<Case> newCases,Map<id,case> oldCases,map<ID,list<Case>> accCaseChannelCareMap){
        if(!accCaseChannelCareMap.isEmpty() || !accNewCaseChannelCareMap.isEmpty()){
            //For-loop start, Looping through cases(insert/update) to throw error when theres already an existing case of same record type
            for(Case cs : newCases){
                Boolean isChannelCareDuplicate =(((accCaseChannelCareMap.get(cs.AccountId) != null && accCaseChannelCareMap.get(cs.AccountId).size() > 0 )||
                                                    (accNewCaseChannelCareMap.get(cs.AccountId) != null && accNewCaseChannelCareMap.get(cs.AccountId).size() > 1 && accNewCaseCreated.get(cs.AccountId) != null)) &&
                                                 rtMap.get(cs.RecordTypeId).getDeveloperName() == System.label.Case_RecordType_salesup_Sales_Child_Support && 
                                                cs.salesup_Work_Required__c == System.label.WorkRequired_PortfolioManagement);
                if(isChannelCareDuplicate){
                    cs.addError(System.label.Case_Error_For_Existing_ChannelCare_Case_With_Same_Acc);
                }
                else if(!accNewCaseCreated.containsKey(cs.AccountId)&& rtMap.get(cs.RecordTypeId).getDeveloperName() == System.label.Case_RecordType_salesup_Sales_Child_Support && 
                                                cs.salesup_Work_Required__c == System.label.WorkRequired_PortfolioManagement){
                    accNewCaseCreated.put(cs.AccountId,1);
                    
                }
            }
        }
    }


    /*SFO Team (Sravanthi Velagapudi): 
      Modified Comments :   EDGE-63998 :Error on  Modular ETC Waiver Case for same opportunity 
                            EDGE-69764 : Error on  Enterprise Pricing Case for same opportunity 
                    20.15 & P2OB-10544 all existing cases with same account
                    P2OB-10544 : keeping record type check to exclude Channel care cases when fetching via opportunity*/
    public static void existingCases(list<Case> newList, List<Id> oppIds, List<String> exludedStatus ,List<Id> accIds,List<String> potfolioCaseStatusExcluded,List<String> oppRecordTypes){        
        if(newList!=null && newList.size()>0){
            if((oppIds!=null && oppIds.size()>0) && (exludedStatus!=null && exludedStatus.size()>0)){
            //For-loop start, Mapping list of open cases against same opportunity
            for(Case cs : [Select id,Status,OpportunityId__c,RecordTypeId,RecordType.DeveloperName,RecordType.name from Case where ID NOT IN: newList AND OpportunityId__c IN :oppIds
                           AND Status NOT IN : exludedStatus AND RecordType.name IN : oppRecordTypes]){
                              existingCasesByRecordType(cs);
                           }//For-loop end
        }

        //20.15 & P2OB-10544 all existing Portfolio Managment cases with same account 
            if(!accIds.isEmpty()){
                //For-loop start, Mapping list of open cases against same opportunity
                for(Case cs : [Select id,Status,AccountId,RecordTypeId,RecordType.DeveloperName,RecordType.Name from Case where ID NOT IN: newList AND AccountId IN :accIds
                AND Status NOT IN : potfolioCaseStatusExcluded AND salesup_Work_Required__c = : System.label.WorkRequired_PortfolioManagement AND RecordType.DeveloperName = : System.label.Case_RecordType_salesup_Sales_Child_Support]){
                   existingCasesByRecordType(cs);
                }//For-loop end
            }
        }
        

    }
    // This method called in existingCases method,to devide casses by record type with opportunity ID , 
    // in this method oppCaseETCMap,oppCaseEPMap,oppCaseConstractSupport static maps variables will update.
    private static void existingCasesByRecordType(Case cs){
        if(cs.RecordType.Name==System.label.Case_RecordType_PricingETCWaiver){
            list<Case> pricingETCWaiverCaseList = oppCaseETCMap.get(cs.OpportunityId__c);
            if(null == pricingETCWaiverCaseList){
                pricingETCWaiverCaseList = new list<Case>();
                oppCaseETCMap.put(cs.OpportunityId__c,pricingETCWaiverCaseList);
            }
            pricingETCWaiverCaseList.add(cs);
        }
        else if(cs.RecordType.Name==System.label.Case_RecordType_EnterprisePricing){
            list<Case> enterprisePricingCaseList = oppCaseEPMap.get(cs.OpportunityId__c);
            if(null == enterprisePricingCaseList){
                enterprisePricingCaseList = new list<Case>();
                oppCaseEPMap.put(cs.OpportunityId__c,enterprisePricingCaseList);
            }
            enterprisePricingCaseList.add(cs);
        }
        else if(cs.RecordType.Name==System.label.Case_RecordType_ContractSupport){
            list<Case> contractSupportCaseList = oppCaseConstractSupport.get(cs.OpportunityId__c);
            if(null == contractSupportCaseList){
                contractSupportCaseList = new list<Case>();
                oppCaseConstractSupport.put(cs.OpportunityId__c,contractSupportCaseList);
            }
            contractSupportCaseList.add(cs);
        }
    //20.15 & P2OB-10544 all existing cases with same account
        else if(cs.RecordType.DeveloperName==System.label.Case_RecordType_salesup_Sales_Child_Support){
            list<Case> channelCareCaseList = accCaseChannelCareMap.get(cs.AccountId);
            if(null == channelCareCaseList){
                channelCareCaseList = new list<case>();
                accCaseChannelCareMap.put(cs.AccountId,channelCareCaseList);
            }

            channelCareCaseList.add(cs);
        }
    }
 /**
 EDGE - 89741
 EDGE-119565- Removed 'EDGE - 89741' components and placed in 'Send Email to Agent' PB and with recpective class
 1. Retain the placeholder for existing story with a description that - C&A record would be created on earlier status (Initiate Adjustment) since the new story replaces the trigger with case PB and a renamed status : Obtaining Internal Approval.
 2. Above the existing story, add the story number that replaces the trigger feature with PB.
 ***/
//Functionality Moved to Seperate class FUL_CaseTriggerHandler
/*EDGE-128933
    public static void validateFulfilmentCaseClosure(List<Case> newCasesLst, Map<id,case> newCases,Map<id,case> oldCases){
        system.debug('inside validateFulfilmentCaseClosure::'+newCasesLst);
        set<id> caseIds = new set<id>();
        List<id> caseIdLst;
        String recordtypeid  = Schema.SObjectType.Case.RecordTypeInfosByName.get('Fulfillment').RecordTypeId;       
        for(id ids :newCases.keySet()){
            if(newCases.get(ids).status != oldCases.get(ids).status && newCases.get(ids).status.equalsIgnoreCase('Closed') && newCases.get(ids).Recordtypeid == recordtypeid){
                caseIds.add(ids);
            }
        }
        if(!caseIds.isEmpty()){
            caseIdLst = new List<id> (caseIds);
            List<FulfillmentLineItem__c> fulItemLst = [SELECT Id, case__c FROM FulfillmentLineItem__c WHERE Status__c != 'Completed' AND case__c IN :caseIdLst];
            if(!fulItemLst.isEmpty()){
                caseIds = new set<id>();
                for(FulfillmentLineItem__c fli :fulItemLst){
                    caseIds.add(fli.case__c);
                }
                for(Case caseRec:newCasesLst){
                    if(caseIds.contains(caseRec.Id)){
                        caseRec.addError('Ensure you close each fulfilment task to close the Case automatically.');
                    }
                }
            }
        }
    }    */
    public static boolean isRecursive = false;
    //Channel Care recordtype's Id on Case object
    public static Id recIdChannelCare = Schema.SObjectType.Case.getRecordTypeInfosByName().get(System.label.Case_RecordType_ChannelCare).getRecordTypeId();
    /*******************************************************************
@Method Name    :   assignCaseOwner
@Sprint         :   20.09  & P2OB-6268 & P2OB-6275
@Author         :   SFO Team (Sri)
@CreateDate     :   07/07/2020
@Description    :   To assign the case owner based on the approval process 
@References     :   caseTrigger in before update
@TestCoverage   :   CaseTriggerHandlerTest
@Updated        :   SFO Team (Sri) P2OB-10606 :: 10/11/2020, this method need to be called in same transaction 
                    to throw an error while incoming approving manager trying to approve after updating the final revenue target
*********************************************************************/
    public static void assignCaseOwner(List<Case> newCases,Map<id,case> oldCases){
        //isRecursive = true;
        for(Case cs : newCases){
            if(cs.RecordTypeid == recIdChannelCare && cs.salesup_Work_Required__c == Label.WorkRequired_PortfolioManagement){
                
                //To check whether 'Final Revenue Target' modifed or not
                if(cs.Final_Revenue_Target_Updated__c && cs.status == Label.Case_Status_Approved){
                    cs.addError(Label.PortfolioApprovalProcessErrMsg);
                }else if(cs.status == Label.Case_Status_Negotiate && cs.Final_Revenue_Target_Updated__c ){
                    cs.Final_Revenue_Target_Updated__c = False;
                }
                /*Assign case owner based on the apporval process updated 'current approver' value
                if(cs.Current_Approvar__c == 'Loosing GM' && cs.Losing_Approver__c <> null && cs.status <> 'Approved'){
                    cs.OwnerId = cs.Losing_Approver__c;
                }
                else if(cs.Current_Approvar__c == 'Gaining GM' && cs.Gaining_Approver__c <> null && cs.status <> 'Approved'){
                    cs.OwnerId = cs.Gaining_Approver__c;
                }
                else if(cs.status == 'Approved' && cs.Ownership_Code__c <> null){
                    system.debug('Case Ownership was not null so case added to CDM Queue');
                    list<Group> cdmQueue =new list<Group>([Select DeveloperName , Id , Name from Group where  Type = 'Queue' AND DeveloperName =: Label.Portman_CDM_Queue_DeveloperName]);
                    if(cdmQueue.size() == 1){
                        // Assigning Case to Portman CDM queue if Ownership Code is updated
                        cs.OwnerId = cdmQueue[0].id;
                    } 
                }
                else if(cs.status == 'Approved' && cs.Ownership_Code__c == null){
                    system.debug('Case Ownership was null so case added to Finance Queue');
                    list<Group> financeQueue =new list<Group>([Select DeveloperName , Id , Name from Group where  Type = 'Queue' AND DeveloperName =: Label.Portman_Finance_Queue_DeveloperName]);
                    if(financeQueue.size() == 1){
                        // Assigning Case to Portman Finance queue if Ownership Code is NULL
                        cs.OwnerId = financeQueue[0].id;
                    } 
                } */
            }
        }


    }
    //EDGE-175758 added by team amsterdam
    public static Void truncateActualAmountApproved(List<Case> newCases){
        for(Case cs:newCases){
            if(cs.Salesup_Actual_Amount_Approved__c!=NULL){
                Decimal acualAmtApproved=cs.Salesup_Actual_Amount_Approved__c;
                cs.Salesup_Actual_Amount_Approved__c=acualAmtApproved.setscale(2,system.RoundingMode.DOWN);
            }
            if(cs.Customer_requested_Transfer_Amount__c!=null){
                Decimal CRTAmt=cs.Customer_requested_Transfer_Amount__c;
                cs.Customer_requested_Transfer_Amount__c=CRTAmt.setscale(2,system.RoundingMode.DOWN);
            }
        }
    }
    
    /**    
    * Description : Method to Create OpenAirNotification Platform Event for MuleSoft. Whenever the Case Owner is changed. 
    * Jira : P2OB-14466 (Sprint 21.07)
    */
    public static void createOpenAirNotification(Map<id,Case> newMap, Map<id,Case> oldMap){
        try{
            Id StandardSolution = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Presales_Solution').getRecordTypeId();
            List<OpenAir_Notification__e> oanList = new List<OpenAir_Notification__e>();
            for(Id CaseId : newMap.keySet()){
                String NewOwner = newMap.get(CaseId).OwnerId.getSObjectType().getDescribe().getName();
                String OldOwner = oldMap.get(CaseId).OwnerId.getSObjectType().getDescribe().getName();
                
                if(newMap.get(CaseId).Technology_Specialisation__c != null && newMap.get(CaseId).Technology_Specialisation__c != '' && newMap.get(CaseId).RecordTypeId == StandardSolution && ( newMap.get(CaseId).OwnerId != oldMap.get(CaseId).OwnerId ) 	){
                    if( ( OldOwner == 'Group' && NewOwner == 'User' ) || ( OldOwner == 'User' && NewOwner == 'User' ) ){
                        oanList.add(PRMOpenAirNotificationUtil.GenrateOpenAirNotificationData(CaseId, newMap.get(CaseId).OpportunityId__c));
                    }
                }
            }
            
            if(oanList.size() > 0 ) PRMOpenAirNotificationUtil.publishEvents(oanList);
            
        }catch(Exception e){
            System.debug('***Telstra:CaseTriggerHandler:createOpenAirNotification:exception:'+e.getMessage());
            System.debug('***Telstra:CaseTriggerHandler:createOpenAirNotification:exception: At Line number: ' + e.getLineNumber());
        }
    }

/*******************************************************************
@Method Name    :   synchSuggestedRevenueTargetAndHisTrack
@Sprint         :   21.07  & P2OB-14319
@Author         :   SFO Team (Pallavi B)
@CreateDate     :   03/06/2021
@Description    :   To update final revenue target,suggested revenue target ht(field : for history tracking) with suggested revenue target
@References     :   caseTrigger in before update
@TestCoverage   :   CaseTriggerHandlerTest
*********************************************************************/
   public static void synchSuggestedRevenueTargetAndHisTrack(List<Case> newCases,Map<id,case> oldCases){
        oldCaseMap = oldCases;
        for(Case ObjCase : newCases){
            boolean approverChange = (isChanged('Gaining_Approver__c', ObjCase) || isChanged('Losing_Approver__c', ObjCase));

            if(ObjCase.RecordTypeid == recIdChannelCare && ObjCase.salesup_Work_Required__c == Label.WorkRequired_PortfolioManagement && approverChange && ObjCase.status <> Label.Case_Status_Approved ){
                ObjCase.New_Revenue_Target__c = ObjCase.Current_Revenue_Targets__c;
                    ObjCase.Suggested_revenue_target_ht__c = ObjCase.Current_Revenue_Targets__c;            }
        }
    }

/*******************************************************************
@Method Name    :   validateRedemptionApprovalStatus
@Sprint         :   21.09 (EDGE-218373)
@Author         :   Amsterdam Team (Parmanand)
@CreateDate     :   25/06/2021
@Description    :   To validate case status initiate redumption, the credit ad adjustment status should not pending
@References     :   caseTrigger in before update
@TestCoverage   :   CaseTriggerHandlerTest
*********************************************************************/
public static void validateRedemptionApprovalStatus(List<Case> newCases,Map<id,case> newCaseMap,Map<id,case> oldCases){
    Set<id> caseId = new set<id>();
    oldCaseMap = oldCases;
    Id billingOnefundRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Billing TEP Fund Retrospective Redemption').getRecordTypeId();
    for(Case ObjCase : newCases){
        if(isChanged('Status',ObjCase) && ObjCase.status == 'Closed' && ObjCase.RecordTypeId == billingOnefundRecordTypeId ){
            caseId.add(ObjCase.id);
        }
    }
    if(caseId.size()>0){
        List<Credits_and_Adjustments__c> credAndAdjList = [select ID, case_Number__c, Redemption_Status__c from Credits_and_Adjustments__c where case_Number__c In : caseId and RecordType.DeveloperName = 'Retrospective_Redemption_CA'];
        if(credAndAdjList !=null && credAndAdjList.size()>0){
            for(Credits_and_Adjustments__c credAndAdj : credAndAdjList){
                if(credAndAdj.Redemption_Status__c == 'Pending'){
                    case c = newCaseMap.get(credAndAdj.case_Number__c);
                    c.addError('You cannot close Case as it is currently awaiting Sales Manager approval');
                }
            }
        }
    }
}
 
/*******************************************************************
@Method Name    :   isChanged
@Sprint         :   21.07  & P2OB-14319
@Author         :   SFO Team (Pallavi B)
@CreateDate     :   03/06/2021
@Description    :   General Method to check for change of fields
@References     :   can be used wherever required to check for ischanged functionality
@TestCoverage   :   CaseTriggerHandlerTest
*********************************************************************/
    
    
     public static boolean isChanged(String fieldApiName, Case objCase){
        return objCase?.get(fieldApiName) != oldCaseMap.get(objCase.Id)?.get(fieldApiName);
    }
}
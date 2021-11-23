/*************************************************************************************************
Name : BsktStageUpdateForClosedOppsTrigHandler
Description : called from trigger OpportunityTrigger
Used to :
1. validate basket is synced and enriched before Close Won Opp
2. set the basket status to cancelled once the opportunity is set to 
Closed Lost
3. set synced basket status to submitted once the opportunity is set to
Closed Won
4. set the DPR status to cancelled once the opportunity is set to 
Closed Lost
5. validate DPR is primary and Scored before Develop Opp
6. shubhi for inflight EDGE-202203
7.  set the DPR and FA status to cancelled as part of EDGE-204335 
8. Update DPR and FA status to cancelled when opportunity is closed lost as part of EDGE-205345

***************************************************************************************************/
public with sharing class BsktStageUpdateForClosedOppsTrigHandler{

    public static boolean isFirstRun = false;
    
    //checks if the basket is synced and enriched before Close Won Opp, else throws error
    public void validateClosedWon(Set<Id> closedWonOppIdSet, List<Opportunity> oppList )
    {
    List<cscfga__Product_Basket__c> basketList = getPBList(closedWonOppIdSet);
    Set<Id> errorOppIdSet = new Set<Id>();
    Set<Id> correctOppIdSet = new Set<Id>();
    Map<Id,cscfga__Product_Basket__c> oppIdToSyncedBasket = new Map<Id,cscfga__Product_Basket__c>(); //EDGE-117966 (Parallel MACD)
        if(basketList != null && basketList.size()>0 && !isFirstRun)
        {
            isFirstRun = true;
            for(cscfga__Product_Basket__c basket:basketList)
            {  
                System.debug('basket.csbb__Synchronised_with_Opportunity__c'+basket.csbb__Synchronised_with_Opportunity__c);
                System.debug('basket.csordtelcoa__Basket_Stage__c'+ basket.csordtelcoa__Basket_Stage__c);
                System.debug('basket.cscfga__Opportunity__r.Product_Type__c'+basket.cscfga__Opportunity__r.Product_Type__c);
                // if the basket is synced and is in Enriched stage add it to the correct set 
                if(basket.csbb__Synchronised_with_Opportunity__c &&(((basket.csordtelcoa__Basket_Stage__c == 'Enriched' || basket.csordtelcoa__Basket_Stage__c == 'Submitted' )&& basket.cscfga__Opportunity__r.Product_Type__c=='Modular')|| basket.cscfga__Opportunity__r.Product_Type__c=='Non Modular'))
                { 
                    correctOppIdSet.add(basket.cscfga__Opportunity__c);
                    if (String.isNotBlank(basket.csordtelcoa__Change_Type__c)) {
                        //EDGE-117966 (Parallel MACD): adding only correct baskets to the map for later MACD basket validation
                        oppIdToSyncedBasket.put(basket.cscfga__Opportunity__c, basket);
                    }
                }
                //else add it to error set 
                else
                {       
                    System.debug('basket error'+basket.Id);
                    errorOppIdSet.add(basket.cscfga__Opportunity__c);
                }  
            }
            System.debug('errorOppIdSet  <><>'+errorOppIdSet.size());
             for(Opportunity opp: oppList)
            {
                 //if the opportunity is present in errorOppIdSet and not in correctOppIdSet, throw the error. 
                 if((errorOppIdSet!=null && errorOppIdSet.contains(opp.Id))&& (correctOppIdSet ==null || (correctOppIdSet!=null && !correctOppIdSet.contains(opp.Id))))
                 {
                     System.debug('In the errored<><>');
                     if(opp.Product_Type__c == 'Modular')
                     {
                         opp.addError(System.Label.Label_CloseWinOppError);
                     }
                     if(opp.Product_Type__c == 'Non Modular')
                     {
                         opp.addError(System.Label.Label_CloseWinOppErrorNM);
                     }
                 } else if (oppIdToSyncedBasket.containsKey(opp.Id)) {
                    //EDGE-117966 (Parallel MACD): only if there would be no errors we perform MACD basket validation to minimize impact as managed API is not bulkified!
                    String validationError = cssmgnt.API_1.validateBasket((String)oppIdToSyncedBasket.get(opp.Id).id);
                    if (String.isNotEmpty(validationError)) {
                        opp.addError(validationError);
                    }
                 }
                system.debug('opp listttt<><>'+opp);
            }
        }
    }
    
    //checks if the DPR is Scored and primary before Develop Opp, else throws error
    public void validateDevelopOppty(Set<Id> developOpptySet, List<Opportunity> oppList )
    {
    system.debug('develop opp list'+developOpptySet);
    List<delegated_Pricing_Request__c> dprList = getDPRList(developOpptySet);
    Set<Id> errorOppIdSet = new Set<Id>();
    Set<Id> correctOppIdSet = new Set<Id>();
    
    system.debug('basket issue'+dprList);
        if(dprList != null && dprList.size()>0 && !isFirstRun)
        {
            isFirstRun = true;
            for(delegated_Pricing_Request__c dpr:dprList)
            {  
                System.debug('dpr.isPrimary__c'+dpr.isPrimary__c);
                System.debug('dpr.deal_status__c'+ dpr.deal_status__c);
                System.debug('dpr.Opportunity__r.Product_Type__c'+dpr.Opportunity__r.Product_Type__c);
                // if the dpr is synced and is in Enriched stage add it to the correct set 
                if(dpr.isPrimary__c &&((((dpr.deal_status__c == 'Scored') || (dpr.deal_status__c == 'Sent for Approval') || (dpr.deal_status__c == 'Approved')|| (dpr.deal_status__c == 'Contract Initiated')|| (dpr.deal_status__c == 'Contract Generated')|| (dpr.deal_status__c == 'Active'))&& dpr.Opportunity__r.Product_Type__c=='Modular')))
                { 
                    correctOppIdSet.add(dpr.Opportunity__c);
                }
                //else add it to error set 
                else
                {       
                    System.debug('dpr error'+dpr.Id);
                    errorOppIdSet.add(dpr.Opportunity__c);
                }  
            }
            System.debug('errorOppIdSet  <><>'+errorOppIdSet.size());
    
           for(Opportunity opp: oppList)
            {
                 //if the opportunity is present in errorOppIdSet and not in correctOppIdSet, throw the error. 
                 if((errorOppIdSet!=null && errorOppIdSet.contains(opp.Id))&& (correctOppIdSet ==null || (correctOppIdSet!=null && !correctOppIdSet.contains(opp.Id))))
                 {
                     System.debug('In the errored<><>');
                     if(opp.Product_Type__c == 'Modular')
                     {
                         System.debug('i am here <><>');
                         opp.addError(System.Label.Label_developOppError);
                     }
                 }
                system.debug('opp listttt<><>'+opp);
            }
             
             
        }
    }
    
    
    
    //cancels the basket stage when the opportunity is closed lost  
    //P2OB-11727 added the condition for Non Modular product to update basket stage to cancelled when Opportunity is closed lost  
    public void cancelBasketStage(Set<Id> closedLostOppIdSet) {
        List<cscfga__Product_Basket__c> basketList = getPBList(closedLostOppIdSet);
        
        if(basketList != null) {
            if (basketList.size() > 0) {
                for(cscfga__Product_Basket__c basket : basketList) {
                    if (basket.cscfga__Opportunity__r.Product_Type__c == 'Modular' || basket.cscfga__Opportunity__r.Product_Type__c == 'Non Modular') {
                        basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
                    }
                }
            }   
            update basketList;
        }  
    }
    
    
    //cancels the DPR stage when the opportunity is closed lost(Modified as part of EDGE-205345)    
    public void cancelDPRStage(Set<Id> ClosedLostDealOppIdSet) {
        
      List<delegated_Pricing_Request__c> dprList = getDPRList(ClosedLostDealOppIdSet);
        List<csconta__frame_agreement__c> FAList =   getFAList(ClosedLostDealOppIdSet);
        
        
        if(FAList != null) {
            
        if (ClosedLostDealOppIdSet.size() > 0){
            System.debug(LoggingLevel.DEBUG, 'ClosedLostDealOppIdSet product setting to ClosedLost');
            list<Opportunity> lstOpp = [
                SELECT id, pricebook2id, Pricing_Method__c, (SELECT id FROM OpportunityLineItems)
                FROM Opportunity
                WHERE id IN :ClosedLostDealOppIdSet
            ];
            if (lstOpp.size()>0){
                list<OpportunityLineItem> lstOLI = new List<OpportunityLineItem>();
               
                System.debug(LoggingLevel.DEBUG, 'ClosedLost.lstOpp = ' + lstOpp.size());
                for(Opportunity opp: lstOpp){
                    System.debug(LoggingLevel.DEBUG, 'ClosedLost.inside lstOpp looppps');
                    if(opp.OpportunityLineItems.size() > 0 && opp.Pricing_Method__c == 'Delegated Pricing'){
                        for(OpportunityLineItem oli : opp.OpportunityLineItems){
                            oli.Product_Status__c = 'Lost';
                            lstOLI.add(oli);
                        }
                    }
                }
                if(lstOLI.size() > 0)
                    update lstOLI;
            }
        }
            
      if (FAList.size() > 0) {
                for(csconta__frame_agreement__c FA : FAList) {
                    if (FA.Opportunity__r.Product_Type__c == 'Modular' && FA.Opportunity__r.Pricing_Method__c == 'Delegated Pricing') {
                        FA.csconta__Status__c = 'Cancelled';
                    }
                }
            update FAList;
        }
            
            
            
        if (dprList.size() > 0) {
                for(delegated_Pricing_Request__c dpr : dprList) {
                    if (dpr.Opportunity__r.Product_Type__c == 'Modular' && dpr.Opportunity__r.Pricing_Method__c == 'Delegated Pricing') {
                        dpr.deal_status__c = 'Cancelled';
                    }
                }
            update dprList;
        }   
            
        }  
    }
    
    
    
    //when opportunity is closed won, checks the basket with sync flag. updates it to submitted stage and rest all baskets to cancelled  
    //P2OB-11727 added the condition for Non Modular product to update basket stage to Submitted when Opportunity is closed won  
    public void submitBasketStage(Set<Id> closedWonOppIdSet) {
        List<cscfga__Product_Basket__c> basketList = getPBList(closedWonOppIdSet);
    
        if(basketList != null) {
            if (basketList.size() > 0) {
                for(cscfga__Product_Basket__c basket:basketList) {
                        if ((basket.csordtelcoa__Basket_Stage__c != 'Cancelled' && basket.csordtelcoa__Basket_Stage__c != 'Submitted') && (basket.cscfga__Opportunity__r.Product_Type__c == 'Modular' || basket.cscfga__Opportunity__r.Product_Type__c == 'Non Modular' ) && basket.recordType.name!='Inflight Change' ){ //EDGE-202203
                        if(!basket.csbb__Synchronised_with_Opportunity__c && !basket.csordtelcoa__Synchronised_with_Opportunity__c) {
                            basket.csordtelcoa__Basket_Stage__c = 'Cancelled';
                        }
                        else {
                            basket.csordtelcoa__Basket_Stage__c = 'Submitted';
                        }          
                    }
                }
            }
            update basketList;
        } 
    }
    
    // When opportunity is closed won, update the status of Frame Agreement and delegated pricing request to cancelled except for active and contract rejected
        // MOdifying as part of EDGE-204335   
        
        public void updateFAAndDealStatus(List<Opportunity> lstOfOpp) {
            set<Id> setOfWonOppIds=new set<Id>();
            List<csconta__frame_agreement__c> FrameList = new List<csconta__frame_agreement__c>();
            List<delegated_Pricing_Request__c> DPRList = new List<delegated_Pricing_Request__c>();
            
            for(Opportunity opp:lstOfOpp){
                if(opp.stageName == 'Closed Won'&& opp.Pricing_Method__c == 'Delegated Pricing' && opp.Product_Type__c == 'Modular'){
                    setOfWonOppIds.add(opp.Id);
                }  
            }
            if(!setOfWonOppIds.isEmpty()){
                List<Opportunity> oppList = getOpportunityRelatedRecords(setOfWonOppIds);
                for(Opportunity opp : oppList){
                    if(opp.Frame_Agreements__r != null && opp.Frame_Agreements__r.size() > 0) {
                        for(csconta__frame_agreement__c frameAgg:opp.Frame_Agreements__r) {
                           if ((frameAgg.csconta__Status__c != 'Cancelled' && frameAgg.csconta__Status__c != 'Active' && frameAgg.csconta__Status__c != 'Contract Rejected') && (!frameAgg.Is_Primary__c)){
                                frameAgg.csconta__Status__c = 'Cancelled';
                            }
                            FrameList.add(frameAgg);
                         }
                    }
                    if(opp.Delegated_Pricing_Requests__r != null && opp.Delegated_Pricing_Requests__r.size()>0 ) {
                        for(delegated_Pricing_Request__c DelPR:opp.Delegated_Pricing_Requests__r) {
                            if ((DelPR.deal_status__c != 'Cancelled' && DelPR.deal_status__c != 'Active' && DelPR.deal_status__c != 'Contract Rejected') && (!DelPR.isPrimary__c)){
                                DelPR.deal_status__c = 'Cancelled';
                            }
                            DPRList.add(DelPR);
                        }
                    }
                }
                DprTriggerhelper.BlockDprTrigger = true;
                If(FrameList.size()>0){
                    update FrameList;
                }
                If(DPRList.size()>0){
                    update DPRList;
                }
            }
        }
    
    //method which queries the basket object based on the Opportunity Id Set received
    public List<cscfga__Product_Basket__c> getPBList(Set<Id> oppIdSet) {
            List<cscfga__Product_Basket__c> basketList = [SELECT id,csordtelcoa__Basket_Stage__c,csordtelcoa__Synchronised_with_Opportunity__c,csbb__Synchronised_with_Opportunity__c,cscfga__Opportunity__c,cscfga__Opportunity__r.Product_Type__c, csordtelcoa__Change_Type__c,recordType.name
                                                      FROM cscfga__Product_Basket__c
                                                      WHERE cscfga__Opportunity__c IN:oppIdSet];
    
    return basketList;
    }
    //method which queries the FA object based on the Opportunity Id Set received
    public List<csconta__frame_agreement__c> getFAList(Set<Id> oppIdSet)
    {
    List<csconta__frame_agreement__c> FAList = [Select id, csconta__Status__c, isPrimary__c, Opportunity__c, Opportunity__r.Product_Type__c, Opportunity__r.Pricing_Method__c from csconta__frame_agreement__c where Opportunity__c in:oppIdSet];
    
    return FAList;
    }
    
    
    
    //method which queries the DPR object based on the Opportunity Id Set received
    public List<delegated_Pricing_Request__c> getDPRList(Set<Id> oppIdSet)
    {
    List<delegated_Pricing_Request__c> dprList = [Select id, deal_Status__c, isPrimary__c, Opportunity__c, Opportunity__r.Product_Type__c, Opportunity__r.Pricing_Method__c from delegated_Pricing_Request__c where Opportunity__c in:oppIdSet];
    
    return dprList;
    }
    
    //method which queries FA and DPR based on the Opportunity Id Set received
        public List<Opportunity> getOpportunityRelatedRecords(Set<Id> oppIdSet){
            List<Opportunity> oppList = [select id,Name,Product_Type__c,Pricing_Method__c,
                                         (Select id, deal_Status__c, isPrimary__c from Delegated_Pricing_Requests__r),
                                         (Select id, csconta__Status__c, Is_Primary__c from Frame_Agreements__r) 
                                         from opportunity where Id IN:oppIdSet];
            
            return oppList;
        }
    
    
    }
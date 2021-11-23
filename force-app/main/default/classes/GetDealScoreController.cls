/********************************************************************
* Ankush Rana    19/07/2021       DIGI-720     Logic change to stop deriving User.Delegation_role__c based on Profile.Name = ‘Pricing Admin’, instead populate DelegationRole__c = Customized Pricing for every ‘Pricing Admin’ user
*********************************************************************************************************************************************/

public class GetDealScoreController {

    @AuraEnabled
    public static List<wrapperLineItem> fetchOfferLineItem(Id FrameId){
        Map<Id,wrapperLineItem> lineItemWrapMap = new  Map<Id,wrapperLineItem>();
        
        wrapperLineItem lineItemWrapObj;
        
        csconta__Frame_Agreement__c frameRec = retrieveFrameRecord(FrameId);
        List<DPR_Offer_Line_Item__c> offerLineList = retrieveLineItem(frameRec);
        
        for(DPR_Offer_Line_Item__c offerLineRec :offerLineList){
            System.debug('offerLineRec<><>'+offerLineRec);
            lineItemWrapObj = new wrapperLineItem();
            if(offerLineRec.DPR_Offer_Line_Item_Type__c == 'Plan' && offerLineRec.Parent_DPR_Offer_Line_Item_Id__c ==null){
                if(lineItemWrapMap.containsKey(offerLineRec.Id)){
                    lineItemWrapObj = lineItemWrapMap.get(offerLineRec.Id);
                }
                lineItemWrapObj.recordId = offerLineRec.Id ;
                lineItemWrapObj.planType = offerLineRec.cspmb_Price_Item__r.Type__c;
                lineItemWrapObj.plan = offerLineRec.Name;
                lineItemWrapObj.listPrice = offerLineRec.List_Price__c;
                lineItemWrapObj.activationSIO = offerLineRec.Quantity__c;
                lineItemWrapObj.recontractSIO = offerLineRec.Recontracting_Quantity__c; 
                lineItemWrapObj.Delegated_Pricing_Request = offerLineRec.Delegated_Pricing_Request__c;
                lineItemWrapObj.Overridden_Unit_price = offerLineRec.Overridden_Unit_price__c;
        lineItemWrapObj.finalDelegatedOutcome = offerLineRec.Delegated_Pricing_Request__r.Final_Delegation_Outcome__c;
                lineItemWrapObj.Deal_Status = offerLineRec.Delegated_Pricing_Request__r.Deal_Status__c;
                 lineItemWrapObj.productFamily = offerLineRec.Product_Family__c;
                //system.debug('@@@lineItemWrapObj.Deal_Status'+lineItemWrapObj.Deal_Status);
                
            }
            else if (offerLineRec.Parent_DPR_Offer_Line_Item_Id__c != null){
                if(lineItemWrapMap.containsKey(offerLineRec.Parent_DPR_Offer_Line_Item_Id__c)){
                    lineItemWrapObj = lineItemWrapMap.get(offerLineRec.Parent_DPR_Offer_Line_Item_Id__c);
                }
                lineItemWrapObj.recordId = offerLineRec.Parent_DPR_Offer_Line_Item_Id__c ;
                lineItemWrapObj.discountRecordId = offerLineRec.Id;
                lineItemWrapObj.mmc = offerLineRec.DPR_Offer_Line_Item_Value__c;
            }
            if(lineItemWrapObj.recordId != '' && lineItemWrapObj.recordId != null){
                lineItemWrapMap.put(lineItemWrapObj.recordId,lineItemWrapObj);
            }
            //EDGE-21112..start
            List<WrapperRateCardLineItem> lstwrapperRCLItem=new List<WrapperRateCardLineItem>();
            if(offerLineRec.DPR_Rate_Card__r.size()>0){
                for(DPR_Rate_Card__c rc:offerLineRec.DPR_Rate_Card__r){
                    if(rc.Parent_DPR_Rate_Card_ID__c !=null){
                        WrapperRateCardLineItem wrappRCLI=new WrapperRateCardLineItem();
                        wrappRCLI.RCLrecordId=rc.Id;
                        wrappRCLI.Plan=rc.Parent_DPR_OLI_id__r.Name;
                        wrappRCLI.ParentRatecardName=rc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c;
                        wrappRCLI.RateCardLineName=rc.DPR_Rate_Card_Name__c;
                        wrappRCLI.RateValue=rc.DPR_RC_Rate_Value__c;
                        wrappRCLI.NegotiatedValue=rc.DPR_RC_Negotiated_Value__c;
                        wrappRCLI.NegotiatedDiscount=rc.Negotiated_Discount__c;
                        lstwrapperRCLItem.add(wrappRCLI);
                    }
                }
            }
            if(!lstwrapperRCLItem.isEmpty()){
                lineItemWrapObj.wrapperRateCardLineItem=lstwrapperRCLItem;
            }
          //EDGE-21112..end
        }
        return lineItemWrapMap.values();
    } 
    
    @AuraEnabled
    public static csconta__Frame_Agreement__c retrieveFrameRecord(Id FrameId){
        csconta__Frame_Agreement__c  frameObj = [Select Id, Name, CorrelationId__c, Delegated_Pricing_Request__c,
                                                 csconta__Status__c From csconta__Frame_Agreement__c WHERE Id =:FrameId]; 
        return frameObj;
    }
    
    @AuraEnabled
    public static List<DPR_Offer_Line_Item__c> retrieveLineItem(csconta__Frame_Agreement__c frameObj){
        List<DPR_Offer_Line_Item__c> offerLineList = new List <DPR_Offer_Line_Item__c>([Select Id,Name,
                                                                                        (Select ID, DPR_Rate_Card_Name__c, Parent_DPR_OLI_id__r.Name,
                                                                                         Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c, 
                                                                                         Parent_DPR_Rate_Card_ID__r.Name, DPR_RC_Rate_Value__c,
                                                                                         DPR_RC_Negotiated_Value__c , Negotiated_Discount__c 
                                                FROM DPR_Rate_Card__r 
                                                                                         where Parent_DPR_Rate_Card_ID__c <> null),
                                                                                        Delegated_Pricing_Request__c,
                                                                                        Offer_Type_Name__c,
                                                                                        cspmb_Price_Item__c,
                                                                                        cspmb_Price_Item__r.Type__c,
                                                                                        DPR_Offer_Line_Item_Type__c,
                                                                                        Quantity__c,
                                                                                        List_Price__c,
                                                                                        DPR_Offer_Line_Item_Value__c,
                                                                                        Recontracting_Quantity__c,
                                                                                        Parent_DPR_Offer_Line_Item_Id__c,
                                                                                        Overridden_Unit_price__c,
                                                                                        Delegated_Pricing_Request__r.Final_Delegation_Outcome__c,
                                                                                        Delegated_Pricing_Request__r.Deal_Status__c,
                                                                                        Product_Family__c
                                                                                        FROM DPR_Offer_Line_Item__c 
                                                                                        where Delegated_Pricing_Request__c =:frameObj.Delegated_Pricing_Request__c
                                                                                        AND isNegotiableCharge__c = true]);
                                       //added isNegotiableCharge__c = true as part of EDGE-177929 by Team Amsterdam
        return offerLineList;
    }
    
    @AuraEnabled
    public static String UpdateDPROfferLine(List<wrapperLineItem> lineWrapList){
        List<DPR_Offer_Line_Item__c> dprOfferLineList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprOfferLineRec;
        Decimal overriddenTotalPrice;
        Map<String,DPR_Offer_Line_Item__c> mapOfParentDPR=new Map<String,DPR_Offer_Line_Item__c>();
        for (wrapperLineItem lineWrapRec:lineWrapList){
            dprOfferLineRec=new DPR_Offer_Line_Item__c();
            dprOfferLineRec.Id = lineWrapRec.recordId;
            dprOfferLineRec.Quantity__c  = lineWrapRec.activationSIO;
            dprOfferLineRec.Recontracting_Quantity__c = lineWrapRec.recontractSIO;
            overriddenTotalPrice=lineWrapRec.Overridden_Unit_price*(lineWrapRec.activationSIO + lineWrapRec.recontractSIO);
            dprOfferLineRec.Overridden_Total_Price__c = overriddenTotalPrice;
            dprOfferLineList.add(dprOfferLineRec);
            mapOfParentDPR.put(lineWrapRec.recordId,dprOfferLineRec);
        }
        Update dprOfferLineList;
         /** EDGE-196157 Start **/
        if(!dprOfferLineList.isEmpty() && mapOfParentDPR!=null){
            List<DPR_Offer_Line_Item__c> lstOfDLIAddOn = new List <DPR_Offer_Line_Item__c>([Select Id,Name,
                                                                                            DPR_Offer_Line_Item_Type__c,
                                                                                            Quantity__c,
                                                                                            Recontracting_Quantity__c,
                                                                                            Parent_DPR_Offer_Line_Item_Id__c,
                                                                                            Overridden_Unit_price__c,
                                                                                            Overridden_Total_Price__c
                                                                                            FROM DPR_Offer_Line_Item__c 
                                                                                            where Parent_DPR_Offer_Line_Item_Id__c IN:mapOfParentDPR.keyset()
                                                                                            AND DPR_Offer_Line_Item_Type__c= 'Addon']);
            if(!lstOfDLIAddOn.isEmpty()){
                for(DPR_Offer_Line_Item__c addOnDLI:lstOfDLIAddOn){
                    DPR_Offer_Line_Item__c ParentDLI=mapOfParentDPR.get(addOnDLI.Parent_DPR_Offer_Line_Item_Id__c);
                    addOnDLI.Overridden_Total_Price__c = addOnDLI.Overridden_Unit_price__c*(ParentDLI.Quantity__c + ParentDLI.Recontracting_Quantity__c);
                }
                update lstOfDLIAddOn;
            }
        }
         /** EDGE-196157 end **/
        return 'Success';
    }
    @AuraEnabled 
    public static String Samplemethod(){
        return 'Success';
    }
    
    //This method is making the PRE interface to get the deal score
  @AuraEnabled
  public static List<String> getDealScoreFromPREServer(String DPRId, String correlationId){
        System.debug('getDealScoreFromPREServer<><><>'+correlationId);
    List<String> correlationAndMessageList = DP_PREInterfaceClass.calloutToPREToGetDealScore(DPRId,correlationId);
        System.debug('getDealScoreFromPREServer<><><><>'+correlationAndMessageList);
    return correlationAndMessageList;
  }
    
  /*
     @Description: This method is used to generate unique correlation Id.
   */
  @AuraEnabled
  public static String getDPRCorrelationID(){
    String correlationId = EDISSingleManager.getUID();
    return correlationId;
  }
    @AuraEnabled
  public static DPR_Offer__c getDPROfferDetails(String dprOfferId){
    DPR_Offer__c dprOfferList = GBBandDelOutHandler.getDPROfferDetails(dprOfferId);
    return dprOfferList;
  }

  /* Napier Team - Shivaprasad
     * EDGE-219478 EDGE-219744
     *    @Description: This method is used to fetch values of DPR Offer level GBB Scale
   */
    @AuraEnabled
  public static DPR_Offer__c getDPROfferLevelDetails(String dprOfferId, String offerName){
        system.debug('dprOfferId::'+dprOfferId);
         system.debug('offerName::'+offerName);
    DPR_Offer__c dprOfferList = GBBandDelOutHandler.getDPROfferLevelDetails(dprOfferId, offerName);
    return dprOfferList;
  }

    @AuraEnabled
  public static String insertReceivedEventData(String DPRRecord, String DPROffer, String DPROfferLineItem, String DPRDelegationOutcome, String DPRGBBReportDetail){
    String response = DP_PREInterfaceClass.mapJSONToObjects(DPRRecord,DPROffer,DPROfferLineItem,DPRDelegationOutcome,DPRGBBReportDetail);
    return response;
  }
    /*
     *    @Description: This method is used to fetch Delegation Outcome button colour and Final Delegation Outcome value
     to be displayed on the button.
   */
  @AuraEnabled
  public static List<String> getFinalDelegationOutcome(String dprID) {
    List<String> finalDelegationOutcomeList = GBBandDelOutHandler.getFinalDelegationOutcome(dprID);
    return finalDelegationOutcomeList;
  }
    /*
     *    @Description: This method is used to fetch Delegation Outcome display pop up table values list.
   */
  @AuraEnabled
  public static List<DPR_Delegation_Outcome__c> getDelegationOutcomeTable(String dprID) {
    List<DPR_Delegation_Outcome__c> modifiedDelOutList = GBBandDelOutHandler.getDelegationOutcomeTable(dprID);
    return modifiedDelOutList;
  }

   /* Napier Team - Shivaprasad
     * EDGE-219478 EDGE-219744
     *    @Description: This method is used to fetch Delegation Outcome display pop up table values list for DPR Offers.
   */
  @AuraEnabled
  public static Map<String,List<DPR_Delegation_Outcome__c>> getDPRDelegationOutcomeTable(String dprID) {
    Map<String,List<DPR_Delegation_Outcome__c>> modifiedDelOutMap = GBBandDelOutHandler.getDPRDelegationOutcomeTable(dprID);
    return modifiedDelOutMap;
  }

    /*
     *    @Description: This method is used to fetch Plan details for Plan Gbb Scale.
   */
  @AuraEnabled
  public static DPR_Offer_Line_Item__c getDPRPlanDetails(String planId) {
    DPR_Offer_Line_Item__c dprPlanDetails = GBBandDelOutHandler.getDPRPlanDetails(planId);
    return dprPlanDetails;
  }
    /*
     * @Description: This method is used to fetch Gbb Report Details to display on i button pop up table.
   */
  @AuraEnabled
  public static List<DPR_GBB_Report_Detail__c> fetchGBBReportDetails(String planId){
    List<DPR_GBB_Report_Detail__c> dprGBBReportDetails = [SELECT Id,Annual_Revenue_Impact__c,Display_Name__c,Impact_Type__c,Label_Name__c,Scenario_Value__c,Sort_Order__c,DPR_Offer_Line_Item__r.Net_AAR__c,DPR_Offer_Line_Item__r.Total_Revenue_Impacts__c,DPR_Offer_Line_Item__r.Gross_AAR__c
                                                          FROM DPR_GBB_Report_Detail__c
                                                          WHERE DPR_Offer_Line_Item__c =:planId
                                                              order by Sort_Order__c];
    return dprGBBReportDetails;
  }
        
    public class wrapperLineItem{
        @AuraEnabled public String recordId{get; set;}
        @AuraEnabled public String discountRecordId{get; set;}
        @AuraEnabled public String planType{get; set;}
        @AuraEnabled public String plan{get; set;}
        @AuraEnabled public Decimal listPrice{get; set;}
        @AuraEnabled public Decimal mmc{get; set;}
        @AuraEnabled public Decimal activationSIO{get; set;}
        @AuraEnabled public Decimal recontractSIO{get; set;}
        @AuraEnabled public String offerLineType{get; set;}
        @AuraEnabled public String Delegated_Pricing_Request{get;set;}
        @AuraEnabled public Decimal Overridden_Unit_price{get;set;}
    @AuraEnabled public String finalDelegatedOutcome{get;set;}
        @AuraEnabled public String Deal_Status{get;set;}
        @AuraEnabled public String productFamily{get;set;}
        @AuraEnabled public List<WrapperRateCardLineItem> wrapperRateCardLineItem{get;set;}//EDGE-21112
        
        
        public wrapperLineItem(){
            recordId='';
            discountRecordId='';
            Delegated_Pricing_Request='';
            planType='';
            plan='';
            listPrice=0.00;
            mmc =0.00;
            activationSIO = 0;
            recontractSIO = 0;
            offerLineType='';
            Overridden_Unit_price=0.00;
            finalDelegatedOutcome='';
            Deal_Status='';
            wrapperRateCardLineItem=new List<WrapperRateCardLineItem>();
           
        }
       
    }
    //EDGE-21112..start
    public class WrapperRateCardLineItem{
        @AuraEnabled public String RCLrecordId{get; set;}
        @AuraEnabled public String  Plan{get; set;}
        @AuraEnabled public String  ParentRatecardName{get; set;}
        @AuraEnabled public String  RateCardLineName{get; set;}
        @AuraEnabled public Decimal  RateValue{get; set;}
        @AuraEnabled public Decimal  NegotiatedValue{get; set;}
        @AuraEnabled public Decimal  NegotiatedDiscount{get; set;}
        public WrapperRateCardLineItem(){
            RCLrecordId='';
            Plan='';
            ParentRatecardName='';
            RateCardLineName='';
            RateValue=0.00;
            NegotiatedValue=0.00;
            NegotiatedDiscount=0.00;
        }
    }
    //EDGE-21112...end
    
   // EDGE-219478 EDGE-219744 team Napier - Start - Shivaprasad

    public class dprOfferFDOColor{
        @AuraEnabled public String productFamily{get; set;}
        @AuraEnabled public String fdo{get; set;}
        @AuraEnabled public String color{get; set;}
        @AuraEnabled public String userProfile{get; set;}
        @AuraEnabled public Boolean dprFDOButton{get; set;}
        public dprOfferFDOColor(){
            productFamily='';
                fdo=null;
                color='';
                userProfile='';
              dprFDOButton = false;
        }
    }
    // EDGE-219478 EDGE-219744 team Napier - End - Shivaprasad

    //-----START OF EDGE-185052 by Abhishek from Osaka Team--------//
    //Description: This method is used to fetch 'Type' field of opportunity related to current FA record.
    //and return true if opportunity type is Migration and logged in user Profile is Migration BOH User.
    @AuraEnabled
    public static Boolean getOpptyType(String frameId){
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        Boolean isMigration = false;
        csconta__Frame_Agreement__c frameRec = new csconta__Frame_Agreement__c();
        frameRec = [select opportunity__r.type from csconta__Frame_Agreement__c frameRec where id = :frameId];
        if(frameRec.opportunity__r.type == 'Migration' && profileName == 'Migration BOH user'){
            isMigration = true;
        }
        return isMigration;
    }
    

    //Description: This method updates Frame Agreement status to scored, Final Delegation Outcome = Account Executive 
    //        and marks isPrimary checkbox as true.
    @auraEnabled
    public static csconta__Frame_Agreement__c updatDPR(String frameId){
        System.debug('Frame ID::'+frameId);
        csconta__Frame_Agreement__c frameRec = new csconta__Frame_Agreement__c();
        csconta__Frame_Agreement__c frameRecUpdate = new csconta__Frame_Agreement__c();
        frameRec = [select id,Final_Delegation_Outcome__c,csconta__Status__c from csconta__Frame_Agreement__c frameRec where id = :frameId];
        if(frameRec!= null){
            frameRecUpdate.Id = frameRec.id;
            frameRecUpdate.Final_Delegation_Outcome__c = 'Account Executive';
            frameRecUpdate.csconta__Status__c = 'Scored';
            frameRecUpdate.isPrimary__c = True;
            update frameRecUpdate;
        }
        return frameRecUpdate;
    }
    //-----START OF EDGE-185052 by Abhishek from Osaka Team--------//

/*  
@Added by: Shivaprasad
@team : Napier
@Description: This method is used to fetch Delegation Outcome button colour and Final Delegation Outcome value 
to be displayed on the button for DPR Offer.
*/
@AuraEnabled
public static List<dprOfferFDOColor> getDPROfferFinalDelegationOutcome(String dprID) {
    
    Integer userDelegationRole;
    Integer finalDelegationOutcome;
    
    List<dprOfferFDOColor> dprOfferDelOutcomeList = new  List<dprOfferFDOColor>();

    Map<String,Integer> delegationHierarchy = new Map<String,Integer>();
    delegationHierarchy.put('Partner',0);    //EDGE-186881 Changes to Deal escalation flow for Partner users
    delegationHierarchy.put('Account Executive',1);
    delegationHierarchy.put('Sales Specialist',2);
    delegationHierarchy.put('Sales Manager',3);
    delegationHierarchy.put('Sales General Manager',4);
    delegationHierarchy.put('Customized Pricing',5);
    delegationHierarchy.put('No Discount Offerable',6);//Not Offerable
    
    Map<String, List<String>> mapOfProductFamilyFDO = new  Map<String, List<String>>();

    User user = [select id, Profile.Name, Delegation_Role__c 
    FROM User Where id =: userInfo.getUserId()];
    String udr = user.Delegation_Role__c;
    String up = user.Profile.Name;

    List<DPR_Offer__c> dprList = [select id, Product_Family__c, Final_Delegation_Outcome__c from DPR_Offer__c where Delegated_Pricing_Request__c =: dprID];
    
    
    for(DPR_Offer__c dpr: dprList){
        
        dprOfferFDOColor dprOfferDelOutcome = new dprOfferFDOColor();
        

        List<String> finalDelegationOutcomeList = new List<String>();
        String fdo = dpr.Final_Delegation_Outcome__c;
        
        System.debug('PF::'+dpr.Product_Family__c);
        dprOfferDelOutcome.productFamily = dpr.Product_Family__c;

        if(fdo!=null){
            dprOfferDelOutcome.fdo = fdo;
            dprOfferDelOutcome.dprFDOButton = true;
            finalDelegationOutcomeList.add(fdo);
            System.debug('PF::'+dpr.Product_Family__c+',fdo::'+dpr.Final_Delegation_Outcome__c);
        }
        if(fdo==null){
            dprOfferDelOutcome.fdo = null;
            dprOfferDelOutcome.dprFDOButton = true;
            finalDelegationOutcomeList.add('null'); 
            System.debug('PF::'+dpr.Product_Family__c+',fdo::'+dpr.Final_Delegation_Outcome__c);
        }
        
        //Commented as part of EDGE-219478 EDGE-219744 - Start
        //FDO-partner button green EDGE-188476
        /*if('Partner' == fdo){
            String colour = 'success';
            dprOfferDelOutcome.color = colour;
            finalDelegationOutcomeList.add(colour);
            System.debug('PF::'+dpr.Product_Family__c+',Color::'+colour);
        }*/
        //Commented as part of EDGE-219478 EDGE-219744 - END
        //FDO-NO button red
        if('No Discount Offerable' == fdo){
            String colour = 'destructive';
            dprOfferDelOutcome.color = colour;
            finalDelegationOutcomeList.add(colour);
        }
        //DIGI-720 Condition Change
        //if UDR empty consider UDR as AE       
        if(udr == null){
            udr = 'Account Executive';
        }       
                
        //iterate through map to get hierarchy values
        for(String delOut : delegationHierarchy.keySet()){
            if(delOut == fdo){
                finalDelegationOutcome = delegationHierarchy.get(delOut);
            }
            if(delOut == udr){
                userDelegationRole = delegationHierarchy.get(delOut);
            }
        }
        
        //if FDO>UDR button will be red
        if(finalDelegationOutcome > userDelegationRole){
            String colour = 'destructive';
            dprOfferDelOutcome.color = colour;
            finalDelegationOutcomeList.add(colour);
            System.debug('PF::'+dpr.Product_Family__c+',Color::'+colour);
        }
        
        //if FDO<=UDR button will be green
        if(finalDelegationOutcome <= userDelegationRole){
            String colour = 'success';
            dprOfferDelOutcome.color = colour;
            finalDelegationOutcomeList.add(colour);
        }
        
        //for debug
        dprOfferDelOutcome.userProfile = up;
        finalDelegationOutcomeList.add(up);
        mapOfProductFamilyFDO.put(dpr.Product_Family__c,finalDelegationOutcomeList);
        dprOfferDelOutcomeList.add(dprOfferDelOutcome);
    }

    return dprOfferDelOutcomeList;
    
}
    // Added by team Napier EDGE-219478 EDGE-219744 - End - Shivaprasad

}
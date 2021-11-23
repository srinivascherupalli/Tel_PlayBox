/********************************************************************
EDGE        : 114351
Controller  : DelegatedPricingController
Description : DPR Controller
Author      : Deepak Kumar
Last Modified By: Manish Berad
1.          Gunjan Aswani           16/12/2020              EDGE-190520 FAM Contract Initiation
2.          Kamlesh Kumar           17/3/2021               EDGE : 200438  Fetched group details ex : Queue
3.          Parmanand               12/5/2021               EDGE-212164
4.          Madhu Gaurav            11/10/2021              DIGI-24743
*******************************************************************/   

global with sharing class  DelegatedPricingController implements csfam.RemoteActionDataProvider {
    
    @AuraEnabled  
    public static Map<String,DelegatedPricingController.MinMaxDiscountWrapper> fetchMinMaxValuesForDiscounts(){
        Map<String,DelegatedPricingController.MinMaxDiscountWrapper> mapOfMinMax=new Map<String,DelegatedPricingController.MinMaxDiscountWrapper>();
        List<cspmb__Discount_Association__c> lstMinMax=[select cspmb__Discount_Level__r.Name,cspmb__Discount_Level__r.cspmb__Minimum_Discount_Value__c, 
                                                        cspmb__Discount_Level__r.cspmb__Maximum_Discount_Value__c,cspmb__price_item__r.Type__c,cspmb__price_item__r.Plan__c 
                                                        from cspmb__Discount_Association__c where cspmb__Discount_Level__r.Check_todays_date__c = true
                                                        and cspmb__Discount_Level__r.is_delegated__c = true and cspmb__Discount_Level__r.Account__c = null];
        if(lstMinMax.size()>0){
            for(cspmb__Discount_Association__c da:lstMinMax){
                if(da.cspmb__Discount_Level__c!=null){
                    if(da.cspmb__price_item__r.Type__c!=null && da.cspmb__price_item__r.Plan__c!=null && da.cspmb__Discount_Level__r.Name!=null){
                        string minMaxKey=da.cspmb__price_item__r.Type__c+da.cspmb__price_item__r.Plan__c+da.cspmb__Discount_Level__r.Name;
                        DelegatedPricingController.MinMaxDiscountWrapper wrapp=new DelegatedPricingController.MinMaxDiscountWrapper();
                        wrapp.DiscountName=da.cspmb__Discount_Level__r.Name;
                        if(da.cspmb__Discount_Level__r.cspmb__Minimum_Discount_Value__c!=null && da.cspmb__Discount_Level__r.cspmb__Maximum_Discount_Value__c!=null){
                            wrapp.MinVal=da.cspmb__Discount_Level__r.cspmb__Minimum_Discount_Value__c;
                            wrapp.MaxVal=da.cspmb__Discount_Level__r.cspmb__Maximum_Discount_Value__c;
                        }
                        mapOfMinMax.put(minMaxKey,wrapp);
                    }
                }
            }
        }
        return mapOfMinMax;
    }
    
    public class MinMaxDiscountWrapper{
        @AuraEnabled public String DiscountName;
        @AuraEnabled public Decimal MinVal;
        @AuraEnabled public Decimal MaxVal;
        MinMaxDiscountWrapper(){
            DiscountName='';
            MinVal=0;
            MaxVal=0;
        }
    }
    
    
    /*  Start of EDGE:114434,114433,117701
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created Common function to fetch picklist values.
    */  
    @AuraEnabled
    public static DelegatedPricingController.PicklistValesWrapper fetchPickValues(String  selectedProduct){
        DelegatedPricingController.PicklistValesWrapper pickWrapp=new DelegatedPricingController.PicklistValesWrapper();
        Map<String,set<String>> mapOfOfferTypeVsProduct=new Map<String,set<String>>();
        Map<String,set<String>> mapOfCmdPlanVsOffer=new Map<String,set<String>>();
        Map<String,set<String>> mapOfPlanTypeVsOffer=new Map<String,set<String>>();
        Map<String,set<String>> mapOfcmdPlanVsPtype=new Map<String,set<String>>();
        Map<String,set<String>> mapOfAddOn=new Map<String,set<String>>();
        Set<String> setOfPriceItemIds=new Set<String>();
        List<DPOfferId__mdt> ListOfOfferIds=new List<DPOfferId__mdt>();
        for(DPOfferId__mdt dproffer : [SELECT Id,Product_Name__c,Add_on_Prod_Spec_Id__c,Add_on_External_Id__c FROM DPOfferId__mdt WHERE Product_Name__c=:selectedProduct]){
            ListOfOfferIds.add(dproffer);
        }
        List<Marketable_Offer__c > listOfMarkOffer=[SELECT Id,Name,Offer_ID__c FROM Marketable_Offer__c  WHERE Name=:selectedProduct];
        if(listOfMarkOffer.size()>0){
            String SOQLquery='SELECT Id,Offer_Id__c,Offer_Type__c ,Offer__c,Offer_Name__c,cspmb__Price_Item_Code__c,cspmb__Recurring_Charge__c,Type__c,Plan__c FROM cspmb__Price_Item__c WHERE Check_todays_date__c=true';
            
            List<cspmb__Price_Item__c> lstofPriceItem = Database.query(SOQLquery);
            //system.debug('Adddd#'+lstofPriceItem);
            if(lstofPriceItem.size()>0){
                for(cspmb__Price_Item__c pi:lstofPriceItem){
                    
                    //get offer type based on selected product
                    if((pi.cspmb__Price_Item_Code__c==listOfMarkOffer[0].Name && pi.Offer_Id__c==listOfMarkOffer[0].Offer_ID__c)
                       && (pi.offer_type__c=='Fairplay Data' || pi.offer_type__c=='Committed Data')){
                           //put Offer_Type__c  against cspmb__Price_Item_Code__c
                           if(!mapOfOfferTypeVsProduct.containsKey(pi.cspmb__Price_Item_Code__c)){
                               mapOfOfferTypeVsProduct.put(pi.cspmb__Price_Item_Code__c, new Set<String>{pi.Offer_Type__c});
                           }else{
                               mapOfOfferTypeVsProduct.get(pi.cspmb__Price_Item_Code__c).add(pi.Offer_Type__c);
                           }
                       }
                    
                    //get commited Data Plans based on offer type
                    if(pi.Offer_Id__c==listOfMarkOffer[0].Offer_ID__c && pi.offer_type__c=='Committed Data'){
                        //put Plan__c against Offer_Type__c 
                        if(!mapOfCmdPlanVsOffer.containsKey(pi.Offer_Type__c)){
                            mapOfCmdPlanVsOffer.put(pi.Offer_Type__c,new Set<String>{pi.Plan__c});
                        }else{
                            mapOfCmdPlanVsOffer.get(pi.Offer_Type__c).add(pi.Plan__c);
                        }
                    }
                    
                    //get plan type based on offer type
                    if((pi.Offer__c =='Committed Data'|| pi.Offer__c =='FairPlay Data') 
                       && pi.Offer_Id__c==listOfMarkOffer[0].Offer_ID__c && pi.Plan__c!=null){
                           //put Type__c against Offer__c
                           if(!mapOfPlanTypeVsOffer.containsKey(pi.Offer__c)){
                               mapOfPlanTypeVsOffer.put(pi.Offer__c,new Set<String>{pi.Type__c});
                           }else{
                               mapOfPlanTypeVsOffer.get(pi.Offer__c).add(pi.Type__c);
                           }
                       }
                    
                    //get plans based on plan 
                    System.debug('pi.Offer__c '+pi.Offer__c);
                     System.debug('pi.Offer_Id__c '+pi.Offer_Id__c);
                     System.debug('listOfMarkOffer[0].Offer_ID__c '+listOfMarkOffer[0].Offer_ID__c);
                     System.debug('pi.Offer_Type__c '+pi.Offer_Type__c);
                    if((pi.Offer__c =='Committed Data'|| pi.Offer__c =='FairPlay Data')
                       && pi.Offer_Id__c==listOfMarkOffer[0].Offer_ID__c && pi.Offer_Type__c==null){
                           
                           string OTCDkey=pi.Offer__c+pi.Type__c;
                           if(!mapOfcmdPlanVsPtype.containsKey(OTCDkey)){
                               mapOfcmdPlanVsPtype.put(OTCDkey,new Set<String>{pi.Plan__c});
                           }else{
                               mapOfcmdPlanVsPtype.get(OTCDkey).add(pi.Plan__c);
                           }
                       }
                    
                    //logic 
                    if(pi.Offer_Id__c==listOfMarkOffer[0].Offer_ID__c){
                        setOfPriceItemIds.add(pi.Id);
                    }
                }  
            }
        }
        if(setOfPriceItemIds.size()>0){
             //Start of EDGE-146943 : Added Check_todays_date__c condition to below SOQL query to fetch add-on association records 
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> listAddOn=[SELECT ID,AddOn_Name__c,cspmb__price_item__c,cspmb__price_item__r.Offer__c,cspmb__price_item__r.Plan__c,cspmb__price_item__r.Type__c
                                                                                FROM cspmb__Price_Item_Add_On_Price_Item_Association__c
                                                                                WHERE cspmb__Add_On_Price_Item__r.external_id__c LIKE '%RecurringCharge_000669%' AND cspmb__add_on_price_item__r.ProdSpecId__c =:ListOfOfferIds[0].Add_on_Prod_Spec_Id__c
                                                                                AND  cspmb__price_item__c=:setOfPriceItemIds AND Check_todays_date__c =true ];
            //End of EDGE-146943
            if(listAddOn.size()>0){
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c pia:listAddOn){
                    if(pia.AddOn_Name__c!=null && pia.AddOn_Name__c!=''){
                        string addOnKey=pia.cspmb__price_item__r.Offer__c+pia.cspmb__price_item__r.Type__c+pia.cspmb__price_item__r.Plan__c;
                        if(!mapOfAddOn.containsKey(addOnKey)){
                            mapOfAddOn.put(addOnKey,new Set<String>{pia.AddOn_Name__c});
                        }else{
                            mapOfAddOn.get(addOnKey).add(pia.AddOn_Name__c);
                        }
                    }
                }
            }
        }
        
        System.debug('mapOfAddOn'+mapOfAddOn);
        if(mapOfOfferTypeVsProduct!=null){
            pickWrapp.mapOfOfferTypeVsProduct=mapOfOfferTypeVsProduct;
        }
        if(mapOfCmdPlanVsOffer!=null){
            pickWrapp.mapOfCmdPlanVsOffer=mapOfCmdPlanVsOffer;
        }
        if(mapOfPlanTypeVsOffer!=null){
            pickWrapp.mapOfPlanTypeVsOffer=mapOfPlanTypeVsOffer;
        }
        if(mapOfcmdPlanVsPtype!=null){
            pickWrapp.mapOfcmdPlanVsPtype=mapOfcmdPlanVsPtype;
        }  
        if(mapOfAddOn!=null){
            pickWrapp.mapOfAddOn=mapOfAddOn;
        }
        return pickWrapp;
    }
    
    /*  Start of EDGE:114434,114433,117701
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created Wrapper function to fetch picklist values.
    */  
    public class PicklistValesWrapper{
        @AuraEnabled
        public Map<String,set<String>> mapOfOfferTypeVsProduct {get;set;}  
        @AuraEnabled
        public Map<String,set<String>> mapOfCmdPlanVsOffer {get;set;} 
        @AuraEnabled
        public Map<String,set<String>> mapOfPlanTypeVsOffer {get;set;}
        @AuraEnabled
        public Map<String,set<String>> mapOfcmdPlanVsPtype {get;set;} 
        @AuraEnabled
        public Map<String,set<String>> mapOfAddOn {get;set;} 
        public PicklistValesWrapper(){
            mapOfOfferTypeVsProduct=new Map<String,set<String>>();
            mapOfCmdPlanVsOffer=new Map<String,set<String>>();
            mapOfPlanTypeVsOffer=new Map<String,set<String>>();
            mapOfcmdPlanVsPtype=new Map<String,set<String>>();
            mapOfAddOn=new Map<String,set<String>>();
        }
    }
    
    /*  Start of EDGE:117701,114435
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created function to fetch discount values on selection of plan.
    */  
    @AuraEnabled
    public static string  getDiscountValue(String selectedProduct,
                                           String offerType ,String DPRId,String DelegatedPricingRequest,
                                           String hardwareOption,String MarketableOffer,String type,String plans,String discountName){
                                               List<cspmb__Price_Item__c> listOfCSPMBForPlanRecId=new List<cspmb__Price_Item__c>();
                                               List<Marketable_Offer__c > listOfMarkOffer=new List<Marketable_Offer__c >();
                                               listOfMarkOffer=[SELECT Id,Name,Offer_ID__c FROM Marketable_Offer__c  WHERE Name=:selectedProduct];
                                               
                                               if(listOfMarkOffer.size() > 0){
                                                   listOfCSPMBForPlanRecId=[SELECT Id FROM cspmb__Price_Item__c WHERE Check_todays_date__c=true AND
                                                                            Offer__c=:offerType AND Offer_Id__c=:listOfMarkOffer[0].Offer_ID__c 
                                                                            AND Type__c=:type 
                                                                            AND Plan__c <> NULL];
                                               }
                                               List<cspmb__Price_Item__c> listOfCSPMB=new List<cspmb__Price_Item__c>();
                                               if(listOfMarkOffer.size() > 0){
                                                   listOfCSPMB=[SELECT Id,Type__c,Plan__c FROM cspmb__Price_Item__c WHERE Check_todays_date__c=true AND Offer__c=:offerType AND Offer_Id__c=:listOfMarkOffer[0].Offer_ID__c AND  Plan__c =:plans AND Type__c=:type];
                                               }
                                               Set<Id> setOFPriceItemRecID=new Set<Id>();
                                               for(cspmb__Price_Item__c priceItemObj:listOfCSPMB){
                                                   setOFPriceItemRecID.add(priceItemObj.Id);
                                               }
                                               List<cspmb__Discount_Association__c> listOfDiscount=[SELECT ID,cspmb__Discount_Level__r.cspmb__Discount_Values__c FROM cspmb__Discount_Association__c
                                                                                                    WHERE cspmb__price_item__c=:setOFPriceItemRecID and cspmb__discount_level__r.is_delegated__c= true
                                                                                                    and cspmb__discount_level__r.check_todays_date__c = true AND cspmb__Discount_Level__r.Name=:discountName];
                                               String discountValue;
                                               if(listOfDiscount.size() > 0){
                                                   discountValue=listOfDiscount[0].cspmb__Discount_Level__r.cspmb__Discount_Values__c;
                                               }
                                               return discountValue;
                                               
                                           }
    
    ////EDGE: 114351 | Get Opportunity details.
    ////EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals
    @Auraenabled 
    public static Opportunity getOpportunityDetails(Id oppId){
        Opportunity  orpportunityDetailsRecord = [SELECT ID,Name,AccountID,Account.Name,Product_Type__c,Contract_Attachment_Count__c,Product_Count__c,Pricing_Method__c,StageName,(SELECT Id FROM OpportunityContactRoles) 
                                                  FROM Opportunity 
                                                  WHERE Id =:oppId LIMIT 1];
        return orpportunityDetailsRecord;
    }
    
    //EDGE : 114351 | Get Delegated Pricing details.
    //EDGE:118631 | Escalate the deal to the next approving authority.
    @Auraenabled
    public static Delegated_Pricing_Request__c fetchDelPricingRequest(Id DPRId)
    {
        List<Delegated_Pricing_Request__c> DPR= new List<Delegated_Pricing_Request__c>([Select Id, Name,Deal_Status__c,Deal_Approver__r.Name,Description__c,is_Deal_Escalated__c,DPR_Number__c,isPrimary__c,Mark_as_Variation__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,Opportunity__r.StageName,Parent_DPR__c,TotalContractValue__c,Final_Delegation_Outcome__c from Delegated_Pricing_Request__c where Id=:DPRId]);
    
        if(DPR.size()>0){
           return  DPR[0];
        }else{
            return new Delegated_Pricing_Request__c();
        }
    }
    
    //EDGE:114351 | This method is used to fetch the Marketable Offer  details.
    @AuraEnabled
    Public static List<Marketable_Offer__c> getMarketableofferDetailes(String objectType, String selectedField ){
        List<Marketable_Offer__c> lstoffers=[SELECT Id,Name,OfferDefinationName__c,Offer_ID__c,OwnerId,Solution_Template__c FROM Marketable_Offer__c where Is_Enabled_for_Delegated_Pricing__c= true];
        return lstoffers;
    }
    
    //EDGE : 114351 | Save DPR Landing screen details.
    //EDGE:118631 | Escalate the deal to the next approving authority.
    //EDGE:117700: Cancel function on DPR screen.
    //EDGE:121823 | Deal Approval Process UI functionality for Pricing Team Approvals.
    @Auraenabled
    public static Delegated_Pricing_Request__c insertDelegatedPricingRequest(Delegated_Pricing_Request__c dpRequest){
        system.debug('@@@@@@@dpRequest'+dpRequest);
        upsert dpRequest;
        if(dpRequest.Id != null){
        return fetchDelPricingRequest(dpRequest.Id); 
        }else{
            return dpRequest;
        }
    }
    //akshay
    @AuraEnabled
    public static csconta__Frame_Agreement__c insertFrameAgreement(csconta__Frame_Agreement__c dpRequest){
        system.debug('@@@@@@@dpRequest'+dpRequest);
        upsert dpRequest;
        if (dpRequest.Id != null) {
            return fetchFAPricingRequest(dpRequest.Id);
            
        } else {
            return dpRequest;
        }
    }
    @AuraEnabled
    public static csconta__Frame_Agreement__c fetchFAPricingRequest(Id FAId)
    {
        List<csconta__Frame_Agreement__c > FA = new List<csconta__Frame_Agreement__c >([Select Id, csconta__Agreement_Name__c ,csconta__Status__c,Deal_Approver__r.Name,Description__c,is_Deal_Escalated__c,isPrimary__c,Mark_as_Variation__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.Account.Name,TotalContractValue__c,Final_Delegation_Outcome__c from csconta__Frame_Agreement__c where Id = : FAId]);

        if (FA.size() > 0) {
            return FA[0];
        } else {
            return new csconta__Frame_Agreement__c ();
        }
    }
    
    //EDGE:134133 | not allow new DPR if a DPR already in 'Sent for Approval'
    @Auraenabled
    public static Boolean getSentForApprovalDPR(Id oppId){
        Boolean sentForApproval = false;
        List<Delegated_Pricing_Request__c> dprList = new List<Delegated_Pricing_Request__c>();
        dprList = [SELECT Id, Deal_Status__c FROM Delegated_Pricing_Request__c WHERE Opportunity__c =: oppId];
        if(!dprList.isEmpty()){
            for(Delegated_Pricing_Request__c dpr: dprList){
                if(dpr.Deal_Status__c == 'Sent for Approval'){
                    sentForApproval = true;
                }  
            }
        }
        return sentForApproval;
    }
    
    //EDGE:118631 | Escalate the deal to the next approving authority
    @Auraenabled
    public static void insertOpportunityTeamMember(ID OpportunityId, ID DealApprover){
        OpportunityTeamMember OppTeamMember = new OpportunityTeamMember();
        OppTeamMember.UserId = DealApprover;
        OppTeamMember.OpportunityId = OpportunityId;
        OppTeamMember.TeamMemberRole = 'Opportunity Team Member';
        upsert OppTeamMember;
        //get all of the sharing records which Salesforce created right now. rowCause is Sales Team.
        List<OpportunityShare> oppShareRecords = [select Id, OpportunityAccessLevel, RowCause from OpportunityShare where OpportunityId =: OpportunityId and RowCause = 'Sales Team'];
        //set all team members access to read/write
        for (OpportunityShare OppShare : oppShareRecords){
            OppShare.OpportunityAccessLevel = 'Edit';
        }
    }
    
    
    @AuraEnabled
    public static List<cspmb__Price_Item__c> fetchCommercialProduct(Decimal limitValue){
        Integer ltVlaue = (Integer)limitValue;
        List<cspmb__Price_Item__c> priceItem=[select id,Plan__c,Offer_Name__c,Offer_Type__c,Offer_Id__c,Type__c,cspmb__Account__r.GB2B_Customer_Status__c from cspmb__Price_Item__c LIMIT :ltVlaue ];
        System.debug('priceItem'+priceItem);
        return priceItem;
    }
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    @AuraEnabled
    public static Boolean fetchGroupMember(){
        Boolean groupMemberVal = false;
        List< GroupMember > gmList = [Select Group.DeveloperName, UserOrGroupId From GroupMember where  UserOrGroupId = :userInfo.getUserId() and Group.DeveloperName = 'Enterprise_Pricing_User_1'];
        If (gmList.size() == 0){
            groupMemberVal = true;
        }
        return groupMemberVal;
    }
    
    @Auraenabled
    public static List<DPR_Offer_Line_Item__c> getOfferPlans(String DPROfferId){
        List<DPR_Offer_Line_Item__c> offerRecordLineItemList = [SELECT Id, Name, DPR_Offer__c, Marketable_Offer__c, Offer_Type_Name__c, cspmb_Price_Item__c, cspmb_Add_On_Price_Item__c,
                                                                Offer_Type__c, cspmb_Allowance__c, Parent_DPR_Offer_Line_Item_Id__c, DPR_Offer_Line_Item_Type__c, 
                                                                DPR_Offer_Line_Item_Unit_Type__c, Quantity__c, List_Price__c, DPR_Offer_Line_Item_Value__c, 
                                                                Overridden_Unit_price__c, Overridden_Total_Price__c, Total_Recurring_Charge__c, 
                                                                Total_Once_Off_Charge__c, PoorMinimalValue__c, ActualOfferPrice__c, MinimalMarginalValue__c, 
                                                                GoodBetterValue__c, MarginalGoodValue__c, BetterBestValue__c, BestMaxValue__c, Delegated_Pricing_Request__c, 
                                                                External_System__c, Gross_AAR__c, Recontracting_Quantity__c, Total_Revenue_Impacts__c, 
                                                                Net_AAR__c, Counter__c FROM DPR_Offer_Line_Item__c WHERE DPR_Offer__c =:DPROfferId];
        return offerRecordLineItemList;
    } 
    
    /*  Start of EDGE:114435
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created function to fetch offer type values.
    */  
    @Auraenabled
    public static List<DPR_Offer__c>  fetchDPROffer(String  selectedProduct, String DPRId){
        List<DPR_Offer__c> dprOfferList =[SELECT Id, Name FROM DPR_Offer__c WHERE Name = : selectedProduct AND Delegated_pricing_Request__c = :DPRId];
        system.debug('dprOfferList ###'+dprOfferList);
        
        if(dprOfferList != null && dprOfferList.size() > 0){
            return dprOfferList;
        }
        return dprOfferList;    
    }
    
    /*  Start of 119320,114435,114434
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created function to fetch MRO Bonus credit values.
    */
    @Auraenabled
    public static String  fetchMroBonCredAmt(String  discLevId){
        String mroBonusCred;
        List<cspmb__Discount_Level__c > listOfDiscLev=new List<cspmb__Discount_Level__c >();
        listOfDiscLev=[SELECT ID,cspmb__Discount_Values__c FROM cspmb__Discount_Level__c   WHERE Id=:discLevId];
        if(listOfDiscLev.size() > 0){
            mroBonusCred = listOfDiscLev[0].cspmb__Discount_Values__c;
        }
        System.debug('mroBonusCred--'+mroBonusCred);
        return mroBonusCred;
    }
    
    
    /*  Start of 119320,114435,114434
    @Modified/updatedBy: 
    @team : Napier
    @Description: Created function to fetch discounts for selected plan.
    */
    @Auraenabled
    public static List<cspmb__Discount_Association__c>  getDiscountData(String  selectedProduct,String offerType,String plan,String planType,String getcommitteddata){ 
        List<cspmb__Price_Item__c> listOfCSPMBToReturn=new List<cspmb__Price_Item__c>();
        List<cspmb__Price_Item__c> listOfCSPMB=new List<cspmb__Price_Item__c>();
        List<cspmb__Discount_Association__c>listofdiscountdata = null; 
        List<cspmb__Discount_Association__c> listOfDiscount = new List<cspmb__Discount_Association__c>();
        List<cspmb__Discount_Association__c> listOfcommittedDiscount = new List<cspmb__Discount_Association__c>();
        Set<Id> setOFPriceItemRecID=new Set<Id>();
        Set<Id> setOfferRecID=new Set<Id>();
        List<Marketable_Offer__c > listOfMarkOffer=[SELECT Id,Name,Offer_ID__c FROM Marketable_Offer__c  WHERE Name=:selectedProduct];
        if(listOfMarkOffer.size() > 0){ listOfCSPMB=[SELECT Id,Type__c,Plan__c FROM cspmb__Price_Item__c WHERE Check_todays_date__c=true AND 
                                                     Offer__c=:offerType AND Offer_Id__c=:listOfMarkOffer[0].Offer_ID__c AND  Plan__c =:plan AND Type__c=:planType];
                                      }
        for(cspmb__Price_Item__c priceItemObj:listOfCSPMB){ 
            setOFPriceItemRecID.add(priceItemObj.Id); 
        }
        listOfDiscount=[SELECT ID,Name,cspmb__Discount_Level__c,cspmb__Discount_Level__r.cspmb__Discount__c,
                        cspmb__Discount_Level__r.Name,cspmb__Discount_Level__r.cspmb__Discount_Type__c,
                        cspmb__price_item__c FROM cspmb__Discount_Association__c
                        WHERE cspmb__price_item__c=:setOFPriceItemRecID and cspmb__discount_level__r.is_delegated__c= true
                        and cspmb__discount_level__r.check_todays_date__c = true and cspmb__Discount_Level__r.account__c = null];
        listOfcommittedDiscount =[ select ID,Name , cspmb__Discount_Level__c, cspmb__Discount_Level__r.Data_Pack_Plan__c, cspmb__Discount_Level__r.Name,
                                  cspmb__Discount_Level__r.cspmb__Discount_Type__c,cspmb__price_item__c from cspmb__Discount_Association__c where 
                                  (cspmb__price_item__c =: setOFPriceItemRecID and cspmb__Discount_Level__r.Data_Pack_Plan__c =: getcommitteddata and cspmb__Discount_Level__r.Is_Delegated__c = true and cspmb__Discount_Level__r.Check_todays_date__c = true and cspmb__Discount_Level__r.account__c = null) or
                                  (cspmb__price_item__c = :setOFPriceItemRecID and cspmb__Discount_Level__r.Data_Pack_Plan__c = null and cspmb__Discount_Level__r.Is_Delegated__c = true and cspmb__Discount_Level__r.Check_todays_date__c = true and cspmb__Discount_Level__r.account__c = null)];
        if(offerType == 'Fairplay Data'){
            listofdiscountdata = new List<cspmb__Discount_Association__c>();
            listofdiscountdata.addall(listOfDiscount); 
        }
        else if(offerType == 'Committed Data'){
            listofdiscountdata = new List<cspmb__Discount_Association__c>();
            listofdiscountdata.addall(listOfcommittedDiscount);
        }
        return listofdiscountdata;
    }
    
    //--added by deepak
    @Auraenabled
    public static cspmb__Price_Item__c  fetchDataOnPlanTypeAndPlanD(String  planType,String plan){
        cspmb__Price_Item__c listOfCSPMB=new cspmb__Price_Item__c();
        try{
            listOfCSPMB=[SELECT Id,Type__c,Plan__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c WHERE
                         Plan__c=:plan AND Type__c=:planType AND Offer_Id__c='DMCAT_Offer_000646' AND Offer__c in('FairPlay Data','Committed Data') AND Check_todays_date__c = true  limit 1];
        }catch(Exception e){
        }
        return listOfCSPMB;
    }
    //This method is making the PRE interface to get the deal score 
    //Author: Megha Bhardwaj
    @AuraEnabled 
    public static List<String> getDealScoreFromPREServer(String DPRId, String correlationId){
        List<String> correlationAndMessageList =DP_PREInterfaceClass.calloutToPREToGetDealScore(DPRId,correlationId);
        return correlationAndMessageList;
    }
    
    //  added by Rishabh 1
    /*  Start of EDGE:118371
    @Modified/updatedBy: 
    @team : Napier
    @Description: This method is used to fetch DPR offer values which are used to create the GBB Scale.
    */   
    @Auraenabled  
    public static DPR_Offer__c getDPROfferDetails(String dprOfferId){
        DPR_Offer__c dprOfferList = GBBandDelOutHandler.getDPROfferDetails(dprOfferId);
        return dprOfferList;
    } 
    
    //  added by Rishabh 2
    /*  Start of EDGE:114439
    @Modified/updatedBy: 
    @team : Napier
    @Description: This method is used to fetch Delegation Outcome button colour and Final Delegation Outcome value 
    to be displayed on the button.
    */    
    @AuraEnabled
    public static List<String> getFinalDelegationOutcome(String dprID) {
        List<String> finalDelegationOutcomeList = GBBandDelOutHandler.getFinalDelegationOutcome(dprID);
        return finalDelegationOutcomeList;
    } 
    
    //  added by Rishabh 3 
    /*  Start of EDGE:114439
    @Modified/updatedBy: 
    @team : Napier
    @Description: This method is used to fetch Delegation Outcome display pop up table values list.
    */ 
    @AuraEnabled
    public static List<DPR_Delegation_Outcome__c> getDelegationOutcomeTable(String dprID) {
        List<DPR_Delegation_Outcome__c> modifiedDelOutList = GBBandDelOutHandler.getDelegationOutcomeTable(dprID);
        return modifiedDelOutList;
    } 
    
    //  added by Rishabh 4 
    /*  Start of EDGE:118624
    @Modified/updatedBy: 
    @team : Napier
    @Description: This method is used to fetch Gbb Report Details to display on i button pop up table.
    */
    @AuraEnabled
    public static List<DPR_GBB_Report_Detail__c> fetchGBBReportDetails(String planId){
        List<DPR_GBB_Report_Detail__c> dprGBBReportDetails=[SELECT Id,Annual_Revenue_Impact__c,Display_Name__c,Impact_Type__c,Label_Name__c,Scenario_Value__c,Sort_Order__c,DPR_Offer_Line_Item__r.Net_AAR__c,DPR_Offer_Line_Item__r.Total_Revenue_Impacts__c,DPR_Offer_Line_Item__r.Gross_AAR__c 
                                                            FROM DPR_GBB_Report_Detail__c 
                                                            WHERE DPR_Offer_Line_Item__c=:planId
                                                            order by Sort_Order__c];
        return dprGBBReportDetails;
    }
    
    //  added by Megha
    /*  Start of EDGE:EDGE-118371
    @Modified/updatedBy: 
    @team : Napier
    @Description: This method is used persist data into database received through platform event from MS.
    */ 
    @AuraEnabled
    public static String insertReceivedEventData(String DPRRecord, String DPROffer, String DPROfferLineItem, String DPRDelegationOutcome, String DPRGBBReportDetail){
        String response = DP_PREInterfaceClass.mapJSONToObjects(DPRRecord,DPROffer,DPROfferLineItem,DPRDelegationOutcome,DPRGBBReportDetail);
        return response;
    }
    
    //EDGE:114351 | Get Delegated Pricing details.
    @AuraEnabled
    public static DelegatedPricingCurrentLoggedUser fetchDelegatedPricingCurrentLoggedUser(Id DPRId){
        DelegatedPricingCurrentLoggedUser DelPriceEsclate = new DelegatedPricingCurrentLoggedUser();
        DelPriceEsclate.delPriceReq = [SELECT Id, Name,Deal_Status__c,is_Deal_Escalated__c,Description__c,DPR_Number__c,isPrimary__c,Mark_as_Variation__c,Opportunity__c,Opportunity__r.Name,Opportunity__r.StageName,Opportunity__r.Account.Name,Parent_DPR__c,Final_Delegation_Outcome__c from Delegated_Pricing_Request__c where Id=:DPRId];
        DelPriceEsclate.currentDelUser = [SELECT Id,Name,Delegation_Role__c  FROM User  WHERE ID=:UserInfo.getUserId()];
        DelPriceEsclate.retVal = getDelegationUserHirerchy(DPRId);
        return DelPriceEsclate;
    }
    
   @Auraenabled
    public static List<DPR_Offer__c> getDPROfferlist(string dprId){
        List<DPR_Offer__c> DPROffer1234 = 
            [SELECT Name,DPR_Offer_Quantity__c,Overridden_Total_Price__c FROM DPR_Offer__c where Delegated_Pricing_Request__c=:dprId ORDER BY CREATEDDATE DESC ];
        
        return DPROffer1234;
    } 
    
    //EDGE:116099 : Delete function.
    @Auraenabled
    public static List<DPR_Offer__c> deleteDPROfferById(string dprId){                                
        List<DPR_Offer__c> DPROffer = 
            [SELECT Name,DPR_Offer_Quantity__c,Overridden_Total_Price__c FROM DPR_Offer__c where Delegated_Pricing_Request__c=:dprId  limit 1];
        delete DPROffer;
        return [SELECT Name,DPR_Offer_Quantity__c,Overridden_Total_Price__c FROM DPR_Offer__c where Delegated_Pricing_Request__c=:dprId ];
    }
    
    //EDGE:118631 | Escalate the deal to the next approving authority.
    @AuraEnabled
    public static List<User> getDelegationUser(String DPRId) {
        List<User> userListDelOut = GBBandDelOutHandler.getDelegationUserList(DPRId); 
        return userListDelOut;
    }
    
    /* Added By Deepak -- Approval Proccess */
    @AuraEnabled
    public static List<Integer> getDelegationUserHirerchy(Id DPRId) {
        List<Integer> userListDelOut = GBBandDelOutHandler.getDelegationUserListHirerchy(DPRId);
        return userListDelOut;
    }
    
    // added by Rishabh 5 
    /* Start of EDGE:114439
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to fetch Plan details for Plan Gbb Scale.
    */
    @AuraEnabled
    public static DPR_Offer_Line_Item__c getDPRPlanDetails(String planId) {
        DPR_Offer_Line_Item__c dprPlanDetails = GBBandDelOutHandler.getDPRPlanDetails(planId);
        return dprPlanDetails;
    }
    
    //  added by Rishabh 6 
    /*  Start of EDGE:123727
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to create discount level and discount association records.
    */
    @AuraEnabled
    public static void acceptContract(String dprId) {
        GBBandDelOutHandler.acceptContract(dprId);
    }
    
    //  added by Rishabh 7 
    /*  Start of EDGE:136226
    @Modified/updatedBy: 
    @team : Napier 
    @Description: update the status of Deal as Contract Rejected and Related Contract junction status to Cancelled.
    */
    @AuraEnabled
    public static void rejectContract(String dprId) {
        List<Delegated_Pricing_Request__c> dprList = [select id, Name, Opportunity__c, Deal_Status__c
                                                      from Delegated_Pricing_Request__c
                                                      where id =: dprId];
        if(!dprList.isEmpty()){
        dprList[0].Deal_Status__c = 'Contract Rejected';
        Update dprList;
        }
        
        List<Case> relatedCase = [select id, ContractJunction__c from Case where Deal__c =: dprId];
        
        List<ContractJunction__c> contJunc = [select id, Status__c from ContractJunction__c
                                              where id =: relatedCase[0].ContractJunction__c];
        if(!contJunc.isEmpty()){
        contJunc[0].Status__c = 'Cancelled';
        Update contJunc;
        }
        
        Opportunity opp = [Select Id, StageName from Opportunity where id =: dprList[0].Opportunity__c];
        opp.StageName = 'Define';
        Update opp;
    }
    
    //added for price calculation logic
    public Static void performDPPriceCalculation(List<DPR_Offer_Line_Item__c> planList){
        //Variable to stop recursion
        boolean isExecuted = True;
        //Plan ID Set for which price calculations need to be performed
        Set<Id> updatePlanIds = new Set<Id>();
        //Add on ID Set for which price calculations need to be performed
        Set<Id> updateAddonIds = new Set<Id>();
        //Offer ID Set to fetch datapackplan
        Set<Id> offerIdsForDatapack = new Set<Id>();
        
        //Below for loop extracts all plan ids that need update due to plan, addon or discount change.
        for(DPR_Offer_Line_Item__c DPRLineItemValue : planList){
            updatePlanIds.add(DPRLineItemValue.ID); 
            // offerIdsForDatapack.add(DPRLineItemValue.DPR_Offer__c);
            System.debug('offerIdsForDatapack--------->' +offerIdsForDatapack);
        }
        
        //Fetch plan records that needs update
        Map<String,DPR_Offer_Line_Item__c > PlanMap = new Map<String, DPR_Offer_Line_Item__c>([Select Id,Offer_Type_Name__c,DPR_Offer__c,Delegated_Pricing_Request__c, Quantity__c,Recontracting_Quantity__c,List_Price__c,Total_Recurring_Charge__c,Parent_DPR_Offer_Line_Item_Id__c,DPR_Offer_Line_Item_Type__c, Overridden_Unit_price__c, Overridden_Total_Price__c from DPR_Offer_Line_Item__c where Id IN:updatePlanIds]);
        for(DPR_Offer_Line_Item__c item:PlanMap.values()){
            offerIdsForDatapack.add(item.DPR_Offer__c);
        }
        
        //Fetches Datapack plan for all DPR offers undergoing change.
        Map<String,DPR_Offer__c > OfferMapForDataMack = new Map<String, DPR_Offer__c>([select id, 
                                                                                       name, Data_Pack_Plan__c, Data_Pack_Plan_List_Price__c,
                                                                                       Data_Pack_Plan_Name__c, Delegated_Pricing_Request__c
                                                                                       from DPR_Offer__c where  Data_Pack_Plan__c != null and Id IN:offerIdsForDatapack]);
        
        //Fetch Plan related Addon and Discount DPR offer line item records             
        List<DPR_Offer_Line_Item__c> RelatedAddonDiscountList = new List<DPR_Offer_Line_Item__c>([Select Id,Name,Offer_Type_Name__c,DPR_Offer__c,Delegated_Pricing_Request__c, Quantity__c,Recontracting_Quantity__c,List_Price__c,Total_Recurring_Charge__c,Parent_DPR_Offer_Line_Item_Id__c,DPR_Offer_Line_Item_Type__c, Overridden_Unit_price__c,DPR_Offer_Line_Item_Unit_Type__c,DPR_Offer_Line_Item_Value__c,  Overridden_Total_Price__c from DPR_Offer_Line_Item__c where (Parent_DPR_Offer_Line_Item_Id__c IN:updatePlanIds)]);
        // system.debug('print size'+RelatedAddonDiscountList.size());
        //Below logic is to convert the Related AddOn and Discount records in Map with Key as plan id.
        Map<String, DPR_Offer_Line_Item__c> AddOnMap = new Map<String, DPR_Offer_Line_Item__c>();
        Map<String, List<DPR_Offer_Line_Item__c>> DiscountMap = new Map<String, List<DPR_Offer_Line_Item__c>>();
        List<DPR_Offer_Line_Item__c> DPRDiscountList = null;
        if(RelatedAddonDiscountList != null){  
            for(DPR_Offer_Line_Item__c offerLineItemRecord :RelatedAddonDiscountList){
                if (offerLineItemRecord.DPR_Offer_Line_Item_Type__c == 'AddOn'){
                    AddOnMap.put(offerLineItemRecord.Parent_DPR_Offer_Line_Item_Id__c,offerLineItemRecord);
                }else if (offerLineItemRecord.DPR_Offer_Line_Item_Type__c == 'Discount'){ 
                    if (DiscountMap.containsKey(offerLineItemRecord.Parent_DPR_Offer_Line_Item_Id__c)){   
                        DPRDiscountList = DiscountMap.get(offerLineItemRecord.Parent_DPR_Offer_Line_Item_Id__c);
                        DPRDiscountList.add(offerLineItemRecord);
                        DiscountMap.put(offerLineItemRecord.Parent_DPR_Offer_Line_Item_Id__c,DPRDiscountList);
                    }
                    else {   
                        DPRDiscountList = new List<DPR_Offer_Line_Item__c>();
                        DPRDiscountList.add(offerLineItemRecord);
                        DiscountMap.put(offerLineItemRecord.Parent_DPR_Offer_Line_Item_Id__c,DPRDiscountList);
                    }
                } 
                
            }
        }
        
        //Logic to calculate discount information starts.
        DPR_Offer_Line_Item__c planRecord = null;
        DPR_Offer_Line_Item__c addOnRecord = null;
        List<DPR_Offer_Line_Item__c> discountList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer__c datapackplanOfferRecord = null;
        Map<String,DPR_Offer_Line_Item__c > PlanAddonTobeUpdated = new Map<String,DPR_Offer_Line_Item__c >();
        for(ID planId :updatePlanIds){
            Decimal datapackplan = 0.0;
            Decimal dpDiscount = 0.0;
            Decimal addonPrice = 0.0;
            Decimal addOnDiscount = 0.0;
            planRecord = PlanMap.get(planId);
            addOnRecord = AddOnMap.get(planId);
            discountList =  DiscountMap.get(planId);
            //get datapackplan configuration if plan type is committed data
            if ( planRecord.Offer_Type_Name__c == 'Committed Data') {
                datapackplanOfferRecord = OfferMapForDataMack.get(planRecord.DPR_Offer__c);
                if(datapackplanOfferRecord != null){
                    datapackplan = datapackplan + datapackplanOfferRecord.Data_Pack_Plan_List_Price__c;
                }
            }
            //calculating addon related price information.
            if (addOnRecord != null) {
                addonPrice = addonPrice + addOnRecord.List_Price__c;
            }
            //calculating discount based on discounts mapped against plans.
            if(discountList <> null && !discountList.isEmpty()) {
                for(DPR_Offer_Line_Item__c discountRecord :discountList){
                    if(discountRecord.DPR_Offer_Line_Item_Unit_Type__c == 'Amount' && discountRecord.Name <> 'MRO Bonus Credit'){ 
                        if (discountRecord.Name == 'MMC Discount') {
                            dpDiscount = dpDiscount + discountRecord.DPR_Offer_Line_Item_Value__c/1.1; // EDGE-122345 : MMC Discount GST Exclusive value to be considered
                        } else {
                            dpDiscount = dpDiscount + discountRecord.DPR_Offer_Line_Item_Value__c;
                        }
                    }
                    if(addOnRecord != null && discountRecord.DPR_Offer_Line_Item_Unit_Type__c == 'Percent' && 'IDD Call Pack Discount' == discountRecord.Name ) {
                        addOnDiscount = addOnDiscount + (discountRecord.DPR_Offer_Line_Item_Value__c/100 * addonPrice);
                    }
                }
            }
            //updated plan Record calculation based on discounts and quantity.
            if (planRecord != null){
                planRecord.Overridden_Unit_price__c = planRecord.List_Price__c + datapackplan + addonPrice - dpDiscount - addOnDiscount ;
                Decimal quantityP = 0;
                quantityP = planRecord.Quantity__c + planRecord.Recontracting_Quantity__c;
                /*Change by badri Starts*/
                Decimal GrossVal =0;
                GrossVal = planRecord.List_Price__c + addonPrice + datapackplan;
                planRecord.Gross_Value__c = GrossVal * quantityP;
                /*Change by badri Ends*/
                Decimal TotalPrice = planRecord.Overridden_Unit_price__c * quantityP;
                planRecord.Overridden_Total_Price__c = TotalPrice.setScale(2);  /* updated by badri to round off to 2 decimal places */   
                planRecord.Total_Recurring_Charge__c = planRecord.List_Price__c;
                PlanAddonTobeUpdated.put(planRecord.id, planRecord);
                if (addOnRecord != null){
                    //updated addOn Record calculation based on discounts and quantity.
                    addOnRecord.Overridden_Unit_price__c = addOnRecord.List_Price__c - addOnDiscount;
                    Decimal quantityA = 0;
                    quantityA = addOnRecord.Quantity__c + addOnRecord.Recontracting_Quantity__c;
                    addOnRecord.Overridden_Total_Price__c =  addOnRecord.Overridden_Unit_price__c * quantityA;
                    addOnRecord.Total_Recurring_Charge__c = addOnRecord.List_Price__c;
                    PlanAddonTobeUpdated.put(addOnRecord.id, addOnRecord);  
                }
            }   
        }
        
        if(!PlanAddonTobeUpdated.values().IsEmpty())
            update PlanAddonTobeUpdated.values();   
    }  
    
    /* Start of EDGE:120087
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to clear pre responses for edit case. */
    public static void clearPREResponse(string dprId, string dprOfferId){
        
        Delegated_Pricing_request__c  dpr = [Select Deal_Status__c,Final_Delegation_Outcome__c,Total_Deal_Monthly_Value__c from Delegated_Pricing_request__c where Id =:dprId ];
        string dprStatus = dpr.Deal_Status__c;
        If(!dprStatus.equalsIgnoreCase('Draft')){
            DPR_Offer__c dprOffer = [SELECT ActualOfferPrice__c, BestMaxValue__c,BetterBestValue__c, GoodBetterValue__c, MarginalGoodValue__c, MinimalMarginalValue__c, PoorMinimalValue__c FROM DPR_Offer__c WHERE Id = :dprOfferId];
            List<Id> offerIdList = new List<Id>();  
            if(dprOffer != null){   
                dprOffer.ActualOfferPrice__c = null;
                dprOffer.BestMaxValue__c = null;
                dprOffer.BetterBestValue__c = null;
                dprOffer.GoodBetterValue__c = null;
                dprOffer.MarginalGoodValue__c = null;
                dprOffer.MinimalMarginalValue__c = null;
                dprOffer.PoorMinimalValue__c = null;
                update dprOffer;
                
                List<DPR_Offer_Line_Item__c> dprOfferLineItemList = [SELECT ActualOfferPrice__c, BestMaxValue__c,BetterBestValue__c, GoodBetterValue__c, MarginalGoodValue__c, MinimalMarginalValue__c, PoorMinimalValue__c, DPR_Offer__c FROM DPR_Offer_Line_Item__c where DPR_Offer_Line_Item_Type__c = 'Plan' AND DPR_Offer__c =: dprOffer.Id];
                List<Id> offerLineItemIdList = new List<Id>();
                
                if (dprOfferLineItemList != null) {
                    for(DPR_Offer_Line_Item__c dprOLI : dprOfferLineItemList){
                        dprOli.ActualOfferPrice__c = null;
                        dprOli.BestMaxValue__c = null;
                        dprOli.BetterBestValue__c = null;
                        dprOli.GoodBetterValue__c = null;
                        dprOli.MarginalGoodValue__c = null;
                        dprOli.MinimalMarginalValue__c = null;
                        dprOli.PoorMinimalValue__c = null;
                        offerLineItemIdList.add(dprOli.Id);
                    }      
                }
                if(dprOfferLineItemList.size() > 0)
                    update dprOfferLineItemList;
                
                List<DPR_Delegation_Outcome__c> dprDelegationOutcomeList = [select id from DPR_Delegation_Outcome__c where Delegated_Pricing_Request__c = :dprId AND DPR_Offer__c =: dprOffer.Id];
                if(dprDelegationOutcomeList != null && dprDelegationOutcomeList.size() > 0)
                    delete dprDelegationOutcomeList;
                
                List<DPR_GBB_Report_Detail__c> gbbReportDetailList = [select Id from DPR_GBB_Report_Detail__c where DPR_Offer_Line_Item__c IN : offerLineItemIdList ]; 
                if(gbbReportDetailList != null && gbbReportDetailList.size() > 0)
                    delete gbbReportDetailList;
                
                dpr.Deal_Status__c = 'Draft';
                dpr.StatusCode__c = null;
                dpr.Error_Message__c = null;
                dpr.Final_Delegation_Outcome__c = null;
                update dpr;
            }
        }
    }
    
    //EDGE:114351 | Get Delegated Pricing details.
    @AuraEnabled
    public static Id getRecordTypeIdbyName(String objectName, String strRecordTypeName) {
        // return  Schema.getGlobalDescribe().get(objectName).getDescribe().getRecordTypeInfosByName().get(strRecordTypeName).getRecordTypeId();
        Id devRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Pricing Support').getRecordTypeId();
        return devRecordTypeId;   
    }
    
    // added by Rishabh 7 
    /* Start of EDGE:123727
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to generate unique correlation Id.
    */
    @AuraEnabled
    public static String getDPRCorrelationID(){
        String correlationId = EDISSingleManager.getUID();
        return correlationId;
    }
    
    /* Start of EDGE:117703
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to save record DPR offer object. */
    @AuraEnabled
    public static string upsertDPROffer(String DPRId,String DprOfferId,
                                        String selectedProduct,string hardwareOption,
                                        String offerType,String commitedDataPlan){
                                            //map to store offer against selected product
                                            Map<String,Marketable_Offer__c> mapOfMarketableOffer=new Map<String,Marketable_Offer__c>();
                                            for(Marketable_Offer__c mo:[SELECT Id,Name,Offer_ID__c 
                                                                        FROM Marketable_Offer__c  
                                                                        WHERE Name=:selectedProduct]){
                                                                            mapOfMarketableOffer.put(mo.Name,mo);
                                                                        }
                                            DPR_Offer__c objDPROffer = null;
                                            if(DprOfferId != null && DprOfferId != ''){
                                                clearPREResponse(DPRId,DprOfferId);
                                                objDPROffer = new DPR_Offer__c(id = DprOfferId);
                                            }else{
                                                objDPROffer = new DPR_Offer__c();
                                                objDPROffer.Delegated_Pricing_Request__c = DPRId; 
                                            }
                                            objDPROffer.Name = selectedProduct;
                                            objDPROffer.Hardware_Option__c = hardwareOption;
                                            objDPROffer.Marketable_Offer__c=mapOfMarketableOffer.get(selectedProduct).Id;
                                            
                                            String cmdData=commitedDataPlan;
                                            if(commitedDataPlan=='Select committed data'){
                                                cmdData='';
                                            }
                                            if(cmdData!=null && cmdData != ''){
                                                List<cspmb__Price_Item__c> lstcmtdata=[select id,cspmb__Recurring_Charge__c,Type__c,Plan__c 
                                                                                       from cspmb__Price_Item__c where Plan__c =:cmdData];
                                                objDPROffer.Data_Pack_Plan__c=lstcmtdata[0].id ;
                                                objDPROffer.Data_Pack_Plan_Name__c=cmdData;
                                                objDPROffer.Data_Pack_Plan_List_Price__c=lstcmtdata[0].cspmb__Recurring_Charge__c;
                                            }
                                            //upsert DPR Offer
                                            upsert objDPROffer Id;
                                            string delePRId=objDPROffer.Id;
                                            return delePRId;
                                        }
    
    /* Start of EDGE:117703
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to save record DPR offer Line Item object. */
    @AuraEnabled
    public static List<DelegatedPricingController.PlanAndDiscountWrapper> upsertPlanAndDiscount(String listOfPlansAndDiscounts,/*String listOfPlansAndDiscounts2,*/String selectedProduct, String hardwareOption, String offerType,String commitedDataPlan, String DPRId,/* String MarketableOffer,*/ String DprOfferId){
        List<DelegatedPricingController.PlanAndDiscountWrapper> lstOfPlanAndDiscount=(List<DelegatedPricingController.PlanAndDiscountWrapper>)System.JSON.deserialize(listOfPlansAndDiscounts, List<DelegatedPricingController.PlanAndDiscountWrapper>.class);
        Set<String> setOfPlanIds=new Set<String>();
        Set<String> setOfIdsToDelete=new Set<String>();
        System.debug('commitedDataPlan....'+commitedDataPlan);
        //map to store offer against selected product
        Map<String,Marketable_Offer__c> mapOfMarketableOffer=new Map<String,Marketable_Offer__c>();
        for(Marketable_Offer__c mo:[SELECT Id,Name,Offer_ID__c 
                                    FROM Marketable_Offer__c  
                                    WHERE Name=:selectedProduct]){
                                        mapOfMarketableOffer.put(mo.Name,mo);
                                    }
        
        Map<String,cspmb__Price_Item__c> mapOfPriceItem=new Map<String,cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c pi:[SELECT Id,offer_type__c 
                                     FROM cspmb__Price_Item__c 
                                     WHERE Check_todays_date__c=true 
                                     AND  cspmb__Price_Item_Code__c=:mapOfMarketableOffer.keyset() 
                                     AND   Offer_Id__c=:mapOfMarketableOffer.get(selectedProduct).Offer_ID__c
                                     AND offer_type__c =: offerType]){
                                         mapOfPriceItem.put(pi.offer_type__c,pi);
                                     }
        List<DPOfferId__mdt> ListOfOfferIds=new List<DPOfferId__mdt>();
        for(DPOfferId__mdt dproffer : [SELECT Id,Offer_Id__c,Product_Name__c,Add_on_Prod_Spec_Id__c,Add_on_External_Id__c FROM DPOfferId__mdt WHERE Product_Name__c=:selectedProduct]){
            ListOfOfferIds.add(dproffer);
            system.debug('ListOfOfferIds:::::'+ListOfOfferIds);
        }
        
        Map<String,cspmb__Price_Item__c> mapOfPIvsPlanType=new Map<String,cspmb__Price_Item__c>();
        for(cspmb__Price_Item__c pt:[SELECT Id,Type__c,Plan__c 
                                     FROM cspmb__Price_Item__c 
                                     WHERE Check_todays_date__c=true 
                                     AND Plan__c <> NULL AND Offer_Id__C =: ListOfOfferIds[0].Offer_Id__c AND offer__c =:offerType]){
                                         system.debug('PriceItem'+pt.Id);
                                         String keyOfPlanAndType=pt.Type__c+pt.Plan__c;                          
                                         mapOfPIvsPlanType.put(keyOfPlanAndType,pt);                          
                                     }
        system.debug('MapOfPriceItem::::::::::'+mapOfPIvsPlanType);
        //Osaka Start of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC
        string selectedAddon;
        string selectedPlan;
        //Osaka end of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC        
        string delePRId=DprOfferId;
        Map<string,DPR_Offer_Line_Item__c> mapOfPlanItem=new Map<string,DPR_Offer_Line_Item__c>();
        Set<String> selectedAddOnn=new Set<String>();
        Set<String> PriceItemIds=new Set<String>();
        Set<String> DelDiscountByIds=new Set<String>();
        if(lstOfPlanAndDiscount.size()>0){
            for(DelegatedPricingController.PlanAndDiscountWrapper pdwrapp:lstOfPlanAndDiscount){
                //Osaka Start of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC
                //Taking Plan and Addon from lstOfPlanAndDiscount
                selectedAddon =pdwrapp.AddOn;
                selectedPlan =pdwrapp.Qplan;
                system.debug('----->selectedAddon'+selectedAddon);
                system.debug('----->selectedPlan'+selectedPlan);
                // Osaka End of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC                
                if(delePRId!=null && delePRId!=''){
                    pdwrapp.DPROfferId=delePRId;
                }
                //logic to upsert Plans
                if(offerType!=null && pdwrapp.PlanType!=null && pdwrapp.QPlan!=null){
                    String planKey=delePRId+offerType+pdwrapp.PlanType+pdwrapp.QPlan;
                    System.debug('planKey....'+planKey);
                    String ppTypekey=pdwrapp.PlanType+pdwrapp.QPlan;
                    System.debug('ppTypekey....'+ppTypekey);
                    DPR_Offer_Line_Item__c plan=null;
                    if(pdwrapp.PlanId!=null && pdwrapp.PlanId!=''){
                        plan=new DPR_Offer_Line_Item__c(Id=pdwrapp.PlanId);
                    }else{
                        plan= new DPR_Offer_Line_Item__c(); 
                        plan.DPR_Offer__c=pdwrapp.DPROfferId;
                        plan.Delegated_Pricing_Request__c = DPRId; 
                    }
                    plan.Unique_Key_to_Update__c=planKey+'Plan';
                    plan.Marketable_Offer__c = mapOfMarketableOffer.get(selectedProduct).Id;
                    plan.Offer_Type_Name__c=offerType;
                    plan.offer_Type__c=mapOfPriceItem.get(offerType).Id;
                    plan.cspmb_Price_Item__c=mapOfPIvsPlanType.get(ppTypekey).Id;
                    System.debug('plan.cspmb_Price_Item__c......'+plan.cspmb_Price_Item__c);
                    plan.Name=pdwrapp.QPlan;
                    plan.DPR_Offer_Line_Item_Type__c ='Plan';
                    plan.DPR_Offer_Line_Item_Unit_Type__c ='Amount';
                    if(pdwrapp.MMC !=null){
                        plan.List_Price__c =Decimal.valueof(pdwrapp.MMC);
                        plan.Total_Recurring_Charge__c =Decimal.valueof(pdwrapp.MMC);
                    }
                    if(pdwrapp.ActivatedSIOs != null && pdwrapp.ActivatedSIOs != ''){
                        plan.Quantity__c = integer.valueof(pdwrapp.ActivatedSIOs);
                    }else{
                        plan.Quantity__c = 0;
                    }
                    if(pdwrapp.RecontractingSIOs !=null && pdwrapp.RecontractingSIOs != ''){
                        plan.Recontracting_Quantity__c=integer.valueof(pdwrapp.RecontractingSIOs);
                    }else{
                        plan.Recontracting_Quantity__c=0;
                    }
                    mapOfPlanItem.put(planKey,plan);
                    PriceItemIds.add(plan.cspmb_Price_Item__c);
                    System.debug('PriceItemIds....'+PriceItemIds);
                }
                //get selected addOn to set total recuring charges
                if(pdwrapp.AddOn!=null){
                    selectedAddOnn.add(pdwrapp.AddOn);
                }
            }
        }
        
        //maps to return add plans & Its discount record Ids to check dublicate records
        Map<String,String> mapOfPlanIds=new Map<String,String>();
        Map<String,String> mapOfAddOnIds=new Map<String,String>();
        Map<String,String> mapOfIddCPDIds=new Map<String,String>();
        Map<String,String> mapOfMWD1Ids=new Map<String,String>();
        Map<String,String> mapOfMWD2Ids=new Map<String,String>();
        Map<String,String> mapOfMWD3Ids=new Map<String,String>();
        Map<String,String> mapOfNBDIds=new Map<String,String>();
        Map<String,String> mapOfMMCIds=new Map<String,String>();
        Map<String,String> mapOfRCMIds=new Map<String,String>();
        Map<String,String> mapOfMROIds=new Map<String,String>();
        Map<String,cspmb__Add_On_Price_Item__c> mapAddOnVsPrizeItemIds=new Map<String,cspmb__Add_On_Price_Item__c>();
        
        Map<String,DiscountVsValueWrapper> mapOfDiscountVsValues=new Map<String,DiscountVsValueWrapper>();
        Map<String,String> mapOfACMDIds=new Map<String,String>();
        
        //maps to upsert plan, addon,Discounds
        Map<string,DPR_Offer_Line_Item__c> mapOfAddOnToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfIddCPDToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfMWD1ToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfMWD2ToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfMWD3ToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfNBDToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfMMCDToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfACMDToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfRCMToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        Map<string,DPR_Offer_Line_Item__c> mapOfMROToUpsert=new Map<string,DPR_Offer_Line_Item__c>();
        
        if(!mapOfPlanItem.isEmpty()){
            //upsert plans record
            upsert mapOfPlanItem.values();
            //collects the inserted plan Ids
            for(DPR_Offer_Line_Item__c dprPlan:mapOfPlanItem.values()){
                mapOfPlanIds.put(dprPlan.Unique_Key_to_Update__c,dprPlan.Id);
                setOfPlanIds.add(dprPlan.Id);
            }
            //Osaka Start of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC
            //Fetch the List Recurring charge from cspmb__Price_Item_Add_On_Price_Item_Association__c
           List<cspmb__Price_Item_Add_On_Price_Item_Association__c> addonAssociation =[select id,cspmb__Recurring_Charge__c from cspmb__Price_Item_Add_On_Price_Item_Association__c 
                                                                                       where cspmb__Add_On_Price_Item__r.name=: selectedAddon 
                                                                                       and cspmb__Price_Item__r.Check_todays_date__c=true  
                                                                                       and Check_todays_date__c = true 
                                                                                       and cspmb__Price_Item__r.Plan__c=: selectedPlan];
            system.debug('---------------->addonAssociation'+addonAssociation);
            //Osaka End of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC             

            //get addOn Prize for selected addOn
            for(cspmb__Add_On_Price_Item__c addOnPrize:[SELECT Id,Name,cspmb__Recurring_Charge__c 
                                                        FROM cspmb__Add_On_Price_Item__c  
                                                        WHERE  Name IN:selectedAddOnn]){
                                                            mapAddOnVsPrizeItemIds.put(addOnPrize.Name,addOnPrize);                                           
                                                        }
            
 
            
            for(cspmb__Discount_Association__c discountPrize:[select ID,Name,cspmb__Discount_Level__c, cspmb__Discount_Level__r.Name, 
                                                        cspmb__Discount_Level__r.cspmb__Discount_Values__c,cspmb__price_item__r.Type__c,cspmb__price_item__r.Plan__c from cspmb__Discount_Association__c where 
                                                        (cspmb__price_item__c in: PriceItemIds and cspmb__Discount_Level__r.Data_Pack_Plan__c =: commitedDataPlan and cspmb__Discount_Level__r.Is_Delegated__c = true and cspmb__Discount_Level__r.Check_todays_date__c = true and cspmb__Discount_Level__r.account__c = null) or
                                                        (cspmb__price_item__c in: PriceItemIds and cspmb__Discount_Level__r.Data_Pack_Plan__c = null and cspmb__Discount_Level__r.Is_Delegated__c = true and cspmb__Discount_Level__r.Check_todays_date__c = true and cspmb__Discount_Level__r.account__c = null)]){
                                                                  system.debug('discountPrize:::::::::::::::'+discountPrize);
                                                                  String ppTypeDiscountkey=discountPrize.cspmb__price_item__r.Type__c+discountPrize.cspmb__price_item__r.Plan__c+discountPrize.cspmb__Discount_Level__r.Name;
                                                                    system.debug('ppTypeDiscountkey:::::::::::'+ppTypeDiscountkey);
                                                                  DiscountVsValueWrapper dvWrap=new DiscountVsValueWrapper();
                                                                  dvWrap.DiscountName=discountPrize.cspmb__Discount_Level__r.Name;
                                                                  dvWrap.DiscountId=discountPrize.cspmb__Discount_Level__c;
                                                                  if(discountPrize.cspmb__Discount_Level__r.cspmb__Discount_Values__c!=null){ 
                                                                      dvWrap.DiscountValues=Decimal.valueOf(discountPrize.cspmb__Discount_Level__r.cspmb__Discount_Values__c);
                                                                  }
                                                                  mapOfDiscountVsValues.put(ppTypeDiscountkey,dvWrap);
                                                                    system.debug('mapOfDiscountVsValues::::::::::'+mapOfDiscountVsValues);
                                                              }
            
            for(DelegatedPricingController.PlanAndDiscountWrapper pdAddOnn:lstOfPlanAndDiscount){
                String planKeyTpUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan;
                String ppTypekey=pdAddOnn.PlanType+pdAddOnn.QPlan;
                //logic to upsert addonn
                if(offerType!=null && pdAddOnn.PlanType!=null && pdAddOnn.QPlan!=null){
                    if(pdAddOnn.AddOn!=null && pdAddOnn.AddOn != 'Select Add On' && pdAddOnn.AddOn != ''){
                        DPR_Offer_Line_Item__c  AddOn = null;
                        if(pdAddOnn.AddOnID!=null && pdAddOnn.AddOnID!=''){
                            AddOn = new DPR_Offer_Line_Item__c(id=pdAddOnn.AddOnID); 
                        }else {
                            AddOn = new DPR_Offer_Line_Item__c(); 
                            AddOn.DPR_Offer__c=pdAddOnn.DPROfferId;
                            AddOn.Delegated_Pricing_Request__c = DPRId; 
                        }
                        AddOn.Unique_Key_to_Update__c=planKeyTpUpdate+'AddOn';
                        AddOn.Marketable_Offer__c = mapOfMarketableOffer.get(selectedProduct).Id;
                        AddOn.Offer_Type_Name__c=offerType;
                        AddOn.offer_Type__c=mapOfPriceItem.get(offerType).Id;
                        AddOn.Name=pdAddOnn.AddOn;
                        AddOn.DPR_Offer_Line_Item_Type__c ='AddOn';
                        AddOn.DPR_Offer_Line_Item_Unit_Type__c ='Amount';
                        AddOn.cspmb_Add_On_Price_Item__c=mapAddOnVsPrizeItemIds.get(pdAddOnn.AddOn).Id;
                        AddOn.cspmb_Price_Item__c=mapOfPIvsPlanType.get(ppTypekey).Id;
                        /*if(pdAddOnn.addOnCount==1){
                            AddOn.List_Price__c =0;
                            AddOn.Total_Recurring_Charge__c =0; 
                        }else*/ if(addonAssociation.size()>0 && !addonAssociation.isempty()){
                            //Osaka Start of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC
                            AddOn.List_Price__c =addonAssociation[0].cspmb__Recurring_Charge__c;
                            AddOn.Total_Recurring_Charge__c = addonAssociation[0].cspmb__Recurring_Charge__c;
                            //Osaka End of EDGE-146942 : Delegate Pricing:Discrepancy in the Add On list price in DP and SC   
                        }
                        if(pdAddOnn.ActivatedSIOs != null && pdAddOnn.ActivatedSIOs != ''){
                            AddOn.Quantity__c = integer.valueof(pdAddOnn.ActivatedSIOs);
                        }else{
                            AddOn.Quantity__c = 0;
                        }
                        if(pdAddOnn.RecontractingSIOs!=null && pdAddOnn.RecontractingSIOs != ''){
                            AddOn.Recontracting_Quantity__c=integer.valueof(pdAddOnn.RecontractingSIOs);
                        }else{
                            AddOn.Recontracting_Quantity__c=0;
                        }
                        AddOn.Parent_DPR_Offer_Line_Item_Id__c =mapOfPlanIds.get(planKeyTpUpdate+'Plan'); 
                        mapOfAddOnToUpsert.put(planKeyTpUpdate,AddOn);
                    }
                }else{
                    //delete existing discont
                    setOfIdsToDelete.add(planKeyTpUpdate+'AddOn');
                    //To delete addon on change of plan
                    if(!String.isBlank(pdAddOnn.AddOnID)){
                        DelDiscountByIds.add(pdAddOnn.AddOnID);
                    }
                    pdAddOnn.AddOnID='';
                }
                
                
                /*------------------------------------------------------------------------------------
    * ----------Discount section start---------------------------------------------------
    * -----------------------------------------------------------------------------------
    * */ 
                //IDD Call Pack Discount
                if(!String.isBlank(pdAddOnn.IDDCallPackDiscount)){
                    String IddCPDKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'IddCPD';
                    String DiscountName ='IDD Call Pack Discount';
                    Map<string, DPR_Offer_Line_Item__c> mapOfIddCPD=prepareDPROfferLineItem(DPRId,IddCPDKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                            DiscountName,selectedProduct,offerType,'Discount','Percent',
                                                                                            pdAddOnn.IDDCallPackDiscountID,
                                                                                            mapOfMarketableOffer,mapOfPIvsPlanType,mapOfPriceItem,
                                                                                            mapOfPlanIds,mapOfDiscountVsValues,pdAddOnn.IDDCallPackDiscount,false,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfIddCPD.values()){
                        mapOfIddCPDToUpsert.put(IddCPDKeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'IddCPD');
                    //To delete IDD discount on change of plan
                    if(!String.isBlank(pdAddOnn.IDDCallPackDiscountID)){
                        DelDiscountByIds.add(pdAddOnn.IDDCallPackDiscountID);
                    }
                    pdAddOnn.IDDCallPackDiscountID='';
                }
                //Mobile Workspace Discount 1
                if(pdAddOnn.MobileWorkspaceDiscount1=='Yes'){
                    String MWD1KeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'MWD1';
                    string DiscountName = 'Mobile Workspace Discount 1';
                    Map<string, DPR_Offer_Line_Item__c> mapOfMWD1=prepareDPROfferLineItem(DPRId,MWD1KeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                          DiscountName,selectedProduct,offerType,'Discount',
                                                                                          'Percent',pdAddOnn.MobileWorkspaceDiscount1ID,
                                                                                          mapOfMarketableOffer,mapOfPIvsPlanType,
                                                                                          mapOfPriceItem,mapOfPlanIds,mapOfDiscountVsValues,
                                                                                          pdAddOnn.MobileWorkspaceDiscount1,true,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfMWD1.values()){
                        mapOfMWD1ToUpsert.put(MWD1KeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'MWD1');
                    //To delete MW1 discount on change of plan
                    if(!String.isBlank(pdAddOnn.MobileWorkspaceDiscount1ID)){
                        DelDiscountByIds.add(pdAddOnn.MobileWorkspaceDiscount1ID);
                    }
                    pdAddOnn.MobileWorkspaceDiscount1ID='';
                }
                
                //Mobile Workspace Discount 2
                if(pdAddOnn.MobileWorkspaceDiscount2=='Yes'){
                    String MWD2KeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'MWD2';
                    string DiscountName = 'Mobile Workspace Discount 2';
                    Map<string, DPR_Offer_Line_Item__c> mapOfMWD2=prepareDPROfferLineItem(DPRId,MWD2KeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                          DiscountName,selectedProduct,offerType,'Discount',
                                                                                          'Amount',pdAddOnn.MobileWorkspaceDiscount2ID,
                                                                                          mapOfMarketableOffer,mapOfPIvsPlanType,
                                                                                          mapOfPriceItem,mapOfPlanIds,mapOfDiscountVsValues,
                                                                                          pdAddOnn.MobileWorkspaceDiscount2,true,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfMWD2.values()){
                        mapOfMWD2ToUpsert.put(MWD2KeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'MWD2');
                    //To delete MW2 discount on change of plan
                    if(!String.isBlank(pdAddOnn.MobileWorkspaceDiscount2ID)){
                        DelDiscountByIds.add(pdAddOnn.MobileWorkspaceDiscount2ID);
                    }
                    pdAddOnn.MobileWorkspaceDiscount2ID='';
                }
                
                //Mobile Workspace Discount 3
                if(pdAddOnn.MobileWorkspaceDiscount3=='Yes'){
                    String MWD3KeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'MWD3';
                    String DiscountName = 'Mobile Workspace Discount 3';
                    Map<string, DPR_Offer_Line_Item__c> mapOfMWD3=prepareDPROfferLineItem(DPRId,MWD3KeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                          DiscountName,selectedProduct,offerType,'Discount',
                                                                                          'Amount',pdAddOnn.MobileWorkspaceDiscount3ID,
                                                                                          mapOfMarketableOffer,mapOfPIvsPlanType,mapOfPriceItem,
                                                                                          mapOfPlanIds,mapOfDiscountVsValues,
                                                                                          pdAddOnn.MobileWorkspaceDiscount3,true,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfMWD3.values()){
                        mapOfMWD3ToUpsert.put(MWD3KeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'MWD3');
                    //To delete MW3 discount on change of plan
                    if(!String.isBlank(pdAddOnn.MobileWorkspaceDiscount3ID)){
                        DelDiscountByIds.add(pdAddOnn.MobileWorkspaceDiscount3ID);
                    }
                    pdAddOnn.MobileWorkspaceDiscount3ID='';
                }
                
                //National BYO Discount
                if(pdAddOnn.NationalBYODiscount=='Yes'){
                    String NBDKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'NBD';
                    String DiscountName = 'National BYO Discount';
                    Map<string, DPR_Offer_Line_Item__c> mapOfNBD=prepareDPROfferLineItem(DPRId,NBDKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                         DiscountName,selectedProduct,offerType,'Discount',
                                                                                         'Amount',pdAddOnn.NationalBYODiscountID,
                                                                                         mapOfMarketableOffer,mapOfPIvsPlanType,
                                                                                         mapOfPriceItem,mapOfPlanIds,mapOfDiscountVsValues,
                                                                                         pdAddOnn.NationalBYODiscount,true,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfNBD.values()){
                        mapOfNBDToUpsert.put(NBDKeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'NBD');
                    //To delete NBY discount on change of plan
                    if(!String.isBlank(pdAddOnn.NationalBYODiscountID)){
                        DelDiscountByIds.add(pdAddOnn.NationalBYODiscountID);
                    }
                    pdAddOnn.NationalBYODiscountID='';
                }
                
                //MMC Discount
                if(!String.isBlank(pdAddOnn.MMCDiscount)){
                    String MMCDKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'MMCD';
                    String DiscountName = 'MMC Discount';
                    Map<string, DPR_Offer_Line_Item__c> mapOfMMCD=prepareDPROfferLineItem(DPRId,MMCDKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                          DiscountName,selectedProduct,offerType,'Discount',
                                                                                          'Amount',pdAddOnn.MMCDiscountID,
                                                                                          mapOfMarketableOffer,mapOfPIvsPlanType,
                                                                                          mapOfPriceItem,mapOfPlanIds,mapOfDiscountVsValues,pdAddOnn.MMCDiscount,false,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfMMCD.values()){
                        mapOfMMCDToUpsert.put(MMCDKeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'MMCD');
                    //To delete MMC discount on change of plan
                    if(!String.isBlank(pdAddOnn.MMCDiscountID)){
                        DelDiscountByIds.add(pdAddOnn.MMCDiscountID);
                    }
                    pdAddOnn.MMCDiscountID='';
                }
                
                //Recontracting Credits Months
                if(!String.isBlank(pdAddOnn.RecontractingCreditsMonthsDiscount)){
                    string DiscountName ='Recontracting Credits Months Discount';
                    String RCMKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'RCM';
                    Map<string, DPR_Offer_Line_Item__c> mapOfRCM=prepareDPROfferLineItem(DPRId,RCMKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                         DiscountName,selectedProduct,offerType,'Discount',
                                                                                         'Credit Months',pdAddOnn.RecontractingCMDiscountID,
                                                                                         mapOfMarketableOffer,mapOfPIvsPlanType,
                                                                                         mapOfPriceItem,mapOfPlanIds,mapOfDiscountVsValues,
                                                                                         pdAddOnn.RecontractingCreditsMonthsDiscount,false,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfRCM.values()){
                        mapOfRCMToUpsert.put(RCMKeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'RCM');
                    //To delete RCM discount on change of plan
                    if(!String.isBlank(pdAddOnn.RecontractingCMDiscountID)){
                        DelDiscountByIds.add(pdAddOnn.RecontractingCMDiscountID);
                    }
                    pdAddOnn.RecontractingCMDiscountID='';
                }
                
                //MROBonusCredit
                if(pdAddOnn.MRO == true){
                    if(!String.isBlank(pdAddOnn.MROBonusCredit)){
                        string DiscountName = 'MRO Bonus Credit';
                        String MROKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'MRO';
                        Map<string, DPR_Offer_Line_Item__c> mapOfMRO=prepareDPROfferLineItem(DPRId,MROKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                             DiscountName,selectedProduct,offerType,'Discount',
                                                                                             'Amount',pdAddOnn.MROBonusCreditID,
                                                                                             mapOfMarketableOffer,mapOfPIvsPlanType,mapOfPriceItem,mapOfPlanIds,
                                                                                             mapOfDiscountVsValues,pdAddOnn.MROBonusCredit,false,mapAddOnVsPrizeItemIds);
                        for(DPR_Offer_Line_Item__c dis:mapOfMRO.values()){
                            mapOfMROToUpsert.put(MROKeyToUpdate,dis);
                        }
                    }
                }else{
                        setOfIdsToDelete.add(planKeyTpUpdate+'MRO');
                        //To delete MRO discount on change of plan
                        if(!String.isBlank(pdAddOnn.MROBonusCreditID)){
                        DelDiscountByIds.add(pdAddOnn.MROBonusCreditID);
                        }
                        pdAddOnn.MROBonusCreditID='';
                    }
                
                //Activation Credit Months Discount
                if(!String.isBlank(pdAddOnn.ActivationCreditsMonthsDiscount)){
                    String ACMDKeyToUpdate=delePRId+offerType+pdAddOnn.PlanType+pdAddOnn.QPlan+'ACMD';
                    String DiscountName = 'Activation Credits Months Discount';
                    Map<string, DPR_Offer_Line_Item__c> mapOfACMD=prepareDPROfferLineItem(DPRId,ACMDKeyToUpdate,planKeyTpUpdate,pdAddOnn,
                                                                                          DiscountName,selectedProduct,offerType,'Discount',
                                                                                          'Credit Months',pdAddOnn.ActivationCreditsMonthsDiscountID,
                                                                                          mapOfMarketableOffer,mapOfPIvsPlanType,mapOfPriceItem,mapOfPlanIds,
                                                                                          mapOfDiscountVsValues,pdAddOnn.ActivationCreditsMonthsDiscount,false,mapAddOnVsPrizeItemIds);
                    for(DPR_Offer_Line_Item__c dis:mapOfACMD.values()){
                        mapOfACMDToUpsert.put(ACMDKeyToUpdate,dis);
                    }
                }else{
                    setOfIdsToDelete.add(planKeyTpUpdate+'ACMD');
                    //To delete ACM discount on change of plan
                    if(!String.isBlank(pdAddOnn.ActivationCreditsMonthsDiscountID)){
                        DelDiscountByIds.add(pdAddOnn.ActivationCreditsMonthsDiscountID);
                    }
                    pdAddOnn.ActivationCreditsMonthsDiscountID='';
                }
            }
            
            if(mapOfAddOnToUpsert!=null){
                //upsert addon Record for the plan
                upsert mapOfAddOnToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfAddOnToUpsert.values()){
                    mapOfAddOnIds.put(add.Unique_Key_to_Update__c,add.Id);
                }
            }
            //upsert IDD Call Pack Discount for the plan
            if(mapOfIddCPDToUpsert!=null){
                upsert mapOfIddCPDToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfIddCPDToUpsert.values()){
                    mapOfIddCPDIds.put(add.Unique_Key_to_Update__c,add.Id);
                }
            }
            //upsert Mobile Workspace Discount 1 for the plan
            if(mapOfMWD1ToUpsert!=null){
                upsert mapOfMWD1ToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfMWD1ToUpsert.values()){
                    mapOfMWD1Ids.put(add.Unique_Key_to_Update__c,add.Id);
                } 
            }
            //upsert Mobile Workspace Discount 2 for the plan
            if(mapOfMWD2ToUpsert!=null){
                upsert mapOfMWD2ToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfMWD2ToUpsert.values()){
                    mapOfMWD2Ids.put(add.Unique_Key_to_Update__c,add.Id);
                } 
            }
            //upsert Mobile Workspace Discount 3 for the plan
            if(mapOfMWD3ToUpsert!=null){
                upsert mapOfMWD3ToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfMWD3ToUpsert.values()){
                    mapOfMWD3Ids.put(add.Unique_Key_to_Update__c,add.Id);
                }   
            }
            //upsert National BYO Discount for the plan
            if(mapOfNBDToUpsert!=null){
                upsert mapOfNBDToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfNBDToUpsert.values()){
                    mapOfNBDIds.put(add.Unique_Key_to_Update__c,add.Id);
                }   
            } 
            //upsert MMC Discount for the plan
            if(mapOfMMCDToUpsert!=null){
                upsert mapOfMMCDToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfMMCDToUpsert.values()){
                    mapOfMMCIds.put(add.Unique_Key_to_Update__c,add.Id);
                }  
            }
            //upsert Activation Credit Months Discount for the plan
            if(mapOfACMDToUpsert!=null){
                upsert mapOfACMDToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfACMDToUpsert.values()){
                    mapOfACMDIds.put(add.Unique_Key_to_Update__c,add.Id);
                }
            }
            //upsert Recontracting Credits Months
            if(mapOfRCMToUpsert!=null){
                upsert mapOfRCMToUpsert.values();
                for(DPR_Offer_Line_Item__c add:mapOfRCMToUpsert.values()){
                    mapOfRCMIds.put(add.Unique_Key_to_Update__c,add.Id);
                } 
            }
            //upsert MRO Bonus credit for plans
            if(mapOfMROToUpsert!=null){
                upsert mapOfMROToUpsert.values();
                for(DPR_Offer_Line_Item__c mro:mapOfMROToUpsert.values()){
                    mapOfMROIds.put(mro.Unique_Key_to_Update__c,mro.Id);
                } 
            }
            
        }
        
        //logic to set all Inserted Ids to wrapper class
        if(lstOfPlanAndDiscount.size()>0){
            for(DelegatedPricingController.PlanAndDiscountWrapper pdAssign:lstOfPlanAndDiscount){
                String planKeyTpUpdate=delePRId+offerType+pdAssign.PlanType+pdAssign.QPlan;
                if(mapOfPlanIds.get(planKeyTpUpdate+'Plan')!=null){
                    pdAssign.PlanId=mapOfPlanIds.get(planKeyTpUpdate+'Plan');
                }
                if(mapOfAddOnIds.get(planKeyTpUpdate+'AddOn')!=null){
                    pdAssign.AddOnID=mapOfAddOnIds.get(planKeyTpUpdate+'AddOn');
                }
                if(mapOfIddCPDIds.get(planKeyTpUpdate+'IddCPD')!=null){
                    pdAssign.IDDCallPackDiscountID=mapOfIddCPDIds.get(planKeyTpUpdate+'IddCPD');
                }
                if(mapOfMWD1Ids.get(planKeyTpUpdate+'MWD1')!=null){
                    pdAssign.MobileWorkspaceDiscount1ID=mapOfMWD1Ids.get(planKeyTpUpdate+'MWD1');
                }
                if(mapOfMWD2Ids.get(planKeyTpUpdate+'MWD2')!=null){
                    pdAssign.MobileWorkspaceDiscount2ID=mapOfMWD2Ids.get(planKeyTpUpdate+'MWD2');
                }
                if(mapOfMWD3Ids.get(planKeyTpUpdate+'MWD3')!=null){
                    pdAssign.MobileWorkspaceDiscount3ID=mapOfMWD3Ids.get(planKeyTpUpdate+'MWD3');
                }
                if(mapOfNBDIds.get(planKeyTpUpdate+'NBD')!=null){
                    pdAssign.NationalBYODiscountID=mapOfNBDIds.get(planKeyTpUpdate+'NBD');
                }
                if(mapOfMMCIds.get(planKeyTpUpdate+'MMCD')!=null){
                    pdAssign.MMCDiscountID=mapOfMMCIds.get(planKeyTpUpdate+'MMCD');
                }
                if(mapOfACMDIds.get(planKeyTpUpdate+'ACMD')!=null){
                    pdAssign.ActivationCreditsMonthsDiscountID=mapOfACMDIds.get(planKeyTpUpdate+'ACMD');
                }
                if(mapOfRCMIds.get(planKeyTpUpdate+'RCM')!=null){
                    pdAssign.RecontractingCMDiscountID=mapOfRCMIds.get(planKeyTpUpdate+'RCM');
                }
                if(mapOfMROIds.get(planKeyTpUpdate+'MRO')!=null){
                    pdAssign.MROBonusCreditID=mapOfMROIds.get(planKeyTpUpdate+'MRO');
                }
            }
        }
        //delete discount if user set it blanks after save
        deletExistingDiscount(setOfIdsToDelete,setOfPlanIds,DelDiscountByIds);
        //post save calculatons for gross & net values for the Plans
        performDPPriceCalculation(mapOfPlanItem.values());
        
        //logic to set values to wrapper
        Map<Id,DPR_Offer_Line_Item__c> mapOfNetAndGross =new Map<Id,DPR_Offer_Line_Item__c>([Select Id,  Gross_Value__c, Overridden_Total_Price__c, DPR_Offer__c  
                                                                                             From DPR_Offer_Line_Item__c
                                                                                             Where Id in : mapOfPlanIds.values()]);
        for(DelegatedPricingController.PlanAndDiscountWrapper wrapNetGross:lstOfPlanAndDiscount){
            if(mapOfNetAndGross!=null){
                DPR_Offer_Line_Item__c itemVal=mapOfNetAndGross.get(wrapNetGross.PlanId);
                if(itemVal.Gross_Value__c!=null && itemVal.Overridden_Total_Price__c!=null){
                    wrapNetGross.GrossValue=string.valueof(itemVal.Gross_Value__c);
                    wrapNetGross.NetValue=string.valueof(itemVal.Overridden_Total_Price__c);
                }
            }
            
        }
        
        return lstOfPlanAndDiscount;
    }
    //prepaire discount values & Ids against Discount Name
    public class DiscountVsValueWrapper{
        @AuraEnabled public String DiscountId;
        @AuraEnabled public Decimal DiscountValues;
        @AuraEnabled public String DiscountName;
        public DiscountVsValueWrapper(){
            DiscountId='';
            DiscountValues=0.0;
            DiscountName='';
        }
    }
    //Wrapper to return UI for save & update Offer, Plans & Discounds
    public class PlanAndDiscountWrapper{
        @AuraEnabled public String OfferType;
        //Plan section
        @AuraEnabled public String PlanId;
        @AuraEnabled public String DPROfferId;
        @AuraEnabled public String PlanType;
        @AuraEnabled public String Qplan;
        @AuraEnabled public String MMC;
        @AuraEnabled public String ActivatedSIOs;
        @AuraEnabled public String RecontractingSIOs;
        @AuraEnabled public boolean MRO;
        
        //AddOn Section
        @AuraEnabled public String AddOn;
        @AuraEnabled public String AddOnID;
        
        //Discount section
        @AuraEnabled public String IDDCallPackDiscount;
        @AuraEnabled public String IDDCallPackDiscountID;
        
        @AuraEnabled public String MobileWorkspaceDiscount1;
        @AuraEnabled public String MobileWorkspaceDiscount1ID;
        
        @AuraEnabled public String MobileWorkspaceDiscount3;
        @AuraEnabled public String MobileWorkspaceDiscount3ID;
        
        @AuraEnabled public String MobileWorkspaceDiscount2;
        @AuraEnabled public String MobileWorkspaceDiscount2ID;
        
        @AuraEnabled public String NationalBYODiscount;
        @AuraEnabled public String NationalBYODiscountID;
        
        @AuraEnabled public String GrossValue;
        @AuraEnabled public String NetValue;
        
        @AuraEnabled public String MMCDiscount;
        @AuraEnabled public String MMCDiscountID;
        @AuraEnabled public String MMCDiscountExGST;
        
        @AuraEnabled public String ActivationCreditsMonthsDiscount;
        @AuraEnabled public String ActivationCreditsMonthsDiscountID;
        
        @AuraEnabled public String RecontractingCreditsMonthsDiscount;
        @AuraEnabled public String RecontractingCMDiscountID;
        
        @AuraEnabled public String MROBonusCredit;
        @AuraEnabled public String MROBonusCreditID;
        
        @AuraEnabled public Integer addOnCount;
        
        public PlanAndDiscountWrapper(){
            OfferType='';
            PlanId='';
            DPROfferId='';
            PlanType='';
            Qplan='';
            MMC='';
            ActivatedSIOs='';
            RecontractingSIOs='';
            MRO=false;
            AddOn='';
            AddOnID='';
            IDDCallPackDiscount='';
            IDDCallPackDiscountID='';
            
            MobileWorkspaceDiscount1='';
            MobileWorkspaceDiscount1ID='';
            
            MobileWorkspaceDiscount3='';
            MobileWorkspaceDiscount3ID='';
            
            MobileWorkspaceDiscount2='';
            MobileWorkspaceDiscount2ID='';
            
            NationalBYODiscount='';
            NationalBYODiscountID='';
            
            GrossValue='';
            NetValue='';
            
            MMCDiscount='';
            MMCDiscountID='';
            MMCDiscountExGST='';
            
            ActivationCreditsMonthsDiscount='';
            ActivationCreditsMonthsDiscountID='';
            
            RecontractingCreditsMonthsDiscount='';
            RecontractingCMDiscountID='';
            
            MROBonusCredit='';
            MROBonusCreditID='';
            
            addOnCount=0;
        }
    }
    /*
    * common function to prepair Discount records for the plans
    ***/
    public static Map<String,DPR_Offer_Line_Item__c> prepareDPROfferLineItem(String DPRId,string DiskeyToUpdate,String planKeyTpUpdate,DelegatedPricingController.PlanAndDiscountWrapper planDiscountObj,
                                                                             string DiscountName,String selectedProduct,String offerType,String ItemType,String UnitType,String DPRofferLineItemId,
                                                                             Map<String,Marketable_Offer__c> mapOfMarketableOffer,Map<String,cspmb__Price_Item__c> mapOfPIvsPlanType,Map<String,cspmb__Price_Item__c> mapOfPriceItem,Map<String,String> mapOfPlanIds,
                                                                             Map<String,DiscountVsValueWrapper> mapOfDiscountVsValues,String DiscountValue,Boolean isPicklist,Map<String,cspmb__Add_On_Price_Item__c> mapAddOnVsPrizeItemIds){
                                                                                 Map<string,DPR_Offer_Line_Item__c> mapDPROfferLineItem=new Map<string,DPR_Offer_Line_Item__c>();
                                                                                 String ppTypeDiscountkey=planDiscountObj.PlanType+planDiscountObj.QPlan+DiscountName;
                                                                                 system.debug('ppTypeDiscountkey:::::::::::'+ppTypeDiscountkey);
                                                                                 system.debug('mapOfDiscountVsValues:::::::::::'+mapOfDiscountVsValues);
                                                                                 String ppTypekey=planDiscountObj.PlanType+planDiscountObj.QPlan;
                                                                                 String DiscountId = mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountId;
                                                                                 DPR_Offer_Line_Item__c item=null;
                                                                                 if(DPRofferLineItemId!=null && DPRofferLineItemId!=''){
                                                                                     item= new DPR_Offer_Line_Item__c(id =DPRofferLineItemId); 
                                                                                 }else {
                                                                                     item= new DPR_Offer_Line_Item__c(); 
                                                                                     item.DPR_Offer__c=planDiscountObj.DPROfferId;
                                                                                     item.Delegated_Pricing_Request__c=DPRId; 
                                                                                 }
                                                                                 item.Unique_Key_to_Update__c=DiskeyToUpdate;
                                                                                 item.Name=DiscountName;
                                                                                 if(item.Name == 'IDD Call Pack Discount'){
                                                                                     item.cspmb_Add_On_Price_Item__c=mapAddOnVsPrizeItemIds.get(planDiscountObj.AddOn).Id;
                                                                                 }
                                                                                 //EDGE:136961: Added to render Save MMC Excl. GST Value
                                                                                 if(item.Name == 'MMC Discount'){
                                                                                     item.MMC_Discount_GST_Exc_Value__c=decimal.valueof(planDiscountObj.MMCDiscountExGST);
                                                                                 }
                                                                                 item.Marketable_Offer__c=mapOfMarketableOffer.get(selectedProduct).Id;
                                                                                 item.Offer_Type__c = mapOfPriceItem.get(offerType).Id;
                                                                                 item.Offer_Type_Name__c =offerType;
                                                                                 item.DPR_Offer_Line_Item_Type__c =ItemType;
                                                                                 item.DPR_Offer_Line_Item_Unit_Type__c =UnitType;
                                                                                 item.cspmb_Price_Item__c=mapOfPIvsPlanType.get(ppTypekey).Id;
                                                                                 item.Parent_DPR_Offer_Line_Item_Id__c=mapOfPlanIds.get(planKeyTpUpdate+'Plan');
                                                                                 if(isPicklist){
                                                                                     if(planDiscountObj.MobileWorkspaceDiscount1 == 'Yes' && mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues!=null){
                                                                                         item.DPR_Offer_Line_Item_Value__c=mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues;
                                                                                     }
                                                                                     if(planDiscountObj.MobileWorkspaceDiscount2 == 'Yes' && mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues!=null){
                                                                                         item.DPR_Offer_Line_Item_Value__c=mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues;
                                                                                     }
                                                                                     if(planDiscountObj.MobileWorkspaceDiscount3 == 'Yes' && mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues!=null){
                                                                                         item.DPR_Offer_Line_Item_Value__c=mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues;
                                                                                     }
                                                                                     if(planDiscountObj.NationalBYODiscount == 'Yes' && mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues!=null){
                                                                                         item.DPR_Offer_Line_Item_Value__c=mapOfDiscountVsValues.get(ppTypeDiscountkey).DiscountValues;
                                                                                     }
                                                                                 }
                                                                                 if(!isPicklist){
                                                                                     item.DPR_Offer_Line_Item_Value__c=decimal.valueof(DiscountValue);
                                                                                 }
                                                                              system.debug('111111111111111111111111111'+DiscountId);
                                                                         if(DiscountId != null){
                                                                                 item.Discount_Level__c=DiscountId;
                                                                       } 
                                                                                 
                                                                                 mapDPROfferLineItem.put(DiskeyToUpdate,item);
                                                                                 return mapDPROfferLineItem;
                                                                             }
    /* Start of 119320,114435,114434
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to fetch MMC Value. */
    @AuraEnabled
    public static List<cspmb__Price_Item__c> fetchMMC(String planType, String plan){
        List<cspmb__Price_Item__c> lstOfPriceItem=[Select Id,cspmb__Recurring_Charge__c,Type__c,Plan__c 
                                                   From cspmb__Price_Item__c
                                                   Where Type__c=:planType and Plan__c=:plan and Check_todays_date__c=true];
        if(lstOfPriceItem.size()>0){
            return lstOfPriceItem;
        }
        return lstOfPriceItem;
    }
    
    /**
     * Start of EDGE:119320,114435,114434
     * @Modified/updatedBy: 
     * @team : Napier 
     * @Description: This method is used to delete plans & discounts on click of delete icon.
     */
    @AuraEnabled
    public static void delePlansAndDiscount(String PlanId,string DPROfferId){
        List<DPR_Offer_Line_Item__c> lstPlans=[Select Id,Delegated_Pricing_Request__c,DPR_Offer__c
                                               From DPR_Offer_Line_Item__c 
                                               where Id=:PlanId OR Parent_DPR_Offer_Line_Item_Id__c=:PlanId];
        if(lstPlans.size()>0){
            clearPREResponse(lstPlans[0].Delegated_Pricing_Request__c,lstPlans[0].DPR_Offer__c);
        }
        
        if(lstPlans.size()>0){
            delete lstPlans;
        }
        
    }
    
    /* Start of EDGE:122835
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to delete plans & discounts on click of delete offer button. */
    @AuraEnabled
    public static void deleteOfferItems(String strLineItem){
        List<DelegatedPricingController.PlanAndDiscountWrapper> lstOfPDToDelete=(List<DelegatedPricingController.PlanAndDiscountWrapper>)System.JSON.deserialize(strLineItem, List<DelegatedPricingController.PlanAndDiscountWrapper>.class);
        system.debug('lstOfPDToDelete-------'+lstOfPDToDelete);
        set<string> planIds=new set<string>();
        if(lstOfPDToDelete.size()>0){
            for(DelegatedPricingController.PlanAndDiscountWrapper pd:lstOfPDToDelete){
                if(String.isNotBlank(pd.PlanId)){
                    planIds.add(pd.PlanId);
                }
            } 
        }
        List<DPR_Offer_Line_Item__c> lstPlan= [select Id,DPR_Offer__c,Delegated_Pricing_Request__c,Offer_Type__c from DPR_Offer_Line_Item__c where Id IN:planIds];
        if(lstPlan.size()>0){
            clearPREResponse(lstPlan[0].Delegated_Pricing_Request__c,lstPlan[0].DPR_Offer__c);
        }
        List<DPR_Offer_Line_Item__c> lstPlans=[Select Id 
                                               From DPR_Offer_Line_Item__c 
                                               where Id IN:planIds OR Parent_DPR_Offer_Line_Item_Id__c IN:planIds];
        if(lstPlans.size()>0){
            delete lstPlans;
        }
    }
    
    /* Start of EDGE:117583,114301
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to fetch all line item values & display on ui on click of edit/view icon. */
    @AuraEnabled
    public static DelegatedPricingController.PlanAndDiscountEditWrapper getEditScreenWrapper(String DPRId, String DPROfferId){
        String CDkey='Committed Data';
        String FDkey='FairPlay Data';
        DelegatedPricingController.PlanAndDiscountEditWrapper wrappToEdit=new DelegatedPricingController.PlanAndDiscountEditWrapper();
        List<DPR_Offer_Line_Item__c> lstPlans=[Select Id,Name,Offer_Type_Name__c,DPR_Offer_Line_Item_Type__c,DPR_Offer__c,
                                               DPR_Offer__r.Name,DPR_Offer__r.Hardware_Option__c,DPR_Offer__r.Data_Pack_Plan_Name__c,
                                               DPR_Offer__r.Marketable_Offer__c,
                                               Delegated_Pricing_Request__c,Unique_Key_to_Update__c,Marketable_Offer__c,
                                               offer_Type__c,cspmb_Price_Item__c,DPR_Offer_Line_Item_Unit_Type__c,
                                               List_Price__c,Total_Recurring_Charge__c,Quantity__c,Recontracting_Quantity__c,
                                               DPR_Offer_Line_Item_Value__c,Gross_Value__c,Overridden_Total_Price__c,MMC_Discount_GST_Exc_Value__c
                                               From DPR_Offer_Line_Item__c 
                                               where Delegated_Pricing_Request__c=:DPRId AND DPR_Offer__c=:DPROfferId];
        system.debug('@@@@@@lstPlans'+lstPlans);
        
        Map<String,String> mapOfPlanVsType=new Map<String,String>();
        for(cspmb__Price_Item__c pi:[SELECT Id,Type__c,Plan__c FROM cspmb__Price_Item__c where Type__c!=null AND Plan__c!=null]){
            mapOfPlanVsType.put(pi.Plan__c,pi.Type__c);
        }
        system.debug('@@@@@@mapOfPlanVsType'+mapOfPlanVsType);
        Map<String,List<DPR_Offer_Line_Item__c>> mapOfCDPlans=new Map<String,List<DPR_Offer_Line_Item__c>>();
        Map<String,List<DPR_Offer_Line_Item__c>> mapOfFDPlans=new Map<String,List<DPR_Offer_Line_Item__c>>();
        if(lstPlans.size()>0){
            for(DPR_Offer_Line_Item__c plan:lstPlans){
                
                if(plan.Offer_Type_Name__c==FDkey){
                    if(mapOfFDPlans.containsKey(FDkey)){
                        mapOfFDPlans.get(FDkey).add(plan);
                    }else{
                        mapOfFDPlans.put(FDkey,new List<DPR_Offer_Line_Item__c>{plan});
                    }
                    wrappToEdit.offerType=plan.Offer_Type_Name__c;
                }
                if(plan.Offer_Type_Name__c==CDkey){
                    if(mapOfCDPlans.containsKey(CDkey)){
                        mapOfCDPlans.get(CDkey).add(plan);
                    }else{
                        mapOfCDPlans.put(CDkey,new List<DPR_Offer_Line_Item__c>{plan});
                    }
                    if(plan.DPR_Offer__r.Data_Pack_Plan_Name__c!=null){
                        wrappToEdit.committedDataPlan=plan.DPR_Offer__r.Data_Pack_Plan_Name__c;
                        wrappToEdit.offerType=plan.Offer_Type_Name__c;
                    }
                }
                if(plan.DPR_Offer__c!=null){
                    wrappToEdit.DPROfferId=plan.DPR_Offer__c;
                    wrappToEdit.product=plan.DPR_Offer__r.Name;
                    wrappToEdit.hardwareOption=plan.DPR_Offer__r.Hardware_Option__c; 
                }
            }
        }
        if(mapOfCDPlans!=null){
            List<DelegatedPricingController.PlanAndDiscountWrapper> lstCDWrapp=prepareWrapperForEditScreen(mapOfCDPlans,mapOfPlanVsType,CDkey);
             system.debug('@@@@@@lstCDWrapp'+lstCDWrapp);
            if(lstCDWrapp.size()>0){
                wrappToEdit.lstOfCDPlans=lstCDWrapp;
            }
        }
        if(mapOfFDPlans!=null){
            List<DelegatedPricingController.PlanAndDiscountWrapper> lstFDWrapp=prepareWrapperForEditScreen(mapOfFDPlans,mapOfPlanVsType,FDkey);
           system.debug('@@@@@@lstFDWrapp'+lstFDWrapp);
            if(lstFDWrapp.size()>0){
                wrappToEdit.lstOfFDPlans=lstFDWrapp;
            }
        }
        return wrappToEdit;
    }
    
    /* #Manish
    * Wrapper class for the edit Screen
    * */
    public class PlanAndDiscountEditWrapper{
        @AuraEnabled public string product;
        @AuraEnabled public string hardwareOption;
        @AuraEnabled public string offerType;
        @AuraEnabled public string committedDataPlan;
        @AuraEnabled public string DPROfferId;
        @AuraEnabled public List<DelegatedPricingController.PlanAndDiscountWrapper> lstOfCDPlans;
        @AuraEnabled public List<DelegatedPricingController.PlanAndDiscountWrapper> lstOfFDPlans;
        public PlanAndDiscountEditWrapper(){
            lstOfCDPlans=new List<DelegatedPricingController.PlanAndDiscountWrapper>();
            lstOfFDPlans=new List<DelegatedPricingController.PlanAndDiscountWrapper>();
        }
    }
    
    public static List<DelegatedPricingController.PlanAndDiscountWrapper> prepareWrapperForEditScreen(Map<String,List<DPR_Offer_Line_Item__c>> mapOfPDPlans,Map<String,String> mapOfPlanVsType,String CDkey){
        List<DelegatedPricingController.PlanAndDiscountWrapper> lstPDWrapp=new List<DelegatedPricingController.PlanAndDiscountWrapper>();
        Map<String,DPR_Offer_Line_Item__c> mapOfPDToAssign=new  Map<String,DPR_Offer_Line_Item__c>();
        if(mapOfPDPlans!=null){
            List<DPR_Offer_Line_Item__c> PDItem=mapOfPDPlans.get(CDkey);
            if(PDItem!=null && PDItem.size()>0){
                for(DPR_Offer_Line_Item__c lineItem:PDItem){
                    if(lineItem.Unique_Key_to_Update__c!=null){
                        mapOfPDToAssign.put(lineItem.Unique_Key_to_Update__c,lineItem);
                    }
                } 
            }
        }
        List<DPR_Offer_Line_Item__c> lstOfPDPlans=new List<DPR_Offer_Line_Item__c>();
        if(mapOfPDToAssign!=null){
            for(DPR_Offer_Line_Item__c pl:mapOfPDToAssign.values()){
                if(pl.DPR_Offer_Line_Item_Type__c=='Plan'){
                    lstOfPDPlans.add(pl);
                }
            }
        }
        if(lstOfPDPlans.size()>0){
            for(DPR_Offer_Line_Item__c plan:lstOfPDPlans){
                DelegatedPricingController.PlanAndDiscountWrapper cdWrapp=new DelegatedPricingController.PlanAndDiscountWrapper();
                String planType=mapOfPlanVsType.get(plan.Name);
                String planKey=plan.DPR_Offer__c+plan.Offer_Type_Name__c+planType+plan.Name;
                if(mapOfPDToAssign!=null){
                    DPR_Offer_Line_Item__c item=mapOfPDToAssign.get(planKey+'Plan'); 
                    if(item!=null){
                        if(item.DPR_Offer_Line_Item_Type__c=='Plan'){
                            System.debug('item'+item);
                            cdWrapp.Qplan=item.Name;
                            cdWrapp.PlanId=item.Id;
                            cdWrapp.DPROfferId=item.DPR_Offer__c;
                            cdWrapp.PlanType=planType;
                            cdWrapp.MMC=String.valueof(item.List_Price__c);
                            cdWrapp.ActivatedSIOs=String.valueOf(item.Quantity__c);
                            cdWrapp.RecontractingSIOs=String.ValueOf(item.Recontracting_Quantity__c);
                            cdWrapp.GrossValue=String.valueof(item.Gross_Value__c);
                            cdWrapp.NetValue=String.valueof(item.Overridden_Total_Price__c);
                        }
                    }
                }
                String planKeyToUpdate=plan.DPR_Offer__c+plan.Offer_Type_Name__c+planType+plan.Name;
                DPR_Offer_Line_Item__c addOnitem=mapOfPDToAssign.get(planKeyToUpdate+'AddOn');
                if(addOnitem!=null){
                    if(addOnitem.DPR_Offer_Line_Item_Type__c =='AddOn'){
                        cdWrapp.AddOn=addOnitem.Name;
                        cdWrapp.AddOnID=addOnitem.Id;
                    }
                }
                DPR_Offer_Line_Item__c IddCPDitem=mapOfPDToAssign.get(planKeyToUpdate+'IddCPD');
                if(IddCPDitem!=null){
                    String DiscountName1 ='IDD Call Pack Discount';
                    if(IddCPDitem.Name==DiscountName1){
                        cdWrapp.IDDCallPackDiscount=String.valueof(IddCPDitem.DPR_Offer_Line_Item_Value__c);
                        cdWrapp.IDDCallPackDiscountID=IddCPDitem.Id;
                    }   
                }  
                DPR_Offer_Line_Item__c MWD1item=mapOfPDToAssign.get(planKeyToUpdate+'MWD1');
                if(MWD1item!=null){
                    string DiscountName2 = 'Mobile Workspace Discount 1';//PICKLIST
                    if(MWD1item.Name==DiscountName2){
                        if(MWD1item.DPR_Offer_Line_Item_Value__c!=null){
                            cdWrapp.MobileWorkspaceDiscount1='Yes';
                            cdWrapp.MobileWorkspaceDiscount1ID=MWD1item.Id; 
                        }
                    }  
                }
                DPR_Offer_Line_Item__c MWD2item=mapOfPDToAssign.get(planKeyToUpdate+'MWD2');
                if(MWD2item!=null){
                    string DiscountName3 = 'Mobile Workspace Discount 2';//PICKLIST
                    if(MWD2item.Name==DiscountName3){
                        if(MWD2item.DPR_Offer_Line_Item_Value__c!=null){
                            cdWrapp.MobileWorkspaceDiscount2='Yes';
                            cdWrapp.MobileWorkspaceDiscount2ID=MWD2item.Id; 
                        }
                    }   
                }    
                DPR_Offer_Line_Item__c MWD3item=mapOfPDToAssign.get(planKeyToUpdate+'MWD3');
                if(MWD3item!=null){
                    String DiscountName4 = 'Mobile Workspace Discount 3';//PICKLIST
                    if(MWD3item.Name==DiscountName4){
                        if(MWD3item.DPR_Offer_Line_Item_Value__c!=null){
                            cdWrapp.MobileWorkspaceDiscount3='Yes';
                            cdWrapp.MobileWorkspaceDiscount3ID=MWD3item.Id; 
                        }
                    }
                }
                DPR_Offer_Line_Item__c NBDitem=mapOfPDToAssign.get(planKeyToUpdate+'NBD');   
                if(NBDitem!=null){
                    String DiscountName5 = 'National BYO Discount';//PICKLIST
                    if(NBDitem.Name==DiscountName5){
                        if(NBDitem.DPR_Offer_Line_Item_Value__c!=null){
                            cdWrapp.NationalBYODiscount='Yes';
                            cdWrapp.NationalBYODiscountID=NBDitem.Id; 
                        }
                    }
                }
                DPR_Offer_Line_Item__c MMCDitem=mapOfPDToAssign.get(planKeyToUpdate+'MMCD');
                if(MMCDitem!=null){
                    String DiscountName6 = 'MMC Discount';
                    if(MMCDitem.Name==DiscountName6){
                        cdWrapp.MMCDiscount=String.valueof(MMCDitem.DPR_Offer_Line_Item_Value__c);
                        //EDGE:136961: Added to render MMC Excl. GST Value to UI
                        cdWrapp.MMCDiscountExGST=String.valueof(MMCDitem.MMC_Discount_GST_Exc_Value__c);
                        cdWrapp.MMCDiscountID=MMCDitem.Id;
                    }
                }
                DPR_Offer_Line_Item__c RCMitem=mapOfPDToAssign.get(planKeyToUpdate+'RCM');
                if(RCMitem!=null){
                    string DiscountName7 ='Recontracting Credits Months Discount';
                    if(RCMitem.Name==DiscountName7){
                        cdWrapp.RecontractingCreditsMonthsDiscount=String.valueof(RCMitem.DPR_Offer_Line_Item_Value__c);
                        cdWrapp.RecontractingCMDiscountID=RCMitem.Id;
                    }
                }
                DPR_Offer_Line_Item__c MROitem=mapOfPDToAssign.get(planKeyToUpdate+'MRO');
                if(MROitem!=null){
                    string DiscountName8 = 'MRO Bonus Credit';
                    if(MROitem.Name==DiscountName8){
                        cdWrapp.MROBonusCredit=String.valueof(MROitem.DPR_Offer_Line_Item_Value__c);
                        cdWrapp.MROBonusCreditID=MROitem.Id;
                        cdWrapp.MRO=true;
                    }  
                }   
                DPR_Offer_Line_Item__c ACMDitem=mapOfPDToAssign.get(planKeyToUpdate+'ACMD');
                if(ACMDitem!=null){
                    String DiscountName9 = 'Activation Credits Months Discount';
                    if(ACMDitem.Name==DiscountName9){
                        cdWrapp.ActivationCreditsMonthsDiscount=String.valueof(ACMDitem.DPR_Offer_Line_Item_Value__c);
                        cdWrapp.ActivationCreditsMonthsDiscountID=ACMDitem.Id;
                    }   
                }
                lstPDWrapp.add(cdWrapp); 
            }
        }
        return lstPDWrapp;
    }
    
    
    public static void deletExistingDiscount(Set<String> keyToDelete,Set<String> planIds,Set<String> DelDiscountByIds){
        
        List<DPR_Offer_Line_Item__c> lstToDelDiscount=[Select Id 
                                                       From DPR_Offer_Line_Item__c
                                                       Where (Unique_Key_to_Update__c IN :keyToDelete
                                                       AND Parent_DPR_Offer_Line_Item_Id__c=:planIds)
                                                        OR Id =: DelDiscountByIds];
       if(lstToDelDiscount.size()>0){
            Delete lstToDelDiscount;
        }
    }
    
    //  added by Rishabh 8 
    /*  Start of EDGE:117699
    @Modified/updatedBy: 
    @team : Napier 
    @Description: This method is used to clone a DPR
    */
    @AuraEnabled
    public static String dprClone(String dprId) {
        String newDPRId = GBBandDelOutHandler.dprClone(dprId);
        return newDPRId;
    }
    
    //Get Contract Support case Record Type
    //EDGE:123784 | Generate the pricing contract after the deal has been approved.
  @AuraEnabled
    public static Id getContractSupportCaseRecordType() {
        Id CSRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Support').getRecordTypeId();
        return CSRecordTypeId;   
    }
    
    //EDGE:123784 | Generate the pricing contract after the deal has been approved. 
   public Static Id cJOrderFormRecordType = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
    @AuraEnabled
    public static String insertContJunc(Delegated_Pricing_Request__c dpRequest){
                Opportunity oppRecord = [Select Id, Name, StageName,AccountId from Opportunity Where id =: dpRequest.Opportunity__c];
                oppRecord.StageName = 'propose';
                update oppRecord;
                dpRequest.Deal_Status__c = 'Contract Initiated';
                update dpRequest;
                List<ContractJunction__c> contJuncList = [Select Id from ContractJunction__c where Related_Deal__c =: dpRequest.id];
        if(!contJuncList.isEmpty()){
            delete contJuncList;
        }
                System.debug('==============>'+dpRequest.Name);
                ContractJunction__c contractRecord = new ContractJunction__c();
                contractRecord.Name = 'CN' + dpRequest.Name.substring(2);
                contractRecord.RecordTypeId = cJOrderFormRecordType;
                contractRecord.Status__c = 'Initiated';
                contractRecord.Related_Deal__c = dpRequest.id;
                contractRecord.Related_Opportunity__c = oppRecord.id;
                contractRecord.Account__c = oppRecord.AccountId;
                insert contractRecord;
                String contJuncId = contractRecord.Id;
                return contJuncId;
                
}
    //EDGE: 136226
     @AuraEnabled
    public static Boolean checkInitCont(Id dprId){
        Boolean check = false;
        Delegated_Pricing_Request__c dpr = [select id, opportunity__c from Delegated_Pricing_Request__c where id =: dprId];
        Id oppId = dpr.opportunity__c;
        
        List<Delegated_Pricing_Request__c> dprList = [select id, deal_status__c from Delegated_Pricing_Request__c
                                                      where opportunity__c =: oppId];
        
        for(Delegated_Pricing_Request__c dpreq: dprList){
            if(dpreq.deal_status__c == 'Contract Initiated'){
                check = true;
            }
        }
        return check;
    }
    //shradha
     @AuraEnabled
    public static Delegated_Pricing_Request__c  updatefaPri(Id FrameId){
        csconta__Frame_Agreement__c Fam=[SELECT Id, csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c FROM csconta__Frame_Agreement__c
                                          WHERE Id = :FrameId];
        
        Delegated_Pricing_Request__c dpr = [select id, deal_status__c from Delegated_Pricing_Request__c where id =: Fam.Delegated_Pricing_Request__c];
        dpr.deal_status__c = 'Contract Initiated';
       update dpr;
        return dpr;
      
    }
    //shradha
      public Static Id cJOrderFormRecordType1 = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId(); 
     @AuraEnabled
    
    public static ContractJunction__c insertContJuncFA(Id frameAgreementId, string signer2, string signer3,AgreementUtilities.AgreementDecision agreementDecision){
        
        List<csconta__Frame_Agreement__c> famList=[SELECT Id,is_Deal_Escalated__c, Name,csconta__Agreement_Name__c,csconta__Status__c, Opportunity__c, Delegated_Pricing_Request__c,Deal_Approver__c,Final_Delegation_Outcome__c FROM csconta__Frame_Agreement__c
                                          WHERE Id = :frameAgreementId LIMIT 1];
                                          
        Delegated_Pricing_Request__c dpr = [SELECT id, name, Opportunity__c from Delegated_Pricing_Request__c where id =:famList[0].Delegated_Pricing_Request__c];                        
        csconta__Frame_Agreement__c fa = new csconta__Frame_Agreement__c(
            Id = famList[0].Id,
            is_Deal_Escalated__c = true,
            csconta__Status__c = 'Contract Initiated');
        update fa;
        System.debug('fa ======= '+fa);
        
        //Insert default recepient record       
        if(famList[0].Delegated_Pricing_Request__c != null){
            FA_DefaultRecipients__c fdr = new FA_DefaultRecipients__c(
               Signatory_1__c= signer2,
               Signatory_2__c = signer3, 
               Deal_Pricing_Request__c = famList[0].Delegated_Pricing_Request__c);
           Insert fdr;
        }
        
        
           
        dpr.is_Deal_Escalated__c= true;
        dpr.Deal_Status__c = 'Contract Initiated';
        update dpr;
        
        System.debug('dpr =========== '+dpr);
        
        //EDGE-190520 FAM Contract Initiation
        //if ( string.isEmpty(signer2) && string.isEmpty(signer3) && string.isEmpty(frameAgreementId) ){
        
       // }
        Opportunity oppRecord = [Select Id, Name, StageName,AccountId from Opportunity Where id =: famList[0].Opportunity__c LIMIT 1][0];
                
        List<ContractJunction__c> contJuncList = [Select Id,Name from ContractJunction__c where Related_Deal__c =: dpr.Id];
        if (!contJuncList.isEmpty()) {
            delete contJuncList;
        }
        //System.debug('==============>'+dpRequest.Name);
        ContractJunction__c contractRecord = new ContractJunction__c();
        contractRecord.Name = 'CN' + famList[0].Name.substring(2);
        contractRecord.RecordTypeId = cJOrderFormRecordType1;
        contractRecord.Status__c = 'Initiated';
        contractRecord.Related_Deal__c = dpr.id;
        contractRecord.Related_Opportunity__c = oppRecord.id;
        contractRecord.Account__c = oppRecord.AccountId;
        insert contractRecord;
        //String contJuncId = contractRecord.Id;
        
        GenerateDelegatedPricingContract.createContract(new List<Delegated_Pricing_Request__c>{dpr},agreementDecision);  //DIGI-24743
        return contractRecord;
        
        

    }

    //EDGE: 136226
     @AuraEnabled
    public static void updateDelPriReq(Id dprId){
        Delegated_Pricing_Request__c dpr = [select id, deal_status__c from Delegated_Pricing_Request__c where id =: dprId];
        dpr.deal_status__c = 'Contract Initiated';
        update dpr;
    }
     //EDGE-145563 : Added to retrive committed data plan charge -->
     @AuraEnabled
    public static Decimal fetchDataPlanCharge(String committedPlan)
    {
    Decimal result;      
    List<cspmb__Price_Item__c> dataChargeList=[SELECT Id,Type__c,Plan__c,Offer_Type__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c where Type__c!=null AND Plan__c!=null and Offer_Type__c='Committed Data' and Check_todays_date__c=true and Plan__c=:committedPlan];    
    if (!dataChargeList.isEmpty())    {
     result=dataChargeList[0].cspmb__Recurring_Charge__c;
    }
    return result;
    }
    
       //EDGE-145558: Added to retrive addon charge -->
     @AuraEnabled
    public static Decimal fetchAddonDataCharge(String directDialValue, string planDataValue)
    {
    Decimal result;
    List<cspmb__Price_Item_Add_On_Price_Item_Association__c> dataChargeList=[select id,cspmb__Recurring_Charge__c from cspmb__Price_Item_Add_On_Price_Item_Association__c where cspmb__Add_On_Price_Item__r.name=: directDialValue and cspmb__Price_Item__r.Check_todays_date__c=true  and Check_todays_date__c = true and cspmb__Price_Item__r.Plan__c=: planDataValue];    
    if (!dataChargeList.isEmpty())    {
     result=dataChargeList[0].cspmb__Recurring_Charge__c;
    }
    return result;
    }
    //EDGE-190520 FAM Contract Initiation - calls getDocuSignRestrictedFlag and returns DocuSignRestrictedFlag in json format on GenerateContract method on FAMCustomResource.js
    global Object performAction(String param) {
        Map <String, Object> inputMap = (Map <String, Object>) JSON.deserializeUntyped(param);
        System.debug('value actual '+(String) inputMap.get('method'));
        if ((String) inputMap.get('method') == 'getDocuSignRestrictedFlag') {
            String acId = (String) inputMap.get('acId');
            return getDocuSignRestrictedFlag((Id)acId);
        }
        return null;
    }

    //@RemoteAction
    //Gunjan EDGE-186588 Stop automated case creation for non Docusign restricted customers
    //EDGE-190520 FAM Contract Initiation - returns DocuSignRestrictedFlag value and other account owner details on FAMCustomResource.js
    @AuraEnabled
    public static String getDocuSignRestrictedFlag(Id acId){
        Account accLst = [select APTPS_DocuSign_Restricted__c, Owner.Id, Owner.Name from Account where id =: acId];
        return JSON.serialize(accLst);
    }
    
    /*
    *@Created By : Kamlesh Kumar
    *@Created Date : 17/3/2021
    *@Breif : EDGE : 200438 Fetches the group details
    */
    @AuraEnabled
    public static List<Group> fetchGroupDetails(String name, String groupType){
      try{
        List<Group> groupList = new List<Group>();
        groupList = GenericUtilityClass.fetchGroupTypeDetails(name,groupType);
        return groupList;
        }catch(Exception e) {
           return null;
        }
    }
    /*
    *@Created By : Parmanand Shete
    *@Created Date : 11/5/2021
    *@Breif : EDGE-212164
    */
    @AuraEnabled
    public static List<DPR_Offer__c> getDPROfferRecords(String FA_Id){
      try{
            String DPROffers = FAM_DPR_Utility.getDPRRecords(FA_Id);
            List<DPR_Offer__c> Dpr_offer_list = (List<DPR_Offer__c>)JSON.deserialize(DPROffers, List<DPR_Offer__c>.class);
            return Dpr_offer_list;
        }catch(Exception e) {
           return null;
        }
    }
     /*
    *@Created By : Madhu Gaurav
    *@Created Date : 11/10/2021
    *@Breif : DIGI-24743
    */
    @AuraEnabled
    public static AgreementUtilities.AgreementDecision resolveSAType(String DPRId){
        Delegated_Pricing_Request__c dprobj=[Select Id,Opportunity__r.Contract_Type__c, Account__c,Name,Opportunity__c From Delegated_Pricing_Request__c Where Id=:DPRId limit 1]; 
        AgreementUtilities.AgreementDecision decision =AgreementDealUtilities.resolveSAType(dprobj);
        return decision;
    }
}
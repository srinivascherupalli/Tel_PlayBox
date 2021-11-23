/**================================================================
 * Appirio, Inc
 * Name: BillingUtility
 * Description: Class to build Request and Parse Response from Billing API (BDS)
 * Created Date: June 04, 2020
 * Created By: Gaurang Maheshwari
1.  Pawan                 30/06/2020      EDGE-156163
2.  Vaibhav Deshpande     17/07/2020      EDGE-148819
3.  Vaibhav Deshpande     21/07/2020      EDGE-153454
4.  Vaibhav Deshpande     22/07/2020      EDGE-156163 code revert
5.  Suyash Chiplunkar     23/07/2020      DPG-2000 Added to send raterow in RTB
6.  Vaibhav Deshpande     13/08/2020      EDGE-169970 fix
7.  Prajakta Patil        28/08/2020      EDGE-172511
8.  Prajakta Patil        2/09/2020       EDGE-173790 
9.  Pawan Devaliya        04-Sep-202      EDGE-164355
10.  Shresth Dixit         9/09/2020       DPG-2649
11. Vaibhav Deshpande     09/09/2020      EDGE-165967
12. RaviTeja              26/10/2020      EDGE-186075
14. Prajakta              30/10/2020      EDGE-174931
15. Shresth Dixit         06/11/2020       DPG-3420
16. Akanksha Jain      16/12/2020    EDGE-187676
17. Vaibhav Deshpande     16/12/2020      EDGE-187676
18. Mukta Wadhwani        19/01/2021      EDGE-189327
19. Vivek Makkar          19/01/2021      EDGE-189763
20. Mukta Wadhwani        26-02-2021      EDGE-206052
21. Vaibhav Deshpande     12/03/2021      EDGE-152475
22. Sayantan Halder       18/03/2021      EDGE-204321(Rolled Back)
23. Ankit Goswami         30/03/2021      EDGE-210940
24. Vaibhav               26/04/2021      INC000095547173 fix
25 Sayantan Halder        27/04/2021      EDGE-216659(To Roll Back EDGE-204321)
26 Prajakta               20/04/2021      EDGE-205522 added code for CoBA Payload generation
27 Prajakta               17/05/2021      EDGE-218310 COBA Fix
28 Mukta                  18/05/2021      EDGE-218386 Custom rate block generation for negotiated prices NGUC.
29 Akanksha               25/05/2021      Added code to send req as array to BDS
30 Prajakta               25/06/2021      EDGE-226097 Fix
31 Dharmik                09/08/2021      DIGI-2569 Right to Bill for IoT Shared Date Plans 
32 Nikhil Sharma		  13/08/2021	  DIGI-4641 DMS | RTB updates to Billing System
33 Akanksha				  26/08/2021	  DIGI-14510 set modelChangeOrder  flag to false for SIM replacement order
34 Akanksha               07/09/2021      DIGI-20023 added code to send unit price in price alteration block for HRO and MRO scenario
35 Aman Gupta             08/09/2021      DIGI-20885 
36.Vijaya                 10/08/2021      DIGI-28478	To generate custom rate block in RTB Payload for IoT.
37.Arun                   10/08/2021      DIGI-31594	To Set action Code in RTB Payload for IoT
38.Monali                 19/10/2021      DIGI-22519    AMMS intune offer change for rate card generation
==================================================================*/
public with sharing Virtual class BillingUtility {
    public Map<Id, csord__Subscription__c> subscriptionMap { get; set; }
    public Map<Id,list<csord__Subscription__c>> solutionToSubsMap { get; set; } // EDGE-187676 added
    public Map<Id, csord__Service__c> serviceMap { get; set; }
    private boolean isIncludeSolution { get; set; }
    private boolean isProductExpire { get; set; }
    private Map<Id, Map<String, List<Price_Schedule_Line_Item__c>>> serviceIdToListPriceSchedule { get; set; }
    private Map<Id, List<Tier_Line_Item__c>> priceScheduleToListTierLineItems { get; set; }
    //private Map<Id, Map<String, Object>> subscriptionInformation { get; set; }
    private Map<Id, csord__Subscription__c> mapParentSubToSolution { get; set; }
    public Map<Id, List<Id>> mapSubscriptionTolistServiceIds { get; set; }
    //private Map<Id, Attachment> serviceAttachmentMap { get; set; }
  private Map<Id, BLOB> serviceAttachmentMap { get; set; }
    private Map<String, String> orderTypeactioncodeMap { get; set; }
    private Map<Id, List<Number__c>> mapPCToNumberList { get; set; }
    public String handlerName;
    public Map<Id, List<Charge_Line_Item__c>> mapServiceToCLIs { get; set; }
    public Map<Id, List<Discount_Line_Item__c>> mapCLIsToDLIs { get; set; }
    public Map<Id, List<Price_Schedule_Line_Item__c>> mapCLIsToPSLIs { get; set; }
    public Map<Id, List<Tier_Line_Item__c>> mapPSLIsToTLIs { get; set; }
    public Map<String, List<Number__c>> mapSubsNumbers { get; set; }
    //private Map < String, String > mapOfferIdSpecId { get; set; }//DIGI-22519
    Set<String> prodSpecSetForRateCard = new Set<String>();//DIGI-22519
    private Map < String, Set<String>> offerSpecCodeMapForRCard { get; set; }//DIGI-22519
    private Map<String,String> offerIdToSolutionTypeMap{get;set;}//DPG-2649
    public Map<Id,Map<Id,Map<Id,Decimal>>> SubscriptionIdRateValueMap ;
    Set<String> prodCharSet = new Set<String>(); //EDGE-165967
    Map<Id, List<cspmb__Rate_Card_Line__c>> commProdToRateCardLineItemMap {get; set;}//DPG-2000
    public RetrieveRateCard.PriceItemWrapper rateCardWrapperObj  {get; set;}//EDGE-189327, EDGE-189763 
    @testVisible
    private Map<String, List<cspmb__Rate_Card_Line__c>> rateCardToRateCardLineItemMap {get; set;}//DPG-2649
    @testVisible
    private Map<Id,Map<String,List<cspmb__Rate_Card_Line__c>>> commercialProductIdRateCardCodeMap{get;set;}//DPG-2649
    GenerateNegoiatedPayload negotiatedPayloadObj = new GenerateNegoiatedPayload();//EDGE-218386
    public BillingUtility(List<Id> subscriptionIds, boolean isIncludeSolution, boolean isProductExpire, String handlerName) {
        Map<String, String> orderTypeactioncodeMap = new Map<String, String>();
        Map<Id, csord__Subscription__c> tempSubscriptionMap = new Map<Id, csord__Subscription__c>(
            [
                SELECT
                    id,
                    Name,
                    triggerBill_RTB__c,
                    eventId__c,
                    csord__Status__c,
                    response_Status_Code__c,
                    MarketableOffer__c,
                    MarketableOffer__r.Offer_ID__c,
                    Billing_Account__c,
                    Billing_Account__r.Status__c,
                    ModelChange__c,
                    csordtelcoa__Replaced_Subscription__r.csord__Order__c,
                    toBeCancelled__c,
                    csordtelcoa__Replaced_Subscription__r.id,
                    csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c,
                    csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c,
                    csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,
                    csordtelcoa__Replaced_Subscription__r.csordtelcoa__Product_Configuration__c,
                    csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                    csordtelcoa__Replaced_Subscription__r.right_to_bill_date__c,
                    csordtelcoa__Replaced_Subscription__c,
                    Site__r.name,
                    Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c,
                    Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c,
                    Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c,
                    csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name,
                    csord__Order__r.csord__Primary_Order__c,
                    csord__Order__r.csord__Primary_Order__r.Billing_Account__c,
                    csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c,
                    csord__Order__r.Billing_Account__c,
                    csord__Order__r.Billing_Account__r.Billing_Account_Number__c,
                    Right_to_Bill_Date__c,
                    csordtelcoa__Subscription_Number__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                    csord__Order__r.csord__Primary_Order__r.Scenario_Type__c,
                    offer__r.offer_spec_id__c,
                    Right_To_Stop_Date__c,
                    csord__Order__r.Scenario_Type__c,
                    MarketableOffer__r.Invoice_Definition__c,
                    Billing_Account__r.Billing_Account_Number__c,
                    cssdm__solution_association__c,
                    isAggregationPoint__c,
                    csord__Order__r.csordtelcoa__Opportunity__c,
                    ContractJunction__r.Name,
                    csord__Order__c,
                    csord__Order__r.csord__Order_Number__c,
                    autoExpiry__c, expiryDuration__c,oldServiceMSISDN__c, /*EDGE-148819 - added autoExpiry__c,expiryDuration__c*/
                    TenancyID__c ,Ready_for_Activation_Date__c,Trigger_RFA__c,  //kiran //EDGE-187676 - added Ready_for_Activation_Date__c 
                    csordtelcoa__Product_Configuration__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c,
                    //csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.name,//EDGE-216659
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__r.BasketType__c,csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c,
                    csordtelcoa__Replaced_Subscription__r.cssdm__solution_association__c,Action_Type__c,customerFacingServiceId__c,
                    csordtelcoa__Replaced_Subscription__r.triggerBill_RTB__c /*DIGI-32340 - ADD Action Type */
                FROM csord__Subscription__c
                WHERE Id IN :subscriptionIds
            ]
        );

        Map<Id, csord__Service__c> tempServiceMap = new Map<Id, csord__Service__c>(
            [
                SELECT
                    Id,
                    Name,
                    csordtelcoa__Service_Number__c,
                    toBeCancelled__c,
                    csordtelcoa__Replaced_Service__c,
                    Scenario_Type__c,
                    csord__Subscription__c,
                    Mobility_Plan__c,
                    Offer_Type__c,
                    csord__Subscription__r.oldServiceMSISDN__c,
                    csordtelcoa__Product_Configuration__c,
                    csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,
                    csord__Subscription__r.Action_Type__c,
            csord__Subscription__r.csord__Status__c  
                FROM csord__Service__c
                WHERE csord__Subscription__c IN :subscriptionIds
            ]
        );
        Map<Id, Blob> tempAttachmentMap = new Map<Id, Blob>();
        for (Attachment att : [SELECT Id, body, parentId FROM Attachment WHERE parentId IN :tempServiceMap.keyset() AND name = :OrchestratorConstants.DataOrchestrationNames.service]) {
            tempAttachmentMap.put(att.parentId, att.body);
        }

        //List<ActionCode_For_RTB__mdt> actionCodeMetadataList = [SELECT action__c, actionCode__c, orderType__c FROM ActionCode_For_RTB__mdt];
        for (ActionCode_For_RTB__mdt actionMetadata : [SELECT action__c, actionCode__c, orderType__c FROM ActionCode_For_RTB__mdt]) {
            orderTypeactioncodeMap.put(actionMetadata.orderType__c + '_' + actionMetadata.action__c, actionMetadata.actionCode__c);
        }
    //List<String> listOfOfferId = new List<String>();
    //DPG-2000
        //Map < String, String > mapOfferIdSpecId = new Map < String, String > ();
        Map < String, String > offerIdToSolutionTypeMap = new Map<String,String>();//DPG-2649
	    Set<String> prodSpecSetForRateCard = new Set<String>(); //DIGI-22519
	    Map<String, Set<String>> offerSpecCodeMapForRCard = new Map<String, Set<String>>();//DIGI-22519

        for (PopulateRateCardBilling__mdt row: [SELECT Offer_Id__c, Spec_Id__c,isChildComponent__c,Solution_Type__c from PopulateRateCardBilling__mdt WHERE useForPopulationInPayload__c = True]) {//DPG-2649 added isChildComponent__c,Solution_Type__c
            //mapOfferIdSpecId.put(row.Spec_Id__c, row.Offer_Id__c);
	        prodSpecSetForRateCard.add(row.Spec_Id__c);//DIGI-22519
	        offerSpecCodeMapForRCard.put(row.Offer_Id__c,prodSpecSetForRateCard);//DIGI-22519
            offerIdToSolutionTypeMap.put(row.Offer_Id__c,row.Solution_Type__c);//DPG-2649
        }    
      
        this.handlerName = handlerName;
        this.subscriptionMap = tempSubscriptionMap;
        this.serviceMap = tempServiceMap;
        this.serviceIdToListPriceSchedule = getpriceScheduleRecordbyServId(subscriptionIds);
        this.priceScheduleToListTierLineItems = getTierLineItems(subscriptionIds);
        //this.subscriptionInformation = populateSubscriptionInfos();
        //this.mapParentSubToSolution = populateSubscriptionInfos(subscriptionIds);
        populateSubscriptionInfos(subscriptionIds);
        this.isProductExpire = isProductExpire;
        this.isIncludeSolution = isIncludeSolution;
        this.serviceAttachmentMap = tempAttachmentMap;
        this.orderTypeactioncodeMap = orderTypeactioncodeMap;
        //this.mapOfferIdSpecId = mapOfferIdSpecId;//DPG-2000
        this.offerIdToSolutionTypeMap = offerIdToSolutionTypeMap;//DPG-2649
	    this.prodSpecSetForRateCard = prodSpecSetForRateCard;//DIGI-22519
        this.offerSpecCodeMapForRCard = offerSpecCodeMapForRCard;//DIGI-22519
        fetchServiceLineItems(subscriptionIds);
      fetchRateCardItems(subscriptionIds);
        //EDGE-187676 adding starts
        system.debug('tempSubscriptionMap.values()'+tempSubscriptionMap.values());
      /*for(csord__Subscription__c subs :tempSubscriptionMap.values())
        {
            if(subscriptionMap.containsKey(subs.cssdm__solution_association__c))
            {
              List<csord__Subscription__c> tempSubList = new list<csord__Subscription__c>();//;subscriptionMap.get(subs.cssdm__solution_association__c);
                tempSubList.add(subs);
                solutionToSubsMap.put(subs.cssdm__solution_association__c,tempSubList);
            }
            else
            {
                system.debug('subs176'+subs);
                solutionToSubsMap.put(subs.cssdm__solution_association__c,new list<csord__Subscription__c>{subs}); //
            }
        }*/
        Set<Id> orderIdSet =new Set<Id>();
        for(csord__Subscription__c subs :tempSubscriptionMap.values())
        { 
            if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                orderIdSet.add(subs.csord__Order__r.id);
            }
        }
        
        Map<Id,list<csord__Subscription__c>> tempsolutionToSubsMap = new Map<Id,list<csord__Subscription__c>>();
        
        for(csord__Subscription__c allSubs: [Select Id,cssdm__solution_association__c,Trigger_RFA__c,csord__status__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csord__Order__r.id from csord__Subscription__c where csord__Order__r.id IN :orderIdSet and csord__status__c = 'Ready For Activation']) // INC000095547173 - added condition in where to filter out sub list
        {
            if(tempsolutionToSubsMap.containsKey(allSubs.cssdm__solution_association__c))
            {
                List<csord__Subscription__c> tempSubList = tempsolutionToSubsMap.get(allSubs.cssdm__solution_association__c);
                tempSubList.add(allSubs);
                tempsolutionToSubsMap.put(allSubs.cssdm__solution_association__c,tempSubList);
            }else{
                tempsolutionToSubsMap.put(allSubs.cssdm__solution_association__c,new list<csord__Subscription__c>{allSubs});
            }
        }
     this.solutionToSubsMap = tempsolutionToSubsMap;
      //EDGE-187676 adding ends
    //tempSubscriptionMap.clear();
    //tempServiceMap.clear();
    //tempAttachmentMap.clear();
    }
    /*
public String getSubName(Id SubId){
String subName = subscriptionMap.get(SubId).Name;
return subName;
}
*/
    private void populateSubscriptionInfos(List<Id> subscriptionIds) {
        Map<Id, Map<String, Object>> subscriptionsInfo = new Map<Id, Map<String, Object>>();
        Set<Id> solutionIds = new Set<Id>();
        Map<Id, csord__Subscription__c> mapParentSubToSolution = new Map<Id, csord__Subscription__c>();
        Map<Id, List<Id>> subscriptionToService = new Map<Id, List<Id>>();
        List<Id> pcIdList = new List<Id>();
        Map<Id, List<Number__c>> mapPCToNumberList = new Map<Id, List<Number__c>>();
        for (csord__service__c service : serviceMap.Values()) {
            if (subscriptionToService.containsKey(service.csord__Subscription__c)) {
                subscriptionToService.get(service.csord__Subscription__c).add(service.Id);
            } else {
                subscriptionToService.put(service.csord__Subscription__c, new List<Id>{ service.Id });
            }
            if (service.csordtelcoa__Product_Configuration__c != null) {
                pcIdList.add(service.csordtelcoa__Product_Configuration__c);
            }
            if (service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c != null) {
                pcIdList.add(service.csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c);
            }
        }
        for (Id subscriptionId : subscriptionIds) {
            if (subscriptionMap.get(subscriptionId).cssdm__solution_association__c != null) {
                solutionIds.add(subscriptionMap.get(subscriptionId).cssdm__solution_association__c);
                solutionIds.add(subscriptionMap.get(subscriptionId).csordtelcoa__Replaced_Subscription__r.cssdm__solution_association__c); //EDGE-152475
            }
        }
        for (csord__Subscription__c subscription : [SELECT Id, Name, cssdm__solution_association__c, toBeCancelled__c, csordtelcoa__Product_Configuration__r.configurationType1__c, csordtelcoa__Subscription_Number__c FROM csord__Subscription__c WHERE cssdm__solution_association__c IN :solutionIds]) {
            if (subscription.csordtelcoa__Product_Configuration__r.configurationType1__c == OrchestratorConstants.ProductConfigType.SolutionComponent || subscription.Name.contains('Unified Communication Tenancy Solution')) {
                mapParentSubToSolution.put(subscription.cssdm__solution_association__c, subscription);
            }
        }
        // Commented as part of EDGE-210940 || start
       /* for (Number__c numberRecord : [SELECT Service_Number__c, Mobile__c, Service_Id__c, Status__c, Start_Range__c, End_range__c, Product_Configuration__c, toBeCancelled__c FROM Number__c WHERE Product_Configuration__c IN :pcIdList AND Status__c IN ('Provisioned','Disconnected' )]) {
            if (mapPCToNumberList.containsKey(numberRecord.Product_Configuration__c)) {
                mapPCToNumberList.get(numberRecord.Product_Configuration__c).add(numberRecord);
            } else {
                mapPCToNumberList.put(numberRecord.Product_Configuration__c, new List<Number__c>{ numberRecord });
            }
        }*/
        // Commented as part of EDGE-210940 || end
        this.mapParentSubToSolution = mapParentSubToSolution;
        this.mapSubscriptionTolistServiceIds = subscriptionToService;
       // this.mapPCToNumberList = mapPCToNumberList; // Commented as part of EDGE-210940
        //return mapParentSubToSolution;
    }

    @TestVisible
    private Map<Id, Map<String, List<Price_Schedule_Line_Item__c>>> getpriceScheduleRecordbyServId(List<Id> subscriptionIds) {
        List<Id> replacedSubsciptionIds = new List<Id>();
        for (Id subscriptionId : subscriptionIds) {
            if (subscriptionMap.get(subscriptionId).csordtelcoa__Replaced_Subscription__c != null) {
                replacedSubsciptionIds.add(subscriptionMap.get(subscriptionId).csordtelcoa__Replaced_Subscription__c);
            }
        }
        Map<Id, Map<String, List<Price_Schedule_Line_Item__c>>> servieToPriceScheduleMap = new Map<Id, Map<String, List<Price_Schedule_Line_Item__c>>>();

        for (Price_Schedule_Line_Item__c priceScheduleRecord : [
            SELECT
                id,
                applicationDuration__c,
                chargeInstance__c,
                fromPeriod__c,
                priority__c,
                status__c,
                toPeriod__c,
                unitPrice__c,
                chargeInstance__r.serviceId__r.csord__Subscription__c,
                chargeInstance__r.BusinessID__c,
                chargeInstance__r.chargeType__c,
                chargeInstance__r.serviceId__r.csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,
                chargeInstance__r.serviceId__c,
                chargeInstance__r.serviceId__r.csordtelcoa__Replaced_Service__c
            FROM Price_Schedule_Line_Item__c
            WHERE chargeInstance__r.serviceId__r.csord__Subscription__c IN :subscriptionIds OR chargeInstance__r.serviceId__r.csord__Subscription__c IN :replacedSubsciptionIds
        ]) {
            Map<String, List<Price_Schedule_Line_Item__c>> tempMap = new Map<String, List<Price_Schedule_Line_Item__c>>();
            if (priceScheduleRecord.chargeInstance__r.serviceId__c != null) {
                if (servieToPriceScheduleMap.containsKey(priceScheduleRecord.chargeInstance__r.serviceId__c)) {
                    tempMap = servieToPriceScheduleMap.get(priceScheduleRecord.chargeInstance__r.serviceId__c);
                    if (tempMap.containsKey(priceScheduleRecord.chargeInstance__r.BusinessID__c)) {
                        List<Price_Schedule_Line_Item__c> lstpriceScheduleRecord = tempMap.get(priceScheduleRecord.chargeInstance__r.BusinessID__c);
                        lstpriceScheduleRecord.add(priceScheduleRecord);
                        tempMap.put(priceScheduleRecord.chargeInstance__r.BusinessID__c, lstpriceScheduleRecord);
                    } else {
                        tempMap.put(priceScheduleRecord.chargeInstance__r.BusinessID__c, new List<Price_Schedule_Line_Item__c>{ priceScheduleRecord });
                    }
                    servieToPriceScheduleMap.put(priceScheduleRecord.chargeInstance__r.serviceId__c, tempMap);
                } else {
                    tempMap.put(priceScheduleRecord.chargeInstance__r.BusinessID__c, new List<Price_Schedule_Line_Item__c>{ priceScheduleRecord });
                    servieToPriceScheduleMap.put(priceScheduleRecord.chargeInstance__r.serviceId__c, tempMap);
                }
            }
        }
        return servieToPriceScheduleMap;
    }

    private Map<Id, List<Tier_Line_Item__c>> getTierLineItems(List<Id> subscriptionIds) {
        Map<Id, List<Tier_Line_Item__c>> pricingSchdleIdToTierLineMap = new Map<Id, List<Tier_Line_Item__c>>();

        for (Price_Schedule_Line_Item__c priceScheduleRecord : [
            SELECT id, chargeInstance__c, applicationDuration__c, chargeInstance__r.serviceId__r.csord__Subscription__c, chargeInstance__r.BusinessID__c, chargeInstance__r.chargeType__c, (SELECT id, FromUnit__c, ToUnit__c, Discounted_Price__c FROM Tier_Line_Items__r)
            FROM Price_Schedule_Line_Item__c
            WHERE chargeInstance__r.serviceId__r.csord__Subscription__c IN :subscriptionIds AND chargeInstance__r.chargeType__c = :System.label.Tiered_Recurring
        ]) {
            pricingSchdleIdToTierLineMap.put(priceScheduleRecord.id, priceScheduleRecord.Tier_Line_Items__r);
        }
        return pricingSchdleIdToTierLineMap;
    }

     public virtual String buildBillPayload(Id subscriptionId,String scenarioType, String targetBAN) {
        String payload = '';
        boolean modelChangeOrder = false;
        String solutionsubNumber = '';
        List<Id> serviceIdList = mapSubscriptionTolistServiceIds.get(subscriptionId);
        //system.debug('serviceIdList===>>>>>'+serviceIdList);
        BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
        csord__subscription__c subscription = subscriptionMap.get(subscriptionId);
         boolean isNonCommOrder=  evaluateNonCommOrder(serviceIdList); // DIGI-14510 added
        if (subscription.ModelChange__c && (isNonCommOrder==false)) // DIGI-14510 modified
        {
            modelChangeOrder = true;
        }
        if (subscription.cssdm__solution_association__c != null) {
            solutionsubNumber = mapParentSubToSolution.get(subscription.cssdm__solution_association__c).csordtelcoa__Subscription_Number__c;
        }
        system.debug('solutionsubNumber' + solutionsubNumber);
        populateMainCharateristics(billingSpecDTOV2, subscription, serviceIdList);

        populateAdditionalBillInfo(billingSpecDTOV2, subscription);

        populateProductOffering(subscription, billingSpecDTOV2, solutionsubNumber, billingSpecDTOV2.productActionType, serviceIdList);

        populateOrderItems(subscription, billingSpecDTOV2, serviceIdList, modelChangeOrder);
    
    system.debug('after billingSpecDTOV2:'+billingSpecDTOV2);
    
    addSpecificToBuildBillPayload(subscription, billingSpecDTOV2,solutionsubNumber,scenarioType,targetBAN); // EDGE-226097 Fix

        //system.debug('billingSpecDTOV2OrderItem=' + billingSpecDTOV2.orderItems);
        payload = Json.serialize(billingSpecDTOV2, true);
         
        system.debug('payload=='+payload);
        return payload;
    }
  public virtual void addSpecificToBuildBillPayload(csord__subscription__c subscription, BillingSpecDTOV2 billingSpecDTOV2,String solutionsubNumber,String scenarioType, String targetBAN){ //EDGE-226097 Fix
    
  }

    private void populateMainCharateristics(BillingSpecDTOV2 billingSpecDTOV2, csord__subscription__c subscription, List<Id> serviceIdList) {
        
        if (isProductExpire) {
            billingSpecDTOV2.productActionType = 'expire';
        } else if (subscription.csordtelcoa__Replaced_Subscription__c != null && subscription.csordtelcoa__Replaced_Subscription__r.csord__Order__c != null && subscription.toBeCancelled__c != 'true') {
            billingSpecDTOV2.productActionType = 'modify';
        } else if (subscription.toBeCancelled__c == 'true') {
            billingSpecDTOV2.productActionType = 'cease';
        } else {
            billingSpecDTOV2.productActionType = 'add';
        }
        for (Id serviceId : serviceIdList) {
            if (serviceMap.get(serviceId).Scenario_Type__c != null) {
                if (serviceMap.get(serviceId).Scenario_Type__c == 'Change of Mobile Number') {
                    billingSpecDTOV2.productActionType = 'modify';
                    break;
                } else if (serviceMap.get(serviceId).Scenario_Type__c.equalsIgnoreCase('Replace SIM')) {
                    billingSpecDTOV2.productActionType = 'modify';
                    break;
                }
            }
        }
        if (subscription.csord__Status__c == 'Ready For Activation') { //EDGE-187676
      billingSpecDTOV2.effectiveDate = subscription.Ready_for_Activation_Date__c;
      billingSpecDTOV2.requestType = 'RFA';
    }else{
      if(subscription.Trigger_RFA__c == true && subscription.Ready_for_Activation_Date__c != null && subscription.csord__Order__r.csordtelcoa__Opportunity__c!=null && subscription.csordtelcoa__Replaced_Subscription__c == null){ //EDGE-200483
        billingSpecDTOV2.requestType = 'RTB'; //EDGE-187676
      }
      if(subscription.toBeCancelled__c == 'true') {
        billingSpecDTOV2.effectiveDate = subscription.Right_To_Stop_Date__c;
      } else {
            billingSpecDTOV2.effectiveDate = subscription.right_to_bill_date__c;
      }
    }
        
        if (subscription.Billing_Account__c != null) {
            billingSpecDTOV2.billingAccountNumber = Long.valueOf(subscription.Billing_Account__r.Billing_Account_Number__c);
        }
        //added as part of EDGE-152475
         if(subscription.Action_Type__c!=null && subscription.Action_Type__c.containsIgnoreCase('chown') && subscription.csordtelcoa__Replaced_Subscription__c!=null && subscription.csordtelcoa__Replaced_Subscription__r.Billing_Account__c != null){
                 billingSpecDTOV2.fromBillingAccountNumber = Long.valueOf(subscription.csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c);
            }
        //added as part of EDGE-216659    
        if (subscription.ContractJunction__r.name != null) {
            billingSpecDTOV2.orderReference = subscription.ContractJunction__r.Name;
        }
    }

    private void populateAdditionalBillInfo(BillingSpecDTOV2 billingSpecDTOV2, csord__Subscription__c subs) {
        List<BillingSpecDTOV2.AdditionalBillInfo> additionalBillInfo = new List<BillingSpecDTOV2.AdditionalBillInfo>();
        BillingSpecDTOV2.AdditionalBillInfo additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
        if (subs.Site__r.name != null) {
            additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
            additionalBillInfoObject.name = 'siteName';
            additionalBillInfoObject.value = subs.Site__r.name;
            additionalBillInfo.add(additionalBillInfoObject);
            billingSpecDTOV2.additionalBillInfo = additionalBillInfo;
            
        //Added by Nikhil as part of DIGI-4641 (DMS | RTB updates to Billing System)   
        }else if (subs.Site__r == null && subs.customerFacingServiceId__c!= null){
            additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
            additionalBillInfoObject.name = 'customerFacingServiceId';
            additionalBillInfoObject.value = subs.customerFacingServiceId__c;
            additionalBillInfo.add(additionalBillInfoObject);
            billingSpecDTOV2.additionalBillInfo = additionalBillInfo;
        }
        /* Added By Kiran for tenancyId to be sent for drill down view in U2C start */
        if(subs.TenancyID__c != null){
             additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
             additionalBillInfoObject.name = 'tenancyId';
             additionalBillInfoObject.value = subs.TenancyID__c;
             additionalBillInfo.add(additionalBillInfoObject);
             billingSpecDTOV2.additionalBillInfo = additionalBillInfo;
        }
       /* Added By Kiran for tenancyId to be sent for drill down view in U2C End */
    }
    public void populateProductOffering(csord__Subscription__c subscription, BillingSpecDTOV2 billingSpecDTOV2, String solutionsubNumber, String productActionType, List<Id> serviceIdList) {
        Boolean isSharedQuantity = false;
        BillingSpecDTOV2.ProductOffering productOffering = new BillingSpecDTOV2.ProductOffering();
        if (subscription.MarketableOffer__r.Invoice_Definition__c != null) {
            productOffering.invoiceDefinition = subscription.MarketableOffer__r.Invoice_Definition__c;
        }
        productOffering.productInstanceId = subscription.csordtelcoa__Subscription_Number__c;
        productOffering.offerId = subscription.MarketableOffer__r.Offer_ID__c;
        productOffering.description = subscription.Name;
    //EDGE-148819 - Start
    if(subscription.autoExpiry__c == true){
      productOffering.autoExpiry = subscription.autoExpiry__c;
      productOffering.expireDurationValue= Integer.valueOf(subscription.expiryDuration__c); 
      productOffering.expireDurationUnit= System.Label.BDSDurationValue;
    }
    //EDGE-148819 - End
        if (solutionsubNumber != null && solutionsubNumber != '') {
            productOffering.offerInstanceId = solutionsubNumber;
        } else {
            productOffering.offerInstanceId = subscription.csordtelcoa__Subscription_Number__c;
        }
        //EDGE-152475
        if(subscription.Action_Type__c!=null && subscription.Action_Type__c.containsIgnoreCase('chown') && subscription.csordtelcoa__Replaced_Subscription__c!=null && subscription.csordtelcoa__Replaced_Subscription__r.cssdm__solution_association__c !=null && mapParentSubToSolution.containsKey(subscription.csordtelcoa__Replaced_Subscription__r.cssdm__solution_association__c)){
            productOffering.fromOfferInstanceId = mapParentSubToSolution.get(subscription.csordtelcoa__Replaced_Subscription__r.cssdm__solution_association__c).csordtelcoa__Subscription_Number__c;  
        }
        if (subscription.isAggregationPoint__c == true) {
            productOffering.isAggregationPoint = 'TRUE';
        }
        for (Id serviceId : serviceIdList) {

      if(serviceMap.containsKey(serviceId)) {
        csord__service__c service = serviceMap.get(serviceId);
        if (service.Mobility_Plan__c != null && service.Offer_Type__c != null) {
          if (
            subscription.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' &&
            subscription.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000646' &&
            subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c == 'DMCAT_ProductSpecification_000420' &&
            (productActionType == 'add' ||
            productActionType == 'cease') &&
            (service.Offer_Type__c == 'Committed Data') &&
            (service.Mobility_Plan__c != 'X-Large Data SIM BYO' &&
            service.Mobility_Plan__c != 'XX-Large Data SIM BYO')
          ) {
            isSharedQuantity = true;
          }
        }
      }
        }
        if (isSharedQuantity == true) {
            productOffering.isSharedQuantity = 'TRUE';
        }
        //End EDGE-115840
        billingSpecDTOV2.ProductOffering = productOffering;
    }

    private void populateOrderItems(csord__Subscription__c subscription, BillingSpecDTOV2 billingSpecDTOV2, List<Id> serviceIdList, boolean modelChangeOrder) {
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = getAllServSpecs(serviceIdList);
        List<BillingSpecDTOV2.OrderItems> orderItemsList = new List<BillingSpecDTOV2.OrderItems>();
        Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> mapServiceIstanceIdToBillSpecList = new Map<String, List<CS_SpecificationDTO.ServiceSpecification>>();
        Map<String, String> mapServiceIstanceIdToBillDescription = new Map<String, String>();
        Map<String, List<String>> mapServiceIstanceIdToBillStatus = new Map<String, List<String>>();

        //populateDataMapForOrderItems(srvSpecMap, codeSpecMap, mapServiceIstanceIdToBillSpecList, mapServiceIstanceIdToBillDescription, mapServiceIstanceIdToBillStatus);
        for (CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : srvSpecMap.get('FULFILMENT')) {
            if (
                fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000263_Fulfilment') ||
                fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000313_Fulfilment') ||
                fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000537_Fulfilment') ||
                fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000966_Fulfilment') ||
        fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_001196_Fulfilment')//EDGE-172511
            ) {
                codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'), fulfillSrvSpec);
            }
        }

        for (CS_SpecificationDTO.ServiceSpecification specification : srvSpecMap.get('BILLING')) {
            system.debug('--00--' + specification.serviceId + '===' + specification.Code + '=====' + specification.status);
            //csord__Service__c serviceRecord = serviceMap.get(specification.serviceId);
            String specCode = specification.Code;
            //String serviceInstanceId = serviceRecord.csordtelcoa__Service_Number__c+':'+specCode.substringBefore('_Bill');
            String orderItemIdentifier = specification.serviceId + ':' + specCode.substringBefore('_Bill');
            if (mapServiceIstanceIdToBillSpecList.containsKey(orderItemIdentifier)) {
                mapServiceIstanceIdToBillSpecList.get(orderItemIdentifier).add(specification);
            } else {
                mapServiceIstanceIdToBillSpecList.put(orderItemIdentifier, new List<CS_SpecificationDTO.ServiceSpecification>{ specification });
            }
            mapServiceIstanceIdToBillDescription.put(orderItemIdentifier, specification.description.substringBefore('_Bill'));
            if (mapServiceIstanceIdToBillStatus.containsKey(orderItemIdentifier)) {
                mapServiceIstanceIdToBillStatus.get(orderItemIdentifier).add(specification.status);
            } else {
                mapServiceIstanceIdToBillStatus.put(orderItemIdentifier, new List<String>{ specification.status });
            }
            //mapServiceIstanceIdToBillDescription.put(orderItemIdentifier, specification.description);
        }
        //system.debug('mapServiceIstanceIdToBillSpecList==' + mapServiceIstanceIdToBillSpecList.keyset());
        //for(CS_SpecificationDTO.ServiceSpecification specification: srvSpecMap.get('BILLING')){
        for (String orderItemId : mapServiceIstanceIdToBillSpecList.keyset()) {
            system.debug('orderItemId433'+orderItemId);
            BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();
      csord__Service__c serviceRecord = serviceMap.containsKey(orderItemId.split(':')[0]) ? serviceMap.get(orderItemId.split(':')[0]): null;
      
      system.debug('--00--'+serviceRecord +'==='+orderItemId);
      
            //String specCode = specification.Code;
            String serviceInstanceId = (serviceRecord != null ? serviceRecord.csordtelcoa__Service_Number__c : '') + ':' + ((String.isNotBlank(orderItemId) && orderItemId.contains(':') && orderItemId.split(':').size() >1) ? orderItemId.split(':')[1] : '');
             
            if(subscription.Action_Type__c != null && subscription.Action_Type__c.containsIgnoreCase('chown')){
                 billingOrderItemDataObject.productActionType = 'modify';
            }
            else if (serviceRecord != null && serviceRecord.toBeCancelled__c == 'true') {
                billingOrderItemDataObject.productActionType = 'cease';
            } else {
                billingOrderItemDataObject.productActionType = getOrderItemAction(mapServiceIstanceIdToBillStatus.get(orderItemId));
            }
            for (Id serviceId : serviceIdList) {
                if (serviceMap.get(serviceId).Scenario_Type__c != null) {
                    if (serviceMap.get(serviceId).Scenario_Type__c == 'Change of Mobile Number') {
                        billingOrderItemDataObject.productActionType = 'modify';
                        break;
                    } else if (serviceMap.get(serviceId).Scenario_Type__c.equalsIgnoreCase('Replace SIM')) {
                        billingOrderItemDataObject.productActionType = 'modify';
                        break;
                    }
                }
            }
      
      if (subscription.csord__Status__c == 'Ready For Activation') { //EDGE-187676
                 billingOrderItemDataObject.effectiveDate = subscription.Ready_for_Activation_Date__c;      
            }else if(subscription.toBeCancelled__c == 'true'){
                billingOrderItemDataObject.effectiveDate = subscription.Right_To_Stop_Date__c;
                } else {
                billingOrderItemDataObject.effectiveDate = subscription.right_to_bill_date__c;
                }
             
             if (subscription.Action_Type__c != null && subscription.Action_Type__c.containsIgnoreCase('chown')) {
                billingOrderItemDataObject.scenarioType = 'CHOWN';
           }else if (serviceRecord != null && serviceRecord.Scenario_Type__c != null) {
                billingOrderItemDataObject.scenarioType = serviceRecord.Scenario_Type__c;
      }
      
      String prodId = (serviceInstanceId.contains(':') && serviceInstanceId.split(':').size() >1 ? serviceInstanceId.split(':')[1] : '');

            billingOrderItemDataObject.serviceInstanceId = serviceInstanceId;
            billingOrderItemDataObject.productId = prodId;
            billingOrderItemDataObject.description = mapServiceIstanceIdToBillDescription.get(orderItemId); //specification.description.substringBefore('_Bill');
            // EDGE-165967 - changed parameters of method call
            populateServices(mapServiceIstanceIdToBillSpecList.get(orderItemId) /*srvSpecMap.get('BILLING')*/, codeSpecMap, billingOrderItemDataObject, orderItemId, subscription, modelChangeOrder, serviceIdList);
            //populateBillingSpecifications(allBillingSpecs,billingOrderItemDataObject,servInstanceId.split(':')[1],servInstanceId.split(':')[0]);
           populateBillingSpecifications(/*srvSpecMap.get('BILLING')*/ mapServiceIstanceIdToBillSpecList.get(orderItemId), billingOrderItemDataObject, prodId, serviceIdList); //EDGE-218310 COBA Fix
         
            orderItemsList.add(billingOrderItemDataObject);
        }
        prodCharSet.clear();
          //EDGE-173790     
        if(!orderItemsList.isEmpty()){
        billingSpecDTOV2.orderItems = orderItemsList;}
    }

    /*private void populateDataMapForOrderItems(Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap, Map<String,CS_SpecificationDTO.ServiceSpecification> codeSpecMap, Map<String, List<CS_SpecificationDTO.ServiceSpecification>> mapServiceIstanceIdToBillSpecList, Map<String, String> mapServiceIstanceIdToBillDescription, Map<String, List<String>> mapServiceIstanceIdToBillStatus);{
for(CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : srvSpecMap.get('FULFILMENT')){
if(fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000263_Fulfilment') || fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000313_Fulfilment') || fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000537_Fulfilment')||fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000966_Fulfilment')){
codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'),fulfillSrvSpec);
}
}

for(CS_SpecificationDTO.ServiceSpecification specification: srvSpecMap.get('BILLING')){
system.debug('--00--'+specification.serviceId+'==='+specification.Code+'====='+specification.status);
//csord__Service__c serviceRecord = serviceMap.get(specification.serviceId);
String specCode = specification.Code;
//String serviceInstanceId = serviceRecord.csordtelcoa__Service_Number__c+':'+specCode.substringBefore('_Bill');
String orderItemIdentifier = specification.serviceId+':'+specCode.substringBefore('_Bill');
if(mapServiceIstanceIdToBillSpecList.containsKey(orderItemIdentifier)){
mapServiceIstanceIdToBillSpecList.get(orderItemIdentifier).add(specification);
}else{
mapServiceIstanceIdToBillSpecList.put(orderItemIdentifier, new List<CS_SpecificationDTO.ServiceSpecification>{specification});
}
mapServiceIstanceIdToBillDescription.put(orderItemIdentifier, specification.description);
if(mapServiceIstanceIdToBillStatus.containsKey(orderItemIdentifier)){
mapServiceIstanceIdToBillStatus.get(orderItemIdentifier).add(specification.status);
}else{
mapServiceIstanceIdToBillStatus.put(orderItemIdentifier, new List<String>{specification.status});
}
//mapServiceIstanceIdToBillDescription.put(orderItemIdentifier, specification.description);

}
}*/

    private String getOrderItemAction(List<String> specStatusList) {
        string finalStatus = 'add';
        for (String specStatus : specStatusList) {
            if (!specStatus.equalsIgnoreCase('Created')) {
                finalStatus = 'modify';
            }
        }
        return finalStatus;
    }

    @TestVisible
    private Map<String, List<CS_SpecificationDTO.ServiceSpecification>> getAllServSpecs(List<Id> serviceIdList) {
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = new Map<String, List<CS_SpecificationDTO.ServiceSpecification>>();
        List<CS_SpecificationDTO.ServiceSpecification> billSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        for (String eachService : serviceIdList) {
            if (serviceAttachmentMap.containsKey(eachService)) {
                String attachmentBody = serviceAttachmentMap.get(eachService).toString();
                billSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attachmentBody), 'BILLING'));
                fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(attachmentBody), 'FULFILMENT'));
            }
        }
        srvSpecMap.put('BILLING', billSrvspecList);
        srvSpecMap.put('FULFILMENT', fulfilmentSrvspecList);
        return srvSpecMap;
    }
 //commented as part of EDGE-165967
  /* @TestVisible
    private void populateServices(List<CS_SpecificationDTO.ServiceSpecification> billingSpecList, Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap, BillingSpecDTOV2.OrderItems billingOrderItemDataObject, String serviceInstanceId, csord__Subscription__c subscription, boolean modelChangeOrder, List<Id> serviceIdList) {
        List<BillingSpecDTOV2.ProductCharacteristics> prodCharList = new List<BillingSpecDTOV2.ProductCharacteristics>();
        BillingSpecDTOV2.ProductCharacteristics prodCharacteristics;
        Boolean mobileFlag = false;
        Boolean fnnFlag = false;
        Boolean tenancyFlag = false;
        List<String> servidList = new List<String>();

        String actionCode = '';
        String oldServId = '';
        for (CS_SpecificationDTO.ServiceSpecification billingSpec : billingSpecList) {
            actionCode = getAssuranceOrderitemActionCode(billingSpec.status);
            if (billingOrderItemDataObject.scenarioType != null) {
                if (billingOrderItemDataObject.scenarioType.equals('Change of Mobile Number')) {
                    oldServId = serviceMap.get(billingSpec.serviceId).csord__Subscription__r.oldServiceMSISDN__c;
                }
            }
            if (billingSpec.code.contains('DMCAT_ProductSpecification_000263') || billingSpec.code.contains('DMCAT_ProductSpecification_000537') || billingSpec.code.contains('DMCAT_ProductSpecification_000690') || billingSpec.code.contains('DMCAT_ProductSpecification_000966')||billingSpec.code.contains('DMCAT_ProductSpecification_001196')) { //EDGE-172511
                for (CS_SpecificationDTO.SimpleAttributes billattr : billingSpec.SimpleAttributes) {
                    if (billattr.name.equalsIgnoreCase('billingSpecId') && billattr.value.equalsIgnoreCase('BSUSG001_CB') && (serviceInstanceId.contains('DMCAT_ProductSpecification_000263') || serviceInstanceId.contains('DMCAT_ProductSpecification_000966')||serviceInstanceId.contains('DMCAT_ProductSpecification_001196'))) {//EDGE-172511
                        mobileFlag = true;
                    }
                    if (billattr.name.equalsIgnoreCase('billingSpecId') && billattr.value.equalsIgnoreCase('BSUSG003_CB') && serviceInstanceId.contains('DMCAT_ProductSpecification_000537')) {
                        tenancyFlag = true;
                    }
                }
            }
            if (billingSpec.code.contains('DMCAT_ProductSpecification_000313') || billingSpec.code.contains('DMCAT_ProductSpecification_000871')) {
                if (billingSpec.SimpleAttributes != null) {
                    for (CS_SpecificationDTO.SimpleAttributes billattr : billingSpec.SimpleAttributes) {
                        if (billattr.name.equalsIgnoreCase('billingSpecId') && (billattr.value != null)) {
                            if (billattr.name.equalsIgnoreCase('billingSpecId') && (billattr.value.equalsIgnoreCase('BSUSG001_CB') || billattr.value.equalsIgnoreCase('BSUSG003_CB'))) {
                                fnnFlag = true;
                            }
                        }
                    }
                }
            }
        }
        system.debug('mobileFlag==' + mobileFlag + 'tenancyFlag==' + tenancyFlag);

        if (mobileFlag == true || tenancyFlag) {
            List<BillingSpecDTOV2.Characteristics> characteristicList = new List<BillingSpecDTOV2.Characteristics>();
            CS_SpecificationDTO.ServiceSpecification mobileSerSpec = codeSpecMap.get(serviceInstanceId.split(':')[1]);
            if (mobileSerSpec != null && mobileSerSpec.additionalAttributes != null) {
                for (CS_SpecificationDTO.SimpleAttributes fulattr : mobileSerSpec.additionalAttributes) {
                    if (fulattr.name.equalsIgnoreCase('CustomerFacingServiceId') && fulattr.value != null) {
                        BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                        charact.name = 'MSISDN';
                        charact.value = fulattr.value;
                        characteristicList.add(charact);
                    }
                    if (fulattr.name.equalsIgnoreCase('IMSI') && fulattr.value != null) {
                        BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                        charact.name = fulattr.name;
                        charact.value = fulattr.value;
                        characteristicList.add(charact);
                    }
                    if (fulattr.name.equalsIgnoreCase('tenancyId') && fulattr.value != null) {
                        BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                        charact.name = 'tenancyId';
                        charact.value = fulattr.value;
                        characteristicList.add(charact);
                    }
                }
            }
            if (!String.isBlank(oldServId)) {
                BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                charact.name = 'oldServiceId';
                charact.value = oldServId;
                characteristicList.add(charact);
            }
            prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
            String actCode = getProdCharacteristicsActioncode(subscription, serviceIdList);
            if (actCode != 'no') {
                system.debug('in prodCharacteristics.actionCode:' + prodCharacteristics.actionCode);
                prodCharacteristics.actionCode = actCode;
            }
            if (characteristicList.size() > 0) {
                prodCharacteristics.characteristics = characteristicList;
                prodCharList.add(prodCharacteristics);
            }
        }
        if (fnnFlag == true) {
            List<Number__c> fnnSet = new List<Number__c>();
            if (serviceInstanceId != null) {
                if (mapPCToNumberList.keyset() != null && serviceMap.get(serviceInstanceId.split(':')[0]) != null && mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).Id) != null && mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__c)) {
                    fnnSet.addAll(mapPCToNumberList.get(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__c));
                }
                if (
                    mapPCToNumberList.keyset() != null &&
                    serviceMap.get(serviceInstanceId.split(':')[0]) != null &&
                    mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).Id) != null &&
                    mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c)
                ) {
                    fnnSet.addAll(mapPCToNumberList.get(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c));
                }
                if (fnnSet != null) {
                    for (Number__c fnn : fnnSet) {
                        prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
                        List<BillingSpecDTOV2.Characteristics> characteristicList = new List<BillingSpecDTOV2.Characteristics>();
                        BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                        if (fnn.Service_Number__c != null) {
                            charact.name = 'FNN';
                            charact.value = fnn.Service_Number__c;
                        } else if (fnn.Start_Range__c != null) {
                            //EDGE-154773
                            charact.name = 'FNN';
                            charact.value = fnn.Start_Range__c + ' : ' + fnn.End_range__c;
                        }
                        if (modelChangeOrder) {
                            prodCharacteristics.actionCode = 'add';
                        } else if (actionCode == 'cease') {
                            prodCharacteristics.actionCode = actionCode; //Added fix to handle scenario where service is added to modify order. - 3/04/19
                        } else if (fnn.toBeCancelled__c == true) {
                            //EDGE-154773
                            prodCharacteristics.actionCode = 'cease';
                        } else {
                            prodCharacteristics.actionCode = 'add';
                        }
                        characteristicList.add(charact);
                        if (characteristicList.size() > 0) {
                            prodCharacteristics.characteristics = characteristicList;
                        }
                        prodCharList.add(prodCharacteristics);
                    }
                }
            }
        }
        //system.debug('prodCharList=======' + prodCharList);
        if (prodCharList.size() > 0) {
            billingOrderItemDataObject.productCharacteristics = prodCharList;
        }
        system.debug('billingOrderItemDataObject674'+billingOrderItemDataObject);
    }*/
    
    //added as part of  EDGE-165967
    @TestVisible
    private void populateServices(List<CS_SpecificationDTO.ServiceSpecification> billingSpecList, Map<String, CS_SpecificationDTO.ServiceSpecification> codeSpecMap, BillingSpecDTOV2.OrderItems billingOrderItemDataObject, String serviceInstanceId, csord__Subscription__c subscription, boolean modelChangeOrder, List<Id> serviceIdList) {
        Map<String, List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = getAllServSpecs(serviceIdList);
        List<BillingSpecDTOV2.ProductCharacteristics> prodCharList = new List<BillingSpecDTOV2.ProductCharacteristics>();
        BillingSpecDTOV2.ProductCharacteristics prodCharacteristics; 
        List<BillingSpecDTOV2.Characteristics> characteristicList = new List<BillingSpecDTOV2.Characteristics>();
        // Map<String,List<Product_Characteristic__mdt>> pcMetaDataMap = new Map<String,List<Product_Characteristic__mdt>>(); //added as part of EDGE-165967
        Map<String,List<Product_Characteristic__mdt>> pcMetaDataMap = new Map<String,List<Product_Characteristic__mdt>>();
        Boolean fnnFlag = false;
        Boolean IoTFlag = false;
        String actionCode = '';
        system.debug('prodCharSet689'+prodCharSet);
        String actCode;
        Set<String> BillingspecIdSet = new Set<String>(); //EDGE-165967
        // String actCode = getProdCharacteristicsActioncode(subscription, serviceIdList);
        For(Product_Characteristic__mdt pcmdt :[Select attributesName__c,attributesNameInInterface__c,attributeSource__c,billingSpecId__c,ParentProductSpecId__c,ProductSpecId__c,scenarioType__c From Product_Characteristic__mdt])
        {
            if(pcMetaDataMap.containsKey(pcmdt.ProductSpecId__c))
            {
                List<Product_Characteristic__mdt> tempList = pcMetaDataMap.get(pcmdt.ProductSpecId__c);
                templist.add(pcmdt);
                pcMetaDataMap.put(pcmdt.ProductSpecId__c,tempList);
            }else{
                List<Product_Characteristic__mdt> charList=new List<Product_Characteristic__mdt>();
                charList.add(pcmdt);
                pcMetaDataMap.put(pcmdt.ProductSpecId__c,charList);
            }
            
            
        }
        system.debug('pcMetaDataMap725'+pcMetaDataMap);
        //BillingSpecDTOV2.ProductCharacteristics prodCharacteristics =new BillingSpecDTOV2.ProductCharacteristics();
        system.debug('billingSpecList726'+billingSpecList);
        
        Set<String> billingSpecSet =new Set<String> ();
        List<String> billspecList=new List<String>();
        Map<String,String> billSpectoServId=new Map<String,String>();
        for(CS_SpecificationDTO.ServiceSpecification billingSpec : billingSpecList){
            billingSpecSet.add(billingSpec.code.substringBefore('_Bill'));
            billSpectoServId.put(billingSpec.code.substringBefore('_Bill'),billingSpec.serviceId);
        }
        billspecList.addAll(billingSpecSet);
        system.debug('billspecList723'+billspecList);
        for(String billSpec : billspecList){
            system.debug('billSpec725'+billSpec);
            system.debug('pcMetaDataMap.get(billSpec)'+pcMetaDataMap.get(billSpec));
            if(pcMetaDataMap.containsKey(billSpec)){
                for(Product_Characteristic__mdt pcmdt : pcMetaDataMap.get(billSpec))
                {
                    String atrVal='';
                    
                    if(serviceMap.containsKey(billSpectoServId.get(billSpec)) && serviceMap.get(billSpectoServId.get(billSpec)).Scenario_Type__c !=null &&serviceMap.get(billSpectoServId.get(billSpec)).Scenario_Type__c.containsIgnoreCase('chown'))
                    {
                        actCode = 'no change';
                    }else if(pcmdt.attributeSource__c!='ParentSpec'){
                        actCode= getProdCharacteristicsActioncode(subscription, serviceIdList);
                    }
                    else{
                        actCode = 'no';
                    }
                    system.debug('pcmdt742'+pcmdt);
                    system.debug('pcmdt.attributesNameInInterface__c752'+pcmdt.attributesNameInInterface__c+':'+pcmdt.attributeSource__c);
                    //if(!prodCharSet.contains(pcmdt.attributesNameInInterface__c)){
                    BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                    if(pcmdt.attributesNameInInterface__c != 'FNN' && pcmdt.attributesNameInInterface__c != 'IoT'){
                        atrVal = populateCharValue(pcmdt.attributesName__c,pcmdt.attributeSource__c,srvSpecMap.get('FULFILMENT'),subscription); 
                        if(String.isNotBlank(atrVal)){
                            if(pcmdt.attributesNameInInterface__c != 'oldServiceId'){
                                charact.name = pcmdt.attributesNameInInterface__c;
                                charact.value=  atrVal;
                                characteristicList.add(charact);
                                system.debug('characteristicList749'+characteristicList);
                            }
                            //else{
                            if(pcmdt.scenarioType__c != null){
                                csord__Service__c serv = serviceMap.containsKey(billSpectoServId.get(billSpec)) ? serviceMap.get(billSpectoServId.get(billSpec)): null;
                                if(serv.Scenario_Type__c == pcmdt.scenarioType__c){
                                    //if(String.isNotBlank(atrVal)){
                                    charact.name = pcmdt.attributesNameInInterface__c;
                                    charact.value=  atrVal;
                                    //populateCharValue(pcmdt.attributesName__c,pcmdt.attributeSource__c,srvSpecMap.get('FULFILMENT'),subscription);
                                    characteristicList.add(charact);
                                    system.debug('characteristicList756'+characteristicList);
                                    //}
                                }
                            }
                        }
                        // }
                    }else if(pcmdt.attributesNameInInterface__c == 'IoT'){
                        IoTFlag = true;
                        for(String sub : mapSubsNumbers.keySet()){
                            for(Number__c num : mapSubsNumbers.get(sub)){
                                prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
                                characteristicList = new List<BillingSpecDTOV2.Characteristics>();
                                String atName = pcmdt.attributesName__c;                                
                                for(String str : atName.split(':::')){                                    
                                    charact = new BillingSpecDTOV2.Characteristics();                                    
                                    charact.name = str.split(':')[0];
                                    Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(num));                                    
                                    charact.value = m.get(str.split(':')[1])+'';                                    
                                    characteristicList.add(charact);
                                }
                                //if(actCode != 'no')    prodCharacteristics.actionCode = actCode;
                                if (subscription.Action_Type__c == 'New'){  // DIGI-31594
                                    prodCharacteristics.actionCode = 'add';
                                    }
                                    else if (subscription.Action_Type__c == 'Cancel'){
                                        prodCharacteristics.actionCode = 'cease';
                                    }
                                prodCharacteristics.characteristics = characteristicList;                                
                                prodCharList.add(prodCharacteristics);
                            }
                        }
                    }
                     //Commented as part of EDGE-210940 || start
                    /*else{
                        fnnFlag = true;
                        prodCharList = populateFNN(serviceInstanceId,actCode,modelChangeOrder);
                        system.debug('prodCharList762'+prodCharList);
                    }*/
                     //Commented as part of EDGE-210940 || end
                    prodCharSet.add(pcmdt.attributesNameInInterface__c);
                    system.debug('prodCharSet778'+prodCharSet);
                    //}
                }
            }
        }
        //}           
        //}
        if(!IoTFlag){
            prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
            if (actCode != 'no' && !fnnFlag){
                system.debug('in prodCharacteristics.actionCode:' + prodCharacteristics.actionCode);
                prodCharacteristics.actionCode = actCode;
            }
            system.debug('characteristicList773'+characteristicList);
            //prodCharacteristics.characteristics = characteristicList;
            if (characteristicList.size() > 0) {
                prodCharacteristics.characteristics = characteristicList;
                prodCharList.add(prodCharacteristics);
            }
            system.debug('prodCharacteristics775'+prodCharacteristics);
            //prodCharList.add(prodCharacteristics);
            system.debug('prodCharacteristics777'+prodCharacteristics);
        }
        if(IoTFlag){
            billingOrderItemDataObject.ocsProductId = Product_Characteristic__mdt.getInstance('IOT').ocsProductId__c;
            billingOrderItemDataObject.serviceType = Product_Characteristic__mdt.getInstance('IOT').serviceType__c;
        }
        if (prodCharList.size() > 0) {
            billingOrderItemDataObject.productCharacteristics = prodCharList; 
        }
        system.debug('billingOrderItemDataObject788'+billingOrderItemDataObject);
    }
    
   /* private String getAssuranceOrderitemActionCode(String billSrvSpecStatus) {
        String actionCode = '';
        if (billSrvSpecStatus != null && billSrvSpecStatus.contains('Disconnect')) {
            actionCode = 'cease';
        } else if (billSrvSpecStatus != null && billSrvSpecStatus.equalsIgnoreCase('Modified')) {
            actionCode = 'modify';
        } else {
            actionCode = 'add';
        }
        return actionCode;
    }*/

    @TestVisible
    private void populateBillingSpecifications(List<CS_SpecificationDTO.ServiceSpecification> specList, BillingSpecDTOV2.OrderItems billingOrderItemDataObject, String specCode, List<Id> serviceIdList) {
        //system.debug('inside populatebillSpec' + specList);
        Boolean addExternalId = TRUE;
        String EdgeEnable;
        List<BillingSpecDTOV2.BillingSpecifications> billingSpecs = new List<BillingSpecDTOV2.BillingSpecifications>();
        Map<Id, Map<String, List<BillingSpecDTOV2.priceAlterations>>> servIdtospecCodePriceAltMap = covertPriceScheuleToPriceAlterations(specList);
System.debug('specList : '+specList);
        for (CS_SpecificationDTO.ServiceSpecification billSpec : specList) {
            System.debug('billSpec836 '+billSpec.code);
            List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
            String billingSubtype = 'NULL';
            String billingSpecIdValue;
            String contractTermValue;
      //EDGE-156163 
            String contractType; 
      //system.debug('billSpec ::' + billSpec);
      System.debug('specCode ::'+ specCode);
      System.debug('billSpec845 '+billSpec.code);
            if ((billSpec.code.contains(specCode) && !billSpec.status.equalsIgnoreCase('Complete') && !billSpec.status.equalsIgnoreCase('Paid Out')) ||(billSpec.code.contains(specCode) && serviceMap.get(billSpec.serviceId).csord__Subscription__r.Action_Type__c != null && serviceMap.get(billSpec.serviceId).csord__Subscription__r.Action_Type__c.containsIgnoreCase('chown'))|| (serviceMap.get(billSpec.serviceId).csord__Subscription__r.csord__Status__c.equalsIgnoreCase('Update In Progress'))){
                BillingSpecDTOV2.BillingSpecifications billingspecification = new BillingSpecDTOV2.BillingSpecifications();
                billingspecification.instanceId = billSpec.guid;
                if (billSpec.status == 'Modified') {
                    billingspecification.actionCode = 'modify';
                } else if (billSpec.status.contains('Disconnect')) {
                    billingspecification.actionCode = 'cease';
                }  else if (billSpec.status.contains('Complete') && serviceMap.get(billSpec.serviceId).csord__Subscription__r.Action_Type__c!= null && serviceMap.get(billSpec.serviceId).csord__Subscription__r.Action_Type__c.containsIgnoreCase('chown')) {
                    billingspecification.actionCode = 'no change';
                }else {
                    billingspecification.actionCode = 'add';
                }
                for (Id serviceId : serviceIdList) {
                    if (serviceMap.get(serviceId).Scenario_Type__c != null) {
                        if (serviceMap.get(serviceId).Scenario_Type__c == 'Change of Mobile Number') {
                            billingspecification.actionCode = 'modify';
                            break;
                        }
                    }
        }
        System.debug('billSpec863 '+billSpec.code);
        List<BillingSpecDTOV2.CustomRate> customRateList = new List<BillingSpecDTOV2.CustomRate>();
        List<BillingSpecDTOV2.RateGroup> rateGroupList = new List<BillingSpecDTOV2.RateGroup>();
        //System.debug('billSpec.complexAttributes :::'+ billSpec.complexAttributes);
        //System.debug('mapOfferIdSpecId==>> :::'+ mapOfferIdSpecId);
	    System.debug('prodSpecSetForRateCard==>> :::'+ prodSpecSetForRateCard);//DIGI-22519
        //DPG-2649 start
        system.debug('specCode'+specCode);
         //DPG-3420 START
         //DIGI-22519
        //if(mapOfferIdSpecId != null && mapOfferIdSpecId.containsKey(specCode) && (rateCardToRateCardLineItemMap!=null || commercialProductIdRateCardCodeMap!=null)){
	    if(prodSpecSetForRateCard != null && prodSpecSetForRateCard.contains(specCode) && (rateCardToRateCardLineItemMap!=null || commercialProductIdRateCardCodeMap!=null)){
            //DPG-3420 START
            addExternalId = FALSE;
            Map<String,String> valueMap=new map<String,String>();
            for(CS_SpecificationDTO.SimpleAttributes simpleAttribute:billSpec.simpleAttributes){
                valueMap.put(simpleAttribute.name,simpleAttribute.value);
            }
           
            //DPG-3420 END
            if(commercialProductIdRateCardCodeMap!=null){
                rateCardToRateCardLineItemMap = new Map<String, List<cspmb__Rate_Card_Line__c>>();
                System.debug('valueMap--->'+valueMap);
                System.debug('commercialProductIdRateCardCodeMap--->'+commercialProductIdRateCardCodeMap);
                if(valueMap != null && valueMap.containsKey('commercialProductId') && valueMap.get('commercialProductId')!=null && commercialProductIdRateCardCodeMap.get(valueMap.get('commercialProductId'))!=null){
                    rateCardToRateCardLineItemMap.putAll(commercialProductIdRateCardCodeMap.get(valueMap.get('commercialProductId')));
                }
            }
            for(String rateCardCode : rateCardToRateCardLineItemMap.keySet()){
                BillingSpecDTOV2.RateGroup rateGroup = new BillingSpecDTOV2.RateGroup();
                rateGroup.rateGroupId = rateCardCode;
                rateGroup.customRate = new List<BillingSpecDTOV2.CustomRate>();
                for(cspmb__Rate_Card_Line__c rateCardLine:rateCardToRateCardLineItemMap.get(rateCardCode)){
                    BillingSpecDTOV2.CustomRate customRate = new BillingSpecDTOV2.CustomRate();customRate.fromUnit = String.valueOf(Integer.valueOf(rateCardLine.fromUnit__c));customRate.toUnit = String.valueOf(Integer.valueOf(rateCardLine.toUnit__c));customRate.unitPrice = String.valueOf(rateCardLine.cspmb__rate_value__c);
                    if(valueMap!=NULL && valueMap.get('externalId')!=NULL && String.isNotBlank(valueMap.get('externalId'))){//DPG-3420
                        customRate.externalRateId = String.valueOf(valueMap.get('externalId'));
                    }
                    rateGroup.customRate.add(customRate);
                }
                rateGroupList.add(rateGroup);
            }
        }
        //DPG-2649 end
        //DPG-2000
        //DIGI-22519
        //else if(mapOfferIdSpecId != null && mapOfferIdSpecId.containsKey(specCode)){
		
	    else if(prodSpecSetForRateCard != null && prodSpecSetForRateCard.contains(specCode)){
          system.debug('inside&&&&'+specCode);
          if(billSpec.simpleAttributes.size() != 0 && billSpec.simpleAttributes != null){
            Map<String,String> valueMap=new map<String,String>();
            for(CS_SpecificationDTO.SimpleAttributes simpleAttribute:billSpec.simpleAttributes){
              valueMap.put(simpleAttribute.name,simpleAttribute.value);
            }
            System.debug('SubscriptionIdRateValueMap_IoT' +SubscriptionIdRateValueMap);
            if(valueMap != null && valueMap.containsKey('sharedPlanId') && SubscriptionIdRateValueMap.isEmpty() ){ // DIGI-28478	To generate custom rate block in RTB Payload for IoT.
              String commercialProductId = valueMap.get('sharedPlanId');
              List<cspmb__Rate_Card_Line__c> rateCardLineItemList = new List<cspmb__Rate_Card_Line__c>();
              if(commProdToRateCardLineItemMap.containsKey(commercialProductId)){
                rateCardLineItemList = commProdToRateCardLineItemMap.get(commercialProductId);
              }
              for(cspmb__Rate_Card_Line__c rateCardLine: rateCardLineItemList){
                BillingSpecDTOV2.CustomRate customRate = new BillingSpecDTOV2.CustomRate();customRate.fromUnit = String.valueOf(Integer.valueOf(rateCardLine.fromUnit__c));customRate.toUnit = String.valueOf(Integer.valueOf(rateCardLine.toUnit__c));customRate.unitPrice = String.valueOf(rateCardLine.cspmb__rate_value__c);customRateList.add(customRate);
              }
            }
            else{
                List<cspmb__Rate_Card_Line__c> rateCardLineItemList = new List<cspmb__Rate_Card_Line__c>();
                System.debug('rateCardLineItemList.values()' +rateCardLineItemList);
                for(cspmb__Rate_Card_Line__c rateCardLine: rateCardLineItemList){
                    BillingSpecDTOV2.CustomRate customRate = new BillingSpecDTOV2.CustomRate();customRate.fromUnit = String.valueOf(Integer.valueOf(rateCardLine.fromUnit__c));customRate.toUnit = String.valueOf(Integer.valueOf(rateCardLine.toUnit__c));customRate.unitPrice = String.valueOf(rateCardLine.cspmb__rate_value__c);customRateList.add(customRate);
                }
            }
          }  /*DPG-2000 End*/
        }
         //Added as part of EDGE-189327, EDGE-189763 to add custom rate block for telstra collaboration
         if(rateCardWrapperObj !=  null && rateCardWrapperObj.comboToLinesWrap != null){
            Id subscriptionId = serviceMap.get(billSpec.serviceId).csord__Subscription__c;
            addExternalId = TRUE;
            //Added as part of EDGE-218386  
            GenerateNegoiatedPayload.populateBillingSpecWrapper wrapObj = new GenerateNegoiatedPayload.populateBillingSpecWrapper();
            wrapObj.subscriptionId = subscriptionId;
            wrapObj.rateCardWrapperObj = rateCardWrapperObj;
            wrapObj.billSpec = billSpec;
            wrapObj.billingspecification = billingspecification;
            wrapObj.addExternalId = addExternalId;
            billingspecification = negotiatedPayloadObj.createCustomRateAndRateGroup(wrapObj);
        }
    //EDGE-189327, EDGE-189763, EDGE-218386  ends 
        else {  
          Map<String, String> valueMap = new Map<String, String>();
                if (billSpec.complexAttributes.size() != 0 && billSpec.complexAttributes != null && billSpec.complexAttributes.get('customRate') != null) {
                    for (CS_SpecificationDTO.ComplexAttributes compAttrData : billSpec.complexAttributes.get('customRate')) {
                        for (CS_SpecificationDTO.SimpleAttributes simpleAttribute : compAttrData.simpleAttributes) {
                            valueMap.put(simpleAttribute.name, simpleAttribute.value);
                        }
                        BillingSpecDTOV2.CustomRate customRate = new BillingSpecDTOV2.CustomRate();
                        customRate.fromUnit = valueMap.get('rangeFrom');
                        customRate.toUnit = valueMap.get('rangeTo');
                        customRate.unitPrice = valueMap.get('price');
               if(valueMap.get('externalId')!=null){ //added as part of EDGE-153454
                customRate.externalRateId=valueMap.get('externalId');
              } //code commented as part of contractTerm change revert
                   
                        customRateList.add(customRate);
                    }
                }
                //system.debug('customRateList'+customRateList);
          
        }
        if (!customRateList.isEmpty()){
          billingspecification.customRate = customRateList;
        }
        //DPG-2649 start
        else if(!rateGroupList.isEmpty()){
            billingspecification.rateGroups = rateGroupList;
        }
        //DPG-2649 end
        System.debug('billSpec863 '+billSpec.code);
        //System.debug('servIdtospecCodePriceAltMap  ::::'+ servIdtospecCodePriceAltMap);
        System.debug('billSpec.serviceId :::'+ billSpec.serviceId);
System.debug('billSpec ::910 '+billSpec);
                String specCodeNew = 'DMCAT_' + (String.isNotBlank(billSpec.code) && billSpec.code.contains('Billing_')  ? billSpec.code.split('Billing_')[1] : '');
                System.debug('specCodeNew: '+specCodeNew);
                System.debug('servIdtospecCodePriceAltMap: '+servIdtospecCodePriceAltMap);
                System.debug('servIdtospecCodePriceAltMap.size(): '+servIdtospecCodePriceAltMap.size());
               // System.debug('servIdtospecCodePriceAltMap.get(billSpec.serviceId): '+servIdtospecCodePriceAltMap.get(billSpec.serviceId));
               // System.debug('servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew): '+servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew));
                if (servIdtospecCodePriceAltMap != null && servIdtospecCodePriceAltMap.size() > 0 && servIdtospecCodePriceAltMap.get(billSpec.serviceId) != null && servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew) != null) {
                    //EDGE-155146
                    System.debug('priceAlterValuesNew inside If');
                    for (BillingSpecDTOV2.priceAlterations pa : servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew)) {
                        priceAlterValuesNew.add(pa);
                        System.debug('priceAlterValuesNew '+priceAlterValuesNew);
                        billingspecification.priceAlteration = priceAlterValuesNew;
                    }
                }
                for (CS_SpecificationDTO.SimpleAttributes simpleAttr : billSpec.SimpleAttributes) {
                    if ('billingSpecId'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.billingSpecId = simpleAttr.value;
                            billingSpecIdValue = simpleAttr.value;
                        }
                    }
                    if ('featureID'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.featureId = simpleAttr.value;
                        }
                    }
                    //EDGE - 123083
                    if ('quantity'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.units = Decimal.valueof(simpleAttr.value);
                        }
                    }
                    if ('rateExcludeGST'.equals(simpleAttr.name)) {
                        //system.debug('rateExcludeGST' + simpleAttr.name);
                        if (simpleAttr.value != null && !String.isBlank(simpleAttr.value)) {
                            billingspecification.unitPrice = Decimal.valueof(simpleAttr.value);
                        }
                    }
                    if ('billDescription'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.description = simpleAttr.value;
                        }
                    }
                    if ('frequency'.equals(simpleAttr.name)) {
                        billingspecification.frequency = simpleAttr.value;
                    }
                    if ('currency'.equals(simpleAttr.name)) {
                        billingspecification.currencyCode = simpleAttr.value;
                    }
                    if ('billInAdvance'.equals(simpleAttr.name)) {
                        billingspecification.billInAdvance = simpleAttr.value;
                    }
                    if ('prorate'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.prorateType = simpleAttr.value;
                        }
                    }
                    if ('ocsProdID'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.ocsProductId = simpleAttr.value;
                        }
                    }
                    if ('billingSubtype'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.billingSubType = simpleAttr.value;
                            billingSubtype = simpleAttr.value;
                        }
                    }
                    //Start : Changes for EDGE-75162
                    if ('taxTreatment'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.taxTreatment = simpleAttr.value;
                        }
                    }
                    
                    //EDGE-164355
                 if ('refundFlag'.equals(simpleAttr.name)) {    
                            if (simpleAttr.value != null && !String.isBlank(simpleAttr.value) && (String.valueOf(simpleAttr.value)).equalsIgnoreCase('true')) { 
                                billingspecification.refundFlag = String.valueOf(simpleAttr.value); 
                            }   
                        }            
                    
                    if ((simpleAttr.name).equalsIgnoreCase('ContractTerm')) {
                        if (simpleAttr.value != null) {
                            contractTermValue = simpleAttr.value;
                        }
                    }
          //EDGE-156163  
          
          if((simpleAttr.name).equalsIgnoreCase('contractType')) { 
            if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){ 
              contractType = simpleAttr.value;
            }
          }       
                        
                    //End : Changes for EDGE-75162
                    // Start :EDGE-99622
                    if ('otcDescription'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.otcDescription = simpleAttr.value;
                        }
                    }
                    if ('creditDescription'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.creditDescription = simpleAttr.value;
                        }
                    }
                    //Start EDGE-144163
                    if (EnvironmentVariable__c.getValues('Sprint20.07_144163') != null) {
                        EdgeEnable = EnvironmentVariable__c.getValues('Sprint20.07_144163').Value__c;
                    }
                    if (EdgeEnable == 'true') {
                        if ('isRedeemable'.equals(simpleAttr.name)) {
                            if (simpleAttr.value != null) {
                                billingspecification.isRedeemable = String.valueOf(simpleAttr.value);
                            }
                        }
                    }
          //added as part of EDGE-153454 - Start
                     if('chargeId'.equals(simpleAttr.name)){ //code commented as part of contractTerm change revert
                        if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){
              billingspecification.chargeId = simpleAttr.value; 
            }                                         
                    }
                    if('externalId'.equals(simpleAttr.name) && addExternalId){
                        if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){
              billingspecification.externalRateId = simpleAttr.value; 
            }                                         
                    }                                              
                    //added as part of EDGE-153454 - End 

                    //End:Changes for EDGE-88677,EDGE-91410
                    
                  //Start EDGE-174931 
                if ('monthlyPrice'.equals(simpleAttr.name)) {
                        if (simpleAttr.value != null) {
                            billingspecification.monthlyPrice = Decimal.valueof(simpleAttr.value);
                        }
                    }   
                //End EDGE-174931   
          
                //Start of DIGI-19347 by Osaka to send originalAmount to RTB Payload
                if ('FullContractTerm'.equals(simpleAttr.name)) {
                    if (simpleAttr.value != null) {
                        billingspecification.originalDuration = Integer.valueOf(simpleAttr.value);
                    }
                } 
                //End of DIGI-19347
                
                  //start EDGE-186075 
                 if ('purchaseOrder'.equals(simpleAttr.name)) {
                    if (simpleAttr.value != null && !string.isBlank(simpleAttr.value)) {
                            billingspecification.purchaseOrderNumber = simpleAttr.value;
                        }
                    }
                    //End EDGE-186075 
                    
                }

                //end of EDGE-138279
                //billingspecification.priceAlterList=priceAlterationList;
                if (billingSubtype != null && billingSubtype.equalsIgnoreCase('ETC')) {
                    billingspecification.actionCode = 'add';
                }
                //Start : Changes for EDGE-75162,
        
        //EDGE-156163 : made if condition product independent
                if(contractTermValue != NULL && !string.isBlank(contractTermValue)) {
          billingspecification.durationValue = Integer.valueOf(contractTermValue); 
          billingspecification.durationUnit = System.Label.BDSDurationValue;
                }
        
                //EDGE-156163 
                if(contractType != NULL && !string.isBlank(contractType)) {
          billingspecification.contractType = String.valueOf(contractType); 
        }                   
        
                //End : Changes for EDGE-75162
        if('BSRO001_CB'.equals(billingSpecIdValue)) { 
          if(contractTermValue != NULL) {
                        billingspecification.durationValue = Integer.valueOf(contractTermValue);
                    }
                    billingspecification.durationUnit = System.Label.BDSDurationValue;
                }
                billingSpecs.add(billingspecification);
            }
        }
        System.debug('billingSpecs::' + billingSpecs);
        billingOrderItemDataObject.billingSpecifications = billingSpecs;
    }

    private String getProdCharacteristicsActioncode(csord__Subscription__c subscription, List<Id> serviceIdList) {
        String orderType = '';
        String actioncode;
        csord__Service__c service;
        boolean isNonCom = false;
         boolean isNonCommOrder=  evaluateNonCommOrder(serviceIdList);//DIGI-14510 added
        if (subscription != null) {
            //system.debug('subs.ModelChange__c3' + subscription.ModelChange__c);
            if (subscription.ModelChange__c && (isNonCommOrder==false)) // DIGI-14510 modified condition
            {
                actioncode = 'add';
            } else {
                for (Id serviceId : serviceIdList) {
                    if (serviceMap != null && serviceMap.get(serviceId) != null && serviceMap.get(serviceId).Scenario_Type__c != null) {
                        isNonCom = true;
                        service = serviceMap.get(serviceId);
                    }
                }
                if (isNonCom == false) {
                    orderType = 'COM';
                } else {
                    orderType = service.Scenario_Type__c;
                }
                //system.debug('orderType::' + orderType);
                if (orderType != null) {
                    if (subscription.csord__Order__r.csordtelcoa__Opportunity__c == null) {
                        actioncode = orderTypeactioncodeMap.get(orderType + '_' + 'Modify');
                    } else if (subscription.csordtelcoa__Replaced_Subscription__c != null && subscription.csordtelcoa__Replaced_Subscription__r.csord__Order__c != null && subscription.toBeCancelled__c != 'true' && orderType != 'Port Out') {
                        actioncode = orderTypeactioncodeMap.get(orderType + '_' + 'Modify');
                    } else if (subscription.toBeCancelled__c == 'true' || orderType == 'Port Out') {
                        actioncode = orderTypeactioncodeMap.get(orderType + '_' + 'Cancel');
                    } else {
                        actioncode = orderTypeactioncodeMap.get(orderType + '_' + 'New');
                    }
                }
            }
        }
        //system.debug('actioncode::' + actioncode);
        return actioncode;
    }
    
@testVisible
    private List<BillingSpecDTOV2.priceAlterations> populatePriceAlterationPSLI(Map<String, List<Price_Schedule_Line_Item__c>> mapBusinessCodeToPriceScheduleList, String businessCode) {
        List<BillingSpecDTOV2.priceAlterations> priceAlterationList = new List<BillingSpecDTOV2.priceAlterations>();
    BillingSpecDTOV2.priceAlterations priceAlterObj = new BillingSpecDTOV2.priceAlterations();
    //System.debug('mapBusinessCodeToPriceScheduleList :::'+ mapBusinessCodeToPriceScheduleList);
    System.debug('businessCode :::'+ businessCode);
    
        if (mapBusinessCodeToPriceScheduleList != null && mapBusinessCodeToPriceScheduleList.size() > 0 && mapBusinessCodeToPriceScheduleList.containsKey(businessCode)) {
            for (Price_Schedule_Line_Item__c ps : mapBusinessCodeToPriceScheduleList.get(businessCode)) {
                priceAlterObj = new BillingSpecDTOV2.priceAlterations();
                if (!String.isBlank(ps.status__c)) {
                    if (ps.status__c == 'New') {
                        priceAlterObj.actionCode = 'add'; 
                        if (ps.applicationDuration__c != null) {
                            priceAlterObj.applicationDuration = Integer.valueOf(ps.applicationDuration__c);priceAlterObj.recurringChargePeriod = 'Months';
                        }
                    } else {
                        priceAlterObj.actionCode = 'cease';
                    }
                }
                // DIGI-20023 added condition to send unit price for all scnearios
                 if (ps.unitPrice__c != null) {
                            priceAlterObj.unitPrice = (Decimal) ps.unitPrice__c;
                        }
                // DIGI-20023 adding ends
                if (!String.isBlank(ps.id) && ps.id != null) {
                    priceAlterObj.instanceId = (String) ps.id;
                }
                if (priceScheduleToListTierLineItems.get(ps.Id) != null && !priceScheduleToListTierLineItems.get(ps.Id).isEmpty() && ps.chargeInstance__r.chargeType__c != null && ps.chargeInstance__r.chargeType__c == System.label.Tiered_Recurring) {
                    priceAlterObj.customRate = getTLIbyPSLIId(ps.id);
                }
                priceAlterationList.add(priceAlterObj);
                priceAlterObj = null;
            }
        }
        System.debug('priceAlterationList ::'+priceAlterationList);
        return priceAlterationList;
    }

    @TestVisible
    private List<BillingSpecDTOV2.CustomRate> getTLIbyPSLIId(Id psId) {
        BillingSpecDTOV2.CustomRate custRate = new BillingSpecDTOV2.CustomRate();
        List<BillingSpecDTOV2.CustomRate> custRateList = new List<BillingSpecDTOV2.CustomRate>();
        if (priceScheduleToListTierLineItems != null && priceScheduleToListTierLineItems.containsKey(psId)) {
            //added null check
            for (Tier_Line_Item__c tli : priceScheduleToListTierLineItems.get(psId)) {
                custRate = new BillingSpecDTOV2.CustomRate();
                custRate.fromUnit = tli.FromUnit__c;
                custRate.toUnit = tli.ToUnit__c;
                custRate.unitPrice = String.valueOf(tli.Discounted_Price__c);
                custRateList.add(custRate);
                //custRate=null;
            }
        }
        return custRateList;
    }

    private Map<Id, Map<String, List<BillingSpecDTOV2.priceAlterations>>> covertPriceScheuleToPriceAlterations(List<CS_SpecificationDTO.ServiceSpecification> specList) {
        Map<Id, Map<String, List<BillingSpecDTOV2.priceAlterations>>> servIdtospecCodePriceAltMap = new Map<Id, Map<String, List<BillingSpecDTOV2.priceAlterations>>>();
        //system.debug('check entry to covertPriceScheuleToPriceAlterations===' + specList.size());
        for (CS_SpecificationDTO.ServiceSpecification Spec : specList) {
            String code = Spec.code.contains('Billing_') ? 'DMCAT_' + Spec.code.split('Billing_')[1] : '';
            Map<String, List<BillingSpecDTOV2.priceAlterations>> newspectoPaMap = new Map<String, List<BillingSpecDTOV2.priceAlterations>>();
            if (serviceIdToListPriceSchedule.get(Spec.serviceId) != null) {
                if (servIdtospecCodePriceAltMap.containsKey(Spec.serviceId)) {
                    newspectoPaMap = servIdtospecCodePriceAltMap.get(Spec.serviceId);
                    if (newspectoPaMap.containsKey(code)) {
                        List<BillingSpecDTOV2.priceAlterations> listPA = newspectoPaMap.get(code);
                        List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(Spec.serviceId), code);
                        if (tempPAListToAdd != null) {
                            listPA.addAll(tempPAListToAdd);
                        }
                        newspectoPaMap.put(code, listPA);
                        servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                    } else {
                        List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(Spec.serviceId), code);
                        newspectoPaMap.put(code, tempPAListToAdd);
                        servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                    }
                } else {
                    List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(Spec.serviceId), code);
                    newspectoPaMap.put(code, tempPAListToAdd);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                }
            }

            if (serviceMap.containsKey(Spec.serviceId) && serviceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c != null && serviceIdToListPriceSchedule.get(serviceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c) != null) {
                if (servIdtospecCodePriceAltMap.containsKey(Spec.serviceId)) {
                    newspectoPaMap = servIdtospecCodePriceAltMap.get(Spec.serviceId);
                    if (newspectoPaMap.containsKey(code)) {
                        List<BillingSpecDTOV2.priceAlterations> listPA = newspectoPaMap.get(code);List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(serviceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c), code);
                        if (tempPAListToAdd != null) {
                            listPA.addAll(tempPAListToAdd);
                        }

                        newspectoPaMap.put(code, listPA);
                        servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                    } else {
                        //Map<String,List<BillingSpecDTOV2.priceAlterations>> newspectoPaMap=new Map<String,List<BillingSpecDTOV2.priceAlterations>>();
                        List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(serviceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c), code);
                        newspectoPaMap.put(code, tempPAListToAdd);servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                    }
                } else {
                    List<BillingSpecDTOV2.priceAlterations> tempPAListToAdd = populatePriceAlterationPSLI(serviceIdToListPriceSchedule.get(serviceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c), code);
                    newspectoPaMap.put(code, tempPAListToAdd);servIdtospecCodePriceAltMap.put(Spec.serviceId, newspectoPaMap);
                }
            }
        }
        system.debug('servIdtospecCodePriceAltMap ' + servIdtospecCodePriceAltMap);
        return servIdtospecCodePriceAltMap;
    }

    public Orchestration_calloutResponse processBillingCallout(Id subscriptionId, String oAuthToken, Integration_Handler__mdt integrationHandlerRecord) {
        Orchestration_calloutResponse calloutResponse; // = new Orchestration_calloutResponse();
        Map<String, String> pathMap = new Map<String, String>();
        List<Id> serviceIdList = new List<Id>();
    if(subscriptionId!=null)
    {
      serviceIdList = mapSubscriptionTolistServiceIds.get(subscriptionId);
    }
        boolean isNonCommercialMACD = false;
        String status = 'Failed';
    String correlationId = '';
    String UniqueCorelationId = '';
    
       if(serviceIdList!=null)
    {
        for (Id serviceId : serviceIdList) {
            if (serviceMap.get(serviceId).Scenario_Type__c != null) {
                if (serviceMap.get(serviceId).Scenario_Type__c == 'Change of Mobile Number' || serviceMap.get(serviceId).Scenario_Type__c == 'Port Out' || serviceMap.get(serviceId).Scenario_Type__c == 'Replace SIM') {
                    isNonCommercialMACD = true;
                    break;
                }
            }
        }
    }
        csord__Subscription__c subscription = subscriptionMap.get(subscriptionId);
        system.debug('Heap Check before req body====>>>'+limits.getHeapSize());
        String requestBody = buildBillPayload(subscriptionId, null , null);
        if(requestBody!=null)
        {
            requestBody ='['+requestBody+']'; 
        }
        else
            return null;
        system.debug('Heap Check after req body====>>>'+limits.getHeapSize());
        pathMap.put(subscription.Billing_Account__r.Billing_Account_Number__c, 'subscriptions');
        //status = 'Failed';
        String orderNumber = subscription.csord__Order__r.csord__Order_Number__c;
    /***umiqueId changes part of EDGE-161643***/
    UniqueCorelationId = IntegrationRecordHandlerUtil.getCorrelationId();//Length 18 char
        correlationId = UniqueCorelationId + OrderNumber; //correlationId max length is 36 char
    
        Map<String, String> headerMap = new Map<String, String>{ 'Content-Type' => 'application/json', 'Authorization' => 'Bearer ' + oAuthToken, 'Correlation-Id' => correlationId, 'Source-System' => 'SFDC' };

        if ((subscription.response_Status_Code__c > 300 && subscription.csord__Status__c == 'Billing Pending') || isProductExpire == true) {

      String eventId = String.isNotBlank(subscription.eventId__c) ? subscription.eventId__c : '';
            headerMap.put('eventId', subscription.eventId__c);
        }

        // Added DIGI-32340 - ADD action type changes
        if ((subscription.csordtelcoa__Replaced_Subscription__r.triggerBill_RTB__c == TRUE  || subscription.csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c  != null)
            && (subscription.csordtelcoa__Replaced_Subscription__c != null && subscription.csordtelcoa__Replaced_Subscription__r.csord__Order__c != null) 
            || (isNonCommercialMACD != false)|| isProductExpire == true ) {
            headerMap.put('X-HTTP-Method-Override', 'PATCH');
            String newvalue = 'subscriptions' + '/' + String.ValueOf(subscription.csordtelcoa__Subscription_Number__c);
            pathMap.put(subscription.Billing_Account__r.Billing_Account_Number__c, newvalue);
        }  

        HttpResponse adResponse;
        DateTime startTime = DateTime.now();

        //System.debug('headerMap :::' + headerMap);

        adResponse = Orchestration_CalloutUtility.sendRequestGeneric(requestBody, Orchestration_CalloutUtility.HTTP_METHOD_POST, headerMap, integrationHandlerRecord, pathMap);
        DateTime endTime = DateTime.now();
        Long requestTime = Orchestration_CalloutUtility.getRequestTimeDifference(startTime, endTime);
        /*if(){
calloutResponse = new Orchestration_calloutResponse();
}*/
        String statusCode = String.valueOf(adResponse.getStatusCode());
        String responseBody = adResponse.getBody();
        //Capture multiple Response for success
        if (statusCode.equals('202')) {
            system.debug('====>>202' + handlerName);
            calloutResponse = new Orchestration_CallOutResponse(String.valueOf(subscriptionId), requestBody, responseBody, statusCode, handlerName, 'Integration', null, orderNumber, null, requestTime, Orchestration_CalloutUtility.HTTP_METHOD_POST);
        } else if (statusCode.equals('404')) {
            system.debug('====>>404' + handlerName);
            calloutResponse = new Orchestration_CallOutResponse(String.valueOf(subscriptionId), requestBody, responseBody, statusCode, handlerName, 'Exception', null, orderNumber, statusCode, requestTime, Orchestration_CalloutUtility.HTTP_METHOD_POST);
        } else {
            system.debug('====>>' + statusCode + this.handlerName);
            BillingAccountErrorDTO billingError = BillingAccountErrorDTO.parse(responseBody);
            string errorMessage = '';
            string errorCode = '';
            if (billingError != null) {
                if (billingError.errors != null) {
                    errorMessage = billingError.errors[0].message;
                }
                errorCode = billingError.code;
            }
            calloutResponse = new Orchestration_CallOutResponse(String.valueOf(subscriptionId), requestBody, responseBody, statusCode, handlerName, 'Exception', null, orderNumber, String.valueOf(errorCode), requestTime, Orchestration_CalloutUtility.HTTP_METHOD_POST, subscription.Billing_Account__c, errorMessage);
        }

        return calloutResponse;
    }

    private void fetchServiceLineItems(List<Id> subscriptionIds) {
        Set<String> subsNumbers = new Set<String>();
        List<Id> serviceIds = new List<Id>();
        Map<String, List<Number__c>> mapSubsNumbers = new Map<String, List<Number__c>>();
        Map<Id, List<Charge_Line_Item__c>> mapServiceToCLIs = new Map<Id, List<Charge_Line_Item__c>>();
        Map<Id, List<Discount_Line_Item__c>> mapCLIsToDLIs = new Map<Id, List<Discount_Line_Item__c>>();
        Map<Id, List<Price_Schedule_Line_Item__c>> mapCLIsToPSLIs = new Map<Id, List<Price_Schedule_Line_Item__c>>();
        Map<Id, List<Tier_Line_Item__c>> mapPSLIsToTLIs = new Map<Id, List<Tier_Line_Item__c>>();
        Set<Id> cLIIds = new Set<Id>();
        Set<Id> priceLIIds = new Set<Id>();

        for (Id subscriptionId : subscriptionIds) {
            subsNumbers.add(subscriptionMap.get(subscriptionId).csordtelcoa__Subscription_Number__c);
            serviceIds.addAll(mapSubscriptionTolistServiceIds.get(subscriptionId));
        }
        System.debug('subsNumbers '+subsNumbers);
        for (Number__c numRec : [SELECT id, name, Service_Number__c, Status__c, Subscription_number__c, Product_ID__c, External_Id__c, IMSI__c, Number_Group__r.Scenario_Type__c, Number_Group__r.Pattern_Type__c FROM Number__c WHERE Subscription_number__c = :subsNumbers and Mobile__c != 'Fixed'  ] ) {  //added Mobile__c != 'Fixed' in where condition EDGE-210940
        if(numRec.Number_Group__c == null || numRec.Number_Group__r.Scenario_Type__c == null){  // DIGI-31594
            if (!mapSubsNumbers.containsKey(numRec.Subscription_number__c) ) {
                mapSubsNumbers.put(numRec.Subscription_number__c, new List<Number__c>());
            }
            mapSubsNumbers.get(numRec.Subscription_number__c).add(numRec);
        }
    }
        this.mapSubsNumbers = mapSubsNumbers;
        for (Charge_Line_Item__c chargeLI : [SELECT Id, status__c, serviceId__c, serviceId__r.csord__Subscription__c FROM Charge_Line_Item__c WHERE serviceId__c IN :serviceIds]) {
            if (!mapServiceToCLIs.containsKey(chargeLI.serviceId__c)) {
                mapServiceToCLIs.put(chargeLI.serviceId__c, new List<Charge_Line_Item__c>());
            }
            mapServiceToCLIs.get(chargeLI.serviceId__c).add(chargeLI);
            cLIIds.add(chargeLI.Id);
        }
        this.mapServiceToCLIs = mapServiceToCLIs;
        for (Discount_Line_Item__c discountLI : [SELECT id, status__c, chargeInstance__c FROM Discount_Line_Item__c WHERE chargeInstance__c IN :cLIIds]) {
            if (!mapCLIsToDLIs.containsKey(discountLI.chargeInstance__c)) {
                mapCLIsToDLIs.put(discountLI.chargeInstance__c, new List<Discount_Line_Item__c>());
            }
            mapCLIsToDLIs.get(discountLI.chargeInstance__c).add(discountLI);
        }
        this.mapCLIsToDLIs = mapCLIsToDLIs;
        for (Price_Schedule_Line_Item__c priceCLI : [SELECT Id, Status__c, chargeInstance__c FROM Price_Schedule_Line_Item__c WHERE chargeInstance__c IN :cLIIds]) {
            if (!mapCLIsToPSLIs.containsKey(priceCLI.chargeInstance__c)) {
                mapCLIsToPSLIs.put(priceCLI.chargeInstance__c, new List<Price_Schedule_Line_Item__c>());
            }
            mapCLIsToPSLIs.get(priceCLI.chargeInstance__c).add(priceCLI);
            priceLIIds.add(priceCLI.Id);
        }
        this.mapCLIsToPSLIs = mapCLIsToPSLIs;
        for (Tier_Line_Item__c tierLI : [SELECT Id, status__c, PSLIInstance__c FROM Tier_Line_Item__c WHERE PSLIInstance__c IN :priceLIIds]) {
            if (!mapPSLIsToTLIs.containsKey(tierLI.PSLIInstance__c)) {
                mapPSLIsToTLIs.put(tierLI.PSLIInstance__c, new List<Tier_Line_Item__c>());
            }
            mapPSLIsToTLIs.get(tierLI.PSLIInstance__c).add(tierLI);
        }
        this.mapPSLIsToTLIs = mapPSLIsToTLIs;
    }
  //DPG-2000 Added to send raterow in RTB
  //fetch rate card line itms for applicable products
  private void fetchRateCardItems(List<Id> subscriptionIds){
    Set <String> setOfferId = new Set<String>();
        Map<Id, Id> rateCardIdCommercialProductIdMap = new Map<Id,Id>();
        Map<String, List<cspmb__Rate_Card_Line__c>> rateCardCodeLineItemMap = new Map<String,List<cspmb__Rate_Card_Line__c>>();//DPG-2649
        Map<Id,Map<String,List<cspmb__Rate_Card_Line__c>>> commercialProductIdRateCardCodeMap = new Map<Id,Map<String,List<cspmb__Rate_Card_Line__c>>>();//DPG-2649
        Map<Id, List<cspmb__Rate_Card_Line__c>> tempRateCardItemMap = new Map<Id, List<cspmb__Rate_Card_Line__c>>();
    for(Id subscriptionId: subscriptionIds){
        if(subscriptionMap.get(subscriptionId).csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){//DPG-2649 Condition added
	        //DIGI-22519
            //if(mapOfferIdSpecId!=null && !mapOfferIdSpecId.isEmpty()  && mapOfferIdSpecId.values().contains(subscriptionMap.get(subscriptionId).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)){
            //    setOfferId.add(subscriptionMap.get(subscriptionId).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c);
            //}
	        if(offerSpecCodeMapForRCard!=null && !offerSpecCodeMapForRCard.isEmpty()  && offerSpecCodeMapForRCard.keySet().contains(subscriptionMap.get(subscriptionId).MarketableOffer__r.Offer_ID__c)){
                setOfferId.add(subscriptionMap.get(subscriptionId).MarketableOffer__r.Offer_ID__c);
            }
        }
        //DPG-2649 start
	//DIGI-22519
        else{
            //if(mapOfferIdSpecId!=null && !mapOfferIdSpecId.isEmpty() && mapOfferIdSpecId.keySet().contains(subscriptionMap.get(subscriptionId).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)){
            //    setOfferId.add(mapOfferIdSpecId.get(subscriptionMap.get(subscriptionId).csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c));
            //}
	        if(offerSpecCodeMapForRCard!=null && !offerSpecCodeMapForRCard.isEmpty() && offerSpecCodeMapForRCard.keySet().contains(subscriptionMap.get(subscriptionId).MarketableOffer__r.Offer_ID__c)){
                setOfferId.add(subscriptionMap.get(subscriptionId).MarketableOffer__r.Offer_ID__c);
            }    
        }
        //DPG-2649 end
    }
    
    if(!setOfferId.isEmpty() && offerIdToSolutionTypeMap!=null && !offerIdToSolutionTypeMap.isEmpty()){//DPG-2649 added additional checks for offerIdToSolutionTypeMap
        for(cspmb__Price_Item_Rate_Card_Association__c rateCardAssoc: Database.query('SELECT id,cspmb__Price_Item__r.Plan__c,cspmb__Price_Item__r.Name,cspmb__Rate_Card__r.Name,cspmb__Rate_Card__c FROM cspmb__Price_Item_Rate_Card_Association__c WHERE cspmb__Price_Item__c !=NULL AND cspmb__Rate_Card__c != NULL AND cspmb__Price_Item__r.Offer_Id__c IN:setOfferId'+ (offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0])=='IOT'?' AND cspmb__Price_Item__r.Plan__c != NULL':''))){//DPG-2649 Changed to dynamic query
        //for(cspmb__Price_Item_Rate_Card_Association__c rateCardAssoc: [SELECT id,cspmb__Price_Item__r.Plan__c,cspmb__Price_Item__r.Name,cspmb__Rate_Card__r.Name,cspmb__Rate_Card__c FROM cspmb__Price_Item_Rate_Card_Association__c WHERE cspmb__Price_Item__c !=NULL AND cspmb__Rate_Card__c != NULL AND cspmb__Price_Item__r.Offer_Id__c IN:setOfferId AND cspmb__Price_Item__r.Plan__c != NULL]){
                rateCardIdCommercialProductIdMap.put(rateCardAssoc.cspmb__Rate_Card__c, rateCardAssoc.cspmb__Price_Item__c);
      }
    }
    
    if(rateCardIdCommercialProductIdMap != null && !rateCardIdCommercialProductIdMap.isEmpty()){
        //DPG-2649 start
            if(setOfferId.size()==1 && !offerIdToSolutionTypeMap.isEmpty() && (offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0])=='NGADP' || offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0])=='TMDM')){
                // DIGI-20885 : Condition added in below query (cspmb__Is_Active__c) = true : Aman Gupta
                for(cspmb__Rate_Card_Line__c rateCardLineItem: [SELECT fromUnit__c, toUnit__c, cspmb__rate_value__c,rateLineGroupIdentifier__c FROM cspmb__Rate_Card_Line__c WHERE cspmb__Rate_Card__r.Offer_Id__c IN: setOfferId AND cspmb__Rate_Card__r.cspmb__Is_Active__c = true  AND cspmb__Rate_Card__c IN : rateCardIdCommercialProductIdMap.keyset() AND Check_todays_date__c = true AND toUnit__c != NULL AND fromUnit__c !=NULL AND cspmb__Is_Active__c = true]){
                    if(!rateCardCodeLineItemMap.containskey(rateCardLineItem.rateLineGroupIdentifier__c)){
                        rateCardCodeLineItemMap.put(rateCardLineItem.rateLineGroupIdentifier__c, new List<cspmb__Rate_Card_Line__c>{rateCardLineItem});
                    }else{
                        rateCardCodeLineItemMap.get(rateCardLineItem.rateLineGroupIdentifier__c).add(rateCardLineItem);
                    }      
                }
            }
            else if(setOfferId.size()==1 && !offerIdToSolutionTypeMap.isEmpty() && (offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0])=='MS')){
                // DIGI-20885 : Condition added in below query (cspmb__Is_Active__c = true) : Aman Gupta
                for(cspmb__Rate_Card_Line__c rateCardLineItem: [SELECT fromUnit__c, toUnit__c, cspmb__rate_value__c,rateLineGroupIdentifier__c,cspmb__Rate_Card__c FROM cspmb__Rate_Card_Line__c WHERE cspmb__Rate_Card__r.Offer_Id__c IN: setOfferId AND cspmb__Rate_Card__r.cspmb__Is_Active__c = true  AND cspmb__Rate_Card__c IN : rateCardIdCommercialProductIdMap.keyset() AND Check_todays_date__c = true AND toUnit__c != NULL AND fromUnit__c !=NULL AND cspmb__Is_Active__c = true]){
                    if(!commercialProductIdRateCardCodeMap.containsKey(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c))){
                        commercialProductIdRateCardCodeMap.put(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c),new Map<String,List<cspmb__Rate_Card_Line__c>>{rateCardLineItem.rateLineGroupIdentifier__c=>new List<cspmb__Rate_Card_Line__c>{rateCardLineItem}});
                    }
                    else if(commercialProductIdRateCardCodeMap.get(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c)).containsKey(rateCardLineItem.rateLineGroupIdentifier__c)){
                        commercialProductIdRateCardCodeMap.get(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c)).get(rateCardLineItem.rateLineGroupIdentifier__c).add(rateCardLineItem);
                    }
                    else{
                        commercialProductIdRateCardCodeMap.get(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c)).put(rateCardLineItem.rateLineGroupIdentifier__c,new List<cspmb__Rate_Card_Line__c>{rateCardLineItem});
                    }
                }
            }
            //DPG-2649 end
            else{
      // DIGI-20885 : Condition added in below query (cspmb__Is_Active__c) = true : Aman Gupta
      for(cspmb__Rate_Card_Line__c rateCardLineItem: [SELECT fromUnit__c, toUnit__c, cspmb__rate_value__c, cspmb__Rate_Card__c FROM cspmb__Rate_Card_Line__c WHERE cspmb__Rate_Card__r.Offer_Id__c IN: setOfferId AND cspmb__Rate_Card__r.cspmb__Is_Active__c = true  AND cspmb__Rate_Card__c IN : rateCardIdCommercialProductIdMap.keyset() AND Check_todays_date__c = true AND toUnit__c != NULL AND fromUnit__c !=NULL AND cspmb__Is_Active__c = true]){
        Id priceItemId = rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c);
        if(!tempRateCardItemMap.containskey(rateCardIdCommercialProductIdMap.get(rateCardLineItem.cspmb__Rate_Card__c))){
          tempRateCardItemMap.put(priceItemId, new List<cspmb__Rate_Card_Line__c>{rateCardLineItem});
        }else{
          tempRateCardItemMap.get(priceItemId).add(rateCardLineItem);
        }        
      }
    }
    system.debug('tempRateCardItemMap'+tempRateCardItemMap);
    system.debug('rateCardCodeLineItemMap'+rateCardCodeLineItemMap);
    system.debug('commercialProductIdRateCardCodeMap'+commercialProductIdRateCardCodeMap);
    if(!tempRateCardItemMap.isEmpty()){
      this.commProdToRateCardLineItemMap = tempRateCardItemMap;
    }
    //DPG-2649 start
        else if(!commercialProductIdRateCardCodeMap.isEmpty()){
            this.commercialProductIdRateCardCodeMap = commercialProductIdRateCardCodeMap;
        }
        else if(!rateCardCodeLineItemMap.isEmpty()){
            this.rateCardToRateCardLineItemMap = rateCardCodeLineItemMap;
        }
    //DPG-2649 end
    
  }
  //Added as part of EDGE-189327, EDGE-189763 to fetch rate card data for Telstra Collaboration 
   //Modified by Nikhil as part of DIGI-4642 added condition for DMS product also 
  // DIGI-28478	To generate custom rate block in RTB Payload for IoT.
  if(!setOfferId.isEmpty() && offerIdToSolutionTypeMap!=null && offerIdToSolutionTypeMap.containsKey(new list<String>(setOfferId)[0]) && (offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0]) == 'NGUC' || offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0]) == 'DMS'  || offerIdToSolutionTypeMap.get(new list<String>(setOfferId)[0]) == 'IOT')){
    //Added as part of EDGE-218386 
    SubscriptionIdRateValueMap = GenerateNegoiatedPayload.getSubscriptionIdRateValueMap(subscriptionIds);
    //EDGE-218386 ends
    rateCardWrapperObj = RetrieveRateCard.getLinesFromCPGeneric('','',new list<String>(setOfferId)[0]);
  }
  //EDGE-189327, EDGE-189763 ended`
  }
  //added as part of EDGE-165967
   private string populateCharValue(String attributeName,String attributeSource,List<CS_SpecificationDTO.ServiceSpecification> fulfilmentspecs,csord__Subscription__c subscription){
       String charVal = '';
       system.debug('attributeName1366'+attributeName);
        system.debug('attributeSource1367'+attributeSource);
       if(attributeSource=='SelfSpec' || attributeSource=='ParentSpec'){
           for(CS_SpecificationDTO.ServiceSpecification spec : fulfilmentspecs)
           {
               for (CS_SpecificationDTO.SimpleAttributes fulattr : spec.additionalAttributes) {
                   system.debug('fulattr.Name'+fulattr.name);
                   system.debug('fulattr.value'+fulattr.value);
                   if(fulattr.name.equalsIgnoreCase(attributeName) && !string.isBlank(fulattr.value))
                   {
                       charVal= fulattr.value;
                   }
               }
           }
           
       }else if(attributeSource=='csord__Subscription__r'){
           if(subscription.oldServiceMSISDN__c != null)
           {
               charVal = subscription.oldServiceMSISDN__c;
           }
           
       }
       system.debug('charVal1385'+charVal);
       return charVal;
     
   }
       // added for DIGI-14510
    public boolean evaluateNonCommOrder(List<Id> serviceIdList)
    {
        boolean isNonCommOrder = false;
         for (Id serviceId : serviceIdList) 
         {
            if (serviceMap.get(serviceId).Scenario_Type__c != null) {
                if (serviceMap.get(serviceId).Scenario_Type__c == 'Change of Mobile Number' || serviceMap.get(serviceId).Scenario_Type__c == 'Port Out' || serviceMap.get(serviceId).Scenario_Type__c == 'Replace SIM') {
                    isNonCommOrder = true;
                    break;
                }
            }
        }
        return isNonCommOrder;
    }
  
    // adding ends for DIGI-14510
    //added as part of EDGE-165967
    //Commented as part of EDGE-210940 || start
       /*  private List<BillingSpecDTOV2.ProductCharacteristics> populateFNN(String serviceInstanceId, String actionCode , boolean modelChangeOrder){
       List<BillingSpecDTOV2.ProductCharacteristics> prodCharList = new List<BillingSpecDTOV2.ProductCharacteristics>();
     
       BillingSpecDTOV2.ProductCharacteristics prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
         List<Number__c> fnnSet = new List<Number__c>();
            if (serviceInstanceId != null) {
                if (mapPCToNumberList.keyset() != null && serviceMap.get(serviceInstanceId.split(':')[0]) != null && mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).Id) != null && mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__c)) {
                    fnnSet.addAll(mapPCToNumberList.get(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__c));
                }
                if (
                    mapPCToNumberList.keyset() != null &&
                    serviceMap.get(serviceInstanceId.split(':')[0]) != null &&
                    mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).Id) != null &&
                    mapPCToNumberList.containsKey(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c)
                ) {
                    fnnSet.addAll(mapPCToNumberList.get(serviceMap.get(serviceInstanceId.split(':')[0]).csordtelcoa__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c));
                }
                if (fnnSet != null) {
                    for (Number__c fnn : fnnSet) {
                        prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
                        List<BillingSpecDTOV2.Characteristics> characteristicList = new List<BillingSpecDTOV2.Characteristics>();
                        BillingSpecDTOV2.Characteristics charact = new BillingSpecDTOV2.Characteristics();
                        if (fnn.Service_Number__c != null) {
                            charact.name = 'FNN';
                            charact.value = fnn.Service_Number__c;
                        } else if (fnn.Start_Range__c != null) {
                            //EDGE-154773
                            charact.name = 'FNN';
                            charact.value = fnn.Start_Range__c + ' : ' + fnn.End_range__c;
                        }
                        if (modelChangeOrder) {
                            prodCharacteristics.actionCode = 'add';
                        } else if (actionCode == 'cease') {
                            prodCharacteristics.actionCode = actionCode; //Added fix to handle scenario where service is added to modify order. - 3/04/19
                        } else if (fnn.toBeCancelled__c == true) {
                            //EDGE-154773
                            prodCharacteristics.actionCode = 'cease';
                        } else {
                            prodCharacteristics.actionCode = 'add';
                        }
                        characteristicList.add(charact);
                        if (characteristicList.size() > 0) {
                            prodCharacteristics.characteristics = characteristicList;
                        }
                       prodCharList.add(prodCharacteristics);
                    }
                }
            }
            return prodCharList;
   }*/
            //Commented as part of EDGE-210940 || end
  
}
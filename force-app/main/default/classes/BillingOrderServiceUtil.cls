/********************************************************
Class Name      :   BillingOrderServiceUtil
Test Class : BillingOrderServiceUtilTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Shreya Jaiswal        15/10/19        EDGE-107514
2.            Prajakta Patil        22/10/19         EDGE-112016,EDGE-81140 & EDGE-115840
3.            Shreya Jaiswal        23/10/19        EDGE-107514 fix
4.            Shreya Jaiswal        04/11/19        EDGE-107514 (within contract Date comparison format fix)
5.            Shreya Jaiswal        15/11/19        TID Modify RTB fix
6.            Prajakta Patil        22/11/19        EDGE-99622
7.            Shreya Jaiswal        27/11/19        EDGE-125548
8.            Shreya Jaiswal        20/12/19        EDGE-129979
9.            Vaibhav               7/1/2020        EDGE-92307 - Managed services fix
10.           Sandip Deshmane       17/1/2020       EDGE-92551 - Number Removal for NGUC
11.           Vaibhav Deshpande     20/01/2020      EDGE-120128  added priceAlteration block in payload
12.           Vaibhav Deshpande     28/01/2020      EDGE-132475  added orderReference attribute in payload

13.           Aarathi Iyer          10/02/2020      DPG 1417 added IOT Access to retrieve MSISDN in RTB payload
14.           Vaibhav Deshpande     11/02/2020      EDGE-128979  added priceAlteration block in payload for NGUC
15.           Vaibhav Deshpande     19/02/2020      EDGE-120128  added check for time-bounded discounts
16.           Vaibhav Deshpande     03/04/2020      EDGE-138279 & EDGE-138939 Fix
17.           Prajakta Patil        06/03/2020      EDGE-138595
18.           Vaibhav Deshpande     11/03/2020      EDGE-120131 Pricing Modify
19.           Prajakta Patil        11/03/2020      EDGE-137876
20.           Vaibhav Deshpande     03/04/2020      Commented MRO bonus priceAlteration block related all code
21.           Ravi  Bhatnagar       23/04/2020      EDGE-144163
22.           Vaibhav Deshpande     07/05/2020      EDGE-147623 fix- Added fix to handel empty TLI response from MS
23.           Vaibhav Deshpande     22/05/2020      EDGE-149868
24.           Prajakta              10/06/2020      EDGE-154773
25.           Vaibhav Deshpande     13/06/2020      EDGE-155146 
26.           Vaibhav               19/06/2020      EDGE-152421
27.           Pawan                 30/06/2020      EDGE-156163
28.           Vaibhav Deshpande     17/07/2020      EDGE-148819
29.           Vaibhav Deshpande     21/07/2020      EDGE-153454
30.           Vaibhav Deshpande     22/07/2020      EDGE-156163 code revert
31            Suyash Chiplunkar     23/07/2020      DPG-2000 Added to send raterow in RTB
******************************************************************************************************************
*/
public with sharing class BillingOrderServiceUtil {
    public class My2Exception extends Exception {}//added as part of EDGE-120128
    static Map<Id, String> billingOrderPayloadMap = new Map<Id, String>();
    static List<CS_SpecificationDTO.ServiceSpecification> removedSpecs =null;
    public static Id subscripId;
    //EDGE-129979
    static List<csord__Subscription__c> staticSubsList =new List<csord__Subscription__c>();
    //As a part of code refactoring
    /*CONSTANTS - begin --*/
    public static Boolean modelChangeOrder = false;
    //added as part of EDGE-120128
    public static Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> specCodeToPSLIMap=new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();//EDGE-155146 
    public static Map<Id,List<Tier_Line_Item__c>> PSLIIdtoTLIMap=new Map<Id,List<Tier_Line_Item__c>>();//added as part of EDGE-128979
    public static Map<Id,csord__Service__c> servIdtoServiceMap =new Map<Id,csord__Service__c>();
    /*CONSTANTS - end --*/
    //Added as a Part of DPG-2000
    public static Map < Id, List < BillingSpecDTOV2.CustomRate >> commercialProductRateCardMap = new Map < Id, List < BillingSpecDTOV2.CustomRate >> ();
    public static Map<Id, String> buildPostSubscriptionPayload(List<Id> subscriptionIds,boolean isIncludeSolution,boolean isProductActionExpire){
        try{
            subscripId = subscriptionIds[0];
            //System.debug('subscripId'+subscripId);
            List<csord__Subscription__c> subsList = getSubscriptionList(subscriptionIds);
            specCodeToPSLIMap=getPSLIbyServId(subsList);  //EDGE-120128 - fetching PSLI data related to subscriptions
            PSLIIdtoTLIMap=getTLIbySubId(subsList); //EDGE-128979 - fetching TLI data
            servIdtoServiceMap=getServiceMap(subscriptionIds);
            staticSubsList = subsList;
            
            //DPG-2000 - Start
            List < PopulateRateCardBilling__mdt > actlist = [select Offer_Id__c FROM PopulateRateCardBilling__mdt];
            List < String > listOfOfferId = new List < String > ();
            for (PopulateRateCardBilling__mdt row: actlist) {
                listOfOfferId.add(row.Offer_Id__c);
            }
            List < csord__Subscription__c > offerBasedSubscriptionList = new List < csord__Subscription__c > ();
            for (csord__Subscription__c row: subsList) {
                //if(row.MarketableOffer__r.Offer_ID__c == 'DMCAT_Offer_000964'){
                //if(listOfOfferId.contains(row.MarketableOffer__r.Offer_ID__c)){
                if (listOfOfferId.contains(row.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)) {
                    offerBasedSubscriptionList.add(row);
                }
            }
            if (offerBasedSubscriptionList != null && !offerBasedSubscriptionList.IsEmpty()) {
                commercialProductRateCardMap = PopulateRateCardRowsforBilling.getRateCardItems(offerBasedSubscriptionList[0].csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c);
            }
            //DPG-2000 End
            
            //System.debug('subsList'+subsList);
            Feature_Flag__mdt ft= FeatureFlagUtility.getFeatureTogglingByName('PostSubProductAPIV2');
            for(csord__Subscription__c subs: subsList){
                if( ft.IsActive__c ==true){
                    mapBillingSpecDataWithPayloadV2(subs,billingOrderPayloadMap,isIncludeSolution,isProductActionExpire);
                }
            }
            System.debug('billingOrderPayloadMap:::' + billingOrderPayloadMap); 
            if(Test.isRunningTest()){ //added as part of EDGE-120128
                throw new My2Exception('My exception');
            }
        }
        catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        return billingOrderPayloadMap;
    }
    public static List<csord__Subscription__c> getSubscriptionList(List<Id> subscriptionIds){
        List<csord__Subscription__c> subsList = new List<csord__Subscription__c>();
        try{            
            //EDGE-98378 : Query Modified
            //Query modified for EDGE-129979
            //EDGE-132475 - added ContractJunction__r.Name in Query //EDGE-148819 - added autoExpiry__c,expiryDuration__c
            subsList = [SELECT id,Name,MarketableOffer__c,MarketableOffer__r.Offer_ID__c,Billing_Account__c,
                        ModelChange__c,csordtelcoa__Replaced_Subscription__r.csord__Order__c,toBeCancelled__c,csordtelcoa__Replaced_Subscription__r.id,
                        csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c,
                        csordtelcoa__Replaced_Subscription__r.Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c,
                        csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,
                        csordtelcoa__Replaced_Subscription__r.csordtelcoa__Product_Configuration__c,csordtelcoa__Product_Configuration__r.ConfigurationType1__c,
                        csordtelcoa__Replaced_Subscription__r.right_to_bill_date__c,csordtelcoa__Replaced_Subscription__c, Site__r.name, 
                        Site__r.cscrm__Installation_Address__r.cscrm__Street_Name__c, Site__r.cscrm__Installation_Address__r.Street_Number_Start_calc__c, 
                        Site__r.cscrm__Installation_Address__r.Street_Number_End_calc__c, csordtelcoa__Product_Configuration__r.cscfga__originating_offer__r.name, 
                        csord__Order__r.csord__Primary_Order__c, csord__Order__r.csord__Primary_Order__r.Billing_Account__c, 
                        csord__Order__r.csord__Primary_Order__r.Billing_Account__r.Billing_Account_Number__c, csord__Order__r.Billing_Account__c, 
                        csord__Order__r.Billing_Account__r.Billing_Account_Number__c,Right_to_Bill_Date__c, csordtelcoa__Subscription_Number__c,
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, csord__Order__r.csord__Primary_Order__r.Scenario_Type__c,
                        offer__r.offer_spec_id__c,Right_To_Stop_Date__c, csord__Order__r.Scenario_Type__c,MarketableOffer__r.Invoice_Definition__c,
                        Billing_Account__r.Billing_Account_Number__c,cssdm__solution_association__c,
                        isAggregationPoint__c, csord__Order__r.csordtelcoa__Opportunity__c,ContractJunction__r.Name,csord__Order__c,autoExpiry__c,expiryDuration__c  FROM csord__Subscription__c WHERE Id IN:subscriptionIds];
            if(Test.isRunningTest()){ //added as part of EDGE-120128
                throw new My2Exception('My exception');
            }
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        return subsList;
    }
    //EDGE-84479 
    public static List<csord__Service__c> getServiceList(Id subscriptionId){
        List<csord__Service__c> servList = new List<csord__Service__c>();
        servList = [Select Id, Name,Scenario_Type__c, csord__Subscription__c from csord__Service__c where csord__Subscription__r.Id =:subscriptionId];
        return servList;
    }
    public static List<CS_SpecificationDTO.ServiceSpecification> compareServiceSpec(String serviceSpecNew,String serviceSpecModify){
        List<CS_SpecificationDTO.ServiceSpecification> removedSpecs = new List<CS_SpecificationDTO.ServiceSpecification>();
        try{            
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecListNewDTO = CS_SpecificationDTO.parseSubscriptionSpec(serviceSpecNew, 'BILLING');  
            List<CS_SpecificationDTO.ServiceSpecification> srvSpecListModifyDTO = CS_SpecificationDTO.parseSubscriptionSpec(serviceSpecModify, 'BILLING');
            Map<String, CS_SpecificationDTO.ServiceSpecification> newSpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
            Map<String, CS_SpecificationDTO.ServiceSpecification> modifySpecMap = new Map<String, CS_SpecificationDTO.ServiceSpecification>();
            for(CS_SpecificationDTO.ServiceSpecification o : srvSpecListNewDTO){
                newSpecMap.put(o.code, o);
            }   
            for(CS_SpecificationDTO.ServiceSpecification o : srvSpecListModifyDTO){
                modifySpecMap.put(o.code, o);
            }
            for(CS_SpecificationDTO.ServiceSpecification specs : newSpecMap.values() ){
                if(!modifySpecMap.containsKey(specs.code)){
                    removedSpecs.add(specs);
                }
            }
            if(Test.isRunningTest()){ //added as part of EDGE-120128
                throw new My2Exception('My exception');
            }
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }  
        return removedSpecs;
    }
    public static void mapBillingSpecDataWithPayloadV2(csord__Subscription__c subs,Map<Id, String> billingOrderPayloadMap,boolean isIncludeSolution,boolean isProductActionExpire){
        try{    
            System.debug(subs);
            System.debug('subscripId'+subscripId);
            boolean solustionsub = false;
            String solutionsubNumber ='';
            List<CS_SpecificationDTO.ServiceSpecification> BillingSpecs = new List<CS_SpecificationDTO.ServiceSpecification>();
            // Start Changes for EDGE-87688
            if(subs.csordtelcoa__Product_Configuration__c != null){
                if (isIncludeSolution == true && subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                    solustionsub = true;
                }
            }
            List <csord__Subscription__c> subList = [select id,csord__Order__c,right_to_bill_date__c,
                                                     csordtelcoa__Product_Configuration__r.ConfigurationType1__c,csordtelcoa__Subscription_Number__c 
                                                     from csord__Subscription__c where cssdm__solution_association__c =: subs.cssdm__solution_association__c];
            //  system.debug('subList::'+subList);
            if(subList!=null){
                for(csord__Subscription__c solutionsub :subList){
                    if(solutionsub != null){
                        if(solutionsub.csordtelcoa__Product_Configuration__r.ConfigurationType1__c == 'SolutionComponent'){
                            solutionsubNumber = solutionsub.csordtelcoa__Subscription_Number__c; 
                            //system.debug('solutionsubNumber::'+solutionsubNumber);
                        }
                    }
                }
            }
            // End Changes for EDGE-87688
            if(subs.Billing_Account__c != null ){
                BillingSpecDTOV2 billingSpecDTOV2 = new BillingSpecDTOV2();
                if(subs.ModelChange__c) modelChangeOrder = true;
                else
                    modelChangeOrder = false;
                //Edge-257.Start
                //Defect fix : EDGE-116249  
                if(isProductActionExpire == true){billingSpecDTOV2.productActionType = 'expire';} //EDGE-81140
                else if(subs.csordtelcoa__Replaced_Subscription__c!=null && subs.csordtelcoa__Replaced_Subscription__r.csord__Order__c != null && subs.toBeCancelled__c != 'true'){ 
                    billingSpecDTOV2.productActionType = 'modify';  
                }else if(subs.toBeCancelled__c == 'true'){  billingSpecDTOV2.productActionType = 'cease';
                                                         }else{ billingSpecDTOV2.productActionType = 'add'; } 
                //EDGE-84479 : as scenario type is moved to service object  
                for(csord__Service__c serv : getServiceList(subs.Id)){
                    if('Change of Mobile Number'.equals(serv.Scenario_Type__c)){
                        billingSpecDTOV2.productActionType = 'modify';
                        break;
                    }else if('Replace SIM'.equalsIgnoreCase(serv.Scenario_Type__c)){
                        billingSpecDTOV2.productActionType = 'modify';
                        break;
                        
                    }
                }
                if(subs.toBeCancelled__c == 'true'){billingSpecDTOV2.effectiveDate = subs.Right_To_Stop_Date__c;
                                                   } else   {
                                                       billingSpecDTOV2.effectiveDate = subs.right_to_bill_date__c;
                                                   }    
                if(subs.Billing_Account__c != null){
                    billingSpecDTOV2.billingAccountNumber = Long.valueOf(subs.Billing_Account__r.Billing_Account_Number__c);}
                if(subs.ContractJunction__r.name!=null){ //EDGE-132475 - added orderReference
                    billingSpecDTOV2.orderReference=subs.ContractJunction__r.name;
                }
                populateAdditionalBillInfo(subs,billingSpecDTOV2);
                populateProductOffering(subs,billingSpecDTOV2,solutionsubNumber,billingSpecDTOV2.productActionType);
                // changes for EDGE-87688
                BillingSpecs = getAllBillingServSpecs(subs.id); // EDGE-115840 allowance spec change
                if(BillingSpecs !=null && BillingSpecs.size()>0){
                    populateOrderItems(subs,billingSpecDTOV2);}
                else
                    billingSpecDTOV2.orderItems=null;
                billingOrderPayloadMap.put(subs.id, JSON.serialize(billingSpecDTOV2, true));
            }
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();        }
    }
    public static void populateAdditionalBillInfo(csord__Subscription__c subs,BillingSpecDTOV2 billingSpecDTOV2){        
        try{           
            List<BillingSpecDTOV2.AdditionalBillInfo> additionalBillInfo = new List<BillingSpecDTOV2.AdditionalBillInfo>();
            BillingSpecDTOV2.AdditionalBillInfo additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
            if(subs.Site__r.name != null){
                additionalBillInfoObject = new BillingSpecDTOV2.AdditionalBillInfo();
                additionalBillInfoObject.name = 'siteName';
                additionalBillInfoObject.value = subs.Site__r.name;
                additionalBillInfo.add(additionalBillInfoObject);   
                billingSpecDTOV2.additionalBillInfo = additionalBillInfo;
            } 
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
    }
    public static void populateProductOffering(csord__Subscription__c subs,BillingSpecDTOV2 billingSpecDTOV2,String solutionsubNumber, String productActionType){
        try{
            Boolean isSharedQuantity = false;
            BillingSpecDTOV2.ProductOffering productOffering = new BillingSpecDTOV2.ProductOffering();
            //EDGE-98378 : invoice def population modified
            if(subs.MarketableOffer__r.Invoice_Definition__c != null)
                productOffering.invoiceDefinition = subs.MarketableOffer__r.Invoice_Definition__c ;
            productOffering.productInstanceId = subs.csordtelcoa__Subscription_Number__c;
            //Start : Changes for EDGE-75162
            productOffering.offerId = subs.MarketableOffer__r.Offer_ID__c;
            productOffering.description = subs.Name;
            //End : Changes for EDGE-75162
      //EDGE-148819 - Start
      if(subs.autoExpiry__c== true)
      {
        productOffering.autoExpiry = subs.autoExpiry__c; 
                productOffering.expireDurationValue= Integer.valueOf(subs.expiryDuration__c); 
                productOffering.expireDurationUnit= System.Label.BDSDurationValue;
        
      }
      //EDGE-148819 - End
            // Changes for EDGE-8768
            system.debug('solutionsubNumber::'+solutionsubNumber);
            //EDGE-99310
            if(solutionsubNumber != null && solutionsubNumber != ''){
                productOffering.offerInstanceId = solutionsubNumber;
            }
            else{ productOffering.offerInstanceId = subs.csordtelcoa__Subscription_Number__c;}
            //End
            //EDGE-112016
            if(subs.isAggregationPoint__c == true){
                productOffering.isAggregationPoint = 'TRUE';
            }
            //End EDGE-112016
            //EDGE-115840
            List<csord__Service__c> serviceList = [select id,csord__Subscription__c,Mobility_Plan__c,Offer_Type__c from csord__Service__c where csord__Subscription__c =:subs.id];      
            if(serviceList != null){
                for(csord__Service__c serv : serviceList){
                    if(serv.Mobility_Plan__c!= null && serv.Offer_Type__c !=null){
                        if(subs.csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' && subs.MarketableOffer__r.Offer_ID__c =='DMCAT_Offer_000646' && subs.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c =='DMCAT_ProductSpecification_000420' && (productActionType == 'add'||productActionType =='cease') && (serv.Offer_Type__c =='Committed Data') && (serv.Mobility_Plan__c!='X-Large Data SIM BYO'&& serv.Mobility_Plan__c!='XX-Large Data SIM BYO')) {
                            isSharedQuantity = true;}
                    }
                }
            }
            if(isSharedQuantity == true){productOffering.isSharedQuantity ='TRUE';
                                        }
            //End EDGE-115840
            billingSpecDTOV2.ProductOffering = productOffering; }catch(Exception e){
                System.debug('Exception in populateProductOffering '+e);
            }
    }
    public static void populateOrderItems(csord__Subscription__c subs,BillingSpecDTOV2 billingSpecDTOV2){
        //try{
        List<BillingSpecDTOV2.OrderItems> orderItems = new List<BillingSpecDTOV2.OrderItems>();
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = getAllServSpecs(subs.id);
        List<CS_SpecificationDTO.ServiceSpecification> allSpecs = srvSpecMap.get('ALL');
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs1 = srvSpecMap.get('BILLING');    
        List<CS_SpecificationDTO.ServiceSpecification> allfulfilmentSpecs = srvSpecMap.get('FULFILMENT');                   
        List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs = getAllBillingServSpecs(subs.id);
        List<String> srvInstanceIdList = getAllSrvInstanceId(allBillingSpecs,subs.id);                          
        system.debug('srvInstanceIdList'+srvInstanceIdList);
        List<BillingSpecDTOV2.OrderItems> orderItemsList = new List<BillingSpecDTOV2.OrderItems>();
        for(String servInstanceId : srvInstanceIdList){
            BillingSpecDTOV2.OrderItems billingOrderItemDataObject = new BillingSpecDTOV2.OrderItems();
            csord__service__c serviceRec = getServiceFromServNumber(subs.id,servInstanceId.split(':')[0]);
            //csord__service__c serviceRec = getServiceFromServNumber(subs.id,'SVC-000056255');
            if(serviceRec!=null){
                if(serviceRec.toBeCancelled__c == 'true'){ billingOrderItemDataObject.productActionType = 'cease';
                                                         }else{
                                                             billingOrderItemDataObject.productActionType = getOrderItemAction(allBillingSpecs,servInstanceId.split(':')[1]);
                                                         }
                //EDGE-84479 : as scenario type is moved to service object  
                for(csord__Service__c serv : getServiceList(subs.Id)){
                    if('Change of Mobile Number'.equals(serv.Scenario_Type__c)){
                        billingOrderItemDataObject.productActionType = 'modify';
                        break;
                    }else if('Replace SIM'.equalsIgnoreCase(serv.Scenario_Type__c)){
                        billingOrderItemDataObject.productActionType = 'modify';
                        break;
                        
                    }
                }
            }
            if(subs.toBeCancelled__c == 'true'){ billingOrderItemDataObject.effectiveDate = subs.Right_To_Stop_Date__c;   
                                               }else {             
                                                   billingOrderItemDataObject.effectiveDate = subs.right_to_bill_date__c;
                                               }
            //start EDGE-81566
            /*if(subs.csord__Order__r.Scenario_Type__c != null) {                      
billingOrderItemDataObject.scenarioType = subs.csord__Order__r.Scenario_Type__c;
}    */
            //End EDGE-81566
            //ScenrioType bug
            if(serviceRec != null && serviceRec.Scenario_Type__c != null){
                billingOrderItemDataObject.scenarioType = serviceRec.Scenario_Type__c;
            }
            billingOrderItemDataObject.serviceInstanceId = servInstanceId;
            billingOrderItemDataObject.productId = servInstanceId.split(':')[1]; 
            billingOrderItemDataObject.description = fetchDescriptionFromSpec(servInstanceId,allBillingSpecs);
            populateServices(allBillingSpecs1,allfulfilmentSpecs,billingOrderItemDataObject,servInstanceId,subs); 
            populateBillingSpecifications(allBillingSpecs,billingOrderItemDataObject,servInstanceId.split(':')[1],servInstanceId.split(':')[0]);
            //EDGE-120128 modified method call 
            orderItemsList.add(billingOrderItemDataObject);    
        }
        billingSpecDTOV2.orderItems = orderItemsList;
        /*}catch(Exception e){
System.debug('Exception in populateOrderItems '+e.getStackTraceString());
}*/
    }
    //EDGE-120128 : changed method defination - added extra parameter String serviceID
    public static void populateBillingSpecifications(List<CS_SpecificationDTO.ServiceSpecification> specList,BillingSpecDTOV2.OrderItems billingOrderItemDataObject,String specCode,string servId){
        try{
        system.debug('inside populatebillSpec'+specList);
      String EdgeEnable;
            List<BillingSpecDTOV2.BillingSpecifications> billingSpecs =  new List<BillingSpecDTOV2.BillingSpecifications>();
            // EDGE-120128 - start
            //List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>();
           Map<Id,Map<String, List<BillingSpecDTOV2.priceAlterations>>> servIdtospecCodePriceAltMap=new Map<Id,Map<String, List<BillingSpecDTOV2.priceAlterations>>>(); //added as part of EDGE-155146 
           //Added as a Part on DPG-2000 
           List < PopulateRateCardBilling__mdt > actlist = [select Offer_Id__c, Spec_Id__c from PopulateRateCardBilling__mdt];
            Map < String, String > mapOfferIdSpecId = new Map < String, String > ();
            for (PopulateRateCardBilling__mdt row: actlist) {
                mapOfferIdSpecId.put(row.Spec_Id__c, row.Offer_Id__c);
            }
    for(CS_SpecificationDTO.ServiceSpecification Spec : specList){
         String code='DMCAT_'+Spec.code.split('Billing_')[1];
     system.debug('Spec '+Spec);
     //EDGE-155146 - start **************************************
    Map<String, List<BillingSpecDTOV2.priceAlterations>> newspectoPaMap=new  Map<String, List<BillingSpecDTOV2.priceAlterations>>();
        if(specCodeToPSLIMap.get(Spec.serviceId)!=null){ 
           
            system.debug('Spec.serviceId'+Spec.serviceId); 
            //servid to code&psli list
            
            if(servIdtospecCodePriceAltMap.containsKey(Spec.serviceId)){
               newspectoPaMap=servIdtospecCodePriceAltMap.get(Spec.serviceId);
                if(newspectoPaMap.containsKey(code)){
                    
                    List<BillingSpecDTOV2.priceAlterations> listPA = newspectoPaMap.get(code);
                    for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(Spec.serviceId),code))
                    {
                        if(pa!=null){
                            listPA.add(pa);
                        }
                        
                    }
                    
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
            }else{
                    //Map<String,List<BillingSpecDTOV2.priceAlterations>> newspectoPaMap=new Map<String,List<BillingSpecDTOV2.priceAlterations>>();
                    List<BillingSpecDTOV2.priceAlterations> listPA = new List<BillingSpecDTOV2.priceAlterations>();
                    for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(Spec.serviceId),code))
                    {
                       if(pa!=null){
                            listPA.add(pa);
                        }
                    }
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
            }}else{
                List<BillingSpecDTOV2.priceAlterations> listPA = new List<BillingSpecDTOV2.priceAlterations> ();
                 for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(Spec.serviceId),code))
                    {
                       if(pa!=null){
                            listPA.add(pa);
                        }
                    }
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
                
            }}//EDGE-152421 - added null check
            if(servIdtoServiceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__c!=null && specCodeToPSLIMap.get(servIdtoServiceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__r.id)!=null){
        
      if(servIdtospecCodePriceAltMap.containsKey(Spec.serviceId)){
               newspectoPaMap=servIdtospecCodePriceAltMap.get(Spec.serviceId);
                if(newspectoPaMap.containsKey(code)){
                    
                    List<BillingSpecDTOV2.priceAlterations> listPA = newspectoPaMap.get(code);
                    for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(servIdtoServiceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__r.id),code))
                    {
                        if(pa!=null){
                            listPA.add(pa);
                        }
                        
                    }
                    
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
            }else{
                    //Map<String,List<BillingSpecDTOV2.priceAlterations>> newspectoPaMap=new Map<String,List<BillingSpecDTOV2.priceAlterations>>();
                    List<BillingSpecDTOV2.priceAlterations> listPA = new List<BillingSpecDTOV2.priceAlterations>();
                    for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(servIdtoServiceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__r.id),code))
                    {
                       if(pa!=null){ listPA.add(pa);
                        }
                    }
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
            }}else{
                List<BillingSpecDTOV2.priceAlterations> listPA = new List<BillingSpecDTOV2.priceAlterations> ();
                 for(BillingSpecDTOV2.priceAlterations pa:populatePriceAlterationPSLI(specCodeToPSLIMap.get(servIdtoServiceMap.get(Spec.serviceId).csordtelcoa__Replaced_Service__r.id),code))
                    {
                       if(pa!=null){listPA.add(pa);
                        }
                    }
                    newspectoPaMap.put(code, listPA);
                    servIdtospecCodePriceAltMap.put(Spec.serviceId,newspectoPaMap);
                
            }
        
        
      }
           
            system.debug('servIdtospecCodePriceAltMap '+servIdtospecCodePriceAltMap);
            //}
            //EDGE-155146 - end **************************************
            }
            //System.debug('billing specList '+specList);
            // EDGE-120128 - end
            for(CS_SpecificationDTO.ServiceSpecification billSpec : specList){
                 List<BillingSpecDTOV2.priceAlterations> priceAlterValuesNew = new List<BillingSpecDTOV2.priceAlterations>(); //EDGE-138939 - reinitialized priceAlter list
                String billingSubtype = 'NULL';
                //Start : Changes for EDGE-75162
                String billingSpecIdValue;
                String contractTermValue;
                //EDGE-156163 
                //String contractType;  //code commented as part of EDGE-156163 code revert     
                //End : Changes for EDGE-75162
                system.debug('billSpec'+billSpec);
                if(billSpec.code.contains(specCode) && !billSpec.status.equalsIgnoreCase('Complete') && !billSpec.status.equalsIgnoreCase('Paid Out')){
                    BillingSpecDTOV2.BillingSpecifications billingspecification = new BillingSpecDTOV2.BillingSpecifications();
                    // billingspecification.priceAlterList priceAlt = new list<billingspecification.priceAlteration>();
                    //List<BillingSpecDTOV2.priceAlteration> priceAlterationList =new List<BillingSpecDTOV2.priceAlteration>();
                    //BillingSpecDTOV2.priceAlteration priceAlt;
                    billingspecification.instanceId = billSpec.guid;
                    if(billSpec.status=='Modified'){ 
                        billingspecification.actionCode = 'modify'; 
                    }else if(billSpec.status.contains('Disconnect')){  billingspecification.actionCode = 'cease'; 
                                                                    }else{  billingspecification.actionCode = 'add';
                                                                         }
                    //EDGE-84479 : as scenario type is moved to service object
                    if(subscripId != null || subscripId!=''){  
                        for(csord__Service__c serv : getServiceList(subscripId)){
                            if('Change of Mobile Number'.equals(serv.Scenario_Type__c)){billingspecification.actionCode = 'modify';break;}
                        }
                    }
                    //EDGE-81130
                    //DPG-2000 Start
                    if (mapOfferIdSpecId.containsKey(specCode)) {
                        List < BillingSpecDTOV2.CustomRate > customRateListIOT = new List < BillingSpecDTOV2.CustomRate > ();
                        customRateListIOT = PopulateRateCardRowsforBilling.addRateCardRowsToBillingSpecs(billingspecification, billSpec, mapOfferIdSpecId.get(specCode), commercialProductRateCardMap);
                        if (customRateListIOT != null && !customRateListIOT.isEmpty()) {
                            billingspecification.customRate = customRateListIOT;
                            customRateListIOT = null;
                            commercialProductRateCardMap = null;
                        }
                    } else { //DPG-2000 End
                        Map<String,String> valueMap=new map<String,String>();
                        List<BillingSpecDTOV2.CustomRate> customRateList=new List<BillingSpecDTOV2.CustomRate>();
                        //if(billingspecification.actionCode!='modify' && billSpec.complexAttributes.size()!=0 && billSpec.complexAttributes!=null){
                        /*EDGE-92307 - removed check billingspecification.actionCode!='modify' and added billSpec.complexAttributes.get('customRate')!=null to trigger 
        RTB in case of modify order*/
                        if(billSpec.complexAttributes.size()!=0 && billSpec.complexAttributes!=null && billSpec.complexAttributes.get('customRate')!=null){
                            for(CS_SpecificationDTO.ComplexAttributes compAttrData:billSpec.complexAttributes.get('customRate')){
                                for(CS_SpecificationDTO.SimpleAttributes simpleAttribute:compAttrData.simpleAttributes){
                                    valueMap.put(simpleAttribute.name,simpleAttribute.value);
                                }
                                BillingSpecDTOV2.CustomRate customRate=new BillingSpecDTOV2.CustomRate();
                                customRate.fromUnit=valueMap.get('rangeFrom');
                                customRate.toUnit=valueMap.get('rangeTo');
                                customRate.unitPrice=valueMap.get('price');
                           /* if(valueMap.get('externalId')!=null){ //added as part of EDGE-153454
                                customRate.externalRateId=valueMap.get('externalId');}*/ //code commented as part of contractTerm change revert
                                customRateList.add(customRate);
                            }
                        }
                        system.debug('customRateList'+customRateList);
                        if(!customRateList.isEmpty())
                            billingspecification.customRate=customRateList;
                    }
                    //EDGE-120128 - start
                    String specCodeNew='DMCAT_'+billSpec.code.split('Billing_')[1];
                    //system.debug('specCodeNew'+specCodeNew);
                    //EDGE-152421 - added null check
                    if(servIdtospecCodePriceAltMap!=null && servIdtospecCodePriceAltMap.size()>0 && servIdtospecCodePriceAltMap.get(billSpec.serviceId)!=null && servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew)!=null ){//EDGE-155146
                        for(BillingSpecDTOV2.priceAlterations pa :servIdtospecCodePriceAltMap.get(billSpec.serviceId).get(specCodeNew))
                        {
                         priceAlterValuesNew.add(pa);
                         billingspecification.priceAlteration=priceAlterValuesNew;
                        }
                    }
                    //EDGE-120128 - end
                    //Double alterPrice;
                    for(CS_SpecificationDTO.SimpleAttributes simpleAttr : billSpec.SimpleAttributes){
                        if('billingSpecId'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null) {
                                billingspecification.billingSpecId = simpleAttr.value;
                                //Added for for EDGE-75162
                                billingSpecIdValue = simpleAttr.value;
                            }
                        }
                        if('featureID'.equals(simpleAttr.name)){ 
                            if(simpleAttr.value != null){ billingspecification.featureId = simpleAttr.value; } 
                        }
                        //EDGE - 123083
                        if('quantity'.equals(simpleAttr.name)){ 
                            if(simpleAttr.value != null){ billingspecification.units = Decimal.valueof(simpleAttr.value); }                                 
                        }   
                        if('rateExcludeGST'.equals(simpleAttr.name)){ 
                        system.debug('rateExcludeGST'+simpleAttr.name);
                            if(simpleAttr.value != null){ billingspecification.unitPrice = Decimal.valueof(simpleAttr.value);
                            system.debug('rateExcludeGST'+simpleAttr.value);
                            system.debug('rateExcludeGSTV'+Decimal.valueof(simpleAttr.value));
                            system.debug('billingspecification.unitPrice'+billingspecification.unitPrice);
                             } 
                        }
                        if('billDescription'.equals(simpleAttr.name)){ if(simpleAttr.value != null){ billingspecification.description = simpleAttr.value;} 
                        }
                        if('frequency'.equals(simpleAttr.name)){billingspecification.frequency = simpleAttr.value;
                        }                   
                        if('currency'.equals(simpleAttr.name)){billingspecification.currencyCode = simpleAttr.value;                                                                                      
                        }                   
                        if('billInAdvance'.equals(simpleAttr.name)){billingspecification.billInAdvance = simpleAttr.value;
                        }                   
                        if('prorate'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){billingspecification.prorateType = simpleAttr.value;}
                        }                       
                        if('ocsProdID'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){ billingspecification.ocsProductId = simpleAttr.value;}
                        }                   
                        if('billingSubtype'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){ billingspecification.billingSubType  = simpleAttr.value; billingSubtype = simpleAttr.value; }                               
                        }
                        //Start : Changes for EDGE-75162
                        if('taxTreatment'.equals(simpleAttr.name)) {
                            if(simpleAttr.value != null){billingspecification.taxTreatment = simpleAttr.value;}
                        }
                        if((simpleAttr.name).equalsIgnoreCase('ContractTerm')) { if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){ contractTermValue = simpleAttr.value;}
                                                                               }
                        //EDGE-156163   
                        //code commented as part of EDGE-156163 code revert                                                   
                        /*if((simpleAttr.name).equalsIgnoreCase('contractType')) { if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){ contractType = simpleAttr.value;}
                                                                               }*/                                                      
                                                                                
                        //End : Changes for EDGE-75162
                        // Start :EDGE-99622
                        if('otcDescription'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){ billingspecification.otcDescription  = simpleAttr.value; }                                         
                        }
                        if('creditDescription'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){ billingspecification.creditDescription  = simpleAttr.value; }                                        
                        }
                        //Start EDGE-144163
             EdgeEnable = EnvironmentVariable__c.getValues('Sprint20.07_144163').Value__c;
            if(EdgeEnable == 'true'){
                        if('isRedeemable'.equals(simpleAttr.name)){
                            if(simpleAttr.value != null){ billingspecification.isRedeemable  = String.valueOf(simpleAttr.value); }                                        
                        }}
                        //End EDGE-144163
                        // End :EDGE-99622
                          //added as part of EDGE-153454 - Start
                       /* if('chargeId'.equals(simpleAttr.name)){ //code commented as part of contractTerm change revert
                        if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){ billingspecification.chargeId = simpleAttr.value; }                                         
                        }
                        if('externalId'.equals(simpleAttr.name)){
                        if(simpleAttr.value != null && !string.isBlank(simpleAttr.value)){ billingspecification.externalRateId = simpleAttr.value; }                                         
                        } */                                              
                    //added as part of EDGE-153454 - End 
                        /***
* @modifiedby   - Ramesh Somalagari
* @team         - OSAKA
* @JirastoryRef - EDGE-91410
***/
                        //Start :Changes for EDGE-88677,EDGE-91410
                        //System.debug('simpleAttr---------->'+simpleAttr);
                        //added as part of EDGE-138279 fix
                       /* if('alteredPrice'.equals(simpleAttr.name)){ //Code commented - MRO related code
                            if(String.isNotEmpty(simpleAttr.value)){ alterPrice  = Decimal.valueof(simpleAttr.value); }                                        
                        }*/
                      
                      //EDGE-138279 - commented code
                       /* if('alteredPrice'.equals(simpleAttr.name) && simpleAttr.value != null && simpleAttr.value != '' && Decimal.valueof(simpleAttr.value) != 0 && billingspecification.unitPrice!=null && Double.valueof(simpleAttr.value) != billingspecification.unitPrice){             
                            system.debug('simpleAttrName'+simpleAttr.name);
                            system.debug('simpleAttrVal'+Double.valueof(simpleAttr.value));
                            system.debug('simpleAttrBillingSpec'+billingspecification.unitPrice);
                            System.debug('actionCode :: '+billingspecification.actionCode);
                             system.debug('simpleAttrBillingSpec'+billSpec.code);
                            List<BillingSpecDTOV2.priceAlterations> priceAlterValues = new List<BillingSpecDTOV2.priceAlterations>();
                            /**** Check for MAC orders only****
                            //modified as a part of EDGE-107514:: separate block for modify
                            if(billingspecification.actionCode != null){
                                if(billingspecification.actionCode.equals('add'))
                                    priceAlterValues = populatePriceAlteration(billSpec,billingspecification.actionCode);
                                //modified condition: check for commercial order : EDGE-129979          
                                else if(billingspecification.actionCode.equals('modify') && staticSubsList[0].csord__Order__r.csordtelcoa__Opportunity__c!= null){
                                    //calling a new method populatePriceAlterationForModify to check planchange(using altered price and remaining term) within contract term and accordingly populate price alteration block for modify scenario (EDGE-107514)
                                    priceAlterValues = populatePriceAlterationForModify(billSpec,billingspecification.actionCode);
                                }
                                //System.debug('priceAlterValues :: '+priceAlterValues);
                                if(priceAlterValues != null){
                                    billingspecification.priceAlteration = priceAlterValues;
                                    //System.debug('priceAlteration has been added to billing specification successfully');
                                }    
                            }
                        }*/
                        //End:Changes for EDGE-88677,EDGE-91410
                    }
                   //system.debug('BillSpecUp'+billingspecification.unitPrice);
                    //system.debug('alterPrice '+alterPrice);
                    //system.debug('billSpec'+billSpec);
                    //added code as part of EDGE-138279 - MRo related Code commented
                   /* if( billingspecification.unitPrice!=null && alterPrice !=null && alterPrice != billingspecification.unitPrice){             
                           
                            List<BillingSpecDTOV2.priceAlterations> priceAlterValues = new List<BillingSpecDTOV2.priceAlterations>();
                            /**** Check for MAC orders only***
                            //modified as a part of EDGE-107514:: separate block for modify
                            if(billingspecification.actionCode != null){
                                if(billingspecification.actionCode.equals('add'))
                                    priceAlterValues = populatePriceAlteration(billSpec,billingspecification.actionCode);
                                //modified condition: check for commercial order : EDGE-129979          
                                else if(billingspecification.actionCode.equals('modify') && staticSubsList[0].csord__Order__r.csordtelcoa__Opportunity__c!= null){
                                    //calling a new method populatePriceAlterationForModify to check planchange(using altered price and remaining term) within contract term and accordingly populate price alteration block for modify scenario (EDGE-107514)
                                    priceAlterValues = populatePriceAlterationForModify(billSpec,billingspecification.actionCode);
                                }
                                //System.debug('priceAlterValues :: '+priceAlterValues);
                                if(priceAlterValues != null && !priceAlterValues.isEmpty()){
                                    billingspecification.priceAlteration = priceAlterValues;
                                    //System.debug('priceAlteration has been added to billing specification successfully');
                                }    
                            }
                        }*/
                        //end of EDGE-138279 
                    //billingspecification.priceAlterList=priceAlterationList;
                    if(billingSubtype != NULL && billingSubtype.equalsIgnoreCase('ETC')){ billingspecification.actionCode = 'add';
                                                                                        }
                   
                   /******code commented as part of EDGE-156163 code revert     
                    //EDGE-156163 : made if condition product independent
                    if(contractTermValue != NULL && !string.isBlank(contractTermValue)) { billingspecification.durationValue = Integer.valueOf(contractTermValue); billingspecification.durationUnit = System.Label.BDSDurationValue;
                    }
                    //EDGE-156163 
                    if(contractType != NULL && !string.isBlank(contractType)) {billingspecification.contractType = String.valueOf(contractType); }                   
                    *****/ 
                     //Start : Changes for EDGE-75162,
                    if('BSRO001_CB'.equals(billingSpecIdValue)) { if(contractTermValue != NULL) {billingspecification.durationValue = Integer.valueOf(contractTermValue); }
                                                                 billingspecification.durationUnit = System.Label.BDSDurationValue;
                                                                }
                    //End : Changes for EDGE-75162
                  

                    billingSpecs.add(billingspecification);
                }
            }
            //System.debug('billingSpecs::' + billingSpecs);
            billingOrderItemDataObject.billingSpecifications = billingSpecs;   }catch(Exception e){
                Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
            }
    }
    /**
*  The method is called for MRO bonus scenario from the "populateBillingSpecifications" method.It contains the MRO price details in the billing specification.
*  @name populatePriceAlteration
*  @param specList - specification List; billingOrderItemDataObject - OrderItems from BillingSpecDTOV2 class ;specCode -specification code
*  @return void - 
*  @throws exception - Throws an error if Billingspecifications are empty.
*  @Jira Story Ref - EDGE-88677
*  @Created by - Manjunath Ediga
*/ 
   /* public static List<BillingSpecDTOV2.priceAlterations> populatePriceAlteration(CS_SpecificationDTO.ServiceSpecification billspec,String actionCode){
        List<BillingSpecDTOV2.priceAlterations> priceAlterationList = new List<BillingSpecDTOV2.priceAlterations>();
        try{
            BillingSpecDTOV2.priceAlterations priceAlterationObj = null;
            system.debug('simpleAttr-->'+billSpec);
            for(CS_SpecificationDTO.SimpleAttributes simpleAttr : billSpec.SimpleAttributes){
                //checking if new attribute present in the specification file and assigning the value to billing payload(PriceAlteration)
                if('alteredPrice'.equals(simpleAttr.name)){
                    if(simpleAttr.value != null){
                        if(priceAlterationObj == null)
                            priceAlterationObj = new BillingSpecDTOV2.priceAlterations();
                        priceAlterationObj.unitPrice = Decimal.valueof(simpleAttr.value);
                    }
                }
                if('applicationDuration'.equals(simpleAttr.name)){
                    if(simpleAttr.value != null){
                        if(priceAlterationObj == null)
                            priceAlterationObj = new BillingSpecDTOV2.priceAlterations();
                        priceAlterationObj.applicationDuration = Integer.valueOf(simpleAttr.value);
                        /***
* @modifiedby   - Ramesh Somalagari
* @team         - OSAKA
* @JirastoryRef - EDGE-91410
* */
                        /*** Start : Changes for EDGE-91410 ***/
                        /** if(actionCode.equals('cease'))
priceAlterationObj.applicationDuration = '0'; **/
                        /*** END : Changes for EDGE-91410 **
                    }
                } 
                if('recurringChargePeriod'.equals(simpleAttr.name)){
                    if(simpleAttr.value != null){
                        if(priceAlterationObj == null)
                            priceAlterationObj = new BillingSpecDTOV2.priceAlterations();
                        priceAlterationObj.recurringChargePeriod = simpleAttr.value;
                    }
                } 
                if('description'.equals(simpleAttr.name)){
                    if(simpleAttr.value != null){
                        if(priceAlterationObj == null)
                            priceAlterationObj = new BillingSpecDTOV2.priceAlterations();
                        priceAlterationObj.description = simpleAttr.value;
                    }
                }
            }
            if( priceAlterationObj == null){
                throw new CustomException('PriceAlteration list is empty');
            }
            if(priceAlterationObj != null && priceAlterationObj.applicationDuration > 0){
                priceAlterationList.add(priceAlterationObj);
                priceAlterationObj = null;
            } 
            //system.debug('Price Alteration list is '+priceAlterationList);
            return priceAlterationList;
        }
        catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            return null;
        }
    }*/
    /* To check plan change and accordingly sending price alteration for modify orders
@method name populatePriceAlterationForModify
@Jira Story Ref - EDGE-107514
@Created by - Shreya  */
    /*public static List<BillingSpecDTOV2.priceAlterations> populatePriceAlterationForModify(CS_SpecificationDTO.ServiceSpecification billspec,String actionCode){
        List<BillingSpecDTOV2.priceAlterations> priceAlterationList = new List<BillingSpecDTOV2.priceAlterations>();
        try{
            List<CS_SpecificationDTO.ServiceSpecification> oldbillspeclist = new List<CS_SpecificationDTO.ServiceSpecification>();
            CS_SpecificationDTO.ServiceSpecification oldbillspec = new CS_SpecificationDTO.ServiceSpecification();
            Map<String, String> oldbillspecMap = new Map<String, String>();Map<String, String> curbillspecMap = new Map<String, String>();
            System.debug('here after:'+subscripId);
            String subId = subscripId;
            csord__subscription__c sub = [select Id, name, csordtelcoa__Replaced_Subscription__c, csordtelcoa__Replaced_Subscription__r.Id from csord__subscription__c where Id = :subId];
            //querid to get remaining term from parent service
            csord__service__c parentServ = [select Id, csordtelcoa__Product_Configuration__r.Remaining_Term__c, csord__subscription__c, csord__service__c from csord__service__c where csord__subscription__c =:sub.Id and csord__service__c = null];
            //EDGE-138595 start 
            List<csord__service__c> serv = [select Id, Initial_Activation_Date__c,contract_term__c, csord__subscription__c, csord__service__c from csord__service__c where csord__subscription__c =:sub.csordtelcoa__Replaced_Subscription__c ];
            Boolean flagServ = false;csord__service__c service = new csord__service__c();Date lastDate;
            if(!serv.isEmpty()){                
                for(csord__service__c ser :serv){
                if(ser.csord__service__c != null){flagServ = true;service = ser;break;
                }
            }           
            if (flagServ == false){service = serv[0];               }
            
            lastDate = service.Initial_Activation_Date__c.addMonths(Integer.valueof(service.contract_term__c)); 
            }
            ////EDGE-138595 end
            // system.debug('lastDate queired:'+lastDate.format() );
            if(sub.csordtelcoa__Replaced_Subscription__c != null){oldbillspeclist = getAllBillingServSpecs(sub.csordtelcoa__Replaced_Subscription__r.Id);
            }
            // system.debug('oldbillspeclist'+oldbillspeclist);
            for (CS_SpecificationDTO.ServiceSpecification oldbillspecobj : oldbillspeclist){system.debug('billspec.code.'+billspec.code);
             system.debug('oldbillspecobj.code.'+oldbillspecobj.code);
             if(billspec.code.equals(oldbillspecobj.code)){oldbillspec = oldbillspecobj;break;}
            }
            system.debug('oldbillspec'+oldbillspec);
            if(oldbillspec != null){
                for(CS_SpecificationDTO.SimpleAttributes oldSimpleAttr : oldbillspec.SimpleAttributes){oldbillspecMap.put(oldSimpleAttr.name, oldSimpleAttr.value);}
                for(CS_SpecificationDTO.SimpleAttributes curSimpleAttr : billSpec.SimpleAttributes){curbillspecMap.put(curSimpleAttr.name, curSimpleAttr.value);}
                //EDGE-107514 Fix date comparison format by Shreya on 04/11/2019
                if(System.today() <= lastDate){//within contract term
                    // system.debug('within contract');
                    if(oldbillspecMap.get('alteredPrice') != curbillspecMap.get('alteredPrice')){
                        system.debug('changed altered price');
                        //modified
                        if(parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c>0 && parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c<24){
                            // system.debug('RT :0 to 23');
                            priceAlterationList = populatePriceAlteration(billspec, actionCode);
                            //system.debug('RT :0 to 23 : priceAlterationList '+priceAlterationList )
                            //no application duration :: remove application duration from the block
                            priceAlterationList[0].applicationDuration = null;
                            //system.debug('RT :1 to 23 : priceAlterationList after making app dur null'+priceAlterationList );
                        }
                        else if(parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 24 || parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0){
                            //   system.debug('RT :24 or 0');
                            priceAlterationList = populatePriceAlteration(billspec, actionCode);
                            //system.debug('RT :24 or 0 : priceAlterationList '+priceAlterationList );
                        }
                    }
                    else if(oldbillspecMap.get('alteredPrice').equals(curbillspecMap.get('alteredPrice'))){
                        if(parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 24 || parentServ.csordtelcoa__Product_Configuration__r.Remaining_Term__c == 0){
                            //system.debug('RT :24 or 0 but no change in alt price');
                            priceAlterationList = populatePriceAlteration(billspec, actionCode);
                            //  system.debug('RT :24 or 0 but no change in alt price : priceAlterationList '+priceAlterationList );
                        }
                    }                   
                }
            }
        }  
        catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler'); logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        //system.debug('final price alt block ret::'+priceAlterationList);
        return priceAlterationList;
    }*/
    //----- get All,Billing,Fulfilment Specs based on Subscription Id -----//
    public static Map<String,List<CS_SpecificationDTO.ServiceSpecification>> getAllServSpecs(String subId){
        Map<String,List<CS_SpecificationDTO.ServiceSpecification>> srvSpecMap = new Map<String,List<CS_SpecificationDTO.ServiceSpecification>>();
        List<CS_SpecificationDTO.ServiceSpecification> srvSpecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> billSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        try{
            List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c WHERE csord__Subscription__r.id =:subId Order By CreatedDate];
            Map<Id, Attachment> servAttachmentRecordMap = new Map<Id, Attachment>();
            Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :srvcList]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
            }
            for(String eachService: serviceAttachmentMap.keySet()){
                srvSpecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService))));
                billSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'BILLING'));
                fulfilmentSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'FULFILMENT'));
                srvSpecMap.put('ALL',srvSpecList);
                srvSpecMap.put('BILLING',billSrvspecList);
                srvSpecMap.put('FULFILMENT',fulfilmentSrvspecList);
            }
            //System.debug('srvSpecMap::' + srvSpecMap);
            if(Test.isRunningTest()){ 
                throw new My2Exception('My exception');
            }       
        } catch (Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        return srvSpecMap;
    }
    public static List<CS_SpecificationDTO.ServiceSpecification> getAllBillingServSpecs(String subId){
        List<CS_SpecificationDTO.ServiceSpecification> billSrvspecList = new List<CS_SpecificationDTO.ServiceSpecification>();
        try{
            List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c WHERE csord__Subscription__r.id =:subId Order By CreatedDate];
            Map<Id, Attachment> servAttachmentRecordMap = new Map<Id, Attachment>();
            Map<Id,String> serviceAttachmentMap = new Map<Id,String>();
            for(Attachment att: [Select id,body,parentId from Attachment where parentId in :srvcList]){
                servAttachmentRecordMap.put(att.parentId,att);
                serviceAttachmentMap.put(att.parentId,att.body.toString());
            }
            for(String eachService: serviceAttachmentMap.keySet()){
                billSrvspecList.addAll(CS_SpecificationDTO.parseServiceSpec(csedm.API_1.getServiceSpecifications(serviceAttachmentMap.get(eachService)),'BILLING'));
            } 
            if(Test.isRunningTest()){ 
                throw new My2Exception('My exception');
            }
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);logger.exitLogger();
        }
        return billSrvspecList;
    }
    public static List<String> getAllSrvInstanceId(List<CS_SpecificationDTO.ServiceSpecification> allBillingSpecs,String subId){
        List<String> serviceInstanceIdList = new List<String>();
        try{
            Map<String,String> specCodeServiceIdMap = new Map<String,String>();
            String codeStr = '';
            for(CS_SpecificationDTO.ServiceSpecification billServSpec : allBillingSpecs){
                codeStr = billServSpec.code;
                String billSpecCode =codeStr.substringBefore('_Bill'); 
                specCodeServiceIdMap.put(billSpecCode,billServSpec.serviceId);
            }
            Map<String,String> servIdtoNumber = getServiceIDNumberMap(subId);
            for(String specCode : specCodeServiceIdMap.keySet()){
                //System.debug('servIdtoNumber.get(specCodeServiceIdMap.get(specCode))====>'+servIdtoNumber.get(specCodeServiceIdMap.get(specCode)));
                serviceInstanceIdList.add(servIdtoNumber.get(specCodeServiceIdMap.get(specCode))+':'+specCode);
            }
            //System.debug('serviceInstanceIdList::' + serviceInstanceIdList);
            return serviceInstanceIdList;
        }catch(Exception e){ Logger2 logger = Logger2.getLogger('PostSubscriptionHandler'); logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false); logger.exitLogger(); return serviceInstanceIdList; }
    }
    public static Map<String,String> getServiceIDNumberMap(String subId){
        Map<String,String> serviceIdtoNumber = new Map<String,String>();
        try{        
            List<csord__Service__c> srvcList = [SELECT Id, Name, csord__Status__c, csord__Order__c, csord__Order__r.id , csord__Subscription__r.csordtelcoa__Replaced_Subscription__c,csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.csord__Order__c,csord__Order_Request__c, csordtelcoa__Service_Number__c, csord__Subscription__c, ReplacedSubscription__c, CreatedDate,Forecasted_Delivery_Date__c, Telstra_Committed_Date__c, csord__Order__r.csordtelcoa__Opportunity__c FROM csord__Service__c WHERE csord__Subscription__r.id =:subId Order By CreatedDate];
            for(csord__Service__c ser : srvcList){
                serviceIdtoNumber.put(ser.id,ser.csordtelcoa__Service_Number__c);
            }  }catch(Exception e){
                //system.debug('Exception in getServiceIDNumberMap ' +e);
            }
        return serviceIdtoNumber;
    }
    public static String fetchDescriptionFromSpec(String srvInstanceId, List<CS_SpecificationDTO.ServiceSpecification> allBillingSpec){
        String specDescription = '';
        try{            
            for(CS_SpecificationDTO.ServiceSpecification spec : allBillingSpec ){
                if(spec.code.contains(srvInstanceId.split(':')[1])){
                    String specDesc = spec.description;
                    specDescription = specDesc.substringBefore('_Bill');                    
                }
            }
        }catch(Exception e){            
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }        
        return specDescription;
    }
    public static void populateServices(List<CS_SpecificationDTO.ServiceSpecification> billingSrvSpecList,List<CS_SpecificationDTO.ServiceSpecification> fulfilmentSrvSpecList,BillingSpecDTOV2.OrderItems billingOrderItemDataObject, String serviceInstanceId,csord__Subscription__c sub)
    {
        System.debug('fulfilmentSrvSpecList::' + fulfilmentSrvSpecList);
        System.debug('billingSrvSpecList::' + billingSrvSpecList);
        System.debug('billingOrderItemDataObject::' + billingOrderItemDataObject);
        system.debug('serviceInstanceId::'+serviceInstanceId);
        List<BillingSpecDTOV2.ProductCharacteristics> prodCharList = new List<BillingSpecDTOV2.ProductCharacteristics>();
        Map<String,CS_SpecificationDTO.ServiceSpecification> codeSpecMap = new Map<String,CS_SpecificationDTO.ServiceSpecification>();
        BillingSpecDTOV2.ProductCharacteristics prodCharacteristics;
        Boolean mobileFlag = false;
        Boolean fnnFlag = false;
        Boolean tenancyFlag = false;
        List<String> servidList = new List<String>();
        for(CS_SpecificationDTO.ServiceSpecification serSpec : fulfilmentSrvSpecList){
            if(serSpec.serviceId != null){             
                servidList.add(serSpec.serviceId);       
            }  
        }
        List<csord__Service__c> servList = getServiceListFromServId(servidList);
        // DPG 1417 Added IOT Access to retrieve MSISDN
        for(CS_SpecificationDTO.ServiceSpecification fulfillSrvSpec : fulfilmentSrvSpecList){                       
            if(fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000263_Fulfilment') || fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000313_Fulfilment') || fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000537_Fulfilment')||fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000966_Fulfilment')){
            //if(fulfillSrvSpec.code.equalsIgnoreCase('DMCAT_ProductSpecification_000966_Fulfilment')){    
                codeSpecMap.put(fulfillSrvSpec.code.substringBefore('_Fulfilment'),fulfillSrvSpec);
            }
        }
        //System.debug('codeSpecMap:::'+codeSpecMap);
        String actionCode = '';
        String oldServId = '';
        for(CS_SpecificationDTO.ServiceSpecification billSrvSpec : billingSrvSpecList)
        {
            //String actionCode = getOrderitemActionCode(billSrvSpec.status);
            actionCode = getAssuranceOrderitemActionCode(billSrvSpec.status);
            //EDGE-84479 modified (put check for change in mob) by Shreya on 15 Nov,19
            //null check applied 
            if(billingOrderItemDataObject.scenarioType !=null){
                if(billingOrderItemDataObject.scenarioType.equals('Change of Mobile Number'))
                {oldServId = getOldServiceID(serviceInstanceId.split(':')[0]);}
                //for MSISDN Numbers &&&&&&& added for MDM tenancy
            }
            // DPG 1417 Added IOT Access to retrieve MSISDN
            if ((billSrvSpec.code.contains('DMCAT_ProductSpecification_000263') && serviceInstanceId.contains('DMCAT_ProductSpecification_000263')) || (billSrvSpec.code.contains('DMCAT_ProductSpecification_000537') && serviceInstanceId.contains('DMCAT_ProductSpecification_000537')) || (billSrvSpec.code.contains('DMCAT_ProductSpecification_000690') && serviceInstanceId.contains('DMCAT_ProductSpecification_000690')) || (billSrvSpec.code.contains('DMCAT_ProductSpecification_000966') && serviceInstanceId.contains('DMCAT_ProductSpecification_000966'))){
                System.debug('Inside DPF if loop');
                for(CS_SpecificationDTO.SimpleAttributes billattr : billSrvSpec.SimpleAttributes){
                System.debug('******Inside DPF for loop billattr.NAME-->' + billattr.name + ' ---billattr VALUE--> ' + billattr.value + '  ---serviceInstanceId --> '+serviceInstanceId);
                    //if(billattr.name.equalsIgnoreCase('RoutingServiceType')) { routingServiceType = billattr.value;  }
                    if(billattr.name.equalsIgnoreCase('billingSpecId') && billattr.value.equalsIgnoreCase('BSUSG001_CB') && (serviceInstanceId.contains('DMCAT_ProductSpecification_000263') || serviceInstanceId.contains('DMCAT_ProductSpecification_000966'))){
                    //if(billattr.name.equalsIgnoreCase('billingSpecId') && billattr.value.equalsIgnoreCase('BSUSG001_CB') && (serviceInstanceId.contains('DMCAT_ProductSpecification_000966'))){
                        mobileFlag = true;
                        System.debug('DPG mobileFlag:::'+mobileFlag);
                    }
                    if(billattr.name.equalsIgnoreCase('billingSpecId') && billattr.value.equalsIgnoreCase('BSUSG003_CB') && serviceInstanceId.contains('DMCAT_ProductSpecification_000537')){
                        tenancyFlag = true;
                    }
                }
            }
            //for UC Numbers
            if((billSrvSpec.code.contains('DMCAT_ProductSpecification_000313')&& serviceInstanceId.contains('DMCAT_ProductSpecification_000313')) || (billSrvSpec.code.contains('DMCAT_ProductSpecification_000871')&& serviceInstanceId.contains('DMCAT_ProductSpecification_000871'))){
                //system.debug('into1=====');
                if(billSrvSpec.SimpleAttributes != null){                  
                    system.debug('simpleattibutes=====');
                    for(CS_SpecificationDTO.SimpleAttributes billattr : billSrvSpec.SimpleAttributes){
                        system.debug('billattr::'+billattr);
                        if(billattr.name.equalsIgnoreCase('billingSpecId') && (billattr.value != null)){
                            if(billattr.name.equalsIgnoreCase('billingSpecId') && (billattr.value.equalsIgnoreCase('BSUSG001_CB')|| billattr.value.equalsIgnoreCase('BSUSG003_CB')) ){
                                fnnFlag = true;
                            }
                        } 
                    }
                }
            }
        }
        if(mobileFlag == true || tenancyFlag){
            List<BillingSpecDTOV2.Characteristics> characteristicList=new List<BillingSpecDTOV2.Characteristics>();
            CS_SpecificationDTO.ServiceSpecification mobileSerSpec = codeSpecMap.get(serviceInstanceId.split(':')[1]);
            // System.debug('mobileSerSpec::' + mobileSerSpec);
            if(mobileSerSpec.additionalAttributes != null){  
                for(CS_SpecificationDTO.SimpleAttributes fulattr : mobileSerSpec.additionalAttributes){
                    if(fulattr.name.equalsIgnoreCase('CustomerFacingServiceId') && fulattr.value != NULL)      { 
                        BillingSpecDTOV2.Characteristics charact=new BillingSpecDTOV2.Characteristics();
                        charact.name='MSISDN';
                        charact.value=fulattr.value;
                        characteristicList.add(charact);
                    }
                    if(fulattr.name.equalsIgnoreCase('IMSI') && fulattr.value != NULL)  { 
                        BillingSpecDTOV2.Characteristics charact=new BillingSpecDTOV2.Characteristics();
                        charact.name=fulattr.name;
                        charact.value=fulattr.value;
                        characteristicList.add(charact);    
                    }
                    if(fulattr.name.equalsIgnoreCase('tenancyId') && fulattr.value != NULL)  { 
                        BillingSpecDTOV2.Characteristics charact=new BillingSpecDTOV2.Characteristics();
                        charact.name='tenancyId';
                        charact.value=fulattr.value;
                        characteristicList.add(charact);    
                    }
                }
            }
            //oldserviceid in char block
            //EDGE-125548
            if(!String.isBlank(oldServId))  { BillingSpecDTOV2.Characteristics charact=new BillingSpecDTOV2.Characteristics();
                                             charact.name='oldServiceId';
                                             charact.value=oldServId;
                                             characteristicList.add(charact);    
                                            }
            prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
            //Start EDGE-137515
              String actCode = getProdCharacteristicsActioncode(sub);
              if(actCode!= 'no'){
                  system.debug('in prodCharacteristics.actionCode:'+prodCharacteristics.actionCode );
                   prodCharacteristics.actionCode = actCode;
              }
            
           /* if(modelChangeOrder){
                prodCharacteristics.actionCode = 'add';
            }   
            else{
                prodCharacteristics.actionCode = actionCode; //Added fix to handle scenario where service is added to modify order. - 3/04/19
            }
            //EDGE-84479 : as scenario type is moved to service object  
            if(subscripId != null || subscripId!=''){
                for(csord__Service__c serv : getServiceList(subscripId)){if('Change of Mobile Number'.equals(serv.Scenario_Type__c)){prodCharacteristics.actionCode = 'modify';break;
                                                                                                                                    }
                                                                        }
            }*/
            
            //End  EDGE-137515
            //adding tenancy Id
            // system.debug('MIA characteristic list ' + characteristicList);
            if(characteristicList.size()>0){
                //prodCharacteristic.oldServiceId = oldServId; 
                prodCharacteristics.characteristics=characteristicList;
                prodCharList.add(prodCharacteristics);
            }
        }
        //EDGE-92551 : Updated getNumbersforBDS call from NCSHelper to NumberUtil
        if(fnnFlag == true){
            //NumberNCSHelper ncs = new NumberNCSHelper();
            List<Number__c> fnnSet = new List<Number__c>();  //EDGE-154773
            if(serviceInstanceId!=null){
                fnnSet = NumberUtil.getNumbersforBDS(serviceInstanceId.split(':')[0]);
                system.debug('fnnSet '+fnnSet);
                if(fnnSet!=null){
                    for(Number__c fnn : fnnSet){
                        prodCharacteristics = new BillingSpecDTOV2.ProductCharacteristics();
                        List<BillingSpecDTOV2.Characteristics> characteristicList = new List<BillingSpecDTOV2.Characteristics>();
                        BillingSpecDTOV2.Characteristics charact=new BillingSpecDTOV2.Characteristics();
                        if(fnn.Service_Number__c != NULL){
                        charact.name='FNN';
                        charact.value=fnn.Service_Number__c;}
                        else if(fnn.Start_Range__c != NULL){ //EDGE-154773
                        charact.name='FNN';
                        charact.value = fnn.Start_Range__c + ' : ' + fnn.End_range__c;
                        }
                        if(modelChangeOrder){prodCharacteristics.actionCode = 'add';}
                        else if(actionCode == 'cease' )
                        {
                            prodCharacteristics.actionCode =actionCode; //Added fix to handle scenario where service is added to modify order. - 3/04/19
                        }else if(fnn.toBeCancelled__c == true){ //EDGE-154773
                             prodCharacteristics.actionCode ='cease';
                        }
                        else{
                            prodCharacteristics.actionCode ='add';
                        }
                        characteristicList.add(charact);
                        if(characteristicList.size()>0){
                            prodCharacteristics.characteristics=characteristicList;
                        }
                        prodCharList.add(prodCharacteristics);
                    }
                }
            }                    
        }
        if(prodCharList.size()>0){
            billingOrderItemDataObject.productCharacteristics = prodCharList;
        }
    }
    public static String getOrderItemAction(List<CS_SpecificationDTO.ServiceSpecification> billingSrvSpecList,String specCode){
        for(CS_SpecificationDTO.ServiceSpecification spec : billingSrvSpecList){
            if(spec.code.contains(specCode) && !spec.status.equalsIgnoreCase('Created')){return 'modify';}// EDGE-115840 action fix
        }
        return 'add';       
    }
    public static List<csord__Service__c> getServiceListFromServId(List<String> servId){
        try{            
            List<csord__Service__c> serviceList = [Select id,name,csordtelcoa__Replaced_Service__c,toBeCancelled__c,ModelChange__c,Scenario_Type__c from csord__Service__c where Id IN: servId];
            return serviceList;
        }catch(Exception e){Logger2 logger = Logger2.getLogger('PostSubscriptionHandler'); logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false); logger.exitLogger();return null;}
    }
    //Added fix to handle scenario where service is added to modify order. - 3/04/19
    public static String getAssuranceOrderitemActionCode(String billSrvSpecStatus){
        String actionCode ='';
        if(billSrvSpecStatus!=null && billSrvSpecStatus.contains('Disconnect')){actionCode = 'cease';}
        else if(billSrvSpecStatus!=null && billSrvSpecStatus.equalsIgnoreCase('Modified')){actionCode = 'modify';}
        else{
            actionCode = 'add';
        }
        return actionCode;
    }
    public static csord__Service__c getServiceFromServNumber(String subRecId,String svcNumber){
        try{            
            csord__Service__c serviceRec = [Select id,name,csordtelcoa__Replaced_Service__c,toBeCancelled__c,ModelChange__c,csordtelcoa__Service_Number__c,csord__Subscription__c,Scenario_Type__c from csord__Service__c where csordtelcoa__Service_Number__c =: svcNumber and csord__Subscription__c =:subRecId order by createddate desc limit 1];
            if(serviceRec!=null){return serviceRec;}
        }catch(Exception e){
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
        }
        return null;
    }
    /*********************************************************************************************************************************
* Method Name      :   getOldServiceID
*Return            :   Returns String old service number
*Story             :   EDGE-84479
**********************************************************************************************************************************/
    public static String getOldServiceID(String svcNumber){
        try{            
            csord__Service__c serv = [Select id,csordtelcoa__Service_Number__c,csord__Subscription__r.oldServiceMSISDN__c from csord__Service__c where csordtelcoa__Service_Number__c =: svcNumber ORDER BY Createddate DESC LIMIT 1];
            return serv.csord__Subscription__r.oldServiceMSISDN__c;
        }catch(Exception e){
            return null;
        }
    }
    /*********************************************************************************************************************************
* Method Name      :   evaluateSolutionCompletion
*Story             :   EDGE-81140
**********************************************************************************************************************************/
    public static void evaluateSolutionCompletion(List<String> subscripIdList){
        try{ 
            Integer count;    
            List<Id> subIds = new List<Id>();
            List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
            csord__Subscription__c sub =[select id,Name,csord__Order__c,csord__Status__c,MarketableOffer__c,MarketableOffer__r.Auto_Expired_Entity__c,cssdm__solution_association__c,cssdm__solution_association__r.Name from csord__Subscription__c where id IN:subscripIdList LIMIT 1];
            if(sub.MarketableOffer__r.Auto_Expired_Entity__c == true){
                subList = [select id,Name,csord__Order__c,csord__Status__c,cssdm__solution_association__c from csord__Subscription__c where csord__Order__c =: sub.csord__Order__c];
                count = subList.size();
                if(subList != null){
                    for(csord__Subscription__c triggerSub :subList){
                        if(triggerSub.csord__Status__c =='Bill Readiness In Progress' ||triggerSub.csord__Status__c == 'Active')
                            count--;
                        if(sub.cssdm__solution_association__r.Name == triggerSub.Name){subIds.add(triggerSub.id);                }
                    }
                }
                boolean isIncludeSolution = true;
                boolean isProductActionExpire = false;
                if(count == 0){   isProductActionExpire = true; BillingOrderService.sendBillingOrder(subIds,isIncludeSolution,isProductActionExpire);} //EDGE-137876
                
            }
            if(Test.isRunningTest()){ 
                throw new My2Exception('My exception');
            }
        }
        catch(Exception e)  {
            Logger2 logger = Logger2.getLogger('PostSubscriptionHandler');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();} 
    }
    //EDGE-120128 - added new method to fetch PSLI records of subscriptions
    //changed method signature as part of EDGE-155146
    public static Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> getPSLIbyServId(List<csord__Subscription__c> subsList){
        
        List<Id> replacedSubList=new List<Id>();//Added as part of EDGE-120131
        for(csord__Subscription__c repsub:subsList)//Added as part of EDGE-120131 - adding replaced sub in list
        {
            if(repsub.csordtelcoa__Replaced_Subscription__r.id!=null){replacedSubList.add(repsub.csordtelcoa__Replaced_Subscription__r.id);}
        }
        Map<String,List<Price_Schedule_Line_Item__c>> specToPSLI = new Map<String,List<Price_Schedule_Line_Item__c>>();
        Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>> newspecToPSLI = new Map<Id,Map<String,List<Price_Schedule_Line_Item__c>>>();//added as part of EDGE-155146
        //EDGE-120131 - changed where condition in SOQL
        //added chargeInstance__r.serviceId__r.Id field in SOQL as part of EDGE-155146
        for(Price_Schedule_Line_Item__c psli:[select id,applicationDuration__c,chargeInstance__c,fromPeriod__c,priority__c,status__c,toPeriod__c,unitPrice__c,chargeInstance__r.serviceId__r.csord__Subscription__c,chargeInstance__r.BusinessID__c,chargeInstance__r.chargeType__c,chargeInstance__r.serviceId__r.csord__Subscription__r.csordtelcoa__Replaced_Subscription__r.id,chargeInstance__r.serviceId__r.Id,chargeInstance__r.serviceId__r.csordtelcoa__Replaced_Service__c  from Price_Schedule_Line_Item__c where chargeInstance__r.serviceId__r.csord__Subscription__r.Id IN :subsList  or chargeInstance__r.serviceId__r.csord__Subscription__r.Id IN :replacedSubList])
        {
         system.debug('psli... '+psli);
         system.debug('psli.chargeInstance__r.serviceId__r'+psli.chargeInstance__r.serviceId__r);
         
            //EDGE-155146 - start **************************************
            Map<String,List<Price_Schedule_Line_Item__c>> newSpecMap=new Map<String,List<Price_Schedule_Line_Item__c>>();
            if(psli.chargeInstance__r.serviceId__r.Id!=null){
           if(newspecToPSLI.containsKey(psli.chargeInstance__r.serviceId__r.Id)){
           newSpecMap=newspecToPSLI.get(psli.chargeInstance__r.serviceId__r.Id);
           if(newSpecMap.containsKey(psli.chargeInstance__r.BusinessID__c))
                {
                    List<Price_Schedule_Line_Item__c> lstPSLI = newSpecMap.get(psli.chargeInstance__r.BusinessID__c);
                    lstPSLI.add(psli);
                    newSpecMap.put(psli.chargeInstance__r.BusinessID__c, lstPSLI);
                }
                else{
                    newSpecMap.put(psli.chargeInstance__r.BusinessID__c, new List<Price_Schedule_Line_Item__c>{psli});
                }
                
            newspecToPSLI.put(psli.chargeInstance__r.serviceId__r.Id,newSpecMap); 
            }else{
            /* Map<String,List<Price_Schedule_Line_Item__c>> newSpecMap=new Map<String,List<Price_Schedule_Line_Item__c>>();
               if(newSpecMap.containsKey(psli.chargeInstance__r.BusinessID__c))
                {
                    List<Price_Schedule_Line_Item__c> lstPSLI = newSpecMap.get(psli.chargeInstance__r.BusinessID__c);
                    lstPSLI.add(psli);
                    newSpecMap.put(psli.chargeInstance__r.BusinessID__c, lstPSLI);
                }
                else{*/
                    newSpecMap.put(psli.chargeInstance__r.BusinessID__c, new List<Price_Schedule_Line_Item__c>{psli});
                //}
                 newspecToPSLI.put(psli.chargeInstance__r.serviceId__r.Id,newSpecMap); 
            }
         }
            //EDGE-155146 - end **************************************
        }
        system.debug('newspecToPSLI'+newspecToPSLI);
        return newspecToPSLI; //EDGE-155146
    }
    //added method as part of EDGE-120128 to generate priceAlteration block
    public static List<BillingSpecDTOV2.priceAlterations> populatePriceAlterationPSLI(Map<String,List<Price_Schedule_Line_Item__c>> specCodetoPSLIMap,String Code){
        List<BillingSpecDTOV2.priceAlterations> priceAlterationList = new List<BillingSpecDTOV2.priceAlterations>();
        BillingSpecDTOV2.priceAlterations priceAlterObj = new BillingSpecDTOV2.priceAlterations();
        //EDGE-152421 - added null check
                if(specCodeToPSLIMap!=null && specCodeToPSLIMap.size()>0 && specCodeToPSLIMap.containsKey(Code))
                {
                     for(Price_Schedule_Line_Item__c ps:specCodeToPSLIMap.get(Code))
                        {
                            priceAlterObj = new BillingSpecDTOV2.priceAlterations();
                            //system.debug('specCodeToPSLIMap.get(code)'+specCodeToPSLIMap.get(Code));
                            if(!String.isBlank(ps.status__c)){
                                if(ps.status__c=='New'){
                                    priceAlterObj.actionCode='add';
                                     if(ps.unitPrice__c!=null) //added as part of EDGE-120131
                                        {
                                            priceAlterObj.unitPrice=(Decimal)ps.unitPrice__c;
                                        }
                                      if(ps.applicationDuration__c!=null) // EDGE-120128 - added check for perpetual discounts and time-bounded discounts
                                        {
                                            priceAlterObj.applicationDuration=Integer.valueOf(ps.applicationDuration__c); //EDGE-149868
                                            priceAlterObj.recurringChargePeriod='Months';
                                        }
                                }else{
                                    priceAlterObj.actionCode='cease';
                                }
                            }
                            if(!String.isBlank(ps.id) && ps.id!=null){
                                priceAlterObj.instanceId=(String)ps.id;
                            }
                             //code commented as part of EDGE-120131
                           /* if(ps.unitPrice__c!=null)
                            {
                                priceAlterObj.unitPrice=(Decimal)ps.unitPrice__c;
                            }
                           
                           if(ps.toPeriod__c!=null && ps.toPeriod__c!='99999') // EDGE-120128 - added check for perpetual discounts and time-bounded discounts
                            {
                                priceAlterObj.applicationDuration=Integer.valueOf(ps.toPeriod__c);
                                priceAlterObj.recurringChargePeriod='Months';
                            }*/
                            //NGUC pricing code commented
                             system.debug('psForNguc'+ps);
                             system.debug('PSLIIdtoTLIMap.get(ps.Id)'+PSLIIdtoTLIMap.get(ps.Id));
                             //added isEmpty check for PSLIIdtoTLIMap
                               if(PSLIIdtoTLIMap.get(ps.Id)!=null && !PSLIIdtoTLIMap.get(ps.Id).isEmpty() && ps.chargeInstance__r.chargeType__c!=null && ps.chargeInstance__r.chargeType__c==System.label.Tiered_Recurring  ){ //added as part of EDGE-128979 - added EDGE-147623 related fix
                                  priceAlterObj.customRate=getTLIbyPSLIId(ps.id);
                            }
                          
                            //system.debug('ps2'+ps);
                            //priceAlterObj.recurringChargePeriod='Months';
                            priceAlterationList.add(priceAlterObj);
                            priceAlterObj=null;
                }
            }
        return priceAlterationList;
    }
    
      //added as EDGE-137515
    public static String getProdCharacteristicsActioncode(csord__Subscription__c sub){
      system.debug('sub::'+sub);
    String orderType = '';
    String actioncode;
    csord__Service__c service;
    boolean isNonCom =  false;
    Map<String, String> orderTypeactioncodeMap = new Map<String, String>();
    List<ActionCode_For_RTB__mdt> actlist = [select action__c,actionCode__c,orderType__c from ActionCode_For_RTB__mdt];
    for(ActionCode_For_RTB__mdt act :actlist){
        orderTypeactioncodeMap.put(act.orderType__c+'_'+act.action__c, act.actionCode__c);
    }

    if(sub!=null){
        system.debug('subs.ModelChange__c3'+sub.ModelChange__c);
        if(sub.ModelChange__c){actioncode = 'add';}
         else{
        
            List<csord__Service__c> servList = getServiceList(sub.id);
            system.debug('servList::'+servList);
                for(csord__Service__c serv :servList){
                     if(serv.Scenario_Type__c != null){
                         isNonCom = true;
                         service = serv;
                        system.debug('isNonCom=====');
                     }
                    
                }
        
                if(isNonCom== false){
                    
                    orderType = 'COM';}
                else{
                orderType =service.Scenario_Type__c;
                }
            system.debug('orderType::'+orderType);

            if(orderType!= null){
            if(sub.csord__Order__r.csordtelcoa__Opportunity__c == null){
                 actioncode =  orderTypeactioncodeMap.get(orderType+'_'+'Modify');
            }
            else if(sub.csordtelcoa__Replaced_Subscription__c!=null && sub.csordtelcoa__Replaced_Subscription__r.csord__Order__c !=null && sub.toBeCancelled__c !='true' && orderType !='Port Out'){
                 actioncode =  orderTypeactioncodeMap.get(orderType+'_'+'Modify');
            }else if(sub.toBeCancelled__c == 'true' ||  orderType == 'Port Out' ){actioncode =  orderTypeactioncodeMap.get(orderType+'_'+'Cancel'); 
            }
            else{actioncode =  orderTypeactioncodeMap.get(orderType+'_'+'New');
            
            }
        }
     }

    }
        system.debug('actioncode::'+actioncode);
     return actioncode; 
    }   
    
  
    //added as part of EDGE-128979 to get TLI data
    public static Map<Id,List<Tier_Line_Item__c>> getTLIbySubId(List<csord__Subscription__c> subsList){
        Map<Id,List<Tier_Line_Item__c>> PSLItoTLI = new Map<Id,List<Tier_Line_Item__c>>();
        
        for(Price_Schedule_Line_Item__c psli:[select id,chargeInstance__c,applicationDuration__c,chargeInstance__r.serviceId__r.csord__Subscription__c,chargeInstance__r.BusinessID__c,chargeInstance__r.chargeType__c,(Select id,FromUnit__c,ToUnit__c,Discounted_Price__c from Tier_Line_Items__r)  from Price_Schedule_Line_Item__c where chargeInstance__r.serviceId__r.csord__Subscription__r.Id IN :subsList and chargeInstance__r.chargeType__c=:System.label.Tiered_Recurring])
        {
           
                if(PSLItoTLI.containsKey(psli.id))
                {
                    List<Tier_Line_Item__c> lstTLI = PSLItoTLI.get(psli.id);
                    if(!psli.Tier_Line_Items__r.isEmpty()){
                    lstTLI.add(psli.Tier_Line_Items__r);
                    PSLItoTLI.put(psli.id, lstTLI);
                    }
                }
                else{
                   List<Tier_Line_Item__c> lstTLINew=new List<Tier_Line_Item__c>();
                     if(!psli.Tier_Line_Items__r.isEmpty()){
                            for(Tier_Line_Item__c tli:psli.Tier_Line_Items__r)
                            {
                                lstTLINew.add(tli);
                            }
                      }
                    
                    PSLItoTLI.put(psli.id,lstTLINew);
                    system.debug('PSLItoTLI '+PSLItoTLI);
                }
            
        }
       system.debug('PSLItoTLI1 '+PSLItoTLI);
        return PSLItoTLI;
    }
  //added as part of EDGE-128979  
  public static List<BillingSpecDTOV2.CustomRate> getTLIbyPSLIId(Id psId){
        BillingSpecDTOV2.CustomRate custRate=new BillingSpecDTOV2.CustomRate();
        List<BillingSpecDTOV2.CustomRate> custRateList=new List<BillingSpecDTOV2.CustomRate>();
      if(PSLIIdtoTLIMap.get(psId)!=null){ //added null check
      for(Tier_Line_Item__c tli:PSLIIdtoTLIMap.get(psId)){
              custRate=new BillingSpecDTOV2.CustomRate();                   
              custRate.fromUnit=tli.FromUnit__c;
              custRate.toUnit=tli.ToUnit__c;
              custRate.unitPrice=String.valueOf(tli.Discounted_Price__c);
              custRateList.add(custRate);
              //custRate=null;
             
            }
      }
       return custRateList; 
    }
    
    public static Map<Id,csord__Service__c> getServiceMap(List<Id> subIds){
        Map<Id,csord__Service__c> servMap = new Map<Id,csord__Service__c>();
        for(csord__Service__c serv :[Select Id, Name,csordtelcoa__Replaced_Service__c,csordtelcoa__Replaced_Service__r.id, csord__Subscription__c from csord__Service__c where csord__Subscription__r.Id =:subIds])
        {
            servMap.put(serv.id,serv);
        }
        return servMap;
    }
}
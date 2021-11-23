/*
* @Author : Shubhi
* @Date : 17 Dec 2019
* @Desc : pricing related data for test class  
* @Jira : Edge-133963
* @Jira : Edge-143527 Added generateMobilePriceItemFairPlay by Aman Soni
* @Jira : DPG-1513 Modified by Ila for CWP
* @Jira : Edge-123593 Added generatePriceScheduleLineItem, generateDiscountLineItems & generatePriceScheduleDiscountAssociations by Aman Soni
Shubhi V 			28-June-2020    Edge-149830 device care pricing
Shubhi V 			06-July-2020    EDGE-147513    BillingAcc checks
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated offer name using variable NGUC_OFFER_NAME from Telstra_Collaboration to Adaptive Collaboration

*/  
@isTest
public class PricingTestDataFactory {   
    /* Ms response payload  edge-140157*/
    public static string msresponse='{"chargeLineItems":{"unitPrice__c":0.3,"contractTerm__c":12,"businessID__c":"DMCAT_RecurringCharge_000808","unitTotalContractValue__c":0.0,"priceScheduleLineItem":[{"id":"PSLI1","fromPeriod__c":1,"toPeriod__c":3,"tierLineItems":[{"toUnit__c":500,"fromUnit__c":201,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"},{"toUnit__c":99999,"fromUnit__c":501,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"},{"toUnit__c":200,"fromUnit__c":51,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"},{"toUnit__c":10,"fromUnit__c":1,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"},{"toUnit__c":20,"fromUnit__c":11,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"},{"toUnit__c":50,"fromUnit__c":21,"discounted_Price__c":0.3,"appliedDiscountAmount__c":0.0,"rateCardLineIdentifier__c":"TierLine Item"}],"applicableDiscounts":[{"id":"aBE2O00000005cIWAQ","description":"Early Adopter Discount","discountAmount":"100.0%"}],"applicationDuration__c":3.0}]}}';
    final static String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c; //DIGI-5648
    // method to generate account
    public static Account generateAccount(){
        String recordName = 'testAccountDiscount';
        Account acc = new Account(Name = recordName);
          acc.Customer_Status__c='Active';
        return acc;
    }   
    /* methods to generate opportunity */   
    public static Opportunity generateOpportunity(){
        Opportunity  opp = new Opportunity(Name='oppTest', StageName='Develop',  CloseDate = Date.today() );   
        return opp;
    }   
    public static Opportunity generateOpportunityForAccount(Account acc){
        Opportunity oppty = new Opportunity(Name='oppTest', AccountId=acc.Id, StageName='Develop',  CloseDate = Date.today());
        return oppty;
    }   
    /*method to creatre basket */
    public static cscfga__Product_Basket__c generateProductBasket(Account acc,Opportunity opp){
        String recordName = 'Test Basket ';
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c(Name = recordName, csordtelcoa__Account__c =acc.Id,cscfga__Opportunity__c= opp.Id);
        return basket;
    }   
    ///METHOD TO CRETAE PRICE ITEM  
    public static cspmb__Price_Item__c generatePriceItem(String name){
        cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c(Name=name, cspmb__Is_Active__c = true, Charge_Id__c='DMCAT_RecurringCharge_000654',
          Offer__c = 'Committed Data');
        return priceItem;
    } 
    /*-----------------------------------------------------------------------------
    Method Name -generateMOBILITYriceItem_discount
    Object      -cspmb__Price_Item__c (mobility)
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c createMobilePriceItem(String externalId){
      cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
          Name = 'Mobility',
          cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
          cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
          cspmb__Billing_Frequency__c = 'Monthly',
          cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
          cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
          cspmb__Is_Active__c = false,
          cspmb__Is_Authorization_Required__c = false,
          cspmb__Is_One_Off_Discount_Allowed__c = false,
          cspmb__Is_Recurring_Discount_Allowed__c = false,
          cspmb__Price_Item_Code__c = 'Mobility',
			Commercial_Product_Code__c = 'Mobility', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
          cspmb__Product_Definition_Name__c = 'Mobility',
          cspmb__Recurring_Charge__c = 4.6,
          External_Id__c = externalId,
          SRM__c = 0.0,
          Package_Name__c = 'Corporate Mobile Plus',
          Type__c = 'Data',
          Unit_Of_Measure__c = 'per Mobility Plan',
          BillInAdvance__c = 'true',
          BillingSpecId__c = 'BSRC001_CB',
          Billing_Description__c = 'Corporate Mobile Plus - Data SIM $5 Plan',
          ChargeFrequency__c = 'Monthly',
          ChargeType__c = 'RC',
          Currency__c = 'AUD',
          Frequency__c = 'Monthly',
          Prorate__c = 'false',
          taxTreatment__c = 'GST Applicable',
          Offer_Id__c = 'DMCAT_Offer_000646',
          Plan__c = 'Data SIM $5',
          ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
          Charge_Id__c='DMCAT_RecurringCharge_000654',
          Offer__c = 'Committed Data');
      return price_Item;
    }  
    /*-----------------------------------------------------------------------------
    Method Name -generateMobilePriceItemFairPlay
    Object      -cspmb__Price_Item__c (mobility)
    Author      -Aman Soni || EDGE-143527 
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c generateMobilePriceItemFairPlay(String externalId){
      cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
          Name = 'Mobility',
          cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
          cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
          cspmb__Billing_Frequency__c = 'Monthly',
          cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
          cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
          cspmb__Is_Active__c = false,
          cspmb__Is_Authorization_Required__c = false,
          cspmb__Is_One_Off_Discount_Allowed__c = false,
          cspmb__Is_Recurring_Discount_Allowed__c = false,
          cspmb__Price_Item_Code__c = 'Mobility',
			Commercial_Product_Code__c = 'Mobility', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
          cspmb__Product_Definition_Name__c = 'Mobility',
          cspmb__Recurring_Charge__c = 68.18,
          External_Id__c = externalId,
          SRM__c = 0.0,
          Package_Name__c = 'Corporate Mobile Plus',
          Type__c = 'Voice and Data',
          Unit_Of_Measure__c = 'per Mobility Plan',
          BillInAdvance__c = 'true',
          BillingSpecId__c = 'BSRC001_CB',
          Billing_Description__c = 'Corporate mobile plus - local plan',
          ChargeFrequency__c = 'Monthly',
          ChargeType__c = 'RC',
          Currency__c = 'AUD',
          Frequency__c = 'Monthly',
          Prorate__c = 'false',
          taxTreatment__c = 'GST Applicable',
          Offer_Id__c = 'DMCAT_Offer_000646',
          Plan__c = 'Local',
          ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
          Charge_Id__c='DMCAT_RecurringCharge_000654',
          Offer__c = 'FairPlay Data');
      return price_Item;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateNGUCPriceItem_discount
    Object      -cspmb__Price_Item__c (NGUC)
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c generateNGUCPriceItem_discount(String name, String contractType, String ChargeId){
        cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
            Name = name,
            Contract_Type__c = contractType,
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Price_Item_Code__c = 'Unified Communication Device',
			Commercial_Product_Code__c = 'Unified Communication Device', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Unified Communication Device',
            External_Id__c = ChargeId,
            Charge_Id__c=ChargeId,
            // Package_Name__c = 'Telstra Collaboration', DIGI-5648
            Package_Name__c = NGUC_OFFER_NAME,
            Type__c = 'IP Handsets Device',
            Unit_Of_Measure__c = 'per Device',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Polycom IP phone VVX 411',
            ChargeFrequency__c = 'Monthly',
            Currency__c = 'AUD',
            Offer_Id__c = 'DMCAT_Offer_000618'
            );
        return price_Item;
    }    
    /*-----------------------------------------------------------------------------
    Method Name -generateNGUCPriceItem_Voice
    Object      -cspmb__Price_Item__c (NGUC Voice)
    Author      -Gnana
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c generateNGUCPriceItem_Voice(String name, String ChargeId){
        cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
            Name = name,
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = false,
            cspmb__Price_Item_Code__c = 'Next Generation Voice',
			Commercial_Product_Code__c = 'Next Generation Voice', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Next Generation Voice',
            External_Id__c = 'dmcat_112',
            Charge_Id__c=ChargeId,
            // Package_Name__c = 'Telstra Collaboration', DIGI-5648
            Package_Name__c = NGUC_OFFER_NAME,            
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Polycom IP phone VVX 411',
            Offer_Id__c = 'DMCAT_Offer_000618'
            );
        return price_Item;
    }
    ///METHOD TO CRETAE ADDON 
    public static cspmb__Add_On_Price_Item__c generateAddOnPriceItem(){
          cspmb__Add_On_Price_Item__c  addOnPI = new cspmb__Add_On_Price_Item__c(
            Name = 'Basic',
            cspmb__Add_On_Price_Item_Code__c = 'Mobile Access',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,05,16),
            cspmb__Product_Definition_Name__c = 'Mobile Access',
            cspmb__Recurring_Charge__c = 10.0,
            External_Id__c = 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_101',
            Price_Override__c = false,
            ProdSpecId__c = 'DMCAT_ProductSpecification_000263',
            BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSRC001_CB',
            Billing_Description__c = 'International call pack - basic',
            Offer_Id__c = 'DMCAT_Offer_000646',
            Offer_Name__c = 'Corporate Mobile Plus'
              
            );
        return addOnPI;
    }
     /*-----------------------------------------------------------------------------
    Method Name -generateDiscountLevelPLan
    Object      -cspmb__Discount_Level__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Discount_Level__c generateDiscountLevelPLan(String Name, String businessId, Account acc,String plan,String datapackPlan){
        cspmb__Discount_Level__c discountLevel1 = new cspmb__Discount_Level__c();         
            discountLevel1.Name = Name;
            discountLevel1.cspmb__Discount_Type__c = 'Amount';
            discountLevel1.cspmb__Discount__c = 4.6;
            discountLevel1.cspmb__Discount_Values__c = '4.6';
            discountLevel1.Effective_End_Date__c = Date.today()+1;
            discountLevel1.Effective_Start_Date__c = Date.today()-1;
            discountLevel1.Plan__c = plan;
            discountLevel1.Business_ID__c = businessId;
            discountLevel1.Data_Pack_Plan__c = datapackPlan;
            discountLevel1.Discount_Application_Point__c = 'Billing Pre-Itemization';
            discountLevel1.Is_Delegated__c = true;
            discountLevel1.is_Unlimited__c = true;
            discountLevel1.cspmb__duration__c=2.0;
            discountLevel1.Description__c='test plan';
            if(acc!=null)
                discountLevel1.Account__c = acc.id;
        system.debug('discountLevel1--->'+discountLevel1);
        return discountLevel1;
    }
     /*-----------------------------------------------------------------------------
    Method Name -generateDiscountAssociation2
    Object      -cspmb__Discount_Association__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Discount_Association__c generateDiscountAssociation2(cspmb__Price_Item__c pi, cspmb__Add_On_Price_Item__c addOnPI, cspmb__Discount_Level__c dl){
        cspmb__Discount_Association__c discountAssoc1= new cspmb__Discount_Association__c();
        if(pi != null){
            discountAssoc1.cspmb__Price_Item__c = pi.id;
        }
        if(addOnPI != null){
            discountAssoc1.cspmb__Add_On_Price_Item__c = addOnPI.Id;
        }
        discountAssoc1.cspmb__Discount_Level__c = dl.id;
        //insert discountAssoc;
        return discountAssoc1;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateproceItemaddonAssociation
    Object      -cspmb__Discount_Association__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item_Add_On_Price_Item_Association__c generateproceItemaddonAssociation(cspmb__Price_Item__c pi, cspmb__Add_On_Price_Item__c addon){
        cspmb__Price_Item_Add_On_Price_Item_Association__c addonassoc1 = new cspmb__Price_Item_Add_On_Price_Item_Association__c(cspmb__Add_On_Price_Item__c=addon.id,
                                     cspmb__Price_Item__c=pi.id,cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,05,16));

        //insert discountAssoc;
        return addonassoc1;
    }
    ///METHOD TO CRETAE ADDON 
    public static cspmb__Add_On_Price_Item__c generateAddOn(string chargeId,String name,String externalid){
          cspmb__Add_On_Price_Item__c  addOnPI = new cspmb__Add_On_Price_Item__c(
            Name = name,
            cspmb__Add_On_Price_Item_Code__c = 'Mobile Access',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,05,16),
            cspmb__Product_Definition_Name__c = 'Mobile Access',
            cspmb__Recurring_Charge__c = 10.0,
            External_Id__c = externalid,
            Price_Override__c = false,
            ProdSpecId__c = 'DMCAT_ProductSpecification_000263',
            BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSRC001_CB',
            Billing_Description__c = 'International call pack - basic',
            Offer_Id__c = 'DMCAT_Offer_000646',
            Offer_Name__c = 'Corporate Mobile Plus',
            Charge_id__c=chargeId
            );
        return addOnPI;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateSolution
    Object      -csord__Solution__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/    
    public static csord__Solution__c generateSolution(String name){
        csord__Solution__c solution = new csord__Solution__c();
        solution.Name = name;
        solution.csord__Identification__c = 'Solution Management';
        solution.csord__Status__c = 'Completed';
        solution.cssdm__total_contract_value__c = 0.0;
        solution.cssdm__total_one_off_charge__c = 0.0;
        solution.cssdm__total_recurring_charge__c = 0.0;     
        return solution;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateChargeLineItem
    Object      -Charge_Line_Item__c
    Author      -Gnana
    -------------------------------------------------------------------------------*/
    public static Charge_Line_Item__c generateChargeLineItem(String correlationId, String guId, String pcIdentifier){       
        Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c(CorrelationId__c = correlationId,guid__c=guId, Product_Charge_Identifier__c=pcIdentifier);        
        return chargeLineItem1;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generatePriceScheduleLineItem
    Object      -Price_Schedule_Line_Item__c
    Author      -Aman Soni || EDGE-123593
    -------------------------------------------------------------------------------*/
   public static Price_Schedule_Line_Item__c generatePriceScheduleLineItem(String fromPeriod, String toPeriod, Decimal unitPrice, Charge_Line_Item__c cliId){      
        Price_Schedule_Line_Item__c psli = new Price_Schedule_Line_Item__c(fromPeriod__c = fromPeriod,toPeriod__c=toPeriod, unitPrice__c=unitPrice,chargeInstance__c=cliId.id);        
        return psli;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateDiscountLineItems
    Object      -Discount_Line_Item__c
    Author      -Aman Soni || EDGE-123593
    -------------------------------------------------------------------------------*/
    public static Discount_Line_Item__c generateDiscountLineItems(String name, String discountValue, String discountClass,Charge_Line_Item__c cliId){      
        Discount_Line_Item__c discountLineItem = new Discount_Line_Item__c(Name=name, discountValue__c=discountValue,discountClass__c= discountClass,chargeInstance__c=cliId.id);
        if(discountClass == 'Percent'){
            discountValue+='%'; 
        }
        return discountLineItem;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generatePriceScheduleDiscountAssociations
    Object      -Price_Schedule_Discount_Association__c
    Author      -Aman Soni || EDGE-123593
    -------------------------------------------------------------------------------*/
    public static Price_Schedule_Discount_Association__c generatePriceScheduleDiscountAssociations(Price_Schedule_Line_Item__c priceScheduleInstance,Discount_Line_Item__c discountInstance){      
        Price_Schedule_Discount_Association__c psda = new Price_Schedule_Discount_Association__c(priceScheduleInstance__c=priceScheduleInstance.id, discountInstance__c=discountInstance.id);
        return psda;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateDiscountLineItem
    Object      -Discount_Line_Item__c
    Author      -Gnana
    -------------------------------------------------------------------------------*/
    public static Discount_Line_Item__c generateChargeLineItem(String cli_Id){      
        Discount_Line_Item__c discountLineItem = new Discount_Line_Item__c(chargeInstance__c=cli_Id );
        return discountLineItem;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generatePricingMSResponse
    Object      -PricingMSResponseObject__c
    Author      -Gnana
    -------------------------------------------------------------------------------*/
    public static PricingMSResponseObject__c generatePricingMSResponse(Charge_Line_Item__c cli, String errorResponse, String payLoad){       
        PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
        pricingMSResponse.CLI_Instance_ID__c= cli.id;
        pricingMSResponse.ErrorDescription__c=errorResponse;
        pricingMSResponse.ResponsePayload__c=payLoad;
        pricingMSResponse.Status__c='success';
        pricingMSResponse.TCV_Value__c= Integer.valueof((Math.random() * 100));
        return pricingMSResponse;
    }
    /*-----------------------------------------------------------------------------
    Method Name -generateSolutionAttachment
    Object      -attachment
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
     public static Attachment generateSolutionAttachment(String solutionId,String attBody){
        Attachment att=new attachment();
        att.name='solutionDetails.JSON';
        att.body = Blob.valueOf(attBody);
        att.parentId = solutionId;
        return att;
    }
     /*-----------------------------------------------------------------------------
    Method Name -generateRateCard
    Object      -cspmb__Rate_Card__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Rate_Card__c generateRateCard(String offerId,String ratecardCode){
        cspmb__Rate_Card__c rateCard=new cspmb__Rate_Card__c();
        rateCard.Offer_Id__c=offerId;
        rateCard.cspmb__Rate_Card_Code__c=ratecardCode;  
        rateCard.cspmb__Effective_End_Date__c=Date.today()+1;
        rateCard.cspmb__Effective_Start_Date__c=Date.today()-1;
        return rateCard;
    }
         /*-----------------------------------------------------------------------------
    Method Name -generateRateCardLine
    Object      -cspmb__Rate_Card_Line__c
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Rate_Card_Line__c generateRateCardLine(Decimal toUnit,Decimal fromUnit,String ratecardId,String rateLineGroupIdentifier){
        cspmb__Rate_Card_Line__c rateCardLine=new cspmb__Rate_Card_Line__c();
        rateCardLine.toUnit__c=toUnit;
        rateCardLine.fromUnit__c=fromUnit;  
        rateCardLine.cspmb__Rate_Card__c=ratecardId;
        rateCardLine.cspmb__Effective_Start_Date__c=Date.today()-1;
        rateCardLine.cspmb__Effective_End_Date__c=Date.today()+1;
        rateCardLine.rateLineGroupIdentifier__c=rateLineGroupIdentifier;
        return rateCardLine;
    }
    /*-----------------------------------------------------------------------------
    Method Name - createMobileDevicePriceItem
    Object      -cspmb__Price_Item__c (mobility)
    Author      -Shubhi
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c createMobileDevicePriceItem(String externalId){//DMCAT_Offer_000783_DMCAT_ProductSpecification_000423_DMCAT_NonRecurringCharge_000511_2151
      cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
          Name = 'Mobile Device',
          cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
          cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
          cspmb__Is_Active__c = false,
          cspmb__Is_One_Off_Discount_Allowed__c = true,
          cspmb__Price_Item_Code__c = 'Mobile Device',
			Commercial_Product_Code__c = 'Mobile Device', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
          cspmb__Product_Definition_Name__c = 'Mobile Device',
          External_Id__c = externalId,
          Package_Name__c = 'Device Outright Purchase',
          Type__c = 'Mobile Handset',
          Unit_Of_Measure__c = 'per device',
          BillInAdvance__c = 'true',
          BillingSpecId__c = 'BSOTC001_CB',
          Billing_Description__c = 'Apple iPhone 11 128GB Black 4GX',
          ChargeType__c = 'OC',
          Currency__c = 'AUD',
          taxTreatment__c = 'GST Applicable',
          Offer_Id__c = 'DMCAT_Offer_000783',
          ProdSpecId__c = 'DMCAT_ProductSpecification_000423',
          Charge_Id__c='DMCAT_NonRecurringCharge_000511');
      return price_Item;
    }
   /*-----------------------------------------------------------------------------
    Method Name -createCwpPriceItem
    Object      -cspmb__Price_Item__c (mobility)
    Author      -Ila
    Jira  		-DPG-1513
    -------------------------------------------------------------------------------*/
    public static cspmb__Price_Item__c createCwpPriceItem(String externalId){
      cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
         Name = 'Mobility',
            cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
            cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
            cspmb__Billing_Frequency__c = 'Monthly',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
            cspmb__Is_Active__c = false,
            cspmb__Is_Authorization_Required__c = false,
            cspmb__Is_One_Off_Discount_Allowed__c = false,
            cspmb__Is_Recurring_Discount_Allowed__c = false,
            cspmb__Price_Item_Code__c = 'Mobility',
			Commercial_Product_Code__c = 'Mobility', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Mobility',
            cspmb__Recurring_Charge__c = 4.6,
            External_Id__c = externalId,
            SRM__c = 0.0,
            Package_Name__c = 'Connected Workplace',
            Type__c = 'Voice and Data',
            Unit_Of_Measure__c = 'per Mobility Plan',
            BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSRC001_CB',
            Billing_Description__c = 'Mobile Worker - national plan',
            ChargeFrequency__c = 'Monthly',
            ChargeType__c = 'RC',
            Currency__c = 'AUD',
            Frequency__c = 'Monthly',
            Prorate__c = 'false',
            taxTreatment__c = 'GST Applicable',
            Offer_Id__c = '	DMCAT_Offer_000303',
            Plan__c = 'National',
            ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
            Offer__c = 'FairPlay Data');
      return price_Item;
    }
     ///Added by Ila as part of DPG-1513 to create Addon for CWP
    public static cspmb__Add_On_Price_Item__c generateAddOnPriceItemCwp(){
          cspmb__Add_On_Price_Item__c  addOnPI = new cspmb__Add_On_Price_Item__c(
            Name = '3G Standard Retail',
            cspmb__Add_On_Price_Item_Code__c = 'Mobile Access',
            //cspmb__Add_On_Price_Item_Description__c = 'Manually Created',
            cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
            cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
            cspmb__Billing_Frequency__c = 'Monthly',
            cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
            cspmb__Effective_Start_Date__c = Date.newInstance(2019,05,16),
            cspmb__Is_Active__c = false,
            cspmb__Is_Authorization_Required__c = false,
            cspmb__Is_One_Off_Discount_Allowed__c = false,
            cspmb__Is_Recurring_Discount_Allowed__c = false,
            cspmb__Product_Definition_Name__c = 'Mobile Access',
            cspmb__Recurring_Charge__c = 10.0,
            cspmb__Sequence__c = 0.0,
            External_Id__c = 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000497_101',
            Price_Override__c = false,
            ProdSpecId__c = 'DMCAT_ProductSpecification_000263',
            BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSRC001_CB',
            Billing_Description__c = '3G Standard Retail',
            Frequency__c = 'Monthly',
            Offer_Id__c = 'DMCAT_Offer_000646',
            Offer_Name__c = 'Postpaid Handheld',
            Prorate__c = 'false',
            Unit_Of_Measure__c = 'each',
            taxTreatment__c = 'GST Applicable');
        return addOnPI;
    }
    /*-----------------------------------------------------------------------------
    Method Name -getNextGenEM solution string
    Object      -string
    Author      -shubhi
    Jira  		-Edge-149830
    -------------------------------------------------------------------------------*/
	public static String getNextGenEMSolutionJson(){
		return '{"8642c730-69b6-39b4-3ba7-93417ca362d6":{"ischildApplicable":{"name":"ischildApplicable","value":"true"},"GUID":{"name":"GUID","label":"","readOnly":false,"showInUi":false,"required":false,"type":"String","value":"8642c730-69b6-39b4-3ba7-93417ca362d6","displayColumn":null,"displayValue":null,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"BusinessId":{"name":"BusinessId","label":"BusinessId","readOnly":false,"showInUi":false,"required":false,"type":"String","value":"","displayColumn":null,"displayValue":null,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"OC":{"name":"OC","label":"One-off charge (Ex. GST)","readOnly":true,"showInUi":true,"required":false,"type":"Calculation","value":190,"displayColumn":"cspmb__One_Off_Charge__c","displayValue":190,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"taxTreatment":{"name":"taxTreatment","label":"taxTreatment","readOnly":false,"showInUi":false,"required":false,"type":"Calculation","value":"GST Applicable","displayColumn":"taxTreatment__c","displayValue":"GST Applicable","other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"IsRedeemFundCheckNeeded":{"name":"IsRedeemFundCheckNeeded","label":"IsRedeemFundCheckNeeded","readOnly":false,"showInUi":false,"required":false,"type":"Boolean","value":true,"displayColumn":null,"displayValue":true,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"RedeemFund":{"name":"RedeemFund","label":"Redeem Fund","readOnly":false,"showInUi":true,"required":false,"type":"Decimal","value":"5","displayColumn":null,"displayValue":"5","other":"","error":false,"status":true,"errorMessage":"","helpText":"Redeem your fund against the selected device(Non-Negative Value)","validationErrorMessage":"Please Enter a Non-Negative Value!"}},"c1827a8a-910e-505f-510d-c3ee381e338e":{"OC":{"name":"OC","label":"One-off charge (Ex. GST)","readOnly":false,"showInUi":true,"required":false,"type":"Calculation","value":1162.72,"displayColumn":"cspmb__One_Off_Charge__c","displayValue":1162.72,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"EarlyTerminationCharge":{"name":"EarlyTerminationCharge","label":"Balance Due on Device","readOnly":false,"showInUi":false,"required":false,"type":"Calculation","value":"","displayColumn":null,"displayValue":null,"other":"","options":[],"error":false,"status":true,"errorMessage":"","helpText":"Remaining device(s) only charge. May vary based on actual disconnection date. Device(s) owned outright upon payment.","validationErrorMessage":""},"RedeemFund":{"name":"RedeemFund","label":"Redeem Fund","readOnly":false,"showInUi":true,"required":false,"type":"Decimal","value":"30","displayColumn":null,"displayValue":"30","other":"","error":false,"status":true,"errorMessage":"","helpText":"Redeem your fund against the selected device(Non-Negative Value)","validationErrorMessage":"Please Enter a Non-Negative Value!"},"taxTreatment":{"name":"taxTreatment","label":"taxTreatment","readOnly":false,"showInUi":false,"required":false,"type":"Calculation","value":"GST Applicable","displayColumn":"taxTreatment__c","displayValue":"GST Applicable","other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"PriceItemId":{"name":"PriceItemId","label":"PriceItemId","readOnly":false,"showInUi":false,"required":false,"type":"Calculation","value":"a3u2O0000007AfRQAU","displayColumn":"Id","displayValue":"a3u2O0000007AfRQAU","other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"IsRedeemFundCheckNeeded":{"name":"IsRedeemFundCheckNeeded","label":"IsRedeemFundCheckNeeded","readOnly":false,"showInUi":false,"required":false,"type":"Boolean","value":true,"displayColumn":null,"displayValue":true,"other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"BusinessId":{"name":"BusinessId","label":"BusinessId","readOnly":false,"showInUi":false,"required":false,"type":"Calculation","value":"DMCAT_NonRecurringCharge_000511","displayColumn":"Charge_Id__c","displayValue":"DMCAT_NonRecurringCharge_000511","other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""},"Quantity":{"name":"Quantity","label":"Quantity","readOnly":false,"showInUi":false,"required":false,"type":"String","value":"1","displayColumn":null,"displayValue":"1","other":"","error":false,"status":true,"errorMessage":"","helpText":"","validationErrorMessage":""}}}';
	}
   /*-----------------------------------------------------------------------------
    Method Name -generateProductConfiguration
    Object      -string
    Author      -shubhi
    Jira  		-EDGE-147513
    -------------------------------------------------------------------------------*/
    public static cscfga__Product_Configuration__c generateProductConfiguration(String ConfigurationType1,string Type,string basketid,string solutionId,String prddeffinitionId){
    	String recordName = 'Test Name ';
    	cscfga__Product_Configuration__c prodConfiguration=new cscfga__Product_Configuration__c();
      	prodConfiguration = new cscfga__Product_Configuration__c(Name = recordName, 
          //cscfga__Product_Definition__c = prddeffinitionId,
         Quantity_Product_Configuration__c = 2, 
         cscfga__Product_Basket__c = basketid,
         cssdm__solution_association__c= solutionId, Type__c=Type,ConfigurationType1__c=ConfigurationType1 );
    	return prodConfiguration;
  	}
     /*-----------------------------------------------------------------------------
    Method Name -generateProductConfiguration
    Object      -string
    Author      -shubhi
    Jira  		-Edge-EDGE-147513
    -------------------------------------------------------------------------------*/
    public static csord__Subscription__c generateSubscriptionWithBillacc(string solutionId,String bilingAccid,String accid,string orderid){
    	csord__Subscription__c testSubscription7 = new csord__Subscription__c();
        testSubscription7.Name = 'TestSubsforTest7';
        testSubscription7.csord__Account__c = accid;
        testSubscription7.csord__Order__c = orderid;
        testSubscription7.csord__Identification__c = 'test7';
        //testSubscription7.Site__c=site1.Id;
        testSubscription7.cssdm__solution_association__c=solutionId;
        testSubscription7.csord__Status__c = 'Active';
       	testSubscription7.Billing_Account__c = bilingAccid;
        return testSubscription7;
  	}
}
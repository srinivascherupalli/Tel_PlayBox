/*
1.     Pawan Singh         09/08/2021       DIGI-5648    Updated offer name using variable NGUC_OFFER_NAME from Telstra_Collaboration to Adaptive Collaboration
*/ 
@isTest
public class TestDataFactory {

	public static String jsonNumberOfNumber = '{' +
	    '"configurations": [{' +
	    '"guid": "4d71aae1-d1c9-dd39-0707-90f67c5ed03b",'+
	    '"listCode": "No Entry Line",'+
	    '"status": "RESERVED",'+
	    '"rangeTo": 798234565,'+
	    '"rangeFrom": 798234556,'+
	    '"FNN": "3"'+
	    '}],' +
	    '"schema": {'+
	    '"name": "NumberManagementv1",'+
	    '"id": "a792O00000000DEQAY",'+
	    '"attributes": [{'+
	    '"type": "String",'+
	    '"showInUI": true,'+
	    '"required": false,'+
	    '"name": "FNN"'+
	    '}, {'+
	    '"type": "String",'+
	    '"showInUI": true,'+
	    '"required": false,'+
	    '"name": "rangeFrom"'+
	    '}, {'+
	    '"type": "String",'+
	    '"showInUI": true,'+
	    '"required": false,'+
	    '"name": "rangeTo"'+
	    '}, {'+
	    '"type": "String",'+
	    '"showInUI": true,'+
	    '"required": false,'+
	    '"name": "status"'+
	    '}, {'+
	    '"type": "String",'+
	    '"showInUI": true,'+
	    '"required": false,'+
	    '"name": "listCode"'+
	    '}]'+
	    '}'+
	    '}';

	public static String jsonDefaultTransitionJSOn = '{'+
	    '"Source_System_Id": "Replicator",'+
	    '"site": [{'+
	    '"siteName": null,'+
	    '"productList": [],'+
	    '"Error_Description": "Services not found",'+
	    '"Error_Code": "ERR114",'+
	    '"ADBOR_Id": "180819951"'+
	    '}, {'+
	    '"siteName": null,'+
	    '"productList": [{'+
	    '"serviceList": [{'+
	    '"Service_Type": "Voice",'+
	    '"service": [{'+
	    '"serviceExtension": [{'+
	    '"Services_From": "0353389801",'+
	    '"Services_To": "0353389899"'+
	    '},                     {'+
	    '"Services_From": "0353389801",'+
	    '"Services_To": "0353389899"'+
	    '}],'+
	    '"Service_Type": "Voice",'+
	    '"Service_Id": "0243297925",'+
	    '"IsInflight": null,'+
	    '"In_Flight_Order_Id": "",'+
	    '"In_Flight_Legacy_System": "AXIS",'+
	    '"In_Flight_Flag": "N",'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}],'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}],'+
	    '"Product_Type": "ISDN BRA",'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}, {'+
	    '"serviceList": [{'+
	    '"Service_Type": "Voice",'+
	    '"service": [{'+
	    '"serviceExtension": [],'+
	    '"Service_Type": "Voice",'+
	    '"Service_Id": "0243293471",'+
	    '"IsInflight": null,'+
	    '"In_Flight_Order_Id": "",'+
	    '"In_Flight_Legacy_System": "AXIS",'+
	    '"In_Flight_Flag": "N",'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}],'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}],'+
	    '"Product_Type": "PSTN",'+
	    '"disableCheck": null,'+
	    '"checkValue": true'+
	    '}],'+
	    '"Error_Description": "",'+
	    '"Error_Code": "",'+
	    '"ADBOR_Id": "262135088"'+
	    '}],'+
	    '"Error_Description": "",'+
	    '"Error_Code": "",'+
	    '"Correlation_Id": "SFDC_REP_GETSERVICE10df1a91f01a44af1e",'+
	    '"CIDN": "7500861181"'+
	    '}';

    public static String jsonSigmaString = '{'+
      '"productOffering": {'+
        '"specId": "DMCAT_Offer_000303",'+
        '"name": "Connected Workplace",'+
        '"invoiceDefinition": "Invoice_Def_1",'+
        '"products": ['+
          '{'+
            '"specId": "DMCAT_ProductOffering_000302",'+
            '"productStaticCharacteristics": ['+
              '{'+
                '"name": "CommPhases",'+
                '"value": "true"'+
              '},'+
              '{'+
                '"name": "TechPhases",'+
                '"value": "true"'+
              '},'+
              '{'+
                '"name": "AssurancePhase",'+
                '"value": "true"'+
              '},'+
              '{'+
                '"name": "TechPhases",'+
                '"value": "false"'+
              '}'+
            '],'+
            '"endDate": "2099-12-31T00:00:00.000Z",'+
            '"name": "IP Network",'+
            '"action": "New",'+
            '"associationEndDate": "2099-12-31T00:00:00.000Z",'+
            '"type": "Default_Enterprise_Offer",'+
            '"startDate": "2018-08-28T00:00:00.000Z",'+
            '"associationStartDate": "2018-08-28T00:00:00.000Z",'+
            '"products": ['+
              '{'+
                '"specId": "DMCAT_ProductSpecification_000163",'+
                '"productStaticCharacteristics": ['+
                  '{'+
                    '"name": "CommPhases",'+
                    '"value": "true"'+
                  '},'+
                  '{'+
                    '"name": "TechPhases",'+
                    '"value": "true"'+
                  '},'+
                  '{'+
                    '"name": "AssurancePhase",'+
                    '"value": "true"'+
                  '},'+
                  '{'+
                    '"name": "test",'+
                    '"value": "true"'+
                  '}'+
                '],'+
                '"endDate": "2099-12-31T00:00:00.000Z",'+
                '"name": "Internet Protection Solution",'+
                '"action": "Update",'+
                '"attributes": ['+
                  '{'+
                    '"default": "Web and Mail",'+
                    '"values": ['+
                      '"Hybrid",'+
                      '"Web and Mail",'+
                      '"Web",'+
                      '"Mail"'+
                    '],'+
                    '"name": "Internet Protection Solution Type",'+
                    '"interfaceName": "InternetProtectionSolutionType",'+
                    '"type": "uiLOV",'+
                    '"staticCharacteristics": ['+
                      '{'+
                        '"name": "AssurancePhase",'+
                        '"value": "true"'+
                      '},'+
                      '{'+
                        '"name": "TechPhases",'+
                        '"value": "true"'+
                      '},'+
                      '{'+
                        '"name": "TechPhases",'+
                        '"value": "false"'+
                      '},'+
                      '{'+
                        '"name": "test",'+
                        '"value": "true"'+
                      '}'+
                    '],'+
                    '"cpqDisplayName": ""'+
                  '}'+
                ']'+
              '}'+
            ']'+
          '}'+
        ']'+
      '}'+
    '}';
  
  static cscfga__Product_Configuration__c prodConfiguration;
  static csbb__Product_Configuration_Request__c prodConfRequest;
  static cscfga__Product_Basket__c basket;
  static cscfga__Product_Definition__c prodDefinition;
  static cscfga__Attribute_Definition__c attDefinition;
  static csord__Service__c service;
  static csord__Subscription__c subscription;
  static csoe__Non_Commercial_Schema__c nonCommSchema;
  static Account acc;
  static Attachment attach;
  static Opportunity opp;
  static cspmb__Price_Item__c priceItem;
  static cspmb__Add_On_Price_Item__c addOnPI;
  static cspmb__Discount_Level__c discountLevel;
  static cspmb__Discount_Association__c discountAssoc;
  static csord__Solution__c solution;
  final static String NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c; //DIGI-5648
  private static Integer recordNumber;

	public static cspmb__Price_Item__c generatePriceItem(){
		if (priceItem == null) {
			priceItem = new cspmb__Price_Item__c(Name = 'Price Test', cspmb__Is_Active__c = true);

			insert priceItem;
		}

		return priceItem;
	}

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
			Offer__c = 'Committed Data');
		insert price_item;

		return price_Item;
	}

	public static cspmb__Price_Item__c generateNGUCPriceItem(String name, String contractType, String ChargeId){
		cspmb__Price_Item__c price_item = new cspmb__Price_Item__c(
			Name = name,
			Contract_Type__c = contractType,
			cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
			cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
			//cspmb__Billing_Frequency__c = 'Monthly',
			cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
			cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
			cspmb__Is_Active__c = false,
			cspmb__Is_Authorization_Required__c = false,
			cspmb__Is_One_Off_Discount_Allowed__c = false,
			cspmb__Is_Recurring_Discount_Allowed__c = false,
			cspmb__Price_Item_Code__c = 'Unified Communication Device',
			Commercial_Product_Code__c = 'Unified Communication Device', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Unified Communication Device',
            //cspmb__Recurring_Charge__c = 4.6,
            External_Id__c = ChargeId,
            Charge_Id__c='DMCAT_RecurringCharge_000857',
            //SRM__c = 0.0,
            // Package_Name__c = 'Telstra Collaboration',
            Package_Name__c = NGUC_OFFER_NAME,
            Type__c = 'IP Handsets Device',
            Unit_Of_Measure__c = 'per Device',
            //BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Polycom IP phone VVX 411',
            ChargeFrequency__c = 'Monthly',
            //ChargeType__c = 'RC',
            Currency__c = 'AUD',
            //Frequency__c = 'Monthly',
            Prorate__c = 'false',
            taxTreatment__c = 'GST Applicable',
            Offer_Id__c = 'DMCAT_Offer_000618'
            //Plan__c = 'Data SIM $5',
            //ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
            //Offer__c = 'Committed Data'
            );
        insert price_item ;
        
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
			cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
			cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
			//cspmb__Billing_Frequency__c = 'Monthly',
			cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
			cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
			cspmb__Is_Active__c = false,
			cspmb__Is_Authorization_Required__c = false,
			cspmb__Is_One_Off_Discount_Allowed__c = false,
			cspmb__Is_Recurring_Discount_Allowed__c = false,
			cspmb__Price_Item_Code__c = 'Unified Communication Device',
			Commercial_Product_Code__c = 'Unified Communication Device', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Unified Communication Device',
            //cspmb__Recurring_Charge__c = 4.6,
            External_Id__c = 'dmcat_112',
            Charge_Id__c=ChargeId,
            //SRM__c = 0.0,
            // Package_Name__c = 'Telstra Collaboration',
            Package_Name__c = NGUC_OFFER_NAME,
            Type__c = 'IP Handsets Device',
            Unit_Of_Measure__c = 'per Device',
            //BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Polycom IP phone VVX 411',
            ChargeFrequency__c = 'Monthly',
            //ChargeType__c = 'RC',
            Currency__c = 'AUD',
            //Frequency__c = 'Monthly',
            Prorate__c = 'false',
            taxTreatment__c = 'GST Applicable',
            Offer_Id__c = 'DMCAT_Offer_000618'
            //Plan__c = 'Data SIM $5',
            //ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
            //Offer__c = 'Committed Data'
            );
            //insert price_item ;
        
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
			//Contract_Type__c = contractType,
			//cspmb__Apply_One_Off_Charge_Account_Discount__c = false,
			//cspmb__Apply_Recurring_Charge_Account_Discount__c = false,
			//cspmb__Billing_Frequency__c = 'Monthly',
			cspmb__Effective_End_Date__c = Date.newInstance(2099,12,31),
			cspmb__Effective_Start_Date__c = Date.newInstance(2019,09,10),
			cspmb__Is_Active__c = false,
			cspmb__Is_Authorization_Required__c = false,
			cspmb__Is_One_Off_Discount_Allowed__c = false,
			cspmb__Is_Recurring_Discount_Allowed__c = false,
			cspmb__Price_Item_Code__c = 'Next Generation Voice',
			Commercial_Product_Code__c = 'Next Generation Voice', //AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c
            cspmb__Product_Definition_Name__c = 'Next Generation Voice',
            //cspmb__Recurring_Charge__c = 4.6,
            External_Id__c = 'dmcat_112',
            Charge_Id__c=ChargeId,
            //SRM__c = 0.0,
            // Package_Name__c = 'Telstra Collaboration',
            Package_Name__c = NGUC_OFFER_NAME,
            //Type__c = 'IP Handsets Device',
            //Unit_Of_Measure__c = 'per Device',
            //BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSOTC001_CB',
            Billing_Description__c = 'Polycom IP phone VVX 411',
            ChargeFrequency__c = 'Monthly',
            //ChargeType__c = 'RC',
            Currency__c = 'AUD',
            //Frequency__c = 'Monthly',
            Prorate__c = 'false',
            taxTreatment__c = 'GST Applicable',
            Offer_Id__c = 'DMCAT_Offer_000618'
            //Plan__c = 'Data SIM $5',
            //ProdSpecId__c = 'DMCAT_ProductSpecification_000420',
            //Offer__c = 'Committed Data'
            );
            //insert price_item ;
        
        return price_Item;
    }
    
    public static cspmb__Add_On_Price_Item__c generateAddOnPriceItem(){
        if(addOnPI == null){
            addOnPI = new cspmb__Add_On_Price_Item__c(
            Name = 'Basic',
            cspmb__Add_On_Price_Item_Code__c = 'Mobile Access',
            cspmb__Add_On_Price_Item_Description__c = 'Manually Created',
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
            External_Id__c = 'DMCAT_Offer_000646_DMCAT_ProductSpecification_000420_DMCAT_RecurringCharge_000669_101',
            Price_Override__c = false,
            ProdSpecId__c = 'DMCAT_ProductSpecification_000263',
            BillInAdvance__c = 'true',
            BillingSpecId__c = 'BSRC001_CB',
            Billing_Description__c = 'International call pack - basic',
            Frequency__c = 'Monthly',
            Offer_Id__c = 'DMCAT_Offer_000646',
            Offer_Name__c = 'Corporate Mobile Plus',
            Prorate__c = 'false',
            Unit_Of_Measure__c = 'each',
            taxTreatment__c = 'GST Applicable');
            
            insert addOnPI;
        }
        
        return addOnPI;
    }
    
    public static cspmb__Discount_Level__c generateDiscountLevel(String Name, String businessId, Account acc){
        if(discountLevel == null){
            discountLevel = new cspmb__Discount_Level__c(          
                Name = Name,
                cspmb__Discount_Type__c = 'Amount',
                cspmb__Discount__c = 4.6,
                cspmb__Discount_Values__c = '4.6',
                Effective_End_Date__c = Date.today()+1,
                Effective_Start_Date__c = Date.today()-1,
                Plan__c = 'Data SIM $5',
                Business_ID__c = businessId,
                Data_Pack_Plan__c = '3 GB',
                Discount_Application_Point__c = 'Billing Pre-Itemization',
                Is_Delegated__c = true,
                is_Unlimited__c = true,
                cspmb__duration__c=2.0,
                Description__c='test plan',
                Account__c = acc.id);
            
            insert discountLevel;
        }
        
        return discountLevel;
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
            discountLevel1.Account__c = acc.id;
        system.debug('discountLevel1--->'+discountLevel1);
        return discountLevel1;
    }
    
    public static cspmb__Discount_Association__c generateDiscountAssociation(cspmb__Price_Item__c pi, cspmb__Add_On_Price_Item__c addOnPI, cspmb__Discount_Level__c dl){
        if(discountAssoc == null){
            discountAssoc = new cspmb__Discount_Association__c();
            if(pi != null){
                discountAssoc.cspmb__Price_Item__c = pi.id;
            }
            if(addOnPI != null){
                discountAssoc.cspmb__Add_On_Price_Item__c = addOnPI.Id;
            }
            discountAssoc.cspmb__Discount_Level__c = dl.id;
            insert discountAssoc;
        }
        
        return discountAssoc;
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
    
    public static csord__Solution__c generateSolution(String name){
        if(solution == null){
            solution = new csord__Solution__c();
            solution.Name = name;
            solution.csord__Identification__c = 'Solution Management';
            solution.csord__Status__c = 'Completed';
            solution.cssdm__total_contract_value__c = 0.0;
            solution.cssdm__total_one_off_charge__c = 0.0;
            solution.cssdm__total_recurring_charge__c = 0.0;
            
            insert solution;
        }
        
        return solution;
    }
    
    public static Charge_Line_Item__c generateChargeLineItem(String correlationId, String guId, String pcIdentifier){
        
        Charge_Line_Item__c chargeLineItem1 = new Charge_Line_Item__c(CorrelationId__c = correlationId,guid__c=guId, Product_Charge_Identifier__c=pcIdentifier);
        insert chargeLineItem1;
        
        return chargeLineItem1;
    }
    
    public static PricingMSResponseObject__c generatePricingMSResponse(Charge_Line_Item__c cli, String errorResponse, String payLoad){
        
        PricingMSResponseObject__c pricingMSResponse = new PricingMSResponseObject__c();
        pricingMSResponse.CLI_Instance_ID__c= cli.Id;
        pricingMSResponse.ErrorDescription__c=errorResponse;
        pricingMSResponse.ResponsePayload__c=payLoad;
        pricingMSResponse.Status__c='success';
        pricingMSResponse.TCV_Value__c= Integer.valueof((Math.random() * 100));
        
        insert pricingMSResponse;
        
        return pricingMSResponse;
    }

	public static Opportunity generateOpportunity(){
		if ( opp == null) {
			opp = new Opportunity(Name = 'oppTest', StageName = 'Develop',  CloseDate = Date.today() );

			insert opp;
		}

		return opp;
	}

	public static Opportunity generateOpportunityForAccount(Account acc){
		Opportunity oppty = new Opportunity(Name = 'oppTest', AccountId = acc.Id, StageName = 'Develop',  CloseDate = Date.today() );
		insert oppty;
		return oppty;
	}

	public static Attachment generateAttachment(String attName,String attBody, Id productConfigID){

		if (attach == null) {
			attach = new Attachment(
				Name = attName,
				body = Blob.valueOf(attBody),
				parentId = productConfigID
				);

			insert attach;
		}

		return attach;

	}

	public static csoe__Non_Commercial_Schema__c generateCommercialSchema(){
		String recordName = 'NumberManagementv1';

		if (nonCommSchema == null) {
			nonCommSchema = new csoe__Non_Commercial_Schema__c(Name = recordName);

			insert nonCommSchema;
		}

		return nonCommSchema;
	}

	public static csord__Subscription__c generateSubscription(){
		String recordName = 'Test Subscription';

		if (subscription == null) {
			subscription = new csord__Subscription__c(Name = recordName, csord__Identification__c = 'TestValue',csord__Status__c='Pending'                                                                                            
            );
			insert subscription;
		}

		return subscription;

	}

	public static csord__Service__c generateService(){
		String recordName = 'Test Service';

		if ( service == null ) {
			service = new csord__Service__c(Name = recordName, csordtelcoa__Product_Configuration__c = generateProductConfiguration().Id,
			                                csord__Status__c = 'Success', csord__Subscription__c = generateSubscription().Id,
			                                csord__Identification__c = 'TestValue'
			                                );

			insert service;
		}

		return service;
	}

	public static Account generateAccount(){
		String recordName = 'Test Account';

		if (acc == null) {
			acc = new Account(Name = recordName);
			insert acc;
		}

		return acc;
	}

	public static cscfga__Product_Basket__c generateProductBasket(){
		String recordName = 'Test Basket ';

		//csordtelcoa__Account__c

		if (basket == null) {
			basket = new cscfga__Product_Basket__c(Name = recordName, csordtelcoa__Account__c = generateAccount().Id);
			insert basket;
		}

		return basket;
	}

	/**
	   For Product Configuration
	 */
	public static cscfga__Product_Configuration__c generateProductConfiguration(){
		String recordName = 'Test Name ';
		if (recordNumber != null) {
			recordName += recordNumber;
		}

		//csordtelcoa__Replaced_Product_Configuration__c = Product configuration
		//cscfga__Product_Basket__r.csbb__Account__c == Product basket

		if (prodConfiguration == null) {
			prodConfiguration = new cscfga__Product_Configuration__c(Name = recordName, cscfga__Product_Definition__c = generateProductDefinition().Id,
			                                                         Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = generateProductBasket().Id );
			insert prodConfiguration;
		}

		return prodConfiguration;
	}

	public static csbb__Product_Configuration_Request__c genProdConfRequest(String defProdSpec, String recordName){

		cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = recordName + 'PD', Site_Agnostic__c = true, cscfga__Description__c = 'Test Description',
		                                                                                  product_Specification__c = defProdSpec );
		insert prodDefinition;

		cscfga__Product_Configuration__c prodConfiguration = new cscfga__Product_Configuration__c(Name = recordName + 'PC', cscfga__Product_Definition__c = prodDefinition.Id,
		                                                                                          Quantity_Product_Configuration__c = 2, cscfga__Product_Basket__c = generateProductBasket().Id );
		insert prodConfiguration;

		csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c( csbb__Postcode__c = '55332211', csbb__Product_Configuration__c = prodConfiguration.Id);
		insert pcr;

		return pcr;
	}

	public static List<cscfga__Product_Configuration__c> generateProductConfigurations(Integer numOfRecord){

		List<cscfga__Product_Configuration__c> prodConfigurationList = new List<cscfga__Product_Configuration__c>();
		for (Integer i = 0; i < numOfRecord; i++) {
			recordNumber = i;
			prodConfigurationList.add(generateProductConfiguration());
		}

		return prodConfigurationList;
	}

	/**
	   For Product Configuration Request
	 */
	public static csbb__Product_Configuration_Request__c generateProdutConfigurationRequest(){
		String testPostCode = '55332211';
		if (recordNumber != null) {
			testPostCode += recordNumber;
		}

		prodConfRequest = new csbb__Product_Configuration_Request__c(csbb__Postcode__c = testPostCode, csbb__Optionals__c = '{"selectedAddressDisplay":"71-73 SMITH ST NARACOORTE SA 5271","hiddenParam1":"100784813","selectedPcrs":"a5I2O0000003dHmUAI,a5I2O0000003d8LUAQ,a5I2O0000003dIGUAY,a5I2O0000003dHwUAI,a5I2O0000003dHrUAI"}',
		                                                             csbb__Product_Configuration__c = generateProductConfiguration().Id);
		insert prodConfRequest;

		return prodConfRequest;
	}

	public static List<csbb__Product_Configuration_Request__c> generateProdutConfigurationRequests(Integer numOfRecord){
		List<csbb__Product_Configuration_Request__c> prodConfRequests = new List<csbb__Product_Configuration_Request__c>();
		for (Integer i = 0; i < numOfRecord; i++) {
			recordNumber = i;
			prodConfRequests.add(generateProdutConfigurationRequest());
		}

		return prodConfRequests;
	}

	/**
	   For Product Definition
	 */
	public static cscfga__Product_Definition__c generateProductDefinition(){
		String recordName = 'Test Record ';
		if (recordNumber != null) {
			recordName += recordNumber;
		}

		if (prodDefinition == null) {
			prodDefinition = new cscfga__Product_Definition__c( Name = recordName, Site_Agnostic__c = true, cscfga__Description__c = 'Test Description',
			                                                    product_Specification__c = 'DMCAT_ProductSpecification_000074' );
			insert prodDefinition;
		}

		return prodDefinition;
	}

	public static cscfga__Product_Definition__c generateProductDefinition(String prodConfig, String definitionName){
		cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = definitionName, Site_Agnostic__c = true, cscfga__Description__c = 'Test Description',
		                                                                                  product_Specification__c = prodConfig );
		insert prodDefinition;

		return prodDefinition;
	}

	public static List<cscfga__Product_Definition__c> generateProductDefinitions(Integer numOfRecord){
		List<cscfga__Product_Definition__c> prodDefinitions = new List<cscfga__Product_Definition__c>();
		for (Integer i = 0; i < numOfRecord; i++) {
			recordNumber = i;
			prodDefinitions.add(generateProductDefinition());
		}

		return prodDefinitions;
	}

	//For Attribute Definition
	public static cscfga__Attribute_Definition__c generateAttributeDefinition(){
		String recordName = 'Test Record ';
		if (recordNumber != null) {
			recordName += recordNumber;
		}

		attDefinition = new cscfga__Attribute_Definition__c( Name = recordName, cscfga__Default_Value__c = 'default',   cscfga__Product_Definition__c = generateProductDefinition().Id );
		insert attDefinition;

		return attDefinition;
	}

	public static List<cscfga__Attribute_Definition__c> generateAttributeDefinitions(Integer numOfRecord){
		List<cscfga__Attribute_Definition__c> attDefinitions = new List<cscfga__Attribute_Definition__c>();
		for (Integer i = 0; i < numOfRecord; i++) {
			recordNumber = i;
			attDefinitions.add(generateAttributeDefinition());
		}

		return attDefinitions;
	}

	public static Site_Contact_Role__c generateSiteContactRole(Boolean executeDML, Contact contact, cscrm__Site__c site){
		Site_Contact_Role__c scp = new Site_Contact_Role__c();
		scp.Contact__c = contact.Id;
		scp.Site__c = site.Id;
		if (executeDML)
			insert scp;
		return scp;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateBillingAccount
	   Description -Billing Account test Data for test classes.
	   Object      -Billing_Account__c
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public static Billing_Account__c generateBillingAccount(String ban,string Status,String customerAccountName,String billingAccountOwner){
		Billing_Account__c billingAccount = new Billing_Account__c();
		billingAccount.Billing_Account_Number__c = ban;
		billingAccount.Status__c = status;
		billingAccount.Billing_Account_Owner__c = billingAccountOwner;
		billingAccount.Account__c = customerAccountName;
		return billingAccount;

	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateContact
	   Description -Contact test Data for test classes.
	   Object      -Contact
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public static contact generateContact(String firstName,String accountId,string status,String lastName,date lastVerifiedDate,String preferredCommunicationMethod){
		Contact contact = new contact();
		contact.FirstName = firstName;
		contact.AccountId = accountId;
		contact.Contact_Status__c = status;
		contact.LastName = lastName;
		contact.lastVerifiedDate__c = lastVerifiedDate;
		contact.Pref_Comm_Method__c = preferredCommunicationMethod;
		return contact;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateEnvironmentVariable
	   Description -EnvironmentVariable test Data for test classes.
	   Object      -EnvironmentVariable__c custom setting.
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public static EnvironmentVariable__c generateEnvironmentVariable(String name,String value){
		EnvironmentVariable__c certificate = new EnvironmentVariable__c();
		certificate.Name = name;
		certificate.Value__c = value;
		return certificate;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateCreditsAndAdjustments
	   Description -CreditsAndAdjustments test Data for test classes.
	   Object      -Credits_and_Adjustments__c
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/

	public static Credits_and_Adjustments__c generateCreditsAndAdjustments(string ban,string reasonCode,Date dateCredit,Decimal amount,String caseNumber){
		Credits_and_Adjustments__c creditAndAdjustment = new Credits_and_Adjustments__c();
		creditAndAdjustment.Reason_Code__c = reasonCode;
		creditAndAdjustment.Date_when_credit_was_given_to_customer__c = dateCredit;
		creditAndAdjustment.Credit_Change_Amount__c = amount;
		creditAndAdjustment.Billing_Account_Number_BAN__c = ban;
		creditAndAdjustment.Case_Number__c = caseNumber;
		return creditAndAdjustment;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateCase
	   Description -Case test Data for test classes.
	   Object      -Case
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/

	public static case generateCase(String accountId,string contactId,string Origin,string Priority,string Status,string billingAccount,String subject,String description){
	case cas = new case ();
		cas.AccountId = accountId;
		cas.ContactId = contactId;
		cas.Origin = Origin;
		cas.Priority = Priority;
		cas.Status = status;
		cas.Billing_Account__c = billingAccount;
		cas.subject = subject;
		cas.Description = description;
		return cas;
}
	/*-----------------------------------------------------------------------------
	   Method Name -generateInvoice
	   Description -Invoice test Data for test classes.
	   Object      -Invoice__c
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	Public static Invoice__c generateInvoice(String name,String ban,date dueDate,decimal paymentsandAdjustments,String invoicePeriod,String ariaInvoiceNumber){
		Invoice__c invoice = new Invoice__c();
		invoice.Billing_Account__c = ban;
		invoice.Due_Date__c = dueDate;
		invoice.Payments_and_Adjustments__c = paymentsandAdjustments;
		invoice.Invoice_Period__c = invoicePeriod;
		invoice.Name = name;
		invoice.Aria_Invoice_Number__c = ariaInvoiceNumber;
		return Invoice;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateInvoiceLineItem
	   Description -InvoiceLineItem test Data for test classes.
	   Object      -Invoice_Line_Item__c
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	Public static Invoice_Line_Item__c generateInvoiceLineItem(String invoice,String ServiceType,String ChargeType,date startDate,date endDate){
		Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
		invoiceLineItem.Invoice__c = invoice;
		invoiceLineItem.Service_Type__c = ServiceType;
		invoiceLineItem.Charge_Type__c = ChargeType;
		invoiceLineItem.Start_Date__c = startDate;
		invoiceLineItem.End_Date__c = endDate;
		return invoiceLineItem;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateQueriedLineItem
	   Description -QueriedLineItem test Data for test classes.
	   Object      -Queried_Line_Item__c
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public static Queried_Line_Item__c generateQueriedLineItem(String Cas,string creditAdjustment,string invoiceLineItem,string reasonCode,Decimal determinationAmount,Decimal maxCreditAmount){
		Queried_Line_Item__c lineItem = new Queried_Line_Item__c();
		lineItem.Case__c = Cas;
		lineItem.Credit_Adjustment__c = creditAdjustment;
		lineItem.Invoice_Line_Item__c = invoiceLineItem;
		lineItem.Reason_Code__c = reasonCode;
		LineItem.Determination_Amount__c = determinationAmount;
		LineItem.Max_Credit_Amount__c = maxCreditAmount;
		return lineItem;
	}

	/*-----------------------------------------------------------------------------
	   Method Name -generateProduct
	   Description -Product test Data for test classes.
	   Object      -Product2.
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public static product2 generateProduct(String name,Boolean active,String ProductCode){
		product2 product = new product2();
		product.Name = name;
		product.IsActive = active;
		Product.ProductCode = ProductCode;
		return Product;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateAsset
	   Description -Asset test Data for test classes.
	   Object      -Asset.
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/

	public static Asset generateAsset(String name,String Subscription,String Product2,Date PurchaseDate,Date InstallDate,Decimal Quantity,String accountId,string assetId){
		Asset asst = new Asset();
		asst.Name = name;
		asst.Subscription__c = Subscription;
		asst.Product2Id = Product2;
		asst.AssetID__c = assetId;
		asst.PurchaseDate = PurchaseDate;
		asst.InstallDate = InstallDate;
		asst.Quantity = Quantity;
		asst.AccountId = accountId;
		return asst;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -generateOrder
	   Description -order test Data for test classes.
	   Object      -csord__Order__c.
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/

	public static csord__Order__c generateOrder(String accId,String recordType,String status,String orderType,String orderIdentification,Date startDate,String ProductType,String name,String scenerioType,String Owner){
		csord__Order__c order = new csord__Order__c();
		order.csord__Account__c = accId;
		order.recordTypeId = Schema.SObjectType.csord__Order__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
		order.csord__Status2__c = status;
		order.csord__Order_Type__c = orderType;
		order.csord__Identification__c = orderIdentification;
		order.csord__Start_Date__c = startDate;
		order.csord__Product_Type__c = ProductType;
		order.Name = name;
		order.Scenario_Type__c = scenerioType;
		order.OwnerId = owner;
		return order;
	}
	/*-----------------------------------------------------------------------------
	   Method Name -createAddress
	   Description -Address test Data for test classes.
	   Object      -cscrm__Address__c.
	   Author      -Dheeraj Bhatt
	   -------------------------------------------------------------------------------*/
	public Static cscrm__Address__c generateAddress(String externalId,String country,String state,String postalCode,String streetName,String streetType,String streetNumber,String AddressLine){
		cscrm__Address__c address = new cscrm__Address__c();
		address.cscrm__External_ID__c = externalId;
		address.cscrm__Country__c = country;
		address.cscrm__State_Province__c = state;
		address.cscrm__Zip_Postal_Code__c = postalCode;
		address.cscrm__Street_Name__c = streetName;
		address.cscrm__Street_Type__c = streetType;
		address.cscrm__Street_Number_Start__c = streetNumber;
		address.Address_Line_1__c = AddressLine;
		return address;
	}
	@IsTest
	public static void requiredTestCase(){
		System.assertEquals(1,1,'RequiredTestCase');
	}
    public static user createTestUser(String profileName){
        list<Profile> p = [SELECT Id FROM Profile WHERE Name=:profileName];
        if(p.size()>0){
            User u = new User(Alias = 'testU', Email='stdusr@test.com', 
                              EmailEncodingKey='UTF-8', LastName='Test', LanguageLocaleKey='en_US', 
                              LocaleSidKey='en_US', ProfileId = p[0].Id, 
                              TimeZoneSidKey='America/Los_Angeles', Username = 'testU@a.com' + System.currentTimeMillis(),
                              phone='+121231231234');
            insert u;
            return u;
        }
        else return null;
    }

}
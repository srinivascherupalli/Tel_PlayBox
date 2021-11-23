/*
   Created BY: Abinash Barik
   Created Date: 04/24/2019
   Description: EDGE-81696,EDGE-70343 - Sigma-CS interface code refactoring -
            Modular class structure and generic json parsing logic,
            Sigma-CS interface code refactoring - Update logic for Price Item,
            Attribute LoV and EDM mappings.
            This class is responsible for create all Commercial Product and Add on Products
   Class Name: ProcessPriceItemRecords
   =========================================================================
   ChagneSet No    Name            Date                    Description

 */
public class ProcessPriceItemRecords {
	public static Map<String, List<sobject> > createPriceItem(Map<String, List<sobject> > mapsObjectrec,
	                                                          SigmaJSONParseInterface.Charges charge,
	                                                          SigmaJSONParseInterface.Products product){
		system.debug('Inside createPriceItem');
		if (charge.prices != null ) {
			for (SigmaJSONParseInterface.Prices attlovvalue: charge.prices) {
				if (SigmaJSONParseInterface.prodspectoId.containsKey(product.specId)) {
					cspmb__Price_Item__c attlov = new cspmb__Price_Item__c();
					attlov.cspmb__Effective_Start_Date__c = date.valueOf(attlovvalue.startdate);
					attlov.cspmb__Effective_End_Date__c = date.valueOf(attlovvalue.endDate);
					attlov.External_Id__c = attlovvalue.externalId;
					attlov.Package_Name__c = SigmaJSONParseInterface.offername;
					attlov.Offer_Id__c = SigmaJSONParseInterface.offerspecId;
					attlov.cspmb__Product_Definition_Name__c = product.name;
					if (charge.type_x == 'RC') {
						attlov.cspmb__Recurring_Charge__c = decimal.valueof(attlovvalue.rateExcludeGST);
					} else if (charge.type_x == 'OC') {
						attlov.cspmb__One_Off_Charge__c = decimal.valueof(attlovvalue.rateExcludeGST);
					}
					attlov.cspmb__Billing_Frequency__c = charge.frequency_x;
					attlov.ChargeType__c = charge.type_x;
					attlov.Currency__c = charge.currency_x;
					attlov.ChargeFrequency__c = charge.frequency_x;
					attlov.BillingSpecId__c = charge.billingSpecId;
					attlov.BillInAdvance__c = charge.billInAdvance;
					attlov.taxTreatment__c = charge.taxTreatment; //added for edge 33964
					attlov.Prorate__c = charge.prorate;
					attlov.billingSubtype__c = charge.billingSubtype;
					attlov.Billing_Description__c = attlovvalue.billDescription;
					attlov.Unit_Of_Measure__c = charge.unitofMeasure; // Edge-38256
					String attName = '';
					/***************Tactical changes for Sigma Launch price attribute renaming-Recommended by Akshay and pankaj *****************************/
					attlov.cspmb__Contract_Term__c = attlovvalue.term;
					attlov.OP_Contract_Term__c = attlovvalue.term;
					//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c start
					attlov.cspmb__Price_Item_Code__c = attlov.External_Id__c; //product.name;
					attlov.Commercial_Product_Code__c = product.name;
					//AB: PRE cspmb__Price_Item_Code__c => Commercial_Product_Code__c end
					attlov.Frequency__c = charge.frequency_x;
					attlov.ProdSpecId__c = product.specId;
					attlov.Name = product.name;
					if (attlovvalue.attributes != null) {
						for (SigmaJSONParseInterface.ProductStaticCharacteristics priceatt: attlovvalue.attributes)
						{
							system.debug(Logginglevel.ERROR,'priceatt>>>>'+priceatt.name);
							if (String.isNotBlank(priceatt.name) && priceatt.name == 'term')
							{
								attlov.cspmb__Contract_Term__c = priceatt.value;
								attlov.OP_Contract_Term__c = priceatt.value;
							}
							else if (String.isNotBlank(priceatt.name) && priceatt.name != 'term' && String.isNotBlank(priceatt.value) )
							{

								attName = priceatt.name+'__c';
								System.debug('attName========>'+attName);
								if (priceatt.name == 'From_Duration' || priceatt.name == 'To_Duration')
									attlov.put(attName, Decimal.valueOf(priceatt.value));
								else if (priceatt.name == 'Handset_and_Accessories_Type')
									attlov.put('Type__c', priceatt.value);
								else If(priceatt.name != 'Message_Bank')
									attlov.put(attName, priceatt.value);
								System.debug('priceatt.value====>'+priceatt.value);
							}
						}
					}
					if (!SigmaJSONParseInterface.setPriceItemExternalIds.contains(attlov.External_Id__c)) {
						SigmaJSONParseInterface.lstPriceItemToInsert.add(attlov);
						SigmaJSONParseInterface.setPriceItemExternalIds.add(attlov.External_Id__c);
					}

					//mapsObjectrec = ProcessSpecificationRecords.addSpecificationToMap(mapsObjectrec,attlov,'PriceItem');
				} else {
					// TODO for Add On records
					cspmb__Add_On_Price_Item__c addonPriceItem = new cspmb__Add_On_Price_Item__c();
					addonPriceItem.cspmb__Effective_Start_Date__c = date.valueOf(attlovvalue.startdate);
					addonPriceItem.cspmb__Effective_End_Date__c = date.valueOf(attlovvalue.endDate);
					addonPriceItem.External_Id__c = attlovvalue.externalId;
					addonPriceItem.cspmb__Product_Definition_Name__c = product.name;
					if (charge.type_x == 'RC') {
						addonPriceItem.cspmb__Recurring_Charge__c = decimal.valueof(attlovvalue.rateExcludeGST);
					} else if (charge.type_x == 'OC') {
						addonPriceItem.cspmb__One_Off_Charge__c = decimal.valueof(attlovvalue.rateExcludeGST);
					}
					addonPriceItem.cspmb__Billing_Frequency__c = charge.frequency_x;
					addonPriceItem.BillingSpecId__c = charge.billingSpecId;
					addonPriceItem.BillInAdvance__c = charge.billInAdvance;
					addonPriceItem.taxTreatment__c = charge.taxTreatment;
					addonPriceItem.Prorate__c = charge.prorate;
					addonPriceItem.Billing_Description__c = attlovvalue.billDescription;
					addonPriceItem.billingSubtype__c = charge.billingSubtype;
					addonPriceItem.Unit_Of_Measure__c = charge.unitofMeasure;
					addonPriceItem.cspmb__Contract_Term__c = attlovvalue.term;
					addonPriceItem.Name = attlovvalue.billDescription;
					addonPriceItem.Frequency__c = charge.frequency_x;
					addonPriceItem.Offer_Name__c = SigmaJSONParseInterface.offername;
					addonPriceItem.Offer_Id__c = SigmaJSONParseInterface.offerspecId;
					addonPriceItem.cspmb__Add_On_Price_Item_Code__c = product.name;
					addonPriceItem.ProdSpecId__c = product.specId;
					if (!SigmaJSONParseInterface.setAddonExternalIds.contains(addonPriceItem.External_Id__c)) {
						SigmaJSONParseInterface.lstAddonToInsert.add(addonPriceItem);
						SigmaJSONParseInterface.setAddonExternalIds.add(addonPriceItem.External_Id__c);
					}

				}
			}
		}
		return mapsObjectrec;
	}
}
/**************************************************************************************************
Name : ChargeLineItemsDTOTest 
Description : EDGE-123581 : Test Class for ChargeLineItemsDTO
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Pawan Devaliya      19-Jan-2020   Created      
2.        Pawan Devaliya      11-Feb-2020   Change according to new Json structure
3.        Pawan Devaliya      13-Feb-2020   Test changes for EDGE-136115 : Defect Fix : Change in datatype of UnitPrice
5.        Pawan               27-Feb-2020   EDGE-135274     Changes for new fields DiscountAmount and applicationDuration
===============================================================================================================================
***************************************************************************************************/

@IsTest
public class ChargeLineItemsDTOTest {
    
    @isTest
    private static void testParse1() {
        String json = '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "aBE2O00000004nZWAQ", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "aBE2O00000004naWAA", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        ChargeLineItemsDTO obj = ChargeLineItemsDTO.parse(json);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem.size(), 1);
        //Assert on TierLineItem
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].TierLineItems[0].appliedDiscountAmount, 2.1);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].TierLineItems[0].discounted_Price, 5.2);
        
        
        
        
    }
    
//added for  EDGE-135274    
   @isTest
    private static void testParse2() {
        String json = '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "aBE2O00000004nZWAQ", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "aBE2O00000004naWAA", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        ChargeLineItemsDTO obj = ChargeLineItemsDTO.parse(json);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].applicationDuration, 3);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].ApplicableDiscounts[0].appliedDiscountAmount, 10.15);
  
        
    }
    
    //Test Empty array
   @isTest
    private static void testParseEmptyArray() {
        String json = '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "aBE2O00000004nZWAQ", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "aBE2O00000004naWAA", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ ] } ] } }';
        ChargeLineItemsDTO obj = ChargeLineItemsDTO.parse(json);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].applicationDuration, 3);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].ApplicableDiscounts[0].appliedDiscountAmount, 10.15);
        System.assertEquals(obj.chargeLineItems.PriceScheduleLineItem[0].TierLineItems.size(),0);
  
        
    }
}
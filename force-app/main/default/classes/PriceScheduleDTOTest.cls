/******************************************************************************************************************************
Class Name : PriceScheduleDTOTest

Sr.No.  Developer       Date          Story Description           Sprint
1.      Aman Soni       20/04/2020    EDGE-123593(New Class)      20.05
******************************************************************************************************************************/
@IsTest
public class PriceScheduleDTOTest{
       
   @isTest
    private static void testPriceSchedule(){
        Test.startTest();
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
        String json = '{ "chargeLineItems": { "unitPrice__c": 68.18, "contractTerm__c": 24, "businessID__c": "DMCAT_RecurringCharge_000654", "unitTotalContractValue__c": 820.68, "priceScheduleLineItem": [ { "id": "PSLI1", "fromPeriod__c": 1, "toPeriod__c": 3, "unitPrice__c": 22.12, "applicationDuration__c": 3, "applicableDiscounts": [ { "id": "aBE2O00000004nZWAQ", "description": "MRO Bonus", "discountAmount": "10.0", "appliedDiscountAmount__c": 10.15 }, { "id": "aBE2O00000004naWAA", "description": "Activation Credit", "discountAmount": "100.0 %", "appliedDiscountAmount__c": 100.65 } ], "tierLineItems": [ { "fromUnit__c": "0", "toUnit__c": "100", "discounted_Price__c": 5.2, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000872_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "101", "toUnit__c": "200", "discounted_Price__c": 4.5, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000871_DMCAT_RecurringCharge_000808_6953" }, { "fromUnit__c": "201", "toUnit__c": "500", "discounted_Price__c": 4.1, "appliedDiscountAmount__c": 2.1, "rateCardLineIdentifier__c": "DMCAT_Offer_000618_DMCAT_ProductSpecification_000873_DMCAT_RecurringCharge_000808_6953" } ] } ] } }';
        System.runAs(sales){
        PriceScheduleDTO obj = PriceScheduleDTO.parse(json);
        System.assertEquals(obj.chargeLineItems.priceScheduleLineItem[0].applicableDiscounts[0].description, 'MRO Bonus');
        System.assertEquals(obj.chargeLineItems.priceScheduleLineItem[0].applicableDiscounts[1].description, 'Activation Credit');
        }
        Test.stopTest();
    }
}
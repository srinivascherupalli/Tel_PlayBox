/**
 * Created By: Payal Popat 
 * Description: Created for deseralizing rate card SIO's atribute
 * Referred in: RateMatrixForIoTController, RateDiscountforNGUCController,ProductUtilityForModular
 * Test Class: RateMatrxiForIoTControllerTest
 No.       Developer Name        Date            Story     Description
1.      Gokul        11/03/2021     EDGE-205510 -  Update RateGroupIdentifier as Key for the RateCardMap
 */ 
public class RateCardSIOWrapper {
  public class wrapSIO{
        @AuraEnabled public String name{get;set;}
        @AuraEnabled public Integer expectedSIO{get;set;}
        @AuraEnabled public Decimal currentRate{get;set;}
        @AuraEnabled public Decimal previousRate{get;set;}
        @AuraEnabled public Integer actualSIO{get;set;}
        @AuraEnabled public String rateCardId {get;set;}
       @AuraEnabled public String rateCardName {get;set;}
       //EDGE-205510
       @AuraEnabled public String rateGroupIdentifier {get;set;}
       @AuraEnabled public String chargeFrequency {get;set;} //Changes for DIGI - 32161 by Natasha


    }
}
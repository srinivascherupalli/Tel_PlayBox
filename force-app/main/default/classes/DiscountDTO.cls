/*
* @Author : Shubhi
* @Date : 26 Nov 2019
* @Desc : Discount DTO
* @Jira : Edge-120132
*@TestClass: DiscountDTOTest 
===============================================================================================================================
Sr.No.    Developer Name      Date          	Story Description
1.        shubhi              12.march.2020 	EDGE-140157 nguc modify
2.        shubhi              12.march.2020 	EDGE-133882 nguc new ui
===============================================================================================================================
*/
 
 public  with sharing class DiscountDTO {
     
     @AuraEnabled public string discountName {get; set;}
     @AuraEnabled public string description {get; set;}
     @AuraEnabled public string discAmount {get; set;}
     @AuraEnabled public string discDuration {get; set;}
     @AuraEnabled public string promotionID {get; set;} 
     @AuraEnabled public string DiscountType {get; set;} 

     @AuraEnabled public String startDate {get; set;} //EDGE-133882/shubhi
     @AuraEnabled public String endDate {get; set;} //EDGE-133882/shubhi
  	//EDGE-140157 nguc modify start
  	@AuraEnabled public String initialActivationDate {get; set;} //EDGE-140157/shubhi
    @AuraEnabled public String remainingTerm {get; set;} //EDGE-140157/shubhi
    @AuraEnabled public String status {get; set;} //EDGE-140157/shubhi
  	//EDGE-140157 nguc modify end
}
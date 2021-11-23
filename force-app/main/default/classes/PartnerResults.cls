/*
* Version     Author                         Last Modified Date      Description
* v1.0        Vivian Charlie (Team Hawaii)   06 Oct 2020             P2OB-5498 : Partner Recommendation Result Wrapper
                                                                     Test coverage for class is done in PRMPartnerRecommendationRulesTest.cls

* v1.1        Vivian Charlie (Team Hawaii)   30 Oct 2020             P2OB-6781 : Opportunity code optimization

*/
public class PartnerResults{
    @AuraEnabled public boolean isselected {get;set;}
    @AuraEnabled public Account account {get;set;}
    @AuraEnabled public String Id {get;set;}
    @AuraEnabled public String isPartner {get;set;}
    @AuraEnabled public String accountName {get;set;}
    @AuraEnabled public String accreditation {get;set;}
    @AuraEnabled public String stateCoverage {get;set;}
    @AuraEnabled public String TradingName {get;set;}

    @AuraEnabled public Double OptySuccessRate {get;set;}
    @AuraEnabled public String DistributorName {get;set;}
    @AuraEnabled public String DistributorId {get;set;}
    @AuraEnabled public String porProductDomain {get;set;} //EDGE-151598
    @AuraEnabled public date porAgreementEnddate {get;set;} //EDGE-151598

    /*
    @AuraEnabled public boolean isselected {get; set;}
    @AuraEnabled public Account account {get; set;}
    @AuraEnabled public String Id {get; set;}
    @AuraEnabled public String accountName {get; set;}
    @AuraEnabled public String accreditation {get; set;}
    @AuraEnabled public String stateCoverage {get; set;}

    @AuraEnabled public Double OptySuccessRate {get; set;}

    public Integer compareTo(Object compareTo) {
        PartnerResults PartnerResults = (PartnerResults) compareTo;
        if (this.OptySuccessRate == PartnerResults.OptySuccessRate) return 0;
        if (this.OptySuccessRate < PartnerResults.OptySuccessRate) return 1;
        return -1;
    }
    */
}
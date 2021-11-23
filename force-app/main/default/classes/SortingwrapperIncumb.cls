/*
* Version     Author                         Last Modified Date      Description
* v1.0        Vivian Charlie (Team Hawaii)   30 Oct 2020             P2OB-6781 Oportunity Recommendation/Incumbency optimization
                                                                     Test coverage for class is done in PRMSubmitToPartnerRulesTest.cls
*/
public without sharing class SortingwrapperIncumb implements Comparable{
    public PartnerResults PartnerResults {get;set;}
    public date CreatedDate {get;set;}
    public String AccountName {get;set;}
    public String isPartner {get;set;}
    public Integer compareTo(Object compareTo) {
        sortingwrapperIncumb sortingwrapperIncumb = (sortingwrapperIncumb) compareTo;
        if (this.CreatedDate < sortingwrapperIncumb.CreatedDate) return 1;
        if (this.CreatedDate > sortingwrapperIncumb.CreatedDate) return -1;
        else{
             if (this.AccountName > sortingwrapperIncumb.AccountName) return 1;
             if (this.AccountName < sortingwrapperIncumb.AccountName) return -1;
             else{
                 return 0;
             }
         }
    }
}
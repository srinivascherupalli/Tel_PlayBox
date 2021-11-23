/*
* Version     Author                         Last Modified Date      Description
* v1.0        Vivian Charlie (Team Hawaii)   06 Oct 2020             P2OB-5498 : Partner Recommendation Sorting Wrapper
                                                                     Test coverage for class is done in PRMPartnerRecommendationRulesTest.cls
*/
public class SortingwrapperRecomm implements Comparable{
    public PartnerResults PartnerResults {
        get;
        set;
    }
    public integer AccreditationLevel {
        get;
        set;
    }
    public String AccountName {
        get;
        set;
    }
    public Integer compareTo(Object compareTo) {
        sortingwrapperRecomm sortingwrapperRecomm = (sortingwrapperRecomm) compareTo;
        if (this.AccreditationLevel < sortingwrapperRecomm.AccreditationLevel) return 1;
        if (this.AccreditationLevel > sortingwrapperRecomm.AccreditationLevel) return -1;
         else{
             if (this.AccountName > sortingwrapperRecomm.AccountName) return 1;
                if (this.AccountName < sortingwrapperRecomm.AccountName) return -1;
             else{
                 return 0;
             }
         }
    }
}
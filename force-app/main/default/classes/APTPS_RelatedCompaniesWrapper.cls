public class APTPS_RelatedCompaniesWrapper {
    public account accnt{get;set;}
    public boolean isSelected{get;set;}
    public APTPS_RelatedCompaniesWrapper(account acc){
        accnt=acc;
        isSelected=false;
    }
}
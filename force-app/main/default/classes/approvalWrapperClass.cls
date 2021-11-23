public class approvalWrapperClass{
    @auraenabled
    public string oppName{get;set;}
        @auraenabled
public string oppId{get;set;}
        @auraenabled
public Opportunity oppty{get;set;}
    @auraenabled
    public string workItemId{get;set;}
     @auraenabled
    public Decimal Amount{get;set;}
     @auraenabled
    public Date CloseDate{get;set;}
     @auraenabled
    public string AccountName{get;set;}
     @auraenabled
    public Object response{get;set;}
    @auraenabled
    public string sComments{get;set;}
    //add all the fields which needs to be displayed on UI
    
    public approvalWrapperClass(Opportunity oppty,
                                string oppName,string workItemId,
                                Decimal decAmount,Date dCloseDate,string sAccName,string sComments,
                               Object response){
        this.oppName=oppName;
        this.response=response;
        this.oppty=oppty;
        this.workItemId=workItemId;
        if(decAmount != null)
            this.Amount = decAmount;
        this.CloseDate = dCloseDate;
        this.AccountName = sAccName;
        this.sComments = sComments;
        this.oppId=oppty.id;

    }
}
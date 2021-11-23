public class ManageContactDAO {
    
    public Contact manageContact{set;get;}
    public String eventType{set;get;}
    public String mcReq{set;get;}
    public String identifier{set;get;}
    public String acrRole{set;get;}
    public Boolean isACREndDated{set;get;}
    public String accountId{set;get;}
    
    public ManageContactDAO(Contact manageContact, String eventType){
        this.manageContact = manageContact;
        this.eventType = eventType;
    }
    public ManageContactDAO(Contact manageContact, String eventType,String accountId){
        this.manageContact = manageContact;
        this.eventType = eventType;
        this.accountId = accountId;
    }
}
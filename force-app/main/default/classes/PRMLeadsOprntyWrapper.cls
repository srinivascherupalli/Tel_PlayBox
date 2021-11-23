/*******************************************************************
Created By          :   Garg / Ashish
Created Date        :   
Desc                :   This is a wrapper class to show lead and opportunity cards data on partner community

Date            Version             Modified By             Desc
25-Augst-2019        1              Ashish garg              

Date            Version             Modified By             Desc
1. 4-November-2019      2              Paresh Patil            (Team Hawaii)created variable DchOwner as part of Jira - P2OB-3691
2. 29-November-2019     3              Vivian Charlie          (Team Hawaii) created variable tileType
3. 27-April-2020        4              Ritika Jaiswal          P2OB-5673 - Display Campaign Name for Lead
4. 23-Jun-2020          5              Ritika Jaiswal          P2OB-6903 - Primary Domain for Oppty Tile    
***********************************************************************/
public class PRMLeadsOprntyWrapper {

    @auraenabled
    public string Name{get;set;}
    @auraenabled
    public string Id{get;set;}
    @auraenabled
    public string workItemId{get;set;}
    @auraenabled
    public Decimal Amount{get;set;}
    @auraenabled
    public Date CloseDate{get;set;}
    @auraenabled
    public string AccountName{get;set;}
    @auraenabled
    public string DchOwner{get;set;}
    @auraenabled
    public String tileType{get;set;}
    @auraenabled
    public boolean forClosure{get;set;}
    @auraenabled
    public boolean showCampaign{get;set;} //P2OB-5673 - Condition to show/hide campaign on tile 
    @auraenabled
    public string campaignName{get;set;}  //P2OB-5673 - Campaign Name associated with Lead
    @auraenabled
    public string primaryDomain{get;set;} //P2OB-6903 - Primary Domain for Oppty Tile   
    //add all the fields which needs to be displayed on UI
    
    
    public PRMLeadsOprntyWrapper(String name,String workItemId, Decimal decAmount,Date dCloseDate, String sAccName,String Id,String Owner,String tileTyp, boolean closure,string CampaignOnLead,string primaryDomain) {
        this.Name=name;
        this.workItemId=workItemId;
        if(decAmount != null)
            this.Amount = decAmount;
        this.CloseDate = dCloseDate;
        this.AccountName = sAccName;
        this.Id=Id;
        if(Owner != null){
            this.DchOwner = Owner;
        }
        this.tileType = tileTyp;
        this.forClosure = closure;
        this.showCampaign = !(String.isBlank(CampaignOnLead)); //P2OB - 5673 : Conditional display of Campaign on card-list-tile
        this.campaignName = CampaignOnLead; //P2OB-5673 - Campaign Name associated with Lead 
        this.primaryDomain = primaryDomain; //P2OB-6903 - Primary Domain for Oppty Tile    
    }
}
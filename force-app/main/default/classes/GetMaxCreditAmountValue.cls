/************************************************************ 
* @version      - 0.1
* @createdBy    - Jawahar
* @team         - OSAKA
* @jirastoryRef - EDGE-138355
******************************************************************
Sr.No.    Developer Name      Date          Story Description
1.         Shubhi             13-05-2021    EDGE-212404
***************************************************************************************************/

public class GetMaxCreditAmountValue implements Queueable, Database.AllowsCallouts {

    string caseId;
    String invoiceNumber='';
    
    
    public GetMaxCreditAmountValue (String caseId)
    {
       
        this.caseId=caseId;
    }
    //updated by : Shubhi V Edge-212404 start---------
    public GetMaxCreditAmountValue (String caseId,String invoiceNumber)
    {
        this.invoiceNumber=invoiceNumber;
        this.caseId=caseId;
    }
    public void getMaxCreditAndEnrichQLI(String caseId,String invoiceNumber) {
        List<Id> caseCreated = new List<Id> ();
        caseCreated.add(caseId);
        QLIBillingLineItemAdjustment.getMaxCreditAndEnrichQLI(caseId,invoiceNumber);
    }
    //updated by : Shubhi V Edge-212404 end----------
    public void execute(QueueableContext context)
    {
        //updated by : Shubhi V Edge-212404 added ternary condition    
       if(String.isNotBlank(invoiceNumber))
        getMaxCreditAndEnrichQLI(caseId,invoiceNumber);
       else 
        getMaxCredit(caseId);
    }
    
    public void getMaxCredit(String caseId) {
    List<Id> caseCreated = new List<Id> ();
        caseCreated.add(caseId);
        if(!Test.isRunningTest())
            QLIBillingLineItemAdjustment.getMaxCredit(caseCreated);
    }
        
}
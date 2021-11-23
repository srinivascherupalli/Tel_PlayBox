/**
* @Author     :   Aniket S 
* @Date       :   Jan 2021
* @Initial US :   EDGE-193826
* */
public class QuoteContractQueueable implements Queueable{
     String contractJunctionRecordString;
     String prBasketRecordString;
    public QuoteContractQueueable(String contractJunctionRecordStringPara,String prBasketRecordStringPara){
        this.contractJunctionRecordString = contractJunctionRecordStringPara ;  
        this.prBasketRecordString = prBasketRecordStringPara ;  
    }
	public void execute(QueueableContext context) {
        AgreementOrderUtilities.createPriceScheduleVariation(contractJunctionRecordString,prBasketRecordString);
              
    }
}
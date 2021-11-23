/**
* @Story : EDGE-191759.
* @Author : Kshitiz Sahu,Pooja Gupta
* @Description : To move the basket stage to "Contract Accepted" for both incoming and outgoing customers(CHOWN Functionality).
* @Date : 16/Feb/2021

EDGE-216340 Shweta Khandelwal 30/4/21
*/

/*To move the basket stage to "Contract Accepted" for outgoing customers(CHOWN Functionality)*/
public with sharing class chownProductBasketUtil {
    public static final String HANDLER = 'chownProductBasketUtil';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    public static cscfga__Product_Basket__c changeBasketStageForChown(string outgoingBasketId){
        cscfga__Product_Basket__c outgoingBasketRecord = new cscfga__Product_Basket__c();
        try{
            if (outgoingBasketId!=null){
                outgoingBasketRecord.id = outgoingBasketId; 
                //cscfga__Product_Basket__c outgoingBasketRecord =[Select Id, csordtelcoa__Basket_Stage__c  From cscfga__Product_Basket__c where Id=: outgoingBasketId ];
                system.debug('outgoingBasketRecord'+outgoingBasketRecord);
                outgoingBasketRecord.csordtelcoa__Basket_Stage__c='Contract Accepted';
            }
        }
        catch(exception e){
            logger.logMessages('StockCheckCalloutException', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage()+';'+e.getLineNumber(), false, false);
            system.debug(e.getMessage() + ';' + string.valueOf(e.getLineNumber()));
        }
        return outgoingBasketRecord;
    }
}
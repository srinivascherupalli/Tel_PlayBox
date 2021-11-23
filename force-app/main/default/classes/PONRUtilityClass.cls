/*******************************************************************************************************************
Class Name : PONRUtilityClass
Description : Generic validation class which will be called from Quote/ Contract and Submit order button 
====================================================================================================================
Sr.No.    Developer Name          Date                  Story Description
1.        Pooja Gupta             11/01/2021            EDGE-191824 In-Flight: PONR Check before initiating Contract/Skip Contract/Quote
2.        Arunkumar V & Martand   25/01/2021            EDGE-199064 
3.        Pooja Gupta             16/02/2021            EDGE-201589
4.        Pallavi D               10.05.2021            EDGE-217693
====================================================================================================================
********************************************************************************************************************/ 
public with sharing class PONRUtilityClass {
    public static cscfga__Product_Basket__c productBasketToCheck = new cscfga__Product_Basket__c();//EDGE-217693
    
    public static Boolean validatePONRforBasket(cscfga__Product_Basket__c productBasket){
        Boolean response = false;
        productBasketToCheck = productBasket;//EDGE-217693
        System.debug('productBasket***' + productBasket);
        //Id orderId = [select id from csord__Order__c where csordtelcoa__Opportunity__c =:productBasket.cscfga__Opportunity__c LIMIT 1].Id;
        string orderNum = [select csord__Order_Number__c from csord__Order__c where csordtelcoa__Opportunity__c =:productBasket.cscfga__Opportunity__c LIMIT 1].csord__Order_Number__c;//EDGE-201589
        System.debug('orderNum' + orderNum);
        if(orderNum != null){
            response = PONRUtilityClass.validatePONRforOrder(orderNum);
        }
        return response;
    }
    
    public static Boolean validatePONRforOrder(string orderNum){//changes the orderID param to orderNumber as expected by API- EDGE-201589
        try{
            return PONROrderItemHandler.syncExecute(orderNum); //EDGE-199064 Changed the return condition
        }
        catch(Exception e){return true;}
    }
}
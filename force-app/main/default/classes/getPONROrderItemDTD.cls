/*******************************************************************************************************************
Name : getPONROrderItemDTD
EDGE->  186512,186513
Description : To receive the data after callout in a specific format.
====================================================================================================================
Sr.No.    Developer Name     	 	Date         				 Story Description
1.        Rajiv Singh    		  29/10/2020   		As a salesforce user, I want to Perform PONR status Check for specific
                                                     order number: PONR status Enquiry API Consumption
====================================================================================================================
********************************************************************************************************************/

public class getPONROrderItemDTD {

    public String externalOrderId;
    public String sourceSystem;
    public String action;
    public String customerId;
    public List<String> OrderItemsinPONR;
    
     public static getPONROrderItemDTD parse(String json) {
        return (getPONROrderItemDTD) System.JSON.deserialize(json, getPONROrderItemDTD.class);
    }
}
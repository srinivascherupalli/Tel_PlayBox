/**************************************************************************
EDGE        -163367
component   -InvoiceDiscountDetails
Description -This Component is used to show the Discount details of a particular Invoice Line Item record based on
			  Is Discount Drillable attribute to True.
Author      -Manjunath Ediga
Team        -Osaka
******************************************************************************** */
({
	getDiscountDetails : function(component, event, helper) {
        helper.makeCallout(component, event, helper);
	},
   
 sectionDiscounts : function(component, event, helper) {
       helper.helperDiscounts(component,event,'section');
    },
    
})
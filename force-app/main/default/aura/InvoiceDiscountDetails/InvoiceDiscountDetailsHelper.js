/**************************************************************************
EDGE        -163367
component   -InvoiceDiscountDetails
Description -This Component is used to show the Discount details of a particular Invoice Line Item record based on
			  Is Discount Drillable attribute to True.
Author      -Manjunath Ediga
Team        -Osaka
Version No	Author 		Date			Description
1			Monali	    14-Oct-2021     DIGI-16909 - Billing assurance uplift with discountName
******************************************************************************** */
({
    makeCallout : function(component, event, helper) {
        var action = component.get('c.getInvoiceDetails');
        var Obj = new Object();
        Obj.chargeId=parseInt(component.get("v.LineItemRecord.Charge_Id__c"));
        Obj.statementNumber=component.get("v.LineItemRecord.Invoice__r.Name");
        var requestJSON=JSON.stringify(Obj); 
        console.log('requestJSON from Discount',requestJSON);
        action.setParams({request:requestJSON,handlerName:'InvoiceDiscountHandler'}); 
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === 'SUCCESS')
            {
                var responseObject=response.getReturnValue();   
                console.log('responseObject',JSON.stringify(responseObject));
                var statusCode=Object.keys(responseObject);
                if(responseObject!= null && statusCode.length != 0)
                {
                    var responsebody=Object.values(responseObject);
                    var response=JSON.parse(responsebody[0]);
                    if(statusCode[0].startsWith(2))
                    {
                        for(var ili of response.discountDetails){
                            for(var iliFilter of ili.invoiceLineAttributes){
                                if(component.get("v.LineItemRecord.Invoice_Transaction_ID__c") == iliFilter.invoiceTransactionId)
                                {
                                    component.set("v.cataloguePrice",ili.cataloguePriceExGst);
                                    component.set("v.discountApplied",ili.discountAppliedExGst);
                                    component.set("v.discountedPriceExGST",ili.discountedPriceExGst);
                                    component.set("v.discountedPriceIncGST",ili.discountedPriceIncGst);
                                    component.set("v.discountName",getDiscountName(ili.discountSplit)); //DIGI-16909
                                 }
                            }
                        }
                    }
                    else{
                        console.log(response.errorMessage);
                        component.set("v.errorMessage",response.errorMessage);
                    }
                }
                else {
                     component.set("v.errorMessage",$A.get("$Label.c.Invoice_Charge_Error"));
                    }
            }
        });
        $A.enqueueAction(action);
    },
    
    helperDiscounts : function(component,event,secId) {
        var ili = component.find(secId);
        for(var cmp in ili) {
            $A.util.toggleClass(ili[cmp], 'slds-show');  
            $A.util.toggleClass(ili[cmp], 'slds-hide');  
        }
    },
    //DIGI-16909
    getDiscountName : function(discountSplits) {
        let discName='';
        if(discountSplits && discountSplits.length > 0){
            for(let disc of discountSplits){
                if(discName.length > 0) {
                    discName = discName+',';
                }
                discName+=disc.discountName;
            }
        }
        return discName;
    },
})
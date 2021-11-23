({
    makeCallout : function(component, event, helper) {
        var action = component.get('c.getInvoiceDetails');
        var Obj = new Object();
        Obj.chargeId=parseInt(component.get("v.LineItemRecord.Charge_Id__c"));
        Obj.statementNumber=component.get("v.LineItemRecord.Invoice__r.Name");
        var requestJSON=JSON.stringify(Obj);  
        
        action.setParams({request:requestJSON,handlerName:'RepaymentDetails'}); 
        action.setCallback(this,function(response){
            var state=response.getState();
            if(state === 'SUCCESS')
            {
                var responseObject=response.getReturnValue(); 
                var statusCode=Object.keys(responseObject);
                if(responseObject!= null && statusCode.length != 0)
                {
                    var responsebody=Object.values(responseObject);
                    var response=JSON.parse(responsebody[0]);
                    if(statusCode[0].startsWith(2))
                    {
                        component.set("v.chargedThisInvoice",response.repaymentSummary.chargedThisInvoice);
                        for(var ili of response.repaymentSummary.repaymentDetails){
                            for(var iliFilter of ili.invoiceLineAttributes){
                                if( component.get("v.LineItemRecord.Invoice_Transaction_ID__c") == iliFilter.invoiceTransactionId)
                                {
                                    
                                    component.set("v.orderNumber",ili.orderNumber);
                                    component.set("v.deviceId",ili.deviceId);
                                    component.set("v.installment",ili.installment);
                                    component.set("v.purchaseDate",ili.purchaseDate);
                                    console.log('ili.chargedSoFar-->',ili.chargedSoFar);
                                    if((ili.chargedSoFar != null) ){
                                        var chargedSoFarDollar ='$';
                                        var chargedSoFarVal = ili.chargedSoFar;
                                        component.set("v.chargedSoFar",chargedSoFarDollar.concat(chargedSoFarVal));
                                    }
                                    if(ili.unitPrice!= null ){
                                        var unitPriceDollar ='$';
                                        var unitPriceValue=ili.unitPrice;                                            
                                        component.set("v.unitPrice",unitPriceDollar.concat(unitPriceValue));
                                        
                                    }
                                    if(ili.totalRemaining != null ){
                                        var totalRemainingDollar ='$';
                                        var totalRemainingVal = ili.totalRemaining;
                                        component.set("v.totalRemaining",totalRemainingDollar.concat(totalRemainingVal));
                                    }
                                    if(ili.devicePrice != null ){
                                        var devicePricevalDollar='$';
                                        var devicePriceval = ili.devicePrice;
                                        component.set("v.devicePrice",devicePricevalDollar.concat(devicePriceval));
                                    }
                                    
                                    
                                }
                            }
                        }
                    }
                    else
                    {
                        
                        component.set("v.errorMessage",$A.get("$Label.c.Invoice_Charge_Error"));
                    }
                }
                else
                {
                    component.set("v.errorMessage",$A.get("$Label.c.Invoice_Charge_Error"));
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    repaymentSection : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
})
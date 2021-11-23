({
    makeCallout : function(component, event, helper) {
        var action = component.get('c.getInvoiceDetails');
        var Obj = new Object();
        Obj.chargeId=parseInt(component.get("v.LineItemRecord.Charge_Id__c"));
        Obj.statementNumber=component.get("v.LineItemRecord.Invoice__r.Name");
        var requestJSON=JSON.stringify(Obj);    
        action.setParams({request:requestJSON,handlerName:'InvoiceOrderHandler'}); 
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
                        for(var ili of response.orderDetails){
                                     for(var iliFilter of ili.invoiceLineAttributes){
                                       if( component.get("v.LineItemRecord.Invoice_Transaction_ID__c") == iliFilter.invoiceTransactionId)
                                       {
                                        component.set("v.orderNumber",ili.orderNumber);
                                        component.set("v.caseId",ili.caseId);  
                                        //component.set("v.custReference",'');
                                         //Added by mukta as part of EDGE-223833
                                         if(!$A.util.isEmpty(ili.deviceId) && ili.deviceId.includes(',')){
                                            component.set("v.deiceIdString",ili.deviceId);
                                        }
                                        else{
                                            component.set("v.deviceId",ili.deviceId);
                                        }
                                        component.set("v.chargeDate",ili.date);
                                        component.set("v.quantity",ili.quantity);
                                           if (ili.unitRate != null){
                                           var rateDoller='$';
                                           var rateValue=ili.unitRate;
                                        component.set("v.unitRate",rateDoller.concat(rateValue));
                                           }
                                        
                                         }
                                     }
                                     }
                                     //Added by mukta as part of EDGE-223833
                                     if(!$A.util.isEmpty(component.get("v.deiceIdString"))){
                                        this.createCSV(component);
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
    
    helperSectionOrder : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-show');  
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
     //Added by mukta as part of EDGE-223833
     createCSV : function(component){
        var action = component.get("c.createDeviceCSV");
        var deviceIds = component.get("v.deiceIdString");
        action.setParams({invoiceLineId: component.get("v.LineItemRecord.Id"),deviceId : deviceIds});
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS' && !$A.util.isEmpty(response.getReturnValue())){
                component.set("v.docId",response.getReturnValue());
            }
            else{
                component.set("v.deviceId",deviceIds);
            }
        });
        $A.enqueueAction(action);

    }
})
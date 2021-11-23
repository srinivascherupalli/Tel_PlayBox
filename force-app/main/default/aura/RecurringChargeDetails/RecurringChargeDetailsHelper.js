({
    makeCallout : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {//DPG-3572(Added conition to execute only in the case of onload)
            var action = component.get('c.getInvoiceDetails');
            var Obj = new Object();
            Obj.chargeId=parseInt(component.get("v.LineItemRecord.Charge_Id__c"));
            Obj.statementNumber=component.get("v.LineItemRecord.Invoice__r.Name");
            var requestJSON=JSON.stringify(Obj);
            action.setParams({request:requestJSON,handlerName:'RecurringChargeHandler'});
            action.setCallback(this,function(response){
                var state=response.getState();
                if(state === 'SUCCESS')
                {
                    var responseObject=response.getReturnValue();
                    var statusCode=Object.keys(responseObject);
                    if(responseObject!= null && statusCode.length != 0)
                    {
                        var selectedIli;
                        var responsebody=Object.values(responseObject);
                        var response=JSON.parse(responsebody[0]);
                        if(statusCode[0].startsWith(2))
                        {
                            var recurringType = response.recurringType;
                            for(var ili of response.recurringDetails){
                                for(var iliFilter of ili.invoiceLineAttributes){
                                    if(component.get("v.LineItemRecord.Invoice_Transaction_ID__c") == iliFilter.invoiceTransactionId) {
                                        selectedIli =ili;
                                        component.set("v.orderNumber",ili.orderNumber);
                                        if((recurringType === 2) || (recurringType === 3) || recurringType === 4) { //DIGI-12074 for LM
                                            component.set("v.serviceId",'');
                                        } else {
                                            component.set("v.serviceId",ili.serviceId);
                                        }
                                        if( recurringType === 4){ //DIGI-12074 for LM
                                            component.set("v.basePlan",'');
                                        }else{
                                             component.set("v.basePlan",ili.basePlan);
                                        }
                                        component.set("v.unitPrice",ili.unitPrice);
										component.set("v.nickName",ili.userName);
                                        break;
                                    }
                                }
                            }
                            var drillDownList = [];
                            if(selectedIli && selectedIli.serviceDetails){
                                if(recurringType === 2) { //Adaptive Care
                                    component.set('v.serviceDetailsTableName', 'Service_Details_AMMC');
                                    
                                    for (var serviceDetail of selectedIli.serviceDetails) {
                                        var drillDown = {};
                                        drillDown.serviceId=serviceDetail.serviceId;
                                        drillDown.basePlan=selectedIli.basePlan;
                                        drillDown.unitRate=selectedIli.unitPrice;
                                        drillDownList.push(drillDown);
                                    }
                                } else if(recurringType === 3) {//TMDM
                                    component.set('v.serviceDetailsTableName', 'Service_Details_MS_TMDM');
                                    
                                    for (var serviceDetail of selectedIli.serviceDetails) {
                                        var drillDown = {};
                                        drillDown.serviceId=serviceDetail.serviceId;
                                        drillDown.deviceId=serviceDetail.deviceId;
                                        drillDown.username=serviceDetail.userName;
                                        drillDown.email=serviceDetail.email;
                                        drillDown.basePlan=selectedIli.basePlan;
                                        drillDown.unitRate=selectedIli.unitPrice;
                                        drillDownList.push(drillDown);
                                    }
                                    
                                }else if(recurringType === 4) {//Lifecycle Management //DIGI-12074 for LM
                                    component.set('v.serviceDetailsTableName', 'Service_Details_LM');
                                    
                                    for (var serviceDetail of selectedIli.serviceDetails) {
                                        var drillDown = {};
                                      //  drillDown.serviceId=serviceDetail.serviceId;
                                      //  drillDown.serviceId=serviceDetail.serviceId;                                        
                                      serviceDetail.serviceId !== null ? drillDown.serviceId=serviceDetail.serviceId : drillDown.serviceId = serviceDetail.deviceId; // DIGI-25273
                                        drillDown.unitRate=selectedIli.unitPrice;
                                        drillDownList.push(drillDown);
                                    }
                                    
                                }
                            }
                            component.set('v.fetchRecord', drillDownList);
                            //DPG-3572 START
                            var dateCalculated = component.get("v.LineItemRecord.Date_Calculated__c");
                            var tenancyId = component.get("v.LineItemRecord.Tenancy_Id__c");
                            if(recurringType===3 && selectedIli && selectedIli.tenancyId && selectedIli.dateCalculated && (!dateCalculated || !tenancyId)){
                                var lineItem =  Object.assign({}, component.get("v.LineItemRecord"));
                                lineItem.Date_Calculated__c = $A.localizationService.formatDate(selectedIli.dateCalculated, "YYYY-MM-DD");
                                lineItem.Tenancy_Id__c = selectedIli.tenancyId;
                                helper.handleSaveLineItemRecord(component,lineItem);
                            }
                            //DPG-3572 END
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
        }
    },
    
    helperRecurring : function(component,event,secId) {
        var acc = component.find(secId);
        for(var cmp in acc) {
            $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
    },
    handleSaveLineItemRecord:function(component,lineItem){//DPG-3572
        var action  = component.get('c.upsertInvoiceLineItem');
        action.setParams({invoiceLineItem : lineItem});
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                $A.get('e.force:refreshView').fire();
            }
            else if(state === 'ERROR'){
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
})
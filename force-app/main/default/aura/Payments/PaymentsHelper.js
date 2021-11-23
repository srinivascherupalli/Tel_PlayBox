/* **************************************************************************
EDGE        -88306
component   -paymentsHelper
Description -JS Helper for payment component
Author      -Dheeraj Bhatt
//22-Feb-2021 Ravi Shankar added EDGE-194644 changes PaymentType
//03-Jun-2021 Pooja Bhat added EDGE-215989 changes to Dormant Payment related changes
**********************************************************************************/
({
    // getting the billing account number and loading the paymenmt at component load
    init : function(component, event, helper) {
        var action = component.get("c.getBan");
        action.setParams({"billingAccountId": component.get("v.billingAccountId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.ban",response.getReturnValue());
                if(component.get("v.ban") != null || component.get("v.ban") !=''){
                this.searchPayments(component, event, helper);
                }
                else{
                    component.set("v.errorMessage",$A.get("$Label.c.Billing_Acc_cannot_null"));
                    component.set("v.IsError",true);
                }
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        $A.enqueueAction(action);
    },
    /* Setting the default date */
    setDefaultDate:function(component,event,helper){
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; 
        var yyyy = today.getFullYear();
        if(dd<10) 
        {
            dd='0'+dd;
        } 
        if(mm<10) 
        {
            mm='0'+mm;
        }
        var to_yy=yyyy;
        var to_mm=mm-13;
        var to_dd=dd;
        if(to_mm <= 0){
            to_mm=12+to_mm;
            to_yy=to_yy-1;
            if(to_mm==0){
                to_mm=12; 
                to_yy=to_yy-1;
            }
        } 
        if(to_mm<10) 
        {
            to_mm='0'+to_mm;
        }
        today = yyyy+'-'+mm+'-'+dd;
        var from_date= to_yy+'-'+to_mm+'-'+to_dd;
        component.set("v.to",today);
        component.set("v.todayDate",today);
        component.set("v.from",from_date);
    },
    /* getting the payment from external system  */
    searchPayments:function(component, event, helper){
        var handler= component.get("v.handler");
        var ban=component.get("v.ban");
        var from=component.get("v.from");
        var to=component.get("v.to");
        var action = component.get("c.getPayments");
        action.setParams({"handler": handler,
                          "ban": ban,
                          "toDate": to,
                          "fromDate": from});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records=response.getReturnValue();
                if(records.responseErrors ==null){
                    component.set("v.IsError",false);
                    component.set("v.recordList",records.responsePayments);
                    
                    if(component.get("v.recordList") !=null){
                        for(var k=0; k<records.responsePayments.length; k++ ) {
                            if(records.responsePayments[k].paymentAmountIndicator != null && records.responsePayments[k].paymentAmountIndicator != '' && records.responsePayments[k].paymentAmountIndicator == 'dr'){
                                records.responsePayments[k].paymentAmountFmtd = '$'+String(records.responsePayments[k].paymentAmount.toFixed(2))+' Dr';
                            }
                            else{
                                records.responsePayments[k].paymentAmountFmtd = '$'+String(records.responsePayments[k].paymentAmount.toFixed(2));
                            }
                        }
                        //console.log('fmtdRecords::::'+JSON.stringify(records.responsePayments));
                    }
                                                            
                    if(component.get("v.recordList") !=null){
                    this.sortData(component,component.get("v.sortBy"),component.get("v.sortDirection"));
                    }
                    else{
                         component.set("v.errorMessage",$A.get("$Label.c.Payment_data_Null"));
                         component.set("v.IsError",true); 
                    }
                }
                else {
                    component.set("v.recordList",records.responsePayments);
                   component.set("v.errorMessage",records.responseErrors[0].message);
                    component.set("v.IsError",true);
                }
                    
            } 
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log(errorMsg);
            }
        });
        $A.enqueueAction(action);
    },
    /* sorting the coloumn */  
    sortData : function(component,fieldName,sortDirection){
        if(fieldName == 'paymentAmountFmtd'){
            fieldName = 'paymentAmount';
        }
        var data = component.get("v.recordList");
        //function to return the value stored in the field
        var key = function(a) { return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'transactionId' || fieldName == 'paymentAmount' || fieldName == 'paymentUnappliedAmount' || fieldName == 'paymentAppliedAmount'){ 
            data.sort(function(a,b){
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        // to handel date text type fields
        else if(fieldName=='paymentDate'){
            data.sort(function(a,b) {
                var a = key(a).split('/').reverse().join('');
                var b = key(b).split('/').reverse().join('');
                return reverse * ((a>b) - (b>a));
                
            });
        }
        // to handle text type fields 
            else{
                data.sort(function(a,b){ 
                    var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                    var b = key(b) ? key(b).toLowerCase() : '';
                    return reverse * ((a>b) - (b>a));
                });    
            }
        //set sorted data to recordList attribute
        component.set("v.recordList",data);
    },

    //Start:EDGE-215989
    checkDormance : function(component) {
        var action = component.get("c.checkPaymentDormance");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var isDormant = response.getReturnValue();
                var transactionType = (isDormant ? 'text' : 'button');
                console.log('isDormant****'+isDormant);
                console.log('transactionType****'+transactionType);
                // Setting the columns for Data table
                component.set("v.dataColumns",[
                    { 
                        label : 'TELSTRA TRANSACTION ID',
                        fieldName : 'transactionId',
                        type : transactionType,//Added:EDGE-212793,Modified:EDGE-215989
                        sortable : true,
                        typeAttributes: {
                            label: { fieldName: 'transactionId' },
                            name: 'transactionId'
                        },//End EDGE : 212793
                    },
                    {
                        label : 'DATE PROCESSED',
                        fieldName : 'paymentDate',
                        type : 'text',
                        sortable : true,            
                    },
                    {
                        label : 'PAYMENT TYPE',
                        fieldName : 'paymentType',
                        type : 'text',
                        sortable : true,            
                    },             
                    {
                        label : 'AMOUNT',
                        fieldName : 'paymentAmountFmtd',
                        type : 'text',
                        sortable : true,            
                    },              
                    /*{
                        label : 'AMOUNT',
                        fieldName : 'paymentAmount',
                        type : 'currency',
                        sortable : true,
                        typeAttributes: { currencyCode: 'AUD'},
                        cellAttributes: { alignment: 'left' },
                    },*/             
                    {
                        label : 'AMOUNT APPLIED TO INVOICES',
                        fieldName : 'paymentAppliedAmount',
                        type : 'currency',
                        sortable : true,
                        typeAttributes: { currencyCode: 'AUD'},
                        cellAttributes: { alignment: 'left' },
                    },
                    {

                        label : 'UNAPPLIED AMOUNT',
                        fieldName : 'paymentUnappliedAmount',
                        type : 'currency',
                        sortable : true,
                        typeAttributes: { currencyCode: 'AUD'},
                        cellAttributes: { alignment: 'left' },
                    }
                ]);
            } else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                console.log('***error while checking billing account payments dormancy***' + errorMsg);
            }
        });
        $A.enqueueAction(action);
    }
    //End:EDGE-215989
     
})
({
	getdoInit : function(component ,event) {
        component.set("v.IsError",false);
		var invoiceLineItemId= component.get("v.invoiceLineItemId");
         
        if(1==1){
        component.set("v.loadingSpinner", true);
        var action= component.get("c.getUsageResponseDetails");
        action.setParams({"invoiceLineItemId": invoiceLineItemId });
        
        action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.loadingSpinner", false);
                if(state === "SUCCESS") {
                    var usageWrapper = response.getReturnValue();
                    
                    console.log("test is ",response.getReturnValue());
                    if(usageWrapper.errorwr==null ){
                        component.set("v.repaymentSummaryDetails", usageWrapper.lstAddWrapper); 
                        var varUsage = component.get("v.repaymentSummaryDetails");
                        component.set("v.IsError",false);
                    }
                    else{
                        alert('else block');
                         component.set("v.repaymentSummaryDetails", usageWrapper.lstAddWrapper);
                        component.set("v.errorMessage",adjWrapper.errorwr.message);
                        component.set("v.IsError",true);
                        //this.showCustomToast(component,adjWrapper.errorwr.message , "Error", "error");
                    }
                } else {
                    console.log(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },
    //Method for sorting data in lightning datatable
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.repaymentSummaryDetails");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.repaymentSummaryDetails", data);
    },
    //Method for searching adjustment data in based on new date selection
    SearchUsageData:function(component ,event) {
        this.doInit(component ,event);
    },
    //Method for sorting data for given field and direction
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
             if(field=='dateApplied'){
                 return function (a, b) {
                     var a = key(a).split('/').reverse().join('');
                     var b = key(b).split('/').reverse().join('');
                     return reverse * ((a>b) - (b>a));
                     
                 };
             }
        else{
            return function (a, b) {
                return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
            }
        }
    }, 
})
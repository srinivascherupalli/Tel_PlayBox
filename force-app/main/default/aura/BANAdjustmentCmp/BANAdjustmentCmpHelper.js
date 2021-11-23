/*EDGE -104930
Name: BanAdjustmentCmpHelper.js
Description: Js helper for BanAdjustmentCmp
Author:Mahima*/
({
    doInit : function(component ,event) {   
        component.set("v.IsError",false);
        var startDateparam = component.get("v.StartDate");    
        var endDateParam = component.get("v.EndDate");
        var billingAccId= component.get("v.billingAccountId");
        
        if(this.getdatevalidate(startDateparam,endDateParam,component)){
            component.set("v.loadingSpinner", true);
            //calling controller method getAdjustmentList 
            var action= component.get("c.getAdjustmentList");
            action.setParams({"startdate": startDateparam, "endDate": endDateParam, "bANId" :billingAccId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                component.set("v.loadingSpinner", false);
                if(state === "SUCCESS") {
                    var adjWrapper = response.getReturnValue();
                    if(adjWrapper.errorwr==null ){
                        component.set("v.ListAdjustment", adjWrapper.lstAddWrapper); 
                        component.set("v.IsError",false);
                        if(adjWrapper.lstAddWrapper == null){
                           component.set("v.errorMessage",$A.get("$Label.c.Credit_And_Adjustment_data_Null"));
                        component.set("v.IsError",true);  
                        }
                         
                    }
                    else{
                         component.set("v.ListAdjustment", adjWrapper.lstAddWrapper);
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
        var data = component.get("v.ListAdjustment");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.ListAdjustment", data);
    },
    //Method for searching adjustment data in based on new date selection
    SearchAdjustmentData:function(component ,event) {
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
    //To set max date today for date inputs.
    setMaxdate: function(component, event){
        var d = new Date();        
        var maxDate = this.getDateString(d);        
        component.set('v.maxdate',maxDate);
    },
    // For returning date string .
    getDateString: function(d){
        var dat= new Date(d);
        var dd = dat.getDate();
        var mm = dat.getMonth() + 1; //January is 0!
        var yyyy = dat.getFullYear();
        if (dd < 10) {
            dd = '0' + dd;
        } 
        if (mm < 10) {
            mm = '0' + mm;
        }
        var dateStr = yyyy + '-' + mm + '-' + dd;
        return dateStr;
    },
    //Show Error or success toast messages
    showCustomToast: function (cmp, message, title, type) {		
        $A.createComponent(
            "c:customToast", {
                "type": type,
                "message": message,
                "title": title
            },
            function (customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");                 
                    body.set("v.body", customComp);
                }
            }
        );
    },
    // Method for validating input dates before making server call.
    getdatevalidate: function(strdate, enddate,component)
    {
        var isvalid= true;
        var errmsg='';
        var today= new Date();
        var sdate= new Date(strdate);
        var edate= new Date(enddate);        
        if(sdate>today || edate>today){
            errmsg=$A.get("$Label.c.Select_Past_Date_For_From_Date_And_To_Date");          
            isvalid= false;
            component.set("v.errorMessage",errmsg);
            component.set("v.IsError",true);
            
            return isvalid;
        }        
        if(strdate!=null && enddate==null){
            errmsg=$A.get("$Label.c.To_Date_Required");            
            isvalid= false;
            component.set("v.errorMessage",errmsg);
            component.set("v.IsError",true);        
            return isvalid;
        }        
        if(strdate==null && enddate!=null){
            errmsg=$A.get("$Label.c.From_Date_Required");                      
            isvalid= false;
            component.set("v.errorMessage",errmsg);
            component.set("v.IsError",true);        
            return isvalid;            
        }
        if(enddate<strdate){
            errmsg=$A.get("$Label.c.To_Date_Greater_Equal_To_From_Date");  
            isvalid= false;
            component.set("v.errorMessage",errmsg);
            component.set("v.IsError",true);
            
            return isvalid;
        }         
        
        return isvalid;      
    }
})
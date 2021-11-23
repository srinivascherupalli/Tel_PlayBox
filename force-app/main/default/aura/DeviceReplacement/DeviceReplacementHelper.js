({
    helperOptionvalue: function(component, field, helper) {
        
        var action=component.get("c.getOptionvalue");
        action.setParams({
            "SobjectApiName": field,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(field=='Reverse_Logistic_Return_Reason__mdt'){
                    component.set("v.returnReasonList",response.getReturnValue())
                }
                else{
                    component.set("v.recoveryMethodList",response.getReturnValue())
                }
                
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
        
    },
    /*Helper class for search functionality  */ 
    searchHelper : function(component, event, helper) {
        var action=component.get("c.searchDevice");
        action.setParams({
            "device": component.get("v.deviceId"),
            "accountId": component.get("v.accountId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var records =response.getReturnValue();
                component.set("v.subsciptionList",records)
                if(component.get("v.subsciptionList") ==null || component.get("v.subsciptionList") ==''){
                    component.set("v.errorMessage",$A.get("$Label.c.Subscription_Not_Found"));
                    component.set("v.showMessage",true);  
                    
                }
                else{
                    component.set("v.shellProductDetails.replacedDeviceID",component.get("v.deviceId"));
                    //EDGE-194027-Dheeraj Bhatt-auto population of Current Device SKU
                    component.set("v.currentDeviceSKUDisabled",false);
                    if(component.get("v.subsciptionList[0].Assets__r") !='undefined' && component.get("v.subsciptionList[0].Assets__r").length !=0 && !this.isEmpty(component.get("v.subsciptionList[0].Assets__r[0].Stock_Keeping_Unit__c"))){
                        component.set("v.currentDeviceSKU",component.get("v.subsciptionList[0].Assets__r[0].Stock_Keeping_Unit__c"));
                        component.set("v.currentDeviceSKUDisabled",true);
                    }
                    component.set("v.showMessage",false);
                    component.set("v.errorMessage",'');
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
    },
    
    //--Edge-100986 start---//
    helperGetAssetName: function(component, field, helper) {
        var action=component.get("c.assetOfferId");
        action.setParams({
            "device": component.get("v.deviceId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.assetRequireField",response.getReturnValue());
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
    },
    //--Edge-100986 end---///
    
    //--Edge-175532 start---//
    helperGetCurrentDeviceSKU: function(component, field, helper) {
        
        var action=component.get("c.currentDeviceSKUCheck");
        action.setParams({
            "device": component.get("v.deviceId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                component.set("v.deviceSKURequiredField",response.getReturnValue());
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
    },
    //--Edge-175532 end---///
    
    submitOrder : function(component, event, helper){
        var action=component.get("c.createOrder");
        action.setParams({
            "accountId": component.get("v.accountId"),
            "subscription":component.get("v.subscriptions"),
            "shellProductDetails":JSON.stringify(component.get("v.shellProductDetails")),
            "deliveryContactId":component.get("v.deliveryContact.ContactId"),
            "deliveryAddressId":component.get("v.deliveryAddress.Id"),
            "tNowCaseRef":component.get("v.tNowCaseRef")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") { 
                component.set("v.order",response.getReturnValue());
                if(component.get("v.order.csord__Order_Number__c") !=null){
                    this.showReplacedeviceButton(component, event, helper);
                    component.set("v.showSpinner",false);
                    component.set("v.showSuccessMessage",true);
                    component.set("v.successMessage",$A.get("$Label.c.Order_Created_successfully"));
                    component.set("v.deviceId",'');
                }else{
                    component.set("v.showSpinner",false);
                    component.set("v.errorMessage",$A.get("$Label.c.Error_In_Order_creation"));
                    component.set("v.showMessage",true);
                }
                component.set("v.shellProductDetails",{});
                component.set("v.deliveryAddress",null);
                component.set("v.deliveryContact",null);
                
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
    },
    showReplacedeviceButton:function(component, event, helper){
        var action=component.get("c.showAddReplaceButton");
        action.setParams({
            "accountId": component.get("v.accountId"),
            "device":component.get("v.deviceId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") { 
                var assetStatus=response.getReturnValue();
                if(assetStatus==null || assetStatus==''){
                    component.set("v.showReplaceButton",true);
                    component.set("v.assetStatus",'');
                }
                else{
                    component.set("v.assetStatus",assetStatus);
                    component.set("v.showReplaceButton",false);
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
                component.set("v.errorMessage",errorMsg);
                component.set("v.showMessage",true);
            }
        });
        $A.enqueueAction(action);
    },
    //EDGE-194027-Dheeraj Bhatt-To check whether string is empty or not.
    isEmpty:function(str) {
        return (!str || 0 === str.length || str === null || str === '' || str === 'undefined');
    }  
    
})
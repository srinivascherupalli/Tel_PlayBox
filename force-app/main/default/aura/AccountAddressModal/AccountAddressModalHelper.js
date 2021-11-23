({
    doInit : function(component, event, helper) {
        document.title = component.get("v.title");
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        console.log('value: ',value);
        var context = '';
        
        context = JSON.parse(window.atob(value)); 
        component.set("v.parentRecordId",context.attributes.recordId);
        console.log('context.attributes.recordId:',context.attributes.recordId);  
        
        var action = component.get('c.getParentAccount');       
        action.setParams({"accountId" : component.get('v.parentRecordId')});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            component.set("v.accountDetails",data);
        });
        $A.enqueueAction(action);
        // Hide both Search by Address Or AdboreId, Search Result Components on init:
        var toggleText = component.find("SearchByAddressAdboreId");
        $A.util.addClass(toggleText,'toggle');
        
        toggleText = component.find("SearchResultId");
        $A.util.addClass(toggleText,'toggle'); 
        
    },
    doCloseOperation : function(component, event, helper) {
        //Closing the Modal Window
        var getId = component.get("v.parentRecordId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });        
        homeEvt.fire();        
    },
    searchAddressOpen : function (component, event, helper) {
        
        var offerDetailsLC = component.find("DetailsAddressId");
        $A.util.addClass(offerDetailsLC,'toggle');
        var offerTemplateLC = component.find("SearchByAddressAdboreId");
        $A.util.removeClass(offerTemplateLC,'toggle');
    },
    handleBubbling : function(component, event, helper) {
        var params = event.getParams();
        var navigateAction = params.ComponentAction;
        
        switch (navigateAction) {
                
            case "CreateSiteModel_AddAddress":                
                var toggleText = component.find("DetailsAddressId");
                $A.util.addClass(toggleText,'toggle'); 
                
                var toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'toggle'); 
                
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchByAddressAdboreId");
                $A.util.removeClass(displaySection,'toggle');
                break;
                
            case "SearchAddressAdborid_Cancel":
                var toggleText = component.find("SearchByAddressAdboreId");
                $A.util.addClass(toggleText,'toggle');
                
                toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'toggle'); 
                
                // Unhide DetailsAddress main               
                var displaySection = component.find("DetailsAddressId");
                $A.util.removeClass(displaySection,'toggle');
                break;
                
            case "searchAddressResult_Next":
                var toggleText = component.find("SearchByAddressAdboreId");
                $A.util.addClass(toggleText,'toggle');
                
                toggleText = component.find("DetailsAddressId");
                $A.util.addClass(toggleText,'toggle'); 
                
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchResultId");
                $A.util.removeClass(displaySection,'toggle');
                break;
                
            case "SearchAddressAdborid_Back":
                var toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'toggle');
                
                toggleText = component.find("DetailsAddressId");
                $A.util.addClass(toggleText,'toggle'); 
                
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchByAddressAdboreId");
                $A.util.removeClass(displaySection,'toggle');
                break;
                
            case "SearchAddressAdborid_Select":
                var toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'toggle');
                
                toggleText = component.find("SearchByAddressAdboreId");
                $A.util.addClass(toggleText,'toggle'); 
                
                // Unhide DetailsAddress main               
                var displaySection = component.find("DetailsAddressId");
                $A.util.removeClass(displaySection,'toggle');
                break;     
        }
        
    },
    searchedCompletedAction : function(component, event, helper) {
        var params = event.getParams();
        if(params.searchedResult != null && params.searchedResult != ''){
            this.getAddressNameAfterSel(component, event, helper, params.searchedResult);
        }        
    },
    getAddressNameAfterSel : function(component, event, helper, addressId){           
        var action = component.get("c.getAddressNameSFDC");
        action.setParams({"addressId" : addressId});
        
        action.setCallback(this, function(response) {
            console.log('inside getSiteName');
            var data = response.getReturnValue();
            console.log(JSON.stringify(data));
            component.set("v.siteName",data);
            component.find("addressLookup").set("v.value",addressId);
        });
        $A.enqueueAction(action);
    },
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    getAddressTypes: function (component, event, helper) {
        var action = component.get("c.getaddressTypes");
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.options", opts);
        });
        $A.enqueueAction(action);
    },
    isAddressTypeAvailable : function(component, event, helper){
         console.log('In isAddressAvailable helper');
        var action = component.get("c.hasAddress");
        var addressType = component.find("addressType").get("v.value");
         var account = component.get("v.parentRecordId");
        action.setParams({"addressType" : ''+ addressType, "account" : ''+account});
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                if(!opts){
                    this.showToast(component,event,addressType,$A.get("$Label.c.Address_Error"),'error');   
                }
                component.find("hiddenActive").set("v.value",opts);
                component.find("hiddenActive").set("v.disabled",!opts);               
            }else if (state === "ERROR") { 
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        this.showToast(component,event,addressType,errors[0].message,'error'); 
                    }
                } else {
                    this.showToast(component,event,addressType,'Unknown Error','error'); 
                }
            }
        });
        $A.enqueueAction(action);
    },
    saveAccount : function (component, event, helper) {       
        helper.waiting(component);
        event.preventDefault();
        event.stopPropagation();
        //component.set("v.loadingSpinner", true);
        if((component.find("addressLookup").get("v.value")!= null && component.find("addressLookup").get("v.value").trim() !='')){
            var account = component.get("v.parentRecordId")
            var address = component.find("addressLookup").get("v.value");
             var addType =component.find("addressType").get("v.value");
            var active = component.find("hiddenActive").get("v.value");
           
            var actionForType = component.get("c.getAddressType");
            actionForType.setParams({"address" : address}); 
            $A.enqueueAction(actionForType);
            
            var action = component.get("c.saveNewAddressRel");
            action.setParams({"addressType" : ''+ addType, "account" : ''+account,"address" : ''+address,"active" : ''+active});
            action.setCallback(this, function(response) {
                //var data = response.getReturnValue();
                var data = JSON.parse(response.getReturnValue()); 
                console.log('data:',data);
                console.log('data.successMsg:',data.successMsg);
                //component.set("v.loadingSpinner", false);
                if(data.isSuccess == false){
                    component.set("v.loadingSpinner", false);
                    this.showToast(component, event, 'Failure',data.errorMsg,'error');    
                }else{
                    this.showToast(component, event, 'Success',data.successMsg,'success');
                   console.log( 'event.getSource().get("v.value")',event.getSource().get("v.value"));
                    if(event.getSource().get("v.value") == "SaveNew"){
                        helper.doneWaiting(component);
                        $A.get("e.force:refreshView").fire();
                    }
                    else{
                        helper.doneWaiting(component);
						this.showCustomerPage(component, event, helper);
                    }
                }
            });
          
            actionForType.setCallback(this, function(response) {
                var data = response.getReturnValue();
                var addressType = data.cscrm__Address_Type__c;
                    $A.enqueueAction(action);
            });
            
        }
   else if(component.find("addressLookup").get("v.value") == null || component.find("addressLookup").get("v.value") =='') {
                component.set("v.loadingSpinner", false);
                component.find("addressLookup").showError('Please select an address');
            }
    },
    showToast : function(component, event, title ,msg,msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 5000,
            "title": title,
            "message": msg,
            type : msgType
        });
        toastEvent.fire();
    },
    showCustomerPage : function(component, event, helper) {
        var getId = component.get("v.parentRecordId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });        
        homeEvt.fire(); 
    },
     waiting: function(component) {
    	 component.set('v.loadingSpinner', true);
     },
 
    doneWaiting: function(component) {
    	component.set('v.loadingSpinner', false);
   }
})
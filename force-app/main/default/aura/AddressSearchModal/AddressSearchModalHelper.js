({
    doInit : function(component, event, helper) {
        
        document.title = component.get("v.title");
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        console.log('value: ',value);
        var context = '';
        
        context = JSON.parse(window.atob(value)); 
        component.set("v.parentRecordId",context.attributes.recordId);
        console.log('context.attributes.recordId:',context.attributes.recordId);  
        
        
        
        
        var action = component.get('c.getParentContact');
        
        action.setParams({"contactId" : component.get('v.parentRecordId')});
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
            console.log('inside getAddressName');
            var data = response.getReturnValue();
            console.log(JSON.stringify(data));
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
    getAddressName : function(component, event, helper){
        var address = component.find("addressLookup").get("v.value");
        
        var action = component.get("c.getAddressNameSFDC");
        action.setParams({"addressId" : address});
        
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log(JSON.stringify(data));
            
        });
        $A.enqueueAction(action);
    },
    
    
    saveContact : function(component, event, helper) {
        console.log('in savecontact');
        helper.waiting(component);
        event.preventDefault();
        event.stopPropagation();
        //component.set("v.loadingSpinner", true);
        //if all the mandatory fields are entered
        var add = component.find("addressType").get("v.value"); 
        console.log('add: ',add);
        if((!component.find("addressType").get("v.value"))){
            console.log('in error condition++');
             this.showToast(component, event, 'Failure','Please select Address Type','error');    
        }
        else if((component.find("addressLookup").get("v.value")!= null && component.find("addressLookup").get("v.value").trim() !='')){
            //   alert('All Valid---> '+component.find("addressLookup").get("v.value"));
            
            var contact = component.get("v.parentRecordId")
            var address = component.find("addressLookup").get("v.value");
            var addType =component.find("addressType").get("v.value");
            var active = component.find("hiddenActive").get("v.value");
            var primary = component.find("hiddenPrimary").get("v.value");
            var actionForType = component.get("c.getAddressType");
            actionForType.setParams({"address" : address}); 
            $A.enqueueAction(actionForType);
            
            var action = component.get("c.saveNewContact");
            action.setParams({"addressType" : ''+ addType, "contact" : ''+contact,"address" : ''+address,"active" : ''+active,"primary" : ''+primary});
            action.setCallback(this, function(response) {
               
                var data = JSON.parse(response.getReturnValue()); 
                console.log('data:',data);
                console.log('data.successMsg:',data.successMsg);
                component.set("v.loadingSpinner", false);
                if(data.isSuccess == false){
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
        //  component.set("v.loadingSpinner", false);
    },
    
    showToast : function(component, event, title ,msg,msgType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            type : msgType,
            duration : 5000,
            "title": title,
            "message": msg
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
        $A.get("e.force:refreshView").fire();
    },
    getContactAddressType: function (component, event, helper) {
        var action = component.get("c.getContactAddressTypesController");
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.options", opts);
        });
        $A.enqueueAction(action);
    },
    onChangeHelper : function(component, event, helper){
        var addressType =component.find("addressType").get("v.value");
        var contact = component.get("v.parentRecordId");
        var tempContact=contact;
        
        
        var action = component.get("c.hasAddress");
        if(tempContact!=null){
            action.setParams({"addressType" : ''+ addressType, "contact" : ''+tempContact});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                //alert(data);            
                if(addressType.includes('Home Address') || addressType.includes('Office Address')){
                    if(data){
                        component.find("hiddenActive").set("v.value",true);
                        component.find("hiddenPrimary").set("v.value",true);
                        component.set("v.isEdit",false);
                    }
                    else{
                        if(addressType.includes('Home Address')){
                            component.find("hiddenActive").set("v.value",false);
                            component.find("hiddenPrimary").set("v.value",false);
                            component.set("v.isEdit",true);
                            helper.showToast(component, event, addressType ,$A.get("$Label.c.ContactAddressPrimaryActive"),'error');
                            
                        }
                        else if(addressType.includes('Office Address')){
                            component.find("hiddenActive").set("v.value",false);
                            component.find("hiddenPrimary").set("v.value",false);
                            component.set("v.isEdit",true);
                            helper.showToast(component, event, addressType ,$A.get("$Label.c.ContactAddressPrimaryActiveOffice"),'error');
                            
                        }                
                    }
                    
                }
                else{
                    component.find("hiddenActive").set("v.value",false);
                    component.find("hiddenPrimary").set("v.value",false);
                    component.set("v.isEdit",false);
                    
                }
            });
            $A.enqueueAction(action);
        } 
    },
    waiting: function(component) {
        component.set('v.loadingSpinner', true);
    },
    
    doneWaiting: function(component) {
        component.set('v.loadingSpinner', false);
    }
})
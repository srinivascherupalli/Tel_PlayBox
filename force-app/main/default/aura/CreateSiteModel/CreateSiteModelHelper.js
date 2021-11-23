({
    doInit : function(component, event, helper) {
        document.title = component.get("v.title");
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = '';
     //   var context = JSON.parse(window.atob(value));
     /* This is the case for Save and New click from edit page */
        if(value == null){
        var action= component.get('c.getParaSaveAndNew');
        action.setCallback(this, function(response) {
            var dataSite = response.getReturnValue();
            var state = response.getState();
            if(dataSite != null && dataSite != 'Fail' && dataSite != '' && state === "SUCCESS"){
                component.set("v.parentRecordId",dataSite.cscrm__Account__c);
                var actionParent = component.get('c.getParentAccount');
                actionParent.setParams({"accountId" : dataSite.cscrm__Account__c});
                actionParent.setCallback(this, function(response1) {
                var dataParent = response1.getReturnValue();
                component.set("v.accountDetails",dataParent);
                });
                $A.enqueueAction(actionParent);
            }
             else{
                  this.showToast(component, event, 'Failure',$A.get("$Label.c.Site_Saved_Failure"));   
                }

        });
        $A.enqueueAction(action);
        }
        /* This is the case for Save and New click from edit page */
        else{
          context = JSON.parse(window.atob(value)); 
          component.set("v.parentRecordId",context.attributes.recordId);
        }
        
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
            this.getSiteNameAfterSel(component, event, helper, params.searchedResult);
        }        
    },
    getSiteNameAfterSel : function(component, event, helper, addressId){           
        var action = component.get("c.getSiteNameSFDC");
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
    getSiteName : function(component, event, helper){
        var address = component.find("addressLookup").get("v.value");
        
        var action = component.get("c.getSiteNameSFDC");
        action.setParams({"addressId" : address});
        
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log(JSON.stringify(data));
            component.set("v.siteName",data);
        });
        $A.enqueueAction(action);
    },
    
    saveSite : function(component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        component.set("v.loadingSpinner", true);
        //if all the mandatory fields are entered
        if(component.find("SiteName").get("v.validity").valid && (component.find("addressLookup").get("v.value")!= null && component.find("addressLookup").get("v.value").trim() !='')){
            //   alert('All Valid---> '+component.find("addressLookup").get("v.value"));
            var siteName = component.find("SiteName").get("v.value");
            var account = component.get("v.parentRecordId")
            var address = component.find("addressLookup").get("v.value");
            
            var actionForType = component.get("c.getAddressType");
            actionForType.setParams({"address" : address}); 
            $A.enqueueAction(actionForType);
            
            var action = component.get("c.saveNewSite");
            action.setParams({"siteName" : ''+ siteName, "account" : ''+account,"address" : ''+address});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                component.set("v.loadingSpinner", false);
                if(data == 'Failed'){
                    this.showToast(component, event, 'Failure',$A.get("$Label.c.Site_Saved_Failure"));    
                }else{
                    this.showToast(component, event, 'Success',$A.get("$Label.c.Site_Saved_Success"));
                    this.showCustomerPage(component, event, helper);
                }
            });
            
            actionForType.setCallback(this, function(response) {
                var data = response.getReturnValue();
                  component.set("v.loadingSpinner", false);
                var addressType = data.cscrm__Address_Type__c;
                if(addressType == "Postal Address"){
                    component.find("addressLookup").showError(($A.get("$Label.c.Error_Addresslookup_CreateSite")));
                }else{
                    $A.enqueueAction(action);
                }
            });
        }
        
        else if(!component.find("SiteName").get("v.validity").valid){
            component.set("v.loadingSpinner", false);
            component.find("SiteName").showHelpMessageIfInvalid();
        }	
            else if(component.find("addressLookup").get("v.value") == null || component.find("addressLookup").get("v.value") =='') {
                component.set("v.loadingSpinner", false);
                component.find("addressLookup").showError('Please select an address');
            }
      //  component.set("v.loadingSpinner", false);
    },
    showToast : function(component, event, title ,msg) {
        var toastType = '';
        if(title.includes("Success")){
            toastType = 'Success';
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg,
            type : toastType
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
    }
})
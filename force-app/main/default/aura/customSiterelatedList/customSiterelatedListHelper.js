({
    fetchSites : function(cmp, event, helper) {
        var accountId = cmp.get("v.recordId");
        cmp.set("v.parentRecordId",accountId);
        console.log("accountId",accountId);
        cmp.set('v.siteColumns', [
          //  {label: 'Site Name', fieldName: 'Name', type: 'text'},
             {label: 'Site Name', fieldName: 'linkName', type: 'url', 
            typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            
            {label: 'Address', fieldName: 'Address__c', type: 'text'},
            {label: 'Address Status', fieldName: 'address_Status__c', type: 'text'},
            {label: 'Source System', fieldName: 'source_system__c', type: 'text'}
        ]);
        var action = cmp.get("c.getAllsites");
        
      
        action.setParams({"accountId" : accountId,"ViewAllRec":cmp.get("v.ViewAllRec")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                
                console.log('response*****');
                var baseurl = window.location.href;
              
                var url='/partners/s/detail/';
                if (baseurl.includes('partners.enterprise.telstra.com.au')){
                    
                    url='/detail/';
                }
                else {
                    url='/partners/s/detail/';
                }
                
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = url+record.Id;
                });
                cmp.set("v.siteList", records);
              
            }
        });
        
        var actionParent = cmp.get('c.getParentAccount');
        actionParent.setParams({"accountId" : accountId});
        actionParent.setCallback(this, function(response1) {
            var dataParent = response1.getReturnValue();
            cmp.set("v.accountDetails",dataParent);
        });
        $A.enqueueAction(actionParent);
        
        var actionParentpor = cmp.get('c.checkcreatesiteaccess');
        actionParentpor.setParams({"accountId" : accountId});
        actionParentpor.setCallback(this, function(responsepor) {
            var dataParent1 = responsepor.getReturnValue();
            console.log('dataParent1',dataParent1);
        
            cmp.set("v.canCreateSite",dataParent1);
     
            
        });
        $A.enqueueAction(actionParentpor);
        
        $A.enqueueAction(action);
        
        
    },
	 doCloseOperation : function(component, event, helper) {
           component.set("v.isOpen", false);
          component.set("v.loadingSpinner", false);
       /*  
        //Closing the Modal Window
        //EDGE-136660-Dheeraj Bhatt-Change the below code to naviagte to parentRecord for PRM users.
        if(component.get("v.parentRecordId")!=''|| component.get("v.parentRecordId")!='') {
        var url='';
        if (window.location.href.includes('partners.enterprise.telstra.com.au') || window.location.href.includes('partners')){
             url=window.location.origin+'/partners/'+component.get("v.parentRecordId");
        }
        else{
            url=window.location.origin+'/'+component.get("v.parentRecordId");
        }
      window.open(url,'_self');
        }
        else{
            window.close();
        }
       // Ashtrik was here var getId = component.get("v.parentRecordId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });        
        homeEvt.fire(); */
        
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
               
                if(data == 'Failed'){
                     component.set("v.loadingSpinner", false);
                    this.showToast(component, event, 'Failure',$A.get("$Label.c.Site_Saved_Failure"));    
                }else{
                   this.doCloseOperation(component, event, helper);
                  	component.set("v.isOpen", false);
                    this.showToast(component, event, 'Success',$A.get("$Label.c.Site_Saved_Success"));
                    //this.showCustomerPage(component, event, helper); 
                     $A.get("e.force:refreshView").fire();
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
       // EDGE-136660-Dheeraj Bhatt-to reuse the existing above closeOperation Method.
        this.doCloseOperation(component, event, helper);
      /*var getId = component.get("v.parentRecordId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });        
        homeEvt.fire(); */
    }
})
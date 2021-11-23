({
	doInit : function(component, event, helper) {
        var url = window.location.href;
        var accID = helper.getAccID(component, event, helper,url);
        var accLookup = component.find("accountLookup");
        
        var hiddenSiteName = component.get("v.hiddenSiteName");
        var hiddenAccountId = component.get("v.hiddenAccountId");
        var hiddenAddressId = component.get("v.hiddenAddressId");

        if( hiddenAccountId!= null){
            //prepopulate Account in Site after saving address from EAST
            accLookup.set("v.value", hiddenAccountId);
        }
        else if(accID != null){
            //prepopulate Account from url
            accLookup.set("v.value", accID);
            component.set("v.hiddenAccountId",accID);
        }
        
        if(hiddenSiteName != null){
            //prepopulate SiteName in Site after saving address from EAST
            component.find("SiteName").set("v.value",hiddenSiteName);
        }
        if(hiddenAddressId != null){
            //prepopulate address in Site after saving address from EAST
            helper.populateAddress(component, event, helper);
        }
      	
    },
    saveSite : function(component, event, helper) {
        event.preventDefault();
        event.stopPropagation();
        
        //if all the mandatory fields are entered
        if(component.find("SiteName").get("v.validity").valid && component.find("addressLookup").get("v.value")!= null){
            helper.saveSite(component, event, helper);
        }
       
        else if(!component.find("SiteName").get("v.validity").valid){
            component.find("SiteName").showHelpMessageIfInvalid();
        }	
        else if(component.find("addressLookup").get("v.value") == null) {
            component.find("addressLookup").showError('Please select an address');
        }
    },
    
    cancelSiteCreation : function(component, event, helper) {
        var url = window.location.href;
        var accID = helper.getAccID(component, event, helper,url);
        var nextURL;
        var orgURL = $A.get("$Label.c.Lightning_Org_URL");
        if(accID != null) {
            nextURL = orgURL + '/Account/' + accID + '/view';
        }else if (component.get("v.hiddenAccountId") != null){
            nextURL = orgURL + '/Account/' + component.get("v.hiddenAccountId") + '/view';
        }
        window.location = nextURL;
    },
    
    navigateToSearchAddress : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SearchAddress",
            componentAttributes: {
                //for US-3971
                inputAddress : event.getParam("inputText") ,
                //end
                hiddenSiteName : component.find("SiteName").get("v.value") ,
                hiddenAccountId : component.find("accountLookup").get("v.value") ,
                hiddenNavigator : 'SiteCreate'
            }
        });
        evt.fire();
    },

	getSiteName : function(component, event, helper){
        var address = component.find("addressLookup").get("v.value");
    	//var address = component.get("v.hiddenAddressId");
        console.log("test 1"+ address);    
        
        var action = component.get("c.getSiteNameSFDC");
        action.setParams({"addressId" : address});
        
        action.setCallback(this, function(response) {
            console.log('inside getSiteName');
            var data = response.getReturnValue();
            console.log(JSON.stringify(data));
                component.set("v.siteName",data);
        });
        $A.enqueueAction(action);
	}

    
})
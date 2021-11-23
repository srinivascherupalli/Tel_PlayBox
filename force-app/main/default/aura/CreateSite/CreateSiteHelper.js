({
    getAccID : function(component, event, helper,url) {
        var accID;
        if(url.includes('accIDURL')){
            accID = url.split('?accIDURL=')[1];
        	if(accID.includes('&'))
            accID = accID.split('&')[0];
        }
        //NFB-4427 Sales Console Issue Fixes
        if(accID == null){
        	var temp_accID = url.split('/sObject/')[1];
        if(temp_accID != null)
        	accID = temp_accID.split("/")[0];
        }
         return accID;
        //Change for sales console End
    }
	,
	saveSite : function(component, event, helper) {
		var siteName = component.find("SiteName").get("v.value");
        var account = component.find("accountLookup").get("v.value");
        var address = component.find("addressLookup").get("v.value");
        
        var actionForType = component.get("c.getAddressType");
        actionForType.setParams({"address" : address}); 
        $A.enqueueAction(actionForType);
        
        var action = component.get("c.saveNewSite");
        action.setParams({"siteName" : ''+ siteName, "account" : ''+account,"address" : ''+address});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data == 'Failed'){
            	this.showToast(component, event, 'Failure',$A.get("$Label.c.Site_Saved_Failure"));    
            }else{
                this.showToast(component, event, 'Success',$A.get("$Label.c.Site_Saved_Success"));
                this.showCustomerPage(component, event, helper);
            }
        });
        //Edge - 108 Start
        
        actionForType.setCallback(this, function(response) {
            var data = response.getReturnValue();
            var addressType = data.cscrm__Address_Type__c;
        	if(addressType == "Postal Address"){
           	 	component.find("addressLookup").showError(($A.get("$Label.c.Error_Addresslookup_CreateSite")));
        	}else{
        		$A.enqueueAction(action);
        	}
        });
        
        //Edge - 108 Stop 
	}
    ,
    populateAddress : function(component, event, helper){
        component.find("addressLookup").set("v.value",component.get("v.hiddenAddressId"));
    }
    ,
    showCustomerPage : function(component, event, helper) {
        var url = window.location.href;
        var accID;		
    	if(url.includes('accIDURL')){
        accID= url.split('?accIDURL=')[1];
        if(accID.includes('&'))
            accID = accID.split('&')[0];
		}
        var nextURL;
        var orgURL = $A.get("$Label.c.Lightning_Org_URL");
        if(accID != null) {
            nextURL = orgURL + '/Account/' + accID + '/view';
        }else if (component.get("v.hiddenAccountId") != null){
            nextURL = orgURL + '/Account/' + component.get("v.hiddenAccountId") + '/view';
        }
        window.location = nextURL;
    }
    ,
    showToast : function(component, event, title ,msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
	}
})
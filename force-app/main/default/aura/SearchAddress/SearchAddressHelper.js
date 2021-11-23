({
	searchAddressFromEast: function(component) {
        var action = component.get('c.searchAddress');
        action.setParams({"addressText" : component.get("v.inputAddress")});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log('uploading ' + data[0]);
            component.set("v.addresses",data);
            var responseCode = component.get("v.addresses[0].responseStatus");
            if(response.getReturnValue() == null || response.getReturnValue() == 'Fail' || response.getReturnValue() == ''){
                this.showToast(component, 'Warning!', $A.get("$Label.c.EAST_Service_Unavailable"));
            }else if (response.getReturnValue() != null && responseCode != '200'){
                this.getError(component,responseCode,'EAST_UnStructured');
            }
        });
        $A.enqueueAction(action);
    }
    ,
    
    searchAddressFromNBNEast : function(component) {
        var action = component.get('c.searchAddressByAdborid');
        action.setParams({"adborid" : component.get("v.inputAdborID")});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log('******uploading ' + data);
            component.set("v.nbnAddresses",data);
            var responseStatus = component.get("v.nbnAddresses.status");
            if (response.getReturnValue() == null || responseStatus == null){
                this.showToast(component, 'Warning!', $A.get("$Label.c.EAST_Service_Unavailable"));
            }else if (response.getReturnValue() != null && responseStatus != '200') {
                this.getError(component,responseStatus,'EAST_Structured');
            }
        });
        $A.enqueueAction(action);
    }
    ,
    saveAddress : function (component, event, helper, idx,searchType) {
        var action1 = component.get('c.saveAddressApex');
        var addressList = component.get("v.addresses");
        action1.setParams({"addList" : JSON.stringify(addressList),"searchType":searchType,"selectedAddressId" : idx+''});
        action1.setCallback(this,function(response){
            component.set("v.loadingSpinner", false);
        	if(response.getReturnValue() != null && response.getReturnValue() != 'Fail'){
                component.set("v.hiddenAddressId", response.getReturnValue());
                this.showToast(component, 'Success !', $A.get("$Label.c.EAST_Address_Saved_Success"));
                if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'SiteCreate'){
                	this.navigateToSiteCreate(component, event, helper);
                }else if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'AddressRelCreate'){
                	this.navigateToAddressRelCreate(component, event, helper);
                }else if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") =='ContactAddressRelCreate'){
                	this.navigateToContactAddressRelCreate(component, event, helper);
                }else{
                    this.navigateToCreatedAddress(component, event, helper,response.getReturnValue());
                }
            }
            else{
                this.showToast(component, 'Failure', $A.get("$Label.c.EAST_Address_Saved_Failure"));
            }
        });
        $A.enqueueAction(action1);
        
        
    }
    ,
    cancelButtonHelper : function (component,event,helper){
        if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'SiteCreate'){
            this.navigateToSiteCreate(component,event,helper);
        }
        else if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'AddressRelCreate'){
            this.navigateToAddressRelCreate(component,event,helper);
        }
        else if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'ContactAddressRelCreate'){
            this.navigateToContactAddressRelCreate(component,event,helper);
        }
        else{
            window.location = $A.get("$Label.c.Lightning_Org_URL").split('/r')[0] +'/page/home';
        }
    }
    ,
    navigateToContactAddressRelCreate : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:ContactAddressRelCreate",
            componentAttributes: {
                hiddenContactId : component.get("v.hiddenContactId"),
                hiddenAddressId : component.get("v.hiddenAddressId"),
            }
        });
        evt.fire();
    },
    navigateToAddressRelCreate : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:AddressRelCreate",
            componentAttributes: {
                hiddenAccountId : component.get("v.hiddenAccountId"),
                hiddenAddressId : component.get("v.hiddenAddressId"),
            }
        });
        evt.fire();
    },
    navigateToSiteCreate : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CreateSite",
            componentAttributes: {
                hiddenSiteName : component.get("v.hiddenSiteName"),
                hiddenAccountId : component.get("v.hiddenAccountId"),
                hiddenAddressId : component.get("v.hiddenAddressId"),
                hiddenContactId : component.get("v.hiddenContactId")
            }
        });
        evt.fire();
    }
    ,
    navigateToCreatedAddress : function(component, event, helper, navId) {
		var orgURL = $A.get("$Label.c.Lightning_Org_URL");
        var nextURL = orgURL + '/Account/' + navId + '/view';
        window.location = nextURL;
	},
    navigateToAddressPage : function(component, event, helper, url) {
        var addressID = url.split('%2CaddressIdUrl%3D')[1];
         if(addressID.includes('&'))
           addressID = addressID.split('&')[0];
        var sourceSystem = url.split('%2CaddressIdUrl%3D')[0];
        var sourceSystemUrl = sourceSystem.split('?sourceSystemUrl=')[1];
        var action = component.get('c.getId');
        action.setParams({"adborid" : addressID});
        action.setCallback(this, function(response) {
        var data = response.getReturnValue();
        component.set("v.addressRecordId",data);
        if(sourceSystemUrl == 'EAST'){
        	this.showToast(component, 'Warning !', $A.get("$Label.c.Address_From_EAST"));
        	this.navigateToCreatedAddress(component, event, helper,component.get("v.addressRecordId"));
        }
        if(sourceSystemUrl == '' || sourceSystemUrl == null ){
        	this.showToast(component, 'Warning !', 'Source_system field is null');
        	this.navigateToCreatedAddress(component, event, helper,component.get("v.addressRecordId"));
        }
        else if (sourceSystemUrl == 'TCM' && (addressID.startsWith('T') || addressID.startsWith('U'))){
            this.showToast(component, 'Warning !', $A.get("$Label.c.AddressId_Is_CDBORID"));
        	this.navigateToCreatedAddress(component, event, helper,component.get("v.addressRecordId"));
        }
        else if (sourceSystemUrl == 'TCM' || sourceSystemUrl == 'Replicator'){
        component.set("v.searchBy",'adborid');
        component.find("address").set("v.value",false);
        component.find("adborid").set("v.value",true);
        component.set("v.sourceSystemUrl",sourceSystemUrl);
        component.find("inputAdborID").set("v.value",addressID);
        component.set("v.addressIdUrl",addressID);
        }
        });
        $A.enqueueAction(action);
	}
    ,
    showToast : function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
	} ,

    getError : function(component,errorStatus,interfaceName){
    	var action = component.get('c.getErrorMsg');
        action.setParams({"errorStatus" : errorStatus.toString() ,"interfaceName" : interfaceName});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            console.log('uploading ' + data);
            if(data == null){
                this.showToast(component, 'Warning!',$A.get("$Label.c.EAST_Service_Unavailable"));
            }else{
            component.set("v.errorMsg",data.BusinessDescription__c);
            var error = component.get("v.errorMsg");
            this.showToast(component, 'Warning!',error);
            }
        })
        $A.enqueueAction(action);
    }
})
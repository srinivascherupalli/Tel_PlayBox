({
    goToSiteModel : function(component, event, helper) {       
        component.set("v.addresses",null);
        component.set("v.dataAddress",null);
        component.set("v.nbnAddresses",null);
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
        //Closing the Modal Window
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Cancel' });
        appEvent.fire();          
    },
    goToSearchAddress : function (component, event, helper) {
        component.set("v.addresses",null);
        component.set("v.dataAddress",null);
        component.set("v.nbnAddresses",null);
        component.set("v.addresses",null);
        $A.util.addClass(component.find("errorMsgId"),'toggle');
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Back' });
        appEvent.fire(); 
    },
    handleInputRecord : function (component, event, helper) {
        var params = event.getParams();
        if(params.hiddenNavigator == 'searchedResultSel'){
            return;
        }
        //  var searchedInputValue = params.ComponentAction;
        component.set("v.loadingSpinner", params.loadingSpinner);
        component.set("v.parentRecordId", params.parentID);
        component.set("v.searchText",params.searchedText);
        //   alert(JSON.stringify("<------>"+params.parentID +"<------>"+params.searchedText +"<------>"+params.searchType +"<------>"+params.loadingSpinner));
        // -------------------- 
        component.set('v.columns', [
            {label: 'ADDRESS ID', fieldName: 'addressId', type: 'text'},
            {label: 'Address', fieldName: 'addressLine',initialWidth: 150, type: 'text', iconName: 'standard:address'},
            {label: 'Locality', fieldName: 'locality', type: 'text', iconName: 'standard:location'},
            {label: 'State', fieldName: 'state', type: 'text', iconName: 'standard:location'},
            {label: 'Postcode', fieldName: 'postcode', type: 'text', iconName: 'standard:location'},
            {label: 'Status', fieldName: 'status', type: 'text',iconName: 'standard:stage'},
            {label: 'NBN Status', fieldName: 'nbnStatus', type: 'text', iconName: 'standard:stage'},
            {label: 'Type', fieldName: 'addressType', type: 'text'}
            
        ]);
        //------------------- 
        
        
        if(params.searchType == 'Address'){
            var action = component.get('c.searchAddress');
            action.setParams({"addressText" : params.searchedText});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                component.set("v.addresses",data);
                component.set("v.dataAddress", data);
                var responseCode = component.get("v.addresses[0].responseStatus");
                if(response.getReturnValue() == null || response.getReturnValue() == 'Fail' || response.getReturnValue() == ''){
                    this.showToast(component, 'Warning!', $A.get("$Label.c.EAST_Service_Unavailable"));
                }else if (response.getReturnValue() != null && responseCode != '200'){
                    this.getError(component,responseCode,'EAST_UnStructured');
                }
                component.set("v.loadingSpinner", false);
                component.set("v.searchByAddressFlag" ,true);
                component.set("v.searchByAdboridFlag" ,false);
                component.set("v.searchBy",params.searchType);
            });
            $A.enqueueAction(action);
        }
        else if (params.searchType == 'AdborID'){
            if(params.searchedText == null || params.searchedText ==''){
                helper.showToast(component, 'Warning !', 'Please provide a valid/10 digit ADBORID');
            }
            else{
                var action = component.get('c.searchAddressByAdborid');
                action.setParams({"adborid" : params.searchedText});
                action.setCallback(this, function(response) {
                    var data = response.getReturnValue();
                    component.set("v.nbnAddresses",data);
                    var responseStatus = component.get("v.nbnAddresses.status");
                    //  alert(responseStatus);
                    if (response.getReturnValue() == null || responseStatus == null){
                        this.showToast(component, 'Warning!', $A.get("$Label.c.EAST_Service_Unavailable"));
                    }else if (response.getReturnValue() != null && responseStatus != '200') {
                        this.getError(component,responseStatus,'EAST_Structured');
                    }
                    component.set("v.loadingSpinner", false);
                    component.set("v.searchByAddressFlag" ,false);
                    component.set("v.searchByAdboridFlag" ,true);
                    component.set("v.searchBy",params.searchType);
                });
                $A.enqueueAction(action);
            }
        }
    },
    saveAddress : function (component, event, helper) {
        
        var targetId = event.target.id;
        component.set("v.loadingSpinner", true);
        //var idx = event.getSource().get("v.name");
        var idx = targetId;
        var searchType = component.get("v.searchBy");
        var action = component.get('c.saveAddressApex');
        var addressList = component.get("v.addresses");
        /*  alert('*****>'+JSON.stringify(addressList) +' ****** '+searchType +' ****** '+idx); */
        action.setParams({"addList" : JSON.stringify(addressList),"searchType":searchType.toLowerCase(),"selectedAddressId" : idx+''});
        action.setCallback(this,function(response){
            /*    alert(JSON.stringify("<------>"+response.getReturnValue() )); */
            if(response.getReturnValue() != null && response.getReturnValue() != 'Fail'){
                component.set("v.searchedAddressId", response.getReturnValue());
                this.showToast(component, 'Success !', $A.get("$Label.c.EAST_Address_Saved_Success"));
                // if(component.get("v.hiddenNavigator") != null && component.get("v.hiddenNavigator") == 'SiteCreate'){
                this.navigateToSiteCreate(component, event, helper);
                //  }
            }
            else{
                component.set("v.loadingSpinner", false);
                this.showToast(component, 'Failure', $A.get("$Label.c.EAST_Address_Saved_Failure"));
                //  this.getError(component,'',$A.get("$Label.c.EAST_Address_Saved_Failure"));
            }
        });
        $A.enqueueAction(action);
        
    },
    navigateToSiteCreate : function(component, event, helper) {
        component.set("v.loadingSpinner", true);
        var appEventRecond = $A.get("e.c:RecordDetailEvent");
        appEventRecond.setParams({"parentID" : component.get("v.parentRecordId") });
        appEventRecond.setParams({"searchType" : component.get("v.searchBy") });
        appEventRecond.setParams({"loadingSpinner" : true });
        appEventRecond.setParams({"searchedResult" : component.get("v.searchedAddressId") });
        appEventRecond.setParams({"hiddenNavigator" : 'searchedResultSel' });
        appEventRecond.fire(); 
        
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Select' });
        appEvent.fire(); 
        
        component.set("v.addresses",null);
        component.set("v.dataAddress",null);
        component.set("v.nbnAddresses",null);
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
    },
    getError : function(component,errorStatus,interfaceName){
        var action = component.get('c.getErrorMsg');
        action.setParams({"errorStatus" : errorStatus.toString() ,"interfaceName" : interfaceName});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue();
            if(data == null){
                this.showToast(component, 'Warning!',$A.get("$Label.c.EAST_Service_Unavailable"));
                component.set("v.errorMsg",$A.get("$Label.c.EAST_Service_Unavailable"));
                this.showCustomErrorMsg(component, 'Warning!',error);
            }else{
                component.set("v.errorMsg",data.BusinessDescription__c);
                var error = component.get("v.errorMsg");
                this.showToast(component, 'Warning!',error);
                
                component.set("v.errorMsg",data.BusinessDescription__c);
                this.showCustomErrorMsg(component, 'Warning!',error);
            }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, title, msg) {
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
    getAddressInDataTable : function(component, event, helper){
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', editable:'true', type: 'text'},
            {label: 'Phone', fieldName: 'Phone', editable:'true', type: 'phone'},
            {label: 'Rating', fieldName: 'Rating', editable:'true', type: 'text'},
            {label: 'Custom Field', fieldName: 'My_Custom_Field__c', editable:'true', type: 'text'}
        ]);
    },
    showCustomErrorMsg : function(component, title, msg) {
        var errorMsgId = component.find("errorMsgId");
        $A.util.removeClass(errorMsgId,'toggle');
        
    },    
    toggle : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        $A.util.toggleClass(toggleText, "toggle");
    },
    closeModel : function(component, event, helper) {
        //Closing the Modal Window
        var getId = component.get("v.parentRecordId");
        var homeEvt = $A.get("e.force:navigateToURL");
        homeEvt.setParams({
            "url": "/"+getId+""
        });        
        homeEvt.fire(); 
        // component.find("overlayLibRefId").notifyClose();
    },
})
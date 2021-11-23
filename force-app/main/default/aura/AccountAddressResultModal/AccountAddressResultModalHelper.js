({
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
        
        component.set("v.searchText",'');
        if(params.hiddenNavigator == 'searchedResultSel'){
            return;
        }
        component.set("v.loadingSpinner", true);
        component.set("v.parentRecordId", params.parentID);
        
        component.set('v.columns', [
            {label: 'ADDRESS ID', fieldName: 'addressId', type: 'text'},
            {label: 'Address', fieldName: 'addressLine',initialWidth: 150, type: 'text', iconName: 'standard:address'},
            {label: 'Locality', fieldName: 'locality', type: 'text', iconName: 'standard:location'},
            {label: 'State', fieldName: 'state', type: 'text', iconName: 'standard:location'},
            {label: 'Postcode', fieldName: 'postcode', type: 'text', iconName: 'standard:location'},
            {label: 'Status', fieldName: 'status', type: 'text',iconName: 'standard:stage'},
            {label: 'Type', fieldName: 'addressType', type: 'text'}
            /*{label: 'NBN Status', fieldName: 'nbnStatus', type: 'text', iconName: 'standard:stage'},
            */
            
        ]);
        console.log('searchType:',params.searchType);
        console.log('searchedText:',params.searchedText);
        if(params.searchType == 'UnStructuredAddressHandler' || params.searchType == 'StructuredAddressHandler'){
            var action = component.get('c.searchAddressSQ');
            action.setParams({"params" : params.addressMap , "handler" : params.searchType, "adborid":null});
            action.setCallback(this, function(response) {
                var data = response.getReturnValue();
                //EDGE - 79316, Observation 2 fix.
                if(data==null){
                    this.showToast(component, 'Warning!', $A.get("$Label.c.SQ_address_unavailable"),'Warning');
                }
                
                console.log('data: ',data);
                //component.set("v.addresses",data);
                component.set("v.addressesPage",data);
                 component.set("v.columnsPage", data.length);     
                component.set("v.dataAddress", data);
                var responseCode = component.get("v.addressesPage[0].responseStatus");
                var addNotFound = component.get("v.addressesPage[0].addNotFound");
                console.log('responseCode: '+responseCode);
                //EDGE-122625 Kalashree Borgaonkar. Paginate the records. Start
                 if( responseCode == '200'){
                      var appEvent = $A.get("e.c:paginationEvent");
                appEvent.setParams({"PageData" : component.get('v.addressesPage'),
                                    "StartRecord" : 1,
                                    "EndRecord" : 1,
                                    "CurrentPage" : component.get('v.CurrentPage'),
                                    "TotalPages" : Math.ceil(data.length /component.get('v.PageSize')),
                                    "PageSize" : component.get('v.PageSize'),
                                    "TotalRecords" :component.get('v.addressesPage').length}); 
                appEvent.fire();
                this.dispMethod(component);
                  component.set("v.loadingSpinner", false);
                }
                //EDGE-122625 Kalashree Borgaonkar. Paginate the records. end
                if (response.getReturnValue() != null && responseCode == '200'  && addNotFound!=null){
                    this.showToast(component, 'Warning!',addNotFound,'Warning');
                     component.set("v.loadingSpinner", false);
                }
                else if (response.getReturnValue() != null && responseCode != '200'){
                    console.log('responseCode=', +responseCode);
                    this.getError(component,responseCode);
                     component.set("v.loadingSpinner", false);
                }
                
               
                component.set("v.searchByAddressFlag" ,true);
                var tempFlag =  component.get("v.searchByAddressFlag");
                console.log(tempFlag);
                component.set("v.searchByAdboridFlag" ,false);
                component.set("v.searchBy",params.searchType);
                
            });
            $A.enqueueAction(action);
        }
        else if (params.searchType == 'AdborIdAddressHandler'){
            if(params.searchedText == null || params.searchedText ==''){
                helper.showToast(component, 'Warning !',  $A.get("$Label.c.Address_Search_Error"),'Warning');
                //component.set("v.searchText",reset);
            }
            else{
                
                var action = component.get('c.searchAddressSQ');
                action.setParams({"params" : null , "handler" : params.searchType,"adborid" : params.searchedText});
                action.setCallback(this, function(response) {
                    console.log('in adbor search');
                    var data = response.getReturnValue();
                    //EDGE - 79316, Observation 2 fix.
                    if(data==null){
                    	this.showToast(component, 'Warning!', $A.get("$Label.c.SQ_address_unavailable"),'Warning');
                	}
                    //component.set("v.addresses",data);
                    component.set("v.addresses",data);
                    console.log('data:adbor ',data);
                    var addNotFound = component.get("v.addresses[0].addNotFound");
                    var responseStatus = component.get("v.addresses[0].responseStatus");
                    //  alert(responseStatus);
                    if (response.getReturnValue() != null && responseStatus == '200'  && addNotFound!=null){
                        this.showToast(component, 'Warning!',addNotFound,'Warning');
                         component.set("v.loadingSpinner", false);
                    }
                    else if (response.getReturnValue() != null && responseStatus != '200') {
                        console.log('responseStatus+',responseStatus);
                        this.getError(component,responseStatus);
                         component.set("v.loadingSpinner", false);
                    }
       
                    component.set("v.searchText",params.searchedText);
                    //component.set("v.loadingSpinner", false);
                    component.set("v.searchByAddressFlag" ,false);
                    component.set("v.searchByAdboridFlag" ,true);
                    component.set("v.searchBy",params.searchType);
                     component.set("v.loadingSpinner", false);
                    
                });
                $A.enqueueAction(action);
            }
        }
    },
    saveAddress : function (component, event, helper) {
        
        var targetId = event.target.id;
        component.set("v.loadingSpinner", true);
        var idx = targetId;
        var searchType = component.get("v.searchBy");
       //EDGE - 76217, Removing usage of saveAddressApexSQ method.
        var action = component.get('c.saveAddressApex'); 
        var addressList = component.get("v.addresses");
        action.setParams({"addList" : JSON.stringify(addressList),"searchType":searchType.toLowerCase(),"selectedAddressId" : idx+''});
        //var action = component.get('c.saveAddressApexSQ');
        var addressList = component.get("v.addresses");
        console.log(JSON.stringify(addressList));
        // action.setParams({"addList" : JSON.stringify(addressList),"searchType":searchType.toLowerCase(),"selectedAddressId" : idx+''});
        //action.setParams({"addList" : JSON.stringify(addressList),"adborid" : idx});
        action.setCallback(this,function(response){
            console.log('response',response);
            if(response.getReturnValue() != null && response.getReturnValue() != 'Fail'){
                component.set("v.searchedAddressId", response.getReturnValue());
                console.log('success');
                this.showToast(component, 'Success !', $A.get("$Label.c.EAST_Address_Saved_Success"),'Success');
                this.navigateToAddressCreate(component, event, helper);                
            }
            else{
                component.set("v.loadingSpinner", false);
                this.showToast(component, 'Failure', $A.get("$Label.c.EAST_Address_Saved_Failure"),'error');
            }
        });
        $A.enqueueAction(action);
        
    }, //resting
    navigateToAddressCreate : function(component, event, helper) {
        
        //component.set("v.loadingSpinner", true);
        
        // EDGE- 71384--start
        var parentCompName=component.get("v.parentComp");
        if(parentCompName!= null && parentCompName=='CreateSiteModal')
        { 
            var appEventRecond = $A.get("e.c:RecordDetailEvent");
            appEventRecond.setParams({"parentID" : component.get("v.parentRecordId") });
            appEventRecond.setParams({"searchType" : component.get("v.searchBy") });
            appEventRecond.setParams({"loadingSpinner" : true });
            appEventRecond.setParams({"searchedResult" : component.get("v.searchedAddressId") });
            appEventRecond.setParams({"hiddenNavigator" : 'searchedResultSel' });
            appEventRecond.fire();    
        }
        else{
            // EDGE- 71384--end
            var appEventRecond = $A.get("e.c:AddressResultEvent");
            appEventRecond.setParams({"parentID" : component.get("v.parentRecordId") });
            appEventRecond.setParams({"searchType" : component.get("v.searchBy") });
            appEventRecond.setParams({"loadingSpinner" : true });
            appEventRecond.setParams({"searchedResult" : component.get("v.searchedAddressId") });
            appEventRecond.setParams({"hiddenNavigator" : 'searchedResultSel' });
            appEventRecond.fire(); 
        }
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Select' });
        appEvent.fire(); 
        
        component.set("v.addresses",null);
        component.set("v.dataAddress",null);
        component.set("v.nbnAddresses",null);
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
    },
    getError : function(component,errorStatus){
        var action = component.get("c.getErrorMsg");
        console.log('errorStatus**', errorStatus);
        var toStr = (errorStatus!=null)?errorStatus.toString():'';
        console.log('toStr',toStr);
        action.setParams({"errorStatus" : toStr});
        action.setCallback(this, function(response) {
            var data = response.getReturnValue(); 
            if(data != null){
                component.set("v.errorMsg",data.BusinessDescription__c);
                var error = component.get("v.errorMsg");
                this.showToast(component, 'Warning!',error,'Warning');
                component.set("v.errorMsg",data.BusinessDescription__c);
                this.showCustomErrorMsg(component, 'Warning!',error);
            }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, title, msg,toastType) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg,
            "type" : toastType
        });
        toastEvent.fire();
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
    },
    //EDGE-39897
    navigateToNewAddress: function(component, event, helper)
    {
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": 'http://lxweb0013.in.telstra.com.au:7780/pls/ws/f?p=AFF:1:102917654335350' 
        });
        eUrl.fire();
    },
     /*---------------------------------------------------------------------------------------
    Name : changeData
    Description : Method to set pagination parameters
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
    changeData:function(component, event){
        console.log('changeData');   
        component.set("v.CurrentPage",  event.getParam("CurrentPage"));
        component.set("v.PageSize", event.getParam("PageSize"));
        component.set("v.TotalPages", event.getParam("TotalPages"));
       
        this.dispMethod(component);
        
    },
    /*---------------------------------------------------------------------------------------
    Name : dispMethod
    Description : Method to display data on page
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
    dispMethod: function(component, event){
        var tempList = [];
        var pNo = component.get("v.CurrentPage");
        var size = component.get("v.PageSize");
        tempList = component.get("v.addressesPage");
        console.log('tempList',tempList);
        //console.log("PageNumber:  "+ pNo);
        //console.log("std Helper:  RecordSize:  "+ size+ " ListSize " + tempList.length);
        component.set("v.addresses", tempList.slice((pNo-1)*size, Math.min(pNo*size, tempList.length)));
        var tempadd = component.get("v.addresses");
        console.log("v.addresses",tempadd);
    },
})
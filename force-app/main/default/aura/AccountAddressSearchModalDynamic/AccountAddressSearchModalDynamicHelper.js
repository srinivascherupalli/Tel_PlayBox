/*****************************************************************************
ChangeSet   No    Name            Date                    Description
EDGE-151593 1     Purushottam     1-09-2020               Added Component in Community Page for Partners.
*******************************************************************************/
({
    doInit : function(component, event, helper) {  
        var toggleText = component.find("SearchResultId");  
        console.log('AccountAddressSearchModalDynamic   Helper 1');
          $A.util.addClass(toggleText, 'slds-hide'); 
                this.loadStreetType(component, event, helper);
        console.log('AccountAddressSearchModalDynamic   helper 2');
        // Added by Purushottam : EDGE-151593  Start
        var baseurl = window.location.href;
        if (baseurl.includes('partners.enterprise.telstra.com.au') || (baseurl.includes('/partners/s'))) {  
            component.set("v.isPartner",true);
        }
        // Added by Purushottam : EDGE-151593  End
    },    
    doCloseOperation : function(component, event, helper) {
        this.clearInput(component, event, helper);
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
        //Closing the Modal Window
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Cancel' });
        appEvent.fire();          
    },
    searchUnstructred : function(component, event, getInputString){
        //component.set("v.IsSpinner", true);
        var radioGrpValue = component.get("v.radioGrpValue");
        var addressMap = component.get("v.addressMap");
        var action = component.get("c.fetchAdd");
        
        
        action.setParams({"parentID" : component.get("v.parentRecordId"),
                          "searchedText" : getInputString,
                          "addressMap" : addressMap,
                          "searchType" : radioGrpValue,
                          "loadingSpinner" : true, 
                         });	
        action.setCallback(this, function(response) {
            component.set("v.spinner" , false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                //component.set("v.IsSpinner", false);
                if (data.length == 0) {
                    component.set("v.Message1", 'No Result Found...');
                }else {
                    component.set("v.Message1", '');
                }
                // 
                component.set("v.listOfSearchRecordsAddnew", data);
            }	
        });	
        $A.enqueueAction(action);
    },
    
    validateUnstructuredInput : function (component, event, helper) {
        var getInputString = component.get("v.UnstructuredInput");
        
        if(getInputString!=null && getInputString.length > 3){
            var forOpen = component.find("searchRes3");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            var forclose2 = component.find("lookup-3481");
            $A.util.addClass(forclose2, 'slds-is-open');
            $A.util.removeClass(forclose2, 'slds-hide');
            
            //component.set("v.IsSpinner", true);
            var iconClose = component.find("iconAdd");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchUnstructred(component,event,getInputString);
            
        }
        else{
            component.set("v.spinner" , false);
            var forclose = component.find("searchRes3");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
            var forclose2 = component.find("lookup-3481");
            $A.util.addClass(forclose2, 'slds-is-close');
            $A.util.removeClass(forclose2, 'slds-is-open');
        }
    },
    navigateToAddressCreate : function(component, event, helper) {
        
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Select' });
        appEvent.fire(); 
        
        component.set("v.addresses",null);
        component.set("v.dataAddress",null);
        component.set("v.nbnAddresses",null);
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
       
    },
    getAddresOnclick:function(component, event, helper){
        var selectedAddGetFromEvent = event.getParam("addressAutoEvent"); 
        
        var action= component.get('c.getAutoCompAddress');
        action.setParams({"name" : selectedAddGetFromEvent});
        action.setCallback(this, function(response){
            var res= response.getReturnValue();
            if(res != null && res != 'Fail'){                 
                component.set("v.searchedAddressIdUnStructure", res);                
                console.log('success before toast');
                this.showToast(component, 'Success !', $A.get("$Label.c.EAST_Address_Saved_Success"),'Success');
                
                 /*Author : Amar Chakka 
                   Jira Story: SFO Sprint 20.04 P2OB-4924,AC-4 and AC-6
                   Description: On creation of Address From Contact/Account Address Lookup Field. Redirecting back to previous screen.*/
            
                var url = window.location.href; 
        		console.log('Printing URL'+url);
       			var substring = "inContextOfRef";
        		//var value = url.substr(0,url.lastIndexOf('/') + 1);
        		console.log('Vlaue of Include FUnction'+url.includes(substring));
 				if(!url.includes(substring)){
                    window.history.back();                    
                }
                // End of the code Added as part of P2OB-4924.

                this.navigateToAddressCreate(component, event,res);
                //Reset the search Bar, edge- 71384
                component.set("v.UnstructuredInput",'');
                component.set("v.listOfSearchRecordsAddnew",'');
                var forclose = component.find("searchRes3");
                $A.util.addClass(forclose, 'slds-is-close');
                $A.util.removeClass(forclose, 'slds-is-open');
                var forclose2 = component.find("lookup-3481");
                $A.util.addClass(forclose2, 'slds-is-close');
                $A.util.removeClass(forclose2, 'slds-is-open');
                
            }
            else{
                component.set("v.loadingSpinner", false);
                this.showToast(component, 'Failure', $A.get("$Label.c.EAST_Address_Saved_Failure"),'error');
            }
        });
        $A.enqueueAction(action);
        
    },
    
    searchAddressResultOpen : function (component, event, helper) {
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
        var radioGrpValue = component.get("v.radioGrpValue");
        var searchString = component.get("v.searchValue");
        var searchLine1 = component.get("v.inputAddress1");
        var streetnumber = component.get("v.inputAddress2");
        var streetname = component.get("v.inputAddress3");
        var streettype = component.get("v.inputAddress4");
        var stateVal = component.get("v.state");
        var postcode =component.get("v.postalCode");
        var locality=component.get("v.locality");
        var addressMap = component.get("v.addressMap");
        if(radioGrpValue == 'AdborIdAddressHandler'){
            if( searchString == null || searchString ==''){
                helper.showToast(component, 'Warning !', $A.get("$Label.c.Address_Search_Error"),'Warning');
            }else
                if(searchString.length>9 || searchString.length<9){
                    helper.showToast(component, 'Warning !', $A.get("$Label.c.Address_Valid_AdborId"),'Warning');
                }else
                {
                    var appEvent = $A.get("e.c:windowSPANotifierEvent");
                    appEvent.setParams({"ComponentAction" : 'searchAddressResult_Next' });
                    appEvent.fire();  
                    
                    var appEventRecordDetails = $A.get("e.c:AddressResultEvent");
                    appEventRecordDetails.setParams({                       
                        "searchedText" : searchString,
                        "addressMap" : addressMap,
                        "searchType" : radioGrpValue,
                        "loadingSpinner" : true,           
                    });
                    appEventRecordDetails.fire(); 	
                }					
        }
        else if(radioGrpValue == 'StructuredAddressHandler'){
            if(streetnumber == null || streetnumber ==' ' || streetnumber =='' || streetnumber.trim()==''|| streetname == null || streetname ==' ' || streetname == '' || streetname.trim()==''||(stateVal == '--None--') || (postcode == '--None--') || (locality ==  '--None--')){
                helper.showToast(component, 'Warning !', $A.get("$Label.c.Structured_Error"),'Warning'); 
            }           
            else{
                addressMap["addressType"]=component.get("v.addressType");
                addressMap["streetnumber"]=component.get("v.inputAddress2");
                addressMap["streetname"]=component.get("v.inputAddress3");
                addressMap["streettype"]=component.get("v.inputAddress4");
                addressMap["state"]=component.get("v.state"); 
                addressMap["postcode"]=component.get("v.postalCode");
                addressMap["locality"]=component.get("v.locality");
                
                //EDGE-71384
                var appEvent = $A.get("e.c:windowSPANotifierEvent");
                appEvent.setParams({"ComponentAction" : 'searchAddressResult_Next' });
                appEvent.fire();  
                
                var appEventRecordDetails = $A.get("e.c:AddressResultEvent");
                appEventRecordDetails.setParams({
                    
                    "searchedText" : searchString,
                    "addressMap" : addressMap,
                    "searchType" : radioGrpValue,
                    "loadingSpinner" : true,           
                });
                appEventRecordDetails.fire(); 	
            }
        }
        
    },
    
    searchCriteria : function (component, event, helper) {
        this.clearInput(component, event, helper);
        var radioGrpValue = component.get("v.radioGrpValue");
        var placeholdertext = 'Search for address';
        if(radioGrpValue == 'AdborIdAddressHandler'){
            component.set("v.isUnstruct", true);
            var addressComp = component.find("searchAddressOption"); 
            var addressCompMsg = component.find("searchAddressMessage");
            var addlineone = component.find("Addressline1");
            var streetnum = component.find("streetnumber");
            var streetname = component.find("streetname");
            var streettype = component.find("streettype");
            var searchUnstruct = component.find("searchUnstructred");
            var adborComp = component.find("searchAdborIdOption");
            var searchButton = component.find("searchbutton");
            var cancelbutton = component.find("cancelbutton");
            $A.util.addClass(searchButton,"displayShow");
            $A.util.removeClass(searchButton,"displayHide");
            $A.util.addClass(cancelbutton,"displayShow");
            $A.util.removeClass(cancelbutton,"displayHide");
           
            $A.util.addClass(adborComp,"displayShow");
            $A.util.removeClass(adborComp,"displayHide");
            $A.util.addClass(addressCompMsg,"displayHide");
            $A.util.removeClass(addressCompMsg,"displayShow");
            $A.util.addClass(addressComp,"displayHide");
            $A.util.removeClass(addressComp,"displayShow");
            $A.util.addClass(searchUnstruct,"displayHide");
            $A.util.removeClass(searchUnstruct,"displayShow");
            
        }else if(radioGrpValue == 'UnStructuredAutocompleteHandler'){
            var adborComp = component.find("searchAdborIdOption");
            var addlineone = component.find("Addressline1");
            var streetnum = component.find("streetnumber");
            var streetname = component.find("streetname");
            var streettype = component.find("streettype");
            var addressCompMsg = component.find("searchAddressMessage");
            var searchUnstruct = component.find("searchUnstructred");
            var addressComp = component.find("searchAddressOption"); 
            var searchButton = component.find("searchbutton");
            var cancelbutton = component.find("cancelbutton");
            $A.util.addClass(searchButton,"displayHide");
            $A.util.removeClass(searchButton,"displayShow");
            $A.util.addClass(cancelbutton,"displayHide");
            $A.util.removeClass(cancelbutton,"displayShow");
            $A.util.addClass(adborComp,"displayHide");
            $A.util.removeClass(adborComp,"displayShow");
            $A.util.addClass(addressCompMsg,"displayHide");
            $A.util.removeClass(addressCompMsg,"displayShow");
            $A.util.addClass(addressComp,"displayHide");
            $A.util.removeClass(addressComp,"displayShow");
            $A.util.addClass(searchUnstruct,"displayShow");
            $A.util.removeClass(searchUnstruct,"displayHide");
            
        }
        
            else if(radioGrpValue=='StructuredAddressHandler'){
                component.set("v.isUnstruct", true);
                var adborComp = component.find("searchAdborIdOption");
                var addressCompMsg = component.find("searchAddressMessage");
                var addlineone = component.find("Addressline1");
                var streetnum = component.find("streetnumber");
                var streetname = component.find("streetname");
                var streettype = component.find("streettype");
                var searchUnstruct = component.find("searchUnstructred");
                var addressComp = component.find("searchAddressOption"); 
                var searchButton = component.find("searchbutton");
                var cancelbutton = component.find("cancelbutton");
                $A.util.addClass(searchButton,"displayShow");
                $A.util.removeClass(searchButton,"displayHide");
                $A.util.addClass(cancelbutton,"displayShow");
                $A.util.removeClass(cancelbutton,"displayHide");
                $A.util.addClass(adborComp,"displayHide");
                $A.util.removeClass(adborComp,"displayShow");
                $A.util.addClass(addressComp,"displayShow");
                $A.util.removeClass(addressComp,"displayHide");
                $A.util.addClass(addressCompMsg,"displayShow");
                $A.util.removeClass(addressCompMsg,"displayHide");
                $A.util.addClass(addlineone,"displayHide");
                $A.util.removeClass(addlineone,"displayShow");
                $A.util.addClass(streetnum,"displayShow");
                $A.util.removeClass(streetnum,"displayHide");
                $A.util.addClass(streetname,"displayShow");
                $A.util.removeClass(streetname,"displayHide");
                $A.util.addClass(streettype,"displayHide");
                $A.util.removeClass(streettype,"displayHide");
                $A.util.addClass(searchUnstruct,"displayHide");
                $A.util.removeClass(searchUnstruct,"displayShow");
                
            }
    },
    validateAdborIDInput : function(component, event, helper) {
        var radioGrpValue = component.get("v.radioGrpValue");
        if(radioGrpValue == 'AdborIdAddressHandler'){
            var adborid = component.get("v.searchValue");
            var reg = /^\d$/;
            var value="";
            for(var i=0;i<adborid.length;i++){
                if(reg.test(adborid[i]) ){
                    value=value+adborid[i].toString();
                }
            }
            adborid=value; 
            component.set('v.searchValue', adborid);
        }
    },
    showToast : function(component, title, msg,msgType) {
        console.log("Inside ShowToast");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg,
            "type" : msgType
        });
        toastEvent.fire();
    },
    onStateChange : function(component, event, helper) {
        var stateCode = component.get("v.state");
        //component.set("v.loadingSpinner", true);
        var action = component.get("c.getPostCodeByState");
        action.setParams({"stateCode" : stateCode});
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.locality", '');
            component.set("v.postalCode", '');
            component.set("v.postCodeList", opts);
            component.set("v.localityList", null);
        });
        $A.enqueueAction(action);
        
    }
    ,
    onPostCodeChange : function(component, event, helper) {
        var postCode = component.get("v.postalCode");
        //component.set("v.loadingSpinner", true);
        var action = component.get("c.getLocalityByPostCode");
        action.setParams({"postCode" : postCode});
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            component.set("v.locality", '');
            component.set("v.localityList", opts);
        });
        $A.enqueueAction(action);       
        
    },
    showCustomErrorMsg : function(component, title, msg) {
        component.set('v.errorMsg', msg);
        var errorMsgId = component.find("errorMsgId");
        $A.util.removeClass(errorMsgId,'toggle');   
        window.setTimeout(
            $A.getCallback(function() {
                $A.util.addClass(component.find("errorMsgId"),'toggle'); 
            }), 5000
        );
    },
    toggle : function(component, event, helper) {
        var toggleText = component.find("errorMsgId");
        //alert(toggleText+ ' inside close button click');
        $A.util.toggleClass(toggleText, "toggle");
    },
    clearInput : function(component, event, helper){
        
        component.set("v.postalCode", '');
        component.set("v.locality", '');
        component.set("v.inputAddress2", '');
        component.set("v.inputAddress3", '');
        component.set("v.inputAddress4", '');
        component.set("v.searchValue",'');
        component.set("v.UnstructuredInput",'');
        component.set("v.listOfSearchRecordsAddnew",'');
        var forclose = component.find("searchRes3");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
        var forclose2 = component.find("lookup-3481");
        $A.util.addClass(forclose2, 'slds-is-close');
        $A.util.removeClass(forclose2, 'slds-is-open');
    },
    /*showSpinner:function(component, event, helper){
        component.set("v.IsSpinner",true);
    },
    
    hideSpinner:function(component, event, helper){
        component.set("v.IsSpinner",false);
    }, */
    
    closeModel : function(component, event, helper) {
        //Closing the Modal Window 
              
        //EDGE- 71384
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "cscrm__Address__c"
        });
        homeEvent.fire();        
        $A.get("e.force:closeQuickAction").fire();  
    },
    
    handleBubbling : function(component, event, helper) {
        var params = event.getParams();
        var navigateAction = params.ComponentAction;
        
        switch (navigateAction) {
                case "searchAddressResult_Next":
                var toggleText = component.find("SearchByAddressAdboreId");
                $A.util.addClass(toggleText,'slds-hide');       
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchResultId");
                $A.util.removeClass(displaySection,'slds-hide');
                break;                            
                
                case "SearchAddressAdborid_Back":
                //alert('SearchAddressAdborid_Back');
                var toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'slds-hide'); 
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchByAddressAdboreId");
                $A.util.removeClass(displaySection,'slds-hide');                
                break;
                
                case "SearchAddressAdborid_Select":
                //alert('SearchAddressAdborid_Select');
                var toggleText = component.find("SearchResultId");
                $A.util.addClass(toggleText,'slds-hide'); 
                // Unhide DetailsAddress main               
                var displaySection = component.find("SearchByAddressAdboreId");
                $A.util.removeClass(displaySection,'slds-hide'); 
                break;
        }
        
    },
    searchedCompletedAction : function(component, event, helper) {
        var params = event.getParams();        
         //alert( params.searchType);
          if(params.hiddenNavigator=='searchedResultSel'){
                if( params.searchType=='AdborIdAddressHandler'){
                     component.set("v.searchValue",''); 
                }
                else if( params.searchType=='StructuredAddressHandler')
                {               
                    
                    component.set("v.inputAddress2", '');
                    component.set("v.inputAddress3", '');
                    component.set("v.inputAddress4", '');
                    component.set("v.addressType", 'All');
       
                    component.set("v.state", '--None--');
                    component.set("v.postalCode", '--None--');
                    component.set("v.locality", '--None--');
                    }
                }
    },
    
    
    loadStreetType : function(component, event, helper) {
        //var stateCode = component.get("v.state");
        //component.set("v.loadingSpinner", true);
        var action = component.get("c.getStreettype");
        
        action.setCallback(this, function(response) {
            var opts = response.getReturnValue();
            console.log('opts: ',opts);
            component.set("v.StreetList", opts);
        });
        $A.enqueueAction(action);
        
    }
    
    
    
})
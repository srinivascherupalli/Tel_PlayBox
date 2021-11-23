({
    doCloseOperation : function(component, event, helper) {
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
        //Closing the Modal Window
        var appEvent = $A.get("e.c:windowSPANotifierEvent");
        appEvent.setParams({"ComponentAction" : 'SearchAddressAdborid_Cancel' });
        appEvent.fire();          
    },
    searchAddressResultOpen : function (component, event, helper) {
        $A.util.addClass(component.find("errorMsgId"),'toggle'); 
        var radioGrpValue = component.get("v.radioGrpValue");
        var searchString = component.get("v.searchValue");
        console.log('****'+radioGrpValue +'****> '+searchString);
        if(searchString == null || searchString ==''){
            helper.showToast(component, 'Warning !', 'Please provide a valid search string'); 
          //  helper.showCustomErrorMsg(component, 'Warning!','Please provide a valid search string');
        }
        else {  
            var appEvent = $A.get("e.c:windowSPANotifierEvent");
            appEvent.setParams({"ComponentAction" : 'searchAddressResult_Next' });
            appEvent.fire();  
            
            var appEventRecordDetails = $A.get("e.c:RecordDetailEvent");
            appEventRecordDetails.setParams({
                "parentID" : component.get("v.parentRecordId"),
                "searchedText" : searchString,
                "searchType" : radioGrpValue,
                "loadingSpinner" : true,           
            });
            appEventRecordDetails.fire(); 
        }
    },
    searchCriteria : function (component, event, helper) {
        var radioGrpValue = component.get("v.radioGrpValue");
        var placeholdertext = 'Search for address';
        if(radioGrpValue == 'AdborID')
            placeholdertext = 'Please enter only numeric values for adborid';
        component.set('v.placeholderText', placeholdertext);
        var searchInputId = component.find("searchInputId");
        var searchValue = searchInputId.get("v.value");
        component.set('v.searchValue', "");
        
    },
    validateAdborIDInput : function(component, event, helper) {
        var radioGrpValue = component.get("v.radioGrpValue");
        if(radioGrpValue == 'AdborID'){
            var adborid = component.get("v.searchValue");
            var reg = /^\d$/;
            var value="";
            for(var i=0;i<adborid.length;i++){
                if(reg.test(adborid[i])){
                    value=value+adborid[i].toString();
                }
            }
            adborid=value; 
            component.set('v.searchValue', adborid);
        }
    },
    showToast : function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'dismissible',
            duration : 2500,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
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
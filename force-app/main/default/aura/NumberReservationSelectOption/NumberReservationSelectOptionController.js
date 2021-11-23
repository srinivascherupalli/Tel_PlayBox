({
    doInit : function(component, event, helper) {
        helper.getProfileId(component, event);//EDGE-203930
        console.log('Inside Select Option do Init');
        component.set("v.selectedoption", "addnewnumber");
        var tabId = component.get("v.selectedTab");
        console.log('tabId>>>>>>>'+tabId);
        if(tabId =='Fixed'){
            //EDGE-208742 renamed Transition numbers to Migratin Numbers for BOH profile 
            if(component.get("v.profileName") == 'Migration BOH user'){ 
            component.set('v.searchoptions', [
                {'label': 'Add New Numbers', 'value': 'addnewnumber'},
                {'label': 'Port In Numbers', 'value': 'portin'},
                {'label': 'Migration Numbers', 'value': 'transitionnumber'},
                {'label': 'Manage Numbers', 'value': 'managenumber'}
            ]);
            }else{
                 component.set('v.searchoptions', [
                {'label': 'Add New Numbers', 'value': 'addnewnumber'},
                {'label': 'Port In Numbers', 'value': 'portin'},
                {'label': 'Transition Numbers', 'value': 'transitionnumber'},
                {'label': 'Manage Numbers', 'value': 'managenumber'}
            ]);
            }
        }
        else{
            helper.setSearchOption(component, event);
            //EDGE-165481,171843.
            //helper.retrievePortOutReversalBtn(component, event);
            //EDGE-185029
             helper.retrieveRadioBtnOptions(component, event);
        }
    },
    handleChange : function(component, event, helper) {
        console.log(component.get("v.selectedoption"));
        var cmpEvent = component.getEvent("NumberReservoptionevt");
        cmpEvent.setParams({
            "selectedsearchoption" : component.get("v.selectedoption")
        });
        cmpEvent.fire();
    }
})
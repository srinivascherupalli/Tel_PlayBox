({
    
    handleEvent: function(component, event, helper) {
        var cmpEvent = component.getEvent("NumberReservevt");
        cmpEvent.setParams({
            clickedAction: "addAddress"
        });
        cmpEvent.fire();
    },
    /*------------------------------------------------------
     * EDGE-126317
     * Method:renderPatternTypeOptions
     * Description: Method to validate number reservation for NgUc
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
    renderPatternTypeOptions: function(component, event) {
        // component.set("v.loadingSpinner", true);
        var searchType = component.get("v.numberReserve.selectedSearchType");
        console.log("searchType", searchType);
        var action = component.get("c.getPatternType");
        action.setParams({
            searchType: searchType
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var patternList = response.getReturnValue();
                console.log("patternList: ", patternList);
                component.set("v.numberReserve.patternList", patternList);
            }
            //component.set("v.loadingSpinner", false);
        });
        $A.enqueueAction(action);
    },
    handleSearchNumbers: function(component, event) {
        var searchdata = component.get("v.numberReserve");
        
        console.log('searchdata',searchdata);
        console.log(searchdata)
        var cmpEvent = component.getEvent("searchresultevt");
        cmpEvent.setParams({
            "searchresult" : searchdata,
            "searchType": 'search'
        });
        cmpEvent.fire();
    },
    /*------------------------------------------------------
    EDGE-93081 
    Description: LRM AutoReserve MSISDN Numbers called from component
    ------------------------------------------------------*/
    //Auto Reserve Numbers for LRM
    handleAutoReserve: function(component, event, helper) {
        var searchdata = component.get("v.numberReserve");
        var cmpEvent = component.getEvent("searchresultevt");
        cmpEvent.setParams({
            "searchresult" : searchdata,
            "searchType": 'Autoreserve'
        });
        cmpEvent.fire();
    },
    //DIGI-3161 added by shubhi for logging transaction logs for splunk
    logTransaction: function(component, event, helper,searchType,eventInfo){
		var searchdata = component.get("v.numberReserve");
        var reqQuan=0;
        if(searchType=='Auto Reserve'){
            reqQuan=searchdata.autoReserverQuantity;
        }else if (searchType=='Pattern Search'){
            reqQuan=searchdata.quantity;
        }
        var action = component.get("c.logTransaction");
        action.setParams({
            "searchType": searchType,
            "basketId":component.get("v.basket_id"),
            "quantity":reqQuan,
            "event":eventInfo
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Transaction log inserted");
            }        
        });
        $A.enqueueAction(action);
    }
});
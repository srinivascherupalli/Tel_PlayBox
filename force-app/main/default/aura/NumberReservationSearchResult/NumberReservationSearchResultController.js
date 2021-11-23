////EDGE-140792,EDGE-138086
({
    
    doInit : function(component, event, helper) { 
        helper.getColumnAndAction(component);
        helper.getSIMConfig(component, event, helper);
        var data = component.get("v.searchResult");
        var reserverecord = component.get("v.reservedata");
        console.log(reserverecord);
        if(reserverecord != undefined)
        	component.set("v.totalReservedrecord",reserverecord.length);
        
        if(component.get("v.selectedradio") == 'Transition'){
            component.set("v.showAssignButton",false);
        }else{
             component.set("v.showAssignButton",true);
        }
         //EDGE-144140 Kalashree set default selected tab
      /*  if(component.get("v.showSearchTab")==false){
            component.set("v.selectedTabId","reservationpull");
        }
        else{
            //component.set("v.selectedTabId","searchresulttab");
        } */

    },//EDGE-140792,EDGE-138086
    handleClickedTab : function(component, event, helper) {
        console.log('Inside handleClickedTab');
        var cmpEvent = component.getEvent("refreshTab");
        cmpEvent.fire();
        helper.handlerefreshdataview(component, event, helper,'','');
        
    },//EDGE-140792,EDGE-138086
    handleReserve :  function(component, event, helper) {
        var searchType="Pattern Search";
        var eventType="Number reservation initiated";
        helper.logTransaction(component, event,helper,searchType,eventType);//DIGI-3161 added by shubhi
        helper.handleReserve(component, event,helper);
    },//EDGE-140792,EDGE-138086
    handleSelectedrecords :  function(component, event, helper) {
        helper.handleSelectedrecords(component, event);
    },//EDGE-140792,EDGE-138086
    removeassignednumber:  function(component, event, helper) {
        console.log('Inside removeassignednumber');
        helper.removeassignednumber(component, event, helper);
    },//EDGE-140792,EDGE-138086
    assignSelectedNumbers:  function(component, event, helper) {
        console.log('Inside assignNumbers');
        helper.assignSelectedNumber(component, event, helper);
    },//EDGE-140792,EDGE-138086
    removefromreservationPool:  function(component, event, helper) {
        console.log('Inside removefromreservationPool');
        //helper.removefromreservationPool(component, event, helper);
        helper.removeNumberFromPools(component, event, helper);
    },//EDGE-140792,EDGE-138086
    executeAfterreserve : function (component, event, helper) {
        var params = event.getParam('arguments');
        component.set("v.productconflist",params.updatedpcs);
        component.set("v.reservedata",params.updatednumbers);
    },
    pickListValueChange: function (component, event, helper){
        helper.updateNumberRecs(component, event, helper);
    },
    prodConfigRowSelection: function (component, event, helper){
        helper.handleSelectedrecordslwc(component, event, helper);
    },
     //EDGE-168641 : On change of SIM Configuration
    getSIMType: function (component, event, helper){
        if(component.get("v.isngEMPresent")) {
            var selPickListValue = event.getSource().get("v.value");
            console.log("selPickListValue: ",selPickListValue);
            component.set("v.SIMType",'');
            var simType = [];
            var configData= component.get("v.SIMConfig");
            for (var i = 0; i < configData.length ; i++)
            {
                if(component.get("v.selectedradio") == configData[i].Selected_Tab__c && configData[i].SIM_Options__c == selPickListValue)
                {
                    var type = configData[i].Type__c;
                    simType =  type.split(",");

                }
            }                 
            component.set("v.SIMType",simType);  
            console.log("simType: ",simType);
        }        
    }  ,
    handleQualifySim :function (component, event, helper){
        helper.handleQualifySim(component, event);
    } ,
    validateSimSerNum :function (component, event, helper){
        helper.validateSimSerNum(component, event);
    } ,
    //EDGE-185029,EDGE-186482. Kalashree Borgaonkar. SIM detail assignment and validations for Reactivate services
    assignSIMforReactivation :function (component, event, helper){
        helper.assignSIMforReactivation(component, event);

    } ,
    reservedataRowSelection: function (component, event, helper){
        helper.handlereserveRowSelected(component, event, helper);
    },
    //EDGE-203929-Dheeraj Bhatt-Enhancements to "Assign Numbers To" table to display add-ons in a Tree view for each plan config record
    onRowSelection: function (component, event, helper){
        helper.onRowSelection(component, event, helper);  
    },
     //203932-Dheeraj Bhatt-Number Assignment for Transition without reservation Pool
    handleSelectTransitionNumberEvt: function (component, event, helper){
        helper.handleSelectTransitionNumberEvt(component, event, helper);  
    },
  	//DIGI-1946 - Purushottama Sahu. Bulk upload of SIM Serial numbers in Port-In number management screen
  	handleBulkUploadChange:function(component, event,helper) {
        console.log('handleBulkUploadChange');
        let spinner = event.getParam('spinner');
        if(spinner){
           component.set("v.loadingSpinner", true); 
        }else{
            let messge = event.getParam('message');
            let type = event.getParam('type');
          helper.handlerefreshdataview(component, event, helper,messge,type);
        }
    }
})
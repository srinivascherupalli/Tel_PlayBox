({
  doInit: function(component, event, helper) {
      console.log('in controller');
    component.set("v.columns", helper.getColumnDefinitions());
     // component.set("v.isFailure",false);
    component.set("v.theBtnLabel", "Reserve");
    //EDGE-89984
    const empApi = component.find('empApi');
         empApi.onError($A.getCallback(error => {
             console.error('EMP API error for ChangeOfMobileNumber : ', error);}));
     //till here
  },
  openModel: function(component, event, helper) {
    // for Display Model,set the "isOpen" attribute to "true"
    component.set("v.isOpen", true);
   
  },

  closeModel: function(component, event, helper) {
    // for Hide/Close Model,set the "isOpen" attribute to "Fasle"
    component.set("v.isOpen", false);
  },

  likenClose: function(component, event, helper) {
    
	component.set("v.showSpinner", true);
    var filteredData = component.get("v.selectedRowsList");
    var actType = component.get("v.actionTypeSelected");
    var tNowCsRef = component.get("v.tNowCaseRef");//EDGE-132715
    var allSelectedSubId = [];
    filteredData.forEach(function(filData) {
      allSelectedSubId.push(filData.SubscriptionID);
   
    });
      if(component.get("v.theBtnLabel") === 'Reserve'){
          component.set("v.isError", false);
           var action = component.get("c.invokeMSISDNForNumberChange");

   
    action.setParams({
      subId: allSelectedSubId
    });
    action.setCallback(this, function(response) {
     	  var state = response.getState();
        console.log('response...'+JSON.stringify(response.getReturnValue()));
        console.log('response.getState...'+state);
        if(state === 'SUCCESS'){
            if(response.getReturnValue() === 'SUCCESS'){
                //EDGE-89984::start
                const empApi = component.find('empApi');
                const SubmitStatus = component.find('nextbtn').get('v.value');
                const replayId = -1;
                // Subscribe to the event
                empApi.subscribe(SubmitStatus, replayId, $A.getCallback(eventReceived => {
                    console.log('Received event ', JSON.stringify(eventReceived));
                }))
                    .then(subscription => {
                    console.log('Event Recieved!');
                });
                    //EDGE-89984::End
                    component.set("v.showSpinner", false);
                    var myLabel = component.set("v.theBtnLabel","Submit Order");
            }
                    else{
                    component.set("v.showSpinner", false);
                    component.set("v.isError", true);
                }
          
        }
            else{      
            component.set("v.showSpinner", false);
            component.set("v.isError", true);
        }
		  
    });
    $A.enqueueAction(action);
      }else {
                    //added by Vamsi for DIGI-17914 04NOV2021 starts
                    var date1 = new Date();
                    var timeMilSec = date1.getTime();
                    component.set('v.dateTimeMilliseconds',timeMilSec);
                    helper.changeMobileNumberLogs(component, event, helper);
                    //added by Vamsi for DIGI-17914 04NOV2021 ends           
           var action = component.get("c.submitOrder");
    action.setParams({
       subId : allSelectedSubId,
      scenarioType : actType,
            tNowCaseRef : tNowCsRef
      
    });
	
    action.setCallback(this, function(response) {
     	var state = response.getState();
        var res = response.getReturnValue();
        var accId =  component.get("v.accountId");
        if(state === 'SUCCESS'){
            //if (res === 'Success'){ //Shweta commented this  EDGE:185521
            component.set("v.showSpinner", false);
            component.set("v.disabled",true);
          //Toast
             
           component.set("v.isSuccess",true);
            //added by Vamsi for DIGI-17914 04NOV2021 starts
            var orderID = response.getReturnValue();
            helper.changeMobileNumberLogs(component, event, helper, orderID);
            //added by Vamsi for DIGI-17914 04NOV2021 ends
               // helper.redirectToAccountPage(component,accId); //Shweta commented this  EDGE:185521
                  helper.redirectToOrderPage(component,res); //Shweta added this  EDGE:185521

        }
        else {
            component.set("v.isFailure",true);
            helper.redirectToAccountPage(component,accId);
        }
        
        //} 
        
    });
    $A.enqueueAction(action);
      }
   
  },

  NavigateComponent: function(component, event, helper) {
    component.set("v.isOpen", true);
    var message = event.getParam("filteredData");
      var accID = event.getParam("accountId");
       var actType = event.getParam("actTypeSelected");
        var tNowRef = event.getParam("tNowCaseRef");
      component.set("v.tNowCaseRef", tNowRef);
        component.set("v.actionTypeSelected", actType);
      let selectedRecordSub = event.getParam("selectedRecordSub");
     let selectedRows = [];
      message.forEach(function(obj) {
          if(selectedRecordSub.includes(obj.SubscriptionID)){ 
              selectedRows.push(obj);
          }
         // selectedRows.push(obj.Id); 
      });
    //Set the handler attributes based on event data
   // component.set("v.filteredData", message);
    component.set("v.filteredData", selectedRows);
    component.set("v.data", message);
      component.set("v.accountId", accID);
      
  },

  updateSelectedText: function(component, event, helper) {
    component.set("v.selectedRowsList", event.getParam("selectedRows"));
      component.set("v.btnStatus", false);
  },
  updateColumnSorting: function(component, event, helper) {
    component.set("v.isLoading", true);
    setTimeout(function() {
      var fieldName = event.getParam("fieldName");
      var sortDirection = event.getParam("sortDirection");
      component.set("v.sortedBy", fieldName);
      component.set("v.sortedDirection", sortDirection);
      helper.sortData(component, fieldName, sortDirection);
      component.set("v.isLoading", false);
    }, 0);
  },
  filter: function(component, event, helper) {
    var data = component.get("v.data"),
      term = component.get("v.filter"),
      results = data,
      regex;
    try {
      regex = new RegExp(term, "i");
      // filter checks each row, constructs new array where function returns true
      results = data.filter(
        row =>
          regex.test(row.subscriptionName) ||
          regex.test(row.ServiceId) ||
          regex.test(row.subscriptionNumber)
      );
    } catch (e) {}
    component.set("v.filteredData", results);
    var data1 = component.get("v.filteredData");
    if (data1.length == 0) {
      component.set("v.NoSearchRecord", true);
    }
    if (data1.length != 0) {
      component.set("v.NoSearchRecord", false);
    }
  },
  SubmitOrder: function(component, event, helper) {}
      
});
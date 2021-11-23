/****************************************
EDGE -92546
Name: NumberManagementComp
Description: Show/Select/Remove Reserved Numbers using Manage Tab
Author:Sandip Deshmane
Revision History: EDGE-142086 - Updated this component for UX Uplift
************************************************/

({
//Search and Show Reserved Numbers based on Product Selection.  
  searchReservedNumbers: function(component, event) {
    var selected = component.get("v.selectedTabId");
    var recordId = component.get("v.basket_id");
    var lstpc = component.get("v.selectedPC");
    if(lstpc.length != 0){
        var configIds = [];
        console.log("Selected PC Details", lstpc);
        lstpc.forEach(function(pc) {
          //configIds.push(pc.configId);
          console.log("Config Ids", configIds);
        });
        configIds=lstpc;
        console.log("Config Ids", configIds);
        var searchObj = {
          selectedTabId: selected,
          basket_id: recordId,
          configId: configIds
        };
        console.log("All Variable values:", searchObj);
        component.set("v.loadingSpinner", true);
        var action = component.get("c.getNumberList");
        action.setParams({ searchObj: searchObj });
        action.setCallback(this, function(response) {
          var state = response.getState();
          console.log("Inside Helper Method:", selected);
          if (state === "SUCCESS") {
            console.log("Inside SUCCESS:", state);
            component.set("v.loadingSpinner", false);
            var numWrapList = response.getReturnValue();
            if (numWrapList.length != 0) {
              //added for data table
              var selectedNum = [];
              console.log("Inside Helper Method:", numWrapList);
              component.set("v.NumberObjList", numWrapList);
              component.set("v.selectedRowsNum", selectedNum);
            } else {
              this.showCustomToast(component,$A.get("$Label.c.Reserve_numbers_not_found"),"error","error");
            }
          }
        });
        $A.enqueueAction(action);
      }else{
          this.showCustomToast(component,"Please select product to see Reserved Numbers","error","error");
      }
  },
//Move selected numbers from Existing Number List to Number Pool
  addToRemovalPool: function(component, event) {
    //component.set("v.isReserve", true);
    var tabselected = component.get("v.selectedTabId");
    var remNumList = component.get("v.selectedRowsNumDetails");
    var existingNumList = component.get("v.NumberListToPool");
    var reservedNumList = component.get("v.NumberObjList");
    console.log("Reserved Numbers List:", reservedNumList);
    console.log("Existing Numbers in the Pool:", existingNumList);
    console.log("Selected Number List", remNumList);
    var removeList = JSON.stringify(remNumList);
    var existingList = JSON.stringify(existingNumList);
    var reservedList = JSON.stringify(reservedNumList);
    if (remNumList.length > 0) {
      var action = component.get("c.addToNumberPool");
      action.setParams({
        selectedNumList: removeList,
        existingNumList: existingList,
        reservedNumList: reservedList
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var numWrapMap = response.getReturnValue();
          var numWrapList = numWrapMap["NumbersToRemove"];
          var remNumWrapList = numWrapMap["NumbersRemaining"];
          console.log("New Number List", numWrapList);
          console.log("Remaining Number List", numWrapList);
          if (numWrapList.length != 0) {
            //added for data table
            var selectedNum = [];
            component.set("v.NumberListToPool", numWrapList);
            component.set("v.NumberObjList", remNumWrapList);
            component.set("v.selectedRowsNum", selectedNum);
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.loadingSpinner", false);
      this.showCustomToast(
        component,
        "Please select at least one number to Remove.",
        "Error",
        "error"
      );
    }
  },
//Remove selected numbers from Number Pool and add to Existing numbers List    
//EDGE-142086 - Updated this component for UX Uplift
/*  removeFromPool: function(component, event) {
    var remNumList = component.get("v.selectedRowsNumDetails");
    var reservedNumList = component.get("v.NumberObjList");
    var removalPoolList = component.get("v.NumberListToPool");
    console.log("Reserved Numbers List:", reservedNumList);
    console.log("Existing Numbers in the Pool:", removalPoolList);
    console.log("Selected Number List", remNumList);
    var removeList = JSON.stringify(remNumList);
    var numberPoolList = JSON.stringify(removalPoolList);
    var reservedList = JSON.stringify(reservedNumList);
    if (remNumList.length > 0) {
      var action = component.get("c.removeFromNumberPool");
      action.setParams({
        selectedNumList: removeList,
        removalPoolList: numberPoolList,
        reservedNumList: reservedList
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var numWrapMap = response.getReturnValue();
          var numWrapList = numWrapMap["NumbersReserved"];
          var remNumWrapList = numWrapMap["NumbersRemaining"];
          console.log("New Number List", numWrapList);
          console.log("Remaining Number List", numWrapList);
          if (numWrapList.length != 0) {
            //added for data table
            var selectedNum = [];
            component.set("v.NumberListToPool", remNumWrapList);
            component.set("v.NumberObjList", numWrapList);
            component.set("v.selectedRowsNum", selectedNum);
          }
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.loadingSpinner", false);
      this.showCustomToast(
        component,
        "Please select at least one number to Remove.",
        "Error",
        "error"
      );
    }
  },*/
//Update the status of Selected numbers to PENDING DISCONNECTION and show them in the Number Pool
  removeNumbers: function(component, event) {
    var recordId = component.get("v.basket_id");
    var remNumList = component.get("v.selectedRowsNumDetails");
    var removalPoolList = component.get("v.NumberListToPool");
    console.log("Existing Numbers in the Pool:", removalPoolList);
    console.log("Selected Number List", remNumList);
    var removeList = JSON.stringify(remNumList);
    var numberPoolList = JSON.stringify(removalPoolList);
    if(removalPoolList.length > remNumList.length){
        console.log("Selected Numbers are Less than Numbers in Pool", removalPoolList, remNumList);
    	this.showCustomToast(
        component,$A.get("$Label.c.NumberRemovalPendingError"),"Error","error");
    }else{
      if (remNumList.length > 0) {
          var action = component.get("c.removeReservedNumbers");
          action.setParams({
            selectedNumList: removeList,
            removalPoolList: numberPoolList,
            basketid: recordId
          });
          //EDGE-142086 - Updated this component for UX Uplift
          component.set("v.loadingSpinner", true);
          action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
              var numWrapList = response.getReturnValue();
              //EDGE-142086 - Updated this component for UX Uplift
              component.set("v.loadingSpinner", false);
              console.log("Removed Number List", numWrapList);
    
              if (numWrapList.length != 0) {
                //added for data table
                var selectedNum = [];
                component.set("v.NumberListToPool", numWrapList);
                component.set("v.selectedRowsNum", selectedNum);
              }
            }
          });
      	$A.enqueueAction(action);
      	component.set("v.showFinishWarning", true);
    } else {
      component.set("v.loadingSpinner", false);
      this.showCustomToast(
        component,
        "Please select at least one number to Remove.",
        "Error",
        "error"
      );
    }
  }
  },
//Sort Numbers in Existing Number List using different Fields
  sortExistingData: function(component, fieldName, sortDirection) {
    var data = component.get("v.NumberObjList");
    var reverse = sortDirection !== "asc";
    data.sort(this.sortBy(fieldName, reverse));
    component.set("v.NumberObjList", data);
  },
//Sort Numbers in Number Pool using different Fields    
  sortPoolData: function(component, fieldName, sortDirection) {
    var data = component.get("v.NumberListToPool");
    var reverse = sortDirection !== "asc";
    data.sort(this.sortBy(fieldName, reverse));
    component.set("v.NumberListToPool", data);
  },
//Sort by ASC/DESC on different fields    
  sortBy: function(field, reverse, primer) {
    var key = primer
      ? function(x) {
          return primer(x[field]);
        }
      : function(x) {
          return x[field];
        };
    reverse = !reverse ? 1 : -1;
    return function(a, b) {
      return (a = key(a)), (b = key(b)), reverse * ((a > b) - (b > a));
    };
  },
//Toast to display Error message
  showCustomToast: function(cmp, message, title, type) {
    $A.createComponent(
      "c:customToast",
      {
        type: type,
        message: message,
        title: title
      },
      function(customComp, status, error) {
        if (status === "SUCCESS") {
          var body = cmp.find("manageContainer");

          body.set("v.body", customComp);
        }
      }
    );
  },
//EDGE-142086 - Filter Numbers from Existing numbers.
    onChangeFilterText: function(component, event){
        var seachInput = component.find("filterNumber").get("v.value");
        var basketId = component.get("v.basket_id");
    	var lstpc = component.get("v.selectedPC");
        if(lstpc.length != 0){
        	var configIds = [];
            console.log("Selected PC Details", lstpc);
            configIds=lstpc;
            var searchObj = {
            	basket_id: basketId,
                configId: configIds,
                searchTerm: seachInput
            };
                console.log("All Variable values:", searchObj);
                component.set("v.loadingSpinner", true);
                var action = component.get("c.getFilteredNumberList");
                action.setParams({ searchObj: searchObj });
                action.setCallback(this, function(response) {
                  var state = response.getState();
                  if (state === "SUCCESS") {
                    console.log("Inside SUCCESS:", state);
                    component.set("v.loadingSpinner", false);
                    var numWrapList = response.getReturnValue();
                    if (numWrapList.length != 0) {
                      //added for data table
                      var selectedNum = [];
                      console.log("Inside Helper Method:", numWrapList);
                      component.set("v.NumberObjList", numWrapList);
                      component.set("v.selectedRowsNum", selectedNum);
                    } else {
                      this.showCustomToast(component,$A.get("$Label.c.Reserve_numbers_not_found"),"error","error");
                    }
                  }
                });
                $A.enqueueAction(action);  
      }else{
          this.showCustomToast(component,"Please select product to see Reserved Numbers","error","error");
      }
    }
});
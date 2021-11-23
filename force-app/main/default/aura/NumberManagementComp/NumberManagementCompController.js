/****************************************
EDGE -92546
Name: NumberManagementComp
Description: Show/Select/Remove Reserved Numbers using Manage Tab
Author:Sandip Deshmane
Revision History: EDGE-142086 This component is modified to implement UX uplift
************************************************/

({
  handleEvent: function() {},
  doInit: function(component, event, helper) {
    var tabId = component.get("V.selectedTabId");
    var lstpc = component.get("v.selectedPC");
    console.log("Selected PC Details", lstpc);
    console.log("Tab Id Selected", tabId);
    component.set("v.columnsNum", [
      {label: "Number",fieldName: "PhoneNumber",type: "Integer",sortable: true,initialWidth: 300},
      {label: "Range",fieldName: "IsPartOfRange",type: "text",sortable: true,initialWidth: 300},
      {label: "Status",fieldName: "Status",type: "text",sortable: true,initialWidth: 300}
    ]);
     //EDGE-142086 This component is modified to implement UX uplift
    /*component.set("v.columnsNumPool", [
      {label: "Number",fieldName: "PhoneNumber",type: "Integer",sortable: true,initialWidth: 200},
      {label: "Range",fieldName: "NumberRange",type: "text",sortable: true,initialWidth: 200},
      {label: "Status",fieldName: "Status",type: "text",sortable: true,initialWidth: 200}
    ]);*/
    helper.searchReservedNumbers(component, event);
  },
  handleRowSelectionNum: function(cmp, event, helper) {
    console.log("in handleRowSelectionNum");
    var selectedRowsNum = event.getParam("selectedRows");
    var selectedNum = [];
    var selectedNumDetails = [];
    console.log(selectedRowsNum.length);
    var count = selectedRowsNum.length;
    selectedRowsNum.forEach(function(num) {
      	var numberRange = num.IsPartOfRange;
        //EDGE-142086 This component is modified to implement UX uplift
        if(numberRange == "Yes"){
            var ranges = num.PhoneNumber.split(" - ");
            var startRange = parseInt(ranges[0]);
            var endRange = parseInt(ranges[1]);
            count = count+ (endRange - startRange);
            console.log("count"+count);
        }
        /*if(numberRange == "Yes"){
            helper.showCustomToast(cmp,$A.get("$Label.c.NumberRemovalError"),"Error","error");
        }*/
      selectedNum.push(num.numberId);
      selectedNumDetails.push(num);
    });
    console.log(selectedNum);
    cmp.set("v.selectedRowsNumDetails", selectedNumDetails);
    //EDGE-142086 This component is modified to implement UX uplift
    cmp.set("v.noOfRowsSelected", count);
    cmp.set("v.showWarning", false);
  },
  existingNumColumnSorting: function(component, event, helper) {
    var fieldName = event.getParam("fieldName");
    var sortDirection = event.getParam("sortDirection");
    console.log("fieldName", fieldName);
    console.log("sortDirection", sortDirection);
    component.set("v.existingNumsortedBy", fieldName);
    component.set("v.existingNumsortedDirection", sortDirection);
    helper.sortExistingData(component, fieldName, sortDirection);
  },
  poolNumColumnSorting: function(component, event, helper) {
    var fieldName = event.getParam("fieldName");
    var sortDirection = event.getParam("sortDirection");
    console.log("fieldName", fieldName);
    console.log("sortDirection", sortDirection);
    component.set("v.sortedBy", fieldName);
    component.set("v.sortedDirection", sortDirection);
    helper.sortPoolData(component, fieldName, sortDirection);
  },
  addtoRemovalPool: function(component, event, helper) {
    helper.addToRemovalPool(component, event);
  },
  //EDGE-142086 This component is modified to implement UX uplift
  /*removefromPool: function(component, event, helper) {
    helper.removeFromPool(component, event);
  },*/
  removeSelected: function(component, event, helper) {
    helper.removeNumbers(component, event);
  },
//EDGE-142086 This component is modified to implement UX uplift 
  onChangeFilterText: function(component, event, helper){
    console.log("Inside Filter function");
	helper.onChangeFilterText(component, event);
  }
});
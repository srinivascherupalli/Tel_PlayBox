/*--------------------------------------------------------------------------------------
Name : StockCheckBaseHelper
Description : Lightning UI Helper for checking stock availability for mobile devices 
Author: Aishwarya Yeware
Story: EDGE-80858
//Sandhya - INC000094260232 Fix
--------------------------------------------------------------------------------------------------*/
({
  /*---------------------------------------------------------------------------------------
    Name : doInit
    Description : Returns the available Mobile devices
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/

  doInit: function(component, event) {
    /* var myval=component.get("v.selectType"");
        var action = component.get("c.getSelectedDevice");
        action.setParams({"selectedDevice" : myval});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                //var testdata=['--None--'];
                 var devices = [];
                var options = response.getReturnValue();
                devices.push({value: '', label: '--None--'}); 
                for ( var key in options ) {
                    devices.push({value: key, label: options[key]});
                }
                component.set("v.devices",devices);
                //component.set("v.deviceMap",options);
                //alert(options);
                
            }
        });
        $A.enqueueAction(action); */
  },

  /*---------------------------------------------------------------------------------------
    Name : checkQuantity
    Description : Returns the available quantity for selected device
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/

  checkQuantity: function(component, event) {
    var btnelem = component.find("check");
    btnelem.set("v.disabled", true);
    var myval = component.get("v.selectDevice");
    //alert(myval);
    component.set("v.loadingSpinner", true);
    var action = component.get("c.getDeviceQuantity");
    action.setParams({ selectedDevice: myval });
    action.setCallback(this, function(response) {
      var state = response.getState();

      //EDGE:80858 if response is success then set available attribute value
      if (state === "SUCCESS") {
        var options = response.getReturnValue();
        var available = options.stockAvailable;
        component.set("v.loadingSpinner", false);
        if (available == "Check Failed.Please Retry") {
          component.set("v.available", options.stockAvailable);
        } else {
          component.set("v.available", options.stockAvailable + " Available");
          component.set("v.restocked", options.restocked);
        }
      }
    });
    $A.enqueueAction(action);
  },
  /*---------------------------------------------------------------------------------------
    Name : onChange
    Description : Method to get device names on change of device type
    Story: EDGE-98400
     -----------------------------------------------------------------------------------*/
  onChange: function(component, event) {
    var btnelem = component.find("check");
    var myval = event.getSource().get("v.value");
    btnelem.set("v.disabled", true);
    //btnelem.v.disabled=true;
    component.set("v.selectType", myval);
    component.set("v.available", "");

    var action = component.get("c.getSelectedDevice");
    action.setParams({ selectedDevice: myval });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var devices = [];
        var options = response.getReturnValue();
        devices.push({ value: "", label: "--None--" });
        for (var key in options) {
          devices.push({ value: key, label: options[key] });
        }
        component.set("v.devices", devices);
        //component.set("v.deviceMap",options);
        //alert(options);
      }
    });
    $A.enqueueAction(action);
  },
  /*---------------------------------------------------------------------------------------
    Name : onReset
    Description : Method to reset the stock on selection value changes
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/

  onReset: function(component, event) {
    var btnelem = component.find("check");
    var myval = event.getSource().get("v.value");

    //EDGE:80858 if dropdown list value is 'None' then disable the button
    if (myval != "--None--") {
      btnelem.set("v.disabled", false);
    } else {
      btnelem.set("v.disabled", true);
    }
    component.set("v.selectDevice", myval);

    component.set("v.available", "");
  },

  /*---------------------------------------------------------------------------------------
    Name : fetchDevices
    Description : Method to fetch mobile devices already in basket
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/

  fetchDevices: function(component, event) {
    component.set("v.loadingSpinner", true);
    var action = component.get("c.setProductDetails");
    var basketId = component.get("v.basketId");
    var attrJson = component.get("v.attrJson");
    var type = component.get("v.type");//DPG-3510
    var solutionName = component.get("v.solutionName"); //DPG-3510, Ila
      
      action.setParams({ basketid: basketId,attrJson:attrJson,type:type, solutionName:solutionName});//DPG-3510(Parameter 'type' & 'solutionName' Introduced)
    action.setCallback(this, function(response) {
      var state = response.getState();

      //EDGE:80858 if response is success then set wrapper list attributes values
      if (state === "SUCCESS") {
        var wrapperList = response.getReturnValue();

        component.set("v.deviceModel", wrapperList);
        component.set("v.columns", wrapperList.length);
        var deviceLength = component.get("v.deviceModel");
        //EDGE-144680 : boolean to check and display the message if more devices are present in Basket 
        console.log('deviceLength outside',deviceLength.length);
        if(deviceLength.length > 1){
            console.log('deviceLength inside',deviceLength.length);
         component.set("v.moreDevices", true);
        }
        //End of : EDGE-144680
        var TotalPages = Math.ceil(wrapperList.length / component.get("v.PageSize"));
        component.set("v.TotalPages",TotalPages);
        //EDGE:80858  fires pagination event to set parameters
        var appEvent = $A.get("e.c:paginationEvent");
        //Start of EDGE-148577 : Added componentName to Event to avoid overriding of the handlee events.
        appEvent.setParams({
          PageData: component.get("v.deviceModel"),
          StartRecord: 1,
          EndRecord: 1,
          CurrentPage: component.get("v.CurrentPage"),
          TotalPages: TotalPages,
          PageSize: component.get("v.PageSize"),
          TotalRecords: component.get("v.deviceModel").length,
          componentName:component.get("v.componentName")
        });
        appEvent.fire();
        this.dispMethod(component);
        component.set("v.loadingSpinner", false);
      } else {
        component.set("v.loadingSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },

  /*---------------------------------------------------------------------------------------
    Name : changeData
    Description : Method to set pagination parameters
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
  changeData: function(component, event) {
    //Start of EDGE-148577 : validating if the event has fired from this component.
    var compName = event.getParam("componentName");
    if(compName == 'StockCheckBaseComponent'){
    component.set("v.CurrentPage", event.getParam("CurrentPage"));
    component.set("v.PageSize", event.getParam("PageSize"));
        component.set("v.TotalPages", component.get("v.TotalPages"));
        //Start of EDGE-148577 : To hide header checkbox on next/previous Page.
         component.set("v.isSelectAll",false);
         component.set("v.isDeviceSelected", true);
        //End of EDGE-148577
    this.dispMethod(component);
    }//End of EDGE-148577
    
  },
  /*---------------------------------------------------------------------------------------
    Name : dispMethod
    Description : Method to display data on page
    Story: EDGE-80858
     -----------------------------------------------------------------------------------*/
  dispMethod: function(component, event) {
      console.log('dispMethod of stockcheckbase');
    var tempList = [];
    var pNo = component.get("v.CurrentPage");
    console.log('current page in basket page');
    var size = component.get("v.PageSize");
    tempList = component.get("v.deviceModel");
    component.set(
      "v.dispList",
      tempList.slice((pNo - 1) * size, Math.min(pNo * size, tempList.length))
    );
  },
  /*---------------------------------------------------------------------------------------
    Name : getDeviceType
    Description : Method to get device type
    Story: EDGE-98400
     -----------------------------------------------------------------------------------*/
  getDeviceType: function(component, event) {
       console.log('getDeviceType of stockcheckbase');
    //var myval=component.get("v.selectType");
    var action = component.get("c.getDevice");

    //action.setParams({"selectedDevice" : myval});
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //var myval=['--None--'];
        var options = response.getReturnValue();

        component.set("v.deviceType", options);
        var myval = component.get("v.deviceType");
        //alert(myval);
      }
    });
    $A.enqueueAction(action);
  },

  handleSelectAllChange: function(component) {
    cosole.log("handleSelectAllChange:");
    var test = component.get("v.isAllSelected");

    if (component.get("v.isAllSelected") == false) {
      component.set("v.isAllSelected", true);
    }
    const myCheckboxes = component.find("checkBoxes");
    let chk = myCheckboxes.length == null ? [myCheckboxes] : myCheckboxes;
    chk.forEach(checkbox =>
      checkbox.set("v.checked", component.get("v.isAllSelected"))
    );
  },

  checkQuantityMultiple: function(component, event) {
    component.set("v.loadingSpinner", true);

    var skuidList = [];
    var rows = component.get("v.selectedRowsDetails");
    var displayList = component.get("v.dispList");

    var action = component.get("c.checkStock");
    action.setParams({
      selectedWrapperList: rows,
      displayWrapper: displayList
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //var myval=['--None--'];
        var options = response.getReturnValue();
        //alert(myval);
        component.set("v.dispList", options);
        component.set("v.loadingSpinner", false);
      } else {
        component.set("v.loadingSpinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  handledeSelectAllContact: function(component, event) {
    var checkQuantity = component.find("checkQuantity");
    var checkvalue = component.find("selectAll").get("v.value");

    var flag = false;
    //int cnt=0;
    //EDGE-123156 Kalashree Borgaonkar
    if (!Array.isArray(checkQuantity)) {
      checkQuantity = [checkQuantity];
    }
    for (var i = 0; i < checkQuantity.length; i++) {
      if (checkQuantity[i].get("v.value") == false) {
        component.set("v.isSelectAll", false);
        break;
      } else {
        break;
      }
    }
    for (var i = 0; i < checkQuantity.length; i++) {
      if (checkQuantity[i].get("v.value") == true) {
        component.set("v.isDeviceSelected", false);
        break;
      } else {
        component.set("v.isDeviceSelected", true);
      }
    }
  },
  handleRowSelection: function(cmp, event) {
    var selectedRows = event.getParam("selectedRows");
    var selectedPC = [];
    var selectedPCDetails = [];

    selectedRows.forEach(function(pc) {
      //selectedPC.push(pc.configId);
      selectedPCDetails.push(pc);
    });

    //cmp.set('v.selectedRowsPC', selectedPC);
    cmp.set("v.selectedRowsDetails", selectedPCDetails);
  },
  handleSelectedProducts: function(component, event) {
    var selectedProducts = [];
    var checkvalue = component.find("checkQuantity");

    if (!Array.isArray(checkvalue)) {
      if (checkvalue.get("v.value") == true) {
        selectedProducts.push(checkvalue.get("v.text"));
      }
    } else {
      for (var i = 0; i < checkvalue.length; i++) {
        if (checkvalue[i].get("v.value") == true) {
          selectedProducts.push(checkvalue[i].get("v.text"));
        }
      }
    }

    component.set("v.loadingSpinner", true);
    var displayList = component.get("v.dispList");
    console.log("displayList", displayList);
    var action = component.get("c.checkStockQuantity");
    action.setParams({
      skuidList: selectedProducts,
      displayWrapper: displayList
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        //var myval=['--None--'];
        var options = response.getReturnValue();
        console.log("options: ", options);
        //alert(myval);
        component.set("v.dispList", options);
        component.set("v.isDeviceSelected", true);
        component.set("v.loadingSpinner", false);
      } else {
        component.set("v.isDeviceSelected", true);
        component.set("v.loadingSpinner", false);
      }
      component.set("v.isSelectAll", false);
    });
    $A.enqueueAction(action);
  },
  handleSelectAllContact: function(component, event) {
    var getID = component.get("v.dispList");
    var checkvalue = component.find("selectAll").get("v.value");
    var checkQuantity = component.find("checkQuantity");
    //EDGE-123156 Kalashree Borgaonkar
    if (!Array.isArray(checkQuantity)) {
      checkQuantity = [checkQuantity];
    }
    if (checkvalue == true) {
      for (var i = 0; i < checkQuantity.length; i++) {
        if(checkQuantity[i] != '' && checkQuantity[i] != null && checkQuantity[i] != 'undefined'){ //INC000094260232 Fix 
            checkQuantity[i].set("v.value", true);
            component.set("v.isDeviceSelected", false);
        }
      }
    } else {
      for (var i = 0; i < checkQuantity.length; i++) {
        if(checkQuantity[i] != '' && checkQuantity[i] != null && checkQuantity[i] != 'undefined'){  // INC000094260232 Fix
            checkQuantity[i].set("v.value", false);
            component.set("v.isDeviceSelected", true);
        }
      }
    }
  }
});
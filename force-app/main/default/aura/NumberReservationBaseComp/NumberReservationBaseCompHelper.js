/****************************************
EDGE -93081
Name: NumberReservationNewComp
Description: Display New number resvation UI for Product Basket 
Author:Ila/Mahima 
************************************************/
({
    //EDGE-93081: Fetch all Prod Config for the basket
    initPC: function(component, event, helper) {
        //EDGE-97393,Call method to get basket stage
        this.getbasketStage(component, event);
        var selected = component.get("v.tabId");
        //EDGE-92546 - added attribute to hold subTab -->
        var selectedSubTab = component.get("v.subTabId");
        var action = component.get("c.getProdConfig");
        var recordId = component.get("v.basket_id");
        action.setParams({ basketId: recordId, selTabId: selected });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pcWrapList = response.getReturnValue();
                console.log(pcWrapList);
                component.set("v.pcWrapList", pcWrapList);
                if (pcWrapList.length == 0 && selected == "Fixed") {
                    this.showCustomToast(
                        component,
                        "No Products available for Fixed number reservation",
                        "Error",
                        "error"
                    );
                } else if (pcWrapList.length == 0 && selected == "Mobile") {
                    this.showCustomToast(
                        component,
                        "No Products available for Mobile number reservation",
                        "Error",
                        "error"
                    );
                }
                if (pcWrapList.length > 0) {
                    component.set("v.basketName", pcWrapList[0].BasketName);
                }
                
                console.log(pcWrapList);
                //added for data table
                var selectedPc = [];
                component.set("v.selectedRowsPC", selectedPc);
                this.getBasketStatus(component, event);
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    // Fetch Numers from Reservation Pool
    fetchReservationPool: function(component, event, helper) {
        var selected = component.get("v.tabId");
        var action = component.get("c.getNumberList");
        var recordId = component.get("v.basket_id");
        //EDGE-117819, Addded selectedTab
        action.setParams({ basketId: recordId, selectedTab: selected });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var numWrapList = response.getReturnValue();
                
                //added for data table
                var selectedNum = [];
                numWrapList.forEach(function(record) {
                    if (record.ProdConfigName) {
                        record.statusIconName = "utility:success";
                    } else {
                        record.statusIconName = "utility:warning";
                    }
                });
                component.set("v.NumberObjList", numWrapList);
                component.set("v.selectedRowsNum", selectedNum);
            } else {
            }
        });
        $A.enqueueAction(action);
    },
    
    //Reserve Selected numbers to Number__c
    reserveSelected: function(component, event, helper, pclist, numberList) {
        console.log("reserveSelected called");
        var identifier = component.get("v.tabId");
        console.log("identifier: ", identifier);
        console.log("pclist: ", pclist);
        if (identifier == "Mobile") {
            if (pclist.length == numberList.length) {
                var action = component.get("c.reserveNumbers");
                var recordId = component.get("v.basket_id");
                //EDGE-144233. Kalashree Borgaonkar. Added basketid in where clause for limiting query to basket
                action.setParams({
                    selectedPcWrapper: pclist,
                    selectedNumbers: numberList,
                    identifier: identifier,
                     basketid:recordId
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var result = response.getReturnValue();
                        if (result == true) {
                            //this.showCustomToast(component,"Selected Product Configuration and Numbers are assigned successfully", "Success", "success");
                            
                            this.initPC(component, event, helper);
                            this.fetchReservationPool(component, event, helper);
                            component.set("v.selectedRows", null);
                            //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                            component.set("v.selectedRowsNumDetails", []);
                            component.set("v.selectedRowsPCDetails",[]);
                        } else {
                            this.showCustomToast(
                                component,
                                "Number reservation for selected Product Configuration got failed. Please try agian later",
                                "Error",
                                "error"
                            );
                            component.set("v.selectedRows", null);
                            //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                            component.set("v.selectedRowsNumDetails", []);
                            component.set("v.selectedRowsPCDetails",[]);
                        }
                    } else {
                        this.showCustomToast(
                            component,
                            response.getError(),
                            "Error",
                            "error"
                        );
                        component.set("v.selectedRows", null);
                        //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                        component.set("v.selectedRowsNumDetails", []);
                        component.set("v.selectedRowsPCDetails",[]);
                    }
                });
                $A.enqueueAction(action);
            } else {
                this.showCustomToast(
                    component,
                    $A.get("{!$Label.c.NumberReservation_QuantityCheck}"),
                    "Error",
                    "error"
                );
                component.set("v.selectedRows", null);
                //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                component.set("v.selectedRowsNumDetails", []);
                component.set("v.selectedRowsPCDetails",[]);
            }
        } else {
            
            var action = component.get("c.reserveNumbers");
            var recordId = component.get("v.basket_id");
                            //EDGE-144233. Kalashree Borgaonkar. Added basketid in where clause for limiting query to basket

            action.setParams({
                selectedPcWrapper: pclist,
                selectedNumbers: numberList,
                identifier: identifier,
                basketid:recordId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result == true) {
                        this.showCustomToast(
                            component,
                            "Selected Product Configuration and Numbers are assigned successfully",
                            "Success",
                            "success"
                        );
                        
                        this.initPC(component, event, helper);
                        this.fetchReservationPool(component, event, helper);
                        component.set("v.selectedRows", null);
                        //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                        component.set("v.selectedRowsNumDetails", []);
                        component.set("v.selectedRowsPCDetails",[]);
                    } else {
                        this.showCustomToast(
                            component,
                            "Number reservation for selected Product Configuration got failed. Please try agian later",
                            "Error",
                            "error"
                        );
                        component.set("v.selectedRows", null);
                        //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                        component.set("v.selectedRowsNumDetails", []);
                        component.set("v.selectedRowsPCDetails",[]);
                    }
                } else {
                    this.showCustomToast(
                        component,
                        response.getError(),
                        "Error",
                        "error"
                    );
                    component.set("v.selectedRows", null);
                    //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                    component.set("v.selectedRowsNumDetails", []);
                    component.set("v.selectedRowsPCDetails",[]);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    //Remove Selected Numbers from Number__c
    removeSelected: function(component, event, helper, pclist, numberList) {
        console.log("numberList.length", numberList.length);
        if (numberList.length == 0) {
            console.log("selectednumber error removeSelected");
            this.showCustomToast(
                component,
                "Please select at least one number",
                "Error",
                "error"
            );
        } else {
            var identifier = component.get("v.tabId");
            console.log("identifier: ", identifier);
            //alert('in ere');
            //component.set("v.loadingSpinner", true);
            if (identifier == "Mobile") {
                var action = component.get("c.unReserveNumbers");
                var recordId = component.get("v.basket_id");
                action.setParams({
                    selectedPcWrapper: pclist,
                    selectedNumbers: numberList,
                    basketId: recordId
                });
                numberList = [];
                console.log("numlen", numberList.length);
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        this.initPC(component, event, helper);
                        this.fetchReservationPool(component, event, helper);
                        var appEvent = $A.get("e.c:removeFromReservationPool");
                        appEvent.fire();
                        
                           //EDGE-135489-26-Feb-2020-Dheeraj Bhatt-Salesforce to disable Unreserve/Rollback API Call for MSISDN on Click of Remove Selected Button
                  /*EDGE-135489-Start
                   window.clearInterval(intervalId);
                        //Polling logic start
                        let intervalId = "";
                        if (respJobid != "") {
                            var action1 = component.get("c.getJobStatus");
                            action1.setParams({ jobId: respJobid });
                            action1.setCallback(this, function(response) {
                                console.log("in callback", response);
                                
                                var state = response.getState();
                                
                                //alert(state);
                                if (state === "SUCCESS") {
                                    var resp1 = response.getReturnValue();
                                    if (resp1 == true) {
                                        component.set("v.loadingSpinner", false);
                                        component.set("v.numList", null);
                                        
                                        this.initPC(component, event, helper);
                                        this.fetchReservationPool(component, event, helper);
                                        //alert(intervalId);
                                        EDGE-105438
								Author: Ila 
                      var appEvent = $A.get("e.c:removeFromReservationPool");
                      appEvent.fire();
                      window.clearInterval(intervalId);
                  }
                } else {
                    console.log("error");
                }
              });
                intervalId = window.setInterval(
                    $A.getCallback(function() {
                        $A.enqueueAction(action1);
                    }),
                    10000
                );
                //alert(intervalId);
            } 
                        else {
                component.set("v.loadingSpinner", false);
                component.set("v.numList", null);
                this.initPC(component, event, helper);
                this.fetchReservationPool(component, event, helper);
                EDGE-105438
					Author: Ila 
                var appEvent = $A.get("e.c:removeFromReservationPool");
                appEvent.fire();
            } EDGE-135489 END*/
              numberList = [];
              console.log("numberList::", numberList.length);
              //polling logic end
              
              component.set("v.loadingSpinner", false);
              
              this.showCustomToast(component,"Numbers removed successfully from reservation pool", "Success", "success");
          } else {
              numberList = [];
              console.log("numberList::", numberList.length);
          }
        });
          $A.enqueueAction(action);
      }
        //EDGE-59982
        else {
            console.log("identifier: ", identifier);
            //alert('in else');
            var action = component.get("c.unReserveFNN");
            var recordId = component.get("v.basket_id");
            component.set("v.isReserve", "Rollback");
            var button = "false";
            var st = "";
            var end = "";
            action.setParams({
                selectedNumbers: numberList,
                basketId: recordId,
                resourceState: component.get("v.isReserve"),
                startNum: st,
                endNum: end
            });
            //alert(numberList);
            action.setCallback(this, function(response) {
                var res = response.getReturnValue();
                console.log("res+++" + res);
                // alert(res);
                if (res.resIds != null || res.stRange != null) {
                    component.set("v.loadingSpinner", false);
                    component.set("v.numList", null);
                    //alert(component.get("v.numList"));
                    
                    this.initPC(component, event, helper);
                    this.fetchReservationPool(component, event, helper);
                    
                    var appEvent = $A.get("e.c:removeFromReservationPool");
                    appEvent.fire();
                    numberList = [];
                    console.log("numberList::", numberList.length);
                } else if (res.errList != null) {
                    //numberList = [];
                    var err = "";
                    var message = "";
                    var i;
                    var len = res.errList.length;
                    for (i = 0; i < len; i++) {
                        message =
                            res.errList[i].resourceId + " " + res.errList[i].message + "\n";
                        err = err + message + "\n";
                    }
                    component.set("v.loadingSpinner", false);
                    
                    //component.set("v.numberList",null); //EDGE-117819 Defect Fix
                    this.showCustomToast(component, err, "Error", "error");
                    component.set("v.selectedRowsNum", null);
                }
            });
            $A.enqueueAction(action);
        }
    }
  },
    
    //Submit Numbers to Reservation Pool
    SubmitReservationPool: function(component, event, helper, operation) {
        var identifier = component.get("v.tabId");
        console.log("identifier: ", identifier);
        var isvalidforReserve = true;
        var lstpc = component.get("v.selectedRowsPCDetails"); //component.get("v.pcWrapList");
        console.log("lstpc", lstpc);
        var lstnumber = component.get("v.selectedRowsNumDetails"); //component.get("v.NumberObjList");
        var selectedPC = [];
        if (identifier == "Mobile") {
            lstpc.forEach(function(pc) {
                //EDGE-96503- Mahima
                if (
                    pc.AssignedNumber != "" &&
                    pc.AssignedNumber != "<Unassigned>" &&
                    operation == "reserve"
                ) {
                    isvalidforReserve = false;
                } else {
                    selectedPC.push(pc.configId);
                }
            });
        } else {
            
               lstpc.forEach(function(pc) {
                //EDGE-117836 defect fix
                if (operation == "reserve") selectedPC.push(pc.configId);
            }); 
            
            
        }
        console.log('selectedPC',selectedPC);
        var selectednumber = [];
        if (identifier == "Mobile") {
            lstnumber.forEach(function(num) {
                //if(num.IsSelected==true)
                //{
                if (operation == "reserve") {
                    selectednumber.push(num.numberId);
                } else {
                    selectednumber.push(num.PhoneNumber);
                }
                //}
            });
            console.log(lstnumber);
        } else {
            if(lstnumber!=null){
                lstnumber.forEach(function(num) {
                selectednumber.push(num.PhoneNumber);
                
                //}
            });
            }
            
        }
        if (operation == "reserve" && isvalidforReserve == true) {
            console.log('selectedPC:::',selectedPC);
            if (selectedPC.length > 0 && selectednumber.length > 0)
                this.reserveSelected(
                    component,
                    event,
                    helper,
                    selectedPC,
                    selectednumber
                );
            else
                this.showCustomToast(
                    component,
                    "Please select at least one product configuration and one number for assignment.",
                    "Error",
                    "error"
                );
        }
        //EDGE-96503- Mahima
        else if (operation == "reserve" && isvalidforReserve == false) {
            this.showCustomToast(
                component,
                $A.get("{!$Label.c.NumberReservation_NumberAlreadyAssignedtoThisPC}"),
                "Error",
                "error"
            );
        } else {
            if (selectednumber.length == 0) {
                console.log("selectednumber error");
                this.showCustomToast(
                    component,
                    "Please select at least one number to remove.",
                    "Error",
                    "error"
                );
            } else {
                this.removeSelected(
                    component,
                    event,
                    helper,
                    selectedPC,
                    selectednumber
                );
                component.set("v.selectedRows", null);
                //EDGE-138688. Kalashree Borgaonkar. Fix for Assign Number error
                component.set("v.selectedRowsNumDetails", []);
                component.set("v.selectedRowsPCDetails",[]);   
            }
        }
    },
    
    //Method for callout to fetch Reservation Pool
    addToReservationPoolAction: function(component, event, helper) {
        var type = event.getParam("Type");
        var len = event.getParam("len");
        var quan = event.getParam("Quan");
        var selected = component.get("v.tabId");
        var Displaymsg = event.getParam("Displaymsg");
        var saveMsg = event.getParam("saveMsg");
        this.initPC(component, event, helper);
        this.fetchReservationPool(component, event, helper);
        
        //Defect EDGE-110273 fix
        if (selected == "Mobile") {
            if (type == "New" && quan == null) {
                this.showCustomToast(
                    component,
                    "Number reservation request is complete, " +
                    len +
                    " number(s) have been reserved. Please review the quantity reserved before proceeding with your order.",
                    "Success",
                    "success"
                );
            } else if (type == "PortIn") {
                this.showCustomToast(
                    component,
                    "Successfully added to reservation pool.",
                    "Success",
                    "success"
                );
            } else {
                this.showCustomToast(
                    component,
                    "Number reservation request is complete, " +
                    quan +
                    " number(s) have been reserved. Please review the quantity reserved before proceeding with your order.",
                    "Success",
                    "success"
                );
            }
        } else if (selected == "Fixed") {
            if (saveMsg != null) {
                this.showCustomToast(
                    component,
                    "Number reservation request is complete, " +
                    saveMsg +
                    " number(s) have been reserved. Please review the quantity reserved before proceeding with your order.",
                    "Success",
                    "success"
                );
            } else if (Displaymsg != null) {
                this.showCustomToast(component, Displaymsg, "Error", "error");
            }
        }
    },
    
    //Custom toast to display messages
    showCustomToast: function(cmp, message, title, type) {
        $A.createComponent(
            "c:customToast",
            {
                type: type,
                duration: 45000,
                message: message,
                title: title
            },
            function(customComp, status, error) {
                if (status === "SUCCESS") {
                    var body = cmp.find("container");
                    body.set("v.body", customComp);
                }
            }
        );
    },
    //EDGE-96503- Mahima
    finishReservationhelper: function(component, event, helper) {
        var validateWrapper;
        var returnBoolean;
        var recordId = component.get("v.basket_id");
        var action = component.get("c.finishReservation");
        action.setParams({ basketID: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("state", state);
            if (state === "SUCCESS") {
                validateWrapper = response.getReturnValue();
                console.log("validateWrapper", validateWrapper);
                returnBoolean = validateWrapper.IsValid;
                if (validateWrapper.IsValid == true) {
                    //alert(validateWrapper.IsValid);
                    
                    this.showCustomToast(
                        component,
                        validateWrapper.ErrorMessage,
                        "Success",
                        "success"
                    );
                    // this.showToast(component,"Success", validateWrapper.ErrorMessage );
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.parent.postMessage("close", "*");
                            sessionStorage.setItem("close", "close");
                        }),
                        3000
                    );
                } else {
                    //alert('Each Product Configuration must be assigned with a Number.');
                    this.showCustomToast(
                        component,
                        validateWrapper.ErrorMessage,
                        "Error",
                        "error"
                    );
                }
            }
        });
        $A.enqueueAction(action);
        console.log('validateWrapper.IsValid',returnBoolean);
        return returnBoolean;
    },
    //EDGE-96503- Mahima
    removeAssignedNumber: function(component, event, helper) {
        var recordId = component.get("v.basket_id");
        var lstpc = component.get("v.selectedRowsPCDetails");
        var selectedPC = [];
        lstpc.forEach(function(pc) {
            selectedPC.push(pc.configId);
        });
        var action = component.get("c.unAssignPCNumber");
        if (selectedPC.length == 0) {
            this.showCustomToast(
                component,
                "Please select atleast one product configuration ",
                "Error",
                "error"
            );
        } else {
            action.setParams({ selectedPC: selectedPC, basketID: recordId });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    //alert(response.getReturnValue());
                    this.initPC(component, event, helper);
                    this.fetchReservationPool(component, event, helper);
                    $A.get("e.force:refreshView").fire();
                }
            });
            $A.enqueueAction(action);
        }
    },
    //EDGE-97393,to disable Add to number reservation pool button
    getbasketStage: function(component, event) {
        var recordId = component.get("v.basket_id");
        var action = component.get("c.getBasketStage");
        action.setParams({ basketid: recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //EDGE:97393 if response is success then set available attribute value
            if (state === "SUCCESS") {
                var options = response.getReturnValue();
                //alert(options);
                if (options != "Contract Accepted") {
                    component.set("v.isEnriched", true);
                } else {
                    component.set("v.isEnriched", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /*---------------------------------------------------------------------------------
     Story:EDGE-97392
     Author:Aishwarya
     Method:updateColumnSorting
     Description:Method to get data to sort in given direction
     -----------------------------------------------------------------------*/
    
    sortData: function(component, fieldName, sortDirection) {
        var data = component.get("v.NumberObjList");
        var reverse = sortDirection !== "asc";
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.NumberObjList", data);
    },
    
    //EDGE-97392,Method to sort type field in given direction
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
    getBasketStatus: function(component, event) {
        var unassignCount = 0;
        var lstPC = component.get("v.pcWrapList");
        lstPC.forEach(function(pc) {
            if (pc.AssignedNumber == "<Unassigned>") {
                unassignCount++;
            }
        });
        //if()
        //{
        if (unassignCount > 0 && unassignCount <= lstPC.length) {
            component.set("v.remainingNumbers", unassignCount);
            component.set("v.totalNumbers", lstPC.length);
            var toggleCmp = component.find("warningDiv");
            $A.util.removeClass(toggleCmp, "slds-hide");
            var toggleCmp = component.find("successDiv");
            $A.util.addClass(toggleCmp, "slds-hide");
        } else {
            var toggleCmp = component.find("warningDiv");
            $A.util.addClass(toggleCmp, "slds-hide");
            var toggleCmp = component.find("successDiv");
            $A.util.removeClass(toggleCmp, "slds-hide");
        }
        //}
    },
    showToast: function(component, title, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            //mode: 'sticky',
            duration: 5000,
            title: title,
            message: msg
        });
        toastEvent.fire();
    },
    
    handleRemoveEvent: function(component, title, msg) {
        this.showCustomToast(
            component,
            "The selected number(s) have been removed from the pool.",
            "Success",
            "success"
        );
    },
    
    getCustomsettingValue: function(component, event) {
        var action = component.get("c.checkShowPortin");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            //EDGE:97393 if response is success then set available attribute value
            if (state === "SUCCESS") {
                var isPortinShow = response.getReturnValue();
                console.log(isPortinShow);
                component.set("v.IsShowPortin", isPortinShow);
            }
        });
        $A.enqueueAction(action);
    },
    caValidation: function(component, event, helper) {
        //EDGE-89299 added for CA Form validation
        var recordId = component.get("v.basket_id");
        var resp;
        //component.set("v.loadingSpinner", false);
        var action = component.get("c.isPortInValid");
        action.setParams({
            basketid: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                resp = response.getReturnValue();
                console.log('resp',resp);
                //component.set("v.isPortinValid", resp);
                
                /*if(resp==true){
                this.showToast(component, 'Customer Authority Form is going to expire in 10 days. Please click on the Customer Authorisation button to upload a new CA form.', "Warning", "Warning");

                }  */
            } else {
                // component.set("v.loadingSpinner", false);
            }
        });
        // enqueue the server side action
        $A.enqueueAction(action);
        console.log('resp',resp);
        return resp;
    },
   
    /*------------------------------------------------------
     * EDGE-128633
     * Method:fixedValidation
     * Description: Method to validate number reservation for NgUc
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
    fixedValidation: function(component, event, helper) {
        //EDGE-89299 added for CA Form validation
        var recordId = component.get("v.basket_id");
        var resp;
        var returnBoolean;
        //component.set("v.loadingSpinner", false);
        var action = component.get("c.ngucValidationOnEnrich");
        action.setParams({
            basketID: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                resp = response.getReturnValue();
                returnBoolean = resp.IsValid;   
            } else {
                 returnBoolean = false;
            }
            if(returnBoolean==false){
                this.showCustomToast(
                        component,
                        $A.get("{!$Label.c.FixedNumberValidation}"),
                        "Error",
                        "error"
                    );
            }
        });
        // enqueue the server side action
        $A.enqueueAction(action);
    },
     
    //EDGE-89299,AC6 finish button validation and EDGE-100662,AC1
    isFinished: function(component, event, helper) {
        //EDGE-126718 Kalashree Borgaonkar, Validation for nguc
       this.fixedValidation(component, event, helper);   
        if (component.get("v.tabId") == "Fixed") {
            //EDGE-92546 - Added to close the window on click of Finish 
            if (component.get("v.subTabId") == "manageTab") {
                window.setTimeout(
                    $A.getCallback(function() {
                        window.parent.postMessage("close", "*");
                        sessionStorage.setItem("close", "close");
                    }),
                    100
                );
            } else {
                 console.log('In else');
                    this.PopupValidation(component, event, helper); 
            }
        } else {
            var isvalid = this.caValidation(component, event, helper);
            console.log('isvalid',isvalid);
            var isFinish = this.finishReservationhelper(component, event, helper);
            console.log('isFinish',isFinish);
            //alert(isvalid);
            
            if (isvalid && !isFinish) {
                this.showToast(
                    component,
                    "Customer Authority Form is going to expire in 10 days. Please click on the Customer Authorisation button to upload a new CA form.",
                    "Warning",
                    "Warning"
                );
            } else if (!isvalid && isFinish) {
                this.showCustomToast(
                    component,
                    validateWrapper.ErrorMessage,
                    "Error",
                    "error"
                );
            } else if (!isvalid && !isFinish) {
                this.showCustomToast(
                    component,
                    validateWrapper.ErrorMessage,
                    "Success",
                    "success"
                );
            } else if (isvalid && isFinish) {
                this.showCustomToast(
                    component,
                    validateWrapper.ErrorMessage,
                    "Error",
                    "error"
                );
            }
        }
        
    },
    
    //EDGE-59982,To get the selected Tab
    handleChange: function(component, event, helper) {
        var selected = component.get("v.tabId");
        
        this.initPC(component, event, helper);
    },
    //EDGE-100662,AC2 OK button validation in Popup box
    okPopup: function(component, event, helper) {
       
        var action = component.get("c.OKunReserveFNN");
        action.setParams({
            basketId: component.get("v.basket_id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isPopup", false);
                this.fetchReservationPool(component, event, helper);
                    window.setTimeout(
                        $A.getCallback(function() {
                            window.parent.postMessage("close", "*");
                            sessionStorage.setItem("close", "close");
                        }),
                        1000
                    );
                }
        });
        $A.enqueueAction(action);
    },
    // EDGE-100662, Validation for Popup window
    PopupValidation: function(component, event, helper) {
        var action = component.get("c.isPopupValidation");
        action.setParams({
            basketId: component.get("v.basket_id")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state',state);
            if (state === "SUCCESS") {
                console.log('response.getReturnValue()>>>>'+response.getReturnValue());
                if(response.getReturnValue()){
                component.set("v.isPopup", response.getReturnValue());
                }
                //EDGE-132362 defect fix
                else{
                    window.setTimeout(
                    $A.getCallback(function() {
                        window.parent.postMessage("close", "*");
                        sessionStorage.setItem("close", "close");
                    }),
                    100
                );
                    
                }
            }
            
        });
        $A.enqueueAction(action);
    }
});
({
  /*------------------------------------------------------
     * EDGE-80749
     * Method:closeInfo
     * Description: Method to Initialise component with values
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  doInit: function(component, event) {
    this.checkCAF(component, event);
    this.createObjectData(component, event, false);
    this.caValidation(component, event);
  },
  /*------------------------------------------------------
     * EDGE-80749
     * Method:closeInfo
     * Description: Method to close information section
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  closeInfo: function(component, event) {
    var toggleCmp = component.find("info");
    $A.util.addClass(toggleCmp, "slds-hide");
        console.log("toggleCmp",toggleCmp);
  },

  /*------------------------------------------------------
     * EDGE-80749
     * Method:handleDisplay
     * Description: Method to display/hide on using radio button
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  handleDisplay: function(component, event) {
    var radioVal = event.target.value;
    component.set("v.radioValue", radioVal);
    if (radioVal == "Mobile") {
      var toggleMobile = component.find("MobilePanel");
      $A.util.removeClass(toggleMobile, "slds-hide");
      $A.util.addClass(toggleMobile, "slds-show");
      var toggleFixed = component.find("FixedPanel");
      $A.util.addClass(toggleFixed, "slds-hide");
    } else {
      var toggleMobile = component.find("MobilePanel");
      $A.util.addClass(toggleMobile, "slds-hide");
      var toggleFixed = component.find("FixedPanel");
      $A.util.removeClass(toggleFixed, "slds-hide");
      $A.util.addClass(toggleFixed, "slds-show");
    }
  },

  /*------------------------------------------------------
     * EDGE-89257,AC6, Edge-EDGE-80751
     * Method:createObjectData
     * Description: Method for creating row
     * Author: Kalashree Borgaonkar,Ila
     ------------------------------------------------------*/
  createObjectData: function(component, event, isAddRow) {
    // get the msisdnList from component and add(push) New Object to List
    var RowItemList = component.get("v.numberList");
    var displist = component.get("v.dispList");
    var action = component.get("c.getImportedData");
    var basketId = component.get("v.basketId");
        var currentpage = component.get("v.CurrentPage");
    action.setParams({
      basketid: basketId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        if (resp.length == 0 || resp.length == null) {
          RowItemList.push({
            sobjectType: "Object",
            num: "",
            accountNumber: "",
            carrier: "",
            isSelect: false,
            isDisabled: false,
            row: 0
          });
          // set the updated list to attribute (msisdnList) again
          component.set("v.dispList", RowItemList);
                    component.set("v.showtotalRecords",1);
        } else {
          for (var i = 0; i < resp.length; i++) {
            RowItemList.push({
              sobjectType: "Object",
              num: resp[i].num,
              accountNumber: resp[i].accountNumber,
              carrier: resp[i].carrier,
              isSelect: false,
              isDisabled: false,
              row: 0
            });
          }
          component.set("v.dispList", RowItemList);
          if (RowItemList != null) {
            component.set("v.totalRecords", RowItemList.length);
                        component.set("v.showtotalRecords",RowItemList.length);
          }
        }
        var appEvent = $A.get("e.c:paginationEvent");
        appEvent.setParams({
          PageData: component.get("v.dispList"),
          StartRecord: 1,
          EndRecord: 1,
          CurrentPage: component.get("v.CurrentPage"),
          TotalPages: Math.ceil(
            RowItemList.length / component.get("v.PageSize")
          ),
          PageSize: component.get("v.PageSize"),
          TotalRecords: component.get("v.dispList").length
        });
        appEvent.fire();
               
      }
    });
    // enqueue the server side action
    if (isAddRow == false) {
      $A.enqueueAction(action);
    } else {
      displist.push({
        sobjectType: "Object",
        num: "",
        accountNumber: "",
        carrier: "",
        isDisabled: false,
        isSelect: false,
        row: 0
      });
      var displist = component.get("v.dispList");
      component.set("v.dispList", displist);
      this.dispMethod(component);
            var numLength = RowItemList.length;
            if(numLength%10==0 && numLength!=0){
      var totalpages = component.get("v.TotalPages");
      totalpages = totalpages + 1;
      component.set("v.TotalPages", totalpages);
                var paginationCmp = component.find("pagination");
                paginationCmp.nextMethod();
            }
    }
  },
  /*------------------------------------------------------
     * EDGE-89257,AC6
     * Method:AddNewRow
     * Description: Method for adding row in event
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  addNewRow: function(component, event, helper) {
    // call the common "createObjectData" helper method for add new Object Row to List
    this.createObjectData(component, event, true);
    var RowItemList = component.get("v.numberList");
    component.set("v.columns", RowItemList.length);
  },

  /*------------------------------------------------------
     * EDGE-89257,AC6
     * Method:AddNewRow
     * Description: Method for adding row 
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  AddNewRow: function(component, event) {
    // fire the AddNewRowEvt Lightning Event
    component.getEvent("AddRowEvt").fire();
  },

  /*------------------------------------------------------
     * EDGE-89257,AC7
     * Method:deleteAllRows
     * Description: Method to delete rows
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  removeDeletedRow: function(component, event) {
    // get the selected row Index for delete, from Lightning Event Attribute
        var dispList = component.get("v.dispList");
    var index = event.getParam("indexVar");
        var currentpage = component.get("v.CurrentPage");
        var displistIndex = (currentpage - 1)*10 ;
    var AllRowsList = component.get("v.numberList");
        var showtotalRecords = component.get("v.showtotalRecords");
         var selectedRecords = component.get("v.selectedRecords");
    if (index != null) {

      AllRowsList.splice(index, 1);
            displistIndex = displistIndex + index;
            if(dispList[displistIndex].isSelect==true){
                selectedRecords = selectedRecords - 1;
                component.set("v.selectedRecords",selectedRecords);
            }
            dispList.splice(displistIndex,1);
      component.set("v.numberList", AllRowsList);
            component.set("v.dispList",dispList);
            showtotalRecords = showtotalRecords-1;
            component.set("v.showtotalRecords",showtotalRecords);
          
    } else {
			var ctr=0;
            for(var i=displistIndex;i<(AllRowsList.length+displistIndex);i++){
                if(dispList[i].isSelect==true){
                    ctr++;
                }
            }
            dispList.splice(displistIndex,AllRowsList.length);
            showtotalRecords = showtotalRecords - AllRowsList.length;
      AllRowsList.length = 0;
            component.set("v.dispList",dispList);
      component.set("v.numberList", AllRowsList);
            if(ctr>0){
                selectedRecords = selectedRecords - ctr;
                component.set("v.selectedRecords",selectedRecords);
            }
        }
        if(AllRowsList%10 == 0 && currentpage!=1){
            var totalpages = component.get("v.TotalPages");
            totalpages = totalpages - 1;
            component.set("v.TotalPages", totalpages);
            var paginationCmp = component.find("pagination");
            paginationCmp.previousMethod();  
    }
  },
  /*------------------------------------------------------
     * EDGE-89257,AC4
     * Method:deleteAllRows
     * Description: Method to save MSISDN port details in Service Qualification object 
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  Save: function(component, event) {
        var numlist = component.get("v.dispList");
    var i;
        var flag = false; 'error';
    //EDGE-80749, AC10, check all the numbers have been check for qualified or not.
    for (i = 0; i < numlist.length; i++) {
      //EDGE-129664 defect fix
            if (numlist[i].indicator != null ) {
                flag = 'success';
        break;
      }
            else {
                flag = 'errorIndicator';     
            }
        }
        for (i = 0; i < numlist.length; i++) {
            if((/\D/.test(numlist[i].accountNumber) || numlist[i].accountNumber==null || numlist[i].accountNumber=='') && numlist[i].indicator != null){
                flag = 'errorAccountNumber';
                break;
    }
        }
        if (flag == 'errorIndicator') {
      this.showCustomToast(
        component,
        $A.get("$Label.c.PortinSaveValidation"),
        "Error",
        "error"
      );
        } else if(flag == 'errorAccountNumber'){
            this.showCustomToast(
                component,
                $A.get("$Label.c.PortinSaveAccountValidation"),
                "Error",
                "error"
            );
    } else {
      var lst = JSON.stringify(numlist);
      component.set("v.loadingSpinner", true);
      var action = component.get("c.saveMsisdnSQresults");
      var basketId = component.get("v.basketId");
      action.setParams({
        msisdnList: lst,
        basketid: basketId
      });
      // set call back
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          var resp = response.getReturnValue();
          if (resp == "Record saved") {
            component.set("v.loadingSpinner", false);
            //EDGE-80749, AC10
                        var childComponent = component.find("cafComp");//EDGE-144140. Kalashree - Refresh child comp
                        var message = childComponent.handleRefresh();
                        console.log('fired cafevent');
                        numlist.length=0;
                        component.set("v.dispList",numlist);
                        component.set("v.numberList",numlist);
                        this.doInit(component,event);
            this.showCustomToast(
              component,
              $A.get("$Label.c.PortinDetailsSaved"),
              "Success",
              "success"
            );
          } else {
            component.set("v.loadingSpinner", false);
            //EDGE-80749, AC10
            this.showCustomToast(
              component,
              $A.get("$Label.c.PortinSaveError"),
              "Error",
              "error"
            );
          }
        } else {
          component.set("v.loadingSpinner", false);
          //EDGE-80749, AC10
          this.showCustomToast(
            component,
            $A.get("$Label.c.PortinSaveError"),
            "Error",
            "error"
          );
        }
                
                 component.set("v.isNumberSelected",true);
                component.set("v.selectedRecords",0);
                component.set("v.isSelectAll",false);
      });
      // enqueue the server side action
      $A.enqueueAction(action);
    }
  },
  /*------------------------------------------------------
     * EDGE-89257
     * Method:deleteAllRows
     * Description:Method to delete rows
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  //Method for deleting row
  deleteAllRows: function(component, event) {
    // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
    component.getEvent("DeleteRowEvt").fire();
  },
  //to show error/success message
  showToast: function(component, event, title, msg, toastType) {
    var toastEvent = $A.get("e.force:showToast");

    toastEvent.setParams({
      title: title,
      message: msg,
      type: toastType
    });

    toastEvent.fire();
  },
  /*------------------------------------------------------
     * EDGE-89257
     * Method:showCustomToast
     * Description:Method to show toast
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
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
          var body = cmp.find("parentcontainer");
          body.set("v.body", customComp);
        }
      }
    );
  },
  showToast: function(cmp, message, title, type) {
    $A.createComponent(
      "c:customToast",
      {
        type: type,
        message: message,
        title: title,
        isOKActive: "false"
      },
      function(customComp, status, error) {
        if (status === "SUCCESS") {
          var body = cmp.find("parentcontainer");
          body.set("v.body", customComp);
        }
      }
    );
  },
  /*------------------------------------------------------
     * EDGE-89257,AC3
     * Method:getPortSelectionList
     * Description:Method to get qualified MSISDN
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  getPortSelectionList: function(component, event) {
    var basketId = component.get("v.basketId");
    var action = component.get("c.getQualifiedMsisdn");
    action.setParams({
      basketid: basketId
    });
    // set call back
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        var qualifiedNumList = response.getReturnValue();
        if (qualifiedNumList == null || qualifiedNumList.length == 0) {
          component.set("v.areNumQualified", false);
        } else {
          component.set("v.areNumQualified", true);
          component.set("v.portSelectionList", qualifiedNumList);
        }
      } else {
      }
    });
    // enqueue the server side action
    $A.enqueueAction(action);
  },

  /*------------------------------------------------------
     * EDGE-90327
     * Method:checkCAF
     * Description:Method to get active CAF details
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  checkCAF: function(component, event) {
    //checkActiveCAF
    var basketId = component.get("v.basketId");
    component.set("v.loadingSpinner", false);
    var action = component.get("c.checkActiveCAF");
    action.setParams({
      basketid: basketId
    });
    // set call back
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        if (resp != null) {
          component.set("v.isCafActive", resp.isActive);
          component.set("v.isPpvActive", resp.isVerified);
                    //DIGI-778:Call Child aura method to disable send SMS button
        			var cafComp = component.find("cafComp");
        			var message = cafComp.handleSendSMSEvent(resp.isActive);
                    if (resp.isActive == false) {
                        component.set("v.variantCustAuth", "neutral");
                        component.set("v.variantPPV", "brand");
                    }
                }
            } else {
                component.set("v.loadingSpinner", false);
            }
        });
        // enqueue the server side action
        $A.enqueueAction(action);
    },
    
    /*------------------------------------------------------
     * EDGE-89299
     * Method:NavigateComponent
     * Description:NavigateToCAF event action
     ------------------------------------------------------*/
  NavigateComponent: function(component, event, helper) {
    if (event.getParam("navigate") == "true") {
      if (event.getParam("isPPV") == "true") {
        var toggleCmp = component.find("ppvComp");
        $A.util.removeClass(toggleCmp, "slds-hide");
        $A.util.addClass(toggleCmp, "slds-show");
        var toggleCmp = component.find("portInContainer");
        $A.util.addClass(toggleCmp, "slds-hide");
        var toggleCmp = component.find("custAuth1");
        $A.util.addClass(toggleCmp, "slds-hide");
      } else {
        var toggleCmp = component.find("custAuth1");
        $A.util.removeClass(toggleCmp, "slds-hide");
        $A.util.addClass(toggleCmp, "slds-show");
        var toggleCmp = component.find("portInContainer");
        $A.util.addClass(toggleCmp, "slds-hide");
        var toggleCmp = component.find("ppvComp");
        $A.util.addClass(toggleCmp, "slds-hide");
      }
    }
  },
  /*------------------------------------------------------
     * EDGE-90327
     * Method:handleSampleEvent
     * Description:Handle event after PPV is sent.
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  // call by child component by a Lightning event handler
  handleSampleEvent: function(component, event) {
    //alert('in parent');
    this.getDetailPpv(component, event);
    this.checkCAF(component, event);
    var event = $A.get("e.c:PpvUpdateEvent");
    var parm = event.fire();
    var cmpTarget = component.find("portInContainer");
    $A.util.removeClass(cmpTarget, "slds-hide");
    $A.util.addClass(cmpTarget, "slds-show");
  },
  /*------------------------------------------------------
     * EDGE-89299
     * Method:buttonFunction
     * Description:Opens the Customer Authorisation Lightning component
     ------------------------------------------------------*/
  buttonFunction: function(component, event) {
    var basketId = component.get("v.basketId");
    //basketId = "a3Q2O0000008VZj";

    var event = $A.get("e.c:NavigateToCAF");
    event.setParams({
      navigate: "true",
      basketID: basketId
    });
    var parm = event.fire(event.getParam("basketId"));
  },
  /*------------------------------------------------------
     * EDGE-90327
     * Method:buttonFunctionPpv
     * Description:Opens the Customer Authorisation Lightning component
     ------------------------------------------------------*/
  buttonFunctionPpv: function(component, event) {
    var basketId = component.get("v.basketId");
    //basketId = "a3Q2O0000008VZj";
    var defCon = component.get("v.defaultContact");
    var event = $A.get("e.c:NavigateToCAF");
    //EDGE-117585 Kalashree Borgaonkar. Contact to be sent to PPV Comp-->
    event.setParams({
      navigate: "true",
      basketID: basketId,
      isPPV: "true",
      defaultContact: defCon
    });
    var parm = event.fire(event.getParam("basketId"));
  },
  /*------------------------------------------------------
     * EDGE-90327
     * Method:getDetailPpv
     * Description:get PPV details.
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  getDetailPpv: function(component, event) {
    var basketId = component.get("v.basketId");
    //component.set("v.loadingSpinner", false);
    var action = component.get("c.getPpvDetails");
    action.setParams({
      basketid: basketId
    });
    // set call back
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        if (resp != null) {
          component.set("v.ppvDetail", resp);
          //EDGE-117585. Populate default contact
          component.set("v.defaultContact", resp.approver);
          //component.set("v.loadingSpinner", false);
        }
      } else {
        // component.set("v.loadingSpinner", false);
      }
    });
    // enqueue the server side action
    $A.enqueueAction(action);
  },
  caValidation: function(component, event, helper) {
    //EDGE-89299 added for CA Form validation
    var basketId = component.get("v.basketId");
    //component.set("v.loadingSpinner", false);
    var action = component.get("c.isPortInValid");
    action.setParams({
      basketid: basketId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var resp = response.getReturnValue();
        component.set("v.isPortinValid", resp);
        // alert(resp);
        if (resp == true) {
          this.showToast(
            component,
            "Customer Authority Form is about to expire soon. Please generate a new CA form for customer sign off before submitting the order.",
            "Warning",
            "Warning"
          );
        }
      } else {
        // component.set("v.loadingSpinner", false);
      }
    });
    // enqueue the server side action
    $A.enqueueAction(action);
  },
  handlePPVEvent: function(component, event) {},
  handleSelectAllNumbers: function(component, event) {
    var index = event.getParam("isSelectAll");
    var numList = component.get("v.numberList");
    numList.forEach(function(record) {
      record.isSelect = index;
    });
    component.set("v.numberList", numList);
  },

  
  /*---------------------------------------------------------------------------------------
    Name : changeData
    Description : Method to set pagination parameters
    Story: EDGE-107149
     -----------------------------------------------------------------------------------*/
  changeData: function(component, event) {
    component.set("v.CurrentPage", event.getParam("CurrentPage"));
    component.set("v.PageSize", event.getParam("PageSize"));
    component.set("v.TotalPages", event.getParam("TotalPages"));
        console.log()
    this.dispMethod(component);
  },
  /*---------------------------------------------------------------------------------------
    Name : dispMethod
    Description : Method to display data on page
    Story: EDGE-107149
     -----------------------------------------------------------------------------------*/
  dispMethod: function(component, event) {
    var tempList = [];
    var pNo = component.get("v.CurrentPage");
    var size = component.get("v.PageSize");
    tempList = component.get("v.dispList");
    component.set(
      "v.numberList",
      tempList.slice((pNo - 1) * size, Math.min(pNo * size, tempList.length))
    );
    //EDGE-129897. Kalashree Borgaonkar. Fix to disable checkbox- start
    var numlist = component.get("v.numberList");
    var flag = false;
    for (var record of numlist) {
      if (record.isSelect == false) {
        flag = true;
        break;
      }
    }
    if (flag == true) {
      component.set("v.isSelectAll", false);
        } else if(numlist.length>0){
      component.set("v.isSelectAll", true);
    }
    //EDGE-129897. Kalashree Borgaonkar. Fix to disable checkbox- end
  },
  /*---------------------------------------------------------------------------------------
    Name : qualifyCallout
    Description : Method to Invoke Qualify callout for multiple numbers
    Story: EDGE-107149
     -----------------------------------------------------------------------------------*/
  qualifyCallout: function(component, event) {
    var numlist = component.get("v.numberList");
    var displist = component.get("v.dispList");

    var basketId = component.get("v.basketId");
    var msisdn;
    var flag = false;
    component.set("v.numTempList", displist);
    var numTempList = component.get("v.numTempList");
        var count=0;
        for(var i=0; i<displist.length;i++){
            if(displist[i].isSelect==true){
                count++;
            }
        }
        if (count > 30) {
      this.showCustomToast(
        component,
        $A.get("$Label.c.QualifyMsisdnMessage"),
        "error",
        "error"
      );
            return;
        }// else {
      for (var i = 0; i < numlist.length; i++) {
        if (
          (numlist[i].num == null ||
            numlist[i].num == "" ||
            numlist[i].num.length < 8 ||
            /\D/.test(numlist[i].num)) &&
          numlist[i].isSelect == true
        ) {
          flag = true;
          break;
        } else {
          flag = false;
        }
      }
        
      if (flag == true) {
        this.showCustomToast(
          component,
          $A.get("$Label.c.PortInValidationMessage"),
          "error",
          "error"
        );
      } else {
        component.set("v.loadingSpinner", true);
        var lst = JSON.stringify(displist);
        var action = component.get("c.getMultipleQualifyResponse");
        action.setParams({
          msisdnList: lst,
          basketid: basketId
        });
        action.setCallback(this, function(response) {
          var state = response.getState();
          if (state === "SUCCESS") {
            var resp = response.getReturnValue();
                    console.log('resp: ',resp);
                    //EDGE-151027 check for error message
                    if (resp !=null && resp[0].message != null) {
              //var errors = response.getError();
              component.set("v.loadingSpinner", false);
                        this.showCustomToast(component, resp[0].message, "Error", "Error");
                        component.set("v.selectedRecords",0);
            }
                    else{
            component.set("v.loadingSpinner", false);
                        component.set("v.dispList.message", resp.message);
                        component.set("v.dispList", resp);
            this.dispMethod(component);

        }
                    component.set("v.isNumberSelected",true);
                    component.set("v.selectedRecords",0);
                    component.set("v.isSelectAll",false);
                    component.set("v.loadingSpinner", false); 
          }
        });
            $A.enqueueAction(action);
      }
        //}
    },
       
    handleCheckboxEvent: function(component, event) {
    //helper.handleCheckboxEvent(component, event);
        
      var sel = component.get("v.isNumberSelected");
	var test = event.getParam("isSelectAll");
	 var dispList = component.get("v.dispList");
    var numlist = component.get("v.numberList");
       var test2 = event.getParam("rowIndex");
    var selectedNum = 0;
    var unselectedNum = 0;
        
        if (test) {
      component.set("v.isNumberSelected", !test);
            var updatecount = component.get("v.selectedRecords")+1;
            component.set("v.selectedRecords",updatecount);
            //component.set("v.row",updatecount);
            //component.set("v.numberList",numlist);
    }
	else{
            var updatecount = component.get("v.selectedRecords")-1;
            component.set("v.selectedRecords",updatecount); 
            //component.set("v.row",updatecount);
            //component.set("v.numberList",numlist);
          }
        var flag = 0;
        for(var i=0;i<dispList.length; i++){
            if (dispList[i].isSelect == true) {
                flag++;
                break;
	}
        }
        if (flag == 0) {
        component.set("v.isNumberSelected", true);
      }
    component.set("v.dispList", dispList);
    //component.set("v.numberList", numlist);
    var disp = component.get("v.dispList");
    this.dispMethod(component);
},
    handleSelectAllNumbers1: function(component, event) {
    var numlist = component.get("v.numberList");
    var checkvalue = component.find("selectAll").get("v.value");
        var dispList = component.get("v.dispList");
        var ctr=0;
        numlist.forEach(function(record) {
            if(record.isSelect == true){
                record.row=1;
                ctr++; 
            } 
            else{
                record.row=0;
            }
        });
        component.set("v.numlist",numlist);
    if (checkvalue == true) {
      component.set("v.isNumberSelected", false);
      component
        .getEvent("SelectRows")
        .setParams({ isSelectAll: true })
        .fire();
      //EDGE-129897. Kalashree Borgaonkar. Fix to show error message- start
      var selectedNum = 0;
      for (var record of dispList) {
        if (record.isSelect == true) {
          selectedNum = selectedNum + 1;
        }
      }
            component.set("v.selectedRecords",selectedNum) ;
         
      //EDGE-129897. Kalashree Borgaonkar. Fix to show error message- end
    } else {
            var selectedNum = component.get("v.selectedRecords") ;
            var cntr=0;
            for (var record of dispList) {
                if (record.isSelect == false) {
                    cntr++;
                }
            }
            selectedNum = dispList.length - numlist.length-cntr;
            component.set("v.selectedRecords",selectedNum) ;
      component
        .getEvent("SelectRows")
        .setParams({ isSelectAll: false })
        .fire();
            //EDGE-151027 Kalashree. Fix forQulify button enablement
            if(selectedNum>0){
                component.set("v.isNumberSelected", false); 
            } 
            else{
      component.set("v.isNumberSelected", true);
            }
            var selectedRec = component.get("v.selectedRecords");   
    }
  },
     closeModal : function(component, event, helper){
    	component.set("v.isShowMobileport",false);
    },
    /*-------------------------------------------------------- 
EDGE		-144140
Method		-sortData
Description	-sort by Port in ready
Author		-Kalashree
--------------------------------------------------------*/
    sortData : function(component,fieldName,sortDirection){
        
        var data = component.get("v.numberList");
        console.log('data dispList before',data);
        //function to return the value stored in the field
        var key = function(a) { console.log('a[fieldName]',a[fieldName]); return a[fieldName]; }
        var reverse = sortDirection == 'asc' ? 1: -1;
        
        // to handel number/currency type fields 
        if(fieldName == 'NumberOfEmployees'){ 
            data.sort(function(a,b){
                console.log('m here');
                var a = key(a) ? key(a) : '';
                var b = key(b) ? key(b) : '';
                return reverse * ((a>b) - (b>a));
            }); 
        }
        else{// to handel text type fields 
            data.sort(function(a,b){ 
                console.log('m there');
                var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                var b = key(b) ? key(b).toLowerCase() : '';
                return reverse * ((a>b) - (b>a));
            });    
        }
        //set sorted data to accountData attribute
        console.log('data dispList after',data);
        component.set("v.numberList",data);
        
    },
    //DIGI-2144
    handleBulkUploadChange:function(component, event,helper) {
      console.log('handleBulkUploadChange');
      let spinner = event.getParam('spinner');
      component.set("v.loadingSpinner", spinner); 
      if(!spinner)
      {
          //component.set("v.numberList", event.getParam('data'));
          if(event.getParam('data')){
              var RowItemList=[];
              var resp=  event.getParam('data');
              for (var i = 0; i < resp.length; i++) {
                  RowItemList.push({
                      sobjectType: "Object",
                      num: resp[i].num,
                      accountNumber: resp[i].accountNumber,
                      carrier: resp[i].carrier,
                      isSelect: false,
                      isDisabled: false,
                      row: 0
                  });
              }
              console.log('RowItemList data:',RowItemList);
              component.set("v.dispList", RowItemList);
              if (RowItemList != null) {
                  component.set("v.totalRecords", RowItemList.length);
                  component.set("v.showtotalRecords",RowItemList.length);
              }
              var appEvent = $A.get("e.c:paginationEvent");
              appEvent.setParams({
                  PageData: component.get("v.dispList"),
                  StartRecord: 1,
                  EndRecord: 1,
                  CurrentPage: component.get("v.CurrentPage"),
                  TotalPages: Math.ceil(
                      RowItemList.length / component.get("v.PageSize")
                  ),
                  PageSize: component.get("v.PageSize"),
                  TotalRecords: component.get("v.dispList").length
              });
              appEvent.fire();
          }
          this.showToast(
              component,
              event.getParam('message'),
              event.getParam('type'),
              event.getParam('type')
          );
      }
      
  }
});
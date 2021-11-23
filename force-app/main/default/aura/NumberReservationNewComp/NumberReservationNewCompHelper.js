/****************************************
EDGE -93081
Name: NumberReservationNewComp
Description: Display New number resvation UI for Product Basket 
Author:Ila/Mahima 
************************************************/

({
  //Search numbers for LRM
  searchNumbers: function(component, event) {
    var totalReserved = 0;
    //var pat = new RegExp('(^[0-9]+[0-9]+[%])|(^[0-9]+[0-9]+[*]|^[0-9]+[0-9])');
    var regex = /^\d[0-9]+[%*]?$/;
    var pat = new RegExp(regex);
    var reqQuan = component.get("v.reqQuantity");
    var reqNumPattern = component.get("v.reqPattern");
    var reqSearchType = component.find("selectSearchType").get("v.value");
    if (reqQuan == null || reqQuan == "") {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_quantity_required"),
        "error",
        "error"
      );
    } else if (reqQuan <= 0 || reqQuan > 50 || reqQuan == 0) {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_quantity_validation"),
        "error",
        "error"
      );
    } else if (
      reqSearchType != "RANDOM" &&
      reqNumPattern != null &&
      !pat.test(reqNumPattern)
    ) {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_pattern_validation"),
        "error",
        "error"
      );
    } else {
      component.set("v.loadingSpinner", true);
      var action = component.get("c.searchMSISDN");
      var searchObj = {
        reqQuantity: reqQuan,
        reqSearch: reqSearchType,
        reqPattern: reqNumPattern
      };
      action.setParams({ searchObj: searchObj });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          component.set("v.loadingSpinner", false);
          var numList = response.getReturnValue();
          if (numList.length != 0) {
            component.set("v.numList", numList);
          } else {
            this.showCustomToast(
              component,
              $A.get("$Label.c.Reserve_numbers_not_found"),
              "error",
              "error"
            );
          }
        }
      });
      $A.enqueueAction(action);
    }
  },
  //Toast to display Error
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
          var body = cmp.find("container");

          body.set("v.body", customComp);
        }
      }
    );
  },

  //Reserve LRM numbers and on success Save to Number
  reserveNumbers: function(component, event) {
    //var respNumList = component.get("v.numList");
    //
    var tabselected = component.get("v.selectedTabId");
    var respNumList = component.get("v.SelectedNumNew");
    var lst = JSON.stringify(respNumList);
    var len = respNumList.length;
    var flag = false;
    /* for(var i=0;i<respNumList.length;i++){
            if(respNumList[i].isSelectedNew==true){
                flag=true;
                break;
            }  
        }*/
    if (respNumList.length > 0) {
      flag = true;
    }

    if (flag == true) {
      var recordId = component.get("v.basket_id");
      //action.setParams({"basketId": component.get("v.recordId")});
      component.set("v.loadingSpinner", true);
      var action = component.get("c.reserveMSISDN");
      action.setParams({
        fnnListToReserve: lst,
        basketId: recordId
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          // component.set("v.loadingSpinner", false);
          var resp = response.getReturnValue();
          debugger;
          if (resp == "SaveError") {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
              component,
              "Error in adding to Reservation Pool.Please try again.",
              "Error",
              "error"
            );
          } else {
            //component.set("v.loadingSpinner", false);
            //component.set("v.numList",null);
            //var appEvent = $A.get("e.c:addtoReservationPool");
            //appEvent.setParams({"Type" : 'New' });
            //appEvent.fire();

            //Polling logic start
            let intervalId = "";
            var action1 = component.get("c.getJobStatus");
            action1.setParams({ jobId: resp });
            action1.setCallback(this, function(response) {
              //console.log('in callback',response);
              //debugger;
              var state = response.getState();

              //alert(state);
              if (state === "SUCCESS") {
                var resp1 = response.getReturnValue();
                if (resp1 == true) {
                  component.set("v.loadingSpinner", false);
                  component.set("v.numList", null);
                  component.set("v.reqQuantity", "");
                  component.set("v.reqPattern", "");
                  var appEvent = $A.get("e.c:addtoReservationPool");
                  appEvent.setParams({ Type: "New" });
                  appEvent.setParams({ len: len });
                  appEvent.fire();
                  //alert(intervalId);
                  window.clearInterval(intervalId);
                }
              } else {
                //console.log('error');
              }
            });
            intervalId = window.setInterval(
              $A.getCallback(function() {
                $A.enqueueAction(action1);
              }),
              10000
            );
            //alert(intervalId);
            //polling logic end
          }
        } else {
          component.set("v.loadingSpinner", false);
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.loadingSpinner", false);
      this.showCustomToast(
        component,
        "Please select at least one number to add.",
        "Error",
        "error"
      );
    }
  },
  //Auto Reserve Numbers for LRM
  autoReserve: function(component, event, helper) {
    var reqQuan = component.get("v.reqQuantity");
    var recordId = component.get("v.basket_id");
    //action.setParams({"basketId": component.get("v.recordId")});
    if (reqQuan == null || reqQuan == "") {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_quantity_required"),
        "error",
        "error"
      );
    } else if (reqQuan <= 0 || reqQuan > 50 || reqQuan == 0) {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_quantity_validation"),
        "error",
        "error"
      );
    } else {
      component.set("v.loadingSpinner", true);
      var action = component.get("c.autoReserveMSISDN");
      action.setParams({
        searchQuan: reqQuan,
        basketId: recordId
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          //component.set("v.loadingSpinner", false);
          var resp = response.getReturnValue();
          if (resp == "SaveError") {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
              component,
              "Error in adding to Reservation Pool.Please try again.",
              "Error",
              "error"
            );
          } else {
            /*component.set("v.loadingSpinner", false);
                        var appEvent = $A.get("e.c:addtoReservationPool");
            			appEvent.setParams({"Type" : 'New' });            
            			appEvent.fire();*/

            //Polling logic start
            let intervalId = "";
            var action1 = component.get("c.getJobStatus");
            action1.setParams({ jobId: resp });
            action1.setCallback(this, function(response) {
              //console.log('in callback',response);
              debugger;
              var state = response.getState();

              //alert(state);
              if (state === "SUCCESS") {
                var resp1 = response.getReturnValue();
                if (resp1 == true) {
                  component.set("v.loadingSpinner", false);
                  component.set("v.numList", null);
                  component.set("v.reqQuantity", "");
                  component.set("v.reqPattern", "");
                  var appEvent = $A.get("e.c:addtoReservationPool");
                  appEvent.setParams({ Type: "New" });
                  appEvent.setParams({ Quan: reqQuan });
                  appEvent.fire();
                  //alert(intervalId);
                  window.clearInterval(intervalId);
                }
              } else {
                //console.log('error');
              }
            });
            intervalId = window.setInterval(
              $A.getCallback(function() {
                $A.enqueueAction(action1);
              }),
              10000
            );
            //alert(intervalId);
            //polling logic end
          }
        } else {
          component.set("v.loadingSpinner", false);
        }
      });
      $A.enqueueAction(action);
    }
  },
  clearForm: function(component, event, helper) {
    component.set("v.reqQuantity", "");
    component.set("v.reqPattern", "");
    component.find("selectPatternType").set("v.value", "None");
    component.find("AreaCode").set("v.value", "");
    component.find("SearchType").set("v.value", "Non-Contiguous");
  },

  //EDGE-59982 Search numbers for NGUC
  searchNumbersFNN: function(component, event) {
    var totalReserved = 0;
    //var pat = new RegExp('(^[0-9]+[0-9]+[%])|(^[0-9]+[0-9]+[*]|^[0-9]+[0-9])');
    var regex = /^\d[0-9]+[%*]?$/;
    var pat = new RegExp(regex);
    var reqQuan = component.get("v.reqQuantity");
    var reqNumPattern = component.get("v.reqPattern");
    var reqSearchType = component.find("SearchType").get("v.value");
    var flag = false;
    //EDGE-100659
    // console.log('reqNumPattern'+reqNumPattern);
    var reqPatternType = component.find("selectPatternType").get("v.value");
    //EDGE-100661- Geo Params Section- starts
    var areaCode = component.find("AreaCode").get("v.value");
    let isSameExchange = component.find("sameExchange").get("v.checked");
    let address = component.get("v.deliveryAddress");
    let isArea = component.get("v.enableAreaCode");
    let addressId = "";
    let ESAValue = "";
    if (isArea == false) {
      if (address != null && address != "") {
        addressId = address.Address_ID__c;
        if (isSameExchange) {
          ESAValue = address.ESA_Code__c;
        }
      }
    }
    //EDGE-100661-END
    //kala
     console.log('reqSearchType',reqSearchType+ '  '+reqNumPattern);
     if (reqSearchType == "Contiguous" && reqNumPattern > 999999) {
        console.log('reqSearchType in if',reqSearchType+ '  '+reqNumPattern);
      this.showCustomToast(
        component,
        $A.get("$Label.c.ContiguousValidationMessage"),
        "error",
        "error"
      );
    } 
    if (reqQuan == null || reqQuan == "") {
      this.showCustomToast(
        component,
        $A.get("$Label.c.Reserve_number_quantity_required"),
        "error",
        "error"
      );
    } else if (reqQuan <= 0) {
      this.showCustomToast(
        component,
        "Plese Enter valid Quantity",
        "error",
        "error"
      );
    } else if(reqSearchType=='Contiguous' && (reqQuan % 100) != 0){
          this.showCustomToast(component, "Contiguous Search the quantity should be multiple of hundred", "error", "error");  
        } else if (reqQuan > 10000) {
      this.showCustomToast(
        component,
        "Maximum quantity supported is 10,000",
        "error",
        "error"
      );
    } else if (reqPatternType == "None" && reqNumPattern < 9999999) {

     
      component.set("v.reqPattern", "");
      flag = true;
    }
    else if (
      reqPatternType != "None" &&
      (reqNumPattern == null || reqNumPattern == "")
    ) {
      this.showCustomToast(
        component,
        "Pattern to be mentioned on Pattern Field",
        "error",
        "error"
      );
    } else if (
      reqPatternType != "None" &&
      (reqNumPattern != null || reqNumPattern != "") &&
      reqNumPattern < 9999999
    ) {
      flag = true;
    }

    //EDGE-100659 Ends
    if (flag == true) {
      console.log("In true");
      component.set("v.loadingSpinner", true);
      var action = component.get("c.searchFNN");
      console.log("searchFNN");
        
      var searchObj = {
        reqQuantity: reqQuan,
        reqSearch: reqSearchType,
        pattern: reqNumPattern,
        patternType: reqPatternType,
        areaCode: areaCode,
        addressId: addressId,
        esaValue: ESAValue
      };
      console.log(JSON.stringify(searchObj));
      action.setParams({ searchObj: searchObj });
      action.setCallback(this, function(response) {
        var state = response.getState();
        console.log("state" + state);
        if (state === "SUCCESS") {
          component.set("v.loadingSpinner", false);
          var numList = response.getReturnValue();

          if (
            numList.length != 0 &&
            numList[0].message != "" &&
            reqSearchType == "Contiguous"
          ) {
            //alert('In here')
            this.showCustomToast(
              component,
              numList[0].message,
              "warning",
              "warning"
            );

            this.startTimer(component);
            component.set("v.fixednumList", numList); //EDGE-117819 Defect Fix
          } else if (
            numList.length != 0 &&
            numList[0].message == "" &&
            reqSearchType == "Contiguous"
          ) {
            this.startTimer(component);
            component.set("v.fixednumList", numList); //EDGE-117819 Defect Fix
          } else if (numList.length != 0 && reqSearchType == "Non-Contiguous") {
            this.startTimer(component);
            component.set("v.fixednumList", numList);
          } else {
            this.showCustomToast(
              component,
              $A.get("$Label.c.Reserve_numbers_not_found"),
              "error",
              "error"
            );
          }
        } else {
          console.log("response" + JSON.stringify(response));
          component.set("v.loadingSpinner", false);
        }
      });
      $A.enqueueAction(action);
    }
  },
  // EDGE-59982 Reserve FNN numbers and on success Save to Number
  reserveFNNNumbers: function(component, event) {
    component.set("v.isReserve", "Held Order");
    var tabselected = component.get("v.selectedTabId");
    var respNumList = component.get("v.SelectedNumNew");
    var lst = JSON.stringify(respNumList);
    var len = respNumList.length;
    var flag = false;

    if (respNumList.length > 0) {
      flag = true;
    }

    if (flag == true) {
      var recordId = component.get("v.basket_id");
      //action.setParams({"basketId": component.get("v.recordId")});
      component.set("v.loadingSpinner", true);
      var action = component.get("c.reserveFNN");
      action.setParams({
        fnnListToReserve: lst,
        basketId: recordId,
        resourceState: component.get("v.isReserve")
      });
      action.setCallback(this, function(response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          // component.set("v.loadingSpinner", false);
          var resp = response.getReturnValue();
          if (resp == "Error") {
            component.set("v.loadingSpinner", false);
            this.showCustomToast(
              component,
              "Error in adding to Reservation Pool.Please try again.",
              "Error",
              "error"
            );
          } else if (resp.successMsg != null) {
            component.set("v.loadingSpinner", false);
            var saveMsg = resp.successMsg;
            component.set("v.fixednumList", null);
            var appEvent = $A.get("e.c:addtoReservationPool");
            appEvent.setParams({ Type: "FNN" });
            appEvent.setParams({ saveMsg: saveMsg });
            appEvent.fire();
          } else if (resp.errList != null) {
            var err = "";
            var message = "";
            var i;
            var len = resp.errList.length;
            for (i = 0; i < len; i++) {
              message =
                resp.errList[i].resourceId +
                " " +
                resp.errList[i].message +
                "\n";
              err = err + message + "\n";
            }
            component.set("v.loadingSpinner", false);
            component.set("v.fixednumList", null); //EDGE-117819 Defect Fix
            component.set("v.reqQuantity", "");
            // console.log('error=='+err);
            //    alert(errorMessage);
            var appEvent = $A.get("e.c:addtoReservationPool");
            appEvent.setParams({ Type: "FNN" });
            appEvent.setParams({ Displaymsg: err });
            appEvent.fire();
          }
        } else {
          component.set("v.loadingSpinner", false);
        }
      });
      $A.enqueueAction(action);
    } else {
      component.set("v.loadingSpinner", false);
      this.showCustomToast(
        component,
        "Please select at least one number to add.",
        "Error",
        "error"
      );
    }
  },
  handleEvent: function(component, event, helper) {
    var name = event.getParam("OperationName"); // getting the value of event attribute
    component.set("v.OperationName", name);
  },
  //EDGE-100659, Timer to hide numbers after 5 mins
  startTimer: function(component) {
    var tabselected = component.get("v.selectedTabId");
    var minutes = 0;
    var duration = 60 * 5;
    var seconds = 0;
    var timer = duration,
      minutes,
      seconds;
    setInterval(function() {
      minutes = parseInt(timer / 60, 10);
      seconds = parseInt(timer % 60, 10);

      minutes = minutes < 10 ? "0" + minutes : minutes;
      seconds = seconds < 10 ? "0" + seconds : seconds;
      var timeLeft = minutes + ":" + seconds;

      var toggleCmp = component.find("timerBlock");
      $A.util.addClass(toggleCmp, "slds-show");
      if (--timer < 0) {
        for (var i = 0; i < 10000; i++) {
          window.clearInterval(i);
        }
        // switchOffTimer();
      }
      var notify = "Please select within " + timeLeft + " minutes!";
      window.clearInterval(timer);
      //component.set("v.timeLeft", timeLeft);
      component.set("v.timeLeft", timeLeft);
      component.set("v.timerPretext", "Please select within ");
      component.set("v.timerPosttext", " minutes!");
      if (timer <= 0 && tabselected == "Fixed") {
        //EDGE-124987 defect fix
        var toggleCmp = component.find("SearchResult");
        $A.util.addClass(toggleCmp, "slds-hide");
      }
    }, 1000);
  },
  /*------------------------------------------------------
     * EDGE-126317
     * Method:renderPatternTypeOptions
     * Description: Method to validate number reservation for NgUc
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/
  renderPatternTypeOptions: function(component, event) {
    //var searchType=component.find("SearchType");
    component.set("v.loadingSpinner", true);
    var searchType = component.get("v.selectedSearchType");
    console.log("searchType", searchType);
    //var searchType='Non-Contiguous';
    //console.log('searchType',searchType);
    var action = component.get("c.getPatternType");
    action.setParams({
      searchType: searchType
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var patternList = response.getReturnValue();
        console.log("patternList: ", patternList);
        component.set("v.patternList", patternList);
      }
      component.set("v.loadingSpinner", false);
    });
    $A.enqueueAction(action);
  },
   /*------------------------------------------------------
     * EDGE-126317
     * Method:doInit
     * Description: Method to initialize pattern picklist
     * Author: Kalashree Borgaonkar
     ------------------------------------------------------*/ 
  doInit: function(component, event) {
    this.renderPatternTypeOptions(component, event);
  },
    addAddress:function(component, event,helper){
        var action=component.get("c.checkForPartnerUser");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var IsPartner=response.getReturnValue();
                console.log('IsPartner=='+IsPartner);
                if(IsPartner) {
                    window.open("/partners/s/communityaddresssearch");
                }
                else{
                    window.open("/lightning/n/Address_Search_New");
                }
            }
            else if (state==="ERROR") {
                var errorMsg = action.getError()[0].message;
            }
        });
        $A.enqueueAction(action);
    }
});
({
  doInit: function (component, event, helper) {
    component.set("v.showSpinner", true);
    var CallingPlan = component.get("v.CallingPlan");
    //EDGE-185639
    var jsonsoi = component.get("v.jsonsoi");
    var offerId = component.get("v.offerid");
    var SolutionId = component.get("v.SolutionID");
    //EDGE-140157 start
    var guid = component.get("v.guid");
    var Mode=component.get("v.Mode");
    var changeType = component.get("v.changeType");
    //EDGE-140157 end
    if (changeType == "New" || changeType == "") {
      component.set("v.isNewBasket", true);
    }
    var action = component.get("c.getRateCard_Discounts");
    action.setParams({
        "callingPlan":CallingPlan,
        "offerId":offerId,
        "solutionId": SolutionId,
        "changeType": changeType,
        "guid": guid,
        "Mode":Mode,
        //EDGE-185639
        "jsonsoiString": jsonsoi
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var res = response.getReturnValue();
        if (res) {
          component.set("v.discountDataList", res.discountDTOList);
          var rateCardMap = [];
          var rateCardList = res.RateCardMap;
          console.log("rateCardList --> is" + JSON.stringify(rateCardList));
          for (var key in rateCardList) {
            rateCardMap.push({ value: rateCardList[key], key: key });
          }
          console.log("rateCardMap in UI-->" , rateCardMap);
          component.set("v.RateCardMap", rateCardMap);
          helper.createJson(component);
        }
        if (
          component.get("v.discountDataList") == null ||
          component.get("v.discountDataList") == ""
        ) {
          component.set("v.isDiscountDataListEmpty", true);
        } else {
          component.set("v.isDiscountDataListEmpty", false);
        }
      }
      component.set("v.showSpinner", false);
    });
    $A.enqueueAction(action);
  },

  //This method will close the lightning page
  //EDGE-185639
  handleCancel: function (component, event, helper) {
    window.setTimeout(
      $A.getCallback(function () {
        window.parent.postMessage("close", "*");
        sessionStorage.setItem("close", "close");
      }),
      1000
    );
    return;
  },

  //This method will save the expected sios data in json_data and will pass the value to parent js
  //EDGE-185639
  handleSave: function (component, event, helper) {
      helper.createJson(component);
      window.setTimeout(
            $A.getCallback(function() {
                window.parent.postMessage("close", "*");
                sessionStorage.setItem("close", "close");
            }),
            1000
        );
  },
  
})
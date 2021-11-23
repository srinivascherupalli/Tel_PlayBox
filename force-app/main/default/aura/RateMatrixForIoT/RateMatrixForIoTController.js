({     
    doInit : function(component, event, helper) {
        var CallingPlan=component.get("v.CallingPlan");
        var offerId=component.get("v.offerid");      
		var action = component.get("c.getRateCardData");
        var commProdId=  component.get("v.commProdId");
        var compName = component.get("v.componentName");
        var jsonsio = component.get("v.jsonsios");
        var guid=component.get("v.guid");
        var changeType=component.get("v.changeType");
        var basketId=component.get("v.basketId");
        var selectplanname=component.get("v.selectplanname");
        var solutionId = component.get("v.solutionId");//Vamsi
        // Modified by Nikhil as part of DIGI-603 
        var getSolutionType = component.get("c.getSolutionType");
        // modified by shashank to implement domancy 
        var isDmsRatematrixActive = component.get("c.dmsRatematrixActive");
        var getDMSRateCardData = component.get("c.retrieveConsumptionRateCards");
        var getRateCardDiscoutIoT = component.get("c.getRateCard_DiscountsIoT");//Vamsi
        getSolutionType.setParams({
            "offerId": offerId,
        });
        getSolutionType.setCallback(this, function (response) {
            var state = response.getState();
            console.log(state);
            if (state == "SUCCESS") {
                let solutionType = response.getReturnValue();
                console.log(solutionType);
                //Added ChangeType as transition for MDM transition flow
                if(changeType != undefined && (changeType == 'New' || changeType == '' || changeType == 'transition')) {
                    component.set("v.isNewBasket", true);
                }
                if(solutionType == 'DMS'){
                    getDMSRateCardData.setParams({
                        "offerId": offerId,
                        "jsonsios": jsonsio
                    });
                    getDMSRateCardData.setCallback(this, function (response) {
                        helper.fillRateCardMap(component,CallingPlan,response);
                    });
                    $A.enqueueAction(getDMSRateCardData);

                     // changes started by shashank - DIGI-37779
                    //  console.log('calling doormancy dms ');
                     isDmsRatematrixActive.setCallback(this, function (response) {
                         helper.toggleFeature(component,response);
                     });
                     $A.enqueueAction(isDmsRatematrixActive);
                     // changes ended by shashank - DIGI-37779
                }
                //Vamsi
                else if(solutionType == 'IOT')
                {
                        getRateCardDiscoutIoT.setParams({
                             "callingPlan":CallingPlan,
                             "offerId": offerId,
                             "solutionId":solutionId,
                             "changeType": changeType,
                             "jsonsios": jsonsio,
                             "selectplanname":selectplanname,
                             "guid":guid
                        });
                    getRateCardDiscoutIoT.setCallback(this, function (response) {
                        helper.fillRateCardMap(component,CallingPlan,response);
                    });
                    $A.enqueueAction(getRateCardDiscoutIoT);
                }//Vamsi
                    else {

                    action.setParams({
                        "callingPlan":CallingPlan,
                        "offerId": offerId,
                        "commProdId": commProdId,
                        "jsonsios": jsonsio,
                        "basketId":basketId,
            			"selectplanname":selectplanname
                    });
                    action.setCallback(this, function (response) {
                        helper.fillRateCardMap(component,CallingPlan,response);
                    });
                    $A.enqueueAction(action);
                }
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set('v.errorMessage',errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(getSolutionType);
        /***-----------------END DIGI-603---------------------------***/
    },
    //This method will close the lightning page
    //EDGE-185639
    handleCancel : function(component,event){
         window.setTimeout(
            $A.getCallback(function() {
                window.parent.postMessage("close", "*");
                sessionStorage.setItem("close", "close");
            }),
            1000
        );
        return;
    },
    //This method will save the expected sios data in json_data and will pass the value to parent js
    //EDGE-189788
    handleSave : function(component, event, helper) {
        var json_Data = [];
        var rateCardMapVal = component.get("v.RateCardMap");
        var jsonSIOData = JSON.parse(component.get("v.jsonsios"));
        var isNewbasket = component.get("v.isNewBasket");
        var solutionType = component.get("v.solutionType");
        jsonSIOData.forEach(function(item){
            var wrapSIO = item;
            rateCardMapVal.forEach(function(rateCardVal){ 
                rateCardVal.value.forEach(function(Value){
                    //EDGE-205510 - Updated the if condition with rateGroupIdentifier

                    if(solutionType=='DMS'){
                        if(item['name'] == Value.rateCardName ){
                                                console.log("before isNewbasket",isNewbasket);
                        if(isNewbasket){
                            // console.log("inside if isnewbasket");
                            wrapSIO.expectedSIO = Value.expectedSIO; // rateCardVal.value[0].expectedSIO-- added by shashank DIGI-32149
                            // console.log("expectedSIO "+wrapSIO.expectedSIO);
                        }else{
                            // console.log("inside else isnewbasket");
                            wrapSIO.actualSIO = rateCardVal.value[0].actualSIO;  //
                        }
                        console.log('ChargeFrequency',Value.chargeFrequency);
                        wrapSIO.chargeFrequency = Value.chargeFrequency;  // added by shashank DIGI-32149
                        wrapSIO.rateCardName = Value.rateCardName;
                        wrapSIO.rateCardId = Value.rateCardId;
                      
                        if(isNewbasket && wrapSIO.expectedSIO >= Value.rangeFrom && wrapSIO.expectedSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        }else if(!isNewbasket && wrapSIO.expectedSIO >= Value.rangeFrom && wrapSIO.expectedSIO <= Value.rangeTo){
                            wrapSIO.previousRate = (wrapSIO.previousRate == 0)?wrapSIO.currentRate:wrapSIO.previousRate;
                        }
                        if(!isNewbasket && wrapSIO.actualSIO >= Value.rangeFrom && wrapSIO.actualSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        }
                        }
                    }
                    else if(item['rateGroupIdentifier'] == Value.rateGroupIdentifier){
                        if(isNewbasket){
                            wrapSIO.expectedSIO = rateCardVal.value[0].expectedSIO;
                        }else{
                            wrapSIO.actualSIO = rateCardVal.value[0].actualSIO;
                        }
                        wrapSIO.rateCardName = Value.rateCardName;
                        wrapSIO.rateCardId = Value.rateCardId;
                        if(isNewbasket && wrapSIO.expectedSIO >= Value.rangeFrom && wrapSIO.expectedSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        }else if(!isNewbasket && wrapSIO.expectedSIO >= Value.rangeFrom && wrapSIO.expectedSIO <= Value.rangeTo){
                            wrapSIO.previousRate = (wrapSIO.previousRate == 0)?wrapSIO.currentRate:wrapSIO.previousRate;
                        }
                        if(!isNewbasket && wrapSIO.actualSIO >= Value.rangeFrom && wrapSIO.actualSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        } 
                    }
                }); 
                
            });
            json_Data.push(wrapSIO); 
        });
        console.log('json_Data '+json_Data);
        var guid=component.get("v.guid");
        let pageloadPayload={
            command: 'RateCard' ,
            data: JSON.stringify(json_Data),
            caller : component.get("v.componentName"),
            guid : guid
        };
        window.parent.postMessage(pageloadPayload,"*");
        window.setTimeout(
            $A.getCallback(function() {
                window.parent.postMessage("close", "*");
                sessionStorage.setItem("close", "close");
            }),
            1000
        );
        //return;
    }
})
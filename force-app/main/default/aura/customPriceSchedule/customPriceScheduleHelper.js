({
    getDiscountDetails: function(component, event) {

        var configId = component.get('v.configId');
        var changeFlag = component.get('v.changeFlag'); //Added by Ankit as a part of EDGE-123593
        //Added by Aman Soni as a part of EDGE-123593 || Start
        var classtoSet = '';
        var responsePayDTOType = false;
        console.log('changeFlag--->' + changeFlag);
        if(!changeFlag)
         classtoSet = 'c.fetchPricingSummaryResponseEM';
        else
          classtoSet = 'c.fetchModifyScheduleEM'; 
        //Added by Aman Soni as a part of EDGE-123593 || End
        var action = component.get(classtoSet);//Added by Aman Soni as a part of EDGE-123593
        action.setParams({
            "configId": configId,
            "changeFlag":changeFlag, //Added by Ankit as a part of EDGE-123593
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var response1 = response.getReturnValue();
                var deviceListItem = [];
                var pricingListItem = [];
                var addonListItem = [];
                
                for (var key in response1){
                    //Modified by Aman Soni as a part of EDGE-123593 || Start
                    if (key === "Price Item") {												
                        if(response1[key]["ResponsePayload__c"]!=null && response1[key]["ResponsePayload__c"] != undefined)
                        {
                         responsePayDTOType =false;
                         component.set("v.responsePayDTOTypeCmp", responsePayDTOType);
                         var pricingCLI = JSON.parse(response1[key]["ResponsePayload__c"]);
                         var pricingDate = response1[key]["CreatedDate"];
                        }
                        else{
                        responsePayDTOType =true;
                        component.set("v.responsePayDTOTypeCmp", responsePayDTOType);
                        var pricingCLI = JSON.parse(response1[key]["chargeLineItems"]);
                        }					
						var pricingDateStr = new Date(pricingDate);
						var dd = String(pricingDateStr.getDate()).padStart(2, '0');
						var mm = String(pricingDateStr.getMonth() + 1).padStart(2, '0');
						var yyyy = pricingDateStr.getFullYear();
						var formattedPricingDate = yyyy + '-' + mm + '-' + dd;						
                        console.log('Response date-->',formattedPricingDate);
					    component.set("v.today", formattedPricingDate);										
						var planPrice = responsePayDTOType ? pricingCLI.unitPrice : pricingCLI.chargeLineItems.unitPrice__c;
                        var planContractTerm = responsePayDTOType ? pricingCLI.contractTerm : pricingCLI.chargeLineItems.contractTerm__c;
						console.log('Plan Name ---->' + component.get("v.planName"));//added for EDGE-136003						
						component.set("v.unitPrice", planPrice);
						component.set("v.contractTerm", planContractTerm);
						var psliCheck ;
                        var psliCheck = responsePayDTOType ? pricingCLI : pricingCLI.chargeLineItems;
						for (var j = 0; j < psliCheck.priceScheduleLineItem.length; j++) {
                            if(psliCheck.priceScheduleLineItem[j].applicableDiscounts){
                            if(psliCheck.priceScheduleLineItem[j].applicableDiscounts.length >0)
                                pricingListItem.push(psliCheck.priceScheduleLineItem[j]);}
						}
                        component.set("v.noPlan", false);
                        //Modified by Aman Soni as a part of EDGE-123593 || End
                    } 
					else if (key === "AddOn"){
						//Modified by Aman Soni as a part of EDGE-123593 || Start
                        if(response1[key]["ResponsePayload__c"]!=null && response1[key]["ResponsePayload__c"] != undefined)
                        {
                         responsePayDTOType =false;
                         component.set("v.responsePayDTOTypeCmp", responsePayDTOType);
                         var addOnCLI = JSON.parse(response1[key]["ResponsePayload__c"]);
                         var addonDate = response1[key]["CreatedDate"];	
                        }
                        else{
                        responsePayDTOType =true;
                        component.set("v.responsePayDTOTypeCmp", responsePayDTOType);
                        var addOnCLI = JSON.parse(response1[key]["chargeLineItems"]);
                        }		
                        console.log('responsePayDTOType--->',responsePayDTOType);
						var addonDateStr = new Date(addonDate);
						var dd = String(addonDateStr.getDate()).padStart(2, '0');
						var mm = String(addonDateStr.getMonth() + 1).padStart(2, '0'); //January is 0!
						var yyyy = addonDateStr.getFullYear();
						var formattedPricingDate = yyyy + '-' + mm + '-' + dd;												
                        console.log('AddOn Response date-->',formattedPricingDate);	
						component.set("v.today", formattedPricingDate);										
						var planPrice = responsePayDTOType ? addOnCLI.unitPrice : addOnCLI.chargeLineItems.unitPrice__c;
                        var planContractTerm = responsePayDTOType ? addOnCLI.contractTerm : addOnCLI.chargeLineItems.contractTerm__c;
						console.log('Addon Name ---->' + component.get("v.addOnPlanName"));//added for EDGE-136003
						component.set("v.addOnUnitPrice", planPrice);
						component.set("v.addOnContractTerm", planContractTerm);				
                        var psliCheck = responsePayDTOType ? addOnCLI : addOnCLI.chargeLineItems;
                        for (var j = 0; j < psliCheck.priceScheduleLineItem.length; j++) {
                            if(psliCheck.priceScheduleLineItem[j].applicableDiscounts){
                            	if(psliCheck.priceScheduleLineItem[j].applicableDiscounts.length >0)
                                addonListItem.push(psliCheck.priceScheduleLineItem[j]);
                            }
                        //Modified by Aman Soni as a part of EDGE-123593 || End
						}
						component.set("v.noAddon", false);
                    }else if (key === "PricingError") {
                        component.set("v.noPlan", true);
                    }else if (key === "DeviceError") { //Added by Ankit as a part of EDGE-123593
                        component.set("v.noDevice", true); //Added by Ankit as a part of EDGE-123593
                    } else {
                        component.set("v.noAddon", true);
                    }

                }
                addonListItem.sort(compare);
                component.set("v.addOnDetails", addonListItem);
                pricingListItem.sort(compare);
                component.set("v.pricingDetails", pricingListItem);
                console.log('responsePayDTOType',responsePayDTOType);
                //Added by Aman Soni as a part of EDGE-123593 
                function compare(a, b) {
                    var fromPeriodVar = responsePayDTOType ? 'fromPeriod' : 'fromPeriod__c';
                    console.log('fromPeriodVar',fromPeriodVar);
                    var bandA = parseInt(a.fromPeriodVar);//Added by Aman Soni as a part of EDGE-123593
                    var bandB = parseInt(b.fromPeriodVar);//Added by Aman Soni as a part of EDGE-123593

                    let comparison = 0;
                    if (bandA > bandB) {
                        comparison = 1;
                    } else if (bandA < bandB) {
                        comparison = -1;
                    }
                    return comparison;
                }

            } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE RESPONSE");
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

    },

})
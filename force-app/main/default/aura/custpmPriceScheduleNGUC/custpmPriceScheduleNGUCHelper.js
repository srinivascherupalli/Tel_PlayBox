({
    getDiscountDetails: function(component, event) {

        var configId = component.get('v.configId');
        console.log('contractType...'+component.get('v.contractType'));
        //console.log('Config ID from '+ eventSource +' Tab'+configId);
        var action = component.get("c.fetchPricingSummaryResponse");
        action.setParams({
            "configId": configId,
            "changeFlag":false
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response1 = response.getReturnValue();
                console.log('Response --->' + JSON.stringify(response1));
                console.log('Response1 Json--->' + response1);
                var deviceListItem = [];
                for (var key in response1) {
                    if (key === "Device") {
                        console.log('inside Pricing Key chargeLineItems...' + JSON.stringify(response1[key]));
                        var deviceCLI = JSON.parse(response1[key]);
                        console.log('deviceCLI..' + deviceCLI);
                            var businessId = deviceCLI.chargeLineItems.businessID__c;
                            var unitPrice = deviceCLI.chargeLineItems.unitPrice__c;
                            var contractTerm = deviceCLI.chargeLineItems.contractTerm__c;

                            component.set("v.unitPrice", unitPrice);
                            component.set("v.contractTerm", contractTerm);
                            console.log('inside Pricing Key chargeLineItems...' + deviceCLI.chargeLineItems.priceScheduleLineItem);
                            for (var j = 0; j < deviceCLI.chargeLineItems.priceScheduleLineItem.length; j++) {
                                console.log('response.chargeLineItems.priceScheduleLineItem[j] --->' + JSON.stringify(deviceCLI.chargeLineItems.priceScheduleLineItem[j]));
                                deviceListItem.push(deviceCLI.chargeLineItems.priceScheduleLineItem[j]);
                            }
                       // }
                    } else if (key === "DeviceError") {
                        component.set("v.noDevice", true);
                    }
                }

                deviceListItem.sort(compare);
                component.set("v.deviceDetails", deviceListItem);

                function compare(a, b) {
                    var bandA = parseInt(a.fromPeriod__c);
                    var bandB = parseInt(b.fromPeriod__c);

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
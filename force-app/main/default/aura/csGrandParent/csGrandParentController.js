({
    //This will create a modal component 
    doInit: function(component, event, helper) {
        
var uType;
        var modalBody;
        
        var action1 = component.get("c.returnUserInfo");
        action1.setCallback(this, function(response) {
            var states = response.getState();
            console.log("######states#########"+states);
            if (states === "SUCCESS") {
                console.log('RETURNED BASE URL*****' + response.getReturnValue());
                uType = response.getReturnValue();
                console.log("recordID " + component.get("v.recordId"));
                console.log("#usertype " + uType);
                if (uType == 'PowerPartner') {
                    console.log("Inside if");
                    $A.createComponents([
                            ["c:csParentCaseScreen", {
                                recordId: component.get("v.recordId")
                            }]
                        ],            
                        function(modalCmps, status, errorMessage) {
                            console.log("Before if");
                            if (status === "SUCCESS") {
                                console.log("Inside if 2");
                                modalBody = modalCmps[0];
                                component.find('overlayLib').showCustomModal({
                                    body: modalBody,
                                    showCloseButton: true,
                                    cssClass: "slds-modal_small",
                                    closeCallback: function() {
                                        console.log('*****closeCallback Called*****');
                                        //console.log("window.location.href "+window.location.href);   
                                        var str = window.location.href;
                                        var res = str.replace("/detail/", "");
                                        //console.log("res "+res);
                                        window.location.assign(res);
                                        // window.open(res);                     
                                    }
                                });
                            } else if (status === "ERROR") {
                                console.log('ERROR: ', errorMessage);
                            }
                        }
                    );
                }else {
                    var newEvent = $A.get("e.force:navigateToComponent");
        newEvent.setParams({
            componentDef: "c:csParentCaseScreen",
            componentAttributes: {
            	recordId : component.get("v.recordId")
			}
        });
        console.log('****EVENT fired csGrandParentcmp');
        newEvent.fire();
                }
            } 
        });

        $A.enqueueAction(action1);
        
        window.setTimeout(
            $A.getCallback(function() {

                //$A.get("e.force:closeQuickAction").fire();
            }), 1000

        );
     },
})
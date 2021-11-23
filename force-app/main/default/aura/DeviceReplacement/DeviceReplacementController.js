({
        doInit: function (component, event, helper)  {
             helper.helperOptionvalue(component,component.get("v.recoveryMethodSobject"), helper);
            helper.helperOptionvalue(component,component.get("v.returnReasonSobject"), helper);
        },
        /*search subsciption for searched device. */
        search:function (component, event, helper){
            
            component.set("v.showSuccessMessage",false);
            if(component.get("v.deviceId")=='' || component.get("v.deviceId")==null){
                component.set("v.errorMessage",$A.get("$Label.c.Device_Id_Is_BlanK"));
                component.set("v.showMessage",true)
                
            }
            else{
                component.set("v.showMessage",false);
                helper.searchHelper(component, event, helper);
                helper.helperGetAssetName(component);//--Edge-100986 Osaka--//
                
                helper.helperGetCurrentDeviceSKU(component);//--Edge-175532 Osaka--//
                helper.showReplacedeviceButton(component, event, helper);
            }
        },
        /* open replacement form*/  
        handleRowAction:function(component,event,helper){
            component.set("v.subscriptions",JSON.stringify(event.getSource().get('v.value')));
            component.set("v.showForm",true);
            component.set("v.showSuccessMessage",false);
        },
        /* Submit device replacement form */  
        submit: function(component, event, helper) {
            component.set("v.shellProductDetails.telstraNowCaseID",component.get("v.tNowCaseRef"));
            var allValid = component.find('fieldId').reduce(function (validSoFar, inputCmp) {
                inputCmp.showHelpMessageIfInvalid();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            if(allValid){  
                if(component.get("v.deliveryContact") == null || component.get("v.deliveryAddress") == null){
                    component.set("v.errorMessage",$A.get("$Label.c.Delivery_Address_And_Contact_Is_Blank"));
                    component.set("v.showMessage",true);  
                }
                /*Updated Device Care Case ID from DCMMC to DCM   */
                else if(component.get("v.shellProductDetails.deviceCareCaseID") != null && !component.get("v.shellProductDetails.deviceCareCaseID").startsWith("DCM")) {
                    component.set("v.errorMessage",$A.get("$Label.c.Device_Care_Case_ID_Validation"));
                    component.set("v.showMessage",true);
                }
                   

                        else {
                            component.set("v.showMessage",false);
                            component.set("v.showForm",false);
                            component.set("v.errorMessage",'');
                            component.set("v.showSpinner",true);
                            helper.submitOrder(component, event, helper);
                        } 
            }
            
        },
        cancel: function(component, event, helper) {
            component.set("v.showForm",false);
            component.set("v.showMessage",false);
            component.set("v.errorMessage",'');
        },
        
        addAddress:  function(component, event, helper) {
            window.open("/lightning/n/Address_Search_New");
        },
        addContact:  function(component, event, helper) {
            window.open("/lightning/o/Contact/new");
        }, 
        gotoOrder:function(component, event, helper) {
            window.open("/lightning/r/csord__Order__c/"+component.get("v.order.Id")+"/view");
        },
        gotoSubscription : function(component, event, helper) {
           // window.open("/lightning/r/csord__Subscription__c/"+event.target.id+"/view");
            // Get the record ID attribute
            var record = event.target.id;
            
            // Get the Lightning event that opens a record in a new tab
            var redirect = $A.get("e.force:navigateToSObject");
            
            // Pass the record ID to the event
            redirect.setParams({
                "recordId": record
            });
            
            // Open the record
            redirect.fire();
            
        },
    })
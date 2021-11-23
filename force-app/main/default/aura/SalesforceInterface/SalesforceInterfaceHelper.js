({
	/*
    Author: Girish P
    Dated : 18-JAN-2018
    Description: this function calls SF and resolves promise and returns to calling function.
    all server calls should be routed though this
    */
    submitToSF: function(resolve, reject,component, sfMethod,params) {
        var action = component.get(sfMethod);
        action.setParams(params);
        action.setCallback(this, function(response) {
            console.log('Salesforce Response***');
            console.log(response);
            var state = response.getState();
            console.log(response.getReturnValue());
            if (state === 'SUCCESS') {
                console.log(resolve);
                if (resolve) {
                    console.log('Inside resolve.getReturnValue()');
                    resolve(response.getReturnValue());
                }
            } else {
                if (reject) {
                    console.log('Rejecting with Error');
                    console.log(response.getError()[0].message);
                    reject(Error(response.getError()[0].message));
                }
            }
        });
        $A.enqueueAction(action);
    },

    /*
        Author: Girish P
        Dated : 18-JAN-2018
        Description: this function calls SF and resolves promise and returns to calling function.
        all server calls should be routed though this
        */
    showToast: function(params) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: params.mode,
            type: params.type,
            message: params.message
        });
        // $A.get("e.force:refreshView").fire();
        toastEvent.fire();
        console.log('Toast Fried!');
    },
    getParameteres:function(component,event){
        var parameters = event.getParam("arguments");
        return parameters;
    },
    checkEmailValidity2: function(component, emailComponentId) {
        var emailComponent = component.find(emailComponentId);
        var email = emailComponent.get("v.value");
        console.log("email***" + email);
        var regExp = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
        var validEmail = regExp.test(email) || email == "";
        console.log("validEmail***" + validEmail);
        if (validEmail) {
            this.handleUserMessageAndSave(component, emailComponent, false, "");
        } else {
            console.log("inside else**");
            this.handleUserMessageAndSave(
                component,
                emailComponent,
                true,
                "Please Enter a Valid Email Address"
            );
        }
        return validEmail;
    },
    handleShowNotice: function(component, nHeader, nVariant, syserr) {
        component.find("notifLib").showNotice({
            header: nHeader,
            variant: nVariant,
            message: syserr
        });
    },
    handleComponentError: function(
        component,
        errorComponent,
        isErrorEnabled,
        sMessage
    ) {
        component.set("v.errormsg", sMessage);
        //component.set("v.disSaveButt", isErrorEnabled);
        if (isErrorEnabled) {
            errorComponent.set("v.validity", {
                valid: !isErrorEnabled,
                badInput: isErrorEnabled
            });
        }
    },
})
({
    doInit: function (component, event, helper) {
        console.log("PRMSubmitInit")
        console.log(':::init ');
        // v1.3 update to fetch PRM Opportunity Partner Auto Tagging custom setting records
        var action = component.get("c.getHiearchySettings");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.objPartnerAutoTagging", response.getReturnValue());
                component.set("v.blnOpportunityOptimization", response.getReturnValue().isActive); // P2OB-4957 - custom setting field to wrapper class
                console.log('OPTIMIZATIOn ENABLED*****' + component.get("v.blnOpportunityOptimization"));
            } else if (state === 'ERROR') {
                console.log('Something went wrong. Error');
            } else {
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);

        // v1.3 update to fetch Distributor Model messages
        var action = component.get("c.getDistributorModelSettings");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.objDistributorModel", response.getReturnValue());
            } else if (state === 'ERROR') {
                console.log('Something went wrong. Error');
            } else {
                console.log('Something went wrong, Please check with your admin');
            }
        });
        console.log(':::end issue');
        $A.enqueueAction(action);

        console.log('***valPrimaryDistributor***' + component.get("v.valPrimaryDistributor"));
        console.log('***valPrimaryDistributorName***' + component.get("v.valPrimaryDistributorName"));
    },

    // v1.3 method to fetch details of the selected partner lookup
    checkPartnerActive: function (component, event, helper) {
        // Check if either partner lookup is populated
        component.set("v.saveDisabled", false);
        var currPartner1 = component.find("PartnerAcc1");
        if (currPartner1 != undefined) {
            currPartner1 = currPartner1.get("v.value");
        }
        var currPartner = component.find("PartnerAcc");
        if (currPartner != undefined) {
            currPartner = currPartner.get("v.value");
        }
        var currentPartner;

        if (currPartner != undefined && currPartner != '') {
            currentPartner = currPartner;
        } else if (currPartner1 != undefined && currPartner1 != '') {
            currentPartner = currPartner1;
        }
        console.log('*****currentPartner*****' + currentPartner);
        // Pass the currently selected partner to fetch partner details from PRMSubmitToPartnerRules.cls
        if (currentPartner != undefined && currentPartner != '') {
            // v1.4 moving logic to helper to check conditions for displaying message
            helper.fetchPartnerDetails(component, event, currentPartner);
            /*
            var action = component.get("c.returnSelectedPartner");
            action.setParams({
               partnerId : currentPartner
            });
            
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var accountInstance = response.getReturnValue(); 
                    // If Opportunity Optimization is enabled display new set of messages
                    if(component.get("v.blnOpportunityOptimization")){
                        // v1.4 adding logic to check partner principal contact's user is active
                        console.log('account.PartnerPrincipalContact__c**********'+accountInstance.PartnerPrincipalContact__c);
                        console.log('Account_Status__c**********'+accountInstance.Account_Status__c);
                        console.log('Partner_Type__c**********'+accountInstance.Partner_Type__c);
                        var nonPartnerUserCreated = true;
                        if(accountInstance.PartnerPrincipalContact__c != undefined){
                            var principalContactId;
                            if(accountInstance.Partner_Type__c == 'Nominate'
                            && accountInstance.Account_Status__c != 'Active'){
                                console.log('Non onboarded nominate use case******');
                                principalContactId = accountInstance.Primary_Distributor__r.PartnerPrincipalContact__c;
                            }else{
                                console.log('***Others Use case***');
                                principalContactId = accountInstance.PartnerPrincipalContact__c;
                            }
                            console.log('principalContactId******'+principalContactId);
                            var action1 = component.get("c.returnPartnerUser");
                            action1.setParams({
                                partnerPrincipalContactId : principalContactId
                            });

                            action1.setCallback(this, function(response){
                                var state = response.getState();
                                if(state === 'SUCCESS'){
                                    var userInstance = response.getReturnValue();
                                    console.log('userInstance*****'+userInstance);
                                    if(userInstance == undefined || userInstance == null){
                                        component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").noPartnerUserErrorMessage); // v1.4
                                        nonPartnerUserCreated = false;
                                        component.set("v.saveDisabled",true);
                                        console.log('***USER RESULT UNDEFINED');
                                    }else{
                                        console.log('***USER RESULT NOT UNDEFINED');
                                    }
                                }else if (state === 'ERROR'){
                                    console.log('Something went wrong. Error');
                                }else{
                                    console.log('Something went wrong, Please check with your admin');
                                }
                            });
                            $A.enqueueAction(action1);
                        }else{
                            // display ERROR MESSAGE
                            component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").noPartnerUserErrorMessage); // v1.4
                            nonPartnerUserCreated = false;
                            component.set("v.saveDisabled",true);
                        }
                        // end of v1.4
                        if(accountInstance.Account_Status__c == 'Active'){
                            console.log('Selected account is ACTIVE**********');
                            component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").onboardedPartnerMessage); // P2OB-4957 - custom setting field to wrapper class
                        }else{
                            // For non onboarded nominate account display Distributor name with whom Opportunity will be shared
                            if(accountInstance.Partner_Type__c == 'Nominate'){
                                var nomMsg = component.get("v.objPartnerAutoTagging").nonOnboarderNominateMessage; // P2OB-4957 - custom setting field to wrapper class
                                nomMsg = nomMsg.replace('{!distributorName}',accountInstance.Primary_Distributor__r.Name);
                                component.set("v.OppOptimizationMessage",nomMsg); 
                            }else{
                                component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").nonOnboarderTaggedPartnerMessage); // P2OB-4957 - custom setting field to wrapper class
                            }
                        }
                    }else{
                        // If partner auto tagging is disabled and partner is inactive then display new message
                        console.log('Opp optimization DISABLED**********'+accountInstance.Account_Status__c);
                        if(accountInstance.Account_Status__c != 'Active'){
                            component.set("v.blnOptOptimizationMessage", true);
                            component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").nonOnboarderPartnerErrorMessage); // P2OB-4957 - custom setting field to wrapper class
                            component.set("v.saveDisabled",true);
                        }
                    }
                }else if (state === 'ERROR'){
                    console.log('Something went wrong. Error');
                }else{
                    console.log('Something went wrong, Please check with your admin');
                }
            });
            $A.enqueueAction(action);
            */
        } else {
            component.set("v.OppOptimizationMessage", '');
        }

    },

    handleContinue: function (cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //alert("test");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        appEvent.setParams({
            "IsContinue": "true",
            "PartnerSelectedDetails": "{!v.selectedRowsList}"
        });
        appEvent.fire();
    },
    handleOverideinccancel: function (cmp, event) {
        //Fired when cancel is clicked.
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOnload: function (component, event, helper) {
        component.set("v.spinner", true);
        var recUi = event.getParam("recordUi");
        var parentName = component.get("v.PartnerAccId");
        var parentNameId = component.get("v.RecomondedAccId");
        console.log("PRMhandleOnload")
        // requires inputFields to have aura:id
        //component.find("PartnerAcc").set("v.value", parentName);
        //component.find("RecomandedPartnerAcc").set("v.value", parentNameId);
        component.set("v.spinner", false);
    },

    handleApplicationEvent1: function (cmp, event, helper) {
        console.log("InreciverPRMSubmittoPartner");
        cmp.set("v.spinner", true);
        var IsContinue = event.getParam("IsContinue");
        var ReconmondedId = event.getParam("ReconmondedId");
        var OverideIncumbent = event.getParam("OverideIncumbent");
        var IsOverrideINC = event.getParam("IsOverrideINC");
        var IsContinuePartner = event.getParam("IsContinuePartner");
        var distributorId = event.getParam("valPrimaryDistributor");
        console.log("InreciverPRMSubmittoPartnerReconmondedId" + ReconmondedId);
        console.log("OverideIncumbent" + OverideIncumbent);
        console.log("IsOverrideINC" + IsOverrideINC);
        console.log("IsContinuePartner" + IsContinuePartner);

        console.log("valPrimaryDistributor in handleAppEvt1 *** " + event.getParam("valPrimaryDistributor"));
        console.log("valPrimaryDistributorName in handleAppEvt1 *** " + event.getParam("valPrimaryDistributorName"));
        // v1.4 calling helper to check conditions for error messages
        if (distributorId != undefined) {
            console.log('call helper for distributor details****');
            helper.fetchPartnerDetails(cmp, event, distributorId);
        } else {
            if (ReconmondedId != undefined) {
                console.log('call helper for partner details****');
                helper.fetchPartnerDetails(cmp, event, ReconmondedId);
            }
        }
        //var Partnerjson=event.getParam("PartnerSelectedDetails");
        //var ReconmondedId = event.getParam("ReconmondedId");
        //
        //var Partnerjson=event.getParam("PartnerSelectedDetails");

        //alert("InreciverIsContinue"+IsContinue);
        //alert("InreciverPartnerjson"+Partnerjson);
        console.log("ReconmondedId" + ReconmondedId);

        // set the handler attributes based on event data
        cmp.set("v.IsCotinue", IsContinue);

        cmp.set("v.OverideIncumbent", OverideIncumbent);
        cmp.set("v.IsOverrideINC", IsOverrideINC);
        cmp.set("v.IsContinuePartner", IsContinuePartner);

        console.log("ReconmondedId" + ReconmondedId);
        if (IsOverrideINC == false) {
            cmp.set("v.PartnerAccId", ReconmondedId);
            console.log("IFIsContinue" + IsContinue);
            var partnenLkp = cmp.find("PartnerAcc");
            if (partnenLkp != undefined) {
                cmp.find("PartnerAcc").set('v.value', ReconmondedId); // v1.3
            } else {
                partnenLkp = cmp.find("PartnerAcc1");
                if (partnenLkp != undefined) {
                    cmp.find("PartnerAcc1").set('v.value', ReconmondedId); // v1.3 setting value to PartnerAcc1 instead of Partner Acc
                }
            }
            //  cmp.find("RecomandedPartnerAcc").set("v.value", ReconmondedId)
            cmp.set("v.disabled", "true");

            //cmp.find("PartnerAcc").set("v.value", ReconmondedId);
        }
        if (IsOverrideINC == true) {
            cmp.set("v.PartnerAccId", ReconmondedId);
            console.log("IFIsContinue" + IsContinue);
            // cmp.find("PartnerAcc").set('v.value', ReconmondedId);
            // cmp.find("RecomandedPartnerAcc").set("v.value", ReconmondedId)
            // cmp.set("v.disabled","true");

            //cmp.find("PartnerAcc").set("v.value", ReconmondedId);
        }

        // cmp.find("RecomandedPartnerAcc").set("v.value", ReconmondedId);
        //cmp.set("v.SelectedJson", Partnerjson);
        //location.reload();
        // var numEventsHandled = parseInt(cmp.get("v.numEvents")) + 1;
        //cmp.set("v.numEvents", numEventsHandled);

        cmp.set("v.spinner", false);
    },

    handleSubmitIncOveride: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        /*
        var eventFields = event.getParam("fields");
            var field = 'Override_Reason__c';
            if (eventFields.hasOwnProperty(field)) {
                console.log("eventFields"+eventFields.hasOwnProperty(field));
                console.log("eventFieldsvalue"+ eventFields.Override_Reason__c);
               
                if ( !eventFields.NumberOfEmployees ) {            
                    event.preventDefault();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!!!",
                        "message": "Please fill Employees field",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                
            }*/

        console.log("handleOverideIncSave");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        appEvent.setParams({
            "IsContinue": false,
            "OverideIncumbent": false,
            "IsIncumbentBack": false,
            "IsIncumbentSave": true,
            "PartnerSelectedDetails": "{!v.selectedRowsList}"
        });
        appEvent.fire();

        /*	var record = event.getParam("response");
            component.find("notificationsLibrary").showToast({
            "title": "Submited to Partner",
            "message": "Overide Ride Reason saved sucessfully",
        });
          */
    },

    handleOnSubmit: function (component, event, helper) {
        //  alert("InSubmit");
        component.set("v.spinner", true);
        event.preventDefault();
        var distributorId = component.get("v.valPrimaryDistributor");// v1.2
        var overrideReason = component.get("v.OverideReason");
        var overridecomment = component.get("v.OverideComments");
        var fields = event.getParam("fields");
        console.log('***fields***' + fields);
        fields["Override_Reason__c"] = overrideReason;
        fields["Override_Comment__c"] = overridecomment;
        if (distributorId != undefined && distributorId != '') {// v1.2
            fields.PartnerAccountId = distributorId;
        }
        //  $A.util.removeClass(component.find("messages"), "slds-hide");    
        console.log("fieldssubmited");
        console.log(JSON.stringify(fields));

        //component.get("v.parentId")  
        //fields["AccountId"] = component.get("v.parentId");
        component.find("form").submit(fields);
    },

    handleOnSuccess: function (component, event, helper) {
        component.set("v.spinner", false);
        $A.get("e.force:closeQuickAction").fire();
        var record = event.getParam("response");
        var action = component.get("c.sendChatterToIncumbentPartners");
        action.setParams({
            partnerResultsList: component.get("v.PartnerResults"),
            optyId: component.get("v.recordId")
        });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {

            }
        });
        $A.enqueueAction(action);
        // v1.5 if partner is non onbaorded then display new toast title and message as per P2OB-5227
        var toastTitle = 'Submitted to Partner';
        var toastMsg = 'Opportunity Successfully Submitted to Partner';
        var isNonOnBoarded = component.get("v.blnNonOnbordedPartnerSuccessMessage");
        console.log(isNonOnBoarded + '*****isNonOnBoarded*****');
        if (isNonOnBoarded) {
            toastTitle = 'Non-onboarded Partner Tagged';
            toastMsg = 'You will remain the Opportunity owner';
        }
        // "title":"Submitted to Partner"
        // "message":"Opportunity Successfully Submitted to Partner"
        component.find("notificationsLibrary").showToast({
            "title": toastTitle,
            "message": toastMsg,
            "variant": 'success'
        });


    },
    handleOnonerror: function (component, event, helper) {
        component.set("v.spinner", false);
        /*
            $A.get("e.force:closeQuickAction").fire();
        var record = event.getParam("response");
        component.find("notificationsLibrary").showToast({
            "title": "Submited to Partner",
            "message": "Opportunity Sucessfully Submitted to Partner",
        });
         */
    },
    handleOverideIncback: function (cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //alert("testsave");
        var appEvent = $A.get("e.c:SubmitToPartnerEvent");
        appEvent.setParams({
            "IsContinue": false,
            "OverideIncumbent": false,
            "IsIncumbentBack": true,
            "IsIncumbentSave": false,
            "PartnerSelectedDetails": "{!v.selectedRowsList}"
        });
        appEvent.fire();
    },
    handleOverideIncSave: function (cmp, event) {
        // Get the application event by using the
        // e.<namespace>.<event> syntax
        //cmp.set("v.spinner",true);
        console.log("handleOverideIncSave1*****");

        var passNext = true;

        var Override_Reason = cmp.find("Override_Reason");
        var Override_comment = cmp.find("Override_Comment");
        console.log("handleOverideIncSave1Override_Reason" + Override_Reason);
        console.log("handleOverideIncSave1Override_Reason" + Override_Reason.get("v.value"));
        if ($A.util.isEmpty(Override_Reason.get("v.value"))) {

            console.log("handleOverideIncSave1Override_null");
            passNext = false;
            cmp.set("v.ShowMessageLC", true);
        }
        else {
            console.log("handleOverideIncSave1Override_false");
            console.log("handleOverideIncSave1Override_Reasonval" + Override_Reason.get("v.value"));
            var Override_Reasonother = Override_Reason.get("v.value");
            if (Override_Reasonother == "Other") {
                console.log("handleOverideIncOverride_Reasonother");

                if ($A.util.isEmpty(Override_comment.get("v.value"))) {

                    console.log("handleOverideIncSaveverride_commentes");
                    passNext = false;
                    cmp.set("v.ShowMessageLC", true);
                }
                else {
                    console.log("handleOverideIncSave1Override_valuesentered");
                    passNext = true;
                    cmp.set("v.ShowMessageLC", false);
                }

            }
            else {
                console.log("handleOverideIncSave1Override_valuesentered");
                passNext = true;
                cmp.set("v.ShowMessageLC", false);
            }

        }

        console.log('passNext*****' + passNext);
        if (passNext) {
            var Override_Reason1 = Override_Reason.get("v.value");
            var Override_comment1 = Override_comment.get("v.value");
            cmp.set("v.OverideReason", Override_Reason1);
            cmp.set("v.OverideComments", Override_comment1);
            //var fields = event.getParam("fields");
            // fields["Override_Reason"] ="Others";
            // fields["Override_Comment"] = "test";
            //cmp.find("form").submit();

            var appEvent = $A.get("e.c:SubmitToPartnerEvent");
            appEvent.setParams({
                "IsContinue": true,
                "OverideIncumbent": false,
                "IsIncumbentBack": false,
                "IsIncumbentSave": true
            });
            appEvent.fire();
        }

    }
})
({
    isPartnerLoggedIn : function(component, event, helper) {
        var action = component.get('c.isPartnerLoggedIn');
        action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log('STATE*****'+state);
            if(state == 'SUCCESS'){
                component.set("v.isPartner",a.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getPlanId : function(component, event, helper) {
		var action = component.get('c.getPlanId'); 
        var currentId = component.get('v.recordId');
        console.log('currentId*****'+currentId);
        if(currentId != undefined){
            action.setParams({
                "recId" : component.get('v.recordId') 
            });
		}
		action.setCallback(this, function(a){
            var state = a.getState(); // get the response state
            console.log('STATE*****'+state);
            if(state == 'SUCCESS'){
                var planId = a.getReturnValue().strPlanId;
                var partnerId = a.getReturnValue().strPartnerAccountId;
                var recordFY = a.getReturnValue().strFinancialYear;
                var redirect = a.getReturnValue().blnRedirect;
                component.set("v.parentRecordName",a.getReturnValue().strPartnerAccountName);
                component.set('v.autoRedirect',redirect);
                if(redirect != undefined){
                    if(redirect == false){
                        //getPartnerPlans(component, event, helper, recId);
                        component.set("v.parentRecordId",partnerId);
                        helper.getTableRows(component, event, helper, planId, recordFY);
                    }else{
                        var pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                objectApiName: 'Partner_Plan__c',
                                recordId : planId,
                                actionName: 'view'
                            }
                        };
                        component.set('v.loaded',true);
                        var newee = component.find("navService");
                        newee.navigate(pageReference);
                    }
                }else{
                    var msg = $A.get("$Label.c.PRMPartnerPlanNotFound");
                    msg = msg.replace("{!partner}",component.get("v.parentRecordName"));
                    console.log('****msg***'+msg);
                    //component.set("v.errorMsg",msg);
                    component.set('v.loaded',true);
                    component.find('notifLib').showNotice({
                        "header": "Error",
                        "variant" : "error",
                        "message": msg,
                        closeCallback: function(){
                            console.log('***close called*****');
                            helper.closeModal(component, event, helper);
                        }
                    });
                }
            }else if (state == "INCOMPLETE") {
                // do something
            }else if (state == "ERROR") {
                component.set('v.loaded',true);
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                        component.find('notifLib').showToast({
                            "title": "Error",
                            "variant" : "error",
                            "message": errors[0].message
                        });
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
	},
	getTableFieldSet : function(component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });

        action.setCallback(this, function(response) {
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('fieldSetObj*****'+fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
        })
        $A.enqueueAction(action);
    },
    getTableRows : function(component, event, helper, pId, recFY){
        console.log('*******getTableRows*****');
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        var clang=fieldSetValues.length; 
        for(var c=0; c < clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].name)) {                 
                setfieldNames.add(fieldSetValues[c].name);                   
                if(fieldSetValues[c].type == 'REFERENCE') {                     
                    if(fieldSetValues[c].name.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');
                    }else {
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');
                    }
                }
            }
        }
        var arrfieldNames = [];
        setfieldNames.forEach(v => arrfieldNames.push(v));
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            parentFieldName: component.get("v.parentFieldName"),
            parentRecordId: component.get("v.parentRecordId"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            planId: pId,
            currentFY: recFY
        });
        action.setCallback(this, function(response) {
            var list = JSON.parse(response.getReturnValue());
            console.log('list********'+list);
            component.set('v.loaded',true);
            if(list == undefined || list == ''){
                component.set("v.noRecords",true);
            }else{
                component.set("v.noRecords",false);
            }
            component.set("v.tableRecords", list);
        })
        $A.enqueueAction(action);
    },
    closeModal : function(component, event, helper){
        var element = document.getElementsByClassName("DESKTOP uiModal forceModal");    
        element.forEach(function(e, t) {
            $A.util.addClass(e, 'slds-hide');
        });  
    }
})
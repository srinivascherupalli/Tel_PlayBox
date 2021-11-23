({
    getValues: function(component, event, helper) {
        var record = component.get("v.record");
        //  alert(JSON.stringify('********>record --> '+record[component.get("v.selectedFieldOnClick")]));
        //  alert(JSON.stringify('********>record2 --> '+component.get("v.subHeadingFieldsAPI")));
        var subheading = '';
        if (true == true) {
            for (var i = 0; i < component.get("v.subHeadingFieldsAPI").length; i++) {
                if (record[component.get("v.subHeadingFieldsAPI")[i]]) {
                    subheading = subheading + record[component.get(
                        "v.subHeadingFieldsAPI")[i]] + ' - ';
                }
            }
        }
        subheading = subheading.substring(0, subheading.lastIndexOf('-'));
        component.set("v.subHeadingFieldValues", subheading);
        component.set("v.displayRecord", record[component.get("v.selectedFieldOnClick")]);
    },
    
    handleSelect: function(component, event, helper) {
        
        /*---- Email Id Validation ---*/
        var isValid = helper.validateEmail(component, event, helper);
        /*---- Email Id Validation ---*/
        if(isValid == true){
            var recordId = component.get("v.record")[component.get("v.selectedRecordIdField")];
            var recordName = component.get("v.record")[component.get("v.selectedFieldOnClick")];
            //  alert('id---->'+component.get("v.record")[component.get("v.selectedRecordIdField")]);
            var chooseEvent = component.getEvent("lookupSelect");
            chooseEvent.setParams({
                "recordId": recordId,
                "recordName": recordName
            });
            chooseEvent.fire();
        }
        else{
            var chooseEvent = component.getEvent("lookupSelect");
            chooseEvent.setParams({
                "recordId": '',
                "recordName": '--$$NotValidEmailId$$--'
            });
            chooseEvent.fire();
        }
    },
    
    validateEmail: function(component, event, helper) {
        var isValidEmail = true;
        if(component.get("v.objectAPIName") == "AccountContactRelation"){
            var emailFieldValue = component.get("v.record")["Contact_Email"];
            var regExpEmailformat =
                /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
            if (!$A.util.isEmpty(emailFieldValue)) {
                if (emailFieldValue.match(regExpEmailformat)) {
                    isValidEmail = true;
                } else {
                    isValidEmail = false;
                }
            }
            else {
                isValidEmail = false;
            }
        }
        return isValidEmail;
    }
})
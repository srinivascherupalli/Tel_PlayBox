({
    //get record type id from record type name
    getRecordTypeId : function(component, event, helper){
        var recordTypeName = component.get('v.contactRecordTypeName');
        console.log('recordTypeName value is'+recordTypeName);
        //call apex method
        var recordTypeId = component.get('c.getRecordTypeId');
        //pass object name and record type name
        recordTypeId.setParams({
            "objectName" : component.get('v.objectName'),
            "recordTypeName" : component.get('v.contactRecordTypeName')
        });
        //callback function to get result from server
        recordTypeId.setCallback(this, function(response){
            var state = response.getState();
            console.log('record type value is'+response.getReturnValue());
            if(state === 'SUCCESS'){
                //store record type id in recordTypeId attribute
                component.set('v.recTypeId',response.getReturnValue());
            }
        });
        $A.enqueueAction(recordTypeId);
    },
    
    //get fields detail from field sets
	getFields : function(component, event, helper){
        var objName = component.get('v.objectName');
        var fieldSet = component.get('v.fieldSetName');
        console.log('objectName value is'+objName);
        console.log('fieldSetName value is'+fieldSet);
        var fieldSetList = fieldSet.split(',');
        console.log('fieldSetList value is'+fieldSetList);
        //call apex method to get field details from fieldsets
		var contactInfoFieldSet = component.get('c.getFieldSetMember');
        contactInfoFieldSet.setParams({
            "objectName" : objName,
            "fieldSetName" : fieldSetList[0]
        });
        //callback method to get output from server
        contactInfoFieldSet.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                //create new object to generate contact information section
                var contactFieldList = new Object();
                contactFieldList.SectionLabel = 'Contact Information';
                contactFieldList.ContactFieldList = JSON.parse(response.getReturnValue());
                contactFieldList.DetailPresent=true;
                component.set("v.contactfieldList",contactFieldList);
                console.log('contactFieldList value is'+JSON.stringify(contactFieldList));
                console.log('fieldSetList[1] value is'+fieldSetList[1]);
                if(fieldSetList[1] != undefined){
                    //call apex method to get field details from fieldsets
                    var addressInfoFieldSet = component.get('c.getFieldSetMember');
                    addressInfoFieldSet.setParams({
                        "objectName" : objName,
                        "fieldSetName" : fieldSetList[1]
                    });
                    addressInfoFieldSet.setCallback(this, function(response){
                        if(response.getState() === 'SUCCESS'){
                            //create new object to generate address information section
                            var addressFieldList = new Object();
                            addressFieldList.SectionLabel = 'Address Information';
                            addressFieldList.AddressFieldList = JSON.parse(response.getReturnValue());
                            addressFieldList.DetailPresent=true;
                            component.set("v.addressFieldList",addressFieldList);
                            console.log('addressFieldList value is'+JSON.stringify(addressFieldList));
                        }
                    });
                    $A.enqueueAction(addressInfoFieldSet);
                }
            }
        });
        $A.enqueueAction(contactInfoFieldSet);
	},
    
    //this method is used to set error messages,if there are errors
    handleOnError : function(component, event, helper) {
        component.set('v.spinner',false);
        // Get the error message
    	var errorMessage = event.getParam("message");
        console.log('erorm essage is'+errorMessage);
        console.log('Detail essage is'+event.getParam("detail"));
        console.log('erorm essage is'+JSON.stringify("output"));
        component.set('v.isError',true);
        component.set('v.errorDetail',event.getParam("detail"));
        //show toast messages if there is any error
        var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
            "type":"error",
        	"title": "Error!",
        	"message": "Please review Error messages on page",
            "mode":"pester",
            "duration":"1000",
            "class":"toastEventClass"
    	});
    	toastEvent.fire();
	},
    
    //this method is used to set get contact id of newly created record 
    handleSuccess : function(component, event, helper) {
        console.log('Record is created');
        component.set('v.spinner',false);
        component.set('v.isError',false);
        var getRecord = event.getParams().response;
        console.log('getRecord value is'+getRecord.id);
        component.set('v.recordId',getRecord.id);
        //show toast message on successful creation of records
    	var toastEvent = $A.get("e.force:showToast");
    	toastEvent.setParams({
            "type":"success",
        	"title": "Success!",
        	"message": "The record has been created successfully.",
            "mode":"pester",
            "duration":"1000"
    	});
    	toastEvent.fire();
      $A.get("e.force:refreshView").fire();
      component.set('v.isUserForm',false);
      //Call the child-component 'prmFindUserPIMS' to handle findUser and CreateUser
      var findUserCMP = component.find('prmFindUserPIMS');  
      var eventId = event.getSource().getLocalId();
      findUserCMP.childmanageUserJS(eventId, JSON.stringify(getRecord));
    },
    
    //this method is used to submit record and also default selection of few fields like AcountId,Pref_Comm_Method__c
    handleSubmit : function(component, event, helper) {
        event.preventDefault();
    	var fields = event.getParam("fields");
        fields["AccountId"] = component.get("v.userAccountId");
        fields["Pref_Comm_Method__c"] = 'eMail';
        console.log('fields value are '+JSON.stringify(fields));
    	component.find("finduser").submit(fields);
        var elements11 = document.getElementsByClassName("modalClass");
        console.log('element 11 ali'+elements11.length);
	},
    
    showSpinnerWindow: function(component, event) {
        component.set("v.Spinner", true);
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner: function(component, event, helper) {
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
})
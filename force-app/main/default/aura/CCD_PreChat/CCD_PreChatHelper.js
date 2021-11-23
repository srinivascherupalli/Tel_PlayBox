({
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
	fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Enquiry Type":"Enquiry_Type__c"
    },
    
    onStartButtonClick: function(component) {
        
        var prechatFieldComponents = component.find("prechatField");
		var fields;
        
        var enquiryType = component.get('v.enquiryType');
        
        var incidentNumber = component.get('v.incidentNumber');

        console.log('enquiryType::', enquiryType);
                
        var fieldValue = component.get('v.haveIncidents') == true ? 'Incident' : 'General Support enquiries';
        
		var attributes = {
            label: 'enquiryType',
            value: fieldValue,
            name: 'Enquiry Type'
            };
        
        // Make an array of field objects for the library
        fields = this.createFieldsArray(prechatFieldComponents);
        
        console.log('fields :::', fields);
             
        var validation = component.get("v.customerror");
        if(validation == false){
            if (component.find("prechatAPI").validateFields(fields).valid) {
                
                var event = new CustomEvent(
                    "setCustomField",
                    {
                        detail: {
                            callback: component.find("prechatAPI").startChat.bind(this, fields),
                            customField: [fieldValue, incidentNumber]
                        }
                    }
                );
                // Dispatch the event.
                document.dispatchEvent(event);
                //component.find("prechatAPI").startChat(fields);
                //this.createVistorRecord(component, event, helper, fields, customerType);
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        } else {
            
            component.set("v.customerror",true);
            component.set("v.errormessage", "Required fields are missing!")
        }
	},
 
	/**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
	createFieldsArray: function(fields) {
        console.log('fields::', fields);
		if(fields.length) {
			return fields.map(function(fieldCmp) {
				console.log('@@@!! '+fieldCmp.get("v.value") +  '@@@!! '+fieldCmp.get("v.label"));
                
                var value;
                
				return {
					label: fieldCmp.get("v.label"),
					value: value,
					name: this.fieldLabelToName[fieldCmp.get("v.label")]
				};
			}.bind(this));
		} else {
			return [];
		}
	},
    getPrechatFieldAttributesArray: function(prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var prechatFieldsInfoArray = [];
 		
        console.log('prechatFields ::'+ prechatFields);
        
        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            var componentInfoArray = ["ui:" + componentName];
            
            var value = field.value;
            
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                value: value
            };
            
            // Special handling for options for an input:select (picklist) component
            if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);
            
            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
        });
 
        return prechatFieldsInfoArray;
    },
    
    createVistorRecord : function(component, event, helper,fields,customerType){
        var fieldsData = fields;
        var action = component.get("c.savePreChatVisitorCount");
        if(fieldsData.length>0){
            action.setParams({
                "clickInstance" : window.location.href,
                "customerType" : customerType
            });
        }else{
            action.setParams({
                "clickInstance" : window.location.href,
                "customerType" : customerType
            });
        }
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('state ::', state);
            var errors = response.getError();
            console.log('errors ::', errors);
            if(component.isValid() && state === "SUCCESS"){
                var rec = response.getReturnValue();
                if(rec){
                    console.log('Vistor record inserted/updated successfully');
                }else{
                    console.log('Vistor record not inserted successfully');
                }
            }else{
                console.log('Vistor record could not be tracked');
            }
        });
        $A.enqueueAction(action);
    }
});



//})
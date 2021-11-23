({
    /**
	 * Map of pre-chat field label to pre-chat field name (can be found in Setup)
	 */
	fieldLabelToName: {
        "First Name": "FirstName",
        "Last Name": "LastName",
        "Email": "Email",
        "Company Name": "Company_Name__c",
        "Phone": "Phone"
    },
    
	/**
	 * Create an HTML input element, set necessary attributes, add the element to the DOM
	 *
	 * @param fields - pre-chat fields object with attributes needed to render
	 */
    getPrechatFieldAttributesArray: function(component, fields) {
        // Dynamically create input HTML element
        // 
        var prechatFieldsInfoArray = [];

        fields.forEach(function(field) {
            
            var componentName = (field.type === "inputSplitName") ? "inputText" : field.type;
            console.log('componentName!!! '+componentName);
            var componentInfoArray = ["ui:" + componentName];
            var attributes = {
                "aura:id": "prechatField",
                required: field.required,
                label: field.label,
                disabled: field.readOnly,
                maxlength: field.maxLength,
                class: field.className,
                value: field.value,
                name: field.name
            };
            
            // Special handling for options for an input:select (picklist) component
            if(field.type === "inputSelect" && field.picklistOptions) attributes.options = field.picklistOptions;
            
            // Append the attributes Object containing the required attributes to render this pre-chat field
            componentInfoArray.push(attributes);

            // Append this componentInfoArray to the fieldAttributesArray
            prechatFieldsInfoArray.push(componentInfoArray);
        })
        
        console.log('prechatFieldsInfoArray :::', prechatFieldsInfoArray);
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldsInfoArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    component.set("v.prechatFieldComponents", components);
                    console.log('@@@@ '+JSON.stringify(component.get("v.prechatFieldComponents").label));
                }
            }
        );
    },
    /**
	 * Create an array of field objects to start a chat from an array of pre-chat fields
	 * 
	 * @param fields - Array of pre-chat field Objects.
	 * @returns An array of field objects.
	 */
	createFieldsArray: function(fields) {
		if(fields.length) {
			return fields.map(function(fieldCmp) {
                console.log('fieldCmp :::', fieldCmp + '@@@!! '+fieldCmp.get("v.required"));
				return {
					label: fieldCmp.get("v.label"),
					value: fieldCmp.get("v.value"),
                    required: fieldCmp.get("v.required"),
					name: this.fieldLabelToName[fieldCmp.get("v.label")]
				};
			}.bind(this));
		} else {
			return [];
		}
	},
    
    commonBack : function(component, event, helper){
        component.set("v.initialpage",true);
        component.set("v.enterprise",false);
        component.set("v.nonenterprisePersonal",false);
        component.set("v.nonenterpriseBusiness",false);
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
})
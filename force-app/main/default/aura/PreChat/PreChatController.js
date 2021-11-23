({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
	onInit: function(cmp, evt, hlp) {
        // Get pre-chat fields defined in setup using the prechatAPI component
		var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(cmp,prechatFields);
        
    },
    handleEntrepriseClick : function(component, event, helper) {
        component.set("v.initialpage",false);
        component.set("v.enterprise",true);
        component.set("v.nonenterprisePersonal",false);
        component.set("v.nonenterpriseBusiness",false);
	},
	handlePersonalClick : function(component, event, helper) {
        component.set("v.initialpage",false);
        component.set("v.enterprise",false);
        component.set("v.nonenterprisePersonal",true);
        component.set("v.nonenterpriseBusiness",false);
	},
    handleBusinessClick : function(component, event, helper) {
        component.set("v.initialpage",false);
        component.set("v.enterprise",false);
        component.set("v.nonenterpriseBusiness",true);
        component.set("v.nonenterprisePersonal",false);
	},
    handlePersonalRedirect : function(component, event, helper) {
        window.open($A.get("$Label.c.PreChatPersonalRedirect"));
        helper.commonBack(component, event, helper);
        var fields = [];
        var customerType = $A.get("$Label.c.CHAT_BUTTON_PERSONAL");
        helper.createVistorRecord(component, event, helper, fields, customerType);
    },
    handleBusinessRedirect : function(component, event, helper) {
        window.open($A.get("$Label.c.PreChatBusinessRedirect"));
        helper.commonBack(component, event, helper);
        var fields = [];
        var customerType = $A.get("$Label.c.CHAT_BUTTON_SMALL_BUSINESS");
        helper.createVistorRecord(component, event, helper, fields, customerType);
    },
    handleBackClick : function(component, event, helper) {
        component.set("v.customerror",false);
        helper.commonBack(component, event, helper);
	},
    handleBackClickStart : function(component, event, helper) {
        component.set("v.customerror",false);
        var fields = [];
        var customerType = $A.get("$Label.c.CHAT_BUTTON_ENTERPRISE_ABANDONED");
        helper.createVistorRecord(component, event, helper, fields, customerType);
        helper.commonBack(component, event, helper);
	},
    
    createStartChatDataArray: function(component, event, prechatFields) {
        //var input = document.querySelector(".prechatFields").childNodes[0];
        console.log('input '+prechatFields);
        var info = {
            name: input.name,
            label: input.label,
            value: input.value
        };
        return [info];
    },
    
    /**
	 * After this component has rendered, create an  input fields
	 *
	 * @param component - This prechat UI component.
	 * @param event - The Aura event.
	 * @param helper - This component's helper.
	 */
    onRender: function(component, event, helper) {
        
        component.set("v.initialpage",false);
        component.set("v.enterprise",true);
        component.set("v.nonenterprisePersonal",false);
        component.set("v.nonenterpriseBusiness",false);
        // Get array of pre-chat fields defined in Setup using the prechatAPI component
        var prechatFields = component.find("prechatAPI").getPrechatFields();
        console.log('prechatFields', JSON.stringify(prechatFields));
        // Append an input element to the prechatForm div.
        helper.renderField(component, prechatFields);
    },
    
    /**
	 * Handler for when the start chat button is clicked
	 *
	 * @param component - This prechat UI component.
	 * @param event - The Aura event.
	 * @param helper - This component's helper.
	 */
    onStartButtonClick: function(component, event, helper) {
        var prechatFieldComponents = component.find("prechatField");
		var fields;
        var customerType = $A.get("$Label.c.CHAT_BUTTON_ENTERPRISE");
		
        console.log('prechatFieldComponents ::', prechatFieldComponents);
        // Make an array of field objects for the library
        fields = helper.createFieldsArray(prechatFieldComponents);
        
        if((fields[2].value) && (fields[1].value) && (fields[0].value)) {
            console.log('Value :::::: '+ (fields[3].value) + (fields[2].value) + (fields[1].value) + (fields[0].value));
            
            if(fields[2].value){
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if(!(fields[2].value).match(regExpEmailformat)){
                    component.set("v.customerror",true);
                    component.set("v.errormessage", "Email not valid!");
                }else{
                    component.set("v.customerror",false);
                    component.set("v.errormessage", "");
                }     
            }
            
            var validation = component.get("v.customerror");
            if(validation == false){
                if (component.find("prechatAPI").validateFields(fields).valid) {
                    component.find("prechatAPI").startChat(fields);
                    helper.createVistorRecord(component, event, helper, fields, customerType);
                } else {
                    console.warn("Prechat fields did not pass validation!");
                }
            }
           
        }else{
            component.set("v.customerror",true);
            component.set("v.errormessage", "Required fields are missing!")
        }
    }
})
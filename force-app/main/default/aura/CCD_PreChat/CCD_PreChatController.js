({
    onInit: function(cmp, eve, hlp) {     
    	
        // Get pre-chat fields defined in setup using the prechatAPI component
		var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        console.log('prechatFields ::', JSON.stringify(prechatFields));
        
        var settingsApi = cmp.find("settingsAPI").getLiveAgentSettings();
        console.log('settingsApi :::', JSON.stringify(settingsApi));
        // Get pre-chat field types and attributes to be rendered
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(prechatFields);
        
        console.log('prechatFieldComponentsArray:::', prechatFieldComponentsArray);
        // Make asynchronous Aura call to create pre-chat field components
        $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                }
            }
        );
    },
    
    handleIncidents: function (component, evt, helper) {
        component.set('v.initialpage', false);
        component.set('v.isIncidents', true);
        component.set('v.haveIncidents', false);
        var customerType = 'Incidents';
        var fields = [];
        helper.createVistorRecord(component, event, helper, fields, customerType);
    },
    
    sendIncidentToAgent: function (component, evt, helper) {
        component.set('v.initialpage', false);
        component.set('v.isIncidents', false);
        component.set('v.haveIncidents', true);
        var customerType = 'Yes, I have';
        var fields = [];
        helper.createVistorRecord(component, event, helper, fields, customerType);
    },
    
    //handleStartButtonClick: function(cmp, eve, hlp) {
       // hlp.onStartButtonClick(cmp,eve);
    handleStartButtonClick: function(cmp, evt, helper){
       
        var customerType = 'Incident Start Chat';
        var buttonId = evt.getSource().getLocalId();
        
        if(buttonId == 'generalButton') {
            
            customerType = 'General support enquiries';
        }
        var fields = [];
        helper.createVistorRecord(cmp, evt, helper, fields, customerType);
        helper.onStartButtonClick(cmp);
	},
    handleBackClick: function(component, evt, helper){
        
        var isIncidents = component.get('v.isIncidents');
        var haveIncidents = component.get('v.haveIncidents');
        var initialpage = component.get('v.initialpage');
        
        if(isIncidents) {
            
            component.set('v.initialpage', true);
            component.set('v.isIncidents', false);
            component.set('v.haveIncidents', false);
        } else if(haveIncidents) {
            
            component.set('v.initialpage', false);
            component.set('v.isIncidents', true);
            component.set('v.haveIncidents', false);
        }
        var customerType = 'Go back';
        var fields = [];
        helper.createVistorRecord(component, event, helper, fields, customerType);
	},
    logIncident: function(component, event, helper) {
        
        var customerType = 'No, help me to raise it';
        var fields = [];
        helper.createVistorRecord(component, event, helper, fields, customerType);
        window.open($A.get("$Label.c.TCONNECT_INCIDENT_LOG_URL"),'_top');
    }
});
({
	doInit : function(component, event, helper) {
         helper.fetchQualifiedPortList(component, event);
          helper.doInit(component, event);
        	helper.isActiveCAF(component, event);
		
	},
     openModel: function(component, event, helper) {
      
        component.set("v.isOpen", true);
    },
     closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "False"  
        component.set("v.isOpen", false);
         var selectedButtonLabel = event.getSource().get("v.value");
         console.log('selectedButtonLabel',selectedButtonLabel);
        var cmpEvent = component.getEvent("closeModalEvent"); 
   		cmpEvent.setParams({"modalvalue" : selectedButtonLabel
                        }); 
   		cmpEvent.fire();
         
    },
    saveDetails: function(component, event, helper) {
      
        helper.saveDetails(component, event);
    },
     getContactsForInput : function(component, event, helper) {
		helper.getContactsForInput(component, event);
	},
     getPortNumForInput : function(component, event, helper) {
		helper.getPortNumForInput(component, event);
	},
      handleOnblur : function(component, event, helper) {
		helper.handleOnblur(component, event);
	},
     handleContactEvent : function(component, event, helper) {
		helper.handleContactEvent(component, event);
	},
    handlePortEvent : function(component, event, helper) {
		helper.handlePortEvent(component, event);
	},
     changeData:function(component, event, helper){
        helper.changeData(component, event);
    },
    getContactsForCAFInput : function(component, event, helper) {
		helper.getContactsForCAFInput(component, event);
	},
})
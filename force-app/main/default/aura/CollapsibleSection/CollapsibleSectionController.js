({
	ToggleCollapse : function(component, event, helper) { 
		if(component.get("v.collpaseText")=="Show")
			component.set("v.collpaseText","Hide");
		else
			component.set("v.collpaseText","Show");
	},
    	doInit : function(component, event, helper) { 
		/*var test = component.getConcreteComponent();
            console.log('test::s',test);
            if(component.get("v.actionName")=='search'){
                
            }*/
	},
      generateAppErrorScen : function(component, event, helper) {
               helper.generateAppErrorScen(component, event,helper); 
      }
})
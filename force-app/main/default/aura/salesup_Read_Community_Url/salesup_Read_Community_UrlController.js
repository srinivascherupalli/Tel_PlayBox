({
	doInit : function(component, event, helper) {
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); //You get the whole decoded URL of the page.
        var sURLVariables = sPageURL.split('?'); //Split by & so that you get the key value pairs separately in a list
        var sParameterName;
        var i;
        var flow = component.find("LightningflowData");

        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value
        }
        
        var inputVariables = [
            {
            	name : "varQueryParameter",
            	type : "SObject",
            	value : sParameterName[1]
            }
        ];
    
        flow.startFlow("Create_Channel_Care_case_from_Telstra_com",inputVariables);
    }

})
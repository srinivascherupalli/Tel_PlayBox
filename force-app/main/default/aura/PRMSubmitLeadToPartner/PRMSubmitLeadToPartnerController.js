({
	doInit : function(component, event, helper){
		var leadId = component.get("v.LeadId");
        console.log('***leadId***'+leadId);
        var action = component.get("c.findRecommendation");
        action.setParams({leadId : leadId});
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){ 
            	component.set("v.data",response.getReturnValue());
                if(response.getReturnValue() != ''){
                    component.set("v.blnRecommendationsFound", true);
                    console.log('RECO TRUE*****');
                }else{
                    component.set("v.blnRecommendationsFound", false);
                    console.log('RECO FALSE*****');
                }
            }
        });
        $A.enqueueAction(action);
	},
    updateSelectedText : function(component, event, helper){
		var res = event.getSource().get("v.text");
        console.log('Partner Id*****'+res);
        component.set("v.RecommendedPartnerId",res);
	}
})
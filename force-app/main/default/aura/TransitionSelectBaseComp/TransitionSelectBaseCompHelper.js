({
	doInit : function(component, event) {
		var basketId = this.getParameterByName("id", window.location.href);
        component.set("v.basketId",basketId);
        console.log("basketId: ",basketId);
        //Start of DIGI-1753: Added by Pradeep Mudenur from Osaka Team
        var replicatorResponse = component.get("c.checkReplicatorResponseHelper");
            replicatorResponse.setParams({
                basketId: component.get("v.basketId")
            });
            replicatorResponse.setCallback(this, function(response) {
                //Check the condition if Transition is present associated with PC.
                var data = response.getReturnValue();
                console.log("$$$$$$$$" + response.getState());
                if(response.getState() == "SUCCESS"){
                    console.log('Response is success:'+data);
                    if (data == true){
                        console.log('Transition Json is present');
                        component.set("v.isOnScreenRetrieval", true);
                    }
                    else{
                        console.log('Transition Json is not present:'+data);
                        //Setting this flag to true if Transition Json is present.
                        component.set("v.isOnScreenRetrieval",false);
                    }
            }
                
            });
            $A.enqueueAction(replicatorResponse);
        //End of DIGI-1753
	},
    getParameterByName: function (name, url) {
        if (!url) url = window.location.href;
        name = name.replace(/[\[\]]/g, "\\$&");
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
            results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return "";
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
})
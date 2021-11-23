({
    getpicklistvalues: function(component, event,Field) {
    var action = component.get("c.getPicklistvalues");
     action.setParams({ "FieldAPIName" : Field });

         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result'+result);
                var plValues = [];
                for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }
                if(Field == 'Partner_categories__c' ){
               		 component.set("v.PartnercategoriesList", plValues);
                }
                if(Field == 'Source_Info_Telstra_Channel_Partner_prog__c')
                {	
                    
                    component.set("v.TCPProgramoptions", plValues);   
            }
        }
                           
        });
        $A.enqueueAction(action);
    
    
},
    //Added by Ayush for story P2OB-7471
    handleCheckBoxGroup :function(component){
        var partnerSource=component.get("v.TCPProgramoptionsselectedVal");
    	if(partnerSource.includes("A Channel Partner or Distributor")){
   		 	component.set("v.containsDistributor",true);
        }else{
            component.set("v.containsDistributor",false);
        }
    }
       
})
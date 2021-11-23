({
	searchHelper: function (component, event, getInputkeyWord) {
		// call the apex class method 
        console.log('isAddress::'+component.get("v.isAddress")+' isContact::'+component.get("v.isContact"));
        console.log('accountid::'+component.get("v.objectAPIName"));
        var action ='';
        if(component.get("v.isAddress")==true){
            console.log('inside addrss search');
            action=component.get("c.fetchAddressLookUpValues");
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName': component.get("v.objectAPIName")
            });
            // set a callBack    
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    console.log('**storeresponse'); 
                    console.log(storeResponse);
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }                   
                    component.set("v.listOfSearchRecords", storeResponse);
                }
            });
        }
        if(component.get("v.isContact")==true){
            console.log('inside contct search');
            action=component.get("c.fetchDeliveryContactLookUpValues");
            // set param to method  
            action.setParams({
                'searchKeyWord': getInputkeyWord,
                'ObjectName': component.get("v.objectAPIName")
            });
            // set a callBack    
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    console.log('**storeresponse'); 
                    console.log(storeResponse);
                    // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                    if (storeResponse.length == 0) {
                        component.set("v.Message", 'No Result Found...');
                    } else {
                        component.set("v.Message", '');
                    }                   
                    component.set("v.listOfSearchRecords", storeResponse);
                }
            });
        }   	 
		$A.enqueueAction(action);
	},
})
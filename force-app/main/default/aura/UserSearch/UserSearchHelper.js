({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
      var action = component.get("c.searchRecord");
      // P2OB-10711 : added Account.Name field in query
      let accName = ['Account.Name','IsActive'];
      // set param to method  
       action.setParams({objectAPIName : 'User',
                         searchTextPara : getInputkeyWord,
                         fieldAPIName   : 'name',
                         moreFields     : accName,
                         recordLimit    : null,
                         rawSOQLcriteria : '',
                         dyamicVariable  :''
		});
      // set a callBack    
        action.setCallback(this, function(response) {
        $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse value is'+JSON.stringify(storeResponse));
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                
                //P2OB-13417 : Filter to show only Active Users as result of UserSearch
                let filtered_users = storeResponse.filter(function (e) {
                    return (e.IsActive === true);
            	});
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", filtered_users);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
})
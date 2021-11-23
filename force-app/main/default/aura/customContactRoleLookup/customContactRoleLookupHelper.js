({
	searchHelper: function (component, event, getInputkeyWord) {
		// call the apex class method 
		var action = component.get("c.fetchLookUpValues");
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
				if (storeResponse.length == 0) {
					component.set("v.Message", 'No Result Found...');
				} else {
					component.set("v.Message", '');
				}
				// set searchResult list with return value from server.
				var rolesToSort = [];

				for (var i = 0; i < storeResponse.length; i++) {
					var obj = {
						Roles: storeResponse[i].Roles,
						Contact_Name__c: storeResponse[i].Contact_Name__c,
						Id: storeResponse[i].Id,
						ContactId: storeResponse[i].ContactId,
						AccountId: storeResponse[i].AccountId
					};
					rolesToSort.push(obj);
				}

				var ordering = {}, // map for efficient lookup of sortIndex
					sortOrder = ['Full Authority', 'Legal Lessee', 'Limited Authority', 'Asset User', '3rd Party', 'Non-Authorised', 'Advocate', 'Biling Contact', 'Nominated Serv Cust'];
				for (var i = 0; i < sortOrder.length; i++)
					ordering[sortOrder[i]] = i;

				rolesToSort.sort(function (a, b) { // Pass a function to the sort that takes 2 elements to compare
					if (a.Roles == b.Roles) { // If the elements both have the same `type`,
						return a.Contact_Name__c.localeCompare(b.Contact_Name__c); // Compare the elements by `name`.
					} else { // Otherwise,
						return sortOrder.indexOf(a.Roles) - sortOrder.indexOf(b.Roles); // Substract indexes, If element `a` comes first in the array, the returned value will be negative, resulting in it being sorted before `b`, and vice versa.
					}
				});
				component.set("v.listOfSearchRecords", rolesToSort);
			}
		}); 
		$A.enqueueAction(action);
	},
})
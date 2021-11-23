({
	searchHelper : function(component,event,getInputkeyWord) {
      var uniqueValue=component.get("v.objectAPIName")
      let objectName = component.get("v.objectAPIName");
      objectName += '.';
      objectName += component.get("v.primaryField");
     // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'recordId' : component.get("v.inputId"),
            'identifier' : objectName,
             "resultSearchMap": component.get("v.resultMap"),
             "filter": component.get("v.filter")//DPG-3510
          });
          
         action.setStorable(); 
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from serve r.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
    }
    
 
    
})
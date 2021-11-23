({
	helperMethod : function() {
		
	},
    applyCSS: function(cmp, event, class_css) {
       var cmpTarget = cmp.find('relatedList');
       $A.util.toggleClass(cmpTarget,class_css)
    },
    getColumnDefinitions: function (component) {
        var columns = [
            {label: 'Number Name',fieldName: 'linkName' ,
             sortable: true,type : 'url', 
             typeAttributes: { label: { fieldName:'Id'}, target: '_blank'}
            },
            {label: 'Phone Number', fieldName: 'Service_Number__c', type: 'text', sortable: true},
            {label: 'Status', fieldName: 'Status__c' ,type: 'text', sortable: true}
        ];
         component.set("v.columns",columns);
        return columns;
    },
    doinit : function(component, event , helper){
    	var action = component.get("c.getNumbersOfRecord"); // DIGI-27409 changes
        component.set("v.subscriptionId",component.get("v.recordId"));
     	action.setParams({
            recordId: component.get("v.recordId") // DIGI-27409 changes
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var listOfNumber=response.getReturnValue();
                var listofnum_new=[];

              for(var num of listOfNumber) { 
              //Added by Rashmi as part of EDGE-219789 
                      if(num.Mobile__c =='Fixed'){
                     component.set('v.isViewSearch',true) ;                   
                        //alert('v.isViewSearch');
                    }  
                    num.linkName= '/'+num.Id;
                    listofnum_new.push(num);                  
                }
              component.set("v.listOfNumber",listOfNumber );  
              //Added by Rashmi as part of EDGE-219789
              component.set("v.listofSearch",listOfNumber );    
            }
            else if(state === "ERROR"){
                console.log('A problem occurred: ' + JSON.stringify(response.error));
            }
        });
        
        $A.enqueueAction(action);
	}
})
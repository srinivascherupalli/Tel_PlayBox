({  
    
  /*  getData : function(component) {
        //var service = component.find("UtilityService");
        service.callServer(component,
            "c.getRecords", ''
        ).
        then($A.getCallback(function(data) {
                console.log('fetched data');
                "recordLimit": component.get("v.initialRows"),
            "recordOffset": component.get("v.rowNumberOffset"),
     */
    
     getData : function(component) {
 		var action = component.get("c.getRecords");
         var recordId = component.get("v.recordId");
         var initialRows = component.get("v.initialRows");
         
        action.setParams({
                  "recordId":recordId,
            "initialRows":initialRows
        });
       
         console.log("recordI***"+recordId);
         
       //var action = component.get('c.getRecords');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.mydata', response.getReturnValue());
                console.log(response.getReturnValue());
                console.log('response.getReturnValue()');
                var rows = response.getReturnValue();
           		 for (var i = 0; i < rows.length; i++) 
                 {
                	var row = rows[i];
                	if (row.Contact) row.ContactName = row.Contact.Name;
                     if (row.Contact) row.ContactEmail = row.Contact.Email;
                    // console.log(row);
            	}
            component.set('v.data', rows);
			console.log(rows);
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }, //Comment was here
    
    /*
    getContacts : function(component) {
        var action = component.get("c.getRecords");
        action.setParams({
            "recordLimit": component.get("v.initialRows"),
            "recordOffset": component.get("v.rowNumberOffset")
        });
       
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                 console.log("jj"+resultData);
                component.set("v.data", resultData);
              /*
                component.set('v.columns', [
                {label: 'Id', fieldName: 'Id', type: 'text'},
                {label: 'ContactId', fieldName: 'ContactId', type: 'text'},
                {label: 'Contact Name', fieldName: 'Role', type: 'text'}
            ]);
            //Commented here
                
                component.set("v.data", resultData);
                component.set("v.currentCount", component.get("v.initialRows"));
            }
        });
        $A.enqueueAction(action);
    },
     */
    getTotalNumberOfContacts : function(component) {
        var action = component.get("c.getRecords");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var resultData = response.getReturnValue();
                component.set("v.totalNumberOfRows", resultData);
            }
        });
        $A.enqueueAction(action);
    },
     
    getColumnAndAction : function(component) {
        var actions = [
            //{label: 'New', name: 'new'},
           //// {label: 'Edit', name: 'edit'},
          //  {label: 'Delete', name: 'delete'},
            {label: 'View', name: 'view'}
        ];
        component.set('v.columns', [
            {label: 'Name', fieldName: 'ContactName', type: 'text', sortable:true},
            {label: 'Role', fieldName: 'Role', type: 'email', sortable:true},
            {label: 'Email', fieldName: 'ContactEmail', type: 'phone', sortable:true},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
    },
     
    getMoreContacts: function(component , rows){
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = component.get('c.getContactList');
            var recordOffset = component.get("v.currentCount");
            var recordLimit = component.get("v.initialRows");
            action.setParams({
                "recordLimit": recordLimit,
                "recordOffset": recordOffset 
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    var resultData = response.getReturnValue();
                    resolve(resultData);
                    recordOffset = recordOffset+recordLimit;
                    component.set("v.currentCount", recordOffset);   
                }                
            });
            $A.enqueueAction(action);
        }));
    },
     
    sortData: function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse))
        component.set("v.data", data);
    },
     
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
     
    viewContactRecord : function(component, event) {
         console.log("viewContactRecord****"+event);
       // var row = event.getParam('row');
      //  var recordId = row.Id;
       // console.log("Row****"+row);
        // console.log("RoId****"+recordId);
   /*     
        var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        */
    },
     
    deleteContactRecord : function(component, event) {
        var action = event.getParam('action');
        var row = event.getParam('row');
         
        var action = component.get("c.deleteContact");
        action.setParams({
            "con": row
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS" ) {
                var rows = component.get('v.data');
                var rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                component.set('v.data', rows);
                 
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been delete successfully."
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
     
    editContactRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    },
     
    createContactRecord : function (component, event) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Contact"
        });
        createRecordEvent.fire();
    }
    //
    /*
    getData : function(component) {
        var service = component.find("UtilityService");
        service.callServer(component,
            "c.getRecords", ''
        ).
        then($A.getCallback(function(data) {
                console.log('fetched data');
                console.log(data);
            	component.set('v.mydata', response.getReturnValue());
                console.log(response.getReturnValue());
                console.log('response.getReturnValue()');
                var rows= response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
					if (row.Contact) {
					  row.ContactURL = window.location.host+"/"+row.ContactId;
					  row.recordname = row.Contact.Name;
					}
				}
			}))
            .catch($A.getCallback(function(error) {
                console.log('error');
                console.log(error);
            }))
            .then($A.getCallback(function() {
                console.log('All updates Done!!');
            }));
        
        /*var action = cmp.get('c.getRecords');
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                cmp.set('v.mydata', response.getReturnValue());
                console.log(response.getReturnValue());
                console.log('response.getReturnValue()');
                var rows= response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                if (row.Contact) {
                  row.ContactURL = window.location.host+"/"+row.ContactId;
                  row.recordname = row.Contact.Name;
                }
            }
            cmp.set('v.data', rows);

            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
        }));
        $A.enqueueAction(action);
    }// Comment was here
	}
 */
    
})
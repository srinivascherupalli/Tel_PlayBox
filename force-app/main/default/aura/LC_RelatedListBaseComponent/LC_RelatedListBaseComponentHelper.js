({
    callActionAsPromise: function(component, helper, actionName, params) {
        return new Promise($A.getCallback(function(resolve, reject) {
            // let action = component.get(actionName);
            var action = component.get("c.getColumnsAndData");
            action.setParams(params);
            console.log('In Helper');
            action.setCallback(helper, function(actionResult) {
                console.log('In setCallback');
                if (actionResult.getState() === 'SUCCESS') {
                    resolve({'c':component, 'h':helper, 'r':actionResult.getReturnValue()});
                    //resolve(actionResult.getReturnValue());
                  

                } else {
                    console.log('SUCCESSELSE' + actionResult.getError());
                    let errors = actionResult.getError();
                    reject(new Error(errors && Array.isArray(errors) && errors.length === 1 ? errors[0].message : JSON.stringify(errors)));
                }
            });
            $A.enqueueAction(action);
        }));
    },
        Updatecontactrole: function(component, event, helper) {
        var modalBody;
        console.log('Updatecontactrole');
        var flowName='PRM_Update_Contact_Role';
		$A.createComponents([
				["c:PRM_CreateCaseViaFlow", {
					flowName: flowName
                   }]
			],                
			function(modalCmps, status, errorMessage) {
				if (status === "SUCCESS") {
					modalBody = modalCmps[0];
					component.find('overlayLib').showCustomModal({
						body: modalBody,
						showCloseButton: true,
						cssClass: "slds-modal_small",
						closeCallback: function() {
							console.log('modal closed!');
						}
					});
				} else if (status === "ERROR") {
					console.log('ERROR: ', errorMessage);
				}
			}
		)
                		
	},
    
    getContacts: function(component, helper, actionName, params) {
            var actions = [
            { label: 'Edit', name: 'edit' }];
        //label: 'View', name: 'view'
         component.set('v.columns', [
                    { label: 'Id', fieldName: 'Id', type: 'text' },
                    { label: 'ContactId', fieldName: 'ContactId', type: 'text' },
                    { label: 'Contact Name', fieldName: 'Role', type: 'text' },
                    { label: 'Email', fieldName: 'Contact Email', type: 'phone', sortable: true },
                    { type: 'action', typeAttributes: { rowActions: actions } }]);
        var action = component.get("c.getColumnsAndData");
        action.setParams({
            "recordLimit": component.get("v.initialRows"),
            "recordOffset": component.get("v.rowNumberOffset")
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resultData = response.getReturnValue();

           
                component.set("v.data", resultData);
               
                component.set("v.data", resultData);
                component.set("v.currentCount", component.get("v.initialRows"));
            }
        });
        $A.enqueueAction(action);
    },
    sortData: function(cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.data", data);
    },
    sortBy: function(field, reverse, primer) {
        var key = primer ?
            function(x) { return primer(x[field]) } :
            function(x) { return x[field] };
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function(a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    processData:function(component, event, helper,response) {
       
            response = response.r;
                var actions = [
            { label: 'Edit', name: 'edit' },
            { label: 'View', name: 'view' } ];
            var columns =response.columns ;
            var rowAction = { type: "action", typeAttributes: { 'rowActions': actions }};
           // columns.push(rowAction);
         
 		
        var baseurl = window.location.href;
        var url='/partners/s/contact/';
                if (baseurl.includes('partners.enterprise.telstra.com.au')){
                    url='/s/contact/';
                }
				else {
					  url='/partners/s/contact/';
                }
        
       /*  var navService = cmp.find("navService");
                        var pageReference = {
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: record.Id,
                                actionName: 'view'
                            }
                        };
                        navService.generateUrl(pageReference)
                        .then($A.getCallback(function(url) {
                            record.linkName = url ? url : defaultUrl;
                        }));
                        */
            for (var i = 0; i < response.data.length; i++) {
                var row = response.data[i];
                
                if (row.Contact) {
                    row.ContactName = url+row.Contact.Id;
                    row.ContactEmail = row.Contact.Email;
                    row.ContactNameDisplay =row.Contact.Name;
                }
            }
            columns.forEach(function (column) {
          	switch (column.fieldName) {
              case 'ContactName':
                  column.type = 'url';
                  column['typeAttributes'] = { label: { fieldName: 'ContactNameDisplay' }};
                  break;
                  default:
                      break;
              }
        });
            component.set('v.columns', columns);
            component.set('v.data', response.data);
    },
    handleRowAction: function(cmp, event, helper) {

        var action = event.getParam('action');

        var row = event.getParam('row');
		 console.log('handleRowAction',action.name);
       var navEvt = $A.get("e.force:navigateToSObject");

        navEvt.setParams({

            "recordId": row.Id,

            "slideDevName": "detail"

        });

        navEvt.fire();
		/*
        switch ( action.name ) {
            case 'edit':
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                });
                editRecordEvent.fire();
                break;
            case 'view':
                console.log('Action_view',row.Id);
                var viewRecordEvent = $A.get("e.force:navigateToSObject");
                viewRecordEvent.setParams({
                    "recordId": row.Id,
           			 "slideDevName": "detail"
                });
                viewRecordEvent.fire();
                break;
        }
        */
        
    },

})
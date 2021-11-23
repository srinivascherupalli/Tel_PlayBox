({
    init: function(component, event, helper) {
        console.log('calling helper*****');
        var flow = component.find("flowId");
        console.log('calling flow',flow);
        
        
        
        helper.callActionAsPromise(
            component,
            helper,
            'c.getColumnsAndData', {
                'sObjectName': component.get('v.sObjectName'),
                'sObjectFieldsNames': component.get('v.sObjectFieldsNames'),
                'whereClause': component.get('v.whereClause'),
                'relationshipFields': component.get('v.relationshipFields')
            }
        ).then(function(response) {
            helper.processData(component, event, helper,response);
            /*console.log('response*****');
            console.log(response);
            response = response.r;
            var actions = [{ label: 'Show details', name: 'show_details' }];
            var columns =response.columns ;
            var rowAction = { type: "action", typeAttributes: { 'rowActions': actions } };
            //columns.unshift(rowAction);
            console.log(columns);
 		
            for (var i = 0; i < response.data.length; i++) {
                var row = response.data[i];
                if (row.Contact) {
                    row.ContactName = '/partners/s/detail/'+row.Contact.Id;
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
            console.log(response.columns);
            component.set('v.data', response.data);
            */
        })
    },
	loadMoreData: function (cmp, event, helper) {
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        cmp.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(cmp, cmp.get('v.rowsToLoad'))
            .then($A.getCallback(function (data) {
                if (cmp.get('v.data').length >= cmp.get('v.totalNumberOfRows')) {
                    cmp.set('v.enableInfiniteLoading', false);
                    cmp.set('v.loadMoreStatus', 'No more data to load');
                } else {
                    var currentData = cmp.get('v.data');
                    //Appends new data to the end of the table
                    var newData = currentData.concat(data);
                    cmp.set('v.data', newData);
                    cmp.set('v.loadMoreStatus', '');
                }
               event.getSource().set("v.isLoading", false);
            }));
    },
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function(cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        event.getSource().set("v.sortedBy", fieldName);

        event.getSource().set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    handleRowAction: function(cmp, event, helper) {
       
        var action = event.getParam('action');
        console.log('handleRowAction:::',action.name);
        var row = event.getParam('row');
        var navEvt = $A.get("e.force:navigateToSObject");
        console.log(JSON.stringify(row));
        row = JSON.parse(JSON.stringify(row));
       console.log('action.name'+action.name);

         var recordId=row.Id;
       
        /*    var inputVariables = [{name : "RecordId", type: "String", value :recordId}  ];
                        console.log('inputVariables');  
                        console.log(inputVariables);  
                        var flow = component.find("flowData");
                        console.log('::flow'+flow);
          var flowLabel = $A.get("$Label.c.PRM_Channel_Care_Flow_Name");
                        flow.startFlow(flowLabel,inputVariables);
        flow.startFlow("salesup_Create_Sales_Service_Certitude_support_request_Dup",inputVariables);
     */
       
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
                    "recordId": row.ContactId,
           			 "slideDevName": "detail"
                });
                viewRecordEvent.fire();
              break;  
        }
       /*
        if(undefined!== navEvt){
        navEvt.setParams({
            "recordId": row.ContactId,
            "slideDevName": "detail"
        });
        navEvt.fire();
        }
		*/
    },
     Updatecontactrole : function(component, event, helper) {
        helper.Updatecontactrole(component, event, helper);
    },
    
})
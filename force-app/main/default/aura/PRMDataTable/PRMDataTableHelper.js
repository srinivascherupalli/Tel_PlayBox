({
    setData:function(component,data,columns){
        component.set('v.columns',columns);
        component.set('v.columnData',data);
        console.log(component.get("v.columns"));
    },
	getDataHelper : function(component, event) {

        var action = component.get("c.getAccRecords");
        //Set the Object parameters and Field Set name
        action.setParams({
           strObjectName : 'Account',
            strFieldSetName : 'DataTableFieldSet'
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
              component.set("v.columns", response.getReturnValue().lstDataTableColumns);
              component.set("v.columnData", response.getReturnValue().lstDataTableData);
                console.log(response.getReturnValue().lstDataTableColumns);
                console.log(response.getReturnValue().lstDataTableColumns);
                console.log(component.get("v.columns"));
                console.log(component.get("v.columnData"));
            }else if (state === 'ERROR'){
                var errors = response.getError();
                  //System.debug("v.mycolumns"+response.getError());
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }else{
                console.log('Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);	
    	
        var selectedRowsIds = ["0012O000003hMseQAE"];

        // I was expecting the line below to work
        //component.set("v.partnerSelectedRows", selectedRowsIds);

        // Workaround to selectRows
       // component = component.find("PRMDataTable");
      //	component.set("v.selectedRows", selectedRowsIds);
        
    }
})
({
    //Start of Test Code
    doInit : function(component, event, helper) {
        var recordId=component.get("v.recordId");
        var whereClause="OpportunityId='"+recordId+"'";
        console.log(whereClause+'where');
        component.set("v.where",whereClause);
        component.set("v.displayList",false);
          var action=component.get("c.getOpptyStatus");
         action.setParams({
            "opptyId": component.get("v.recordId")                     
        });
        
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") {
                console.log('OpptyStatus'+response.getReturnValue());
                var opptyStatus=response.getReturnValue();
            
                if(opptyStatus =="Approved" || opptyStatus =="Not Applicable")
                {
                   component.set("v.displayList",true);
                }
                component.set("v.displayList",true);
               
            }
            else if(state === "ERROR")
            {
                var errors = response.getError();
                console.error(errors);
               
            }
        });
        $A.enqueueAction(action);
        
        // var action = component.get("c.getIconName");
        // action.setParams({ "sObjectName" :"OpportunityContactRole" });
        // action.setCallback(this, function(response) {
        //    component.set("v.iconName", response.getReturnValue() );
        // });
                   component.set("v.iconName", "/img/icon/t4v35/standard/contact_120.png" );


        //$A.enqueueAction(action);
   //     var actions = [{ label: 'Show details', name: 'show_details' }];
    //       var actions = [
  //           {label: 'New', name: 'new'},
      //      //// {label: 'Edit', name: 'edit'},
      //     //  {label: 'Delete', name: 'delete'},
      //       {label: 'View', name: 'view'}
  //     ];
      //      //  helper.getTotalNumberOfContacts(component);
      // 	// helper.getColumnAndAction(component);
      //   component.set('v.columns', [
      //          	// {label: 'Id', fieldName: 'Id', type: 'text'},
      //       	//	{label: 'ContactId', fieldName: 'ContactId', type: 'text'},
      //       	//{type: 'action', typeAttributes: { rowActions: actions } },
      //       	{label: 'Name', fieldName: 'ContactName', type: 'url',},
      //       	{label: 'Role', fieldName: 'Role', type: 'text'},
      //       	{label: 'Email', fieldName: 'ContactEmail', type: 'text'},
      //        {type: 'action', typeAttributes: { rowActions: actions } }

      //       ]);
      //   console.log('Int'+component);
      // //  helper.getContacts(component);
      //       helper.getData(component);
    },
 handleSectionHeaderClick : function(component, event, helper) {
        var button = event.getSource();
        button.set('v.state', !button.get('v.state'));
        var sectionContainer = component.find('collapsibleSectionContainer');
        $A.util.toggleClass(sectionContainer, "slds-is-open");
    },
    handleLoadMoreContacts: function (component, event, helper) {
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading....');
        helper.getMoreContacts(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length == component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = component.get('v.data');
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', 'Please scroll down to load more data');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },

    handleSelectedRows: function (component, event, helper) {
        var data = component.get('v.data');
        var selectedRowList =  component.get("v.selectedRowsList");
        console.log('selectedRowList-' + selectedRowList);
    },

    handleSelectedRow: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRowsCount", selectedRows.length);
        let obj =[] ;
        for (var i = 0; i < selectedRows.length; i++){
            obj.push({Name:selectedRows[i].Name});
        }
        component.set("v.selectedRowsDetails", JSON.stringify(obj) );
        component.set("v.selectedRowsList", event.getParam('selectedRows'));
    },

    handleLeadSave : function (component, event) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "OpportunityContactRole",
            "OpportunityId": component.get("v.recordId") 
        });
        createRecordEvent.fire();
    },
   
    handleRowAction: function (component, event, helper) {
        console.log("InHandler****handleRowAction");
        var action = event.getParam('action');
        switch (action.name) {
            case 'new':
                helper.createContactRecord(component, event);
                break;
            case 'edit':
                helper.editContactRecord(component, event);
                break;
            case 'delete':
                helper.deleteContactRecord(component, event);
                break;
            case 'view':
                helper.viewContactRecord(component, event);
                break;
        }
    },

    handleColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },

    //END of test code

    /*
   init: function (cmp, event, helper) {
        cmp.set('v.columns', [
                {label: 'Id', fieldName: 'Id', type: 'text'},
                {label: 'Name', fieldName: 'ContactURL', type: 'url',
                  typeAttributes: {
                    label: { fieldName: 'recordname' }
                  }}
            ]);
        helper.getData(cmp);
    },
    */
    loadMoreData: function (component, event, helper) {
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(component, component.get('v.rowsToLoad')).then($A.getCallback(function (data) {
            if (component.get('v.data').length >= component.get('v.totalNumberOfRows')) {
                component.set('v.enableInfiniteLoading', false);
                component.set('v.loadMoreStatus', 'No more data to load');
            } else {
                var currentData = component.get('v.data');
                //Appends new data to the end of the table
                var newData = currentData.concat(data);
                component.set('v.data', newData);
                component.set('v.loadMoreStatus', 'Please wait ');
            }
            event.getSource().set("v.isLoading", false);
        }));
    },

})
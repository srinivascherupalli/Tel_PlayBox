({
    fetchUser : function(component, event, helper) {
        helper.fetchUserHelper(component, event, helper);
    },
    updateSelectedText : function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        var selRowStr = null;
        for (var i = 0; i < selectedRows.length; i++) {
            var row = selectedRows[i];
            if(selRowStr == null) selRowStr = row.ContactId;
            else selRowStr = selRowStr + ',' + row.ContactId;
        }
        component.set("v.selectedRowStr", selRowStr);
        //alert(JSON.stringify(selectedRows));
        //alert(selRowStr);
	}

})
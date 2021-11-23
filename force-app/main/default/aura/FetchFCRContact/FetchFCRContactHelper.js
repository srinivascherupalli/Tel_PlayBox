({
    fetchUserHelper : function(component, event, helper) {
        component.set('v.mycolumns', [
            {label: 'Last Name', fieldName: 'ContactLastName', type: 'text'},
                {label: 'First Name', fieldName: 'ContactFirstName', type: 'text'},
                {label: 'P Number', fieldName: 'P_Number__c', type: 'text'},
                {label: 'Email', fieldName: 'ContactEmail', type: 'Email'}
            ]);
        var action = component.get("c.fetchContact");
        action.setParams({
            "fcrId": component.get("v.fcrId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            //alert(state);
            if (state === "SUCCESS") {
                var usrLst = response.getReturnValue();
                if(usrLst.length > 0){
                    component.set("v.recordExists", 'True');
                }
                else{
                    component.set("v.recordExists", 'False');
                }
                for (var i = 0; i < usrLst.length; i++) {
                    var row = usrLst[i];
                    if (row.Contact){
                        row.ContactLastName = row.Contact.LastName;
                        row.ContactFirstName = row.Contact.FirstName;
                        row.ContactEmail = row.Contact.Email;
                    } 
                }
				//alert(component.get("v.recordExists"));                
                component.set("v.usrList", usrLst);
            }
            //alert(JSON.stringify(usrLst));
        });
        $A.enqueueAction(action);
    }
})
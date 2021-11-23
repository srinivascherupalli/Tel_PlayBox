/*****************************************************************************
@Name: SelectRolesHelper.js
@Author: Shaik Mahaboob Subani
@CreateDate: 20/09/2019
@Description: P2OB-1659. this componet used for quick action to select roles and upate
			  Selection Of Role 
@LastModified:Subani and Sravanthi [P2OB-3297]     
*******************************************************************************/
({
    //To Fetch Roles Data from server side controller
    getRoleData : function(component) {
        var msgFailed = "Failed.";          
        var action = component.get("c.getRolesList");
        action.setCallback(this, function(response) {
            console.log('response... ' + response.getReturnValue());
            if(response.getState() === 'SUCCESS') {
                component.set("v.rolesList", response.getReturnValue());
                component.set("v.rolesList1", response.getReturnValue());
                
                component.set("v.spinner", false);
            } else {
                var errors = response.getError();                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        msgFailed += " Error message: " + errors[0].message;
                    }
                } 
                this.showErrorToast( msgFailed );  
            }
        });
        $A.enqueueAction(action);
    },
    //To Save Selected Record
    saveRoles : function(cmp,evt) {
        cmp.set("v.spinner", true);
        var selectedRadio = cmp.get("v.selectedRadio");
        var action = cmp.get("c.saveSelectedRadio");
        var rolerec = cmp.get("v.rolesList");
        for(var i = 0; i < rolerec.length; i++ ){
            if(rolerec[i].roleId == selectedRadio){
               var rolerecsingle1 = rolerec[i];
            }
        }
        
        action.setParams({
            recordId: cmp.get("v.recordId"), rolerec : JSON.stringify(rolerecsingle1) 
            
        }); 
     
        action.setCallback(this, function(response) { 
            cmp.set("v.spinner", false);
            if(response.getState() === 'SUCCESS') {
                $A.get("e.force:showToast").setParams({ type: "success", title: "Success!", message: 'Role saved successfully' }).fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
            }
            //To handel  Validation Error on Targets Object
            else if (response.getState()  === 'ERROR') {
                let errors = response.getError();
                let message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                    }
                var str = message; 
                var value = str.includes('User Role seems not to be matching with');
                    
                if( Boolean(value)){
                $A.get("e.force:showToast").setParams({ type: "Error", title: "Error!", message:'User Role seems not to be matching with the Role populated on Target record.' }).fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            }  
                else{
                $A.get("e.force:showToast").setParams({ type: "Error", title: "Error!", message:'There is an Error Please contact Administrator' }).fire();
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
                
                }   
                }
        });
        $A.enqueueAction(action);
        
    },
    // To get the Filtered Records. Search Functionality
    filteredRoles : function(component,evt) {

        var rolesList = component.get("v.rolesList");
        var rolesList1 = component.get("v.rolesList1");
        var searchKey = component.get("v.filter");
        if(rolesList!=undefined || rolesList.length>0){
            
            var filtereddata = rolesList1.filter(word => (!searchKey) || word.roleName.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
        }  
        component.set("v.rolesList", filtereddata);
        if(searchKey == ''){
            component.set("v.rolesList", component.get("v.rolesList1"));
        }
    },
    
	// Selected Record setting to attribute. 
    selectedrecord : function(component,evt) {
        var selected = evt.getSource().get("v.text");
        component.set("v.selectedRadio",selected);
    }
})
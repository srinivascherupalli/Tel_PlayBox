({
     doInit: function(component,event,helper) {
        var action=component.get("c.getApprovalList");
        console.log('--- rec id'+component.get("v.Approvelist"));
        console.log(component.get("v.Approvelist"));
        action.setCallback(this, function(response){
        var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.ApprovalList",response.getReturnValue());
                console.log(response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
     handleClickAction: function(component, event, helper){
         helper.handleClickAction(component, event, helper);
        },
     // handleApproveORreject: function(component, event, helper){
     //        console.log('1212');
     //        var vBtname = component.get("v.btnName");
     //     console.log('vBtname ===>'+vBtname);
     //        if(vBtname == 'Approve'){
     //            helper.handleClickApprove(component, event, helper);
     //        }if(vBtname == 'Reject'){
     //            helper.handleClickReject(component, event, helper);
     //        }
     //    },
    handleModalEditLeadOpen: function(component) {
         component.set('v.showModalEditLead', true);
     },
     handleModalEditLeadCancel: function(component) {
         component.set('v.showModalB', false);
         var Cmnts = component.find("Cmnts");
         Cmnts.set("v.errors", null);   // Clear error
         
     },
    handleOpenModalB: function(component, event, helper) {
         component.set('v.showModalB', true);
         var btnClicked = event.getSource();         // the button
         var btnLabel = btnClicked.get("v.label"); // the button's label
         var buttonWorkitemId = btnClicked.get("v.value");
         var btnOpptyId = btnClicked.get("v.name"); 
        //alert('optyId++'+btnOpptyId);
            //event.getSource().getLocalId();
        component.set("v.WorkitemIdval", buttonWorkitemId);
        component.set("v.opptyId", btnOpptyId);
        component.set("v.btnName", btnLabel);
     },
    // handleApproveandReject : function(component, event, helper){
    //     handleClickApprove();
    // },
   // this function automatic call by aura:waiting event
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    
    /* navToRecordController.js */
    handleClickToRecord: function (component,event,helper) {
        console.log('Test handleClickToRecord');
       
        var ctarget = event.currentTarget;
        var id_str = ctarget.dataset.record;
        console.log('rec id'+id_str);
        
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": id_str
        });
        sObjectEvent.fire();
	},

        //var navEvt = $A.get("e.force:navigateToSObject");
        //var oppName= component.find("oppName").get("v.value");
        //var recordId = component.get('c.getOptyId');
             //   console.log('Test handleClickToRecord');

      //  navEvt.setParams({
           // "recordId": component.get("c.getOptyId"),
            //var action=component.get("c.getApprovalList");
            //var recordId = component.get('c.getOptyId');
            //"optyName": component.find("oppName").get("v.value"),
            //"recordId": '0062O000002mqWfQAI'
       // });
        //navEvt.fire();
   // }
    
})
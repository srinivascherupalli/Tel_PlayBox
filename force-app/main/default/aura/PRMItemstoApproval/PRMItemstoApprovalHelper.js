({
    // // really simple function that can be used in every component's helper file to make using promises easier.
    // executeAction: function(cmp, action) {
    //     return new Promise(function(resolve, reject) {
    //         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             if (state === "SUCCESS") {
    //                 var retVal = response.getReturnValue();
    //                 resolve(retVal);
    //                 alert("In helper1");
    //             } else if (state === "ERROR") {
    //                 alert("In helper2");
    //                 var errors = response.getError();
    //                 if (errors) {
    //                     if (errors[0] && errors[0].message) {
    //                         reject(Error("Error message: " + errors[0].message));
    //                     }
    //                 } else {
    //                     reject(Error("Unknown error"));
    //                 }
    //             }
    //         });
    //         $A.enqueueAction(action);
    //     });
    // },
    handleClickAction: function(component, event, helper) {
        console.log('handleClickAction');
        var service = component.find("UtilityService");
        var message = "The record has been Approved successfully.";
        var messageType = 'Success';
        var actionType =  component.get("v.btnName");
        if (actionType == 'Decline') {
            message = "The record has been Rejected successfully.";
            messageType = 'Error';
        }else{
            actionType='Approve';
        }
        var comments = component.find("Cmnts");
        var workItemId = component.get("v.WorkitemIdval");
        var vComments = component.get("v.sComments");
        if (vComments == null || vComments == '') {
            comments.set("v.errors", [{ message: "Please fill comments before saving " }]);
            return false;
        }
        comments.set("v.errors", null);
        // Clear error
        console.log('component.get("v.ApprovalList")');
        console.log(actionType);
        console.log(component.get("v.opptyId"));
        service.callServer(component, 
            "c.handleApprovalAction", {
                workItemId: workItemId,
                sComments: vComments,
                sApprovalType: actionType,
                opptyId:component.get("v.opptyId")
            }
        ).
        then($A.getCallback(function(data) {
            console.log('fetched data');
            // service.showToast(component,messageType + "!", messageType, message);
            helper.showToast(component,messageType + "!",message,messageType);
            // component.set('v.showModalB', false);
        })).catch(function(errors) {
            console.log('error');
            console.log(errors);
            helper.showToast(component,"Exception!" + "!",'Please close this window and contact System Admin!. Message for Admin:'+errors.message,'Error');
            // service.handleShowNotice(this.component,'Something went wrong!','Please close this window and contact System Admin!',errors);
            // service.showToast({
            //             "title": "Exception!",
            //             "message": 'Please close this window and contact System Admin!. Message for Admin:'+errors.message,
            //            "type":"Error"
            //           });
            // component.set('v.showModalB', false);
               //             var toastEvent = $A.get("e.force:showToast");
               // toastEvent.setParams({
               //          "title": ,
               //          "message": ,
               //         "type":"Error"
               //        });
               //  component.set('v.showModalB', false);
               //  $A.get('e.force:refreshView').fire();
            // toastEvent.fire();
        });
        //     var action=component.get("c.handleApprovalAction");
        //       action.setParams({
        //           workItemId : ButValue,
        //           sComments:vComments,
        //           sApprovalType:'Approved'});
        //    action.setCallback(this, function(a) {
        //     if (a.getState() === "SUCCESS")
        //     {
        //        console.log("Save completed successfully.");
        //        var toastEvent = $A.get("e.force:showToast");
        //        toastEvent.setParams({
        //                 "title": "Success!",
        //                 "message": "The record has been Approved successfully.",
        //                "type":"success"
        //               });
        //         component.set('v.showModalB', false);
        //         $A.get('e.force:refreshView').fire();
        //     toastEvent.fire();
        //     } else if (a.getState() === "ERROR")
        //     {
        //         $A.log("Errors", a.getError());
        //     }
        // });
        // $A.enqueueAction(action);
    },
    // handleClickApprove : function(component, event, helper)
    // {
    //     var Cmnts = component.find("Cmnts");
    //     var ButValue=component.get("v.WorkitemIdval");
    //     var vComments = component.get("v.sComments");
    //     if(vComments == null || vComments == ''){
    //         Cmnts.set("v.errors", [{message:"Comments should be filled: "}]);
    //         return false;
    //     } else {
    //         Cmnts.set("v.errors", null);   // Clear error
    //     }
    //     var action=component.get("c.approveRecord");
    //       action.setParams({
    //           workItemId : ButValue,sComments:vComments});
    // action.setCallback(this, function(a) {
    //     if (a.getState() === "SUCCESS")
    //     {
    //        console.log("Save completed successfully.");
    //        var toastEvent = $A.get("e.force:showToast");
    //        toastEvent.setParams({
    //                 "title": "Success!",
    //                 "message": "The record has been Approved successfully.",
    //                "type":"success"
    //               });
    //         component.set('v.showModalB', false);
    //         $A.get('e.force:refreshView').fire();
    //     toastEvent.fire();
    //     } else if (a.getState() === "ERROR")
    //     {
    //         $A.log("Errors", a.getError());
    //     }
    // });
    // $A.enqueueAction(action);
    // },
    // handleClickReject : function(component, event, helper)
    // {
    //     alert('qaqaaaaa');
    //     var Cmnts = component.find("Cmnts");
    //    // var btnClicked = event.getSource();         // the button
    //    // var btnMessage = btnClicked.get("v.label"); // the button's label
    //    // var ButValue = btnClicked.get("v.value");
    //     var ButValue=component.get("v.WorkitemIdval");
    //     var vComments = component.get("v.sComments");
    //     if(vComments == null || vComments == ''){
    //         Cmnts.set("v.errors", [{message:"Comments should be filled: "}]);
    //         return false;
    //     } else {
    //         Cmnts.set("v.errors", null);   // Clear error
    //     }
    //     var action=component.get("c.rejectRecord");
    //       action.setParams({
    //      workItemId : ButValue,sComments:vComments});
    // action.setCallback(this, function(a) {
    //        console.log('aaaaa----'+a.getState());
    //     if (a.getState() === "SUCCESS")
    //     {
    //        console.log("Save completed successfully.");
    //        var toastEvent = $A.get("e.force:showToast");
    //        toastEvent.setParams({
    //                 "title": "Success!",
    //                 "message": "The record has been Rejected successfully.",
    //                "type":"success"
    //               });
    //     component.set('v.showModalB', false);
    //     $A.get('e.force:refreshView').fire();
    //     toastEvent.fire();
    //     component.set('v.showModalB', true);
    //     } else if (a.getState() === "ERROR")
    //     {
    //         $A.log("Errors", a.getError());
    //     }
    // });
    // $A.enqueueAction(action);
    // }
    showToast:function(component,title,message,type){
        $A.get('e.force:refreshView').fire();
        var toastEvent = $A.get("e.force:showToast");
           toastEvent.setParams({
                    "title": title,
                    "message": message,
                   "type":type
                  });
            component.set('v.showModalB', false);
    }
})
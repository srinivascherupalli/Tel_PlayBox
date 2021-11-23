({
    doInit: function(component, event, helper) {
        // Set isModalOpen attribute to true
        //component.find("caseStatus").set("v.value", "New");
        
        
    },
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true getCaseRecord
        //helper structure "getValueFromApex : function(component, event, param, setResponseValue, recordId)"
        component.set("v.showStatus", false);

        component.set("v.messageOpen", false); 
        component.set("v.showButton",true);
        helper.getValueFromApex(component, event , "c.getCaseRecord" ,"v.caseRecord", "v.recordId");
        helper.getValueFromApex(component, event , "c.getCreditAndAdjustmentRecord" ,"v.creditAndAdjustment", "v.recordId");
        helper.getValueFromApex(component, event , "c.getOldStatusValue" ,"v.caseHistory", "v.recordId");
        helper.getValueFromApex(component, event , "c.getQueriedLineItem" ,"v.queriedLineItemBoolean", "v.recordId");
        helper.getValueFromApex(component, event , "c.getAttachmentDetails" ,"v.attachmentBoolean", "v.recordId");        
    },
    
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false 
        component.set("v.showButton",false);
        component.set("v.showStatus", true); 
        component.set("v.isModalOpen", false);
        component.set("v.attachmentModal", false);

        component.set("v.messageOpen", false);
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.find("Modal").submit();
        component.set("v.showButton",false);
        component.set("v.showStatus", true);
        component.set("v.isModalOpen",false);

        component.set("v.messageOpen", true);
    },
    saveRecord: function(component, event, helper) {
        // Set isModalOpen attribute to false
        var caseStatus = component.find("statusValue").get("v.value");
        var determinationStatus = component.get("v.creditAndAdjustment.Determination_Status__c");
        var submitted = component.get("v.creditAndAdjustment.Submitted__c");
        var totalDetermination = component.get("v.caseRecord.Total_Determination__c");
        var previousStatus = component.get("v.caseHistory.NewValue");
        //console.log("Flag: "+component.get("v.queriedLineItemBoolean"));
        //console.log("C&A" +JSON.stringify(component.get("v.creditAndAdjustment")));
        //console.log("Previous Value" +previousStatus);
        if(caseStatus == 'Closed'){
            if(determinationStatus != 'Approved' && component.get("v.creditAndAdjustment") != null  && totalDetermination!=0){

               // console.log("Inside-Closed Not Approved");
                component.set("v.modalBody",$A.get("$Label.c.Case_Close_Modal_Not_Approved"));
                component.set("v.isModalOpen", true);
            }
            else if(determinationStatus == 'Approved' && submitted == false && totalDetermination!=0){
                //console.log("Inside Closed - Approved and Submitted is false");
                component.set("v.modalBody",$A.get("$Label.c.Case_Close_Modal"));
                component.set("v.isModalOpen", true);
            }
                else if(previousStatus != 'Resolved'){

                   // console.log("Inside closed and previous status Not Resolved");

                    component.set("v.modalBody",$A.get("$Label.c.Previous_Case_Status_Modal"));
                    component.set("v.isModalOpen", true);
                }
                    else{

                        component.find("Modal").submit();
                        component.set("v.messageOpen", true);
                        component.set("v.showButton",false);
                        component.set("v.showStatus", true);
                        component.set("v.isModalOpen",false);
                    }
        }
        else if(caseStatus == 'Obtaining Internal Approval' && component.get("v.queriedLineItemBoolean") == true ){
            //console.log("Inside Obtaining Internal Approval");

            component.set("v.modalBody", $A.get("$Label.c.Obtaining_Internal_Approval_Modal"));
            component.set("v.isModalOpen", true);
        }
        
            else if(caseStatus == 'Resolved'){

               // console.log("Inside Resolved");

                if(component.get("v.attachmentBoolean") == false){
                    console.log("Attachment marked as external missing");
                    component.set("v.modalBody",$A.get("$Label.c.Case_Attachment_Modal"));
                    component.set("v.isModalOpen", true);
                }
                else if(component.get("v.attachmentBoolean") == true){

                  //  console.log("Attachment marked as external greater than 1.5 mb");

                    component.set("v.attachmentModalBody",$A.get("$Label.c.Case_Attachment_Size_Modal"));
                    component.set("v.attachmentModal", true);
                }
                    else{

                    //    console.log("inside final else");
                        component.set("v.messageOpen", true);

                        component.set("v.isModalOpen", false);
                        component.find("Modal").submit();
                        component.set("v.showStatus", true);
                        component.set("v.showButton",false);
                    }

            }
                else{
                    component.set("v.messageOpen", true);
                   // console.log("inside FINAL else");

                    //component.set("v.spinner", true);
                    component.set("v.isModalOpen", false);
                    component.find("Modal").submit();
                    component.set("v.showStatus", true);
                    component.set("v.showButton",false);
                }
    },
    onCancel: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.showStatus", true); 
        component.set("v.showButton",false);
    }
})
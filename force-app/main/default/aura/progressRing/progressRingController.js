/*
 ===============================================================================================================================
Class : TransitionReviewConfirmWrapperTest
Developer Name : Rohit
Test Class : TransitionReviewConfirmWrapperTest
===============================================================================================================================
Sr.No.    Developer Name       	Modified  Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     			CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)

===============================================================================================================================
*/
({
	updateView: function(component, event, helper) {
        var variant = component.get("v.variant"),
            hasVariant = variant == "warning" || variant == "expired",
            style = "slds-progress-ring slds-progress-ring_large",
            iconName,
            altText;
        if(hasVariant) {
            style = style ;
            iconName = "utility:"+({ warning: "warning", expired: "info" }[variant]);
            altText = { warning: "Warning", expired: "Expired" }[variant];
        }
        var val = component.get("v.value");
        var valmax = component.get("v.valuemax");
        console.log ('Value---->'+val);
        console.log ('ValueMac---->'+valmax);
        
        var msgcontent = val + "/" + valmax + " Completed";
        console.log('msg contenttt--->'+msgcontent);
        component.set("v.msg", msgcontent);
        component.set("v.ringClass", style);
        component.set("v.hasVariant", hasVariant);
        //component.set("v.iconName", iconName);
        component.set("v.altText", altText)
    }
})
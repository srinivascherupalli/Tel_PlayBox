/******************************************************************************************************************************************
Component Name  :   displayMessageComponentAuraController.js
Created Date    :   5/July/2021
******************************************************** Change Log ***********************************************************************
SL.NO.      Name            Date            Description
1.          Pooja Bhat      5/July/2021     EDGE-221053: B2B-1179 Case Attachment size to be aligned as per T-Connect
*******************************************************************************************************************************************/
({
    doInit : function(component, event, helper) {
        helper.checkFileInfo(component, event, helper);
    }
})
/* ****************************************************************************
Class Name      : SolutionHelperPORPermissionChk
* Author        : Laxmi Rahate : EDGE-142321
* Date          : 21 APR 2020
* Description   : Remote Action Class for checking if Account has Port Out reversal Permissions checks
*******************************************************************************/
global with sharing class SolutionHelperPORPermissionChk implements cssmgnt.RemoteActionDataProvider {

/****************************************************************************************************
* Method Name : getData
* Description : Default method to be overwritten from the Interface to perform Remote Actions
* Parameters  : Map<String, Object>     -   inputMap passed from the JavaScript Plugin
* Return      : Map<String, Object>     -   ReturnMap with the details required for JavaScript Plugin
****************************************************************************************************/
    global Map<String,Object> getData(Map<String,Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();      
		boolean hasCustomPermissionSet=FeatureManagement.checkPermission('Port_Out_Reversal_Permission');
        returnMap.put('hasPortOutReversalPermission', hasCustomPermissionSet);
        return returnMap;
    }
    }
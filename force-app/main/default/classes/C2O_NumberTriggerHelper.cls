/********************************************************************************
* Class Name  : C2O_NumberTriggerHelper
* Description : Number Trigger Helperruns logic on Number records which are filtered
*               based on certain filter conditions which are defined in handler
* Created By  : Dinesh Sekar
* Change Log  : 09 May 2021: Created 
********************************************************************************/
public class C2O_NumberTriggerHelper {

    public static void callEDIS(List<Number__c> recordstoprocess){
        List<String> customstringtoprocess = new List<String>();
        
        for(Number__c num : recordstoprocess){
            String str = num.Status__c+':::'+num.Service_Id__c+':::'+num.Service_Number__c+':::'+num.IsUpdatedFromBatch__c;
            customstringtoprocess.add(str);
        }
        
        if(!customstringtoprocess.isEmpty()){
            EDISSingleManagerUsingNumber.callEDIS(customstringtoprocess);
        }
    }
}
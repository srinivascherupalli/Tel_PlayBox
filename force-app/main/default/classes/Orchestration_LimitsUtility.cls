/**================================================================
* Appirio, Inc
* Name: Orchestration_LimitsUtility
* Description: Class to check the available Salesforce Limits
* Created Date: May 19, 2020
* Created By: Gaurang Maheshwari
==================================================================
Change.No.    Developer Name          Date         Description
1.        Martand Atrey      May 20, 2020  Added the Heapsize check in areLimitsViolated
2.          Arunkumar V     Feb 19, 2021  Added concurrent time limit
==================================================================*/

public without sharing class Orchestration_LimitsUtility {
    //checks the limit is they are violated
    static Long startTime;
    static Long asyncStartTime;
    public static Boolean areLimitsViolated() {
        return checkSoqlLimit() || checkDmlLimit() || checkCpuLimit() || checkHeapSizeLimit() || timeLimit();
    }
   
    
    //checks the async limit is they are violated
    public static Boolean areAsyncLimitsViolated() {
        system.debug('*****Inside areAsyncLimitsViolated()');
        return checkAsyncSoqlLimit() || checkDmlLimit() || checkAsyncCpuLimit() || checkAsyncHeapSizeLimit() || asyncTimeLimit();
    }

    //checks the callout related limit is they are violated
    public static Boolean areCallOutLimitsViolated() {
        return checkSoqlLimit() || checkCalloutLimit() || checkCpuLimit() || checkHeapSizeLimit() || timeLimit();
    }

    //Return the count of process that can be created
    public static Integer getOrchestrationProcessLimit() {
        Integer dmlRowsLimit = Limits.getLimitDmlRows();
        Integer orchProcessRecordsLimit = OrchestratorConstants.SystemConstant.OrchestrationProcessRecordsLimit;

        if (Governor_Limits__c.getInstance().DML_Rows_limit__c != null) {
            dmlRowsLimit = Integer.valueof(Governor_Limits__c.getInstance().DML_Rows_limit__c);
        }
        if (Governor_Limits__c.getInstance().Orchestration_Process_Limit__c != null) {
            orchProcessRecordsLimit = Integer.valueof(Governor_Limits__c.getInstance().Orchestration_Process_Limit__c);
        }
        System.debug('dmlRowsLimit '+dmlRowsLimit);
        System.debug('Limits.getDMLRows() '+Limits.getDMLRows());
        System.debug('orchProcessRecordsLimit '+orchProcessRecordsLimit);
        System.debug('((dmlRowsLimit - Limits.getDMLRows()) / orchProcessRecordsLimit) '+((dmlRowsLimit - Limits.getDMLRows()) / orchProcessRecordsLimit));
        return ((dmlRowsLimit - Limits.getDMLRows()) / orchProcessRecordsLimit);
    }
    
    //Checks the concurrent time limit
    public static Boolean timeLimit(){
    system.debug('startTime ' + startTime);
    if ( startTime == null){
        startTime = system.currentTimeMillis();
        return false;
    }else{
        return ((system.currentTimeMillis() - startTime) > Governor_Limits__c.getInstance().Concurrent_Time_Limit__c);
        }
    }
     //Checks the concurrent time limit
    public static Boolean asyncTimeLimit(){
    system.debug('asyncStartTime ' + asyncStartTime);
    if ( asyncStartTime == null){
       asyncStartTime = system.currentTimeMillis();
       return false;
    }else{
        system.debug('async StartTime ' + system.currentTimeMillis());
        system.debug('asyncstartTime ' + asyncstartTime);
        system.debug('condition  ' + ((system.currentTimeMillis() - startTime) >  Governor_Limits__c.getInstance().Async_Time_Limit__c));
        return ((system.currentTimeMillis() - asyncStartTime) > Governor_Limits__c.getInstance().Async_Time_Limit__c);
        }
    }
 
    //checks if the current soql is less than the Governor Limits custom setting
    public static Boolean checkSoqlLimit() {
        Boolean ret = false;
        Integer soqlNum = Limits.getQueries();
        Integer soqlLimit = Limits.getLimitQueries();
        if (Governor_Limits__c.getInstance().SOQL_limit__c != null) {
            soqlLimit = Integer.valueof(Governor_Limits__c.getInstance().SOQL_limit__c);
        }
        if (soqlNum > soqlLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    //checks if the current soql is less than the Governor Limits custom setting
    public static Boolean checkAsyncSoqlLimit() {
        Boolean ret = false;
        Integer soqlNum = Limits.getQueries();
        Integer soqlLimit = Limits.getLimitQueries();

        if (Governor_Limits__c.getInstance().Async_SOQL_limit__c != null) {
            soqlLimit = Integer.valueof(Governor_Limits__c.getInstance().Async_SOQL_limit__c);
        }
        if (soqlNum > soqlLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    //checks if the current dml is less than the Governor Limits custom setting
    public static Boolean checkDmlLimit() {
        Boolean ret = false;
        Integer dmlNum = Limits.getDMLStatements();
        Integer dmlLimit = Limits.getLimitDMLStatements();
        
        if (Governor_Limits__c.getInstance().DML_limit__c != null) {
            dmlLimit = Integer.valueof(Governor_Limits__c.getInstance().DML_limit__c);
        }
        if (dmlNum > dmlLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }
    
    

    //checks if the current callout is less than the Governor Limits custom setting
    public static Boolean checkCalloutLimit() {
        Boolean ret = false;
        Integer calloutNum = Limits.getCallouts();
        Integer calloutLimit = Limits.getLimitCallouts();
        if (Governor_Limits__c.getInstance().Call_Out_limit__c != null) {
            calloutLimit = Integer.valueof(Governor_Limits__c.getInstance().Call_Out_limit__c);
        }

        if (calloutNum > calloutLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    //checks if the current cpu is less than the Governor Limits custom setting
    public static Boolean checkCpuLimit() {
        Boolean ret = false;
        Integer cpuNum = Limits.getCpuTime();
        Integer cpuLimit = Limits.getLimitCpuTime();
        if (Governor_Limits__c.getInstance().CPU_limit__c != null) {
            cpuLimit = Integer.valueof(Governor_Limits__c.getInstance().CPU_limit__c);
        }

        if (cpuNum > cpuLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }
    
    //checks if the current cpu is less than the Governor Limits custom setting
    public static Boolean checkAsyncCpuLimit() {
        Boolean ret = false;
        Integer cpuNum = Limits.getCpuTime();
        Integer cpuLimit = Limits.getLimitCpuTime();
        if (Governor_Limits__c.getInstance().Async_CPU_limit__c != null) {
            cpuLimit = Integer.valueof(Governor_Limits__c.getInstance().Async_CPU_limit__c);
        }

        if (cpuNum > cpuLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    //Check if the current heap size is less than the Governor Limits in Custom Settings
    public static Boolean checkHeapSizeLimit() {
        Boolean ret = false;
        Integer heapSize = Limits.getHeapSize();
        Integer heapSizeLimit = Limits.getLimitHeapSize();
        if (Governor_Limits__c.getInstance().Heap_Size_Limit__c != null) {
            heapSizeLimit = Integer.valueOf(Governor_Limits__c.getInstance().Heap_Size_Limit__c);
        }

        if (heapSize > heapSizeLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }
    
    //Check if the current heap size is less than the Governor Limits in Custom Settings
    public static Boolean checkAsyncHeapSizeLimit() {
        Boolean ret = false;
        Integer heapSize = Limits.getHeapSize();
        Integer heapSizeLimit = Limits.getLimitHeapSize();
        if (Governor_Limits__c.getInstance().Async_Heap_Size_LImit__c != null) {
            heapSizeLimit = Integer.valueOf(Governor_Limits__c.getInstance().Async_Heap_Size_LImit__c);
        }

        if (heapSize > heapSizeLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }

    //checks if the current dml rows is less than the Governor Limits custom setting
    public static Boolean checkDmlRowsLimit() {
        Boolean ret = false;
        Integer dmlRowsnum = Limits.getDMLRows();
        Integer dmlRowsLimit = Limits.getLimitDMLRows();
        if (Governor_Limits__c.getInstance().DML_Rows_limit__c != null) {
            dmlRowsLimit = Integer.valueof(Governor_Limits__c.getInstance().DML_Rows_limit__c);
        }
        if (dmlRowsnum > dmlRowsLimit) {
            ret = true;
        } else {
            ret = false;
        }
        return ret;
    }
}
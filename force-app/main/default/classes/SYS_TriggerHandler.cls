/**
* Trigger Framework
*
* This trigger framework bundles a single TriggerHandler base class that you can inherit from trigger handlers. 
* The base class includes context-specific methods that are automatically called when a trigger is executed.
* Base class also provides a secondary role as a supervisor for Trigger execution. 
* It acts like a watchdog, monitoring trigger activity and providing an api for controlling certain aspects of 
* execution and control flow.
*
* @author   Nandan Narasappa/Sharath Krishnaraj
* @version  1.0
* @since    25/03/2021 
*
* @credits  Kevin O'hara
* @link     https://github.com/kevinohara80/sfdc-trigger-framework
* 
*  Version History
* ----------------------------
* Change Log   |    Date            |       Change Description
* 1.1           24/08/2021              Changed Implementation for addToLoopCount - execute trigger logic even if LOOP_MAX_VALUE exceeded, but log such deviations in Exception Log
*/
public virtual class SYS_TriggerHandler{

    // Default Trigger Handler execution set to run once
    @TestVisible private static final Integer LOOP_MAX_VALUE = 10;// assuming we proccess 2,000 records, 200 at a time
    private static final String DEF_BYPASS_PERM = 'SYS_Bypass_Triggers'; 
    private static final String ERR_CATEGORY = 'Technical';
    private static final String METH_ADDTOLOOPCOUNT = 'addToLoopCount';
    private static final String EXP_BUSSINESS_DESCRIPTION = 'Trigger By-passed due to maximum recursion.';
    private static final String MSG_MAX_COUNT_REACHED = 'Maximum Excecution Reached for {0} object. \n Count : {1}  \n Event Handler : {2} \n Execution Time : {3} ms \n Record Ids : {4}';

    private static final Map<String, String> SEVERITY_MAP = new Map<String, String>{    
        'FATAL' =>'1',
        'ERROR' => '2',
        'WARNING' => '3',
        'INFO' => '4'
    }; 

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    private static String bypassPermission;
    private String handlerName;

    private String sObjectType; 
    private Long startTime; // start time of the trigger execution in milliseconds
    private Long endTime;   // time when max count reached in milliseconds
    
    // the current context of the trigger, overridable in tests
    @TestVisible private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible private Boolean isTriggerExecuting;

    // static initialization 
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        bypassPermission = DEF_BYPASS_PERM;
    }

    @TestVisible
    //Sudheendra: Constructor to set the trigger context and populate the objectType based on the trigger data. 
    //TO DO : Deprecate this. String.valueOf(Trigger.new.getSObjectType()) does NOT help with performance of Trigger
       public SYS_TriggerHandler(){
        if(Trigger.isExecuting){
            SObjectType triggerType = Trigger.isDelete ? Trigger.old.getSObjectType() : Trigger.new.getSObjectType();
            this.sObjectType = String.valueOf(triggerType);   
        }
        this.setTriggerContext();
    }

    // Pass the Constructor name from TiggerHandler
    public SYS_TriggerHandler(String sObjectType) {
        this.sObjectType = sObjectType;
        this.setTriggerContext();
    }
    


    // main method that will be called during execution
    public void run() {
        startTime = DateTime.now().getTime();   // capture start time in milliseconds

        if(!validateRun()){
            return;
        }
        //add to counter & log
        addToLoopCount();
    
        // dispatch to the correct handler method
        if(this.context == TriggerContext.BEFORE_INSERT) {
          this.beforeInsert();
        } 
        else if(this.context == TriggerContext.BEFORE_UPDATE) {
          this.beforeUpdate();
        }
        else if(this.context == TriggerContext.BEFORE_DELETE) {
          this.beforeDelete();
        } 
        else if(this.context == TriggerContext.AFTER_INSERT) {
          this.afterInsert();
        } 
        else if(this.context == TriggerContext.AFTER_UPDATE) {
          this.afterUpdate();
        } 
        else if(this.context == TriggerContext.AFTER_DELETE) {
          this.afterDelete();
        } 
        else if(this.context == TriggerContext.AFTER_UNDELETE) {
          this.afterUndelete();
        }
    }

    public Map<String, LoopCount> getLoopCountMap(){
        return SYS_TriggerHandler.loopCountMap;
    }
    
    //set Handler name explicitly
    public void setHandlerName(String handler){
        handlerName = handler;
    }

    // set the count for handler
    public void setMaxLoopCount(Integer max) {
        String eventHandlerName = getEventHandlerName();
        if(!SYS_TriggerHandler.loopCountMap.containsKey(eventHandlerName)) {
            SYS_TriggerHandler.loopCountMap.put(eventHandlerName, new LoopCount(max));
        } 
        else {
            SYS_TriggerHandler.loopCountMap.get(eventHandlerName).setMax(max);
        }
    }
    
    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /** public static methods **/

    public static void bypass(String handlerName) {
        SYS_TriggerHandler.bypassedHandlers.add(handlerName);
    }
    
    public static void clearBypass(String handlerName) {
        SYS_TriggerHandler.bypassedHandlers.remove(handlerName);
    }
    
    public static Boolean isBypassed(String handlerName) {
        return SYS_TriggerHandler.bypassedHandlers.contains(handlerName);
    }
    
    public static void clearAllBypasses() {
        SYS_TriggerHandler.bypassedHandlers.clear();
    }

    /** private instance methods **/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if(!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } 
        else {
            this.isTriggerExecuting = true;
        }
        
        if((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
            (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } 
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
            (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        } 
        else if((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
            (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } 
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
            (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } 
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
            (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } 
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
            (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } 
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
            (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private Boolean addToLoopCount() {
        Boolean retVal = true;
        String eventHandlerName = getEventHandlerName(); // fetch the event & the handler combination

        if(SYS_TriggerHandler.loopCountMap.containsKey(eventHandlerName)) {
            LoopCount eventHandlerLoopCount = SYS_TriggerHandler.loopCountMap.get(eventHandlerName);
            Boolean exceeded = eventHandlerLoopCount.increment();
            // Log msgs if counter > LOOP_MAX_VALUE in Exception object, however, do NOT stop execution
            if(exceeded) {
                endTime = DateTime.now().getTime(); // capture end time
                Long executionTime = endTime - startTime;   // execution time in milliseconds
                Object recordIds = (this.isTriggerExecuting && Trigger.newMap != null) ? Trigger.newMap.keyset() : null;
                
                // e.g : Maximum Excecution Reached for Case object, count : 2 , Event Handler : AC_CaseTriggerHandler_BEFORE_INSERT, Execution Time : 200ms, RecordIds : 
                String errorMessage = String.format(MSG_MAX_COUNT_REACHED, 
                                                    new List<Object>{this.sObjectType,eventHandlerLoopCount.count,eventHandlerName,executionTime,
                                                                        recordIds});
                                                                      
                String newGUID = GuidUtil.NewGuid();
                Map<String,Object> inputMap = new Map<String,Object>();
                inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH);
                inputMap.put('capability', C2O_ExceptionHandler.Capability.SYS_TRG);
                inputMap.put('interfaceName', SYS_TriggerHandler.METH_ADDTOLOOPCOUNT);
                inputMap.put('errorDescription', errorMessage);
                inputMap.put('correlationId', GuidUtil.NewGuid());
                C2O_Utilities.logException(inputMap,false);
            }
        }
        else{
            SYS_TriggerHandler.loopCountMap.put(eventHandlerName, new LoopCount(LOOP_MAX_VALUE));
            SYS_TriggerHandler.loopCountMap.get(eventHandlerName).increment();
        }
        return retVal;
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        Boolean isValid = true;
        System.debug('Trigger::Executing:'+this.isTriggerExecuting);
        System.debug('Trigger::context:'+this.context);
        if(!this.isTriggerExecuting || this.context == null) {
            isValid = false;
        }
        // by pass trigger if handler is bypassed explicitly or through permission or environment configuration  
        if(SYS_TriggerHandler.bypassedHandlers.contains(getHandlerName()) || checkPermission() || checkObjectSetting() ) {
            isValid = false;
        }
        return isValid;
    }

    @TestVisible
    private Boolean checkPermission() {
        return FeatureManagement.checkPermission(SYS_TriggerHandler.bypassPermission);
    }

    @TestVisible
    private Boolean checkObjectSetting(){
        Boolean isTriggerDisabled = false;
        Environment_Configurations__c  envConfiguration = Environment_Configurations__c.getInstance();
        if(envConfiguration != null && envConfiguration.No_Triggers__c){
            isTriggerDisabled = true;
        }
        return isTriggerDisabled;
    }

    @TestVisible
    private String getEventHandlerName() {
        return (getHandlerName() + '_' + this.context);  // eg: AC_CaseTriggerHandler_BEFORE_INSERT
    }

    @TestVisible
    private String getHandlerName() {
        if(handlerName == null){
            String fullContext = String.valueOf(this);
            handlerName = fullContext.substring(0,fullContext.indexOf(':'));
            
        }
        return handlerName;
    }

    /** context methods for override **/
    @TestVisible protected virtual void beforeInsert(){}
    @TestVisible protected virtual void beforeUpdate(){}
    @TestVisible protected virtual void beforeDelete(){}
    @TestVisible protected virtual void afterInsert(){}
    @TestVisible protected virtual void afterUpdate(){}
    @TestVisible protected virtual void afterDelete(){}
    @TestVisible protected virtual void afterUndelete(){}

    /** Inner classes **/
    @TestVisible
    public class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = LOOP_MAX_VALUE;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            if(this.max < 0){
                return false;
            } 
            if(this.count > this.max) {
                return true;
            }
            return false;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

}
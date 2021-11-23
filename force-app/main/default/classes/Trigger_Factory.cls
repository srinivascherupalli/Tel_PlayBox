/*
Class Name : Trigger_Factory
Description  : This is the common class for all the trigger handler classes, it iterates 
               the Trigger values and pass them to respective handler classes.
Created By   : ABINASH BARIK
Created On   : 

Change History:
----------------------------------------------------------------------------------------------------------------------
Sr#      Description                     Updated By                         Updated On            EMP ID
----------------------------------------------------------------------------------------------------------------------

*/

/**
 * Class Trigger_Factory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 */
public with sharing class Trigger_Factory
{ 
    private static String handlerName = '';
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a TriggerException if no handler has been coded.
     */
    public static void createHandler(Schema.sObjectType soType)
    {
        system.debug('Inside createHandler');
        // Get a handler appropriate to the object being processed
        //ITrigger handler = getHandler(soType);
         
        // Execute the handler to fulfil the trigger
        //execute(handler);
        system.debug('soType>>>>>>'+soType);
        if (System.label.Trigger_Active.EqualsIgnoreCase(System.Label.true)) {
            system.debug('Inside soType>>>>>>'+soType);
            handlerName = String.valueOf(soType);
            ITrigger handler = getHandler(soType);
            system.debug('Inside handler>>>>>>'+handler);
            if(handler!=null){ 
            	execute(handler);
            } 
        }
    }
     
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */
    private static void execute(ITrigger handler)
    {
        try
        {
            // Before Trigger
            if (Trigger.isBefore)
            {
                // Call the bulk before to handle any caching of data and enable bulkification
                handler.bulkBefore();
                
                // Iterate through the records to be deleted passing them to the handler.
                if (Trigger.isDelete)
                {
                    for (SObject so : Trigger.old)
                    {
                        system.debug(so);
                        handler.beforeDelete(so);
                    }
                }
                // Iterate through the records to be inserted passing them to the handler.
                else if (Trigger.isInsert)
                {
                    for (SObject so : Trigger.new)
                    {
                        handler.beforeInsert(so);
                    }
                }
                // Iterate through the records to be updated passing them to the handler.
                else if (Trigger.isUpdate)
                {
                     
                    for (SObject so : Trigger.old)
                    {
                       handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
            }
            else
            {
                // Call the bulk after to handle any caching of data and enable bulkification
                handler.bulkAfter();
                 
                // Iterate through the records deleted passing them to the handler.
                if (Trigger.isDelete)
                {
                    for (SObject so : Trigger.old)
                    {
                        handler.afterDelete(so);
                    }
                }
                // Iterate through the records inserted passing them to the handler.
                else if (Trigger.isInsert)
                {
                    for (SObject so : Trigger.new)
                    {
                        handler.afterInsert(so);
                    }
                }
                // Iterate through the records updated passing them to the handler.
                else if (Trigger.isUpdate)
                {
                    for (SObject so : Trigger.old)
                    {
                        handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
            }
             
            // Perform any post processing
            handler.andFinally();
        }catch(Exception e){
            if(handlerName == null)
                handlerName = '';
            //system.debug('handlerName*******'+handlerName);
            if(handlerName != 'User'){ 
                String msg =  e.getMessage() +'\n' + e.getStackTraceString()  ;  
                // TODO Create an object and store all run time execution exceptions
            }
        }
    }
     
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    private static ITrigger getHandler(Schema.sObjectType soType)
    {
        system.debug('soType>>>' + soType);
        system.debug('soType>>>' + String.valueOf(soType));
        
        try{
            ITrigger classObj = getObjectHandlerInstance.getCurrentObjectHandlerClass(String.valueOf(soType));
            return classObj;
        }
        catch(Exception e){
            system.debug(e);
        } //skip bad name silently
		return null;
    }
}
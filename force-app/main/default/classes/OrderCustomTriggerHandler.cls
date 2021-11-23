/******************************************************************************************************
Class Name: OrderCustomTriggerHandler
Decription: Hanlder class Invoked from OrderTriggerCustom
Test Class: OrderCustomTriggerHandlerTest
=======================================================================================================   
Sr.No.      Developer Name          Date            Story           Description
1.          Jagadeswary             31/3/21         EDGE-209486     Publish new platform event
2.          Gokul                   14/05/21        EDGE-215986     Post chatter notification based on order status
3.          Gokul                   02/06/21        EDGE-222343     Avoid recursion from order Trigger
4.          Aman Soni/Payal         02/06/21        DIGI-16594      Though the orders are completed in phoenix , the completion status in not flowing to tnow for few of them
**************************************************************************************************/
public with sharing class OrderCustomTriggerHandler{
    @testVisible private static List<OrderGenerationMSEvent__e> orderEventList = new List<OrderGenerationMSEvent__e>();
    @testVisible private static boolean testException = false;
    static String CONST_INTERFACENAME = 'OrderCustomTriggerHandler';
    static String correlationId = GuidUtil.NewGuid();
    public static boolean isRecursive = false;//EDGE-222343
    //Method to publish orderGeneration event on status change
    public static void generateOrderMSEvent(List<csord__Order__c> orderNewList,Map<Id,csord__Order__c> oldMap){	
		//Added by Aman Soni for DIGI-16594	|| Start
		List<csord__Order__c> orderUpdatedList = new List<csord__Order__c>();
		String orderInitialState = csordtelcoa__Orders_Subscriptions_Options__c.getInstance().csordtelcoa__Order_Initial_State__c;
			for(csord__Order__c orderObj : orderNewList){
				if(orderObj.csord__Status2__c != oldMap.get(orderObj.id).csord__Status2__c && oldMap.get(orderObj.id).csord__Status2__c !=null && orderObj.csord__Status2__c !=orderInitialState){
					orderUpdatedList.add(orderObj);				
				}
			}
		//Added by Aman Soni for DIGI-16594	|| End
		
        //EDGE-222343 || Added orderUpdatedList check and in SOQL query for DIGI-16594
        if(!isRecursive & !orderUpdatedList.isEmpty()){
            isRecursive = true;
			//Commented by Aman Soni for DIGI-16594
            //String orderInitialState = csordtelcoa__Orders_Subscriptions_Options__c.getInstance().csordtelcoa__Order_Initial_State__c;
            try{
                for(csord__Order__c order: [select id,csord__Account__r.CIDN__c,csord__Order_Number__c,csord__Status2__c,referenceNumber__c from csord__Order__c where id in:orderUpdatedList]){
					//Commented by Aman Soni for DIGI-16594
                    //if(order.csord__Status2__c != oldMap.get(order.id).csord__Status2__c && oldMap.get(order.id).csord__Status2__c !=null && order.csord__Status2__c !=orderInitialState){                      
                        orderEventList.add(OrderCustomTriggerHelper.createEvent(order));
                    //}
                }
                
                if(Test.isRunningTest() && testException){
                    Integer i=1/0;
                }
                if(!orderEventList.isEmpty()){
                    List<Database.SaveResult> results = EventBus.publish(orderEventList);
                    for(Database.SaveResult sr : results){
                        if(!sr.isSuccess()){
                            for(Database.Error err : sr.getErrors()){
                                GenericUtilityClass.logException('OrderCustomTriggerHandler','generateOrderMSEvent','',correlationId,err.getMessage() + '-' + err.getStatusCode(),'Exception occured during order event publishing',C2O_ExceptionHandler.Capability.ORD);
                            }
                        }       
                    }
                }  
            }
            catch(Exception e){
                GenericUtilityClass.logException('OrderCustomTriggerHandler','generateOrderMSEvent','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured during order event publishing',C2O_ExceptionHandler.Capability.ORD);
            }
        }
    }

    /***********************************************************************************************************************
    Method Name:  postChatterNotification
    Description:  Post chatter notification based on order status. This method is called from OrderCustomTrigger
    Story      :  Edge-215986
	*************************************************************************************************************************/     
    public static void postChatterNotification(List<csord__Order__c> orderNewList,Map<Id,csord__Order__c> oldOrderMap){
        Sync_Control_and_Constants__c syncConstMap = new Sync_Control_and_Constants__c();
        try{
            syncConstMap = Sync_Control_and_Constants__c.getValues('Order_Chatter_Notification');
            OrderCustomTriggerHelper.postChatterNotification(orderNewList,oldOrderMap,syncConstMap);
        }catch(Exception e) {
            GenericUtilityClass.logException(CONST_INTERFACENAME,'postChatterNotification','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while posting chatter notification',C2O_ExceptionHandler.Capability.ORD);          
        }       
    }
}
/**********************************************************************************************
@description: Order Generation helper to be used to call the order generation apis through apex
@Test: OrderBifurcationFramework_Test 
***********************************************************************************************/

public without sharing class OrderGenrationHelper{
    
    public static void orderGenerationDecision(List<Opportunity> ChangedOppList,Map<Id,Opportunity> oldMapOpps){
            csordtelcoa__Orders_Subscriptions_Options__c onsOptions = csordtelcoa__Orders_Subscriptions_Options__c.getInstance();
            //system.debug('onsOptions ---<><><> '+onsOptions);
            if(onsOptions.csordtelcoa__Initiate_order_generation_manually__c){
                orderGenrationHelper.orderGenerationStrategyRedirection(ChangedOppList, oldMapOpps, onsOptions);
            }
    }

    private static void orderGenerationStrategyRedirection(List<Opportunity> ChangedOppList,Map<Id,Opportunity> oldMapOpps, csordtelcoa__Orders_Subscriptions_Options__c onsOptions){
        List<Id> tempopportunityIds = new List<Id>();
        try{
            order_Utilites__c orderUtilSetting = order_Utilites__c.getInstance();
            
            List<order_decomposition_request__e> orderDecomposeEvents= new list<order_decomposition_request__e>();
            if(orderUtilSetting.Use_Platform_Event__c){
                for(opportunity opp: ChangedOppList){
                    if(!onsOptions.csordtelcoa__Opportunity_Stages_creating_orders__c.contains(oldMapOpps.get(opp.Id).StageName) && onsOptions.csordtelcoa__Opportunity_Stages_creating_orders__c.contains(opp.StageName) && opp.Product_Type__c == 'Modular'){
                        tempopportunityIds.add(opp.Id);
                        orderDecomposeEvents.add(new order_decomposition_request__e(Opportunity_Id__c=opp.Id));   
                    }
                }
                //Publish the event
                OrderGenrationHelper.publishOrderDecompositionEvents(orderDecomposeEvents, tempopportunityIds);
            }
            else{
                
                for(opportunity opp: ChangedOppList){
                if(!onsOptions.csordtelcoa__Opportunity_Stages_creating_orders__c.contains(oldMapOpps.get(opp.Id).StageName) && onsOptions.csordtelcoa__Opportunity_Stages_creating_orders__c.contains(opp.StageName) && opp.Product_Type__c == 'Modular'){
                    tempopportunityIds.add(opp.Id);
                }
                }
                OrderGenerationAPIInvoker.orderGeneration(tempopportunityIds, orderUtilSetting);    
                
            }
        }catch(exception e){
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('orderGenerationStrategyRedirection', tempopportunityIds, correlationId, e.getMessage(), 'orderGenerationStrategyRedirection method failure, please check error description' );
        }
        
    }
    
    public static void publishOrderDecompositionEvents(List<order_decomposition_request__e> orderDecomposeEvents, List<Id> tempopportunityIds){
        try{
            List<Database.SaveResult> results = EventBus.publish(orderDecomposeEvents);   
            for(Database.SaveResult sr: results) {
                if(!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        String correlationId = GuidUtil.NewGuid();
                        orderBifurcationExceptionHandler.logException('orderGenerationStrategyRedirection', tempopportunityIds, correlationId, err.getStatusCode() + ' - ' + err.getMessage(), 'Failure in publishing events for order generation' );
                    }
    
                }       
            }
        }catch(exception e){
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('publishOrderDecompositionEvents', tempopportunityIds, correlationId, e.getMessage(), 'publishing order decomposition events failed, orders cannot be generated for this request' );
        }
        
    }

}
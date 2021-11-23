/**********************************************************************************************
@description: OrderGenerationAPIInvoker, this class implements methods to invoke APIs and internally 
decide whether to invoke them in sync or async mode
@Test: OrderBifurcationFramework_Test
***********************************************************************************************/

public without sharing class OrderGenerationAPIInvoker {
    
    public static void orderGenerationAPIInvokerDecision(Boolean isFutureEnabled, List<Id> opportunityIds, Boolean isAsync){
        try{
            if(isFutureEnabled && !isAsync){
                orderGenerationInFutureMethod(opportunityIds);
            }else {
                csordtelcoa.API_V1.generateOrdersFromOpportunities(opportunityIds, isAsync);

            }
        }catch(exception e){
            
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('orderGenerationAPIInvokerDecision', opportunityIds , correlationId, e.getMessage(), 'Order Generation decision making block failed. If async mode is used Opportunity update may have failed' );
        }
    }
    
    @future
    private static void orderGenerationInFutureMethod(List<Id> opportunityIds){
        try{
            //if(!test.isRunningTest()) {
                csordtelcoa.API_V1.generateOrdersFromOpportunities(opportunityIds, false);
            //}
        }catch(exception e){
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('orderGenerationInFutureMethod', opportunityIds, correlationId, e.getMessage(), 'Order Generation API failure, please check error description' );
        }

    }
     
    @InvocableMethod(label='Order Generation API')
    public Static void generateOrderCustom(List<Id> tempopportunityIds){
            order_Utilites__c orderUtilSetting = order_Utilites__c.getInstance();
            orderGenerationAPIInvoker.orderGeneration(tempopportunityIds, orderUtilSetting);
    } 
    
    public static void orderGeneration(List<Id> tempopportunityIds, order_Utilites__c orderUtilSetting ){
        try{
            Map<Id, boolean> oppForAsyncOG = new Map<Id, boolean>();
            //modified by Ashish Agrawal (05-10-2021)
            Integer limitQuery = 0;
            limitQuery = (Integer)orderUtilSetting.basket_size_for_bifurcation__c +1;
            system.debug('integer.   ' + limitQuery);
            for(cscfga__product_basket__c basket: [Select Id, cscfga__Opportunity__c, (Select Id from cscfga__Product_Configurations__r limit :limitQuery) from cscfga__product_basket__c where cscfga__Opportunity__c IN: tempopportunityIds and csordtelcoa__Synchronised_with_Opportunity__c = true]){
                if(basket.cscfga__Product_Configurations__r.size()> orderUtilSetting.basket_size_for_bifurcation__c){
                    oppForAsyncOG.put(basket.cscfga__Opportunity__c, true);
                }else{
                    oppForAsyncOG.put(basket.cscfga__Opportunity__c, false);
        
                }
            }
            for(Id oppId: oppForAsyncOG.keyset()){
                List<Id> opportunityIds = new List<Id>();
                opportunityIds.add(oppId);
                system.debug('orderUtilSetting for loop ---<><><>'+opportunityIds+'  '+orderUtilSetting.Use_Future_Method_for_Order_Generation__c+'  '+ oppForAsyncOG.get(oppId));
                orderGenerationAPIInvoker.orderGenerationAPIInvokerDecision( orderUtilSetting.Use_Future_Method_for_Order_Generation__c, opportunityIds, oppForAsyncOG.get(oppId));
            }
        }catch(exception e){
            String correlationId = GuidUtil.NewGuid();
            orderBifurcationExceptionHandler.logException('orderGeneration', tempopportunityIds, correlationId, e.getMessage(), 'Order Generation logic failed while calculating basket size' );
        }
        
        
    }   
}
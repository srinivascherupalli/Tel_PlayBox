/**================================================================
Name: AdditionalBillPayloadGenerator
Description:  class to generate payload of muliple subscriptions for coba
Created Date: April 28, 2021
Created By: Prajakta patil
1. Prajakta    17/05/2021   EDGE-218310 COBA Fix
2. Prajakta    22/06/2021   EDGE-226097 Fix
==================================================================*/

public with sharing class AdditionalBillPayloadGenerator extends BillingUtility {
    
    public static String Payload = ''; 
    public static String handlerName = 'PostSubscriptionHandler'; 
    
    public AdditionalBillPayloadGenerator (List<Id> subscriptionIds, boolean isIncludeSolution, boolean isProductExpire, String handlerName, String targetBAN){
        super(subscriptionIds,isIncludeSolution,isProductExpire,handlerName);
        
    }
    
    public override void addSpecificToBuildBillPayload(csord__subscription__c subscription, BillingSpecDTOV2 billingSpecDTOV2,String solutionsubNumber,String scenarioType, String targetBAN) {
        
        system.debug('billingSpecDTOV2:'+billingSpecDTOV2);
        try{

            if(scenarioType!= null && scenarioType.equalsIgnoreCase('COBA') ){
        
        billingSpecDTOV2.requestType = null; // EDGE-226097 Fix
        
                billingSpecDTOV2.billingAccountNumber = Long.valueOf(targetBAN);
                
                billingSpecDTOV2.fromBillingAccountNumber = Long.valueOf(subscription.Billing_Account__r.Billing_Account_Number__c);
                
                billingSpecDTOV2.productActionType = 'modify';
                
                billingSpecDTOV2.ProductOffering.fromOfferInstanceId = solutionsubNumber; // EDGE-226097 Fix
                
                List<BillingSpecDTOV2.OrderItems> orderItemsList= billingSpecDTOV2.orderItems; 
                List<BillingSpecDTOV2.OrderItems> updatedorderItemsList = new List<BillingSpecDTOV2.OrderItems>();
                
                if(orderItemsList!=null)
                {
                   
                    for( BillingSpecDTOV2.OrderItems billingOrderItemDataObject :orderItemsList){
                        
                    List<BillingSpecDTOV2.BillingSpecifications> recurringbillingSpecs = new List<BillingSpecDTOV2.BillingSpecifications>();
        
                        billingOrderItemDataObject.productActionType = 'modify';
                        billingOrderItemDataObject.scenarioType = scenarioType;
                        
                        List<BillingSpecDTOV2.ProductCharacteristics> prodcharList = billingOrderItemDataObject.productCharacteristics;
                        
                        if(prodcharList!=null) 
                        {
                            for( BillingSpecDTOV2.ProductCharacteristics prodchar :prodcharList){ prodchar.actionCode ='no change'; }
                        }
                        
                        List<BillingSpecDTOV2.BillingSpecifications> billingSpecs = billingOrderItemDataObject.billingSpecifications;
                        
                        for( BillingSpecDTOV2.BillingSpecifications billingSpec :billingSpecs){
                           
                           
                           if(billingSpec.billingSpecId!= null && billingSpec.billingSpecId.equalsIgnoreCase('BSOTC001_CB') ){
                                if(!billingSpec.ContractType.containsIgnoreCase('Purchase')){
                                    recurringbillingSpecs.add(billingSpec);
                                }
                            }
                            else{recurringbillingSpecs.add(billingSpec);
                                }
                        }
                        
                        for(BillingSpecDTOV2.BillingSpecifications bSpec :recurringbillingSpecs){
                            if(bSpec.actionCode !='Cease' && scenarioType.equalsIgnoreCase('COBA')){
                                bSpec.actionCode ='no change';}
                            
                            List<BillingSpecDTOV2.priceAlterations> pricealtList = bSpec.priceAlteration;
                            if(pricealtList!=null)
                            {
                                for(BillingSpecDTOV2.priceAlterations probj:pricealtList){probj.actionCode ='no change';}
                            }
                        }      
                        
                        billingOrderItemDataObject.billingSpecifications = null;
                        
                        billingOrderItemDataObject.billingSpecifications = recurringbillingSpecs;
                    
                        if(billingOrderItemDataObject.billingSpecifications!= null && !billingOrderItemDataObject.billingSpecifications.isEmpty()){ //EDGE-218310 COBA Fix
                        updatedorderItemsList.add(billingOrderItemDataObject);
                        }
                    } 
                    billingSpecDTOV2.orderItems = null;
                    system.debug('updatedorderItemsList:'+updatedorderItemsList);
                    billingSpecDTOV2.orderItems = updatedorderItemsList;
                }
                
            }
        }catch(Exception e)
        {
            CoBABillHandler.logException('addSpecificToBuildBillPayload', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'Build payload for coba failed');
            throw e;
        }
         system.debug('billingSpecDTOV2 at end:'+billingSpecDTOV2);
        
    }
    
    
    public String generateCOBABillingPayLoad(String targetbillingaccountNumber){
        try{
            List<String> payloads = new List<String>();
            system.debug('subscriptionMap:'+subscriptionMap.values());
            for(csord__subscription__c sub :subscriptionMap.values()){
                payloads.add(buildBillPayload(sub.id, 'COBA', targetbillingaccountNumber));
            }
            
            payload = '['+String.join(payloads,',')+']';
            return payload;
        }
        catch(Exception e)
        {
            CoBABillHandler.logException('generateCOBABillingPayLoad', '', '',  e.getMessage() + '-' + e.getStackTraceString(), 'generating coba payload for all subscriptions failed');
            throw e;
        }
    }
}
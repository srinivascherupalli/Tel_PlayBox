/********************************************************************************
* Class Name  : C2O_ProductConfigurationTriggerHelper
* Description : C2O_ProductConfigurationTriggerHelper runs logic on Product configuration records which are filtered
based on certain filter conditions which are defined in handler
* Created By  : Uday Dunna 
* Change Log  : Created
********************************************************************************/
public class C2O_ProductConfigurationTriggerHelper {  
    
    /***************************************************************************************
* Author - Uday Dunna  
* Method Name - CheckOfferReference
* Description - This method is used to update the offer reference for Product Config records.
****************************************************************************************/
    public static void CheckOfferReference(List<cscfga__Product_Configuration__c> productConfigRecsList){
        for(cscfga__Product_Configuration__c pdConfg : productConfigRecsList){
            //Update Offer Reference on Product Configuration record with Configuration offer Id.
            pdConfg.Offer_Reference__c = pdConfg.cscfga__Configuration_Offer__c;
        }
    }
    
    /***************************************************************************************
* Author - Uday Dunna 
* Method Name - updateChargeLineItemWithPC
* Description - This method is used to update Charge Line item.
****************************************************************************************/    
    public static void updateChargeLineItemWithPC(List<cscfga__Product_Configuration__c> productConfigRecs){ 
        List<String> BASKET_STAGE = new List<String>{'Commercial Configuration','Draft'};
        Map<String,cscfga__Product_Configuration__c> guidConfigRecordMap = new Map<String,cscfga__Product_Configuration__c>();
        Map<String,String> guidConfigBasketMap = new Map<String,String>();
        List<Charge_Line_Item__c> updatedCLIList = new List<Charge_Line_Item__c>();
        
        try{ 
            for(cscfga__Product_Configuration__c pc : [SELECT Id, Name, configGUID__c, cscfga__Product_Basket__c, cscfga__Configuration_Offer__c,
                                                       cscfga__Configuration_Status__c FROM cscfga__Product_Configuration__c
                                                       WHERE Id IN: productConfigRecs AND cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c  IN :BASKET_STAGE ]){
                                                           if(!String.isBlank(pc.configGUID__c)){
                                                               guidConfigRecordMap.put(pc.configGUID__c,pc);
                                                               guidConfigBasketMap.put(pc.configGUID__c,pc.cscfga__Product_Basket__c);
                                                           }
                                                       }
            ChargeDiscountQueryUtility cdqUtility = new ChargeDiscountQueryUtility();
            
            Map<String,Charge_Line_Item__c> chargeLineItemMap = cdqUtility.fetchExistingChargeLineItem(guidConfigRecordMap.keySet());
            
            for(Charge_Line_Item__c cli : chargeLineItemMap.values()){
                if(cli.Product_Configuration__c == null && guidConfigRecordMap.containsKey(cli.guid__c) && guidConfigBasketMap!=null && guidConfigBasketMap.containsKey(cli.guid__c) && guidConfigBasketMap.get(cli.guid__c).contains(cli.basketId__c)){
                    cli.Product_Configuration__c = guidConfigRecordMap.get(cli.guid__c).Id;
                    updatedCLIList.add(cli);
                }
            }
            
            if(updatedCLIList != null && !updatedCLIList.isEmpty()){
                ComplexChargeDisountFactory ccd = new ComplexChargeDisountFactory();
                ccd.updateChargeLineItem(updatedCLIList);
            }
        } catch(Exception e){
            Map<String,Object> inputMap = new Map<String,Object>();
            inputMap.put('severity', C2O_ExceptionHandler.SEVERITY.HIGH); 
            inputMap.put('errorDescription', e.getMessage());
            inputMap.put('LoggingLevel.INFO', e.getStackTraceString()); 
            C2O_Utilities.logException(inputMap,false);
        }
    }
}
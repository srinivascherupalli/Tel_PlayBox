/* 
* @Author : Yash 
* @Date   : 24/11/2020
* @Desc   : Custom Apex to identify Frame Agreement linked to Basket and fetch pricing details accordingly
* @Jira   : EDGE-184433
*/
/***History of Updates 
* Yash Rathod:  12/09/2020  EDGE-176688  Generic AM change to fetch OC values from PC & RC values from PC/attribute
* Yash Rathod:  12/11/2020  EDGE-176688  AM Device HRO Specific 
*****/

public with sharing class ProductPricingHandler {
    /* Passing PC and attribute details to construct Discount Text and Recurring/One-off charges */
    public static string paymentTypeIdentifierRC = 'RC';
    public static Decimal getPricingDetails(String amType, cscfga__Product_Configuration__c pc, sObject pricingRecord,String paymentTypeIdentifier){
        Decimal finalPrice = 0.00;
        String objectAPIName = '';
        String paymentTypeIdentifierOC = 'OC';
        String amTypePlan = 'Plan';
        String amTypeDevice = 'Device';
        String attrObj = 'cscfga__Attribute__c';
        cscfga__Attribute__c attrRec = new cscfga__Attribute__c();
        try{
            objectAPIName = pricingRecord.getSObjectType().getDescribe().getName();
            //EDGE-176688 | Start
            if(paymentTypeIdentifier.equals(paymentTypeIdentifierOC) && pc.cscfga__One_Off_Charge__c != null){
                finalPrice = pc.cscfga__One_Off_Charge__c;
                System.debug('***Telstra:ProductPricingHandler:getPricingDetails:INSIDE OC PRICE'+finalPrice);
            } 
            else if(paymentTypeIdentifier.equals(paymentTypeIdentifierRC) && pc.cscfga__Recurring_Charge__c != null && amType.equals(amTypePlan)){
                finalPrice = pc.cscfga__Recurring_Charge__c;
                
            }
            else if(paymentTypeIdentifier.equals(paymentTypeIdentifierRC) && amType.equals(amTypeDevice) && objectAPIName.equalsIgnoreCase(attrObj)){
                attrRec = (cscfga__Attribute__c) pricingRecord;
                if(attrRec.cscfga__Value__c!=null){
                    finalPrice = Decimal.valueOf(attrRec.cscfga__Value__c);
                    System.debug('***Telstra:ProductPricingHandler:getPricingDetails:INSIDE RC Device PRICE'+finalPrice);
                }
            } 
            //EDGE-176688 | End
        }
        catch(Exception e){
            System.debug('***Telstra:ProductPricingHandler:getPricingDetails:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductPricingHandler:getPricingDetails:finalPrice '+finalPrice);
        return finalPrice;
    }
    //EDGE-176688 - Start
    public static Decimal amDeviceHROCheck(cscfga__Product_Configuration__c pc){
        Decimal finalPrice = 0.00;
        String ngemDeviceProdSpecId = 'DMCAT_ProductSpecification_001211';
        String AMDeviceProdSpecId = 'DMCAT_ProductSpecification_001342'; // EDGE-191284

        String AmAccProdSpecId = 'DMCAT_ProductSpecification_001389'; // Added By Mahima- DPG-3508(get HRO prices)
        
        try{
            //Added or condition for AmAccProdSpecId- DPG- 3508
            if(pc.cscfga__Product_Definition__r.product_Specification__c == ngemDeviceProdSpecId || pc.cscfga__Product_Definition__r.product_Specification__c == AMDeviceProdSpecId || pc.cscfga__Product_Definition__r.product_Specification__c ==AmAccProdSpecId || (system.label.pricingLogicSwitch == 'True' && (pc.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || pc.cscfga__Product_Definition__r.product_Specification__c ==DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID))){//EDGE-210438 Added checks for ngUC

                    system.debug('***Telstra:ProductPricingHandler:getAMDeviceHROPricing:finalPrice@@'+pc.cscfga__Product_Definition__r.product_Specification__c);
                   
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                    if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==False){
                        if(attribute.name.equals(paymentTypeIdentifierRC) && attribute.cscfga__Value__c != null){
                            finalPrice = Decimal.valueOf(attribute.cscfga__Value__c);
                            system.debug('***Telstra:ProductPricingHandler:getAMDeviceHROPricing:finalPrice::'+attribute.cscfga__Value__c + '::pc.name::' + pc.Name+'::pc.id::' + pc.id);
                        }
                    }
                } 
            }
            //EDGE-210438(ngUC qty fix) Start
            else if(pc.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || pc.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID){
                
                finalPrice=pc.cscfga__total_recurring_charge__c*pc.Quantity_Product_Configuration__c;
            }//EDGE-210438(ngUC qty fix) End
            else{
                finalPrice = pc.cscfga__total_recurring_charge__c;
            }
        }
        catch(Exception e){
            System.debug('***Telstra:ProductPricingHandler:getAMDeviceHROPricing:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductPricingHandler:getAMDeviceHROPricing:finalPrice '+finalPrice);
        return finalPrice;    
    }
    //EDGE-176688 - End
}
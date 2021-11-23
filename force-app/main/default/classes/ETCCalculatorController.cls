/*******************************************************************************************************************
Name : ETCCalculatorController
EDGE-> 198139
Description : To calculate ETC charges and Remaining term on subscription
====================================================================================================================
Sr.No.    Developer Name          Date                  Story Description
1.        Rajiv Singh          11/02/2021       To calculate ETC charges and Remaining term on subscription                                             
====================================================================================================================
********************************************************************************************************************/

public with sharing class ETCCalculatorController {
    
    @AuraEnabled
    public static Object grtServiceDetails(String subscriptionId){
        Map<String,Object> result = new Map<String,Object>();
        List<ConstantMetadataUtility__mdt> metdataList = [SELECT Value__c,DeveloperName FROM ConstantMetadataUtility__mdt WHERE DeveloperName IN ('Adaptive_Mobility','Corporate_Mobile_Plus','Standalone_Device_and_Accessory','Telstra_Collaboration','ETCNotes')];
        Map<String,String> metadataMap = new Map<String,String>();
        for(ConstantMetadataUtility__mdt mdtRec : metdataList){
            metadataMap.put(mdtRec.DeveloperName,mdtRec.Value__c);
        }
        String Adaptive_Mobility = metadataMap.get('Adaptive_Mobility');
        String   Standalone_Device_and_Accessory = metadataMap.get('Standalone_Device_and_Accessory');
        String   Telstra_Collaboration = metadataMap.get('Telstra_Collaboration');
        String Corporate_Mobile_Plus = metadataMap.get('Corporate_Mobile_Plus');
        set<String> labelSet = new set<String>();
        labelSet.add(Adaptive_Mobility);
        labelSet.add(Standalone_Device_and_Accessory);
        labelSet.add(Telstra_Collaboration);
        labelSet.add(Corporate_Mobile_Plus);
        if(subscriptionId!=null){
        // Getting the subscription record details on which the ETC is to be calculated.
            csord__Subscription__c subscription = [SELECT Id,csord__Status__c,Name,Contract_Term__c ,Initial_Activation_DateTime__c,csordtelcoa__Product_Configuration__c,MarketableOffer__c,MarketableOffer__r.Offer_ID__c,Nickname__c FROM csord__Subscription__c WHERE Id=:subscriptionId];
            if(subscription.csord__Status__c != 'Active'){
                result.put('Active Error','ETC Charges are available only for active subscriptions');
            }else{
                if(subscription.MarketableOffer__r != null && subscription.MarketableOffer__r.Offer_ID__c != null &&  !labelSet.contains(subscription.MarketableOffer__r.Offer_ID__c)){
                    result.put('Result','Marketable Offer Error');
                    system.debug('inide marketable error');
                    result.put('message','The assigned marketable offer is not valid for ETC calculation');
                }else{
                                        //Getting the service list with payment type = Repayment
              List<csord__service__c> serviceList =   [SELECT Id,ContractTerms__c,contract_term__c,csord__Activation_Date__c,Initial_Activation_DateTime__c, Name, Payment_Type__c,csordtelcoa__Product_Configuration__c FROM csord__service__c WHERE csord__Subscription__c =: subscriptionId AND Payment_Type__c LIKE '%Repayment%' AND csord__Subscription__r.csord__Status__c='Active' LIMIT 1];
              if(serviceList.size() > 0){
                  result.put('Result','success');
                  result.put('csord__Subscription__c',subscription);
                  if(subscription.MarketableOffer__r.Offer_ID__c == Adaptive_Mobility || subscription.MarketableOffer__r.Offer_ID__c == Standalone_Device_and_Accessory){
                    result.put('dm_cat_check','AM');
                  }
                  if(subscription.MarketableOffer__r.Offer_ID__c == Telstra_Collaboration){
                    result.put('dm_cat_check','NGUC');
                  }
                  if(subscription.MarketableOffer__r.Offer_ID__c == Corporate_Mobile_Plus){
                    result.put('dm_cat_check','CMP');
                  }
              }else{
                  result.put('Result','Error');
                  result.put('message','ETC Charges are available only for Hardware Repayment devices');
              }
                }

            }
           
        }
        else{
            result.put('Result','Error');
            result.put('message','Invalid subscription Id');
        }      
        
        return result;
    }
    
    @AuraEnabled
    public static Object getDataForCMP(String subscriptionId){
        Map<String,Object> result = new Map<String,Object>();
        List<csord__service__c> serviceList =   [SELECT Id,ContractTerms__c,contract_term__c,csord__Activation_Date__c, Initial_Activation_Date__c, Name, Payment_Type__c,csordtelcoa__Product_Configuration__c FROM csord__service__c WHERE csord__Subscription__c =: subscriptionId AND csord__subscription__r.marketableoffer__r.Offer_ID__c ='DMCAT_Offer_000646' AND Payment_Type__c LIKE '%Repayment%' AND csord__Service__c !=NULL LIMIT 1];
        if(serviceList.size() > 0){
            result.put('ProdConfigId',serviceList[0].csordtelcoa__Product_Configuration__c);
            result.put('InitailActivationDate',serviceList[0].Initial_Activation_Date__c);
            system.debug('values'+ result);
        }
        return result;
    }

    @AuraEnabled
    public static Map<String, String> getETCChargesForCMPDevice(Map<String, Object> inputMap){
        Map<String, Object> returnMap = new Map<String, Object>();
        String prodConfigId = (String)inputMap.get('ProdConfigId');
        system.debug('ProdConfigId '+ProdConfigId);
        Date disconnectionDate = Date.valueOf((String)inputMap.get('DisconnectionDate'));
        Integer term = Integer.valueOf(inputMap.get('etc_Term'));
        Decimal unitPrice = 0.0;
        Date initialActivationDate = null;
        String billingAccNumber;
        Map<String, String> results;
        List<cscfga__Product_Configuration__c> deviceConfig = [SELECT Id, Name, csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c, (
            SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c
            FROM cscfga__Attributes__r
            where Name= 'InstalmentCharge' and cscfga__Recurring__c = true)
                                                               FROM cscfga__Product_Configuration__c
                                                               WHERE Id = :prodConfigId]; 
            initialActivationDate = Date.valueOf((String)inputMap.get('InitailActivationDate'));
            system.debug('initial activation date '+initialActivationDate);
            if(deviceConfig.size() > 0){
                for (cscfga__Product_Configuration__c device : deviceConfig){
                    System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:device:' + device);
                    if (device.id == prodConfigId){
                        if (device.cscfga__Attributes__r.size() > 0){
                            unitPrice = Decimal.valueOf(device.cscfga__Attributes__r[0].cscfga__Value__c);
                            System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:AttributeRecurringCharges:' + device.cscfga__Attributes__r[0]);
                        }
                    }
                }
            }
        if(inputMap.containskey('subscriptionId')){
            String subscriptionId = String.valueOf(inputMap.get('subscriptionId'));
            csord__Subscription__c sub = [SELECT Id,csord__Status__c,Name,Contract_Term__c ,Billing_Account__r.Billing_Account_Number__c,Initial_Activation_DateTime__c,csordtelcoa__Product_Configuration__c,MarketableOffer__c,MarketableOffer__r.Offer_ID__c FROM csord__Subscription__c WHERE Id=:subscriptionId];
            billingAccNumber = sub.Billing_Account__r.Billing_Account_Number__c;
        }
       // System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:deviceConfigId=' + deviceConfigId + ',prodConfigId=' + prodConfigId + ', disconnectionDate=' + disconnectionDate + ', term=' + term + ', unitPrice=' + unitPrice);
        String etcCharge;
        if (String.isNotEmpty(prodConfigId)){
            System.debug('Inside main if');
                System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:' + billingAccNumber + ':' + initialActivationDate);
                results = EarlyCancellationCalcService.CancelChargesCalc(0, initialActivationDate, disconnectionDate, Term, unitPrice, true, billingAccNumber);
            
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:etcCharge=' + results);
        return results;
    }

    @AuraEnabled
    public static string getLabels(){
        String label;
        ConstantMetadataUtility__mdt mdtRec = [SELECT Value__c,DeveloperName FROM ConstantMetadataUtility__mdt WHERE DeveloperName = 'ETCNotes'];
        label = mdtRec.Value__c;
        return label;
    }
}
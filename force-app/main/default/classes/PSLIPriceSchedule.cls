/******************************************************************************************************************************
Class Name : PSLIPriceSchedule
Test Class : PSLIPriceScheduleTest

Sr.No.  Developer       Date          Story Description         Sprint
1.      Aman Soni       20/04/2020    EDGE-123593(New Class)    20.05
******************************************************************************************************************************/
public with sharing class PSLIPriceSchedule{
  public static Map<String,Map<String,String>> PSLIPriceScheduleResponse(String configGuid,boolean changeFlag){
    Map<String,Map<String,String>> finalMap = new Map<String,Map<String,String>>();
    Map<String,PriceScheduleDTO.ChargeLineItems> cliToNameMap = new Map<String,PriceScheduleDTO.ChargeLineItems>();
    Map<String,List<PriceScheduleDTO.PriceScheduleLineItem>> cliTopsliMap = new Map<String,List<PriceScheduleDTO.PriceScheduleLineItem>>();
    Map<String,List<PriceScheduleDTO.ApplicableDiscounts>> psliTodliMap = new Map<String,List<PriceScheduleDTO.ApplicableDiscounts>>();
    List<PriceScheduleDTO.PriceScheduleLineItem> psliList = new List<PriceScheduleDTO.PriceScheduleLineItem>();   
    List<PriceScheduleDTO.ApplicableDiscounts> dliList = new List<PriceScheduleDTO.ApplicableDiscounts>();
    List<PriceScheduleDTO.ChargeLineItems> cliList = new List<PriceScheduleDTO.ChargeLineItems>();
    
    if(!String.isBlank(configGuid)){
        for(Price_Schedule_Discount_Association__c psda : [Select id,priceScheduleInstance__c,discountInstance__c,discountInstance__r.Name,discountInstance__r.discountValue__c,discountInstance__r.discountType__c,discountInstance__r.discountClass__c,priceScheduleInstance__r.toPeriod__c,priceScheduleInstance__r.unitPrice__c,priceScheduleInstance__r.fromPeriod__c,priceScheduleInstance__r.chargeInstance__r.unitPrice__c,priceScheduleInstance__r.chargeInstance__r.contractTerm__c,discountInstance__r.chargeInstance__c,priceScheduleInstance__r.chargeInstance__c,priceScheduleInstance__r.chargeInstance__r.Product_Charge_Identifier__c,priceScheduleInstance__r.chargeInstance__r.BusinessID__c,priceScheduleInstance__r.chargeInstance__r.targetChargeProduct__c,priceScheduleInstance__r.chargeInstance__r.totalContractValue__c  from Price_Schedule_Discount_Association__c where priceScheduleInstance__r.chargeInstance__r.guid__c =: configGuid and priceScheduleInstance__r.chargeInstance__r.status__c='Active']){
            //Create PSLI 
            PriceScheduleDTO.PriceScheduleLineItem PSLIInstance = new PriceScheduleDTO.PriceScheduleLineItem();
            if(!String.isBlank(psda.priceScheduleInstance__c) && !String.isBlank(psda.priceScheduleInstance__r.chargeInstance__c) && !String.isBlank(psda.discountInstance__c)){
                PSLIInstance.id = psda.priceScheduleInstance__c;
                PSLIInstance.fromPeriod = Integer.ValueOf(psda.priceScheduleInstance__r.fromPeriod__c);
                PSLIInstance.toPeriod = Integer.ValueOf(psda.priceScheduleInstance__r.toPeriod__c);
                PSLIInstance.unitPrice = psda.priceScheduleInstance__r.unitPrice__c;
                PSLIInstance.cliId = psda.priceScheduleInstance__r.chargeInstance__c;
                psliList.add(PSLIInstance);
                if(cliTopsliMap.containsKey(PSLIInstance.cliId)){
                List<PriceScheduleDTO.PriceScheduleLineItem> adList = cliTopsliMap.get(PSLIInstance.cliId);
                adList.add(PSLIInstance);     
                cliTopsliMap.put(PSLIInstance.cliId,adList);
                }
                else{        
                List<PriceScheduleDTO.PriceScheduleLineItem> adList = new List<PriceScheduleDTO.PriceScheduleLineItem>();
                adList.add(PSLIInstance);
                cliTopsliMap.put(PSLIInstance.cliId,adList);
                }   
            
                //Create DLI
                PriceScheduleDTO.ApplicableDiscounts dliInstance = new PriceScheduleDTO.ApplicableDiscounts ();
                dliInstance.id = psda.discountInstance__c;
                dliInstance.description = psda.discountInstance__r.Name;
                dliInstance.discountAmount = psda.discountInstance__r.discountValue__c;
                if(psda.discountInstance__r.discountClass__c == 'Percent'){
                   dliInstance.discountAmount += '%';   
                }
                dliInstance.appliedDiscountValue = psda.discountInstance__r.discountValue__c;
                dliInstance.psliId = psda.priceScheduleInstance__c;
                dliList.add(dliInstance);
                if(psliTodliMap.containsKey(dliInstance.psliId)){
                List<PriceScheduleDTO.ApplicableDiscounts> adList = psliTodliMap.get(dliInstance.psliId);
                adList.add(dliInstance);        
                psliTodliMap.put(dliInstance.psliId,adList);       
                }
                else{        
                List<PriceScheduleDTO.ApplicableDiscounts> adList = new List<PriceScheduleDTO.ApplicableDiscounts>();
                adList.add(dliInstance);
                psliTodliMap.put(dliInstance.psliId,adList);      
                }

              //Create CLI
                if(cliToNameMap.get(psda.priceScheduleInstance__r.chargeInstance__r.Product_Charge_Identifier__c) == null ){
                PriceScheduleDTO.ChargeLineItems CLIInstance = new PriceScheduleDTO.ChargeLineItems();
                CLIInstance.unitPrice = psda.priceScheduleInstance__r.chargeInstance__r.unitPrice__c;
                CLIInstance.contractTerm = Integer.ValueOf(psda.priceScheduleInstance__r.chargeInstance__r.contractTerm__c);
                CLIInstance.productChargeIdentifier = psda.priceScheduleInstance__r.chargeInstance__r.Product_Charge_Identifier__c;
                CLIInstance.businessID = psda.priceScheduleInstance__r.chargeInstance__r.BusinessID__c;
                CLIInstance.targetChargeProduct = psda.priceScheduleInstance__r.chargeInstance__r.targetChargeProduct__c;
                CLIInstance.unitTotalContractValue = psda.priceScheduleInstance__r.chargeInstance__r.totalContractValue__c;
                CLIInstance.id = psda.priceScheduleInstance__r.chargeInstance__c;
                cliList.add(CLIInstance);
                cliToNameMap.put(psda.priceScheduleInstance__r.chargeInstance__r.Product_Charge_Identifier__c,CLIInstance);
                }
            }
        }
        Map<String,PriceScheduleDTO.PriceScheduleLineItem> uniquePSLIMap = new Map<String,PriceScheduleDTO.PriceScheduleLineItem>();
        if(psliList != null && psliList.size()>0){
            for(PriceScheduleDTO.PriceScheduleLineItem psliL :psliList){
                uniquePSLIMap.put(psliL.id,psliL);   
            }
        }
        if(uniquePSLIMap != null && uniquePSLIMap.size()>0){
            for(PriceScheduleDTO.PriceScheduleLineItem psliL : uniquePSLIMap.values()){
                if(psliTodliMap != null && psliTodliMap.size()>0){
                    psliL.applicableDiscounts = psliTodliMap.get(psliL.id);
                }
            }
        }
        if(cliList != null && cliList.size()> 0){
            for(PriceScheduleDTO.ChargeLineItems cliL : cliList){
                Map<String,String> cliInstanceMap = new Map<String,String>();
                if(cliTopsliMap != null && cliTopsliMap.size()>0){
                cliL.priceScheduleLineItem = cliTopsliMap.get(cliL.id);
                }
                cliInstanceMap.put('chargeLineItems',JSON.serialize(cliL));
                finalMap.put(cliL.productChargeIdentifier,cliInstanceMap);                      
            }
        }
        system.debug('finalMap in PSLIPriceScheduleResponse-->'+finalMap);
    } 
    return finalMap;
  }
}
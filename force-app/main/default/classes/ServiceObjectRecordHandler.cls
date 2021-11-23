/*
* @Author : Gnana
* @Date : 28 Jan 2020
* @Desc : Services object record handler  
* @Jira : Edge-132211
* @test class : ServiceObjectRecordHandlerTest
* @Modification History:
* 1. Gnana 28/05/2020 - toBeCancelled__c != 'true' - Removed this condition as part of EDGE-151675
* 2. Gnana 19/06/2020 - EDGE# - Modified updateChargeLineItemWithService to add addition condition to check 
						cli.PC==ser.PC before updating CLI with Service Id
*/
public without sharing class ServiceObjectRecordHandler {
    
    // Removing Status condition 
    //public static string STATUS_PENDING = 'Pending';
    
    @InvocableMethod(label='Associate CLI to Service Record' description='Associate Charge Line Items with Services record')
    public static void updateChargeLineItemWithService(List<ID> serviceIds){
        if(serviceIds != null && !serviceIds.isEmpty()){
            Map<String,csord__Service__c > guidServiceRecordMap = new Map<String,csord__Service__c >();
            for(csord__Service__c ser : [SELECT Id, Name, csordtelcoa__Product_Configuration__c, csordtelcoa__Product_Configuration__r.configGUID__c, csordtelcoa__Product_Basket__c, 
                                         csord__Status__c FROM csord__Service__c WHERE Id IN: serviceIds AND csordtelcoa__Product_Configuration__c != NULL]){
                                             if(!String.isBlank(ser.csordtelcoa__Product_Configuration__r.configGUID__c)){
                                                 guidServiceRecordMap.put(ser.csordtelcoa__Product_Configuration__r.configGUID__c,ser);
                                             }
                                         }
            
            if(guidServiceRecordMap != null && !guidServiceRecordMap.isEmpty()){
                ChargeDiscountQueryUtility cdqUtility = new ChargeDiscountQueryUtility();
                Map<String,Charge_Line_Item__c> chargeLineItemMap = cdqUtility.fetchExistingChargeLineItem(guidServiceRecordMap.keySet());
                if(chargeLineItemMap != null && !chargeLineItemMap.isEmpty()){
                    List<Charge_Line_Item__c> updatedCLIList = new List<Charge_Line_Item__c>();
                    for(Charge_Line_Item__c cli : chargeLineItemMap.values()){
                        if(cli.serviceId__c == null && guidServiceRecordMap.containsKey(cli.guid__c) && cli.Product_Configuration__c == guidServiceRecordMap.get(cli.guid__c).csordtelcoa__Product_Configuration__c){
                            cli.serviceId__c = guidServiceRecordMap.get(cli.guid__c).Id;
                            updatedCLIList.add(cli);
                        }
                    }
                    if(updatedCLIList != null && !updatedCLIList.isEmpty()){
                        ComplexChargeDisountFactory ccd = new ComplexChargeDisountFactory();
                        ccd.updateChargeLineItem(updatedCLIList);
                    }
                }
            }
        }
    }
}
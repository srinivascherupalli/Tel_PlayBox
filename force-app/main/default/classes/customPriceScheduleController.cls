/*************************************************************************************************
Name : customPriceScheduleController
EDGE-> 120144
Description : Handler for customPriceSchedule Lightning Component
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description
1.        Rohit Tripathi    24-Dec-2019     EDGE-120144 : Present Pricing MS response : As a sales user, 
                      I should be able to view the generated detailed pricing schedule
                      for configured plans, total contract value so that i can have conversation with customer regarding net prices.
2.        Gnana        10-Feb-2020    EDGE-133963 : Updated fetchPricingSummaryResponse method to include Device details if applicable
3.        Gnana        20-Feb-2020    EDGE-134880 : Updated fetchPricingSummaryResponse method to update ChargeLineItem SOQL query to include Cancelled filter
4.        Aman Soni    30-March-2020  EDGE-123593 : Updated fetchPricingSummaryResponse method to differentiate price schedule between Modify and New journey
5.       Aman Soni     14-April-2020  EDGE-123593 : Created separate method fetchPricingSummaryResponseEM for Mobility
6.       Aman Soni     24-April-2020  EDGE-123593 : Created separate method fetchModifyScheduleEM for Mobility for MAC Journey
===============================================================================================================================
***************************************************************************************************/

public with Sharing class customPriceScheduleController {

    public static String PRICING_FILTER = 'Price Item';
    public static String ADDON_FILTER = 'AddOn';
    public static String DEVICE_FILTER = 'Device';//EDGE-134880
    
    /*method to fetch fetchPricingSummaryResponse based on Config Id passed from Lightning Component (customPriceSchedule) Edge-120144*/
    @AuraEnabled
    public static Map<String,String> fetchPricingSummaryResponse(String configId,boolean changeFlag)//Added addition argument changeFlag by Aman Soni as a part of EDGE-123593
    {
        System.debug('configId --->'+configId+''+changeFlag);
        changeFlag=false; //added to fix qa2 error 
        Map<String,String> mapOfPricingResponse = new Map<String,String>();
        Map<String,String> mapOfCLIAndPCI = new Map<String,String>();
        
        // Fetch all Charge Line Items with the given Config GUID
        if(!String.isBlank(configId))//Added null check by Aman Soni as a part of EDGE-123593
        {            
                for(Charge_Line_Item__c cli : [Select id,CorrelationId__c,Product_Charge_Identifier__c,status__C from Charge_Line_Item__c where guid__c = :configId])
                {
                    if(!changeFlag && (cli.Product_Charge_Identifier__c==PRICING_FILTER || cli.Product_Charge_Identifier__c==ADDON_FILTER || cli.Product_Charge_Identifier__c==DEVICE_FILTER) && cli.status__C=='New'){
                        mapOfCLIAndPCI.put(cli.Id,cli.Product_Charge_Identifier__c);
                    }
               }            
        }

        // Process PricingMSResponse
        if(!mapOfCLIAndPCI.isEmpty())//Added null check by Aman Soni as a part of EDGE-123593
        {
            for (PricingMSResponseObject__c res :[Select id,createddate,ResponsePayload__c, Status__c, TCV_Value__c, ErrorDescription__c,CLI_Instance_ID__c from PricingMSResponseObject__c where CLI_Instance_ID__c = :mapOfCLIAndPCI.keySet() order by LastModifiedDate ASC]){            
                if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == PRICING_FILTER){
                    mapOfPricingResponse.put(PRICING_FILTER,res.ResponsePayload__c);
                }
                else if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == ADDON_FILTER){
                    mapOfPricingResponse.put(ADDON_FILTER,res.ResponsePayload__c);
                }
                else if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == DEVICE_FILTER){//EDGE-134880
                    mapOfPricingResponse.put(DEVICE_FILTER,res.ResponsePayload__c);
                }
            }
        }
        
        if(!mapOfPricingResponse.containsKey(PRICING_FILTER)){
            mapOfPricingResponse.put('PricingError','Error');
        }
        if(!mapOfPricingResponse.containsKey(ADDON_FILTER)){
            mapOfPricingResponse.put('AddOnError','Error');
        }
        if(!mapOfPricingResponse.containsKey(DEVICE_FILTER)){
            mapOfPricingResponse.put('DeviceError','Error');//EDGE-134880
        }

        System.debug('mapOfPricingResponse---->'+mapOfPricingResponse);
        return mapOfPricingResponse;
    }
    
    // Method fetchPricingSummaryResponseEM created by Aman Soni as a part of EDGE-123593 || It works separately for EM
    @AuraEnabled
    public static Map<String,PricingMSResponseObject__c> fetchPricingSummaryResponseEM(String configId,boolean changeFlag)
    {
        System.debug('configId--->'+configId+'@@@'+'changeFlag--->'+changeFlag);
        Map<String,PricingMSResponseObject__c> mapOfPricingResponse = new Map<String,PricingMSResponseObject__c>();
        Map<String,String> mapOfCLIAndPCI = new Map<String,String>();
        PricingMSResponseObject__c res1 = new PricingMSResponseObject__c();
        // Fetch all Charge Line Items with the given Config GUID
        if(!String.isBlank(configId))
        {            
            for(Charge_Line_Item__c cli : [Select id,CorrelationId__c,Product_Charge_Identifier__c,status__C from Charge_Line_Item__c where guid__c =: configId])
            {
                if(!changeFlag && (cli.Product_Charge_Identifier__c==PRICING_FILTER || cli.Product_Charge_Identifier__c==ADDON_FILTER || cli.Product_Charge_Identifier__c==DEVICE_FILTER) && cli.status__C == 'New'){
                    mapOfCLIAndPCI.put(cli.Id,cli.Product_Charge_Identifier__c);
                }
            }               
        }

        //To get PricingMSResponse
        if(!mapOfCLIAndPCI.isEmpty())
        {
            for (PricingMSResponseObject__c res :[Select id,createddate,ResponsePayload__c, Status__c, TCV_Value__c, ErrorDescription__c,CLI_Instance_ID__c from PricingMSResponseObject__c where CLI_Instance_ID__c =: mapOfCLIAndPCI.keySet() order by LastModifiedDate ASC]){
                    
                if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == PRICING_FILTER){
                    mapOfPricingResponse.put(PRICING_FILTER,res);
                }
                else if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == ADDON_FILTER){
                    mapOfPricingResponse.put(ADDON_FILTER,res);
                }
                else if(mapOfCLIAndPCI.get(res.CLI_Instance_ID__c) == DEVICE_FILTER){
                    mapOfPricingResponse.put(DEVICE_FILTER,res);
                }
            }
        }
        
        if(!mapOfPricingResponse.containsKey(PRICING_FILTER)){
            mapOfPricingResponse.put('PricingError',res1);
        }
        if(!mapOfPricingResponse.containsKey(ADDON_FILTER)){
            mapOfPricingResponse.put('AddOnError',res1);
        }
        if(!mapOfPricingResponse.containsKey(DEVICE_FILTER)){
            mapOfPricingResponse.put('DeviceError',res1);
        }
        System.debug('mapOfPricingResponse in fetchPricingSummaryResponseEM--->'+mapOfPricingResponse);
        return mapOfPricingResponse;
    }
    
    //Method fetchModifyScheduleEM created by Aman Soni as a part of EDGE-123593 || It will fetch Price schedule from PSLI instead of Response to see previous schedule in Modify Journey. 
    @AuraEnabled
    public static Map<String,Map<String,String>> fetchModifyScheduleEM(String configId,boolean changeFlag)
    {   
        Map<String,String> errorMap = new Map<String,String>();
        Map<String,Map<String,String>> mapOfPricingResponse = new Map<String,Map<String,String>>();
        if(!String.isBlank(configId)){
        mapOfPricingResponse = PSLIPriceSchedule.PSLIPriceScheduleResponse(configId,changeFlag);
        System.debug('mapOfPricingResponse in fetchModifyScheduleEM Before--->'+mapOfPricingResponse);   
        }         
            if(!mapOfPricingResponse.containsKey(PRICING_FILTER)){
                mapOfPricingResponse.put('PricingError',errorMap);
            }
            if(!mapOfPricingResponse.containsKey(ADDON_FILTER)){
                mapOfPricingResponse.put('AddOnError',errorMap);
            }
            if(!mapOfPricingResponse.containsKey(DEVICE_FILTER)){
                mapOfPricingResponse.put('DeviceError',errorMap);
            }
        System.debug('mapOfPricingResponse in fetchModifyScheduleEM After--->'+mapOfPricingResponse);     
        return mapOfPricingResponse;
    }
    
}
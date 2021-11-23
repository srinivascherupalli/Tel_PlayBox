/*
===============================================================================================================================
Class : OrderLodgement
Developer Name : Dheeraj Bhatt
Test Class : OrderLodgementTest
===============================================================================================================================
Sr.No.    Developer Name        Date          Story Description
1.        Dheeraj Bhatt         06 Aept 2021   DIGI-1939 - Enable an API call to the MS to initiate digi plan configuration
===============================================================================================================================
*/
public without sharing class OrderLodgement {
    private static final String CONST_INTERFACENAME = 'OrderLodgementService';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.BSK;
    
    private static final String CONST_HANDLERNAME = 'OrderLodgement';
    public static Boolean orderLodgmentServiceRequest(string basketId){
        boolean isSuccess=false;
        try {
            List<cscfga__Product_Configuration__c> productConfig= [SELECT id,cscfga__Product_Basket__r.AutoConfigStage__c,cssdm__solution_association__r.Name,Marketable_Offer__r.Name,ConfigurationType1__c FROM cscfga__Product_Configuration__c 
                                                                   WHERE cscfga__Product_Basket__c=:basketId AND ConfigurationType1__c='SolutionComponent'];
            if(!productConfig.isEmpty()){
                HttpResponse response=OrderLodgementService.orderLodgementRequest(CONST_HANDLERNAME,basketId,productConfig[0]?.cssdm__solution_association__r?.Name,productConfig[0]?.Marketable_Offer__r?.Name);   
                if(response.getStatusCode()==200){
                    isSuccess=true;
                    cscfga__Product_Basket__c basket= [SELECT id,AutoConfigStage__c FROM cscfga__Product_Basket__c WHERE Id =:basketId];
                    basket.AutoConfigStage__c='	In Progress';
                    update basket;
                }
            }
        }
        catch(exception ex){ 
            logException('orderLodgementCallout','', GuidUtil.NewGuid(), ex.getMessage(), 'order Lodgement Api');
        }
        return isSuccess;
    }
     private static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }

}
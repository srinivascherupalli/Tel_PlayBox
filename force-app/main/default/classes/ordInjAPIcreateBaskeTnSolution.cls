/*********************************************************************************************************************************
Class Name: ordInjAPIcreateBaskeTnSolution
Test Class Name: ordInjAPIcreateBaskeTnSolutionTest
Description: TON Adding Branching Logic for Oppty Less Basket
===============================================================================================================================
Sr.No.    Developer Name          Date            Story Description
1.        Ameer Basha           16-Sept-2021      DIGI-16902:TON Adding Branching Logic for Oppty Less Basket.
================================================================================================================================
*/
global with sharing class ordInjAPIcreateBaskeTnSolution{
    public static final String HANDLER = 'ordInjAPIcreateBaskeTnSolution';
    public Static Logger2 logger = Logger2.getLogger(HANDLER);
    
    public static RestResponse createBaskeTnSolution(RestRequest request){
        string correlationId = '';
        RestResponse finalRes;
        //Map<String,String> resultMap = new Map<String,String>();
        correlationId = ordInjAPICreateOrder.getCorrelationId(request);
        finalRes= ordInjAPICreateOrder.validateData(correlationId, 'validateData','createBasket');
        
    return finalRes;
    }
}
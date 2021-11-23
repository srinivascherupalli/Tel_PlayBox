/*************************************************************************************************
Name : TransactionLogger 
description: class to insert transacton logs 
test class: TransactionLoggerTest
===============================================================================================================================
Sr.No.    Developer Name      Date              Story Description
1.         Shubhi/Aditya      31-08-2021        DIGI-3161
2.          Gautam/Aditya     02/11/2021        DIGI-37572
===============================================================
***************************************************************************************************/
global with sharing class TransactionLogger implements cssmgnt.RemoteActionDataProvider {
    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap){
      //determine featureEligibility for logged in user. Params - metadataname, flowName
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion')){
        String correlationID = '';
        Map<String,String> loggerdetailsMap=new Map<String,String>();
        if(inputMap!=null && inputMap.containskey('TransactionLogger')){
            if(inputMap.containskey('correlationId')){
                correlationID = String.valueof(inputMap.get('correlationId'));
            }
        }
        if(String.isNotBlank(correlationID) ){
            insertTransactionLogs(correlationId,inputMap,'TransactionLogger');
        }
     }
    return new Map<String, Object>();  
}


    public static void insertTransactionLogs(string correlationId, Map<String,Object> loggerdetailsMap, String loggerName){
        //logger at entry of the method
        //This is random hardcoded correlation ID for demo only. This value should be passed from UI.
        //private static 
        Logger3 logger = LoggerFactory.getLogger(loggerName);
        try{
            //logger while calling method from another class
            String loggerString='';
            loggerString+=loggerdetailsMap.containsKey('event')?'Event='+loggerdetailsMap.get('event'):'';
            loggerString+=loggerdetailsMap.containsKey('configurationCount')?', Number of configurations='+loggerdetailsMap.get('configurationCount'):'';
            loggerString+=loggerdetailsMap.containsKey('searchType')?', SearchType='+loggerdetailsMap.get('searchType'):'';
            loggerString+=loggerdetailsMap.containsKey('Quantity')?', Quantity='+loggerdetailsMap.get('Quantity'):'';
            loggerString+=loggerdetailsMap.containsKey('basketName')?', BasketName = '+loggerdetailsMap.get('basketName'):'';
            loggerString+=loggerdetailsMap.containsKey('OrderType')?', OrderType = '+loggerdetailsMap.get('OrderType'):'';
            loggerString+=loggerdetailsMap.containsKey('Name')?', Name = '+loggerdetailsMap.get('Name'):'';
            loggerString+=loggerdetailsMap.containsKey('OpportunityName')?', OpportunityName = '+loggerdetailsMap.get('OpportunityName'):'';
            loggerString+=loggerdetailsMap.containsKey('OpportunityType')?', OpportunityType = '+loggerdetailsMap.get('OpportunityType'):'';
            loggerString+=loggerdetailsMap.containsKey('OrderName')?', OrderName = '+loggerdetailsMap.get('OrderName'):'';
            loggerString+=loggerdetailsMap.containsKey('OfferName')?', OfferName = '+loggerdetailsMap.get('OfferName'):'';
            loggerString+=loggerdetailsMap.containsKey('OpportunityStage')?', OpportunityStage = '+loggerdetailsMap.get('OpportunityStage'):'';
            loggerString+=loggerdetailsMap.containsKey('BasketUrl')?', BasketUrl = '+loggerdetailsMap.get('BasketUrl'):'';
            loggerString+=loggerdetailsMap.containsKey('OrderURL')?', OrderURL = '+loggerdetailsMap.get('OrderURL'):'';
            loggerString+=loggerdetailsMap.containsKey('URL')?', URL = '+loggerdetailsMap.get('URL'):'';
            loggerString+=loggerdetailsMap.containsKey('OrderId')?', OrderId = '+loggerdetailsMap.get('OrderId'):'';
            loggerString+=loggerdetailsMap.containsKey('OrderStatus')?', OrderStatus = '+loggerdetailsMap.get('OrderStatus'):'';
            //added by gautam start--- DIGI-37572
            loggerString+=loggerdetailsMap.containsKey('AgreementType')?', AgreementType = '+loggerdetailsMap.get('AgreementType'):'';
            loggerString+=loggerdetailsMap.containsKey('AgreementStatus')?', AgreementStatus = '+loggerdetailsMap.get('AgreementStatus'):'';
            //added by gautam end ---
            logger.Info(loggerString) ;
        if (Test.isRunningTest()) {
            throw new DmlException('Exception thrown from test method run');
        }
                    
        }catch(exception ex){

            ExceptionHandlerHelper.ExceptionLogHandlerWrapper e = new ExceptionHandlerHelper.ExceptionLogHandlerWrapper();
            e.severity            = ExceptionHandlerHelper.Severity.HIGH;
            e.interfaceName       = 'TransactionLogger';
            e.elementName         = 'insertTransactionLogs()';
            e.referenceNumber     = '';
            e.capability          = ExceptionHandlerHelper.Capability.SYS_LOG;
            e.endPointURL         = '';
            e.integrationPayload  = '';
            e.correlationID       = correlationId;
            e.httpStatusCode      = '';
            e.errorCode           = '';
            e.errorDescription    = 'High Severity Error';
            e.destinationSystem   = 'DESTINATION_SYSTEM';
            e.responseMessage     = '';
            e.sourceName          = ExceptionHandlerHelper.SourceName.OTHERS;
            e.BusinessDescription = 'BUSINESS_DESCRIPTION';
            e.errorCategory       = 'TECHNICAL';
            
            logger.error(e);
            system.debug('Error in updateCorIdwithOppIDandSolID --> '+ex.getMessage());
        }finally{
            //Inserting logs as single record into Transaction Log object.
            LoggerFactory.flush(correlationId);
        }
    
    }

    @InvocableMethod(label='TransactionLoggerClass')
    public static void testInvokeActionFromFlow(){
        system.debug('Indside Transaction logger claas. this class was run by flow');
    }
}
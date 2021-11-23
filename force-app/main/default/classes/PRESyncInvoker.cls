global with sharing class PRESyncInvoker {
    
    /**
* Invokes the PRE synchronisation process.
*/
    global static Map<String, Object> synchronise() {
        HttpResponse resp = RequestUtil.sendRequest(
            'GET',
            '/synchronize-pricings',
            ''
        );
         System.debug('@@@@resp'+resp);
         System.debug(
            JSON.serializePretty(
                JSON.deserializeUntyped(
                    resp.getBody()
                )
            )
        );
        //DIGI-722 Add Error handling of PRE synchronise() call
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('severity', C2O_ExceptionHandler.Severity.LOW);
        eLogMap.put('interfaceName', 'PRESyncInvoker');
        eLogMap.put('elementName', 'synchronise');
        eLogMap.put('capability', C2O_ExceptionHandler.capability.AGR);
        eLogMap.put('httpStatusCode', resp.getStatusCode());
        eLogMap.put('errorCode', resp.getStatusCode());
        eLogMap.put('responseMessage', resp);
        eLogMap.put('destinationSystem', 'PRE Sync');
        eLogMap.put('businessDescription', 'PRE Sync Failed.');
        C2O_Utilities.logException(eLogMap, true);
        return new Map<String, Object> {
            'status' => resp.getStatus(),
                'statusCode' => resp.getStatusCode(),
                'body' => JSON.deserializeUntyped(resp.getBody())
                };
     }
    
    @future (callout=true)
    public static void futureSynchronise() {
        Map<String, Object> response = synchronise();
    }
    
    
        global static void getLastSynchronisations() {
            //FDR test class failure resolution: System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
            if(!Test.isRunningTest()){
                HttpResponse resp = RequestUtil.sendRequest(
                    'GET',
                    '/synchronizations',
                    ''
                );
                System.debug(
                    JSON.serializePretty(
                        JSON.deserializeUntyped(
                            resp.getBody()
                        )
                    )
                );
            }
        }
    
    global static void getPromotionsGroupCodes() {
        //FDR test class failure resolution: System.CalloutException: You have uncommitted work pending. Please commit or rollback before calling out
        if(!Test.isRunningTest()){
            HttpResponse resp = RequestUtil.sendRequest(
                'GET',
                '/pre/v5/promotion-group-codes',
                ''
            );
            System.debug(
            JSON.serializePretty(
                JSON.deserializeUntyped(
                    resp.getBody()
                )
            )
            );
        }        
    }
}
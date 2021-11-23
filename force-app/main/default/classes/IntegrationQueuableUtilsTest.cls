@isTest
private class IntegrationQueuableUtilsTest {
    @isTest static void isAnythingPendingToRunTest() {
        // Data Setup
        Integration_Record__c intRec = createIntegrationRecord(IntegrationQueueHandler.PENDING, 0, 'Test_Handler', true);
        
        Test.startTest();
        Boolean anythingPendingToRun = IntegrationQueuableUtils.isAnythingPendingToRun('Test_Handler');
        Test.stopTest();
        
        system.assertEquals(true, anythingPendingToRun);
    }
    
    @isTest static void retryTest() {
        String ERROR_MESSAGE = 'An unknown error occurred';     
        
        // Data Setup
        List<Integration_Record__c> intRecList = new List<Integration_Record__c>();
        Integration_Record__c intRec1 = createIntegrationRecord(IntegrationQueueHandler.PENDING, 3, 'Test_Handler1', false);
        intRecList.add(intRec1);
        Integration_Record__c intRec2 = createIntegrationRecord(IntegrationQueueHandler.IN_PROGRESS, 1, 'Test_Handler2', false);
        intRecList.add(intRec2);        
        Integration_Record__c intRec3 = createIntegrationRecord(IntegrationQueueHandler.IN_PROGRESS, 3, 'Test_Handler3', false);
        intRecList.add(intRec3);        
        Integration_Record__c intRec4 = createIntegrationRecord(IntegrationQueueHandler.PROCESSED, 0, 'Test_Handler4', false);
        intRecList.add(intRec4);        

        insert intRecList;                
        List<String> params = new List<String>();
        List<String> params1 = new List<String>();
        params.add('123456789');
        
        System.debug('Retry Count: ' + IntegrationRecordHandlerUtil.getMaxNoOfRetries('Test_Handler2'));
        Test.startTest();
        // Run retry for all relevant handlers
        IntegrationQueuableUtils.retry('Test_Handler1', params, ERROR_MESSAGE);
        IntegrationQueuableUtils.retry('Test_Handler2', params, ERROR_MESSAGE);
        IntegrationQueuableUtils.retry('Test_Handler3', params, ERROR_MESSAGE);
        IntegrationQueuableUtils.retry('Test_Handler4', params, ERROR_MESSAGE); 
        IntegrationQueuableUtils.retry('Test', params1, 'Test');
        Test.stopTest();
        
        //Query the Integration Records that were passed for 'retry' to confirm the updated statuses
        List<Integration_Record__c> updatedIntRecList = new List<Integration_Record__c>([SELECT Id, Number_Of_Retries__c, Status__c, Handler__c, Params__c
                                                                                        FROM Integration_Record__c
                                                                                        WHERE Id IN :intRecList]);
                                                                                        
        System.debug('Max Retries: ' + IntegrationRecordHandlerUtil.getMaxNoOfRetries('Test_Handler2'));
        System.debug('UpdatedIntRecList: ' + updatedIntRecList.size());
        
        if(updatedIntRecList.size() > 0) {
            for(Integration_Record__c rec : updatedIntRecList) {
                if(rec.Handler__c.equals('Test_Handler1')) {
                    System.assertEquals(IntegrationQueueHandler.PENDING, rec.Status__c, 'ERROR: Record updated incorrectly');
                }
                else if(rec.Handler__c.equals('Test_Handler2')) {
                    System.assertEquals(IntegrationQueueHandler.PENDING, rec.Status__c, 'ERROR: Record not updated to the correct status');
                    System.assertEquals(2, rec.Number_Of_Retries__c, 'ERROR: Number of retries not increased');                
                }
                else if(rec.Handler__c.equals('Test_Handler3')) {
                    System.assertEquals(IntegrationQueuableUtils.ERROR, rec.Status__c, 'ERROR: Record not updated to the correct status');
                }
            }
        }
    }    

    @isTest static void updateOnSucessTest() {
        List<Integration_Record__c> intRecList = new List<Integration_Record__c>();
        Integration_Record__c intRec1 = createIntegrationRecord(IntegrationQueueHandler.IN_PROGRESS, 0, 'Test_Handler2', false);
        intRec1.Params__c = '1111';
        intRecList.add(intRec1);        
        Integration_Record__c intRec2 = createIntegrationRecord(IntegrationQueueHandler.IN_PROGRESS, 0, 'Test_Handler2', false);
        intRec2.Params__c = '2222';
        intRecList.add(intRec2);        
        
        insert intRecList;
        
        List<String> params = new List<String>();
         List<String> params1 = new List<String>();
        params.add(intRec1.Params__c);
        params.add(intRec2.Params__c);
        Test.startTest();
             //IntegrationQueuableUtils.updateOnSucess('Test', params1);
            IntegrationQueuableUtils.updateOnSucess('Test_Handler2', params);
            
            //Query the Integration Records that were passed for 'updateOnSucess' to confirm the updated statuses
            List<Integration_Record__c> updatedIntRecList = new List<Integration_Record__c>([SELECT Id, Number_Of_Retries__c, Status__c, Handler__c, Params__c
                                                                                             FROM Integration_Record__c
                                                                                             WHERE Id IN :intRecList]);
            if(updatedIntRecList.size() > 0) {
                for(Integration_Record__c rec : updatedIntRecList) {
                    if(rec.Handler__c.equals('Test_Handler1')) {
                        System.assertEquals(IntegrationQueueHandler.PROCESSED, rec.Status__c, 'ERROR: Record updated incorrectly');
                    }                    
                }                
            }
        Test.stopTest();
    }
        
    private static Integration_Record__c createIntegrationRecord(String status, Decimal noOfRetries, String handler, Boolean insertNow) {        
        Integration_Record__c iRec;
        
        try {
            iRec = new Integration_Record__c();
            iRec.Status__c = status;
            iRec.Handler__c = handler;
            iRec.Params__c = '123456789';   
            iRec.Number_Of_Retries__c = noOfRetries;
            
            if(insertNow) {
                insert iRec;
            }

            system.debug('Integration Record created: ' + iRec.Id);
        } catch (Exception e) {           
            throw new CustomException(e.getMessage());
        }        
        
        return iRec;
    }
}
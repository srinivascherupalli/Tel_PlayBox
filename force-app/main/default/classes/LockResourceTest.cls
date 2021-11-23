@isTest
private class LockResourceTest {
    @isTest
    static void Test_httpPost_NoRequest(){ 
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
         
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('');
        RestContext.request = req;
        RestContext.response= res;
        LockResource.doPost(); 
        Test.stopTest();
        System.assertEquals(400, res.statusCode); 
    }
    
    @isTest
    static void Test_httpPostUCDM_LockNumber_InvalidNumbers(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["12345"],"ranges":[{"startNumber":"11","endNumber":"15"}]}]}';
           
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.httpMethod = 'POST';
        req.addHeader('Source-System', 'UCDM');
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }

    @isTest
    static void Test_httpPostUCDM_LockNumber_NotFoundNumbers(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61000000000"],"ranges":[{"startNumber":"61000000001","endNumber":"61000000002"}]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.httpMethod = 'POST';
        req.addHeader('Source-System', 'UCDM');
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
    
    @isTest
    static void Test_httpPostUCDM_LockNumbersInvalid(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61352426230","61352426233"],"ranges":[{"startNumber":"61352426220","endNumber":"61352426223"}]}]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.httpMethod = 'POST';
        req.addHeader('Source-System', 'UCDM');
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        List<Number__C> nbrList = new List<Number__C> ();
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426230','61352426233'}, 'Active');
        nbrList.addAll(SYS_TestDataFactory.createNumbers(new List<String>{'61352426220','61352426221','61352426222','61352426223'}, 'Disconnected'));
        for(Number__C num : nbrList){
            num.Mobile__c = 'Fixed';
        }
        insert nbrList;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
    
    @isTest
    static void Test_httpPostUCDM_UnlockNumbersInvalid(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Unlock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61352426230","61352426231"],"ranges":[{"startNumber":"61352426220","endNumber":"61352426223"}]}]}';
   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        List<Number__C> nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426230','61352426231'}, 'Active');
        nbrList[0].Locked_By__c = 'UCDM';
        insert nbrList;
        
        nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61352426220','61352426221','61352426222','61352426223'}, 'Disconnected');
        insert nbrList;
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }
    
    @isTest
    static void Test_httpPostUCDM_LockNumbersValid(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61000000001","61000000002"],"ranges":[]}]}';
 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        List<Number__C> nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61000000001','61000000002'}, 'Active');
        for(Number__C num : nbrList) {
            num.Start_Range__c = '61000000001';
            num.End_range__c  = '61000000002';
            num.Mobile__c ='Fixed';
        }
        insert nbrList;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(200, res.statusCode);
    }
    
    @isTest
    static void Test_httpPostUCDM_UnlockNumbersValid(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Unlock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61000000001","61000000002"],"ranges":[]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        List<Number__C> nbrList = SYS_TestDataFactory.createNumbers(new List<String>{'61000000001','61000000002'}, 'Locked');
        for(Number__C num : nbrList) {
            num.Start_Range__c = '61000000001';
            num.End_range__c  = '61000000002';
            num.Locked_By__c = 'UCDM';
            num.Mobile__c ='Fixed';
        }
        insert nbrList;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(200, res.statusCode);
    }   

    @isTest
    static void Test_httpPost_validateLockUnlockRequest_NullActionType(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61352426230","61352426231"],"ranges":[]}]}';
   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }  

    @isTest
    static void Test_httpPost_validateLockUnlockRequest_ABCActionType(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"abc","reason":"Lock for Disconnect","numbers":[{"singleNumbers":["61352426230","61352426231"],"ranges":[]}]}';

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }  

    @isTest
    static void Test_httpPost_validateLockUnlockRequest_NoNumbers(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[],"ranges":[]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    }  

    @isTest
    static void Test_httpPost_validateLockUnlockRequest_InvalidRange(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[],"ranges":[{"startNumber":"","endNumber":"61352426223"}]}]}';
 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 

    @isTest
    static void Test_httpPost_validateLockUnlockRequest_NullReasonForLock(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"","numbers":[{"singleNumbers":[],"ranges":[{"startNumber":"","endNumber":"61352426223"}]}]}';
 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM'); 
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 

    @isTest
    static void Test_httpPost_validateNumbers_InvalidStartRange(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[],"ranges":[{"startNumber":"613524262","endNumber":"61352426223"}]}]}';
 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 

    @isTest
    static void Test_httpPost_validateNumbers_InvalidEndRange(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[],"ranges":[{"startNumber":"61352426223","endNumber":"613524262"}]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 

    @isTest
    static void Test_httpPost_validateNumbers_InvalidRange(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[],"ranges":[{"startNumber":"61352426226","endNumber":"61352426223"}]}]}';
   
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 

    @isTest
    static void Test_httpPost_validateNumbers_singleNumbers(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"singleNumbers":[613524262],"ranges":[{"startNumber":"61352426223","endNumber":"61352426228"}]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
         

        
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 
    @isTest
    static void testNetworkServiceId(){
        Test.startTest();
        String jsonstring = '{"networkServiceId":"test","actionType":"Lock","reason":"Lock for Disconnect","numbers":[{"ranges":[{"startNumber":"61352426223","endNumber":"61352426228"}]}]}';
  
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/v1/lock-resource-c2o';
        req.addHeader('Source-System', 'UCDM');
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonstring);
        RestContext.request = req;
        RestContext.response= res;
        LockResource.doPost();
        Test.stopTest();
        System.assertEquals(400, res.statusCode);
    } 
}
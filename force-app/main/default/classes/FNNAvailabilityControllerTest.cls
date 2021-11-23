@isTest
private class FNNAvailabilityControllerTest {
    private static String fnnString = '';
 	
    //Token Test
    /*@isTest static void testToken() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockSQServiceResponseGenerator());
        String token = AuthenticationManager.getOauthToken('SQSiteCheck');
        system.debug('>>>'+token);
        Test.stopTest();
		//System.assertEquals('tElsAddR32156teSt', token);
    }*/
    
    //Success Test for Interface
    @isTest static void searchCheckFNNCase1(){
        fnnString = '["1300000086","1800000011","0700000000"]';
		Map<String, FNNManager> fnnMap= new Map<String, FNNManager>();
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQNUMBERPORTABILITY));       
		fnnMap = FNNAvailabilityController.checkFNN(fnnString);
        Test.stopTest();
        
        System.assertEquals(true, fnnMap!=null);
        System.assertEquals(fnnMap.get('1300000086').reason,'The FNN cannot be ported into Telstra network as the given FNN status is ACTIVE');
		System.assertEquals(fnnMap.get('1800000011').reason,'The FNN is managed by Telstra');
		System.assertEquals(fnnMap.get('0700000000').reason,'FNN not found');                            
    }
    
    //Failure of FNN validation case
    @isTest static void searchCheckFNNCase2(){
        fnnString = '["0100000000","1800000011","0700000000"]';
		Map<String, FNNManager> fnnMap= new Map<String, FNNManager>();
        Test.startTest();
		Test.setMock(HttpCalloutMock.class, new MockSQServiceSuccessResponseGenerator(MockSQServiceSuccessResponseGenerator.SUCCESSTEST_SQNUMBERPORTABILITY));       
		fnnMap = FNNAvailabilityController.checkFNN(fnnString);
        Test.stopTest();
        
        System.assertEquals(true, fnnMap!=null);
        System.assertEquals(fnnMap.get('0100000000').reason,System.Label.ERROR_INVALID_FNN);
		System.assertEquals(fnnMap.get('1800000011').reason,'');
		System.assertEquals(fnnMap.get('0700000000').reason,'');                            
    }
    
    //Add fnn case
    @isTest static void checkInitalizeInput(){
        List<String> fnnList = new List<String>();
       	Integer fnnListSize=fnnList.size();
        Test.startTest();
        fnnList=FNNAvailabilityController.initalizeInput();
        Test.stopTest();
        system.assertEquals(fnnList.size(),fnnListSize+1);
    }
    
    //Exception case
    @isTest static void searchCheckFNNCase3(){
        fnnString = null;
		Map<String, FNNManager> fnnMap= new Map<String, FNNManager>();
        Test.startTest();
		fnnMap = FNNAvailabilityController.checkFNN(fnnString);
        Test.stopTest();        
        System.assertEquals(false, fnnMap!=null);                            
    }
    
    //failure of validateFnnNumber
    @isTest static void validateFnnNumberFailureCase(){
        try{
        fnnString = null;
        Test.startTest();
		Boolean valid = FNNAvailabilityController.validateFnnNumber(fnnString);
        Test.stopTest();                                
        }
        catch(Exception e){
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest static void checkPortabilityFailureCase(){
        		Map<String, FNNManager> fnnMap= new Map<String, FNNManager>();
        try{
        fnnString = null;
        Test.startTest();
		fnnMap = FNNAvailabilityController.checkPortability(fnnString);
        Test.stopTest();                                
        }
        catch(Exception e){
            System.assertEquals('null input to JSON parser', e.getMessage());
        }
    }
    
    @isTest static void getResultFailureCase(){
        Map<String, FNNManager> fnnMap= new Map<String, FNNManager>();
        try{
		PortInSQResponseDTO sqResDTO=null;
        Test.startTest();
		fnnMap = FNNAvailabilityController.getResult(sqResDTO);
        Test.stopTest();                                
        }
        catch(Exception e){
            System.assertEquals('Attempt to de-reference a null object', e.getMessage());
        }
    }

}
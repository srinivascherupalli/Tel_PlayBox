@isTest
public class ValidateSIMInterfaceTest {
    
    @isTest
    static void testValidateSimSerial_200(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        Boolean imsiRequired = false;
        Boolean allRequired = false;
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Success',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,imsiRequired,allRequired,names);
         system.assertNotEquals(null, resMap);
    }
    
     @isTest
    static void testValidateSimSerial_200_partial(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
         List<SimResponseDTO.errors> errList = new List<SimResponseDTO.errors>();
        SimResponseDTO.errors err = new SimResponseDTO.errors();
        err.simNumber='89610182000501374302';
        err.message='SIM details not found';
        err.code ='LRM-RESOURCE_NOT_FOUND';
        errList.add(err);
        
        Boolean imsiRequired = false;
        Boolean allRequired = false;
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(200,'Partial Success',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,imsiRequired,allRequired,names);
         system.assertNotEquals(null, resMap);
    }
    
    @isTest
    static void testValidateSimSerial_422(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
       Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>() ;
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        Boolean imsiRequired = false;
        Boolean allRequired = false;
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(422,'Validation errors',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,imsiRequired,allRequired,names);
       //  List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
       //  system.assertEquals(code, 422);
         system.assertNotEquals(null, resMap);
    }
    
    @isTest
    static void testValidateSimSerial_404(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(404,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,null,null,names);
       // List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
        //system.assertEquals(code, 404);
         system.assertNotEquals(null, resMap);
    }
    
    @isTest
    static void testValidateSimSerial_400(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(400,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,null,null,names);
       // List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
        //system.assertEquals(code, 404);
         system.assertNotEquals(null, resMap);
    }
    
    @isTest
    static void testValidateSimSerial_500(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(500,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,null,null,names);
       // List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
        //system.assertEquals(code, 404);
         system.assertNotEquals(null, resMap);
    }

     @isTest
    static void testValidateSimSerial_502(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(502,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,null,null,names);
       // List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
        //system.assertEquals(code, 404);
         system.assertNotEquals(null, resMap);
    }

     @isTest
    static void testValidateSimSerial_401(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        simSerialNumbersMap.put('89610182000501374304','eSIM');
        simSerialNumbersMap.put('89610182000501374402','SIM Card');
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(401,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,null,null,names);
       // List<String> rescode = new List<String>();
       // rescode.addAll(resMap.keyset());
        //Integer code = Integer.ValueOf(rescode[0]);
        //system.assertEquals(code, 404);
         system.assertNotEquals(null, resMap);
    }
    
    @isTest
    static void testValidateSimSerialEmptyResponse(){
        Map<String,String> simSerialNumbersMap=new Map<String,String>();
         Map<String,Map<String,String>> resMap=new Map<String,Map<String,String>>();
        Boolean imsiRequired = false;
        Boolean allRequired = false;
        List<String> names=new List<String>();
        names.add('SIM Type');
        names.add('SIM Category');
        names.add('Order ID');
        Test.setMock(HttpCalloutMock.class, new MockLRMResponseGenerator(422,'Error : Not Found',null));
        resMap = ValidateSIMInterface.ValidateSimSerial(simSerialNumbersMap,imsiRequired,allRequired,names);
        List<String> resultList=new List<String>();
        resultList.addAll(resMap.keyset());
        system.assertEquals('LRM Failure',resultList[0]);
    }


}
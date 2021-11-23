/*------------------------------------------------------------ 
Author: Kalashree Borgaonkar 
Description: Test class for Address Trigger
History 
<19-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
@isTest
public class AddressTriggerHandlerTest {
    //Creating custom setting records.
    @testSetup static void setup() {
        TCM_EAST_AddressType__c eastAddress = new TCM_EAST_AddressType__c(name = 'ALLOTMENT',addressType__c='A',addressTypeCode__c='ALLOTMENT');
        insert eastAddress;
        TCM_EAST_Street_Type__c streetType = new TCM_EAST_Street_Type__c(name = 'ACCESS',StreetType__c='Access',streetTypeCode__c='ACCS');
        insert streetType;      
    }
	/*------------------------------------------------------------ 
EDGE - 39902,
Method: getAddressTypeForTCMManage 
Description: This method returns addressType value for TCM manage call
Inputs: addressType
Returns: addressType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @isTest
    public static void test_NoParent_NoSubAddr(){
        Test.startTest();
        String addrType = AddressTriggerHandler.getAddressTypeForTCMManage(null,'0','ALLOTMENT');
        System.assertNOTEquals(addrType=='A',true,'success');
        Test.stopTest();
    }
     @isTest
    public static void test_Parent_SubAddr_null(){
        Test.startTest();
        String addrType = AddressTriggerHandler.getAddressTypeForTCMManage(null,null,'ALLOTMENT');
       System.assertEquals(addrType=='',true,'success');
         Test.stopTest();
    }
     @isTest
    public static void test_Parent_SubAddrs_null(){
         Test.startTest();
        String addrType = AddressTriggerHandler.getAddressTypeForTCMManage(null,'1','ALLOTMENT');
        System.assertEquals(addrType=='',true,'success');
         Test.stopTest();
    }
   
     @isTest
    public static void test_Parent_NoSubAddr(){
         Test.startTest();
        String addrType = AddressTriggerHandler.getAddressTypeForTCMManage('Parent','0','ALLOTMENT');
        System.assertEquals(addrType=='A',true,'success');
         Test.stopTest();
    }
    
     @isTest
    public static void test_Parent_SubAddr(){
         Test.startTest();
        String addrType = AddressTriggerHandler.getAddressTypeForTCMManage('Parent','1','ALLOTMENT');
        System.assertEquals(addrType=='A',true,'success');
         Test.stopTest();
    }
   
    /*------------------------------------------------------------ 
EDGE - 39902,
Method: getAddressType 
Description: This method returns addressType from TCM_EAST_AddressType__c custom setting
Inputs: addressType
Returns: addressType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @isTest
    public static void test_getAddressType(){
        Test.startTest();
        String addressType = AddressTriggerHandler.getAddressType('ALLOTMENT'); 
        System.assertEquals(addressType=='A',true,'success');
         Test.stopTest();
    }
    
 /*------------------------------------------------------------ 
EDGE - 39902,
Method: getStreetTypeForTCMManage 
Description: This method returns streetType from TCM_EAST_Street_Type__c custom setting
Inputs: addressType
Returns: addressType for payload
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    @isTest
    public static void test_getStreetTypeForTCMManage(){
         Test.startTest();
        String addressType = AddressTriggerHandler.getStreetTypeForTCMManage('Access');
        System.assertEquals(addressType=='ACCS',true,'success');
         Test.stopTest();
    }
    
    /*------------------------------------------------------------ 
Story: EDGE-122626
Author: Kalashree Borgaonkar
Method: onBeforeInsertUpdateTest 
Description: Update address status
Inputs: List of cscrm__Address__c
------------------------------------------------------------*/
     @isTest
    public static void onBeforeInsertUpdateTest(){
        List<cscrm__Address__c> listAddress=new List<cscrm__Address__c>();
        cscrm__Address__c add = new cscrm__Address__c ();
        add.Address_Status__c='UN';
        add.Address_ID__c='987654';
        listAddress.add(add);
        cscrm__Address__c add1 = new cscrm__Address__c ();
        add1.Address_Status__c='CO';
        add1.Address_ID__c='987653';
        listAddress.add(add1);
        Test.startTest();
        insert listAddress;
        Test.stopTest();
        System.assertEquals([SELECT count() FROM cscrm__Address__c WHERE Address_Status__c IN ('CO','UN')]==0, true, 'Status updated');
    }
    @isTest
    public static void testRunOnce(){
        AddressTriggerHandler.run=false;
        Test.startTest();
        Boolean runner = AddressTriggerHandler.runOnce();
        System.assertEquals(runner=true, true,'true');
        Test.stopTest();
    }
    
}
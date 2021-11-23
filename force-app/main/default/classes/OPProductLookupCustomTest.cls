/**
 * Class for OPProductLookupCustom test.
 */
@isTest
private class OPProductLookupCustomTest {

    public static OPProductLookupCustom opProductLookup;
    
    @isTest
    static void getRequiredAttributes() {
        Test.startTest();
        opProductLookup =  new OPProductLookupCustom();
        String attList = opProductLookup.getRequiredAttributes();
        Test.stopTest();
        System.assert(attList.contains('Product'));
    }
    
    @isTest
    static void getUniqueListByField_WillReturnEmpty_WhenPassEmptyPIList() {
        Test.startTest();
        opProductLookup =  new OPProductLookupCustom();
        List<cspmb__Price_Item__c> pis = opProductLookup.getUniqueListByField(new List<cspmb__Price_Item__c>(), 'Product');
        Test.stopTest();
        System.assertEquals(0, pis.size());
    }
    
    @isTest
    static void getUniqueListByField_WillReturnValues() {
        Test.startTest();
        opProductLookup =  new OPProductLookupCustom();
        List<cspmb__Price_Item__c> pis = opProductLookup.getUniqueListByField(getPIList(), 'Product');
        Test.stopTest();
        System.assertEquals(1, pis.size());
    }
    
    @isTest static void doLookupSearchTest()
    {
        Test.startTest();
        getPIList();
        opProductLookup =  new OPProductLookupCustom();
        Object[] piList = opProductLookup.doLookupSearch(new Map<String, String>{'Product' => 'DOT on Copper'},null,null,null,null);
        Test.stopTest();
        System.assertEquals(1, piList.size());
    }
    
    @isTest static void doLookupSearchTest_WhenSearchValueMatches()
    {
        Test.startTest();
        getPIList();
        opProductLookup =  new OPProductLookupCustom();
        Object[] piList = opProductLookup.doLookupSearch(new Map<String, String>{'Product' => 'DOT on Copper', 'searchValue' => 'DOT'},null,null,null,null);
        Test.stopTest();
        System.assertEquals(1, piList.size());
    }
    
    private static List<cspmb__Price_Item__c> getPIList() {
        List<cspmb__Price_Item__c> pis = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c piObj = ProductTestFactory.buildPriceItemForOpportunityProduct('DOT on Copper',0.00,0.00,'DOT on Copper','DOT Core Plans','Wall Mount Bracket T42','24');
        insert piObj;   
        piObj = [SELECT name, OP_Product__c, OP_Type__c, OP_Option__c, OP_Contract_Term__c, id, cspmb__One_Off_Charge__c, cspmb__Recurring_Charge__c 
                 FROM cspmb__Price_Item__c 
                 WHERE id = :piObj.id ];
        pis.add(piObj);
        return pis;
    }
}
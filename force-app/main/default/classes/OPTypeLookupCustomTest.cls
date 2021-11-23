/**
 * Class for OPTypeLookupCustom test.
 */
@isTest
private class OPTypeLookupCustomTest {

    public static OPTypeLookupCustom opTypeLookup;
    
    @isTest
    static void getRequiredAttributes() {
        Test.startTest();
        opTypeLookup =  new OPTypeLookupCustom();
        String attList = opTypeLookup.getRequiredAttributes();
        Test.stopTest();
        System.assert(attList.contains('ProductSelected'));
    }
    
    @isTest
    static void getUniqueListByField_WillReturnEmpty_WhenPassEmptyPIList() {
        Test.startTest();
        opTypeLookup =  new OPTypeLookupCustom();
        List<cspmb__Price_Item__c> pis = opTypeLookup.getUniqueListByField(new List<cspmb__Price_Item__c>(), 'Type');
        Test.stopTest();
        System.assertEquals(0, pis.size());
    }
    
    @isTest
    static void getUniqueListByField_WillReturnValues() {
        Test.startTest();
        opTypeLookup =  new OPTypeLookupCustom();
        List<cspmb__Price_Item__c> pis = opTypeLookup.getUniqueListByField(getPIList(), 'Type');
        Test.stopTest();
        System.assertEquals(1, pis.size());
    }
    
    @isTest static void doLookupSearchTest()
    {
        Test.startTest();
        getPIList();
        opTypeLookup =  new OPTypeLookupCustom();
        Object[] piList = opTypeLookup.doLookupSearch(new Map<String, String>{'ProductSelected' => 'DOT on Copper'},null,null,null,null);
        Test.stopTest();
        System.assertEquals(1, piList.size());
    }
    
    @isTest static void doLookupSearchTest_WhenSearchValueMatches()
    {
        Test.startTest();
        getPIList();
        opTypeLookup =  new OPTypeLookupCustom();
        Object[] piList = opTypeLookup.doLookupSearch(new Map<String, String>{'ProductSelected' => 'DOT on Copper', 'searchValue' => 'DOT'},null,null,null,null);
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
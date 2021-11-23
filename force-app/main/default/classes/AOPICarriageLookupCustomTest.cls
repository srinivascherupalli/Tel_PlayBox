@isTest
private class AOPICarriageLookupCustomTest {
	public static AOPICarriageLookupCustom cLookup;
    
    @isTest
    static void getRequiredAttributes_WillRetuenLiistOf4() {
        Test.startTest();
            cLookup =  new AOPICarriageLookupCustom();
            String attList = cLookup.getRequiredAttributes();
        Test.stopTest();
        System.assert(attList.contains('Access Type'));
        System.assert(attList.contains('Class Of Service'));
    }
    
    @isTest
    static void getUniqueListByField_WillReturnEmpth_WhenPassEmptyAOPIAList() {
        Test.startTest();
            cLookup =  new AOPICarriageLookupCustom();
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopias = cLookup.getUniqueListByField(new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>(), 'AccessType');
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
    @isTest
    static void getUniqueListByField_WillReturnAccessTypes_WhenPassAccessTypeAsField() {
        Test.startTest();
            cLookup =  new AOPICarriageLookupCustom();
        	List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopias = cLookup.getUniqueListByField(getAOPIAList(), 'AccessType');
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void getUniqueListByField_WillReturnAccessConfiguration_WhenPassAccessConfigurationAsField() {
        Test.startTest();
            cLookup =  new AOPICarriageLookupCustom();
        	List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopias = cLookup.getUniqueListByField(getAOPIAList(), 'AccessConfiguration');
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void getUniqueListByField_WillReturnClassOfService_WhenPassClassOfServiceAsField() {
        Test.startTest();
            cLookup =  new AOPICarriageLookupCustom();
        	List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopias = cLookup.getUniqueListByField(getAOPIAList(), 'ClassOfService');
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessTypes_WhenNoAttributesAreDefined() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        	 Object[] aopias = cLookup.doLookupSearch(new Map<String, String>(), null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessTypes_WhenAccessTypeMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessTypes_WhenAccessTypeMatchWithSearchValue() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'searchValue' => 'NB'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnCOS_WhenCOSMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COS'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnCOS_WhenCOSMatchSearch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COS', 'searchValue' => 'NBN'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnCOS_WhenCOSNoMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COSNA'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
        @isTest
    static void doLookupSearch_WillReturnPlanName_WhenPlanNameMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COS', 'Plan Name' => 'NBN Plan'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnPlanName_WhenPlanNameMatchSearch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COS', 'Plan Name' => 'NBN Plan', 'searchValue' => 'NBN'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnPlanName_WhenPlanNameNoMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'Class Of Service' => 'NBN COS', 'Plan Name' => 'NBN PlanNA'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
    
    @isTest
    static void doLookupSearch_WillReturnAccessConfig_WhenAccessConfigMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessConfig_WhenAccessConfigMatchSearch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'searchValue' => 'NBN'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(1, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessConfig_WhenAccessConfigMatchSearchNoMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config', 'searchValue' => 'TEST'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnAccessConfig_WhenAccessConfigNoMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'NBN', 'Access Configuration' => 'NBN Config NA'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
    @isTest
    static void doLookupSearch_WillReturnEmpty_WhenAccessTypeNoMatch() {
        Test.startTest();
        	getAOPIAList();
            cLookup =  new AOPICarriageLookupCustom();
        Object[] aopias = cLookup.doLookupSearch(new Map<String, String>{'Access Type' => 'TEST'}, null, null, null, null);
        Test.stopTest();
        System.assertEquals(0, aopias.size());
    }
    
    private static List<cspmb__Price_Item_Add_On_Price_Item_Association__c> getAOPIAList() {
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopias = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        cspmb__Price_Item_Add_On_Price_Item_Association__c aopia = ProductTestService.createPricingData('TIP', 'Carriage Access', 'Carriage Access', 'NBN', 'NBN Config', 'NBN COS','NBN Plan');
        aopia = [SELECT cspmb__add_on_price_item__r.access_type__c, 
                 	cspmb__add_on_price_item__r.access_configuration__c,
                 	cspmb__add_on_price_item__r.class_of_service__c,
                 	cspmb__add_on_price_item__r.plan_name__c  
                 FROM cspmb__Price_Item_Add_On_Price_Item_Association__c 
                 WHERE id = :aopia.id ];
        
        aopias.add(aopia);
        return aopias;
    }
}
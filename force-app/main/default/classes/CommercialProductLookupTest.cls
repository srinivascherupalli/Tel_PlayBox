/***********************************************************************************************************
Name          : CommercialProductLookupTest
Created By    : Ramcharan Patidar
Created Date  : Dec 19 2020
Description   : This is a test class to Search LookupC and test the logic of CommercialProductLookup
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           --------- 
v1.0     Ramcharan Patidar  19-DEC-2020    CommercialProductLookupTest
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class CommercialProductLookupTest {
    
    
    /******************************************************************************************************
    * Method Name : doCommercialProductLookupTest
    * Description : Used to simulate and test the logic of doCommercialProductLookupTest method in CommercialProductLookup
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void doCommercialProductLookupTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        List<cspmb__Price_Item__c> pis = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c product1 = new cspmb__Price_Item__c(Name='Test Product');
        cspmb__Price_Item__c plan1 = new cspmb__Price_Item__c(Name='Test Plan');
        pis.add(product1);
        pis.add(plan1);
        insert pis;
               
        Product_To_Product_Association__c productToPrdtAssc = new Product_To_Product_Association__c(Governing_Product__c=product1.id,Governed_Product__c=plan1.id,Governed_Attribute_Name__c = 'PlanDiscount' ,Effective_End_Date__c = system.Today()+1, Effective_Start_Date__c= system.Today()-2);
        insert productToPrdtAssc;
        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('srvListString','Enterprise SRV List');
        String productDefinitionId ;
        Integer pageOffset = 5;
        Integer pageLimit = 2;
        Id[] excludeIds;
        Test.startTest();
            CommercialProductLookup cpl = new CommercialProductLookup();
            cpl.getRequiredAttributes();
            cpl.doLookupSearch(searchFields,productDefinitionId, excludeIds, pageOffset, pageLimit);
            cpl.getUniqueListByField(pis, 'name');
        Test.stopTest();
        System.assertEquals(1, searchFields.size());
        System.assertNotEquals(true, pis.isEmpty());
        System.assert(searchFields.containsKey('srvListString'));
    }

    static testmethod void doCommercialProductLookupTestWhenSearchValueIsPresent() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        List<cspmb__Price_Item__c> pis = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c product1 = new cspmb__Price_Item__c(Name='Test Product');
        cspmb__Price_Item__c plan1 = new cspmb__Price_Item__c(Name='Test Plan');
        pis.add(product1);
        pis.add(plan1);
        insert pis;
               
        Product_To_Product_Association__c productToPrdtAssc = new Product_To_Product_Association__c(Governing_Product__c=product1.id,Governed_Product__c=plan1.id,Governed_Attribute_Name__c = 'PlanDiscount' ,Effective_End_Date__c = system.Today()+1, Effective_Start_Date__c= system.Today()-2);
        insert productToPrdtAssc;
        Map<String, String> searchFields = new Map<String, String>();
        searchFields.put('srvListString','Enterprise SRV List');
        searchFields.put('searchValue','Business');
        searchFields.put('domainString','Data  & IP');
        String productDefinitionId ;
        Integer pageOffset = 5;
        Integer pageLimit = 2;
        Id[] excludeIds;
        Test.startTest();
            CommercialProductLookup cpl = new CommercialProductLookup();
            cpl.getRequiredAttributes();
            cpl.doLookupSearch(searchFields,productDefinitionId, excludeIds, pageOffset, pageLimit);
            cpl.getUniqueListByField(pis, 'name');
        Test.stopTest();
        System.assertEquals(3, searchFields.size());
        System.assertNotEquals(true, pis.isEmpty());
        System.assert(searchFields.containsKey('srvListString'));
    }
}
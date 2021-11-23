/***********************************************************************************************************
Name          : FamilyLookupTest
Created By    : Ramcharan Patidar
Created Date  : Dec 19 2020
Description   : This is a test class to Search Lookup and test the logic of FamilyLookup
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           --------- 
v1.0     Ramcharan Patidar  19-DEC-2020    FamilyLookupTest
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
public class FamilyLookupTest {
    
    
    /******************************************************************************************************
    * Method Name : doFamilyLookupTest
    * Description : Used to simulate and test the logic of doFamilyLookupTest method in FamilyLookup
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void doFamilyLookupTest() {
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
            FamilyLookup fl = new FamilyLookup();
            fl.getRequiredAttributes();
            fl.doLookupSearch(searchFields,productDefinitionId, excludeIds, pageOffset, pageLimit);
            fl.getUniqueListByField(pis, 'Product_Family__c');
        Test.stopTest();
        System.assertEquals(1, searchFields.size());
        System.assertNotEquals(true, pis.isEmpty());
        System.assert(searchFields.containsKey('srvListString'));
    }
}
/*******************************************************************************************************************
    Class Name : flushCacheCotroller 
====================================================================================================================
Sr.No.    Developer Name           Date            Story Description
1.        Shubhi V                05/07/2021        EDGE-224336
====================================================================================================================
********************************************************************************************************************/
@isTest
public class flushCacheControllerTest {
	
    @testSetup public static void testdatasetup(){
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_000965';
   		insert pd;  
    }

    @isTest
    public static void testonload(){
        cscfga__Product_Definition__c pd=[select id from cscfga__Product_Definition__c limit 1];
        Test.startTest();
        ApexPages.standardController stdCon = new ApexPages.standardController(pd);
        flushCacheController controller = new flushCacheController(stdCon);
        PageReference pr=controller.onload();
        system.assert(pd!=null);
        
    }

}
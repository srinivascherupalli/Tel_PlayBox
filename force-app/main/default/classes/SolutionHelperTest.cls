/***********************************************************************************************************
Name          : SolutionHelperTest
Created By    : Mahaboob Basha
Created Date  : Jun 11 2019
Description   : This is a test class to simulate and test the logic of SolutionHelper
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        11-06-2019      Created
1.1         Mahaboob        11-06-2019      Added methods getUserAttributeDetailsTest, getUserUnitPriceTest
                                                        , getIPSiteBandwidthTest
1.2         Venkata Ramanan 21-07-2019      Added methods getUserTotalETCTest,getDeviceMROBonusTest

1.3			Jayesh			30-07-2019		Added method getUCEUserAttributeDetails
**********************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class SolutionHelperTest {
    
    /******************************************************************************************************

    * Method Name : getUCEUserAttributeDetails
    * Description : Used to simulate and test the logic of getUserAttributeDetails method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getUCEUserAttributeDetails() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('Offer Id', '1');
        cspmb__Price_Item__c userPI = new cspmb__Price_Item__c(Name = 'User', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'User', Package_Name__c = 'Telstra Collaboration', Type__c = 'User', Zone__c = '1', cspmb__Effective_End_Date__c = System.today().addDays(1), cspmb__Effective_Start_Date__c = System.today().addDays(-1));
        INSERT userPI;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('User'));
    }
	
    /******************************************************************************************************
    * Method Name : getUserAttributeDetailsTest
    * Description : Used to simulate and test the logic of getUserAttributeDetails method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getUserAttributeDetailsTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('siteNetworkZone', '1');
        cspmb__Price_Item__c userPI = new cspmb__Price_Item__c(Name = 'User', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'User', Package_Name__c = 'Connected Workplace', Type__c = 'Fixed Seat', Zone__c = '1', cspmb__Effective_End_Date__c = System.today().addDays(1), cspmb__Effective_Start_Date__c = System.today().addDays(-1));
        INSERT userPI;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('User'));
    }
    
    /******************************************************************************************************
    * Method Name : getUserUnitPriceTest
    * Description : Used to simulate and test the logic of getUserUnitPrice method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getUserUnitPriceTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('TypeUser', 'Fixed Seat');
        inputMap.put('ZonefromParent', '1');
        cspmb__Price_Item__c userPI = new cspmb__Price_Item__c(Name = 'User', cspmb__Is_Active__c = TRUE, cspmb__Product_Definition_Name__c = 'User', Package_Name__c = 'Connected Workplace', Type__c = 'Fixed Seat', Zone__c = '1', cspmb__Effective_End_Date__c = System.today().addDays(1), cspmb__Effective_Start_Date__c = System.today().addDays(-1));
        INSERT userPI;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('User'));
    }
    
    /******************************************************************************************************
    * Method Name : getIPSiteBandwidthTest
    * Description : Used to simulate and test the logic of getIPSiteBandwidth method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getIPSiteBandwidthTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('CountTotalUserQty', '1');
        inputMap.put('TierSelected', '1');
        inputMap.put('Technology', 'Telstra Fibre');
        Bandwidth_Calculation__c bwCalc = new Bandwidth_Calculation__c(Count_Bandwidth_Clip_On__c = 1, Max_User_Count__c = 3, Min_User_Count__c = 0, Technology__c = 'Telstra Fibre');
        INSERT bwCalc;
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('IPSite'));
    }

    /******************************************************************************************************
    * Method Name : getUserTotalETCTest
    * Description : Used to simulate and test the logic of getUserTotalETC method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getUserTotalETCTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        inputMap.put('Quantity', '1');
        inputMap.put('TypeUser', 'Fixed Seat');
        inputMap.put('DisconnectionDate', String.valueof(system.today()-1));
        cscfga__Product_Configuration__c prdconfig = new cscfga__Product_Configuration__c(name='Test Prdconfig');
        INSERT prdconfig;
        inputMap.put('ProdConfigId', prdconfig.id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('User'));
    }
    /******************************************************************************************************
    * Method Name : getDeviceMROBonusTest
    * Description : Used to simulate and test the logic of getDeviceMROBonus method in SolutionHelper
    * Parameters  : NA
    * Return      : NA                      
    ******************************************************************************************************/
    static testmethod void getDeviceMROBonusTest() {
        Map<String, Object> inputMap = new Map<String, Object> ();
        cspmb__Price_Item__c product1 = new cspmb__Price_Item__c(Name='Test Product');
        cspmb__Price_Item__c plan1 = new cspmb__Price_Item__c(Name='Test Plan');
        insert product1;
        insert plan1;
        Product_To_Product_Association__c productToPrdtAssc = new Product_To_Product_Association__c(Governing_Product__c=product1.id,Governed_Product__c=plan1.id,Governed_Attribute_Name__c = 'PlanDiscount' ,Effective_End_Date__c = system.Today()+1, Effective_Start_Date__c= system.Today()-2);
        insert productToPrdtAssc;
        inputMap.put('DeviceId', product1.id);
        inputMap.put('PlanId', plan1.id);
        Map<String, Object> returnMap = new Map<String, Object>();
        Test.startTest();
            SolutionHelper sh = new SolutionHelper();
            returnMap = sh.getData(inputMap);
        Test.stopTest();
        System.assertEquals(1, returnMap.size());
        System.assert(returnMap.containsKey('MRO Bonus'));
    }
}
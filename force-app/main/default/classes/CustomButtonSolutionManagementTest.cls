/****************************************************************************************************
Name          : CustomButtonSolutionManagementTest
Created By    : Mahaboob Basha
Created Date  : Jun 12 2019
Description   : This is a test class to simulate and test the logic of CustomButtonSolutionManagement
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        12-06-2019      Created
1.1         Mahaboob        12-06-2019      Added methods performActionTest, performActionTest1
                                                        , performActionTest2
****************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class CustomButtonSolutionManagementTest {
    
    /************************************************************************************************************
    * Method Name : performActionTest
    * Description : Used to simulate and test the logic of performAction method in CustomButtonSolutionManagement
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************************/
    static testmethod void performActionTest() {
        String result;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        csbb__Product_Configuration_Request__c pcr = TestDataFactory.genProdConfRequest('12345', 'Test Config');
        Test.startTest();
            CustomButtonSolutionManagement cbSolMgmt = new CustomButtonSolutionManagement();
            result = cbSolMgmt.performAction(basket.Id, '["' + pcr.Id + '"]');
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
    
    /************************************************************************************************************
    * Method Name : performActionTest1
    * Description : Used to simulate and test the logic of performAction method in CustomButtonSolutionManagement
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************************/
    static testmethod void performActionTest1() {
        String result;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        csbb__Product_Configuration_Request__c pcr = TestDataFactory.genProdConfRequest('12345', 'Test Config');
        csord__Solution__c sol = new csord__Solution__c(Name = 'Test Sol', csord__Identification__c = '12', csord__External_Identifier__c = '123', csord__External_Identifier2__c = '1234');
        INSERT sol;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(Id = pcr.csbb__Product_Configuration__c, cssdm__solution_association__c = sol.Id);
        UPDATE pc;
        Test.startTest();
            CustomButtonSolutionManagement cbSolMgmt = new CustomButtonSolutionManagement();
            result = cbSolMgmt.performAction(basket.Id, '["' + pcr.Id + '"]');
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
    
     /************************************************************************************************************
    * Method Name : performActionTest2
    * Description : Used to simulate and test the logic of performAction method in CustomButtonSolutionManagement
    * Parameters  : NA
    * Return      : NA                      
    ************************************************************************************************************/
    static testmethod void performActionTest2() {
        String result;
        cscfga__Product_Basket__c basket = TestDataFactory.generateProductBasket();
        csbb__Product_Configuration_Request__c pcr = TestDataFactory.genProdConfRequest('12345', 'Test Config');
        csord__Solution__c sol = new csord__Solution__c(Name = 'Test Sol', csord__Identification__c = '12', csord__External_Identifier__c = '123', csord__External_Identifier2__c = '1234');
        INSERT sol;
        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(Id = pcr.csbb__Product_Configuration__c, cssdm__solution_association__c = sol.Id);
        UPDATE pc;
        csbb__Product_Configuration_Request__c pcr1 = TestDataFactory.genProdConfRequest('123456', 'Test Config');
        csord__Solution__c sol1 = new csord__Solution__c(Name = 'Test Sol1', csord__Identification__c = '121', csord__External_Identifier__c = '1231', csord__External_Identifier2__c = '12341');
        INSERT sol1;
        cscfga__Product_Configuration__c pc1 = new cscfga__Product_Configuration__c(Id = pcr1.csbb__Product_Configuration__c, cssdm__solution_association__c = sol1.Id);
        UPDATE pc1;
        Test.startTest();
            CustomButtonSolutionManagement cbSolMgmt = new CustomButtonSolutionManagement();
            result = cbSolMgmt.performAction(basket.Id, '["' + pcr.Id + '"' + ',"' + pcr1.Id + '"]');
        Test.stopTest();
        System.assertNotEquals(NULL, result);
    }
}
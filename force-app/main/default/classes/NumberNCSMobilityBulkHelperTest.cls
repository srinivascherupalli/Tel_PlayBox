/*************************************************************************************************
Name          : NumberNCSMobilityBulkHelperTest
Created By    : Mahaboob Basha
Created Date  : Jun 17 2019
Description   : This is a test class to simulate and test the logic of NumberNCSMobilityBulkHelper
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        17-06-2019      Created
1.1         Mahaboob        17-06-2019      Added methods checkForExistingNCSTest
                                                        , checkForExistingNCSTest1
                                                        , checkForExistingNCSTest2
                                                        , checkForExistingNCSTest3
                                                        , getNumbersFromNCSTest
                                                        , createNewNCSTest, createNewNCSTest1
                                                        , createNewNCSTest2, createNewNCSTest3
                                                        , updateExistingNCSTest
                                                        , deleteExistingNCSTest
                                                        , getTotalCountOfNumbersTest
                                                        , updateNCSForStatusTest
************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class NumberNCSMobilityBulkHelperTest {
    
    /***************************************************************************************************************
    * Method Name : checkForExistingNCSTest
    * Description : Used to simulate and test the logic of checkForExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void checkForExistingNCSTest() {
        Boolean result;
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.checkForExistingNCS(NULL,'');
        Test.stopTest();
        System.assertEquals(FALSE, result);
    }
    
    /***************************************************************************************************************
    * Method Name : checkForExistingNCSTest1
    * Description : Used to simulate and test the logic of checkForExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void checkForExistingNCSTest1() {
        Boolean result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        Blob attBody = Blob.valueOf('{"configurations":[{"listCode":"","Status":"","MobileNumber":"","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.checkForExistingNCS(pc.cscfga__Product_Basket__c,'MobileNumberManagementv1_schema.json');
        Test.stopTest();
        System.assertEquals(TRUE, result);
    }
    
    /***************************************************************************************************************
    * Method Name : checkForExistingNCSTest2
    * Description : Used to simulate and test the logic of checkForExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void checkForExistingNCSTest2() {
        Boolean result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        Blob attBody = Blob.valueOf('{"configurations":[],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.checkForExistingNCS(pc.cscfga__Product_Basket__c,'MobileNumberManagementv1_schema.json');
        Test.stopTest();
        System.assertEquals(FALSE, result);
    }
    
    /***************************************************************************************************************
    * Method Name : checkForExistingNCSTest3
    * Description : Used to simulate and test the logic of checkForExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void checkForExistingNCSTest3() {
        Boolean result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        Blob attBody = Blob.valueOf('Test Body');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.checkForExistingNCS(pc.cscfga__Product_Basket__c,'MobileNumberManagementv1_schema.json');
        Test.stopTest();
        System.assertEquals(FALSE, result);
    }
    
    /*************************************************************************************************************
    * Method Name : getNumbersFromNCSTest
    * Description : Used to simulate and test the logic of getNumbersFromNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    *************************************************************************************************************/
    static testmethod void getNumbersFromNCSTest() {
        List<String> result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        Blob attBody = Blob.valueOf('{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.getNumbersFromNCS(pc.cscfga__Product_Basket__c);
        Test.stopTest();
        System.assertEquals(1, result.size());
    }
    
    /********************************************************************************************************
    * Method Name : createNewNCSTest
    * Description : Used to simulate and test the logic of createNewNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void createNewNCSTest() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.createNewNCS(pc.cscfga__Product_Basket__c, NULL, ncsDTO.configurations,'Mobility');
        Test.stopTest();
        System.assertEquals('Failure', result);
    }
    
    /********************************************************************************************************
    * Method Name : createNewNCSTest1
    * Description : Used to simulate and test the logic of createNewNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void createNewNCSTest1() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.createNewNCS(pc.cscfga__Product_Basket__c, ncs.Name, ncsDTO.configurations,'Mobility');
        Test.stopTest();
        System.assertEquals('Success', result);
    }
    
    /********************************************************************************************************
    * Method Name : createNewNCSTest2
    * Description : Used to simulate and test the logic of createNewNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void createNewNCSTest2() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.createNewNCS(pc.cscfga__Product_Basket__c, ncs.Name, ncsDTO.configurations,'Mobility');
        Test.stopTest();
        System.assertEquals('Failure', result);
    }
    
    /********************************************************************************************************
    * Method Name : createNewNCSTest3
    * Description : Used to simulate and test the logic of createNewNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    ********************************************************************************************************/
    static testmethod void createNewNCSTest3() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.createNewNCS(pc.Id, ncs.Name, ncsDTO.configurations, ncs);
        Test.stopTest();
        System.assertEquals('Failure', result);
    }
    
    /*************************************************************************************************************
    * Method Name : updateExistingNCSTest
    * Description : Used to simulate and test the logic of updateExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    *************************************************************************************************************/
    static testmethod void updateExistingNCSTest() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.updateExistingNCS(pc.Id, ncs.Name, ncsDTO.configurations);
        Test.stopTest();
        System.assertEquals('Success', result);
    }
    
    /*************************************************************************************************************
    * Method Name : updateExistingNCSTest1
    * Description : Used to simulate and test the logic of updateExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    *************************************************************************************************************/
    static testmethod void updateExistingNCSTest1() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.updateExistingNCS(pc.Id, ncs.Name, ncsDTO.configurations, ncs);
        Test.stopTest();
        System.assertEquals('Success', result);
    }
    
    /*************************************************************************************************************
    * Method Name : deleteExistingNCSTest
    * Description : Used to simulate and test the logic of deleteExistingNCS method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    *************************************************************************************************************/
    static testmethod void deleteExistingNCSTest() {
        String result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.deleteExistingNCS(pc.cscfga__Product_Basket__c, ncs.Name, new List<String>{'123456'});
        Test.stopTest();
        System.assertEquals('Success', result);
    }
    
    /*************************************************************************************************************
    * Method Name : getTotalCountOfNumbersTest
    * Description : Used to simulate and test the logic of getTotalCountOfNumbers method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    *************************************************************************************************************/
    static testmethod void getTotalCountOfNumbersTest() {
        Integer result;
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            result = nmMobBulkHelper.getTotalCountOfNumbers(pc.Id);
        Test.stopTest();
        System.assertEquals(1, result);
    }
    
    /**************************************************************************************************************
    * Method Name : updateNCSForStatusTest
    * Description : Used to simulate and test the logic of updateNCSForStatus method in NumberNCSMobilityBulkHelper
    * Parameters  : NA
    * Return      : NA                      
    **************************************************************************************************************/
    static testmethod void updateNCSForStatusTest() {
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        String jsonStr = '{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"123456","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}';
        Blob attBody = Blob.valueOf(jsonStr);
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        csoe__Non_Commercial_Schema__c ncs = new csoe__Non_Commercial_Schema__c(Name = 'MobileNumberManagementv1');
        INSERT ncs;
        NumberNCSMobilityDTO ncsDTO = NumberNCSMobilityDTO.parse(jsonStr);
        Test.startTest();
            NumberNCSMobilityBulkHelper nmMobBulkHelper = new NumberNCSMobilityBulkHelper();
            nmMobBulkHelper.updateNCSForStatus(pc.Id);
        Test.stopTest();
        System.assert(att != null);
    }
}
/**********************************************************************************************
Name          : NMMobilityBulkControllerTest
Created By    : Mahaboob Basha
Created Date  : Jun 17 2019
Description   : This is a test class to simulate and test the logic of NMMobilityBulkController
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        17-06-2019      Created
1.1         Mahaboob        17-06-2019      Added methods NMMobilityBulkControllerTest
                                                        , NMMobilityBulkControllerTest1
                                                        , NMMobilityBulkControllerTest2
                                                        , NMMobilityBulkControllerTest3
                                                        , NMMobilityBulkControllerTest4
                                                        , NMMobilityBulkControllerTest5
                                                        , NMMobilityBulkControllerTest6
                                                        , NMMobilityBulkControllerTest7
**********************************************************************************************/
@isTest(SeeAllData=FALSE)
private class NMMobilityBulkControllerTest {
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTestTest() {
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', '');
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
        Test.stopTest();
        System.assertEquals(true, nmMobBulkCtrl.basketId!=null);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest1
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest1() {
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        Blob attBody = Blob.valueOf('{"configurations":[{"listCode":"","Status":"","MobileNumber":"","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
        Test.stopTest();
        System.assertEquals('New', nmMobBulkCtrl.reqType);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest2
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest2() {
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        Blob attBody = Blob.valueOf('{"configurations":[{"listCode":"","Status":"RESERVED","MobileNumber":"1234567890","SolutionId":"a4f4Y00000002AKQAY","guid":"7df970ec-0cce-4032-f835-36534561a868"}],"schema":{"configurations":[],"attributes":[{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"guid"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":false,"readOnly":false,"label":"","name":"SolutionId"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"MobileNumber"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"Status"},{"validationErrorMessage":"","helpText":"","errorMessage":"","status":true,"error":false,"other":"","displayValue":"","displayColumn":"","value":"","type":"String","required":false,"showInUi":true,"readOnly":false,"label":"","name":"listCode"}],"id":"a6B4Y00000001b4UAA","showEditButtonOverride":false,"changeType":"","visible":true,"disabled":false,"errorMessage":"","active":false,"error":false,"dirty":true,"max":1,"min":1,"description":"Mobile numbers","name":"MobileNumberManagementv1"}}');
        Attachment att = new Attachment(Name = 'MobileNumberManagementv1_schema.json', Body = attBody, parentId = pc.Id);
        INSERT att;
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
        Test.stopTest();
        System.assertEquals('New', nmMobBulkCtrl.reqType);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest3
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest3() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            nmMobBulkCtrl.getSearchTypes();
        Test.stopTest();
        System.assertEquals('New', nmMobBulkCtrl.reqType);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest4
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest4() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('success_Search'));
        
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            msisdnWrapper.isSelected = true;
            nmMobBulkCtrl.reserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            nmMobBulkCtrl.getSearchTypes();
            nmMobBulkCtrl.clearAll();
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.getToBeReservedQty(10, 5);
            nmMobBulkCtrl.unreserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            //nmMobBulkCtrl.unreserveSelected();
            nmMobBulkCtrl.reserveSelected();
            nmMobBulkCtrl.createReserveWrap(new List<String>{'123'});
            list<String> numbers = nmMobBulkCtrl.searchMSISDN();
        	//nmMobBulkCtrl.reserveMSISDN(new List<String>{'123'});
            nmMobBulkCtrl.sendChatterNotification();
            nmMobBulkCtrl.validateSiteWithUSers();
        Test.stopTest();
        System.assert(numbers.size() > 0);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTestUnreserve
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTestUnreserve() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('success_Search'));
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            msisdnWrapper.isSelected = true;
            nmMobBulkCtrl.reserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            nmMobBulkCtrl.getSearchTypes();
            nmMobBulkCtrl.clearAll();
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.getToBeReservedQty(10, 5);
            nmMobBulkCtrl.unreserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            String jobid = nmMobBulkCtrl.unReserveMSISDN(msisdnList);
            //nmMobBulkCtrl.reserveSelected();
            //nmMobBulkCtrl.createReserveWrap(new List<String>{'123'});
            //nmMobBulkCtrl.searchMSISDN();
        	//nmMobBulkCtrl.reserveMSISDN(new List<String>{'123'});
            nmMobBulkCtrl.sendChatterNotification();
            nmMobBulkCtrl.validateSiteWithUSers();
        Test.stopTest();
        System.assert(jobid != null);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTestReserve
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTestReserve() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Reserve'));
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            msisdnWrapper.isSelected = true;
            nmMobBulkCtrl.reserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            nmMobBulkCtrl.getSearchTypes();
            nmMobBulkCtrl.clearAll();
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.getToBeReservedQty(10, 5);
            nmMobBulkCtrl.unreserveList = new List<NMMobilityBulkController.MsisdnWrapper>{msisdnWrapper};
            //nmMobBulkCtrl.unReserveMSISDN(msisdnList);
            //nmMobBulkCtrl.reserveSelected();
            //nmMobBulkCtrl.createReserveWrap(new List<String>{'123'});
            //nmMobBulkCtrl.searchMSISDN();
        	String jobid = nmMobBulkCtrl.reserveMSISDN(msisdnList);
            nmMobBulkCtrl.sendChatterNotification();
            nmMobBulkCtrl.validateSiteWithUSers();
        Test.stopTest();
        System.assert(jobid != null);
    }
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest5
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest5() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('success_Search'));
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            nmMobBulkCtrl.reqQuantity = 0;
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.reqQuantity = 60;
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.reqQuantity = 10;
            nmMobBulkCtrl.tobeReserved = 0;
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.tobeReserved = 5;
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.reqQuantity = 5;
            nmMobBulkCtrl.reqSearch = 'TEST';
            nmMobBulkCtrl.reqPattern = '1';
            nmMobBulkCtrl.doSearch();
        	//nmMobBulkCtrl.reserveMSISDN(new List<String>{'123'});
        Test.stopTest();
        System.assertEquals(false, nmMobBulkCtrl.showSearch);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest6
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest6() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Reserve'));
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
        pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            nmMobBulkCtrl.quantity = 40;
            nmMobBulkCtrl.isAutoRes = true;
        	nmMobBulkCtrl.doAutoReserve();

        Test.stopTest();
        System.assertEquals(true, nmMobBulkCtrl.checkStatus);
    }
    
    /*********************************************************************************************
    * Method Name : NMMobilityBulkControllerTest7
    * Description : Used to simulate and test the logic of constructor in NMMobilityBulkController
    * Parameters  : NA
    * Return      : NA                      
    *********************************************************************************************/
    static testmethod void NMMobilityBulkControllerTest7() {
        List<cscfga__Attribute_Definition__c> attrDefs = TestDataFactory.generateAttributeDefinitions(3);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(Id = pc.cscfga__Product_Definition__c, Name = 'Mobility');
        UPDATE pd;
        List<cscfga__Attribute__c> attrs = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c att1 = new cscfga__Attribute__c(Name = 'Device', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[0].Id, csexpimp1__guid__c = '123', cscfga__Key__c = '1', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att1);
        cscfga__Attribute__c att2 = new cscfga__Attribute__c(Name = 'VoiceToText', cscfga__Value__c = 'Test', cscfga__Attribute_Definition__c = attrDefs[1].Id, csexpimp1__guid__c = '1234', cscfga__Key__c = '12', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att2);
        cscfga__Attribute__c att3 = new cscfga__Attribute__c(Name = 'DeviceQuantity', cscfga__Value__c = '1', cscfga__Attribute_Definition__c = attrDefs[2].Id, csexpimp1__guid__c = '1235', cscfga__Key__c = '123', cscfga__Product_Configuration__c = pc.Id);
        attrs.add(att3);
        INSERT attrs;
        
        List<String> msisdnList=new List<String>();
        msisdnList.add('6123456782');
        msisdnList.add('6123456783');
        Test.setMock(HttpCalloutMock.class, new MockMSISDNServiceResponse('Unreserve'));
        Test.startTest();
            PageReference pageRef = Page.NumberManagementMobilityBulk;
            pageRef.getParameters().put('basketId', pc.cscfga__Product_Basket__c);
            pageRef.getParameters().put('identifyProduct', 'Mobility');
            Test.setCurrentPage(pageRef);
            NMMobilityBulkController nmMobBulkCtrl = new NMMobilityBulkController();
            NMMobilityBulkController.MsisdnWrapper msisdnWrapper = new NMMobilityBulkController.MsisdnWrapper('123');
            nmMobBulkCtrl.reqQuantity = 0;
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.successM = 'Test';
            nmMobBulkCtrl.device = 'Test';
            nmMobBulkCtrl.voice = 'Test';
            nmMobBulkCtrl.createReserveWrap(msisdnList);
            nmMobBulkCtrl.doSearch();
            nmMobBulkCtrl.unreserveSelected();
            nmMobBulkCtrl.reserveList = new List<NMMobilityBulkController.MsisdnWrapper>();
            nmMobBulkCtrl.reserveSelected();
            nmMobBulkCtrl.autoReserveMSISDN();
        Test.stopTest();
        System.assertEquals(true, nmMobBulkCtrl.checkStatus);
    }
    
    
}
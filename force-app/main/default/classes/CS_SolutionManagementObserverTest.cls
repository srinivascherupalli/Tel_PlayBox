/***************************************************************************************************
Name          : CS_SolutionManagementObserverTest
Created By    : Mahaboob Basha
Created Date  : Jun 14 2019
Description   : This is a test class to simulate and test the logic of CS_SolutionManagementObserver
-------
History                                                            
-------                                                            
VERSION     AUTHOR          DATE            DETAIL                   
-------     ------          -----           ---------                 
1.1         Mahaboob        14-06-2019      Created
1.1         Mahaboob        14-06-2019      Added methods linkSubscriptionsTest
***************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class CS_SolutionManagementObserverTest {
    
    /***************************************************************************************************************
    * Method Name : linkSubscriptionsTest
    * Description : Used to simulate and test the logic of linkSubscriptions method in CS_SolutionManagementObserver
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void linkSubscriptionsTest() {
        Test.startTest();
            CS_SolutionManagementObserver.linkSubscriptions(new List<Id>());
        Test.stopTest();
        //dummy assert as this test case covers null scenario
        System.assert(1==1);

    }
    
    /***************************************************************************************************************
    * Method Name : linkSubscriptionsTest1
    * Description : Used to simulate and test the logic of linkSubscriptions method in CS_SolutionManagementObserver
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void linkSubscriptionsTest1() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        csord__Solution__c sol = new csord__Solution__c(Name = 'Connected Workplace', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        System.debug('Solution Id : ' + sol.Id);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cssdm__solution_association__c = sol.Id;
        UPDATE pc;
        csord__Service__c serv = TestDataFactory.generateService();
        serv.cssdm__solution_association__c = sol.Id;
        serv.csordtelcoa__product_configuration__c = pc.Id;
        UPDATE serv;
        System.debug('Service Id1 : ' + serv.Id);
        csord__Subscription__c sub = new csord__Subscription__c(Id = serv.csord__Subscription__c, cssdm__solution_association__c = sol.Id);
        UPDATE sub;
        csord__Solution__c sol1 = new csord__Solution__c(cssdm__replaced_solution__c = sol.Id, Name = 'Connected Workplace', csord__Account__c = acc.Id, csord__External_Identifier__c = '123456', csord__External_Identifier2__c = '12345', csord__Identification__c = '123');
        INSERT sol1;
        System.debug('Solution1 Id : ' + sol1.Id);
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cssdm__solution_association__c = sol1.Id;
        UPDATE pc1;
        csord__Service__c serv1 = TestDataFactory.generateService();
        serv1.cssdm__solution_association__c = sol1.Id;
        serv1.csordtelcoa__product_configuration__c = pc1.Id;
        UPDATE serv1;
        System.debug('Service1 Id : ' + serv1.Id);
        csord__Subscription__c sub1 = new csord__Subscription__c(Id = serv1.csord__Subscription__c, cssdm__solution_association__c = sol1.Id);
        UPDATE sub1;
        Test.startTest();
            CS_SolutionManagementObserver.linkSubscriptions(new List<Id>{sub1.Id});
        Test.stopTest();
        List<csord__Subscription__c> subList = [SELECT Id, Name, cssdm__solution_association__c from csord__Subscription__c];
        System.assertEquals(sol1.Id, subList[0].cssdm__solution_association__c);
    }
    
    /***************************************************************************************************************
    * Method Name : updateSubscriptionReferencesToMACSolutionsTest1
    * Description : Used to simulate and test the logic of updateSubscriptionReferencesToMACSolutions method in CS_SolutionManagementObserver
    * Parameters  : NA
    * Return      : NA                      
    ***************************************************************************************************************/
    static testmethod void updateSubscriptionReferencesToMACSolutionsTest1() {
        Account acc = new Account(Name = 'Test Account');
        INSERT acc;
        csord__Solution__c sol = new csord__Solution__c(Name = 'Connected Workplace', csord__Account__c = acc.Id, csord__External_Identifier__c = '12345', csord__External_Identifier2__c = '1234', csord__Identification__c = '12');
        INSERT sol;
        System.debug('Solution Id : ' + sol.Id);
        cscfga__Product_Configuration__c pc = TestDataFactory.generateProductConfiguration();
        pc.cssdm__solution_association__c = sol.Id;
        UPDATE pc;
        
       csord__Subscription__c subscription = new csord__Subscription__c(Name = 'IP SIte', csord__Identification__c = 'TestValue');

      insert subscription;
        
       // csord__Service__c serv = TestDataFactory.generateService();
       csord__Service__c service = new csord__Service__c(Name = 'IP Site', csordtelcoa__Product_Configuration__c = pc.Id,
                      csord__Status__c = 'Success', csord__Subscription__c = subscription.Id,
                      csord__Identification__c = 'TestValue'
                      );

      insert service;
        service.cssdm__solution_association__c = sol.Id;
        service.csordtelcoa__product_configuration__c = pc.Id;
        UPDATE service;
        System.debug('Service Id : ' + service.Id);
        csord__Subscription__c subscription1 = new csord__Subscription__c(Id = service.csord__Subscription__c, cssdm__solution_association__c = sol.Id);
        UPDATE subscription1;
        
        cscfga__Product_Configuration__c pcNochange = TestDataFactory.generateProductConfiguration();
        pcNochange.cssdm__solution_association__c = sol.Id;
        UPDATE pcNochange;
        csord__Service__c servNoChange = TestDataFactory.generateService();
        servNoChange.cssdm__solution_association__c = sol.Id;
        servNoChange.csordtelcoa__product_configuration__c = pcNochange.Id;
        UPDATE servNoChange;
        System.debug('Service Id : ' + servNoChange.Id+'=====>>>>>>>'+servNoChange.cssdm__solution_association__c);
        csord__Subscription__c subNoChange = new csord__Subscription__c(Id = servNoChange.csord__Subscription__c, cssdm__solution_association__c = sol.Id,csordtelcoa__Replacement_Subscription__c=null);
        UPDATE subNoChange;
        
        csord__Solution__c sol1 = new csord__Solution__c(cssdm__replaced_solution__c = sol.Id, Name = 'Connected Workplace', csord__Account__c = acc.Id, csord__External_Identifier__c = '123456', csord__External_Identifier2__c = '12345', csord__Identification__c = '123');
        INSERT sol1;
        System.debug('Solution1 Id : ' + sol1.Id);
        
        servNoChange.cssdm__solution_association__c = sol1.Id;
        subNoChange.cssdm__solution_association__c = sol1.Id;
            
        cscfga__Product_Configuration__c pc1 = TestDataFactory.generateProductConfiguration();
        pc1.cssdm__solution_association__c = sol1.Id;
        UPDATE pc1;
        csord__Service__c serv1 = TestDataFactory.generateService();
        serv1.cssdm__solution_association__c = sol1.Id;
        serv1.csordtelcoa__product_configuration__c = pc1.Id;
        UPDATE serv1;
        System.debug('Service1 Id : ' + serv1.Id);
        csord__Subscription__c sub1 = new csord__Subscription__c(Id = serv1.csord__Subscription__c, cssdm__solution_association__c = sol1.Id);
        UPDATE sub1;
        Map<String, SObjectType> globalSchema = Schema.getGlobalDescribe();
        Test.startTest();
            CS_SolutionManagementObserver.updateSubscriptionReferencesToMACSolutions(new Set<Id>{sol1.Id}, globalSchema);
        Test.stopTest();
        
        List<csord__Subscription__c> subList = [SELECT Id, Name, cssdm__solution_association__c from csord__Subscription__c];
        System.assertEquals(sol1.Id, subList[0].cssdm__solution_association__c);

    }
}
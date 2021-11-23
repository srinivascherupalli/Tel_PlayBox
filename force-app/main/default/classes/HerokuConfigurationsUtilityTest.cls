/********************************************************
Test Class :HerokuConfigurationsUtilityTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.             Venkat T              09/01/2021      Test coverage of HerokuConfigurationsUtility
*******************************************************************************************************************************/
@isTest
public class HerokuConfigurationsUtilityTest {

     @Testsetup
    static void dataSetup(){
        
        Account acc = new Account();
        acc.Name = 'test Account1' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Rajiv';
        con.LastName = 'Singh'; 
        con.email ='rajiv@test.com';
        con.Contact_Status__c ='Active';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csconta__Frame_Agreement__c frameAgg = new csconta__Frame_Agreement__c();
        frameAgg.csconta__Account__c = acc.Id;
        insert frameAgg;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        insert ord;
        
        cscfga__Product_Basket__c testBasket3 = new cscfga__Product_Basket__c();
        testBasket3.csbb__Account__c = acc.Id;
        testBasket3.Name = 'TestPreviousBasket';
        testBasket3.cscfga__Opportunity__c = opp.Id;
        testBasket3.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        testBasket3.csconta__Frame_Agreement__c = frameAgg.Id;
        testBasket3.Device_Care_Contact__c = con.Id;
        testBasket3.csordtelcoa__Order_Under_Change__c = ord.id;
        insert testBasket3;
        
        
        List<csord__Subscription__c> subList=new List<csord__Subscription__c>();
           
               
        csord__Subscription__c replSubs=new csord__Subscription__c();
        replSubs.name  = 'test replaced subs';
        replSubs.csord__Identification__c = 'test identity replced';
        replSubs.Sub_status__c = 'Active';
        replSubs.eventId__c = '9f0ded2-1bfd-7916-662d-9e28c804294e';
        subList.add(replSubs);
        
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        subs.Suspension_reason__c='Requested by Customer';
        subs.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.changeType__c = 'Resume';
        subs.Point_of_No_Return_Reached__c = true;
        subs.cancel_Point_of_No_Return_Reached__c = true; 
        subList.add(subs);
        insert subList;
        
        
        cscfga__Product_Configuration__c userPC1 = new cscfga__Product_Configuration__c(Name = 'IP site',  Quantity_Product_Configuration__c = 3, Type__c = 'Cancel', configGuID__c = '122344');
        insert userPC1;
        
        
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csord__Subscription__c = subs.Id;
        serv.csordtelcoa__Service_Number__c = '1';
        serv.csordtelcoa__Service_Number__c = 'svc-1235645';
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c =  ord.Id;
        serv.csord__Status__c ='Amend Rejected';
        serv.csordtelcoa__Point_of_No_Return_Reached__c = true;
        serv.csordtelcoa__Product_Configuration__c = userPC1.ID;
        servs.add(serv);
        insert servs;    
    
}
       @isTest
        static void testHerokuConfigurationsUtility(){
        
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Status__c, csord__Order__c,csord__Order__r.LastModifiedDate FROM csord__Service__c LIMIT 1]);
        csord__Order__c ord = [SELECT Id,Name, csord__Status2__c ,Push_Heroku_Configurations_Job_Id__c ,LastModifiedDate FROM csord__Order__c Where Name = 'TestOrder' Limit 1];        
       
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'UpdateRemediationFlag'), 1);
        Boolean result = HerokuConfigurationsUtility.pushRemediationFlagToHeroku(ord.Id);
        Test.stopTest();  
        System.assertEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);
        System.assertEquals(true,result);
    }
    
       @isTest
        static void testHerokuConfigurationsUtility2(){
        
        cscfga__Product_Basket__c inflightBasket =  [SELECT Id,csordtelcoa__Order_Under_Change__c, csordtelcoa__Order_Under_Change__r.csord__Status2__c FROM cscfga__Product_Basket__c
                                                    LIMIT 1];    
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Status__c, csord__Order__c,csord__Order__r.LastModifiedDate FROM csord__Service__c LIMIT 1]);
        csord__Order__c ord = [SELECT Id,Name, csord__Status2__c ,Push_Heroku_Configurations_Job_Id__c ,LastModifiedDate FROM csord__Order__c Where Name = 'TestOrder' Limit 1];        
         ord.csord__Status2__c = 'Amend Rejected';
        update ord;    
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'UpdateRemediationFlag'), 1);
         HerokuConfigurationsUtility.PushResetHerokuConfigurations(inflightBasket.Id);
        Test.stopTest();  
        System.assertEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);
        //System.assertEquals(true,result);
    }

    @isTest
    static void testResetAllowAmendInHeroku(){
        cscfga__Product_Basket__c inflightBasket =  [SELECT Id,csordtelcoa__Order_Under_Change__c, csordtelcoa__Order_Under_Change__r.csord__Status2__c 
            FROM cscfga__Product_Basket__c
            LIMIT 1];    
        Map<Id, csord__Service__c> servicesMap = new Map<Id, csord__Service__c>([SELECT Id, csord__Status__c, csord__Order__c,csord__Order__r.LastModifiedDate FROM csord__Service__c LIMIT 1]);
        csord__Order__c ord = [SELECT Id,Name, csord__Status2__c ,Push_Heroku_Configurations_Job_Id__c ,LastModifiedDate FROM csord__Order__c Where Name = 'TestOrder' Limit 1];        
        
        Test.startTest();
        Id jobId = Database.executeBatch(new PushHerokuConfigurationsBatch(servicesMap.keySet(), 'UpdateRemediationFlag'), 1);
        HerokuConfigurationsUtility.resetAllowAmendInHeroku(inflightBasket.Id);
        Test.stopTest();  
        System.assertEquals(ord.LastModifiedDate, servicesMap.values()[0].csord__Order__r.LastModifiedDate);
    }
}
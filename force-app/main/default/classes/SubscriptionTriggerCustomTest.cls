/*********************************************************************************************************************************
*Class Name      :   SubscriptionTriggerCustomTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Gnana                   27-Mar-2020   Test Class for SubscriptionTriggerCustom
2.            Gnana                   09-Apr-2020   EDGE-138284 - Refactor Subscription trigger 	
*********************************************************************************************************************************
*/
@isTest
public class SubscriptionTriggerCustomTest {
    
    @TestSetup static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = new Opportunity( Name = 'test opportunity', AccountId= acc.Id, Product_Domain__c = 'MOBILES', StageName='Develop', Description='Test Opp', Pricing_Method__c='PET', Contract_Type__c='BSA',Billing_Solution__c='Standard', recordtypeId='0122P0000004HYg');
        opp.CloseDate = system.today();
        insert opp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        csord__Order__c pord = ProductTestFactory.buildOrder('ParentTestOrder', acc.id, 'Created', ordReq.id);
        pord.csord__Order_Request__c = ordReq.Id;
        pord.csordtelcoa__Opportunity__c = opp.Id;
        insert pord;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        ord.csord__Primary_Order__c = pord.Id;
        insert ord;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.csord__Status__c='Active';
        subs.csordtelcoa__Subscription_Number__c='SN-123456';
        subs.Suspension_reason__c='Requested by Customer';
        insert subs;
        
        cscfga__Product_Definition__c userPD = new cscfga__Product_Definition__c(Name = 'IP Site', cscfga__Description__c = 'IP Site',product_Specification__c = 'DMCAT_ProductOffering_000304');
        insert userPD;
        
        cscfga__Product_Configuration__c userPCold = new cscfga__Product_Configuration__c(Name = 'IP site', cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPCold;
        
        cscfga__Product_Configuration__c userPC = new cscfga__Product_Configuration__c(Name = 'IP site',csordtelcoa__Replaced_Product_Configuration__c=userPCold.id, cscfga__Product_Definition__c = userPD.Id, Quantity_Product_Configuration__c = 3);
        insert userPC;
        
        csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csord__Order_Request__c = ordReq.Id;
        serv.csord__Order__c = ord.Id;
        serv.csordtelcoa__Product_Configuration__c = userPC.id;
        serv.Telstra_Committed_Date__c = Date.today() + 30;
        insert serv;
        
        subs.Contract_Term__c='24';
        update subs;
    }
    
    @isTest
    static void testSubscriptionTrigger(){
        csord__Subscription__c subs = [SELECT Id,csord__Order__c,Telstra_Committed_Date__c, Contract_Term__c FROM csord__Subscription__c WHERE Name='test subs' LIMIT 1];
        System.debug('Telstra Committed Date'+subs.Telstra_Committed_Date__c);
        subs.Contract_Term__c = '12';
        Update subs;
        System.assertEquals(subs!=null, true);
    }

}
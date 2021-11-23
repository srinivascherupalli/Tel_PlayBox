/*
===============================================================================================================================
Class : TM1ResponseEventTriggerTest
Developer Name : Rohit
Test Class : TM1ResponseEventTriggerTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Shubhi ,Harsh,Rohit   23/5/2019     CheckEligibilitySolution (EDGE-66570 ,EDGE-72453,EDGE-73521)
2.         shubhhi V           8/03/2021     fdr test class fix
===============================================================================================================================
*/

@isTest
public class TM1ResponseEventTriggerTest {
        
    public static Id standardID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();   

    @isTest 
    public static void dataSetup(){
        
        Account testAccount = new Account();
        testAccount.Name = 'testAccount';
        testAccount.Customer_Status__c = 'ACTIVE';
        insert testAccount;
        
        Opportunity testOpp = new Opportunity();
        testOpp.Account = testAccount;
        testOpp.Name = 'testOpp';
        testOpp.StageName = 'Develop';
        testOpp.Product_Type__c = 'Modular';
        testOpp.CloseDate = System.Date.today();
        testOpp.RecordTypeId=standardID;
        testOpp.Type ='Migration'; //'Disconnect';
        testOpp.Billing_Solution__c='Standard';
        insert testOpp;

        cscfga__Product_Basket__c testBasket = new cscfga__Product_Basket__c();
        testBasket.csbb__Account__c = testAccount.Id;
        testBasket.Name = 'ShowSubTestBasket';
        testBasket.cscfga__Opportunity__c = testOpp.Id;
        insert testBasket;
        
        List<TM1TransactionEvent__e> tm1eventList = new List<TM1TransactionEvent__e>();
        tm1eventList.add(new TM1TransactionEvent__e(basketId__c=testBasket.id));
        
         Test.startTest();
            // Call method to publish events
            List<Database.SaveResult> results = EventBus.publish(tm1eventList);
            // Inspect publishing result for each event
            for (Database.SaveResult sr : results) {
                if (sr.isSuccess()) {
                    System.debug('Successfully published event.');
                } else {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Error returned: ' +
                                    err.getStatusCode() +
                                    ' - ' +
                                    err.getMessage());
                    }
                }       
            }
        Test.stopTest();
        System.assertEquals(results.size()>0,true);

    }
}
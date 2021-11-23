@isTest
public class transitionPCCreationForMACTest {
    @TestSetup static void dataSetup() {
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;
 
        cscfga__Product_Basket__c prodBasket = new cscfga__Product_Basket__c ();
        prodBasket.csbb__Account__c = acc.ID;
        insert prodBasket;
        
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = system.Label.Connected_Workplace;
        testSubscription.csord__Account__c = acc.Id;
        testSubscription.csord__Identification__c = 'test';
        testSubscription.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription2 = new csord__Subscription__c();
        testSubscription2.Name = 'TestSubsforTest2';
        testSubscription2.csord__Account__c = acc.Id;
        testSubscription2.csord__Identification__c = 'test2';
        testSubscription2.csord__Status__c = 'Pending';

        
        csord__Subscription__c testSubscription3 = new csord__Subscription__c();
        testSubscription3.Name = 'TestSubsforTest3';
        testSubscription3.csord__Account__c = acc.Id;
        testSubscription3.csord__Identification__c = 'test3';
        testSubscription3.csord__Status__c = 'Active';

        csord__Subscription__c testSubscription4 = new csord__Subscription__c();
        testSubscription4.Name = 'TestSubsforTest4';
        testSubscription4.csord__Account__c = acc.Id;
        testSubscription4.csord__Identification__c = 'test';
        testSubscription4.csord__Status__c = 'Active';
        
        csord__Subscription__c testSubscription5 = new csord__Subscription__c();
        testSubscription5.Name = 'TestSubsforTest5';
        testSubscription5.csord__Account__c = acc.Id;
        testSubscription5.csord__Identification__c = 'test';
        testSubscription5.csord__Status__c = 'Closed Replaced';
        
        cscfga__Product_Definition__c prodDef = new cscfga__Product_Definition__c();
        prodDef.Name =  system.Label.LegacyPD;
        prodDef.cscfga__Description__c = 'Dummy PC for Transition Mac Test';
        
        insert prodDef;

        List<csord__Subscription__c> testSubsList = new List<csord__Subscription__c>{testSubscription,testSubscription2,testSubscription3,testSubscription4,testSubscription5};
        insert testSubsList;
        
        List<csord__Service__c> servlist=new List<csord__Service__c>();
        integer i=0;
        for(csord__Subscription__c testSubs:[SELECT Id,csord__Status__c FROM csord__Subscription__c])
        {           
            csord__Service__c serv = new csord__Service__c();
            serv.name ='Legacy'+i;
            serv.csord__Identification__c  = 'testIdentify_4';
            serv.csordtelcoa__Service_Number__c = '3';
            serv.csord__Subscription__c = testSubs.Id;
            serv.csord__Status__c = 'Created';
            serv.substage__c = 'Product Requirements Validation';
            servlist.add(serv);
            i++;
            
        }
        //create service
        insert servlist;


    }
    
        @isTest static void testserviceIds() {
        List<cscfga__Product_Basket__c> basketIdList = [SELECT Id from cscfga__Product_Basket__c ];
        List<Id> baskID = new List<Id>();
        for (cscfga__Product_Basket__c basket : basketIdList){
            baskID.add(basket.Id);  
        }

        Test.startTest();
        transitionPCCreationForMAC.serviceIds(baskID);
       Test.stopTest();
       System.assert(basketIdList!=null);
    }
}
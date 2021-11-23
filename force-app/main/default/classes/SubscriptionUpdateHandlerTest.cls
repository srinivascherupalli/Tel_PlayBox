/********************************************************
Test Class :SubscriptionUpdateHandlerTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.             Venkat T              05/01/2021     Test coverage of SubscriptionUpdateHandlerTest
2.          Vamsi Krishna Vaddipalli 17/feb/2021      EDGE-199772 test
*******************************************************************************************************************************/

@isTest
private  class SubscriptionUpdateHandlerTest {
    @Testsetup
    static void dataSetup(){
        
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        
        Opportunity opp = ProductTestFactory.getOpportunityBasic(acc);
        opp.StageName = 'Define';
        opp.CloseDate = System.Date.today();
        insert opp;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        
        
        
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opp.Id;
        //Added by Vamsi for EDGE-199772 on 17FEB2021 starts
        ord.csord__Status2__c = 'Amend Rejected';
        //Added by Vamsi for EDGE-199772 on 17FEB2021 ends
        insert ord;
        
        
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
        
        
        csord__Subscription__c sub1=new csord__Subscription__c();
        sub1.name  = 'test subs1';
        sub1.csord__Identification__c = 'test identity1';
        subs.csordtelcoa__Subscription_Number__c ='SN-12345';
        sub1.csord__Order__c = ord.Id;
        sub1.Sub_status__c = 'Active';
        sub1.csord__Status__c='Active';
        sub1.Suspension_reason__c='Requested by Customer';
        sub1.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        sub1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        sub1.changeType__c = 'Resume';
        sub1.Point_of_No_Return_Reached__c = true;
        sub1.cancel_Point_of_No_Return_Reached__c = true; 
        subList.add(sub1);
        
        
        
        csord__Subscription__c sub2=new csord__Subscription__c();
        sub2.name  = 'test sub2';
        sub2.csord__Identification__c = 'test identity';
        sub2.Sub_status__c = 'Active';
        sub2.csord__Status__c='Active';
        sub1.csordtelcoa__Subscription_Number__c ='SN-12345';
        sub2.Suspension_Reason__c='Requested by Customer';
        sub2.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        sub2.csord__Order__c = ord.Id;
        sub2.Point_of_No_Return_Reached__c = true;
        sub2.cancel_Point_of_No_Return_Reached__c = true; 
        subList.add(sub2);
        
        
        csord__Subscription__c sub3=new csord__Subscription__c();
        sub3.name  = 'test sub3';
        sub3.csord__Identification__c = 'test identity';
        sub3.Sub_status__c = 'Active';
        sub3.csord__Status__c='Active';
        sub1.csordtelcoa__Subscription_Number__c ='SN-12345';
        sub3.Suspension_Reason__c='Requested by Customer';
        sub3.csordtelcoa__Replaced_Subscription__c = replSubs.id;
        sub3.csord__Order__c = ord.Id;
        sub3.Point_of_No_Return_Reached__c = true;
        sub3.cancel_Point_of_No_Return_Reached__c = true; 
        subList.add(sub3);
        insert subList;
        
        
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
        serv.csordtelcoa__Point_of_No_Return_Reached__c = true;
        servs.add(serv);
        
        csord__Service__c serv1 = new csord__Service__c();
        serv1.name ='tst service1';
        serv1.csord__Identification__c  = 'test identify1';
        serv1.csord__Subscription__c = sub1.Id;
        serv1.csordtelcoa__Service_Number__c = '2';
        serv1.csord__Status__c = 'Service Created';
        serv1.csord__Order_Request__c = ordReq.Id;
        serv1.csord__Order__c = ord.Id;
        serv1.cancel_Point_of_No_Return_Reached__c = true;
        //Added by Vamsi for EDGE-199772 on 17FEB2021 starts
        serv1.Action_Type__c = 'Inflight Cancel';
        //Added by Vamsi for EDGE-199772 on 17FEB2021 ends
        servs.add(serv1);
        
        csord__Service__c serv2 = new csord__Service__c();
        serv2.name ='tst service2';
        serv2.csord__Identification__c  = 'test identify2';
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.csord__Subscription__c = sub2.Id;
        serv2.csord__Status__c = 'Service Created';
        serv2.csord__Order_Request__c = ordReq.Id;
        serv2.csord__Order__c = ord.Id;
        serv2.csordtelcoa__Point_of_No_Return_Reached__c = true;
        serv2.cancel_Point_of_No_Return_Reached__c = true;
        servs.add(serv2);
        
        csord__Service__c serv3 = new csord__Service__c();
        serv3.name ='tst service3';
        serv3.csord__Identification__c  = 'test identify2';
        serv3.csord__Subscription__c = sub3.Id;
        serv3.csordtelcoa__Service_Number__c = '5';
        serv3.csord__Status__c = 'Service Created';
        serv3.csord__Order_Request__c = ordReq.Id;
        serv3.csord__Order__c = ord.Id;
        serv3.csordtelcoa__Point_of_No_Return_Reached__c = true;
        serv3.cancel_Point_of_No_Return_Reached__c = true;
        servs.add(serv3);  
        insert servs; 
        
    }
    
    
    @isTest
    static void testUpdateSubsOrderPONRFlags(){
        Set<ID> serviceIds=new Set<ID>();
        
       
       csord__Service__c  servrec1 = [select id,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c  
                                      From csord__Service__c 
                                      Where Name = 'tst service1' Limit 1];
        
        
        servrec1.cancel_Point_of_No_Return_Reached__c=true;
        servrec1.csordtelcoa__Point_of_No_Return_Reached__c=true;
        
        update servrec1;
        serviceIds.add(servrec1.Id);
        
        Test.startTest();
        SubscriptionUpdateHandler.UpdateSubsOrderPONRFlags(serviceIds);
        Test.stopTest();
    
        csord__Subscription__c subs1=[select id, Name,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c 
                                      From csord__Subscription__c 
                                      Where Name = 'test subs1' Limit 1];
                   
        
        System.assertEquals(true,subs1.Point_of_No_Return_Reached__c);
        System.assertEquals(true,subs1.cancel_Point_of_No_Return_Reached__c);
        
       csord__Order__c ord1 = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c 
                                FROM csord__Order__c 
                                WHERE Name = 'TestOrder' Limit 1];
        
        System.assertEquals(true,ord1.csordtelcoa__Point_of_No_Return_Reached__c);
        System.assertEquals(true,ord1.cancel_Point_of_No_Return_Reached__c);
        
        //2nd 
        
        
        
         csord__Service__c servrec2 = [select id,Name,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c  
                                      From csord__Service__c 
                                      Where Name = 'tst service2' Limit 1];
        
        
        servrec2.cancel_Point_of_No_Return_Reached__c=true;
        servrec2.csordtelcoa__Point_of_No_Return_Reached__c=false;
        
        update servrec2;
        
        
      
        csord__Subscription__c subs2=[select id, Name,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c 
                                      From csord__Subscription__c 
                                      Where Name = 'test subs1' Limit 1];
                                      
        System.assertEquals(true,subs2.Point_of_No_Return_Reached__c);
        System.assertEquals(true,subs2.cancel_Point_of_No_Return_Reached__c);
        
        csord__Order__c ord2 = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c 
                                FROM csord__Order__c 
                                WHERE Name = 'TestOrder' Limit 1];
        
        System.assertEquals(true,ord2.csordtelcoa__Point_of_No_Return_Reached__c);
        System.assertEquals(true,ord2.cancel_Point_of_No_Return_Reached__c);
                
        // 3rd 
        
      
        csord__Service__c servrec3 = [select id,Name,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c  
                                      From csord__Service__c 
                                       Where Name = 'tst service3' Limit 1];
        
        
        servrec3.cancel_Point_of_No_Return_Reached__c=true;
        servrec3.csordtelcoa__Point_of_No_Return_Reached__c=true;
        
        update servrec3;
        
        
     
        
        csord__Subscription__c subs3=[select id, Name,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c 
                                      From csord__Subscription__c 
                                      Where Name = 'test subs1' Limit 1];
        
        System.assertEquals(true,subs3.Point_of_No_Return_Reached__c);
        System.assertEquals(true,subs3.cancel_Point_of_No_Return_Reached__c);
        
        csord__Order__c ord3 = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c 
                                FROM csord__Order__c 
                                WHERE Name = 'TestOrder' Limit 1];
        
        System.assertEquals(true,ord3.csordtelcoa__Point_of_No_Return_Reached__c);
        System.assertEquals(true,ord3.cancel_Point_of_No_Return_Reached__c);
        
        
        
        
    }
    

    @isTest
    static void testUpdateSubsOrderPONRFlags2(){
        Set<ID> serviceIds=new Set<ID>();
        
       
       csord__Service__c  servrec1 = [select id,cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c  
                                      From csord__Service__c 
                                      Where Name = 'tst service1' Limit 1];
        
        
        //servrec1.cancel_Point_of_No_Return_Reached__c=true;
        //servrec1.csordtelcoa__Point_of_No_Return_Reached__c=true;
        
        //update servrec1;
          csord__Order__c ord = [SELECT id,csord__Status2__c, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c 
                                FROM csord__Order__c 
                                WHERE Name = 'TestOrder' Limit 1];
        ord.csord__Status2__c = 'Amend Rejected';
        update ord;
        serviceIds.add(servrec1.Id);
        
        Test.startTest();
        SubscriptionUpdateHandler.UpdateSubsOrderPONRFlags(serviceIds);
        Test.stopTest();
    
        csord__Subscription__c subs1=[select id, Name,Point_of_No_Return_Reached__c,cancel_Point_of_No_Return_Reached__c 
                                      From csord__Subscription__c 
                                      Where Name = 'test subs1' Limit 1];
                   
        
        System.assertEquals(false,subs1.Point_of_No_Return_Reached__c);
        System.assertEquals(true,subs1.cancel_Point_of_No_Return_Reached__c);
        
       csord__Order__c ord1 = [SELECT id, cancel_Point_of_No_Return_Reached__c,csordtelcoa__Point_of_No_Return_Reached__c 
                                FROM csord__Order__c 
                                WHERE Name = 'TestOrder' Limit 1];
        
        System.assertEquals(true,ord1.csordtelcoa__Point_of_No_Return_Reached__c);
        System.assertEquals(true,ord1.cancel_Point_of_No_Return_Reached__c);
        
    
    }
}
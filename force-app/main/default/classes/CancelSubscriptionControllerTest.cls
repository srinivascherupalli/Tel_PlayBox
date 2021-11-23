@isTest( SeeAllData = false )
private class CancelSubscriptionControllerTest
{
    static testMethod void checkCancelSubscriptionSelectedListFunctionality()
    {
       Account acc = AccountTestFactory.buildAccount('Test Account') ;
       csord__Subscription__c subscriptionObj = new csord__Subscription__c();
       subscriptionObj  = ProductTestService.getSubscriptionObject(acc);
        
       EnvironmentVariable.put('Cancel_Subscription_Pagination_Size', '10');
       ApexPages.currentPage().getParameters().put('id', subscriptionObj.id); 
       
       
       ProductTestFactory.createOverAllOrchestrationProcessTemplate();
       ProductTestFactory.createChildOrchestrationProcessTemplate();
       
       CancelSubscriptionController testContl = new CancelSubscriptionController ();
       
       Test.startTest(); 
             
       testContl.searchForSubscriptions();
       //System.assertNotEquals(null,testContl.newSubscriptionList);
       testContl.WrapperList.get(0).selected = true; 
       
       testContl.BackToOrder();
       testContl.ContinueCancellation();             
              
       testContl.getSelectedSubscriptionList();
       System.assertEquals(1,testContl.selectedSubscriptionList.size());
             
       Test.stopTest();
    }  
    
     static testMethod void checkCancelSubscriptionConfirmFromSubscriptionPage()
     {
       Account acc = AccountTestFactory.buildAccount('Test Account');
       csord__Subscription__c subscriptionObj = new csord__Subscription__c();
       subscriptionObj  = ProductTestService.getSubscriptionObject(acc);
        
       EnvironmentVariable.put('Cancel_Subscription_Pagination_Size', '10');
       ApexPages.currentPage().getParameters().put('id', subscriptionObj.id); 
       
       
       ProductTestFactory.createOverAllOrchestrationProcessTemplate();
       ProductTestFactory.createChildOrchestrationProcessTemplate();
       
       CancelSubscriptionController testContl = new CancelSubscriptionController ();
       
       Test.startTest(); 
             
       testContl.searchForSubscriptions();
       testContl.WrapperList.get(0).selected = true;        
       testContl.BackToOrder();
       testContl.ContinueCancellation();                           
       testContl.getSelectedSubscriptionList();      
       testContl.BackToSelection();      
       testContl.ContinueCancelSubscription();       
       testContl.BackToCancelProcess();
       testContl.ConfirmCancellation();
       
       csord__Subscription__c  getSubscriptionObj = new csord__Subscription__c();
       getSubscriptionObj  = [SELECT id,csord__Status__c  FROM csord__Subscription__c where id = :subscriptionObj.id];
       System.assertEquals('Pending Cancel', getSubscriptionObj.csord__Status__c);
       
       integer count = [SELECT count() from CSPOFA__Orchestration_Process__c ];
       System.assertEquals(2, count );
          
       testContl.ExitAction();
       
       Test.stopTest();
     }
     
     
     static testMethod void testPagination()
     {
       Account acc = AccountTestFactory.buildAccount('Test Account');
       insert acc;
       ProductTestService.getSubscriptionAsList(acc);
               
       EnvironmentVariable.put('Cancel_Subscription_Pagination_Size', '10');

       ApexPages.currentPage().getParameters().put('id', acc.id);             
       
       CancelSubscriptionController testContl = new CancelSubscriptionController ();       
       Test.startTest(); 
       
       testContl.searchForSubscriptions();       
       testContl.Next();
       testContl.First();
       testContl.Last();
       testContl.Previous();

       testContl.getPageNumber();
       testContl.getTotalPages();
       
       System.assertEquals(1,testContl.getPageNumber());
       System.assertEquals(2,testContl.getTotalPages());       
       Test.stopTest(); 
     }
     
     static testMethod void testWithChildSubscriptions()
     {
        Account acc = AccountTestFactory.buildAccount('Test Account');
        insert acc;
        ProductTestService.createSubscriptionWithChild(acc);
        EnvironmentVariable.put('Cancel_Subscription_Pagination_Size', '10');
        ApexPages.currentPage().getParameters().put('id', acc.id); 
       
       
        ProductTestFactory.createOverAllOrchestrationProcessTemplate();
        ProductTestFactory.createChildOrchestrationProcessTemplate();
        CancelSubscriptionController testContl = new CancelSubscriptionController ();
       
        Test.startTest(); 
             
        testContl.searchForSubscriptions();
        testContl.WrapperList.get(0).selected = true;   
        testContl.WrapperList.get(1).selected = true;       
                                  
        testContl.getSelectedSubscriptionList();             
        testContl.ConfirmCancellation();
       
        csord__Subscription__c  getSubscriptionObj1 = new csord__Subscription__c();
        getSubscriptionObj1  = [SELECT id,csord__Status__c  FROM csord__Subscription__c where id = :testContl.WrapperList.get(0).Wrapsub.id];
        System.assertEquals('Pending Cancel', getSubscriptionObj1.csord__Status__c);
        
        csord__Subscription__c  getSubscriptionObj2 = new csord__Subscription__c();
        getSubscriptionObj2  = [SELECT id,csord__Status__c  FROM csord__Subscription__c where id = :testContl.WrapperList.get(0).Wrapsub.id];
        System.assertEquals('Pending Cancel', getSubscriptionObj2.csord__Status__c);       
        integer count = [SELECT count() from CSPOFA__Orchestration_Process__c ];       
        System.assertEquals(3, count );
        Test.stopTest();
     }    
}
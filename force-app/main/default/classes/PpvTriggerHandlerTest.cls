/****************************************************************************
@Author: Aishwarya Yeware
@Story: EDGE-100327
@Description: PpvTriggerHandlerTest test covrage class for covering PpvTriggerHandler
*********************************************************************************/
@isTest
public class PpvTriggerHandlerTest {
    
    @testSetup
    public static void setupData(){
        Account acc = TestUtil.createAccount('Test Account');
        acc.Customer_Status__c = 'ACQUIRED';
        insert acc;
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        Contact c = TestUtil.createContact(acc.id,'Testing', 'Test');
        insert c;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        List<Customer_Authority_Form__c> caf1 = TestUtil.createBulkCAFwithPPV(200,opp,acc,c);
        insert caf1;

    }
    /*----------------------------------------------------------------
Method : ppvVerifiedTest
Author: Aishwarya
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void ppvVerifiedTest(){
        Account acc = [SELECT id FROM Account WHERE name ='Test Account'];
        List<Customer_Authority_Form__c> caf1 = [SELECT id,Customer_Authority_Form__c,CA_signed__c,ca_status__c,Opportunity__c,Contact__c,Status__c FROM Customer_Authority_Form__c WHERE Account__c=:acc.id];
        system.debug('caf1'+caf1);
        caf1[0].ca_status__c = 'Completed';
        caf1[0].Type__c='Mobile';
        update  caf1[0];
        Map<Id,Customer_Authority_Form__c> oldMap=new Map<Id,Customer_Authority_Form__c>();
        for(Customer_Authority_Form__c c:caf1){
            oldMap.put(c.id,c);
        }
        List<Customer_Authority_Form__c> caf=new List<Customer_Authority_Form__c>();
        Map<Id,Customer_Authority_Form__c> newMap=new Map<Id,Customer_Authority_Form__c>();
         Map<String,List<Customer_Authority_Form__c>> ppvCafMap ;
        Test.startTest();
        for(Customer_Authority_Form__c c:caf1){
            c.Status__c = 'success';
            caf.add(c) ; 
        }
        if(!caf.isEmpty()){
           //update caf; 
        }
        for(Customer_Authority_Form__c c1:caf){
            newMap.put(c1.id,c1);
        }
        
        
        PpvTriggerHandler.onBeforeUpdate(newMap,oldMap);
        PpvTriggerHandler.onAfterUpdate(newMap,oldMap);
        PpvTriggerHandler.onAfterCASigned(newMap,oldMap);
        ppvCafMap=PpvTriggerHandler.getCAFmap(caf);
        PpvTriggerHandler.setPpvMap(newMap,oldMap,ppvCafMap);
        Test.stopTest();  
        System.assertEquals(newMap!=Null,true, 'Map empty');
        
    }
    /*----------------------------------------------------------------
Method : postChatterSuccessTest
Author: Aishwarya
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void postChatterSuccessTest(){
        Account acc = [SELECT id,Name,OwnerId FROM Account WHERE name ='Test Account'];
        Contact con = [SELECT id FROM Contact WHERE name = 'Testing Test'];
        cscfga__Product_Basket__c basket = [SELECT id,Name FROM cscfga__Product_Basket__c];
        PpvComponentController.PpvWrapper detailWrapper=new PpvComponentController.PpvWrapper();
        detailWrapper.basketId=basket.id;
        detailWrapper.isAdded=true;
        List<Customer_Authority_Form__c> caf = [SELECT id,Customer_Authority_Form__c.Opportunity__c,Contact__c,Account__c,Status__c,CreatedDate FROM Customer_Authority_Form__c WHERE Account__c=:acc.id AND Status__c = 'MPPV-ACCEPTED'];
        
        Map<Id,Customer_Authority_Form__c> newMap=new Map<Id,Customer_Authority_Form__c>();
        for(Customer_Authority_Form__c c:caf){
            newMap.put(c.id,c);
        }
        FeedItem post = new FeedItem();
        post.ParentId = con.Id;
        post.Body = 'hello' ;
        insert post;
        Test.startTest();
        PpvTriggerHandler.postChattertNotification(detailWrapper,newMap,con.Id,'success');
        Test.stopTest();  
        System.assertEquals(newMap!=Null,true, 'Map empty');
    }
    /*----------------------------------------------------------------
Method : postChatterFailureTest
Author: Aishwarya
Story: EDGE-100327
-------------------------------------------------------------------------------------*/
    @isTest
    public static void postChatterFailureTest(){
        Account acc = [SELECT id,Name,OwnerId FROM Account WHERE name ='Test Account'];
        Contact con = [SELECT id FROM Contact WHERE name = 'Testing Test'];
        cscfga__Product_Basket__c basket = [SELECT id,Name FROM cscfga__Product_Basket__c];
        PpvComponentController.PpvWrapper detailWrapper=new PpvComponentController.PpvWrapper();
        detailWrapper.basketId=basket.id;
        detailWrapper.isAdded=false;
        List<Customer_Authority_Form__c> caf = [SELECT id,Customer_Authority_Form__c.Opportunity__c,Contact__c,Account__c,Status__c,CreatedDate FROM Customer_Authority_Form__c WHERE Account__c=:acc.id AND Status__c = 'MPPV-ACCEPTED'];
        
        Map<Id,Customer_Authority_Form__c> newMap=new Map<Id,Customer_Authority_Form__c>();
        for(Customer_Authority_Form__c c:caf){
            newMap.put(c.id,c);
        }
        FeedItem post = new FeedItem();
        post.ParentId = con.Id;
        post.Body = 'hello' ;
        insert post;
        Test.startTest();
        PpvTriggerHandler.postChattertNotification(detailWrapper,newMap,con.Id,'failed');
        Test.stopTest();  
        System.assertEquals(newMap!=Null,true, 'Map empty');
    }
}
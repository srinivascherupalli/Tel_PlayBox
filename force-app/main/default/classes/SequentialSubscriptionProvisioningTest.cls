/*
**************************************************************************
Class : SequentialSubscriptionProvisioningTest
Developer Name : Ila Anmol Verma
Main Class : SequentialSubscriptionProvisioning
Date : 17/9/2020
Story: DPG-2578 
***************************************************************************
*/

@isTest
public class SequentialSubscriptionProvisioningTest {

     @Testsetup static void dataSetup(){
         //List of Accounts for order
        List<account> accountList = new List<account>();
         //Order request on Order
        List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
        //List of Subscription
        List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
        // List of Orders
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        //Product Configuration List
        list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
        //Solutions list
        list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
        //Service List
        List<csord__Service__c> servlist = new List<csord__Service__c>();
        //Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
          //User
          List<User> newUser = new List<User>();
         newUser = Orchestration_TestUtility.buildUser(true,1);
          System.runAs(newUser[0]){
         accountList = Orchestration_TestUtility.buildAccount(true,1);
        oppList =  Orchestration_TestUtility.buildOpp(true,1,accountList);
          oppList[0].OwnerId = newUser[0].id;
        update oppList;
        orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
        orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 2);
        orderList[1].csordtelcoa__Opportunity__c = oppList[0].id;
          insert orderList;   
         
         List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();

    offerList = Orchestration_TestUtility.buildMarkertableOffer(false,3);
        offerList[0].Offer_ID__c = 'DMCAT_Offer_000854';
        offerList[1].Offer_ID__c = 'DMCAT_Offer_000750';
        offerList[2].Offer_ID__c = 'DMCAT_Offer_000681';
        insert offerList; 
         
         
       productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,2);
        productconfiglistList[0].Marketable_Offer__c=offerList[1].id;
        productconfiglistList[0].ConfigurationType1__c = 'SolutionComponent';
        productconfiglistList[1].Marketable_Offer__c=offerList[1].id;
        productconfiglistList[1].ConfigurationType1__c  = '';
        insert productconfiglistList;
         
         
         solutionList = Orchestration_TestUtility.buildSolution(true,1);

         subscriptionList = Orchestration_TestUtility.buildSubscription(false,4,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
         
         subscriptionList[0].csord__order__c = orderList[1].id;
         subscriptionList[1].csord__order__c = orderList[1].id;
         subscriptionList[2].csord__order__c = orderList[1].id;
         subscriptionList[3].csord__order__c = orderList[1].id;
         subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
         subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
          subscriptionList[0].MarketableOffer__c = offerList[1].id;
         subscriptionList[1].MarketableOffer__c = offerList[1].id;
         subscriptionList[2].MarketableOffer__c = offerList[0].id;
         subscriptionList[3].MarketableOffer__c = offerList[2].id;
         subscriptionList[0].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
         subscriptionList[1].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
         subscriptionList[2].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
         subscriptionList[3].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
              insert subscriptionList;
         
         FulfillmentLineItem__c f= new FulfillmentLineItem__c(subscription__c=subscriptionList[0].id,Name='Test123',Status__c='New');
        insert f;
         
         servlist= Orchestration_TestUtility.buildService(false,4,subscriptionList[0].id,orderReqList[0].id,orderList[1].id,productconfiglistList[0].id);
        servlist[0].csord__Subscription__c = subscriptionList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
        servlist[2].csord__Subscription__c = subscriptionList[2].id;
        servlist[3].csord__Subscription__c = subscriptionList[3].id;
        insert servlist; 
          }
       }

//Trigger RTB for PS
    
   @isTest
    public static void processRTBForTmdmMsPs(){
      system.debug('inside processRTBForTmdmMsPs method');
         test.startTest();
        csord__Order__c order = [select id from csord__Order__c where name = 'order11' and csordtelcoa__Opportunity__c!=null];
        List<String> moList = new List<String>{'DMCAT_Offer_000750','DMCAT_Offer_000854'};
        FulfillmentLineItem__c lineItem= [Select Status__c,subscription__c from FulfillmentLineItem__c where Name='Test123'];
        lineItem.Status__c='Closed';
        update lineItem;
        List<String> param = new List<String>();
        param.add(order.id);
        SequentialSubscriptionProvisioning.updateSubsForPSFulfillment(param);
        test.stopTest();
        csord__Subscription__c sub= [Select id,csord__Status__c from csord__Subscription__c where  MarketableOffer__r.Offer_ID__c=:moList[0] and csord__order__c =:order.id and csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent' limit 1];
        csord__Service__c ser = [Select id, csord__Status__c from csord__Service__c where csord__Subscription__c =: sub.id];
        system.debug('sub++ ' +sub);
         system.assertEquals(ser.csord__Status__c, 'Connected'); 
        
    } 
    
    
}
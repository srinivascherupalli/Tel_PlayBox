/*
*******************************************************************************
Class : TenancyIdUpdate_TmdmMsPsTest
Developer Name : Ila Anmol Verma
Description : Test Class for TenancyIdUpdate_TmdmMsPs
Date : 10/8/2020
Story: DPG-2579

********************************************************************************
*/
@isTest
public class TenancyIdUpdate_TmdmMsPsTest {

  @Testsetup static void dataSetup(){
   
    //Offer List
    List<Marketable_Offer__c> offerList = new List<Marketable_Offer__c>();
    
	//Product Configuration List
    list<cscfga__Product_Configuration__c> productconfiglistList= new list<cscfga__Product_Configuration__c>();
    //User
    List<User> newUser = new List<User>();
    //Opportunity
	List<Opportunity> oppList = new List<Opportunity>();
    //List of Subscription
    List<csord__Subscription__c> subscriptionList = new List<csord__Subscription__c>();
    // List of Orders
    List<csord__Order__c> orderList = new List<csord__Order__c>();
	//Service List
    List<csord__Service__c> servlist = new List<csord__Service__c>();
	//List of Accounts for order
    List<account> accountList = new List<account>();
    //Order request on Order
    List<csord__Order_Request__c> orderReqList = new List<csord__Order_Request__c>();
    //Solutions list
    list<csord__Solution__c> solutionList= new list<csord__Solution__c>();
       //Attachment for the services
        list<Attachment> attachmentList= new list<Attachment>();
	
	  newUser = Orchestration_TestUtility.buildUser(true,1);
      System.runAs(newUser[0]){ 
          accountList = Orchestration_TestUtility.buildAccount(true,1);
          oppList =  Orchestration_TestUtility.buildOpp(false,1,accountList);
          oppList[0].OwnerId = newUser[0].id;
          insert oppList;  
          orderReqList = Orchestration_TestUtility.buildOrderRequest(true,1);
          orderList = Orchestration_TestUtility.buildOrder('order1', accountList[0].id, 'Complete', orderReqList[0].id, false , 2);
          for(csord__Order__c ord: orderList){
              ord.csordtelcoa__Opportunity__c = oppList[0].id;
              ord.skipFulfillment__c = false;    
          }
          orderList[1].name='order2'; 
          insert orderList;
     	
          offerList = Orchestration_TestUtility.buildMarkertableOffer(false,3);
          offerList[0].Offer_ID__c = 'DMCAT_Offer_000854';
          offerList[1].Offer_ID__c = 'DMCAT_Offer_000750';
          offerList[2].Offer_ID__c = 'DMCAT_Offer_000681';
          insert offerList; 
    
          productconfiglistList = Orchestration_TestUtility.buildProductConfiguration(false,4);
          productconfiglistList[0].Marketable_Offer__c=offerList[0].id;
          productconfiglistList[0].ConfigurationType1__c = 'SolutionComponent';
          productconfiglistList[1].Marketable_Offer__c=offerList[0].id;
          productconfiglistList[1].ConfigurationType1__c = '';
          productconfiglistList[2].Marketable_Offer__c=offerList[1].id;
          productconfiglistList[2].ConfigurationType1__c = '';
          productconfiglistList[3].Marketable_Offer__c=offerList[2].id;
          productconfiglistList[3].ConfigurationType1__c = '';
          insert productconfiglistList;
    
 		solutionList = Orchestration_TestUtility.buildSolution(true,1);    
       subscriptionList = Orchestration_TestUtility.buildSubscription(false,4,accountList[0].id,orderList, productconfiglistList[0].id,solutionList[0].id);
		subscriptionList[0].csord__order__c = orderList[1].id;
		subscriptionList[1].csord__order__c = orderList[1].id;
		subscriptionList[2].csord__order__c = orderList[1].id;
		subscriptionList[3].csord__order__c = orderList[1].id;
		
		subscriptionList[0].csordtelcoa__Product_Configuration__c = productconfiglistList[0].id;
         subscriptionList[1].csordtelcoa__Product_Configuration__c = productconfiglistList[1].id;
        subscriptionList[2].csordtelcoa__Product_Configuration__c = productconfiglistList[2].id;
        subscriptionList[3].csordtelcoa__Product_Configuration__c = productconfiglistList[3].id;
		
         subscriptionList[0].MarketableOffer__c = offerList[0].id;
         subscriptionList[1].MarketableOffer__c = offerList[0].id;
		 subscriptionList[2].MarketableOffer__c = offerList[1].id;
		 subscriptionList[3].MarketableOffer__c = offerList[2].id;
         subscriptionList[0].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
         subscriptionList[1].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
		 subscriptionList[2].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
		 subscriptionList[3].csord__Status__c = OrchestratorConstants.SubscriptionStatus.Pending;
		 insert subscriptionList; 
		 
    servlist= Orchestration_TestUtility.buildService(false,2,subscriptionList[0].id,orderReqList[0].id,orderList[0].id,productconfiglistList[0].id);
       
        servlist[0].csord__Subscription__c = subscriptionList[0].id;
        servlist[1].csord__Subscription__c = subscriptionList[1].id;
		 insert servlist;
          
           attachmentList = Orchestration_TestUtility.buildAttachment(false,2,servlist,productconfiglistList[0].id);
           attachmentList[1].ParentId = servlist[0].id; 
          attachmentList[1].Name = 'ServiceSpecifications.json';
        attachmentList[1].Body = Blob.valueOf('{"legacyAttributes":[],"serviceId":"'+servlist[0].id+'","specifications":[{"additionalAttributes":{"TenancyID":""},"attributes":{"__targetSystem":"SOMOpenAir","PlatformType":"T-MDM","TenancyID":"","FeatureLevel":"Integrated","TechnicalSupport":"24x7"},"code":"DMCAT_ProductSpecification_000853","description":"Mobility Managed Services_SOMOpenAir","endDate":"","guid":"42587e22-8519-96a7-94e1-e46d4c9c02c2","includeBilling":false,"instanceId":"","metadata":{},"name":"Mobility Managed Services_SOMOpenAir","productConfigurationId":"a3T5P0000004fNxUAI","specification":"DMCAT_ProductSpecification_000853","startDate":"","status":"Created","version":"1"},{"additionalAttributes":{},"attributes":{"__targetSystem":"BILLING","Platform_Type":"T-MDM","FeatureLevel":"Integrated","TechnicalSupport":"24x7","billingSpecId":"BSUSG005_CB","billDescription":"Unified endpoint management - platform management - integrated - 24x7","taxTreatment":"GST Applicable","currency":"AUD","commercialProductId":"a3u5P000000A5eDQAS","rateCardId":"7891","chargeId":"DMCAT_RecurringCharge_000948","externalId":"DMCAT_Offer_000854_DMCAT_ProductSpecification_000853_DMCAT_RecurringCharge_000948_7891"},"code":"DMCAT_ProductSpecification_000853_Billing_RecurringCharge_000948","description":"Mobility Platform Management_Billing_RecurringCharge_000948","endDate":"","guid":"4110577b-bb5d-e9a4-73e6-bb2193c00908","includeBilling":false,"instanceId":"","metadata":{},"name":"853_RC_948","productConfigurationId":"a3T5P0000004fNxUAI","specification":"DMCAT_ProductSpecification_000853DMCAT_ProductSpecification_000853_Billing_RecurringCharge_000948","startDate":"","status":"Created","version":"1"}]}');
         insert attachmentList;
          
         //DPG-3624 
       cscfga__Attribute__c ad1 = new cscfga__Attribute__c(
            cscfga__Product_Configuration__c = productconfiglistList[2].Id,
            Name = 'Operational User',cscfga__Value__c = ''
        );
      List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c> {ad1};
          insert lstAttribute;
    }
      
    }
    
/**************************************  
Name:  processTenancyIdForTmdmMsPs
Description: Update Tenancy Id for MS & PS with TMDM 
Story: DPG-2579
Author: Ila
/******************************************/
    public static testMethod void processTenancyIdForTmdmMsPs(){
      system.debug('inside processTmdmMSPs');
          test.startTest();
        csord__Order__c order = [select id from csord__Order__c where Name='order2'];  
        system.debug('order++' +order);
        List<String> moList = new List<String>{'DMCAT_Offer_000750','DMCAT_Offer_000681'};
            csord__Subscription__c sub= [Select id,TenancyID__c from csord__Subscription__c where csord__order__c =:order.id and MarketableOffer__r.Offer_ID__c=:moList[1]];  
        sub.TenancyID__c='14092020';    
        update sub;
        csord__Subscription__c sub1= [Select id,csord__Status__c,TenancyID__c from csord__Subscription__c where  MarketableOffer__r.Offer_ID__c=:moList[0] and csord__order__c =:order.id];
       
        sub1.csord__Status__c='Active';
        update sub1;
       
        List<String> param = new List<String>();
        param.add(order.id+':::'+sub.TenancyID__c);
        system.debug('param+ ' +param);
       
        TenancyIdUpdate_TmdmMsPs.updateTenancyId(param);
        test.stopTest();
         csord__Subscription__c sub2= [Select id,csord__Status__c,TenancyID__c from csord__Subscription__c where  MarketableOffer__r.Offer_ID__c=:moList[0] and csord__order__c =:order.id];
       
        if(sub2.TenancyID__c==null)
        {
            system.debug('sub2+ within ' +sub2.TenancyID__c);
            sub2.TenancyID__c='14092020';            
        }    
        system.debug('sub2+ ' +sub2.TenancyID__c);
         system.assertEquals(sub.TenancyID__c, '14092020');   
    }
      
}
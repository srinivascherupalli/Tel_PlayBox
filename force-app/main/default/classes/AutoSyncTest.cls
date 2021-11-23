/*************************************************************************************************
Name : AutoSyncTest
Description : Test class for AutoSync trigger
***************************************************************************************************/
@isTest
public class AutoSyncTest {
    
  @isTest  
    public static void autoSyncTestMethod(){
           //CREATE ACCOUNT
             Account acc = AccountTestFactory.buildAccount('Test Account') ;             
             acc.Customer_Status__c = 'Active';
             insert acc;
             System.assertNotEquals(null,acc);
             
             //CREATE OPPORTUNITY
             Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
             insert opp;
             System.assertNotEquals(null,opp);
             
              //Create Basket
              cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
              basket.csbb__Account__c = acc.id;
              basket.cscfga__Opportunity__c = opp.id;
              basket.Name = 'basket1';
              basket.cscfga__Basket_status__c = 'Valid';
              insert basket;
              
              //Create a test event instance
              AutoSync__e asEvent = new AutoSync__e(Basket_Id__c = basket.id,SyncFlag__c=false);
         
              Test.startTest();
              basket.csbb__Synchronised_With_Opportunity__c = false;
              basket.Primary_Basket__c = true;
              update basket;
              // Publish test event
              Database.SaveResult sr = EventBus.publish(asEvent);
              Test.stopTest();
              System.assertEquals(true, sr.isSuccess());
                           
    }
}
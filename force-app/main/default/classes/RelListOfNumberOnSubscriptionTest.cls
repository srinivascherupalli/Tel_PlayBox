/*************************************************************************************************
Name : RelListOfNumberOnSubscriptionContoller
Test Class  : RelListOfNumberOnSubscriptionTest
Ch no 
1.  18/09/2020      Shubhi Vijayvergia   EDGE-173803(new )
2.                  Rashmi       EDGE-219789   
3.  06/10/2021      Puneeth Kamath       DIGI-27409
**************************************************************************************************/
@isTest
public class RelListOfNumberOnSubscriptionTest {
    @TestSetup static void dataSetup()
    {
        Account acc = new Account();         
        acc.name = 'Test';
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';  
        insert acc;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;      
        
        csord__Order__c order = ProductTestFactory.buildOrder('PrimaryOrder', acc.id, 'Created', ordReq.id);
        order.csord__Order_Request__c = ordReq.Id;
        insert order;
        csord__Subscription__c testSubscription = new csord__Subscription__c();
        testSubscription.Name = 'Connected Workplace Solution';
        //testSubscription.csordtelcoa__Subscription_Number__c='SN-000196724';
        testSubscription.csord__Identification__c='test123';
        insert testSubscription;
        List<Number__c> numberList=new List<Number__c>();
        for(integer i=0;i<=5;i++){
            Number__c num=new Number__c();
            num.name='test';
            num.Subscription_number__c=testSubscription.csordtelcoa__Subscription_Number__c;  
            numberList.add(num);
        }
        insert numberList;
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        String orgId=Userinfo.getOrganizationId();
        String dateString=String.valueof(Date.today());
        Integer randomNumber= Integer.valueof(math.rint(math.random()*1000000));
        String uniquename=orgId+dateString+randomNumber;
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username=uniquename+'_salesunifieduser@testsales.com',phone='+121231231234');
        insert sales; 
        
    }
    @isTest
    public static void testRelatedlistofNums(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com'];     
        //System.runAs(sales){
        csord__Subscription__c sub=[Select id,csordtelcoa__Subscription_Number__c from csord__Subscription__c limit 1];
        List<Number__c> numberList=[select Id,name,Service_Number__c,Status__c,Subscription_number__c  from Number__c];
        for(Number__c num: numberList){
            num.Subscription_number__c=sub.csordtelcoa__Subscription_Number__c;
        }
        update numberList;
        system.debug('numlist-->'+numberList);
        numberList=RelListOfNumberOnSubscriptionContoller.getNumbersOfRecord(sub.id);
        system.assertEquals(sub.csordtelcoa__Subscription_Number__c,numberList[0].Subscription_number__c);
        //}
        Test.stopTest();
    }
    @isTest
    public static void testRelatedlistofNumsNegative(){
        Test.startTest();
        User sales = [SELECT id,name FROM User Where email='salesuser@testsales.com'];     
        System.runAs(sales){
            //csord__Subscription__c sub=[Select id from csord__Subscription__c limit 1];
            List<Number__c> numberList=RelListOfNumberOnSubscriptionContoller.getNumbersOfRecord('');
            system.assertEquals(0,numberList.size());
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testRelatedlistofNumsOrder(){
        csord__Order__c order = [Select id,Service_Number__c from csord__Order__c limit 1];
        List<Number__c> numberList = [select Id,name,Service_Number__c,Status__c,Subscription_number__c  from Number__c];
        Test.startTest();
        numberList = RelListOfNumberOnSubscriptionContoller.getNumbersOfRecord(order.id);
        system.assertEquals(0,numberList.size());
        Test.stopTest();
    }
    
}
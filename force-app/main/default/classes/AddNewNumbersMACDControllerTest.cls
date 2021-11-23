@isTest
public with sharing class AddNewNumbersMACDControllerTest {
    @testSetup   
    public static void setupdata(){        
        Account acc = new Account();         
        acc.name = 'Test';
        acc.Pref_Comm_Method__c = 'B2B';
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'Test Accoun1';
        con.LastName  ='Last 1';
        con.AccountId = acc.Id ;
        insert con;
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = 'SN-000223173';
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        //insert numberGroup;
        Number__c num = new Number__c();
        num.Service_Number__c = '61260452045';
        num.Subscription_Number__c = 'SN-000223173';
        num.Status__c = 'Reserved';
        num.Account__c = acc.Id ;
        insert num;
        csord__Subscription__c sub = new csord__Subscription__c();
        sub.csord__Identification__c='abcdeee';
        sub.csordtelcoa__Subscription_Number__c='SN-000223173';
        sub.csord__Status__c = 'Active';
        sub.serviceMSISDN__c='0123456789';
        insert sub;
              
         BDSNotifyTestFactory.createBdsNotifySettings(); 
        
        //DIGI-13386
        csord__Service__c ser = new csord__Service__c();
        ser.csordtelcoa__Service_Number__c = 'SVC-123456789';
        ser.csord__Subscription__c = sub.Id;
        ser.csord__Identification__c = 'Service_Test_0';
        insert ser;
        
    }
    
    @isTest
    public static void createOrderTest(){ 
        String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000223173","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';
        String accId = [select Id from Account limit 1].Id ; 
        String conId = [select Id from Contact limit 1].Id ;
        //List<Number_Group__c> numberGroup = [SELECT ID FROM Number_Group__c];
        Number_Group__c numberGroup = new Number_Group__c();
        numberGroup.Subscription_Number__c = 'SN-000223173';
        numberGroup.Status__c = 'Reserved';
        numberGroup.Scenario_Type__c = 'Add';
        insert numberGroup;
        List<String> numGroupIds = new List<String>{numberGroup.Id};
            List<String>  searchNum=new List<String>{'61260452045'};      
                Test.startTest(); 
        String status = AddNewNumbersMACDController.createOrder(numGroupIds,subscription, accId,conId);
        List<csord__Order__c> orders = new  List<csord__Order__c>([SELECT Id,csord__Account__r.CIDN__c ,csord__Order_Number__c, Fulfilment_Order_Version__c  FROM csord__Order__c]);
        AddNewNumbersMACDController.submitOrder(orders[0].Id);
        system.assert(String.isNotBlank(status));
        Test.stopTest();
        // System.assertEquals(status, actual);
    }
    
    
    @isTest
    public static void assignReservedNumbersTest(){
        String searchNumType='Non Contiguous';
        String data='[{"PhoneNumber":"61260452045","Status":"Assigned"}]';
        String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000223173","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';
        String  accId =[select Id from Account limit 1].Id ;
        Test.startTest();  
        AddNewNumbersMACDController.Response res =AddNewNumbersMACDController.assignReservedNumbers(data, subscription, accId);
        system.assert(res !=null);
        Test.stopTest();
    }
    
    
    @isTest
    public static void assignReservedNumbersTest1(){
        String searchNumType='Contiguous';
        String data='[{"PhoneNumber":"61260452045 - 61260452050","Status":"Assigned"}]';
        String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000223173","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';
        String  accId =[select Id from Account limit 1].Id ;
        Test.startTest();  
        AddNewNumbersMACDController.Response res1 =AddNewNumbersMACDController.assignReservedNumbers(data, subscription, accId);
        system.assert(res1 !=null);
        Test.stopTest();
    }
    
    @isTest 
    public static void doNumbersExistTest(){
        List<String> searchNum=new List<String>();
        searchNum.add('12345 - 234567');
        Test.startTest(); 
        List<AddNewNumbersMACDController.NumbersExistWrap>  listwrap =AddNewNumbersMACDController.doNumbersExist(searchNum,'[{"billingAccount":"700001268898","createdBy":"Ankit Goswami","createdDate":"28/05/2021 00:41:15","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00168603","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003llbQAA","subscriptionName":"Business Calling-Individual Line-Standard_1","subscriptionNumber":"SN-000238215","totalOC":"$ 0.00","totalRC":"$ 0.00"}]');
        system.debug(listwrap);
        system.assert(listwrap.size() >0);
        Test.stopTest();
        // System.assertEquals(status=='SUCCESS',true,'Contiguous type exist');
    }   
    
    
    
    @isTest 
    public static void removeReservedNumbersTest(){    
        String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000223173","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';      
        List<String> resNumbers = new List<String>{'61260452045'};
            Test.startTest(); 
        AddNewNumbersMACDController.Response res  =AddNewNumbersMACDController.removeReservedNumbers(resNumbers,subscription);
        system.assert(res !=null);
        Test.stopTest();
    } 
    
    @isTest 
    public static void removeReservedNumbersNonexistingNumbTest(){ 
        String subscription='[{"billingAccount":"700001268898","createdBy":"Aditya Pareek","createdDate":"07/04/2021 14:01:30","disableRow":false,"isBillStopped":false,"isCWP":true,"MarketOffer":"DMCAT_Offer_000618","OrderNumber":"ON00160457","productDefinitionName":"DMCAT_ProductSpecification_000871","status":"Active","SubscriptionID":"a4g2N0000003JGtQAM","subscriptionName":"Business Calling","subscriptionNumber":"SN-000223173","totalOC":"$ 0.00","totalRC":"$ 0.00"}]';         
        List<String> resNumbers = new List<String>{'61260452045'};
            Test.startTest(); 
        AddNewNumbersMACDController.Response res  =AddNewNumbersMACDController.removeReservedNumbers(resNumbers,subscription);
        system.assert(res !=null);
        Test.stopTest();
    } 
    
    @isTest 
    public static void getContiguousSplitNumbersTest(){
        String searchNum='[{"numberList":"61738779200 - 61738779299"}]';
        Test.startTest();      
        List<AddNewNumbersMACDController.LRMWrapper> lst  =AddNewNumbersMACDController.getContiguousSplitNumbers(searchNum);
        system.assert(lst.size() > 0);
        Test.stopTest();
        //System.assertEquals(status=='SUCCESS',true,'Numbers splitted successfully');
    }
    @isTest 
    public static void fatchSubscriptionsTest(){
        String accId = [select Id from Account limit 1].Id ; 
        system.assert(String.isNotBlank(accId));
        String  typeSelected= 'Manage Fixed Numbers';
        List<csord__Subscription__c> subsList= [SELECT Id FROM csord__Subscription__c];
        List<String> subsId = new List<String>{subsList[0].Id};
            Test.startTest(); 
        List<SubWrapper> lst  = AddNewNumbersMACDController.fatchSubscriptions(accId,typeSelected,subsId);
        
        Test.stopTest();
        //System.assertEquals(status=='SUCCESS',true,'Numbers splitted successfully');
    } 
    
    @isTest 
    public static void testReserveNumbersCallout(){
        List<String> searchNum = new List<String>();
        searchNum.add('61738779200 - 61738779299');
        Test.startTest();   
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('success_fixed'));
        string status = AddNewNumbersMACDController.numberStatusSync(searchNum, 'Reserve');
        System.assert(status == 'Success');
        Test.stopTest();
    }
    
    @isTest 
    public static void testRemoveNumbersCallout(){
        List<String> searchNum = new List<String>();
        searchNum.add('61738779200 - 61738779299');
        Test.startTest();      
        Test.setMock(HttpCalloutMock.class, new MockNumberReservationFixed('errorResponse'));
        string status = AddNewNumbersMACDController.numberStatusSync(searchNum, 'Remove');
        System.assert(String.isNotBlank(status));
        Test.stopTest();
    }
    
    public class LRMWrapper{
        public String numberList;
        public Boolean isSelectedNew;
        public String message;
    }
    
    
    
    public class SubscriptionDetails{
        public string subscriptionId;
        public String subscriptionNumber;
        public String orderNumber;
        public String serviceNumber; //DIGI-13386
    }
    
    public class Response{
        public String message;
        public List<String> recordIds;
        public boolean isSuccess;
        public Response(String msg, List<String> recIds, boolean isInserted){
            message = msg;
            recordIds  = recIds;
            isSuccess = isInserted;
        }
    }
    
    
}
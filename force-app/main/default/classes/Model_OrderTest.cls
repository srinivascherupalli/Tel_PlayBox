/******************************************************************************************************************************
Class Name : Model_Order
Test Class : Model_Ordertest 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Shubhi              22/02/2021    EDGE-191138(order gen issue fix))21.05
******************************************************************************************************************************/

@isTest
public class Model_OrderTest {
    
    //Desc: Test Data Setup
    @TestSetup
    public static void setup(){
        Profile pf = [select id from profile where name =:Label.Profile_SystemAdmin];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='adminuser@testAdmin.com',phone='+121231231234');
        insert sales;
        
        List<Account> accLst= new List<Account>();
        Account accOut = new Account();
        accOut.name = 'Test CHOWN Outgoing Account';
        accLst.add(accOut);
        
        Account accIn = new Account();
        accIn.name = 'Test CHOWN Incoming Account';
        accLst.add(accIn);
        insert accLst;
        
        List<Opportunity> opptyLst= new List<Opportunity>();
        Opportunity opptyOut = new Opportunity();
        opptyOut.Account = accOut;
        opptyOut.name = 'Test CHOWN Outgoing Oppty';
        opptyOut.StageName = 'Propose';
        opptyOut.CloseDate = System.today()+1;
        opptyLst.add(opptyOut);
        
        Opportunity opptyIn = new Opportunity();
        opptyIn.Account = accIn;
        opptyIn.name = 'Test CHOWN Incoming Oppty';
        opptyIn.StageName = 'Propose';
        opptyIn.CloseDate = System.today()+1;
        opptyLst.add(opptyIn);
        insert opptyLst;
        
        List<cscfga__Product_Basket__c> basketLst= new List<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basketOut = new cscfga__Product_Basket__c();
        basketOut.name = 'Test CHOWN Outgoing Basket';
        basketOut.BasketType__c = 'Outgoing';
        basketOut.csordtelcoa__Basket_Stage__c = 'Enriched';
        basketOut.csbb__Account__c = accOut.id;
        basketOut.cscfga__Opportunity__c = opptyOut.id;
        basketLst.add(basketOut);
        
        cscfga__Product_Basket__c basketIn = new cscfga__Product_Basket__c();
        basketIn.name = 'Test CHOWN Outgoing Basket';
        basketIn.BasketType__c = 'Incoming';
        basketIn.csordtelcoa__Basket_Stage__c = 'Enriched';
        basketIn.csbb__Account__c = accIn.id;
        basketIn.cscfga__Opportunity__c = opptyIn.id;
        basketLst.add(basketIn);
        insert basketLst;
        
        List<cscfga__Product_Configuration__c> configLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c configOut = new cscfga__Product_Configuration__c();         
        configOut.name = 'Test Outgoing Config';
        configOut.configGUID__c = 'dfghjkl56789067890vbnjkf';
        configOut.cscfga__Product_Basket__c = basketOut.Id;
        configOut.ConfigurationType1__c = '';
        configLst.add(configOut);
        
        cscfga__Product_Configuration__c configIn = new cscfga__Product_Configuration__c();         
        configIn.name = 'Test Outgoing Config';
        configIn.configGUID__c = 'dfghjkl56789067890vbnjkf';
        configIn.cscfga__Product_Basket__c = basketIn.Id;
        configIn.ConfigurationType1__c = '';
        configLst.add(configIn);
        insert configLst;
        
        List<csord__Order_Request__c> ordReqList = new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq);
        csord__Order_Request__c ordReq1 = ProductTestFactory.buildOrderRequest();
        ordReqList.add(ordReq1);
        insert ordReqList;
        
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', accOut.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csordtelcoa__Opportunity__c = opptyOut.Id;
        orderList.add(ord);
        csord__Order__c ord1 = ProductTestFactory.buildOrder('TestOrder1', accIn.id, 'Created', ordReq1.id);
        ord1.csord__Order_Request__c = ordReq1.Id;
        ord1.csordtelcoa__Opportunity__c = opptyIn.Id;
        orderList.add(ord1);
        insert orderList;
        
        List<csord__Subscription__c> subList = new List<csord__Subscription__c>();  
        csord__Subscription__c subOut = new csord__Subscription__c();
        subOut.csord__Identification__c = 'Subscription_1';
        subOut.csordtelcoa__Product_Configuration__c = configOut.id;
        subOut.name = 'Test Outgoing Subscription';
        subOut.csordtelcoa__Replacement_Subscription__c = null;
        subOut.csord__Order__c = ord.Id;
        subList.add(subOut);
        
        csord__Subscription__c subIn = new csord__Subscription__c();
        subIn.csord__Identification__c = 'Subscription_2';
        subIn.csordtelcoa__Product_Configuration__c = configIn.id;
        subIn.name = 'Test Incoming Subscription';
        subIn.csordtelcoa__Replaced_Subscription__c = null;
        subIn.csord__Order__c = ord1.Id;
        subList.add(subIn);
        insert subList;
        
        List<csord__Service__c> servList = new List<csord__Service__c>();
        csord__Service__c servOut = new csord__Service__c();
        servOut.csordtelcoa__Product_Configuration__c = configOut.id;
        servOut.csord__Subscription__c = subOut.id;
        servOut.csord__Identification__c = 'Service_0';
        servOut.name = 'Test Outgoing Service';
        servList.add(servOut);
        
        csord__Service__c servIn = new csord__Service__c();
        servIn.csordtelcoa__Product_Configuration__c = configIn.id;
        servIn.csord__Subscription__c = subIn.id;
        servIn.csord__Identification__c = 'Service_1';
        servIn.csordtelcoa__Replaced_Service__c = null;
        servIn.name = 'Test Incoming Service';
        servList.add(servIn);
        insert servList;

    }
    @isTest
    public static void getorderfrombasketPositive(){
        Set<String> basketIdSet = new Set<String>();
        for(cscfga__Product_Basket__c basket : [Select Id From cscfga__Product_Basket__c Where Name In ('Test CHOWN Outgoing Basket')]){
            basketIdSet.add(basket.Id);
        }
        Model_Order.getorderfrombasket(basketIdSet);
    }
    @isTest
    public static void getorderfrombasketNegative(){
        
    }
    
    public static testMethod void getOrdersList_Test(){
        Set<String> orderIdSet = new Set<String>();
        for(csord__Order__c order : [Select Id From csord__Order__c Where Name In ('TestOrder', 'TestOrder1')]){
            orderIdSet.add(order.Id);
        }
        Model_Order.getOrdersList(orderIdSet);
    }
    
    public static testMethod void getOrdersListFromServices_Test(){
        Set<String> recIdSet = new Set<String>();
        for(csord__Service__c service : [Select Id From csord__Service__c Where Name In ('Test Outgoing Service', 'Test Incoming Service')]){
            recIdSet.add(service.Id);
        }
        Model_Order.getOrdersListFromServices(recIdSet);
    }

}
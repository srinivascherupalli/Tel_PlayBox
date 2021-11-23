/********************************************************
Class Name : GetSubscriptionHelperTest
===============================================================================================================================
Change.No. Developer Name          Date       Story        Description
1.         Pradeep Kumar        17/10/2018  
2.       Shreya          24/11/2019     EDGE-117980     addded plan field to service & testFetchUCNumbers method for code coverage
3.         Vaibhav Deshpande        20/12/2019      EDGE-98388     Changed logic to populate fixed numbers from number object
4.         Dheeraj Bhatt            08-June-2020   EDGE-149915 -Modify GetSubscriptionDetails API to support duplicate number/subscription records**********************************************************
5.        Gnana            14-May-2021    EDGE-214615 - Added a new test method
5.        Arun             10-Aug-2021    DIGI-9672 - Added GUID Tag for Mobile Numbers not for Fixed Numbers
*/
@isTest(SeeAllData=false)
public class GetSubscriptionHelperTest {
    @testsetup 
    public static void dataSetup(){
        
        Account acc = new Account();
        acc.name = 'Account1';
        acc.Type = 'Competitor' ;
        acc.Customer_ID__c = '12345';
        
        insert acc;
        
        cscfga__Configuration_Offer__c off = new cscfga__Configuration_Offer__c();
        off.Offer_Spec_Id__c='123456';
        insert off;
        
        cscrm__Site__c si= new cscrm__Site__c();
        si.name='TestSite';
        si.cscrm__Account__c = acc.id;
        insert si;
        LIST<csord__Order__c> orderlist=new List<csord__Order__c>();  
        csord__Order__c  ord = new csord__Order__c();    
        ord.name = 'TestOrder';
        //ord.csord__Order_Number__c='ON00003147';
        ord.csord__Identification__c ='Test';
        ord.csord__Start_Date__c = date.today();
        orderlist.add(ord);
        csord__Order__c  ord1 = new csord__Order__c();
        ord1.name = 'TestOrder';
        //ord.csord__Order_Number__c='ON00003147';
        ord1.csord__Identification__c ='Test';
        ord1.csord__Start_Date__c = date.today();
        orderlist.add(ord1);
        insert orderlist;
        ord1.csord__Primary_Order__c=ord.id;
        update ord1;     
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.csordtelcoa__Subscription_Number__c = 'SN-000004523';
        subs.name = 'subsTest';
        subs.csord__Account__c = acc.id;
        subs.csord__Status__c = 'Complete';
        subs.Contract_Term__c='ABC';
        subs.Serviceability_Location__c='Mumbai';
        subs.Offer__c = off.id;
        subs.csord__Identification__c = 'test identity';
        subs.Site__c=si.id;
        subs.Right_to_Bill_Date__c = date.today();
        subs.csord__Order__C=ord1.id;
        subs.Contract_Start_Date__c =Date.today();
        subs.TON_Barring_Status__c = 'Barred';
        insert subs;
        
        csord__Subscription__c subs1 = new csord__Subscription__c();
        subs1.csordtelcoa__Subscription_Number__c ='SN-000004524';
        subs1.name = 'subsTest1';
        subs1.csord__Account__c = acc.id;
        subs1.csord__Status__c = 'Complete';
        subs1.Contract_Term__c='ABC';
        subs1.Serviceability_Location__c='Mumbai';
        subs1.Offer__c = off.id;
        subs1.csord__Identification__c = 'test identity';
        subs1.Site__c=si.id;
        subs1.TON_Barring_Status__c = 'Barred';
        subs1.Right_to_Bill_Date__c = date.today();
        subs1.csord__Order__C=ord1.id;
        subs1.Contract_Start_Date__c =Date.today();
        insert subs1;
        
        //EDGE-117980 plan field added    
        csord__Service__c serv= new csord__Service__c();
        serv.name = 'TestService';
        serv.csordtelcoa__Service_Number__c='SVC-000067679';
        serv.csord__Subscription__c=subs1.id;
        serv.csord__Identification__c='Test';
        serv.csord__Order__c=ord1.id;
        serv.Plan__c = 'Local';
        serv.Scenario_Type__c='Change of Mobile Number';
        insert serv;
        string serviceNumber=[SELECT csordtelcoa__Service_Number__c from csord__Service__c WHERE Id =: serv.id ].csordtelcoa__Service_Number__c;
        string subscriptionNumber=[SELECT csordtelcoa__Subscription_Number__c from csord__Subscription__c WHERE Id =: subs1.id ].csordtelcoa__Subscription_Number__c;
        
        List<Number__c> numList=new List<Number__c>();
        Number__c num=new Number__c();
        num.Service_Id__c=serv.csordtelcoa__Service_Number__c;
        num.Service_Number__c='6532589526';
        num.Status__c='RESERVED';
        num.is_Part_of_Range__c=true;
        num.Start_Range__c='6532589524';
        num.End_range__c='6532589528';
        num.Mobile__c='Fixed'; 
        num.Subscription_number__c=subscriptionNumber;
        num.Service_Id__c=serviceNumber;
        numList.add(num);
        
        Number__c num2=new Number__c();
        num2.Service_Id__c=serv.csordtelcoa__Service_Number__c;
        num2.Service_Number__c='6532589516';
        num2.Status__c='RESERVED';
        num2.is_Part_of_Range__c=false;
        num2.Start_Range__c='6532589514';
        num2.End_range__c='6532589518';
        num2.Mobile__c='Fixed';
        num2.Service_Id__c=serviceNumber;
        num2.Subscription_number__c=subscriptionNumber;
        numList.add(num2);
        
        Number__c num3=new Number__c();
        num3.Service_Id__c=serv.csordtelcoa__Service_Number__c;
        num3.Service_Number__c='6532589514';
        num3.Status__c='RESERVED';
        num3.is_Part_of_Range__c=false;
        num3.Start_Range__c='6532589514';
        num3.End_range__c='6532589518';
        num3.Mobile__c='Fixed';
        num3.Service_Id__c=serviceNumber;
        num3.Subscription_number__c=subscriptionNumber;
        numList.add(num3);
        
        insert numList;
        
        csord__Service__c serv1= new csord__Service__c();
        serv1.name = 'TestService1';
        serv1.csordtelcoa__Service_Number__c='SVC-000123564';
        serv1.csord__Subscription__c=subs1.id;
        serv1.csord__Identification__c='Test1';
        serv1.csord__Order__c=ord1.id;
        serv1.Plan__c = 'Local';
        serv1.Scenario_Type__c='Change of Mobile Number';
        insert serv1;
        
        Number__c num1=new Number__c();
        num1.Service_Id__c=serv1.csordtelcoa__Service_Number__c;
        num1.Service_Number__c='6532589526';
        num1.Status__c='RESERVED';
        num1.is_Part_of_Range__c=true;
        num1.Start_Range__c='6532589524';
        num1.End_range__c='6532589528';
        num1.Mobile__c='Fixed'; 
        num1.Subscription_number__c='SN-000004524';
        insert num1;
        
        Attachment att1 = new Attachment();
        att1.Body = Blob.valueOf('{"specifications":[{"additionalAttributes" : {"SERVID" : "61474814390"},"attributes" : {"BillofMaterialID" : "{BoMForMobileAccess}","__targetSystem" : "FULFILMENT","ServiceID" : "","ShippingRequired " : "TRUE",     "ExternalAntennaRequired" : "FALSE","IMSI" : "1234","IPVPNProductInstanceId" : "DMCAT_ProductSpecification_000028_Fulfilment","CustomerFacingServiceId" : "1234"},"code" : "DMCAT_ProductSpecification_000871_Fulfilment","description" : "","endDate" : "","guid" : "434207c7-7981-4588-4357-c643c351234b","instanceId" : "","name" : "Mobile Access_Fulfilment","productConfigurationId" : "a3T2O0000008yTH","specification" : "null_chrgOC","startDate" : "","status" : "Created","version" : "1"},{"version" : "1","status" : "Created","startDate" : "","specification" : "DMCAT_ProductSpecification_000322DMCAT_ProductSpecification_000313","productConfigurationId" : "a3T2O000000GhjSUAS","name" : "UC Numbers_Fulfilment","metadata" : { },"instanceId" : "", "includeBilling" : false,"guid" : "219ab53a-68eb-a3a6-e477-7302c720a9b9","endDate" : "","description" : "","code" : "DMCAT_ProductSpecification_000313_Fulfilment","attributes" : {"Number" : [ {"attributes" : {"listCode" : "LE","status" : "RESERVED","rangeTo" : null,"rangeFrom" : null,"FNN" : "0738193230"},"schemaId" : "589544bf-9bc3-f356-0797-f85d9d65eba5"},{"attributes" : {"listCode" : "No Entry Line","status" : "RESERVED","rangeTo" : "738193246","rangeFrom" : "738193245","FNN" : null},"schemaId" : "ce52bbcc-fa77-8d1f-24c8-25231aa51c42"} ],"__targetSystem" : "FULFILMENT","parentSpec" : "DMCAT_ProductSpecification_000322_Fulfilment"},"additionalAttributes" : {"parentSpec" : "7da9c15a-31c1-cf3a-806b-1bb843712e18"},"complexAttributes":{"complexAttributes":[{"simpleAttributes":[{"value":"8080","name":"complexAttrPort"},{"value":"Fibre","name":"complexAttrTech"}, {"value":"ACTIVE","name":"status"},{"value":"123","name":"rangeTo"},{"value":"456","name":"rangeFrom"}],"productConfigurationId":"ConfigId1"}]}}], "legacyAttributes" : [ ],"serviceId" : "'+serv.Id+'"}');
        att1.Name = 'ServiceSpecifications.json';
        att1.ParentId = serv.Id;
        insert att1;     
        EnvironmentVariable__c envrn = new EnvironmentVariable__c(Name='enableSplunkAttributesInventory', Value__c = 'true');
        insert envrn;
        
        Asset newAsset= TestDataFactory.generateAsset('apple iphone 7',subs.id,null,system.today(),system.today(), 1.0,acc.id,'test123456');
        newAsset.Status='Active';
        Insert newAsset;
        
        Asset newAsset1= TestDataFactory.generateAsset('apple iphone 7',subs1.id,null,system.today(),system.today(), 1.0,acc.id,'test123457');
        newAsset1.Status='InActive';
        newAsset1.csordtelcoa__Replaced_Asset__c=newAsset.id;
        newAsset1.parentId=newAsset.id;
        Insert newAsset1;
    }
    @isTest
    public static void findServiceSpecTest(){
        
        
        //String Correlation = subs.csordtelcoa__Subscription_Number__c;
        //DPG-4574 added Suspension_reason_summary__c
        List<csord__Subscription__c> subList = [SELECT id, 
                                                name,Suspension_reason__c,Suspension_reason_summary__c,MarketableOffer__c,MarketableOffer__r.Offer_ID__c,
                                                csord__Account__c,Device_Replacement_DMCAT_Id__c, 
                                                csord__Account__r.Customer_ID__c,
                                                serviceMSISDN__c,
                                                csord__Account__r.CIDN__c,
                                                Billing_Account__r.Billing_Account_Number__c, 
                                                csordtelcoa__Subscription_Number__c, 
                                                Right_to_Bill_Date__c,
                                                csord__Status__c, 
                                                csord__Order__r.csord__Start_Date__c,
                                                csord__Order__r.CreatedDate, 
                                                csord__Order__r.csord__End_Date__c,
                                                csord__Order__c, 
                                                Contract_Term__c, 
                                                Serviceability_Location__c, 
                                                Contract_Start_Date__c, 
                                                Offer__r.Offer_Spec_Id__c, 
                                                Site__r.name, 
                                                Site__r.AdborID__c,
                                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c, 
                                                csord__Order__r.csordtelcoa__Opportunity__c,
                                                csord__Order__r.csord__Primary_Order__c, 
                                                Product_Model_Version__c, modelChange__c,Nickname__c, TON_Barring_Status__c FROM 
                                                csord__Subscription__c 
                                                WHERE  name = 'subsTest1'];
        List<csord__Service__c> serviceList=[SELECT Id, 
                                             Name,csord__Status__c, 
                                             csordtelcoa__Service_Number__c,
                                             csord__Order__c,NetworkServiceId__c,
                                             csord__Order__r.csordtelcoa__Opportunity__c,
                                             Product_Model_Version__c,modelChange__c,International_Direct_Dial__c,Mobility_Plan__c, Plan__c,Scenario_Type__c 
                                             FROM 
                                             csord__Service__c  WHERE csord__Subscription__c=: subList[0].id];
        List<Number__c> numberList=[SELECT id,Service_Id__c,Status__c,Service_Number__c,is_Part_of_Range__c,Start_Range__c,End_range__c,Mobile__c,Subscription_number__c FROM Number__c WHERE Subscription_number__c=:subList[0].csordtelcoa__Subscription_Number__c];
        List<asset> assetList=[SELECT Id,Subscription__c, Subscription__r.csordtelcoa__Subscription_Number__c,
                                  csordtelcoa__Replaced_Asset__r.AssetID__c,csordtelcoa__Replaced_Asset__r.Name FROM Asset 
                                  WHERE Subscription__c=:subList[0].id LIMIT 1];
           
        csord__Subscription__c solSubs= new csord__Subscription__c();
        system.assertNotEquals(null, GetSubscriptionHelper.findServiceSpec(subList[0].csordtelcoa__Subscription_Number__c,subList[0],serviceList,numberList,solSubs,assetList));
        
    }
    
    @isTest
    public static void findServiceSpecTest_Exception(){
        SubscriptionDetailsResponse dtoResponse = GetSubscriptionHelper.findServiceSpec(null,null,null,null,null,null);
        list<Exception_Log__c> expList = [select id,Error_Description__c from Exception_Log__c];
        system.assertNotEquals(null,expList);
        
    }
    
    @isTest
    public static void findErrorSpecTest(){
        String subsNo = 'SN-000004523';
        String Correlation = 'SN-000004523';
        system.assertNotEquals(null, GetSubscriptionHelper.findErrorSpec404(Correlation));
        
    }
    @isTest
    public static void findErrorSpec502Test(){
        String subsNo = 'SN-000004523';
        String Correlation = 'SN-000004523';
        GetSubscriptionHelper.ListingFNNWrapper wrp=new GetSubscriptionHelper.ListingFNNWrapper();
        wrp.fnn='12445';
        wrp.range='1234';
        system.assertNotEquals(null, GetSubscriptionHelper.findErrorSpec502(Correlation));
        
    } 
    
    @isTest 
    public static void NumberDTOTest(){
        GetSubscriptionHelper.Numbers nums=new GetSubscriptionHelper.Numbers();
        nums.endRange='123456789';
        nums.isPartofRange='Y';
        nums.numbers='123456787';
        nums.startRange='123456785';
        nums.status='RESERVED';
        nums.GUID='12345';  // DIGI-9672
        system.assertNotEquals(null, nums);
        
    }
    
    
    
}
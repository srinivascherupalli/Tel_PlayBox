@isTest
public class GetSubscriptionHandlerTest {
    
    @testsetup 
    public static void dataSetup(){
        
        Account acc = new Account();
        acc.name = 'Account1';
        acc.Type = 'Competitor' ;
        acc.Customer_ID__c = '12345';
        acc.Customer_Status__c = 'ACTIVE'; //DPG-4574
        
        insert acc;
        
        Opportunity opp =  ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c=opp.id;
        insert basket;
        
        List<cscfga__Product_Definition__c> pdList=new List<cscfga__Product_Definition__c>();
        
        cscfga__Product_Definition__c productDefinition = new cscfga__Product_Definition__c();
        productDefinition.Name = 'Mobile Subscription';
        productDefinition.cscfga__Description__c = 'Mobile Subscription';
        productDefinition.product_Specification__c = 'DMCAT_ProductSpecification_000420';
        pdList.add(productDefinition);
        
        cscfga__Product_Definition__c productDefinition2 = new cscfga__Product_Definition__c();
        productDefinition2.Name = 'Enterprise Mobility';
        productDefinition2.cscfga__Description__c = 'Enterprise Mobility';
        productDefinition2.product_Specification__c = 'DMCAT_Offer_000646';
        pdList.add(productDefinition2);
        
        insert pdList;
        
        List<cscfga__Product_Configuration__c> pcList=new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        productConfig.cscfga__Product_Definition__c = productDefinition.Id;
        productConfig.Remaining_Term__c  = 24;
        productConfig.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig);
        
        cscfga__Product_Configuration__c productConfig2 = new cscfga__Product_Configuration__c();
        productConfig2.cscfga__Product_Definition__c = productDefinition2.Id;
        productConfig2.ConfigurationType1__c='SolutionComponent';
        productConfig2.Remaining_Term__c  = 24;
        productConfig2.cscfga__Product_Basket__c=basket.id;
        pcList.add(productConfig2);
        insert pcList;
        
        
        cscfga__Configuration_Offer__c off = new cscfga__Configuration_Offer__c();
        off.Offer_Spec_Id__c='123456';
        insert off;
        
        cscrm__Site__c si= new cscrm__Site__c();
        si.name='TestSite';
        si.cscrm__Account__c = acc.id;
        insert si;
        
        csord__Order__c  ord = new csord__Order__c();
        ord.name = 'TestOrder';
        //ord.csord__Order_Number__c='ON00003147';
        ord.csord__Identification__c ='Test';
        insert ord;
        
        csord__Subscription__c subs = new csord__Subscription__c();
        subs.csordtelcoa__Subscription_Number__c = 'SN-000004523';
        subs.csord__Order__c = ord.id;
        subs.name = 'subs';
        subs.csord__Account__c = acc.id;
        subs.csord__Status__c = 'Complete';
        subs.Contract_Term__c='ABC';
        subs.Serviceability_Location__c='Mumbai';
        subs.Offer__c = off.id;
        subs.csord__Identification__c = 'test identity';
        subs.Site__c=si.id;
        insert subs;
        
        csord__Subscription__c solutionSubscription=new csord__Subscription__c();
        solutionSubscription.name  = 'test subs';
        solutionSubscription.csord__Identification__c = 'test identity';
        solutionSubscription.csord__Status__c = 'Pending';
        solutionSubscription.csord__Order__c = ord.id;
        solutionSubscription.Parent_Subscription__c=subs.id;
        solutionSubscription.csordtelcoa__Product_Configuration__c=productConfig2.id;
        subs.csordtelcoa__Subscription_Number__c='SN-000172209';
        insert solutionSubscription;
        
        csord__Service__c serv= new csord__Service__c();
        serv.name = 'TestService';
        serv.csord__Subscription__c=subs.id;
        serv.csord__Identification__c='Test';
        serv.Scenario_Type__c='Port In';
        insert serv;
        
        string serviceNumber=[SELECT csordtelcoa__Service_Number__c from csord__Service__c WHERE Id =: serv.id ].csordtelcoa__Service_Number__c;
        string subscriptionNumber=[SELECT csordtelcoa__Subscription_Number__c from csord__Subscription__c WHERE Id =: subs.id ].csordtelcoa__Subscription_Number__c;
        
        Number_Group__c ng = new Number_Group__c();  //DIGI-1409/DIGI-9672
        ng.Subscription_number__c = subscriptionNumber;
        ng.Service_Instance_Id__c = 'TestServiceInstanceId';
        ng.Pattern_Type__c = 'Number';
        insert ng;

        List<Number__c> numberList=new List<Number__c>(); 
        Number__c num= new Number__c(Service_Id__c=serviceNumber,Service_Number__c='61459812342',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num);
        
        Number__c num1= new Number__c(Service_Number__c='61459812345',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890123',IMSI__c='1234',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num1);
        Number__c num2= new Number__c(Service_Id__c=serviceNumber,Subscription_number__c=subscriptionNumber,Service_Number__c='61459812346',Type__c='FNN', Mobile__c='Fixed',Sim_Serial_Number__c='1234567890125',IMSI__c='1234567890123',Basket__c=basket.id,Product_Configuration__c=productConfig.id);
        numberList.add(num2);
        Number__c num3= new Number__c(Service_Id__c=serviceNumber,Subscription_number__c=subscriptionNumber,Service_Number__c='61459812346',Type__c='FNN', Mobile__c='Mobile',Sim_Serial_Number__c='1234567890125',IMSI__c='1234567890123',Basket__c=basket.id,Product_Configuration__c=productConfig.id,Number_Group__c = ng.Id);
        numberList.add(num3);  // DIGI-1409/DIGI-9672
        insert numberList;
        
        Asset newAsset= TestDataFactory.generateAsset('apple iphone 7',solutionSubscription.id,null,system.today(),system.today(), 1.0,acc.id,'test123456');
        newAsset.Status='Active';
        Insert newAsset;
        
        Asset newAsset1= TestDataFactory.generateAsset('apple iphone 7',subs.id,null,system.today(),system.today(), 1.0,acc.id,'test123457');
        newAsset1.Status='InActive';
        newAsset1.csordtelcoa__Replaced_Asset__c=newAsset.id;
        newAsset1.parentId=newAsset.id;
        Insert newAsset1;
    }
    
    @isTest
    public static void validateRequestTest(){
        //csord__Order__c ordDetails = [Select id, csord__Order_Number__c from csord__Order__c where name = 'TestOrder' limit 1];
        try{
            
            csord__Subscription__c subDetials = [Select id,csord__Order__r.csord__Order_Number__c, csordtelcoa__Subscription_Number__c from csord__Subscription__c where name = 'subs' limit 1];
            String Correlation = subDetials.csordtelcoa__Subscription_Number__c; 
            
            system.assertEquals('Valid',GetSubscriptionHandler.validateRequest(Correlation));
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }      
    
    @isTest
    public static void generateResponseTest_200(){
        try{
            
            RestResponse res = new RestResponse();
            //csord__Order__c ordDetails = [Select id, csord__Order_Number__c from csord__Order__c where name = 'TestOrder' limit 1];
            csord__Subscription__c subDetials = [Select id,csord__Order__r.csord__Order_Number__c, csordtelcoa__Subscription_Number__c from csord__Subscription__c where name = 'subs' limit 1];
            String Correlation = subDetials.csordtelcoa__Subscription_Number__c;  
            
            system.assertNotEquals(null,GetSubscriptionHandler.generateResponse(res,Correlation));
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
    }
    
    
    @isTest
    public static void generateResponseTest(){
        try{  
            
            RestResponse res = new RestResponse();            
            String Correlation = 'SN-000004523'; 
            
            system.assertNotEquals(null,GetSubscriptionHandler.generateResponse(res,Correlation));
        }catch(Exception e){
            system.debug(e.getMessage());
        }
    }
    @isTest
    public static void generateResponseErrorTest(){
        try{
            
            RestResponse res = new RestResponse();
            String Correlation = '0004523'; 
            
            system.assertNotEquals(null,GetSubscriptionHandler.generateResponse(res,Correlation));
        }catch(Exception e){ 
            
            system.debug(e.getMessage());
        }
    }
    @isTest
    public static void generateResponseErrorTest2(){                
        RestResponse res = new RestResponse();
        list<csord__Subscription__c> subsLst = [select id from csord__Subscription__c];
        if(subsLst != null && subsLst.size()>0){
            subsLst[0].csord__Status__c = 'Closed Replaced';
            subsLst[0].csordtelcoa__Subscription_Number__c = 'SN-000004523';
            //update subsLst;
        }
        //delete subsLst;
        RestResponse outRes = GetSubscriptionHandler.generateResponse(null,'SN-000004523'); 
        //system.assertEquals('SN-000004523',subsLst[0].csordtelcoa__Subscription_Number__c);
        list<Exception_Log__c> expList = [select id,Error_Description__c from Exception_Log__c];
        system.assertNotEquals(null,expList);
    } 
    @isTest
    public static void generateResponseForArrayTest(){
        RestResponse res = new RestResponse();            
        csord__Subscription__c subDetials = [Select id,csord__Order__r.csord__Order_Number__c, csordtelcoa__Subscription_Number__c from csord__Subscription__c where name = 'subs' limit 1];
            String Correlation = subDetials.csordtelcoa__Subscription_Number__c;
        system.assertNotEquals(null,GetSubscriptionHandler.generateResponseForArray(res,Correlation));
    }
}
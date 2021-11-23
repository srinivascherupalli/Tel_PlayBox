/*
* @Author : Gnana
* @Date : 28 Jan 2020
* @Desc : Test class for ServiceObjectRecordHandler
* @Jira : Edge-132211 
* @Modification History:
* 1. Gnana 19/06/2020 - EDGE-151675 : Modified test data creation method to remove unwanted data creation.
									  Also modified success and negative method.
* 2. Gnana 27/08/2020 - QA2 Test Class Failure Fix
*/
@isTest
public class ServiceObjectRecordHandlerTest {
    
    static blob b = [select body from staticResource where name = 'ServiceJSON'].body;    
    static String serviceDTO = b.toString();
    static String serviceDTO_V2 = '{"Source_System_Id":"Replicator","site":[{"siteName":null,"productList":[{"serviceList":[{"Service_Type":"Voice","service":[{"serviceExtension":[{"Services_To":"0246315099","Services_From":"0246315001","disableCheck":null,"checkValue":null}],"Service_Type":"Voice","Service_Id":"0246315000","IsInflight":null,"In_Flight_Order_Id":"","In_Flight_Legacy_System":"AXIS","In_Flight_Flag":"N","disableCheck":null,"checkValue":true}],"disableCheck":null,"checkValue":null}],"Product_Type":"ISDN-BRA","disableCheck":null,"checkValue":true}],"Error_Description":"","Error_Code":"","ADBOR_Id":"266049834"}],"Error_Description":"","Error_Code":"","Correlation_Id":"SFDC_REP_GETSERVICEa5f369527219745b8c","CIDN":"6892971200"}';
    
    @testSetup static void setup() { 
        EnvironmentVariable__c transitionClone =  new EnvironmentVariable__c();
        transitionClone .name='TransitionClone';
        transitionClone .value__c='3';
        insert transitionClone ;
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        acc.CIDN__c = '1234567890';
        acc.Customer_Status__c='Active';
        insert acc;

        Billing_Account__c billAcc = new Billing_Account__c();
        billAcc.Billing_Account_Number__c = '700000506340';
        billAcc.Account__c = acc.id;
        insert billAcc;
        system.debug('billAcc@@::' + billAcc);

        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        opp.Product_Type__c ='Modular';
        insert opp;
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
        basket.csbb__Synchronised_With_Opportunity__c =true;
        basket.cscfga__Basket_Status__c = 'Valid';
        basket.cscfga__total_contract_value__c = 1000;
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        insert basket;
        List<cscfga__Product_Basket__c> prodBasketList = new List<cscfga__Product_Basket__c>();
        cscfga__Product_Definition__c pd = ProductTestFactory.buildProductDefinition('Test','Test');
        pd.product_Specification__c='DMCAT_ProductSpecification_000935';
        insert pd; 

        List<cscfga__Configuration_Offer__c> listOffers = new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c offernameCMP= new cscfga__Configuration_Offer__c();
        offernameCMP.Offer_Spec_Id__c='DMCAT_Offer_000646';
        offernameCMP.name='Corporate Mobile Plus';
        offernameCMP.cscfga__Active__c=true;
        offernameCMP.cscfga__Description__c='';
        listOffers.add(offernameCMP);
        insert listOffers;
        
        List<Marketable_Offer__c> listOfOffers1= new List<Marketable_Offer__c>();
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        listOfOffers1.add(moMob);
        insert listOfOffers1;
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(pd.id);
        config.cscfga__Product_Definition__c = pd.id;
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description CMP';
        config.cscfga__Contract_Term__c = 36;
        config.Commercial_Config__c='Yes';
        config.Quantity_Product_Configuration__c=1;
        config.cscfga__total_one_off_charge__c=100;
        config.cscfga__total_recurring_charge__c=100;
        config.name='Corporate Mobile Plus-Committed Data';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c =offernameCMP.id;
        config.cscfga__Product_Family__c='Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.configGUID__c = '2b07b38f-4176-f866-3006-643c269b8a39';
        config.Quantity_Product_Configuration__c =1;
        prodConfigList.add(config);
            
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd.id);
        config.cscfga__Product_Definition__c = pd.id;
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description CMP';
        config.cscfga__Contract_Term__c = 36;
        config.Commercial_Config__c='Yes';
        config.Quantity_Product_Configuration__c=1;
        config.cscfga__total_one_off_charge__c=100;
        config.cscfga__total_recurring_charge__c=100;
        config.name='Corporate Mobile Plus-Committed Data';
        config.Type__c = 'New';
        config.Marketable_Offer__c = moMob.id;
        config.Offer_Reference__c =offernameCMP.id;
        config.cscfga__Product_Family__c='Enterprise Mobility';
        config.cscfga__unit_recurring_charge__c = 200;
        config.Quantity_Product_Configuration__c =1;
        prodConfigList.add(config2);   
        insert prodConfigList;
        
        /*
        List<Charge_Line_Item__c> listOfCLI = new List<Charge_Line_Item__c>();
        Charge_Line_Item__c cli=new Charge_Line_Item__c();
        cli.guid__c = '2b07b38f-4176-f866-3006-643c269b8a39';
        cli.commercialProductId__c ='Test';
        cli.solutionId__c = 'solutionid';
        cli.BusinessID__c = 'businessid';
        cli.basketId__c= basket.id;
        listOfCLI.add(cli);
        
        Charge_Line_Item__c cli2=new Charge_Line_Item__c();
        cli2.guid__c = 'TestNegativeScenario';
        cli2.commercialProductId__c ='Test';
        cli2.basketId__c= basket.id;
        listOfCLI.add(cli2);
        insert listOfCLI;
        */
        
        List<cscfga__Product_Configuration__c> updListPC = new List<cscfga__Product_Configuration__c>();
        config.cscfga__Description__c = 'Update CMP Desc1';
        updListPC.add(config);
       	config2.cscfga__Description__c = 'Update CMP Desc2';
        updListPC.add(config2);
        update updListPC;
        
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
        Account acc1 = [Select Id from account limit 1];
        csord__Order__c primaryOrd = ProductTestFactory.buildOrder('PrimaryOrder', acc1.id, 'Created', ordReq.Id);
        insert primaryOrd;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc1.id, 'Created', ordReq.id);
        ord.csord__Primary_Order__c = primaryOrd.Id;
        insert ord;
        
        csord__Subscription__c subscrip = ProductTestFactory.buildSubscription('SubscriptionProd', acc1.id, ord.Id, ordReq.id);
        insert subscrip;
        
        Contact contact = AccountTestFactory.buildContact(acc1, 'Nikhil3');
        insert contact;
        
        cscrm__Address__c address = AccountTestFactory.buildAddress('ADR-00003');
        insert address;
        
        List<csord__Service__c> serList = new List<csord__Service__c>();
        csord__Service__c serv2 = ProductTestFactory.buildService('ServiceProd1', ord.Id, subscrip.Id, ordReq.id);
        serv2.csordtelcoa__Product_Configuration__c = prodConfigList[0].Id;
        serv2.TenancyPrimaryContact__c= contact.Id;
        serv2.Site_Delivery_Contact__c = contact.Id;
        serv2.csord__status__c = 'Pending';
        serv2.Scenario_Type__c = System.Label.Device_Replacement;
        serv2.csordtelcoa__Service_Number__c = '3';
        serv2.Delivery_Address__c = address.Id;
        serList.add(serv2);

        csord__Service__c serv3 = ProductTestFactory.buildService('ServiceProd2', ord.Id, subscrip.Id, ordReq.id);
        serv3.csordtelcoa__Product_Configuration__c = prodConfigList[1].Id;
        serv3.TenancyPrimaryContact__c= contact.Id;
        serv3.Site_Delivery_Contact__c = contact.Id;
        serv3.csord__status__c = 'Pending';
        serv3.Scenario_Type__c = System.Label.Device_Replacement;
        serv3.csordtelcoa__Service_Number__c = '3';
        serv3.Delivery_Address__c = address.Id;
        serList.add(serv3);
        insert serList;
        
         List<Charge_Line_Item__c> listOfCLI = new List<Charge_Line_Item__c>();
        Charge_Line_Item__c cli=new Charge_Line_Item__c();
        cli.guid__c = '2b07b38f-4176-f866-3006-643c269b8a39';
        cli.commercialProductId__c ='Test';
        cli.solutionId__c = 'solutionid';
        cli.BusinessID__c = 'businessid';
        cli.basketId__c= basket.id;
        cli.serviceId__c = serList[0].id;
        listOfCLI.add(cli);
        
        Charge_Line_Item__c cli2=new Charge_Line_Item__c();
        cli2.guid__c = 'TestNegativeScenario';
        cli2.commercialProductId__c ='Test';
        cli2.basketId__c= basket.id;
        listOfCLI.add(cli2);
        insert listOfCLI;
        
    }
    
    @isTest static void getCMPDevicesTestSuccess(){
        List<csord__Service__c> listOfserv2 = [select id from csord__Service__c where name = 'ServiceProd1' limit 1];
        if(listOfserv2.size()>0){
            Charge_Line_Item__c cliRes = [select id,serviceId__c from Charge_Line_Item__c where guid__c = '2b07b38f-4176-f866-3006-643c269b8a39' limit 1];

            System.assertNotEquals(null,cliRes.serviceId__c);
            System.assertNotEquals(null,listOfserv2[0].Id);
        }
        
    }
    
    @isTest static void getCMPDevicesTestNegative(){
        cscfga__Product_Configuration__c config2 = [select id,configGUID__c from cscfga__Product_Configuration__c where configGUID__c = null limit 1];
        List<csord__Service__c> listOfserv3 = [select id from csord__Service__c where name = 'ServiceProd2' limit 1];
        if(listOfserv3.size()>0){
            Charge_Line_Item__c cliRes = [select id,serviceId__c from Charge_Line_Item__c where guid__c = 'TestNegativeScenario' limit 1];
            System.assert(cliRes.serviceId__c  == null);
        }
        
    }
    
}
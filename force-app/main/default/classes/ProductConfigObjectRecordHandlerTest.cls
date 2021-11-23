/*
* @Author : Gnana
* @Date : 28 Jan 2020
* @Desc : Test class for ProductConfigObjectRecordHandler
* @Jira : Edge-132211 
*/
@isTest
public class ProductConfigObjectRecordHandlerTest {
    
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
        //billAcc.name = 'BA-0004772';
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
        cscfga__Product_Definition__c pd1 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd1.product_Specification__c='DMCAT_ProductSpecification_000871';
        insert pd1;
        cscfga__Product_Definition__c pd2 = ProductTestFactory.buildProductDefinition('Test','Test');
        pd2.product_Specification__c='DMCAT_ProductSpecification_000420';
        insert pd2;  
        List<cscfga__Configuration_Offer__c> listOffers = new List<cscfga__Configuration_Offer__c>();
        cscfga__Configuration_Offer__c offernameCMP= new cscfga__Configuration_Offer__c();
        offernameCMP.Offer_Spec_Id__c='DMCAT_Offer_000646';
        offernameCMP.name='Corporate Mobile Plus';
        offernameCMP.cscfga__Active__c=true;
        offernameCMP.cscfga__Description__c='';
        listOffers.add(offernameCMP);

        cscfga__Configuration_Offer__c offernameDOP= new cscfga__Configuration_Offer__c();
        offernameDOP.Offer_Spec_Id__c='DMCAT_Offer_000783';
        offernameDOP.name='Device Outright Purchase';
        offernameDOP.cscfga__Active__c=true;
        offernameDOP.cscfga__Description__c='';
        listOffers.add(offernameDOP);

        cscfga__Configuration_Offer__c offernameTC= new cscfga__Configuration_Offer__c();
        offernameTC.Offer_Spec_Id__c='DMCAT_Offer_000618';
        offernameTC.name='Telstra Collaboration';
        offernameTC.cscfga__Active__c=true;
        offernameTC.cscfga__Description__c='';
        listOffers.add(offernameTC);  

        insert listOffers;
        List<Marketable_Offer__c> listOfOffers1= new List<Marketable_Offer__c>();
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c ='Corporate Mobile Plus' ;
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        listOfOffers1.add(moMob);
        insert listOfOffers1;
        
        //List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
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
        //prodConfigList.add(config);   
        insert config;
        System.debug('configId...'+config.Id);
        
        cscfga__Product_Configuration__c config2 = ProductTestFactory.buildProductConfig(pd.id);
        config.cscfga__Product_Definition__c = pd.id;
        config.cscfga__Product_Basket__c = basket.id;
        config.cscfga__Description__c = 'test Description CMP 2';
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
        insert config2;
        
        Charge_Line_Item__c cli=new Charge_Line_Item__c();
        cli.guid__c = '2b07b38f-4176-f866-3006-643c269b8a39';
        cli.commercialProductId__c ='Test';
        cli.solutionId__c = 'solutionid';
        cli.BusinessID__c = 'businessid';
        cli.basketId__c= basket.id;
        insert cli;
    }
    
    @isTest static void getCMPDevicesTestSuccess(){
        List<cscfga__Product_Configuration__c> listOfConfig = [select id,configGUID__c from cscfga__Product_Configuration__c where configGUID__c != null limit 1];
        if(listOfConfig.size()>0){
            List<ID> ids = new List<ID>();
            ids.add(listOfConfig[0].id);
            ProductConfigObjectRecordHandler.updateChargeLineItemWithPC(ids);
            Charge_Line_Item__c cliRes = [select id,Product_Configuration__c from Charge_Line_Item__c limit 1];
            System.assert(cliRes.Product_Configuration__c  == listOfConfig[0].id);
        }
    }
    
    @isTest static void getCMPDevicesTestNegative(){
        List<cscfga__Product_Configuration__c> listOfConfig = [select id,configGUID__c from cscfga__Product_Configuration__c where configGUID__c = null limit 1];
        if(listOfConfig.size()>0){
            List<ID> ids = new List<ID>();
            ids.add(listOfConfig[0].id);   
            ProductConfigObjectRecordHandler.updateChargeLineItemWithPC(ids);
            Charge_Line_Item__c cliRes = [select id,Product_Configuration__c from Charge_Line_Item__c limit 1];
            System.assert(cliRes.Product_Configuration__c  == null);
        }
    }
    
}
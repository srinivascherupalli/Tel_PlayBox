/****************************************************************************************************************************************************
Main Class : CustomButtonSubmitOrder
Test Class : CustomButtonSubmitOrderTest
=====================================================================================================================================================
Sr.No.    Developer Name      Date            Story                       Description
1.        Ankit Goswami      03/07/2020       EDGE-181979 (New)        cancel button test for Non Commercial journey
=====================================================================================================================================================
******************************************************************************************************************************************************/
@isTest(SeeAllData=FALSE)
private class CustomButtonCancelBasketNCTest{
    @TestSetup
    private static void testSetup(){
        Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
        User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                              lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                              profileid = pf.id,
                              timezonesidkey='Australia/Sydney',
                              username='salesunifieduser@testsales.com',phone='+121231231234');
        insert sales;
        
        Account acc = new Account(Name = 'Burlington');
        insert Acc;
        
        SharedDisplayMessage__c custset= new SharedDisplayMessage__c();
        custset.Name='alreadyCancelledBasket';
        custset.value__c='Basket Already In Cancelled Stage';
        insert custset;
        
        cscfga__Product_Definition__c prodDef= new cscfga__Product_Definition__c();
        prodDef.name='Inactive SIM';
        prodDef.cscfga__Description__c='Inactive SIM';
        insert prodDef;
        
        list<cscfga__Product_Basket__c> prodBasList= new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c prodBas= new cscfga__Product_Basket__c();
        prodBas.csordtelcoa__Account__c=Acc.id;
        prodBas.referencenumber__c='TNC000000000';
        prodBas.name='Test';
        prodBasList.add(prodBas);
        
        cscfga__Product_Basket__c prodBas1= new cscfga__Product_Basket__c();
        prodBas1.name='Test2';
        prodBas1.referencenumber__c='TNC000000001';
        prodBas1.csordtelcoa__Account__c=Acc.id;
        prodBasList.add(prodBas1);
        
        
        cscfga__Product_Basket__c prodBas2= new cscfga__Product_Basket__c();
        prodBas2.name='Test3';
        prodBas.referencenumber__c='TNC000000002';
        prodBas2.csordtelcoa__Account__c=Acc.id;
        prodBasList.add(prodBas2);
        
        cscfga__Product_Basket__c prodBas3= new cscfga__Product_Basket__c();
        prodBas3.csordtelcoa__Account__c=Acc.id;
        prodBas.referencenumber__c='TNC000000003';
        prodBas3.csordtelcoa__Basket_Stage__c='Cancelled';
        prodBasList.add(prodBas3);
        insert prodBasList;
        
        List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
        newConfig.name = 'new config';
        newConfig.Quantity_Product_Configuration__c=20;
        newConfig.cscfga__Product_Definition__c=prodDef.id;
        newConfig.cscfga__Product_Basket__c=prodBas.id;
        prodConfigLst.add(newConfig);
        
        cscfga__Product_Configuration__c config = new cscfga__Product_Configuration__c();
        config.name = 'prod config';
        config.Quantity_Product_Configuration__c=201;
        config.cscfga__Contract_Term__c = 12;
        config.cscfga__Product_Definition__c=prodDef.id;
        config.cscfga__total_contract_value__c = 325;
        config.cscfga__Product_Basket__c=prodBas1.id;
        prodConfigLst.add(config);
        
        
        cscfga__Product_configuration__c configNew = new cscfga__Product_configuration__c();
        configNew.name = 'prod configNew';
        configNew.Quantity_Product_configuration__c=20;
        configNew.cscfga__Contract_Term__c = 12;
        configNew.cscfga__Product_Definition__c=prodDef.id;
        configNew.cscfga__total_contract_value__c = 325;
        configNew.cscfga__Product_Basket__c=prodBas3.id;
        prodconfigLst.add(configNew);
        insert prodConfigLst;
    }
    
    static testmethod void sucessOnAccTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c WHERE referencenumber__c='TNC000000001'];
            CustomButtonCancelBasketNC cutbutton=new  CustomButtonCancelBasketNC();
            string result=cutbutton.performAction(prod[0].id);
            system.assert(result.contains('ok'));
        }
        
    }
    static testmethod void inflightSucessOnAccTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            cscfga__Product_Basket__c prod=[select id,recordtypeid from cscfga__Product_Basket__c WHERE referencenumber__c='TNC000000001' limit 1];
            id recid = [select id from recordtype where developername = 'Inflight_Change' limit 1].id;
            prod.recordtypeid = recid;
            update prod;
            CustomButtonCancelBasketNC cutbutton=new  CustomButtonCancelBasketNC();
            string result=cutbutton.performAction(prod.id);
            system.assert(result.contains('ok'));
        }
        
    }
    
    static testmethod void alreadyCancelTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            list<cscfga__Product_Basket__c> prod=[select id from cscfga__Product_Basket__c WHERE csordtelcoa__Basket_Stage__c='Cancelled'];
            CustomButtonCancelBasketNC cutbutton=new  CustomButtonCancelBasketNC();
            string result=cutbutton.performAction(prod[0].id);
            system.assert(result.contains('error'));
        }
        
    }
    static testmethod void catchErrorTest(){
        User sales = [SELECT id,name FROM User Where username='salesunifieduser@testsales.com'];      
        System.runAs(sales){
            CustomButtonCancelBasketNC cutbutton=new  CustomButtonCancelBasketNC();
            string result=cutbutton.performAction('');
            system.assert(result.contains('error'));
        }
        
    }
    
}
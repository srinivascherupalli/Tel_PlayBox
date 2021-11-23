/*********************************
 * @Author: Sarvanan, Sathyanarayanan, Vasu
 * @Date : Sep 19, 2021
 * @Description : orderEnrichmentUtillTest
 * Last modified Date: 13/10/2021
 *********************************/ 

@isTest(SeeAllData=FALSE)
private class orderEnrichmentUtillTest {
  @TestSetup
  private static void testSetup(){
    Profile pf = [select id from profile where name =:Label.Profile_SalesEnterpriseUnified];
    User sales = new User(alias = 'standt',email='salesuser@testsales.com',emailencodingkey='UTF-8',IsActive =true,
                          lastname='Testing', languagelocalekey='en_US',localesidkey='en_US',
                          profileid = pf.id,
                          timezonesidkey='Australia/Sydney',
                          username='salesunifieduser@testsales.com',phone='+121231231234');
    insert sales;
    
      list<OrderEnrichmentValidation__c>orderValidationList=new list<OrderEnrichmentValidation__c>();
      
      OrderEnrichmentValidation__c orderval= new OrderEnrichmentValidation__c();
      orderval.Name='Test1';
      orderval.Action__c='{"isTrue":[{"attrName":"Not Before CRD","errorMessage":" Not Before CRD can not be a past date","readOnly":true,"showInUI": true,"value":""}],"isFalse":[]}';
      orderval.Condition__c='OR';
      orderval.Is_Active__c=true;
      orderval.Product_Specification_Id__c='DMCAT_ProductSpecification_001196';
      orderval.Offer_Name__c='Adaptive Mobility';
      orderval.Logic__c='[{"id":1,"attName": "@Not Before CRD@","operator": "<","attValue": "@today@"}]';
      orderValidationList.add(orderval);
      
      
      OrderEnrichmentValidation__c orderval1= new OrderEnrichmentValidation__c();
       orderval1.Name='Test2';
      orderval1.Action__c='{"isTrue":[{"attrName":"Not Before CRD","errorMessage":" Not Before CRD can not be a past date","readOnly":true,"showInUI": true,"value":""}],"isFalse":[]}';
      orderval1.Condition__c='OR';
      orderval1.Is_Active__c=true;
      orderval1.Product_Specification_Id__c='DMCAT_ProductSpecification_001196';
      orderval1.Offer_Name__c='Adaptive Mobility';
      orderval1.Logic__c='[{"id":1,"attName": "@Not Before CRD@","operator": "<","attValue": "@today@"}]';
      orderValidationList.add(orderval1);
      
      
      insert orderValidationList;
    
    
    List<Account> AccLst = new List<Account>();
    Account acc = new Account(Name = 'Test Account');
    AccLst.add(acc);
    
    Account acc1 = new Account(Name = 'Burlington');
    AccLst.add(acc1);
    insert AccLst;
    
    List<cscrm__Address__c> AddrLst = new List<cscrm__Address__c>();
    cscrm__Address__c addr = new cscrm__Address__c(Name = 'Test Addr', Address_ID__c = '12345');
    AddrLst.add(addr);
    insert AddrLst;
    
    List<cscrm__Site__c> SiteLst = new List<cscrm__Site__c>();
    cscrm__Site__c site = new cscrm__Site__c(Name = 'Test Site', cscrm__Account__c = acc.Id, cscrm__Installation_Address__c = addr.Id, Legacy__c = TRUE);
    SiteLst.add(site);
    insert SiteLst;
    
    List<Billing_Account__c> billAccLst = new List<Billing_Account__c>();
    Billing_Account__c billingAccount = ProductTestFactory.getBillingAccount();
    billingAccount.Billing_Account_Number__c = '700000449806';
    billAccLst.add(billingAccount);
    Billing_Account__c billingAccount1 = ProductTestFactory.getBillingAccount();
    billingAccount1.Billing_Account_Number__c = '700000504654';
    billingAccount1.Account__c = acc1.Id;
    billAccLst.add(billingAccount1);
    insert billAccLst;
    
    List<cscfga__Product_Definition__c> prodDefLst = new List<cscfga__Product_Definition__c>();
    cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('Test Product', 'Test Plan');
    prodDef.product_Specification__c = 'DMCAT_ProductSpecification_001196';
    prodDefLst.add(prodDef);
    cscfga__Product_Definition__c prodDef1 = ProductTestFactory.buildProductDefinition('Test Product Def', 'Test Plan');
    prodDef1.product_Specification__c = 'DMCAT_ProductSpecification_000537';
    prodDefLst.add(prodDef1);
    insert prodDefLst;
  
    List<cscfga__Product_Basket__c> basketLst = new List<cscfga__Product_Basket__c>();
    cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
    basket.csbb__Account__c = acc1.id;
    basket.csbb__Synchronised_with_Opportunity__c = true;
    basket.csordtelcoa__Synchronised_with_Opportunity__c = true; // Added for nullpointer exception
    basketLst.add(basket);
      
    cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
    basket2.csbb__Account__c = acc1.id;
    basketLst.add(basket2);
    insert basketLst;
      
    csord__Solution__c solution = new csord__Solution__c();
    solution.Name = 'Test Solution';
    solution.csord__Identification__c = 'Solution Management';
    insert solution;
  
    List<cscfga__Product_Configuration__c> prodConfigLst = new List<cscfga__Product_Configuration__c>();
    cscfga__Product_Configuration__c newConfig = new cscfga__Product_Configuration__c();
    newConfig.name = 'new config';
    newConfig.cssdm__solution_association__c = solution.Id;
    newConfig.cscfga__total_contract_value__c = 1234.45;
    newConfig.cscfga__Product_Definition__c=prodDef.id;
    prodConfigLst.add(newConfig);
    insert prodConfigLst;
    
    list<cscfga__Attribute__c> attrLst=new list<cscfga__Attribute__c>();
    
    cscfga__Attribute__c attr=new cscfga__Attribute__c();
    attr.name='SiteDeliveryAddress';
    attr.cscfga__Value__c='';
    attr.cscfga__Product_Configuration__c=newConfig.id;
    attrLst.add(attr);
    
    cscfga__Attribute__c attr1=new cscfga__Attribute__c();
    attr1.name='test1';
    attr1.cscfga__Value__c='test1';
    attr1.cscfga__Product_Configuration__c=newConfig.id;
    attrLst.add(attr1);
    insert attrLst;
    
 
    
  }
   static testmethod void getSolutionsDetailTest() {         
        csord__Solution__c solId =[Select id from csord__Solution__c where name = 'Test Solution'];
       list<cscfga__Product_Configuration__c>prodConfigList=[SELECT id, Name,csordtelcoa__Hierarchy_Level__c,cscfga__Index__c,cscfga__Product_Definition__c,cscfga__Product_Definition__r.Name, cscfga__Product_Definition__r.product_Specification__c,cssdm__solution_association__r.Name FROM cscfga__Product_Configuration__c  where cssdm__solution_association__r.id =: solId.id];

        list<OrderEnrichmentValidation__c>orderValidationList=[select id, Is_Active__c,Action__c,Condition__c,Target__c,Logic__c,Product_Specification_Id__c,Offer_Name__c from OrderEnrichmentValidation__c];
        Test.startTest();
        string returnResult = orderEnrichmentUtill.getSolutionsDetail((string)solId.id);
        Test.stopTest();
        System.assertEquals(true, returnResult != null);
    }
    static testmethod void doLookupContactDetailsTest() {         
        cscfga__Product_Basket__c basketId =[Select id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
        List<Contact> returnResult = orderEnrichmentUtill.doLookupContactDetails((string)basketId.id,'','');
        Test.stopTest();
        System.assertEquals(true, returnResult != null);
    }
    static testmethod void doLookupDeliveryAddressTest() {         
        cscfga__Product_Basket__c basketId =[Select id from cscfga__Product_Basket__c Limit 1];
        Test.startTest();
        List<cscrm__Address__c> returnResult = orderEnrichmentUtill.doLookupDeliveryAddress((string)basketId.id,'');
        Test.stopTest();
        System.assertEquals(true, returnResult != null);
    }
    static testmethod void doInsertOETest() {  
        list<cscfga__Product_Configuration__c>pcList =[Select id from cscfga__Product_Configuration__c Limit 1];    
        List<cscfga__Attribute__c>aatrList =[Select id,cscfga__Value__c,name from cscfga__Attribute__c Limit 1];
        list<OrderEnrichmentValidation__c>validationList=[select id, Is_Active__c,Action__c,Condition__c,Target__c,Logic__c,Product_Specification_Id__c,Offer_Name__c from OrderEnrichmentValidation__c];
        Test.startTest();
        
        orderEnrichmentUtill.attributeWrapper attr=new orderEnrichmentUtill.attributeWrapper(pcList[0].id,aatrList);
        
        
        list<orderEnrichmentUtill.attributeWrapper>attrWrapList=new list<orderEnrichmentUtill.attributeWrapper>();
        orderEnrichmentUtill.attributeWrapper attrWrapper=new orderEnrichmentUtill.attributeWrapper();
        attrWrapper.pcID=pcList[0].id;
        attrWrapper.attributeList=aatrList;
        attrWrapList.add(attrWrapper);
        
        list<orderEnrichmentUtill.ProductConfigurationWrapper>pcWrapList=new  list<orderEnrichmentUtill.ProductConfigurationWrapper>();
        orderEnrichmentUtill.ProductConfigurationWrapper  pcWrap=new orderEnrichmentUtill.ProductConfigurationWrapper(pcList,new list<Order_Enrichment_Schema__mdt>());
        pcWrapList.add(pcWrap);
        
        
        orderEnrichmentUtill.solutionWrapper solWrap=new orderEnrichmentUtill.solutionWrapper('Test','',pcWrapList,validationList);
        
        
        List<Order_Enrichment__c> oeList=new List<Order_Enrichment__c>();
        Order_Enrichment__c oeShema=new Order_Enrichment__c();
        oeShema.Product_Configuration__c=pcList[0].id;
        oeList.add(oeShema);
        
        string returnResult = orderEnrichmentUtill.doInsertOE(oeList,attrWrapList);
        Test.stopTest();
        System.assertEquals(true, returnResult != null);
    }
    static testmethod void getErrorDetailsTest() {         
        csord__Solution__c solId=[Select id from csord__Solution__c Limit 1];
        Test.startTest();
        set<id> returnResult = orderEnrichmentUtill.getErrorDetails((string)solId.id);
        Test.stopTest();
        System.assertEquals(true, returnResult != null);
    }
}
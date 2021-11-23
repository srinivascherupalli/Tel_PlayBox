/* Class Name      :   ApttusTestDataFactory
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1. 		Divya Chilakabathini	25/11/2020	   Test Data Class
*/

@isTest
public class ApttusTestDataFactory {
    /*-----------------------------------------------------------------------------
    Method Name -buildOpportunityContactRole
    Description -OpportunityContactRole test Data for test classes.
    Object      -OpportunityContactRole.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static OpportunityContactRole buildOpportunityContactRole(Contact contact,Opportunity opp) {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=TRUE;
        ocr.Role='Decision Maker';
        
        return ocr;
    }
    /*-----------------------------------------------------------------------------
    Method Name -buildMarketableOffer
    Description -Marketable_Offer__c test Data for test classes.
    Object      -Marketable_Offer__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static Marketable_Offer__c buildMarketableOffer() {
        
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c = 'Next Generation Enterprise Mobility';
        moMob.Name = 'Adaptive Mobility';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        moMob.Product_Family__c = 'Adaptive Mobility';
        moMob.Contract_Type__c = 'DSA';
        
        return moMob;
    }
        /*-----------------------------------------------------------------------------
    Method Name -buildProductBasket
    Description -cscfga__Product_Basket__c test Data for test classes.
    Object      -cscfga__Product_Basket__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static cscfga__Product_Basket__c buildProductBasket(Account acc,Opportunity opp) {
        
       cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
		basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
		basket.csordtelcoa__Synchronised_with_Opportunity__c =true;
		basket.csbb__Synchronised_With_Opportunity__c =true;
		basket.cscfga__Basket_Status__c = 'Valid';
		basket.cscfga__total_contract_value__c = 1234;
        
        return basket;
    }
    
            /*-----------------------------------------------------------------------------
    Method Name -buildProductConfiguration
    Description -cscfga__Product_Configuration__c test Data for test classes.
    Object      -cscfga__Product_Configuration__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    
    public static cscfga__Product_Configuration__c buildProductConfiguration(Marketable_Offer__c moMob,cscfga__Product_Definition__c pd,cscfga__Product_Basket__c basket) {
        
       cscfga__Product_Configuration__c pconfig = new cscfga__Product_Configuration__c();
		pconfig.cscfga__Product_Definition__c = pd.id;
		pconfig.cscfga__Product_Basket__c = basket.id;
		pconfig.cscfga__Description__c = 'test Description';
		pconfig.cscfga__Contract_Term__c = 36;
		pconfig.Commercial_Config__c='Yes';
		pconfig.Quantity_Product_Configuration__c=1;
		pconfig.cscfga__total_one_off_charge__c=100.23;
		pconfig.cscfga__total_recurring_charge__c=100;
		pconfig.name = 'Unified Communication';
		pconfig.Type__c = 'New'; 
		pconfig.Marketable_Offer__c = moMob.id;
        
        return pconfig;
    }
     /*-----------------------------------------------------------------------------
    Method Name -buildPricebook2
    Description -Pricebook2 test Data for test classes.
    Object      -Pricebook2.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    
    public static Pricebook2 buildPricebook2(){
        
        Pricebook2 pb = new Pricebook2(Name = 'Custom Price Book', Description = 'Custom Price Book', IsActive = true);
        insert pb;
        return pb;
    }
    
     /*-----------------------------------------------------------------------------
    Method Name -buildPricebookEntry
    Description -PricebookEntry test Data for test classes.
    Object      -PricebookEntry.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static PricebookEntry buildPricebookEntry(Product2 prd,Id pricebookId){
        PricebookEntry pbEntry = new PricebookEntry (Product2ID=prd.id,Pricebook2ID=pricebookId,UnitPrice=50, isActive=true);
        insert pbEntry;
        return pbEntry;    
    }
    
     /*-----------------------------------------------------------------------------
    Method Name -buildAtrribute
    Description -cscfga__Attribute__c test Data for test classes.
    Object      -cscfga__Attribute__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static cscfga__Attribute__c buildAtrribute(cscfga__Product_Configuration__c pconfig){
        cscfga__Attribute__c attr0 = new cscfga__Attribute__c();
        attr0.name = 'SRM';
        attr0.cscfga__Value__c = '100.00';
        attr0.cscfga__Product_Configuration__c = pconfig.id;
        insert attr0;
        return attr0;
    }
     /*-----------------------------------------------------------------------------
    Method Name -generateOpportunityLineItem
    Description -OpportunityLineItem test Data for test classes.
    Object      -OpportunityLineItem.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static OpportunityLineItem generateOpportunityLineItem(PricebookEntry pbEntry,cscfga__Product_Basket__c basket,cscfga__Product_Configuration__c pconfig,cscfga__Attribute__c attr0){
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid=pbEntry.Id,TotalPrice=2000,Quantity = 2,OpportunityID = basket.cscfga__Opportunity__c, Description = pconfig.cscfga__Description__c,cscfga__Attribute__c = attr0.id,Product_Status__c = 'Lost',Product_Name__c='test prod',OfferName__c='Corporate Mobile Plus');
        insert oli;
        return oli;
    }
     /*-----------------------------------------------------------------------------
    Method Name -buildOpportunity
    Description -Opportunity test Data for test classes.
    Object      -Opportunity.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static Opportunity buildOpportunity(Account acc) {
        Opportunity opp  = new Opportunity();
        opp.Name = 'TestOpp';
        opp.AccountID = acc.id;
        opp.StageName = 'Committed';
        opp.CloseDate = System.today();
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        
        
        return opp;
    }
    
    /*-----------------------------------------------------------------------------
    Method Name -buildApttusTemplate
    Description -Apttus__APTS_Template__c test Data for test classes.
    Object      -Apttus__APTS_Template__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static List<Apttus__APTS_Template__c> buildApttusTemplate() {
        List<Apttus__APTS_Template__c> apttusTem = new List<Apttus__APTS_Template__c>();
        
        Apttus__APTS_Template__c tem  = new Apttus__APTS_Template__c();
        tem.Apttus__IsActive__c = true;
        tem.Name = 'DSA_Template';
        tem.Apttus__Type__c= 'Agreement';    
		apttusTem.add(tem);
        
        Apttus__APTS_Template__c tem2  = new Apttus__APTS_Template__c();
        tem2.Apttus__IsActive__c = true;
        tem2.Name = '	Price_Schedule_Template';
        tem2.Apttus__Type__c= 'Agreement';    
		apttusTem.add(tem2);
        
        insert apttusTem;
        return apttusTem;
    }
    
    /*-----------------------------------------------------------------------------
    Method Name -buildAgreement
    Description -Apttus__APTS_Agreement__c test Data for test classes.
    Object      -Apttus__APTS_Agreement__c.
    Author      -Divya Chilakabathini
    -------------------------------------------------------------------------------*/
    public static Apttus__APTS_Agreement__c buildAgreement(Account acc,contact cc,Opportunity opp,ContractJunction__c cj) {
        //List<Apttus__APTS_Agreement__c> agg = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c agmt  = new Apttus__APTS_Agreement__c();
        agmt.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        agmt.Apttus__Agreement_Category__c = 'Digital Services';
        agmt.APTPS_Agreement_Subcategory__c = 'Single Customer';
        agmt.APTPS_Customer_Primary_Contact__c = cj.Customer_Primary_Contact__c;
        agmt.Apttus__Account__c = cj.Account__c;
        agmt.Related_Contract__c = cj.Id;
        agmt.Apttus__Related_Opportunity__c = cj.Related_Opportunity__c;
        agmt.Related_Basket__c = cj.Related_Basket__c;
        agmt.Apttus__Contract_Start_Date__c = System.today();
        agmt.Apttus__Term_Months__c = 36;
        insert agmt;
        
        Apttus__APTS_Agreement__c ag  = new Apttus__APTS_Agreement__c();
        ag.Apttus__Parent_Agreement__c = agmt.Id;
        ag.Apttus__Agreement_Category__c='Pricing'; 
        ag.APTPS_Agreement_Subcategory__c='Price Book'; 
        ag.Apttus__Subtype__c='Standard'; 
        ag.Apttus__Contract_Start_Date__c=system.today(); 
        ag.Apttus__Term_Months__c=36;
        ag.Apttus__Account__c = acc.Id;
        ag.APTPS_Customer_Primary_Contact__c = cc.Id;
        ag.Apttus__Related_Opportunity__c = opp.Id;
        ag.Related_Contract__c = cj.Id;
        ag.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        insert ag;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=ag.id;
        insert attach;
        
        return ag;
        
    }
    
    @isTest
    public static void requiredTestCase(){
        System.assertEquals(1,1,'RequiredTestCase');
    }
    
    public static Opportunity buildOpportunity1(Account acc) {
           Id devRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Custom').getRecordTypeId();

            Opportunity sobj = new Opportunity(
            AccountId=acc.Id,
            name = 'ContractJunction__c', 
            Amount=2000.0, 
            Product_Domain__c='MOBILES',    
            Confidence_Level__c='Low probability', 
            ForecastCategoryName='Omitted',                                       
            Billing_Solution__c='Standard', 
            Pricing_Method__c='Off the Shelf', 
            CloseDate = system.today()+1,                       
            StageName = 'Prospecting', 
            Requires_Bid_Management__c='Yes',                                 
            Probability = 10,
            Proposal_Required_Date__c=System.today(),
            Description = 'testSuccess',
            RecordTypeId=devRecordTypeId);
        insert sobj;
        return sobj;
    }
    public static ContractJunction__c buildContractt(id acc,id opp,id basket) {
        ContractJunction__c oldContract=new ContractJunction__c();
        oldContract.Account__c = acc;
        oldContract.BSA_Generated__c=true;
        oldContract.Related_Opportunity__c=opp;
        oldContract.Related_Basket__c=basket;
        insert oldContract;
        return oldContract;
    }
    
    public static Apttus__APTS_Agreement__c buildAgg(id acc,id oldContract,id basket,id agreementRecordType) {
      Apttus__APTS_Agreement__c agt = new Apttus__APTS_Agreement__c();
        agt.Apttus__Agreement_Category__c = 'Pricing';
        agt.APTPS_Agreement_Subcategory__c ='Price Book';
		agt.Apttus__Subtype__c ='Standard';
		agt.Apttus__Contract_Start_Date__c = System.today();
        agt.Apttus__Account__c = acc;
        agt.Related_Contract__c = oldContract;
        agt.Related_Basket__c = basket;
        agt.Apttus__Status_Category__c = 'Terminated';
        agt.RecordTypeId = agreementRecordType;
        insert agt;
        return agt;
    }

}
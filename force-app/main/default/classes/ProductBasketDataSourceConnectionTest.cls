/* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 17 Jan 2019
 * Description : Test class for : ProductBasketDataSourceConnection
 * Revision : 
 * Ritika Jaiswal   EDGE - 98246:Adding asserts in test methods
 * Jayesh : 20/02/2020 DPG-1454: Added to retrieve ETC charges for IOT Cancellation Services

 * Aniket/Sunil : 01/05/2020 :EDGE-132608
 * Aniket/Sunil : 01/05/2020 :EDGE-142319
 * Jayesh/Aruna : 20 July 2020 : DPG-1481: Generate Quote for the IoT Shared Data plan
 * Payel/Lalit : 15 Mar 2021 : DPG-4421
 * Sharmila/Payel: Added changes for DIGI-929 and DIGI-930 recommit
 * Natasha Ambre(Radium) : 06 Sept 2021 : Added test method for DIGI 6139 & DIGI 6141
 * Natasha Ambre(Radium) : 14th October 2021 : DIGI-22598 and DIGI-22599 by Natasha Ambre - DMS Cancel
 * Payel: Added changes for DIGI-13857 and DIGI-13858
 * *****************************************************************************/
@isTest
public class ProductBasketDataSourceConnectionTest {
    public static String prdBasketId;
     /*****************************************************************************
 * Author : Manoj Kumar
 * Date : 17 Jan 2019
 * Description : Method to create product basket test data.
 * Revision :
 * 
 * *****************************************************************************/
    public static String generateProdBasket() {
          //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c='Active';
        insert acc;  
        System.assert(acc.id != null);
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0412345678',
            Email = 'test@tele2.com'   
        );
        Insert contact;
        System.assert(contact.id != null);
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        opp.AccountId = acc.id;
        insert opp;
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
        insert lstbasket;
        System.assert(lstbasket.Size()>0);
      ContractJunction__c Contractrecord = new ContractJunction__c();
        Contractrecord.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contractrecord.Related_Basket__c = lstbasket[0].id;
        Contractrecord.CongaStatus__c = 'NotStarted';
        Contractrecord.Related_Opportunity__c = opp.Id;
        Contractrecord.Contract_Activated_Date__c = System.today();
        Contractrecord.Contract_Term_Months__c = 36;
        Contractrecord.Name = 'CN' ;
        Contractrecord.GPTVersion__c=1.2;
        Contractrecord.OFTVersion__c=1.4;
        Contractrecord.BSAVersion__c=1.3;
        Contractrecord.Status__c = 'In Effect';
        Contractrecord.Account__c = acc.id;
        insert Contractrecord; 
      return lstbasket[0].id;
    }
    /*****************************************************************************
 * Author : Manoj Kumar
 * Date : 17 Jan 2019
 * Description : Method to cover "sync" &&"getRows" methods without subfilter flow
 * Revision :
 * 
 * *****************************************************************************/
   @isTest 
   public static void TestGetRows() {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        prdBasketId = generateProdBasket(); 
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = prdBasketId;
        filter.columnValue = prdBasketId;
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        prdBasketCtrl.sync();
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
     /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 21 Jan 2019
 * Description : Method to cover "getRows" method with subfilter flow
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryType1Flow() {
        prdBasketId = generateProdBasket();   
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        System.assert(offername.id != null);
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPC = new cscfga__Product_Configuration__c();
       // MACPC.cscfga__Product_Basket__c = prdBasketId;
        MACPC.name='IP Site';
        MACPC.Type__c='Modify';
        MACPC.cscfga__originating_offer__c=offername.id;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='New';
        prdConfigList.add(MACPC);
        prdConfigList.add(MACPCnew);
        cscfga__Product_Configuration__c MACPCcncl = new cscfga__Product_Configuration__c();
        MACPCcncl.cscfga__Product_Basket__c =prdBasketId;
        MACPCcncl.cscfga__originating_offer__c=offername.id;
        MACPCcncl.csordtelcoa__Replaced_Product_Configuration__c=MACPCnew.id;
        MACPCcncl.name='IP Site';
        MACPCcncl.Type__c='Cancel';
        insert MACPCcncl;
        insert prdConfigList;
        System.assert(prdConfigList.Size() > 0);
        /***EDGE-80772 : commented for Solution Console retrofit
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = MACPCcncl.id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;*/
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf('encodedContentsString');
        attachment.Name = String.valueOf('Transition11');
        attachment.ParentId = MACPCcncl.id; 
        insert attachment;
        /***EDGE-80772 : commented for Solution Console retrofit
        csbb__Product_Configuration_Request__c prrequest1= new   csbb__Product_Configuration_Request__c();
        prrequest1.csbb__Product_Configuration__c = prdConfigList[1].id;
        prrequest1.csbb__Product_Basket__c=prdBasketId;
        insert prrequest1;*/
        /***EDGE-80772 : commented for Solution Console retrofit
        csbb__Product_Configuration_Request__c prrequest3= new   csbb__Product_Configuration_Request__c();
        prrequest3.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest3.csbb__Product_Basket__c=prdBasketId;
        insert prrequest3;*/
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        //   filter.columnName = 'Product_Basket';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = '2';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
    /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 21 Jan 2019
 * Description : Method to cover "getRows" method with subfilter flow 2
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryType2Flow() {
        prdBasketId = generateProdBasket();   
          cscfga__Product_Basket__c basketRec = [Select id, csbb__Account__c, cscfga__Opportunity__c, 
                                                 Name from cscfga__Product_Basket__c where id =:prdBasketId];
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = basketRec.csbb__Account__c;
        basket.cscfga__Opportunity__c = basketRec.cscfga__Opportunity__c;
        basket.Name = 'basket2';
        insert basket;
        System.assert(basket.id != null);
        ContractJunction__c Contractrecord = new ContractJunction__c();
        Contractrecord.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contractrecord.Related_Basket__c = basket.id;
        Contractrecord.CongaStatus__c = 'NotStarted';
        Contractrecord.Related_Opportunity__c = basketRec.cscfga__Opportunity__c;
        Contractrecord.Contract_Activated_Date__c = System.today();
        Contractrecord.Contract_Term_Months__c = 36;
        Contractrecord.Name = 'CN' ;
        Contractrecord.GPTVersion__c=1.2;
        Contractrecord.OFTVersion__c=1.4;
        Contractrecord.BSAVersion__c=1.3;
        Contractrecord.BSA_Generated__c = true;
        Contractrecord.Status__c = 'Initiated';
        Contractrecord.Account__c = basketRec.csbb__Account__c;
        insert Contractrecord; 
        System.assert(Contractrecord.id != null);
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.Offer_Reference__c=offername.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Product_Definition__c = pd.Id;// EDGE-165834 - Added PD association
        insert MACPCnew;
        cscfga__Product_Configuration__c MACPCcncl = new cscfga__Product_Configuration__c();
        MACPCcncl.cscfga__Product_Basket__c =prdBasketId;
        MACPCcncl.name='IP Site';
        MACPCcncl.Type__c='Cancel';
        MACPCcncl.Offer_Reference__c=offername.id;
        MACPCcncl.cscfga__Product_Family__c = 'Mobility';
        MACPCcncl.Commercial_Config__c = 'Yes';
        MACPCcncl.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCcncl.cscfga__total_recurring_charge__c=1.0;
        MACPCcncl.cscfga__Parent_Configuration__c = MACPCnew.id;
        MACPCcncl.cscfga__Product_Definition__c = pd.Id;//// EDGE-165834 - Added PD association
        prdConfigList.add(MACPCcncl);
        insert prdConfigList;
         
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = MACPCnew.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        Attachment attachment = new Attachment();
        attachment.Body = Blob.valueOf('encodedContentsString');
        attachment.Name = String.valueOf('Transition11');
        attachment.ParentId = prrequest.id; 
        insert attachment;
        System.assert(attachment.id != null);
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'SummaryForChangesToExisting';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
    @isTest 
    public static void Test_QueryType3Flow() {
        prdBasketId = generateProdBasket();   
          cscfga__Product_Basket__c basketRec = [Select id, csbb__Account__c, cscfga__Opportunity__c, 
                                                 Name from cscfga__Product_Basket__c where id =:prdBasketId];
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = basketRec.csbb__Account__c;
        basket.cscfga__Opportunity__c = basketRec.cscfga__Opportunity__c;
        basket.Name = 'basket2';
        insert basket;
        System.assert(basket.id != null);
        ContractJunction__c Contractrecord = new ContractJunction__c();
        Contractrecord.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        Contractrecord.Related_Basket__c = basket.id;
        Contractrecord.CongaStatus__c = 'NotStarted';
        Contractrecord.Related_Opportunity__c = basketRec.cscfga__Opportunity__c;
        Contractrecord.Contract_Activated_Date__c = System.today();
        Contractrecord.Contract_Term_Months__c = 36;
        Contractrecord.Name = 'CN' ;
        Contractrecord.GPTVersion__c=1.2;
        Contractrecord.OFTVersion__c=1.4;
        Contractrecord.BSAVersion__c=1.3;
        Contractrecord.BSA_Generated__c = true;
        Contractrecord.Status__c = 'Initiated';
        Contractrecord.Account__c = basketRec.csbb__Account__c;
        insert Contractrecord; 
        System.assert(Contractrecord.id != null);
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='CWP Mobility';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
    csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
       // MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        MACPCParent.Offer_Reference__c=offername.id;
        MACPCParent.cscfga__Product_Definition__c = pd.Id;// EDGE-165834 - Added PD association
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCcncl = new cscfga__Product_Configuration__c();
        MACPCcncl.cscfga__Product_Basket__c =prdBasketId;
        MACPCcncl.name='IP Site';
        MACPCcncl.Type__c='Cancel';
        MACPCcncl.cscfga__Product_Family__c = 'Mobility';
        MACPCcncl.Commercial_Config__c = 'Yes';
        MACPCcncl.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCcncl.cscfga__total_recurring_charge__c=1.0;
        //MACPCcncl.cscfga__Parent_Configuration__c = MACPCParent.id;
        MACPCcncl.Offer_Reference__c=offername.id;
        MACPCcncl.cscfga__Product_Definition__c = pd.Id;// EDGE-165834 - Added PD association
        prdConfigList.add(MACPCcncl);
        insert prdConfigList;
           
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = MACPCcncl.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'SummaryForChangesToExisting';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
        /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 21 Jan 2019
 * Description : Method to cover "getRows" method with subfilter Cancel flow
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryTypeCancelFlow() {
         cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        id prdBasketIdcancel = generateProdBasket();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs.Right_to_Bill_Date__c=Date.today();
        insert subs;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
        MACPCParent.cscfga__Product_Basket__c =prdBasketIdcancel;
        MACPCParent.cscfga__originating_offer__c=offername.id;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketIdcancel;
        MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
        System.assert(prdConfigList.Size()>0);        
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketIdcancel;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        //String prdBasketId = generateProdBasket();
        filter.columnName = 'ExternalId';
        //   filter.columnName = 'Product_Basket';
        filter.columnValue = prdBasketIdcancel;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketIdcancel;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'Cancel';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
     /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 21 Jan 2019
 * Description : Method to cover "getRows" method with subfilter flow : offer in basket
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryTypeOfferInBasketFlow() {
        String prdBasketId = generateProdBasket();
       // String prdBasketId2 = generateProdBasket();
        cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
        //MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.cscfga__originating_offer__c=offername.id;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.Commercial_Config__c = 'Yes';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        //   filter.columnName = 'Product_Basket';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'OffersInBasket';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
     /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 21 Jan 2019
 * Description : Method to cover "getRows" method with subfilter flow : Offer in Basket
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryTypeOfferInBasketFlow2() {
        String prdBasketId = generateProdBasket();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
       // MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.Commercial_Config__c = 'Yes';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'OffersInBasket';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assert(result!=null);
    } 
      /* ****************************************************************************
 * Author : Manoj Kumar
 * Date : 04 March 2019
 * Description : Method to cover "getRows" method with subfilter flow : MobilityProducts
 * Revision :
 * 
 * *****************************************************************************/
     @isTest 
    public static void TestMobilityProd() {
         String prdBasketId = generateProdBasket();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
       // MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.cscfga__Product_Family__c = 'Mobility';
        MACPCnew.Commercial_Config__c = 'Yes';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        //MACPCnew.cscfga__One_Off_Charge__c = '100';
        //MACPCnew.cscfga__Recurring_Charge__c= '100';
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
           cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = MACPCnew.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'MobilityProducts';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
    @isTest 
   public static void TestGetRows2() {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        prdBasketId = generateProdBasket(); 
        DataSource.Filter filter = new DataSource.Filter();
        filter.columnName = 'Product_Basket';
        filter.columnValue = prdBasketId;
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        prdBasketCtrl.sync();
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();
    System.assert(result!=null);    
    } 
     //EDGE-88163 - Start
            /* ****************************************************************************
 * Author : Yash Rathod
 * Date : 14 Jun 2019
 * Description : Method to cover "getRows" method with subfilter ProductType flow
 * Revision :
 * 
 * *****************************************************************************/
    @isTest 
    public static void Test_QueryTypeProductTypeFlow() {
         cscfga__Configuration_Offer__c offername= new cscfga__Configuration_Offer__c();
        offername.name='Connected Workplace Package';
        offername.cscfga__Active__c=true;
        offername.cscfga__Description__c='Connected Workplace Package';
        insert offername;
        id prdBasketIdcancel = generateProdBasket();
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs.Right_to_Bill_Date__c=Date.today();
        insert subs;
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
        MACPCParent.cscfga__Product_Basket__c =prdBasketIdcancel;
        MACPCParent.cscfga__originating_offer__c=offername.id;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketIdcancel;
        MACPCnew.cscfga__originating_offer__c=offername.id;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
        System.assert(prdConfigList.Size()>0);        
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketIdcancel;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        //String prdBasketId = generateProdBasket();
        filter.columnName = 'ExternalId';
        //   filter.columnName = 'Product_Basket';
        filter.columnValue = prdBasketIdcancel;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketIdcancel;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'ProductType';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
    System.assert(result!=null);   
    }
     //EDGE-88163 - End
 /* ****************************************************************************
 * Author : Purushottam Sahu
 * Date : 24 Sep 2019
 * Description : Method to cover "getRows" method with subfilter flow : MDMProfServiceDetails
 * Revision :
 * 
 * *****************************************************************************/
     @isTest 
    public static void testMDMProfServiceDetails() {
         String prdBasketId = generateProdBasket();
         Marketable_Offer__c moPS = new Marketable_Offer__c(OfferDefinationName__c ='Professional Services',Name = 'Professional Services-MDM Config',Offer_ID__c = 'DMCAT_ProductOffering_000716');
        insert moPS;
        cscfga__Product_Configuration__c pdConfig = TestDataFactory.generateProductConfiguration();
        pdConfig.name = 'Professional Services-MDM Config';
        pdConfig.Type__c = 'New'; 
        pdConfig.Marketable_Offer__c = moPS.id;
        pdConfig.cscfga__Product_Family__c='Professional Services-MDM Config';
        update pdConfig;
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pdConfig.cscfga__Product_Definition__c,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pdConfig.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'MDMProfServiceDetails';
        subfilterList.add(subFilterRec1); 
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Professional Services-MDM Config';
        subfilterList.add(subFilterRec2); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
//EDGE-99894 - Start
 /* ****************************************************************************
 * Author : Aman Soni
 * Date : 9 Oct 2019
 * Description : Method to cover "getRows" method with subfilter flow : DOPServiceDetails
 * Revision :
 * 
 * *****************************************************************************/
     @isTest 
    public static void testDOPServiceDetails() {
         String prdBasketId = generateProdBasket();
         Marketable_Offer__c moPS = new Marketable_Offer__c(OfferDefinationName__c ='Device Outright Purchase Solution',Name = 'Device Outright Purchase',Offer_ID__c = 'DMCAT_Offer_000783');
        insert moPS;
        cscfga__Product_Configuration__c pdConfig = TestDataFactory.generateProductConfiguration();
        pdConfig.name = 'Device Outright Purchase Solution';
        pdConfig.Type__c = 'New'; 
        pdConfig.Marketable_Offer__c = moPS.id;
        pdConfig.cscfga__Product_Family__c='Device Outright Purchase Solution';
        update pdConfig;
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pdConfig.cscfga__Product_Definition__c,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = pdConfig.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'DOPServiceDetails';
        subfilterList.add(subFilterRec1); 
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Device Outright Purchase';
        subfilterList.add(subFilterRec2); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
//EDGE-99894 - End
    /* ****************************************************************************
 * Author : RaviTeja
 * Date : 07 Nov 2019
 * Description : Method to cover "getRows" method with subfilter flow : getMobiltyManagedServceDetails
 * Revision :
 * 
 * *****************************************************************************/
     @isTest 
    public static void testMobiltyManagedServceDetails() {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'Mobility Platform Management';
        subfilterList.add(subFilterRec1); 
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Test';
        subfilterList.add(subFilterRec2); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
    /* ****************************************************************************
 * Author : RaviTeja
 * Date : 07 Nov 2019
 * Description : Method to cover "getRows" method with subfilter flow : getTenancyDetails
 * Revision :
 * 
 * *****************************************************************************/
     @isTest 
    public static void testMobiltyTenancyDetails() {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'TenancyDetails';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
/* ****************************************************************************
 * Author : Jayesh
 * Date : 25 Feb 2020
 * Description : Method to cover "getRows" method with subfilter flow for IOTServicesOC 
 * *****************************************************************************/
     @isTest 
    public static void testIOTServicesOC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'IOTServicesOC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('IOTServicesOC',subfilterList.get(0).columnValue);
    }
 /* ****************************************************************************
 * Author : Jayesh/Aruna
 * Date : 20 July 2020
 * Description : Method to cover "getRows" method with subfilter flow for IoTSharedDataPlan
 * Jira Cloud : DPG-1481
 * *****************************************************************************/
     @isTest 
    public static void testIoTSharedDataPlan()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'IoTSharedDataPlan';
        subfilterList.add(subFilterRec);
        filter.subfilters = subfilterList;
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
        System.assertEquals('IoTSharedDataPlan',subfilterList.get(0).columnValue);
    }
/* ****************************************************************************
 * Author : Jayesh
 * Date : 25 Feb 2020
 * Description : Method to cover "getRows" method with subfilter flow for IoTCancelServices 
 * Jira Cloud : DPG-1454 & DPG-1033
 * *****************************************************************************/
   @isTest 
    public static void testIoTCancelServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'IoTCancelServices';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('IoTCancelServices',subfilterList.get(0).columnValue);
    }

    //EDGE-132608 Start
    @isTest 
    public static void testngUCRateModel()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'ngUCRateModel';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    @isTest 
    public static void testNGUCRateCardDetails()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGUCRateCardDetails';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //EDGE-132608 End
    //EDGE-142319 Start
    @isTest 
    public static void testngUCRateModelMac()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'ngUCRateModelMac';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //EDGE-142319 End
    //EDGE-148728 Start
    @isTest 
    public static void testNGEMDetails()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceOC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //EDGE-148728 End
    //EDGE-165326 Start

    //EDGE-155059 & EDGE-162542

    @isTest 
    public static void testNGEMPlansDetails()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMPlanWLS';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //EDGE-165326 End
     @isTest 
    public static void TestBSMobTrans() { //EDGE-173365
         String prdBasketId = generateProdBasket();
                //EDGE-173365 --- Start
                List<Legacy_Service__c> lstLegSer = new List<Legacy_Service__c>();
                Legacy_Service__c legSrvc = new Legacy_Service__c();
                legSrvc.Product_Basket__c = prdBasketId;
                legSrvc.Product_Type__c = 'Enterprise Mobility';
                legSrvc.Select__c = TRUE;
                legSrvc.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc);
                Legacy_Service__c legSrvc1 = new Legacy_Service__c();
                legSrvc1.Product_Basket__c = prdBasketId;
                legSrvc1.Product_Type__c = 'Enterprise Mobility';
                legSrvc1.Select__c = TRUE;
                legSrvc1.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc1);
                insert lstLegSer;
          Service_Add_On__c ser = new Service_Add_On__c();
           list<Service_Add_On__c> serList = new list<Service_Add_On__c>();
        ser.Device_Description__c = 'IPhone 6';
            ser.Monthly_Amount__c = 100.00;
            ser.Residual_Remaining_Term__c =3;
        ser.Legacy_Service__c = lstLegSer[0].Id;
        serList.add(ser);
        Service_Add_On__c ser1 = new Service_Add_On__c();
        ser1.Device_Description__c = 'IPhone 6';
            ser1.Monthly_Amount__c = 10.00;
            ser1.Residual_Remaining_Term__c =2;
        ser1.Legacy_Service__c =  lstLegSer[1].Id;
          serList.add(ser1);
          insert serList;
          //EDGE-173365 --- End       
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
       // MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.cscfga__Product_Family__c = 'Mobility';
        MACPCnew.Commercial_Config__c = 'Yes';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        //MACPCnew.cscfga__One_Off_Charge__c = '100';
        //MACPCnew.cscfga__Recurring_Charge__c= '100';
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
           cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = MACPCnew.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'BSMobilityTransaction';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }
     @isTest 
    public static void TestBSMobTransHnD() { //EDGE-175105
         String prdBasketId = generateProdBasket();
                //EDGE-173365 --- Start
                List<Legacy_Service__c> lstLegSer = new List<Legacy_Service__c>();
                Legacy_Service__c legSrvc = new Legacy_Service__c();
                legSrvc.Product_Basket__c = prdBasketId;
                legSrvc.Product_Type__c = 'Enterprise Mobility';
                legSrvc.Select__c = TRUE;
                legSrvc.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc);
                Legacy_Service__c legSrvc1 = new Legacy_Service__c();
                legSrvc1.Product_Basket__c = prdBasketId;
                legSrvc1.Product_Type__c = 'Enterprise Mobility';
                legSrvc1.Select__c = TRUE;
                legSrvc1.Plan_Name__c = 'LegacyAMPlan';
              lstLegSer.add(legSrvc1);
                insert lstLegSer;
          Service_Add_On__c ser = new Service_Add_On__c();
           list<Service_Add_On__c> serList = new list<Service_Add_On__c>();
        ser.Device_Description__c = 'IPhone 6';
            ser.Monthly_Amount__c = 100.00;
            ser.Residual_Remaining_Term__c =3;
        ser.Legacy_Service__c = lstLegSer[0].Id;
        serList.add(ser);
        Service_Add_On__c ser1 = new Service_Add_On__c();
        ser1.Device_Description__c = 'IPhone 6';
            ser1.Monthly_Amount__c = 10.00;
            ser1.Residual_Remaining_Term__c =2;
        ser1.Legacy_Service__c =  lstLegSer[1].Id;
          serList.add(ser1);
          insert serList;
          //EDGE-173365 --- End       
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Status__c = 'Active';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        insert subs;
        System.assert(subs.id != null);
        List<cscfga__Product_Configuration__c> prdConfigList = new List<cscfga__Product_Configuration__c>();
        cscfga__Product_Configuration__c MACPCParent = new cscfga__Product_Configuration__c();
       // MACPCParent.cscfga__Product_Basket__c =prdBasketId;
        MACPCParent.name='IP Site';
        MACPCParent.Type__c='Cancel';
        MACPCParent.cscfga__total_recurring_charge__c=1.0;
        insert MACPCParent;
        cscfga__Product_Configuration__c MACPCnew = new cscfga__Product_Configuration__c();
        MACPCnew.cscfga__Product_Basket__c =prdBasketId;
        MACPCnew.name='IP Site';
        MACPCnew.Type__c='Cancel';
        MACPCnew.cscfga__Product_Family__c = 'Mobility';
        MACPCnew.Commercial_Config__c = 'Yes';
        MACPCnew.csordtelcoa__Replaced_Subscription__c =subs.id;
        MACPCnew.cscfga__total_recurring_charge__c=1.0;
        MACPCnew.cscfga__Parent_Configuration__c = MACPCParent.id;
        //MACPCnew.cscfga__One_Off_Charge__c = '100';
        //MACPCnew.cscfga__Recurring_Charge__c= '100';
        prdConfigList.add(MACPCnew);
        insert prdConfigList;
           cscfga__Product_Definition__c pd = new cscfga__Product_Definition__c(
            Name = 'IP Site',
            cscfga__Description__c = 'PD1 Desc',
            Snapshot_Object__c ='CS_Basket_Snapshot_Transactional__c',
            product_Specification__c = Label.MobilitySpecCode
        );
        insert pd;
        List<cscfga__Attribute_Definition__c> lstAttributeDef = new List<cscfga__Attribute_Definition__c>();
            cscfga__Attribute_Definition__c ad = new cscfga__Attribute_Definition__c(
                cscfga__Product_Definition__c = pd.Id,
                Name = 'AD1',
                Snapshot_Attribute_Value_Field__c = 'Product_Module_Name ',
                Snapshot_Attribute_Fields__c = 'Plan Device MessageBank'
            );
            lstAttributeDef.add(ad);
            insert lstAttributeDef;
         List<cscfga__Attribute__c> lstAttribute = new List<cscfga__Attribute__c>();
            cscfga__Attribute__c att = new cscfga__Attribute__c(
                cscfga__Product_Configuration__c = MACPCnew.Id,
                Name = 'Test',
                cscfga__Value__c = '10',
                cscfga__is_active__c = true,
                cscfga__Attribute_Definition__c = lstAttributeDef[0].Id
            );
            lstAttribute.add(att);
            insert lstAttribute;
        csbb__Product_Configuration_Request__c prrequest= new   csbb__Product_Configuration_Request__c();
        prrequest.csbb__Product_Configuration__c = prdConfigList[0].id;
        prrequest.csbb__Product_Basket__c=prdBasketId;
        insert prrequest;
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = prdBasketId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'MobilityTransitionHardwareAndDevice';
        subfilterList.add(subFilterRec1); 
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        Test.stopTest();    
       System.assert(result!=null);
    }

    //EDGE-180110 & EDGE-177567 Start 
    @isTest 
    public static void testDealQuoteCondition() {
        ProductBasketDataSourceConnection dprOfferCntrl = new ProductBasketDataSourceConnection();
        String dprId = generateDPROffer();

        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';

        filter.columnValue = dprId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        DataSource.Filter subFilterRec4 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = dprId;
        subfilterList.add(subFilterRec);
        subFilterRec1.columnName = 'Query_Type';
        subFilterRec1.columnValue = 'DPR_DealQuotePlanHH';
        subfilterList.add(subFilterRec1); 
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Test';
        subfilterList.add(subFilterRec2);
        //EDGE-177567 Start
        subFilterRec3.columnName = 'Query_Type';
        subFilterRec3.columnValue = 'DPR_DealQuotePlanWLS';
        subfilterList.add(subFilterRec3);
        subFilterRec4.columnName = 'Query_Type';
        subFilterRec4.columnValue = 'DPR_DealQuotePlanMBB';
        subfilterList.add(subFilterRec4);
        //EDGE-177567 End 

        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  

        DataSource.TableResult result = dprOfferCntrl.query(context);
        Test.stopTest();    
        System.assertEquals('DPR_DealQuotePlanHH',subfilterList.get(1).columnValue);
        //EDGE-177567 Start
        System.assertEquals('DPR_DealQuotePlanWLS',subfilterList.get(3).columnValue);
        System.assertEquals('DPR_DealQuotePlanMBB',subfilterList.get(4).columnValue);
        //EDGE-177567 End
    }
    @isTest 
    public static void testTCDealQuoteCondition() {
        ProductBasketDataSourceConnection dprOfferCntrl = new ProductBasketDataSourceConnection();
        String dprId = generateDPROffer();

        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';

        filter.columnValue = dprId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        DataSource.Filter subFilterRec4 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = dprId;
        subfilterList.add(subFilterRec);
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Test';
        subfilterList.add(subFilterRec2);
        subFilterRec4.columnName = 'Query_Type';
        subFilterRec4.columnValue = 'DPR_DealQuoteTC';
        subfilterList.add(subFilterRec4);

        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  

        DataSource.TableResult result = dprOfferCntrl.query(context);
        Test.stopTest();    
        System.assertEquals('DPR_DealQuoteTC',subfilterList.get(2).columnValue);
    }
    @isTest 
    public static void testTCRateCard() {
        ProductBasketDataSourceConnection dprOfferCntrl = new ProductBasketDataSourceConnection();
        String dprId = generateDPROffer();

        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';

        filter.columnValue = dprId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        DataSource.Filter subFilterRec1 = new DataSource.Filter();
        DataSource.Filter subFilterRec2 = new DataSource.Filter();
        DataSource.Filter subFilterRec3 = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type1';
        subFilterRec.columnValue = dprId; 
        subfilterList.add(subFilterRec);
        subFilterRec2.columnName = 'Offer_Name';
        subFilterRec2.columnValue = 'Test';
        subfilterList.add(subFilterRec2);
        subFilterRec3.columnName = 'Query_Type';
        subFilterRec3.columnValue = 'TCRateCard';
        subfilterList.add(subFilterRec3);

        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  

        DataSource.TableResult result = dprOfferCntrl.query(context);
        Test.stopTest();    
        System.assertEquals('TCRateCard',subfilterList.get(2).columnValue);
    }
    public static String generateDPROffer() {
        //Account 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;
        //Opportunity 
         Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        List<DPR_Offer__c> dList = new List<DPR_Offer__c>();
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = dpReq.Id ; 
        dOffer.Name = 'Test';
        dList.add(dOffer);
        insert dList ; 
        System.assert(dList[0].Name == 'Test');
        return dList[0].id;
    }
    //EDGE-180110 & EDGE-177567 End
     @isTest 
    //DPG-3509 -start
    public static void testAMDeviceAccessOC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();

        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';

        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceOC_AMaccessoryOC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);

        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  

        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    @isTest
    public static void testAMDeviceAccessRC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceRC_AMaccessoryRC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //DPG-3508 End
 //EDGE-171311 Start
    @isTest
    public static void testAMDeviceAccessOCIC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceOCIC_AMaccessoryOC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    @isTest
    public static void testAMDeviceAccessRCIC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceRCIC_AMaccessoryRC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    //EDGE-171311 End
    /* ****************************************************************************
 * Author : Payel
 * Date : 15 Mar 2021
 * Description :  Method to cover "getRows" method with subfilter flow for getSDWANServicesSecureEdge
 * *****************************************************************************/
   @isTest 
    public static void testSECUREEDGEServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'SECUREEDGEServices';
        subfilterList.add(subFilterRec);
        //System.debug(' subfilter List-->  '+ subfilterList);
        //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('SECUREEDGEServices',subfilterList.get(0).columnValue);
        //System.assert(result!=null);
        system.assert(result.success==true);
    }
    
    // Method to cover "getRows" method with subfilter flow for getSDWANServices 
    @isTest 
    public static void testSDWANServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        //DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'SDWANServices';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('SDWANServices',subfilterList.get(0).columnValue);
        //System.assert(result!=null);
        //system.assert(result.success==true);
    } 
    /* ****************************************************************************
 * Author : Natasha Ambre
 * Date : 06 Sept 2021
 * Description :  Method to cover "getRows" method with subfilter flow for getDMSServices
 * *****************************************************************************/
    // Method to cover "getRows" method with subfilter flow for getDMSServices 
    @isTest 
    public static void testDMSServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        //DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'DMSServices';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('DMSServices',subfilterList.get(0).columnValue);
        //System.assert(result!=null);
        //system.assert(result.success==true);
    } 
    /* ****************************************************************************
 * Author : Natasha Ambre
 * Date : 06 Sept 2021
 * Description :  Method to cover "getRows" method with subfilter flow for getDMSCancelServices
 * *****************************************************************************/
    // Method to cover "getRows" method with subfilter flow for getDMSCancelServices  
    @isTest 
    public static void testDMSCancelServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        //DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'DMSCancelServices';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('DMSCancelServices',subfilterList.get(0).columnValue);
        //System.assert(result!=null);
        //system.assert(result.success==true);
    }
        //DIGI-929/DIGI-930 Method to cover "getRows" method with subfilter flow for getSDWANCancelServices recommit
    @isTest 
    public static void testSDWANCancelServices()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        //DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'SDWANCancel';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();    
        System.assertEquals('SDWANCancel',subfilterList.get(0).columnValue);
        //System.assert(result!=null);
        //system.assert(result.success==true);
    }

    /* ****************************************************************************
 * Author : Payel Ganguly
 * Date : 10 Nov 2021
 * Description :  Method to cover "getRows" method with subfilter flow for getSDWANServicesSecureEdgeModify DIGI-13857/DIGI-13858
 * *****************************************************************************/
   @isTest 
   public static void testgetSDWANServicesSecureEdgeModify()
   {
       ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
       DataSource.QueryContext context = new DataSource.QueryContext();
       DataSource.Filter filter = new DataSource.Filter();
       DataSource.Filter filter1 = new DataSource.Filter();
       filter.columnName = 'ExternalId';
       filter.columnValue = prdBasketId;
       List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
       DataSource.Filter subFilterRec = new DataSource.Filter();
       subFilterRec.columnName = 'Query_Type';
       subFilterRec.columnValue = 'SECUREEDGEModify';
       subfilterList.add(subFilterRec);
       //System.debug(' subfilter List-->  '+ subfilterList);
       //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
       filter.subfilters = subfilterList;
       System.debug('Test filter'+filter);
       DataSource.TableSelection tableSelection = new DataSource.TableSelection();
       tableSelection.tableSelected = 'BasketSnapshot';
       tableSelection.filter = filter;
       context.TableSelection = tableSelection;
       //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
       Test.startTest();  
       DataSource.TableResult result = prdBasketCtrl.query(context);
       System.debug(' result--> '+result);
       Test.stopTest();    
       System.assertEquals('SECUREEDGEModify',subfilterList.get(0).columnValue);
       //System.assert(result!=null);
       system.assert(result.success==true);
   }
   
   /* ****************************************************************************
* Author : Payel Ganguly
* Date : 10 Nov 2021
* Description :  Method to cover "getRows" method with subfilter flow for getSDWANServicesSecureEdgeCancel DIGI-13857/DIGI-13858
* *****************************************************************************/
  @isTest 
   public static void testgetSDWANServicesSecureEdgeCancel()
   {
       ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
       DataSource.QueryContext context = new DataSource.QueryContext();
       DataSource.Filter filter = new DataSource.Filter();
       DataSource.Filter filter1 = new DataSource.Filter();
       filter.columnName = 'ExternalId';
       filter.columnValue = prdBasketId;
       List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
       DataSource.Filter subFilterRec = new DataSource.Filter();
       subFilterRec.columnName = 'Query_Type';
       subFilterRec.columnValue = 'SECUREEDGECancel';
       subfilterList.add(subFilterRec);
       //System.debug(' subfilter List-->  '+ subfilterList);
       //System.debug(' String cloumn 0 -->  '+ subfilterList.get(0).columnValue);
       filter.subfilters = subfilterList;
       System.debug('Test filter'+filter);
       DataSource.TableSelection tableSelection = new DataSource.TableSelection();
       tableSelection.tableSelected = 'BasketSnapshot';
       tableSelection.filter = filter;
       context.TableSelection = tableSelection;
       //System.assertNotEquals('CWPCancelServices',subfilterList.get(0).columnValue);
       Test.startTest();  
       DataSource.TableResult result = prdBasketCtrl.query(context);
       System.debug(' result--> '+result);
       Test.stopTest();    
       System.assertEquals('SECUREEDGECancel',subfilterList.get(0).columnValue);
       //System.assert(result!=null);
       system.assert(result.success==true);
   }


       @isTest
    public static void testAMaccessory()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceOCIC_AMaccessoryOCIC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
    @isTest
    public static void testAMaccessoryRCIC()
    {
        ProductBasketDataSourceConnection prdBasketCtrl = new ProductBasketDataSourceConnection();
        DataSource.QueryContext context = new DataSource.QueryContext();
        DataSource.Filter filter = new DataSource.Filter();
        DataSource.Filter filter1 = new DataSource.Filter();
        filter.columnName = 'ExternalId';
        filter.columnValue = prdBasketId;
        List <DataSource.Filter> subfilterList = new List <DataSource.Filter>();
        DataSource.Filter subFilterRec = new DataSource.Filter();
        subFilterRec.columnName = 'Query_Type';
        subFilterRec.columnValue = 'NGEMDeviceRCIC_AMaccessoryRCIC';
        subfilterList.add(subFilterRec);
        System.debug(' subfilter List-->  '+ subfilterList);
        filter.subfilters = subfilterList;
        System.debug('Test filter'+filter);
        DataSource.TableSelection tableSelection = new DataSource.TableSelection();
        tableSelection.tableSelected = 'BasketSnapshot';
        tableSelection.filter = filter;
        context.TableSelection = tableSelection;
        Test.startTest();  
        DataSource.TableResult result = prdBasketCtrl.query(context);
        System.debug(' result--> '+result);
        Test.stopTest();
        System.assert(result!=null);
        system.assert(result.success==true);
    }
}
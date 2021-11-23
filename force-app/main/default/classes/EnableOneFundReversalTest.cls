/**
 * @Author   :   Aarathi Iyer
 * @Date     :   28 Aug 2020
 * @Desc     :   test class for the class EnableOneFundReversal
 * @US       :   EDGE-164351
*/

@IsTest
public class EnableOneFundReversalTest {
    private static cscfga__Product_Basket__c basketMAC1 = null,basketMAC2 = null,basketMAC3=null,basketMAC4=null;
 
    private void setup(){
         //CREATE ACCOUNT
        List<Account> AccList = new List<Account>();
        Account acc = AccountTestFactory.buildAccount('Test Account');
        acc.Customer_Status__c='Active'; 
        acc.CIDN__c = '767687989';
        AccList.add(acc);
       
        Account acc1 = AccountTestFactory.buildAccount('Test Account1');
        acc1.Customer_Status__c='Active'; 
        acc1.CIDN__c = '100000001';
        acc1.Parent_CIDN__c = '767687989';
        acc1.ParentId = acc.Id;
        AccList.add(acc1);
        
        Account acc2 = AccountTestFactory.buildAccount('Test Account2');
        acc2.Customer_Status__c='Active'; 
        acc2.CIDN__c = '100000011';
        acc2.Ultimate_Parent_CIDN__c = '767687989';
        acc2.Ultimate_Parent_Account__c = acc.Id;
        AccList.add(acc2);
        
        insert AccList;
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0412345678',
            Email = 'test@tele2.com',Phone= '+61401098123' 
        );
        
        insert contact;
        //CREATE OPPORTUNITY
        
        List<Opportunity> OppList = new List<Opportunity>();
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        OppList.add(opp);
        
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc1);
        opp1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        OppList.add(opp1);
        
        Opportunity opp2   = ProductTestFactory.getOpportunityBasic(acc2);
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        OppList.add(opp2);
       
        //CREATE MACOPPORTUNITY
        Opportunity oppMAC   = ProductTestFactory.getOpportunityBasic(acc);
        oppMAC.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
        OppList.add(oppMAC);
        
        Opportunity oppMAC1   = ProductTestFactory.getOpportunityBasic(acc1);
        oppMAC1.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
        OppList.add(oppMAC1);
        
        Opportunity oppMAC2   = ProductTestFactory.getOpportunityBasic(acc2);
        oppMAC2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('MAC').getRecordTypeId();
        OppList.add(oppMAC2);
        insert OppList;        
        
        List<cscfga__Product_Basket__c> BasketList = new List<cscfga__Product_Basket__c>();
        basketMAC1 = ProductTestFactory.buildEmptyBasket();
        basketMAC1.csbb__Account__c = acc.id;
        basketMAC1.cscfga__Opportunity__c = oppMAC.id;
        basketMAC1.name = 'basket1';
        basketMAC1.OF_Reversal_Inserted__c = false;
        BasketList.add(basketMAC1);
        
        basketMAC2 = ProductTestFactory.buildEmptyBasket();
        basketMAC2.csbb__Account__c = acc.id;
        basketMAC2.cscfga__Opportunity__c = oppMAC.id;
        basketMAC2.name = 'basket2';
        basketMAC2.OF_Reversal_Inserted__c = false;
        BasketList.add(basketMAC2); 
        
        basketMAC3 = ProductTestFactory.buildEmptyBasket();
        basketMAC3.csbb__Account__c = acc1.id;
        basketMAC3.cscfga__Opportunity__c = oppMAC1.id;
        basketMAC3.name = 'basket3';
        basketMAC3.OF_Reversal_Inserted__c = false;
        BasketList.add(basketMAC3);
        
        basketMAC4 = ProductTestFactory.buildEmptyBasket();
        basketMAC4.csbb__Account__c = acc2.id;
        basketMAC4.cscfga__Opportunity__c = oppMAC2.id;
        basketMAC4.name = 'basket3';
        basketMAC4.OF_Reversal_Inserted__c = false;
        BasketList.add(basketMAC4);
        insert BasketList; 
        
        List<Marketable_Offer__c> listOfOffers= new List<Marketable_Offer__c>();
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Adaptive Mobility' ;  //EDGE-184269- Changed the offer name from 'Adaptive Mobility Plan' to 'Adaptive Mobility'
        mo.Name = 'Adaptive Mobility'; //EDGE-184269
        mo.Offer_ID__c = 'DMCAT_Offer_001233';
        listOfOffers.add(mo);   
        insert listOfOffers;
              
        cscfga__Configuration_Offer__c offername1= new cscfga__Configuration_Offer__c();
        offername1.name='Adaptive Mobility'; //EDGE-184269
        offername1.cscfga__Active__c=true;
        offername1.cscfga__Description__c='Adaptive Mobility'; //EDGE-184269
        insert offername1;
                
        cscfga__Product_Definition__c prodDefinition = new cscfga__Product_Definition__c( Name = 'TestPD', cscfga__Description__c = 'Mobile Device Care', product_Specification__c = 'DMCAT_ProductSpecification_001208',Snapshot_Object__c='basketsnapshot' );
        insert prodDefinition;
        
        list<cscfga__Product_Configuration__c>productconfiglist= new list<cscfga__Product_Configuration__c>(); 
        cscfga__Product_Configuration__c pcNGEM1 = new cscfga__Product_Configuration__c();
        pcNGEM1.cscfga__Product_Basket__c = basketMAC1.id;
        pcNGEM1.cscfga__Product_Definition__c = prodDefinition.Id;
        pcNGEM1.name='Mobile Device Care Purchase';
        pcNGEM1.Type__c='Cancel';
        pcNGEM1.Marketable_Offer__c = mo.id;
        pcNGEM1.cscfga__originating_offer__c=offername1.id;
        pcNGEM1.cscfga__Product_Family__c = 'Mobile Device Care';
        productconfiglist.add(pcNGEM1);
        
        cscfga__Product_Configuration__c pcNGEM2 = new cscfga__Product_Configuration__c();
        pcNGEM2.cscfga__Product_Basket__c = basketMAC2.id;
        pcNGEM2.cscfga__Product_Definition__c = prodDefinition.Id;
        pcNGEM2.name='Mobile Device Care Purchase';
        pcNGEM2.Type__c='Cancel';
        pcNGEM2.Marketable_Offer__c = mo.id;
        pcNGEM2.cscfga__originating_offer__c=offername1.id;
        pcNGEM2.cscfga__Product_Family__c = 'Mobile Device Care';
        productconfiglist.add(pcNGEM2);
        
        cscfga__Product_Configuration__c pcNGEM3 = new cscfga__Product_Configuration__c();
        pcNGEM3.cscfga__Product_Basket__c = basketMAC3.id;
        pcNGEM3.cscfga__Product_Definition__c = prodDefinition.Id;
        pcNGEM3.name='Mobile Device Care Purchase';
        pcNGEM3.Type__c='Cancel';
        pcNGEM3.Marketable_Offer__c = mo.id;
        pcNGEM3.cscfga__originating_offer__c=offername1.id;
        pcNGEM3.cscfga__Product_Family__c = 'Mobile Device Care';
        productconfiglist.add(pcNGEM3);
        
        cscfga__Product_Configuration__c pcNGEM4 = new cscfga__Product_Configuration__c();
        pcNGEM4.cscfga__Product_Basket__c = basketMAC4.id;
        pcNGEM4.cscfga__Product_Definition__c = prodDefinition.Id;
        pcNGEM4.name='Mobile Device Care Purchase';
        pcNGEM4.Type__c='Cancel';
        pcNGEM4.Marketable_Offer__c = mo.id;
        pcNGEM4.cscfga__originating_offer__c=offername1.id;
        pcNGEM4.cscfga__Product_Family__c = 'Mobile Device Care';
        productconfiglist.add(pcNGEM4);
        
        insert productconfiglist;          
        
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        cscfga__Attribute__c attr1 = new cscfga__Attribute__c();
        attr1.Name = 'RedeemFundCopy';
        attr1.cscfga__Value__c = '100.00';
        attr1.cscfga__Product_Configuration__c = pcNGEM1.Id;            
        attrList.add(attr1);
        
        cscfga__Attribute__c attr2 = new cscfga__Attribute__c();
        attr2.Name = 'RedeemFundCopy';
        attr2.cscfga__Value__c = '0.00';
        attr2.cscfga__Product_Configuration__c = pcNGEM2.Id;            
        attrList.add(attr2);
        
        cscfga__Attribute__c attr3 = new cscfga__Attribute__c();
        attr3.Name = 'RedeemFundCopy';
        attr3.cscfga__Value__c = '200.00';
        attr3.cscfga__Product_Configuration__c = pcNGEM3.Id;            
        attrList.add(attr3);
        
        cscfga__Attribute__c attr4 = new cscfga__Attribute__c();
        attr4.Name = 'RedeemFundCopy';
        attr4.cscfga__Value__c = '300.00';
        attr4.cscfga__Product_Configuration__c = pcNGEM4.Id;            
        attrList.add(attr4);
        
        insert attrList;            
        
        List<ContractJunction__c> cjList = new List<ContractJunction__c>();
        ContractJunction__c CJ1=new ContractJunction__c();
        CJ1.name='testCJ1';
        CJ1.account__c=acc.id;
        CJ1.Related_Opportunity__c = opp.id;
        CJ1.Status__c = 'Contract Accepted';
        CJ1.Customer_Primary_Contact__c = contact.id;
        CJ1.Related_Basket__c = basketMAC1.id;
        cjList.add(CJ1);
        
        ContractJunction__c CJ2=new ContractJunction__c();
        CJ2.name='testCJ2';
        CJ2.account__c=acc.id;
        CJ2.Related_Opportunity__c = opp.id;
        CJ2.Status__c = 'Contract Accepted';
        CJ2.Customer_Primary_Contact__c = contact.id;
        CJ2.Related_Basket__c = basketMAC2.id;
        cjList.add(CJ2);
        
        ContractJunction__c CJ3=new ContractJunction__c();
        CJ3.name='testCJ3';
        CJ3.account__c=acc1.id;
        CJ3.Related_Opportunity__c = oppMAC1.id;
        CJ3.Status__c = 'Contract Accepted';
        CJ3.Customer_Primary_Contact__c = contact.id;
        CJ3.Related_Basket__c = basketMAC3.id;
        cjList.add(CJ3);
        
        ContractJunction__c CJ4=new ContractJunction__c();
        CJ4.name='testCJ4';
        CJ4.account__c=acc2.id;
        CJ4.Related_Opportunity__c = opp2.id;
        CJ4.Status__c = 'Contract Accepted';
        CJ4.Customer_Primary_Contact__c = contact.id;
        CJ4.Related_Basket__c = basketMAC4.id;
        cjList.add(CJ4);
        
        insert cjList;  
        
        List<OneFund__c> OFList = new List<OneFund__c>();
        OneFund__c onefund1 = new OneFund__c();
        onefund1.CIDN__c = acc.id;
        onefund1.OneFund_Status__c = 'Active';
        onefund1.Start_Date__c = system.today();
        onefund1.OneFund_Accrual_Frequency__c = 'Monthly';
        OFList.add(onefund1);
        
        insert OFList;        
        
    }
    
    @isTest
    static void OneFundTransactionInsertTestPositiveScenarioChildCIDN() {
        EnableOneFundReversalTest test1 = new EnableOneFundReversalTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c CJ = [Select Id from ContractJunction__c where name ='testCJ1' limit 1];       
        EnableOneFundReversal.OneFundTransactionInsert(new List<String>{CJ.Id});
        cscfga__Product_Basket__c PB = [Select Id,OF_Reversal_Inserted__c from cscfga__Product_Basket__c where Id =:basketMAC1.Id];
        List<OneFund_Transactions__c> OFT = [Select Id, OneFund__c,Sub_Type__c,Product_Basket__c from OneFund_Transactions__c where Product_Basket__c=:basketMAC1.Id];
        Test.stopTest();
        System.assertEquals(1, OFT.size());
        system.assertEquals(true,PB.OF_Reversal_Inserted__c);        
    }
    
     @isTest
    static void OneFundTransactionInsertTestPositiveScenarioParentCIDN() {
        EnableOneFundReversalTest test1 = new EnableOneFundReversalTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c CJ = [Select Id from ContractJunction__c where name ='testCJ3' limit 1];       
        EnableOneFundReversal.OneFundTransactionInsert(new List<String>{CJ.Id});
        cscfga__Product_Basket__c PB = [Select Id,OF_Reversal_Inserted__c from cscfga__Product_Basket__c where Id =:basketMAC3.Id limit 1];
        List<OneFund_Transactions__c> OFT = [Select Id, OneFund__c,Sub_Type__c,Product_Basket__c from OneFund_Transactions__c where Product_Basket__c=:basketMAC3.Id limit 1];
        Test.stopTest();
        System.assertEquals(1, OFT.size());
        system.assertEquals(true,PB.OF_Reversal_Inserted__c);
       }
    
     @isTest
    static void OneFundTransactionInsertTestPositiveScenarioUltimateParentCIDN() {
        EnableOneFundReversalTest test1 = new EnableOneFundReversalTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c CJ = [Select Id from ContractJunction__c where name ='testCJ4' limit 1];       
        EnableOneFundReversal.OneFundTransactionInsert(new List<String>{CJ.Id});
        cscfga__Product_Basket__c PB = [Select Id,OF_Reversal_Inserted__c from cscfga__Product_Basket__c where Id =:basketMAC4.Id];
        List<OneFund_Transactions__c> OFT = [Select Id, OneFund__c,Sub_Type__c,Product_Basket__c from OneFund_Transactions__c where Product_Basket__c=:basketMAC4.Id];
        Test.stopTest();
        System.assertEquals(1, OFT.size());
        system.assertEquals(true,PB.OF_Reversal_Inserted__c);
       }
    
    @isTest
    static void OneFundTransactionInsertTestNegativeScenario() {
        EnableOneFundReversalTest test1 = new EnableOneFundReversalTest();
        test1.setup();
        Test.startTest();
        ContractJunction__c CJ = [Select Id from ContractJunction__c where name ='testCJ2' limit 1];       
        EnableOneFundReversal.OneFundTransactionInsert(new List<String>{CJ.Id});
        cscfga__Product_Basket__c PB = [Select Id,OF_Reversal_Inserted__c from cscfga__Product_Basket__c where Id =:basketMAC2.Id];
        List<OneFund_Transactions__c> OFT = [Select Id, OneFund__c,Sub_Type__c,Product_Basket__c from OneFund_Transactions__c where Product_Basket__c=:basketMAC2.Id];
        Test.stopTest();
        System.assertEquals(0, OFT.size());
        system.assertEquals(false,PB.OF_Reversal_Inserted__c);        
    }

}
/**
     * @Author   :   Aniket S
     * @Date     :   Jan 2021
     * @US       :   EDGE-193826
     * @Description: Test class for QuoteContractQueueable class
 * */

@isTest
public class QuoteContractQueueableTest {
    @testSetup
    static void setupTestData(){
        Account acc = AccountTestFactory.buildAccount('Test AccountOrderflow') ;
        acc.APTPS_DocuSign_Restricted__c = false; 
        acc.Customer_Status__c = 'Active'; 
        insert acc;  
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;
      
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test Adaptive Opty';
        opp.amount = 4600;
        insert opp;
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.cscfga__total_contract_value__c = 9.9;
        insert basket;
       
        ContractJunction__c cntrctRecord=new ContractJunction__c();
        cntrctRecord.Account__c = basket.csbb__Account__c;
        cntrctRecord.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        cntrctRecord.Related_Basket__c=basket.id;
        insert cntrctRecord;
        
    }
    @isTest 
    static void testQueueable(){
        
        setupTestData();
        ContractJunction__c CJRecord = [SELECT id from ContractJunction__c limit 1];
        cscfga__Product_Basket__c productBasket =  [SELECT id from cscfga__Product_Basket__c limit 1];
        String contractJunctionRecordString = Json.serialize(CJRecord);
        String prBasketRecordString=Json.serialize(productBasket);
        QuoteContractQueueable qcq = new QuoteContractQueueable(contractJunctionRecordString,prBasketRecordString);
        test.startTest();
        ID jobID = System.enqueueJob(qcq);
        Test.stopTest();
        system.assert(jobID!=null);
    }

}
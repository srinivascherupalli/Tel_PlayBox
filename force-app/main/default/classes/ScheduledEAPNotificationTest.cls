/*
* AUTHOR : Romil,Tejes 
* TEAM: Napier
* EDGE-141820
* DESCRIPTION : Test Class for ScheduledEAPNotification class
*/
@isTest
public class ScheduledEAPNotificationTest {
    
    @isTest
    static void testScheduledEAPNotification() {

        List<Account> accountList= new List<Account>();
        List<Opportunity> oppList= new List<Opportunity>();
        
        Account acc = new Account(Name = 'Test Account for EAP');
        acc.Customer_Status__c = 'Active';
        accountList.add(acc);
        
        insert accountList;
        
        Opportunity opp = new Opportunity();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOppForEAP';
        opp.AccountId=acc.id;
        opp.CloseDate=Date.today()+90;
        oppList.add(opp);
        
        Opportunity oppBatch = new Opportunity();
        oppBatch.StageName = 'Develop';
        oppBatch.Product_Type__c = 'Modular';
        oppBatch.Name = 'BatchTestingOppForEAP';
        oppBatch.AccountId=acc.id;
        oppBatch.CloseDate=Date.today()+90;
        oppList.add(oppBatch);
        
        insert oppList;
        
        List<cscfga__Product_Basket__c> basketList= new List<cscfga__Product_Basket__c>();
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforEAP';
        basketList.add(basket);
        
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
        basket2.cscfga__Opportunity__c = opp.id;
        basket2.csbb__Account__c = acc.Id;
        basket2.Name = 'testBasketforEAP2';
        basketList.add(basket2);
        
        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
        basket3.cscfga__Opportunity__c = opp.id;
        basket3.csbb__Account__c = acc.Id;
        basket3.Name = 'testBasketforEAP3';
        basketList.add(basket3);
        
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c();
        basket4.csordtelcoa__Basket_Stage__c = 'Contract Initiated';
        basket4.cscfga__Opportunity__c = opp.id;
        basket4.csbb__Account__c = acc.Id;
        basket4.Name = 'testBasketforEAP4';
        basketList.add(basket4);
        
        insert basketList;
        
        List<ContractJunction__c> contractList = new List<ContractJunction__c>();
        ContractJunction__c contract= new ContractJunction__c();
        contract.Related_Opportunity__c=opp.Id;
        contract.IsNotificationTriggered__c=false;
        contract.Status__c='Initiated';
        contract.Related_Basket__c=basket.id;
        contract.CIS_Dispatched_Offers__c='Telstra Collaboration';
        contract.EAP_Discount_End_Date__c=Date.today()-3;
        contractList.add(contract);
        
        ContractJunction__c contract2= new ContractJunction__c();
        contract2.Related_Opportunity__c=opp.Id;
        contract2.IsNotificationTriggered__c=false;
        contract2.Status__c='Initiated';
        contract2.Related_Basket__c=basket2.id;
        contract2.CIS_Dispatched_Offers__c='Telstra Collaboration';
        contract2.EAP_Discount_End_Date__c=Date.today()-3;
        contractList.add(contract2);
        
        ContractJunction__c contract3= new ContractJunction__c();
        contract3.Related_Opportunity__c=opp.Id;
        contract3.IsNotificationTriggered__c=false;
        contract3.Status__c='Initiated';
        contract3.Related_Basket__c=basket3.id;
        contract3.CIS_Dispatched_Offers__c='Telstra Collaboration';
        contract3.EAP_Discount_End_Date__c=Date.today()-3;
        contractList.add(contract3);
        
        ContractJunction__c contract4= new ContractJunction__c();
        contract4.Related_Opportunity__c=opp.Id;
        contract4.IsNotificationTriggered__c=false;
        contract4.Status__c='Initiated';
        contract4.Related_Basket__c=basket4.id;
        contract4.CIS_Dispatched_Offers__c='Telstra Collaboration';
        contract4.EAP_Discount_End_Date__c=Date.today()+30;
        contractList.add(contract4);
        
        insert contractList;
        
        List<dsfs__DocuSign_Envelope__c> envelopeList = new List<dsfs__DocuSign_Envelope__c>();
        dsfs__DocuSign_Envelope__c envelope=new dsfs__DocuSign_Envelope__c();
        envelope.dsfs__DocuSign_Envelope_ID__c='7cb05914-e927-45fe-8094-5ff8b67a74dd';
        envelope.dsfs__Source_Object__c=contract.Id;
        envelopeList.add(envelope);
        
        dsfs__DocuSign_Envelope__c envelope2=new dsfs__DocuSign_Envelope__c();
        envelope2.dsfs__DocuSign_Envelope_ID__c='7cb05914-e927-45fe-8094-5ff8b67a74cc';
        envelope2.dsfs__Source_Object__c=contract2.Id;
        envelopeList.add(envelope2);
        
        dsfs__DocuSign_Envelope__c envelope3=new dsfs__DocuSign_Envelope__c();
        envelope3.dsfs__DocuSign_Envelope_ID__c='7cb05914-e927-45fe-8094-5ff8b67a74bb';
        envelope3.dsfs__Source_Object__c=contract3.Id;
        envelopeList.add(envelope3);
        
        dsfs__DocuSign_Envelope__c envelope4=new dsfs__DocuSign_Envelope__c();
        envelope4.dsfs__DocuSign_Envelope_ID__c='7cb05914-e927-45fe-8094-5ff8b67a74aa';
        envelope4.dsfs__Source_Object__c=contract4.Id;
        envelopeList.add(envelope4);
        
        insert envelopeList;
        
        
        
        Test.setMock(HttpCalloutMock.class, new MockHttpDocuSignResGenerator());
        Test.startTest();
		        
        Datetime dt = Datetime.now().addMinutes(1);
        String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
        ScheduledEAPNotification sch = new ScheduledEAPNotification();
        system.schedule('TestEAPNotification', CRON_EXP, sch);
        ScheduledEAPNotification.sendChatterNotification();
        
        
        Test.stopTest();
        
        
        List<ContractJunction__c> contractBatchList=[SELECT ID,Name,Status__c,EAP_Discount_End_Date__c,Related_Basket__r.csordtelcoa__Basket_Stage__c,Related_Opportunity__r.OwnerId, IsNotificationTriggered__c 
                                                       FROM ContractJunction__c WHERE Related_Opportunity__r.Name =:'TestingOppForEAP' ];
        for(ContractJunction__c conRec:contractBatchList){
            if(conRec.EAP_Discount_End_Date__c < Date.today()){
                System.assertEquals(true,conRec.IsNotificationTriggered__c);
            	System.assertEquals('Cancelled',conRec.Status__c);
            	System.assertEquals('Contract Rejected',conRec.Related_Basket__r.csordtelcoa__Basket_Stage__c);
            }
            else{
                System.assertEquals(false,conRec.IsNotificationTriggered__c);
            	System.assertEquals('Initiated',conRec.Status__c);
            	System.assertEquals('Contract Initiated',conRec.Related_Basket__r.csordtelcoa__Basket_Stage__c);
            }
            
        }
        
    }
}
@isTest
public class LinkAgreementSubscriptionTest {
	@Testsetup
	static void dataSetup(){
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        insert acc;

        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.csordtelcoa__Basket_Stage__c = 'Submitted';
		basket.Project_ID__c = 'acc01';
        basket.Project_Manager_User_ID__c = 'test01';
        basket.Project_Manager_Contact_Number__c = '9985018467';
        basket.Project_Manager_Email__c = 'test@gmail.com';
		insert basket;
        
       	csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
		insert ordReq;
        
    	cscfga__Product_Configuration__c productConfig = new cscfga__Product_Configuration__c();
        insert productConfig;
        
        csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        insert ord;
        
        csord__Subscription__c subs1=new csord__Subscription__c();
        subs1.name  = 'test subs1';
        subs1.csord__Identification__c = 'test identity';
        subs1.csord__Order__c = ord.Id;
        subs1.Sub_status__c = 'Active';
        subs1.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs1;
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        insert subs;
        
        List<csord__Service__c> servs = new List<csord__Service__c>();
		csord__Service__c serv = new csord__Service__c();
        serv.name ='tst service';
        serv.csordtelcoa__Product_Basket__c = basket.id;
        serv.csord__Identification__c  = 'test identify';
        serv.csordtelcoa__Service_Number__c = '3';
        serv.csord__Subscription__c = subs.Id;
        serv.csord__Status__c = 'Service Created';
        serv.csordtelcoa__Product_Configuration__c = productConfig.id;
        servs.add(serv);
        insert servs;
        
  		Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
		agreement.name = 'Apttus Agreement 1';
        agreement.Related_Basket__c = basket.id;
		insert agreement;
    }
    
    @isTest
    public static void assignSubscriptionToAppointmentTest() {
    	csord__Service__c serv = [SELECT id from csord__Service__c where name = 'tst service'];
        
    	Test.startTest();
		LinkAgreementSubscription.assignSubscriptionToAgreement(new List<ID> {serv.id});
		Test.stopTest();
        String agreementId = null;
        String subscriptionAgreementId = null;
        for(Apttus__APTS_Agreement__c agreement : [select id, name, related_basket__c from Apttus__APTS_Agreement__c where name ='Apttus Agreement 1']){
            agreementId = agreement.Id;
            break;
        }
        for(csord__Subscription__c subscription : [select id, Agreement__c,name from csord__Subscription__c where name = 'test subs']){
            subscriptionAgreementId = subscription.Agreement__c;
            break;
        }
        system.assert(subscriptionAgreementId!=null);
        
    }
}
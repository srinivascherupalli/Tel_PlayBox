@isTest(SeeAllData=false)
public class CancelContractWithAgreementTest {
    
    @Testsetup
    static void dataSetup(){
    Environment_Configurations__c environmentConfig =New Environment_Configurations__c();    
    environmentConfig.No_Triggers__c = true;
        insert environmentConfig;
    EnvironmentVariable__c ev= new EnvironmentVariable__c();
        ev.name='Cancel_Contract_With_Agreement';
        ev.Value__c='True';
        insert ev;
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Customer_Status__c='Active';
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Qualify';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp;
        
       // Contact contact = AccountTestFactory.buildContact(acc, 'Smith123');
         Contact contactCustom = new contact();
        contactCustom.FirstName = 'Reena123';
        contactCustom.lastName = 'Reena123Last';
        contactCustom.Pref_Comm_Method__c='eMail123';
        contactCustom.MobilePhone='0423456789'; //FDR Fix for sprint 21.14
        contactCustom.email='k123@gmail.com';
        contactCustom.AccountId = acc.id;
        insert contactCustom;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contactCustom.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        insert ocr;
        
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        insert basket;
        
       ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = contactCustom.Email;
        record.Phone__c = contactCustom.MobilePhone;
        record.Customer_Primary_Contact__c = contactCustom.Id;
        record.Related_Basket__c = basket.id;
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        record.isAgreementGenerated__c=true;
        record.Agreement_Number__c='12354';
        insert record;
        
        Apttus__APTS_Agreement__c agrrcrd= new Apttus__APTS_Agreement__c();
        agrrcrd.name='BSA_Test00000.0';
        agrrcrd.Apttus__Account__c=acc.id;
        agrrcrd.RecordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        agrrcrd.Apttus__Agreement_Category__c='Business Services';
        agrrcrd.APTPS_Agreement_Subcategory__c='Single Customer';
        agrrcrd.APTPS_Customer_Primary_Contact__c=contactCustom.id;
        agrrcrd.Related_Contract__c=record.id;
        insert agrrcrd;
       
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        insert ordReq;
        
         csord__Order__c ord = ProductTestFactory.buildOrder('TestOrder', acc.id, 'Created', ordReq.id);
        ord.csord__Order_Request__c = ordReq.Id;
        ord.csord__Status2__c='In Progress';
        ord.name = 'TestOrder';
        ord.csordtelcoa__Opportunity__c =opp.id;
        insert ord;
        
        cscrm__Address__c addr = AccountTestFactory.buildAddress('ADR-00001');
        insert addr;
        cscrm__Site__c  site = AccountTestFactory.buildSite(addr.Id, acc.Id);
        insert site; 
        
        csord__Subscription__c subs=new csord__Subscription__c();
        subs.name  = 'test subs';
        subs.csord__Identification__c = 'test identity';
        subs.csord__Order__c = ord.Id;
        subs.ContractJunction__c=record.id;
        subs.csord__Status__c = 'Closed Replaced';
        subs.Sub_status__c = 'Active';
        subs.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs.Site__c = site.Id;
        subs.csord__Order_Request__c = ordReq.Id;
        insert subs;
        
        csord__Subscription__c subs2=new csord__Subscription__c();
        subs2.name  = 'test subs';
        subs2.csord__Identification__c = 'test identity';
        subs2.csord__Order__c = ord.Id;
        subs2.ContractJunction__c=record.id;
        subs2.csord__Status__c = 'Closed Replaced';
        subs2.Sub_status__c = 'Active';
        subs2.eventId__c = '9f0bfd2-1bfd-7916-552d-9e28c804294e';
        subs2.csordtelcoa__Subscription_Number__c = 'SN-12345';
        subs2.Site__c = site.Id;
        subs2.csord__Order_Request__c = ordReq.Id;
        insert subs2;
        
        
    }
    
    @isTest
    static void testprocessOrderRecordNew(){
    csord__Subscription__c sub = [SELECT Id, csord__Order__c,ContractJunction__c, csordtelcoa__Subscription_Number__c, csord__Status__c, Name from csord__Subscription__c where Name = 'test subs' limit 1];
    List<id> Contractid = new List<id>();
    Contractid.add(sub.ContractJunction__c);
    Test.startTest();
    
    CancelContractWithAgreement.processCancellation(Contractid);
    List<csord__Subscription__c> subs= [select id from csord__Subscription__c];
    System.assert(!subs.isEmpty());    
    Test.stopTest();
    
    }
    
    @isTest
    static void testprocessOrder(){
    
    List<id> Contractid = new List<id>();
    //Contractid.add(sub.ContractJunction__c);
    Test.startTest();
   
    CancelContractWithAgreement.processCancellation(Contractid);
    List<csord__Subscription__c> subs= [select id from csord__Subscription__c];
    System.assert(!subs.isEmpty()); 
    Test.stopTest();
    
    }
    
            @isTest
    static void processContractCancellationTest(){
    //dataSetup();
	 list<csord__Subscription__c> relatedSubscriptions = [SELECT Id,ContractJunction__c, csord__Status__c, csordtelcoa__Replaced_Subscription__c, toBeCancelled__c FROM csord__Subscription__c WHERE ContractJunction__c != NULL]; 
    Test.startTest();
        if(relatedSubscriptions.size() > 0){
             CancelContractWithAgreement.processContractCancellation(relatedSubscriptions[0]);
            List<csord__Subscription__c> subs= [select id from csord__Subscription__c];
    		System.assert(!subs.isEmpty());
        }
    Test.stopTest();
    
    }

}
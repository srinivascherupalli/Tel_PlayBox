/* Class Name      :   QuoteAndContractSendChatterPostTest
Developer Name    Date          Story Description
Monali Golhar     19/03/2021    Test class for QuoteAndContractSendChatterPostTest 
 */
@isTest(SeeAllData=true)
public class QuoteAndContractSendChatterPostTest {
    @isTest
    static void generateChatterPostTest(){
         Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator']; 
       User u = new User(Alias = 'admin', Email='testuser@test.com.sample', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_AU', ProfileId = p.Id, 
                          TimeZoneSidKey='Australia/Sydney', UserName='admin@test.com.portfoliotest');
        
        u.Phone = '3433233223';
        
        insert u;
        
        Account ac = new Account();
        ac.name = 'Test';
        ac.Customer_Status__c = 'Active';
        insert ac;
        Contact con = new Contact(LastName ='testCon2',AccountId = ac.Id, Onboarding_Status__c = 'Active',PIMS_User_Type__c='TEG',OTP_Mobile_Phone_Number__c='+911234567890',Community_User_Type__c='Domestic'); // Hawaii
        insert con;
            
        
        Opportunity opp = new Opportunity();
        opp.AccountId=ac.Id;
        opp.Contract_Term__c = 12;
        opp.CloseDate=System.today();
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        opp.OwnerId = u.Id; 
        insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();  
        basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = ac.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.Pre_Authorised__c = false;
        basket.cscfga__total_contract_value__c = 11000;
        insert basket;
        
        ContractJunction__c cn=new ContractJunction__c();
        cn.Account__c = basket.csbb__Account__c;
        //oldContract.BSA_Generated__c=true;
        cn.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        cn.Related_Basket__c=basket.id;
        cn.Customer_Primary_Contact__c = con.Id; 
        insert cn;
        
        
        
        dsfs__DocuSign_Status__c ES = New dsfs__DocuSign_Status__c();
        ES.dsfs__DocuSign_Envelope_ID__c = 'B97DD032-9DEE-4911-94C1-DA690B917C72';
        ES.dsfs__Sender_Email__c = 'test@team.telstra.com';
        ES.dsfs__Sender__c = 'Contract Retract User';
        ES.dsfs__Subject__c = 'Contract Retract';
        ES.dsfs__Envelope_Status__c = 'Voided';
        ES.dsfs__Voided_Reason__c = 'Test Reason';
        insert ES;
        
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient.ContractJunction__c = cn.id;
        docuSignRecipient.dsfs__Parent_Status_Record__c = ES.Id;
        //docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A6-E90DF35DC9FC';
        docuSignRecipient.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A329';
        docuSignRecipient.Name='etss';
        docuSignRecipient.dsfs__Date_Signed__c=system.today();
        insert docuSignRecipient; 
        
        
        Test.startTest();
        List<dsfs__DocuSign_Recipient_Status__c> d  = [SELECT Id, ContractJunction__r.Related_Opportunity__r.RecordType.Name ,dsfs__DocuSign_Routing_Order__c,dsfs__Recipient_Status__c,ContractJunction__r.Contract_Type__c,ContractJunction__r.Related_Opportunity__r.ownerId,ContractJunction__r.Customer_Primary_Contact__r.FirstName,ContractJunction__r.Customer_Primary_Contact__r.LastName, dsfs__Account__r.Name ,ContractJunction__r.Id FROM dsfs__DocuSign_Recipient_Status__c Where Id =:docuSignRecipient.Id];
        System.debug('Op' +d[0].ContractJunction__r.Related_Opportunity__r.ownerId);
        QuoteAndContractSendChatterPost.generateChatterPost(d);
        FeedItem[] feed = [Select id ,Body,ParentId from FeedItem ];
        system.assertEquals(feed.Size() > 0 ,true);     
        Test.stopTest();
    }
}
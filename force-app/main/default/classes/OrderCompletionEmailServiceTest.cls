//updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
@isTest
public class OrderCompletionEmailServiceTest {
    
    @Testsetup
    static void dataSetup(){
        
        BDS_Notify_Settings__c featureLevel = new BDS_Notify_Settings__c(name = 'Feature Level',Value__c = 'FeatureLevelShadow',Is_SI5_Offer__c  = true);
        BDS_Notify_Settings__c technicalSupport = new BDS_Notify_Settings__c(name = 'Technical Support',Value__c = 'TechnicalSupportShadow ',Is_SI5_Offer__c  = true);
        insert new List<BDS_Notify_Settings__c>{featureLevel,technicalSupport};
            
        Account acc = new Account();
        acc.Name = 'test Account' ;
        acc.Type = 'Competitor' ;
        acc.Account_Status__c='Active';
        acc.Customer_Status__c  = 'Active';
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.name='opp1';
        opp.StageName='Closed Won';
        opp.CloseDate=Date.newInstance(2016, 12, 9);
        opp.AccountId = acc.id;
        insert opp;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Synchronised_With_Opportunity__c = true;
        basket.csordtelcoa__Basket_Stage__c = 'Contract Accepted';
        insert basket;
        
        Contact contact = AccountTestFactory.buildContact(acc, 'Smith');
        contact.FirstName = 'Reena';
        contact.Pref_Comm_Method__c='eMail';
        contact.MobilePhone='0476543210';
        contact.email='k@gmail.com';
        contact.AccountId = acc.id;
        insert contact;
        
        Billing_Account__c ba=new Billing_Account__c();
        ba.Billing_Account_Name__c='Test Billing Account';
        ba.Billing_Account_Number__c='123456789123';
        ba.Account__c=acc.Id;
        ba.Billing_Account_Owner__c=contact.Id;
        insert ba;
        

        //EDGE - 103485 Start
        Marketable_Offer__c marketableOfferTID = new Marketable_Offer__c();
        marketableOfferTID.Name = 'Telstra Internet Direct';
        marketableOfferTID.Offer_ID__c = 'DMCAT_Offer_000709';
        marketableOfferTID.OfferDefinationName__c = '';
        system.debug('marketableOfferTID:::' + marketableOfferTID);
        insert marketableOfferTID;
        //EDGE - 103485 End
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=true;
        ocr.ROLE = 'Decision Maker';
        insert ocr;
        List<csord__Order_Request__c> ordReqs=new List<csord__Order_Request__c>();
        csord__Order_Request__c ordReq = ProductTestFactory.buildOrderRequest();
        ordReqs.add(ordReq);
        
        insert ordReqs;
        
        cscfga__Product_Definition__c prodDef = ProductTestFactory.buildProductDefinition('TestProduct', 'TestPlan');
        prodDef.product_Specification__c = 'DMCAT_ProductOffering_000304';
        insert prodDef;
        
        
        cscfga__Product_Configuration__c prodConfig = ProductTestFactory.buildProductConfig(prodDef.Id);
        insert prodConfig;
              

  List<APXTConga4__Conga_Email_Template__c> templates=new List<APXTConga4__Conga_Email_Template__c>();
        APXTConga4__Conga_Email_Template__c congaTemplate5 =new APXTConga4__Conga_Email_Template__c();
        congaTemplate5.APXTConga4__Is_Body_Attachment__c = false;
        congaTemplate5.APXTConga4__Name__c = 'Order_Completion_Template_Combined';
        congaTemplate5.APXTConga4__Subject__c = 'Your Telstra order';
        congaTemplate5.APXTConga4__Template_Group__c = 'Orlando Templates';
        congaTemplate5.APXTConga4__HTMLBody__c = '{order.number} {offerdetails} {appointment_details}';
        templates.add(congaTemplate5);
        

        insert templates;
        
          
        
         List<csord__Order__c> ords=new List<csord__Order__c>();
        
       csord__Order__c createOrder = ProductTestFactory.buildOrder('EDGE-100899', acc.id, 'In Progress', ordReq.id);
        createOrder.csord__Order_Request__c = ordReq.Id;
        createOrder.csord__Status2__c='In Progress';
        createOrder.csordtelcoa__Opportunity__c =opp.id;
        createOrder.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        createOrder.Billing_Account__c=ba.Id;
        createOrder.Project_Manager_Email__c = 'projectmanageremail@team.telstra.com';
        ords.add(createOrder);
        insert ords;
        
        csord__Order__c secondaryOrder = ProductTestFactory.buildOrder('EDGE-100899', acc.id, 'In Progress', ordReq.id);
        secondaryOrder.csord__Order_Request__c = ordReq.Id;
        secondaryOrder.csord__Status2__c='In Progress';
        secondaryOrder.csordtelcoa__Opportunity__c =opp.id;
        secondaryOrder.csordtelcoa__Product_Configuration__c = prodConfig.Id;
        secondaryOrder.Billing_Account__c=ba.Id;
        secondaryOrder.csord__Primary_Order__c = createOrder.Id;
        secondaryOrder.Project_Manager_Email__c = 'projectmanageremail@team.telstra.com';
        insert secondaryOrder;
               
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User SignatoryContact3 = New User(Alias = 'newUser', Email='new1_kiran@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles', UserName='new1_kiran@testorg.com');
        SignatoryContact3.IsActive =true; 
        // insert SignatoryContact3;
        ContractJunction__c CJ=new ContractJunction__c();
        CJ.name='testCJ';
        CJ.account__c=acc.id;
        CJ.Related_Opportunity__c = opp.id;
        CJ.Customer_Primary_Contact__c = contact.id;
        CJ.Related_Basket__c = basket.id;
        CJ.DocuSign_Signer_2__c = contact.id;
       // CJ.DocuSign_Recipient_Status__c = ds.id;
        insert CJ;
        
         dsfs__DocuSign_Status__c ES = New dsfs__DocuSign_Status__c();
        ES.dsfs__DocuSign_Envelope_ID__c = 'B97DD032-9DEE-4911-94C1-DA690B917C72';
        ES.dsfs__Sender_Email__c = 'test@team.telstra.com';
        ES.dsfs__Sender__c = 'Contract Retract User';
        ES.dsfs__Subject__c = 'Contract Retract';
        ES.dsfs__Envelope_Status__c = 'Voided';
        ES.dsfs__Voided_Reason__c = 'Test Reason';
        insert ES;
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient.ContractJunction__c = CJ.id;
        docuSignRecipient.dsfs__Parent_Status_Record__c = ES.Id;
        //docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A6-E90DF35DC9FC';
        docuSignRecipient.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A329';
		docuSignRecipient.Name='etss';
        Insert docuSignRecipient; 
        
        list<contractjunction__c> conjun=[select id,(select id from DocuSign_Recipient_Status__r) from contractjunction__c];
        system.debug('conjun'+conjun[0].DocuSign_Recipient_Status__r);
    }
    
    @isTest
    static void testsendEmailByOrderID(){


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IntegrationRecordHandlerUtilCalloutMock());    
     list<csord__Order__c> Orderlist =[SELECT Id, Name, csord__Order_Number__c, csordtelcoa__Opportunity__c from csord__Order__c];
     list<id> Orderids= new list<id>();
     for(csord__Order__c Order1:Orderlist){
         Orderids.add(Order1.id);        
     }
        OrderCompletionEmailService.sendEmailByOrderID(Orderids) ;
      Test.stopTest();
        system.assert(Orderlist.size()>0);
       
}
}
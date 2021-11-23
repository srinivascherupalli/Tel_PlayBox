/**
* @Author   :   Yash Rathod
* @Date     :   28 Feb 2019
* @Desc     :   TestClass for RetractContractComponent Controller
//Last Modified : updated only MobilePhone value (none of other) to valid format on contact creation, to fix the testclass failure because of new validation implemented as part of DIGI-4056 (Team SFO :: 21.14)
* */

@isTest
public class RetractContractComponentTest {
    
    public static String generateContractRec() {
          //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.APTPS_DocuSign_Restricted__c = false;
        acc.Customer_Status__c = 'ACTIVE';
        insert acc;  
        System.assert(acc.id != null);
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '0423456789',
            Email = 'test@tele2.com'   
        );
        Insert contact;
        System.assert(contact.id != null);
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        opp.Product_Type__c='Modular';
        opp.AccountId = acc.id;
        insert opp;
        
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Draft';
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
       
         Contractrecord.Status__c = 'Initiated';
         Contractrecord.Account__c = acc.id;

         insert Contractrecord; 

        list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();

        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
        Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated', Related_Contract__c=Contractrecord.Id);
        Agglist.add(agreement1); 

        Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        Agglist.add(agreement2);

        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';

        Product2 prod1=new Product2();
        prod1.Name='Adaptive Mobility1';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;

        insert  Agglist ;   

        dsfs__DocuSign_Status__c ES = New dsfs__DocuSign_Status__c();
        ES.dsfs__DocuSign_Envelope_ID__c = 'B97DD032-9DEE-4911-94C1-DA690B917C72';
        ES.dsfs__Sender_Email__c = 'test@team.telstra.com';
        ES.dsfs__Sender__c = 'Contract Retract User';
        ES.dsfs__Subject__c = 'Contract Retract';
        ES.dsfs__Envelope_Status__c = 'Voided';
        ES.dsfs__Voided_Reason__c = 'Test Reason';
        insert ES;
        
        list<dsfs__DocuSign_Recipient_Status__c> docuSignRecipientlst=new list<dsfs__DocuSign_Recipient_Status__c>();
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient.ContractJunction__c = Contractrecord.id;
        docuSignRecipient.dsfs__Parent_Status_Record__c = ES.Id;
        //docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A6-E90DF35DC9FC';
        docuSignRecipient.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A329';
    docuSignRecipient.Name='etss';
        docuSignRecipient.dsfs__Date_Signed__c=system.today();
        docuSignRecipientlst.add(docuSignRecipient); 
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient1 = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient1.ContractJunction__c = Contractrecord.id;
        docuSignRecipient1.dsfs__Parent_Status_Record__c = ES.Id;
        //docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A7-E90DF35DC9FC';
        docuSignRecipient1.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A325';
    docuSignRecipient1.Name='etss1';
        docuSignRecipient1.dsfs__Date_Signed__c=system.today();
       docuSignRecipientlst.add(docuSignRecipient1); 
        
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient2 = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient2.ContractJunction__c = Contractrecord.id;
        docuSignRecipient2.dsfs__Parent_Status_Record__c = ES.Id;
        //docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A7-E90DF35DC9FC';
        docuSignRecipient2.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A325';
    docuSignRecipient2.Name='etss2';
    //    docuSignRecipient2.dsfs__Date_Signed__c=system.today();
        docuSignRecipientlst.add(docuSignRecipient2); 
        
        insert docuSignRecipientlst;

         System.assert(Contractrecord.id != null);
         return Contractrecord.id;
    }
    @isTest
    public static void recordDetailsTest(){
      //  RetractContractComponent retCon = new RetractContractComponent();
        Test.startTest();
        String idRec = generateContractRec();
        RetractContractComponent.recordDetails(idRec);
        System.assertNotEquals(NULL , RetractContractComponent.recordDetails(idRec) );
        Test.stopTest();
    }
    
    @isTest
    public static void updateRecordTest(){
     try{ 
        Test.startTest();
        String idRec = generateContractRec();
        
        dsfs__DocuSign_Status__c ES = New dsfs__DocuSign_Status__c();
        ES.dsfs__DocuSign_Envelope_ID__c = 'B97DD032-9DEE-4911-94C1-DA690B917C72';
        ES.dsfs__Sender_Email__c = 'test@team.telstra.com';
        ES.dsfs__Sender__c = 'Contract Retract User';
        ES.dsfs__Subject__c = 'Contract Retract';
        ES.dsfs__Envelope_Status__c = 'Voided';
        ES.dsfs__Voided_Reason__c = 'Test Reason';
        insert ES;
        /*
        dsfs__DocuSign_Recipient_Status__c docuSignRecipient = new dsfs__DocuSign_Recipient_Status__c();
        docuSignRecipient.ContractJunction__c = idRec;
        docuSignRecipient.dsfs__Parent_Status_Record__c = ES.Id;
        docuSignRecipient.dsfs__Envelope_Id__c = '60B2E98B-4244-4409-80A6-E90DF35DC9FC';
        docuSignRecipient.dsfs__DocuSign_Recipient_Id__c = 'CC4E47AF-7148-4286-BFB9-D6A8BE02A329';
        Insert docuSignRecipient; */
        Boolean isUpdated = RetractContractComponent.updateRecord(idRec,'Other text a', 'Test Other Text');
        System.assertEquals(true , isUpdated );
        Test.stopTest();
    }
   Catch(Exception ex) {
           system.debug('########>>>>> Exception ' + ex);
    } 
    }
        @isTest
    public static void UserAndOrgDetailsTest(){
      
        Test.startTest();
        RetractContractComponent.userInfoPRM();
     String orgDetail = RetractContractComponent.organizationInfo();
        Test.stopTest();
    }
    
}
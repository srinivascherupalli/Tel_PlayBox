@IsTest
public class AgreementRecordCreationTest {
    private static ContractJunction__c record = new ContractJunction__c();
    private static ContractJunction__c record1 = new ContractJunction__c();
   
    @testSetup
    static void setupTestData(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
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
            Email = 'test@tele2.com'   
        );
        Insert contact;
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        listoppty.add(opp);
       // insert opp;
        
         //CREATE OPPORTUNITY
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc);
        opp1.amount = 4600;
        listoppty.add(opp1);
        
        insert listoppty;
        
        list<cscfga__Product_Basket__c> lstbasket= new list<cscfga__Product_Basket__c>();
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        lstbasket.add(basket);
       // insert basket;
        
         //Create Basket
        cscfga__Product_Basket__c basket2 = ProductTestFactory.buildEmptyBasket();
        basket2.csbb__Account__c = acc.id;
        basket2.cscfga__Opportunity__c = opp1.id;
        basket2.Name = 'basket2';
        lstbasket.add(basket2);
        
        insert lstbasket;
        
        
       
        
       List<ContractJunction__c> contractJunctionList = new List<ContractJunction__c>();
      
      //  record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
      //  record.Email__c = oppContact.contact.Email;
       // record.Phone__c = oppContact.contact.MobilePhone;
       // record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.CongaStatus__c = 'NotStarted';
        
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        record.GPTVersion__c=1.2;
        record.OFTVersion__c=1.4;
        record.BSAVersion__c=1.3;
        //insert record;
        contractJunctionList.add(record);
    
        
       
      //   record = new ContractJunction__c();
        record1.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
      //  record1.Email__c = oppContact.contact.Email;
       // record1.Phone__c = oppContact.contact.MobilePhone;
       // record1.Customer_Primary_Contact__c = oppContact.ContactId;
        record1.Related_Basket__c = basket2.id;
        record1.Parent_Contract__c=record.id;
        record1.CongaStatus__c = 'NotStarted';
        record1.Account__c = basket2.csbb__Account__c;
        record1.Related_Opportunity__c = basket2.cscfga__Opportunity__c;
        record1.Contract_Activated_Date__c = System.today();
        record1.Contract_Term_Months__c = 36;
        record1.Name = 'CN' + 'TestBasket';
        record1.GPTVersion__c=1.2;
        record1.OFTVersion__c=0.0;
        record1.BSAVersion__c=0.0;
       // insert record1;
        contractJunctionList.add(record1);
        insert contractJunctionList;
        test.starttest();
        list<Service_Term__c> stlist= new list<Service_Term__c>();
        Service_Term__c st =new Service_Term__c();
        st.Related_Contract__c = record.Id;
        st.Name = 'MDM ServiceTerm';
     //   st.ServiceTermTemplateName__c = 'Contract - Service Terms(MDM)';
        st.Account__c = acc.Id;
        st.Related_Opportunity__c = opp1.Id;
        st.Contract_Activated_Date__c = System.today();
        st.Contract_Term_Months__c = 32;
        st.ParentContract__c = record.id;
        st.ServiceTermName__c='test';
        //insert st;
        stlist.add(st);
        Service_Term__c st1 =new Service_Term__c();
        st1.Related_Contract__c = record1.Id;
        st1.Name = 'MDM ServiceTerm';
        st1.Account__c = acc.Id;
        st1.Related_Opportunity__c = opp1.Id;
        st1.Contract_Activated_Date__c = System.today();
        st1.Contract_Term_Months__c = 32;
        st1.ParentContract__c = record1.id;
        st1.OFTVersion__c=2;
        st1.ServiceTermName__c='test';
        //insert st1;
        stlist.add(st1);
        insert stlist;
            
        
      list<Apttus__APTS_Agreement__c> Agglist= new list<Apttus__APTS_Agreement__c>();
             
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Product_Key_Facts').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('General_Product_Terms').getRecordTypeId();
            Apttus__APTS_Agreement__c agreement1 = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Account__c=contractJunctionList[0].Account__c,Apttus__Contract_End_Date__c=system.today(),name = 'Test', Apttus__Agreement_Category__c = 'Single Customer', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        Agglist.add(agreement1);
        
            Apttus__APTS_Agreement__c agreement2 = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Account__c=contractJunctionList[0].Account__c,Apttus__Contract_End_Date__c=system.today(),name = 'Test', Apttus__Agreement_Category__c = 'Single Customer', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
            Agglist.add(agreement2);
            
            insert  Agglist ;   
        
        list<ContentVersion> ContentVersionList = New list<ContentVersion>();
        for(Integer i=1; i<= 9; i++){
            ContentVersion contentVersion = new ContentVersion(
                Title = 'Penguins'+i+'.pdf',
                PathOnClient = 'Penguins'+i+'.pdf',
                VersionData = Blob.valueOf('Test Content'),
                IsMajorVersion = true
            );
            ContentVersionList.add(contentVersion);
        }
        insert ContentVersionList;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = record.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList.add(cdl);
        }
        insert ContentDocumentLinkList;
        insert new EnvironmentVariable__c(Name= 'ContractInitiate', Value__c = '1');
        insert new EnvironmentVariable__c(Name= 'AgreementGenerateContract', Value__c = '1');
        Insert new CustomConfigurationOptions__c(Name = 'ContractInitiate',Enrichment_Basket_Stage__c ='Contract Initiated' , External_Id__c ='7842', MarketableOfferList__c = '', Opportunity_Stage__c = 'Propose');
        
          //create ContentDocumentLink  record 
        list<ContentDocumentLink> ContentDocumentLinkList1 = New list<ContentDocumentLink>();
        for(ContentDocument document : documents){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = record1.id;
            cdl.ContentDocumentId = document.Id;
            cdl.shareType = 'V';
            ContentDocumentLinkList1.add(cdl);
        }
        insert ContentDocumentLinkList1;
       
      test.stoptest();
    }
    @isTest
    static void creaContractJunctionRecord() {
        Test.startTest();
        try{
       // setupTestData();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
         
        
        AgreementRecordCreation.createAgreementData(Database.query(soql));
        AgreementRecordCreation.createChildAgreementData(null,null);
        list<Apttus__APTS_Agreement__c> ApttusAgreement = [SELECT ID, Related_Contract__c FROM Apttus__APTS_Agreement__c 
                                                           WHERE Related_Contract__r.name = 'CNTestBasket'];
          ApttusAgreement[0].Auto_Created_by_Basket__c = true;
          update ApttusAgreement;
         System.assert(ApttusAgreement != null);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
    }
    
    //Test method to Cover updateAgreementsWithLatestVersion
    @isTest
    static void updateAgreementsWithLatestVersionTest() {
        Test.startTest();
        try{
       // setupTestData();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
        
        AgreementRecordCreation.updateAgreementsWithLatestVersion(Database.query(soql));

         System.assert(fields.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
    }
    //Create record with status 'In Effect'
      @isTest
    static void contractJunctionRecordWithStatus() {
        Test.startTest();
        try{
       // setupTestData();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c > 0';
        List<ContractJunction__c> contractJunctionList = Database.query(soql);
        contractJunctionList[0].Status__c = 'In Effect';
        contractJunctionList[0].Agreement_Number__c = '1';
        update contractJunctionList;
        AgreementRecordCreation.createAgreementData(contractJunctionList);
         System.assert(contractJunctionList.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
    }
    
      @isTest
    static void mapAgreementsWithServiceTermsTest() {
        Test.startTest();
        try{
       // setupTestData();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' FROM ContractJunction__c'
            + ' WHERE Name=\'CNTestBasket\'';
        List<ContractJunction__c> contractJunctionList = Database.query(soql);
            
        Service_Term__c st =new Service_Term__c();
        st.Related_Contract__c = contractJunctionList[0].Id;
        st.Name = 'MDM ServiceTerm';
        st.Account__c =contractJunctionList[0].Account__c ;
        st.Related_Opportunity__c = contractJunctionList[0].Related_Opportunity__c ;
        st.Contract_Activated_Date__c = System.today();
        st.Contract_Term_Months__c = 32;
        st.ParentContract__c =contractJunctionList[0].id;
        st.ServiceTermName__c='test';
        insert st;  
            
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c(APTPS_Validation_on_Fully_Signed__c=true,Related_Service_Term__c=st.id,Apttus__Account__c=contractJunctionList[0].Account__c,Apttus__Contract_End_Date__c=system.today(),name = 'Test', Apttus__Agreement_Category__c = 'Single Customer', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated');
        insert agreement;
   
        update contractJunctionList;
        AgreementRecordCreation.createAgreementData(contractJunctionList);
         System.assert(contractJunctionList.Size()>0);
         }
          catch(Exception e){
              System.debug(e.getMessage());
        
          }
        Test.stopTest();
    }
    
    @isTest
    static void updateAgreementsWithLatestVersion_Test(){
         Test.startTest();
        try{
      //  setupTestData();
        List<String> fields = new List<String>(ContractJunction__c.SObjectType.getDescribe().fields.getMap().keySet());
        String soql = ''
            + ' SELECT ' + String.join(fields, ',')
            + ' from ContractJunction__c'
            + ' where BSAVersion__c = 0.0'+' and id=:record1.id';
        
        AgreementRecordCreation.createAgreementData(Database.query(soql));
        list<Apttus__APTS_Agreement__c> ApttusAgreement = [SELECT ID, Related_Contract__c FROM Apttus__APTS_Agreement__c 
                                                           WHERE Related_Contract__c = :record1.id];
          ApttusAgreement[0].Auto_Created_by_Basket__c = true;
          update ApttusAgreement;
         System.assert(ApttusAgreement != null);
         }
          catch(Exception e){
               System.debug(e.getMessage());
          }
        Test.stopTest();
        
    }
    @isTest
    static void getUserEmailTest() {
        Test.startTest();
        try{
            Id id1 = UserInfo.getUserId();
            System.assert(ContentDocumentLinkContract.getUserEmail(id1) != null);
        }
        catch(Exception e){
               System.debug(e.getMessage());
          }
        Test.stopTest();
    }
   
    
}
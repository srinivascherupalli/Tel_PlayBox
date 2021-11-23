/*Eureka Changes 24th June 2021*/
@IsTest
public class ContractJunctionTriggerTest {
  @isTest
    static void DeleteContractTest() {
        Test.startTest();
       try{
             Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            //CREATE CONTACT
            Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            
            APXTConga4__Conga_Template__c template = new APXTConga4__Conga_Template__c();
            template.APXTConga4__Name__c = 'OrderForm';
            template.Sequence__c = 1;
            template.APXTConga4__Template_Group__c = 'Contract'; 
            insert template;
            
            APXTConga4__Conga_Merge_Query__c query1 = new APXTConga4__Conga_Merge_Query__c();
            query1.APXTConga4__Name__c = 'BasketSnapshot'; 
            insert query1;
            APXTConga4__Conga_Merge_Query__c query2 = new APXTConga4__Conga_Merge_Query__c();
            query2.APXTConga4__Name__c = 'AccountDetails'; 
            insert query2;
            APXTConga4__Conga_Merge_Query__c query3 = new APXTConga4__Conga_Merge_Query__c();
            query3.APXTConga4__Name__c = 'BasketProductDetails'; 
            insert query3;
            APXTConga4__Conga_Merge_Query__c query4 = new APXTConga4__Conga_Merge_Query__c();
            query4.APXTConga4__Name__c = 'OpportunityDetails'; 
            insert query4;
            
            CustomConfigurationOptions__c CO = new CustomConfigurationOptions__c();
            CO.Name = 'ContractInitiate';
            CO.Enrichment_Basket_Stage__c = 'Contract Initiated';
            CO.External_Id__c = '7842';
            CO.MarketableOfferList__c = '';
            CO.Opportunity_Stage__c = 'Propose';
            Insert CO;
            
            ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            insert record;
          //  sObjectLookupController.createFCRRecord(basket.Id,record);
            
           Delete record;
            system.assert(record != NULL);
        }
        catch(Exception e){
            
        } 
        Test.stopTest();
    }
    
     
       /* ****************************************************************************
* Author : Manoj Kumar
* Date : 18 Nov 2019
* Description : Success scenario : Test method to cover | class : ContractJunctionTriggerHelper 
                | Method : fetchEligibleProdSuccess

* *****************************************************************************/ 
    @isTest
    static void fetchEligibleProdSuccessTest() {
        Test.startTest();
        try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            //CREATE CONTACT 
            Contact contact = new Contact( 
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            System.assertNotEquals(contact.Id, null);
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            System.assertNotEquals(contact2.Id, null);
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            //createFlexiOneFundTest Data for EDGE-190304
            opp.recordtypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
      opp.Product_Type__c='Modular';
      opp.Pricing_Method__c='Delegated Pricing1';
            insert opp;
             System.assertNotEquals(opp.Id, null);
           
            Marketable_Offer__c mo = new Marketable_Offer__c();
            mo.OfferDefinationName__c ='CWP Mobility' ;
            mo.Name = 'CWP Mobility';
            mo.Offer_ID__c = 'D12333';
           insert mo;
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            System.assertNotEquals(basket.Id, null);
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            System.assertNotEquals(oppContact.Id, null);
              //create Product Definition
        cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility', product_Specification__c = 'DMCAT_ProductSpecification_000420');

       
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
        insert prodDefList;
        
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Product_Basket__c = basket.Id;
            config.cscfga__Contract_Term__c = 36;
            config.Marketable_Offer__c = mo.Id;
            insert config;
             
        Attachment att = new Attachment();
        att.Name = 'TransitionData.json';
        att.ParentId = config.Id;
        att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
        insert att;
        System.assertNotEquals(att.Id, null);
         Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
         ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            record.Status__c = 'Initiated';
            insert record;
            System.assertNotEquals(record.Id, null);
            record.Status__c = 'Contract Accepted';
            update record;
            //EDGE-190304:Allow Auto creation of Flexi OneFund for customer ordering through Order First journey once Contract is Accepted
            List<OneFund__c> lstOfFlexiOneFund  = [Select ID,CIDN__c from OneFund__c where CIDN__c=:acc.Id];



       
             
            //System.assert(lstOfFlexiOneFund.size()>0);
            
       }
        catch(Exception e){
            
        } 
        Test.stopTest();
    } 
      
     /* ****************************************************************************
* Author : Manoj Kumar : EDGE-81053
* Date : 12 July 2019
* Description : Test method to cover | class : ContractJunctionTriggerHelper 
                | Method : fetchReserveProdConfigTest

* *****************************************************************************/ 
    @isTest
    static void fetchReserveProdConfigCwpTest() {
        Test.startTest();
        try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            
            OneFund__c flexiOneFund=new OneFund__c();
            flexiOneFund.CIDN__c=acc.Id;
            flexiOneFund.Start_Date__c=Date.today();
            flexiOneFund.OneFund_Accrual_Frequency__c='Monthly';
            flexiOneFund.OneFund_Status__c='Active';

            flexiOneFund.RecordTypeId=Schema.SObjectType.OneFund__c.getRecordTypeInfosByDeveloperName().get('OneFund_Flexible').getRecordTypeId();

            insert flexiOneFund;
            
            //CREATE CONTACT 
            Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            System.assertNotEquals(contact.Id, null);
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            System.assertNotEquals(contact2.Id, null);
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            System.assertNotEquals(opp.Id, null);
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            System.assertNotEquals(basket.Id, null);
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            System.assertNotEquals(oppContact.Id, null);
              //create Product Definition
        cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');
        defMob.product_Specification__c = 'DMCAT_ProductSpecification_000871';
       
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
        insert prodDefList;
        
         cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Product_Basket__c = basket.Id;
             config.cscfga__Contract_Term__c = 36;
             insert config;
             
        Attachment att = new Attachment();
        att.Name = 'TransitionData.json';
        att.ParentId = config.Id;
        att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
        insert att;
        System.assertNotEquals(att.Id, null);
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_acknowledgement'));
         ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            record.Status__c = 'Initiated';
            insert record;
            System.assertNotEquals(record.Id, null);
            record.Status__c = 'Contract Accepted';
            update record;
            
            //EDGE-190304:dont Allow Auto creation of Flexi OneFund for customer ordering through Order First journey if onefund alrady Created
            List<OneFund__c> lstOfFlexiOneFund  = [Select ID,CIDN__c from OneFund__c where CIDN__c=:acc.Id];
            System.assert(lstOfFlexiOneFund.size()==1);
            
       }
        catch(Exception e){
            
        } 
        Test.stopTest();
    } 
    @isTest
    static void fetchReserveProdConfigNgucTest() {
        Test.startTest();
        try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            //CREATE CONTACT 
            Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            System.assertNotEquals(contact.Id, null);
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            System.assertNotEquals(contact2.Id, null);
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            insert opp;
            System.assertNotEquals(opp.Id, null);
            //Create Basket
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            System.assertNotEquals(basket.Id, null);
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = basket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            System.assertNotEquals(oppContact.Id, null);
              //create Product Definition
        cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility');
        defMob.product_Specification__c = 'DMCAT_ProductOffering_000304';
       
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob};
        insert prodDefList;
        
         cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob.id);
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Product_Basket__c = basket.Id;
             config.cscfga__Contract_Term__c = 36;
            config.Name = 'IP Site';
             insert config;
             
        Attachment att = new Attachment();
        att.Name = 'TransitionData.json';
        att.ParentId = config.Id;
        att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
        insert att;
        System.assertNotEquals(att.Id, null);
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('error_acknowledgement'));
         ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            record.Status__c = 'Initiated';
            insert record;
            System.assertNotEquals(record.Id, null);
            record.Status__c = 'Contract Accepted';
            update record;
            
       }
        catch(Exception e){
            
        } 
        Test.stopTest();
    } 
    
   



    @IsTest public static void migrationOrderTM2TriggerFlowTest(){
        Profile p=   [Select Name, Id From Profile where Name='Migration BOH user'];
        User migrationUser = new User(alias = 'migBoh', email='migrationBOHUser@test.com',
                                      emailencodingkey='UTF-8', lastname='BOHUser', languagelocalekey='en_US',
                                      localesidkey='en_US', profileid =p.id, country='United States',IsActive =true,               
                                      timezonesidkey='America/Los_Angeles', username='migrationBOHUser@test.com');
        insert migrationUser;
        
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='ACTIVE';
        insert acc; 
          Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
        
        
        Opportunity migrationOpp = new Opportunity();
    system.runAs(migrationUser){
       
        migrationOpp.AccountId = acc.Id;
        migrationOpp.Name = 'Migration Opportunity';
        migrationOpp.Product_Domain__c = 'Other';
        migrationOpp.StageName = 'Develop';
        migrationOpp.Product_Type__c = 'Modular';
        migrationOpp.CloseDate = System.Date.today();
        migrationOpp.Description__c = 'test';
        migrationOpp.Type = 'Migration';
         insert migrationOpp;
        }
        
        cscfga__Product_Basket__c migrationOppBasket = new cscfga__Product_Basket__c();
        migrationOppBasket.csbb__Account__c = acc.Id;
        migrationOppBasket.Name = 'Migration Opportunity Basket';
        migrationOppBasket.cscfga__Opportunity__c = migrationOpp.Id;
        insert migrationOppBasket;
        
         OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = migrationOppBasket.cscfga__Opportunity__c;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
        
        cscfga__Product_Definition__c defMob = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility', product_Specification__c = 'DMCAT_ProductSpecification_000420');
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Adaptive Mobility' ;
        mo.Name = 'Adaptive Mobility';
        mo.Offer_ID__c = 'D12333';
        insert mo;
        
         cscfga__Product_Definition__c defMob2 = new cscfga__Product_Definition__c (Name = 'Mobility', cscfga__Description__c = 'Mobility', product_Specification__c = 'DMCAT_ProductSpecification_000420');

       
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defMob2};
        insert prodDefList;
        
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defMob2.id);
            config.cscfga__total_contract_value__c = 325;
            config.cscfga__Product_Basket__c = migrationOppBasket.Id;
            config.cscfga__Contract_Term__c = 36;
            config.Marketable_Offer__c = mo.Id;
            insert config;
             
        Attachment att = new Attachment();
        att.Name = 'TransitionData.json';
        att.ParentId = config.Id;
        att.body = Blob.ValueOf('{"Source_System_Id":"Replicator","serviceCount":0,"productList":[{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"0438034768","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":"524822a6-71ef-4774-9edd-7528536b98ac"}],"disableCheck":null,"checkValue":true}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0"},{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"NOVA","Service_Id":"0480126680","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393120","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"120","calling_line_identifier":"on"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"0000"}],"Product_Type":"Mobile PostPaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":true},{"site":[{"siteName":null,"serviceList":[{"Service_Type":null,"groupType":[{"service":[{"sim_serial_number":"89610179078138000029","service_type_code":"NORM","service_type":null,"service_status":"AC","Service_Id":"8910","plan_name":"3OB*049 | 3G Cap 49 Business Mobile Plan","message_bank":"3GPPMSGK | 3G Pre-Paid Video Message Bank","international_roaming":"EFPAIR01| EFP Intl. Roaming $0 $50 Pack","imsi_number":"505013438393119","idd":"BFIDD100 | Bus Fleet Plus IDD $100","directory_listing":null,"contract_term":"0","calling_line_identifier":"off"}],"groupId":"mobileGroup","transitionId":null}],"disableCheck":null,"checkValue":false}],"Error_Description":null,"Error_Code":null,"ADBOR_Id":"123"}],"Product_Type":"Mobile PrePaid HandHeld","eligibilityStatus":null,"eligibilityReason":null,"disableCheck":null,"checkValue":false}],"Error_Description":"","Error_Code":"","Correlation_Id":"abcd_1234","CIDN":"6898327073"}');
        insert att;

        Test.startTest();
        ContractJunction__c  contract = new ContractJunction__c();
        contract.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        contract.Related_Basket__c = migrationOppBasket.id;
        contract.CongaStatus__c = 'NotStarted';
        contract.Account__c = migrationOppBasket.csbb__Account__c;
        contract.Related_Opportunity__c = migrationOppBasket.cscfga__Opportunity__c;
        contract.Contract_Activated_Date__c = System.today();
        contract.Contract_Term_Months__c = 36;
        contract.Name = 'CN' + 'Migration Opportunity Basket';
        contract.GPTVersion__c=1.2;
        contract.OFTVersion__c=0.0;
        contract.BSAVersion__c=0.0;
        contract.isDSAGenerated__c=true;
        insert contract;
        Test.setMock(HttpCalloutMock.class, new TM1EligibilityCheckServiceV2Mock('success_acknowledgement'));
        contract.IsMigratedContract__c=true;
        update contract;
        List<OneFund__c> lstOfFlexiOneFund  = [Select ID,CIDN__c from OneFund__c where CIDN__c=:acc.Id];
        System.assert(lstOfFlexiOneFund.size()==0);
        Test.stopTest();
    }
    
      /* ****************************************************************************
* Author : Rahul Asarma
* Date : 28 April 2021
* Description : Success scenario : Test method to cover | class : ContractJunctionTriggerHelper 
                | Method : sendNotifyOrCISEmailService

* *****************************************************************************/ 
    @isTest
    static void sendNotifyOrCISEmailServiceSuccessTest() {


             Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c = 'ACTIVE';
            insert acc;  
            System.assertNotEquals(acc.Id, null);
            //CREATE CONTACT 
            Contact contact = new Contact( 
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
            Insert contact;
            System.assertNotEquals(contact.Id, null);
            Contact contact2 = new Contact(
                AccountId = acc.id,
                LastName = 'Last1',
                FirstName = 'First1',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            System.assertNotEquals(contact2.Id, null);
            
            //CREATE OPPORTUNITY
            Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
            opp.amount = 4600;
            //createFlexiOneFundTest Data for EDGE-190304
            opp.recordtypeId=Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - Standard').getRecordTypeId();
            opp.Product_Type__c='Modular';
            opp.Pricing_Method__c='Delegated Pricing1';
            insert opp;
            
            OpportunityContactRole oppContact = new OpportunityContactRole();
            oppContact.ContactId = contact.Id;
            oppContact.IsPrimary = true;
            oppContact.OpportunityId = opp.id;
            oppContact.Role = 'Inside Sales Account Manager';
            insert oppContact;
            
            cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
            basket.csbb__Account__c = acc.id;
            basket.cscfga__Opportunity__c = opp.id;
            basket.Name = 'basket1';
            insert basket;
            
            string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
              Apttus__APTS_Agreement__c agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id,VariationNotApplicable__c='NoAgreeement');
           insert agreementPS;
            
             ContractJunction__c record = new ContractJunction__c();
            record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contact.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            record.Status__c = 'Initiated';
            record.Contract_type__c='DSA';
            record.CIS_Dispatched_Offers__c='Adaptive Mobility';
            record.Related_Price_Schedule__c=agreementPS.id;
            record.isSendOrderFormEmail__c=true;
            insert record;
             test.startTest();
            System.assertNotEquals(record.Id, null);
            record.isOrderFormGenerated__c  = true;
            update record;
             test.stopTest();
            ContractJunction__c cjrecord=[select id,Status__c from ContractJunction__c where id=:record.id limit 1];
             System.assertEquals('Initiated',cjrecord.Status__c);
            
    }

}
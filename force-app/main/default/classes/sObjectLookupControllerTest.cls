/*1.            Payal                   5/2/2021                EDGE-198027 Change Async Process of createOLI from future to batch 
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 09-17-2021
 * @last modified by  : LokeshThathuru@team.telstra.com
**/

@IsTest
public class sObjectLookupControllerTest {
    @isTest
    static void SearchLookupMethodSOQL() {
        Test.startTest();
        try{
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c='Active';
            insert acc;  
            //CREATE CONTACT 
            
        Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.allowSave = true;
        dml.DuplicateRuleHeader.runAsCurrentUser = true;
        Contact contact = new Contact(
                AccountId = acc.id,
                LastName = 'Last',
                FirstName = 'First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test@tele2.com'   
            );
        Database.SaveResult sr = Database.insert(contact, dml);
        if (sr.isSuccess()) {
            System.debug('Duplicate account has been inserted in Salesforce!');
        }
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
            
            /* list<String> fieldAPIName = new list<String>();
            fieldAPIName.add('Name'); */
            list<String> moreFields = new list<String>();
            moreFields.add('Email');
            String searchString = '';
            sObjectLookupController.searchRecord('User', 'Name', moreFields, 'test', 5, searchString, '');
            String rawSOQLcriteria = '( Roles= "Full Authority" OR Roles = "Legal" Lessee Order By Contact.Name ASC';
            List<sObject> objectList =sObjectLookupController.searchRecord('User', 'Name', moreFields, 'test', 5, rawSOQLcriteria, '');
            system.assert(objectList!=null);
        } catch (Exception e) {
            
        }
        Test.stopTest();
    }
    @isTest
    static void SearchLookupMethodPRM() {
        
        //   try{
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c='Active';
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
        
        List<cscfga__Product_Configuration__c> testConfigList= new List<cscfga__Product_Configuration__c>();
        
        cscfga__Product_Configuration__c testConfigReplaced = new cscfga__Product_Configuration__c();
        testConfigReplaced.Name = 'replacedConfigTEST';
        testConfigReplaced.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced.cscfga__total_recurring_charge__c = 5;
        testConfigReplaced.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced;
        
        cscfga__Product_Configuration__c testConfigReplaced2 = new cscfga__Product_Configuration__c();
        testConfigReplaced2.Name = 'replacedConfigTEST2';
        testConfigReplaced2.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced2.cscfga__total_recurring_charge__c = 6;
        testConfigReplaced2.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced2;
        
        cscfga__Product_Configuration__c testConfigRoot = new cscfga__Product_Configuration__c();
        testConfigRoot.Name = 'rootConfigTEST';
        testConfigRoot.cscfga__Product_Basket__c = basket.Id;
        testConfigRoot.Incremental_Revenue__c = 0;
        testConfigRoot.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced2.Id;
        testConfigRoot.cscfga__total_recurring_charge__c = 7;
        testConfigRoot.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigRoot);
        
        cscfga__Product_Configuration__c testConfigNew = new cscfga__Product_Configuration__c();
        testConfigNew.Name = 'newConfigTEST';
        testConfigNew.cscfga__Product_Basket__c = basket.Id;
        testConfigNew.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced.Id;
        testConfigNew.cscfga__total_recurring_charge__c = 6;
        testConfigNew.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigNew);
        
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = oppContact.contact.Email;
        record.Phone__c = oppContact.contact.MobilePhone;
        record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.DocuSign_Signer_2__c = UserInfo.getUserId();
        record.DocuSign_Signer_3__c = UserInfo.getUserId();
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.BSA_Generated__c =true;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
        
        insert testConfigList;
        
     User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'user@mail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            
        );
        insert u;
        
        

         Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = opp.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Deal_Status__c='In Effect';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
           
          
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
        
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id ; 
        dOffer.Name = 'Test';
        dOffer.Marketable_Offer__c=Marketoffer.Id;
        dOffer.Minimum_Spent_per_Month_Manual__c=100;
        //dOffer.Total_Spend_over_Contract_Term__c =    10;
        dOffer.PF_Contract_Term__c=20;
        insert dOffer ;
        
        List<cspmb__Price_Item__c> cpList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c cProduct = new cspmb__Price_Item__c();
        cProduct.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProduct.cspmb__Recurring_Charge__c = 18.18;
        cProduct.Type__c = 'Handheld';
        cpList.add(cProduct);
        
        cspmb__Price_Item__c cProducta = new cspmb__Price_Item__c();
        cProducta.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProducta.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProducta.cspmb__Recurring_Charge__c = 18.18;
        cProducta.Type__c = 'Enterprise Wireless';
        cpList.add(cProducta);
        
        cspmb__Price_Item__c cProductb = new cspmb__Price_Item__c();
        cProductb.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProductb.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        cProductb.cspmb__Recurring_Charge__c = 18.18;
        cProductb.Type__c = 'Mobile Broadband';
        cpList.add(cProductb);
        
        cspmb__Price_Item__c cProduct1 = new cspmb__Price_Item__c();
        cProduct1.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct1.ChargeType__c = 'OC'; //EDGE-177567
        cProduct1.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct1.cspmb__Recurring_Charge__c = 18.18;
        cpList.add(cProduct1);
        
        cspmb__Price_Item__c cProduct2 = new cspmb__Price_Item__c();
        cProduct2.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct2.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct2.ChargeType__c = 'RC'; //EDGE-177567
        cProduct2.cspmb__One_Off_Charge__c = 18.18;
        cpList.add(cProduct2);
        
        insert cpList;
        
        //DIGI-434 - Start
        List<DPR_Offer_Line_Item__c> dprList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprLineItemHH = New DPR_Offer_Line_Item__c();
        dprLineItemHH.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH.Quantity__c = 5;
        dprLineItemHH.List_Price__c =40;
        dprLineItemHH.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemHH.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemHH.Overridden_Total_Price__c = 150 ;
        dprLineItemHH.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemHH);
        
        
        
        DPR_Offer_Line_Item__c dprLineItemWLS = New DPR_Offer_Line_Item__c();
        dprLineItemWLS.cspmb_Price_Item__c = cpList[1].Id; 
        dprLineItemWLS.Quantity__c = 5;
        dprLineItemWLS.List_Price__c =40;
        dprLineItemWLS.DPR_Offer__c = dOffer.Id ;   
        dprLineItemWLS.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemWLS.DPR_Offer_line_item_value__c = 35;
        dprLineItemWLS.Offer_Type_Name__c = 'Enterprise Wireless';
        dprLineItemWLS.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemWLS.Overridden_Total_Price__c = 175;
        //   dprLineItemWLS.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemWLS);
        
        DPR_Offer_Line_Item__c dprLineItemMBB = New DPR_Offer_Line_Item__c();
        dprLineItemMBB.cspmb_Price_Item__c = cpList[2].Id; 
        dprLineItemMBB.Quantity__c = 5;
        dprLineItemMBB.List_Price__c =40;
        dprLineItemMBB.DPR_Offer__c = dOffer.Id ; 
        dprLineItemMBB.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemMBB.DPR_Offer_line_item_value__c = 20;
        dprLineItemMBB.Offer_Type_Name__c = 'Mobile Broadband';
        dprLineItemMBB.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemMBB.Overridden_Total_Price__c = 100;
        dprLineItemMBB.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemMBB);
        
        
        
        DPR_Offer_Line_Item__c dprLineItem2 = New DPR_Offer_Line_Item__c();
        dprLineItem2.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem2.Quantity__c = 15;
        dprLineItem2.List_Price__c =25;
        dprLineItem2.DPR_Offer__c = dOffer.Id ; 
         dprLineItem2.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem2.DPR_Offer_line_item_value__c = 30;
        dprLineItem2.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem2.Overridden_Total_Price__c = 750;
        dprLineItem2.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem2);
        
        DPR_Offer_Line_Item__c dprLineItem4 = New DPR_Offer_Line_Item__c();
        dprLineItem4.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem4.Quantity__c = 15;
        dprLineItem4.List_Price__c =25;
        dprLineItem4.DPR_Offer__c = dOffer.Id ; 
        dprLineItem4.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem4.DPR_Offer_line_item_value__c = 30;
        dprLineItem4.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem4.Overridden_Total_Price__c = 750;
        dprLineItem4.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem4);
        
        DPR_Offer_Line_Item__c dprLineItem1 = New DPR_Offer_Line_Item__c();
        dprLineItem1.cspmb_Price_Item__c = cpList[3].Id; 
        //  dprLineItem1.cspmb_Add_On_Price_Item__c = ofcpList[0].Id;
        dprLineItem1.Quantity__c = 5;
        dprLineItem1.List_Price__c =25;
        dprLineItem1.DPR_Offer__c = dOffer.Id ;
        dprLineItem1.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem1.Overridden_Total_Price__c = 124;
        //  dprLineItem1.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        dprList.add(dprLineItem1);
        
        DPR_Offer_Line_Item__c dprLineItem3 = New DPR_Offer_Line_Item__c();
        dprLineItem3.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem3.Quantity__c = 15;
        dprLineItem3.List_Price__c =25;
        dprLineItem3.DPR_Offer__c = dOffer.Id ;
        dprLineItem3.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem3.DPR_Offer_line_item_value__c = 30;
        dprLineItem3.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem3.Overridden_Total_Price__c = 750;
        dprList.add(dprLineItem3);
        insert dprList ; 
        
       
        //List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:insertDelegatedPricingRequest.id];
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
       
        Test.startTest();
            boolean isPRMuser = sObjectLookupController.userInfoPRM(); 
            system.assert(isPRMuser!=null);
            String response = sObjectLookupController.createRecord(basket.Id, contact.Id, Userinfo.getProfileid(),false,null);
            system.assert(response!=null);
            csconta__Frame_Agreement__c fam = new csconta__Frame_Agreement__c();
            fam.csconta__Status__c = 'Contract Initiated';
            fam.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
            fam.Opportunity__c=opp.id;
            insert fam;    
            //EDGE-190520 FAM Contract Initiation
            /*FA_DefaultRecipients__c fa = new FA_DefaultRecipients__c();
            fa.Signatory_1__c = Contact.Id;
            fa.Signatory_2__c = u.Id;
            insert fa;*/
            //sObjectLookupController.toCheckSyncJobCompletion();
            sObjectLookupController.createRecordFA(Fam.Id, Contact.Id, u.Id,null);// DIGI-434 Exception
           // sObjectLookupController.createRecordFA(Fam.Id, null, null,null);
    //    } catch (Exception e) {
            
    //    }
        Test.stopTest();
    }
    @isTest
    static void SearchLookupMethodPRMNull() {
       
       
            //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c='Active';
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
         
        
        List<cscfga__Product_Configuration__c> testConfigList= new List<cscfga__Product_Configuration__c>();
        
        cscfga__Product_Configuration__c testConfigReplaced = new cscfga__Product_Configuration__c();
        testConfigReplaced.Name = 'replacedConfigTEST';
        testConfigReplaced.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced.cscfga__total_recurring_charge__c = 5;
        testConfigReplaced.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced;
        
        cscfga__Product_Configuration__c testConfigReplaced2 = new cscfga__Product_Configuration__c();
        testConfigReplaced2.Name = 'replacedConfigTEST2';
        testConfigReplaced2.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced2.cscfga__total_recurring_charge__c = 6;
        testConfigReplaced2.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced2;
        
        cscfga__Product_Configuration__c testConfigRoot = new cscfga__Product_Configuration__c();
        testConfigRoot.Name = 'rootConfigTEST';
        testConfigRoot.cscfga__Product_Basket__c = basket.Id;
        testConfigRoot.Incremental_Revenue__c = 0;
        testConfigRoot.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced2.Id;
        testConfigRoot.cscfga__total_recurring_charge__c = 7;
        testConfigRoot.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigRoot);
        
        cscfga__Product_Configuration__c testConfigNew = new cscfga__Product_Configuration__c();
        testConfigNew.Name = 'newConfigTEST';
        testConfigNew.cscfga__Product_Basket__c = basket.Id;
        testConfigNew.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced.Id;
        testConfigNew.cscfga__total_recurring_charge__c = 6;
        testConfigNew.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigNew);
        
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = oppContact.contact.Email;
        record.Phone__c = oppContact.contact.MobilePhone;
        record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.DocuSign_Signer_2__c = UserInfo.getUserId();
        record.DocuSign_Signer_3__c = UserInfo.getUserId();
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.BSA_Generated__c =true;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
        
        insert testConfigList;
        
     User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'user@mail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            
        );
        insert u;
        

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = opp.id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Deal_Status__c='In Effect';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
        
          
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
        
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id ; 
        dOffer.Name = 'Test';
        dOffer.Marketable_Offer__c=Marketoffer.Id;
        dOffer.Minimum_Spent_per_Month_Manual__c=100;
        //dOffer.Total_Spend_over_Contract_Term__c =    10;
        dOffer.PF_Contract_Term__c=20;
        insert dOffer ;
        
        List<cspmb__Price_Item__c> cpList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c cProduct = new cspmb__Price_Item__c();
        cProduct.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProduct.cspmb__Recurring_Charge__c = 18.18;
        cProduct.Type__c = 'Handheld';
        cpList.add(cProduct);
        
        cspmb__Price_Item__c cProducta = new cspmb__Price_Item__c();
        cProducta.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProducta.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProducta.cspmb__Recurring_Charge__c = 18.18;
        cProducta.Type__c = 'Enterprise Wireless';
        cpList.add(cProducta);
        
        cspmb__Price_Item__c cProductb = new cspmb__Price_Item__c();
        cProductb.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProductb.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        cProductb.cspmb__Recurring_Charge__c = 18.18;
        cProductb.Type__c = 'Mobile Broadband';
        cpList.add(cProductb);
        
        cspmb__Price_Item__c cProduct1 = new cspmb__Price_Item__c();
        cProduct1.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct1.ChargeType__c = 'OC'; //EDGE-177567
        cProduct1.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct1.cspmb__Recurring_Charge__c = 18.18;
        cpList.add(cProduct1);
        
        cspmb__Price_Item__c cProduct2 = new cspmb__Price_Item__c();
        cProduct2.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct2.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct2.ChargeType__c = 'RC'; //EDGE-177567
        cProduct2.cspmb__One_Off_Charge__c = 18.18;
        cpList.add(cProduct2);
        
        insert cpList;
        
        //DIGI-434 - Start
        List<DPR_Offer_Line_Item__c> dprList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprLineItemHH = New DPR_Offer_Line_Item__c();
        dprLineItemHH.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH.Quantity__c = 5;
        dprLineItemHH.List_Price__c =40;
        dprLineItemHH.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemHH.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemHH.Overridden_Total_Price__c = 150 ;
        dprLineItemHH.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemHH);
        
        
        
        DPR_Offer_Line_Item__c dprLineItemWLS = New DPR_Offer_Line_Item__c();
        dprLineItemWLS.cspmb_Price_Item__c = cpList[1].Id; 
        dprLineItemWLS.Quantity__c = 5;
        dprLineItemWLS.List_Price__c =40;
        dprLineItemWLS.DPR_Offer__c = dOffer.Id ;   
        dprLineItemWLS.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemWLS.DPR_Offer_line_item_value__c = 35;
        dprLineItemWLS.Offer_Type_Name__c = 'Enterprise Wireless';
        dprLineItemWLS.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemWLS.Overridden_Total_Price__c = 175;
        //   dprLineItemWLS.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemWLS);
        
        DPR_Offer_Line_Item__c dprLineItemMBB = New DPR_Offer_Line_Item__c();
        dprLineItemMBB.cspmb_Price_Item__c = cpList[2].Id; 
        dprLineItemMBB.Quantity__c = 5;
        dprLineItemMBB.List_Price__c =40;
        dprLineItemMBB.DPR_Offer__c = dOffer.Id ; 
        dprLineItemMBB.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemMBB.DPR_Offer_line_item_value__c = 20;
        dprLineItemMBB.Offer_Type_Name__c = 'Mobile Broadband';
        dprLineItemMBB.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemMBB.Overridden_Total_Price__c = 100;
        dprLineItemMBB.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemMBB);
        
        
        
        DPR_Offer_Line_Item__c dprLineItem2 = New DPR_Offer_Line_Item__c();
        dprLineItem2.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem2.Quantity__c = 15;
        dprLineItem2.List_Price__c =25;
        dprLineItem2.DPR_Offer__c = dOffer.Id ; 
         dprLineItem2.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem2.DPR_Offer_line_item_value__c = 30;
        dprLineItem2.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem2.Overridden_Total_Price__c = 750;
        dprLineItem2.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem2);
        
        DPR_Offer_Line_Item__c dprLineItem4 = New DPR_Offer_Line_Item__c();
        dprLineItem4.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem4.Quantity__c = 15;
        dprLineItem4.List_Price__c =25;
        dprLineItem4.DPR_Offer__c = dOffer.Id ; 
        dprLineItem4.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem4.DPR_Offer_line_item_value__c = 30;
        dprLineItem4.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem4.Overridden_Total_Price__c = 750;
        dprLineItem4.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem4);
        
        DPR_Offer_Line_Item__c dprLineItem1 = New DPR_Offer_Line_Item__c();
        dprLineItem1.cspmb_Price_Item__c = cpList[3].Id; 
        //  dprLineItem1.cspmb_Add_On_Price_Item__c = ofcpList[0].Id;
        dprLineItem1.Quantity__c = 5;
        dprLineItem1.List_Price__c =25;
        dprLineItem1.DPR_Offer__c = dOffer.Id ;
        dprLineItem1.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem1.Overridden_Total_Price__c = 124;
        //  dprLineItem1.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        dprList.add(dprLineItem1);
        
        DPR_Offer_Line_Item__c dprLineItem3 = New DPR_Offer_Line_Item__c();
        dprLineItem3.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem3.Quantity__c = 15;
        dprLineItem3.List_Price__c =25;
        dprLineItem3.DPR_Offer__c = dOffer.Id ;
        dprLineItem3.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem3.DPR_Offer_line_item_value__c = 30;
        dprLineItem3.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem3.Overridden_Total_Price__c = 750;
        dprList.add(dprLineItem3);
        insert dprList ; 
        
       
        //List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:insertDelegatedPricingRequest.id];
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        Test.startTest();
        
        boolean isPRMuser = sObjectLookupController.userInfoPRM(); 
        system.assert(isPRMuser!=null);
        String response = sObjectLookupController.createRecord(basket.Id, contact.Id, Userinfo.getProfileid(),false,null);
        system.assert(response!=null);
        csconta__Frame_Agreement__c fam = new csconta__Frame_Agreement__c();
        fam.csconta__Status__c = 'Contract Initiated';
        fam.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        fam.Opportunity__c=opp.id;
        insert fam;   
        
        sObjectLookupController.createRecordFA(Fam.Id, null, null,null); //DIGI-434 Exception Handling
        Test.stopTest();
    }
    @isTest
    static void SearchLookupMethodUpdateBasket() {
        Test.startTest();
      //     try{
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
               acc.Customer_Status__c='Active';
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
        Account accExternal = AccountTestFactory.buildAccount('Test Account External') ;
        insert accExternal;  
        Contact contactExternal = new Contact(
            AccountId = accExternal.id,
            LastName = 'TEST Last',
            FirstName = 'TEST First',
            Contact_Role__c = 'Consultant1',
            MobilePhone = '+61123456789',
            Email = 'test1@tele2.com'   
        );
        Insert contactExternal;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Draft';       
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
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = contactExternal.Id;
        ACR.AccountId = acc.Id;
        ACR.Contact_Usage__c = 'Business';
        ACR.Job_Description__c = 'Administrative';
        ACR.Seniority_Level__c = 'Chief Customer Officer'; 
        ACR.Relationship_Verified_Date__c = System.today();
        ACR.Roles = 'Legal Lessee'; 
        Insert ACR;
        
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
        record.DocuSign_Signer_2__c = contactExternal.id;
        record.DocuSign_Signer_3__c = UserInfo.getUserId();
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
        
        //Added By Pooja Bhat
        sObjectLookupController.updateBasketStage(basket.Id, record.Id);
        List<cscfga__Product_Basket__c> updatedbasket =   [SELECT csordtelcoa__Basket_Stage__c,csordtelcoa__Synchronised_with_Opportunity__c,Primary_Basket__c FROM cscfga__Product_Basket__c WHERE Id=:basket.Id LIMIT 1];
        System.assertEquals('Contract Initiated',updatedbasket[0].csordtelcoa__Basket_Stage__c);
        //System.assertEquals(true,updatedbasket[0].csordtelcoa__Synchronised_with_Opportunity__c);
        //sObjectLookupController.createFCRRecord(basket.Id,record);
        
        /*-- EDGE-66515 :  Default contract recipient as Order requestor for Modify and Cancel orders --*/
        sObjectLookupController.OnloadCustomerContractSignatory(basket.csbb__Account__c,basket.cscfga__Opportunity__c,'PureModify');
      //  sObjectLookupController.updateBasketStage(basket.Id,record.Id); 
               system.debug('*****>'+basket);
        system.assert(basket.csordtelcoa__Basket_Stage__c!=null);

      //  } catch (Exception e) {
        
      //    }
        Test.stopTest();
    }
    
     @isTest
    static void SearchLookupMethodUpdateBasketOpp() {
        Test.startTest();
      //     try{
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
               acc.Customer_Status__c='Active';
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
        Account accExternal = AccountTestFactory.buildAccount('Test Account External') ;
        insert accExternal;  
        Contact contactExternal = new Contact(
            AccountId = accExternal.id,
            LastName = 'Test Last',
            FirstName = 'Test First',
            Contact_Role__c = 'Consultant1',
            MobilePhone = '+61123456789',
            Email = 'test1@tele2.com'   
        );
        Insert contactExternal;
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;
        insert opp;
        
        //Create Basket
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        basket.csordtelcoa__Basket_Stage__c = 'Draft';       
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
        
        AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = contactExternal.Id;
        ACR.AccountId = acc.Id;
        ACR.Contact_Usage__c = 'Business';
        ACR.Job_Description__c = 'Administrative';
        ACR.Seniority_Level__c = 'Chief Customer Officer'; 
        ACR.Roles = 'Legal Lessee'; 
        ACR.Relationship_Verified_Date__c = System.today();
        Insert ACR;
        
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
        record.DocuSign_Signer_2__c = contactExternal.id;
        record.DocuSign_Signer_3__c = UserInfo.getUserId();
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
     //   sObjectLookupController.updateBasketStage(basket.Id,record.Id); 
               system.debug('*****>'+basket);
        system.assert(basket.csordtelcoa__Basket_Stage__c!=null);
     //   } catch (Exception e) {
        
     //     }
        Test.stopTest();
    }
    
    @isTest
    static void organizationInfoTest() {
        Test.startTest();
    //    try{
            String OrgDetail = sObjectLookupController.organizationInfo();
            system.assert(OrgDetail != '');
   //     } catch (Exception e) {
            
   //     }
        Test.stopTest();
    }
    
    @isTest
    static void searchRecordWithSequenceTest() {
     //   Test.startTest();
     //   try{
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c='Active';
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
                LastName = 'Test Last',
                FirstName = 'Test First',
                Contact_Role__c = 'Consultant',
                MobilePhone = '+61123456789',
                Email = 'test0@tele2.com'   
            );
            Insert contact2;
            
            Account accExternal = AccountTestFactory.buildAccount('Test Account External') ;
            insert accExternal;  

            
            Contact contactExternal = new Contact(
                AccountId = accExternal.id,
                LastName = 'Test Last123',
                FirstName = 'Test First123',
                Contact_Role__c = 'Consultant1',
                MobilePhone = '+61123456789',
                Email = 'test1@tele2.com'   
            );
            insert contactExternal;
            


            
            
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
        
        
                AccountContactRelation ACR = new AccountContactRelation();
        ACR.ContactId = contactExternal.Id;
        ACR.AccountId = acc.Id;
        ACR.Contact_Usage__c = 'Business';
        ACR.Job_Description__c = 'Administrative';
        ACR.Seniority_Level__c = 'Chief Customer Officer'; 
        ACR.Roles = 'Full Authority'; 
        ACR.Relationship_Verified_Date__c = System.today();
        Insert ACR;
            
            ContractJunction__c record = new ContractJunction__c();
            //record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Contract Role').getRecordTypeId();
            record.Email__c = oppContact.contact.Email;
            record.Phone__c = oppContact.contact.MobilePhone;
            record.Customer_Primary_Contact__c = oppContact.ContactId;
            record.Related_Basket__c = basket.id;
            record.DocuSign_Signer_2__c = contactExternal.id;
            record.DocuSign_Signer_3__c = UserInfo.getUserId();
            record.CongaStatus__c = 'NotStarted';
            record.Account__c = basket.csbb__Account__c;
            record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
            record.Contract_Activated_Date__c = System.today();
            record.Contract_Term_Months__c = 36;
            record.Name = 'CN' + basket.Name.substring(2);
            insert record;
    Test.startTest();   
            sObjectLookupController.createFCRRecord(basket.Id,record);
            
            /* list<String> fieldAPIName = new list<String>();
fieldAPIName.add('Name'); */
            list<String> moreFields = new list<String>();
            moreFields.add('Roles');
            String searchString = '';
            String rawSOQLcriteria = '( Roles != \'Full Authority\' OR Roles = \'Legal Lessee\') Order By Contact.Name ASC';
            List<sobjectwrapperclass> sobjectwrapperList = sObjectLookupController.searchRecordWithSequence('AccountContactRelation', 'Contact_Name', moreFields, '', 5, rawSOQLcriteria, '');
            system.assert(sobjectwrapperList.size()!= 0);
    //    } catch (Exception e) {

    //    }
        Test.stopTest();
    }
    @isTest
    static void TestSiteSQWebCallout() {
        Test.startTest();

        EnvironmentVariable__c env_var =  new EnvironmentVariable__c();
        env_var.name = 'ValidationIPUCE';
        env_var.value__c = '1';
        insert env_var;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
        insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
        insert prod;

        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        List<PricebookEntry> testpbeList = new List<PricebookEntry> {standardPBE, pbe};
        insert testpbeList;
        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c='Active';
        acc.Customer_Status__c = 'ACQUIRED';

        Account acc2 = new Account(Name = 'Test Account for CBQ 2');
        acc2.Customer_Status__c='Active';
        acc2.Customer_Status__c = 'ACQUIRED';

        List<Account> accList = new List<Account> {acc, acc2};
        insert accList;

        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';

        Opportunity opp2 = ProductTestFactory.getOpportunity(acc2, pb);
        opp2.StageName = 'Develop';
        opp2.Product_Type__c = 'Modular';
        opp2.Name = 'TestingOppError';

        Opportunity opp3 = ProductTestFactory.getOpportunity(acc2, pb);
        opp3.StageName = 'Develop';
        opp3.Product_Type__c = 'Modular';
        opp3.Name = 'TestingOppError2';

        Opportunity opp4 = ProductTestFactory.getOpportunity(acc, pb);
        opp4.StageName = 'Develop';
        opp4.Product_Type__c = 'Modular';
        opp4.Name = 'TestingOpp4';

        List<Opportunity> oppList = new List<Opportunity> {opp, opp2, opp3, opp4};
        insert oppList;

        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        c.Email = 'test@mailinator.com'; 
        INSERT c;

        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';

        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = c.Id;
        ocr2.OpportunityId = opp2.Id;
        ocr2.IsPrimary = TRUE;
        ocr2.Role = 'Decision Maker';

        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.ContactId = c.Id;
        ocr3.OpportunityId = opp4.Id;
        ocr3.IsPrimary = TRUE;
        ocr3.Role = 'Decision Maker';

        List<OpportunityContactRole> testOCRList = new List<OpportunityContactRole> {ocr, ocr2, ocr3};
        INSERT testOCRList;

        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';

        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.csbb__Account__c = acc2.Id;
        basket2.Description__c = 'testBasketforCBQ';

        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket3.cscfga__Opportunity__c = opp2.id;
        basket3.csbb__Account__c = acc2.Id;
        basket3.Description__c = 'secondaryTestBasketforCBQ';
        basket3.Primary_Basket__c = true;
            
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c();
        basket4.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket4.cscfga__Opportunity__c = opp3.id;
        basket4.csbb__Account__c = acc2.Id;
        basket4.Description__c = 'testBasketforCBQError';

        cscfga__Product_Basket__c basket5 = new cscfga__Product_Basket__c();
        basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket5.cscfga__Opportunity__c = opp4.id;
        basket5.csbb__Account__c = acc.Id;
        basket5.Description__c = 'testDiscDate';

        cscfga__Product_Basket__c basket6 = new cscfga__Product_Basket__c();
        basket6.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket6.cscfga__Opportunity__c = opp4.id;
        basket6.csbb__Account__c = acc.Id;
        basket6.Description__c = 'testBasketQuote';
        basket6.Primary_Basket__c = true;

        List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c> {basket, basket2, basket3, basket4, basket5, basket6};
        insert testBasketList;

        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);

        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);

        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );

        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c> {defIpSite, defIpNetwork, defUcEnterprise};
        insert prodDefList;

        cscfga__Attribute_Definition__c atrDef = ProductTestFactory.buildAttributeDefinition('test', defIpSite.id);
        atrDef.cscfga__is_Significant__c = true;
        insert atrDef;

        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        //List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>();
        for (Integer i = 0; i < 15; i++) {
            //cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defIpSite.id);
            config.cscfga__total_contract_value__c = 325;
            config.Technology_Type__c = 'NBN Access';
            String confName = System.Label.Label_CWP;
            config.cscfga__Product_Definition__c = defIpSite.Id;

            if ( i == 8 || i == 10 || i == 13 ) {
                confName = System.Label.IP_Network;
                config.cscfga__Product_Definition__c = defIpNetwork.Id;
            } else if ( i == 9 || i == 11 || i == 14) {
                confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            if (i == 6 || i == 7 || i == 10 || i == 11) {
                config.cscfga__Product_Basket__c = basket2.id;
            } else if (i == 4 || i == 5 || i == 13 || i == 14 ) {
                config.cscfga__Product_Basket__c = basket5.id;
            } else {
                config.cscfga__Product_Basket__c = basket.id;
              
            }
            config.Name = confName;
            config.cscfga__Description__c = 'test Description ' + i;
            config.cscfga__Contract_Term__c = 36;
            config.Type__c = 'Modify';
            if  (i == 4 || i == 5) {
                config.Type__c = 'Cancel';
                config.Name = 'IP Site';
        } 
            config.Name = 'IP Site';
            prodConfigList.add(config);
        }
        cscfga__Product_Category__c prodcat = ProductTestFactory.buildProductCategory();
        insert prodcat;

        insert prodConfigList;

        List<csbb__Callout_Product_Result__c> testCPRList = new List<csbb__Callout_Product_Result__c>();
        /***EDGE-80772 : commented for Solution Console retrofit
    List<csbb__Product_Configuration_Request__c> testProdConfReqList = new List<csbb__Product_Configuration_Request__c>();

        for (cscfga__Product_Configuration__c config : prodConfigList) {

            csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
            pcr.csbb__Product_Category__c = prodcat.id;

            pcr.csbb__Product_Configuration__c = config.id;
            pcr.csbb__Product_Basket__c = config.cscfga__Product_Basket__c;
            pcr.csbb__Total_OC__c = 25;
            pcr.csbb__Total_MRC__c = 25;

            testProdConfReqList.add(pcr);
        }

        insert testProdConfReqList;
    */
        csbb__Callout_Result__c cor = ProductTestFactory.buildCallOutResults();
        insert cor;
    /**EDGE-80772 : commented for Solution Console retrofit
        for (csbb__Product_Configuration_Request__c pcr : testProdConfReqList ) {
            csbb__Callout_Product_Result__c copr = ProductTestFactory.buildCalloutProductResults(pcr, cor);
            testCPRList.add(copr);
        }
        insert testCPRList;
    */
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for (cscfga__Product_Configuration__c config0 : prodConfigList) {
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config0.id);
            attList.add(attr0);
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config0.id);
            attList.add(attr1);
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config0.id);
            attList.add(attr2);
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config0.id);
            attList.add(attr3);
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config0.id);
            attList.add(attr4);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config0.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config0.id);
            attList.add(attr6);
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', 'testproduct', config0.id);
            attList.add(attr8);
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config0.id);
            attList.add(attr9);
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config0.id);
            attList.add(attr10);
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config0.id);
            attList.add(attr11);
            cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config0.id);
            attList.add(attr12);
            cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config0.id);
            attList.add(attr13);
            cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'FIXED TELEPHONY', config0.id);
            attList.add(attr14);
            cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config0.id);
            attList.add(attr15);
            cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config0.id);
            attList.add(attr16);
            cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config0.id);
            attList.add(attr17);
            cscfga__Attribute__c attr18 = ProductTestFactory.buildAttribute('Site Id', '123456798', config0.id);
            attList.add(attr18);
            if (config0.cscfga__Product_Basket__c == basket5.id) {
                cscfga__Attribute__c attr19 = ProductTestFactory.buildAttribute('DisconnectionDate', '', config0.id);
                attList.add(attr19);
            }
            cscfga__Attribute__c attr20 = ProductTestFactory.buildAttribute('AdborID', '123456798', config0.id);
            attList.add(attr20);

        }
        insert attList;
        System.assert(attList.Size() > 0);

        cscrm__Address__c addressRecord = AccountTestFactory.buildAddress('123456798');
        Insert addressRecord;
        System.assertNotEquals(addressRecord.Id, Null);
        cscrm__Site__c siteRecord =  AccountTestFactory.buildSite(addressRecord.Id, acc.Id);
        Insert siteRecord;
        System.assertNotEquals(siteRecord.Id, Null);

        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for (cscfga__Attribute__c attr : attList) {
            if (attr.Name == 'Product')
                newattrList.add(attr);
        }
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 2000, Quantity = 2,
                OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[0].cscfga__Description__c,
                cscfga__Attribute__c = attList[0].id, Product_Status__c = 'Lost', Product_Name__c = 'test prod');
        OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 3000, Quantity = 3,
                OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[1].cscfga__Description__c,
                cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won', Product_Name__c = 'test1');
        OpportunityLineItem oli2 = new OpportunityLineItem(pricebookentryid = pbe.Id, TotalPrice = 4000, Quantity = 4,
                OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[2].cscfga__Description__c,
                cscfga__Attribute__c = attList[2].id, Product_Status__c = 'withdrawn', Product_Name__c = 'test2');

        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem> {oli, oli1, oli2};
        insert oLIList;
        System.assert(oLIList.Size() > 0);
        cscfga__Product_Configuration__c configRec = [ SELECT id, Name, type__c, Technology_Type__c  FROM 
                                                      cscfga__Product_Configuration__c
                    WHERE cscfga__Product_Basket__c = : basket.id AND  Name = 'IP Site' AND
                           Technology_Type__c = 'NBN Access' 
                           Limit 1];
          configRec.Type__c = 'New';
          Update configRec;
        sObjectLookupController.siteSQWebCallout(basket.id, 100, 10, 0, '', accList[0].Id);
        sObjectLookupController.UpdateRelatedDataForSQSite(basket.id, '123456798');

        Test.stopTest();
    }
        @isTest
    static void siteSQWebCalloutTest() {
        Test.startTest();
        
        EnvironmentVariable__c env_var=  new EnvironmentVariable__c();
            env_var.name='ValidationIPUCE';
            env_var.value__c='1';
            insert env_var;

        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true );
            insert pb;
        Product2 prod = new Product2(Name = 'SLA: Bronze', IsActive = true);
            insert prod;
        
        PricebookEntry standardPBE = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = prod.Id, UnitPrice = 1000, IsActive = true);
        List<PricebookEntry> testpbeList = new List<PricebookEntry>{standardPBE, pbe};
        insert testpbeList;
        Account acc = new Account(Name = 'Test Account for CBQ');
        acc.Customer_Status__c='Active';
        acc.Customer_Status__c = 'ACQUIRED';
        
        Account acc2 = new Account(Name = 'Test Account for CBQ 2');
        acc2.Customer_Status__c='Active';
        acc2.Customer_Status__c = 'ACQUIRED';
        
        List<Account> accList = new List<Account>{acc, acc2};
            insert accList;
        
        Opportunity opp = ProductTestFactory.getOpportunity(acc, pb);
        opp.StageName = 'Develop';
        opp.Product_Type__c = 'Modular';
        opp.Name = 'TestingOpp';
        
        Opportunity opp2 = ProductTestFactory.getOpportunity(acc2, pb);
        opp2.StageName = 'Develop';
        opp2.Product_Type__c = 'Modular';
        opp2.Name = 'TestingOppError';
        
        Opportunity opp3 = ProductTestFactory.getOpportunity(acc2, pb);
        opp3.StageName = 'Develop';
        opp3.Product_Type__c = 'Modular';
        opp3.Name = 'TestingOppError2';
        
        Opportunity opp4 = ProductTestFactory.getOpportunity(acc, pb);
        opp4.StageName = 'Develop';
        opp4.Product_Type__c = 'Modular';
        opp4.Name = 'TestingOpp4';
        
        List<Opportunity> oppList = new List<Opportunity>{opp, opp2, opp3, opp4};
            insert oppList;
        
        Contact c = new Contact();
        c.FirstName = 'Testing';
        c.LastName = 'Test';
        c.AccountId = acc.id;
        c.Email = 'test@mailinator.com'; 
        INSERT c;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId = c.Id;
        ocr.OpportunityId = opp.Id;
        ocr.IsPrimary = TRUE;
        ocr.Role = 'Decision Maker';
        
        OpportunityContactRole ocr2 = new OpportunityContactRole();
        ocr2.ContactId = c.Id;
        ocr2.OpportunityId = opp2.Id;
        ocr2.IsPrimary = TRUE;
        ocr2.Role = 'Decision Maker';
        
        OpportunityContactRole ocr3 = new OpportunityContactRole();
        ocr3.ContactId = c.Id;
        ocr3.OpportunityId = opp4.Id;
        ocr3.IsPrimary = TRUE;
        ocr3.Role = 'Decision Maker';
        
        List<OpportunityContactRole> testOCRList = new List<OpportunityContactRole>{ocr, ocr2, ocr3};
            INSERT testOCRList;
        
        cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
        basket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket.cscfga__Opportunity__c = opp.id;
        basket.csbb__Account__c = acc.Id;
        basket.Name = 'testBasketforCBQ';
        
        cscfga__Product_Basket__c basket2 = new cscfga__Product_Basket__c();
        basket2.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket2.cscfga__Opportunity__c = opp2.id;
        basket2.csbb__Account__c = acc2.Id;
        basket2.Description__c = 'testBasketforCBQ';
        
        cscfga__Product_Basket__c basket3 = new cscfga__Product_Basket__c();
        basket3.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket3.cscfga__Opportunity__c = opp2.id;
        basket3.csbb__Account__c = acc2.Id;
        basket3.Description__c = 'secondaryTestBasketforCBQ';
        basket3.Primary_Basket__c = true;
        
        cscfga__Product_Basket__c basket4 = new cscfga__Product_Basket__c();
        basket4.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket4.cscfga__Opportunity__c = opp3.id;
        basket4.csbb__Account__c = acc2.Id;
        basket4.Description__c = 'testBasketforCBQError';
        
        cscfga__Product_Basket__c basket5 = new cscfga__Product_Basket__c();
        basket5.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
        basket5.cscfga__Opportunity__c = opp4.id;
        basket5.csbb__Account__c = acc.Id;
        basket5.Description__c = 'testDiscDate';
        
        cscfga__Product_Basket__c basket6 = new cscfga__Product_Basket__c();
        basket6.csordtelcoa__Basket_Stage__c = 'Submitted';
        basket6.cscfga__Opportunity__c = opp4.id;
        basket6.csbb__Account__c = acc.Id;
        basket6.Description__c = 'testBasketQuote';
        basket6.Primary_Basket__c = true;
        
        List<cscfga__Product_Basket__c> testBasketList = new List<cscfga__Product_Basket__c>{basket, basket2, basket3, basket4, basket5, basket6};
            insert testBasketList;
        
        //create Product Definition
        cscfga__Product_Definition__c defIpSite = new cscfga__Product_Definition__c (Name = System.Label.IP_Site, cscfga__Description__c = System.Label.IP_Site);
        
        cscfga__Product_Definition__c defIpNetwork = new cscfga__Product_Definition__c (Name = System.Label.IP_Network, cscfga__Description__c = System.Label.IP_Network);
        
        cscfga__Product_Definition__c defUcEnterprise = new cscfga__Product_Definition__c (Name = System.Label.UC_Enterprise, cscfga__Description__c = System.Label.UC_Enterprise );
        
        List<cscfga__Product_Definition__c> prodDefList = new List<cscfga__Product_Definition__c>{defIpSite, defIpNetwork, defUcEnterprise};
            insert prodDefList;
        
        cscfga__Attribute_Definition__c atrDef = ProductTestFactory.buildAttributeDefinition('test',defIpSite.id);
        atrDef.cscfga__is_Significant__c = true;
        insert atrDef;
        
        //create Product Configuration
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
        //List<OpportunityLineItem> OLIList = new List<OpportunityLineItem>(); 
        for (Integer i=0; i < 15; i++){
            //cscfga__Product_Configuration__c config = ProductTestService.createProductConfiguration();
            cscfga__Product_Configuration__c config = ProductTestFactory.buildProductConfig(defIpSite.id);
            config.cscfga__total_contract_value__c = 325;
            config.Technology_Type__c = 'NBN Access';
            
            String confName = System.Label.Label_CWP;
            config.cscfga__Product_Definition__c = defIpSite.Id;
            
            if ( i == 8 || i == 10 || i == 13 ){
                confName = System.Label.IP_Network;
                config.cscfga__Product_Definition__c = defIpNetwork.Id;
            }
            else if( i == 9 || i == 11 || i == 14) {
                confName = System.Label.UC_Enterprise;
                config.cscfga__Product_Definition__c = defUcEnterprise.Id;
            }
            if (i == 6 || i == 7 || i == 10 || i == 11)
            {
                config.cscfga__Product_Basket__c = basket2.id;
            } 
            else if (i == 4 || i == 5 || i == 13 ||i == 14 )
            {
                config.cscfga__Product_Basket__c = basket5.id;              
            }
            else{
                config.cscfga__Product_Basket__c = basket.id;
            }     
            config.Name = confName;
            config.cscfga__Description__c = 'test Description '+i;
            config.cscfga__Contract_Term__c = 36;
            config.Type__c = 'Modify';
            if  (i == 4 ||i == 5)
            {
                config.Type__c = 'Cancel';
                config.Name = 'IP Site';
            }
            config.Name = 'IP Site';
            prodConfigList.add(config);         
        }
        cscfga__Product_Category__c prodcat = ProductTestFactory.buildProductCategory();
        insert prodcat;
        
        insert prodConfigList;
        
        List<csbb__Callout_Product_Result__c> testCPRList = new List<csbb__Callout_Product_Result__c>();
        List<csbb__Product_Configuration_Request__c> testProdConfReqList = new List<csbb__Product_Configuration_Request__c>();
        
        for (cscfga__Product_Configuration__c config : prodConfigList)
        {
            
            csbb__Product_Configuration_Request__c pcr = new csbb__Product_Configuration_Request__c();
            pcr.csbb__Product_Category__c = prodcat.id;         
            
            pcr.csbb__Product_Configuration__c = config.id;
            pcr.csbb__Product_Basket__c = config.cscfga__Product_Basket__c;
            pcr.csbb__Total_OC__c = 25;
            pcr.csbb__Total_MRC__c = 25;
            
            testProdConfReqList.add(pcr);
        }
        
        insert testProdConfReqList;
        
        csbb__Callout_Result__c cor = ProductTestFactory.buildCallOutResults();
        insert cor;
        
        for (csbb__Product_Configuration_Request__c pcr : testProdConfReqList )
        {
            csbb__Callout_Product_Result__c copr = ProductTestFactory.buildCalloutProductResults(pcr, cor);
            testCPRList.add(copr);
        }
        insert testCPRList;
        
        List<cscfga__Attribute__c> attList = new List<cscfga__Attribute__c>();
        for(cscfga__Product_Configuration__c config0:prodConfigList){
            cscfga__Attribute__c attr0 = ProductTestFactory.buildAttribute('SRM', '100.00', config0.id);
            attList.add(attr0);
            cscfga__Attribute__c attr1 = ProductTestFactory.buildAttribute('PartnerName', '200.00', config0.id);
            attList.add(attr1);
            cscfga__Attribute__c attr2 = ProductTestFactory.buildAttribute('OC', '400.00', config0.id);
            attList.add(attr2);
            cscfga__Attribute__c attr3 = ProductTestFactory.buildAttribute('Quantity', '300.00', config0.id);
            attList.add(attr3);
            cscfga__Attribute__c attr4 = ProductTestFactory.buildAttribute('ContractTerms', '500.00', config0.id);
            attList.add(attr4);
            cscfga__Attribute__c attr5 = ProductTestFactory.buildAttribute('ProductStatus', 'Lost', config0.id);
            attList.add(attr5);
            cscfga__Attribute__c attr6 = ProductTestFactory.buildAttribute('RC', '700.00', config0.id);
            attList.add(attr6);
            cscfga__Attribute__c attr8 = ProductTestFactory.buildAttribute('Product', 'testproduct', config0.id);
            attList.add(attr8); 
            cscfga__Attribute__c attr9 = ProductTestFactory.buildAttribute('AcquisitionRevenue', '100.00', config0.id);
            attList.add(attr9);
            cscfga__Attribute__c attr10 = ProductTestFactory.buildAttribute('AvgAnnualisedRevenue', '200.00', config0.id);
            attList.add(attr10);
            cscfga__Attribute__c attr11 = ProductTestFactory.buildAttribute('Competitor', '300.00', config0.id);
            attList.add(attr11);
            cscfga__Attribute__c attr12 = ProductTestFactory.buildAttribute('CurrentRevenue', '400.00', config0.id);
            attList.add(attr12);
            cscfga__Attribute__c attr13 = ProductTestFactory.buildAttribute('IncrementalRevenue', '600.00', config0.id);
            attList.add(attr13);
            cscfga__Attribute__c attr14 = ProductTestFactory.buildAttribute('Domain', 'FIXED TELEPHONY', config0.id);
            attList.add(attr14);
            cscfga__Attribute__c attr15 = ProductTestFactory.buildAttribute('ProductCode', '1345', config0.id);
            attList.add(attr15);
            cscfga__Attribute__c attr16 = ProductTestFactory.buildAttribute('ProductMaximName', 'Elvin', config0.id);
            attList.add(attr16);
            cscfga__Attribute__c attr17 = ProductTestFactory.buildAttribute('RenewalRevenue', '900.00', config0.id);
            attList.add(attr17);
            cscfga__Attribute__c attr18 = ProductTestFactory.buildAttribute('Site Id', '123456798', config0.id);
            attList.add(attr18);
            if (config0.cscfga__Product_Basket__c == basket5.id)
            {
                cscfga__Attribute__c attr19 = ProductTestFactory.buildAttribute('DisconnectionDate', '', config0.id);
                attList.add(attr19);
            }
            cscfga__Attribute__c attr20 = ProductTestFactory.buildAttribute('AdborID', '123456798', config0.id);
            attList.add(attr20);
            
        }
        insert attList;
        System.assert(attList.Size()>0);
        
        cscrm__Address__c addressRecord = AccountTestFactory.buildAddress('123456798');
        Insert addressRecord;
        System.assertNotEquals(addressRecord.Id, Null);
        cscrm__Site__c siteRecord =  AccountTestFactory.buildSite(addressRecord.Id, acc.Id);
        Insert siteRecord;
        
        Service_Qualification__c sq = new Service_Qualification__c();
        sq.name = 'Test';
        sq.Site__c =siteRecord.id;
        sq.Location_ID__c = 'LOC343242';
        insert sq;
        
        System.assertNotEquals(siteRecord.Id, Null);
        
        List<cscfga__Attribute__c> newattrList = new List<cscfga__Attribute__c>();
        for(cscfga__Attribute__c attr : attList){
            if(attr.Name == 'Product')
                newattrList.add(attr);
        }
        OpportunityLineItem oli = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=2000,Quantity = 2,
                                                          OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[0].cscfga__Description__c,
                                                          cscfga__Attribute__c = attList[0].id,Product_Status__c = 'Lost',Product_Name__c='test prod');
        OpportunityLineItem oli1 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=3000,Quantity = 3,
                                                           OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[1].cscfga__Description__c,
                                                           cscfga__Attribute__c = attList[1].id, Product_Status__c = 'won',Product_Name__c='test1');
        OpportunityLineItem oli2 = new OpportunityLineItem(pricebookentryid=pbe.Id,TotalPrice=4000,Quantity = 4,
                                                           OpportunityID = basket.cscfga__Opportunity__c, Description = prodConfigList[2].cscfga__Description__c,
                                                           cscfga__Attribute__c = attList[2].id,Product_Status__c = 'withdrawn',Product_Name__c='test2');
        
        List<OpportunityLineItem> oLIList = new List<OpportunityLineItem>{oli, oli1, oli2};
            insert oLIList;
        System.assert(oLIList.Size()>0);
        sObjectLookupController.siteSQWebCallout(basket.id, 100, 10, 0,'', accList[0].Id);
        sObjectLookupController.UpdateRelatedDataForSQSite(basket.id, '123456798');
        //Manoj
         List<cscrm__Site__c> siteList = [Select id,AdborID__c from cscrm__Site__c]; 
         List<String> adbList = new List<String>();
          for(cscrm__Site__c cs : siteList){
             adbList.add(cs.AdborID__c ); 
          }
    //    try{
             HttpResponse res=new HttpResponse();
        String success_Search ='{"code":200,"status":200,"time":"2019-03-05T13:12:45+10:00","request":{"params":{"addressId":"123456798","serviceFilter":"Internet"},"data":{},"path":"/service-addresses","method":"GET","requestId":"cec27ea8-d1f4-4f05-89ac-d11ddaa67774","correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b"},"correlationId":"00d3e37a-82e2-454f-9b66-a8104945973b","data":{"addressId":"161152457","serviceTypeQualifications":[{"serviceType":"Internet","technologyType":"Fibre","readyForServiceDate":"2011-10-09","serviceabilityClass":"12","locationId":"LOC160829045445","csaId":"CSA200000000199","demandType":"Standard Install","providerResources":[{"resourceType":"Copper Pair","id":"New Path","status":"","sicIndicator":"Y","sicCode":"SIC_NEW_PATH_SELECTED_INFLIGHT_INPLACE","sicReason":"SIC is applicable due to In flight order in place","serviceabilityClass":"12"}],"characteristics":[{"name":"TC4 Downstream Upper Rate","value":"25 Mbps"},{"name":"TC4 Downstream Lower Rate","value":""},{"name":"TC4 Upstream Upper Rate","value":"5 Mbps"},{"name":"TC4 Upstream Lower Rate","value":""}],"statusReason":"NBN Internet is serviceable at this address","status":"Available","serviceTransferIndicator":"N","appointmentRequired":"Yes","copperPairIndicator":"Y"}],"additionalTrafficClassAvailability":[{"name":"High Speed TC2 (greater or equal to 20Mbps)","value":"No"},{"name":"TC2","value":"No"},{"name":"NCAS TC2 5Mbps Capacity","value":"No"},{"name":"NCAS TC2 10Mbps Capacity","value":"No"},{"name":"NCAS TC2 20Mbps Capacity","value":"No"},{"name":"NCAS TC2 30Mbps Capacity","value":"No"},{"name":"NCAS TC2 40Mbps Capacity","value":"No"},{"name":"NCAS TC4 High Speed Tiers (greater or equal to 250Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 0.3Mbps)","value":"No"},{"name":"NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)","value":"No"},{"name":"Multicast","value":"No"}],"messages":[{"code":"SQNTT002","message":"The dates cannot be retrieved due to downstream errors"}],"scheduledDates":{"ceaseSaleDate":"","orderStabilityPeriodDate":""},"resourceDetails":[{"ntdId":"NTD400000353005","ntdLoc":"INDOOR","ntdInstallDate":"2016-10-16T01:06:17Z","ntdType":"INTERNAL","ntdPowerType":"AC","batteryPowerUnit":"Yes","powerSupplyWithBatteryBackupInstallDate":"2014-10-16T01:06:17Z","batteryPowerUnitMonitored":"ENABLED","portDetails":[{"uniPortType":"UNI-D","portId":"1-UNI-D1","portStatus":"Used"},{"uniPortType":"UNI-D","portId":"1-UNI-D2","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D3","portStatus":"Free"},{"uniPortType":"UNI-D","portId":"1-UNI-D4","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V1","portStatus":"Used"},{"uniPortType":"UNI-V","portId":"1-UNI-V2","portStatus":"Free"}]}]}}';
       
        res.setBody(success_Search);
        res.setStatusCode(200);
        Map<String,HttpResponse> addrToResourseMap = new Map<String, HttpResponse>{adbList[0]=>res};
        sObjectLookupController.mapResponseToField(basket.id,addrToResourseMap);
    //    }
   //     Catch(Exception Ex){
//            System.debug('Exception: ' +Ex.getMessage());
   //     }
       
        Test.stopTest();
    }
    /*Added below method to cover toCheckSyncJobCompletion method
    * Modified By: Payal Popat  
    * Edge : EDGE-198027
    */
    @isTest
    static void toCheckSyncJobCompletionTest() {
        //CREATE ACCOUNT
            Account acc = AccountTestFactory.buildAccount('Test Account') ;
            acc.Customer_Status__c='Active';
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
            Map<String,String> mapJobId = sObjectLookupController.toCheckSyncJobCompletion(basket.id,'');

            System.assert(mapJobId.Size()==0);
        

    }

    
    /*Added below method to cover toCheckSyncJobCompletion method
* Modified By: Gokul
* Edge : EDGE-195270
*/
    @isTest
    static void toCheckSyncJobCompletionChownTest() {
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active';
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
        //CREATE OPPORTUNITY
        list<opportunity> oppList = new list<opportunity>();
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.amount = 4600;


        opp.Description__c  = 'Chown Incoming';
        oppList.add(opp);
        
        
        Opportunity opp1   = ProductTestFactory.getOpportunityBasic(acc);
        opp1.amount = 4600;


        opp1.Description__c  = 'Chown Outgoing';
        oppList.add(opp1);
        insert oppList;
        //Create Basket
        list<cscfga__Product_Basket__c> pblist = new list<cscfga__Product_Basket__c>();
        cscfga__Product_Basket__c basket = ProductTestFactory.buildEmptyBasket();
        basket.csbb__Account__c = acc.id;
        basket.cscfga__Opportunity__c = opp.id;
        basket.Name = 'basket1';
        pblist.add(basket);
        cscfga__Product_Basket__c basket1 = ProductTestFactory.buildEmptyBasket();
        basket1.csbb__Account__c = acc.id;
        basket1.cscfga__Opportunity__c = opp1.id;
        basket1.Name = 'basket1';
        pblist.add(basket1);
        insert pblist;
        
        Migration_Change_Request__c mcr = new Migration_Change_Request__c();
        mcr.macd_basket_ids__c = basket.id+','+basket1.id;
        insert mcr;
        cscfga__Product_Basket__c pb = [select id,Opportunity_Type__c from cscfga__Product_Basket__c where id =:basket.id limit 1];
        system.debug('1--'+pb.Opportunity_Type__c);
        Map<String,String> mapJobId = sObjectLookupController.toCheckSyncJobCompletion(pb.id,'');

        System.assert(mapJobId.Size()==0);
    }
    
    //Created This Method as a part of DIGI-434 
    @isTest
    static void createRecordFATest(){
        
        
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active';
        acc.APTPS_Contract_Manager__c=UserInfo.getUserId();
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
        
        List<cscfga__Product_Configuration__c> testConfigList= new List<cscfga__Product_Configuration__c>();
        
        cscfga__Product_Configuration__c testConfigReplaced = new cscfga__Product_Configuration__c();
        testConfigReplaced.Name = 'replacedConfigTEST';
        testConfigReplaced.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced.cscfga__total_recurring_charge__c = 5;
        testConfigReplaced.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced;
        
        cscfga__Product_Configuration__c testConfigReplaced2 = new cscfga__Product_Configuration__c();
        testConfigReplaced2.Name = 'replacedConfigTEST2';
        testConfigReplaced2.cscfga__Product_Basket__c = basket.Id;
        testConfigReplaced2.cscfga__total_recurring_charge__c = 6;
        testConfigReplaced2.cscfga__total_one_off_charge__c = 0;
        insert testConfigReplaced2;
        
        cscfga__Product_Configuration__c testConfigRoot = new cscfga__Product_Configuration__c();
        testConfigRoot.Name = 'rootConfigTEST';
        testConfigRoot.cscfga__Product_Basket__c = basket.Id;
        testConfigRoot.Incremental_Revenue__c = 0;
        testConfigRoot.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced2.Id;
        testConfigRoot.cscfga__total_recurring_charge__c = 7;
        testConfigRoot.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigRoot);
        
        cscfga__Product_Configuration__c testConfigNew = new cscfga__Product_Configuration__c();
        testConfigNew.Name = 'newConfigTEST';
        testConfigNew.cscfga__Product_Basket__c = basket.Id;
        testConfigNew.csordtelcoa__Replaced_Product_Configuration__c = testConfigReplaced.Id;
        testConfigNew.cscfga__total_recurring_charge__c = 6;
        testConfigNew.cscfga__total_one_off_charge__c = 0;
        testConfigList.add(testConfigNew);
        
        ContractJunction__c record = new ContractJunction__c();
        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
        record.Email__c = oppContact.contact.Email;
        record.Phone__c = oppContact.contact.MobilePhone;
        record.Customer_Primary_Contact__c = oppContact.ContactId;
        record.Related_Basket__c = basket.id;
        record.DocuSign_Signer_2__c = UserInfo.getUserId();
        record.DocuSign_Signer_3__c = UserInfo.getUserId();
        record.CongaStatus__c = 'NotStarted';
        record.Account__c = basket.csbb__Account__c;
        record.Related_Opportunity__c = basket.cscfga__Opportunity__c;
        record.Contract_Activated_Date__c = System.today();
        record.Contract_Term_Months__c = 36;
        record.BSA_Generated__c =true;
        record.Name = 'CN' + basket.Name.substring(2);
        insert record;
        
        
        insert testConfigList;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'user@mail.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            
        );
        insert u;

        Delegated_Pricing_Request__c insertDelegatedPricingRequest = new Delegated_Pricing_Request__c();
        insertDelegatedPricingRequest.Description__c = 'Test';
        insertDelegatedPricingRequest.Opportunity__c = opp.id;
        insertDelegatedPricingRequest.Account__c=acc.Id;
        insertDelegatedPricingRequest.isPrimary__c = False;
        insertDelegatedPricingRequest.Mark_as_Variation__c = False;
        insertDelegatedPricingRequest.Parent_DPR__c = 'Test';
        insertDelegatedPricingRequest.Deal_Status__c='In Effect';
        //insertDelegatedPricingRequest.Total_Contract_Value__c=0;
        insert insertDelegatedPricingRequest;
         
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
        
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id ; 
        dOffer.Name = 'Test';
        dOffer.Marketable_Offer__c=Marketoffer.Id;
        dOffer.Minimum_Spent_per_Month_Manual__c=100;
        //dOffer.Total_Spend_over_Contract_Term__c =    10;
        dOffer.PF_Contract_Term__c=20;
        insert dOffer ;
        
        List<cspmb__Price_Item__c> cpList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c cProduct = new cspmb__Price_Item__c();
        cProduct.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProduct.cspmb__Recurring_Charge__c = 18.18;
        cProduct.Type__c = 'Handheld';
        cpList.add(cProduct);
        
        cspmb__Price_Item__c cProducta = new cspmb__Price_Item__c();
        cProducta.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProducta.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; 
        cProducta.cspmb__Recurring_Charge__c = 18.18;
        cProducta.Type__c = 'Enterprise Wireless';
        cpList.add(cProducta);
        
        cspmb__Price_Item__c cProductb = new cspmb__Price_Item__c();
        cProductb.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProductb.ProdSpecId__c = 'DMCAT_ProductSpecification_001196';
        cProductb.cspmb__Recurring_Charge__c = 18.18;
        cProductb.Type__c = 'Mobile Broadband';
        cpList.add(cProductb);
        
        cspmb__Price_Item__c cProduct1 = new cspmb__Price_Item__c();
        cProduct1.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct1.ChargeType__c = 'OC'; //EDGE-177567
        cProduct1.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct1.cspmb__Recurring_Charge__c = 18.18;
        cpList.add(cProduct1);
        
        cspmb__Price_Item__c cProduct2 = new cspmb__Price_Item__c();
        cProduct2.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct2.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct2.ChargeType__c = 'RC'; //EDGE-177567
        cProduct2.cspmb__One_Off_Charge__c = 18.18;
        cpList.add(cProduct2);
        
        insert cpList;
        
        //DIGI-434 - Start
        List<DPR_Offer_Line_Item__c> dprList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprLineItemHH = New DPR_Offer_Line_Item__c();
        dprLineItemHH.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH.Quantity__c = 5;
        dprLineItemHH.List_Price__c =40;
        dprLineItemHH.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemHH.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemHH.Overridden_Total_Price__c = 150 ;
        dprLineItemHH.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemHH);
        
        
        
        DPR_Offer_Line_Item__c dprLineItemWLS = New DPR_Offer_Line_Item__c();
        dprLineItemWLS.cspmb_Price_Item__c = cpList[1].Id; 
        dprLineItemWLS.Quantity__c = 5;
        dprLineItemWLS.List_Price__c =40;
        dprLineItemWLS.DPR_Offer__c = dOffer.Id ;   
        dprLineItemWLS.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemWLS.DPR_Offer_line_item_value__c = 35;
        dprLineItemWLS.Offer_Type_Name__c = 'Enterprise Wireless';
        dprLineItemWLS.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemWLS.Overridden_Total_Price__c = 175;
        //   dprLineItemWLS.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemWLS);
        
        DPR_Offer_Line_Item__c dprLineItemMBB = New DPR_Offer_Line_Item__c();
        dprLineItemMBB.cspmb_Price_Item__c = cpList[2].Id; 
        dprLineItemMBB.Quantity__c = 5;
        dprLineItemMBB.List_Price__c =40;
        dprLineItemMBB.DPR_Offer__c = dOffer.Id ; 
        dprLineItemMBB.Marketable_Offer__c=Marketoffer.Id;
        dprLineItemMBB.DPR_Offer_line_item_value__c = 20;
        dprLineItemMBB.Offer_Type_Name__c = 'Mobile Broadband';
        dprLineItemMBB.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItemMBB.Overridden_Total_Price__c = 100;
        dprLineItemMBB.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemMBB);
        
        
        
        DPR_Offer_Line_Item__c dprLineItem2 = New DPR_Offer_Line_Item__c();
        dprLineItem2.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem2.Quantity__c = 15;
        dprLineItem2.List_Price__c =25;
        dprLineItem2.DPR_Offer__c = dOffer.Id ; 
         dprLineItem2.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem2.DPR_Offer_line_item_value__c = 30;
        dprLineItem2.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem2.Overridden_Total_Price__c = 750;
        dprLineItem2.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem2);
        
        DPR_Offer_Line_Item__c dprLineItem4 = New DPR_Offer_Line_Item__c();
        dprLineItem4.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem4.Quantity__c = 15;
        dprLineItem4.List_Price__c =25;
        dprLineItem4.DPR_Offer__c = dOffer.Id ; 
        dprLineItem4.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem4.DPR_Offer_line_item_value__c = 30;
        dprLineItem4.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        dprLineItem4.Overridden_Total_Price__c = 750;
        dprLineItem4.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem4);
        
        DPR_Offer_Line_Item__c dprLineItem1 = New DPR_Offer_Line_Item__c();
        dprLineItem1.cspmb_Price_Item__c = cpList[3].Id; 
        //  dprLineItem1.cspmb_Add_On_Price_Item__c = ofcpList[0].Id;
        dprLineItem1.Quantity__c = 5;
        dprLineItem1.List_Price__c =25;
        dprLineItem1.DPR_Offer__c = dOffer.Id ;
        dprLineItem1.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem1.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem1.Overridden_Total_Price__c = 124;
        //  dprLineItem1.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        dprList.add(dprLineItem1);
        
        DPR_Offer_Line_Item__c dprLineItem3 = New DPR_Offer_Line_Item__c();
        dprLineItem3.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem3.Quantity__c = 15;
        dprLineItem3.List_Price__c =25;
        dprLineItem3.DPR_Offer__c = dOffer.Id ;
        dprLineItem3.Marketable_Offer__c=Marketoffer.Id;
        dprLineItem3.DPR_Offer_line_item_value__c = 30;
        dprLineItem3.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id; 
        dprLineItem3.Overridden_Total_Price__c = 750;
        dprList.add(dprLineItem3);
        insert dprList ; 
        
       
        //List<Delegated_Pricing_Request__c> dprlist = [select id,Account__c,Opportunity__c,Total_Deal_Monthly_Value__c,Opportunity__r.Contract_Type__c from Delegated_Pricing_Request__c];
        List<DPR_Offer_Line_Item__c> relatedDPROLI= [select id,name,Delegated_Pricing_Request__r.Opportunity__r.AccountId,Marketable_Offer__c,Marketable_Offer__r.Product_Family__c,Marketable_Offer__r.name,DPR_Offer_Line_Item_Type__c,Offer_Type_Name__c,Offer_Type__r.Type__c,DPR_Offer_Line_Item_Value__c,DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c=:insertDelegatedPricingRequest.id];
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('Schedule').getRecordTypeId();
        string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByName().get('SA').getRecordTypeId();
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>();     
        Apttus__APTS_Agreement__c agreementDSADigi = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c = insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c =insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementDSADigi);
        Apttus__APTS_Agreement__c agreementDSALegacy = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementDSALegacy);
        Apttus__APTS_Agreement__c agreementPSDigi = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Digital');
        agmtList.add(agreementPSDigi);
        Apttus__APTS_Agreement__c agreementPSLegacy = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =insertDelegatedPricingRequest.Opportunity__c,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c = insertDelegatedPricingRequest.Account__c,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Apttus__Source__c = 'Internal Paper');
        agmtList.add(agreementPSLegacy);
        insert agmtList;
        agmtList[2].Apttus__Parent_Agreement__c = agmtList[0].id;
        agmtList[3].Apttus__Parent_Agreement__c = agmtList[1].id;
        upsert agmtList;
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
        
        List<Apttus__AgreementLineItem__c> agmtLineItems = new List<Apttus__AgreementLineItem__c>();
        Apttus__AgreementLineItem__c lineitem00 = new Apttus__AgreementLineItem__c();
        lineitem00.Apttus__AgreementId__c = agreementPSLegacy.id;
        lineitem00.Apttus__ProductId__c= prod.id;
        agmtLineItems.add(lineitem00);
        
        Apttus__AgreementLineItem__c lineitem01 = new Apttus__AgreementLineItem__c();
        lineitem01.Apttus__AgreementId__c = agreementPSDigi.id;
        lineitem01.Apttus__ProductId__c= prod1.id;
        agmtLineItems.add(lineitem01);
        insert agmtLineItems;
        Test.startTest();
        boolean isPRMuser = sObjectLookupController.userInfoPRM(); 
        system.assert(isPRMuser!=null);
        String response = sObjectLookupController.createRecord(basket.Id, contact.Id, Userinfo.getProfileid(),false,null);
        system.assert(response!=null);
        csconta__Frame_Agreement__c fam = new csconta__Frame_Agreement__c();
        fam.csconta__Status__c = 'Contract Initiated';
        fam.Delegated_Pricing_Request__c = insertDelegatedPricingRequest.Id;
        fam.Opportunity__c=opp.id;
        insert fam;    
            //EDGE-190520 FAM Contract Initiation
            /*FA_DefaultRecipients__c fa = new FA_DefaultRecipients__c();
            fa.Signatory_1__c = Contact.Id;
            fa.Signatory_2__c = u.Id;
            insert fa;*/
            //sObjectLookupController.toCheckSyncJobCompletion();
        
        sObjectLookupController.createRecordFA(fam.Id, Contact.Id, u.Id,null);
        
        Test.stopTest();

    }
    
  
}
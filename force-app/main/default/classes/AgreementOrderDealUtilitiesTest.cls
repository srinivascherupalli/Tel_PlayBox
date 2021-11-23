/**
     * @Author   :   Rahul Asarma
     * @Date     :   Feb 2021
     * @US       :   EDGE-200025
     * @Description: Test class for AgreementOrderDealUtilities that creates vairation PS Agreeemnts.
 * */
@IsTest 
public with sharing class AgreementOrderDealUtilitiesTest {
public static Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
public static Account acc = null;
public static Contact contact= null;
public static Opportunity oppty1=null;
public static Opportunity oppty2=null;
public static Apttus__APTS_Agreement__c agreementPS=null;

public static String varieationString='[{"VariationModify":"Corporate Mobile Plus","VariationAdd":null,"Product":"Corporate Mobile Plus","Attribute":"Y","ALI":"Y"},{"VariationModify":null,"VariationAdd":"Adaptive Mobility","Product":"Adaptive Mobility","Attribute":"Y","ALI":"Y"}]'; // EDGE-194529-- Changes added


@testSetup
  static void setupTestData(){
        
       acc = AccountTestFactory.buildAccount('Test AccountOrderflow') ;
        acc.APTPS_DocuSign_Restricted__c = false; 
        acc.Customer_Status__c = 'Active'; 

        insert acc;  
        //CREATE CONTACT 
        contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;
        list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test Adaptive Opty';
        opp.amount = 4600;
       //insert opp;
       listoppty.add(opp);
       oppty1   = ProductTestFactory.getOpportunityBasic(acc);
        oppty1.name='Test Adaptive Opty';
        oppty1.amount = 4600;
       listoppty.add(oppty1);
       
       oppty2   = ProductTestFactory.getOpportunityBasic(acc);
        oppty2.name='Test Adaptive Opty';
        oppty2.amount = 4600;
       listoppty.add(oppty2);
        
        insert listoppty;

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
        //oldContract.BSA_Generated__c=true;
        cntrctRecord.Related_Opportunity__c=basket.cscfga__Opportunity__c;
        cntrctRecord.Related_Basket__c=basket.id;
        insert cntrctRecord;
        
        List<Apttus__APTS_Template__c> aptTempList = new List<Apttus__APTS_Template__c>();
        Apttus__APTS_Template__c dsaTemp  = APTPS_TestClassData.templateRecord('Price_Schedule_Document','Agreement');
        Apttus__APTS_Template__c psTemp = APTPS_TestClassData.templateRecord('Price_Schedule_Template','Agreement'); 
        aptTempList.add(dsaTemp);
        aptTempList.add(psTemp);
        
        string AGREEMENT_KEYFACTS_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
            string GENERAL_PRODUCT_TERMS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
            Apttus__APTS_Agreement__c agreementDSA = new Apttus__APTS_Agreement__c(recordtypeid=GENERAL_PRODUCT_TERMS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestDSA', Apttus__Agreement_Category__c = 'Digital Services', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',Apttus__Status__c='Activated',Related_Basket__c=basket.id);
             insert agreementDSA ; 
            
            

            agreementPS = new Apttus__APTS_Agreement__c(recordtypeid=AGREEMENT_KEYFACTS_RECORDTYPEID,Apttus__Related_Opportunity__c =opp.id,APTPS_Validation_on_Fully_Signed__c=true,Apttus__Contract_End_Date__c=system.today(),Apttus__Account__c=acc.id,name = 'TestPS', Apttus__Agreement_Category__c = 'Pricing', APTPS_Telstra_Legal_Entity__c = 'Melbourne',Apttus__Status_Category__c='In Effect',PS_Variation_Details__c=varieationString,Apttus__Status__c='Activated',Apttus__Parent_Agreement__c=agreementDSA.id,Related_Basket__c=basket.id,APTPS_VariationModify__c='Adaptive Mobility',Variation_Applicable__c=true); // EDGE-194529-- Changes PS_Variation_Details__c field added

           insert agreementPS;
        
        list<Product2> prodlst =new list<Product2>();
        Product2 prod=new Product2();
        prod.Name='Adaptive Mobility';
        
        Product2 prod1=new Product2();
        prod1.Name='Corporate Mobile Plus';
        prodlst.add(prod);
        prodlst.add(prod1);
        insert prodlst;
       }
    
      @isTest 
    static void createPriceScheduleVariation_testPositiveWithFAdefault(){
        test.startTest();
        setupTestData();
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'OpportunityTrigger';
        insert disabledTriggersProfile;
        //Account acc=[select id from Account where name=:'Test AccountOrderflow' limit 1];
        
        /*Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test deal Opty';
        opp.amount = 4600;
       insert opp;*/
       
       Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
       
       Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=oppty1.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='Adaptive Mobility Plan';
        insert dproffer;
        
        DPR_Offer_Line_Item__c dolineitem= new DPR_Offer_Line_Item__c();
        dolineitem.Delegated_Pricing_Request__c=dpr.id;
        dolineitem.Marketable_Offer__c=Marketoffer.id;
        dolineitem.List_Price__c=10;
        dolineitem.DPR_Offer__c=dproffer.id;
        dolineitem.DPR_Offer_Line_Item_Type__c ='Plan';
        dolineitem.Offer_Type_Name__c='Mobile Broadband';
        dolineitem.DPR_Offer_Line_Item_Value__c=10;
        insert dolineitem;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=oppty1.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        
       /* Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;*/
        
          
        FA_DefaultRecipients__c faDef= new FA_DefaultRecipients__c();
        faDef.Signatory_1__c=contact.id;
        faDef.Signatory_2__c=userinfo.getuserid();
        faDef.Deal_Pricing_Request__c=dpr.id;
        insert faDef;
        
        List<Delegated_Pricing_Request__c> dprList= new List<Delegated_Pricing_Request__c>();
        dprList.add(dpr);
        
         List<DPR_Offer_Line_Item__c> relatedDPROLI= new List<DPR_Offer_Line_Item__c>();
        relatedDPROLI.add(dolineitem);
       // Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();

       // List<Apttus__APTS_Agreement__c> PSAgreementRecord=[select Id, Apttus__Account__c,Name, Apttus__FF_Agreement_Number__c, APTPS_Parent_Agreement_Id__c,Apttus__Status_Category__c, APTPS_Title__c,Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,APTPS_Agreement_Subcategory__c, Apttus__Parent_Agreement__c,createddate,Related_Basket__c,Apttus__Related_Opportunity__c,Auto_Created_by_Basket__c,APTPS_variationAdd__c,APTPS_VariationModify__c,PS_Variation_Details__c,Apttus__Version_Number__c,Variation_Applicable__c from Apttus__APTS_Agreement__c where  Apttus__Account__c =: acc.Id AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId = :AGREEMENT_Schedule_RECORDTYPEID AND Variation_Applicable__c=true ORDER BY CreatedDate DESC LIMIT 1];

        AgreementOrderDealUtilities.priceScheduleVariationCreateForOrderToDeal(dprList,relatedDPROLI,agreementPS);
        test.stopTest();
        Apttus__APTS_Agreement__c variatedAgreement=[select id,Apttus__Version_Number__c from Apttus__APTS_Agreement__c where Delegated_Pricing_Request__c=:dpr.id];
        System.assertEquals(variatedAgreement.Apttus__Version_Number__c,1);
        
    }
    @isTest 
    static void createPriceScheduleVariation_testNegativeWithprmContactRole(){
        test.startTest();
        setupTestData();
        
        Disabled_Triggers__c disabledTriggersProfile = new Disabled_Triggers__c();
        disabledTriggersProfile.SetupOwnerId = UserInfo.getProfileId();
        disabledTriggersProfile.Trigger_Name_List1__c = 'OpportunityTrigger';
        insert disabledTriggersProfile;
        //Account acc=[select id from Account where name=:'Test AccountOrderflow' limit 1];
        
        /*Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test deal Opty';
        opp.amount = 4600;
       insert opp;*/
       
       Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Adaptive Mobility';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Adaptive Mobility';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
       
       Delegated_Pricing_Request__c dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=oppty2.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='Adaptive Mobility Plan';
        insert dproffer;
        
        DPR_Offer_Line_Item__c dolineitem= new DPR_Offer_Line_Item__c();
        dolineitem.Delegated_Pricing_Request__c=dpr.id;
        dolineitem.Marketable_Offer__c=Marketoffer.id;
        dolineitem.List_Price__c=10;
        dolineitem.DPR_Offer__c=dproffer.id;
        dolineitem.DPR_Offer_Line_Item_Type__c ='Plan';
        dolineitem.Offer_Type_Name__c='Mobile Broadband';
        dolineitem.DPR_Offer_Line_Item_Value__c=10;
        insert dolineitem;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=oppty2.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        
        /*Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'Last',
            FirstName = 'First',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+17626727626',
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;*/
        
        
        OpportunityContactRole oppContRole = new OpportunityContactRole();
        oppContRole.ContactId = contact.Id;
        oppContRole.OpportunityId = oppty2.Id;
        oppContRole.IsPrimary = true;
        oppContRole.Role = 'Decision Maker';
        insert oppContRole;
        
        
          
        
        
        List<Delegated_Pricing_Request__c> dprList= new List<Delegated_Pricing_Request__c>();
        dprList.add(dpr);
        
         List<DPR_Offer_Line_Item__c> relatedDPROLI= new List<DPR_Offer_Line_Item__c>();
        relatedDPROLI.add(dolineitem);
        

        //List<Apttus__APTS_Agreement__c> PSAgreementRecord=[select Id, Apttus__Account__c,Name, Apttus__FF_Agreement_Number__c, APTPS_Parent_Agreement_Id__c,Apttus__Status_Category__c, APTPS_Title__c,Apttus__Status__c,  Apttus__Agreement_Category__c,PS_Variation_Details__c,  Apttus__Subtype__c,APTPS_Agreement_Subcategory__c, Apttus__Parent_Agreement__c,createddate,Related_Basket__c,Apttus__Related_Opportunity__c,Auto_Created_by_Basket__c,APTPS_variationAdd__c,APTPS_VariationModify__c,Apttus__Version_Number__c,Variation_Applicable__c from Apttus__APTS_Agreement__c where  Apttus__Account__c =: acc.Id AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId = :AGREEMENT_Schedule_RECORDTYPEID AND Variation_Applicable__c=true ORDER BY CreatedDate DESC LIMIT 1];

        AgreementOrderDealUtilities.getMarketableOfferDeal(dprList,relatedDPROLI);
        AgreementOrderDealUtilities.priceScheduleVariationCreateForOrderToDeal(dprList,relatedDPROLI,agreementPS);
        test.stopTest();
 
        Apttus__APTS_Agreement__c variatedAgreement=[select id,Apttus__Version_Number__c from Apttus__APTS_Agreement__c where Delegated_Pricing_Request__c=:dpr.id];
        System.assertEquals(variatedAgreement.Apttus__Version_Number__c,1);
        
        
    }
    }
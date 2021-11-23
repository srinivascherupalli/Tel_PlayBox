/**
     * @Author   :   Rahul Asarma
     * @Date     :   23 May 2021
     * @US       :   EDGE-134661
     * @Description: Test class for AgreementApttusRateCardUtilities that creates Agreeemnts for deal Pricing.
 * */
@IsTest 
public with sharing class AgreementApttusRateCardUtilitiesTest {
    public static DPR_Offer_Line_Item__c dprlineItem=null;
    public static Delegated_Pricing_Request__c dpr=null;
      static void setupTestData(){
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
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;
        //list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test Adaptive Opty';
        opp.amount = 4600;
       insert opp;
       
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='Telstra Collaboration';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='Telstra Collaboration';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
       
        dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='Telstra Collaboration';
        dproffer.Marketable_Offer__c=Marketoffer.id;
        insert dproffer;
        
        dprlineItem= new DPR_Offer_Line_Item__c();
        dprlineItem.Delegated_Pricing_Request__c=dpr.id;
        dprlineItem.Marketable_Offer__c=Marketoffer.id;
        dprlineItem.List_Price__c=10;
        dprlineItem.DPR_Offer__c=dproffer.id;
        dprlineItem.DPR_Offer_Line_Item_Type__c ='Plan';
        dprlineItem.Offer_Type_Name__c='Mobile Broadband';
        dprlineItem.DPR_Offer_Line_Item_Value__c=10;
        insert dprlineItem;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        
        
      
    }
    
    @isTest 
    static void apttusRateCardCreationPositive(){
        setupTestData();
        Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
        map<id,id> dprlineitemwithapttusRateCardMap= new map<id,id>();
         List<String> rateCardPlanName= new List<String>{'(1 to 10)','(11 to 20)','(21 to 50)','(51 to 200)','(201 to 500)','(501 to 99999)'};
        String rateCardName='test DPR Rate Card';
        
        cspmb__Rate_Card__c parentRateCard= new cspmb__Rate_Card__c();
        parentRateCard.name= rateCardName;
        insert parentRateCard;
        
        List<cspmb__Rate_Card_Line__c> ratecardlineitemList= new List<cspmb__Rate_Card_Line__c>();
        
        for(String slab:rateCardPlanName){
        cspmb__Rate_Card_Line__c ratcardLineitem= new cspmb__Rate_Card_Line__c();
        ratcardLineitem.Name=rateCardName+' '+slab;
        ratcardLineitem.cspmb__Rate_Card__c=parentRateCard.id;
        ratecardlineitemList.add(ratcardLineitem);
        }
        
        insert ratecardlineitemList;
        
        DPR_Rate_Card__c prntDprRateCard= new DPR_Rate_Card__c();
        prntDprRateCard.Rate_Card__c=parentRateCard.id;
        prntDprRateCard.Delegated_Pricing_Request__c=dpr.id;
        prntDprRateCard.Parent_DPR_OLI_id__c=dprlineItem.id;
        prntDprRateCard.DPR_Rate_Card_Type__c='Rate Card';
        prntDprRateCard.DPR_RC_Negotiated_Value__c=1.0;
        prntDprRateCard.Negotiated_Discount__c=1.0;
        insert prntDprRateCard;
        
        list<DPR_Rate_Card__c> dprRateCardinsertList= new list<DPR_Rate_Card__c>();
        for(cspmb__Rate_Card_Line__c ratcardLineitemloop:ratecardlineitemList){
            DPR_Rate_Card__c DprRateCardlineItem= new DPR_Rate_Card__c();
            DprRateCardlineItem.Rate_Card__c=parentRateCard.id;
            DprRateCardlineItem.Parent_DPR_Rate_Card_ID__c=prntDprRateCard.id;
            DprRateCardlineItem.Rate_Card_Line__c=ratcardLineitemloop.id;
            DprRateCardlineItem.Delegated_Pricing_Request__c=dpr.id;
            DprRateCardlineItem.Parent_DPR_OLI_id__c=dprlineItem.id;
            DprRateCardlineItem.DPR_Rate_Card_Type__c='Rate Card Line';
            DprRateCardlineItem.DPR_RC_Negotiated_Value__c=1.0;
            DprRateCardlineItem.Negotiated_Discount__c=1.0;
            dprRateCardinsertList.add(DprRateCardlineItem);
        }
        insert dprRateCardinsertList;
      system.debug('dprRateCardinsertList'+dprRateCardinsertList);
        test.startTest();
        
        List<DPR_Rate_Card__c> dprRateCardList=[SELECT Id,DPR_Rate_Card_Name__c,Parent_DPR_OLI_id__c,Parent_DPR_OLI_id__r.Product_Family__c,                                            Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,Parent_DPR_Rate_Card_ID__c,Rate_Card__r.name, DPR_RC_Negotiated_Value__c,                                              DPR_Rate_Card_Type__c  from DPR_Rate_Card__c where Parent_DPR_OLI_id__c =: dprlineItem.id order by DPR_Rate_Card_Name__c asc];
        system.debug('dprRateCardList'+dprRateCardList);
        if(dprRateCardList.size()>0){
            dprlineitemwithapttusRateCardMap=AgreementApttusRateCardUtilities.createApttusRateCard(dprRateCardList);
        }
        
        test.stopTest();
        
        APTPS_Rate_Card__c aptpsRateCard=[select id,level1_Negotiated_Value__c from APTPS_Rate_Card__c where DPR_Offer_Line_Item__c in :dprlineitemwithapttusRateCardMap.keyset() limit 1];
         System.assertEquals(aptpsRateCard.level1_Negotiated_Value__c,1.0);
        
    }
    
    @isTest 
    static void apttusRateCardCreationN(){
        setupTestData();
        map<id,id> dprlineitemwithapttusRateCardMap= new map<id,id>();
        Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
         List<String> rateCardPlanName= new List<String>{'(1 to 10)','(11 to 20)','(21 to 50)','(51 to 200)','(201 to 500)','(501 to 99999)'};
        String rateCardName='test DPR Rate Card';
        
        cspmb__Rate_Card__c parentRateCard= new cspmb__Rate_Card__c();
        parentRateCard.name= rateCardName;
        insert parentRateCard;
        
        List<cspmb__Rate_Card_Line__c> ratecardlineitemList= new List<cspmb__Rate_Card_Line__c>();
        
        for(String slab:rateCardPlanName){
        cspmb__Rate_Card_Line__c ratcardLineitem= new cspmb__Rate_Card_Line__c();
        ratcardLineitem.Name=rateCardName+' '+slab;
        ratcardLineitem.cspmb__Rate_Card__c=parentRateCard.id;
        ratecardlineitemList.add(ratcardLineitem);
        }
        
        insert ratecardlineitemList;
        
        DPR_Rate_Card__c prntDprRateCard= new DPR_Rate_Card__c();
        prntDprRateCard.Rate_Card__c=parentRateCard.id;
        prntDprRateCard.Delegated_Pricing_Request__c=dpr.id;
        prntDprRateCard.Parent_DPR_OLI_id__c=dprlineItem.id;
        prntDprRateCard.DPR_Rate_Card_Type__c='Rate Card';
        prntDprRateCard.DPR_RC_Negotiated_Value__c=1.0;
        prntDprRateCard.Negotiated_Discount__c=1.0;
        insert prntDprRateCard;
        
        
      
        test.startTest();
        
        List<DPR_Rate_Card__c> dprRateCardList=[SELECT Id,DPR_Rate_Card_Name__c,Parent_DPR_OLI_id__c,                                            Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,Parent_DPR_Rate_Card_ID__c,Rate_Card__r.name, DPR_RC_Negotiated_Value__c,                                              DPR_Rate_Card_Type__c  from DPR_Rate_Card__c where Parent_DPR_OLI_id__c =: dprlineItem.id order by DPR_Rate_Card_Name__c asc];
        system.debug('dprRateCardList'+dprRateCardList);
        if(dprRateCardList.size()>0){
           dprlineitemwithapttusRateCardMap= AgreementApttusRateCardUtilities.createApttusRateCard(dprRateCardList);
        }
        
        test.stopTest();
        
        List<APTPS_Rate_Card__c> aptpsRateCard=[select id,level1_Negotiated_Value__c from APTPS_Rate_Card__c where DPR_Offer_Line_Item__c in :dprlineitemwithapttusRateCardMap.keyset() limit 1];
         System.assertEquals(aptpsRateCard.size(),0);
        
    }
    
     @isTest 
    static void apttusRateCardCreationForIoTConnectivity(){
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
            Email = 'test@tele2.com',
            Pref_Comm_Method__c = 'Email'           
        );
        Insert contact;
        //list<Opportunity> listoppty= new list<Opportunity>();
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.name='Test IoT Opty';
        opp.amount = 4600;
       insert opp;
       
        Marketable_Offer__c Marketoffer=new Marketable_Offer__c();
        Marketoffer.Name='IoT Connectivity';
        Marketoffer.Contract_Type__c='DSA';
        Marketoffer.Product_Family__c='IoT Connectivity';
        Marketoffer.Offer_ID__c='DMCAT_Offer_001231';
        insert Marketoffer;
       
        dpr= new Delegated_Pricing_Request__c();
        dpr.Account__c=acc.id;
        dpr.Opportunity__c=opp.id;
        dpr.Commitment_Frequency__c='Quarterly';
        insert dpr;
        
        DPR_Offer__c dproffer= new DPR_Offer__c();
        dproffer.Delegated_Pricing_Request__c=dpr.id;
        dproffer.name='IoT Connectivity';
        dproffer.Marketable_Offer__c=Marketoffer.id;
        insert dproffer;
        
        dprlineItem= new DPR_Offer_Line_Item__c();
        dprlineItem.Delegated_Pricing_Request__c=dpr.id;
        dprlineItem.Marketable_Offer__c=Marketoffer.id;
        dprlineItem.List_Price__c=10;
        dprlineItem.DPR_Offer__c=dproffer.id;
        dprlineItem.DPR_Offer_Line_Item_Type__c ='Plan';
        dprlineItem.Offer_Type_Name__c='LTE';
        dprlineItem.DPR_Offer_Line_Item_Value__c=10;
        insert dprlineItem;
        
        csconta__Frame_Agreement__c framAg= new csconta__Frame_Agreement__c();
        framAg.csconta__Account__c=acc.id;
        framAg.Opportunity__c=opp.id;
        framAg.Delegated_Pricing_Request__c=dpr.id;
        framAg.csconta__Agreement_Name__c='AGR-TEST';
        insert framAg;
        Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
        map<id,id> dprlineitemwithapttusRateCardMap= new map<id,id>();
         List<String> rateCardPlanName= new List<String>{'(1 to 999)','(1000 to 2499)','(2500 to 9999)','(10000 to 24999)','(25000 to 999999)'};
        String rateCardName='Test IoT LTE DPR Rate Card';
        
        cspmb__Rate_Card__c parentRateCard= new cspmb__Rate_Card__c();
        parentRateCard.name= rateCardName;
        insert parentRateCard;
        
        List<cspmb__Rate_Card_Line__c> ratecardlineitemList= new List<cspmb__Rate_Card_Line__c>();
        
        for(String slab:rateCardPlanName){
        cspmb__Rate_Card_Line__c ratcardLineitem= new cspmb__Rate_Card_Line__c();
        ratcardLineitem.Name=rateCardName+' '+slab;
        ratcardLineitem.cspmb__Rate_Card__c=parentRateCard.id;
        ratecardlineitemList.add(ratcardLineitem);
        }
        
        insert ratecardlineitemList;
        
        DPR_Rate_Card__c prntDprRateCard= new DPR_Rate_Card__c();
        prntDprRateCard.Rate_Card__c=parentRateCard.id;
        prntDprRateCard.Delegated_Pricing_Request__c=dpr.id;
        prntDprRateCard.Parent_DPR_OLI_id__c=dprlineItem.id;
        prntDprRateCard.DPR_Rate_Card_Type__c='Rate Card';
        prntDprRateCard.DPR_RC_Negotiated_Value__c=1.0;
        prntDprRateCard.Negotiated_Discount__c=1.0;
        insert prntDprRateCard;
        
        list<DPR_Rate_Card__c> dprRateCardinsertList= new list<DPR_Rate_Card__c>();
        for(cspmb__Rate_Card_Line__c ratcardLineitemloop:ratecardlineitemList){
            DPR_Rate_Card__c DprRateCardlineItem= new DPR_Rate_Card__c();
            DprRateCardlineItem.Rate_Card__c=parentRateCard.id;
            DprRateCardlineItem.Parent_DPR_Rate_Card_ID__c=prntDprRateCard.id;
            DprRateCardlineItem.Rate_Card_Line__c=ratcardLineitemloop.id;
            DprRateCardlineItem.Delegated_Pricing_Request__c=dpr.id;
            DprRateCardlineItem.Parent_DPR_OLI_id__c=dprlineItem.id;
            DprRateCardlineItem.DPR_Rate_Card_Type__c='Rate Card Line';
            DprRateCardlineItem.DPR_RC_Negotiated_Value__c=1.0;
            DprRateCardlineItem.Negotiated_Discount__c=1.0;
            dprRateCardinsertList.add(DprRateCardlineItem);
        }
        insert dprRateCardinsertList;
      system.debug('dprRateCardinsertList'+dprRateCardinsertList);
        test.startTest();
        
        List<DPR_Rate_Card__c> dprRateCardList=[SELECT Id,DPR_Rate_Card_Name__c,Parent_DPR_OLI_id__c,Parent_DPR_OLI_id__r.Product_Family__c,                                            Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,Parent_DPR_Rate_Card_ID__c,Rate_Card__r.name, DPR_RC_Negotiated_Value__c,                                              DPR_Rate_Card_Type__c  from DPR_Rate_Card__c where Parent_DPR_OLI_id__c =: dprlineItem.id order by DPR_Rate_Card_Name__c asc];
        system.debug('dprRateCardList'+dprRateCardList);
        for(DPR_Rate_Card__c dprRateCard:dprRateCardList){
            System.debug(dprRateCard.Rate_Card__r.name);
            System.debug(dprRateCard.Parent_DPR_OLI_id__r.Product_Family__c);
            System.debug(dprRateCard.Parent_DPR_Rate_Card_ID__c);
        }
        if(dprRateCardList.size()>0){
            dprlineitemwithapttusRateCardMap=AgreementApttusRateCardUtilities.createApttusRateCard(dprRateCardList);
        }
        
        test.stopTest();
        
        APTPS_Rate_Card__c aptpsRateCard=[select id,level1_Negotiated_Value__c from APTPS_Rate_Card__c where DPR_Offer_Line_Item__c in :dprlineitemwithapttusRateCardMap.keyset() limit 1];
         System.assertEquals(aptpsRateCard.level1_Negotiated_Value__c,1.0);
        
    }
    
    
}
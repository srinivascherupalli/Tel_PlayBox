/*
* @Author : Yash/Sunil 
* @Date : 9th March 2020
* @Desc : Code to initiate a deal contract support request with Agreements via Process Builder Delegated Pricing Contract Process
* @Jira : EDGE-138646, EDGE-138647
* Histry of Update:-
* Vishal Arbune: 19/05/2020 EDGE-143011 Creation of service terms, general service terms records in CALMS for document generation.
*/
@isTest
public class GenerateDelegatedPricingContractTest {
    public static testMethod void createContract(){
        //CREATE ACCOUNT
        Account acc = AccountTestFactory.buildAccount('Test Account') ;
        acc.Customer_Status__c='Active'; 
        insert acc;
        
        Environment_Configurations__c setting = new Environment_Configurations__c();
        setting.No_Triggers__c=true;
        insert setting;
        
        //CREATE CONTACT 
        Contact contact = new Contact(
            AccountId = acc.id,
            LastName = 'TestPricing',
            FirstName = 'TestDelegate',
            Contact_Role__c = 'Consultant',
            MobilePhone = '+919923456789',
            Email = 'test@tele2.com',Phone= '+919923456789' 
        );
        insert contact;
        
        //CREATE OPPORTUNITY
        Opportunity opp   = ProductTestFactory.getOpportunityBasic(acc);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Defined').getRecordTypeId();
        insert opp;
        
        //CREATE OPP CONTACT ROLE
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.ContactId=contact.id;
        ocr.OpportunityId=opp.id;
        ocr.IsPrimary=TRUE;
        ocr.Role='Decision Maker';
        insert ocr; 
        
        //CREATE Delegated Pricing Request
        
        Delegated_Pricing_Request__c dpr = new Delegated_Pricing_Request__c();
        //dpr.Name='DPR-000999';
        dpr.Opportunity__c=opp.Id;
        dpr.Deal_Status__c='Draft';
        insert dpr;
        //CREATE CASE
         Case objCase = new Case();
        objCase.Deal__c = dpr.Id;
        insert objCase;
        
        // CREATE MARKETABLE OFFERS
        List<Marketable_Offer__c> listOfMOffers = new List<Marketable_Offer__c>();
        Marketable_Offer__c moMob = new Marketable_Offer__c();
        moMob.OfferDefinationName__c = 'Corporate Mobile Plus';
        moMob.Name = 'Corporate Mobile Plus';
        moMob.Offer_ID__c = 'DMCAT_Offer_000646';
        listOfMOffers.add(moMob);
        
        Marketable_Offer__c moTC = new Marketable_Offer__c();
        moTC.OfferDefinationName__c ='Telstra Collaboration';
        moTC.Name = 'Telstra Collaboration';
        moTC.Offer_ID__c = 'D12sd333z';
        listOfMOffers.add(moTC);
        insert listOfMOffers;
        //CREATE COMMERCIAL PRODUCT
        cspmb__Price_Item__c testPriceItemCD = new cspmb__Price_Item__c();
        testPriceItemCD.Name = 'Committed Data Plan';
        testPriceItemCD.Manufacturer__c = 'TestMan';
        testPriceItemCD.Model__c = 'TestMod';
        testPriceItemCD.Colour__c = 'TestCol';
        testPriceItemCD.cspmb__Contract_Term__c = '12';
        testPriceItemCD.ChargeType__c = 'RC';
        testPriceItemCD.cspmb__Recurring_Charge__c = 75;
        testPriceItemCD.cspmb__One_Off_Charge__c = 750;
        testPriceItemCD.ProdSpecId__c='TestOffer';
        testPriceItemCD.Feature_Level__c='Advanced';
        testPriceItemCD.Technical_Support__c='24X7';
        testPriceItemCD.rangeFrom__c='1';
        testPriceItemCD.rangeTo__c='500';
        testPriceItemCD.Billing_Description__c ='Test';
        testPriceItemCD.taxTreatment__c = 'GST Applicable';
        testPriceItemCD.Unit_Of_Measure__c='per month per service';
        testPriceItemCD.Offer_Id__c = 'DMCAT_Offer_000646';
        List<cspmb__Price_Item__c> PIListCD = new List<cspmb__Price_Item__c>{testPriceItemCD};
            insert PIListCD;
        //CREATE DPR OFFER
        DPR_Offer__c dprOffer = new DPR_Offer__c();
        dprOffer.Delegated_Pricing_Request__c=dpr.Id;
        dprOffer.Data_Pack_Plan__c=testPriceItemCD.Id;
        dprOffer.Marketable_Offer__c=moMob.Id;
        dprOffer.Name='Corporate Mobile Plus';
        insert dprOffer;
        system.debug('dprOffer'+dprOffer);
        
        // CREATE PRODUCT
        Product2 prd = new Product2();
        prd.Name = 'Corporate Mobile Plus';
        insert prd;
        
        //CREATE DPR OFFER LINE ITEM
        List<DPR_Offer_Line_Item__c> dprlineitemlst = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprLineItem = new DPR_Offer_Line_Item__c();
        dprLineItem.Name='Standard';
        dprLineItem.DPR_Offer__c=dprOffer.Id;
        dprLineItem.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem.Marketable_Offer__c=moMob.Id;
        dprLineItem.Offer_Type_Name__c='Committed Data';
        dprLineItem.Offer_Type__c=testPriceItemCD.id;
        dprLineItem.DPR_Offer_Line_Item_Type__c='Plan';
        dprLineItem.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem);
        
        DPR_Offer_Line_Item__c dprLineItem1 = new DPR_Offer_Line_Item__c();
        dprLineItem1.Name='Mobile Workspace Discount 1';
        dprLineItem1.DPR_Offer__c=dprOffer.Id;
        dprLineItem1.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem1.Marketable_Offer__c=moMob.Id;
        dprLineItem1.Offer_Type_Name__c='Committed Data';
        dprLineItem1.Offer_Type__c=testPriceItemCD.id;
        dprLineItem1.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem1.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem1);
        
        DPR_Offer_Line_Item__c dprLineItem2 = new DPR_Offer_Line_Item__c();
        dprLineItem2.Name='Activation Credits';
        dprLineItem2.DPR_Offer__c=dprOffer.Id;
        dprLineItem2.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem2.Marketable_Offer__c=moMob.Id;
        dprLineItem2.Offer_Type_Name__c='Committed Data';
        dprLineItem2.Offer_Type__c=testPriceItemCD.id;
        dprLineItem2.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem2.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem2);
        
        DPR_Offer_Line_Item__c dprLineItem3 = new DPR_Offer_Line_Item__c();
        dprLineItem3.Name='Recontracting Credits'; 
        dprLineItem3.DPR_Offer__c=dprOffer.Id;
        dprLineItem3.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem3.Marketable_Offer__c=moMob.Id;
        dprLineItem3.Offer_Type_Name__c='Committed Data';
        dprLineItem3.Offer_Type__c=testPriceItemCD.id;
        dprLineItem3.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem3.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem3);
        
        DPR_Offer_Line_Item__c dprLineItem4 = new DPR_Offer_Line_Item__c();
        dprLineItem4.Name='Mobile Workspace Discount 2';
        dprLineItem4.DPR_Offer__c=dprOffer.Id;
        dprLineItem4.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem4.Marketable_Offer__c=moMob.Id;
        dprLineItem4.Offer_Type_Name__c='Committed Data';
        dprLineItem4.Offer_Type__c=testPriceItemCD.id;
        dprLineItem4.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem4.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem4);
        
        DPR_Offer_Line_Item__c dprLineItem5 = new DPR_Offer_Line_Item__c();
        dprLineItem5.Name='Mobile Workspace Discount 3';
        dprLineItem5.DPR_Offer__c=dprOffer.Id;
        dprLineItem5.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem5.Marketable_Offer__c=moMob.Id;
        dprLineItem5.Offer_Type_Name__c='Committed Data';
        dprLineItem5.Offer_Type__c=testPriceItemCD.id;
        dprLineItem5.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem5.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem5);
        
        DPR_Offer_Line_Item__c dprLineItem6 = new DPR_Offer_Line_Item__c();
        dprLineItem6.Name='MMC Discount';
        dprLineItem6.DPR_Offer__c=dprOffer.Id;
        dprLineItem6.Delegated_Pricing_Request__c = dpr.Id;
        dprLineItem6.Marketable_Offer__c=moMob.Id;
        dprLineItem6.Offer_Type_Name__c='Committed Data';
        dprLineItem6.Offer_Type__c=testPriceItemCD.id;
        dprLineItem6.DPR_Offer_Line_Item_Type__c='Discount';
        dprLineItem6.List_Price__c=54.60;
        dprlineitemlst.add(dprLineItem6);
        
        if(!dprlineitemlst.isEmpty()){
            insert dprlineitemlst;
        }
        //negative scenario - agreement should not be associated with case record before process.
        system.assertNotEquals(objCase.Pricing_Agreement__c==null,false);
        Case cs = new Case();
        Apttus__APTS_Agreement__c aptAggr = new Apttus__APTS_Agreement__c();
        List<Apttus__APTS_Agreement__c> schAgreement = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__AgreementLineItem__c> agrLineItem=new List<Apttus__AgreementLineItem__c>();
        Map<String,String> mapOfChildAgreement=new Map<String,String>();
        Map<String,String> mapAggLineItem=new Map<String,String>();
        Test.startTest();
        List<Delegated_Pricing_Request__c> dprList = new List<Delegated_Pricing_Request__c>([Select Id, Name,Deal_Status__c,Opportunity__c from Delegated_Pricing_Request__c where Id=:dpr.Id]);
        if(!dprList.isEmpty() && dprList.size()>0){
        GenerateDelegatedPricingContract.createContract(dprList);
        cs = [Select Id,Pricing_Agreement__c, Deal__c from Case where Deal__c=:dprList[0].Id];
        aptAggr = [Select Id, Delegated_Pricing_Request__c,APTPS_Customer_Primary_Contact__c from Apttus__APTS_Agreement__c where Delegated_Pricing_Request__c=:dprList[0].Id];//EDGE-143713 - Added contact field in query
        //EDGE-142348 - Get schedule agreement record.
        schAgreement = [Select Id, Apttus__Term_Months__c,Apttus__Agreement_Category__c,APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c
                        from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =:aptAggr.Id];
            for(Apttus__APTS_Agreement__c ch:schAgreement){
                mapOfChildAgreement.put(ch.Id, ch.Apttus__Agreement_Category__c);
            }
             agrLineItem=[Select Id From Apttus__AgreementLineItem__c Where Apttus__AgreementId__c IN:mapOfChildAgreement.keySet()];
            
        } 
        Test.stopTest();
        //Positive scenario - newly created agreement should be associated with case record after the process.       
        system.assertEquals(cs.Pricing_Agreement__c,aptAggr.Id);
        //EDGE-143713 - Assert to Make sure Contact Role is associated with Newly Created Agreement.
        system.assertEquals(aptAggr.APTPS_Customer_Primary_Contact__c,contact.Id);
        //EDGE-142348 -- Assert to make sure contract term populated on schedule agreement record.
        system.assertEquals(schAgreement[0].Apttus__Term_Months__c!=null,true);
        
        //EDGE-143011 assert to check Creation of Shedule, service terms, general service terms records in CALMS for document generation.
        system.assertEquals(schAgreement.size(),3);
        //assert to check Apttus AgreementLineItem created for Apttus APTS Agreement.
        system.assertEquals(agrLineItem.size(),3);
        for(Apttus__APTS_Agreement__c ch:schAgreement){
            if(ch.Apttus__Agreement_Category__c=='Pricing'){
                 system.assertEquals(ch.Apttus__Agreement_Category__c,mapOfChildAgreement.get(ch.Id));
            }
            if(ch.Apttus__Agreement_Category__c=='Service Terms'){
                 system.assertEquals(ch.Apttus__Agreement_Category__c,mapOfChildAgreement.get(ch.Id));
            }
            if(ch.Apttus__Agreement_Category__c=='General Service Terms'){
                 system.assertEquals(ch.Apttus__Agreement_Category__c,mapOfChildAgreement.get(ch.Id));
            }
        }
        //EDGE-143011 end
    }
   
}
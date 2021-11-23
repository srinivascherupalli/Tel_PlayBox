/* 
* @Author : Aniket Bhalerao
* @Date : 21st Sept 2021 
* @Desc : Test IOTDealQuoteDataHandler 
*/

@isTest
public class IOTDealQuoteDataHandlerTest {
    @TestSetup
    private static void setup() {
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;
        
        Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        mo.Name = 'Telstra Collaboration';
        mo.Offer_ID__c = DataHandlerConstants.IOT_Offer_Id;
        insert mo ; 
        
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        	
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = dpReq.Id ; 
        dOffer.Name = 'Test';
        doffer.Marketable_Offer__c = mo.Id ; 
        insert dOffer ; 

        DPR_Offer_Line_Item__c dOLI = new DPR_Offer_Line_Item__c();
        dOLI.DPR_Offer__c=dOffer.Id;
        insert dOLI;

        List<cspmb__Rate_Card_Line__c> rcLines=new List<cspmb__Rate_Card_Line__c>();

        cspmb__Rate_Card__c rCardLTE= new cspmb__Rate_Card__c();
        rCardLTE.Name=DataHandlerConstants.IOt_LTE+' Plan';
        insert rCardLTE;

        cspmb__Rate_Card_Line__c rcLineLTE1 = new cspmb__Rate_Card_Line__c();
        rcLineLTE1.Name=DataHandlerConstants.IOt_LTE+' '+DataHandlerConstants.LTE_VolumeTier1;
        rcLineLTE1.cspmb__Rate_Card__c=rCardLTE.Id;
        rcLines.add(rcLineLTE1);
        cspmb__Rate_Card_Line__c rcLineLTE2 = new cspmb__Rate_Card_Line__c();
        rcLineLTE2.Name=DataHandlerConstants.IOt_LTE+' '+DataHandlerConstants.LTE_VolumeTier2;
        rcLineLTE2.cspmb__Rate_Card__c=rCardLTE.Id;
        rcLines.add(rcLineLTE2);
        cspmb__Rate_Card_Line__c rcLineLTE3 = new cspmb__Rate_Card_Line__c();
        rcLineLTE3.Name=DataHandlerConstants.IOt_LTE+' '+DataHandlerConstants.LTE_VolumeTier3;
        rcLineLTE3.cspmb__Rate_Card__c=rCardLTE.Id;
        rcLines.add(rcLineLTE3);
        cspmb__Rate_Card_Line__c rcLineLTE4 = new cspmb__Rate_Card_Line__c();
        rcLineLTE4.Name=DataHandlerConstants.IOt_LTE+' '+DataHandlerConstants.LTE_VolumeTier4;
        rcLineLTE4.cspmb__Rate_Card__c=rCardLTE.Id;
        rcLines.add(rcLineLTE4);
        cspmb__Rate_Card_Line__c rcLineLTE5 = new cspmb__Rate_Card_Line__c();
        rcLineLTE5.Name=DataHandlerConstants.IOt_LTE+' '+DataHandlerConstants.LTE_VolumeTier5;
        rcLineLTE5.cspmb__Rate_Card__c=rCardLTE.Id;
        rcLines.add(rcLineLTE5);

        cspmb__Rate_Card__c rCardLPWAN= new cspmb__Rate_Card__c();
        rCardLPWAN.Name=DataHandlerConstants.IOt_LPWAN+' Plan';
        insert rCardLPWAN;

        cspmb__Rate_Card_Line__c rcLineLPWAN1 = new cspmb__Rate_Card_Line__c();
        rcLineLPWAN1.Name=DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier1;
        rcLineLPWAN1.cspmb__Rate_Card__c=rCardLPWAN.Id;
        rcLines.add(rcLineLPWAN1);
        cspmb__Rate_Card_Line__c rcLineLPWAN2 = new cspmb__Rate_Card_Line__c();
        rcLineLPWAN2.Name=DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier2;
        rcLineLPWAN2.cspmb__Rate_Card__c=rCardLPWAN.Id;
        rcLines.add(rcLineLPWAN2);
        cspmb__Rate_Card_Line__c rcLineLPWAN3 = new cspmb__Rate_Card_Line__c();
        rcLineLPWAN3.Name=DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier3;
        rcLineLPWAN3.cspmb__Rate_Card__c=rCardLPWAN.Id;
        rcLines.add(rcLineLPWAN3);
        cspmb__Rate_Card_Line__c rcLineLPWAN4 = new cspmb__Rate_Card_Line__c();
        rcLineLPWAN4.Name=DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier4;
        rcLineLPWAN4.cspmb__Rate_Card__c=rCardLPWAN.Id;
        rcLines.add(rcLineLPWAN4);
        cspmb__Rate_Card_Line__c rcLineLPWAN5 = new cspmb__Rate_Card_Line__c();
        rcLineLPWAN5.Name=DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier5;
        rcLineLPWAN5.cspmb__Rate_Card__c=rCardLPWAN.Id;
        rcLines.add(rcLineLPWAN5);

		cspmb__Rate_Card__c rCardUtilities= new cspmb__Rate_Card__c();
        rCardUtilities.Name=DataHandlerConstants.IOt_Utilities+' Plan';
        insert rCardUtilities;

        cspmb__Rate_Card_Line__c rcLineUtilities1 = new cspmb__Rate_Card_Line__c();
        rcLineUtilities1.Name=DataHandlerConstants.IOt_Utilities+' '+DataHandlerConstants.Utilities_VolumeTier1;
        rcLineUtilities1.cspmb__Rate_Card__c=rCardUtilities.Id;
        rcLines.add(rcLineUtilities1);
        cspmb__Rate_Card_Line__c rcLineUtilities2 = new cspmb__Rate_Card_Line__c();
        rcLineUtilities2.Name=DataHandlerConstants.IOt_Utilities+' '+DataHandlerConstants.Utilities_VolumeTier2;
        rcLineUtilities2.cspmb__Rate_Card__c=rCardUtilities.Id;
        rcLines.add(rcLineUtilities2);
        cspmb__Rate_Card_Line__c rcLineUtilities3 = new cspmb__Rate_Card_Line__c();
        rcLineUtilities3.Name=DataHandlerConstants.IOt_Utilities+' '+DataHandlerConstants.Utilities_VolumeTier3;
        rcLineUtilities3.cspmb__Rate_Card__c=rCardUtilities.Id;
        rcLines.add(rcLineUtilities3);
        cspmb__Rate_Card_Line__c rcLineUtilities4 = new cspmb__Rate_Card_Line__c();
        rcLineUtilities4.Name=DataHandlerConstants.IOt_Utilities+' '+DataHandlerConstants.Utilities_VolumeTier4;
        rcLineUtilities4.cspmb__Rate_Card__c=rCardUtilities.Id;
        rcLines.add(rcLineUtilities4);
        cspmb__Rate_Card_Line__c rcLineUtilities5 = new cspmb__Rate_Card_Line__c();
        rcLineUtilities5.Name=DataHandlerConstants.IOt_Utilities+' '+DataHandlerConstants.Utilities_VolumeTier5;
        rcLineUtilities5.cspmb__Rate_Card__c=rCardUtilities.Id;
        rcLines.add(rcLineUtilities5);

        insert rcLines;

        List<DPR_Rate_Card__c> rateCards = new List<DPR_Rate_Card__c>();
        DPR_Rate_Card__c dRateCardP1 = new DPR_Rate_Card__c();
        dRateCardP1.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCardP1.Parent_DPR_Rate_Card_ID__c=null;
        dRateCardP1.DPR_RC_Negotiated_Value__c=0;
        dRateCardP1.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCardP1.Rate_Card__c=rCardLPWAN.Id;
		insert dRateCardP1;

        DPR_Rate_Card__c dRateCard1 = new DPR_Rate_Card__c();
        dRateCard1.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard1.Parent_DPR_Rate_Card_ID__c=dRateCardP1.Id;
        dRateCard1.DPR_RC_Negotiated_Value__c=1;
        dRateCard1.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard1.Rate_Card_Line__c=rcLineLPWAN1.Id;
		rateCards.add(dRateCard1);
        DPR_Rate_Card__c dRateCard2 = new DPR_Rate_Card__c();
        // dRateCard2.DPR_Rate_Card_Name__c = 'TEST RATE'+DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier2;
        dRateCard2.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard2.Parent_DPR_Rate_Card_ID__c=dRateCardP1.Id;
        dRateCard2.DPR_RC_Negotiated_Value__c=1;
        dRateCard2.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard2.Rate_Card_Line__c=rcLineLPWAN2.Id;
		rateCards.add(dRateCard2);
        DPR_Rate_Card__c dRateCard3 = new DPR_Rate_Card__c();
        // dRateCard3.DPR_Rate_Card_Name__c = 'TEST RATE'+DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier3;
        dRateCard3.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard3.Parent_DPR_Rate_Card_ID__c=dRateCardP1.Id;
        dRateCard3.DPR_RC_Negotiated_Value__c=1;
        dRateCard3.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard3.Rate_Card_Line__c=rcLineLPWAN3.Id;
		rateCards.add(dRateCard3);
        DPR_Rate_Card__c dRateCard4 = new DPR_Rate_Card__c();
        // dRateCard4.DPR_Rate_Card_Name__c = 'TEST RATE'+DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier4;
        dRateCard4.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard4.Parent_DPR_Rate_Card_ID__c=dRateCardP1.Id;
        dRateCard4.DPR_RC_Negotiated_Value__c=1;
        dRateCard4.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard4.Rate_Card_Line__c=rcLineLPWAN4.Id;
		rateCards.add(dRateCard4);
        DPR_Rate_Card__c dRateCard5 = new DPR_Rate_Card__c();
        // dRateCard5.DPR_Rate_Card_Name__c = 'TEST RATE'+DataHandlerConstants.IOt_LPWAN+' '+DataHandlerConstants.LPWAN_VolumeTier5;
        dRateCard5.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard5.Parent_DPR_Rate_Card_ID__c=dRateCardP1.Id;
        dRateCard5.DPR_RC_Negotiated_Value__c=1;
        dRateCard5.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard5.Rate_Card_Line__c=rcLineLPWAN5.Id;
		rateCards.add(dRateCard5);

        DPR_Rate_Card__c dRateCardP2 = new DPR_Rate_Card__c();
        // dRateCardP2.DPR_Rate_Card_Name__c = 'Test Rate'+DataHandlerConstants.IOt_LTE;
        dRateCardP2.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCardP2.Parent_DPR_Rate_Card_ID__c=null;
        dRateCardP2.DPR_RC_Negotiated_Value__c=0;
        dRateCardP2.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCardP2.Rate_Card__c=rCardLTE.Id;
		insert dRateCardP2;

        DPR_Rate_Card__c dRateCard6 = new DPR_Rate_Card__c();
        dRateCard6.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard6.Parent_DPR_Rate_Card_ID__c=dRateCardP2.Id;
        dRateCard6.DPR_RC_Negotiated_Value__c=1;
        dRateCard6.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard6.Rate_Card_Line__c=rcLineLTE1.Id;
		rateCards.add(dRateCard6);
        DPR_Rate_Card__c dRateCard7 = new DPR_Rate_Card__c();
        dRateCard7.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard7.Parent_DPR_Rate_Card_ID__c=dRateCardP2.Id;
        dRateCard7.DPR_RC_Negotiated_Value__c=1;
        dRateCard7.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard7.Rate_Card_Line__c=rcLineLTE2.Id;
		rateCards.add(dRateCard7);
        DPR_Rate_Card__c dRateCard8 = new DPR_Rate_Card__c();
        dRateCard8.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard8.Parent_DPR_Rate_Card_ID__c=dRateCardP2.Id;
        dRateCard8.DPR_RC_Negotiated_Value__c=1;
        dRateCard8.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard8.Rate_Card_Line__c=rcLineLTE3.Id;
		rateCards.add(dRateCard8);
        DPR_Rate_Card__c dRateCard9 = new DPR_Rate_Card__c();
        dRateCard9.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard9.Parent_DPR_Rate_Card_ID__c=dRateCardP2.Id;
        dRateCard9.DPR_RC_Negotiated_Value__c=1;
        dRateCard9.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard9.Rate_Card_Line__c=rcLineLTE4.Id;
		rateCards.add(dRateCard9);
        DPR_Rate_Card__c dRateCard10 = new DPR_Rate_Card__c();
        dRateCard10.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard10.Parent_DPR_Rate_Card_ID__c=dRateCardP2.Id;
        dRateCard10.DPR_RC_Negotiated_Value__c=1;
        dRateCard10.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard10.Rate_Card_Line__c=rcLineLTE5.Id;
		rateCards.add(dRateCard10);

        DPR_Rate_Card__c dRateCardP3 = new DPR_Rate_Card__c();
        dRateCardP3.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCardP3.Parent_DPR_Rate_Card_ID__c=null;
        dRateCardP3.DPR_RC_Negotiated_Value__c=0;
        dRateCardP3.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCardP3.Rate_Card__c=rCardUtilities.Id;
		insert dRateCardP3;

        DPR_Rate_Card__c dRateCard11 = new DPR_Rate_Card__c();
        dRateCard11.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard11.Parent_DPR_Rate_Card_ID__c=dRateCardP3.Id;
        dRateCard11.DPR_RC_Negotiated_Value__c=1;
        dRateCard11.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard11.Rate_Card_Line__c=rcLineUtilities1.Id;
		rateCards.add(dRateCard11);
        DPR_Rate_Card__c dRateCard12 = new DPR_Rate_Card__c();
        dRateCard12.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard12.Parent_DPR_Rate_Card_ID__c=dRateCardP3.Id;
        dRateCard12.DPR_RC_Negotiated_Value__c=1;
        dRateCard12.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard12.Rate_Card_Line__c=rcLineUtilities2.Id;
		rateCards.add(dRateCard12);
        DPR_Rate_Card__c dRateCard13 = new DPR_Rate_Card__c();
        dRateCard13.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard13.Parent_DPR_Rate_Card_ID__c=dRateCardP3.Id;
        dRateCard13.DPR_RC_Negotiated_Value__c=1;
        dRateCard13.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard13.Rate_Card_Line__c=rcLineUtilities3.Id;
		rateCards.add(dRateCard13);
        DPR_Rate_Card__c dRateCard14 = new DPR_Rate_Card__c();
        dRateCard14.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard14.Parent_DPR_Rate_Card_ID__c=dRateCardP3.Id;
        dRateCard14.DPR_RC_Negotiated_Value__c=1;
        dRateCard14.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard14.Rate_Card_Line__c=rcLineUtilities4.Id;
		rateCards.add(dRateCard14);
        DPR_Rate_Card__c dRateCard15 = new DPR_Rate_Card__c();
        dRateCard15.Delegated_Pricing_Request__c = dpReq.Id;
        dRateCard15.Parent_DPR_Rate_Card_ID__c=dRateCardP3.Id;
        dRateCard15.DPR_RC_Negotiated_Value__c=1;
        dRateCard15.Parent_DPR_OLI_id__c=dOLI.Id;
        dRateCard15.Rate_Card_Line__c=rcLineUtilities5.Id;
		rateCards.add(dRateCard15);

        insert rateCards;


    }
    @isTest
    public static void getIOTPlanRateCardLTETest(){
        IOTDealQuoteDataHandler dq = new IOTDealQuoteDataHandler();
        Delegated_Pricing_Request__c dpr =[SELECT Id FROM Delegated_Pricing_Request__c limit 1];
        Map<String,String> subfilters = new Map<String,String>();
        subfilters.put('Query_Type', DataHandlerConstants.IOt_LTE);
        Test.startTest();
        dq.getIOTPlanRateCard(dpr.Id, subfilters);
        Test.stopTest();
    }
    @isTest
    public static void getIOTPlanRateCardLPWANTest(){
        IOTDealQuoteDataHandler dq = new IOTDealQuoteDataHandler();
        Delegated_Pricing_Request__c dpr =[SELECT Id FROM Delegated_Pricing_Request__c limit 1];
        Map<String,String> subfilters = new Map<String,String>();
        subfilters.put('Query_Type', DataHandlerConstants.IOt_LPWAN);
        Test.startTest();
        dq.getIOTPlanRateCard(dpr.Id, subfilters);
        Test.stopTest();
    }
    @isTest
    public static void getIOTPlanRateCardUtilitiesTest(){
        IOTDealQuoteDataHandler dq = new IOTDealQuoteDataHandler();
        Delegated_Pricing_Request__c dpr =[SELECT Id FROM Delegated_Pricing_Request__c limit 1];
        Map<String,String> subfilters = new Map<String,String>();
        subfilters.put('Query_Type', DataHandlerConstants.IOt_Utilities);
        Test.startTest();
        dq.getIOTPlanRateCard(dpr.Id, subfilters);
        Test.stopTest();
    }
    @isTest 
    public static void getQuantityTest(){
        IOTDealQuoteDataHandler dq = new IOTDealQuoteDataHandler();
        Test.startTest();
        dq.getQuantity(1,1);
        dq.getQuantity(-1,1);
        dq.getQuantity(1,-1);
        Test.stopTest();
    }
}
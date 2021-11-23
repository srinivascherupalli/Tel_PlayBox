/* 
* @Author : Monali Golhar
* @Date : 19th May 2021 
* @Desc : Test TCDealQuoteDataHandler 
* @Jira : EDGE-134662 
*/

@isTest
public class TCDealQuoteDataHandlerTest {
    private void setup() {
        //Account 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;
        //Opportunity 
         Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        
        Marketable_Offer__c mo = new Marketable_Offer__c();
        mo.OfferDefinationName__c ='Telstra Collaboration Solution' ;
        mo.Name = 'Telstra Collaboration';
        mo.Offer_ID__c = 'DMCAT_Offer_000618';
        insert mo ; 
        
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
        	
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = dpReq.Id ; 
        dOffer.Name = 'Test';
        doffer.Marketable_Offer__c = mo.Id ; 
        insert dOffer ; 
        
        List<cspmb__Price_Item__c> cpList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c cProduct = new cspmb__Price_Item__c(); 
        cProduct.Billing_Description__c = 'One Access 8 fxs 8 port integrated access device';
        cProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_000622';
        cProduct.cspmb__Recurring_Charge__c = 18.18;	 
        cProduct.Type__c = 'IADs'; 
        cProduct.Offer_ID__c  = 'DMCAT_Offer_000618';
        cpList.add(cProduct); 
        
        cspmb__Price_Item__c cProducta = new cspmb__Price_Item__c();
        cProducta.Billing_Description__c = 'Cisco power adapter for IP phones 88xx series repayment';
        cProducta.ProdSpecId__c = 'DMCAT_ProductSpecification_000623';
        cProducta.cspmb__Recurring_Charge__c = 18.18;
        cProducta.Type__c = 'Power Supply';
        cpList.add(cProducta);
        
        
        insert cpList;
       
	    
        List<DPR_Offer_Line_Item__c> dprList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprDevice = New DPR_Offer_Line_Item__c();
        dprDevice.cspmb_Price_Item__c = cpList[0].Id; 
        dprDevice.Quantity__c = 5;
        dprDevice.List_Price__c =40;
        dprDevice.DPR_Offer__c = dOffer.Id ; 
        dprDevice.DPR_Offer_line_item_value__c = 30;
        dprDevice.Delegated_Pricing_Request__c = dpReq.Id;
        dprDevice.Overridden_Total_Price__c = 150 ;
        dprDevice.isNegotiableCharge__c = true ;
        dprList.add(dprDevice);
        
       
        
        DPR_Offer_Line_Item__c dprAccesory = New DPR_Offer_Line_Item__c();
        dprAccesory.cspmb_Price_Item__c = cpList[1].Id; 
        dprAccesory.Quantity__c = 5;
        dprAccesory.List_Price__c =40;
        dprAccesory.DPR_Offer__c = dOffer.Id ; 
        dprAccesory.DPR_Offer_line_item_value__c = 35;
        dprAccesory.Offer_Type_Name__c = 'Enterprise Wireless';
        dprAccesory.Delegated_Pricing_Request__c = dpReq.Id;
        dprAccesory.Overridden_Total_Price__c = 175;
        dprAccesory.isNegotiableCharge__c = true ;
        dprList.add(dprAccesory);
      
        insert dprList ; 
        
        cspmb__Rate_Card__c rc = new cspmb__Rate_Card__c(
            Name = 'Shared line - standard calling plan',
            Offer_Id__c ='DMCAT_Offer_000618',
            cspmb__Rate_Card_Code__c = 'ucUsers', 
            cspmb__Effective_End_Date__c = Date.today()+1,
            cspmb__Effective_Start_Date__c = Date.today()-1,
            cspmb__Is_Active__c = true);
        insert rc;
        List<cspmb__Rate_Card_Line__c> rateCardLineList = new List<cspmb__Rate_Card_Line__c>();
        cspmb__Rate_Card_Line__c rcl1 =PricingTestDataFactory.generateRateCardLine(10,1,rc.id,'1');
        rcl1.cspmb__rate_value__c = 1.5;
        rcl1.Name= 'Shared line - standard calling plan (1 to 10)';
        rateCardLineList.add(rcl1);
        cspmb__Rate_Card_Line__c rcl2 =PricingTestDataFactory.generateRateCardLine(20,11,rc.id,'1');
        rcl2.cspmb__rate_value__c = 2.5;
        rcl2.Name= 'Shared line - standard calling plan (11 to 20)';
        rateCardLineList.add(rcl2);
        cspmb__Rate_Card_Line__c rcl3 =PricingTestDataFactory.generateRateCardLine(50,21,rc.id,'1');
        rcl3.cspmb__rate_value__c = 2.5;
        rcl3.Name= 'Shared line - standard calling plan (21 to 50)';
        rateCardLineList.add(rcl3);
        cspmb__Rate_Card_Line__c rcl4 =PricingTestDataFactory.generateRateCardLine(200,51,rc.id,'1');
        rcl4.cspmb__rate_value__c = 2.5;
        rcl4.Name= 'Shared line - standard calling plan (51 to 200)';
        rateCardLineList.add(rcl4);
        cspmb__Rate_Card_Line__c rcl5 =PricingTestDataFactory.generateRateCardLine(500,201,rc.id,'1');
        rcl5.cspmb__rate_value__c = 2.5;
        rcl5.Name= 'Shared line - standard calling plan (201 to 500)';
        rateCardLineList.add(rcl5);
        cspmb__Rate_Card_Line__c rcl6 =PricingTestDataFactory.generateRateCardLine(99999,501,rc.id,'1');
        rcl6.cspmb__rate_value__c = 2.5;
        rcl6.Name= 'Shared line - standard calling plan (501 to 99999)';
        rateCardLineList.add(rcl6);
        insert rateCardLineList;
        
        DPR_Rate_Card__c rcObj=new DPR_Rate_Card__c();
        rcObj.Delegated_Pricing_Request__c=dpReq.Id;
        rcObj.DPR_Rate_Card_Type__c='Rate Card';
        rcObj.Parent_DPR_OLI_id__c=dprList[0].Id;
        rcObj.Rate_Card__c=rc.ID;
        Insert rcObj;
        
        List<DPR_Rate_Card__c> rcl = new List<DPR_Rate_Card__c>();
        DPR_Rate_Card__c rclObj=new DPR_Rate_Card__c();
        rclObj.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj.DPR_RC_Negotiated_Value__c=12;
        rclObj.Negotiated_Discount__c=5;
        rclObj.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj.Rate_Card_Line__c=rcl1.Id;
        rcl.add(rclObj);
        DPR_Rate_Card__c rclObj1=new DPR_Rate_Card__c();
        rclObj1.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj1.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj1.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj1.DPR_RC_Negotiated_Value__c=12;
        rclObj1.Negotiated_Discount__c=5;
        rclObj1.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj1.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj1.Rate_Card_Line__c=rcl2.Id;
        rcl.add(rclObj1);
        DPR_Rate_Card__c rclObj2=new DPR_Rate_Card__c();
        rclObj2.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj2.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj2.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj2.DPR_RC_Negotiated_Value__c=12;
        rclObj2.Negotiated_Discount__c=5;
        rclObj2.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj2.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj2.Rate_Card_Line__c=rcl3.Id;
        rcl.add(rclObj2);
        DPR_Rate_Card__c rclObj3=new DPR_Rate_Card__c();
        rclObj3.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj3.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj3.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj3.DPR_RC_Negotiated_Value__c=12;
        rclObj3.Negotiated_Discount__c=5;
        rclObj3.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj3.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj3.Rate_Card_Line__c=rcl4.Id;
        rcl.add(rclObj3);
        DPR_Rate_Card__c rclObj4=new DPR_Rate_Card__c();
        rclObj4.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj4.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj4.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj4.DPR_RC_Negotiated_Value__c=12;
        rclObj4.Negotiated_Discount__c=5;
        rclObj4.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj4.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj4.Rate_Card_Line__c=rcl5.Id;
        rcl.add(rclObj4);
        DPR_Rate_Card__c rclObj5=new DPR_Rate_Card__c();
        rclObj5.Parent_DPR_OLI_id__c=rcObj.Parent_DPR_OLI_id__c;
        rclObj5.Delegated_Pricing_Request__c=rcObj.Delegated_Pricing_Request__c;
        rclObj5.DPR_Rate_Card_Type__c='Rate Card Line';
        rclObj5.DPR_RC_Negotiated_Value__c=12;
        rclObj5.Negotiated_Discount__c=5;
        rclObj5.Parent_DPR_Rate_Card_ID__c=rcObj.Id;
        rclObj5.Rate_Card__c=rcObj.Rate_Card__c;
        rclObj5.Rate_Card_Line__c=rcl6.Id;
        rcl.add(rclObj5);
        insert rcl;
    }
   @isTest  static void getPlansTest(){
        AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
 		list<String> productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ApexConstant')); 
		system.debug(productSpecCodes); 
		Map<String,String> allConst = new Map<String,String>(); 
		List<String> t = null;  
		For(String v:productSpecCodes){
 		    t = v.split(':'); 
 			allConst.put(t[0],t[1]);
		}
		system.debug(allConst); 
       TCDealQuoteDataHandlerTest dqTest = new TCDealQuoteDataHandlerTest();
       TCDealQuoteDataHandler dq = new TCDealQuoteDataHandler();
       Test.startTest(); 
       dqTest.setup();
       List<DPR_Offer_Line_Item__c> dprList = [Select Quantity__c,Recontracting_Quantity__c,List_Price__c,DPR_Offer_line_item_value__c,Delegated_Pricing_Request__r.Id From DPR_Offer_Line_Item__c];
       system.debug('dprList'+dprList);
       List<Map<String,Object>> tcRow =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuoteTC'}); 
       List<Map<String,Object>> rcRow =dq.getTCPlanRateCard(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'TCRateCard'}); 
       Decimal q = dq.getQuantity(5,10);
       Decimal q1 = dq.getQuantity(null,10);
       Decimal q2 = dq.getQuantity(5,null);
       Test.stopTest();
       system.debug('tcRow: '+tcRow);
       System.assertEquals('10.00',tcRow[0].get('VolumeTier3'));
       System.assertEquals(5,tcRow[0].get('Quantity'));
       System.assertEquals('One Access 8 fxs 8 port integrated access device Repayment',tcRow[0].get('Product_Module_Name'));
   	   System.assertEquals('Shared line - standard calling plan',rcRow[0].get('Product_Module_Name'));
       System.assertEquals(15,q);
	
   }
    @isTest static void getConstantTest(){
         DealQuoteDataHandler dq = new DealQuoteDataHandler();
         Test.startTest(); 
         Map<String,String> constList =  dq.getConstant();
         Test.stopTest();
         System.assert(constList.get('DPRDealQuotePlanHH') == 'DPR_DealQuotePlanHH');
    }
    }
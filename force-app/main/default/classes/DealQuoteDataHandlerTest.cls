/* 
* @Author : Monali Golhar
* @Date : 15th  October 2020 
* @Desc : Test DealQuoteDataHandler 
* @Jira : EDGE-180110 
*/
/***History of Updates 
* Yash :  2/11/2020  EDGE-177567  Add detailed tables for NEW services being taken up in deal journey(FAM)
*/

@isTest
public class DealQuoteDataHandlerTest {
    private void setup() {
        //Account 
        Account acc = AccountTestFactory.buildAccount('TestAcc');
        insert acc;
        //Opportunity 
         Opportunity opp  = ProductTestFactory.getOpportunityBasic(acc);
        insert opp;
        //Delegated Pricing Request 
        Delegated_Pricing_Request__c dpReq = new Delegated_Pricing_Request__c();
        dpReq.Opportunity__c = opp.Id;
        insert dpReq ; 
            
        DPR_Offer__c dOffer = new DPR_Offer__c();
        dOffer.Delegated_Pricing_Request__c = dpReq.Id ; 
        dOffer.Name = 'Test';
        insert dOffer ; 
        
        List<cspmb__Price_Item__c> cpList = new List<cspmb__Price_Item__c>();
        cspmb__Price_Item__c cProduct = new cspmb__Price_Item__c();
        cProduct.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; //EDGE-177567
        cProduct.cspmb__Recurring_Charge__c = 18.18;
        cProduct.Type__c = 'Handheld';
        cpList.add(cProduct);
        
        cspmb__Price_Item__c cProducta = new cspmb__Price_Item__c();
        cProducta.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProducta.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; //EDGE-177567
        cProducta.cspmb__Recurring_Charge__c = 18.18;
        cProducta.Type__c = 'Enterprise Wireless';
        cpList.add(cProducta);
        
        cspmb__Price_Item__c cProductb = new cspmb__Price_Item__c();
        cProductb.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProductb.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; //EDGE-177567
        cProductb.cspmb__Recurring_Charge__c = 18.18;
        cProductb.Type__c = 'Mobile Broadband';
        cpList.add(cProductb);
        
        cspmb__Price_Item__c cProduct1 = new cspmb__Price_Item__c();
        cProduct1.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct1.ChargeType__c = 'OC'; //EDGE-177567
        cProduct1.ProdSpecId__c = 'DMCAT_ProductSpecification_001211'; //EDGE-177567
        cProduct1.cspmb__Recurring_Charge__c = 18.18;
        cpList.add(cProduct1);
        
        cspmb__Price_Item__c cProduct2 = new cspmb__Price_Item__c();
        cProduct2.Billing_Description__c = 'Mobile Broadband Essential Plan';
        cProduct2.ProdSpecId__c = 'DMCAT_ProductSpecification_001211';
        cProduct2.ChargeType__c = 'RC'; //EDGE-177567
        cProduct2.cspmb__One_Off_Charge__c = 18.18;
        cpList.add(cProduct2);
        
        insert cpList;
        
        List<cspmb__Add_On_Price_Item__c> ofcpList = new List<cspmb__Add_On_Price_Item__c >();
        cspmb__Add_On_Price_Item__c  ofcProduct = new cspmb__Add_On_Price_Item__c ();
        ofcProduct.Billing_Description__c = 'AppleCare+ 2 years iPad 9.7';
        ofcProduct.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; //EDGE-177567
        ofcProduct.cspmb__Recurring_Charge__c = 18.18;
        ofcProduct.Type__c = 'Handheld';
        ofcpList.add(ofcProduct);
        
        cspmb__Add_On_Price_Item__c  ofcProduct1 = new cspmb__Add_On_Price_Item__c ();
        ofcProduct1.Billing_Description__c = 'Transition Mobile Device Charge';
        ofcProduct1.ProdSpecId__c = 'DMCAT_ProductSpecification_001196'; //EDGE-177567
        ofcProduct1.cspmb__Recurring_Charge__c = 18.18;
        ofcProduct1.Type__c = 'Handheld';
        ofcpList.add(ofcProduct1);
        insert ofcpList;
        
        //EDGE-177567 - Start
        List<DPR_Offer_Line_Item__c> dprList = new List<DPR_Offer_Line_Item__c>();
        DPR_Offer_Line_Item__c dprLineItemHH = New DPR_Offer_Line_Item__c();
        dprLineItemHH.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH.Quantity__c = 5;
        dprLineItemHH.List_Price__c =40;
        dprLineItemHH.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH.Delegated_Pricing_Request__c = dpReq.Id;
        dprLineItemHH.Overridden_Total_Price__c = 150 ;
        dprLineItemHH.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemHH);
        
       
        
        DPR_Offer_Line_Item__c dprLineItemWLS = New DPR_Offer_Line_Item__c();
        dprLineItemWLS.cspmb_Price_Item__c = cpList[1].Id; 
        dprLineItemWLS.Quantity__c = 5;
        dprLineItemWLS.List_Price__c =40;
        dprLineItemWLS.DPR_Offer__c = dOffer.Id ; 
        dprLineItemWLS.DPR_Offer_line_item_value__c = 35;
        dprLineItemWLS.Offer_Type_Name__c = 'Enterprise Wireless';
        dprLineItemWLS.Delegated_Pricing_Request__c = dpReq.Id;
        dprLineItemWLS.Overridden_Total_Price__c = 175;
     //   dprLineItemWLS.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemWLS);
        
        DPR_Offer_Line_Item__c dprLineItemMBB = New DPR_Offer_Line_Item__c();
        dprLineItemMBB.cspmb_Price_Item__c = cpList[2].Id; 
        dprLineItemMBB.Quantity__c = 5;
        dprLineItemMBB.List_Price__c =40;
        dprLineItemMBB.DPR_Offer__c = dOffer.Id ; 
        dprLineItemMBB.DPR_Offer_line_item_value__c = 20;
        dprLineItemMBB.Offer_Type_Name__c = 'Mobile Broadband';
        dprLineItemMBB.Delegated_Pricing_Request__c = dpReq.Id;
        dprLineItemMBB.Overridden_Total_Price__c = 100;
        dprLineItemMBB.isNegotiableCharge__c = true ;
        dprList.add(dprLineItemMBB);
        //EDGE-177567 - End
        
        
        DPR_Offer_Line_Item__c dprLineItem2 = New DPR_Offer_Line_Item__c();
        dprLineItem2.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem2.Quantity__c = 15;
        dprLineItem2.List_Price__c =25;
        dprLineItem2.DPR_Offer__c = dOffer.Id ; 
        dprLineItem2.DPR_Offer_line_item_value__c = 30;
        dprLineItem2.Delegated_Pricing_Request__c = dpReq.Id; //EDGE-177567
        dprLineItem2.Overridden_Total_Price__c = 750;
        dprLineItem2.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem2);
        
        DPR_Offer_Line_Item__c dprLineItem4 = New DPR_Offer_Line_Item__c();
        dprLineItem4.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem4.Quantity__c = 15;
        dprLineItem4.List_Price__c =25;
        dprLineItem4.DPR_Offer__c = dOffer.Id ; 
        dprLineItem4.DPR_Offer_line_item_value__c = 30;
        dprLineItem4.Delegated_Pricing_Request__c = dpReq.Id; //EDGE-177567
        dprLineItem4.Overridden_Total_Price__c = 750;
        dprLineItem4.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem4);
        
        DPR_Offer_Line_Item__c dprLineItem1 = New DPR_Offer_Line_Item__c();
        dprLineItem1.cspmb_Price_Item__c = cpList[3].Id; 
      //  dprLineItem1.cspmb_Add_On_Price_Item__c = ofcpList[0].Id;
        dprLineItem1.Quantity__c = 5;
        dprLineItem1.List_Price__c =25;
        dprLineItem1.DPR_Offer__c = dOffer.Id ;
        dprLineItem1.Delegated_Pricing_Request__c = dpReq.Id; //EDGE-177567
        dprLineItem1.Overridden_Total_Price__c = 124;
      //  dprLineItem1.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        dprList.add(dprLineItem1);
        
        DPR_Offer_Line_Item__c dprLineItem3 = New DPR_Offer_Line_Item__c();
        dprLineItem3.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem3.Quantity__c = 15;
        dprLineItem3.List_Price__c =25;
        dprLineItem3.DPR_Offer__c = dOffer.Id ; 
        dprLineItem3.DPR_Offer_line_item_value__c = 30;
        dprLineItem3.Delegated_Pricing_Request__c = dpReq.Id; //EDGE-177567
        dprLineItem3.Overridden_Total_Price__c = 750;
        dprList.add(dprLineItem3);
        insert dprList ; 
        
        DPR_Offer_Line_Item__c dprLineItem5 = New DPR_Offer_Line_Item__c();
        dprLineItem5.cspmb_Price_Item__c = cpList[4].Id; 
        dprLineItem5.cspmb_Add_On_Price_Item__c = ofcpList[0].Id;
        dprLineItem5.Quantity__c = 5;
        dprLineItem5.Recontracting_Quantity__c = 5;
        dprLineItem5.List_Price__c =25;
        dprLineItem5.DPR_Offer__c = dOffer.Id ;
        dprLineItem5.Delegated_Pricing_Request__c = dpReq.Id; //EDGE-177567
        dprLineItem5.Overridden_Total_Price__c = 124;
        dprLineItem5.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        dprLineItem5.isNegotiableCharge__c = true ;
        dprList.add(dprLineItem5);
        
        //EDGE-189035 : Added child plans to check bolton implemantation 
        DPR_Offer_Line_Item__c dprLineItemHH1 = New DPR_Offer_Line_Item__c();
        dprLineItemHH1.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH1.cspmb_Add_On_Price_Item__c = ofcpList[1].Id;
        dprLineItemHH1.Quantity__c = 5;
        dprLineItemHH1.List_Price__c =40;
        dprLineItemHH1.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH1.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH1.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH1.Delegated_Pricing_Request__c = dpReq.Id;
        dprLineItemHH1.Overridden_Total_Price__c = 150 ;
        dprLineItemHH1.isNegotiableCharge__c = true ;
        dprLineItemHH1.Parent_DPR_Offer_Line_Item_Id__c = dprLineItemHH.Id; 
        dprLineItemHH1.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        insert dprLineItemHH1 ; 
        
        DPR_Offer_Line_Item__c dprLineItemHH2 = New DPR_Offer_Line_Item__c();
        dprLineItemHH2.cspmb_Price_Item__c = cpList[0].Id; 
        dprLineItemHH2.cspmb_Add_On_Price_Item__c = ofcpList[1].Id;
        dprLineItemHH2.Quantity__c = 5;
        dprLineItemHH2.List_Price__c =40;
        dprLineItemHH2.DPR_Offer__c = dOffer.Id ; 
        dprLineItemHH2.DPR_Offer_line_item_value__c = 30;
        dprLineItemHH2.Offer_Type_Name__c = 'Handheld';
        dprLineItemHH2.Delegated_Pricing_Request__c = dpReq.Id;
        dprLineItemHH2.Overridden_Total_Price__c = 150 ;
       //  dprLineItemHH2.isNegotiableCharge__c = true ;        //EDGE-205310 When bolton is not negotiable  
        dprLineItemHH2.Parent_DPR_Offer_Line_Item_Id__c = dprLineItemHH.Id; 
        dprLineItemHH2.DPR_Offer_Line_Item_Type__c = 'Addon'; 
        insert dprLineItemHH2 ; 
        //EDGE-189035 End
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
       DealQuoteDataHandlerTest dqTest = new DealQuoteDataHandlerTest();
       DealQuoteDataHandler dq = new DealQuoteDataHandler();
       Test.startTest(); //EDGE-177567
       dqTest.setup();
       //EDGE-177567 - Start
       List<DPR_Offer_Line_Item__c> dprList = [Select Quantity__c,Recontracting_Quantity__c,List_Price__c,DPR_Offer_line_item_value__c,Delegated_Pricing_Request__r.Id From DPR_Offer_Line_Item__c];
       system.debug('dprList'+dprList);
       List<Map<String,Object>> planRowsHH =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuotePlanHH'});
       List<Map<String,Object>> planRowsWLS =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuotePlanWLS'});
       List<Map<String,Object>> planRowsMBB =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuotePlanMBB'});
       List<Map<String,Object>> deviceRCRows =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuoteDeviceRC'});
       List<Map<String,Object>> deviceOCRows =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPR_DealQuoteDeviceOC'}); //EDGE-189035
       Test.stopTest(); //EDGE-177567
       system.debug('planRowsHH: '+planRowsHH+'\r\nplanRowsWLS: '+planRowsWLS+'\r\nplanRowsMBB: '+planRowsMBB+'\r\ndeviceRCRows: '+deviceRCRows);
       System.assertEquals('10.00',planRowsHH[0].get('VolumeTier3'));
       System.assertEquals('5.00',planRowsWLS[0].get('VolumeTier3'));
       System.assertEquals('20.00',planRowsMBB[0].get('VolumeTier3'));
       System.assertEquals('N/A',deviceRCRows[0].get('VolumeTier3'));
       //EDGE-189035
       System.assertEquals(30,deviceRCRows[0].get('Quantity'));
       System.assertEquals('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Transition Mobile Device Charge',planRowsHH[1].get('Product_Module_Name'));
       System.assertEquals(true,deviceOCRows.isempty()); //EDGE-205310 As device is not negotiable 
       System.assertEquals(2,planRowsHH.size()); //EDGE-205310 one plan and one bolton as other bolton is not negotiable 
       //EDGE-177567 - End
   }
    @isTest  static void getPlansTestNeg(){
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
        DealQuoteDataHandlerTest dqTest = new DealQuoteDataHandlerTest();
        DealQuoteDataHandler dq = new DealQuoteDataHandler();
        Test.startTest(); //EDGE-177567
        dqTest.setup();
        List<DPR_Offer_Line_Item__c> dprList = [Select cspmb_Price_Item__c,Quantity__c,List_Price__c,DPR_Offer_line_item_value__c,DPR_Offer__r.Id From DPR_Offer_Line_Item__c ];
        List<Map<String,Object>> listd= dq.getNewDPRPlan(dprList,allConst);
        Test.stopTest(); //EDGE-177567
        System.assert(listd.isEmpty() == true);
        List<Map<String,Object>> planRows =dq.getRows(dprList[0].DPR_Offer__r.Id ,new Map<String,String>{'Type'=>'DPR_DealQuote'});
        System.assert(planRows.isEmpty() == true);
   }
    @isTest static void getConstantTest(){
         DealQuoteDataHandler dq = new DealQuoteDataHandler();
         Test.startTest(); //EDGE-177567
         Map<String,String> constList =  dq.getConstant();
         Test.stopTest(); //EDGE-177567
         System.assert(constList.get('DPRDealQuotePlanHH') == 'DPR_DealQuotePlanHH'); //EDGE-177567
    }
    @isTest  static void getDPRConditionalCheckTest(){
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
       DealQuoteDataHandlerTest dqTest = new DealQuoteDataHandlerTest();
       DealQuoteDataHandler dq = new DealQuoteDataHandler();
       Test.startTest(); 
       dqTest.setup();
       List<DPR_Offer_Line_Item__c> dprList = [Select Quantity__c,List_Price__c,DPR_Offer_line_item_value__c,Delegated_Pricing_Request__r.Id From DPR_Offer_Line_Item__c];
       system.debug('dprList'+dprList);
       List<Map<String,Object>> conditionaRow =dq.getRows(dprList[0].Delegated_Pricing_Request__r.Id,new Map<String,String>{'Query_Type'=>'DPRQuoteConditionalCheck'});
       Test.stopTest(); 
       system.debug('conditionaRow: '+conditionaRow);
       System.assertEquals(true,conditionaRow[0].get('is_TC'));
        }
   
}
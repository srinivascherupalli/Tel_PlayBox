/* 
* @Author : Monali 
* @Date : 15/10/2020
* @Desc : Custom Apex Connector for ExternalObject BasketSnapshot, for obtaining DPR Line Items to be displayed in quote
* @Jira : EDGE-180110 
*/
/***History of Updates 
* Yash :  2/11/2020  EDGE-177567  Add detailed tables for NEW services being taken up in deal journey(FAM)
* Monali : 3/11/2020 Added method to populate boolean field checks 
* Monali : 15/11/2020 EDGE-189035 To display devices, device care, plan bolton 
* Monali : 03/06/2021  EDGE-134662 : Code to update isNGEM field on basket snapshot in order to hide AM tables in case of all TC Product . 
* Monali : 04/06/2021  EDGE-205310 : INC000095052281 : Remove non-negotiated items(Devices and Boltons only) from a deal quote generated from FA journey
*/

public with sharing class DealQuoteDataHandler {
    /* Passing apropriate query result according to query type in getNewDPRPlan method and return Deal Quote Plan/Device rows 
     * Calling Method :ProductBasketDataSourceConnection
      */
     static final String DPRDealQuotePlanHH = 'DPRDealQuotePlanHH';
     static final String DPRDealQuotePlanWLS = 'DPRDealQuotePlanWLS';
     static final String  DPRDealQuotePlanMBB = 'DPRDealQuotePlanMBB';
     static final String  DPRDealQuoteDeviceOC = 'DPRDealQuoteDeviceOC';
     static final String DPRDealQuoteDeviceRC = 'DPRDealQuoteDeviceRC'; 
     static final String DPRQuoteConditionalCheck = 'DPRQuoteConditionalCheck';
     public List<Map<String,Object>> getRows(String dprId, Map<String,String> subfilters){
         List<Map<String,Object>> rows = new List<Map<String,Object>>();
         List<DPR_Offer_Line_Item__c> dprRows = new List<DPR_Offer_Line_Item__c>();
         Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();     
         List<String> specIdList = new List<String>();
         List<String> specIdListDevice = new List<String>();
         Map<String,String> allConst = new Map<String,String>();
         String offerType = ''; //EDGE-177567
         try{
             allConst = getConstant();
             List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];    
             for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){    
                     if(ngemSpec.ProductCategory__c==allConst.get('NGEMPlan')){    
                         map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                         specIdList.add(ngemSpec.ProdSpecId__c); 
                     }   
                     if(ngemSpec.ProductCategory__c==allConst.get('NGEM')){    
                         map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                         specIdListDevice.add(ngemSpec.ProdSpecId__c); 
                     } 
             }
         //EDGE-177567 - Start
            
             String dprQuery ;
             String dprQueryDevice = 'SELECT cspmb_Add_On_Price_Item__r.Billing_Description__c,cspmb_Price_Item__r.Billing_Description__c,Quantity__c,List_Price__c,DPR_Offer_Line_Item_Type__c, DPR_Offer_line_item_value__c ,cspmb_Price_Item__r.Type__c,cspmb_Price_Item__r.ProdSpecId__c,Parent_DPR_Offer_Line_Item_Id__c,Delegated_Pricing_Request__r.Name,Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c,Recontracting_Quantity__c,Overridden_Total_Price__c,Delegated_Pricing_Request__r.id,Offer_Type_Name__c,Delegated_Pricing_Request__r.Opportunity__r.Contract_Term__c,cspmb_Price_Item__r.ChargeType__c  from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__r.id = :dprId AND isNegotiableCharge__c = true '; //EDGE-189035 Query for Devices , removed parentId check to include Device Care OLI //EDGE-205310 Added isnegotiable check  
             
             String dprQueryPlan = 'SELECT cspmb_Price_Item__r.Billing_Description__c,isNegotiableCharge__c,Quantity__c,List_Price__c,DPR_Offer_Line_Item_Type__c, DPR_Offer_line_item_value__c ,cspmb_Price_Item__r.Type__c,cspmb_Price_Item__r.ProdSpecId__c,Parent_DPR_Offer_Line_Item_Id__c,Delegated_Pricing_Request__r.Name,Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c,Recontracting_Quantity__c,Overridden_Total_Price__c,Delegated_Pricing_Request__r.id,Offer_Type_Name__c,(SELECT cspmb_Add_On_Price_Item__r.Billing_Description__c,cspmb_Price_Item__r.Billing_Description__c,Quantity__c,List_Price__c,DPR_Offer_Line_Item_Type__c, DPR_Offer_line_item_value__c ,cspmb_Price_Item__r.Type__c,cspmb_Price_Item__r.ProdSpecId__c,Parent_DPR_Offer_Line_Item_Id__c,Delegated_Pricing_Request__r.Name,Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c,Recontracting_Quantity__c,Overridden_Total_Price__c,Delegated_Pricing_Request__r.id,Offer_Type_Name__c  from DPR_Offer_Line_Items__r WHERE isNegotiableCharge__c = true )  from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__r.id = :dprId and Parent_DPR_Offer_Line_Item_Id__c = null'; //EDGE-205310 Added isnegotiable check to the inner query 
              //EDGE-189035 Query for plans , added inner query to get related Addons OLI 
             if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanHH) || subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanWLS) || subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanMBB)){ //EDGE-189035 If condition to identify plan query  
             if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanHH)){
                 offerType = allConst.get('offerTypeHH');
                 dprQuery = dprQueryPlan +  ' AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdList AND cspmb_Price_Item__r.Type__c =:offerType' ; //Fetching Type from Comemrcial Product
                 system.debug('***Telstra:DealQuoteHandler:getRowsHH:specIdList '+specIdList+'offerType: '+offerType);
             } 
             else if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanWLS)){
                 offerType = allConst.get('offerTypeWLS');
                 dprQuery = dprQueryPlan +  ' AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdList AND cspmb_Price_Item__r.Type__c =:offerType' ; //Fetching Type from Comemrcial Product
                 system.debug('***Telstra:DealQuoteHandler:getRowsWLS:specIdList '+specIdList+'offerType: '+offerType);
             }
             else if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuotePlanMBB)){
                 offerType = allConst.get('offerTypeMBB');
                 dprQuery = dprQueryPlan +  ' AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdList AND cspmb_Price_Item__r.Type__c =:offerType' ; //Fetching Type from Comemrcial Product
                 system.debug('***Telstra:DealQuoteHandler:getRowsMBB:specIdList '+specIdList+'offerType: '+offerType);
             }
             dprRows =Database.query(dprQuery);
             system.debug('***Telstra:DealQuoteHandler:getRowsMBB:specIdList '+specIdList+'dprRows: '+dprRows);
             return  getNewDPRPlan(dprRows,allConst);
             }
             if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuoteDeviceOC) || subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuoteDeviceRC)){ //EDGE-189035 If condition to identify device query  
             if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuoteDeviceOC)){
                 offerType = allConst.get('deviceTypeOC');
                 dprQuery = dprQueryDevice + 'AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdListDevice AND cspmb_Price_Item__r.ChargeType__c =:offerType';
                 system.debug('***Telstra:DealQuoteHandler:getRows:specIdListDeviceOC '+specIdListDevice+'offerType: '+offerType);
             }
             else if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRDealQuoteDeviceRC)){
                 offerType = allConst.get('deviceTypeRC');
                 dprQuery = dprQueryDevice + 'AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdListDevice AND cspmb_Price_Item__r.ChargeType__c =:offerType';
                 system.debug('***Telstra:DealQuoteHandler:getRows:specIdListDeviceRC '+specIdListDevice+'offerType: '+offerType);
                 system.debug('dprRows*******'+dprRows);  
             }
             dprRows =Database.query(dprQuery);
             return getNewDPRDevice(dprRows,allConst);
             }
             if(subfilters.get(allConst.get('QueryType')) == allConst.get(DPRQuoteConditionalCheck)){
                 dprQuery = dprQueryDevice;
                 system.debug('***Telstra:DealQuoteHandler:getRows:specIdListDeviceRC '+specIdListDevice+'offerType: '+offerType);
                
                  dprRows =Database.query(dprQuery);
                  system.debug('dprRows*******'+dprRows); 
                  return getDPRConditionalCheck(dprRows,allConst,specIdListDevice, specIdList);
             }
             system.debug('***Telstra:DealQuoteHandler:getRows:dprQuery '+dprQuery); 
            
             system.debug('***Telstra:DealQuoteHandler:getRows:dprRows '+dprRows);  
          /*   if(subfilters.get(allConst.get('QueryType')) == allConst.get('DPRQuoteConditionalCheck')){
                 return getDPRConditionalCheck(dprRows,allConst,specIdListDevice);
             }*/
          /*   else{
                return getNewDPRDevice(dprRows,allConst);
             } */
             
         }
     //EDGE-177567 - End
         catch(Exception e){   
             System.debug('***Telstra:DealQuoteHandler:getRows:exception:'+e.getLineNumber()+' '+e.getMessage()); 
         }   
         return rows; 
     }
     public List<Map<String,Object>> getNewDPRDevice(List<DPR_Offer_Line_Item__c> dprRows ,Map<String,String> allConst){
         List<Map<String,Object>> rows = new List<Map<String,Object>>();
         Map<String, Map<String,Object> > checkDuplicate = new Map<String,Map<String,Object>>();   
         Integer ExId = 1;
         try{
             if(dprRows != null && dprRows.Size() > 0){
               //  Map<String,Object> dprRow= null ; 
                
                 for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                    Map<String,Object> dprRow= new Map<String,Object>();
                     String uniqueKey ;
                     if(dprLineItem.DPR_Offer_Line_Item_Type__c == allConst.get('Addon')){
                           uniqueKey = dprLineItem.cspmb_Add_On_Price_Item__r.Billing_Description__c + dprLineItem.List_Price__c; 
                          }
                     else{
                           uniqueKey = dprLineItem.cspmb_Price_Item__r.Billing_Description__c + dprLineItem.List_Price__c; 
                        }
                   
                    Map<String,Object> modifyRecord = checkDuplicate.get(uniqueKey);
                    Decimal quantity = 0 ; 
                    if(checkDuplicate.containsKey(uniqueKey)){ //EDGE-189035 Aggregation for device 
                        Decimal existingQty =  Integer.valueOf(modifyRecord.get(allConst.get('Quantity'))); 
                        system.debug('existingQty'+existingQty);
                        if(dprLineItem.DPR_Offer_Line_Item_Type__c == allConst.get('Addon')){
                            existingQty = existingQty+ 1;                                
                        }
                        else{
                            existingQty = existingQty+ getQuantity(dprLineItem.Quantity__c , dprLineItem.Recontracting_Quantity__c );
                        }                        
                        modifyRecord.put(allConst.get('Quantity'), existingQty);  
                        system.debug('existingPrice'+modifyRecord.get(allConst.get('GSTExcl_Total_Recurring_Charges')));
                        string totalExcl = String.valueOf(modifyRecord.get(allConst.get('GSTExcl_Total_Recurring_Charges')));
                        Decimal existingPrice = Decimal.valueOf(totalExcl); 
                        system.debug('existingPrice'+existingPrice);
                        system.debug('existingPrice'+dprLineItem.Overridden_Total_Price__c);
                        existingPrice =  existingPrice + dprLineItem.Overridden_Total_Price__c ; 
                        modifyRecord.put(allConst.get('GSTExcl_Total_Recurring_Charges'), string.valueOf(existingPrice));  
                     }
                     else{
                         if(dprLineItem.DPR_Offer_Line_Item_Type__c == allConst.get('Addon')){
                             quantity = 1;
                             dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Add_On_Price_Item__r.Billing_Description__c );
                         }
                         else{
                          String offerType = allConst.get('deviceTypeRC');
                          system.debug('***Telstra:DealQuoteHandler:getNewDPRDevice:dprRow:offerType'+offerType); 
                          system.debug('***Telstra:DealQuoteHandler:getNewDPRDevice:dprRow:dprLineItem.cspmb_Price_Item__r.ChargeType__c'+dprLineItem.cspmb_Price_Item__r.ChargeType__c); 
                 
                         quantity = getQuantity(dprLineItem.Quantity__c , dprLineItem.Recontracting_Quantity__c ) ; 
                          if(dprLineItem.cspmb_Price_Item__r.ChargeType__c == offerType){
                             dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c + ' Repayment');
                             dprRow.put(allConst.get('DiscountText'),'Over ' + dprLineItem.Delegated_Pricing_Request__r.Opportunity__r.Contract_Term__c +' months');
                
                         }
                         else{
                             dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c );
                         }
                         }
                    // dprRow= new Map<String,Object>();
                       /*      if(dprLineItem.cspmb_Price_Item__r.ChargeType__c == offerType){
                             dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c + ' Repayment');
                             dprRow.put(allConst.get('DiscountText'),'Over ' + dprLineItem.Delegated_Pricing_Request__r.Opportunity__r.Contract_Term__c +' months');
                
                         }
                         else{
                             dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c );
                         }
                    */ 
                     dprRow.put(allConst.get('Quantity'), quantity);
                     dprRow.put(allConst.get('VolumeTier1'),dprLineItem.List_Price__c );
                   /*  if(dprLineItem.DPR_Offer_Line_Item_Value__c != null && dprLineItem.List_Price__c != null && (dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c) > 0){
                         dprRow.put(allConst.get('VolumeTier3'),String.valueOf(dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c)); //EDGE-177567
                         dprRow.put(allConst.get('VolumeTier2'),dprLineItem.DPR_Offer_line_item_value__c );
                     }
                     else{  Commenting as no negotiation for device */
                         dprRow.put(allConst.get('VolumeTier3'),allConst.get('NA')); //EDGE-177567
                         dprRow.put(allConst.get('VolumeTier2'),allConst.get('NA'));
                   //  }
                     dprRow.put(allConst.get('GSTExcl_Total_Recurring_Charges'), string.valueOf(dprLineItem.Overridden_Total_Price__c));  //EDGE-177567
                     dprRow.put(allConst.get('ExternalId'),ExId++ );  
                     rows.add(dprRow);
                     checkDuplicate.put(uniqueKey,dprRow);
                     system.debug('***Telstra:DealQuoteHandler:getNewDPRDevice:dprRow:'+dprRow); 
                     }
                   
                 }
                 system.debug('***Telstra:DealQuoteHandler:getNewDPRDevice:rows:'+rows);
             }
         }
         catch(Exception e){   
             System.debug('***Telstra:DealQuoteHandler:getNewDPRDevice:exception:'+e.getLineNumber()+' '+e.getMessage()); 
         } 
         return rows; 
     }
    //EDGE-189035 Created new method for Plan and bolton 
    public List<Map<String,Object>> getNewDPRPlan(List<DPR_Offer_Line_Item__c> dprRows ,Map<String,String> allConst){ 
    Map<DPR_Offer_Line_Item__c, List<DPR_Offer_Line_Item__c>> mapParentChildOLI = getPlanBoltonMap(dprRows)  ;  
    system.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:dprRow:'+dprRows);
        //
         List<Map<String,Object>> rows = new List<Map<String,Object>>();
         Integer ExId = 1;
         try{
             if(dprRows != null && dprRows.Size() > 0){
                 for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                    Map<String,Object> dprRow= new Map<String,Object>();
                    Decimal quantity = 0 ; 
                    
                    quantity = getQuantity(dprLineItem.Quantity__c , dprLineItem.Recontracting_Quantity__c ) ;
                    // dprRow= new Map<String,Object>();
                     dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c );
                     dprRow.put(allConst.get('Quantity'), quantity);
                     dprRow.put(allConst.get('VolumeTier1'),dprLineItem.List_Price__c );
                     if(dprLineItem.DPR_Offer_Line_Item_Value__c != null && dprLineItem.List_Price__c != null && (dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c) > 0){   //EDGE-189035 Changed condition to isNegotiableCharge Field 
                         dprRow.put(allConst.get('VolumeTier3'),String.valueOf(dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c)); //EDGE-177567
                         dprRow.put(allConst.get('VolumeTier2'),dprLineItem.DPR_Offer_line_item_value__c );
                     }
                     else{
                         dprRow.put(allConst.get('VolumeTier3'),allConst.get('NA')); //EDGE-177567
                         dprRow.put(allConst.get('VolumeTier2'),dprLineItem.DPR_Offer_line_item_value__c );
                     }
                     dprRow.put(allConst.get('GSTExcl_Total_Recurring_Charges'), string.valueOf(dprLineItem.Overridden_Total_Price__c));  //EDGE-177567
                     dprRow.put(allConst.get('ExternalId'),ExId++ );  
                     rows.add(dprRow);
                     system.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:dprRow:'+dprRow); 
                    if(mapParentChildOLI.get(dprLineItem) != null){
                    for(DPR_Offer_Line_Item__c innerOLI:mapParentChildOLI.get(dprLineItem)){
                    system.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:innerOLI:'+innerOLI.DPR_Offer_Line_Item_Type__c+innerOLI); 
                    if(innerOLI.DPR_Offer_Line_Item_Type__c == allConst.get('Addon')){
                    Map<String,Object> innerDprRow= new Map<String,Object>();
                     system.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:innerOLI:'+innerOLI); 
                    // dprRow= new Map<String,Object>();
                     innerDprRow.put(allConst.get('ProductModuleName'),'&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + innerOLI.cspmb_Add_On_Price_Item__r.Billing_Description__c );
                     innerDprRow.put(allConst.get('Quantity'), dprRow.get(allConst.get('Quantity')));
                     innerDprRow.put(allConst.get('VolumeTier1'),innerOLI.List_Price__c );
                  /*   if(innerOLI.DPR_Offer_Line_Item_Value__c != null && innerOLI.List_Price__c != null && (innerOLI.List_Price__c - innerOLI.DPR_Offer_Line_Item_Value__c) > 0){
                         innerDprRow.put(allConst.get('VolumeTier3'),String.valueOf(innerOLI.List_Price__c - innerOLI.DPR_Offer_Line_Item_Value__c)); //EDGE-177567
                         innerDprRow.put(allConst.get('VolumeTier2'),innerOLI.DPR_Offer_line_item_value__c );
                     }
                     else{ */
                         innerDprRow.put(allConst.get('VolumeTier3'),allConst.get('NA')); //EDGE-177567
                         innerDprRow.put(allConst.get('VolumeTier2'),allConst.get('NA'));
                   //  } 
                     innerDprRow.put(allConst.get('GSTExcl_Total_Recurring_Charges'), string.valueOf(innerOLI.Overridden_Total_Price__c));  //EDGE-177567
                     innerDprRow.put(allConst.get('ExternalId'),ExId++ );  
                     rows.add(innerDprRow);
                            }
                         }
                     }
                   
                 }
                 system.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:rows:'+rows);
             }
         }
         catch(Exception e){   
             System.debug('***Telstra:DealQuoteHandler:getNewDPRPlan:exception:'+e.getLineNumber()+' '+e.getMessage()); 
         } 
         return rows; 
     } 
    //Get map of constantans which are added to Apex Constant Metadata record 
     public Map<String,String> getConstant(){
         Map<String,String> allConst = new Map<String,String>(); 
         try{
             AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
             list<String> productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ApexConstant'));
             system.debug(productSpecCodes); 
             allConst = new Map<String,String>(); 
             List<String> constKeyValueList = null; 
             for(String v:productSpecCodes){
                 constKeyValueList = v.split(':'); 
                 allConst.put(constKeyValueList[0],constKeyValueList[1]);
             }
             system.debug('***Telstra:DealQuoteHandler:getConstant:allConst'+allConst); 
             return allConst; 
         }
         catch(Exception e){   
             System.debug('***Telstra:DealQuoteHandler:getConstant:exception:'+e.getLineNumber()+' '+e.getMessage()); 
         } 
         return allConst; 
     }
    //Populate boolean fields according to condition 
     public List<Map<String,Object>> getDPRConditionalCheck(List<DPR_Offer_Line_Item__c> dprRows ,Map<String,String> allConst,List<String> specIdListDevice,List<String> specIdList){
         List<Map<String,Object>> rows = new List<Map<String,Object>>();
         Boolean isNegotiated = false; 
         Decimal totalMonthlyCharge ;
         Boolean isNGEMDeviceNew = false;
         Boolean isNGEM = false ; //EDGE-134662 
         Integer ExId = 1;
         try{
             if(dprRows != null && dprRows.Size() > 0){
                 Map<String,Object> dprRow= new Map<String,Object>() ; 
                 for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                    if(specIdListDevice.contains(dprLineItem.cspmb_Price_Item__r.ProdSpecId__c)){
                        isNGEMDeviceNew  = true ; 
                         break ; 
                     } 
                  }
                 for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                    totalMonthlyCharge = dprLineItem.Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c;
                    if(dprLineItem.DPR_Offer_Line_Item_Value__c != null && dprLineItem.DPR_Offer_Line_Item_Value__c > 0){
                        isNegotiated  = true ; 
                         break ; 
                     } 
                  }
                  //EDGE-134662 Start 
                  for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                   if(specIdListDevice.contains(dprLineItem.cspmb_Price_Item__r.ProdSpecId__c) || specIdList.contains(dprLineItem.cspmb_Price_Item__r.ProdSpecId__c)  ){
                            isNGEM  = true ; 
                         break ; 
                     } 
                  } 
                  //EDGE-134662 End 
                 dprRow.put(allConst.get('isTC'), isNegotiated);
                 dprRow.put(allConst.get('VolumeTier1'),String.valueOf(totalMonthlyCharge));
                  dprRow.put(allConst.get('isNGEMDeviceNew'),isNGEMDeviceNew);
                  dprRow.put('isNGEM',isNGEM);
                  dprRow.put(allConst.get('ExternalId'),ExId++ );  
                  rows.add(dprRow);
                 system.debug('***Telstra:DealQuoteHandler:getDPRConditionalCheck:rows:'+rows);
             }
         }
         catch(Exception e){   
             System.debug('***Telstra:DealQuoteHandler:getDPRConditionalCheck:exception:'+e.getLineNumber()+' '+e.getMessage()); 
         } 
         return rows; 
     }
    //EDGE-189035 To derive quantity 
     public Decimal getQuantity(Decimal quantity, Decimal reQuantity ){
         Decimal qty; 
         
         if(quantity != null && reQuantity != null){
             qty = quantity + reQuantity ;
         }
         else if (quantity != null){
             qty = quantity ;
         }
         else if(reQuantity != null){
             qty = reQuantity ;
         } 
         if(qty != null){
              return qty ; 
         }
         else {
         return 0 ; 
         }
         
     }
    //EDGE-189035 Get map of parent dpr and its addon 
     public Map<DPR_Offer_Line_Item__c , List<DPR_Offer_Line_Item__c>> getPlanBoltonMap(List<DPR_Offer_Line_Item__c> dprRows){
         Map<DPR_Offer_Line_Item__c, List<DPR_Offer_Line_Item__c>> mapParentChildOLI =new Map<DPR_Offer_Line_Item__c, List<DPR_Offer_Line_Item__c>>();

            for(DPR_Offer_Line_Item__c dprObj:dprRows)
            {
                if(mapParentChildOLI.containsKey(dprObj))
                {

                    if(dprObj.DPR_Offer_Line_Items__r.size()>0)
                    {
                        List<DPR_Offer_Line_Item__c> lst = mapParentChildOLI.get(dprObj);

                        for(DPR_Offer_Line_Item__c oli:dprObj.DPR_Offer_Line_Items__r)
                        {
                            lst.add(oli);
                        }
                        mapParentChildOLI.put(dprObj,lst);
                    }        
                }
                else
                {

                    if(dprObj.DPR_Offer_Line_Items__r.size()>0)
                    {
                        List<DPR_Offer_Line_Item__c> lst = new List<DPR_Offer_Line_Item__c>();
                        for(DPR_Offer_Line_Item__c oli:dprObj.DPR_Offer_Line_Items__r)
                        {
                            lst.add(oli);
                        }
                        mapParentChildOLI.put(dprObj,lst);
                    }
                }    
            }

        System.debug('test=' + mapParentChildOLI ); 
        return mapParentChildOLI ; 
     }
}
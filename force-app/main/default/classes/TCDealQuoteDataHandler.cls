/* 
* @Author : Monali 
* @Date : 14/05/2021 
* @Desc : As a Sales and Partner user, I should be able to send a proposal(Deal quote) to customer for NGUC delegated discounts/proposed deals.
* @Jira : EDGE-134662 
*/

public with sharing class TCDealQuoteDataHandler {
        
    public List<Map<String,Object>> getRows(String dprId, Map<String,String> subfilters){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        List<DPR_Offer_Line_Item__c> dprRows = new List<DPR_Offer_Line_Item__c>();
        Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();     
        List<String> specIdListTC = new List<String>();
        Map<String,String> allConst = new Map<String,String>();
        try{
            allConst = getConstant();
            List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];    
            for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){    
                if(ngemSpec.ProductCategory__c== DataHandlerConstants.TC){    
                    map_PDvsSecId.put(ngemSpec.Label,ngemSpec); 
                    specIdListTC.add(ngemSpec.ProdSpecId__c); 
                } 
                
            }
            String dprQuery = 'SELECT cspmb_Price_Item__r.Billing_Description__c,Quantity__c,List_Price__c,DPR_Offer_line_item_value__c ,cspmb_Price_Item__r.ProdSpecId__c,Recontracting_Quantity__c,Overridden_Total_Price__c,Delegated_Pricing_Request__r.Opportunity__r.Contract_Term__c  from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__r.id =: dprId AND isNegotiableCharge__c = true '; 
            if(subfilters.get(allConst.get('QueryType')) == DataHandlerConstants.DPR_DealQuoteTC ){
                dprQuery = dprQuery + 'AND cspmb_Price_Item__r.ProdSpecId__c IN :specIdListTC';
                system.debug('***Telstra:TCDealQuoteDataHandler:getRows:specIdListTC '+specIdListTC);
                system.debug('***Telstra:TCDealQuoteDataHandler:getRows:dprQuery '+dprQuery);
                dprRows =Database.query(dprQuery);
                system.debug('dprRows*******'+dprRows);
                 system.debug('dprQuery*******'+dprQuery);
                return getTCRows(dprRows,allConst);
            }
        }
        catch(Exception e){   
            System.debug('***Telstra:TCDealQuoteDataHandler:getRows:exception:'+e.getLineNumber()+' '+e.getMessage()); 
            String msg = e.getMessage()+' @'+e.getLineNumber();
            throw new CongaTemplateException(msg,' TCDealQuoteDataHandler :: getRows','Q');
        }   
        return rows; 
    }
    public List<Map<String,Object>> getTCRows(List<DPR_Offer_Line_Item__c> dprRows ,Map<String,String> allConst){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer ExId = 1;
        try{
            if(dprRows != null && dprRows.Size() > 0){
                for(DPR_Offer_Line_Item__c dprLineItem:dprRows){
                    Map<String,Object> dprRow= new Map<String,Object>();
                    
                    Decimal quantity = getQuantity(dprLineItem.Quantity__c , dprLineItem.Recontracting_Quantity__c ) ; 
                    dprRow.put(allConst.get('ProductModuleName'),dprLineItem.cspmb_Price_Item__r.Billing_Description__c + DataHandlerConstants.REPAYMENT);
                    dprRow.put(allConst.get('DiscountText'),'Over ' + dprLineItem.Delegated_Pricing_Request__r.Opportunity__r.Contract_Term__c +DataHandlerConstants.MONTHS);
                    dprRow.put(allConst.get('Quantity'), quantity);
                    dprRow.put(allConst.get('VolumeTier1'),dprLineItem.List_Price__c );
                    if(dprLineItem.DPR_Offer_Line_Item_Value__c != null && dprLineItem.List_Price__c != null && (dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c) > 0){
                        dprRow.put(allConst.get('VolumeTier3'),String.valueOf(dprLineItem.List_Price__c - dprLineItem.DPR_Offer_Line_Item_Value__c)); 
                        dprRow.put(allConst.get('VolumeTier2'),dprLineItem.DPR_Offer_line_item_value__c );
                    }
                    dprRow.put(allConst.get('GSTExcl_Total_Recurring_Charges'), string.valueOf(dprLineItem.Overridden_Total_Price__c)); 
                    dprRow.put(allConst.get('ExternalId'),ExId++ );                        
                    rows.add(dprRow);
                    system.debug('***Telstra:TCDealQuoteDataHandler:getTCRows:dprRow:'+dprRow); 
                }
                system.debug('***Telstra:TCDealQuoteDataHandler:getTCRows:rows:'+rows);
            }
        }
        catch(Exception e){   
            System.debug('***Telstra:TCDealQuoteDataHandler:getTCRows:exception:'+e.getLineNumber()+' '+e.getMessage()); 
            throw new CongaTemplateException(e.getMessage(),' TCDealQuoteDataHandler :: getTCRows','Q');
        } 
        return rows; 
    }
    public List<Map<String,Object>> getTCPlanRateCard(String dprId, Map<String,String> subfilters){
        Map<String,List<DPR_Rate_Card__c>> wrapRow = new Map<String,List<DPR_Rate_Card__c>>();
        Map<String,String> allConst = new Map<String,String>();    
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer ExId = 1;
        try{
            allConst = getConstant();
            for(DPR_Rate_Card__c arc : [Select ID, DPR_Rate_Card_Name__c, Parent_DPR_OLI_id__r.Id,Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c, DPR_RC_Rate_Value__c, DPR_RC_Negotiated_Value__c , Negotiated_Discount__c,Parent_DPR_Rate_Card_ID__c,Delegated_Pricing_Request__c    FROM DPR_Rate_Card__c where Delegated_Pricing_Request__c    =: dprId AND Parent_DPR_OLI_id__r.DPR_Offer__r.Marketable_Offer__r.Offer_ID__c =: DataHandlerConstants.TC_Offer_Id]){
                if(arc.Parent_DPR_Rate_Card_ID__c != null){
                    if(!wrapRow.containsKey(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c)){
                        wrapRow.put(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,new List<DPR_Rate_Card__c>());
                    }
                    wrapRow.get(arc.Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c).add(arc); 
                }
            }
            for(String plan: wrapRow.keySet()){
                Map<String,Object> dprRow= new Map<String,Object>();
                dprRow.put(allConst.get('ProductModuleName'),plan);
                String name = null;
                for(DPR_Rate_Card__c rateCard : wrapRow.get(plan)){
                    name = rateCard.DPR_Rate_Card_Name__c;
                    if(name.contains(DataHandlerConstants.ONE_TO_TEN)){
                        dprRow.put(allConst.get('VolumeTier1'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    }   else if(name.contains(DataHandlerConstants.ELEVEN_TO_TWENTY)){
                        dprRow.put(allConst.get('VolumeTier2'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    } else if(name.contains(DataHandlerConstants.TWENTYONE_TO_FIFTY)){
                        dprRow.put(allConst.get('VolumeTier3'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    } else if(name.contains(DataHandlerConstants.FIFTYONE_TO_TWOHUNDRED)){
                        dprRow.put(allConst.get('VolumeTier4'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    } else if(name.contains(DataHandlerConstants.TWOHUNDREDONE_TO_FIVEHUNDRED)){
                        dprRow.put(allConst.get('VolumeTier5'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    } else if(name.contains(DataHandlerConstants.FIVEHUNDREDONE_TO_NINTYNINETHOUSANDNINEHUNDREDNINTYNINE)){
                        dprRow.put(allConst.get('VolumeTier6'), rateCard.DPR_RC_Negotiated_Value__c);
                        continue;
                    }             
                }
                dprRow.put(allConst.get('ExternalId'),ExId++ );
                rows.add(dprRow); 
            }
            system.debug('***Telstra:TCDealQuoteDataHandler:getTCPlanRateCard:rows'+rows);
        }
        catch(Exception e){   
            System.debug('***Telstra:TCDealQuoteDataHandler:getTCPlanRateCard:exception:'+e.getLineNumber()+' '+e.getMessage()); 
            throw new CongaTemplateException(e.getMessage(),' TCDealQuoteDataHandler :: getTCPlanRateCard','Q');
        }   
        return rows; 
    }
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
            system.debug('***Telstra:TCDealQuoteDataHandler:getConstant:allConst'+allConst); 
            return allConst; 
        }
        
        catch(Exception e){   
            System.debug('***Telstra:TCDealQuoteDataHandler:getConstant:exception:'+e.getLineNumber()+' '+e.getMessage()); 
            throw new CongaTemplateException(e.getMessage(),' TCDealQuoteDataHandler :: getConstant','Q');
        } 
        
    }
    public Decimal getQuantity(Decimal quantity, Decimal reQuantity ){
        Decimal qty = 0; 
        
        if((quantity != null && quantity >0 ) && (reQuantity != null && reQuantity >0 )){
            qty = quantity + reQuantity ;
            return qty;
        }
        else if (quantity != null && quantity >0 ){
            return quantity ;
        }
        else if(reQuantity != null && reQuantity >0 ){
            return reQuantity ;
        }  else {
            return qty ; 
        }
    }
}
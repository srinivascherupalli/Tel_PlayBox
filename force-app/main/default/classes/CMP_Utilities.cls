/*
* @Desc : CMP Utility Class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
public with sharing class CMP_Utilities {
 public static List<string> lstEnterpriseMobilitySpecCode;
    static final String pphhId = 'DMCAT_Offer_000646';
    static final String newType = 'New';
    static final String modifyType = 'Modify';
    static final String cancelType = 'Cancel';
    static final String reactivateType ='Reactivate';
    public static List<String> lstEMSpecCodes;
    static final String xBYOOfferName = 'X-Large Data SIM BYO';
    public CMP_Utilities(){
        lstEnterpriseMobilitySpecCode=new List<String>(AllCQEnvironmentVariable.getValueAsList('EnterpriseMobilitySpecCode'));
        lstEMSpecCodes=new List<String>(AllCQEnvironmentVariable.getValueAsList('EMSpecCodes'));
    }
    public static String calculateTotalDataforCommittedPlan(String Plan_Data, String Bonus_Data){
    Integer cmp_plan_data = Integer.valueof(Plan_Data);
    integer cmp_bonus_data = Integer.valueof(Bonus_Data);
    String total_data;
    integer total_value;
    total_value = cmp_plan_data + cmp_bonus_data;
    total_data = String.valueOf(total_value)+' GB';
    
    return total_data;
    }
    
    //EDGE - 105921 - START - CMP-Committed Offer Quote/Orderform
    public List<Map<String,Object>> getCMPCommittedData(String basketId, Map<String,String> subfilters){
        List<cscfga__Product_Configuration__c> planCMPList = new List<cscfga__Product_Configuration__c>(); 
        List<cscfga__Product_Configuration__c> planCMPCDList = new List<cscfga__Product_Configuration__c>(); //EDGE-146809      
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String, String> map_PlanVsDataAllowance = new Map<String, String>();
        Map<String, String> map_PlanVsBonusAllowance = new Map<String, String>();
        Map<String,CMP_committed_offers__mdt> CMP_committedOffersMap = new Map<String,CMP_committed_offers__mdt>();
        Integer externalId=1;
        Boolean isCommitedTrue = false;//EDGE-144228 Start
        String objectAPIName=''; 
        Id temp;       
        try{            
            if(subfilters.get('Type') =='New')
               planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketId AND cscfga__Product_Definition__r.product_Specification__c IN:lstEnterpriseMobilitySpecCode AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];
            //EDGE - 117740 Start
            else if(subfilters.get('Type') =='Modify')
                planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where name = 'Corporate Mobile Plus-Committed Data' AND cscfga__Product_Basket__c =:basketId AND Type__c='Modify']; 
            else if(subfilters.get('Type') =='Cancel' )
                planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where name = 'Corporate Mobile Plus-Committed Data' AND cscfga__Product_Basket__c =:basketId AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null]; 
            //EDGE - 117740 End
            //EDGE-144228 Start
            
            for(cscfga__Product_Configuration__c pc1:planCMPList){
                
                for(cscfga__Attribute__c attribute:pc1.cscfga__Attributes__r){
                    
                    if(attribute.name == 'OfferTypeString'){
                        
                        if(attribute.cscfga__Value__c == 'Committed Data'){
                            isCommitedTrue = true;
                            planCMPCDList.add(pc1); //EDGE-146809 | Filtering Committed Data PCs
                        }
                    } 
                }
            }
            
             //EDGE-144228 End            
        //EDGE-121387, EDGE-133760 Start 
            if(planCMPCDList.size()==0 || isCommitedTrue == false){//EDGE-144228
                return rows;
            }
            //EDGE-121387, EDGE-133760 End
            List<CMP_committed_offers__mdt> CMP_committedOffersList = [select MasterLabel,Plan_Data__c,Bonus_Data__c,Total_Data__c,Plan_Rate__c,LT_1__c,PAYG_1_to_2__c,PAYG_2_to_3__c,PAYG_3_to_4__c,PAYG_4_to_5__c,PAYG_GT_5__c,Is_Mandatory__c from CMP_committed_offers__mdt];
            if(!CMP_committedOffersList.IsEmpty()){
                for(CMP_committed_offers__mdt cmpMdtRec : CMP_committedOffersList){
                    CMP_committedOffersMap.put(cmpMdtRec.MasterLabel,cmpMdtRec);
                }
            }
            
            for(cscfga__Product_Configuration__c pc:planCMPCDList){      
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                    
                    if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True){
                        temp = attribute.cscfga__Value__c;
                        objectAPIName = temp.getSObjectType().getDescribe().getName();
                        
                        //EDGE-148067 Start | segregating Data & Bonus Allowances
                        if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c') && attribute.Name=='Data Pack Allowance'){
                            
                            map_PlanVsDataAllowance.put(pc.Id,attribute.cscfga__Value__c);
                        }
                        if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c') && attribute.Name=='BonusDataAllowance'){
                            
                            map_PlanVsBonusAllowance.put(pc.Id,attribute.cscfga__Value__c);
                        }
                        //EDGE-148067 End                           
             }
                     }
          }
            
            //EDGE-148067 Start | segregating Data & Bonus Allowances
            Set<String> attrIdList = new Set<String>();
            attrIdList.addAll(map_PlanVsDataAllowance.values());
           
            attrIdList.addAll(map_PlanVsBonusAllowance.values());
           
            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Allowance__c> allowanceRecords = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
            //EDGE-148067 End
            
            if(planCMPCDList.size()>0){
            for(CMP_committed_offers__mdt CMPrec: CMP_committedOffersList){
                Map<String,Object> newRow1 = new Map<String,Object>();
                    if(CMPrec.Is_Mandatory__c==true)
                    {
                        
                        newRow1.put('ExternalId', externalID++);
                        newRow1.put('Plan_Data',CMPrec.Plan_Data__c);
                        newRow1.put('Plan_Rate',CMPrec.Plan_Rate__c);
                        newRow1.put('Bonus_Data',CMPrec.Bonus_Data__c);
                        newRow1.put('Total_Data',CMPrec.Total_Data__c);
                        newRow1.put('PAYG_LT_1',CMPrec.LT_1__c);
                        newRow1.put('PAYG_1_to_2',CMPrec.PAYG_1_to_2__c);
                        newRow1.put('PAYG_2_to_3',CMPrec.PAYG_2_to_3__c);
                        newRow1.put('PAYG_3_to_4',CMPrec.PAYG_3_to_4__c);
                        newRow1.put('PAYG_4_to_5',CMPrec.PAYG_4_to_5__c);
                        newRow1.put('PAYG_GT_5',CMPrec.PAYG_GT_5__c);
                        newRow1.put('Product_Module_Name','Committed');                     
                        
                        rows.add(newRow1);
                    }
            }
            for(cscfga__Product_Configuration__c pc:planCMPCDList){
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('Product_Module_Name','Committed');
                newRow.put('ExternalId', externalID++);
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                    
                    String mappingfield ='';
                    if(!ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True){
                        
                        mappingfield = (attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
                        
                        newRow.put(mappingfield,attribute.cscfga__Value__c);
                        if(mappingfield.contains('Plan_Rate')){ 
                            newRow.put('Plan_Rate',attribute.cscfga__Value__c);  
                        }  
                    }
                }
                //EDGE-148067 Start | fetching values from Allowance records instead of Metadata
                cspmb__Allowance__c dataAllowanceRecord = allowanceRecords.get(map_PlanVsDataAllowance.get(pc.Id));
                cspmb__Allowance__c bonusAllowanceRecord = allowanceRecords.get(map_PlanVsBonusAllowance.get(pc.Id)); 
                newRow.put('Unit_Of_Measure',dataAllowanceRecord.Unit_Of_Measure__c);
                newRow.put('Plan_Data',dataAllowanceRecord.Value__c);
                newRow.put('Bonus_Data',bonusAllowanceRecord.Value__c);
                if(CMP_committedOffersMap.ContainsKey(dataAllowanceRecord.Value__c)){
                    if(CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).MasterLabel=='PAYG'){
                        newRow.put('Total_Data','N/A');
                        newRow.put('Plan_Rate','N/A');
                    }
                    else{
                        newRow.put('Total_Data',calculateTotalDataforCommittedPlan(dataAllowanceRecord.Value__c,bonusAllowanceRecord.Value__c));
                        //Reusing Rate__c as static Unit of Measurement
                        newRow.put('Rate','per month per service');
                    }
                    newRow.put('PAYG_LT_1',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).LT_1__c);
                    newRow.put('PAYG_1_to_2',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_1_to_2__c);
                    newRow.put('PAYG_2_to_3',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_2_to_3__c);
                    newRow.put('PAYG_3_to_4',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_3_to_4__c);
                    newRow.put('PAYG_4_to_5',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_4_to_5__c);
                    newRow.put('PAYG_GT_5',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_GT_5__c);
                }
                //EDGE-148067 End
                
                rows.add(newRow);
            }
            }
        }
        catch(Exception e)
        {
           // System.debug('***Telstra:ProductBasketDataHandler:getCMPCommittedData:exception:'+e.getLineNumber()+' '+e.getMessage());
            C2O_Utilities.createException(e);
        }
        
        return rows;
    }
    public List<Map<String,Object>>getCMPCancelProducts(String basketID,Map<String,String> subfilters){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        rows.addAll(getCMPServices(basketID,subfilters));
        rows.addAll(getCMPDevices(basketID,subfilters));
        return rows;
    }
    //EDGE-98246 - start Method to get CMP Devices 
    public List<Map<String,Object>> getCMPDevices(String basketId, Map<String,String> subfilters) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String,List<cscfga__Product_Configuration__c>> map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        Map<String, String> map_DeviceModelVsPriceItem = new Map<String, String>();
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        //changes start EDGE - 104681
        List<cscfga__Product_Configuration__c> devicePCList = new List<cscfga__Product_Configuration__c>();  
        try{
            if(subfilters.get('Type') =='New')
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];//EDGE-154662 Fix
            else if(subfilters.get('Type') =='Modify')
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='Modify' AND csordtelcoa__Replaced_Product_Configuration__c!=null];//EDGE-154662 Fix
            else if(subfilters.get('Type') =='Cancel')
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null];//EDGE-154662 Fix
            
            //changes end EDGE - 104681
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:devicePCList){
                if(pc.Type__c != 'Cancel'){                                   
                    if(map_DeviceModelvsPC.get(pc.Name) == null){
                        map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());          
                    }
                    map_DeviceModelvsPC.get(pc.Name).add(pc);
                    for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                        if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True){
                        map_DeviceModelVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
                        map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);
                        }
                    }
                    }
                else if(pc.Type__c == 'Cancel'){
                        
                        Map<STRing,Object> cancelDeviceRow = new Map<String,Object>();
                        cancelDeviceRow.put('Product_Module_Name',pc.Name);
                        cancelDeviceRow.put('ExternalId', externalID++);
                        for(cscfga__Attribute__c att:pc.cscfga__Attributes__r){
                            if(ProductBasketDataHandler.isValidId(att.cscfga__Value__c)==False){
                                String mappingfield = (att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');                      
                                cancelDeviceRow.put(mappingfield, att.cscfga__Value__c);
                                if(mappingfield.equalsIgnoreCase('GSTExcl_TotalETC')){
                                    cancelDeviceRow.put('GSTExcl_TotalETC', att.cscfga__Value__c);
                                  cancelDeviceRow.put('GSTIncl_TotalETC', ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(att.cscfga__Value__c)));
                                }
                                if(mappingfield.equalsIgnoreCase('RemainingTerm'))
                                    cancelDeviceRow.put('RemainingTerm', 'Your mobile repayment option has '+att.cscfga__Value__c+' months remaining');
                            }           
                    }
                    rows.add(cancelDeviceRow);
                }
            }                  
           
            List<String> attrIdList = map_DeviceModelVsPriceItem.values();
            //String priceItemQuery = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
//                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
            
            //Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(priceItemQuery)); 
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)[SELECT id,name,Unit_Of_Measure__c,cspmb__Contract_Term__c,cspmb__Recurring_Charge__c FROM cspmb__Price_Item__c WHERE id IN :attrIdList]); 
            
            for(String deviceKey: map_DeviceModelvsPC.keySet()){
                Map<STRing,Object> newRow = new Map<String,Object>();
                newRow.put('Product_Module_Name',String.valueOf(deviceKey));
                newRow.put('ExternalId', externalID++);
                Integer qty = map_DeviceModelvsPC.get(deviceKey).size();
                newRow.put('Quantity',qty);
                cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_DeviceModelVsPriceItem.get(deviceKey));
                if(priceItemRecord!=null){
                    newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                    newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                    newRow.put('Rate',priceItemRecord.cspmb__Recurring_Charge__c);
                    newRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                    newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                }
                rows.add(newRow); 
            }
        }
        catch(Exception e)
        {
           // System.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
           C2O_Utilities.createException(e);
        }
        return rows;
    }
    public List<Map<String,Object>> getCMPServices(String basketId, Map<String,String> subfilters) {
        
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        ProductBasketDataHandler bskHandle=new ProductBasketDataHandler();
        Map<String,List<cscfga__Product_Configuration__c>> map_PlanvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        //EDGE-162024 - Map declaration for unique key    
        Map<String,List<cscfga__Product_Configuration__c>> map_PlanNetValuevsPC = new Map<String,List<cscfga__Product_Configuration__c>>(); 
        // EDGE-162024 End
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        //EDGE-162025 start
        Map<String,String> map_AttributeVsValue = new Map<String, String>();
        Map<String,List<Id>> map_AddonIDDAsso = new Map<String,List<Id>>();
        Map<String,List<Id>> map_Addon3GStandardAsso = new Map<String,List<Id>>();
        //EDGE-162025 end
        // EDGE - 117740 Start
        Map<String, String> map_PlanVsPriceItemCommit;
        //EDGE - 117740 End
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        //EDGE-140420
        Decimal sharedQuantity=0;
        //EDGE - 117740
        String objectAPIName=''; Id temp;
        String sCommittedData = '';
        String sCommittedBonusData = '';
        //EDGE - 117740
        Decimal sCommittedText;
        Map<String,List<Id>> map_AddonsAssociation = new Map<String,List<Id>>();
        Map<String,List<Id>> map_Addons = new Map<String,List<Id>>();
        Map<String,String> pcVSDiscount = new Map<String,String>();
        //EDGE - 117740 Start
        Map<String, String> map_PlanVsAllowance = new Map<String, String>();
        List<String> attrIdList1;
        Map<String, String> map_AllowanceVsBasketsnaphotFields = new Map<String, String>();
        Map<String,CMP_committed_offers__mdt> CMP_committedOffersMap = new Map<String,CMP_committed_offers__mdt>();
        MAP<String,String> map_PlanVsPCAttrib = new Map<String, String>();//EDGE-144779
        //EDGE - 117740 End
        //changes start EDGE - 104681
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        try{
    //filter change
            if(subfilters.get('Type') =='New' ){//EDGE-188100 added subtype__c
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and subtype__c=null];
            }
            else if(subfilters.get('Type') =='Reactivate'){//EDGE-188100 changes
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and subtype__c='Reactivate'];
            }
            //EDGE-143435 START | Adding Active type
            else if(subfilters.get('Type') =='Modify'){
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND (Type__c='Modify' OR Type__c='Active') AND csordtelcoa__Replaced_Product_Configuration__c!=null];
            }else if(subfilters.get('Type') =='Cancel'){
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND (Type__c='Cancel' OR Type__c='Active') AND csordtelcoa__Replaced_Product_Configuration__c!=null];
            }
            //EDGE-143435 END
                  
            //EDGE-123788 start
            Map<String,String>  mapOfAddOnAssociationvsPC=new Map<String,String>();
        Map<String,String>  mapOfAddOnvsPC=new Map<String,String>();
            Map<String,List<Discount_Line_Item__c>> mapOfDLIvsDiscount=new Map<String,List<Discount_Line_Item__c>>();
            Map<String,List<Discount_Line_Item__c>> mapOfDLIvsAddOnDiscount=new Map<String,List<Discount_Line_Item__c>>();
      //get the DLI based on basketId related to CLI & Product Config.
            List<Discount_Line_Item__c> lstOfDLI=[Select Id,chargeInstance__c,BusinessID__c,discountValue__c,duration__c,Status__c,
                                                  chargeInstance__r.Product_Configuration__c,chargeInstance__r.Product_Configuration__r.Id,
                                                  chargeInstance__r.Product_Configuration__r.Name,chargeInstance__r.targetChargeProduct__c
                                                  From Discount_Line_Item__c Where chargeInstance__r.basketId__c=:basketId];
            if(lstOfDLI!=null && !lstOfDLI.isEmpty()){
                for(Discount_Line_Item__c dli:lstOfDLI){
                    if(dli.chargeInstance__c!=null && dli.chargeInstance__r.Product_Configuration__c!=null){
                        if(dli.chargeInstance__r.targetChargeProduct__c=='Plan'){
                            if(!mapOfDLIvsDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                                mapOfDLIvsDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                            }else{
                                mapOfDLIvsDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                            }
                        }else if(dli.chargeInstance__r.targetChargeProduct__c=='AddOn'){
                            if(!mapOfDLIvsAddOnDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                                mapOfDLIvsAddOnDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                            }else{
                                mapOfDLIvsAddOnDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                            }
                        }
                    }
                }
            } //EDGE-123788 end
            //changes end EDGE - 104681 
            //EDGE-117740 Start
            //EDGE-117740 Start
            List<CMP_committed_offers__mdt> CMP_committedOffersList = [select MasterLabel,Plan_Data__c,Bonus_Data__c,Total_Data__c,Plan_Rate__c,LT_1__c,PAYG_1_to_2__c,PAYG_2_to_3__c,PAYG_3_to_4__c,PAYG_4_to_5__c,PAYG_GT_5__c,Is_Mandatory__c from CMP_committed_offers__mdt];
            if(!CMP_committedOffersList.IsEmpty()){
                for(CMP_committed_offers__mdt cmpMdtRec : CMP_committedOffersList){
                    CMP_committedOffersMap.put(cmpMdtRec.MasterLabel,cmpMdtRec);
                }
            }
            //EDGE-140420 - Start
            if(EnvironmentVariable__c.getValues('Committed_Data').Value__c=='True'){
                for(cscfga__Product_Configuration__c pcloop:planPCList){
                    
                    //EDGE-143435 | Adding type Active
                    if((pcloop.Type__c=='Cancel'|| pcloop.Type__c=='Active') && pcloop.name.contains('Committed Data')){
                        if(String.isNotEmpty(pcloop.Name) && pcloop.cscfga__Product_Definition__r.product_Specification__c!= pphhId && !(pcloop.Name.contains(xBYOOfferName))){
                            sharedQuantity=sharedQuantity+pcloop.cscfga__Quantity__c;                            
                        }
                    }
                }
            }
            //EDGE-140420 - END
            //EDGE-117740 End
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:planPCList){
                if(map_PlanvsPC.get(pc.Name) == null){                    
                    map_PlanvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
                    
                }
                //EDGE-162025 start
                for(cscfga__Attribute__c att:pc.cscfga__Attributes__r){
                    map_AttributeVsValue.put(att.Name,att.cscfga__Value__c);
                }
                //EDGE-162025 end
                //EDGE - 117740 Start
                map_PlanVsAllowance = new Map<String, String>();
                map_PlanVsPriceItemCommit = new Map<String, String>();
                Map<String,Object> commitRow = new Map<String,Object>(); 
                //EDGE - 117740 End
                map_PlanvsPC.get(pc.Name).add(pc);                
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){                    
                    // EDGE-162024 - Start
                    if(attribute.Name == 'PlanCharge'){
                        String key = pc.Name + attribute.cscfga__Value__c;
                        if(map_PlanNetValuevsPC.get(key) == null){
                        map_PlanNetValuevsPC.put(key,new List<cscfga__Product_Configuration__c>());                          
                        }
                        map_PlanNetValuevsPC.get(key).add(pc);                    
                    }
                    //EDGE-162024 -End
            //EDGE-144779
                    if(attribute.name == 'OfferTypeString'){
                        map_PlanVsPCAttrib.put(pc.Name,attribute.cscfga__Value__c);
                    }
                    if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True){
                        temp = attribute.cscfga__Value__c;
                        objectAPIName = temp.getSObjectType().getDescribe().getName();                        
                        if(objectAPIName.equalsIgnoreCase('cspmb__Price_Item__c')){
                            map_PlanVsPriceItem.put(pc.name,attribute.cscfga__Value__c);
                            //EDGE - 117740 Start
                            map_PlanVsPriceItemCommit.put(pc.id,attribute.cscfga__Value__c);                            
                            //EDGE - 117740 End                    
                            map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);                         
                             
                           
                        }                           
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Price_Item_Add_On_Price_Item_Association__c'))
                        {
               //EDGE-123788 start
                            mapOfAddOnAssociationvsPC.put(attribute.cscfga__Value__c,attribute.cscfga__Product_Configuration__c);
              //EDGE-123788 end
                            //EDGE-162025 start
                            if(attribute.Name != 'InternationalDirectDial'){
                           if(map_AddonsAssociation.get(attribute.cscfga__Value__c) == null)
                                map_AddonsAssociation.put(attribute.cscfga__Value__c,new List<Id>());
                            map_AddonsAssociation.get(attribute.cscfga__Value__c).add(attribute.id);
                        }
                            
                            //--- Prod Inc IDD consolidation
                            if(attribute.Name == 'InternationalDirectDial' && map_AttributeVsValue.get('IDD Charge') != null && map_AttributeVsValue.get('SelectIDD') == 'Premium'){
                                String IDDkey;
                                if(map_AttributeVsValue.get('IDD Charge Discounted') == null || map_AttributeVsValue.get('IDD Charge Discounted') == ''){
                                  IDDkey = map_AttributeVsValue.get('SelectIDD')+map_AttributeVsValue.get('IDD Charge'); 
                                }else{
                                  IDDkey = map_AttributeVsValue.get('SelectIDD')+map_AttributeVsValue.get('IDD Charge Discounted');   
                                }
                                if(map_AddonIDDAsso.get(IDDkey)==null){
                                    map_AddonIDDAsso.put(IDDkey,new List<Id>());    
                                }
                                map_AddonIDDAsso.get(IDDkey).add(attribute.cscfga__Value__c);              
                            }
                            //---end
                            // #3G Standard Consolidation map_Addon3GStandardAsso
                            If(attribute.Name =='MessageBank' && map_AttributeVsValue.get('MessageBank RC')!=null && (map_AttributeVsValue.get('MessageBankString') == '3G Standard Retail' || map_AttributeVsValue.get('MessageBankString') == 'VOICE to TEXT')){
                              String keyforAddon = map_AttributeVsValue.get('MessageBankString')+map_AttributeVsValue.get('MessageBank RC');
                                if(map_Addon3GStandardAsso.get(keyforAddon)==null){
                                    map_Addon3GStandardAsso.put(keyforAddon,new List<Id>());
                                }
                                map_Addon3GStandardAsso.get(keyforAddon).add(attribute.cscfga__Value__c);
                            }
                            //EDGE-162025 end
                        }
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Add_On_Price_Item__c'))
                        {                            
               //EDGE-123788 start
                            mapOfAddOnvsPC.put(attribute.cscfga__Value__c,attribute.cscfga__Product_Configuration__c);
               //EDGE-123788 end
                            if(map_Addons.get(attribute.cscfga__Value__c) == null)
                                map_Addons.put(attribute.cscfga__Value__c,new List<Id>());
                            map_Addons.get(attribute.cscfga__Value__c).add(attribute.id);
                        }
                        //EDGE-117740 Start
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c'))
                        {
                            map_PlanVsAllowance.put(attribute.cscfga__Value__c,attribute.cscfga__Value__c); 
                        }
                        //EDGE-117740 End
                        
                    }
                    else if(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c.contains('Discount') && !String.isEmpty(attribute.cscfga__Value__c) ){
                        pcVSDiscount.put(pc.id,attribute.cscfga__Value__c);
                        
                    }
                }
                //EDGE-162025 start
                map_AttributeVsValue.clear();
                //EDGE-162025 end
               
                //EDGE - 117740 Start
                //if(pc.name == 'Corporate Mobile Plus-Committed Data'){
                if(pc.cscfga__Product_Definition__r.product_Specification__c== pphhId && pc.name.contains('Committed Data')){
                    
                
                attrIdList1 = new List<String>(map_PlanVsAllowance.keySet());
                String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList1';            
                Map<id,cspmb__Allowance__c> allowanceRecords1 = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
                
                commitRow.put('ExternalId', externalID++);
                //EDGE-140420 - Start
                decimal qty=0; 
                //EDGE-143435 | Adding type Active 
                if(EnvironmentVariable__c.getValues('Committed_Data').Value__c=='True' && (pc.Type__c=='Cancel'|| pc.Type__c=='Active')){
                    qty=sharedQuantity;
                }
                else{
                    qty=pc.Quantity_Product_Configuration__c;
                }
                commitRow.put('Quantity',qty);
                //EDGE-140420 - End
                //EDGE-143435 START | Adding NA for ETC rows
                commitRow.put('GSTIncl_TotalETC', 'N/A');
                commitRow.put('GSTExcl_TotalETC', 'N/A');
                //EDGE-143435 END
                //commitRow.put('Rate',pc.cscfga__Recurring_Charge__c);
                //commitRow.put('Product_Module_Name','Committed Data Plan');
                
                for(String id: map_PlanVsAllowance.keySet()){
                    cspmb__Allowance__c allowance1 = allowanceRecords1.get(id);
                    if(allowance1.type__c == 'Committed Data')
                       sCommittedData = allowance1.Value__c;
                    if(allowance1.type__c == 'Committed Bonus Data')
                    sCommittedBonusData = allowance1.Value__c;
                    }
                    
                    sCommittedText = decimal.valueOf(sCommittedData) + decimal.valueOf(sCommittedBonusData);
                    
                    commitRow.put('Discount_Text',sCommittedText + ' Gb ('+sCommittedData+'Gb + '+sCommittedBonusData+'Gb bonus) data for use in Australia');
                    
                    attrIdList1 = new List<String>(map_PlanVsPriceItemCommit.values());
                    
                    //query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                   // ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList1';                    
                    //Map<id,cspmb__Price_Item__c> priceItemCommit = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
                    Map<id,cspmb__Price_Item__c> priceItemCommit = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)[SELECT id,cspmb__Recurring_Charge__c,name,Unit_Of_Measure__c FROM cspmb__Price_Item__c WHERE id IN :attrIdList1]);
                    
                    for(String id: map_PlanVsPriceItemCommit.values()){
                    cspmb__Price_Item__c priceItemCommitRecord = priceItemCommit.get(id);
                    
                    commitRow.put('Rate',priceItemCommitRecord.cspmb__Recurring_Charge__c);
                    commitRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemCommitRecord.cspmb__Recurring_Charge__c);
                    commitRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemCommitRecord.cspmb__Recurring_Charge__c));
                    commitRow.put('Product_Module_Name',priceItemCommitRecord.name);
                    commitRow.put('Unit_Of_Measure',priceItemCommitRecord.Unit_Of_Measure__c);
                    }
                    //EDGE-140420 - Start
                   
                        if(qty>0)
                           // system.debug('commitRow-->'+commitRow);
                        rows.add(commitRow);
                   
                    //EDGE-140420 - Start
                }
                //EDGE - 117740 End
            }
            
            List<String> attrIdList = map_PlanVsPriceItem.values();
            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
            attrIdList = new List<String>(map_AddonsAssociation.keySet());
            query = ' SELECT cspmb__Add_On_Price_Item__r.Billing_Description__c,cspmb__Add_On_Price_Item__r.Charge_Id__c,cspmb__Add_On_Price_Item__r.taxTreatment__c, ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item_Add_On_Price_Item_Association__c')) + ' ,cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c' +
                ' FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE id IN :attrIdList';               
            Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c> Add_On_Price_Item_Association_Records = new Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c>((List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)Database.query(query));
            attrIdList = new List<String>(map_Addons.keySet());
            query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Add_On_Price_Item__c')) + ' ' +
                ' FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrIdList';                  
            Map<id,cspmb__Add_On_Price_Item__c> Add_On_Price_Item_Records = new Map<id,cspmb__Add_On_Price_Item__c>((List<cspmb__Add_On_Price_Item__c>)Database.query(query));
            //EDGE-117740 Start
            //attrIdList = new List<String>(map_PlanVsAllowance.values());
            attrIdList = new List<String>(map_PlanVsAllowance.keySet());
            query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Allowance__c> allowanceRecords = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
            //EDGE-117740 End
            
            for(String deviceKey: map_PlanNetValuevsPC.keySet()){
                system.debug('deviceKey' + deviceKey);
                Map<String,Object> newRow = new Map<String,Object>();                
                Integer qty = map_PlanNetValuevsPC.get(deviceKey).size(); 
                if(qty>0){
                    String displayText='';
                    
                    List<cscfga__Product_Configuration__c> lstOfPC1=map_PlanNetValuevsPC.get(deviceKey);
                    
                    String pcName = lstOfPC1[0].Name;
                    
                    //EDGE-144779
                    if(!(map_PlanVsPCAttrib.get(pcName) =='Committed Data' || map_PlanVsPCAttrib.get(pcName) =='FairPlay Data')){
                       
                    newRow.put('ExternalId', externalID++);
                    newRow.put('Quantity',qty);
                        cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pcName));
                        
             //EDGE-123788 start
                        List<cscfga__Product_Configuration__c> lstOfPC=map_PlanNetValuevsPC.get(deviceKey);
                        List<String> listOfDiscountText=new List<String>();
                        
                        if(lstOfPC!=null && !lstOfPC.isEmpty()){
                            for(cscfga__Product_Configuration__c pc:lstOfPC){
                                if(pc.Name==lstOfPC[0].Name){
                                    if(mapOfDLIvsDiscount!=null){
                                       
                                       listOfDiscountText=bskHandle.getDiscountApplied(pc.Id,mapOfDLIvsDiscount);
                                       
                                   }
                                }
                            }
                        }
            //EDGE-123788 end
                    
                    if(priceItemRecord != null) //EDGE-117740
                    {
                        newRow.put('Product_Module_Name',(priceItemRecord.Billing_Description__c).capitalize());                        
                        newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                        newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                        newRow.put('Rate',priceItemRecord.cspmb__Recurring_Charge__c);
                        newRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                        if(priceItemRecord.taxTreatment__c!=null && priceItemRecord.taxTreatment__c.contains('GST Applicable'))    
                            newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                        else
                            newRow.put('GSTIncl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                    }
                    newRow.put('GSTIncl_TotalETC', 'N/A');
                    newRow.put('GSTExcl_TotalETC', 'N/A');
           //EDGE-123788 start
            if(!listOfDiscountText.isEmpty()){
                            String discountStr=String.valueOf(listOfDiscountText);
                            newRow.put('Discount_Text', discountStr);
                        }
           //EDGE-123788 end
                    rows.add(newRow);
                    }
                }
            }
            //---- EDGE-162025 - Sun -IDD Prod Incident fix
            List<Id> lstaddonAllIds = new List<Id>();
            for(String id: map_AddonIDDAsso.keySet()){
                lstaddonAllIds.addAll(map_AddonIDDAsso.get(id));
            }
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstPIAddon=ProductBasketDataHandler.getPIsForPC(lstaddonAllIds);
            for(String id: map_AddonIDDAsso.keySet()){
                Decimal totalRC = 0.00;String unitofMsg;String taxTreatment;String billingDesc;Decimal IDDRate = 0.00;
                Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c> mapAddIdVsRec = new Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c addon1:lstPIAddon){
                    mapAddIdVsRec.put(addon1.Id,addon1);
                    unitofMsg = addon1.cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c;
                    taxTreatment = addon1.cspmb__Add_On_Price_Item__r.taxTreatment__c;
                    billingDesc = addon1.cspmb__Add_On_Price_Item__r.Billing_Description__c;
                }
                for(Id ids:map_AddonIDDAsso.get(Id)){
                    totalRC += mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                    IDDRate = mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                }
                List<String> listOfDiscountText=new List<String>();
                if(!lstPIAddon.isEmpty()){
                    String pCId=mapOfAddOnAssociationvsPC.get(lstPIAddon[0].Id);                    
                    if(pCId!=null){
                        if(lstPIAddon[0].cspmb__Add_On_Price_Item__r.charge_id__c=='DMCAT_RecurringCharge_000669'){
                            listOfDiscountText.addAll(bskHandle.getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount));
                        }
                    }
                }
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',billingDesc);
                Integer qty = map_AddonIDDAsso.get(id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',unitofMsg);
                newRow.put('Rate',IDDRate);
                newRow.put('GSTExcl_Total_Recurring_Charges',totalRC);
                if(taxTreatment!=null && taxTreatment.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(totalRC));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',totalRC);  
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');                
                if(!listOfDiscountText.isEmpty()){
                    String discountStr=String.valueOf(listOfDiscountText);
                    newRow.put('Discount_Text', discountStr);
                }        
                
                rows.add(newRow);
            }
            // Consolidation for 3g Standard
            List<Id> lst3GAddons = new List<Id>();
            for(String id: map_Addon3GStandardAsso.keySet()){
                lst3GAddons.addAll(map_Addon3GStandardAsso.get(id));
            }
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lst3Gadd = ProductBasketDataHandler.getPIsForPC(lst3GAddons); 
            for(String id: map_Addon3GStandardAsso.keySet()){ 
                Decimal totalAddonRC = 0.00;String unitofMsg;String taxTreatment;String billingDesc; Decimal Addonrate = 0.00;
                Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c> mapAddIdVsRec = new Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c addon2:lst3Gadd){
                    mapAddIdVsRec.put(addon2.Id,addon2);
                    unitofMsg = addon2.cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c;
                    taxTreatment = addon2.cspmb__Add_On_Price_Item__r.taxTreatment__c;
                    billingDesc = addon2.cspmb__Add_On_Price_Item__r.Billing_Description__c;
                }
                for(Id ids:map_Addon3GStandardAsso.get(Id)){
                    totalAddonRC += mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                    Addonrate = mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                }
          List<String> listOfDiscountText=new List<String>();
                if(!lst3Gadd.isEmpty()){
                    String pCId=mapOfAddOnAssociationvsPC.get(lst3Gadd[0].Id);                    
                if(pCId!=null){
                        if(lst3Gadd[0].cspmb__Add_On_Price_Item__r.charge_id__c=='DMCAT_RecurringCharge_000669'){
                        listOfDiscountText.addAll(bskHandle.getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount));
                
                    }
                }
                }
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',billingDesc);
                Integer qty = map_Addon3GStandardAsso.get(Id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',unitofMsg);
                newRow.put('Rate',Addonrate);
                newRow.put('GSTExcl_Total_Recurring_Charges',totalAddonRC);
                if(taxTreatment!=null && taxTreatment.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(totalAddonRC));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',totalAddonRC);  
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');
        if(!listOfDiscountText.isEmpty()){
          String discountStr=String.valueOf(listOfDiscountText);
          newRow.put('Discount_Text', discountStr);
        }
                
                rows.add(newRow);
            }
            // End
            //----EDGE-162025 Sun- Prod Incident fix end map_Addon3GStandardAsso
            for(String id: map_Addons.keySet()){
                Map<String,Object> newRow = new Map<String,Object>();
                cspmb__Add_On_Price_Item__c addOn = Add_On_Price_Item_Records.get(id);
         //EDGE-123788 start
        String pCId=mapOfAddOnvsPC.get(id);
         List<String> listOfDiscountText=new List<String>();
        
        if(pCId!=null){
             listOfDiscountText=bskHandle.getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount);
        
         }
         //EDGE-123788 end
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',(addOn.Billing_Description__c).capitalize());
                Integer qty = map_Addons.get(id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',addOn.Unit_Of_Measure__c);
                newRow.put('Rate',addOn.cspmb__Recurring_Charge__c);
                newRow.put('GSTExcl_Total_Recurring_Charges',qty*addOn.cspmb__Recurring_Charge__c);
                if(addOn.taxTreatment__c!=null && addOn.taxTreatment__c.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*addOn.cspmb__Recurring_Charge__c));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',qty*addOn.cspmb__Recurring_Charge__c);
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');
         //EDGE-123788 start
        if(!listOfDiscountText.isEmpty()){
          String discountStr=String.valueOf(listOfDiscountText);
          newRow.put('Discount_Text', discountStr);
        }
         //EDGE-123788 end
                rows.add(newRow);
            }
        }
        catch(Exception e)
        {
            //System.debug('***Telstra:ProductBasketDataHandler:getCMPServices:exception:'+e.getLineNumber()+' '+e.getMessage());
            C2O_Utilities.createException(e);
        }
        
        return rows;
    }
    //EDGE-98246 - end 
    
}
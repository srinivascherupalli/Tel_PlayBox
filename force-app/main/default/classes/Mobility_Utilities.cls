/*
* @Author : Mary Thangaraj
* @Created Date : 6/07/2021
* @Desc : Mobility Utility Class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class Mobility_Utilities {
    //// created final vars to remove hardcoded values form SOQL
    public static final String Product_Type = 'Enterprise Mobility';
    @TestVisible public static final String PCOffer = 'CWP Mobility';
    @TestVisible public static final String AName = 'Device Model';
    public static final String PCType = 'Cancel';
    
    public List<Map<String,Object>> getMobilityTypeProducts(String basketId,Map<String,String> subfilters) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer externalId = 1;        
        try{
            List<cscfga__Product_Configuration__c> pcList =[select id,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__unit_one_off_charge__c,cscfga__total_one_off_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Price__c,cscfga__Recurring__c, cscfga__Line_Item_Description__c, cscfga__Value__c,cscfga__Is_Line_Item__c,
                                                                                                                                                                                                                                                                                               cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, 
                                                                                                                                                                                                                                                                                               cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                                                                                                                                                                                                                                                                                               FROM cscfga__Attributes__r 
                                                                                                                                                                                                                                                                                               WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) from cscfga__Product_Configuration__c where cscfga__Product_Family__c IN ('Mobility','Mobile Device') and cscfga__Product_Basket__c =:basketId order by cscfga__unit_recurring_charge__c desc];
            //// [select id,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__unit_one_off_charge__c,(SELECT Id, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c,  cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c  FROM cscfga__Attributes__r  WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) from cscfga__Product_Configuration__c where cscfga__Product_Family__c IN ('Mobility','Mobile Device') and cscfga__Product_Basket__c =:basketId order by cscfga__unit_recurring_charge__c desc];
            //map parent-pc with attributes of mobility-plan, message-bank and device
            Map<String,List<cscfga__Attribute__c>> allAttributes = new Map<String,List<cscfga__Attribute__c>>();
            for(cscfga__Product_Configuration__c pc:pcList){                    
                if(String.isBlank(pc.cscfga__Parent_Configuration__c)){
                    allAttributes.put(pc.id,new List<cscfga__Attribute__c>());                   
                    (allAttributes.get(pc.id)).addAll(pc.cscfga__Attributes__r); 
                }else if(!String.isBlank(pc.cscfga__Parent_Configuration__c) && allAttributes.containsKey(pc.cscfga__Parent_Configuration__c)){
                    allAttributes.get(pc.cscfga__Parent_Configuration__c).addAll(pc.cscfga__Attributes__r);
                }
            }
            Map<String,Object> rowTemp = new Map<String,Object>(); 
            Map<String,Object> rowMobilityPlan = new Map<String,Object>(); 
            Map<String,Object> rowMessageBank = new Map<String,Object>();     
            List<Map<String,Object>> rowsOfDevices = new List<Map<String,Object>>();
            List<Map<String,Object>> rowsOfMessageBanks = new List<Map<String,Object>>();
            List<Map<String,Object>> rowsOfMobilityPlans = new List<Map<String,Object>>();            
            Set<String> messageBanksSet=new Set<String>();
            Set<String> mobilityPlansSet=new Set<String>();                    
            externalId = 3;
            for(cscfga__Product_Configuration__c pc:pcList){
                if(String.isBlank(pc.cscfga__Parent_Configuration__c)){
                    rowMessageBank=new Map<String,Object>();
                    rowMobilityPlan=new Map<String,Object>();
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    rowMobilityPlan.put('ExternalId', String.valueOf(externalId));
                    rowMessageBank.put('ExternalId', String.valueOf(externalId));
                    if(pc.cscfga__unit_one_off_charge__c>0)
                        rowTemp.put('Type','Once-off Charges');
                    else if(pc.cscfga__unit_recurring_charge__c>0)
                        rowTemp.put('Type','Recurring Charges');
                    for(cscfga__Attribute__c att:allAttributes.get(pc.id)){
                        String mappingfield = '';                        
                        mappingfield = (att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
                        
                        if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('Device')){
                            rowTemp.put(mappingfield, att.cscfga__Value__c); 
                            
                            rowTemp.put('Order_Type','Devices');
                            if(mappingfield.equalsIgnoreCase('GSTExcl_Total_Recurring_Charges') && !String.isBlank(att.cscfga__Value__c) && pc.cscfga__unit_recurring_charge__c>0)                                
                                //// rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                                rowTemp.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                            if(mappingfield.equalsIgnoreCase('GSTExcl_Total_Onceoff_Charges') && !String.isBlank(att.cscfga__Value__c) && pc.cscfga__unit_one_off_charge__c>0){                                
                                // rowTemp.put('GSTExcl_Total_Recurring_Charges',att.cscfga__Value__c);
                                //// rowTemp.put('GSTIncl_Total_Onceoff_Charges',calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                                rowTemp.put('GSTIncl_Total_Onceoff_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                            }
                        }
                        if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('Plan')){                           
                            rowMobilityPlan.put(mappingfield, att.cscfga__Value__c);
                            rowMobilityPlan.put('Type','Recurring Charges');
                            rowMobilityPlan.put('Order_Type','Mobile Services');
                            if(mappingfield.contains('Product_Module_Name'))
                            //if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c.contains('Product_Module_Name'))
                                mobilityPlansSet.add(att.cscfga__Value__c);
                        }
                        if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('MessageBank')){
                            rowMessageBank.put(mappingfield, att.cscfga__Value__c);
                            rowMessageBank.put('Type','Recurring Charges');
                            rowMessageBank.put('Order_Type','Mobile Services');
                            if(mappingfield.contains('Product_Module_Name'))
                                messageBanksSet.add(att.cscfga__Value__c);
                        }
                    }
                    rowsOfMessageBanks.add(rowMessageBank);
                    rowsOfMobilityPlans.add(rowMobilityPlan); 
                    if(subfilters.get('Order_Type') == rowTemp.get('Order_Type') && subfilters.get('Type') == rowTemp.get('Type') ){
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',( Decimal.valueOf(rowTemp.get('Rate').toString()) * Decimal.valueOf(rowTemp.get('Quantity').toString())));
                        //// rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice( Decimal.valueOf(rowTemp.get('Rate').toString()) * Decimal.valueOf(rowTemp.get('Quantity').toString())));
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice( Decimal.valueOf(rowTemp.get('Rate').toString()) * Decimal.valueOf(rowTemp.get('Quantity').toString())));
                        rowsOfDevices.add(rowTemp);
                    }    
                    externalId++;
                }
            }
            /* *********************************************************************************
* Author : Jayesh
* Date : 17 June 2019
* Description : Logic to show the Mobility Product Discount Amount/Percentage on Quote - Contract
* Jira Cloud : EDGE-85582
********************************************************************************* */
            List<Map<String,Object>> rowsTemp = rowsOfMobilityPlans;
            if(subfilters.get('Order_Type') == 'Mobile Services') 
            {
                integer sum_quantity = 0;
                Decimal sum_charges = 0.0;
                Decimal sum_GSTcharges = 0.0;
                for(Map<String,Object> mB:rowsTemp)
                {
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    rowTemp.put('Product_Module_Name',mB.get('Product_Module_Name'));    
                    rowTemp.put('Rate',mB.get('Rate'));
                    rowTemp.put('Unit_Of_Measure',mB.get('Unit_Of_Measure'));
                    rowTemp.put('Type',mB.get('Type'));
                    rowTemp.put('Offer_Name',mB.get('Offer_Name'));
                    rowTemp.put('Order_Type','Mobile Services');
                    if(mB.get('PlanDiscount')!=null || mB.get('PlanDiscount')!='')
                    {
                        rowTemp.put('PlanDiscount',mB.get('PlanDiscount'));
                        String str = 'Includes $' + mB.get('PlanDiscount') + ' discount while device repayment option applied';
                        rowTemp.put('Discount_Text',str);
                        rowTemp.put('Rate',Decimal.valueOf(String.valueOf(mB.get('Rate'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount'))));
                        rowTemp.put('Quantity',Integer.valueOf(String.valueOf(mB.get('Quantity'))));
                        //rowTemp.put('GSTExcl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))));
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount'))));
                        //rowTemp.put('GSTIncl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges'))));
                        //// rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount')))));
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount')))));
                        rows.add(rowTemp);
                    }else
                    {
                        if(mB.get('Quantity')!=null && mB.get('Quantity')!='')
                            sum_quantity += Integer.valueOf(String.valueOf(mB.get('Quantity')));
                        if(mB.get('GSTExcl_Total_Recurring_Charges')!=null && mB.get('GSTExcl_Total_Recurring_Charges')!='')
                            sum_charges +=Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges')));
                        if(mB.get('GSTIncl_Total_Recurring_Charges')!=null && mB.get('GSTIncl_Total_Recurring_Charges')!='')
                            sum_GSTcharges +=Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges')));
                        rowTemp.put('Quantity',sum_quantity);
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',sum_charges);
                        //// rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(sum_charges));
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(sum_charges));
                        rows.add(rowTemp);
                    }
                    ExternalId++;
                }
            }            
            List<Map<String,Object>> rowsTemp1 = rowsOfMessageBanks;
            Set<String> setTemp1 = messageBanksSet;            
            if((subfilters.get('Order_Type') == 'Mobile Services') || (Test.isRunningTest()))           
            {                
                for(String messageBank:setTemp1)
                {
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    integer sum_quantity = 0;
                    Decimal sum_charges = 0.0;
                    Decimal sum_GSTcharges = 0.0;
                    for(Map<String,Object> mB:rowsTemp1)
                    {
                        if(messageBank.equalsIgnoreCase(String.valueOf(mB.get('Product_Module_Name'))))
                        {
                            rowTemp.put('Product_Module_Name',mB.get('Product_Module_Name'));    
                            rowTemp.put('Rate',mB.get('Rate'));
                            rowTemp.put('Unit_Of_Measure',mB.get('Unit_Of_Measure'));
                            rowTemp.put('Type',mB.get('Type'));
                            rowTemp.put('Offer_Name',mB.get('Offer_Name'));
                            rowTemp.put('Order_Type','Mobile Services');
                            if(mB.get('Quantity')!=null && mB.get('Quantity')!='')
                                sum_quantity += Integer.valueOf(String.valueOf(mB.get('Quantity')));
                            if(mB.get('GSTExcl_Total_Recurring_Charges')!=null && mB.get('GSTExcl_Total_Recurring_Charges')!='')
                                sum_charges +=Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges')));
                            if(mB.get('GSTIncl_Total_Recurring_Charges')!=null && mB.get('GSTIncl_Total_Recurring_Charges')!='')
                                sum_GSTcharges +=Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges')));
                        }
                    }      
                    rowTemp.put('Quantity',sum_quantity);
                    if(sum_charges <= 0) 
                        continue;
                    rowTemp.put('GSTExcl_Total_Recurring_Charges',sum_charges);
                    //// rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(sum_charges));
                    rowTemp.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(sum_charges));
                    rows.add(rowTemp);
                }
            }
            // end EDGE-85582  
            if(subfilters.get('Order_Type') == 'Devices')
                rows.addAll(rowsOfDevices);
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);	   /// added exception
        }
        return rows;
    }
    
    public List<Map<String,Object>> getMobilityCancelTypeProducts(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{		//// added try catch block
            ////String soqlQuery='SELECT name,cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, TotalGSTInclusiveTRC__c, cscfga__One_Off_Charge__c, Quantity_Product_Configuration__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r WHERE name=\'Device Model\') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\' AND csordtelcoa__Replaced_Subscription__c!=null AND type__c=\'Cancel\' order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
            List<cscfga__Product_Configuration__c> pcList = [SELECT name,cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, TotalGSTInclusiveTRC__c, cscfga__One_Off_Charge__c, Quantity_Product_Configuration__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r WHERE name= 'Device Model') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =:basketId AND csordtelcoa__Replaced_Subscription__c!=null AND type__c='Cancel' order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c];
            ////(only required attributes are used in query)//// [SELECT cscfga__unit_one_off_charge__c, OfferName__c, type__c, Quantity_Product_Configuration__c, (SELECT Id, cscfga__Display_Value__c FROM cscfga__Attributes__r WHERE name=: AName) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =:basketId AND csordtelcoa__Replaced_Subscription__c!=null AND type__c=: PCType order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c];
            Integer j=1;
            ////Decimal total_one_off_charge_exGST = 0.00;
            Decimal total_one_off_charge_incGST = 0.00;
            Set<String> offerName = new Set<String>();
            ////list<cscfga__Product_Configuration__c> pcList = Database.query(soqlQuery);
            Map<String,Object> rowcancel =null;
            if(pcList != null && pcList.size()>0){				//// added this check
                for(cscfga__Product_Configuration__c pc2:pcList){                   
                    if(pc2.OfferName__c == PCOffer && !pc2.cscfga__Attributes__r.IsEmpty()) {
                        rowcancel = new Map<String,Object>();
                        
                String tempOffername='';
                tempOffername = (String.valueOf(pc2.OfferName__c)==null?pc2.csordtelcoa__Replaced_Subscription__r.Name:String.valueOf(pc2.OfferName__c));                   
                if(tempOffername.contains('CWP Mobility'))
                    rowcancel.put('Existing_Service','CWP Mobility');
                else
                    rowcancel.put('Existing_Service',tempOffername);
                rowcancel.put('GSTExcl_TotalETC',pc2.cscfga__unit_one_off_charge__c);
                rowcancel.put('GSTIncl_TotalETC',ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__unit_one_off_charge__c));
                //rowcancel.put('Device_Model',pc2.cscfga__Display_Value__c);
                if(!pc2.cscfga__Attributes__r.IsEmpty())
                    rowcancel.put('Device_Model',pc2.cscfga__Attributes__r[0].cscfga__Display_Value__c);
                rowcancel.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);
                rowcancel.put('Quantity',pc2.Quantity_Product_Configuration__c);                
                rowcancel.put('ExternalId', String.valueOf(j));
                rows.add(rowcancel);
                j++;
                    }
                }
            }
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);		/// added exception
        }
        return rows;
    }
    
    //EDGE-175105 - Start
    public List<Map<String,Object> > getMobilityTransitionHardwareAndDevice(String basketId, Map<String,String> subfilters){
        Map<string,Decimal> newmap = new Map<string,Decimal>();
        Integer externalId = 1;
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{
            List<Service_Add_On__c> myRecs = [select Device_Description__c, Monthly_Amount__c,
                                              Residual_Remaining_Term__c from Service_Add_On__c where Legacy_Service__r.Select__c = TRUE  AND Legacy_Service__r.Product_Basket__c =:basketId AND Legacy_Service__r.Product_Type__c =: Product_Type];
             Map<string, Service_Add_On__c> serviceMap = new Map<string, Service_Add_On__c>();
            if(myRecs != null && myRecs.size()>0){
                  for(Service_Add_On__c serAdd :myRecs){
                      serviceMap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c ,serAdd);
                 }        
                for(Service_Add_On__c serAdd :myRecs){
                    if(newmap.containsKey(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c)){
                        //// Decimal d = newmap.get(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c);
                        //// d=d+1;
                        Decimal d = newmap.get(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c)+1;
                        newmap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c,d); 
                    }else
                    {
                        newmap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c,1);
                    }
                }
                for (String key : newmap.keySet()) {
                    Map<String,Object> newRow = new Map<String,Object>();
                    decimal Quantity = newmap.get(key); 
                    Integer QuantityIntVal = Quantity != 0 ? Integer.valueOf( Quantity ) : 1;
                    String[] res = key.split(',');
                    decimal Monthly_amountCal = res[1] != null ? decimal.valueOf( res[1] ) : 1;
                    decimal Remaining_MonthsCal = res[2] != null ? decimal.valueOf( res[2] ) : 1;
                    decimal remainingTotalAMT = Remaining_MonthsCal * Monthly_amountCal * QuantityIntVal;
                    newRow.put('Existing_Service',res[0]);
                    newRow.put('ExternalId',externalId++);
                    newRow.put('Recurring_Charges',res[1]);
                    newRow.put('Quantity',Quantity);
                    newRow.put('Total_Contract_Value',res[2]);
                    newRow.put('Total_Once_Off',remainingTotalAMT);
                    rows.add(newRow);
                }
            }
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);		//// added exception
        }
        return rows;
    }
    
    //EDGE-173365 - getBSMobilityTransition Start
    public List<Map<String,Object>> getBSMobilityTransition(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{
            Integer externalID=1;
            Integer intg;
            Map<String,Integer> mpPlan = new Map<String,Integer>();
            Map<String,Object> row ;
            List<Legacy_Service__c> lstLegacySrvcLst = [SELECT Id, Plan_Name__c FROM Legacy_Service__c WHERE Product_Basket__c = :basketId AND Product_Type__c =: Product_Type AND Select__c = TRUE];
            if(lstLegacySrvcLst != null && lstLegacySrvcLst.size()>0){
                for(Legacy_Service__c ls:lstLegacySrvcLst){
                    if(mpPlan.containsKey(ls.Plan_Name__c)){
                        intg = mpPlan.get(ls.Plan_Name__c)+1;
                        mpPlan.put(ls.Plan_Name__c, intg);
                    }
                    else{
                        mpPlan.put(ls.Plan_Name__c, 1);
                    }
                }
                for(String s:mpPlan.KeySet()){
                    row = new Map<String,Object>();             
                    row.put('ExternalId', String.valueOf(externalID));
                    row.put('Plan_Data', s);
                    row.put('Quantity',String.valueOf(mpPlan.get(s)));              
                    rows.add(row);
                    externalId ++;
                }
            }
        }
        catch(Exception e){
            C2O_Utilities.createException(e);
        }
        return rows;
    }
    
    //Method to populate line-items in Services-To-cancel table of Quote/Orderform
    public List<Map<String,Object>> getCancelTypeProducts(String basketId){
        List<Map<String,Object>> rows;
        try{
         rows = new List<Map<String,Object>>();
        
        // Yash : EDGE-63430 : Query Modification
        ////  STring soqlQuery='SELECT name,cscfga__unit_one_off_charge__c,OfferName__c,cscfga__Parent_Configuration__r.Offername__c,Site_Name__c,Site_Address__c, cscfga__Contract_Term__c,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,csordtelcoa__Replaced_Subscription__r.Contract_Start_Date__c,csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c,csordtelcoa__Replaced_Subscription__r.Name,Quantity_Product_Configuration__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\' and name=\'IP Site\' and csordtelcoa__Replaced_Subscription__c!=null and type__c=\'Cancel\' order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
List<cscfga__Product_Configuration__c> pcList = [SELECT name, cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Parent_Configuration__r.Offername__c, Site_Name__c, Site_Address__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c, type__c, cscfga__total_recurring_charge__c, TotalGSTInclusiveTRC__c, cscfga__total_contract_value__c,cscfga__One_Off_Charge__c, csordtelcoa__Replaced_Subscription__r.Contract_Start_Date__c, csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c, csordtelcoa__Replaced_Subscription__r.Name, Quantity_Product_Configuration__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND name = 'IP Site' AND csordtelcoa__Replaced_Subscription__c != null AND type__c = 'Cancel' ORDER BY cscfga__Parent_Configuration__r.cscfga__originating_offer__c];
        Integer j = 1;      
        ////   Decimal total_one_off_charge_exGST = 0.00;
        Decimal total_one_off_charge_incGST = 0.00;
        Decimal total_recurring_charge_exGST = 0.00;
        Decimal total_recurring_charge_incGST = 0.00;
        Set<String> offerName = new Set<String>();
        ////  list<cscfga__Product_Configuration__c> pcList = Database.query(soqlQuery);
        Map<String,Object> rowcancel = null;
        if(pcList != null && pcList.size()>0){				//// added this check
            for(cscfga__Product_Configuration__c pc2:pcList){
                if(pc2.name=='IP Site') {
                    rowcancel = new Map<String,Object>();
                    String tempOffername='';
                    tempOffername = (String.valueOf(pc2.OfferName__c)==null?pc2.csordtelcoa__Replaced_Subscription__r.Name:String.valueOf(pc2.OfferName__c));                   
                    // Start EDGE-67629
                    if(tempOffername.contains('Connected Workplace'))
                        rowcancel.put('Existing_Service','Connected Workplace');
                    else
                        rowcancel.put('Existing_Service',tempOffername);     
                    // end EDGE-67629
                    rowcancel.put('Site_Name',pc2.Site_Name__c);
                    rowcancel.put('Site_Address',pc2.Site_Address__c);
                    rowcancel.put('Total_Once_Off',pc2.cscfga__unit_one_off_charge__c);
                    //Manoj : EDGE : 63432 : 05/Feb/2019 : Start
                    rowcancel.put('GSTExcl_TotalETC',pc2.cscfga__unit_one_off_charge__c);
                    ////  rowcancel.put('GSTIncl_TotalETC',calculateGSTIncludedPrice(pc2.cscfga__unit_one_off_charge__c));
                    rowcancel.put('GSTIncl_TotalETC',ProductBasketDataHandler.calculateGSTIncludedPrice(pc2.cscfga__unit_one_off_charge__c));
                    //Manoj : EDGE : 63432 : 05/Feb/2019 : End
                    rowcancel.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);
                    rowcancel.put('Total_Recurring_Charges',total_recurring_charge_exGST);
                    rowcancel.put('GSTIncl_Total_Recurring_Charges',total_recurring_charge_incGST);
                    // Yash : EDGE-63430 : Start
                    rowcancel.put('Quantity',pc2.Quantity_Product_Configuration__c);
                    // Yash : EDGE-63430 : End
                    String term = pc2.cscfga__Contract_Term__c+' Months';
                    rowcancel.put('Term',term);
                    if(pc2.csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c!=null) { 
                        Date dt=pc2.csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c.date();
                        rowcancel.put('Service_Start_Date', dt.format() );
                    }
                    rowcancel.put('ExternalId', String.valueOf(j));
                    rows.add(rowcancel);
                    j++;
                }
            }
        }
        }
        catch(Exception e){
            C2O_Utilities.createException(e);
        }
        return rows;
    }
}
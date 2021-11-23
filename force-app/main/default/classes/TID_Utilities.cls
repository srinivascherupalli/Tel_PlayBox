/*
* @Desc : TID Utility Class called from RF_ProductBasketDataHandler
* @Jira : DIGI-518
*/
global with sharing class TID_Utilities {
    //// created these variables to remove hard coded values in SOQL
    private static final String Type1 = 'New';
    private static final String Type2 = 'Modify';
    private static final String Type3 = 'Cancel';
    public static List<string> lstInternetSiteSpecCode;
    public TID_Utilities(){
        AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
        lstInternetSiteSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('InternetSiteSpecCode'));
    }
    //EDGE-98336 - Start
    public List<Map<String,Object> > getTIDDetails(String basketId,Map<String,String> subfilters){
        Integer externalId = 1;
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        Map<String,String> snapshotMapping = new Map<String,String> {'Site Name'=>'Site_Name','Site Address'=>'Site_Address','ServiceabilityLocation'=>'Serviceability_Location','ResponseTime'=>'Response_time','RestorationTime'=>'Restoration_time','SelectZone'=>'PAYG_1_to_2','AccessConfigString'=>'PAYG_2_to_3','Bandwidth Shadow'=>'PAYG_3_to_4','RecurringPrice'=>'GSTExcl_Total_Recurring_Charges'};
            Set<String> attributeList= snapshotMapping.keySet();
        try{
            // EDGE-165831 - Filter change
            if(subfilters.get('Type') == Type1 ){
                pcList=[SELECT id,name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and csordtelcoa__Replaced_Product_Configuration__c =null];
               // pcList=[SELECT id,name,(SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and csordtelcoa__Replaced_Product_Configuration__c =null];
            }
            //EDGE-127778 - Added MAC Scenario - Start
            else if(subfilters.get('Type') == Type2 ){
                pcList=[SELECT id,name,Type__c,(SELECT Id, Name,cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and Type__c=: Type2];
               // pcList=[SELECT id,name,Type__c,(SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and Type__c=: Type2];
            }
            //EDGE-127778 - End
                for(cscfga__Product_Configuration__c pc:pcList) {
                    Map<String,Object> newRow = new Map<String,Object>();
                    newRow.put('ExternalId', externalID++);
                    newRow.put('Product_Module_Name', 'Internet Direct');
                    for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                        newRow.put(snapshotMapping.get(attribute.name),attribute.cscfga__Value__c);
                        if(attribute.name=='RecurringPrice'){
                            Decimal strToDec = decimal.valueOf(attribute.cscfga__Value__c);
                            newRow.put('GSTIncl_Total_Recurring_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(strToDec));
                        }
                    }
                    rows.add(newRow);
                
            }
        }
        catch(Exception e){
            C2O_Utilities.createException(e);
        }
        return rows;
    }
    
    //EDGE-127780 Start
    public List<Map<String,Object> > getTIDCancel(String basketId, Map<String,String> subfilters){ 
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String,List<cscfga__Product_Configuration__c>> map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        List<cscfga__Product_Configuration__c> sitePCList = new List<cscfga__Product_Configuration__c>();
        Integer externalId = 1;
        try{   
            //EDGE-165831 - Filter Change 
            //// sitePCList = [SELECT id,Type__c,Site_Name__c,Site_Address__c,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode AND cscfga__Product_Basket__c =:basketId AND Type__c=: Type3];
            sitePCList = [SELECT id,Type__c,Site_Name__c,Site_Address__c,name,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,(SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode AND cscfga__Product_Basket__c =:basketId AND Type__c=: Type3];           
            if(sitePCList != null && sitePCList.size()>0){				//// added this check            
                for(cscfga__Product_Configuration__c pc:sitePCList)
                {
                    Map<String,String> cancelrow = new Map<String,String>();
                    if(pc.Type__c == Type3)
                    {
                        if(map_DeviceModelvsPC.get(pc.Name) == null)
                        {
                            map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());          
                        }
                        map_DeviceModelvsPC.get(pc.Name).add(pc);
                        for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r)
                        {
                            if(attribute.name=='EarlyTerminationCharge')
                            {
                                cancelrow.put('GSTExcl_TotalETC',string.valueOf(attribute.cscfga__Value__c));
                                ////    cancelrow.put('GSTIncl_TotalETC',string.valueOf(calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                                cancelrow.put('GSTIncl_TotalETC',string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                            }
                            if(attribute.name=='DisconnectionDate')
                            {
                                cancelrow.put('Total_Data',string.valueOf(attribute.cscfga__Value__c));//same field used - chk if value will be overwritten
                            }
                            if(attribute.name=='Contract Term')
                            {
                                cancelrow.put('Term',string.valueOf(attribute.cscfga__Value__c));
                            }
                        }
                        cancelrow.put('Service_Start_Date',string.valueOf(pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c));
                        cancelrow.put('ExternalId', String.valueOf(externalId));
                        cancelrow.put('Site_Name', pc.Site_Name__c);
                        cancelrow.put('Site_Address', pc.Site_Address__c);
                        rows.add(cancelrow);
                        externalId++;
                    }                
                }
            }
        }
        catch(Exception e)
        {
            C2O_Utilities.createException(e);
        }
        return rows;
    }
}
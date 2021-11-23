/*
* @Author : Vitap/Aruna 
* @Date : 18th Oct 2020
* @Desc : Handler class for ProductBasketDataSourceConnection
*/
/****History of Updates 
1. Aruna Aware DPG-2421 - IOT Shared Plan || Recurring charge incorrect in Quote(Coming as 1.64$)
2. Jayesh DPG-1311 - Logic to retrieve Recurring charges for IOT Services
3. Jayesh/Aruna DPG-1481 - Method to fetch IoT Shared Data Plan Rate Matrix details
4. Jayesh - DPG-1454 & DPG-1033 - Method to fetch IoT Cancellation details
5. Jayesh - DPG-1690 - removing try as per Governance review comments
6. Aruna Aware 11/02/2020 - DPG-2673 - Generate order form for the IoT Digital water metering solution
7. Payal 27-Nov-2020  EDGE-189788 - Added a Parameter to be passed for getRateCardData method
8. Aruna 23-Mar-2021  DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
****/

global class IoTDataHandler {
    //change start for DPG-598
    static final String iotId = 'DMCAT_Offer_000964';    //change end for DPG-598 
    //DPG-598 : Added to retrieve One off charges for IOT Services
    public List<Map<String,Object> > getIOTServicesOC(String basketId, Map<String,String> subfilters){
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String,List<cscfga__Product_Configuration__c> > map_PlanvsPC = new Map<String,List<cscfga__Product_Configuration__c> >();
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        String objectAPIName=''; 
        Map<String,List<cscfga__Attribute__c>> allAttributes = new Map<String,List<cscfga__Attribute__c>>();
        Map<String,Object> newRow = new Map<String,Object>();

        try{
            if(subfilters.get('Type') =='New') {
                 planPCList =[SELECT id,name,OfferName__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Parent_Configuration__c,cscfga__total_one_off_charge__c, cscfga__Recurring_Charge__c
				,   (   SELECT  Id,Name,cscfga__Product_Configuration__c,cscfga__Display_Value__c,cscfga__Value__c 
                        FROM    cscfga__Attributes__r 
                        WHERE   Name IN ('SharedPlan'))
				 FROM cscfga__Product_Configuration__c where cscfga__Product_Family__c =: Label.IoTPlans AND cscfga__Product_Basket__c = :basketId AND Type__c='New'];
				 
                system.debug('planPCList' + planPCList);
               if(planPCList.size()>0 ){ 
                Integer qty=1;
               
                //Get the Quantity of IOT Configurations
                newRow.put('is_IOT',true);

                    for(cscfga__Product_Configuration__c pc:planPCList) {
                      Map < String, String > mapAttrNameRecord = new Map < String, String >();
						for (cscfga__Attribute__c attributeRecord: pc.cscfga__Attributes__r) {
						if(attributeRecord.Name != 'SharedPlan'){
                           mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
						}else {
						   mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Display_Value__c);
						}
						}
					   qty = Integer.valueOf(pc.Quantity_Product_Configuration__c);
                       newRow.put('ExternalId', externalID++);
                        newRow.put('Product_Module_Name', pc.Name);
						newRow.put('Plan_Data', mapAttrNameRecord.get('SharedPlan'));
                        newRow.put('Quantity',qty);
                        newRow.put('Offer_Name',pc.OfferName__c);
                        newRow.put('Total_Once_Off',qty*pc.cscfga__total_one_off_charge__c);
                        newRow.put('GSTIncl_Total_Onceoff_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*pc.cscfga__total_one_off_charge__c));
                        newRow.put('GSTExcl_Total_Onceoff_Charges',qty*pc.cscfga__total_one_off_charge__c);
                        newRow.put('GSTIncl_Total_Recurring_Charges','NA');
                        newRow.put('GSTExcl_Total_Recurring_Charges','NA');
                        newRow.put('Discount_Text','$ '+pc.cscfga__total_one_off_charge__c+' ex GST per SIM card'); 
                        System.debug('***Telstra:ProductBasketDataHandler:getIOTServicesOC:newRow:'+newRow);
                    }   
               
                rows.add(newRow);
               }
               
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getIOTServicesOC:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getIOTServicesOC: found:'+rows);
        return rows; 
    }
/* *********************************************************************************
* Author : Jayesh/Aruna
* Date : 20 July 2020
* Description : Method to fetch IoT Shared Data Plan Rate Matrix details
* Jira Cloud : DPG-1481
********************************************************************************* */
   /* public List<Map<String,Object>> getIoTSharedDataPlan(String basketId, Map<String,String> subfilters)
    {
        system.debug('basketId ' + basketId);
        Integer externalId = 0;   
        List<Map<String,Object>> rows = new List<Map<String,Object> >();
        if(subfilters.get('Type') =='New'){
            system.debug('inside subfilters');
            RateMatrixForIoTController.RateCardDTOIOT rateCardDTO = RateMatrixForIoTController.getRateCardData('Shared Data',iotId,'','',basketId);//EDGE-189788
            Map<String,List<RateMatrixForIoTController.ChargeRateCardDTOIOT>> RateCardMap = rateCardDTO.RateCardMap;
            Map<String,Object> newRow = new Map<String,Object>();
            for(String str : RateCardMap.keySet()){
                newrow.put('ExternalId',externalId);
                if (str != 'null' ){
                    newRow.put('Plan_Data',str);
                }
                for(RateMatrixForIoTController.ChargeRateCardDTOIOT row : RateCardMap.get(str)){
                    if (row.rangeFrom == 1 && row.rangeTo == 499){
                        newRow.put('VolumeTier1', row.rateValueInclGST);
                    }else if(row.rangeFrom == 500 && row.rangeTo == 999){
                        newRow.put('VolumeTier2', row.rateValueInclGST);
                    }else if (row.rangeFrom == 1000 && row.rangeTo == 2499){
                        newRow.put('VolumeTier3', row.rateValueInclGST);
                    }else if (row.rangeFrom == 2500 && row.rangeTo == 9999){
                        newRow.put('VolumeTier4', row.rateValueInclGST);
                    }else if (row.rangeFrom == 10000 && row.rangeTo == 99999){
                        newRow.put('VolumeTier5', row.rateValueInclGST);
                    }else if (row.rangeFrom == null){
                        newRow.put('VolumeTier6', row.rateValueInclGST);
                    }
                }
                rows.add(newRow);
                newRow = new Map<String,Object>();
                externalId ++;
            }
        }
        return rows;
    } */
/* *********************************************************************************
* Author : Jayesh
* Date : 20 February 2020
* Description : Method to fetch IoT Cancellation details
* Jira Cloud : DPG-1454 & DPG-1033
********************************************************************************* */
    public List<Map<String,Object>> getIoTCancelServices(String basketId, Map<String,String> subfilters)
    {
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object>> rows = new List<Map<String,Object> >();
        Map<String,List<cscfga__Product_Configuration__c>> map_PlanvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        Integer externalId=1;
        system.debug('*****Inside getIoTCancelServices');       
        if(subfilters.get('Type') =='Cancel' ) 
        {
            planPCList =[SELECT id,name,Type__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c FROM cscfga__Product_Configuration__c where cscfga__Product_Family__c =: Label.IoTSubscription AND cscfga__Product_Basket__c = :basketId AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null];
        }
        system.debug('planPCList' + planPCList);
        for(cscfga__Product_Configuration__c pc:planPCList) 
        {
            if(map_PlanvsPC.get(pc.Name) == null) 
            {
                map_PlanvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
            }
            map_PlanvsPC.get(pc.Name).add(pc);
        }
        system.debug('map_PlanvsPC.keySet()' + map_PlanvsPC.keySet());
        Map<String,Object> newRow = new Map<String,Object>();
        Integer qty=1;
        Integer ETC_Charge=0;
        //Get the Quantity of IOT Configurations
        for(String deviceKey: map_PlanvsPC.keySet())
        {
            system.debug('deviceKey...' + deviceKey);
            qty = map_PlanvsPC.get(deviceKey).size(); 
            system.debug('qty.......' + qty);
            for(cscfga__Product_Configuration__c pc:map_PlanvsPC.get(deviceKey)) 
            {
                newRow.put('ExternalId', externalID++);
                //Fetch items from Product configuration and populate in Quote/Contract Template
                newRow.put('Product_Module_Name',pc.Name);
                newRow.put('Quantity',qty);
                newRow.put('Type',pc.Type__c);
                newRow.put('GSTExcl_TotalETC',ETC_Charge);
                newRow.put('GSTIncl_TotalETC',ProductBasketDataHandler.calculateGSTIncludedPrice(ETC_Charge));
                rows.add(newRow);
            }
        }
        System.debug('*****Telstra:ProductBasketDataHandler:getIoTCancelServices -->: '+rows);
        return rows;
    }    

/* *********************************************************************************
* Author : Jayesh
* Date : 20 February 2020
* Description : Method to fetch IoT Cancellation details
* Jira Cloud : DPG-1454 & DPG-1033
********************************************************************************* */
    public List<Map<String,Object> > getM2MServicesOC(String basketId, Map<String,String> subfilters)
  {
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String,List<cscfga__Product_Configuration__c> > map_PlanvsPC = new Map<String,List<cscfga__Product_Configuration__c> >();
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        String objectAPIName=''; 
       // cscfga__Product_Configuration__c solutionPC = new cscfga__Product_Configuration__c();
        Map<String,List<cscfga__Attribute__c>> allAttributes = new Map<String,List<cscfga__Attribute__c>>();
        Map<String,Object> newRow = new Map<String,Object>();

        try{
            if(subfilters.get('Type') =='New') {

                 planPCList =[SELECT id,name,OfferName__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__total_one_off_charge__c, cscfga__Recurring_Charge__c FROM cscfga__Product_Configuration__c where cscfga__Product_Family__c =: Label.IoTSubscription AND cscfga__Product_Basket__c = :basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];
                system.debug('planPCList' + planPCList);

               if(planPCList.size()>0 ){ 
               for(cscfga__Product_Configuration__c pc:planPCList) {
                    if(map_PlanvsPC.get(pc.Name) == null) {
                        map_PlanvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
                    }
                    map_PlanvsPC.get(pc.Name).add(pc);
      
                } 
                Integer qty=1;
                //Get the Quantity of IOT Configurations
        newRow.put('is_M2M',true);
        
                for(String deviceKey: map_PlanvsPC.keySet()){
                    system.debug('deviceKey...' + deviceKey);
                    qty = map_PlanvsPC.get(deviceKey).size(); 
                    system.debug('qty.......' + qty);
                    for(cscfga__Product_Configuration__c pc:map_PlanvsPC.get(deviceKey)) {
                        //Added String Conversion for externalID 
                       // newRow.put('ExternalId', String.valueOf(externalID));
                       newRow.put('ExternalId', externalID++);
                       // externalID++;
                        //Fetch items from Product configuration and populate in Quote/Contract Template
                        newRow.put('Product_Module_Name', pc.Name);
                        //DPG-2673 - Generate order form for the IoT Digital water metering solution.
                        //Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan

                        newRow.put('Quantity',qty);
                        newRow.put('Offer_Name',pc.OfferName__c);
                        // newRow.put('Rate',pc.cscfga__total_one_off_charge__c);
                        newRow.put('Total_Once_Off',qty*pc.cscfga__total_one_off_charge__c);
                        newRow.put('GSTIncl_Total_Onceoff_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(qty*pc.cscfga__total_one_off_charge__c));
                        newRow.put('GSTExcl_Total_Onceoff_Charges',qty*pc.cscfga__total_one_off_charge__c);
                        newRow.put('GSTIncl_Total_Recurring_Charges','NA');
                        newRow.put('GSTExcl_Total_Recurring_Charges','NA');
                       
                        //Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
                        newRow.put('Discount_Text','$ '+pc.cscfga__total_one_off_charge__c+' ex GST per SIM card'); 
                        //DPG-1311 - END
                        System.debug('***Telstra:ProductBasketDataHandler:getM2MServicesOC:newRow:'+newRow);
                        break; //remove the break statement if needs to fetch all prod configs
                    }   
                }
                rows.add(newRow);
               }
               
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getM2MServicesOC:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getM2MServicesOC: found:'+rows);
        return rows; 
    }
}
/****************************************************************************************************************************************
 * @Author : Suyash Chiplunkar/lalit Motiray
 * @Date : 24th Feb 2021
 * @Desc : Handler class for ProductBasketDataSourceConnection
 *@JIRA  : DPG-4421

 /***History of Updates
  * * Sharmila/Payel: Added changes for DIGI-929 and DIGI-930 recommit
 ****************************************************************************************************************************************/

global class SDWANDataHandler {
    /*
     *@purpose : To create SDWAN row data for conga template
     *@param   : 1)basket Id   2)subfilters (passing as empty)
     *@return  : Rows for conga template (list of map row key and value pair)
     */
  
    public List < Map < String, Object >> getSDWANServices (String basketId, Map < String, String > subfilters) {

        System.debug('getSDWANServices subfilters==>'+ JSON.serialize(subfilters));
        System.debug('getSDWANServices subfilters==>'+ subfilters.get('Type'));

        List < cscfga__Product_Configuration__c > planPCList;
        List < Map < String, Object > > rows = new List < Map < String, Object > > ();
        Integer externalId = 1;
        Map < Id, Map < String, String >> allAttributesRelatedPrdt = new Map < Id, Map < String, String >> ();
        Map < Id, List < cscfga__Product_Configuration__c >> mapSolutionIdPCList = new Map < Id, List < cscfga__Product_Configuration__c >> ();
        List < String > offerIDList = new List < String > ();
        offerIDList.add(System.Label.SDWAN_OFFER);
        offerIDList.add(System.Label.SDWAN_ADAPT_OFFER);
        offerIDList.add(System.Label.ENTERPRISE_WIRELESS);
        System.debug('offerIDList==>' + offerIDList);
        try {
            // fetch product configuration
            planPCList = [
                            SELECT      Id  
                                    ,   cssdm__solution_association__c
                                    ,   name
                                    ,   OfferName__c
                                    ,   cscfga__Contract_Term__c
                                    ,   cscfga__Quantity__c
                                    ,   cscfga__Parent_Configuration__c
                                    ,   cscfga__total_one_off_charge__c
                                    ,   cscfga__total_recurring_charge__c
                                    ,   cscfga__Recurring_Charge__c
                                    ,   (   SELECT      Id
                                                    ,   Name
                                                    ,   cscfga__Product_Configuration__c
                                                    ,   cscfga__Display_Value__c
                                                    ,   cscfga__Value__c 
                                            FROM    cscfga__Attributes__r 
                                            WHERE   Name IN ('Auto Data Top Up', 'WirelessPlanChargeId', 'Plan Name')
                                        )
                                    ,   Site_Name__c
                                    ,   Site_Address__c
                                    ,   cscfga__Product_Definition__r.product_Specification__c
                            FROM cscfga__Product_Configuration__c
                            WHERE cscfga__Product_Basket__c =: basketId
                            AND Type__c ='New'
                            AND csordtelcoa__Replaced_Product_Configuration__c = null
                            AND cscfga__Product_Definition__r.product_Specification__c
                            IN: offerIDList
                        ];

            //get allowance Map 
            Map < ID, cspmb__Allowance__c > idAllounceMap = getAllowance();
            //get Commercial product Map for SDWAN using offer Id 
            Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = getCommercialProductDetails();
            System.debug('mapIdCommercialProduct==>'+mapIdCommercialProduct);
            for (cscfga__Product_Configuration__c pc: planPCList) {
                //Crate SolutionId and PC list map
                if (mapSolutionIdPCList.containsKey(pc.cssdm__solution_association__c)) {
                    mapSolutionIdPCList.get(pc.cssdm__solution_association__c).add(pc);
                } else {
                    List < cscfga__Product_Configuration__c > pcList = new List < cscfga__Product_Configuration__c > ();
                    pcList.add(pc);
                    mapSolutionIdPCList.put(pc.cssdm__solution_association__c, pcList);
                }
                //Create Map for Related Product
                if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.ENTERPRISE_WIRELESS || pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_ADAPT_OFFER) {
                    for (cscfga__Attribute__c attributeRecord: pc.cscfga__Attributes__r) {
                        if (allAttributesRelatedPrdt.containskey(pc.id)) {
                            Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                            mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                        } else {
                            Map < String, String > mapAttrNameRecord = new Map < String, String > ();
                            mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                            allAttributesRelatedPrdt.put(pc.id, mapAttrNameRecord);
                        }
                    }
                }
            }
            Integer qty = 1;
            //create row (Map) for conga template
            for (Id solutionId: mapSolutionIdPCList.keySet()) {
                Map < String, Object > newRow = new Map < String, Object > ();
                List < cscfga__Product_Configuration__c > solutuibPCList = mapSolutionIdPCList.get(solutionId);

                for (cscfga__Product_Configuration__c pc: solutuibPCList) {
                    System.debug('pc==>'+pc);
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_OFFER) { //'SDWAN ADAPT S1'
                        newRow.put('Site_Name', pc.Site_Name__c); //Done
                        newRow.put('Site_Address', pc.Site_Address__c); //Done
                    }
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_ADAPT_OFFER) { //child SDWAN SD-WAN ADAPT S1
                       System.debug('inside child SDWAN==>');
                        Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                        if (mapAttrNameRecord.containsKey('Plan Name') && 
                            mapIdCommercialProduct.containsKey(mapAttrNameRecord.get('Plan Name'))) {
                            System.debug('inside if child SDWAN==>'+  mapIdCommercialProduct.get(mapAttrNameRecord.get('Plan Name')));
                            cspmb__Price_Item__c commercialProductrecord = mapIdCommercialProduct.get(mapAttrNameRecord.get('Plan Name'));
                            newRow.put('Product_Module_Name', commercialProductrecord.Billing_Description__c); //Done
                            newRow.put('Rate', commercialProductrecord.cspmb__Recurring_Charge__c); //Done
                            newRow.put('GSTExcl_Total_Recurring_Charges', qty * commercialProductrecord.cspmb__Recurring_Charge__c); //Done
                            newRow.put('GSTIncl_Total_Recurring_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(qty * commercialProductrecord.cspmb__Recurring_Charge__c)); //Done
                            newRow.put('GSTExcl_Total_Onceoff_Charges', qty * commercialProductrecord.cspmb__One_Off_Charge__c); //Done
                            newRow.put('GSTIncl_Total_Onceoff_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(qty * commercialProductrecord.cspmb__One_Off_Charge__c));
                        }
                        newRow.put('VolumeTier1', qty); //Done
                        newRow.put('Discount_Text', System.Label.DiscountText_Contract); //Done
                        newRow.put('Quantity', qty); //Done
                        newRow.put('Type', 'SD-WAN Adapt S1 activation'); //Done
                    }

                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.ENTERPRISE_WIRELESS && allAttributesRelatedPrdt.containsKey(pc.id)) {
                        Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                        // check condition for 'auto data pop up' SDWAN PC attribute and add rows if it has value 
                        if (mapAttrNameRecord.containsKey('Auto Data Top Up') && idAllounceMap.containsKey(mapAttrNameRecord.get('Auto Data Top Up'))) {
                            cspmb__Allowance__c allowanceRecord = idAllounceMap.get(mapAttrNameRecord.get('Auto Data Top Up'));
                            newRow.put('Commercial_Config', allowanceRecord.Description__c); //Done
                            newRow.put('Discount_Template_Name', System.Label.DiscountTemplate_Contract); //Done
                            newRow.put('VolumeTier3', qty); //Done
                        }
                        // check condition for 'WirelessPlanChargeId' enterprice wireless PC attribute and add rows if it has value 
                        if (mapAttrNameRecord.containsKey('WirelessPlanChargeId') && mapIdCommercialProduct.containsKey(mapAttrNameRecord.get('WirelessPlanChargeId'))) {
                            cspmb__Price_Item__c commerProdRecord = mapIdCommercialProduct.get(mapAttrNameRecord.get('WirelessPlanChargeId'));
                            if(commerProdRecord.cspmb__Recurring_Charge__c > 0){
                                
                                newRow.put('Existing_Service', commerProdRecord.Billing_Description__c); //Done
                                newRow.put('Plan_Rate', commerProdRecord.cspmb__Recurring_Charge__c); //Done
                                newRow.put('Bonus_Data', System.Label.BonusData_Contract); //Done
                                newRow.put('VolumeTier2', qty); //Done
                                newRow.put('Total_Recurring_Charges', commerProdRecord.cspmb__Recurring_Charge__c); //Done
                                newRow.put('TotalAnnualMaintanceCharges', ProductBasketDataHandler.calculateGSTIncludedPrice(commerProdRecord.cspmb__Recurring_Charge__c)); //Done
                            
                            }
                        }
                    }
                }
                newRow.put('ExternalId', String.valueOf(externalId));
                newRow.put('isSDWAN', True);
                externalId++;
                rows.add(newRow);
            }
        } catch (Exception exp) {
            System.debug('***Telstra:ProductBasketDataSourceConnection:getSDWANServices:exception:' + exp.getLineNumber() + ' ' + exp.getMessage());
        }
        System.debug('rows==>'+rows);
        return rows;
    }
    
     /* ******************************************************************
      	  Added changes for DIGI-929 and DIGI-930 recommit
         *@purpose : To create SDWAN Cancel Services
         *@param   : 1)basket Id   
         *@return  : Rows for conga template (list of map row key and value pair)
      ******************************************************************   */
        public List<Map<String,Object>> getSDWANCancelServices(String basketId)
        {
            List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
            List<Map<String,Object>> rows = new List<Map<String,Object> >();
            Integer externalId=1;
            Map < Id, Map < String, String >> allAttributesRelatedPrdt = new Map < Id, Map < String, String >> ();
            system.debug('*****Inside getSDWANCancelServices---> ' + allAttributesRelatedPrdt);   
            Map < Id, List < cscfga__Product_Configuration__c >> mapSolutionIdPCList = new Map < Id, List < cscfga__Product_Configuration__c >> ();
            List < String > offerIDList = new List < String > ();
            offerIDList.add(System.Label.SDWAN_OFFER);
            offerIDList.add(System.Label.SDWAN_ADAPT_OFFER);
            offerIDList.add(System.Label.ENTERPRISE_WIRELESS);
            System.debug('offerIDList==>' + offerIDList);
            try
            {
                planPCList = [
                                SELECT      Id  
                                        ,   cssdm__solution_association__c
                                        ,   name
                                        ,   OfferName__c
                                        ,   cscfga__Contract_Term__c
                                        ,   cscfga__Quantity__c
                                        ,   cscfga__Parent_Configuration__c
                                        ,   cscfga__total_one_off_charge__c
                                        ,   cscfga__total_recurring_charge__c
                                        ,   cscfga__Recurring_Charge__c
                    					,   (   SELECT      Id
                                                    ,   Name
                                                    ,   cscfga__Product_Configuration__c
                                                    ,   cscfga__Display_Value__c
                                                    ,   cscfga__Value__c 
                                            FROM    cscfga__Attributes__r 
                                            WHERE   Name IN ('Auto Data Top Up', 'WirelessPlanChargeId', 'Plan Name' ,'LTE Mode')
                                        )
                                        ,   Site_Name__c
                                        ,   Site_Address__c
                                        ,   cscfga__Product_Definition__r.product_Specification__c
                    					,	csordtelcoa__Replaced_Subscription__r.customerFacingServiceId__c
                                FROM cscfga__Product_Configuration__c
                                WHERE cscfga__Product_Basket__c =: basketId
                                AND Type__c ='Cancel'
                                AND csordtelcoa__Replaced_Product_Configuration__c != null
                                AND cscfga__Product_Definition__r.product_Specification__c
                                IN: offerIDList
                            ]; 
                 System.debug('planPCList==>' + planPCList);
            
            //get allowance Map 
            Map < ID, cspmb__Allowance__c > idAllounceMap = getAllowance();
            //get Commercial product Map for SDWAN using offer Id 
            Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = getCommercialProductDetails();
            //System.debug('mapIdCommercialProduct==>'+mapIdCommercialProduct);
            for (cscfga__Product_Configuration__c pc: planPCList) {
                System.debug('checking for attributes -->' + pc.cscfga__Attributes__r);
                //Crate SolutionId and PC list map
                if (mapSolutionIdPCList.containsKey(pc.cssdm__solution_association__c)) {
                    mapSolutionIdPCList.get(pc.cssdm__solution_association__c).add(pc);
                    System.debug('mapSolutionIdPCList ===>' + mapSolutionIdPCList);
                } else {
                    List < cscfga__Product_Configuration__c > pcList = new List < cscfga__Product_Configuration__c > ();
                    pcList.add(pc);
                    mapSolutionIdPCList.put(pc.cssdm__solution_association__c, pcList);
                    System.debug('mapSolutionIdPCList ===>' + mapSolutionIdPCList);
                   // System.debug('PG2');
                }
                //Create Map for Related Product
                if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.ENTERPRISE_WIRELESS || pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_ADAPT_OFFER) {
                    System.debug('Inside Related Product if....' + pc.cscfga__Attributes__r);
                    for (cscfga__Attribute__c attributeRecord: pc.cscfga__Attributes__r) {
                        System.debug('PG5--> '+ pc.cscfga__Attributes__r);
                        if (allAttributesRelatedPrdt.containskey(pc.id)) {
                            Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                            mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                            System.debug('PG3'+mapAttrNameRecord);
                        } else {
                            Map < String, String > mapAttrNameRecord = new Map < String, String > ();
                            mapAttrNameRecord.put(attributeRecord.Name, attributeRecord.cscfga__Value__c);
                            allAttributesRelatedPrdt.put(pc.id, mapAttrNameRecord);
                            System.debug('PG4'+mapAttrNameRecord);
                        }
                    }
                } 
            }
            Integer qty = 1;
                System.debug('mapSolutionIdPCList==>'+mapSolutionIdPCList);
            //create row (Map) for conga template
            for (Id solutionId: mapSolutionIdPCList.keySet()) {
                Map < String, Object > newRow = new Map < String, Object > ();
                List < cscfga__Product_Configuration__c > solutuibPCList = mapSolutionIdPCList.get(solutionId);

                for (cscfga__Product_Configuration__c pc: solutuibPCList) {
                    System.debug('pc==>'+pc);
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_OFFER) { //'SDWAN ADAPT S1'
                        newRow.put('Site_Name', pc.Site_Name__c); //Done
                        newRow.put('Site_Address', pc.Site_Address__c); //Done
                        System.debug('Site_Name'+pc.Site_Name__c);
                        System.debug('Site_Address'+pc.Site_Address__c);
                        
                    }
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_ADAPT_OFFER) { //child SDWAN SD-WAN ADAPT S1
                       System.debug('inside child SDWAN==>');
                        Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                        if (mapAttrNameRecord.containsKey('Plan Name') && 
                            mapIdCommercialProduct.containsKey(mapAttrNameRecord.get('Plan Name'))) {
                            System.debug('inside if child SDWAN==>'+  mapIdCommercialProduct.get(mapAttrNameRecord.get('Plan Name')));
                            cspmb__Price_Item__c commercialProductrecord = mapIdCommercialProduct.get(mapAttrNameRecord.get('Plan Name'));
                            newRow.put('Product_Module_Name', commercialProductrecord.Billing_Description__c); //Done
                            newRow.put('Rate', commercialProductrecord.cspmb__Recurring_Charge__c); //Done
                            newRow.put('GSTExcl_Total_Recurring_Charges', pc.cscfga__total_recurring_charge__c); //Done
                            newRow.put('GSTIncl_Total_Recurring_Charges', pc.cscfga__total_recurring_charge__c); //Done
                            System.debug(pc.cscfga__total_recurring_charge__c);    
                           // newRow.put('GSTExcl_Total_Onceoff_Charges', pc.cscfga__total_recurring_charge__c); //Done
                            //newRow.put('GSTIncl_Total_Onceoff_Charges', pc.cscfga__total_recurring_charge__c);
                        }
                        //newRow.put('VolumeTier1', qty); //Done
                        newRow.put('Discount_Text', System.Label.DiscountText_Contract); //Done
                        newRow.put('Quantity', qty); //Done
                        //newRow.put('Type', 'SD-WAN Adapt S1 activation'); 
                        newRow.put('Serviceability_Location', pc.csordtelcoa__Replaced_Subscription__r.customerFacingServiceId__c);
                        System.debug('Serviceability_Location' + pc.csordtelcoa__Replaced_Subscription__r.customerFacingServiceId__c);
                    }
                    if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.ENTERPRISE_WIRELESS && allAttributesRelatedPrdt.containsKey(pc.id)) {
                        Map < String, String > mapAttrNameRecord = allAttributesRelatedPrdt.get(pc.id);
                        // check condition for 'auto data pop up' SDWAN PC attribute and add rows if it has value
                        System.debug('allAttributesRelatedPrdt'+allAttributesRelatedPrdt);
                        System.debug('mapAttrNameRecord'+mapAttrNameRecord);
                        System.debug('idAllounceMap'+idAllounceMap);
                        if (mapAttrNameRecord.containsKey('Auto Data Top Up') && idAllounceMap.containsKey(mapAttrNameRecord.get('Auto Data Top Up'))) {
                            cspmb__Allowance__c allowanceRecord = idAllounceMap.get(mapAttrNameRecord.get('Auto Data Top Up'));
                            if(mapAttrNameRecord.containsKey('LTE Mode') && mapAttrNameRecord.get('LTE Mode')=='Active'){
                                newRow.put('Commercial_Config', allowanceRecord.Description__c); //Done
                                newRow.put('Discount_Template_Name', System.Label.DiscountTemplate_Contract); //Don
                                newRow.put('VolumeTier3', qty); //Done
                            }
                        }
                        // check condition for 'WirelessPlanChargeId' enterprice wireless PC attribute and add rows if it has value 
                        if (mapAttrNameRecord.containsKey('WirelessPlanChargeId') && mapIdCommercialProduct.containsKey(mapAttrNameRecord.get('WirelessPlanChargeId'))) {
                            cspmb__Price_Item__c commerProdRecord = mapIdCommercialProduct.get(mapAttrNameRecord.get('WirelessPlanChargeId'));
                            if(mapAttrNameRecord.containsKey('LTE Mode') && mapAttrNameRecord.get('LTE Mode')=='Active'){
                                newRow.put('Existing_Service', commerProdRecord.Billing_Description__c); //Done
                                newRow.put('Plan_Rate', commerProdRecord.cspmb__Recurring_Charge__c); //Done
                                newRow.put('Bonus_Data', System.Label.BonusData_Contract); //Done
                                newRow.put('VolumeTier2', qty); //Done
                                newRow.put('Total_Recurring_Charges', pc.cscfga__total_recurring_charge__c); //Done
                                newRow.put('TotalAnnualMaintanceCharges', pc.cscfga__total_recurring_charge__c); //Done
                            
                            }
                        }
                    }
                    
                }
                newRow.put('ExternalId', String.valueOf(externalId));
                System.debug('externalId'+externalId);
                externalId++;
                rows.add(newRow);
            }
        } catch (Exception exp) {
            System.debug('***Telstra:ProductBasketDataSourceConnection:getSDWANCancelServices:exception:' + exp.getLineNumber() + ' ' + exp.getMessage());
        }
        System.debug('rows==>'+rows);
        return rows;
    }
    /*
     *@purpose : To create secureEdge row data for conga template
     *@param   : 1)basket Id   2)subfilters (passing as empty)
     *@return  : Rows for conga template (list of map row key and value pair)
     */
    public List < Map < String, Object > > getSDWANServicesSecureEdge(String basketId, Map < String, String > subfilters) {

        List < cscfga__Product_Configuration__c > planPCList;
        List < Map < String, Object >> rows = new List < Map < String, Object >> ();
        Map < String, Object > newRow;
        Integer externalId = 1;
        List < String > offerIDList = new List < String > ();
        offerIDList.add(System.Label.SECUREEDGE_CLOUD);
        offerIDList.add(System.Label.SECUREEDGE_REMOTE);
        offerIDList.add(System.Label.SECUREEDGE_EXTERNALIP);
       
        try {
            // fetch product configuration of secureEdge cloud, SecureEdge cloud remote and External IP Address 
            planPCList = [SELECT
                                    id
                                ,   name
                                ,   OfferName__c
                                ,   cscfga__Contract_Term__c
                                ,   cscfga__Quantity__c
                                ,   cscfga__Parent_Configuration__c
                                ,   cscfga__total_one_off_charge__c
                                ,   cscfga__Recurring_Charge__c
                                ,   cscfga__Product_Definition__r.product_Specification__c
                                ,   Quantity_Product_Configuration__c
                                ,   (   SELECT     Id
                                                ,   Name
                                                ,   cscfga__Product_Configuration__c
                                                ,   cscfga__Display_Value__c
                                                ,   cscfga__Value__c 
                                        FROM    cscfga__Attributes__r
                                        WHERE   Name IN ('Add-On Bandwidth', 'Commercial Product Id')
                                    )
                            FROM cscfga__Product_Configuration__c
                            WHERE cscfga__Product_Definition__r.product_Specification__c
                            IN: offerIDList
                            AND cscfga__Product_Basket__c =: basketId AND Type__c = 'New'
                            AND csordtelcoa__Replaced_Product_Configuration__c = null
            ];

            //get Commercial product Map for SDWAN using offer Id 
            Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = getCommercialProductDetails();

            for (cscfga__Product_Configuration__c pc: planPCList) {
                for (cscfga__Attribute__c att: pc.cscfga__Attributes__r) {
                    if (att.cscfga__Value__c == null) {
                        continue;
                    }
                    //added by lalit check Product defination and related attribute criteria to add data in conga template 
                    if ((att.Name == 'Add-On Bandwidth' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_CLOUD) || //System.Label.SecureEdgeCloud_PDName) || 
                        (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_REMOTE) || //System.Label.SecureEdge_Cloud_Remote_PDName) || 
                        (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_EXTERNALIP)) { //System.Label.External_IP_Address_PDName) ) {
         
                        if (mapIdCommercialProduct.containsKey(att.cscfga__Value__c)) {
                            cspmb__Price_Item__c commercialProd = mapIdCommercialProduct.get(att.cscfga__Value__c);
                            Decimal qty = pc.Quantity_Product_Configuration__c != null ? pc.Quantity_Product_Configuration__c : 1;
                            newRow = new Map < String, Object > ();
                            newRow.put('Product_Module_Name', String.valueOf(commercialProd.Billing_Description__c));
                            newRow.put('Quantity', String.valueOf(qty));
                            newRow.put('GSTExcl_Total_Recurring_Charges', qty * commercialProd.cspmb__Recurring_Charge__c);
                            newRow.put('GSTIncl_Total_Recurring_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(qty * commercialProd.cspmb__Recurring_Charge__c));
                            newRow.put('Rate', commercialProd.cspmb__Recurring_Charge__c);
                            newRow.put('Discount_Text', 'ex GST per month');
                            newRow.put('isSDWAN', True);
                            newRow.put('ExternalId', String.valueOf(externalID));
                            externalID++;
                            rows.add(newRow);
                            break;
                        }
                    }
                }
            }

        } catch (Exception exp) {
            System.debug('***Telstra:ProductBasketDataSourceConnection:getSDWANServicesSecureEdge:exception:' + exp.getLineNumber() + ' ' + exp.getMessage());
        }
        return rows;
    }

    /*
     *@purpose : Create map of commercial product Id and commercial Product Record
     *@param   : -
     *@return  : mapIdCommercialProduct
     */
    public Map < ID, cspmb__Price_Item__c > getCommercialProductDetails() {
        List < String > offerIDList = new List < String > ();     
        offerIDList.add(System.Label.SECUREEDGE_OFFER);
        offerIDList.add(System.Label.SDWAN_OFFER);
        Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = new Map < ID, cspmb__Price_Item__c > ([SELECT Id
                                                                                                            ,   Offer_Id__c
                                                                                                            ,   cspmb__One_Off_Charge__c
                                                                                                            ,   cspmb__Recurring_Charge__c
                                                                                                            ,   Billing_Description__c
                                                                                                        FROM cspmb__Price_Item__c
                                                                                                        WHERE Offer_Id__c IN: offerIDList 
                                                                                                        AND Check_todays_date__c = true
                                                                                                        ]);
        return mapIdCommercialProduct;
    }

    /*
     *@purpose : Create map of allowance record ID and allowance record
     *@param   : - 
     *@return  : mapIdAllowanceRecord
     */
    public Map < ID, cspmb__Allowance__c > getAllowance() {
        List < String > offerIDList = new List < String > ();
        offerIDList.add(System.Label.SDWAN_OFFER);

        Map < ID, cspmb__Allowance__c > mapIdAllowanceRecord = new Map < ID, cspmb__Allowance__c > ([SELECT Id
                                                                                                        ,   Offer_Id__c
                                                                                                        ,   Description__c
                                                                                                        ,   CheckTodaysDate__c
                                                                                                    FROM cspmb__Allowance__c
                                                                                                    WHERE Offer_Id__c IN: offerIDList 
                                                                                                    AND CheckTodaysDate__c = true
                                                                                                    ]);
        return mapIdAllowanceRecord;
    }
    /* ******************************************************************
      	  Added changes for DIGI-13858 and DIGI-13857
         *@purpose : To create SECUREEDGE Modify Services
         *@param   : 1)basket Id   
         *@return  : Rows for conga template (list of map row key and value pair)
      ******************************************************************   */
      public List<Map<String,Object>> getSDWANServicesSecureEdgeModify(String basketId)
      {
          List < cscfga__Product_Configuration__c > planPCList;
      List < Map < String, Object >> rows = new List < Map < String, Object >> ();
      Map < String, Object > newRow;
      Integer externalId = 1;
      List < String > offerIDList = new List < String > ();
      offerIDList.add(System.Label.SECUREEDGE_CLOUD);
      offerIDList.add(System.Label.SECUREEDGE_REMOTE);
      offerIDList.add(System.Label.SECUREEDGE_EXTERNALIP);
          try {
          planPCList = [SELECT
                                  id
                              ,   name
                              ,   OfferName__c
                              ,   cscfga__Contract_Term__c
                              ,   cscfga__Quantity__c
                              ,   cscfga__Parent_Configuration__c
                              ,   cscfga__total_one_off_charge__c
                              ,   cscfga__Recurring_Charge__c
                              ,   cscfga__Product_Definition__r.product_Specification__c
                              ,   Quantity_Product_Configuration__c
                              ,   (   SELECT     Id
                                              ,   Name
                                              ,   cscfga__Product_Configuration__c
                                              ,   cscfga__Display_Value__c
                                              ,   cscfga__Value__c 
                                      FROM    cscfga__Attributes__r
                                      WHERE   Name IN ('Add-On Bandwidth', 'Commercial Product Id', 'AddOnBandWidthShadow')
                                  )
                          FROM cscfga__Product_Configuration__c
                          WHERE cscfga__Product_Definition__r.product_Specification__c
                          IN: offerIDList
                          AND cscfga__Product_Basket__c =: basketId AND Type__c = 'Modify'
                          AND csordtelcoa__Replaced_Product_Configuration__c != null
          ];
              System.debug('SecureEdge_planPCList' + planPCList);
          Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = getCommercialProductDetails();
              
          for (cscfga__Product_Configuration__c pc: planPCList) {
              System.debug('SecureEdge_cscfga__Attributes__r' + pc.cscfga__Attributes__r);
              for (cscfga__Attribute__c att: pc.cscfga__Attributes__r) {
                  if (att.cscfga__Value__c == null) {
                      continue;
                  }
                  if (((att.Name == 'Add-On Bandwidth' || att.Name == 'AddOnBandWidthShadow' ) && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_CLOUD) || //System.Label.SecureEdgeCloud_PDName) || 
                      (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_REMOTE) || //System.Label.SecureEdge_Cloud_Remote_PDName) || 
                      (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_EXTERNALIP)) { //System.Label.External_IP_Address_PDName) ) {
                       System.debug('mapIdCommercialProduct' + mapIdCommercialProduct);
                      if (mapIdCommercialProduct.containsKey(att.cscfga__Value__c)) {
                          cspmb__Price_Item__c commercialProd = mapIdCommercialProduct.get(att.cscfga__Value__c);
                          System.debug('commercialProd' + commercialProd);
                          Decimal qty = pc.Quantity_Product_Configuration__c != null ? pc.Quantity_Product_Configuration__c : 1;
                          newRow = new Map < String, Object > ();
                          //newRow.put('Product_Module_Name', 'Hello World Modify');
                          newRow.put('Product_Module_Name', String.valueOf(commercialProd.Billing_Description__c));
                          newRow.put('Quantity', String.valueOf(qty));
                          newRow.put('GSTExcl_Total_Recurring_Charges', qty * commercialProd.cspmb__Recurring_Charge__c);
                          newRow.put('GSTIncl_Total_Recurring_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(qty * commercialProd.cspmb__Recurring_Charge__c));
                          newRow.put('Rate', commercialProd.cspmb__Recurring_Charge__c);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_CLOUD)
                          newRow.put('Discount_Text', System.Label.Discount_Text_SEC);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_EXTERNALIP)
                          newRow.put('Discount_Text', System.Label.Discount_Text_EIP);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_REMOTE)
                          newRow.put('Discount_Text', System.Label.Discount_Text_SER);
                          newRow.put('isSDWAN', True);
                          newRow.put('ExternalId', String.valueOf(externalID));
                          externalID++;
                          rows.add(newRow);
                          System.debug('newRow' + newRow);
                          break;
                      }
                  }
              }
          }
      }
      catch (Exception exp) {
          System.debug('***Telstra:ProductBasketDataSourceConnection:getSDWANServicesSecureEdge:exception:' + exp.getLineNumber() + ' ' + exp.getMessage());
      }
      return rows;
      }
  /* ******************************************************************
          Added changes for DIGI-13858 and DIGI-13857
       *@purpose : To create SECUREEDGE Cancel Services
       *@param   : 1)basket Id   
       *@return  : Rows for conga template (list of map row key and value pair)
    ******************************************************************   */
      public List<Map<String,Object>> getSDWANServicesSecureEdgeCancel(String basketId)
      {
          List < cscfga__Product_Configuration__c > planPCList;
      List < Map < String, Object >> rows = new List < Map < String, Object >> ();
      Map < String, Object > newRow;
      Integer externalId = 1;
      List < String > offerIDList = new List < String > ();
      offerIDList.add(System.Label.SECUREEDGE_CLOUD);
      offerIDList.add(System.Label.SECUREEDGE_REMOTE);
      offerIDList.add(System.Label.SECUREEDGE_EXTERNALIP);
          try {
          planPCList = [SELECT
                                  id
                              ,   name
                              ,   OfferName__c
                              ,   cscfga__Contract_Term__c
                              ,   cscfga__Quantity__c
                              ,   cscfga__Parent_Configuration__c
                              ,   cscfga__total_one_off_charge__c
                              ,   cscfga__Recurring_Charge__c
                              ,   cscfga__Product_Definition__r.product_Specification__c
                              ,   Quantity_Product_Configuration__c
                              ,   (   SELECT     Id
                                              ,   Name
                                              ,   cscfga__Product_Configuration__c
                                              ,   cscfga__Display_Value__c
                                              ,   cscfga__Value__c 
                                      FROM    cscfga__Attributes__r
                                      WHERE   Name IN ('Add-On Bandwidth', 'Commercial Product Id')
                                  )
                          FROM cscfga__Product_Configuration__c
                          WHERE cscfga__Product_Definition__r.product_Specification__c
                          IN: offerIDList
                          AND cscfga__Product_Basket__c =: basketId AND Type__c = 'Cancel'
                          AND csordtelcoa__Replaced_Product_Configuration__c != null
          ];
              System.debug('SecureEdge_planPCList' + planPCList);
          Map < ID, cspmb__Price_Item__c > mapIdCommercialProduct = getCommercialProductDetails();
              
          for (cscfga__Product_Configuration__c pc: planPCList) {
              System.debug('SecureEdge_cscfga__Attributes__r' + pc.cscfga__Attributes__r);
              for (cscfga__Attribute__c att: pc.cscfga__Attributes__r) {
                  if (att.cscfga__Value__c == null) {
                      continue;
                  }
                  if ((att.Name == 'Add-On Bandwidth' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_CLOUD) || //System.Label.SecureEdgeCloud_PDName) || 
                      (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_REMOTE) || //System.Label.SecureEdge_Cloud_Remote_PDName) || 
                      (att.Name == 'Commercial Product Id' && pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_EXTERNALIP)) { //System.Label.External_IP_Address_PDName) ) {
                       System.debug('mapIdCommercialProduct' + mapIdCommercialProduct);
                      if (mapIdCommercialProduct.containsKey(att.cscfga__Value__c)) {
                          cspmb__Price_Item__c commercialProd = mapIdCommercialProduct.get(att.cscfga__Value__c);
                          System.debug('commercialProd' + commercialProd);
                          Decimal qty = pc.Quantity_Product_Configuration__c != null ? pc.Quantity_Product_Configuration__c : 1;
                          newRow = new Map < String, Object > ();
                          //newRow.put('Product_Module_Name', 'Hello World Modify');
                          newRow.put('Product_Module_Name', String.valueOf(commercialProd.Billing_Description__c));
                          newRow.put('Quantity', String.valueOf(qty));
                          newRow.put('GSTExcl_Total_Recurring_Charges', qty * pc.cscfga__Recurring_Charge__c);
                          newRow.put('GSTIncl_Total_Recurring_Charges', ProductBasketDataHandler.calculateGSTIncludedPrice(qty * pc.cscfga__Recurring_Charge__c));
                          newRow.put('Rate', commercialProd.cspmb__Recurring_Charge__c);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_CLOUD)
                          newRow.put('Discount_Text', System.Label.Discount_Text_SEC);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_EXTERNALIP)
                          newRow.put('Discount_Text', System.Label.Discount_Text_EIP);
                          if (pc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SECUREEDGE_REMOTE)
                          newRow.put('Discount_Text', System.Label.Discount_Text_SER);
                          newRow.put('isSDWAN', True);
                          newRow.put('ExternalId', String.valueOf(externalID));
                          externalID++;
                          rows.add(newRow);
                          System.debug('newRow' + newRow);
                          break;
                      }
                  }
              }
          }
      }
      catch (Exception exp) {
          System.debug('***Telstra:ProductBasketDataSourceConnection:getSDWANServicesSecureEdge:exception:' + exp.getLineNumber() + ' ' + exp.getMessage());
      }
      return rows;
      }
}
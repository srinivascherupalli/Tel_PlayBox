/*  
* @Author : Aniket    
* @Date : 30th march 2021
* @Desc : To display NGUC details to Q & C  
* @Jira : EDGE-210438, EDGE-207338,EDGE-210440 and EDGE-210441
*/  
global with sharing class TCDataHandler { 
    public static List<String> ngUCAcceUCDSpecCode;
    public TCDataHandler(){
        AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
        ngUCAcceUCDSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('NGUCAcceUCD'));
    }
    /**
     * @Desc: Common method to get the rows for New / Modify and Cancel tables for Telstra Collaboration
     */
    public List<Map<String,Object> > getTCServices(String basketId, Map<String,String> subfilters){ 
        List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Integer externalId=1;
        String sUserMode;
        try{
            if(subfilters.get('Type') == 'New'){
                planTCPCList = [ SELECT id, name,(SELECT Id, Name,cscfga__Value__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM  cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :DataHandlerConstants.BUSINESS_CALLING_SPECID AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];
            } else {
                planTCPCList =[SELECT id,name,csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c,(SELECT Id, Name,cscfga__Value__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :DataHandlerConstants.BUSINESS_CALLING_SPECID AND cscfga__Product_Basket__c =:basketId AND Type__c=:subfilters.get('Type') AND csordtelcoa__Replaced_Product_Configuration__c!=null];
            } 
            system.debug('planTCPCList@@::' + planTCPCList);
            if(planTCPCList.size()>0){
                Map<id,cspmb__Price_Item__c> priceItemsRecords = null;
                //Below function call to to fetch map of pc vs priceitem record
                priceItemsRecords = getPriceItemRecordMap(planTCPCList, null);
                Map<String,Object> newRow;
                System.debug('***Telstra:ProductBasketDataHandler:getngUCDevicesOC:priceItemsRecords: '+priceItemsRecords);
                for(cscfga__Product_Configuration__c pc:planTCPCList) {
                    newRow = new Map<String,Object>();
                    newRow.put('ExternalId', externalID++);
                    system.debug('pc.Name::' + pc.Name);
                    cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(pc.id);
                    system.debug('priceItemsRecords::' + priceItemsRecords);
                    sUserMode = '<b>Adaptive Collaboration Calling Plan:</b> '+ priceItemRecord.Mode__c + ' - ' + priceItemRecord.Plan__c;
                    newRow.put('UserMode',sUserMode);
                    if((subfilters.get('Type') == 'Modify' || subfilters.get('Type') == 'Cancel') && pc.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c!=null){
                        newRow.put('Offer_Name',pc.csordtelcoa__Replaced_Subscription__r.csordtelcoa__Subscription_Number__c);
                    }
                    system.debug('newRow' + newRow);
                    rows.add(newRow);
                }
            }
        }
        catch(Exception e) {
            System.debug('***Telstra:tcDataHandler:getngUCCancel:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:tcDataHandler:getTCServices found:'+rows);
        return rows;																							
}
   
    public List<Map<String,Object> > getngUCDevicesOC(String basketId, Map<String,String> subfilters){
        List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        Integer externalId=1;
        String UOM;
        system.debug('ngUCAcceUCDSpecCode::' + ngUCAcceUCDSpecCode);
        Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>();
        try{
            map_DeviceWithRedeemAmount = getDevicesWithOneFund(basketId);  
            system.debug('basketid: ' + basketId);
			if(subfilters.get('Type') =='New' ) {
                planTCPCList =[SELECT id,name,cscfga__Product_Definition__r.product_Specification__c, (SELECT Id, Name, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:ngUCAcceUCDSpecCode AND cscfga__Product_Basket__c = :basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and cscfga__total_recurring_charge__c = 0];
            }
            system.debug('planTCPCList' + planTCPCList);
			if(planTCPCList.size()>0){
				for(cscfga__Product_Configuration__c pc:planTCPCList) {
					for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
						System.debug('attribute:'+attribute.name);
						if(attribute.name == 'ContractType') {
							map_PlanVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
							break;
							
						}
					}
				}
				System.debug('***Telstra:tcDataHandler:getngUCDevicesOC:map_PlanVsPriceItem: '+map_PlanVsPriceItem);
				List<String> attrIdList = map_PlanVsPriceItem.values();
				String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL(DataHandlerConstants.PRICE_ITEM_APINAME)) + ' ' +
					' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
				Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
				System.debug('***Telstra:tcDataHandler:getngUCDevicesOC:priceItemsRecords: '+priceItemsRecords);
			    for(cscfga__Product_Configuration__c pc:planTCPCList) {
					Map<String,Object> newRow = new Map<String,Object>();
					String productModuleName = getOneFundProdName(map_DeviceWithRedeemAmount,pc);
					newRow.put('Product_Module_Name',productModuleName);
					newRow.put('ExternalId', externalID++);
					for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
						System.debug('attribute:'+attribute.name);
						String mappingfield ='';
						if(!ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {
							mappingfield = (attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
							system.debug('mappingfield' + mappingfield);
							newRow.put(mappingfield,attribute.cscfga__Value__c);
							if(mappingfield.contains('GSTExcl_Total_Onceoff_Charges')) {
								Decimal strToDec = decimal.valueOf(attribute.cscfga__Value__c);
								system.debug('Inside GST' + attribute.cscfga__Value__c);
								newRow.put('GSTIncl_Total_Onceoff_Charges',ProductBasketDataHandler.calculateGSTIncludedPrice(strToDec));
								
							}
						}
					}
					cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pc.name));
					system.debug('pc.cscfga__Product_Definition__r.product_Specification__c::' + pc.cscfga__Product_Definition__r.product_Specification__c + DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID + DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID);
					
					if(pc.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID)
						UOM = priceItemRecord.Unit_Of_Measure__c;
					else if(pc.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID)
						UOM = 'per accessory';
					newRow.put('Unit_Of_Measure',UOM);
					newRow.put('Rate',priceItemRecord.cspmb__One_Off_Charge__c);
					system.debug('newRow' + newRow);
					rows.add(newRow);
				}
			}
		}
        catch(Exception e)
        {
            System.debug('***Telstra:tcDataHandler:getngUCDevicesOC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:tcDataHandler:getngUCDevicesOC:found:'+rows);
        return rows;
    }
    
     public List<Map<String,Object> > getngUCDevicesRCRepayment(String basketId, Map<String,String> subfilters){
        List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        Integer externalId=1;
        String prodtype = 'Device';

        Double sContractTerm; 

        String UOM;
        try{
            system.debug('basketid: ' + basketId);
            if(subfilters.get('Type') =='New' ) {

                planTCPCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__One_Off_Charge__c,cscfga__Recurring_Charge__c,cscfga__Product_Definition__r.product_Specification__c,Quantity_Product_Configuration__c,(SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:ngUCAcceUCDSpecCode AND cscfga__Product_Basket__c = :basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and cscfga__total_recurring_charge__c <> 0 AND Id IN (select cscfga__Product_Configuration__c FROM cscfga__Attribute__c WHERE cscfga__Display_Value__c = 'Hardware Repayment')];

            }
            system.debug('planTCPCList' + planTCPCList);
			if(planTCPCList.size()>0){
				for(cscfga__Product_Configuration__c pc:planTCPCList) {
					for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
						System.debug('attribute:'+attribute.name);
						if(attribute.name == 'ContractType') {
							map_PlanVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
							break;
							
						}
					}
				}
				System.debug('***Telstra:tcDataHandler:getngUCDevicesRCRepayment:map_PlanVsPriceItem: '+map_PlanVsPriceItem);
				List<String> attrIdList = map_PlanVsPriceItem.values();
				String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL(DataHandlerConstants.PRICE_ITEM_APINAME)) + ' ' +
					' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
				Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
				System.debug('***Telstra:tcDataHandler:getngUCDevicesRCRepayment:priceItemsRecords: '+priceItemsRecords);
				for(cscfga__Product_Configuration__c pc:planTCPCList) {
					Map<String,Object> newRow = new Map<String,Object>();

                    
                    sContractTerm = pc.cscfga__Contract_Term__c;

					newRow.put('Product_Module_Name',pc.Name);
					newRow.put('ExternalId', externalID++);
					for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
						System.debug('attribute:'+attribute.name);
						if(system.label.pricingLogicSwitch == 'True'){
							if(attribute.name.equals(DataHandlerConstants.rcAttr)){
								Decimal rcCharge = ProductPricingHandler.getPricingDetails(prodtype,pc,attribute,DataHandlerConstants.rcAttr);
								String rate = String.valueof(rcCharge);
								newRow.put(DataHandlerConstants.totalRCExGST,pc.Quantity_Product_Configuration__c*rcCharge);
								Decimal totalRecurring = (pc.Quantity_Product_Configuration__c*rcCharge);
								Decimal totalRecurringGSTIncl = ProductBasketDataHandler.calculateGSTIncludedPrice(totalRecurring);
								newRow.put(DataHandlerConstants.totalRCIncGST,totalRecurringGSTIncl);
								
								
							}
						}
						else{
							if(attribute.name.equals(DataHandlerConstants.totalRC)){

                                Decimal strToDec = decimal.valueOf(attribute.cscfga__Value__c)/sContractTerm;//EDGE-210438-Recurring Charge Fix. Divide by term
                                newRow.put(DataHandlerConstants.totalRCExGST,strToDec);

								system.debug('Inside GST' + attribute.cscfga__Value__c);
								newRow.put(DataHandlerConstants.totalRCIncGST,ProductBasketDataHandler.calculateGSTIncludedPrice(strToDec));
								
							}
							
						}
						
					}
					cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pc.name));
					system.debug('1234' + priceItemRecord.Unit_Of_Measure__c);
					if(pc.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID)
						UOM = priceItemRecord.Unit_Of_Measure__c;
					else if(pc.cscfga__Product_Definition__r.product_Specification__c == DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID)
						UOM = 'per accessory';
					newRow.put('Unit_Of_Measure',UOM);
					newRow.put('Rate',priceItemRecord.cspmb__Recurring_Charge__c);
					newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
					newRow.put('Quantity',pc.Quantity_Product_Configuration__c);
					system.debug('newRow' + pc.Quantity_Product_Configuration__c);
					rows.add(newRow);
				}
			}	
        }
        catch(Exception e)
        {
            System.debug('***Telstra:tcDataHandler:getngUCDevicesOC:getngUCDevicesRCRepayment:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:tcDataHandler:getngUCDevicesRCRepayment:TC Services found:'+rows);
        return rows;
    }

    	//Below method is to get cancellation details of ngUC devices/accessories to present in quote/contract.
    	public List<Map<String,Object> > getngUCCancel(String basketId, Map<String,String> subfilters){
		List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
		List<Map<String,Object> > rows = new List<Map<String,Object> >();
		Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
		Integer externalId=1;
		String objectAPIName=''; Id temp;
		String billAcc='';
		Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>();
		BillingAccountDetailsDTO billAccDTO = null;
		try{
			system.debug('basketid: ' + basketId);
			map_DeviceWithRedeemAmount = getDevicesWithOneFund(basketId);
			if(subfilters.get('Type') =='Cancel' ) {
			planTCPCList =[SELECT id,name,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c,
						   (SELECT Id, Name, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c  FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) 
						   FROM cscfga__Product_Configuration__c 
						   where (cscfga__Product_Definition__r.product_Specification__c =:DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID OR cscfga__Product_Definition__r.product_Specification__c = :DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID) 
								  AND cscfga__Product_Basket__c = :basketId AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null];
			}
			system.debug('planTCPCList' + planTCPCList);
			if(planTCPCList.size()>0){
			for(cscfga__Product_Configuration__c pc:planTCPCList) {
				billAcc = pc.csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c;
				for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
					System.debug('attribute:'+attribute.name);
					if(attribute.name == 'ContractType') {
						map_PlanVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
					}
					if(attribute.name == 'CallingPlans'){
						map_PlanVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
					}
				}
			}
			billAccDTO = BillingOrderService.requestBillingAccountDetails(billAcc);
			system.debug('billAccDTO@@::' +billAccDTO + map_PlanVsPriceItem);
			List<String> attrIdList = map_PlanVsPriceItem.values();
			String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL(DataHandlerConstants.PRICE_ITEM_APINAME)) + ' ' +
				' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
			Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
			System.debug('***Telstra:tcDataHandler:getngUCCancel:priceItemsRecords: '+priceItemsRecords);
			
			for(cscfga__Product_Configuration__c pc:planTCPCList) {
				String productModuleName = pc.Name + ' repayment';
				if(map_DeviceWithRedeemAmount != null && map_DeviceWithRedeemAmount.containsKey(pc.Id)){
					String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
					if(redeemAmt != '0.00'){
						productModuleName = productModuleName+' <sup>#</sup>';//EDGE-225347
					}
				}
				Integer remainingTerm = 0;
				Date disconnectionDate;
				Map<String,Object> newRow = new Map<String,Object>();
				system.debug('pc.Name@@@::' + pc.Name);
				newRow.put('Product_Module_Name',productModuleName);
				newRow.put('ExternalId', externalID++);
				for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
					System.debug('attributePC:'+attribute.name);
					String mappingfield ='';
					if(!ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {
						mappingfield = (attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
						system.debug('mappingfield' + mappingfield);
						newRow.put(mappingfield,attribute.cscfga__Value__c);
						if(mappingfield.contains('GSTExcl_TotalETC') && attribute.cscfga__Value__c!=null) {
							Decimal strToDec = decimal.valueOf(attribute.cscfga__Value__c);
							system.debug('Inside GST' + attribute.cscfga__Value__c);
							newRow.put('GSTIncl_TotalETC',ProductBasketDataHandler.calculateGSTIncludedPrice(strToDec));
							system.debug('attribute.cscfga__Value__c' + ProductBasketDataHandler.calculateGSTIncludedPrice(strToDec));
						}
					}
					if(attribute.name == 'DisconnectionDate' && attribute.cscfga__Value__c!=null)
					disconnectionDate =  Date.valueOf(attribute.cscfga__Value__c);   
				}
				cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pc.name));
				system.debug('priceItemRecord.Unit_Of_Measure__c::'+priceItemRecord.Unit_Of_Measure__c + priceItemRecord.cspmb__Contract_Term__c + pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c + pc.csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c + pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c+disconnectionDate+billAccDTO);
				             
				if(priceItemRecord.cspmb__Contract_Term__c != '' && priceItemRecord.cspmb__Contract_Term__c != null){
				remainingTerm = calculateRemainingTermngUC(pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,disconnectionDate,Integer.valueOf(priceItemRecord.cspmb__Contract_Term__c),billAccDTO);
				}
				else{
				remainingTerm = calculateRemainingTermngUC(pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,disconnectionDate,24,billAccDTO);
				}
				system.debug('remainingTerm@@::' + remainingTerm+priceItemRecord.Contract_Type__c);
				newRow.put('Discount_Text',remainingTerm+ ' monthly repayments remaining');
				system.debug('newRow' + newRow);
				rows.add(newRow);
			}
	   
			system.debug('rows@@::' + rows);
		}
	}
		catch(Exception e)
		{
		System.debug('***Telstra:tcDataHandler:getngUCCancel:exception:'+e.getLineNumber()+' '+e.getMessage());
		}
		System.debug('***Telstra:tcDataHandler:getngUCCancel::'+rows);
		return rows;
	}
    
     //EDGE-117631 : Below method is to get details of ngUC Prof Services details for quote/contract
    public List<Map<String,Object>> getTelstraCollaborationPS(String basketId, Map<String,String> subfilters){
            system.debug('basketId'+basketId);
            List<Map<String,Object>> rows = new List<Map<String,Object>>();
            Integer externalId=1;
            String OfferId=subfilters.get('Offer_Name'); //DMCAT_ProductSpecification_000935
            map<Id, List<String>> mpPCAttr = new map<Id, List<String>>();
            map<Id, String> mpPCType = new map<Id, String>();
            map<Id, String> mpPCSupp = new map<Id, String>();
            map<String, String> mpPISupp = new map<String, String>();
            Map<String,Object> newRow;
            List<String> lsStr;
            String delimiter = ',';
            String featureType;
            String featureSuppType;
            Map<String,String> mpFeatureSuppType = new Map<String,String>{'24x7'=>'24x7','Bus Hrs'=>'Business Hours'};
            Map<String,String> mpFeatureType = new Map<String,String>{'Config'=>'Configuration',
                    'Design'=>'Design',
                    'Site Visit'=>'Site Visit',
                    'Training'=>'Training',     
                    'Project Management'=>'Project Management',
                    'Install'=> 'Installation'};         
            try{
                system.debug('offer id---->'+OfferId);
                for(cscfga__Attribute__c attr:[Select Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,  cscfga__Attribute_Definition__r.cscfga__Type__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__c=:basketId and cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c=:OfferId]){
                    if(attr.cscfga__Value__c != null){
                        lsStr = null;
                        if(attr.Name=='OC'){
                            if(mpPCAttr != null && mpPCAttr.containsKey(attr.cscfga__Product_Configuration__c)){
                                lsStr = mpPCAttr.get(attr.cscfga__Product_Configuration__c);
                                lsStr.add('Rate,'+attr.cscfga__Value__c);
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c,lsStr);
                                }
                            else
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c, new List<String>{'Rate,'+attr.cscfga__Value__c});
                        }
                        else if(attr.Name=='Quantity'){
                            if(mpPCAttr != null && mpPCAttr.containsKey(attr.cscfga__Product_Configuration__c)){
                                lsStr = mpPCAttr.get(attr.cscfga__Product_Configuration__c);
                                lsStr.add('Unit_Of_Measure,'+attr.cscfga__Value__c);
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c,lsStr);
                                }
                            else
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c, new List<String>{'Unit_Of_Measure,'+attr.cscfga__Value__c});
                        }
                        else if(attr.Name=='TC'){
                            if(mpPCAttr != null && mpPCAttr.containsKey(attr.cscfga__Product_Configuration__c)){
                                lsStr = mpPCAttr.get(attr.cscfga__Product_Configuration__c);
                                lsStr.add('GSTExcl_Total_Onceoff_Charges,'+attr.cscfga__Value__c);
                                lsStr.add('GSTIncl_Total_Onceoff_Charges,'+String.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(Decimal.valueOf(attr.cscfga__Value__c))));
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c,lsStr);
                                }
                            else{
                                lsStr = new List<String>();
                                lsStr.add('GSTExcl_Total_Onceoff_Charges,'+attr.cscfga__Value__c);
                                lsStr.add('GSTIncl_Total_Onceoff_Charges,'+String.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(Decimal.valueOf(attr.cscfga__Value__c))));                            
                                mpPCAttr.put(attr.cscfga__Product_Configuration__c,lsStr);
                                }
                        }
                        else if(attr.Name=='Type'){
                            mpPCType.put(attr.cscfga__Product_Configuration__c, attr.cscfga__Value__c);
                        }
                        else if(attr.Name=='OperationalHours'){
                            mpPCSupp.put(attr.cscfga__Product_Configuration__c, attr.cscfga__Value__c);
                        }
                    }                   
                }
                if(mpPCSupp.size() > 0){
                    for(cspmb__Price_Item__c prItm:[SELECT Id, Technical_Support__c FROM cspmb__Price_Item__c WHERE Id IN :mpPCSupp.Values()]){
                        mpPISupp.put(prItm.Id, prItm.Technical_Support__c);
                    }
                    for(Id pc:mpPCSupp.keySet()){
                        newRow = new Map<String,Object>();
                        newRow.put('ExternalId', externalID++);
                        
                        featureType = mpFeatureType.containsKey(mpPCType.get(pc))?mpFeatureType.get(mpPCType.get(pc)):mpPCType.get(pc);
                        featureSuppType = mpFeatureSuppType.containsKey(mpPISupp.get(mpPCSupp.get(pc)))?mpFeatureSuppType.get(mpPISupp.get(mpPCSupp.get(pc))):mpPISupp.get(mpPCSupp.get(pc));
                        newRow.put('Techinical_Support', 'Professional Service '+featureType+' - '+featureSuppType);
                        for(String str :mpPCAttr.get(pc)){
                            newRow.put(str.substringBefore(delimiter),str.substringAfter(delimiter));
                        }
                        
                        rows.add(newRow);
                    }
                }
            }
            catch(Exception e){
                System.debug('***Telstra:tcDataHandler:getTelstraCollaborationPS:exception:'+e.getLineNumber()+' '+e.getMessage());
            }
            System.debug('***Telstra:tcDataHandler:getTelstraCollaborationPS: Services found:'+rows);
            return rows;
    } // End EDGE-117631  
    
    //Below method is fetch remaining term for ngUC devices/accessories cancellation
    public static Integer calculateRemainingTermngUC(Date initialActivationDate,Date disconnectionDate,Integer contractTerm,BillingAccountDetailsDTO billAccDTO){
        Integer remainingTerm;
        Date firstBillDate,lastBillDate;
        System.debug('***Telstra:calculateRemainingTermngUC:initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm);
        try{ 
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:billAccDTO:'+billAccDTO);
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
                String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                System.debug('***Telstra:firstBillDate:'+firstBillDate);
                //Date on which latest bill was generated
                lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
                if(disconnectionDate < lastBillDate)
                lastBillDate = lastBillDate.addMonths(-1);            
                System.debug('***Telstra:calculateRemainingTermngUC:lastBillDate:'+lastBillDate);
                
                Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth
                
                if(TermPassed<0)
                    TermPassed = 0;
                remainingTerm = contractTerm - TermPassed;
                }
				System.debug('remainingTerm-->'+remainingTerm);
                return remainingTerm;
        }
            catch(Exception e){
            System.debug('***Telstra:calculateRemainingTermngUC:BillingAccount-Response:'+billAccDTO);
            return remainingTerm;
            }
        }
    
    //Below method returns map of pc.id and corresponding one fund redemption against the PC
    public Map<String,String> getDevicesWithOneFund(String basketId){
        Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>();
        try{
            if(basketId.length()>0){
                for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id=:basketId and (name ='RedeemFund')]){
                    System.debug('cscfga__Product_Configuration__c.ID ----->>>>>:'+attr.cscfga__Product_Configuration__c);
                    if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){
                        map_DeviceWithRedeemAmount.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c); 
                    }                                      
                }                                        
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:TCDataHandler:getDevicesWithOneFund:map_DeviceWithRedeemAmount:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        system.debug('map_DeviceWithRedeemAmount::' + map_DeviceWithRedeemAmount);
        return map_DeviceWithRedeemAmount;
    }
    
    
    //Below method returns the final name of plan/device/accessories with the character appended at the end based on whether one fund is opted for
    public String getOneFundProdName(Map<String,String> map_DeviceWithRedeemAmount,cscfga__Product_Configuration__c pc){
        String productModuleName = pc.Name;
        try{
                          
            if(map_DeviceWithRedeemAmount != null && map_DeviceWithRedeemAmount.containsKey(pc.Id)){
                String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                if(redeemAmt != '0.00'){
                    productModuleName = productModuleName+' <sup>#</sup>';//EDGE-225347
                }
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:TCDataHandler:getOneFundProdName:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        system.debug('productModuleName::' + productModuleName);
        return productModuleName;
    }

    /** 
     * @Desc: This utility method takes the List of PCs and returns a Map of PC Id and Price Item record contained in the PC Attribute
     */
    
    public static Map<id,cspmb__Price_Item__c> getPriceItemRecordMap (List<cscfga__Product_Configuration__c> PCList, String inputAttribute) {
        Map<id,cspmb__Price_Item__c> priceItemMap = null;
        Map<String, String> map_PlanVsPriceItem = null;
        Id temp; String objectAPIName='';
        if (PCList != null && !PCList.isEmpty()) {
            priceItemMap = new Map<id,cspmb__Price_Item__c>();
            map_PlanVsPriceItem = new Map<String, String>();
            for(cscfga__Product_Configuration__c pc:PCList) {                    
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                    System.debug('@@@ TCDataHandler :: getPriceItemRecordMap -> attribute:'+attribute.name);
                    if (inputAttribute != null && !inputAttribute.equals('') && inputAttribute.trim().equals(attribute.name)) {
                        map_PlanVsPriceItem.put(pc.Id, attribute.cscfga__Value__c);
                        break;
                    }
                    if(ProductBasketDataHandler.isValidId(attribute.cscfga__Value__c)==True) {
                        temp = attribute.cscfga__Value__c;
                        objectAPIName = temp.getSObjectType().getDescribe().getName();
                        if(objectAPIName.equalsIgnoreCase(DataHandlerConstants.PRICE_ITEM_APINAME)) {
                            System.debug('@@@ TCDataHandler :: getPriceItemRecordMap -> id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);
                            map_PlanVsPriceItem.put(pc.Id,attribute.cscfga__Value__c);
                            break;
                        }
                    }
                }
            }

            System.debug('@@@ TCDataHandler :: getPriceItemRecordMap -> map_PlanVsPriceItem: '+map_PlanVsPriceItem);
            List<String> attrIdList = map_PlanVsPriceItem.values();

            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL(DataHandlerConstants.PRICE_ITEM_APINAME)) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';

            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>) Database.query(query));
            
            for(cscfga__Product_Configuration__c pc:PCList) { 
                cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pc.id));
                priceItemMap.put(pc.id, PriceItemRecord);
            }
            System.debug('@@@ TCDataHandler :: getPriceItemRecordMap -> priceItemMap: '+priceItemMap);
        }
        return priceItemMap;
    }
}
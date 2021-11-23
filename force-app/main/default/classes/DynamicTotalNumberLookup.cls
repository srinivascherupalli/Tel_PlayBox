global with sharing class DynamicTotalNumberLookup extends cscfga.ALookupSearch  {

	global override Object[] doDynamicLookupSearch(Map<String, String> searchFields,  String productDefinitionID){          

		//String testingID = '0012O000002n998QAA';
		FINAL String ipSitePDSpec = 'DMCAT_ProductSpecification_000049';
		FINAL String ucePDSpec = 'DMCAT_ProductSpecification_000087';
		System.debug('searchFields ::'+searchFields);
		Id basktId = searchFields.get('BasketId');
		Id accountId = searchFields.get('AccountId');
		String configId = searchFields.get('UCEConfigId');
		Integer numberQty = 0;
		//System.debug('UCEConfigId::'+configId);
		if(configId != null && configId != ''){
			//Query PCs in the basket
			/*List<cscfga__Product_Configuration__c> bsktConfigs = [SELECT Id, Name, cscfga__Product_Basket__r.csbb__Account__c, cscfga__product_definition__r.product_Specification__c, cscfga__Product_Basket__c, Quantity_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__c 
																  FROM cscfga__Product_Configuration__c
																  WHERE (cscfga__product_definition__r.product_Specification__c = :ipSitePDSpec
																  OR cscfga__product_definition__r.product_Specification__c = :ucePDSpec)
																  AND cscfga__Product_Basket__c = :basktId];
																  //AND Quantity_Product_Configuration__c != null];
			*/
			//Query numbers attachment for IP Sites it is replicator attachment, for UCE NCE attachment
			//for IP Site PCR query for replicator dto-ReplicatorGetServiceDataObject_V2 att-TransitionJSONData.json
			/*List<Attachment> legacyServices = [SELECT Id, Name, Body, BodyLength
												FROM Attachment
												WHERE ParentId IN (SELECT Id FROM csbb__Product_Configuration_Request__c
														WHERE csbb__Product_Configuration__r.cscfga__product_definition__r.product_Specification__c = :ipSitePDSpec
														AND csbb__Product_Configuration__r.cscfga__Product_Basket__c = :basktId
													)
												AND Name = 'TransitionJSONData.json'
												];*/
			//for UCE PC query for uce numbers dto-? att-NumberManagement
			/*List<cscfga__Product_Configuration__c> uceNumbers = [SELECT Id FROM cscfga__Product_Configuration__c
											WHERE cscfga__product_definition__r.product_Specification__c = :ucePDSpec
											AND cscfga__Product_Basket__c = :basktId
											];*/
			//attachment names are different, based on attachment name decompose them to read numbers
			//Legacy Numbers

			System.debug('Querying...');
			//UCE Numbers
			Map<String, List<String>> uceNumbers = new Map<String, List<String>>();
			NumberNCSHelper ncs = new NumberNCSHelper();
			uceNumbers = ncs.getNumbersFromNCS(configId);
			System.debug('uceNumbers::'+uceNumbers);
			List<String> numberList = new List<String>();
			for(List<String> a: uceNumbers.values()){
				numberList.addAll(a);
			}

			System.debug('numberList::'+numberList);
			
			//read numbers single and ranges, if single count + 1, if ranges count + difference in ranges

			Integer tempCount = 0;
			for(String str: numberList){
				List<String> splitNumbers = str.split(' : ');
				if(splitNumbers.size() > 1){
						tempCount += Integer.valueOf(splitNumbers[1]) - Integer.valueOf(splitNumbers[0]) + 1;
					} else {
						tempCount += 1;
					}
			}
			System.debug('tempCount::'+tempCount);

			//create return cscfga__Product_Configuration__c Quantity_Product_Configuration__c
			cscfga__Product_Configuration__c retRec = new cscfga__Product_Configuration__c();
			retRec.Quantity_Product_Configuration__c = tempCount;

			return new List<cscfga__Product_Configuration__c>{retRec} ;
		} else {
			return null;
		}

	}
	
	global override String getRequiredAttributes(){         
		return '[ "AccountId", "BasketId", "UCEConfigId"]';      
	}
}
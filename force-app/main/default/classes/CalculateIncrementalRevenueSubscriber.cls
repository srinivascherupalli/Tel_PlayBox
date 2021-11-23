/*********************************************************************************************************************************
 *Class Name      :   CalculateIncrementalRevenueSubscriber
 *Story             :   EDGE-89844  Unable to place Mobility Cancel order in QA2 environment
 *Developer         :   Rohit Tripathi
Test Class : CalculateIncrementalRevenueSubscriberTest
===============================================================================================================================
Sr.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi 		6/7/2019     	 Unable to place Mobility Cancel order in QA2 environment (EDGE-89844)

 *********************************************************************************************************************************
*/


global with sharing class CalculateIncrementalRevenueSubscriber extends csutil.ASubscriber {

	public override void onMessage(String topic, String subject, Map<String, Object> payload)
	{
		
		System.debug('CalculateIncrementalRevenueSubscriber: Topic: ' + topic + '; Subject: ' + subject + '; Payload: ' + Json.serialize(payload) );

		List<cscfga__Product_Configuration__c> payloadList = new List<cscfga__Product_Configuration__c>();
		List<Id> prodConfIdList = new List<Id>();
		cscfga__Product_Configuration__c rootConfig = new cscfga__Product_Configuration__c();
        
		for (String tempKey : payload.keySet()) 
		{
			if(tempKey == 'AllConfigs' )
			{
				payloadList = (List<cscfga__Product_Configuration__c>)JSON.deserialize(JSON.serialize(payload.get(tempKey)), List<cscfga__Product_Configuration__c>.class);
				System.debug('CalculateIncrementalRevenueSubscriber payloadList: ' + payloadList);
			}
			if(tempKey=='RootConfig')
			{
				rootConfig = (cscfga__Product_Configuration__c) JSON.deserialize(JSON.serialize(payload.get(tempKey)), cscfga__Product_Configuration__c.class);
			}
		}
		System.debug('CalculateIncrementalRevenueSubscriber payloadList: ' + payloadList);
		if (!payloadList.isEmpty())
		{
			for (cscfga__Product_Configuration__c pc : payloadList)
			{
				prodConfIdList.add(pc.Id);
			}
		}
		if (!prodConfIdList.isEmpty())
		{
			calculationFilter(prodConfIdList, rootConfig);
			System.debug('CalculateIncrementalRevenueSubscriber prodConfIdList: ' + prodConfIdList);
		}
        
	}

    public void calculationFilter(List<Id> confIdList,cscfga__Product_Configuration__c rootConfig)
    {
        Map<cscfga__Product_Configuration__c,Id> OppIdMACProdConfMap = new Map<cscfga__Product_Configuration__c,Id>();
        List<cscfga__Product_Configuration__c> prodConfList = [SELECT Id, Name, cscfga__total_one_off_charge__c, cscfga__total_recurring_charge__c, cscfga__Product_Basket__c, cscfga__Product_Basket__r.cscfga__Opportunity__c, 
		                                                              csordtelcoa__Replaced_Product_Configuration__c, csordtelcoa__Replaced_Product_Configuration__r.cscfga__total_one_off_charge__c, 
																	  csordtelcoa__Replaced_Product_Configuration__r.cscfga__total_recurring_charge__c, cscfga__Contract_Term__c, cscfga__Root_Configuration__c,
																	  csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__r.cscfga__Opportunity__c
                                                               FROM cscfga__Product_Configuration__c
                                                               WHERE Id in:confIdList];
		List<Id> replacedConfigList = new List<Id>();
		Map<cscfga__Product_Configuration__c, Map<cscfga__Product_Configuration__c,Id>> relevantInfoMap = new Map<cscfga__Product_Configuration__c, Map<cscfga__Product_Configuration__c,Id>>();
		
		for (cscfga__Product_Configuration__c config: prodConfList)
        {
			if(!(config.csordtelcoa__Replaced_Product_Configuration__c==null))
			{
				replacedConfigList.add(config.csordtelcoa__Replaced_Product_Configuration__c);
			}
		}

		List<cscfga__Product_Configuration__c> replacedProdConfList = [SELECT Id, cscfga__total_one_off_charge__c, cscfga__total_recurring_charge__c, cscfga__Product_Basket__c, cscfga__Product_Basket__r.cscfga__Opportunity__c
		                                                               FROM cscfga__Product_Configuration__c
																	   WHERE Id IN:replacedConfigList];

        List<Id> basketIdList = new List<Id>();

		for (cscfga__Product_Configuration__c replacedConfig : replacedProdConfList)
		{
			basketIdList.add(replacedConfig.cscfga__Product_Basket__c);
		}

		List<cscfga__Product_Basket__c> basketList = [SELECT Id, cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE Id in: basketIdList];

		System.debug('CalculateIncrementalRevenueSubscriber query prodConfList ' + prodConfList);
		System.debug('CalculateIncrementalRevenueSubscriber query replacedProdConfList ' + replacedProdConfList);
		System.debug('CalculateIncrementalRevenueSubscriber query basketList ' + basketList);

        for (cscfga__Product_Configuration__c config: prodConfList)
        {
			for (cscfga__Product_Configuration__c replacedConfig : replacedProdConfList)
			{
				for(cscfga__Product_Basket__c basketForReplacedConfig : basketList)
				{
					if((replacedConfig.cscfga__Product_Basket__c == basketForReplacedConfig.Id)&&(config.csordtelcoa__Replaced_Product_Configuration__c == replacedConfig.Id))
					{
						Map<cscfga__Product_Configuration__c,Id> partOfRelevanInfoMap = new Map<cscfga__Product_Configuration__c,Id>();
						partOfRelevanInfoMap.put(replacedConfig,basketForReplacedConfig.cscfga__Opportunity__c);
						OppIdMACProdConfMap.put(config,basketForReplacedConfig.cscfga__Opportunity__c);
						relevantInfoMap.put(config, partOfRelevanInfoMap);
					}
				}
			}
        }
		System.debug('CalculateIncrementalRevenueSubscriber OppIdMACProdConfMap: ' + OppIdMACProdConfMap);
		System.debug('CalculateIncrementalRevenueSubscriber relevantInfoMap: ' + relevantInfoMap);
		if (!OppIdMACProdConfMap.isEmpty() && !(rootConfig==null))
		{
			calculation(OppIdMACProdConfMap, relevantInfoMap, rootConfig);
		}
    }

    public void calculation(Map<cscfga__Product_Configuration__c,Id> OppIdMACProdConfMap, Map<cscfga__Product_Configuration__c, Map<cscfga__Product_Configuration__c,Id>> relevantInfoMap, cscfga__Product_Configuration__c rootConfig)
    {
        Decimal increaseInOneOff;
        Decimal increaseInRecurring;
		Integer remainingDays;
        Integer remainingTerm;
		Decimal totalIncrease = 0;
		
        Map<cscfga__Product_Configuration__c, csord__Order__c> dateOrderConfigMap = new Map<cscfga__Product_Configuration__c, csord__Order__c>();
        Set<Id> oppIdSet = new Set<Id>();
        List<csord__Order__c> orderList = new List<csord__Order__c>();
        List<Id> oppIdList = OppIdMACProdConfMap.values();
		List<cscfga__Product_Configuration__c> prodconfList = new List<cscfga__Product_Configuration__c>();
		prodconfList.addAll(OppIdMACProdConfMap.keySet());
        oppIdSet.addAll(oppIdList);
		System.debug('CalculateIncrementalRevenueSubscriber oppIdList ' + oppIdList + ';prodconfList: ' + prodconfList + ';oppIdSet: ' + oppIdSet);

        orderList = [SELECT Id, Name, csord__End_Date__c, csord__Start_Date__c, csordtelcoa__Opportunity__c FROM csord__Order__c WHERE csordtelcoa__Opportunity__c in:oppIdSet];

		System.debug('CalculateIncrementalRevenueSubscriber orderList: ' + orderList);
		
        for (csord__Order__c ord :orderList)
        {
            for (cscfga__Product_Configuration__c prodconf : prodconfList )
            {
				System.debug('CalculateIncrementalRevenueSubscriber relevantInfoMap.get(prodconf).values()[0]: ' + relevantInfoMap.get(prodconf).values()[0]);
				System.debug('CalculateIncrementalRevenueSubscriber ord.csordtelcoa__Opportunity__c: ' + ord.csordtelcoa__Opportunity__c);
				
				if ( ord.csordtelcoa__Opportunity__c == relevantInfoMap.get(prodconf).values()[0])
                {
					
					System.debug('CalculateIncrementalRevenueSubscriber TI before' + totalIncrease);
					List<cscfga__Product_Configuration__c> helperList = new List<cscfga__Product_Configuration__c>();
					helperList.addAll(relevantInfoMap.get(prodconf).keySet());
					System.debug('CalculateIncrementalRevenueSubscriber helperList' + helperList);
					if (ord.csord__End_Date__c==null)
					{
						remainingDays = 30;
					}
					else{
						remainingDays = Date.today().daysBetween(ord.csord__End_Date__c);
					}

					
                    remainingTerm = Integer.valueOf(remainingDays/30);
					
                    if ((helperList[0].cscfga__total_one_off_charge__c - prodconf.cscfga__total_one_off_charge__c) >= 0)
                    {
                        increaseInOneOff = 0;
                    }
                    else{
                        increaseInOneOff = prodconf.cscfga__total_one_off_charge__c - helperList[0].cscfga__total_one_off_charge__c;
                    }
                    if ((helperList[0].cscfga__total_recurring_charge__c - prodconf.cscfga__total_recurring_charge__c ) >= 0)
                    {
                        increaseInRecurring = 0;
                    }
                    else{
                        increaseInRecurring = prodconf.cscfga__total_recurring_charge__c - helperList[0].cscfga__total_recurring_charge__c;
                    }
					
					totalIncrease = totalIncrease + (increaseInRecurring*remainingTerm + increaseInOneOff);
					System.debug('CalculateIncrementalRevenueSubscriber TI after' + totalIncrease);
					
                }
            }
        }
		
		System.debug('CalculateIncrementalRevenueSubscriber root before' + rootConfig);
		
		rootConfig.Incremental_Revenue__c = totalIncrease;
		
		System.debug('CalculateIncrementalRevenueSubscriber root after' + rootConfig);

		cscfga__Product_Basket__c basket = [SELECT Id,Incremental_Revenue__c FROM cscfga__Product_Basket__c WHERE Id = :rootConfig.cscfga__Product_Basket__c];
		System.debug('CalculateIncrementalRevenueSubscriber basket before' + basket);
		basket.Incremental_Revenue__c = totalIncrease;
		System.debug('CalculateIncrementalRevenueSubscriber basket after' + basket);
		update rootConfig;
		update basket;		
    }
}
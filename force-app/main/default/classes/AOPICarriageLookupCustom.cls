global class AOPICarriageLookupCustom extends cscfga.ALookupSearch {

    public override String getRequiredAttributes(){
        return '["Access Type", "Access Configuration", "Class Of Service", "Plan Name", "H_ParentPIID"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit){
        System.debug('-----------> searchFields   ' + searchFields);
        String accessType = searchFields.get('Access Type');
        String accessConfig = searchFields.get('Access Configuration'); 
        String classOfService = searchFields.get('Class Of Service');
        String planName = searchFields.get('Plan Name');
        String searchValue = searchFields.get('searchValue');
        String serachMatch = '';
        
        if(searchValue != null && searchValue != '') {
            if(accessType == null || accessType == '') {
                serachMatch = 'cspmb__add_on_price_item__r.access_type__c like ' + '\'' + searchValue + '%\'';
            } else if (accessConfig == null || accessConfig == '') {
                serachMatch = 'cspmb__add_on_price_item__r.access_configuration__c like ' + '\'' + searchValue + '%\'';
            } else if (classOfService == null || classOfService == '') {
                serachMatch = 'cspmb__add_on_price_item__r.class_of_service__c like ' + '\'' + searchValue + '%\'';
            } else if (planName == null || planName == '') {
                serachMatch = 'cspmb__add_on_price_item__r.plan_name__c like ' + '\'' + searchValue + '%\'';
            }
        }
        
        String searchQuery = 'SELECT name, addOn_name__c, addon_code__c, id, price__c,cspmb__add_on_price_item__r.access_type__c,' +
            					'cspmb__add_on_price_item__r.access_configuration__c,' +
            					'cspmb__add_on_price_item__r.class_of_service__c,cspmb__add_on_price_item__r.plan_name__c  ' +
            				  ' FROM cspmb__Price_Item_Add_On_Price_Item_Association__c';
        String whereClose = '';
        if(serachMatch != '') {
            whereClose = ' WHERE ' + serachMatch + ' AND cspmb__add_on_price_item__r.cspmb__add_on_price_item_code__c = \'Carriage Access\'';
        } else {
            whereClose = ' WHERE cspmb__add_on_price_item__r.cspmb__add_on_price_item_code__c = \'Carriage Access\'';
        }
        //String whereClose = ' WHERE cspmb__add_on_price_item__r.cspmb__add_on_price_item_code__c = \'Carriage Access\'';// AND cspmb__Price_Item__c = \'' + searchFields.get('H_ParentPIID') + '\'';
        if(accessType != null && accessType != '') {
        	whereClose += ' AND cspmb__add_on_price_item__r.access_type__c = \'' +  accessType + '\''; 
        } 
        if(accessConfig != null && accessConfig != '') {
        	whereClose += ' AND cspmb__add_on_price_item__r.access_configuration__c = \'' +  accessConfig + '\''; 
        }
        if(classOfService != null && classOfService != '') {
        	whereClose += ' AND cspmb__add_on_price_item__r.class_of_service__c = \'' +  classOfService + '\''; 
        }
        if(planName != null && planName != '') {
        	whereClose += ' AND cspmb__add_on_price_item__r.plan_name__c = \'' +  planName + '\''; 
        }
        
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopis = Database.query(searchQuery + whereClose);
        
        if(accessType == null || accessType == '') {
        	return getUniqueListByField(aopis, 'AccessType'); 
        } else if(accessConfig == null || accessConfig == '') {
        	return getUniqueListByField(aopis, 'AccessConfiguration');
        } else if(classOfService == null || classOfService == '') {
        	return getUniqueListByField(aopis, 'ClassOfService');
        } else if(planName == null || planName == '') {
        	return getUniqueListByField(aopis, 'PlanName');
        }
        return aopis;
    }
    
    @TestVisible
    private List<cspmb__Price_Item_Add_On_Price_Item_Association__c> getUniqueListByField(List<cspmb__Price_Item_Add_On_Price_Item_Association__c> aopis, String fieldName){
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> uItams = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        Map<String, cspmb__Price_Item_Add_On_Price_Item_Association__c> itemMap =  new Map<String, cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        for(cspmb__Price_Item_Add_On_Price_Item_Association__c itam : aopis) {
            if(fieldName == 'AccessType' && !itemMap.containsKey(itam.cspmb__add_on_price_item__r.access_type__c)) {
                itam.cspmb__add_on_price_item__r.access_configuration__c = '-';
                itam.cspmb__add_on_price_item__r.class_of_service__c = '-';
                itam.cspmb__add_on_price_item__r.plan_name__c = '-';
                itemMap.put(itam.cspmb__add_on_price_item__r.access_type__c, itam);
            }
            if(fieldName == 'AccessConfiguration' && !itemMap.containsKey(itam.cspmb__add_on_price_item__r.access_configuration__c)) {
                itam.cspmb__add_on_price_item__r.class_of_service__c = '-';
                itam.cspmb__add_on_price_item__r.plan_name__c = '-';
                itemMap.put(itam.cspmb__add_on_price_item__r.access_configuration__c, itam);
            }
            if(fieldName == 'ClassOfService' && !itemMap.containsKey(itam.cspmb__add_on_price_item__r.class_of_service__c)) {
            	itam.cspmb__add_on_price_item__r.plan_name__c = '-';
                itemMap.put(itam.cspmb__add_on_price_item__r.class_of_service__c, itam);
            } 
            if(fieldName == 'PlanName' && !itemMap.containsKey(itam.cspmb__add_on_price_item__r.plan_name__c)) {
                itemMap.put(itam.cspmb__add_on_price_item__r.plan_name__c, itam);
            } 
        }
        return itemMap.values();
    }
}
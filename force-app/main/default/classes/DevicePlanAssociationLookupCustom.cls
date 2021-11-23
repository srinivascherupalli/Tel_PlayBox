global class DevicePlanAssociationLookupCustom extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    { 
        return '["ParentPriceItem","ManufacturerString","ModelString","ColourString","PaymentTypeString"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        System.debug('DevicePlanAssociationLookupCustom searchFields: ' + searchFields);

        Id selectedParentPriceItem = searchFields.get('ParentPriceItem');
        String selectedManufacturer = searchFields.get('ManufacturerString');
        String selectedModel = searchFields.get('ModelString');
        String selectedColour = searchFields.get('ColourString');
        String selectedPaymentType = searchFields.get('PaymentTypeString');
        
        system.debug('selectedParentPriceItem: ' + selectedParentPriceItem);
        String searchQuery = 'SELECT id, name, Device__c, Plan__c, Device__r.Name, Device__r.Manufacturer__c, Device__r.Model__c, Device__r.Colour__c, Device__r.Contract_Type__c, Device__r.cspmb__Contract_Term__c, MRO_Bonus__c, MRO_Price__c, Purchase_Price__c from Device_Plan_Association__c ' ;
        String fieldName = '';
        String orderBy = '';
        if (selectedParentPriceItem != null) {
            searchQuery += ' WHERE Plan__c = :selectedParentPriceItem ';
            orderBy = ' ORDER BY Plan__c';
            fieldName = 'Device__r.Manufacturer__c';
        }
        if (selectedManufacturer != null && selectedManufacturer != '') {
            searchQuery += 'AND Device__r.Manufacturer__c = :selectedManufacturer ';
            orderBy = ' ORDER BY Device__r.Manufacturer__c';
            fieldName = 'Device__r.Model__c';
        }
        if (selectedModel != null && selectedModel != '') {
            searchQuery += 'AND Device__r.Model__c = :selectedModel ';
            orderBy = ' ORDER BY Device__r.Model__c';
            fieldName = 'Device__r.Colour__c';
        }
        if (selectedColour != null && selectedColour != '') {
            searchQuery += 'AND Device__r.Colour__c = :selectedColour ';
            orderBy = ' ORDER BY Device__r.Colour__c';
            fieldName = 'Device__r.Contract_Type__c';

        }
        if (selectedPaymentType != null && selectedPaymentType != '') {
            searchQuery += 'AND Device__r.Contract_Type__c = :selectedPaymentType ';
            orderBy = ' ORDER BY Device__r.Contract_Type__c';
            fieldName = 'Device__r.cspmb__Contract_Term__c';

        }
        
        if(orderBy != ''){
            searchQuery += orderBy;
        }
        
        System.debug('DevicePlanAssociationLookupCustom searchQuery: ' + searchQuery);
        List<Device_Plan_Association__c> CommercialProductsList = Database.query(searchQuery);

        List<Device_Plan_Association__c> distinctList = getUniqueListByField(CommercialProductsList, fieldName);
        return distinctList;
    
    }

    @TestVisible
    private List<Device_Plan_Association__c> getUniqueListByField(List<Device_Plan_Association__c> pis, String fieldName){
        System.debug('DevicePlanAssociationLookupCustom pis: ' + pis);
        System.debug('DevicePlanAssociationLookupCustom fieldName: ' + fieldName);
        Map<String, Device_Plan_Association__c> itemMap =  new Map<String, Device_Plan_Association__c>();
        for(Device_Plan_Association__c item : pis) {
            if (fieldName == 'Device__r.Manufacturer__c' && !itemMap.containsKey(item.Device__r.Manufacturer__c)) {
                itemMap.put(item.Device__r.Manufacturer__c, item);
            }
            else if(fieldName == 'Device__r.Model__c' && !itemMap.containsKey(item.Device__r.Model__c)) {
                itemMap.put(item.Device__r.Model__c, item);
            }
            else if(fieldName == 'Device__r.Colour__c' && !itemMap.containsKey(item.Device__r.Colour__c)) {
                itemMap.put(item.Device__r.Colour__c, item);
            }
            else if(fieldName == 'Device__r.Contract_Type__c' && !itemMap.containsKey(item.Device__r.Contract_Type__c)) {
                itemMap.put(item.Device__r.Contract_Type__c, item);
            }
            else if(fieldName == 'Device__r.cspmb__Contract_Term__c' && !itemMap.containsKey(item.Device__r.cspmb__Contract_Term__c)) {
                itemMap.put(item.Device__r.cspmb__Contract_Term__c, item);
            }
            
        }
        System.debug('DevicePlanAssociationLookupCustom itemMap: ' + itemMap);
        return itemMap.values();
    }
}
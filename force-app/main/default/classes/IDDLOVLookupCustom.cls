//EDGE-81081 custom filter class - developer: Mladen
global class IDDLOVLookupCustom extends cscfga.ALookupSearch {
    public override String getRequiredAttributes()
    {
        return '["MobilityPlanSelected"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields,String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit)
    {
        String searchQuery;
        String chosenMobilityPlan = String.valueOf(searchFields.get('MobilityPlanSelected'));
        If (chosenMobilityPlan == 'L'){
            String filterName = 'InternationalDirectDialIn';
            String filterValue = '%45%';
            searchQuery = 'SELECT id, name, Value__c FROM Product_Attribute_LOV__c '
                + 'WHERE Name LIKE :filterName AND Value__c Like :filterValue '
                + 'ORDER BY Value__c ASC ';
            List<Product_Attribute_LOV__c> filteredIDDProducts = Database.query(searchQuery);
            return filteredIDDProducts;
        }else if (chosenMobilityPlan == 'M'){
            String filterName = 'InternationalDirectDialIn';
            String filterValue = '%30%';
            searchQuery = 'SELECT id, name, Value__c FROM Product_Attribute_LOV__c '
                + 'WHERE Name LIKE :filterName AND Value__c Like :filterValue '
                + 'ORDER BY Value__c ASC ';
            List<Product_Attribute_LOV__c> filteredIDDProducts = Database.query(searchQuery);
            return filteredIDDProducts;
        }else{
            String filterName = 'InternationalDirectDialIn';
            searchQuery = 'SELECT id, name, Value__c FROM Product_Attribute_LOV__c '
                + 'WHERE Name LIKE :filterName '
                + 'ORDER BY Value__c ASC ';
            List<Product_Attribute_LOV__c> filteredIDDProducts = Database.query(searchQuery);

            return filteredIDDProducts;
        }
    }
}
global class SolutionOEHelper implements cssmgnt.RemoteActionDataProvider {

    // --- main method that needs to be implemented ---
    global Map<String, Object> getData(Map<String, Object> inputMap) {
        System.debug('Enter remote action');
        System.debug('Input Map ' + inputMap);

        Map<String, Object> returnMap = new Map<String, Object>();

        returnMap = getRequiredInfo(inputMap);
        
        return returnMap;

    }
    // -------------------
	
    private Map<String, Object> getRequiredInfo(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<Object> attributesData = new List<Object>();
        List<List<Map<String, Object>>> configData = new List<List<Map<String, Object>>>();
        for (Functional_Contact_Role__c fcr : [SELECT Id, Name, Role_Type__c, Role__c, SiteID__c, contactid__c FROM Functional_Contact_Role__c WHERE Role_Type__c = 'Site' AND Role__c = 'Primary Contact' LIMIT 1]) {
            Map<String, Object> attribute1 = new Map<String, Object>();
            Map<String, Object> attribute1Values = new Map<String, Object>();
            attribute1.put('name','Funcprimarycontact');
            attribute1Values.put('value', fcr.contactid__c);
            attribute1Values.put('displayValue', fcr.contactid__c);
            attribute1Values.put('readOnly', true);
            attribute1Values.put('required', false);
            attribute1.put('value',attribute1Values);
            attributesData.add(attribute1);
        }
        returnMap.put('Site Details', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }
}
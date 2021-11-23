global class SolutionOpportunityHelper implements cssmgnt.RemoteActionDataProvider {

    // --- main method that needs to be implemented ---
    global Map<String, Object> getData(Map<String, Object> inputMap) {
        System.debug('Enter remote action');
        System.debug('Input Map ' + inputMap);
        //return getRequiredInfo(inputMap);
        
        Map<String, Object> returnMap = new Map<String, Object>();

        returnMap = getRequiredInfo(inputMap);
        
        
        return returnMap;

    }

    private Map<String, Object> getRequiredInfo(Map<String, Object> inputMap) {
        Map<String, Object> returnMap = new Map<String, Object>();		
        String basketId = (String)inputMap.get('basketId');
        Map<String, Object> attribute1 = new Map<String, Object>();
        Map<String, Object> attribute1Values = new Map<String, Object>();
        List<Object> attributesData = new List<Object>();
        cscfga__Product_Basket__c pb = [SELECT cscfga__Opportunity__c FROM cscfga__Product_Basket__c WHERE id =: basketId LIMIT 1];
        system.debug('pb-->'+pb);
        attribute1.put('name','OpptyId');
        attribute1Values.put('value', pb.cscfga__Opportunity__c);
        attribute1Values.put('displayValue', pb.cscfga__Opportunity__c);
        attribute1Values.put('readOnly', true);
        attribute1Values.put('required', false);
        attribute1.put('value',attribute1Values);
        attributesData.add(attribute1);
        returnMap.put('IP Site', attributesData);
        System.debug('Final Output : '+ JSON.serialize(attributesData));
        return returnMap;
    }
}
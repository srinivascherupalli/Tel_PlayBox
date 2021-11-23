global with sharing class SolutionGetBaskeData implements cssmgnt.RemoteActionDataProvider {

    @RemoteAction
    global static Map<String,Object> getData(Map<String,Object> inputMap) {

        System.debug('inputMap'+inputMap);

        Map<String, Object> returnMap = new Map<String, Object>(); 
        Set<String> inputKey = inputMap.keySet();
        Set<String> basketIds = new Set<String>();
        for(String k :inputKey){
            if (k == 'basketId') {
                String basketId = (String)inputMap.get('basketId');
                basketIds.add(basketId);
            }
        }
        Map<String,cscfga__Product_Basket__c> basketMap = new Map<String,cscfga__Product_Basket__c>([Select id, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id IN: basketIds]);
        for (String k :inputKey) {
            if (k == 'basketId') {
                String basketId = (String)inputMap.get('basketId');
                //cscfga__Product_Basket__c basket = [Select id, csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c where id =:basketId];
                cscfga__Product_Basket__c basket =  basketMap.get(basketId);
                returnMap.put('basket',basket);

            } 
            else if (k == 'Hunt Group' && inputMap.containsKey('Offer Id'))  {
                returnMap.put(k, getUnitPriceByProductforUCE(k, (String)inputMap.get(k)));
            }else if(k == 'Hunt Group') {
                returnMap.put(k, getUnitPriceByProduct(k, (String)inputMap.get(k)));
            }
            else if (k == 'Auto Attendants' && inputMap.containsKey('Offer Id'))  {
                returnMap.put(k, getUnitPriceByProductforUCE(k, (String)inputMap.get(k)));
            }else if(k == 'Auto Attendants') {
                returnMap.put(k, getUnitPriceByProduct(k, (String)inputMap.get(k)));
            }
            else if (k == 'Main Business Numbers' && inputMap.containsKey('Offer Id'))  {
                returnMap.put(k, getUnitPriceByProductforUCE(k, (String)inputMap.get(k)));
            }else if(k == 'Main Business Numbers') {
                returnMap.put(k, getUnitPriceByProduct(k, (String)inputMap.get(k)));
            }
        }
    
        return returnMap;
    }

    private static cspmb__Price_Item__c getUnitPriceByProduct(String pdName, String attr) {

        cspmb__Price_Item__c pi = null;

        String sQry = 'SELECT id, ' + attr + ' FROM cspmb__Price_Item__c WHERE cspmb__Product_Definition_Name__c = \'' + pdName + '\' limit 1';
        system.debug('sQry: ' + sQry);

        List<cspmb__Price_Item__c> piList = Database.query(sQry);

        if (piList != null && !piList.isEmpty() ) {
            pi = piList[0];
        } else {
            pi = null;
        }
        return pi;
    }   
    
    private static cspmb__Price_Item__c getUnitPriceByProductforUCE(String pdName, String attr) {

        cspmb__Price_Item__c pi = null;
        String offerId = 'DMCAT_Offer_000618';
        String sQry = 'SELECT id,Offer_Id__c, ' + attr + ' FROM cspmb__Price_Item__c WHERE Offer_Id__c = \'' + offerId + '\' AND cspmb__Product_Definition_Name__c = \'' + pdName + '\' and cspmb__Effective_End_Date__c >= TODAY AND cspmb__Effective_Start_Date__c <= TODAY ORDER BY rangeTo__c ASC limit 1';
        system.debug('sQry: ' + sQry);

        List<cspmb__Price_Item__c> piList = Database.query(sQry);

        if (piList != null && !piList.isEmpty() ) {
            pi = piList[0];
        } else {
            pi = null;
        }
        return pi;
    }   
}
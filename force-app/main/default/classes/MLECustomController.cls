public with sharing class MLECustomController {
    
    @TestVisible private static Map<String, String> pdIdAndNameMap;
    @TestVisible private static Map<String, List<ScreenFlowDTO>> pdAndSfa;
    @TestVisible private static Map<String, Object> payload;
    @TestVisible private static String PDS = 'PDS';
    @TestVisible private static String SFS = 'SFS';
  
    @RemoteAction
    public static String getBasketData(String basketId) {
        getPorductDefinitionsForBasket(basketId);
        getScreenFlowsForProductDefinitions(pdIdAndNameMap.keySet());
        payload =  new Map<String, Object>();
        payload.put(PDS, pdIdAndNameMap);
        payload.put(SFS, pdAndSfa);
        return JSON.serialize(payload);
    }
    
    @TestVisible
    private static void getPorductDefinitionsForBasket(String bId) {
        List<cscfga__Product_Configuration__c> pcs = [	SELECT cscfga__Product_Definition__c, 
                                                      			cscfga__Product_Definition__r.name
                                                        FROM cscfga__Product_Configuration__c
                                                        WHERE cscfga__Product_Basket__c = :bId];
        pdIdAndNameMap =  new Map<String, String>();
        for(cscfga__Product_Configuration__c pc : pcs) {
            pdIdAndNameMap.put(pc.cscfga__Product_Definition__c, pc.cscfga__Product_Definition__r.name);
        }
    }
    
    @TestVisible
    private static void getScreenFlowsForProductDefinitions(Set<String> pdIds) {
        List<cscfga__Screen_Flow_Product_Association__c> sfas = [ SELECT cscfga__Product_Definition__c,
                                                                 		cscfga__Screen_Flow_Name__c, 
                                                                 		cscfga__Screen_Flow__r.id
                                                                  FROM cscfga__Screen_Flow_Product_Association__c
                                                                  WHERE cscfga__Product_Definition__c IN :pdIds];
        pdAndSfa = new Map<String, List<ScreenFlowDTO>>();
        for(cscfga__Screen_Flow_Product_Association__c sfa : sfas) {
            ScreenFlowDTO sfDTO =  new ScreenFlowDTO();
            sfDTO.flowId = sfa.cscfga__Screen_Flow__r.id;
            sfDTO.name = sfa.cscfga__Screen_Flow_Name__c;
            if(pdAndSfa.containsKey(sfa.cscfga__Product_Definition__c)) {
                pdAndSfa.get(sfa.cscfga__Product_Definition__c).add(sfDTO);
            } else {
                List<ScreenFlowDTO> nSfa = new List<ScreenFlowDTO>();
                nSfa.add(sfDTO);
                pdAndSfa.put(sfa.cscfga__Product_Definition__c, nSfa);  
            }
        }
    }
}
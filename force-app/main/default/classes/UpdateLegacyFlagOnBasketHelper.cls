public with sharing class UpdateLegacyFlagOnBasketHelper {//added with sharing for vulnerability

    /*EDGE-8185 
    *to update basket Legacy flag for Legacy Sites selected
    */
    
    /*
	/* Gnana : Commented below code as part of Spring'20 Upgrade Activity 
	 * No longer required as Legacy__c and TransitionComplete__c fields are not used in any business logic
	 * 
    public static void updateBasketLegacyStatusAfterPCRCreation(List <csbb__Product_Configuration_Request__c> prodConfigReqList){

        Set<Id> pcrIds = (new Map<Id,SObject>(prodConfigReqList)).keySet();
        Map<Id, List<string>> basketIdCompositeKeyListMap = new Map<Id, List<string>>();
        List<cscfga__Product_Basket__c> pbToUpdate= new List<cscfga__Product_Basket__c>();
        Map<String, String> compositeKeyANDCidnPlusAdborIdMap = new Map<String, String>();
        List<String> adborIDList= new List<String>();
        List<String> cidnList= new List<String>();

        List<csbb__Product_Configuration_Request__c> pcrList = [SELECT Id, csbb__Product_Basket__c, csbb__Product_Basket__r.csbb__Account__r.CIDN__c, csbb__Optionals__c FROM csbb__Product_Configuration_Request__c WHERE Id IN: pcrIds AND csbb__Product_Category__r.Name !='Current Product Catalog'];

        for(csbb__Product_Configuration_Request__c pcr: pcrList) {
            String adborId = fetchAdBorIdFromPCR(pcr);
            String cidn = pcr.csbb__Product_Basket__r.csbb__Account__r.CIDN__c;
            
            if(adborId != null && cidn != null){
                if(basketIdCompositeKeyListMap.containsKey(pcr.csbb__Product_Basket__c)){
                    List<String> compList =basketIdCompositeKeyListMap.get(pcr.csbb__Product_Basket__c);
                    compList.add(cidn+adborId);
                    basketIdCompositeKeyListMap.put(pcr.csbb__Product_Basket__c,compList);
                }

                else{
                    List<String> compList = new List<String>();
                    compList.add(cidn+adborId);
                    basketIdCompositeKeyListMap.put(pcr.csbb__Product_Basket__c,compList);
                }

                compositeKeyANDCidnPlusAdborIdMap.put(cidn+adborId, cidn+'|'+adborId);
                adborIDList.add(adborId);
                cidnList.add(cidn);
            }
        }

        Map<Id, cscfga__Product_Basket__c> basketMap = new Map<Id, cscfga__Product_Basket__c>([SELECT id, Legacy__c, TransitionComplete__c FROM cscfga__Product_Basket__c WHERE Id IN: basketIdCompositeKeyListMap.keyset()]);
        List<String> compList = new List<String>();
        for(List<String> stringList: basketIdCompositeKeyListMap.values()){
            for(String str: stringList){
                compList.add(str);
            }
            
        }

        Map<String, Boolean> sitecompIdLegacyMap = new Map<String, Boolean>();
        Set<String> cIDNPlusAdborId = new Set<String>();
        for(cscrm__Site__c site: [SELECT Id, Name, AdborId__c, cscrm__Installation_Address__r.Address_ID__c ,cscrm__Account__r.CIDN__c, Composite_Key__c, Legacy__c FROM cscrm__Site__c WHERE cscrm__Installation_Address__r.Address_ID__c IN: adborIDList AND cscrm__Account__r.CIDN__c IN: cidnList]){
            String adborID = site.cscrm__Installation_Address__r.Address_ID__c;
            String cidn = site.cscrm__Account__r.CIDN__c;
            if(adborID != null && adborID != '' && cidn != null && cidn != ''){
                sitecompIdLegacyMap.put(cidn+adborID, site.Legacy__c);
           
            }  
        }
        
        if(sitecompIdLegacyMap.size()==0){
            for(String compositekey: compositeKeyANDCidnPlusAdborIdMap.KeySet()){
                cIDNPlusAdborId.add(compositeKeyANDCidnPlusAdborIdMap.get(compositekey));
            }
        }
        else{
            for(String compositekey:sitecompIdLegacyMap.keySet()){//sitecompIdLegacyMap contians sites which are already there in Salesfore no need to create them so removing from final Map
                compositeKeyANDCidnPlusAdborIdMap.remove(compositekey);
            }
            for(String compositekey: compositeKeyANDCidnPlusAdborIdMap.KeySet()){
                cIDNPlusAdborId.add(compositeKeyANDCidnPlusAdborIdMap.get(compositekey));
            }
        }

        
        if(Trigger.isInsert && Trigger.isAfter){
            
            System.debug('cIDNPlusAdborId<><>'+cIDNPlusAdborId);
            if(cIDNPlusAdborId.size()>0){
                System.debug('cIDNPlusAdborId<><>'+cIDNPlusAdborId);
				String TransitionClone = EnvironmentVariable__c.getValues('TransitionClone').Value__c;
				System.debug('***** '+ TransitionClone );
				if(TransitionClone=='2'){
					insertNewSites(cIDNPlusAdborId);
				}					
			}			
                
		}
        
        for(cscfga__Product_Basket__c basket: basketMap.values()){
            if(basketIdCompositeKeyListMap.containsKey(basket.Id)){
                List<String> compLis = basketIdCompositeKeyListMap.get(basket.Id);
                Boolean pbcontainsLegacySite =false;
                for(String compositeKey: compLis){
                    if(sitecompIdLegacyMap.containsKey(compositeKey) && sitecompIdLegacyMap.get(compositeKey) == true){
                        pbcontainsLegacySite = true;
                        break;
                    } 
                    if(!sitecompIdLegacyMap.containsKey(compositeKey)){ //Site not in Salesforce
                        pbcontainsLegacySite = true;
                        break;
                    }
                }
                if(pbcontainsLegacySite == true){
                    basket.Legacy__c = true;
                    basket.TransitionComplete__c = false;
                    pbToUpdate.add(basket);
                }
                else{
                    basket.Legacy__c = false;
                    basket.TransitionComplete__c = true;
                    pbToUpdate.add(basket);
                }
            }
        }

        Update pbToUpdate;  
    }
	*/


    /*EDGE-8185 
    *Class used to parse the json in the optionals field of PCR
    */
    
    /*  Gnana : Commented below code as part of Spring'20 Upgrade Activity 
    public class Optionals{
        public String selectedAddressDisplay;
        public String hiddenParam1;
    }*/

    /* Gnana : Commented below code as part of Spring'20 Upgrade Activity 
    public Static String fetchAdBorIdFromPCR (csbb__Product_Configuration_Request__c pcrNew){
        //CHECK IF OPTIONALS IS NOT NULL
        if(pcrNew != null && pcrNew.csbb__Optionals__c!=null){
            String optionalsJson = '['+pcrNew.csbb__Optionals__c+']';
            String adborID = '';
            //PARSE THE OPTIONALS VALUE
            List<Optionals> optionalLs = (List<Optionals>)System.JSON.deserialize(optionalsJson, List<Optionals>.class);
            for(Optionals op: optionalLs){
                if(op.hiddenParam1 != null){
                    adborID = op.hiddenParam1;
                    break;
                }
            }
            return adborID;
        }else{
            return null;        
        }
    }
	*/

/*EDGE-8185 
    *to insert Site in Salesforce if Legacy - make queueable call to insert the site
    */
    
    /* Gnana : Commented below code as part of Spring'20 Upgrade Activity 
    public static void insertNewSites(Set<String> cIDNPlusAdborId){

        for(String str: cIDNPlusAdborId){
            String adBorID = str.substringAfter('|');
            String finCIDN = str.substringBefore('|');
            System.enqueueJob(new AsyncExecutionReplicatorGetSite(finCIDN,adBorID));
        }

    }
*/




    /*EDGE-8185 
    *to insert Site in Salesforce if Legacy - make replicator call and insert the site
    * FUTURE CALLOUT METHOD
    */
    
    @future(callout=true)
    public static void insertLegacySiteFuture(String finCIDN, String adBorID){
        ReplicatorGetSiteDataObject getSiteDTO = ReplicatorGetSiteService.getCustomerSites(finCIDN);
        if(getSiteDTO != null){
            AddressAndSiteObjectUtility.upsertReplicatorAddressAndSite(adBorID,getSiteDTO);
            List<cscrm__Site__c> siteList = [select id from cscrm__Site__c where cscrm__Installation_Address__r.Address_ID__c =: adBorID AND  cscrm__Account__r.CIDN__c =: finCIDN ];
            system.debug('PCRTriggerHandler - siteList to updatewithLegacy ' + siteList);
            for(cscrm__Site__c site : siteList){
                site.Legacy__c=true;
            }
            update siteList;
        }
    } 


    /* Gnana : Commented below code as part of Spring'20 Upgrade Activity 
    public static void updateBasketLegacyStatusAfterPCRDeletion(List<csbb__Product_Configuration_Request__c> pcrL){

        List<Id> basketIdList= new List<Id>();
        List<csbb__Product_Configuration_Request__c> pcrList= new List<csbb__Product_Configuration_Request__c>();
        List<cscfga__Product_Basket__c> pbToUpdate = new List<cscfga__Product_Basket__c>();
        
        for(csbb__Product_Configuration_Request__c pcr: pcrL){
            basketIdList.add(pcr.csbb__Product_Basket__c);
        }

        Set<Id> pcrIds = (new Map<Id,SObject>(pcrL)).keySet();
        
        for(cscfga__Product_Basket__c basket: [SELECT id, Legacy__c, TransitionComplete__c,(SELECT Name, csbb__Optionals__c FROM csbb__Product_Configuration_Requests__r WHERE Id NOT IN: pcrIds) FROM cscfga__Product_Basket__c WHERE Id IN: basketIdList]){
            
            for(csbb__Product_Configuration_Request__c pcr: basket.csbb__Product_Configuration_Requests__r){
                pcrList.add(pcr);
            }
            
            if(basket.csbb__Product_Configuration_Requests__r.size() == 0){
                basket.Legacy__c = false;
                basket.TransitionComplete__c = true;
                pbToUpdate.add(basket);
            }
            
            
        }
        
        update pbToUpdate;
        if(pcrList.size()>0){
            updateBasketLegacyStatusAfterPCRCreation(pcrList);
        }
        
    }
	*/

}
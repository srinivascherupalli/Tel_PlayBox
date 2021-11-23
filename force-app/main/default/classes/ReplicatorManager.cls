/*
*    Manager class for all interactions with the Replicator interface
*/
public with sharing class ReplicatorManager {
	
	private ReplicatorManager(){}
    
    @AuraEnabled 
    public static ReplicatorGetSiteDataObject getCustomerSites(String finCIDN) {
        System.debug('Input CIDN to getCustomerSites :'+finCIDN);		 
        return ReplicatorGetSiteService.getCustomerSites(finCIDN);
    }
    
    @AuraEnabled
    public static ReplicatorGetServiceDataObject getCustomerServicesAtSite(String finCIDN, List<String> adbor_Id, List<String> siteNameArray) {
        ReplicatorGetServiceDataObject serviceDTO;
        try{
        	
        	Map<String,String> siteNameMap = new Map<String, String>();
            for(String siteName : siteNameArray){
                String[] siteNameList = siteName.split('#');
                siteNameMap.put(siteNameList[0], siteNameList[1]);
            }
            
            System.debug('finCIDN'+finCIDN+'adborId'+adbor_Id);
        	serviceDTO = ReplicatorLegacyAssetService.getCustomerServices(finCIDN, adbor_Id);
        	for (ReplicatorGetServiceDataObject.SiteDTO siteData : serviceDTO.Site){
        		siteData.siteName = siteNameMap.get(siteData.ADBOR_Id);
	 			Map<String,String> pIDInFlightMap = new Map<String,String>();
        		for(ReplicatorGetServiceDataObject.ProductDTO product: siteData.productList){           
            		pIDInFlightMap.put(product.Product_Identifier,product.In_Flight_Flag);
        		}           
        	}
        }catch(Exception e){
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
        }   
        System.debug('serviceDTO'+serviceDTO);
        return serviceDTO;
    }    
    
    @AuraEnabled 
    public static AddressAndSiteObjectUtility.AuraProcessingMessage upsertAddress(String[] adborIdList,String replicatorAddress){
		AddressAndSiteObjectUtility.AuraProcessingMessage auramsg ;
		try{			
			ReplicatorGetSiteDataObject siteDTO = ReplicatorGetSiteDataObject.parse(replicatorAddress);
        	auramsg = AddressAndSiteObjectUtility.upsertReplicatorAddressAndSiteList(adborIdList,siteDTO);
            AddressAndSiteObjectUtility.upsertReplicatorAddressAsync(adborIdList,replicatorAddress);                       
		}
 		catch(Exception e){
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
        }
   		return auramsg;
    }        
     @AuraEnabled 
    public static AddressAndSiteObjectUtility.AuraProcessingMessage inFlightCheck(String adbor_id,String cidn){ 
        return AddressAndSiteObjectUtility.inFlightCheck(adbor_id,cidn);
    }
    
    //Get Eligible Offers for given Services  
    @AuraEnabled
    public static List<String> getEligibleOffers(String legacyService){
        ReplicatorGetServiceDataObject serviceDTO ;
        try{
             system.debug('***** parameter' + legacyService);
             serviceDTO = ReplicatorGetServiceDataObject.parse(legacyService);
            system.debug('****serviceDTO' + serviceDTO);
             return TransitionProductBasketCreation.getEligibleOffersForTransition(serviceDTO);
        }
        catch(Exception e){
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
        }
        return null;
    }
    
    //Transition to Basket Page
    @AuraEnabled
     public static String redirectToBasket(String legacyProd, String selectedOffer,String opportunityID){
         String urlToBasket;
         List<String> selectedOfferList;
         ReplicatorGetServiceDataObject serviceDTO;
         try{
             system.debug('in redirect to basket function'+selectedOffer);
             selectedOfferList = (List<String>)JSON.deserialize(selectedOffer, List<String>.class);
             system.debug('selectedOfferList:'+selectedOfferList);
         	 serviceDTO = ReplicatorGetServiceDataObject.parse(legacyProd);
             system.debug('serviceDTO :' + serviceDTO);
             PageReference basketPage= TransitionProductBasketCreation.createTransitionBasket(serviceDTO,selectedOfferList,opportunityID);
             
             urlToBasket=basketPage.getUrl();
             system.debug('PageReference urlToBasket :' +basketPage +' '+urlToBasket);
         }catch(Exception e){
            Logger.getLogger(ReplicatorManager.class).debug(e);
            Logger.exitLogger();
         }
         return urlToBasket;
     }
    
    @AuraEnabled 
    public static ReplicatorGetServiceDataObject getReplicatorGetServiceDataObject() {
        ReplicatorGetServiceDataObject obj=new ReplicatorGetServiceDataObject();
        obj.site= new List<ReplicatorGetServiceDataObject.SiteDTO>();
        obj.CIDN='';
        obj.Source_System_Id='';
        obj.Correlation_Id='';
        obj.Error_Code='';
        obj.Error_Description='';
        System.debug('ReplicatorGetServiceDataObject:'+obj);
        return obj;
    }
    
    @AuraEnabled 
    public static ReplicatorGetServiceDataObject getSelectedSite(String checkboxes,String legacyService) {
        ReplicatorGetServiceDataObject objDTO=new ReplicatorGetServiceDataObject();
        ReplicatorGetServiceDataObject selectedDTO=new ReplicatorGetServiceDataObject();
        system.debug('***** parameter legacyService' + legacyService);
        List<String> checkbox = (List<String>)System.JSON.deserialize(checkboxes, List<String>.class);
        system.debug('***** parameter checkboxes' + checkboxes);
        system.debug('*****' + checkbox[0]);
        objDTO = ReplicatorGetServiceDataObject.parse(legacyService);
        system.debug('****serviceDTO' + objDTO);
        system.debug('****serviceDTO' + selectedDTO);
        Integer k=0;       
        
        selectedDTO.site= new List<ReplicatorGetServiceDataObject.SiteDTO>();
        for (Integer j = 0; j < objDTO.site.size(); j++) {
            system.debug('PD Size :'+objDTO.site[j].productList.size());
            ReplicatorGetServiceDataObject.SiteDTO siteDTO = new ReplicatorGetServiceDataObject.SiteDTO();
            siteDTO.productList = new List<ReplicatorGetServiceDataObject.ProductDTO>();
            for (Integer i = 0; i < objDTO.site[j].productList.size(); i++) {
				ReplicatorGetServiceDataObject.ProductDTO productDTO = new ReplicatorGetServiceDataObject.ProductDTO(); 
                system.debug('PD Size inside if:'+objDTO.site[j].productList.size());
                System.debug('here'+checkbox[k]);
                if (checkbox[k].equals('true')) {
                    productDTO = objDTO.site[j].productList[i];
                    siteDTO.productList.add(productDTO);
                }
                k++;
            }
            siteDTO.ADBOR_Id = objDTO.site[j].ADBOR_Id;
            siteDTO.Error_Code = objDTO.site[j].Error_Code;
            siteDTO.Error_Description = objDTO.site[j].Error_Description;
            if(!siteDTO.productList.isEmpty()){
               selectedDTO.site.add(siteDTO);
            }
        }
        selectedDTO.CIDN = objDTO.CIDN;
        selectedDTO.Source_System_Id = objDTO.Source_System_Id;
        selectedDTO.Correlation_Id = objDTO.Correlation_Id;
        selectedDTO.Error_Code = objDTO.Error_Code;
        selectedDTO.Error_Description = objDTO.Error_Description;
        System.debug('ReplicatorGetServiceDataObject:'+selectedDTO);
        return selectedDTO;
    }
}
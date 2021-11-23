/*************************************************************************************************
Name : BroadsoftTenancyController
Description :Controller class for BroadsoftTenancyComponent
Author:Kalashree Borgaonkar
Story: EDGE-216668
***************************************************************************************************/
public with sharing class BroadsoftTenancyController {
    public class LegacyDeatilsWrapper{
        @AuraEnabled
        public String legacyId;
        @AuraEnabled
        public String cidn;
        @AuraEnabled
        public String productFamily;
        @AuraEnabled
        public Boolean isSelected;
    }
    public class LegacyDisplayWrapper{
        @AuraEnabled
        public List<LegacyDeatilsWrapper> legacyDetails;
        @AuraEnabled
        public String message;
    }
    @AuraEnabled
    public static LegacyDisplayWrapper getLegacyServices(String basketid){
        LegacyDisplayWrapper legacyDetails = new LegacyDisplayWrapper();
        String targetCidn='';
        String cidnHeirarchy='';
        Boolean isCidnHeirarchy=false;
        List<String> cidnHeirarchyList = new  List<String>();
        List<String> prodFamilyList = new  List<String>{};
            try{
                List<cscfga__Product_Basket__c> basket = [SELECT csbb__Account__r.name,csbb__Account__r.CIDN__c
                                                          FROM cscfga__Product_Basket__c 
                                                          WHERE Id=: basketid];
                if(!basket.isEmpty()){
                    targetCidn = basket[0].csbb__Account__r.CIDN__c;
                }
                Map<String, String> cidnHeirarchyMap = TransitionSelectContoller.getCIDNDetails(basketid); 
                if(!cidnHeirarchyMap.isEmpty()){
                    cidnHeirarchyList = cidnHeirarchyMap.values();
                    for(String heirarchy: cidnHeirarchyList){
                        cidnHeirarchy = cidnHeirarchy + heirarchy +',';
                    }
                    cidnHeirarchy=cidnHeirarchy.removeEnd(',');
                }
                System.debug('cidnHeirarchy: '+cidnHeirarchy);
                System.debug('targetCidn: '+targetCidn);
                isCidnHeirarchy = (cidnHeirarchy!='')?true:false;
                ReplicatorGetServiceDTO serviceDTO= ReplicatorGetServiceManager.getSiteAgnosticServicesNgUc(targetCidn,prodFamilyList,basketid,cidnHeirarchy,isCidnHeirarchy,'BW-TENANCY');
                System.debug('ReplicatorGetServiceDTO'+serviceDTO);
                if(serviceDTO!=null){
                    if(serviceDTO.message!=null){
                        legacyDetails.message = serviceDTO.message;
                    }
                    else if(serviceDTO.servicesList.isEmpty()){
                        legacyDetails.message = Label.BW_LegacyServiceUnavailable +' '+ basket[0].csbb__Account__r.name;
                   		
                    }
                    else{
                       // LegacyDisplayWrapper legacyDisplay = new LegacyDisplayWrapper();
                        List<LegacyDeatilsWrapper> legacyDetailList = new  List<LegacyDeatilsWrapper>();
                        for( ReplicatorGetServiceDTO.servicesDTO service:serviceDTO.servicesList){
                            LegacyDeatilsWrapper legacyDetail = new LegacyDeatilsWrapper();
                            legacyDetail.cidn = service.cidn;
                            legacyDetail.legacyId = service.fnn;
                            legacyDetail.productFamily = service.productFamily;
                            legacyDetail.isSelected = false;
                            legacyDetailList.add(legacyDetail);
                            
                        }
                        legacyDetailList[0].isSelected = true;
                        System.debug('legacyDetailList'+legacyDetailList);
                        legacyDetails.legacyDetails = legacyDetailList;
                        legacyDetails.message = 'Success';
                    }
                }
                
            }
        catch(Exception ex){
            System.debug('Exception in getLegacyServices: '+ex.getStackTraceString());
            legacyDetails.message = ex.getMessage();
        }
        return legacyDetails;
    }
    
}
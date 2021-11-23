//EDGE - 67863 
//Author: Kalashree Borgaonkar
//This class is used to initiate SQ for MAC using 'initiateSQ' Button.
    global without sharing class CustomButtonInitiateSQ extends csbb.CustomButtonExt{
        public static Integer configurablePeriod = 5;
        public CustomButtonInitiateSQ (){
           // System.debug('In initiate SQ');
        }
        public String performAction(String basketID, String pcrIds) {
            //System.debug('In initiate SQ in method');
            //System.debug('IpcrIds: '+pcrIds);
            List<String> addressidList = getAddressidList(pcrIds);
            String accid = getAccountid(basketID);
            initiateSQService(addressidList,accid);
            return '{"status":"ok","text":"Success"}';
        }
        //Get addressids from PCR selected from the button.
        public List<String>  getAddressidList(String pcrIds){
            List<String> pcrList = new List<String>();
            Map<String, String>  values = null; 
            Map<String,String> optionsMap = new Map<String,String>();
            List<String> addressidList = new List<String> ();
            pcrList = pcrIds.remove('[').remove('"').remove(']').split(',');
            System.debug('pcrList: '+pcrList);
            List<csbb__Product_Configuration_Request__c> pcrOptionsList =[SELECT id,csbb__Optionals__c FROM csbb__Product_Configuration_Request__c WHERE id in :pcrList];
            for(csbb__Product_Configuration_Request__c pcr:pcrOptionsList){
                if(pcr.csbb__Optionals__c!=null && pcr.csbb__Optionals__c.contains('cscrm_installation_address_c')){
                    system.debug('pcr.csbb__Optionals__c'+pcr.csbb__Optionals__c);
                    optionsMap.put(pcr.id,pcr.csbb__Optionals__c);
                }
            }
            if(optionsMap!=null){
                for(String pcrid: optionsMap.keySet()){
                    System.debug('pcrid'+pcrid);
                    values =    (Map<String, String>)JSON.deserialize(optionsMap.get(pcrid), Map<String, String>.class);
                    System.debug('values: '+values);
                    if(values.keySet().contains('hiddenParam1')){
                        addressidList.add(values.get('hiddenParam1'));
                    }
                }
                System.debug('addressidList: '+addressidList);
                
            }
            return addressidList;
        }
        
        //Initiate Callout
        public void initiateSQService(List<String> addressidList,String accId){
            if(!addressidList.isEmpty()){
                List<String>    addressidListForSQ  = getConfigurableAddressIdList(addressidList,accId);
                if(!addressidListForSQ.isEmpty()){
                    String jobId = System.enqueueJob(new SQcheckCalloutHandler(addressidListForSQ,accId));
                }
            }
        } 
        
        //Get list of addressids for which call is not made within configurable time period. 
        public List<String> getConfigurableAddressIdList(List<String> addressidList,String accId){
            List<cscrm__Site__c> siteList = [SELECT id,AdborID__c,(SELECT CreatedDate from Service_qualifications__r ORDER BY CreatedDate desc LIMIT 1) FROM cscrm__Site__c WHERE cscrm__Account__c =:accId AND AdborID__c IN  :addressidList];
            System.debug('siteList: '+siteList);
            List<Service_Qualification__c> sqList = null;
            List<String> adboridList = new List<String>();
            for(cscrm__Site__c site : siteList){
                sqList = site.Service_qualifications__r;
                if(sqList.isEmpty()){
                    adboridList.add(site.AdborID__c);
                }
                else{
                    if(shouldInitiateSQ(Date.valueOf(sqList[0].CreatedDate))){
                        adboridList.add(site.AdborID__c);
                    }
                }
            }
            System.debug('adboridList: '+adboridList);
            return adboridList;
        }
        
        // Check if  call was made within configurable time period.
        public Boolean shouldInitiateSQ(Date createDate){
            Date todayDate = Date.today();
            System.debug('date: '+createDate.daysBetween(todayDate));       
            if(createDate.daysBetween(todayDate)>configurablePeriod){
                return true;
            }
            return false;
        }   
        //EDGE-75272 Bug. To associate a SQ response with a site. 
        //get accountId from account of Product basket for composite key 
        public String getAccountid(String basketId){
            cscfga__Product_Basket__c basket = [SELECT csbb__Account__c FROM cscfga__Product_Basket__c WHERE id =:basketId];
            String accId=null;
            if(basket!=null){
                accId = basket.csbb__Account__c;
            }
            return accId;
        }    
    }
/*************************************************************************************************
Name : PpvComponentController
Description : Used for Pre-Port Verification
Author: Kalashree Borgaonkar
Story: EDGE-90327
***************************************************************************************************/
public with sharing class PpvComponentController {
    
    /*-------------------------------------------------------- 
EDGE-90327
Method: getDetails
Description: Method to get details using baskeid
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    
    //test basketid:a3Q2O0000008VZj
    @AuraEnabled
    public static  BasketDetailsWrapper getDetails(String basketid){
        BasketDetailsWrapper detailWrapper  = null;
        System.debug('basketid: '+basketid);
        List<cscfga__Product_Basket__c> basketDetail = [SELECT cscfga__Opportunity__c,csbb__Account__c,csbb__Account__r.name,Name FROM cscfga__Product_Basket__c WHERE ID=:basketid ]; 
        //EDGE-113427 To fetch recent CAF
        List<Customer_Authority_Form__c> activeCAF = [SELECT Id FROM Customer_Authority_Form__c WHERE Opportunity__c=:basketDetail[0].cscfga__Opportunity__c AND Is_active__c = true ORDER BY createdDate desc LIMIT 1];
        System.debug('activeCAF: '+activeCAF);
        System.debug('basketDetail: '+basketDetail);
        String activeCafid = !activeCAF.isEmpty()?activeCAF[0].id:null;
        if(!basketDetail.isEmpty() && activeCafid!=null){
            detailWrapper = new BasketDetailsWrapper(basketDetail[0].Name,basketDetail[0].csbb__Account__r.name,activeCafid,basketDetail[0].csbb__Account__c,basketDetail[0].cscfga__Opportunity__c);	
            System.debug('detailWrapper: '+detailWrapper);
        }	
        return detailWrapper;
    } 
    
    /*-------------------------------------------------------- 
EDGE-90327
Method: ppvCallout
Description: Method to make callout to PPV tool
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @AuraEnabled
    public static  ResponeWrapper ppvCallout(String accountId,String portNumber,String externalId,String contactName){
        ResponeWrapper wrapper = null;
        String response = 'Error';
        System.debug(accountId+''+contactName);
        //List<Contact> con = [SELECT id FROM Contact WHERE accountid = :accountId AND name = :contactName];
        List<AccountContactRelation> acr = [SELECT AccountId,contactid,contact.name FROM AccountContactRelation WHERE AccountId=:accountid AND contact.name=:contactName];
        PpvRequestDTO ppvRequest = PpvCallout.createPayload(portNumber,externalId);
        PpvResponseDTO ppvResponse=PpvCallout.calloutToPpvTool(ppvRequest);
        String ppvStatus=null;
        String resourceId=null;
        if(ppvResponse!=null ){
            ppvStatus = ppvResponse.responseCode;
            if(ppvResponse.data!=null){
                resourceId = ppvResponse.data.resourceId;
            }
            if(ppvResponse.code==202){
                response=Label.PpvSmsSuccessful.replace('<portNumber>', portnumber);
                
            }
            else if(ppvResponse.code==422){
                
                response=Label.PpvSmsError.replace('<portNumber>', portnumber);	
            }
            else if(ppvResponse.code==503){
                response=Label.PpvSmsError503.replace('<portNumber>', portnumber);	
            }
            wrapper = new ResponeWrapper(response,String.valueOf(ppvResponse.code));      
        }
        saveResponse(ppvStatus,externalId,portNumber,!acr.isEmpty()?acr[0].contactid:null,resourceId);
        return wrapper;
    }
    
    /*-------------------------------------------------------- 
EDGE-100327
Method: addToReservationPool
Description: Method to save all eligible port in numbers to Reservation Pool
Author:Aishwarya Yeware
-------------------------------------------------------- */
    
    
    public static PpvWrapper addToReservationPool(String accountId,String OppId,String resourceId,String Status){
        //Boolean isAdded = false;
        PpvWrapper detailWrapper  = new PpvWrapper();
        List<Service_Qualification__c> sqList = null;
        Number__c msisdn = null;
        List<Number__c> msisdnListToSave = null;
        Set<String> servNum = new set<String>();
        List<cscfga__Product_Basket__c> bsktAcc = [Select id,Name from cscfga__Product_Basket__c where cscfga__Opportunity__c=:OppId AND Primary_Basket__c=true];
        List<Number__c> numList = [SELECT id,Service_Number__c from Number__c where basket__c=: bsktAcc[0].id AND  type__C='Port In']; 
        for(Number__c num: numList){
            servNum.add(num.Service_Number__c);
            system.debug('number in Pool for current account== ' +servNum);
        } 
        msisdnListToSave = new List<Number__c>();
        
        sqList= [SELECT Service_Number__c ,Basket_id__c FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Added_to_CA_form__c=true AND Account__c = :accountId AND Service_number__c  NOT IN :servNum];
        System.debug('sqList: '+sqList);
        try{
            if(sqList !=NULL){ 
                for(Service_Qualification__c sq:sqList){ 
                    msisdn = new Number__c();
                    msisdn.Service_Number__c = sq.Service_Number__c;
                    msisdn.Type__c = 'Port In';
                    msisdn.Mobile__c='Mobile';
                    msisdn.Basket__c=bsktAcc[0].id;
                    msisdnListToSave.add(msisdn);
                    detailWrapper.basketId=bsktAcc[0].id;   
                }
                if(msisdnListToSave!=null && !msisdnListToSave.isEmpty() && Status==Label.ppv_success){
                    insert msisdnListToSave ;
                    detailWrapper.isAdded=true;
                    //postChattertNotification(msisdnListToSave);
                    System.debug('msisdnListToSave: '+msisdnListToSave);
                }
                else if(msisdnListToSave!=null && !msisdnListToSave.isEmpty() && Status==Label.ppv_failure){
                    detailWrapper.isAdded=false;
                }
            }
        }
        catch(Exception e){
            detailWrapper.isAdded=false;
            System.debug('Exception in saveToReservationPool'+e.getStackTraceString());
        }
        return detailWrapper;
    }
    //EDGE-145845-Kalashree Borgaonkar - Fix for Production incident-start
    public static void removePortinFromReservationPool(String accountid,String OppId){
        System.debug('in removePortinFromReservationPool:');
        List<cscfga__Product_Basket__c> bsktAcc = [Select id,Name from cscfga__Product_Basket__c where cscfga__Opportunity__c=:OppId];
        List<Number__c> numList ; 
        List<String> portInNumbers = new List<String>();
        List<Service_Qualification__c> sqList= [SELECT Service_Number__c  FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Added_to_CA_form__c=false AND Account__c = :accountId];
        for( Service_Qualification__c sq : sqList){
                portInNumbers.add(sq.Service_Number__c);
        }
        System.debug('portInNumbers: '+portInNumbers);
        numList = [SELECT id from Number__c where basket__c=: bsktAcc[0].id AND  type__C='Port In' AND service_number__c IN :portInNumbers]; 
        if(!numList.isEmpty()){
            delete numList;
        }
        System.debug('numList: '+numList);
    }
    //EDGE-145845-Kalashree Borgaonkar - Fix for Production incident- end
    
    /*-------------------------------------------------------- 
EDGE-90327
Method: getAuthorisedContacts
Description: Method to populate contacts in search input
Author:Kalashree Borgaonkar
--------------------------------------------------------*/ 
    @AuraEnabled
    public static List<AccountContactRelation> getContactsForSearch(String accountId,String oppId,String searchText){
        List<AccountContactRelation> acrList = null;  
        acrList = getAuthorisedContacts(accountId,oppId,searchText);
        return acrList;
    }
    
    public static List<AccountContactRelation> getAuthorisedContacts(String accountId,String oppId,String searchText){
        String searchKey = searchText + '%';
        System.debug('searchKey'+searchKey);
        List<OpportunityContactRole> oppContactlst =[SELECT Id,contactid FROM OpportunityContactRole opp where opportunityid=:oppId];
        System.debug('oppContactlst::'+oppContactlst);
        List<String> contactidList = new List<String>();
        for(OpportunityContactRole role : oppContactlst){
            contactidList.add(role.contactid);
        }
        system.debug('contactidList>>>>' + contactidList);
        List<AccountContactRelation> acrList = null;
        Map<String,String> contacMap = new Map<String,String> ();
        List<String> roleList=  system.Label.ACR_Roles.split(',');
        system.debug('roleList>>>>' + roleList);
        if(!contactidList.isEmpty()){
            if(searchKey == '%'){
                acrList = [SELECT ContactId,contact.name FROM AccountContactRelation WHERE ContactId IN :contactidList AND roles IN :roleList  AND accountid=:accountId];
            }
            else{
                acrList = [SELECT ContactId,contact.name FROM AccountContactRelation WHERE ContactId IN :contactidList AND roles IN :roleList AND contact.name LIKE :searchKey AND accountid=:accountId]; 
            }
            System.debug('acrList>>>>>>'+acrList);
        }
        return acrList;   
    }
    /*-------------------------------------------------------- 
EDGE-90327
Method: getPortInMsisdns
Description: Method to populate MSISDNs in search input
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    @AuraEnabled
    public static List<Service_Qualification__c> getPortInMsisdns(String accountId,String oppId,String searchText){
        List<Service_Qualification__c> sqList = null;
        //EDGE-130044 Starts here
        List<String> numberList=new List<String>();
        List<cscfga__Product_Basket__c> bsktAcc= [SELECT id,csordtelcoa__Basket_Stage__c,csbb__Account__c,cscfga__Opportunity__c FROM cscfga__Product_Basket__c where cscfga__Opportunity__c =:oppId ];
        //Retrieve List of port in Numbers reserved
        List<Number__c> numList = [SELECT id,Service_Number__c from Number__c where basket__c=: bsktAcc[0].id AND  type__C='Port In']; 
        if(!numList.isEmpty()){
            for(Number__c num:numList){
                numberList.add(num.Service_Number__c);
            }
        }
        System.debug(accountId + ' '+searchText);
        String searchKey = searchText + '%';
        if(searchKey == '%'){
            //Query change as a part of EDGE-130044:To retrieve list of SQ's which are  qualified,added in CA and not Reserved 
            sqList= [SELECT Service_Number__c FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Account__c = :accountId AND Added_to_CA_form__c=true AND Service_Number__c NOT IN :numberList];
        }
        else{
            sqList= [SELECT Service_Number__c FROM Service_Qualification__c WHERE Portability_Status__c = 'Y' AND Account__c = :accountId AND Added_to_CA_form__c=true AND Service_Number__c LIKE :searchKey AND Service_Number__c  NOT IN :numberList ];
        }
        System.debug('sqList:'+sqList);
        return sqList;
    }
    /*-------------------------------------------------------- 
EDGE-90327
Method: saveResponse
Description: Method to save PPV response 
Author:Kalashree Borgaonkar
--------------------------------------------------------*/
    public static Boolean saveResponse(String  responseCode,String externalid,String portNum,String contactId,String resourceId){
        Boolean isSaved = false;
        List<Customer_Authority_Form__c> cafList = [SELECT PPV_status__c,id,Account__c,Contact__c,Is_active__c,Customer_Authority_Form__c,Opportunity__c,Status__c FROM Customer_Authority_Form__c WHERE ID=:externalid];
        Customer_Authority_Form__c selfCaf = new Customer_Authority_Form__c();
        if(!cafList.isEmpty()){
            try{
                //EDGE-111382
                System.debug(responseCode+' responseCode.containsIgnoreCase:'+responseCode.containsIgnoreCase('Failed'));
                
                if(responseCode!=null && !responseCode.containsIgnoreCase('Failed')){
                    selfCaf.Contact__c = contactId;
                    selfCaf.MSISDN__c = portNum;
                }
                selfCaf.Status__c = responseCode;   
                selfCaf.PPV_status__c = getStatusValue(responseCode); 
                selfCaf.Opportunity__c = cafList[0].Opportunity__c;
                selfCaf.Customer_Authority_Form__c = cafList[0].id; 
                selfCaf.Type__c = 'PPV';
                selfCaf.Resource_Id__c = resourceId;
                selfCaf.Account__c = cafList[0].Account__c;
                isSaved = true;
                upsert selfCaf; 
            }
            catch(Exception e){
                isSaved = false;
                System.debug('Exception in save: '+e.getStackTraceString());
            }
            System.debug('isSaved'+isSaved);
        }
        
        return isSaved;   
    }
    
    //Wrapper to display details on UI
    public class BasketDetailsWrapper{
        @AuraEnabled
        public String basketNumber;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String activeCAF;
        @AuraEnabled
        public String accountid;
        @AuraEnabled
        public String oppId;
        @AuraEnabled
        public String status;
        public BasketDetailsWrapper( String basketNumber , String accountName, String activeCAF,String accountid, String oppId){
            this.basketNumber =basketNumber;
            this.accountName = accountName;
            this.activeCAF = activeCAF;
            this.accountid = accountid;
            this.oppId = oppId;
            
        } 
    }
    //Wrapper to retrieve details on UI
    public class ResponeWrapper{
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String code;
        public ResponeWrapper(String message,String code){
            this.message = message;
            this.code = code;
        }
    }
    
    public class PpvWrapper{
        public Boolean isAdded;
        public String BasketId;
    }
    
    /*-------------------------------------------------------- 
EDGE-90327
Method: getStatusValue
Description: Method to get relevant value from meta data 
Author:Kalashree Borgaonkar
--------------------------------------------------------*/    
    
    public static String getStatusValue(String responseCode){
        System.debug('responseCode: '+responseCode);
        String status = null;
        if(responseCode!=null){
            List<PpvStatus__mdt> statusMdt = [SELECT MapValue__c FROM PpvStatus__mdt WHERE PpvToolValue__c=:responseCode];
            if(!statusMdt.isEmpty()){
                status=statusMdt[0].MapValue__c;
            }  
        } 
        System.debug('status: '+status);
        return status;
    }
}
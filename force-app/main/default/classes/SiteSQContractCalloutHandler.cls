/* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Handler Class to : SiteSQContractCallout : This class is used to 
 *               Save response on object Service_Qualification__c
 * Revision :EDGE-105216 updated condition for upstreaam and downstream speed fields
 * 
 * *****************************************************************************/
public with sharing class SiteSQContractCalloutHandler {
    

    public Service_Qualification__c saveSQResponse(String addressId, SqResponseDTO responseDTO, String AccountId) {
        Service_Qualification__c serviceQ =null;
        
        Boolean isTechTypeFiber = false;
        String siteId = getSiteIdFromAdborid(addressId,AccountId);
        System.debug('siteId: '+siteId);
        List<Service_Qualification__c> serviceQList =new List<Service_Qualification__c>();
        Map<String,list<SqResponseDTO.ProviderResources>> proResourceMap= new Map<String,list<SqResponseDTO.ProviderResources>> ();
        Map<String,String> addrToSiteIdMap = new Map<String,String>();
        try{
            if(responseDTO!=null && responseDTO.data!=null){
                List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = responseDTO.data.serviceTypeQualifications;
                if(!srvQualificationList.isEmpty()){
                    for(SqResponseDTO.ServiceTypeQualifications sq: srvQualificationList){
                           
                            List<SqResponseDTO.ProviderResources> proResourceList = sq.providerResources;
                            List<SqResponseDTO.Characteristics> charList = sq.characteristics;
                            serviceQ = new Service_Qualification__c();
                            serviceQ.Address_ID__c = addressId;
                            serviceQ.Site__c = siteId;
                            serviceQ.Service_Type__c    =   sq.serviceType ;
                            serviceQ.Technology_Type__c =   sq.technologyType ;
                            Date Ready_for_Service_Date = Date.valueOf(sq.readyForServiceDate); 
                            serviceQ.Ready_for_Service_Date__c    =  Ready_for_Service_Date  ;
                            serviceQ.Serviceability_Class__c    =   sq.serviceabilityClass ;
                            serviceQ.Location_ID__c =   sq.locationId ;
                            serviceQ.CSA_ID__c  =   sq.csaId ;
                            serviceQ.Demand_Type__c =   sq.demandType ;
                            serviceQ.Status_Reason__c   =   sq.statusReason ;
                            serviceQ.Status__c  =   sq.status ;
                            serviceQ.Service_Transfer_Indicator__c  =   sq.serviceTransferIndicator ;
                            serviceQ.Copper_Pair_Indicator__c   =   sq.copperPairIndicator ;
                            proResourceMap.put(serviceQ.Technology_Type__c,proResourceList);
                            if(charList!=null && !charList.isEmpty()){
                                for(SqResponseDTO.Characteristics chars:charList){
                                    if(chars.name.containsIgnoreCase('Downstream')){//EDGE-105216
                                        serviceQ.Max_Downstream_Speed__c = chars.value;
                                    }
                                    if(chars.name.containsIgnoreCase('Upstream')){//EDGE-105216
                                        serviceQ.Max_Upstream_Speed__c = chars.value;
                                    }
                                }
                            }
                        
                        return serviceQ;
                        
                    }
                    
                }
            }
        }catch(Exception e){
            System.debug('error caught '+e.getLineNumber());
        }
        return null;
    }
    
    /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Save partial response into object : Service_Qualification_Provider_Resource__c
 * Revision :
 * 
 * *****************************************************************************/
   public void saveProviderResources(List<Service_Qualification__c> serviceQList,Map<String,HttpResponse> addressToResponseMap){
       Service_Qualification_Provider_Resource__c proRes;
       List<Service_Qualification_Provider_Resource__c> proResList = new List<Service_Qualification_Provider_Resource__c>();
        for(Service_Qualification__c sqRec : serviceQList){
            if(addressToResponseMap.containsKey(sqRec.Address_ID__c)){
                 HttpResponse res = addressToResponseMap.get(sqRec.Address_ID__c);
              if (res.getStatusCode() == 200) {
                       
                  SqResponseDTO responseDTO = SqResponseDTO.parse(res.getBody());
                  List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = responseDTO.data.serviceTypeQualifications;
                if(!srvQualificationList.isEmpty()){
                    for(SqResponseDTO.ServiceTypeQualifications sq: srvQualificationList){
                         List<SqResponseDTO.ProviderResources> proResourceList = sq.providerResources;
                        for(SqResponseDTO.ProviderResources sqpr:  proResourceList){
                           if(sqpr.resourceType!=null && 'Copper Pair'.equalsIgnoreCase(sqpr.resourceType)){
                    proRes = new Service_Qualification_Provider_Resource__c ();
                   
                    proRes.Copper_Pair_ID__c    =   sqpr.id ;
                    proRes.Copper_Pair_Status__c    =   sqpr.status ;
                    proRes.Copper_Pair_SC__c    =   sqpr.serviceabilityClass;
                    proRes.Service_Qualification__c = sqRec.id;
                    proResList.add(proRes);
                           } 
                        }
                    }
                }
              } 
            }
            
            
        }
        
         if(!proResList.isEmpty()){
                insert proResList;
            }
        
    }
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description : Save partial response into object : Service_Qualification_Resource_Detail__c
 * Revision :
 * 
 * *****************************************************************************/
    public void saveResourceDetail(List<Service_Qualification__c> serviceQList, SqResponseDTO responseDTO) {
        id fiberSQId;
        Service_Qualification_Resource_Detail__c srvResDtl = null;
        List<Service_Qualification_Resource_Detail__c> srvResDtlList =new List<Service_Qualification_Resource_Detail__c>();
        Service_Qualification_Port_Detail__c srvPortDtl;
        List<Service_Qualification_Port_Detail__c> portDtlList;
        List<Service_Qualification_Port_Detail__c> portDtlMasterList = new List<Service_Qualification_Port_Detail__c>();
        map<string, List<Service_Qualification_Port_Detail__c>> mpPortDetails = new map<string, List<Service_Qualification_Port_Detail__c>>();
        List<SqResponseDTO.ResourceDetails> srvResDtlLst = responseDTO.data.resourceDetails;
        if(!srvResDtlLst.isEmpty()){    
            for(Service_Qualification__c sq: serviceQList){
                if(sq.Service_Type__c.equalsIgnoreCase('Internet') && sq.Technology_Type__c.Contains('Fibre'))
                    fiberSQId = sq.id;
            }
            
            for(SqResponseDTO.ResourceDetails rs: srvResDtlLst){
                srvResDtl = new Service_Qualification_Resource_Detail__c();
                if(rs.powerSupplyWithBatteryBackupInstallDate != null)
                    srvResDtl.Battery_Backup_Install_Date__c = Date.valueOf(rs.powerSupplyWithBatteryBackupInstallDate.substring(0,10));
                srvResDtl.Battery_Power_Unit_Monitored__c = rs.batteryPowerUnitMonitored;
                srvResDtl.NTD_ID__c = rs.ntdId;
                srvResDtl.NTD_Location__c = rs.ntdLoc;
                srvResDtl.NTD_Power_Type__c = rs.ntdPowerType;
                srvResDtl.NTD_Type__c = rs.ntdType;
                srvResDtl.Service_Qualification__c = fiberSQId;                 
                srvResDtlList.add(srvResDtl);
                if(!rs.portDetails.isEmpty()){
                    portDtlList = new List<Service_Qualification_Port_Detail__c>();
                    for(SqResponseDTO.PortDetails pd: rs.portDetails){
                        srvPortDtl = new Service_Qualification_Port_Detail__c();
                        srvPortDtl.Port_ID__c = pd.portId;
                        srvPortDtl.Port_Status__c = pd.portStatus;
                        srvPortDtl.Uni_Port_Type__c = pd.uniPortType;
                        portDtlList.add(srvPortDtl);
                    }
                    mpPortDetails.put(rs.ntdId, portDtlList);
                }
            }
            insert srvResDtlList;
            if(mpPortDetails.size()>0){
                for(Service_Qualification_Resource_Detail__c rd: srvResDtlList){
                    if(rd.NTD_ID__c != null){
                        for(Service_Qualification_Port_Detail__c pd: mpPortDetails.get(rd.NTD_ID__c)){
                            pd.Service_Qualification_Resource_Detail__c = rd.id;
                            portDtlMasterList.add(pd);
                        }
                    }
                }
                insert portDtlMasterList;
            }
        }
    }
    
     /* ****************************************************************************
 * Author : Manoj Kumar : EDGE-66038
 * Date : 22 March 2019
 * Description :Fetch site id from adboreId
 * Revision :
 * 
 * *****************************************************************************/
    
     public String getSiteIdFromAdborid(String addressId, String AccountId){ 
        List<cscrm__Site__c> siteid; 
        
            siteid = [select id from cscrm__Site__c  WHERE  AdborID__c = :addressId AND cscrm__Account__c =:AccountId];
         
        System.debug('siteid '+siteid +addressId);
        if(siteid !=null){
            try{
            return siteid[0].id;
            }
            catch(Exception e){
                
            }
        }
        return null;
    }
     

}
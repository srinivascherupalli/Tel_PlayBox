/*
Story No    | Status   | Name
EDGE - 67863| Created  | Kalashree Borgaonkar
DIGI - 776  | Modified | Akshay G (Istanbul) - Mapped extra fields in Service Qualification, 
                         Service Qualification Provider Resource and Service Qualification Details objects.
DIGI-2540   | Modified | Ajith Kumar - Code Refactoring changes
                         Service Qualification Provider Resource and Service Qualification Details objects. 
DIGI - 6700 | Modified | Ajith Kumar - Adding addtional Parameter to callSQService method Payload.
DIGI - 333  | Modified | Ajith Kumar - Mapping the new fields for carriage solutions.
DIGI-26084  | Modified | Ajith Kumar - Added Null Pointer Check along with isEmpty Check
DIGI-29002  | Modified | Sowmya      - Mapping the new fields for carriage solutions and updating the status of 
                         service qualification.
*/
    
    //This class is used to initiate SQ check callout
    public without sharing class SQcheckCalloutHandler implements Queueable, Database.AllowsCallouts{
        public static final String handler =  'SiteSQAddressHandler';
        public static final String sqHandler ='WidefeasSQAddressHandler';
        Logger2 logger = Logger2.getLogger(handler);
        public static NBNAttributeWrapper nbnAttributes;
        List<String> addressidList=new List<String>();
        public String accId ='';
        public Id selSiteId =null;
        public Boolean isManualCall = false;
        public string resultStr = 'success';
        public string displayTechType ='';// P2OB-7333 to differenciate between NBN Fibre and NBN Ethernet
        public string siteId;
        public Boolean isTechTypeFiber = false;
        List<Service_Qualification__c> serviceQList =new List<Service_Qualification__c>();
        Map<String,String> addrToSiteIdMap = new Map<String,String>(); 
        Service_Qualification__c serviceQ =new Service_Qualification__c();
        public SQcheckCalloutHandler(List<String> addressidList,String accId){
            this.addressidList = addressidList;
            this.accId=accId;
        }
        // P2OB-7333 to differenciate between NBN Fibre and NBN Ethernet
        public SQcheckCalloutHandler(List<String> addressidList,String siteId, Boolean isManualCall,String displayTechType){
            this.addressidList = addressidList;
            this.selSiteId=siteId;
            this.isManualCall = isManualCall;
            this.displayTechType = displayTechType;
        } 

    public void execute(QueueableContext context) {
        String token = AuthenticationManager.getOauthToken(handler);
        callSQService(token,'');
    }
    public string syncExecute(String techType) {
        //EDGE-98319
            String token='';
            if(techType == Label.Telstra_Fibre){
                token= AuthenticationManager.getOauthToken(sqHandler);
            }
            else{
                token = AuthenticationManager.getOauthToken(handler);
                }
        try{
            SqResponseDTO responseDTO  = callSQService(token,techType);
            if(responseDTO!=null && responseDTO.data!=null ){
                resultStr = 'success';
            }else{
                resultStr = 'fail';
            }
        }
        catch(exception ex){
            return ex.getMessage() +';'+ex.getLineNumber();                
        }
        return resultStr;
    }
    /*------------------------------------------------------		
    EDGE -98319
    Name: callSQService
    Description: callout method for SQcheck
    Author:Aishwarya
    --------------------------------------------------------------*/
    public SqResponseDTO callSQService(String token,String techType){
        SqResponseDTO responseDTO =new SqResponseDTO();        
        String correlationId=EDISSingleManager.getUID();
        HttpResponse response = new HttpResponse();
        String payload = '';
        String profileId='enterprise';
        Map<String,SqResponseDTO> mapResponseDTO =new Map<String,SqResponseDTO>();
        // P2OB-7333 to set serviceFilter value for NBN Fibre and NBN Ethernet
        String serviceFilter = '';
        Boolean tc2Required=false;
        if(displayTechType.equalsIgnoreCase('NBN Fibre')){
                serviceFilter='Internet';
                tc2Required=true;            
        }
        else 
            { serviceFilter='Enterprise Ethernet';} //For NBN Ethernet
        // add more parameter here wrt to ethernet 
        Long requestTime;
        Map<String,HttpResponse> addressToResponseMap = new Map<String,HttpResponse>();
        try{    
            for(String address:addressidList){
                if(displayTechType.equalsIgnoreCase(Label.Telstra_Fibre)){
                    payload = 'addressId='+address+'&profileId='+profileId;
                }
                else{
                    payload = 'addressId='+address+'&serviceFilter='+serviceFilter+'&tc2Required='+tc2Required;
                }
                Map<String,String> headerMap = new Map<String, String>{'Content-Type' => 'application/json','Authorization'=> 'Bearer ' + token,'correlationId'=> +correlationId};
                DateTime startTime = DateTime.now();
                if(displayTechType.equalsIgnoreCase(Label.Telstra_Fibre)){
                    response = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,sqHandler,null, null);
                }
                else{
                    response = IntegrationRecordHandlerUtil.callout(payload,'GET',headerMap,handler,null, null);
                }
                DateTime endTime = DateTime.now();
                requestTime = Logger.getRequestTimeDifference(startTime, endTime);
                String responseCode = String.valueOf(response.getStatusCode());
                addressToResponseMap.put(address,response);
            }
            if(addressToResponseMap != null && !addressToResponseMap.isEmpty()){
                for(String addId: addressToResponseMap.keyset()){
                    HttpResponse res = addressToResponseMap.get(addId);
                    if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 202) {
                        responseDTO = SqResponseDTO.parse(res.getBody());
                        //DIGI-2540 Created Map of address and SQResponse
                        mapResponseDTO.put(addID,responseDTO);
                        logger.logMessages(payload, res.getBody(), '', '', '', 
                                '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);                           
                                                       
                    }
                    else {
                        logger.logMessages(payload, res.getBody(), '', '', '', 
                                '', String.valueOf(res.getStatusCode()), correlationId, '','','','Create',requestTime ,'POST',false, false);
                    }
                    logger.exitLogger();
                }
                //DIGI-2540 Added if else condition to get the siteId from response map
                addrToSiteIdMap=getSiteIdFromAdborid(accid,mapResponseDTO.keyset());
                if(isManualCall){            
                    siteId = selSiteId;
                }
                if(!mapResponseDTO.isEmpty()){
                	saveSQResponse(mapResponseDTO);
                }
            }   
        }catch (Exception e) {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            resultStr = e.getMessage();
        }         
        return responseDTO;
    }
    //DIGI-2540 Changed the string method to map 
    public Map<String,String> getSiteIdFromAdborid(String accid,Set<String> addressId){
        Map<String,String> siteAddressidMap=new Map<String,String>();
        for(cscrm__Site__c siteObj:[SELECT id,AdborID__c FROM cscrm__Site__c  WHERE cscrm__Account__c = :accid AND AdborID__c IN :addressId ORDER BY Lastmodifieddate DESC]){
            siteAddressidMap.put(siteObj.AdborID__c,siteObj.Id);
        }
        return siteAddressidMap;
    }
    /*------------------------------------------------------		
    EDGE -98319
    Name: saveSQResponse
    Description: To save SQResponse in service qualification object
    Author:Aishwarya
    --------------------------------------------------------------*/
    public void saveSQResponse(Map<String,SqResponseDTO> mapResponseDTO) {
        List<SqResponseDTO.ProductDetails> productDetailsList =new List<SqResponseDTO.ProductDetails>();      
        try{
            Set<Service_Qualification__c> serviceQSet;
            List<Service_Qualification__c> serviceQualificationList = new List<Service_Qualification__c>();
            if(mapResponseDTO != null && !mapResponseDTO.isEmpty()){
                if(displayTechType.equalsIgnoreCase(Label.Telstra_Fibre)){
                    for(String addressId:mapResponseDTO.keySet()){                        
                        if(!isManualCall){
                            siteId = addrToSiteIdMap.get(addressId);
                        }
                        serviceQ = new Service_Qualification__c();
                        //Start DIGI-29002
                        serviceQSet = new Set<Service_Qualification__c>();
                        //End DIGI-29002
                        serviceQ.Address_ID__c = addressId;
                        serviceQ.Site__c = siteId;                    
                        List<SqResponseDTO.location> locationlist = mapResponseDTO.get(addressId).data.location;
                        if(locationlist != null && !locationlist.isEmpty()){
                            for(SqResponseDTO.location sq: locationlist){
                                serviceQ.Technology_Type__c = Label.Telstra_Fibre;
                                //Start DIGI-29002 
                                serviceQ.Status__c='Unavailable';
                                //End DIGI-29002
                                productDetailsList =sq.productDetails;
                                //Start DIGI-29002
                                serviceQSet.add(serviceQ);
                                //End DIGI-29002
                            }                       
                        }
                    }
         
                    //Start DIGI-29002
                    if(!serviceQSet.isEmpty()){ 
               
                        serviceQList.addall(serviceQSet);
                        for(Service_Qualification__c sq:serviceQList){
                            if(productDetailsList != null && !productDetailsList.isEmpty()){
                                for(SqResponseDTO.ProductDetails sqpr:  productDetailsList){
                            
                                    if(sqpr.maximumESABandwidth > 0 && sq.Technology_Type__c == Label.Telstra_Fibre)
                                    {
                                      sq.Status__c = 'Available';
                                    }
                                }
                                serviceQualificationList.add(sq);
                            }
                        }
                    //End DIGI-29002                 
                        insert serviceQualificationList;                    
                    }
                    if(displayTechType.equalsIgnoreCase(Label.Telstra_Fibre) && serviceQualificationList != null && !serviceQualificationList.isEmpty()){                
                        if(productDetailsList != null && !productDetailsList.isEmpty()){
                            saveCarriageSolution(productDetailsList,serviceQualificationList);
                        }
                    }
                }
                else if(displayTechType.equalsIgnoreCase('NBN Ethernet')){                    
                    saveNBNEtherenetSQ(mapResponseDTO);                   
                }                
                else if(displayTechType.equalsIgnoreCase('NBN Fibre')){
                    saveFibreSQResponse(mapResponseDTO);
                }    
            }          
        }catch(Exception e){
            resultStr = e.getMessage();
        }
    }

    /*------------------------------------------------------		
    DIGI -2540
    Name: saveFibreSQResponse
    Description: To save Fibre SQ Response in service qualification object
    Author:Ajith Kumar
    --------------------------------------------------------------*/
    public void saveFibreSQResponse(Map<String,SqResponseDTO> mapResponseDTO){  
    List<SqResponseDTO.CopperPairs> copperPairsList = new List<SqResponseDTO.CopperPairs>();
    Map<String,list<SqResponseDTO.ProviderResources>> proResourceMap= new Map<String,list<SqResponseDTO.ProviderResources>> ();
        try{
            for(String addressId:mapResponseDTO.keySet()){
                List<SqResponseDTO.ServiceTypeQualifications> srvQualificationList = mapResponseDTO.get(addressId).data.serviceTypeQualifications;
                SqResponseDTO.ScheduledDates scheduledDates = mapResponseDTO.get(addressId).data.scheduledDates;
                SqResponseDTO.OrderableTC2Capacity orderTC2Capacity = mapResponseDTO.get(addressId).data.orderableTC2Capacity;
                List<SqResponseDTO.AdditionalTrafficClassAvailability> addTrafficClassList = mapResponseDTO.get(addressId).data.additionalTrafficClassAvailability;
                    if(srvQualificationList != null && !srvQualificationList.isEmpty()){
                        if(!isManualCall){
                            siteId = addrToSiteIdMap.get(addressId);
                        }
                        for(SqResponseDTO.ServiceTypeQualifications sq: srvQualificationList){
                            //if display tech type is nbn fibre
                            if(sq.serviceType.equalsIgnoreCase('Internet')){
                                if(sq.technologyType.equalsIgnoreCase('Fibre'))
                                    isTechTypeFiber = true;
                                List<SqResponseDTO.ProviderResources> proResourceList = sq.providerResources;
                                List<SqResponseDTO.Characteristics> charList = sq.characteristics;
                                copperPairsList = sq.copperPairs;				
                                serviceQ.Address_ID__c = addressId;
                                serviceQ.Site__c = siteId;
                                serviceQ.Service_Type__c    =   sq.serviceType ;
                                serviceQ.Technology_Type__c =   sq.technologyType ;
                                if(sq.readyForServiceDate != null){
                                    Date Ready_for_Service_Date = Date.valueOf(sq.readyForServiceDate); 
                                    serviceQ.Ready_for_Service_Date__c    =  Ready_for_Service_Date  ;
                                }
                                serviceQ.Serviceability_Class__c    =   sq.serviceabilityClass ;
                                serviceQ.Location_ID__c =   sq.locationId ;
                                serviceQ.CSA_ID__c  =   sq.csaId ;
                                serviceQ.Demand_Type__c =   sq.demandType ;
                                serviceQ.Status_Reason__c   =   sq.statusReason ;
                                serviceQ.Status__c  =   sq.status ;
                                serviceQ.Service_Transfer_Indicator__c  =   sq.serviceTransferIndicator ;
                                serviceQ.Copper_Pair_Indicator__c   =   sq.copperPairIndicator ;
                                serviceQ.Appointment_Required__c  = sq.appointmentRequired;
                                /******DIGI - 776 Start *****/
                                serviceQ.NBN_TC1_Speed__c = '1Mbps';
                                if(scheduledDates != null && string.isNotBlank(scheduledDates.ceaseSaleDate)){
                                    serviceQ.Cease_Sale_Date__c = Date.valueof(scheduledDates.ceaseSaleDate);
                                }
                                //These values will only be populated if the TC2Required is set to true while sending the request
                                if(orderTC2Capacity != null && string.isNotBlank(orderTC2Capacity.maxBackhaul)){
                                    serviceQ.Max_Backhaul__c = orderTC2Capacity.maxBackhaul;
                                }
                                if(orderTC2Capacity != null && string.isNotBlank(orderTC2Capacity.maxSpareCopperPair)){        
                                    serviceQ.Max_Spare_Copper_Pair__c = orderTC2Capacity.maxSpareCopperPair;
                                }
                                if(addTrafficClassList != null && !addTrafficClassList.isEmpty()) {
                                    for(SqResponseDTO.AdditionalTrafficClassAvailability tc : addTrafficClassList){
                                        if(tc.name.containsIgnoreCase('NCAS TC1 High Speed Tiers (greater or equal to 2Mbps)') && tc.value == 'Yes'){
                                            serviceQ.NBN_TC1_Speed__c = '5Mbps';
                                        }
                                    }
                                }                                                                         
                                /******DIGI - 776 End *****/
                                if(proResourceList != null && !proResourceList.isEmpty())
                                    proResourceMap.put(serviceQ.Technology_Type__c,proResourceList);
                                if(charList != null && !charList.isEmpty()){
                                    for(SqResponseDTO.Characteristics chars:charList){
                                        if(chars.name.containsIgnoreCase('Downstream')){
                                            serviceQ.Max_Downstream_Speed__c = chars.value;
                                        }
                                        if(chars.name.containsIgnoreCase('Upstream')){
                                            serviceQ.Max_Upstream_Speed__c = chars.value;
                                        }
                                    }
                                }
                                nbnAttributeMapping();                                 
                            }
                            
                            serviceQList.add(serviceQ);
                        }                     
                    }
            }
            if(!serviceQList.isEmpty()){                    
                insert serviceQList;                    
            }   	
            if(!proResourceMap.isEmpty())
            // DIGI- 776: Added a parameter(copperPairsList) to pass the CopperPairs value
                saveProviderResources(proResourceMap,serviceQList,copperPairsList);				
                if(isTechTypeFiber)
                    saveResourceDetail(serviceQList, mapResponseDTO);   
            
        }
        catch(Exception e){
                resultStr = e.getMessage();
        }
    }
    /*------------------------------------------------------		
    DIGI -2540
    Name: saveNBNEtherenetSQ
    Description: To save NBN Ethernet Response in service qualification object
    Author:Ajith Kumar
    --------------------------------------------------------------*/
    public void saveNBNEtherenetSQ(Map<String,SqResponseDTO> mapResponseDTO){
        try{
            for(String addressId:mapResponseDTO.keySet()){
                List<SqResponseDTO.ServiceTypeQualifications> serviceQualificationList = mapResponseDTO.get(addressId).data.serviceTypeQualifications;
                if(serviceQualificationList != null && !serviceQualificationList.isEmpty()){
                    if(!isManualCall){
                        siteId = addrToSiteIdMap.get(addressId);
                    }
                    for(SqResponseDTO.ServiceTypeQualifications sq: serviceQualificationList){
                        if(sq.serviceType.equalsIgnoreCase('Enterprise Ethernet Access Service')){
                                            // P2OB-7333 saving response for NBN Ethernet 
                                            //For NBN Ethernet Service type = Enterprise Ethernet Access Service								
                                            serviceQ.Address_ID__c = addressId;
                                            serviceQ.Site__c = siteId;
                                            serviceQ.SQ_Type__c = 'Address SQ';
                                            serviceQ.Status__c  =   sq.status ;
                                            serviceQ.Technology_Type__c =   sq.serviceType ;
                                            serviceQ.Location_ID__c =   sq.locationId ;
                                            if(string.isNotBlank(sq.estimatedAvailabilityDate)){
                                                serviceQ.NBN_Estimated_Availability_Date__c = Date.valueOf(sq.estimatedAvailabilityDate); //DIGI - 776            
                                            }
                                        
                                            if(sq.estimatedAvailabilityDate != null && sq.status.equalsIgnoreCase('Unavailable')){
                                                Date Ready_for_Service_Date = Date.valueOf(sq.estimatedAvailabilityDate); 
                                                serviceQ.Ready_for_Service_Date__c    =  Ready_for_Service_Date  ;
                                            }
                                            serviceQ.Service_Type__c    =   'Internet' ;
                                            serviceQ.Status_Reason__c   = 'NBN Enterprise Ethernet is '+  sq.status ;
                        }
                        serviceQList.add(serviceQ);
                    }
                    if(!serviceQList.isEmpty()){                    
                        insert serviceQList;                    
                    }
                }
            }    
        }
        catch(Exception e){
                resultStr = e.getMessage();
        }
    }

    /*------------------------------------------------------		
    DIGI -2540
    Name: nbnAttributeMapping
    Description: To map NBN Attributes with the SQ 
    Modified:Ajith Kumar
    --------------------------------------------------------------*/
    public void nbnAttributeMapping(){
        //Added by shubhi for NBN SQ  attribute mapping EDGE-65964
        nbnAttributes=new NBNAttributeWrapper(); 
        nbnAttributes.adbordID = serviceQ.Address_ID__c;
        if(serviceQ.Status__c=='Available'){
            nbnAttributes.NBNAvailability='Available';
        }else{
            nbnAttributes.NBNAvailability='Not Available';
        }
        nbnAttributes.NBNRFSDate=String.valueOf(serviceQ.Ready_for_Service_Date__c); 
        if(serviceQ.Technology_Type__c=='Fibre To The Node'){
            nbnAttributes.NBNTechnologyType='FTTN';
        }else if(serviceQ.Technology_Type__c=='Fibre To The Building'){
            nbnAttributes.NBNTechnologyType='FTTB';
        }else if(serviceQ.Technology_Type__c=='Fibre To The Curb'){
            nbnAttributes.NBNTechnologyType='FTTC';
        }else if(serviceQ.Technology_Type__c=='Fibre To The Premise'){
            nbnAttributes.NBNTechnologyType='FTTP';
        }else if(serviceQ.Technology_Type__c=='Fibre'){
            nbnAttributes.NBNTechnologyType='FTTP';
        }else if(serviceQ.Technology_Type__c=='Wireless'){
            nbnAttributes.NBNTechnologyType='Fixed Wireless';
        }else {
            nbnAttributes.NBNTechnologyType=serviceQ.Technology_Type__c;                                
        }
        nbnAttributes.MaxUploadSpeed=serviceQ.Max_Downstream_Speed__c;
        nbnAttributes.MaxDownloadSpeed=serviceQ.Max_Upstream_Speed__c;          
        nbnAttributes.serviceabilityClass=serviceQ.Serviceability_Class__c;
        nbnAttributes.copperPairIndicator = serviceQ.Copper_Pair_Indicator__c;
        //end EDGE-65964
    }

    /*------------------------------------------------------		
    EDGE -98319
    Name: saveCarriageSolution
    Description: To save product details in carriage solution object
    Author:Aishwarya
    --------------------------------------------------------------*/
    public void saveCarriageSolution(List<SqResponseDTO.ProductDetails> productDetailList,List<Service_Qualification__c> serviceQList){
        Carriage_Solutions__c  carrSolution;
        List<Carriage_Solutions__c> carrSolutionList = new List<Carriage_Solutions__c>();
        //List<Service_Qualification__c> serviceQualificationList = new List<Service_Qualification__c>();
        try{
            if(serviceQList != null && !serviceQList.isEmpty()){
                for(Service_Qualification__c sq:serviceQList){
                    if(productDetailList != null && !productDetailList.isEmpty()){
                        for(SqResponseDTO.ProductDetails sqpr:  productDetailList){
                                carrSolution = new Carriage_Solutions__c ();
                                carrSolution.Name    =   sqpr.carriageSolution;
                                carrSolution.carriageSolutionStatus__c    = sqpr.carriageSolutionStatus;
                                carrSolution.carriageSolutionReasonCode__c  = sqpr.carriageSolutionReasonCode;
                                carrSolution.maximumESABandwidth__c = sqpr.maximumESABandwidth;
                                carrSolution.maximumDeviceBandwidth__c =sqpr.maximumDeviceBandwidth;
                                carrSolution.interfaceType__c = sqpr.interfaceType;
                                //DIGI-333 mapping the new fields
                                carrSolution.spareSlotIndicator__c=Boolean.valueOf(sqpr.spareSlotIndicator);//DIGI-333 converting string to boolean
                                carrSolution.deviceBuildIndicator__c=sqpr.deviceBuildIndicator;
                                carrSolution.Service_Qualification__c=sq.id;
                                //Start DIGI-29002 mapping the new fields
                                carrSolution.Device_Type__c = sqpr.deviceType;
                                carrSolution.Device_Domain__c = sqpr.deviceDomain;
                                carrSolution.Unified_Access__c  = sqpr.unifiedAccess;
                                carrSolution.Device_Migration__c   = sqpr.deviceMigration;
                                //End DIGI-29002 mapping the new fields
                                carrSolutionList.add(carrSolution);
                                
                        }
                    }
              
                }
            }
            
            if(!carrSolutionList.isEmpty()){
                    insert carrSolutionList;                   
                }
        }
        catch(Exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            resultStr = e.getMessage();
        }
    }
    public void saveProviderResources(Map<String,List<SqResponseDTO.ProviderResources>> proResourceMap,List<Service_Qualification__c> serviceQList, List<SqResponseDTO.CopperPairs> copperPairsList){
        Service_Qualification_Provider_Resource__c proRes;
        List<Service_Qualification_Provider_Resource__c> proResList = new List<Service_Qualification_Provider_Resource__c>();
        try{ 
            if(!serviceQList.isEmpty()){
                for(Service_Qualification__c sq:serviceQList){
                    if(proResourceMap.keySet().contains(sq.Technology_Type__c)){
                        for(SqResponseDTO.ProviderResources sqpr:  proResourceMap.get(sq.Technology_Type__c)){
                            if(sqpr.resourceType!=null && 'Copper Pair'.equalsIgnoreCase(sqpr.resourceType)){
                                proRes = new Service_Qualification_Provider_Resource__c ();
                                proRes.Copper_Pair_ID__c    =   sqpr.id ;
                                proRes.Copper_Pair_Status__c    =   sqpr.status ;
                                proRes.Copper_Pair_SC__c    =   sqpr.serviceabilityClass;
                                proRes.Service_Qualification__c = sq.id;
                                /******DIGI - 776 Start *****/
                                proRes.Resource_Type__c = sqpr.resourceType;
                                proRes.Copper_Path__c = sqpr.id;
                                proRes.SIC_Indicator__c = sqpr.sicIndicator;
                                proRes.SIC_Code__c = sqpr.sicCode;
                                proRes.SIC_Reason__c = sqpr.sicReason;
                                /******DIGI - 776 End *****/
                                proResList.add(proRes);
                            }else{
                                /******DIGI - 776 Start *****/
                                if(copperPairsList != null && !copperPairsList.isEmpty()){
                                    for(SqResponseDTO.CopperPairs cp : copperPairsList){
                                        proRes.Copper_Path__c = cp.id;
                                    }
                                }
                                /******DIGI - 776 End *****/
                            }   
                        }
                    }
                }
            }
            if(!proResList.isEmpty()){
                    insert proResList;
                }
            }
            catch(Exception e){
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
                logger.exitLogger();
                resultStr = e.getMessage();
            }
        }
        public void saveResourceDetail(List<Service_Qualification__c> serviceQList, Map<String,SqResponseDTO> mapResponseDTO) {
            id fiberSQId;
            Service_Qualification_Resource_Detail__c srvResDtl = null;
            List<Service_Qualification_Resource_Detail__c> srvResDtlList =new List<Service_Qualification_Resource_Detail__c>();
            Service_Qualification_Port_Detail__c srvPortDtl;
            List<Service_Qualification_Port_Detail__c> portDtlList;
            List<Service_Qualification_Port_Detail__c> portDtlMasterList = new List<Service_Qualification_Port_Detail__c>();
            map<string, List<Service_Qualification_Port_Detail__c>> mpPortDetails = new map<string, List<Service_Qualification_Port_Detail__c>>();            
            try{
                if(serviceQList != null && !serviceQList.isEmpty()){    
                    for(Service_Qualification__c sq: serviceQList){
                        if(sq.Service_Type__c.equalsIgnoreCase('Internet') && sq.Technology_Type__c.equalsIgnoreCase('Fibre'))
                            fiberSQId = sq.id;
                    }
                    for(String addresslst:mapResponseDTO.keySet()){
                        List<SqResponseDTO.ResourceDetails> srvResDtlLst = mapResponseDTO.get(addresslst).data.ResourceDetails;
                        if(!srvResDtlLst.isEmpty() && srvResDtlLst!=null ){
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
                                if(string.isNotBlank(rs.batteryPowerUnit)){
                                    srvResDtl.Battery_Power_Unit__c = boolean.valueof(rs.batteryPowerUnit); // DIGI - 776 
                                }               
                                srvResDtlList.add(srvResDtl);
                                if(rs.portDetails != null && !rs.portDetails.isEmpty()){
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
        catch(Exception e){
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            resultStr = e.getMessage();
        }
    }
        /*------------------------------------------------------    
    EDGE -98319
    Name: saveWidefeasSQResponse
    Description: To save saveWidefeasSQResponse in service qualification object
    Author:Aishwarya
    --------------------------------------------------------------*/
            public void saveWidefeasSQResponse(String addressId, WidefeaseSQResponseDTO responseDTO) {
                Service_Qualification__c serviceQ =null;
            // nbnAttributes=new NBNAttributeWrapper();
                Boolean isTechTypeFiber = false;
                String siteId;
                if(isManualCall)
                    siteId = selSiteId;
                else
                     addrToSiteIdMap=getSiteIdFromAdborid(accid,new Set<String>{addressId}); //EDGE-75272 Bug. To associate a SQ response with a site.
                    siteId =  addrToSiteIdMap.get(addressId);
                List<Service_Qualification__c> serviceQList =new List<Service_Qualification__c>();
                List<WidefeaseSQResponseDTO.ProductDetails> productDetailsList =null;
                // Map<String,list<WidefeaseSQResponseDTO.ProductDetails>> productDetailsMap= new Map<String,list<WidefeaseSQResponseDTO.ProductDetails>> ();
                Map<String,String> addrToSiteIdMap = new Map<String,String>();
                try{
                    if(responseDTO!=null && responseDTO.data!=null){
                        List<WidefeaseSQResponseDTO.location> locationlist = responseDTO.data.location;
                        if(locationlist != null && !locationlist.isEmpty()){
                        for(WidefeaseSQResponseDTO.location sq: locationlist){
                                serviceQ = new Service_Qualification__c();
                                serviceQ.Address_ID__c = addressId;
                                serviceQ.Site__c = siteId;
                                serviceQ.Technology_Type__c = Label.WidefeasSQ;
                                serviceQ.Status__c=sq.fibreAvailabilityStatus;
                                serviceQ.Status_Reason__c=sq.fibreAvailabilityReasonCode;
                                productDetailsList = sq.productDetails;
                                /*if(productDetailsList != null && !productDetailsList.isEmpty()){
                                    productDetailsMap.put(serviceQ.Technology_Type__c,productDetailsList);
                                }*/
                                serviceQList.add(serviceQ);
                    	}
                    	if(serviceQList != null && !serviceQList.isEmpty()){
                                insert serviceQList;
                            }
                            if(productDetailsList != null && !productDetailsList.isEmpty()){
                            	saveCarriageSolution(productDetailsList,serviceQList);
                            }
                }
                    }
            }
                catch(Exception e){
                    resultStr = e.getMessage();
                }
            }
        /*------------------------------------------------------    
    EDGE -98319
    Name: saveCarriageSolution
    Description: To save product details in carriage solution object
    Author:Aishwarya
    --------------------------------------------------------------*/
            public void saveCarriageSolution(List<WidefeaseSQResponseDTO.ProductDetails> productDetailList,List<Service_Qualification__c> serviceQList){
                Carriage_Solutions__c  carrSolution;
                List<Carriage_Solutions__c> carrSolutionList = new List<Carriage_Solutions__c>();
                for(Service_Qualification__c sq:serviceQList){
                    if(productDetailList !=Null){
                        for(WidefeaseSQResponseDTO.ProductDetails sqpr:  productDetailList){
                                carrSolution = new Carriage_Solutions__c ();
                                carrSolution.Name    =   sqpr.carriageSolution;
                                carrSolution.carriageSolutionStatus__c    = sqpr.carriageSolutionStatus;
                                carrSolution.carriageSolutionReasonCode__c  = sqpr.carriageSolutionReasonCode;
                                carrSolution.maximumESABandwidth__c = sqpr.maximumESABandwidth;
                                carrSolution.maximumDeviceBandwidth__c =sqpr.maximumDeviceBandwidth;
                                carrSolution.interfaceType__c = sqpr.interfaceType;
                                carrSolution.Service_Qualification__c=sq.id;
                                carrSolutionList.add(carrSolution);
                        }
                    }
                }
                if(carrSolutionList != null && !carrSolutionList.isEmpty()){
                        insert carrSolutionList;
                    }
            }
        //added for EDge-65964
    public Class NBNAttributeWrapper{
        public String adbordID  {get; set;}
        public String NBNAvailability {get; set;}
        public String NBNRFSDate {get; set;} 
        public String NBNTechnologyType {get; set;}
        //public String BandwidthType {get; set;}
        public String MaxUploadSpeed {get; set;}
        public String MaxDownloadSpeed {get; set;}          
        public String serviceabilityClass {get; set;}
        public String copperPairIndicator {get; set;}
    }
}
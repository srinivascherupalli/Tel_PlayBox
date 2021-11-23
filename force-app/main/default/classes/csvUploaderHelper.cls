public class csvUploaderHelper {
    //Start of DIGI-1742: Added by Abhishek(Osaka) to make display messages/Profile Names configurable.
    public static Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
    public static List<String> profileNamesList = String.valueOf(MTMMetadataUtilityMap.get('Profile_Names').get('Value__c')).split(',');
    //End of DIGI-1742: Added by Abhishek(Osaka) to make display messages/Profile Names configurable.
    
    public static String saveFile(String base64Data,String basketId, Boolean nextFlag) {
        System.debug('base64Data: '+base64Data);
        String response='';
        boolean isSuccess = true;
        //Start of EDGE-201124:Hardstop if CIDN is not part of hierarchy
        Id profile_id=userinfo.getProfileId();
        String profile_name = [select Name from Profile where id = :profile_id].Name;
        boolean applicableMultiCIDNValidation = getProfileInfoForSalesUser();
        String currentBasketCIDN = getCurrentBasketCIDN(basketId);
        Set<String> hierarchicalCIDNList = checkForCIDNHierarchy(basketId);
        //End of EDGE-201124
        //START OF EDGE-189357 by Abhishek from Osaka Team
        TransitionSelectContoller.DetailsWrapper detailWrap =TransitionSelectContoller.getServiceType(basketId);
        String accCIDN = detailWrap.accountCIDN; 
        if(nextFlag == true && base64Data ==  null){
            System.debug('Inside Empty file');
            //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
            response = String.valueOf(MTMMetadataUtilityMap.get('Empty_File').get('Value__c'));
        }
        //END OF EDGE-189357 by Abhishek from Osaka Team
        else{
            String data= JSON.deserializeUntyped(base64Data).toString();
            list<Legacy_Service__c> lstlegacyserviceToInsert = new list<Legacy_Service__c>();
            list<String> lstCSVLines = data.split('\n');
            system.debug('lstCSVLines>>>'+lstCSVLines);
            system.debug('lstCSVLines.size>>>'+lstCSVLines.size());
            Set<String> setcidn = new Set<String>();
            Map<String,String> mapServiceid = new Map<String,String>();
            List<String> lstcolumnHeaders = lstCSVLines[0].split(',');
            List<String> nonCIDNList = new List<String>();
            system.debug('lstcolumnHeaders>>>'+lstcolumnHeaders + '====' + lstcolumnHeaders.size());
            For(String header : lstcolumnHeaders){
                system.debug('header>>>>'+String.isBlank(header));
                if(header == null || header == '' || String.isBlank(header)){
                    system.debug('header>>>>'+header);
                    //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                    //response = 'Some or all key details (Service ID, CIDN, Product Family) are missing.';
                    response = String.valueOf(MTMMetadataUtilityMap.get('Header_Missing').get('Value__c'));
                    isSuccess = false;
                    return response;
                }
            }
            Set<String> setofferDetails = getOfferdetails(basketId);
            system.debug('lstCSVLines>>>>>'+lstCSVLines.size());
            for(Integer i = 1; i < lstCSVLines.size(); i++){
                Legacy_Service__c legacyservice = new Legacy_Service__c();
                String csvLine = lstCSVLines[i];
                String prevLine = csvLine;
                Integer startIndex;
                Integer endIndex;
                system.debug('csvLine>>>'+csvLine);
                /*  while(csvLine.indexOf('"') > -1){   
system.debug('in while');
if(startIndex == null){
system.debug('startIndex: '+startIndex);
startIndex = csvLine.indexOf('"');
csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
}else{
if(endIndex == null){
system.debug('endIndex: '+endIndex);
endIndex = csvLine.indexOf('"');
csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
}
}

if(startIndex != null && endIndex != null){
system.debug('here: '+endIndex);
String sub = csvLine.substring(startIndex, endIndex);
sub = sub.replaceAll(',', ':comma:');
csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
startIndex = null;
endIndex = null;
}
}*/
                
                List<String> csvRowData = new List<String>();
                for(String column : csvLine.split(',')){
                    column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
                    system.debug('column>>>'+column);
                    csvRowData.add(column);
                }
                //START OF EDGE-189357 by Abhishek from Osaka Team
                if(nextFlag == true){
                    if(csvRowData[1].trim() != accCIDN ){
                        nonCIDNList.add(csvRowData[1]);
                        System.debug('nonCIDNList ' + nonCIDNList);
                    }
                    //Start of EDGE-201124:Bypassing multiCIDN validation for Sales and Assurance User- Added additional condition
                    if(nonCIDNList.size()>0 && applicableMultiCIDNValidation){
                        //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                        //response = 'This CSV file contains service IDs associated to multiple CIDNs. Only Legacy details for Services associated to '+accCIDN+' will be retrieved.';
                        response = String.valueOf(MTMMetadataUtilityMap.get('MultipleCIDN_Validation').get('Value__c')).replace('AccountCIDN',accCIDN);
                    }
                    //End of EDGE-201124
                }
                //END OF EDGE-189357 by Abhishek from Osaka Team
                else{
                    System.debug('csvRowData[1] ' + csvRowData[1]);
                    if(csvRowData[1] == null || csvRowData[1] == ''){
                        response = String.valueOf(MTMMetadataUtilityMap.get('CIDN_not_Blank').get('Value__c'));
                        return response;
                    }
                    //Start of EDGE-201124:Hardstop if CIDN is not part of hierarchy
                    else{
                        if(!hierarchicalCIDNList.contains(csvRowData[1])){
                            System.debug('Inside multiple CIDNList');
                            //DIGI-1742 Added by Abhishek(Osaka) to make Profile Names configurable.
                            //if(profile_name =='Sales-Enterprise-Unified' || profile_name =='Assurance Service Agent' || profile_name == 'System Administrator'){
                            if(profileNamesList.contains(profile_name)){
                                response = String.valueOf(MTMMetadataUtilityMap.get('CIDN_not_in_Hierarchy').get('Value__c'));
                                return response;
                            }
                        }
                        //End of EDGE-201124
                    }
                    if(csvRowData[0] == null || csvRowData[0] == ''){
                        //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                        //response = 'Service Id value can not blank.';
                        response = String.valueOf(MTMMetadataUtilityMap.get('ServiceId_Validation').get('Value__c'));
                        return response;
                    }
                    setcidn.add(csvRowData[1]);
                    
                    mapServiceid.put(csvRowData[0], csvRowData[1]);
                    legacyservice.Product_Basket__c		= basketId;
                    legacyservice.Service_Id__c			= csvRowData[0];
                    legacyservice.Product_Type__c		= csvRowData[2];
                    /*if(!csvRowData[0].startsWith('61') || csvRowData[0].length() != 11){
                    response = 'Number should start with 61 or has to be 11 digits';
                    return response;
                    }*/
                    system.debug('csvRowData>>>>'+csvRowData[2].trim());
                    if(!setofferDetails.contains(csvRowData[2].trim())){
                        //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                        //response = 'The Product Family in the CSV file does not match the Product Family of the offer in the basket.';
                        response = String.valueOf(MTMMetadataUtilityMap.get('Product_Family_Validation').get('Value__c'));
                        return response;
                    }
                    lstlegacyserviceToInsert.add(legacyservice);
                }
            }
            system.debug('lstlegacyserviceToInsert>>>>'+lstlegacyserviceToInsert);
            
            //Added this condition to not re-run the existing validations(which have already executed once on file upload) on the click on Next.
            system.debug('nextFlag>>>>'+nextFlag);
            system.debug('lstlegacyserviceToInsert>>>>'+lstlegacyserviceToInsert.size());
            if(nextFlag == false){ 
                
                if(lstCSVLines.size() > Integer.valueOf(System.Label.csvTransitionrecords)){
                    //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                    //response = 'Number of rows in the CSV file has exceeded the maximum limit.';
                    response = String.valueOf(MTMMetadataUtilityMap.get('NumberOfCSVRows_Validation').get('Value__c'));
                    return response;
                }
                boolean isCIDNMatched = false;
                if(!lstCSVLines.isEmpty() && !setcidn.isEmpty()){
                    Map<String,String> mapciddata = getCIDNwithAccoundId(setcidn);
                    for(Legacy_Service__c lservice:lstlegacyserviceToInsert){
                        if(mapServiceid.containsKey(lservice.Service_Id__c) && mapciddata.get(mapServiceid.get(lservice.Service_Id__c)) != null){
                            lservice.Account__c = mapciddata.get(mapServiceid.get(lservice.Service_Id__c));
                            isCIDNMatched = true;
                        }else{
                            //return 'Provided CIDN number is not present in the system:'+mapServiceid.get(lservice.Service_Id__c);
                        }                
                    }
                    if(isCIDNMatched == false){
                        //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                        //return 'There are no services related to CIDN# in the CSV file.';
                        return String.valueOf(MTMMetadataUtilityMap.get('NoService_Validation').get('Value__c'));
                    }
                    Schema.SObjectField ftoken = Legacy_Service__c.Fields.Service_Id__c;
                    System.debug('lstlegacyserviceToInsert final legacy services list' + lstlegacyserviceToInsert);
                    //Start of EDGE-198138: Jay from Osaka
                    // Collecting all legacy records
                    //Set<String> lstlegacyservice =getServiceList(lstlegacyserviceToInsert);
                    Map<String,List<Legacy_Service__c>> allServices = checkIfServiceDuplicate(lstlegacyserviceToInsert, basketId);
                    
                    //  Map<String,List<Legacy_Service__c>> allServices = checkIfServiceExisting(lstlegacyserviceToInsert, basketId);
                    
                    //List of Legacy records to be upserted
                    List<Legacy_Service__c> lsToBeUpserted = allServices.get('upsertServiceIds');
                    //Duplicate legacy records
                    List<Legacy_Service__c> duplicateLs = allServices.get('duplicateServiceIds');
                    //Collecting duplicate service Ids from existing legacy records
                    String duplicateServiceIds = checkForDuplicateServiceIds(duplicateLs);
                    //End of Start of EDGE-198138
                    Database.UpsertResult[] srList = Database.upsert(lsToBeUpserted,ftoken, false);
                    
                    for (Database.UpsertResult sr : srList) {
                        if (sr.isSuccess()) {
                            System.debug('Successfully inserted Invoice. Invoice ID: ' + sr.getId());
                        } else {
                            for(Database.Error objErr : sr.getErrors()) {
                                System.debug(objErr.getStatusCode() + ': ' + objErr.getMessage());
                                //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                                //response = 'Legacy Service insert affected by the error: ' + + objErr.getFields();
                                response = String.valueOf(MTMMetadataUtilityMap.get('Insert_Error').get('Value__c'))+''+ objErr.getFields();
                                isSuccess = false;
                                return response;
                            }
                        }
                    }
                    if(isSuccess){
                        //Start of EDGE-198138: Jay from Osaka
                        if(duplicateServiceIds != ''){
                            response = duplicateServiceIds;
                            System.debug('duplicateServiceIds ' + response);
                            //End of EDGE-198138
                        }else{
                            //DIGI-1742 Added by Abhishek(Osaka) to make display messages configurable.
                            //response = 'file uploaded successfully.';
                            response = String.valueOf(MTMMetadataUtilityMap.get('FileUpload_Success').get('Value__c'));
                        }
                    }
                }
            }
        }
        return response;
    }
    
    public Static map<String, String> getCIDNwithAccoundId(Set<String> setcidn){
        
        Map<String,String> mapcidnAccount = new Map<String,String>();
        for(Account acc : [SELECT id,CIDN__c FROM Account WHERE CIDN__c IN:setcidn]){
            mapcidnAccount.put(acc.CIDN__c, acc.Id);
        }
        return mapcidnAccount;
    }
    public Static set<String> getOfferdetails(String basketId){
        set<String> setofferDetails = new set<String>();
        /*for(cscfga__Product_Configuration__c pc : [SELECT id,OfferName__c FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Basket__c=:basketId]){
                                                       if(pc.OfferName__c == 'Corporate Mobile Plus' || pc.OfferName__c == 'Adaptive Mobility'){
                                                           setofferDetails.add('Enterprise Mobility');
                                                       }else if(pc.OfferName__c == 'Telstra Collaboration'){
                                                           setofferDetails.add('PSTN');
                                                           setofferDetails.add('ISDN2');
                                                           setofferDetails.add('ISDN2DID');
                                                           setofferDetails.add('ISDN30');
                                                           //DIGI-1755 : To include TIPT-SIPC product family for Bulk Upload scenario by Abhishek(Osaka)
                                                           setofferDetails.add('TIPT-SIPC');
                                                       }
                                                   }*/
        
        //DIGI-6039 :- Added by Jay(Osaka) for removing hardcoded offer name
        for(cscfga__Product_Configuration__c pc : [SELECT id,OfferName__c, Marketable_Offer__r.Offer_ID__c FROM cscfga__Product_Configuration__c 
                                                   WHERE cscfga__Product_Basket__c=:basketId]){
                                                       if(pc.Marketable_Offer__r.Offer_ID__c == String.valueOf(MTMMetadataUtilityMap.get('Corporate_Mobile_Plus_Offer_Check').get('Value__c')) || pc.Marketable_Offer__r.Offer_ID__c == String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Mobility_Markatable_Offer_Check').get('Value__c'))){
                                                           setofferDetails.add('Enterprise Mobility');
                                                       }else if(pc.Marketable_Offer__r.Offer_ID__c == String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Collaboration_Markatable_Offer').get('Value__c'))){
                                                           setofferDetails.add('PSTN');
                                                           setofferDetails.add('ISDN2');
                                                           setofferDetails.add('ISDN2DID');
                                                           setofferDetails.add('ISDN30');
                                                           //DIGI-1755 : To include TIPT-SIPC product family for Bulk Upload scenario by Abhishek(Osaka)
                                                           setofferDetails.add('TIPT-SIPC');
                                                       }else if(pc.Marketable_Offer__r.Offer_ID__c == String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c'))){
                                                        setofferDetails.add('IOT');
                                                        }
                                                   }
        //End of DIGI-6039
        
        return setofferDetails;
    }
    /**
* @Author   :   Jayghosh Mishra
* @Team     :   Osaka
* @US       :   EDGE-198138
* @Desc     :   <B2B- 1525>Restrict users from selecting the same service if already part of another basket- Mobility
* */
    /*
@AuraEnabled 
public static Map<String,list<Legacy_Service__c>> checkIfServiceExisting(List<Legacy_Service__c> lstlegacyserviceToInsert, String basketId){
map<String, list<Legacy_Service__c>> allServiceIds= new map<String, list<Legacy_Service__c>>();
Set<String> serviceIdsInFile = new Set<String> ();
Set<String> existingServiceIds = new Set<String> ();
System.debug('lstlegacyserviceToInsert in checkIfServiceExisting' + lstlegacyserviceToInsert);
List<Legacy_Service__c> lsToNotBeUpserted = new List<Legacy_Service__c>();
List<String> notUpsertedServiceIds = new List<String>();
Set<Legacy_Service__c> lsToBeUpserted = new Set<Legacy_Service__c>();
List<Legacy_Service__c> finalLstobeInserted = new List<Legacy_Service__c>();
if(!lstlegacyserviceToInsert.isEmpty()){
for(Legacy_Service__c lsServiceIdsComingFromFile : lstlegacyserviceToInsert){
serviceIdsInFile.add(lsServiceIdsComingFromFile.Service_Id__c);
}
System.debug('serviceIdsInFile available ' + serviceIdsInFile);
List<Legacy_Service__c> existingLegecyServices = [Select id, Service_Id__c, Account__r.CIDN__c, Product_Basket__r.csordtelcoa__Basket_Stage__c, Product_Basket__r.cscfga__Opportunity__r.StageName from Legacy_Service__c where Service_Id__c IN: serviceIdsInFile  AND Product_Basket__c != :basketId AND Product_Basket__r.csordtelcoa__Basket_Stage__c != 'Cancelled'];
for(Legacy_Service__c existingLsServiceIds : existingLegecyServices){
existingServiceIds.add(existingLsServiceIds.Service_Id__c);
}
System.debug('existingLegecyServices ' + existingLegecyServices);
String newServiceId = '';
for(Legacy_Service__c newLsRecord : lstlegacyserviceToInsert){
newServiceId = newLsRecord.Service_Id__c;
System.debug('newLsRecord ' + newLsRecord);
if(!existingLegecyServices.isEmpty()){
for(Legacy_Service__c existingLs : existingLegecyServices){
System.debug('existingLs ' + existingLs);
//Checking for duplicate service Ids
if(newLsRecord.Service_Id__c == existingLs.Service_Id__c){
lsToNotBeUpserted.add(newLsRecord);
notUpsertedServiceIds.add(newLsRecord.Service_Id__c);   
System.debug('Records not to be inserted' + lsToNotBeUpserted);
}else{
if(!existingServiceIds.contains(newServiceId)){
lsToBeUpserted.add(newLsRecord);
//finalLstobeInserted.addall(lsToBeUpserted);
System.debug('Records  to be inserted' + lsToBeUpserted);
}
}
}
}else{
lsToBeUpserted.add(newLsRecord);
}	
}
finalLstobeInserted.addall(lsToBeUpserted);
}
allServiceIds.put('upsertServiceIds', finalLstobeInserted);// Legacy records with unique service ids
allServiceIds.put('duplicateServiceIds', lsToNotBeUpserted);//  Legacy records with duplicate service Ids

return allServiceIds;

} */
    /**
* @Author   :   Jay
* @Date     :   Feb 2021
* @Desc     :   Get Service
* @US       :   EDGE-198138
* @Status   :   Development
* */
    
    
    public static Set<String> getServiceList(List<Legacy_Service__c> notUpsertedServiceIds){
        Set <String> serviceId= new set <String> ();
        if (!notUpsertedServiceIds.isEmpty()) {
            for (Legacy_Service__c service: notUpsertedServiceIds) {
                serviceId.add(service.Service_Id__c);
            }
        }
        return serviceId;
    }
    
    public static Map<String,List<Legacy_Service__c>> checkIfServiceDuplicate(List<Legacy_Service__c> serviceRecordList, String basketId) {
        //Fetch service Id list from record.
        Set<String> lstlegacyserviceToInsert= getServiceList(serviceRecordList)  ;
        //Convert to set to remove duplicates and remove records
        Set<Legacy_Service__c> collatedServiceList = new Set<Legacy_Service__c> (serviceRecordList);
        //Collated Map with 2 records - service IDs to be saved and the duplicate service Ids.
        map<String, list<Legacy_Service__c>> allServiceIds= new map<String, list<Legacy_Service__c>>();
        System.debug('lstlegacyserviceToInsert in checkIfServiceExisting' + lstlegacyserviceToInsert);
        // Query for duplicate service Ids in staging table.
        List <Legacy_Service__c> existingLegacyServices = new List<Legacy_Service__c> ();
        
        //To be populated based on SoQL to fetch duplicate service ID.
        //List<Legacy_Service__c> lsToNotBeUpserted = new List<Legacy_Service__c>();
        //List<String> notUpsertedServiceIds = new List<String>();
        //Set<String> existingServiceIds = new Set<String> ();
        // New Service Ids to be upserted.
        //Set<Legacy_Service__c> lsToBeUpserted = new Set<Legacy_Service__c>();
        // List<Legacy_Service__c> finalLstobeInserted = new List<Legacy_Service__c>();
        if(!lstlegacyserviceToInsert.isEmpty()){			
            System.debug('serviceIds available ' + lstlegacyserviceToInsert);
            
            // Query for existing service Ids in staging table.
            existingLegacyServices = [Select id, Service_Id__c, Account__r.CIDN__c, Product_Basket__r.csordtelcoa__Basket_Stage__c, Product_Basket__r.cscfga__Opportunity__r.StageName from Legacy_Service__c where Service_Id__c IN: lstlegacyserviceToInsert  AND Product_Basket__c != :basketId AND Product_Basket__r.csordtelcoa__Basket_Stage__c != 'Cancelled'];
            // Fetching duplicate service Id list
            String serviceInstance='';
            for(Legacy_Service__c existingLsServiceIds : existingLegacyServices){
                serviceInstance=existingLsServiceIds.Service_Id__c;
                //existingServiceIds.add(serviceInstance);
                for (integer iterate=0;iterate<serviceRecordList.size();iterate++) {
                    if(serviceRecordList[iterate].Service_Id__c==serviceInstance) {
                        serviceRecordList.remove(iterate);
                    }
                }
            }
            //Fetching the services to be inserted
            /*  if(!existingServiceIds.isEmpty()){
collatedServiceList.removeAll(existingServiceIds);
}*/
            
            System.debug('Existing Legacy Services ' + existingLegacyServices);
            
            
            
        }
        allServiceIds.put('upsertServiceIds', serviceRecordList);// Legacy records with unique service ids
        allServiceIds.put('duplicateServiceIds', existingLegacyServices);//  Legacy records with duplicate service Ids
        
        return allServiceIds;
        
    }
    
    @AuraEnabled
    public static String checkForDuplicateServiceIds(List<Legacy_Service__c> notUpsertedServiceIds){
        System.debug('In New method notUpsertedServiceIds ' + notUpsertedServiceIds);
        List<String> finalDuplicateServiceIds = new List<String> ();
        String duplicateSids = '';
        if(!notUpsertedServiceIds.isEmpty()){
            for(Legacy_Service__c existingLs : notUpsertedServiceIds){
                finalDuplicateServiceIds.add(existingLs.Service_Id__c);
                
            }
            duplicateSids = String.join(finalDuplicateServiceIds, '\n');
            System.debug('finalDuplicateServiceIds ' + finalDuplicateServiceIds);
            //finalDuplicateServiceIds.add(dServiceIds);
        }
        
        System.debug('duplicateSids ' + duplicateSids);
        return duplicateSids;
    }
    // End of EDGE-198138
    
    
    /**
* @Author   :   Jayghosh Mishra
* @Date     :   Feb 2021
* @Desc     :   Validation rules on next button in transition select page, Bypassing multiCIDN validation for Sales and Assurance User
* @US       :   EDGE-201124
* @Status   :   Development
* */
    @AuraEnabled(cacheable = true)
    public static Boolean getProfileInfoForSalesUser (){
        Id profile_id=userinfo.getProfileId();
        system.debug('Current logged In User Profile~~'+profile_id);
        boolean applicableMultiCIDNValidation = true;
        String profile_name = [select Name from Profile where id = :profile_id].Name;
        System.debug('Sales-Enterprise-Unified ~~'+profile_name);
        //if(profile_name == 'Sales-Enterprise-Unified' || profile_name == 'Assurance Service Agent'  ||  profile_name == 'Developer Support' ){
        //DIGI-1742 Added by Abhishek(Osaka) to make Profile Names configurable.
        if(profileNamesList.contains(profile_name)){
            applicableMultiCIDNValidation = false;
        }
        System.debug('applicableMultiCIDNValidation ' + applicableMultiCIDNValidation);
        return applicableMultiCIDNValidation;
    }
    
    /**
* @Author   :   Jayghosh Mishra
* @Date     :   Feb 2021
* @Desc     :   Validation rules on next button in transition select page:- Getting current basket CIDN
* @US       :   EDGE-201124
* @Status   :   Development
* */
    //Getting Current Basket CIDN
    public static String getCurrentBasketCIDN(String basketId){
        cscfga__Product_Basket__c CurrentBasketDetails = [Select ID, Name, csbb__Account__r.CIDN__c from cscfga__Product_Basket__c where ID =: basketId];
        String currentBasketCIDN = CurrentBasketDetails.csbb__Account__r.CIDN__c;
        return currentBasketCIDN;
        
        
    }
    /**
* @Author   :   Jayghosh Mishra
* @Date     :   Feb 2021
* @Desc     :   Validation rules on next button in transition select page:- Getting hierarichal CIDN for ultimate parent CIDN
* @US       :   EDGE-201124
* @Status   :   Development
* */
    // Getting multiple CIDNs associated with ultimate parent CIDN
    public static Set<String> checkForCIDNHierarchy(String basketId){
        String ultimateCIDN = '';
        String hierarchicalCIDN = '';
        Set<String> hierarchicalCIDNList = new Set<String> ();
        String currentBasketCIDN = getCurrentBasketCIDN(basketId);
        // Query to get ultimate parent CIDN based on target CIDN
        List<Account> accList = [Select Id, name, CIDN__c, Parent_CIDN__c, Customer_Status__c, Ultimate_Parent_CIDN__c from Account where (CIDN__c =: currentBasketCIDN OR Parent_CIDN__c =:currentBasketCIDN OR Ultimate_Parent_CIDN__c =: currentBasketCIDN) AND (Customer_Status__c = 'ACTIVE' OR Customer_Status__c = 'ACQUIRED')];
        //System.debug('Accrecord based on CurrentBasketCIDN ' + accList);
        
        If(!accList.isEmpty()){
            for(Account acc : accList){
                ultimateCIDN = acc.Ultimate_Parent_CIDN__c;
            }
            If(ultimateCIDN != NULL){
                
                //Query to get all associated CIDNs from ultimate parent CIDN
                
                List<Account> accRec = [Select id, name, CIDN__c, Ultimate_Parent_CIDN__c from Account where CIDN__c =:ultimateCIDN OR Ultimate_Parent_CIDN__c =: ultimateCIDN];
                
                //System.debug('Account record based on Ultimate Parent CIDN ' + accRec);
                if(!accRec.isEmpty()){
                    for(Account filteredAcc : accRec){
                        hierarchicalCIDN = filteredAcc.CIDN__c;
                        hierarchicalCIDNList.add(hierarchicalCIDN);
                    }
                    //System.debug('hierarchicalCIDNList based on Ultimate ' + hierarchicalCIDNList);
                }
            }else{
                hierarchicalCIDNList.add(currentBasketCIDN);
                //System.debug('hierarchicalCIDNList based on Current ' + hierarchicalCIDNList);
            }
        }
        return hierarchicalCIDNList;
    }

/***************************************************************
 * Method : fetchProductFamily
 * Team : Osaka
 * Developer : Abhishek Mallick
 * Description : This method return product family Metadata Name
 * 				based on product added for particular basket	
 * *************************************************************/    
    @AuraEnabled
    public static String fetchProductFamily(String basketId){
        
        Set<String> pcOfferName = new Set<String>();
        Set<String> pcMarkatableOfferIdSet = new Set<String>();
        String productFamilyMeta;
        String currentMarketableOfferId = '';


        for(cscfga__Product_Configuration__c pcRec : [SELECT id,OfferName__c, Marketable_Offer__r.Offer_ID__c FROM cscfga__Product_Configuration__c 
                                                      WHERE cscfga__Product_Basket__c=:basketId]){
                                                          pcOfferName.add(pcRec.OfferName__c);
                                                          pcMarkatableOfferIdSet.add(pcRec.Marketable_Offer__r.Offer_ID__c);
                                                          currentMarketableOfferId = pcRec.Marketable_Offer__r.Offer_ID__c;
                                                          
                                                      }
        /*if(pcOfferName.contains('Telstra Collaboration')){
            productFamilyMeta ='Product_Family_for_ngUc';
        }
        else if(pcOfferName.contains('Adaptive Mobility') || pcOfferName.contains('Corporate Mobile Plus')){
            productFamilyMeta ='Product_Family_for_Mobile';
        }*/
        //DIGI-6039 :- Added by Jay(Osaka) for removing hardcoded offer name
        if(pcMarkatableOfferIdSet.contains(String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Collaboration_Markatable_Offer').get('Value__c')))){
            productFamilyMeta ='Product_Family_for_ngUc';
        }else if(pcMarkatableOfferIdSet.contains(String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Mobility_Markatable_Offer_Check').get('Value__c'))) || pcMarkatableOfferIdSet.contains(String.valueOf(MTMMetadataUtilityMap.get('Corporate_Mobile_Plus_Offer_Check').get('Value__c')))){
            productFamilyMeta ='Product_Family_for_Mobile';
        }
        /* Developer :- Jay(Osaka) 
             * Story :- DIGI-16452
             * Dec :- TED-284 - Enabling Transition for IOT Product in the  Transition screen 
             * */
            else if(currentMarketableOfferId != NULL && pcMarkatableOfferIdSet.contains(String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c')))){
                System.debug('IoT Block -->>> ' + String.valueOf(MTMMetadataUtilityMap.get('IoT_Marketable_Offer').get('Value__c')));
                productFamilyMeta='Product_Family_For_IoT';
                }
            // End of DIGI-16452
        // End of DIGI-6039 
        return productFamilyMeta;
    }
    
}
/*
*    This class captures all the utility methods that act on the Address and Site Object.
*/
//This is Test Run for US EDGE 3970 on 7 nov 2017
//Please approve my pull request to complete my demo.
public with sharing class AddressAndSiteObjectUtility {
    public static List<cscfga__Attribute__c> attrFilteredList = new List<cscfga__Attribute__c>();
    public static List<csord__Subscription__c> orderSubList = new List<csord__Subscription__c>();
    public static List<cscfga__Attribute__c> attrList = new List<cscfga__Attribute__c>();
    public static String objectString='';
    public static String objectFields='';
    //public static List<Account> accountList=new List<Account>();
    
    /*NFB-2803 : Utility Method for modifying RFS date based on the SQ call*/
    public static AuraProcessingMessage changeRFSDate(String adborId, String rfsdate, String locId){
        cscrm__Address__c address= new cscrm__Address__c();//Added Changes Regarding EDGE-71954
        List<cscrm__Address__c> addrs=new List<cscrm__Address__c>();//Added Changes Regarding EDGE-71954
        AuraProcessingMessage msg;
        try{
            msg=new AuraProcessingMessage();
            objectString='cscrm__Address__c';
            objectFields='Address_ID__c,Ready_For_Service_Date__c,NBN_Location_Id__c';
            if(checkAccessibility(objectString,objectFields))
            {
                addrs =  Database.query('SELECT Address_ID__c, Ready_For_Service_Date__c, NBN_Location_Id__c  FROM cscrm__Address__c WHERE Address_ID__c =:adborId');
            }
            if(addrs!=null && addrs.size()!=0){
                address = addrs.get(0);
                if(locId != null && locId !=''){
                    address.NBN_Location_Id__c = locId;
                    address.Ready_For_Service_Date__c = rfsdate;
                    msg=UpsertAddress(address);
                }
            }else{
                msg.isSuccess=false;
                msg.errorMsg='Address not found';
                throw new AddressNotFoundException();
            }
        }catch(AddressNotFoundException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }  
        return msg;
    }
    
    /*  NFB-2815 : Added for upserting address record recieved from EAST, TCM & Replicator interfaces  */
    
    /*Class for returning the success/error msgs & status after method call*/
    public class AuraProcessingMessage { 
        
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String errorMsg; 
        @AuraEnabled public String successMsg; 
        
        public AuraProcessingMessage(){
            isSuccess = true;
            errorMsg = '';
            successMsg = '';
        }
    }
    
    /*Custom Exceptions for Replicator Site Creation method*/
    public class SiteCreationFailedException extends Exception {}
    public class SiteUnconfirmedException extends Exception {}
    public class SiteCreationFailedAddrNotFoundException extends Exception {}
    public class SiteCreationFailedAccountNotFoundException extends Exception {}
    public class AddressCreationException extends Exception {}
    public class AddressNotFoundException extends Exception {}
    
    /*Method to check the existance of Address based on ADBOR Id*/
    public static cscrm__Address__c getExistingAddressFromSF(String adborid){
        system.debug('Adbor Id in getExistingAddress function = ' + adborid);
        cscrm__Address__c address= new cscrm__Address__c();//Added Changes Regarding EDGE-71954
        List<cscrm__Address__c> addressList;
        try{
            objectString='cscrm__Address__c';
            objectFields='Address_ID__c, Source_System__c, Address_Status__c';
            if(checkAccessibility(objectString,objectFields)){
                addressList = Database.query('SELECT Address_ID__c, Source_System__c, Address_Status__c FROM cscrm__Address__c WHERE Address_ID__c = :adborId');
            }
            
            if(addressList!=null && addressList.size()!=0){
                address = addressList.get(0);
                System.debug('Method : getExistingAddressFromSF ' + address);
            }
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return address;
    }
    
    
    /*Utility Method for Saving the Address returned from TCM interface to Salesforce*/
    public static cscrm__Address__c upsertTCMAddress(CustomerObject.Address tcmAddress){
        cscrm__Address__c address;
        String stNumber = ''; 
        String numTo = '';
        try{
            address = getExistingAddressFromSF(tcmAddress.addressId);
            //Update the common fields for Address if the source system os blank or 'TCM'.
            if(address==null){
                address = new cscrm__Address__c();
                address.Source_System__c = '';
            }
            if(address.Source_System__c == null || String.isBlank(address.Source_System__c) || address.Source_System__c == 'TCM'){
                //Creating new Address object if address not found in SalesForce db.
                address.Address_ID__c = tcmAddress.addressId;
                address.cscrm__Country__c = tcmAddress.country;
                address.Source_System__c = 'TCM';
                address.cscrm__External_ID__c = tcmAddress.addressId;
                address.cscrm__State_Province__c = tcmAddress.state;
                address.cscrm__Zip_Postal_Code__c = tcmAddress.postalCode;
                address.cscrm__Street_Name__c = tcmAddress.streetName;
                //address.cscrm__Street_Type__c = tcmAddress.streetType;
                address.Locality__c = tcmAddress.locality;
                address.cscrm__Address_Type__c = tcmAddress.addressType;
                /************* Release 17.13 hotfix*********/
                address.streetType__c = tcmAddress.streetType;
                address.streetTypeSuffix__c = tcmAddress.streetTypeSuffix;
                address.Street_Number_To__c = tcmAddress.streetNumberEnd;
                address.streetNumberEndSuffix__c = tcmAddress.streetNumberEndSuffix;
                address.Street_Number_From_calc__c = tcmAddress.streetNumberStart;
                address.streetNumberStartSuffix__c = tcmAddress.streetNumberStartSuffix;
                /***************END**********/
                if(tcmAddress.streetNumberStart != null){
                    stNumber  = tcmAddress.streetNumberStart;
                    if (tcmAddress.streetNumberStartSuffix != null) {stNumber = stNumber + tcmAddress.streetNumberStartSuffix; }
                    //address.cscrm__Street_Number_Start__c  = stNumber;
                }
                
                if(tcmAddress.streetNumberEnd != null){
                    numTo =tcmAddress.streetNumberEnd;
                    if (tcmAddress.streetNumberEndSuffix != null) {numTo = numTo + tcmAddress.streetNumberEndSuffix; }
                    //address.cscrm__Street_Number_End__c = numTo;
                }
                
                if(tcmAddress.subAddress != null){
                    if(tcmAddress.subAddress.numberStart != null ){
                        address.TCM_numberStart__c =tcmAddress.subAddress.numberStart; 
                    }
                    if(tcmAddress.subAddress.numberEnd != null ){
                        address.TCM_numberEnd__c =tcmAddress.subAddress.numberEnd; 
                    }
                    
                    address.Sub_Address1_Type__c = tcmAddress.addressTypeCode;
                    address.Sub_Address1_Number__c = address.TCM_numberStart__c + ((address.TCM_numberEnd__c != null && address.TCM_numberEnd__c != '0' && address.TCM_numberEnd__c != '') ? ('-' + address.TCM_numberEnd__c) : '');
                    //address.Sub_Address_Level_1__c = address.Sub_Address1_Type__c + ' ' + address.Sub_Address1_Number__c;
                    
                    address.cscrm__Building_Name__c = tcmAddress.SubAddress.propertyName;
                    if(tcmAddress.subAddress.addressLines != null  && !tcmAddress.subAddress.addressLines.isEmpty()){
                        if(tcmAddress.subAddress.addressLines[0] != null){
                            address.Address_Line_1__c = tcmAddress.subAddress.addressLines[0];    
                        }
                        if(tcmAddress.subAddress.addressLines[1] != null){
                            address.Address_Line_2__c = tcmAddress.subAddress.addressLines[1];    
                        }
                        if(tcmAddress.subAddress.addressLines[2] != null){
                            address.Address_Line_3__c = tcmAddress.subAddress.addressLines[2];    
                        }
                    }
                    if(tcmAddress.SubAddress.details != null){
                        if(tcmAddress.SubAddress.details[0]!=null){
                            address.Sub_Address2_Number__c = tcmAddress.SubAddress.details[0].value;
                            address.Sub_Address2_Type__c = tcmAddress.SubAddress.details[0].detailType;
                            address.Sub_Address2_Type_Code__c = tcmAddress.SubAddress.details[0].detailTypeCode;
                            //address.Sub_Address_Level_2__c = address.Sub_Address2_Type__c + ' ' + address.Sub_Address2_Number__c;
                        }
                        if(tcmAddress.SubAddress.details[1]!=null){
                            address.Sub_Address_3_Number__c = tcmAddress.SubAddress.details[1].value;
                            address.Sub_Address_3_Type__c = tcmAddress.SubAddress.details[1].detailType;
                            address.Sub_Address_3_Type_Code__c = tcmAddress.SubAddress.details[1].detailTypeCode;
                            //address.Sub_Address_Level_3__c = address.Sub_Address_3_Type__c + ' ' + address.Sub_Address_3_Number__c;
                        }
                    }
                    
                }
                
                //String street_start_end = address.Street_Number_Start_calc__c + ((address.Street_Number_End_calc__c != null && address.Street_Number_End_calc__c!= '0' && address.Street_Number_End_calc__c!= '') ? ('-' + address.Street_Number_End_calc__c) : '');
                //address.Name = address.Sub_Address_Level_1_calc__c + ' ' + address.Sub_Address_Level_2_calc__c+ ' ' + address.cscrm__Building_Name__c + ' ' + street_start_end + ' ' + address.cscrm__Street_Name__c + ' ' + address.Street_Type_calc__c + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c + '(' + tcmAddress.addressId + ')';
                //address.Name = tcmAddress.streetName + ' ' + tcmAddress.locality + ' ' + tcmAddress.state + ' ' + tcmAddress.postalCode + '(' + tcmAddress.addressId + ')';
            }
            //Updating TCM specific fields by default.
            address.cscrm__Is_Billing_Address__c = true;
            
            System.debug('Address to be inserted:'+address);
            //Calling utility function to upsert address object.
            upsertAddress(address);
        }
        catch(DMLException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return address;
    }
    public static cscrm__Address__c upsertEastAddress(AddressSummary eastAddress){
        cscrm__Address__c address;
        String envAdddressNameSize;
        Integer adddressNameSize;
        String numTo = '';
        String stNumber = '';
        try{
            envAdddressNameSize = EnvironmentVariable.get('east_result_ui_address_name_text_size');
            adddressNameSize = (envAdddressNameSize != null && envAdddressNameSize != '') ? integer.valueof(envAdddressNameSize) : 68;
            address = getExistingAddressFromSF(eastAddress.addressId);
            //Creating new Address object if address not found in SalesForce db.
            if(address==null){
                address= new cscrm__Address__c();
            }
            address.Address_ID__c = eastAddress.addressId;
            address.Source_System__c = 'EAST';
            //address.cscrm__Street__c = eastAddress.addressLine; 
            address.cscrm__Building_Name__c = eastAddress.name;
            address.cscrm__Address_Type__c = eastAddress.addressType;
            address.Postal_Delivery_Type__c = eastAddress.postalDeliveryType;
            address.cscrm__Plan_Number__c  = eastAddress.planNumber;
            address.Address_Status__c = eastAddress.status;
            if (eastAddress.numberStart != null) {
                stNumber  = eastAddress.numberStart;
                if (eastAddress.numberPrefix != null) {stNumber = eastAddress.numberPrefix + stNumber; }
                if (eastAddress.numberSuffix != null) {stNumber = stNumber + eastAddress.numberSuffix; }
            }
            //address.cscrm__Street_Number_Start__c  = stNumber;
            if (eastAddress.numberTo != null) {
                numTo = eastAddress.numberTo;
                if (eastAddress.numberToPrefix != null) {numTo = eastAddress.numberToPrefix + numTo; }
                if (eastAddress.numberToSuffix != null) {numTo = numTo + eastAddress.numberToSuffix; }
            }
            //address.cscrm__Street_Number_End__c = numTo;
            //address.cscrm__Building_Number__c = stNumber + ((numTo != null && numTo != '0' && numTo != '') ? ('-' + numTo) : '');
            address.cscrm__Street_Name__c   = eastAddress.streetName;
            String streetType = '';
            if (eastAddress.streetType != null) {
                streetType = eastAddress.streetType;
                if (eastAddress.streetTypeSuffix != null) {streetType = streetType + eastAddress.streetTypeSuffix; }
            }
            address.streetType__c = streetType;
            address.Locality__c = eastAddress.locality;
            address.Greater_Locality__c   = eastAddress.greaterLocality;
            address.cscrm__State_Province__c = eastAddress.state;
            address.cscrm__Zip_Postal_Code__c = eastAddress.postcode;
            
            //Fix for Geolocation Issue
            
            String latitude = eastAddress.lat;
            String longitude = eastAddress.longZ;
            
            if (latitude != null && latitude != '') {
                
                Double latDouble = ConvertDegreesToDecimal(latitude);
                
                if(latDouble!=null){
                    address.cscrm__Geolocation__Latitude__s  = latDouble;
                }
                
                System.debug('address.cscrm__Geolocation__Latitude__s :'+address.cscrm__Geolocation__Latitude__s);
            }
            
            if (longitude != null && longitude != '') {
                
                Double longDouble = ConvertDegreesToDecimal(longitude);
                
                if(longDouble!=null){
                    address.cscrm__Geolocation__Longitude__s  = longDouble;
                }
                
                System.debug('address.cscrm__Geolocation__Longitude__s :'+address.cscrm__Geolocation__Longitude__s);
            }
            //End of Geolocation Fix
            
            address.latitude__c = EastAddress.lat;
            system.debug('***** latitude :'+address.latitude__c);
            address.longitude__c = EastAddress.longZ;
            system.debug('***** longitude :'+address.longitude__c);
            
            system.debug('***** building name :'+address.cscrm__Building_Name__c);
            //address.Sub_Address_Level_1__c = EastAddress.subAddressLevel1;
            //System.debug('**** sub address level 1 is  *** :'+address.Sub_Address_Level_1_calc__c);
            //address.Sub_Address_Level_2__c = EastAddress.subAddresslevel2;
            //System.debug('**** sub address level 2 is  *** :'+address.Sub_Address_Level_2__c);
            //address.Sub_Address_Level_3__c = EastAddress.subAddresslevel3;
            //System.debug('**** sub address level 3 is  *** :'+address.Sub_Address_Level_3__c);
            //address.Sub_Address_Level_4__c = EastAddress.subAddresslevel4;
            //System.debug('**** sub address level 4 is  *** :'+address.Sub_Address_Level_4__c);
            
            address.Sub_Address1_Number__c = EastAddress.addrNumLvl1;
            address.Sub_Address2_Number__c = EastAddress.addrNumLvl2;
            address.Sub_Address_3_Number__c = EastAddress.addrNumLvl3;
            address.Sub_Address_4_Number__c = EastAddress.addrNumLvl4;
            address.Sub_Address1_Type__c = EastAddress.addrTypeLvl1;
            address.Sub_Address2_Type__c = EastAddress.addrTypeLvl2;
            address.Sub_Address_3_Type__c = EastAddress.addrTypeLvl3;
            address.Sub_Address_4_Type__c = EastAddress.addrTypeLvl4;                                
            
            if(eastAddress.readyForServiceDate != null && eastAddress.readyForServiceDate !=''){
                address.Ready_For_Service_Date__c  = eastAddress.readyForServiceDate;
            }
            address.Rural_Mail_Type__c = eastAddress.ruralMailType;
            address.NBN_Status__c = eastAddress.nbnStatus;
            address.Parent_Address_Id__c   = eastAddress.parentAddressId;
            address.Number_of_Sub_addresses__c = eastAddress.numberOfSubAddresses;
            address.Sub_Address_Type__c   = eastAddress.subAddressType;
            address.Sub_Address_Number__c  = eastAddress.subAddressNumber;
            address.NBN_Location_Id__c   = eastAddress.locationId;
            address.Connectivity_Serving_Area__c   = eastAddress.connectivityServiceAreaId;
            address.ESA_Code__c   = eastAddress.exchangeServiceAreaId;
            address.FACS_Realm__c   = eastAddress.facsRealm;
            String name = address.Street_calc__c + ' ' + address.Locality__c + ' ' + address.cscrm__State_Province__c + ' ' + address.cscrm__Zip_Postal_Code__c;
            system.debug('eastAddress.accountId='+eastAddress.accountId);
            address.cscrm__Account__c = eastAddress.accountId;
            System.debug('Address:'+address);
            upsertAddress(address); 
        }
		catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e.getMessage());
        }
        return address;
    }
    
    
    /*------------------------------------------------------------ 
//EDGE -76217
Method: upsertNBNStructured_Auto 
Description: Save Address for structured/unstructures search
Inputs: AddressResponseDTO
Returns:  cscrm__Address__c
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    
    public static cscrm__Address__c upsertNBNStructured_Auto (AddressResponseDTO nbnEastAddress){
        System.debug('upsertNBNStructured_Auto: '+nbnEastAddress );
        cscrm__Address__c address;
        String latitude;
        String longitude;
        try{
           
            AddressResponseDTO.Structured nbnStructured ;
            AddressResponseDTO.UnstructuredAUPost nbnUnStructured ;
            //System.debug('nbnStructured: '+nbnEastAddress.dataZ);
            //System.debug('AddressResponseDTO: '+nbnEastAddress);
            if(nbnEastAddress.dataZ!=null && !nbnEastAddress.dataZ.structured.isEmpty()){
                nbnStructured = nbnEastAddress.dataZ.structured[0];
            }
            if(nbnEastAddress.dataZ!=null && !nbnEastAddress.dataZ.unstructuredAUPost.isEmpty()){
                nbnUnStructured = nbnEastAddress.dataZ.unstructuredAUPost[0];
            }
            System.debug('nbnStructured: '+nbnStructured);
            System.debug('nbnStructured: '+nbnUnStructured);
            address = getExistingAddressFromSF(nbnStructured.addressId);
            //Creating new Address object if address not found in SalesForce db.
            if(address==null){
                address= new cscrm__Address__c();
            }       
            //common mapping for both parent & child address
            address.Source_System__c = 'EAST';
            address.Address_ID__c = nbnStructured.addressId;
            
            //EDGE-122626 Kalashree Borgaonkar. Changing mapping 
            address.Locality__c = nbnUnStructured.localityName;
            address.cscrm__Country__c = 'AUSTRALIA';
            
            address.cscrm__State_Province__c = nbnUnStructured.state;
            address.cscrm__Zip_Postal_Code__c = nbnUnStructured.postcode;
            address.cscrm__Plan_Number__c = nbnStructured.planNumber;
            address.Rural_Mail_Type__c = nbnStructured.ruralmailType;
            
            if(nbnStructured!=null && nbnStructured.streetName!=null){
                address.cscrm__Street_Name__c = nbnStructured.streetName;
            } else if(nbnStructured!=null && nbnStructured.primarySummary!=null && nbnStructured.primarySummary.streetName!=null){
                address.cscrm__Street_Name__c = nbnStructured.primarySummary.streetName;
            }
            
            if(nbnStructured!=null &&  nbnStructured.propertyNumberTo!=null){
                address.Street_Number_To__c = nbnStructured.propertyNumberTo;
            } else if(nbnStructured!=null &&  nbnStructured.primarySummary!=null && nbnStructured.primarySummary.propertyNumberTo!=null){
                address.Street_Number_To__c = nbnStructured.primarySummary.propertyNumberTo;
            }
            
            system.debug('****Street_Number_To__c :' + address.Street_Number_To__c);
            
            if(nbnStructured!=null &&  nbnStructured.propertyNumberFrom!=null){
                address.Street_Number_From__c = String.valueOf(nbnStructured.propertyNumberFrom);
            } else if(nbnStructured!=null &&  nbnStructured.primarySummary!=null && nbnStructured.primarySummary.propertyNumberFrom!=null){
                address.Street_Number_From__c = String.valueOf(nbnStructured.primarySummary.propertyNumberFrom);
            }else{
                address.Street_Number_From__c = nbnStructured.ruralmailNumber;
            }
            address.Street_Number_From_calc__c =address.Street_Number_From__c;
            
            system.debug('****Street_Number_From__c :' + address.Street_Number_From_calc__c);  
            
            if(nbnStructured!=null &&  nbnStructured.streetType!=null && nbnStructured.streetName!=null){
                address.streetType__c= nbnStructured.streetType;
            } else if(nbnStructured!=null &&  nbnStructured.primarySummary!=null && nbnStructured.primarySummary.streetType!=null){
                address.streetType__c= nbnStructured.primarySummary.streetType;
            } 
            
            /* if(nbnStructured!=null &&  nbnStructured.streetSuffix!=null){
address.streetTypeSuffix__c= nbnStructured.streetSuffix;
} 

address.streetNumberEndSuffix__c = nbnStructured.propertyNumberSuffixTo;
address.streetNumberStartSuffix__c = nbnStructured.propertyNumberSuffixFrom;  

if(address.streetNumberStartSuffix__c==null || address.streetNumberStartSuffix__c==''){
address.streetNumberStartSuffix__c = nbnStructured.ruralmailType;
}*/
            //EDGE - 76217 : mapping additional fields
            if(nbnStructured!=null ){
                if( nbnStructured.subAddressNumberFrom!=null){
                    address.Sub_Address_Number__c= nbnStructured.subAddressNumberFrom;
                }
                if( nbnStructured.parcelNumber!=null){
                    address.Parcel_Number__c= nbnStructured.parcelNumber;
                }
                if( nbnStructured.numSubaddresses!=null){
                    address.Number_of_Sub_addresses__c = String.valueOf(nbnStructured.numSubaddresses);
                }
                if( nbnStructured.subAddressType!=null){
                    address.Sub_Address_Type__c = nbnStructured.subAddressType;
                }
                if( nbnStructured.parcelDescriptionType1!=null){
                    address.Parcel_Type__c  =   nbnStructured.parcelDescriptionType1 ;
                }
                if( nbnStructured.parcelType!=null){
                    address.Parcel_Type__c  =   nbnStructured.parcelType ;
                }
                if( nbnStructured.parcelDescriptor1Prefix!=null){
                    address.Parcel_Type_Prefix__c   =   nbnStructured.parcelDescriptor1Prefix;
                }
                if( nbnStructured.condorCode!=null){
                    address.Condor_Code__c  =   nbnStructured.condorCode;
                }
                if( nbnStructured.fsam!=null){
                    address.fsam__c =   nbnStructured.fsam;
                }
                if( nbnStructured.ruralmailNumber!=null){
                    address.Rural_Mail_Number__c    =   nbnStructured.ruralmailNumber;
                }
                if( nbnStructured.postalDeliveryNumber!=null){
                    address.Postal_Delivery_Number__c   =   nbnStructured.postalDeliveryNumber;
                }
                if( nbnStructured.postalDeliveryType!=null){
                    address.Postal_Delivery_Type__c =   nbnStructured.postalDeliveryType;
                }  
                //Kalashree Borgaonkar. Fixed as per discussion on 30-04-2019 with BA. EDGE-90329
                 if( nbnStructured.addressType!=null){
                    address.cscrm__Address_Type__c =  nbnStructured.addressType;    
                }  
                if( nbnStructured.parent==null){
                    System.debug('In parent');
                    if(nbnStructured.serviceLocation!=null && nbnStructured.serviceLocation.exchangeServiceArea!=null){
                        address.ESA_Code__c =   nbnStructured.serviceLocation.exchangeServiceArea;
                    }
                }
                else{
                    if(nbnStructured.primarySummary!=null){
                        address.ESA_Code__c =   nbnStructured.primarySummary.serviceLocation.exchangeServiceArea;         
                    }
                }    
            }
            Boolean addressStatus = nbnStructured.confirmed;
            address.Address_Status__c = (addressStatus == true) ? 'Confirmed' : 'Unconfirmed';
            
            //mapping for US-706(for parent)
            if(nbnStructured.SubAddresses != null && nbnStructured.parent==null){    
                
                AddressResponseDTO.Level1[] level1;
                AddressResponseDTO.Level2[] level2;
                AddressResponseDTO.Level3[] level3;
				address.cscrm__Address_Type__c =  nbnStructured.addressType;
                // logic for building name & different address levels
                level1 = nbnStructured.Subaddresses.Level1;
                if(level1 != null & address.cscrm__Building_Name__c==null){
                    for (integer i = 0 ; i < level1.size() ; i++){
                        if(level1[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c == null && level1[i].SubAddressType == 'BUILDING') ? level1[i].BUname : address.cscrm__Building_Name__c;
                            level2 = level1[i].Level2;         
                        }
                    }
                }
                if(level2 != null && address.cscrm__Building_Name__c==null){
                    for (integer i = 0 ; i < level2.size() ; i++){
                        if(level2[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c == null && level2[i].SubAddressType == 'BUILDING') ? level2[i].BUname : address.cscrm__Building_Name__c;
                            level3 = level2[i].Level3;
                        }        
                    }
                }
                if(level3 != null && address.cscrm__Building_Name__c==null){
                    for(integer i = 0 ; i < level3.size() ; i++){
                        if(level3[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c== null && level3[i].SubAddressType == 'BUILDING') ? level3[i].BUname : address.cscrm__Building_Name__c; 
                        }
                    }
                }
                if(nbnStructured.serviceLocation!=null){
                    address.Connectivity_Serving_Area__c = nbnStructured.serviceLocation.customerServiceAreaId;
                    //address.ESA_Code__c = nbnStructured.serviceLocation.exchangeServiceArea;
                    address.FACS_Realm__c = nbnStructured.serviceLocation.facsRealm;
                    latitude = nbnStructured.serviceLocation.latitude;
                    longitude = nbnStructured.serviceLocation.longitude;
                    address.NBN_Location_Id__c = nbnStructured.serviceLocation.locationId;
                    address.Ready_For_Service_Date__c = nbnStructured.serviceLocation.readyForServiceDate;
                }
                
            }
            //mapping for child address
            else {     
                
                AddressResponseDTO.Parent parent1;
                AddressResponseDTO.Parent parent2;
                AddressResponseDTO.Parent parent3;
                AddressResponseDTO.Parent parent4;
                
               // address.cscrm__Address_Type__c = nbnStructured.subAddressType;
                
                // logic for building name & subaddress levels
                if(nbnStructured != null){
                    System.debug('nbnStructured.addressSummaryType: '+nbnStructured.addressSummaryType);
                    if(nbnStructured.addressSummaryType == 'SubAddressSummary'){
                        
                        if(address.cscrm__Building_Name__c == null && nbnStructured.subAddressType == 'BUILDING' && nbnStructured.name!=null){
                            //address.cscrm__Building_Name__c = nbnStructured.name;
                        }else{
                            address.Sub_Address1_Number__c = nbnStructured.subAddressNumberFrom;
                            address.Sub_Address1_Type__c = nbnStructured.subAddressType;
                            address.Sub_Address1_Type_Code__c = nbnStructured.subAddressCodeset;
                        }
                        parent1 = nbnStructured.parent;
                    }
                }        
                if(parent1 != null){
                    address.Parent_Address_Id__c = parent1.addressId;
                    if(parent1.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent1.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent1.name;
                        }else{
                            address.Sub_Address2_Number__c = parent1.subAddressNumberFrom;
                            address.Sub_Address2_Type__c = parent1.subAddressType;
                            address.Sub_Address2_Type_Code__c = parent1.subAddressCodeset;
                        }
                        parent2 = parent1.parent;
                    }           
                }        
                if(parent2 != null){
                    if(parent2.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent2.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent2.name;
                        }else{
                            address.Sub_Address_3_Number__c = parent2.subAddressNumberFrom;
                            address.Sub_Address_3_Type__c = parent2.subAddressType;
                            address.Sub_Address_3_Type_Code__c = parent2.subAddressCodeset;
                        }
                        parent3 = parent2.parent;
                    }   
                }           
                if(parent3 != null){
                    if(parent3.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent3.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent3.name;
                        }else{
                            address.Sub_Address_4_Number__c = parent3.subAddressNumberFrom;
                            address.Sub_Address_4_Type__c = parent3.subAddressType;
                            address.Sub_Address_4_Type_Code__c = parent3.subAddressCodeset;
                        }
                        parent4 = parent3.parent;
                    }   
                }
                if(parent4 != null){
                    if(parent4.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent4.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent4.name;
                        }else{
                            address.Sub_Address_4_Number__c = parent4.subAddressNumberFrom;
                            address.Sub_Address_4_Type__c = parent4.subAddressType;
                            address.Sub_Address_4_Type_Code__c = parent4.subAddressCodeset;
                        }
                    }   
                }  
                if(nbnStructured.serviceLocation!=null){
                    address.Connectivity_Serving_Area__c = nbnStructured.serviceLocation.customerServiceAreaId;
                    //address.ESA_Code__c = nbnUnStructured.serviceLocation.exchangeServiceArea;
                    address.FACS_Realm__c = nbnStructured.serviceLocation.facsRealm;
                    latitude = nbnStructured.serviceLocation.latitude;
                    longitude = nbnStructured.serviceLocation.longitude;
                    address.NBN_Location_Id__c = nbnStructured.serviceLocation.locationId;
                    address.Ready_For_Service_Date__c = nbnStructured.serviceLocation.readyForServiceDate;
                }   
                
                
            }
            // logic for geolocation
            
            /*if((address.cscrm__Building_Name__c==null || address.cscrm__Building_Name__c=='') && nbnStructured.primarySummary!=null && nbnStructured.primarySummary.propertyName!=null){
address.cscrm__Building_Name__c = nbnStructured.primarySummary.propertyName;
}*/
            
            if (latitude != null && latitude != '') {               
                Double latDouble = ConvertDegreesToDecimal(latitude);   
                if(latDouble!=null){
                    address.cscrm__Geolocation__Latitude__s  = latDouble;
                }   
                System.debug('address.cscrm__Geolocation__Latitude__s :'+address.cscrm__Geolocation__Latitude__s);
            }           
            if (longitude != null && longitude != '') {         
                Double longDouble = ConvertDegreesToDecimal(longitude);     
                if(longDouble!=null){
                    address.cscrm__Geolocation__Longitude__s  = longDouble;
                }           
                System.debug('address.cscrm__Geolocation__Longitude__s :'+address.cscrm__Geolocation__Longitude__s);
            }    
            if(nbnStructured.serviceLocation!=null){
                address.latitude__c = nbnStructured.serviceLocation.latitude;
                system.debug('***** latitude :'+address.latitude__c);
                address.longitude__c = nbnStructured.serviceLocation.longitude;
                system.debug('***** longitude :'+address.longitude__c);
            } 
            address.Address_Line_1__c = nbnUnStructured.addressline1;
            address.Address_Line_2__c = nbnUnStructured.addressline2;
            address.Address_Line_3__c = nbnUnStructured.addressline3; 
            System.debug('Address to be inserted:'+address);
            //Calling utility function to upsert address object.
            upsertAddress(address);
            
        } catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }       
        return address;
    }
    /**************** Start of Edge 85839 *****************/
    //Overridden the method with one extra boolean argument to extend the existing functionality to use in InvokeEASTCalloutBatch Batch class.
    public static cscrm__Address__c upsertNBNEastAddress (AddressResponseDTO nbnEastAddress){
        /**************** Start of Edge 85839 *****************/
        return upsertNBNEastAddress (nbnEastAddress,false);
        /**************** End of Edge 85839 *****************/
    }
    
    //method for upserting EAST address by adborid search
    /**
     * @createdBy               : 
     * @name upsertNBNEastAddress
     * @description             : The method is called from the "InvokeEASTCalloutBatch" class and it will help upsert the Address Object.
                                  Added one flag on the existing method to bypass the upsert operation
                                  Whenever the falg is false then the existing functionality will execute and if it is true then our Batch will execute
    
     * @param nbnEastAddress    : AddressResponseDTO 
     * @param isBatch           : true
     * @return cscrm__Address__c: Addresse Object
     * @jiraStoryRef            : EDGE-85839
     * @createdBy               : Sasidhar Devarapalli,OSAKA
     * 
     **/
    
    public static cscrm__Address__c upsertNBNEastAddress (AddressResponseDTO nbnEastAddress, Boolean isBatch){
        cscrm__Address__c address;
        String latitude;
        String longitude;
        try{
            AddressResponseDTO.Addresses nbnAddress = nbnEastAddress.data.unstructuredAUPost.addresses;
            AddressResponseDTO.Structured nbnStructured = nbnEastAddress.data.structured;
            AddressResponseDTO.UnstructuredAUPost nbnUnStructured = nbnEastAddress.data.unstructuredAUPost;
            
            address = getExistingAddressFromSF(nbnAddress.addressId);
            //Creating new Address object if address not found in SalesForce db.
            if(address==null){
                address= new cscrm__Address__c();
            }       
            //common mapping for both parent & child address
            address.Source_System__c = 'EAST';
            address.Address_ID__c = nbnAddress.addressId;
            address.Address_Line_1__c = nbnAddress.addressline1;
            address.Address_Line_2__c = nbnAddress.addressline2;
            address.Address_Line_3__c = nbnAddress.addressline3;
            address.Locality__c = nbnAddress.localityName;
            address.cscrm__Country__c = 'AUSTRALIA';
            address.cscrm__State_Province__c = nbnAddress.state;
            address.cscrm__Zip_Postal_Code__c = nbnAddress.postcode;
            
            address.cscrm__Plan_Number__c = nbnAddress.planNumber;
            address.Rural_Mail_Type__c = nbnStructured.addresses.ruralmailType;
            
            if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.streetName!=null){
                address.cscrm__Street_Name__c = nbnStructured.addresses.streetName;
            } else if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.primarySummary!=null && nbnStructured.addresses.primarySummary.streetName!=null){
                address.cscrm__Street_Name__c = nbnStructured.addresses.primarySummary.streetName;
            }
            
            if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.propertyNumberTo!=null){
                address.Street_Number_To__c = nbnStructured.addresses.propertyNumberTo;
            } else if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.primarySummary!=null && nbnStructured.addresses.primarySummary.propertyNumberTo!=null){
                address.Street_Number_To__c = nbnStructured.addresses.primarySummary.propertyNumberTo;
            }
            
            system.debug('****Street_Number_To__c :' + address.Street_Number_To__c);
            
            if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.propertyNumberFrom!=null){
                address.Street_Number_From__c = nbnStructured.addresses.propertyNumberFrom;
            } else if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.primarySummary!=null && nbnStructured.addresses.primarySummary.propertyNumberFrom!=null){
                address.Street_Number_From__c = nbnStructured.addresses.primarySummary.propertyNumberFrom;
            }else{
                address.Street_Number_From__c = nbnStructured.addresses.ruralmailNumber;
            }
            address.Street_Number_From_calc__c =address.Street_Number_From__c;
            
            system.debug('****Street_Number_From__c :' + address.Street_Number_From_calc__c);  
            
            if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.streetType!=null && nbnStructured.addresses.streetName!=null){
                address.streetType__c= nbnStructured.addresses.streetType;
            } else if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.primarySummary!=null && nbnStructured.addresses.primarySummary.streetType!=null){
                address.streetType__c= nbnStructured.addresses.primarySummary.streetType;
            } 
            
            if(nbnStructured!=null && nbnStructured.addresses!=null && nbnStructured.addresses.streetSuffix!=null){
                address.streetTypeSuffix__c= nbnStructured.addresses.streetSuffix;
            } 
            
            address.streetNumberEndSuffix__c = nbnStructured.addresses.propertyNumberSuffixTo;
            address.streetNumberStartSuffix__c = nbnStructured.addresses.propertyNumberSuffixFrom;  
            
            if(address.streetNumberStartSuffix__c==null || address.streetNumberStartSuffix__c==''){
                address.streetNumberStartSuffix__c = nbnStructured.addresses.ruralmailType;
            }
            //EDGE - 76217 : mapping additional fields
            if(nbnStructured!=null && nbnStructured.addresses!=null ){
                if( nbnStructured.addresses.subAddressNumberFrom!=null){
                    address.Sub_Address_Number__c= nbnStructured.addresses.subAddressNumberFrom;
                }
                if( nbnStructured.parcelDescriptor1!=null){
                    address.Parcel_Number__c= nbnStructured.parcelDescriptor1;
                }
                if( nbnStructured.addresses.subAddressType!=null){
                    address.Sub_Address_Type__c = nbnStructured.addresses.subAddressType;
                }
                if( nbnStructured.addresses.numSubaddresses!=null){
                    address.Number_of_Sub_addresses__c = String.valueOf(nbnStructured.addresses.numSubaddresses);
                }
                if( nbnStructured.addresses.parcelDescriptionType1!=null){
                    address.Parcel_Type__c  =   nbnStructured.addresses.parcelDescriptionType1 ;
                }
                if( nbnStructured.addresses.parcelType1!=null){
                    address.Parcel_Type_Prefix__c   =   nbnStructured.addresses.parcelType1;
                }
                if( nbnStructured.addresses.condorCode!=null){
                    address.Condor_Code__c  =   nbnStructured.addresses.condorCode;
                }
                if( nbnStructured.addresses.fsam!=null){
                    address.fsam__c =   nbnStructured.addresses.fsam;
                }
                if( nbnStructured.addresses.ruralmailNumber!=null){
                    address.Rural_Mail_Number__c    =   nbnStructured.addresses.ruralmailNumber;
                }
                if( nbnStructured.addresses.postalDeliveryNumber!=null){
                    address.Postal_Delivery_Number__c   =   nbnStructured.addresses.postalDeliveryNumber;
                }
                if( nbnStructured.addresses.postalDeliveryType!=null){
                    address.Postal_Delivery_Type__c =   nbnStructured.addresses.postalDeliveryType;
                } 
                //Kalashree Borgaonkar. Fixed as per discussion on 30-04-2019 with BA.EDGE-90329
                 if( nbnStructured.addresses.addressType!=null){
                    address.cscrm__Address_Type__c =  nbnStructured.addresses.addressType;  
                }               
                if( nbnStructured.addresses.parent==null){
                    System.debug('In parent');
                    if(nbnStructured.serviceLocation!=null && nbnStructured.serviceLocation.exchangeServiceArea!=null){
                        address.ESA_Code__c =   nbnStructured.serviceLocation.exchangeServiceArea;
                    }
                }
                else{
                    System.debug('In child');
                    System.debug('In child:'+nbnStructured.addresses.primarySummary.serviceLocation.exchangeServiceArea);
                    if(nbnStructured.addresses.primarySummary!=null){
                        System.debug('In child1:'+nbnStructured.addresses.primarySummary.serviceLocation.exchangeServiceArea);
                        address.ESA_Code__c =   nbnStructured.addresses.primarySummary.serviceLocation.exchangeServiceArea;         
                        System.debug('In child1:'+address.ESA_Code__c);
                    }
                }    
            }
            Boolean addressStatus = nbnAddress.confirmed;
            address.Address_Status__c = (addressStatus == true) ? 'Confirmed' : 'Unconfirmed';
            
            //mapping for US-706(for parent)
            if(nbnStructured.addresses.SubAddresses != null && nbnStructured.addresses.parent==null){    
                
                AddressResponseDTO.Level1[] level1;
                AddressResponseDTO.Level2[] level2;
                AddressResponseDTO.Level3[] level3;
                address.cscrm__Address_Type__c =  nbnAddress.addressType;
                // logic for building name & different address levels
                level1 = nbnStructured.addresses.Subaddresses.Level1;
                if(level1 != null & address.cscrm__Building_Name__c==null){
                    for (integer i = 0 ; i < level1.size() ; i++){
                        if(level1[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c == null && level1[i].SubAddressType == 'BUILDING') ? level1[i].BUname : address.cscrm__Building_Name__c;
                            level2 = level1[i].Level2;         
                        }
                    }
                }
                if(level2 != null && address.cscrm__Building_Name__c==null){
                    for (integer i = 0 ; i < level2.size() ; i++){
                        if(level2[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c == null && level2[i].SubAddressType == 'BUILDING') ? level2[i].BUname : address.cscrm__Building_Name__c;
                            level3 = level2[i].Level3;
                        }        
                    }
                }
                if(level3 != null && address.cscrm__Building_Name__c==null){
                    for(integer i = 0 ; i < level3.size() ; i++){
                        if(level3[i] != null){
                            address.cscrm__Building_Name__c = (address.cscrm__Building_Name__c== null && level3[i].SubAddressType == 'BUILDING') ? level3[i].BUname : address.cscrm__Building_Name__c; 
                        }
                    }
                }
                address.Connectivity_Serving_Area__c = nbnStructured.serviceLocation.customerServiceAreaId;
                //address.ESA_Code__c = nbnStructured.serviceLocation.exchangeServiceArea;
                address.FACS_Realm__c = nbnStructured.serviceLocation.facsRealm;
                latitude = nbnStructured.serviceLocation.latitude;
                longitude = nbnStructured.serviceLocation.longitude;
                address.NBN_Location_Id__c = nbnStructured.serviceLocation.locationId;
                address.Ready_For_Service_Date__c = nbnStructured.serviceLocation.readyForServiceDate;
            }
            //mapping for child address
            else {     
                
                AddressResponseDTO.Parent parent1;
                AddressResponseDTO.Parent parent2;
                AddressResponseDTO.Parent parent3;
                AddressResponseDTO.Parent parent4;
                
                //address.cscrm__Address_Type__c = nbnAddress.subAddressType;
                
                // logic for building name & subaddress levels
                if(nbnStructured != null){
                    if(nbnStructured.addresses.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && nbnStructured.addresses.subAddressType == 'BUILDING' && nbnStructured.addresses.name!=null){
                            address.cscrm__Building_Name__c = nbnStructured.addresses.name;
                        }else{
                            address.Sub_Address1_Number__c = nbnStructured.addresses.subAddressNumberFrom;
                            address.Sub_Address1_Type__c = nbnStructured.addresses.subAddressType;
                            address.Sub_Address1_Type_Code__c = nbnStructured.addresses.subAddressCodeset;
                        }
                        parent1 = nbnStructured.addresses.parent;
                    }
                }        
                if(parent1 != null){
                    address.Parent_Address_Id__c = parent1.addressId;
                    if(parent1.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent1.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent1.name;
                        }else{
                            address.Sub_Address2_Number__c = parent1.subAddressNumberFrom;
                            address.Sub_Address2_Type__c = parent1.subAddressType;
                            address.Sub_Address2_Type_Code__c = parent1.subAddressCodeset;
                        }
                        parent2 = parent1.parent;
                    }           
                }        
                if(parent2 != null){
                    if(parent2.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent2.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent2.name;
                        }else{
                            address.Sub_Address_3_Number__c = parent2.subAddressNumberFrom;
                            address.Sub_Address_3_Type__c = parent2.subAddressType;
                            address.Sub_Address_3_Type_Code__c = parent2.subAddressCodeset;
                        }
                        parent3 = parent2.parent;
                    }   
                }           
                if(parent3 != null){
                    if(parent3.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent3.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent3.name;
                        }else{
                            address.Sub_Address_4_Number__c = parent3.subAddressNumberFrom;
                            address.Sub_Address_4_Type__c = parent3.subAddressType;
                            address.Sub_Address_4_Type_Code__c = parent3.subAddressCodeset;
                        }
                        parent4 = parent3.parent;
                    }   
                }
                if(parent4 != null){
                    if(parent4.addressSummaryType == 'SubAddressSummary'){
                        if(address.cscrm__Building_Name__c == null && parent4.subAddressType == 'BUILDING'){
                            address.cscrm__Building_Name__c = parent4.name;
                        }else{
                            address.Sub_Address_4_Number__c = parent4.subAddressNumberFrom;
                            address.Sub_Address_4_Type__c = parent4.subAddressType;
                            address.Sub_Address_4_Type_Code__c = parent4.subAddressCodeset;
                        }
                    }   
                }         
                address.Connectivity_Serving_Area__c = nbnUnStructured.serviceLocation.customerServiceAreaId;
                //address.ESA_Code__c = nbnUnStructured.serviceLocation.exchangeServiceArea;
                address.FACS_Realm__c = nbnUnStructured.serviceLocation.facsRealm;
                latitude = nbnUnStructured.serviceLocation.latitude;
                longitude = nbnUnStructured.serviceLocation.longitude;
                address.NBN_Location_Id__c = nbnUnStructured.serviceLocation.locationId;
                address.Ready_For_Service_Date__c = nbnUnStructured.serviceLocation.readyForServiceDate;
            }
            // logic for geolocation
            
            if((address.cscrm__Building_Name__c==null || address.cscrm__Building_Name__c=='') && nbnStructured.addresses.primarySummary!=null && nbnStructured.addresses.primarySummary.propertyName!=null){
                address.cscrm__Building_Name__c = nbnStructured.addresses.primarySummary.propertyName;
            }
            
            if (latitude != null && latitude != '') {               
                Double latDouble = ConvertDegreesToDecimal(latitude);   
                if(latDouble!=null){
                    address.cscrm__Geolocation__Latitude__s  = latDouble;
                }   
                System.debug('address.cscrm__Geolocation__Latitude__s :'+address.cscrm__Geolocation__Latitude__s);
            }           
            if (longitude != null && longitude != '') {         
                Double longDouble = ConvertDegreesToDecimal(longitude);     
                if(longDouble!=null){
                    address.cscrm__Geolocation__Longitude__s  = longDouble;
                }           
                System.debug('address.cscrm__Geolocation__Longitude__s :'+address.cscrm__Geolocation__Longitude__s);
            }    
            
            address.latitude__c = nbnUnStructured.serviceLocation.latitude;
            system.debug('***** latitude :'+address.latitude__c);
            address.longitude__c = nbnUnStructured.serviceLocation.longitude;
            system.debug('***** longitude :'+address.longitude__c);
            
            System.debug('Address to be inserted:'+address);
            //Calling utility function to upsert address object.
            /**************** Start of Edge 85839 *****************/
            if(!isBatch) 
            upsertAddress(address);
           else
           {
               String siteName = '',addrLine1 = '',addrLine2 = '',addrLine3 = '';
               if(address.Address_Line_1__c != null && !address.Address_Line_1__c.equals('null') && !address.Address_Line_1__c.equals('0')&& !address.Address_Line_1__c.equals('-')&& !address.Address_Line_1__c.equals('_') && address.Address_Line_1__c.length()>0)
                addrLine1 = address.Address_Line_1__c;
               if(address.Address_Line_2__c != null && !address.Address_Line_2__c.equals('null') && !address.Address_Line_2__c.equals('0')&& !address.Address_Line_2__c.equals('-')&& !address.Address_Line_2__c.equals('_') && address.Address_Line_2__c.length()>0)
                addrLine2 = address.Address_Line_2__c;
               if(address.Address_Line_3__c != null && !address.Address_Line_3__c.equals('null') && !address.Address_Line_3__c.equals('0')&& !address.Address_Line_3__c.equals('-')&& !address.Address_Line_3__c.equals('_') && address.Address_Line_3__c.length()>0)
                addrLine3 = address.Address_Line_3__c;
                
               if(addrLine1.length()>0)
                siteName = addrLine1;
               if(addrLine2.length()>0)
               {
                   if(addrLine1.length()>0)
                    siteName = addrLine1+' '+addrLine2;
                   else
                    siteName = addrLine2;
               }
              siteName = siteName +' '+addrLine3+' '+address.Locality__c+ ' '+address.cscrm__State_Province__c+' '+address.cscrm__Zip_Postal_Code__c;
              siteName  = siteName.replace(' ', '  ');
              address.Name = siteName.trim();
              system.debug('siteName-------->'+siteName);
              system.debug('address-------->'+address);
           }
            /**************** End of Edge 85839 *****************/
        }   
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e.getMessage());
        }        
        return address;
    }
    /**************** End of Edge 85839 *****************/
    
    /*methos for not allowing null in address name concatenation
public static String checkNull(String variable){
if(variable==null){
return '';
}
return variable;
} 
*/
    //Common utility method to split address name in address lines depending on length (NFB-3190)
    
    public static cscrm__Address__c splitAddressName(cscrm__Address__c address, Integer adddressNameSize, String name){
        try{
            address.Address_Line_1__c = null;
            address.Address_Line_2__c = null;
            address.Address_Line_3__c = null;
            if (name != null && name.length()  >= adddressNameSize && name.length() < (adddressNameSize + 40)) {
                address.Address_Line_1__c = name.substring(adddressNameSize, name.length());
            }         
            else if (name != null && name.length()  >= (adddressNameSize + 40) && name.length() < (adddressNameSize + 80)) {
                address.Address_Line_1__c = name.substring(adddressNameSize, (adddressNameSize + 40));
                address.Address_Line_2__c = name.substring((adddressNameSize + 40), name.length());
            }
            else if (name != null && name.length()  >= (adddressNameSize + 80) && name.length() < (adddressNameSize + 120)) {
                address.Address_Line_1__c = name.substring(adddressNameSize, (adddressNameSize + 40));
                address.Address_Line_2__c = name.substring((adddressNameSize + 40), (adddressNameSize + 80));
                address.Address_Line_3__c = name.substring((adddressNameSize + 80), name.length());
            }  
            else if (name != null && name.length() > adddressNameSize + 120){
                address.Address_Line_1__c = name.substring(adddressNameSize, (adddressNameSize + 40));
                address.Address_Line_2__c = name.substring((adddressNameSize + 40), (adddressNameSize + 80));
                address.Address_Line_3__c = name.substring((adddressNameSize + 80), (adddressNameSize + 120));
            }
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        System.debug('SplitAddressName: '+address);
        return address;
    }  
    //end 
    
    /*Method to retrieve Replicator Site and Address details from Replicator DTO which needs to be upserted*/
    public static ReplicatorGetSiteDataObject.SiteDTO getReplicatorSiteAddrToBeInserted(String adborID, ReplicatorGetSiteDataObject replicatorAddress){
        ReplicatorGetSiteDataObject.SiteDTO addressToBeInserted=null;
        try{
            if(adborID != null){
                for( ReplicatorGetSiteDataObject.SiteDTO site:ReplicatorAddress.Site){
                    if(site.adbor_id == adborID) {
                        addressToBeInserted = site;
                    }
                }
            }
            else{
                addressToBeInserted = ReplicatorAddress.Site.get(0);
            }
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        System.debug('Address to be Inserted :'+addressToBeInserted);
        return addressToBeInserted;
    }
    
    public static void upsertReplicatorAddressAsync(String[] adborID,String ReplicatorAddress){
        AddressRequestDTO req;
        //AddressResponseDTO res;
        try{
            if(adborID.size()==1){
                req=createRequestDTO(adborID[0]);
                AddressValidateManager.searchAddressByAdborIdAsync(req);
                /*if(res!=null){
AddressAndSiteObjectUtility.upsertNBNEastAddress(res);
}*/
            }
            else{
                for (Integer i = 0; i < adborID.size(); i++) {
                    System.debug('in here utility');
                    req=createRequestDTO(adborID[i]);
                    AddressValidateManager.searchAddressByAdborIdAsync(req);      
                } 
            }                           
        }catch(Exception e){
            System.debug('Exception occured in Async East callout:'+e);
            Logger.getLogger(EASTAddressDataObjectUtils.class).debug(e);
            throw(e);
        }
    }
    
    public static AddressRequestDTO createRequestDTO(String adborID){
        AddressRequestDTO req;
        try{
            req=new AddressRequestDTO();
            req.data =new AddressRequestDTO.Data();
            req.data.adborId=adborID;
        }catch(Exception e){
            System.debug('Exception occured in creating RequestDTO:'+e);
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            throw(e);
        }
        System.debug('RequestDTO:'+req.data);
        return req; 
    }
    
    /*Method to upsert Site & Address provided by Replicator Interface*/
    public static AuraProcessingMessage upsertReplicatorAddressAndSiteList(String[] adborID, ReplicatorGetSiteDataObject replicatorAddress){
        AuraProcessingMessage auraMsg = new AuraProcessingMessage();//Added Changes Regarding EDGE-71954
        try{
            for (Integer i = 0; i < adborID.size(); i++) {                          
                auraMsg=upsertReplicatorAddressAndSite(adborID[i],replicatorAddress);
            } 
        }catch(SiteUnconfirmedException e){
            Logger.getLogger(EASTAddressDataObjectUtils.class).debug(e);
            Logger.exitLogger();
        }/***********End of NFB-3038*************/
        catch(AddressCreationException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return auraMsg;
    }
    
    /*Upsert Replicator Address and Site*/
    public static AuraProcessingMessage upsertReplicatorAddressAndSite(String adborID, ReplicatorGetSiteDataObject replicatorAddress){
        AuraProcessingMessage auraMsg= new AuraProcessingMessage();
        cscrm__Address__c address;
        try{                        
            auraMsg = UpsertReplicatorAddress(adborID,replicatorAddress);
            if(auraMsg.isSuccess==true){
                address = getExistingAddressFromSF(adborID);
                if(address.Address_Status__c == 'CONFIRMED'){
                    auraMsg = upsertReplicatorSite(adborID,replicatorAddress,address.Id);
                }else{
                    auraMsg.isSuccess = false;
                    auraMsg.errorMsg = Label.ERROR_MESSAGE_SITE_CREATION_ADDR_UNCONFIRMED;
                    throw new SiteUnconfirmedException(Label.ERROR_MESSAGE_SITE_CREATION_ADDR_UNCONFIRMED);
                }
            }else{
                System.debug('Address creation failed');
                throw new AddressCreationException('Address creation failed');
            }
        }catch(SiteUnconfirmedException e){
            Logger.getLogger(EASTAddressDataObjectUtils.class).debug(e);
            Logger.exitLogger();
        }
        catch(AddressCreationException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return auraMsg;
    }
    
    /*Method to upsert address provided by Replicator Interface*/
    public static AuraProcessingMessage upsertReplicatorAddress(String adborID, ReplicatorGetSiteDataObject replicatorAddress){
        AuraProcessingMessage msg=new AuraProcessingMessage();
        cscrm__Address__c address;
        String addStatus='';
        String envAdddressNameSize;
        Integer adddressNameSize;
        ReplicatorGetSiteDataObject.SiteDTO addressToBeInserted;
        try{
            Map<String,String> status = new Map<String,String>();
            status.put('CO', 'CONFIRMED');
            status.put('UN', 'UNCONFIRMED');
            status.put('LO', 'LOGICALLY');
            status.put('DO', 'DELETED');
            envAdddressNameSize = EnvironmentVariable.get('east_result_ui_address_name_text_size');
            adddressNameSize = (envAdddressNameSize != null && envAdddressNameSize != '') ? integer.valueof(envAdddressNameSize) : 68;
            addressToBeInserted = getReplicatorSiteAddrToBeInserted(adborID,replicatorAddress);
            address = checkForAddress(adborId);
            address.Address_ID__c  = addressToBeInserted.adbor_id;
            // if(address.Source_System__c==null || address.Source_System__c=='' || address.Source_System__c=='Replicator' || address.Source_System__c=='TCM'){
            // address.Source_System__c = 'Replicator';
                String addressStatus=status.get(addressToBeInserted.Site_Address_Status);
                System.debug('Address Status in'+address.Address_Status__c+addressStatus);
                if(addressStatus!=null){
                    address.Address_Status__c =addressStatus;
                }                    
                //address.cscrm__Street_Number_Start__c = addressToBeInserted.address_no_from + addressToBeInserted.suffix_from;
                //address.cscrm__Street_Number_End__c = addressToBeInserted.address_no_to + addressToBeInserted.suffix_to;
                address.cscrm__Street_Name__c   = addressToBeInserted.Street_Name;
                //address.cscrm__Street_Type__c   = addressToBeInserted.Street_Type;
                address.Locality__c = addressToBeInserted.loc_name;
                address.cscrm__State_Province__c = addressToBeInserted.State;
                address.cscrm__Zip_Postal_Code__c = addressToBeInserted.ADBoR_Postcode;
                //address.Sub_Address_Level_1__c = addressToBeInserted.Sub1_CodeSet_Abbrev+' '+addressToBeInserted.Sub1_Descriptor_1+' '+addressToBeInserted.Sub1_Descriptor_2;
                //address.Sub_Address_Level_2__c = addressToBeInserted.Sub2_CodeSet_Abbrev+' '+addressToBeInserted.Sub2_Descriptor_1+' '+addressToBeInserted.Sub2_Descriptor_2;
                //address.Sub_Address_Level_3__c = addressToBeInserted.Sub3_CodeSet_Abbrev+' '+addressToBeInserted.Sub3_Descriptor_1+' '+addressToBeInserted.Sub3_Descriptor_2;
                //address.Sub_Address_Level_4__c = addressToBeInserted.Sub4_CodeSet_Abbrev+' '+addressToBeInserted.Sub4_Descriptor_1+' '+addressToBeInserted.Sub4_Descriptor_2;
                address.Street_Number_To__c=addressToBeInserted.Address_No_To;
                address.Street_Number_From_calc__c=addressToBeInserted.Address_No_From;
                address.streetType__c=addressToBeInserted.Street_Type;
                address.streetNumberStartSuffix__c=addressToBeInserted.Suffix_From;
                address.streetNumberEndSuffix__c=addressToBeInserted.Suffix_To;
                address.Sub_Address2_Number__c=addressToBeInserted.Sub2_Descriptor_1;
                address.Sub_Address2_Type__c=addressToBeInserted.Sub2_CodeSet_Abbrev;
                address.Sub_Address1_Number__c=addressToBeInserted.Sub1_Descriptor_1;
                address.Sub_Address1_Type__c=addressToBeInserted.Sub1_CodeSet_Abbrev;
                address.Sub_Address_3_Number__c=addressToBeInserted.Sub3_Descriptor_1;
                address.Sub_Address_3_Type__c=addressToBeInserted.Sub3_CodeSet_Abbrev;
                address.Sub_Address_4_Number__c=addressToBeInserted.Sub4_Descriptor_1;
                address.Sub_Address_4_Type__c=addressToBeInserted.Sub4_CodeSet_Abbrev;
                if(addressToBeInserted.rfs_date != null && addressToBeInserted.rfs_date !=''){
                    address.Ready_For_Service_Date__c  = addressToBeInserted.rfs_date;
                }
                
            //}
            
            System.debug('Final address :'+address);
            //Upsert address record in SF.
            msg=UpsertAddress(address);
            System.debug('Address Upserted successfully');
            upsertEnterpriseId(replicatorAddress.CIDN ,replicatorAddress.Enterprise_Id);
            
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return msg;
    }
    
    //Fetching account details which needs to be updated with enterpriseId
    public static void upsertEnterpriseId(String cidn, String enterpriseId){
        Account account= new Account();//Added Changes Regarding EDGE-71954
        try{    
            objectString='Account';
            objectFields='Id , Enterprise_ID__c';
            if(checkAccessibility(objectString,objectFields)){     
                account = Database.query('SELECT Id , Enterprise_ID__c FROM Account WHERE CIDN__c=:cidn LIMIT 1');
            }
            account.Enterprise_ID__c = enterpriseId;
            update account;
            System.debug('Account updated with Enterprise_Id :'+account.Enterprise_ID__c);
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
    }
    /*Method to upsert site provided by Replicator Interface*/
    public static AuraProcessingMessage upsertReplicatorSite(String adborID,ReplicatorGetSiteDataObject replicatorAddress,Id addId){
        AuraProcessingMessage returnMessage = new AuraProcessingMessage();
        cscrm__Site__c site;
        cscrm__Address__c address;
        ReplicatorGetSiteDataObject.SiteDTO siteToBeInserted;
        Id accountId;
        List<Account> accountList= new List<Account>();//Added Changes Regarding EDGE-71954
        List<cscrm__Site__c> sites= new List<cscrm__Site__c>();
        String strCIDN = '';
        try{
            returnMessage = new AuraProcessingMessage();
            siteToBeInserted = getReplicatorSiteAddrToBeInserted(adborID,replicatorAddress);         
            site = new cscrm__Site__c();
            if(addId!=null){
                site.cscrm__Installation_Address__c = addId;
            }else{
                returnMessage.isSuccess = false;
                returnMessage.errorMsg = Label.ERROR_MESSAGE_SITE_CREATION_ADDR_NOT_FOUND;
                throw new SiteCreationFailedAddrNotFoundException(Label.ERROR_MESSAGE_SITE_CREATION_ADDR_NOT_FOUND);
            }
            objectString='Account';
            objectFields='Id';
            strCIDN = replicatorAddress.CIDN;
            if(checkAccessibility(objectString,objectFields)){
                accountList = Database.query('select id from Account where CIDN__c = :strCIDN');
            }
            if(accountList!=null && accountList.size()!=0){
                accountId = accountList.get(0).Id;
            }else{
                returnMessage.isSuccess = false;
                returnMessage.errorMsg = Label.ERROR_MESSAGE_SITE_CREATION_ACC_NOT_FOUND;
                throw new SiteCreationFailedAccountNotFoundException(Label.ERROR_MESSAGE_SITE_CREATION_ACC_NOT_FOUND);
            }
            
            site.Legacy__c=true; //EDGE-72118
            
            /*************** End of NFB-3039 ******************/
            site.cscrm__Account__c = accountId;
            site.Media_Type__c = siteToBeInserted.media_type;
            site.Site_Nick_Name__c = siteToBeInserted.site_nick_name;
            /*if(site.Site_Nick_Name__c!=null || site.Site_Nick_Name__c!=''){
site.Name=site.Site_Nick_Name__c;
}*/
            
            /**************** Start of Edge 108 *****************/
            if(site.Site_Nick_Name__c==null || site.Site_Nick_Name__c==''){
                String StreetNo = '';
                /**
                *   @Description - If site name is start with '0' or 'null' or BLANK values then ignore value.
                *   @Jira Story Ref - EDGE-77460
                *   @ModifiedBy - Ramesh Somalagari,OSAKA
                **/
                System.debug('siteToBeInserted :: '+siteToBeInserted);
                if(siteToBeInserted.Address_No_To==null || siteToBeInserted.Address_No_To=='')
                {
                    StreetNo = siteToBeInserted.Address_No_From; 
                }else{
                    //StreetNo = siteToBeInserted.Address_No_From + ' - ' + siteToBeInserted.Address_No_To;
                    if(siteToBeInserted.Address_No_From != null && !siteToBeInserted.Address_No_From.trim().equals('0') && !siteToBeInserted.Address_No_From.trim().equals('null'))
                        StreetNo = siteToBeInserted.Address_No_From;
                    if(siteToBeInserted.Address_No_To != null && !siteToBeInserted.Address_No_To.trim().equals('0') && !siteToBeInserted.Address_No_To.trim().equals('null')){
                        if(StreetNo != '')
                            StreetNo = StreetNo +' - '+ siteToBeInserted.Address_No_To;
                        else
                            StreetNo = siteToBeInserted.Address_No_To;
                        
                    }
                        
                }
                StreetNo = StreetNo.trim();
                if((StreetNo + ' ' + siteToBeInserted.Street_Name + ' '  + siteToBeInserted.Street_Type + ' '  + siteToBeInserted.Loc_Name).length()<80){
                    site.Site_Nick_Name__c=StreetNo + ' ' + siteToBeInserted.Street_Name + ' '  + siteToBeInserted.Street_Type + ' '  + siteToBeInserted.Loc_Name;
                }else{
                    site.Site_Nick_Name__c=(StreetNo + ' ' + siteToBeInserted.Street_Name + ' '  + siteToBeInserted.Street_Type + ' '  + siteToBeInserted.Loc_Name).subString(0,80);
                }
                site.Site_Nick_Name__c = site.Site_Nick_Name__c.trim();
            }
            //Changes as per EDGE 27237
            if(site.Site_Nick_Name__c==null || site.Site_Nick_Name__c=='' || site.Site_Nick_Name__c=='   '){
                site.Site_Nick_Name__c='Default Site Name';
            }
            site.Name=site.Site_Nick_Name__c;
            /**************** End of Edge 108 *****************/
            site.Disconnection_Date__c = siteToBeInserted.disconnection_date;
            site.In_Flight_Order__c = siteToBeInserted.in_flight_order;
            site.Servicability__c = siteToBeInserted.serviceability;
            site.Disconnect_wave__c = siteToBeInserted.disconnect_wave;
            site.Site_Composition__c = siteToBeInserted.site_composition;
            site.Order_Stability_Date__c = siteToBeInserted.order_stability_date;
            site.Service_Class__c = siteToBeInserted.service_class;
            site.Site_Migration_Flag__c=siteToBeInserted.Site_Migration_Flag;
            site.Composite_Key__c=replicatorAddress.CIDN+adborID;
            String upsertResult=siteSaveUtility(site);
            System.debug('upsertResult :'+upsertResult);
            
            if(('Failed').equals(upsertResult))//Added Changes Regarding EDGE-71954
            {
                returnMessage.isSuccess = false;
                returnMessage.errorMsg = Label.ERROR_MESSAGE_SITE_CREATION;
                throw new SiteCreationFailedException(Label.ERROR_MESSAGE_SITE_CREATION);
            }
            System.debug('Upsert successful'); 
            returnMessage.successMsg=Label.SUCCESS_MESSAGE_SITE_CREATION;
        }catch(SiteCreationFailedException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }catch(SiteCreationFailedAddrNotFoundException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }catch(SiteCreationFailedAccountNotFoundException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }catch(Exception e){
            returnMessage.isSuccess = false;
            returnMessage.errorMsg = e.getMessage();
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return returnMessage;
    }
    
    
    
    
    //Utility function to upsert Address record in SF db.
    public static AuraProcessingMessage upsertAddress(cscrm__Address__c address){
        AuraProcessingMessage returnMessage=new AuraProcessingMessage();
        try{
            
            Schema.SObjectField addresID = cscrm__Address__c.Fields.Address_ID__c;
            Database.UpsertResult result = Database.upsert(address, addresID, false);
            System.debug('Address UpsertResult :'+result);
            if(result.isSuccess()==true){
                returnMessage.isSuccess = true;
                returnMessage.SuccessMsg = 'Address created successfully';
            }else{
                returnMessage.isSuccess = false;
                returnMessage.errorMsg = 'Error in Address creation';
            }  
        }
       catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            System.debug(e);
        }
        return returnMessage;
    }
    /*****************End of NFB-2815**************************/
    
    /*
* NFB-3783-Validation rule to check inflight orders in SFDC
* Parameter :
*       adbor_id : Adbord_ID of Selected Site
*       cidn: It's customer Id will used to check inflight orders in SFDC
* Return : Aura Message
*/
    public static AuraProcessingMessage inFlightCheck(String adborId, String cidn){
        AuraProcessingMessage returnMessage;
        List<Account> accountList= new List<Account>();//Added Changes Regarding EDGE-71954
        List<cscrm__Site__c> sitesList = new List<cscrm__Site__c>();//Added Changes Regarding EDGE-71954
        try{
            returnMessage=new AuraProcessingMessage();
            objectString='Account';
            objectFields='Id';
            if(checkAccessibility(objectString,objectFields)){
                accountList = Database.query('select id from Account where CIDN__c = :cidn');             
            }
            String compositeKey = cidn + adborId;
            objectString='cscrm__Site__c';
            objectFields='address_id__c, Composite_Key__c';
            if(checkAccessibility(objectString,objectFields)){
                sitesList = Database.query('SELECT address_id__c, Composite_Key__c FROM cscrm__Site__c WHERE Composite_Key__c = :compositeKey');
            }
            
            Set<String> stageSet = OrderStages__c.getAll().keySet();
            if(accountList!=null && sitesList!=null && accountList.size() != 0 && sitesList.size() != 0 && stageSet.size() != 0){
                checkForInFlightCheckIn(accountList,sitesList);
            }
            if(orderSubList.size() != 0 || attrFilteredList.size() != 0){
                returnMessage=setMessageForInflightCheckIn();
            }
            else{
                returnMessage.isSuccess = false;
            }
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return returnMessage;
    }
    //EDGE-89
    public static String addressRelSaveUtility (cscrm__Account_Address_Relationship__c accountAddress){
        AuraProcessingMessage auraMsg = new AuraProcessingMessage();
        try{
            Database.UpsertResult upsertResult= Database.upsert(accountAddress);
            if (!upsertResult.isSuccess()){
                system.debug('upsertResult.Errors : ' + upsertResult.getErrors());
                auraMsg.isSuccess = false;
                auraMsg.errorMsg = Label.Account_Address_Rel_Creation_Failed;
                return JSON.serialize(auraMsg);   
            }else{
                auraMsg.isSuccess = true;
                auraMsg.successMsg = Label.Contact_Address_Rel_Creation_Succeed;
                return JSON.serialize(auraMsg);
            }
        }
        catch(DmlException dmlExp){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(dmlExp);
            Logger.exitLogger();
            
            String exactErrMsg = '';
            system.debug('dmlExp :>> ' + dmlExp);
            exactErrMsg = dmlExp.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION: ' , ' You can look up ExceptionCode');
            if(String.isBlank(exactErrMsg))
            {
                exactErrMsg = dmlExp.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': []');  
            }
            
            system.debug('FIELD_CUSTOM_VALIDATION_EXCEPTION : ' + exactErrMsg);
            auraMsg.isSuccess = false;
            auraMsg.errorMsg = String.isNotBlank(exactErrMsg)?exactErrMsg:dmlExp.getMessage();
            return JSON.serialize(auraMsg);
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            auraMsg.isSuccess = false;
            auraMsg.errorMsg = Label.Account_Address_Rel_Creation_Failed;
            return JSON.serialize(auraMsg);
        }
    }
    /*
     * @Jira :EDGE-72118
     * Method:Using Data Coming from Replicator , Address is fetched from East and Upsert address and site
    
    */
    Public static void upsertEastAddressAndSite(String[] adborID, ReplicatorGetSiteDataObject replicatorAddress){
        
        AddressRequestDTO req;
        //AddressResponseDTO res;
        try{
            
            for (String adborIDs:adborID ){
                System.debug('****in here utility'+adborIDs);
                req=createRequestDTO(adborIDs);
                System.debug('***req :'+req);
                ID JobId= System.enqueueJob(new NBNEastCallout(req,adborIDs,replicatorAddress));
                //  AddressValidateManager.searchAddressByAdborIdAsync(req); 
                // AddressAndSiteObjectUtility.upsertReplicatorAddressAndSite(adborIDs,replicatorAddress);
                
                
            }                           
        }catch(Exception e){
            System.debug('Exception occured in Async East callout:'+e);
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            throw(e);
        }
        
    }
    public static List<SelectOptionz> getContactAddressTypes()
    {
        List<SelectOptionz> options = new List<SelectOptionz>();
        
        Schema.DescribeFieldResult fieldResult =
            cscrm__Contact_Address_Relationship__c.cscrm__Address_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOptionz(f.getLabel(), f.getValue()));
        }      
        return options;
    }    
    public static string contactAddressRelSaveUtility (cscrm__Contact_Address_Relationship__c contactAddress){
        AuraProcessingMessage auraMsg = new AuraProcessingMessage();
        try{
            Database.UpsertResult upsertResult= Database.upsert(contactAddress);
            if (!upsertResult.isSuccess()){
                auraMsg.isSuccess = false;
                auraMsg.errorMsg = Label.ContactAddressRelCreationFailed;
                return JSON.serialize(auraMsg);   
            }else{
                auraMsg.isSuccess = true;
                auraMsg.successMsg = Label.Contact_Address_Rel_Creation_Succeed;
                return JSON.serialize(auraMsg);
            }
        }
        catch(DmlException dmlExp){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(dmlExp);
            Logger.exitLogger();
            
            String exactErrMsg = '';
            exactErrMsg = dmlExp.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION: ' , ' You can look up ExceptionCode');
            if(String.isBlank(exactErrMsg))
            {
                exactErrMsg = dmlExp.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ' , ': []');  
            }
            system.debug('FIELD_CUSTOM_VALIDATION_EXCEPTION : ' + exactErrMsg);
            auraMsg.isSuccess = false;
            auraMsg.errorMsg = String.isNotBlank(exactErrMsg)?exactErrMsg:dmlExp.getMessage();
            return JSON.serialize(auraMsg);
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            auraMsg.isSuccess = false;
            auraMsg.errorMsg = Label.ContactAddressRelCreationFailed;
            return JSON.serialize(auraMsg);
        }
    }
    //
    public static List<SelectOptionz> getaddressTypes()
    {
        List<SelectOptionz> options = new List<SelectOptionz>();
        
        Schema.DescribeFieldResult fieldResult =
            cscrm__Account_Address_Relationship__c.cscrm__Address_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOptionz(f.getLabel(), f.getValue()));
        }      
        return options;
    } 
    //Common upsert utility for site
    public static String siteSaveUtility (cscrm__Site__c site){
        try{
            Schema.SObjectField compositekey = cscrm__Site__c.Fields.Composite_Key__c;
            Database.UpsertResult upsertResult= Database.upsert(site,compositekey,false);
            if (!upsertResult.isSuccess()){
                return 'Failed';   
            }else{
                return 'Success';
            }
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
            return 'Failed';
        }
    }
    
    private static cscrm__Address__c checkForAddress(String adborId)
    {       
        cscrm__Address__c address;
        try{
            address = getExistingAddressFromSF(adborId);
            if(address==null){
                address = new cscrm__Address__c();
                address.Source_System__c = '';
            }
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }       
        return address;
    }
    @testVisible
    private static void checkForInFlightCheckIn(List<Account> accountList,List<cscrm__Site__c> sitesList){
        try{
            System.debug('checkForInFlightCheckIn');
            objectString='csord__Subscription__c';
            objectFields='csordtelcoa__Subscription_Number_Sequence__c';
            if(checkAccessibility(objectString,objectFields)){
                orderSubList = [Select csord__Order__r.csord__Order_Number__c, csordtelcoa__Subscription_Number_Sequence__c, csord__Order__r.csord__Status__c FROM csord__Subscription__c WHERE Site__c =: sitesList[0].id AND csord__Account__c =: accountList[0].id AND csord__Order__r.csord__Product_Type__c =:Label.BusinessBundle AND csord__Order__r.csord__Status__c NOT IN:OrderStages__c.getAll().keySet()];
            }
            objectString='cscfga__Attribute__c';
            objectFields='cscfga__Value__c';
            if(checkAccessibility(objectString,objectFields)){    
                attrList = [Select cscfga__Value__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Basket_ID__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c FROM cscfga__Attribute__c WHERE Name=:Label.SiteId AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c !=:Label.BasketStageCancelled AND cscfga__Product_Configuration__r.Name LIKE :('%'+Label.BusinessBundle+'%') AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c =: accountList[0].id];
            }
            System.debug('attrList<><><>'+attrList);
            for(cscfga__Attribute__c attr: attrList){
                if(attr.cscfga__Value__c == sitesList[0].id){
                    attrFilteredList.add(attr);
                }
            }
            System.debug('attrList!!!!'+attrFilteredList);
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }   
    }
    @testVisible
    private static AuraProcessingMessage setMessageForInflightCheckIn(){
        AuraProcessingMessage returnMessage;
        try{
            returnMessage=new AuraProcessingMessage();
            String[] tempSubscription = New String[]{};
                String[] tempAttribute = New String[]{};
                    String idStringForSubscription;
            String idStringForAttribute;
            for(csord__Subscription__c sub : orderSubList){
                tempSubscription.add(sub.csord__Order__r.csord__Order_Number__c);
            }
            idStringForSubscription = string.join(tempSubscription,',');
            for(cscfga__Attribute__c attr : attrFilteredList){
                tempAttribute.add(attr.cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Basket_ID__c);
            }
            idStringForAttribute = string.join(tempAttribute,',');
            if(orderSubList.size() != 0 && attrFilteredList.size() == 0 ){
                returnMessage.isSuccess = true;
                returnMessage.errorMsg = Label.InFlightOrderFound+' '+idStringForSubscription;
            }
            if(attrFilteredList.size() != 0 && orderSubList.size() == 0){
                returnMessage.isSuccess = true;
                returnMessage.errorMsg = Label.ActiveBasketFound+' '+idStringForAttribute;
            }
            if(orderSubList.size() != 0 && attrFilteredList.size() != 0){
                returnMessage.isSuccess = true;
                returnMessage.errorMsg = Label.InFlightOrderFound+' '+idStringForSubscription+'. '+Label.ActiveBasketFound+' '+idStringForAttribute;
            }
        }catch(Exception e){
            System.debug('Exception<><>'+e);
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return returnMessage;
    }
    
    //check FLS for object before SOQL/DML
    public static Boolean checkAccessibility(String sObjectType, String commaDelimitedFields){   
        try{
            SObjectType schemaType = Schema.getGlobalDescribe().get(sObjectType);
            Map<String, SObjectField> fieldMap = schemaType.getDescribe().fields.getMap();
            
            for (String fieldName : commaDelimitedFields.split(',')){
                System.debug(fieldName);
                
                if (!fieldMap.get(fieldName.trim()).getDescribe().isAccessible())
                    return false;
            }
            return true;
        }catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        return false;
    }
    
    //Convert DMS(Degree,Minute,Second) to Double. Used for Geolocation field
    
    public static double  ConvertDegreesToDecimal(string coordinate)
        
    {
        double decimalCoordinate=0;//Added Changes Regarding EDGE-71954
        string[] coordinateArray = coordinate.Split(':');
        if (3 == coordinateArray.size())
        {
            double degrees = Double.valueOf(coordinateArray[0]);
            double minutes = Double.valueOf(coordinateArray[1]) / 60;
            double seconds = Double.valueOf(coordinateArray[2]) / 3600;
            
            if (degrees > 0)
            {
                decimalCoordinate = (degrees + minutes + seconds);
            }
            else
            {
                decimalCoordinate = (degrees - minutes - seconds);
            }
        }
        return decimalCoordinate;
    }  
    
    
    /*Utility Method for Saving the Address returned from EAST interface to Salesforce*/
    public static CustomerObject.Address getAddressForTCM(String adborId){
        CustomerObject.Address tcmAddress = new CustomerObject.Address();
        cscrm__Address__c address;
        List<cscrm__Address__c> addrs;
        AuraProcessingMessage msg;
        try{
            addrs =  Database.query('SELECT Address_ID__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Address_Status__c,cscrm__Building_Name__c,Locality__c,cscrm__Plan_Number__c,cscrm__State_Province__c,cscrm__Street_Name__c,Street_Number_End_calc__c,Street_Number_Start_calc__c,streetNumberEndSuffix__c,streetNumberStartSuffix__c,Street_Type_calc__c,TCM_Street_Type_code__c,streetTypeSuffix__c,cscrm__Zip_Postal_Code__c FROM cscrm__Address__c WHERE Address_ID__c =:adborId');
            address = addrs.get(0);
        }catch(AddressNotFoundException e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        catch(Exception e){
            Logger.getLogger(AddressAndSiteObjectUtility.class).debug(e);
            Logger.exitLogger();
        }
        List<String> addressLine = new List<String>();
        addressLine.add(address.Address_Line_1__c);
        addressLine.add(address.Address_Line_2__c);
        addressLine.add(address.Address_Line_3__c);
        tcmAddress.addressId                    = address.Address_ID__c;
        tcmAddress.subAddress                   = new CustomerObject.SubAddress();
        tcmAddress.subAddress.addressLines      = addressLine;
        tcmAddress.status                       = address.Address_Status__c;
        tcmAddress.subAddress.propertyName      = address.cscrm__Building_Name__c;
        tcmAddress.country                      = 'AUSTRALIA';
        tcmAddress.locality                     = address.Locality__c;
        tcmAddress.registeredPlan               = address.cscrm__Plan_Number__c;
        tcmAddress.state                        = address.cscrm__State_Province__c;
        tcmAddress.streetName                   = address.cscrm__Street_Name__c;
        tcmAddress.streetNumberEnd              = address.Street_Number_End_calc__c;
        tcmAddress.streetNumberStart            = address.Street_Number_Start_calc__c;
        tcmAddress.streetNumberEndSuffix        = address.streetNumberEndSuffix__c;
        tcmAddress.streetNumberStartSuffix      = address.streetNumberStartSuffix__c;
        tcmAddress.streetType                   = address.Street_Type_calc__c;
        tcmAddress.streetTypeCode               = address.TCM_Street_Type_code__c;
        tcmAddress.streetTypeSuffix             = address.streetTypeSuffix__c;
        tcmAddress.postalCode                   = address.cscrm__Zip_Postal_Code__c;
        return tcmAddress;
    }
    
}
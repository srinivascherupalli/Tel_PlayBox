/**
 * Class for address summary.
 */
public class AddressSummary {

    //EastAddress object fields
    @AuraEnabled
    public Integer responseStatus {get; set;}
    @AuraEnabled
    public String addNotFound {get; set;}
    @AuraEnabled
    public String accountId {get; set;}
    @AuraEnabled
    public String addressId {get; set;}
    @AuraEnabled
    public String name {get; set;}


    @AuraEnabled
    public String addressType {get; set;}
    @AuraEnabled
    public String confirmed {get; set;}
    @AuraEnabled
    public String propertyNumberFrom {get; set;}
    @AuraEnabled
    public String propertyNumberTo {get; set;}
    @AuraEnabled
    public String serLocLat {get; set;}
    @AuraEnabled
    public String serLocLong {get; set;}
    @AuraEnabled
    public String serLocReady {get; set;}
    @AuraEnabled
    public String serLocXchange {get; set;}
    @AuraEnabled
    public String serLocFace {get; set;}
    @AuraEnabled
    public String postalDeliveryType {get; set;}
    @AuraEnabled
    public String postalDeliveryNumber {get; set;}
    @AuraEnabled
    public String customerServiceAreaId {get; set;}
    @AuraEnabled
    public String planNumber {get; set;}
    @AuraEnabled
    public String status {get; set;}
    @AuraEnabled
    public String numberStart {get; set;}
    @AuraEnabled
    public String numberPrefix {get; set;}
    @AuraEnabled
    public String numberSuffix {get; set;}
    @AuraEnabled
    public String numberTo {get; set;}
    @AuraEnabled
    public String numberToPrefix {get; set;}
    @AuraEnabled
    public String numberToSuffix {get; set;}
    @AuraEnabled
    public String streetName {get; set;}
    @AuraEnabled
    public String streetType {get; set;}
    @AuraEnabled
    public String streetTypeSuffix {get; set;}
    @AuraEnabled
    public String locality {get; set;}
    @AuraEnabled
    public String greaterLocality {get; set;}
    @AuraEnabled
    public String state {get; set;}
    @AuraEnabled
    public String postcode {get; set;}
    @AuraEnabled
    public String lat {get; set;}
    @AuraEnabled
    public String longZ {get; set;} // in json: long
    @AuraEnabled
    public String numberOfSubAddresses {get; set;}
   
    //Owner:Akshay Deuskar | Date: 24-May-17 | Added for new fields NBN Status and 
    //                                         Rural Mail Type as part of US NFB-1218
    @AuraEnabled
    public String nbnStatus {get; set;}
    @AuraEnabled
    public String ruralMailType {get; set;}
    
    //SubAddress Array Fields
    @AuraEnabled
    public String parentAddressId {get; set;}
    @AuraEnabled
    public String subAddressType {get; set;}
    @AuraEnabled
    public String subAddressNumber {get; set;}
    //ServiceLocation Array Fields
    @AuraEnabled
    public String readyForServiceDate {get; set;}
    @AuraEnabled
    public String condorCode {get; set;}
     @AuraEnabled
    public String subAddressCodeset {get; set;}
     @AuraEnabled
    public String parcelDescriptor1 {get; set;}
     @AuraEnabled
    public String ParcelNumber {get; set;}
     @AuraEnabled
    public String parcelType {get; set;}
     @AuraEnabled
    public String ruralmailNumber {get; set;}
    
    
    @AuraEnabled
    public String locationId {get; set;}
    @AuraEnabled
    public String connectivityServiceAreaId {get; set;}
    @AuraEnabled
    public String exchangeServiceAreaId {get; set;}
    @AuraEnabled
    public String facsRealm {get; set;}
    //UI specific fields

    @AuraEnabled
    public String addressLine {get; set;}
    @AuraEnabled
    public String subAddressLine {get; set;}

    //NFB-3190 specific fields
    
    @AuraEnabled
    Public String subAddresslevel1{get; set;}
    @AuraEnabled
    Public String subAddresslevel2{get; set;}
    @AuraEnabled
    Public String subAddresslevel3{get; set;}
    @AuraEnabled
    Public String subAddresslevel4{get; set;}
    
    //NFB-4099
    @AuraEnabled
    Public String addrNumLvl1{get; set;}
    @AuraEnabled
    Public String addrTypeLvl1{get; set;}
    @AuraEnabled
    Public String addrNumLvl2{get; set;}
    @AuraEnabled
    Public String addrTypeLvl2{get; set;}
    @AuraEnabled
    Public String addrNumLvl3{get; set;}
    @AuraEnabled
    Public String addrTypeLvl3{get; set;}
    @AuraEnabled
    Public String addrNumLvl4{get; set;}
    @AuraEnabled
    Public String addrTypeLvl4{get; set;}
    //END
    

    /**
     * No arguments contructor
     */
    public AddressSummary() {}

    /**
     * Constructs the object.
     *
     * @param      aId    A identifier
     * @param      aLine  A line
     * @param      e      EASTAddress
     */
    public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress mainAd) {

        addressId  = aid;
        name   = mainAd.name;
        addressType = mainAd.addressType;
        postalDeliveryType = mainAd.postalDeliveryType;
        planNumber  = mainAd.planNumber;
        status = mainAd.status;
        numberStart = mainAd.numberZ;
        numberPrefix   = mainAd.numberPrefix;
        numberSuffix   = mainAd.numberSuffix;
        numberTo   = mainAd.numberTo;
        numberToPrefix   = mainAd.numberToPrefix;
        numberToSuffix   = mainAd.numberToSuffix;
        streetName   = mainAd.streetName;
        streetType   = mainAd.streetType;
        streetTypeSuffix   = mainAd.streetTypeSuffix;
        locality = mainAd.locality;
        greaterLocality   = mainAd.greaterLocality;
        state = mainAd.state;
        postcode = mainAd.postcode;
        lat   = mainAd.lat;
        longZ  = mainAd.longZ;
        numberOfSubAddresses = mainAd.numberOfSubAddresses;

        //ServiceLocation Array Fields
        readyForServiceDate  = mainAd.ServiceLocation.readyForServiceDate;
        
        /*
        * Start : NFB-1218 - Included changes for populating new NBN Status field
        *                    based on value of RFS date and set Rural Mail Type
        * Date : 24-May-17
        * Owner : Akshay Deuskar
        */
        
        Date rfsDate;
        if(!String.isBlank(readyForServiceDate))
        {
             rfsDate = date.valueOf(readyForServiceDate);
             if(rfsDate <= Date.today()){
                nbnStatus = Label.NBN_Ready_Label;
             }else if(rfsDate > Date.today()){
                 nbnStatus = readyForServiceDate;
             }
        } else{
            nbnStatus = Label.NBN_Status_Unavailable_Label;
        }
        
        ruralMailType = mainAd.ruralMailType;
        
        /*
        * End: NFB-1218 - Included changes for populating new NBN Status field 
        *                 based on value of RFS date and set Rural Mail Type
        */
        
        locationId   = mainAd.ServiceLocation.locationId;
        connectivityServiceAreaId   = mainAd.ServiceLocation.connectivityServiceAreaId;
        exchangeServiceAreaId   = mainAd.ServiceLocation.exchangeServiceAreaId;
        facsRealm   = mainAd.ServiceLocation.facsRealm;
        //UI specific fields
        addressLine = aLine;
    }

    /**
     * Constructs the object with sub Address
     *
     * @param      aId    A identifier
     * @param      aLine  A line
     * @param      e      EASTAddress
     */
    // for level 1 subaddress
    public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress mainAd, EASTAddressDataObject.SubAddressComponents subAd) {

        //calling other constructor
        this(subAd.id, aLine, mainAd);

        parentAddressId   = subAd.parentAddressId;
        subAddressType   = subAd.subAddressType;
        subAddressNumber  = subAd.numberZ;


        addrTypeLvl1 = (subAddressType != null && subAddressType != '' && subAddressType != 'null') ? subAddressType : '';
        addrNumLvl1 = (subAddressNumber != null && subAddressNumber != '' && subAddressNumber != 'null') ? subAddressNumber : '';

        subAddressLine = addrTypeLvl1 + addrNumLvl1;
        
    //NFB-3190
        subAddresslevel1 = subAddressLine;
        //END
        if (subAddressLine != null && subAddressLine != '') {
            addressLine = subAddressLine + ' ' + aLine;
        }
    }
    
    // for level 2 subaddress
    public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress mainAd, EASTAddressDataObject.SubAddressComponents subAd,EASTAddressDataObject.SubAddressComponents subAd1) {

        //calling other constructor
        this(subAd1.id, aLine, mainAd);

        parentAddressId   = subAd1.parentAddressId;
        subAddressType   = subAd1.subAddressType;
        subAddressNumber  = subAd1.numberZ;
        
        addrTypeLvl2 = (subAddressType != null && subAddressType != '' && subAddressType != 'null') ? subAddressType : '';
        addrNumLvl2 = (subAddressNumber != null && subAddressNumber != '' && subAddressNumber != 'null') ? subAddressNumber : '';

        subAddressLine = addrTypeLvl2 + addrNumLvl2;
        
    //NFB-3190
          addrTypeLvl1 = (subAd.subAddressType != null && subAd.subAddressType != '' && subAd.subAddressType != 'null') ? subAd.subAddressType : '';
          addrNumLvl1 = (subAd.numberZ != null && subAd.numberZ != '' && subAd.numberZ != 'null') ? subAd.numberZ : '';
        
        subAddresslevel1 = addrTypeLvl1 + addrNumLvl1;
        subAddresslevel2 = subAddressLine;
        //END
        if (subAddressLine != null && subAddressLine != '') {
            addressLine = subAddresslevel1 + ' ' +subAddressLine + ' ' + aLine;
        }
        
    }
    
    //for level3 subaddress
    public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress mainAd, EASTAddressDataObject.SubAddressComponents subAd,EASTAddressDataObject.SubAddressComponents subAd1,EASTAddressDataObject.SubAddressComponents subAd2) {

        //calling other constructor
        this(subAd2.id, aLine, mainAd);

        parentAddressId   = subAd2.parentAddressId;
        subAddressType   = subAd2.subAddressType;
        subAddressNumber  = subAd2.numberZ;
        
        addrTypeLvl3 = (subAddressType != null && subAddressType != '' && subAddressType != 'null') ? subAddressType : '';
        addrNumLvl3 = (subAddressNumber != null && subAddressNumber != '' && subAddressNumber != 'null') ? subAddressNumber : '';

        subAddressLine = addrTypeLvl3 + addrNumLvl3;
        
        //NFB-3190
        addrTypeLvl1 = (subAd.subAddressType != null && subAd.subAddressType != '' && subAd.subAddressType != 'null') ? subAd.subAddressType : '';
        addrNumLvl1 = (subAd.numberZ != null && subAd.numberZ != '' && subAd.numberZ != 'null') ? subAd.numberZ : '';
       
        addrTypeLvl2 = (subAd1.subAddressType != null && subAd1.subAddressType != '' && subAd1.subAddressType != 'null') ? subAd1.subAddressType : '';
        addrNumLvl2 = (subAd1.numberZ != null && subAd1.numberZ != '' && subAd1.numberZ != 'null') ? subAd1.numberZ : '';
        
        subAddresslevel1 = addrTypeLvl1 + addrNumLvl1;
        subAddresslevel2 = addrTypeLvl2 + addrNumLvl2;
        subAddresslevel3 = subAddressLine;
        //END

        if (subAddressLine != null && subAddressLine != '') {
            addressLine = subAddresslevel1 + ' ' + subAddresslevel2 + ' ' +subAddressLine + ' ' + aLine;
        }
        
    }
    
    //for level 4 subaddress
    public AddressSummary(String aId, String aLine, EASTAddressDataObject.EASTAddress mainAd, EASTAddressDataObject.SubAddressComponents subAd,EASTAddressDataObject.SubAddressComponents subAd1,EASTAddressDataObject.SubAddressComponents subAd2,EASTAddressDataObject.SubAddressComponents subAd3) {

        //calling other constructor
        this(subAd3.id, aLine, mainAd);

        parentAddressId   = subAd3.parentAddressId;
        subAddressType   = subAd3.subAddressType;
        subAddressNumber  = subAd3.numberZ;
        
        addrTypeLvl4 = (subAddressType != null && subAddressType != '' && subAddressType != 'null') ? subAddressType : '';
        addrNumLvl4 = (subAddressNumber != null && subAddressNumber != '' && subAddressNumber != 'null') ? subAddressNumber : '';

        subAddressLine = addrTypeLvl4 + addrNumLvl4;
        
    //NFB-3190
        addrTypeLvl1 = (subAd.subAddressType != null && subAd.subAddressType != '' && subAd.subAddressType != 'null') ? subAd.subAddressType : '';
        addrNumLvl1 = (subAd.numberZ != null && subAd.numberZ != '' && subAd.numberZ != 'null') ? subAd.numberZ : '';
       
        addrTypeLvl2 = (subAd1.subAddressType != null && subAd1.subAddressType != '' && subAd1.subAddressType != 'null') ? subAd1.subAddressType : '';
        addrNumLvl2 = (subAd1.numberZ != null && subAd1.numberZ != '' && subAd1.numberZ != 'null') ? subAd1.numberZ : '';
        
        addrTypeLvl3 = (subAd2.subAddressType != null && subAd2.subAddressType != '' && subAd2.subAddressType != 'null') ? subAd2.subAddressType : '';
        addrNumLvl3 = (subAd2.numberZ != null && subAd2.numberZ != '' && subAd2.numberZ != 'null') ? subAd2.numberZ : '';
        
        subAddresslevel1 = addrTypeLvl1 + addrNumLvl1;
        subAddresslevel2 = addrTypeLvl2 + addrNumLvl2;
        subAddresslevel3 = addrTypeLvl3 + addrNumLvl3;
        subAddresslevel4 = subAddressLine;
        //END
        if (subAddressLine != null && subAddressLine != '') {
            addressLine = subAddresslevel1 + ' ' + subAddresslevel2 + ' ' + subAddresslevel3 + ' ' + subAddressLine + ' ' + aLine;
        }
        
    }
    /*
     public AddressSummary(AddressResponse.Structured addr) {
        addressId = addr.addressId;
        addressType = addr.addressType;
        status = addr.confirmed?'CONFIRMED':'UNCONFIRMED';  
        state = addr.state;
        postcode = addr.postcode;
        locality = addr.localityName;
        if(addr.numSubaddresses != NULL)        {   numberOfSubAddresses = String.valueOf(addr.numSubaddresses);    }
        if(addr.propertyNumberFrom != NULL)     {   propertyNumberFrom = String.valueOf(addr.propertyNumberFrom);       }
        if(addr.propertyNumberTo != NULL)       {   propertyNumberTo = addr.propertyNumberTo;                           }
        if(addr.serviceLocation!=NULL)    {locationId = addr.serviceLocation.locationId; }    
     if(addr.serviceLocation!=NULL)    {customerServiceAreaId = addr.serviceLocation.customerServiceAreaId; }
        streetName = addr.streetName;
        streetType = addr.streetType;
        if(addr.serviceLocation!=NULL)          {serLocLat = addr.serviceLocation.latitude; }
        if(addr.serviceLocation!=NULL)          {serLocLong = addr.serviceLocation.longitude; }
        if(addr.serviceLocation!=NULL)       {serLocReady = addr.serviceLocation.readyForServiceDate; }
        if(addr.serviceLocation!=NULL)        {serLocXchange = addr.serviceLocation.exchangeServiceArea; }
        if(addr.serviceLocation!=NULL)           {serLocFace = addr.serviceLocation.facsRealm;}
        condorCode  =  addr.condorCode  ;
    subAddressType  =  addr.subAddressType  ;
    subAddressCodeset  =  addr.subAddressCodeset  ;
    parcelDescriptor1  =  addr.parcelDescriptor1Prefix  ;
    ParcelNumber  =  addr.ParcelNumber  ;
    parcelType  =  addr.parcelType  ;
    ruralmailType  =  addr.ruralmailType  ;
    ruralmailNumber  =  addr.ruralmailNumber  ;
    postalDeliveryNumber  =  addr.postalDeliveryNumber  ;
    if(addr.parent!=NULL) { parentAddressId = addr.parent.addressId;}
     }
    */
    /*------------------------------------------------------------ 
    EDGE - 76217
	Constructor: AddressSummary 
    Description: Creates instance for displaying address info on UI
    Inputs: AddressResponseDTO.UnstructuredAUPost 
    History 
    <18-04-2019> <Kalashree Borgaonkar>
    ------------------------------------------------------------*/
    public AddressSummary(AddressResponseDTO.UnstructuredAUPost addr) {
	if(addr.addresses!=null){
		addressId = addr.addresses.addressId;
		status = addr.addresses.confirmed?'CONFIRMED':'UNCONFIRMED';  
		state = addr.addresses.state;
		postcode = addr.addresses.postcode;
		locality = addr.addresses.localityName;
		if(addr.addresses.addressline1 != NULL)   { addressLine = addr.addresses.addressline1;}
		if(addr.addresses.addressline2 != NULL)   { addressLine = addressLine + addr.addresses.addressline2;}
		if(addr.addresses.addressline3 != NULL)   { addressLine = addressLine + addr.addresses.addressline3;}	
		addressLine = addressLine.removeEnd(',');
	}
	else{
		addressId = addr.addressId;
		status = addr.confirmed?'CONFIRMED':'UNCONFIRMED';  
		state = addr.state;
		postcode = addr.postcode;
		locality = addr.localityName;
		if(addr.addressline1 != NULL)   { addressLine = addr.addressline1;}
		if(addr.addressline2 != NULL)   { addressLine = addressLine + addr.addressline2;}
		if(addr.addressline2 != NULL)   { addressLine = addressLine + addr.addressline2;}	
		addressLine = addressLine.removeEnd(',');
	}
}
 
}
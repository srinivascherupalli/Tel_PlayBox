/**
 * Extension controller for the ValidateAddress
 */
public with sharing class ValidateAddressExtension {

    public String selectedId {get; set;}
    public AddressSummary selectedAddress {get; set;}
    public AddressSummary selectedParentAddress {get; set;}
    public String addressText {get; set;}

    public cscrm__Address__c addr {get; set;}
    public cscrm__Address__c parentAddr {get; set;}
    Public ID accountID {get; set;}
    Public ID contactID {get; set;}
    public List<AddressSummary> addressList {get; set;}
    private ApexPages.StandardController stdController;
    public Map<String, AddressSummary> addressMap = new Map<String, AddressSummary>();
    public Integer offset { get; set; }

    public Integer paginationSize {get; set;}
    public Integer adddressNameSize {get; set;}
    public Integer adddressListWarningLimit {get; set;}
    public String  refineSearchMsg {get; set;}

    /**
     * Constructs the object.
     *
     * @param      stdController  The standard controller
     */
    public ValidateAddressExtension(ApexPages.StandardController stdController) {
		this.stdController = stdController;
        addr = (cscrm__Address__c)stdController.getRecord();
        accountID = addr.cscrm__Account__c;
        
        PageReference pageRef = ApexPages.currentPage();
        if(pageRef != null) {
	        if(pageRef.getParameters().get('contactId') != null) {
	        	contactID = pageRef.getParameters().get('contactId');
	        }
	        if(pageRef.getParameters().get('acctId') != null) {
	        	accountID = pageRef.getParameters().get('acctId');
	        }
        }        
        System.debug('AccountId: ' + accountID + ', ContactId: ' + contactID); 
    }
    /**
     * Search address
     *
     * @return     PageReference
     */
    public PageReference searchAddress() {

        try {

            System.debug(addressText);
            addressText = addressText.replace('\\', ' ').replace('/', ' ');
            addressList  = AddressValidateManager.searchAddress(addressText);

            String envPaginationSize = EnvironmentVariable.get('okapi_east_result_pagination_size');
            String envAdddressNameSize = EnvironmentVariable.get('east_result_ui_address_name_text_size');
            String envResultListWarningLimit = EnvironmentVariable.get('okapi_east_result_list_warning_limit');

            paginationSize =  (envPaginationSize != null && envPaginationSize != '') ? integer.valueof(envPaginationSize) : 50;
            adddressNameSize = (envAdddressNameSize != null && envAdddressNameSize != '') ? integer.valueof(envAdddressNameSize) : 68;
            adddressListWarningLimit = (envResultListWarningLimit != null && envResultListWarningLimit != '') ? integer.valueof(envResultListWarningLimit) : 1000;
			refineSearchMsg = String.format(Label.East_validate_refine_search,new String[]{String.valueof(adddressListWarningLimit)});

            System.debug('addressList size' + addressList.size());

            if (addressList != null) {
                for (AddressSummary addSum : addressList ) {
                    if (addSum != null && addSum.addressId != null) {
                        addressMap.put(addSum.addressId, addSum);
                    }
                }
            }
            offset = 0;

        } catch (Exception e) {
            Logger.getLogger(ValidateAddressExtension.class).debug(e);
            Logger.exitLogger();
        }

        return null;

    }

    /**
     * Saves the selected address details
     *
     * @return     PageReference for view screen
     */
    
    // commenting the method as new save funtinality has been implemented under US-2843
   /* Public PageReference save() {

        try {

            selectedAddress = addressMap.get(selectedId);
            System.debug('Selected parent address1 '+selectedAddress.parentAddressId);
            selectedAddress.accountId = accountID;
            
            
            /**NFB-2815 : Calling Utility class method to persist address in salesforce**/
            /*System.debug('********in page reference');
            addr=AddressAndSiteObjectUtility.UpsertEastAddress(selectedAddress);
            System.debug('AddressId: ' + selectedAddress.addressId);
            /*********End of NFB-2815****************/
            
            /* Commented below logic as part of NFB-2815 */
            
            /*addr = getAddressFromSelected(selectedAddress);
            addr.cscrm__Account__c = accountID;

            Schema.SObjectField addresID = cscrm__Address__c.Fields.Address_ID__c;
            Database.upsert(addr, addresID, false);
            System.debug('AddressId: ' + addr.Id);
			//Commented below logic to bring the parent address ID. Not in scope currently
			
            /*if (selectedAddress.parentAddressId != null && selectedAddress.parentAddressId != '') {
                selectedParentAddress = addressMap.get(selectedAddress.parentAddressId);
                parentAddr = getAddressFromSelected(selectedParentAddress);
                parentAddr.cscrm__Account__c = accountID;
                Database.upsert(parentAddr, addresID, false);
            }*/

            /*PageReference finalView = new ApexPages.StandardController(addr).view();
            if(contactID != null) {
            	cscrm__Contact_Address_Relationship__c car = new cscrm__Contact_Address_Relationship__c(cscrm__Contact__c = contactID, cscrm__Address__c=addr.Id);
            	insert car;
            	finalView = new PageReference('/' + contactID);
            }
            return finalView;

        } catch (Exception e) {
            Logger.getLogger(ValidateAddressExtension.class).debug(e);
            Logger.exitLogger();
            return null;
        }



    }*/

	/* NFB-2815 : Method commented as part of this user story */
    /**
     * Saves the selected address details
     *
     * @return     PageReference for view screen
     */

    /*Public cscrm__Address__c getAddressFromSelected(AddressSummary selectedAddress) {

        cscrm__Address__c addr = new cscrm__Address__c();
        addr.Address_ID__c = selectedAddress.addressId;
        addr.cscrm__Street__c = selectedAddress.addressLine;
        addr.cscrm__Building_Name__c   = selectedAddress.name;
        addr.cscrm__Address_Type__c = selectedAddress.addressType;
        addr.Postal_Delivery_Type__c = selectedAddress.postalDeliveryType;
        addr.cscrm__Plan_Number__c  = selectedAddress.planNumber;
        addr.Address_Status__c = selectedAddress.status;

        String stNumber = '';

        if (selectedAddress.numberStart != null) {

            stNumber  = selectedAddress.numberStart;
            if (selectedAddress.numberPrefix != null) {stNumber = selectedAddress.numberPrefix + stNumber; }
            if (selectedAddress.numberSuffix != null) {stNumber = stNumber + selectedAddress.numberSuffix; }
        }

        addr.cscrm__Street_Number_Start__c  = stNumber;

        String numTo = '';

        if (selectedAddress.numberTo != null) {

            numTo = selectedAddress.numberTo;
            if (selectedAddress.numberToPrefix != null) {numTo = selectedAddress.numberToPrefix + numTo; }
            if (selectedAddress.numberToSuffix != null) {numTo = numTo + selectedAddress.numberToSuffix; }

        }


        addr.cscrm__Street_Number_End__c   = numTo;

        addr.cscrm__Building_Number__c = stNumber + ((numTo != null && numTo != '0' && numTo != '') ? ('-' + numTo) : '');

        addr.cscrm__Street_Name__c   = selectedAddress.streetName;

        String streetType = '';

        if (selectedAddress.streetType != null) {

            streetType = selectedAddress.streetType;

            if (selectedAddress.streetTypeSuffix != null) {streetType = streetType + selectedAddress.streetTypeSuffix; }

        }

        addr.cscrm__Street_Type__c   = streetType;

        addr.Locality__c = selectedAddress.locality;
        addr.Greater_Locality__c   = selectedAddress.greaterLocality;
        addr.cscrm__State_Province__c = selectedAddress.state;
        addr.cscrm__Zip_Postal_Code__c = selectedAddress.postcode;

        String latitude = selectedAddress.lat;
        String longitude = selectedAddress.long_Z;

        /*
        * Start : NFB-1218 - Included changes for populating latitude, longitude, RFS date
        *                    Rural Mail Type and NBN status fields 
        * Date : 24-May-17
        * Owner : Akshay Deuskar
       
        // add longitude and latitude
        if (latitude != null && latitude != '') {
            addr.cscrm__Geolocation__Latitude__s  = Decimal.valueOf(latitude);
        }

        if (longitude != null && longitude != '') {
            addr.cscrm__Geolocation__Longitude__s  = Decimal.valueOf(longitude);
        }

        // add RFS date
		if(selectedAddress.readyForServiceDate !=null && selectedAddress.readyForServiceDate !=''){ 
			addr.Ready_For_Service_Date__c  = selectedAddress.readyForServiceDate;
		}
        
        // add Rural Mail Type
        addr.Rural_Mail_Type__c = selectedAddress.ruralMailType;
        
        //add NBN status
        //addr.NBN_Status__c = selectedAddress.nbnStatus;
        /*
         * End : NFB-1218 - Included changes for populating latitude, longitude, RFS date and NBN status fields 
         
        

        //SubAddress Array Fields
        addr.Parent_Address_Id__c   = selectedAddress.parentAddressId;
        addr.Sub_Address_Type__c   = selectedAddress.subAddressType;
        addr.Sub_Address_Number__c  = selectedAddress.subAddressNumber;


        //ServiceLocation Array Fields
        addr.NBN_Location_Id__c   = selectedAddress.locationId;
        addr.Connectivity_Serving_Area__c   = selectedAddress.connectivityServiceAreaId;
        addr.ESA_Code__c   = selectedAddress.exchangeServiceAreaId;
        addr.FACS_Realm__c   = selectedAddress.facsRealm;


        String name = addr.cscrm__Street__c + ' ' + addr.Locality__c + ' ' + addr.cscrm__State_Province__c + ' ' + addr.cscrm__Zip_Postal_Code__c;

        if (name != null && name.length() > adddressNameSize) {
            name = name.substring(0, adddressNameSize);
        }
        addr.Name = name + '(' + addr.Address_ID__c + ')';

        return addr;

    }*/

	/*
	*	Override the Cancel button's standar behaviour 
	*/
	public PageReference cancel() {
		if(contactID != null) {
			PageReference pr = new PageReference('/' + contactID);
			return pr;
		}
		else {
			return stdController.cancel();
		}
	}

    /**
    * Redirect the new page to validate address details
    *
    * @return     PageReference for validate screen
    */
    public PageReference redirect() {

        PageReference pr = new PageReference('/apex/ValidateAddressWithEAST');
        return pr;
    }

    /**
    * Redirect the page back to Address search page
    *
    * @return     PageReference for create Address
    */
    public PageReference goBack() {

        PageReference pr = new PageReference('/apex/CreateAddress');
        return pr;
    }

    /**
    * Moves to first page
    */
    public void first() {

        offset = 0;
    }
    /**
     * Goes to next page
     */
    public void next() {

        offset = offset + paginationSize;

    }
    /**
     * Goes to previous page
     */
    public void previous() {

        offset = Math.max(0, offset - paginationSize);

    }
    /**
     * Goes to last page
     */
    public void last() {

        Integer mod = Math.mod(addressList.size(), paginationSize);
        mod = (mod != 0) ? mod : paginationSize;
        offset = addressList.size() - mod;

    }
    /**
     * Checks if next page exists
     *
     * @return     Has next.
     */
    public Boolean getHasNext() {

        return  addressList.size() > (offset + paginationSize);
    }

    /**
     * Checks if previous page exists
     *
     * @return     Has previous.
     */
    public Boolean getHasPrevious() {

        return offset != 0;
    }
    /**
     * Get the page number.
     *
     * @return     Page number.
     */
    public Integer getPageNumber() {

        return (offset / paginationSize) + 1;
    }
    /**
     * Get the total pages.
     *
     * @return     Total pages.
     */
    public Integer getTotalPages() {

        Decimal r = addressList.size();
        Decimal p = paginationSize;
        Decimal d = (r / p).round(System.roundingMode.CEILING);
        System.debug('getTotalPages ' + (d.intValue()));
        return d.intValue();
    }

}
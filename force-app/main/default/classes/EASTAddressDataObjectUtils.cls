/*
*    This class captures all the utility methods that act on the EASTAddressDataObject
*/
public class EASTAddressDataObjectUtils {
    
    public static cscrm__Address__c createBillingAddressRecord(EASTAddressDataObject.EASTAddress e, String accountId) {
        cscrm__Address__c csadBilling = new cscrm__Address__c();
        
        csadBilling.Address_ID__c = e.id;
        csadBilling.Address_Line_1__c = EASTAddressDataObjectUtils.aSummarize(e).addressLine;
        csadBilling.Address_Type__c = e.addressType;
        csadBilling.cscrm__Zip_Postal_Code__c = e.postcode;
        csadBilling.Locality__c = e.locality;
        csadBilling.cscrm__State_Province__c = e.state;
        csadBilling.cscrm__Account__c =  Id.valueOf(accountId);
        csadBilling.Address_Status__c = e.status;
        csadBilling.cscrm__Is_Billing_Address__c = true;
        csadBilling.cscrm__Street_Name__c = e.streetName;
        csadBilling.cscrm__Street_Type__c = e.streetType;
        csadBilling.Locality__c = e.locality;
        csadBilling.cscrm__Street_Number_Start__c = e.numberZ;
        csadBilling.cscrm__Street_Number_End__c = e.numberTo;
        
        return csadBilling;
    }

    public static cscrm__Address__c createMailingAddressRecord(EASTAddressDataObject.EASTAddress e, String accountId) {
        cscrm__Address__c csadMailing = new cscrm__Address__c();
        
        csadMailing.Address_ID__c = e.id;
        csadMailing.Address_Line_1__c = aSummarize(e).addressLine;
        csadMailing.Address_Type__c = e.addressType;
        csadMailing.cscrm__Zip_Postal_Code__c = e.postcode;
        csadMailing.Locality__c = e.locality;
        csadMailing.cscrm__State_Province__c = e.state;
        csadMailing.cscrm__Account__c =  Id.valueOf(accountId);
        csadMailing.Address_Status__c = e.status;
        csadMailing.cscrm__Is_Shipping_Address__c = true;
        csadMailing.cscrm__Street_Name__c = e.streetName;
        csadMailing.cscrm__Street_Type__c = e.streetType;
        csadMailing.Locality__c = e.locality;
        csadMailing.cscrm__Street_Number_Start__c = e.numberZ;
        csadMailing.cscrm__Street_Number_End__c = e.numberTo;
        
        return csadMailing;
    }
        
    // Slice out information from the dataObject
    public static EASTAddressSearchController.AddressSummary aSummarize(EASTAddressDataObject.EASTAddress e){
        String stNumber ='';
        String adLine='';
        EASTAddressSearchController.AddressSummary aSum;
        if(e.numberZ != null) {
            stNumber = e.numberZ;
            if(e.numberPrefix != null) {stNumber = e.numberPrefix + stNumber; }
            if(e.numberSuffix != null) {stNumber = stNumber +e.numberSuffix; }
        }
        if(e.numberTo!=null) {
            String numTo = '';
            if(e.numberToPrefix != null) {numTo = e.numberToPrefix + numTo; }
            if(e.numberToSuffix != null) {numTo = numTo +e.numberToSuffix; }
            stNumber += numTo;
        }
        adLine = e.numberZ+' '+e.streetName+' '+e.streetType;
        adLine.replace('null', ' ');

        return new EASTAddressSearchController.AddressSummary(e.id, '', e);
    }    
}
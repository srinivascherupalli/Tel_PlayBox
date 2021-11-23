/**
* @Description : Get Customer and Contacts from TCM application based on CIDN and insert/update in Force.com.
* @Author : ChandrakanthReddy B.
* @Date : 14/Nov/2017
* @Story : EDGE-4090
* @Story : EDGE-61, AC2, Anu Yadav, 12/Feb/2018
* @Story : EDGE-92229, AC2, Kalashree Borgaonkar, 29/Aug/2018
*/
public with sharing class TCMGetCustomer {
    
    private String sourceFrom;
    public static Boolean isCustomerFromTCM = false;
    
    public Account createAccountAndAddress(CustomerObject.Customer selectedCustomer){
        System.debug('TCMGetCustomer - Creating Account/cscrm__Account_Address_Relationship__c');
        Account tcmCustomer = null;
        List<cscrm__Account_Address_Relationship__c> accountAddressRelationList = null;
        try{
            tcmCustomer = getAccount(selectedCustomer);
            //Upsert Account record.
            if(tcmCustomer != null){
                isCustomerFromTCM = true;
                upsert tcmCustomer CIDN__c;
                system.debug('cidn'+tcmCustomer.CIDN__c);
                accountAddressRelationList = getAccountAddress(tcmCustomer, selectedCustomer);
                //Upsert cscrm__Account_Address_Relationship__c's records.
                if(!accountAddressRelationList.isEmpty()){
                    upsert accountAddressRelationList AccountAddressRelationship__c;    
                }
                if(!isAccountIndustryExist(tcmCustomer,selectedCustomer)){
                    Account_Industry_Relationship__c accIndustry = accountIndustry(tcmCustomer,selectedCustomer);
                    if(accIndustry != null) {
                        insert accIndustry;
                    }
                }
            }
        } catch(DmlException de){
            throw new TCMException.TCMCustomerCreationException(de.getMessage(),de);
        }
        return tcmCustomer;
    }
    
    public Account getAccount(CustomerObject.Customer selectedCustomer){
        Account tcmAccount = null;
        if(selectedCustomer != null){
            System.debug('TCMGetCustomer - Building Account object for : ' + selectedCustomer.cidn);
            tcmAccount = new Account();
            tcmAccount.Customer_ID__c = selectedCustomer.cac;
            tcmAccount.Imported__c = true;
            //tcmAccount.Source_System__c = validateStringField(sourceFrom, 'Other');
            //tcmAccount.AccountNumber = selectedCustomer.cac;
            tcmAccount.Customer_Status__c = selectedCustomer.accountStatus;
            tcmAccount.CIDN__c = selectedCustomer.cidn;
            tcmAccount.Type = selectedCustomer.customerType;
            tcmAccount.Legacy_Ownership_Code__c=selectedCustomer.ownershipCode;
            tcmAccount.Business_Unit__c = selectedCustomer.businessUnit;
            ///
            tcmAccount.Churn_Propensity__c = selectedCustomer.churnPropensity;
            tcmAccount.Customer_Last_Verified_Date__c =  (String.isNotBlank(selectedCustomer.lastVerifiedDate))?validateDateField(selectedCustomer.lastVerifiedDate) : TCMCustomerContactHelper.setLastVerifiedDateField(selectedCustomer.lastVerifiedDate);
            tcmAccount.Validation_Consent_Request_Date__c = validateDateField(selectedCustomer.validationConsentRequestDate);
            tcmAccount.Actual_Retired_Date__c = validateDateField(selectedCustomer.actualRetiredDate);
            //tcmAccount.Geographical_Location_Code__latitude__s = validateDecimalValue(selectedCustomer.geographicalLocationCode);
            //tcmAccount.Geographical_Location_Code__longitude__s = validateDecimalValue(selectedCustomer.geographicalLocationCode);
            //tcmAccount.Retired_UserID__c = selectedCustomer.retiredUId;
            tcmAccount.Date_of_Application__c = validateDateField(selectedCustomer.dateOfApplication);
            tcmAccount.Approve_Decline_Reason__c = selectedCustomer.approveDeclineReason;
            tcmAccount.Recommended_Billing_Frequency__c = selectedCustomer.recommendedBillingFrequency;
            tcmAccount.Legacy_Created_date__c = validateDateField(selectedCustomer.createdDate);
            tcmAccount.Customer_Current_Revenue__c = selectedCustomer.currentRevenue;
            tcmAccount.Validation_Customer_Consent__c = selectedCustomer.validationCustomerConsent;
            tcmAccount.Date_Started_Trading_with_Telstra__c = validateDateField(selectedCustomer.customerSince);
            tcmAccount.Franchisee_Arrange__c = selectedCustomer.franchiseArrange;
            tcmAccount.Partners__c = selectedCustomer.partners;
            tcmAccount.Language_Preference__c = selectedCustomer.languagePreference;
            tcmAccount.TCM_Last_Updated__c = validateDateField(selectedCustomer.lastUpdated);
            tcmAccount.Loc__c = selectedCustomer.location;
            tcmAccount.Market_Segment__c = selectedCustomer.marketSegment;
            tcmAccount.TCM_MasterID__c = selectedCustomer.masterID;
            tcmAccount.TCM_Merge_Status__c = selectedCustomer.mergeStatus;
            tcmAccount.Acount_Description__c = selectedCustomer.description;
            tcmAccount.OLB_Online_Bill_Registered__c = TCMCustomerContactHelper.validateField(selectedCustomer.category.online);
            tcmAccount.Recommended_Payment_Method__c = selectedCustomer.recommendedPaymentMethod;
            tcmAccount.Customer_Potential_Revenue__c = selectedCustomer.potentialRevenue;
            tcmAccount.Customer_Effective_EndDate__c = validateDateField(selectedCustomer.customerEffectiveEndDate);
            tcmAccount.Reporting_Point_Indicator__c = selectedCustomer.reportingPointIndicator;
            tcmAccount.Customer_Effective_Start_Date__c = validateDateField(selectedCustomer.customerEffectiveStartDate);
            tcmAccount.Relationship_Type__c = selectedCustomer.relationshipType;
            tcmAccount.Parent_Source_System__c = selectedCustomer.parentSourceSystem;
            tcmAccount.Source_System_Operation__c = selectedCustomer.sourceSysOperation;
            tcmAccount.Legacy_ROU__c = selectedCustomer.revenueOrganisationUnit;
            tcmAccount.Legacy_SOU__c = selectedCustomer.servicingOrgUnit;
            tcmAccount.Sic = selectedCustomer.ansicCode;
            tcmAccount.Retirement_Reason__c = selectedCustomer.retirementReason;
            tcmAccount.Time_Zone__c = selectedCustomer.timeZone;
            tcmAccount.Wriiten_Auth_Required__c = TCMCustomerContactHelper.validateField(selectedCustomer.writtenaAuthorityRequiredFlag);
            //
            tcmAccount.PriorityAssist__c = TCMCustomerContactHelper.validateField(selectedCustomer.priorityAssist);
            tcmAccount.Managed__c = TCMCustomerContactHelper.validateField(selectedCustomer.customerManagedFlag);
            tcmAccount.Date_Started_Trading_with_Telstra__c = validateDateField(selectedCustomer.customerSince);    
            tcmAccount.TCM_MasterID__c = selectedCustomer.masterID;    
            tcmAccount.Parent_CIDN__c = selectedCustomer.parentCidn;
            tcmAccount.Ultimate_Parent_CIDN__c = selectedCustomer.ultimateParentCidn;
            tcmAccount.Market_Segment__c = selectedCustomer.marketSegment;
            tcmAccount.Portfolio_Code__c = selectedCustomer.portfolioCode;
            accountConcessionMapping(selectedCustomer.concession,tcmAccount);
            customerAccountMapping(selectedCustomer.customerAccount,tcmAccount);
            accountCreditSituationMapping(selectedCustomer.creditsituation,tcmAccount);
            if(selectedCustomer.accountTrading != null){
                accountTradingMapping(selectedCustomer.accountTrading,tcmAccount);
            }
        }
        return tcmAccount;
    }
    
    private void accountConcessionMapping(CustomerObject.Concession concession, Account tcmAccount){
        if(concession != null){
            tcmAccount.Bypass_Concession_Validation__c = concession.bypassConcessionValidation;
            tcmAccount.Concession_Authority__c = concession.concessionAuthority;
            tcmAccount.Valid_Concession_Flag__c = TCMCustomerContactHelper.validateField(concession.validConcessionFlag);
            tcmAccount.Concession_Number__c = concession.concessionNumber;
            tcmAccount.Payment_Status__c = concession.paymentStatus;
            tcmAccount.Payment_Type__c = concession.paymentType;
            tcmAccount.Concession_Type__c = concession.concessionType;
            tcmAccount.Validation_Result_Override__c = concession.validationResultOverride;
            tcmAccount.Last_Validated_Date__c =  validateDateField(concession.lastValidatedDate);
        }
    }
    
    private void customerAccountMapping(CustomerObject.CustomerAccount customerAccount, Account tcmAccount){
        if(customerAccount != null){
            tcmAccount.ABN__c = customerAccount.abn;
            tcmAccount.Pref_Comm_Method__c = customerAccount.preferredMethod;
            tcmAccount.Account_UUID__c = customerAccount.accountUuid;
            tcmAccount.VIP_Customer__c =  TCMCustomerContactHelper.validateField(customerAccount.vipFlag);
            tcmAccount.Website = customerAccount.webAddress;
            tcmAccount.Name = (tcmAccount.type != null && (tcmAccount.Type == 'Sole Trader' || tcmAccount.Type == 'Residential')) ? 
                customerAccount.firstname + ' '+customerAccount.lastName : customerAccount.lastName;
            tcmAccount.ACN__c = customerAccount.acn;
            tcmAccount.Fax = TCMCustomerContactHelper.formatNumber(customerAccount.faxNumber);
            tcmAccount.Phone = TCMCustomerContactHelper.formatNumber(customerAccount.phoneNumber);
            tcmAccount.Email__c = customerAccount.emailAddress;    
            tcmAccount.Effective_Retired_Date__c = validateDateField(customerAccount.effectiveRetiredDate);
            tcmAccount.FraudFlag__c =  TCMCustomerContactHelper.validateField(customerAccount.fraudFlag);                
            tcmAccount.Data_Sovereign_Status__c = validateStringField(customerAccount.dataSovereignty,'SFDC Integration');
        }
    }
    
    private void accountCreditSituationMapping(CustomerObject.CreditSituation creditsituation, Account tcmAccount){
        if(creditsituation != null){
            tcmAccount.Credit_Management_Status__c = creditsituation.creditManagementStatus;
            tcmAccount.Credit_Rating__c = creditsituation.creditRating;
            tcmAccount.Credit_Limit__c = creditsituation.creditLimit;
        }
    }
    
     private void accountTradingMapping(List<CustomerObject.AccountTrading> accountTrading, Account tcmAccount){
        if(!accountTrading.isEmpty()){
           tcmAccount.Customer_Trading_Name__c = (TCMCustomerContactHelper.isNotNullAndBlank(accountTrading[0].tradingName))?accountTrading[0].tradingName :'';
           tcmAccount.Primary__c = (TCMCustomerContactHelper.isNotNullAndBlank(accountTrading[0].isPrimary) && accountTrading[0].isPrimary == 'Y'? True : False);
       }
    }
    
    /**
     * @Author : Anu Yadav
     * Story : EDGE-61, AC2
     */
    private Boolean isAccountIndustryExist(Account tcmAccount,CustomerObject.Customer selectedCustomer){
        Boolean accIndustry = false;
        if(selectedCustomer.ansicCode != null && String.isNotBlank(selectedCustomer.ansicCode)){
            Map<Id,ASIC__c> asicMap = new Map<Id,ASIC__c>([Select Id,Industry__c,SIC_Code__c from ASIC__c where SIC_Code__c= :selectedCustomer.ansicCode]);
            List<Account_Industry_Relationship__c> accIndustryList = [select Id, AccountID__c,IndustryID__c from Account_Industry_Relationship__c where AccountID__c = :tcmAccount.Id and IndustryID__c in :asicMap.keySet()];
            if(!accIndustryList.isEmpty() && !asicMap.isEmpty()){
                accIndustry = true;
            }
        }
        return accIndustry;
    }
    
    /**
     * @Author : Anu Yadav
     * Story : EDGE-61, AC2
     */   
    private Account_Industry_Relationship__c accountIndustry(Account tcmAccount,CustomerObject.Customer selectedCustomer){
        Account_Industry_Relationship__c accIndustry = null;
        if(selectedCustomer.ansicCode != null && String.isNotBlank(selectedCustomer.ansicCode)){
           List<ASIC__c> asic = [Select Id,Industry__c,SIC_Code__c from ASIC__c where SIC_Code__c= :selectedCustomer.ansicCode];
           if(!asic.isEmpty()){
            accIndustry = new Account_Industry_Relationship__c();
            accIndustry.AccountID__c = tcmAccount.Id;
            accIndustry.IndustryID__c= asic[0].Id; 
          }
        }
        return accIndustry;
    }
    
    private String validateStringField(String value, String defaultValue){
        return (value != null && String.isNotBlank(value)) ? value : defaultValue;
    }
    
    private Date validateDateField(String value){
        return (value != null && String.isNotBlank(value)) ? Date.valueOf(value) : null;
    }
    
    /**private Decimal validateDecimalValue(String value){
        return (value != null && String.isNotBlank(value)) ? Decimal.valueOf(value) : null;
    }*/
    
    private List<cscrm__Account_Address_Relationship__c> getAccountAddress(Account tcmCustomer, CustomerObject.Customer selectedCustomer){
        //CustomerObject.Customer selectedCustomer = tcmCustomerObj.customer;
        Integer length=0;
        System.debug('TCMGetCustomer - Building cscrm__Account_Address_Relationship__c object for : ' + selectedCustomer.cidn);
        List<cscrm__Account_Address_Relationship__c> accountAddressRelationList = null;
        if(tcmCustomer != null && tcmCustomer.Id != null && selectedCustomer.address != null){
            accountAddressRelationList = new List<cscrm__Account_Address_Relationship__c>();
            //if(!selectedCustomer.address.isEmpty()){system.debug('Address size :- '+ selectedCustomer.address.size());}
            for(CustomerObject.Address add : selectedCustomer.address) {
                /*NFB-2815 : Calling Utility class method to upsert TCM address. */
                //EDGE-92229 : Kalashree Borgaonkar - start
                length = add.addressId!=null ? add.addressId.length() : 0;
                System.debug('length:'+add.addressId);
                if(add.addressId!=null && add.addressId.isNumeric() && (length ==8 || length==9) ){
                    cscrm__Address__c address = AddressAndSiteObjectUtility.UpsertTCMAddress(add);
                    accountAddressRelationList.add(relateAddressToAccount(tcmCustomer.Id, address.Id, add));
                }
                //EDGE-92229 : Kalashree Borgaonkar - end
            }
        }
        return accountAddressRelationList;
    }
    
    private cscrm__Account_Address_Relationship__c relateAddressToAccount(String accountId, String addressId, CustomerObject.Address add) {
        cscrm__Account_Address_Relationship__c aar = new cscrm__Account_Address_Relationship__c();
        aar.cscrm__Account__c = accountId;
        aar.cscrm__Address__c = addressId;
        aar.cscrm__Active__c = true;
        aar.AccountAddressRelationship__c = aar.cscrm__Account__c +''+ aar.cscrm__Address__c;
        if(TCMCustomerContactHelper.validateField(add.isPrimary)){
            aar.cscrm__Address_Type__c = 'Primary Address';
        }
        return aar;
    }
    
}
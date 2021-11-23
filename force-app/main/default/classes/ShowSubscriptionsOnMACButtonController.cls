/*
********************************************************************************************************************************
Class : ShowSubscriptionsOnMACButtonController 
Developer Name : Vedran
Test Class : ShowSubscriptionsOnMACButtonControllerrTest
********************************************************************************************************************************
Sr.No.    Developer Name      Date          Story Description
1.        Vedran              28/08/2018    
2.        Rohit Tripathi      03/20/2018    EDGE-74733 FOR PRM MAC PAGE is not opening
3.        Shubhi Vijayvergia  21/3/2018     Edge-53882 MAC page for Sim Replacement for Assurance service agent Profile
4.        Harsh Parmar        25/03/2019    Edge-75347 Updated the query for 'subList' in getsubscriptionview function  
5.        Harsh Parmar        10/04/2019    Edge-67962 Updated the code in addrecords2  
6.        Vaibhav             21/11/2019    EDGE-98386 TID suspend related changes
7.        Dheeraj Bhatt       20/04/2020    EDGE-140734 restrict Lock/Unlock of a subscription for users other than Telstra Wholesale team users.
8.        RaviTeja            27/04/2020    EDGE-140756 Read MACD Action Types picklist values from custom settings MACD Action Types Custom Settings
9.        Aruna Aware         03/06/2020    DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services
10.       Ankit Goswami       26/08/2020    EDGE-166431 Read Replacment Reason picklist values from custom settings Replacement Reason.
11.       Jawahar M           05/10/2020    INC000093801785 NGUC solution subscriptions for Non-Commercial MAC Orders which are ideally applicable only for CMP
12.       Swapna Deshpande    04/11/2020    EDGE-182533 Added Filter on Subscription status for blank SIM
13.       Shweta              11/1/2020     EDGE-185521 - Enhance non commercial order flow to redirect user to order details page after submission
14.       Shresth/Jenish      04/1/2021     DPG:4542 - DPG | Adaptive Mobility | Suspend Resume | P2O - Enhance for stackable suspensions
15.       Ila/Krunal          04/1/2021     DPG:4543/DPG:4544 -DPG | Adaptive Mobility | Suspend Resume | P2O - Enhance 'suspend' submit order
16.       Pooja Bhat          26/03/2021    EDGE-205597 UI/UX:- Enable user to select subscriptions for change of Billing account
17.       Gokul R             12/04/2021    EDGE-205598 - Added logic to call Case creation method from CoBA page
18.       Pooja Bhat          20/04/2021    EDGE-210731 - <Technical> Changing the implementation for Action Type on MACD Flow
19.       Gokul R             28/04/2021    EDGE -210200 -  Added a validation method to check Parallel MACD. returns error
20.       Jenish Shingala     27/04/2021    DPG-5284: Adaptive Mobility | Suspend Resume | P2O - Suspension reason not available for Service Assurance Profile
21.       Gokul R             15/07/2021    EDGE - 228872 - Reverting the code overridden of DPG changes
********************************************************************************************************************************
*/
public with sharing class ShowSubscriptionsOnMACButtonController {
    private static final String OPPORTUNITY_REC_TYPE = 'Enterprise - In Contract';
    private static final String OPPORTUNITY_STAGE = 'Develop';
    private static final String OPPORTUNITY_TYPE_MAC = 'MACs (Moves, Adds & Change)';
    private static final String OPPORTUNITY_TYPE_DISCONNECT = 'Disconnect';
    private static final String OPPORTUNITY_PRODUCT_TYPE = 'Modular';
    private static final String OPPORTUNITY_PRIMARY_DOMAIN = 'Other';
    private static final String OPPORTUNITY_IN_CONTRACT = 'Yes';
    private static final String CHANGE_TYPE_MODIFY = 'Modify';
    private static final String CHANGE_TYPE_CANCEL = 'Cancel';    
    private static final String BASKET_CHANGE_TYPE = 'Upgrade';
    private static final String BASKET_CHANGE_STAGE = 'Commercial Configuration';
    //Start EDGE-84486
    private static final String CHANGE_OF_MOBILE_NUMBER = 'Change Of Mobile Number';
    private static final String SUCCESS = 'Success';
    
    //end EDGE-84486
    private static final String PS420='DMCAT_ProductSpecification_000420';
    private static final String PS312='DMCAT_ProductSpecification_000312';
    private static final String PS871='DMCAT_ProductSpecification_000871';
    private static final String PS747='DMCAT_ProductSpecification_000747';//EDGE-98386 TID product code
    // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - add product Specification code for IOT
    private static final String PS965='DMCAT_ProductSpecification_000965';
    private static final String PS1196='DMCAT_ProductSpecification_001196';//EDGE-166431 EM Product Code
    private static final String PS1523='DMCAT_ProductSpecification_001523';
    //Added for exception handling
    private static String correlationId =   GuidUtil.NewGuid();
    private static String className     =   'ShowSubscriptionsOnMACButtonController';


    @AuraEnabled
    public static Account acc { get; set; }
    //private static final string  ERROR_MESSAGE = 'Error Message From Apex: ';
    @AuraEnabled
    public static String errorMsg { get; set; }
    //EGDGE-87725 Added few fields in the query for sim replacement

    //EDGE-205598 - This method sends the details from CoBA page to Case Creation method
    @AuraEnabled
    public static caseWrapper submitBillAcc(String accountId, String contactId, String targetBillAccId, String reason, List<String> lstSubscrptnIds){     
        try{
            //EDGE -210200 -  Start
            caseWrapper wrap = new caseWrapper();
            wrap.response = CoBAProcessHelper.validationBeforeCoBASubmission(lstSubscrptnIds);
            if(wrap.response.equalsIgnoreCase('success'))
                wrap.caseRec =  CoBASubscriptionsUpdateUtility.submitCoBA(accountId, contactId, targetBillAccId, reason, lstSubscrptnIds); 
            return wrap;
            //EDGE -210200 -  End         
        }catch(Exception e) {
            GenericUtilityClass.logException(className,'submitBillAcc','',correlationId,e.getMessage() + ' - ' + e.getLineNumber() + ' - ' +e.getStackTraceString(),'Exception occured while submitting CoBA request',C2O_ExceptionHandler.Capability.ORD);
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage() );
        }
        
    }
    @AuraEnabled
    public static Account getAccountDetails(String basketId, String accountId) {
        if (basketId != '' || basketId==null) {
            cscfga__Product_Basket__c bas = [SELECT id, csbb__Account__c FROM cscfga__Product_Basket__c WHERE Id = :basketId];
            acc = [SELECT id, name, CIDN__c, Owner.name FROM Account WHERE Id = :bas.csbb__Account__c];
        } else if (accountId != '' || accountId==null) {
            acc = [SELECT id, name, CIDN__c, Owner.name FROM Account WHERE Id = :accountId];
        }
        
        return acc;
    }
    @AuraEnabled
    public static Boolean isCancelationNBN(String basketId) {
        if (basketId != '') {
            cscfga__Product_Basket__c bas = [SELECT id, Cancellation_Reason__c FROM cscfga__Product_Basket__c WHERE Id = :basketId];
            //System.debug('ShowSubscriptionsOnMACButtonController Cancellation_Reason__c: ' + bas);
            if (bas.Cancellation_Reason__c == 'NBN Transfer Out') {
                return true;
            }
        }
        return false;       
    }
    // Method to get all list view option available for the Account object 
    @AuraEnabled
    public static List < SubWrapper > getSubscriptionView(String basketId, String accountId) {
        String accId = accountId;
        cscfga__Product_Basket__c bas = new cscfga__Product_Basket__c();
        Set < Id > oldProducts = new Set < Id > ();
        set < Id > MobilitySubscriptionAlreadypresent = new Set < Id > ();
        csordtelcoa__Orders_Subscriptions_Options__c OS = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        String status = OS.csordtelcoa__Subscription_Closed_Replaced_State__c;
        String blockedStatus = OS.csordtelcoa__Statuses_Not_Allowing_Change__c;
        
        if (basketId != '' && basketId != null) {
            bas = [SELECT id, csbb__Account__c FROM cscfga__Product_Basket__c WHERE Id = :basketId];
                        
            List < cscfga__Product_Configuration__c > productsAlreadyInTheBasket = new List < cscfga__Product_Configuration__c > ();
            productsAlreadyInTheBasket = [
                SELECT id, csordtelcoa__Replaced_Product_Configuration__c, csordtelcoa__Replaced_Subscription__c, cscfga__Product_Definition__r.Name
                FROM cscfga__Product_Configuration__c
                WHERE cscfga__Product_Basket__c =: basketId
            ];            
            
            for (cscfga__Product_Configuration__c pc: productsAlreadyInTheBasket) {
                if (pc.cscfga__Product_Definition__r.Name != system.label.mobility) {
                    oldProducts.add(pc.csordtelcoa__Replaced_Product_Configuration__c);
                } else {
                    MobilitySubscriptionAlreadypresent.add(pc.csordtelcoa__Replaced_Subscription__c);
                }
            }
            
            accId = bas.csbb__Account__c;
        }
        
        //hide used subscriptions in MACD
        oldProducts.addAll(getProductConfigurationsInUse(accId));
        
        List < csord__Subscription__c > subList = [
            SELECT
                id,
            Site__c,
            Site__r.Name,
            Site__r.Address__c,
            csordtelcoa__Subscription_Number__c,
            CreatedDate,
            csord__Status__c,
            Access_Type__c,//EDGE-77981
            csord__Total_Recurring_Charges__c,
            csord__Total_One_Off_Charges__c,
            CreatedById,
            CreatedBy.Name,
            csord__Account__c,
                Name,
                serviceMSISDN__c,
            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                Is_Bill_Stopped__c,
                Suspension_reason__c,
                Billing_Account__r.Billing_Account_Number__c
            FROM csord__Subscription__c
            WHERE
                csord__Status__c != :status
            AND csord__Account__c =: accId
                AND csordtelcoa__Replacement_Subscription__c = NULL
            AND csordtelcoa__Product_Configuration__c NOT IN: oldProducts 
            AND id NOT IN: MobilitySubscriptionAlreadypresent
                AND csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c != NULL
            AND csord__Status__c NOT IN ('Inactive', 'Closed') //EDGE-182533 - Added Check on Status for ('Inactive', 'Closed')
        ];
        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                    for (csord__Subscription__c su: subList) {
                        SubWrapper suw = new SubWrapper();
                        suw.SubscriptionID = su.id;
                        suw.subscriptionName = su.Name;
                        suw.SiteID = su.Site__c;
                        suw.accessType=su.Access_Type__c;//EDGE-77981
                        suw.siteAddress = su.Site__r.Address__c;
                        suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                        suw.status = su.csord__Status__c;
                        suw.ServiceId = su.serviceMSISDN__c;
                        suw.createdBy = su.CreatedBy.Name;
                        suw.productDefinitionName = su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                        suw.isBillStopped = su.Is_Bill_Stopped__c;
                        suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;//EDGE-98386 - added billing account number
                        suw.suspensionReason = su.Suspension_reason__c;
                        //format date
                        String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                        suw.createdDate = su.CreatedDate.format(dateFormatString);
                        //format currency
                        Decimal rc = su.csord__Total_Recurring_Charges__c;
                        Decimal oc = su.csord__Total_One_Off_Charges__C;
                        String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                            String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
                                suw.totalRC = '$ ' + String.format(finalrc, args);
                        suw.totalOC = '$ ' + String.format(finaloc, args);
                        if (su.csord__status__c != null) {
                            if (SYSTEM.LABEL.Active_Status.equalsIgnoreCase(su.csord__status__c)) {
                                suw.disableRow = false;
                            } else {
                                suw.disableRow = true;
                            }
                        } else {
                            suw.disableRow = true;
                        }
                        
                        suw.isCWP = true;
                        //Added !su.Name.contains('CWP') to allow CWP Mobility products in MAC baskets 
            if (
                !su.name.contains(System.Label.Label_CWP) // && !su.Name.contains('CWP Mobile') && !su.Name.contains('CWP BYO Mobile'))
            ) {
                            suw.isCWP = false;
                            if (!su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name.contains('Mobility')) {
                                suw.disableRow = true;
                            }
                        }
                        
                        subwrapList.add(suw);                        
                    }
        return subwrapList;
    }
    
    public static String getSobjectFields(String so) {
        String fieldString;
        SObjectType sot = Schema.getGlobalDescribe().get(so);
        List < Schema.SObjectField > fields = sot.getDescribe().fields.getMap().values();
        fieldString = fields[0].getDescribe().LocalName;
        for (Integer i = 1; i < fields.size(); i++) {
            fieldString += ',' + fields[i].getDescribe().LocalName;
        }
        return fieldString;
    }
    
    @AuraEnabled
    public static Id addRecords2(List < String > subscriptionIdList, String basketId, String changeType, String accountId, String accountName) {
        String pbasketId = basketId;
        String paccountId = accountId;
        cscfga__Product_Basket__c pBasket = new cscfga__Product_Basket__c(); //Fetch basket to extract respective accountId
        if (accountId != '') {
            try {
                Id macdOpportunityId = createOpportunity(accountId, accountName, changeType);
                pbasketId = createBasket(accountId, macdOpportunityId);
            } catch (Exception e) {
                return null;
            }
        }else{
            pBasket = [SELECT Id, csbb__Account__c FROM cscfga__Product_Basket__c WHERE Id = :basketId];
            paccountId = pBasket.csbb__Account__c;
        }
        List < csord__Subscription__c > subscriptionsListAll = new List < csord__Subscription__c > ();
        List < csord__Subscription__c > subscriptionList = new List < csord__Subscription__c > ();
        List < csordtelcoa__Subscr_MACDProductBasket_Association__c > subscriptionListInBasket = new List < csordtelcoa__Subscr_MACDProductBasket_Association__c > ();
        
        subscriptionListInBasket = [
            SELECT Id, csordtelcoa__Subscription__r.Name, csordtelcoa__Subscription__r.csordtelcoa__Change_Type__c, csordtelcoa__Subscription__r.Id, csordtelcoa__Subscription__c
            FROM csordtelcoa__Subscr_MACDProductBasket_Association__c
            WHERE csordtelcoa__Product_Basket__c =: basketId
        ];
        
        subscriptionsListAll = [
            SELECT Id, Name, csordtelcoa__Change_Type__c, csord__Account__c
            FROM csord__Subscription__c
            WHERE csord__Account__c = :paccountId AND csord__Status__c LIKE :SYSTEM.LABEL.Active_Status
        ];
        subscriptionList = [SELECT Id, Name, csordtelcoa__Change_Type__c FROM csord__Subscription__c WHERE Id = :subscriptionIdList];
        List < Id > sublist = new List < Id > ();
        /*Rr. no. 5 ~ Updated below loop for the issue Edge-67962*/
        //Mladen - refactoring the nested if..else statements to be able to deploy EDGE-77981
        List < csordtelcoa__Subscr_MACDProductBasket_Association__c > cancelSubscriptionsInBasket = new List<csordtelcoa__Subscr_MACDProductBasket_Association__c>(
            [
                SELECT Id, csordtelcoa__Subscription__r.Name, csordtelcoa__Subscription__r.csordtelcoa__Change_Type__c, csordtelcoa__Subscription__c
                FROM csordtelcoa__Subscr_MACDProductBasket_Association__c
                WHERE csordtelcoa__Product_Basket__c = :basketId AND csordtelcoa__Subscription__r.csordtelcoa__Change_Type__c = :System.Label.Cancel
            ]
        );
        
        //if (changeType == 'Cancel' && subscriptionsListAll.size() != subscriptionList.size()){
        if (
            changeType == 'Cancel' &&
            subscriptionsListAll.size() != subscriptionList.size() &&
            subscriptionsListAll.size() == subscriptionList.size() + subscriptionListInBasket.size() &&
            cancelSubscriptionsInBasket.size() + 2 == subscriptionListInBasket.size()
        ) {
                //if(subscriptionsListAll.size() == subscriptionList.size() + subscriptionListInBasket.size()
                //&& cancelSubscriptionsInBasket.size() + 2 == subscriptionListInBasket.size()){
                List <cscfga__Product_Configuration__c> statusUpdate = new List <cscfga__Product_Configuration__c>(
                [
                    SELECT Id, Type__c
                    FROM cscfga__Product_Configuration__c
                    WHERE
                        cscfga__Product_Basket__r.Id = :basketId
                     AND (cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.UC_Config_Name + '%'
                          OR cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.IP_Network)
                ]
            );
                for(cscfga__Product_Configuration__c pc: statusUpdate){
                    pc.Type__c = System.Label.Cancel;
                }
                try{
                    if(statusUpdate.size()>0){
                    update statusUpdate;
                }
            } catch (Exception e) {
                    System.debug('An exception occurred  ' + e.getMessage());
                }  
                
                for (csord__Subscription__c subscription: subscriptionList){
                    sublist.add(subscription.Id);
                    subscription.csordtelcoa__Change_Type__c = changeType;
                }                
        } else if (
            changeType == 'Cancel' &&
            subscriptionsListAll.size() != subscriptionList.size() &&
            (subscriptionsListAll.size() != subscriptionList.size() + subscriptionListInBasket.size() ||
            cancelSubscriptionsInBasket.size() + 2 != subscriptionListInBasket.size())
        ) {
                         for (csord__Subscription__c subscription: subscriptionList) {
                             sublist.add(subscription.Id);
                             if (subscription.Name.contains(SYSTEM.LABEL.IP_Network) || subscription.Name.contains(SYSTEM.LABEL.UC_Config_Name)) {
                                 subscription.csordtelcoa__Change_Type__c = CHANGE_TYPE_MODIFY;
                             } else {
                                 subscription.csordtelcoa__Change_Type__c = changeType;
                             }
                         }
        } else if (changeType != 'Cancel' || subscriptionsListAll.size() == subscriptionList.size()) {
            for (csord__Subscription__c subscription: subscriptionList) {
                sublist.add(subscription.Id);
                subscription.csordtelcoa__Change_Type__c = changeType;
            }
        }
        try{
            if(subscriptionList.size()>0){
                update subscriptionList;
        }
        } catch (Exception e) {
            System.debug('An exception occurred  ' + e.getMessage());
        }
        
        cscfga__Product_Basket__c aProductBasket = [SELECT Id, cscfga__Opportunity__c, csordtelcoa__Change_Type__c FROM cscfga__Product_Basket__c WHERE Id = :pbasketId];
        
        createOppSubscriptionAssociations(aProductBasket.cscfga__Opportunity__c, subscriptionIdList);
        updateOpportunityType(aProductBasket.cscfga__Opportunity__c, changeType);
        aProductBasket.csordtelcoa__Change_Type__c = 'Upgrade'; //ChangeType is mandatory for csordtelcoa.API_V1.addSubscriptionsToMacBasket to work
        
        try{
            if(aProductBasket!=null){
                update aProductBasket;
            }
        } catch (Exception e) {
            System.debug('An exception occurred  ' + e.getMessage());
        }
        
        try {
            csordtelcoa.API_V1.addSubscriptionsToMacBasket(sublist, aProductBasket.Id, true);
            //csordtelcoa.API_V1.addSubscriptionsToMacBasket(aProductBasket, subscriptionList, null);
        } catch (Exception e) {
            return null;
            //throw new AuraHandledException('Error occured while trying to add selected Subscriptions to Product Bakset: ' + e.getMessage());
        }
        
        return pbasketId;
    }
    
    //Creates missing Subscription MACDOpportunity Associations.    
    public static void createOppSubscriptionAssociations(Id oppId, List < String > subscriptionIdList) {
        List < csordtelcoa__Subscription_MACDOpportunity_Association__c > subscriptionAssociationList = new List < csordtelcoa__Subscription_MACDOpportunity_Association__c > ();
        
        subscriptionAssociationList = [
            SELECT Id, csordtelcoa__Opportunity__c, csordtelcoa__Subscription__c
            FROM csordtelcoa__Subscription_MACDOpportunity_Association__c
            WHERE csordtelcoa__Opportunity__c =: oppId
        ];
        
        Set < Id > subscriptionAssociationSet = new Set < Id > ();
        
        for (csordtelcoa__Subscription_MACDOpportunity_Association__c subscriptionAssociation: subscriptionAssociationList) {
            subscriptionAssociationSet.add(subscriptionAssociation.csordtelcoa__Subscription__c);
        }
        
        subscriptionAssociationList = new List < csordtelcoa__Subscription_MACDOpportunity_Association__c > ();
        for (String subscriptionId: subscriptionIdList) {
            if (!subscriptionAssociationSet.contains(subscriptionId)) {
                csordtelcoa__Subscription_MACDOpportunity_Association__c subscriptionAssociation = new csordtelcoa__Subscription_MACDOpportunity_Association__c();
                subscriptionAssociation.csordtelcoa__Opportunity__c = oppId;
                subscriptionAssociation.csordtelcoa__Subscription__c = subscriptionId;
                
                subscriptionAssociationList.add(subscriptionAssociation);
            }
        }
        insert subscriptionAssociationList;
    }
    
    public static Id createOpportunity(Id accountId, String accountName, String changeType) {
        Opportunity opp = new Opportunity();
        Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(OPPORTUNITY_REC_TYPE).getRecordTypeId();
        
        opp.Name = changeType + ' ' + accountName; //datetime.now();
        opp.RecordTypeId = oppRecordTypeId;
        opp.StageName = OPPORTUNITY_STAGE;
        opp.CloseDate = date.today().addDays(30);
        opp.Type = (changeType == 'Modify') ? OPPORTUNITY_TYPE_MAC : OPPORTUNITY_TYPE_DISCONNECT;
        opp.Product_Type__c = OPPORTUNITY_PRODUCT_TYPE;
        opp.AccountId = accountId;
        opp.Product_Domain__c = OPPORTUNITY_PRIMARY_DOMAIN;
        opp.In_Contract_MAC__c = OPPORTUNITY_IN_CONTRACT;
        opp.AgreetoTerms__c = true;//Sr no 2.   
        //opp.Competitor__c = ;
        //opp.Description__c = ; // comments / description
        //opp.Cancellation_Reason__c = ;
        opp.Is_MACD__c = true; //EDGE-140756
    
        insert opp;
        return opp.Id;
    }
    
    public static Id createBasket(Id accountId, Id opportunityId) {
        String profileName = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId()].Name;
        cscfga__Product_Basket__c macBasket = new cscfga__Product_Basket__c();
        macBasket.Primary_Basket__c = true;
        macBasket.csbb__Account__c = accountId;
        macBasket.cscfga__Opportunity__c = opportunityId;
        macBasket.csordtelcoa__Change_Type__c = BASKET_CHANGE_TYPE;
        macBasket.csordtelcoa__Basket_Stage__c = BASKET_CHANGE_STAGE;
        if(profileName=='Assurance Service Agent'){
            macBasket.Pre_Authorised__c=true;
        }
        
        insert macBasket;
        return macBasket.Id;
    }
    
    public static void updateOpportunityType(Id opportunityId, String changeType) {
        if (changeType == CHANGE_TYPE_MODIFY) {
            Opportunity opp = new Opportunity();
            opp = [SELECT Type FROM Opportunity WHERE Id =: opportunityId];
            
            if (opp.Type == OPPORTUNITY_TYPE_DISCONNECT) {
                opp.Type = OPPORTUNITY_TYPE_MAC;
                update opp;
            }
        }
    }
    
    public static Set < Id > getProductConfigurationsInUse(Id accountId) {
        Set < Id > prodConfigIdSet = new Set < Id > ();
        
        List < cscfga__Product_Configuration__c > prodConfigList = new List < cscfga__Product_Configuration__c > ();
        prodConfigList = [
            SELECT csordtelcoa__Replaced_Product_Configuration__c
                          FROM cscfga__Product_Configuration__c
            WHERE
                cscfga__Product_Basket__r.csbb__Account__c = :accountId
                AND cscfga__Product_Basket__r.csbb__Synchronised_With_Opportunity__c = TRUE
                          AND cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c IN('Contract Initiated', 'Contract Accepted', 'Enriched', 'Submitted')
                AND csordtelcoa__Replaced_Product_Configuration__c != NULL
                          AND(NOT cscfga__Product_Basket__r.cscfga__Opportunity__r.StageName LIKE 'Closed%')
                          AND(NOT cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.UC_Config_Name + '%')
                          AND(NOT cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.IP_Network)
                          AND(NOT cscfga__Product_Definition__r.Name LIKE: SYSTEM.LABEL.Mobility)
                         ];
        
        for (cscfga__Product_Configuration__c prodConfig: prodConfigList) {
            prodConfigIdSet.add(prodConfig.csordtelcoa__Replaced_Product_Configuration__c);
        }
        return prodConfigIdSet;
    }
    
    // Method to check if some product type is present in the basket 
    @AuraEnabled
    public static boolean ifProductPresent(String basketId, String type) {
        boolean present = false;
        List < cscfga__Product_Configuration__c > basket = new List < cscfga__Product_Configuration__c > ();
        basket = [SELECT id, Name FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId];
        for (cscfga__Product_Configuration__c product: basket) {
            if (product.Name.contains(type)) {
                present = true;
            }
        }
        return present;
    }
    @AuraEnabled
    public static Integer noOfProductPresentUnderModify(String basketId, String type) {
        Integer present = 0;
        List < cscfga__Product_Configuration__c > basket = new List < cscfga__Product_Configuration__c > ();
        basket = [SELECT id, Name, cscfga__Product_Definition__r.Name, Type__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId];
        for (cscfga__Product_Configuration__c product: basket) {
            if (product.cscfga__Product_Definition__r.Name.contains(type) && product.Type__c == 'Modify') {
                present++;
            }
        }
        return present;
    }
    
    @AuraEnabled
    public static AccountContactRelation acr { get; set; }
    @AuraEnabled
    public static AccountContactRelation getACRId(Id basketId) {
        List<cscfga__Product_Basket__c> basket = new List<cscfga__Product_Basket__c>(
            [SELECT csbb__Account__r.id, cscfga__Opportunity__r.id FROM cscfga__Product_Basket__c WHERE id = :basketId]
        );
        List<OpportunityContactRole> ocr = new List<OpportunityContactRole>(
            [SELECT Id, ContactId FROM OpportunityContactRole WHERE OpportunityId = :basket[0].cscfga__Opportunity__r.id]
        );
        if (!ocr.IsEmpty()) {
            List<AccountContactRelation> listACR = new List<AccountContactRelation>(
                [
                    SELECT id, ContactId, AccountId, Contact_Name__c, Roles
                    FROM AccountContactRelation
                    WHERE AccountId = :basket[0].csbb__Account__r.id AND ContactId = :ocr[0].ContactId
                ]
            );
            
            if (!listACR.IsEmpty())
                AccountContactRelation acr = new AccountContactRelation();
            acr = listACR[0];
            return acr;
        }
        return null;
    }
    @AuraEnabled
    public static String getPathPrefix(){
        return Site.getPathPrefix();
    }
    
    // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - add product Specification code for IOT
    @AuraEnabled // Sr.3 new method for dispaying subscriptions for assurance agent
    public static List < SubWrapper > getSubscriptionViewForAssuranceAgent(String accountId) {
        String accId = accountId;
        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        csordtelcoa__Orders_Subscriptions_Options__c OS = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        String status = OS.csordtelcoa__Subscription_Closed_Replaced_State__c;
        String blockedStatus = OS.csordtelcoa__Statuses_Not_Allowing_Change__c;
        List<String> specCode = new List<String>{PS420,PS1196};//DPG:4542; List of specs AM/CMP
        Map<String,Map<String,String>> offerspecificOptionsMap = ShowSubscriptionsOnMACButtonController.getSuspensionReasonMap();//DPG:4542; Offer Specific ReasonOption map
        //hide used subscriptions in MACD
        if(accId !=null){
            List < csord__Subscription__c > subList = [
                SELECT
                    id,
                Site__c,
                Site__r.Name,
                Site__r.Address__c,
                csordtelcoa__Subscription_Number__c,
                CreatedDate,
                csord__Status__c,
                csord__Total_Recurring_Charges__c,
                csord__Total_One_Off_Charges__c,
                CreatedById,
                CreatedBy.Name,
                csord__Account__c,
                    Name,
                    serviceMSISDN__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                    Is_Bill_Stopped__c,
                    Billing_Account__r.Billing_Account_Number__c,
                    Suspension_reason__c,
                    MarketableOffer__r.Offer_ID__c,
                    csord__Order__r.csord__Status2__c,Suspension_reason_summary__c//DPG-4542; query Suspension_reason_summary__c
                FROM csord__Subscription__c
                WHERE
                (csord__Status__c = :system.label.subscription_Suspended_Status OR csord__Status__c = :system.label.Active)//DPG-4542(To Show suspened reasons)//To show only Active subscriptions for sim replacement ~ EDGE-87725
                AND csord__Account__c =: accId
                    AND csordtelcoa__Replacement_Subscription__c = NULL
                    AND (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS420
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS312
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS871
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS747
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS965
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS1196)//DPG-4542
            ];          
            List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                        for (csord__Subscription__c su: subList) {
                          if((specCode.contains(su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c) 
                          && su.csord__Order__r.csord__Status2__c == 'Completed' && su.csord__Status__c == system.label.subscription_Suspended_Status) 
                          || (su.csord__Status__c == system.label.Active)){//DPG:4542 ; Show Suspended Subscritpion Order for AM/CMP and Active subs for all offers
                            SubWrapper suw = new SubWrapper();
                            suw.SubscriptionID = su.id;
                            suw.subscriptionName = su.Name;
                            suw.SiteID = su.Site__c;
                            suw.siteAddress = su.Site__r.Address__c;
                            suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                            suw.status = su.csord__Status__c;
                            suw.ServiceId = su.serviceMSISDN__c;
                            suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;//EDGE-98386 - added billing account number
                            suw.suspensionReason = ShowSubscriptionsOnMACButtonController.getReasonDescription(su.Suspension_reason__c);//DPG-4542
                            suw.suspensionReasonDescriptionCodeMap = offerspecificOptionsMap.containskey('noValue')?null:(offerspecificOptionsMap.get(su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)==null?offerspecificOptionsMap.get('default'): offerspecificOptionsMap.get(su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c));//DPG-4542
                            suw.suspensionReasonSummary =  ShowSubscriptionsOnMACButtonController.getReasonDescription(su.Suspension_reason_summary__c);//DPG-4542
                            suw.createdBy = su.CreatedBy.Name;
                            suw.productDefinitionName = su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                            suw.MarketOffer=su.MarketableOffer__r.Offer_ID__c;
                            //EDGE-84486
                            suw.isBillStopped = true;
                            //format date
                            String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                            suw.createdDate = su.CreatedDate.format(dateFormatString);
                            //format currency
                            Decimal rc = su.csord__Total_Recurring_Charges__c;
                            Decimal oc = su.csord__Total_One_Off_Charges__C;
                            String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                                String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
                                    suw.totalRC = '$ ' + String.format(finalrc, args);
                            suw.totalOC = '$ ' + String.format(finaloc, args);
                            if (su.csord__status__c != null && !SYSTEM.LABEL.Active_Status.equalsIgnoreCase(su.csord__status__c) && !system.label.subscription_Suspended_Status.equalsIgnoreCase(su.csord__status__c)) {//DPG4542
                                suw.disableRow = true;
                            }else{
                                suw.disableRow = false;
                            }
                            suw.isCWP = true;
                            subwrapList.add(suw);
                            }
                        }             
        }
        return subwrapList;
    }
    
    /*********************************************************************************************************************************
* Method Name      :   invokeMSISDNForNumberChange
*Return            :   Returns String with as a value Success
*Story             :   EDGE-84486
**********************************************************************************************************************************/
    //calls msisdn for change of mobile number scenario
    @AuraEnabled
    public static String invokeMSISDNForNumberChange(List<String> subId) { 
        //System.debug('subId======::'+subId);
        MSISDNReserveServiceHandler msisdn = new MSISDNReserveServiceHandler();
        List<Id> orderIds = new List<Id>();
        List<csord__Subscription__c> subList = [SELECT id, name, csord__Order__c, Primary_Order__c, Bill_Stopped__c FROM csord__Subscription__c WHERE id IN :subId];
        List<ID> orderList = new List<ID>();
        List<csord__Order__c> ordListToUpdate = new List<csord__Order__c>();
        for(csord__Subscription__c sub :subList){
            orderIds.add(sub.csord__Order__c);
            // sub.Bill_Stopped__c = true;
        }
       /* for(csord__Order__c ord :[SELECT ID,isMSISDNHeld__c,isMSISDNRequired__c,isMSISDNReserved__c FROM csord__Order__c WHERE ID IN :orderIds]){
            ord.isMSISDNHeld__c = false;
            ord.isMSISDNRequired__c = false;
            ord.isMSISDNReserved__c = false;
            ordListToUpdate.add(ord);
            //update ord;
        }
        update ordListToUpdate; */      
        // System.debug('orderIds::'+orderIds);
        //updates method signature
        //msisdn.MSISDNReserveServices(orderIds,'Change of Mobile Number',subId);
        String res = ChangeOfMobileNumber_Handler.MSISDNReserveServices('Change of Mobile Number',subId);
        // System.debug('subId::'+subId);
        //return SUCCESS;
        return res;
        //msisdn.MSISDNReserveServices();
    }
    
    @AuraEnabled
    public static void updateOrders(List<String> subId) { 
        List<Id> orderIds = new List<Id>();
        List<csord__Subscription__c> subList = [SELECT id, name, csord__Order__c, Primary_Order__c, Bill_Stopped__c FROM csord__Subscription__c WHERE id IN :subId];
        List<ID> orderList = new List<ID>();
        List<csord__Order__c> ordListToUpdate = new List<csord__Order__c>();
        for(csord__Subscription__c sub :subList){
            orderIds.add(sub.csord__Order__c);
            // sub.Bill_Stopped__c = true;
        }
        // update subList;
        //orderList.addAll(orderIds);
        //System.debug('subList==>'+subList);
        
        for(csord__Order__c ord :[SELECT ID,isMSISDNHeld__c,isMSISDNRequired__c,isMSISDNReserved__c FROM csord__Order__c WHERE ID IN :orderIds]){
            ord.isMSISDNHeld__c = false;
            ord.isMSISDNRequired__c = false;
            ord.isMSISDNReserved__c = false;
            ordListToUpdate.add(ord);
            //update ord;
        }
        update ordListToUpdate;
    }
    
    /*********************************************************************************************************************************
* Method Name      :   submitOrder
*Return            :   Returns String with as a value Success after submitting Change Of Mobile Number order
*Story             :   EDGE-84486
**********************************************************************************************************************************/
    @AuraEnabled
    public static String submitOrder(List<String> subId,String scenarioType, String tNowCaseRef) {
        String accountId = '';
         String result = ''; //Shweta added this: EDGE:185521
        List<csord__Order__c> orderList=new  List<csord__Order__c>();
        try{
            for(csord__Subscription__c eachSub : [SELECT ID,Primary_Order__c,csord__Account__c,csord__Order__c FROM csord__Subscription__c WHERE ID IN :subId] ){
                accountId = eachSub.csord__Account__c;
            }
            
            orderList = OrderGeneratorUtil.generateOrderForScenarioType(subId,accountId,scenarioType,tNowCaseRef);//EDGE-132715 Added tNowCaseRef
            result = orderList[0].id; //Shweta added this: EDGE:185521
        } catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
        }
        
        if(orderList.size()>0){
            // System.debug(SUCCESS);
            //return SUCCESS; //Shweta commented this  EDGE:185521
            return result; //Shweta added this  EDGE:185521
        }
        return  null;
    }
    
    @AuraEnabled
    public static String submitOrderForSuspend(List<String> subId,String scenarioType,String tNowCaseRef,Map<String, String> subsToReasonMap ) //DPG-4543 || DPG-4544, Ila || Krunal, Removed reason parameter
    {
        String accountId = '';
        String result = ''; //Shweta added this: EDGE:185521
        List<csord__Order__c > orderList=new List<csord__Order__c >();
        try{
            for (csord__Subscription__c eachSub : [
                SELECT ID, Primary_Order__c, csord__Account__c, csord__Order__c, Suspension_reason__c
                FROM csord__Subscription__c
                WHERE ID IN :subId
            ]) {
                accountId = eachSub.csord__Account__c;
            }
            
            orderList = OrderGeneratorUtil.generateOrderForSuspendResume(subId,accountId,scenarioType,tNowCaseRef,subsToReasonMap);//EDGE-132715 Added tNowCaseRef; DPG-4543 || DPG-4544, Ila || Krunal, Removed reason parameter
            // System.debug('orderList::'+orderList);
            //Shweta added this: EDGE:185521
            result = orderList[0].id;
        } catch (Exception e) {
            system.debug('e.getMessage()'+e.getMessage());
        }
        if(orderList.size()>0){
            // System.debug(SUCCESS);
            //return SUCCESS; //Shweta commented this  EDGE:185521
            return result; //Shweta added this  EDGE:185521
            }
        return  null;
    }
    
    /* @AuraEnabled
public static void updateReasonForSuspend(List<String> subId,String scenarioType,String reason) {
List<csord__Subscription__c> subList = new List<csord__Subscription__c>();
for(csord__Subscription__c sub : [SELECT ID,csord__Account__c,Suspension_reason__c FROM csord__Subscription__c WHERE ID IN :subId] ){
sub.Suspension_reason__c=reason;
subList.add(sub);
}
update subList;


}*/
    // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - add product Specification code for IOT
    @AuraEnabled // EDGE-91569 new method for dispaying suspended subscriptions for assurance agent
    public static List < SubWrapper > getSuspendedSubscriptionViewForAssuranceAgent(String accountId) {
        Map<String,Map<String,String>> offerspecificOptionsMap = ShowSubscriptionsOnMACButtonController.getSuspensionReasonMap();//DPG:4542
        String accId = accountId;
        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        csordtelcoa__Orders_Subscriptions_Options__c OS = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        String status = OS.csordtelcoa__Subscription_Closed_Replaced_State__c;
        String blockedStatus = OS.csordtelcoa__Statuses_Not_Allowing_Change__c;
        //hide used subscriptions in MACD
        if(accId !=null){
            List < csord__Subscription__c > subList = [
                SELECT
                    id,
                Site__c,
                Site__r.Name,
                Site__r.Address__c,
                csordtelcoa__Subscription_Number__c,
                CreatedDate,
                csord__Status__c,
                csord__Total_Recurring_Charges__c,
                csord__Total_One_Off_Charges__c,
                CreatedById,
                CreatedBy.Name,
                csord__Account__c,
                    Name,
                    serviceMSISDN__c,
                Suspension_reason__c,
                    csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                    Is_Bill_Stopped__c,
                    Billing_Account__r.Billing_Account_Number__c,Suspension_reason_summary__c//DPG:4542
                FROM csord__Subscription__c
                WHERE
                    csord__Status__c = :system.label.subscription_Suspended_Status //To show only suspended subscriptions for resume actiontype ~ EDGE-91569
                AND csord__Account__c =: accId
                    AND csordtelcoa__Replacement_Subscription__c = NULL
                    AND (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS420
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS312
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS871
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS747
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS965
                    OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS1196)
            ];          
            List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                        for (csord__Subscription__c su: subList) {
                            SubWrapper suw = new SubWrapper();
                            suw.SubscriptionID = su.id;
                            suw.subscriptionName = su.Name;
                            suw.SiteID = su.Site__c;
                            suw.siteAddress = su.Site__r.Address__c;
                            suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                            suw.status = su.csord__Status__c;
                            suw.ServiceId = su.serviceMSISDN__c;
                            suw.createdBy = su.CreatedBy.Name;
                            suw.suspensionReason = su.Suspension_reason__c;
                            suw.suspensionReasonDescriptionCodeMap = offerspecificOptionsMap.containskey('noValue')?null:(offerspecificOptionsMap.get(su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c)==null?offerspecificOptionsMap.get('default'): offerspecificOptionsMap.get(su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c));//DPG-4542
                            suw.suspensionReasonSummary =  ShowSubscriptionsOnMACButtonController.getReasonDescription(su.Suspension_reason_summary__c);//DPG-4542
                            suw.productDefinitionName = su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                            //EDGE-84486
                            suw.isBillStopped = su.Is_Bill_Stopped__c;
                            suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;////EDGE-98386 - added BAN
                            //format date
                            String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                            suw.createdDate = su.CreatedDate.format(dateFormatString);
                            //format currency
                            Decimal rc = su.csord__Total_Recurring_Charges__c;
                            Decimal oc = su.csord__Total_One_Off_Charges__C;
                            String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                                String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
                                    suw.totalRC = '$ ' + String.format(finalrc, args);
                            suw.totalOC = '$ ' + String.format(finaloc, args);
                            if (su.csord__status__c != null && su.csord__status__c.equalsIgnoreCase('Active')) {
                                suw.disableRow = true;
                            }else{
                                suw.disableRow = false;
                            }
                            suw.isCWP = true;
                            subwrapList.add(suw);
                        }             
        }
        return subwrapList;
    }
    
    //INC000093801785 Removed NGUC product Config code from query ('DMCAT_ProductSpecification_000871') for SIM replacement and Change of Mobile number. 
    // DPG-1891 & DPG-1892 Suspend IoT Services and Resume IoT Services - add product Specification code for IOT
    @AuraEnabled // EDGE-91569 new method for dispaying suspended subscriptions for assurance agent
    public static List < SubWrapper > getActiveSuspendedSubscriptionViewForAssuranceAgent(String accountId , String actionTypeSelected) {
        String accId = accountId;
        List < Subwrapper > subwrapList = new List < SubWrapper > ();
        csordtelcoa__Orders_Subscriptions_Options__c OS = csordtelcoa__Orders_Subscriptions_Options__c.getOrgDefaults();
        String status = OS.csordtelcoa__Subscription_Closed_Replaced_State__c;
        String blockedStatus = OS.csordtelcoa__Statuses_Not_Allowing_Change__c;
        //hide used subscriptions in MACD
        if(accId !=null){
            List < csord__Subscription__c > subList = new List < csord__Subscription__c >(); 
            //EDGE-208199 -- changes starts here  
            // where clause for PS871 needs to be changed in future to make it configurable
            if(actionTypeSelected=='Manage Fixed Numbers'){
                subList = [
                    SELECT
                        id,
                    Site__c,
                    Site__r.Name,
                    Site__r.Address__c,
                    csordtelcoa__Subscription_Number__c,
                    CreatedDate,
                    csord__Status__c,
                    csord__Total_Recurring_Charges__c,
                    csord__Total_One_Off_Charges__c,
                    CreatedById,
                    CreatedBy.Name,
                    csord__Account__c,
                        Name,
                        serviceMSISDN__c,
                    Suspension_reason__c,
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                        Is_Bill_Stopped__c,
                        Billing_Account__r.Billing_Account_Number__c,
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                        MarketableOffer__r.Offer_ID__c,
                        csord__Order__r.csord__Order_Number__c, //EDGE-205903
                      customerFacingServiceId__c
                    FROM csord__Subscription__c
                    WHERE
                        (csord__Status__c = :system.label.subscription_Suspended_Status
                        OR csord__Status__c = :system.label.Active) //To show only suspended subscriptions for resume actiontype ~ EDGE-91569
                    AND csord__Account__c =: accId
                        AND csordtelcoa__Replacement_Subscription__c = NULL
                        AND (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS871 OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS1523)
                ];
            }
            //EDGE-208199 -- changes ends here 
            else{
                subList = [
                    SELECT
                        id,
                    Site__c,
                    Site__r.Name,
                    Site__r.Address__c,
                    csordtelcoa__Subscription_Number__c,
                    CreatedDate,
                    csord__Status__c,
                    csord__Total_Recurring_Charges__c,
                    csord__Total_One_Off_Charges__c,
                    CreatedById,
                    CreatedBy.Name,
                    csord__Account__c,
                        Name,
                        serviceMSISDN__c,
                    Suspension_reason__c,
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Name,
                        Is_Bill_Stopped__c,
                        Billing_Account__r.Billing_Account_Number__c,
                        csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c,
                        MarketableOffer__r.Offer_ID__c,
                      customerFacingServiceId__c
                    FROM csord__Subscription__c
                    WHERE
                        (csord__Status__c = :system.label.subscription_Suspended_Status
                        OR csord__Status__c = :system.label.Active) //To show only suspended subscriptions for resume actiontype ~ EDGE-91569
                    AND csord__Account__c =: accId
                        AND csordtelcoa__Replacement_Subscription__c = NULL
                        AND (csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS420
                        OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS312
                        OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS747
                        OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS965
                        OR csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c = :PS1196) /*EDGE-166431 added by ankit*/
                ];   
            }
            List<String> args = new List<String>{ '0', 'number', '###,###,##0.00' };
                        for (csord__Subscription__c su: subList) {
                            SubWrapper suw = new SubWrapper();
                            suw.SubscriptionID = su.id;
                            suw.subscriptionName = su.Name;
                            suw.SiteID = su.Site__c;
                            suw.siteAddress = su.Site__r.Address__c;
                            suw.subscriptionNumber = su.csordtelcoa__Subscription_Number__c;
                            suw.status = su.csord__Status__c;
                            //Added by Nikhil as part of Incident INC000096088639
                            System.debug(LoggingLevel.INFO,su.MarketableOffer__r?.Offer_ID__c);
                            if(su.MarketableOffer__r?.Offer_ID__c == Label.Nguc_Offer){
                                suw.ServiceId = su.customerFacingServiceId__c;
                            }else{
                                suw.ServiceId = su.serviceMSISDN__c;
                            }
                            suw.createdBy = su.CreatedBy.Name;
                            suw.suspensionReason = su.Suspension_reason__c;
                            suw.productDefinitionName = su.csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c;
                            //EDGE-84486
                            suw.isBillStopped = su.Is_Bill_Stopped__c;
                            suw.billingAccount = su.Billing_Account__r.Billing_Account_Number__c;//EDGE-98386 - added BAN
                            //format date
                            String dateFormatString = 'dd/MM/yyyy HH:mm:ss';
                            suw.createdDate = su.CreatedDate.format(dateFormatString);
                            suw.MarketOffer=su.MarketableOffer__r.Offer_ID__c;
                            //format currency
                            Decimal rc = su.csord__Total_Recurring_Charges__c;
                            Decimal oc = su.csord__Total_One_Off_Charges__C;
                            String finalrc = rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                                String finaloc = oc.format().contains('.') ? oc.format() : (oc.format() + '.00');
                                    suw.totalRC = '$ ' + String.format(finalrc, args);
                            suw.totalOC = '$ ' + String.format(finaloc, args);
                            if (su.csord__status__c == null) {
                                suw.disableRow = true;
                            }else{
                                suw.disableRow = false;
                            }
                            suw.isCWP = true;
                            suw.OrderNumber = actionTypeSelected.equalsIgnoreCase('Manage Fixed Numbers') ? su.csord__Order__r.csord__Order_Number__c : null;//EDGE-205903
                            subwrapList.add(suw);
                        }             
        }
        return subwrapList;
    }  
  
  
  
    /* public static string getMarketoffer(String sub)
{
String marketOffer;
Marketable_Offer__c mkt=[select id,Offer_ID__c from Marketable_Offer__c where ];
return marketOffer;
}*/
    /**********************************************************************************************************
    EDGE        -140733
    Method      -getNgucPortOutPermission
    Description -Check Logged in user has Nguc port Out permission
    Author      -Dheeraj Bhatt
    ************************************************************************************************************/    
    @AuraEnabled
    public static Boolean getNgucPortOutPermission(){
        Boolean hasNgucportOutPermission=false;
        List<PermissionSetAssignment> permissionSetAssignmentList = [
            SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.ProfileId, PermissionSet.Profile.Name, AssigneeId, Assignee.Name
            FROM PermissionSetAssignment
            WHERE PermissionSet.Name = 'NgUc_Port_out' AND AssigneeId = :userInfo.getUserId()
        ];
        if(!permissionSetAssignmentList.IsEmpty()){
            hasNgucportOutPermission=true;
        }
        return hasNgucportOutPermission;
    } 

    /**********************************************************************************************************
    EDGE        -EDGE-140756,EDGE-174770,EDGE-210731 
    Method      -getMACDActionTypes
    Description -Read MACD Action Types picklist values from custom settings MACD Action Types Custom Settings
    Author      -RaviTeja K/Bharagva/Pooja
    ************************************************************************************************************/    
    @AuraEnabled
    public static Map<String,String> getMACDActionTypes(String isActivePOR){
        Map<String,String> options  =   new Map<String,String>(); 
        List<String> actionTypes    =   new List<String>();
        List<String> fieldsList     =   new List<String>{'Id','MasterLabel','DeveloperName','Action_Types_for_Active_POR__c',
                    'Action_Types_for_Insolvency_Consultants__c','Action_Types_in_General__c','Profile_User__c',
                    'Profile_User__r.Salesforce_Id__c','Profile_User__r.DeveloperName'};
        try {
            MACD_Order_Options__mdt macdtyps    =   GenericUtilityClass.retrieveEligibleActionTypes(UserInfo.getUserId(),UserInfo.getProfileId(),fieldsList);
            String actionType_Insolvency        =   (String.isNotBlank(macdtyps.Action_Types_for_Insolvency_Consultants__c) ? macdtyps.Action_Types_for_Insolvency_Consultants__c : '');  
            String actionType_ActivePOR         =   (String.isNotBlank(macdtyps.Action_Types_for_Active_POR__c) ? macdtyps.Action_Types_for_Active_POR__c : '');  
            String actionType_General           =   (String.isNotBlank(macdtyps.Action_Types_in_General__c) ? macdtyps.Action_Types_in_General__c : '');  
            if (FeatureManagement.checkPermission('InsolvencyConsultants') || FeatureManagement.checkPermission('Collection_Agent_Written_Off_Permission')) {
                actionTypes.addAll(actionType_Insolvency.split(','));
            } else if (isActivePOR == 'Active') {
                actionTypes.addAll(actionType_ActivePOR.split(','));
            } else {
                actionTypes.addAll(actionType_General.split(','));
            }
            for(String oAT : actionTypes) {
                options.put(oAT,oAT);
            }
            if(!getNgucPortOutPermission() && options.containsKey('Port Out')){
                options.remove('Port Out');
            }
        } catch (Exception e) {
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return options;
    } 

    /**********************************************************************************************************
    EDGE        -EDGE-166431
    Method      -getReplacmentReson
    Description -Read Replacment Reason picklist values from custom settings Replacement Reason
    Author      -Ankit Goswami
    ************************************************************************************************************/    

    @AuraEnabled
    public static Map<String,String> getReplacmentReson(){
            Map<String, String> options = new Map<String, String>();        
            Map<String, Object> deserializedOptions=new Map<String, Object>();  
        
        list<string> valueList = new List<string>();
        for (Replacement_Reason__mdt mdtvalue : [
            SELECT id, isActive__c, Replacement_Reason__c, Replacement_Reason_Code__c, Replacement_Type__c, sortOrder__c
            FROM Replacement_Reason__mdt
            WHERE isActive__c = TRUE
            ORDER BY sortOrder__c ASC
        ]) {
                valueList.add(mdtvalue.Replacement_Reason__c);
            }     
            for(String str:valueList){
                options.put(str,str); 
            }
            return options;
        }
    @AuraEnabled
    public static String getCSMPortalDetails() {
            return TNOW_CSM_URL__c.getInstance().PortalUrl__c + '|' + TNOW_CSM_URL__c.getInstance().KAUrl__c;
    }
    /**********************************************************************************************************
    Story       -DPG-4542
    Method      -getSuspensionReasonMap
    Author      -Shresth Dixit
    Description  - Return offer specific reason options map based on logged in profile and assigned permission set
    ************************************************************************************************************/
    public static Map<String,Map<String,String>> getSuspensionReasonMap(){//DPG-4542
        Map<String,Map<String,String>> offerspecificOptionsMap = new Map<String,Map<String,String>>();
        List<String> permissionSetNameList = new List<String>();
        String profileName = [Select Name from Profile where Id = :Userinfo.getProfileId()].Name;
        if(profileName ==System.Label.Billing_Consultant){
            permissionSetNameList.add(System.Label.Collection_Consultant);//label
        }
        else if(profileName ==System.Label.Billing_and_Support){//label
            permissionSetNameList.add(System.Label.Fraud_Management);//label
            permissionSetNameList.add(System.Label.Credit_Management);//label
        }
        Integer permissionSetCount = [SELECT count() FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN :permissionSetNameList];
        //DPG-5284 | Jenish Shingala | Added Assurance profile in IF condition
        //EDGE - 228872 - Fixed the overridden issue in the if condition
        if((permissionSetCount > 0 && (profileName ==System.Label.Billing_and_Support || profileName ==System.Label.Billing_Consultant)) ||  (profileName== System.Label.PRM_Admin_Australia || profileName ==System.Label.Assurance_Profile || profileName== System.Label.PRM_Community_User_Australia || profileName==System.Label.SystemAdministratorProfile )){ //DPG-5284
            Map<String,Object> suspenstionReasonsObjectMapProfile  = new Map<String,Object>();
            Map<String,Object> suspenstionReasonsObjectMapDefault = new Map<String,Object>();
            if(Suspension_reason__c.getInstance().Options__c!=NULL){
                suspenstionReasonsObjectMapProfile= (Map<String,Object>) JSON.deserializeUntyped(Suspension_reason__c.getInstance().Options__c);
            }
            if(Suspension_reason__c.getOrgDefaults().Options__c!=NULL){
                suspenstionReasonsObjectMapDefault= (Map<String,Object>) JSON.deserializeUntyped(Suspension_reason__c.getOrgDefaults().Options__c);
            }
            for(String str: suspenstionReasonsObjectMapProfile.keyset()){
                if(offerspecificOptionsMap.get(PS420)==NULL){
                    //offerspecificOptionsMap.put(PS420, new Map<String,String>{(String)suspenstionReasonsObjectMapProfile.get(str)=>str});
                    offerspecificOptionsMap.put(PS420, new Map<String,String>{str=>(String)suspenstionReasonsObjectMapProfile.get(str)});
                }
                else{
                    offerspecificOptionsMap.get(PS420).put(str,(String)suspenstionReasonsObjectMapProfile.get(str));
                }
                if(offerspecificOptionsMap.get(PS1196)==NULL){
                    offerspecificOptionsMap.put(PS1196, new Map<String,String>{str=>(String)suspenstionReasonsObjectMapProfile.get(str)});
                }
                else{
                    offerspecificOptionsMap.get(PS1196).put(str,(String)suspenstionReasonsObjectMapProfile.get(str));
                }
                if(offerspecificOptionsMap.get('allValues')==NULL){
                   offerspecificOptionsMap.put('allValues', new Map<String, String>{str=>(String)suspenstionReasonsObjectMapProfile.get(str)});
                }
                else{
                   offerspecificOptionsMap.get('allValues').put(str,(String)suspenstionReasonsObjectMapProfile.get(str));
                }
            }

            for(String str: suspenstionReasonsObjectMapDefault.keyset()){ 
                if(offerspecificOptionsMap.get('default')==NULL){
                    offerspecificOptionsMap.put('default', new Map<String,String>{str=>(String)suspenstionReasonsObjectMapDefault.get(str)});
                }
                else{
                    offerspecificOptionsMap.get('default').put(str,(String)suspenstionReasonsObjectMapDefault.get(str));
                }
                if(offerspecificOptionsMap.get('allValues')==NULL){
                    offerspecificOptionsMap.put('allValues', new Map<String, String>{str=>(String)suspenstionReasonsObjectMapDefault.get(str)});
                }
                else{
                    offerspecificOptionsMap.get('allValues').put(str,(String)suspenstionReasonsObjectMapDefault.get(str));
                }
            }

            return offerspecificOptionsMap;
        }
        else{
            offerspecificOptionsMap.put('noValue',null);//show always requested by customer requested in 
            return offerspecificOptionsMap;
        }
        return offerspecificOptionsMap;//Edge-223597
    }
    /**********************************************************************************************************
    Story       -DPG-4542
    Method      -getReasonDescription
    Author      -Shresth Dixit
    Description - Get description value of code maintained in Suspension Reason & Suspension Reason Summary on Subscription
    ************************************************************************************************************/
    public static String getReasonDescription(String reasonCodeSummary){//DPG-4542
        List<String> reasonCodeSummaryDescriptionList = new List<String>();
        if(String.isNotBlank(reasonCodeSummary)){
            Map<String,Object> suspenstionReasonsObjectMapAllValues= (Map<String,Object>) JSON.deserializeUntyped(Suspension_reason__c.getOrgDefaults().All_Values__c);
            Map<String,Object> suspenstionReasonsObjectMapDefault= (Map<String,Object>) JSON.deserializeUntyped(Suspension_reason__c.getOrgDefaults().Options__c);
            suspenstionReasonsObjectMapDefault.putAll(suspenstionReasonsObjectMapAllValues);
            for(String reasonCode : reasonCodeSummary.split(',')){
                if(String.isNotBlank((String)suspenstionReasonsObjectMapDefault.get(reasonCode))){ 
                    reasonCodeSummaryDescriptionList.add((String)suspenstionReasonsObjectMapDefault.get(reasonCode)); 
                }
            }
            if(reasonCodeSummaryDescriptionList.size()>0){
                return string.join(reasonCodeSummaryDescriptionList,',');
            }
        }
        return null;
    }  

    /*****************************************************************************************************************************************************
    *   EDGE        -   EDGE-205597 UI/UX:- Enable user to select subscriptions for change of Billing account
    *   Method      -   getFilteredSubscriptionsData
    *   Description -   To get the Subcription(csord__Subscription__c) records
                        1. Parameter inputMap accept map of <fieldName, operator fieldValue>,
                        2. Parameter fieldsList accept the list of fields to be retreived from Subcription Record
                        3. Parameter actionType = Action Type value selected in UI
    *******************************************************************************************************************************/    
     
    @AuraEnabled
    public static List<SubWrapper> getFilteredSubscriptionsData(Map<String, Object> inputMap, List<String> fieldsList, String actionType) {
        List<Subwrapper> subwrapList            =   new List<SubWrapper>();
        List<csord__Subscription__c> subList    =   new List<csord__Subscription__c>();
        List<String> args                       =   new List<String>{ '0', 'number', '###,###,##0.00' };
        String dateFormatString                 =   'dd/MM/yyyy HH:mm:ss';
        try {
            if(actionType.equalsIgnoreCase('Change of Billing Account')) {
                List<csord__Subscription__c> tempSubsList   =   new List<csord__Subscription__c>();
                List<String> filterStatus                   =  new List<String>();
                filterStatus.addAll(GenericUtilityClass.getSubscriptionStatusAllowingCoBA()); 
                inputMap.put('csord__Status__c ','IN ' + filterStatus);
                tempSubsList = (List<csord__Subscription__c>)GenericUtilityClass.getfilteredQueryResult(inputMap, fieldsList, 'csord__Subscription__c');

                subList.addAll(GenericUtilityClass.filterSubcriptionCoBARequest(tempSubsList));

            }
            


        Offer_Id__mdt offerIdMdt = [Select MasterLabel,Template_Family__c,IsActive__c from Offer_Id__mdt where IsActive__c = true and DeveloperName='Telstra_Collaboration' LIMIT 1];
                         
            for(csord__Subscription__c su: subList) {
                SubWrapper suw          =   new SubWrapper();
                suw.SubscriptionID      =   su.Id;
                suw.subscriptionName    =   su.Name;
                suw.subscriptionNumber  =   su.csordtelcoa__Subscription_Number__c;
                suw.ServiceId           =   (su.MarketableOffer__r.Offer_ID__c ==  offerIdMdt.MasterLabel) ? su.customerFacingServiceId__c : su.serviceMSISDN__c;
                suw.SiteID              =   su.Site__c;
                suw.siteAddress         =   su.Site__r.Address__c;
                suw.firstActivationDate =   String.valueOf(su.initialActivationDate__c);
                suw.createdDate         =   su.CreatedDate.format(dateFormatString);
                suw.status              =   su.csord__Status__c;
                Decimal rc              =   su.csord__Total_Recurring_Charges__c;
                String finalrc          =   rc.format().contains('.') ? rc.format() : (rc.format() + '.00');
                suw.totalRC             =   '$ ' + String.format(finalrc, args);
                suw.billingAccount      =   su.Billing_Account__r.Name;
                suw.createdBy           =   su.CreatedBy.Name;
                suw.disableRow          =   ((String.isNotBlank(su.csord__status__c) && su.csord__status__c.equalsIgnoreCase('Active')) ? true : false);
                suw.isCWP               =   true;
                subwrapList.add(suw);
            }             
        } catch(Exception e) {
            throw new AuraHandledException('Exception** ' + e.getLineNumber() + ' ' + e.getMessage());
        }
        return subwrapList;
    }

    /*  
    * Method Name : insertTransactionLogs
    * Author : Gautam Kumar
    * Jira : DIGI-17910
   */
    
    @AuraEnabled
    public static String insertTransactionLogs(String accountId, String orderType, String orderId, String correlationId)
    {
        string corId = '';
        system.debug('G*G insertTransactionLogs subscriptionsOnMac outer called');
        if((FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion')
        && FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion'))){
            
        if(String.isNotBlank(accountId) && String.isNotBlank(orderType) && (orderType == 'Suspend' || orderType == 'Resume')){
            
                system.debug('G*G insertTransactionLogs subscriptionsOnMac inner called');
                
                Map<String,Object> loggerdetailsMap=new Map<String,Object>();
                
                if(String.isBlank(correlationId)){
                    corId = accountId + '-' + orderType.toUpperCase() + System.now().millisecondGMT();
                    loggerdetailsMap.put('event','Order generation initiated');
                    loggerdetailsMap.put('OrderType',orderType);
                }
                else{
                    corId = correlationId;
                    loggerdetailsMap.put('event','Order generation completed');
                    loggerdetailsMap.put('OrderType',orderType);
                    loggerdetailsMap.put('OrderId',orderId);
                }
                TransactionLogger.insertTransactionLogs(corId,loggerdetailsMap,'ShowSubscriptionsOnMACButtonController');
            
        }
    }
        return corId;
    }
    
    /*  
    * Method Name : changeMobileNumberTransactionlogs
    * Owner : Vamsi Krishna Vaddipalli
    * Jira : DIGI-17914
   */
    @AuraEnabled
    public static void changeMobileNumberTransactionlogs(String accountId,String orderId,String datetimeinmillisec)
    {
        Map<String,Object> loggerdetailsMap=new Map<String,Object>();
        string correlationId = accountId+'-CHGMOB'+datetimeinmillisec;
        String orderType = 'Change of mobile number';
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','beforelogsinsertion'))
        {
            if(String.isNotBlank(accountId) && String.isBlank(orderId))
            {
                String event = 'Order generation initiated';
                
                loggerdetailsMap.put('event',event);
                loggerdetailsMap.put('OrderType',orderType);
                TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'ShowSubscriptionsOnMACButtonController');
            }
        }
        
        if(FeatureEligibilityChecker.determineFeatureEligiblity('TransactionLogs','afterlogsinsertion'))
        {
            if(String.isNotBlank(orderId))
            {
                String event = 'Order generation completed';
                
                loggerdetailsMap.put('event',event);
                loggerdetailsMap.put('OrderType',orderType);
                loggerdetailsMap.put('OrderId',orderId);
                TransactionLogger.insertTransactionLogs(correlationId,loggerdetailsMap,'ShowSubscriptionsOnMACButtonController');
            }
        }
        
        
    }

}
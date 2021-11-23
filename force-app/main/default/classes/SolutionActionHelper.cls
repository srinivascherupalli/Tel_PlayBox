/*********************************************************************************************************************************
*Class Name      :   SolutionActionHelper
Test Class : SolutionActionHelperTest
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Ankit Goswami        20/11/2019      EDGE-117256  added serviceMSISDN__c,Name field in Query in GetSubscriptionForConfiguration method
2.            Laxmi Rahate         27/11/2019      EDGE-98299  - Added CIDN in the GetBasket Method Query
3.            Ankit Goswami        30/01/2020      EDGE-132276 Device status update on Device for Macd
4.            Laxmi Rahate         24/02/2020      EDGE-135885 - Added Basket Name in the below Query
5.            Ankit Goswami        25/02/2020      EDGE-123594- Added Initial_Activation_Date__c in the below Query
6.            RaviTeja K           26/02/2020      EDGE-133590- Added Solutions inner query to Basket Query
7.            Aman Soni            26/02/2020      EDGE-135278 - Added Billing_Account__r.Billing_Account_Number__c
8.            Laxmi Rahate         26/02/2020      EDGE-135885 - Added Basket Name in the  Query
9.            shubhi               10/03/2020      EDGE-133963
10.           Aman Soni            26/02/2020      EDGE-138169 - Added initialActivationDate__c
11.           Shubhi               18/0/2020       EDGE-142085
12.           Ankit                25/06/2020      EDGE-148733- Added GetAssetForConfiguration method
13.           RaviTeja             15-07-2020      EDGE-162597-add Product configs to the query
14.           Gnana/Pooja          20/07/2020      Spring 20 upgrade. Added methods
15.           Sandip Deshmane      08/08/2020      Spring20 Upgrade. Added If condition
16.           Manish Berad         03/09/2020      EDGE-168275, EDGE-164350 
17.           Aarathi/Manish       04/09/2020      EDGE-164351
18.           Sandhya              05/09/2020      EDGE-172941 INC000093743308 Fix
19.           shubhi/Ankit         22/08/2020      EDGE-169593 replace id fix
20.           Manuga Kale          10/09/2020      EDGE-165017 Enable a button on CS Solution console for Sales/R2R/Partner users to view Power BI offer explorer
20.           Monali Mukherjee     20/08/2020      DPG-2168 - Added method GetExistingTenancySubscriptionsForBilling
21.           Krunal Taak          02/09/2020      DPG-2577 - P2O validation- getActiveManagedServiceSubscriptionCheckInfo , k='tenancyid'
22.           Shresth Dixit        13/10/2020      DPG-2319
23            Vijay                22/10/2020      EDGE-169456   Pricing Service & Frame Agreements Changes
24            Sandip Deshmane      03/11/2020      EDGE-186945 - cscfga__Price__c added to query and changed from value to Price.
25.           Shubhi/Ankit         30/10/2020      Edge-181996 added condition for non commercial basket
26.           Jagadeswary          25/11/2020      EDGE-188712 added new ETC charge method for AM
27.           Ankit                14/12/2020      EDGE-184443 
28.           Srujana Durvasula    23/12/2020      P2OB-11382 Solution Console - Retrieval of Opportunity details in Solution
27.           Akanksha Jain        23/11/2020      EDGE-170544 modified SOQL to fetch recordtype of basket in GetBasket method
28.           Shubhi               07/01/2021      EDGE-170016 modified SOQL to fetch amentType of basket in GetBasket method
29.           Shishir Pareek       02/02/2021      P2OB-11727 Solution Console - Retrieval of Opportunity Stage details in Solution
30.           Ramcharan Patidar    22/02/2021      P2OB-12186 <Cloudsense><Solution Console> New Business Rule for Opportunities having Partner Account
31.           Shishir Pareek       03/03/2021      P2OB-13129 <CloudSense> Standard Solution | QA2 org | TCV value must be correct on Basket in Sprint 21.03 delivery
32.           Shishir Pareek       29/03/2021      P2OB-13156 <CloudSense><Solution Console> Addition of new fields in the Product Configuration of Solution Console
33.           Vishal Arbune        10/05/2021      EDGE-216217: POS Redemption
34.           Monali Mukherjee     09/06/2021      DPG-5626 - Added GetPurchaseOrderNoForConfiguration Method
35.           Monali Mukherjee     26/04/2021      DPG-4887 - Not able to add new AMC even though we cancel the old AMC upon the same billing account.
36.           Arinjay Singh        19/08/2021      DIGI-15041 - Transition Device Cancellation Charges
37.           Sayantan Halder      01/09/2021      DIGI-15303-Replacing the method getServiceForMAC to process replaceConfigId
38.           Don Navarro          22/10/2021      DIGI-456 added Feature Toggling logic for Adaptive Mobility Order Enrichment
*********************************************************************************************************************************************************************

**/
global with sharing class SolutionActionHelper implements cssmgnt.RemoteActionDataProvider {
    global static List < String > pricingRuleGroupList = new List < String > ();
    @RemoteAction
    global static Map < String, Object > getData(Map < String, Object > inputMap) {
        System.debug('SolutionActionHelper Input Map: ' + inputMap);
        //return getRequiredInfo(inputMap);
        Map < String, Object > returnMap = new Map < String, Object > ();
        Map < String, String > returnMapOE = new Map < String, String > ();
        List < String > configIdList = new List < String > ();
        String CorrelationId = '';
        System.debug('inputMap.keySet():  ' + inputMap.keySet());
        Set < String > inputKey = inputMap.keySet();
        for (String k: inputKey) {
            if (k == 'UnreserveNumbers') {
                String configId = (String) inputMap.get('UnreserveNumbers');
                System.debug('UnreserveNumbers for ConfigId:  ' + configId);
                String res = unreserveNumbers(configId);
                returnMap.put('UnreserveNumbers', res);
            } else if (k == 'GetReservedNumbers') {
                String configId = (String) inputMap.get('GetReservedNumbers');
                System.debug('GetReservedNumbers for ConfigId:  ' + configId);
                String res = getReservedNumbers(configId);
                returnMap.put('GetReservedNumbers', res);
            } else if (k == 'DetachAccountFromSite') {
                String adborId = (String) inputMap.get('DetachAccountFromSite');
                System.debug('DetachAccountFromSite for adborId:  ' + adborId);
                String res = detachAccountFromSite(adborId);
                returnMap.put('DetachAccountFromSite', res);
            } else if (k == 'GetBasket') {
                String basketId = (String) inputMap.get('GetBasket');
                System.debug('GetBasket for basketId:  ' + basketId);
                String res = GetBasket(basketId);
                returnMap.put('GetBasket', res);
                if (res != null && res != '') {
                    returnMap.put('Prgs', JSON.serialize(pricingRuleGroupList));
                }
            }
            // 08-05-19, LT, Added to get PC data
            else if (k == 'GetPCData') {
                String pcId = (String) inputMap.get('GetPCData');
                System.debug('GetPCData for pcId:  ' + pcId);
                String res = getPCData(pcId);
                returnMap.put('GetPCData', res);
            } else if (k == 'GetSiteId') {
                String pcId = (String) inputMap.get('GetSiteId');
                System.debug('GetSiteId');
                String res = GetSiteId();
                returnMap.put('GetSiteId', res);
            } else if (k == 'GetServiceStartDate') {
                String pcId = (String) inputMap.get('GetServiceStartDate');
                System.debug('GetServiceStartDate for configuration: ' + pcId);
                String res = GetServiceStartDate(pcId);
                returnMap.put('GetServiceStartDate', res);
            }
            //P2OB-11382 <Solution Console> Retrieval of Opportunity details in Solution
            else if (k == 'GetOppty') {
                String opptyId = (String) inputMap.get('GetOppty');
                System.debug('GetOppty for configuration: ' + opptyId);
                String res = GetOppty(opptyId);
                returnMap.put('GetOppty', res);
            }
            //P2OB-12186 <Solution Console> New Business Rule for Opportunities having Partner Account
            else if (k == 'GetPartnerAccount') {
                String opptyId = (String) inputMap.get('GetPartnerAccount');
                System.debug('GetPartnerAccount for configuration: ' + opptyId);
                String res = GetPartnerAccount(opptyId);
                returnMap.put('GetPartnerAccount', res);
            } else if (k == 'GetMobileUnitPrice') {
                String messageBank = (String) inputMap.get('GetMobileUnitPrice');
                System.debug('GetMobileUnitPrice: ' + messageBank);
                String res = GetMobileUnitPrice(messageBank);
                returnMap.put('GetMobileUnitPrice', res);
            } else if (k == 'GetSubscriptionForConfiguration') {
                String configIds = (String) inputMap.get('GetSubscriptionForConfiguration');
                System.debug('GetSubscriptionForConfiguration: ' + configIds);
                String res = GetSubscriptionForConfiguration(configIds);
                returnMap.put('GetSubscriptionForConfiguration', res);
            }
            // Start EDGE-132276 Device status update on Device for Macd
            else if (k == 'GetServiceForConfiguration') {
                String configIds = (String) inputMap.get('GetServiceForConfiguration');
                System.debug('GetServiceForConfiguration: ' + configIds);
                String res = GetServiceForConfiguration(configIds);
                returnMap.put('GetServiceForConfiguration', res);
            }
            // Added as part of EDGE-148733 by ankit||strat
            else if (k == 'GetAssetForConfiguration') {
                String configIds = (String) inputMap.get('GetAssetForConfiguration');
                System.debug('GetAssetForConfiguration: ' + configIds);
                String res = GetAssetForConfiguration(configIds);
                returnMap.put('GetAssetForConfiguration', res);
            }
            // Added as part of EDGE-148733 by ankit||End
            //End EDGE-132276
            // Added as part of DPG-5626 by Monali||start
            else if (k == 'GetPurchaseOrderNoForConfiguration') {
                String configIds = (String) inputMap.get('GetPurchaseOrderNoForConfiguration');
                System.debug('GetPurchaseOrderNoForConfiguration: ' + configIds);
                String res = GetPurchaseOrderNoForConfiguration(configIds);
                returnMap.put('GetPurchaseOrderNoForConfiguration', res);
            }
            // Added as part of DPG-5626 by Monali||End
            //Start of EDGE - 93425: Adding key to getServiceForMAC method.
            else if (k == 'getServiceForMAC') {
                String replacedConfigId = (String) inputMap.get('getServiceForMAC');
                System.debug('replacedConfigId: ' + replacedConfigId);
                String res = getServiceForMAC(replacedConfigId);
                returnMap.put('getServiceForMAC', res);
            }
            //End of Edge: 93425
            //Modified by Venkat for US# -92244
            else if (k == 'getExistingTenancySubscriptions') {
                String accountId = (string) inputMap.get('getExistingTenancySubscriptions');
                System.debug('getExistingTenancySubscriptions: ' + accountId);
                String res = getExistingTenancySubscriptions(accountId);
                returnMap.put('getExistingTenancySubscriptions', res);
            }
            //Modified by Monali for DPG -2168
            else if (k == 'getExistingTenancySubscriptionsForBilling') {
                //String accountId = (string)inputMap.get('getExistingTenancySubscriptionsForBilling');
                String billingId = (string) inputMap.get('getExistingTenancySubscriptionsForBilling');
                System.debug('getExistingTenancySubscriptionsForBilling: ' + billingId);
                String res = getExistingTenancySubscriptionsForBilling(billingId);
                returnMap.put('getExistingTenancySubscriptionsForBilling', res);
            } else if (k == 'GetSmOptions') {
                System.debug('GetSmOptions');
                String res = GetSmOptions();
                returnMap.put('GetSmOptions', res);
            } else if (k == 'CalculateEtc') { //EDGE : 81135: Calculate ETC for CMP
                System.debug('Calculate ETC');
                Map < String, String > results = getETCChargesForCMPDevice(inputMap);
                returnMap.put('CalculateEtc', results.get('ETCcharges'));
                returnMap.put('RemainingTerm', results.get('RemainingTerm'));
            } else if (k == 'getETCChargesForNGUC') { //EDGE : 81135: Calculate ETC for CMP
                System.debug('getETCChargesForNGUC ETC');
                Map < String, String > results = getETCChargesForNGUC(inputMap);
                returnMap.put('getETCChargesForNGUC', results.get('ETCcharges'));
                returnMap.put('RemainingTerm', results.get('RemainingTerm'));
                //returnMap.put('getETCChargesForNGUC', ETCCharges);
            } else if (k == 'getETCChargesForAM') { // EDGE-188712 added new ETC charge method for AM
                System.debug('getETCChargesForAM ETC');
                Map < String, String > results = getETCChargesForAM(inputMap);
                returnMap.put('getETCChargesForAM', results.get('ETCcharges'));
                returnMap.put('RemainingTerm', results.get('RemainingTerm'));
            } else if (k == 'getETCChargesForTID') { //EDGE : 111053: Calculate ETC for TID
                System.debug('getETCChargesForTID ETC');
                Map < String, String > results = getETCChargesForTID(inputMap);
                returnMap.put('getETCChargesForTID', results.get('ETCcharges'));
                returnMap.put('RemainingTerm', results.get('RemainingTerm'));
            } else if (k == 'configIdList') { //EDGE : 111053: Calculate ETC for TID
                System.debug('configIdList ETC'); // DIGI-10993 uncommented from 209 to 212
                String configIdListStr = (String) inputMap.get('configIdList');
                configIdList = configIdListStr.split(',');
                System.debug('configIdList 1' + configIdListStr);
                System.debug('configIdList 2' + configIdList);
                //String configIdListStr = (String)inputMap.get('configIdList');
                //System.debug(inputMap.get(k));
                // List<String> guidList=(String)inputMap.get('configIdList');
                // configIdList.add(configIdListStr );
                //System.debug('configIdList ETC'+configIdList);
            } else if (k == 'CorrelationId') { //EDGE : 111053: Calculate ETC for TID
                System.debug('CorrelationId');
                //String configId = (String)inputMap.get('UnreserveNumbers');
                CorrelationId = (String) inputMap.get('CorrelationId');
                System.debug('CorrelationId' + CorrelationId);
            }
            //Start DPG-1878
            else if (k == 'billingDetails') { //DPG
                System.debug('billingDetails');
                String AccountId = (String) inputMap.get('AccountId');
                String billingDetails = (String) inputMap.get('billingDetails');
                String guid = (String) inputMap.get('guid');
                String billingCheck = GetBillingCheckInfo(AccountId, billingDetails, guid);
                returnMap.put('billingDetails', billingCheck);
            }
            //End DPG-1878
            //Start DPG-2577 
            else if (k == 'tenancyId') { //DPG
                System.debug('tenancyId');
                //String AccountId = (String)inputMap.get('AccountId');
                String TenancyId = (String) inputMap.get('tenancyId');
                String mngdServSubsCheck = getActiveManagedServiceSubscriptionCheckInfo(TenancyId);
                returnMap.put('tenancyId', mngdServSubsCheck);
            }
            //End DPG-2577
            //AB: post upgrade changes start
            else if (k == 'updateSolutionTotals') {
                //High volume optimisation is to no longer maintain total fields on solution on every PC change.
                //This logic is now executed only once in afterSave hook
                String solutionId = (String) inputMap.get(k);
                updateSolutionTotals(solutionId);
            }
            //AB: post upgrade changes end
            //Gnana: CS Spring'20 Upgrade Start
            else if (k == 'updateBasketOppySynFlag') {
                String basketId = (String) inputMap.get(k);
                String res = updateBasketOppySynFlag(basketId);
                returnMap.put('updateBasketOppySynFlagResult', res);
            }
            //Gnana: CS Spring'20 Upgrade End
            //Aditya: CS Spring'20 Upgrade Start
            else if (k == 'updateBasketStageToDraft') {
                String basketId = (String) inputMap.get(k);
                String res = updateBasketStageToDraft(basketId);
                returnMap.put('updateBasketStageToDraftResult', res);
            }
            //Aditya: CS Spring'20 Upgrade End
            //Pooja: CS Spring'20 upgrade start, To update Basket Stage = Commerical Configuration and set the Basket's Opportunity Synchronised Flag to False
            else if (k == 'updateBasketDetails') {
                String basketId = (String) inputMap.get(k);
                String res = updateBasketDetails(basketId);
                returnMap.put('updateBasketDetailsResult', res);
                system.debug('a' + res);
            }

            //EDGE-216217
            else if (k == 'invalidateOnBasketRedemptions') {
                String basketId = (String) inputMap.get(k);
                String res = invalidateOnBasketRedemptions(basketId);
                returnMap.put('invalidateOnBasketRedemptionsResult', res);
                system.debug('invalidateOnBasketRedemptions' + res);
            } else if (k == 'markBasketAsInvalid') {
                String basketId = (String) inputMap.get(k);
                String res = markBasketAsInvalid(basketId);
                returnMap.put('markBasketAsInvalidResult', res);
                system.debug('markBasketAsInvalid' + res);
            }

            //Pooja: CS Spring'20 upgrade end
            //AB: OE attachment loading helper - EDGE-167811 - Spring20 Upgrade
            else if (k == 'GetOeAttachment') {
                String configurationId = (String) inputMap.get(k);
                String fileName = '%' + (String) inputMap.get('AttachmentName') + '%';
                String attachmentBody = getOeAttachment(fileName, configurationId);
                returnMap.put('GetOeAttachment', attachmentBody);
            }
            /*else if(k == 'GetConfigurationId'){
                      // to be excluded in future when atch will fix this issue //added for replace config id at child level //Edge-EDGE-169593
              //added by shubhi for replaceconfig id
              //Map<String, Object> returnMap = new Map<String, Object>();
              String basketId = (String)inputMap.get('basketId');   
              String guid= (String)inputMap.get('GetConfigurationId');
              cscfga__Product_Configuration__c pc=[Select id,configGUID__c,csordtelcoa__Replaced_Product_Configuration__c from cscfga__Product_Configuration__c where configGUID__c =:guid and cscfga__Product_Basket__c =:basketId limit 1];
                      if(pc!=null && pc.csordtelcoa__Replaced_Product_Configuration__c!=null){
                returnMap.put('childGuid',pc.configGUID__c);
                          returnMap.put('childId',pc.id);
                          returnMap.put('replacedConfigid',pc.csordtelcoa__Replaced_Product_Configuration__c);
              }        
              return returnMap;
            }*/
            //Added by Sandhya EDGE-172941 INC000093743308 Fix Start
            else if (k == 'getPCId') {
                String pcIdListStr = (String) inputMap.get('getPCId');
                Set < String > pcIds = new Set < String > (pcIdListStr.Split(','));
                List < Number__c > numberList = [Select id, Product_Configuration__c, Service_Number__c from Number__c where Product_Configuration__c IN: pcIds];
                for (Number__c num: numberList) {
                    returnMapOE.put(num.Product_Configuration__c, num.Service_Number__c);
                }
                return returnMapOE;
            } //EDGE-172941 INC000093743308 Fix End 
            else if (k == 'GetConfigurationId') {
                //EDGE-221460 mode the below code to this method and commeted the below code.    
                return getReplacedConfigId(inputMap, returnMap);
            } else if (k == 'getChildServicesForDeviceCare') { //EDGE-168275,EDGE-164350
                String replacedConfigId = (String) inputMap.get('getChildServicesForDeviceCare');
                System.debug('replacedConfigId: ' + replacedConfigId);
                csord__Service__c res = getChildServicesForDeviceCare(replacedConfigId);
                returnMap.put('getChildServicesForDeviceCare', res);
            } else if (k == 'updateISPOSReversalRequired') { //EDGE-164351
                String basketId = (String) inputMap.get('updateISPOSReversalRequired');
                updateISPOSReversalRequired(basketId);
                //Added by Manuga EDGE-165017 start
            } else if (k == 'getLoginUserProfileName') {
                profile res = getLoginUserProfileName();
                returnMap.put('getLoginUserProfileName', res);
                system.debug('@@@Mao' + returnMap);
            }
            //Added by Manuga EDGE-165017 END
            else if (k == 'getCommercialProductId') { //DPG-2319
                String resultKey = (String) inputMap.get('getCommercialProductId');
                if (String.isNotBlank(resultKey)) {
                    String[] commercialProductKeys;
                    commercialProductKeys = resultKey.split(',');
                    if (commercialProductKeys.size() == 3) {
                        String res = getCommercialProductId(commercialProductKeys[0], commercialProductKeys[1], commercialProductKeys[2]);
                        returnMap.put('getCommercialProductId', res);
                    }
                } else {
                    returnMap.put('getCommercialProductId', null);
                }
            } else if (k == 'allowHardStop') {
                String AllowHardStop = EnvironmentVariable__c.getValues('AllowHardStop').Value__c;
                returnMap.put('AllowHardStop', AllowHardStop);
            } else if (k == 'transitionDeviceCancel') {
                String configurationId = (String) inputMap.get('ConfigId');
                String billingaccountnumber = (String) inputMap.get('billingAccNum');
                system.debug('configurationId--->' + configurationId + billingaccountnumber);
                String resultres = transitionDeviceCancel(billingaccountnumber, configurationId);
                returnMap.put('transitionDeviceCancel', resultres);

            }
            //Added by Shishir Pareek as part of P2OB-13129
            else if (k == 'updateBAUSolutionTotals') {
                //High volume optimisation is to no longer maintain total fields on solution on every PC change.
                //This logic is now executed only once in afterSave hook
                String solutionId = (String) inputMap.get(k);
                updateBAUSolutionTotals(solutionId);
            } else if (k == 'updateBASolutionTotals') {
                //High volume optimisation is to no longer maintain total fields on solution on every PC change.
                //This logic is now executed only once in afterSave hook
                System.debug('updateBASolutionTotals');
                String res = 'Remote Action Test';
                returnMap.put('updateBASolutionTotals', res);
            }
            //Added By Vasu for toggling order Enrichment|| start
            /* DN: commented out
             * else if (k == 'checkOrderEnrichmentConsole') {
                System.debug('checkOrderEnrichmentConsole');
                string res = label.useNewEnrichmentVersion;
                returnMap.put('checkOrderEnrichmentConsole', res);
            } //Added By Vasu for toggling order Enrichment|| end
            */
            //DN: alternative Order Enrichment dormancy approach using FeatureToggle framework
            else if (k == 'OrderEnrichment') { //DN: Order Enrichment for AM
                String enrichDetails = (String) inputMap.get('OrderEnrichment');
                Boolean res = (FeatureEligibilityChecker.determineFeatureEligiblity('OrderEnrichment', enrichDetails));
                returnMap.put(enrichDetails, res);
            }
             else if (k == 'oeError') { 
                 //list<id> configId = (list<id>) inputMap.get('oeAMPCids');
                set<id> res = orderEnrichmentUtill.getErrorDetails((string)inputMap.get('oeError') );
                returnMap.put(k, res);
              }
             else if (k == 'OrderReplacedId') { 
               Map<string,string>UpdatedinputMap =new Map<string,string>();
               string orderString=((string) inputMap.get('OrderReplacedId'));
               UpdatedinputMap.put((orderString.length() >15? orderString.substring(0,15):orderString),(string) inputMap.get('pcid'));
                string res = orderEnrichmentUtill.cloneOrderEnrichmentRecords(UpdatedinputMap);
                returnMap.put(k, res);
              }
              //DN order enrichment End 
            //Added by Aman Soni as a part of EDGE-123575 || Start
            if (CorrelationId != '' && !configIdList.isEmpty()) {
                Map < String, Map < String, String >> tcvMap = GetPriceSchedulevirtualClass.fetchTCV(configIdList, CorrelationId); //EDGE-133963 by shubhi
                if (!tcvMap.isEmpty()) {
                    returnMap.put('TCVMap', tcvMap);
                }
            }
            //Added by Aman Soni as a part of EDGE-123575 || end
        }
        System.debug('returnMap: ' + returnMap);
        return returnMap;
    }
    // 08-05-19, LT, Added to get PC data
    global static string getPCData(string configId) {
        if (configId == null || configId.length() == 0)
            return '';
        try {
            cscfga__Product_Configuration__c pc = [select Incremental_Revenue__c
                from cscfga__Product_Configuration__c
                where id =: configId
                LIMIT 1
            ];
            if (pc != null) {
                return JSON.serialize(pc);
            }
        } catch (Exception e) {
            System.debug('getPCData: ' + e.getMessage());
        }
        return '';
    }
    global static string unreserveNumbers(string rootConfigId) {
        NumberNCSHelper ncs = new NumberNCSHelper();
        boolean isFNNReserved = ncs.checkForExistingNCS(rootConfigId);
        System.debug('Reserve Status: ' + isFNNReserved);
        if (isFNNReserved == true) {
            Map < String, List < String >> reservedNumbersMap = ncs.getNumbersFromNCS(rootConfigId);
            List < String > reservedNumbersList = reservedNumbersMap.get('RESERVED');
            if (reservedNumbersList != null && reservedNumbersList.size() > 0) {
                FNNDTO dto = new FNNDTO();
                FNNResponseDTO fnnRes = new FNNResponseDTO();
                FNNDTO.FNNDataObject fdo = new FNNDTO.FNNDataObject();
                fdo.serviceIds = reservedNumbersList;
                fdo.systemId = 'MSPA';
                dto.data = fdo;
                FNNService fnnSer = new FNNService();
                fnnRes = fnnSer.unReserveFNN(dto);
                System.debug('Response ' + fnnRes);
                if (fnnRes != NULL && String.Valueof(fnnRes.status).startsWith('2')) {
                    String respMsg = ncs.deleteExistingNCS(rootConfigId, reservedNumbersList);
                    if (respMsg == 'Success') {
                        return String.join(reservedNumbersList, ',');
                    } else {
                        return respMsg;
                    }
                } else {
                    return 'fnnSer.unReserveFNN - FAILED';
                }
            }
        }
        return 'No action performed';
    }
    global static string getReservedNumbers(string rootConfigId) {
        NumberNCSHelper ncs = new NumberNCSHelper();
        boolean isFNNReserved = ncs.checkForExistingNCS(rootConfigId);
        System.debug('Reserve Status: ' + isFNNReserved);
        List < NumberNCSDTO.Configuration > numberList = new List < NumberNCSDTO.Configuration > ();
        if (isFNNReserved == true) {
            Map < String, List < String >> reservedNumbersMap = ncs.getNumbersFromNCS(rootConfigId);
            List < String > reservedNumbersList = reservedNumbersMap.get('RESERVED');
            if (reservedNumbersList != null && reservedNumbersList.size() > 0) {
                NumberNCSDTO.Configuration numConfig = NULL;
                for (String fnn: reservedNumbersList) {
                    numConfig = new NumberNCSDTO.Configuration();
                    numConfig.FNN = fnn;
                    numConfig.listCode = 'No Entry Line';
                    numConfig.status = 'RESERVED';
                    numberList.add(numConfig);
                }
            }
        }
        return JSON.serialize(numberList);
    }
    global static string detachAccountFromSite(String adborId) {
        if (adborId == null || adborId.length() == 0)
            return 'No action performed';
        try {
            cscrm__Site__c site = [select id
                from cscrm__Site__c
                where AdborId__c =: adborId AND Legacy__c =: true
            ];
            if (site != null) {
                delete site;
            }
        } catch (Exception e) {
            return 'Failed: ' + e.getMessage();
        }
        return 'Success';
    }
    global static string GetBasket(String basketId) {
        if (basketId == null || basketId.length() == 0)
            return '';
        try {
            //moved soql to model class EDGE-170016 
            cscfga__Product_Basket__c basket = Model_ProductBasket.getProductBasketonLoadSolution(basketId);
            if (basket != null) {
                // Add the Pricing Rule Group Code from Frame Agreements related list
                if (basket.csconta__Frame_Agreement__c != null) {
                    for (cspmb__Pricing_Rule_Group__c prg: [SELECT Id, cspmb__pricing_rule_group_code__c FROM cspmb__Pricing_Rule_Group__c where csconta__frame_agreement__c =: basket.csconta__Frame_Agreement__c]) {
                        pricingRuleGroupList.add(prg.cspmb__pricing_rule_group_code__c); //Adding the PRGC to the List   
                    }
                }
                return JSON.serialize(basket);
            }
        } catch (Exception e) {
            System.debug('GetBasketChangeType: ' + e.getMessage());
        }
        return '';
    }
    //P2OB-11382 <Solution Console> Retrieval of Opportunity details in Solution
    //P2OB-11727 <Solution Console> - Retrieval of Opportunity Stage details in Solution
    global static string GetOppty(String opportunityId) {
        if (opportunityId == null || opportunityId.length() == 0)
            return '';
        try {
            //P2OB-13156 Added CreatedBy.Name and Account.Id for P2OB-13156 changes
            //To retrieve SRV List // added To retrieve PartnerAccount.id & PartnerAccount.Name related to P2OB-12186                  
            Opportunity opportunity = [SELECT Name, PartnerAccount.id, PartnerAccount.Name, Price_List__c, Type, StageName, CreatedBy.Name, Account.Id
                FROM Opportunity WHERE Id =: opportunityId LIMIT 1
            ];
            GetPartnerAccount(opportunity.PartnerAccount.id);
            if (opportunity != null) {
                return JSON.serialize(opportunity);
            }
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        }
        return '';
    }
    //P2OB-12186 <Solution Console> New Business Rule for Opportunities having Partner Account
    global static string GetPartnerAccount(String partnerAccountId) {
        if (partnerAccountId == null || partnerAccountId.length() == 0)
            return '';
        try {
            //To retrieve Partner Account Details related to P2OB-12186                
            Account partnerAccount = [SELECT id, Name FROM Account WHERE Id =: partnerAccountId LIMIT 1];
            system.debug('partnerAccount>>>>>' + partnerAccount);
            if (partnerAccount != null) {
                return JSON.serialize(partnerAccount);
            }
        } catch (Exception e) {
            System.debug('Error message: ' + e.getMessage());
        }
        return '';
    }
    global static string GetSiteId() {
        return Site.getSiteId();
    }
    global static string GetServiceStartDate(String configId) {
        try {
            csord__Service__c service = [select Initial_Activation_Date__c
                from csord__Service__c
                where csordtelcoa__Product_Configuration__c =: configId
                LIMIT 1
            ];
            if (service != null) {
                return JSON.serialize(service.Initial_Activation_Date__c);
            }
        } catch (Exception e) {
            System.debug('GetServiceStartDate: ' + e.getMessage());
        }
        return '';
    }
    /*------------------------------------------------------------
    EDGE-93425
    Method: getServiceForMAC
    Description: Fetch the service start date of the replaced configuration.
    Inputs: ConfigId
    Returns:  String
    History
    <05-08-2019> <Sasidhar Devarapalli>
    ------------------------------------------------------------*/
    //Start of DIGI-15303: Replacing method: getServiceForMAC to process replaceConfigId
    /*global static string getServiceForMAC(String configId){
        try{
            cscfga__Product_Configuration__c replacedConfig = [select csordtelcoa__Replaced_Product_Configuration__c
                                                               from cscfga__Product_Configuration__c
                                                               where id = :configId
                                                               LIMIT 1];
            if (replacedConfig != null){
                String serviceActivationDate = GetServiceStartDate(String.valueOf(replacedConfig.csordtelcoa__Replaced_Product_Configuration__c));
                return JSON.serialize(serviceActivationDate);
            }
        } catch (Exception e){
            System.debug('getServiceForMAC: ' + e.getMessage());
        }
        return '';
    }*/
    global static string getServiceForMAC(String replaceConfigId) {
        try {
            if (replaceConfigId != null) {
                String serviceActivationDate = GetServiceStartDate(String.valueOf(replaceConfigId));
                return JSON.serialize(serviceActivationDate);
            }
        } catch (Exception e) {
            System.debug('getServiceForMAC: ' + e.getMessage());
        }
        return '';
    } // End of DIGI-15303
    global static string GetMobileUnitPrice(String messageBank) {
        try {
            system.debug('messageBank:' + messageBank);
            cspmb__Add_On_Price_Item__c priceItem = [select id, cspmb__Recurring_Charge__c
                from cspmb__Add_On_Price_Item__c
                where cspmb__Add_On_Price_Item_Code__c = 'Mobile Access'
                and Message_Bank__c =: messageBank
                LIMIT 1
            ];
            system.debug('priceItem:' + priceItem);
            if (priceItem != null) {
                return JSON.serialize(priceItem.cspmb__Recurring_Charge__c);
            }
        } catch (Exception e) {
            System.debug('GetMobileUnitPrice: ' + e.getMessage());
        }
        return '';
    }
    global static string GetSubscriptionForConfiguration(String configIdsStr) {
        try {
            string[] configIds;
            configIds = configIdsStr.Split(',');
            List < csord__Subscription__c > subscriptions = [select id, csordtelcoa__Product_Configuration__c, serviceMSISDN__c, Name, csord__Status__c, initialActivationDate__c, Billing_Account__c, Billing_Account__r.Billing_Account_Number__c
                from csord__Subscription__c
                where csordtelcoa__Product_Configuration__c in: configIds
            ]; /*EDGE-138169 || Added by Aman Soni||initialActivationDate__c, EDGE-135278 || Added by Aman Soni||Billing_Account__r.Billing_Account_Number__c, EDGE-117256 /// added Billing_Account__c by shubhi EDGE-142085*/
            system.debug('subscriptions:' + subscriptions);
            if (subscriptions != null && subscriptions.size() > 0) {
                return JSON.serialize(subscriptions);
            }
        } catch (Exception e) {
            System.debug('GetSubscriptionForConfiguration: ' + e.getMessage());
        }
        return '';
    }
    // Start EDGE-132276 Device status update on Device for Macd
    global static string GetServiceForConfiguration(String configIdsStr) {
        try {
            string[] configIds;
            configIds = configIdsStr.Split(',');
            List < csord__Service__c > serviceList = [select id, csord__Status__c, Initial_Activation_Date__c, csordtelcoa__Product_Configuration__c
                from csord__Service__c
                where csordtelcoa__Product_Configuration__c in: configIds
            ]; // Added Initial_Activation_Date__c as part of EDGE-123594
            system.debug('serviceList:' + serviceList);
            if (serviceList != null && serviceList.size() > 0) {
                return JSON.serialize(serviceList);
            }
        } catch (Exception e) {
            System.debug('GetServiceForConfiguration: ' + e.getMessage());
        }
        return '';
    }
    //End
    //Venkat - WIP
    global static string getExistingTenancySubscriptions(String accountId) {
        Map < String, string > ret = new Map < String, string > ();
        List < csord__Subscription__c > subslst = [SELECT id, Name, csord__Account__c, TenancyID__c
            FROM csord__Subscription__c
            where csord__Account__c =: accountId and csord__Status__c = 'Active'
            and ConfigSpecID__c = 'DMCAT_ProductSpecification_000537'
        ];
        for (csord__Subscription__c sub: subslst) {
            if (ret.containskey(sub.csord__Account__c)) {
                String s = ret.get(sub.csord__Account__c);
                s += ',' + sub.TenancyID__c;
                ret.put(sub.csord__Account__c, s);
            } else {
                ret.put(sub.csord__Account__c, sub.TenancyID__c);
            }
        }
        if (!ret.isEmpty())
            return JSON.serialize(ret.get(accountId));
        else
            return null;
    }
    //Monali DPG-2168
    global static string getExistingTenancySubscriptionsForBilling(String billingId) {
        Map < String, string > ret = new Map < String, string > ();
        List < csord__Subscription__c > subslst = [SELECT id, Name, csord__Account__c, TenancyID__c, Billing_Account__c
            FROM csord__Subscription__c
            where Billing_Account__c =: billingId and csord__Status__c = 'Active'
            and ConfigSpecID__c = 'DMCAT_ProductSpecification_000537'
        ];
        for (csord__Subscription__c sub: subslst) {
            if (ret.containskey(sub.Billing_Account__c)) {
                String s = ret.get(sub.Billing_Account__c);
                s += ',' + sub.TenancyID__c;
                ret.put(sub.Billing_Account__c, s);
            } else {
                ret.put(sub.Billing_Account__c, sub.TenancyID__c);
            }
        }
        if (!ret.isEmpty())
            //return JSON.serialize(ret.get(accountId));
            return JSON.serialize(ret.get(billingId));
        else
            return null;
    }
    global static string GetSmOptions() {
        try {
            cssmgnt__SM_Options__c smOptions = cssmgnt__SM_Options__c.getInstance();
            if (smOptions != null) {
                return JSON.serialize(smOptions);
            }
        } catch (Exception e) {
            System.debug('GetSmOptions: ' + e.getMessage());
        }
        return '';
    }
    /*
     * JIRA - EDGE - 81135
     * Desc - Method to be called from JavaScript for calculating the ETC charges for CMP offer
     */
    @AuraEnabled
    global static Map < String, String > getETCChargesForCMPDevice(Map < String, Object > inputMap) {
        Map < String, Object > returnMap = new Map < String, Object > ();
        String prodConfigId = (String) inputMap.get('ProdConfigId');
        Date disconnectionDate = Date.valueOf((String) inputMap.get('DisconnectionDate'));
        Integer term = Integer.valueOf(inputMap.get('etc_Term'));
        Decimal unitPrice = 0.0;
        Date initialActivationDate = null;
        Map < String, String > results;
        Id deviceConfigId = (String) inputMap.get('deviceConfigID');
        Id macdeviceConfigID = (String) inputMap.get('macdeviceConfigID');
        List < cscfga__Product_Configuration__c > deviceConfig = [SELECT Id, Name, csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c, (
                SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where /*cscfga__Is_Line_Item__c = true*/ Name = 'InstalmentCharge'
                and cscfga__Recurring__c = true)
            FROM cscfga__Product_Configuration__c
            WHERE Id =: deviceConfigId or Id =: macdeviceConfigId
        ]; //EDGE-184443 Remove Islineitem check and added Name condition
        for (cscfga__Product_Configuration__c device: deviceConfig) {
            System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:device:' + device);
            if (device.id == macdeviceConfigID)
                initialActivationDate = device.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c;
            if (device.id == deviceConfigId) {
                if (device.cscfga__Attributes__r.size() > 0) {
                    unitPrice = Decimal.valueOf(device.cscfga__Attributes__r[0].cscfga__Value__c);
                    System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:AttributeRecurringCharges:' + device.cscfga__Attributes__r[0]);
                }
            }
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:deviceConfigId=' + deviceConfigId + ',prodConfigId=' + prodConfigId + ', disconnectionDate=' + disconnectionDate + ', term=' + term + ', unitPrice=' + unitPrice);
        List < Object > attributesData = new List < Object > ();
        String etcCharge;
        if (String.isNotEmpty(prodConfigId) && disconnectionDate != NULL) {
            System.debug('Inside main if');
            List < cscfga__Product_Configuration__c > configs = [SELECT Id, Name, csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c, csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c
                FROM cscfga__Product_Configuration__c
                WHERE Id =: prodConfigId
                LIMIT 1
            ];
            if (configs.size() > 0) {
                //Date initialActivationDate = configs[0].csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c;
                String billingAccNumber = configs[0].csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c;
                System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:' + billingAccNumber + ':' + initialActivationDate);
                results = EarlyCancellationCalcService.CancelChargesCalc(0, initialActivationDate, disconnectionDate, Term, unitPrice, true, billingAccNumber);
            }
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForCMPDevice:etcCharge=' + results);
        return results;
    }
    @AuraEnabled
    global static Map < String, String > getETCChargesForNGUC(Map < String, Object > inputMap) {
        Map < String, Object > returnMap = new Map < String, Object > ();
        String prodConfigId = (String) inputMap.get('ProdConfigId');
        System.debug('prodConfigId' + prodConfigId);
        Date disconnectionDate = Date.valueOf((String) inputMap.get('DisconnectionDate'));
        Integer term = Integer.valueOf(inputMap.get('etc_Term'));
        Decimal unitPrice = 0.0;
        Date initialActivationDate = null;
        String billingAccNumber;
        Map < String, String > results;
        List < csord__Service__c > services = [SELECT Id, Initial_Activation_Date__c
            FROM csord__Service__c
            WHERE csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (services != null && services.size() > 0) {
            initialActivationDate = services[0].Initial_Activation_Date__c;
        }
        //EDGE-186945 - Added field to the query cscfga__Price__c
        List < cscfga__Attribute__c > attributes = [SELECT Id, cscfga__Price__c, cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Recurring__c, cscfga__Product_Configuration__c
            FROM cscfga__Attribute__c
            WHERE cscfga__Product_Configuration__c =: prodConfigId AND cscfga__Is_Line_Item__c = true AND cscfga__Recurring__c = true
        ];
        if (attributes.size() > 0) {
            //EDGE-186945 - Changed field from Value to Price
            //unitPrice = Decimal.valueOf(attributes[0].cscfga__Value__c);
            unitPrice = attributes[0].cscfga__Price__c;
            System.debug('***Telstra:SolutionActionHelper:getETCChargesForNGUC:AttributeRecurringCharges:' + attributes[0]);
        }
        List < csord__Subscription__c > subsRecord = [SELECT Id, Billing_Account__r.Billing_Account_Number__c
            from csord__Subscription__c
            where csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (subsRecord != null && subsRecord.size() > 0) {
            billingAccNumber = subsRecord[0].Billing_Account__r.Billing_Account_Number__c;
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForNGUC:prodConfigId=' + prodConfigId + ', initialActivationDate= ' + initialActivationDate + ', disconnectionDate=' + disconnectionDate + ', term=' + term + ', unitPrice=' + unitPrice + ', billingAccNumber=' + billingAccNumber);
        List < Object > attributesData = new List < Object > ();
        String etcCharge;
        if (String.isNotEmpty(prodConfigId) && disconnectionDate != NULL && billingAccNumber != NULL) {
            results = EarlyCancellationCalcService.CancelChargesCalc(0, initialActivationDate, disconnectionDate, term, unitPrice, true, billingAccNumber);
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForNGUC:etcCharge=' + results);
        return results;
    }
    //EDGE-188712 added new ETC charge method for AM
    @AuraEnabled
    global static Map < String, String > getETCChargesForAM(Map < String, Object > inputMap) {
        Map < String, Object > returnMap = new Map < String, Object > ();
        system.debug('inputMap ' + inputMap);
        String prodConfigId = (String) inputMap.get('ProdConfigId');
        System.debug('prodConfigId' + prodConfigId);
        Date disconnectionDate = Date.valueOf((String) inputMap.get('DisconnectionDate'));
        Integer term = Integer.valueOf(inputMap.get('etc_Term'));
        Decimal unitPrice = 0.0;
        Date initialActivationDate = null;
        String billingAccNumber;
        Map < String, String > results;
        List < csord__Service__c > services = [SELECT Id, Initial_Activation_Date__c
            FROM csord__Service__c
            WHERE csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (services != null && services.size() > 0) {
            initialActivationDate = services[0].Initial_Activation_Date__c;
        }
        List < cscfga__Attribute__c > attributes = [SELECT Id, cscfga__Price__c, cscfga__Value__c, cscfga__Recurring__c, cscfga__Product_Configuration__c
            FROM cscfga__Attribute__c
            WHERE cscfga__Product_Configuration__c =: prodConfigId AND cscfga__Attribute_Definition__r.Name = 'RC'
            and cscfga__Recurring__c = true
        ];
        if (attributes.size() > 0) {
            unitPrice = Decimal.valueOf(attributes[0].cscfga__Value__c);
            System.debug('***Telstra:SolutionActionHelper:getETCChargesForAM:AttributeRecurringCharges:' + attributes[0]);
        }
        List < csord__Subscription__c > subsRecord = [SELECT Id, Billing_Account__r.Billing_Account_Number__c
            from csord__Subscription__c
            where csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (subsRecord != null && subsRecord.size() > 0) {
            billingAccNumber = subsRecord[0].Billing_Account__r.Billing_Account_Number__c;
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForNGUC:prodConfigId=' + prodConfigId + ', initialActivationDate= ' + initialActivationDate + ', disconnectionDate=' + disconnectionDate + ', term=' + term + ', unitPrice=' + unitPrice + ', billingAccNumber=' + billingAccNumber);
        List < Object > attributesData = new List < Object > ();
        String etcCharge;
        if (String.isNotEmpty(prodConfigId) && disconnectionDate != NULL && billingAccNumber != NULL) {
            results = EarlyCancellationCalcService.CancelChargesCalc(0, initialActivationDate, disconnectionDate, term, unitPrice, true, billingAccNumber);
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForNGUC:etcCharge=' + results);
        return results;
    }
    /*------------------------------------------------------------
    EDGE-148733
    Method: GetAssetForConfiguration
    Description: Fetch Device ID from Asset
    Inputs: inputMap
    Devlop: Ankit Goswami
    ------------------------------------------------------------*/
    global static string GetAssetForConfiguration(String configIdsStr) {
        try {
            Set < String > configIds = new set < String > (configIdsStr.Split(','));
            list < Asset > AssetList = new list < Asset > ();
            if (configIds != null && configIds.size() > 0) {
                AssetList = Model_AssetObj.getAssetId(configIds);
            }
            if (AssetList != null && AssetList.size() > 0) {
                return JSON.serialize(AssetList);
            }
        } catch (Exception e) {
            System.debug('GetServiceForConfiguration: ' + e.getMessage());
        }
        return '';
    }
    /*------------------------------------------------------------
    DPG-5626
    Method: GetPurchaseOrderNoForConfiguration
    Description: Fetch Purchase Order No from Subscription
    Inputs: inputMap
    Devlop: Monali Mukherjee
    ------------------------------------------------------------*/
    global static string GetPurchaseOrderNoForConfiguration(String configIdsStr) {
        try {
            Set < String > configIds = new set < String > (configIdsStr.Split(','));
            list < csord__Subscription__c > subList = new list < csord__Subscription__c > ();
            if (configIds != null && configIds.size() > 0) {
                subList = [select id, Logistics_Order_Number__c, csordtelcoa__Product_Configuration__c from csord__Subscription__c where csordtelcoa__Product_Configuration__c In: configIds];
            }
            if (subList != null && subList.size() > 0) {
                return JSON.serialize(subList);
            }
        } catch (Exception e) {
            System.debug('GetPurchaseOrderNoForConfiguration: ' + e.getMessage());
        }
        return '';
    }
    /*------------------------------------------------------------
    EDGE-111053
    Method: getETCChargesForTID
    Description: Calculate ETC Charges for Internet Site Product
    Inputs: inputMap
    History
    <04-11-2019> <Sandip Deshmane>
    ------------------------------------------------------------*/
    global static Map < String, String > getETCChargesForTID(Map < String, Object > inputMap) {
        Map < String, Object > returnMap = new Map < String, Object > ();
        String prodConfigId = (String) inputMap.get('ProdConfigId');
        System.debug('prodConfigId' + prodConfigId);
        Date disconnectionDate = Date.valueOf((String) inputMap.get('DisconnectionDate'));
        Integer contractTerm = Integer.valueOf(inputMap.get('ContractTerm'));
        Integer etcPercentage = Integer.valueOf(inputMap.get('ETCPercentage'));
        Decimal unitPrice = 0.0;
        Date initialActivationDate = null;
        String billingAccNumber;
        Map < String, String > results;
        List < csord__Service__c > services = [SELECT Id, Initial_Activation_Date__c
            FROM csord__Service__c
            WHERE csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (services != null && services.size() > 0) {
            initialActivationDate = services[0].Initial_Activation_Date__c;
        }
        List < cscfga__Attribute__c > attributes = [SELECT Id, cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Recurring__c, cscfga__Product_Configuration__c
            FROM cscfga__Attribute__c
            WHERE cscfga__Product_Configuration__c =: prodConfigId AND cscfga__Is_Line_Item__c = true AND cscfga__Recurring__c = true
        ];
        if (attributes.size() > 0) {
            unitPrice = Decimal.valueOf(attributes[0].cscfga__Value__c);
            System.debug('***TID:SolutionActionHelper:getETCChargesForTID:AttributeRecurringCharges:' + attributes[0]);
        }
        List < csord__Subscription__c > subsRecord = [SELECT Id, Billing_Account__r.Billing_Account_Number__c
            from csord__Subscription__c
            where csordtelcoa__Product_Configuration__c =: prodConfigId
        ];
        if (subsRecord != null && subsRecord.size() > 0) {
            billingAccNumber = subsRecord[0].Billing_Account__r.Billing_Account_Number__c;
        }
        System.debug('***TID:SolutionActionHelper:getETCChargesForTID:prodConfigId=' + prodConfigId + ', initialActivationDate= ' + initialActivationDate + ', disconnectionDate=' + disconnectionDate + ', contractTerm=' + contractTerm + ', unitPrice=' + unitPrice + ', billingAccNumber=' + billingAccNumber);
        List < Object > attributesData = new List < Object > ();
        String etcCharge;
        if (String.isNotEmpty(prodConfigId) && disconnectionDate != NULL && billingAccNumber != NULL) {
            results = EarlyCancellationCalcService.CancelChargesCalcforTID(etcPercentage, initialActivationDate, disconnectionDate, contractTerm, unitPrice, false, billingAccNumber);
        }
        System.debug('***Telstra:SolutionActionHelper:getETCChargesForTID:etcCharge=' + results);
        return results;
    }
    /**
     * Due to HV optimisation total values fiels are no longer maintained on the solution record on every PC change.
     * This is replacement logic that should update those fields only once at the end of the save operation (afterSave hook).
     * AB: post upgrade changes
     */
    global static void updateSolutionTotals(String solutionId) {
        decimal totalOneOff = 0;
        decimal totalRC = 0;
        decimal totalContractValue = 0;
        //sum all parent PC to get up-to-date  total contract value
        AggregateResult[] parentPCsGroup = [SELECT SUM(cscfga__total_contract_value__c) TCV
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Parent_Configuration__c = null AND cssdm__solution_association__c =: solutionId
        ];
        //summ all PC to get up-to-date OC and RC values
        AggregateResult[] allPCsGroup = [SELECT SUM(cscfga__One_Off_Charge__c) OC, SUM(cscfga__Recurring_Charge__c) RC
            FROM cscfga__Product_Configuration__c
            WHERE cssdm__solution_association__c =: solutionId
        ];
        //optimisation check, if values are unchanged then no need for DML
        csord__Solution__c sol = [SELECT Id, cssdm__total_one_off_charge__c, cssdm__total_recurring_charge__c, cssdm__total_contract_value__c
            FROM csord__Solution__c
            WHERE Id =: solutionId
        ];
        totalContractValue = (decimal) parentPCsGroup[0].get('TCV');
        totalRC = (decimal) allPCsGroup[0].get('RC');
        totalOneOff = (decimal) allPCsGroup[0].get('OC');
        //if nothing changed then skip the DML
        if (sol.cssdm__total_one_off_charge__c != totalOneOff || sol.cssdm__total_recurring_charge__c != totalRC || sol.cssdm__total_contract_value__c != totalContractValue) {
            sol.cssdm__total_one_off_charge__c = totalOneOff;
            sol.cssdm__total_recurring_charge__c = totalRC;
            sol.cssdm__total_contract_value__c = totalContractValue;
            update sol;
            system.debug('Solution totals updated: ' + sol);
        }
    }
    /*
     * Gnana : Spring'20 Upgradae
     * Moved updating basket oppty sync flag logic from AttributeTrigger to AfterSave hook
     */
    global static String updateBasketOppySynFlag(String basketId) {
        List < cscfga__Product_Basket__c > prodBasketUpdateList = new List < cscfga__Product_Basket__c > ();
        List < cscfga__Product_Basket__c > prodBasketList = [Select id, cscfga__Opportunity__r.Product_Type__c, csbb__Synchronised_with_Opportunity__c
            from cscfga__Product_Basket__c
            where id =: basketId and csbb__Synchronised_with_Opportunity__c = true
        ];
        for (cscfga__Product_Basket__c basket: prodBasketList) {
            basket.csbb__Synchronised_with_Opportunity__c = false;
            prodBasketUpdateList.add(basket);
        }
        try {
            if (prodBasketUpdateList != null && prodBasketUpdateList.size() > 0) {
                update prodBasketUpdateList;
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception on Updating Basket Oppty Sync Flag...' + e);
            return 'Failed Remote Action => updateBasket: ' + e.getMessage();
        }
    }
    /*
     * Aditya : Spring'20 Upgradae
     * Moved updating basket stage to Draft logic from PCRTrigger to AfterSolutionDelete hook
     */
    global static String updateBasketStageToDraft(String basketId) {
        System.debug('inside updateBasketStageToDraft...');
        List < cscfga__Product_Basket__c > prodBasketUpdateList = new List < cscfga__Product_Basket__c > ();
        List < cscfga__Product_Basket__c > prodBasketList = [Select id, csordtelcoa__Basket_Stage__c, (
                Select id from cscfga__Product_Configurations__r)
            from cscfga__Product_Basket__c
            where id =: basketId
        ];
        for (cscfga__Product_Basket__c basket: prodBasketList) {
            System.debug('****' + basket.cscfga__Product_Configurations__r.size());
            if (basket.cscfga__Product_Configurations__r.size() == 0 && CustomConfigurationOptions__c.getValues('Draft') != null && CustomConfigurationOptions__c.getValues('Draft').Enrichment_Basket_Stage__c != null) {
                basket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('Draft').Enrichment_Basket_Stage__c;
                prodBasketUpdateList.add(basket);
            }
        }
        try {
            if (prodBasketUpdateList != null && prodBasketUpdateList.size() > 0) {
                System.debug('prodBasketList...');
                update prodBasketUpdateList;
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception on Updating Basket Stage to Draft...' + e);
            return 'Failed Remote Action => updateBasketStageToDraft: ' + e.getMessage();
        }
    }
    /*
     * Pooja : Spring'20 Upgrade
     * Moved this logic from PCRTrigger AfterInsert Event to AfterSave Hook. Method to -
     *      a. To update Basket Stage from Draft to Commercial Configuration
     *      b. To reset Opportunity Sync Flags to false
     */
    global static String updateBasketDetails(String basketId) {
        List < cscfga__Product_Basket__c > prodBasketUpdateList = new List < cscfga__Product_Basket__c > ();
        List < cscfga__Product_Basket__c > prodBasketList = [SELECT Id, csordtelcoa__Basket_Stage__c, basketType__c, csbb__Synchronised_With_Opportunity__c, csordtelcoa__Synchronised_with_Opportunity__c FROM cscfga__Product_Basket__c WHERE Id =: basketId LIMIT 1]; // added basketType__c by Ankit/shubhi for Edge-181996 
        for (cscfga__Product_Basket__c basket: prodBasketList) {
            Boolean isStageUpdated = false;
            Boolean isSyncFlagUpdated = false;
            if (basket.basketType__c == Label.Non_Commercial) { //// added basketType__c by Ankit/shubhi for Edge-181996 start
                if (CustomConfigurationOptions__c.getValues('Configuration') != null && CustomConfigurationOptions__c.getValues('Configuration').Enrichment_Basket_Stage__c != null && basket.csordtelcoa__Basket_Stage__c != CustomConfigurationOptions__c.getValues('Configuration').Enrichment_Basket_Stage__c) {
                    basket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('Configuration').Enrichment_Basket_Stage__c;
                    isStageUpdated = true;

                } //// added basketType__c by Ankit/shubhi for Edge-181996 end
            } else {
                if ((basket.csordtelcoa__Basket_Stage__c.equalsIgnoreCase(Label.Draft) || String.isBlank(basket.csordtelcoa__Basket_Stage__c)) && CustomConfigurationOptions__c.getValues('CommercialConfiguration') != null && CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c != null) {
                    basket.csordtelcoa__Basket_Stage__c = CustomConfigurationOptions__c.getValues('CommercialConfiguration').Enrichment_Basket_Stage__c;
                    isStageUpdated = true;
                }
                if (basket.csbb__Synchronised_With_Opportunity__c == true || basket.csordtelcoa__Synchronised_with_Opportunity__c == true) {
                    basket.csordtelcoa__Synchronised_with_Opportunity__c = false;
                    basket.csbb__Synchronised_With_Opportunity__c = false;
                    isSyncFlagUpdated = true;
                }
            }
            if (isStageUpdated || isSyncFlagUpdated) {
                prodBasketUpdateList.add(basket);
            }
        }
        try {
            if (!prodBasketUpdateList.isEmpty()) {
                update prodBasketUpdateList;
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception while updating basket stage to commericial configuration *** ' + e.getMessage() + ' LN: ' + e.getLineNumber());
            return 'Failed Remote Action => setOppyBasketSynFlagFalse: ' + e.getMessage();
        }
    }
    //End of method updateBasketDetails
    /*
     * EDGE-167811 - Spring20 Upgrade
     * Method added to fetch the OE details to show on NumberManagement OE tab - 
     * @Param - String
     * @Param - String
     * @Return - String    
     */
    global static String getOeAttachment(String fileName, String configurationId) {
        List < Attachment > oeAttList = [SELECT Id, body FROM Attachment
            WHERE Name LIKE: fileName AND parentid =: configurationId
            LIMIT 1
        ];
        if (!oeAttList.isEmpty()) {
            return oeAttList[0].body.toString();
        } else {
            return '';
        }
    } //End of getOeAttachment
    /*------------------------------------------------------------
EDGE-168275, EDGE-164350 
Method: getChildServicesForDeviceCare
Description: fetch services based on replacedConfigId
Inputs: inputMap
History
<03-09-2020> <Manish Berad>
------------------------------------------------------------*/
    global static csord__Service__c getChildServicesForDeviceCare(String repConfigId) {
        csord__Service__c returnchildService = new csord__Service__c();
        try {
            if (repConfigId != null) {
                csord__Service__c ParentService = [select Initial_Activation_Date__c, csord__Status__c
                    from csord__Service__c
                    where csordtelcoa__Product_Configuration__c =: repConfigId
                    LIMIT 1
                ];
                if (ParentService != null) {
                    csord__Service__c childService = [select Initial_Activation_Date__c, csord__Status__c
                        from csord__Service__c where csord__Service__c =: ParentService.Id LIMIT 1
                    ];
                    if (childService != null && childService.csord__Status__c == 'Connected' &&
                        childService.Initial_Activation_Date__c != null) {
                        returnchildService = childService;
                    } else {
                        returnchildService = null;
                    }
                } else {
                    returnchildService = null;
                }
            }
        } catch (Exception e) {
            System.debug('getTrialPeriodfromActivationDate: ' + e.getMessage());
        }
        return returnchildService;
    }
    /*------------------------------------------------------------
    EDGE-168275, EDGE-164351 
    Method: updateISPOSReversalRequired
    Description: update basket field Is_OF_POS_Reversal_Required__c on the basis of RedeemFundCopy attribute
    Inputs: inputMap
    History
    <03-09-2020> <Manish Berad/Aarathi>
    ------------------------------------------------------------*/
    global static void updateISPOSReversalRequired(String basketId) {
        //try{
        if (basketId != null) {
            cscfga__Product_Basket__c newbsk = new cscfga__Product_Basket__c();
            newbsk.Id = basketId;
            newbsk.Is_OF_POS_Reversal_Required__c = true;
            update newbsk;
        }
        /*} catch (Exception e){
            System.debug('updateISPOSReversalRequired: ' + e.getMessage());
        }*/
    }
    /*************************************************************************************************
    *EDGE-165017
    * Method Name : getLoginUserProfileName 
    * Description : Used to fetch the profiles
    <9/10/2020> <Manuga Kale>

    *************************************************************************************************/
    global static Profile getLoginUserProfileName() {
        Id profileId = userinfo.getProfileId();
        profile profileName = [Select Id, Name from Profile where Id =: profileId];

        system.debug('ProfileName' + profileName);
        return profileName;
    }
    /*------------------------------------------------------------
     DPG-1878
     Method: GetBillingCheckInfo
     Description: Returns true & false as per billingAccount availability(Used In Next Gen Adaptive Care)
     Inputs: inputMap
     History
     <04-11-2019> <Pravin K.>
    ------------------------------------------------------------*/
    global static String GetBillingCheckInfo(String accountId, String billingAccountInfo, String guid) {
        /* DN: COPADOCI02 start...
        try {
            List < string > oldBillingAccInfo = new List < String > ();
            Map < string, string > pcWithBillinInfo = new Map < String, String > ();
            for (cscfga__Attribute__c attributeInst: [SELECT cscfga__Product_Configuration__c, cscfga__Value__c, Name, cscfga__Product_Configuration__r.cscfga__Product_Basket__c, cscfga__Product_Configuration__r.Name FROM cscfga__Attribute__c
                    WHERE cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c =: accountId AND(Name = 'BillingAccountShadowNextGenAC'
                        OR Name = 'GUID') ORDER BY name ASC
                ]) {
                if (attributeInst.cscfga__Value__c == billingAccountInfo) {
                    pcWithBillinInfo.put(attributeInst.cscfga__Product_Configuration__c, attributeInst.cscfga__Value__c);
                }
                if (attributeInst.cscfga__Value__c == guid) {
                    pcWithBillinInfo.remove(attributeInst.cscfga__Product_Configuration__c);
                }
            }
            system.debug('the pclist contains-->' + pcWithBillinInfo);
            if (!pcWithBillinInfo.isEmpty()) {
                return 'true';
            }
        } catch (Exception e) {
            System.debug('GetBasketChangeType: ' + e.getMessage());
        }
        return 'false';
        DN: COPADOCI02 ...end */

        /*DN: master start...*/
        try {
            List < string > oldBillingAccInfo = new List < String > ();
            Map < string, string > pcWithBillinInfo = new Map < String, String > ();
            //Added By Monali :Start
            List < cscfga__Attribute__c > pcList = new List < cscfga__Attribute__c > ();
            set < String > subPCIdsSet = new Set < String > ();
            String results;
            system.debug('billingAccountInfo -->' + billingAccountInfo);
            system.debug('accountId -->' + accountId);
            list < csord__Subscription__c > Sublist = [select id, Name, csord__Account__c, Billing_Account__c, csordtelcoa__Product_Configuration__c
                from csord__Subscription__c where Billing_Account__c =: billingAccountInfo and csord__Status__c = 'Active'
                and ConfigSpecID__c IN('DMCAT_Offer_001251', 'DMCAT_ProductSpecification_001252')
            ];
            system.debug('the Sublist -->' + Sublist);
            if (!Sublist.isEmpty()) {
                system.debug('Yes Active Subscription for the billing Account -->' + results);
                results = 'true';
                return 'true';
            } else {
                results = 'false';
                system.debug('No Active Subscription for the billing Account,checking Contract Initiated till Submitted stages... -->');

                List < csord__Subscription__c > subPCList = [select id, Name, csord__Account__c, Billing_Account__c, csordtelcoa__Product_Configuration__c
                    from csord__Subscription__c where Billing_Account__c =: billingAccountInfo and
                    csord__Status__c IN('Inactive', 'Closed Replaced') and ConfigSpecID__c IN('DMCAT_Offer_001251', 'DMCAT_ProductSpecification_001252')
                ];
                system.debug('subPCList' + subPCList);
                for (csord__Subscription__c subpc: subPCList) {
                    subPCIdsSet.add(subpc.csordtelcoa__Product_Configuration__c);
                }
                system.debug('subPCIdsSet--' + subPCIdsSet);

                if (subPCIdsSet != null && subPCIdsSet.size() > 0) {
                    system.debug('Checking If subPCIdsSet--' + subPCIdsSet);
                    pcList = [SELECT id, cscfga__Product_Configuration__c, cscfga__Value__c, Name, cscfga__Product_Configuration__r.cscfga__Product_Basket__c, cscfga__Product_Configuration__r.Name,
                        cscfga__Product_Configuration__r.Type__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c, cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c
                        FROM cscfga__Attribute__c WHERE cscfga__Product_Configuration__r.Type__c = 'New'
                        and(cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Contract Initiated'
                            OR cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Contract Accepted'
                            OR cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Enriched')
                        and cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c =: accountId
                        AND(Name = 'BillingAccountShadowNextGenAC'
                            OR Name = 'GUID')
                        AND cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c = 'DMCAT_Offer_001251'
                        AND cscfga__Product_Configuration__r.id NOT IN: subPCIdsSet
                    ];
                } else {
                    system.debug('Checking else subPCIdsSet--' + subPCIdsSet);
                    pcList = [SELECT id, cscfga__Product_Configuration__c, cscfga__Value__c, Name,
                        cscfga__Product_Configuration__r.cscfga__Product_Basket__c, cscfga__Product_Configuration__r.Name,
                        cscfga__Product_Configuration__r.Type__c, cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c, cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c
                        FROM cscfga__Attribute__c WHERE cscfga__Product_Configuration__r.Type__c = 'New'
                        and(cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Contract Initiated'
                            OR cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Contract Accepted'
                            OR cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csordtelcoa__Basket_Stage__c = 'Enriched')
                        and cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c =: accountId
                        AND(Name = 'BillingAccountShadowNextGenAC'
                            OR Name = 'GUID')
                        AND cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c = 'DMCAT_Offer_001251'
                    ];
                }
                system.debug('pcList' + pcList);
                if (pcList != null && pcList.size() > 0) {
                    for (cscfga__Attribute__c attrListC: pcList) {
                        if (attrListC.cscfga__Value__c == billingAccountInfo) {
                            pcWithBillinInfo.put(attrListC.cscfga__Product_Configuration__c, attrListC.cscfga__Value__c);
                        }
                        if (attrListC.cscfga__Value__c == guid) {
                            pcWithBillinInfo.remove(attrListC.cscfga__Product_Configuration__c);
                        }
                    }
                    if (!pcWithBillinInfo.isEmpty()) {
                        return 'true';
                    }
                } else {
                    system.debug('No Contract Initiated for the billing Account -->');
                    results = 'false';

                    for (cscfga__Attribute__c attributeInst: [SELECT cscfga__Product_Configuration__c, cscfga__Value__c, Name, cscfga__Product_Configuration__r.cscfga__Product_Basket__c,
                            cscfga__Product_Configuration__r.Name FROM cscfga__Attribute__c
                            WHERE cscfga__Product_Configuration__r.cscfga__Product_Basket__r.csbb__Account__c =: accountId
                            AND(Name = 'BillingAccountShadowNextGenAC'
                                OR Name = 'GUID') ORDER BY name ASC
                        ]) {
                        if (attributeInst.cscfga__Value__c == billingAccountInfo) {
                            pcWithBillinInfo.put(attributeInst.cscfga__Product_Configuration__c, attributeInst.cscfga__Value__c);
                        }
                        if (subPCIdsSet != null && subPCIdsSet.size() > 0) {
                            for (String s: subPCIdsSet) {
                                if (pcWithBillinInfo.containskey(s)) {
                                    system.debug('pcWithBillinInfo Remove+' + pcWithBillinInfo);
                                    pcWithBillinInfo.remove(attributeInst.cscfga__Product_Configuration__c);
                                }
                            }
                        }
                        if (attributeInst.cscfga__Value__c == guid) {
                            pcWithBillinInfo.remove(attributeInst.cscfga__Product_Configuration__c);
                        }
                    }
                    system.debug('the pclist contains-->' + pcWithBillinInfo);
                    if (!pcWithBillinInfo.isEmpty()) {
                        return 'true';
                    }
                }
            }
            //Added By Monali : End
        } catch (Exception e) {}
        return 'false';
        /*DN: master ...end*/
    }
    /*------------------------------------------------------------
    DPG-2577 - Krunal Taak
    Method: getActiveManagedServiceSubscriptionCheckInfo
    Description: Returns true & false as per Active Managed Service Subscription availability(Used In Enterprise Managed Services)
    Inputs: inputMap
    ------------------------------------------------------------*/
    global static String getActiveManagedServiceSubscriptionCheckInfo(String tenancyId) {
        try {
            //Sub_Status__c = 'Active' / csord__Account__c=:accountId AND
            system.debug('--tenancyid--' + tenancyId);
            List < csord__Subscription__c > subscriptionList = [SELECT id, TenancyID__c, MarketableOffer__r.Offer_ID__c FROM csord__Subscription__c WHERE csord__Status__c = 'Active'
                AND TenancyID__c =: tenancyId AND MarketableOffer__r.Offer_ID__c = 'DMCAT_Offer_000854'
            ];
            system.debug('the subscriptionList -->' + subscriptionList);
            if (!subscriptionList.isEmpty()) {
                return 'true';
            }
        } catch (Exception e) {
            System.debug('subscriptionList Error: ' + e.getMessage());
        }
        return 'false';
    }
    /************************************************************************************************* 
     * Story : DPG-2319 
     * Author : Shresth Dixit
     * Method Name : getCommercialProductId
     * Description : Used to fetch Commercial Product Id
     *************************************************************************************************/
    global static String getCommercialProductId(String technicalSupport, String featureLevel, String productSpecificationId) {
        if (String.isNotBlank(technicalSupport) && String.isNotBlank(featureLevel) && String.isNotBlank(productSpecificationId)) {
            List < Id > commercialProductIdSet = new List < Id > ();
            for (cspmb__Price_Item__c commercialProduct: [SELECT Id FROM cspmb__Price_Item__c
                    WHERE ProdSpecId__c =: productSpecificationId
                    AND Check_todays_date__c = TRUE
                    AND Technical_Support__c =: technicalSupport
                    AND Feature_Level__c =: featureLevel
                ]) {
                commercialProductIdSet.add(commercialProduct.id);
            }
            if (commercialProductIdSet.size() == 1) {
                return (String) commercialProductIdSet[0];
            } else {
                return null;
            }
        }
        return null;
    }
    /*global Static String transitionDeviceCancel(String billingAccNum, String ConfigId){
        
        Integer remainingTerm;
        Date firstBillDate;
        Date datetd = Date.today();
        Date initialActivationDate;
        BillingAccountDetailsDTO billAccDTO = null;
        String results = '';
        
        //System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:maxETC:'+maxETC+',initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm+',unitPrice:'+unitPrice+',isDeviceCancellationApplicable:'+isDeviceCancellationApplicable+',billingAccNum:'+billingAccNum);
        try{ 
            csord__Service__c service = [select Initial_Activation_DateTime__c
                                         from csord__Service__c
                                         where csordtelcoa__Product_Configuration__c = :configId
                                         LIMIT 1];
            List<cscfga__Product_Configuration__c>  listofpc = [select csordtelcoa__Replaced_Service__c,csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c from cscfga__Product_Configuration__c where id =:configId LIMIT 1];
            if(listofpc!= NULL && listofpc.size()>0){
        //invoking BillingAccountRetrieve : web callout
            if(listofpc[0].csordtelcoa__Replaced_Service__c!= NULL && listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c!= NULL){
            initialActivationDate = listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c.date();
            billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
           // System.debug('***Telstra:EarlyCancellationCalcService:CancelCtransitionDeviceCancelhargesCalc:billAccDTO:'+billAccDTO);
        
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
         
                String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
            
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:firstBillDate:'+firstBillDate);
            
                //Date on which latest bill was generated
                
            } 
            if(datetd <= firstBillDate)
            results = 'OC';
            else
            results = 'RCRT';
            return results ;
        }
        else return 'Error';
        }
        else return 'Error';
        }
        catch(Exception e){
            System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:BillingAccount-Response:'+billAccDTO);
            results = 'Error';
            return results;
        }
        
    }*/

    //Start: DIGI-15041 - Transition Device Cancellation Charges
    global Static String transitionDeviceCancel(String billingAccNum, String configId) {
        Integer remainingTerm;
        Date firstBillDate;
        Date datetd = Date.today();
        Date initialActivationDate;
        BillingAccountDetailsDTO billAccDTO = null;
        String results = '';
        //System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:maxETC:'+maxETC+',initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm+',unitPrice:'+unitPrice+',isDeviceCancellationApplicable:'+isDeviceCancellationApplicable+',billingAccNum:'+billingAccNum);
        try {
            /* DN: COPADOCI02 start...
            /*csord__Service__c service = [select Initial_Activation_DateTime__c
                                         from csord__Service__c
                                         where csordtelcoa__Product_Configuration__c = :configId
                                         LIMIT 1];*/
            /*List < cscfga__Product_Configuration__c > listofpc = [select csordtelcoa__Replaced_Service__c, csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c from cscfga__Product_Configuration__c where id =: configId LIMIT 1];
            if (listofpc != NULL && listofpc.size() > 0) {
                //invoking BillingAccountRetrieve : web callout
                if (listofpc[0].csordtelcoa__Replaced_Service__c != NULL && listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c != NULL) {
                    initialActivationDate = listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c.date();
                    billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
                    // System.debug('***Telstra:EarlyCancellationCalcService:CancelCtransitionDeviceCancelhargesCalc:billAccDTO:'+billAccDTO);

                    if (billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS) {

                        String dayValue = billAccDTO.BillingAccount.startDate;
                        Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;

                        // Date on which first bill will be generated in BDS
                        firstBillDate = Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                        if (initialActivationDate >= firstBillDate)
                            firstBillDate = firstBillDate.addMonths(1);
                        System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:firstBillDate:' + firstBillDate);

                        //Date on which latest bill was generated

                    }
                    if (datetd <= firstBillDate)
                        results = 'OC';
                    else
                        results = 'RCRT';
                    return results;
                } else return 'Error';
            } else return 'Error';
            DN: COPADOCI02 ...end */

            /* DN: master start... */
            //Query is enabled for services DIGI-15041
            csord__Service__c service = [select Initial_Activation_DateTime__c
                from csord__Service__c
                where csordtelcoa__Product_Configuration__c =: configId
                LIMIT 1
            ];

            //List<cscfga__Product_Configuration__c>  listofpc = [select csordtelcoa__Replaced_Service__c,csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c from cscfga__Product_Configuration__c where id =:configId LIMIT 1];
            //if(listofpc!= NULL && listofpc.size()>0){
            //invoking BillingAccountRetrieve : web callout
            //if(listofpc[0].csordtelcoa__Replaced_Service__c!= NULL && listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c!= NULL){
            //initialActivationDate = listofpc[0].csordtelcoa__Replaced_Service__r.Initial_Activation_DateTime__c.date();

            if (service != null) {
                initialActivationDate = service.Initial_Activation_DateTime__c.date();
                billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
                // System.debug('***Telstra:EarlyCancellationCalcService:CancelCtransitionDeviceCancelhargesCalc:billAccDTO:'+billAccDTO);
                if (billAccDTO != null && billAccDTO.BillingAccount != null &&
                    billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS) {
                    String dayValue = billAccDTO.BillingAccount.startDate;
                    Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;

                    // Date on which first bill will be generated in BDS
                    firstBillDate = Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                    if (initialActivationDate >= firstBillDate)
                        firstBillDate = firstBillDate.addMonths(1);
                    System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:firstBillDate:' + firstBillDate);
                    //Date on which latest bill was generated
                }
                if (datetd <= firstBillDate)
                    results = 'OC';
                else
                    results = 'RCRT';
                return results;
            } else return 'Error';
            /* DN: master ...end */
        } catch (Exception e) {
            System.debug('***Telstra:EarlyCancellationCalcService:transitionDeviceCancel:BillingAccount-Response:' + billAccDTO);
            results = 'Error';
            return results;
        }
    }

    public static void updateBAUSolutionTotals(Id solutionId) {
        System.debug('Eter Method updateBAUSolutionTotals');
        Decimal totalOneOff = 0;
        Decimal totalRC = 0;
        Decimal totalContractValue = 0;
        BAUSolutionFields__mdt bauSolutionFieldInstance = [SELECT Id, Once_Off_Fields__c, Recurring_Fields__c
            FROM BAUSolutionFields__mdt WHERE DeveloperName = 'Once_and_Recurring_fields'
        ];
        List < String > listOfOnceOffFields = new List < String > ();
        List < String > listOfRecurringField = new List < String > ();
        listOfOnceOffFields = bauSolutionFieldInstance.Once_Off_Fields__c.split(',');
        listOfRecurringField = bauSolutionFieldInstance.Recurring_Fields__c.split(',');
        List < cscfga__Attribute__c > listOfAttributes = [SELECT Id, Name, cscfga__Value__c
            FROM cscfga__Attribute__c
            WHERE cscfga__Product_Configuration__r.cssdm__solution_association__c =: solutionId
            AND(Name IN: listOfOnceOffFields OR Name IN: listOfRecurringField)
        ];
        for (cscfga__Attribute__c attr: listOfAttributes) {
            if (listOfOnceOffFields.contains(attr.Name) && !String.isBlank(attr.cscfga__Value__c)) {
                totalOneOff += Decimal.valueof(attr.cscfga__Value__c.trim());
            } else if (listOfRecurringField.contains(attr.Name) && !String.isBlank(attr.cscfga__Value__c)) {
                totalRC += Decimal.valueof(attr.cscfga__Value__c.trim());
            }
        }

        AggregateResult[] parentPCsGroup = [SELECT SUM(cscfga__total_contract_value__c) TCV
            FROM cscfga__Product_Configuration__c
            WHERE cscfga__Parent_Configuration__c = null
            AND cssdm__solution_association__c =: solutionId
        ];
        totalContractValue = (Decimal) parentPCsGroup[0].get('TCV');
        List < csord__Solution__c > listOfSolution = [SELECT Id, cssdm__total_one_off_charge__c, cssdm__total_recurring_charge__c,
            cssdm__total_contract_value__c
            FROM csord__Solution__c
            WHERE Id =: solutionId
        ];
        List < csord__Solution__c > listOfSolutionToUpdate = new List < csord__Solution__c > ();
        for (csord__Solution__c sol: listOfSolution) {
            if (sol.cssdm__total_one_off_charge__c != totalOneOff ||
                sol.cssdm__total_recurring_charge__c != totalRC ||
                sol.cssdm__total_contract_value__c != totalContractValue) {

                sol.cssdm__total_one_off_charge__c = totalOneOff;
                sol.cssdm__total_recurring_charge__c = totalRC;
                sol.cssdm__total_contract_value__c = totalContractValue;
            }
            listOfSolutionToUpdate.add(sol);
        }

        if (!listOfSolutionToUpdate.isEmpty()) {
            update listOfSolutionToUpdate;
            System.debug('List Of Solution Update' + listOfSolutionToUpdate);

        }
    }

    //EDGE-216217   
    global static String invalidateOnBasketRedemptions(String basketId) {
        System.debug('in invalidateOnBasketRedemptions ----->>>>>:' + basketId);
        list < cscfga__Product_Basket__c > prodBsktLst = [Select id, cscfga__Basket_Status__c, cscfga__pricing_status__c from cscfga__Product_Basket__c where id =: basketId LIMIT 1];
        System.debug('prodBsktLst ----->>>>>:' + prodBsktLst);
        try {
            if (prodBsktLst != null && prodBsktLst[0].cscfga__Basket_Status__c != 'Incomplete') {
                prodBsktLst[0].cscfga__Basket_Status__c = 'Incomplete';
                prodBsktLst[0].cscfga__pricing_status__c = 'Current';
                update prodBsktLst;
                System.debug('After Update prodBsktLst ----->>>>>:' + prodBsktLst);
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception while updating basket stage to Invalid *** ' + e.getMessage() + ' LN: ' + e.getLineNumber());
            return 'Failed Remote Action => invalidateOnBasketRedemptions: ' + e.getMessage();
        }
    }

    global static String markBasketAsInvalid(String basketId) {
        Decimal redemptionamount;
        Id oppAccountId;
        list < cscfga__Product_Basket__c > prodBsktLst = [Select id, cscfga__Opportunity__r.Basket_Redemption_amount__c, cscfga__Opportunity__r.AccountId, cscfga__Basket_Status__c, cscfga__pricing_status__c from cscfga__Product_Basket__c where id =: basketId LIMIT 1];
        if (prodBsktLst != null && prodBsktLst.size() > 0) {
            redemptionamount = prodBsktLst[0].cscfga__Opportunity__r.Basket_Redemption_amount__c;
            oppAccountId = prodBsktLst[0].cscfga__Opportunity__r.AccountId;
        }

        //Decimal redemptionamount = basketId.cscfga__Opportunity__r.Basket_Redemption_amount__c;
        //Id oppAccountId = productBasket.cscfga__Opportunity__r.AccountId;
        //Opportunity opp = [SELECT id, Basket_Redemption_amount__c, AccountId FROM Opportunity WHERE id = :productBasket.cscfga__Opportunity__c LIMIT 1];

        try {
            if (redemptionamount > 0) {
                // Fetching OneFund Balance for Account
                Map < String, Object > params = new Map < String, Object > ();
                params.put('recordId', oppAccountId);
                Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen ShowOneFundBalance = new Flow.Interview.Show_Available_OneFunds_on_Retrospective_Redemption_Screen(
                    params
                );
                ShowOneFundBalance.start();
                Decimal availableOneFundBalance = (Decimal) ShowOneFundBalance.getVariableValue('TotalOneFundAmount');
                //Error on insufficient OneFund balance
                if (redemptionamount > availableOneFundBalance) {
                    //ValidateMinimumRequirements.markBasketAsInvalid(basketId);
                    if (prodBsktLst != null && prodBsktLst[0].cscfga__Basket_Status__c != 'Incomplete') {
                        System.debug('Here ----->>>>>');
                        prodBsktLst[0].cscfga__Basket_Status__c = 'Incomplete';
                        prodBsktLst[0].cscfga__pricing_status__c = 'Current';
                        update prodBsktLst;
                    }
                }
            }
            return 'Success';
        } catch (Exception e) {
            System.debug('Exception while updating basket stage to Invalid *** ' + e.getMessage() + ' LN: ' + e.getLineNumber());
            return 'Failed Remote Action => makebasketInvalid: ' + e.getMessage();
        }
    }

    global static Map < String, Object > getReplacedConfigId(Map < String, Object > inputMap, Map < String, Object > returnMap) {
        // to be excluded in future when atch will fix this issue //added for replace config id at child level //Edge-EDGE-169593
        //added by shubhi for replaceconfig id
        //Map<String, Object> returnMap = new Map<String, Object>();
        String replacedConfigId = (String) inputMap.get('replacedConfigId');
        String attributeName = (String) inputMap.get('attributeName');
        //String basketId = (String)inputMap.get('basketId');   
        String guid = (String) inputMap.get('GetConfigurationId');
        cscfga__Product_Configuration__c pc = [Select id, configGUID__c, csordtelcoa__Replaced_Product_Configuration__c,
            cscfga__Parent_Configuration__c
            from cscfga__Product_Configuration__c where configGUID__c =: guid
            and cscfga__Parent_Configuration__c =: replacedConfigId limit 1
        ];
        if (pc != null && pc.cscfga__Parent_Configuration__c != null) {
            returnMap.put('childGuid', pc.configGUID__c);
            returnMap.put('childId', pc.id);
            returnMap.put(attributeName, pc.cscfga__Parent_Configuration__c);
        }
        return returnMap;
    }
}
/*
 * Class Name: CS_TierForBandwidthClipon
Description: Custom Lookup
ChangeSet No    Name            Date                    Description
CH-1            Vijaya         03/11/2019      EDGE-65981 As a sales / partner user,
                                                I want product configuration page to validate the
                                                configured user quantity, disable / enable bandwidth
                                                bolt on based on C2M provided business rules so that
                                                sales will sale the solution that's supported at that site.
Ch2				Laxmi		   28/06/2019		EDGE-92949 - Bandwidth CLip on drop down was not gettign populated, 
												added equalt to along with less than in the Where query clause
*/

global with sharing class CS_TierForBandwidthClipon extends cscfga.ALookupSearch {

    public override String getRequiredAttributes() {
        return '["User Quantity","Prod_Cnf_Id", "OfferId", "Technology", "Technology Type"]';
    }

    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds,
                                            Integer pageOffset, Integer pageLimit) {
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT;
        Integer recordOffset = 1;
        if (pageLimit != null) {
            SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = pageLimit + 1;
        } else
            SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 1;

        if (pageOffset != null && pageOffset != 0 && pageLimit != null && pageLimit != 0)
            recordOffset = pageOffset * pageLimit;

        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.recordOffset = ' + recordOffset);

        String result = '';
        if (searchFields.get('searchValue') == null)
            result = '%%';
        else
            result = '%' + searchFields.get('searchValue') + '%';

        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.searchFields = ' + searchFields);
        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.result = ' + result);

        String offerId = searchFields.get('OfferId');
        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.offerId = ' + offerId);

        String Technology = searchFields.get('Technology');
        String Technology_Type = searchFields.get('Technology Type');
        Integer User_Quantity = Integer.ValueOf(searchFields.get('User Quantity'));

        //CH-1 Start - EDGE-65981 to filter tier value based on NBN technology and Access type.
        List<Bandwidth_Calculation__c> tierList = new List<Bandwidth_Calculation__c>();
        String tierqueryString = 'SELECT ';
        tierqueryString += 'Count_Bandwidth_Clip_On__c ';
        tierqueryString += 'FROM ';
        tierqueryString += 'Bandwidth_Calculation__c ';
        tierqueryString += 'WHERE ';
        tierqueryString += 'Technology__c = :Technology ';
        tierqueryString += 'AND ';
        tierqueryString += 'Technology_Type__c = :Technology_Type ';
        tierqueryString += 'AND ';
        // Ch2 - Added = in below clause along with < and >
        tierqueryString += 'Max_User_Count__c >= :User_Quantity ';
        tierqueryString += 'AND ';
        tierqueryString += 'Min_User_Count__c <= :User_Quantity ';

        tierList = Database.Query(tierqueryString);
        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.tierList = ' + tierList);
        List<String> tierList1 = new List<String>();
        for (Bandwidth_Calculation__c locTier : tierList) {
            String locTierString = String.ValueOf(locTier.Count_Bandwidth_Clip_On__c);
            tierList1.add(locTierString);
        }
        //CH-1 End - EDGE-65981 to filter tier value based on NBN technology and Access type.

        //EDGE-41492 - Added Billing_Description__c field to existing query
        List<cspmb__Price_Item__c> priceList = new List<cspmb__Price_Item__c>();
        String queryString = 'SELECT ';
        queryString += 'Id, ';
        queryString += 'Name, ';
        queryString += 'Tier__c, ';
        queryString += 'cspmb__Recurring_Charge__c, ';
        queryString += 'cspmb__One_Off_Charge__c, ';
        queryString += 'Frequency__c, ';
        queryString += 'Check_todays_date__c, ';
        queryString += 'Unit_Of_Measure__c, ';
        queryString += 'taxTreatment__c, ';
        queryString += 'Package_Name__c, ';
        queryString += 'Billing_Description__c ';
        queryString += 'FROM ';
        queryString += 'cspmb__Price_Item__c ';
        queryString += 'WHERE ';
        queryString += 'cspmb__Product_Definition_Name__c = \'Bandwidth Clip On\' ';
        queryString += 'AND ';
        queryString += 'Package_Name__c = \'Connected Workplace\' ';
        queryString += 'AND ';
        queryString += 'Check_todays_date__c = true ';
        //CH-1
        if (!tierList1.isEmpty()) {
            queryString += 'AND ';
            queryString += 'Tier__c IN : tierList1 ' ;
        }

        if (result != '') {
            queryString += 'AND ';
            queryString += 'Tier__c LIKE :result ';
        }

        if (offerId != ''  && offerId != null) {
            String offIdSearch = '%' + offerId + '%';
            queryString += 'AND ';
            queryString += 'Offer_Id__c LIKE :offIdSearch ';
        }
        queryString += 'LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT ';

        priceList = Database.Query(queryString);
        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.priceList = ' + priceList);
        System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.User_Quantity = ' + User_Quantity);

        Map<String, cspmb__Price_Item__c> tierMap = new  Map<String, cspmb__Price_Item__c>();
        if (priceList != null) {
            //system.debug('priceList-->'+priceList);
            for (cspmb__Price_Item__c item : priceList) {
                if (User_Quantity > 78 && User_Quantity < 104) {
                    System.debug(LoggingLevel.INFO, 'CS_TierForBandwidthClipon.item = ' + item);
                    if (item.Tier__c == '1') {
                        tierMap.put(item.Tier__c, item);
                        break;
                    }
                }
                //Ch2 - Changed from 4 to 3 and added = sign
                if (User_Quantity >=3 && User_Quantity < 79)
                    tierMap.put(item.Tier__c, item);
            }
        }

        return tierMap.values();
    }
}
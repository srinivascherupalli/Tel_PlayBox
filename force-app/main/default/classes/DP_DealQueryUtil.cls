/*********************************************************************************************************************************
Class Name:     DP_DealQueryUtil
Description:    The purpose of the class is to have methods to query on Deal objects for the deals that are active for the customer and respond back the details.

===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Aditya Pareek      27/01/2020     EDGE-128406 | Update Deal Management UI to restrict MRO checkbox
2.        Laxmi Rahate       27/01/2020     EDGE-127421 | Change in representation of MRO Bonus
3.        Samish             21/02/2020     EDGE-120137 - Recontracting Credit Points
**********************************************************************************************************************************/
global with Sharing  class DP_DealQueryUtil  {
public String accountId;
public String opportunityId;
public List<Delegated_Pricing_Request__c> DealpriceRequest;

   /* public DP_DealQueryUtil(Id accountID){
        accountId = accountID;
    }*/
/*********************************************************************************************************************************
        Method Name:     DP_DealQueryUtil
        Description:    The method would return list of Deal_Pricing_Request__c records by querying on opportunities
===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Aditya Pareek      29/01/2020     EDGE-128406 | Update Deal Management UI to restrict MRO checkbox
**********************************************************************************************************************************/
    public static List<Delegated_Pricing_Request__c> getActiveDealsForAccount(String accID){
        List<Delegated_Pricing_Request__c> DPRList =[select id, Opportunity__c, Opportunity__r.Product_Type__c, Opportunity__r.Pricing_Method__c, Opportunity__r.StageName from Delegated_Pricing_Request__c where Opportunity__r.StageName = 'Closed Won' 
                                                     and Opportunity__r.Pricing_Method__c = 'Delegated Pricing' 
                                                     and Opportunity__r.Product_Type__c = 'Modular' 
                                                     //EDGE-127421 - Laxmi Addeed below check in the Query
                                                     and Opportunity__r.Account.id = :accID];
           system.debug('DPRList ::::'+DPRList );
            return DPRList;
        
    }
/*******************************************************************************************************************************************
        Method Name:     getDPROffers
        Description:    This method would use the private variable of List of DPR object and get Map of <String,List<DPR_Offer__c>> records
===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Aditya Pareek      29/01/2020     EDGE-128406 | Update Deal Management UI to restrict MRO checkbox
******************************************************************************************************************************************/
    public static List<DPR_Offer__c> getDPROffers(List<Delegated_Pricing_Request__c>  DPRList){
 
        List<DPR_Offer__c> dprOffers =new list<DPR_Offer__c>();
        Set<Id> dprIDs = (new Map<Id,SObject>(DPRList)).keySet();
        system.debug('dprIDs::::'+dprIDs);
   
        if(dprIDs !=null){
             dprOffers = [select id,Marketable_Offer__r.offer_Id__c, Delegated_Pricing_Request__c,Hardware_Option__c from DPR_Offer__c where Delegated_Pricing_Request__c in :dprIDs];  
             system.debug('dprOffers::::'+dprOffers);
        }
        return dprOffers ;
    }
/*******************************************************************************************************************************************
        Method Name:     isAnyActiveDealWithOffer
        Description:    The method should internally use above two methods to get list of DPR_Offer__c records.
===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Aditya Pareek      30/01/2020     EDGE-128406 | Update Deal Management UI to restrict MRO checkbox
2.        Laxmi Rahate       27/01/2020     EDGE-127421 | Added Account ID in Method Parameter

******************************************************************************************************************************************/
    public static boolean isAnyActiveDealWithOffer(String offerId,String accID) {
        Boolean IsActiveDeal=false;
        List<Delegated_Pricing_Request__c> DPReq = getActiveDealsForAccount(accID);
        if(DPReq != null){
           List<DPR_Offer__c> DPROffer = getDPROffers(DPReq);
            system.debug('DPROffer ::::'+DPROffer );
            for(DPR_Offer__c dell: DPROffer ){
                if(offerId== dell.Marketable_Offer__r.offer_Id__c){
                    IsActiveDeal=true;
                    return IsActiveDeal;
                }
             }   
            
        }
        return IsActiveDeal;
    }
/*******************************************************************************************************************************************
        Method Name:     isHardwareOptionOneFund
        Description:    The method should internally use above methods to check if there is any activeDeal for that offer. If no, return false
===============================================================================================================================
No.       Developer Name        Date            Story Description
1.        Aditya Pareek      30/01/2020     EDGE-128406 | Update Deal Management UI to restrict MRO checkbox
2.        Laxmi Rahate       27/01/2020     EDGE-127421 | Added Account ID in Method Parameter

******************************************************************************************************************************************/
    public static boolean isHardwareOptionOneFund(String offerId, String accID) {
        boolean isHardwareOption=false;
       // boolean IsActiveDealPresent = isAnyActiveDealWithOffer(offerId,accID);
        //if(IsActiveDealPresent){
            List<Delegated_Pricing_Request__c> dprList = getDPRReqListForAcc(accID);
            if(DPRList != null){
                for (Delegated_Pricing_Request__c dpr :dprList )   { 
                for(DPR_Offer__c offer: DPR.Delegated_Pricing_Request_Offers__r){
                    if (offerId == offer.Marketable_Offer__r.offer_Id__c && offer.Hardware_Option__c =='One Fund') {
                        isHardwareOption=true;
                        System.debug (' The Payment Option is OneFund!!');
                        return isHardwareOption;
                   }
                } 
            }
        }
        return isHardwareOption;
    }

    
       /*******************************************************************************************************************************************
    Method Name:    retrieveContractSignDate
    Description:    
    ===============================================================================================================================
    No.       Developer Name        Date            Story Description
    1.        Samish                21/02/2020      EDGE-120137 - Recontracting Credit Points

    ******************************************************************************************************************************************/
    public static Date retrieveContractSignDate(String offerId, String accID){
        Date contractSignedDate;
        List<Delegated_Pricing_Request__c> lstDPRequests = new List<Delegated_Pricing_Request__c>();
        lstDPRequests = getDPRReqListForAcc(accID);
        if(!lstDPRequests.isEmpty()){
            for (Delegated_Pricing_Request__c dpr :lstDPRequests){ 
                for(DPR_Offer__c offer: dpr.Delegated_Pricing_Request_Offers__r){
                    if (offerId == offer.Marketable_Offer__r.offer_Id__c && dpr.Contract_Acceptance_Date__c!=null){
                        contractSignedDate = Date.newinstance(dpr.Contract_Acceptance_Date__c.year(), dpr.Contract_Acceptance_Date__c.month(), dpr.Contract_Acceptance_Date__c.day());
                        break;
                    }
                } 
            }
        }

        return contractSignedDate;
    }
    
    
    
    /*******************************************************************************************************************************************
    Method Name:    getDPRReqListForAcc
    Description:    
    ===============================================================================================================================
    No.       Developer Name        Date            Story Description
    1.        Laxmi                 02/03/2020      EDGE-127421 - returns the DPR List along with Offer for the Account
******************************************************************************************************************************************/
    public static List<Delegated_Pricing_Request__c>  getDPRReqListForAcc(String accID){
        boolean isHardwareOption=false;
        List<Delegated_Pricing_Request__c> dprList = new List<Delegated_Pricing_Request__c>();
        if(String.isNotBlank(accID)){
            dprList = [SELECT id, Opportunity__c, Opportunity__r.Product_Type__c, 
                    Opportunity__r.Pricing_Method__c, Opportunity__r.StageName, Contract_Acceptance_Date__c,
                    (SELECT id,Marketable_Offer__r.offer_Id__c, Delegated_Pricing_Request__c,Hardware_Option__c from Delegated_Pricing_Request_Offers__r)
                    FROM Delegated_Pricing_Request__c 
                    WHERE Opportunity__r.StageName = 'Closed Won' 
                        and Opportunity__r.Pricing_Method__c = 'Delegated Pricing' 
                        and Opportunity__r.Product_Type__c = 'Modular' 
                        and Opportunity__r.Account.id = :accID];
        }

        return dprList;
    }
}
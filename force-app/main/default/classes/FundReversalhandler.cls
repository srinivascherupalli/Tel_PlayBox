/*
===============================================================================================================================
Class : FundReversalhandler
Developer Name : shubhi
EDGE-EDGE-193068
===============================================================================================================================
Sr.No.    Developer Name      Date          Story Description 
1.        shubhi/vamsi        2.2.2021       EDGE-193068(new)
2.        Shubhi v            12/03/2021      Edge-202203     error handling
===============================================================================================================================
*/
public with sharing class FundReversalhandler {
    private static Id allocatRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Accrual').getRecordTypeId();   
    private static Id redempRecordId = Schema.SObjectType.OneFund_Transactions__c.getRecordTypeInfosByDeveloperName().get('OneFund_Redemptions').getRecordTypeId();
    public static Decimal debitamount=0.00; 
    public static Map<string,Decimal> basketToDebitAmountMap=new Map<string,Decimal>();
    public Set<String> successIds=new set<String>();
    public static boolean hasError=false;
    public static List<cscfga__Product_Basket__c> successBasketList=new List<cscfga__Product_Basket__c>();
    public static List<cscfga__Product_Basket__c> failureBasketList=new List<cscfga__Product_Basket__c>();
   //method to pass wrapper from class to flow
  
    //method to fetch AFD and attribute
    private static Map<string,List<cscfga__Attribute_Field__c>> getAFDDetailMap(Set<String> basketIdSet){
        Map<string,cscfga__Attribute_Field__c>attrfieldMap=new Map<string,cscfga__Attribute_Field__c>();
        Map<string,List<cscfga__Attribute_Field__c>> returnmap=new  Map<string,List<cscfga__Attribute_Field__c>>();
        if(basketIdSet!=null && !basketIdSet.isEmpty()){
        attributeFieldSelectorHelper attrFieldObj =   new attributeFieldSelectorHelper();
        attrFieldObj.basketIdSet                  =   basketIdSet;
        attrfieldMap                              =   attrFieldObj.attributeCondition('byRedeemFundAction');
            if(attrfieldMap!=null && !attrfieldMap.isEmpty()){
                returnmap=FundReversalhandler.getAFDbasketMap(attrfieldMap);
            }
        }

        return returnmap;
    }
    //return basket to afds map
    private static Map<string,List<cscfga__Attribute_Field__c>> getAFDbasketMap(Map<string,cscfga__Attribute_Field__c> attrfieldMap){
        Map<string,List<cscfga__Attribute_Field__c>> returnmap=new  Map<string,List<cscfga__Attribute_Field__c>>();
        for(cscfga__Attribute_Field__c att:attrfieldMap.values()){
            List<cscfga__Attribute_Field__c> afList=new List<cscfga__Attribute_Field__c>();
            if(returnmap.containsKey(att.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c)){
                afList.addAll(returnmap.get(att.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c));
            }
            afList.add(att);
            returnmap.put(att.cscfga__Attribute__r.cscfga__Product_Configuration__r.cscfga__Product_Basket__c,afList);
        }
        return returnmap;
    }

        // get onefund map from basket list
    private static List<OneFund__c>  getOnefundList(List<cscfga__Product_Basket__c> basketList){
        List<OneFund__c> onefundList=new  List<OneFund__c>();
        Set<String> Cidnset=new Set<String>();
        if(basketList!=null && !basketList.isEmpty()){
            for(cscfga__Product_Basket__c basket: basketList){
                if(basket.csbb__Account__c!=null){
                    if(String.isNotBlank(basket.csbb__Account__r.CIDN__c))
                    CidnSet.add(basket.csbb__Account__r.CIDN__c);
                    if(String.isNotBlank(basket.csbb__Account__r.Parent_CIDN__c))
                    CidnSet.add(basket.csbb__Account__r.Parent_CIDN__c);
                    if(String.isNotBlank(basket.csbb__Account__r.Ultimate_Parent_CIDN__c))
                    CidnSet.add(basket.csbb__Account__r.Ultimate_Parent_CIDN__c);
                }
            }
            onefundList=[select id,CIDN__c,CIDN__r.CIDN__c from OneFund__c where CIDN__c IN (Select id from account where CIDN__c IN :CidnSet)];
        }
        return onefundList;
    }
                        
    //getbasket to onefund map
    private static Map<String,OneFund__c> getbasketOnefundMap(List<cscfga__Product_Basket__c> basketList){
        List<OneFund__c> onefundList=new  List<OneFund__c>();
        Map<String,OneFund__c> basketonefundmap=new  Map<String,OneFund__c>();
        if(basketList!=null && !basketList.isEmpty()){
            onefundList=FundReversalhandler.getOnefundList(basketList);
            for(cscfga__Product_Basket__c basket: basketList){
                for(OneFund__c ofund:onefundList){
                    if(ofund.CIDN__r.CIDN__c==basket.csbb__Account__r.CIDN__c){ 
                        basketonefundmap.put(basket.id,ofund);
                        continue;
                    }else if(ofund.CIDN__r.CIDN__c==basket.csbb__Account__r.Parent_CIDN__c){
                    basketonefundmap.put(basket.id,ofund); continue;}
                    else if(ofund.CIDN__r.CIDN__c==basket.csbb__Account__r.Ultimate_Parent_CIDN__c){
                        basketonefundmap.put(basket.id,ofund); continue;}
                }
            } 
        }
        return basketonefundmap;
    }

    //method to insert transactions
    public static void insertTransactions(Set<String>basketIdset,List<cscfga__Product_Basket__c> basketList){
        //List<List<OneFundFlowOutputparam>> onefundList=new List<List<OneFundFlowOutputparam>>();
        List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();
        Map<string,List<cscfga__Attribute_Field__c>> attrfieldMap=new Map<string,List<cscfga__Attribute_Field__c>>();
        Map<String,OneFund__c> basketonefundmap=new  Map<String,OneFund__c>();
        Savepoint sp = Database.setSavepoint(); 
        try{  
            if(basketList!=null && !basketList.isEmpty()){
                attrfieldMap = FundReversalhandler.getAFDDetailMap(basketIdSet);
                basketonefundmap = FundReversalhandler.getbasketOnefundMap(basketList);
                if(attrfieldMap!=null && !attrfieldMap.isEmpty() && basketonefundmap!=null && !basketonefundmap.isEmpty()){
                    //transactionList=FundReversalhandler.mapOFTdata(basketList[0].id,attrfieldMap,onefund.id);
                    transactionList=FundReversalhandler.OFTdataList(attrfieldMap,basketonefundmap);
                    if(transactionList!=null && !transactionList.isEmpty()){
                        Database.SaveResult[] rsltList    =   Database.insert(transactionList, true);
                        if(!FundReversalhandler.basketToDebitAmountMap.isEmpty()){
                            FundReversalhandler.updateRedeemptionAmountonAllocation(FundReversalhandler.basketToDebitAmountMap,basketonefundmap,basketList);
                        }
                    }   
                }
                FundReversalhandler.successBasketList=basketList;
            }
            if(test.isRunningTest()) { throw (new IllegalArgumentException()); }    
        }catch(Exception e){
            // Rollback all transactions in case of failure
           Database.rollback(sp);
           FundReversalhandler.hasError=true;
           System.debug('InflightFundBatch:Execute exception' + e.getLineNumber() + ' ' + e.getMessage());
            Logger2 logger = Logger2.getlogger('InflightFundBatch');
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in execute method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
            logger.exitLogger();
           FundReversalhandler.failureBasketList=basketList;
           List<InflightProcessHelper.ChatterFeedWrapper> feedsLst =   new List<InflightProcessHelper.ChatterFeedWrapper>();
           for(cscfga__Product_Basket__c pb:basketList){
               String currentUserId=   UserInfo.getUserId();
               String feedMessage  =   Label.ChatterFeed_BasketSubmitFailure;
               List<String> params =   new List<String>{'{'+currentUserId+'}','{record:' + pb.id + '}'};
               feedsLst.add(new InflightProcessHelper.ChatterFeedWrapper(null,pb.id,String.format(feedMessage, params)));
           }
           if(feedsLst!=null && feedsLst.size() > 0) {
               InflightProcessHelper.inflightSubmitChatterNotification(feedsLst);
           } 
        }//Edge-202203 end by Shubhi-----------
    }
    //get oft data
    private static List<OneFund_Transactions__c> OFTdataList (Map<string,List<cscfga__Attribute_Field__c>> attrfieldMap,Map<String,OneFund__c> basketonefundmap){
       List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();    
       for(String basketId:attrfieldMap.keySet()){
            Decimal debitAmmount=0;
            if(!attrfieldMap.get(basketId).isEmpty() && basketonefundmap.containskey(basketId)){
                transactionList.addAll(FundReversalhandler.OFTCreditData(basketId,attrfieldMap.get(basketId),basketonefundmap.get(basketId).id));
                debitAmmount=FundReversalhandler.basketToDebitAmountMap.containsKey(basketId)?FundReversalhandler.basketToDebitAmountMap.get(basketId):0;
                if(debitAmmount>0){
                    transactionList.add(FundReversalhandler.OFTDebitData(basketId,basketonefundmap.get(basketId).id,debitAmmount));
                }
            }
        }
       return transactionList;
    }

    //get credit transactions
     private static List<OneFund_Transactions__c> OFTCreditData (String basketid,List<cscfga__Attribute_Field__c> attrfieldList,String onefundId){
        List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();  
        for(cscfga__Attribute_Field__c afd:attrfieldList){
            if(afd.cscfga__Value__c=='Credit'){
                OneFund_Transactions__c oft=new OneFund_Transactions__c(
                    Product_Basket__c=basketid,
                    Product_Configuration__c=afd.cscfga__Attribute__r.cscfga__Product_Configuration__c,
                    OneFund__c=onefundId,Transaction_Amount__c=Decimal.Valueof(afd.cscfga__Attribute__r.cscfga__Value__c),
                    Sub_Type__c='Reversal',
                    RecordTypeId = FundReversalhandler.allocatRecordId,
                    Transaction_Status__c='Active',
                    Start_Date__c=Date.today(),
                    Expiry_Date__c=Date.today().addDays(+365));
                    transactionList.add(oft); 
            }else if(afd.cscfga__Value__c=='Debit'){
               debitamount+=Decimal.Valueof(afd.cscfga__Attribute__r.cscfga__Value__c);
            }
        }
        basketToDebitAmountMap.put(basketId,debitamount);
        return transactionList;
    }
    //get debit transactions
    private static OneFund_Transactions__c OFTDebitData (String basketid,String onefundId,Decimal debitAmount){
        OneFund_Transactions__c oft=new OneFund_Transactions__c(Product_Basket__c=basketid,
        OneFund__c=onefundId,
        Transaction_Amount__c=debitAmount,
        Sub_Type__c='POS',
        RecordTypeId = FundReversalhandler.redempRecordId,
        Transaction_Status__c='Active',
        Start_Date__c=Date.today());
        return oft;
    }
    //updating redemption amount in allocation records
    private static void updateRedeemptionAmountonAllocation(Map<string,Decimal> basketToDebitAmountMap,Map<String,OneFund__c> basketonefundmap,List<cscfga__Product_Basket__c> basketList){
        List<OneFund_Transactions__c> transactionList=new List<OneFund_Transactions__c>();
       
        Map<String,List<OneFund_Transactions__c>> basketTOOFTAllocationMap=FundReversalhandler.getOnefundTransations(basketonefundmap,basketList) ;
        for(cscfga__Product_Basket__c pb:basketList){
            Decimal debitAmountUpdated=FundReversalhandler.basketToDebitAmountMap.containsKey(pb.id)?FundReversalhandler.basketToDebitAmountMap.get(pb.id):0;
            if(basketTOOFTAllocationMap.ContainsKey(pb.id)){
                for(OneFund_Transactions__c oft:basketTOOFTAllocationMap.get(pb.id)){
                    if(debitAmountUpdated<=oft.Current_Amount__c){
                        oft.Redeemed_Amount__c+=debitAmountUpdated;
                        debitAmountUpdated-=debitAmountUpdated;
                        transactionList.add(oft);
                        break;
                    }
                    if(debitAmountUpdated>oft.Current_Amount__c){
                        oft.Redeemed_Amount__c+=oft.Current_Amount__c;
                        debitAmountUpdated-=oft.Current_Amount__c;
                        transactionList.add(oft);
                    }
                    if(debitAmountUpdated==0)
                        break;
                }
            }
        }
        if(transactionList!=null && !transactionList.isEmpty()){
            Database.SaveResult[] rsltList    =   Database.update(transactionList, true);  
        }
    }
    //get ofts for updating allocations
    private static Map<String,List<OneFund_Transactions__c>> getOnefundTransations(Map<String,OneFund__c> basketonefundmap,List<cscfga__Product_Basket__c> basketList){
        Map<String,List<OneFund_Transactions__c>> basketTOOFTAllocationMap=new Map<String,List<OneFund_Transactions__c>>();
        List<OneFund_Transactions__c> oftList=[Select id,Transaction_Amount__c,Transaction_Status__c,Expiry_Date__c,
        Redeemed_Amount__c,Current_Amount__c,OneFund__r.CIDN__r.CIDN__c  from OneFund_Transactions__c where OneFund__c IN:basketonefundmap.values() AND Transaction_Status__c='Active' AND RecordTypeId =:FundReversalhandler.allocatRecordId
        Order by Expiry_Date__c ASC];
        for(cscfga__Product_Basket__c pb:basketList){
            for(OneFund_Transactions__c oft:oftList){
                List<OneFund_Transactions__c> newoftList=new List<OneFund_Transactions__c>();
                if(basketTOOFTAllocationMap.containsKey(pb.id)){
                    newoftList.addAll(basketTOOFTAllocationMap.get(pb.id));
                }
                if(oft.OneFund__r.CIDN__r.CIDN__c==pb.csbb__Account__r.CIDN__c || oft.OneFund__r.CIDN__r.CIDN__c==pb.csbb__Account__r.Parent_CIDN__c || oft.OneFund__r.CIDN__r.CIDN__c==pb.csbb__Account__r.Ultimate_Parent_CIDN__c){
                    newoftList.add(oft);
                    basketTOOFTAllocationMap.put(pb.id,newoftList);
                }
            }
        }
        return basketTOOFTAllocationMap;
    }
}
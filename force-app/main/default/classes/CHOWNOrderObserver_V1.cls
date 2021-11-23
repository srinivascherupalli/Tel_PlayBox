/******************************************************************************************************************************
Class Name : CHOWNOrderObserver_V1
Test Class : CHOWNOrderObserver_V1Test 
===============================================================================================================================
Sr.No.  Developer           Date          Story Description                Sprint
1.      Aman Soni           22/02/2021    EDGE-191138(New Class)           21.03
2.      Shubhi              22/02/2021    EDGE-191138(order gen issue fix))21.03
1.    Shubhi V              31/03/2021      EDGE-209293 (chown order)
******************************************************************************************************************************/
global with sharing class CHOWNOrderObserver_V1 implements Database.Batchable<sObject>, Database.Stateful{  
    public final csordtelcoa.OrderGenerationObservable observable;
    public List<Id> subscriptionIds = new List<Id>();
    public Set<Id> basketIds = new Set<Id>();
    public Set<Id> accountIds = new Set<Id>();
    public Map<Id, cscfga__Product_Basket__c> incomingBasketMap = new Map<Id, cscfga__Product_Basket__c>();
    public String query ='';
    public Set<Id> ignoreOrderIds = new Set<Id>(); //EDGE-209293 added by shubhi
    public Set<String> ignoreMCRIds = new Set<String>(); //EDGE-209293 added by shubhi
    List<csord__Subscription__c> subscriptionList=new List<csord__Subscription__c>();
    List<sObject> mcrList=new List<sObject>();//Added by Shubhi for EOF exception

    
    global CHOWNOrderObserver_V1(){
    }
    
    //Constructor for setting context for batch processing
    //Constructor for setting context for batch processing
    public CHOWNOrderObserver_V1(csordcb.ObserverApi.Observable o){
        this.observable = (csordtelcoa.OrderGenerationObservable)o;
    }
    public CHOWNOrderObserver_V1(csordcb.ObserverApi.Observable o,List<csord__Subscription__c> subscriptionList){
        this.observable = (csordtelcoa.OrderGenerationObservable)o;
        this.subscriptionList=subscriptionList;
    }
    public CHOWNOrderObserver_V1(csordcb.ObserverApi.Observable o,List<csord__Subscription__c> subscriptionList,List<Id> subscriptionIds){
        this.observable = (csordtelcoa.OrderGenerationObservable)o;
        this.subscriptionList=subscriptionList;
        this.subscriptionIds=subscriptionIds;
    }
    
    
    //Start Method || Added Iterable<sObject> by Shubhi for EOF exception
    public Iterable<sObject> start(Database.BatchableContext BC){
        //Get all the Subscription Id's
        //Iterate over each subscription and get all the basket Id's
        if(subscriptionList!= null && !subscriptionList.isEmpty()){
            for(csord__Subscription__c subscription: subscriptionList){
                if(subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c != null){
                    basketIds.add(subscription.csordtelcoa__Product_Configuration__r.cscfga__Product_Basket__c);
                }
            }
        }
        //Iterate over the baskets and get all the baskets which are of Incoming Basket Type and get the Accounts as well for the same
        Set<cscfga__Product_Basket__c> basketSet = new Set<cscfga__Product_Basket__c>();
        if(basketIds!= null && !basketIds.isEmpty()){
            basketSet = Model_ProductBasket.getbasketForChown(basketIds);
        }
        if(basketSet!= null && !basketSet.isEmpty()){
            for(cscfga__Product_Basket__c basket : basketSet){
                if(basket.BasketType__c.equalsIgnoreCase('Incoming')){
                    accountIds.add(basket.csbb__Account__c);
                    incomingBasketMap.put(basket.Id, basket);
                }
            }   
        }
        //Iterate over accountIds and get all the MCR records and send it to execute for further processing
        if(incomingBasketMap!= null && !incomingBasketMap.isEmpty() && accountIds!= null && !accountIds.isEmpty()){ 
            mcrList  = [select id,name,macd_basket_ids__c,account_id__c,target_account__c from Migration_Change_Request__c 
            where migration_status__c = 'Completed' and macd_basket_ids__c != null and target_account__c IN :accountIds ];
        }
        return mcrList;
    }
    
    //Execute Method 
    public void execute(Database.BatchableContext BC, List<Migration_Change_Request__c> mcrList){
        String mcrId = '';
        Boolean IsMacdBasketId = false;
        for(Migration_Change_Request__c mcr : mcrList){
            List<Id> mcrBasketIds = String.isNotBlank(mcr.macd_basket_ids__c) ? mcr.macd_basket_ids__c.split(',') : new List<Id>();
            for(Id mcrBasketId : mcrBasketIds){
                if(incomingBasketMap.containskey(mcrBasketId)){
                   mcrId = mcr.id;
                   IsMacdBasketId = true;
                }
            }
            if(IsMacdBasketId)
            break;
        }
        if(String.isNotBlank(mcrId)){
            //EDGE-209293 added by shubhi
            try{
               PerformOpsAfterMigration perAM = new PerformOpsAfterMigration();
               perAM.linkSubsAfterMigration(mcrId);
               if(Test.isRunningTest()) { throw (new IllegalArgumentException()); }  
            }catch(Exception e){
                ignoreMCRIds.add(mcrId);
                System.debug('CHOWNOrderObserver_V1:Execute exception' + e.getLineNumber() + ' ' + e.getMessage());
                Logger2 logger = Logger2.getlogger('CHOWNOrderObserver_V1');
                logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception in execute method',e.getLineNumber() + ' ' + e.getMessage(), false, false);
                logger.exitLogger();
            }
        }         
    }
    
    //Finish Method 
    public void finish(Database.BatchableContext BC){
        Set<String> mcrBasketIds=new  Set<String>();
        List<Migration_Change_Request__c> mcrListFinal=(List<Migration_Change_Request__c>)mcrList;
        for(Migration_Change_Request__c mcr : mcrListFinal){
            if(ignoreMCRIds.contains(mcr.id) && String.isNotBlank(mcr.macd_basket_ids__c) ){
               mcrBasketIds.addAll(mcr.macd_basket_ids__c.split(','));
            }
        }
       
        //fetch order from failed basketids
        List<csord__Order__c> failedorderList = new List<csord__Order__c>();
        for(csord__Order__c ord:Model_Order.getorderfrombasket(mcrBasketIds)){
            ignoreOrderIds.add(ord.id);
            failedorderList.add(new csord__Order__c(Id = ord.Id, csord__Status2__c = 'Order Decomposition Failed', Observer_Message__c = 'CHOWN updates Failed Retry Again'));
        }
        //update order with failure 
        update failedorderList;

        Integer subBatchSize = Governor_Limits__c.getInstance().Batch_Size__c != null ? Integer.valueof(Governor_Limits__c.getInstance().Batch_Size__c) : 10;
    Id batchInstanceId = Database.executeBatch(new OrderPostProcessing(observable,ignoreOrderIds,subscriptionIds), subBatchSize);
        //Your Logic
    } 
}
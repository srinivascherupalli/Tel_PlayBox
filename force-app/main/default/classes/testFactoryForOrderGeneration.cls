/**********************************************************************************************
@description: this class implements methods to formulate data to test order generation 
framework
@Test: OrderBifurcationFramework_Test
***********************************************************************************************/


public class testFactoryForOrderGeneration {
    
    
    public static void orderUtilConfiguration(Integer bifurcationSize, boolean isFuture, boolean platformEnabled, String opportunityStages){
        testFactoryForOrderGeneration.orderUtilConfiguration(bifurcationSize, isFuture, platformEnabled, opportunityStages, true);
    }
    
    public static void orderUtilConfiguration(Integer bifurcationSize, boolean isFuture, boolean platformEnabled, String opportunityStages, boolean useProceeBuilder){
        order_Utilites__c ordUtil = new order_Utilites__c();
        ordUtil.basket_size_for_bifurcation__c = bifurcationSize;
        ordUtil.Use_Future_Method_for_Order_Generation__c = isFuture?isFuture:False;
        ordUtil.Use_Platform_Event__c = platformEnabled?platformEnabled:False;
        ordUtil.use_process_builder_as_subscriber__c = useProceeBuilder?useProceeBuilder:False;
        insert ordUtil;
        testFactoryForOrderGeneration.orderOptionsConfiguration(opportunityStages);
    }
    
    public static void orderOptionsConfiguration(String opportunityStages){
        csordtelcoa__Orders_Subscriptions_Options__c onsOptions = new csordtelcoa__Orders_Subscriptions_Options__c ();
        onsOptions.csordtelcoa__Initiate_order_generation_manually__c = true;
        onsOptions.csordtelcoa__Opportunity_Stages_creating_orders__c = opportunityStages;
        onsOptions.csordtelcoa__Order_Initial_State__c = 'Appointment Required';
        onsOptions.csordtelcoa__Service_Initial_State__c = 'Pending';
        onsOptions.csordtelcoa__Subscription_Initial_State__c = 'Pending';
        onsOptions.csordtelcoa__Enforce_Synchronisation__c = true;
        onsOptions.csordtelcoa__Basket_Linked_To_Opportunity__c = true;
        onsOptions.csordtelcoa__Generate_Orders_From_Basket__c = true;
        insert onsOptions;
        testFactoryForOrderGeneration.registerModule();
        
    }
    
    public static void registerModule(){
        CSORDCB.ModuleDefinition md = new CSORDCB.ModuleDefinition();
        md.uniqueName = 'CS Order Implementation Module Telco A';
        md.version = '1.0';
        md.dataCarrierClassnameT =
        csordtelcoa.OrderModuleImpl.OrderDataCarrier.class;
        md.moduleManagerClassnameT =
        csordtelcoa.OrderModuleImpl.OrderModuleManager.class;
        md.orderManagerClassnameT =
        csordtelcoa.OrderModuleImpl.OrderOrderManagerEx.class;
        md.stateTransitionManagerClassnameT =
        csordtelcoa.OrderModuleImpl.OrderStateTransitionManager.class;
        md.legalStateTransitions = 'order:initialised;'
        + 'order:initialised,Order Submitted;'
        + 'order:initialised,In Progress;'
        + 'order:Order Submitted,In Progress;'
        + 'solution:initialised;'
        + 'Subscription:initialised;'
        + 'Subscription:initialised,Subscription created;'
        + 'Service:initialised;'
        + 'Service:initialised,Service created';
        md.callbackResponderClassnameT =
        csordtelcoa.OrderModuleImpl.OrderCallbackResponder.class;
        CSORDCB.OrdersAndSubscriptions_API_V1 api = new
        CSORDCB.OrdersAndSubscriptions_API_V1();
        api.register(md);
    }
    
    public static List<Account> accountCreation (Integer numberOfRecords, String prefix ){
        List<Account> recordList = new List<Account>();
        for(Integer i=0; i< numberOfRecords; i++){
            Account rec = new Account(name = prefix + ' ' + i, Customer_Status__c = 'Active');
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    
    public static List<Opportunity> opportunityCreation (Integer numberOfRecords, String prefix, Id accountId, String productType, String stageName ){
        List<Opportunity> recordList = new List<Opportunity>();
        for(Integer i=0; i< numberOfRecords; i++){
            Opportunity rec = new Opportunity(name = prefix + ' ' + i, product_Type__c = productType, AccountId = accountId, StageName = stageName, CloseDate = System.today()+1);
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    public static List<cscfga__Product_Basket__c> basketCreation (Integer numberOfRecords, String stageName, Id accountId, Id opportunityId ){
        List<cscfga__Product_Basket__c> recordList = new List<cscfga__Product_Basket__c>();
        for(Integer i=0; i< numberOfRecords; i++){
            cscfga__Product_Basket__c rec = new cscfga__Product_Basket__c(Name = 'BT-000-000', csordtelcoa__Basket_Stage__c = stageName, csbb__Account__c = accountId, cscfga__Opportunity__c = opportunityId, csordtelcoa__Synchronised_with_Opportunity__c =true, csbb__Synchronised_With_Opportunity__c=true);
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    public static List<cscfga__Product_Configuration__c> productConfigurationCreation (Integer numberOfRecords, String pcName, Id basketId ){
        List<cscfga__Product_Configuration__c> recordList = new List<cscfga__Product_Configuration__c>();
        for(Integer i=0; i< numberOfRecords; i++){
            cscfga__Product_Configuration__c rec = new cscfga__Product_Configuration__c(Name = pcName+ ' ' +i, cscfga__Product_Basket__c = basketId);
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    public static List<csord__subscription__c> subscriptionCreation (Integer numberOfRecords, String subName, Id orderId, Id pcId ){
        List<csord__subscription__c> recordList = new List<csord__subscription__c>();
        for(Integer i=0; i< numberOfRecords; i++){
            csord__subscription__c rec = new csord__subscription__c(Name = subName+ ' ' +i, csord__Identification__c = subName+ '_' +i, csordtelcoa__Product_Configuration__c = pcId , csordtelcoa__Replacement_Subscription__c =null,   csord__Order__c = orderId, csord__Status__c='Incomplete');
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    
    public static List<csord__service__c> serviceCreation (Integer numberOfRecords, String serviceName, Id orderId, Id pcId, Id subId ){
        List<csord__service__c> recordList = new List<csord__service__c>();
        for(Integer i=0; i< numberOfRecords; i++){
            csord__service__c rec = new csord__service__c(Name = serviceName+ ' ' +i, csord__Identification__c = serviceName+ '_' +i, csordtelcoa__Product_Configuration__c = pcId , csord__Subscription__c = subId,   csord__Order__c = orderId, csord__Status__c='Incomplete');
            recordList.add(rec);
            
        }
        return recordList;
    }
    
    
    

}
/******************************************************************************************************
    *Class Name     : MigrateSubscriptionCustomUtility
    *Decription     : Utility class Invoked from observer classes TargetSolutions, SourceSolutions,
                         SourceSubscriptions,TargetAccounts and BeforeMigrationSubmit
    *Test Class     : MigrateSubscriptionsTest
    
   Sr.No.      Developer Name          Date            Story           Description
    1.            Jagadeswary        22/2/21            EDGE-195269    Validation around outgoing subs
    2.            Jagadeswary        22/2/21            EDGE-203019    CHOWN: Finish Migration Error handling
    3.            Vamsi              22-Feb-2021        Edge-152456(new)
    4.            Shubhi V            22-Feb-2021       EDGE-152457(new chown)  
    5.            Jagadeswary        16/4/21            EDGE-213796    Migrate Device
    6.              Gokul               19/05/21        EDGE-215259    Filter Subs within refund period
    7.              Gokul               26/07/21        EDGE-223208   Searching Solution for CHOWN by Mobile number,Sub name,Number
    8.              Gokul               11/08/21        DIGI-12242    Added If condition to filter the solution
    9.              Rashmi         21/09/21    EDGE-14125     CHOWN Quote & Contract for Adaptive Collaboration & Adaptive Collaboration Tenancy
********************************************************************************************************/

public with sharing class MigrateSubscriptionCustomUtility {

    public static final String ADAPTIVE_MOBILITY = 'Adaptive Mobility';
    //Method name : filterSolutions
    //Description : to filter solution records invoked from observer
    //To filter completed, no replaced solution and Adaptive mobility only
    public static Map<String, Object> filterSolutions(Map<String, Object> inputMap){

        List<csord__Solution__c> inputList = new List<csord__Solution__c>();
        string accountId;
        string userInputText;
        List<csord__Solution__c> listOfFilteredSol = new List<csord__Solution__c>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Set<Id> solutionsWithActiveSubscriptions = new Set<Id>();
        List<csord__Subscription__c> listOfFilteredSubs = new List<csord__Subscription__c>();//EDGE-215259
        List<csord__Subscription__c> finalSubsList = new List<csord__Subscription__c>();//EDGE-215259
        if(!inputMap.isEmpty()){
            if(inputMap.containskey('solutions'))
                inputList = (List<csord__Solution__c>)inputMap.get('solutions');   
            if(inputMap.containskey('accountId'))
                accountId = (string)inputMap.get('accountId');
            if(inputMap.containskey('userInputText'))
                userInputText = (string)inputMap.get('userInputText');
        }
        
        //215259  Use List to store the queried subs instead of looping it
        // EDGE-223208 - Start -- Searching Solution for CHOWN by Mobile number,Sub name,Number
        if(string.isBlank(userInputText)){
            for(csord__Subscription__c sub : [select id,name, csordtelcoa__Subscription_Number__c,serviceMSISDN__c,cssdm__solution_association__c,csord__status__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c,
                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c,
                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c,
                                            cssdm__solution_association__r.cssdm__solution_definition__c,
                                            Initial_Activation_DateTime__c from csord__Subscription__c where 
                                            cssdm__solution_association__c in:inputList
                                            and csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'
                                            and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                            and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                            and (csord__status__c = 'Active' or csord__status__c = 'Suspended')]){
                                                
                                            listOfFilteredSubs.add(sub);

            }
        }else{
            String userInputTextVal = '%'+String.escapeSingleQuotes(userInputText)+'%';
            set<id> subIds = new set<id>();
            for(Asset ast : [Select AssetID__c,Subscription__c from Asset where Subscription__r.csord__Account__c = :accountId and AssetID__c Like :userInputTextVal] ){
                subIds.add(ast.Subscription__c);
            }
            for(csord__Subscription__c sub : [select id,name, csordtelcoa__Subscription_Number__c,serviceMSISDN__c,cssdm__solution_association__c,csord__status__c,csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c,
                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c,
                                            csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c,
                                            cssdm__solution_association__r.cssdm__solution_definition__c,
                                            Initial_Activation_DateTime__c from csord__Subscription__c where 
                                            csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'
                                            and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                            and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                            and (csord__status__c = 'Active' or csord__status__c = 'Suspended')
                                            and csord__Account__c = :accountId 
                                            and (id IN : subIds OR cssdm__solution_association__c IN:inputList OR cssdm__solution_association__c iN:inputList OR name like : userInputTextVal OR csordtelcoa__Subscription_Number__c like : userInputTextVal OR serviceMSISDN__c like : userInputTextVal)]){
                                            
                                                listOfFilteredSubs.add(sub);
            }
        }
        /*for(csord__Subscription__c subscription: [select id,cssdm__solution_association__c,csord__status__c from csord__Subscription__c where 
                                                    cssdm__solution_association__c in:inputList
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                                    and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                                    and (csord__status__c = 'Active' or csord__status__c = 'Suspended')]){
                
                                                        listOfFilteredSubs.add(subscription); //EDGE-215259                                      
                
        }*/
        //EDGE-215259 -- Start
        finalSubsList = GenericUtilityClass.filterSubcriptionCoBARequest(listOfFilteredSubs);
        for(csord__Subscription__c sub : finalSubsList){
            if(sub.cssdm__solution_association__r.cssdm__solution_definition__c != null)
                solutionsWithActiveSubscriptions.add(sub.cssdm__solution_association__c);
        }
        //EDGE-215259 --End
        set<id> solutionIds = new set<id>();
        for(csord__Solution__c solution:inputList ){
            //DIGI-12242 - Added the below if confition
            if(solutionsWithActiveSubscriptions.contains(solution.id)){
                solutionIds.add(solution.id);
                listOfFilteredSol.add(solution);
            }
            
        }
        for(csord__Solution__c solution: [select id,name,csord__Status__c,CreatedDate,cssdm__replaced_solution__c,cssdm__solution_definition__r.Name from csord__Solution__c where ID IN : solutionsWithActiveSubscriptions]){
           if(!solutionIds.contains(solution.id)) 
               listOfFilteredSol.add(solution);
        }
        // EDGE-223208 - End   
        outputMap.put('solutions', listOfFilteredSol); 
        return outputMap;
    }
    
    //Method name : filterTargetSolutions
    //Method to filter target solution records invoked from observer
    //To filter completed, no replaced solution and Adaptive mobility only
    
    public static Map<String, Object> filterTargetSolutions(Map<String, Object> inputMap){
        List<csord__Solution__c> inputList = new List<csord__Solution__c>();   
        List<csord__Solution__c> listOfFilteredSol = new List<csord__Solution__c>();
        Map<String, Object> outputMap = new Map<String, Object>();
        Set<Id> solutionsWithActiveSubscriptions = new Set<Id>();
        Set<Id> solutionsWithReplacementSubscriptions = new Set<Id>();
        List<String> subscriptionsList = new List<String>();
        if(inputMap!=null && inputMap.containskey('solutions'))
           inputList = (List<csord__Solution__c>)inputMap.get('solutions');   

        if(inputMap.containskey('sourceSubscriptions') && inputMap.get('sourceSubscriptions') != null)
            subscriptionsList =   (List<String>)inputMap.get('sourceSubscriptions');   
        Set<String> offerIds = new Set<String>();
        
        for(csord__Subscription__c subscription: [select id,cssdm__solution_association__c, 
                                                    csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Offer_id__c 
                                                    from csord__Subscription__c 
                                                    where id in:subscriptionsList
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                                    and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Offer_id__c != null]){
            offerIds.add(subscription.csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Offer_id__c);
        }
        for(csord__Subscription__c subscription: [select id,cssdm__solution_association__c,csordtelcoa__Replacement_Subscription__c,csord__status__c from csord__Subscription__c 
                                                    where cssdm__solution_association__c in:inputList  
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                                    and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                                    and (csord__status__c = 'Active' or csord__status__c = 'Suspended')
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Offer_id__c != null
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Offer_id__c in:offerIds]){
               solutionsWithActiveSubscriptions.add(subscription.cssdm__solution_association__c);
            if(subscription.csordtelcoa__Replacement_Subscription__c != null)
               solutionsWithReplacementSubscriptions.add(subscription.cssdm__solution_association__c);
        } 
        for(csord__Solution__c solution: inputList){ 
           if(solutionsWithActiveSubscriptions.contains(solution.id) && 
              !solutionsWithReplacementSubscriptions.contains(solution.id))
               listOfFilteredSol.add(solution);
        }   
        outputMap.put('solutions', listOfFilteredSol); 
        return outputMap;
    }

    
    //Method name : filterSubscriptions

    //Method to filter subscription records invoked from observer
    //To filter Active,suspended and resumed only

    public static Map<String, Object> filterSubscriptions(Map<String, Object> inputMap){
        List<csord__Subscription__c> inputList =  new List<csord__Subscription__c>();
        List<csord__Subscription__c> listOfFilteredSubs = new List<csord__Subscription__c>();
        List<csord__Subscription__c> finalSubsList = new List<csord__Subscription__c>();//EDGE-215259
        Map<String, Object> outputMap = new Map<String, Object>();
        Set<Id> setOfActiveSubs = new Set<Id>();

        if(inputMap!=null && inputMap.containskey('subscriptions'))
           inputList = (List<csord__Subscription__c>)inputMap.get('subscriptions');  
        //subscription queried for additional fields
        ////EDGE-215259 - Use List to store the queried subs instead of looping it
        listOfFilteredSubs = [select id,name, csordtelcoa__Subscription_Number__c,serviceMSISDN__c ,csord__status__c,
                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Eligible_For_Hardware_Refund__c,
                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Is_Hardware__c,
                                csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Refund_Duration__c,
                                Initial_Activation_DateTime__c from csord__Subscription__c where 
                                id in:inputList
                                and csordtelcoa__Product_Configuration__r.ConfigurationType1__c != 'SolutionComponent'
                                and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                and (csord__status__c = 'Active' or csord__status__c = 'Suspended')];
        /*for(csord__Subscription__c subscription: [select id,csord__status__c from csord__Subscription__c where 
                                                    id in:inputList
                                                    and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Chown_Enabled__c = true
                                                    and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.Chown_Enabled__c = true
                                                    and (csord__status__c = 'Active' or csord__status__c = 'Suspended')]){
            setOfActiveSubs.add(subscription.id);

        }
        for(csord__Subscription__c subscription: inputList){
           if(setOfActiveSubs.contains(subscription.id)) 
               listOfFilteredSubs.add(subscription);
            }*/
        //EDGE-215259 -- Start
        finalSubsList = GenericUtilityClass.filterSubcriptionCoBARequest(listOfFilteredSubs);
        outputMap.put('subscriptions', finalSubsList);
        //EDGE-215259 -- End
        return outputMap;
    }

    //Method name : filterAccounts

    //Method to filter account records invoked from observer
    //To filter non partner accounts only

    public static Map<String, Object> filterAccounts(Map<String, Object> inputMap){
        List<Account> inputList =  new List<Account>();   
        List<Account> listOfFilteredAccs = new List<Account>();
        Map<String, Object> outputMap = new Map<String, Object>();
        if(inputMap!=null && inputMap.containskey('accounts'))
           inputList = (List<Account>)inputMap.get('accounts');   

        for(Account account: inputList){
           if(!account.isPartner){
               listOfFilteredAccs.add(account);
           }
        }   
        outputMap.put('accounts', listOfFilteredAccs);
        
        return outputMap;
    }

    //Method name : beforeMigrationSubmission

    //Method to invoke before migration submission from observer
    //To update baskets to sync and enriched before closing opp

    public static Map<String, Object> beforeMigrationSubmission(Map<String, Object> inputMap){
        OSLogic osInstance = new OSModuleConnector();
        Map<String, Object> outputMap = new Map<String, Object>();
        List<String> oppIds = new List<String>();
        List<Opportunity> oppList = new List<Opportunity>();
        Boolean isAdaptiveCollabTenancy = false;        
        String mcrid = (String)inputMap.get('mcrId');
        Migration_Change_Request__c mcrInstance = [
            select id, account_id__c, macd_basket_ids__c, migration_status__c,
                selected_source_solution_ids__c,target_account__c,
                selected_subscription_ids__c, target_solution_id__c,solution_definition__c,solution_definition__r.cssdm__product_definition__r.product_Specification__c
            from Migration_Change_Request__c
            where id = :mcrid
        ];
        List<Id> macdBasketIds = mcrInstance.macd_basket_ids__c != '' ?
            mcrInstance.macd_basket_ids__c.split(',') :
            new List<Id>();
        List<cscfga__Product_Basket__c> basketList = osInstance.getBaskets(macdBasketIds);
        isAdaptiveCollabTenancy = checkForAdaptiveCollabTenancy(mcrInstance); 
        // existing code will mark status as Enriched
        List<cscfga__Product_Basket__c> basketsToUpdate = new List<cscfga__Product_Basket__c>();
        for(cscfga__Product_Basket__c pb : [select id,csbb__Synchronised_With_Opportunity__c,csordtelcoa__Synchronised_with_Opportunity__c,cscfga__Opportunity__c 
                                            from cscfga__Product_Basket__c where id in:basketList]){
             if(isAdaptiveCollabTenancy){
                pb.csbb__Synchronised_With_Opportunity__c = true;
                pb.csordtelcoa__Synchronised_with_Opportunity__c = true;
             }
            if(pb.csbb__Synchronised_With_Opportunity__c && pb.csordtelcoa__Synchronised_with_Opportunity__c){
                CustomConfigurationOptions__c customOption = CustomConfigurationOptions__c.getInstance('ServiceDetailing');
                pb.csordtelcoa__Basket_Stage__c = (customOption !=null? customOption.Enrichment_Basket_Stage__c: 'Enriched');
                oppIds.add(pb.cscfga__Opportunity__c);
                basketsToUpdate.add(pb);
            }
            else{
                outputMap.put('status', false);
                outputMap.put('message', 'Please sync the basket via contract button on the incoming basket before proceeding ahead');
                if(!Test.IsRunningTest())
                    ConnectApiHelper.postFeedItemWithMentions(null, userInfo.getUserId(),'Hi {' + userInfo.getUserId()+ '}, Your chown completion request from {record:' +mcrInstance.account_id__c+ '} to {record:' +mcrInstance.target_account__c+'}, has failed. Please sync the basket via contract button on the incoming basket before proceeding ahead.');
                return outputMap;
            }
        }
        for(String oppId :oppIds){
            Opportunity opp =new Opportunity(id=oppid);
            opp.customer_accepted__c = true;
            opp.Closure_Reason__c = 'Won';
            opp.Won_Lost_Reason__c = 'Relationship - Other Corporate';
            oppList.add(opp);
        }
        try{
            if(!basketsToUpdate.isEmpty())
                update basketsToUpdate;  
            if(!oppList.isEmpty())
                update oppList;
                
            outputMap.put('status', true);
            outputMap.put('message', 'Baskets Updated');
        }catch(Exception e){    
            outputMap.put('status', false);
            outputMap.put('message', e.getmessage());

            ConnectApiHelper.postFeedItemWithMentions(null, userInfo.getUserId(),'Hi {' + userInfo.getUserId()+ '}, Your chown completion request from {record:' +mcrInstance.account_id__c+ '} to {record:' +mcrInstance.target_account__c+'}, has failed. Please Retry completing the migration. If error continues, please contact your admin.');

        }
        
        return outputMap;
    }
     //ngucEnabledforMigrtion 
    //EDGE-14125 CHOWN Quote & Contract for Adaptive Collaboration & Adaptive Collaboration Tenancy
    public static Boolean checkForAdaptiveCollabTenancy(Migration_Change_Request__c mcrInstance){
        
        Boolean isNgucChownEnabled = FeatureEligibilityChecker.determineFeatureEligiblity('NGUC_Chown','processNgucChown');
        if(isNgucChownEnabled){
            String adaptiveCollabTenancyOfferId = Offer_Id__mdt.getInstance('Unified_Communication_Tenancy')?.MasterLabel;// get offer Id for AC tenancy
            if(mcrInstance.solution_definition__c != null && mcrInstance.solution_definition__r.cssdm__product_definition__r.product_Specification__c == adaptiveCollabTenancyOfferId){
                return true;
            }
        }
        return false; 
    }
    

    //Method name : updateOpportunityFields

    //Method invoked from process builder to update opp fields with required values

    @InvocableMethod
    public static void updateOpportunityFields(List<Id> migrationIds){
        Set<String> setOfbasketIds = new Set<String>();//EDGE-152457
        String targetAcc;
        String sourceAcc;
        for(Migration_Change_Request__c migration: [select id,macd_basket_ids__c,target_account__c,account_id__c from Migration_Change_Request__c where id in:migrationIds]){
            String basketids = migration.macd_basket_ids__c;
            targetAcc = migration.target_account__c;
            sourceAcc = migration.account_id__c;
            Map<String,cscfga__Product_Basket__c> mapOfProdBskt = new Map<String,cscfga__Product_Basket__c>();
            if(basketids !=null){
                setOfbasketIds.addall(basketids.split(','));
            }
        }

        List<Opportunity> listOfOpportunities = new List<Opportunity>();
        Map<String, cscfga__Product_Basket__c> prodMap = new Map<String, cscfga__Product_Basket__c>();////EDGE-152457
        List<cscfga__Product_Basket__c> ProductbasketList=new List<cscfga__Product_Basket__c>();
        ProductbasketList=Model_ProductBasket.getProductBasketAccount(setOfbasketIds);//EDGE-152457
        //[select cscfga__Opportunity__c,cscfga__Opportunity__r.Account.Name,cscfga__Opportunity__r.Accountid from cscfga__Product_Basket__c where id in:listOfbasketIds]){;*/// commented by shubhi and moved to model class 
        for(cscfga__Product_Basket__c productBasket: ProductbasketList){
            prodMap.put(productBasket.csbb__Account__c, productBasket);
            if(productBasket.cscfga__Opportunity__c != null){
            Opportunity opp = new Opportunity(id = productBasket.cscfga__Opportunity__c);
            opp.type = 'CHOWN';
            opp.Product_Type__c = 'Modular';
            opp.recordtypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise - In Contract').getRecordtypeId();
            if(sourceAcc == productBasket.cscfga__Opportunity__r.Accountid){
                opp.Description__c = 'CHOWN Outgoing';
                opp.Name = 'CHOWN Outgoing '+productBasket.cscfga__Opportunity__r.Account.Name+' '+ system.now().format('dd/MM/YYYY hh:mm a');
            }
            else if(targetAcc == productBasket.cscfga__Opportunity__r.Accountid){
                opp.Description__c = 'CHOWN Incoming';
                opp.Name = 'CHOWN Incoming '+productBasket.cscfga__Opportunity__r.Account.Name+' '+ system.now().format('dd/MM/YYYY hh:mm a');
            }
            listOfOpportunities.add(opp);
            }
        }

        if(!listOfOpportunities.isEmpty())
            update listOfOpportunities;
        //Edge-152456,EDGE-152457 start---
        if(prodMap!=null && !prodMap.isEmpty()){
            MigrateSubscriptionCustomUtility.updateBasketWithChownDetails(prodMap,sourceAcc,targetAcc);
        }
        //Edge-152456,EDGE-152457 end--
        
    }
    //Edge-152456,EDGE-152457 start---
    // created by vamsi for updating basket fields at the time of basket creation Edge-152456
    // updated by shubhi for EDGE-152457
    private static void updateBasketWithChownDetails(Map<String, cscfga__Product_Basket__c> prodMap, String sourceAcc, String targetAcc)
    {
        if(String.isBlank(sourceAcc) || String.isBlank(targetAcc) || prodMap==null || prodMap.isEmpty())
            return ;
        List<cscfga__Product_Basket__c> ProductbasketUpdateList=new List<cscfga__Product_Basket__c>();
        String previousBasketId='';
        if(prodMap.containsKey(sourceAcc) && prodMap.get(sourceAcc)!=null && prodMap.containsKey(targetAcc)&& prodMap.get(targetAcc)!=null)
        {  
            cscfga__Product_Basket__c outgoingPB=MigrateSubscriptionCustomUtility.updateOutgoingBasket(prodMap.get(sourceAcc));
            previousBasketId=outgoingPB.id;
            ProductbasketUpdateList.add(outgoingPB);
            cscfga__Product_Basket__c incomingPB=MigrateSubscriptionCustomUtility.updateIngoingBasket(prodMap.get(targetAcc),previousBasketId);
            ProductbasketUpdateList.add(incomingPB);
        }
        if(ProductbasketUpdateList!=null && !ProductbasketUpdateList.isEmpty())
            update ProductbasketUpdateList;
    }
    private static cscfga__Product_Basket__c updateOutgoingBasket(cscfga__Product_Basket__c outgoingPB){
        outgoingPB.BasketType__c = 'Outgoing';
        outgoingPB.Description__c = 'CHOWN Outgoing Basket';//EDGE-152457
        return outgoingPB;
    }
    private static cscfga__Product_Basket__c updateIngoingBasket(cscfga__Product_Basket__c incomingPB,String previousBasketId){
        List<csconta__Frame_Agreement__c> frameAgrmt = [Select id,csconta__Account__c,csconta__Status__c from csconta__Frame_Agreement__c where csconta__Account__c =: incomingPB.csbb__Account__c AND csconta__Status__c = 'Active' order by createdDate limit 1];//EDGE-152457
        incomingPB.BasketType__c = 'Incoming';
        if(String.IsNotBlank(previousBasketId))incomingPB.csordtelcoa__Previous_Product_Basket__c = previousBasketId;//EDGE-152457
        if(frameAgrmt!=null && !frameAgrmt.isEmpty())incomingPB.csconta__Frame_Agreement__c=frameAgrmt[0].id; //EDGE-152457
        incomingPB.Description__c='CHOWN Incoming Basket';//EDGE-152457
        return incomingPB;
    }
    //Edge-152456,EDGE-152457 end--
}
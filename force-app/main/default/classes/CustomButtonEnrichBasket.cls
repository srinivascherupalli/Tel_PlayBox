/*********************************************************************************************************************************
*Class Name      :   CustomButtonEnrichBasket
*Story             :   EDGE-78293  Create PB to attach Dummy PC for Legacy Transition Services
*Developer         :   Rohit Tripathi
Test Class : CustomButtonEnrichBasketTest
*********************************************************************************************************************************
Sr.No.    Developer Name          Date          Story Description
1.        Rohit  Tripathi       6/6/2019         MDM Tenancy Enrichment to capture the Tenancy Primary Contact (EDGE-10637)
1.        Abinash Barik        07/27/2019        // EDGE-81085 Project Complexity field in CS to be selected based on the   complexity needs via Work Instructions
2.        Abinash Barik        02/08/2019        EDGE-104215/EDGE-81085 Project Management Fields are editable in product basket even before Contract Accepted stage
3.        Ritika Jaiswal       19/08/2019        EDGE - 81135 - cancel corporate mobile plus service(s)/entire CMP offer (capturing cancellation reason)
4.      Ritika Jaiswal         26/09/2019        Modifed query to fetch PCs, which are not of solution-type
5.      Hitesh Gandhi           02/01/2020       Removed method updateIPNetworkSpecifications as part of fix for EDGE-130570
6.      Rohit Tripathi          03/01/2020      Cyclomatic Complexity , DML Query inside For loop - Issues EDGE-127666,EDGE-127667
7.      Samish                  06/01/2020      Cyclomatic Complexity Issues EDGE-127666
8.      Rohit Tripathi          10/03/2020      INC000092247848 Delivery address details not added and saved before order submission
9.      Aruna Aware             08/04/2020      DPG-1692 Added for to check Enrichment for IOT Subscription
10      Dheeraj Bhatt           22/04/2020      EDGE-126433-Enable validation at NGUC product configuration level to have at least one number assigned before basket is enriched.
11      Laxmi Rahate            29/04/2020      EDGE-142321 - Skip Validation depending on the Shipping Fields
12      Rohit Tripahi           08/05/2020      EDGE-137753 No error is coming on Enriched button if enrichment is not done for UC tenancy offer
13      Aditya Pareek           15/05/2020      EDGE- 144971 Full Cancellation for NGUC
14      Shubhi/Aman             22/05/2020      EDGE-142085 To remove Billing Account validation at basket level
15    Laxmi Rahate      15/06/2020    EDGE-155254 On click of Enriched Button shoudl throw an error
16    Gnana          30/06/2020    EDGE-151354 - Added logic for validating Device Care Contact
17    Pallavi        21/07/2020    Spring 20 upgrade(commented depricated field)
18    Gnana          10/07/2020    EDGE-148725 - Added condition to validate DCC for MACD scenario
19    Abinash        11/08/2020    EDGE-153402 - <B2B-1370> Enable Number Reservation button on the Solution page for ngEM plans
20    Gokul           11/09/2020   EDGE-172954 -  Complete code refactoring to improve performance
21    Sharmila        25/09/2020    DPG-2890 - Added to check for Enrichment for VeloCloud Tenancy
22    Gokul         09/10/2020.   EDGE-183219 - Fixed the defect related to device care contact
22    Akanksha      19/10/2020     EDGE-174219- added SIMAvailabilityType Attr instead of shippingReq in checkAddressAndContactEnrichment
23    Dheeraj      19/10/2020     EDGE-174219- added validation on checkNextGenMobilityValid me thod
24.   Aman Soni     4/11/2020     EDGE-176693 While user is enriching the basket, Plan transitions revenue should be tagged as technology transformation revenue instead of incremental annuity
25.   Raviteja  09/11/2020  INC000094308347     Partner Order: After Basket Enriched, partner redirected to Basket screen with a different layout.
26.   Kamlesh    23/11/2020 INC000094293839    After clicking 'Enriched' ,Sales User redirected back to Basket Page instead of Opportunity page -- Fixed
27.   Aman Soni    05/01/2021 EDGE-196842    To Update OLI Order Type from Product Config SubType
28.   Sharmila    15/11/2020    DPG-3466  -  Added to check for Enrichment for SDWAN
29.  Sharmila    21/01/2021     DPG-3299  -  Added to check for Enrichment for SecureEdge
30. Gokul       11/02/2021   EDGE-200054 - Defect fix for Number reservation validation
31. Aman Soni       02/03/2021   INC000095150396  Apex CPU time limit exceeded 
32. Shubhi      14/04/2021   EDGE-213807
33.     Suyash Chiplunkar 02/08/2021 DIGI-4031 Enrichment Validations for SDWAN
34. shashank kulshreshtha   31-08-21    DIGI-15582   Order Enrichment validation for DMS
*/
global with sharing class CustomButtonEnrichBasket extends ValidateBasketStage{
    /**
    * performAction method overriden to provide enrich basket implementation
    * @param      basketId  The basket identifier
    * @return     String JSON format values
    */
    //EDGE-127666
    public static List<cscfga__Product_Configuration__c> prodConfListMain = new List<cscfga__Product_Configuration__c>();
    // EDGE-172954 - Below variables are added as a part of code RF - Gokul
    public static boolean tcPresent = false;
    public static Boolean EMValid = true;
    public static Boolean IOTValid = true;
    public static Boolean validateIOTEnrichment = true;
    public static Boolean validateEMEnrichment = true;
    public static boolean isBillingAccvalidationNeeded = false;
    public static Boolean isBillAccEnrichNeeded=false;
    public static Boolean nGenMobilityValidMethod = true;
    public static Boolean validateTenancyEnrichment = true;
    public static Boolean validateNextGenMobility = false;
    public static Boolean validateNextGenMobilityDCC = false;
    public static Boolean validateNGUCEnrichment = true;
    Public static Boolean IpSiteValid = true;
    public static Boolean validateEnrichment = false;//EDGE-200054
    public static List<cscfga__Product_Configuration__c> pcNextGenMobilityList = new List<cscfga__Product_Configuration__c>();

    public static List<cscfga__Product_Configuration__c> updatePcList = new List<cscfga__Product_Configuration__c>();
    public static List<cscfga__Product_Configuration__c> pcListIpSiteAndUnifiedComm = new List<cscfga__Product_Configuration__c>();
    public static List<cscfga__Product_Configuration__c> pcListWithNullRootConfig = new List<cscfga__Product_Configuration__c>();
    public static List<cscfga__Product_Configuration__c> pcListIpwithDmcatSpec = new List<cscfga__Product_Configuration__c>();
    Map<Id,Id> mapOfPCandCont = new Map<Id,Id>();
    Map<Id,contact> contactMap = new Map<Id,contact>();
    public static Set<Id> setOfContactIds = new Set<Id>();
    public String performAction(String basketId) {
        //EDGE-127666
        prodConfListMain = getPCsFromBasket (basketId);
        system.debug('prodConfListMain---'+prodConfListMain.size());
        String queryString = 'SELECT ';
        queryString += 'id, ';
        queryString += 'csordtelcoa__Basket_Stage__c, ';
        queryString += 'cscfga__Basket_Status__c, ';
        queryString += 'cscfga__Opportunity__r.StageName, ';
        queryString += 'Project_Manager_Contact_Number__c, ';
        queryString += 'cscfga__Opportunity__r.Type, ';
        queryString += 'Project_Complexity__c, ';
        queryString += 'Project_Manager__c, ';
        queryString += 'Project_Manager_Email__c, ';
        queryString += 'Project_Manager_User_ID__c, ';
        queryString += 'cscfga__Opportunity__r.RecordTypeId, ';
        queryString += 'cscfga__Products_Id_Qty_In_Basket__c,';
        queryString += 'Project_ID__c, ';
        queryString += 'PM_Required__c, ';
        queryString += 'Billing_Account__c, ';
        queryString += 'csbb__Account__c, ';
        queryString += 'cscfga__Opportunity__r.id, csordtelcoa__Change_Type__c ';
        queryString += 'FROM ';
        queryString += 'cscfga__Product_Basket__c ';
        queryString += 'WHERE ';
        queryString += 'id = :basketId';
        String ngucError = Label.FixedNumberValidation;
        cscfga__Product_Basket__c productBasket = Database.query(queryString);
            //INC000094308347
        String redirecturl=FeatureManagement.checkPermission('Partner_User')?'/s/sfdcpage/'+EncodingUtil.urlEncode(EnrichBasketConstants.REDIRECT_URL+productBasket.Id, 'UTF-8'):EnrichBasketConstants.REDIRECT_URL+ productBasket.Id;
        PageReference ref = new PageReference(redirecturl);
        //PageReference ref = new PageReference(EnrichBasketConstants.REDIRECT_URL + productBasket.Id);
        ref.setRedirect(true);
        
        //Added by Aman Soni for EDGE-176693 || Start
        //Invoke processTechTransRevenueForTransitionOLI only when basket is Valid
        //Custom setting used to disable all the validation rules for the current running user.
        Environment_Configurations__c ecCusSetting = Environment_Configurations__c.getInstance(UserInfo.getUserId()); 
        if(ecCusSetting.No_Validations__c == false){  
            ecCusSetting.No_Validations__c = true;
            upsert ecCusSetting;                
        }
        
        if(productBasket.cscfga__Basket_Status__c.equalsIgnoreCase('Valid')){       
            processTechTransRevenueForTransitionOLI(basketId);          
        }
        
        //After Basket sync, enable the validation rules for the current running user.
        if(ecCusSetting.Id != null && ecCusSetting.No_Validations__c == true){                      
            ecCusSetting.No_Validations__c = false;
            update ecCusSetting;
        }
        //Added by Aman Soni for EDGE-176693 || End
        
        //EDGE-117966 first validate basket so that we don't waste SOQLs on other checkes if basked shouldn't be moved forward
        /*String macdValidation = validateMACDbasket(productBasket, true);
        if (String.isNotEmpty(macdValidation)) {
        return EnrichBasketConstants.ERROR_STATUS + macdValidation + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
        }*/
        //RPLP-166 Changes : Start : changed the below for loop based on OfferName
        //EDGE-172954 - RF - Below assignment has been moved to getPCsFromBasket method - Gokul
        //Boolean tcPresent = ProductBasketUtil.doesBasketHaveOffer(productBasket, EnrichBasketConstants.TELSTRA_COLLABORATION);
        //EDGE-172954 - RF - These Methods are deprecated as we no longer using csoe__Commercial_Configuration__c - Gokul
        /*Boolean validateEnrichment ;//= checkNumberAndSiteEnrichment(basketId);
    Boolean validateMobileEnrichment = checkMobilityEnrichment(basketId);*/
        // Check Enrichment for MDM Tenacy PD
        //EDGE-172954 - RF - Below assignment has been moved to getPCsFromBasket method - Gokul
        //Boolean validateTenancyEnrichment = validateTenancyContact(basketId);
        if (!validateTenancyEnrichment)
            return EnrichBasketConstants.MDM_TENANCY_ERROR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
        //EDGE-172954 - RF - Below assignment has been moved to getPCsFromBasket method - Gokul
        //Boolean isBillingAccvalidationNeeded=checkBillingAccValidation(prodConfListMain);
        if(prodConfListMain!=null && !prodConfListMain.isEmpty() && isBillingAccvalidationNeeded)
            return EnrichBasketConstants.ERROR_STATUS1 +Label.Billing_Account_Required_Error  + EnrichBasketConstants.CLOSE_BRACKET;
        ////EDGE-172954 - RF - Below methods are moved from extension class to this class and refactored - Gokul
        String validateClosedWon = validateBasketStage(productBasket,EnrichBasketConstants.CLOSED_WON);
        String validateCancelled = validateBasketStage(productBasket,EnrichBasketConstants.CANCEL_BASKET);
        String retVal = validateClosedWon != null ? validateClosedWon : null;
        retVal = ((retVal == null) && validateCancelled != null) ? validateCancelled : retVal;
        //EDGE-127666 
        retVal = continueCheckEnrichment(basketId, tcPresent, productBasket,ngucError,ref,retVal);
        system.debug('retValfinal--'+retVal);
        if(updatePcList.size()>0)
            update updatePcList;
        return retVal;
    }
    @TestVisible
    public CustomButtonEnrichBasket(ApexPages.StandardController controller){
    }
    @TestVisible
    public CustomButtonEnrichBasket() {}
    
    /*  
     * Method Name      : getConfigListForTTRUpdate
     * Input Parameter  : basketId,transitionLabel
     * Return Parameter : returns List of product config
     * Description      : Update Technology Transformation Revenue from Incremental Annuity in case of Transition configs only and also OLI's orderType from respective PC subType  
     * Owner            : Aman Soni
     * Jira             : EDGE-176693 || EDGE-196842
     */
    public void processTechTransRevenueForTransitionOLI(String basketId){
    //List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>(); //Commented for EDGE-196842 by Aman Soni
    Map<Id, cscfga__Product_Configuration__c> pcMap = new Map<Id, cscfga__Product_Configuration__c>();//Added for EDGE-196842 by Aman Soni
    List<opportunityLineItem> oliLst = new List<opportunityLineItem>();
        try{
            if(String.isNotBlank(basketId)){
                pcMap = Model_ProductConfiguration.getConfigListForTTRUpdate(basketId, Label.ProductConfigSubType);
                //Added Order_Type__c,Product_Configuration__c for EDGE-196842 by Aman Soni
                if(!pcMap.isEmpty()){
                    for(opportunityLineItem oli : [Select id,name,Order_Type__c,Product_Configuration__c,Technology_Transformation_RevenueCur__c,New_Income_Revenue__c,cscfga__Attribute__c from opportunityLineItem where cscfga__Attribute__r.cscfga__Product_Configuration__c IN: pcMap.keySet()]){
                        if((oli.Technology_Transformation_RevenueCur__c == 0.00 || oli.Technology_Transformation_RevenueCur__c == null) && oli.New_Income_Revenue__c != null){
                            oli.Technology_Transformation_RevenueCur__c = oli.New_Income_Revenue__c;
                            oli.New_Income_Revenue__c = null;
                            //Added for EDGE-196842 by Aman Soni || Start
                            if(pcMap.containskey(oli.Product_Configuration__c)){
                                oli.Order_Type__c = pcMap.get(oli.Product_Configuration__c).subType__c;  
                            }
                            //Added for EDGE-196842 by Aman Soni || End            
                            oliLst.add(oli);
                        }
                    }
                    //INC000095150396 Fix || Aman Soni || Start
                    if(!oliLst.isEmpty()){
                        update oliLst;
                    }
                    //INC000095150396 Fix || Aman Soni || End                   
                }                                         
            }           
        }
        catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }       
    }
    
    @TestVisible
    private List<cscfga__Product_Configuration__c> getPCsFromBasket (String basketId){
       system.debug('getPCsFromBasket------');
  // added ConfigurationType1__c,Marketable_Offer__c in query for EDGE-147514 feature flagging
  ///EDGE-172954 - RF - Looping all the Pcs and Attributes to avoid unnecessary loops and queries as a part of refactoring - Gokul
    /*String queryString = 'SELECT ';
    queryString += 'id, ';
    queryString += 'Name, ';
    queryString += 'Type__c, ';
    queryString += 'csoe__Commercial_Configuration__c, ';
    queryString += 'cscfga__Configuration_Status__c, ';
    queryString += 'cscfga__Product_Definition__c ,';
    queryString += 'cscfga__Product_Definition__r.Name, ';
    queryString += 'ConfigurationType1__c ,';
    queryString += 'Marketable_Offer__c ,';
    queryString += 'Marketable_Offer__r.Config__c, ';
    queryString += 'cscfga__Product_Basket__r.Device_Care_Contact__c, ';
    queryString += 'cscfga__Product_Basket__r.Device_Care_Contact_Email__c ';
    queryString += 'FROM ';
    queryString += 'cscfga__Product_Configuration__c ';
    queryString += 'WHERE ';
    queryString += 'cscfga__Product_Basket__c = :basketId';
    // added ConfigurationType1__c,Marketable_Offer__c in query for EDGE-147514 feature flagging
return Database.query(queryString);*/
        list<cscfga__Product_Configuration__c> pclist = new list<cscfga__Product_Configuration__c>();
    //Added by Gokul for EDGE-183219
        set<string> attrNameSet = new set<string>{EnrichBasketConstants.TENANCY_PRIMARY_CONTACT,system.label.TenancyPrimaryContact,EnrichBasketConstants.CALL_RESTRICTION,EnrichBasketConstants.SITE_DELIVERY_ADDRESS,EnrichBasketConstants.ORDER_PRIMARY_CONTACT_ID, EnrichBasketConstants.TOTAL_USER_QTY,EnrichBasketConstants.TOTAL_NUMBERS,


            EnrichBasketConstants.PRIMARY_CONTACT_ID, EnrichBasketConstants.TECHNICAL_CONTACT_ID, EnrichBasketConstants.WIFI_ADD_ON_USER_MODIFIED,EnrichBasketConstants.SITE_DELIVERY_CONTACT,EnrichBasketConstants.PREFERRED_CRD,EnrichBasketConstants.NOT_BEFORE_CRD, EnrichBasketConstants.SHIPPING_REQUIRED,EnrichBasketConstants.DEVICE_SHIPPING,EnrichBasketConstants.SIM_AVAILABILITY_TYPE }; //EDGE-174219 Dheeraj added SIM_AVAILABILITY_TYPE

                for(cscfga__Product_Configuration__c pc : [Select id,Name,Type__c,cscfga__Root_Configuration__c,csoe__Commercial_Configuration__c,cscfga__Configuration_Status__c,cscfga__Product_Definition__c ,cscfga__Product_Basket__c,
                                                           cscfga__Product_Definition__r.product_Specification__c,
                                                           Quantity_Product_Configuration__c,Offername__c,cscfga__Product_Definition__r.Name,ConfigurationType1__c,Marketable_Offer__c ,Marketable_Offer__r.Config__c,cssdm__solution_association__c,cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,
                                                           cscfga__Product_Basket__r.Device_Care_Contact__c,cscfga__Product_Basket__r.Device_Care_Contact_Email__c,
                                                           cscfga__Product_Basket__r.RecordType.Name,csordtelcoa__Replaced_Product_Configuration__c, // added by shubhi for EDGE-213807
                                                           (SELECT id,name,cscfga__Display_Value__c,cscfga__Value__c,cscfga__Product_Configuration__c,cscfga__is_required__c,cscfga__Product_Configuration__r.Id 
                                                            FROM cscfga__Attributes__r WHERE name IN: attrNameSet) FROM cscfga__Product_Configuration__c 
                                                           WHERE cscfga__Product_Basket__c = :basketId]){  
                                                               if ((pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.MOBILE_SUBSCRIPTION || pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.IOT_SUBSCRIPTION) && pc.Type__c == EnrichBasketConstants.NEW_STR){
                                                                   validateEMEnrichment = checkAddressAndContactEnrichment(pc); 
                                                               system.debug('validateEMEnrichment----'+validateEMEnrichment);
                                                               }
                                                               if (pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.IOT_SUBSCRIPTION && pc.Type__c == EnrichBasketConstants.NEW_STR){
                                                                   validateIOTEnrichment = checkAddressAndContactEnrichmentIOT(pc);
                                                               system.debug('validateIOTEnrichment----'+validateIOTEnrichment);
                                                               }
                                                                 //enrichngUCBasket &  continueEnrichmentPart3
                                                                if(pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.IP_SITE || pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.UNIFIED_COMMUNICATION)
                                                                   pcListIpSiteAndUnifiedComm.add(pc);    
                                                                if(pc.cscfga__Product_Definition__r.product_Specification__c == EnrichBasketConstants.DMCAT_PRODUCTOFFERING_000304 && pc.cscfga__Product_Definition__r.name.contains(EnrichBasketConstants.IP))
                                                                   pcListIpwithDmcatSpec.add(pc);
                                                                //continueEnrichmetpart2
                                                               if(pc.cscfga__Root_Configuration__c == null && (pc.Type__c == EnrichBasketConstants.CANCEL || pc.Type__c == EnrichBasketConstants.PAID_OUT || pc.Type__c == EnrichBasketConstants.PAY_OUT)) 
                                                                   pcListWithNullRootConfig.add(pc); 
                                                                /*RPLP-166 Changes : Start : changed the below for loop based on OfferName
                                                                Boolean tcPresent = ProductBasketUtil.doesBasketHaveOffer(productBasket, EnrichBasketConstants.TELSTRA_COLLABORATION);
                                                                EDGE-128633. Using offername attribute instead of parent*/
                                                                if(pc.Offername__c != null && pc.Offername__c.contains(EnrichBasketConstants.TELSTRA_COLLABORATION)){
                                                                    tcPresent = true;      
                                                                }
                                                               if(pc.ConfigurationType1__c==EnrichBasketConstants.SOLUTION_COMPONENT && pc.Marketable_Offer__c!=null && pc.Marketable_Offer__r.Config__c!=null && !isBillAccEnrichNeeded)
                                           isBillingAccvalidationNeeded = checkBillingAccValidation(pc);
                                                                // EDGE-155254 - nextGenMobility

                                                               if ((pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.TENANCY_BRODSOFT_TENANCY|| pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.BUSINESS_CALLING) && pc.Type__c == EnrichBasketConstants.NEW_STR && validateNGUCEnrichment)

                                                                validateNGUCEnrichment = checkTenancyDetailsEnrichment(pc);
                                                                //validateNextGenMobility
                                                               if (pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.NEXT_GENERATION_MOBILE_DEVICE || pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.ENTERPRISE_MOBILITY_PLAN || pc.cscfga__Product_Definition__r.name == EnrichBasketConstants.MOBILE_DEVICE_CARE ){
                                                                pcNextGenMobilityList.add(pc);
                                                                checkNextGenMobilityValid(pc);
                                                               }
                                                               if (pc.Name == system.label.Tenancy && validateTenancyEnrichment)
                                                                   validateTenancyEnrichment = validateTenancyContact(pc);
                                                               //getDeviceCareContact
                                                               setOfContactIds.add(pc.cscfga__Product_Basket__r.Device_Care_Contact__c);
                                                               pclist.add(pc);
                                                           }
        return pclist;
    }
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    @TestVisible
    private Boolean validateTenancyContact(cscfga__Product_Configuration__c pc) {
        system.debug('validateTenancyContact------');
        /* Below code is part of  EDGE-10637 MDM Tenancy Enrichment to capture the Tenancy Primary Contact
        EDGE-127666
        Adding all Tenancy PC to a list for checking Attribute Value.
        Checking Attribute value for each PC , if value is blank then mark the Tenancy valid flag as False*/
        Boolean TenancyValid = true;
        for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r) {
            if (attr.cscfga__Value__c == '' && attr.Name == system.label.TenancyPrimaryContact ) 
                TenancyValid = false;
        }
        return TenancyValid;
    }
    ////EDGE-172954-RF - Below method is not utilised  - Gokul
    /*@TestVisible private Boolean checkngUCNumberEnrichment(String basketId) {
        //Enrichment check asked for ngUC Site
        //Returning true if Enrichment is ok or not required
    System.debug('RPLP:56 - inside checkngUCNumberEnrichment..');
    //EDGE-127666
        List<cscfga__Product_Configuration__c> prodConfList = prodConfListMain;
        String prodConfig = EnrichBasketConstants.UNIFIED_COMMUNICATION;
        List<cscfga__Product_Configuration__c> pcIPSiteList = new List<cscfga__Product_Configuration__c>();
        for (cscfga__Product_Configuration__c pc : prodConfList) {
            if (pc.Name == prodConfig)
                pcIPSiteList.add(pc);
        }
        for (cscfga__Product_Configuration__c pc : prodConfList)
        {
            if (pc.Name == prodConfig && pc.cscfga__Configuration_Status__c == EnrichBasketConstants.VALID) {
                return true;
            }
        }
    System.debug('RPLP:56 - inside checkngUCNumberEnrichment..pcIPSiteList'+pcIPSiteList);
        Boolean checkSite; Boolean checkNumbers; Boolean checkCRD; Boolean IpSiteValid = true;
        for (cscfga__Product_Configuration__c IPSite : pcIPSiteList) {
            checkSite = false;checkNumbers = false;checkCRD = false;
            if (IPSite.Type__c == EnrichBasketConstants.CANCEL){checkNumbers = true;checkCRD = true;}
            for (cscfga__Product_Configuration__c pc : prodConfList) {
        System.debug('Inside for loop prodConfList...'+prodConfList);
        System.debug('Inside for loop pc.csoe__Commercial_Configuration__c...'+pc.csoe__Commercial_Configuration__c);
                System.debug('Inside for loop IPSite.Id...'+IPSite.Id);
                //EDGE-127667
                //if (pc.csoe__Commercial_Configuration__c == IPSite.Id) {
                    //if (pc.Name == 'Site Details')
                      //  checkSite = true;
                    //else
                    if ( (pc.csoe__Commercial_Configuration__c == IPSite.Id) && (pc.Name == 'Reserve Numbers'  || (IPSite.Type__c == 'Modify' && pc.Name == 'Reserve Numbers') || (IPSite.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Reserve Numbers')))
                        checkNumbers = true;
                    else if ( (pc.csoe__Commercial_Configuration__c == IPSite.Id) && (pc.Name == 'Customer Requested Dates' || (IPSite.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Customer Requested Dates')))
                        checkCRD = true;
               // }
            }
      System.debug('RPLP:166 - checkngUCNumberEnrichment..Numbers'+checkNumbers+'..CRD..'+checkCRD);
            //if (!(checkSite && checkNumbers && checkCRD)) {
             if (!(checkNumbers && checkCRD)) {
                IPSite.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;IpSiteValid = false;
            }
        }
    System.debug('RPLP:166 - checkngUCNumberEnrichment..IpSiteValid'+IpSiteValid);
        if (!IpSiteValid)
            update pcIPSiteList; return IpSiteValid;
    }*/
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    //EDGE-137753 Code End  --> Added By Rohit T
    //////////////////////////////////////////////////// EDGE-147514 start//////////////////////////////////////
    @TestVisible
    private Boolean checkBillingAccValidation(cscfga__Product_Configuration__c pc){
        system.debug('checkBillingAccValidation------');
        Map<String,Object> mapAllConfigs;
        mapAllConfigs=(Map<String,Object>) JSON.deserializeUntyped(pc.Marketable_Offer__r.Config__c);
        if(mapAllConfigs.containsKey(EnrichBasketConstants.VALIDATE_BILL_ACC_ENRICH) && !(Boolean)mapAllConfigs.get(EnrichBasketConstants.VALIDATE_BILL_ACC_ENRICH)){
            isBillAccEnrichNeeded=true;
        }
        return isBillAccEnrichNeeded;  
    }
    //EDGE-172954-RF - Below method has been added from ValidateBasketStage and made it as generic to accept both closedwon and cancel status - Gokul
    @TestVisible
    private String validateBasketStage(cscfga__Product_Basket__c productBasket,string stage){
        system.debug('validateBasketStage------');
        string returnString;
        CustomConfigurationOptions__c customSetting;
        try{
            if(stage == EnrichBasketConstants.CLOSED_WON){
                customSetting = CustomConfigurationOptions__c.getValues(EnrichBasketConstants.CLOSED_WON1);
                returnString = EnrichBasketConstants.ERROR_STATUS1+Label.Basket_Closed_Won_Error+EnrichBasketConstants.CLOSE_BRACKET;
            }
            else{
                customSetting = CustomConfigurationOptions__c.getValues(EnrichBasketConstants.CANCEL_BASKET);
                returnString = EnrichBasketConstants.ERROR_STATUS1+Label.Cancelled_Basket+EnrichBasketConstants.CLOSE_BRACKET;
            } 
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            if(productBasket.csordtelcoa__Basket_Stage__c == basketStage)
                return returnString;
            else 
                return null;
        } catch(Exception e){
            System.debug(e.getStackTraceString());
            Logger.getLogger(ValidateBasketStage.class).debug(e);
            return EnrichBasketConstants.ERROR_STATUS+Label.Validate_Basket_Stage_Exception+EnrichBasketConstants.CLOSE_BRACKET;
        }
    }
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    //INC000092247848 Start --> Method to check Enrichment for Enterprise Mobile Subscription
    @TestVisible
    private Boolean checkAddressAndContactEnrichment(cscfga__Product_Configuration__c pc) {
        system.debug('checkAddressAndContactEnrichment------');
        //  DPG-1692 Added for to check Enrichment for IOT Subscription       
        //EDGE-142321 Changes
        String shippingRequired = '';
        String simAvailabilityType = ''; // EDGE-174218 added
        String deviceShipping ='';
        List <cscfga__Attribute__c> subList;
        Map<String, String> attrMapTMP = new Map<String, String>();
        //Changes END
        // Laxmi - EDGE-142321 - Added ShippingRequired and Device Shipping in below query and changed the logic of cecking the values
        // IF ShippingRequired and DeviceShipping both are false Delivery Details arent mandatory
        subList = new List <cscfga__Attribute__c> ();
        // EDGE-174218 replaced ShippingRequired with SIM_AVAILABILITY_TYPE
        for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
            if (attr.cscfga__Product_Configuration__c == pc.id && (attr.name == EnrichBasketConstants.CALL_RESTRICTION || attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT || attr.name == EnrichBasketConstants.PREFERRED_CRD || attr.name == EnrichBasketConstants.NOT_BEFORE_CRD || attr.name == EnrichBasketConstants.SIM_AVAILABILITY_TYPE || attr.name == EnrichBasketConstants.DEVICE_SHIPPING)){
                attrMapTMP.put (attr.name, attr.cscfga__Value__c);
                subList.add (attr);
            }
        }
        // system.debug('attrMapTMP--'+attrMapTMP);
        if (attrMapTMP.size()>0){
            if (attrMapTMP.containsKey(EnrichBasketConstants.SIM_AVAILABILITY_TYPE) && String.isNotBlank(attrMapTMP.get(EnrichBasketConstants.SIM_AVAILABILITY_TYPE)))
                simAvailabilityType = attrMapTMP.get (EnrichBasketConstants.SIM_AVAILABILITY_TYPE);
            if (attrMapTMP.containsKey(EnrichBasketConstants.DEVICE_SHIPPING) && String.isNotBlank(attrMapTMP.get(EnrichBasketConstants.DEVICE_SHIPPING)))
                deviceShipping = attrMapTMP.get(EnrichBasketConstants.DEVICE_SHIPPING);
        }
        for (cscfga__Attribute__c attrChk : subList){
            system.debug('simAvailabilityType--'+simAvailabilityType);
            system.debug('deviceShipping--'+deviceShipping);
            system.debug('attrChk.name--'+attrChk.name);
            system.debug('attrChk.cscfga__Value__c--'+attrChk.cscfga__Value__c);
            if(simAvailabilityType.containsIgnoreCase('new') && !(deviceShipping == EnrichBasketConstants.FALSE_STR))
            {
                if ((attrChk.name == EnrichBasketConstants.CALL_RESTRICTION || attrChk.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attrChk.name ==       EnrichBasketConstants.SITE_DELIVERY_CONTACT || attrChk.name == EnrichBasketConstants.PREFERRED_CRD ||attrChk.name == EnrichBasketConstants.NOT_BEFORE_CRD ) && (String.isBlank ( attrChk.cscfga__Value__c )))
                {
                        EMValid = false;
                }
            }
            else
            {
                if ((attrChk.name == EnrichBasketConstants.PREFERRED_CRD ||attrChk.name == EnrichBasketConstants.NOT_BEFORE_CRD || attrChk.name == EnrichBasketConstants.CALL_RESTRICTION ) && (String.isBlank ( attrChk.cscfga__Value__c )))
                {
                        EMValid = false;
                }
            }
        }
        return EMValid;
    }
    //EDGE-172954-RF - below method has been merged with checkAddressAndContactEnrichment as a part of code refactoring - Gokul
   /* @TestVisible
    private Boolean checkEMValid(List<cscfga__Product_Configuration__c> pcMobileSubscriptionList){
        Boolean deliveryAddress; Boolean deliveryContact; Boolean checkCRD; Boolean EMValid = true;
        //EDGE-142321 Changes
        String shippingRequired = '';
        String deviceShipping ='';
        List <cscfga__Attribute__c> subList;
        Map<String, String> attrMapTMP = new Map<String, String>();
        //Changes END
        // Laxmi - EDGE-142321 - Added ShippingRequired and Device Shipping in below query and changed the logic of cecking the values
        // IF ShippingRequired and DeviceShipping both are false Delivery Details arent mandatory
        List <cscfga__Attribute__c> attrList =  [select id , name , cscfga__Product_Configuration__c , cscfga__Display_Value__c , cscfga__Value__c from cscfga__Attribute__c where name in (EnrichBasketConstants.CALL_RESTRICTION,EnrichBasketConstants.SITE_DELIVERY_ADDRESS,EnrichBasketConstants.SITE_DELIVERY_CONTACT,EnrichBasketConstants.PREFERRED_CRD,EnrichBasketConstants.NOT_BEFORE_CRD, EnrichBasketConstants.SHIPPING_REQUIRED,EnrichBasketConstants.DEVICE_SHIPPING) and cscfga__Product_Configuration__c in :pcMobileSubscriptionList order by cscfga__Product_Configuration__c];
        Map<id, cscfga__Attribute__c> attrMap = new Map<id, cscfga__Attribute__c>();
        for (cscfga__Attribute__c attribute : attrList ){
            attrMap.put (attribute.cscfga__Product_Configuration__c, attribute);
        }
        for (cscfga__Product_Configuration__c pc : pcMobileSubscriptionList)
        {
            subList = new List <cscfga__Attribute__c> ();
            for (cscfga__Attribute__c attr : attrList){
                if (attr.cscfga__Product_Configuration__c == pc.id)
                {
                    attrMapTMP.put (attr.name, attr.cscfga__Value__c);
                    subList.add (attr);
                    //System.debug ( 'attr.name, attr.cscfga__Value__c ' + attr.name + ' ----' + attr.cscfga__Value__c);
                }
            }
            if (attrMapTMP.size()>0){
                if (attrMapTMP.containsKey(EnrichBasketConstants.SHIPPING_REQUIRED) && String.isNotBlank(attrMapTMP.get(EnrichBasketConstants.SHIPPING_REQUIRED)))
                {
                    shippingRequired = attrMapTMP.get (EnrichBasketConstants.SHIPPING_REQUIRED);
                    //system.debug ('shippingRequired    ' + shippingRequired);
                }
                if (attrMapTMP.containsKey(EnrichBasketConstants.DEVICE_SHIPPING) && String.isNotBlank(attrMapTMP.get(EnrichBasketConstants.DEVICE_SHIPPING)))
                {
                    deviceShipping = attrMapTMP.get(EnrichBasketConstants.DEVICE_SHIPPING);
                    //system.debug ('DeviceShipping    ' + shippingRequired);
                }
            }
            for (cscfga__Attribute__c attrChk : subList){
                if ( (shippingRequired == EnrichBasketConstants.FALSE_STR ) && (deviceShipping == EnrichBasketConstants.FALSE_STR)){
                    if ( (attrChk.name == EnrichBasketConstants.PREFERRED_CRD ||attrChk.name == EnrichBasketConstants.NOT_BEFORE_CRD || attrChk.name == 'Call Restriction' ) && (String.isBlank ( attrChk.cscfga__Value__c )) ){
                        EMValid = false;
                        System.debug ( 'Details Missing both attributes are False');
                    }
                }else {
                    if ( ( attrChk.name == 'Call Restriction' || attrChk.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attrChk.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT || attrChk.name == EnrichBasketConstants.PREFERRED_CRD ||attrChk.name == EnrichBasketConstants.NOT_BEFORE_CRD ) && (String.isBlank ( attrChk.cscfga__Value__c ))){
                        EMValid = false;
                        System.debug ( 'Details Missing both attributes are NOT false');
                    }
                }
            }
        }
        return EMValid;
    }*/
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    //INC000092247848 End
    // DPG-1692 & DPG-1723 Added for to check Enrichment for IOT Subscription & Incorporate review comments from governance forum
    @TestVisible
    private Boolean checkAddressAndContactEnrichmentIOT(cscfga__Product_Configuration__c pc) {
        system.debug('checkAddressAndContactEnrichmentIOT------');
            for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
                system.debug('attr.name---'+attr.name);
                system.debug('attr.cscfga__Value__c---'+attr.cscfga__Value__c);
                if ((attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.PREFERRED_CRD || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT || attr.name == EnrichBasketConstants.NOT_BEFORE_CRD) && (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null ))
                    IOTValid = false;
            }
        return IOTValid;
    }
    //EDGE-172954-RF - below method has been merged with checkAddressAndContactEnrichmentIOT as a part of code refactoring - Gokul
    // DPG-1692 & DPG-1723 Added for to check Enrichment for IOT Subscription & Incorporate review comments from governance forum
   /* @TestVisible
    private Boolean checkIOTValid(Set<Id> pcIOTSubscriptionList){
    Boolean deliveryAddress; Boolean deliveryContact; Boolean checkCRD; Boolean IOTValid = true;
    List <cscfga__Attribute__c> attrList =  [select id , name , cscfga__Display_Value__c , cscfga__Value__c from cscfga__Attribute__c where name in (EnrichBasketConstants.SITE_DELIVERY_ADDRESS,EnrichBasketConstants.SITE_DELIVERY_CONTACT,EnrichBasketConstants.PREFERRED_CRD,EnrichBasketConstants.NOT_BEFORE_CRD) and cscfga__Product_Configuration__c in :pcIOTSubscriptionList];
        if (attrList.size()>0){
        for (cscfga__Attribute__c attr : attrList){
            if (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null ){
                IOTValid = false;
            }
        }
    }
    return IOTValid;
}*/

    // DPG-2890  Added to check Enrichment for VeloCloud Tenancy 
    @TestVisible
     private Boolean checkContactDetailsVelo(String basketId) {
        List<cscfga__Product_Configuration__c> veloConfList = prodConfListMain;
        Set<Id> vcVeloSubscriptionSet = new Set<Id>();
         for (cscfga__Product_Configuration__c vc : veloConfList) {
             
            if (vc.cscfga__Product_Definition__r.Name == System.Label.Velo_PDName && vc.Type__c == 'New')
                vcVeloSubscriptionSet.add(vc.Id);
        }
        Boolean veloValid = true;
        if (vcVeloSubscriptionSet.size()>0 )
            veloValid = checkVeloValid(vcVeloSubscriptionSet); 
        return veloValid;
    }
    // DPG-2890 Added for to check Enrichment for VeloCloud Tenancy
        @TestVisible
        private Boolean checkVeloValid(Set<Id> vcVeloSubscriptionList){
        Boolean contactDetails; Boolean veloValid = true;
        List <cscfga__Attribute__c> attrVeloList =  [select id , name , cscfga__Value__c from cscfga__Attribute__c where name in ('Tenancy Primary Contact') and cscfga__Product_Configuration__c in :vcVeloSubscriptionList];
            
            if (attrVeloList.size()>0){
            for (cscfga__Attribute__c attr : attrVeloList){ 
                if (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null ){
                    veloValid = false;
                }           
            }
        }
           return veloValid;
    }
    
    // DPG-3466  Added to check Enrichment for SD-WAN Tenancy 
    @TestVisible
     private Boolean checkContactDetailsSdwan(String basketId) {
        List<cscfga__Product_Configuration__c> sdwanConfList = prodConfListMain;
        Set<Id> scSdwanSubscriptionSet = new Set<Id>();
         for (cscfga__Product_Configuration__c sc : sdwanConfList) {   
            if (sc.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_ADAPT_OFFER && sc.Type__c == 'New'){
                scSdwanSubscriptionSet.add(sc.Id);
            }
        }
        Boolean sdwanValid = true;
        if (scSdwanSubscriptionSet!= NULL && !scSdwanSubscriptionSet.IsEmpty()){
            sdwanValid = checkSDWANValid(scSdwanSubscriptionSet); 
        }
        return sdwanValid;
    }

    
    // DPG-3466 && DIGI-4031 Added to check Enrichment for SD-WAN Tenancy 
    @TestVisible
    public Boolean checkSDWANValid(Set<Id> scSDWANSubscriptionList){
        Boolean contactDetails; Boolean sdwanValid = true;
        Set<Id> contactID = new Set<Id>();
        List <cscfga__Attribute__c> attrSDWANList = [SELECT        Id 
                                                                ,   name 
                                                                ,   cscfga__Value__c 
                                                    FROM cscfga__Attribute__c 
                                                    WHERE name in ('SiteDeliveryContact','SiteDeliveryAddress') 
                                                    AND cscfga__Product_Configuration__c IN :scSDWANSubscriptionList];
            
        for (cscfga__Attribute__c attr : attrSDWANList){
            if (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null ){
                sdwanValid = false;
                break;
            }
            if(attr.Name == 'SiteDeliveryContact'){
                contactID.add(attr.cscfga__Value__c);
            }
        }
        if(contactID != NULL && !contactID.isEmpty() && sdwanValid == true)  {
            List<Contact> listOfContacts = [SELECT      Id 
                                                    ,   FirstName
                                                    ,   LastName
                                                    ,   Phone
                                                    ,   Email 
                                            FROM Contact 
                                            WHERE (FirstName = NULL OR LastName = NULL OR Phone = NULL OR Email = NULL)  
                                            AND id IN :contactID                                         
                                        ];
            if(listOfContacts != NULL && !listOfContacts.IsEmpty()){
                sdwanValid = false;
            }
            system.debug('listOfContacts ===>' + listOfContacts);  
        }  
        return sdwanValid;
    }
    
    
    // DPG-3299  Added to check Enrichment for SecureEdge
    @TestVisible
     private Boolean checkContactDetailsSEdge(String basketId) {
        List<cscfga__Product_Configuration__c> SEdgeConfList = prodConfListMain;
        Set<Id> seSEdgeSubscriptionSet = new Set<Id>();
         for (cscfga__Product_Configuration__c se : SEdgeConfList) {
             
            if (se.cscfga__Product_Definition__r.Name == System.Label.SecureEdge_PDName && se.Type__c == 'New')
                seSEdgeSubscriptionSet.add(se.Id);
        }
        Boolean SEdgeValid = true;
        if (seSEdgeSubscriptionSet.size()>0 )
            SEdgeValid = checkSEdgeValid(seSEdgeSubscriptionSet); 
        return SEdgeValid;
    }
    
   // DPG-3299  Added to check Enrichment for SecureEdge
        @TestVisible
        public Boolean checkSEdgeValid(Set<Id> seSEdgeSubscriptionList){
        Boolean contactDetails; Boolean SEdgeValid = true;
        List <cscfga__Attribute__c> attrSEdgeList =  [select id , name , cscfga__Value__c from cscfga__Attribute__c where name in ('Tenancy Primary Contact') and cscfga__Product_Configuration__c in :seSEdgeSubscriptionList];
            
            if (attrSEdgeList.size()>0){
            for (cscfga__Attribute__c attr : attrSEdgeList){ 
                if (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null ){
                    SEdgeValid = false;
                }           
            }
        }
           return SEdgeValid;
    }
    
     //////////////////////////////////////////////////// EDGE-147514 end//////////////////////////////////////
   // EDGE-155254 - New Method for nextGenMobility
   @TestVisible
    private Boolean validateNextGenMobility(String validationType) {
system.debug('validateNextGenMobility------'); 
            Boolean nGenMobilityValid = true;

        Set<Id> pcNextGenMobilitySet = new Set<Id>();

            Map<Id,Contact> mapOfPCandCont = new Map<Id,Contact>();
            /* Added this as part of EDGE-151354 - Start */
            if(validationType == EnrichBasketConstants.DCC){
                mapOfPCandCont = getDeviceCareContact(prodConfListMain);
            }
            system.debug('mapOfPCandCont--'+mapOfPCandCont);
            /* Added this as part of EDGE-151354 - End */
            //EDGE-172954-RF - pcNextGenMobilityList values have been set from getPCsfromBasket method - Gokul
            if(pcNextGenMobilityList != null) {
              for (cscfga__Product_Configuration__c pc : pcNextGenMobilityList) {
                /*Added "Enterprise Mobility Plan" PD Name Condition as part of EDGE-155181*/
                /* Added this check as part of EDGE-151354 - Start*/
                // EDGE-148725 - Added Type=New criteria in the below if condition

                if ((pc.cscfga__Product_Definition__r.Name == 'Next Generation Mobile Device' || pc.cscfga__Product_Definition__r.Name == 'Enterprise Mobility Plan') && validationType == 'OE'){ /* Added validationType as part EDGE-151354 */
                    pcNextGenMobilitySet.add(pc.Id);
                }
                //EDGE-183219 - Added null check for mapOfPCandCont - Gokul
                if(pc.cscfga__Product_Definition__r.name == EnrichBasketConstants.MOBILE_DEVICE_CARE && validationType == EnrichBasketConstants.DCC  && pc.Type__c == EnrichBasketConstants.NEW_STR
                   && (pc.cscfga__Product_Basket__r.Device_Care_Contact__c == null
                       || (mapOfPCandCont!= null && mapOfPCandCont.containskey(pc.Id) && (mapOfPCandCont.get(pc.Id).FirstName == null || mapOfPCandCont.get(pc.Id).LastName == null || mapOfPCandCont.get(pc.Id).Email == null)))){
                           system.debug('in mapOfPCandCont---');
                           nGenMobilityValid = false;
                       }
                /* Added this check as part of EDGE-151354 - End */
            }    
            if (pcNextGenMobilitySet.size()>0 && nGenMobilityValid)

                nGenMobilityValid = nGenMobilityValidMethod;
            }
            return nGenMobilityValid;
   }
    // EDGE-155254 - nextGenMobility New method
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    @TestVisible
    private  Boolean checkNextGenMobilityValid(cscfga__Product_Configuration__c pc){
        system.debug('checkNextGenMobilityValid------');    
         //Added for EDGE-174219 start
         Map<String,Map<String,String>> productconfigattmap = new Map<String,Map<String,String>>();
         for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
            map<String,String> attmap = new map<String,String>();
                System.debug('cscfga__Value__c is:'+attr.cscfga__Value__c);
                if(!productconfigattmap.containsKey(attr.cscfga__Product_Configuration__c)){
                    attmap.put(attr.name,attr.cscfga__Value__c);
                    productconfigattmap.put(attr.cscfga__Product_Configuration__c,attmap);
                }
                else{
                    map<String,String> getattmap = productconfigattmap.get(attr.cscfga__Product_Configuration__c);
                    attmap.put(attr.name,attr.cscfga__Value__c);
                    getattmap.putall(attmap);
                    productconfigattmap.put(attr.cscfga__Product_Configuration__c,getattmap);
                }
        }
        system.debug('productconfigattmap  '+productconfigattmap);
       for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r){
            // added by shubhi for EDGE-213807
            if((attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null) && (attr.name == EnrichBasketConstants.PREFERRED_CRD || attr.name == EnrichBasketConstants.NOT_BEFORE_CRD)){
                nGenMobilityValidMethod = false;
                break;
            }
            
            if(productconfigattmap.get(attr.cscfga__Product_Configuration__c).containsKey(EnrichBasketConstants.SIM_AVAILABILITY_TYPE) && productconfigattmap.get(attr.cscfga__Product_Configuration__c).get(EnrichBasketConstants.SIM_AVAILABILITY_TYPE)!= null && productconfigattmap.get(attr.cscfga__Product_Configuration__c).get(EnrichBasketConstants.SIM_AVAILABILITY_TYPE)!= ''){
                    
                if(productconfigattmap.get(attr.cscfga__Product_Configuration__c).get(EnrichBasketConstants.SIM_AVAILABILITY_TYPE).contains('New')){
                        system.debug('SIm availability not null'); 
                     // updated if condition  by shubhi for EDGE-213807 
                    if (pc.cscfga__Product_Basket__r.RecordType.Name!='Inflight Change'){
                        if(pc.csordtelcoa__Replaced_Product_Configuration__c==null && (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null) && (attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT)  ){
                            nGenMobilityValidMethod = false;
                            break;
                        }
                    }else{
                        if((attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null) && (attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT)  ){
                            nGenMobilityValidMethod = false;
                            break;
                        }
                    }
                }
            }
            else{
                system.debug('SIm availability null'); 
                // updated if condition  by shubhi for EDGE-213807
                if (pc.cscfga__Product_Basket__r.RecordType.Name!='Inflight Change'){
                    if(pc.csordtelcoa__Replaced_Product_Configuration__c==null && (attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null) && (attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT)){
                        nGenMobilityValidMethod = false;
                        break;
                    }
                }
                else{
                    if((attr.cscfga__Value__c == '' || attr.cscfga__Value__c == null) && (attr.name == EnrichBasketConstants.SITE_DELIVERY_ADDRESS || attr.name == EnrichBasketConstants.SITE_DELIVERY_CONTACT)){
                        nGenMobilityValidMethod = false;
                        break;
                   }
                }
            }       
                
         }//Added for EDGE-174219 end
        return nGenMobilityValidMethod;
    }
    // Added this method as part of EDGE-151354
    @TestVisible
    private Map<Id,Contact> getDeviceCareContact(List<cscfga__Product_Configuration__c> prodConfList){
        system.debug('getDeviceCareContact------');
        Map<Id,Contact> mapOfPCAndContact = new Map<Id,Contact>();
         //EDGE-172954-RF - setOfContactIds  values have been set from getPCsfromBasket method - Gokul
        List<Contact> listOfContacts = [SELECT Id,FirstName,LastName,Email FROM Contact WHERE Id IN :setOfContactIds];
        for(cscfga__Product_Configuration__c pc : prodConfList){
            for(Contact cont : listOfContacts){
                if(pc.cscfga__Product_Basket__r.Device_Care_Contact__c == cont.Id){
                    mapOfPCAndContact.put(pc.Id,cont);
                }
            }
        }
        return mapOfPCAndContact;
    }
    //EDGE-172954-RF - Below method has been modified to get parameter as pc from getpcsfrombasket method as a part of code refactoring - Gokul
    // Added this method as part of EDGE-151354
    //Remvoed Device Care method
    //EDGE-137753 Code Start --> Added By Rohit T
    @TestVisible
    private Boolean checkTenancyDetailsEnrichment(cscfga__Product_Configuration__c pc) {

        system.debug('checkTenancyDetailsEnrichment------');

        Boolean isBusinessCalling = true; Boolean NGUCValid = true; Boolean UCValid = true; Boolean BusinessCalling = true; 
        if ((pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.TENANCY_BRODSOFT_TENANCY) && pc.Type__c == EnrichBasketConstants.NEW_STR){ 
            for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                if (att.name == EnrichBasketConstants.TENANCY_PRIMARY_CONTACT && (String.isBlank(att.cscfga__Display_Value__c) || String.isBlank(att.cscfga__Value__c))) 
                    UCValid = false;
            }
        }
        if ((pc.cscfga__Product_Definition__r.Name == EnrichBasketConstants.BUSINESS_CALLING) && pc.Type__c == EnrichBasketConstants.NEW_STR){
            for(cscfga__Attribute__c att : pc.cscfga__Attributes__r){
                if ((att.name == EnrichBasketConstants.NOT_BEFORE_CRD || att.name == EnrichBasketConstants.PREFERRED_CRD) && (String.isBlank(att.cscfga__Display_Value__c) || String.isBlank(att.cscfga__Value__c))) 
                    BusinessCalling = false;
            }
        }

        system.debug('UCValid---'+UCValid+BusinessCalling);
        if (!UCValid || !BusinessCalling) 

            NGUCValid = false;
        return NGUCValid;
    } 
    //EDGE-172954-RF - below method has been merged with checkTenancyDetailsEnrichment as a part of code refactoring - Gokul
    /*@TestVisible
    private Boolean checkNGUCValid(List<cscfga__Product_Configuration__c> checkNGUCValid ,Boolean isBusinessCalling){
        Boolean TenancyPrimaryContact ; Boolean NGUCValid = true;
        List<String> attNameList = new List<String>();
        if(isBusinessCalling){ attNameList.add(EnrichBasketConstants.NOT_BEFORE_CRD); attNameList.add(EnrichBasketConstants.PREFERRED_CRD); }
        if(!isBusinessCalling) attNameList.add(EnrichBasketConstants.TENANCY_PRIMARY_CONTACT);
        system.debug('Inside checkNGUCValid attNameList-----'+attNameList);
        List <cscfga__Attribute__c> attrList = [select id , name , cscfga__Product_Configuration__c , cscfga__Display_Value__c , cscfga__Value__c from cscfga__Attribute__c where name in :attNameList and cscfga__Product_Configuration__c in :checkNGUCValid order by cscfga__Product_Configuration__c];
        system.debug('Inside checkNGUCValid attrList-----'+attrList);
        for(cscfga__Attribute__c att : attrList){
            if (String.isBlank(att.cscfga__Display_Value__c) || String.isBlank(att.cscfga__Value__c)){ NGUCValid = false;}
        }
        system.debug('Inside checkNGUCValid NGUCValid-----'+NGUCValid);
        return NGUCValid;
    }*/
    /**EDGE-172954-RF - Below four methods have been deprecated since we are not using csoe__Commercial_Configuration__c - Gokul
     //EDGE#127666 by Samish END
    @TestVisible
    private Boolean checkNumberAndSiteEnrichment(String basketId) {
        //Enrichment check asked for IP Site
        //Returning true if Enrichment is ok or not required
        //EDGE-127666
        List<cscfga__Product_Configuration__c> prodConfList = prodConfListMain;
        List<cscfga__Product_Configuration__c> pcIPSiteList = new List<cscfga__Product_Configuration__c>();
        for (cscfga__Product_Configuration__c pc : prodConfList) {
            if (pc.Name == EnrichBasketConstants.IP_SITE)
                pcIPSiteList.add(pc);
        }
        for (cscfga__Product_Configuration__c pc : prodConfList) {
            if (pc.Name == 'Connected Workplace Solution')  return true;
        }
        /* code moved to checkIpSiteValid() for EDGE# 127666 by Samish *
        Boolean IpSiteValid = true;
        /* code moved to checkIpSiteValid() for EDGE# 127666 by Samish *
        IpSiteValid = checkIpSiteValid(pcIPSiteList, prodConfList);   //Added for EDGE#127666 by Samish START
        return IpSiteValid;
    }
    //EDGE#127666 by Samish START
    private Boolean checkIpSiteValid(List<cscfga__Product_Configuration__c> pcIPSiteList, List<cscfga__Product_Configuration__c> prodConfList){
        Boolean checkSite; Boolean checkNumbers; Boolean checkCRD; Boolean IpSiteValid = true;
        for (cscfga__Product_Configuration__c IPSite : pcIPSiteList) {
            checkSite = false;checkNumbers = false;checkCRD = false;
            if (IPSite.Type__c == EnrichBasketConstants.CANCEL) checkNumbers = true;checkCRD = true;
            if (IPSite.Type__c == 'Modify') checkNumbers = true;
            for (cscfga__Product_Configuration__c pc : prodConfList) {
                if (pc.csoe__Commercial_Configuration__c == IPSite.Id) {
                    if (pc.Name == 'Site Details')checkSite = true;
                    else if (pc.Name == 'Reserve Numbers' || pc.Name == EnrichBasketConstants.NUMBER_MANAGEMENT_V1 || (IPSite.Type__c == 'Modify' && pc.Name == 'Reserve Numbers') || (IPSite.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Reserve Numbers'))checkNumbers = true;
                    else if (pc.Name == 'Customer Requested Dates' || (IPSite.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Customer Requested Dates'))checkCRD = true;
                }
            }
            if (!(checkSite && checkNumbers && checkCRD)) {IPSite.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;IpSiteValid = false;}
        }
        if (!IpSiteValid)
            update pcIPSiteList;
        return IpSiteValid;
    }  
    //EDGE#127666 by Samish END
    @TestVisible 
  private Boolean checkMobilityEnrichment(String basketId)
  {
    //Enrichment check asked for Mobility
    //Returning true if Enrichment is ok or not required
    //EDGE-127666
    List<cscfga__Product_Configuration__c> prodConfList = prodConfListMain;
    List<cscfga__Product_Configuration__c> pcMobilityList = new List<cscfga__Product_Configuration__c>();
    for (cscfga__Product_Configuration__c pc : prodConfList)
    {
        if (pc.Name == 'Mobility')
        {
            pcMobilityList.add(pc);
        }
    }
      for (cscfga__Product_Configuration__c pc : prodConfList)
      {
          if (pc.Name == 'Connected Workplace Solution') {
            /*  for (cscfga__Product_Configuration__c Mob : pcMobilityList)
              {
                  Mob.cscfga__Configuration_Status__c = EnrichBasketConstants.VALID;
              }
              update pcMobilityList;*
              return true;
          }
      }
    //Boolean checkNumbers;
    Boolean checkDeliveryDetails;
    Boolean checkCRD;
    Boolean checkMobilityFeatures;
    Boolean MobilityValid = true;
    //a bit of explenation on the || in the if - some enrichment can only be seen for certain Type of Mobility, so if it's not that type,
    //pass it through - the visibility is handled through javascript actions, so no need to handle it here
    //Delivery Details has an extra requirement of ShippingRequired attribute on Mobility to be set to TRUE - that is when the ChangeType attribute is set to New
    for (cscfga__Product_Configuration__c Mob : pcMobilityList)
    {
      //checkNumbers = false;//EDGE-99777, removing checkNumbers logic
      checkDeliveryDetails = false;
      checkCRD = false;
      checkMobilityFeatures = false;
      for (cscfga__Product_Configuration__c pc : prodConfList)
      {
        if (pc.csoe__Commercial_Configuration__c == Mob.Id)
        {
            //EDGE-99777, removing checkNumbers logic
          /*if (pc.Name == 'Reserve Numbers' || pc.Name == 'MobileNumberManagementv1')
          {
            checkNumbers = true;
          }
          else*
          if (pc.Name == 'Delivery Details' || (Mob.Type__c == 'Modify' && pc.Name == 'Delivery Details') || (Mob.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Delivery Details'))
          {
            checkDeliveryDetails = true;
          }
          else if (pc.Name == 'Customer Requested Dates')
          {
            checkCRD = true;
          }
          else if (pc.Name == 'Mobility Features' || (Mob.Type__c == 'Modify' && pc.Name == 'Mobility Features') || (Mob.Type__c == EnrichBasketConstants.CANCEL && pc.Name == 'Mobility Features') )
          {
            checkMobilityFeatures = true;
          }
        }
      }
      //if (!(checkNumbers && checkDeliveryDetails && checkCRD && checkMobilityFeatures)) //EDGE-99777, removing checkNumbers logic
            if (!(checkDeliveryDetails && checkCRD && checkMobilityFeatures)){Mob.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;        MobilityValid = false;}
    }
        if (!MobilityValid){update pcMobilityList;}
    return MobilityValid;
  } 
     */
    @TestVisible
    private string continueCheckEnrichment(String basketId, Boolean tcPresent,cscfga__Product_Basket__c productBasket,String ngucError, PageReference ref, String retVal) {
        system.debug('continueCheckEnrichment------');
        //This sync functionality is commented as after contract accepted pricing field is locked.
        /*CustomButtonOpportunitySync sync = new CustomButtonOpportunitySync();
        String syncMsg = sync.syncMessage(basketId, false);*/
        //EDGE - INC000094293839
        Id userId = UserInfo.getProfileId();
        String queryString = 'SELECT id, Name FROM PROFILE WHERE id = :userId';
        List<Profile> profileList = Database.query(queryString);
        PageReference reff = null;
        if(profileList != null && profileList.size() > 0 && (profileList[0].Name == Label.PRM_Community_User || profileList[0].Name == Label.PRM_Indirect_Channel_Mangr || profileList[0].Name == Label.PRM_Indirect_channel_mgrIntl || profileList[0].Name == Label.PRM_CommunityAdmin_User)) {
            reff= new PageReference('/' + productBasket.id);
        }
        else {
            reff = new PageReference('/apex/c__NewBasketOverrideRedirectPage?id=' + productBasket.id);
        }
        ref.setRedirect(true);
        String syncMsg = '{"status":"ok", "text":"", "redirectURL":"' + reff.getUrl() +'"}';
        //END EDGE - INC000094293839
        String cancelReasonMsg;
        //if (syncMsg.contains(EnrichBasketConstants.ok)) {
            if(!tcPresent){
                //Ritika EDGE - 81135:Changes Start: As the code related to cancellation-details became unreachbale, rearranged enrichment and cancellation-details flow.
                //return CustomButtonEnrichBasket.enrichBasket(basketId);
                //EDGE-172954-RF - Below 2 methods have been deprecated since we are not using csoe__Commercial_Configuration__c - Gokul
                /*validateEnrichment = checkNumberAndSiteEnrichment(basketId);
                validateMobileEnrichment = checkMobilityEnrichment(basketId);*/
                // INC000092247848
                //EDGE-172954-RF - below boolean values are assigned from getPcsfromBasket method - gokul
                //Boolean validateEMEnrichment = checkAddressAndContactEnrichment(basketId);
                //DPG-1692 & DPG-1723 Added for to check Enrichment for IOT Subscription and Incorporate review comments from governance forum
                //Boolean validateIOTEnrichment = checkAddressAndContactEnrichmentIOT(basketId);
                //DPG-1692 & DPG-1723 Added for to check Enrichment for IOT Subscription and Incorporate review comments from governance forum
                validateNextGenMobility = validateNextGenMobility(EnrichBasketConstants.OE);  /* Modified EDGE-151354 */
                  
                //DPG-2890 Added for to check Enrichment for VeloCloud Tenancy and Incorporate review comments from governance forum
                Boolean validateVeloEnrichment = checkContactDetailsVelo(basketId);
                //DPG-3466 Added to check Enrichment for SD-WAN Tenancy and Incorporate review comments from governance forum
                Boolean validateSDWANEnrichment = checkContactDetailsSdwan(basketId);
                //DPG-3299  -  Added to check for Enrichment for SecureEdge and Incorporate review comments from governance forum
                Boolean validateSecureEdgeEnrichment = checkContactDetailsSEdge(basketId);

                // DIGI-15582 changes starts here --- added by shashank
                Boolean validDmsOe = OrderEnrichValidations.isDmsOEValid(basketId , prodConfListMain);
                // DIGI-15582 changes ends here --- added by shashank

                // EDGE-151354 - nextGenMobility (Device Care Contact Validation)
                validateNextGenMobilityDCC = validateNextGenMobility(EnrichBasketConstants.DCC);  /* Added EDGE-151354 */
                boolean validnextGenMBasket; //EDGE-153402
                NumberReservationHelper.ValidationWrapper isValidReserve = NumberReservationHelper.finishReservationMobile(basketId);
                if(isValidReserve!=null)
                    validnextGenMBasket = isValidReserve.IsValid;
                if (!validnextGenMBasket)//EDGE-153402
                    //EDGE-170884. Kalashree Borgaonkar. Conditional message.
                    return '{"status":"error","text":"'+isValidReserve.ErrorMessage+'", "redirectURL":"' + EnrichBasketConstants.CLOSE_BRACKET;
                //EDGE-172954-RF
               /* if (!validateEnrichment)
                    return EnrichBasketConstants.ERROR_STATUS1+ngucError+EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;*/
                // INC000092247848
                if (!validateEMEnrichment)
                    return EnrichBasketConstants.OE_ERROR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
                //DPG-1692 & DPG-1723 Added for to check Enrichment for IOT Subscription and Incorporate review comments from governance forum
                if (!validateIOTEnrichment)
                    return EnrichBasketConstants.ERROR_STATUS1 + Label.Enrichment_Error + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
                //DPG-2890 Added for to check Enrichment for VeloCloud Tenanct and Incorporate review comments from governance forum
                if (!validateVeloEnrichment){return '{"status":"error","text":"' + Label.Enrichment_Error + '", "redirectURL":"' + ref.getUrl() + '"}';}
                 //DPG-3466 Added to check Enrichment for SD-WAN Tenancy and Incorporate review comments from governance forum
                if (!validateSDWANEnrichment){return '{"status":"error","text":"' + Label.Enrichment_Error + '", "redirectURL":"' + ref.getUrl() + '"}';}
                //DIGI-15582 changes starts here --- added by shashank 
                if (!validDmsOe){return '{"status":"error","text":"' + Label.Enrichment_Error + '", "redirectURL":"' + ref.getUrl() + '"}';}
                //DIGI-15582 changes ends here --- added by shashank 
                //DPG-3299  -  Added to check for Enrichment for SecureEdge and Incorporate review comments from governance forum 
                if (!validateSecureEdgeEnrichment){return '{"status":"error","text":"' + Label.Enrichment_Error + '", "redirectURL":"' + ref.getUrl() + '"}';}
                
                //// EDGE-155254 - nextGenMobility
                if (!validateNextGenMobility)
                    return EnrichBasketConstants.ERROR_STATUS1 + Label.Enrichment_Error + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
                // EDGE-155254 - nextGenMobility END
                if(!validateNextGenMobilityDCC)
                    return EnrichBasketConstants.ERROR_STATUS1 + Label.Enrich_Basket_Device_Care_Contact_Error + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
                //EDGE-172954 - RF
               /* if (!validateMobileEnrichment)
                    return '{"status":"error","text":"Mobility enrichment is incomplete", "redirectURL":"' + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;*/
                String result = enrichBasket(basketId,productBasket);
                system.debug('enrich result--'+result);
                if(result.contains(EnrichBasketConstants.ok)){
                    retVal = checkNullRootConfigPcs(basketId);
                     system.debug('retVal--'+retVal);
                    if (retVal.contains(EnrichBasketConstants.ok))  
                        return retVal;
                    else {
                       //EDGE - INC000094293839
                       //return result Commented as part of INC000094293839;
                       return syncMsg;
                       //END //EDGE - INC000094293839
                    }  
                }
                else
                    return result;
                //EDGE - 81135:Changes End
            }
            else
            {
                //EDGE-128633. Kalashree Borgaonkar. Validation number reservation for nguc
                //validateEnrichment = checkngUCNumberEnrichment(basketId);
                //Dheeraj Bhatt-EDGE-126433-Enable validation at NGUC product configuration level to have at least one number assigned before   basket is enriched.
               //EDGE-172954 -RF - 
                 NumberReservationHelper.ValidationWrapper ngucValidate = NumberReservationHelper.finishReservationFixed(basketId);//EDGE-200054
                validateEnrichment= ngucValidate.isValid;//EDGE-200054
                //EDGE-137029. Kalashree Borgaonkar. Fix to show nguc validation message
                //EDGE-137753 Code Start --> Added By Rohit T
               // Boolean validateNGUCEnrichment = checkTenancyDetailsEnrichment(basketId);//EDGE-172954 -RF - below boolean values are assigned from getPcsfromBasket method - gokul
                //EDGE-137753 Code End --> Added By Rohit T
                if (!validateNGUCEnrichment){return EnrichBasketConstants.OE_ERROR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;}
                //EDGE-172954 -RF
                if (!validateEnrichment)//EDGE-200054
                    return EnrichBasketConstants.ERROR_STATUS1+ngucError+EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;//EDGE-200054
                //else*/
                    return enrichngUCBasket(basketId,productBasket);
            }
       /* }
        retVal = syncMsg;
        return retVal;*/
    }
    /**
    *  Changes the basket status to In Enrichment
    * @param      basketId  The basket identifier
    * @return     String JSON format values
    */
    @TestVisible
    private static String enrichBasket(String basketId,cscfga__Product_Basket__c  productBasket) {
      system.debug('enrichBasket------');
        try {
            //Edge-127666
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues(EnrichBasketConstants.SERVICE_DETAILING);
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            String retVal;
            Pattern phonePattern;
            Matcher phoneMatcher;
            String phoneNumber = productBasket.Project_Manager_Contact_Number__c ;
            Boolean correctNumber = false;
            Boolean bIsPrimaryAndTechnicalContactBlank = false;
            Boolean bIsOrderPrimaryContactBlank = false;
            Boolean isWifiDeviceNotAdded = false;
            Integer totalNumbers = 0;
            Integer totalUserQty = 0;
            Boolean isSufficientNumbers = true;
            String UCEConfigId = null;
            if (phoneNumber != null && phoneNumber.length() == 10) {
                phonePattern = Pattern.compile('\\D*?(\\d\\D*?){10}');
                Pattern numericPattern = Pattern.compile('[0-9]{10}');
                phoneMatcher = phonePattern.matcher(phoneNumber);
                Matcher numericMatcher = numericPattern.matcher(phoneNumber);
                if (numericMatcher.matches())
                    correctNumber = true;
            }
                    retVal = checkIpSiteandUnifiedCommPcs(basketId, productBasket, basketStage, phonePattern ,phoneMatcher, phoneNumber , correctNumber, bIsPrimaryAndTechnicalContactBlank , bIsOrderPrimaryContactBlank , isWifiDeviceNotAdded , totalNumbers , totalUserQty , isSufficientNumbers , UCEConfigId, retVal);
            return retVal;
        } catch (Exception e) {
            System.debug(e.getStackTraceString());
            Logger.getLogger(CustomButtonEnrichBasket.class).debug(e);
            return EnrichBasketConstants.ERROR_STATUS + Label.Validate_Basket_Stage_Exception + EnrichBasketConstants.CLOSE_BRACKET;
        }
    }
    //EDGE-127666
    @TestVisible
    private static string checkNullRootConfigPcs(String basketId){
        system.debug('checkNullRootConfigPcs------');
            String acc;String opportunityId;Boolean redirectPg = false;
            //Added check on configurationType to exclude the PC related to solution
            // Updated for EDGE-144971 Start
            //EDGE-172954-RF - pcListSOQLCE2 values have been assigned from getPCsfromBasket method and optimised the below loop - Gokul
            if (pcListWithNullRootConfig != null) {
                for(cscfga__Product_Configuration__c pc : pcListWithNullRootConfig){
                    acc = pc.cscfga__Product_Basket__r.csbb__Account__c;
                    opportunityId = pc.cscfga__Product_Basket__r.cscfga__Opportunity__c;
                    if(pc.cssdm__solution_association__c != null)
                        return EnrichBasketConstants.CANCELLATION_REASON_REDIRECT+basketId+EnrichBasketConstants.ACCOUNT_ID+acc+EnrichBasketConstants.OPP_ID+opportunityId+EnrichBasketConstants.END_URL_STR;
                    break;
                }
            }
        return EnrichBasketConstants.SOME_ERROR;
    }
    @TestVisible
    private Static string checkIpSiteandUnifiedCommPcs(String basketId,cscfga__Product_Basket__c productBasket,String basketStage, Pattern phonePattern, Matcher phoneMatcher,String phoneNumber ,Boolean correctNumber,Boolean bIsPrimaryAndTechnicalContactBlank ,Boolean bIsOrderPrimaryContactBlank ,Boolean isWifiDeviceNotAdded ,Integer totalNumbers ,Integer totalUserQty ,Boolean isSufficientNumbers ,String UCEConfigId,String retVal){
        system.debug('checkIpSiteandUnifiedCommPcs------');
        Set<Id> wifiPcSet = new Set<Id>();
        Set<Id> setOfProdConfIds = new Set<Id>();
        //EDGE-172954-RF - pcListSOQL values have been assigned from getPCsfromBasket method and optimised the below loop - Gokul
        for (cscfga__Product_Configuration__c prodConfigUCE : pcListIpSiteAndUnifiedComm) {
            system.debug('pc---1'+prodConfigUCE);
            system.debug('pc---2'+prodConfigUCE.cscfga__Attributes__r);
            for (cscfga__Attribute__c att : prodConfigUCE.cscfga__Attributes__r) {
                if (prodConfigUCE.cscfga__Product_Definition__r.name == EnrichBasketConstants.UNIFIED_COMMUNICATION){
                    if (att.name == EnrichBasketConstants.ORDER_PRIMARY_CONTACT_ID && String.isBlank(att.cscfga__Value__c))
                        bIsOrderPrimaryContactBlank = true;
                    if (att.name == EnrichBasketConstants.TOTAL_NUMBERS && !String.isBlank(att.cscfga__Value__c) && prodConfigUCE.Name.contains(EnrichBasketConstants.IP_SITE)) 
                        totalNumbers = Integer.valueOf(att.cscfga__Value__c);
                    if (att.name == EnrichBasketConstants.TOTAL_USER_QTY && !String.isBlank(att.cscfga__Value__c) && prodConfigUCE.Name.contains(EnrichBasketConstants.IP_SITE)) 
                        totalUserQty = Integer.valueOf(att.cscfga__Value__c);
                }
                else{
                    if (att.name != EnrichBasketConstants.WIFI_ADD_ON_USER_MODIFIED && att.name != EnrichBasketConstants.TOTAL_NUMBERS && String.isBlank(att.cscfga__Value__c))
                        bIsPrimaryAndTechnicalContactBlank = true;
                    else if (att.name == EnrichBasketConstants.WIFI_ADD_ON_USER_MODIFIED && att.cscfga__Value__c == EnrichBasketConstants.TRUE_STR)
                        wifiPcSet.add(att.cscfga__Product_Configuration__c);
                }
            }
            if (bIsPrimaryAndTechnicalContactBlank == true || bIsOrderPrimaryContactBlank == true) {
                prodConfigUCE.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;
                if(!setOfProdConfIds.contains(prodConfigUCE.id)){
                    updatePcList.add(prodConfigUCE);
                    setOfProdConfIds.add(prodConfigUCE.id);
                }
            }       
        }
        if (totalUserQty > totalNumbers) 
            isSufficientNumbers = false;
         //EDGE-172954-RF - Below query contains csoe__Commercial_Configuration__c as we are not using it - Gokul
       /* if (!wifiPcSet.isEmpty()) {
            string queryString = 'SELECT ';
            queryString += 'id, ';
            queryString += 'csoe__Commercial_Configuration__c, ';
            queryString += '(';
            queryString += 'SELECT ';
            queryString += 'Id, ';
            queryString += 'Name, ';
            queryString += 'cscfga__Value__c, ';
            queryString += 'cscfga__is_required__c ';
            queryString += 'FROM ';
            queryString += 'cscfga__Attributes__r ';
            queryString += 'WHERE ';
            queryString += 'cscfga__is_required__c = true';
            queryString += ') ';
            queryString += 'FROM ';
            queryString += 'cscfga__Product_Configuration__c ';
            queryString += 'WHERE ';
            queryString += 'name =  \'Wifi Access Point\' ';
            queryString += 'AND ';
            queryString += 'csoe__Commercial_Configuration__c IN :wifiPcSet';
            List<cscfga__Product_Configuration__c> wifiPCList = Database.query(queryString);
            if (wifiPCList.isEmpty()) 
                isWifiDeviceNotAdded = true;
            else {
                for (cscfga__Product_Configuration__c prodConfig : wifiPCList) {
                    for (cscfga__Attribute__c att : prodConfig.cscfga__Attributes__r) {
                        if (String.isBlank(att.cscfga__Value__c))
                            isWifiDeviceNotAdded = true;
                        cscfga__Product_Configuration__c pc = new cscfga__Product_Configuration__c(id = prodConfig.csoe__Commercial_Configuration__c);
                        pc.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;
                        if(!setOfProdConfIds.contains(pc.id)){ 
                            updatePcList.add(pc);
                            setOfProdConfIds.add(pc.id); 
                        }
                    }    
                }
            }
        }*/
        retVal = checkBasketDetails(basketId, productBasket, basketStage, phonePattern, phoneMatcher, phoneNumber , correctNumber, bIsPrimaryAndTechnicalContactBlank , bIsOrderPrimaryContactBlank , isWifiDeviceNotAdded , totalNumbers , totalUserQty , isSufficientNumbers , UCEConfigId);
        return retVal;
    }
    @TestVisible
    private Static String checkBasketDetails(String basketId,cscfga__Product_Basket__c productBasket,String basketStage, Pattern phonePattern, Matcher phoneMatcher,String phoneNumber ,Boolean correctNumber,Boolean bIsPrimaryAndTechnicalContactBlank ,Boolean bIsOrderPrimaryContactBlank ,Boolean isWifiDeviceNotAdded ,Integer totalNumbers ,Integer totalUserQty ,Boolean isSufficientNumbers ,String UCEConfigId){
       system.debug('checkBasketDetails------');
        String error = '';
        Integer countProducts = prodConfListMain.size();
        if (countProducts == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Empty_Basket));
            return EnrichBasketConstants.ERROR_STATUS1 + Label.Empty_Basket + EnrichBasketConstants.CLOSE_BRACKET;
        }
        //EDGE-172954-RF - Below block is not utilised - Gokul
       /* Id recordTypeId = null;
            String queryString = 'SELECT ';
            queryString += 'BusinessProcessId, ';
            queryString += 'DeveloperName, ';
            queryString += 'Id, ';
            queryString += 'Name, ';
            queryString += 'SobjectType ';
            queryString += 'FROM ';
            queryString += 'RecordType ';
            queryString += 'WHERE ';
            queryString += 'SobjectType = \'Opportunity\' ';
            queryString += 'AND ';
            queryString += 'DeveloperName = \'Defined\'';
            List<RecordType> recordTypes = Database.query(queryString);
            for (RecordType rType : recordTypes){
                recordTypeId = rType.Id;
            }*/
        if (!isSufficientNumbers)
            error = Label.Unsufficient_Numbers.replace(EnrichBasketConstants.QUANTITY, String.valueOf(totalUserQty - totalNumbers));
        if (bIsPrimaryAndTechnicalContactBlank)
            error = Label.Site_Enrichment_Error;
        if (bIsOrderPrimaryContactBlank)
            error = Label.Order_Primary_Contact_Enrichment_Error;
        if (isWifiDeviceNotAdded)
            error = Label.Wifi_Enrichment_Error;
        if ((productBasket.Project_Complexity__c == EnrichBasketConstants.COMPLEX || productBasket.Project_Complexity__c == EnrichBasketConstants.COMPLEX_PLUS)
            && (productBasket.Project_ID__c == null || productBasket.Project_Complexity__c == null)) {
                if (error != '') 
                    error = error + '.                                       ' + Label.PM_Error;
                else
                    error = Label.PM_Error;
            }
        if (productBasket.Project_Manager_User_Id__c != null && productBasket.Project_Manager_User_Id__c.length() != 7) {
            if (error != '') 
                error = error + '.                                       ' + Label.PM_User_Id_Error;
            else
                error = Label.PM_User_Id_Error;
        }
        if (phoneNumber != null && (phoneNumber.length() != 10 || !correctNumber)) {
            if (error != '') 
                error = error + '.                                      ' + Label.PM_Contact_Number_Error;
            else 
                error = Label.PM_Contact_Number_Error;
        }
        // Changes for EDGE-48933
        if (EnvironmentVariable__c.getValues(EnrichBasketConstants.ENABLE_B2B4).Value__c.equalsIgnoreCase(EnrichBasketConstants.TRUE_STR)) {
            NumberEnrichmentValidationHelper nEhelper = new NumberEnrichmentValidationHelper();
            boolean validMobilityBasket = true;
            NumberReservationHandler.ValidationWrapper isValidReserve = NumberReservationHandler.finishReservation(basketId);
            if(isValidReserve!=null){
                validMobilityBasket = isValidReserve.IsValid;
            }
            if (!validMobilityBasket)
                //EDGE-170884. Kalashree Borgaonkar. Conditional message.
                error = isValidReserve.ErrorMessage;
        }
        //Commented by Shubhi/Aman as a part of EDGE-142085 || Start
        ////
        /*if (productBasket.Billing_Account__c == null && productBasket.cscfga__Opportunity__r.RecordTypeId == recordTypeId) {
        if (error != '')
        error = error + '.                                      ' + Label.Billing_Account_Required_Error;
        else
        error = Label.Billing_Account_Required_Error;
        }*/
        //
        //Commented by Shubhi/Aman as a part of EDGE-142085 || End
        if (productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Enrichment));
            return EnrichBasketConstants.ERROR_STATUS1 + Label.Basket_Already_In_Enrichment + EnrichBasketConstants.CLOSE_BRACKET;
        } if (productBasket.cscfga__Basket_Status__c != EnrichBasketConstants.VALID) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Enrich_Basket_Error));
            return EnrichBasketConstants.ERROR_STATUS1 + Label.Enrich_Basket_Error + EnrichBasketConstants.CLOSE_BRACKET;
        } else
            productBasket.csordtelcoa__Basket_Stage__c = basketStage;
        // Start EDGE-81085 Project Complexity field in CS to be selected based on the complexity needs via Work Instructions
        if ((productBasket.Project_Complexity__c == EnrichBasketConstants.COMPLEX || productBasket.Project_Complexity__c == EnrichBasketConstants.COMPLEX_PLUS)&& productBasket.PM_Required__c == false)
            productBasket.PM_Required__c = true;
        if (productBasket.Project_Complexity__c.equalsIgnoreCase(EnrichBasketConstants.SIMPLEX) || productBasket.Project_Complexity__c == EnrichBasketConstants.SIMPLEX_PLUS){
            productBasket.PM_Required__c = false;productBasket.Project_ID__c = '';productBasket.Project_Manager__c = '';productBasket.Project_Manager_Email__c = '';productBasket.Project_Manager_Contact_Number__c = '';
        }
        // EDGE-81085 End
        if (error != '') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Enrichment));
            return EnrichBasketConstants.ERROR_STATUS1 + error + EnrichBasketConstants.CLOSE_BRACKET;
        }
        update productBasket;
        executeDirectoryBusinessRules(productBasket.id); 
        //INC000094308347
        String redirecturl=FeatureManagement.checkPermission('Partner_User')?'/s/sfdcpage/'+EncodingUtil.urlEncode(EnrichBasketConstants.REDIRECT_URL+productBasket.Id, 'UTF-8'):EnrichBasketConstants.REDIRECT_URL+ productBasket.Id;
        PageReference ref = new PageReference(redirecturl);
       // PageReference ref = new PageReference(EnrichBasketConstants.REDIRECT_URL + basketId);
        ref.setRedirect(true);
        return EnrichBasketConstants.OK_STATUS + Label.Enrich_Basket_Success + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
    }
    @TestVisible
    private static void executeDirectoryBusinessRules(String basketId) {
       system.debug('executeDirectoryBusinessRules------');
        // EDGE-124525,EDGE-122842 Start
        Map<String,String> mapFNN = updateNumberAndGetListingRecOfSrvcNumber(basketId);     //Added for EDGE# 127666 by Samish
        /* moved code to new method updateNumberAndGetListingRecOfSrvcNumber() for EDGE# 127666 by Samish */
        //original logic prior to EDGE-90967 changes (see below)
        /* removed commented code for EDGE# 127666 by Samish */
        //Start EDGE-90967 changes to bulkify OE call
        // //EDGE-172954-RF - configsList values have been set in getPCsFromBasket method as a part of code refactoring - Gokul
        if (pcListIpwithDmcatSpec != null && !pcListIpwithDmcatSpec.isEmpty()) {
            performBulkOECall(pcListIpwithDmcatSpec, mapFNN); // moved code to new method performBulkOECall() for EDGE# 127666 by Samish
        }
        //End EDGE-90967 changes to bulkify OE call
    }
    //EDGE# 127666 by Samish END
    //EDGE#127666 by Samish START
    public Static Map<String,String> updateNumberAndGetListingRecOfSrvcNumber(String basketId){
       system.debug('updateNumberAndGetListingRecOfSrvcNumber------');
        // EDGE-124525,EDGE-122842 Start
        List<Number__c> lstNumber = [SELECT id,ListingCode__c,Service_Number__c,Product_Configuration__c,Type__c,
                                     Mobile__c FROM Number__c WHERE Product_Configuration__c != null
                                     AND Basket__c =:basketId ];
        Map<String,String> mapFNN = new Map<String,String>();
        Integer totalrecord = 0;
        if(!lstNumber.isEmpty()){
            for(Number__c numberrec: lstNumber){
                if(numberrec.Type__c == EnrichBasketConstants.TRANSITION && numberrec.ListingCode__c != null &&
                   numberrec.ListingCode__c.contains(EnrichBasketConstants.LISTED))
                    numberrec.ListingCode__c = EnrichBasketConstants.LISTED_FAX;
                else
                    numberrec.ListingCode__c = EnrichBasketConstants.UNLISTED;
                totalrecord++;
                if(totalrecord == lstNumber.size()){ numberrec.ListingCode__c = EnrichBasketConstants.LISTED_FAX;
                                                   }
                mapFNN.put(numberrec.Service_Number__c,numberrec.ListingCode__c);
            }
            update lstNumber;
        }
        //End
        return mapFNN;
    }
    //EDGE# 127666 by Samish START
    private static void performBulkOECall(List<cscfga__Product_Configuration__c> pcListIpwithDmcatSpec, Map<String,String> mapFNN){
        system.debug('performBulkOECall------');
        List<NumberNCSDTO.Configuration> numberList = new List<NumberNCSDTO.Configuration>();
        List<NumberNCSDTO.Configuration> numberListold = new List<NumberNCSDTO.Configuration>();
        NumberNCSHelper ncs = new NumberNCSHelper();
        //Start EDGE-90967 changes to bulkify OE call
        //load all attachments
        List<Attachment> attList = [SELECT id, name, body, ParentId FROM Attachment WHERE
                                    ParentId  IN :pcListIpwithDmcatSpec AND name like 'NumberManagement%'];
        //prepare Map for convenience, key: parentId, value: list of attachments
        Map<Id, List<Attachment>> parentIdToAttachmentList = new Map<Id, List<Attachment>>();
        /* moved code to new method getParentIdToAttachmentList() for EDGE# 127666 by Samish */
        parentIdToAttachmentList = getParentIdToAttachmentList(attList);
        //collect all info for OE
        List<String> rootConfigIdList = new List<String>();
        Map<String,List<NumberNCSDTO.Configuration>> configIdToNumberList = new Map<String,List<NumberNCSDTO.Configuration>>();
        for (cscfga__Product_Configuration__c configs : pcListIpwithDmcatSpec) {
            numberList = new List<NumberNCSDTO.Configuration>();
            numberListOld = new List<NumberNCSDTO.Configuration>();
            if (!parentIdToAttachmentList.containsKey(configs.id))
                continue;
            //we have attachments so add PC and initialize configIdToNumberList for it
            rootConfigIdList.add(configs.id);
            configIdToNumberList.put(configs.id, new List<NumberNCSDTO.Configuration>());
            for (attachment att : parentIdToAttachmentList.get(configs.id)) {
                String jsonStr = att.body.toString();
                NumberNCSDTO ncsDTO = NumberNCSDTO.parse(jsonStr);
                for (NumberNCSDTO.Configuration config : ncsDTO.configurations) {
                    if (config.listCode == EnrichBasketConstants.LE)
                        numberList.add(config);
                    // EDGE-124525,EDGE-122842 Start
                    if(mapFNN.containsKey(config.FNN))
                        config.listCode = mapFNN.get(config.FNN);
                    //End
                    numberListold.add(config);
                }
                if (numberList == null || numberList.size() == 0) {
                    numberListold[0].listCode = EnrichBasketConstants.LE;
                    configIdToNumberList.get(configs.id).addAll(numberListold);
                    //ncs.updateExistingNCS(configs.id, EnrichBasketConstants.NUMBER_MANAGEMENT_V1, numberListold); //old call
                } else {
                    system.debug('numberList==' + numberListold);
                    configIdToNumberList.get(configs.id).addAll(numberList);
                    //ncs.updateExistingNCS(configs.id, EnrichBasketConstants.NUMBER_MANAGEMENT_V1, numberList); // old call
                }
            }
        }
        //collected all the info, perform bulk OE call
        ncs.updateExistingNCSbulk(rootConfigIdList, EnrichBasketConstants.NUMBER_MANAGEMENT_V1, configIdToNumberList);
        //End EDGE-90967 changes to bulkify OE call
    }
    //EDGE# 127666 by Samish END
    //EDGE#127666 by Samish START
    @TestVisible
    private static Map<Id, List<Attachment>> getParentIdToAttachmentList(List<Attachment> attList){
       system.debug('getParentIdToAttachmentList------');
        Map<Id, List<Attachment>> parentIdToAttachmentList = new Map<Id, List<Attachment>>();
        for (Attachment att : attList) {
            if (parentIdToAttachmentList.containsKey(att.ParentId))
                parentIdToAttachmentList.get(att.ParentId).add(att);
            else {
                parentIdToAttachmentList.put(att.ParentId, new List<Attachment>{att});
            }
        }
        return parentIdToAttachmentList;
    }
    //RPLP :166 Added the method for ngUC offer
    @TestVisible
    private static String enrichngUCBasket(String basketId ,cscfga__Product_Basket__c productBasket) {
       system.debug('enrichngUCBasket------');
        try {
            ////EDGE-127666
            CustomConfigurationOptions__c customSetting = CustomConfigurationOptions__c.getValues(EnrichBasketConstants.SERVICE_DETAILING);
            String basketStage = customSetting.Enrichment_Basket_Stage__c;
            Pattern phonePattern;
            Matcher phoneMatcher;
            String phoneNumber = productBasket.Project_Manager_Contact_Number__c ;
            Boolean correctNumber = false;
            Boolean bIsPrimaryAndTechnicalContactBlank = false;
            Boolean bIsOrderPrimaryContactBlank = false;
            Boolean isWifiDeviceNotAdded = false;
            Integer totalNumbers = 0;
            Integer totalUserQty = 0;
            Boolean isSufficientNumbers = true;
            String UCEConfigId = null;
            //EDGE-127666
            if (phoneNumber != null && phoneNumber.length() == 10) {
                phonePattern = Pattern.compile('\\D*?(\\d\\D*?){10}');
                Pattern numericPattern = Pattern.compile('[0-9]{10}');
                phoneMatcher = phonePattern.matcher(phoneNumber);
                Matcher numericMatcher = numericPattern.matcher(phoneNumber);
                if (numericMatcher.matches())
                    correctNumber = true;
            }
            //EDGE-172954-RF - pcListSOQL values have been assigned from getPCsfromBasket method and optimised the below loop - Gokul
                    for (cscfga__Product_Configuration__c prodConfigUCE : pcListIpSiteAndUnifiedComm) {
                        if (prodConfigUCE.Name == EnrichBasketConstants.UNIFIED_COMMUNICATION){
                            for (cscfga__Attribute__c att : prodConfigUCE.cscfga__Attributes__r) {
                                if (att.name == EnrichBasketConstants.ORDER_PRIMARY_CONTACT_ID && String.isBlank(att.cscfga__Value__c))
                                    bIsOrderPrimaryContactBlank = true;
                                if (att.name == EnrichBasketConstants.TOTAL_NUMBERS && !String.isBlank(att.cscfga__Value__c) && prodConfigUCE.Name.contains(EnrichBasketConstants.UNIFIED_COMMUNICATION))
                                    totalNumbers = Integer.valueOf(att.cscfga__Value__c);
                                if (att.name == EnrichBasketConstants.TOTAL_USER_QTY && !String.isBlank(att.cscfga__Value__c) && prodConfigUCE.Name.contains(EnrichBasketConstants.UNIFIED_COMMUNICATION))
                                    totalUserQty = Integer.valueOf(att.cscfga__Value__c);
                            }
                        }
                        if (bIsOrderPrimaryContactBlank == true) {
                            prodConfigUCE.cscfga__Configuration_Status__c = EnrichBasketConstants.INCOMPLETE;
                            updatePcList.add(prodConfigUCE);
                        }
                    } 
            if (totalUserQty > totalNumbers)
                isSufficientNumbers = false;
            String qty = productBasket.cscfga__Products_Id_Qty_In_Basket__c; //Spring 20 upgrade field is depricated
            //qty = '1';// RPLP:56 - REMOVE THIS LINE . For Testing only
            String error = '';
            //if (productBasket.cscfga__Products_Id_Qty_In_Basket__c == null) {
            /* if (qty == null) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Empty_Basket));
            return EnrichBasketConstants.ERROR_STATUS1 + Label.Empty_Basket + EnrichBasketConstants.CLOSE_BRACKET;
            } Spring 20 upgrade field is depricated*/
             //EDGE-172954-RF - below block of code is not utilised  - Gokul
            /*Id recordTypeId = null;
            queryString = 'SELECT ';
            queryString += 'BusinessProcessId, ';
            queryString += 'DeveloperName, ';
            queryString += 'Id, ';
            queryString += 'Name, ';
            queryString += 'SobjectType ';
            queryString += 'FROM ';
            queryString += 'RecordType ';
            queryString += 'WHERE ';
            queryString += 'SobjectType = \'Opportunity\' ';
            queryString += 'AND ';
            queryString += 'DeveloperName = \'Defined\'';
            List<RecordType> recordTypes = Database.query(queryString);
            System.debug('RPLP:166 - Inside enrichngUCBasket:recordTypes..'+recordTypes+'..QueryString..'+queryString);
            for (RecordType rType : recordTypes){
                recordTypeId = rType.Id;
            }*/
            if (!isSufficientNumbers)
                error = Label.Unsufficient_Numbers.replace(EnrichBasketConstants.QUANTITY, String.valueOf(totalUserQty - totalNumbers));
            if (bIsOrderPrimaryContactBlank)
                error = Label.Order_Primary_Contact_Enrichment_Error;
            //EDGE-127666
            if (phoneNumber != null && error != '' && (phoneNumber.length() != 10 || !correctNumber))
                error = error + '.                                      ' + Label.PM_Contact_Number_Error;
            else if (phoneNumber != null && error != '' && (phoneNumber.length() != 10 || !correctNumber) && error == '') 
                error = Label.PM_Contact_Number_Error;
            // Changes for EDGE-48933
            /*
            if (EnvironmentVariable__c.getValues(EnrichBasketConstants.ENABLE_B2B4).Value__c.equalsIgnoreCase(EnrichBasketConstants.TRUE_STR)) {
            NumberEnrichmentValidationHelper nEhelper = new NumberEnrichmentValidationHelper();
            boolean validMobilityBasket = true;
            validMobilityBasket = nEhelper.validateMobilityProductsInBasket(basketId);
            if (!validMobilityBasket)
            error = Label.Enrich_Basket_NumberError;
            }*/
            ////
            //EDGE-127666
            //Commented by Shubhi/Aman as a part of EDGE-142085 || Start
            /* if (productBasket.Billing_Account__c == null && productBasket.cscfga__Opportunity__r.RecordTypeId == recordTypeId && error != '') {
            //if (error != '')
            error = error + '.                                      ' + Label.Billing_Account_Required_Error;
            }
            else if (productBasket.Billing_Account__c == null && productBasket.cscfga__Opportunity__r.RecordTypeId == recordTypeId && error == '')
            error = Label.Billing_Account_Required_Error; */
            //Commented by Shubhi/Aman as a part of EDGE-142085 || End
            if (productBasket.csordtelcoa__Basket_Stage__c == basketStage) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Enrichment));
                return EnrichBasketConstants.ERROR_STATUS1 + Label.Basket_Already_In_Enrichment + EnrichBasketConstants.CLOSE_BRACKET;
            } if (productBasket.cscfga__Basket_Status__c != EnrichBasketConstants.VALID) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Enrich_Basket_Error));
                return EnrichBasketConstants.ERROR_STATUS1 + Label.Enrich_Basket_Error + EnrichBasketConstants.CLOSE_BRACKET;
            } else
                productBasket.csordtelcoa__Basket_Stage__c = basketStage;
            if (error != '') {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Basket_Already_In_Enrichment)); 
                return EnrichBasketConstants.ERROR_STATUS1 + error + EnrichBasketConstants.CLOSE_BRACKET;
            }
            executeDirectoryBusinessRules(productBasket.id);
            String retVal2 = checkNullRootConfigPcs(basketId);
            if (retVal2 != EnrichBasketConstants.SOME_ERROR)
                return retVal2;
            update productBasket;
            //INC000094308347 - Handling PRM Url for Basket Page
            String redirecturl=FeatureManagement.checkPermission('Partner_User')?'/s/sfdcpage/'+EncodingUtil.urlEncode(EnrichBasketConstants.REDIRECT_URL+basketId, 'UTF-8'):EnrichBasketConstants.REDIRECT_URL+ basketId;
            PageReference ref = new PageReference(redirecturl);ref.setRedirect(true);
            //PageReference ref = new PageReference(EnrichBasketConstants.REDIRECT_URL + basketId);ref.setRedirect(true);
            return EnrichBasketConstants.OK_STATUS + Label.Enrich_Basket_Success + EnrichBasketConstants.REDIRECT_URL_STR + ref.getUrl() + EnrichBasketConstants.CLOSE_BRACKET;
        } catch (Exception e) {
            Logger.getLogger(CustomButtonEnrichBasket.class).debug(e); 
            return EnrichBasketConstants.ERROR_STATUS + Label.Validate_Basket_Stage_Exception + EnrichBasketConstants.CLOSE_BRACKET;
        }
    }
}
/*
* @Author : Rahul/Ritika 
* @Date : 5th May 2019
* @Desc : Handler class for ProductBasketDataSourceConnection
* @Jira : EDGE-66165, EDGE-66484
*/
/***History of Updates 
* Ritika Jaiswal:  19/08/2019  EDGE-98246  For CMP services and devices
* Ritika Jaiswal:  21/08/2019  EDGE-98246  For MDM, CMP - discount, MessageBank and IDD
* Ritika Jaiswal:  21/08/2019  EDGE-104681 For Modify CMP
* Ritika Jaiswal: 30/08/2019   EDGE-110648,109988 Defect fixing for CMP modify 
* Aniket Srivastava : 11/09/2019 Egde - 98374 - TC New Quote/Orderform
* Purushotama Sahu : EDGE-80783 - Get MDM Professional Service Details
* Ritika Jaiswal : BVT defect fixes for Billing-literals
* Vijayalakshmi S: 28/09/2019  EDGE-99894 For Device Outright Purchase
* Aniket Srivastava : 02/10/2019 EDGE-113291 - Defect Fix 
* Vijayalakshmi S: 14/10/2019  EDGE-99894 Changes to fix the quantity issue
* Ritika Jaiswal : 24/10/2019 EDGE - 81135 : CMP cancel 
* Murlidhar Reddy : 31/10/2019 DPG-598 - For IOT Offer
* RaviTeja    07/11/2019 EDGE-101077 - Quote and Order form updates for Mobility Managed Service
* Aniket Srivastava 13/12/2019 EDGE-117738 : ngUC Device Rental and Repayment function added
* Sunil Nangare 13/12/2019 EDGE-117738 : ngUC New Services 
* Aniket Srivastava 13/12/2019 EDGE-127817 : Added function getngUCCancel and calculateRemainingTermngUC for ngUC Cancellation
* Sunil Nangare 13/12/2019 EDGE-127823 : Added code for ngUC Modify
* Vishal Arbune:   01/01/2020  EDGE-117967 : Capture POS redemption information in Quotes
* Vishal Arbune:   10/01/2020  EDGE-114970 : Capturing redemption information in Order form for customer sign off
* Vishal Arbune:   29/01/2020  EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
* Jayesh : 31/01/2020 DPG-1311 : Logic to retrieve Recurring charges for IOT Services
* Jayesh : 20/02/2020 DPG-1454 DPG-1033 : Added method to fetch IoT Cancellation details
* Jayesh : 20/01/2020 DPG-1311 - Label changes
* Vishal Arbune:   05/02/2020  EDGE-123788 Display Delegated Discounts in Quote Document
* Vishal Arbune:   05/02/2020  EDGE-123789 Display Delegated Discounts in Order Form Document
* Vijayalakshmi S:21/01/2020 EDGE-132158 : Fix for DOP Quote
* Yash: Updating Tenancy Solution in Product Family as per Colombo's change | No change in flow | INC000091883668
* Aniket S: 09/02/2020 :EDGE-135025
* Aniket S: 12/02/2020 :EDGE-127780 : Quote changes for TID cancellation
* Aniket S:25/02/2020:EDGE : EDGE-137773 - Prod Incident - INC000092084866
* Vishal Arbune:   10/03/2020  EDGE-123791: Delegation discounts to be displayed in the Quote document(MAC order)        
* Vishal Arbune:   13/03/2020  EDGE-123792: Delegation discounts to be displayed in the Order form document(MAC order)
* Jayesh : 03/04/2020 DPG-1690 - Changes as per Governance review comments
* Vishal Arbune:   30/03/2020 : EDGE-121387 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(New Orders)
* Vishal Arbune:   10/04/2020 : EDGE-133760 : Telstra Collaboration (Next Gen UC): EAP discounts to be displayed in the Quote and Order form documents(MAC Orders)
* Aniket : 14/04/2020 : EDGE-144228 - INC000092458895 fixing
* Aniket : 16/04/2020 : EDGE-144779 - INC000092510399 Fixing
* Aniket/Sunil : 01/05/2020 :EDGE-132608
* Aniket/Sunil : 01/05/2020 :EDGE-142319
* Yash : 03/05/2020 : EDGE-144732 | NGUC Consumption Based Model Changes
* Aniket:21/05/2020 :EDGE-148534 Incident INC000092761770 Fix
* Manish Berad: 11/05/2020 EDGE-144574 | MDM Offer name updates in Quote, Order form, CIS and service terms documents
* Yash/Aniket : 2/07/2020 EDGE-148722 | NGEM Devices


* Sunil : 28/08/2020 | EDGE-162024 - CMP Plan consolidation fix
* Aniket : 13/07/2020 | EDGE-162365 Defect Fix
* Jayesh/Aruna : 20 July 2020 | DPG-1481 - Method to fetch IoT Shared Data Plan Rate Matrix details
* Sunil Nangare/Manish Berad: 28 July 2020 : EDGE-162025 -B2B - Prod INC - Consolidation of Voice to text International call pack - premium & 3G Standard Retail
* Aruna : 11/08/2020 | DPG-2421 - IOT Shared Plan || Recurring charge incorrect in Quote(Coming as 1.64$) 
* Sunil - EDGE-165831 - Product Family and Offer name replace with codes.

* Ravi Shankar/Rajashekar - 09-24-2020 EDGE-170932/EDGE-173365/EDGE-175103 - Transition to Adaptive Mobility changes.
* Sunil - EDGE-165834 - Total Charges summary on order form
* Shradha -15-Oct-2020 EDGE-169456 - Pricing Service & Frame Agreements Package

* Sunil 11-oct-2020 added filter for Prof Incident INC000094305738
* Sandip 25-Nov-2020 EDGE-185178 - Commented CMP Offer check
* Sandip 25-Nov-202  EDGE-181157 - Commented code block

* Payal 27-Nov-2020  EDGE-189788 - Added a Parameter to be passed for getRateCardData method
* Mukta 14-JAN-2021  EDGE-189346 - Modifeid method to fetch rate card date as per new NGUC data model
* Pooja 18-Jan-2021  EDGE-197766 - INC000094731218 Fix, calculation of RedeemFundGST and RedeemFundIncGST  

* Aruna 23-Mar-2021  DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
* Pallavi 08.04.2021 EDGE-209790 Generate order form for CHOWN basket
* Arun/Kshiitiz 10/06/2021 EDGE-204960 Order and quote form changes
* Mahima  18th June 2021 DPG-5624
* Vamsi Krishna Vaddipalli DIGI-1410,DIGI-1412 on 26JUL2021
* Puneeth Kamath 10-Aug-2021 DIGI-3352 B2B-1762 - Offer Name Change
* Lokesh Thathuru DIGI-20532 Prod Incident Optimized the code to fix the 101 soql 
***/ 
/* This class is declared as a global class, since it is required by External Object BasketSnapshot of Cloudsense package.*/
global with sharing class ProductBasketDataHandler {
    static list<cscfga__Product_Configuration__c> prodcList = null;
  static list<cscfga__Product_Configuration__c> parentProdcList = null;//Moved as per OneDeclarationPerLine SCA rule
    //EDGE-117738 Start
    static List<String> parentPCs = new list<String>{'Unified Communication','IP Site','MDM Tenancy','Next Gen Mobility Adaptive Care'}; // DPG-2317
    //EDGE-134876
    //EDGE-165326 added Product Family | Refactoring for this to be taken as part of utility method for EDGE-135349


    //static List<String> productFamilies = new list<String> {'IOT Subscription','Mobile Subscription','Mobility','Tenancy','Professional Services-MDM Config','Telstra Collaboration Professional Servi','Auto Attendant','Hunt Group','Unified Communication Device','Accessory','Main Business Number','User','Device','Enterprise Mobility','Next Generation Voice','Internet Site','Tenancy Solution','Business Calling','Next Generation Mobile Device','Enterprise Mobility Plan'}; //EDGE-148728 | Added NGEM //EDGE-160509-Removed Device Care //EDGE-165326
    //EDGE-165831 - get all product specefication codes for different product families
    public static List<String> productSpecCodes;
    public static List<String> ngUCAcceUCDSpecCode;
    public static List<String> lstEMSpecCodes;
    public static List<String> lstIPSitesSpecCode;    
    public static List<String> lstDeviceSpecCode;
    public static List<String> lstUCESpecCodes;
    public static List<string> lstEnterpriseMobilitySpecCode;
    public static List<string> lstInternetSiteSpecCode;
    public static List<string> lstDevAccSpecCode; //DIGI-14501
    //EDGE-165831 --end    
    String etcAttr = 'EarlyTerminationCharge';//EDGE-148722
    //EDGE-117738 End        
    //EDGE - 117740 Start
    public static string CMPordertype = 'Transition to Corporate Mobile Plus';
    public static string CMPOffer = 'Corporate Mobile Plus';
    //EDGE - 117740 End

    public static string AMSCMPOffertype = 'Transition to Adaptive Mobility';//EDGE-170932
    public static string AMSCMPOffer = Label.ExistingMobPlan;//EDGE-170932  



    public static final string NGUC_OFFER_NAME = Offer_Id__mdt.getInstance('Telstra_Collaboration')?.Template_family__c;
    //public static string ngUCordertype = 'Transition to Telstra Collaboration';
    public static string ngUCordertype = 'Transition to ' + NGUC_OFFER_NAME;
    public static string ngUCOffer = 'ISDN10/20/30 /ISDN2DID/ TIPT/ TIPT SIPC/PSTN';//Changed as per EDGE-217484 defect
    //EDGE-80772 : Updated for Solution Console retrofit
    //EDEG-98246 :Start

    //EDGE-165831
    public static Map<String,String> offerId_Vs_OfferCode = new Map<String,String>();

            //Defect - EDGE-109988  
            static List<String> minimumCommitmentAvailable = new List<String>{'DMCAT_Offer_000303','DMCAT_Offer_000646','DMCAT_Offer_000618','DMCAT_Offer_000854','DMCAT_Offer_000709','DMCAT_Offer_001551','DMCAT_Offer_001562'}; //EDGE-165326 | Added NGEMPlan //EDGE-165488
                static List<String> importantInformationAvailable = new List<String>{'DMCAT_Offer_000303','DMCAT_Offer_000618','DMCAT_Offer_000854','DMCAT_Offer_000750','DMCAT_Offer_000936','DMCAT_Offer_000709','DMCAT_Offer_001551','DMCAT_Offer_001562'};                                       
                    static Set<String> offers = null;
    static final String mobileSubscription = 'DMCAT_ProductSpecification_000420';//EDGE-148534
    static final String internetSite = 'DMCAT_ProductSpecification_000747';//EDGE-148534
    static final String cwpId = 'DMCAT_Offer_000303';
    static final String xBYOOfferName = 'X-Large Data SIM BYO';
    static final String businessCalling = 'DMCAT_ProductSpecification_000871';//EDGE-132608
    static final String unifiedCommunicationDevice = 'DMCAT_ProductSpecification_000622'; //EDGE-144732
    static final String accessory = 'DMCAT_ProductSpecification_000623'; //EDGE-144732 
    static final String pphhId = 'DMCAT_Offer_000646';
    //EDGE-81548
    static final String mdmId = 'DMCAT_Offer_000681';
    static final String tcId = 'DMCAT_Offer_000618';
    //changes start for 99894
    static final String dopId = 'DMCAT_Offer_000783';
    //changes start for 99894
    //EDGE-123562
    static final String mmsId = 'DMCAT_Offer_000854';
    static final String psMdmId = 'DMCAT_Offer_000750';
    static final String telCollabPSId = 'DMCAT_Offer_000936';
    static final String ammsLCId = 'DMCAT_Offer_001551';
    static final String ammsInTuneId = 'DMCAT_Offer_001562';
    //change start for DPG-598
    //static final String iotId = 'DMCAT_Offer_000964';    //change end for DPG-598
    //EDGE-98336 
    static final String tidId = 'DMCAT_Offer_000709'; 
    static final String ngemId = 'DMCAT_Offer_001231'; //EDGE-148728 
    static final String ngemPlanId = 'DMCAT_Offer_001233'; //EDGE-148728
    static final String ngemDeviceProdSpecId = 'DMCAT_ProductSpecification_001211'; // EDGE-172118

    static final String AMDeviceProdSpecId = 'DMCAT_ProductSpecification_001342'; // EDGE-191284


    static final String ngemAccProdSpecId= 'DMCAT_ProductSpecification_001389'; // DPG-3508-3708


    static final String ngemDeviceCare = 'DMCAT_ProductSpecification_001208'; //EDGE-176688
    static final String RedeemFund = 'RedeemFundCopy' ; //EDGE-164623
   static final String AdaptiveCareId = 'DMCAT_Offer_001251'; // DPG-2317-- Mahima


    static final String deviceProdSpecificationId = 'DMCAT_ProductSpecification_000423';//EDGE-188062
    static final String IoTConnectivity = 'IoT Connectivity';//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
    //EDGE-216201 Start
    Static Map <String, List<Double>> offerRedeemAmtMap = null;
    Static Map <String, Map <String, List<Double>>> basketRedeemMap = new Map <String, Map <String, List<Double>>> ();
    //EDGE-216201 End
    public ProductBasketDataHandler() {
        //EDGE-165831 - start
        AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
        productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
        ngUCAcceUCDSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('NGUCAcceUCD'));
        lstEMSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('EMSpecCodes'));
        lstIPSitesSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('IPSitesSpecCode'));      
        lstDeviceSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('DeviceSpecCode'));
        lstUCESpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('UCESpecCodes'));
        lstEnterpriseMobilitySpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('EnterpriseMobilitySpecCode'));
        lstInternetSiteSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('InternetSiteSpecCode'));
        lstDevAccSpecCode = new List<String>(AllCQEnvironmentVariable.getValueAsList('DevAccSpecCode'));//DIGI-14501
        //EDGE-165831 - end
    }


    //helper method to get child product-configurations of basket 
    public static list<cscfga__Product_Configuration__c> getPCsForBasket(String basketId){               
        if(prodcList!=null)
            return prodcList;
        else{  
            //EDGE-113291 Added 'Telstra Collaboration' in below query 
            //EDGE-117967 Added 'Device Outright Purchase' in below query


            //EDGE-165326 added Product Family | Refactoring for this to be taken as part of utility method for EDGE-135349
            /*prodcList=[SELECT id,cscfga__Parent_Configuration__r.Offername__c,cscfga__Parent_Configuration__r.Offer_Reference__r.Name,cscfga__Parent_Configuration__r.Name,cscfga__Parent_Configuration__c,cscfga__Contract_Term__c,cscfga__total_one_off_charge__c,cscfga__Parent_Configuration__r.cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,cscfga__Parent_Configuration__r.cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,(select id,name,cscfga__Value__c from cscfga__Attributes__r where name='CaseStatus') from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketId and (Commercial_Config__c='Yes' or cscfga__Product_Family__c IN ('Professional Services-MDM Config','Tenancy','Telstra Collaboration Professional Servi','Managed Services','Telstra Collaboration Solution','Device Outright Purchase Solution','Enterprise Mobility','Internet Of Things','IOT Subscription','Device Outright Purchase','Internet Site','Tenancy Solution','Next Generation Mobile Device','Mobile Device Care','Enterprise Mobility Plan'))];*/
            // Refactor filter
            prodcList=[SELECT id,Marketable_Offer__r.Offer_ID__c,cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c,csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,cscfga__Parent_Configuration__r.Offername__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__r.Offer_Reference__r.Name,cscfga__Parent_Configuration__r.Name,cscfga__Parent_Configuration__c,cscfga__Contract_Term__c,cscfga__total_one_off_charge__c,cscfga__Parent_Configuration__r.cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,cscfga__Parent_Configuration__r.cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,(select id,name,cscfga__Value__c from cscfga__Attributes__r where name='CaseStatus') from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basketId and (Commercial_Config__c='Yes' or cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes)];
            //Refactor filter end 


// system.debug('Inside ProductBasketDataHandler:: prodcList = ' + prodcList );            
            return prodcList;
        }  
    }
    //helper method to get distinct offers added in the basket
    public static Set<String> getOffersInBasket(String basketId){
        if(offers!=null)
            return offers;
        else{ 
            offers = new Set<String>();   
 // system.debug('getOffersInBasket: offers..'+offers);               
            //list<cscfga__Product_Configuration__c> prodcList = getPCsForBasket(basketId);
            String temp='';
            for(cscfga__Product_Configuration__c pcloop:getPCsForBasket(basketId)){
                // system.debug('pcloop.Offername__c-->'+pcloop.Offername__c);
                // system.debug('pcloop.Marketable_Offer__r.Offer_ID__c-->'+pcloop.Marketable_Offer__r.Offer_ID__c);
                if(!String.isBlank(pcloop.Offername__c)){
                    //offers.add(getOfferFamily(pcloop.Offername__c));
                    //EDGE-165831 - changed method parameter
                    offers.add(getOfferFamily(pcloop.Marketable_Offer__r.Offer_ID__c));
                }
                if(pcloop.cscfga__Parent_Configuration__c!=null && !String.isBlank(pcloop.cscfga__Parent_Configuration__r.Offername__c)){
                    //offers.add(getOfferFamily(pcloop.cscfga__Parent_Configuration__r.Offername__c));
                    //EDGE-165831 - method parameter change
                    offers.add(getOfferFamily(pcloop.cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c));
                }
            }
            system.debug('getOffersInBasket outside for : '+offers);                           
            return offers;
        }
    }
    public static List<Offer_Id__mdt> lstOfferIds = [Select MasterLabel,Template_Family__c,IsActive__c from Offer_Id__mdt where IsActive__c = true];
    //helper method to identify the offer-family for a selected offer
    public static String getOfferFamily(String offerName){
        //EDGE-165831 - replaced offer name with offer code.
        // system.debug('lstOfferIds-->'+lstOfferIds);
        if(!lstofferIds.isEmpty()){
            for(Offer_Id__mdt oids:lstofferIds){
                offerId_Vs_OfferCode.put(oids.MasterLabel,oids.Template_Family__c);  
                
            }    
        }
        // system.debug('offerId_Vs_OfferCode-->'+offerId_Vs_OfferCode);
        //return Offer_vs_OfferFamily.get(offerName);
        return offerId_Vs_OfferCode.get(offerName);
    }
    //helper method to get status of Case-record(for ETC waiver) created for an opportunity 
    public static Map<id,String> getCaseStatusMap(String basketId){
        Map<id,String> caseStatusMap= new Map<id,String>();       
        // list<cscfga__Product_Configuration__c> prodcList = getPCsForBasket(basketId);
        for(cscfga__Product_Configuration__c pcloop:getPCsForBasket(basketId)){
            for(cscfga__Attribute__c at:pcloop.cscfga__Attributes__r ){
                if(at.cscfga__Value__c!=null){
                    caseStatusMap.put(pcloop.cscfga__Parent_Configuration__c,at.cscfga__Value__c);
                }
            }
        }
        return caseStatusMap;
    }
    //Helper method to check if the account has an active Contract for the same offer
    public static boolean checkifContractExistsForAccount(String basketId,String Offer){       
        Boolean ExistingContract=false;
        //start defect - 59875
        List<String> inactiveContractStatus=new List<String>{'Signature Declined','Cancelled','Void'}; 
            String soqlOnExistingContract='select id from ContractJunction__c where Related_Basket__c!=\''+ String.escapeSingleQuotes(basketId) +'\' and account__c IN(select csbb__Account__c from cscfga__Product_Basket__c where id=\''+ String.escapeSingleQuotes(basketId) +'\') and BSA_Generated__c =true and Status__c not in :inActiveContractStatus';
        //end defect - 59875
        List<ContractJunction__c> Cj=Database.query(soqlOnExistingContract);
        if(Cj.size()>0)
            return true;
        else
            return false;
    }
    //Method to bring data for table 'Changes to Existing Services' in Summary section of Quote/Orderform
    public List<Map<String,Object>> getSummaryForChangesToExisting(String basketID){
        //Map to maintain different types of orders in basket - Transition,Change,Cancel
        //EDGE-164623
         Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
         String ngemCarePDName = 'Mobile Device Care';
         List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
         for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
             if(ngemSpec.ProductCategory__c=='NGEM'){
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
             }
         }
        //EDGE-164623 End 
        //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration', EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
        Map<String,List<Map<String,Object>>> summaryOfOrder =new Map<String,List<Map<String,Object>>>{DataHandlerConstants.modifyChangeType => new List<Map<String,Object>>() , 'Transition to Connected Workplace' => new List<Map<String,Object>>(),'Transition to Corporate Mobile Plus' => new List<Map<String,Object>>(), 'Transition to Adaptive Collaboration'=> new List<Map<String,Object>>(),'Transition to Adaptive Mobility' => new List<Map<String,Object>>(),'Cancel' => new List<Map<String,Object>>()};
        Double sumOfNoFaultRedemption = 0.0;





            List<Map<String,Object>> rows = new List<Map<String,Object>>();
        //query to get PCR for IP-site 
        //EDGE-80772 : Rewritten for Solution Console retrofit
        //EDGE-110648 : Defect fix for Modify of CMP 
        // system.debug('*****Inside getSummaryForChangesToExisting');   
        //EDGE-127780 Start
        List<cscfga__Product_Configuration__c> planTCPCList = new List<cscfga__Product_Configuration__c>();
    //EDGE-148534 Modified below query
    planTCPCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN (:mobileSubscription,:internetSite) AND cscfga__Product_Basket__c = :basketID AND Type__c='Cancel'];
        //planTCPCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,csordtelcoa__Replaced_Subscription__r.Billing_Account__r.Billing_Account_Number__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Family__c IN ('Internet Site') AND cscfga__Product_Basket__c = :basketID AND Type__c='Cancel'];
       //EDGE-148534 Start
       if(basketID == null)
       {
           return rows;
       }  
       //EDGE-148534  End
    // system.debug('planTCPCList@@:::' + planTCPCList);
        Map<Id,String> map_PCvsETCAttrib = new Map<Id,String>(); 
    for(cscfga__Product_Configuration__c pc:planTCPCList)
        {
            // system.debug('pc@@::' + pc.name);
      for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r)
                {
          // system.debug('attribute.name@@:::' + attribute.name);
                    if(attribute.name=='EarlyTerminationCharge')
                    {
      // system.debug('attribute.value@@:::' + attribute.cscfga__Value__c);            
            map_PCvsETCAttrib.put(pc.id,attribute.cscfga__Value__c);
          }
        }
    }  
     system.debug('map_PCvsETCAttrib@@:::' + map_PCvsETCAttrib);  
    //EDGE-127780 End  
        List<String> parentPCs = new list<String>{'Unified Communication','IP Site','MDM Tenancy','Next Generation Voice','Enterprise Mobility'};
            //EDGE-165326 added Product Family | Refactoring for this to be taken as part of utility method for EDGE-135349

        //List<String> productFamilies = new list<String>{'Mobile Subscription','Mobility','Tenancy','Accessory','Unified Communication Device','Next Generation Voice','Enterprise Mobility','Internet Site','Tenancy Solution','Business Calling','Next Generation Mobile Device','Enterprise Mobility Plan'}; //EDGE-132608: Added Business Calling     
                /*String queryPCR = 'select id,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,'+

                'cscfga__unit_one_off_charge__c,cscfga__Product_Family__c,'+
                'name,cscfga__Contract_Term__c,'+
                'Type__c,OfferName__c,Offer_Reference__r.Name,'+
                'csordtelcoa__Replaced_Product_Configuration__c,'+
                'csordtelcoa__Replaced_Subscription__r.Name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r),'+//EDGE-148722 - Added attributes inner query
                '(select id,name from attachments where name like \'%Transition%\')'+
                ' from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+String.escapeSingleQuotes(basketID) +'\'  and (name IN :parentPCs or (cscfga__Product_Family__c IN :productFamilies)) AND Type__c NOT IN (\'Active\')'; //EDGE-110648 : Defect fix for Modify of CMP*/

        /*String queryPCR = 'select id,Marketable_Offer__r.Offer_ID__c,csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,'+

                'cscfga__unit_one_off_charge__c,cscfga__Product_Family__c,'+
                'name,cscfga__Product_Basket__r.name,cscfga__Contract_Term__c,'+
                'Type__c,OfferName__c,Offer_Reference__r.Name,'+
                'csordtelcoa__Replaced_Product_Configuration__c,'+
                'csordtelcoa__Replaced_Subscription__r.Name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r),'+//EDGE-148722 - Added attributes inner query
                '(select id,name from attachments where name like \'%Transition%\')'+

                ' from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+String.escapeSingleQuotes(basketID) +'\'  and cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND Type__c NOT IN (\'Active\')';*/
        List<cscfga__Product_Configuration__c> pcrlist = Database.query('select id,Marketable_Offer__r.Offer_ID__c,csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c,cscfga__One_Off_Charge__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,'+
                'cscfga__unit_one_off_charge__c,cscfga__Product_Family__c,'+
                'subtype__c,name,cscfga__Product_Basket__r.name,cscfga__Contract_Term__c,'+
                'Type__c,OfferName__c,Offer_Reference__r.Name,'+
                'csordtelcoa__Replaced_Product_Configuration__c,'+
                'csordtelcoa__Replaced_Subscription__r.Name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r),'+//EDGE-148722 - Added attributes inner query
                '(select id,name from attachments where name like \'%Transition%\')'+
                ' from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+String.escapeSingleQuotes(basketID) +'\'  and cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND Type__c NOT IN (\'Active\')');

        //query to get body of all TransitionJSON for basket 
        String soqlQueryAttachment = 'SELECT Id,name,body,ParentId FROM Attachment WHERE ParentId IN(SELECT Id FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c=\''+ String.escapeSingleQuotes(basketID) +'\') and name like \'%Transition%\'';        
        // system.debug('soqlQueryAttachment Test--->'+soqlQueryAttachment);
        Map<id,string> pcrWithAttachment = new Map<id,string> ();
        // EDGE-155245 Added flag for transition
        boolean isTransition;
        for(Attachment att:Database.query(soqlQueryAttachment)){
            pcrWithAttachment.put(att.ParentId,att.body.tostring());
            isTransition = true;
        }
        // system.debug('pcrWithAttachment Test--->'+pcrWithAttachment); 
        String tempOffername='';        String CMPConfig= System.Label.ProductSpecificationMobile;//EDGE - 117740
        //Manoj : EDGE-117738
        List < String > productSpecNgUcList = Label.ProductSpecificationNgUc.split(',');
        // system.debug('productSpecNgUcList -->'+productSpecNgUcList);
        Boolean contractExists = checkifContractExistsForAccount(basketID,'');
        Map<id,String> caseStatusMap = getCaseStatusMap(basketID);
        Set<String> offers = new Set<String>();
        Map<String,Object> row = null;
        Integer externalId = 1;
        // system.debug('pcrlist list-->'+pcrlist);
        //EDGE-204960 Start
        String oneOffPaymentTypeValue = 'Purchase';        String repaymentPaymentTypeValue = 'Hardware Repayment';
        //EDGE-204960  End
         String paymentType = '';
        system.debug('pcrlist list-->'+pcrlist);
        //EDGE-80772 : Rewritten for Solution Console retrofit -Start
        for(cscfga__Product_Configuration__c prConfigRequest:pcrlist){
            // system.debug('prConfigRequest.type__c@@@::' + prConfigRequest.type__c+':::'+prConfigRequest.name+':::'+prConfigRequest.cscfga__Product_Family__c);
            row = new Map<String,Object>();             
            // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:For Modify:'+prConfigRequest);
            //check if the PC are of modify-type
            if((prConfigRequest.type__c=='New' && contractExists==true)||(prConfigRequest.type__c=='Modify'|| prConfigRequest.csordtelcoa__Replaced_Product_Configuration__c!=null)){
                // system.debug('Inside prConfigRequest.type__c==New');
                // tempOffername = (String.valueOf(prConfigRequest.OfferName__c)==null?prConfigRequest.csordtelcoa__Replaced_Subscription__r.Name:String.valueOf(prConfigRequest.OfferName__c));
                //EDGE-165831 - Chnaged method parameter
                tempOffername = (String.valueOf(prConfigRequest.Marketable_Offer__r.Offer_ID__c)==null?prConfigRequest.csordtelcoa__Replaced_Subscription__r.MarketableOffer__r.Offer_ID__c:String.valueOf(prConfigRequest.Marketable_Offer__r.Offer_ID__c));
                // system.debug('tempOffername-->'+tempOffername);
                //EDGE-165831 end
                tempOffername = getOfferFamily(tempOffername);
                row.put('Existing_Service',tempOffername);
                //offers.add(tempOffername);//EDGE-173365
                //end EDGE-67629   
                if(prConfigRequest.type__c=='Cancel'){
                    // system.debug('Inside prConfigRequest.type__c==Cancel');
                    // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:For Cancel:'+prConfigRequest);
                    row.put('Order_Type','Cancel');
                    // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:Case for Cancel:'+caseStatusMap.get(prConfigRequest.id));
                    if(caseStatusMap.get(prConfigRequest.id)!=null){
                        // system.debug('caseStatusMap.get(prConfigRequest.id)!=null');
                        row.put('GSTExcl_TotalETC','Waived'); 
                        row.put('GSTIncl_TotalETC','Waived'); 
                    }
                    else{
                        //Manoj : EDGE : 63432 : 05/Feb/2019 : Start 
                        // system.debug('Inside else');
                        /*row.put('GSTExcl_TotalETC','$'+prConfigRequest.cscfga__unit_one_off_charge__c); 
                        row.put('GSTIncl_TotalETC','$'+calculateGSTIncludedPrice(prConfigRequest.cscfga__unit_one_off_charge__c)); */
                        //EDGE-148722 Start
                        //EDGE-204960  Start
                        for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
                            if(attribute.name == 'PaymentTypeString'){
                               paymentType = attribute.cscfga__Value__c;
                               system.debug('paymenttype--_1'+paymentType);
                               break;
                           }
                       }
                       //EDGE-204960  End
   for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
       system.debug('prConfigRequest--1'+prConfigRequest);
       system.debug('paymentType--1'+paymentType.equals('other'));
                       if(isValidId(attribute.cscfga__Value__c)==False){
                           system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:RC:Cancel Attribute with Value: '+attribute);
                           if(attribute.name.equals(etcAttr) && attribute.cscfga__Value__c != null && 
                              prConfigRequest.cscfga__Product_Definition__r.product_Specification__c!=deviceProdSpecificationId && prConfigRequest.subType__c != 'No Fault Return'){ //EDGE-174805 added overridden null check. No changes in Test Class
                               row.put('GSTExcl_TotalETC','$'+string.valueOf(attribute.cscfga__Value__c));
                               if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                   row.put('GSTIncl_TotalETC','$'+string.valueOf(attribute.cscfga__Value__c));
                               }
                               else{
                                   row.put('GSTIncl_TotalETC','$'+string.valueOf(calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                               }
                               system.debug('row@@cancel@@' + row);
                           }
                           //EDGE-204960  Start 
                           else if(prConfigRequest.subType__c == 'No Fault Return' && paymentType.equals(oneOffPaymentTypeValue) 
                                   && attribute.name.equals('OC') && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''/* DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){//display one month charges in case of HRO- no fault return
                                       
                                       double existingETC = (decimal.valueOf(attribute.cscfga__Value__c)*(-1));
                                       row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                       if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                        row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                        }
                                    else{
                                        row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                        }
                                       
                                       System.debug('purchase NFR GST == '+row+'   '+attribute.id);
                                   }
                          else if(prConfigRequest.subType__c == 'No Fault Return' && paymentType.equals(repaymentPaymentTypeValue) 
                                   && attribute.name.equals('RC') && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''/*DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){//display one month charges in case of HRO- no fault return
                                       
                                       double existingETC = (decimal.valueOf(attribute.cscfga__Value__c)*(-1));
                                       row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                       if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                            row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                            }
                                        else{
                                            row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                            }
                                       
                                       
                                       System.debug('HRO NFR GST == '+row+'   '+attribute.id);
                                   }
                           
                           else if((prConfigRequest.subType__c != null && prConfigRequest.subType__c.equals('No Fault Return') ) && paymentType.equals(oneOffPaymentTypeValue) && attribute.name.equals('RedeemFundCopy') 
                                   && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != '' /*DIGI-6250 Starts*/ && double.valueof(attribute.cscfga__Value__c) != 0 /*DIGI-6250 Ends*/){ 
                                       
                                       sumOfNoFaultRedemption = sumOfNoFaultRedemption +Double.valueOf(attribute.cscfga__Value__c);
                                       double existingETC = double.valueOf(attribute.cscfga__Value__c); 
                                       System.debug('Before redeemfundcopy NFR GST == '+row+'   '+attribute.id);
                                       row.put('GSTExcl_TotalETC','$'+string.valueOf(existingETC));
                                       if(lstDevAccSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && FeatureEligibilityChecker.determineFeatureEligiblity('DIGI14501', 'DeviceAcc')){
                                            row.put('GSTIncl_TotalETC','$'+string.valueOf(existingETC));
                                        }
                                    else{
                                        row.put('GSTIncl_TotalETC','$'+string.valueOf(ProductBasketDataHandler.calculateGSTIncludedPrice(existingETC)));
                                        }
                                       
                                       System.debug('redeemfundcopy NFR GST == '+row+'   '+attribute.id);  
                                   } 
                           //EDGE-204960  End
                       }
       //EDGE-148722 End
    }
                  
                        //Manoj : EDGE : 63432 : 05/Feb/2019 : End
                    }
                    offers.add(tempOffername); //EDGE-173365
                    System.debug('Adding row ========= '+row);//DIGI-6250 change location to loop
                    summaryOfOrder.get('Cancel').add(row);//DIGI-6250 change location to loop
                    system.debug('summaryOfOrder@@::' + summaryOfOrder);
                }
                else{
                    //EDGE-147912 | Excluding PaidOut details // EDGE-155245 excluded Transition pc 

                    //if((!((prConfigRequest.cscfga__Product_Family__c=='Accessory' || prConfigRequest.cscfga__Product_Family__c=='Unified Communication Device') && prConfigRequest.cscfga__unit_one_off_charge__c!=0)) && prConfigRequest.type__c!='PaidOut' && isTransition != true){
                    // refactor
            if((!(ngUCAcceUCDSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__unit_one_off_charge__c!=0)) && prConfigRequest.type__c!='PaidOut' && isTransition != true){

                    // system.debug('Inside else row.put');
                   // row.put('Order_Type','Change');
                    //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration',EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
                    row.put('Order_Type',DataHandlerConstants.modifyChangeType);
                    row.put('GSTExcl_TotalETC','$0.00');
                    row.put('GSTIncl_TotalETC','$0.00');
                        //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration',
                    offers.add(tempOffername); //EDGE-173365
                    summaryOfOrder.get(DataHandlerConstants.modifyChangeType).add(row);//EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'
                }
                }    
                row.put('ExternalId', String.valueOf(externalId));
                rows.add(row);
                externalId++;
            }else if(prConfigRequest.type__c=='New'){    //EDGE-80772 : Rewritten for Solution Console retrofit - End
                for(attachment attachment:prConfigRequest.attachments){
                    // system.debug('Inside only New');
                    // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:For Transition:'+attachment);
                    ReplicatorGetServiceDataObject serviceObjDTO = ReplicatorGetServiceDataObject.parse(pcrWithAttachment.get(prConfigRequest.id));
                    // system.debug('serviceObjDTO --->'+serviceObjDTO);
                    // system.debug('serviceObjDTO.site--->'+serviceObjDTO.site);
                    // EDGE - 117740 - Transitin fro Brand New account
                    Map<String,Object> newTransrow = new Map<String,Object>();
                    // system.debug('cscfga__Product_Family__c-->'+prConfigRequest.cscfga__Product_Family__c);
                    // system.debug('prConfigRequest.cscfga__Product_Definition__r.product_Specification__c-->'+prConfigRequest.cscfga__Product_Definition__r.product_Specification__c);
            // filter change
                    if(lstEMSpecCodes.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == CMPConfig){
                                    // system.debug('inside CMP transition loop');
                                    newTransrow .put('Existing_Service',String.valueOf(CMPOffer));
                                    offers.add(String.valueOf(CMPOffer));
                                    newTransrow.put('Order_Type',CMPordertype );
                              //EDGE-150587 - ETC changed from Waived to NA- Not available
                                    newTransrow.put('GSTExcl_TotalETC','NA- Not available');
                                    newTransrow.put('GSTIncl_TotalETC','NA- Not available');
                                    newTransrow.put('ExternalId', String.valueOf(externalId));
                                    rows.add(newTransrow);
                                    externalId++;
                                    summaryOfOrder.get(CMPordertype).add(newTransrow);
                                    // system.debug('summaryrows for transition-->'+summaryOfOrder);
                    }
            // EDGE-117738 Transition nguc,EDGE-210438 Fetch value from DataHandlerConstants
                    if((prConfigRequest.cscfga__Product_Family__c==DataHandlerConstants.ngUCPlan) && productSpecNgUcList.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){
                                   // system.debug('inside nguc transition loop for new account');
                                    newTransrow.put('Existing_Service',String.valueOf(ngUCOffer));
                                    offers.add(String.valueOf(ngUCOffer));
                                    newTransrow.put('Order_Type',ngUCordertype );
                                    newTransrow.put('GSTExcl_TotalETC','NA - Not Applicable');//EDGE-210438
                                    newTransrow.put('GSTIncl_TotalETC','NA - Not Applicable');//EDGE-210438  
                                    newTransrow.put('ExternalId', String.valueOf(externalId));
                                    // system.debug('newrow nguc-->'+newTransrow);
                                    rows.add(newTransrow);
                                    externalId++;
                                    summaryOfOrder.get(ngUCordertype).add(newTransrow);
                                    // system.debug('summaryrows for transition nguc new-->'+summaryOfOrder);
                    }
                    // end
                    if(serviceObjDTO.site!=null){
                    for(ReplicatorGetServiceDataObject.SiteDTO siteObj : serviceObjDTO.site)
                    {
                        // system.debug('siteObj.productList--->'+siteObj.productList);
                        for(ReplicatorGetServiceDataObject.ProductDTO prod: siteObj.productList)
                        {
                            Map<String,Object> newrow = new Map<String,Object>();                           
                            if(prod.checkValue){
                // filter change
                                if(lstIPSitesSpecCode.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){//EDGE - 117740
                                    newrow.put('Existing_Service',String.valueOf(prod.Product_Type));
                                    offers.add(String.valueOf(prod.Product_Type));
                                    newrow.put('Order_Type','Transition to Connected Workplace');
                                    //EDGE-150587 - ETC changed from Waived to NA- Not available
                                    newrow.put('GSTExcl_TotalETC','NA- Not available');
                                    newrow.put('GSTIncl_TotalETC','NA- Not available');   
                                    newrow.put('ExternalId', String.valueOf(externalId));
                                    rows.add(newrow);
                                    externalId++;
                                    summaryOfOrder.get('Transition to Connected Workplace').add(newrow);
                                }
                           }
                        }
                    }
                    }                    
                }                
            }
            // Changed for 117740 - Start for existing CMP.
            if(prConfigRequest.type__c=='New'){                
                // system.debug('Inside transition loop--->'+prConfigRequest.attachments);
                // system.debug('Product Family--->'+prConfigRequest.cscfga__Product_Family__c);
                // system.debug('Specification-->'+prConfigRequest.cscfga__Product_Definition__r.product_Specification__c);
                for(attachment attachment:prConfigRequest.attachments){
                    Map<String,Object> newrow = new Map<String,Object>();
            // EDGE-165831 - Query Filter Change
                    if(lstEMSpecCodes.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c) && prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == CMPConfig){
                                    // system.debug('inside CMP transition loop');
                                    newrow.put('Existing_Service',String.valueOf(CMPOffer));
                                    offers.add(String.valueOf(CMPOffer));
                                    newrow.put('Order_Type',CMPordertype );
                              //EDGE-150587 - ETC changed from waived to NA- Not available
                                    newrow.put('GSTExcl_TotalETC','NA- Not available');
                                    newrow.put('GSTIncl_TotalETC','NA- Not available');
                                    newrow.put('ExternalId', String.valueOf(externalId));
                                    rows.add(newrow);
                                    externalId++;
                                    summaryOfOrder.get(CMPordertype).add(newrow);
                                    // system.debug('summaryrows for transition-->'+summaryOfOrder);
                    }
                    system.debug('NGUCConfig-->'+prConfigRequest.cscfga__Product_Definition__r.product_Specification__c);
                    //NGUC Transition : Manoj : EDGE-117738 Transition Start,EDGE-210438 - fetching value from DataHandlerConstants
                      if((prConfigRequest.cscfga__Product_Family__c==DataHandlerConstants.ngUCPlan) && productSpecNgUcList.contains(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c)){
                                    system.debug('inside nguc transition loop');
                                    newrow.put('Existing_Service',String.valueOf(ngUCOffer));
                                    offers.add(String.valueOf(ngUCOffer));
                                    newrow.put('Order_Type',ngUCordertype );
                                    newrow.put('GSTExcl_TotalETC','NA - Not Applicable');//EDGE-210438
                                    newrow.put('GSTIncl_TotalETC','NA - Not Applicable');//EDGE-210438 
                                    newrow.put('ExternalId', String.valueOf(externalId));
                                    // system.debug('newrow nguc-->'+newrow);
                                    rows.add(newrow);
                                    externalId++;
                                    summaryOfOrder.get(ngUCordertype).add(newrow);
                                    // system.debug('summaryrows for transition-->'+summaryOfOrder);
                    }
                    //NGUC Transition : Manoj : End                
                }                
            } // Changed for 117740 - End
        }
        //EDGE-173365 --- Start
        List<Legacy_Service__c> legacySrvLst = [SELECT Id FROM Legacy_Service__c WHERE Product_Basket__c=:basketID AND Product_Type__c='Enterprise Mobility' AND Select__c = TRUE];
        if(legacySrvLst != null && legacySrvLst.size()>0){
            // system.debug('AMSCMPOffer for legacy transition-->');
            Map<String,Object> newAMTransRow = new Map<String,Object>();
            newAMTransRow.put('Existing_Service',String.valueOf(AMSCMPOffer));
            newAMTransRow.put('Order_Type',AMSCMPOffertype);
            newAMTransRow.put('GSTExcl_TotalETC','N/A');
            newAMTransRow.put('GSTIncl_TotalETC','N/A');
            newAMTransRow.put('ExternalId', String.valueOf(externalId));
            externalId++;
            offers.add(String.valueOf(AMSCMPOffer));
            rows.add(newAMTransRow);
            summaryOfOrder.get(AMSCMPOffertype).add(newAMTransRow); 
        }




        //EDGE-173365 --- End    
         system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:summaryOfOrder'+summaryOfOrder);
        rows=groupByOrderTypeAndExistingService(summaryOfOrder,offers);        

         //EDGE-164623
        decimal totalVal=0;
        for(cscfga__Product_Configuration__c prConfigRequest:pcrlist){
             if(prConfigRequest.cscfga__Product_Definition__r.product_Specification__c == map_PDvsSecId.get(ngemCarePDName).ProdSpecId__c){
                        for(cscfga__Attribute__c attribute:prConfigRequest.cscfga__Attributes__r) {
                            if(attribute.name.equals(RedeemFund) && attribute.cscfga__Value__c != '0.00' && string.isNotEmpty(attribute.cscfga__Value__c) )
                                {
                                    totalVal = totalVal + decimal.valueof(attribute.cscfga__Value__c);
                                } 
                        }
                  }
        }   
        if(totalVal > 0){
        totalVal = 0 - totalVal;
            Map<String,Object> appleCareOneFund = new Map<String,Object>();
            appleCareOneFund.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Credit);
            appleCareOneFund.put('ExternalId', String.valueOf(externalId));              
            appleCareOneFund.put('GSTExcl_TotalETC',string.valueOf(totalVal));     //EDGE-197766: Modified          
            appleCareOneFund.put('GSTIncl_TotalETC',string.valueOf((totalVal*1.1).setScale(2))); //EDGE-197766: Modified


            rows.add(appleCareOneFund);
            externalId++;
        }
        //EDGE-164623 End 
        //EDGE-155059 Start
        String basketName = pcrlist[0].cscfga__Product_Basket__r.name;//Changed logic for fetching basketname as per review comments for EDGE-155059
        // system.debug('basketName@@::' + basketName);
        Double sumOfBasketRedemption=0;
        sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);


         system.debug('sumOfBasketRedemption@@::' + sumOfBasketRedemption);
        if(sumOfBasketRedemption != 0){
        Map<String,Object> rowRdeem = new Map<String,Object>();
                 sumOfBasketRedemption = 0 - sumOfBasketRedemption;
                rowRdeem.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Fund);
                rowRdeem.put('ExternalId', String.valueOf(externalId));             
                rowRdeem.put('GSTExcl_TotalETC',sumOfBasketRedemption);      //EDGE-197766: Modified                    
                rowRdeem.put('GSTIncl_TotalETC',(sumOfBasketRedemption*1.1).setScale(2)); //EDGE-197766: Modified          
                rows.add(rowRdeem);
        externalId++;
            }
            //EDGE-204960  Start
    System.debug('sumOfNoFaultRedemption == '+sumOfNoFaultRedemption);
    /*sumOfNoFaultRedemption = 0 - sumOfNoFaultRedemption;*/
    if(sumOfNoFaultRedemption > 0){
        Map<String,Object> rowRdeem = new Map<String,Object>();               
        rowRdeem.put('Existing_Service',System.Label.Telstra_Enterprise_Plus_Fund_Credit);
        rowRdeem.put('ExternalId', String.valueOf(externalId));             
        rowRdeem.put('GSTExcl_TotalETC',sumOfNoFaultRedemption);      //EDGE-197766: Modified                    
        rowRdeem.put('GSTIncl_TotalETC',(sumOfNoFaultRedemption*1.1).setScale(2)); //EDGE-197766: Modified          
        rows.add(rowRdeem);
        externalId++;
    }
    //EDGE-204960  End
        //EDGE-155059 End
        // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForChangesToExisting:rows'+rows);
        //Changes End- EDGE-44968
        return rows;
    }
    /* ****************************************************************************
* Author : Manoj Kumar
* Date : 29 Jan 2019
* Description : This method is used to calculate the GST price of product
* Parameters : integer, Integer
* Return Integer
* *****************************************************************************/
    public static Decimal calculateGSTIncludedPrice(Decimal onceOffCharge){
        Decimal rateOfGST = Decimal.valueOf(Label.GSTChargeRate);
        onceOffCharge = onceOffCharge + onceOffCharge * rateOfGST;
        Decimal chargesIncGST = onceOffCharge.setScale(2);
        return chargesIncGST;
    }
    //Method to group line-items in Summary-ChangesToExisting table by OrderType and Service  
    public static List<Map<String,Object>> groupByOrderTypeAndExistingService(Map<String,List<Map<String,Object>>> summaryOrder,Set<String> offerName){
        //EDGE-123791,EDGE-123792: Changed Order Type 'Change' to 'Change Commercial Configuration'.
        //EDGE-210438 Changed 'Change Commercial Configuration' to 'Change service Configuration'

        List<String> types=new List<String>{DataHandlerConstants.modifyChangeType,'Transition to Connected Workplace','Cancel','Transition to Corporate Mobile Plus','Transition to Adaptive Mobility','Transition to Adaptive Collaboration'};//EDGE-170932 Added Transition to Adaptive Mobility


            List<Map<String,Object>> totals = new List<Map<String,Object>>();    
        Boolean isTransition = false;//EDGE-166406
        for(String s:types){
            for(String offer : offerName){
                integer j=1;
                Map<String,Object> newrow = new Map<String,Object>();
                Decimal total_exGST = 0.00;
                Decimal total_incGST = 0.00;
                if(!summaryOrder.get(s).isEmpty()){
                    for(Map<String,Object> row:summaryOrder.get(s)){
                        // system.debug('row123:'+row + '@@123offer' + offer);
                        if(!row.isEmpty() && row.get('Existing_Service')!=null && row.get('GSTExcl_TotalETC')!=null && row.get('Existing_Service').equals(offer)){ //EDGE-164335 | Added Null check for GSTExcl_TotalETC
                         //   System.debug('row456:'+row + '@@456offer' + offer);
                            if(row.get('GSTExcl_TotalETC').equals('Waived') || row.get('GSTExcl_TotalETC').equals('NA- Not available') || row.get('GSTExcl_TotalETC').equals('N/A') || row.get('GSTExcl_TotalETC').equals('NA - Not Applicable')){//EDGE-210438 Added NA - Not Applicable
                         //       System.debug('Waived || NA- Not available');
                                //total_exGST = -9999.234;
                                //total_incGST = -9999.234;
                                isTransition = true;
                                // system.debug('isTransition::' + isTransition);//EDGE-166406
                            }
                            else{
                                // system.debug('Not Waived');
                                total_exGST +=Decimal.valueOf(String.valueOf(row.get('GSTExcl_TotalETC')).substringAfter('$'));
                                // system.debug('total_exGST-->'+total_exGST);
                                total_incGST += Decimal.valueOf(String.valueOf(row.get('GSTIncl_TotalETC')).substringAfter('$'));
                            }                        
                        }
                    }
                    newrow.put('ExternalId', String.valueOf(j));j++;
                    newrow.put('Existing_Service', offer);
                    newrow.put('Order_Type', s);
                    // system.debug('isTransitionFinal::' + isTransition);
                    if(isTransition == true){//EDGE-166406


                        if(s=='Transition to Adaptive Mobility'){//EDGE-170932


                            newrow.put('GSTExcl_TotalETC', 'Waived');
                            newrow.put('GSTIncl_TotalETC', 'Waived');                            
                        }
                        else{

                        // system.debug('total_exGST < 0 -->'+total_exGST);
                        //EDGE-150587 - ETC changed from Waived to NA- Not available
                        newrow.put('GSTExcl_TotalETC', 'NA- Not available');
                        newrow.put('GSTIncl_TotalETC', 'NA- Not available');
                        //newrow.put('GSTExcl_TotalETC', 'Waived');
                        //newrow.put('GSTIncl_TotalETC', 'Waived');
                    }
                    }
                    else{
                        // system.debug('total_exGST  > 0 -->'+total_exGST);
                        //EDGE-164623 | Removing hardcoaded $ and using Currency mergefield in Conga
                        newrow.put('GSTExcl_TotalETC', total_exGST);
                        newrow.put('GSTIncl_TotalETC', total_incGST);
                    }
                    totals.add(newrow);
                }
            }
        }
        System.debug('rows:'+totals);
        return totals;
    }
    
    //Method to populate New-Services table in summary section of quote/orderform
    public List<Map<String,Object>> getSummaryForNewServices(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Double sumOfBasketRedemption=0;
        Integer extId=0;
        String paymentTypeStringAttr = 'PaymentTypeString';     //EDGE-176688
        String oneOffPaymentTypeValue = 'Purchase';     //EDGE-176688
        String paymentTypeShadowAttr = 'PaymentTypeShadow';   // DPG-4690-Mahima
        try{
            Integer externalID=1;
            //EDGE-117967 : Capture POS redemption information in Quotes
            String basketName = '';
            if(basketId.length()>0){
            List<cscfga__Product_Basket__c > basketNameList = [select name from cscfga__Product_Basket__c where id=:basketId];
                for(Integer i=0;i<basketNameList.size();i++){
                    basketName = basketNameList[i].name;
                }                                       
            } 
            sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);
            sumOfBasketRedemption = 0 - sumOfBasketRedemption;
          //   system.debug('sumOfBasketRedemption@@::' + sumOfBasketRedemption);
            Set<String> offers = getOffersInBasket(basketId);
           //  system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewServices:Offers:'+offers);
            //List<Map<String,Object>> rows = new List<Map<String,Object>>();
            Map<String,Object> row = new Map<String,Object>();
            //EDGE-117738 Start
            //EDGE-141462 : EDGE-123791_New services is not coming in Order Summary section for Mac Order of CMP and NGUC, 
            // so the filter added Type__c='New'
            //parentProdcList = [SELECT id,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId and (name IN :parentPCs or cscfga__Product_Family__c IN :productFamilies ) and Type__c='New'];
        // Query filter change

     /*   parentProdcList = [SELECT id,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,Marketable_Offer__r.Offer_ID__c,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c,(SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Value__c FROM cscfga__Attributes__r) 
                           from cscfga__Product_Configuration__c 
                           where cscfga__Product_Basket__c= :basketId 
                           and cscfga__Product_Definition__r.product_Specification__c IN :productSpecCodes 
                           and (Type__c='New' OR Type__c='CHOWN')]; *///cscfga__Parent_Configuration__c==null added by sunil for Prod Incident INC000094305738 //EDGE-176688 - Removing Parent Config nullcheck to enable AMDeviceCare// EDGE-209790 added chown check
                            //EDGE-210438(ngUC qty fix) - Added Quantity_Product_Configuration__c
                            parentProdcList = [SELECT id,Quantity_Product_Configuration__c,subtype__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,Marketable_Offer__r.Offer_ID__c,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c,cscfga__Product_Configuration__c.Name, cscfga__Quantity__c, cssdm__solution_association__c,
                            (SELECT Id, Name, cscfga__Product_Configuration__c,cscfga__Value__c FROM cscfga__Attributes__r)
                           from cscfga__Product_Configuration__c 
                           where cscfga__Product_Basket__c= :basketId 
                           and cscfga__Product_Definition__r.product_Specification__c IN :productSpecCodes 
                           and (Type__c='New' OR Type__c='CHOWN') 
                            AND (cscfga__Parent_Configuration__c= null OR cscfga__Product_Definition__r.product_Specification__c =: ngemDeviceCare)];                 

        // Query filter change end
            // system.debug('parentProdcList@@::' + parentProdcList);
            //EDGE-117738
            Decimal total_one_off_charge_exGST=0.00;
      Decimal total_one_off_charge_incGST = 0.00;// Moved as per OneDeclarationPerLine SCA Rule
      Decimal total_recurring_charge_exGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
      Decimal total_recurring_charge_incGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
            for(String offer:offers){ 
                // system.debug('offer@@::' + offer);
                total_one_off_charge_exGST = 0.00;
                total_one_off_charge_incGST = 0.00;
                total_recurring_charge_exGST = 0.00;
                total_recurring_charge_incGST = 0.00;
                Integer cnt=0; //Added as part of DPG-1311
                for(cscfga__Product_Configuration__c pc2:parentProdcList){//EDGE-117738 Added parentProdcList
                    Map<Id,Decimal> mapCommittedDataCount = new Map<Id,Decimal>();
                    Map<Id,Id> mapCommittedDataSolnToPCMap = new Map<Id,Id>();
                    //EDGE-140420 END
                    // system.debug('pc2@@::' + pc2);
                   //  system.debug('pc2.Offername__c@@::' + pc2.Offername__c);
                    // Method parameter change
                    //// system.debug('getOfferFamily(pc2.Offername__c)@@::' + getOfferFamily(pc2.Offername__c));
                     system.debug('offerinside@@::' + offer +'pc2.Marketable_Offer__r.Offer_ID__c'+pc2.Marketable_Offer__r.Offer_ID__c+'pc2.Offername__c'+pc2.Offername__c);
                    //if(pc2.Offername__c!=null && (getOfferFamily(pc2.Offername__c)).equalsIgnoreCase(offer)){
                    //EDGE-176688 - Start ,Added for EDGE-191284
                    //Updated By Mahima for DPG-4690 pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId)- INC000095245663
                     if(pc2.Offername__c!=null && (pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId)||pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemAccProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare))){
                        if(pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId) ||pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemAccProdSpecId)){
                             //          system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewServices1 :Inside AM Device:'+pc2.cscfga__Product_Definition__r.product_Specification__c);
                       
                            for(cscfga__Attribute__c attribute:pc2.cscfga__Attributes__r) {
                                //Updated By Mahima for DPG-4690 added paymentTypeShadowAttr
                                if((attribute.Name.equals(paymentTypeStringAttr)|| attribute.Name.equals(paymentTypeShadowAttr)) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue)){
                                    // system.debug('attribute.Name'+attribute.Name);
                                    total_one_off_charge_exGST += pc2.cscfga__One_Off_Charge__c;  total_one_off_charge_incGST += calculateGSTIncludedPrice(pc2.cscfga__One_Off_Charge__c);
                                    // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewServices:Inside AM Device: Upfront charges: '+pc2.cscfga__One_Off_Charge__c);
                                }
                            }
                        }
                        else if(pc2.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare)){
                            total_one_off_charge_exGST += pc2.cscfga__One_Off_Charge__c;
                            total_one_off_charge_incGST += calculateGSTIncludedPrice(pc2.cscfga__One_Off_Charge__c);
                       //      system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewServices:Inside AM Device Care: Upfront charges '+pc2.cscfga__One_Off_Charge__c);
                        }
                    }
                    //EDGE-176688 - End
                    else if(pc2.Offername__c!=null && (getOfferFamily(pc2.Marketable_Offer__r.Offer_ID__c)).equalsIgnoreCase(offer) && pc2.cscfga__Parent_Configuration__c==null){
                      //  system.debug('pc2@@::inside' + pc2);
                        // EDGE-210438(ngUC qty fix) Start
                        if(pc2.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || pc2.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID){
                            total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c*pc2.Quantity_Product_Configuration__c; total_one_off_charge_incGST += calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c*pc2.Quantity_Product_Configuration__c);
                        }// EDGE-210438(ngUC qty fix) End
                        else if(offer != null && offer == IoTConnectivity){
                            total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c*pc2.Quantity_Product_Configuration__c;
                            total_one_off_charge_incGST += calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c*pc2.Quantity_Product_Configuration__c);
                        }  
                        else{
                         system.debug('pc2@@::inside else part ' + pc2);
                        total_one_off_charge_exGST += pc2.cscfga__total_one_off_charge__c; //total_one_off_charge_incGST += pc2.TotalGSTInclusiveTOC__c;
                        total_one_off_charge_incGST += calculateGSTIncludedPrice(pc2.cscfga__total_one_off_charge__c);//EDGE-162365 Defect Fix
                        total_recurring_charge_exGST += pc2.cscfga__total_recurring_charge__c;
                        }
                        //total_recurring_charge_incGST += pc2.TotalGSTInclusiveTRC__c;
                        cnt++; //Added as part of DPG-1311
                    }
                }
                /*while(mapCommittedDataSolnToPCMap.size()){
                    mapCommittedDataCount
                }*/
                row.put('Offer_Name',offer);
                row.put('ExternalId', String.valueOf(externalID));externalID++;
                row.put('Total_Once_Off',total_one_off_charge_exGST);
                //row.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);
                //row.put('GSTIncl_Total_Onceoff_Charges',calculateGSTIncludedPrice(total_one_off_charge_exGST));
                row.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);//EDGE-162365
                // system.debug('row@@::inside' + row);
                //DPG - 597
                if(offer != null && ( !(offer == Label.IoTOfferName) || !(offer == IoTConnectivity) ))//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
               {
                    // system.debug('Count --> '+cnt);
                    row.put('Total_Recurring_Charges',total_recurring_charge_exGST);
                    row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(total_recurring_charge_exGST));
               }
               //Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan - no need to show RC in order form
              /* else
               {
                   row.put('Total_Recurring_Charges',cnt*Decimal.ValueOf(Label.IoTRecurCharge)); //Added as part of DPG-1311
                   row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(cnt*Decimal.ValueOf(Label.IoTRecurCharge))); //Added as part of DPG-1311
               } */
                row.put('Term','36 Months');
                //EDGE-117967 : Capture POS redemption information in Quotes                
                row.put('BasketRedeemAmtQuote',(sumOfBasketRedemption)); //EDGE-197766: Modified
                row.put('GSTInclBasketRedeemAmtQuote',sumOfBasketRedemption*1.1); //EDGE-197766: Modified
                rows.add(row); 
                //EDGE-117967 : Capture POS redemption information in Quotes
                extId = externalID; 
                row = new Map<String,Object>();
            }
            //EDGE-117967 : Fetch Redemption amount in Quotes for summarised view  
            if(sumOfBasketRedemption != 0){
                extId++;
                row.put('Offer_Name',System.Label.Telstra_Enterprise_Plus_Fund);
                row.put('ExternalId', String.valueOf(extId));             
                row.put('Total_Once_Off',(sumOfBasketRedemption)); //EDGE-197766: Modified
                row.put('GSTIncl_Total_Onceoff_Charges',sumOfBasketRedemption*1.1); //EDGE-197766: Modified
                row.put('Total_Recurring_Charges',0.00);
                row.put('GSTIncl_Total_Recurring_Charges',0.00);
                rows.add(row);
            }
        }
        catch(Exception e){
            System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());}
        system.debug('rows@@::last' + rows);
        return rows;
    }
    //EDGE-123788 & EDGE-123789 start
// EDGE-169456 Start
  public List<Map<String,Object>> getSummaryForNewServicesRC(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer extId=0;
        try{
            Integer externalID=1;
            Set<String> offers = getOffersInBasket(basketId);
             // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewServices:Offers:'+offers);
            Map<String,Object> row = new Map<String,Object>();
            Map<String,Decimal> mapOfOffervsCLIDiscount=new Map<String,Decimal>();
            Map<String,Decimal> mapOfOffervsatrrPrice=new Map<String,Decimal>();
            //EDGE-121387, EDGE-133760
            Map<String,cscfga__Product_Configuration__c> mapOfpcIdvsPCs=new Map<String,cscfga__Product_Configuration__c>();
            Map<String,List<Charge_Line_Item__c>> mapOfOfferVsCLI = new Map<String,List<Charge_Line_Item__c>>(); 
            //EDGE-141462 : EDGE-123791_New services is not coming in Order Summary section for Mac Order of CMP and NGUC, 
            // So the filter added Type__c='New'
           /*List<cscfga__Product_Configuration__c> parentProdcList = [SELECT id,Name,cscfga__total_one_off_charge__c,cscfga__Parent_Configuration__c,cscfga__recurring_charge_line_discount_value__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,cscfga__Product_Family__c,Offername__c,Offer_Reference__r.Name,Offer_Reference__r.Offer_Spec_Id__c
                                                                    from cscfga__Product_Configuration__c 
                                                                     where cscfga__Product_Basket__c= :basketId 
                                                                     AND (name IN :parentPCs or cscfga__Product_Family__c IN :productFamilies )
                                                                      AND Type__c='New'];*/


       // EDGE-165831 - Filter change//EDGE-166406 added subquery for attribs
       // * EDGE-169456-Added cscfga__discounts__c field in the query to retrieveparent parentProdcList.




       //EDGE-187507 added cscfga__recurring_charge_product_discount_value__c to query
    List<cscfga__Product_Configuration__c> parentProdcList = [SELECT id,Quantity_Product_Configuration__c,Marketable_Offer__r.Offer_ID__c,cscfga__Parent_Configuration__c,cscfga__recurring_charge_line_discount_value__c,cscfga__recurring_charge_product_discount_value__c,type__c,cscfga__total_recurring_charge__c,cscfga__total_contract_value__c,Offername__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Recurring_Charge__c,subType__c ,(SELECT Id, Name, cscfga__Value__c FROM cscfga__Attributes__r WHERE Name = 'RC') from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId AND cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND (Type__c='New' OR Type__c = 'CHOWN') AND subType__c !='Inflight Amend'];         //Filter change end
            //Filter change end
            //EDGE-166406 Start
            Map<Id,Decimal> map_PCVSGSTIncprice;
            map_PCVSGSTIncprice = getGSTIncPriceforPC(basketId,false);
            Map<Id,Decimal> map_PCVSGSTIncpriceIncDisc;
            map_PCVSGSTIncpriceIncDisc = getGSTIncPriceforPC(basketId,true);
            //EDGE-166406 End


            Boolean isDiscountUpdatedOnPC=False;
        //    system.debug('parentProdcList-->'+parentProdcList);
            if(parentProdcList!=null && !parentProdcList.isEmpty()){
                for(cscfga__Product_Configuration__c pc:parentProdcList){
          //          system.debug('pc.Offername__c--->'+pc.Offername__c);
                    if(pc.Offername__c!=null){
                        //EDGE-121387, EDGE-133760
                        mapOfpcIdvsPCs.put(pc.Id,pc);
                    }
                    //EDGE-140501,EDGE-142033 Checking if Strategic solution is implemented
                    if(pc.cscfga__Parent_Configuration__c == null && pc.cscfga__recurring_charge_line_discount_value__c !=null && pc.cscfga__recurring_charge_line_discount_value__c > 0){
                        isDiscountUpdatedOnPC=True;
                }
            }
            }
            Map<String,Double> mapOfListPrice;
            //if(isDiscountUpdatedOnPC){
                //EDGE-140501,EDGE-142033 Getting list price from Product Configuration using discount value (Strategic solution)
                mapOfListPrice=getListPriceUsingDiscount(basketId,parentProdcList);
        //        System.debug('mapOfListPriceDiscount-----@@@@:'+mapOfListPrice);
            //}
            //EDGE-147408 - Attribute discounts functionality discarded, so commented function call.
            /*else{
                //EDGE-121387, EDGE-133760 Getting list price from PC Attributes(Tactical solution)
                mapOfListPrice=getListPrice(basketId,mapOfpcIdvsPCs);
       //     System.debug('mapOfListPrice----->>>>>:'+mapOfListPrice);
            }*/  // EDGE-147408 end.          
            //EDGE-117738
            Decimal monthly_RC_Promotions_incGST=0.00;
      Decimal monthly_RC_Promotions_exGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
      Decimal total_recurring_charge_exGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
      Decimal total_recurring_charge_incGST = 0.00;//Moved as per OneDeclarationPerLine SCA Rule
       //     System.debug('offers check ----->>>>>:'+offers);
            for(String offer:offers){  
       //         System.debug('offer here ----->>>>>:'+offer);
                total_recurring_charge_exGST = 0.00;
                total_recurring_charge_incGST = 0.00;
                monthly_RC_Promotions_incGST = 0.00;
                monthly_RC_Promotions_exGST = 0.00;   
                Integer cnt=0;
                for(cscfga__Product_Configuration__c pc2:parentProdcList){
               //     System.debug('parentProdcList--+11'+pc2);
               //     System.debug('pc2.Offername__c--->21'+pc2.Offername__c); 
                //    system.debug('offer-->12'+offer);
                    Decimal rcCharge = 0.00; //EDGE-176688
                    // Method Parameter change
                    //if(pc2.Offername__c!=null && (getOfferFamily(pc2.Offername__c)).equalsIgnoreCase(offer)){
                    if(pc2.Offername__c!=null && (getOfferFamily(pc2.Marketable_Offer__r.Offer_ID__c)).equalsIgnoreCase(offer)){

                  //      System.debug('Here ----->>>>>:1' + pc2.name + '::' + pc2.id);
                       //EDGE-185178 - Commented CMP Offer check
                       //if(pc2.cscfga__Parent_Configuration__c == null && offer != 'Corporate Mobile Plus'){// EDGE-158690 - Added if to skip child products &EDGE-169456-Added for checking CMP offer
                       if(pc2.cscfga__Parent_Configuration__c == null){

                            //EDGE-176688 - Start
                            rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                            total_recurring_charge_exGST += rcCharge;
                            //EDGE-176688 - End








                       //EDGE-187507 start commented out EDGE-169456
                       /*


                                 //* EDGE-169456 start

                    Decimal baseprice = 0;  
                        if(pc2.cscfga__discounts__c != null){   
                            DiscountsJson dj = DiscountsJson.parse(pc2.cscfga__discounts__c);   
                            for(DiscountsJson.Discounts dis : dj.discounts ){   
                                if(dis.source == 'BasePrices' && dis.chargeType == 'recurring' && dis.discountPrice == 'sales'){    

                                    baseprice = dis.amount; 
                                }   
                            } 


                            //find negotiated discount as we need to add ONLY that part because we would like to show base prices, not FA negotiated ones
                            Decimal negotiatedDiscountAmount =  baseprice - pc2.cscfga__Recurring_Charge__c - pc2.cscfga__recurring_charge_product_discount_value__c;
                            monthly_RC_Promotions_incGST += negotiatedDiscountAmount;
                        } 
                       // * EDGE-169456 End

                       */  //EDGE-187507 End commented out EDGE-169456





                           //EDGE-166406 Start
                            if(map_PCVSGSTIncprice.containsKey(pc2.id)){
                             total_recurring_charge_incGST+=map_PCVSGSTIncprice.get(pc2.id);
                         //     system.debug('incGST::getSummaryForNewServicesRC::func' +map_PCVSGSTIncprice.get(pc2.id)+ '::' + pc2.name);
                            }
                            else{
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                total_recurring_charge_incGST+=calculateGSTIncludedPrice(rcCharge);
                             //   system.debug('incGST::getSummaryForNewServicesRC::pc' +calculateGSTIncludedPrice(rcCharge)+ '::' + pc2.name);
                                //EDGE-176688 - End
                            }
                        }
                        //EDGE-166406 End
                        /* EDGE-181157 - Commented code block
                         // EDGE-169456 start
                     if(pc2.cscfga__Parent_Configuration__c == null && offer == 'Corporate Mobile Plus'){// EDGE-158690 - Added if to skip child products    
                        total_recurring_charge_exGST += pc2.cscfga__total_recurring_charge__c;  
                  //      system.debug('mapOfListPrice'+mapOfListPrice);  
                  //      system.debug('mapOfListPrice.get(pc2.Id)-->'+mapOfListPrice.get(pc2.Id));   
                        if(mapOfListPrice!=null && !mapOfListPrice.isEmpty() && mapOfListPrice.get(pc2.Id)!=null){  
                            Double monthlyRCPromotions=mapOfListPrice.get(pc2.Id);  
                 //           system.debug('monthlyRCPromotions'+monthlyRCPromotions);    
                            if(monthlyRCPromotions>0){  
                                monthly_RC_Promotions_incGST+=monthlyRCPromotions;  
                            }else{  
                                monthly_RC_Promotions_incGST+=pc2.cscfga__total_recurring_charge__c;    
                            }   
                        }   
                        else{   
                            if(pc2.cscfga__Parent_Configuration__c == null)// EDGE-158690 - Added if to skip child products 
                            monthly_RC_Promotions_incGST+=pc2.cscfga__total_recurring_charge__c;    
                        }   
                    } 
                  // EDGE-169456 End
                  EDGE-181157 - End*/
              //            system.debug('mapOfListPrice'+mapOfListPrice);
               //         system.debug('mapOfListPrice.get(pc2.Id)-->'+mapOfListPrice.get(pc2.Id));
                        if(mapOfListPrice!=null && !mapOfListPrice.isEmpty() && mapOfListPrice.get(pc2.Id)!=null){
                            Double monthlyRCPromotions=mapOfListPrice.get(pc2.Id);
                  //          system.debug('monthlyRCPromotions'+monthlyRCPromotions);
                            if(monthlyRCPromotions>0){
                                monthly_RC_Promotions_exGST+=monthlyRCPromotions;
                  //              system.debug('inside 0::' + monthlyRCPromotions + '::' + pc2.name);
                            }else{
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                monthly_RC_Promotions_exGST+=rcCharge;
                    //            system.debug('inside 1::' + rcCharge + '::' + pc2.name);
                                //EDGE-176688 - End
                            }
                            //EDGE-166406 Start
                            if(map_PCVSGSTIncpriceIncDisc.containsKey(pc2.id)){
                                monthly_RC_Promotions_incGST+=map_PCVSGSTIncpriceIncDisc.get(pc2.id);
                   //             system.debug('inside 2::'+map_PCVSGSTIncpriceIncDisc.get(pc2.id) + '::' + pc2.name);
                            }   

                            else{

                            //EDGE-181157 Defect Fix Start 
                                if(monthlyRCPromotions>0){
                                monthly_RC_Promotions_incGST+=calculateGSTIncludedPrice(monthlyRCPromotions);
                      //          system.debug('inside 3::' + calculateGSTIncludedPrice(monthlyRCPromotions) + '::' + pc2.name);
                            }//EDGE-181157 Defect Fix End
                    else{

                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                monthly_RC_Promotions_incGST+=calculateGSTIncludedPrice(rcCharge);
                        //        system.debug('inside 3.5::' + calculateGSTIncludedPrice(rcCharge) + '::' + pc2.name);
                                //EDGE-176688 - End


                            }


                            }


                        }else{
                            if(pc2.cscfga__Parent_Configuration__c == null){// EDGE-158690 - Added if to skip child products
                                //EDGE-176688 - Start
                                rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                monthly_RC_Promotions_exGST+=rcCharge;
                        //        system.debug('inside 4::' + rcCharge + '::' + pc2.name);
                                //EDGE-176688 - End
                            //EDGE-166406 Start
                                if(map_PCVSGSTIncpriceIncDisc.containsKey(pc2.id)){
                                monthly_RC_Promotions_incGST+=map_PCVSGSTIncpriceIncDisc.get(pc2.id);
                        //        system.debug('inside 5::' + map_PCVSGSTIncpriceIncDisc.get(pc2.id) + '::' + pc2.name);
                                }
                                else{
                                    //EDGE-176688 - Start
                                    rcCharge = ProductPricingHandler.amDeviceHROCheck(pc2);
                                    monthly_RC_Promotions_incGST+=calculateGSTIncludedPrice(rcCharge);
                          //          system.debug('inside 6::' + calculateGSTIncludedPrice(rcCharge) + '::' + pc2.name);
                                    //EDGE-176688 - End
                                }
                                //EDGE-166406 End
                            }
                        }
                        cnt++;
                    }
                }
                row.put('Offer_Name',offer);
                row.put('ExternalId', String.valueOf(externalID));
                externalID++;
                row.put('MonthlyRCPromotionsExclGST',total_recurring_charge_exGST);
                //row.put('MonthlyRCPromotionsInclGST',calculateGSTIncludedPrice(total_recurring_charge_exGST));
                row.put('MonthlyRCPromotionsInclGST',total_recurring_charge_incGST.setScale(2));//EDGE-166406
                if(offer != null && ( !(offer == Label.IoTOfferName) || !(offer == IoTConnectivity)) ){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
           //     system.debug('Count --> '+cnt);
                row.put('Total_Recurring_Charges',monthly_RC_Promotions_exGST);
                //row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(monthly_RC_Promotions_exGST));
                row.put('GSTIncl_Total_Recurring_Charges',monthly_RC_Promotions_incGST.setScale(2));//EDGE-166406
               }
               // Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan - no need to show RC values in order form
              /* else{
                   row.put('Total_Recurring_Charges',cnt*Decimal.ValueOf(Label.IoTRecurCharge));
                   row.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(cnt*Decimal.ValueOf(Label.IoTRecurCharge)));
                } */
                row.put('Term','36 Months');
                //EDGE-171311 - Start
                if((decimal)(row.get('MonthlyRCPromotionsExclGST')) < 0)
                    row.put('MonthlyRCPromotionsExclGST','('+(decimal)(row.get('MonthlyRCPromotionsExclGST'))*-1+')');
                if((decimal)(row.get('MonthlyRCPromotionsInclGST')) < 0)
                    row.put('MonthlyRCPromotionsInclGST','('+(decimal)(row.get('MonthlyRCPromotionsInclGST'))*-1+')');
                if((decimal)(row.get('Total_Recurring_Charges')) < 0)
                    row.put('Total_Recurring_Charges','('+(decimal)(row.get('Total_Recurring_Charges'))*-1+')');
                if((decimal)(row.get('GSTIncl_Total_Recurring_Charges')) < 0)
                    row.put('GSTIncl_Total_Recurring_Charges','('+(decimal)(row.get('GSTIncl_Total_Recurring_Charges'))*-1+')');
                //EDGE-171311 - End                 
               // Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan  
               if(offer != null && (offer == Label.IoTOfferName || offer == IoTConnectivity)){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
                    row.put('MonthlyRCPromotionsExclGST','Not Applicable');
                    row.put('MonthlyRCPromotionsInclGST','Not Applicable');
                    row.put('Total_Recurring_Charges','Not Applicable');
                    row.put('GSTIncl_Total_Recurring_Charges','Not Applicable');
                }             
                rows.add(row); 
                extId = externalID; 
                row = new Map<String,Object>();
            }
        }
        catch(Exception e){
            System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());
        }
        system.debug('rows ----->>>>>:'+rows);
        system.debug('========== Heap Size ::getSummaryfornewservicesRC:: ' + Limits.getHeapSize());
        return rows;
    }

//EDGE-123788 & EDGE-123789 end
//EDGE-166406 Start
public static Map<Id,Decimal> getGSTIncPriceforPC(String basketId, Boolean incDisc){
        List<cscfga__Attribute__c> boltOnAttrList = new List<cscfga__Attribute__c>();//EDGE-166406
        Map<Id, String> map_AttrVsAddOn = new Map<Id, String>();
        Map<Id,Decimal> map_PCVSGSTIncPrice=new Map<Id,Decimal>();
        Decimal rateOfGST = Decimal.valueOf(Label.GSTChargeRate);
        String addonPriceitem = 'cspmb__Add_On_Price_Item__c';//EDGE-166406
        Id temp;
        String objectAPIName='';
        Integer i=0;
        Integer j=0;
        //*******************************************************************************************************
        String ngemPlan = 'NGEMPlan';
        Set<String> ngemPlanPDId = new Set<String>();//EDGE-155059 Changed to list
        Map<string, string> labelMap = new Map<string, string>();
        List<String> specIdList = new List<String>(); //EDGE-148776
        Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        List<String> attrNameLst = new List<String>(); 
        try{
            List<NGEM_GSTFreeAttr__mdt> labelsNGEM = [Select id,Label from NGEM_GSTFreeAttr__mdt where isActive__c = true];
            //  system.debug('***Telstra:NGEMDataHandler:getNGEMPlans:CheckLabelNGEM:'+labelsNGEM);
            for(NGEM_GSTFreeAttr__mdt addOnRec:labelsNGEM){
                attrNameLst.add(addOnRec.label);
                
            }
            
            system.debug('attrNameLst::'+ attrNameLst);
            
            
            List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
            for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
                if(ngemSpec.ProductCategory__c==ngemPlan){
                    map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
                    specIdList.add(ngemSpec.ProdSpecId__c);
                }
            }
            List<Apex_Label__mdt> labels = [Select id,Label, Value__c from Apex_Label__mdt where isActive__c = true];
            for(Apex_Label__mdt l:labels){
                labelMap.put(l.label,l.value__c); 
            }
            if(map_PDvsSecId != null && !map_PDvsSecId.isEmpty()){
                //EDGE-155059 Adding rows in list
                if(labelMap.get('ngemPlanPDName')!=null)
                    ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemPlanPDName')).ProdSpecId__c);
                if(labelMap.get('ngemDataPDname')!=null)
                    ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemDataPDname')).ProdSpecId__c);
                if(labelMap.get('ngemVoicePDName')!=null)
                    ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemVoicePDName')).ProdSpecId__c);
                if(labelMap.get('ngemCallMsgPDName')!=null)
                    ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemCallMsgPDName')).ProdSpecId__c);
                //EDGE-176737 Start
                if(labelMap.get('ngemIRPDName')!=null)
                    ngemPlanPDId.add(map_PDvsSecId.get(labelMap.get('ngemIRPDName')).ProdSpecId__c);
                //EDGE-176737 End
            }
             
                    for(cscfga__Attribute__c attribute:[SELECT Id,cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.id, cscfga__Value__c FROM cscfga__Attribute__c where name in :attrNameLst AND cscfga__Product_Configuration__r.cscfga__Product_Basket__r.id =:basketId and cscfga__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId and cscfga__Product_Configuration__r.cscfga__Parent_Configuration__c!=null and cscfga__Display_Value__c!=null]) {
                        
                                    boltOnAttrList.add(attribute);
                                    map_AttrVsAddOn.put(attribute.Id,attribute.cscfga__Value__c);
                    }
          
            
            //system.debug('ngemPlanPDId::' + ngemPlanPDId); 
            
            //System.debug(Logginglevel.ERROR,'MsgTxt' + ngemPlanPDId);
            List<String> attrIdList = map_AttrVsAddOn.values();
             // system.debug('attrIdList:getAggregatedRows '+attrIdList);
            List<cspmb__Add_On_Price_Item__c> addOnpriceItemList = [SELECT id,taxTreatment__c,cspmb__Recurring_Charge__c FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrIdList];
             // system.debug('addOnpriceItemList: '+addOnpriceItemList);
            Map<id,cspmb__Add_On_Price_Item__c> addOnPriceItemsRecords = new Map<id,cspmb__Add_On_Price_Item__c>(addOnpriceItemList);
           //  system.debug('***Telstra:NGEMDataHandler:getAggregatedRows:addOnPriceItemsRecords:'+addOnPriceItemsRecords);
            for(cscfga__Product_Configuration__c pc:[SELECT id,cscfga__recurring_charge_line_discount_value__c, cscfga__recurring_charge_product_discount_value__c,cscfga__total_recurring_charge__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c= :ngemPlanPDId AND cscfga__Product_Basket__c=:basketId AND cscfga__Parent_Configuration__c=null]) {
                    j=j+1;
                    Decimal totalRecChargeAddOn = 0.00;
                    Decimal recurringChargePC =0.00;
                    if(incDisc)
                        
                        recurringChargePC = pc.cscfga__total_recurring_charge__c + pc.cscfga__recurring_charge_line_discount_value__c + pc.cscfga__recurring_charge_product_discount_value__c; //EDGE-187507 added cscfga__recurring_charge_product_discount_value__c
                    
                    else
                        recurringChargePC = pc.cscfga__total_recurring_charge__c;
                  
                    Decimal recurringChargePCGSTInc = 0.00;
                    for(cscfga__Attribute__c boltOnAttr:boltOnAttrList) {
                        i=i+1;
                        if(boltOnAttr.cscfga__Product_Configuration__r.cscfga__Parent_Configuration__r.id == pc.id)
                        {
                             
                            cspmb__Add_On_Price_Item__c addOnpriceItemRecord = addOnPriceItemsRecords.get(map_AttrVsAddOn.get(boltOnAttr.Id));
                         
                            if(addOnpriceItemRecord.taxTreatment__c == 'TAX Exempt'){
                                totalRecChargeAddOn = totalRecChargeAddOn + addOnpriceItemRecord.cspmb__Recurring_Charge__c;
                              
                            }
                        }
                        system.debug(Logginglevel.INFO,'i::'+i+'   ::j::' + j);
                        
                    }
                     
                    recurringChargePC = recurringChargePC - totalRecChargeAddOn;
             
                    recurringChargePC = recurringChargePC + (recurringChargePC*rateOfGST);
                    
                    recurringChargePCGSTInc = recurringChargePC +  totalRecChargeAddOn;
                    
                    map_PCVSGSTIncPrice.put(pc.id,recurringChargePCGSTInc);
                
            }
             
            
        
        }
        catch(Exception e)
        {
              system.debug('***Telstra:Productbasketdatahandler:getGSTIncPriceforPC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        // system.debug('map_PCVSGSTIncPrice::After@@' + map_PCVSGSTIncPrice);
         system.debug('========== Heap Size ::getGSTIncPriceForPC:: ' + Limits.getHeapSize());
        return map_PCVSGSTIncPrice;
    }
//EDGE-166406 End
//changes start for EDGE-99894
//Method to populate New-Services table in summary section of DOP quote/orderform
public List<Map<String,Object>> getDOPServices(String basketId, Map<String,String> subfilters)
{
    List<Map<String,Object> > rows = new List<Map<String,Object> >();
    Map<String,List<cscfga__Product_Configuration__c> > map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c> >();
    Map<String, String> map_DeviceModelVsPriceItem = new Map<String, String>();
    Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
    //EDGE-117967 : Capture POS redemption information in Quotes
    Map<String, String> map_DeviceWithRedeemAmount = new Map<String, String>();
    Integer externalId=1;
    List<cscfga__Product_Configuration__c> devicePCList = new List<cscfga__Product_Configuration__c>();
    try{
        //EDGE-117967 : Capture POS redemption information in Quotes
        if(basketId.length()>0){
            //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
            for(cscfga__Attribute__c attr : [Select cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.name,cscfga__Value__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__r.Id=:basketId and (name ='RedeemFund')]){
                // system.debug('cscfga__Product_Configuration__c.ID ----->>>>>:'+attr.cscfga__Product_Configuration__c);
                if(attr.cscfga__Product_Configuration__c != null && attr.cscfga__Value__c !=null){
                     map_DeviceWithRedeemAmount.put(attr.cscfga__Product_Configuration__c,attr.cscfga__Value__c); 
                }                                    
            }                                     
        }   
    // EDGE-165831 - Filter Change
    // EDGE-* EDGE-169456-Add cscfga__One_Off_Charge__c field in SOQL query
        devicePCList =[SELECT id,name,cscfga__Contract_Term__c,Quantity_Product_Configuration__c, cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__One_Off_Charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.product_Specification__c IN:lstDeviceSpecCode AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null AND Marketable_Offer__r.Offer_ID__c=:dopId];//EDGE-154662 Added Markatable offer's offer id check
        //    System.debug('***devicePCList***'+devicePCList);
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:devicePCList) {
                if(map_DeviceModelvsPC.get(pc.Name) == null) {
                    map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
                }
                map_DeviceModelvsPC.get(pc.Name).add(pc);
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                    if(isValidId(attribute.cscfga__Value__c)==True) {
                        map_DeviceModelVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
                        map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);
                    }
                }
            }
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:'+map_DeviceModelvsPC);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:map_DeviceModelVsPriceItem:'+map_DeviceModelVsPriceItem);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:map_PriceItemvsBasketsnaphotFields:'+map_PriceItemvsBasketsnaphotFields);
            List<String> attrIdList = map_DeviceModelVsPriceItem.values();
            String priceItemQuery = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(priceItemQuery));
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:priceItemsRecords:'+priceItemsRecords);
            //Changes start for EDGE-132158
            for(cscfga__Product_Configuration__c pc:devicePCList) {
                Map<STRing,Object> newRow = new Map<String,Object>(); 
                //EDGE-117967 : Capture POS redemption information in Quotes
                String productModuleName = '';               
                if(map_DeviceWithRedeemAmount != null){
                    String redeemAmt =map_DeviceWithRedeemAmount.get(pc.Id);
                    //EDGE-133499 : <Technical Story> - Verify Quote for POS redemption information
                    if(redeemAmt != '0.00'){
                     productModuleName = pc.Name+'#';
                    }else{
                        productModuleName = pc.Name;
                    }
                }     
                newRow.put('Product_Module_Name',productModuleName);
                newRow.put('ExternalId', externalID++);
                Decimal qty = 1;
                qty = pc.Quantity_Product_Configuration__c;
                newRow.put('Quantity',qty);
                cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_DeviceModelVsPriceItem.get(pc.name));
                if(priceItemRecord!=null) {
                    newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                    newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                //EDGE-169456 start -changed the variable priceItemRecord to pc
                newRow.put('Rate',pc.cscfga__One_Off_Charge__c);
                newRow.put('Total_Once_Off',qty*pc.cscfga__One_Off_Charge__c);
                Decimal totalOnceOff = (qty*pc.cscfga__One_Off_Charge__c);
                //EDGE-169456 End
                Decimal totalOnceOffGSTIncl = calculateGSTIncludedPrice(totalOnceOff);
                newRow.put('GSTIncl_Total_Onceoff_Charges',totalOnceOffGSTIncl);
            }
            rows.add(newRow);
        }
        //Changes end for EDGE-132158
    }
    catch(Exception e)
    {
        System.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
    }
    return rows;
}
//Method to populate line-items in Services-To-cancel table of Quote/Orderform
public List<Map<String,Object>> getCancelTypeProducts(String basketId){
    List<Map<String,Object>> rows = new List<Map<String,Object>>();
    // Yash : EDGE-63430 : Query Modification
    STring soqlQuery='SELECT name,cscfga__unit_one_off_charge__c,OfferName__c,cscfga__Parent_Configuration__r.Offername__c,Site_Name__c,Site_Address__c, cscfga__Contract_Term__c,cscfga__total_one_off_charge__c,TotalGSTInclusiveTOC__c,type__c,cscfga__total_recurring_charge__c,TotalGSTInclusiveTRC__c,cscfga__total_contract_value__c,cscfga__One_Off_Charge__c,csordtelcoa__Replaced_Subscription__r.Contract_Start_Date__c,csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c,csordtelcoa__Replaced_Subscription__r.Name,Quantity_Product_Configuration__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\' and name=\'IP Site\' and csordtelcoa__Replaced_Subscription__c!=null and type__c=\'Cancel\' order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
    Integer j=1;      
    Decimal total_one_off_charge_exGST = 0.00;
    Decimal total_one_off_charge_incGST = 0.00;
    Decimal total_recurring_charge_exGST = 0.00;
    Decimal total_recurring_charge_incGST = 0.00;
    Set<String> offerName = new Set<String>();
    list<cscfga__Product_Configuration__c> pcList = Database.query(soqlQuery);
    // system.debug('valueofquery'+pcList);
    Map<String,Object> rowcancel =null;
    for(cscfga__Product_Configuration__c pc2:pcList){
        //if(pc2.cscfga__Parent_Configuration__r.Offername__c.contains(offer))
        //defect - 59875
        if(pc2.name=='IP Site') {
            rowcancel = new Map<String,Object>();
            // system.debug('valueofdate'+pc2.csordtelcoa__Replaced_Subscription__r.Contract_Start_Date__c);
            String tempOffername='';
            tempOffername = (String.valueOf(pc2.OfferName__c)==null?pc2.csordtelcoa__Replaced_Subscription__r.Name:String.valueOf(pc2.OfferName__c));                   
            // Start EDGE-67629
            if(tempOffername.contains('Connected Workplace'))
                rowcancel.put('Existing_Service','Connected Workplace');
            else
                rowcancel.put('Existing_Service',tempOffername);     
            // end EDGE-67629
            rowcancel.put('Site_Name',pc2.Site_Name__c);
            rowcancel.put('Site_Address',pc2.Site_Address__c);
            rowcancel.put('Total_Once_Off',pc2.cscfga__unit_one_off_charge__c);
            //Manoj : EDGE : 63432 : 05/Feb/2019 : Start
            rowcancel.put('GSTExcl_TotalETC',pc2.cscfga__unit_one_off_charge__c);
            rowcancel.put('GSTIncl_TotalETC',calculateGSTIncludedPrice(pc2.cscfga__unit_one_off_charge__c));
            //Manoj : EDGE : 63432 : 05/Feb/2019 : End
            rowcancel.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);
            rowcancel.put('Total_Recurring_Charges',total_recurring_charge_exGST);
            rowcancel.put('GSTIncl_Total_Recurring_Charges',total_recurring_charge_incGST);
            // Yash : EDGE-63430 : Start
            rowcancel.put('Quantity',pc2.Quantity_Product_Configuration__c);
            // Yash : EDGE-63430 : End
            String term=pc2.cscfga__Contract_Term__c+' Months';
            rowcancel.put('Term',term);
            if(pc2.csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c!=null) { 
                Date dt=pc2.csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c.date();
                rowcancel.put('Service_Start_Date', dt.format() );
            }
            rowcancel.put('ExternalId', String.valueOf(j));
            rows.add(rowcancel);
            j++;
        }
    }
    return rows;
}
/* *********************************************************************************
* Author : Ritika
* Description : Method to bring Mobility and Mobile-device details into BasketSnapshot, for displaying in Quote/Orderform
* Jira Cloud : EDGE-65364,66165,66484
********************************************************************************* */    
    public List<Map<String,Object>> getMobilityTypeProducts(String basketId,Map<String,String> subfilters) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer externalId=1;
        try{
            List<cscfga__Product_Configuration__c> pcList =[select id,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__unit_one_off_charge__c,cscfga__total_one_off_charge__c,cscfga__Recurring_Charge__c,cscfga__One_Off_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Price__c,cscfga__Recurring__c, cscfga__Line_Item_Description__c, cscfga__Value__c,cscfga__Is_Line_Item__c,
                                                                                                                                                                                                                                                                                               cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, 
                                                                                                                                                                                                                                                                                               cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                                                                                                                                                                                                                                                                                               FROM cscfga__Attributes__r 
                                                                                                                                                                                                                                                                                               WHERE cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) from cscfga__Product_Configuration__c where cscfga__Product_Family__c IN ('Mobility','Mobile Device') and cscfga__Product_Basket__c =:basketId order by cscfga__unit_recurring_charge__c desc];
            //map parent-pc with attributes of mobility-plan, message-bank and device
            Map<String,List<cscfga__Attribute__c>> allAttributes = new Map<String,List<cscfga__Attribute__c>>();
            for(cscfga__Product_Configuration__c pc:pcList){                    
                if(String.isBlank(pc.cscfga__Parent_Configuration__c)){
                    allAttributes.put(pc.id,new List<cscfga__Attribute__c>());
                    (allAttributes.get(pc.id)).addAll(pc.cscfga__Attributes__r); 
                }else if(!String.isBlank(pc.cscfga__Parent_Configuration__c) && allAttributes.containsKey(pc.cscfga__Parent_Configuration__c)){
                    allAttributes.get(pc.cscfga__Parent_Configuration__c).addAll(pc.cscfga__Attributes__r);
                }
            }
            // system.debug('***Telstra:ProductBasketDataHandler:getMobilityProducts:attributes'+allAttributes);                
            Map<String,Object> rowTemp = new Map<String,Object>(); 
            Map<String,Object> rowMobilityPlan = new Map<String,Object>(); 
            Map<String,Object> rowMessageBank = new Map<String,Object>();     
            List<Map<String,Object>> rowsOfDevices = new List<Map<String,Object>>();
            List<Map<String,Object>> rowsOfMessageBanks = new List<Map<String,Object>>();
            List<Map<String,Object>> rowsOfMobilityPlans = new List<Map<String,Object>>();            
            Set<String> messageBanksSet=new Set<String>();
            Set<String> mobilityPlansSet=new Set<String>();                    
            externalId=3;
            for(cscfga__Product_Configuration__c pc:pcList){
                if(String.isBlank(pc.cscfga__Parent_Configuration__c)){
                    rowMessageBank=new Map<String,Object>();
                    rowMobilityPlan=new Map<String,Object>();
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    rowMobilityPlan.put('ExternalId', String.valueOf(externalId));
                    rowMessageBank.put('ExternalId', String.valueOf(externalId));
                    if(pc.cscfga__unit_one_off_charge__c>0)
                        rowTemp.put('Type','Once-off Charges');
                    else if(pc.cscfga__unit_recurring_charge__c>0)
                        rowTemp.put('Type','Recurring Charges');
                    for(cscfga__Attribute__c att:allAttributes.get(pc.id)){
                        String mappingfield ='';                        
                        mappingfield = (att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
                        if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('Device')){
                            rowTemp.put(mappingfield, att.cscfga__Value__c);   
                            rowTemp.put('Order_Type','Devices');
                            if(mappingfield.equalsIgnoreCase('GSTExcl_Total_Recurring_Charges') && !String.isBlank(att.cscfga__Value__c) && pc.cscfga__unit_recurring_charge__c>0)                                
                                rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                            if(mappingfield.equalsIgnoreCase('GSTExcl_Total_Onceoff_Charges') && !String.isBlank(att.cscfga__Value__c) && pc.cscfga__unit_one_off_charge__c>0){                                
                                // rowTemp.put('GSTExcl_Total_Recurring_Charges',att.cscfga__Value__c);
                                rowTemp.put('GSTIncl_Total_Onceoff_Charges',calculateGSTIncludedPrice(Decimal.valueOf(att.cscfga__Value__c)));
                            }                                         
                        }
                        if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('Plan')){
                            rowMobilityPlan.put(mappingfield, att.cscfga__Value__c);
                            rowMobilityPlan.put('Type','Recurring Charges');
                            rowMobilityPlan.put('Order_Type','Mobile Services');
                            if(mappingfield.contains('Product_Module_Name'))
                                mobilityPlansSet.add(att.cscfga__Value__c);
                        }if(att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c.contains('MessageBank')){
                            rowMessageBank.put(mappingfield, att.cscfga__Value__c);
                            rowMessageBank.put('Type','Recurring Charges');
                            rowMessageBank.put('Order_Type','Mobile Services');
                            if(mappingfield.contains('Product_Module_Name'))
                                messageBanksSet.add(att.cscfga__Value__c);
                        }
                    }
                    rowsOfMessageBanks.add(rowMessageBank);
                    rowsOfMobilityPlans.add(rowMobilityPlan); 
                    if(subfilters.get('Order_Type') == rowTemp.get('Order_Type') && subfilters.get('Type') == rowTemp.get('Type') ){
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',( Decimal.valueOf(rowTemp.get('Rate').toString()) * Decimal.valueOf(rowTemp.get('Quantity').toString())));
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice( Decimal.valueOf(rowTemp.get('Rate').toString()) * Decimal.valueOf(rowTemp.get('Quantity').toString())));
                        rowsOfDevices.add(rowTemp);
                    }    
                    externalId++;
                    // system.debug('***externalId:--> ' + externalId);
                }
            }
            /* *********************************************************************************
* Author : Jayesh
* Date : 17 June 2019
* Description : Logic to show the Mobility Product Discount Amount/Percentage on Quote - Contract
* Jira Cloud : EDGE-85582
********************************************************************************* */
            List<Map<String,Object>> rowsTemp = rowsOfMobilityPlans;
            if(subfilters.get('Order_Type') == 'Mobile Services') 
            {
                integer sum_quantity = 0;
                Decimal sum_charges = 0.0;
                Decimal sum_GSTcharges = 0.0;
                for(Map<String,Object> mB:rowsTemp)
                {
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    rowTemp.put('Product_Module_Name',mB.get('Product_Module_Name'));    
                    rowTemp.put('Rate',mB.get('Rate'));
                    rowTemp.put('Unit_Of_Measure',mB.get('Unit_Of_Measure'));
                    rowTemp.put('Type',mB.get('Type'));
                    rowTemp.put('Offer_Name',mB.get('Offer_Name'));
                    rowTemp.put('Order_Type','Mobile Services');
                    if(mB.get('PlanDiscount')!=null || mB.get('PlanDiscount')!='')
                    {
                        rowTemp.put('PlanDiscount',mB.get('PlanDiscount'));
                        String str = 'Includes $' + mB.get('PlanDiscount') + ' discount while device repayment option applied';
                        rowTemp.put('Discount_Text',str);
                        rowTemp.put('Rate',Decimal.valueOf(String.valueOf(mB.get('Rate'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount'))));
                        // system.debug('Failing mB:'+mB);
                        rowTemp.put('Quantity',Integer.valueOf(String.valueOf(mB.get('Quantity'))));
                        //rowTemp.put('GSTExcl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))));
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount'))));
                        //rowTemp.put('GSTIncl_Total_Recurring_Charges',Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges'))));
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges'))) - Decimal.valueOf(String.valueOf(mB.get('PlanDiscount')))));
                        rows.add(rowTemp);
                    }else
                    {
                        if(mB.get('Quantity')!=null && mB.get('Quantity')!='')
                            sum_quantity += Integer.valueOf(String.valueOf(mB.get('Quantity')));
                        if(mB.get('GSTExcl_Total_Recurring_Charges')!=null && mB.get('GSTExcl_Total_Recurring_Charges')!='')
                            sum_charges +=Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges')));
                        if(mB.get('GSTIncl_Total_Recurring_Charges')!=null && mB.get('GSTIncl_Total_Recurring_Charges')!='')
                            sum_GSTcharges +=Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges')));
                        rowTemp.put('Quantity',sum_quantity);
                        rowTemp.put('GSTExcl_Total_Recurring_Charges',sum_charges);
                        rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(sum_charges));
                        rows.add(rowTemp);
                    }
                    ExternalId++;
                }
            }
            List<Map<String,Object>> rowsTemp1 = rowsOfMessageBanks;
            Set<String> setTemp1 = messageBanksSet;
            // system.debug('***setTemp1:--> ' + setTemp1);
            if(subfilters.get('Order_Type') == 'Mobile Services') 
            {
                for(String messageBank:setTemp1)
                {
                    // system.debug('***messageBank:--> ' + messageBank);
                    rowTemp= new Map<String,Object>();
                    rowTemp.put('ExternalId', String.valueOf(externalId));
                    integer sum_quantity = 0;
                    Decimal sum_charges = 0.0;
                    Decimal sum_GSTcharges = 0.0;
                    for(Map<String,Object> mB:rowsTemp1)
                    {
                        if(messageBank.equalsIgnoreCase(String.valueOf(mB.get('Product_Module_Name'))))
                        {
                            rowTemp.put('Product_Module_Name',mB.get('Product_Module_Name'));    
                            rowTemp.put('Rate',mB.get('Rate'));
                            rowTemp.put('Unit_Of_Measure',mB.get('Unit_Of_Measure'));
                            rowTemp.put('Type',mB.get('Type'));
                            rowTemp.put('Offer_Name',mB.get('Offer_Name'));
                            rowTemp.put('Order_Type','Mobile Services');
                            if(mB.get('Quantity')!=null && mB.get('Quantity')!='')
                                sum_quantity += Integer.valueOf(String.valueOf(mB.get('Quantity')));
                            if(mB.get('GSTExcl_Total_Recurring_Charges')!=null && mB.get('GSTExcl_Total_Recurring_Charges')!='')
                                sum_charges +=Decimal.valueOf(String.valueOf(mB.get('GSTExcl_Total_Recurring_Charges')));
                            if(mB.get('GSTIncl_Total_Recurring_Charges')!=null && mB.get('GSTIncl_Total_Recurring_Charges')!='')
                                sum_GSTcharges +=Decimal.valueOf(String.valueOf(mB.get('GSTIncl_Total_Recurring_Charges')));
                        }
                    }      
                    rowTemp.put('Quantity',sum_quantity);
                    if(sum_charges <= 0) 
                        continue;
                    rowTemp.put('GSTExcl_Total_Recurring_Charges',sum_charges);
                    rowTemp.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(sum_charges));
                    rows.add(rowTemp);
                }
            }
            // end EDGE-85582  
            System.debug('***Telstra:ProductBasketDataHandler:getMobilityProducts:MobilityRows:'+rows);
            if(subfilters.get('Order_Type') == 'Devices')
                rows.addAll(rowsOfDevices);
        }
        catch(Exception e)
        {
            System.debug('exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        return rows;
    }
    /* *********************************************************************************
* Author : Jayesh
* Date : 6 May 2019
* Description : Method to populate Early Termination Charges for Mobility Products
* Jira Cloud : EDGE-78601
********************************************************************************* */
    public List<Map<String,Object>> getMobilityCancelTypeProducts(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        String soqlQuery='SELECT name,cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, TotalGSTInclusiveTRC__c, cscfga__One_Off_Charge__c, Quantity_Product_Configuration__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r WHERE name=\'Device Model\') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\' AND csordtelcoa__Replaced_Subscription__c!=null AND type__c=\'Cancel\' order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
        Integer j=1;      
        Decimal total_one_off_charge_exGST = 0.00;
        Decimal total_one_off_charge_incGST = 0.00;
        Set<String> offerName = new Set<String>();
        list<cscfga__Product_Configuration__c> pcList = Database.query(soqlQuery);
        // system.debug('valueofquery'+pcList);
        Map<String,Object> rowcancel =null;
        for(cscfga__Product_Configuration__c pc2:pcList){
            if(pc2.OfferName__c=='CWP Mobility' && !pc2.cscfga__Attributes__r.IsEmpty()) {
                rowcancel = new Map<String,Object>();
                String tempOffername='';
                tempOffername = (String.valueOf(pc2.OfferName__c)==null?pc2.csordtelcoa__Replaced_Subscription__r.Name:String.valueOf(pc2.OfferName__c));                   
                if(tempOffername.contains('CWP Mobility'))
                    rowcancel.put('Existing_Service','CWP Mobility');
                else
                    rowcancel.put('Existing_Service',tempOffername);
                rowcancel.put('GSTExcl_TotalETC',pc2.cscfga__unit_one_off_charge__c);
                rowcancel.put('GSTIncl_TotalETC',calculateGSTIncludedPrice(pc2.cscfga__unit_one_off_charge__c));
                //rowcancel.put('Device_Model',pc2.cscfga__Display_Value__c);
                if(!pc2.cscfga__Attributes__r.IsEmpty())
                    rowcancel.put('Device_Model',pc2.cscfga__Attributes__r[0].cscfga__Display_Value__c);
                rowcancel.put('GSTIncl_Total_Onceoff_Charges',total_one_off_charge_incGST);
                rowcancel.put('Quantity',pc2.Quantity_Product_Configuration__c);
                // system.debug('row in q3:'+rowcancel);
                rowcancel.put('ExternalId', String.valueOf(j));
                rows.add(rowcancel);
                j++;
            }
        }        
        return rows;
    }
    // end EDGE-78601
    //EDGE-88163 - Start Descr: Get parent products to dynamically show/hide Minimum Commitment table
    //Defect - EDGE-109988 : Fix applied in below method for deciding if minimum-commitment,important-information table to be shown or not.
      public List<Map<String,Object>> getParentProducts(String basketId){
       //This below code will give the count of Queries that are consumed. 
        Integer startingCount =  Limits.getQueries(); System.debug('getParentProducts Starting Count of Query -> '+startingCount); 
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        //EDGE-114970 : Capturing redemption information in Order form for customer sign off            
        List<Double> validDOPRedeemAmtList = new List<Double>();
        List<Double> validTCRedeemAmtList = new List<Double>();
        List<Double> validNGEMRedeemAmtList = new List<Double>(); //EDGE-148728
        try{
            Integer externalID=1;
            Set<String> offers = getOffersInBasket(basketId);
            Map<String,Object> row = new Map<String,Object>();
         system.debug('inside getParentProducts');
            String basket_Id = String.escapeSingleQuotes(basketId);
            //INC000093040240 change showHideMinimumCommitment from Boolean to Decimal
            Decimal showHideMinimumCommitment = 0; 
          Boolean showHideImportantInfo = false;
      //EDGE-171429 | Start
            Map<String, ProductSpecificationCode__mdt> map_PDvsSecId = new Map<String, ProductSpecificationCode__mdt>();
            String amPlan = 'Enterprise Mobility Plan';
            String amDevice = 'Next Generation Mobile Device';
            String amAccessory='Mobile Accessory';
            //Aruna - DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
            //String iotSub ='IOT Subscription';
            List<ProductSpecificationCode__mdt> ngemSpecIds = [Select id,Label,ProductCategory__c,ProdSpecId__c from ProductSpecificationCode__mdt];
            for(ProductSpecificationCode__mdt ngemSpec:ngemSpecIds){
                map_PDvsSecId.put(ngemSpec.Label,ngemSpec);
            }
            //EDGE-171429 | End
            //list<cscfga__Product_Configuration__c> prodList = [SELECT id,name,Offername__c,Marketable_Offer__r.Offer_ID__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basket_Id];
            //EDGE-144228 Added Inner Query
        //Added where condition to the query for optimization "OR Name = 'RedeemFund'" as a part of DIGI-20532
        list<cscfga__Product_Configuration__c> prodList = [SELECT id,name,type__c,subType__c,cscfga__Product_Definition__r.product_Specification__c,Offername__c,Marketable_Offer__r.Offer_ID__c,Sale_Eligibility__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c,cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c,
        cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where name = 'OfferTypeString' OR Name = 'RedeemFund') FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basket_Id];//EDGE-155059 & EDGE-162542 Added type in the query
         system.debug('prodList--->'+prodList.size());
        system.debug(prodList);

        //DIGI-20532 Started 
        List<cscfga__Attribute__c> listOfRedeemFundsAttributes=new List<cscfga__Attribute__c>();
        
        for(cscfga__Product_Configuration__c pcInstance:prodList){
            for(cscfga__Attribute__c attributeInstance :pcInstance.cscfga__Attributes__r){
                if(attributeInstance.Name=='RedeemFund'){
                    listOfRedeemFundsAttributes.add(attributeInstance);
                }                   
            }
        }
        
    
        if (listOfRedeemFundsAttributes.size() >0) {
            String amount;
            String marOfferId;
            offerRedeemAmtMap = new Map<String, List<Double>>();
            List<Double> validRedeemAmtList = null;
            for(cscfga__Attribute__c redeemAttr : listOfRedeemFundsAttributes){
                marOfferId = redeemAttr.cscfga__Product_Configuration__r.Marketable_Offer__r.Offer_ID__c;
                amount = redeemAttr.cscfga__Value__c;
                if (offerRedeemAmtMap.get(marOfferId) != null){
                    validRedeemAmtList =  offerRedeemAmtMap.get(marOfferId); 
                }
                else {
                    validRedeemAmtList = new List<Double>();                                          
                }
                
                if(amount!=null){   
                    system.debug('amountdouble::' + Double.valueOf(amount));
                    if(Double.valueOf(redeemAttr.cscfga__Value__c) != 0.00){
                        validRedeemAmtList.add(Double.valueOf(redeemAttr.cscfga__Value__c));
                    }
                }
                offerRedeemAmtMap.put(marOfferId, validRedeemAmtList);
            }
            //basketRedeemMap.put(basketId, offerRedeemAmtMap);
        } 
        // DIGI-20532 End
           // for(String offer:offers){
                //// system.debug('@@offer'+offer) ;       
                //EDGE-114970 : Capturing redemption information in Order form for customer sign off    
    
                 //EDGE-123788  Display Delegated Discounts in Quote Document
                boolean isProApplied =isPromotionApplied(basketId);
                Boolean isFairplay=false;//EDGE-145184/INC000092558413 Changes
                Boolean isInviteOnlyPlanInBasket=false; //DIGI-3376
                for(cscfga__Product_Configuration__c pc1:prodList){
                    // system.debug('pc1.Marketable_Offer__r.Offer_ID__c==>'+pc1.Marketable_Offer__r.Offer_ID__c);   
                    // system.debug('pc1.cscfga__Product_Definition__r==>'+pc1.cscfga__Product_Definition__r);
                    // system.debug('pc1.cscfga__Product_Definition__r.product_Specification__c==>'+pc1.cscfga__Product_Definition__r.product_Specification__c);
                    //EDGE-210438 Start
                    if(pc1.type__c == 'Cancel'){
                        row.put('isCancel',True);    
                        }  
                    //EDGE-210438 End
                               
                    if(pc1.Marketable_Offer__r.Offer_ID__c==cwpId){
                        // system.debug('inside CWP Offerspecid');
                        row.put('isCWP',True);
                        if(minimumCommitmentAvailable.contains(cwpId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        //showHideMinimumCommitment = minimumCommitmentAvailable.contains(cwpId);//INC000093040240 End
                        showHideImportantInfo = importantInformationAvailable.contains(cwpId);
                    }
                    /*  EDGE-172118 //EDGE-148728 START
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==ngemId){
                        // system.debug('inside NGEM Offerspecid');
                        row.put('isNGEM',True);
                        if(!validNGEMRedeemAmtList.isEmpty())
                            row.put('isNGEMRedeemable',True);
                        else
                            row.put('isNGEMRedeemable',False);
                        if(minimumCommitmentAvailable.contains(ngemId)==true){
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                    }  EDGE-172118 */
                    //EDGE-148728 END


                    //EDGE-165326 & EDGE-172118 Start
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==ngemPlanId || pc1.Marketable_Offer__r.Offer_ID__c==ngemId){
                        // system.debug('inside NGEM Plan Offerspecid');
                        row.put('isNGEMPlan',True);

            //EDGE-155059 & EDGE-162542 Start
                        if(pc1.type__c == 'Cancel'){
                        row.put('isNGEMPlanCancel',True);    
                        }
                        //EDGE-155059 & EDGE-162542 End
                        System.debug('offerRedeemAmtMap -->'+offerRedeemAmtMap);
                        if(offerRedeemAmtMap!=null && offerRedeemAmtMap.size()>0)
                            validNGEMRedeemAmtList = offerRedeemAmtMap.get(pc1.Marketable_Offer__r.Offer_ID__c); // DIGI-20532 Added this code to get the values
                        //offerIdWiseRedeemedAmountList(basketId,pc1.Marketable_Offer__r.Offer_ID__c);//EDGE-216201 -// DIGI-20532 removed this method
                        system.debug('validNGEMRedeemAmtList::'+ validNGEMRedeemAmtList);
                        if(validNGEMRedeemAmtList!=null && !validNGEMRedeemAmtList.isEmpty())
                            row.put('isNGEMRedeemable',True);
                        else
                            row.put('isNGEMRedeemable',False);
                        if(minimumCommitmentAvailable.contains(ngemPlanId)==true || minimumCommitmentAvailable.contains(ngemId)==true){
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        if(pc1.cscfga__Product_Definition__r.product_Specification__c == ngemDeviceProdSpecId){
                             // system.debug('inside NGEM Offerspecid');
                          row.put('isNGEM',True);
                        }
                        //DPG-3508
                        if(pc1.cscfga__Product_Definition__r.product_Specification__c == ngemAccProdSpecId){
                             // system.debug('inside NGEM Offerspecid');
                          row.put('isNGEMDeviceNew',True);
                        }
            //EDGE-171429 - Start
            if(pc1.type__c == 'New' || pc1.type__c == 'CHOWN' ||  pc1.subType__c == 'No Fault Return' )//EDGE-209790
                        {
                            row.put('isNGEMNew',True);
                            if(pc1.cscfga__Product_Definition__r.product_Specification__c==map_PDvsSecId.get(amPlan).ProdSpecId__c || (String.isBlank(pc1.subType__c)))//EDGE-188100 Added sybType__c check //EDGE-209790 Chown OR condition changed
                                row.put('isNGEMPlanNew',True);
                                if(pc1.cscfga__Product_Definition__r.product_Specification__c==map_PDvsSecId.get(amDevice).ProdSpecId__c || pc1.subType__c == 'No Fault Return')
                                row.put('isNGEMDeviceNew',True);
                        }
                        if(pc1.type__c == 'Modify' || pc1.subType__c == 'No Fault Return'){
                            row.put('isNGEMMac',True);
                            if(pc1.cscfga__Product_Definition__r.product_Specification__c==map_PDvsSecId.get(amPlan).ProdSpecId__c)
                                row.put('isNGEMPlanMac',True);
                        }
                        //EDGE-171429 - End
                    }
                    //EDGE-165326 & EDGE-172118 END
                    
                   
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==pphhId){
                        row.put('isPPHH',True);
                        // system.debug('isPPHH@@::');
                        if(minimumCommitmentAvailable.contains(pphhId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        //showHideMinimumCommitment = minimumCommitmentAvailable.contains(pphhId);//INC000093040240 End
                        //EDGE-147419 Added if to skip this execution if showHideImportantInfo is already true.
                        if(showHideImportantInfo==false){
                        showHideImportantInfo = importantInformationAvailable.contains(pphhId);
                        }
                        //EDGE-147419
                        //EDGE - 105921 - START
                        /*if(pc1.name=='Corporate Mobile Plus-FairPlay Data'){
                            row.put('isFairplayData',True);//EDGE-137773
                            // system.debug('FairPlay Data@@::' + row);//EDGE-137773
                        }
                        if(pc1.name=='Corporate Mobile Plus-Committed Data'){
                            row.put('isCommittedData',True);
                            // system.debug('Committed Data@@::' + row);//EDGE-137773
                        }
                        // system.debug('ROWS@@::' + row);//EDGE-137773*/
                        //EDGE-144228 Start
                       /* for(cscfga__Attribute__c attribute:pc1.cscfga__Attributes__r) {
                            // system.debug('attribute:'+attribute.name);
                            if(attribute.cscfga__Value__c == 'Committed Data'){
                              row.put('isCommittedData',True);
                              // system.debug('Committed Data@@::' + row);  
                            }
                        }*/
                        //EDGE-145184/INC000092558413 Changes Start Here
                        for(cscfga__Attribute__c attribute:pc1.cscfga__Attributes__r) {
                            // system.debug('attribute:'+attribute.name);
                            if(!isFairplay){
                                 if(attribute.cscfga__Value__c == 'FairPlay Data' && attribute.Name=='OfferTypeString'){
                                  isFairplay=true;
                                  break ; // added break as a part of EDGE-216040
                                }
                            }
                        }
                        // system.debug('valueoFAIRPLAY'+isFairplay);
                        if(isFairplay)
                             row.put('isCommittedData',False);
                        else
                            row.put('isCommittedData',True);
                        //EDGE-145184/INC000092558413 Changes End Here
                        // system.debug('ROWS@@::' + row);
                        //EDGE-144228 End
                        //EDGE-123788   Display Delegated Discounts in Quote Document
                        if(isProApplied){
                            row.put('isPromotionsApplied',True);
                        }else{
                            row.put('isPromotionsApplied',False);
                        }                      
                        //EDGE - 105921 - End
                    }
                    //EDGE-81548 - Start
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==mdmId){
                        row.put('isMDM',True);
                        // EDGE-138986 | Commenting Important Info and Minimum Commitment for MDM | No change in flow
                        /* showHideMinimumCommitment = minimumCommitmentAvailable.contains(mdmId);
                        showHideImportantInfo = importantInformationAvailable.contains(mdmId); */
                    }
                    //changes start for 99894
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==dopId) {
                        row.put('isDOP',True);
                        //EDGE-114970 : Capturing redemption information in Order form for customer sign off 
                         System.debug('offerRedeemAmtMap -->'+offerRedeemAmtMap);
                        if(offerRedeemAmtMap!=null && offerRedeemAmtMap.size()>0)
                            validDOPRedeemAmtList =  offerRedeemAmtMap.get(pc1.Marketable_Offer__r.Offer_ID__c); // DIGI-20532 Added this code to get the values
                    //offerIdWiseRedeemedAmountList(basketId,pc1.Marketable_Offer__r.Offer_ID__c);//EDGE-216201  - // DIGI-20532 removed this method
                        system.debug('validDOPRedeemAmtList::' + validDOPRedeemAmtList);
                        if(validDOPRedeemAmtList!=null && !validDOPRedeemAmtList.isEmpty()){
                            row.put('isDOPRedeemable',True);
                        }else{
                            row.put('isDOPRedeemable',False);
                        }
                        if(minimumCommitmentAvailable.contains(dopId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        //showHideMinimumCommitment = minimumCommitmentAvailable.contains(dopId);//INC000093040240 End
                        showHideImportantInfo = importantInformationAvailable.contains(dopId);
                    }
                    //changes end for 99894
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==tcId){
                        row.put('is_TC',True);
                        //EDGE-114970 : Capturing redemption information in Order form for customer sign off  
                        System.debug('offerRedeemAmtMap -->'+offerRedeemAmtMap);
                        if(offerRedeemAmtMap!=null && offerRedeemAmtMap.size()>0)                
                            validTCRedeemAmtList =  offerRedeemAmtMap.get(pc1.Marketable_Offer__r.Offer_ID__c); // DIGI-20532 Added this code to get the values
                    //offerIdWiseRedeemedAmountList(basketId,pc1.Marketable_Offer__r.Offer_ID__c);//EDGE-216201 - // DIGI-20532 removed this method
            if(validTCRedeemAmtList!=null && !validTCRedeemAmtList.isEmpty()){
                            row.put('isTCRedeemable',True);
                        }else{
                            row.put('isTCRedeemable',False);
                        }
                       
                        //EDGE-210438 Start
                        if(ngUCAcceUCDSpecCode.contains(pc1.cscfga__Product_Definition__r.product_Specification__c))
                        {
                            row.put('isTCDevAcc',True);
                        }
                         if(pc1.type__c == 'Cancel'){
                             row.put('isTCCancel',True);}//EDGE-210438 End
                    }
                    //changes for DPG-598
                     /*   else if(pc1.Marketable_Offer__r.Offer_ID__c==iotId){
                    // system.debug('PDH : Inside IOT ....'+iotId);                                
                       // row.put('is_IOT',True);
                        if(minimumCommitmentAvailable.contains(iotId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                       // showHideMinimumCommitment = minimumCommitmentAvailable.contains(iotId);//INC000093040240 End
                        showHideImportantInfo = importantInformationAvailable.contains(iotId);
                        if(pc1.type__c == 'New' || pc1.type__c == 'Modify'){
                            if(pc1.cscfga__Product_Definition__r.product_Specification__c==map_PDvsSecId.get(iotSub).ProdSpecId__c)
                                row.put('is_IOT',True);
                        }
                    }*/
                    //EDGE-123562 Start
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==mmsId){
                        row.put('isMobilityManagedService',True);
                        if(minimumCommitmentAvailable.contains(mmsId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        //showHideMinimumCommitment = minimumCommitmentAvailable.contains(mmsId);//INC000093040240 End
                        showHideImportantInfo = importantInformationAvailable.contains(mmsId);
            //Mahima AMMS Cancel
                        if(pc1.type__c == 'Cancel'){
                          row.put('isMobilityManagedService_Cancel',True);    
                    } 
                    } 
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==psMdmId){
                        row.put('isPSMDM',True);
                        showHideImportantInfo = importantInformationAvailable.contains(psMdmId);
                    } 
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==telCollabPSId){
                        row.put('isPSTelstraCollaboration',True);
                        showHideImportantInfo = importantInformationAvailable.contains(telCollabPSId);
                    } //EDGE-123562 End 
                    
                    //EDGE-98336 - Start
                    else if(pc1.Marketable_Offer__r.Offer_ID__c==tidId){
                        row.put('isTID',True);
                        if(minimumCommitmentAvailable.contains(tidId)==true){//INC000093040240 Start
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        //showHideMinimumCommitment = minimumCommitmentAvailable.contains(tidId);//INC000093040240 End
                        showHideImportantInfo = importantInformationAvailable.contains(tidId);
                    }
                    //EDGE-98336 - End
                    //EDGE-81548 - End
           //DPg-2317--mahima gandhe
                     else if(pc1.Marketable_Offer__r.Offer_ID__c==adaptiveCareId) {
                        row.put('IsAdaptiveCare',True);


                          //Adptive care Cancel--Mahima
                          if(pc1.type__c == 'Cancel'){
                        row.put('IsAdaptiveCare_Cancel',True);    
                        }

                     }else if(pc1.Marketable_Offer__r.Offer_ID__c==ammsLCId){ //DIGI-5562
                        row.put('isAMMSLifecycleNew',True);
                        if(minimumCommitmentAvailable.contains(ammsLCId)==true){
                            showHideMinimumCommitment=showHideMinimumCommitment+1;
                        }
                        
                        showHideImportantInfo = importantInformationAvailable.contains(ammsLCId);
                       
                        if(pc1.type__c == 'Cancel'){
                            row.put('isAMMSLifecycleCancel',True);    
                        } 
                    }else if(pc1.Marketable_Offer__r.Offer_ID__c==ammsInTuneId){
                        row.put('isAMMSIntuneNew',True);
                       if(minimumCommitmentAvailable.contains(ammsInTuneId)==true){
                           showHideMinimumCommitment=showHideMinimumCommitment+1;
                       }
                       
                       showHideImportantInfo = importantInformationAvailable.contains(ammsInTuneId);
                      
                       if(pc1.type__c == 'Cancel'){
                           row.put('isAMMSIntuneCancel',True);    
                       } 
                    }

                    //DPG-3508
                     if(pc1.cscfga__Product_Definition__r.product_Specification__c == ngemAccProdSpecId){
                         // system.debug('inside  Am Accessory ');
                         row.put('isNGEMDeviceNew',True);
                     }
                     //EDGE-171311- deployed with DPG DPG-5624 regression impact 
                     if(pc1.subType__c=='Inflight Cancel')
                     {                       
                         row.put('isBsktInflight_Cancel',True);                      
                     }
                     if(pc1.Sale_Eligibility__c=='Invite Only'){ //DIGI-3376
                        isInviteOnlyPlanInBasket=true; 
                    }
                    row.put('ExternalId', String.valueOf(externalID));
                    //Reusing Type,Order-type field to store boolean for show/hide   
                    //row.put('Type',showHideMinimumCommitment);//INC000093040240 fix
                    row.put('Order_Type',showHideImportantInfo);
                    // system.debug('@@@row1234'+row);
                }                       
                //INC000093040240 Start
                    if(showHideMinimumCommitment>0){
                    row.put('Type',true);
                    }   
                    else{
                        row.put('Type',false);
                    }                   
                //INC000093040240 End  
                if((row.get('isMDM')==true || row.get('isMobilityManagedService')==true || row.get('IsAdaptiveCare')==true || row.get('isNGEMNew')==true || row.get('isAMMSLifecycleNew')==true || row.get('isAMMSIntuneNew') ==true) && isInviteOnlyPlanInBasket){ //DIGI-5562
                     row.put('OCT_URL_WITH_TEXT','<a href="'+Label.INVITE_ONLY_CUSTOMER_URL+'" style="color:#0000ff">here</a> ');
                     row.put('OCT_URL_with_Service_Terms','<a href="'+Label.INVITE_ONLY_CUSTOMER_URL+'" style="color:#0000ff">Service Terms</a> ');
                     row.put('OCT_URL', Label.INVITE_ONLY_CUSTOMER_URL);
                 } else{
                     row.put('OCT_URL_WITH_TEXT','<a href="'+Label.STANDARD_CUSTOMER_URL+'" style="color:#0000ff" >here</a> ');
                     row.put('OCT_URL_with_Service_Terms','<a href="'+Label.STANDARD_CUSTOMER_URL+'" style="color:#0000ff">Service Terms</a> ');
                     row.put('OCT_URL',Label.STANDARD_CUSTOMER_URL);
                 } 
                 
                 if(row.get('isMobilityManagedService')==true || row.get('isAMMSLifecycleNew')==true || row.get('isAMMSIntuneNew') ==true){ ////DIGI-5562
                     row.put('isAMMS',true);
                     row.put('isAMMSNew',true);
                 }
                 if(row.get('isMobilityManagedService_Cancel')==true || row.get('isAMMSLifecycleCancel')==true || row.get('isAMMSIntuneCancel')==true){ //DIGI-5562
                    row.put('isAMMS',true);
                    row.put('isAMMSCancel',true);
                    row.put('isAMMSNew',false);
                 }        
            //}
            // system.debug('@@@row'+row);
            rows.add(row);
            system.debug('@@@rows'+rows);
            externalID++;
        }
        catch(Exception e){
            System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());
        }
        Integer endQuerycountdiff = Limits.getQueries();// end- start 
        System.debug('getParentProduct - End count of remaining Query  -> '+(endQuerycountdiff - startingCount));
        System.debug('Total Queries Consumed in this Transaction '+limits.getQueries());
        return rows;
    }
    //EDGE-88163 - End
    //EDGE-114970 : Capturing redemption information in Order form for customer sign off
    public List<Double> offerWiseRedeemedAmountList(String basketId, String offerName){         
        // system.debug('Inside offerWiseRedeemedAmountList');   
        // system.debug('basketId@@' + basketId+' offerName@@' + offerName);
        List<Double> validRedeemAmtList = new List<Double>(); 
        if(offerName != null){
            List<cscfga__Attribute__c> redeemAmtList = [Select cscfga__Value__c 
                                                    from cscfga__Attribute__c 
                                                    where  cscfga__Product_Configuration__r.cscfga__Product_Basket__c=:basketId and 
                                                    name ='RedeemFund' and cscfga__Product_Configuration__r.Offername__c =:offerName];
            // system.debug('redeemAmtList@@::' + redeemAmtList);
            if(redeemAmtList.size() > 0){
                for(cscfga__Attribute__c amtList : redeemAmtList){
                    // system.debug('amtList::@@' + amtList);
                    if(amtList.cscfga__Value__c!=null){//INC - INC000094326608
                    if(Double.valueOf(amtList.cscfga__Value__c) != 0.00){
                        validRedeemAmtList.add(Double.valueOf(amtList.cscfga__Value__c));
                    }       
                }   
            }            
        }        
        }        
        return validRedeemAmtList;
    }
    //EDGE-123788   Display Delegated Discounts in Quote Document
    public Boolean isPromotionApplied(String basketId){     
        List<Discount_Line_Item__c> lstOfDLI = [Select Id, Name From Discount_Line_Item__c Where chargeInstance__r.basketId__c=:basketId];
        if(lstOfDLI!=null && !lstOfDLI.isEmpty()){
            return true;
        }else{
            return false;
        }        
    }
    public static list<cspmb__Price_Item_Add_On_Price_Item_Association__c> getPIsForPC(List<Id> piIds){
        List<cspmb__Price_Item_Add_On_Price_Item_Association__c> priceItemList = new List<cspmb__Price_Item_Add_On_Price_Item_Association__c>();
        if(!priceItemList.isEmpty()){
            return priceItemList;
        }else{  
            priceItemList = [Select Id, Name, cspmb__Add_On_Price_Item__r.charge_id__c,cspmb__Add_On_Price_Item__r.Billing_Description__c,cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c,cspmb__Recurring_Charge__c, cspmb__Add_On_Price_Item__r.taxTreatment__c from cspmb__Price_Item_Add_On_Price_Item_Association__c where Id IN:piIds];                      
            return priceItemList;
        }  
    }
    //EDGE-98246 - Start - Get Corporate Mobile Plus Services  
    public List<Map<String,Object>> getCMPServices(String basketId, Map<String,String> subfilters) {
        // system.debug('Inside GetCMPServices');
        // system.debug('lstOfferIds--->'+lstOfferIds);
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String,List<cscfga__Product_Configuration__c>> map_PlanvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        //EDGE-162024 - Map declaration for unique key    
        Map<String,List<cscfga__Product_Configuration__c>> map_PlanNetValuevsPC = new Map<String,List<cscfga__Product_Configuration__c>>(); 
        // EDGE-162024 End
        Map<String, String> map_PlanVsPriceItem = new Map<String, String>();
        //EDGE-162025 start
        Map<String,String> map_AttributeVsValue = new Map<String, String>();
        Map<String,List<Id>> map_AddonIDDAsso = new Map<String,List<Id>>();
        Map<String,List<Id>> map_Addon3GStandardAsso = new Map<String,List<Id>>();
        //EDGE-162025 end
        // EDGE - 117740 Start
        Map<String, String> map_PlanVsPriceItemCommit;
        //EDGE - 117740 End
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        //EDGE-140420
        Decimal sharedQuantity=0;
        //EDGE - 117740
        String objectAPIName=''; Id temp;
        String sCommittedData = '';
        String sCommittedBonusData = '';
        //EDGE - 117740
        Decimal sCommittedText;
        Map<String,List<Id>> map_AddonsAssociation = new Map<String,List<Id>>();
        Map<String,List<Id>> map_Addons = new Map<String,List<Id>>();
        Map<String,String> pcVSDiscount = new Map<String,String>();
        //EDGE - 117740 Start
        Map<String, String> map_PlanVsAllowance;
        List<String> attrIdList1;
        //Map<String, String> map_PlanVsAllowance = new Map<String, String>();
        //Map<String, List<Id>> map_PlanVsAllowance = new Map<String,List<Id>>();
        Map<String, String> map_AllowanceVsBasketsnaphotFields = new Map<String, String>();
        Map<String,CMP_committed_offers__mdt> CMP_committedOffersMap = new Map<String,CMP_committed_offers__mdt>();
        MAP<String,String> map_PlanVsPCAttrib = new Map<String, String>();//EDGE-144779
        //EDGE - 117740 End
        //changes start EDGE - 104681
        List<cscfga__Product_Configuration__c> planPCList = new List<cscfga__Product_Configuration__c>();
        try{
    //filter change
            if(subfilters.get('Type') =='New' ){//EDGE-188100 added subtype__c
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and subtype__c=null];
            }
            else if(subfilters.get('Type') =='Reactivate' ){//EDGE-188100 changes
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null and subtype__c='Reactivate'];
            }
            //EDGE-143435 START | Adding Active type
            else if(subfilters.get('Type') =='Modify'){
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND (Type__c='Modify' OR Type__c='Active') AND csordtelcoa__Replaced_Product_Configuration__c!=null];
            }else if(subfilters.get('Type') =='Cancel'){
                planPCList =[SELECT id,name,cscfga__Product_Family__c,Type__c,cscfga__Contract_Term__c,cscfga__Quantity__c,Quantity_Product_Configuration__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstEMSpecCodes AND cscfga__Product_Basket__c =:basketId AND (Type__c='Cancel' OR Type__c='Active') AND csordtelcoa__Replaced_Product_Configuration__c!=null];
            }
            //EDGE-143435 END
            // system.debug('planPCList:' + planPCList);       
            //EDGE-123788 start
            Map<String,String>  mapOfAddOnAssociationvsPC=new Map<String,String>();
        Map<String,String>  mapOfAddOnvsPC=new Map<String,String>();
            Map<String,List<Discount_Line_Item__c>> mapOfDLIvsDiscount=new Map<String,List<Discount_Line_Item__c>>();
            Map<String,List<Discount_Line_Item__c>> mapOfDLIvsAddOnDiscount=new Map<String,List<Discount_Line_Item__c>>();
      //get the DLI based on basketId related to CLI & Product Config.
            List<Discount_Line_Item__c> lstOfDLI=[Select Id,chargeInstance__c,BusinessID__c,discountValue__c,duration__c,Status__c,
                                                  chargeInstance__r.Product_Configuration__c,chargeInstance__r.Product_Configuration__r.Id,
                                                  chargeInstance__r.Product_Configuration__r.Name,chargeInstance__r.targetChargeProduct__c
                                                  From Discount_Line_Item__c Where chargeInstance__r.basketId__c=:basketId];
            if(lstOfDLI!=null && !lstOfDLI.isEmpty()){
                for(Discount_Line_Item__c dli:lstOfDLI){
                    if(dli.chargeInstance__c!=null && dli.chargeInstance__r.Product_Configuration__c!=null){
                        if(dli.chargeInstance__r.targetChargeProduct__c=='Plan'){
                            if(!mapOfDLIvsDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                                mapOfDLIvsDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                            }else{
                                mapOfDLIvsDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                            }
                        }else if(dli.chargeInstance__r.targetChargeProduct__c=='AddOn'){
                            if(!mapOfDLIvsAddOnDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                                mapOfDLIvsAddOnDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                            }else{
                                mapOfDLIvsAddOnDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                            }
                        }
                    }
                }
            } //EDGE-123788 end
            //changes end EDGE - 104681 
            //EDGE-117740 Start
            //EDGE-117740 Start
            List<CMP_committed_offers__mdt> CMP_committedOffersList = [select MasterLabel,Plan_Data__c,Bonus_Data__c,Total_Data__c,Plan_Rate__c,LT_1__c,PAYG_1_to_2__c,PAYG_2_to_3__c,PAYG_3_to_4__c,PAYG_4_to_5__c,PAYG_GT_5__c,Is_Mandatory__c from CMP_committed_offers__mdt];
            if(!CMP_committedOffersList.IsEmpty()){
                for(CMP_committed_offers__mdt cmpMdtRec : CMP_committedOffersList){
                    CMP_committedOffersMap.put(cmpMdtRec.MasterLabel,cmpMdtRec);
                }
            }
            //EDGE-140420 - Start
            if(EnvironmentVariable__c.getValues('Committed_Data').Value__c=='True'){
                for(cscfga__Product_Configuration__c pcloop:planPCList){
                    // system.debug('$sharedQuantity'+sharedQuantity);
                    //EDGE-143435 | Adding type Active
                    if((pcloop.Type__c=='Cancel'|| pcloop.Type__c=='Active') && pcloop.name.contains('Committed Data')){
                        if(String.isNotEmpty(pcloop.Name) && pcloop.cscfga__Product_Definition__r.product_Specification__c!= pphhId && !(pcloop.Name.contains(xBYOOfferName))){
                            sharedQuantity=sharedQuantity+pcloop.cscfga__Quantity__c;
                            // system.debug('insideNewCondition'+sharedQuantity);
                        }
                    }
                }
            }
            //EDGE-140420 - END
            //EDGE-117740 End
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:planPCList){
                if(map_PlanvsPC.get(pc.Name) == null){
                    // system.debug('map_PlanvsPC.get(pc.Name)' + map_PlanvsPC.get(pc.Name));
                    map_PlanvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());
                    // system.debug('map_PlanvsPC.get(pc.Name) After' + map_PlanvsPC.get(pc.Name));
                }
                //EDGE-162025 start
                for(cscfga__Attribute__c att:pc.cscfga__Attributes__r){
                    map_AttributeVsValue.put(att.Name,att.cscfga__Value__c);
                }
                //EDGE-162025 end
                //EDGE - 117740 Start
                map_PlanVsAllowance = new Map<String, String>();
                map_PlanVsPriceItemCommit = new Map<String, String>();
                Map<String,Object> commitRow = new Map<String,Object>(); 
                //EDGE - 117740 End
                map_PlanvsPC.get(pc.Name).add(pc);
                // system.debug('map_PlanvsPC.get(pc.Name) After' + pc.name);  
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                    // system.debug('attribute:'+attribute.name);
                    // EDGE-162024 - Start
                    if(attribute.Name == 'PlanCharge'){
                        String key = pc.Name + attribute.cscfga__Value__c;
                        if(map_PlanNetValuevsPC.get(key) == null){
                        map_PlanNetValuevsPC.put(key,new List<cscfga__Product_Configuration__c>());                          
                        }
                        map_PlanNetValuevsPC.get(key).add(pc);                    
                    }
                    //EDGE-162024 -End
            //EDGE-144779
                    if(attribute.name == 'OfferTypeString'){
                        map_PlanVsPCAttrib.put(pc.Name,attribute.cscfga__Value__c);
                    }
                    if(isValidId(attribute.cscfga__Value__c)==True){
                        temp = attribute.cscfga__Value__c;
                        objectAPIName = temp.getSObjectType().getDescribe().getName();
                        // system.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);
                        // system.debug('Before Addon elseif@@');
                        if(objectAPIName.equalsIgnoreCase('cspmb__Price_Item__c')){
                            map_PlanVsPriceItem.put(pc.name,attribute.cscfga__Value__c);
                            //EDGE - 117740 Start
                            map_PlanVsPriceItemCommit.put(pc.id,attribute.cscfga__Value__c);
                            // system.debug('map_PlanVsPriceItemCommit-->'+map_PlanVsPriceItemCommit);
                            //EDGE - 117740 End
                            // system.debug('pc.Name' + pc.Name);
                            // system.debug('attribute.cscfga__Value__c' + attribute.cscfga__Value__c);
                            map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);                         
                            // system.debug('attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c' + attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c);
                            // system.debug('attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c' + attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);
                            // system.debug('map_PlanVsPriceItemCommit::999' + map_PlanVsPriceItemCommit);
                        }                           
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Price_Item_Add_On_Price_Item_Association__c'))
                        {
               //EDGE-123788 start
                            mapOfAddOnAssociationvsPC.put(attribute.cscfga__Value__c,attribute.cscfga__Product_Configuration__c);
              //EDGE-123788 end
                            //EDGE-162025 start
                            if(attribute.Name != 'InternationalDirectDial'){
                           if(map_AddonsAssociation.get(attribute.cscfga__Value__c) == null)
                                map_AddonsAssociation.put(attribute.cscfga__Value__c,new List<Id>());
                            map_AddonsAssociation.get(attribute.cscfga__Value__c).add(attribute.id);
                        }
                            // system.debug('map_AddonsAssociation--->'+map_AddonsAssociation);
                            //--- Prod Inc IDD consolidation
                            if(attribute.Name == 'InternationalDirectDial' && map_AttributeVsValue.get('IDD Charge') != null && map_AttributeVsValue.get('SelectIDD') == 'Premium'){
                                String IDDkey;
                                if(map_AttributeVsValue.get('IDD Charge Discounted') == null || map_AttributeVsValue.get('IDD Charge Discounted') == ''){
                                  IDDkey = map_AttributeVsValue.get('SelectIDD')+map_AttributeVsValue.get('IDD Charge'); 
                                }else{
                                  IDDkey = map_AttributeVsValue.get('SelectIDD')+map_AttributeVsValue.get('IDD Charge Discounted');   
                                }
                                if(map_AddonIDDAsso.get(IDDkey)==null){
                                    map_AddonIDDAsso.put(IDDkey,new List<Id>());    
                                }
                                map_AddonIDDAsso.get(IDDkey).add(attribute.cscfga__Value__c);              
                            }
                            //---end
                            // #3G Standard Consolidation map_Addon3GStandardAsso
                            If(attribute.Name =='MessageBank' && map_AttributeVsValue.get('MessageBank RC')!=null && (map_AttributeVsValue.get('MessageBankString') == '3G Standard Retail' || map_AttributeVsValue.get('MessageBankString') == 'VOICE to TEXT')){
                              String keyforAddon = map_AttributeVsValue.get('MessageBankString')+map_AttributeVsValue.get('MessageBank RC');
                                if(map_Addon3GStandardAsso.get(keyforAddon)==null){
                                    map_Addon3GStandardAsso.put(keyforAddon,new List<Id>());
                                }
                                map_Addon3GStandardAsso.get(keyforAddon).add(attribute.cscfga__Value__c);
                            }
                            //EDGE-162025 end
                        }
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Add_On_Price_Item__c'))
                        {
                            // system.debug('attribute.cscfga__Product_Configuration__c' +attribute.cscfga__Product_Configuration__c);
               //EDGE-123788 start
                            mapOfAddOnvsPC.put(attribute.cscfga__Value__c,attribute.cscfga__Product_Configuration__c);
               //EDGE-123788 end
                            if(map_Addons.get(attribute.cscfga__Value__c) == null)
                                map_Addons.put(attribute.cscfga__Value__c,new List<Id>());
                            map_Addons.get(attribute.cscfga__Value__c).add(attribute.id);
                        }
                        //EDGE-117740 Start
                        /*else if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c')){
                            // system.debug('Inside Allowance' + attribute.cscfga__Value__c + '@pd.id' + pc.id);
                            map_PlanVsAllowance.put(pc.id,attribute.cscfga__Value__c);
 //map_AllowanceVsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_//Definition__r.Snapshot_Attribute_Value_Field__c);                         
                        }*/
                        else if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c'))
                        {
                            map_PlanVsAllowance.put(attribute.cscfga__Value__c,attribute.cscfga__Value__c); 
                        }
                        //EDGE-117740 End
                        // system.debug('map_PlanVsPriceItemCommit123' + map_PlanVsPriceItemCommit);
                    }
                    else if(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c.contains('Discount') && !String.isEmpty(attribute.cscfga__Value__c) ){
                        pcVSDiscount.put(pc.id,attribute.cscfga__Value__c);
                        // system.debug('map_PlanVsPriceItemCommit345' + map_PlanVsPriceItemCommit);
                    }
                }
                //EDGE-162025 start
                map_AttributeVsValue.clear();
                //EDGE-162025 end
                // system.debug('map_PlanVsPriceItemCommit890' + map_PlanVsPriceItemCommit);
                //EDGE - 117740 Start
                //if(pc.name == 'Corporate Mobile Plus-Committed Data'){
                if(pc.cscfga__Product_Definition__r.product_Specification__c== pphhId && pc.name.contains('Committed Data')){
                    // system.debug('map_PlanVsPriceItemCommit::inside if' + map_PlanVsPriceItemCommit);
                // system.debug('map_PlanVsAllowance@@@ : ' + map_PlanVsAllowance + ':: PC Name@' + pc.name);
                attrIdList1 = new List<String>(map_PlanVsAllowance.keySet());
                String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList1';            
                Map<id,cspmb__Allowance__c> allowanceRecords1 = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
                // system.debug('@@allowanceRecords1 :: ' + allowanceRecords1);
                commitRow.put('ExternalId', externalID++);
                //EDGE-140420 - Start
                decimal qty=0; 
                //EDGE-143435 | Adding type Active 
                if(EnvironmentVariable__c.getValues('Committed_Data').Value__c=='True' && (pc.Type__c=='Cancel'|| pc.Type__c=='Active')){
                    qty=sharedQuantity;
                }
                else{
                    qty=pc.Quantity_Product_Configuration__c;
                }
                commitRow.put('Quantity',qty);
                //EDGE-140420 - End
                //EDGE-143435 START | Adding NA for ETC rows
                commitRow.put('GSTIncl_TotalETC', 'N/A');
                commitRow.put('GSTExcl_TotalETC', 'N/A');
                //EDGE-143435 END
                //commitRow.put('Rate',pc.cscfga__Recurring_Charge__c);
                //commitRow.put('Product_Module_Name','Committed Data Plan');
                // system.debug('map_PlanVsPriceItemCommit::Before For' + map_PlanVsPriceItemCommit);
                for(String id: map_PlanVsAllowance.keySet()){
                    cspmb__Allowance__c allowance1 = allowanceRecords1.get(id);
                    if(allowance1.type__c == 'Committed Data')
                       sCommittedData = allowance1.Value__c;
                    if(allowance1.type__c == 'Committed Bonus Data')
                    sCommittedBonusData = allowance1.Value__c;
                    }
                    // system.debug('map_PlanVsPriceItemCommit::After For' + map_PlanVsPriceItemCommit);
                    // system.debug('sCommittedData@@@ :: ' + sCommittedData + '@@ sCommittedBonusData @@ ::' + sCommittedBonusData);
                    sCommittedText = decimal.valueOf(sCommittedData) + decimal.valueOf(sCommittedBonusData);
                    // system.debug('sCommittedText@@ : ' + sCommittedText);
                    commitRow.put('Discount_Text',sCommittedText + ' Gb ('+sCommittedData+'Gb + '+sCommittedBonusData+'Gb bonus) data for use in Australia');
                    // system.debug('@@map_PlanVsPriceItemCommit :: ' + map_PlanVsPriceItemCommit);
                    attrIdList1 = new List<String>(map_PlanVsPriceItemCommit.values());
                    // system.debug('attrIdList1'+attrIdList1);
                    query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                    ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList1';
                    // system.debug('query-->'+query);
                    Map<id,cspmb__Price_Item__c> priceItemCommit = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
                    // system.debug('@@priceItemCommit::' + priceItemCommit);
                    for(String id: map_PlanVsPriceItemCommit.values()){
                    cspmb__Price_Item__c priceItemCommitRecord = priceItemCommit.get(id);
                    // system.debug('@@priceItemCommitRecord::' + priceItemCommitRecord);
                    commitRow.put('Rate',priceItemCommitRecord.cspmb__Recurring_Charge__c);
                    commitRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemCommitRecord.cspmb__Recurring_Charge__c);
                    commitRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(qty*priceItemCommitRecord.cspmb__Recurring_Charge__c));
                    commitRow.put('Product_Module_Name',priceItemCommitRecord.name);
                    commitRow.put('Unit_Of_Measure',priceItemCommitRecord.Unit_Of_Measure__c);
                    }
                    //EDGE-140420 - Start
                   //if(EnvironmentVariable__c.getValues('Committed_Data').Value__c=='True' && pc.Type__c=='Cancel'){
                        if(qty>0)
                            // system.debug('commitRow-->'+commitRow);
                        rows.add(commitRow);
                   // }
                   // else{*/
                      //  rows.add(commitRow);
                  //  }
                    //EDGE-140420 - Start
                }
                //EDGE - 117740 End
            }
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_PlanvsPC: '+map_PlanvsPC);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_PlanVsPriceItem: '+map_PlanVsPriceItem);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_PriceItemvsBasketsnaphotFields: '+map_PriceItemvsBasketsnaphotFields);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_AddonsAssociation: '+map_AddonsAssociation);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_Addons: '+map_Addons);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:pcVSDiscount: '+pcVSDiscount);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_PlanVsAllowance: '+map_PlanVsAllowance);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:CMP_committedOffersMap: '+CMP_committedOffersMap);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:map_PlanVsPCAttrib: '+map_PlanVsPCAttrib);
            List<String> attrIdList = map_PlanVsPriceItem.values();
            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(query));
            attrIdList = new List<String>(map_AddonsAssociation.keySet());
            query = ' SELECT cspmb__Add_On_Price_Item__r.Billing_Description__c,cspmb__Add_On_Price_Item__r.Charge_Id__c,cspmb__Add_On_Price_Item__r.taxTreatment__c, ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item_Add_On_Price_Item_Association__c')) + ' ,cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c' +
                ' FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE id IN :attrIdList';               
            Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c> Add_On_Price_Item_Association_Records = new Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c>((List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)Database.query(query));
            attrIdList = new List<String>(map_Addons.keySet());
            query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Add_On_Price_Item__c')) + ' ' +
                ' FROM cspmb__Add_On_Price_Item__c WHERE id IN :attrIdList';                  
            Map<id,cspmb__Add_On_Price_Item__c> Add_On_Price_Item_Records = new Map<id,cspmb__Add_On_Price_Item__c>((List<cspmb__Add_On_Price_Item__c>)Database.query(query));
            //EDGE-117740 Start
            //attrIdList = new List<String>(map_PlanVsAllowance.values());
            attrIdList = new List<String>(map_PlanVsAllowance.keySet());
            query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Allowance__c> allowanceRecords = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
            //EDGE-117740 End
            //attrIdList = new List<String>(map_Addons.keySet());
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:priceItemsRecords: '+priceItemsRecords);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:Add_On_Price_Item_Association_Records: '+Add_On_Price_Item_Association_Records);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:Add_On_Price_Item_Records: '+Add_On_Price_Item_Records);
            // system.debug('map_PlanvsPC.keySet()' + map_PlanvsPC.keySet());
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:allowanceRecords: '+allowanceRecords);
            for(String deviceKey: map_PlanNetValuevsPC.keySet()){
                // system.debug('deviceKey' + deviceKey);
                Map<String,Object> newRow = new Map<String,Object>();                
                Integer qty = map_PlanNetValuevsPC.get(deviceKey).size(); 
                if(qty>0){
                    String displayText='';
                    // system.debug('QTY > 0' + qty);
                    List<cscfga__Product_Configuration__c> lstOfPC1=map_PlanNetValuevsPC.get(deviceKey);
                    // system.debug('PC Name-->'+lstOfPC1[0].Name);
                    String pcName = lstOfPC1[0].Name;
                    //newRow.put('Product_Module_Name',String.valueOf(deviceKey));
                    //if(deviceKey != 'Corporate Mobile Plus-Committed Data' && deviceKey !='Corporate Mobile Plus-FairPlay Data'){//EDGE - 117740
                    //EDGE-144779
                    if(!(map_PlanVsPCAttrib.get(pcName) =='Committed Data' || map_PlanVsPCAttrib.get(pcName) =='FairPlay Data')){
                    // system.debug('Inside Device Key If@@::');    
                    newRow.put('ExternalId', externalID++);
                    newRow.put('Quantity',qty);
                        cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_PlanVsPriceItem.get(pcName));
                        // system.debug('priceItemRecord--->'+priceItemRecord);
             //EDGE-123788 start
                        List<cscfga__Product_Configuration__c> lstOfPC=map_PlanNetValuevsPC.get(deviceKey);
                        List<String> listOfDiscountText=new List<String>();
                        // String displayText='';
                        if(lstOfPC!=null && !lstOfPC.isEmpty()){
                            for(cscfga__Product_Configuration__c pc:lstOfPC){
                                if(pc.Name==lstOfPC[0].Name){
                                    if(mapOfDLIvsDiscount!=null){
                                        // system.debug('pc.Id-->'+pc.Id);
                                        // system.debug('mapOfDLIvsDiscount-->'+mapOfDLIvsDiscount);
                                       listOfDiscountText=getDiscountApplied(pc.Id,mapOfDLIvsDiscount);
                                        // system.debug('listOfDiscountText---->>'+listOfDiscountText);
                                   }
                                }
                            }
                        }
            //EDGE-123788 end
                    // system.debug('###########---lstOfPC>'+lstOfPC);
                    // system.debug('###########---displayText>'+displayText);
                    if(priceItemRecord != null) //EDGE-117740
                    {
                        newRow.put('Product_Module_Name',(priceItemRecord.Billing_Description__c).capitalize());
                        // system.debug('capitalize:'+(priceItemRecord.Billing_Description__c).capitalize());
                        newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                        newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                        newRow.put('Rate',priceItemRecord.cspmb__Recurring_Charge__c);
                        newRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                        if(priceItemRecord.taxTreatment__c!=null && priceItemRecord.taxTreatment__c.contains('GST Applicable'))    
                            newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                        else
                            newRow.put('GSTIncl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                    }
                    newRow.put('GSTIncl_TotalETC', 'N/A');
                    newRow.put('GSTExcl_TotalETC', 'N/A');
           //EDGE-123788 start
            if(!listOfDiscountText.isEmpty()){
                            String discountStr=String.valueOf(listOfDiscountText);
                            newRow.put('Discount_Text', discountStr);
                        }
           //EDGE-123788 end
                    rows.add(newRow);
                    }
                }
            }
            //---- EDGE-162025 - Sun -IDD Prod Incident fix
            List<Id> lstaddonAllIds = new List<Id>();
            for(String id: map_AddonIDDAsso.keySet()){
                lstaddonAllIds.addAll(map_AddonIDDAsso.get(id));
            }
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lstPIAddon=getPIsForPC(lstaddonAllIds);
            for(String id: map_AddonIDDAsso.keySet()){
                Decimal totalRC = 0.00;String unitofMsg;String taxTreatment;String billingDesc;Decimal IDDRate = 0.00;
                Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c> mapAddIdVsRec = new Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c addon1:lstPIAddon){
                    mapAddIdVsRec.put(addon1.Id,addon1);
                    unitofMsg = addon1.cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c;
                    taxTreatment = addon1.cspmb__Add_On_Price_Item__r.taxTreatment__c;
                    billingDesc = addon1.cspmb__Add_On_Price_Item__r.Billing_Description__c;
                }
                for(Id ids:map_AddonIDDAsso.get(Id)){
                    totalRC += mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                    IDDRate = mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                }
                List<String> listOfDiscountText=new List<String>();
                if(!lstPIAddon.isEmpty()){
                    String pCId=mapOfAddOnAssociationvsPC.get(lstPIAddon[0].Id);                    
                    if(pCId!=null){
                        if(lstPIAddon[0].cspmb__Add_On_Price_Item__r.charge_id__c=='DMCAT_RecurringCharge_000669'){
                            listOfDiscountText.addAll(getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount));
                        }
                    }
                }
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',billingDesc);
                Integer qty = map_AddonIDDAsso.get(id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',unitofMsg);
                newRow.put('Rate',IDDRate);
                newRow.put('GSTExcl_Total_Recurring_Charges',totalRC);
                if(taxTreatment!=null && taxTreatment.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(totalRC));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',totalRC);  
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');                
                if(!listOfDiscountText.isEmpty()){
                    String discountStr=String.valueOf(listOfDiscountText);
                    newRow.put('Discount_Text', discountStr);
                }        
                // system.debug('newRow--->'+newRow);
                rows.add(newRow);
            }
            // Consolidation for 3g Standard
            List<Id> lst3GAddons = new List<Id>();
            for(String id: map_Addon3GStandardAsso.keySet()){
                lst3GAddons.addAll(map_Addon3GStandardAsso.get(id));
            }
            List<cspmb__Price_Item_Add_On_Price_Item_Association__c> lst3Gadd = getPIsForPC(lst3GAddons); 
            for(String id: map_Addon3GStandardAsso.keySet()){ 
                Decimal totalAddonRC = 0.00;String unitofMsg;String taxTreatment;String billingDesc; Decimal Addonrate = 0.00;
                Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c> mapAddIdVsRec = new Map<Id,cspmb__Price_Item_Add_On_Price_Item_Association__c>();
                for(cspmb__Price_Item_Add_On_Price_Item_Association__c addon2:lst3Gadd){
                    mapAddIdVsRec.put(addon2.Id,addon2);
                    unitofMsg = addon2.cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c;
                    taxTreatment = addon2.cspmb__Add_On_Price_Item__r.taxTreatment__c;
                    billingDesc = addon2.cspmb__Add_On_Price_Item__r.Billing_Description__c;
                }
                for(Id ids:map_Addon3GStandardAsso.get(Id)){
                    totalAddonRC += mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                    Addonrate = mapAddIdVsRec.get(ids).cspmb__Recurring_Charge__c;
                }
          List<String> listOfDiscountText=new List<String>();
                if(!lst3Gadd.isEmpty()){
                    String pCId=mapOfAddOnAssociationvsPC.get(lst3Gadd[0].Id);                    
                if(pCId!=null){
                        if(lst3Gadd[0].cspmb__Add_On_Price_Item__r.charge_id__c=='DMCAT_RecurringCharge_000669'){
                        listOfDiscountText.addAll(getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount));
                        // system.debug('listOfDiscountText---->>'+listOfDiscountText);
                    }
                }
                }
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',billingDesc);
                Integer qty = map_Addon3GStandardAsso.get(Id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',unitofMsg);
                newRow.put('Rate',Addonrate);
                newRow.put('GSTExcl_Total_Recurring_Charges',totalAddonRC);
                if(taxTreatment!=null && taxTreatment.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(totalAddonRC));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',totalAddonRC);  
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');
        if(!listOfDiscountText.isEmpty()){
          String discountStr=String.valueOf(listOfDiscountText);
          newRow.put('Discount_Text', discountStr);
        }
                // system.debug('newRow--->'+newRow);
                rows.add(newRow);
            }
            // End
            //----EDGE-162025 Sun- Prod Incident fix end map_Addon3GStandardAsso
            for(String id: map_Addons.keySet()){
                Map<String,Object> newRow = new Map<String,Object>();
                cspmb__Add_On_Price_Item__c addOn = Add_On_Price_Item_Records.get(id);
         //EDGE-123788 start
        String pCId=mapOfAddOnvsPC.get(id);
         List<String> listOfDiscountText=new List<String>();
        // system.debug('###########---pCId--mapOfAddOnvsPC>'+mapOfAddOnvsPC);
         // system.debug('###########---pCId--AddOnvs>'+pCId);
        if(pCId!=null){
             listOfDiscountText=getDiscountApplied(pCId,mapOfDLIvsAddOnDiscount);
            // system.debug('listOfDiscountText---->>'+listOfDiscountText);
         }
         //EDGE-123788 end
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name',(addOn.Billing_Description__c).capitalize());
                Integer qty = map_Addons.get(id).size();
                newRow.put('Quantity',qty);
                newRow.put('Unit_Of_Measure',addOn.Unit_Of_Measure__c);
                newRow.put('Rate',addOn.cspmb__Recurring_Charge__c);
                newRow.put('GSTExcl_Total_Recurring_Charges',qty*addOn.cspmb__Recurring_Charge__c);
                if(addOn.taxTreatment__c!=null && addOn.taxTreatment__c.contains('GST Applicable'))
                    newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(qty*addOn.cspmb__Recurring_Charge__c));
                else
                    newRow.put('GSTIncl_Total_Recurring_Charges',qty*addOn.cspmb__Recurring_Charge__c);
                newRow.put('GSTIncl_TotalETC', 'N/A');
                newRow.put('GSTExcl_TotalETC', 'N/A');
         //EDGE-123788 start
        if(!listOfDiscountText.isEmpty()){
          String discountStr=String.valueOf(listOfDiscountText);
          newRow.put('Discount_Text', discountStr);
        }
         //EDGE-123788 end
                rows.add(newRow);
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getCMPServices:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getCMPServices:CMP Services found:'+rows);
        return rows;
    }
    //EDGE-98246 - end 
    //EDGE-98246 - utility Method to check if value is a record-id
    static public Boolean isValidId(String strId) {
        Boolean isValid = (strId InstanceOf ID) ? true : false ;
        return isValid ;
    }
    //EDGE-98246 - start Method to get CMP Devices 
    public List<Map<String,Object>> getCMPDevices(String basketId, Map<String,String> subfilters) {
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String,List<cscfga__Product_Configuration__c>> map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
        Map<String, String> map_DeviceModelVsPriceItem = new Map<String, String>();
        Map<String, String> map_PriceItemvsBasketsnaphotFields = new Map<String, String>();
        Integer externalId=1;
        //changes start EDGE - 104681
        List<cscfga__Product_Configuration__c> devicePCList = new List<cscfga__Product_Configuration__c>();  
        try{
            if(subfilters.get('Type') =='New' )
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];//EDGE-154662 Fix
            else if(subfilters.get('Type') =='Modify')
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='Modify' AND csordtelcoa__Replaced_Product_Configuration__c!=null];//EDGE-154662 Fix
            else if(subfilters.get('Type') =='Cancel')
                devicePCList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,Type__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c WHERE cscfga__Parent_Configuration__r.Marketable_Offer__r.Offer_ID__c=:pphhId AND cscfga__Product_Basket__c =:basketId  AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null];//EDGE-154662 Fix
            // system.debug('devicePCList=='+devicePCList);
            //changes end EDGE - 104681
            //map parent-pc with attributes of mobility-plan, message-bank and device
            for(cscfga__Product_Configuration__c pc:devicePCList){
                if(pc.Type__c != 'Cancel'){                                   
                    if(map_DeviceModelvsPC.get(pc.Name) == null){
                        map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());          
                    }
                    map_DeviceModelvsPC.get(pc.Name).add(pc);
                    for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                        if(isValidId(attribute.cscfga__Value__c)==True){
                        map_DeviceModelVsPriceItem.put(pc.Name,attribute.cscfga__Value__c);
                        map_PriceItemvsBasketsnaphotFields.put(attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c,attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c);
                        }
                    }
                    }
                else if(pc.Type__c == 'Cancel'){
                        // system.debug('***Telstra:CancelCMP:pc:'+pc);
                        Map<STRing,Object> cancelDeviceRow = new Map<String,Object>();
                        cancelDeviceRow.put('Product_Module_Name',pc.Name);
                        cancelDeviceRow.put('ExternalId', externalID++);
                        for(cscfga__Attribute__c att:pc.cscfga__Attributes__r){
                            if(isValidId(att.cscfga__Value__c)==False){
                                String mappingfield = (att.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');                      
                                cancelDeviceRow.put(mappingfield, att.cscfga__Value__c);
                                if(mappingfield.equalsIgnoreCase('GSTExcl_TotalETC')){
                                    cancelDeviceRow.put('GSTExcl_TotalETC', att.cscfga__Value__c);
                                  cancelDeviceRow.put('GSTIncl_TotalETC', calculateGSTIncludedPrice(decimal.valueof(att.cscfga__Value__c)));
                                }
                                if(mappingfield.equalsIgnoreCase('RemainingTerm'))
                                    cancelDeviceRow.put('RemainingTerm', 'Your mobile repayment option has '+att.cscfga__Value__c+' months remaining');
                            }           
                    }
                    rows.add(cancelDeviceRow);
                }
            }                  
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:'+map_DeviceModelvsPC);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:map_DeviceModelVsPriceItem:'+map_DeviceModelVsPriceItem);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:map_PriceItemvsBasketsnaphotFields:'+map_PriceItemvsBasketsnaphotFields);
            List<String> attrIdList = map_DeviceModelVsPriceItem.values();
            String priceItemQuery = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item__c')) + ' ' +
                ' FROM cspmb__Price_Item__c WHERE id IN :attrIdList';
            Map<id,cspmb__Price_Item__c> priceItemsRecords = new Map<id,cspmb__Price_Item__c>((List<cspmb__Price_Item__c>)Database.query(priceItemQuery)); 
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:priceItemsRecords:'+priceItemsRecords);
            for(String deviceKey: map_DeviceModelvsPC.keySet()){
                Map<STRing,Object> newRow = new Map<String,Object>();
                newRow.put('Product_Module_Name',String.valueOf(deviceKey));
                newRow.put('ExternalId', externalID++);
                Integer qty = map_DeviceModelvsPC.get(deviceKey).size();
                newRow.put('Quantity',qty);
                cspmb__Price_Item__c priceItemRecord = priceItemsRecords.get(map_DeviceModelVsPriceItem.get(deviceKey));
                if(priceItemRecord!=null){
                    newRow.put('Unit_Of_Measure',priceItemRecord.Unit_Of_Measure__c);
                    newRow.put('Term',priceItemRecord.cspmb__Contract_Term__c);
                    newRow.put('Rate',priceItemRecord.cspmb__Recurring_Charge__c);
                    newRow.put('GSTExcl_Total_Recurring_Charges',qty*priceItemRecord.cspmb__Recurring_Charge__c);
                    newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(qty*priceItemRecord.cspmb__Recurring_Charge__c));
                }
                rows.add(newRow); 
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getCMPDevices:map_DeviceModelvsPC:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        return rows;
    }
    //EDGE-98246 :End
    //EDGE - 81135: get CMP-products of cancel type
    public List<Map<String,Object>>getCMPCancelProducts(String basketID,Map<String,String> subfilters){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        rows.addAll(getCMPServices(basketID,subfilters));
        rows.addAll(getCMPDevices(basketID,subfilters));
        return rows;
    }
    
   

 
 
  
    //EDEG-80783 :Start
    public List<Map<String,Object> > getMDMProfServices(String basketId,Map<String,String> subfilters){
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        Map<String,String> snapshotMapping = new Map<String,String> {'Unit Of Measure Value'=>'Unit_Of_Measure',
            'TotalPrice'=>'GSTExcl_Total_Onceoff_Charges',
            'Unit Price'=>'Rate',
            'Quantity'=>'Quantity'};
                try{
                    System.debug('OfferName Input:'+subfilters.get('Offer_Name'));
                    String Offer_Name=subfilters.get('Offer_Name');
                    Set<String> attributeList= snapshotMapping.keySet();
                    String soqlQuery='SELECT name,cscfga__unit_one_off_charge__c, OfferName__c, cscfga__Contract_Term__c, cscfga__total_one_off_charge__c, TotalGSTInclusiveTOC__c, type__c, TotalGSTInclusiveTRC__c, cscfga__One_Off_Charge__c, Quantity_Product_Configuration__c, (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c= \''+ String.escapeSingleQuotes(basketId)+'\'And name =\''+ String.escapeSingleQuotes(Offer_Name)+'\'order by cscfga__Parent_Configuration__r.cscfga__originating_offer__c';
                    list<cscfga__Product_Configuration__c> devicePCList = Database.query(soqlQuery);
                    // system.debug('valueofquery'+devicePCList);
                    Integer externalId=1;
                    for(cscfga__Product_Configuration__c pc:devicePCList) {
                        Map<String,Object> newRow = new Map<String,Object>();
                        newRow.put('ExternalId', externalID++);
                        newRow.put('Product_Module_Name', 'T-MDM Professional Services');
                        for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                            // system.debug(snapshotMapping.get(attribute.name)+' : '+attribute.cscfga__Value__c);
                            newRow.put(snapshotMapping.get(attribute.name),attribute.cscfga__Value__c);
                        }
                        rows.add(newRow);
                    }
                }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getMDMProfServices:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getMDMProfServices:Professional Services found:'+rows);
        return rows;
    }
    //EDEG-80783 :End
    //EDGE - 105921 - START - CMP-Committed Offer Quote/Orderform
    public List<Map<String,Object>> getCMPCommittedData(String basketId, Map<String,String> subfilters){
        List<cscfga__Product_Configuration__c> planCMPList = new List<cscfga__Product_Configuration__c>(); 
        List<cscfga__Product_Configuration__c> planCMPCDList = new List<cscfga__Product_Configuration__c>(); //EDGE-146809      
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Map<String, String> map_PlanVsDataAllowance = new Map<String, String>();
        Map<String, String> map_PlanVsBonusAllowance = new Map<String, String>();
        Map<String,CMP_committed_offers__mdt> CMP_committedOffersMap = new Map<String,CMP_committed_offers__mdt>();
        Integer externalId=1;
        Boolean isCommitedTrue = false;//EDGE-144228 Start
        String objectAPIName=''; Id temp;
        try{
            if(subfilters.get('Type') =='New' )
                //filter change               
                /*planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketId AND cscfga__Product_Family__c='Enterprise Mobility' AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];*/ //EDGE-144228 Removed name hardcoding
        planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Basket__c =:basketId AND cscfga__Product_Definition__r.product_Specification__c IN:lstEnterpriseMobilitySpecCode AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];
            //EDGE - 117740 Start
            else if(subfilters.get('Type') =='Modify' )
                planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where name = 'Corporate Mobile Plus-Committed Data' AND cscfga__Product_Basket__c =:basketId AND Type__c='Modify']; 
            else if(subfilters.get('Type') =='Cancel' )
                planCMPList =[SELECT id,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where name = 'Corporate Mobile Plus-Committed Data' AND cscfga__Product_Basket__c =:basketId AND Type__c='Cancel' AND csordtelcoa__Replaced_Product_Configuration__c!=null]; 
            //EDGE - 117740 End
            //EDGE-144228 Start
            for(cscfga__Product_Configuration__c pc1:planCMPList){
                // system.debug('pc1@@::' + pc1.name);
                for(cscfga__Attribute__c attribute:pc1.cscfga__Attributes__r){
                    // system.debug('attribute.name@@::' + attribute.name);
                    // system.debug('attribute.cscfga__Value__c@@::' + attribute.cscfga__Value__c);
                    if(attribute.name == 'OfferTypeString'){
                        // system.debug('attribute.cscfga__Value__c123@@::' + attribute.cscfga__Value__c);
                        if(attribute.cscfga__Value__c == 'Committed Data'){
                            isCommitedTrue = true;
                            planCMPCDList.add(pc1); //EDGE-146809 | Filtering Committed Data PCs
                        }
                    } 
                }
            }
            // system.debug('isCommitedTrue@@::' + isCommitedTrue);
             //EDGE-144228 End
        //EDGE-121387, EDGE-133760 Start 
            if(planCMPCDList.size()==0 || isCommitedTrue == false){//EDGE-144228
                return rows;
            }
            //EDGE-121387, EDGE-133760 End
            List<CMP_committed_offers__mdt> CMP_committedOffersList = [select MasterLabel,Plan_Data__c,Bonus_Data__c,Total_Data__c,Plan_Rate__c,LT_1__c,PAYG_1_to_2__c,PAYG_2_to_3__c,PAYG_3_to_4__c,PAYG_4_to_5__c,PAYG_GT_5__c,Is_Mandatory__c from CMP_committed_offers__mdt];
            if(!CMP_committedOffersList.IsEmpty()){
                for(CMP_committed_offers__mdt cmpMdtRec : CMP_committedOffersList){
                    CMP_committedOffersMap.put(cmpMdtRec.MasterLabel,cmpMdtRec);
                }
            }
            // system.debug('planCMPCDList' + planCMPCDList);
            for(cscfga__Product_Configuration__c pc:planCMPCDList){      
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                    // system.debug('attribute:'+attribute.name);
                    if(isValidId(attribute.cscfga__Value__c)==True){
                        temp = attribute.cscfga__Value__c;
                        objectAPIName = temp.getSObjectType().getDescribe().getName();
                        // system.debug('id found:'+attribute.name+attribute.cscfga__Value__c+objectAPIName);
                        //EDGE-148067 Start | segregating Data & Bonus Allowances
                        if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c') && attribute.Name=='Data Pack Allowance'){
                            // system.debug('Inside Data Allowance'+attribute);
                            map_PlanVsDataAllowance.put(pc.Id,attribute.cscfga__Value__c);
                        }
                        if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c') && attribute.Name=='BonusDataAllowance'){
                            // system.debug('Inside Bonus Allowance'+attribute);
                            map_PlanVsBonusAllowance.put(pc.Id,attribute.cscfga__Value__c);
                        }
                        //EDGE-148067 End                           
             }
                     }
          }
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPCommittedData:map_PlanVsDataAllowance: '+map_PlanVsDataAllowance);
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPCommittedData:map_PlanVsBonusAllowance: '+map_PlanVsBonusAllowance);  
            //EDGE-148067 Start | segregating Data & Bonus Allowances
            Set<String> attrIdList = new Set<String>();
            attrIdList.addAll(map_PlanVsDataAllowance.values());
            // system.debug('Adding Data Allowance attrIdList: '+attrIdList);
            attrIdList.addAll(map_PlanVsBonusAllowance.values());
            // system.debug('Adding Bonus Allowance attrIdList: '+attrIdList);
            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList';            
            Map<id,cspmb__Allowance__c> allowanceRecords = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
            //EDGE-148067 End
            // system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:allowanceRecords: '+allowanceRecords);
            if(planCMPCDList.size()>0){
            for(CMP_committed_offers__mdt CMPrec: CMP_committedOffersList){
                Map<String,Object> newRow1 = new Map<String,Object>();
                    if(CMPrec.Is_Mandatory__c==true)
                    {
                        // system.debug('Inside mdt IF');
                        newRow1.put('ExternalId', externalID++);
                        newRow1.put('Plan_Data',CMPrec.Plan_Data__c);
                        newRow1.put('Plan_Rate',CMPrec.Plan_Rate__c);
                        newRow1.put('Bonus_Data',CMPrec.Bonus_Data__c);
                        newRow1.put('Total_Data',CMPrec.Total_Data__c);
                        newRow1.put('PAYG_LT_1',CMPrec.LT_1__c);
                        newRow1.put('PAYG_1_to_2',CMPrec.PAYG_1_to_2__c);
                        newRow1.put('PAYG_2_to_3',CMPrec.PAYG_2_to_3__c);
                        newRow1.put('PAYG_3_to_4',CMPrec.PAYG_3_to_4__c);
                        newRow1.put('PAYG_4_to_5',CMPrec.PAYG_4_to_5__c);
                        newRow1.put('PAYG_GT_5',CMPrec.PAYG_GT_5__c);
                        newRow1.put('Product_Module_Name','Committed');                     
                        // system.debug('newRow1' + newRow1);
                        rows.add(newRow1);
                    }
            }
            for(cscfga__Product_Configuration__c pc:planCMPCDList){
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('Product_Module_Name','Committed');
                newRow.put('ExternalId', externalID++);
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                    // system.debug('attribute:'+attribute.name);
                    String mappingfield ='';
                    if(!isValidId(attribute.cscfga__Value__c)==True){
                        // system.debug('attribute name:'+attribute.name+' Value: '+attribute.cscfga__Value__c);
                        mappingfield = (attribute.cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c).substringbefore('__c');
                        // system.debug('mappingfield' + mappingfield);  
                        newRow.put(mappingfield,attribute.cscfga__Value__c);
                        if(mappingfield.contains('Plan_Rate')){ 
                            newRow.put('Plan_Rate',attribute.cscfga__Value__c);  
                        }  
                    }
                }
                //EDGE-148067 Start | fetching values from Allowance records instead of Metadata
                cspmb__Allowance__c dataAllowanceRecord = allowanceRecords.get(map_PlanVsDataAllowance.get(pc.Id));
                cspmb__Allowance__c bonusAllowanceRecord = allowanceRecords.get(map_PlanVsBonusAllowance.get(pc.Id)); 
                newRow.put('Unit_Of_Measure',dataAllowanceRecord.Unit_Of_Measure__c);
                newRow.put('Plan_Data',dataAllowanceRecord.Value__c);
                newRow.put('Bonus_Data',bonusAllowanceRecord.Value__c);
                if(CMP_committedOffersMap.ContainsKey(dataAllowanceRecord.Value__c)){
                    if(CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).MasterLabel=='PAYG'){
                        newRow.put('Total_Data','N/A');
                        newRow.put('Plan_Rate','N/A');
                    }
                    else{
                        newRow.put('Total_Data',calculateTotalDataforCommittedPlan(dataAllowanceRecord.Value__c,bonusAllowanceRecord.Value__c));
                        //Reusing Rate__c as static Unit of Measurement
                        newRow.put('Rate','per month per service');
                    }
                    newRow.put('PAYG_LT_1',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).LT_1__c);
                    newRow.put('PAYG_1_to_2',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_1_to_2__c);
                    newRow.put('PAYG_2_to_3',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_2_to_3__c);
                    newRow.put('PAYG_3_to_4',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_3_to_4__c);
                    newRow.put('PAYG_4_to_5',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_4_to_5__c);
                    newRow.put('PAYG_GT_5',CMP_committedOffersMap.get(dataAllowanceRecord.Value__c).PAYG_GT_5__c);
                }
                //EDGE-148067 End
                // system.debug('newRow' + newRow);
                rows.add(newRow);
            }
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getCMPCommittedData:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getCMPCommittedData: Services found:'+rows);
        return rows;
    }
    public static String calculateTotalDataforCommittedPlan(String Plan_Data, String Bonus_Data){
    Integer cmp_plan_data = Integer.valueof(Plan_Data);
    integer cmp_bonus_data = Integer.valueof(Bonus_Data);
    String total_data;
    integer total_value;
    total_value = cmp_plan_data + cmp_bonus_data;
    total_data = String.valueOf(total_value)+' GB';
    system.debug('total_data: '+total_data);
    return total_data;
    }
    //EDGE - 105921 - END - CMP-Committed Offer Quote/Orderform 
  
    
 public List<Map<String,Object>> getTenancyDetails(String basketId, Map<String,String> subfilters){    
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        Integer externalId=1;
        String ProductDefnition=subfilters.get('Product_Module_Name'); //
        try{
            list<cscfga__Attribute__c> atributelist=[Select cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c,Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c from cscfga__Attribute__c where  cscfga__Product_Configuration__r.cscfga__Product_Basket__c=:basketId and cscfga__Product_Configuration__r.cscfga__Product_Definition__r.Name=:ProductDefnition];
        for(cscfga__Attribute__c attr:atributelist){        
                if(attr.Name=='TenancyID'){
                       Map<String,Object> newRow = new Map<String,Object>();  
                         newRow.put('ExternalId', externalID++);
                        newRow.put('TenancyId',attr.cscfga__Value__c); 
                         rows.add(newRow);
                    }
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:MobiltyManagedServceDetails:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:MobiltyManagedServceDetails: Services found:'+rows);
        return rows;
    }

    //EDGE-123788   : Display Delegated Discounts in Quote Document
    //EDGE-123791,EDGE-123792:Delegation discounts to be displayed in the Quote& Order form document(MAC order) 
   public List<Map<String,Object>> getPromotionsApplied(String basketId,Map<String,String> subfilters){
        List<Map<String,Object>> rows = new List<Map<String,Object>>(); 
        Integer externalId=1;
        String objectAPIName='';
        Id temp;
        Decimal sCommittedText=0;
        String sCommittedData = '';
        String sCommittedBonusData = '';
        Set<String> setOfPCIds=new Set<String>();
        Map<String, String> mapOfPlanVsAllowance = new Map<String, String>();
        Map<String,String>  mapOfAddOnAssociationvsPC=new Map<String,String>();
        Map<String,List<String>> mapOfAddonsAssociation = new Map<String,List<String>>();
        List<cscfga__Product_Configuration__c> listOfPlan=new List<cscfga__Product_Configuration__c>();
        try{
    // EDGE-165831 - Filter change
        if(subfilters.get('Type') == 'New'){
            /*listOfPlan=[SELECT id,name,cscfga__Product_Family__c,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,
                        (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                         FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null)
                        FROM cscfga__Product_Configuration__c 
                            where cscfga__Product_Family__c IN:productFamilies
                        AND cscfga__Product_Basket__c =:basketId AND Type__c='New'
                        AND csordtelcoa__Replaced_Product_Configuration__c=null];*/
    listOfPlan=[SELECT id,name,cscfga__Product_Family__c,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,
                        (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                         FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null)
                        FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes AND cscfga__Product_Basket__c =:basketId AND Type__c='New' AND csordtelcoa__Replaced_Product_Configuration__c=null];
        }else if(subfilters.get('Type') =='Modify'){
            //EDGE-123791,EDGE-123792 Start:Delegation discounts to be displayed in the Quote& Order form document(MAC order) 
            /*listOfPlan=[SELECT id,name,cscfga__Product_Family__c,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,
                        (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                         FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null)
                        FROM cscfga__Product_Configuration__c 
                            where cscfga__Product_Family__c IN:productFamilies
                        AND cscfga__Product_Basket__c =:basketId AND Type__c='Modify'
                        AND csordtelcoa__Replaced_Product_Configuration__c!=null ];*/
        // EDGE-165831 - Filter change
        listOfPlan=[SELECT id,name,cscfga__Product_Family__c,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,
                        (SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c 
                         FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null)
                        FROM cscfga__Product_Configuration__c 
                            where cscfga__Product_Definition__r.product_Specification__c IN:productSpecCodes
                        AND cscfga__Product_Basket__c =:basketId AND Type__c='Modify'
                        AND csordtelcoa__Replaced_Product_Configuration__c!=null ];
        // Filter change end 
            //EDGE-123791,EDGE-123792 Start
        }
            // system.debug('listOfPlan'+listOfPlan);
        Map<String,String>  mapOfAddOnvsPC=new Map<String,String>();
        Map<String,List<Discount_Line_Item__c>> mapOfDLIvsDiscount=new Map<String,List<Discount_Line_Item__c>>();
        Map<String,List<Discount_Line_Item__c>> mapOfDLIvsAddOnDiscount=new Map<String,List<Discount_Line_Item__c>>();
        if(listOfPlan!=null && !listOfPlan.isEmpty()){
            for(cscfga__Product_Configuration__c pc:listOfPlan){
                if(pc!=null){
                    setOfPCIds.add(pc.Id);
                    // system.debug('PCId--->'+setOfPCIds);
                    for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r){
                        if(attribute.cscfga__Value__c!=null){
                            if(isValidId(attribute.cscfga__Value__c)==True){
                                temp = attribute.cscfga__Value__c;
                                objectAPIName = temp.getSObjectType().getDescribe().getName();
                                if(pc.name =='Corporate Mobile Plus-Committed Data'){
                                    if(objectAPIName.equalsIgnoreCase('cspmb__Allowance__c')){
                                        mapOfPlanVsAllowance.put(attribute.cscfga__Value__c,attribute.cscfga__Value__c); 
                                    }
                                }
                                if(objectAPIName.equalsIgnoreCase('cspmb__Price_Item_Add_On_Price_Item_Association__c')){
                                    mapOfAddOnAssociationvsPC.put(attribute.cscfga__Value__c,attribute.cscfga__Product_Configuration__c);
                                    if(mapOfAddonsAssociation.get(attribute.cscfga__Value__c) == null){
                                        mapOfAddonsAssociation.put(attribute.cscfga__Value__c,new List<Id>());
                                    }else{
                                        mapOfAddonsAssociation.get(attribute.cscfga__Value__c).add(attribute.id);
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } 
        // system.debug('basketId-->'+basketId);
        //get the DLI based on basketId related to CLI & Product Config.
        List<Discount_Line_Item__c> lstOfDLI1=[Select Id,chargeInstance__c,BusinessID__c,discountValue__c,duration__c,Status__c,
                                               chargeInstance__r.Product_Configuration__c,chargeInstance__r.Product_Configuration__r.Id,
                                               chargeInstance__r.Product_Configuration__r.Name,chargeInstance__r.targetChargeProduct__c
                                               From Discount_Line_Item__c Where chargeInstance__r.basketId__c=:basketId And chargeInstance__r.Product_Configuration__c IN:setOfPCIds];
        // system.debug('lstOfDLI1-->'+lstOfDLI1);
        if(lstOfDLI1!=null && !lstOfDLI1.isEmpty()){
            for(Discount_Line_Item__c dli:lstOfDLI1){
                if(dli.chargeInstance__c!=null && dli.chargeInstance__r.Product_Configuration__c!=null){
                    if(dli.chargeInstance__r.targetChargeProduct__c=='Plan'){
                        if(!mapOfDLIvsDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                            mapOfDLIvsDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                        }else{
                            mapOfDLIvsDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                        }
                    }else if(dli.chargeInstance__r.targetChargeProduct__c=='AddOn'){
                        if(!mapOfDLIvsAddOnDiscount.containsKey(dli.chargeInstance__r.Product_Configuration__c)){
                            mapOfDLIvsAddOnDiscount.put(dli.chargeInstance__r.Product_Configuration__c,new List<Discount_Line_Item__c>{dli});
                        }else{
                            mapOfDLIvsAddOnDiscount.get(dli.chargeInstance__r.Product_Configuration__c).add(dli);
                        }
                    }
                }
            }
        }
        List<String> attrIdList =new List<String>(mapOfAddonsAssociation.keySet());
        String soqlAddOnn = ' SELECT cspmb__Add_On_Price_Item__r.Billing_Description__c,cspmb__Add_On_Price_Item__r.Name, ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Price_Item_Add_On_Price_Item_Association__c')) + ' ,cspmb__Add_On_Price_Item__r.Unit_Of_Measure__c' +
            ' FROM cspmb__Price_Item_Add_On_Price_Item_Association__c WHERE id IN :attrIdList';               
        Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c> Add_On_Price_Item_Association_Records = new Map<id,cspmb__Price_Item_Add_On_Price_Item_Association__c>((List<cspmb__Price_Item_Add_On_Price_Item_Association__c>)Database.query(soqlAddOnn));
        // system.debug('Add_On_Price_Item_Association_Records-->>>'+Add_On_Price_Item_Association_Records);
        Map<String,Promotion_Applied__mdt> mapOfPramotionAppliedVsHelpText=new Map<String,Promotion_Applied__mdt>();
            //EDGE-121387, EDGE-133760
            List<Promotion_Applied__mdt> lstOfPAmdt=[Select Id,DiscountTemplate_Text__c,MasterLabel,Discount_Name__c,Discount_Template_Text__c,Discount_Template_Name__c
                                                 From Promotion_Applied__mdt];
        if(lstOfPAmdt.size()>0){
            for(Promotion_Applied__mdt pamdt:lstOfPAmdt){
                mapOfPramotionAppliedVsHelpText.put(pamdt.MasterLabel,pamdt);
            }
        }
        Map<String,String> mapOfDLIvsPCIds=new Map<String,String>();
        Map<String,Discount_Line_Item__c> mapOfDLI=new Map<String,Discount_Line_Item__c>();
        List<Discount_Line_Item__c> lstOfDLI=[Select Id,Name,chargeInstance__c,chargeInstance__r.basketId__c,
                                              BusinessID__c,discountValue__c,duration__c,Status__c,chargeInstance__r.Product_Configuration__c
                                              From Discount_Line_Item__c 
                                              Where chargeInstance__r.basketId__c=:basketId And chargeInstance__r.Product_Configuration__c IN:setOfPCIds];
        // system.debug('lstOfDLI--?'+lstOfDLI);
        if(lstOfDLI.size()>0){
            for(Discount_Line_Item__c dli:lstOfDLI){
                if(dli.BusinessID__c!=null){
                    mapOfDLI.put(dli.Name,dli);
                }
            }
        }
            // system.debug('lstOfDLI'+lstOfDLI);
            // system.debug('mapOfDLI'+mapOfDLI);
        if(mapOfDLI!=null){
            for(String str:mapOfDLI.keyset()){
                Map<String,Object> row = new Map<String,Object>(); 
                Discount_Line_Item__c DLI=mapOfDLI.get(str);
                if(DLI!=null && mapOfPramotionAppliedVsHelpText!=null && mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c)!=null){
                    if(DLI.BusinessID__c!='DMCAT_Discount_000957'){
                        String DiscountTemplateName=String.valueOf(mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c).Discount_Template_Name__c);
                            //EDGE-121387, EDGE-133760 Start
                            String HelpText='';//String.valueOf(mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c).Discount_Template_Text__c);
                            if(mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c).Discount_Template_Text__c!='NA'){
                                HelpText=String.valueOf(mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c).Discount_Template_Text__c);
                            }else{
                                HelpText=String.valueOf(mapOfPramotionAppliedVsHelpText.get(DLI.BusinessID__c).DiscountTemplate_Text__c);
                            }
                            //EDGE-121387, EDGE-133760 End
                        String appliedPromotion='';
                        if(HelpText.contains('$$$$')){
                            appliedPromotion=HelpText.replace('$$$$', '');
                        }else{
                            appliedPromotion=HelpText;
                        }
                        row.put('ExternalId', externalID++);
                        row.put('Discount_Template_Name',DiscountTemplateName);
                        row.put('Discount_Text',appliedPromotion);
                        rows.add(row);
                    }
                }
            }
        }
        if(mapOfAddonsAssociation!=null){
            for(String str:mapOfAddonsAssociation.keyset()){
                cspmb__Price_Item_Add_On_Price_Item_Association__c addOnPI=Add_On_Price_Item_Association_Records.get(str);
                if(addOnPI!=null &&( addOnPI.AddOn_Name__c=='Basic' || addOnPI.AddOn_Name__c=='Premium')){
                    String PCId=mapOfAddOnAssociationvsPC.get(str);
                    if(pCId!=null){
                        List<Discount_Line_Item__c> lstOfAddOnDiscount=mapOfDLIvsAddOnDiscount.get(pCId); 
                        if(lstOfAddOnDiscount!=null && !lstOfAddOnDiscount.isEmpty()){
                            for(Discount_Line_Item__c dli:lstOfAddOnDiscount){
                                Map<String,Object> addOnBC = new Map<String,Object>(); 
                                String DiscountText=mapOfPramotionAppliedVsHelpText.get(dli.BusinessID__c).Discount_Template_Text__c;
                                String DiscountTemplateName=String.valueOf(mapOfPramotionAppliedVsHelpText.get(dli.BusinessID__c).Discount_Template_Name__c);
                                String DiscountApplied='';
                                if(DiscountText.contains('####')){
                                    DiscountApplied=DiscountText.replace('####',addOnPI.AddOn_Name__c);
                                }
                                addOnBC.put('ExternalId', externalID++);
                                addOnBC.put('Discount_Template_Name',DiscountTemplateName);
                                addOnBC.put('Discount_Text',DiscountApplied);
                                rows.add(addOnBC);
                            }
                        }
                    }
                }
            }
        }
        if(mapOfPlanVsAllowance!=null && !mapOfPlanVsAllowance.isEmpty()){
            List<String> attrIdList1 = new List<String>(mapOfPlanVsAllowance.keySet());
            String query = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cspmb__Allowance__c')) + ' ' +
                ' FROM cspmb__Allowance__c WHERE id IN :attrIdList1';            
            Map<id,cspmb__Allowance__c> allowanceRecords1 = new Map<id,cspmb__Allowance__c>((List<cspmb__Allowance__c>)Database.query(query));
            if(allowanceRecords1!=null){
                Map<String,Object> bonusDatarow = new Map<String,Object>(); 
                for(String id: mapOfPlanVsAllowance.keySet()){
                    if(id!=null){
                        cspmb__Allowance__c allowance1 = allowanceRecords1.get(id);
                        if(allowance1.type__c == 'Committed Data'){
                            sCommittedData = allowance1.Value__c;
                        }
                        if(allowance1.type__c == 'Committed Bonus Data'){
                            sCommittedBonusData = allowance1.Value__c;
                        }
                    }
                }
                sCommittedText = Decimal.valueOf(sCommittedData) + Decimal.valueOf(sCommittedBonusData);
                String bonusDataText= 'Your Committed Data Plan includes '+sCommittedBonusData+'Gb bonus data for use in Australia (total '+sCommittedText+'Gb per month per service).'+
                    '[Note: this promotion has eligibility rules applied through CPQ and changes plan inclusions & line item in table above, but does not affect the price]';
                bonusDatarow.put('ExternalId', externalID++);
                bonusDatarow.put('Discount_Template_Name','Bonus Data Offer');
                bonusDatarow.put('Discount_Text',bonusDataText);
                rows.add(bonusDatarow);
            }
        }
        }catch(Exception e){
             system.debug('***Telstra:ProductBasketDataHandler:getCMPServices:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
         system.debug('rows'+rows);
        return rows;
    }
    //EDGE-123788 & EDGE-123789 end
    //Added below function for EDGE-127817. Below function is invoked from function getngUCCancel to calculate remaining terms of the contract.
    public static Integer calculateRemainingTermngUC(Date initialActivationDate,Date disconnectionDate,Integer contractTerm,BillingAccountDetailsDTO billAccDTO){
        Integer remainingTerm;
        Decimal deviceCancelAmount = 0.00; 
        Decimal planCancelAmount = 0.00;
        Date firstBillDate,lastBillDate;
        //BillingAccountDetailsDTO billAccDTO = null;
        Map<String,String> results = new Map<String,String>();
        // system.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:initialActivationDate'+initialActivationDate+',disconnectionDate:'+disconnectionDate+',contractTerm:'+contractTerm);
        try{ 
            //billAccDTO = BillingOrderService.requestBillingAccountDetails(billingAccNum);
            // system.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:billAccDTO:'+billAccDTO);
            if(billAccDTO != null && billAccDTO.BillingAccount != null && billAccDTO.status == IntegrationRecordHandlerUtil.HTTP_SUCCESS){
                String dayValue = billAccDTO.BillingAccount.startDate;
                Integer billCycleDay = billAccDTO.BillingAccount.billCycleDay;
                // Date on which first bill will be generated in BDS
                firstBillDate =  Date.newInstance(initialActivationDate.year(), initialActivationDate.month(), Integer.valueOf(billCycleDay));
                if(initialActivationDate >= firstBillDate)  
                    firstBillDate = firstBillDate.addMonths(1);             
                // system.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:firstBillDate:'+firstBillDate);
                //Date on which latest bill was generated
                lastBillDate =  Date.newInstance(disconnectionDate.year(), disconnectionDate.month(), Integer.valueOf(billCycleDay));
                if(disconnectionDate < lastBillDate)
                lastBillDate = lastBillDate.addMonths(-1);            
                // system.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:lastBillDate:'+lastBillDate);
                // Evaluate if bill was generated for month from which disconnectionDate is selected
                /*Boolean billGenerated_DisconnectionMonth = false;
                if((disconnectionDate.month() == lastBillDate.month()) && (disconnectionDate.day() >= lastBillDate.day())){
                    billGenerated_DisconnectionMonth = true;
                }*/
                Integer TermPassed = firstBillDate.monthsBetween(lastBillDate)+1; //Added one to include the firstBillMonth
                //// system.debug('TermPassed-->'+TermPassed);
                if(TermPassed<0)
                    TermPassed = 0;
                remainingTerm = contractTerm - TermPassed;
                }
                return remainingTerm;
        }
            catch(Exception e){
            System.debug('***Telstra:EarlyCancellationCalcService:CancelChargesCalc:BillingAccount-Response:'+billAccDTO);
            return remainingTerm;
            }
        }
// EDGE-127817 End       
    //EDGE-98336 - Start
    public List<Map<String,Object> > getTIDDetails(String basketId,Map<String,String> subfilters){
        Integer externalId=1;
        List<Map<String,Object> > rows = new List<Map<String,Object> >();
        List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
        Map<String,String> snapshotMapping = new Map<String,String> {'Site Name'=>'Site_Name','Site Address'=>'Site_Address','ServiceabilityLocation'=>'Serviceability_Location','ResponseTime'=>'Response_time','RestorationTime'=>'Restoration_time','SelectZone'=>'PAYG_1_to_2','AccessConfigString'=>'PAYG_2_to_3','Bandwidth Shadow'=>'PAYG_3_to_4','RecurringPrice'=>'GSTExcl_Total_Recurring_Charges'};
        Set<String> attributeList= snapshotMapping.keySet();
        try{
    // EDGE-165831 - Filter change
            if(subfilters.get('Type') =='New' ){
            pcList=[SELECT id,name,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and csordtelcoa__Replaced_Product_Configuration__c =null];
            // system.debug('valueofquery'+pcList);
            }
            //EDGE-127778 - Added MAC Scenario - Start
            else if(subfilters.get('Type') =='Modify' ){
            pcList=[SELECT id,name,Type__c,(SELECT Id, Name,cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c,cscfga__Is_Line_Item__c, cscfga__Line_Item_Sequence__c FROM cscfga__Attributes__r where Name in :attributeList) FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c=:basketId and cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode and Type__c='Modify'];
            // system.debug('valueofquery'+pcList);
            }
            //EDGE-127778 - End
            for(cscfga__Product_Configuration__c pc:pcList) {
                Map<String,Object> newRow = new Map<String,Object>();
                newRow.put('ExternalId', externalID++);
                newRow.put('Product_Module_Name', 'Internet Direct');
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r) {
                    // system.debug(snapshotMapping.get(attribute.name)+' : '+attribute.cscfga__Value__c);
                    newRow.put(snapshotMapping.get(attribute.name),attribute.cscfga__Value__c);
                    if(attribute.name=='RecurringPrice'){
                        Decimal strToDec = decimal.valueOf(attribute.cscfga__Value__c);
                        newRow.put('GSTIncl_Total_Recurring_Charges',calculateGSTIncludedPrice(strToDec));
                    }
                 }
                 rows.add(newRow);
             }
             // system.debug('rows:'+rows);
        }
        catch(Exception e){
            System.debug('***Telstra:ProductBasketDataHandler:getTIDDetails:exception:'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getTIDDetails:'+rows);
        return rows;
    }
    //EDGE-98336 - End 
// Wrapper for Managing sorting for Price Items based on Range
public class sortPriceItem implements Comparable {       
        public integer Range_From {get;set;}
        public integer Range_To {get;set;}       
        public String Feature_Level{get;set;}
        public String Techinical_Support{get;set;}
        public Decimal Rate{get;set;}
        public String Unit_Of_Measure{get;set;}     
         public Integer compareTo(Object compareTo) {
            sortPriceItem sortPriceItem = (sortPriceItem) compareTo;
            if (this.Range_From > sortPriceItem.Range_From) return 1;
            if (this.Range_From < sortPriceItem.Range_From) return -1;
                  return 0;
        }
    }
//EDGE-127780 Start
public List<Map<String,Object> > getTIDCancel(String basketId, Map<String,String> subfilters){ 
List<Map<String,Object>> rows = new List<Map<String,Object>>();
    Map<String,List<cscfga__Product_Configuration__c>> map_DeviceModelvsPC = new Map<String,List<cscfga__Product_Configuration__c>>();
    List<cscfga__Product_Configuration__c> sitePCList = new List<cscfga__Product_Configuration__c>();
    Integer externalId = 1;
        //if(subfilters.get('Type') =='Cancel'){
        // system.debug('------- Inside IF subfilters.get(Type) ==Cancel ------- ');
     try{   
        //EDGE-165831 - Filter Change 
        sitePCList =[SELECT id,Type__c,Site_Name__c,Site_Address__c,name,cscfga__Contract_Term__c,cscfga__Quantity__c,cscfga__Parent_Configuration__c,csordtelcoa__Replaced_Subscription__r.Right_to_Bill_Date__c,csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c,cscfga__unit_recurring_charge__c,cscfga__total_recurring_charge__c,cscfga__Recurring_Charge__c,(SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c, cscfga__Attribute_Definition__r.cscfga__Type__c FROM cscfga__Attributes__r where cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c!=null) FROM cscfga__Product_Configuration__c where cscfga__Product_Definition__r.product_Specification__c IN:lstInternetSiteSpecCode AND cscfga__Product_Basket__c =:basketId AND Type__c='Cancel'];
        //}
        // system.debug('------- TID sitePCList ------- ' + sitePCList);
        for(cscfga__Product_Configuration__c pc:sitePCList)
        {
            // system.debug('------- TID inside for ------- ');
            Map<String,String> cancelrow = new Map<String,String>();
            if(pc.Type__c == 'Cancel')
            {
                if(map_DeviceModelvsPC.get(pc.Name) == null)
                {
                    map_DeviceModelvsPC.put(pc.Name,new List<cscfga__Product_Configuration__c>());          
                }
                map_DeviceModelvsPC.get(pc.Name).add(pc);
                for(cscfga__Attribute__c attribute:pc.cscfga__Attributes__r)
                {
                    // system.debug('-------TID inside Attribute for loop ------- ');
                    if(attribute.name=='EarlyTerminationCharge')
                    {
                        cancelrow.put('GSTExcl_TotalETC',string.valueOf(attribute.cscfga__Value__c));
                        cancelrow.put('GSTIncl_TotalETC',string.valueOf(calculateGSTIncludedPrice(decimal.valueof(attribute.cscfga__Value__c))));
                        //cancelrow.put('GSTIncl_TotalETC',calculateGSTIncludedPrice(Decimal.valueOf(attribute.cscfga__Value__c)));
                    }
                    if(attribute.name=='DisconnectionDate')
                    {
                        cancelrow.put('Total_Data',string.valueOf(attribute.cscfga__Value__c));//same field used - chk if value will be overwritten
                    }
                    if(attribute.name=='Contract Term')
                     {// system.debug('attribute.cscfga__Value__c@@::' + attribute.cscfga__Value__c);
                        cancelrow.put('Term',string.valueOf(attribute.cscfga__Value__c));
                   }
                }
                cancelrow.put('Service_Start_Date',string.valueOf(pc.csordtelcoa__Replaced_Service__r.Initial_Activation_Date__c));
                //cancelrow.put('Term',string.valueOf(pc.cscfga__Contract_Term__c));
                cancelrow.put('ExternalId', String.valueOf(externalId));
                cancelrow.put('Site_Name', pc.Site_Name__c);
                cancelrow.put('Site_Address', pc.Site_Address__c);
                // system.debug('------- Before Rows.add(cancelrow) ------- ' + cancelrow);
                rows.add(cancelrow);
                externalId++;
            }                
        }
        // system.debug('------- Rows.add(cancelrow) ------- ' + rows);
    }
    catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getTIDCancel::'+e.getLineNumber()+' '+e.getMessage());
        }
        System.debug('***Telstra:ProductBasketDataHandler:getTIDCancel:'+rows);
        return rows;
}
    //EDGE-127780 End
    //EDGE-123788 start
    public List<String> getDiscountApplied(String pCId,Map<String,List<Discount_Line_Item__c>> mapOfDiscounts){
        List<String> listOfDiscountText=new List<String>();
        Map<String,String> mapOfBuisnessIdVsHelpText=new Map<String,String>();
        List<MobilePlanDiscount__mdt> lstOfMobilePlanDis=[Select Id,MasterLabel,Discount_Name__c, Discount_Template_Text__c,Discount_Type__c From MobilePlanDiscount__mdt];
        if(lstOfMobilePlanDis!=null && !lstOfMobilePlanDis.isEmpty()){
            for(MobilePlanDiscount__mdt mpd:lstOfMobilePlanDis){
                mapOfBuisnessIdVsHelpText.put(mpd.MasterLabel,mpd.Discount_Template_Text__c);
            }
        }
        if(mapOfDiscounts!=null && !mapOfDiscounts.isEmpty()){
            List<Discount_Line_Item__c> lstOfDiscounts=mapOfDiscounts.get(pCId); 
            // system.debug('###########---lstOfDiscounts>'+lstOfDiscounts);
            if(lstOfDiscounts!=null && !lstOfDiscounts.isEmpty()){
                for(Discount_Line_Item__c dli:lstOfDiscounts){
                    // system.debug('###########---DLI-->'+dli);
                    if(dli!=null && mapOfBuisnessIdVsHelpText!=null){
                    String DiscountText=mapOfBuisnessIdVsHelpText.get(dli.BusinessID__c);
                    String DiscountApplied='';
                    if(DiscountText!=null && DiscountText.contains('####')){
                        if(dli.discountValue__c!=null){
                            DiscountApplied=DiscountText.replace('####',dli.discountValue__c);
                            if(dli.duration__c!=null){
                                DiscountApplied=DiscountApplied.replace('@@@',dli.duration__c);
                            }
                        }
                    }else{
                        DiscountApplied=DiscountText;
                    }
                    listOfDiscountText.add(DiscountApplied);
                }
                }
            }
        }
        return listOfDiscountText;
    }
    

    /*
    * Description: Method to get list price From Product Configuration using discount value (Strategic solution). 
    * EDGE-140501,EDGE-142033
    * Team: Napier
    * Developer: Tejes Mahajan
    */
    public static Map<String,Double> getListPriceUsingDiscount(String basketId,List<cscfga__Product_Configuration__c> pcList){ 
        Map<String,Double> mapOfPCListPriceRC=new Map<String,Double>();
        for(cscfga__Product_Configuration__c pc:pcList){
            if(pc.Offername__c!=null && pc.cscfga__Parent_Configuration__c == null){

                //EDGE-176688 - Start
                Decimal rcCharge = ProductPricingHandler.amDeviceHROCheck(pc);
                mapOfPCListPriceRC.put(pc.Id,pc.cscfga__recurring_charge_line_discount_value__c+rcCharge+pc.cscfga__recurring_charge_product_discount_value__c); //EDGE-187507 added cscfga__recurring_charge_product_discount_value__c
                //EDGE-176688 - End

            }           
        }
        return mapOfPCListPriceRC;
    }
    //EDGE-140501,EDGE-142033 Ends
    //EDGE-165834 - getSummaryforTotalCharges Start
    public List<Map<String,Object>> getSummaryForNewCharges(String basketId){
    List<Map<String,Object>> rows = new List<Map<String,Object>>();
    List<cscfga__Product_Configuration__c> pcList = new List<cscfga__Product_Configuration__c>();
    String paymentTypeStringAttr = 'PaymentTypeString';     //EDGE-176688
    String oneOffPaymentTypeValue = 'Purchase';     //EDGE-176688
    Map<Id,Decimal> map_PCVSGSTInc;

    try{
        Integer externalID=1;
        Map<String,Object> row = new Map<String,Object>();
        pcList = [SELECT ID , Name,cscfga__Product_Basket__r.name,type__c, cscfga__One_Off_Charge__c,
                  cscfga__total_recurring_charge__c, cscfga__Parent_Configuration__c, subType__c,
                  cscfga__total_one_off_charge__c,cscfga__Product_Definition__r.product_Specification__c,
                  (SELECT Id, Name, cscfga__Display_Value__c, cscfga__Value__c, cscfga__Attribute_Definition__r.Snapshot_Attribute_Value_Field__c, 
                   cscfga__Attribute_Definition__r.Snapshot_Attribute_Fields__c from cscfga__Attributes__r)
                  from cscfga__Product_Configuration__c where cscfga__Product_Basket__c= :basketId 
                  AND subType__c !='Inflight Amend' AND Type__c!='Active' AND Type__c!='PaidOut' ]; //EDGE-176688 | Added ProdSpec,oneoff fields //EDGE-200765 Added cscfga__Product_Basket__r.name field and !=Active condition //EDGE-200765 Added !=PaidOut condition
        system.debug('pcList' + pcList);
        Decimal total_one_off_charge =0.00;
        Decimal total_recurring_charge = 0.00;
        Decimal total_ETC_charge = 0.00;
        Decimal rcCharge = 0.00; 
        Decimal total_recurring_charge_incGST = 0.00;
        Double sumOfNoFaultRedemption = 0.00;
        String paymentType = '';//EDGE-204960 
        //EDGE-186680
        map_PCVSGSTInc = getGSTIncPriceforPC(basketId,false); 
       // Set<String> offers = getOffersInBasket(basketId);
        for(cscfga__Product_Configuration__c prodSpec:pcList){
            //EDGE-176688 - Start ,EDGE-191284 added for AM 
            if(prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare)){
               system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewCharges2:Inside AM Device:'+prodSpec.cscfga__One_Off_Charge__c +''+prodSpec.cscfga__Product_Definition__r.product_Specification__c+'=='+ngemDeviceProdSpecId);
                   
                if(prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceProdSpecId) || prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(AMDeviceProdSpecId)){
                    for(cscfga__Attribute__c attribute:prodSpec.cscfga__Attributes__r) {
                            if(attribute.Name == paymentTypeStringAttr){
                                paymentType = attribute.cscfga__Value__c;
                            } 
                        }
    
                        for(cscfga__Attribute__c attribute:prodSpec.cscfga__Attributes__r) {
                            if(attribute.Name.equals(paymentTypeStringAttr) && attribute.cscfga__Value__c.equals(oneOffPaymentTypeValue) && (prodSpec.subType__c == null || prodSpec.subType__c != 'No Fault Return')){
                                
                                total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;
                                system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewCharges:Inside AM Device:'+prodSpec.cscfga__One_Off_Charge__c);
                                
                            }
                            //EDGE-204960 Start 
                            else if(paymentType != oneOffPaymentTypeValue && attribute.Name.equals('RC') && prodSpec.subType__c == 'No Fault Return' 
                                    && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''){
                                        
                                        Decimal charges = decimal.valueOf(attribute.cscfga__Value__c) * (-1);
                                        System.debug('charges == '+charges +' prodSpec id == '+prodSpec.Id);
                                        
                                        total_one_off_charge += charges;
                                        
                                        System.debug('total_one_off_charge in HRO  == '+total_one_off_charge+ '');
                                    }
                            else if(paymentType == oneOffPaymentTypeValue && attribute.Name.equals('OC') && prodSpec.subType__c == 'No Fault Return' 
                                    && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''){
                                        
                                        Decimal charges = decimal.valueOf(attribute.cscfga__Value__c) * (-1);
                                        System.debug('charges == '+charges +' prodSpec id == '+prodSpec.Id);
                                        
                                        total_one_off_charge += charges;
                                        
                                        System.debug('total_one_off_charge in Purchase  == '+total_one_off_charge+ '');
                                    }
                            if(paymentType == oneOffPaymentTypeValue && attribute.Name.equals('RedeemFundCopy') && prodSpec.subType__c == 'No Fault Return' 
                                    && attribute.cscfga__Value__c != null && attribute.cscfga__Value__c != ''){
                                         
                                        Decimal charges = decimal.valueOf(attribute.cscfga__Value__c);
                                        System.debug('charges == '+charges +' prodSpec id == '+prodSpec.Id);
                                        
                                        total_one_off_charge += charges;
                                        
                                        System.debug('total_one_off_charge in Purchase  == '+total_one_off_charge+ '');
                                    }
                            
                            //EDGE-204960 End
                            
                            
                        }
                        if(prodSpec.subType__c != 'No Fault Return'){
                        if(map_PCVSGSTInc.containsKey(prodSpec.id)){
                            total_recurring_charge_incGST+=map_PCVSGSTInc.get(prodSpec.id);
                            System.debug('searching for 2');
                        }
                        else{
    
    
                            rcCharge = ProductPricingHandler.amDeviceHROCheck(prodSpec);
                            total_recurring_charge_incGST+=calculateGSTIncludedPrice(rcCharge);
                        }
                        total_recurring_charge += rcCharge;

                    }
                }
                else if(prodSpec.cscfga__Product_Definition__r.product_Specification__c.equalsIgnoreCase(ngemDeviceCare)){
                    //EDGE-200765 Start
                    if(System.Label.excludeAppleCareCancel == 'false')
          total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;
          else{
            if(prodSpec.type__c!='Cancel'){
            total_one_off_charge += prodSpec.cscfga__One_Off_Charge__c;
            }
          }
                    //EDGE-200765 End
            
                    // system.debug('***Telstra:ProductBasketDataHandler:getSummaryForNewCharges:Inside AM Device Care:'+prodSpec.cscfga__One_Off_Charge__c);
                }
            }
            //EDGE-176688 - End
            else if(prodSpec.cscfga__Parent_Configuration__c==null){
                //Added if loop as a part of DIGI-3050
                if(prodSpec.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_DEVICE_SPECID || prodSpec.cscfga__Product_Definition__r.product_Specification__c==DataHandlerConstants.UNIFIED_COMMUNICATION_ACCESSORY_SPECID)
                total_one_off_charge += prodSpec.cscfga__total_one_off_charge__c*prodSpec.cscfga__Quantity__c;
                else                
                total_one_off_charge += prodSpec.cscfga__total_one_off_charge__c;
                //EDGE-186680 - start
                if(map_PCVSGSTInc.containsKey(prodSpec.id)){
                       total_recurring_charge_incGST+=map_PCVSGSTInc.get(prodSpec.id);
                }
                else{
                    total_recurring_charge_incGST+=calculateGSTIncludedPrice(prodSpec.cscfga__total_recurring_charge__c);
                }
                //EDGE-186680 - end 

                total_recurring_charge += prodSpec.cscfga__total_recurring_charge__c;
            }
            for(cscfga__Attribute__c attr:prodSpec.cscfga__Attributes__r ){
                if(prodSpec.cscfga__Parent_Configuration__c==null){// added if condition for defect 188062
                if(attr.name.equals('EarlyTerminationCharge') && attr.cscfga__Value__c != '0.00' && string.isNotEmpty(attr.cscfga__Value__c)){//EDGE 188062 - added condition for new charges table as well
                    total_ETC_charge = total_ETC_charge + decimal.valueof(attr.cscfga__Value__c);
                }
            }
        }
        }
        sumOfNoFaultRedemption = 0 - sumOfNoFaultRedemption;
    //EDGE-200765 Start
        if(!pcList.isEmpty()){
            String basketName = pcList[0].cscfga__Product_Basket__r.name;
            Double sumOfBasketRedemption=0;
            sumOfBasketRedemption = BasketRedemptionHelper.getBasket(basketName);
            system.debug('basketName@@::' + basketName + '::sumOfBasketRedemption::' + sumOfBasketRedemption);
            total_one_off_charge = total_one_off_charge - sumOfBasketRedemption;
        }//EDGE-200765 End
        row.put('ExternalId', String.valueOf(externalID));
        if(total_ETC_charge > 0){
            row.put('GSTExcl_Total_Onceoff_Charges',total_one_off_charge+total_ETC_charge);
            row.put('GSTIncl_Total_Onceoff_Charges',calculateGSTIncludedPrice(total_one_off_charge+total_ETC_charge));
        }else{
            row.put('GSTExcl_Total_Onceoff_Charges',total_one_off_charge);
            row.put('GSTIncl_Total_Onceoff_Charges',calculateGSTIncludedPrice(total_one_off_charge));
        }        
        row.put('GSTExcl_Total_Recurring_Charges',total_recurring_charge);

        row.put('GSTIncl_Total_Recurring_Charges',total_recurring_charge_incGST);
        //EDGE-171311 - Start
        if((decimal)(row.get('GSTExcl_Total_Onceoff_Charges')) < 0)
            row.put('GSTExcl_Total_Onceoff_Charges','('+(decimal)(row.get('GSTExcl_Total_Onceoff_Charges'))*-1+')');
        if((decimal)(row.get('GSTIncl_Total_Onceoff_Charges')) < 0)
            row.put('GSTIncl_Total_Onceoff_Charges','('+(decimal)(row.get('GSTIncl_Total_Onceoff_Charges'))*-1+')');
        if((decimal)(row.get('GSTExcl_Total_Recurring_Charges')) < 0)
            row.put('GSTExcl_Total_Recurring_Charges','('+(decimal)(row.get('GSTExcl_Total_Recurring_Charges'))*-1+')');
        if((decimal)(row.get('GSTIncl_Total_Recurring_Charges')) < 0)
            row.put('GSTIncl_Total_Recurring_Charges','('+(decimal)(row.get('GSTIncl_Total_Recurring_Charges'))*-1+')');
        //EDGE-171311 - End
        // Aruna - DIGI-1597 - Configure plans/ allowances for shared data plan variants (DPG-5395)
     /*   for(String offer:offers){
            if(offer != null && offer == Label.IoTOfferName){
                row.put('Total_Recurring_Charges','Not Applicable');
                row.put('GSTIncl_Total_Recurring_Charges','Not Applicable');
            }  
        } */
        rows.add(row);
    }
    catch(Exception e){
        System.debug('e:'+e.getMessage()+' :'+e.getLineNumber());
    }
    system.debug('rows@@::last' + rows);
    return rows;
    }
    //EDGE-165834 -end




    //EDGE-175105 - Start
    public List<Map<String,Object> > getMobilityTransitionHardwareAndDevice(String basketId, Map<String,String> subfilters){ 
        map<string,Decimal> newmap = new map<string,Decimal>();
        Integer externalId = 1;
        list<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{
            List<Service_Add_On__c> myRecs = [select Device_Description__c, Monthly_Amount__c,
                                              Residual_Remaining_Term__c from Service_Add_On__c where Legacy_Service__r.Select__c = TRUE  AND Legacy_Service__r.Product_Basket__c =:basketId AND Legacy_Service__r.Product_Type__c = 'Enterprise Mobility'];
            Map<string, Service_Add_On__c> serviceMap = new Map<string, Service_Add_On__c>();
            if(myRecs != null && myRecs.size()>0){
                for(Service_Add_On__c serAdd :myRecs){
                    serviceMap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c ,serAdd);
                }
                
                for(Service_Add_On__c serAdd :myRecs){
                    if(newmap.containsKey(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c)){
                        Decimal d = newmap.get(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c);
                        d=d+1;
                        newmap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c,d); 
                    }else
                    {
                        newmap.put(serAdd.Device_Description__c +','+ serAdd.Monthly_Amount__c +','+ serAdd.Residual_Remaining_Term__c,1);
                    }
                }
                for (String key : newmap.keySet()) {
                    Map<String,Object> newRow = new Map<String,Object>();
                    decimal Quantity = newmap.get(key); 
                    Integer QuantityIntVal = Quantity != 0 ? Integer.valueOf( Quantity ) : 1;
                    String[] res = key.split(',');
                    decimal Monthly_amountCal = res[1] != null ? decimal.valueOf( res[1] ) : 1;
                    decimal Remaining_MonthsCal = res[2] != null ? decimal.valueOf( res[2] ) : 1;
                    decimal remainingTotalAMT = Remaining_MonthsCal * Monthly_amountCal * QuantityIntVal;
                    newRow.put('Existing_Service',res[0]);
                    newRow.put('ExternalId',externalId++);
                    newRow.put('Recurring_Charges',res[1]);
                    newRow.put('Quantity',Quantity);
                    newRow.put('Total_Contract_Value',res[2]);
                    newRow.put('Total_Once_Off',remainingTotalAMT);
                    rows.add(newRow);
                    system.debug(rows+'&&&&&&&&&&&&&&&');
                }
            }
        }
        catch(Exception e)
        {
            System.debug('***Telstra:ProductBasketDataHandler:getTIDCancel::'+e.getLineNumber()+' '+e.getMessage());
        }
        system.debug(rows+'@@@@@@@@@@@@@@@@');
        return rows;
    }
    //EDGE-173365 - getBSMobilityTransition Start
    public List<Map<String,Object>> getBSMobilityTransition(String basketId){
        List<Map<String,Object>> rows = new List<Map<String,Object>>();
        try{
            Integer externalID=1;
            Integer intg;
            Map<String,Integer> mpPlan = new Map<String,Integer>();
            Map<String,Object> row ;
            List<Legacy_Service__c> lstLegacySrvcLst = [SELECT Id, Plan_Name__c FROM Legacy_Service__c WHERE Product_Basket__c = :basketId AND Product_Type__c = 'Enterprise Mobility' AND Select__c = TRUE];
            if(lstLegacySrvcLst != null && lstLegacySrvcLst.size()>0){
                for(Legacy_Service__c ls:lstLegacySrvcLst){
                    if(mpPlan.containsKey(ls.Plan_Name__c)){
                        intg = mpPlan.get(ls.Plan_Name__c)+1;
                        mpPlan.put(ls.Plan_Name__c, intg);
                    }
                    else{
                        mpPlan.put(ls.Plan_Name__c, 1);
                    }
                }
                for(string s:mpPlan.KeySet()){
                    row = new Map<String,Object>(); row.put('ExternalId', String.valueOf(externalID)); row.put('Plan_Data', s);  row.put('Quantity',String.valueOf(mpPlan.get(s))); rows.add(row);
                    externalId ++;
                }
            }
        }
        catch(Exception e){
            System.debug('getBSMobilityTransition error:'+e.getMessage()+' :'+e.getLineNumber());
        }
        System.debug('rows@@getBSMobilityTransition::' + rows);
        return rows;
    }
    //EDGE-173365 - getBSMobilityTransition End

}
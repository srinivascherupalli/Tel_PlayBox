/*
* This class is written for story EDGE-25921.
* It has logic to create Conga-URL and ContractJunction record for contracts created for CWP.  
* Revisions : 
* Ritika/Yash  19/08/2019  EDGE-98246  For CMP services and devices
* Ritika 29/08/2019 EDGE 110648 : Defect fix
* Vijayalakshmi 28/09/2019 EDGE-99894 For DOP
*Shubhi updated field api name Edge-98904
* Aniket Defect Fix EDGE - 115457 
* Vijayalakshmi 30/10/2019 EDGE-120230 For Auto Expired Offers 
* Yash: Updating Tenancy Solution in Product Family as per Colombo's change | No change in flow | INC000091883668
* Murlidhar 20/11/2019 DPG - 922 : IoT specific changes (Refer Line : 222)
* Aarathi 24/12/2019 DPG - 753 : IoT specific changes
* Yash: Updating Tenancy Solution in Product Family as per Colombo's change | No change in flow | EDGE-134876
* Aniket Defect Fix EDGE-132157
* Aarathi 20/01/2020 DPG 1301 - Label changes
* Suyash DPG-1619 Added new Contract Template for IoT
* Vishal Arbune : 20/03/2020 EDGE-141462 : EDGE-123791_New services is not coming in Order Summary section for Mac Order of CMP and NGUC
* Tejes Mahajan : 24/04/2020 EDGE-144224 : Added code for populating EAP End date on Contract record.
* Aarathi 23/07/2020 EDGE-151840 - Hide signature panel from Order Form for MAC orders
* Sunil - 29/08/2020 EDGE-165831 - Prod Families and offer families refactor.
* Vamsi Krishna Vaddipalli - DIGI-1410,DIGI-1412 on 26JUL2021

* Manuga -21/09/2020 EDGE-169277 - To skip the docusign flow for condition mentioned in US..
* Sunil - EDGE-165472 - Added condition for BSjA MAC one sugnature creation...
* Maq - Apttus related changes
* Maq : Frame agreement changes

Dheeraj 03/11/2020 EDGE -171769 check if this is a BSA or DSA, if this is DSA enabled product and skip cong-docusign path
EDGE -173035 check if this is a mixed basket throw an error
EDGE-171302  Add related price shcedule detail from parent contract in MAC case.
EDGE-171773  Full cancellations - Manage the process of solution cancellations and updates in CALMS + CJ records
* Ravi Shankar - 23/11/2020 - Added EDGE-173365 and EDGE-175103 changes 



* Ravi Shankar - 20/01/2021 - Added EDGE-171311 changes
* Aruna 23-Mar-2021  DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan

* Pallavi 08.04.2021 EDGE-209790 Generate order form for CHOWN basket
* lalit 18-08-2021 DIGI-1607 SDWAN MACD order condition
* Monali Golhar 20/09/2021 DIGI-20864
*/
public without sharing class GenerateContract {
    
    //public class myException extends Exception{} 
    //to throw exception for invalid mac order
    //EDGE-88882 ,97383, 97382 Service Terms UserStory
    public static List<Marketable_Offer__c> marketableOffersList;
    public static List<cscfga__Product_Configuration__c> prodConfigList;
    public static set<cscfga__Product_Configuration__c> prodConfigSet;
    public static set<String> moIdsSet;
    public static set<String> offerNameSet;
    public static List<Service_Term__c> stList = new List<Service_Term__c>();
    public static List<Service_Term__c> modstList = new List<Service_Term__c>();
    public static List<Service_Term__c> modCancList = new List<Service_Term__c>();   
    public static List<Service_Term__c> stListUpdated = new List<Service_Term__c>();
    public static Set<Service_Term__c> stSetUpdated = new Set<Service_Term__c>();
    public static map<string,Service_Term__c> stNameObjMap = new map<string,Service_Term__c>();
    Set<string> stNameSet = new Set<string>();
    Set<String> mrktblOfferNameSet= new Set<string>();//EDGE-126184 Changes 
    Set<Service_Term__c> inactvStatusSet = new Set<Service_Term__c>();
    List<Service_Term__c> inactvStatusList = new List<Service_Term__c>();
    public static map<string,APXTConga4__Conga_Template__c> offNmeTmpIdmap = new map<string,APXTConga4__Conga_Template__c>();
    public static Map<String,Boolean> offBoolMap = new Map<String,Boolean>();
    public static List<ContractJunction__c> lstcj = new List<ContractJunction__c>();
    public static set<string> parentbskSet = new set<string>();
    public static Map<string,cscfga__Product_Configuration__c> prodConfigMap = new Map<string,cscfga__Product_Configuration__c>();
    public static Map<string,string> tempNameUrlmap = new Map<string,string>();
    //Manoj : EDGE-98247 : holds MDM offer id
    public static final String MDMOfferId = 'DMCAT_Offer_000681';
    public static final String IOTOfferId = 'DMCAT_Offer_000964';
    public static final String IoTConnectivity = 'DMCAT_Offer_001522';//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
    static final String IoTConnects = 'IoT Connectivity';//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
    public static final String standAloneDeviceOffer = 'Standalone Devices and Accessories';//EDGE-207342
    public static final String adaptiveMobilityOfferName='Adaptive Mobility';//EDGE-207342
    //public static String contractTypeGlobal = ''; // EDGE-154520 | Author - Maq
    public static String psProductFamilies = '';  // EDGE-154520 | Author - Maq
    public static map<String, Boolean> relatedDocumentStatus = new map<String, Boolean>();  // EDGE-154520 | Author - Maq
    // EDGE-154519 | Author - Maq
    public static Boolean pcContainsDSAOffer = false; //This variable check if ngEM is added into the basket or not//Renamed as part of DIGI-683 from isDSAPresentInPc to pcContainsDSAOffer
    public static Boolean showSignaturePanel = true;
    public static String agreementCategory = 'Digital Services';//EDGE-226364
    
    public static Boolean isBSAOneDocuSignature = false;
    //EDGE-151840 - Hide signature panel from Order Form for MAC orders
    public static Boolean isPreauthorisedMAC = false;//to identify whether MAC order and Pre Authorised is true
    public static List<String> marketableOfferProductFamilies = new List<String>(); //EDGE-158915
    public static boolean iotAnnualPlan=false; //DPG 3344 - Service schedule for IoT Annual Data Plan
    
    
    
    
    //EDGE-173035 - set of marketable offer//Renamed from offerListValidation to pcContractTypeSet as part of DIGI-683
    public Static Set<String> pcContractTypeSet = new Set<String>();
    
    //EDGE-165831 - get all product specefication codes
    public List<String> prodSpecCodes;    
    
    
    public String createContract(String BasketId, map<string, Id> ContractSignatories, String CallingFrom,
                                boolean isDigBsaPSVarApplicableForRA , AgreementUtilities.AgreementDecision decision){
        if(BasketId == null || BasketId == '')//EDGE-155059 & EDGE-162542
            return null;
        //public String createContract(String BasketId,  String CallingFrom){
        // map<string, Id> ContractSignatories;
        String congaURL='';
        ContractJunction__c record;
        boolean isMAC=false;
        boolean isMDM=false;  // Manoj Kumar : EDGE-98247
        boolean isIOT=false;  // Aarathi DPG 753
        boolean docusignRestrictedFlag = false;
        //Manuga Changes for EDGE-169277
        
        boolean isSendOrderFormEmail = false; 
        boolean isChownIncomingOrder = false; //EDGE-191759 changes 


        String docuSigner2 = '';
        String docuSigner3 = '';
        Integer showNewServices=0;
        Integer showExistingServices=0;
        Integer showCancelDSAServices = 0; //EDGE-171773
        Integer showChangesToExisting=0; //EDGE-143435 && EDGE-158055
        Integer showTransitionServices=0;//EDGE-132157
        Integer showCancelServices=0;
        Integer showCancelMobilityervices=0;
        set<string> offername= new set<string>();
        String contractName = ''; // added a new variable for RPLP-72
        String dispatchOffer = ''; // added a new variable for RPLP-72
        boolean tcPresent = false;
        boolean isRenewServiceTerm = false;
        string accNameId ='';
        string origBsktName='';//EDGE-171311
        string IOTValue = '';//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
        Boolean areAgmtCancelled = false;//DIGI-30673
        
        
        
        /*-- EDGE-43745 :  Contract signatories setup --*/
        if( ContractSignatories.ContainsKey('signer2')){
            docuSigner2 = ContractSignatories.get('signer2');
        }
        if(ContractSignatories.ContainsKey('signer3')){
            docuSigner3 = ContractSignatories.get('signer3');
        }
        /*-- EDGE-43745 :  Contract signatories setup --*/
        try{
            GenerateQuoteHelper.populateGSTPricesinPC(BasketId);
            ContractJunction__c parentContract;
            congaURL ='&Id=';
            OpportunityContactRole primaryContact;
            Contact SignatoryContact = New Contact();
            System.debug('Inside new contract');           
            
            //Query to get product-basket details /** Added  csbb__Account__r.APTPS_Contract_Manager__c, csbb__Account__r.Name fields to the Query as a part of DIGI-434 userstory By Lokesh Thathuru */

            String queryProductBasket ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('cscfga__Product_Basket__c'))+', csbb__Account__r.APTPS_Contract_Manager__c, csbb__Account__r.Name '+' FROM cscfga__Product_Basket__c WHERE Id =: basketId FOR UPDATE';
            cscfga__Product_Basket__c productBasket=Database.query(queryProductBasket);
            //EDGE-171311 - Start
            //if(productBasket.RecordTypeId != null){
                //String inflOpptyId = productBasket.cscfga__Opportunity__c;
                //list<cscfga__Product_Basket__c> origProdBsktLst = [SELECT Id,Name FROM cscfga__Product_Basket__c WHERE RecordTypeId = null AND csordtelcoa__Basket_Stage__c = 'Submitted' AND cscfga__Opportunity__c = :inflOpptyId];
                //if(origProdBsktLst != null && origProdBsktLst.size()>0)
                    //origBsktName = origProdBsktLst[0].Name;
            //}
            //EDGE-171311 - End
            /***** ORLANDO CODE CHANGE START***/
            //EDGE-88882 ,97383, 97382 Service Terms UserStory
            //Creating list of product configurations in the basket
            marketableOffersList = new List<Marketable_Offer__c>();
            prodConfigList = new List<cscfga__Product_Configuration__c>();
            prodConfigSet = new Set<cscfga__Product_Configuration__c>();
            moIdsSet = new Set<String>(); 
            marketableOffersList = [SELECT Id,Offer_ID__c,Solution_Template__c,Name,OfferDefinationName__c FROM Marketable_Offer__c];
            system.debug('marketableOffersList'+marketableOffersList);
            for(Marketable_Offer__c mo : marketableOffersList){
                moIdsSet.add(mo.OfferDefinationName__c);
            }
            system.debug('moIdsSet--'+moIdsSet);
            if(moIdsSet!=null && moIdsSet.size()>0){
                prodConfigList = [SELECT id,Name,cscfga__Contract_Term__c,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Basket__r.Name,Type__c,
                                  cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,ConfigurationType1__c,
                                  
                                  
                                  Marketable_Offer__r.Offer_ID__c,cscfga__Product_Basket__r.cscfga__total_contract_value__c,Marketable_Offer__r.Name, cscfga__Product_Basket__c,Marketable_Offer__r.Contract_Type__c,Marketable_Offer__r.OfferDefinationName__c,
                                  
                                  
                                  cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c,OfferName__c
                                  from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=: basketId
                                  and (cscfga__Product_Definition__r.cscfga__Label__c IN :moIdsSet  OR ConfigurationType1__c='SolutionComponent' )];//changes field in query Edge-98904
            } 
            system.debug('offerNameSet'+offerNameSet);
            system.debug('prodConfigListSize'+prodConfigList);
            
            offerNameSet = new Set<string>();
            if(prodConfigList != null && prodConfigList.size()>0){
                prodConfigSet.addAll(prodConfigList);
                system.debug('prodConfigSet --'+prodConfigSet);
                for(cscfga__Product_Configuration__c pc :prodConfigList ){
                    mrktblOfferNameSet.add(pc.Marketable_Offer__r.Name);//EDGE-126184 Changes 
                    offerNameSet.add(pc.Marketable_Offer__r.OfferDefinationName__c);
                    prodConfigMap.put(pc.Marketable_Offer__r.OfferDefinationName__c,pc);
                    pcContractTypeSet.add(pc.Marketable_Offer__r.Contract_Type__c);
                    accNameId = pc.cscfga__Product_Basket__r.csbb__Account__c;
                    System.debug('pc.name'+pc.Name);
                    //Manoj Kumar : EDGE-98247 : setting isMDM true if pc is MDM
                    if(pc.Marketable_Offer__c != null && pc.Marketable_Offer__r.Offer_ID__c == MDMOfferId){
                        isMDM = true;
                    }
                    // Added for IOT Offer - DPG 753
                    if(pc.Marketable_Offer__c != null && (pc.Marketable_Offer__r.Offer_ID__c == IOTOfferId || pc.Marketable_Offer__r.Offer_ID__c == IoTConnectivity)){ //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
                        isIOT = true;
                        IOTValue = pc.Marketable_Offer__r.Offer_ID__c;//DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021
                    }
                    //START--DPG 3344 - Service schedule for IoT Annual Data Plan
                    
                    if(string.isNotBlank(pc.Name)){
                        if(pc.Name.containsIgnoreCase(System.Label.Iot_Annual_Plan)){
                            iotAnnualPlan = true;  
                        }
                        
                    }
                    //END--DPG 3344 - Service schedule for IoT Annual Data Plan
                    
                    
                    
                }
            }
            system.debug('prodConfigList --'+prodConfigList);
            system.debug('prodConfigMap --'+prodConfigMap);
            system.debug('mrktblOfferNameSet'+mrktblOfferNameSet);
            system.debug('pcContractTypeSet'+pcContractTypeSet);
            
            
            if(pcContractTypeSet.size()>0){
                if(pcContractTypeSet.contains('DSA') && pcContractTypeSet.contains('BSA')){
                    
                    
                    return 'Error Mix Basket';
                }
            }
      pcContainsDSAOffer = pcContractTypeSet.contains('DSA');//DIGI-683
      
            // EDGE-154519 | Author - Maq
            //pcContainsDSAOffer = getContractTypeForMarketableOffer(productBasket, 'DSA');
            relatedDocumentStatus = isDSALinkedToAccount(productBasket); // EDGE-154520 | Author - Maq
            // EDGE-154519 | Author - Maq
            //   pcContainsDSAOffer = getContractTypeForMarketableOffer(productBasket, 'DSA');
            offBoolMap = documentsToGenerate(productBasket,offerNameSet);
            system.debug('offBoolMap--'+offBoolMap);
            
            
            //check wheteher basket is dsa and account is linked and price shc is different or new
            if(pcContainsDSAOffer && relatedDocumentStatus.get('DSAGenerated') && !relatedDocumentStatus.get('priceScheduleGenerated') ){
                
                
                Boolean isMACvalid = macAgreementlineItemCheck(productBasket.csbb__Account__c , psProductFamilies.split(';'));
                system.debug('Inside check condition ');
                if(!isMACvalid){
                    return 'Price Shcedule is not present';
                    //throw new myException('Cannot create the contract record. Please Contact System Administrator');
                }
            }
            //End of changes
            /***** ORLANDO CODE CHANGE END***/
            if(docuSigner2 != ''){
                SignatoryContact = [SELECT Id,Email,Phone,Fax,Owner.Title,jobTitle__c FROM Contact WHERE Id =: docuSigner2]; //Added jobTitle__c field for EDGE-165486 
                // start EDGE-76402 Give validation error message when there is no email address with contract signatory contact
                if(SignatoryContact.Email==''||SignatoryContact.Email==null){
                    return 'Add Valid Email Address for contract signatory';
                }
                //end EDGE-76402
            }
            //Query to get type of Opportunity
            Opportunity opportunity = [Select id,RecordType.id,contract_type__c,RecordType.Name,RecordType.DeveloperName from Opportunity where id=:productBasket.cscfga__Opportunity__c FOR UPDATE]; //EDGE-219001 Added Contract_type__c
            System.debug('opportunity.RecordType.Name:'+opportunity.RecordType.Name);
            /* commented by orlando   */
            //Map<String,Boolean> offBoolMap =  documentsToGenerate(productBasket,offerNameSet);   
            Boolean dsaGenerated = relatedDocumentStatus.get('DSAGenerated');
            if(opportunity.RecordType.DeveloperName == 'MAC' || (isBSALinkedToAccount(productBasket) || dsaGenerated)) //EDGE-158915 | Include DSA MAC scenario       
            {
                System.debug('InMAC');
                isMAC = true;
                //EDGE - 109389 Start ngUC Cancel Commenting temporarily for testing
                parentContract = getParentContract(productBasket);  
            }
            //Changes Start- EDGE-44968
            //RPLP-72 Changes : Start : changed the below for loop based on OfferName
            tcPresent = ProductBasketUtil.doesBasketHaveOffer(productBasket, 'Adaptive Collaboration Solution');//DIGI-3352 :Name Change
            String prodConfig = tcPresent ? 'Unified Communication' : 'IP Site';
            System.debug('RPLP72 : prodConfig..'+prodConfig);       
            System.debug('RPLP72 : tcPresent..'+tcPresent);
            /**EDGE-80772 : Commented for Solution Console retrofit
* for(csbb__Product_Configuration_Request__c prrecord:[select id,csbb__Product_Configuration__r.name,csbb__Product_Configuration__r.Type__c,cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c,csbb__Product_Configuration__r.OfferName__c, csbb__Product_Configuration__r.cscfga__Product_Definition__r.Name from csbb__Product_Configuration_Request__c  where csbb__Product_Basket__c=:BasketId and (csbb__Product_Configuration__r.cscfga__Product_Definition__r.Name='Mobility' or csbb__Product_Configuration__r.name=:prodConfig)]){
System.debug('***record'+prrecord.csbb__Product_Configuration__r.Type__c+prrecord.csbb__Product_Configuration__r.cscfga__Product_Definition__r.Name);
//EDGE - 110648 : Defect fix
if(prrecord.csbb__Product_Configuration__r.Type__c=='New' && prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c==null){
showNewServices=showNewServices+1;
}
System.debug('RPLP72 : ShowNewServices..'+showNewServices);
// EDGE-79676 - Start
if(prrecord.csbb__Product_Configuration__r.Type__c=='Cancel' && prrecord.csbb__Product_Configuration__r.cscfga__Product_Definition__r.Name=='Mobility' && prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null){
showCancelMobilityervices=showCancelMobilityervices+1;
system.debug('loopshowCancelMobilityServices'+showCancelMobilityervices);
}
// EDGE-79676 - End
else if(prrecord.csbb__Product_Configuration__r.Type__c=='Cancel' && prrecord.csbb__Product_Configuration__r.cscfga__Product_Definition__r.Name!='Mobility' && prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null){
showCancelServices=showCancelServices+1;
system.debug('loopshowCancelServices'+showCancelServices);
}
else if(prrecord.csbb__Product_Configuration__r.Type__c=='Modify'|| prrecord.csbb__Product_Configuration__r.csordtelcoa__Replaced_Product_Configuration__c!=null){
showExistingServices=showExistingServices+1;
system.debug('loopshowExistingServices'+showExistingServices);
}
//start EDGE-67629
if(prrecord.csbb__Product_Configuration__r.OfferName__c=='Connected Workplace Package')
offername.add('Connected Workplace');
else
offername.add(prrecord.csbb__Product_Configuration__r.OfferName__c); 
system.debug('offernamesetvalue'+offername);                                
}*/
            //For EDGE- 66484, obtaining mobility products
            //EDGE-80772 : Rewritten for Solution Console retrofit
            //EDGE-98246 : start
            //EDGE-109988 : MDM defect fix
            List<String> parentPCs = new list<String>{'Unified Communication','IP Site','MDM Tenancy','Next Gen Mobility Adaptive Care'};// DPG-2317 added adaptive care
                String CMPConfig= System.Label.ProductSpecificationMobile;//EDGE - 117740
            String CWPConfig= System.Label.Product_Specification_for_Cwp;
            Boolean isLegSrvcforENTMob = false;//EDGE-175103
            String productSpecNgUcList = Label.ProductSpecificationNgUc; // EDGE-117738//EDGE-217484 fix
            //List<String> productFamilies = new list<String>{'Mobile Subscription','Mobility','Tenancy','Telstra Collaboration Solution','Next Generation Voice'}; //EDGE-80783 >> -
            //EDGE - Changes start for 99894
            //Added Mobile Device for EDGE - 115457
            //DPG - Changes start for 922 : added 'IOT Subscrioption' in the below list
            //EDGE-134876
            //EDGE-140420 addded product family Enterprise Mobility by DPG Neon which was overridden
            
            
            //List<String> productFamilies = new list<String>{'IOT Subscription','Mobile Subscription','Mobility','Tenancy','Telstra Collaboration Solution','Professional Services-MDM Config','Device Outright Purchase Solution','Mobile Device','Internet Site','Tenancy Solution','Enterprise Mobility','Business Calling','Unified Communication Device','Accessory','Next Generation Mobile Device','Mobile Device Care','Enterprise Mobility Plan'};   //EDGE-80783,EDGE-98337 >> +//EDGE-132608 AND EDGE-144732- Added Business Calling PCName. //EDGE-148728 //EDGE-148722 //EDGE-165326
            //EDGE-165831 - replaced prod families with spec code.       
            AllCQEnvironmentVariable cqVariables = new AllCQEnvironmentVariable();
            prodSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ProductSpeccificationCode'));
            system.debug('prodSpecCodes----->'+prodSpecCodes);
            //EDGE-165831-end 
            //EDGE-143435 && EDGE-158055
            //EDGE-165831 - Commented below list as its not used in class 
            //List<String> cancelProductFamilies = new list<String>{'Telstra Collaboration Solution','Enterprise Mobility','Device','Mobile Subscription','Unified Communication Device','Next Generation Voice','Accessory','Business Calling','Next Generation Mobile Device'}; //EDGE-144732 - Added Business Calling //EDGE-148722
            //EDGE - Changes end for 99894
            //EDGE-173365 --- Start
            List<Legacy_Service__c> legacySrvLst = [SELECT Id FROM Legacy_Service__c WHERE Product_Basket__c=:basketId AND Product_Type__c='Enterprise Mobility' AND Select__c = TRUE];
            if(legacySrvLst != null && legacySrvLst.size()>0){
                isLegSrvcforENTMob = true;//EDGE-175103
                showExistingServices=showExistingServices+1;
            } 
            //EDGE-173365 --- End               
            String developerNameMAC='';//EDGE-141462
            // EDGE-165831- query Filter change
            /*for(cscfga__Product_Configuration__c prrecord:[select id,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Family__c,name,Marketable_Offer__c,Marketable_Offer__r.Name,Type__c,Marketable_Offer__r.Offer_ID__c,
cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,
OfferName__c, cscfga__Product_Definition__r.Name, 
cscfga__Product_Basket__r.Pre_Authorised__c, 
(select id,name from attachments where name like '%Transition%') from cscfga__Product_Configuration__c  where cscfga__Product_Basket__c=:BasketId and (name IN :parentPCs or cscfga__Product_Definition__r.product_Specification__c IN :prodSpecCodes)])*/
            
            //EDGE-171773 added Marketable_Offer__r.Contract_Type__c in soql
            for(cscfga__Product_Configuration__c prrecord:[select id,Marketable_Offer__r.Contract_Type__c,cscfga__Product_Definition__r.product_Specification__c,cscfga__Product_Family__c,name,Marketable_Offer__c,Marketable_Offer__r.Name,Type__c,Marketable_Offer__r.Offer_ID__c,
                                                           cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName,csordtelcoa__Replaced_Product_Configuration__c,
                                                           OfferName__c, cscfga__Product_Definition__r.Name, cscfga__Product_Basket__r.Opportunity_Type__c,
                                                           cscfga__Product_Basket__r.Pre_Authorised__c, 
                                                           (select id,name from attachments where name like '%Transition%') from cscfga__Product_Configuration__c  where cscfga__Product_Basket__c=:BasketId and cscfga__Product_Definition__r.product_Specification__c IN :prodSpecCodes])
                
                
            {
                //EDGE-141462 : Fetch developer name : MAC 
                system.debug('prrecord@@::' + prrecord);
                if(String.isNotBlank(prrecord.cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName)){
                    developerNameMAC = prrecord.cscfga__Product_Basket__r.cscfga__Opportunity__r.RecordType.DeveloperName;                                                            
                }   
                //EDGE - 110648 : Defect fix
                   if((prrecord.Type__c=='New' || prrecord.Type__c=='CHOWN') && prrecord.csordtelcoa__Replaced_Product_Configuration__c==null){//EDGE-209790 added CHOWN check
                    showNewServices=showNewServices+1;
                    system.debug('Inside Normal If');
                    //Defect EDGE-192397 Start
                    for(attachment attachment:prrecord.attachments){
                        system.debug('Inside Transition if to update transition service count');
                        showTransitionServices=showTransitionServices+1;
                    }
                    //Defect EDGE-192397 End
                }
                //Changes start for EDGE-120230 
                if(prrecord.OfferName__c == 'Device Outright Purchase')
                {
                    showNewServices=showNewServices+1;
                }
                //EDGE-141270 AND EDGE-143435 && EDGE-158055 Start
                //Commented as part of EDGE-158055
                /*if((prrecord.Type__c=='Cancel' && prrecord.csordtelcoa__Replaced_Product_Configuration__c!=null && cancelProductFamilies.contains(prrecord.cscfga__Product_Family__c))){
showExistingServices=showExistingServices+1;
system.debug('loopshowExistingServicesCancel'+showExistingServices);    
}  */
                //EDGE-141270 AND EDGE-143435 && EDGE-158055 End  
                //EDGE-141270 AND EDGE-142411 End
                //EDGE-141462 : Check showNewServices values for the MAC basket if available
                if((prrecord.Type__c=='New' && developerNameMAC == 'MAC')){
                    showNewServices=showNewServices+1;
                    //EDGE-151840 - Hide signature panel from Order Form for MAC orders
                    if(prrecord.cscfga__Product_Basket__r.Pre_Authorised__c == true){
                        isPreauthorisedMAC = true;
                    }
                    system.debug('showNewServices for MAC'+showNewServices);    
                }   
                //Changes end for EDGE-120230 
                // EDGE-79676 - Start
                //Added Mobile Device for EDGE - 115457
                if(prrecord.Type__c=='Cancel' && (prrecord.cscfga__Product_Definition__r.Name=='Mobility' || prrecord.cscfga__Product_Definition__r.Name=='Mobile Device') && prrecord.csordtelcoa__Replaced_Product_Configuration__c!=null){
                    showCancelMobilityervices=showCancelMobilityervices+1;
                    //EDGE-151840 - Hide signature panel from Order Form for MAC orders
                    if(prrecord.cscfga__Product_Basket__r.Pre_Authorised__c == true){
                        isPreauthorisedMAC = true;
                    }
                    system.debug('loopshowCancelMobilityServices'+showCancelMobilityervices);
                }
                // EDGE-79676 - End
                else if(prrecord.Type__c=='Cancel' && prrecord.cscfga__Product_Definition__r.Name!='Mobility' && prrecord.csordtelcoa__Replaced_Product_Configuration__c!=null){
                    showCancelServices=showCancelServices+1;
                    //EDGE-151840 - Hide signature panel from Order Form for MAC orders
                    if(prrecord.cscfga__Product_Basket__r.Pre_Authorised__c == true){
                        isPreauthorisedMAC = true;
                    }
                    system.debug('loopshowCancelServices'+showCancelServices);
                }
                else if(prrecord.Type__c=='Modify'&& prrecord.csordtelcoa__Replaced_Product_Configuration__c!=null){
                    showExistingServices=showExistingServices+1;
                    showChangesToExisting=showChangesToExisting+1; //EDGE-143435 && EDGE-158055
                    //EDGE-151840 - Hide signature panel from Order Form for MAC orders
                    if(prrecord.cscfga__Product_Basket__r.Pre_Authorised__c == true){
                        isPreauthorisedMAC = true;
                    }
                    system.debug('loopshowExistingServices'+showExistingServices);
                    system.debug('loopshowChangesToExisting'+showChangesToExisting);
                    //EDGE-154990-Removed NGUC condition as Transition is not applicablr for ngUC    
                }else if(prrecord.Type__c=='New' && (prrecord.cscfga__Product_Definition__r.product_Specification__c == CMPConfig || prrecord.cscfga__Product_Definition__r.product_Specification__c == CWPConfig || prrecord.cscfga__Product_Definition__r.product_Specification__c == productSpecNgUcList)){// EDGE-117740 & EDGE-117738 for TransitionStart////Added nguc changes for EDGE-217484
                    system.debug('Inside CWP If');
                    system.debug('PC name -->'+prrecord.Name);
                    for(attachment attachment:prrecord.attachments){
                        system.debug('Inside CWP If For');
                        showExistingServices=showExistingServices+1;
                        showTransitionServices=showTransitionServices+1;//EDGE-132157
                    }
                // EDGE -117740 end   
                //DIGI-1607 start
        }else if(prrecord.Type__c=='New' && prrecord.cscfga__Product_Definition__r.product_Specification__c == System.Label.SDWAN_OFFER &&  
                         prrecord.cscfga__Product_Basket__r.Opportunity_Type__c == 'MACs (Moves, Adds & Change)'){
                        
                    showExistingServices=showExistingServices+1;

                 } //DIGI-1607 end           

                //start EDGE-67629
                //EDGE-171773 start
                
                
                if(prrecord.Type__c=='Cancel' && prrecord.Marketable_Offer__r.Contract_Type__c == 'DSA' && prrecord.csordtelcoa__Replaced_Product_Configuration__c!=null){
                    
                    
                    showCancelDSAServices=showCancelDSAServices+1;
                    system.debug('showCancelDSAServices =='+showCancelDSAServices);
                }
                //EDGE-171773 end
                if(prrecord.OfferName__c=='Connected Workplace Package')
                    offername.add('Connected Workplace');
                else{
                    // EDGE-165831 -Method Parameter Change
                    //String offerDerived = ProductBasketDataHandler.getOfferFamily(prrecord.OfferName__c)!=null?ProductBasketDataHandler.getOfferFamily(prrecord.OfferName__c):ProductBasketDataHandler.getOfferFamily(prrecord.Marketable_Offer__r.Name);
                    String offerDerived = ProductBasketDataHandler.getOfferFamily(prrecord.Marketable_Offer__r.Offer_ID__c)!=null?ProductBasketDataHandler.getOfferFamily(prrecord.Marketable_Offer__r.Offer_ID__c):ProductBasketDataHandler.getOfferFamily(prrecord.Marketable_Offer__r.Offer_ID__c);
                    System.debug('offerDerived :'+offerDerived );
                    offername.add(offerDerived );
                } 
                //EDGE-98246 end
                system.debug('offernamesetvalue'+offername);                                
            }
            // End- EDGE-67629
            //Query to get contact-details of Primary-Contact mentioned in Oppty's Contact-roles
            List<OpportunityContactRole> contact = [SELECT Id,ContactId,contact.name,contact.email,contact.MobilePhone FROM OpportunityContactRole WHERE OpportunityId =: productBasket.cscfga__Opportunity__c AND IsPrimary = true limit 1];
            if(!contact.isEmpty()){                  
                //  primaryContact = contact[0];
            }              
            Boolean ExistingContract=isBSALinkedToAccount(productBasket);
            List<Conga_Template_Setting__mdt> congaContractTemplates = [select id,feature__c,DeveloperName,Query_Names__c,Query_ID__c,Basket_Filter_value__c from Conga_Template_Setting__mdt where feature__c='Contract'];
            System.debug('congaContractTemplates:'+congaContractTemplates);
            Integer contractTermBasket = getContractTermforBasket(productBasket);
            // EDGE-154519 | Author - Maq
            //pcContainsDSAOffer = getContractTypeForMarketableOffer(productBasket, 'DSA');
            //Sonar-bug fix 
            if(congaContractTemplates.size()>0){
                Conga_Template_Setting__mdt c = congaContractTemplates[0];
                System.debug('congaContractTemplates:'+congaContractTemplates[0]);
                System.debug('DeveloperName:'+c.DeveloperName);
                String DeveloperName = c.DeveloperName;               
                //Changes start for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                Boolean macApplicable = TRUE;
                //Changes end for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                if(DeveloperName.contains('OrderForm'))
                {
                    System.debug('Create Orderform');                     
                    List <ContractJunction__c> recordPresent=[SELECT id,Conga_URL__c,Status__c,Name,Existing_Services_Show__c,Parent_Contract__c FROM ContractJunction__c WHERE Related_Basket__c=:BasketId
                                                              and RecordTypeId!='0122O0000004SeYQAU'];
                    System.debug('recordPresent:'+recordPresent);
                    if(recordPresent.isEmpty()) // check if contractjucntion already present
                    {
                        record = new ContractJunction__c();
                        record.RecordTypeId = Schema.SObjectType.ContractJunction__c.getRecordTypeInfosByName().get('Order Form').getRecordTypeId();
                        System.debug('Record type:'+record.RecordTypeId);
                        /*    record.Email__c = primaryContact.contact.Email;
record.Phone__c = primaryContact.contact.MobilePhone; */
                        /*   record.Customer_Primary_Contact__c = primaryContact.ContactId; */
                        if(docuSigner2 != ''){
                            if(SignatoryContact.Email != NULL)
                                record.Email__c = SignatoryContact.Email;
                            if(SignatoryContact.Phone != NULL)    
                                record.Phone__c = SignatoryContact.Phone;    
                            record.Customer_Primary_Contact__c = docuSigner2; // EDGE-43745, EDGE-43745                             
                            record.Contact_Role__c = SignatoryContact.jobTitle__c;//EDGE-154517   // Replaced jobTitle__c from owner title EDGE-16548                            
                        }
                        
                        //DIGI-16609
                        if(isDigBsaPSVarApplicableForRA==true){
                            record.isDigBSA_PSVarRequiredForRA__c=isDigBsaPSVarApplicableForRA;
                           
                        }
                        if(decision!=null && decision.DigBSARelatedAccount!=null){
                             record.RelatedAccount__c=decision.DigBSARelatedAccount;
                        }
                        
                        record.Related_Basket__c = BasketId;
                        record.CongaStatus__c = 'NotStarted';
                        record.Account__c = productBasket.csbb__Account__c;
                        record.Related_Opportunity__c = productBasket.cscfga__Opportunity__c;
                        record.Contract_Activated_Date__c = System.today();
                        record.Contract_Term_Months__c = contractTermBasket;
                        if(origBsktName != '')//EDGE-171311
                            record.Name = 'CN' + origBsktName.substring(2);
                        else
                            record.Name = 'CN' + productBasket.Name.substring(2);
                        record.Contract_Expiry_Date__c = System.today().AddDays(30);
                        record.DocuSign_Signer_2__c = docuSigner2;
                        record.DocuSign_Signer_3__c = docuSigner3;
                        record.FCRDocuSigner2__c=docuSigner2;
                        // EDGE-154520 | Author - Maq
                        record.Contract_Type__c='DSA';//DIGI-683
                        
                        
                        if(productBasket.csconta__Frame_Agreement__c != NULL)
                            record.isFrameAgreementContract__c=true;
                        
                        //EDGE-144224 Start : Added by Napier Team (Tejes) to update EAP discount end date field on ContractJunction object. 
                        List<charge_line_item__c> cli=[select id,name,(select id, name, BusinessID__c,discountEndDate__c from Discount_Line_Items__r) from charge_line_item__c where basketId__c=:BasketId and Product_Configuration__r.cscfga__Product_Definition__r.Name in ('Business Calling','Unified Communication Device')];//EDGE-147970- Added Business Calling as per new ngUC model 
                        system.debug('cli--->'+cli);
                        if(cli.size() > 0 && cli[0].Discount_Line_Items__r.size() > 0 && cli[0].Discount_Line_Items__r[0].BusinessID__c == 'DMCAT_Discount_000899'){
                            system.debug('update contract-->');
                            record.EAP_Discount_End_Date__c=cli[0].Discount_Line_Items__r[0].discountEndDate__c;
                        }
                        //EDGE-144224 End
                        System.debug('output '+showCancelServices+'***'+showExistingServices);
                        //EDGE-79676 - Changes in loop
                        if((showCancelServices>0 || showCancelMobilityervices>0) && showExistingServices==0)
                        {
                            if(showCancelMobilityervices>0 && showCancelServices==0){
                                record.Cancel_Mobility_Contract__c=true;
                            }else if(showCancelServices>0){
                                record.Cancel_Contract__c=true;
                            }
                            date startDay = (System.TODAY()).toStartofWeek();
                            integer weekDays =(System.TODAY()).daysBetween(startDay);
                            if(weekDays==0)
                            {
                                record.Email_Send_Date__c = System.Today() + 4 ;
                            }
                            else if(weekDays == 1)
                            {                               
                                record.Email_Send_Date__c= System.Today() + 3 ;
                            }
                            else if(weekDays >= 4)
                            {
                                record.Email_Send_Date__c = System.Today() + 4 ;
                            }
                            else
                            {
                                record.Email_Send_Date__c = System.Today() + 2 ;
                            } 
                        }   
                        system.debug('offername.size():' + offername.size());
                        if(offername.size()>0){
                            system.debug('offervalue'+offername);
                            String offerFamily='';
                            String MofferId;
                            //Changes start for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                            marketableOffersList = new List<Marketable_Offer__c>();
                            marketableOffersList = [SELECT Id,Offer_ID__c,Solution_Template__c,Name,OfferDefinationName__c,Auto_Expired_Entity__c FROM Marketable_Offer__c];
                            system.debug('marketableOffersList'+marketableOffersList);
                            //Changes end for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                            for(string offer:offername){
                                //Changes start for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                                for(Marketable_Offer__c mo : marketableOffersList){
                                    if(!String.isBlank(mo.name) && !String.isBlank(offer))
                                    {
                                        Boolean result = offer.equals(mo.name);
                                        if(result == TRUE && mo.Auto_Expired_Entity__c == TRUE){macApplicable = FALSE;}
                                        
                                        if(result == TRUE){                  
                                            MofferId = mo.Offer_ID__c;
                                        }
                                    }
                                }
                                //Changes end for EDGE-120230 - macApplicable based on Auto_Expired_Entity__c
                                //EDGE-165831 - Method Parameter Change
                                //offerFamily = ProductBasketDataHandler.getOfferFamily(offer);
                                offerFamily = ProductBasketDataHandler.getOfferFamily(MofferId);
                                system.debug('@@@@record.CIS_Dispatched_Offers__c'+record.CIS_Dispatched_Offers__c);
                                system.debug('@@@@record.CIS_Dispatched_Offers__c'+offerFamily +''+offer);
                                if(record.CIS_Dispatched_Offers__c==null && !String.isBlank(offerFamily)){
                                    if(offerFamily==standAloneDeviceOffer){
                                    record.CIS_Dispatched_Offers__c=adaptiveMobilityOfferName;}
                                    else{record.CIS_Dispatched_Offers__c=offerFamily;}
                                    system.debug('@@record.CIS_Dispatched_Offers__c'+record.CIS_Dispatched_Offers__c);
                                }
                                else{
                                    System.debug('offer in list:'+offer);
                                    if(!String.isBlank(offerFamily) && !(record.CIS_Dispatched_Offers__c.contains(offerFamily)))
                                        if(offerFamily==standAloneDeviceOffer){
                                        record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';'+adaptiveMobilityOfferName;}
                                        else{record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';'+offerFamily;}
                                    system.debug('@@record.CIS_Dispatched_Offers__c'+offerFamily);
                                    system.debug('@@record.CIS_Dispatched_Offers__c'+record.CIS_Dispatched_Offers__c);
                                }
                            }
                        }
                        //Changes Start- EDGE-44968
                        //Changes start for 99894 - macApplicable based on Auto_Expired_Entity__c
                        //if(ExistingContract==true){
                        //Added showExistingServices condition for EDGE-121558
                        //EDGE-151840 - Hide signature panel from Order Form for MAC orders
                        if(isPreauthorisedMAC == true){
                            record.showSignaturePanel__c = false;
                            record.showAcknowledgeBtn__c = true;
                        }
                        if(ExistingContract==true && showExistingServices>0 && macApplicable == true){
                            //Changes end for 99894 - macApplicable based on Auto_Expired_Entity__c
                            record.Existing_Services_Show__c=true;
                            system.debug('macApplicable@@:Existing');
                            //record.Transition_Services_Show__c = true;//EDGE-132157
                            //EDGE-141462 : Set 'New Services Show' field to true for MAC Basket
                            if(showNewServices>0){
                                record.New_Services_Show__c=true;
                            }else{record.New_Services_Show__c=false;}
                            
                            
                        }
                        else if(showNewServices>0){
                            record.New_Services_Show__c=true;
                            if(showExistingServices>0){
                                system.debug('@@NewExistingServices');
                                record.Existing_Services_Show__c=true;
                                //record.Transition_Services_Show__c = true;//EDGE-132157
                            }
                        }
                        else if(showExistingServices>0){
                            record.Existing_Services_Show__c=true;
                            system.debug('@@@ Inside showExistingServices');
                            //record.Transition_Services_Show__c = true;//EDGE-132157
                        }
                        // EDGE-158055 - Start
                        if(showExistingServices==0 && showCancelServices>0){
                            system.debug('@@@ Inside NewCancel');
                            record.Existing_Services_Show__c=true;
                        }// EDGE-158055 - end
                        //EDGE-143435 && EDGE-158055 START

                        if(showChangesToExisting>0){
                            record.Changes_to_Existing__c=true;
                            system.debug('@@@ Inside showChangesToExisting'+record.Changes_to_Existing__c);
                        }
                        //EDGE-143435 && EDGE-158055 END
                        /*//EDGE - 109389 Start ngUC Cancel
else if(showCancelServices>0){
record.Cancel_Services_Show__c=true;
system.debug('@@@ Inside showCancelServices');
}
//EDGE - 109389 End ngUC Cancel*/
                        //Changes End- EDGE-44968
                        //EDGE-132157 Start
                        if(showTransitionServices>0){
                            
                            //Defect EDGE-192397 Start  
                            record.isTransitionContract__c = true;
                            //Defect EDGE-192397 End
                            //record.Transition_Services_Show__c = false;
                        }
                        //Cancel MAC order start EDGE-171773
                        system.debug('showCancelServices::'+showCancelServices+'::'+showExistingServices);
                        if(showCancelServices > 0 && showExistingServices==0){
                            
                            system.debug('Inside cancel agreement');
                            
                            List<csord__Service__c> servList =  new List<csord__Service__c>();
                            servList = [select id,csord__Status__c,csord__Subscription__r.csord__Account__c,csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Contract_Type__c  from csord__Service__c where csord__Status__c = 'Connected' and csord__Subscription__r.csord__Account__c =:productBasket.csbb__Account__c and csordtelcoa__Product_Configuration__r.Marketable_Offer__r.Contract_Type__c = 'DSA' and csordtelcoa__Product_Configuration__r.cscfga__Product_Definition__r.product_Specification__c IN :prodSpecCodes];
                            system.debug('servList cancel ==>>  '+servList + ':'+showCancelDSAServices);
                            List<Apttus__APTS_Agreement__c> cancelAgreementList = new List<Apttus__APTS_Agreement__c>();
                            List<Apttus__APTS_Agreement__c> updateAgreementList = new List<Apttus__APTS_Agreement__c>();
                            if(showCancelDSAServices == servList.size()){
                                
                                
                                cancelAgreementList = [select id,name,Apttus__Source__c,Related_Basket__r.csbb__Account__c,Apttus__Status_Category__c, Apttus__Status__c,RecordType.Name,Apttus__Agreement_Category__c  from Apttus__APTS_Agreement__c where Related_Basket__r.csbb__Account__c =:productBasket.csbb__Account__c];
                                
                                
                                system.debug('cancelAgreementList  '+cancelAgreementList);
                                if(cancelAgreementList.size()>0){
                                    for(Apttus__APTS_Agreement__c agmt:cancelAgreementList ){
                                        if(agmt.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL && agmt.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY){//DIGI-30673
                                            
                                            
                                            agmt.Apttus__Status_Category__c = 'Cancelled';
                                            agmt.Apttus__Status__c = 'Cancelled Request';
                                            areAgmtCancelled = true;//DIGI-30673
                                            
                                            updateAgreementList.add(agmt);
                                            record.Initiated_document_Generation__c = true;//DIGI-30673
                                        }
                                    }
                                }
                                
                                if(updateAgreementList.size()>0){
                                    update updateAgreementList;
                                }
                                
                                
                            }
                        }
                        //Cancel MAC order end EDGE-171773
                        //system.debug('record.Transition_Services_Show__c@@::' + record.Transition_Services_Show__c);
                        system.debug('record.Existing_Services_Show__c@@::' + record.Existing_Services_Show__c);
                        //EDGE-132157 End
                        //EDGE-171769
                        
                        
                        
                        if(pcContainsDSAOffer && offBoolMap.get('DSA') && (productBasket.csconta__Frame_Agreement__c == null)){
                            
                            
                            
                            record.Restrict_Conga_Flow__c= true;
                        }
                        //EDGE-171769
                        insert record;
                    }
                    else
                    {
                        record = recordPresent[0];
                    }
                }
                List<Opportunity> OpptyOwner=[Select Owner.Id from Opportunity where id=:productBasket.cscfga__Opportunity__c FOR UPDATE];
                System.debug('OpptyOwner:'+OpptyOwner[0].OwnerId);
                List<Account> AccountOwner=[Select Owner.Id,APTPS_DocuSign_Restricted__c from Account where id=:productBasket.csbb__Account__c];
                System.debug('AccountOwner:'+AccountOwner[0].OwnerId); 
                docusignRestrictedFlag = AccountOwner[0].APTPS_DocuSign_Restricted__c;
                System.debug('docusignRestrictedFlag:'+ docusignRestrictedFlag); 
                List<APXTConga4__Conga_Template__c> template = [select id,APXTConga4__Name__c,Type__c,Sequence__c,Active_Template_Version__r.Version__c from APXTConga4__Conga_Template__c where APXTConga4__Template_Group__c ='Contract' order by Sequence__c];
                System.debug('template:'+template);
                congaUrl=congaUrl+ record.Id +'&TemplateId=';
                //EDGE-119211 - Changing input name value of Contract doc in Conga URL
                String conName = record.Name;
                String ConRepName = conName.replace('-', '+-+');
                String orderformNameString = 'Order+Form'+'+-+'+ConRepName;
                String GeneralServiceTerm ='General+Service+Terms';
                String busServiceAgreement = 'Business+Service+Agreement';
                //EDGE-119211 End
                String dsaName = 'DSA'+'+-+'+ConRepName;
                String orderPASName = 'Proposed affected services'+'+-+'+ConRepName;//EDGE-175103
                String psName = 'Price+Schedule'+'+-+'+ConRepName;
                for(APXTConga4__Conga_Template__c t:template){    
                    //commented by Orlando
                    /*if(t.Type__c=='Offer Terms' && offBoolMap.get('OFT')){ 
record.OFTVersion__c = t.Active_Template_Version__r.Version__c;
congaUrl=congaUrl+ t.Id +',';
} */
                    /* if(t.Type__c=='Offer Terms' && offBoolMap.get('OFT')){
if(tcPresent && t.APXTConga4__Name__c == 'ngUCContract - Service Terms') {
record.OFTVersion__c = t.Active_Template_Version__r.Version__c;
congaUrl=congaUrl+ t.Id +',';                                                                             
} else if(!tcPresent && t.APXTConga4__Name__c == 'Contract - Service Terms'){
record.OFTVersion__c = t.Active_Template_Version__r.Version__c;
congaUrl=congaUrl+ t.Id +',';
}
}*/
                    if(t.Type__c=='General Product Terms' && offBoolMap.get('GPT')){
                        record.GPTVersion__c = t.Active_Template_Version__r.Version__c;
                        //congaUrl=congaUrl+ t.Id +',';
                        //EDGE-119211 - Changing input name value of Contract doc in Conga URL
                        congaUrl=congaUrl+'['+GeneralServiceTerm+']'+ t.Id +',';//EDGE-119211
                    }                          
                    else if(t.Type__c=='BSA' && offBoolMap.get('BSA')){
                        record.BSAVersion__c = t.Active_Template_Version__r.Version__c;
                        //congaUrl=congaUrl+ t.Id +',';
                        //EDGE-119211 - Changing input name value of Contract doc in Conga URL
                        congaUrl=congaUrl+'['+busServiceAgreement+']'+ t.Id +',';//EDGE-119211
                        record.BSA_Generated__c = true;
                        record.Contract_Type__c='BSA';//EDGE-207342
                    }// EDGE-154519 - Condition for DSA template
                    else if(t.Type__c=='DSA' && offBoolMap.get('DSA')){
                        
                        
                        
                        
                        
                        if(!(pcContainsDSAOffer && offBoolMap.get('DSA') && (productBasket.csconta__Frame_Agreement__c == null))){
                            
                            
                            
                            
                            
                            record.DSAVersion__c = t.Active_Template_Version__r.Version__c; // EDGE-154520 | Author - Maq
                            //congaUrl=congaUrl+'['+dsaName+']'+ t.Id +','; //INC000098131880 Fix
                        }//EDGE-171769
                    }// EDGE-154519 - Condition for Price Schedule Template
                    else if(t.Type__c=='Price Schedule' && offBoolMap.get('Price Schedule')){
                        
                        if(!(pcContainsDSAOffer && offBoolMap.get('DSA') && offBoolMap.get('Price Schedule') && (productBasket.csconta__Frame_Agreement__c == null))){
                            
                            if(!pcContainsDSAOffer){//Added Condition not generate PS under contract.
                            record.PriceScheduleVersion__c = t.Active_Template_Version__r.Version__c; // EDGE-154520 | Author - Maq
                            record.pricescheduleProductFamilies__c = psProductFamilies; // EDGE-154520 | Author - Maq
                            congaUrl=congaUrl+'['+psName+']'+ t.Id +',';
                            }
                        }//EDGE-171769   
                    }
                    else if(t.Type__c=='Cancel Order Form' && offBoolMap.get('CancelOrderform') && showCancelServices>0 && showExistingServices==0 && mrktblOfferNameSet.contains('Connected Workplace'))
                    {
                        system.debug('in Cancelblock'+t.APXTConga4__Name__c);
                        congaUrl=congaUrl+ t.Id +',';
                    }
                    //DPG-4524 - Generate Quote for the IoT MSIO LPWAN Plan
                    //DPG-1619 Added new Contract Template for IoT
                    //DPG-1690 Removed showCancelMobilityervices check
                 /*   else if(t.Type__c=='None' && offBoolMap.get('Orderform') && (showCancelServices==0 || (showCancelServices>0 && showExistingServices==0) || (showCancelServices>0 && showExistingServices>0)) && isIOT){
                        if(!tcPresent && t.APXTConga4__Name__c == 'Contract - IoT Order Form') {
                            System.debug('Iot order form');
                            congaUrl=congaUrl+'['+orderformNameString+']'+ t.id +',';
                        }
                    } */
                    // INC000092229271 Incident fix--Start Here
                    else if(t.Type__c=='None' && offBoolMap.get('Orderform') && showCancelMobilityervices==0 && (showCancelServices==0 || (showCancelServices>0 && showExistingServices==0))){
                        system.debug('tcPresentvalue'+tcPresent);
                        if (!tcPresent && t.APXTConga4__Name__c == 'Contract - Order Form') {
                            congaUrl=congaUrl+'['+orderformNameString+']'+ t.id +',';
                        }
                    }
                    // INC000092229271 Incident fix--End Here
                    //Added condition for showCancelMobilityervicesfor EDGE - 115457
                    else if(t.Type__c=='None' && offBoolMap.get('Orderform') && showCancelMobilityervices==0 && (showCancelServices==0 || (showCancelServices>0 && showExistingServices>0))){
                        system.debug('in OrderFormBlock..'+t.APXTConga4__Name__c);
                        if(tcPresent && t.APXTConga4__Name__c == 'ngUCContract - Order Form'){
                            system.debug('in OrderFormBlock..TC Offer');
                            //congaUrl=congaUrl+ t.Id +',';
                            //EDGE-119211 - Changing input name value of Contract doc in Conga URL
                            congaUrl=congaUrl+'['+orderformNameString+']'+ t.id +',';//EDGE-119211
                        }
                        else if (!tcPresent && t.APXTConga4__Name__c == 'Contract - Order Form') {
                            //if (t.APXTConga4__Name__c == 'Contract - Order Form') {
                            system.debug('in OrderFormBlock..Non TC Offer');
                            //congaUrl=congaUrl+ t.Id +',';
                            //EDGE-119211 - Changing input name value of Contract doc in Conga URL
                            congaUrl=congaUrl+'['+orderformNameString+']'+ t.id +',';//EDGE-119211
                        }
                    }     
                    // EDGE-79676 - Start
                    else if(t.Type__c=='Cancel Mobility' && offBoolMap.get('CancelMobility') && showCancelServices==0 && showCancelMobilityervices>0 && showExistingServices==0){
                        system.debug('in CancelMobility'+t.APXTConga4__Name__c);
                        congaUrl=congaUrl+ t.Id +',';
                    }
                    // EDGE-79676 - End
                    else if(t.Type__c=='None' && offBoolMap.get('Orderform') && showCancelMobilityervices==0 && (showCancelServices==0 || (showCancelServices>0 && showExistingServices>0))){
                        system.debug('in OrderFormBlock'+t.APXTConga4__Name__c);
                        congaUrl=congaUrl+ t.Id +',';
                    }  
                    if(isLegSrvcforENTMob && t.APXTConga4__Name__c=='Proposed affected services'){//EDGE-175103
                        congaUrl=congaUrl+'['+orderPASName+']'+ t.id +',';
                    }
                }
                congaUrl=congaUrl.substringBeforeLast(',');
                System.debug('CongaURL:'+congaUrl);
                //Manuga changes for EDGE-169277 to skip the docusign process for below condition start           
                ContractJunction__c cObj =[Select id,name,Related_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c,Related_Basket__r.Name,Related_Basket__r.cscfga__Opportunity__r.recordtype.Name,Related_Basket__r.cscfga__total_contract_value__c,Related_Basket__r.Pre_Authorised__c, Related_Basket__r.cscfga__Opportunity__r.Type, Related_Basket__r.BasketType__c From ContractJunction__c WHERE Related_Basket__c=:BasketId];  //EDGE-191759 changes added two new fields in query         
                
                //EDGE-190324 - Start
                Boolean isPartnerUserFlag = FeatureManagement.checkPermission('Partner_User');
                System.debug('isPartnerUserFlag-->'+isPartnerUserFlag);
                //EDGE-190324 - End
                if(cObj!=null && cObj.Related_Basket__c!=null){
                    //EDGE-190324 -  Added Partner Docusign flag condition only
                    //if((cObj !=null && cObj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name == 'Enterprise - In Contract' && cObj.Related_Basket__r.cscfga__total_contract_value__c <= 10000) || (cObj !=null && cObj.Related_Basket__r.Pre_Authorised__c == true))
                    if(((cObj !=null && cObj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name == 'Enterprise - In Contract' 
                         && cObj.Related_Basket__r.cscfga__total_contract_value__c <= 10000) || 
                        (cObj !=null && cObj.Related_Basket__r.Pre_Authorised__c == true))){
                            if(isPartnerUserFlag==true && cObj.Related_Basket__r.cscfga__Opportunity__r.Basket_Redemption_amount__c >0){
                                isSendOrderFormEmail = false;                                     
                                record.isSendOrderFormEmail__c = false;
                            }else{
                                system.debug('Docusign Restricted');
                                isSendOrderFormEmail = true;                                     
                                record.isSendOrderFormEmail__c = true;
                            }
                        }
                    //EDGE-165472
                    if(cObj !=null &&  cObj.Related_Basket__r.Pre_Authorised__c == false && cObj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name == 'Enterprise - In Contract' && cObj.Related_Basket__r.cscfga__total_contract_value__c > 10000){
                        isBSAOneDocuSignature= true;
                    }
                    //EDGE-165472
                    //DIGI-683 Start

                    if(cObj !=null &&  cObj.Related_Basket__r.Pre_Authorised__c == false && cObj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name == 'Enterprise - Standard' && cObj.Related_Basket__r.cscfga__total_contract_value__c > 10000 && (dsaGenerated || isBSALinkedToAccount(productBasket))){
                           isBSAOneDocuSignature= true;
                        system.debug('Inside New Order for > 10000');
                       }
                    system.debug('isBSAOneDocuSignature::' + isBSAOneDocuSignature);
                    //DIGI-683 End
                    
                    //EDGE-191759 changes start
                    String oppType = cObj.Related_Basket__r.cscfga__Opportunity__r.Type;
                    if(isPartnerUserFlag==true &&  oppType.contains('CHOWN') && cObj.Related_Basket__r.BasketType__c == 'Incoming'){
                        isChownIncomingOrder = true;
                        record.isSendOrderFormEmail__c = true;
                    }
                    //EDGE-191759 changes end
                }
                //if(docusignRestrictedFlag){
                
                //EDGE-191759 added isChownIncomingOrder in OR condition
                if(docusignRestrictedFlag || isChownIncomingOrder || isSendOrderFormEmail || (pcContainsDSAOffer && offBoolMap.get('DSA') && offBoolMap.get('BSA') && (productBasket.csconta__Frame_Agreement__c == null))){    //DIGI-683          
                    
                    
                    
                    //EDGE-171769 
                    
                    system.debug('Inside restricted ::' + 'docusignRestrictedFlag::' + docusignRestrictedFlag + 'isSendOrderFormEmail::' + isSendOrderFormEmail + 'pcContainsDSAOffer::' + pcContainsDSAOffer + 'offBoolMap.get::' + offBoolMap.get('DSA') + 'productBasket.csconta__Frame_Agreement__c::' + productBasket.csconta__Frame_Agreement__c);
                    congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile';
                    //Manuga changes for EDGE-169277 to skip the docusign process for US condition End
                    
                    
                }else{
                    // congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+OpptyOwner[0].OwnerId+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR2Id='+contact[0].ContactId+'&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR3Id='+AccountOwner[0].OwnerId+'&DocuSignR3Type=Signer&DocuSignR3Role=Signer+3&DocuSignR3RoutingOrder=3&DocuSignEndpoint=Demo'; 
                    //TED-383 Start
                    String eSignBSATemplateid = null;
                    String eSignBSAMACTemplateid = null;
                    List<echosign_dev1__Agreement_Template__c> eSignTemplateids = GetEchosignAgreementTemplate.getEchoSignAgreementTemplateIds();
                    for(echosign_dev1__Agreement_Template__c echoSigntemplate:eSignTemplateids){
                        if(echoSigntemplate.name == Label.BSA_eSign_Template_name && !eSignTemplateids.isEmpty()){
                            eSignBSATemplateid = echoSigntemplate.id;
                        }
                        else if(echoSigntemplate.name == Label.BSA_MAC_eSign_Template_name && !eSignTemplateids.isEmpty()){
                            eSignBSAMACTemplateid = echoSigntemplate.id;
                        }
                    }
                    //TED-383 End
                    /*-- EDGE-43745 :  Contract signatories setup --*/  
                    if(CallingFrom == 'basket'){
                        /* EDGE-154519 : Author : Maq */
                        if(pcContainsDSAOffer == true){
                            //EDGE-158915 - Start | Adding MAC scenario for DSA and generating Conga URL to send Contract only to Customer
                            if(dsaGenerated == true ||  isMAC == true){
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+docuSigner2+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Contract '+record.Name+' for your review.&DocuSignEndpoint='+Label.DocusignEndpoint;
                                record.showAcknowledgeBtn__c = true; //To display Acknowledge button for customer
                                system.debug('inside pcContainsDSAOffer');
                            }
                            else{
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+docuSigner2+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Contract '+record.Name+' for your review.&DocuSignR2Id='+docuSigner3+'&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR2EmailSubject=Your Telstra Contract '+record.Name+' for signatures.&DocuSignEndpoint='+Label.DocusignEndpoint;
                                system.debug('inside else pcContainsDSAOffer');
                            }
                            //EDGE-158915 - End
                            record.isDSAGenerated__c = true;
                            record.pricescheduleProductFamilies__c = psProductFamilies;
                            record.showSignaturePanel__c = false;
                            //EDGE-158915 - Start | Enabling Product Specific PriceSchedule details
                            marketableOfferProductFamilies = psProductFamilies.split(';');
                            system.debug('psProductFamilies: '+psProductFamilies+' marketableOfferProductFamilies : '+marketableOfferProductFamilies);
                            record.isNGEM__c = marketableOfferProductFamilies.contains(Label.NGEMMarketableOfferPF);
                            //EDGE-158915 - End
                        }
                        else if(showCancelServices>0 && showExistingServices==0){
                            //TED-383  Start
                            if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&ESVisible=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignBSAMACTemplateid;
                            }
                            else{
                                // EDGE-67760 Added subject in email in congaURl
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+docuSigner2+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Your Telstra Contract '+record.Name+' for signatures.&DocuSignEndpoint='+Label.DocusignEndpoint;
                                // EDGE-79676 - Start
                            }
                            //TED-383  End
                        }else if(showCancelMobilityervices>0 && showExistingServices==0){
                            //TED-383  Start
                            if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&ESVisible=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignBSAMACTemplateid;
                            }
                            else{
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+docuSigner2+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignEndpoint='+Label.DocusignEndpoint;
                                // EDGE-79676 - End
                            }
                            //TED-383  End
                        }else if(isBSAOneDocuSignature==true){
                            //TED-383  Start
                            if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&ESVisible=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignBSAMACTemplateid;
                            }
                            else{
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+docuSigner2+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Contract '+record.Name+' for your review.&DocuSignEndpoint='+Label.DocusignEndpoint;
                            }
                            //TED-383  End
                        }else{
                            // EDGE-67760 Added subject in email in congaURl
                            //TED-383  Start
                            if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&ESVisible=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignBSATemplateid;
                            }
                            else{
                                congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+OpptyOwner[0].OwnerId+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Contract '+record.Name+' for your review.&DocuSignR2Id='+docuSigner2+'&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR2EmailSubject=Your Telstra Contract '+record.Name+' for signatures.&DocuSignR3Id='+docuSigner3+'&DocuSignR3Type=Signer&DocuSignR3Role=Signer+3&DocuSignR3RoutingOrder=3&DocuSignR3EmailSubject=Action required: Contract '+record.Name+' for countersignature.&DocuSignEndpoint='+Label.DocusignEndpoint;
                            }
                            //TED-383  End
                        }
                    }
                    else{
                        //TED-383  Start
                        if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                            congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&ESVisible=1&DS7=14&ESSVBA=1&ESAgreementTemplateId='+eSignBSATemplateid;
                        }
                        else{
                            /* Contract Retry Flow - Don't change the order of signer id and signer type*/
                            String DocuSignR2Id = record.Conga_URL__c.substring(record.Conga_URL__c.indexOf('DocuSignR2Id=') + 1, record.Conga_URL__c.indexOf('&DocuSignR2Type'));
                            String DocuSignR3Id = record.Conga_URL__c.substring(record.Conga_URL__c.indexOf('DocuSignR3Id=') + 1, record.Conga_URL__c.indexOf('&DocuSignR3Type'));
                            // EDGE-67760 Added subject in email in congaURl
                            congaUrl=congaUrl+'&ZipFiles=0&SC0=1&SC1=SalesforceFile&DocuSignR1Id='+OpptyOwner[0].OwnerId+'&DocuSignR1Type=Signer&DocuSignR1Role=Signer+1&DocuSignR1RoutingOrder=1&DocuSignR1EmailSubject=Contract '+record.Name+' for your review.&DocuSignR2Id='+DocuSignR2Id+'&DocuSignR2Type=Signer&DocuSignR2Role=Signer+2&DocuSignR2RoutingOrder=2&DocuSignR2EmailSubject=Your Telstra Contract '+record.Name+' for signatures.&DocuSignR3Id='+DocuSignR3Id+'&DocuSignR3Type=Signer&DocuSignR3Role=Signer+3&DocuSignR3RoutingOrder=3&DocuSignR3EmailSubject=Action required: Contract '+record.Name+' for countersignature.&DocuSignEndpoint='+Label.DocusignEndpoint;
                        }
                        //TED-383  End
                    }
                }
                System.debug('url:'+congaUrl);
                if(c.Query_Names__c!=null){
                    congaUrl = congaUrl+'&QueryId=';
                    String queries = c.Query_Names__c;
                    System.debug('Queries:'+queries);
                    //Changes start - 66484 - Refactoring 
                    //List<String> listOfQueries = queries.split(',');
                    List<APXTConga4__Conga_Merge_Query__c> query = [select id,APXTConga4__Name__c from APXTConga4__Conga_Merge_Query__c where APXTConga4__Name__c IN :queries.split(',')];
                    Map<String,APXTConga4__Conga_Merge_Query__c> queryDetails = new Map<String,APXTConga4__Conga_Merge_Query__c>();
                    for(APXTConga4__Conga_Merge_Query__c queryData:query){
                        queryDetails.put(queryData.APXTConga4__Name__c,queryData);
                    } 
                    //  congaUrl=congaUrl+CongaUrlBuilder.congaURLCreater(mrktblOfferNameSet,queryDetails,BasketId);
                    //EDGE-126184 Changes start Here
                    //String congaURLCreator = CongaUrlBuilder.congaURLCreater(mrktblOfferNameSet,queryDetails,BasketId);
                    //Boolean basketBaseCongaURLFormated = false;//EDGE-126184 Changes 
                    //EDGE-126184 Changes End Here
                    APXTConga4__Conga_Merge_Query__c querySelected = new APXTConga4__Conga_Merge_Query__c();
                    for(String s:queryDetails.keySet()){
                        try{
                            querySelected = queryDetails.get(s);
                            System.debug('Conga Query-'+query);
                            //if(s.contains('Basket')|| s.contains('BS'))
                            if((s.contains('Basket')|| s.contains('BS') )){
                                //EDGE-126184 Changes start Here
                                /*if(!basketBaseCongaURLFormated){
congaUrl=congaUrl+congaURLCreator;
}*/
                                // congaUrl=congaUrl+'['+querySelected.APXTConga4__Name__c+']'+querySelected.id+'?'+c.Basket_Filter_value__c+'='+BasketId+',';
                                //basketBaseCongaURLFormated = true;
                                
                                
                                
                                //if(!(pcContainsDSAOffer && offBoolMap.get('DSA') && (productBasket.csconta__Frame_Agreement__c == null))){ //EDGE-193316: Commented this if statement
                                
                                congaUrl=congaUrl+'['+querySelected.APXTConga4__Name__c+']'+querySelected.id+'?'+c.Basket_Filter_value__c+'='+BasketId+',';
                                //basketBaseCongaURLFormated = true;
                                //}//EDGE-171769 //EDGE-193316: Commented this
                                
                                
                                //EDGE-126184 Changes End Here
                            }
                            else if(s.contains('Account'))
                                congaUrl=congaUrl+'['+querySelected.APXTConga4__Name__c+']'+querySelected.id+'?'+c.Basket_Filter_value__c+'='+productBasket.csbb__Account__c+',';
                            else if(s.contains('Opportunity'))
                                congaUrl=congaUrl+'['+querySelected.APXTConga4__Name__c+']'+querySelected.id+'?'+c.Basket_Filter_value__c+'='+productBasket.cscfga__Opportunity__c+',';
                            else {
                                congaUrl=congaUrl+'['+querySelected.APXTConga4__Name__c+']'+querySelected.id+','; //EDGE-98246
                            }//Changes start - 66484 - Refactoring 
                        }
                        Catch(Exception ex){
                            System.debug('Error Caught '+ex.getMessage());
                        }
                    }                                   
                }
                System.debug('here');
                congaUrl=congaUrl.substringBeforeLast(',');
                //Added isSendOrderFormEmail flag to skip the docusign process for EDGE-169277
                
                //EDGE-191759 added isChownIncomingOrder in OR condition
                system.debug('isChownIncomingOrder***' + isChownIncomingOrder);
                //if(docusignRestrictedFlag || isChownIncomingOrder || isSendOrderFormEmail || (pcContainsDSAOffer && offBoolMap.get('DSA') && (productBasket.csconta__Frame_Agreement__c == null))){
                //BSA Fix Start
                if(cObj !=null && cObj.Related_Basket__r.cscfga__Opportunity__r.recordtype.Name == 'Enterprise - Standard' && pcContractTypeSet.contains('BSA')){
                           isBSAOneDocuSignature= true;
                        system.debug('Inside BSA New Order');
                       }
                //BSA Fix End
                if(isBSAOneDocuSignature){
                    //TED-383 - Start
                    if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_CongaComposer','adobe')){
                        congaUrl=congaUrl+'&AttachmentParentId='+record.Id+'&QMode=EchoSign';
                    }
                    else{
                        congaUrl=congaUrl+'&AttachmentParentId='+record.Id+'&QMode=DocuSign';
                    }
                    //TED-383 - End    
                    }
                    else{
                        congaUrl=congaUrl+'&AttachmentParentId='+record.Id+'&QMode=SalesforceFile';
                    
                }
                    system.debug('Inside if flow for docusign');
               // }else{
                    /*System.debug('Inside MAC flow for docusign');
                    //Changes has Started for for EDGE-193827
                    //Changes made to below if else as part of DIGI-683
                    if(isBSAOneDocuSignature){//DIGI-683
                      congaUrl=congaUrl+'&AttachmentParentId='+record.Id+'&QMode=DocuSign';
                        
                    }
                    else{
                        congaUrl=congaUrl+'&AttachmentParentId='+record.Id+'&QMode=SalesforceFile';
                    
                }*/
                    //Changes has Started for for EDGE-193827
                //}
                //Changes start - 66484 - For Mobility Products
                if(record.Existing_Services_Show__c){
                    congaURL=congaURL.replace('BSMobilityServices','BSMobilityMAC');
                    congaURL=congaURL.replace('BSMobilityDevicesRC','BSMobilityRCMAC');
                    congaURL=congaURL.replace('BSMobilityDevicesOC','BSMobilityOCMAC');
                }
                //Changes end - 66484 - For Mobility Products       
                record.Conga_URL__c = congaURL;
                record.CongaStatus__c = 'InProgress';
                if(isMAC){
                    System.debug('here MAC');
                    if(parentContract !=null){
                        record.Parent_Contract__c = parentContract.Parent_Contract__c;
                        record.Related_Contract__c = parentContract.id;
                        //added for EDGE-171302
                        
                        
                        if(parentContract.Related_Price_Schedule__c != null && pcContainsDSAOffer){//Added pcContainsDSAOffer as part DIGI-683 
                            
                            
                            record.Agreement_Number__c = parentContract.Agreement_Number__c;
                            record.Related_Price_Schedule__c = parentContract.Related_Price_Schedule__c;
                        }
                        //added for EDGE-171302
                        //  record.Related_Contract__c = parentContract.id;
                        // parentContract.Related_Contract__c = record.Id;
                        // upsert parentContract;
                    }                   
                }
                system.debug('marketableOffersList-->'+marketableOffersList);
                if(offername.size()>0){
                    system.debug('offervalue'+offername);
                    String offerFamily='';
                    String MofferId1;
                    for(string offer:offername){
                        // EDGE-165831 - Method Parameter Change
                        for(Marketable_Offer__c mo : marketableOffersList){
                            if(!String.isBlank(mo.name) && !String.isBlank(offer))
                            {
                                Boolean result = offer.equals(mo.name);
                                if(result == TRUE){                  
                                    MofferId1 = mo.Offer_ID__c;
                                }
                            }
                        }
                        offerFamily = ProductBasketDataHandler.getOfferFamily(MofferId1);
                        system.debug('offerFamily-->'+offerFamily);      
                        // End
                        //offerFamily = ProductBasketDataHandler.getOfferFamily(offer);
                        if(offerFamily!=standAloneDeviceOffer){
                        if(record.CIS_Dispatched_Offers__c==null && !String.isBlank(offerFamily))
                            record.CIS_Dispatched_Offers__c=offerFamily;
                        else{
                            System.debug('offer in list:'+offer);
                            if(!String.isBlank(offerFamily) && !(record.CIS_Dispatched_Offers__c.contains(offerFamily)))
                                record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';'+offerFamily;
                        }
                    }
                }
                }
                //Manoj : EDGE-98247 : setting value of field : CIS_Dispatched_Offers__c
                if(isMDM && record.CIS_Dispatched_Offers__c==null){
                    record.CIS_Dispatched_Offers__c='Telstra Mobile Device Management – VMware';
                }
                else if(isMDM && record.CIS_Dispatched_Offers__c!=null){
                    record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';MDM Offer';
                }
                // Added for IOT Offer - DPG 753 
                if(isIOT && record.CIS_Dispatched_Offers__c==null){
                    //record.CIS_Dispatched_Offers__c='IoT Offer';
                    // Added label for IOT Offer - DPG 1301
                    //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021 starts
                    if(IOTValue == IOTOfferId)//Vamsi
                    {
                        record.CIS_Dispatched_Offers__c=Label.IoTOfferName;
                    }
                    else if(IOTValue == IoTConnectivity)
                    {
                        record.CIS_Dispatched_Offers__c=IoTConnects;
                    }
                    //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021 ends
                }
                else if(isIOT && record.CIS_Dispatched_Offers__c!=null){
                    //record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';IoT Offer';
                    // Added label for IOT Offer - DPG 1301
                    //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021 starts
                    if(IOTValue == IOTOfferId)//Vamsi
                    {
                        record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';'+Label.IoTOfferName;
                    }
                    else if(IOTValue == IoTConnectivity)
                    {
                        record.CIS_Dispatched_Offers__c=record.CIS_Dispatched_Offers__c+';'+IoTConnects;
                    }
                     //DIGI-1410,DIGI-1412 by Vamsi on 26JUL2021 ends
                }
                //Manoj
                // upsert record;
                
                System.debug('here URL'+record.Conga_URL__c);
                //congaURL ='&Id='; 
            }
            /***** ORLANDO CODE CHANGE START***/
            //EDGE-88882 ,97383, 97382 Service Terms UserStory
            //Generate Service term for add
            offNmeTmpIdmap = tempalteIDGeneration();  
            string parentID = '';
            //string opportunityRecordType = 'Enterprise - In Contract';
            //string pcType_new ='New'; 
            string opportunityRecordType = PRMConstants.Contract_OpportunityRecordType_EnterpriseInContract;
            string pcType_new = PRMConstants.Contract_ProductConfig_Type_New;
            system.debug('offNmeTmpIdmap--'+offNmeTmpIdmap);
            system.debug('prodConfigMap size--'+prodConfigMap.size());
            system.debug('offBoolMap--'+offBoolMap);
            //integer i=1;
            for(string pc: prodConfigMap.keySet()){
                system.debug('pc.Marketable_Offer__r.Name'+prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c);
                system.debug('boolmap name'+offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c));
                if(offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) != null && offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) && offNmeTmpIdmap.containsKey(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) && prodConfigMap.get(pc).Type__c == pcType_new){
                    system.debug('inside sterms gen');
                    System.debug('offerdefination'+offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c));
                    
                    //Start--DPG 3344 - Service schedule for IoT Annual Data Plan
                    if(iotAnnualPlan==false){
                        
                        Service_Term__c st = new Service_Term__c();
                        st.ParentContract__c = record.id;
                        //st.Related_Contract__c = record.id;
                        st.Related_Basket__c = prodConfigMap.get(pc).cscfga__Product_Basket__c;
                        st.CongaStatus__c = PRMConstants.Contract_CongaStatus_NotStarted; 
                        //st.CongaStatus__c = 'NotStarted';
                        st.Account__c = prodConfigMap.get(pc).cscfga__Product_Basket__r.csbb__Account__c;
                        st.Related_Opportunity__c = prodConfigMap.get(pc).cscfga__Product_Basket__r.cscfga__Opportunity__c;
                        st.Contract_Activated_Date__c = System.today();
                        //st.Contract_Term_Months__c = contractTermBasket;
                        st.Contract_Term_Months__c = prodConfigMap.get(pc).cscfga__Contract_Term__c;
                        st.Name = 'ST' + prodConfigMap.get(pc).cscfga__Product_Basket__r.Name.substring(2)+'-'+prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c;
                        st.ServiceTermName__c =  prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c;
                        st.ServiceTermTemplateName__c = offNmeTmpIdmap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).APXTConga4__Name__c;
                        st.Contract_Expiry_Date__c = System.today().AddDays(30);
                        st.DocuSign_Signer_2__c = docuSigner2;
                        st.DocuSign_Signer_3__c = docuSigner3;
                        st.FCRDocuSigner2__c=docuSigner2;
                        st.OFTVersion__c = offNmeTmpIdmap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).Active_Template_Version__r.Version__c;
                        st.isStatusChange__c=false;
                        stList.add(st);
                        tempNameUrlmap.put(st.Name,prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c);
                        
                    }
                    //End--DPG 3344 - Service schedule for IoT Annual Data Plan
                    
                    // i++;
                }else if((prodConfigMap.get(pc).cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c == opportunityRecordType && prodConfigMap.get(pc).Type__c == 'Modify' && offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) != null && offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c))|| ((prodConfigMap.get(pc).cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c == opportunityRecordType && prodConfigMap.get(pc).Type__c == pcType_new && offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) != null && offBoolMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c)))){
                    //Code for generate service term for modify
                    Service_Term__c st = new Service_Term__c();
                    if(parentContract !=null){
                        st.ParentContract__c = record.Id;
                        //   st.Related_Contract__c = parentContract.id;
                        /*st.ParentContract__c= record.Id;
st.Related_Contract__c = record.id;*/
                    }
                    st.Related_Basket__c = prodConfigMap.get(pc).cscfga__Product_Basket__c;
                    st.CongaStatus__c = PRMConstants.Contract_CongaStatus_NotStarted;
                    st.Account__c = prodConfigMap.get(pc).cscfga__Product_Basket__r.csbb__Account__c;
                    st.Related_Opportunity__c = prodConfigMap.get(pc).cscfga__Product_Basket__r.cscfga__Opportunity__c;
                    st.Name = 'ST' + prodConfigMap.get(pc).cscfga__Product_Basket__r.Name.substring(2)+'-'+prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c;
                    st.ServiceTermName__c = prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c;
                    st.ServiceTermTemplateName__c = offNmeTmpIdmap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).APXTConga4__Name__c;
                    if(stNameObjMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) != null){
                        st.Related_Service_terms__c = stNameObjMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).Id;  
                    }
                    //st.Contract_Term_Months__c = contractTermBasket;
                    st.Contract_Term_Months__c = prodConfigMap.get(pc).cscfga__Contract_Term__c;
                    st.Contract_Activated_Date__c = System.today();
                    st.Contract_Expiry_Date__c = System.today().AddDays(30);
                    st.DocuSign_Signer_2__c = docuSigner2;
                    st.DocuSign_Signer_3__c = docuSigner3;
                    st.FCRDocuSigner2__c=docuSigner2;
                    st.OFTVersion__c = offNmeTmpIdmap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).Active_Template_Version__r.Version__c;
                    st.isStatusChange__c=false;
                    stList.add(st);
                    modstList.add(st);
                    tempNameUrlmap.put(st.Name,prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c);
                    //i++;
                }else if(prodConfigMap.get(pc).cscfga__Product_Basket__r.cscfga__Opportunity__r.Opportunity_Record_Type__c == opportunityRecordType && prodConfigMap.get(pc).Type__c == 'Cancel' && offBoolMap.keyset().contains(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c)){
                    Service_Term__c st = new Service_Term__c();
                    if(parentContract !=null){
                        /*st.ParentContract__c = parentContract.Parent_Contract__c;
st.Related_Contract__c = parentContract.id;*/
                        st.ParentContract__c= record.Id;
                        // st.Related_Contract__c = record.id;
                        st.Account__c = prodConfigMap.get(pc).cscfga__Product_Basket__r.csbb__Account__c;
                        st.isStatusChange__c=false;
                        st.ServiceTermName__c = prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c;
                        st.ServiceTermTemplateName__c = offNmeTmpIdmap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).APXTConga4__Name__c;
                        System.debug('--++'+prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c+'='+stNameObjMap);
                        if(stNameObjMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c) != null){
                            st.Related_Service_terms__c = stNameObjMap.get(prodConfigMap.get(pc).Marketable_Offer__r.OfferDefinationName__c).Id;
                        }// modstList.add(st);
                        modCancList.add(st);
                    }
                }
            }
            /*Modify scneario start*/
            system.debug('modstList--'+modstList);
            if(modstList != null && modstList.size()>0){
                for(Service_Term__c str : modstList){
                    stNameSet.add(str.ServiceTermName__c);
                }
                system.debug('stNameSet--'+stNameSet);
                List<String> inActiveServTermStatus=new list<String>{'Signature Declined','Cancelled','Void','Superseded'};
                    if(stNameSet !=null && stNameSet.size()>0){
                        for(Service_Term__c strm : [SELECT id,Name,ServiceTermName__c,Status__c,isStatusChange__c from Service_Term__c
                                                    where status__c NOT IN:inActiveServTermStatus
                                                    AND ServiceTermName__c IN :stNameSet
                                                    AND Account__c =: accNameId
                                                    AND isStatusChange__c = false]){
                                                        strm.Status__c='Superseded';
                                                        strm.isStatusChange__c=true;
                                                        inactvStatusSet.add(strm);
                                                    }
                        system.debug('inactvStatusSet modify--'+inactvStatusSet);
                    }
            }
            /* end  */
            /*Cancel scenario start*/
            system.debug('modCancList--'+modCancList);
            if(modCancList != null && modCancList.size()>0){
                Set<string> stNameSet = new Set<string>();
                Set<Service_Term__c> inactvStatusSet = new Set<Service_Term__c>();
                List<Service_Term__c> inactvStatusList = new List<Service_Term__c>();
                for(Service_Term__c str : modstList){
                    stNameSet.add(str.ServiceTermName__c);
                }
                system.debug('stNameSet--'+stNameSet);
                List<String> inActiveServTermStatus=new list<String>{'Signature Declined','Cancelled','Void','Superseded'};
                    if(stNameSet !=null && stNameSet.size()>0){
                        for(Service_Term__c strm : [SELECT id,Name,ServiceTermName__c,Status__c,isStatusChange__c from Service_Term__c
                                                    where status__c NOT IN:inActiveServTermStatus
                                                    AND ServiceTermName__c IN :stNameSet
                                                    AND Account__c =: accNameId
                                                    AND isStatusChange__c = false]){
                                                        strm.Status__c='Cancelled';
                                                        strm.isStatusChange__c=true;
                                                        inactvStatusSet.add(strm);
                                                    }
                        system.debug('inactvStatusSet  canc--'+inactvStatusSet);
                    }
            }
            /* end  */
            //Cancelling status of previous Service Terms
            if(inactvStatusSet != null && inactvStatusSet.size()>0){
                inactvStatusList.addAll(inactvStatusSet);
                system.debug('inactvStatusList--'+inactvStatusList);
                update inactvStatusList;
            }
            //Insertion of Service Terms
            if(stList != null && stList.size()>0){
                insert stList;
                system.debug('stList1--'+stList);
            }
            system.debug('tempNameUrlmap--'+tempNameUrlmap);
            system.debug('stList12--'+stList);
            System.debug('here CongaURL initial contract--'+congaURL);
            //Formation of Conga URL to accomodate Service Terms --START
            string lastUrlPart = congaURL.split('&ZipFiles')[1];
            string firstUrlPart = congaURL.split('&ZipFiles')[0];
            system.debug('firstUrlPart1--'+firstUrlPart);
            system.debug('lastUrlPart--'+lastUrlPart);
            for(Service_Term__c st : stList){
                system.debug('inside urlpart loop');
                firstUrlPart= firstUrlPart + ','+offNmeTmpIdmap.get(tempNameUrlmap.get(st.name)).Id;
            }
            firstUrlPart.removeEnd(',');
            system.debug('firstUrlPart--'+firstUrlPart);
            string finalurl=firstUrlPart + '&ZipFiles'+lastUrlPart;
            record.Conga_URL__c = finalurl;
            if(docuSigner2!='')
            record.Customer_Primary_Contact__c = docuSigner2;
            //upsert record;
            system.debug('CONTRACTRcordValue'+record.Status__c);
            database.update(record,false);
            System.debug('here CongaURL final with service Term--'+record.Conga_URL__c);
            congaURL ='&Id='; 
            /***** ORLANDO CODE CHANGE END***/
            //EDGE-171769
            
                
            system.debug('pcContainsDSAOffer:' + pcContainsDSAOffer + ':'+offBoolMap.get('DSA')+':'+productBasket.csconta__Frame_Agreement__c);   
            if(pcContainsDSAOffer && !areAgmtCancelled){//DIGI-30673 Added areAgmtCancelled // Removed FA Condition as per DIGI-37579
               system.debug('Queries at the start:'+ Limits.getQueries());
                system.debug('Queries Limit:'+  Limits.getLimitQueries());    
                if(opportunity.contract_type__c == 'DSA' || opportunity.contract_type__c == 'BSA' || opportunity.contract_type__c=='Order Under Existing Contract' ){ //DIGI-683
                    //DIGI-434 - added the return type to the below code
                    AgreementUtilities.AgreementDecision decisionInstance= AgreementOrderUtilities.createAgreementRecords(record,productBasket,opportunity,decision);
                  if(decisionInstance.caseCreation!=null && decisionInstance.caseCreation){
                      delete record;     
          //DIGI-22178 fix       
                      String matchedPFamilies= String.join(new List<String>(decisionInstance.legacyPFMatchedSet), ','); 
                      String message='Contract cannot be proceeded, as an existing Legacy Agreement was detected for '+matchedPFamilies+'. A case '+decisionInstance.caseNumber+' has been assigned to the contracting manager for action. This contract can be continued after this legacy agreement is updated';
                      System.debug('caseCreation!@@!@@!'+decisionInstance.caseNumber);
          return 'caseCreation!@@!@@!'+message;
                    }
                    system.debug('Queries after function call:'+ Limits.getQueries());
                }
                else 
                    return 'Opty Error';
      }
           
            return record.Id; 
        
        }

        catch(AgreementException agEx){
            Agreementutilities.logException(agEx.methodName,agEx.referenceNumber,'',agEx.errorMessage,agEx.businessDescription);
            delete record;
            return 'AgreementError!@@!@@!'+agEx.businessDescription;
        }
        catch(Exception e){
            system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
            throw e;
        }
        //return congaURL;
    }
    ContractJunction__c getParentContract(cscfga__Product_Basket__c basket){
        ContractJunction__c parentContract=null;
        cscfga__Product_Configuration__c replacedPC = [select csordtelcoa__Replaced_Product_Configuration__c,csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=:basket.id limit 1];
        String parentBasketID=replacedPC.csordtelcoa__Replaced_Product_Configuration__r.cscfga__Product_Basket__c;
        if(parentBasketID!=null && replacedPC != null){
            parentContract = [Select id,GPTVersion__c,OFTVersion__c,BSAVersion__c, Related_Contract__c,Agreement_Number__c,Related_Price_Schedule__c,Parent_Contract__c,Name from ContractJunction__c where Related_Basket__c=:parentBasketID]; //added Agreement_Number__c,Related_Price_Schedule__c for EDGE-171302
            if(parentContract.Parent_Contract__c== null){
                parentContract.Parent_Contract__c = parentContract.Id; 
            }
            else if(parentContract.Parent_Contract__c!= null){
                parentContract.Parent_Contract__c = parentContract.Parent_Contract__c;
            }
        }
        else{
            //EDGE-158915 | Include DSA MAC scenario 
            list<ContractJunction__c > parentContractList = [select id,name,Existing_Services_Show__c,Parent_Contract__c,Agreement_Number__c,Related_Price_Schedule__c from ContractJunction__c where Account__c =: basket.csbb__Account__c and (BSA_Generated__c =true or IsDSAGenerated__c =true) order by createddate desc limit 1];       //added Agreement_Number__c,Related_Price_Schedule__c for EDGE-171302
            if(!parentContractList.isEmpty())
                parentContract=parentContractList[0];
        }
        system.debug('parentContract ==> '+parentContract);
        return parentContract;
    }
    public static Boolean isBSALinkedToAccount(cscfga__Product_Basket__c basket){
        List<String> inActiveContractStatus=new list<String>{'Signature Declined','Cancelled','Void'};
            List<ContractJunction__c> BSALinkedContracts = [select id,name,Existing_Services_Show__c from ContractJunction__c where Account__c =: basket.csbb__Account__c and BSA_Generated__c =true and Status__c not in :inActiveContractStatus];
        System.debug('Contracts linked to account:'+BSALinkedContracts);
        if(BSALinkedContracts.size()>0)
            return true;
        else 
            return false;
    }
    // EDGE-154519 - Added function to check DSA document is gemerated on Account.
    public static map < String,  Boolean > isDSALinkedToAccount(cscfga__Product_Basket__c basket) {
        List < String > inActiveContractStatus = new list < String > { 'Signature Declined', 'Cancelled', 'Void' };
            map < String, Boolean > statusofGeneratedDoc = new map < String, Boolean > ();
        statusofGeneratedDoc.put('DSAGenerated', false);
        statusofGeneratedDoc.put('priceScheduleGenerated', true);
        //    List<ContractJunction__c> LinkedContracts = [select id from ContractJunction__c where Account__c =: basket.csbb__Account__c and IsDSAGenerated__c =true and Status__c not in :inActiveContractStatus];
        Decimal DSAVersion;
        Decimal PriceScheduleVersion;
        //EDGE-165484 | Auther : Maq
        
        map<String, boolean> relatedAgreementFlags = new map<String, boolean>();
        if(basket.csconta__Frame_Agreement__c == NULL)
            relatedAgreementFlags = getRelatedAgreementFlags(basket, psProductFamilies.split(';'));
        else // EDGE-184430 : Deal based agreement logic | Maq
            relatedAgreementFlags = AgreementUtilities.validationForContractCreation(basket, psProductFamilies.split(';'), 'DSA');
        
        
        List < APXTConga4__Conga_Template__c > templateVersionCheck = [select id, APXTConga4__Name__c, Type__c, Sequence__c, Active_Template_Version__r.Version__c from APXTConga4__Conga_Template__c where APXTConga4__Template_Group__c = 'Contract'
                                                                       order by Sequence__c];
        for (APXTConga4__Conga_Template__c templateDetail: templateVersionCheck) {
            if (templateDetail.Type__c == 'DSA') {
                DSAVersion = templateDetail.Active_Template_Version__r.Version__c;
            }
            else if (templateDetail.Type__c == 'Price Schedule') {
                PriceScheduleVersion = templateDetail.Active_Template_Version__r.Version__c;
            }
        }
        Set < String > existingProductFamily = new Set < String > ();
        List < ContractJunction__c > LinkedContracts = [select id, IsDSAGenerated__c, pricescheduleProductFamilies__c, DSAVersion__c, PriceScheduleVersion__c from ContractJunction__c where Account__c = :basket.csbb__Account__c and Status__c not in :inActiveContractStatus];
        System.debug('DSA Contracts linked to account:' + LinkedContracts);
        if (LinkedContracts.size() > 0) {
            for (ContractJunction__c documentStatus: LinkedContracts) {
                if ((documentStatus.IsDSAGenerated__c == true && documentStatus.DSAVersion__c == DSAVersion) || relatedAgreementFlags.get('isAgreementGeneratedDSA') == true)  
                    statusofGeneratedDoc.put('DSAGenerated', true);
                if (psProductFamilies != '' && documentStatus.pricescheduleProductFamilies__c != null) {
                    existingProductFamily.addAll(documentStatus.pricescheduleProductFamilies__c.split(';'));
                }
            }
            
            
            system.debug('psProductFamilies :'+psProductFamilies);
            system.debug('existingProductFamily :'+existingProductFamily);
            
            
            if (psProductFamilies != '') {
                system.debug(' check psProductFamilies :'+psProductFamilies);
                for (String currentPF : psProductFamilies.split(';')) {
                    system.debug('currentPF >> '+currentPF);
                    if (!existingProductFamily.contains(currentPF) && relatedAgreementFlags.get('isAgreementGeneratedPS') == false) {
                        system.debug('inside existingproduct family condition');
                        statusofGeneratedDoc.put('priceScheduleGenerated', false);
                    }
                }
            }
            else {
                statusofGeneratedDoc.put('priceScheduleGenerated', false);
            }
        }
        
        else if(basket.csconta__Frame_Agreement__c != NULL) { // EDGE-184430 : Deal based agreement logic | Maq
            system.debug('$$$$$$$--> basket-->' + basket);    
            if(relatedAgreementFlags.get('isAgreementGeneratedDSA') == true){
                statusofGeneratedDoc.put('DSAGenerated', true);
            }
            if(relatedAgreementFlags.get('isAgreementGeneratedPS') == false) {
                statusofGeneratedDoc.put('priceScheduleGenerated', false);    
            }
            
            
            
        }
        system.debug('$$$$$$$--> DSAGenerated-->' + statusofGeneratedDoc);
        return statusofGeneratedDoc;
    }
    //EDGE-88882 ,97383, 97382 Service Terms UserStory
    //Generic Method to feth the list of documnets to be generated 
    public Map<String,Boolean> documentsToGenerate(cscfga__Product_Basket__c basket,set<string> offNameSet){
        Map<String,Boolean> mapOfDocuments = new Map<String,Boolean>{'Price Schedule'=> true,'DSA' => true,'BSA' => true, 'Orderform' => true, 'GPT' => true, 'None' => true,'CancelOrderform' => true, 'CancelMobility' => true}; 
            Map<string,APXTConga4__Conga_Template__c> genAllTempMap = tempalteIDGeneration();
        system.debug('offNameSet--'+offNameSet);
        system.debug('genAllTempMap--'+genAllTempMap);
        if(genAllTempMap != null && genAllTempMap.keySet() !=null && offNameSet != null && offNameSet.size()>0){
            for(string tempNames : genAllTempMap.keySet()){
                if(offNameSet.contains(tempNames)){
                    mapOfDocuments.put(tempNames,true);  
                }
            }
        }
        system.debug('mapOfDocuments--'+mapOfDocuments);
        Boolean bsaGenerated = isBSALinkedToAccount(basket);
        //    boolean isDSAOffer = getContractTypeForMarketableOffer(basket,'DSA');// EDGE-154519
        boolean isDSAOffer = pcContainsDSAOffer;// EDGE-154519
        //    map<String, Boolean> relatedDocumentStatus = isDSALinkedToAccount(basket); // EDGE-154520 | Author - Maq
        Boolean dsaGenerated = relatedDocumentStatus.get('DSAGenerated'); // EDGE-154520 | Author - Maq
        Boolean priceScheduleenerated = relatedDocumentStatus.get('priceScheduleGenerated'); // EDGE-154520 | Author - Maq
        system.debug('bsaGenerated'+bsaGenerated + ' <-->dsaGenerated--> '+dsaGenerated + ' <-->isDSAOffer'+bsaGenerated);
        List<String> inActiveServiceTermStatus=new list<String>{'Signature Declined','Cancelled','Void','Superseded'};
            List<ContractJunction__c> contractsForAccount = [Select id,GPTVersion__c,OFTVersion__c,BSAVersion__c,Name,Existing_Services_Show__c,Parent_Contract__c from ContractJunction__c where Account__c = :basket.csbb__Account__c];
        List<APXTConga4__Conga_Template__c> otherFormsList= [Select id,Type__c, Active_Template_Version__r.Version__c from APXTConga4__Conga_Template__c where Type__c = :PRMConstants.Contract_TemplateType_GeneralProductTerms];
        system.debug('otherFormsList'+otherFormsList);
        system.debug('contractsForAccount'+contractsForAccount);
        if(!bsaGenerated && !isDSAOffer){
            system.debug('isndei if BSA');
            mapOfDocuments.put('DSA', false);
            mapOfDocuments.put('Price Schedule', false);
            return mapOfDocuments;
        }else if(isDSAOffer){   // EDGE-154519 - Added Condition for DSA and Price Schedule template
            if(!dsaGenerated){
                mapOfDocuments.put('BSA', false);
                mapOfDocuments.put('GPT',false);               
            }
            else{
                mapOfDocuments.put('DSA', false);
            }
            //DIGI-20864 Start 
            if (basket.csconta__Frame_Agreement__c != null)
            {
                
                mapOfDocuments.put('DSA', false);
            } 
            // DIGI-20864 End 
            if(priceScheduleenerated){
                mapOfDocuments.put('Price Schedule',false);
            }
            mapOfDocuments.put('BSA', false);
            mapOfDocuments.put('GPT',false);
            system.debug('inside if DSA'+mapOfDocuments);
            /* changes will go here - Creare new function to check if its Price schedule created on account based on product family 
// compare pricescheduleProductFamilies__c of all child contract (by going to account--> contract) with product family of marketable offer PF 
if present (contains), mark mapOfDocuments.put('Price Schedule', false); else market mapOfDocuments.put('Price Schedule', true);
ask question to ravi - what is the significance of version
- what is the significance of Contract Type 
*/
            return mapOfDocuments;
        }
        else{
            system.debug('isndei else');           
            mapOfDocuments.put('BSA', false);
            mapOfDocuments.put('DSA', false);
            mapOfDocuments.put('Price Schedule', false);
            for(ContractJunction__c contract:contractsForAccount){
                for(APXTConga4__Conga_Template__c template : otherFormsList){
                    //if(template.Type__c== 'General Product Terms' && contract.GPTVersion__c == template.Active_Template_Version__r.Version__c){
                    if(template.Type__c== PRMConstants.Contract_TemplateType_GeneralProductTerms && contract.GPTVersion__c == template.Active_Template_Version__r.Version__c){
                        system.debug('inside gpt loop');
                        mapOfDocuments.put('GPT',false);
                    }
                }
            }
            if(offNameSet != null && offNameSet.size()>0 ){
                List<Service_Term__c> stForAccountList = [SELECT Id,Account__c,Status__c,OFTVersion__c,ServiceTermName__c,ServiceTermTemplateName__c from Service_Term__c where Account__c = :basket.csbb__Account__c AND status__c NOT IN :inActiveServiceTermStatus];
                List<APXTConga4__Conga_Template__c> basketOfferFormsList= [Select id,Type__c,Active_Template_Version__c,Active_Template_Version__r.Version__c,Offer_Name__c  from APXTConga4__Conga_Template__c where Offer_Name__c IN :offNameSet];
                system.debug('stForAccountList --'+stForAccountList );
                system.debug('basketOfferFormsList--'+basketOfferFormsList);
                for(Service_Term__c st : stForAccountList){
                    for(APXTConga4__Conga_Template__c template : basketOfferFormsList){
            system.debug('st.ServiceTermName__c===>'+st.ServiceTermName__c);
            system.debug('template.Offer_Name__c===>'+template.Offer_Name__c);
                        if((st.status__c != 'Cancelled' || st.status__c !='Superseded') && template.Offer_Name__c == st.ServiceTermName__c && template.Active_Template_Version__r.Version__c == st.OFTVersion__c && st.ServiceTermName__c!=System.Label.PROFESSIONALSERVICES && st.ServiceTermName__c!=System.Label.TCPS_Offer_Name && st.ServiceTermName__c!='Mobility Managed Services' && st.ServiceTermName__c!='MDM Tenancy' ){
                            mapOfDocuments.put(template.Offer_Name__c,false);
                            stNameObjMap.put(st.ServiceTermName__c,st);
                            system.debug('final output terms--'+st.Id);
                            system.debug('mapOfDocuments final'+mapOfDocuments);
                            system.debug('final stNameObjMap--'+stNameObjMap);
                        }
                    }
                }
            }
            // EDGE-154519 - Condition to false GPT if DSA is enabled/
            if(isDSAOffer){
                mapOfDocuments.put('GPT',false);
            }                        
            return  mapOfDocuments;
        }
    }
    //EDGE-88882 ,97383, 97382 Service Terms UserStory
    //Generic Method to feth the list of templete ids to be generated corresponding to the offer in the basket
    public static map<string,APXTConga4__Conga_Template__c> tempalteIDGeneration(){
        map<string,APXTConga4__Conga_Template__c> offNamTidmap = new map<string,APXTConga4__Conga_Template__c>();
        //use offer_name field for unique values and not type Marketable_Offer__r.Offer_Id__c
        List<APXTConga4__Conga_Template__c> template = [select id,APXTConga4__Name__c,Offer_Name__c,Type__c,Sequence__c,Active_Template_Version__r.Version__c from APXTConga4__Conga_Template__c where APXTConga4__Template_Group__c ='Contract' AND Offer_Name__c != 'General' AND Offer_Name__c != null And Offer_Name__c!='Mobility Managed Services' And Offer_Name__c!='MDM Tenancy'];
        system.debug('inside templategen method');
        //if(offBoolMap.containsKey('GeneralServiceTerms')){
        for(APXTConga4__Conga_Template__c tc : template){
    system.debug('tc.Offer_Name__c==>'+tc.Offer_Name__c);
            offNamTidmap.put(tc.Offer_Name__c,tc);
        }
        // }
        return offNamTidmap;
    }
    /***** ORLANDO CODE CHANGE END***/
    private Integer getContractTermforBasket(sObject record){
        AggregateResult[] groupedResults = [SELECT Max(cscfga__Contract_Term__c) max FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Definition__r.Snapshot_Object__c != null AND cscfga__Product_Basket__c =: record.Id]; 
        return Integer.valueOf(groupedResults[0].get('max'));
    }
    
  
    
    /*
** @Author   :   Maqsood Alam
** @Date     :   Aug 2020
** @Desc     :   EDGE-165484 : <Contract runtime check for agreement/DSA in CALMS> Include the check for an (in effect) agreement in CALMS so we are able to refer to the single source of truth as CALMS agreement records.
**
*/
    public static map<String, boolean> getRelatedAgreementFlags(cscfga__Product_Basket__c basket, list<String> pcMarketablePF){
        Boolean isAgreementGeneratedDSA = false;
        Boolean isAgreementGeneratedBSA = false;
        Boolean isAgreementGeneratedPS = false;
        String recordTypePriceSchedule = 'Schedule';
        String recordTypeDSA = 'SA';
        String AgreementCategoryDSA = 'Digital Services';
        String AgreementCategoryBSA = 'Business Services';
        map<String, boolean> agreementFlags = new map<String, boolean>();
        // Price schedule record ---
        if(pcMarketablePF.size() > 0){
            list<Apttus__agreementlineitem__c> relatedAgreementLineItems = [SELECT  Id, Name, Apttus__agreementid__c, Apttus__agreementid__r.apttus__account__c, Apttus__agreementid__r.recordtype.name, Apttus__agreementid__r.apttus__agreement_category__c, Apttus__productid__c, Apttus__productid__r.marketable_product_family__c FROM Apttus__agreementlineitem__c WHERE Apttus__AgreementId__r.Apttus__Account__c=: basket.csbb__Account__c AND Apttus__productid__r.Name IN: pcMarketablePF AND Apttus__agreementid__r.recordtype.name =:  recordTypePriceSchedule]; 
            if(relatedAgreementLineItems.size() > 0){
                isAgreementGeneratedPS = true; 
            }
        }
        // DSA check ---
        list<Apttus__APTS_Agreement__c> relatedAgreementsDSA = [SELECT  Id, Name, apttus__account__c, recordtype.name, apttus__agreement_category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c=: basket.csbb__Account__c AND recordtype.name =: recordTypeDSA AND (Apttus__Agreement_Category__c =: AgreementCategoryBSA OR Apttus__Agreement_Category__c =: AgreementCategoryDSA) AND Apttus__Status__c !='Cancelled Request']; 
        if(relatedAgreementsDSA.size() > 0){
            for(Apttus__APTS_Agreement__c relatedAgreement: relatedAgreementsDSA){
                if(relatedAgreement.Apttus__Agreement_Category__c == AgreementCategoryDSA){
                    isAgreementGeneratedDSA = true;
                    // break;
                }
                if(relatedAgreement.Apttus__Agreement_Category__c == AgreementCategoryBSA){
                    isAgreementGeneratedBSA = true;
                    // break;
                }
            }
        }
        agreementFlags.put('isAgreementGeneratedDSA', isAgreementGeneratedDSA);
        agreementFlags.put('isAgreementGeneratedPS', isAgreementGeneratedPS);
        agreementFlags.put('isAgreementGeneratedBSA', isAgreementGeneratedBSA);
        system.debug( '<-->isDSAOffer--> ' +agreementFlags+ ' <<--relatedAgreementsDSA --> '+relatedAgreementsDSA );
        return agreementFlags;
    }
    /*
** @Author   :   Dheeraj Singh
** @Date     :   Nov 2020
** @Desc     :   to check if its an MAC basket and if account is related to dsa and ps then check its agreement line items contains the product family or not.
**
*/
    public boolean macAgreementlineItemCheck(Id accountId, list<String> pcMarketablePF){
        Boolean validAgreementlineItem = true;
        String recordTypePriceSchedule = 'Schedule';
        Set<String> productname = new Set<String>();
        List<Id> contractJunId = new List<Id>();
        if(pcMarketablePF.size() > 0){
            
            List<ContractJunction__c > ContractList = [select id ,Account__c,Related_Price_Schedule__c,name from ContractJunction__c where Account__c =:accountId ];
            for(ContractJunction__c conlist:ContractList ){
                contractJunId.add(conlist.Id);
            }
            list<Apttus__agreementlineitem__c> relatedAgreementLineItems = [SELECT Id, Name, Apttus__agreementid__c, Apttus__agreementid__r.apttus__account__c, Apttus__agreementid__r.recordtype.name, Apttus__agreementid__r.apttus__agreement_category__c, Apttus__productid__c,Apttus__ProductId__r.Telstra_Marketable_Product_Family__c  FROM Apttus__agreementlineitem__c WHERE Apttus__agreementid__r.recordtype.name =:  recordTypePriceSchedule and Apttus__AgreementId__r.Apttus__Parent_Agreement__r.Related_Contract__c in: contractJunId];
            
            
            
            
            
            if(relatedAgreementLineItems.size()>0){
                for(Apttus__agreementlineitem__c agreementline : relatedAgreementLineItems){
                    productname.add(agreementline.Apttus__ProductId__r.Telstra_Marketable_Product_Family__c);
                }
            }
            system.debug('productname === '+productname);
            for(String a:pcMarketablePF){
                if(!productname.contains(a)){
                    //validAgreementlineItem = false;//EDGE-193827-- As discussed with Napier Designer (Aakil) commenting this flag to run in variation case.
                    break;
                }
            }
            
        }
        system.debug('validAgreementlineItem :::' +validAgreementlineItem);
        return validAgreementlineItem;
        
        
    }
}
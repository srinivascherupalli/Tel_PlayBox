/**
* @Author     :   Maq
* @Date       :   Oct 2020
* @Desc       :   This class is written for agreement contract validation Records.
* @Initial US :   EDGE-184430
* @Status     :   Deveopment is still pending.
* 
* Shashank Jadhav: 07/04/2021 EDGE-203816-Price Schedule Apttus Contract:Updating DPR Offer on Agreement Line Items
* Shashank Jadhav:  13/07/2021 EDGE-221893-Insert Exception Log records with Exception Log Frameworks
* */
public with sharing class AgreementUtilities {
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    private static final String AGREEMENT_CATEGORY = 'Agreement Category';
    private static final String AGREEMENT_Subtype = 'Agreement Subtype';
    private static final String AGREEMENT_SUBCATEGORY = 'Agreement Subcategory';
    private static final String APPROVAL_STATUS = 'Approval Status';
    private static final String AUTO_RENEWAL = 'Auto Renewal';
    private static final String SOURCE = 'Source';
    private static final String TELSTRA_LEGAL_ENTITY = 'Telstra Legal Entity';
    private static final String VARIATION_SUMMARY_PAGE_NEEDED = 'Variation Summary Page Needed';
    private static final String AgreementCategoryBSA = 'Business Services';
    private static final string AgreementCategoryPricing='Pricing';
    
    private static final string subTypeDigital='Standard';
    private static final C2O_ExceptionHandler.Capability CONST_CAPABILITY = C2O_ExceptionHandler.Capability.AGR;//
    private static final String CONST_INTERFACENAME = 'AgreementCreation';//
    
    //EDGE-219001 Start
    private Static String emailTemplateUniqueName = 'DocuSign_for_Send_to_Customer';
    private Static String emailTemplateUniqueName2 = 'DocuSign_for_Send_to_Telstra';
    private static final Id DOCUSIGN_CONTACT_RECORDTYPEID = Schema.SObjectType.Apttus_DocuApi__DocuSignDefaultRecipient2__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    //EDGE-219001 End
    //EDGE-203816-Price Schedule Apttus Contract:Added by Shashank  
    public static Map<String,Id> mapOfPFWithDPRID=new Map<String,Id>();
    
    /**
* @Author   :   Maqsood Alam
* @Date     :   23 Nov 2020
* @Desc     :   
* @US       :   EDGE-184997
* @Status   :   Development
* */
    public static void AgreementUtilDetails( List<Delegated_Pricing_Request__c> dprRequest, List<DPR_Offer_Line_Item__c> relatedDPROLI) {
        try{//EDGE-221893:Added try block
        Map <String, List < agreementDetails >> flagAgreements =  New Map <String, List < agreementDetails >>();
        Id ParentAgreementId;
        Id psAgreementId;
        list<Id> agreementLineItemId;
        set<String> pFamily = new set<String>();
        Map<String,String> allConst = new Map<String,String>();
        allConst = getConstant();
        List<Apttus__APTS_Template__c> templateList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where (name =:allConst.get('DSATemplate') or name =:allConst.get('PriceScheduleTemplate')) and Apttus__IsActive__c = true and Apttus__Type__c= 'Agreement' ];
        Map<String,Id> templateMap = new Map<String,Id>();
        for(Apttus__APTS_Template__c temp:templateList){
            if(temp.name == allConst.get('DSATemplate')){
                templateMap.put(allConst.get('DSATemplate'), temp.Id);
            }
            else if(temp.name== allConst.get('PriceScheduleTemplate')){
                templateMap.put(allConst.get('PriceScheduleTemplate'),temp.Id);
            }
        }
        system.debug('templateMap == '+templateMap);
        if(dprRequest != NULL && dprRequest.size()> 0 && relatedDPROLI.size() > 0){
            if(relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId != NULL ){
                
                //-- get All Unique product family from DPR_OLI
                for(DPR_Offer_Line_Item__c oli : relatedDPROLI){
                    pFamily.add(oli.Marketable_Offer__r.Product_Family__c);
                    System.debug('pFamily='+oli.Marketable_Offer__r.Product_Family__c);
                    //EDGE-203816-Price Schedule Apttus Contract:Start
                    if(!mapOfPFWithDPRID.containsKey(oli.Marketable_Offer__r.Product_Family__c))
                        mapOfPFWithDPRID.put(oli.Marketable_Offer__r.Product_Family__c,oli.DPR_Offer__c);
                    //EDGE-203816-Price Schedule Apttus Contract:End
                }
                account accountDetails = new account();
                accountDetails.Id = relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId;
                //EDGE-200025-- start changes
                List<Apttus__APTS_Agreement__c> PSAgreementRecord=[select Id, Apttus__Account__c ,Name,Apttus__Term_Months__c,Apttus__Contract_End_Date__c, Apttus__FF_Agreement_Number__c, APTPS_Parent_Agreement_Id__c,Apttus__Status_Category__c, APTPS_Title__c,Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,APTPS_Agreement_Subcategory__c, Apttus__Parent_Agreement__c,createddate,Related_Basket__c,Apttus__Related_Opportunity__c,Auto_Created_by_Basket__c,APTPS_variationAdd__c,APTPS_VariationModify__c,PS_Variation_Details__c,Apttus__Version_Number__c,Variation_Applicable__c,APTPS_buyingWindow__c,Apttus__Contract_Start_Date__c,Apttus__Total_Contract_Value__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c IN: APTPS_Constants.apttusStatusCategory AND Apttus__Account__c =: accountDetails.Id AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId = :AGREEMENT_Schedule_RECORDTYPEID AND Variation_Applicable__c=true ORDER BY CreatedDate DESC LIMIT 1];
                if(PSAgreementRecord.size()>0){
                    if(String.isEmpty(PSAgreementRecord[0].PS_Variation_Details__c)==false &&  PSAgreementRecord[0].Variation_Applicable__c){ //// EDGE-194529-- Changes PS_Variation_Details__c field added
                        AgreementOrderDealUtilities.priceScheduleVariationCreateForOrderToDeal(dprRequest,relatedDPROLI,PSAgreementRecord[0]);
                    }
                    
                }//EDGE-200025-- End changes
                else{
                    
                    flagAgreements = checkExistingAgreementRecords(accountDetails);
                    System.debug('flagAgreements***********'+flagAgreements);
                    if (flagAgreements.containskey('DSA')) {
                        if (flagAgreements.get('DSA') != NULL && flagAgreements.get('DSA').size() > 0) {
                            system.debug('Inside DSA--->'+flagAgreements.get('DSA')); 
                            //-- Check for agreementLineItem record update
                            if (flagAgreements.get('PS') != NULL && flagAgreements.get('PS').size() > 0) {
                                if (flagAgreements.get('PS')[0].Id != null) { // Create Product Schedule agreement 
                                    if (relatedDPROLI != NULL && relatedDPROLI.size() > 0) {
                                        if (relatedDPROLI[0].Marketable_Offer__r.name != NULL) {
                                            agreementLineItemId = createAgreementLineItem(psAgreementId, pFamily);
                                        }
                                    }
                                }   
                                if (agreementLineItemId != null && agreementLineItemId.size() > 0) { //Create attribute on agreementLineitems
                                    createAttributeOnAgmtLineIem(relatedDPROLI, agreementLineItemId);
                                    //callGenerateAg
                                    generateAgreement(flagAgreements.get('PS')[0].Id, templateMap.get(allConst.get('PriceScheduleTemplate')));
                                } 
                                
                            }
                            else{
                                if (flagAgreements.get('DSA')[0].Id != null) {
                                    psAgreementId = createScheduleAgreement(NULL, dprRequest, flagAgreements.get('DSA')[0].Id);
                                }
                                if (psAgreementId != null) { // Create Product Schedule agreement 
                                    if (relatedDPROLI != NULL && relatedDPROLI.size() > 0) {
                                        if (relatedDPROLI[0].Marketable_Offer__r.name != NULL) {
                                            agreementLineItemId = createAgreementLineItem(psAgreementId, pFamily);
                                        }
                                    }
                                }
                                if (agreementLineItemId != null && agreementLineItemId.size() > 0) { //Create attribute on agreementLineitems
                                    createAttributeOnAgmtLineIem(relatedDPROLI, agreementLineItemId);
                                    generateAgreement(psAgreementId,templateMap.get(allConst.get('PriceScheduleTemplate')));
                                }
                                
                            }
                        }
                        else{
                            //-- Create new DSA Agreement
                            ParentAgreementId = createSAAgreement('DSA', NULL, dprRequest);
                            if(ParentAgreementId != null){
                                psAgreementId = createScheduleAgreement(NULL, dprRequest, ParentAgreementId);
                                //Call Generate Agreement  Params: ParentAgreementId 
                                generateAgreement(ParentAgreementId, templateMap.get(allConst.get('DSATemplate'))); 
                                
                            }
                            if(psAgreementId != null){ // Create Product Schedule agreement 
                                if(relatedDPROLI != NULL && relatedDPROLI.size()> 0){
                                    if(relatedDPROLI[0].Marketable_Offer__r.name != NULL ){
                                        agreementLineItemId = createAgreementLineItem(psAgreementId, pFamily);
                                    }    
                                }
                            }
                            if(agreementLineItemId != null && agreementLineItemId.size() > 0){ //Create attribute on agreementLineitems
                                createAttributeOnAgmtLineIem(relatedDPROLI, agreementLineItemId);
                                //Call Generate Agreement  Params: PSAgreementId 
                                generateAgreement(psAgreementId, templateMap.get(allConst.get('PriceScheduleTemplate'))); 
                            }
                        }
                    }
                    if (flagAgreements.containskey('BSA')) {
                        if (flagAgreements.get('BSA') != NULL && flagAgreements.get('BSA').size() > 0) {
                            system.debug('Inside BSA--->'+flagAgreements.get('BSA')); 
                        }
                    }
                }
                
            }
        }
        }catch(Exception ex){//EDGE-221893-Start
            logException('GenerateAgreement', '', '', ex.getMessage(), 'Generation of Agreement Document Failed.');
        }//EDGE-221893-End  
    }  
    
    
    
    
    public static map<String, boolean> validationForContractCreation( cscfga__Product_Basket__c basket, list<String> pcMarketablePF , String contractType) {    
        
        Boolean isAgreementGeneratedDSA = false;
        Boolean isAgreementGeneratedBSA = false;
        Boolean isAgreementGeneratedPS = false;
        String recordTypePriceSchedule = 'Schedule';
        String recordTypeDSA = 'SA';
        String AgreementCategoryDSA = 'Digital Services';
        
        //String AgreementCategoryBSA = 'Business Services';
        
        map<String, boolean> agreementFlags = new map<String, boolean>();
        // Price schedule record ---
        if(pcMarketablePF.size() > 0){
            list<Apttus__agreementlineitem__c> relatedAgreementLineItems = [SELECT  Id, Name, Apttus__agreementid__c, Apttus__agreementid__r.apttus__account__c, Apttus__agreementid__r.recordtype.name, Apttus__agreementid__r.apttus__agreement_category__c, Apttus__productid__c, Apttus__productid__r.marketable_product_family__c FROM Apttus__agreementlineitem__c WHERE Apttus__AgreementId__r.Apttus__Account__c=: basket.csbb__Account__c AND Apttus__productid__r.Name IN: pcMarketablePF AND Apttus__agreementid__r.recordtype.name =:  recordTypePriceSchedule]; 
            if(relatedAgreementLineItems.size() > 0){
                isAgreementGeneratedPS = true; 
            }
            system.debug( '<-->pcMarketablePF--> ' +pcMarketablePF+ ' <<--relatedAgreementLineItems --> '+relatedAgreementLineItems );
        }
        // DSA check ---
        list<Apttus__APTS_Agreement__c> relatedAgreementsDSA = [SELECT  Id, Name, apttus__account__c, recordtype.name, apttus__agreement_category__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__c=: basket.csbb__Account__c AND recordtype.name =: recordTypeDSA AND (Apttus__Agreement_Category__c =: AgreementCategoryBSA OR Apttus__Agreement_Category__c =: AgreementCategoryDSA) AND (Apttus__Status_Category__c = 'In Effect' AND Apttus__Status__c = 'Activated')]; 
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
    
    
    
    
    /**
* @Author   :   Rahul Asarma
* @Date     :   23 Nov 2020
* @Desc     :   This Method has written to check existing Agreement Available in Account
* @US       :   EDGE-176686
* @Status   :   Developed
* */
    public static Map <String, List < agreementDetails >> checkExistingAgreementRecords (Account account) {
        Map <String, Id> existingAgmtMap = new Map <String, Id> ();
        Map <String, List < agreementDetails >> agreementsMapDetails = new Map <String, List < agreementDetails >> ();
        List < agreementDetails > dsaAgmtRecord = new List < agreementDetails >();
        List < agreementDetails > bsaAgmtRecord = new List < agreementDetails >();
        List < agreementDetails > psAgmtRecord = new List < agreementDetails >();
        
        //EDGE-134661--APTPS_Constants.apttusStatusCategory moved in to APTPS_Constants
        List<Apttus__APTS_Agreement__c> existingAgreementOnAccount= [SELECT Id, RecordTypeId,name, Apttus__Agreement_Category__c,(select name,Product__c from Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c where Apttus__Status_Category__c IN : APTPS_Constants.apttusStatusCategory AND Apttus__Account__c = :account.Id AND Apttus__Status__c !='Cancelled Request'];
        System.debug(existingAgreementOnAccount.size());
        
        for(Apttus__APTS_Agreement__c agmt : existingAgreementOnAccount) {
            if (agmt.RecordTypeId == AGREEMENT_SA_RECORDTYPEID) { // logic for checking SA record presence
                if (agmt.Apttus__Agreement_Category__c == 'Digital Services') {
                    existingAgmtMap.put('DSA',agmt.Id);
                    agreementDetails agmtWrapper = new agreementDetails();
                    agmtWrapper.isPresentFlag = true;
                    agmtWrapper.Id = agmt.Id;
                    agmtWrapper.type = 'DSA';
                    agmtWrapper.agreementRecordDetails = agmt;
                    dsaAgmtRecord.add(agmtWrapper);
                    system.debug('>>> DSA present:'+agmt.Id) ;
                } else {
                    existingAgmtMap.put('BSA',agmt.Id);
                    system.debug('+++ BSA present:'+agmt.Id) ;
                    agreementDetails agmtWrapper = new agreementDetails();
                    agmtWrapper.isPresentFlag = true;
                    agmtWrapper.Id = agmt.Id;
                    agmtWrapper.type = 'BSA';
                    agmtWrapper.agreementRecordDetails = agmt;
                    bsaAgmtRecord.add(agmtWrapper);
                }
            } else if(agmt.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID) { // // logic for checking Price Schedule and its Agreement Line Items
                System.debug('### Price Schedule record present for Account :'+account.Id);
                if(agmt.Apttus__AgreementLineItems__r!=null){
                    for(Apttus__AgreementLineItem__c agrLineItems:agmt.Apttus__AgreementLineItems__r){
                        System.debug(agrLineItems.Product__c);
                        existingAgmtMap.put('PS-'+agrLineItems.Product__c,agmt.Id);
                        agreementDetails agmtWrapper = new agreementDetails();
                        agmtWrapper.isPresentFlag = true;
                        agmtWrapper.Id = agmt.Id;
                        agmtWrapper.type = 'PS';
                        agmtWrapper.agreementRecordDetails = agmt;
                        psAgmtRecord.add(agmtWrapper);
                    }
                }
            }            
        }
        agreementsMapDetails.put('DSA',dsaAgmtRecord);
        agreementsMapDetails.put('BSA',bsaAgmtRecord);
        agreementsMapDetails.put('PS',psAgmtRecord);
        system.debug('existingAgmtMap:'+existingAgmtMap);
        system.debug('agreementsMapDetails:----?>>>'+agreementsMapDetails);
        for (String item: existingAgmtMap.keySet()) System.debug ('=== item:'+item);
        
        return agreementsMapDetails;
    }
    /**
* @Author   :   Rahul Asarma
* @Date     :   23 Nov 2020
* @Desc     :   This Method has written to create DSA/BSA agreement records
* @US       :   EDGE-176686
* @Status   :   Development
* */
    public static Id createSAAgreement(String agmtString, Id agreementId, List<Delegated_Pricing_Request__c> dprRequest) {
        csconta__Frame_Agreement__c frameAgreement=null;
        
        List<FA_DefaultRecipients__c> faDefaultRecordlst=null;//EDGE-184432 Changes Added
        OpportunityContactRole oppContactRole=null;
        if(dprRequest != NULL && dprRequest.size()> 0){
            if(dprRequest[0].id != NULL ){
                frameAgreement = fetchFrameAgreement(dprRequest[0].id);
                faDefaultRecordlst=[Select id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c from FA_DefaultRecipients__c where Deal_Pricing_Request__c=:dprRequest[0].id order by createddate desc limit 1];//EDGE-184432 Added Query
                
            }
        }
        if (agreementId == null && frameAgreement!=null) {
            
            // create SA type agreement record
            Map < String, String > configMap = getConfiguration('Agreement_Head_Term');
            
            
            Apttus__APTS_Agreement__c AgmtRecord = new Apttus__APTS_Agreement__c();
            AgmtRecord.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            AgmtRecord.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            AgmtRecord.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            if(agmtString=='DSA'){
                AgmtRecord.APTPS_Show_After_E_Signature_Buttons__c=true;
                AgmtRecord.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            }
            else{
                AgmtRecord.Apttus__Agreement_Category__c = AgreementCategoryBSA;
            }
            AgmtRecord.Delegated_Pricing_Request__c =dprRequest[0].id;
            AgmtRecord.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecord.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            AgmtRecord.Apttus__Source__c = configMap.get(SOURCE);
            AgmtRecord.Apttus__Auto_Renew_Term_Months__c =1;
            
            
            
            AgmtRecord.RecordTypeId = AGREEMENT_SA_RECORDTYPEID;
            AgmtRecord.Apttus__Related_Opportunity__c = frameAgreement.Opportunity__c;
            AgmtRecord.Apttus__Account__c=frameAgreement.csconta__Account__c;
            AgmtRecord.Apttus__Term_Months__c = frameAgreement.Opportunity__r.Contract_Term__c;
            
            //EDGE-184432-- Changes Start
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_2__c!=null){
                AgmtRecord.APTPS_Sales_Account_Executive__c =  faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecord.APTPS_Contract_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecord.APTPS_Commercial_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecord.APTPS_Sales_Account_Executive_email__c=faDefaultRecordlst[0].Signatory_2__r.Email;
            }
            else{
                AgmtRecord.APTPS_Sales_Account_Executive__c =  frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecord.APTPS_Contract_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecord.APTPS_Commercial_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecord.APTPS_Sales_Account_Executive_email__c=frameAgreement.csconta__Account__r.Owner.Email;
            }
            AgmtRecord.Agreement_Owner__c=UserInfo.getUserId();
            
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_1__c!=null){
                AgmtRecord.APTPS_Customer_Primary_Contact__c = faDefaultRecordlst[0].Signatory_1__c;
                AgmtRecord.Apttus__Other_Party_Signed_By__c=faDefaultRecordlst[0].Signatory_1__c;
            }
            else{
                oppContactRole=fetchPrimaryContact(frameAgreement.Opportunity__c);
                if(oppContactRole!=null){
                    AgmtRecord.APTPS_Customer_Primary_Contact__c = oppContactRole.ContactId;
                    AgmtRecord.Apttus__Other_Party_Signed_By__c=oppContactRole.ContactId;
                }
                
            }
            //EDGE-184432-- Changes Start
            
            //AgmtRecord.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
            //AgmtRecord.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
            AgmtRecord.Apttus__Contract_Start_Date__c = system.today();//Putting start date due to template issue
            //AgmtRecord.Related_Contract__c = ContJun.Id;
            AgmtRecord.APTPS_Company_Signed_By__c=frameAgreement.csconta__Account__r.Ownerid;
            
            AgmtRecord.APTPS_Legacy_opportunity_ID__c = frameAgreement.Opportunity__c;
            AgmtRecord.APTPS_Payment_Terms_days__c = 30;
            
            insert AgmtRecord;
            
            //EDGE-184432-- Changes Start   
            agreementId=AgmtRecord.id;
            
            if(faDefaultRecordlst.size()>0){
                faDefaultRecordlst[0].Apttus_Agreement__c=AgmtRecord.id;
                update faDefaultRecordlst[0];
            }
            if(faDefaultRecordlst.size()>0)
                insertDocusignRecipient(AgmtRecord,faDefaultRecordlst[0],null);
            else 
                insertDocusignRecipient(AgmtRecord,null,oppContactRole);
            //EDGE-184432-- Changes End
            
        }
        // create junction record (FA Agreement association) with the DSA Agreement Id and FA Id
        
        system.debug('*****SA_Agreeement_ID******'+agreementId);
        if(agreementId!=null && frameAgreement.id!=null){
            
            Id frameAgreementAssociationId=frageAgreementAssociationRecoredCreation(agreementId,frameAgreement.id,false);
            system.debug('*****frameAgreementAssociationId*****'+frameAgreementAssociationId);
        }
        // Set agreement Meta data 
        //setAgreementMetaData(agreementId, frameAgmtId);        
        return agreementId;
    }
    /**
* @Author   :   Rahul Asarma
* @Date     :   23 Nov 2020
* @Desc     :   This Method has written to create Price Schedule agreement record
* @US       :   EDGE-176686
* @Status   :   Development
* */
    public static Id createScheduleAgreement(Id agreementId,  List<Delegated_Pricing_Request__c> dprRequest, String ParentAggrId) {
        // String productFamily = agmtString.substringAfter('PS-');
        csconta__Frame_Agreement__c frameAgreement=null;
        
        List<FA_DefaultRecipients__c> faDefaultRecordlst=null;//EDGE-184432 Added
        OpportunityContactRole oppContactRole=null;
        if(dprRequest != NULL && dprRequest.size()> 0){
            if(dprRequest[0].id != NULL ){
                frameAgreement = fetchFrameAgreement(dprRequest[0].id);
                faDefaultRecordlst=[Select id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c from FA_DefaultRecipients__c where Deal_Pricing_Request__c=:dprRequest[0].id order by createddate desc ];//EDGE-184432-- Query Added
                
            }
        }
        
        if (agreementId == null && frameAgreement!=null) {
            
            Account acc=[select id from Account where id=:frameAgreement.csconta__Account__c];
            Map < String, String > configMap = getConfiguration('Agreement_Schedule_Term');
            
            Apttus__APTS_Agreement__c AgmtRecordPS = new Apttus__APTS_Agreement__c();
            AgmtRecordPS.Apttus__Parent_Agreement__c=ParentAggrId;
            AgmtRecordPS.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            AgmtRecordPS.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            AgmtRecordPS.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            AgmtRecordPS.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            AgmtRecordPS.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecordPS.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            AgmtRecordPS.Apttus__Source__c = configMap.get(SOURCE);
            AgmtRecordPS.Apttus__Auto_Renew_Term_Months__c =1;
            AgmtRecordPS.Apttus__Subtype__c=subTypeDigital;
            
            
            AgmtRecordPS.RecordTypeId = AGREEMENT_Schedule_RECORDTYPEID;
            AgmtRecordPS.Apttus__Related_Opportunity__c = frameAgreement.Opportunity__c;
            AgmtRecordPS.Apttus__Account__c=frameAgreement.csconta__Account__c;
            AgmtRecordPS.Apttus__Term_Months__c = frameAgreement.Opportunity__r.Contract_Term__c;
            AgmtRecordPS.APTPS_buyingWindow__c=frameAgreement.Opportunity__r.Contract_Term__c;
            //EDGE-184432-- Changes Start 
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_2__c!=null){
                AgmtRecordPS.APTPS_Sales_Account_Executive__c =  faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecordPS.APTPS_Contract_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecordPS.APTPS_Commercial_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                AgmtRecordPS.APTPS_Sales_Account_Executive_email__c=faDefaultRecordlst[0].Signatory_2__r.Email;
            }
            else{
                AgmtRecordPS.APTPS_Sales_Account_Executive__c =  frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecordPS.APTPS_Contract_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecordPS.APTPS_Commercial_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecordPS.APTPS_Sales_Account_Executive_email__c=frameAgreement.csconta__Account__r.Owner.Email;
            }
            AgmtRecordPS.Agreement_Owner__c=UserInfo.getUserId();
            //
            AgmtRecordPS.Delegated_Pricing_Request__c =dprRequest[0].id;
            
            AgmtRecordPS.Apttus__Total_Contract_Value__c   =dprRequest[0].Total_Deal_Monthly_Value__c;
            
            
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_1__c!=null){
                AgmtRecordPS.APTPS_Customer_Primary_Contact__c = faDefaultRecordlst[0].Signatory_1__c;
                AgmtRecordPS.Apttus__Other_Party_Signed_By__c=faDefaultRecordlst[0].Signatory_1__c;
            }
            else{
                oppContactRole=fetchPrimaryContact(frameAgreement.Opportunity__c);
                if(oppContactRole!=null){
                    AgmtRecordPS.APTPS_Customer_Primary_Contact__c = oppContactRole.ContactId;
                    AgmtRecordPS.Apttus__Other_Party_Signed_By__c=oppContactRole.ContactId;
                }
                
            }
            //EDGE-184432-- Changes End
            
            //AgmtRecordPS.Apttus__Contract_End_Date__c = ContJun.Original_End_Date__c;
            //AgmtRecordPS.APTPS_Effective_End_Date__c = ContJun.Effective_End_Date__c;
            AgmtRecordPS.Apttus__Contract_Start_Date__c = system.today();//Putting start date due to template issue
            //AgmtRecordPS.Related_Contract__c = ContJun.Id;
            AgmtRecordPS.APTPS_Company_Signed_By__c=frameAgreement.csconta__Account__r.Ownerid;
            
            AgmtRecordPS.APTPS_Legacy_opportunity_ID__c = frameAgreement.Opportunity__c;
            AgmtRecordPS.APTPS_Payment_Terms_days__c = 30;
            
            insert AgmtRecordPS;
            agreementId=AgmtRecordPS.id;
            
            //EDGE-184432-- Changes Start 
            if(faDefaultRecordlst.size()>0)
                insertDocusignRecipient(AgmtRecordPS,faDefaultRecordlst[0],null);
            else 
                insertDocusignRecipient(AgmtRecordPS,null,oppContactRole);
            //EDGE-184432-- Changes End
            
            
            //}
        }
        system.debug('*****PS_Agreeement_ID******'+agreementId);
        return agreementId;
    }
    /**

* @Author   :   Rahul Asarma
* @Date     :   21 Dec 2020
* @Desc     :   This Method has written to create docusignRecipients
* @US       :   EDGE-184432
* @Status   :   Development
* */
    public static void insertDocusignRecipient(Apttus__APTS_Agreement__c AgreementRecord,FA_DefaultRecipients__c faDefaultRecord,OpportunityContactRole oppContactRole){
        Id DOCUSIGN_CONTACT_RECORDTYPEID = Schema.SObjectType.Apttus_DocuApi__DocuSignDefaultRecipient2__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        String emailTemplateUniqueName = 'DocuSign_for_Send_to_Customer';
        String emailTemplateUniqueName2 = 'DocuSign_for_Send_to_Telstra';
        String singer1 = 'Signer 1';
        String singer2 = 'Signer 2';
        List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docusignRecpList = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        if(faDefaultRecord!=null){
            Apttus_DocuApi__DocuSignDefaultRecipient2__c ds = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
            ds.Apttus_DocuApi__FirstName__c = faDefaultRecord.Signatory_1__r.FirstName;
            ds.Apttus_DocuApi__LastName__c = faDefaultRecord.Signatory_1__r.LastName;
            ds.Apttus_DocuApi__Email__c = faDefaultRecord.Signatory_1__r.Email;
            ds.Apttus_DocuApi__ContactId__c = faDefaultRecord.Signatory_1__c;
            ds.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
            ds.Apttus_CMDSign__AgreementId__c = AgreementRecord.Id;
            ds.Apttus_DocuApi__AccountId__c = AgreementRecord.Apttus__Account__c;
            ds.Apttus_DocuApi__RoleName__c = singer1;
            ds.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplateUniqueName;
            ds.Apttus_DocuApi__SigningOrder__c = 1;
            docusignRecpList.add(ds);
            
            Apttus_DocuApi__DocuSignDefaultRecipient2__c dsr = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
            dsr.Apttus_DocuApi__FirstName__c = faDefaultRecord.Signatory_2__r.FirstName;
            dsr.Apttus_DocuApi__LastName__c = faDefaultRecord.Signatory_2__r.LastName;
            dsr.Apttus_DocuApi__Email__c = faDefaultRecord.Signatory_2__r.Email;
            dsr.Apttus_DocuApi__UserId__c = faDefaultRecord.Signatory_2__c;
            dsr.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
            dsr.Apttus_CMDSign__AgreementId__c = AgreementRecord.Id;
            dsr.Apttus_DocuApi__AccountId__c = AgreementRecord.Apttus__Account__c;
            dsr.Apttus_DocuApi__RoleName__c = singer2;
            dsr.Apttus_DocuApi__EmailTemplateUniqueName__c = EmailTemplateUniqueName2;
            dsr.Apttus_DocuApi__SigningOrder__c = 2;
            docusignRecpList.add(dsr);
        }
        else{
            Apttus_DocuApi__DocuSignDefaultRecipient2__c ds = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
            if(oppContactRole!=null){
                ds.Apttus_DocuApi__FirstName__c = oppContactRole.Contact.FirstName;
                ds.Apttus_DocuApi__LastName__c = oppContactRole.Contact.LastName;
                ds.Apttus_DocuApi__Email__c = oppContactRole.Contact.Email;
                ds.Apttus_DocuApi__ContactId__c = oppContactRole.ContactId;
                ds.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                ds.Apttus_CMDSign__AgreementId__c = AgreementRecord.Id;
                ds.Apttus_DocuApi__AccountId__c = AgreementRecord.Apttus__Account__c;
                ds.Apttus_DocuApi__RoleName__c = singer1;
                ds.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplateUniqueName;
                ds.Apttus_DocuApi__SigningOrder__c = 1;
                docusignRecpList.add(ds);
            }
            if(AgreementRecord.APTPS_Sales_Account_Executive__c!=null){
                User userDetails=[select id,FirstName,LastName from User where id=:AgreementRecord.APTPS_Sales_Account_Executive__c limit 1];
                Apttus_DocuApi__DocuSignDefaultRecipient2__c dsr = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                dsr.Apttus_DocuApi__FirstName__c = userDetails.FirstName;
                dsr.Apttus_DocuApi__LastName__c = userDetails.LastName;
                dsr.Apttus_DocuApi__Email__c = AgreementRecord.APTPS_Sales_Account_Executive_email__c;
                dsr.Apttus_DocuApi__UserId__c = AgreementRecord.APTPS_Sales_Account_Executive__c;
                dsr.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                dsr.Apttus_CMDSign__AgreementId__c = AgreementRecord.Id;
                dsr.Apttus_DocuApi__AccountId__c = AgreementRecord.Apttus__Account__c;
                dsr.Apttus_DocuApi__RoleName__c = singer2;
                dsr.Apttus_DocuApi__EmailTemplateUniqueName__c = EmailTemplateUniqueName2;
                dsr.Apttus_DocuApi__SigningOrder__c = 2;
                docusignRecpList.add(dsr);
            }
            
        }
        if(!docusignRecpList.isEmpty()){
            insert docusignRecpList;
        }       
        
    }
    /**

* @Author   :   Maqsood Alam
* @Date     :   23 Nov 2020
* @Desc     :   This method has written to create Attribute on Agreement Line item
* @US       :   EDGE-184997
* @Status   :   Development
* */
    public static Id createAttributeOnAgmtLineIem(list<DPR_Offer_Line_Item__c> relatedDPROLI, list<Id> agreementLineItems){
        list<APTPS_Component__c> listAttributes = New list<APTPS_Component__c>();
        List<id> dprIdforRateCard= new List<id> ();
        map<id,id> dprlineitemwithapttusRateCardMap= null;
        Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
        List<DPR_Rate_Card__c> dprRateCardList=[SELECT Id,DPR_Rate_Card_Name__c,Parent_DPR_OLI_id__c,Parent_DPR_OLI_id__r.Product_Family__c,                                            Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,Parent_DPR_Rate_Card_ID__c,Rate_Card__r.name, DPR_RC_Negotiated_Value__c,                                              DPR_Rate_Card_Type__c  from DPR_Rate_Card__c where Parent_DPR_OLI_id__c in: relatedDPROLI order by DPR_Rate_Card_Name__c asc];
        if(dprRateCardList.size()>0){
            dprlineitemwithapttusRateCardMap=AgreementApttusRateCardUtilities.createApttusRateCard(dprRateCardList);
        }
        
        for(Apttus__agreementlineitem__c agmtLineItem : [SELECT  Id, Name, Apttus__productid__c, Apttus__productid__r.Name FROM Apttus__agreementlineitem__c WHERE Id IN : agreementLineItems]){
            for(DPR_Offer_Line_Item__c oli : relatedDPROLI){
                If(oli.Marketable_Offer__r.Product_Family__c == agmtLineItem.Apttus__productid__r.Name && oli.DPR_Offer_Line_Item_Type__c == 'Plan'){
                    APTPS_Component__c attribute = new APTPS_Component__c();
                    attribute.DPR_Offer_Line_Item__c=oli.id;
                    
                    //attribute.APTPS_Attribute__c = agmtLineItem.Name;
                    attribute.APTPS_Attribute__c = oli.Name;
                    /*if((mapRateCardSlab.keySet()).contains((oli.Marketable_Offer__r.Product_Family__c).replaceAll(' ','_'))){
dprIdforRateCard.add(oli.id);
}*/
                    if(dprlineitemwithapttusRateCardMap!=null){
                        if(dprlineitemwithapttusRateCardMap.get(oli.id)!=null){
                            attribute.Apttus_Rate_Card__c=dprlineitemwithapttusRateCardMap.get(oli.id);
                        }
                    }
                    attribute.APTPS_Original_Value__c = oli.Offer_Type_Name__c;
                    attribute.Agreement_Line_Item__c = agmtLineItem.Id;
                    attribute.Type__c = oli.Offer_Type__r.Type__C;
                    attribute.Value__c = String.valueOf(oli.DPR_Offer_Line_Item_Value__c);
                    listAttributes.add(attribute);
                }
            }
        }
        if(listAttributes!= NULL && listAttributes.size() > 0){
            Insert listAttributes;
            /* if(dprIdforRateCard.size()>0){
//AgreementApttusRateCardUtilities.createApttusRateCard(dprIdforRateCard);
}*/
        }      
        system.debug('*****listAttributes******'+listAttributes);    
        return null;       
    }
    /**
* @Author   :   Rahul Asarma
* @Date     :   23 Nov 2020
* @Desc     :   This method has written to create Agreement Line item
* @US       :   EDGE-184997
* @Status   :   Development
* */
    public static list<Id> createAgreementLineItem(Id agreementId, set<String> productFamily){
        List<Apttus__agreementlineitem__c> insertAgreementlineitems= new List<Apttus__agreementlineitem__c>(); 
        List<Apttus__AgreementLineItem__c> agreementLineItemslist=[select name,Product__c from Apttus__AgreementLineItem__c where Product__c=:productFamily and Apttus__AgreementId__c=:agreementId];
        String productName = '';
        try{//EDGE-221893: Added try block
        if(agreementLineItemslist.size()==0 && agreementId!=null){
            list<Product2> prodReclst = [SELECT id, Name FROM Product2 where name  =: productFamily];
            Set<Product2> prodrec = new Set<Product2>(prodReclst);//Create a function for product retrieval:Refactor EDGE-219001
            system.debug('@@@@@@set '+prodrec);
            if(prodrec.size()>0){
                for(Product2 prod: prodrec){
                    if(productName != prod.Name){//Change product name to custom field Telstra_Marketable_Product_Family__c.Refactor EDGE-219001
                        productName = prod.Name;  
                        Apttus__agreementlineitem__c AgreementLineItem = new Apttus__agreementlineitem__c();
                        AgreementLineItem.Apttus__AgreementId__c =agreementId;
                        AgreementLineItem.Apttus__ProductId__c = prod.Id;
                        AgreementLineItem.isNegotiated__c=true;
                        //EDGE-203816-Add DPR Offer-Start
                        if(!mapOfPFWithDPRID.isEmpty() && mapOfPFWithDPRID.containsKey(prod.Name))
                            AgreementLineItem.DPR_Offer__c = mapOfPFWithDPRID.get(prod.Name);
                        //EDGE-203816-Add DPR Offer-End
                        insertAgreementlineitems.add(AgreementLineItem);
                    }   
                }
            }
            system.debug('valueofinsertAgreementlineitems'+insertAgreementlineitems.size());
            if(insertAgreementlineitems.size()>0){
                insert insertAgreementlineitems;
            }
            list<id> agmtLineItemIds = new list<id>();
            for(Apttus__agreementlineitem__c agmtLI : insertAgreementlineitems){
                agmtLineItemIds.add(agmtLI.Id);
            }
            system.debug('*****agmtLineItemIds******'+agmtLineItemIds);  
            return agmtLineItemIds;
        }
        }catch(Exception ex){//EDGE-221893-Start
            logException('GenerateAgreement', '', agreementId, ex.getMessage(), 'Generation of Agreement Document Failed.');
        }//EDGE-221893-End  
        return null;       
    }
    
    
    
    
    //This method has written to fetch Frame Agreement Record
    public static csconta__Frame_Agreement__c fetchFrameAgreement(String dprId) {
        
        String queryFrameAgreement ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('csconta__Frame_Agreement__c'))+ ',csconta__Account__r.Ownerid,csconta__Account__r.Owner.Email,Opportunity__r.Contract_Term__c  FROM csconta__Frame_Agreement__c WHERE Delegated_Pricing_Request__c =: dprId order by lastmodifieddate desc limit 1'; 
        
        system.debug('@@@@@@queryFrameAgreement--> '+queryFrameAgreement);
        return Database.query(queryFrameAgreement);
    }
    //This method has written to fetch fetchPrimaryContact
    public static OpportunityContactRole fetchPrimaryContact (String opptyId) {
        
        OpportunityContactRole primaryContact =[select id,ContactId,Contact.Email,Contact.FirstName,Contact.LastName from OpportunityContactRole where OpportunityId=:opptyId and IsPrimary=true limit 1]; 
        if(primaryContact!=null)
            return primaryContact;
        else 
            return null;
    }
    
    
    
    public static Map < String, String > getConfiguration(String configName) {
        
        Map < String, String > configMap = new Map < String, String > ();
        try {
            Contract_Generation_Setting__mdt config = getContractGenerationSettings(configName);
            if (config != null) {
                configMap.put(AGREEMENT_CATEGORY, config.Agreement_Category__c);
                configMap.put(AGREEMENT_SUBCATEGORY, config.Agreement_Subcategory__c);
                configMap.put(AGREEMENT_Subtype, config.Apttus_Subtype__c);
                configMap.put(APPROVAL_STATUS, config.Approval_Status__c);
                configMap.put(AUTO_RENEWAL, ConversionUtils.booleanToString(config.Auto_Renew__c));
                configMap.put(VARIATION_SUMMARY_PAGE_NEEDED, ConversionUtils.booleanToString(config.Variation_Summary_Page_Needed__c));
                configMap.put(SOURCE, config.Source__c);
                configMap.put(TELSTRA_LEGAL_ENTITY, config.Addresses_for_Notices__c);
            }
        }
        catch(Exception e) {
            return null;
        }
        return configMap;
    }
    private static Contract_Generation_Setting__mdt getContractGenerationSettings(String hName) {
        
        Contract_Generation_Setting__mdt contractGenerationSettingRecord = New Contract_Generation_Setting__mdt();
        String queryStr = ' SELECT ' + String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('Contract_Generation_Setting__mdt')) + '\n ' + ' FROM Contract_Generation_Setting__mdt \n ' + ' WHERE DeveloperName = \'' + String.escapeSingleQuotes(hName) + '\' LIMIT 1 ';
        List < Contract_Generation_Setting__mdt > contractGenerationSettingRecordList = Database.query(queryStr);
        if (contractGenerationSettingRecordList != null && !contractGenerationSettingRecordList.isEmpty() && contractGenerationSettingRecordList.get(0) != null) {
            contractGenerationSettingRecord = contractGenerationSettingRecordList.get(0);
        }
        return contractGenerationSettingRecord;
    }
    
    /**
* @Author   :   Rahul Asarma
* @Date     :   23 Nov 2020
* @Desc     :   This method has written to create  Frame Agreement and dsa Agreement Association record
* @US       :   EDGE-184997
* @Status   :   Development
* */
    public static Id frageAgreementAssociationRecoredCreation(Id agreementId, Id frameAgreementId,Boolean variationApplicable){
        
        FA_Agreement_Association__c fa_agreeement_assRecord= new FA_Agreement_Association__c();
        fa_agreeement_assRecord.Agreement__c=agreementId;
        fa_agreeement_assRecord.FA__c=frameAgreementId;
        if(variationApplicable)
            fa_agreeement_assRecord.Variation_Applicable__c=true;
        
        insert fa_agreeement_assRecord;
        
        return fa_agreeement_assRecord.id;
        
    }
    //EDGE-184429
    /**
* @Author   :   Monali Golhar
* @Date     :   23 Nov 2020
* @Desc     :   API call to generate attachment 
* @US       :   EDGE-184429
* @Status   :   Development
* */
    @Future(callout=true)
    public static void  generateAgreement(Id agreementId, Id templateId)
    {
        String apiSessionId = getSessionId(); 
        String pLevel = 'Insert comments and tracked changes only'; 
        String docFormat = 'DOCX'; 
        String apiServerURL =  getapiServerURL();
        Id generatedDocId ;
        try
        {
            System.debug('Inside the method agreementId: '+ agreementId);
            System.debug(' Inside the method templateId: '+ templateId);
            System.debug(' UserId ' +apiSessionId);
            if(!Test.isRunningTest()){
                generatedDocId = Apttus.MergeWebService.generateDoc(templateId, agreementId,pLevel, docFormat, apiSessionId, apiServerURL);  
            }
            system.debug('generatedDocId ===  '+generatedDocId );
        }//EDGE-134661--Changes Start
        catch(CalloutException ex)
        {
            System.debug(' generatedDocId ex: ' + ex);
            logException('GenerateAgreement', '', agreementId, ex.getMessage(), 'Generation of Agreement Document Failed.');
        }
        catch(Exception ex)
        {
            String ErrorMsg='';
            if(ex.getMessage()=='Attempt to de-reference a null object' && agreementId==null){
                ErrorMsg='Attempt to de-reference a null object Becuase Agreement Id Is NULL';
            }
            else if(ex.getMessage()=='Attempt to de-reference a null object' && templateId==null){
                ErrorMsg='Attempt to de-reference a null object Becuase templateId Is NULL';
            }
            else{
                ErrorMsg=ex.getMessage();
            }
            logException('GenerateAgreement', '', agreementId, ErrorMsg, 'Generation of Agreement Document Failed.');
            System.debug(' generatedDocId ex: ' + ex);
            
        }//EDGE-134661--Changes End
    }
    //EDGE-184429
    public static string getSessionId(){
        System.debug(' UserId ' + UserInfo.getSessionId());
        return UserInfo.getSessionId();
        
    }
    public static string getapiServerURL(){
        System.debug(' apiServerURL ' + System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId());
        return System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId();
        
    }
    public class agreementDetails {
        @AuraEnabled
        public Boolean isPresentFlag {get { if(isPresentFlag == null ) isPresentFlag=false; return isPresentFlag;  } Set;}
        @AuraEnabled
        public string Id { get; set; }
        @AuraEnabled
        public string type { get; set; }
        @AuraEnabled
        public Apttus__APTS_Agreement__c agreementRecordDetails { get; set; }
    }
    public static Map<String,String> getConstant(){
        Map<String,String> allConst = new Map<String,String>(); 
        try{
            AllCQEnvironmentVariable cqpVariables = new AllCQEnvironmentVariable();
            list<String> productSpecCodes = new List<String>(AllCQEnvironmentVariable.getValueAsList('ApexConstant'));
            system.debug(productSpecCodes); 
            allConst = new Map<String,String>(); 
            List<String> constKeyValueList = null; 
            for(String v:productSpecCodes){
                constKeyValueList = v.split(':'); 
                allConst.put(constKeyValueList[0],constKeyValueList[1]);
            }
            system.debug('***Telstra:DealQuoteHandler:getConstant:allConst'+allConst); 
            return allConst; 
        }
        catch(Exception e){   
            System.debug('***Telstra:DealQuoteHandler:getConstant:exception:'+e.getLineNumber()+' '+e.getMessage()); 
        } 
        return allConst; 
    }
    //EDGE-134661 Changes Start- this function has added for log exeption//
    public static void logException(String methodName, String referenceNumber, String correlationId, String errorMessage, String businessDescription){
        Map<String, Object> eLogMap = new Map<String, Object>();
        eLogMap.put('capability', CONST_CAPABILITY);
        eLogMap.put('interfaceName', CONST_INTERFACENAME);
        eLogMap.put('elementName', methodName);
        eLogMap.put('referenceNumber', referenceNumber);
        eLogMap.put('correlationId', correlationId);
        eLogMap.put('errorDescription', errorMessage);
        eLogMap.put('businessDescription', businessDescription);
        C2O_Utilities.logException(eLogMap, false);
    }
    
    //EDGE-134661 Changes End- this function has added for log exeption//
    
    //EDGE-219001 Start
    
    public static list<Id> createAgreementLineItem_RF(Id agreementId, set<String> productFamily, Map<String,Id> mapOfPFWithDPRID){
        List<Apttus__agreementlineitem__c> insertAgreementlineitems = new List<Apttus__agreementlineitem__c>();
        list<id> agmtLineItemIds = new List<id>();
        list<Product2> prodReclst = [SELECT id, Name FROM Product2 where Telstra_Marketable_Product_Family__c  IN: productFamily and IsActive=true];// Throw an exception if prodReclst is empty ************
        Set<Product2> prodrec = new Set<Product2>(prodReclst);//Create a function for product retrieval:Refactor EDGE-219001
        try{
            system.debug('@@@@@@set '+prodrec);
            if(prodrec.size()>0){
                for(Product2 prod: prodrec){
                    Apttus__agreementlineitem__c AgreementLineItem = new Apttus__agreementlineitem__c();
                    AgreementLineItem.Apttus__AgreementId__c =agreementId;
                    AgreementLineItem.Apttus__ProductId__c = prod.Id;
                    if(mapOfPFWithDPRID!=null && mapOfPFWithDPRID.containsKey(prod.Name)){
                        AgreementLineItem.isNegotiated__c = true ; 
                        AgreementLineItem.DPR_Offer__c = mapOfPFWithDPRID.get(prod.Name);
                    }
                    
                    insertAgreementlineitems.add(AgreementLineItem);
                }
            }
            system.debug('valueofinsertAgreementlineitems'+insertAgreementlineitems.size());
            if(insertAgreementlineitems.size()>0){
                insert insertAgreementlineitems;
            }
            
            for(Apttus__agreementlineitem__c agmtLI : insertAgreementlineitems){
                agmtLineItemIds.add(agmtLI.Id);
            }
            system.debug('*****agmtLineItemIds******'+agmtLineItemIds);  
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Agreement line items creation failed in class AgreementUtilities at line no:'+ex.getLineNumber()+ 'for Agreement Id:'+agreementId;
            AgreementException agEx = new AgreementException('createAgreementLineItem_RF',string.valueOf(agreementId),ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
        return agmtLineItemIds;
    }
    public static Apttus__APTS_Agreement__c createSAAgreement(String agmtCategory) {
        system.debug('Inside child createSAAgreement ');
        Map < String, String > configMap = getConfiguration('Agreement_Head_Term'); 
        Apttus__APTS_Agreement__c AgmtRecord = new Apttus__APTS_Agreement__c();
        try{
            
            AgmtRecord.Apttus__Agreement_Category__c = agmtCategory;
            
            AgmtRecord.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecord.Apttus__Contract_Start_Date__c = system.today();
            AgmtRecord.APTPS_Show_After_E_Signature_Buttons__c=true;
            AgmtRecord.RecordTypeId = AGREEMENT_SA_RECORDTYPEID;
            AgmtRecord.Apttus__Source__c = APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL;
        }
        catch(Exception ex){
            String referenceNumber = '';
            String businessDescriptionEX = 'Creation of SA agreement record failed in class AgreementUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('createSAAgreement',referenceNumber,ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
        return AgmtRecord;
    }
    
    public static Apttus__APTS_Agreement__c createPSAgreement(Apttus__APTS_Agreement__c parentSAAgreement) {
        Map < String, String > configMap = getConfiguration('Agreement_Schedule_Term');
        Apttus__APTS_Agreement__c AgmtRecordPS = new Apttus__APTS_Agreement__c();
        try{
            AgmtRecordPS = parentSAAgreement.clone(false);
            AgmtRecordPS.Apttus__Parent_Agreement__c=parentSAAgreement.id;
            AgmtRecordPS.RecordTypeId = AGREEMENT_Schedule_RECORDTYPEID;
            AgmtRecordPS.Apttus__Agreement_Category__c = configMap.get(AGREEMENT_CATEGORY);
            AgmtRecordPS.APTPS_Agreement_Subcategory__c = configMap.get(AGREEMENT_SUBCATEGORY);
            AgmtRecordPS.Apttus__Subtype__c=subTypeDigital;
            AgmtRecordPS.Apttus__Contract_Start_Date__c = system.today();
            AgmtRecordPS.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
            AgmtRecordPS.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
            AgmtRecordPS.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
            AgmtRecordPS.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
            AgmtRecordPS.Apttus__Source__c = configMap.get(SOURCE);
            AgmtRecordPS.Apttus__Auto_Renew_Term_Months__c =1;
            AgmtRecordPS.Agreement_Owner__c=UserInfo.getUserId();
            AgmtRecordPS.APTPS_Payment_Terms_days__c = 30;
            AgmtRecordPS.Apttus__Source__c = APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL;
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Creation of PS agreement for SA Agreement Id:'+ parentSAAgreement.Id +' failed in class AgreementUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('createPSAgreement',String.valueOf(parentSAAgreement.Id),ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
        return AgmtRecordPS;
    }
    
    public static void insertDocusignRecipients(List<Apttus__APTS_Agreement__c> agmts,sObject customerContact,sObject CompanyContact){
        Id DOCUSIGN_CONTACT_RECORDTYPEID = Schema.SObjectType.Apttus_DocuApi__DocuSignDefaultRecipient2__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
        List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docusignRecpList = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
        List<Id> signerList = new List<Id>();
        List<Contact> c1ist = new List<Contact>();
        List<User> ulist = new List<User>();
        String signer2 = 'Signer 2';
        String signer3 = 'Signer 3';
        try{
            for(Apttus__APTS_Agreement__c agmtRec:agmts){
                if(customerContact != null ){
                    Apttus_DocuApi__DocuSignDefaultRecipient2__c ds = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                    ds.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                    ds.Apttus_CMDSign__AgreementId__c = agmtRec.Id;
                    ds.Apttus_DocuApi__AccountId__c = agmtRec.Apttus__Account__c;
                    ds.Apttus_DocuApi__FirstName__c = (String)customerContact.get('FirstName');
                    ds.Apttus_DocuApi__LastName__c = (String)customerContact.get('LastName');
                    ds.Apttus_DocuApi__Email__c = (String)customerContact.get('Email');
                    ds.Apttus_DocuApi__ContactId__c = customerContact.Id;
                    ds.Apttus_DocuApi__RoleName__c = signer2;
                    ds.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplateUniqueName;
                    ds.Apttus_DocuApi__SigningOrder__c = 2;  // EDGE-211362
                    docusignRecpList.add(ds);
                    
                }
                if(CompanyContact != null ){
                    Apttus_DocuApi__DocuSignDefaultRecipient2__c dsr = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                    dsr.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                    dsr.Apttus_CMDSign__AgreementId__c = agmtRec.Id;
                    dsr.Apttus_DocuApi__AccountId__c = agmtRec.Apttus__Account__c;
                    dsr.Apttus_DocuApi__FirstName__c = (String)CompanyContact.get('FirstName');
                    dsr.Apttus_DocuApi__LastName__c = (String)CompanyContact.get('LastName');
                    dsr.Apttus_DocuApi__Email__c = (String)CompanyContact.get('Email');
                    dsr.Apttus_DocuApi__UserId__c = CompanyContact.Id;
                    dsr.Apttus_DocuApi__RoleName__c = signer3;
                    dsr.Apttus_DocuApi__EmailTemplateUniqueName__c = EmailTemplateUniqueName2;
                    dsr.Apttus_DocuApi__SigningOrder__c = 3;// EDGE-211362
                    docusignRecpList.add(dsr);
                }
            }
            if(!docusignRecpList.isEmpty()){
                insert docusignRecpList;
            }
        } catch(Exception ex){
            String businessDescriptionEX = 'Insertion of docusign recipient failed for Customer contact:'+customerContact.id+'in class AgreementUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('insertDocusignRecipients', customerContact.id, ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }   
        
    }

        /**
    * @Author   :   Lokesh Thathuru
    * @Date     :   10 Aug 2021
    * @Desc     :   This Method helps to create the case 
    * @US       :   DIGI-434
    * @Status   :   Development
    * */
    public static Case generateContractSupportCase( String caseDescription,String aCMUserIdorCMGUserId,String subject,Id opportunityId){
        Id contractSupportRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Contract Support').getRecordTypeId();  
        
        final  string PRODUCT_BASKET = 'Product Basket';
        final string BASKET_ISSUE ='Basket Issue';       
        final string CASE_PRIORITY ='High';
        final string CASE_STATUS ='New';
        final string CASE_SEVERITY ='Medium';
        
        Case newCaseInstance=new Case();
        //newCaseInstance.AccountId=AccountId;
        newCaseInstance.Subject=subject;
        newCaseInstance.Description=caseDescription;
        newCaseInstance.OwnerId=aCMUserIdorCMGUserId;
        newCaseInstance.RecordTypeId=contractSupportRecordTypeId;
        newCaseInstance.Priority = CASE_PRIORITY;
        newCaseInstance.Status = CASE_STATUS;
        newCaseInstance.Severity__c = CASE_SEVERITY;
        //newCaseInstance.AccountId=accountId; //No required to set 
        newCaseInstance.OpportunityId__c=opportunityId;
        //System.debug('AccounId::'+newCaseInstance.AccountId);
        newCaseInstance.Feedback_Related_to__c = PRODUCT_BASKET;
        newCaseInstance.Feedback_Category__c = BASKET_ISSUE;
        
        

        return newCaseInstance;
    }




    //EDGE-219001 End
    public class AgreementDecision {
        
        @AuraEnabled
        public string sourceType { get; set; }
        @AuraEnabled
        public string saType { get; set; }
        @AuraEnabled
        public boolean variationRequired { get; set; }
        @AuraEnabled
        public string moType { get; set; }
        @AuraEnabled
        public string optyCtrType { get; set; }
        @AuraEnabled
        public string parentPSAgreement { get; set; }
        @AuraEnabled
        public string parentSAAgreement { get; set; }
        @AuraEnabled
        public list<String> PFDifferenceList { get; set; }
        /* This Variables are removed as a part of DIGI-434 by Lokesh Thathuru : as discussed with aniket and monali
        @AuraEnabled
        public list<String> PFDifferenceListAdd { get; set; } // remove
        @AuraEnabled
        public list<String> PFDifferenceListModify{ get; set; }      // remove*/
        @AuraEnabled
        public list<String> parentSAList{ get; set; }     
        @AuraEnabled
        public boolean caseCreation{ get; set; } 
        //Added this collection to store the  Legacy matched ProductFamilies   - DIGI-434 start  
        @AuraEnabled
        public Set<String> legacyPFMatchedSet{get;set;}
        @AuraEnabled
        public String caseNumber {get;set;} 
        //End DIGI-434  
         @AuraEnabled
        public string RCAgreement { get; set; }
        @AuraEnabled
        public string DigBSARelatedAccount{ get; set; }  
         @AuraEnabled
        public string ApttusStatusCategory{ get; set; } 
        @AuraEnabled
        public boolean isPSVariation { get; set; }
    } 
}
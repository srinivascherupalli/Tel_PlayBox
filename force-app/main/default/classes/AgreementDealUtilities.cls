/**
* @Author     :   Monali Golhar 
* @Date       :   Jul 2021
* @Desc       :   This class contains methods required for creating Agreement records in a Deal journey .
* @Initial US :   EDGE-224019, EDGE-219001 - Capability 1499
* @Status     :   Deveopment is still pending.
* 
* Monali Golhar: 10/07/2021 EDGE-224019, EDGE-219001 - Refactor the Deal Agreement creation based on the condition flow setout in Cap-1499
* Lokesh Thathuru : 11-aug-2021 DIGI-434 Case Creation code is plugged when the legacy contract are detected.
* Parmanand Shete : DIGI-10002 RCS Agreement record creation
* Ankush Rana : DIGI-11813 As a Contract Manager, I would like the ability to have a Related Company Schedule to hold the list of related companies so that users can produce a related company BSA
* Shivprasad patil : DIGI-11225 RCS variation creation
* Lokesh Thathuru : 27-aug-2021 DIGI-7386
* Monali Golhar : 17/09/2021 //DIGI-23440 FIX
* Vishal Arbune : DIGI-11226 : Technical story - dissociate all related Companies in Apttus
* Lokesh Thathuru : DIGI-19273 
* */

public class AgreementDealUtilities {
    private static final String TELSTRA_LEGAL_ENTITY = 'Telstra Legal Entity';
    private static final String AUTO_RENEWAL = 'Auto Renewal';
    private static final String VARIATION_SUMMARY_PAGE_NEEDED = 'Variation Summary Page Needed';
    private static final String APPROVAL_STATUS = 'Approval Status';
    private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    private static final Id AGREEMENT_RCS_RECORDTYPEID  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
    private static final string subTypeDigital='Digital';
    private static final String AGREEMENT_Status_CATEGORY = 'In Effect';
    private static final String AGREEMENT_Status = 'Being Amended';
    public static Map<String,Id> mapOfPFWithDPRID=new Map<String,Id>();
    public static String RCDeltaName;
    
    public static void createAgreementRecords(List<Delegated_Pricing_Request__c> dprRequest, List<DPR_Offer_Line_Item__c> relatedDPROLI,AgreementUtilities.AgreementDecision agmtDecResult) {
        System.debug(' inside :: AgreementDealUtilities.createAgreementRecords');
        Integer startTime = System.Now().millisecond();
        try{
            if(agmtDecResult == null){
                agmtDecResult = resolveSAType(dprRequest[0]); 
            }
            Apttus__APTS_Agreement__c agmtSA;
            Apttus__APTS_Agreement__c agmtPS;
            Apttus__APTS_Agreement__c agmtRCS;
            List<Id> aliIds ; 
            List<Apttus__APTS_Agreement__c> agmts;
            List<Apttus__APTS_Agreement__c> saagmts = new List<Apttus__APTS_Agreement__c>();
            List<FA_DefaultRecipients__c> faDefaultRecordlst;
            OpportunityContactRole oppContactRole ; 
            
            
            faDefaultRecordlst = fetchFADefaultRecipientList(dprRequest);
            oppContactRole = fetchOpportunityContactRole(dprRequest);
            csconta__Frame_Agreement__c frameAgreement = AgreementUtilities.fetchFrameAgreement(dprRequest[0].id);
            if(agmtDecResult.caseCreation != null && agmtDecResult.caseCreation == true ){
                //CaseCreation moved to SobjectLookupController for Deal Flow.
            }
            else if(agmtDecResult.variationRequired != true ){ 
                System.debug(' inside :: AgreementDealUtilities.createAgreementRecords :: new block ');
                agmtSA = createSAAgreement(NULL, dprRequest , faDefaultRecordlst , oppContactRole, frameAgreement); 
                saagmts.add(agmtSA);
                agmtPS = createPSAgreement(agmtSA); 
                //DIGI-10002
                Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
                if(Ted_115){
                    agmtRCS = createRCAgreement(frameAgreement,agmtSA);
                }
                //end DIGI-10002
                mapOfPFWithDPRID = getProductFamilyVsDPRId(relatedDPROLI);
                aliIds = createPSAgreementLineItems(agmtPS.Id,mapOfPFWithDPRID.keySet(), mapOfPFWithDPRID);
                agmts = new List<Apttus__APTS_Agreement__c>{agmtSA,agmtPS};
                    if(faDefaultRecordlst != null && faDefaultRecordlst.size()> 0) { // move to the main method 
                        // DIGI-19273 Start Added IF Condition // (FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe')
                        if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign')  && saagmts[0].Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                            insertDocusignRecipients(faDefaultRecordlst[0], oppContactRole, saagmts); 
                        }
                    }
                else{ // DIGI-19273 Added "{" and added the below condition (FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe')
                    if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign') && saagmts[0].Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                        insertDocusignRecipients(NULL, oppContactRole, saagmts); 
                    }
                } //END DIGI-1927 "}"
                createAttributeOnAgmtLineIem(relatedDPROLI,aliIds);
                generateAgreement(agmts); 
            }
            else if(agmtDecResult.variationRequired == true ){
                set < String > productFamilySet = new  set < String >(); 
                set < String > existingPF = new set < String > ();
                set < String > existingPFClone = new set < String > ();
                Id psAgreementId;
                Id accountId;
                accountId =relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId;
                Boolean isRCSVariation = false;
                Apttus__APTS_Agreement__c rcsAgreement,parentAgreement;
                
                /* [SELECT id, NAME,Delegated_Pricing_Request__r.Opportunity__r.AccountId, DPR_Offer__R.NAME, Offer_Type__c, Offer_Type_Name__c, Marketable_Offer__r.name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c, Offer_Type__r.Type__C, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Value__c, DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c =: dprRequest[0].Id] */
                for(DPR_Offer_Line_Item__c relatedDPROL : relatedDPROLI ){
                    productFamilySet.add(relatedDPROL.Marketable_Offer__r.Product_Family__c);
                } 
                for (Apttus__APTS_Agreement__c agreementPS: [SELECT Id, RecordTypeId, name,APTPS_Customer_Primary_Contact__c,Apttus__Account__c, Apttus__APTS_Agreement__c.Apttus__Status__c,Apttus__APTS_Agreement__c.Apttus__Status_Category__c,Apttus__Agreement_Category__c,Apttus__Parent_Agreement__c,Apttus__Term_Months__c, Delegated_Pricing_Request__c, Delegated_Pricing_Request__r.Total_Deal_Monthly_Manual_Value__c, (SELECT Name, Product__c FROM Apttus__AgreementLineItems__r),(Select APTPS_Account__c from Related_Companies__r) FROM Apttus__APTS_Agreement__c WHERE Apttus__Status_Category__c IN: APTPS_Constants.apttusStatusCategory AND Apttus__Account__c =: accountId AND Apttus__Status__c != 'Cancelled Request' /*AND Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c =:agreementCategory */  ORDER BY CreatedDate DESC/* LIMIT 1*/]) {
                    psAgreementId = agreementPS.Id;
                    if(agreementPS.Apttus__Parent_Agreement__c == null){
                        parentAgreement = agreementPS;
                    }
                    if (agreementPS.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID && agreementPS.Apttus__AgreementLineItems__r != null) {
                        for (Apttus__AgreementLineItem__c agrLineItems: agreementPS.Apttus__AgreementLineItems__r) {
                            existingPF.add(agrLineItems.Product__c);
                        }
                    }
                    system.debug('#######'+agreementPS.Apttus__Status_Category__c+'#########'+agreementPS.RecordTypeId+'##########'+agreementPS.Related_Companies__r);
                    if (agreementPS.RecordTypeId == AGREEMENT_RCS_RECORDTYPEID && agreementPS.Apttus__Status_Category__c == APTPS_Constants.IN_EFFECT_STATUS_CATEGORY) {
                        
                        rcsAgreement = agreementPS;
                    }
                }
                //DIGI-11225
                Boolean Ted_115 = Test.IsRunningTest()? true : FeatureEligibilityChecker.determineFeatureEligiblity('TED_115','');
                if(Ted_115){
                    if(rcsAgreement != null){
                        Boolean isShared = ContentDocumentLinkContract.shareAgreementVariation(rcsAgreement.Id);
                        system.debug('########'+isShared);
                        isRCSVariation = isRCSVariationRequired(frameAgreement,rcsAgreement,agmtDecResult.parentSAAgreement,dprRequest,agmtDecResult.isPSVariation);
                    }else{
                        system.debug('Parent agreement ->'+parentAgreement);
                        agmtRCS = createRCAgreement(frameAgreement,parentAgreement);
                        if(!agmtDecResult.isPSVariation){
                            AgreementUtilities.frageAgreementAssociationRecoredCreation(parentAgreement.Id,frameAgreement.id,true);
                        }
                        //DIGI-40120 Start
                        if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign') && agmtRCS.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL){
                            if(faDefaultRecordlst != null && faDefaultRecordlst.size()> 0) {
                                system.debug('Insert docusign receipient faDefaultRecordlst->'+faDefaultRecordlst);
                                AgreementUtilities.insertDocusignRecipient(agmtRCS,faDefaultRecordlst[0],null); 
                            }
                            else{ 
                                system.debug('Insert docusign receipient oppContactRole->'+oppContactRole);
                                AgreementUtilities.insertDocusignRecipient(agmtRCS, NULL, oppContactRole); 
                            }
                        }
						//DIGI-40120 End
                    }
                }
                //end DIGI-11225
                
                system.debug('########isRCSVariation'+isRCSVariation);
                existingPFClone = existingPF.clone();
                System.debug('*****existingPFClone*****' + existingPFClone);
                List < agreementVariationDetails > psVarAgmtDetails = new List < agreementVariationDetails >();
                for (String masterPF: productFamilySet) {
                    if (existingPF != NULL) {
                        if(existingPF.contains(masterPF) && existingPF != NULL){
                            agreementVariationDetails agmtVarWrapper = new agreementVariationDetails();
                            agmtVarWrapper.Product = masterPF;
                            agmtVarWrapper.ALI = 'Y';
                            agmtVarWrapper.Attribute = 'Y';
                            agmtVarWrapper.VariationAdd = null;
                            agmtVarWrapper.VariationModify = masterPF;
                            psVarAgmtDetails.add(agmtVarWrapper);
                            existingPFClone.remove(masterPF);
                            
                        }
                        else if(!existingPF.contains(masterPF) && existingPF != NULL){
                            agreementVariationDetails agmtVarWrapper = new agreementVariationDetails();
                            agmtVarWrapper.Product = masterPF;
                            agmtVarWrapper.ALI = 'Y';
                            agmtVarWrapper.Attribute = 'Y';
                            agmtVarWrapper.VariationAdd = masterPF;
                            agmtVarWrapper.VariationModify = null;
                            psVarAgmtDetails.add(agmtVarWrapper);
                            
                            
                        }
                    }
                }
                if (existingPF != NULL){
                    for (String finalPF: existingPFClone) {
                        agreementVariationDetails agmtVarWrapper = new agreementVariationDetails();
                        agmtVarWrapper.Product = finalPF;
                        agmtVarWrapper.ALI = 'Y';
                        agmtVarWrapper.Attribute = 'N';
                        agmtVarWrapper.VariationAdd = null;
                        agmtVarWrapper.VariationModify = null;
                        psVarAgmtDetails.add(agmtVarWrapper);
                    }
                }
                system.debug('psVarAgmtDetails::'+ psVarAgmtDetails);   
                
                // update agreement with variationProductFamily    
                Map<Id,Id> amendedAgmts= new Map<Id,Id>();
                Boolean isShared = ContentDocumentLinkContract.shareAgreementVariation(agmtDecResult.parentPSAgreement);
                Apttus__APTS_Agreement__c psAgmtUpdate = new Apttus__APTS_Agreement__c();
                psAgmtUpdate.Id = agmtDecResult.parentPSAgreement; 
                psAgmtUpdate.PS_Variation_Details__c = string.valueof(JSON.serialize(psVarAgmtDetails)); 
                psAgmtUpdate.APTPS_Validation_on_Fully_Signed__c = true;
                psAgmtUpdate.Variation_Applicable__c = true;
                
                if(isShared == true)
                    update psAgmtUpdate;
                if(agmtDecResult.isPSVariation){
                    priceScheduleVariationCreateForOrderToDeal(dprRequest , relatedDPROLI, psAgmtUpdate, isRCSVariation);
                }
                
            }
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            system.debug('######Exception######'+ ex.getMessage());
            String methodName = 'createAgreementRecords' ; 
            String referenceNumber = ''; 
            String errorMessage =  ex.getMessage(); 
            system.debug('exception-->'+errorMessage+ ' Line number->' +ex.getLineNumber());
            String businessDescriptionEX = 'class AgreementDealUtilities.createAgreementRecords at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
        Integer endTime = System.Now().millisecond();
        System.debug ('#### AgreementDealUtilities::CreateAgreementRecords execution finished in '+ (endTime-startTime)/1000 +' seconds');
        
        
        
    }
    public static Apttus__APTS_Agreement__c setAgreementData(Apttus__APTS_Agreement__c PSAgreement, Delegated_Pricing_Request__c drpRecord,csconta__Frame_Agreement__c frameAgreement,List<FA_DefaultRecipients__c> faDefaultRecordlst, OpportunityContactRole oppContactRole){
        
        //System.debug('faDefaultRecordlst[0].Signatory_1__c**'+faDefaultRecordlst[0].Signatory_1__c);
        if(drpRecord!=null){
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_2__c!=null){
                PSAgreement.APTPS_Sales_Account_Executive__c =  faDefaultRecordlst[0].Signatory_2__c;
                PSAgreement.APTPS_Contract_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                PSAgreement.APTPS_Commercial_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                PSAgreement.APTPS_Sales_Account_Executive_email__c=faDefaultRecordlst[0].Signatory_2__r.Email;
            }
            else{
                PSAgreement.APTPS_Sales_Account_Executive__c =  frameAgreement.csconta__Account__r.Ownerid;
                PSAgreement.APTPS_Contract_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                PSAgreement.APTPS_Commercial_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                /*      for(User o : [SELECT Id, Email FROM User WHERE Id =: frameAgreement.csconta__Account__r.Ownerid]){
PSAgreement.APTPS_Sales_Account_Executive_email__c=o.Email;
} */
                // PSAgreement.APTPS_Sales_Account_Executive_email__c=frameAgreement.csconta__Account__r.Owner.Email;
            }
            
            if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_1__c!=null){
                System.debug('Inside FADefaultLoop**'+faDefaultRecordlst[0].Signatory_1__c);
                PSAgreement.APTPS_Customer_Primary_Contact__c = faDefaultRecordlst[0].Signatory_1__c;
                PSAgreement.Apttus__Other_Party_Signed_By__c=faDefaultRecordlst[0].Signatory_1__c;
            }
            else{
                if(oppContactRole!=null){
                    PSAgreement.APTPS_Customer_Primary_Contact__c = oppContactRole.ContactId;
                    PSAgreement.Apttus__Other_Party_Signed_By__c=oppContactRole.ContactId;
                }
                
            }
        }
        
        
        return PSAgreement;
    }
    public static List<FA_DefaultRecipients__c> fetchFADefaultRecipientList(List<Delegated_Pricing_Request__c> dprRequest){
        List<FA_DefaultRecipients__c> faDefaultRecordlst = null ;
        try{
            System.debug('dprRequest'+dprRequest[0].Id);
            if(dprRequest != NULL && dprRequest.size()> 0){
                if(dprRequest[0].id != NULL ){
                    String dprId = dprRequest[0].id;
                    //  frameAgreement = fetchFrameAgreement(dprId);
                    faDefaultRecordlst=[SELECT id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c 
                                        FROM FA_DefaultRecipients__c 
                                        WHERE Deal_Pricing_Request__c=:dprRequest[0].id  AND Signatory_1__c != null AND Signatory_2__c != null
                                        ORDER BY createddate desc limit 1];//EDGE-184432 Added Query //DIGI-23440 FIX
                    
                }
            }
            return faDefaultRecordlst; 
        }
        catch(Exception ex){
            String methodName = 'AgreementDealUtilities.fetchFADefaultRecipientList';
            String ReferenceNumber = '';
            if(dprRequest != null)
                referenceNumber = String.valueof(dprRequest[0].Id);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of FA_DefaultRecipients__c record creation failed in class AgreementDealUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    public static OpportunityContactRole fetchOpportunityContactRole(List<Delegated_Pricing_Request__c> dprRequest){
        csconta__Frame_Agreement__c frameAgreement ; 
        OpportunityContactRole oppContactRole ; 
        try{
            System.debug('dprRequest'+ dprRequest[0].Id);
            if(dprRequest != NULL && dprRequest.size()> 0){
                if(dprRequest[0].id != NULL ){
                    String dprId = dprRequest[0].id;
                    frameAgreement = fetchFrameAgreement(dprId);
                }
            }
            oppContactRole=  AgreementUtilities.fetchPrimaryContact(frameAgreement.Opportunity__c) ;
            return oppContactRole; 
        }
        catch(AgreementException agEx){
            throw agEx;
        }
        catch(Exception ex){
            String methodName = 'AgreementDealUtilities.fetchOpportunityContactRole';
            String referenceNumber = '';
            if(dprRequest != null)
                referenceNumber = String.valueof(dprRequest[0].Id);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of FA_DefaultRecipients__c record creation failed in class AgreementDealUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);                        
            throw agEx; 
        }
    }
    
    //Create SA
    public static Apttus__APTS_Agreement__c createSAAgreement(Id agreementId, List<Delegated_Pricing_Request__c> dprRequest, List<FA_DefaultRecipients__c> faDefaultRecordlst, OpportunityContactRole oppContactRole ,csconta__Frame_Agreement__c frameAgreement ) {
        Apttus__APTS_Agreement__c agmtSA;
        try{
            String agmtCat = '';
            for(Opportunity opp : [SELECT Id, Contract_Type__c FROM Opportunity WHERE Id = : dprRequest[0].Opportunity__c]){
                If(opp.Contract_Type__c == 'DSA')
                    agmtCat = APTPS_Constants.DSA_AGMT_CATEGORY;
                else if(opp.Contract_Type__c == 'BSA')
                    agmtCat = APTPS_Constants.BSA_AGMT_CATEGORY; 
            }
            
            system.debug('dprRequest[0]'+ dprRequest[0] +'dprRequest[0].Opportunity__c'+ dprRequest[0].Opportunity__c);
            system.debug('dprRequest[0].Opportunity__r.Contract_Type__c'+dprRequest[0].Opportunity__r.Contract_Type__c+'APTPS_Constants.DSA_AGMT_CATEGORY '+APTPS_Constants.DSA_AGMT_CATEGORY+'agmtCat '+ agmtCat);
            agmtSA = AgreementUtilities.createSAAgreement(agmtCat); 
            system.debug('agmtSA'+ agmtSA);
            updateSAAgreementForDealFlow(agmtSA , dprRequest , faDefaultRecordlst , oppContactRole);
            AgreementUtilities.frageAgreementAssociationRecoredCreation(agmtSA.Id,frameAgreement.id,true);
            
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'AgreementDealUtilities.createSAAgreement';
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of SA agreement record failed in class AgreementDealUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            
            throw agEx; 
        }
        return agmtSA;
    }
    public static void updateSAAgreementForDealFlow(Apttus__APTS_Agreement__c agmtRecord, List<Delegated_Pricing_Request__c> dprRequest, List<FA_DefaultRecipients__c> faDefaultRecordlst, OpportunityContactRole oppContactRole ) {
        csconta__Frame_Agreement__c frameAgreement=null;
        List<Apttus__APTS_Agreement__c> agmtList = new List<Apttus__APTS_Agreement__c>(); 
        try{
            if(dprRequest != NULL && dprRequest.size()> 0){
                if(dprRequest[0].id != NULL ){
                    String dprId = dprRequest[0].id;
                    frameAgreement = fetchFrameAgreement(dprId);
                }
            }
            if (AgmtRecord != null && frameAgreement!=null) {
                // create SA type agreement record
                Map < String, String > configMap = AgreementUtilities.getConfiguration('Agreement_Head_Term');
                //  Apttus__APTS_Agreement__c AgmtRecord = new Apttus__APTS_Agreement__c();
                //  AgmtRecord.Id = agreementId.Id;
                AgmtRecord.APTPS_Telstra_Legal_Entity__c = configMap.get(TELSTRA_LEGAL_ENTITY);
                AgmtRecord.Apttus__Auto_Renewal__c = ConversionUtils.stringtoBoolean(configMap.get(AUTO_RENEWAL));
                AgmtRecord.APTPS_Variation_Summary_Page__c = ConversionUtils.stringtoBoolean(configMap.get(VARIATION_SUMMARY_PAGE_NEEDED));
                AgmtRecord.Delegated_Pricing_Request__c =dprRequest[0].id;
                AgmtRecord.Apttus_Approval__Approval_Status__c = configMap.get(APPROVAL_STATUS);
                //    AgmtRecord.Apttus__Source__c = configMap.get(SOURCE); // currently internal aper will be internal digital 
                AgmtRecord.Apttus__Auto_Renew_Term_Months__c =1;
                AgmtRecord.Apttus__Related_Opportunity__c = frameAgreement.Opportunity__c;
                AgmtRecord.Apttus__Account__c=frameAgreement.csconta__Account__c;
                AgmtRecord.Apttus__Term_Months__c = frameAgreement.Opportunity__r.Contract_Term__c;
                
                //EDGE-184432-- Changes Start
                if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_2__c!=null){
                    AgmtRecord.APTPS_Sales_Account_Executive__c =  faDefaultRecordlst[0].Signatory_2__c;
                    AgmtRecord.APTPS_Contract_Manager__c = faDefaultRecordlst[0].Signatory_2__c; // This is already getting set  DIGI-19273
                    AgmtRecord.APTPS_Commercial_Manager__c = faDefaultRecordlst[0].Signatory_2__c;
                    AgmtRecord.APTPS_Sales_Account_Executive_email__c=faDefaultRecordlst[0].Signatory_2__r.Email;
                }
                else{
                    AgmtRecord.APTPS_Sales_Account_Executive__c =  frameAgreement.csconta__Account__r.Ownerid;
                    AgmtRecord.APTPS_Contract_Manager__c = frameAgreement.csconta__Account__r.Ownerid; // This is already getting set  DIGI-19273
                    AgmtRecord.APTPS_Commercial_Manager__c = frameAgreement.csconta__Account__r.Ownerid;
                    AgmtRecord.APTPS_Sales_Account_Executive_email__c=frameAgreement.csconta__Account__r.Owner.Email;
                }
                AgmtRecord.Agreement_Owner__c=UserInfo.getUserId();
                
                if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_1__c!=null){
                    AgmtRecord.APTPS_Customer_Primary_Contact__c = faDefaultRecordlst[0].Signatory_1__c;
                    AgmtRecord.Apttus__Other_Party_Signed_By__c=faDefaultRecordlst[0].Signatory_1__c;
                    AgmtRecord.Apttus__Primary_Contact__c=faDefaultRecordlst[0].Signatory_1__c; // This is added as a part if DIGI-19273
                }
                else{
                    // oppContactRole=AgreementUtilities.fetchPrimaryContact(frameAgreement.Opportunity__c);
                    if(oppContactRole!=null){
                        AgmtRecord.APTPS_Customer_Primary_Contact__c = oppContactRole.ContactId;
                        AgmtRecord.Apttus__Other_Party_Signed_By__c=oppContactRole.ContactId;
                        AgmtRecord.Apttus__Primary_Contact__c=oppContactRole.ContactId; // This is added as a part if DIGI-19273
                    }
                    
                }
                //EDGE-184432-- Changes Start
                AgmtRecord.APTPS_Company_Signed_By__c=frameAgreement.csconta__Account__r.Ownerid;
                AgmtRecord.APTPS_Legacy_opportunity_ID__c = frameAgreement.Opportunity__c;
                AgmtRecord.APTPS_Payment_Terms_days__c = 30;
                //DIGI-7386 Logic  started
                //Feature Toggle is Enabled for the below code
                Boolean enableExaminFeatureForDealFlow=FeatureEligibilityChecker.determineFeatureEligiblity('ExaminDPROLSaleEligibilityForDealFlow', 'ExaminDPROLSaleEligibilityForDealFlow');
                System.debug('examinDPROLICommercialProductSaleEligibility 01'+enableExaminFeatureForDealFlow);
                if(enableExaminFeatureForDealFlow){
                    AgmtRecord = examinDPROLICommercialProductSaleEligibility(dprRequest[0].id, AgmtRecord);
                }
                //DIGI-7386 End
                insert AgmtRecord;
                System.debug('AgmtRecord -->'+AgmtRecord);
                agmtList.add(AgmtRecord); 
                if(faDefaultRecordlst.size()>0){ 
                    faDefaultRecordlst[0].Apttus_Agreement__c=AgmtRecord.id;
                    update faDefaultRecordlst[0];
                }
                
            }
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'AgreementDealUtilities.updateSAAgreementForDealFlow';
            String referenceNumber = String.valueof(agmtRecord.Id);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of SA agreement record failed in class AgreementDealUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            
            throw agEx; 
        }
    }
    public static void insertDocusignRecipients(FA_DefaultRecipients__c faDefaultRecipient , OpportunityContactRole oppContactRole ,List<Apttus__APTS_Agreement__c> agmts ){
        try{
            sObject customerContact ; 
            sObject companyContact ; 
            if(faDefaultRecipient != null){
                customerContact = [SELECT Id,Email,Phone,Fax,Owner.Title,FirstName,LastName FROM Contact WHERE Id=:  faDefaultRecipient.Signatory_1__c];
                companyContact = [SELECT Id,Email,Phone,FirstName,LastName FROM User WHERE Id=: faDefaultRecipient.Signatory_2__c];
            }
            else if(oppContactRole != null){
                customerContact = [SELECT Id,Email,Phone,Fax,Owner.Title,FirstName,LastName FROM Contact WHERE Id=: oppContactRole.ContactId];
                companyContact = [SELECT Id,Email,Phone,FirstName,LastName FROM User WHERE Id=: agmts[0].APTPS_Sales_Account_Executive__c]; //Check again 
            }
            System.debug('AgreementDealUtilities:insertDocusignRecipients:CreatedAgreement'+customerContact); 
            AgreementUtilities.insertDocusignRecipients(agmts,customerContact,companyContact);
            System.debug('AgreementDealUtilities:insertDocusignRecipients:CreatedAgreement'); 
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'insertDocusignRecipients';
            String referenceNumber = '';
            if(agmts != null)
                referenceNumber = agmts[0].Id;
            String errorMessage =  ex.getMessage();
            String businessDescription = 'Insertion of docusign recipients failed for agreements related to contract id:'+ referenceNumber  +' in class AgreementDealUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescription);
            throw agEx;  
        }
    }
    //This method has written to fetch Frame Agreement Record
    public static csconta__Frame_Agreement__c fetchFrameAgreement(String dprId) {
        try{
            String queryFrameAgreement ='SELECT '+String.escapeSingleQuotes(SObjectHelper.getFieldListForSOQL('csconta__Frame_Agreement__c'))+ ',csconta__Account__r.Ownerid,csconta__Account__r.Owner.Email,Opportunity__r.Contract_Term__c  FROM csconta__Frame_Agreement__c WHERE Delegated_Pricing_Request__c =: dprId order by lastmodifieddate desc limit 1'; 
            system.debug('@@@@@@queryFrameAgreement--> '+queryFrameAgreement);
            return Database.query(queryFrameAgreement);
        }
        catch(Exception ex){
            String methodName = 'fetchFrameAgreement';
            String referenceNumber = '' ;
            if(dprId != null)
                referenceNumber = dprId;
            String errorMessage =  ex.getMessage();
            String businessDescription = 'There is error in fetching frame agreements in fetchFrameAgreement'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescription);
            throw agEx;  
        }
    } 
    //CreatePS 
    public static Apttus__APTS_Agreement__c createPSAgreement(Apttus__APTS_Agreement__c agmtSA){
        Apttus__APTS_Agreement__c agmtPS;
        try{
            agmtPS = AgreementUtilities.createPSAgreement(agmtSA);
            //    updatePSAgreementforDealFlow(agmtPS);
            agmtPS.APTPS_buyingWindow__c = agmtPS.Apttus__Term_Months__c; 
            agmtPS.Apttus__Total_Contract_Value__c = agmtPS.Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c;
            insert agmtPS;
            System.debug('AgreementDealUtilities:createPSAgreement:updatePSAgreementforDealFlow:CreatedAgreement'+agmtPS); 
            //            insert agmtPS;
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'createPSAgreement';
            String referenceNumber = '';
            if(agmtSA != null)
                referenceNumber = String.valueOf(agmtSA.Id);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of PS agreement for SA Agreement Id:'+ referenceNumber  +' failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
        return agmtPS;
    }
    //DIGI-10002
    public static Apttus__APTS_Agreement__c createRCAgreement(csconta__Frame_Agreement__c frameAgreement,Apttus__APTS_Agreement__c agmtSA){
        Apttus__APTS_Agreement__c agmtRCS;
        try{
            Id rcsRecordTypeId  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Related_Company_Schedule').getRecordTypeId();
            Apttus__APTS_Agreement__c parentAgrment = [select id,Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c,Apttus__Source__c,(select id,RecordTypeId,Apttus__Status_Category__c from Apttus__Agreements__r where RecordTypeId =:rcsRecordTypeId and Apttus__Status_Category__c != 'In Effect')  from Apttus__APTS_Agreement__c where id=:agmtSA.Id];
            List<Apttus__APTS_Agreement__c> agreementListToUpdate = new List<Apttus__APTS_Agreement__c>();
            system.debug('child RCS agrment ->'+parentAgrment.Apttus__Agreements__r.size());
            list<csconta__Account_Frame_Agreement_Association__c> listFrameAgrmtAss = [select ID, csconta__Account__c, csconta__Account__r.Name from csconta__Account_Frame_Agreement_Association__c where csconta__Frame_Agreement__c =:frameAgreement.Id];
            system.debug('listFrameAgrmtAss.size()->'+listFrameAgrmtAss.size());
            system.debug('parent Apttus__Source__c->'+parentAgrment.Apttus__Source__c);
            if(parentAgrment.Apttus__Agreements__r.size()==0 && listFrameAgrmtAss.size() > 0 && parentAgrment.Apttus__Source__c =='Internal Digital'){
                agmtRCS = AgreementUtilities.createPSAgreement(agmtSA);
                agmtRCS.RecordTypeId = rcsRecordTypeId;
                agmtRCS.Name =  'RCA_'+parentAgrment.Apttus__FF_Agreement_Number__c;
                agmtRCS.Apttus__Source__c = 'Internal Digital';
                agmtRCS.APTPS_buyingWindow__c = agmtRCS.Apttus__Term_Months__c; 
                agmtRCS.Apttus__Status__c = 'Request';
                agmtRCS.Apttus__Status_Category__c = 'Request';
                agmtRCS.Apttus__Total_Contract_Value__c = agmtRCS.Delegated_Pricing_Request__r.Total_Deal_Monthly_Manual_Value__c;
                
                system.debug('parentAgrment.Id '+parentAgrment.Id);
                //14831
                Apttus__APTS_Agreement__c siblingPSAgreement = [select id,APTPS_Record_Type_Name__c ,Apttus__Version_Number__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Apttus__Term_Months__c, Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Apttus__Source__c from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: parentAgrment.Id  AND RecordType.DeveloperName = 'Schedule' LIMIT 1 ];
                system.debug('siblingPSAgreement '+siblingPSAgreement );
                agmtRCS.Related_PS_Agreement__c = siblingPSAgreement.Id;
                system.debug('agmtRCS.Related_PS_Agreement__c '+agmtRCS.Related_PS_Agreement__c );
                
                insert agmtRCS;
                
                String[] tmp1 = New String[]{};
                    String relatedCompanyNames;
                
                List<APTPS_Related_Companies__c> listRelatedCompany = new List<APTPS_Related_Companies__c>();
                for(csconta__Account_Frame_Agreement_Association__c frameAgrmntAss : listFrameAgrmtAss){
                    APTPS_Related_Companies__c relatedCompany = new APTPS_Related_Companies__c();
                    relatedCompany.APTPS_Account__c = frameAgrmntAss.csconta__Account__c;
                    relatedCompany.APTPS_Agreement__c = agmtRCS.Id;
                    tmp1.add(frameAgrmntAss.csconta__Account__r.Name);
                    listRelatedCompany.Add(relatedCompany);
                }
                if(listRelatedCompany.size()>0){
                    insert listRelatedCompany;
                }
                agmtSA.APTPS_Agreement_Subcategory__c = 'Company Group';
                agmtSA.APTPS_Validation_on_Fully_Signed__c = true;
                agreementListToUpdate.add(agmtSA);
                
                relatedCompanyNames = string.join(tmp1,',');
                system.debug('####RC Names comma separated'+relatedCompanyNames);
                agmtRCS.RC_Name_Delta__c = relatedCompanyNames;
                agreementListToUpdate.add(agmtRCS);
                update agreementListToUpdate;
                
                RCDeltaName = relatedCompanyNames;
                
                Boolean isShared = ContentDocumentLinkContract.shareAgreementVariation(agmtSA.Id);
                
                //DIGI-11813 Starts
                Apttus__APTS_Template__c[] tempList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where name in ('Price_schedule_Cover_Letter','Related Company Schedule Letter')];
                for(Apttus__APTS_Template__c temp:tempList){
                    if(temp.name == 'Related Company Schedule Letter'){
                        AgreementUtilities.generateAgreement(agmtRCS.Id,temp.Id);
                    }
                }
                if(parentAgrment != null && parentAgrment.Apttus__Status_Category__c =='In Effect') {
                    for(Apttus__APTS_Template__c temp:tempList){
                        If(temp.name== 'Price_schedule_Cover_Letter'){
                            AgreementUtilities.generateAgreement(agmtRCS.Id,temp.Id);
                        }
                    }
                }
                ////DIGI-11813 Ends
            }
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'createRCAgreement';
            String referenceNumber = '';
            if(agmtSA != null)
                referenceNumber = String.valueOf(agmtSA.Id);
            String errorMessage =  ex.getMessage();
            system.debug('exception-->'+errorMessage+ ' Line number->' +ex.getLineNumber());
            String businessDescriptionEX = 'Creation of RCS agreement for SA Agreement Id:'+ referenceNumber  +' failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
        return agmtRCS;
    }
    //DIGI-11225
    public static Boolean isRCSVariationRequired(csconta__Frame_Agreement__c frameAgreement,Apttus__APTS_Agreement__c agmtRCS,String agmtSA,List<Delegated_Pricing_Request__c> dprRequest,Boolean isPSVariation){
        
        List<csconta__Account_Frame_Agreement_Association__c> listFrameAgrmtAss = [select csconta__Account__c,csconta__Account__r.Name from csconta__Account_Frame_Agreement_Association__c where csconta__Frame_Agreement__c =:frameAgreement.Id];
        
        system.debug('listFrameAgrmtAss.size()->'+listFrameAgrmtAss.size());
        
        Apttus__APTS_Agreement__c parentAgrment = [select Id,APTPS_Agreement_Subcategory__c,Apttus__Source__c,APTPS_Validation_on_Fully_Signed__c  from Apttus__APTS_Agreement__c where Id=:agmtSA];
        system.debug('######parentAgrment.Apttus__Source__c'+parentAgrment.Apttus__Source__c);
        
        List<APTPS_Related_Companies__c> existingRelCompaniesList = agmtRCS.Related_Companies__r;
        
        Set<Id> existingAccountIdSet = new Set<Id>();
        Set<Id> newAccountIdSet = new Set<Id>();
        Boolean isRCVariationRequired = false;
        
        for(csconta__Account_Frame_Agreement_Association__c tempAccountFAAssoc : listFrameAgrmtAss){
            newAccountIdSet.add(tempAccountFAAssoc.csconta__Account__c);
        }
        system.debug('newAccountIdSet###'+newAccountIdSet);
        
        for(APTPS_Related_Companies__c tempAccountRC : existingRelCompaniesList){
            existingAccountIdSet.add(tempAccountRC.APTPS_Account__c);
        }
        system.debug('existingAccountIdSet###'+existingAccountIdSet);
        
        if(existingAccountIdSet.size() > 0 || newAccountIdSet.size() > 0){
            if(newAccountIdSet.size() != existingAccountIdSet.size()){
                isRCVariationRequired = true;
                system.debug('######1');
            }else if(newAccountIdSet.size() == existingAccountIdSet.size()){
                system.debug('######3');
                for(Id oldAccounts : existingAccountIdSet){
                    if(!newAccountIdSet.contains(oldAccounts)){
                        isRCVariationRequired = true;
                        system.debug('#####4');
                    }
                }
            }
        }
        system.debug('isRCVariationRequired###'+isRCVariationRequired);
        
        if(isRCVariationRequired && listFrameAgrmtAss.size() >= 0 && parentAgrment.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL){
            createRelatedCompanyScheduleVariation(frameAgreement,agmtRCS,listFrameAgrmtAss,parentAgrment,dprRequest,isPSVariation);
            return true;
        }
        else{
            return false;
        }       
    }
    
    public static void createRelatedCompanyScheduleVariation(csconta__Frame_Agreement__c frameAgreement,Apttus__APTS_Agreement__c oldRCSAgmtRecord, List<csconta__Account_Frame_Agreement_Association__c> listFrameAgrmtAss,Apttus__APTS_Agreement__c parentAgrment,List<Delegated_Pricing_Request__c> dprRequest, Boolean isPSVariation){
        
        Apttus__APTS_Agreement__c newVariationRCSAgreement=null;
        Map<Id,Id> amendedAgmts= new Map<Id,Id>();
        
        //Apttus__APTS_Agreement__c parentAgrment = [select Id,APTPS_Agreement_Subcategory__c,Apttus__Source__c from Apttus__APTS_Agreement__c where Id=:agmtSA];
        
        Apttus__APTS_Agreement__c oldRCSRecord = [SELECT Id,PS_Variation_Details__c,Apttus_Approval__Approval_Status__c,Apttus__Status_Category__c,Apttus__Source__c,Apttus__Status__c,Apttus__Account__c,Apttus__Parent_Agreement__c,APTPS_Agreement_Subcategory__c,Apttus__Term_Months__c,APTPS_buyingWindow__c,Apttus__Contract_Start_Date__c,Apttus__Total_Contract_Value__c,APTPS_Validation_on_Fully_Signed__c,Variation_Applicable__c,Related_Basket__c FROM Apttus__APTS_Agreement__c WHERE Id =: oldRCSAgmtRecord.Id LIMIT 1 ];
        
        system.debug('oldRCSRecord::'+oldRCSRecord);
        
        OpportunityContactRole oppContactRole=null;
        
		//DIGI-40120 Start
        List<FA_DefaultRecipients__c> faDefaultRecordlst=[Select id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c from FA_DefaultRecipients__c where Deal_Pricing_Request__c=:dprRequest[0].id AND Signatory_1__c != null AND Signatory_2__c != null order by createddate desc limit 1];
        system.debug('faDefaultRecordlst**'+ faDefaultRecordlst);
        
        
        if(faDefaultRecordlst.size()==0){
            oppContactRole=AgreementUtilities.fetchPrimaryContact(frameAgreement.Opportunity__c);
        }
        //DIGI-40120 End
        
        newVariationRCSAgreement = Apttus.AgreementWebService.amendAgreement(oldRCSRecord.Id);
        newVariationRCSAgreement.Apttus__Parent_Agreement__c = oldRCSRecord.Apttus__Parent_Agreement__c;
        newVariationRCSAgreement.Apttus__Account__c=oldRCSRecord.Apttus__Account__c ;
        newVariationRCSAgreement.Apttus__Term_Months__c=oldRCSRecord.Apttus__Term_Months__c;
        newVariationRCSAgreement.Apttus__Related_Opportunity__c=dprRequest[0].Opportunity__c;
        newVariationRCSAgreement.Apttus__Subtype__c=subTypeDigital;
        newVariationRCSAgreement.Delegated_Pricing_Request__c=dprRequest[0].id;
        newVariationRCSAgreement.Variation_Applicable__c=true;
        newVariationRCSAgreement.Apttus_Approval__Approval_Status__c = oldRCSRecord.Apttus_Approval__Approval_Status__c;
        if(isPSVariation){
            newVariationRCSAgreement.VariationType__c = 'Price Schedule;Related Company';
        }else{
            newVariationRCSAgreement.VariationType__c = 'Related Company';
        }
        newVariationRCSAgreement.APTPS_buyingWindow__c=oldRCSRecord.APTPS_buyingWindow__c;
        newVariationRCSAgreement.Apttus__Contract_Start_Date__c=oldRCSRecord.Apttus__Contract_Start_Date__c;
        newVariationRCSAgreement.Apttus__Total_Contract_Value__c=oldRCSRecord.Apttus__Total_Contract_Value__c;
        
        //14831
        system.debug('newVariationRCSAgreement.VariationType__c: '+newVariationRCSAgreement.VariationType__c );
        if(newVariationRCSAgreement.VariationType__c != null){
            List<string> str = newVariationRCSAgreement.VariationType__c.split(';');
            system.debug('parentAgrment.Id : '+parentAgrment.Id );
            
            if(str.contains('Price Schedule') && str.contains('Related Company')){
                Apttus__APTS_Agreement__c siblingPSAgreement = [select id,APTPS_Record_Type_Name__c ,Apttus__Version_Number__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Apttus__Term_Months__c, Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Apttus__Source__c from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: parentAgrment.Id  AND RecordType.DeveloperName = 'Schedule' LIMIT 1 ];
                system.debug('siblingPSAgreement: '+siblingPSAgreement );
                newVariationRCSAgreement.Related_PS_Agreement__c = siblingPSAgreement.Id;
            }
            else if(str.contains('Related Company')){
                Apttus__APTS_Agreement__c siblingPSAgreement = [select id,APTPS_Record_Type_Name__c ,Apttus__Version_Number__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Apttus__Term_Months__c, Apttus__Status__c,Apttus__Status_Category__c,Apttus__Parent_Agreement__c,Apttus__Source__c from Apttus__APTS_Agreement__c where Apttus__Parent_Agreement__c =: parentAgrment.Id  AND RecordType.DeveloperName = 'Schedule'AND Apttus__Status_Category__c = 'In Effect' LIMIT 1 ];
                system.debug('siblingPSAgreement: '+siblingPSAgreement );
                newVariationRCSAgreement.Related_PS_Agreement__c = siblingPSAgreement.Id;
            }
        }
        
        newVariationRCSAgreement=setAgreementData(newVariationRCSAgreement,dprRequest[0],frameAgreement,faDefaultRecordlst,oppContactRole);
        
        insert newVariationRCSAgreement;
        
        system.debug('newVariationRCSAgreement####'+newVariationRCSAgreement);
        if(!isPSVariation){
            AgreementUtilities.frageAgreementAssociationRecoredCreation(parentAgrment.Id,frameAgreement.id,true);
        }
        
        //This code has written to update old RCS agreement status in Being Amended
        AgreementOrderUtilities.agreementStatusUpdate(oldRCSRecord,AGREEMENT_Status_CATEGORY,AGREEMENT_Status);
        
        //This Part of code has written to Create Related Agreement record's of Amended RCS agreement and old RCS agreement
        if(newVariationRCSAgreement!=null){
            amendedAgmts.put(oldRCSRecord.Id,newVariationRCSAgreement.id);
            APTPS_CreateAgreementVariationController aptsVariationController= new APTPS_CreateAgreementVariationController ();
            aptsVariationController.createRelatedAgreement(amendedAgmts);
        }
        
		//DIGI-40120 Start
        if(faDefaultRecordlst.size()>0){
            AgreementUtilities.insertDocusignRecipient(newVariationRCSAgreement,faDefaultRecordlst[0],null);
        }
        else{
            AgreementUtilities.insertDocusignRecipient(newVariationRCSAgreement,null,oppContactRole);
        }
        //DIGI-40120 End
		
        String[] tmp1 = New String[]{};
            String relatedCompanyNames;
        
        List<APTPS_Related_Companies__c> listRelatedCompany = new List<APTPS_Related_Companies__c>();
        for(csconta__Account_Frame_Agreement_Association__c frameAgrmntAss : listFrameAgrmtAss){
            APTPS_Related_Companies__c relatedCompany = new APTPS_Related_Companies__c();
            relatedCompany.APTPS_Account__c = frameAgrmntAss.csconta__Account__c;
            relatedCompany.APTPS_Agreement__c = newVariationRCSAgreement.Id;
            tmp1.add(frameAgrmntAss.csconta__Account__r.Name);
            listRelatedCompany.Add(relatedCompany);
        }
        
        relatedCompanyNames = string.join(tmp1,',');
        system.debug('####RC Names comma separated in RC Variation::'+relatedCompanyNames);
        newVariationRCSAgreement.RC_Name_Delta__c = relatedCompanyNames;
        update newVariationRCSAgreement;
        
        RCDeltaName = relatedCompanyNames;
        
        system.debug('listRelatedCompany.size()###'+listRelatedCompany.size());
        system.debug('listRelatedCompany###'+listRelatedCompany);
        
        Apttus__APTS_Template__c[] tempList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where name in ('Price_schedule_Cover_Letter','Related Company Schedule Letter')];
        
        if(listRelatedCompany.size()>0){
            insert listRelatedCompany;
            system.debug('Creating RFor Variation scenario');
            
            //DIGI-11813
            for(Apttus__APTS_Template__c temp:tempList){
                if(temp.name == 'Related Company Schedule Letter'){
                    AgreementUtilities.generateAgreement(newVariationRCSAgreement.Id,temp.Id);
                }
            }
        }
        
        //DIGI-11226
        if(listFrameAgrmtAss.size() == 0){
            parentAgrment.APTPS_Agreement_Subcategory__c = 'Single Customer';           
        }else
        {
            parentAgrment.APTPS_Agreement_Subcategory__c = 'Company Group';
        }
        parentAgrment.APTPS_Validation_on_Fully_Signed__c = true; //DIGI-27644
        update parentAgrment;
        
        //DIGI-11813
        if(newVariationRCSAgreement.VariationType__c == 'Related Company'){ 
            for(Apttus__APTS_Template__c temp:tempList){
                if(temp.name == 'Price_schedule_Cover_Letter'){
                    AgreementUtilities.generateAgreement(newVariationRCSAgreement.Id,temp.Id);
                }
            }
        }
    }
    // end DIGI-11225
    /* public Static void updatePSAgreementforDealFlow(Apttus__APTS_Agreement__c agmtPS){
try{
agmtPS.APTPS_buyingWindow__c = agmtPS.Apttus__Term_Months__c; 
agmtPS.Apttus__Total_Contract_Value__c = agmtPS.Delegated_Pricing_Request__r.Total_Deal_Monthly_Value__c;
//AgmtRecord.APTPS_Show_After_E_Signature_Buttons__c = null ; DO we need to do this ? in originalps this field is not populated 
insert agmtPS;
System.debug('AgreementDealUtilities:createPSAgreement:updatePSAgreementforDealFlow:CreatedAgreement'+agmtPS); 
}
catch(AgreementException agEx){
throw agEx; 
}
catch(Exception ex){
String methodName = 'updatePSAgreementforDealFlow';
String referenceNumber = String.valueOf(agmtPS.Id);
String errorMessage =  ex.getMessage();
String businessDescriptionEX = 'Creation of PS agreement for SA Agreement Id:'+ agmtPs.Id +' failed in class AgreementDealUtilities.updatePSAgreementforDealFlow at line no:'+ex.getLineNumber();
AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);

throw agEx; 
}
} */
    //Create ALI
    public static list<Id> createPSAgreementLineItems(Id agreementId, set<String> productFamily, Map<String,Id> mapOfPFWithDPRID){
        try{
            list<Id> agreementLineItemsIds = AgreementUtilities.createAgreementLineItem_RF(agreementId,productFamily, mapOfPFWithDPRID);
            return agreementLineItemsIds ;
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
    }
    public static Map<String,Id> getProductFamilyVsDPRId(List<DPR_Offer_Line_Item__c> relatedDPROLI){
        Map<String,Id> mapOfPFWithDPRID = new Map<String,Id>() ; 
        try{
            if(relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId != NULL  && relatedDPROLI != null && relatedDPROLI.size() > 0 ){
                //-- get All Unique product family from DPR_OLI
                for(DPR_Offer_Line_Item__c oli : relatedDPROLI){
                    System.debug('pFamily='+oli.Marketable_Offer__r.Product_Family__c);
                    if(!mapOfPFWithDPRID.containsKey(oli.Marketable_Offer__r.Product_Family__c))
                        mapOfPFWithDPRID.put(oli.Marketable_Offer__r.Product_Family__c,oli.DPR_Offer__c);
                }
                return mapOfPFWithDPRID ;
            } 
            else return null ; 
        }
        catch(Exception ex){
            String methodName = 'getProductFamilyVsDPRId';
            String referenceNumber = ''; 
            if(relatedDPROLI != null)
                referenceNumber = String.valueOf(relatedDPROLI);
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'get productfamily method failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    //Create attribute 
    /**

* @Author   :   Maqsood Alam
* @Date     :   23 Nov 2020
* @Desc     :   This method has written to create Attribute on Agreement Line item
* @US       :   EDGE-184997
* @Status   :   Development
* */
    public static Id createAttributeOnAgmtLineIem(list<DPR_Offer_Line_Item__c> relatedDPROLI, list<Id> agreementLineItems){
        try{
            list<APTPS_Component__c> listAttributes = New list<APTPS_Component__c>();
            List<id> dprIdforRateCard= new List<id> ();
            map<id,id> dprlineitemwithapttusRateCardMap= null;
            Map<String, DPR_RateCard_Slab__mdt> mapRateCardSlab = DPR_RateCard_Slab__mdt.getAll();
            List<DPR_Rate_Card__c> dprRateCardList=[SELECT Id,DPR_Rate_Card_Name__c,Parent_DPR_OLI_id__c,Parent_DPR_OLI_id__r.Product_Family__c,Parent_DPR_Rate_Card_ID__r.DPR_Rate_Card_Name__c,Parent_DPR_Rate_Card_ID__c,Rate_Card__r.name, DPR_RC_Negotiated_Value__c,DPR_Rate_Card_Type__c  from DPR_Rate_Card__c where Parent_DPR_OLI_id__c in: relatedDPROLI order by DPR_Rate_Card_Name__c asc];
            if(dprRateCardList.size()>0){
                dprlineitemwithapttusRateCardMap=AgreementApttusRateCardUtilities.createApttusRateCard(dprRateCardList);
            }
            
            for(Apttus__agreementlineitem__c agmtLineItem : [SELECT  Id, Name, Apttus__productid__c, Apttus__productid__r.Name FROM Apttus__agreementlineitem__c WHERE Id IN : agreementLineItems]){
                for(DPR_Offer_Line_Item__c oli : relatedDPROLI){
                    //System.debug('ExceptionFix Test Class->'+oli.Marketable_Offer__r.Product_Family__c+ '=='+agmtLineItem.Apttus__productid__r.Name +'&&'+oli.DPR_Offer_Line_Item_Type__c +'=='+ 'Plan');
                    If(oli.Marketable_Offer__r.Product_Family__c == agmtLineItem.Apttus__productid__r.Name && oli.DPR_Offer_Line_Item_Type__c == 'Plan'){
                        APTPS_Component__c attribute = new APTPS_Component__c();
                        attribute.DPR_Offer_Line_Item__c=oli.id;
                        attribute.APTPS_Attribute__c = oli.Name;
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
            }      
            system.debug('*****listAttributes******'+listAttributes);    
            return null;     
        }
        catch(Exception ex){
            String methodName = 'createAttributeOnAgmtLineIem';
            String referenceNumber = '';
            String errorMessage =  ex.getMessage();
            String businessDescriptionEX = 'Creation of attributes failed in class AgreementDealUtilities.createAttributeOnAgmtLineIem at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    public static void  generateAgreement(List<Apttus__APTS_Agreement__c> agmts)
    {
        Id templateId;
        Id agreementId; 
        Map<String,String> allConst = new Map<String,String>();
        try
        {   
            allConst = getConstant();
            List<Apttus__APTS_Template__c> templateList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where (name =:allConst.get('DSATemplate') or name =:allConst.get('PriceScheduleTemplate') or name =:allConst.get('BSATemplate') ) and Apttus__IsActive__c = true and Apttus__Type__c= 'Agreement' ];
            Map<String,Id> templateMap = new Map<String,Id>();
            for(Apttus__APTS_Template__c temp:templateList){
                if(temp.name == allConst.get('DSATemplate')){
                    templateMap.put(allConst.get('DSATemplate'), temp.Id);
                }
                else if(temp.name== allConst.get('PriceScheduleTemplate')){
                    templateMap.put(allConst.get('PriceScheduleTemplate'),temp.Id);
                }
                else if(temp.name== allConst.get('BSATemplate')){
                    templateMap.put(allConst.get('BSATemplate'),temp.Id);
                }
            }
            for(Apttus__APTS_Agreement__c ag : agmts){
                agreementId = ag.Id ; 
                if(ag.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){
                    templateId = templateMap.get(allConst.get('PriceScheduleTemplate'));
                    if(!Test.isRunningTest()){
                        generateAgreementdoc(agreementId,templateId);  
                    }
                }
                if(ag.RecordTypeId == AGREEMENT_SA_RECORDTYPEID){
                    if(ag.Apttus__Agreement_Category__c == APTPS_Constants.DSA_AGMT_CATEGORY){
                        templateId = templateMap.get(allConst.get('DSATemplate'));
                    }
                    if(ag.Apttus__Agreement_Category__c == APTPS_Constants.BSA_AGMT_CATEGORY){
                        templateId = templateMap.get(allConst.get('BSATemplate'));
                    }
                    
                    if(!Test.isRunningTest()){
                        generateAgreementdoc(agreementId,templateId);
                    }
                }
            }
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String methodName = 'generateAgreement' ; 
            String referenceNumber = ''; 
            String errorMessage =  ex.getMessage(); 
            String businessDescriptionEX = 'Creation of attributes failed in class AgreementDealUtilities.generateAgreement at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    }
    // Ravi: Pls move generateAgreement, generateAgreementDoc getAPIServerURL, getSessionId, getConstant to the common class
    // These methods are being repeated once again in AgreementOrderUtilities
    @Future(callout=true)
    public static void  generateAgreementdoc(Id agreementId, Id templateId)
    {
        String apiSessionId = getSessionId(); 
        String pLevel = 'Insert comments and tracked changes only'; 
        String docFormat = 'DOCX'; 
        String apiServerURL =  getapiServerURL();
        Id generatedDocId ;
        try
        {
            if(!Test.isRunningTest()){
                generatedDocId = Apttus.MergeWebService.generateDoc(templateId, agreementId,pLevel, docFormat, apiSessionId, apiServerURL);  
            }
            system.debug('generatedDocId ===  '+generatedDocId );
        }
        catch(Exception ex){
            String methodName = 'generateAgreementdoc' ; 
            String referenceNumber = ''; 
            String errorMessage =  ex.getMessage(); 
            String businessDescriptionEX = 'Creation of attributes failed in class AgreementDealUtilities.generateAgreement at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescriptionEX);
            throw agEx; 
        }
    } 
    public static string getSessionId(){
        // System.debug(' UserId ' + UserInfo.getSessionId()); //commented due to sonarqube
        return UserInfo.getSessionId();
    }
    public static string getapiServerURL(){
        System.debug(' apiServerURL ' + System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId());
        return System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId();
    }
    
    public static Map<String,String> getConstant(){
        Map<String,String> allConst = new Map<String,String>(); 
        
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
        //return allConst; 
        
        return allConst; 
    }
    public static Object getKeyMap(Map<List<Object>,boolean> mapOfList,Integer indx){
        Integer defaultIndex = 0;
        List<Object> keyToReturn = new List<Object>();
        Object objToReturn;
        for(List<Object> mapList : mapOfList.keyset()){
            keyToReturn = mapList;
            break;
        }
        for(Object obj :keyToReturn){
            if(defaultIndex == indx){
                objToReturn =  obj;
            }
            defaultIndex = defaultIndex + 1;
        }
        return objToReturn;
    }
    public static Boolean getValueMap(Map<List<Object>,boolean> mapOfList){
        boolean valToReturn;
        for(boolean mapList : mapOfList.values()){
            valToReturn =  mapList;
            break;
        }
        return valToReturn;
    }
    //Decision
    public static AgreementUtilities.AgreementDecision resolveSAType(Delegated_Pricing_Request__c dprRequest){
        system.debug('Inside resolveSAType');
        set <String > legacyPF = new set <String > ();
        AgreementUtilities.AgreementDecision decision = new AgreementUtilities.AgreementDecision();
        Boolean isLegacyAgmtPresent = false;
        Boolean isDigiAgmtPresent = false;
        Boolean isLegacyPFSame = false;
        List<String> legacySARecIdList = new List<String>(); 
        List<String> existingDigiSARecIdList = new List<String>(); 
        set<String> currentPF = new set < String > ();      
        set<String> existingPF = new set < String > (); 
        List<String> parentSAList = new List<String>(); 
        try{
            List<DPR_Offer_Line_Item__c> relatedDPROLI = [SELECT id, NAME,Delegated_Pricing_Request__r.Opportunity__r.AccountId, DPR_Offer__R.NAME, Offer_Type__c, Offer_Type_Name__c, Marketable_Offer__r.name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c, Offer_Type__r.Type__C, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Value__c, DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c =: dprRequest.Id];
            for(DPR_Offer_Line_Item__c relatedDPROL : relatedDPROLI){
                currentPF.add(relatedDPROL.Marketable_Offer__r.Product_Family__c);
            }
            system.debug('dprRequest.Id '+ dprRequest.Id + 'dprRequest.Account__c' + dprRequest.Account__c);
            //Query all agreements records on Account(Legacy & Digital)
            Id accountId;
            List<Apttus__APTS_Agreement__c> agreementsInAcc = new List<Apttus__APTS_Agreement__c>();
            accountId =relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId;
            System.debug('relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId'+relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId);
            //DIGI-19515 Start
            if (FeatureEligibilityChecker.determineFeatureEligiblity('ShareAgmtWithPRM', 'Agreement')){
                system.debug('PRMSharingEnabled');
                agreementsInAcc = ContentDocumentLinkContract.shareAgreements(accountId);
            }
            else{
                system.debug('PRMSharingDiabled');
                agreementsInAcc = [SELECT Id,Apttus__Source__c,RecordTypeId,Apttus__Account__c,Apttus__Parent_Agreement__c,Apttus__Status_Category__c, (SELECT Name, Product__c,Apttus__ProductId__r.Telstra_Marketable_Product_Family__c FROM Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c where Apttus__Account__c =:accountId  AND Apttus__Status_Category__c=:APTPS_Constants.apttusStatusCategory];
            }
            //DIGI-19515 End
            system.debug('agreementsInAcc '+ agreementsInAcc);
            for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                for(Apttus__AgreementLineItem__c agmtLI : agreement.Apttus__AgreementLineItems__r){
                    existingPF.add(agmtLI.Product__c); 
                }
                System.debug('#agreement.RecordTypeId#'+agreement.RecordTypeId);
                System.debug('#agreement.Apttus__Source__c#'+agreement.Apttus__Source__c);
                // Check for Legacy SA
                if(agreement.RecordTypeId == AGREEMENT_SA_RECORDTYPEID && agreement.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_PAPER){
                    System.debug('inside legacy loop');
                    isLegacyAgmtPresent =true;
                    legacySARecIdList.add(agreement.id); 
                    System.debug('legacySARecIdList ===> 001'+legacySARecIdList);
                    continue; // Why continue ? 
                } 
                // Check for Digital SA
                if(agreement.RecordTypeId == AGREEMENT_SA_RECORDTYPEID && agreement.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL){
                    System.debug('inside digital loop');
                    isDigiAgmtPresent = true;
                    existingDigiSARecIdList.add(agreement.id);
                }
            }
            
            parentSAList.addAll(legacySARecIdList);  
            parentSAList.addAll(existingDigiSARecIdList);  
            decision.parentSAList = parentSAList ; 
            Map<List<Object>,boolean> pfDifferenceMap = checkPSVariation(dprRequest,agreementsInAcc,existingDigiSARecIdList); // DIGI-434 update index 0 and downcast to List<String> ProductFamilies from Object
            list<String> pfDifferenceList = (List<String>) getKeyMap(pfDifferenceMap,0);
            //list<String> pfDifferenceListLegacy = (List<String>) checkPSVariation(dprRequest,agreementsInAcc,legacySARecIdList)[0]; // DIGI-434 update index 0 and downcast to List<String> ProductFamilies from Object
            // Check if Legacy Agreement is present - 1st pref
            if(isLegacyAgmtPresent == true){
                decision.sourceType = 'Paper';
                // If NO variation was detected - Create case for CCO to handle this manually
                for(String existing : existingPF){
                    if(currentPF.size()>0 && currentPF.contains(existing)){
                        /** DIGI-434 STARTED - This helps to identify the case creation prodcutfamilies */
                        decision.caseCreation = true ; 
                        Map<List<Object>,boolean> legacyPFMap = checkPSVariation(dprRequest,agreementsInAcc,legacySARecIdList);
                        decision.legacyPFMatchedSet = (Set<String>) getKeyMap(legacyPFMap,1);
                        System.debug('legacyPFMatchedSet ==> '+decision.legacyPFMatchedSet);
                        /** DIGI-434 END */
                        break ; 
                    }
                }
                
                if(decision.caseCreation != null && decision.caseCreation == false &&  isDigiAgmtPresent != true){
                    //new flow 
                }
                /*  if(pfDifferenceListLegacy == null || (pfDifferenceListLegacy.size()==0 ) ){
decision.caseCreation = true ; 
//ToDo: create a case; 
// and return the method with an error to be displayed to the Sales user
} */
                // If variation, proceed to check Digital Agreement. 
            }
            // Check if Digi Agreement is present - 2nd pref
            if(isDigiAgmtPresent == true){
                system.debug('Inside isDigiAgmtPresent ');
                //Cheagreck if Price Schedule variation required
                //decision.PFDifferenceListAdd = pfDifferenceList; /** This Variables are removed as a part of DIGI-434 by Lokesh Thathuru : as discussed with aniket and monali*/         
                if (pfDifferenceList != null && pfDifferenceList.size() >0) {
                    List< String> cpf = new List<String>() ;
                    for(String masterPF : pfDifferenceList ){
                        if(currentPF != null && !currentPF.contains(masterPF)){ 
                            cpf.add(masterPF);
                            //   system.debug('variationProductFamily:'+ variationProductFamily);
                        }
                    }
                    // decision.PFDifferenceListModify = cpf;  /** This Variables are removed as a part of DIGI-434 by Lokesh Thathuru : as discussed with aniket and monali*/
                } else {
                    list< String> cpf = new List<String>() ; 
                    cpf.addAll(currentPF);
                    // decision.PFDifferenceListModify = cpf;  /** This Variables are removed as a part of DIGI-434 by Lokesh Thathuru : as discussed with aniket and monali*/
                }
                decision.variationRequired = true;
                decision.isPSVariation = false;
                if(getValueMap(pfDifferenceMap)){
                    decision.isPSVariation = true;
                }
                
                system.debug('decision.variationRequired:' + decision.variationRequired);
                system.debug('decision.isPSVariation:' + decision.isPSVariation);
                decision.parentSAAgreement = existingDigiSARecIdList[0];
                decision.sourceType = 'Digital';
                //below code to set parentPSAgreement to record id of existing PS record
                for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                    if(agreement.Apttus__Parent_Agreement__c == existingDigiSARecIdList[0] && agreement.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID && agreement.Apttus__Status_Category__c==APTPS_Constants.IN_EFFECT_STATUS_CATEGORY){
                        system.debug('decision.variationRequired:' + decision.variationRequired);
                        decision.parentPSAgreement = agreement.id;
                        break;
                    }
                }
            }
            else{  // No Digi Agreement present - create a New Digi Agreement based on the Opty Contract Type
                //Set parameters to create agreements first time.
                decision.isPSVariation = false;
                decision.variationRequired = false;
                decision.saType = dprRequest.Opportunity__r.Contract_Type__c ;
            }
        }
        catch(Exception ex){
            String methodName = 'resolveSAType';
            String referenceNumber = '';
            if(dprRequest != null)
                referenceNumber = dprRequest.Id;
            String errorMessage =  ex.getMessage();
            system.debug('Parm--->'+errorMessage + ' ' +ex.getLineNumber());
            String businessDescription = 'Business logic to get SA type failed for basket id:'+referenceNumber+' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescription);
            throw agEx;
        }
        
        return decision;
    }
    //DIGI-434 - Changed the return type from List<String> to List<Object>
    public static Map<List<Object>,boolean> checkPSVariation(Delegated_Pricing_Request__c dprRequest ,List<Apttus__APTS_Agreement__c> agreementsInAcc,List<Id> SAAgreementIdsInAcc){
        list < String > variationProductFamily = New list < String > ();
        Boolean variationRequired = false;
        /** DIGI-434 Added variables STARTED */
        List<Object> listOfObjects=new List<Object>();
        Map<List<Object>,boolean> mapOflistOfObjects = new Map<List<Object>,boolean>();
        Set<String> setOfAgrrkeyMatchedProductFamilies=new  Set<String>();
        /**  DIGI-434 Added variables END */
        set<String> existingPF = new set < String > ();
        set<String> currentPF = new set < String > ();
        try{
            List<DPR_Offer_Line_Item__c> dprOfferLineItems = [SELECT id, NAME, cspmb_Price_Item__c, Delegated_Pricing_Request__r.Opportunity__r.AccountId, DPR_Offer__R.NAME, Offer_Type__c, Offer_Type_Name__c, Marketable_Offer__r.name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c, Offer_Type__r.Type__C, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Value__c, DPR_Offer__c, Overriden_Unit_price__c
                                                              ,(Select ID, DPR_RC_Negotiated_Value__c, Rate_Card_Line__c,Parent_DPR_OLI_id__c from DPR_Rate_Card__r WHERE Parent_DPR_Rate_Card_ID__c != null) from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c =: dprRequest.Id AND Parent_DPR_Offer_Line_Item_Id__c = null AND isNegotiableCharge__c= true];
            for(DPR_Offer_Line_Item__c relatedDPROLI : dprOfferLineItems){
                currentPF.add(relatedDPROLI.Marketable_Offer__r.Product_Family__c);
            }
            System.debug('#### PFs in the current basket: '+currentPF);
            system.debug('agreementsInAcc:'+agreementsInAcc);
            Set<Id> agrLineItemsIdSet = new Set<Id>();
            for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                system.debug('agreement:'+agreement);
                System.debug('SAAgreementIdsInAcc ==> '+SAAgreementIdsInAcc);
                System.debug('agreement.RecordTypeId'+agreement.RecordTypeId);
                System.debug('agreement.Apttus__Status_Category__c'+agreement.Apttus__Status_Category__c);
                System.debug('agreement.Apttus__Parent_Agreement__c'+agreement.Apttus__Parent_Agreement__c);
                if(SAAgreementIdsInAcc.contains(agreement.Apttus__Parent_Agreement__c) && agreement.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID && agreement.Apttus__Status_Category__c==APTPS_Constants.IN_EFFECT_STATUS_CATEGORY){
                    system.debug('PSagreement:'+agreement);
                    if (agreement.Apttus__AgreementLineItems__r != null) {
                        system.debug('agreement.Apttus__AgreementLineItems__r :'+agreement.Apttus__AgreementLineItems__r );
                        for (Apttus__AgreementLineItem__c agrLineItems: agreement.Apttus__AgreementLineItems__r) {
                            agrLineItemsIdSet.add(agrLineItems.Id);
                            existingPF.add(agrLineItems.Product__c);
                            system.debug('existingPF:'+existingPF);
                        }  
                        
                    }
                }
            }
            system.debug('currentPF:' + currentPF);
            for(String masterPF:currentPF){
                if(existingPF.size()>0 && !existingPF.contains(masterPF)){
                    variationProductFamily.add(masterPF);
                    system.debug('variationProductFamily:'+ variationProductFamily);
                }/**  DIGI-434  - else block is added by Lokesh Thathuru : STARTED*/
                else if(existingPF.size()>0 && existingPF.contains(masterPF)){
                    System.debug('masterPF ==>'+masterPF);
                    setOfAgrrkeyMatchedProductFamilies.add(masterPF);
                    
                } 
                /**  DIGI-434 - Else block is added by Lokesh Thathuru: ENDED */        
            }     
            
            /**  DIGI-434 - This block is added by Lokesh Thathuru : STARTED */
            if(variationProductFamily.size()>0){
                listOfObjects.add(variationProductFamily);
                system.debug('variationRequired true in checkPSVariation ps');
                variationRequired = true;
            }else{
                listOfObjects.add(null);
            }
            if(!setOfAgrrkeyMatchedProductFamilies.isEmpty()){
                listOfObjects.add(setOfAgrrkeyMatchedProductFamilies);
            }else{
                listOfObjects.add(null);
            }
            if(!variationRequired){
                List<APTPS_Component__c> previousAttributesList = [Select ID,Name,Value__c, DPR_Offer_Line_Item__c, DPR_Offer_Line_Item__r.cspmb_Price_Item__c from APTPS_Component__c where Agreement_Line_Item__c in :agrLineItemsIdSet AND DPR_Offer_Line_Item__r.isNegotiableCharge__c = true];
                variationRequired = checkPlanAndPriceChange(dprRequest, previousAttributesList, dprOfferLineItems);
            }
            mapOflistOfObjects.put(listOfObjects,variationRequired);
            /**  DIGI-434 - This block is added by Lokesh Thathuru : ENDED */
        }
        catch(Exception ex){
            String methodName = 'checkPSVariation';
            String referenceNumber =  '';
            if(dprRequest != null)
                referenceNumber = dprRequest.id;
            String errorMessage =  ex.getMessage();
            String businessDescription = 'Method to get difference in product families failed in class AgreementDealUtilities at line no:'+ex.getLineNumber() + ' for DPRID :'+referenceNumber ;
            AgreementException agEx = new AgreementException(methodName,referenceNumber,errorMessage,businessDescription);
            throw agEx;
        }         
        //return variationProductFamily; commented by Lokesh Thathuru as a part of DIGI-434
        return mapOflistOfObjects; //Added New DIGI-434
    } 
    public static boolean checkPlanAndPriceChange(Delegated_Pricing_Request__c dprRequest ,List<APTPS_Component__c> previousAttributesList,List<DPR_Offer_Line_Item__c> newDPROfferLineItemsList){
        boolean variationRequired = false;
        //List<APTPS_Component__c> previousAttributesList = [Select ID,Name,Value__c, DPR_Offer_Line_Item__c, DPR_Offer_Line_Item__r.cspmb_Price_Item__c from APTPS_Component__c where Agreement_Line_Item__c in :AgreementLineItems AND DPR_Offer_Line_Item__r.isNegotiableCharge__c = true];
        if(previousAttributesList == null || previousAttributesList.size()==0){
            variationRequired = true;system.debug('variationRequired true 1232');
        }else if(newDPROfferLineItemsList.size() != previousAttributesList.size()){
            variationRequired = true;system.debug('variationRequired true 1234');
        }else if(newDPROfferLineItemsList.size() == previousAttributesList.size()){
            Map<id,DPR_Offer_Line_Item__c> dprLineItemMap = new Map<id,DPR_Offer_Line_Item__c>();
            Map<id,APTPS_Component__c> prvDprLineItemAtributeMap = new Map<id,APTPS_Component__c>();
            for(DPR_Offer_Line_Item__c dprLineItem : newDPROfferLineItemsList){
                dprLineItemMap.put(dprLineItem.cspmb_Price_Item__c,dprLineItem);
            }
            system.debug('dprLineItemMap'+dprLineItemMap);
            for(APTPS_Component__c atribute : previousAttributesList){
                prvDprLineItemAtributeMap.put(atribute.DPR_Offer_Line_Item__r.cspmb_Price_Item__c,atribute);
            }
            system.debug('prvDprLineItemAtributeMap'+prvDprLineItemAtributeMap);
            for(DPR_Offer_Line_Item__c dprLineItem : newDPROfferLineItemsList){
                APTPS_Component__c prvAttributeFound = prvDprLineItemAtributeMap.get(dprLineItem.cspmb_Price_Item__c);
                if(prvAttributeFound == null || (dprLineItem.DPR_Offer_Line_Item_Value__c != decimal.valueOf(prvAttributeFound.Value__c))){
                    variationRequired = true;
                    system.debug('variationRequired true 1248');
                    break;
                }
            }
        }
        system.debug('variationRequired true checkPlanAndPriceChange');
        if(!variationRequired){
            variationRequired = checkRateCardNegotiationChange(dprRequest,newDPROfferLineItemsList,previousAttributesList);
        }
        return variationRequired;
    }
    public static boolean checkRateCardNegotiationChange(Delegated_Pricing_Request__c dprRequest ,List<DPR_Offer_Line_Item__c> newDPROfferLineItemsList,List<APTPS_Component__c> previousAttributesList){
        boolean variationRequired = false;
        List<DPR_Rate_Card__c> currentDPRRateCardList = new List<DPR_Rate_Card__c>();
        List<DPR_Rate_Card__c> previousDPRRateCardList = new List<DPR_Rate_Card__c>();
        Set<Id> preDPROfferLineItemsIdSet = new Set<Id>();
        for(APTPS_Component__c attribute: previousAttributesList){
            preDPROfferLineItemsIdSet.add(attribute.DPR_Offer_Line_Item__c);
        }
        for(DPR_Offer_Line_Item__c dprLineItem : newDPROfferLineItemsList){
            if(dprLineItem.DPR_Rate_Card__r != null){
                for(DPR_Rate_Card__c dprReteCard : dprLineItem.DPR_Rate_Card__r){
                    currentDPRRateCardList.add(dprReteCard);
                }
            }
        }
        if(preDPROfferLineItemsIdSet.size() > 0){
            previousDPRRateCardList = [Select ID, DPR_RC_Negotiated_Value__c, Rate_Card_Line__c ,Parent_DPR_OLI_id__c from DPR_Rate_Card__c WHERE Parent_DPR_Rate_Card_ID__c != null and Parent_DPR_OLI_id__c IN: preDPROfferLineItemsIdSet];
        }
        if(currentDPRRateCardList.size() != previousDPRRateCardList.size()){
            variationRequired = true;
        }else if(currentDPRRateCardList.size() == previousDPRRateCardList.size()){
            //DIGI-41050 #Defect Fix 
            for(DPR_Rate_Card__c newDPR : currentDPRRateCardList){
                for(DPR_Rate_Card__c prevDPR:previousDPRRateCardList){
                    if(prevDPR!=null && (newDPR.DPR_RC_Negotiated_Value__c != prevDPR.DPR_RC_Negotiated_Value__c)){
                    variationRequired = true;
                    break;
                  }
                }
            }
        }
        system.debug('variationRequired true checkRateCardNegotiationChange');
        return variationRequired;
    }
    public static string convertValuesFromSetToString(set <String> setOfvalues){
        String valueString='';
        if(setOfvalues.size()>0){
            for (String addStringloop:setOfvalues){
                valueString=valueString+'- '+ addStringloop +'\n' ;
            }
        }
        return valueString;
    }
    public static void priceScheduleVariationCreateForOrderToDeal(List<Delegated_Pricing_Request__c> dprRequest,List<DPR_Offer_Line_Item__c> relatedDPROLI,Apttus__APTS_Agreement__c PSOldAgreementRecord, Boolean isRCSVariation){
        
        Apttus__APTS_Agreement__c newVariationPSAgreement=null;
        Map<Id,Id> amendedAgmts= new Map<Id,Id>();
        map<String,Id> mapoffamilywithAgreementlineItemId= new map<String,Id>();
        Id accountId;
        accountId =relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId;
        if(dprRequest != NULL && dprRequest.size()> 0){
            Apttus__APTS_Agreement__c oldPSRecord = [SELECT Id,PS_Variation_Details__c,Apttus__Status_Category__c,Apttus__Source__c,Apttus__Status__c,Apttus__Account__c,Apttus__Parent_Agreement__c,Apttus__Term_Months__c,APTPS_buyingWindow__c,Apttus__Contract_Start_Date__c,Apttus__Total_Contract_Value__c,APTPS_Validation_on_Fully_Signed__c,Variation_Applicable__c,Related_Basket__c FROM Apttus__APTS_Agreement__c WHERE Id =: PSOldAgreementRecord.Id LIMIT 1 ];
            if(dprRequest[0].id != NULL ){
                csconta__Frame_Agreement__c frameAgreement = fetchFrameAgreement(dprRequest[0].id);
                OpportunityContactRole oppContactRole=null;
                List<FA_DefaultRecipients__c> faDefaultRecordlst=[Select id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c from FA_DefaultRecipients__c where Deal_Pricing_Request__c=:dprRequest[0].id AND Signatory_1__c != null AND Signatory_2__c != null order by createddate desc limit 1]; //DIGI-23440 FIX
                system.debug('faDefaultRecordlst**'+ faDefaultRecordlst);
                if(faDefaultRecordlst.size()==0)
                    oppContactRole=AgreementUtilities.fetchPrimaryContact(frameAgreement.Opportunity__c);
                // EDGE-194529-- Changes Start from here
                List<agreementVariationDetails> fieldList = (List<agreementVariationDetails>) JSON.deserialize(oldPSRecord.PS_Variation_Details__c, List<agreementVariationDetails>.class);
                
                system.debug('fieldList '+fieldList );
                set<String> variationAddSet= new set<String>();
                set<String> variationModifySet= new set<String>();
                set<String> aliCreationSet =new set<String>();
                set<String> attributeCreationSet =new set<String>();
                
                for(agreementVariationDetails agWrapperloop:fieldList ){
                    if(agWrapperloop.ALI =='Y')
                        aliCreationSet.add(agWrapperloop.Product);
                    
                    if(agWrapperloop.Attribute =='Y')
                        attributeCreationSet.add(agWrapperloop.Product);
                    
                    if(agWrapperloop.VariationAdd!=null)
                        variationAddSet.add(agWrapperloop.VariationAdd);
                    
                    if(agWrapperloop.VariationModify!=null)
                        variationModifySet.add(agWrapperloop.VariationModify);
                    
                }
                String variationAddString='';
                String variationModifyString='';
                
                if(variationAddSet.size()>0)
                    variationAddString=convertValuesFromSetToString(variationAddSet);
                
                if(variationModifySet.size()>0)
                    variationModifyString=convertValuesFromSetToString(variationModifySet);
                
                // EDGE-194529-- Changes End from here
                /*Set<String> setPrdctFamily= new Set<String>();
String variationValue='';
for(String spltFamily : (PSOldAgreementRecord.APTPS_VariationModify__c).split(',')){
setPrdctFamily.add(spltFamily);
variationValue=variationValue+'- '+ spltFamily +'\n' ;
}*/
                system.debug('PSOldAgreementRecord'+PSOldAgreementRecord);
                system.debug('PSOldAgreementRecord'+oldPSRecord.Apttus__Account__c+ 'accountId '+ accountId);
                newVariationPSAgreement = Apttus.AgreementWebService.amendAgreement(oldPSRecord.Id);
                newVariationPSAgreement.Apttus__Parent_Agreement__c = oldPSRecord.Apttus__Parent_Agreement__c;
                newVariationPSAgreement.Apttus__Account__c=oldPSRecord.Apttus__Account__c ;
                newVariationPSAgreement.Apttus__Term_Months__c=oldPSRecord.Apttus__Term_Months__c;
                newVariationPSAgreement.Apttus__Related_Opportunity__c=dprRequest[0].Opportunity__c;
                newVariationPSAgreement.Related_Contract__c=null;
                newVariationPSAgreement.Related_Basket__c=null;
                newVariationPSAgreement.APTPS_Show_After_E_Signature_Buttons__c=true;
                newVariationPSAgreement.Apttus__Subtype__c=subTypeDigital;
                newVariationPSAgreement.Delegated_Pricing_Request__c=dprRequest[0].id;
                newVariationPSAgreement.Variation_Applicable__c=false;
                if(isRCSVariation){
                    newVariationPSAgreement.VariationType__c = 'Related Company;Price Schedule';
                    if(RCDeltaName != null){
                        newVariationPSAgreement.RC_Name_Delta__c = RCDeltaName;
                    }
                }else{
                    newVariationPSAgreement.VariationType__c = 'Price Schedule';
                }
                newVariationPSAgreement.APTPS_buyingWindow__c=oldPSRecord.APTPS_buyingWindow__c;
                newVariationPSAgreement.Apttus__Contract_Start_Date__c=oldPSRecord.Apttus__Contract_Start_Date__c;
                newVariationPSAgreement.Apttus__Total_Contract_Value__c=oldPSRecord.Apttus__Total_Contract_Value__c;
                
                // EDGE-194529-- Changes start here 
                newVariationPSAgreement.PS_Variation_Details__c='';//
                if(!String.IsEmpty(variationModifyString))
                    newVariationPSAgreement.APTPS_VariationModify__c=variationModifyString;
                else
                    newVariationPSAgreement.APTPS_VariationModify__c='';
                
                if(!String.IsEmpty(variationAddString))
                    newVariationPSAgreement.APTPS_variationAdd__c=variationAddString;
                else
                    newVariationPSAgreement.APTPS_variationAdd__c='';
                // EDGE-194529-- Changes End here
                //newVariationPSAgreement.APTPS_VariationModify__c=variationValue;
                newVariationPSAgreement.APTPS_Legacy_opportunity_ID__c=dprRequest[0].Opportunity__c;
                newVariationPSAgreement=setAgreementData(newVariationPSAgreement,dprRequest[0],frameAgreement,faDefaultRecordlst,oppContactRole);
                
                insert newVariationPSAgreement;
                system.debug('DSAID'+PSOldAgreementRecord.APTPS_Parent_Agreement_Id__c);
                
                AgreementUtilities.frageAgreementAssociationRecoredCreation(oldPSRecord.Apttus__Parent_Agreement__c,frameAgreement.id,true);//// EDGE-194529-- Changes added
                
                //This code has written to update old PS agreement status in Being Amended
                AgreementOrderUtilities.agreementStatusUpdate(oldPSRecord,AGREEMENT_Status_CATEGORY,AGREEMENT_Status); // write it locally 
                
                //This Part of code has written to Create Related Agreement record's of Amended PS agreement and old PS agreement
                if(newVariationPSAgreement!=null){
                    amendedAgmts.put(oldPSRecord.Id,newVariationPSAgreement.id);
                    APTPS_CreateAgreementVariationController aptsVariationController= new APTPS_CreateAgreementVariationController ();
                    aptsVariationController.createRelatedAgreement(amendedAgmts);
                }
                //This Part of code has written to Create Agreement Line Items records 
                // EDGE-194529-- Changes start here
                list<Id> agreementLineItemsIds=null;
                if(aliCreationSet.size()>0)
                    //    agreementLineItemsIds=AgreementOrderUtilities.createAgreementLineItem(newVariationPSAgreement.id,aliCreationSet);
                    agreementLineItemsIds=createPSAgreementLineItems(newVariationPSAgreement.id,aliCreationSet,NULL); 
                //This Part of code has written to Create Attributes records 
                if(attributeCreationSet.size()>0)
                    createAttributeOnAgmtLineIem(relatedDPROLI,agreementLineItemsIds);
                // EDGE-194529-- Changes End here
                
                if(faDefaultRecordlst.size()>0){ // "{"This is added as a part of DIGI-19273
                    // DIGI-19273 Start Added IF Condition
                    // Need Confirmation from Ravi to Uncomment this below condition for variation scenario //(FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe')
                    // if( FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign') && newVariationPSAgreement.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                    AgreementUtilities.insertDocusignRecipient(newVariationPSAgreement,faDefaultRecordlst[0],null);
                    // }
                }//End "}" This is added as a part of DIGI-19273
                else {
                    // DIGI-19273 Start Added IF Condition
                    // Need Confirmation from Ravi to Uncomment this below condition for variation scenario //(FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe')
                    // if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign')  && newVariationPSAgreement.Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                    AgreementUtilities.insertDocusignRecipient(newVariationPSAgreement,null,oppContactRole);
                    //  }
                }//End "}" This is added as a part of DIGI-19273
                
                
                //List<Apttus__APTS_Template__c> templateList = ];//EDGE-193826 Added CoverSheet parameters
                Map<String,Id> templateMap = new Map<String,Id>();
                for(Apttus__APTS_Template__c temp:[select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where (name =:Label.DSA_Agreement_Template or name =:Label.PS_Deal_Agreement_Template or name =:Label.PS_Agreement_CoverSheet) and Apttus__IsActive__c = true and (Apttus__Type__c= 'Agreement' OR Apttus__Type__c = 'Supporting Document')]){
                    if(temp.name == Label.PS_Agreement_CoverSheet){
                        templateMap.put('CoverSheet', temp.Id);
                    }
                    else if(temp.name ==Label.PS_Deal_Agreement_Template){
                        templateMap.put('Price Schedule', temp.Id);
                    }
                }
                system.debug('templateMap == '+templateMap);
                if(newVariationPSAgreement != null){
                    AgreementUtilities.generateAgreement(newVariationPSAgreement.Id,templateMap.get('CoverSheet'));
                    AgreementUtilities.generateAgreement(newVariationPSAgreement.Id,templateMap.get('Price Schedule'));
                }
                
                
                
            }
        }
        
    }
    /*@Description : This method helps ot Process the DPR OLI records and check where the Sale Eligibility Meets the critieria
* @Param : delegatedPriceRequestId
* @Param : agreementRecordInstance
* @Return : Apttus_APTS_Agreement__c
* @UserStroy : DIGI-7386
*/
    public static Apttus__APTS_Agreement__c examinDPROLICommercialProductSaleEligibility(Id delegatedPriceRequestId, Apttus__APTS_Agreement__c agreementRecordInstance){
        List<DPR_Offer_Line_Item__c> listOfDPROfferLineItems;
        if(DPR_Offer_Line_Item__c.sObjectType.getDescribe().isAccessible())
            listOfDPROfferLineItems= new List<DPR_Offer_Line_Item__c>([SELECT cspmb_Price_Item__c,cspmb_Price_Item__r.Sale_Eligibility__c,  Id FROM DPR_Offer_Line_Item__c WHERE Delegated_Pricing_Request__c =: delegatedPriceRequestId AND (cspmb_Price_Item__r.Sale_Eligibility__c!= null AND cspmb_Price_Item__r.Sale_Eligibility__c=: APTPS_Constants.INVITE_ONLY) ]);
        if(listOfDPROfferLineItems.size()>0){
            //System.debug('Success - examinDPROLICommercialProductSaleEligibility ->'+listOfDPROfferLineItems);
            agreementRecordInstance.Sale_Eligibility__c=APTPS_Constants.INVITE_ONLY;
        }
        //System.debug('fail - examinDPROLICommercialProductSaleEligibility ->'+listOfDPROfferLineItems);
        return agreementRecordInstance;
    }
    public class agreementVariationDetails {
        
        @AuraEnabled
        public string Product { get; set; }
        @AuraEnabled
        public string ALI { get; set; }
        @AuraEnabled
        public string Attribute { get; set; }
        @AuraEnabled
        public string VariationAdd { get; set; }
        @AuraEnabled
        public string VariationModify { get; set; }
    }
}
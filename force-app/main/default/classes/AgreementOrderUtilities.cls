/**
* @Author     :   Rahul 
* @Date       :   Jan 2021
* @Desc       :   This class is written for Order agreement Variation .
* @Initial US :   EDGE-193827
* @Status     :   Deveopment is still pending.
* 
* Shashank Jadhav: 07/04/2021 EDGE-203816-Price Schedule Apttus Contract:Updating DPR Offer on Agreement Line Items
* Shashank Jadhav   28/05/2021    EDGE-221893-Insert Exception Log records with Exception Log Frameworks
* Aniket 20/07/2021: Refactored class as per TED-104 capability
* Lokesh Thathuru : 11/08/2021 DIGI-434 added Case Creation Logic
* Lokesh Thathuru : 23/08/2021 DIGI-15323
* Lokesh Thathuru : Update DIGI-7386
* Lokesh Thathuru : Update DIGI-19273 
*/
public with sharing class AgreementOrderUtilities{
    private static String agreementCategory = 'Digital Services';
    private static final Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    //EDGE-219001 
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    //@future(callout=true)
    public static void createPriceScheduleVariation(String contractJunctionRecordString,String prBasketRecordString){
        ContractJunction__c cjRecord = new ContractJunction__c();
        cscfga__Product_Basket__c ProductBasket = new cscfga__Product_Basket__c();
        List<Apttus__APTS_Agreement__c> PSAgreementRecord= null;
        List<Apttus__APTS_Agreement__c> agmtList;
        try{
            cjRecord=(ContractJunction__c) Json.deserialize(contractJunctionRecordString, System.Type.forName('ContractJunction__c'));
            ProductBasket=(cscfga__Product_Basket__c) Json.deserialize(prBasketRecordString, System.Type.forName('cscfga__Product_Basket__c'));
            if(cjRecord!=null){
                //DIGI-16609
                String accountId='';
                if(cjRecord.RelatedAccount__c!=null){
                    accountId=cjRecord.RelatedAccount__c;
                }else{
                    accountId= ProductBasket.csbb__Account__c;
                }
                //EDGE-134661--APTPS_Constants.apttusStatusCategory moved in to APTPS_Constants
                PSAgreementRecord=[select Id, Name, VariationNotApplicable__c,Apttus__FF_Agreement_Number__c,Apttus__Term_Months__c,Apttus__Contract_End_Date__c, APTPS_Parent_Agreement_Id__c,Apttus__Status_Category__c, APTPS_Title__c,
                                   
                                   Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                   APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate,Apttus__Source__c,Related_Basket__c,Apttus__Related_Opportunity__c,Auto_Created_by_Basket__c,APTPS_variationAdd__c,Variation_Applicable__c from Apttus__APTS_Agreement__c where Apttus__Status_Category__c IN: APTPS_Constants.apttusStatusCategory AND Apttus__Account__c =:accountId AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId = :AGREEMENT_Schedule_RECORDTYPEID AND  (Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c =:APTPS_Constants.DSA_AGMT_CATEGORY OR Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c =:APTPS_Constants.BSA_AGMT_CATEGORY) AND Apttus__Parent_Agreement__r.Apttus__Source__c =:APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ORDER BY CreatedDate DESC LIMIT 1];
            }
            system.debug('PSAgreementRecord:'+ PSAgreementRecord[0].id+':'+PSAgreementRecord[0].Apttus__Status__c+':'+PSAgreementRecord[0].Apttus__Source__c+':'+PSAgreementRecord[0].Related_Basket__c);
            system.debug('TestClass:'+ cjRecord.Contract_Type__c+':' + PSAgreementRecord[0].VariationNotApplicable__c);
            if(PSAgreementRecord.size()>0)  {
                if(String.isEmpty(PSAgreementRecord[0].APTPS_variationAdd__c)==false &&  PSAgreementRecord[0].Variation_Applicable__c){                                    
                    map<String,Id> mapoffamilywithAgreementlineItemId= new map<String,Id>();
                    Map<Id,Id> amendedAgmts= new Map<Id,Id>();
                    Apttus__APTS_Agreement__c newPSAgreement = null;
                    Set<String> setPrdctFamily= new Set<String>();
                    String variationValue='';
                    for(String spltFamily : (PSAgreementRecord[0].APTPS_variationAdd__c).split(',')){
                        setPrdctFamily.add(spltFamily);
                        variationValue=variationValue+'- '+ spltFamily +'\n' ;
                    }
                    
                    //This part of code has written to insert variation/Amendment Record of PS Agreement
                    newPSAgreement = Apttus.AgreementWebService.amendAgreement(PSAgreementRecord[0].Id);
                    newPSAgreement.APTPS_Parent_Agreement_Id__c = PSAgreementRecord[0].APTPS_Parent_Agreement_Id__c;
                    newPSAgreement.Related_Basket__c=ProductBasket.id;
                    newPSAgreement.Delegated_Pricing_Request__c=null;
                    newPSAgreement.Apttus__Related_Opportunity__c=ProductBasket.cscfga__Opportunity__c;
                    if(cjRecord.RelatedAccount__c!=null){
                        newPSAgreement.Apttus__Account__c=cjRecord.RelatedAccount__c;
                    }else{
                        newPSAgreement.Apttus__Account__c= ProductBasket.csbb__Account__c;
                    }
                   // newPSAgreement.Apttus__Account__c=ProductBasket.csbb__Account__c;
                    newPSAgreement.Auto_Created_by_Basket__c=true;
                    newPSAgreement.Related_Contract__c=cjRecord.id;
                    newPSAgreement.APTPS_variationAdd__c=variationValue;
                    newPSAgreement.Variation_Applicable__c=false;
                    newPSAgreement.APTPS_Show_After_E_Signature_Buttons__c=true;
                    
                    newPSAgreement.Apttus__Term_Months__c=PSAgreementRecord[0].Apttus__Term_Months__c;
                    
                    //EDGE-193826 Start
                    newPSAgreement.APTPS_Sales_Account_Executive__c =  cjRecord.DocuSign_Signer_3__c;
                    newPSAgreement.APTPS_Contract_Manager__c = cjRecord.DocuSign_Signer_3__c;
                    newPSAgreement.APTPS_Commercial_Manager__c = cjRecord.DocuSign_Signer_3__c;
                    List<user> signer_3 = [SELECT id,email from user where id = :cjRecord.DocuSign_Signer_3__c];
                    newPSAgreement.APTPS_Sales_Account_Executive_email__c=signer_3[0].email;
                    newPSAgreement.APTPS_Customer_Primary_Contact__c = cjRecord.DocuSign_Signer_2__c;
                    newPSAgreement.Apttus__Other_Party_Signed_By__c=cjRecord.DocuSign_Signer_2__c;
                    //EDGE-193826 End
                    insert newPSAgreement;
                    system.debug('newPSAgreement::@@' + newPSAgreement.id+':'+newPSAgreement.Apttus__Status__c+':'+newPSAgreement.Apttus__Source__c+':'+newPSAgreement.Related_Basket__c);
                    
                    //This part of code has written update old PS agreement after amendment call
                    agreementStatusUpdate(PSAgreementRecord[0],APTPS_Constants.IN_EFFECT_STATUS_CATEGORY,APTPS_Constants.BEINGAMENDED_STATUS);
                    
                    //This Part of code has written to Create Related Agreement record's of Amended PS agreement and old PS agreement
                    if(newPSAgreement!=null){
                        amendedAgmts.put(PSAgreementRecord[0].Id,newPSAgreement.id);
                        APTPS_CreateAgreementVariationController aptsVariationController= new APTPS_CreateAgreementVariationController ();
                        aptsVariationController.createRelatedAgreement(amendedAgmts);
                    }
                    //This Part of code has written to clone agreement Line items from ols PS Agreements
                    List<Apttus__agreementlineitem__c> agrLineItemCloneInsertList= new List<Apttus__agreementlineitem__c>();
                    for(Apttus__agreementlineitem__c agreementLineItems:[select id,Apttus__ProductId__c,Product__c,isNegotiated__c from Apttus__agreementlineitem__c where Apttus__AgreementId__c=:PSAgreementRecord[0].id]){
                        Apttus__agreementlineitem__c agreementLineItemClone = agreementLineItems.clone(false, true);//(false, true, false, false);
                        agreementLineItemClone.Apttus__AgreementId__c=newPSAgreement.id;
                        agrLineItemCloneInsertList.add(agreementLineItemClone);
                    }
                    
                    if(agrLineItemCloneInsertList.size()>0){
                        insert agrLineItemCloneInsertList;
                        
                    }
                    
                    system.debug('Before AggrementCreation');
                    //This part of code has written to insert Agreement Line Items
                    list<Id> agreementLineItemsIds = AgreementUtilities.createAgreementLineItem_RF(newPSAgreement.Id,setPrdctFamily, NULL); 
                    system.debug('Before Recipientcreation');
                    //EDGE-193826 Start
                    agmtList = new List<Apttus__APTS_Agreement__c>{newPSAgreement};
                    // DIGI-19273 Start Added IF Condition
                    // Need Confirmation from Ravi to Uncomment this below condition for variation scenario
                    // update the below if condition (FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe') 
                    // if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign')  && agmtList[0].Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                       insertDocusignRecipients(cjRecord,agmtList);
                    //}//End DIGI-19273
                    system.debug('After Recipientcreation');
                    generateAgreements(agmtList,true);
                    cjRecord.Related_Price_Schedule__c = newPSAgreement.Id;
                    //EDGE-193826 End
                    cjRecord.Initiated_document_Generation__c =true;
                    update cjRecord;
                    
                }
                
                else if(cjRecord.Contract_Type__c=='DSA' && PSAgreementRecord[0].VariationNotApplicable__c == 'NoAgreeement'){
                    cjRecord.Restrict_Conga_Flow__c = false;
                    update cjRecord;
                    List<cscfga__Product_Basket__c> basketList = new List<cscfga__Product_Basket__c>();
                    
                    cscfga__Product_Basket__c prodBasket= new cscfga__Product_Basket__c();
                    if(cjRecord.Related_Basket__c!=null){
                        prodBasket.id=cjRecord.Related_Basket__c;
                        
                        
                        //update outgoing basket stage EDGE-191759 and EDGE-216340 start Shweta
                        cscfga__Product_Basket__c incomingBasket = [SELECT Id,csordtelcoa__Previous_Product_Basket__c,BasketType__c FROM cscfga__Product_Basket__c
                                                                    WHERE ID =: prodBasket.id]; 
                        if(incomingBasket.BasketType__c == 'Incoming' && incomingBasket.csordtelcoa__Previous_Product_Basket__c != null){    
                            cscfga__Product_Basket__c outgoingBasketRecord = chownProductBasketUtil.changeBasketStageForChown(incomingBasket.csordtelcoa__Previous_Product_Basket__c);
                            basketList.add(outgoingBasketRecord);  
                        }
                        update basketList;
                        //update outgoing basket stage EDGE-191759 and EDGE-216340 END
                    }
                }
            }
            
            
        }
        catch(Exception ex){
            String businessDescription = 'Creation of Variation PS record failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber()+' for Basket Id:'+ProductBasket.Id;
            AgreementException agEx = new AgreementException('createPriceScheduleVariation',!(String.isBlank(ProductBasket.id)) ? String.valueOf(ProductBasket.id) : '' ,ex.getMessage(),businessDescription); //added condition to check if the pd.Id is not null 
            //throw agEx; 
            AgreementUtilities.logException(agEx.methodName, agEx.referenceNumber, '', agEx.errorMessage, agEx.businessDescription); // Added the Exception Logging Lokesh Thathuru (10/13/2021)
        }
    }
    
    
    
    public static void agreementStatusUpdate(Apttus__APTS_Agreement__c PSAgreementRecord,String agrStatusCategory,String agrStatus){
        
        PSAgreementRecord.Apttus__Status_Category__c = agrStatusCategory;
        PSAgreementRecord.Apttus__Status__c = agrStatus;
        update PSAgreementRecord;
        system.debug('agmtupdate::@@' + PSAgreementRecord.id+':'+PSAgreementRecord.Apttus__Status__c+':'+PSAgreementRecord.Apttus__Source__c+':'+PSAgreementRecord.Related_Basket__c);
    }
    
    public static list<Id> createAgreementLineItem(Id agreementId, set<String> productFamily){
        List<Apttus__agreementlineitem__c> insertAgreementlineitems= new List<Apttus__agreementlineitem__c>(); 
        List<Apttus__AgreementLineItem__c> agreementLineItemslist=[select name,Product__c from Apttus__AgreementLineItem__c where Product__c=:productFamily and Apttus__AgreementId__c=:agreementId];
        set<String> productName = new set<string>();
        try{//EDGE-221893: Added try block
            if(agreementLineItemslist.size()==0 && agreementId!=null){
                list<Product2> prodReclst = [SELECT id, Name FROM Product2 where name  =: productFamily];
                Set<Product2> prodrec = new Set<Product2>(prodReclst);
                system.debug('@@@@@@set '+prodrec);
                if(prodrec.size()>0){
                    for(Product2 prod: prodrec){
                        system.debug('prod.name'+prod.name+productName);
                        if(!productName.contains(prod.Name)){
                            productName.add(prod.Name);  
                            Apttus__agreementlineitem__c AgreementLineItem = new Apttus__agreementlineitem__c();
                            AgreementLineItem.Apttus__AgreementId__c =agreementId;
                            AgreementLineItem.Apttus__ProductId__c = prod.Id;
                            //EDGE-203816-Price Schedule Apttus Contract-Start
                            AgreementLineItem.isNegotiated__c=true;
                            if(!AgreementUtilities.mapOfPFWithDPRID.isEmpty() && AgreementUtilities.mapOfPFWithDPRID.containsKey(prod.Name))
                                AgreementLineItem.DPR_Offer__c = AgreementUtilities.mapOfPFWithDPRID.get(prod.Name);
                            //EDGE-203816-Price Schedule Apttus Contract-End
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
            new CreateExceptionLog().logException(C2O_ExceptionHandler.Capability.AGR,'Agreement','createAgreementLineItem', '', agreementId, ex.getMessage(), 'Generation of Agreement Document Failed.',false);
        }//EDGE-221893-End
        
        return null;       
    }
    
public static set<String> productFamilySet = new set<String>();
    
    public static set<String> getMarketableOffer(Id basketId, String contractType){
        try{
            if (productFamilySet != null && !productFamilySet.isEmpty())
                return productFamilySet;
            
            
            list<cscfga__Product_Configuration__c> pcConfig = [SELECT id, Name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId]; 
            if(pcConfig != null && pcConfig.size() > 0){
                for(cscfga__Product_Configuration__c pcForMarketOffer : pcConfig ){
                    if(pcForMarketOffer.Marketable_Offer__r.Contract_Type__c == contractType && pcForMarketOffer.Marketable_Offer__r.Contract_Type__c != ''){
                        if(pcForMarketOffer.Marketable_Offer__r.Product_Family__c != null)
                            productFamilySet.add(pcForMarketOffer.Marketable_Offer__r.Product_Family__c);
                    }
                }
            }
            
            system.debug( ' <<--productFamilySet--> '+productFamilySet );
            if(productFamilySet.size() > 0)  
                return productFamilySet;
            else{
                return null;
            }
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Fetching of marketable offer failed for basket id:'+ basketId +' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('getMarketableOffer',basketId,ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
    }
    
    
    //EDGE-194529 Start
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
    
    
    //EDGE-194529 End
    
    //EDGE-219001 Start
    //DIGI-434 changed the return type to AgreementUtilities.AgreementDecision from void
    public static AgreementUtilities.AgreementDecision createAgreementRecords(ContractJunction__c conJun, cscfga__Product_Basket__c prodBasket, Opportunity opp, AgreementUtilities.AgreementDecision decision) {
        system.debug('Checkpoint 1:'+Limits.getQueries());
        Integer startTime = System.Now().millisecond();
        Apttus__APTS_Agreement__c agmtSA;
        Apttus__APTS_Agreement__c agmtPS;
        List<Apttus__APTS_Agreement__c> agmts;
        //DIGI-434 moved the below code from inside try block to outside 
        AgreementUtilities.AgreementDecision agmtDecResult=new AgreementUtilities.AgreementDecision();
        try{
            if(decision==null){
                agmtDecResult = resolveSAType(conJun, prodBasket, opp);  
            }else{
                agmtDecResult=decision;
            }
            system.debug('Checkpoint 2:'+ Limits.getQueries());
            /** if the Legacy Agreement Detected then create case */
            /** DIGI-434 STARTED - Added the below code to create the Case by Lokesh Thathuru */
            if(agmtDecResult.caseCreation==true){
                List<String> listOfLegacyMatchedProductFamilies = new List<String>(agmtDecResult.legacyPFMatchedSet);
                String caseDescription='Legacy agreement detected for product families: '+String.join(listOfLegacyMatchedProductFamilies,',') +'. '+
                ' A digital contract executed for product families:'+String.join(listOfLegacyMatchedProductFamilies,',') +'  through Basket '+ prodBasket.Name +' could not be continued,'+
                ' as there is an active legacy agreement for product families:'+String.join(listOfLegacyMatchedProductFamilies,',') +'.'+
                ' The existing Agreement needs to be updated for the digital contract to proceed.';
               String subject='Action required: Legacy Agreements containing '+String.join(listOfLegacyMatchedProductFamilies,',') +' undergoing digitization';
               Id aCMUserIdorCMGUserId=null;
               if(prodBasket.csbb__Account__r.APTPS_Contract_Manager__c!=null){
                aCMUserIdorCMGUserId=prodBasket.csbb__Account__r.APTPS_Contract_Manager__c;
               }else{
                   //DIGI-15323
                   if(user.sObjectType.getDescribe().isAccessible())
                aCMUserIdorCMGUserId=[SELECT id from User WHERE Name = 'Contract Management Group'].Id;
               }
               Case caseInstance =AgreementUtilities.generateContractSupportCase( caseDescription, aCMUserIdorCMGUserId ,subject,opp.Id);
                
                // Case Insertion for Legacy Contracts. and check the access and perform the DML
               if(caseInstance!=null &&  Case.sObjectType.getDescribe().isAccessible() && Case.sObjectType.getDescribe().isCreateable()){
                    insert caseInstance;
                }
               System.debug('caseCreation!@@!@@!'+caseInstance);
               agmtDecResult.caseNumber= [SELECT id,CaseNumber FROM Case WHERE id=:caseInstance.Id].CaseNumber;  
            }/**  DIGI-434 ENDED added the else if block below */
            else if(agmtDecResult.parentSAAgreement ==null){//Create SA/PS first time
                system.debug('Checkpoint 3:'+ Limits.getQueries());
                agmtSA = createSAAgreement(conJun,agmtDecResult); 
                system.debug('Checkpoint 4:'+ Limits.getQueries());
                agmtPS = createPSAgreement(agmtSA); 
                system.debug('Checkpoint 5:'+ Limits.getQueries());
                createPSAgreementLineItems(prodBasket,agmtPS);
                system.debug('Checkpoint 6:'+ Limits.getQueries());
                agmts = new List<Apttus__APTS_Agreement__c>{agmtSA,agmtPS};
                // DIGI-19273 Start Added the If Condition // (FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnableForAll__c!=true ||  FeatureToggle__mdt.getInstance('eSign_Apttus_Digital').EnabledFlows__c!='adobe') 
                if(FeatureEligibilityChecker.determineFeatureEligiblity('eSign_Apttus_Digital','docusign') && agmts[0].Apttus__Source__c==APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL ){
                    insertDocusignRecipients(conJun,agmts);
                }//End
                system.debug('Checkpoint 7:'+ Limits.getQueries());
                generateAgreements(agmts,false);
                system.debug('Checkpoint 8:'+ Limits.getQueries());               
            } else if(agmtDecResult.parentSAAgreement !=null){//Digital agreement already exists on Account.
                system.debug('agmtDecResult.PFDifferenceList:' + agmtDecResult.PFDifferenceList);
                Boolean isShared = ContentDocumentLinkContract.shareAgreementVariation(agmtDecResult.parentPSAgreement);
                Apttus__APTS_Agreement__c psAgmtUpdate = new Apttus__APTS_Agreement__c();
                psAgmtUpdate.Id = agmtDecResult.parentPSAgreement;
                
                if(agmtDecResult.variationRequired == false){//Digital Agreement already present account but no difference in current and existing PFs
                    psAgmtUpdate.VariationNotApplicable__c = 'NoAgreeement';
                }
                else{
                    psAgmtUpdate.APTPS_variationAdd__c = String.join(agmtDecResult.PFDifferenceList, ',');
                    psAgmtUpdate.VariationNotApplicable__c = null;//DIGI-683
                }
                psAgmtUpdate.APTPS_Validation_on_Fully_Signed__c = true;
                psAgmtUpdate.Variation_Applicable__c = true;
                if(isShared == true)
                    update psAgmtUpdate;
                
                String contractJunctionRecordString = Json.serialize(conJun);
                String prBasketRecordString=Json.serialize(prodBasket);
                ID jobID = System.enqueueJob(new QuoteContractQueueable(contractJunctionRecordString,prBasketRecordString));
            }
            Integer endTime = System.Now().millisecond();
            System.debug ('#### AgreementOrderUtilities::CreateAgreementRecords execution finished in '+ (endTime-startTime) +' milli seconds');
        }
        catch(AgreementException agEx){
            throw agEx;
        }
        catch(Exception ex){
            String businessDescription = 'Creation of Agreements failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber()+' for Basket Id:'+prodBasket.Id;
            AgreementException agEx = new AgreementException('createAgreementRecords',String.valueOf(prodBasket.id),ex.getMessage(),businessDescription);
            throw agEx; 
        }  
         
        return agmtDecResult;//DIGI-434 added the return type

    }
    
    public static Apttus__APTS_Agreement__c createSAAgreement(ContractJunction__c conJun,AgreementUtilities.AgreementDecision agmtDecResult){
        Apttus__APTS_Agreement__c agmtSA;
        try{
            String agmtCat = '';
            If(agmtDecResult.saType == 'DSA')
                agmtCat = APTPS_Constants.DSA_AGMT_CATEGORY;
            else if(agmtDecResult.saType == 'BSA')
                agmtCat = APTPS_Constants.BSA_AGMT_CATEGORY;
            system.debug('Checkpoint 10:'+Limits.getQueries());
            agmtSA = AgreementUtilities.createSAAgreement(agmtCat);
            system.debug('Checkpoint 11:'+Limits.getQueries());
            updateSAAgreementforOrderFlow(agmtSA,conJun);
            system.debug('Checkpoint 15:'+Limits.getQueries());
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        
        catch(Exception ex){
            String businessDescription = 'Creation of SA Agreement failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber()+' for Contract Id:'+conJun.Id;
            AgreementException agEx = new AgreementException('createSAAgreement',String.valueOf(conJun.id),ex.getMessage(),businessDescription);
            throw agEx; 
        }
        return agmtSA;
    }
    
    public static Apttus__APTS_Agreement__c createPSAgreement(Apttus__APTS_Agreement__c  agmtSA){
        Apttus__APTS_Agreement__c agmtPS;
        try{
            agmtPS = AgreementUtilities.createPSAgreement(agmtSA);
            insert agmtPS;
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        
        catch(Exception ex){
            String businessDescriptionEX = 'Creation of PS agreement for SA Agreement Id:'+ agmtSA.Id +' failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('createPSAgreement',String.valueOf(agmtSA.Id),ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
        return agmtPS;
    }
    
    public static void createPSAgreementLineItems(cscfga__Product_Basket__c prodBasket,Apttus__APTS_Agreement__c  agmtPS){
        
        set<String> currentPF = getMarketableOffer(prodBasket.id, 'DSA');
        try{
            list<Id> agreementLineItemsIds = AgreementUtilities.createAgreementLineItem_RF(agmtPS.Id,currentPF, NULL); 
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        
        
        
        
    }
    public static void insertDocusignRecipients(ContractJunction__c conJun,List<Apttus__APTS_Agreement__c> agmts){
        try{
            sObject customerContact = [SELECT Id,Email,Phone,Fax,Owner.Title,FirstName,LastName FROM Contact WHERE Id=:conJun.DocuSign_Signer_2__c];
            sObject companyContact = [SELECT Id,Email,Phone,FirstName,LastName FROM User WHERE Id=:conJun.DocuSign_Signer_3__c];
            AgreementUtilities.insertDocusignRecipients(agmts,customerContact,companyContact);
        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Insertion of docusign recipients failed for agreements related to contract id:'+ conJun.Id +' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('insertDocusignRecipients',conJun.id,ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
    }
    
    public static void updateSAAgreementforOrderFlow(Apttus__APTS_Agreement__c AgmtRecord,ContractJunction__c contJun) {
        try{
            AgmtRecord.APTPS_Customer_Primary_Contact__c = contJun.Customer_Primary_Contact__c;
            AgmtRecord.Apttus__Account__c = contJun.Account__c;
            AgmtRecord.Related_Contract__c = contJun.Id;
            AgmtRecord.Apttus__Related_Opportunity__c = contJun.Related_Opportunity__c;
            AgmtRecord.Related_Basket__c = contJun.Related_Basket__c;
            AgmtRecord.APTPS_Sales_Account_Executive__c = Id.valueOf(contJun.DocuSign_Signer_3__c);
            system.debug('Checkpoint 12:'+Limits.getQueries());
            AgmtRecord.Apttus__Term_Months__c = getContractTermforBasket(contJun.Related_Basket__c);
            system.debug('Checkpoint 13:'+Limits.getQueries());
            //DIGI-7386 Logic  started
            //Feature Toggle is Enabled for the below code
            Boolean enableExaminFeatureForOrderFlow=FeatureEligibilityChecker.determineFeatureEligiblity('ExaminPCSaleEligibilityForOrderFlow', 'ExaminPCSaleEligibilityForOrderFlow');
            System.debug('examinPCSaleEligibility 01'+enableExaminFeatureForOrderFlow);
            if(enableExaminFeatureForOrderFlow){
                 AgmtRecord=examinPCSaleEligibility(contJun.Related_Basket__c,AgmtRecord); 
            }
            //DIGI-7386 End
            // DIGI-19273 Start
            AgmtRecord.Apttus__Primary_Contact__c =  Id.valueOf(contJun.Customer_Primary_Contact__c);
            AgmtRecord.APTPS_Contract_Manager__c =  Id.valueOf(contJun.DocuSign_Signer_3__c);
            // DIGI-19273 End
            insert AgmtRecord;
            system.debug('Checkpoint 14:'+Limits.getQueries());
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Updation of SA Agreement failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber()+' for Agreement Id:'+AgmtRecord.Id;
            AgreementException agEx = new AgreementException('updateSAAgreementforOrderFlow',String.valueOf(AgmtRecord.Id),ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }
        
        
    }
    
    
    public static void generateAgreements(List<Apttus__APTS_Agreement__c> agmtsList,boolean isVariationScenario){
        Id agmtId;
        try{
            Map<String,String> allConst = new Map<String,String>();
            allConst = getConstant();
            List<Apttus__APTS_Template__c> templateList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where (name =:allConst.get('DSATemplate') or name =:allConst.get('PSOrderTemplate') or name =:allConst.get('BSATemplate') or name =:allConst.get('Coversheet')) and Apttus__IsActive__c = true and (Apttus__Type__c= 'Agreement' OR Apttus__Type__c = 'Supporting Document')];
            Map<String,Id> templateMap = new Map<String,Id>();
            for(Apttus__APTS_Template__c temp:templateList){
                if(temp.name == allConst.get('DSATemplate')){
                    templateMap.put(allConst.get('DSATemplate'), temp.Id);
                }
                else if(temp.name== allConst.get('BSATemplate')){
                    templateMap.put(allConst.get('BSATemplate'),temp.Id);
                }
                else if(temp.name== allConst.get('PSOrderTemplate')){
                    templateMap.put(allConst.get('PSOrderTemplate'),temp.Id);
                }
                else if(temp.name== allConst.get('Coversheet')){
                    templateMap.put(allConst.get('Coversheet'),temp.Id);
                }
            }
            system.debug('templateMap == '+templateMap);
            for(Apttus__APTS_Agreement__c agmt:agmtsList){
                String agmtRecordString = Json.serialize(agmt);
                agmtId = agmt.Id;
                if(agmt.RecordTypeId == AGREEMENT_SA_RECORDTYPEID){
                    if(agmt.Apttus__Agreement_Category__c==APTPS_Constants.DSA_AGMT_CATEGORY){
                        system.debug('Calling for DSA');
                        generateAgreement(agmtRecordString,templateMap.get(allConst.get('DSATemplate')));
                    }  
                    else if(agmt.Apttus__Agreement_Category__c==APTPS_Constants.BSA_AGMT_CATEGORY){
                        system.debug('Calling for BSA');
                        generateAgreement(agmtRecordString,templateMap.get(allConst.get('BSATemplate')));
                    } 
                }
                else if(agmt.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){
                    system.debug('Calling for PS');
                    generateAgreement(agmtRecordString,templateMap.get(allConst.get('PSOrderTemplate')));
                    if(isVariationScenario){
                        generateAgreement(agmtRecordString,templateMap.get(allConst.get('Coversheet'))); 
                    }                    
                }
            }        }
        catch(AgreementException agEx){
            throw agEx; 
        }
        catch(Exception ex){
            String businessDescriptionEX = 'Generation of agreement docs failed for agreement id:'+agmtId+' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('generateAgreements',agmtId,ex.getMessage(),businessDescriptionEX);
            throw agEx; 
        }        
    }
    
    @Future(callout=true)
    public static void  generateAgreement(String agreementRecordString, Id templateId)
    {  
        Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();
        //Getting the session Id of the user
        String apiSessionId = UserInfo.getSessionId(); 
        String pLevel = 'Insert comments and tracked changes only'; 
        String docFormat = 'DOCX'; 
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
        
        //String generatedDocId = null;
        Id generatedDocId;
        try{
            agmt=(Apttus__APTS_Agreement__c) Json.deserialize(agreementRecordString, System.Type.forName('Apttus__APTS_Agreement__c'));
          if(!Test.isRunningTest()) {
                System.debug('Inside the method agreementId: '+ agmt.id);
                System.debug(' Inside the method templateId: '+ templateId);
                system.debug('agmt.RecordType.Name:'+agmt.RecordType.Name);
                generatedDocId = Apttus.MergeWebService.generateDoc2(templateId, agmt.Id,pLevel, docFormat, false, apiSessionId, apiServerURL);//For INC000095158163 changed waterMark variable to false  
                system.debug('generatedDocId ===  '+generatedDocId );
                if(generatedDocId != null && agmt.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){
                    system.debug('Inside order form if else');
                    backUpdateContractRecord(agmt);
                }
            }
        }
        
        catch(CalloutException ex){
            String businessDescription = 'Generation of agreement docs failed for agreement record:'+ agmt.Id +' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            Agreementutilities.logException('generateAgreement',agmt.Id,'',ex.getMessage(),businessDescription);
            
        }catch(Exception ex){
            String businessDescription = 'Generation of agreement docs failed for agreement record:'+ agmt.Id +' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            Agreementutilities.logException('generateAgreement',agmt.Id,'',ex.getMessage(),businessDescription);
        }
    }
    
    public static void  backUpdateContractRecord(Apttus__APTS_Agreement__c agmtPS){  
        String psProductFamilies;
        try{
            system.debug('Inside order form '+agmtPS);
            List<Attachment> attachList = [select id,ParentId from Attachment where ParentId =:agmtPS.Id];
            if(attachList.size()>0){
                system.debug('Inside order form attachment  '+attachList);
                Apttus__APTS_Agreement__c agmtSA = [SELECT id,Apttus__Agreement_Category__c from Apttus__APTS_Agreement__c where id=:agmtPS.Apttus__Parent_Agreement__c];
                system.debug('Parent SA:'+agmtSA);
                ContractJunction__c contractRec = new ContractJunction__c(id=agmtPS.Related_Contract__c);
                if(agmtSA.Apttus__Agreement_Category__c == APTPS_Constants.DSA_AGMT_CATEGORY)
                  contractRec.isDSAGenerated__c =true;
                else if(agmtSA.Apttus__Agreement_Category__c == APTPS_Constants.BSA_AGMT_CATEGORY)
                  contractRec.BSA_Generated__c =true;
                    
                contractRec.Initiated_document_Generation__c = true;
                contractRec.Related_Price_Schedule__c = agmtPS.Id;
                contractRec.Agreement_Number__c = agmtPS.Apttus__FF_Agreement_Number__c;//Not set
                contractRec.Contract_Term_Months__c = agmtPS.Apttus__Term_Months__c;
                contractRec.Effective_End_Date__c = agmtPS.Apttus__Contract_End_Date__c;//Not set
                contractRec.Contract_Start_Date__c = agmtPS.Apttus__Contract_Start_Date__c;
                contractRec.Original_End_Date__c = agmtPS.Apttus__Contract_End_Date__c;//Not set
                system.debug('basket id ==>> '+agmtPS.Apttus__Parent_Agreement__r.Related_Basket__c);
                if(agmtPS.Apttus__Parent_Agreement__r.Related_Basket__c != null){
                    Set<String> productFamilySet = getMarketableOffer(agmtPS.Apttus__Parent_Agreement__r.Related_Basket__c,'DSA');
                    if(productFamilySet != null){
                        psProductFamilies = String.join(new List<String>(productFamilySet), ';');
                        contractRec.pricescheduleProductFamilies__c = psProductFamilies;//Not set
                    }
                }
                
                update contractRec;
                system.debug('contractRec >>> '+contractRec);
                
            }
            //}
        }
        catch(Exception ex){
            String businessDescription = 'Back Update of contract record failed for agreement id:'+ agmtPS.id +' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('createOrderForm',agmtPS.id,ex.getMessage(),businessDescription);
            throw agEx; 
        }
    }
    
    
   public static AgreementUtilities.AgreementDecision resolveSAType(ContractJunction__c conJun,cscfga__Product_Basket__c prodBasket,opportunity opp){
        system.debug('Inside resolveSAType');
        set <String > legacyPF = new set <String > ();
        AgreementUtilities.AgreementDecision decision = new AgreementUtilities.AgreementDecision();
        Boolean isLegacyAgmtPresent = false;
        Boolean isDigiAgmtPresent = false;
        Boolean isLegacyPFSame = false;
        List<id> legacySARecIdList = new List<id>(); 
        List<id> existingDigiSARecIdList = new List<id>();   
          Set<String> setOfBasketACCIdAndRelatedACCId=new Set<String>();        
        try{
              List<APTPS_Related_Companies__c> relCompany=[SELECT id, APTPS_Agreement__c, APTPS_Agreement__r.Apttus__Parent_Agreement__c,
                                                         APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Account__c 
                                                         FROM APTPS_Related_Companies__c
                                                         WHERE APTPS_Account__c = :prodBasket.csbb__Account__c 
                                                         AND (APTPS_Agreement__r.Apttus__Status_Category__c = 'In Effect' OR APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Status_Category__c = 'In Effect') 
                                                         AND APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c in ('Business Services') 
                                                         AND APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Source__c = 'Internal Digital'];
            setOfBasketACCIdAndRelatedACCId.add(prodBasket.csbb__Account__c);
            if(relCompany.size()>0){
                decision.RCAgreement  =relCompany[0].APTPS_Agreement__c;
                decision.DigBSARelatedAccount =relCompany[0].APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Account__c;
                setOfBasketACCIdAndRelatedACCId.add(relCompany[0].APTPS_Agreement__r.Apttus__Parent_Agreement__r.Apttus__Account__c);
            }
            List<Apttus__APTS_Agreement__c> agreementsInAcc = new List<Apttus__APTS_Agreement__c>();
            //Query all agreements records on Account(Legacy & Digital)
            //Changed where clause as per DIGI-9550. Added more status category apart from In Effect//DIGI-434 Added fields
            //DIGI-19515 Start
        if (FeatureEligibilityChecker.determineFeatureEligiblity('ShareAgmtWithPRM', 'Agreement')){
                system.debug('PRMSharingEnabled11');
            //agreementsInAcc = ContentDocumentLinkContract.shareAgreements(prodBasket.csbb__Account__c);
            agreementsInAcc = ContentDocumentLinkContract.shareAgreementsBulk(setOfBasketACCIdAndRelatedACCId);//DIGI-16609
            }
            else{
              system.debug('setOfBasketACCIdAndRelatedACCId'+setOfBasketACCIdAndRelatedACCId);  
            agreementsInAcc = [SELECT Id,Apttus__Source__c,RecordTypeId,Apttus__Parent_Agreement__c,Apttus__Status_Category__c,Name,Related_Basket__r.Name,Related_Basket__r.csbb__Account__c,Related_Contract__r.Account__r.APTPS_Contract_Manager__c, (SELECT Name, Product__c,Apttus__ProductId__r.Telstra_Marketable_Product_Family__c FROM Apttus__AgreementLineItems__r) from Apttus__APTS_Agreement__c where Apttus__Account__c IN:setOfBasketACCIdAndRelatedACCId AND Apttus__Status_Category__c=:APTPS_Constants.apttusStatusCategory AND Apttus__Status__c != 'Cancelled Request'];
            system.debug('PRMSharingDiabled22');
                system.debug('agreementsInAcc'+agreementsInAcc);
                
            }//DIGI-19515 End
            system.debug('agreementsInAcc'+agreementsInAcc);
             system.debug('setOfBasketACCIdAndRelatedACCId'+setOfBasketACCIdAndRelatedACCId);  
            for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                if(agreement.RecordTypeId == AGREEMENT_SA_RECORDTYPEID && agreement.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_PAPER){
                    isLegacyAgmtPresent =true;
                    legacySARecIdList.add(agreement.id);
                    continue;
                }
                if(agreement.RecordTypeId == AGREEMENT_SA_RECORDTYPEID && agreement.Apttus__Source__c == APTPS_Constants.SOURCE_VAL_INTERNAL_DIGITAL){
                    isDigiAgmtPresent = true;
                    existingDigiSARecIdList.add(agreement.id);
                }
            }
            // Check if Legacy Agreement is present - 1st pref
            if(isLegacyAgmtPresent==true){
                decision.sourceType = 'Paper';
                // If variation - create case for CCO
                /** DIGI-434 STARTED - added the below code by Lokesh Thathuru to identify case creation */
                // added the index to condition to check  
                //if(getDifferencePFsList(prodBasket,agreementsInAcc,legacySARecIdList).size()==0){ // commented this condition as a part of user story DIGI-434 added the if condition below
                    Set<String> setOfAgrrkeyMatchedProductFamilies=(Set<String>)getDifferencePFsList(prodBasket,agreementsInAcc,legacySARecIdList)[1];
                   
                    if(setOfAgrrkeyMatchedProductFamilies!=null && !setOfAgrrkeyMatchedProductFamilies.isEmpty()){
                       //create a case; 
                        decision.caseCreation=true;
                        decision.legacyPFMatchedSet=setOfAgrrkeyMatchedProductFamilies;
                        
                    }
                 /**  DIGI-434 by Lokesh Thathuru  ENDED */
                // If NOT a variation, proceed to check Digital Agreement. 
            }
            // Check if Digi Agreement is present - 2nd pref
            if(isDigiAgmtPresent == true){
                system.debug('Inside isDigiAgmtPresent ');
                
                //Check if Price Schedule variation required
                decision.PFDifferenceList = (List<String>)getDifferencePFsList(prodBasket,agreementsInAcc,existingDigiSARecIdList)[0]; // DIGI-434 - added the Index 0 to get the list of variationProductFamily changes are added by Lokesh Thathuru
                if(decision.PFDifferenceList != null && decision.PFDifferenceList.size() > 0){
                    decision.variationRequired = true;
                }
                else{
                    decision.variationRequired = false;
                }
                system.debug('decision.variationRequired:' + decision.variationRequired);
                decision.parentSAAgreement = existingDigiSARecIdList[0];
                decision.sourceType = 'Digital';
               
                //below code to set parentPSAgreement to record id of existing PS record
                for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                    if(agreement.Apttus__Parent_Agreement__c == existingDigiSARecIdList[0] && agreement.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){
                        decision.parentPSAgreement = agreement.id;
                        break;
                    }
                }
            }
            else{//Set parameters to create agreements first time.
                decision.variationRequired = false;
                decision.saType = opp.contract_type__c;            
            }
        }
        catch(Exception ex){
            String businessDescription = 'Business logic to get SA type failed for basket id:'+prodBasket.Id+' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('resolveSAType',prodBasket.id,ex.getMessage(),businessDescription);
            throw agEx;
        }
        
        return decision;
    }
    
    //Changed the DIGI-434 Return type to List<Object> from List<String> to handle the Case description
    public static List<Object> getDifferencePFsList(cscfga__Product_Basket__c prodBasket,List<Apttus__APTS_Agreement__c> agreementsInAcc,List<Id> SAAgreementIdsInAcc){
        list < String > variationProductFamily = New list < String > ();
        List<Object> listOfObjects=new List<Object>();
        Set<String> setOfAgrrkeyMatchedProductFamilies=new  Set<String>();
        set<String> existingPF = new set < String > ();
        set<String> currentPF = getMarketableOffer(prodBasket.Id, 'DSA');
        System.debug('#### PFs in the current basket: '+currentPF);
        system.debug('Inside getDifferencePFsList:'+prodBasket.Id+':'+agreementsInAcc+':'+SAAgreementIdsInAcc);
        try{
            for (Apttus__APTS_Agreement__c agreement: agreementsInAcc) {
                system.debug('agreement:'+agreement);
                if(SAAgreementIdsInAcc.contains(agreement.Apttus__Parent_Agreement__c) && agreement.RecordTypeId == AGREEMENT_Schedule_RECORDTYPEID){//Removed In Effect check as part of DIGI-9550
                    system.debug('PSagreement:'+agreement);
                    if (agreement.Apttus__AgreementLineItems__r != null) {
                        system.debug('agreement.Apttus__AgreementLineItems__r :'+agreement.Apttus__AgreementLineItems__r );
                        for (Apttus__AgreementLineItem__c agrLineItems: agreement.Apttus__AgreementLineItems__r) {
                            
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
                }/** DIGI-434 - else block is added by Lokesh Thathuru : STARTED*/
                 else if(existingPF.size()>0 && existingPF.contains(masterPF)){
                      system.debug('setOfAgrrkeyMatchedProductFamilies:'+ setOfAgrrkeyMatchedProductFamilies);
                    setOfAgrrkeyMatchedProductFamilies.add(masterPF);
                } 
                // else -  set of Matched Product Family      
                /**  DIGI-434 : ENDED else block  */
            }   
            system.debug('setOfAgrrkeyMatchedProductFamilies::'+ setOfAgrrkeyMatchedProductFamilies);
            /** DIGI-434  This block is added by Lokesh Thathuru : STARTED */
            if(variationProductFamily.size()>0){
                listOfObjects.add(variationProductFamily);
            }
            else{
                listOfObjects.add(null);
            }
            if(!setOfAgrrkeyMatchedProductFamilies.isEmpty()){
                listOfObjects.add(setOfAgrrkeyMatchedProductFamilies);
            }
            else{
                listOfObjects.add(null);
            }
            /**  DIGI-434 This block is added by Lokesh Thathuru : ENDED */

        }
        catch(Exception ex){
            String businessDescription = 'Method to get difference in product families failed in class AgreementOrderUtilities at line no:'+ex.getLineNumber() + ' for basket id:'+prodBasket.id;
            AgreementException agEx = new AgreementException('getDifferencePFsList',prodBasket.id,ex.getMessage(),businessDescription);
            throw agEx;
        } 
        system.debug('listOfObjects::'+ listOfObjects);
        //return variationProductFamily; commented by Lokesh Thathuru as a part of DIGI-434
        return listOfObjects; //Added New DIGI-434
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
            
        }
        catch(Exception ex){
       system.debug(ex.getMessage());
       } 
        return allConst; 
    }
    
    public static Integer getContractTermforBasket(Id basketId){
        AggregateResult[] groupedResults;
        try{
            groupedResults = [SELECT Max(cscfga__Contract_Term__c) max,max(cscfga__Product_Basket__r.cscfga__Opportunity__r.Contract_Term__c) maxopp FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Basket__c =: basketId]; //DIGI-32232
        }
        catch(Exception ex){
            String businessDescription = 'Method to get contract term for basket failed for basket id:'+basketId+' in class AgreementOrderUtilities at line no:'+ex.getLineNumber();
            AgreementException agEx = new AgreementException('getContractTermforBasket',basketId,ex.getMessage(),businessDescription);
            throw agEx;
        }
        system.debug('groupedResults' + groupedResults[0].get('max')+'::'+groupedResults[0].get('maxopp')); 
        
        if(groupedResults[0].get('max') != null)      //DIGI-32232  
        return Integer.valueOf(groupedResults[0].get('max'));
        else
        return Integer.valueOf(groupedResults[0].get('maxopp'));//DIGI-32232
    }  
    
 /*  commented as discussed with Aniket and Rahul
 public list < String > updateAgmtPSFlags(set < String > productFamilySet, Id accountId, String callFrom) {
    if (productFamilySet != NULL && productFamilySet.size() > 0) {
        set < String > existingPF = new set < String > ();
        set < String > existingPFClone = new set < String > ();//EDGE-194529
        // function call to agreement
        String recordTypePriceSchedule = 'Schedule';
        Id psAgreementId;
        list < String > variationProductFamily = New list < String > ();

        //Id AGREEMENT_Schedule_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
        List < Apttus__APTS_Agreement__c > existingPSAgreementOnAccount = [SELECT Id, RecordTypeId, name, Apttus__Agreement_Category__c, (SELECT Name, Product__c FROM Apttus__AgreementLineItems__r) FROM Apttus__APTS_Agreement__c WHERE Apttus__Status_Category__c IN: APTPS_Constants.apttusStatusCategory AND Apttus__Account__c =: accountId AND Apttus__Status__c != 'Cancelled Request' AND RecordTypeId = :AGREEMENT_Schedule_RECORDTYPEID AND Apttus__Parent_Agreement__r.Apttus__Agreement_Category__c =:agreementCategory  ORDER BY CreatedDate DESC LIMIT 1]; //EDGE-226364-- Added parent Agreement Agreement Category Condition
         //EDGE-134661--APTPS_Constants.apttusStatusCategory moved in to APTPS_Constants
        for (Apttus__APTS_Agreement__c agreementPS: existingPSAgreementOnAccount) {
            System.debug('*****existingPSAgreementOnAccount*****' + existingPSAgreementOnAccount);
            psAgreementId = agreementPS.Id;
            if (agreementPS.Apttus__AgreementLineItems__r != null) {
                for (Apttus__AgreementLineItem__c agrLineItems: agreementPS.Apttus__AgreementLineItems__r) {
                    existingPF.add(agrLineItems.Product__c);
                }
            }
        }
        System.debug('*****existingPF*****' + existingPF);
        //EDGE-194529 Start
        existingPFClone = existingPF.clone();
        System.debug('*****existingPFClone*****' + existingPFClone);
        List < agreementVariationDetails > psVarAgmtDetails = new List < agreementVariationDetails >();
        //EDGE-194529 End
        for (String masterPF: productFamilySet) {
            if (!existingPF.contains(masterPF) && existingPF != NULL && callFrom == 'OrderBasedFlow') {
                variationProductFamily.add(masterPF);
            }
            /*else if (existingPF != NULL && callFrom == 'DealBasedFlow') {
                variationProductFamily.add(masterPF);
            }*/
            //EDGE-194529 Start
           /* else if (existingPF != NULL && callFrom == 'DealBasedFlow') {
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
            }//EDGE-194529 End
        }
        //EDGE-194529 Start
        if (existingPF != NULL && callFrom == 'DealBasedFlow'){
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
                
        system.debug('JSON::' + string.valueof(JSON.serialize(psVarAgmtDetails)));  
        
        //EDGE-194529 End
        System.debug('*****variationProductFamily*****' + variationProductFamily);
        // update agreement with variationProductFamily
        if (((variationProductFamily != NULL && variationProductFamily.size() > 0) || psVarAgmtDetails!=null) && psAgreementId != NULL) {
            Boolean isShared = ContentDocumentLinkContract.shareAgreementVariation(psAgreementId);
            Apttus__APTS_Agreement__c psAgmtUpdate = new Apttus__APTS_Agreement__c();
            psAgmtUpdate.Id = psAgreementId;
            if(callFrom == 'DealBasedFlow'){
            //psAgmtUpdate.APTPS_Validation_on_Fully_Signed__c = true;
            //psAgmtUpdate.APTPS_VariationModify__c = String.join(variationProductFamily, ',');
            psAgmtUpdate.PS_Variation_Details__c = string.valueof(JSON.serialize(psVarAgmtDetails));
            //psAgmtUpdate.APTPS_Validation_on_Fully_Signed__c = true;
            //update psAgmtUpdate;
            }
            else if(callFrom == 'OrderBasedFlow') {
            psAgmtUpdate.APTPS_variationAdd__c = String.join(variationProductFamily, ',');
                if(variationProductFamily.size()==0){
                    psAgmtUpdate.VariationNotApplicable__c = 'NoAgreeement';
                }
            }
            psAgmtUpdate.APTPS_Validation_on_Fully_Signed__c = true;
            psAgmtUpdate.Variation_Applicable__c = true;
            if(isShared == true)
            update psAgmtUpdate;
        }
    }
    return null;
}*/
    
    
    /*@Description : This method helps ot Process the Product Configuration records and check where the Sale Eligibility Meets the critieria
    * @Param : basketId
    * @Param : agreementRecordInstance
    * @Return : Apttus_APTS_Agreement__c
    * @UserStroy : DIGI-7386
    */
    public static Apttus__APTS_Agreement__c examinPCSaleEligibility(Id basketId, Apttus__APTS_Agreement__c agreementRecordInstance){
        List<cscfga__Product_Configuration__c> listOfProductConfigurations;
        if(cscfga__Product_Configuration__c.sObjectType.getDescribe().isAccessible())
            listOfProductConfigurations= new List<cscfga__Product_Configuration__c>([SELECT Id, cscfga__Product_Basket__c, Sale_Eligibility__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId AND Sale_Eligibility__c=: APTPS_Constants.INVITE_ONLY ]);
        if(listOfProductConfigurations.size()>0){
            agreementRecordInstance.Sale_Eligibility__c=APTPS_Constants.INVITE_ONLY;
        }
        return agreementRecordInstance;
    }
  
    
}
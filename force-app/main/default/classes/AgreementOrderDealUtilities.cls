/**
* @Author     :   Maq/Rahul
* @Date       :   Jan 2021
* @Desc       :   This class is written for agreement Order to Deal contract validation Records.
* @Initial US :   EDGE-200025
* @Status     :   Deveopment is still pending.
* 
* */
public with sharing class AgreementOrderDealUtilities {

    /**
     * @Author   :   Maq
     * @Date     :   Jan 2021
     * @Desc     :   
     * @US       :   EDGE-200025/EDGE-194439
     * @Status   :   Development
     * */
    private static final string subTypeDigital='Digital';
    private static final String AGREEMENT_Status_CATEGORY = 'In Effect';
    private static final String AGREEMENT_Status = 'Being Amended';
    /**
     * @Author   :   Maq
     * @Date     :   Jan 2021
     * @Desc     :   <Delegated pricing journey - Customer moving from OCT pricing to negotiated price for same product family> 
     *               Identify variation and create CALMS agreements, agreement line items, attributes for newly created FA record
     * @US       :   EDGE-194439
     * @Status   :   Development
     * */
    public static set<String> getMarketableOfferDeal( List<Delegated_Pricing_Request__c> dprRequest, List<DPR_Offer_Line_Item__c> relatedDPROLI) {
        set<String> pFamily = new set<String>();
        system.debug('relatedDPROLI[0]::' + relatedDPROLI[0] + 'relatedDPROLI[0].Delegated_Pricing_Request__c' + relatedDPROLI[0].Delegated_Pricing_Request__c + 'relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__c' + relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__c);
            
        system.debug('relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId::' + relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId);
        if(dprRequest != NULL && dprRequest.size()> 0 && relatedDPROLI.size() > 0){
            system.debug('Inside dprRequest');
            if(relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId != NULL ){
                system.debug('relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId::' + relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId);
                //-- get All Unique product family from DPR_OLI
                for(DPR_Offer_Line_Item__c oli : relatedDPROLI){
                    pFamily.add(oli.Marketable_Offer__r.Product_Family__c);
                }      
            }
        }
        System.debug('*****pFamily*****' + pFamily);
    return pFamily;
    }
    
    /**
     * @Author   :   Maq
     * @Date     :   Jan 2021
     * @Desc     :   <Delegated pricing journey - Customer moving from OCT pricing to negotiated price for same product family> 
     *               Identify variation and create CALMS agreements, agreement line items, attributes for newly created FA record
     * @US       :   EDGE-200025
     * @Status   :   Development
     * */
    
    public static void priceScheduleVariationCreateForOrderToDeal(List<Delegated_Pricing_Request__c> dprRequest,List<DPR_Offer_Line_Item__c> relatedDPROLI,Apttus__APTS_Agreement__c PSOldAgreementRecord){
   
    Apttus__APTS_Agreement__c newVariationPSAgreement=null;
     Map<Id,Id> amendedAgmts= new Map<Id,Id>();
      map<String,Id> mapoffamilywithAgreementlineItemId= new map<String,Id>();
        if(dprRequest != NULL && dprRequest.size()> 0){
                if(dprRequest[0].id != NULL ){
                    csconta__Frame_Agreement__c frameAgreement = AgreementUtilities.fetchFrameAgreement(dprRequest[0].id);
                    OpportunityContactRole oppContactRole=null;
                    List<FA_DefaultRecipients__c> faDefaultRecordlst=[Select id, Signatory_1__c,Signatory_1__r.FirstName,Signatory_1__r.LastName,Signatory_1__r.Email,Signatory_2__c,Signatory_2__r.FirstName,Signatory_2__r.LastName,Signatory_2__r.Email,Apttus_Agreement__c from FA_DefaultRecipients__c where Deal_Pricing_Request__c=:dprRequest[0].id order by createddate desc limit 1];
                
                if(faDefaultRecordlst.size()==0)
                    oppContactRole=AgreementUtilities.fetchPrimaryContact(frameAgreement.Opportunity__c);
                   // EDGE-194529-- Changes Start from here
                    List<AgreementOrderUtilities.agreementVariationDetails> fieldList = (List<AgreementOrderUtilities.agreementVariationDetails>) JSON.deserialize(PSOldAgreementRecord.PS_Variation_Details__c, List<AgreementOrderUtilities.agreementVariationDetails>.class);

                    system.debug('fieldList '+fieldList );
                    set<String> variationAddSet= new set<String>();
                    set<String> variationModifySet= new set<String>();
                    set<String> aliCreationSet =new set<String>();
                    set<String> attributeCreationSet =new set<String>();

                        for(AgreementOrderUtilities.agreementVariationDetails agWrapperloop:fieldList ){
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
                    newVariationPSAgreement = Apttus.AgreementWebService.amendAgreement(PSOldAgreementRecord.Id);
                    newVariationPSAgreement.APTPS_Parent_Agreement_Id__c = PSOldAgreementRecord.APTPS_Parent_Agreement_Id__c;
                    newVariationPSAgreement.Apttus__Account__c=PSOldAgreementRecord.Apttus__Account__c ;
                    newVariationPSAgreement.Apttus__Term_Months__c=PSOldAgreementRecord.Apttus__Term_Months__c;
                    newVariationPSAgreement.Apttus__Related_Opportunity__c=dprRequest[0].Opportunity__c;
                    newVariationPSAgreement.Related_Contract__c=null;
                    newVariationPSAgreement.Related_Basket__c=null;
                    newVariationPSAgreement.APTPS_Show_After_E_Signature_Buttons__c=true;
                    newVariationPSAgreement.Apttus__Subtype__c=subTypeDigital;
                    newVariationPSAgreement.Delegated_Pricing_Request__c=dprRequest[0].id;
                    newVariationPSAgreement.Variation_Applicable__c=false;
                    newVariationPSAgreement.APTPS_buyingWindow__c=PSOldAgreementRecord.APTPS_buyingWindow__c;
                    newVariationPSAgreement.Apttus__Contract_Start_Date__c=PSOldAgreementRecord.Apttus__Contract_Start_Date__c;
                    newVariationPSAgreement.Apttus__Total_Contract_Value__c=PSOldAgreementRecord.Apttus__Total_Contract_Value__c;
                    
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
                    
                    AgreementUtilities.frageAgreementAssociationRecoredCreation(PSOldAgreementRecord.Apttus__Parent_Agreement__c,frameAgreement.id,true);//// EDGE-194529-- Changes added
                    
                    //This code has written to update old PS agreement status in Being Amended
                    AgreementOrderUtilities.agreementStatusUpdate(PSOldAgreementRecord,AGREEMENT_Status_CATEGORY,AGREEMENT_Status);
                    
                    //This Part of code has written to Create Related Agreement record's of Amended PS agreement and old PS agreement
                    if(newVariationPSAgreement!=null){
                        amendedAgmts.put(PSOldAgreementRecord.Id,newVariationPSAgreement.id);
                        APTPS_CreateAgreementVariationController aptsVariationController= new APTPS_CreateAgreementVariationController ();
                        aptsVariationController.createRelatedAgreement(amendedAgmts);
                    }
                    //This Part of code has written to Create Agreement Line Items records 
                    // EDGE-194529-- Changes start here
                    list<Id> agreementLineItemsIds=null;
                    if(aliCreationSet.size()>0)
                    agreementLineItemsIds=AgreementOrderUtilities.createAgreementLineItem(newVariationPSAgreement.id,aliCreationSet);
                    
                    //This Part of code has written to Create Attributes records 
                    if(attributeCreationSet.size()>0)
                    AgreementUtilities.createAttributeOnAgmtLineIem(relatedDPROLI,agreementLineItemsIds);
                    // EDGE-194529-- Changes End here
                    
                    if(faDefaultRecordlst.size()>0)
                    AgreementUtilities.insertDocusignRecipient(newVariationPSAgreement,faDefaultRecordlst[0],null);
                    else 
                    AgreementUtilities.insertDocusignRecipient(newVariationPSAgreement,null,oppContactRole);
                    
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
    
    
    
    public static Apttus__APTS_Agreement__c setAgreementData(Apttus__APTS_Agreement__c PSAgreement, Delegated_Pricing_Request__c drpRecord,csconta__Frame_Agreement__c frameAgreement,List<FA_DefaultRecipients__c> faDefaultRecordlst, OpportunityContactRole oppContactRole){
        
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
                        PSAgreement.APTPS_Sales_Account_Executive_email__c=frameAgreement.csconta__Account__r.Owner.Email;
                        }
                        
                        if(faDefaultRecordlst.size()>0 && faDefaultRecordlst[0].Signatory_1__c!=null){
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
    // EDGE-194529-- Changes start here
     public static string convertValuesFromSetToString(set <String> setOfvalues){
        String valueString='';
        if(setOfvalues.size()>0){
            for (String addStringloop:setOfvalues){
                valueString=valueString+'- '+ addStringloop +'\n' ;
            }
        }
        return valueString;
    }
    // EDGE-194529-- Changes start here    
     
}
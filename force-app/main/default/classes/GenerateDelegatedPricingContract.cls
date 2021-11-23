/*
* @Author : Yash/Sunil 
* @Date : 9th March 2020
* @Desc : Code to initiate a deal contract support request with Agreements via Process Builder Delegated Pricing Contract Process
* @Jira : EDGE-138646, EDGE-138647
* Histry of Update:-
* Vishal Arbune: 19/05/2020 EDGE-143011 <Deal contract flow> Creation of service terms, general service terms records in CALMS for document generation.
* Vishal Arbune: 02/06/2020 EDGE-151489 <Deal contract flow> <Tech Story> PD steps to configure CMP Service Term template.
* Maq : EDGE-184997  <Tech story for deal contract initiation from FAM> As sales, 
                    I should be able to click on contract button to initiate deal contract (DSA, price schedule from CALMS) from Frame agreement UI.
* Shashank Jadhav: 07/04/2021 EDGE-203816-Price Schedule Apttus Contract:Updating DPR Offer on Agreement Line Items
* Monali Golhar : 02/08/2021 TED-104 
*/
public without sharing class GenerateDelegatedPricingContract {
    @InvocableMethod
    public static void createContract(List<Delegated_Pricing_Request__c> dprequest){
        createContract(dprequest,null);
    }
    public static void createContract(List<Delegated_Pricing_Request__c> dprequest,AgreementUtilities.AgreementDecision agrmtDecision){
        String tag = '';
        String translatesToField = '';
        String literalValue = '';
        String promotionalValue = '0';
        Decimal listPrice =0;
        String literalValueUOM = 'per month per service';
        String aggrementCat = 'Business Services';
        String aggSubCat = 'Single Customer';
        String legalEntity = 'Victoria';
        Map<String,String> mapOfTagvstranslatesToFields=new Map<String,String>();
        Set<String> dprNames = new Set<String>();
        Map<Id,Id> mapOppPrimaryContact = new Map<Id,Id>();
        Set<String> oppName = new Set<String>();
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> childAgrList = new List<Apttus__APTS_Agreement__c>();
        list<Id> listDPRIds = new list<Id>();
        try{
            for(Delegated_Pricing_Request__c dpr:dprequest){
                dprNames.add(dpr.Name);
                oppName.add(dpr.Opportunity__c);
                listDPRIds.add(dpr.Id); // EDGE-184997 : Changes related to FA agreement | Maq
            }
            system.debug('oppName'+oppName);
            system.debug('dprNames'+dprNames);
       // EDGE-184997 : Changes related to FA agreement | Maq 
       //EDGE-203816-Price Schedule Apttus Contract:Added DPR_Offer__c in SOQL Query
        List<DPR_Offer_Line_Item__c> relatedDPROLI = [SELECT id, NAME,Delegated_Pricing_Request__r.Opportunity__r.AccountId, DPR_Offer__R.NAME, Offer_Type__c, Offer_Type_Name__c, Marketable_Offer__r.name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c, Offer_Type__r.Type__C, DPR_Offer_Line_Item_Type__c, DPR_Offer_Line_Item_Value__c, DPR_Offer__c from DPR_Offer_Line_Item__c where Delegated_Pricing_Request__c IN : listDPRIds];
        list<csconta__Frame_Agreement__c> frameAgreement = [SELECT ID, NAME FROM csconta__Frame_Agreement__c WHERE Delegated_Pricing_Request__c IN :listDPRIds];
       if((relatedDPROLI != null && relatedDPROLI.size() > 0) && (frameAgreement != NULL && frameAgreement.size() > 0)){
            
        AgreementOrderUtilities agmtOrderUtil = new AgreementOrderUtilities();
        set<String> productFamilySet = AgreementOrderDealUtilities.getMarketableOfferDeal(dprequest, relatedDPROLI);
      //  TED-104 Start 
      /*  if(productFamilySet != NULL && productFamilySet.size() > 0){
            agmtOrderUtil.updateAgmtPSFlags(productFamilySet, relatedDPROLI[0].Delegated_Pricing_Request__r.Opportunity__r.AccountId, 'DealBasedFlow');   
        } */

        AgreementDealUtilities.createAgreementRecords(dprequest, relatedDPROLI,agrmtDecision);
            // Call New Calms agreement flow
           // AgreementUtilities.AgreementUtilDetails(dprequest, relatedDPROLI);
       // TED-104 End 
        }  // EDGE-184997 : Changes related to FA agreement | Maq
        else {
            List<OpportunityContactRole> OppContact = [Select ID, Contact.Id, IsPrimary, Opportunity.Name,Opportunity.AccountId,Opportunity.Contract_Term__c from OpportunityContactRole where OpportunityId IN:oppName];//EDGE-143713-removed query filter.
            System.debug('OppContact--->'+OppContact);
            if(!OppContact.isEmpty() && OppContact.size()>0){//EDGE-143713 list null check
                for(OpportunityContactRole conRole : OppContact){
                    if(conRole.IsPrimary==True){//EDGE-143713  adding only primary conatct
                        mapOppPrimaryContact.put(conRole.Opportunity.Id,conRole.Contact.Id);    
                    }
                }
            }
            system.debug('mapOppPrimaryContact'+mapOppPrimaryContact);
            //Create Agreement record for DPR.
            if(dprequest.size()>0){
                for(Delegated_Pricing_Request__c dprOpp:dprequest){
                    Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
                    agreement.RecordTypeId  = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
                    if(OppContact.size()>0){
                        agreement.Apttus__Account__c = OppContact[0].Opportunity.AccountId;   
                        agreement.Apttus__Term_Months__c = OppContact[0].Opportunity.Contract_Term__c;
                        //EDGE-143713 - If primary contact present on opp assign to Agreement else assign any other contact. 
                        if(mapOppPrimaryContact.get(dprOpp.Opportunity__c)!=null){
                            agreement.APTPS_Customer_Primary_Contact__c = mapOppPrimaryContact.get(dprOpp.Opportunity__c);
                        }else{
                            agreement.APTPS_Customer_Primary_Contact__c = OppContact[0].Contact.Id;
                            System.debug('Primary Contact is not present on opportunity so assigned other contact');
                        }
                        agreement.Delegated_Pricing_Request__c = dprOpp.Id;
                    }//EDGE-143713 - fix end
                    agreement.Apttus__Agreement_Category__c= aggrementCat;
                    agreement.APTPS_Agreement_Subcategory__c= aggSubCat;
                    agreement.APTPS_Telstra_Legal_Entity__c = legalEntity;
                    agreementList.add(agreement);
                    system.debug('agreementList---->'+agreementList);
                }
            }
            // insert agreement Record
            if(!agreementList.isEmpty())
                insert agreementList;
            // create child agreement
            if(!agreementList.isEmpty() && agreementList.size()>0){
                //EDGE-143011: Creation of Schedule,service terms, general service terms records in CALMS for document generation.
                Id sheduleAgreementRecordTypeId=Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(APTPS_Constants.SCHEDULE).getRecordTypeId();
                Id STAgreementRecordTypeId=Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(APTPS_Constants.PRODUCT_KEY_FACTS).getRecordTypeId();
                Id GSTAgreementRecordTypeId=Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('General_Product_Terms').getRecordTypeId();
                Apttus__APTS_Agreement__c sheduleTypeAggrement=getChildAgreement(agreementList,sheduleAgreementRecordTypeId,APTPS_Constants.PRICING,APTPS_Constants.PRICE_BOOK,APTPS_Constants.STANDARD,OppContact);
                childAgrList.add(sheduleTypeAggrement);  
                //EDGE-151489: Configured Corporate Mobile Plus as subcategory for Service Terms template
                //Subcategory changed from Standard to Connectivity.
                Apttus__APTS_Agreement__c serviceTermAggrement=getChildAgreement(agreementList,STAgreementRecordTypeId,APTPS_Constants.SERVICE_TERMS,APTPS_Constants.CO_MOBILE_PLUS,APTPS_Constants.CONNECTIVITY,OppContact);
                childAgrList.add(serviceTermAggrement);  
                Apttus__APTS_Agreement__c GSTAggrement=getChildAgreement(agreementList,GSTAgreementRecordTypeId,'General Service Terms','General Service Terms',APTPS_Constants.STANDARD,OppContact);
                childAgrList.add(GSTAggrement);
            }
            // insert child record        
            if(!childAgrList.isEmpty())
                insert childAgrList;
            system.debug('agreementList'+agreementList);
            //Get the agreement pricing data record for trnslate to fields map        
            List<APTPS_Agreement_Pricing_Data_Map__c> agreementPricingList = [SELECT Tag__c,APTPS_Translates_To_Field__c FROM APTPS_Agreement_Pricing_Data_Map__c];
            system.debug('agreementPricingList'+agreementPricingList); 
            for(APTPS_Agreement_Pricing_Data_Map__c agreementPricing: agreementPricingList)
                mapOfTagvstranslatesToFields.put(agreementPricing.Tag__c, agreementPricing.APTPS_Translates_To_Field__c);
            List<DPR_Offer__c> dprOffer = new List<DPR_Offer__c>();
            dprOffer = [SELECT Id, Name, Delegated_Pricing_Request__c from DPR_Offer__c WHERE Delegated_Pricing_Request__r.Name IN:dprNames];
            Set<String> prodNames = new Set<String>();
            for(DPR_Offer__c dproff:dprOffer){
                prodNames.add(dproff.Name);  
            }
            // Get The productId's based on DPR offer Name
            Map<String,Id> mapProdNameVsId = new Map<String,Id>();
            system.debug('dprOffer--->'+dprOffer);
            List<Product2> lstProduct = new List<Product2>();
            lstProduct = [Select Id,Name from Product2 where Name IN:prodNames];
            if(!lstProduct.isEmpty()){
                for(Product2 prd:lstProduct){
                    mapProdNameVsId.put(prd.Name,prd.Id);
                }    
            }
            system.debug('mapOfTagvstranslatesToFields'+mapOfTagvstranslatesToFields); 
            List<DPR_Offer_Line_Item__c> dprOfferLineItemList = [SELECT Delegated_Pricing_Request__r.name, DPR_Offer__r.Data_Pack_Plan_Name__c, MinimalMarginalValue__c,  Delegated_Pricing_Request__c,cspmb_Add_On_Price_Item__r.Name,
                                                                 Parent_DPR_Offer_Line_Item_Id__r.name, name, DPR_Offer_Line_Item_Type__c, Offer_Type_Name__c, DPR_Offer_Line_Item_Unit_Type__c, DPR_Offer_Line_Item_Value__c, List_Price__c, Overridden_Unit_price__c, Discount_Level__r.cspmb__Discount_Values__c, Discount_Level__r.cspmb__duration__c 
                                                                 FROM DPR_Offer_Line_Item__c WHERE Delegated_Pricing_Request__r.Name IN: dprNames order by Delegated_Pricing_Request__c ASC, Parent_DPR_Offer_Line_Item_Id__r.Name DESC];
            system.debug('dprOfferLineItemList'+dprOfferLineItemList);
            List<Apttus__AgreementLineItem__c> agrLineItemList = new List<Apttus__AgreementLineItem__c>();
            for(DPR_Offer__c dpoffer:dprOffer){                          
                // create agreement line items.
                if(childAgrList.size()>0){
                    //EDGE-143011 start
                    for(Apttus__APTS_Agreement__c chiAgr:childAgrList){
                        Apttus__AgreementLineItem__c agrLineItem = new Apttus__AgreementLineItem__c();
                        agrLineItem.Apttus__AgreementId__c =chiAgr.Id;
                        agrLineItem.Apttus__ProductId__c = mapProdNameVsId.get(dpoffer.Name); 
                        agrLineItemList.add(agrLineItem); 
                    }
                    //EDGE-143011 end
                }
            }
            if(!agrLineItemList.isEmpty()){
                insert agrLineItemList;
            }
            // Create Attributes once Aggrement line item created under Child Agreement Record.
            List<APTPS_Component__c> lstComp = new List<APTPS_Component__c>();
            for(DPR_Offer__c dpoffer:dprOffer){
                for (DPR_Offer_Line_Item__c dprOfferLineItem : dprOfferLineItemList) {
                    if (dprOfferLineItem.Discount_Level__r.cspmb__Discount_Values__c != null)
                        promotionalValue = dprOfferLineItem.Discount_Level__r.cspmb__Discount_Values__c;
                    if (dprOfferLineItem.List_Price__c != null)
                        listPrice = dprOfferLineItem.List_Price__c;
                    tag = dprOfferLineItem.DPR_Offer_Line_Item_Type__c + '_'+ dprOfferLineItem.Name;
                    if(String.isNotBlank(dprOfferLineItem.Parent_DPR_Offer_Line_Item_Id__r.Name))
                        tag = tag + '_'+dprOfferLineItem.Parent_DPR_Offer_Line_Item_Id__r.Name;
                    translatesToField=mapOfTagvstranslatesToFields.get(tag);
                    if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Plan' || dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Addon'){
                        literalValue='Base price: $'+listPrice +'ex GST '+literalValueUOM;
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('MMC Discount')){
                        //literalValue = 'Negotiated discount: $'+dprOfferLineItem.DPR_Offer_Line_Item_Value__c+' ex GST MMC discount while your service is active';
                        literalValue = 'Discount: $'+listPrice +'  ex GST MMC discount while your service is active';
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('Activation Credits')){
                        literalValue = 'Promotion: '+promotionalValue+'% Activation credit for '+dprOfferLineItem.DPR_Offer_Line_Item_Value__c+' months from activation';
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('Recontracting Credits')){
                        literalValue = 'Promotion: '+promotionalValue+'% Recontracting credit for '+dprOfferLineItem.DPR_Offer_Line_Item_Value__c+' months from activation';
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('Mobile Workspace Discount 1')){
                        literalValue = 'Promotion: $'+listPrice +' ex GST Mobile Workspace Offer 1 while eligibility conditions met';
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('Mobile Workspace Discount 2')){
                        literalValue = 'Promotion: $'+listPrice +' ex GST Mobile Workspace Offer 2 while eligibility conditions met';
                    }
                    else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('Mobile Workspace Discount 3')){
                        literalValue = 'Promotion: $'+listPrice +' ex GST Mobile Workspace Offer 3 while eligibility conditions met';
                    }else if(dprOfferLineItem.DPR_Offer_Line_Item_Type__c=='Discount' && dprOfferLineItem.Name.contains('IDD Call Pack Discount')){
                        if(dprOfferLineItem.cspmb_Add_On_Price_Item__r.Name=='Basic'){
                          literalValue = 'Promotion: '+promotionalValue +' % discount '+dprOfferLineItem.cspmb_Add_On_Price_Item__r.Name+' IDD inclusion added to selected plans';
                        }else{
                          literalValue = 'Promotion: '+promotionalValue +' % discount '+dprOfferLineItem.cspmb_Add_On_Price_Item__r.Name+' IDD inclusion added to selected plans';    
                        }
                    }
                    system.debug('tag'+tag);
                    system.debug('translatesToField'+translatesToField);
                    system.debug('literalValue'+literalValue);
                    if(agrLineItemList.size()>0){
                        APTPS_Component__c comp = new APTPS_Component__c();
                        comp.Tag__c = tag;
                        comp.APTPS_Attribute__c = translatesToField;
                        comp.Value__c = literalValue;
                        comp.APTPS_Original_Value__c = translatesToField;
                        comp.Agreement_Line_Item__c = agrLineItemList[0].Id;
                        lstComp.add(comp);    
                    }
                }
            }
            if(!lstComp.isEmpty())
                insert lstComp;
            // Associate Agreement with Case record.
            if(!dprequest.isEmpty()){
                system.debug('dprequest-->'+dprequest);
                system.debug('agreementList[0].Id--->'+agreementList[0].Id);
                Case[] caseObj = [Select Id, Pricing_Agreement__c,Deal__c from Case where Deal__c=:dprequest[0].Id AND Deal__c!=null order by CreatedDate Desc limit 1];
                System.debug('caseObj--->'+caseObj);
                If(caseObj.size()>0){
                    if(!agreementList.isEmpty() && agreementList.size()>0){
                        System.debug('inside case update');
                        Case objCS = new Case();
                        objCS.Id=caseObj[0].Id;
                        objCS.Pricing_Agreement__c = agreementList[0].Id;
                        update objCS;
                        system.debug('objCS===>'+objCS);
                    }
                    //system.debug('objCS===>'+objCS);
                }
            }
        }
        }
        catch(AgreementException agEx){
            Agreementutilities.logException(agEx.methodName,agEx.referenceNumber,'',agEx.errorMessage,agEx.businessDescription);
        }
        catch(Exception e){
            system.debug('exception : '+e.getMessage()+' > ' +e.getLineNumber()+ ' > '+e.getStackTraceString());
            throw e;
        }
    }
    /*EDGE-143011:-Creation of Shedule, service terms, general service terms records in CALMS for document generation.
     * added by team Amsterdam.
    */
    public static Apttus__APTS_Agreement__c getChildAgreement(List<Apttus__APTS_Agreement__c> agreementList,Id recTypeId,
            String aggCategory,String subCategory,String apttusSubtype,List<OpportunityContactRole> OppContact){
            Apttus__APTS_Agreement__c childAgreement = new Apttus__APTS_Agreement__c();
            childAgreement.Apttus__Parent_Agreement__c = agreementList[0].Id;
            childAgreement.RecordTypeId=recTypeId;
             childAgreement.Apttus__Agreement_Category__c=aggCategory;// 'Pricing';
            childAgreement.APTPS_Agreement_Subcategory__c =subCategory;// 'Price Book';
            childAgreement.Apttus__Subtype__c =apttusSubtype;// 'Standard';
            //childAgreement.APTPS_Minimum_Number_of_SIOs__c = 1;
            //childAgreement.APTPS_Schedule_Minimum_Spend__c = 100.00;
            childAgreement.Apttus__Contract_Start_Date__c = System.today();
            childAgreement.Apttus__Account__c = agreementList[0].Apttus__Account__c;
            //EDGE-142348 - Added contract term to support apttus flow
            if(OppContact.size()>0){  
                childAgreement.Apttus__Term_Months__c = OppContact[0].Opportunity.Contract_Term__c;
            }//EDGE-142348 - end
        return childAgreement;  
        
    }
}
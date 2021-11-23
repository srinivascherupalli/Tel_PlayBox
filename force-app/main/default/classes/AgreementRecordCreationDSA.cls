/* This class is created for docusign Restricted flow and move with apttus docusign flow
Name        Date      Story        Description
Dheeraj    29/10/2020    EDGE-170429    record creation for DSA and PS (createAgreemnetDSASChrecordandGenratedoc)
EDGE-171302    add agreement field on contract junction
Divya      30/10/2020    EDGE-171295    To create Agreement Line Item records for 
Shashank   10/04/2021	 DIGI-20842: Enabling Adobe Sign Flow
*/


public with sharing class AgreementRecordCreationDSA {
    public class MyException extends Exception{} 
    private static final Id AGREEMENT_SA_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('SA').getRecordTypeId();
    private static final Id AGREEMENT_SCHEDULE_RECORDTYPEID = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Schedule').getRecordTypeId();
    public static String agreementId = '';  
    private static final Id DOCUSIGN_CONTACT_RECORDTYPEID = Schema.SObjectType.Apttus_DocuApi__DocuSignDefaultRecipient2__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
    private Static String emailTemplateUniqueName = 'DocuSign_for_Send_to_Customer';
    private Static String emailTemplateUniqueName2 = 'DocuSign_for_Send_to_Telstra';
    private Static String agreementCategory = 'Digital Services';
    private Static String agreementSubCategory = 'Single Customer';
    private Static String schAgreementCategory = 'Pricing';
    private Static String schAgreementSubCategory = 'Price Book';
    private Static String schAgreementSubType = 'Standard';
    private Static String apttusErrorMessage = 'Contract document generation has failed. You might not have appropriate access. Please raise a contract support case to generate the contract document.';
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to create Agreement records DSA PS
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    public static void createAgreemnetDSASChrecordandGenratedoc(ContractJunction__c contJun){
        try{
            Apttus__APTS_Agreement__c agmt = insertDSAAgreement(contJun);
            
            agreementId = agmt.Id;
            //DIGI-20842:Start
            if(FeatureToggle__mdt.getInstance('eSign_Apttus').EnableForAll__c != true || FeatureToggle__mdt.getInstance('eSign_Apttus').EnabledFlows__c!='adobe' || Test.isRunningTest()) {
                 insertDocusignRecipient(contJun,agmt);
            }
            //DIGI-20842:End

            Apttus__APTS_Agreement__c priceschrec = insertChildAgreement(agmt,AGREEMENT_SCHEDULE_RECORDTYPEID,schAgreementCategory,schAgreementSubCategory,schAgreementSubType);
            system.debug('priceschrec====  '+priceschrec);
            system.debug('agmt====  '+agmt);
            if(priceschrec != null){
                insertAgreementLineItem(contJun,priceschrec.Id); /*EDGE-171295*/
            }
            List<Apttus__APTS_Template__c> templateList = [select id,name,Apttus__IsActive__c from Apttus__APTS_Template__c where (name =:Label.DSA_Agreement_Template or name =:Label.PS_Agreement_Template) and Apttus__IsActive__c = true and Apttus__Type__c= 'Agreement' ];
            Map<String,Id> templateMap = new Map<String,Id>();
            for(Apttus__APTS_Template__c temp:templateList){
                if(temp.name.contains('DSA')){
                    templateMap.put('DSA', temp.Id);
                }
                else if(temp.name.contains('Price')){
                    templateMap.put('Price Schedule', temp.Id);
                }
            }
            system.debug('templateMap == '+templateMap);
            if(agmt != null){
                generateAgreement(agreementId,templateMap.get('DSA'));
            }
            if(priceschrec != null){
                generateAgreement(priceschrec.Id,templateMap.get('Price Schedule'));
            }

        }catch(Exception ex){
            System.debug('Agreement Creation:createAgreemnetDSASChrecordandGenratedoc method ' + ex);
            throw new MyException('User do not have permission to perform this operation');
        }  

    }
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to create Agreement records child agreement PS
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    
    public static Apttus__APTS_Agreement__c insertChildAgreement(Apttus__APTS_Agreement__c agreementList,Id recTypeId,String aggCategory,String subCategory,String apttusSubtype){
                                                                     
        try{
             Apttus__APTS_Agreement__c childAgreement = new Apttus__APTS_Agreement__c();
             childAgreement.Apttus__Parent_Agreement__c = agreementList.Id;
             childAgreement.RecordTypeId=recTypeId;
             childAgreement.Apttus__Agreement_Category__c=aggCategory;// 'Pricing';
             childAgreement.APTPS_Agreement_Subcategory__c =subCategory;// 'Price Book';
             childAgreement.Apttus__Subtype__c =apttusSubtype;// 'Standard';
             childAgreement.Apttus__Contract_Start_Date__c = System.today();
             childAgreement.Apttus__Term_Months__c = agreementList.Apttus__Term_Months__c;
             childAgreement.Apttus__Account__c = agreementList.Apttus__Account__c;
             childAgreement.APTPS_Customer_Primary_Contact__c = agreementList.APTPS_Customer_Primary_Contact__c;
             
             childAgreement.Related_Contract__c = agreementList.Related_Contract__c;
             childAgreement.Apttus__Related_Opportunity__c = agreementList.Apttus__Related_Opportunity__c;
             childAgreement.Related_Basket__c = agreementList.Related_Basket__c;
             insert childAgreement;
             return childAgreement; 
        }catch(Exception ex){
             System.debug('generatedDocId ex: ' + ex);
             throw new MyException('User do not have permission to perform this operation');
        }                                                               
    }
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to trigger order form  documents by updating ContractJunction record
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    
    public static void  createOrderForm(Id agreementId){   
        try{
            Apttus__APTS_Agreement__c agreementRec = [select id,Apttus__Parent_Agreement__r.Related_Basket__c,Apttus__Contract_Start_Date__c,Apttus__Term_Months__c,Apttus__FF_Agreement_Number__c,Apttus__Contract_End_Date__c,Related_Contract__c ,Apttus__Parent_Agreement__c,Apttus__Parent_Agreement__r.Apttus__Term_Months__c,RecordType.Name, Name from Apttus__APTS_Agreement__c where Id =:agreementId ];
            if(agreementRec != null && agreementRec.RecordType.Name =='Schedule'){
                system.debug('Inside order form '+agreementRec);
                List<Attachment> attachList = [select id,ParentId from Attachment where ParentId =:agreementRec.Id];
                if(attachList.size()>0){
                    system.debug('Inside order form attachment  '+attachList);
                    ContractJunction__c contractRec = new ContractJunction__c(id=agreementRec.Related_Contract__c);
                    contractRec.isDSAGenerated__c =true;
                    contractRec.Initiated_document_Generation__c = true;
                    contractRec.Related_Price_Schedule__c = agreementRec.Id;
                    contractRec.Agreement_Number__c = agreementRec.Apttus__FF_Agreement_Number__c;
                    contractRec.Contract_Term_Months__c = agreementRec.Apttus__Term_Months__c;
                    contractRec.Effective_End_Date__c = agreementRec.Apttus__Contract_End_Date__c;
                    contractRec.Contract_Start_Date__c = agreementRec.Apttus__Contract_Start_Date__c;
                    contractRec.Original_End_Date__c = agreementRec.Apttus__Contract_End_Date__c;
                    system.debug('basket id ==>> '+agreementRec.Apttus__Parent_Agreement__r.Related_Basket__c);
                    if(agreementRec.Apttus__Parent_Agreement__r.Related_Basket__c != null){
                        String priceSchProductFamily = getProductFamilies(agreementRec.Apttus__Parent_Agreement__r.Related_Basket__c,'DSA');
                        if(priceSchProductFamily != null){
                            contractRec.pricescheduleProductFamilies__c = priceSchProductFamily;
                        }
                    }
                    
                    update contractRec;
                    system.debug('contractRec >>> '+contractRec);
                    //return contractRec
                }
            }
        }
        catch(Exception ex){
            System.debug('createOrderForm exception: ' + ex);
          throw new MyException('User do not have permission to perform this operation');
            //return null;
        }
    }
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to create documents for DSA PS
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    @Future(callout=true)
    public static void  generateAgreement(Id agreementId, Id templateId)
    {
        //Getting the session Id of the user
        String apiSessionId = UserInfo.getSessionId(); 
        String pLevel = 'Insert comments and tracked changes only'; 
        String docFormat = 'DOCX'; 
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
        
        String generatedDocId = null;
        try{
            if(!Test.isRunningTest()) {
                System.debug('Inside the method agreementId: '+ agreementId);
                System.debug(' Inside the method templateId: '+ templateId);
                generatedDocId = Apttus.MergeWebService.generateDoc2(templateId, agreementId,pLevel, docFormat, false, apiSessionId, apiServerURL);//For INC000095158163 changed waterMark variable to false  
                system.debug('generatedDocId ===  '+generatedDocId );
                if(generatedDocId != null){
                    system.debug('Inside order form if else');
                    createOrderForm(agreementId);
                }
            }
        }catch(CalloutException ex){
            System.debug(' Inside the method CalloutException: '+ ex);
            //agreementsToBeUpdated.add(agreement);  
           throw new MyException('User do not have permission to perform this operation');
        }catch(Exception ex){
            System.debug(' generatedDocId ex: ' + ex);
            throw new MyException('User do not have permission to perform this operation');
        }
    }
    
    /*-------------------------------------------------------- 
    EDGE-171295
    Description: Method to create AgreementLineItems records under PS
    Author:Divya Chilakabathini
    --------------------------------------------------------*/
    public static void insertAgreementLineItem(ContractJunction__c contJun, Id priceschrec){
        try{
            List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
            Map<Id,String> prodConfigMap = new Map<Id,String>();
            Set<String> prodFamilyName = new Set<String>();
            List<Product2> prd = new List<Product2>();
            List<Apttus__AgreementLineItem__c> agrLineItemList = new List<Apttus__AgreementLineItem__c>();
            
            //fetching the product configuration records based on the contract junction related product basket
            prodConfigList = [SELECT id,Name,cscfga__Contract_Term__c,csordtelcoa__Replaced_Product_Configuration__c,cscfga__Product_Basket__r.Name,Marketable_Offer__c,Type__c,
                              cscfga__Product_Basket__r.csbb__Account__c,cscfga__Product_Basket__r.cscfga__Opportunity__c,
                              Marketable_Offer__r.Offer_ID__c,Marketable_Offer__r.Name,Marketable_Offer__r.Id,Marketable_Offer__r.Product_Family__c ,cscfga__Product_Basket__c,OfferName__c
                              from cscfga__Product_Configuration__c where cscfga__Product_Basket__c=: contJun.Related_Basket__c
                             ];
            
            
            if(!prodConfigList.isEmpty()){
                for(cscfga__Product_Configuration__c pc :prodConfigList ){
                    //checking marketable offer is not null and fetching the product family and adding to the list of strings
                    if(pc.Marketable_Offer__c != null){
                        prodFamilyName.add(pc.Marketable_Offer__r.Product_Family__c);
                    }
                    
                }
            }
            
            //quring the product2 records based on the product family
            if(!prodFamilyName.isEmpty()){
                prd = [Select Id,Name,Telstra_Marketable_Product_Family__c from Product2 where Telstra_Marketable_Product_Family__c IN:prodFamilyName];
            }
            
            if(!prd.isEmpty()){
                for(Product2 p : prd){
                    //creating the agreement line items for the product and the price schedule
                    Apttus__AgreementLineItem__c alt = new Apttus__AgreementLineItem__c();
                    alt.Apttus__ProductId__c = p.Id;
                    alt.Apttus__AgreementId__c = priceschrec;
                    agrLineItemList.add(alt);
                    
                }
            }
            
            if(!agrLineItemList.isEmpty()){
                insert agrLineItemList;
            }      
        }catch(Exception ex){
            System.debug('Agreement Line Items:insertAgreementLineItem method ' + ex);
           throw new MyException('User do not have permission to perform this operation');
        }   
        
    }
    
    /*-------------------------------------------------------- 
    EDGE-171295
    Description: Method to create DocusignRecipient records under DSA Agreement Record
    Author:Divya Chilakabathini
    --------------------------------------------------------*/
    
    public static void insertDocusignRecipient(ContractJunction__c contJun,Apttus__APTS_Agreement__c agremt){
        try{
            List<Apttus_DocuApi__DocuSignDefaultRecipient2__c> docusignRecpList = new List<Apttus_DocuApi__DocuSignDefaultRecipient2__c>();
            List<Id> signerList = new List<Id>();
            List<Contact> c1ist = new List<Contact>();
            List<User> ulist = new List<User>();
            String singer2 = 'Signer 2';
            String singer3 = 'Signer 3';
            
            //signerList.add(contJun.Customer_Primary_Contact__c);
            signerList.add(contJun.DocuSign_Signer_2__c);
            signerList.add(contJun.DocuSign_Signer_3__c);
            
            
            c1ist = [SELECT Id,Email,Phone,Fax,Owner.Title,FirstName,LastName FROM Contact WHERE Id IN: signerList];
            
            ulist = [SELECT Id,Email,Phone,FirstName,LastName FROM User WHERE Id IN: signerList];
            
            if(!c1ist.isEmpty()){
                Apttus_DocuApi__DocuSignDefaultRecipient2__c ds = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                for(Contact c : c1ist){
                    ds.Apttus_DocuApi__FirstName__c = c.FirstName;
                    ds.Apttus_DocuApi__LastName__c = c.LastName;
                    ds.Apttus_DocuApi__Email__c = c.Email;
                    ds.Apttus_DocuApi__ContactId__c = c.Id;
                    ds.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                    ds.Apttus_CMDSign__AgreementId__c = agremt.Id;
                    ds.Apttus_DocuApi__AccountId__c = agremt.Apttus__Account__c;
                    if(c.Id == contJun.DocuSign_Signer_2__c){
                        ds.Apttus_DocuApi__RoleName__c = singer2;
                        ds.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplateUniqueName;
                        ds.Apttus_DocuApi__SigningOrder__c = 2;  // EDGE-211362
                    }
                    if(c.Id == contJun.DocuSign_Signer_3__c){
                        ds.Apttus_DocuApi__RoleName__c = singer3;
                        ds.Apttus_DocuApi__EmailTemplateUniqueName__c = emailTemplateUniqueName2;
                        ds.Apttus_DocuApi__SigningOrder__c = 3; // EDGE-211362
                    }
                    docusignRecpList.add(ds);
                }
            }
            if(!ulist.isEmpty()){
                Apttus_DocuApi__DocuSignDefaultRecipient2__c dsr = new Apttus_DocuApi__DocuSignDefaultRecipient2__c();
                for(User u : ulist){
                    dsr.Apttus_DocuApi__FirstName__c = u.FirstName;
                    dsr.Apttus_DocuApi__LastName__c = u.LastName;
                    dsr.Apttus_DocuApi__Email__c = u.Email;
                    dsr.Apttus_DocuApi__UserId__c = u.Id;
                    dsr.RecordTypeId = DOCUSIGN_CONTACT_RECORDTYPEID;
                    dsr.Apttus_CMDSign__AgreementId__c = agremt.Id;
                    dsr.Apttus_DocuApi__AccountId__c = agremt.Apttus__Account__c;
                    if(u.Id == contJun.DocuSign_Signer_2__c){
                        dsr.Apttus_DocuApi__RoleName__c = singer2;
                        dsr.Apttus_DocuApi__EmailTemplateUniqueName__c = EmailTemplateUniqueName;
                        dsr.Apttus_DocuApi__SigningOrder__c = 2;// EDGE-211362
                    }
                    if(u.Id == contJun.DocuSign_Signer_3__c){
                        dsr.Apttus_DocuApi__RoleName__c = singer3;
                        dsr.Apttus_DocuApi__EmailTemplateUniqueName__c = EmailTemplateUniqueName2;
                        dsr.Apttus_DocuApi__SigningOrder__c = 3;// EDGE-211362
                    }
                    docusignRecpList.add(dsr);
                }
            }
            if(!docusignRecpList.isEmpty()){
                insert docusignRecpList;
            }
        }catch(Exception ex){
            System.debug('insert Docusign Recipient:insertDocusignRecipient method ' + ex);
            throw ex;
        }   
        
    }
    
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to fetch term month from product basket Id
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    public static Integer getContractTermforBasket(Id record){
        AggregateResult[] groupedResults = [SELECT Max(cscfga__Contract_Term__c) max FROM cscfga__Product_Configuration__c WHERE  cscfga__Product_Basket__c =: record]; 
        return Integer.valueOf(groupedResults[0].get('max'));
    }
    
    
    /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to populate product families
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    public Static String getProductFamilies(Id basketId, String contractType){
        try{
        String psProductFamilies;
       
        set<String> productFamilySet = new set<String>();
       list<cscfga__Product_Configuration__c> pcConfig = [SELECT id, Name, Marketable_Offer__r.Contract_Type__c, Marketable_Offer__r.Product_Family__c FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c =: basketId]; 
        if(pcConfig.size() > 0){
            for(cscfga__Product_Configuration__c pcForMarketOffer : pcConfig ){
                if(pcForMarketOffer.Marketable_Offer__r.Contract_Type__c == contractType && pcForMarketOffer.Marketable_Offer__r.Contract_Type__c != ''){
                    if(pcForMarketOffer.Marketable_Offer__r.Product_Family__c != null){
                    productFamilySet.add(pcForMarketOffer.Marketable_Offer__r.Product_Family__c);
                   
                }
                
            }
        }
        if(productFamilySet.size() > 0)
        psProductFamilies = String.join(new List<String>(productFamilySet), ';');
        system.debug(' <<--psProductFamilies--> '+psProductFamilies );
        return psProductFamilies;
        }else{
            return null;
        }
        }catch(Exception ex){
            System.debug('psProductFamilies method ' + ex);
            throw ex;
        }   

    }
    
        /*-------------------------------------------------------- 
    EDGE-170429
    Description: Method to create DSA Agreement records 
    Author:Dheeraj Singh
    --------------------------------------------------------*/
    
    public static Apttus__APTS_Agreement__c insertDSAAgreement(ContractJunction__c contJun){
                                                                     
        try{
            Apttus__APTS_Agreement__c agmt = new Apttus__APTS_Agreement__c();    
            agmt.RecordTypeId = AGREEMENT_SA_RECORDTYPEID;
            agmt.Apttus__Agreement_Category__c = agreementCategory;
            agmt.APTPS_Agreement_Subcategory__c = agreementSubCategory;
            agmt.APTPS_Customer_Primary_Contact__c = contJun.Customer_Primary_Contact__c;
            agmt.Apttus__Account__c = contJun.Account__c;
            agmt.Related_Contract__c = contJun.Id;
            agmt.Apttus__Related_Opportunity__c = contJun.Related_Opportunity__c;
            agmt.Related_Basket__c = contJun.Related_Basket__c;
            agmt.Apttus__Contract_Start_Date__c = System.today();
            agmt.APTPS_Sales_Account_Executive__c = Id.valueOf(contJun.DocuSign_Signer_3__c);//EDGE-198932 Defect Fix
            agmt.Apttus__Term_Months__c = getContractTermforBasket(contJun.Related_Basket__c);
            agmt.APTPS_Show_After_E_Signature_Buttons__c=true; 
            insert agmt;
            return agmt;
        }catch(Exception ex){
             System.debug('generatedDocId ex: ' + ex);
             throw new MyException('User do not have permission to perform this operation');
        }
    }
}
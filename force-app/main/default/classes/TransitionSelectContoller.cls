/*************************************************************************************************
Name : TransitionSelectContoller
Description :Controller class for Transition
Author:Kalashree Borgaonkar
Story: EDGE-189351
***************************************************************************************************/
public with sharing class TransitionSelectContoller {
    public static String productSpecMobile = Label.ProductSpecificationMobile;
    public static List<String> listproductSpecMobile = productSpecMobile.split(',');
    public static List < String > listproductSpecNgUc = Label.ProductSpecificationNgUc.split(',');
    //public static String TransitionJSONDataMobile = Label.MobileTransitionName;
    //public static String TransitionJSONDataNgUc = Label.NgUcTransitionName;
    public static boolean checkForPRM;
    
    /*************************************************************************************************
     Name : TransitionSelectContoller
	 Description :Returning Wrapper result for UI validation and display
	Author:Kalashree Borgaonkar
	Story: EDGE-189351
	Modified By: Jay (Osaka) - Added field for populating Markatable Offer Id for tenancy check(DIGI-1754)
    ***************************************************************************************************/
    
    @AuraEnabled
    public static DetailsWrapper getServiceType(String basketid){
        DetailsWrapper details=new DetailsWrapper();
        try{
            List<ConstantMetadataUtility__mdt> constObj = [SELECT id,Value__c FROM ConstantMetadataUtility__mdt WHERE DeveloperName='PowerBi_URL'];
            
            cscfga__Product_Basket__c basket = [SELECT name,cscfga__Opportunity__r.Type,csbb__Account__c,
                                                csbb__Account__r.CIDN__c,
                                                csbb__Account__r.Name,
                                                csbb__Account__r.Parent_CIDN__c,
                                                csbb__Account__r.Ultimate_Parent_CIDN__c,
                                                cscfga__Opportunity__c
                                                FROM cscfga__Product_Basket__c 
                                                WHERE Id=: basketid];
            if('Migration'.equalsIgnoreCase(basket.cscfga__Opportunity__r.Type) ){
                details.serviceType = 'Migration';
            }
            else{
                details.serviceType = 'Transition';
            }
            //DIGI-5034 - Added by Jay (Osaka):- Making code dormant for 21.12
            Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
            String isDormant = String.valueOf(MTMMetadataUtilityMap.get('isDormant').get('Value__c'));
            details.isDormant = isDormant;
            //End of DIGI-5034 
            details.accountId = basket.csbb__Account__c;
            details.basketNumber=basket.name;
            details.accountCIDN = basket.csbb__Account__r.CIDN__c;
            details.accountName = basket.csbb__Account__r.Name;
            details.parentCIDN = basket.csbb__Account__r.Parent_CIDN__c;
            details.ultimateParentCIDN = basket.csbb__Account__r.Ultimate_Parent_CIDN__c;
            details.opportunityId = basket.cscfga__Opportunity__c; // Added by Jay as a part of EDGE-198192
            //Start of EDGE-209886 By Abhishek(Osaka)
            details.productFamily =csvUploaderHelper.fetchProductFamily(basketId);
            System.debug('productFamily returned from CSVUploaderHelper ' + details.productFamily);
            //End of EDGE-209886 By Abhishek(Osaka)
            if(!constObj.isEmpty()){
              details.powerbiURL = constObj[0].value__c.replace('cidnNumber',details.accountCIDN);
      }
            
        }
        catch(Exception e){
            System.debug('Exception in getServiceType'+ e.getStackTraceString());
        }
        return details;
    }
    public class DetailsWrapper{
        @AuraEnabled
        public String accountId;
        @AuraEnabled
        public String basketNumber;
        @AuraEnabled
        public String serviceType;
        @AuraEnabled
        public String accountCIDN;
        @AuraEnabled
        public String powerbiURL;
    //Start of EDGE-198190 by Abhishek From Osaka Team
      @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String parentCIDN;
        @AuraEnabled
        public String ultimateParentCIDN;
        
    //End of EDGE-198190 by Abhishek From Osaka Team
      @AuraEnabled
        public String opportunityId; // EDGE-198192:- Added by Jay
        @AuraEnabled
        public String productFamily;//Added as a part of EDGE-209886 by Abhishek(Osaka)
        @AuraEnabled
        public String isDormant;//Added by Jay(Osaka):- for making 21.12 dormant
        
        
    }
 
    @AuraEnabled
    public static String saveCSVfile(String base64Data,String basketId, Boolean nextFlag){
         List<String> cidnInFile = new List<String> ();
        if(base64Data != NULL){
        cidnInFile = cidnsInHierarchy(base64Data, basketId);
        }
        system.debug('cidnInFile>>>>'+cidnInFile);
        system.debug('base64Data>>>>'+base64Data);
        //nextFlag parameter added to reuse the existing CSV parsing method saveFile for validations on Next button
        //by Abhishek from Osaka Team
        String response = csvUploaderController.saveFile(base64Data,basketId,nextFlag);
        return response;
    }
/*************************************************************************************************
Name : profileAndProductCheck
Description : Method to check whether current basket holds mobile product. 
        This method also check current logged in user profile.
Developer : Abhishek Mallick
Story: EDGE-198190
***************************************************************************************************/
    
    @AuraEnabled
    public static Boolean profileAndProductCheck(String basketId){
        System.debug('profileAndProductCheck called ');
        Boolean profileAndProductCheck;
        //Start of DIGI-16454 added by Jay(Osaka) to get marketable offer Id for IOT
        Map<string,Sobject> MTMMetadataUtility = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
        String iotProdSpec = String.valueOf(MTMMetadataUtility.get('IoT_Marketable_Offer').get('Value__c'));
        //End of DIGI-16454


        System.debug('basketId in profileAndProductCheck ' + basketId);
        Boolean profileCheck = csvUploaderHelper.getProfileInfoForSalesUser();
        System.debug('profileCheck in profileAndProductCheck ' + profileCheck);
        
        List<cscfga__Product_Configuration__c> prodConfigList = new List<cscfga__Product_Configuration__c>();
        //Start of DIGI-16454 added by Jay(Osaka) to add prodSepc for IOT
       if(iotProdSpec != NULL){
       prodConfigList = [SELECT id , name FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.Id = :basketId
       AND (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile
       OR cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc
       OR cscfga__Product_Definition__r.product_Specification__c =: iotProdSpec) ];
       }
       //End of DIGI-16454
       else{
       prodConfigList = [SELECT id , name FROM cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__r.Id = :basketId
       AND (cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecMobile
       OR cscfga__Product_Definition__r.product_Specification__c IN: listproductSpecNgUc
       ) ];
      }
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
       System.debug('prodConfigList.size() ' + prodConfigList.size());
        if(profileCheck == false && (prodConfigList.size() != 0 || prodConfigList != null )){
            profileAndProductCheck = true;
        }
        //Start of DIGI:5333 Added by Jayghosh(Osaka) to enable Product Family dropdown for Partners
           else{
               System.debug('Basket id in else ' + basketId);
               System.debug('Inside else for PRM Profile');
               profileAndProductCheck = false;
               Boolean checkForTenancy = checkForTenancyOfferIdForCurrentBasket(basketId);
               System.debug('checkForTenancy value ' + checkForTenancy);
               if(checkForTenancy){
                   System.debug('Inside checkForTenancy for PRM ');
                   String profileNameforPRMCheck =[Select Id,Name from Profile where Id=:profileId].Name;
                   if(profileNameforPRMCheck =='PRM Community User - Australia' || profileNameforPRMCheck == 'PRM Admin - Australia'){
                       System.debug('Inside profileNameforPRMCheck for PRM');
                       profileAndProductCheck = true;
                   }
               }
           }
        //End of DIGI:5333 Added by Jayghosh(Osaka) to enable Product Family dropdown for Partners
           return profileAndProductCheck;
    }
/*************************************************************************************************
Name : getCIDNDetails
Description :Method to fetch CIDN hierarchy details
Developer : Abhishek Mallick
Team : Osaka
Story: EDGE-198196
***************************************************************************************************/
    @AuraEnabled
    public static Map<String, String> getCIDNDetails(String basketid){
        DetailsWrapper detailWrapRec = getServiceType(basketid);
        Map<String, String> cidnDetails = new Map<String, String>();
        List<Account> accList = new List<Account>();
        List<Account> cidnAccList = new List<Account>();
        Set<String> ultimateParentList = new Set<String>();
        accList = [SELECT id,Name,CIDN__c,Customer_Status__c,Parent_CIDN__c,Ultimate_Parent_CIDN__c from Account where
                   (CIDN__c = :detailWrapRec.accountCIDN OR Parent_CIDN__c = :detailWrapRec.accountCIDN OR Ultimate_Parent_CIDN__c = :detailWrapRec.accountCIDN)
                   AND (Customer_Status__c = 'ACTIVE' OR Customer_Status__c = 'ACQUIRED')];
        System.debug('CIDN List:::'+accList);
        if(accList!=null && !accList.isEmpty()){ 
            for(Account accRec : accList){
                if(accRec.Ultimate_Parent_CIDN__c!=null && accRec.Ultimate_Parent_CIDN__c!=''){
                    System.debug('Account Status:::' +accRec.Customer_Status__c);
                    ultimateParentList.add(accRec.Ultimate_Parent_CIDN__c);
                    
                }
            }
        }
        System.debug('Ultimate CIDN Value::'+ultimateParentList);
        if(ultimateParentList!=null && !ultimateParentList.isEmpty()){
            cidnAccList = [SELECT id, Name, CIDN__c,Ultimate_Parent_CIDN__c,Customer_Status__c from Account where (CIDN__c IN :ultimateParentList OR Ultimate_Parent_CIDN__c IN :ultimateParentList)
                          AND (Customer_Status__c = 'ACTIVE' OR Customer_Status__c = 'ACQUIRED')];
            System.debug('CIDN list ultimate::'+cidnAccList);
            if(cidnAccList!=null && !cidnAccList.isEmpty()){
                for(Account accRecNew : cidnAccList){
                    if(accRecNew.CIDN__c != detailWrapRec.accountCIDN){
                        cidnDetails.put(accRecNew.CIDN__c+' '+accRecNew.Name,accRecNew.CIDN__c);
                    }   
                }
            }    
        }
        System.debug('Final List::'+cidnDetails);
        
        return cidnDetails;
    } 
 /**
* @Author   :   Jayghosh Mishra
* @Team     :   Osaka
* @US       :   EDGE-198192
* @Desc     :   <B2B-1547>Ability for users to upload the consent email/CHOWN web form for CIDN hierarchy transition && to identify any existing approvals in opportunity
* */
    
     @AuraEnabled
    public static String uploadAuthorization(list<Object> filesToInsert, String opportunityId){
        System.debug('opportunityId ' + opportunityId);
        System.debug('uploadAuthorization called');
        String duplicateFiles = '';
        String response = '';
        list<Id> lstCntVerIds = new list<Id>();
        List<ContentDocumentLink> cdList = new List<ContentDocumentLink> ();
        String fileTitle = '';
        List<String> fileTitleList = new List<String>();
        List<String> alreadyUploadedConsentForm = new List<String>();
        List<String> uploadedFileName = new List<String> ();
        fileTitleList = fetchContentTitleList(opportunityId);
        System.debug('fileTitleList ' + fileTitleList);
        // String fileTitle = '';
        // Creating ContentVersion record
        List<ContentVersion> lstVersionsToInsert = new List<ContentVersion>();
        for (Object file : filesToInsert) {
            FileInfo fileData = (FileInfo)JSON.deserialize(JSON.serialize(file), FileInfo.class);
            System.debug('fileData created Line 177 -->>' + fileData);
            ContentVersion objCntVersion = new ContentVersion();
            objCntVersion.PathOnClient = fileData.Title;
            objCntVersion.Title = fileData.Title;
            objCntVersion.VersionData = fileData.VersionData;
             String newFileName = fileData.Title.substring(0, fileData.Title.indexOf('.'));
            newFileName = newFileName.replaceAll('\\D','');
            System.debug('newFileName ' + newFileName);
            if(!fileTitleList.contains(newFileName)){
              lstVersionsToInsert.add(objCntVersion);
                
            }else{
                if(alreadyUploadedConsentForm != NULL){
                alreadyUploadedConsentForm.add(fileData.Title);
              duplicateFiles = String.join(alreadyUploadedConsentForm, ',');
                
                }    
            }
            }
        if(duplicateFiles != NULL){
            response = duplicateFiles;
        }else{
            response = '';
        }
        System.debug('response for Duplicate ' + response);
        insert lstVersionsToInsert;
        //Linking file to Opportunity record
        List<ContentVersion> conVersRec = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ID IN: lstVersionsToInsert];
        String conDocId ='';
        List<String> conDocIdList = new List<String> ();
        for(ContentVersion conRec : conVersRec){
            conDocId = conRec.ContentDocumentId;
            conDocIdList.add(conDocId);
        }
        System.debug('conDocIdList!!!! ' + conDocIdList);
        for(String conDocIDRec : conDocIdList){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = opportunityId;
            cdl.ContentDocumentId = conDocIDRec;
            cdl.shareType = 'V';
            cdList.add(cdl);
            
        }
        insert cdList; 
        return response;
    }
    
    /**
* @Author   :   Jayghosh Mishra
* @Team     :   Osaka
* @US       :   EDGE-198192
* @Desc     :   <B2B-1547>Ability for users to upload the consent email/CHOWN web form for CIDN hierarchy transition
* */
    //Getting existing attached file from Opportunity
     public static List<String> fetchContentTitleList(String opportunityId){
       String fileTitle = '';
        List<String> fileTitleList = new List<String>();
        List<ContentDocumentLink> attachedFileDeatails = [SELECT Id, LinkedEntityId, ContentDocumentId, ContentDocument.Title FROM ContentDocumentLink where LinkedEntityId =: opportunityId and LinkedEntity.Type='Opportunity'];
        for(ContentDocumentLink contentDoc : attachedFileDeatails){
            
            fileTitle = contentDoc.ContentDocument.Title;
            if(fileTitle.contains('.')){
            String extractedFileName = fileTitle.substring(0, fileTitle.indexOf('.'));
            extractedFileName = extractedFileName.replaceAll('\\D','');
            System.debug('extractedFileName ' + extractedFileName);
            fileTitleList.add(extractedFileName);
            }else{
               fileTitleList.add(fileTitle); 
            }
        }
        return fileTitleList;
    }
     /**
        * @Author   :   Jayghosh Mishra
    * @Team     :   Osaka
    * @US       :   EDGE-198192
    * @Desc     :   <B2B-1547>Fetching delta approvals based on selected CIDNs and already attached CIDNs to the opportunity
    * */
    
     @AUraEnabled 
    public static String missingAuthorization(List<String> selectedCIDNs, String opportunityId ){
        List<String> oppAttachment = new List<String>();
        String missingAttachment = '';
        List<String> pendingAttachment = new List<String>();
         Set<String> uploadedSet = new Set <String> (selectedCIDNs);
        if(opportunityId != NULL){
           oppAttachment =  fetchContentTitleList(opportunityId);
        }
        Set<String> attachedSet = new Set <String> (oppAttachment);
        if(!uploadedSet.isEmpty() && !attachedSet.isEmpty()){
            for(String selectedCIDN : uploadedSet){
                if(!attachedSet.contains(selectedCIDN)){
                    pendingAttachment.add(selectedCIDN);
                }
            }
        }else if(!uploadedSet.isEmpty()){
            pendingAttachment.addAll(uploadedSet);
        }
        if(pendingAttachment != NULL){
            missingAttachment = String.join(pendingAttachment, ', ');
        }
        System.debug('missingAttachment ' + missingAttachment);
        return missingAttachment;
    }

     /**
* @Author   :   Jayghosh Mishra
* @Team     :   Osaka
* @US       :   EDGE-198192
* @Desc     :   <B2B-1547>Wrapper class called by uploadAuthorization
* */
    public class FileInfo {
        @AuraEnabled public String Title;
        @AuraEnabled public Blob VersionData;
    }
    
    /**
    * @Author   :   Jayghosh Mishra
    * @Team     :   Osaka
    * @US       :   EDGE-198192
    * @Desc     :   <B2B-1547>Getting the CIDNs from uploaded CSV(In case of bulk upload)
    * */
    @AuraEnabled
    public static List<String> cidnsInHierarchy(String base64Data, String basketId) {
        DetailsWrapper details = new DetailsWrapper ();
        set<String> targetCidnSet = new set<String> ();
        details = getServiceType(basketId);
        String targetCidn = '';
        if(details != NULL){
            targetCidn = details.accountCIDN;
        }
        System.debug('targetCidn in new method ' + targetCidn);
        System.debug('details in cidnsInHierarchy ' + details);
        List<String> uploadedCidnInFile = new List<String> ();
        if(base64Data != NULL){
        String data= JSON.deserializeUntyped(base64Data).toString();
        Set<String> checkForCIDNHierarchy = csvUploaderHelper.checkForCIDNHierarchy(basketId);
        set<String> uploadedCIDNset = new Set<String>();
        String cidn = '';
        list<String> lstCSVLines = data.split('\n');
        List<String> lstcolumnHeaders = lstCSVLines[0].split(',');
          List<String> csvRowData = new List<String>();
        for(Integer i = 1; i < lstCSVLines.size(); i++){
            String csvLine = lstCSVLines[i];
            List<String> CIDNList = lstCSVLines[i].split(',');
            cidn = CIDNList[1].replaceAll(':quotes:', '').replaceAll(':comma:', '');
            if(checkForCIDNHierarchy.contains(cidn) && cidn != targetCidn){
            	uploadedCIDNset.add(cidn);
            }
        }
        uploadedCidnInFile.addAll(uploadedCIDNset);
        }
        System.debug('uploadedCidnInFile finally ' + uploadedCidnInFile);
        return uploadedCidnInFile;
    }
    
   // EDGE-198192
    /**
    * @Author   :   Pradeep Mudenur
    * @Team     :   Osaka
    * @US       :   EDGE-218061
    * @Desc     :   <B2B 1327>Enable the legacy product selection for NGUC prod family and Mobility
    * */
    
    @AuraEnabled
    public static List<String> fetchProductFamily(String productFamily) {
        List<String> productFamilyList = new List<String>();
        List<String> familyList=new List<String>();
        System.debug('Product Family Value::'+productFamily);
        try {
            Product_Family_Transition__mdt productFamilyTransition = new Product_Family_Transition__mdt();
            productFamilyTransition = Product_Family_Transition__mdt.getInstance(productFamily);
            System.debug('Prod Family Values:::'+productFamilyTransition);
            familyList=String.valueOf(productFamilyTransition.Product_Family_Values__c).split(',');
            System.debug('Family List::'+familyList);
            for (String famList : familyList)
            {
                productFamilyList.add(famList.trim());
            }
        } 
        catch (Exception ex)
        {
            System.debug('Exception in fetchProductFamily' + ex);
            productFamilyList.clear();
            return productFamilyList;
        }
        System.debug('ProductFamilyListValues ' + productFamilyList);
        return productFamilyList;
    }
    
    //EDGE-218061
    
    
    /*************************************************************************************************
     Name : TransitionSelectContoller
	 Description :Returning flag for Markatable Offer Id for tenancy check(DIGI-1754) in the current basket
	Author: Jay (Osaka) 
	Story: (DIGI-1754)
    ***************************************************************************************************/
    
    public static Boolean checkForTenancyOfferIdForCurrentBasket(String basketId){
        System.debug('checkForTenancyOfferIdForCurrentBasket called');
        Boolean isTenancyOffer = false;
        Set<String> markatableOfferIdSet = new Set<String> ();
        //String tenancyOfferId = System.Label.mtm_OfferIdForTenancy;
        //String tenancyOfferId = 'DMCAT_Offer_000675';
        //DIGI-6039 :- Added by Jay(Osaka) for removing hardcoded offer name
        Map<string,Sobject> MTMMetadataUtilityMap = ConstantMetadataUtility.getConstantMetadataUtilityRecords('MTM_Metadata_Utility__mdt');
        String tenancyOfferId = String.valueOf(MTMMetadataUtilityMap.get('Adaptive_Collaboration_Tenancy_OfferChec').get('Value__c'));
        // End of DIGI-6039
        System.debug('tenancyOfferId ' + tenancyOfferId);
        try{
        List<cscfga__Product_Configuration__c> prodConfigList = [Select Id, Name,Marketable_Offer__c, cscfga__Product_Basket__c, Marketable_Offer__r.Offer_ID__c from cscfga__Product_Configuration__c where cscfga__Product_Basket__c =: basketId];
        if(prodConfigList != NULL){
            for(cscfga__Product_Configuration__c prodConfigRec : prodConfigList){
                if(prodConfigRec.Marketable_Offer__r.Offer_ID__c != NULL){
                    String markatableOfferId = prodConfigRec.Marketable_Offer__r.Offer_ID__c;
                    markatableOfferIdSet.add(markatableOfferId);
                }
            }
        }
        if(markatableOfferIdSet != NULL){
        if(markatableOfferIdSet.contains(tenancyOfferId)){
            System.debug('inside if of tenancy' + tenancyOfferId);
            isTenancyOffer = true;
        }
        }
        }
        catch(Exception ex){
			System.debug('exception in checkForTenancyOfferIdForCurrentBasket '+ex);            
        }
        return isTenancyOffer;
    }
    //Adding Space
}
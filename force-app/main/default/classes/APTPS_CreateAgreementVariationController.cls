public class APTPS_CreateAgreementVariationController {

    public List<APTPS_AgreementSelection> agreementListToBeDisplayed {get; set;}
    
    public map<Id, Apttus__APTS_Agreement__c> selectedAgreementList {get; set;}

    public Integer selectedAgreementListSize{get; set;}

    public List<string> selectedAgreementListIds {get; set;}
    
    public Integer attachmentsToBeCopiedSize{get; set;}

    public List<string> attachmentsToBeCopied {get; set;}
    
    public string agreementName{get;set;}

    //Getting the record type id
     public Id recordtypeid {get; set;}
         
    public Apttus__APTS_Agreement__c parentAgreement {get; set;}
        
    public boolean showError {get; set;}
    
    public Map<Id, List<Id>> attachmentAgreementMap = new Map<Id, List<Id>>();
    Map<Id,Id> amendedAgmts {get; set;}
        
    //This is the constructor of the class. Here we will store the agreement id for further operations
    public APTPS_CreateAgreementVariationController(ApexPages.StandardController  stdController)
    {
        if(!Test.isRunningTest()){
            stdController.addFields(new List<string>{'Name','Apttus__Status_Category__c', 'Apttus__Status__c'});
        }
        parentAgreement = (Apttus__APTS_Agreement__c)stdController.getRecord();
        recordtypeid = parentAgreement.RecordTypeId;
        agreementName = parentAgreement.Name;
    }
    public APTPS_CreateAgreementVariationController(){}



    /*************************************************************************************************************************
     @Name: getAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method returns the list of Child agreements along with the parent agreement for displaying on the screen
    *************************************************************************************************************************/
    public List<APTPS_AgreementSelection> getAgreements()
    {
        APTPS_AgreementSelection agreementSelection = null;
        if(agreementListToBeDisplayed == null)
        {
            agreementListToBeDisplayed = new List<APTPS_AgreementSelection>();
            
            for(Apttus__APTS_Agreement__c agrmnt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, APTPS_Title__c,
                                                        Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                                        APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate  
                                                        from Apttus__APTS_Agreement__c
                                                        where (Id =:parentAgreement.Id or Apttus__Parent_Agreement__c =:parentAgreement.Id)
                                                        and Apttus__Status_Category__c = 'In Effect' and (Apttus__Status__c = 'Activated' or Apttus__Status__c = 'Rolling')
                                                        order by Apttus__FF_Agreement_Number__c])
            {
                agreementSelection = new APTPS_AgreementSelection(agrmnt);
                if(agrmnt.Apttus__Parent_Agreement__c == null)
                {
                    agreementSelection.selected = true;
                }
                //Converting the agreement record into AgreementForGeneration wrapper class
                agreementListToBeDisplayed.add(agreementSelection);
            }
        }
       
        return agreementListToBeDisplayed;
        
        
    }

    /*************************************************************************************************************************
     @Name: cancel
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method is called on clicking cancel button on VF page and takes the user back on agreement page
    *************************************************************************************************************************/
    public PageReference cancel()
    {
        PageReference pageRef = new PageReference('/'+parentAgreement.Id);
        //pageRef.setredirect(true);
        
        return pageRef;
    }

    /*************************************************************************************************************************
     @Name: createListForGenerateAgreements
     @Author: Shishir Bose
     @Created Date: 04/12/2016
     @Descripton: This method is called on clicking generate button. It populates a list of selected agreement and kicks off 
     the agreement generation process
    *************************************************************************************************************************/
    public PageReference createListForAgreementsToBeAmended()
    {
        selectedAgreementList = new map<Id, Apttus__APTS_Agreement__c>();
        boolean isParentSelected = true;
        selectedAgreementListSize = 0;
        for(APTPS_AgreementSelection agrGen : agreementListToBeDisplayed)
        {
            //Adding the selected agreement to the list
            if(agrGen.selected == false)
            {
                if(agrGen.agreement.Apttus__Parent_Agreement__c == null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Parent agreement has to be selected for creating variation.')); 
                    selectedAgreementListSize = 0;
                    showError = true;
                    return null;
                }
            }
            else
            {
               selectedAgreementListSize = selectedAgreementListSize + 1; 
               
            }
            
        }
        
        //Checking if any agreement is selected or not to send the error message on screen
        if(selectedAgreementListSize == 0)
        {
            selectedAgreementListSize = 0;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please select atleast one record.'));
            showError = true;
        }
        else
        {
            //Setting this variable helps in javascript to find out whether the generate agreement to be called or not
            amendAgreement();            
        }
        
        return null;
    }

    private void amendAgreement()
    {
        selectedAgreementListIds = new List<string>();
        Apttus__APTS_Agreement__c newParentAgreement = null;
        Apttus__APTS_Agreement__c newChildAgreement = null;
        List<Apttus__APTS_Agreement__c> childAgreements = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> originalAgreements = new List<Apttus__APTS_Agreement__c>();
        amendedAgmts = new Map<Id,Id>();
        
        //Amending Parent Agreement. Reparenting/Amending the child agreements
        for(APTPS_AgreementSelection agrGen : agreementListToBeDisplayed)
        {
            //Amending the Parent Agreement
            if(agrGen.agreement.Apttus__Parent_Agreement__c == null)
            {
                if(!Test.isRunningTest()){
                    newParentAgreement = Apttus.AgreementWebService.amendAgreement(parentAgreement.Id);
                    newParentAgreement.APTPS_Parent_Agreement_Id__c = parentAgreement.Id;
                    insert newParentAgreement;
                }
                if(Test.isRunningTest()){ // Dummy data created for Test class.
                    Account dummyAccount = [Select Id From Account Limit 1];
                    newParentAgreement = APTPS_TestClassData.agreementWRecordType(dummyAccount.id, 'SA');
                }
                amendedAgmts.put(parentAgreement.id, newParentAgreement.id);
                originalAgreements.add(agrGen.agreement);               
                
            }
            else
            {
                //Reparenting the child agreements that are not to be amended
                if(agrGen.selected == false)
                {   
                    newChildAgreement = new Apttus__APTS_Agreement__c();
                    newChildAgreement = agrGen.agreement;
                    newChildAgreement.Apttus__Parent_Agreement__c = newParentAgreement.Id;
                    newChildAgreement.APTPS_Is_Custom_Update__c = true;
                    childAgreements.add(newChildAgreement);
                }
                else
                {
                    //Amending the child agreements
                    newChildAgreement = new Apttus__APTS_Agreement__c();
                    if(!Test.isRunningTest()){
                        newChildAgreement = Apttus.AgreementWebService.amendAgreement(agrGen.agreement.Id);
                        newChildAgreement.Apttus__Parent_Agreement__c = newParentAgreement.Id;
                        insert newChildAgreement;
                    }
                    if(Test.isRunningTest()){
                        Account dummyAccount = [Select Id From Account Limit 1];
                        newChildAgreement = APTPS_TestClassData.agreementWRecordType(dummyAccount.id, 'Schedule');
                        newChildAgreement.Apttus__Parent_Agreement__c = newParentAgreement.Id;
                        update newChildAgreement;
                    }
                    amendedAgmts.put(agrGen.agreement.id, newChildAgreement.id);
                    originalAgreements.add(agrGen.agreement);
                    
                }
                
            }
        }
        for(Apttus__APTS_Agreement__c agmt : [select Id, Name, Apttus__FF_Agreement_Number__c, Apttus__Status_Category__c, 
                                                Apttus__Status__c,  Apttus__Agreement_Category__c,  Apttus__Subtype__c,
                                                APTPS_Agreement_Subcategory__c,Apttus__Parent_Agreement__c,createddate  
                                                from Apttus__APTS_Agreement__c
                                                where Apttus__Parent_Agreement__c =:parentAgreement.Id
                                                and Apttus__Status__c != 'Activated' and Apttus__Status__c != 'Rolling'
                                                order by createddate])
        {
            agmt.Apttus__Parent_Agreement__c = newParentAgreement.Id;
            agmt.APTPS_Is_Custom_Update__c = true;
            childAgreements.add(agmt);
        }                                                           
        if(childAgreements.size() > 0 )
        {
            Update childAgreements;
            for(Apttus__APTS_Agreement__c agmt : childAgreements){
                agmt.APTPS_Is_Custom_Update__c = false;
            }
            Update childAgreements;
        }
        if(originalAgreements.size() > 0 )
        {
            for(Apttus__APTS_Agreement__c agmts : originalAgreements)
            {
                agmts.Apttus__Status_Category__c = 'In Effect';
                agmts.Apttus__Status__c = 'Being Amended';
            }
            Update originalAgreements;
        }
        if(!amendedAgmts.isEmpty()){
            selectedAgreementListIds = amendedAgmts.values();
            createRelatedAgreement(amendedAgmts);
            //reparentRelatedList(amendedAgmts);
            getChildFromConfig(amendedAgmts);
            copyNonActivatedAttachments(amendedAgmts);
        }
        
     parentAgreement = newParentAgreement;
        
    }
    public void createRelatedAgreement(Map<Id,Id> amendedAgmts){
        //map of original and amended agreements.
        Apttus__APTS_Related_Agreement__c relatedAgmt;
        List<Apttus__APTS_Related_Agreement__c> firstRelatedAgmtList = new List<Apttus__APTS_Related_Agreement__c>();
        List<Apttus__APTS_Related_Agreement__c> restRelatedAgmtList = new List<Apttus__APTS_Related_Agreement__c>();
        for(Id amgtId : amendedAgmts.keySet())
        {
            //relationship of the amended agreement with it's immediate parent agreement
            relatedAgmt = new Apttus__APTS_Related_Agreement__c();
            relatedAgmt.name = 'Current Agreement';
            relatedAgmt.Apttus__Relationship_From_Type__c = 'Is Amended By';
            relatedAgmt.Apttus__Relationship_To_Type__c = 'Is Amendment For';
            relatedAgmt.Apttus__APTS_Contract_To__c = amendedAgmts.get(amgtId);
            relatedAgmt.Apttus__APTS_Contract_From__c = amgtId;
            firstRelatedAgmtList.add(relatedAgmt);
        }
        if(firstRelatedAgmtList.size() >0)
        {
            insert firstRelatedAgmtList;
        }
        for(Apttus__APTS_Related_Agreement__c oldRelAgmt : [Select Apttus__APTS_Contract_From__c,Apttus__APTS_Contract_To__c, Apttus__APTS_Contract_From__r.id
                                    From Apttus__APTS_Related_Agreement__c where Apttus__APTS_Contract_To__c IN : amendedAgmts.keySet()])
        {
            relatedAgmt = new Apttus__APTS_Related_Agreement__c();
            relatedAgmt.name = 'Current Agreement';
            relatedAgmt.Apttus__Relationship_From_Type__c = 'Is Amended By';
            relatedAgmt.Apttus__Relationship_To_Type__c = 'Is Amendment For';
            relatedAgmt.Apttus__APTS_Contract_To__c = amendedAgmts.get(oldRelAgmt.Apttus__APTS_Contract_To__c);
            relatedAgmt.Apttus__APTS_Contract_From__c = oldRelAgmt.Apttus__APTS_Contract_From__r.id;
            restRelatedAgmtList.add(relatedAgmt);
        }
        if(restRelatedAgmtList.size() >0)
        {
            insert restRelatedAgmtList;
        }
        
        
       
    }
    
    /*********Added later for child and grandchild objects using Variation Config***************/
    public Pagereference getChildFromConfig(Map<Id,Id> amendedAgmts){
        List<Apttus__APTS_Admin__c> variationConfig = [select Id, Name,Apttus__Code__c from Apttus__APTS_Admin__c where Name = 'APTS_VariationConfig' Limit 1];
        if(variationConfig.size() == 0){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please set up Variations Config before Creating Variation'));
            showError = true;
            return null;
        }
        String variationConfigXML = variationConfig[0].Apttus__Code__c;
        Dom.Document doc = new Dom.Document();
        doc.load(variationConfigXML);
        
        Set<Id> agmtIdSet = amendedAgmts.keyset();
         
        /*try
        {*/
            //Retrieve the root element for this document.
            Dom.XMLNode variationsConfig = doc.getRootElement();
            List<id> newAgmtsIdList = amendedAgmts.values();
        /*}
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please set up Variations Config properly before Creating Variation'));
            return null;
        }*/ 
        try
        {       
            //Clear Fields
            string clearFieldQueryString = '';
            
            Dom.XMLNode clearFields = variationsConfig.getChildElement('ClearFields', null);
            
            List<string> clearFieldList = new List<string>();
            
            for(Dom.XMLNode clearfield : clearFields.getChildElements()) 
            {
                string fieldApi = clearfield.getChildElement('Name', null).getText(); 
             
                clearFieldList.add(fieldApi); 
                clearFieldList.add('APTPS_Active_Agreements__c');
                
                clearFieldQueryString += ', '+fieldApi;
            }
            String clearQuery = 'Select id'+clearFieldQueryString+' , APTPS_Active_Agreements__c from Apttus__APTS_Agreement__c where id IN : newAgmtsIdList';
            
                       
            List<sObject> agmtList = Database.query(clearQuery);
            
            String type = 'Apttus__APTS_Agreement__c';
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType leadSchema = schemaMap.get(type);
            Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
            
            for(sObject newAgmt : agmtList)
            {
                for(string fieldName : clearFieldList) 
                {
                    //It provides to get the object fields data type.
                    Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                    if(fielddataType == Schema.DisplayType.Boolean)
                    {
                        newAgmt.put(fieldName, false);
                    }
                    else
                    {
                        newAgmt.put(fieldName, null);
                    }
                    //setting the default value for Approval status field after clearing.
                    if(fieldName == 'Apttus_Approval__Approval_Status__c'){
                        newAgmt.put(fieldName, 'No Approval Needed');
                    }
                }
            }
            
            update agmtList; // updates the new agreement with the selected fields for clearing.
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please set up Clear fields in Variations Config properly before Creating Variation'));
            showError = true;
            return null;
        }
        List<sObject> insertSObject = new List<sObject>();      
        try
        {   
            //Cloned Objects
            Dom.XMLNode clonedObjects = variationsConfig.getChildElement('ClonedObjects', null);  
            List<sObject> updatedGCSObject = new List<sObject>(); 
            for(Dom.XMLNode child : clonedObjects.getChildElements()) 
            {
                string childObjectApi = child.getChildElement('Name', null).getText(); 
                string childRelationField = child.getChildElement('RelationField', null).getText(); 
                
                List<String> sObjectFields = new List<String>{};
                
                Schema.SObjectType objectType  = Schema.getGlobalDescribe().get(childObjectApi);
                sObjectFields.addAll(objectType.getDescribe().fields.getMap().keySet());
                String allSObjectFieldsQuery = ' ' + sObjectFields.get(0);
                
                for (Integer i=1 ; i < sObjectFields.size() ; i++)
                {
                    allSObjectFieldsQuery += ', ' + sObjectFields.get(i);
                }
                string query = 'Select '+allSObjectFieldsQuery;
                
                Map<string,string> gCReparentObjectList = new Map<string,string>();
                Map<string,string> gCCloneObjectList = new Map<string,string>();
                Map<string,string> gCObjectFieldMap = new Map<string,string>();
                
                for(Dom.XMLNode grandChild : child.getChildElements())
                {
                    if(grandChild.getName() == 'GrandChildReparented')
                    {
                        string gCObjectApi = grandChild.getChildElement('Name', null).getText(); 
                        string gCRelationField = grandChild.getChildElement('RelationField', null).getText(); 
                        string gCChildRelationship = grandChild.getChildElement('ChildRelationship', null).getText(); 
                        
                        gCObjectFieldMap.put(gCObjectApi,gCRelationField);
                        
                        gCReparentObjectList.put(gCObjectApi, gCChildRelationship);
                        
                        string subQuery = ', (Select Id, '+gCRelationField+' from '+gCChildRelationship+')';
                        query = query + subQuery;   
                    }
                    if(grandChild.getName() == 'GrandChildCloned')
                    {
                        string gCObjectApi = grandChild.getChildElement('Name', null).getText(); 
                        string gCRelationField = grandChild.getChildElement('RelationField', null).getText();
                        string gCChildRelationship = grandChild.getChildElement('ChildRelationship', null).getText();
                        
                        gCObjectFieldMap.put(gCObjectApi,gCRelationField);
                        
                        
                        List<String> grandChildsObjectFields = new List<String>{};
                        Schema.SObjectType gcObjectType  = Schema.getGlobalDescribe().get(gCObjectApi);
                        grandChildsObjectFields.addAll(gcObjectType.getDescribe().fields.getMap().keySet());
                        
                        String allGCSObjectFieldsQuery = ' ' + grandChildsObjectFields.get(0); 
                        for (Integer i=1 ; i < grandChildsObjectFields.size() ; i++)
                        {
                            allGCSObjectFieldsQuery += ', ' + grandChildsObjectFields.get(i);
                        }
                        gCCloneObjectList.put(gCObjectApi, gCChildRelationship);
                        string subQuery = ', (Select '+allGCSObjectFieldsQuery+' from '+gCChildRelationship+')';
                        query = query + subQuery;   
                    }
                }
                query = query + ' from '+childObjectApi+' where '+childRelationField+' In : agmtIdSet';
                List<sObject> sobjList = Database.query(query);
                
                
                for(sObject obj : sobjList)
                {
                    sObject clonedSOb = obj.clone(false, true, false, false);
                    Id originalId = Id.valueOf(string.valueOf(obj.get(childRelationField)));
                    clonedSOb.put(childRelationField, amendedAgmts.get(originalId));
                   
                    //Added as there is Filter criteria on Agreement Clause lookup on Obligation object to select agreement clauses associated only 
                    //to the associated agreement on Obligation.
                    if(childObjectApi == 'Apttus_SRM__SRMObligation__c')
                    {
                        clonedSOb.put('APTPS_Agreement_Clause__c', null);
                        clonedSOb.put('APTPS_Auto_Obligation__c', false);
                    }
                    
                    insert clonedSOb;
                    
                    for(string objectRelationshipName : gCReparentObjectList.keyset())
                    {
                        List<sObject> childObjects = obj.getSObjects(gCReparentObjectList.get(objectRelationshipName));
                        if(childObjects != null && childObjects.size() > 0)
                        {
                            for(sObject childObj : childObjects)
                            {
                                childObj.put(gCObjectFieldMap.get(string.valueof(childObj.getSObjectType())), clonedSOb.id);
                                updatedGCSObject.add(childObj);
                            }
                        }
                    }
                    for(string objectRelationshipName : gCCloneObjectList.keyset())
                    {
                        List<sObject> childObjects = obj.getSObjects(gCCloneObjectList.get(objectRelationshipName));
                        if(childObjects != null && childObjects.size() > 0)
                        {
                            for(sObject childObj : childObjects)
                            {
                                sObject clonedSObj = childObj.clone(false, true, false, false);
                                clonedSObj.put(gCObjectFieldMap.get(string.valueof(childObj.getSObjectType())), clonedSOb.id);
                                insertSObject.add(clonedSObj);
                            }
                        }
                    }
                }
            }
            if(updatedGCSObject.size() > 0)
            {
                update updatedGCSObject;
            }
            if(insertSObject.size() > 0)
            {
                insert insertSObject;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please set up Cloning Specifications in Variations Config properly before Creating Variation'));
            showError = true;
            return null;
        }
        
        /*try
        {
            //Reparented Objects
            Dom.XMLNode reparentedObjects = variationsConfig.getChildElement('ReparentedObjects', null);  
            List<sObject> updatedChildSObject = new List<sObject>();         
            for(Dom.XMLNode child : reparentedObjects.getChildElements()) 
            {
                string childObjectApi = child.getChildElement('Name', null).getText();
                string childRelationField = child.getChildElement('RelationField', null).getText();    
                              
                string query = 'Select id, '+childRelationField+' from '+childObjectApi+' where '+childRelationField+' In : agmtIdSet';
                
                List<sObject> sobjList = Database.query(query);
                
                for(sObject obj : sobjList)
                {
                    Id originalId = Id.valueOf(string.valueOf(obj.get(childRelationField)));
                    obj.put(childRelationField, amendedAgmts.get(originalId));
                    
                    updatedChildSObject.add(obj);
                }
            }
            if(insertSObject.size() > 0)
            {
                insert insertSObject;
            }
            if(updatedChildSObject.size() > 0)
            {
                update updatedChildSObject;
            }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.error,'Please set up Reparenting Specifications in Variations Config properly before Creating Variation'));
            showError = true;
            return null;
        }*/
                     
        return null;
    }
    
     public void copyNonActivatedAttachments(Map<Id,Id> amendedAgmts){
        //for notes
        List<Note> newNoteList  = new List<Note>();
        for(Note noteRec : [SELECT Body,Id,IsPrivate,OwnerId,ParentId,Title FROM Note 
                                WHERE ParentId In : amendedAgmts.keySet()])
        {
            Note newNote = noteRec.clone();
            newNote.ParentId = amendedAgmts.get(noteRec.ParentId);
            newNoteList.add(newNote);
        }
        if(newNoteList.size() > 0){
            insert newNoteList;
        }
                
        //for attachments       
        List<Id> tempList;
        
     
       
        attachmentsToBeCopiedSize = 0;
        attachmentsToBeCopied = new List<string>();
       
        for(Attachment att : [SELECT id, Name,  ParentId, SystemModstamp FROM Attachment WHERE ParentId In : amendedAgmts.keySet()
                        order by SystemModstamp asc])
        {
            attachmentsToBeCopiedSize++;
            attachmentsToBeCopied.add(att.Id);             
        }
       
    }
    
    public void cloneAttachments()
    {
        string attachmentIdstr = String.valueOf(ApexPages.currentPage().getParameters().get('attachmentId')).trim();
        Id attachmentId = Id.valueOf(attachmentIdstr);
        Attachment att = [SELECT id, Body, BodyLength, ContentType, Description, IsPrivate, Name,
                              OwnerId, ParentId FROM Attachment WHERE Id =: attachmentId];
        
        Attachment newAttachment = att.clone();
        newAttachment.ParentId = amendedAgmts.get(att.ParentId);
        insert newAttachment;
       
        List<Id> tempList;
        
        if(attachmentAgreementMap.get(newAttachment.ParentId) != null)
        {
            tempList = attachmentAgreementMap.get(newAttachment.ParentId);
            tempList.add(newAttachment.Id);

            attachmentAgreementMap.remove(newAttachment.ParentId);

            attachmentAgreementMap.put(newAttachment.ParentId, tempList);

        }
        else
        {
            tempList = new List<Id>();
            tempList.add(newAttachment.Id);
            attachmentAgreementMap.put(newAttachment.ParentId, tempList);
        }
        
    }
    
    public void enableAuthoringAsync(){
        List<Id> tempList = new List<Id>();
        String apiSessionId = UserInfo.getSessionId(); 
        if(attachmentAgreementMap.size() > 0)
        {
            string agreementId = String.valueOf(ApexPages.currentPage().getParameters().get('agreementId')).trim();
            id agrmtId = Id.valueOf(agreementId);
            
            tempList = attachmentAgreementMap.get(agrmtId);
            if(tempList != null && tempList.size() > 0){
                enableAuthoringCallout(agrmtId, tempList, apiSessionId);
            }
        }
        
    }
    
    //@future (callout =true)
    private static void enableAuthoringCallout(Id parentId, List<Id> docIds, String apiSessionId )
    {
        String pLevel = 'Insert comments and tracked changes only'; 
        //String docFormat = 'DOCX'; 
        String apiServerURL = System.Url.getSalesforceBaseUrl(). toExternalForm() + APTPS_Constants.SOAP_API_ADDRESS + UserInfo.getOrganizationId(); 
        if(!Test.isRunningTest()){
            Boolean enableAuthoringStatus = Apttus.MergeWebService.enableAuthoring(parentId, pLevel, docIds, apiSessionId, apiServerURL); 
        }
    }

}
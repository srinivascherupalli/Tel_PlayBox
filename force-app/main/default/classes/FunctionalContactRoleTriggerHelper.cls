/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 26/06/2018
@Story: EDGE-25250
@Description: FunctionalContactRoleHelper class for holding bussiness logic related method of FCR.
@TestCoverageClass: FunctionalContactRoleTriggerTest
@ChangeLog: v1: Created
********************************************************************************/
public without sharing class FunctionalContactRoleTriggerHelper {
    
    //Variable Declaration
    Map<Id,Functional_Contact_Role__c> mapFCRSiteRole;
    Map<Id,Functional_Contact_Role__c> mapFCROrderBasketRole;
    Map<Id,Functional_Contact_Role__c> mapFCRSubcriptionRole;
    Map<Id,Functional_Contact_Role__c> mapFCRContractRole;
 
	//EDGE-34563(AC6)
	//When I create a new Contract FCR 
	//And The Contact has no Authorisation over the Contract Account (ACR Role Type "Full Authorised" or "Legal Lessee")
	//Then the following error should be thrown

    public void validateFCRContract(List<Functional_Contact_Role__c> lstNewFCR){
        Set<Id> setFCRContract = new Set<Id>();
        Map<Id,Id> mapContractFCRAccountContact = new Map<Id,Id>();
        if(!lstNewFCR.isEmpty()){
            Id fcrContractRTId = getFCRRecordTypeId('Contract Role');
            for(Functional_Contact_Role__c fcr : lstNewFCR){
                //system.debug('lstNewFCR.get('+index+').RecordTypeId >> '+ lstNewFCR.get(index).RecordTypeId);
                if(fcrContractRTId == fcr.RecordTypeId){
                    setFCRContract.add(fcr.Contract__c);
                    }
            }
            if(!setFCRContract.isEmpty()){
                List<ContractJunction__c> lstContractAcc= [SELECT Id,Account__c,isDigBSA_PSVarRequiredForRA__c,RelatedAccount__c 
                                                           FROM ContractJunction__c WHERE Id in :setFCRContract];
                if(!lstNewFCR.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){
                        if(fcrContractRTId == lstNewFCR.get(index).RecordTypeId){
                            for(ContractJunction__c ContractAcc :lstContractAcc ){
                                if(ContractAcc.RelatedAccount__c==null && ContractAcc.isDigBSA_PSVarRequiredForRA__c==false){
                                    if(ContractAcc.id == lstNewFCR.get(index).Contract__c){
                                        mapContractFCRAccountContact.put(lstNewFCR.get(index).ContactID__c, ContractAcc.Account__c);
                                    }
                                } 
                            }
                        } 
                    }
                  } 
             }
             if(!mapContractFCRAccountContact.isEmpty()){
                Map<Integer,AccountContactRelation> mapAuthACR = getACRForContract(lstNewFCR,mapContractFCRAccountContact);
                //system.debug('inside validateContractFCRContact -> mapAuthACR >> '+ mapAuthACR);
                if(mapAuthACR.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){                      
                        lstNewFCR[index].addError(System.Label.FCR_Contract_NonAuthorisation_ErrorMsg); 
                    }
                } 
                if(!mapAuthACR.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){
                        if(fcrContractRTId == lstNewFCR.get(index).RecordTypeId){
                            AccountContactRelation acr = mapAuthACR.get(index);
                            //system.debug('inside validateFCRContractContact -> acr >> '+ acr);
                            if(acr != null && (!'Full Authority'.equalsIgnoreCase(acr.Roles) && !'Legal Lessee'.equalsIgnoreCase(acr.Roles)))   
                            	lstNewFCR[index].addError(System.Label.FCR_Contract_NonAuthorisation_ErrorMsg);
                            	//lstNewFCR[index].addError('Test Message');
                        }
                    }
                }
            }
            
        }
    } 
    
    @TestVisible
    private Map<Integer,AccountContactRelation> getACRForContract(List<Functional_Contact_Role__c> lstNewFCR, Map<Id,Id> mapFCRAccCon){        
        system.debug('inside getACRForFCR -> mapFCRAccCon.values() AccId >> '+ mapFCRAccCon.values());
        system.debug('inside getACRForFCR -> mapFCRAccCon.values() ContactId >> '+ mapFCRAccCon.keyset());
        Id fcrContractRTId = getFCRRecordTypeId('Contract Role');
        Map<Integer,AccountContactRelation> mapFcrAcr = new Map<Integer,AccountContactRelation>();
        List<AccountContactRelation> lstFcrAcr = [SELECT Id,ContactId,AccountId,Roles
                                                  FROM AccountContactRelation 
                                                  WHERE AccountId IN :mapFCRAccCon.values() 
                                                  AND ContactId IN :mapFCRAccCon.keyset()];
        //system.debug('inside getACRForFCR -> lstFcrAcr >> '+ lstFcrAcr);
        if(lstFcrAcr != null && !lstFcrAcr.isEmpty()){           
            for(Integer index=0; index < lstNewFCR.size(); index++){
                if(fcrContractRTId == lstNewFCR.get(index).RecordTypeId){
                    for(AccountContactRelation acr : lstFcrAcr)
                    {
                        system.debug('inside getACRForFCR -> acr >> '+ acr);
                        system.debug('inside getACRForFCR -> mapFCRAccCon.containsKey(acr.ContactId) >> '+ mapFCRAccCon.containsKey(acr.ContactId));
                        system.debug('inside getACRForFCR -> acr.AccountId == mapFCRAccCon.get(acr.ContactId) >> '+ acr.AccountId +'=='+ mapFCRAccCon.get(acr.ContactId));
                        if(lstNewFCR.get(index).ContactID__c == acr.ContactId 
                           && mapFCRAccCon.containsKey(acr.ContactId) 
                           && acr.AccountId == mapFCRAccCon.get(acr.ContactId)){
                               mapFcrAcr.put(index, acr);
                           }
                    }
                }      
            }
        }
        return mapFcrAcr;
    }   
     
    //EDGE-25250 (AC1) 
    //WHEN I create a functional contact role for a contact of type Billing
    //AND I search for Billing Account AND the Contact does not have an authority over the Billing Account Customer
    //THEN the following error is thrown
    public void validateFCRBillingContact(List<Functional_Contact_Role__c> lstNewFCR){
        Set<Id> setFCRBilAcc = new Set<Id>();
        Map<Id,Id> mapFCRAccountContact = new Map<Id,Id>();
        //system.debug('inside validateFCRBillingContact -> lstNewFCR' + lstNewFCR);
        if(!lstNewFCR.isEmpty()){    
            Id fcrBillingRTId = getFCRRecordTypeId('Billing Account Role');
            //system.debug('inside if lstNewFCR.size() > '+ lstNewFCR.size());
            for(Functional_Contact_Role__c fcr : lstNewFCR){
                //system.debug('lstNewFCR.get('+index+').RecordTypeId >> '+ lstNewFCR.get(index).RecordTypeId);
                if(fcrBillingRTId == fcr.RecordTypeId){
                    setFCRBilAcc.add(fcr.Billing_Account_Number__c);
                }
            }
            //system.debug('inside validateFCRBillingContact -> mapFCRIdContactId >> '+ mapFCRIdContactId);
            //system.debug('inside validateFCRBillingContact -> setFCRBilAcc >> '+ setFCRBilAcc);
            if(!setFCRBilAcc.isEmpty()){
                List<Billing_Account__c> lstBillAcc = [SELECT Id,Account__c FROM Billing_Account__c WHERE Id in :setFCRBilAcc];
                //system.debug('inside validateFCRBillingContact -> lstBillAcc >> '+ lstBillAcc);
                if(!lstBillAcc.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){
                        if(fcrBillingRTId == lstNewFCR.get(index).RecordTypeId){
                            for(Billing_Account__c billAcc : lstBillAcc){
                                //system.debug('inside validateFCRBillingContact -> billAcc.id >> '+ billAcc.id);
                                //system.debug('inside validateFCRBillingContact -> billAcc.Account__c >> '+ billAcc.Account__c);
                                //system.debug('inside validateFCRBillingContact -> lstNewFCR.get('+index+').Billing_Account_Number__c >> '+ lstNewFCR.get(index).Billing_Account_Number__c);
                                if(billAcc.id == lstNewFCR.get(index).Billing_Account_Number__c){
                                    mapFCRAccountContact.put(lstNewFCR.get(index).ContactID__c, billAcc.Account__c);
                                }
                            }
                        } 
                    }
                }        
            }
            
            //system.debug('inside validateFCRBillingContact -> mapFCRAccountContact >> '+ mapFCRAccountContact);
            if(!mapFCRAccountContact.isEmpty()){
                Map<Integer,AccountContactRelation> mapAuthACR = getACRForFCRBilling(lstNewFCR, mapFCRAccountContact);
                //system.debug('inside validateFCRBillingContact -> mapAuthACR >> '+ mapAuthACR);
                if(mapAuthACR.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){                      
                        lstNewFCR[index].addError(System.Label.FCR_BillingAccount_NonAuthorised_ErrorMsg); 
                    }
                } else if(!mapAuthACR.isEmpty()){
                    for(Integer index=0; index < lstNewFCR.size(); index++){
                        if(fcrBillingRTId == lstNewFCR.get(index).RecordTypeId){
                            AccountContactRelation acr = mapAuthACR.get(index);
                            //system.debug('inside validateFCRBillingContact -> acr >> '+ acr);
                            if(acr != null && 'Non-Authorised'.equalsIgnoreCase(acr.Roles))   
                            	lstNewFCR[index].addError(System.Label.FCR_BillingAccount_NonAuthorised_ErrorMsg);
                        }
                    }
                }
            }
        }    
    }
    
    //EDGE-25250: This method will get the ACR with Roles for the given Parent Account via Billing Account and contact while creating FCR.
    @TestVisible
    private Map<Integer,AccountContactRelation> getACRForFCRBilling(List<Functional_Contact_Role__c> lstNewFCR, Map<Id,Id> mapFCRAccCon){        
        //system.debug('inside getACRForFCR -> mapFCRAccCon.values() AccId >> '+ mapFCRAccCon.values());
        //system.debug('inside getACRForFCR -> mapFCRAccCon.values() ContactId >> '+ mapFCRAccCon.keyset());
        Id fcrBillingRTId = getFCRRecordTypeId('Billing Account Role');
        Map<Integer,AccountContactRelation> mapFcrAcr = new Map<Integer,AccountContactRelation>();
        List<AccountContactRelation> lstFcrAcr = [SELECT Id,ContactId,AccountId,Roles
                                                  FROM AccountContactRelation 
                                                  WHERE AccountId IN :mapFCRAccCon.values() 
                                                  AND ContactId IN :mapFCRAccCon.keyset()];
        //system.debug('inside getACRForFCR -> lstFcrAcr >> '+ lstFcrAcr);
        if(lstFcrAcr != null && !lstFcrAcr.isEmpty()){           
            for(Integer index=0; index < lstNewFCR.size(); index++){
                if(fcrBillingRTId == lstNewFCR.get(index).RecordTypeId){
                    for(AccountContactRelation acr : lstFcrAcr)
                    {
                        //system.debug('inside getACRForFCR -> acr >> '+ acr);
                        //system.debug('inside getACRForFCR -> mapFCRAccCon.containsKey(acr.ContactId) >> '+ mapFCRAccCon.containsKey(acr.ContactId));
                        //system.debug('inside getACRForFCR -> acr.AccountId == mapFCRAccCon.get(acr.ContactId) >> '+ acr.AccountId +'=='+ mapFCRAccCon.get(acr.ContactId));
                        if(lstNewFCR.get(index).ContactID__c == acr.ContactId 
                           && mapFCRAccCon.containsKey(acr.ContactId) 
                           && acr.AccountId == mapFCRAccCon.get(acr.ContactId)){
                               mapFcrAcr.put(index, acr);
                           }
                    }
                }      
            }
        }
        return mapFcrAcr;
    }   
    
    //EDGE-25250 (AC2)
    //WHEN I add a functional contact role for a contact of type Site Role
    //AND if the contact does not have any existing ACR with the parent Account of Site
    //THEN automatically a new ACR is created for the Contact with the Parent Account of Site
    //AND Contact Role as "Non Authorized"
    public void validateFCRSiteRole(){
        Map<Id,Map<Id,Id>> mapFcrSiteRoleContAcc = getFCRSiteRoleAccConMap();
        //system.debug('Inside-> validateFCRSiteRole-> mapFcrSiteRoleContAcc >> ' + mapFcrSiteRoleContAcc); 
        if(!mapFcrSiteRoleContAcc.isEmpty()){
            validateCreateACRforFCR(mapFcrSiteRoleContAcc);
        }  
    }
    
    //Method to create a map of Contact and Account for a specific Site Role.
    @TestVisible
    private Map<Id,Map<Id,Id>> getFCRSiteRoleAccConMap(){
        Map<Id,Id> mapFcrSiteRoleId = new Map<Id,Id>();
        Map<Id,Id> mapFcrSiteRoleParentAccId = new Map<Id,Id>();
        Map<Id,Map<Id,Id>> mapFcrSiteRoleContAcc = new Map<Id,Map<Id,Id>>();
        system.debug('Inside-> getFCRSiteRoleAccConMap-> mapFCRSiteRole >> ' + mapFCRSiteRole); 
        if(mapFCRSiteRole != null && !mapFCRSiteRole.isEmpty()){
            for(Functional_Contact_Role__c siteFCR: mapFCRSiteRole.values()){
                mapFcrSiteRoleId.put(siteFCR.Id, siteFCR.SiteID__c);
            }
            system.debug('Inside-> getFCRSiteRoleAccConMap-> mapFcrSiteRoleId >> ' + mapFcrSiteRoleId); 
            if(!mapFcrSiteRoleId.isEmpty()){
                List<cscrm__Site__c> lstCSSite = [SELECT Id,cscrm__Account__c 
                                                  FROM cscrm__Site__c 
                                                  WHERE Id IN :mapFcrSiteRoleId.values()]; 
                system.debug('Inside-> getFCRSiteRoleAccConMap-> lstCSSite >> ' + lstCSSite);
                for(cscrm__Site__c fcrSite : lstCSSite){
                    mapFcrSiteRoleParentAccId.put(fcrSite.Id,fcrSite.cscrm__Account__c);
                }
            }
            system.debug('Inside-> getFCRSiteRoleAccConMap-> mapFcrSiteRoleParentAccId >> ' + mapFcrSiteRoleParentAccId); 
            if(!mapFcrSiteRoleParentAccId.isEmpty()){
                for(Functional_Contact_Role__c siteFcr : mapFCRSiteRole.values()){
                    if(mapFcrSiteRoleParentAccId.containsKey(siteFcr.SiteID__c)){
                        Map<Id,Id> mapfcrSiteContactParentAccount = new Map<Id,Id>();
                        mapfcrSiteContactParentAccount.put(siteFcr.ContactID__c, mapFcrSiteRoleParentAccId.get(siteFcr.SiteID__c));
                        mapFcrSiteRoleContAcc.put(siteFcr.Id, mapfcrSiteContactParentAccount);
                    }
                }
            }
        }
        return mapFcrSiteRoleContAcc;
    }
    
    //EDGE-25250 (AC3)
    //WHEN I add a functional contact role for a contact of type Order/Basket Role
    //AND if the contact does not have any existing ACR with the parent Account of Order/Basket Role
    //THEN automatically a new ACR is created for the Contact with the Parent Account of Order/Basket Role
    //AND Contact Role as "Non Authorized"
    public void validateFCROrderBasketRole(){
        Map<Id,Map<Id,Id>> mapFcrOrdBasRoleContAcc = getFCROrderBasketRoleAccConMap();
        //system.debug('Inside-> validateFCROrderBasketRole-> mapFcrOrdBasRoleContAcc >> ' + mapFcrOrdBasRoleContAcc); 
        if(!mapFcrOrdBasRoleContAcc.isEmpty()){
            validateCreateACRforFCR(mapFcrOrdBasRoleContAcc);
        }
    }
    
    //Method to create a map of Contact and Account for a specific OrderBasket Role.
    @TestVisible
    private Map<Id,Map<Id,Id>> getFCROrderBasketRoleAccConMap(){
        Map<Id,Map<Id,Id>> mapFcrOrdBasRoleContAcc = new Map<Id,Map<Id,Id>>();
        Map<Id,Id> mapFcrOrdBasRoleId = new Map<Id,Id>();
        Map<Id,Id> mapFcrOrdBasRoleParentAccId = new Map<Id,Id>();
        //system.debug('Inside-> getFCROrderBasketRoleAccConMap-> mapFCROrderBasketRole >> ' + mapFCROrderBasketRole); 
        if(mapFCROrderBasketRole != null && !mapFCROrderBasketRole.isEmpty()){
            for(Functional_Contact_Role__c ordBasFCR: mapFCROrderBasketRole.values()){
                mapFcrOrdBasRoleId.put(ordBasFCR.Id, ordBasFCR.OrderID__c);
            }
            //system.debug('Inside-> getFCROrderBasketRoleAccConMap-> mapFcrOrdBasRoleId >> ' + mapFcrOrdBasRoleId); 
            if(!mapFcrOrdBasRoleId.isEmpty()){
                List<csord__Order__c> lstCSOrder = [SELECT Id,csord__Account__c 
                                                    FROM csord__Order__c 
                                                    WHERE Id IN :mapFcrOrdBasRoleId.values()]; 
                //system.debug('Inside-> getFCROrderBasketRoleAccConMap-> lstCSOrder >> ' + lstCSOrder);
                for(csord__Order__c fcrOrder : lstCSOrder){
                    mapFcrOrdBasRoleParentAccId.put(fcrOrder.Id,fcrOrder.csord__Account__c);
                }
            }
            //system.debug('Inside-> getFCROrderBasketRoleAccConMap-> mapFcrOrdBasRoleParentAccId >> ' + mapFcrOrdBasRoleParentAccId); 
            if(!mapFcrOrdBasRoleParentAccId.isEmpty()){
                for(Functional_Contact_Role__c orderFcr : mapFCROrderBasketRole.values()){
                    if(mapFcrOrdBasRoleParentAccId.containsKey(orderFcr.OrderID__c)){
                        Map<Id,Id> mapfcrOrderBasContactParentAccount = new Map<Id,Id>();
                        mapfcrOrderBasContactParentAccount.put(orderFcr.ContactID__c, mapFcrOrdBasRoleParentAccId.get(orderFcr.OrderID__c));
                        mapFcrOrdBasRoleContAcc.put(orderFcr.Id, mapfcrOrderBasContactParentAccount);
                    }
                }
            }
        }
        return mapFcrOrdBasRoleContAcc;
    }
    
    //EDGE-25250 (AC4)
    //WHEN I add a functional contact role for a contact of type Subscription Role
    //AND if the contact does not have any existing ACR with the parent Account of Subscription Role
    //THEN automatically a new ACR is created for the Contact with the Parent Account of Subscription Role
    //AND Contact Role as "Non Authorized"
    public void validateFCRSubcriptionRole(){
        Map<Id,Map<Id,Id>> mapFcrSubRoleContAcc = getFCRSubcriptionRoleAccConMap();
        //system.debug('Inside-> validateFCRSubcriptionRole-> mapFcrSubRoleContAcc >> ' + mapFcrSubRoleContAcc); 
        if(!mapFcrSubRoleContAcc.isEmpty()){
            validateCreateACRforFCR(mapFcrSubRoleContAcc);
        }
    }
    
    //Method to create a map of Contact and Account for a specific OrderBasket Role.
    @TestVisible
    private Map<Id,Map<Id,Id>> getFCRSubcriptionRoleAccConMap(){
        Map<Id,Map<Id,Id>> mapFcrSubRoleContAcc = new Map<Id,Map<Id,Id>>();
        Map<Id,Id> mapFcrSubRoleId = new Map<Id,Id>();
        Map<Id,Id> mapFcrSubRoleParentAccId = new Map<Id,Id>();
        //system.debug('Inside-> getFCRSubcriptionRoleAccConMap-> mapFCRSubcriptionRole >> ' + mapFCRSubcriptionRole); 
        if(mapFCRSubcriptionRole != null && !mapFCRSubcriptionRole.isEmpty()){
            for(Functional_Contact_Role__c subFCR: mapFCRSubcriptionRole.values()){
                mapFcrSubRoleId.put(subFCR.Id, subFCR.SubscriptionID__c);
            }
            //system.debug('Inside-> getFCRSubcriptionRoleAccConMap-> mapFcrSubRoleId >> ' + mapFcrSubRoleId); 
            if(!mapFcrSubRoleId.isEmpty()){
                List<csord__Subscription__c> lstCSSub = [SELECT Id,csord__Account__c 
                                                         FROM csord__Subscription__c 
                                                         WHERE Id IN :mapFcrSubRoleId.values()]; 
                //system.debug('Inside-> getFCRSubcriptionRoleAccConMap-> lstCSSub >> ' + lstCSSub);
                for(csord__Subscription__c fcrSub : lstCSSub){
                    mapFcrSubRoleParentAccId.put(fcrSub.Id,fcrSub.csord__Account__c);
                }
            }
            //system.debug('Inside-> getFCRSubcriptionRoleAccConMap-> mapFcrSubRoleParentAccId >> ' + mapFcrSubRoleParentAccId); 
            if(!mapFcrSubRoleParentAccId.isEmpty()){
                for(Functional_Contact_Role__c subFcr : mapFCRSubcriptionRole.values()){
                    if(mapFcrSubRoleParentAccId.containsKey(subFcr.SubscriptionID__c)){
                        Map<Id,Id> mapfcrSubContactParentAccount = new Map<Id,Id>();
                        mapfcrSubContactParentAccount.put(subFcr.ContactID__c, mapFcrSubRoleParentAccId.get(subFcr.SubscriptionID__c));
                        mapFcrSubRoleContAcc.put(subFcr.Id, mapfcrSubContactParentAccount);
                    }
                }
            }
        }
        return mapFcrSubRoleContAcc;
    }
    
    //EDGE-23230: Method to validate if the ACR is available for given account and contact.
    @TestVisible
    private void validateCreateACRforFCR(Map<Id,Map<Id,Id>> mapfcrContAcc){
        Set<Id> setContactId = new Set<Id>();
        Set<Id> setAccountId = new Set<Id>();
        Map<Id,AccountContactRelation> mapACR = new Map<Id,AccountContactRelation>();        
        //system.debug('Inside-> verifyandCreateACR-> mapfcrContAcc >> ' + mapfcrContAcc);    
        for(Id key : mapfcrContAcc.keyset()){
            for(Id contactId : mapfcrContAcc.get(key).keyset()){
                setContactId.add(contactId);
                setAccountId.add(mapfcrContAcc.get(key).get(contactId));
            }
        }
        //system.debug('Inside-> verifyandCreateACR-> setAccountId >> ' + setAccountId); 
        //system.debug('Inside-> verifyandCreateACR-> setContactId >> ' + setContactId); 
        List<AccountContactRelation> lstFcrAcr = [SELECT Id,ContactId,AccountId,Roles FROM AccountContactRelation WHERE AccountId IN :setAccountId AND ContactId IN :setContactId];
        //system.debug('Inside-> verifyandCreateACR-> lstFcrAcr >> ' + lstFcrAcr); 
        
        if(lstFcrAcr == null || lstFcrAcr.isEmpty()){
            mapACR = prepareACRforFCR(mapfcrContAcc);
            //system.debug('Inside-> verifyandCreateACR-> mapACR >> ' + mapACR);
        }
        else{
            for(AccountContactRelation acr :lstFcrAcr){
                for(Id key : mapfcrContAcc.keyset()){
                    for(Id contactId : mapfcrContAcc.get(key).keyset()){
                        if(acr.ContactId != contactId 
                           && acr.AccountId != mapfcrContAcc.get(key).get(contactId) 
                           && !mapACR.containsKey(key))
                        {
                            AccountContactRelation newACR = new AccountContactRelation();
                            newAcr.AccountId = mapfcrContAcc.get(key).get(contactId);
                            newAcr.ContactId = contactId;
                            newAcr.Roles='Non-Authorised';
                            //system.debug('Inside-> verifyandCreateACR-> newAcr >> ' + newAcr); 
                            mapACR.put(key,newACR);
                        }
                    }
                }
            }
        }
        //system.debug('Inside-> verifyandCreateACR-> ACR to Create mapACR >> ' + mapACR); 
        If(!mapACR.isEmpty())
        {
            INSERT mapACR.values();        
        }
    }
    
    //EDGE-25250: Method to prepare the new ACR to be created for FCR of site role.
    @TestVisible
    private Map<Id,AccountContactRelation> prepareACRforFCR(Map<Id,Map<Id,Id>> mapsiteContAcc){
        Map<Id,AccountContactRelation> mapNewACR = new Map<Id,AccountContactRelation>();
        for(Id siteId : mapsiteContAcc.keyset()){
            for(Id contactId : mapsiteContAcc.get(siteId).keyset()){
                AccountContactRelation newACR = new AccountContactRelation();
                newAcr.AccountId = mapsiteContAcc.get(siteId).get(contactId);
                newAcr.ContactId = contactId;
                newAcr.Roles='Non-Authorised';
                //system.debug('Inside-> prepareACRforFCR-> newAcr >> ' + newAcr); 
                mapNewACR.put(siteId,newACR);
            }
        }
        return mapNewACR;
    }    
    
    //EDGE-2525: Method to seregate the new FCR records based on the record type into respective map's.
    public void seperateFCRPerRecordType(Map<Id,Functional_Contact_Role__c> mapNewFCR){
        mapFCRSiteRole = new Map<Id,Functional_Contact_Role__c>();
        mapFCROrderBasketRole = new Map<Id,Functional_Contact_Role__c>();
        mapFCRSubcriptionRole = new Map<Id,Functional_Contact_Role__c>();
        Id fcrRecTypeSiteRole = getFCRRecordTypeId('Site Role');
        Id fcrRecTypeOrderBasketRole = getFCRRecordTypeId('Basket/Order Role');
        Id fcrRecTypeSubcriptionRole = getFCRRecordTypeId('Subscription Role');
        //system.debug('Inside-> seperateFCRPerRecordType-> fcrRecTypeSiteRole >> ' + fcrRecTypeSiteRole);  
        //system.debug('Inside-> seperateFCRPerRecordType-> fcrRecTypeOrderBasketRole >> ' + fcrRecTypeOrderBasketRole);  
        //system.debug('Inside-> seperateFCRPerRecordType-> fcrRecTypeSubcriptionRole >> ' + fcrRecTypeSubcriptionRole);
        for(Functional_Contact_Role__c newfcr : mapNewFCR.values()){
            if(fcrRecTypeSiteRole == newfcr.RecordTypeId){
                mapFCRSiteRole.put(newfcr.Id, newfcr);
            }else if(fcrRecTypeOrderBasketRole == newfcr.RecordTypeId){
                mapFCROrderBasketRole.put(newfcr.Id, newfcr);
            }else if(fcrRecTypeSubcriptionRole == newfcr.RecordTypeId){
                mapFCRSubcriptionRole.put(newfcr.Id, newfcr);
            } 
        }
        //system.debug('Inside-> seperateFCRPerRecordType-> mapFCRSiteRole >> ' + mapFCRSiteRole);  
        //system.debug('Inside-> seperateFCRPerRecordType-> mapFCROrderBasketRole >> ' + mapFCROrderBasketRole);  
        //system.debug('Inside-> seperateFCRPerRecordType-> mapFCRSubcriptionRole >> ' + mapFCRSubcriptionRole);
    }
    
    //EDGE-25250: To get the record type id from the name.
    @TestVisible
    private Id getFCRRecordTypeId(String recTypeName){
        return (string.isNotBlank(recTypeName))?Schema.SObjectType.Functional_Contact_Role__c.getRecordTypeInfosByName().get(recTypeName).getRecordTypeId(): null;
    }
    //EDGE-41494 AC3
    public void validateOrderPrimaryContact(List<Functional_Contact_Role__c> lstNewFCR){
        if(checkUserProfile()){
            Set<id>  orderIds = new  Set<id>();
            for(Functional_Contact_Role__c fcr: lstNewFCR){
                if(fcr.Role__c.equalsIgnoreCase('Order Primary Contact') && fcr.OrderID__c!=null ){
                    orderIds.add(fcr.OrderID__c);  
                }
            }
            if(!orderIds.isEmpty()){
                Map<id,csord__Order__c> mapOrderToFcr = new Map<id,csord__Order__c>([SELECT id, (SELECT id FROM Functional_Contact_Roles__r WHERE Relationship_End_Date__c=null AND Role__c='Order Primary Contact') FROM csord__Order__c where id IN :orderIds]);
                for(Functional_Contact_Role__c fcr: lstNewFCR){
                    if( mapOrderToFcr.keyset().contains(fcr.OrderID__c) && !(mapOrderToFcr.get(fcr.OrderID__c).Functional_Contact_Roles__r).isEmpty() ){
                         fcr.addError(System.Label.Order_Primary_contact_error_message); 
                    }
                }
            }
        }
    }
    public boolean checkUserProfile(){
        Profile ProfileName = [select Name from profile where id = :userinfo.getProfileId()];
        if(ProfileName__c.getInstance(ProfileName.Name)!=null){
            return true;
        }
        else{
            return false;
        } 
    }
}
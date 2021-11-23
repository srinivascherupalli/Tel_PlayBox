/********************************************************************************
@Last Modified      : 
No.       Developer Name      Date            Story Description 
********************************************************************************
1.		  Sravanthi			07/01/2021	   Sprint 21.01 - P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
2.        Pallavi(SFO)      13/09/2021     Sprint 21.13 - DIGI-8909 Created methods:filterRecipenetsByEmailIds(),sendChatterNotesOnPortCodeChange(),getRecipenetsByActRec().
3.        Sri(SFO)			23/09/2021     Sprint 21.13 - DIGI-15107 implemented updateManualNoSellCreditHealth

*******************************************************************************/


public without sharing class AccountTriggerHelper {
    
    private static boolean isRunonce = true; //added by saran
    private static boolean hasRunTerritoryAssignmentRule = false;
    //Added below 3 Boolean's as part of Sprint SFO 20.05 P2oB-5483 
    private static boolean stopRecursiveOnInsert = false;
    private static boolean stopRecursiveOnUpdateAAR = false;
    private static boolean stopRecursiveOnUpdateAO = false;
    
    private Set<String> insolventPortfolocodes= new Set<String>();// EDGE 32994
    
    //Added as part of DIGI-8909 Sprint 21.13 Team SFO .Starts here 
    public static Map<Id,Set<Id>> mapOfActIdActTeamMemId = new Map<Id,Set<Id>>();
    public static Map<String,List<Id>> mapOfPortCodeUserIds = new Map<String,List<Id>>();
    //Ends here.
    
    //EDGE-38 : calling field update method from helper to check field updates
    public static Map<id, sobject> fieldupdateidentifier(Map<Id,sobject> newMap,Map<Id,sobject> oldMap){
        FieldUpdateIdentifier fui = new FieldUpdateIdentifier(Account.SobjectType);
        Map<id, sobject> matches = fui.identifyUpdatesToMonitoredFields(newMap, oldMap);
        return matches;
    }
    
    public static Boolean isLOCROUCalculationRequired(){
        return (!EnvironmentalSettings.isSeedingEnabled() && !TCMGetCustomer.isCustomerFromTCM && !isAsyncJob());
        
    }
    
    public static Boolean isAsyncJob(){
        return (system.isBatch() || system.isFuture() || system.isQueueable() || system.isScheduled());
    }
    
    /*
* Method to create New AccountAddressRelationship
*/
    public static void createNewAccountAddressRelationship(Account[] newAccounts){
        
        List<cscrm__Account_Address_Relationship__c> relLst = new List<cscrm__Account_Address_Relationship__c>();
        
        //Added filter condition in IF statement to bypass process builder as part of Team SFO Sprint 20.05 P2OB-5483
        for(Account acc : newAccounts){
            if(acc.Primary_Address__c!=null && acc.AAR_to_Account__c == FALSE){ 
                relLst.add(createAAR(acc.id,acc.Primary_Address__c,Constants.ADDRESS_TYPE_PRIMARY));
            }           
        }
        if(relLst.size()>0){
            insert relLst;
        }
    }
    
    /*
* Method to update AccountAddressRelationship
* Modified by: Pallavi
* Changes : As part of Team SFO Sprint 20.05 P2OB-5483 ,modified by updating AAR to Inactive Instead of deleting..
*/
    
    public static void updateAccountAddressRelationship(Account[] oldAccounts, Map<ID, Account> oldAccountMap, 
                                                        Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
                                                            
                                                            if(!stopRecursiveOnUpdateAAR){
                                                                Map<id,id> accAAr = new Map<id,id>(); //Added As part of Team SFO Sprint 20.05 P2OB-5483
                                                                if(!AccountAddressRelationshipTriggerHelper.isExecutedByTrigger){
                                                                    List<cscrm__Account_Address_Relationship__c> relLst = new List<cscrm__Account_Address_Relationship__c>();
                                                                    
                                                                    //SET TO STORE THE SITES PRIMARY CONTACT WHERE VALUES HAVE CHANGED.
                                                                    Set<ID> setUpdatePrimaryAddress = new Set<ID>();
                                                                    for(Account oldAcct : oldAccountMap.values()){
                                                                        Account newAcct = updateAccountsMap.get(oldAcct.id);
                                                                        if(oldAcct.Primary_Address__c!=newAcct.Primary_Address__c){
                                                                            setUpdatePrimaryAddress.add(newAcct.id);
                                                                            accAAr.put(newAcct.id,newAcct.Primary_Address__c);//As part of Team SFO Sprint 20.05 P2OB-5483
                                                                            if(newAcct.Primary_Address__c!=null && newAcct.AAR_to_Account__c == FALSE){ //As part of Team SFO Sprint 20.05 P2OB-5483 added AAR_to_Account__c(recursive check)
                                                                                relLst.add(createAAR(newAcct.id,newAcct.Primary_Address__c,Constants.ADDRESS_TYPE_PRIMARY)); 
                                                                            }
                                                                        }          
                                                                    }
                                                                    
                                                                    List<cscrm__Account_Address_Relationship__c> lstUpdateExistingRels = new List<cscrm__Account_Address_Relationship__c>();
                                                                    //MOdified as part of Sprint SFO 20.05[P2OB-5483] by adding cscrm__Active__c=TRUE filter condition in Query 
                                                                    if(setUpdatePrimaryAddress.size()>0){
                                                                        for(cscrm__Account_Address_Relationship__c objExistingAAR : [SELECT cscrm__Account__c,cscrm__Address__c,Id,cscrm__Address_Type__c
                                                                                                                                     FROM cscrm__Account_Address_Relationship__c where cscrm__Account__c 
                                                                                                                                     IN :setUpdatePrimaryAddress AND cscrm__Address_Type__c =:Constants.ADDRESS_TYPE_PRIMARY AND cscrm__Active__c=TRUE]){ 
                                                                                                                                         if(accAAr.get(objExistingAAR.cscrm__Account__c) != objExistingAAR.cscrm__Address__c){ //MOdified as part of Sprint SFO 20.05[P2OB-5483] checking previous address and new address are not same
                                                                                                                                             objExistingAAR.cscrm__Active__c = false;//MOdified as part of Sprint SFO 20.05[P2OB-5483] by Making previous address cscrm__Active__c value as false 
                                                                                                                                             lstUpdateExistingRels.add(objExistingAAR);
                                                                                                                                         } 
                                                                                                                                     }
                                                                    } 
                                                                    List<cscrm__Account_Address_Relationship__c> upsrtAARs = new List<cscrm__Account_Address_Relationship__c>();
                                                                    //Update THE PREVIOUS RELATIONSHIPS..
                                                                    if(lstUpdateExistingRels.size()>0){
                                                                        AccountAddressRelationshipTriggerHelper.isExecutedByTrigger = true;
                                                                        upsrtAARs.addALL(lstUpdateExistingRels); //MOdified as part of Sprint SFO 20.05[P2OB-5483] by adding previous address list with cscrm__Active__c value as false
                                                                    }
                                                                    //INSERT THE NEW RELATIONSHIPS..
                                                                    ////MOdified as part of Sprint SFO 20.05[P2OB-5483] below two if conditions to update and insert address with respective cscrm__Active__c
                                                                    if(relLst.size()>0){
                                                                        upsrtAARs.addALL(relLst); 
                                                                    }
                                                                    if(upsrtAARs.size()>0){
                                                                        upsert upsrtAARs;
                                                                    }
                                                                }
                                                                stopRecursiveOnUpdateAAR=true;
                                                            }       
                                                            
                                                        }
    /*
* Method to initialise Site contact role
*/
    @TestVisible
    private static cscrm__Account_Address_Relationship__c createAAR(Id acctId,ID addrId,String addrType){
        cscrm__Account_Address_Relationship__c aar = new cscrm__Account_Address_Relationship__c();
        aar.cscrm__Account__c = acctId;
        aar.cscrm__Address__c = addrId;
        aar.cscrm__Address_Type__c = addrType;
        aar.cscrm__Active__c = true;
        aar.cscrm__Start_Date__c = System.today();
        aar.Account_to_AAR__c = true; //Added as part of Team SFO Sprint 20.05 P2OB-5483
        return aar;
    }
    
    /*
* Method to assign Territory Aligned Accounts to their specified Account Executive based on Territory Role Lookup.
* Runs when a new Account is created or an existing Account has its Portfolio Account modified to a non-null value.
* Modified by     : Pallavi B(SFO)
* @Sprint         : 20.10  & P2OB-6272
* @CreateDate     : 09/07/2020
*  Test Classes   : AccountTriggerTest
*/
    public static void updateAccountOwner(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        Map<Id, Account> oldAccountsMap = null;
        //Will be null when called from before insert
        if(oldAccounts != null){
            oldAccountsMap = new Map<Id, Account>(oldAccounts);
        }
        // Loop through the Accounts and create a Map of Account Id to Portfolio Code
        Map<String, List<Account>> portToAccountMap = new Map<String, List<Account>>();
        for(Account a : updatedAccounts){
            // Only map those accounts where PortCode has changed and is not null or Account is new
            if(a.Portfolio_Code__c != null && (oldAccountsMap == null || a.Portfolio_Code__c != oldAccountsMap.get(a.Id).Portfolio_Code__c)){
                if(portToAccountMap.containsKey(a.Portfolio_Code__c)){
                    portToAccountMap.get(a.Portfolio_Code__c).add(a);
                }
                else{
                    portToAccountMap.put(a.Portfolio_Code__c, new List<Account>{a});
                }
            }
        }
        
        
        String portfolioCodeSegment; //Added as part of P2OB-6272 Sprint 20.10
        Map<String, string> portCodeSegment = new Map<String, string>(); //Added as part of P2OB-6272 Sprint 20.10
        Map<String, string> portCodeVertical = new Map<String, string>(); //Added as part of P2OB-11782	 Sprint 21.08
        
        
        //Loop through applicable UserTerritory2Association records and associate Territory Owner to Account
        //Orders by last modified date in ascending order to ensure that if 2 owners exist the last added wins
        if(!portToAccountMap.isEmpty()){
            for(UserTerritory2Association portOwners : [select UserId, Territory2.Name, Territory2Id from UserTerritory2Association where Territory2.Territory2Model.State = 'Active' and Territory2.Name in :portToAccountMap.keySet() and RoleInTerritory2 = 'Owner' order by LastModifiedDate ASC]){
                String portCode = portOwners.Territory2.Name;
                for(Account acc : portToAccountMap.get(portCode)){
                    // creaetd field Portfolio_Management_Flag__c on account as per the P2OB-6272
                    // to skip the owner udpate when we update the account's portfolio code from the SFO_PortfolioManagementCaseHelper 
                    // as when the account owner is updated all the related account contacts will get update
                    // to skip if there were any validation errors on account owner and contact owner update implemented Portfolio_Management_Flag__c
                    if(!acc.Portfolio_Management_Flag__c){ 
                        acc.OwnerId = portOwners.UserId;
                    }else{
                        acc.Portfolio_Management_Flag__c = False;
                    }
                }
            }
            
            // Below code added as part of P2OB-6272 Sprint 20.10
            for (Portfolio_Code__c portcodes : [select id, name,Tier__c,Vertical__c from Portfolio_Code__c where name = :portToAccountMap.keySet()]){
                portfolioCodeSegment  = portcodes.name;
                portCodeSegment.put(portcodes.Name,portcodes.Tier__c);
                portCodeVertical.put(portcodes.Name,portcodes.Vertical__c); //Added as part of P2OB-11782	 Sprint 21.08
                
            }
            // Below code added as part of P2OB-6272 Sprint 20.10
            if(!portCodeSegment.isEmpty() && !portCodeVertical.isEmpty()){
                for(Account objacc : updatedAccounts){
                    objacc.APTPS_Tier__c = portCodeSegment.get(objacc.Portfolio_Code__c);
                    objacc.Vertical__c = portCodeVertical.get(objacc.Portfolio_Code__c); //Added as part of P2OB-11782 Sprint 21.08
                }
            }      
            
        }
        
    }    
    /**
* Method to run territory assignment rule
**/
    public static void runTerritoryAssignmentRule(Account[] oldAccounts, Account[] updatedAccounts, Map<ID, Account> updateAccountsMap){
        Map<Id, Account> oldAccountsMap;
        //Will be null when called from before insert
        if(oldAccounts != null){
            oldAccountsMap = new Map<Id, Account>(oldAccounts);
        }          
        //Initiate API call to start running territory assigment rule for this account.
        if(!Test.isRunningTest() ){
            RunTerritoryRules job = new RunTerritoryRules() ;                
            job.accntIds = new Set<String>(); 
            for(Account a : updatedAccounts){
                // Only map those accounts where PortCode has changed and is not null
                if(a.Portfolio_Code__c != null && (oldAccountsMap == null ||a.Portfolio_Code__c != oldAccountsMap.get(a.Id).Portfolio_Code__c)){    
                    
                    job.accntIds.add(a.Id);         
                }
            }
            if(job!=null && !job.accntIds.isEmpty() && !hasRunTerritoryAssignmentRule){
                System.enqueueJob(job);
                hasRunTerritoryAssignmentRule = true;
            }
        }
    }
    
    
    public void publishCreateEvents(List<Account> newAccounts, String event){
        //Dynamic Binding
        PublishEvents publishIntface=PublishEventsImpl.getInstance();
        publishIntface.createEventObject(newAccounts,EventConstants.BUSINESS_ENTITY_ACCOUNT,event);
        publishIntface.createEvent();
    }
    
    //EDGE-27948 : Update account as verified account if the "Today - Last Verified Date is less that 366 days"
    public void markAccountAsVerified(List<Account> lstNewAcc){
        For(Account acc : lstNewAcc){
            if(acc.Customer_Last_Verified_Date__c != null && string.isNotBlank(string.valueOf(acc.Customer_Last_Verified_Date__c)) 
               && acc.Customer_Last_Verified_Date__c.daysBetween(Date.today()) < Integer.valueOf(System.Label.Account_Verified_Criteria_Days)){
                   acc.Reviewed_Account__c = true;
               }
        }
    }
    
    //EDGE-27948 : Update account last verified date to today if account is verified account.
    public void updateAccountLastVerifiedDate(List<Account> lstNewAcc, Map<Id,Account> newAccMap, Map<Id,Account> oldAccMap){
        For(Account acc : lstNewAcc){
            if(acc.Reviewed_Account__c && !oldAccMap.get(acc.id).Reviewed_Account__c){
                acc.Customer_Last_Verified_Date__c = Date.today();
            } else if(acc.Customer_Last_Verified_Date__c != null && acc.Customer_Last_Verified_Date__c.daysBetween(Date.today()) < Integer.valueOf(System.Label.Account_Verified_Criteria_Days)){
                acc.Customer_Last_Verified_Date__c = Date.today();
                acc.Reviewed_Account__c = true;
            } else if(acc.Customer_Last_Verified_Date__c == null || acc.Customer_Last_Verified_Date__c.daysBetween(Date.today()) > Integer.valueOf(System.Label.Account_Verified_Criteria_Days)){
                acc.Reviewed_Account__c = false;
            }
        }
    }
    
    //EDGE-27948: Update business unit for an account based on Type and Customer status
    ////EDGE-68099 Removed Hard Coding
    public void updateAccountBusinessUnit(List<Account> lstNewAcc){
        for(Account acc : lstNewAcc){
            if(Label.Acc_Residential.equalsIgnoreCase(acc.Type) && Label.Acc_CustomerStatus_PENDING.equalsIgnoreCase(acc.Customer_Status__c)){
                acc.Business_Unit__c = Label.Acc_BusinessUnit;
            }else if ((Label.Acc_Type_Company.equalsIgnoreCase(acc.Type) || Label.Acc_Type_SoleTrader.equalsIgnoreCase(acc.Type) || Label.Acc_Type_Organisation.equalsIgnoreCase(acc.Type)) && Label.Acc_CustomerStatus_PENDING.equalsIgnoreCase(acc.Customer_Status__c)){
                acc.Business_Unit__c = Label.Acc_BusinessUnit_Business;
            }else if(Label.Acc_Type_Internal.equalsIgnoreCase(acc.Type) && Label.Acc_CustomerStatus_PENDING.equalsIgnoreCase(acc.Customer_Status__c)){
                acc.Business_Unit__c = Label.Acc_Business_Unit_Telstra;
            }
        }
    }
    
    //EDGE-32392: Update 'APTS_Acc_Tier__c' & 'Offshore_Restricted__c' fields on agreement after edit of Account record
    //start
    public void updateAgreement(List<Account> newAccountList )
    {
        try{
            List<Apttus__APTS_Agreement__c> listAgreement = [SELECT id,Apttus__Status_Category__c,Apttus__Status__c,APTS_Acc_Tier__c,Offshore_Restricted__c,Apttus__Account__r.APTPS_Tier__c,Apttus__Account__r.APTPS_Off_Shore_Restricted__c FROM Apttus__APTS_Agreement__c WHERE Apttus__Account__r.id IN : newAccountList ];
            
            List<Apttus__APTS_Agreement__c> listUpdatedAgreement = new List<Apttus__APTS_Agreement__c> ();
            
            
            for(Apttus__APTS_Agreement__c agr : listAgreement)
            {
                agr.APTS_Acc_Tier__c= agr.Apttus__Account__r.APTPS_Tier__c;
                //EDGE-68099 Removed Hard Coding
                //if((Label.Acc_Apptus_Status_Category_In_Effect.equalsIgnoreCase(agr.Apttus__Status_Category__c)) && (Label.Acc_Apptus_Status.equalsIgnoreCase(agr.Apttus__Status__c)))
                {
                    if(agr.Apttus__Account__r.APTPS_Off_Shore_Restricted__c==true)
                    {
                        agr.Offshore_Restricted__c = true;
                    }    
                    else
                    {
                        agr.Offshore_Restricted__c = false;
                    }
                }
                
                listUpdatedAgreement.add(agr);
                
            }
            
            if(!listUpdatedAgreement.isEmpty())
            {
                update listUpdatedAgreement;
            } 
            
            
        }
        catch(Exception e)
        {
            System.debug('Exception occured : '+e);
        }
    }
    //end
    
    
    /****************************************************************************
@Method Name: updatePrimaryAddress
@Author: SFO/Pallavi B
@Sprint :sprint 20.05 [P2OB-5483]
@CreateDate: 05/04/2020
@Description: As a Sales User I want to update the Account Address from the Account 
Details page so that it's easy to update and maintain addresses.                
This Method reffered in AccountTriggerHandler, in before insert and update methods 
to update the address details from  associated cscrmAddress record.
******************************************************************************/      
    public static void updatePrimaryAddress(List<Account> newAccountList,map<id, Account> oldAccountMap, map<id, Account> newAccMap){
        
        set<Id> addressIdSet = new set<id>();
        map<id,cscrm__Address__c> cscrmAddressMap = new map<id,cscrm__Address__c>();
        
        try{
            
            // For Loop START
            for(Account acc:newAccountList){
                if(acc.Primary_Address__c != null){
                    addressIdSet.add(acc.Primary_Address__c );
                }
            }
            // For Loop END
            
            if(!addressIdSet.isEmpty()){
                cscrmAddressMap.putall([SELECT id,locality__c,cscrm__State_Province__c,cscrm__Zip_Postal_Code__c,cscrm__Country__c,
                                        Sub_Address_Level_1_calc__c,Sub_Address_Level_2_calc__c,Sub_Address_Level_3_calc__c,Sub_Address_Level_4_calc__c,
                                        cscrm__Building_Name__c,Street_calc__c,
                                        cscrm__Street__c ,
                                        Sub_Address1_Type__c ,
                                        Sub_Address2_Type__c ,
                                        Sub_Address_3_Type__c ,
                                        Sub_Address_4_Type__c ,
                                        Sub_Address1_Number__c,
                                        Sub_Address2_Number__c,
                                        Sub_Address_3_Number__c,
                                        Sub_Address_4_Number__c
                                        FROM cscrm__Address__c where id in: addressIdSet]);
            }
            
            updateAccountBillingAddress(oldAccountMap,newAccountList,cscrmAddressMap);                  
            
            
        }catch(Exception ex){
            system.debug('Exception:::: AccountTriggerHelper Class:::: updatePrimaryAddress Method'+ Ex.getMessage());
        }
        
    }
    /****************************************************************************
@Method Name: updateAccountBillingAddress
@Author: SFO/Pallavi B
@Sprint :sprint 20.05 [P2OB-5483]
@CreateDate: 05/04/2020
@LastModifiedDate:
@Description: As a Sales User I want to update the Account Address from the Account 
Details page so that it's easy to update and maintain addresses
Assigning the builling info details in account records
Input Parameters :  Map<id, Account> oldAccountMap, 
list<Account> newAccountList, 
map<id,cscrm__Address__c> cscrmaddressMap
Output  :   Assigning the builling info details in account Builling Fields
******************************************************************************/ 
    private static void updateAccountBillingAddress(Map<id, Account> oldAccountMap, list<Account> newAccountList, map<id,cscrm__Address__c> cscrmaddressMap){
        cscrm__Address__c cscrmAddress;
        
        //START For Loop
        for(Account objAcc : newAccountList){
            Boolean ifCheck=((!cscrmaddressMap.isEmpty()) && 
                             (objAcc.Primary_Address__c != null ||
                              ((oldAccountMap != Null && 
                                objAcc.Primary_Address__c!= oldAccountMap.get(objAcc.Id).Primary_Address__c) ||
                               oldAccountMap == Null)) );
            Boolean elseIfCheck=(cscrmaddressMap.isEmpty() && objAcc.Primary_Address__c == null);               
            if(ifCheck){
                cscrmAddress=cscrmaddressMap.get(objAcc.Primary_Address__c);
                objAcc.BillingStreet = billingStreetPopulation(cscrmAddress);
                objAcc.BillingCity = cscrmAddress.Locality__c;
                objAcc.BillingCountry = cscrmAddress.cscrm__Country__c;
                objAcc.BillingPostalCode = cscrmAddress.cscrm__Zip_Postal_Code__c;
                objAcc.BillingState = cscrmAddress.cscrm__State_Province__c;
                
            }
            else if(elseIfCheck){
                objAcc.BillingCity = '';
                objAcc.BillingCountry ='';
                objAcc.BillingPostalCode ='';
                objAcc.BillingState ='';
                objAcc.BillingStreet =''; 
            }
        }
        //END For Loop
    }
    /****************************************************************************
@Method Name: billingStreetPopulation
@Author: SFO/Pallavi B
@Sprint :sprint 20.05 [P2OB-5483]
@CreateDate: 05/04/2020
@Description: As a Sales User I want to update the Account Address from the Account 
Details page so that it's easy to update and maintain addresses
This method called in updateAccountBillingAddress method 
Input parameters: cscrm__Address__c object;
Output: retutn subAddress Detail/billingStreet info in the form of String

******************************************************************************/ 
    private static string billingStreetPopulation(cscrm__Address__c cscrmAddress){
        
        string subAddressLevel1 = cscrmAddress.Sub_Address_Level_1_calc__c;
        string subAddressLevel2 = cscrmAddress.Sub_Address_Level_2_calc__c;
        string subAddressLevel3 = cscrmAddress.Sub_Address_Level_3_calc__c;
        string subAddressLevel4 = cscrmAddress.Sub_Address_Level_4_calc__c;
        string buildingName = cscrmAddress.cscrm__Building_Name__c;
        string street = cscrmAddress.Street_calc__c;
        string billingStreet = '';
        if(!string.isBlank(subAddressLevel1)){
            billingStreet = billingStreet + subAddressLevel1 + ' ';
        }
        if(!string.isBlank(subAddressLevel2)){
            billingStreet = billingStreet + subAddressLevel2 + ' ';
        }
        if(!string.isBlank(subAddressLevel3)){
            billingStreet = billingStreet + subAddressLevel3 + ' ';
        }
        if(!string.isBlank(subAddressLevel4)){
            billingStreet = billingStreet + subAddressLevel4 + ' ';
        }
        if(!string.isBlank(buildingName)){
            billingStreet = billingStreet + buildingName + ' ';
        }
        if(!string.isBlank(street)){
            billingStreet = billingStreet + street + ' ';
        }
        return billingStreet;
        
    }
    
    /****************************************************************************
@Method Name: sendChatterNotesOnPortCodeChange
@Author: SFO/Pallavi B
@Sprint :sprint 21.13 [DIGI-8909]
@CreateDate: 23/08/2021
@Description: To send Chatter notifications on change of portfolio code to Account Team members and user in old/new portfolio codes.
******************************************************************************/ 
    public static boolean stopRecursionOnChatterSent = false; 
    public static void sendChatterNotesOnPortCodeChange(Map<id, Account> oldAccountMap,List<Account> updatedAccounts){
        if(stopRecursionOnChatterSent == false){
            stopRecursionOnChatterSent = true;
            List<String> accPortfolioCodeLst1 = new List<String>();
            List<Account> accList = new List<Account>();
            Set<Id> accIdsLst = new Set<Id>();
            String chatterMessage ;
            C2O_ChatterUtil.ChatterFeedInfo feedInfo;
            List<C2O_ChatterUtil.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_ChatterUtil.ChatterFeedInfo>();
            try{  
                for(Account objAcc : updatedAccounts){ // START for loop of all Accounts to get Old and New Portfolio Codes. 
                    // new Portfolio Code is not equals to old Portfolio Code
                    Boolean ifPortfolioCodeChanged = (objAcc.Portfolio_Code__c!= oldAccountMap.get(objAcc.Id).Portfolio_Code__c);
                    if(ifPortfolioCodeChanged){
                        accIdsLst.add(objAcc.Id);
                        accPortfolioCodeLst1.add(objAcc.Portfolio_Code__c);
                        accPortfolioCodeLst1.add(oldAccountMap.get(objAcc.Id).Portfolio_Code__c);
                        accList.add(objAcc);
                    }
                } // END for loop of all Accounts to get Old and New Portfolio Codes. 
                
                if(accPortfolioCodeLst1.isEmpty()){ //If there is no change in portfolio code of account method exists.
                    return;
                }
                
                if(!accPortfolioCodeLst1.isEmpty()){
                    getRecipenetsByActRec(accIdsLst,accPortfolioCodeLst1); //Method to get list of users from Account Team Member and User2Territory
                }
                
                List<String> exceptionUserlist = filterRecipenetsByEmailIds(); 
                
                if(!accList.isEmpty()){
                    for(Account objAcc1 : accList){ // START for loop of PortfolioCodeChanged Accounts 
                        Set<Id> userIds = new Set<Id>();
                        Set<Id> exceptionuserIds = new Set<Id>();
                        chatterMessage = '  Account'+' '+objAcc1.Name +' '+ 'has moved from portfolio '+' '+ oldAccountMap.get(objAcc1.Id).Portfolio_Code__c +' '+ 'to portfolio '+ ' '+objAcc1.Portfolio_Code__c+ '.';
                        List<Id> chatterUserIds = new List<Id>();
                        
                        if(!mapOfActIdActTeamMemId.isEmpty() && mapOfActIdActTeamMemId.containsKey(objAcc1.Id)){
                            chatterUserIds.addAll(mapOfActIdActTeamMemId.get(objAcc1.Id));
                        }
                        // adding list of userIds of the mapOfPortCodeUserIds cotians userIds for the new port code
                        if(mapOfPortCodeUserIds.get(objAcc1.Portfolio_Code__c) <> null){
                            chatterUserIds.addAll(mapOfPortCodeUserIds.get(objAcc1.Portfolio_Code__c));
                        }
                        // adding list of userIds of the mapOfPortCodeUserIds cotians userIds for the old port code
                        if(mapOfPortCodeUserIds.get(oldAccountMap.get(objAcc1.Id).Portfolio_Code__c) <> null){
                            chatterUserIds.addAll(mapOfPortCodeUserIds.get(oldAccountMap.get(objAcc1.Id).Portfolio_Code__c));
                        }
                        
                        if(!chatterUserIds.isEmpty()){
                            for(Id Uid :chatterUserIds){
                                if(!exceptionUserlist.contains(Uid)){
                                    if(!userIds.contains(Uid)){
                                        feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(objAcc1.Id,new set<Id>{Uid},chatterMessage);
                                        userIds.add(Uid);
                                        if(feedInfo!=null){
                                            listOfchatterFeeds.add(feedInfo);
                                            
                                        } 
                                    }
                                }
                                
                            }
                        }
                    }// END for loop of PortfolioCodeChanged Accounts
                }
                if(!listOfchatterFeeds.isEmpty()){
                    system.enqueueJob(new C2O_ChatterUtil.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
                } 
            }catch(Exception Ex){
                system.debug('Exception:--->AccountTriggerHelper Class,method:: --> sendChatterNotesOnPortCodeChange'+ Ex.getMessage());
            }
        }
    }  
    /****************************************************************************
@Method Name: getRecipenetsByActRec
@Author: SFO/Pallavi B
@Sprint :sprint 21.13 [DIGI-8909]
@CreateDate: 23/08/2021
@Description: To get Account Team members and Old and new portoflio code users.
******************************************************************************/    
    public static void getRecipenetsByActRec(Set<Id> objAccountId,List<String> accPortfolioCodes){
        List<AccountTeamMember> lstmembers;
        if(!objAccountId.isEmpty()){
            lstmembers = SFO_TeamMemberUtil.getAccountTeamMembers(new set<id>(objAccountId),null);
        }
        if(!lstmembers.isEmpty()){
            for(AccountTeamMember atMem :lstmembers){
                
                if(!mapOfActIdActTeamMemId.isEmpty() && mapOfActIdActTeamMemId.containsKey(atMem.AccountId)){
                    mapOfActIdActTeamMemId.get(atMem.AccountId).add(atMem.UserId);
                }
                else{
                    mapOfActIdActTeamMemId.put(atMem.AccountId, new Set<Id>{atMem.UserId});
                }
            }
        }
        if(!accPortfolioCodes.isEmpty()){
            mapOfPortCodeUserIds = SFO_TerritoryUtil.getTerritoryUsers(accPortfolioCodes);
        }
        
    }
    /****************************************************************************
@Method Name: filterRecipenetsByEmailIds
@Author: SFO/Pallavi B
@Sprint :sprint 21.13 [DIGI-8909]
@CreateDate: 23/08/2021
@Description: To filter exception users from  Account Team members and Old and new portoflio code users.
******************************************************************************/       
    private static List<String> filterRecipenetsByEmailIds(){
        
        List<String> exceptionUserEmaillist = new List<String>();
        List<String> exceptionUserlist = new List<String>();
        List<FeatureToggle__mdt> exceptionUser = [SELECT Additional_Logic__c,Id FROM FeatureToggle__mdt where DeveloperName ='AccountNotificationProcessing' ];
        if(!exceptionUser.isEmpty()){
            for(FeatureToggle__mdt crs : exceptionUser){ 
                if(crs.Additional_Logic__c!=null && crs.Additional_Logic__c!=''){
                    exceptionUserEmaillist = crs.Additional_Logic__c.split(';');
                }
            }        
        }
        if(!exceptionUserEmaillist.isEmpty()){
            for(User userInfo: [Select id, email from user where email =:exceptionUserEmaillist]){
                exceptionUserlist.add(userInfo.Id);
            }
        }
        return exceptionUserlist;
    }
    
    /****************************************************************************
@Method Name: updateManualNoSellCreditHealth
@Author: SFO/Sri
@Sprint :sprint 21.13 [DIGI-15107]
@CreateDate: 22/09/2021
@Description: To update Credit Health when the Manual No Sell changed to true
******************************************************************************/       
    public static void updateManualNoSellCreditHealth(Map<id, Account> oldAccountMap, list<Account> newAccountList){
        id actEnterpriseRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(System.label.Account_RecordType_Enterprise).getRecordTypeId();
        boolean manualNoSellTrue; //flag to evaluate whether the Manual No Sell changed to true 
        boolean manualNoSellFalse; //flag to evaluate whether the Manual No Sell changed to false 
        
        for(Account act:newAccountList){ // START for loop of new accounts
            //if current account is not Enterprise skip to the next one 
            if(act.recordtypeId <> actEnterpriseRecordTypeId){
                continue;
			}
            
            //Manual No Sell changed to true && Credit Health is not high risk Credit Health	
            manualNoSellTrue = (act.Manual_No_Sell__c && act.Manual_No_Sell__c <> oldAccountMap.get(act.Id).Manual_No_Sell__c && act.Credit_Health__c <> 'High Risk' );
            //Manual No Sell changed to false
            manualNoSellFalse = (!act.Manual_No_Sell__c && act.Manual_No_Sell__c <> oldAccountMap.get(act.Id).Manual_No_Sell__c );
            
            if(manualNoSellTrue){
                act.Credit_Health__c = 'High Risk';
            }else if(manualNoSellFalse){
                act.Credit_Health__c = '';
                act.Reason_For_Manual_No_Sell__c = '';
            }
        } // END for loop of new accounts
    }
    
}
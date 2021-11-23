/*****************************************************************************
@Name: OpportunityTriggerHelper
@Author: SFO Team : Murali Nunna,subani 
@CreateDate: 09/08/2018
@Description: This Class has logic for checking the user permissions to create event records when 
Opportunity recoed is create/Edit AND To Restrict the opp Ownerchange for offshore opportunities for offshore roles.
@Last Modified      : 07/01/2020 21.01 by Sri, Team SFO
            as part of P2OB-9943/P2OB-6772 removing commented code,debug statements and updating API version to 50.
@Last Modified      : 
No.       Developer Name        Date            Story Description 
1.		  Gokul				09/03/2021	   EDGE-195270 - Bypass COntact Validations for CHown basket
2.        Shishir           20/04/2021     P2OB-13967 - <Cloudsense> <Proposal Builder> Display In progress message during proposal generation and subsequent success or failure notification
3.        Senthil/Srujana   11/05/2021     P2OB-13703 - <Cloudsense><Solution Console> Ability to edit Product Baskets when reopening a Closed Opportunity
4.        Pallavi B         05/04/2021     Sprint 21.05 - Revamp of Customer Risk Score Calculation
5.        Sri		        05/04/2021     Sprint 21.05 - Opportunity Reclassification
6.        Sri		        20/04/2021     Sprint 21.06 - Opportunity Reclassification
7.        Sravanthi         12/08/2021     Sprint 21.11 - Reopen Opportunities
8.        Sri               03/09/2021     Sprint 21.12 - DIGI:6047 send notification opportunity approver 
9.        Ramcharan			14/09/2021     Sprint 21.12 - DIGI-11006 101 issue on opportunity Sync (Opportunity Level(Revenue Section)-Revenue details are getting null)
10.       Sri               14/09/2021     Sprint 21.13 - DIGI-22590 adding space between mentioned user and chatter message 
11.       Sravanthi         20/09/2021     Sprint 21.13 - DIGI-17442  Sending Chatter notifications to opp and account owner reopened in the same month
12.       Sravanthi         01/11/2021     Sprint 21.15 - DIGI-24459  To send notifications for the approvers of close opportunity when partner submits for approval
*******************************************************************************/
public without sharing class OpportunityTriggerHelper {
    public static boolean isRecInsert = false;
    public static boolean isRecUpdate = false;
    public static boolean isOffShoreRestOpp=false;
    public static boolean isRecCustomerRiskScore=false;
    public static boolean isRecDefaultValues = false; // this is to ctrl the recurssion for defaultvalue method
    public static boolean isRecApproverNotification = false; // this is to ctrl the recurssion for defaultvalue method
    // changes start related to DIGI-11006
    public static boolean isSendCustomNotification=false;
    public static boolean isUpdateBasket = false;
    public static boolean isSetTypeForMigrationOnUpdate = false;
    // changes End related to DIGI-11006
    public static list<Opportunity_Stages_For_ContactRole__mdt> stages =  [SELECT MasterLabel,Current_Stage__c,Previous_Stage__c FROM Opportunity_Stages_For_ContactRole__mdt];
    public static Map<String,Decimal> fieldScoreValueMap = new Map<String,Decimal>();
    public static List<String> closedOppStages = new List<String>{'Closed Won' ,'Closed Lost', 'Cancelled'};

    private Id customRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Custom).getRecordTypeId();
    private Id standardRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Defined).getRecordTypeId();
    private Id macRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_MAC).getRecordTypeId();
    private Id transitionRecordTypeId  = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(System.label.Opp_RecordType_Transition).getRecordTypeId();

	private Map<Id,Opportunity> oldOppMap= new Map<Id,Opportunity>();
    
    public void onBeforeInsert(List<Opportunity> newOpps){
        Id profileId= userinfo.getProfileId();
        //P2OB-12121. Fix for autamated process
        List<Profile> profileName=[SELECT Id,Name FROM Profile WHERE Id=:profileId];
        String name = (!profileName.isEmpty())?profileName[0].name:null;
        Boolean isMigrationBOH = (name==Label.MigrationBOHUser) ? true:false;
        for(Opportunity opp : newOpps){
            opp.Storage_Requested_Date__c=DateTime.now();
            //EDGE-198050. Kalashree borgaonkar. Fix for Migration Profile
            setTypeForMigration(isMigrationBOH,opp);
            System.debug('opp: '+opp.type);
        }
    }
    //EDGE-198050. Kalashree borgaonkar. Fix for Migration Profile
    public void setTypeForMigration(Boolean isMigrationBOH,Opportunity opp){
        System.debug('isMigrationBOH: '+isMigrationBOH+ 'opp.type+  '+opp.type);
        if(isMigrationBOH == true && opp.type!='Migration'){
            opp.type='Migration';
        }
    }
    //EDGE-198050. Kalashree borgaonkar. Fix for Migration Profile
    public void setTypeForMigrationOnUpdate(Map<ID,Opportunity> newoppMap,Map<Id,Opportunity> oldOppMap){
    	if(isSetTypeForMigrationOnUpdate != True) { //added related DIGI-11006
	   isSetTypeForMigrationOnUpdate  = True ; //added related DIGI-11006
	        Id profileId= userinfo.getProfileId();
	        //P2OB-12121. Fix for autamated process
	        List<Profile> profileName=[SELECT Id,Name FROM Profile WHERE Id=:profileId];
	        if(!profileName.isEmpty()){
	             Boolean isMigrationBOH = (profileName[0].Name==Label.MigrationBOHUser) ? true:false;
	        if(isMigrationBOH==true){
	           for(String id : newoppMap.keyset()){
	               if(newoppMap.get(id).type!=oldOppMap.get(id).type && newoppMap.get(id).type!='Migration'){
	                   newoppMap.get(id).type = 'Migration';
	               } 
	           }
	        }
	        else{
	             for(String id : newoppMap.keyset()){
	               if(newoppMap.get(id).type!=oldOppMap.get(id).type && newoppMap.get(id).type=='Migration'){
	                   newoppMap.get(id).addError('Please choose opportunity type other than Migration');  
	               } 
	           }

	        }

	        }
        } //added related DIGI-11006
    }
    
    public void createSharePointEventOnOppCreation(List<Opportunity> newOpps){
        try{
            SharePointUtility spu=new SharePointUtility();
            //List<PermissionSetAssignment> psa=[SELECT PermissionSetId,PermissionSetId.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOpportunityCreate');//spu.checkUserHasCustomPermissionAccess('SharePointOpportunityCreate',UserInfo.getUserId());
            if(hasCustomPermissionSet==TRUE){
                list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
                set<ID> oppIdSet = new set<ID>();
                if(isRecInsert != True){
                    if(!newOpps.isEmpty() && newOpps.size()>0){
                        for(Opportunity op: newOpps){
                            oppIdSet.add(op.Id);
                        }
                    }
                    if(oppIdSet.Size()>0){
                        List<Opportunity> listOpps=[Select Id,Name,CIDN__c,Opportunity_Number__c,Archetype__c,LastModifiedDate,AccountId,Maxim_Sync_Indicator__c,Owner.Email,Account.LastModifiedDate,Account.Owner.FederationIdentifier,Account.Owner.Email,Account.Name,Account.Customer_ID__c,Owner.FederationIdentifier From Opportunity Where Id in : OppIdSet];
                        if(listOpps.size()>0){
                            for(Opportunity opp : listOpps){
                                if(opp.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True){
                                    SharePointMainPayload sopl=new SharePointMainPayload();
                                    SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunity',spu.getOpportunityPayload(opp));
                                    speList.add(spe);
                                }
                            }
                        }
                    }
                    if(!speList.isEmpty() && speList.size()>0){
                        insert speList;
                    }
                    isRecInsert = True;
                }
            }
        }catch(Exception Ex){
            system.debug('Exception:--->Opprtunity Trigger Handler Class,createSharePointEventOnOppCreation Method'+ Ex.getMessage());
        }
    }
    public void updateSharePointEventOnOppCreation(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps){
        try{
            SharePointUtility spu=new SharePointUtility();
            //List<PermissionSetAssignment> psa=[SELECT PermissionSetId,PermissionSetId.Name FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId()];
            boolean hasCustomPermissionSet=FeatureManagement.checkPermission('SharePointOpportunityChange');//spu.checkUserHasCustomPermissionAccess('SharePointOpportunityChange',UserInfo.getUserId());
            if(hasCustomPermissionSet==TRUE){
                list<SharePointEvent__c> speList = new list<SharePointEvent__c>();
                set<ID> oppNewIdSet = new set<ID>();
                set<ID> oppOldIdSet = new set<ID>();
                if(isRecUpdate != True){
                    if(!newMapOpps.isEmpty() && newMapOpps.size()>0){
                        oppNewIdSet=newMapOpps.Keyset();
                    }
                    if(!oldMapOpps.isEmpty() && oldMapOpps.size()>0){
                        oppOldIdSet=newMapOpps.Keyset();
                    }
                    if(oppNewIdSet.size()>0){
                        List<Opportunity> listOpps=[Select Id,Name,CIDN__c,Opportunity_Number__c,Archetype__c,LastModifiedDate,AccountId,Maxim_Sync_Indicator__c,Owner.FederationIdentifier,Owner.Email,Account.LastModifiedDate,Account.Owner.FederationIdentifier,Account.Owner.Email,Account.Name,Account.Customer_ID__c From Opportunity Where Id in : oppNewIdSet];
                        Map<id,Opportunity> newOplist=new Map<id,Opportunity>();
                        if(listOpps.size()>0){
                            for(Opportunity oop: listOpps){
                                newOplist.put(oop.id, oop);
                            }
                            for(Opportunity opp : listOpps){//newMapOpps.values()){
                                if(oldMapOpps.containsKey(opp.Id)){
                                    if((opp.Name!=oldMapOpps.get(opp.Id).Name ||opp.OwnerId!=oldMapOpps.get(opp.Id).OwnerId ||opp.Archetype__c !=oldMapOpps.get(opp.Id).Archetype__c )&&(opp.Maxim_Sync_Indicator__c=='Yes' && hasCustomPermissionSet==True)){
                                        SharePointMainPayload sopl=new SharePointMainPayload();                    
                                        SharePointEvent__c spe = spu.createSharePointEvent('SPOpportunity',spu.getOpportunityPayload(newOplist.get(opp.Id)));
                                        speList.add(spe);
                                        isRecUpdate = True;
                                    }
                                }
                            }
                        }
                    }
                    if(!speList.isEmpty() && speList.size()>0){
                        insert speList;
                    }                       
                }
            }
        }catch(Exception Ex){
            system.debug('Exception:--->Opprtunity Trigger Handler Class,updateSharePointEventOnOppCreation Method'+ Ex.getMessage());
        }
    }
    
    
    public void opprtunityValidationNoContactRoles(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps,List<Opportunity> newOpps){
        try{
            Boolean ischeckOppContactRole=TRUE;
            map<id,Boolean> oppConRoleError =new map<id,Boolean>();
            list<id> Opplist= new list<id>();
            list<id> OpplistMAC= new list<id>();
            map<String,String> stagesOppPrevious = new  map<String,String>();
            map<String,String> stagesOppCurrent = new  map<String,String>();
            for( Opportunity_Stages_For_ContactRole__mdt stage: Stages){
                stagesOppPrevious.put(stage.MasterLabel, stage.Previous_Stage__c);
                stagesOppCurrent.put(stage.MasterLabel, stage.Current_Stage__c);
            }
            list<string> previousStageForNonMAC = stagesOppPrevious.get('Stages for Non MAC').split(',');
            list<string> currentStageForNonMAC = stagesOppCurrent.get('Stages for Non MAC').split(',');
            list<string> previousStageForCustom = stagesOppPrevious.get('Stages For Custom').split(',');
            list<string> currentStageForCustom = stagesOppCurrent.get('Stages For Custom').split(',');
            list<string> previousStageForMAC = stagesOppPrevious.get('Stages For MAC').split(',');
            list<string> currentStageForMAC = stagesOppCurrent.get('Stages For MAC').split(',');
            if( !(FeatureManagement.checkPermission('Bypass_Contact_Role_Validation'))){
                if(!newMapOpps.isEmpty() && newMapOpps.size()>0){
                    if(!oldMapOpps.isEmpty() && oldMapOpps.size()>0){
                        if(newMapOpps.values().size()>0){
                            for(Opportunity opp : newMapOpps.values()){
                                 //EDGE-195270 -  Added If condition to bypass contact valdiation for CHown basket
                                if(!opp.isInsolvencyCancel__c && !opp.Type.containsIgnoreCase('CHOWN')){ //DIGI-24388 Added Insolvency check
                                    opportunity oldOppID = oldMapOpps.get(opp.ID);
                                    
                                    if(((opp.RecordTypeId == standardRecordTypeId) || (opp.RecordTypeId == transitionRecordTypeId)) && previousStageForNonMAC.contains(oldOppID.StageName)  && currentStageForNonMAC.contains(opp.StageName)){
                                        Opplist.add(opp.id);
                                    }
                                    else if((opp.RecordTypeId == customRecordTypeId) && previousStageForCustom.contains(oldOppID.StageName)  && currentStageForCustom.contains(opp.StageName)){
                                        Opplist.add(opp.id);
                                    }
                                    else if(opp.RecordTypeId == macRecordTypeId && previousStageForMAC.contains(oldOppID.StageName) && currentStageForMAC.contains(opp.StageName)){
                                        Opplist.add(opp.id);
                                    }
                                }
                            }
                            if(!Opplist.isEmpty()){
                                if(ischeckOppContactRole==TRUE){
                                    ischeckOppContactRole=FALSE;
                                    oppConRoleError =  checkOppContactRole(Opplist);
                                }
                            }
                            if(newOpps.size()>0 && newOpps!=null){
                                for(Opportunity oppThr : newOpps){
                                    if(!oppConRoleError.isEmpty() && oppConRoleError.size()>0){
                                        if(oppConRoleError.get(oppThr.id)==True){
                                            oppThr.addError(System.label.Opp_Contact_Role_Validation_Error);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpportunityTriggerHandler Class,opprtunityValidationNoContactRoles Method'+ Ex.getMessage());
        }
        
    }
    
    
    public static  map<id,Boolean> checkOppContactRole(list<id> opplist){
        map<id,Boolean> oppConRoleCount = new map<id,Boolean>();
        try{            
            if(opplist.size()>0){
                list<AggregateResult> contactRoleOpp = [SELECT COUNT(id),OpportunityId FROM OpportunityContactRole WHERE OpportunityId IN :opplist group by OpportunityId];
                If(!contactRoleOpp.isEmpty()){
                    for (AggregateResult ar : contactRoleOpp)  {
                        if((Integer)ar.get('expr0')==0){
                            oppConRoleCount.put((id)ar.get('OpportunityId'),True);
                        }
                        else{ 
                            oppConRoleCount.put((id)ar.get('OpportunityId'),False);
                        }
                    }}
                else{
                    for(id opp : opplist){
                        oppConRoleCount.put(opp,True);
                    }
                }
            }
            return oppConRoleCount;
        }
        catch(Exception Ex){
            system.debug('Exception:--->OpportunityTriggerHandler Class,checkOppContactRole Method'+ Ex.getMessage());
        }
        return oppConRoleCount;
    }
    
    /*
     *  Sprint 19.03 Edge-63675, SFO Team : Subani Shaik
     * This Method is to check whether new opportunity owner is a part of Enterprise OffShore Public group (EDGE-63675)
     **/
    public void offShoreRestrictedRolAndAccountCheckOnOpportunity(List<Opportunity> newOpp,Map<Id,Opportunity> oldMapOpps){
        if(!isOffShoreRestOpp){     
            List<Opportunity> newOpps=new List<Opportunity>();
            for(Opportunity Opp : newOpp){
                if(Opp.OwnerId!=oldMapOpps.get(Opp.Id).OwnerId){
                    newOpps.add(Opp);                        
                }
            }
            if(newOpps.size()>0){
                GroupMembership gm=new GroupMembership();
                gm.accountOffShoreCheckErrorMessage(newOpps,null);
            }
            isOffShoreRestOpp=TRUE;
        }
    }
    
/*******************************************************************
@Class Name         :   OpportunityTriggerHelper
@Sprint             :   20.08 & P2OB-6727 
@Author         	:   SFO Team (Amar Chakka) 
@CreateDate     	:   15-06-2020
@Description    	:   Calculation of Customer Risk Score. This Method will be called on Before Insert and on Before Update
@References     	:   Opportunity
@TestCoverage   	:   OpportunityTriggerHandlerTest Class, customerRiskScoreTest Method
@Last Modified Info :   21.05 & P2OB-11365/P2OB-13640 ::SFO(Pallavi B) :: Revamp of Customer Risk Score Calculation only in 
						Before Update on change of newlycreated field values.
*********************************************************************/
public void customerRiskScore (List<Opportunity> newOpps,Map<Id,Opportunity> newMapOpps,List<Opportunity> oldOpps,Map<Id,Opportunity> oldMapOpps){
    if(isRecCustomerRiskScore != True){
        isRecCustomerRiskScore = True;
            Decimal accountIndustryValue,contractTypeValue,expectedTCVRangeValue,primaryDomainValue,numberofSitesValue,numberofAdittionalDomains = 0;
            this.oldOppMap = oldMapOpps;
        try{
                Set<Id> accIds = new Set<Id>();
                for(Opportunity opps:newOpps){
                    if(opps.AccountId !=null){
                    	accIds.add(opps.AccountId); 
                    }
                }   
                Map<id,account> accsRecMap = new Map<id,account>([select id,Industry from account where id IN:accIds]);
                //Customer Risk Fields Values are mapped in Customer Risk Score Metadata Type. Hence Fetching mapped values through below query.
               List<Customer_Risk_Score__mdt> crslist = [SELECT CRS_Value_Map__c,CRS_Field_Values__c,DeveloperName,Id,Label,Language,MasterLabel,NamespacePrefix,QualifiedApiName FROM Customer_Risk_Score__mdt];
                for(Customer_Risk_Score__mdt crs : crslist){  // Storing Customer Risk Score Mapped Values in a Map
                    List<String> pointsbyvalue = crs.CRS_Field_Values__c!=null && crs.CRS_Field_Values__c!='' ? crs.CRS_Field_Values__c.split(';') : new List<String>{};
                        for(String fieldvalue : pointsbyvalue){
                            fieldScoreValueMap.put(fieldvalue,crs.CRS_Value_Map__c);
                        }
                }
            
            system.debug('fieldScoreValueMap'+fieldScoreValueMap);
            	Boolean mapEmptyCheck= (!accsRecMap.isEmpty() && !fieldScoreValueMap.isEmpty());
                for(Opportunity opp : newOpps){   // Start of For Loop and Calculating Customer Risk Score based on Customer Ris Assessment Fields on UI
                    Boolean recordTypeCheck = (opp.AccountId != null || opp.AccountId != '') && (opp.RecordTypeId == standardRecordTypeId || opp.RecordTypeId == customRecordTypeId || opp.RecordTypeId == macRecordTypeId);
                    Boolean Ischanged = True;
                    Ischanged =(isChanged('Contract_Type__c', opp)||
                                isChanged('Expected_TCV_Range__c', opp) ||
                                isChanged('Product_Domain__c', opp)||
                                isChanged('Number_of_Sites__c', opp) ||
                                isChanged('Number_of_Additional_Domains_if_any__c', opp));
                    if(recordTypeCheck && Ischanged){
                        contractTypeValue = getScoreValue(opp, 'Contract_Type__c');
                        expectedTCVRangeValue = getScoreValue(opp, 'Expected_TCV_Range__c');
                        primaryDomainValue = getScoreValue(opp, 'Product_Domain__c');
                        numberofSitesValue = getScoreValue(opp, 'Number_of_Sites__c');
                        numberofAdittionalDomains = getScoreValue(opp,'Number_of_Additional_Domains_if_any__c');
                        if( mapEmptyCheck && accsRecMap.get(opp.accountId).Industry != null ){
                            accountIndustryValue = fieldScoreValueMap.get(accsRecMap.get(opp.accountId).Industry);
                        }else if( mapEmptyCheck && !(fieldScoreValueMap.containsKey(accsRecMap.get(opp.accountId).Industry))){
                            accountIndustryValue = 1;
                        }
                        opp.Customer_Risk_Score__c = (contractTypeValue + expectedTCVRangeValue + primaryDomainValue + numberofSitesValue +numberofAdittionalDomains)* accountIndustryValue ;
                    }
                }
        }catch(Exception Ex){
             system.debug('Exception:--->OpportunityTriggerHelper Class,customerRiskScore'+ Ex.getMessage());
      }
    }
}
   
/*******************************************************************
@Description    : Method to check for change of fields that are used in Customer Risk Score Calcaulation .
@TestCoverage   : OpportunityTriggerHandlerTest Class, customerRiskScoreTest Method
@Author : SFO(Pallavi B) :: 21.05 & P2OB-11365/P2OB-13640
*********************************************************************/
private Decimal getScoreValue(Opportunity opp, String fieldAPIName){
    Decimal scoreValue = 0; // as default value is 0 for all other scenarios 
    String fieldValue = (String)opp.get(fieldAPIName);
    if(fieldValue != null && fieldScoreValueMap.containsKey(fieldValue) == true){
        scoreValue = fieldScoreValueMap.get(fieldValue);
    }
    return scoreValue;
}
/*-------------------------------------------------------- 
EDGE-186496
Method: updateOpportunityTypeRestrict
Description: Method to restrict user to update opportunity type
Author:Aishwarya
-------------------------------------------------------- */
    public void updateOpportunityTypeRestrict(List<Opportunity> newOpps){
        List<String> setOfProfiles = System.label.OppoProfileList.split(',');
        String migrationProfile = System.label.MigrationBOHUser;
        Id profileId= userinfo.getProfileId();
        String profileName=[SELECT Id,Name FROM Profile WHERE Id=:profileId].Name;
        system.debug('newMap'+newOpps);
        if(!newOpps.isEmpty()){
            for(Opportunity oppo :newOpps){
                system.debug('Profile Name'+profileName);
                /*if(!(oppo.Name).contains('MAC Solution')){ // EDGE-195821 Excluding the validation for MACD creation, as defaulting the opp type as Migration in ShowSolutionsOnMACButtonController.cls
                    if(profileName == migrationProfile && oppo.Type !='Migration' ){
                        oppo.addError('Please choose opportunity type Migration');                    
                    }
                }
                else*/ if(setOfProfiles.Contains(profileName) &&oppo.Type =='Migration' ){
                    oppo.addError('Please choose opportunity type other than Migration');  
                }
            }                                                                           
        }
    }   
    
    /*
    @Method Name: assignInCotractDefaultValuesOnCreate
    @Description: P2OB-13495, Sprint 21.05
				  To set InCotract Opportunity default values on create
    @Author		: Sri (Team SFO)
    */
    private void assignInCotractDefaultValuesOnCreate(Opportunity opp){
        system.debug('assignInCotractDefaultValuesOnCreate');
        opp.RecordTypeId = macRecordTypeId; 
        opp.Archetype__c = Label.Opportunity_Archetype_1;
        opp.Competitor__c = 'NO COMPETITOR';
        opp.Confidence_Level__c = 'Low probability/ Non Commit/ Red'; 
        opp.Contract_complexity__c = 'In Contract';
        opp.Contract_Type__c = 'Order Under Existing Contract';
        opp.In_Contract_MAC__c = 'Yes';
        //set Pricing_Method__c to 'PET' if opp is not a 'Modular' && 'Delegated Pricing' FIX for FDR TEST FAILURE
        if(!(opp.Product_Type__c == Label.Opp_ProductType_Modular && opp.Pricing_Method__c == 'Delegated Pricing')){
            opp.Pricing_Method__c = 'PET';
        }
        opp.Requires_Bid_Management__c = 'No';
        if(opp.stagename == Label.Opp_Stage_Define || opp.stagename == Label.Opp_Stage_Qualify )
            opp.stagename = 'Develop';
        else if(opp.stagename == Label.Opp_Stage_Price || opp.stagename == Label.Opp_Stage_Negotiate )
            opp.stagename = 'Propose';
    }
    
    /*
    @Method Name: assignStandardDefaultValuesOnCreate
    @Description: P2OB-13495, Sprint 21.05
				  To set Standard Opportunity default values on create
    @Author		: Sri (Team SFO)
    */
    private void assignStandardDefaultValuesOnCreate(Opportunity opp){
        system.debug('assignStandardDefaultValuesOnCreate');
        opp.RecordTypeId = standardRecordTypeId; 
        opp.Archetype__c = Label.Opportunity_Archetype_2;
        // opp.Contract_Type__c = 'BSA';
        if(opp.Pricing_Method__c !='Delegated Pricing'){
            opp.Contract_Type__c = 'BSA';
        }
        if(opp.Product_Type__c == Label.Opp_ProductType_NonModular){ 
            //if Product_Type is 'non modular'
            opp.Pricing_Method__c = 'PET';
        }
        else if(opp.Product_Type__c == Label.Opp_ProductType_Modular && opp.Pricing_Method__c != 'Delegated Pricing'){
            //if Product_Type is 'modular' and Pricing Method is not 'Delegated Pricing'
            opp.Pricing_Method__c = 'Off the Shelf';
        }
    }
    
    /*
    @Method Name: assignCustomDefaultValuesOnCreate
    @Description: P2OB-13495, Sprint 21.05
				  To set Custom Opportunity default values on create
    @Author		: Sri (Team SFO)
    */
    private void assignCustomDefaultValuesOnCreate(Opportunity opp){
        system.debug('assignCustomDefaultValuesOnCreate');
        opp.RecordTypeId = customRecordTypeId; 
        opp.Archetype__c = Label.Opportunity_Archetype_4;
        opp.Contract_Type__c = 'Master Service Agreement';
        opp.Pricing_Method__c = 'Complex';
        opp.proposal_Type__c = 'Large';
    }

    /*
    @Method Name: assignDefaultValuesOnCreate
    @Description: P2OB-13495, Sprint 21.05
				  To set Opportunity default values on create
    @Author		: Sri (Team SFO)
    */
    public void assignDefaultValuesOnCreate(List<Opportunity> newOpps){	
        try{
            for(Opportunity opp:newOpps){ // start for
                if(opp.stagename == Label.Opp_Stage_ClosedWon || opp.stagename == Label.Opp_Stage_ClosedLost || opp.stagename == Label.Opp_Stage_Cancelled){
                    break; //automation shouldn't run on an opp if it is closed 
                }
                assignValuesBasedOnSolComp_ModOpp(opp);
            } // end for
        }catch(Exception ex){
            System.debug('AssignDefaultValuesOnUpdate Exception '+ex.getMessage());
        }
    }

    /*
    @Method Name: assignSolutionComplexity
    @Description: P2OB-13495, Sprint 21.05
				  To set SolutionComplexity of a non-modular Opportunity based on some permutation
    @Author		: Sri (Team SFO)
    */
    private void assignSolutionComplexity(Opportunity opp){
			if(opp.Type == 'MACs (Moves, Adds & Change)' || opp.Type == 'Price Review'){
				opp.Billing_Solution__c = Label.Opp_SolComp_InCon;
				opp.RecordTypeId = macRecordTypeId;
			}
			else if(opp.Contract_Type__c == 'Master Service Agreement' || opp.Number_of_Additional_Domains_if_any__c == '3 or More' || ((opp.Number_of_Additional_Domains_if_any__c == '1' || opp.Number_of_Additional_Domains_if_any__c == '2') && (opp.Will_this_require_integration__c == 'Yes'))){
				opp.Billing_Solution__c = Label.Opp_SolComp_NonStand;
				opp.RecordTypeId = customRecordTypeId;
			}
			else {
				opp.Billing_Solution__c = Label.Opp_SolComp_Stand;
				opp.RecordTypeId = standardRecordTypeId;
			}
	}

    /*
    @Method Name: updateArcheType
    @Description: P2OB-13495, Sprint 21.05
				  To set Archetype__c while on update of Expected_TCV_Range__c/Amount/Number_of_Additional_Domains_if_any__c/Domain__c
    @Author		: Sri (Team SFO)
    */
	private void updateArcheType(Opportunity opp){
			if(opp.Billing_Solution__c == Label.Opp_SolComp_Stand){
                if((opp.Number_of_Additional_Domains_if_any__c  == null || opp.Number_of_Additional_Domains_if_any__c  == '0') && opp.Domain__c == 'Single') {
					opp.Archetype__c = Label.Opportunity_Archetype_2;
                } 
                else {
					opp.Archetype__c = Label.Opportunity_Archetype_3;
                }
                if(opp.Product_Count__c <> 0 && opp.Archetype__c == Label.Opportunity_Archetype_3){
                    opp.Domain__c = 'Multi';
                }
            }
			else if(opp.Billing_Solution__c == Label.Opp_SolComp_NonStand){
                if(opp.Expected_TCV_Range__c == '$50 million or greater' || opp.Amount >= 50000000){
					opp.Archetype__c = Label.Opportunity_Archetype_5;
                }
                else {
					opp.Archetype__c = Label.Opportunity_Archetype_4;
                }
			}
		
	}
    
    /*
    @Method Name: assignValuesBasedOnSolComp_NonModOpp
    @Description: P2OB-13495, Sprint 21.05
				  To set dependent Opportunity fields on updated SolutionComplexity for non-modular Opportunities
    @Author		: Sri (Team SFO)
    */
	private void assignValuesBasedOnSolComp_NonModOpp(Opportunity opp){
			if(opp.Billing_Solution__c == Label.Opp_SolComp_Stand){
                opp.RecordTypeId = standardRecordTypeId;
                opp.Pricing_Method__c = 'PET';
                updateArcheType(opp);
			}
			else if(opp.Billing_Solution__c == Label.Opp_SolComp_NonStand){
                opp.RecordTypeId = customRecordTypeId;
                opp.Pricing_Method__c = 'Complex';
                opp.proposal_Type__c = 'Large';
                updateArcheType(opp);
			}
			else if(opp.Billing_Solution__c == Label.Opp_SolComp_InCon){
                opp.RecordTypeId = macRecordTypeId; 
                opp.Archetype__c = Label.Opportunity_Archetype_1;
                opp.Competitor__c = 'NO COMPETITOR';
                opp.Contract_complexity__c = 'In Contract';
                opp.In_Contract_MAC__c = 'Yes';
                opp.Pricing_Method__c = 'PET';
                opp.Requires_Bid_Management__c = 'No';
                if(opp.stagename == Label.Opp_Stage_Define || opp.stagename == Label.Opp_Stage_Qualify )
                    opp.stagename = 'Develop';
                else if(opp.stagename == Label.Opp_Stage_Price || opp.stagename == Label.Opp_Stage_Negotiate )
                    opp.stagename = 'Propose';
			}
	}

    /*
    @Method Name: assignValuesBasedOnSolComp_ModOpp
    @Description: P2OB-13495, Sprint 21.05
				  To set dependent Opportunity fields on updated SolutionComplexity for modular Opportunities
    @Author		: Sri (Team SFO)
    */
	private void assignValuesBasedOnSolComp_ModOpp(Opportunity opp){
			if(opp.Billing_Solution__c == Label.Opp_SolComp_Stand){
                assignStandardDefaultValuesOnCreate(opp);
			}
			else if(opp.Billing_Solution__c == Label.Opp_SolComp_NonStand){
                assignCustomDefaultValuesOnCreate(opp);
			}
			else if(opp.Billing_Solution__c == Label.Opp_SolComp_InCon){
                assignInCotractDefaultValuesOnCreate(opp);
			}
		
	}

    /*
    @Method Name: isChanged
    @Description: P2OB-13495, Sprint 21.05
				  To check whether the field on record updated or not on record update.
    @Author		: Sri (Team SFO)
    */
    private boolean isChanged(String fieldApiName, Opportunity opp){
        return opp?.get(fieldApiName) != oldOppMap.get(opp.Id)?.get(fieldApiName);
    }

    /*
    @Method Name: assignDefaultValuesOnUpdate
    @Description: P2OB-13495, Sprint 21.05
				  To set Opportunity default values on update
    @Author		: Sri (Team SFO)
    */
    public void assignDefaultValuesOnUpdate(List<Opportunity> newOpps, Map<Id,Opportunity> oppOldMap){
        boolean isUpdateSolComp; 
        boolean isUpdateArcheType;  
        this.oldOppMap = oppOldMap;
        try{
            if(isRecDefaultValues){
                return ; //to avoid recurssion
            }
            isRecDefaultValues = True;
            for(Opportunity opp:newOpps){ //start for
                
				// START P2OB-13687, Sprint 21.09 To update confidence level when the opp closed won
                if(isChanged('stagename', opp) && opp.stagename == Label.Opp_Stage_ClosedWon){
                    opp.Confidence_Level__c = 'Commit/ Green'; 
                }
                // END P2OB-13687, Sprint 21.09
                
                if(opp.stagename == Label.Opp_Stage_ClosedWon || opp.stagename == Label.Opp_Stage_ClosedLost || opp.stagename == Label.Opp_Stage_Cancelled){
                    break; //automation shouldn't run on an opp if it is closed or cancelled
                }
                //to check whether the solution complexity need to be re-caluclated or not for NonModular & NonPartner opps
                isUpdateSolComp = ((opp.Product_Type__c == Label.Opp_ProductType_NonModular && opp.Owner.UserType != 'PowerPartner') && 
                                   (isChanged('Contract_Type__c', opp) || isChanged('Number_of_Additional_Domains_if_any__c', opp) || isChanged('Type', opp) || isChanged('Will_this_require_integration__c', opp)));
                if(isUpdateSolComp){
                    assignSolutionComplexity(opp); //update the solution complexity based on the permutation for NonModular & NonPartner opps
                }
                //to check whether the ArcheType need to be re-caluclated or not for NonModular & NonPartner opps
                isUpdateArcheType = ((opp.Product_Type__c == Label.Opp_ProductType_NonModular  && opp.Owner.UserType != 'PowerPartner') && 
                                     (isChanged('Expected_TCV_Range__c', opp) || isChanged('Number_of_Additional_Domains_if_any__c', opp) || isChanged('Domain__c', opp) || isChanged('Amount', opp)));
                if(isChanged('Billing_Solution__c', opp) && ((opp.Product_Type__c == Label.Opp_ProductType_NonModular && opp.Owner.UserType != 'PowerPartner'))){
                    assignValuesBasedOnSolComp_NonModOpp(opp); //update the default values(along with archetype) based solution complexity for NonModular & NonPartner opps
                } 
                else if(isUpdateArcheType){
                    updateArcheType(opp); //update the archetype based solution complexity for NonModular & NonPartner opps
                }
                else if(isChanged('Billing_Solution__c', opp) && ((opp.Product_Type__c == Label.Opp_ProductType_Modular) || (opp.Owner.UserType == 'PowerPartner'))){
                    assignValuesBasedOnSolComp_ModOpp(opp); //update the archetype based solution complexity for Modular & Partner opps
                }
            }// end for
        }catch(Exception ex){
            System.debug('AssignDefaultValuesOnUpdate Exception '+ex.getMessage());
        }
    }

    //P2OB-13967 changes start
    public static List<Opportunity> sendCustomNotification(List<Opportunity> newOpportunity, Map<Id,Opportunity> oldMap) {
	if(isSendCustomNotification != True) { //added related DIGI-11006
		isSendCustomNotification = True ;  //added related DIGI-11006
	        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
	       											   FROM CustomNotificationType 
	             									   WHERE DeveloperName='Proposal_Generation_Complete'];
	        for(Opportunity opp : newOpportunity) {
	            System.debug('Opp1' + opp.SharePoint_Sync__c);
	            if(opp.SharePoint_Sync__c != null && opp.SharePoint_Sync__c != '' 
	               && opp.SharePoint_Sync__c != oldMap.get(opp.Id).SharePoint_Sync__c) {
	               System.debug('Opp' + opp.SharePoint_Sync__c);
	               if(opp.SharePoint_Sync__c == 'Complete') {
	               		CustomNotificationFromApex.sendNotifications(notificationType, opp, opp.Name, Label.Proposal_Generation_Success);
	                   	opp.Proposal_Requested_User__c = null;
	               } else if(opp.SharePoint_Sync__c == 'Error') {
	                    CustomNotificationFromApex.sendNotifications(notificationType, opp, opp.Name, Label.Proposal_Generation_Error);
	               }
	            }
	        } 
      	} //added related DIGI-11006
        return newOpportunity;
    }
    //P2OB-13967 Changes End
   
    //P2OB-13703 changes Start
    public static void updateBasket(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps)
    {
  	if(isUpdateBasket != True) {  //added related DIGI-11006
		isUpdateBasket = True ;     //added related DIGI-11006   
	        Set<ID> newOppId = new Set<ID>();
			for(Opportunity newOpp : newMapOpps.values())
	        {
	            if(newOpp.Product_Type__c == 'Non Modular')
	            { 
	                Opportunity oldOpp = oldMapOpps.get(newOpp.Id);
	                    if(oldOpp.StageName == 'Closed Won' || oldOpp.StageName == 'Closed Lost')
	                {
	                    newOppId.add(newOpp.Id);
	                }
	            }
	        }
	        List<cscfga__Product_Basket__c> productBasketList = [Select Id,cscfga__Basket_Status__c,csordtelcoa__Basket_Stage__c from cscfga__Product_Basket__c Where cscfga__Opportunity__c =:newOppId];
	        List<cscfga__Product_Basket__c> updateProductBasketList = new List<cscfga__Product_Basket__c>();
	        for (cscfga__Product_Basket__c productBasket: productBasketList)
	        {	
	            if(productBasket.cscfga__Basket_Status__c == 'Valid')
	            {
	               productBasket.csordtelcoa__Basket_Stage__c = 'Commercial Configuration';
	               updateProductBasketList.add(productBasket); 
	            }
            
	        }
	        update updateProductBasketList;
	} //added related DIGI-11006
    }
    //P2OB-13703 changes End
    //DIGI:4646 START
    /*
    @Method Name: setReopenValues
    @Description: DIGI-4646, Sprint 21.11
   				 To Set Reopened_Date__c,Original_Closed_Date__c when reopened and CloseDate value when reclosing opps
    @Author		: Sravanthi/Sri (Team SFO)
    */
    public void setReopenValues(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps){
        try{
                for(Opportunity opp : newMapOpps.values()){
                    if(!closedOppStages.contains(opp.StageName) && !oldMapOpps.isEmpty() &&(oldMapOpps.get(opp.id) != null && closedOppStages.contains(oldMapOpps.get(opp.id).StageName)) && opp.Product_Type__c != Label.Opp_ProductType_Modular && opp.Owner.UserType != 'PowerPartner'){
                        opp.Reopened_Date__c = System.today();
                        opp.Original_Closed_Date__c = oldMapOpps.get(opp.id).CloseDate;
                    }
                    else if (closedOppStages.contains(opp.StageName) && !oldMapOpps.isEmpty() && (oldMapOpps.get(opp.id) != null && !closedOppStages.contains(oldMapOpps.get(opp.id).StageName)) && opp.Original_Closed_Date__c != null && opp.Product_Type__c != Label.Opp_ProductType_Modular && opp.Owner.UserType != 'PowerPartner'){
                        opp.CloseDate=opp.Original_Closed_Date__c;
                    }
                }
        }
        catch(Exception ex){
            System.debug('setReopenValues Exception '+ex.getMessage());
        }
    }
    
    /*
    @Method Name: sendChatterToRequestor
    @Description: DIGI-4646, Sprint 21.11,DIGI-17442, Sprint 21.13
   				 To Send chatter notifications to approval requestor once reopen approval request gets approved.
				 To Send chatter notifications to opp owner and acc owner for reopen opp.
    @Author		: Sravanthi/Sri (Team SFO)
    */
    public void sendChatterToRequestor(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps){
        try{
            List<id> accIdList = new List<id>();
            List<Opportunity> oppList = new List<Opportunity>();
            List<FeedItem> feedItemsList = new List<FeedItem>();
            List<String> approvalStatuses = new List<String>{'Approved','Rejected'};
            String chatterBodyApproved;    
            String chatterBodyRejected;
            String chatterBodyNonOwner;
            String reopenReason ='';
            Map<ID, Account> newOppaccMap;
            
            //START For Loop
            for(Opportunity oppnew : newMapOpps.values()){
                //Close date is not in the current month
                if(oppnew.Approval_Status__c != oldMapOpps.get(oppnew.id).Approval_Status__c 
                   && approvalStatuses.contains(oppnew.Approval_Status__c)  
                   && oppnew.Product_Type__c != Label.Opp_ProductType_Modular 
                   && oppnew.Owner.UserType != 'PowerPartner' 
                   && oppnew.Approval_Requestor__c != null){
                    oppList.add(oppnew);
                    accIdList.add(oppnew.accountId);
                }
                //DIGI-17442 reopen opps previous stage is closed , present stage is non closed stage.
                else if(!closedOppStages.contains(oppnew.StageName) 
                        && !oldMapOpps.isEmpty() 
                        &&(oldMapOpps.get(oppnew.id) != null 
                        && closedOppStages.contains(oldMapOpps.get(oppnew.id).StageName)) 
                        && oppnew.Product_Type__c != Label.Opp_ProductType_Modular 
                        && oppnew.Owner.UserType != 'PowerPartner'
                        && oppnew.CloseDate.month() == System.today().month()){
                    oppList.add(oppnew);
                    accIdList.add(oppnew.accountId);
                }
            }
            //END For Loop
            if(!accIdList.isEmpty()) {
                newOppaccMap = new Map<ID, Account>([SELECT Id, OwnerId FROM Account WHERE id in :accIdList ]);
            }
            //START For Loop
            for(Opportunity opp :oppList){
                if(opp.Approval_Status__c == 'Approved' && opp.Approval_Requestor__c != null){
                    chatterBodyApproved=     'The request to re-open opportunity '+ opp.Name +' has been approved by '+userinfo.getName() +'. Please ensure the opportunity is closed as soon as possible.';
                    
                    feedItemsList.add(new FeedItem(parentId=opp.Approval_Requestor__c,Body=chatterBodyApproved,Type='TextPost',Title='Approved'));
                }
                else if(opp.Approval_Status__c == 'Rejected'&& opp.Approval_Requestor__c != null){
                    chatterBodyRejected=     'The request to re-open opportunity '+ opp.Name +' has been rejected  by '+userinfo.getName() +'.';
                    
                    feedItemsList.add(new FeedItem(parentId=opp.Approval_Requestor__c,Body=chatterBodyRejected,Type='TextPost',Title='Rejected'));
                }
                
                if(opp.Reopened_reason__c != null){
                    reopenReason =opp.Reopened_reason__c;
                }
                else{
                    reopenReason='';
                }
                chatterBodyNonOwner=  'Opportunity '+opp.Name+' has been re-opened. The reason for re-opening the opportunity is -'+ reopenReason+' .';
                if(!newOppaccMap.isEmpty() && newOppaccMap.containsKey(opp.AccountId) && newOppaccMap.get(opp.AccountId) != null){
                    ID accOwnerId=newOppaccMap.get(opp.AccountId).OwnerId;
                    if(opp.Approval_Status__c == 'Approved' 
                       && opp.Approval_Requestor__c != null 
                       && (opp.Approval_Requestor__c != opp.OwnerId 
                           || (opp.Approval_Requestor__c !=accOwnerId))){
                        feedItemsList.addAll(reopenChatterNotifs(opp.Approval_Requestor__c,opp.OwnerId,accOwnerId,chatterBodyNonOwner));
                    }
                    // DIGI-17442 Chatter on reopen to opp/acc owner when close date in same month as today
                    else if(opp.CloseDate.month() == System.today().month() 
                            && !closedOppStages.contains(opp.StageName) 
                            && !oldMapOpps.isEmpty() 
                            && (oldMapOpps.get(opp.id) != null 
                                && closedOppStages.contains(oldMapOpps.get(opp.id).StageName)) 
                            && opp.Product_Type__c != Label.Opp_ProductType_Modular 
                            && opp.Owner.UserType != 'PowerPartner' ){
                        
                        feedItemsList.addAll(reopenChatterNotifs(userinfo.getUserId(),opp.OwnerId,accOwnerId,chatterBodyNonOwner));                       
                        
                    }
                }
            }
			//END For Loop
            if(!feedItemsList.isEmpty()){
                insert feedItemsList;
            }
        }
        catch(Exception ex){
            System.debug('sendChatterToRequestor Exception '+ex.getMessage());
        }
    }
    //DIGI:4646 END
    /*
    @Method Name: reopenChatterNotifs
    @Description: DIGI-17442, Sprint 21.13
   				 To Send chatter notifications to opp owner and acc owner for reopen opp.
    @Author		: Sravanthi (Team SFO)
    */
     public static List<FeedItem> reopenChatterNotifs(String userID , String oppOwnerID , String accOwnerID,String chatterBody) {
        List<FeedItem> feedItemsList = new List<FeedItem>();

        if(userID != oppOwnerID &&  userID !=accOwnerID){
            feedItemsList.add(new FeedItem(parentId=oppOwnerID,Body=chatterBody,Type='TextPost',Title='Reopen Opportunity'));
            feedItemsList.add(new FeedItem(parentId=accOwnerID,Body=chatterBody,Type='TextPost',Title='Reopen Opportunity'));
        }
        else if(userID != oppOwnerID &&  userID ==accOwnerID){
            feedItemsList.add(new FeedItem(parentId=oppOwnerID,Body=chatterBody,Type='TextPost',Title='Reopen Opportunity'));
        }
        else if(userID == oppOwnerID && userID !=accOwnerID){
            feedItemsList.add(new FeedItem(parentId=accOwnerID,Body=chatterBody,Type='TextPost',Title='Reopen Opportunity'));
        }
         return feedItemsList;
    }


    /*
    @Method Name: sendNotificationToOppAppr
    @Description: DIGI-6047, Sprint 21.12
				  To send notifications for the given opportunity related account team member with the Opportunity Approver role 
    @Author		: Sri (Team SFO)
    @modified   : DIGI-6047, Sprint 21.13 Only account team members(Opportunity Approver) should be notified with the chatter , not the account owner.
    */
    public  void sendNotificationToOppAppr(List<Opportunity> newOpps) {
        if(isRecApproverNotification){
            return ;//to avoid recurssion
        }
        isRecApproverNotification = true;
        Map<Id,Id> mapOfOppIdAccId = new Map<Id,Id>(); // contains OpportunityId and AccountId
        Map<Id,Account> mapOfAccIdAccRec ; // contains AccountId and Account record
        Map<Id,AccountTeamMember> mapOfAccIdAccTeamMem = new Map<Id,AccountTeamMember>(); // contains AccountId and AccountTeamMember record
        Map<Id,Opportunity> mapOfOppIdOppRec = new Map<Id,Opportunity>(); // contains OpportunityId and Opportunity record
        
        String role = Label.ClosureApproverAccountTeamMemRole;
        C2O_ChatterUtil.ChatterFeedInfo feedInfo;
        List<C2O_ChatterUtil.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_ChatterUtil.ChatterFeedInfo>();
        
        //loop through the list of new opportunities to keep partner opportunities in a map by oppId
        //keep account and opportunity Ids in a map 
        for(Opportunity opp:newOpps){ // START for loop of Opportunities
            // If Partner Opportunity is Approved and have an Account  
            if(opp.AccountId != null && opp.Partner_Opportunity_Verification__c == 'Approved' && opp.Opportunity_Source__c == 'Partner'){
                mapOfOppIdOppRec.put(opp.Id,opp);
                mapOfOppIdAccId.put(opp.Id,opp.AccountId);
            }
        } // END for loop of Opportunities
        
        //query Accounts and keep them in a map to get by using its accountId
        mapOfAccIdAccRec = new Map<Id,Account>([select id,name,ownerId,owner.name from account where id =:mapOfOppIdAccId.values()]);
        
        //query AccountTeamMembers, for opp realted accounts and keep them in a map by using accountId
        for(AccountTeamMember atMem:SFO_TeamMemberUtil.getAccountTeamMembers(new set<id>(mapOfOppIdAccId.values()),role)){
            system.debug(':::  AccountTeamMember ::: ');
            mapOfAccIdAccTeamMem.put(atMem.AccountId, atMem);
        }
        
        String chatterMsg = ' Dear <OppAprName>, A Partner user of Account <ParActName> has created a new Opportunity belonging to <CusActName> with the value of <TCV>. ';
        AccountTeamMember accTeamMember; // contains AccountTeamMember who is having a mentioned role for the current opp realted account
        Account acc; // contains Account information for the current opp
        
        for(Opportunity opp:mapOfOppIdOppRec.values()){
            accTeamMember = mapOfAccIdAccTeamMem.get(opp.accountId); 
            acc = mapOfAccIdAccRec.get(opp.accountId);
            
            if(opp.Partner_Account_Name__c != null){ // if Partner_Account_Name__c is there repalce with it, if not repalce with empty string
	            chatterMsg = chatterMsg.replace('<ParActName>', opp.Partner_Account_Name__c);
            }else{
	            chatterMsg = chatterMsg.replace('<ParActName>', ' ');
            }
            
            if(acc?.Name != null){ // if Account Name is there repalce with it, if not repalce with empty string
	            chatterMsg = chatterMsg.replace('<CusActName>', acc?.Name);
            }else{
	            chatterMsg = chatterMsg.replace('<CusActName>', ' ');
            }
            
            if(opp.Amount != null){// if Amount is there repalce with it, if not repalce with empty string
	            chatterMsg = chatterMsg.replace('<TCV>', opp.Amount?.toPlainString());
            }else{
	            chatterMsg = chatterMsg.replace('<TCV>', ' ');
            }
            
            if(accTeamMember <> null ){
                //if there is a accTeamMember with the mentioned role send chatter to the same accTeamMember
                chatterMsg =  chatterMsg.replace('<OppAprName>', accTeamMember.user.name);
                feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(opp.id, new set<Id>{accTeamMember.userId}, chatterMsg);
            }
            if(feedInfo <> null){
                listOfchatterFeeds.add(feedInfo);
            }
        }
        
        if (!listOfchatterFeeds.isEmpty() ) {
            System.enqueueJob(new C2O_ChatterUtil.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
        }
    }

    /*
    @Method Name: sendNotificationToPartnerOppCurrentAppr
    @Description: DIGI-24459, Sprint 21.15
				  To send notifications for the approvers of close opportunity when partner submits for approval
    @Author		: Sravanthi (Team SFO)
    */
	private boolean isRecApproverNotificationPartnerOpp = false;
    public  void sendNotificationToPartnerOppCurrentAppr(Map<Id,Opportunity> newMapOpps,Map<Id,Opportunity> oldMapOpps) {
        if(isRecApproverNotificationPartnerOpp){
            return ;//to avoid recurssion
        }
        isRecApproverNotificationPartnerOpp = true;
        
        List<C2O_ChatterUtil.ChatterFeedInfo> listOfchatterFeeds = new List<C2O_ChatterUtil.ChatterFeedInfo>();
        C2O_ChatterUtil.ChatterFeedInfo feedInfo;
        
        String chatterMsg =System.label.PartnerClosureApprovalChatter;
        for(Opportunity opp : newMapOpps.values()){
            // Current_Approver_ID__c gets updated in the closure approval process 1of opportunity with distributor contact / closure approver.
            if(oldMapOpps.containsKey(opp.id) && opp.Current_Approver_ID__c != null && opp.Current_Approver_ID__c !=oldMapOpps.get(opp.id).Current_Approver_ID__c ){
             chatterMsg = chatterMsg.replace('OppName', opp?.Name); // Replacing Opp Name
             feedInfo = new C2O_ChatterUtil.ChatterFeedInfo(opp.id, new set<Id>{opp.Current_Approver_ID__c}, chatterMsg);
            }
            if(feedInfo <> null){
                listOfchatterFeeds.add(feedInfo);
            }
        }
        
        if (!listOfchatterFeeds.isEmpty() ) {
            System.enqueueJob(new C2O_ChatterUtil.InvokeBulkChatterFeedQueueable(listOfchatterFeeds));
        }
    }
}
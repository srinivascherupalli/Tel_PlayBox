/*
AUTHOR : Ravi Teja Komatineni
DESCRIPTION : This class handles the Business Process for filtering the partner list based on business rules for Submitting Opportunity to Partner
Date:08-03-2019
US:EDGE-67568,EDGE-63627 OLD
Date: 09-May-2019 sprint 19.06
US: EDGE-81324, EDGE-81336

Version     Author                         Last Modified Date      Description
v1.1        Vivian Charlie (Team Hawaii)     26 Aug 2019           Updated rules for incumbent partners to include partners tagged on OpportunityLineItems

v1.2        Vivian Charlie (Team Hawaii)     09 Dec 2019           P2OB-2448 : Incumbency to show Primary Distributor for non onboarded Nominates, Opportunity will then be shared with Primary Distributor
EDGE-96585  Bhargava                            23 JAN 2020        Added Warning message for Closed Won/Closed Lost Opportunity
v1.3        Vivian Charlie (Team Hawaii)     28 Jan 2020           P2OB-4628 : Opportunity Optimization
            Megha (Team Hawaii)              13-Feb-2020           P2OB-4628 : Opportunity Optimization (Custom setting issue Fixes)
v1.4        Vivian Charlie (Team Hawaii)     28 Jan 2020           P2OB-4868 : Opportunity Optimization Updates
v1.5        Vivian Charlie (Team Hawaii)     11 Mar 2020           P2OB-4736 : Do not allow opportunity reshare
v1.6        Vivian Charlie (Team Hawaii)     06 Apr 2020           P2OB-5227 : Display appropriate submit message for non onboarded partner
v1.7        Vivian Charlie (Team Hawaii)     11 May 2020           P2OB-5503 : Display Partners with all Accreditation level for recommended partners
v1.8        RaviTeja                         14 Jul 2020           EDGE-151598: As an AE/CE, I want to view POR info when sharing the Opportunity with Partner
v1.9        Vivian Charlie (Team Hawaii)     15 Sep 2020           P2OB-8752 only consider closed opportunities for incumbency
v2.0        Vivian Charlie (Team Hawaii)     22 Sep 2020           P2OB-6722 Prevent opportunity share if owner is inactive
v2.1        Vivian Charlie (Team Hawaii)     01 Oct 2020           P2OB-8725 prevent soql injection using escapeSingleQuotes
v2.2        Vivian Charlie (Team Hawaii)     30 Oct 2020           P2OB-6781 : Domain mapping changes
*/

public with sharing class PRMSubmitToPartnerRules {

    public class WrapperPageData {
        @auraEnabled public PartnerResults[] PartnerResultsInc;
        @auraEnabled public PartnerResults[] PartnerResultsRec;
        @auraEnabled public PartnerResults[] PartnerResultsPOR; //EDGE-151598
        //EDGE-96585 Bhargava added method to get the Opportunity Stage
        @auraEnabled public String GetOpptyStatus;
        @auraEnabled public String GetSubmitToPartnerStatus; // v1.5
        @auraEnabled public String GetPartnerName; // v1.5
        @auraEnabled public String GetPartnerOwnerId; // v1.5
        @auraEnabled public String GetRecTypeId; // v1.5
        @auraEnabled public Boolean GetOwnerActive;// v2.0
    }
    
    @auraEnabled
    public static WrapperPageData init(String OpptyID) {
            WrapperPageData pageData = new WrapperPageData();
            Logger2 logger = Logger2.getLogger('PRMSubmitToPartnerRules.Init');
            pageData.PartnerResultsInc = findIncumbentPartners(OpptyID);
            pageData.PartnerResultsRec = findRecommedation(OpptyID);
            pageData.PartnerResultsPOR=findPartnerOfRecords(OpptyID); //EDGE-151598
            //EDGE-96585 Called method to get the opportunity Stage;
            Opportunity oppInstance = findOpptyStatus(OpptyID); // v1.5  
            pageData.GetOpptyStatus = oppInstance.StageName; // v1.5
            pageData.GetSubmitToPartnerStatus = oppInstance.SubmittoPartnerStatus__c; // v1.5
            // v1.5 If Opportunity is created by Partner set the created by Account as Partner Name else set Partner Account
            if(oppInstance.CreatedBy.ContactId != null){
                pageData.GetPartnerOwnerId = oppInstance.CreatedBy.ContactId;
                pageData.GetPartnerName = oppInstance.CreatedBy.Contact.Account.Name;
            }else if(oppInstance.PartnerAccount != null){
                pageData.GetPartnerName = oppInstance.PartnerAccount.Name; // v1.5
            }
            pageData.GetOwnerActive = oppInstance.Owner.isActive; // v2.0
            
            pageData.GetRecTypeId= oppInstance.RecordtypeId; // v1.5
            set<id> incumidset= new set<id>();
            set<id> recumidset= new set<id>();

        try{
            Opportunity Opp= new Opportunity();
            Opp.id=OpptyID;
            Opp.Incumbent_Partner__c=PRMConstants.PRM_SUBMIT_TO_PARTNER_NO_INCOMBENT ;
            Opp.RecommendedPartner__c=PRMConstants.PRM_SUBMIT_TO_PARTNER_NO_RECOMMENDED;

            if(pageData.PartnerResultsInc.size()>0){
                    Opp.Incumbent_Partner__c=pageData.PartnerResultsInc[0].accountName;
                    }

            if(pageData.PartnerResultsRec.size()>0){
                    Opp.RecommendedPartner__c=pageData.PartnerResultsRec[0].accountName;
            }

            Update opp;
            system.debug('pageData.PartnerResultsInc'+pageData.PartnerResultsInc.size());
            system.debug('pageData.PartnerResultsRec'+pageData.PartnerResultsRec.size());


           /*
            for(PartnerResults Inc:pageData.PartnerResultsInc){
                incumidset.add(Inc.id);
            }

            for(PartnerResults Rec:pageData.PartnerResultsRec){
                recumidset.add(Rec.id);
            }

            updatePartnerAccount(incumidset,recumidset);
            */

        }
         catch(exception e)
        {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();
        }
        return pageData;
        }

     /*
        DESCRIPTION : EDGE-96585 This Method used to the Opportunity Stage Name
        */
        // v1.5 changed return type from string to object
        public static Opportunity findOpptyStatus(String OpptyID) {
        String OpptyStatus;
       
      List<Opportunity> Opportunitstage= [SELECT Id, Name, Product_Domain__c,StageName
                                        ,SubmittoPartnerStatus__c, PartnerAccountId, PartnerAccount.Name
                                        ,CreatedBy.ContactId,CreatedBy.Contact.Account.Name, RecordTypeId
                                        ,Owner.isActive
                                        FROM Opportunity WHERE Id =: OpptyID];
        
        //return Opportunitstage[0].StageName;
        return Opportunitstage[0]; // v1.5
    }

        /*
        DESCRIPTION : This Method used to filter the Partner Account records based on Primary Domain on Opportunity
        */
    /*
    public static list < Account > findBusinessDomain(String OpptyID) {
        String PrimaryDomain;
        list < account > acclist;
        Map < Id, Opportunity > oppDomain = new Map < Id, Opportunity > ([SELECT Id, Name, Product_Domain__c FROM Opportunity WHERE Id =: OpptyID]);
        if (oppDomain.ContainsKey(OpptyID) && oppDomain.get(OpptyID).Product_Domain__c != null) {
            PrimaryDomain = oppDomain.get(OpptyID).Product_Domain__c;
            list < Opportunity_Domain_Partner_Accredition__mdt > mappingList = [SELECT id, Accreditation_Field__c, Accreditation_Status__c, Opportunity_Domain__c, Partner_Accreditation__c FROM Opportunity_Domain_Partner_Accredition__mdt WHERE Opportunity_Domain__c =: PrimaryDomain];
            if (mappingList.size() > 0) {
                list < string > AccridationList = mappingList[0].Accreditation_Status__c.split(',');
                String AccridationField = mappingList[0].Accreditation_Field__c;
                String query = 'SELECT id,Name,State_Coverage__c,Overall_Accreditation__c,Users_on_Account__c FROM Account WHERE ' + AccridationField + ' in :AccridationList and IsPartner = true';
                acclist = Database.query(query);
                system.debug('acclist' + acclist);
            }
        }
        return acclist;
    }
*/
    /*
    DESCRIPTION : This Method used to filter the Partner Account records based on Number of opportunities that can be Accepeted by corresponding partner Account
    Eg: If JB HIFI has 25 Partner Users, then will appear in the recommended list only if Open Opportunities are under 25.
    */
    /*public static List < Account > OpenPartnerAccList(list < Account > Acclist) {
        List < Account > OpenpartnerList = new List < Account > ();
        map < id, Integer > OpenOppsCountMap = new map < id, Integer > ();
        map < id, Integer > AccountUserMap = new map < id, Integer > ();

        if(Acclist!=null){
        Map < Id, AggregateResult > Agresults = new Map < id, AggregateResult > ([
            SELECT PartnerAccountId Id, COUNT(Id) OpportunityCount FROM Opportunity
            WHERE PartnerAccountId != NULL
            AND IsClosed = FALSE
            AND PartnerAccountId in: Acclist
            GROUP BY PartnerAccountId
        ]);
        for (AggregateResult AG: Agresults.values()) {
            OpenOppsCountMap.put((String) AG.get('Id'), (Integer) AG.get('OpportunityCount'));
        }
        Map < Id, AggregateResult > UserAgresults = new Map < id, AggregateResult > ([
            SELECT Contact.AccountId Id, COUNT(Id) UserCount FROM User
            WHERE AccountId != NULL
            AND Contact.AccountId in: Acclist
            AND IsActive = true
            GROUP BY Contact.AccountId
        ]);

        system.debug('Acclist' + Acclist);
        system.debug('UserAgresults' + UserAgresults);

        for (AggregateResult UserAgg: UserAgresults.values()) {
            AccountUserMap.put((String) UserAgg.get('Id'), (Integer) UserAgg.get('UserCount'));
        }
        for (Account Acc: Acclist) {
            system.debug('AccountUserMap' + AccountUserMap.get(acc.id));
            system.debug('OpenOppsCountMap.get(acc.id)' + OpenOppsCountMap.get(acc.id));
            if (AccountUserMap.get(acc.id) != Null && (OpenOppsCountMap.get(acc.id) == null || (OpenOppsCountMap.get(acc.id) < AccountUserMap.get(acc.id)))) {
                OpenpartnerList.add(Acc);
            }
        }

        }
        return OpenpartnerList;
    }

*/
    /*
    DESCRIPTION : This Method used to filter the Partner Account records based on Billing State of Customer Account Vs State Coverage of Partner Account
    */
    /*
    @AuraEnabled
    public static list < Account > getStateCoverageList(list < Account > Acclist, String OpptyID) {
        List < Account > StateFilteredList = new List < Account > ();
        String StateCoverage = '';
        Map < Id, Opportunity > oppStateCoverage = new Map < Id, Opportunity > ([SELECT Id, Name, AccountId, Product_Domain__c FROM Opportunity WHERE Id =: OpptyID]);
        if (oppStateCoverage.ContainsKey(OpptyID) && oppStateCoverage.get(OpptyID).AccountId != null) {
            id Accid = oppStateCoverage.get(OpptyID).AccountId;
            List < Account > BillingStateLst = [select id, BillingState, Shippingstate FROM account WHERE id =: Accid];
            if (BillingStateLst.size() > 0) {
                StateCoverage = BillingStateLst[0].BillingState;
            }
        }

        if(Acclist!=null){
            for (Account Acc: Acclist) {
                //null pointer for Acc.State_Coverage__c
                If(StateCoverage != null && Acc.State_Coverage__c != null && string.valueOf(Acc.State_Coverage__c).Contains(StateCoverage))
                StateFilteredList.add(Acc);
            }
        }
        return StateFilteredList;
    }
*/

   /*
    DESCRIPTION : This Method used to prepare a map of Accounts and open opportunities Size
    */

   /*     public static map < id, Integer > getPartnersWithMaxOpty(list < Account > Acclist) {
        map < id, Integer > OppsCountMap = new map < id, Integer > ();
        if(Acclist!=null){
            string squery='SELECT id, Name, (select id, stageName FROM Partner_Account__r WHERE (StageName =\''+PRMConstants.PRM_OPTY_STAGE_DEFINE+
                '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_QUALIFY+ '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_DEVELOP+ '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_PRICE+ '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_PROPOSE+ '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_NEGOTIATE+ '\' OR StageName =\''+ PRMConstants.PRM_OPTY_STAGE_CLOSED_WON+ '\') and (CreatedDate =' +Label.PRM_LAST_N_TIMEPERIOD+ ')) FROM Account WHERE id in :  Acclist ORDER BY CreatedDate DESC';

            system.debug('squery'+squery);
            List<Account> Accountlist = Database.query(squery);


            for (Account acc: Accountlist) {
                OppsCountMap.put(acc.id, acc.Partner_Account__r.size());
            }
        }
        return OppsCountMap;
    }
*/

    /*
    DESCRIPTION : This Method used to prepare a map of Accounts and open opportunities Size
    */
  /*  public static map < id, Integer > getPartnersWithMaxOptyAll(list < Account > Acclist) {
        map < id, Integer > OppsCountMap = new map < id, Integer > ();

     if(Acclist!=null){
        String Squery='SELECT id, Name, (select id, stageName FROM Partner_Account__r WHERE (CreatedDate =' +Label.PRM_LAST_N_TIMEPERIOD+ ')) FROM Account WHERE id in :  Acclist';
                system.debug('squery'+Squery);

        List<Account> Accountlist = Database.query(Squery);


        for (Account acc: Accountlist) {
            OppsCountMap.put(acc.id, acc.Partner_Account__r.size());
        }
    }
        return OppsCountMap;
    }
*/
    /*
    DESCRIPTION : This Method used to prepare a map of Accounts and Success Rate
    */
  /*  @AuraEnabled
    public static map < id, double > getOpportunitySuccessRate(list < Account > Acclist) {
        map < id, double > SuccessRateMap = new map < id, double > ();
        if(Acclist!=null){
        List < account > Accountlist = [SELECT id, Name, (select id, Name, stageName FROM Partner_Account__r WHERE isClosed = true) FROM Account WHERE id in: Acclist];
        for (Account Acc: Accountlist) {
            double SuccessRate = 0;
            if (Acc.Partner_Account__r.size() > 0) {
                //Success rate is won/(won+closed). pls correct
                system.debug('Acc' + Acc);
                double Total = Acc.Partner_Account__r.size();
                double ClosedWon = 0;
                list < opportunity > opplist = Acc.Partner_Account__r;
                for (Opportunity Opp: opplist) {
                    If(Opp.stageName == 'Closed Won')
                    ClosedWon++;
                }
                if (Total > 0 && ClosedWon>0){
                    //SuccessRate = ((ClosedWon / Total)).Round;
                    SuccessRate = ((ClosedWon / Total));
                    }
            }
            SuccessRateMap.put(Acc.id, SuccessRate);
        }
        }
        system.debug('SuccessRateMap' + SuccessRateMap);
        return SuccessRateMap;
    }
    */

  /*  @AuraEnabled
    public static list < PartnerResults > findIncumbentPartners(String OpptyID) {
        list < PartnerResults > PartnerResultslist = new list < PartnerResults > ();
        system.debug('PartnerResultslist' + PartnerResultslist);
        list < NumberOfOppswrapper > NumberOfOppswrapperlist = new list < NumberOfOppswrapper > ();
          system.debug('NumberOfOppswrapperlist' + NumberOfOppswrapperlist);
        list < PartnerResults > PartnerResultslistSliced = new list < PartnerResults > ();
           system.debug('PartnerResultslistSliced' + PartnerResultslistSliced);
        List < account > AccountList = new list < account > ();
        List < account > DomainBasedList = findBusinessDomain(OpptyID); //Get the List of Account based on Domain of Opportunity
        system.debug('DomainBasedList' + DomainBasedList);
        map < id, Integer > MaxOptyNumberMap = getPartnersWithMaxOpty(DomainBasedList); // get the list of Accounts with max opportunities
        List < account > StateCoverageList = getStateCoverageList(DomainBasedList, OpptyID); //Filter the List of Accounts based on State Coverage
         system.debug('StateCoverageList' + StateCoverageList);
        List < account > OptysThresholdLimitedList = OpenPartnerAccList(DomainBasedList); //Filter the List of Accounts based on Number of open opportunies vs number of partners.
         system.debug('OptysThresholdLimitedList' + OptysThresholdLimitedList);
        map < id, Double > SuccessRateMap = getOpportunitySuccessRate(DomainBasedList);
       // map < id, Integer > MaxOptyNumberMap = getPartnersWithMaxOpty(DomainBasedList);
        for (Account acc: OptysThresholdLimitedList) {
            PartnerResults prec = new PartnerResults();
            NumberOfOppswrapper OpsWrapper = new NumberOfOppswrapper();
            prec.account = acc;
            //GCP added 2 variable for data table
            prec.accountName = acc.Name;
            prec.Id = acc.Id;
            prec.accreditation = acc.Overall_Accreditation__c;
            prec.stateCoverage = acc.State_Coverage__c;
            if (SuccessRateMap.ContainsKey(acc.id))
                prec.OptySuccessRate = SuccessRateMap.get(acc.id);
            OpsWrapper.PartnerResults =prec;
            if (MaxOptyNumberMap.ContainsKey(acc.id))
                OpsWrapper.NoOfOppotunities = MaxOptyNumberMap.get(acc.id);
            NumberOfOppswrapperlist.add(OpsWrapper);
        }
        NumberOfOppswrapperlist.sort();
        if (NumberOfOppswrapperlist.size() > PRMConstants.NUMBER_OF_PARTNERS) {
            for (integer i = 0; i < PRMConstants.NUMBER_OF_PARTNERS; i++) {
                PartnerResultslistSliced.add(NumberOfOppswrapperlist[i].PartnerResults);
            }
            PartnerResultslistSliced.sort();
            return PartnerResultslistSliced;
        }
        system.debug('PartnerResultslist' + PartnerResultslist);
        return PartnerResultslist;
    }
    */
    
    // v1.3 method to fetch partner auto tagging custom setting record details
    @AuraEnabled
    public static PRMOpportunityPartnerAutoTaggingWrapper getHiearchySettings(){
        // P2OB-4628 - Wrap custom setting in wrapper class 
        PRM_Opportunity_Partner_Auto_Tagging__c autoTaggingSetting = PRM_Opportunity_Partner_Auto_Tagging__c.getInstance();
        PRMOpportunityPartnerAutoTaggingWrapper autoTaggingSettingWrapper = new PRMOpportunityPartnerAutoTaggingWrapper();
        autoTaggingSettingWrapper.isActive = autoTaggingSetting.isActive__c;  
        autoTaggingSettingWrapper.onboardedPartnerMessage = autoTaggingSetting.Message_01__c;
        autoTaggingSettingWrapper.nonOnboarderTaggedPartnerMessage = autoTaggingSetting.Message_02__c;
        autoTaggingSettingWrapper.nonOnboarderNominateMessage = autoTaggingSetting.Message_03__c;
        autoTaggingSettingWrapper.nonOnboarderPartnerErrorMessage = autoTaggingSetting.Message_04__c;
        autoTaggingSettingWrapper.noPartnerUserErrorMessage = autoTaggingSetting.Message_05__c;
        return autoTaggingSettingWrapper;
    }
    
    
    // v1.3 method to fetch all message details
    @AuraEnabled
    public static DistributorModelSettingWrapper getDistributorModelSettings(){
        // P2OB-4628 - Wrap custom setting in wrapper class
        Distributor_Model_Setting__c distributorModelSetting = Distributor_Model_Setting__c.getInstance();
        DistributorModelSettingWrapper distributorModelWrapper = new DistributorModelSettingWrapper();
        distributorModelWrapper.isEnabled = distributorModelSetting.isEnabled__c;
        distributorModelWrapper.closedOpportunityError = distributorModelSetting.Error_Message_11__c;// v1.5
        distributorModelWrapper.sharedWithPartnerError = distributorModelSetting.Error_Message_12__c;// v1.5
        distributorModelWrapper.partnerCreatedError = distributorModelSetting.Error_Message_13__c;// v1.5
        distributorModelWrapper.opportunityOwnerInactiveError = distributorModelSetting.Error_Message_14__c;// v2.0
        return distributorModelWrapper;
    }
    
    // v1.3 method to fetch the details of the partner lookup that was selected
    // v1.4 added PartnerPrincipalContact__c field
    // v1.6 added Primary_Distributor__c.Account_Status__c
    @AuraEnabled
    public static Account returnSelectedPartner(Id partnerId){
        list<Account> lstA = [Select Id, Account_Status__c, PartnerPrincipalContact__c, Partner_Type__c
                             , Primary_Distributor__c, Primary_Distributor__r.Name 
                             , Primary_Distributor__r.PartnerPrincipalContact__c
                             , Primary_Distributor__r.Account_Status__c
                             from Account where Id =: partnerId limit 1];
        if(!lstA.isEmpty()){
            return lstA[0];
        }else{
            return null;
        }
    }

    // v1.4 method to fetch Partner Principal Contact's User details
    @AuraEnabled
    public static User returnPartnerUser(Id partnerPrincipalContactId){
        system.debug('*****partnerPrincipalContactId*****'+partnerPrincipalContactId);
        list<User> lstUser = [Select Id, isActive, ContactId from User where ContactId =: partnerPrincipalContactId limit 1];
        system.debug('*****lstUser*****'+lstUser);
        if(lstUser != null && !lstUser.isEmpty()){
            return lstUser[0];
        }else{
            return null;
        }
    }

/* EDGE-81324 This method implements the business logic to display Incumbent Partners as part of submit to partner fucntionality   */
     @AuraEnabled
    public static list < PartnerResults > findIncumbentPartners(String OpptyID) {
        list < PartnerResults > PartnerResultslist = new list < PartnerResults > ();
        List < account > AccountList = new list < account > ();
        String PrimaryDomain;
        String statusActive=PRMConstants.STATUS_ACTIVE;
        String AccridationField;
        list <sortingwrapperIncumb> sortingwrapperIncumlist = new list <sortingwrapperIncumb> ();
        Logger2 logger = Logger2.getLogger('PRMSubmitToPartnerRules.findIncumbentPartners');
        //list <sortingwrapperIncumb> sortingwrapperIncumlistsliced = new list <sortingwrapperIncumb> ();

try{
      /*get details of opportunity and check if the opportunity domains are same for the selected Accounts opportunities. */
        Map < Id, Opportunity > oppDomain = new Map < Id, Opportunity > ([SELECT Id,Partner_Account__c,PartnerAccountId,Accountid,Account.Billingstate, Name, Product_Domain__c FROM Opportunity WHERE Id =: OpptyID]);
        if (oppDomain.ContainsKey(OpptyID) && oppDomain.get(OpptyID).Product_Domain__c != null) {
            PrimaryDomain = String.escapeSingleQuotes(oppDomain.get(OpptyID).Product_Domain__c); // v2.1 sanitize value to prevent SOQL injection
            /* domain and accreditation mapping */
            list < Opportunity_Domain_Partner_Accredition__mdt > mappingList = [select id, Accreditation_Field__c, Accreditation_Status__c, Opportunity_Domain__c, Partner_Accreditation__c FROM Opportunity_Domain_Partner_Accredition__mdt WHERE Opportunity_Domain__c =: PrimaryDomain ];
            if (mappingList.size() > 0) {
                String StateCOverage= oppDomain.get(OpptyID).Account.Billingstate;
                list < string > AccridationList = String.escapeSingleQuotes(mappingList[0].Accreditation_Status__c).split(','); // v2.1 sanitize value to prevent SOQL injection
                AccridationField = mappingList[0].Accreditation_Field__c;
                /*to check if opportunity is of same domain and accreditation and Account status is Active. */
                // v1.1 removed Account Active filter
                // AND Account_Status__c=:statusActive
                String query = 'SELECT id,Name,State_Coverage__c,Customer_Trading_Name__c,Overall_Accreditation__c,Cloud_Accreditation__c,Collaboration_Accreditation__c,Data_Security_Accreditation__c,Mobility_Accreditation__c,Services_Accreditation__c,Security_Accreditation__c,Users_on_Account__c FROM Account WHERE ' + String.escapeSingleQuotes(AccridationField) + ' in : AccridationList'; // v2.2 adding security/service accreditation fields
                system.debug('query' + query);
                    map<Id,Account> accountMap = new map<Id,Account>((list<Account>)Database.query(query)); // v1.1
                    //AccountList = Database.query(query);
                    AccountList = accountMap.values(); // v1.1
                system.debug('AccountList' + AccountList);
                //list < string > AccridationList = mappingList[0].Accreditation_Status__c.split(',');
                String StageName=String.escapeSingleQuotes(Label.Opp_Stage_ClosedWon); //PRM_Opportunity_Open_Stages; v2.1 sanitize value to prevent SOQL injection
                list<string> stageNames=StageName.split(',');
                string ApprovedStatus=PRMConstants.PRM_APPROVED_STATUS;
                Map <String,list<opportunity>> opAccMap= new Map<String,list<opportunity>>();
                String accid = String.escapeSingleQuotes(oppDomain.get(OpptyID).Accountid); // v2.1 sanitize value to prevent SOQL injection
                /*get the opportunities WHERE opty is Approved (when created by partner) or verification status is Approved, opportunity stage is open and is created in the last 12 months. */
                    // v1.1
                    String productStatus = String.escapeSingleQuotes(PRMConstants.OPPORTUNITY_PRODUCT_STATUS); // v1.1 // v2.1 sanitize value to prevent SOQL injection
                    string queryopp = 'select id,Owner.Accountid,name,Partner_Account__c,PartnerAccountId,stagename,CreatedDate,SubmittoPartnerStatus__c,Partner_Opportunity_Verification__c,(Select Id, OpportunityId, Tagged_Partner__c, Domain__c from OpportunityLineItems where Domain__c =:PrimaryDomain and Product_Status__c =:productStatus) FROM opportunity WHERE Accountid =: accid and stagename in: stageNames and CreatedDate = '+String.escapeSingleQuotes(Label.PRM_LAST_N_TIMEPERIOD); // v1.1 // v2.1 sanitize value to prevent SOQL injection
                    // v1.1 string queryopp = 'select id,Owner.Accountid,name,Partner_Account__c,PartnerAccountId,stagename,CreatedDate FROM opportunity WHERE ((PartnerAccountId in: AccountList and SubmittoPartnerStatus__c =: ApprovedStatus) or(createdby.Accountid in: AccountList and Partner_Opportunity_Verification__c =: ApprovedStatus)) and Accountid =: accid and stagename in: stageNames and CreatedDate = '+Label.PRM_LAST_N_TIMEPERIOD;
               //string queryopp='select id,name,PartnerAccountId,stagename,DAY_ONLY(CreatedDate),PartnerAccount.Name pName FROM opportunity WHERE PartnerAccountId in :AccountList and Accountid=:accid and stagename in:stageNames and CreatedDate = '+Label.PRM_LAST_N_TIMEPERIOD+ ' group by DAY_ONLY(CreatedDate),PartnerAccount.Name,id,Name,PartnerAccountId,stagename order by DAY_ONLY(CreatedDate) Desc,PartnerAccount.Name Asc limit 2000';
               //system.debug('queryopp'+queryopp);

               list<Opportunity> Oplist=Database.query(queryopp);
               system.debug('Oplist'+Oplist);
               //new code
               /* Code to check when opportunity is created by a Partner */
                 for(opportunity opp:Oplist){
                system.debug('*****opp.Id*****'+opp.Id);
                        system.debug('*****opp.PartnerAccountId*****'+opp.PartnerAccountId);
                        system.debug('*****opp.SubmittoPartnerStatus__c*****'+opp.SubmittoPartnerStatus__c);
                        system.debug('*****accountMap.containsKey*****'+accountMap.containsKey(opp.PartnerAccountId));
                        system.debug('*****opp.Owner.Accountid*****'+opp.Owner.Accountid);
                        system.debug('*****opp.Partner_Opportunity_Verification__c*****'+opp.Partner_Opportunity_Verification__c);
                        if (opp.PartnerAccountId != null && accountMap.containsKey(opp.PartnerAccountId) && opp.SubmittoPartnerStatus__c == ApprovedStatus) {
                            system.debug('PartnerAccountId NOT NULL *** opp.name pp' + opp.Name);
                            if (opAccMap.containsKey(opp.PartnerAccountId)) {
                                if (opAccMap.get(opp.PartnerAccountId).size() > 0)
                                    opAccMap.get(opp.PartnerAccountId).add(opp);
                            } else {
                                opAccMap.put(opp.PartnerAccountId, new list < opportunity > {
                                    opp
                                });
                            }
                        } else if (opp.PartnerAccountId == null && opp.Owner.Accountid != null
                        && accountMap.containsKey(opp.Owner.AccountId) && opp.Partner_Opportunity_Verification__c == ApprovedStatus) { //   )
                            system.debug('PartnerAccountId NULL *** opp.name' + opp.Name);
                            if (opAccMap.containsKey(opp.Owner.Accountid)) {
                                if (opAccMap.get(opp.Owner.Accountid).size() > 0)
                                    opAccMap.get(opp.Owner.Accountid).add(opp);
                            } else {
                                opAccMap.put(opp.Owner.Accountid, new list < opportunity > {
                                    opp
                                });
                            }
                        }
                        // v1.1 considering tagged partners
                        system.debug('*****TAGGED Partners*****');
                        for(OpportunityLineItem objOLI : opp.OpportunityLineItems){
                            system.debug('*****producst*****'+objOLI.Tagged_Partner__c);
                            if(accountMap.containsKey(objOLI.Tagged_Partner__c)){
                                if (opAccMap.containsKey(objOLI.Tagged_Partner__c)) {
                                    system.debug('MAP CONTAINS KEY*****');
                                    if(!opAccMap.get(objOLI.Tagged_Partner__c).contains(opp)){
                                        system.debug('last step*****');
                                        opAccMap.get(objOLI.Tagged_Partner__c).add(opp);
                                    }
                                }else{
                                    system.debug('MAP DOES NOT CONTAIN KEY, ELSE*****');
                                    opAccMap.put(objOLI.Tagged_Partner__c, new list < opportunity > {opp});
                                }
                            }
                        }
                    }
                /*
                for(opportunity opp:Oplist){
                    if(opAccMap.containsKey(opp.Partner_Account__c)){
                        if( opAccMap.get(opp.Partner_Account__c).size()>0)
                            opAccMap.get(opp.Partner_Account__c).add(opp);
                         }else
                            opAccMap.put(opp.Partner_Account__c,new list<opportunity>{opp});
                }*/
               system.debug('++++opAccMap+++'+opAccMap);
                system.debug('++++AccountList+++'+AccountList);
                    // v1.1 added Account_Status__c, RecordType.DeveloperName to query along with RecordType.DeveloperName filter
                    // v1.2 added Primary_Distributor__c, Primary_Distributor__r.Name, Primary_Distributor__r.Account_Status__c
                    List < Account > partnerAccList = [SELECT id, Name, Primary_Distributor__c, Primary_Distributor__r.Name, Primary_Distributor__r.Account_Status__c, Account_Status__c, RecordType.DeveloperName, IsPartner, ownerid, Owner.Name, State_Coverage__c, Customer_Trading_Name__c, Overall_Accreditation__c, Cloud_Accreditation__c, Collaboration_Accreditation__c, Data_Security_Accreditation__c, Mobility_Accreditation__c, Services_Accreditation__c,Security_Accreditation__c, Users_on_Account__c
                        FROM Account WHERE Id IN: opAccMap.keySet()
                        and RecordType.DeveloperName =: PRMConstants.PRM_RecordType_Partner
                    ]; // v2.2 adding Security / Service accreditation fields
                for (Account acc: partnerAccList) {
                    PartnerResults partnerrec = new PartnerResults();
                    if(opAccMap.containsKey(acc.id))
                    if(opAccMap.containsKey(acc.id) && opAccMap.get(acc.id).size()>0){
                    /*set values to wrapper to display in UI*/
                        sortingwrapperIncumb OpsWrapper = new sortingwrapperIncumb();
                        partnerrec.account = acc;
                        //GCP added 2 variable for data table
                        partnerrec.accountName = acc.Name;
                        partnerrec.TradingName=acc.Customer_Trading_Name__c;
                        partnerrec.Id = acc.Id;

                    /*get the different positive accreditation values of the account */
                    //partnerrec.accreditation = acc.Overall_Accreditation__c;
                    partnerrec.accreditation = acc.get(AccridationField) != null ? (String)acc.get(AccridationField) : ''; // v2.2
                    /*
                    switch on AccridationField {
                         when 'Cloud_Accreditation__c' {
                                partnerrec.accreditation=acc.Cloud_Accreditation__c ;
                            }
                            when 'Collaboration_Accreditation__c' {
                                partnerrec.accreditation=acc.Collaboration_Accreditation__c ;
                            }
                            when 'Data_Security_Accreditation__c' {
                                partnerrec.accreditation=acc.Data_Security_Accreditation__c;
                            }
                            when 'Mobility_Accreditation__c' {
                                partnerrec.accreditation=acc.Mobility_Accreditation__c;
                            }
                                    when
                                    else {
                               partnerrec.accreditation='';
                            }
                        }
                        */
                    partnerrec.stateCoverage = acc.State_Coverage__c;
                    // v1.2 for Nominate Accounts display Primary Distributor name
                    if(acc.Primary_Distributor__c != null){
                        partnerrec.DistributorName = acc.Primary_Distributor__r.Name;
                        if(acc.Primary_Distributor__r.Account_Status__c == PRMConstants.PRM_Account_Status_Active
                        || acc.Account_Status__c == PRMConstants.PRM_Account_Status_Active){
                            partnerrec.isPartner = 'Yes';
                            if(acc.Account_Status__c != PRMConstants.PRM_Account_Status_Active){
                                partnerrec.DistributorId = acc.Primary_Distributor__c;
                            }
                        }else{
                           partnerrec.isPartner = 'No';
                        }
                    }else{
                        partnerrec.isPartner = acc.Account_Status__c == PRMConstants.PRM_Account_Status_Active ? 'Yes' : 'No'; // v1.1
                    }
                    // end of v1.2
                    //OpsWrapper.PartnerResults = partnerrec;
                    //PartnerResultslist.add(partnerrec);
                    OpsWrapper.PartnerResults = partnerrec;
                    OpsWrapper.AccountName=acc.Name;
                    //OpsWrapper.isPartner = String.valueOf(acc.isPartner); // v1.1
                    Datetime mostRecentOppDate;
                    List<Datetime> dateTimeRecs=new List<Datetime>();
                    for(Opportunity opp:opAccMap.get(acc.id)){
                        dateTimeRecs.add(opp.CreatedDate);
                        }
                    dateTimeRecs.sort();
                    if(dateTimeRecs.size()>0){
                    //OpsWrapper.CreatedDate=dateTimeRecs[0].Date();
                    integer indexvalue=dateTimeRecs.size()-1;
                    OpsWrapper.CreatedDate=dateTimeRecs[indexvalue].Date();
                    }


                    sortingwrapperIncumlist.add(OpsWrapper);

        }
        }
       }

          for(sortingwrapperIncumb sa:sortingwrapperIncumlist){
           system.debug('s.created before'+sa.CreatedDate+'Name'+sa.accountName );
       }

       /*sort the derived incumbent partners list */
       sortingwrapperIncumlist.sort();

         for(sortingwrapperIncumb sb:sortingwrapperIncumlist){
           system.debug('s.created after sort'+sb.CreatedDate+'Name'+sb.accountName );
        }

    /*add the sorted partners to a list which is used to display the list in ui component */
       for (integer i = 0; i < sortingwrapperIncumlist.size(); i++) {
                PartnerResultslist.add(sortingwrapperIncumlist[i].PartnerResults);
       }
    }
     }
        catch(exception e)
        {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();

        }

        system.debug('PartnerResultslist'+PartnerResultslist);
        return PartnerResultslist;
    }



   /*EDGE-81336--Recommended Partner
   this method implements the business logic to display Recommended Partners as part of submit to partner fucntionality   */
    @AuraEnabled
    public static list < PartnerResults > findRecommedation(String OpptyID) {
        system.debug('findRecommedation called*****');
        list < PartnerResults > PartnerResultslist = new list < PartnerResults > ();
        List < account > AccountList = new list < account > ();
        String PrimaryDomain;
        String statusActive=String.escapeSingleQuotes(PRMConstants.STATUS_ACTIVE); // v2.1 sanitize value to prevent SOQL injection
        String AccridationField;
        list <sortingwrapperRecomm> sortingwrapperRecommlist = new list <sortingwrapperRecomm> ();
        map<string,sortingwrapperRecomm> sortingwrapperRecommmap= new map<string,sortingwrapperRecomm>();
        list <sortingwrapperRecomm> sortingwrapperRecommlistsliced = new list <sortingwrapperRecomm> ();
        Logger2 logger = Logger2.getLogger('PRMSubmitToPartnerRules.findRecommedation');

        Map < Id, Opportunity > oppDomain = new Map < Id, Opportunity > ([SELECT Id,Account.Billingstate, Name, Product_Domain__c FROM Opportunity WHERE Id =: OpptyID]);
        if (oppDomain.ContainsKey(OpptyID) && oppDomain.get(OpptyID).Product_Domain__c != null) {
            PrimaryDomain = oppDomain.get(OpptyID).Product_Domain__c;
            system.debug('findRecommedation *****'+PrimaryDomain );
            /*get details of opportunity and check if the opportunity domains are same for the selected Accounts opportunities. */
            list < Opportunity_Domain_Partner_Accredition__mdt > mappingList = [select id, Accreditation_Field__c, Accreditation_Status__c, Opportunity_Domain__c, Partner_Accreditation__c FROM Opportunity_Domain_Partner_Accredition__mdt WHERE Opportunity_Domain__c =: PrimaryDomain];
            /*billing state should not be null for recommended partners */
            if (mappingList.size() > 0 && oppDomain.get(OpptyID).Account.Billingstate!=null) {
                String StateCOverage= String.escapeSingleQuotes(oppDomain.get(OpptyID).Account.Billingstate); // v2.1 sanitize value to prevent SOQL injection
                // invoke recommended partners logic
                PartnerResultslist = PRMPartnerRecommendationRules.returnRecommendedPartners(OpptyID,mappingList[0].Accreditation_Status__c,mappingList[0].Accreditation_Field__c,StateCOverage,null); // v2.2
                /*
                // commenting all code as part of code optimization and moving recommendation logic to PRMPartnerRecommendationRules.cls
                //list < string > AccridationList =new list<String> {'Platinum','Gold'}; // v1.7
                //String Accridations=Label.PRM_Accreditation_Levels; // v1.7
                //list<string> AccridationList = Accridations.split(','); // v1.7
                list<string> AccridationList = String.escapeSingleQuotes(mappingList[0].Accreditation_Status__c).split(','); // v1.7 consider all accreditation levels // v2.1 sanitize value to prevent SOQL injection
                AccridationField = mappingList[0].Accreditation_Field__c;
                
                String query = 'SELECT id,Name,State_Coverage__c,Customer_Trading_Name__c,Overall_Accreditation__c,Cloud_Accreditation__c,Collaboration_Accreditation__c,Data_Security_Accreditation__c,Mobility_Accreditation__c,Users_on_Account__c FROM Account WHERE ' + String.escapeSingleQuotes(AccridationField) + ' in :AccridationList AND Account_Status__c=: statusActive AND State_Coverage__c INCLUDES(\''+String.escapeSingleQuotes(StateCOverage)+'\')'; // v2.1 sanitize value to prevent SOQL injection
                system.debug('query' + query);
                AccountList = Database.query(query);
                system.debug('AccountList' + AccountList);
           
            for (Account acc: AccountList) {
            PartnerResults partnerrec = new PartnerResults();
            sortingwrapperRecomm OpsWrapper = new sortingwrapperRecomm();
            partnerrec.account = acc;
            //GCP added 2 variable for data table
            partnerrec.accountName = acc.Name;
            partnerrec.TradingName=acc.Customer_Trading_Name__c;
            partnerrec.Id = acc.Id;
            partnerrec.isPartner = 'Yes'; // v1.1

          
            //partnerrec.accreditation = acc.Overall_Accreditation__c;
             switch on AccridationField {
                 when 'Cloud_Accreditation__c' {
                        partnerrec.accreditation=acc.Cloud_Accreditation__c ;
                    }
                    when 'Collaboration_Accreditation__c' {
                        partnerrec.accreditation=acc.Collaboration_Accreditation__c ;
                    }
                    when 'Data_Security_Accreditation__c' {
                        partnerrec.accreditation=acc.Data_Security_Accreditation__c;
                    }
                    when 'Mobility_Accreditation__c' {
                        partnerrec.accreditation=acc.Mobility_Accreditation__c;
                    }
                    when else {
                       partnerrec.accreditation='';
                    }
                }
            partnerrec.stateCoverage = acc.State_Coverage__c;
            OpsWrapper.PartnerResults = partnerrec;
            if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_PLATINUM){
                OpsWrapper.AccridationLevel=5;
            }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_GOLD){
                OpsWrapper.AccridationLevel=4;
            }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_SILVER){ // v1.7
                OpsWrapper.AccridationLevel=3;
            }else if(partnerrec.accreditation==PRMConstants.PRM_ACCRIDATION_STATUS_APPROVED){ // v1.7
                OpsWrapper.AccridationLevel=2;
            }
            OpsWrapper.AccountName=acc.Name;
            sortingwrapperRecommmap.put(acc.id,OpsWrapper);
            //sortingwrapperRecommlist.add(OpsWrapper);
        }
                */
            } // end of Account.Billingstate != null
        } // end of Product_Domain__c != null
        
        /*
        
        list < PartnerResults > PartnerResultslistinc =  PRMSubmitToPartnerRules.findIncumbentPartners(OpptyID);
           for(PartnerResults prec:PartnerResultslistinc)
           {
               if(sortingwrapperRecommmap.containsKey(prec.Id)){
                  system.debug('excluding'+sortingwrapperRecommmap.get(prec.Id));
                    sortingwrapperRecommmap.remove(prec.Id);
               }

        }
        sortingwrapperRecommlist=sortingwrapperRecommmap.values();

    
        if(sortingwrapperRecommlist.size()>PRMConstants.NUMBER_OF_PARTNERS){
            for (integer i = 0; i < PRMConstants.NUMBER_OF_PARTNERS; i++) {
                Integer randomNumber = Integer.valueof((Math.random() * sortingwrapperRecommlist.size()));
                sortingwrapperRecommlistsliced.add(sortingwrapperRecommlist[randomNumber]);
                sortingwrapperRecommlist.remove(randomNumber);
            }
        }
        else{
                sortingwrapperRecommlistsliced.addall(sortingwrapperRecommlist);
        }
   
        sortingwrapperRecommlistsliced.sort();
         for (integer i = 0; i < sortingwrapperRecommlistsliced.size(); i++) {
                PartnerResultslist.add(sortingwrapperRecommlistsliced[i].PartnerResults);
            }
        //return PartnerResultslist;
        }
        catch(exception e)
        {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();

        }
        */
        return PartnerResultslist;
    }

    /*
    //Base Wrapper
    
    public class PartnerResults  { //implements Comparable
        @AuraEnabled public boolean isselected {
            get;
            set;
        }
        @AuraEnabled public Account account {
            get;
            set;
        }
        @AuraEnabled public String Id {
            get;
            set;
        }
        @AuraEnabled public String isPartner {
            get;
            set;
        }
        @AuraEnabled public String accountName {
            get;
            set;
        }
        @AuraEnabled public String accreditation {
            get;
            set;
        }
        @AuraEnabled public String stateCoverage {
            get;
            set;
        }

        @AuraEnabled public String TradingName {
            get;
            set;
        }
        @AuraEnabled public Double OptySuccessRate {
            get;
            set;
        }
        @AuraEnabled public String DistributorName {
            get;
            set;
        }
        @AuraEnabled public String DistributorId {
            get;
            set;
        }
        
        @AuraEnabled public String porProductDomain {get; set;} //EDGE-151598
        @AuraEnabled public date porAgreementEnddate {get; set;} //EDGE-151598

        //public Integer compareTo(Object compareTo) {
        //  PartnerResults PartnerResults = (PartnerResults) compareTo;
        // if (this.OptySuccessRate == PartnerResults.OptySuccessRate) return 0;
        //if (this.OptySuccessRate < PartnerResults.OptySuccessRate) return 1;
        //return -1;
        //}
    }
    */
    
    //Wrapper for Sorting list based on Number of Opportunities
/*
    public class NumberOfOppswrapper implements Comparable {
        public PartnerResults PartnerResults {
            get;
            set;
        }
        public integer NoOfOppotunities {
            get;
            set;
        }

        public Integer compareTo(Object compareTo) {
            NumberOfOppswrapper NumberOfOppswrapper = (NumberOfOppswrapper) compareTo;
            if (this.NoOfOppotunities == NumberOfOppswrapper.NoOfOppotunities) return 0;
            if (this.NoOfOppotunities < NumberOfOppswrapper.NoOfOppotunities) return 1;
            return -1;
        }
    }
*/

/*sorting logic for Recommended partners. Opportunities to be displayed based on accreditation level- highest accreditation level first- and if same accreditation then in alphabetical order. */
    /*
    public class sortingwrapperRecomm implements Comparable {
        public PartnerResults PartnerResults {
            get;
            set;
        }
        public integer AccridationLevel {
            get;
            set;
        }
        public String AccountName {
            get;
            set;
        }
         public Integer compareTo(Object compareTo) {
            sortingwrapperRecomm sortingwrapperRecomm = (sortingwrapperRecomm) compareTo;
            if (this.AccridationLevel < sortingwrapperRecomm.AccridationLevel) return 1;
            if (this.AccridationLevel > sortingwrapperRecomm.AccridationLevel) return -1;
             else{
                 if (this.AccountName > sortingwrapperRecomm.AccountName) return 1;
                    if (this.AccountName < sortingwrapperRecomm.AccountName) return -1;
                 else{
                     return 0;
                     }
             }
        }
    }
    */

  /*sorting logic for Incumbent partners. most recent created opportunity account to be displayed first.
  if date is same, then accounts to displayed in alphabetical order. */
    /*
    public class sortingwrapperIncumb implements Comparable {
        public PartnerResults PartnerResults {
            get;
            set;
        }
        public date CreatedDate {
            get;
            set;
        }
        public String AccountName {
            get;
            set;
        }
        public String isPartner {
            get;
            set;
        }
         public Integer compareTo(Object compareTo) {
            sortingwrapperIncumb sortingwrapperIncumb = (sortingwrapperIncumb) compareTo;
           if (this.CreatedDate < sortingwrapperIncumb.CreatedDate) return 1;
            if (this.CreatedDate > sortingwrapperIncumb.CreatedDate) return -1;
             else{
                 if (this.AccountName > sortingwrapperIncumb.AccountName) return 1;
                 if (this.AccountName < sortingwrapperIncumb.AccountName) return -1;
                 else{
                     return 0;
                     }
               //return (this.AccountName).compareTo(((sortingwrapperIncumb)compareTo).AccountName);

             }
        }
    }
    */

 /* EDGE-81324 Method to send Chatter Posts to the Partner Manager of the Incumbent Partner(if there are more than 1 ,then send to all ) if incumbancy is overridden. */
   /* @AuraEnabled
    public static list <PartnerResults> sendChatterToIncumbentPartners(String OpptyID){

        //Map<String, Id> params = new Map<String, Id>();
        list <PartnerResults> PartnerResultslist = new list <PartnerResults> ();


        //call the method findIncumbentPartners to fetch the incumbent partners list to whom the notification needs to be sent.
        PartnerResultslist = PRMSubmitToPartnerRules.findIncumbentPartners(OpptyID);

        Opportunity opp = [SELECT id, Name, Override_Reason__c, SubmittoPartnerStatus__c,owner.name, AccountId, Account.name FROM Opportunity WHERE Id =: OpptyID];
        List<FeedItem> feedItemList=new List<FeedItem>();
        // to check if incumbency is overridden and opportunity is submitted to partner outside the incumbancy list.
        if(opp.Override_Reason__c != null && opp.SubmittoPartnerStatus__c == 'Submitted'){
            for(PRMSubmitToPartnerRules.PartnerResults acc : PartnerResultslist){


                FeedItem post = new FeedItem();
                post.ParentId = acc.account.ownerId; // Record Id
                post.Body = 'Hi ' +acc.account.owner.Name+ ',' + '\n' + 'This is to advise incumbent Partner ' +acc.account.Name+ ' has not been selected for the opportunity ' +opp.Name+ ' of account ' +opp.Account.name+ '. For more information please contact ' + opp.owner.Name+ '.' ;
                feedItemList.add(post);
            }
            insert feedItemList;
        }
        return null;



    }*/

 /* EDGE-81324 method to send a chatter notification to the ICM of the Incumbent Partner (if more than 1 then send to all) if incumbancy is overridden and opportunity is submitted to partner not in incumbancy list. */
    @AuraEnabled
    public static list <PartnerResults> sendChatterToIncumbentPartners(List<PartnerResults> partnerResultsList,string optyId){

        Opportunity opp = [SELECT id, Name, Override_Reason__c, SubmittoPartnerStatus__c,owner.name, AccountId, Account.name FROM Opportunity WHERE Id =: optyId];    //get the opportunity details
        List<FeedItem> feedItemList=new List<FeedItem>();
        List<string> accountIdList=new List<string>();
         //for(PRMSubmitToPartnerRules.PartnerResults acc : partnerResultsList){
         for(PartnerResults acc : partnerResultsList){
               accountIdList.add(acc.Id);
         }
         /*get the incumbent partners details */
         List<Account> accList = [select Id,ownerId,owner.Name FROM Account WHERE Id IN :accountIdList];
         Map<string,string> mapUser=new Map<String,string>();
         Map<string,string> mapUserName=new Map<String,string>();
         for(Account acc:accList){
           mapUser.put(acc.Id,acc.ownerId);
           mapUserName.put(acc.Id,acc.owner.Name);
         }
        /* to check if incumbency is overridden and opportunity is submitted to partner outside the incumbancy list. */
        if(opp.Override_Reason__c != null && opp.SubmittoPartnerStatus__c == 'Submitted'){
            //for(PRMSubmitToPartnerRules.PartnerResults acc : partnerResultsList){
            for(PartnerResults acc : partnerResultsList){
                FeedItem post = new FeedItem();
                post.ParentId = mapUser.get(acc.Id); // Record Id
                post.Body = 'Hi ' +mapUserName.get(acc.Id)+ ',' + '\n' + 'This is to advise incumbent Partner ' +acc.account.Name+ ' has not been selected for the opportunity ' +opp.Name+ ' for ' +opp.Account.name+ '. For more information please contact ' + opp.owner.Name+ '.' ;
                feedItemList.add(post);
            }
            insert feedItemList;
        }
        return null;



    }


//update the count for the no of times they appeared in search results
/*

    @future
    public static void updatePartnerAccount(Set<Id> setIncumbentAccountId,Set<Id> setRecommendedAccountId) {


        Logger2 logger = Logger2.getLogger('PRMSubmitToPartnerRules.updatePartnerAccount');

        try{

                    List<Account> listUpdatePartner=    [SELECT id,No_of_Times_Recommended__c,No_of_Time_was_Incumbent__c
                                            FROM Account
                                            WHERE id in :setRecommendedAccountId or Id in  :setIncumbentAccountId];

        for(Account eachPartner: listUpdatePartner){
            if(setRecommendedAccountId.contains(eachPartner.Id)){
                //eachPartner.No_of_Times_Recommended__c+=1;
                eachPartner.No_of_Times_Recommended__c=null!=eachPartner.No_of_Times_Recommended__c && eachPartner.No_of_Times_Recommended__c>=0?(eachPartner.No_of_Times_Recommended__c+1):1;

            }else if(setIncumbentAccountId.contains(eachPartner.Id)){
                eachPartner.No_of_Time_was_Incumbent__c=null!=eachPartner.No_of_Time_was_Incumbent__c && eachPartner.No_of_Time_was_Incumbent__c>=0?(eachPartner.No_of_Time_was_Incumbent__c+1):1;
            }
        }

        if(!listUpdatePartner.isEmpty()){
            //update listUpdatePartner;
            Database.update(listUpdatePartner,false);
        }
        }
      catch(exception e)
        {
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();

        }

    }
  */
   /*EDGE-151598: As an AE/CE, I want to view POR info when sharing the Opportunity with Partner*/ 
   //EDGE-202827 Adding TLS_ProductDomain__c field to the Query
    @AuraEnabled
    public static list < PartnerResults > findPartnerOfRecords(String OpptyID) {
        list < PartnerResults > PartnerResultslist = new list < PartnerResults > ();
        Map < Id, Opportunity > oppMap = new Map < Id, Opportunity > ([SELECT Id,Partner_Account__c,PartnerAccountId,Accountid,Account.Billingstate, Name, Product_Domain__c,Product_type__c FROM Opportunity WHERE Id =: OpptyID]);
       
                String accid=oppMap.get(OpptyID).Accountid;
        if(oppMap.get(OpptyID).Product_type__c == 'Modular'){
                list<Partner_of_Record__c> partnerRecList=[Select id,Name,Partner__r.Name,Partner__r.Account_Status__c,TLS_ProductDomain__c,Customer__c,Partner__c,Partner__r.State_Coverage__c,Partner__r.Customer_Trading_Name__c,Product_Domain__c,End_Date__c from Partner_of_Record__c where Customer__c=:accid and por_status__c='Active'];
                
                for (Partner_of_Record__c POR: partnerRecList) {
                    PartnerResults partnerrec = new PartnerResults();
                    partnerrec.Id = POR.Partner__c;
                    partnerrec.accountName=POR.Partner__r.Name;
                    partnerrec.porProductDomain=POR.TLS_ProductDomain__c;
                    //partnerrec.porProductDomain=POR.Product_Domain__c;                    
                    //partnerrec.account=POR.Partner__c;
                    partnerrec.stateCoverage=POR.Partner__r.State_Coverage__c;
                    partnerrec.porAgreementEnddate=POR.End_Date__c;
                    partnerrec.isPartner = POR.Partner__r.Account_Status__c == PRMConstants.PRM_Account_Status_Active ? 'Yes' : 'No'; 
                    PartnerResultslist.add(partnerrec);
               }
            }
               
     
        system.debug('PartnerResultslist'+PartnerResultslist);
        return PartnerResultslist;

    }
   
  /* 13-Feb-2020 - P2OB-4628 - Created wrapper class to get custom setting */
  public class DistributorModelSettingWrapper {
      @auraEnabled
      public boolean isEnabled {get;set;}
      /*
      @auraEnabled
      public String onboardedPartnerMessage {get;set;} // errorMessage 11
      @auraEnabled
      public String nonOnboarderTaggedPartnerMessage {get;set;} // errorMessage 12
      @auraEnabled
      public String nonOnboarderNominateMessage {get;set;} // errorMessage 13
      @auraEnabled
      public String nonOnboarderPartnerErrorMessage {get;set;} // errorMessage 14
      */
      @auraEnabled
      public String closedOpportunityError {get;set;} // v1.5errorMessage 15
      @auraEnabled
      public String sharedWithPartnerError {get;set;} // v1.5 errorMessage 16
      @auraEnabled
      public String partnerCreatedError {get;set;} // v1.5 errorMessage 17
      @auraEnabled
      public String opportunityOwnerInactiveError {get;set;} // v2.0 errorMessage 14
       
  }
  
  /* 13-Feb-2020 - P2OB-4628 - Created wrapper class to get custom setting */
  public class PRMOpportunityPartnerAutoTaggingWrapper{
      @auraEnabled
      public boolean isActive {get;set;}
      @auraEnabled
      public String onboardedPartnerMessage {get;set;} // errorMessage 1
      @auraEnabled
      public String nonOnboarderTaggedPartnerMessage {get;set;} // errorMessage 2
      @auraEnabled
      public String nonOnboarderNominateMessage {get;set;} // errorMessage 3
      @auraEnabled
      public String nonOnboarderPartnerErrorMessage {get;set;} // errorMessage 4 
      @auraEnabled
      public String noPartnerUserErrorMessage {get;set;} // errorMessage 5
  }

}
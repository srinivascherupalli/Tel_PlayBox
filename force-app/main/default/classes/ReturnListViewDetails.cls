/*******************************************************************
@Class Name     :   ReturnListViewDetails
@Sprint         :   20.06  & P2OB-5923
@Author         :   SFO Team (Sri)
@CreateDate     :   22/04/2020
@Description    :   To Fetch the NBA recomended listviews .
@References     :   navigateToListViewFromHomePage(Lightning Web Component)
@TestCoverage   :   ReturnListViewDetailsTest
@Updated        :   20.07 & P2OB-6502 & P2OB-6501
@Last Modified        : 07/01/2021 21.01 by sravanthi, Team SFO
                        as part of P2OB-9943/P2OB-6772 Removing Commented Code, debug Statements and updating API version to 50.
*********************************************************************/
public without sharing class ReturnListViewDetails {
    private static String conStatusActive='Active';
    private static String accStatusRetired='Retired';
    private static List<ListViewInfo> listViewInfoList=new List<ListViewInfo>();
    private static Map<String,ListView> mapListViewDevNames = new Map<String,ListView>();
    
    private static List<Opportunity> partnerOppsList = new List<Opportunity>();
    private static List<Account> accountsHealthCheckList = new List<Account>();
    private static List<Account> accountsTelstraConnectList = new List<Account>();
    private static List<Contact> lastVerifedContactsList = new List<Contact>();
    private static List<Contact> inValidEmailContactsList = new List<Contact>();
    
/****************************************************************************
@Method Name:	getNBAListViewsInfo
@Sprint 	:	20.06  & P2OB-5923
@CreateDate	: 	22/04/2020
@Description: 	To Fetch the NBA recomended listviews
@References : 	navigateToListViewFromHomePage(Lightning Web Component)
Output		: 	List of Wrapper Class(ListViewInfo).
@Updated    :   20.07 & P2OB-6502, modularized and renamed as per the funcationality
******************************************************************************/
	@AuraEnabled
	public static List<ListViewInfo> getNBAListViewsInfo() {
        Map<String,NBA_List_View__mdt> mapMDTListViewDevNames = new Map<String,NBA_List_View__mdt>();
        try{
            //To update the account Recent_Activity_Date__c based on the tasks related to it
            setAccountHealthCheckDate();

            //To get the list view information from custom metadata 
            for(NBA_List_View__mdt mdtLV : [Select ListView_DevloperName__c, ListView_Label__c, ListView_Multi_Recs_Label__c,ListView_Icon__c, Active__c, Priority__c from NBA_List_View__mdt where Active__c = true order by Priority__c asc]){
                	mapMDTListViewDevNames.put(mdtLV.ListView_DevloperName__c,mdtLV);
            }	
            //To get the list view information from ListView Object
            for(ListView lv: [SELECT DeveloperName,Id,Name,SobjectType FROM ListView WHERE DeveloperName in :mapMDTListViewDevNames.keySet()]){
                mapListViewDevNames.put(lv.DeveloperName, lv);
            }
            Boolean isAccountNBAActive =(mapMDTListViewDevNames.containsKey(System.Label.NBA_Reach_Out_to_the_Customer) || mapMDTListViewDevNames.containsKey(System.Label.NBA_Reach_Out_to_the_Customer_TConnect));
            Boolean isContactNBAActive =(mapMDTListViewDevNames.containsKey(System.Label.NBA_Next_Best_Action_Invalid_Email_Contact) || mapMDTListViewDevNames.containsKey(System.Label.NBA_Not_Verified_Contacts));
            //Start Metadata Active Check
            //Following If conditions are to check whether the respective listviews are active in the metadata or not
            if(isAccountNBAActive){
            	checkNBAForAccounts();            
            }
            if(isContactNBAActive){
	            checkNBAForContacts();            
            }
            if(mapMDTListViewDevNames.containsKey(System.Label.NBA_Partner_Created_Opportunites)){
            	checkNBAForOpportunities();
            }
            //End Metadata Active Check: 
            
            //To set the listviewinformation into the listViewInfoList    
            setListViewInfoList(mapMDTListViewDevNames);            
        }catch(Exception ex){
            system.debug('Exception in getNBAListViewsInfo method ::: '+ex.getMessage());
        }
        if(listViewInfoList.isEmpty()){
            listViewInfoList = null;
        }
        return listViewInfoList;
    }

/****************************************************************************
@Method Name:   setListViewInfoList
@Sprint     :   20.07  & P2OB-6502
@CreateDate :   14/05/2020
@Description:   To add ListViewInfo to ListViewInfoList 
@References :   getNBAListViewsInfo
******************************************************************************/
    public static void setListViewInfoList(Map<String,NBA_List_View__mdt> mapMDTListViewDevNames){
        listViewInfoList = new List<ListViewInfo>();
        ListView lv ;
        ListViewInfo lvInf;
        String listViewDevName;
        Boolean isVerfiedContacts;
        Boolean isInvalidemailContacts;
        Boolean isReachoutCustomersHealthCheck;
        Boolean isReachoutCustomersTConnect;
        Boolean isPartnerOppApproval;
        
        try{
            //To set the visibility and name for the listview based the respective list size
            for(NBA_List_View__mdt metaInfoOfLV :mapMDTListViewDevNames.values()){ //for Start
                listViewDevName = metaInfoOfLV.ListView_DevloperName__c;
                isVerfiedContacts = (listViewDevName == System.Label.NBA_Not_Verified_Contacts && lastVerifedContactsList.size()>0);
                isInvalidemailContacts = (listViewDevName == System.Label.NBA_Next_Best_Action_Invalid_Email_Contact && inValidEmailContactsList.size()>0 );
                isReachoutCustomersHealthCheck = (listViewDevName ==System.Label.NBA_Reach_Out_to_the_Customer && accountsHealthCheckList.size()>0 );
                isReachoutCustomersTConnect = (listViewDevName ==System.Label.NBA_Reach_Out_to_the_Customer_TConnect && accountsTelstraConnectList.size()>0 );
                isPartnerOppApproval = (listViewDevName ==System.Label.NBA_Partner_Created_Opportunites && partnerOppsList.size()>0 );
                lv = mapListViewDevNames.get(listViewDevName);
                if(lv != null){
                    lvInf=new ListViewInfo();
                    lvInf.listViewId=lv.Id;
                    lvInf.objectName=lv.SobjectType;
                    lvInf.listViewIcon = metaInfoOfLV.ListView_Icon__c;
                    lvInf.listViewVisibility = metaInfoOfLV.Active__c;
                    if(isVerfiedContacts){
                        listViewInfoList.add(setListViewName(lvInf,lastVerifedContactsList.size(),metaInfoOfLV));
                    }
                    else if(isInvalidemailContacts){
                        listViewInfoList.add(setListViewName(lvInf,inValidEmailContactsList.size(),metaInfoOfLV));
                    }
                    else if(isReachoutCustomersHealthCheck){
                        listViewInfoList.add(setListViewName(lvInf,accountsHealthCheckList.size(),metaInfoOfLV));
                    }
                    else if(isReachoutCustomersTConnect){
                        listViewInfoList.add(setListViewName(lvInf,accountsTelstraConnectList.size(),metaInfoOfLV));
                    }
                    else if(isPartnerOppApproval){
                        listViewInfoList.add(setListViewName(lvInf,partnerOppsList.size(),metaInfoOfLV));
                    }
                }
            }//for end
        }catch(Exception ex){
            system.debug('Exception in setListViewInfoList method ::: '+ex.getMessage());
        }
    }
/****************************************************************************
@Method Name:   setListViewName
@Sprint     :   20.07  & P2OB-6501
@CreateDate :   24/05/2020
@Description:   To add ListViewName to ListViewInfoList
@References :   setListViewInfoList
******************************************************************************/
    public static ListViewInfo setListViewName(ListViewInfo lvInf,Integer recListLength,NBA_List_View__mdt metaInfoOfLV) {
        if(recListLength==1){
            lvInf.listViewName = metaInfoOfLV.ListView_Label__c;
        }
        else{
            lvInf.listViewName = metaInfoOfLV.ListView_Multi_Recs_Label__c.replace('numrec', recListLength+'');
        }
        return lvInf;
    }
/****************************************************************************
@Method Name:   checkNBAForAccounts
@Sprint     :   20.07  & P2OB-6502
@CreateDate :   14/05/2020
@Description:   To check the NBA recommendation on Accounts for the current user
@References :   getNBAListViewsInfo
@Updated    :   20.07 & P2OB-6501, Added functionality for Tconnect Accounts.
******************************************************************************/
    public static void checkNBAForAccounts() {
        try{
			accountsHealthCheckList = new List<Account>();
			accountsTelstraConnectList = new List<Account>();
            List<Account> accountsList = new List<Account>();
            String recordTypeContains='%'+system.label.Account_RecordType_Enterprise+'%';
            String checkNBAForAccountsQuery = 'select id, Name,APTPS_Tier__c, Recent_Activity_Date__c, Reaching_out_to_Customer__c  from Account where ((Reaching_out_to_Customer__c = true and APTPS_Tier__c != \''+ string.escapeSingleQuotes(system.label.AccountSegmentEntAndGovt)+'\') OR (Reach_out_to_Customer_Tconnect__c = false and APTPS_Tier__c = \''+ string.escapeSingleQuotes(system.label.AccountSegmentEntAndGovt)+'\')) and OwnerId = \''+string.escapeSingleQuotes(UserInfo.getUserId())+'\' and Customer_Status__c != \'' +string.escapeSingleQuotes(accStatusRetired) +'\' and RecordType.name like \'' +string.escapeSingleQuotes(recordTypeContains) +'\' and Parent_CIDN__c = null AND Ultimate_Parent_CIDN__c = null';
            accountsList = Database.query(checkNBAForAccountsQuery);
            if(!accountsList.isEmpty()){
                for(Account acc : accountsList){
                    if(acc.APTPS_Tier__c == system.label.AccountSegmentEntAndGovt){
                        accountsTelstraConnectList.add(acc);
                    }
                    else{
                        accountsHealthCheckList.add(acc);
                    }
                }
            }
        }catch(System.QueryException ex){
            system.debug('Exception in checkNBAForAccounts method ::: '+ex.getMessage());
        }        
    }
/****************************************************************************
@Method Name:   checkNBAForContacts
@Sprint     :   20.07  & P2OB-6502
@CreateDate :   14/05/2020
@Description:   To check the NBA recommendation on Contacts for the current user
@References :   getNBAListViewsInfo
******************************************************************************/
    public static void checkNBAForContacts() {
        try{
            String checkNBAForContactsQuery = 'SELECT Id, Phone,Relationship_Verified_Date__c,Contact_Status__c,Email_status__c,isEmailBounced,lastVerifiedDate__c from Contact where  OwnerId = \''+string.escapeSingleQuotes(UserInfo.getUserId())+'\' and Contact_Status__c = \'' +string.escapeSingleQuotes(conStatusActive) +'\' and RecordType.name =\'' +string.escapeSingleQuotes(system.label.Contact_layout_record_type) +'\'';
            List<Contact> contactList = new List<Contact>();
            inValidEmailContactsList = new List<Contact>();
            lastVerifedContactsList = new List<Contact>();
            contactList = Database.query(checkNBAForContactsQuery);Database.query(checkNBAForContactsQuery);
            
            //To seperate invalid email contacts and last verified contacts
            for(Contact con :contactList){ 
                if(con.Email_status__c || con.isEmailBounced) {
                    inValidEmailContactsList.add(con);
                }
                if(con.lastVerifiedDate__c < Date.today().addDays(-180) ) {
                    lastVerifedContactsList.add(con);
                }
            } //for end
        }catch(System.QueryException ex){
            system.debug('Exception in checkNBAForContacts method ::: '+ex.getMessage());
        }        
    }
/****************************************************************************
@Method Name:   checkNBAForOpportunities
@Sprint     :   20.07  & P2OB-6502
@CreateDate :   14/05/2020
@Description:   To check the NBA recommendation on Opportunities for the current user
@References :   getNBAListViewsInfo
******************************************************************************/
    public static void checkNBAForOpportunities() {
        try{
            // Sprint 20.08, P2OB-7438 .Adding additional Filter in SOQL Queries because Recommendations should not be shown for Closed WON/LOSS and Cancelled Opportunities.
            partnerOppsList = [SELECT id,Partner_Opportunity_Verification__c from Opportunity WHERE account.ownerid =: userInfo.getUserId() and Partner_Opportunity_Verification__c =:system.label.Opp_PartnerOppVer_VerfRequired and StageName !=: System.Label.Opp_Stage_ClosedWon and StageName !=: System.Label.Opp_Stage_ClosedLost and StageName !=: System.Label.Opp_Stage_Cancelled];   
        }catch(System.QueryException ex){
            system.debug('Exception in checkNBAForOpportunities method ::: '+ex.getMessage());            
        }        
    }

    
/****************************************************************************
@Method Name:   setAccountHealthCheckDate
@Sprint     :   20.06  & P2OB-5923
@CreateDate :   22/04/2020
@Description:   To update the account Recent_Activity_Date__c based on the tasks related to it
@References :   getNBAListViewsInfo
******************************************************************************/
public static void setAccountHealthCheckDate() {
    Id accId;
    Date healthCheckDate;
    Datetime healthCheckDatetime;
    Account acc = new Account();
    Map<id,Account>  accountsMap = new Map<id,Account>();
    List<Account>  accListToUpdate = new List<Account>();
    
    try{
        for(Account acct:[select id, Name, Recent_Activity_Date__c, Reaching_out_to_Customer__c  from Account where Customer_Status__c !=:accStatusRetired and OwnerId =:UserInfo.getUserId() and RecordType.name =:system.label.Account_RecordType_Enterprise]){
            if(acct.Recent_Activity_Date__c == null) accountsMap.put(acct.id,acct);
        }        
        String emailFilter = '%' +System.Label.Task_Subject_Email+'%';
        String callFilter = '%' +System.Label.Task_Call_not_Successful+'%';
        AggregateResult[] taskResult = [SELECT Max(CreatedDate),AccountId FROM Task WHERE AccountId in:accountsMap.keySet()  AND (NOT Subject LIKE :emailFilter) AND (NOT Subject LIKE :callFilter)  GROUP BY AccountId];
        //To set the most recent date of account's task to account's Recent_Activity_Date__c
        for (AggregateResult tr : taskResult)  { // for start
            accId = (Id) tr.get('AccountId');
            healthCheckDatetime = (Datetime) tr.get('expr0');
            healthCheckDate = healthCheckDatetime.Date();
            acc = accountsMap.get(accId);
            acc.Recent_Activity_Date__c = healthCheckDate;
            accListToUpdate.add(acc);
        } // for end
        if(accListToUpdate.size()>0){
            Database.SaveResult[] sr = Database.update(accListToUpdate, false);
        }
    }catch(Exception ex){
        system.debug('Exception in setAccountHealthCheckDate method ::: '+ex.getMessage());
    }
}

/*******************************************************************
@Class Name :   ListViewInfo
@Sprint     :   20.06  & P2OB-5923
@CreateDate :   22/04/2020
@Description:   To wrap and send the listview information to LWC
*********************************************************************/
    public class ListViewInfo{
        @AuraEnabled
        Public String listViewId {get;set;}
        @AuraEnabled
        Public String listViewName {get;set;}
        @AuraEnabled
        Public String objectName {get;set;}
        @AuraEnabled
        Public Boolean listViewVisibility {get;set;}
        @AuraEnabled
        Public String listViewIcon {get;set;}
    }
}
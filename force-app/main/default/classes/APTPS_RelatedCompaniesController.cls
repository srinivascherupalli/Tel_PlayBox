public with sharing class APTPS_RelatedCompaniesController {
    
    //Added By Apttus Managed Services for Case#00212472 
    public String searchString {get;set;}
    
    public list<APTPS_RelatedCompaniesWrapper> relAccWrapperList{ get; set; }
    public list<APTPS_RelatedCompaniesWrapper> unrelAccWrapperList{ get; set; } 
    public static List<Account> accountHierarchyList = new List<Account>();
    public static Map<ID,Integer> accountIdLevelMap = new Map<ID,Integer>();
    public static Map<ID,List<Account>> parentChildLinkedListMap = new Map<ID,List<Account>>();
    public static Map<ID,Account> accountDetailsMap = new Map<ID,Account>(); 
    public id agreementId  = apexpages.currentpage().getparameters().get('id');
    public Set<Account> relatedAccountSet;
    public Set<Id> unrelatedAccountSet;
    public boolean emptyRCsection {get;set;}
    public boolean emptyUCsection {get;set;}
    //new fields
    public Integer RecPerPageRC {get; set;}
    public Integer RecPerPageUC {get; set;}
    public list<SelectOption> RecPerPageOption {get; set;}  
    public list<String> AlphaList {get; set;}
    public String selAlphaRC {get; set;}
    public String selAlphaUC {get; set;}
    private String RCQuery;
    private String UCQuery;
    public static Set<Id> rcIDSet;
    public Integer noRCRecords{get; set;}
    public Integer noUCRecords{get; set;}
    public boolean showRelatedCompanies{get; set;}
    public boolean showUnrelatedCompanies{get; set;}
    public Set<id> selectedAccounts;
    public APTPS_RelatedCompaniesWrapper selWrapper {get;set;}
    public APTPS_RelatedCompaniesController(ApexPages.StandardSetController controller) {     
        emptyRCsection = false;
        emptyUCsection = false;  
        showRelatedCompanies = false;
        showUnrelatedCompanies = false;
        //new addition for pagination
        RecPerPageOption = new list<SelectOption>();
        RecPerPageOption.add(new SelectOption('10','10')); //10 values changed for testing with smaller lists
        RecPerPageOption.add(new SelectOption('25','25')); //25
        RecPerPageOption.add(new SelectOption('50','50')); //50
        RecPerPageOption.add(new SelectOption('100','100')); //100
        RecPerPageOption.add(new SelectOption('200','200')); //200
        RecPerPageRC = RecPerPageUC = 10; //default records per page
        AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            selAlphaRC = selAlphaUC = 'All';
        } else {
            selAlphaRC = selAlphaUC = apexpages.currentpage().getparameters().get('alpha');
        }   
        fetchRelatedAccounts();    
        BuildQuery();
    }
    public void fetchRelatedAccounts(){
        Apttus__APTS_Agreement__c agmtRecord = [Select id, RecordType.name, Apttus__Account__c,Apttus__Agreement_Category__c, APTPS_Agreement_Subcategory__c,APTPS_Unrelated_Companies__c 
                                                    from Apttus__APTS_Agreement__c where id = : agreementId limit 1];
        if(agmtRecord.RecordType.name == 'SA')
        {
            if((agmtRecord.Apttus__Agreement_Category__c == 'Business Services' || agmtRecord.Apttus__Agreement_Category__c == 'Managed Services') && agmtRecord.APTPS_Agreement_Subcategory__c == 'Company Group'){
                showRelatedCompanies = true;
                if(agmtRecord.APTPS_Unrelated_Companies__c == true){
                    showUnrelatedCompanies = true;
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.info,'Please select Unrelated Companies checkbox to add Unrelated Companies.');
                    ApexPages.addMessage(myMsg);
                }
            }
            else{
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.fatal,'Please select Agreement Category as Business Services or Managed Services and Subcategory as Company group to add Related Companies.');
                ApexPages.addMessage(myMsg);
            }
        }
        else if(agmtRecord.RecordType.name == 'Service Trial' || agmtRecord.RecordType.name == 'Supporting Agreement')
        {
            showRelatedCompanies = true;
            showUnrelatedCompanies = false;
        }
        else
        {
            showRelatedCompanies = true;
            showUnrelatedCompanies = true;
        }
        Id associatedAccount = agmtRecord.Apttus__Account__c;
        
        relAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();
        unrelAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();                               
        relatedAccountSet = new Set<Account>();   
        if(associatedAccount != null){       
            Account associatedAccRec = [Select Id, Name, ABN__c, CIDN__c, Parent.id, Parent.Parent.id, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id =: associatedAccount];
            //fetching parent, parent's siblings & own siblings
            set<id> parentAccSet = new set<id>();
            //fetches all existing Related Companies for the Agreement record.
            List<APTPS_Related_Companies__c> existingRelCompaniesList = [Select Id, APTPS_Agreement__c, APTPS_Account__c from APTPS_Related_Companies__c where APTPS_Agreement__c =: agreementId];
            Set<Id> existingRelCompaniesSet = new Set<Id>();
            for(APTPS_Related_Companies__c relComp : existingRelCompaniesList){         
                if(relComp.APTPS_Account__c != null){
                    existingRelCompaniesSet.add(relComp.APTPS_Account__c);
                }
            }
            //will add parent and grand parent account record to the set
                       
            if(associatedAccRec.parent.id != null){
                parentAccSet.add(associatedAccRec.parent.id);
            }
            
            if(associatedAccRec.parent.parent.id != null){
                parentAccSet.add(associatedAccRec.parent.parent.id);
            }
            //fetches all the siblings of parent and itself
            if(!parentAccSet.isEmpty()){
                List<Account> siblingAcc = [Select id, name, ABN__c, CIDN__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode  from Account where parent.id IN : parentAccSet]; 
                relatedAccountSet.addAll(siblingAcc);                
            }
            //fetches all the child grandchild and so on of the Associated account till the lowest level
            List<Account> childAccountList = new List<Account>();
            childAccountList = getAllChildAccounts(associatedAccount);
            for(account acc: childAccountList){
                relatedAccountSet.add(acc);
            }
            //remove the Agreement associated Account from the set.
            for(account acc : relatedAccountSet){
                if(acc.id == associatedAccRec.id || existingRelCompaniesSet.contains(acc.id)){ 
                   relatedAccountSet.remove(acc);
                }
            }         
            List<Account> unrelAccList = new List<Account>();
            //fetching all accounts other than the related accounts.
            unrelAccList = [Select Id, Name, ABN__c, CIDN__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account where id NOT IN : relatedAccountSet ORDER BY createddate asc LIMIT 10000];
            unrelatedAccountSet = new set<id>();
            for(account acc : unrelAccList){
                //not add the associated account to the set.
                if(acc.id != associatedAccRec.id && !existingRelCompaniesSet.contains(acc.id)){
                    unrelatedAccountSet.add(acc.id);
                }
            }
        }
    }      
    public static List<Account> getAllChildAccounts(Id parentAcctId) {    
        Boolean endTraversing = false;
        Integer accountLevel = 0;
        Set<ID> parentIdList = new Set<ID>();
        String query;
        List<Account> acctList = new List<Account>();
        parentIdList.add(parentAcctId);
        while(!endTraversing) {
            if(accountLevel == 0) {
                query = 'select Id, Name, ParentId, CIDN__c, ABN__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode from Account WHERE Id IN :parentIdList';
            } else {
                query = 'select Id, Name, ParentId, CIDN__c, ABN__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode  from Account WHERE ParentId IN :parentIdList';
            }
            acctList = Database.query(query);
            if(acctList.size() == 0 ) {
                endTraversing = true;
            }
            else{
                parentIdList.clear();
                acctList.sort();
                Account a;
                for(Integer i = 0; i < acctList.size(); i++ ) {
                    a = acctList.get(i);
                    parentIdList.add(a.Id); 
                    accountIdLevelMap.put(a.Id, accountLevel);
                    accountDetailsMap.put(a.Id, a);
                    if(accountLevel > 0) {
                        if(parentChildLinkedListMap.get(a.ParentId) == null) {
                            parentChildLinkedListMap.put(a.ParentId, new List<Account>()); 
                        }
                        parentChildLinkedListMap.get(a.ParentId).add(a);
                        parentChildLinkedListMap.get(a.ParentId).sort();
                    }
                }
                accountLevel++;
            }
        }
        //calls below method
        addChildAccountsToList(parentAcctId);
        return accountHierarchyList;
    }
    //method recursively called
    @TestVisible private static void addChildAccountsToList(Id parentAccountId) {
        Account a = accountDetailsMap.get(parentAccountId);
        accountHierarchyList.add(a);
        List<Account> childAccounts = parentChildLinkedListMap.get(parentAccountId);
        if(childAccounts != null) {
            childAccounts.sort();
            for(Account acct : childAccounts) {
                addChildAccountsToList(acct.Id);
            }
        }
        return;
    }  
    public String getagreementId() {
        return agreementId;
    }
    //method inserts all the accounts which are checked for addition to the record.
    public Pagereference insertRelatedCompanies(){
        List<Account> addList = new List<Account>();
        List<APTPS_Related_Companies__c> relCompList = new List<APTPS_Related_Companies__c>();
        List<APTPS_RelatedCompaniesWrapper> selWrapperList = new List<APTPS_RelatedCompaniesWrapper>();
        selWrapperList.addAll(relAccWrapperList);
        selWrapperList.addAll(unrelAccWrapperList);
        boolean anySelected = false;
        for(APTPS_RelatedCompaniesWrapper selAcc : selWrapperList){
            if(selAcc.isSelected == true){
                APTPS_Related_Companies__c relComRecord = new APTPS_Related_Companies__c();
                relComRecord.APTPS_Agreement__c = agreementId;
                relComRecord.APTPS_Account__c = selAcc.accnt.id;
                relCompList.add(relComRecord);
                anySelected = true;
            }
        }
        //throws error if there are no selected accounts while clicking Add button
        if(anySelected == false && emptyRCsection == false && emptyUCsection == false){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.fatal,'Select atleast one Related or Unrelated Company to be added');
            ApexPages.addMessage(myMsg);
            return null;
        }
        insert relCompList;
        //returns to the Agreement record page.
        PageReference homePage= new PageReference('/'+agreementId); 
        homePage.setRedirect(true);
        return homePage;
    }
       
    //For Pagination
    //Builds the base query
    public void BuildQuery() {
        relAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();
        unrelAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();  
        setConRC = setConUC = null;   
        rcIDSet = new Set<Id>();
        for(Account acc : relatedAccountSet){
            rcIDSet.add(acc.id);
        }
        string baseQuery = 'select Id, Name, ParentId, CIDN__c, ABN__c, BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode  from Account Where Id IN :';
        RCQuery = baseQuery + 'rcIDSet ' + buildWhere(selAlphaRC); 
        //To add the search string in query
        UCQuery = baseQuery + 'unrelatedAccountSet ' + buildWhereForSearch(searchString);
        //To add where clause and order by clause in the query
        UCQuery = UCQuery  + buildWhere(selAlphaUC) + buildSortString();
        System.debug(UCQuery);
    }
    
    //builds the where clause for the query
    public string buildWhere(string AlphaFilterPassed){      //EDGE-69042 Sonar Fix New variable 
        String QueryWhere = '';
        String AlphaFilter = AlphaFilterPassed;  //EDGE-69042 Sonar Fix New variable 
        if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        }
        if (AlphaFilter == 'Other') {
            QueryWhere += ' AND ' + '(' + ' Name ' + ' < \'A\' OR ' + 
                                    ' Name ' + ' > \'Z\') AND (NOT ' + 
                                    ' Name ' + ' LIKE \'Z%\') ';
        } else if (AlphaFilter != 'All') {
            QueryWhere += ' AND ' + '(' + ' Name ' + ' LIKE \'' + String.escapeSingleQuotes(AlphaFilter) + '%\')';
        }
        
        return QueryWhere;
    }
    
    /**Added By Apttus Managed Services for Case#00212472 
    *--------------------------start----------------------
    */
    public String buildWhereForSearch(string searchStringPassed){   //EDGE-69042 Sonar Fix New variable 
        String whereForSearchStr = '';
        String searchString = searchStringPassed;   //EDGE-69042 Sonar Fix New variable 
        if(!String.isBlank(searchString)){
            searchString = searchString.trim();
            //Support '*' as a wild character 
            if(searchString.contains('*')){
                searchString = searchString.replaceAll('\\*', '%');
            }
            //Support '?' as a wild character           
            if(searchString.contains('?')){
                searchString = searchString.replaceAll('\\?', '_');
            }
        }
        
        if(!String.isBlank(searchString)){
            whereForSearchStr = ' AND Name Like \'%' + searchString + '%\'';
        }
        return whereForSearchStr;
    }
    
    public String buildSortString(){
        //build the full sort expression
        String sortFullExp = sortExpression  + ' ' + sortDirection;
        
        String sortString = ' ORDER BY ' + sortFullExp + ' LIMIT 5000';
        
        return sortString;
    }
    
    //Default Direction
    private String sortDirection = 'ASC';
    //Default Column
    private String sortExp = 'name';    
    
    public String sortExpression{
        get{return sortExp;}
        set{
            //if the column is clicked on then switch between Ascending and Descending modes
            if (value == sortExp)
                sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
            else
                sortDirection = 'ASC';
            sortExp = value;
        }
    }
    
    public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '')
            return 'ASC';
        else
            return sortDirection;
    }
    
    public void setSortDirection(String value){  
        sortDirection = value;
    }
    
    public Boolean getUCsectionMoreThanFiveK1(){
        String str1 = buildWhereForSearch(searchString);
        String str2 = buildWhere(selAlphaUC);
        String str3 = buildSortString();
        
        System.debug('getUCsectionMoreThanFiveK called');
        String countQueryStr = 'SELECT COUNT() FROM Account Where Id IN :unrelatedAccountSet'+ str1 + str2;
        
        System.debug('countQuery' + countQueryStr);
        Integer accCount = Database.countQuery(countQueryStr);
        
        System.debug('Acc size: ' + accCount);
        if(accCount > 5000){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'Your search result returned more than 5000 companies. Please refine your search further if you need to.'));
            return true;
        }else return false;
    }
    
    /**Added By Apttus Managed Services for Case#00212472 
    *--------------------------end------------------------
    */
    
    //for related companies
    public ApexPages.StandardSetController setConRC {
        get {
            if(setConRC == null) {
                setConRC = new ApexPages.StandardSetController(Database.getQueryLocator(RCQuery));
                // sets the number of records in each page set
                setConRC.setPageSize(RecPerPageRC);
                noRCRecords = setConRC.getResultSize();
            }
            return setConRC;
        }
        set;
    }
    public Boolean getRCrecordsFound() {
        if (setConRC != null && setConRC.getRecords().size() > 0) {
            emptyRCsection = false;        
        }
        else{
            emptyRCsection = true;
        }
        return emptyRCsection;
    }
    public list<APTPS_RelatedCompaniesWrapper> getCurrentRCAccountList() {
        relAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();
        for (Account acc : (list<Account>)setConRC.getRecords()) {
            relAccWrapperList.add(new APTPS_RelatedCompaniesWrapper(acc));
            
        }
        return relAccWrapperList;
    }
    //for unrelated companies
    public ApexPages.StandardSetController setConUC {
        get {
            if(setConUC == null) {
                
                System.debug('UCQuery 2: '+ UCQuery);
                
                setConUC = new ApexPages.StandardSetController(Database.getQueryLocator(UCQuery));
                // sets the number of records in each page set
                setConUC.setPageSize(RecPerPageUC);
                noUCRecords = setConUC.getResultSize();
            }
            return setConUC;
        }
        set;
    }
    public Boolean getUCRecordsFound() {
        if (setConUC != null && setConUC.getRecords().size() > 0) {
            emptyUCsection = false;        
        }
        else{
            emptyUCsection = true;
        }
        return emptyUCsection;
    }
    public list<APTPS_RelatedCompaniesWrapper> getCurrentUCAccountList() {
        unrelAccWrapperList = new list<APTPS_RelatedCompaniesWrapper>();
        for (Account acc : (list<Account>)setConUC.getRecords()) {
            unrelAccWrapperList.add(new APTPS_RelatedCompaniesWrapper(acc));
            System.debug('Account' + acc.Name);
        }
        return unrelAccWrapperList;
    }
    public Pagereference selectedAccounts(){
    
        return null;
    }
}
/****************************************************************************
@Author: Nilesh Dethe
@CreateDate: 08/08/2018
@Story: EDGE-31363
@Description: AdvanceCustomerSearchController server side controller class for holding bussiness logic related to AdvanceCustomerSearch lightning component which is created under EDGE-31363.
@TestCoverageClass: AdvanceCustomerSearchControllerTest
@ChangeLog: v1: Created
********************************************************************************/
public with sharing class AdvanceCustomerSearchController {
    //EDGE-31363
    private static final String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
    private static final Integer UPPER_LIMIT = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
    private static String callOutExceptionMessage;
    //EDGE-31363: Wrapper class for pagingation
    public class CustomerPagerWrapper {
        public void CustomerPagerWrapper(){}
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
        @AuraEnabled public Boolean isTCMSearchResults {get;set;}
        @AuraEnabled public List<Account> lstCustomer {get;set;}
        @AuraEnabled public String ErrorMessage {get;set;}
    }
    
    //EDGE-31363: Wrapper Class for Search filter Criteria
    public class SearchFilterCriteria {
        public void SearchFilterCriteria(){}
        @AuraEnabled public String customerName {get;set;}
        @AuraEnabled public String abn {get;set;}
        @AuraEnabled public String acn {get;set;}
        @AuraEnabled public String cidn {get;set;}
    }
    
    
    
    @AuraEnabled //EDGE-31363
    public static CustomerPagerWrapper searchCustomer(Decimal pageNumber ,Integer recordToDisply, String searchCriteria) {
        final Integer pageSize = recordToDisply;
        final Integer offset = ((Integer)pageNumber - 1) * pageSize;
        CustomerPagerWrapper custPagerWrapObj =  new CustomerPagerWrapper();
        final SearchFilterCriteria srchCriteria = null;
        system.debug('searchCriteria >' +searchCriteria);
        if(string.isNotBlank(searchCriteria)){
            srchCriteria = (SearchFilterCriteria)JSON.deserializeStrict(searchCriteria, SearchFilterCriteria.class);
        }
        system.debug('srchCriteria >' +srchCriteria);
        if(srchCriteria != null){
            custPagerWrapObj = searchCustomerInSFDC(srchCriteria,pageSize,offset);
            if(custPagerWrapObj.lstCustomer == null || custPagerWrapObj.lstCustomer.isEmpty()){
                custPagerWrapObj = searchCutomerInTCM(srchCriteria,pageSize,offset);
            } 
        }
        
        if(custPagerWrapObj.lstCustomer != null && !custPagerWrapObj.lstCustomer.isEmpty()){    
            // set the pageSize,Page(Number), total records and accounts List(using OFFSET)   
            custPagerWrapObj.pageSize = pageSize;
            custPagerWrapObj.page = (Integer) pageNumber;
            system.debug('Inside searchCustomer -> custPagerWrapObj >> '+ custPagerWrapObj);
        } else{
            custPagerWrapObj.ErrorMessage = (String.isNotBlank(callOutExceptionMessage))? callOutExceptionMessage:null;
        }
        
        // return the wrapper class instance .
        return custPagerWrapObj;
    }
    
    //EDGE-31363
    public static CustomerPagerWrapper searchCustomerInSFDC(SearchFilterCriteria criteria, Integer pageSize, Integer offset){
        List<Account> lstAcc = new List<Account>();
        system.debug('Inside searchCustomerInSFDC -> criteria >> '+ criteria);
        system.debug('Inside searchCustomerInSFDC -> offset >> '+ offset);
        system.debug('Inside searchCustomerInSFDC -> pageSize >> '+ pageSize);
        Integer totalRecordsFound=0;
        
        if(String.isNotBlank(criteria.customerName) && String.isNotBlank(criteria.abn)
           && String.isBlank(criteria.acn) && String.isBlank(criteria.cidn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE (Name LIKE :'%'+criteria.customerName+'%' AND ABN__c = :criteria.abn)];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE (Name LIKE :'%'+criteria.customerName+'%' AND ABN__c = :criteria.abn) 
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        } 
        else if(String.isNotBlank(criteria.customerName) && String.isNotBlank(criteria.acn) 
                && String.isBlank(criteria.abn) && String.isBlank(criteria.cidn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE (Name LIKE :'%'+criteria.customerName+'%' AND ACN__c = :criteria.acn)];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE (Name LIKE :'%'+criteria.customerName+'%' AND ACN__c = :criteria.acn) 
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        } 
        else if(String.isNotBlank(criteria.customerName) && String.isBlank(criteria.acn)
                && String.isBlank(criteria.abn) && String.isBlank(criteria.cidn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE (Name LIKE :'%'+criteria.customerName+'%')];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE (Name LIKE :'%'+criteria.customerName+'%')
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        } 
        else if(String.isNotBlank(criteria.abn) && String.isBlank(criteria.acn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.cidn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE ABN__c =:criteria.abn];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE ABN__c =:criteria.abn
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        } 
        else if(String.isNotBlank(criteria.acn) && String.isBlank(criteria.abn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.cidn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE ACN__c =:criteria.acn];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE ACN__c =:criteria.acn
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        } 
        else if(String.isNotBlank(criteria.cidn) && String.isBlank(criteria.abn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.acn))
        {
            totalRecordsFound = [SELECT count() FROM Account WHERE (CIDN__c =:criteria.cidn)];
            lstAcc = [SELECT Id, Name,CIDN__c,ABN__c, ACN__c,Customer_Status__c,Type,Business_Unit__c,APTPS_Tier__c,Portfolio_Code__c,Market_Segment__c 
                      FROM Account 
                      WHERE CIDN__c =:criteria.cidn
                      ORDER BY Name LIMIT :pageSize OFFSET :offset];
        }  
        
        final CustomerPagerWrapper custPageWrap = new CustomerPagerWrapper();
        custPageWrap.total = totalRecordsFound;
        custPageWrap.lstCustomer = lstAcc;
        if(!lstAcc.isEmpty()){
            custPageWrap.isTCMSearchResults = false;
        }
        system.debug('Inside searchCustomerInSFDC -> custPageWrap >> '+ custPageWrap);
        return custPageWrap;
    }
    
    //EDGE-31363
    private static CustomerPagerWrapper searchCutomerInTCM(SearchFilterCriteria criteria, Integer pageSize, Integer offset){
        List<Account> lstAcc = new List<Account>();
        CustomerObject searchResponse = null;
        
        if(String.isNotBlank(criteria.customerName) && String.isNotBlank(criteria.abn)
           && String.isBlank(criteria.acn) && String.isBlank(criteria.cidn))
        {
            searchResponse=searchByABN(criteria.customerName,criteria.abn,offset,pageSize);
        } 
        else if(String.isNotBlank(criteria.customerName) && String.isNotBlank(criteria.acn) 
                && String.isBlank(criteria.abn) && String.isBlank(criteria.cidn))
        {
            searchResponse=searchByACN(criteria.customerName,criteria.acn,offset,pageSize);
        } 
        else if(String.isNotBlank(criteria.customerName) && String.isBlank(criteria.acn)
                && String.isBlank(criteria.abn) && String.isBlank(criteria.cidn))
        {
            searchResponse=searchByLastName(criteria.customerName,offset,pageSize);
        } 
        else if(String.isNotBlank(criteria.abn) && String.isBlank(criteria.acn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.cidn))
        {
            searchResponse=searchByABN(criteria.customerName,criteria.abn,offset,pageSize);
        } 
        else if(String.isNotBlank(criteria.acn) && String.isBlank(criteria.abn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.cidn))
        {
            searchResponse=searchByACN(criteria.customerName,criteria.acn,offset,pageSize);
        } 
        else if(String.isNotBlank(criteria.cidn) && String.isBlank(criteria.abn)
                && String.isBlank(criteria.customerName) && String.isBlank(criteria.acn))
        {
            searchResponse=searchByCIDN(criteria.cidn,offset,pageSize);
        }
        
        final CustomerPagerWrapper custPageWrap = new CustomerPagerWrapper();
        if(searchResponse != null){
            lstAcc = mapTCMCustomertoAccountObj(searchResponse);    
            custPageWrap.total = lstAcc.size();
        }
        else { 
            custPageWrap.total = 0;
        }
        custPageWrap.lstCustomer = lstAcc;
        custPageWrap.isTCMSearchResults = true;
        system.debug('Inside searchCutomerInTCM -> custPageWrap >> '+ custPageWrap);
        return custPageWrap;
    }
    
    @auraenabled //EDGE-31363
    public Static CustomerObject searchByABN(String lastName,String abn,Integer offset,Integer pageSize){  
        System.debug('!@#$% Searching by ABN : ' + abn);
        String params='';
        
        params = params + '?abn='+abn;
        if(string.isNotBlank(lastName)) 
        {
            params += '&lastName='+lastName;    
        }
        //string strOffset = string.valueOf(offset);
        return convert(doCallout(true,params,offset,pageSize));
    }
    
    @auraenabled
    public static CustomerObject searchByLastName(String lastName,Integer offset,Integer pageSize){  
        System.debug('!@#$% Searching by lastName : ' + lastName);   
        String params='';
        params = params + '?lastName='+lastName;
        //string strOffset = string.valueOf(offset);
        return convert(doCallout(true,params,offset,pageSize));
    }
    
    @auraenabled //EDGE-31363
    public static CustomerObject searchByACN(String lastName,String acn,Integer offset, Integer pageSize){  
        System.debug('Searching by ACN : ' + acn);
        String params='';
        params = params + '?acn='+acn;
        
        if(string.isNotBlank(lastName)) 
        {
            params += '&lastName='+lastName;    
        }      
        //string strOffset = string.valueOf(offset);
        return convert(doCallout(true,params,offset,pageSize));
    } 
    
    @auraenabled //EDGE-31363
    public static CustomerObject searchByCIDN(String cidn,Integer offset,Integer pageSize){  
        System.debug('!@#$% Searching by CIDN : ' + cidn);   
        String params='';
        if(string.isNotBlank(cidn)){
            params = params + '?cidn='+cidn;
        }
        //string strOffset = string.valueOf(offset);
        return convert(doCallout(true,params,offset,pageSize));
    }
    
    //EDGE-31363
    public static String doCallout(Boolean appendParams,String params,Integer offset,Integer pageSize){
        System.debug('!@#$% Attempting to do a callout to TCM');
        String result='';
        String error='';        
        Integer ofst;
        String finalParams;
        Boolean calloutUnsuccesful = false;
        system.debug('i am failing here'+calloutUnsuccesful); 
        ofst = (offset > 50)?UPPER_LIMIT:offset;
        try {
            String url;
            String token = TCMSearchManager.getTCMToken();
            //system.debug('i am failing here after Token'+ token);
            
            //system.debug('next value'+next);
            system.debug('offset value'+offset);
            IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
            url = (is.EnableMocks__c != null && is.EnableMocks__c) ? MOCK_URL : EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
            finalParams = (appendParams != null && appendParams) ? params + '&limit='+pageSize+'&offset='+ofst : params + '?limit='+pageSize+'&offset='+ofst;
            if(ofst == null) ofst = 0;
            system.debug('params'+params+finalParams);
            HttpResponse resp = TCMSearchService.callout(url+finalParams, token);
            System.debug('===+++resp'+resp);    
            String body = resp.getBody();
            System.debug('!@#$% HTTP Response Body : ' + body);
            
            //searchedOnTCM = true;
            result = body;  
            error = '';
            System.debug('result going to client'+result);
           /* if(resp.getStatusCode() != 200)
            {
                calloutUnsuccesful = true;
                //searchedOnTCM = false;
                //custPagerWrapObj.
                //throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN); 
                callOutExceptionMessage = Label.CUSTOMER_SEARCH_ERROR_TCMDOWN;
            }*/
            if(resp.getStatus()!='OK'){
                 callOutExceptionMessage = Label.CUSTOMER_SEARCH_ERROR_TCMDOWN;
            }
            //CustomerObject convertedObj = (CustomerObject)JSON.deserialize(resp.getBody(), CustomerObject.class); 
            return result;
        }
        catch(NullPointerException e)
        {
            calloutUnsuccesful = true;
            //throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
            callOutExceptionMessage = Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED;
        }
        catch(CalloutException ce) 
        {
            calloutUnsuccesful = true;
            //throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
            callOutExceptionMessage = Label.CUSTOMER_SEARCH_ERROR_TCMDOWN;
        } 
        return result;
    }
    
    @auraenabled //EDGE-31363
    public static CustomerObject convert(String result) 
    {
        CustomerObject convertedObj=null;
        String err='';
        System.debug('!@#$% Attempting to convert the result');
        system.debug('result'+result);
        if(string.isNotBlank(result))
        {
            convertedObj = (CustomerObject)JSON.deserialize(result, CustomerObject.class); 
            System.debug('!@#$% Converted Customer : ' + convertedObj);
        }
        return convertedObj;
    }
    
    //EDGE-31363: Map the TCM customer search response to account object to return it back.
    private static List<Account> mapTCMCustomertoAccountObj(CustomerObject tcmResponse){
        final List<Account> lstAccMapwithTcm = new List<Account>();
        if(tcmResponse != null && tcmResponse.Data != null){
            for(CustomerObject.Customer cust :tcmResponse.Data.customers){
                final Account newAcc = new Account(CIDN__c = cust.cidn, 
                                                   Name = cust.customerAccount.lastName,
                                                   ABN__c = cust.customerAccount.abn,
                                                   ACN__c = cust.customerAccount.acn,
                                                   Customer_Status__c = cust.accountStatus,
                                                   Type = cust.customerType,
                                                   Business_Unit__c = cust.businessUnit,
                                                   APTPS_Tier__c = '', //As this is not available in TCM and used by Eureka team on account object.
                                                   Market_Segment__c = cust.marketSegment,
                                                   Portfolio_Code__c = cust.portfolioCode);
                lstAccMapwithTcm.add(newACc);
            }
        }
        return lstAccMapwithTcm;
    }
    
    
    //EDGE-32689
    @auraEnabled
    public static string createCase(String strCustomer){
        final List<Case> lstCasetoCreate  = new List<Case>();
        List<Account> lstSelcCust = new List<Account>();
        system.debug('Inside->createCase -> strCustomer >>> ' + strCustomer);
        if(string.isNotBlank(strCustomer)){
            lstSelcCust = (List<Account>)JSON.deserialize(strCustomer, List<Account>.class);
        }
        system.debug('Inside->createCase -> lstSelcCust >>> ' + lstSelcCust);
        if(!lstSelcCust.isEmpty()){
            Id feedbackQueueId = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperNAME = 'Feedback_Queue' LIMIT 1].Id;
            Id feedbackCaseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Feedback').getRecordTypeId();
            for(Account cust :lstSelcCust){
                final Case newCase = new Case( Subject = 'Import ' + cust.CIDN__c,
                                              Feedback_Impact__c = 'Your business unit',
                                              OwnerId = feedbackQueueId,
                                              Priority = 'Medium',
                                              Status = 'New',
                                              Description = getCaseDescription(cust),
                                              Feedback_Related_to__c = 'Account',
                                              Origin = 'Feedback',
                                              RecordTypeId = feedbackCaseRTId,
                                              Feedback_Category__c = 'Import Customer'
                                             );
                lstCasetoCreate.add(newCase);
            }
        }
        
        if(!lstCasetoCreate.isEmpty()){
            try{
                Insert lstCasetoCreate;
                return 'Case created successfully and sent to our support team for processing';
            }catch(Exception ex){
                System.debug('Inside-> caseCreate -> Error occured: '+ ex.getMessage() +' Stack Trace: '+ ex.getStackTraceString());
                return 'Case creation failed!';
                
            }
        }
        return 'No customer selected for creating case!';
    }
    
    //EDGE-32689
    private static string getCaseDescription(Account newCust){
        return 'Account Name -> '+newCust.Name+'\nStatus -> '+newCust.Customer_Status__c+'\nCIDN -> '+newCust.CIDN__c+'\nABN -> '+newCust.ABN__c+'\nACN -> '+newCust.ACN__c+'\nType -> '+newCust.Type+'\nBusiness Unit -> '+newCust.Business_Unit__c+'\nMarket Segment -> '+newCust.Market_Segment__c+'\nPortfolio Code -> '+newCust.Portfolio_Code__c;
    }
    
    //EDGE-31363
    @auraEnabled
    public static Boolean loggedInAsSysAdmin(){
        return FeatureManagement.checkPermission('System_Admin_Permission');
    }
    
    //EDGE-30325
    @AuraEnabled
    public static ID getLeadRecordTypeId(){
        Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Enterprise Customer').getRecordTypeId();
        return String.valueOf(devRecordTypeId);
    }
}
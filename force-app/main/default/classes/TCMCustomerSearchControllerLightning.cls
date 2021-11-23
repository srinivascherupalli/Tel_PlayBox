/** 
* @Description : EDGE 36. Customer Search By lightning
* @Author : Shambo Ray
* @Date : 11/11/2017
* @Story : EDGE-36
* @Changes : DEFECT FIXES- 19/11/2017
*/
public without sharing class TCMCustomerSearchControllerLightning {
   
   
    private static final String MOCK_URL = 'http://mocksandbox.getsandbox.com/search';
    private static final Integer upper_limit = Integer.valueOf(Label.CUSTOMER_SEARCH_PAGE_SIZE);
    public static Boolean showSearchResult;
    public static Boolean searchedOnTCM;
   	private static final String exclusion = 'out of scope';
	public static Boolean includeContacts = false;   
    
    @AuraEnabled
    public static List<Account> getinternalSearch(String lname,String abn, String bdate, String email, String acn,String cac,String cidn,String masterId,String fnn) {  
       	List<Account> accountsList = new List<Account>();
        showSearchResult = true;
        Boolean searchedInternally = true;
        if(lname != null && lname != '' && abn !=null && abn !='') 
        {
            if(abn.isNumeric())
            {
				accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ABN__c = :abn and Name LIKE :'%'+lname+'%' ];
            }
            else
            {
                showSearchResult=false;
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA); 
                //exception handling would be included for non numeric field value
            }
        }
        else if(lname != null && lname != '' && acn !=null && acn !='')
        {
          if(acn.isNumeric())
          	{
				accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ACN__c = :acn and Name LIKE :'%'+lname+'%' ];
            }
            else
            {
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }  
        }
        else if(lname != null && lname != '')
        {
          		accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE Name LIKE :'%'+lname+'%' ];  
        }
        
        
        else if(lname != null && lname != '' && bdate !=null && bdate !=''){ 
            if (bdate.length() ==10) 
                {
                    accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE birthDate__c = :bdate and Name LIKE :'%'+lname+'%' ];    
                }
            else
            {
                	showSearchResult=false;
                	//exception handling would be included for non numeric field value
                	throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }  
        }
        
        else if(abn!=null && abn!=''){
           if(abn.isNumeric())
           { 
              	system.debug('in abn block'+abn); 
              	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ABN__c LIKE :'%'+abn+'%' ];  
           	  	system.debug('accountlist'+accountsList);	
           }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
               	throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
        
        else if(acn!=null && acn!=''){
            if(acn.isNumeric()){ 
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ACN__c LIKE :'%'+acn+'%' ];  
            }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
        else if(masterid!=null && masterid!='')
        {
            if(masterid.isNumeric()){
                
                accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE TCM_MasterID__c LIKE :'%'+masterId+'%' ];  
            }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }

        }
        
        else if(cidn!=null && cidn!=''){
             if(cidn.isNumeric()){
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE CIDN__c LIKE :'%'+cidn+'%' ];  
             }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
        else if(cac!=null && cac!=''){
            if(cac.isNumeric()){
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE Customer_ID__c LIKE :'%'+cac+'%' ];  
            }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
       else if(fnn!=null && fnn!=''){
            if(fnn.isNumeric()){
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE Service_ID__c LIKE :'%'+fnn+'%' ];  
            }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric acn no
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        } 
        
        
        
        
        return accountsList;
    }

@AuraEnabled
    public static List<Account> getinternalSearchPRM(String lname,String abn,String acn,String cidn) {  
       	List<Account> accountsList = new List<Account>();
        showSearchResult = true;
        Boolean searchedInternally = true;
        if(lname != null && lname != '' && abn !=null && abn !='') 
        {
            if(abn.isNumeric())
            {
				accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ABN__c = :abn and Name =:lname];
            }
            else
            {
                showSearchResult=false;
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA); 
                //exception handling would be included for non numeric field value
            }
        }
        else if(lname != null && lname != '' && acn !=null && acn !='')
        {
          if(acn.isNumeric())
          	{
				accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ACN__c = :acn and Name = :lname];
            }
            else
            {
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }  
        }
        else if(lname != null && lname != '')
        {
          		accountsList=[SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE Name =:lname];  
        }
        
        else if(abn!=null && abn!=''){
           if(abn.isNumeric())
           { 
              	system.debug('in abn block'+abn); 
              	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ABN__c = :abn];  
           	  	system.debug('accountlist'+accountsList);	
           }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
               	throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
        
        else if(acn!=null && acn!=''){
            if(acn.isNumeric()){ 
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE ACN__c = :acn];  
            }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
        
        else if(cidn!=null && cidn!=''){
             if(cidn.isNumeric()){
             	accountsList = [SELECT Id, Name, ABN__c, ACN__c, Customer_Status__c, Customer_ID__c, TCM_MasterID__c, CIDN__c,Data_Sovereign_Status__c,birthDate__c,Type,Business_Unit__c,Service_ID__c FROM Account WHERE CIDN__c = :cidn];  
             }
            else{
                showSearchResult=false;
                //exception handling would be included for non numeric field value
                throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);   
            }
        }
    
        return accountsList;
    }
    
    
    @AuraEnabled
    public static String getTCMSearch(String lname,String abn, String bdate, String email, String acn,String cac,String cidn,String masterId ,String fnn,String offset,Boolean prev,Boolean next ) {
        
        CustomerObject searchResponse = null;
        includeContacts=true;
		showSearchResult=true;

        if(abn !=null && abn !='')
               {
                    if((acn!=null && acn !='') ||(cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(bDate !=null && bDate !=''))
                    {
                      //Error handling to be done for any invalid comb in server side  
                      throw new AuraHandledException(Label.INVALID_COMBINATION);  
                    }else{
                    
                     if(abn.isNumeric()){
                        searchResponse=searchByABN(lname,abn,offset,prev,next);
                        }
                    else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                    }
                    }
                    
               }
                else if(acn !=null && acn !='')
                {
                    if((cac !=null && cac !='')||(cidn !=null && cidn !='')||(masterId !=null && masterId !='')||(bDate !=null && bDate !=''))
                    {
                      	//Error handling to be done for any invalid comb in server side  
                         throw new AuraHandledException(Label.INVALID_COMBINATION); 
                    }else{
                        if(acn.isNumeric()){
                         searchResponse=searchByACN(lname, acn,offset,prev,next);
                        }
                        else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                        }	
                    }
               
                    
                }
                else if(masterId != null && masterId != '')
                { 
                    if((lName !=null && lName !='')|| (cidn !=null && cidn !='')||(cac !=null && cac!='')||(bDate!=null && bDate!=''))
                    {	
                        //Error handling to be done for any invalid comb in server side  
                        throw new AuraHandledException(Label.INVALID_COMBINATION);
                        
                    }else{
                        includeContacts=false;
                    if(masterid.isNumeric()){
                            searchResponse=searchByMasterID( masterid, includeContacts,offset, prev, next);
                        }
                    
                    else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                    }	
                }
                    
                    
                }
                else if(cidn != null && cidn != '') 
                {
                    if((cac !=null && cac !='')||(lName !=null && lName !='')||(bDate!=null && bDate !=''))
                    {
                        //Error handling to be done for any invalid comb in server side  
                        throw new AuraHandledException(Label.INVALID_COMBINATION);
                       
                    }else{
                        if(cidn.isNumeric()){
                            searchResponse=searchByCIDN(cidn,offset,prev, next);
                            }
                        else{
                            showSearchResult=false;
                            //exception handling would be included for non numeric abn no
                            throw new AuraHandledException(Label.INCORRECT_FIELD_DATA); 
                        
                        }
                    }
                    
                    
                }
                else if(cac != null && cac != '')
                {
                   if((lName !=null && lName !='')||(bDate !=null && bDate !=''))
                   {
                     	//Error handling to be done for any invalid comb in server side  
                         throw new AuraHandledException(Label.INVALID_COMBINATION);  
                   }else{
                    if(cac.isNumeric()){
                        searchResponse=searchByCAC(cac,offset,prev, next);
                    }
                    else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA); 
                    
                    }
                   }
                    
                    
                }
                
                else if((lName != null && lName != '') || (abn != null && abn != '') || (acn != null && acn != '') ||(bDate !=null && bDate !=''))
                {
                    if(lName != null && lName != '' && abn != null && abn != ''){
                        searchResponse=searchByABN(lname,abn,offset,prev,next);
                    }
                    else if(lName != null && lName != '' && acn != null && acn != ''){
                        searchResponse=searchByACN(lname, acn,offset,prev,next);	
                    }
                    else if(lName != null && lName != '' && bDate != null && bDate != '')
                    {
                       searchResponse=searchByDOB(lname,bdate,offset,prev,next);
                    }
                    else if((lName != null && lName != '') || (cidn == null && cidn == '') || (cac == null && cac == '') || (bDate == null && bDate == '') || (abn == null && abn == '') || (acn == null && acn == '') || (masterId == null && masterId == ''))
                   {
                       searchResponse= searchByLastName(lname,abn,acn,offset,prev,next);  
                   }
                     
                }else if(fnn!=null && fnn!='')
                {
                    if(fnn.isNumeric())
                    {
                        searchResponse=searchByFNN(fnn,offset,prev, next);
                    }
                    else
                    {
                        showSearchResult=false;
                        //exception handling would be included for non numeric acn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                    }
                }
                else {
                    
                }     
    
        system.debug('searchresponse inbound'+searchResponse);
        return JSON.serialize(searchResponse);
    }
    
    @AuraEnabled
    public static String getTCMSearchPRM(String lname,String abn,String acn,String cidn,String offset,Boolean prev,Boolean next ) {
        
        CustomerObject searchResponse = null;
        includeContacts=true;
		showSearchResult=true;

        if(abn !=null && abn !='')
               {
                    if((acn!=null && acn !='') ||(cidn !=null && cidn !=''))
                    {
                      //Error handling to be done for any invalid comb in server side  
                      throw new AuraHandledException(Label.INVALID_COMBINATION);  
                    }else{
                    
                     if(abn.isNumeric()){
                        searchResponse=searchByABN(lname,abn,offset,prev,next);
                        }
                    else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                    }
                    }
                    
               }
                else if(acn !=null && acn !='')
                {
                    if((cidn !=null && cidn !=''))
                    {
                      	//Error handling to be done for any invalid comb in server side  
                         throw new AuraHandledException(Label.INVALID_COMBINATION); 
                    }else{
                        if(acn.isNumeric()){
                         searchResponse=searchByACN(lname, acn,offset,prev,next);
                        }
                        else{
                        showSearchResult=false;
                        //exception handling would be included for non numeric abn no
                        throw new AuraHandledException(Label.INCORRECT_FIELD_DATA);  
                        }	
                    }
               
                    
                }
                
                else if(cidn != null && cidn != '') 
                {
                    if(lName !=null && lName !='')
                    {
                        //Error handling to be done for any invalid comb in server side  
                        throw new AuraHandledException(Label.INVALID_COMBINATION);
                       
                    }else{
                        if(cidn.isNumeric()){
                            searchResponse=searchByCIDN(cidn,offset,prev, next);
                            }
                        else{
                            showSearchResult=false;
                            //exception handling would be included for non numeric abn no
                            throw new AuraHandledException(Label.INCORRECT_FIELD_DATA); 
                        
                        }
                    }
                    
                    
                }
                
                else if((lName != null && lName != '') || (abn != null && abn != '') || (acn != null && acn != ''))
                {
                    if(lName != null && lName != '' && abn != null && abn != ''){
                        searchResponse=searchByABN(lname,abn,offset,prev,next);
                    }
                    else if(lName != null && lName != '' && acn != null && acn != ''){
                        searchResponse=searchByACN(lname, acn,offset,prev,next);	
                    }
                    
                    else if((lName != null && lName != '') || (cidn == null && cidn == '') || (abn == null && abn == '') || (acn == null && acn == ''))
                   {
                       searchResponse= searchByLastName(lname,abn,acn,offset,prev,next);  
                   }
                     
                }
                else {
                    
                }     
    
        system.debug('searchresponse inbound'+searchResponse);
        return JSON.serialize(searchResponse);
    }
    
    @auraenabled
    public Static CustomerObject searchByABN(String lastName,String abn,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by ABN : ' + abn);
        String params='';
        
        params = params + '?abn='+abn;
        
        if(lastName != null && lastName != '') 
        {
            params += '&lastName='+lastName;    
        }
        
       return  convert(doCallout(true,params,offset,prev,next));
    }
     @auraenabled
     public static CustomerObject searchByLastName(String lastName,String abn,String acn,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by lastName : ' + lastName);   
        String params='';
        params = params + '?lastName='+lastName;
        if(abn != null && abn != '') 
        {
            params += '&abn='+abn;    
        }
        
        if(acn != null && acn != '') 
        {
            params += '&acn='+acn;    
        }
        
      return  convert(doCallout(true,params,offset,prev,next));
    }
    @auraenabled
	public static CustomerObject searchByACN(String lastName,String acn,String offset,Boolean prev,Boolean next){  
        System.debug('Searching by ACN : ' + acn);
        String params='';
        params = params + '?acn='+acn;
        
        if(lastName != null && lastName != '') 
        {
            params += '&lastName='+lastName;    
        }
        
       return  convert(doCallout(true,params,offset,prev,next));
    } 
    
    @auraenabled
    public static CustomerObject searchByFNN(String fnn,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by MasterId : ' + fnn);
        String params='';
        if(fnn!=null && fnn!='')
        {
        params = params + '?serviceId='+fnn;
        }
        return convert(doCallout(true,params,offset,prev,next));
    }
    
    
    
     @auraenabled
     public static CustomerObject searchByDOB(String lastName,String birthDate,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by DOB : ' + birthDate);
        String params='';
        params = params +'?birthDate='+birthDate;
        system.debug('i am in dob block!');
        if(lastName != null && lastName != '') 
        {
            params += '&lastName='+lastName;  
            System.debug('==++params'+params);
        }
        
        return convert(doCallout(true,params,offset,prev,next));
    }
    @auraenabled
    public static CustomerObject searchByMasterID(String masterId,Boolean includeContacts,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by MasterId : ' + masterId);   
        System.debug('!@#$% includeContacts : ' + includeContacts);
        String params='';
        Boolean append;
        if(masterId!=null && masterId!=''){
            if(includeContacts==false)
            {
                //system.debug('i am in defect');
                params = params + '/'+masterId;
                system.debug('param'+params);
            }
            append = false;
            
            if(includeContacts==true)
            {
                //system.debug('inside include contacts search');
                params='';
                params = params + '/'+masterId + '?include=contacts';
                append = true;
            }
        }
        return convert(doCallout(append,params,offset,prev,next));
    }
     @auraenabled
    public static JSON2TCMCustomerContactObject searchByMasterIDForContactDetails(String masterId,Boolean includeContacts,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by MasterId : ' + masterId);   
        System.debug('!@#$% includeContacts : ' + includeContacts);
        String params='';
        
        Boolean append = false;
        if(masterId!=null && masterId!=''){
            if(includeContacts==true)
            {
                system.debug('inside include contacts search');
                params='';
                params = params + '/'+masterId + '?include=contacts';
                append = true;
            }
        }
        return convertToAccountContact(doCallout(true,params,offset,prev,next));
    }
    
    
     @auraenabled
     public static CustomerObject searchByCIDN(String cidn,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by CIDN : ' + cidn);   
        String params='';
        if(cidn!=null && cidn!=''){
        	params = params + '?cidn='+cidn;
        }
        return convert(doCallout(true,params,offset,prev,next));
    }
     @auraenabled
       public static CustomerObject searchByCAC(String cac,String offset,Boolean prev,Boolean next){  
        System.debug('!@#$% Searching by CAC : ' + cac);   
        String params='';
        if(cac!=null && cac!='')
        {
        	params = params + '?cac='+cac;
        }
        return convert(doCallout(true,params,offset,prev,next));
    }
    
    
    
     
  public static String doCallout(Boolean appendParams,String params,String offset,Boolean prev,Boolean next){
        System.debug('!@#$% Attempting to do a callout to TCM');
        String result='';
        String error='';
        Boolean calloutUnsuccesful = false;
      	Integer ofst;
        system.debug('i am failing here'+calloutUnsuccesful); 
        if(offset == null|| offset== '') 
        {
        	ofst = 0;
        }
        
		if(next == true)
        {
            System.debug('offset value'+offset);
			ofst =  Integer.valueOf(offset) + upper_limit;
		}
		if(prev == true)
        {
		    ofst = Integer.valueOf(offset) - upper_limit;
		}	 
         
        
        try {
            String url;
            String token = TCMSearchManager.getTCMToken();
            
            system.debug('next value'+next);
            system.debug('offset value'+offset);
            IntegrationSettings__c is = IntegrationSettings__c.getOrgDefaults();
            url = (is.EnableMocks__c != null && is.EnableMocks__c) ? MOCK_URL : EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts';
            params += (appendParams != null && appendParams) ? '&limit='+upper_limit+'&offset='+ofst : '?limit='+upper_limit+'&offset='+ofst;
            if(ofst == null) ofst = 0;
            system.debug('params'+params);
            HttpResponse resp = TCMSearchService.callout(url+params, token);
            System.debug('===+++resp'+resp);    
            String body = resp.getBody();
            System.debug('!@#$% HTTP Response Body : ' + body);
            
            searchedOnTCM = true;
            result = body;  
            error = '';
           	System.debug('result going to client'+result);
            if(resp.getStatusCode() != 200)
            {
                calloutUnsuccesful = true;
                searchedOnTCM = false;
                throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);   
            }
            
            CustomerObject convertedObj = (CustomerObject)JSON.deserialize(resp.getBody(), CustomerObject.class); 
            return result;
        }
        catch(NullPointerException e)
        {
            calloutUnsuccesful = true;
            throw new AuraHandledException( Label.CUSTOMER_SEARCH_ERROR_CUSTOMSETTINGS_UNDEFINED);
        }
        catch(CalloutException ce) 
        {
            calloutUnsuccesful = true;
            throw new AuraHandledException(Label.CUSTOMER_SEARCH_ERROR_TCMDOWN);
        }
       return result;
    }
     
    @auraenabled
     public static JSON2TCMCustomerContactObject convertToAccountContact(String result) 
     {
        //Object obj=null;
        //List<CustomerObject.Customer> customerList =  new List<CustomerObject.Customer>();
        JSON2TCMCustomerContactObject customerContact=null;
        //CustomerObject customer=null;
        String err='';
        System.debug('!@#$% Attempting to convert the result');
        if(result != null && result != '')
        {
            
            if(includeContacts != null)
            {
                if(includeContacts==true)
                {
                    system.debug('inside include contacts Json Converter');
                    JSON2TCMCustomerContactObject convertedObj = (JSON2TCMCustomerContactObject)JSON.deserialize(result, JSON2TCMCustomerContactObject.class);    
                   
                    customerContact = convertedObj;
                    System.debug('!@#$% Converted CustomerContact : ' + customerContact);
                    
                    return customerContact;
                }
              
        	}
      
        
    	}
         return null;
    
     }    
    
    
    
    
    @auraenabled
     public static CustomerObject convert(String result) 
     {
       
        CustomerObject customer=null;
        String err='';
        System.debug('!@#$% Attempting to convert the result');
        system.debug('result'+result);
        if(result != null && result != '')
        {
            
            
                CustomerObject convertedObj = (CustomerObject)JSON.deserialize(result, CustomerObject.class); 
                //obj = convertedObj; 
                customer = convertedObj;
                System.debug('!@#$% Converted Customer : ' + customer);
                return customer;
        }
            
        
        
    	return null;
    }
    

    /*
    Modified by : Team SFO , Murali & Sravanthi
    Modified Date : 2/12/2019
    Description: As part of P2OB-3651 AC-2 , implemented a check if portfolio code is present in salesforce ,
                 if not present error is thrown and import aborted.
    */
    @AuraEnabled
    public static Map<String,String> accountContactSave(String lstRecordId) {
        
        system.debug('TCMCustomerSearchControllerLightning.accountContactSave : id inbound -- '+lstRecordId);
        String data =  lstRecordId.substring(1, lstRecordId.length()-1);
        Map < String, String > oErrorMsg = new Map <String , String> ();
        if(data==null || data.length()==0){
            oErrorMsg.put(Label.CUSTOMER_SEARCH_WARNING_SELECTION, '');
            return oErrorMsg;
        }
        CustomerObject.Customer convertedObj = (CustomerObject.Customer)JSON.deserialize(data, CustomerObject.Customer.class);  
        system.debug('TCMCustomerSearchControllerLightning.accountContactSave : CustomerObject.Customer -- ' + convertedObj);
        
        if(convertedObj != null && convertedObj.customerAccount != null){
            //P2OB-3651 : Portfolio check code modification -- START
            if(convertedObj.portfolioCode=='' || convertedObj.portfolioCode==null || String.isBlank(convertedObj.portfolioCode)){
                oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_INVALID_PORTFOLIO, '');
                return oErrorMsg;
            }
            if(convertedObj.portfolioCode!= null ){
                List<Territory2> uta = [SELECT DeveloperName,Id,Name ,Territory2ModelId FROM Territory2 WHERE Name = : convertedObj.portfolioCode AND Territory2Model.State ='Active'AND Territory2Model.Name =: Label.Territory_Model_Name LIMIT 1];
                if(uta == null || uta.isEmpty()){
                    oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_INVALID_PORTFOLIO, '');
                    return oErrorMsg;
                } 
                //P2OB-3651 : Portfolio check code modification -- END 
                else{
                    if(convertedObj.customerAccount.dataSovereignty.toLowerCase() == exclusion){                
                        oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_DATA_SOVEREIGNTY, '');
                        return oErrorMsg;
                    } else {
                        system.debug('inside import contacts method');
                        Account tcmCustomer = null;
                        Savepoint sp = null;
                        TCMCustomerImportByCIDN tcmImportByCIDN = new TCMCustomerImportByCIDN();
                        tcmImportByCIDN.selectedCustomer = convertedObj;
                        try {
                            TCMGetInterface.getInstance().tcmCustomerObject.put(convertedObj.masterID, convertedObj);
                            TCMGetContactFuture tcmGetConFuture = new TCMGetContactFuture();
                            tcmImportByCIDN.tcmObjects(convertedObj.cidn);
                            sp = Database.setSavepoint();
                            tcmImportByCIDN.createTCMCustomer(convertedObj.cidn);
                            tcmCustomer = tcmImportByCIDN.tcmCustomer;
                            tcmGetConFuture.futureCalloutAccount(tcmCustomer, 'TCMSEARCHSERVICE');
                        }
                        catch(TCMException.TCMCallOutException e) {
                            if(sp != null) Database.rollback(sp);
                            oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_IMPORT+'  Reason is:  '+e.getMessage(), '');
                            updateApplicationLogs();
                            return oErrorMsg;
                        }
                        catch(TCMException.TCMCustomerCreationException tcmException){
                            if(sp != null) Database.rollback(sp);
                            TCMBusinessErrorCode.getInstance().logCustomerExcepction(convertedObj.masterId,'TCMSEARCHSERVICE',tcmException);
                            updateApplicationLogs();
                            oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_IMPORT+'  Reason is:  '+tcmException.getMessage(), '');
                            return oErrorMsg;
                        } catch(Exception e) {
                            if(sp != null) Database.rollback(sp);                   
                            updateApplicationLogs();
                            oErrorMsg.put(Label.CUSTOMER_SEARCH_ERROR_IMPORT+'  Reason is:  '+e.getMessage(), '');
                            return oErrorMsg;
                        } finally {
                            updateApplicationLogs();
                        }
                        oErrorMsg.put(Label.CUSTOMER_SEARCH_IMPORT_SUCCESSFUL, tcmCustomer.id);
                        return oErrorMsg;
                    }
                    return oErrorMsg;    
                }
            } 
            return oErrorMsg;
        } else {
            oErrorMsg.put(Label.CUSTOMER_SEARCH_WARNING_SELECTION, '');
            return oErrorMsg;
        }
        
    }
    
    private static void updateApplicationLogs(){
        Logger2 logger2log = Logger2.getLogger('TCMSearchService');
        TCMGetInterface getInterface = TCMGetInterface.getInstance();
        for(String keys : getInterface.callOutDataCapture.keyset()){
            TCMGetInterface.TCMRequestResponseCapture reqResCapture = getInterface.callOutDataCapture.get(keys);
            logger2log.logMessages(reqResCapture.url, reqResCapture.httpResponse.getBody(), '', '', '', '', false, false);
        }
        logger2log.exitLogger();
    }

    @AuraEnabled
    public static String fetchUser(){

    User u = [select id,Name,Profile.name from User where id =: userInfo.getUserId()];
        System.debug('profile'+u.Profile.name);
       
        if((u.Profile.name == PRMConstants.PRM_PROFILE_PRM_Admin_Australia) || (u.Profile.name == PRMConstants.PRM_COMMUNITY_USER_AUSTRALIA) ){
		return 'PRM';
        }
        else
            return 'NonPRM';
    }

}
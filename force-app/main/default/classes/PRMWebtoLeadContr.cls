/*---------------------------
Class Updated by Ayush(Appirio) 
for story number P2OB-7585 
Dated - 28th June 2020
-----------------------------*/
global with sharing class PRMWebtoLeadContr {
    public string recordTypeId{get;set;}
    public string ThankyouUrl{get;set;}
    public string webtoLeadUrl{get;set;}
    //old code used for Webtoleadform
    public PRMWebtoLeadContr(){
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.lead.getRecordTypeInfosByName();
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Edge Partners']; 
    recordTypeId=((string)rtMapByName.get('TE-A Partner Expression of Interest').getRecordTypeId()).substring(0,15);
    ThankyouUrl=network.getLogoutUrl(Network.getNetworkId())+system.label.PRM_THANK_YOU;
        webtoLeadUrl=(runningInASandbox()?'https://test.salesforce.com':'https://webto.salesforce.com')+'/servlet/servlet.WebToLead?encoding=UTF-8';
    }
    public static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    @RemoteAction
    public static string CallWebToLead(string sParams){
        string sOrgID = userinfo.getOrganizationId().substring(0,15);
        Map<String,Schema.RecordTypeInfo> rtMapByNamen = Schema.SObjectType.lead.getRecordTypeInfosByName();
        string srecordTypeId=((string)rtMapByNamen.get('TE-A Partner Expression of Interest').getRecordTypeId()).substring(0,15);
        Network myNetwork = [SELECT Id FROM Network WHERE Name ='Edge Partners']; 
        string sThankyouUrl=network.getLogoutUrl(Network.getNetworkId())+system.label.PRM_THANK_YOU;
        string swebtoLeadUrl=(runningInASandbox()?'https://test.salesforce.com':'https://webto.salesforce.com')+'/servlet/servlet.WebToLead?encoding=UTF-8';
        string sParams1 =sParams.replace('dynamicOrgId',sOrgID); 
        String sParamsValue = swebtoLeadUrl+'&oid='+sOrgID+'&recordType='+srecordTypeId+'&lead_source=Telstra.com+EoI&'+sParams1;
        Logger2 logger = Logger2.getLogger('WebToLead-PRM'); 
        string strReq;
        string strResp;
        try{
            HttpRequest req= new HttpRequest();
            req.setEndpoint(sParamsValue);
            req.setMethod('POST');
            strReq = string.valueOf(req);
            Http http = new Http();
            HttpResponse Resp = http.send(req);
            strResp = string.valueOf(Resp);
            return sThankyouUrl; 
        }Catch(Exception ex){
            logger.logMessages(strReq, strResp, 'Technical', ex.getMessage(), '', '', false, false);
        } 
        return null;
    }
   //Method updated by Ayush(Appirio) for Story P2OB-7585 - Parameters changed to not include leadid     
   @AuraEnabled
    global Static String saveLead(Lead lead,String CatpchToken){  
        Logger2 logger = Logger2.getLogger('PRMWebtoLeadCont.saveLead');
        pageResponse result = new pageResponse() ;  
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.lead.getRecordTypeInfosByName();
        String recordTypeId=((string)rtMapByName.get(PRMConstants.PRM_LEAD_RECORDTYPE_TE_A_PARTNER_EOI).getRecordTypeId()).substring(0,15);      

       try{ 	//Ayush: Below logic commented because validation handled at frontend component
                /*if(!PRMWebtoLeadContr.validateRecaptchaToken(CatpchToken)) {
                    result.status='Error';
                    result.Message='Captcha Verification failed';
                    return JSON.serialize(result);                  
                } */

                //Assign defaulat values in insert call 
                lead.recordTypeId=recordTypeId;
                lead.LeadSource=PRMConstants.PRM_PICKLIST_VAL_TELSTRACOM_EoI;
           		//Ayush: Logic relocated from previous segment to this position
                if(lead.ABN__c!=null){
                    lead.ABN__c=lead.ABN__c.trim();
                    lead.ABN__c=lead.ABN__c.replaceAll('(\\s+)', '');  //to remove white space
                }
                lead.company=String.isNotBlank(lead.company)?lead.company:lead.firstname;
            //Lead is not getting assigned Automatically, so running assignment rules forcefully with apex
           if(lead.status=='open'){
                AssignmentRule AR = new AssignmentRule();
                AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true limit 1];
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
                lead.setOptions(dmlOpts); 
           }               
            insert lead;
            result.status='SUCCESS';
            result.Leadid=lead.id;        
            result.lead=lead;        
            }                  
        catch(exception e)
        {
            result.status='Error';
            result.Message=e.getMessage();
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
        }
        finally{
            logger.exitLogger();           
        }
        return JSON.serialize(result);                  
    }
    @AuraEnabled //get Lead Industry Vertical Picklist Values
    public static Map<String, String> getIndustryVertical(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Lead.Industry_Vertical__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    } 
    @AuraEnabled
    public static List <String> getPicklistvalues(String FieldAPIName ){
        List<String> plValues = new List<String>();
        Schema.DescribeFieldResult fieldResult = null;
        if(FieldAPIName=='Partner_categories__c'){
            fieldResult = Lead.Partner_categories__c.getDescribe();
        }
        else if(FieldAPIName=='Source_Info_Telstra_Channel_Partner_prog__c'){
            fieldResult = Lead.Source_Info_Telstra_Channel_Partner_prog__c.getDescribe();
        }
        else if(FieldAPIName=='Annual_Revenue__c'){
            fieldResult = Lead.Annual_Revenue__c.getDescribe();
        }
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            plValues.add(p.getValue());
        }
        return plValues;
    }
    /*public static Boolean validateRecaptchaToken(String token){
        Boolean success = false;
        PhoenixGlobalUtil.ReCaptcha recaptch=new PhoenixGlobalUtil.ReCaptcha();
        recaptch.endpoint=Label.recaptcha_Endpoint; //  'https://www.google.com/recaptcha/api/siteverify';
        //this is the value captured at page once captcha is validated as cleint side after i am not robot check
        recaptch.token=token; // '03AOLTBLQ4Gwm5HLUoXdpdV385bBHolYIx2xkQ8HrdXismvBCeMg94ozvgPE0qS-X1UXkmN3793ExJIvrSDJa8B8SLfXXq2DU8VbQ--8Tt6iOJc5WIyRe7jzdaSqkbd4L9B2yb5ATKTMtiKkmyaIGd8rYYefy-H1bBD2WYUqFXgR7NflLy8LI3a4hESTNnSOMsFmgwvz2RqsNZsT5Srkmuh7NlFZR2LrVC7EcSroHOQS45kni5Y8O28C1plXxV9vtgKTQysNeqIR9Kwzr74m7LWKRvoh9IfQLgeVJMdP-5GYBC6PZqYYLHw6T1Uc3T6hASC9Oa2SA2HpEe-_hkKTjqjwcyJ3YCwWRJzQ';
        //recatch key whcih remain same, put this in custom label, will change for prod
        recaptch.secret=Label.recaptch_secret;//'6Ld5aOASAAAAAGd0veZ2aVPJRce1CgHfV5EHrY4N';
        PhoenixGlobalUtil.ReCaptcha reCaptcha=PhoenixGlobalUtil.validatecaptcha(recaptch);
        if(reCaptcha != null)
        success = reCaptcha.success; 
        //responsse will be like this
        /* {
"success": false,//true if recaptcha validation was success
"error-codes": [
"timeout-or-duplicate"
]
}*/
        //return success;
    //}
    @AuraEnabled
    public static String getCommunityUrl() {
        if(Network.getNetworkId()!=null)
            return network.getLoginUrl(Network.getNetworkId()).removeEnd('login');
        return null;
    }
    // EDGE-71337; capture Lead information if ABN validation fails due to no of yrs rule
    // PRMMinYrsInBusinessABN value currently set to 2
    //EDGE-70697; Implement new ABN validate method -SearchByABNv201408 as the old method does not have Business Name in response.        
    //Method parameters and structure changed as per story number P2OB-7585 by Ayush(Appirio)
    @AuraEnabled
    public static string callABNService(String sABN){
        //Ayush: If it is running in sandbox then send stub response else make actual callout
        Boolean isSandbox = runningInASandbox();
        if(IsSandbox && sABN == '123'){
            list<String> listBusinessName = new List<String>{'biz1','biz2'};
            String entityName='ABC Test';
            Integer noOfYrsInBusiness=Integer.valueOf(Label.noOfYearsInBusinessForTest);
            ABRResults abrResult = new ABRResults();
            abrResult.noOfYrsInBusiness = noOfYrsInBusiness;
            abrResult.entityName = entityName;
            abrResult.listBusinessName = listBusinessName;
            abrResult.status = 'Active';
            return JSON.serialize(abrResult);
        }
        Integer noOfYrsInBusiness;
        Integer currentYear = System.today().year();
        integer effectiveyear;
        string effectiveFromDate;
        string abnStatus='';
        String entityName='';
        String sServiceName = Label.PRM_ABN_validate_method;      // serviceName currently set to SearchByABNv201408
        String response = PRMConstants.PRM_ABNService_response; 
        String businessEntity201408 = PRMConstants.PRM_ABNService_businessEntity201408; 
        String entityStatus = PRMConstants.PRM_ABNService_entityStatus; 
        String effectiveFrom = PRMConstants.PRM_ABNService_effectiveFromDate;
        String entityStatusCode = PRMConstants.PRM_ABNService_entityStatusCode;
        String mainName = PRMConstants.PRM_ABNService_mainName;
        String mainTradingName = PRMConstants.PRM_ABNService_mainTradingName;
        String organisationName = PRMConstants.PRM_ABNService_entityName;
        String businessName = PRMConstants.PRM_ABNService_businessName;
        String legalName = PRMConstants.PRM_ABNService_legalName;
        String givenName = PRMConstants.PRM_ABNService_givenName;
        String success = PRMConstants.PRM_PIMS_SYNC_STATUS_SUCCESS;
        String error = PRMConstants.PRM_PIMS_SYNC_STATUS_Error;
        list<String> listBusinessName = new List<String>();
        String errorResponse='Inactive';
        Boolean containsError =false;
        //boolean isError=false;
        Logger2 logger = Logger2.getLogger('WebToLead-PRM');
        try{            
            HttpResponse res = new HttpResponse();      
            res = ABNService.callABRService(sServiceName, sABN);     // method accepts the service name as parameter and ABN as another parameter
            Dom.Document doc = res.getBodyDocument();
            Dom.XMLNode rootNode = doc.getRootElement();
            string namespce = rootNode.getNamespace();
            Dom.XMLNode responseNode = rootNode.getChildElement(response,namespce);
            Dom.XMLNode[] responseChildNodes = responseNode.getChildElements();
            for(Dom.XMLNode eachChildNode : responseChildNodes){
                if(eachChildNode.getName() == PRMConstants.PRM_ABNService_exception){
                    errorResponse = eachChildNode.getChildElement(PRMConstants.PRM_ABNService_exceptiondescription,namespce).getText();
                    containsError = true;
                    break;
                }
            }
            if(!containsError){
                Dom.XMLNode businessEntityNode = responseNode.getChildElement(businessEntity201408,namespce);
                //Logic to get EnityName, Business Name(s) and no of yrs in business below
                //toGet effectiveFromDate from entityStatus
                Dom.XMLNode entityStatusNode=null;
                if( businessEntityNode!=null)
                entityStatusNode = businessEntityNode.getChildElement(entityStatus,namespce);
                //Girish: Check if ABN is active or not
                if( entityStatusNode!=null)
                abnStatus = entityStatusNode.getChildElement(entityStatusCode, namespce).getText();
                if(PRMCONSTANTS.PRM_ABNService_entityStatusCodeActive==abnStatus){
                    containsError = false;
                    effectiveFromDate = entityStatusNode.getChildElement(effectiveFrom, namespce).getText();
                    //toGet entityName/organisationName from mainName
                    if(businessEntityNode.getChildElement(mainName,namespce)!= null){ 
                    Dom.XMLNode mainNameNode = businessEntityNode.getChildElement(mainName,namespce); 
                    entityName = mainNameNode.getChildElement(organisationName, namespce).getText();
                    }
                    else if(businessEntityNode.getChildElement(businessName,namespce)!= null){
                    Dom.XMLNode mainNameNode = businessEntityNode.getChildElement(businessName,namespce); 
                    entityName = mainNameNode.getChildElement(organisationName, namespce).getText();
                    }  
                    else if(businessEntityNode.getChildElement(legalName,namespce)!= null){
                    Dom.XMLNode mainNameNode = businessEntityNode.getChildElement(legalName,namespce); 
                    entityName = mainNameNode.getChildElement(givenName, namespce).getText();
                    }
                    //toGet multipleBusiness Names
                    List<Dom.XMLNode> businessNameNodes = new List<Dom.XMLNode>();
                    Dom.XMLNode[] businessEntityChildNodes = businessEntityNode.getChildElements();
                    for(Dom.XMLNode businessEntityChildNode : businessEntityChildNodes){
                        if(businessEntityChildNode.getName() == businessName)
                            businessNameNodes.add(businessEntityChildNode);
                    }
                    for(Dom.XMLNode eachBusinessNameNode : businessNameNodes){
                        listBusinessName.add(eachBusinessNameNode.getChildElement(organisationName,namespce).getText());
                    }
                    if(listBusinessName.isEmpty()){
                          listBusinessName.add(entityName);
                            } 
                    effectiveyear = Date.valueOf(effectiveFromDate).year();
                    noOfYrsInBusiness = currentYear - effectiveyear; //current year - effectivefrom year to get no. of years in business
                }
            }
        }Catch(exception e){
            //Capture Exception in Application log object
            logger.logMessages('', '', e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            throw(e);
        }
        ABRResults abrResult = new ABRResults();
        abrResult.noOfYrsInBusiness = noOfYrsInBusiness;
        abrResult.entityName = entityName;
        abrResult.listBusinessName = listBusinessName;
        if(abnStatus==PRMCONSTANTS.PRM_ABNService_entityStatusCodeActive && entityName != null){
            abrResult.status = PRMCONSTANTS.PRM_ABNService_entityStatusCodeActive;
            }
        else{
            abrResult.status = PRMCONSTANTS.PRM_ABNService_entityStatusCodeInactive;
            }
        abrResult.containsError = containsError;
        ABRResults returnedAbrResult = new ABRResults();
        return JSON.serialize(abrResult);
    }

    // DIGI-15298 Replacing custom labels with metadata records
    @AuraEnabled
    public static String getPRMEOIVisualforceDomain(String recordName){
        return PRMHawaiiUtil.returnMetadataRecord(recordName);
    }

    //Wrapper to return Data to calling class
    public class ABRResults{
        public Integer noOfYrsInBusiness;
        public String entityName;
        //WS returns multiple business names
        public list<String> listBusinessName = new list<String>();
        public String status = '';
        public Boolean containsError = false;
    }
    global class pageResponse {
        Public String Status;
        public String Message;
        public String Leadid;
        public Lead lead;
    }
}
public with sharing class ABNService {
 
    public boolean isError = false;
    public Static HttpResponse callABRService(String sServiceName, String sABN) {
        Logger2 logger = Logger2.getLogger(sServiceName);
        HttpResponse res = new HttpResponse();
        HttpRequest req = new HttpRequest();
        try {
            String payload = 'searchString=' + sABN + '&includeHistoricalDetails=N&authenticationGuid=' + EnvironmentVariable.get('abn_validator_key');
            String endpoint = EnvironmentVariable.get('abn_validator_endpoint') + sServiceName;
            system.debug('endpoint'+endpoint);
            system.debug('payload '+payload );
            //String endpoint = '';
            Http h = new Http();
            req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setBody(payload);
            if(Test.isRunningTest()){
               // String ABNResponse='<ABRPayloadSearchResults xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://abr.business.gov.au/ABRXMLSearch/"><response><usageStatement>test</usageStatement><dateRegisterLastUpdated>2019-04-10</dateRegisterLastUpdated><dateTimeRetrieved>2019-04-10T20:03:00.4542021+10:00</dateTimeRetrieved><businessEntity201408><recordLastUpdatedDate>2019-04-09</recordLastUpdatedDate><ABN><identifierValue>78345431247</identifierValue><isCurrentIndicator>Y</isCurrentIndicator><replacedFrom>0001-01-01</replacedFrom></ABN><entityStatus><entityStatusCode>Active</entityStatusCode><effectiveFrom>2000-02-23</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></entityStatus><ASICNumber/><entityType><entityTypeCode>OIE</entityTypeCode><entityDescription>Other Incorporated Entity</entityDescription></entityType><goodsAndServicesTax><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></goodsAndServicesTax><dgrEndorsement><endorsedFrom>2000-07-01</endorsedFrom><endorsedTo>0001-01-01</endorsedTo><entityEndorsement>Endorsed DGR</entityEndorsement><itemNumber>Item 1</itemNumber></dgrEndorsement><mainName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2001-02-27</effectiveFrom></mainName><mainTradingName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2002-05-14</effectiveFrom></mainTradingName><mainBusinessPhysicalAddress><stateCode>VIC</stateCode><postcode>3004</postcode><effectiveFrom>2019-02-21</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></mainBusinessPhysicalAddress><charityType><charityTypeDescription>Public Benevolent Institution</charityTypeDescription><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></charityType><taxConcessionCharityEndorsement><endorsementType>GST Concession</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>FBT Exemption</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>Income Tax Exemption</endorsementType><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><businessName><organisationName>EMPOWER INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><ACNCRegistration><status>Registered</status><effectiveFrom>2012-12-03</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></ACNCRegistration></businessEntity201408></response></ABRPayloadSearchResults>';
 			    String ABNResponse='<ABRPayloadSearchResults xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://abr.business.gov.au/ABRXMLSearch/"><response><usageStatement>test</usageStatement><dateRegisterLastUpdated>2019-04-10</dateRegisterLastUpdated><dateTimeRetrieved>2019-04-10T20:03:00.4542021+10:00</dateTimeRetrieved><businessEntity201408><recordLastUpdatedDate>2019-04-09</recordLastUpdatedDate><ABN><identifierValue>78345431247</identifierValue><isCurrentIndicator>Y</isCurrentIndicator><replacedFrom>0001-01-01</replacedFrom></ABN><entityStatus><entityStatusCode>Active</entityStatusCode><effectiveFrom>2000-02-23</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></entityStatus><ASICNumber/><entityType><entityTypeCode>OIE</entityTypeCode><entityDescription>Other Incorporated Entity</entityDescription></entityType><goodsAndServicesTax><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></goodsAndServicesTax><dgrEndorsement><endorsedFrom>2000-07-01</endorsedFrom><endorsedTo>0001-01-01</endorsedTo><entityEndorsement>Endorsed DGR</entityEndorsement><itemNumber>Item 1</itemNumber></dgrEndorsement><mainName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2001-02-27</effectiveFrom></mainName><mainTradingName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2002-05-14</effectiveFrom></mainTradingName><legalName><givenName>testGivenName</givenName></legalName><exceptionDescription><exception>testGivenName</exception></exceptionDescription><mainBusinessPhysicalAddress><stateCode>VIC</stateCode><postcode>3004</postcode><effectiveFrom>2019-02-21</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></mainBusinessPhysicalAddress><charityType><charityTypeDescription>Public Benevolent Institution</charityTypeDescription><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></charityType><taxConcessionCharityEndorsement><endorsementType>GST Concession</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>FBT Exemption</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>Income Tax Exemption</endorsementType><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><businessName><organisationName>EMPOWER INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><ACNCRegistration><status>Registered</status><effectiveFrom>2012-12-03</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></ACNCRegistration></businessEntity201408></response></ABRPayloadSearchResults>';
                res.setBody(ABNResponse);             
                res.setStatusCode(200);   
                System.debug('response in test class : '+res);             
            }else{
            	res = h.send(req);
            }
            if (res.getStatusCode() == 200) {
                logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
            } else {
                logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus() + ': ' + res.getStatusCode(), '', false, false);
            }
            logger.exitLogger();
        } catch (Exception e) {
            System.debug('The following exception occurred: ' + e.getMessage());
            logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
            logger.exitLogger();
            return null;
        }
        return res;
    }

    public boolean callout(Account acct) {
        HttpResponse res = callABRService('ABRSearchByABN', acct.ABN__c);
        return handleResponse(res, acct);

        /* Logger2 logger = Logger2.getLogger('ABRSearchService');
         HttpResponse res = new HttpResponse();
         HttpRequest req = new HttpRequest();
         try{
             String payload = 'searchString=' + acct.ABN__c + '&includeHistoricalDetails=N&authenticationGuid=' + EnvironmentVariable.get('abn_validator_key');
             String endpoint = EnvironmentVariable.get('abn_validator_endpoint');
             //String endpoint = '';

             Http h = new Http();
             req = new HttpRequest();
             req.setEndpoint(endpoint);
             req.setMethod('GET');
             req.setBody(payload);

             res = h.send(req);
             if(res.getStatusCode() == 200){
                 logger.logMessages(req.getBody(), res.getBody(), '', '', '', '', false, false);
         
             } else {
                 logger.logMessages(req.getBody(), res.getBody(), '', '', res.getStatus()+': '+res.getStatusCode(), '', false, false);
             }

             logger.exitLogger();
             return handleResponse(res,acct);
         }
         catch(Exception e){
             System.debug('The following exception occurred: ' + e.getMessage());
             logger.logMessages(req.getBody(), res.getBody(), e.getStackTraceString(), 'Technical', 'Exception', e.getMessage(), false, false);
             logger.exitLogger();
             return isError;
         }*/
    }
    @testVisible
    private boolean handleResponse(HttpResponse res, Account acct) {
        System.debug('The res: ' + res.getBody());

        XmlStreamReader reader = res.getXmlStreamReader();

        while (reader.hasNext()) {

            if (reader.getEventType() == XmlTag.START_ELEMENT) {

                if (reader.getLocalName() == 'entityStatusCode') {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.ABN_Status__c = reader.getText();
                    }
                } else if (reader.getLocalName() == 'entityDescription') {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.ABN_Type__c = reader.getText();
                    }
                } else if (reader.getLocalName() == 'mainName') {
                    while (reader.hasNext()) {
                        if (reader.getLocalName() == 'organisationName')
                            break;
                        reader.next();
                    }
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.ABN_Registered_Name__c = reader.getText();
                    }
                } else if (reader.getLocalName() == 'mainTradingName') {
                    while (reader.hasNext()) {
                        if (reader.getLocalName() == 'organisationName')
                            break;
                        reader.next();
                    }
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.ABN_Trading_Name__c = reader.getText();
                    }
                } else if (reader.getLocalName() == 'legalName') {
                    while (reader.hasNext()) {
                        if (reader.getLocalName() == 'givenName')
                            break;
                        reader.next();
                    }
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.ABN_Registered_Name__c = reader.getText();
                    }
                } else if (reader.getLocalName() == 'exceptionDescription') {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS) {
                        acct.Error_description__c = reader.getText();
                        acct.ABN_Status__c = 'Error';
                        isError = true;
                    }
                }
            }

            reader.next();
        }

        update acct;
        return isError;
    }
}
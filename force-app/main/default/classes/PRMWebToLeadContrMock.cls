/*---------------------------
Class Created by Ayush(Appirio) 
for story number P2OB-7585 
Date - 30th June 2020
-----------------------------*/

@isTest
public class PRMWebToLeadContrMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        if(req.getEndpoint().endsWith('siteverify')){
            HttpResponse res = new HttpResponse();
            String resBody ='{"success": true}';
            res.setBody(resBody);             
            res.setStatusCode(200);
            return res;
        }
        else if(req.getEndpoint().endsWith('testOrgId')){
            HttpResponse res = new HttpResponse();
            String resBody ='{"success": true}';
            res.setBody(resBody);             
            res.setStatusCode(200);
            return res;
        }
        else{
            HttpResponse res = new HttpResponse();
            String ABNResponse='<ABRPayloadSearchResults xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://abr.business.gov.au/ABRXMLSearch/"><response><usageStatement>test</usageStatement><dateRegisterLastUpdated>2019-04-10</dateRegisterLastUpdated><dateTimeRetrieved>2019-04-10T20:03:00.4542021+10:00</dateTimeRetrieved><businessEntity201408><recordLastUpdatedDate>2019-04-09</recordLastUpdatedDate><ABN><identifierValue>78345431247</identifierValue><isCurrentIndicator>Y</isCurrentIndicator><replacedFrom>0001-01-01</replacedFrom></ABN><entityStatus><entityStatusCode>Active</entityStatusCode><effectiveFrom>2000-02-23</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></entityStatus><ASICNumber/><entityType><entityTypeCode>OIE</entityTypeCode><entityDescription>Other Incorporated Entity</entityDescription></entityType><goodsAndServicesTax><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></goodsAndServicesTax><dgrEndorsement><endorsedFrom>2000-07-01</endorsedFrom><endorsedTo>0001-01-01</endorsedTo><entityEndorsement>Endorsed DGR</entityEndorsement><itemNumber>Item 1</itemNumber></dgrEndorsement><mainName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2001-02-27</effectiveFrom></mainName><mainTradingName><organisationName>JEWISH CARE (VICTORIA) INC</organisationName><effectiveFrom>2002-05-14</effectiveFrom></mainTradingName><mainBusinessPhysicalAddress><stateCode>VIC</stateCode><postcode>3004</postcode><effectiveFrom>2019-02-21</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></mainBusinessPhysicalAddress><charityType><charityTypeDescription>Public Benevolent Institution</charityTypeDescription><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></charityType><taxConcessionCharityEndorsement><endorsementType>GST Concession</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>FBT Exemption</endorsementType><effectiveFrom>2005-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><taxConcessionCharityEndorsement><endorsementType>Income Tax Exemption</endorsementType><effectiveFrom>2000-07-01</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></taxConcessionCharityEndorsement><businessName><organisationName>EMPOWER INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE INTEREST FREE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER JEWISH CARE LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><businessName><organisationName>EMPOWER LOANS</organisationName><effectiveFrom>2016-10-07</effectiveFrom></businessName><ACNCRegistration><status>Registered</status><effectiveFrom>2012-12-03</effectiveFrom><effectiveTo>0001-01-01</effectiveTo></ACNCRegistration></businessEntity201408></response></ABRPayloadSearchResults>';
            res.setBody(ABNResponse);             
            res.setStatusCode(200);
            return res;
        }
    }
}
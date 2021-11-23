@isTest
public class ImportTCMCustomerByCIDNTest {
    
    @testSetup static void setup() {
        EnvironmentVariable.put('tcm_access_token', '1234');
        EnvironmentVariable.put('tcm_baseUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm');
        EnvironmentVariable.put('tcm_client_id', '1234');
        EnvironmentVariable.put('tcm_client_secret', '1234');
        EnvironmentVariable.put('tcm_contactEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/contacts');
        EnvironmentVariable.put('tcm_content-type', 'application/x-www-form-urlencoded');
        EnvironmentVariable.put('tcm_customer-accounts', '/customer-accounts/');
        EnvironmentVariable.put('tcm_customerEndpoint', 'https://cb.test.dev.telstra.com/org006/slot6/v1/customer-self-management/tcm/customer-accounts');
        EnvironmentVariable.put('tcm_grant_type', 'client_credentials');
        EnvironmentVariable.put('tcm_scope', 'CUSTOMERCONTACTRETRIEVAL');
		EnvironmentVariable.put('tcm_contact_scope', 'TCMCONTACT');
        EnvironmentVariable.put('tcm_tokenUrl', 'https://cb.test.dev.telstra.com/org006/slot6/v1/oauth/token');
		
        //Add data for ASIC__c object.
        final ASIC__c asicCode ;
        asicCode = new ASIC__c(Name='Test Name',Industry__c='Test Industry',SIC_Code__c='38473');
        insert asicCode;
        final ValidationRuleErrors__c validationRuleErrors ;
        validationRuleErrors=new ValidationRuleErrors__c();
        validationRuleErrors.Name='VR0027';
        validationRuleErrors.Value__c='Bus./Last Name must not contain invalid characters';
        insert validationRuleErrors;
    }
    
    static testMethod void customerContactImport200Invalid(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_200_WS0002');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport_200_Invalid_1(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_200_WS0002');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938 ;
        importCustomerByCIDN_8856220938= new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938 ;
        importCustomerResult_8856220938    = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertNotEquals(Null, importCustomerResult_8856220938.errorCode);
        Test.stopTest();
    }
    
    static testMethod void customerContactImport_400(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_400_WS0001');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Bad Request');
        multimock.setStatusCode(400);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778 ;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();
    }

    static testMethod void customerContactImport4001(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_400_WS0001');
        multimock.setStatus('Bad Request');
        multimock.setStatusCode(400);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938 ;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport401(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock ;
        multimock= new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_401');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Unauthorized');
        multimock.setStatusCode(401);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();
    }
   
    static testMethod void customerContactImport4011(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_401');
        multimock.setStatus('Unauthorized');
        multimock.setStatusCode(401);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport403(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_403');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Forbidden');
        multimock.setStatusCode(403);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();        
    }
    
    static testMethod void customerContactImport4031(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_403');
        multimock.setStatus('Forbidden');
        multimock.setStatusCode(403);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938 ;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();        
    }
    
    static testMethod void customerContactImport404(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_404');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Not Found');
        multimock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport4041(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_404');
        multimock.setStatus('Not Found');
        multimock.setStatusCode(404);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938 ;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport405(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_405');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Method not allowed');
        multimock.setStatusCode(405);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778 ;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778 ;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport4051(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_405');
        multimock.setStatus('Method not allowed');
        multimock.setStatusCode(405);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938 ;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();
    }
    
    static testMethod void customerContactImport415(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_415');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Unsupported Media Type');
        multimock.setStatusCode(415);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();        
    }
    
    static testMethod void customerContactImport4151(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_415');
        multimock.setStatus('Unsupported Media Type');
        multimock.setStatusCode(415);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();        
    }
    
    static testMethod void customerContactImport500(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_500_GEN_0001');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('Internal Server Error');
        multimock.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778 ;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_7899251778.errorCode,'Error');
        Test.stopTest();        
    }
   
    static testMethod void customerContactImport5001(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock ;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_500_GEN_0001');
        multimock.setStatus('Internal Server Error');
        multimock.setStatusCode(500);
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938 ;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938 ;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_8856220938.errorCode,'Error');
        Test.stopTest();        
    }
    
    static testMethod void customerContactImport200Valid(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_getcustomer_7899251778');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_8856220938');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_7899251778;
        importCustomerByCIDN_7899251778 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_7899251778;
        importCustomerResult_7899251778 = importCustomerByCIDN_7899251778.importCustomerAndContactbyCIDN('7899251778',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.debug('Error' + importCustomerResult_7899251778.errorDescription);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_SUCCESS, importCustomerResult_7899251778.errorCode);
        /*ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        ImportTCMCustomerResult importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);*/
        Test.stopTest();
    }
    
    static testMethod void customerContactImport200Valid1(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=8856220938&limit=50&offset=0', 'tcm_getcustomer_8856220938');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157367?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_8856220938');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_8856220938;
        importCustomerByCIDN_8856220938 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_8856220938;
        importCustomerResult_8856220938 = importCustomerByCIDN_8856220938.importCustomerAndContactbyCIDN('8856220938',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_SUCCESS, importCustomerResult_8856220938.errorCode);
        Test.stopTest();
    }
    
	static testMethod void importCustomerManually200Valid(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock;
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=7899251778&limit=50&offset=0', 'tcm_getcustomer_7899251778');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000157370?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_7899251778');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final TCMCustomerImportByCIDN importCustomerByCIDN ;
        importCustomerByCIDN = new TCMCustomerImportByCIDN();
        importCustomerByCIDN.tcmObjects('7899251778');
        importCustomerByCIDN.createTCMCustomer('7899251778');
        System.assertNotEquals(null, importCustomerByCIDN.tcmCustomer.Id);
        Test.stopTest();
    }
    
	static testMethod void customerContactImport200ValidNewFailing(){
        Test.startTest();
        final MultiStaticResourceCalloutMock multimock; 
        multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource(EnvironmentVariable.get('tcm_tokenUrl'), 'tcmaccesstoken');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts?cidn=2859980271&limit=50&offset=0', 'tcm_getcustomer_2859980271');
        multimock.setStaticResource(EnvironmentVariable.get('tcm_baseUrl')+'/customer-accounts/10000020676?limit=50&offset=0&include=contacts', 'tcm_getcustomercontact_2859980271');
        multimock.setStatus('status');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, multimock);
        final ImportTCMCustomerByCIDN importCustomerByCIDN_2859980271;
        importCustomerByCIDN_2859980271 = new ImportTCMCustomerByCIDN();
        final ImportTCMCustomerResult importCustomerResult_2859980271;
        importCustomerResult_2859980271= importCustomerByCIDN_2859980271.importCustomerAndContactbyCIDN('2859980271',ImportTCMCustomerByCIDN.SourceFrom.SEEDING);
        System.assertEquals(TCMCustomerContactConstants.TCMERRORCODE_FAILURE, importCustomerResult_2859980271.errorCode,'Error');
        Test.stopTest();
    }
    

    
}
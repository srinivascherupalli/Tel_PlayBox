@isTest
    public class AppointmentRequestDTOTest {
        @isTest
        public static void testparsesuccess(){
            String json='{"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","data":{"ruleSetID":"B2B_Amdocs","transactionType":"Connect","state":"NSW","locationType":"METRO","complexityBand":"STD","transactionReferenceID":"MyOrderNumber123","transactionProducts":[{"productAction":"ADD","productID":"DMCAT_Offer_000303","productInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82"},{"productAction":"ADD","productID":"DMCAT_ProductSpecification_000027","productInstanceID":"9c7ab03e-8de7-b7fa-c48d-72e2b48d01fb","parentProductInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82","productParameters":[{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"},{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"}]}]}}';
            Test.startTest();
            AppointmentRequestDTO appReq= AppointmentRequestDTO.parse(json);
            Test.stopTest();
            
            System.assert(appReq.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
            System.assert(appReq.data.ruleSetID =='B2B_Amdocs');
            System.assert(appReq.data.transactionType =='Connect');
            System.assert(appReq.data.state =='NSW');
            System.assert(appReq.data.locationType =='METRO');
            System.assert(appReq.data.complexityBand =='STD');
            System.assert(appReq.data.transactionReferenceID =='MyOrderNumber123');
            System.assert(appReq.data.transactionProducts[0].productAction =='ADD');
            System.assert(appReq.data.transactionProducts[0].productID =='DMCAT_Offer_000303');
            System.assert(appReq.data.transactionProducts[0].productInstanceID =='877ca8f5-2487-752c-ad43-5b6dba91fe82');
            System.assert(appReq.data.transactionProducts[1].productAction =='ADD');
            System.assert(appReq.data.transactionProducts[1].productID =='DMCAT_ProductSpecification_000027');
            System.assert(appReq.data.transactionProducts[1].productInstanceID =='9c7ab03e-8de7-b7fa-c48d-72e2b48d01fb');
            System.assert(appReq.data.transactionProducts[1].parentProductInstanceID =='877ca8f5-2487-752c-ad43-5b6dba91fe82');
            System.assert(appReq.data.transactionProducts[1].productParameters[0].parameterName =='Access Technology');
            System.assert(appReq.data.transactionProducts[1].productParameters[0].parameterValue =='Telstra Fibre Access');
            System.assert(appReq.data.transactionProducts[1].productParameters[1].parameterName =='Access Technology');
            System.assert(appReq.data.transactionProducts[1].productParameters[1].parameterName =='Access Technology');
        }
    }
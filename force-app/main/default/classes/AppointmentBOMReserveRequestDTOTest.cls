/* Description: Test class Request DTO for Appointment BOM Reserve EDGE-66238
   Author: Aishwarya Yeware */

        @isTest
        public class AppointmentBOMReserveRequestDTOTest {
     /*------------------------------------------------------------ 
    Author: Aishwarya
    US: EDGE-66238  
    Description: parse json response for Schedule Success
    ------------------------------------------------------------*/
            @isTest
            public static void testParsesuccess(){
                string json='{"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","data":{"transactionReferenceID":"MyOrder456","appointment":{"appointmentCategory":"TELSTRA","appointmentType":"ORDER INSTALL","appointmentSubType":"EXCHANGE","contacts":[{"fullName":"John Smith","givenName":"John","familyName":"Smith","phoneNumber":67183835,"role":"PRIMARY"}],"relatedParty":{"name":"ACME Services PTY LTD","role":"CUSTOMER","type":"SMALL BUSINESS"},"note":{"text":"Ring the bell and ask for loading dock access"},"appointmentExtendedDetails":{"extensionType":"TELSTRA_PRODUCT_CHARACTERISTICS","extensionName":"SerialNumber","extensionNameQualifier":"e35736a9-a3e3-3907-bd8d-61dfb2639a46","extensionValue":"1F:34:22:e4:3e:dd","extensionValueQualifier":"string"}}}}';
                //String json='{"correlationId":"e8314645-c0fe-42a7-beac-2e64f8b3ebcf","data":{"ruleSetID":"B2B_Amdocs","transactionType":"Connect","state":"NSW","locationType":"METRO","complexityBand":"STD","transactionReferenceID":"MyOrderNumber123","transactionProducts":[{"productAction":"ADD","productID":"DMCAT_Offer_000303","productInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82"},{"productAction":"ADD","productID":"DMCAT_ProductSpecification_000027","productInstanceID":"9c7ab03e-8de7-b7fa-c48d-72e2b48d01fb","parentProductInstanceID":"877ca8f5-2487-752c-ad43-5b6dba91fe82","productParameters":[{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"},{"parameterName":"Access Technology","parameterValue":"Telstra Fibre Access"}]}]}}';
                Test.startTest();
                AppointmentBOMReserveRequestDTO appReq= AppointmentBOMReserveRequestDTO.parse(json);
                Test.stopTest();
                
                System.assert(appReq.correlationId =='e8314645-c0fe-42a7-beac-2e64f8b3ebcf');
               /* System.assert(appReq.data.ruleSetID =='B2B_Amdocs');
                System.assert(appReq.data.transactionType =='Connect');
                System.assert(appReq.data.state =='NSW');
                System.assert(appReq.data.locationType =='METRO');
                System.assert(appReq.data.complexityBand =='STD');*/
                System.assert(appReq.data.transactionReferenceID =='MyOrder456');
                System.assert(appReq.data.appointment.appointmentCategory =='TELSTRA');
                System.assert(appReq.data.appointment.appointmentType =='ORDER INSTALL');
                System.assert(appReq.data.appointment.appointmentSubType =='EXCHANGE');
                System.assert(appReq.data.appointment.contacts[0].fullName =='John Smith');
                System.assert(appReq.data.appointment.contacts[0].fullName =='John Smith');
                System.assert(appReq.data.appointment.contacts[0].givenName =='John');
                System.assert(appReq.data.appointment.contacts[0].familyName =='Smith');
                System.assert(appReq.data.appointment.contacts[0].phoneNumber =='67183835');
                System.assert(appReq.data.appointment.contacts[0].role =='PRIMARY');
                System.assert(appReq.data.appointment.relatedParty.name =='ACME Services PTY LTD');
                System.assert(appReq.data.appointment.relatedParty.role =='CUSTOMER');

                System.assert(appReq.data.appointment.relatedParty.type =='SMALL BUSINESS');
                System.assert(appReq.data.appointment.note.text =='Ring the bell and ask for loading dock access');
                System.assert(appReq.data.appointment.appointmentExtendedDetails.extensionType =='TELSTRA_PRODUCT_CHARACTERISTICS');
                System.assert(appReq.data.appointment.appointmentExtendedDetails.extensionName =='SerialNumber');
                System.assert(appReq.data.appointment.appointmentExtendedDetails.extensionNameQualifier =='e35736a9-a3e3-3907-bd8d-61dfb2639a46');
                System.assert(appReq.data.appointment.appointmentExtendedDetails.extensionValue =='1F:34:22:e4:3e:dd');
                System.assert(appReq.data.appointment.appointmentExtendedDetails.extensionValueQualifier =='string');




                        
               
                
            }
        }
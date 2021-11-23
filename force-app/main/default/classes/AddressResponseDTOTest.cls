@IsTest
public class AddressResponseDTOTest {
    static testMethod void testParseParent(){
        String json = '{'+
            '   \"code\": 200,'+
            '   \"time\": \"2016-08-16T10:53:09+10:00\",'+
            '   \"data\": {'+
            '       \"transactionStatus\": \"success\",'+
            '       \"structured\": {'+
            '           \"addresses\": {'+
            '               \"addressSummaryType\": \"PropertyAddressSummary\",'+
            '               \"addressId\": 180057100,'+
            '               \"addressType\": \"Property With Number\",'+
            '               \"confirmed\": true,'+
            '               \"subAddressType\": \"\",'+
            '               \"planNumber\": \"DP1135205\",'+
            '               \"parceltype1\": \"F\",'+
            '               \"parceldescriptiontype1\": \"L\",'+
            '               \"parcelDescriptor1 \": 1,'+
            '               \"parceltype2\": \"\",'+
            '               \"parceldescriptiontype2\": \"\",'+
            '               \"parcelDescriptor2\": \"\",'+
            '               \"name\": \"\",'+
            '               \"ruralmailNumber\": \"\",'+
            '               \"ruralmailType\": \"\",'+
            '               \"fsam\": \"\",'+
            '               \"condorCode\": \"WLNGNG\",'+
            '               \"reqaddformatout\": \"structured\",'+
            '               \"postcode\": 2500,'+
            '               \"state\": \"NSW\",'+
            '               \"localityName\": \"WOLLONGONG\",'+
            '               \"streetName\": \"CROWN\",'+
            '               \"streetType\": \"STREET\",'+
            '               \"streetSuffix\": \"\",'+
            '               \"numSubaddresses\": 7,'+
            '               \"subaddresses\": {'+
            '                   \"SubAddresses\": {'+
            '                       \"Level1\": [{'+
            '                           \"SubAddressType\": \"BUILDING\",'+
            '                           \"parentID\": 180057100,'+
            '                           \"ID\": 426860877,'+
            '                           \"BUname\": \"EUREKA TOWER\",'+
            '                           \"AddressType\": \"abc\",'+
            '                           \"from\": 1,'+
            '                           \"Level2\": [{'+
            '                                   \"SubAddressType\": \"Ground Floor\",'+
            '                                   \"parentID\": 426860877,'+
            '                                   \"ID\": 419594516,'+
            '                                   \"AddressType\": \"Complex - Floor/Level\",'+
            '                                   \"Level3\": [{'+
            '                                           \"SubAddressType\": \"Unit\",'+
            '                                           \"parentID\": 419594516,'+
            '                                           \"ID\": 426978197,'+
            '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
            '                                           \"from\": 1,'+
            '                                           \"Confirmed\": true'+
            '                                       },'+
            '                                       {'+
            '                                           \"SubAddressType\": \"Unit\",'+
            '                                           \"parentID\": 419594516,'+
            '                                           \"ID\": 426878193,'+
            '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
            '                                           \"from\": 2,'+
            '                                           \"Confirmed\": true'+
            '                                       },'+
            '                                       {'+
            '                                           \"SubAddressType\": \"Unit\",'+
            '                                           \"parentID\": 419594516,'+
            '                                           \"ID\": 426978198,'+
            '                                           \"AddressType\": \" Complex - Flat/Unit\",'+
            '                                           \"from\": 3,'+
            '                                           \"Confirmed\": true'+
            '                                       }'+
            '                                   ],'+
            '                                   \"Confirmed\": true'+
            '                               },'+
            '                               {'+
            '                                   \"SubAddressType\": \"Level\",'+
            '                                   \"parentID\": 426860877,'+
            '                                   \"ID\": 419794487,'+
            '                                   \"AddressType\": \"Complex - Floor/Level\",'+
            '                                   \"from\": 1,'+
            '                                   \"Confirmed\": true'+
            '                               },'+
            '                               {'+
            '                                   \"SubAddressType\": \"Level\",'+
            '                                   \"parentID\": 426860877,'+
            '                                   \"ID\": 419787211,'+
            '                                   \"AddressType\": \"Complex - Floor/Level\",'+
            '                                   \"from\": 2,'+
            '                                   \"Confirmed\": true'+
            '                               }'+
            '                           ],'+
            '                           \"Confirmed\": true'+
            '                       }]'+
            '                   }'+
            '               },'+
            '               \"propertyName\": \"\",'+
            '               \"propertyNumberFrom\": 121,'+
            '               \"propertyNumberTo\": 0,'+
            '               \"propertyNumberSuffixFrom\": \"\",'+
            '               \"propertyNumberSuffixTo\": \"\"'+
            '           },'+
            '           \"serviceLocation\": {'+
            '               \"readyForServiceDate\": \"\",'+
            '               \"locationId\": \"\",'+
            '               \"facsRealm\": 74,'+
            '               \"exchangeServiceArea\": \"WLGG\",'+
            '               \"customerServiceAreaId\": \"\",'+
            '               \"latitude\": \"-34:25:33.4\",'+
            '               \"longitude\": \"150:53:46.9\"'+
            '           }'+
            '       },'+
            '       \"unstructuredAUPost\": {'+
            '           \"addresses\": {'+
            '               \"addressSummaryType\": \"FormattedAddressSummary\",'+
            '               \"addressId\": 180057100,'+
            '               \"addressType\": \"Property Address With Number\",'+
            '               \"confirmed\": true,'+
            '               \"parcelDescriptor2\": \"\",'+
            '               \"parcelDescriptor1 \": 1,'+
            '               \"planNumber\": \"DP1135205\",'+
            '               \"ruralmailNumber\": \"\",'+
            '               \"subAddressType\": \"\",'+
            '               \"parceltype2\": \"\",'+
            '               \"parceltype1\": \"F\",'+
            '               \"parceldescriptiontype1\": \"L\",'+
            '               \"parceldescriptiontype2\": \"\",'+
            '               \"propertyName\": \"\",'+
            '               \"fsam\": \"\",'+
            '               \"condorCode\": \"WLNGNG\",'+
            '               \"reqaddformatout\": \"unstructuredAUPost\",'+
            '               \"postcode\": 2500,'+
            '               \"state\": \"NSW\",'+
            '               \"localityName\": \"WOLLONGONG\",'+
            '               \"addressline1\": \"121 CROWN ST,\",'+
            '               \"addressline2\": \"\",'+
            '               \"addressline3\": \"\"'+
            '           },'+
            '           \"serviceLocation\": {'+
            '               \"readyForServiceDate\": \"\",'+
            '               \"locationId\": \"\",'+
            '               \"facsRealm\": 74,'+
            '               \"exchangeServiceArea\": \"WLGG\",'+
            '               \"customerServiceAreaId\": \"\",'+
            '               \"latitude\": \"-34:25:33.4\",'+
            '               \"longitude\": \"150:53:46.9\"'+
            '           }'+
            '       }'+
            '   }'+
            '}';
        AddressResponseDTO obj = AddressResponseDTO.parse(json);
        System.assert(obj != null); 
    }
    
    
    static testMethod void testParseChild() {
        String json = '{'+
            '    \"code\": 200,'+
            '    \"status\": 200,'+
            '    \"time\": \"2017-09-25T16:27:21+10:00\",'+
            '    \"data\": {'+
            '        \"transactionStatus\": \"Success\",'+
            '        \"matchingresultscount\": 1,'+
            '        \"structured\": {'+
            '            \"addresses\": {'+
            '                \"addressSummaryType\": \"SubAddressSummary\",'+
            '                \"addressId\": \"418853815\",'+
            '                \"addressType\": \"Complex - Flat/Unit\",'+
            '                \"confirmed\": true,'+
            '                \"reqaddformatout\": \"structured\",'+
            '                \"subAddressNumberFrom\": \"3411\",'+
            '                \"parcelDescriptor1\": \"3411\",'+
            '                \"condorCode\": \"STHBNK\",'+
            '                \"fsam\": \"3SYR-02\",'+
            '                \"subAddressType\": \"UNIT\",'+
            '                \"numSubaddresses\": 0,'+
            '                \"subAddressCodeset\": \"UNIT\",'+
            '                \"parent\": {'+
            '                    \"addressSummaryType\": \"SubAddressSummary\",'+
            '                    \"addressId\": \"265083283\",'+
            '                    \"addressType\": \"Complex - Floor/Level\",'+
            '                    \"confirmed\": true,'+
            '                    \"reqaddformatout\": \"structured\",'+
            '                    \"numSubaddresses\": 10,'+
            '                    \"subAddressCodeset\": \"LEVEL\",'+
            '                    \"subAddressNumberFrom\": \"34\",'+
            '                    \"parcelDescriptor1\": \"34\",'+
            '                    \"condorCode\": \"STHBNK\",'+
            '                    \"subAddressType\": \"LEVEL\",'+
            '                    \"serviceLocation\": {'+
            '                        \"latitude\": \"-37:49:18.2\",'+
            '                        \"longitude\": \"144:57:53.1\"'+
            '                    },'+
            '                    \"parent\": {'+
            '                        \"addressSummaryType\": \"SubAddressSummary\",'+
            '                        \"addressId\": \"265082901\",'+
            '                        \"addressType\": \"Complex - Building with Name\",'+
            '                        \"confirmed\": true,'+
            '                        \"reqaddformatout\": \"structured\",'+
            '                        \"numSubaddresses\": 679,'+
            '                        \"subAddressCodeset\": \"BUILDING\",'+
            '                        \"name\": \"EUREKA TOWER\",'+
            '                        \"condorCode\": \"STHBNK\",'+
            '                        \"subAddressType\": \"BUILDING\",'+
            '                        \"serviceLocation\": {'+
            '                            \"latitude\": \"-37:49:18.2\",'+
            '                            \"longitude\": \"144:57:53.1\"'+
            '                        },'+
            '                        \"parent\": {'+
            '                            \"addressSummaryType\": \"PropertyAddressSummary\",'+
            '                            \"addressId\": \"417085878\",'+
            '                            \"addressType\": \"Property with Number\",'+
            '                            \"confirmed\": true,'+
            '                            \"reqaddformatout\": \"structured\",'+
            '                            \"numSubaddresses\": 688,'+
            '                            \"streetType\": \"QUAY\",'+
            '                            \"propertyNumberFrom\": 7,'+
            '                            \"propertyNumberTo\": \"\",'+
            '                            \"postcode\": \"3006\",'+
            '                            \"state\": \"VIC\",'+
            '                            \"localityName\": \"SOUTHBANK\",'+
            '                            \"planNumber\": \"PS437659\",'+
            '                            \"parcelDescriptor1\": \"1R-8901\",'+
            '                            \"parcelDescriptionType1\": \"L\",'+
            '                            \"parcelType1\": \"F\",'+
            '                            \"condorCode\": \"STHBNK\",'+
            '                            \"serviceLocation\": {'+
            '                                \"exchangeServiceArea\": \"SMEL\",'+
            '                                \"facsRealm\": \"17\",'+
            '                                \"latitude\": \"-37:49:18.2\",'+
            '                                \"longitude\": \"144:57:53.1\"'+
            '                            }'+
            '                        }'+
            '                    }'+
            '                },'+
            '                \"primarySummary\": {'+
            '                    \"addressId\": \"417085878\",'+
            '                    \"addressType\": \"Property with Number\",'+
            '                    \"confirmed\": true,'+
            '                    \"reqaddformatout\": \"structured\",'+
            '                    \"localityName\": \"SOUTHBANK\",'+
            '                    \"state\": \"VIC\",'+
            '                    \"postcode\": \"3006\",'+
            '                    \"propertyNumberFrom\": 7,'+
            '                    \"propertyNumberTo\": \"\",'+
            '                    \"numSubaddresses\": 688,'+
            '                    \"streetType\": \"QUAY\",'+
            '                    \"streetName\": \"RIVERSIDE\",'+
            '                    \"planNumber\": \"PS437659\",'+
            '                    \"parcelDescriptor1\": \"1R-8901\",'+
            '                    \"parcelDescriptionType1\": \"L\",'+
            '                    \"parcelType1\": \"F\",'+
            '                    \"condorCode\": \"STHBNK\",'+
            '                    \"serviceLocation\": {'+
            '                        \"facsRealm\": \"17\",'+
            '                        \"exchangeServiceArea\": \"SMEL\",'+
            '                        \"latitude\": \"-37:49:18.2\",'+
            '                        \"longitude\": \"144:57:53.1\"'+
            '                    }'+
            '                }'+
            '            },'+
            '            \"serviceLocation\": {'+
            '                \"latitude\": \"-37:49:18.2\",'+
            '                \"longitude\": \"144:57:53.1\",'+
            '                \"locationId\": \"LOC000027969270\",'+
            '                \"customerServiceAreaId\": \"CSA300000001055\",'+
            '                \"readyForServiceDate\": \"2015-10-16\"'+
            '            }'+
            '        },'+
            '        \"unstructuredAUPost\": {'+
            '            \"addresses\": {'+
            '                \"addressSummaryType\": \"FormattedAddressSummary\",'+
            '                \"addressId\": \"418853815\",'+
            '                \"addressType\": \"Complex - Flat/Unit\",'+
            '                \"reqaddformatout\": \"unstructuredAUPost\",'+
            '                \"confirmed\": true,'+
            '                \"postcode\": \"3006\",'+
            '                \"state\": \"VIC\",'+
            '                \"localityName\": \"SOUTHBANK\",'+
            '                \"parcelDescriptor1\": \"3411\",'+
            '                \"condorCode\": \"STHBNK\",'+
            '                \"fsam\": \"3SYR-02\",'+
            '                \"subAddressType\": \"UNIT\",'+
            '                \"addressline1\": \"EUREKA TOWER, L 34, U 3411,\",'+
            '                \"addressline2\": \"7 RIVERSIDE QY,\"'+
            '            },'+
            '            \"serviceLocation\": {'+
            '                \"latitude\": \"-37:49:18.2\",'+
            '                \"longitude\": \"144:57:53.1\",'+
            '                \"locationId\": \"LOC000027969270\",'+
            '                \"customerServiceAreaId\": \"CSA300000001055\",'+
            '                \"readyForServiceDate\": \"2015-10-16\"'+
            '            }'+
            '        }'+
            '    },'+
            '    \"request\": {'+
            '        \"params\": {'+
            '            \"addressId\": \"418853815\",'+
            '            \"reqaddformatout\": \"unstructuredAUPost,structured\"'+
            '        },'+
            '        \"data\": {},'+
            '        \"path\": \"/addresses/:addressId\",'+
            '        \"method\": \"GET\",'+
            '        \"requestId\": \"da973b8f-5e08-46e0-b7a4-758c474fdde9\",'+
            '        \"correlationId\": \"79fb3257-2bc1-4312-bef8-d384a53813de\"'+
            '    },'+
            '    \"correlationId\": \"79fb3257-2bc1-4312-bef8-d384a53813de\"'+
            '}';
        AddressResponseDTO obj = AddressResponseDTO.parse(json);
        System.assert(obj != null); 
    }
    /*------------------------------------------------------------ 
Method: parse_unstruct 
Description: Parse addressSQ response for auto-complete search
Inputs: response json
Returns:  AddressResponseDTO
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testParse_unstruct() {
        String json = '{"correlationId":"515f3ae5-fad5-4786-9515-db7f825546fc","requestId":"9ecce65d-04a7-4819-b596-a2f959a78884","results":[{"source":"experian","position":0,"raw":"AUE&#124;0bf29ee6-79bb-4084-8cbd-32bf642d6c5a&#124;0MOAUEGwjiBwAAAAAIAwEAAAAA4A5kEAAhAA4AAAAAAAAAAAD..2QAAAAA.....wAAAAAAAAAAAAAAAAA0MDAgR2VvcmdlIFN0cmVldCBTeWRuZXkA$24","name":"400 George Street, SYDNEY  NSW  2000"}]}';
        Test.startTest();
        AddressResponseDTO dto = AddressResponseDTO.parse_unstruct(json);
        Test.stopTest();
        System.assertEquals(dto!=null, true,'DTO created');
    }
     /*------------------------------------------------------------ 
EDGE - 76217
Method: parse_unstruct 
Description: Parse addressSQ response for auto-complete search
Inputs: response json
Returns:  AddressResponseDTO
History 
<18-04-2019> <Kalashree Borgaonkar>
------------------------------------------------------------*/
    static testMethod void testparseStructure() {
      	String jsonResponse='{"code":200,"status":200,"time":"2019-04-01T14:24:14+10:00","data":{"structured":[{"addressSummaryType":"PropertyAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","subAddressNumberFrom":"0","condorCode":"MELBRNE","fsam":"test","numSubaddresses":253,"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265056301","addressType":"Complex - Floor/Level","confirmed":true,"reqaddformatout":"structured","numSubaddresses":20,"subAddressCodeset":"LEVEL","subAddressNumberFrom":"2","parcelDescriptor1":"2","condorCode":"MELBRNE","subAddressType":"LEVEL","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"parent":{"addressSummaryType":"SubAddressSummary","addressId":"265056108","addressType":"Complex - Building with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":252,"subAddressCodeset":"BUILDING","subAddressNumberFrom":"1","parcelDescriptor1":"1","condorCode":"MELBRNE","subAddressType":"BUILDING","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"parent":{"addressSummaryType":"PropertyAddressSummary","addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","numSubaddresses":253,"streetType":"ROAD","propertyNumberFrom":74,"propertyNumberTo":"","postcode":"3004","state":"VIC","localityName":"MELBOURNE","planNumber":"PS641029","parcelDescriptor1":"1-1216","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"MELBRNE","serviceLocation":{"exchangeServiceArea":"WIRC","facsRealm":"18","latitude":"-37:51:07.7","longitude":"144:58:47.8"}}}},"parcelDescriptionType1":"test","postalDeliveryNumber":"test","postalDeliveryType":"test","parcelType1":"test","ruralmailNumber":"test","postcode":"3004","state":"VIC","localityName":"MELBOURNE","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8","facsRealm":"18","exchangeServiceArea":"WIRC"},"planNumber":"PS641029","parcelNumber":"1-1216","parcelType":"Lot","parcelDescriptor1Prefix":"F","propertyNumberFrom":74,"propertyNumberTo":"","streetName":"QUEENS","streetType":"ROAD","subaddresses":{"Level1":[{"AddressType":"Complex - Building with Number","SubAddressType":"BUILDING","ID":265056108,"parentID":161339881,"Confirmed":true,"from":1,"Level2":[{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056350,"parentID":265056108,"Confirmed":true,"from":1},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056351,"parentID":265056108,"Confirmed":true,"from":2},{"AddressType":"Complex - Floor/Level","SubAddressType":"BASEMENT","ID":265056352,"parentID":265056108,"Confirmed":true,"from":3},{"AddressType":"Complex - Floor/Level","SubAddressType":"GROUND / GROUND FLOOR","ID":265056343,"parentID":265056108,"Confirmed":true,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427633640,"parentID":265056343,"Confirmed":true,"from":"FIP"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"ROOM","ID":427733640,"parentID":265056343,"Confirmed":true,"from":"SECURIT"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":426798195,"parentID":265056343,"Confirmed":true,"from":"GYM"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427635852,"parentID":265056343,"Confirmed":true,"from":"OFFICE"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":427735852,"parentID":265056343,"Confirmed":true,"from":"PUBLIC"},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056344,"parentID":265056343,"Confirmed":true,"from":1},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056345,"parentID":265056343,"Confirmed":true,"from":2},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056346,"parentID":265056343,"Confirmed":true,"from":3},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056347,"parentID":265056343,"Confirmed":true,"from":4},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056348,"parentID":265056343,"Confirmed":true,"from":5},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056349,"parentID":265056343,"Confirmed":true,"from":6}]},{"AddressType":"Complex - Floor/Level","SubAddressType":"LEVEL","ID":265056322,"parentID":265056108,"Confirmed":true,"from":1,"Level3":[{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056323,"parentID":265056322,"Confirmed":true,"from":101},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056324,"parentID":265056322,"Confirmed":true,"from":102},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056325,"parentID":265056322,"Confirmed":true,"from":103},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056326,"parentID":265056322,"Confirmed":true,"from":104},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056327,"parentID":265056322,"Confirmed":true,"from":105},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056328,"parentID":265056322,"Confirmed":true,"from":106},{"AddressType":"Complex - Flat/Unit","SubAddressType":"UNIT","ID":265056329,"parentID":265056322,"Confirmed":true,"from":107}]}]}]},"primarySummary":{"addressId":"161339881","addressType":"Property with Number","confirmed":true,"reqaddformatout":"structured","localityName":"MELBOURNE","state":"VIC","postcode":"3004","propertyNumberFrom":74,"propertyNumberTo":"","numSubaddresses":253,"streetType":"ROAD","streetName":"QUEENS","planNumber":"PS641029","parcelDescriptor1":"1-1216","parcelDescriptionType1":"L","parcelType1":"F","condorCode":"MELBRNE","serviceLocation":{"facsRealm":"18","exchangeServiceArea":"WIRC","latitude":"-37:51:07.7","longitude":"144:58:47.8"}}}],"unstructuredAUPost":[{"addressSummaryType":"FormattedAddressSummary","addressId":"161339881","addressType":"Property with Number","reqaddformatout":"unstructuredAUPost","confirmed":true,"postcode":"3004","state":"VIC","localityName":"MELBOURNE","condorCode":"MELBRNE","addressline1":"74 QUEENS RD,","serviceLocation":{"latitude":"-37:51:07.7","longitude":"144:58:47.8"},"planNumber":"PS641029","parcelNumber":"1-1216","parcelType":"Lot","parcelDescriptor1Prefix":"F"}],"resultCount":25},"request":{"params":{"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"data":{"searchOptions":{"responseFormats":["unstructuredAUPost","structured"],"fuzzyOptions":{"enabled":true},"addressType":"ServiceAddress","addressesToSkip":0,"addressesToReturn":25},"searchData":{"suburb":"MELBOURNE","streetNumber":"74","streetName":"Queens","state":"VIC","postcode":"3004"}},"path":"/structured","method":"POST","requestId":"011a0183-cbc6-4278-ac29-510b224ca866","correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"},"correlationId":"48d2c76b-b226-41ec-4695-66ceeff5a015"}';
        Test.startTest();
        AddressResponseDTO dto = AddressResponseDTO.parseStructure(jsonResponse);
        Test.stopTest();
        System.assertEquals(dto!=null, true,'DTO created');
    }
}
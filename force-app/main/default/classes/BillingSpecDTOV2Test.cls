/********************************************************
Class Name      :   BillingSpecDTOV2Test
===============================================================================================================================
Change.No.    Developer Name          Date          Story Description
1.            Prajakta Patil        15/10/19        EDGE-115840
2.            Vaibhav Deshpande     29/01/2020      EDGE-132475
3.            Pawan                 30/06/2020      EDGE-156163
4.            Vaibhav Deshpande     17/07/2020      EDGE-148819
5.            Vaibhav Deshpande     21/07/2020      EDGE-153454
6.            Pawan                 30/06/2020      EDGE-164355
7.            Prajakta              15/10/2020      EDGE-174931
**********************************************************
*/
@IsTest
public class BillingSpecDTOV2Test {
    
    static testMethod void testParse() {
        String json=    '{'+
            '    "billingAccountNumber": 700000000012,'+
            '    "productOffering":'+
            '        {'+
            '            "invoiceDefinition": "Invoice_Def_1",'+
            '            "productInstanceId": "SN-000033817",'+
            '       "offerId": "DMCAT_Offer_000303",'+
            '            "description": "Connected Workplace Package",'+
            '            "offerInstanceId": "SN-000033817"'+
            '        },'+
            '    "additionalBillInfo":'+
            '        [{'+
            '            "name": "siteName",'+
            '            "value": "150 Lonsdale Street"'+
            '        }'+
            '    ],'+
            '    "productActionType": "add",'+
            '    "orderReference": "CN-120-138",'+
            '    "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '    "orderItems": ['+
            '        {'+
            '            "description": "CWP IP Site",'+
            '            "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '            "serviceInstanceId":"a4e2O0000003PBJQA3",'+
            '            "productId": "DMCAT_ProductSpecification_000099",'+
            '            "productActionType": "add",'+
            '            "orderReference": "CN-120-138",'+
            '            "services":[ {'+
            '                "serviceId": "61432456344",'+
            '                "actionCode": "add",'+
            '                "serviceType": "Mobile",'+
            '                "imsi": "505234556666244",'+
            '         "oldServiceId": "61432456343"'+
            '            }'+
            '            ],'+
            '            "billingSpecifications": ['+
            '            {'+
            '                "instanceId": "b8905354-a164-b480-9fb2-75c2d1a8499a1",'+
            '                "actionCode": "add",'+
            '                "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '                "description": "CWP Mobile Interim Access Allowance",'+
            '                "billingSpecId": "BSUSG001_CB",'+
            '                "ocsProductId": "B2BOCSProd1",'+
            '                "durationValue": 24,'+
            '                "durationUnit": "Months",'+
            '                "taxTreatment": "GST Applicable"'+
            '            }'+
            '            ]'+
            '        },'+
            '      '+
            '        {'+
            '            "description": "User",'+
            '            "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '            "serviceInstanceId":"a4e2O0000003PBJQA3",'+
            '            "productActionType": "add",'+
            '            "productId": "DMCAT_ProductSpecification_000085",'+
            '            "billingSpecifications": ['+
            '            {'+
            '                "instanceId": "b8905354-a164-b480-9fb2-5c2d1a8499b1",'+
            '                "actionCode": "add",              '+
            '                "description": "Fixed Seat (Zone 3)",'+
            '                "billingSpecId": "BSRC001_CB",'+
            '                "frequency": "Monthly",'+
            '                "currencyCode": "AUD",'+
            '                "billInAdvance": "true",'+
            '                "prorateType": "false",'+
            '                "units": 10,'+
            '                "unitPrice": 150.00'+
            '            }'+
            '            ]'+
            '        },'+
            '        {'+
            '            "description": "Bandwidth Clip-On",'+
            '            "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '            "serviceInstanceId":"a4e2O0000003PBJQA3",'+
            '            "productActionType": "add",'+
            '            "productId": "DMCAT_ProductSpecification_000086",'+
            '            "billingSpecifications": ['+
            '            {'+
            '                "instanceId": "b8905354-a164-b480-9fb2-5c2d1a8499c1",'+
            '                "actionCode": "add",              '+
            '                "description": "Bandwidth Clip-On",'+
            '                "billingSpecId": "BSRC001_CB",'+
            '                "frequency": "Monthly",'+
            '                "currencyCode": "AUD",'+
            '                "billInAdvance": "true",'+
            '                "prorateType": "false",'+
            '                "units": 10,'+
            '                "unitPrice": 10.00'+
            '            }'+
            '            ]'+
            '        },'+
            '        {'+
            '            "description": "IAD Device",'+
            '            "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '            "serviceInstanceId":"a4e2O0000003PBJQA3",'+
            '            "productActionType": "add",'+
            '            "productId": "DMCAT_ProductSpecification_000087",'+
            '            "billingSpecifications": ['+
            '            {'+
            '                "instanceId": "b8905354-a164-b480-9fb2-5c2d1a8499d1",'+
            '                "actionCode": "add",              '+
            '                "description": "IAD Device",'+
            '                "billingSpecId": "BSOTC001_CB",'+
            '                "frequency": "Monthly",'+
            '                "currencyCode": "AUD",'+
            '                "units": 10,'+
            '                "unitPrice": 20.00'+
            '            }'+
            '            ]'+
            '        },'+
            '        {'+
            '            "serviceInstanceId":"a4e2O0000003PBJQA8",'+
            '            "description": "UC Site",'+
            '            "productActionType": "add",'+
            '            "productId": "DMCAT_ProductSpecification_000088",'+
            '            "services":[ {'+
            '                "serviceId": "61386245600 - 61386245650",'+
            '                "actionCode": "add",'+
            '                "serviceType": "Voice"'+
            '            }'+
            '            ],'+
            '            "billingSpecifications": ['+
            '            {'+
            '                "instanceId": "b8905354-a164-b480-9fb2-75c2d1a8499d1",'+
            '                "actionCode": "add",'+
            '                "effectiveDate": "2018-09-29T05:00:16.000Z",'+
            '                "description": "CWP NextGenUC Allowance",'+
            '                "billingSpecId": "BSUSG001_CB",'+
            '                "ocsProductId":"ocsSampleProductId"'+
            '            }'+
            '            ]'+
            '        }'+
            '          '+
            '    ]'+
            '}'+
            '';
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(json);
        System.assert(billSpecDTO != null);
        //System.assertEquals(700000000012,billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertNotEquals(billSpecDTO.effectiveDate,null);
        System.assertEquals('SN-000033817',billSpecDTO.productOffering.productInstanceId);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
        System.assertEquals('Connected Workplace Package',billSpecDTO.productOffering.description);
        System.assertEquals('Connected Workplace Package',billSpecDTO.productOffering.description);
        System.assertEquals('DMCAT_ProductSpecification_000099',billSpecDTO.orderItems[0].productId);
        System.assertEquals('CN-120-138',billSpecDTO.orderReference);
        
        //Start : Changes for EDGE-75162
        System.assertEquals('DMCAT_Offer_000303',billSpecDTO.productOffering.offerId);
        System.assertEquals('GST Applicable', billSpecDTO.orderItems[0].billingSpecifications[0].taxTreatment);
        System.assertEquals('Months', billSpecDTO.orderItems[0].billingSpecifications[0].durationUnit);
        System.assertEquals(24, billSpecDTO.orderItems[0].billingSpecifications[0].durationValue);
        //End : Changes for EDGE-75162

        // changes for EDGE-87688
    System.assertEquals('SN-000033817',billSpecDTO.productOffering.offerInstanceId);
    }
    
    @istest static void testParse1() {
        String jsonstr = '{"correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917","sourceSystem": "CloudSense","billingAccountNumber": 71234567,"productActionType": "add","effectiveDate": "2017-09-29T05:00:16.000Z","additionalBillInfo": [{"value": "Australia","name": "siteName"}],"productOffering":{"productId":"CWP_OFFER_123","invoiceDefinition": "Invoice_Def_1","productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8498a","description": "Connected Workplace Package"},"orderItems": [{"productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499b","parentProductInstanceId":"b8905354-a164-b480-9fb2-75c2d1a8499a","productId": "SEAT_123","billingSpecId": "BSRC001_CB","description": "CWP Zone 1 Seat Charges","frequency": "Monthly","currencyCode": "AUD","billInAdvance": "Y","prorateType": "prorate","productActionType": "add","effectiveDate": "2017-09-29T05:00:16.000Z","units": 25,"unitPrice": 50.00,"invoiceDefinition": "Invoice_Def_1","services": [{"id": "0386545400-0386545450"}]}]}';
        Test.startTest();
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(jsonstr);
        system.debug(billSpecDTO);
        Test.stopTest();
        // System.assertEquals('328fdbb9-a4e5-4c4c-b72f-0be6b9422917', billSpecDTO.correlationId);
        // System.assertEquals('CloudSense',billSpecDTO.sourceSystem);
        System.assertEquals(71234567,billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertNotEquals(billSpecDTO.effectiveDate,null);
        System.assertNotEquals(billSpecDTO.productOffering.productInstanceId,null);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
        System.assertEquals('Connected Workplace Package',billSpecDTO.productOffering.description);
    }
    @isTest
    public static void testMDM(){
        String jsonMDM='{"productOffering":{"productInstanceId":"SN-000027692","productId":"DMCAT_ProductOffering_000304","offerId":"DMCAT_Offer_000303","invoiceDefinition":"Invoice_Def_1","description":"Connected Workplace"},"productActionType":"add","orderItems":[{"productCharacteristics":[{"serviceType":"Mobile","serviceId":"61429781122","actionCode":"add","characteristics":[{"value":"ABC_123","name":"tenancyId"}]}],"serviceInstanceId":"SVC-000037479:DMCAT_ProductSpecification_000263","productId":"DMCAT_ProductSpecification_000263","productActionType":"add","effectiveDate":"2019-06-12T03:07:07.000Z","description":"Mobile Access","billingSpecifications":[{"ocsProductId":"T22E_MIA_DATPLAN","instanceId":"fdf3ddbf-8020-c0d8-e011-86cf080b5565","description":"Mobile Interim Access Allowance","billingSpecId":"BSUSG001_CB","actionCode":"add","priceAlteration":[{"unitPrice":20,"applicationDuration":"100","description":"something","recurringChargePeriod":"monthly"}],"customRate":[{"FromUnit":"1","ToUnit":"100","unitPrice":"400"}]}]},{"productCharacteristics":[{"serviceType":"Voice","serviceId":"444482457","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482456","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482455","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482454","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482453","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482452","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482450","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482459","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482458","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482448","actionCode":"add"},{"serviceType":"Voice","serviceId":"444482445","actionCode":"add"}],"serviceInstanceId":"SVC-000037479:DMCAT_ProductSpecification_000313","productId":"DMCAT_ProductSpecification_000313","productActionType":"add","effectiveDate":"2019-06-12T03:07:07.000Z","description":"UC Numbers","billingSpecifications":[{"ocsProductId":"ocsProd3","instanceId":"7897d799-28ab-31d2-27ae-44fa4a28eea1","description":"ngUC Dummy Usage Specification Allowance","billingSpecId":"BSUSG001_CB","actionCode":"add"}]},{"serviceInstanceId":"SVC-000037481:DMCAT_ProductSpecification_000074","productId":"DMCAT_ProductSpecification_000074","productActionType":"add","effectiveDate":"2019-06-12T03:07:07.000Z","description":"User","billingSpecifications":[{"units":3,"unitPrice":150,"taxTreatment":"GST Applicable","prorateType":"false","instanceId":"1c207d69-1b4d-996a-6837-af387df3f64f","frequency":"Monthly","description":"Fixed Seat (Zone 1)","currencyCode":"AUD","billingSpecId":"BSRC001_CB","billInAdvance":"true","actionCode":"add"}]}],"effectiveDate":"2019-06-12T03:07:07.000Z","billingAccountNumber":700000700125,"additionalBillInfo":[{"value":"My_site_01","name":"siteName"}]}';
        Test.startTest();
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(jsonMDM);
        Test.stopTest();
        System.assertEquals(Long.valueOf('700000700125'),billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertEquals(DateTime.newInstanceGmt(2019,06,12,03,07,07),billSpecDTO.effectiveDate);
        System.assertEquals('SN-000027692',billSpecDTO.productOffering.productInstanceId);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
        System.assertEquals('Connected Workplace',billSpecDTO.productOffering.description);
        system.assertEquals('DMCAT_Offer_000303', billSpecDTO.productOffering.offerId);
        system.assertEquals(1,billSpecDTO.additionalBillInfo.size());
        system.assertEquals('siteName', billSpecDTO.additionalBillInfo[0].name);
        system.assertEquals('My_site_01', billSpecDTO.additionalBillInfo[0].value);
        system.assertEquals(3,billSpecDTO.orderItems.size());
        for(BillingSpecDTOV2.OrderItems orderItem:billSpecDTO.orderItems){
            system.assertNotEquals(0, orderItem.billingSpecifications.size());
            if(orderItem.serviceInstanceId.equals('SVC-000037479:DMCAT_ProductSpecification_000263')){
                system.assertEquals('SVC-000037479:DMCAT_ProductSpecification_000263', orderItem.serviceInstanceId);
                system.assertEquals(1,orderItem.productCharacteristics.size());
                system.assertEquals('DMCAT_ProductSpecification_000263', orderItem.productId);
                system.assertEquals('add', orderItem.productActionType);
                //system.assertEquals(DateTime.newInstance(2019, 06, 12, 13, 07, 07), orderItem.effectiveDate);
                system.assertEquals('Mobile Access', orderItem.description);
                for(BillingSpecDTOV2.ProductCharacteristics prod:orderItem.productCharacteristics){
                    system.assertEquals('add', prod.actionCode);
                    system.assertEquals('Mobile', prod.serviceType);
                    system.assertEquals('61429781122', prod.serviceId);
                    system.assertEquals(1, prod.characteristics.size());
                    system.assertEquals('tenancyId', prod.characteristics[0].name);
                    system.assertEquals('ABC_123', prod.characteristics[0].value);
                }
                system.assertEquals(1,orderItem.billingSpecifications.size());
                system.assertEquals('fdf3ddbf-8020-c0d8-e011-86cf080b5565', orderItem.billingSpecifications[0].instanceId);
                system.assertEquals('Mobile Interim Access Allowance', orderItem.billingSpecifications[0].description);
                system.assertEquals('T22E_MIA_DATPLAN', orderItem.billingSpecifications[0].ocsProductId);
                system.assertEquals('BSUSG001_CB', orderItem.billingSpecifications[0].billingSpecId);
                system.assertEquals('add', orderItem.billingSpecifications[0].actionCode);
                for(BillingSpecDTOV2.priceAlterations pAlt:orderItem.billingSpecifications[0].priceAlteration){
                    system.assertEquals(20, pAlt.unitPrice);
                    system.assertEquals(100, pAlt.applicationDuration);
                    system.assertEquals('something', pAlt.description);
                    system.assertEquals('monthly', pAlt.recurringChargePeriod);
                }
                for(BillingSpecDTOV2.CustomRate customRate:orderItem.billingSpecifications[0].customRate){
                    system.assertEquals('1',customRate.FromUnit);
                    system.assertEquals('100',customRate.ToUnit);
                    system.assertEquals('400',customRate.unitPrice);
                    
                }
            }
        }
    }
    
    //EDGE-156163
    @isTest
    public static void testNGEM(){
        String jsonNGEM='{ "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917", "sourceSystem": "CloudSense", "billingAccountNumber": 71234567, "productActionType": "add", "effectiveDate": "2020-06-29T05:00:16.000Z", "additionalBillInfo": [ { "value": "Australia", "name": "siteName" } ], "productOffering": { "productId": "Next Generation EM", "invoiceDefinition": "Invoice_Def_1", "productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8498a", "description": "Next Generation Mobile Device" }, "orderItems": [ { "productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499b", "parentProductInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499a", "productId": "SEAT_123", "billingSpecId": "BSRC001_CB", "description": "Next Generation Mobile Device", "frequency": "Monthly", "currencyCode": "AUD", "billInAdvance": "Y", "prorateType": "prorate", "productActionType": "add", "effectiveDate": "2017-09-29T05:00:16.000Z", "units": 25, "unitPrice": 50, "invoiceDefinition": "Invoice_Def_1", "services": [ { "id": "0386545400-0386545450" } ], "billingSpecifications": [ { "instanceId": "b8905354-a164-b480-9fb2-5c2d1a8499d1", "actionCode": "add", "description": "Apple iPhone 11 128GB Black 4GX", "billingSpecId": "BSOTC001_CB", "contractType": "Purchase","refundFlag": "true", "currencyCode": "AUD", "isRedeemable": "true", "taxTreatment": "GST Applicable", "units": 1, "unitPrice": 1200 } ] } ] }';
        Test.startTest();
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(jsonNGEM);
        Test.stopTest();
        System.assertEquals(Long.valueOf('71234567'),billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertEquals(DateTime.newInstanceGmt(2020,06,29,05,00,16),billSpecDTO.effectiveDate);
        System.assertEquals('b8905354-a164-b480-9fb2-75c2d1a8498a',billSpecDTO.productOffering.productInstanceId);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
        System.assertEquals('Next Generation Mobile Device',billSpecDTO.productOffering.description);
        system.assertEquals(1,billSpecDTO.additionalBillInfo.size());
        system.assertEquals('siteName', billSpecDTO.additionalBillInfo[0].name);
        system.assertEquals('Australia', billSpecDTO.additionalBillInfo[0].value);
        system.assertEquals(1,billSpecDTO.orderItems.size());
        System.assertEquals('GST Applicable', billSpecDTO.orderItems[0].billingSpecifications[0].taxTreatment);
        System.assertEquals('Purchase', billSpecDTO.orderItems[0].billingSpecifications[0].contractType);
        System.assertEquals('true', billSpecDTO.orderItems[0].billingSpecifications[0].refundFlag);   //EDGE-164355
    }   


    //EDGE-156163
    @isTest
    public static void testNGEM_NullCheck(){
        String jsonNGEM='{ "correlationId": "328fdbb9-a4e5-4c4c-b72f-0be6b9422917", "sourceSystem": "CloudSense", "billingAccountNumber": 71234567, "productActionType": "add", "effectiveDate": "2020-06-29T05:00:16.000Z", "additionalBillInfo": [ { "value": "Australia", "name": "siteName" } ], "productOffering": { "productId": "Next Generation EM", "invoiceDefinition": "Invoice_Def_1", "productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8498a", "description": "Next Generation Mobile Device" }, "orderItems": [ { "productInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499b", "parentProductInstanceId": "b8905354-a164-b480-9fb2-75c2d1a8499a", "productId": "SEAT_123", "billingSpecId": "BSRC001_CB", "description": "Next Generation Mobile Device", "frequency": "Monthly", "currencyCode": "AUD", "billInAdvance": "Y", "prorateType": "prorate", "productActionType": "add", "effectiveDate": "2017-09-29T05:00:16.000Z", "units": 25, "unitPrice": 50, "invoiceDefinition": "Invoice_Def_1", "services": [ { "id": "0386545400-0386545450" } ], "billingSpecifications": [ { "instanceId": "b8905354-a164-b480-9fb2-5c2d1a8499d1", "actionCode": "add", "description": "Apple iPhone 11 128GB Black 4GX", "billingSpecId": "BSOTC001_CB",  "currencyCode": "AUD", "isRedeemable": "true", "taxTreatment": "GST Applicable", "units": 1, "unitPrice": 1200 } ] } ] }';
        Test.startTest();
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(jsonNGEM);
        Test.stopTest();
        System.assertEquals(Long.valueOf('71234567'),billSpecDTO.billingAccountNumber);
        System.assertEquals('add',billSpecDTO.productActionType);
        System.assertEquals(DateTime.newInstanceGmt(2020,06,29,05,00,16),billSpecDTO.effectiveDate);
        System.assertEquals('b8905354-a164-b480-9fb2-75c2d1a8498a',billSpecDTO.productOffering.productInstanceId);
        System.assertEquals('Invoice_Def_1',billSpecDTO.productOffering.invoiceDefinition);
        System.assertEquals('Next Generation Mobile Device',billSpecDTO.productOffering.description);
        system.assertEquals(1,billSpecDTO.additionalBillInfo.size());
        system.assertEquals('siteName', billSpecDTO.additionalBillInfo[0].name);
        system.assertEquals('Australia', billSpecDTO.additionalBillInfo[0].value);
        system.assertEquals(1,billSpecDTO.orderItems.size());
        System.assertEquals('GST Applicable', billSpecDTO.orderItems[0].billingSpecifications[0].taxTreatment);
        System.assertEquals(null, billSpecDTO.orderItems[0].billingSpecifications[0].contractType);
        System.assertEquals(null, billSpecDTO.orderItems[0].billingSpecifications[0].refundFlag);   //EDGE-164355
    }   
    
        @isTest
       public static void testAutoExpiry(){
        String payload='{ "productOffering": { "productInstanceId": "SN-000027692", "productId": "DMCAT_ProductOffering_000304", "offerId": "DMCAT_Offer_000303", "invoiceDefinition": "Invoice_Def_1", "description": "Connected Workplace", "autoExpiry": true, "expireDurationValue": 24, "expireDurationUnit": "Months" }, "productActionType": "add", "orderItems": [ { "productCharacteristics": [ { "serviceType": "Mobile", "serviceId": "61429781122", "actionCode": "add", "characteristics": [ { "value": "ABC_123", "name": "tenancyId" } ] } ], "serviceInstanceId": "SVC-000037479:DMCAT_ProductSpecification_000263", "productId": "DMCAT_ProductSpecification_000263", "productActionType": "add", "effectiveDate": "2019-06-12T03:07:07.000Z", "description": "Mobile Access", "billingSpecifications": [ { "ocsProductId": "T22E_MIA_DATPLAN", "instanceId": "fdf3ddbf-8020-c0d8-e011-86cf080b5565", "description": "Mobile Interim Access Allowance", "billingSpecId": "BSUSG001_CB", "actionCode": "add", "priceAlteration": [ { "unitPrice": 20, "applicationDuration": "100", "description": "something", "recurringChargePeriod": "monthly" } ], "customRate": [ { "FromUnit": "1", "ToUnit": "100", "unitPrice": "400" } ] } ] }, { "productCharacteristics": [ { "serviceType": "Voice", "serviceId": "444482457", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482456", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482455", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482454", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482453", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482452", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482450", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482459", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482458", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482448", "actionCode": "add" }, { "serviceType": "Voice", "serviceId": "444482445", "actionCode": "add" } ], "serviceInstanceId": "SVC-000037479:DMCAT_ProductSpecification_000313", "productId": "DMCAT_ProductSpecification_000313", "productActionType": "add", "effectiveDate": "2019-06-12T03:07:07.000Z", "description": "UC Numbers", "billingSpecifications": [ { "ocsProductId": "ocsProd3", "instanceId": "7897d799-28ab-31d2-27ae-44fa4a28eea1", "description": "ngUC Dummy Usage Specification Allowance", "billingSpecId": "BSUSG001_CB", "actionCode": "add" } ] }, { "serviceInstanceId": "SVC-000037481:DMCAT_ProductSpecification_000074", "productId": "DMCAT_ProductSpecification_000074", "productActionType": "add", "effectiveDate": "2019-06-12T03:07:07.000Z", "description": "User", "billingSpecifications": [ { "units": 3, "unitPrice": 150, "taxTreatment": "GST Applicable", "prorateType": "false", "instanceId": "1c207d69-1b4d-996a-6837-af387df3f64f", "frequency": "Monthly", "description": "Fixed Seat (Zone 1)", "currencyCode": "AUD", "billingSpecId": "BSRC001_CB", "billInAdvance": "true", "monthlyPrice": 300, "durationValue": 2, "actionCode": "add" } ] } ], "effectiveDate": "2019-06-12T03:07:07.000Z", "billingAccountNumber": 700000700125, "additionalBillInfo": [ { "value": "My_site_01", "name": "siteName" } ] }';
        Test.startTest();
        BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
        Test.stopTest();
        System.assertEquals(true,billSpecDTO.productOffering.autoExpiry);
        System.assertEquals(24,billSpecDTO.productOffering.expireDurationValue);
        System.assertEquals('Months',billSpecDTO.productOffering.expireDurationUnit);
    
    
    } 

    @isTest
    public static void testExternalRateID(){ //added as part of EDGE-153454
     String payload='{"productOffering":{"productInstanceId":"SN-000027692","productId":"DMCAT_ProductOffering_000304","offerId":"DMCAT_Offer_000303","invoiceDefinition":"Invoice_Def_1","description":"Connected Workplace","autoExpiry":true,"expireDurationValue":24,"expireDurationUnit":"Months"},"productActionType":"add","orderItems":[{"productCharacteristics":[{"serviceType":"Mobile","serviceId":"61429781122","actionCode":"add","characteristics":[{"value":"ABC_123","name":"tenancyId"}]}],"serviceInstanceId":"SVC-000037479:DMCAT_ProductSpecification_000263","productId":"DMCAT_ProductSpecification_000263","productActionType":"add","effectiveDate":"2019-06-12T03:07:07.000Z","description":"Mobile Access","billingSpecifications":[{"ocsProductId":"T22E_MIA_DATPLAN","instanceId":"fdf3ddbf-8020-c0d8-e011-86cf080b5565","description":"Mobile Interim Access Allowance","billingSpecId":"BSUSG001_CB","actionCode":"add","chargeId":"DMCAT_UsageCharge_000657","externalRateId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000112_DMCAT_UsageCharge_000657_4170","customRate":[{"FromUnit":"1","ToUnit":"100","unitPrice":"400","externalRateId":"DMCAT_ProductSpecification_000263_Mobile_Access"}]}]}],"effectiveDate":"2019-06-12T03:07:07.000Z","billingAccountNumber":700000700125,"additionalBillInfo":[{"value":"My_site_01","name":"siteName"}]}';
     Test.startTest();
     BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
     Test.stopTest();
     
     System.assertEquals('DMCAT_ProductSpecification_000263_Mobile_Access',billSpecDTO.orderItems[0].billingSpecifications[0].CustomRate[0].externalRateId);
     System.assertEquals('DMCAT_UsageCharge_000657',billSpecDTO.orderItems[0].billingSpecifications[0].chargeId);
     System.assertEquals('DMCAT_Offer_000646_DMCAT_ProductSpecification_000112_DMCAT_UsageCharge_000657_4170',billSpecDTO.orderItems[0].billingSpecifications[0].externalRateId);
 
 } 
    
       @isTest
    public static void testRFA(){ //added as part of EDGE-153454
     String payload='{ "requestType": "RFA","productOffering":{"productInstanceId":"SN-000027692","productId":"DMCAT_ProductOffering_000304","offerId":"DMCAT_Offer_000303","invoiceDefinition":"Invoice_Def_1","description":"Connected Workplace","autoExpiry":true,"expireDurationValue":24,"expireDurationUnit":"Months"},"productActionType":"add","orderItems":[{"productCharacteristics":[{"serviceType":"Mobile","serviceId":"61429781122","actionCode":"add","characteristics":[{"value":"ABC_123","name":"tenancyId"}]}],"serviceInstanceId":"SVC-000037479:DMCAT_ProductSpecification_000263","productId":"DMCAT_ProductSpecification_000263","productActionType":"add","effectiveDate":"2019-06-12T03:07:07.000Z","description":"Mobile Access","billingSpecifications":[{"ocsProductId":"T22E_MIA_DATPLAN","instanceId":"fdf3ddbf-8020-c0d8-e011-86cf080b5565","description":"Mobile Interim Access Allowance","billingSpecId":"BSUSG001_CB","actionCode":"add","chargeId":"DMCAT_UsageCharge_000657","externalRateId":"DMCAT_Offer_000646_DMCAT_ProductSpecification_000112_DMCAT_UsageCharge_000657_4170","customRate":[{"FromUnit":"1","ToUnit":"100","unitPrice":"400","externalRateId":"DMCAT_ProductSpecification_000263_Mobile_Access"}]}]}],"effectiveDate":"2019-06-12T03:07:07.000Z","billingAccountNumber":700000700125,"additionalBillInfo":[{"value":"My_site_01","name":"siteName"}]}';
     Test.startTest();
     BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
     Test.stopTest();
     
     System.assertEquals('RFA',billSpecDTO.requestType);
 
 } 
 
      @isTest
    public static void testChown(){ 
     String payload='{"productOffering":{"productInstanceId":"SN-000249859","offerInstanceId":"SN-000250183","offerId":"DMCAT_Offer_001233","invoiceDefinition":"Invoice_Def_2","fromOfferInstanceId":"SN-000249858","description":"Enterprise Wireless-Epic_2","fromBillingAccountNumber":"8452145784512"},"productActionType":"modify","orderReference":"CN000-370-543","orderItems":[{"serviceInstanceId":"SVC-000245525:DMCAT_ProductSpecification_001196","scenarioType":"CHOWN","productId":"DMCAT_ProductSpecification_001196","productCharacteristics":[{"characteristics":[{"value":"8080808080808","name":"IMSI"},{"value":"61474703230","name":"MSISDN"}],"actionCode":"no change"}],"productActionType":"modify","effectiveDate":"2021-03-15T06:33:30.000Z","description":"Enterprise Mobility","billingSpecifications":[{"ocsProductId":"T22EM_WIRELESS","instanceId":"b6ff3aa0-17b2-a895-f471-a53958a33717","description":"Includes 50 GB Domestic Data+SMS+MMS","chargeId":"DMCAT_Allowance_001261","billingSpecId":"BSUSG001_CB","actionCode":"NO CHANGE"},{"units":1,"unitPrice":45.45,"taxTreatment":"GST Applicable","prorateType":"false","instanceId":"9c0f03d4-efae-0f60-caf0-e64627aa9dc2","frequency":"Monthly","externalRateId":"DMCAT_Offer_001233_DMCAT_ProductSpecification_001196_DMCAT_RecurringCharge_001232_7784","description":"Enterprise Wireless Epic Plan","currencyCode":"AUD","chargeId":"DMCAT_RecurringCharge_001232","billingSpecId":"BSRC001_CB","billInAdvance":"true","actionCode":"NO CHANGE"}]}],"fromBillingAccountNumber":700001351951,"effectiveDate":"2021-03-15T06:33:30.000Z","billingAccountNumber":700001349138}';
     Test.startTest();

     BillingSpecDTOV2 billSpecDTO = BillingSpecDTOV2.parse(payload);
     
     Test.stopTest();
     
     system.assertEquals('modify', billSpecDTO.productActionType );
 
 }  
}
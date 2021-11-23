@istest
global class ReplicatorResponseMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        String endPoint = req.getEndpoint();
        System.debug('Endpoint: ' + endPoint);
        String reqBody = req.getBody();
        System.debug('Request Body: ' + reqBody);
        
         if(endPoint.contains('adboreid')) {
            System.debug('Request Get Service Body: ' + reqBody);

            if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE))) {
                res.setBody(getCustomerServices_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_404_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE))) {
            	res.setBody(getCustomerServices_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_500_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE))) {
            	res.setBody(getCustomerServices_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_503_CODE);
            }
            else if(endPoint.contains('errorId')) {
            	res.setBody(getCustomerServices_Error());
            }
            else {
                res.setBody(getCustomerServices_withSuccess());   
                res.setStatusCode(200);                
            }        
        } else if(endPoint.contains('CIDN')) {
            System.debug('Request Get Site Body: ' + reqBody);

            if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_404_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_404_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_500_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_500_CODE);
            }
            else if(endPoint.contains('errorId') && endPoint.contains(String.valueOf(IntegrationRecordHandlerUtil.ERROR_503_CODE))) {
                res.setBody(getCustomerSites_Error());   
                res.setStatusCode(IntegrationRecordHandlerUtil.ERROR_503_CODE);
            }
            else if(endPoint.contains('errorId')) {
            	res.setBody(getCustomerSites_Error());
            }
            else {
                res.setBody(getCustomerSites_withSuccess());   
                res.setStatusCode(200);                
            }
        }
        return res;        
    }

    private static String getCustomerSites_withSuccess() {
        String jsonString = '{' + 
        ' \"CIDN\": \"212\", ' +
        ' \"Enterprise_Id\": \"553\", ' +
        ' \"Error_Code\": \"\", ' +
        ' \"Error_Description\": \"\", ' +
        '     \"Site\": [{ ' + 
        '         \"ADBoR_ID\": \"111\", ' +
        '         \"Media_Type\": \"NBN\", ' +
        '         \"Site_Nick_Name\": \"Melbourne CBD\", ' +
        '         \"Address_No_From\": \"22\", ' +
        '         \"Address_No_To\": \"25\", ' +
        '         \"Suffix_From\": \"\", ' +
        '         \"Suffix_To\": \"\", ' +
        '         \"Street_Name\": \"Lonsdale\", ' +
        '         \"Street_Type\": \"Street\", ' +
        '         \"Loc_Name\": \"\", ' +
        '         \"ADBoR_Postcode\": \"3000\", ' +
        '         \"State\": \"\", ' +
        '         \"Name\": \"\", ' +
        '         \"Sub1_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub1_Descriptor_1\": \"\", ' +
        '         \"Sub1_Descriptor_2\": \"\", ' +
        '         \"Sub2_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub2_Descriptor_1\": \"\", ' +
        '         \"Sub2_Descriptor_2\": \"\", ' +
        '         \"Sub3_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub3_Descriptor_1\": \"\", ' +
        '         \"Sub3_Descriptor_2\": \"\", ' +
        '         \"Sub4_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub4_Descriptor_1\": \"\", ' +
        '         \"Sub4_Descriptor_2\": \"\", ' +
        '         \"Disconnection_Date\": \"\", ' +
        '         \"LastReplicator_UpdateDate\": \"\", ' +        
        '         \"In_Flight_Order\": \"\", ' +
        '         \"RFS_Site\": \"\", ' +
        '         \"RFS_Date\": \"\", ' +
        '         \"Serviceability\": \"\", ' +
        '         \"NBN_Access_Type\": \"\", ' +
        '         \"Disconnect_Wave\": \"\", ' +
        '         \"Site_Address_Status\": \"CO\", ' +
        '         \"NBN_Location_Id\": \"\", ' +
        '         \"Site_Composition\": \"\", ' +
        '         \"Complex_Site_Flag\": \"\", ' +
        '         \"Migration_Flag\": \"\", ' +
        '         \"Order_Stability_Date\": \"\", ' +
        '         \"Service_Class\": \"\", ' +
        '         \"Notes\": \"\", ' +
        '         \"Error_Description\": \"\", ' +
        '         \"Contact\": [{ ' +
        '             \"Site_Contact_First_Name\": \"Ben\", ' +
        '             \"Site_Contact_Last_Name\": \"Smith\", ' +
        '             \"Site_Contact_Telephone\": \"0356789078\", ' +
        '             \"Site_Contact_Mobile\": \"0456764532\", ' +
        '             \"Site_Contact_Fax\": \"\", ' +
        '             \"Site_Contact_Email\": \"ben.smith@gmail.com\" ' +
        '         }, { ' +
        '             \"Site_Contact_First_Name\": \"Asoka\", ' +
        '             \"Site_Contact_Last_Name\": \"Perara\", ' +
        '             \"Site_Contact_Telephone\": \"0323145678\", ' +
        '             \"Site_Contact_Mobile\": \"0453627869\", ' +
        '             \"Site_Contact_Fax\": \"\", ' +
        '             \"Site_Contact_Email\": \"asoka.perara@yahoo.com\" ' +
        '         }] ' +
        '     }, ' +
        '     { ' +
        '         \"ADBoR_ID\": \"1143\", ' +
        '         \"Media_Type\": \"NBN\", ' +
        '         \"Site_Nick_Name\": \"Sydney CBD\", ' +
        '         \"Address_No_From\": \"33\", ' +
        '         \"Address_No_To\": \"45\", ' +
        '         \"Suffix_From\": \"\", ' +
        '         \"Suffix_To\": \"\", ' +
        '         \"Street_Name\": \"Opera\", ' +
        '         \"Street_Type\": \"Road\", ' +
        '         \"Loc_Name\": \"\", ' +
        '         \"ADBoR_Postcode\": \"2000\", ' +
        '         \"State\": \"\", ' +
        '         \"Name\": \"\", ' +
        '         \"Sub1_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub1_Descriptor_1\": \"\", ' +
        '         \"Sub1_Descriptor_2\": \"\", ' +
        '         \"Sub2_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub2_Descriptor_1\": \"\", ' +
        '         \"Sub2_Descriptor_2\": \"\", ' +
        '         \"Sub3_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub3_Descriptor_1\": \"\", ' +
        '         \"Sub3_Descriptor_2\": \"\", ' +
        '         \"Sub4_CodeSet_Abbrev\": \"\", ' +
        '         \"Sub4_Descriptor_1\": \"\", ' +
        '         \"SUB4_DESCRIPTOR_2\": \"\", ' +
        '         \"Disconnection_Date\": \"\", ' +
        '         \"LastReplicator_UpdateDate\": \"\", ' +        
        '         \"In_Flight_Order\": \"\", ' +
        '         \"RFS_Site\": \"\", ' +
        '         \"RFS_Date\": \"\", ' +
        '         \"Serviceability\": \"\", ' +
        '         \"NBN_Access_Type\": \"\", ' +
        '         \"Disconnect_Wave\": \"\", ' +
        '         \"Site_Address_Status\": \"CO\", ' +
        '         \"NBN_Location_Id\": \"\", ' +
        '         \"Site_Composition\": \"\", ' +
        '         \"Complex_Site_Flag\": \"\", ' +
        '         \"Migration_Flag\": \"\", ' +
        '         \"Order_Stability_Date\": \"\", ' +
        '         \"Service_Class\": \"\", ' +
        '         \"Notes\": \"\", ' +
        '         \"Error_Description\": \"\", ' +
        '         \"Contact\": [{ ' +
        '             \"Site_Contact_First_Name\": \"Nikki\", ' +
        '             \"Site_Contact_Last_Name\": \"Wilson\", ' +
        '             \"Site_Contact_Telephone\": \"0234567893\", ' +
        '             \"Site_Contact_Mobile\": \"0423567894\", ' +
        '             \"Site_Contact_Fax\": \"\", ' +
        '             \"Site_Contact_Email\": \"nikki.smith@gmail.com\" ' +
        '         }] ' +
        '    }] ' +
        '}';
        
        return jsonString;
    }
    
    private static String getCustomerServices_withSuccess() {
        String jsonString = '{'+
		'	\"Source_System_Id\": \"Replicator\",'+
		'	\"CIDN\": \"1234\",'+
		'	\"Correlation_Id\": \"\",'+
        '   \"Error_Code\": \"\", ' +
        '   \"Error_Description\": \"\", ' +
		'	\"Site\": [{'+
		'		\"ADBOR_Id\": \"111\",'+
		'		\"Error_Code\": \"\",'+
		'		\"Error_Description\": \"\",'+
		'		\"productList\": [{'+
		'			\"Product_Type\": \"Business Essentials\",'+
		'			\"Product_Identifier\": \"24432432432\",'+
		'			\"Association_Type\": \"\",'+
		'			\"Association_Role\": \"\",'+
		'			\"Association_Link_Id\": \"\",'+
		'			\"Business_Owner\": \"Business\",'+
		'			\"Bundle_Indicator\": \"Yes\",'+
		'			\"Purchase_Order\": \"\",'+
		'			\"Invoice_Arrangement_Id\": \"IA1234\",'+
		'			\"Invoice_Arrangement_Id_MICA\": \"\",'+
		'			\"In_Flight_Flag\": \"N\",'+
		'			\"In_Flight_Legacy_System\": \"\",'+
		'			\"In_Flight_Order_Id\": \"\",'+
		'			\"Nominated_FNN\": \"\",'+
		'			\"DOT_GenType\": \"\",'+
		'			\"Enterprise_Id\": \"\",'+
		'			\"Error_Code\": \"\",'+
		'			\"Error_Description\": \"\",'+
		'			\"discount\": [{'+
		'				\"Discount_Name\": \"\",'+
		'				\"Discount_Start_Date\": \"\",'+
		'				\"Discount_Monthly_Amount\": \"\",'+
		'				\"Discount_Term\": \"\"'+
		'			},'+
		'			{'+
		'				\"Discount_Name\": \"\",'+
		'				\"Discount_Start_Date\": \"\",'+
		'				\"Discount_Monthly_Amount\": \"\",'+
		'				\"Discount_Term\": \"\"'+
		'			}],'+
		'			\"service\": [{'+
		'				\"Service_Id\": \"233424\",'+
		'				\"Technical_Association_Role\": \"\",'+
		'				\"Service_Type\": \"Broadband\",'+
		'				\"Bundle_Role\": \"Linked\",'+
		'				\"Last_Replicator_Update_Date\": \"14/06/2017\",'+
		'				\"Error_Code\": \"\",'+
		'				\"Error_Description\": \"\",'+
		'				\"serviceCharacteristic\": [{'+
		'					\"name\": \"ADSL_Bearer_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VOIP_Platform\",'+
		'					\"value\": \"BW\"'+
		'				},'+
		'				{'+
		'					\"name\": \"User_Type\",'+
		'					\"value\": \"Fax\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IP_Type\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Telstra_GW_IPv4\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Telstra_GW_IPv6\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IPv6_Prefix\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_WAN_IP\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_LAN_IP\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_LAN_IPv6\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"BCS_FNN\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Host_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Host_Password\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Ops_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"GB_Allowance\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VoicetoEmail_Text\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Unified_Plan_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Directory_Option\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Call_Barring_Option\",'+
		'					\"value\": \"Y\"'+
		'				},'+
		'				{'+
		'					\"name\": \"RCRM_ Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Essential_Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Temporary_Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"NSC_ Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_FNN\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Trade_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Contact\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Email\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Phone_Num\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Shareable\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Group_Plan_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Group_Deal_Name\",'+
		'					\"value\": \"\"'+
		'				}],'+
		'				\"planCharacteristic\": [{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount1\",'+
		'						\"Discount_Monthly_Amount\": \"33\",'+
		'						\"Discount_Percent_Amount\": \"33\",'+
		'						\"Discount_Start_Date\": \"07/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				},'+
		'				{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				}],'+
		'				\"serviceRelationship\": [{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"device\": {'+
		'						\"Device_Type\": \"Switch\",'+
		'						\"Device_Ownership\": \"\",'+
		'						\"Device_Model\": \"Yealink245\",'+
		'						\"Device_Name\": \"\",'+
		'						\"SKU\": \"REP1234\",'+
		'						\"Device_Payment_Type\": \"\",'+
		'						\"Device_Monthly_Amount\": \"\",'+
		'						\"Device_Plan_Start_Date\": \"\",'+
		'						\"Device_Plan_Term\": \"\",'+
		'						\"Device_Billing_System\": \"\",'+
		'						\"Device_Billing_System_Id\": \"\",'+
		'						\"Legacy_Link\": \"\",'+
		'						\"DECT_BaseStation\": \"\",'+
		'						\"DECT_Handset\": \"\",'+
		'						\"Quantity\": \"\",'+
		'						\"Error_Code\": \"\",'+
		'						\"Error_Description\": \"\",'+
		'						\"discount\": [{'+
		'							\"Discount_Name\": \"discount1\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"24\",'+
		'							\"Discount_Monthly_Amount\": \"25\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						},'+
		'						{'+
		'							\"Discount_Name\": \"discount2\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"12\",'+
		'							\"Discount_Monthly_Amount\": \"250\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						}]'+
		'					}'+
		'				},'+
		'				{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"serviceExtension\": [{'+
		'						\"Services_From\": \"\",'+
		'						\"Services_To\": \"\"'+
		'					},'+
		'					{'+
		'						\"Services_From\": \"\",'+
		'						\"Services_To\": \"\"'+
		'					}]'+
		'				},'+
		'				{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"device\": {'+
		'						\"Device_Type\": \"Switch\",'+
		'						\"Device_Ownership\": \"\",'+
		'						\"Device_Model\": \"Yealink245\",'+
		'						\"Device_Name\": \"\",'+
		'						\"SKU\": \"REP1234\",'+
		'						\"Device_Payment_Type\": \"\",'+
		'						\"Device_Monthly_Amount\": \"\",'+
		'						\"Device_Plan_Start_Date\": \"\",'+
		'						\"Device_Plan_Term\": \"\",'+
		'						\"Device_Billing_System\": \"\",'+
		'						\"Device_Billing_System_Id\": \"\",'+
		'						\"Legacy_Link\": \"\",'+
		'						\"DECT_BaseStation\": \"\",'+
		'						\"DECT_Handset\": \"\",'+
		'						\"Quantity\": \"\",'+
		'						\"Error_Code\": \"\",'+
		'						\"Error_Description\": \"\",'+
		'						\"discount\": [{'+
		'							\"Discount_Name\": \"discount1\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"24\",'+
		'							\"Discount_Monthly_Amount\": \"25\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						},'+
		'						{'+
		'							\"Discount_Name\": \"discount2\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"12\",'+
		'							\"Discount_Monthly_Amount\": \"250\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						}]'+
		'					}'+
		'				}'+
		'				]'+
		'			},'+
		'			{'+
		'				\"Service_Id\": \"543433\",'+
		'				\"service_Type\": \"Voice\",'+
		'				\"Last_Replicator_Update_Date\": \"14/06/2017\",'+
		'				\"Error_Code\": \"\",'+
		'				\"Error_Description\": \"\",'+
		'				\"serviceCharacteristic\": [{'+
		'					\"name\": \"ADSL_Bearer_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VOIP_Platform\",'+
		'					\"value\": \"BW\"'+
		'				},'+
		'				{'+
		'					\"name\": \"User_Type\",'+
		'					\"value\": \"Fax\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IP_Type\",'+
		'					\"value\": \"\"'+
		'				}],'+
		'				\"planCharacteristic\": [{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				},'+
		'				{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				}]'+
		'			}]'+
		'		}]'+
		'	},'+
		'	{'+
		'		\"ADBOR_Id\": \"1143\",'+
		'		\"Error_Code\": \"\",'+
		'		\"Error_Description\": \"\",'+
		'		\"productList\": [{'+
		'			\"Product_Type\": \"PSTN\",'+
		'			\"Product_Identifier\": \"10032432432\",'+
		'			\"Association_Type\": \"\",'+
		'			\"Association_Role\": \"\",'+
		'			\"Association_Link_Id\": \"\",'+
		'			\"Business_Owner\": \"Business\",'+
		'			\"Bundle_Indicator\": \"Yes\",'+
		'			\"Purchase_Order\": \"\",'+
		'			\"Invoice_Arrangement_Id\": \"IA1234\",'+
		'			\"Invoice_Arrangement_Id_MICA\": \"\",'+
		'			\"In_Flight_Flag\": \"N\",'+
		'			\"In_Flight_Legacy_System\": \"\",'+
		'			\"In_Flight_Order_Id\": \"\",'+
		'			\"Nominated_FNN\": \"\",'+
		'			\"DOT_GenType\": \"\",'+
		'			\"Enterprise_Id\": \"\",'+
		'			\"Error_Code\": \"\",'+
		'			\"Error_Description\": \"\",'+
		'			\"discount\": [{'+
		'				\"Discount_Name\": \"\",'+
		'				\"Discount_Start_Date\": \"\",'+
		'				\"Discount_Monthly_Amount\": \"\",'+
		'				\"Discount_Term\": \"\"'+
		'			},'+
		'			{'+
		'				\"Discount_Name\": \"\",'+
		'				\"Discount_Start_Date\": \"\",'+
		'				\"Discount_Monthly_Amount\": \"\",'+
		'				\"Discount_Term\": \"\"'+
		'			}],'+
		'			\"service\": [{'+
		'				\"Service_Id\": \"555424\",'+
		'				\"Technical_Association_Role\": \"\",'+
		'				\"Service_Type\": \"Broadband\",'+
		'				\"Bundle_Role\": \"Linked\",'+
		'				\"Last_Replicator_Update_Date\": \"14/06/2017\",'+
		'				\"Error_Code\": \"\",'+
		'				\"Error_Description\": \"\",'+
		'				\"serviceCharacteristic\": [{'+
		'					\"name\": \"ADSL_Bearer_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VOIP_Platform\",'+
		'					\"value\": \"BW\"'+
		'				},'+
		'				{'+
		'					\"name\": \"User_Type\",'+
		'					\"value\": \"Fax\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IP_Type\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Telstra_GW_IPv4\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Telstra_GW_IPv6\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IPv6_Prefix\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_WAN_IP\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_LAN_IP\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Cust_LAN_IPv6\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"BCS_FNN\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Host_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Host_Password\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Ops_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"GB_Allowance\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VoicetoEmail_Text\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Unified_Plan_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Directory_Option\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Call_Barring_Option\",'+
		'					\"value\": \"Y\"'+
		'				},'+
		'				{'+
		'					\"name\": \"RCRM_ Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Essential_Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Temporary_Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"NSC_ Service\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_FNN\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Trade_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Contact\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Email\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"AOH_Cust_Phone_Num\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Shareable\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Group_Plan_Name\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"Group_Deal_Name\",'+
		'					\"value\": \"\"'+
		'				}],'+
		'				\"planCharacteristic\": [{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount1\",'+
		'						\"Discount_Monthly_Amount\": \"33\",'+
		'						\"Discount_Percent_Amount\": \"33\",'+
		'						\"Discount_Start_Date\": \"07/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				},'+
		'				{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				}],'+
		'				\"serviceRelationship\": [{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"device\": {'+
		'						\"Device_Type\": \"Switch\",'+
		'						\"Device_Ownership\": \"\",'+
		'						\"Device_Model\": \"Yealink245\",'+
		'						\"Device_Name\": \"\",'+
		'						\"SKU\": \"REP1234\",'+
		'						\"Device_Payment_Type\": \"\",'+
		'						\"Device_Monthly_Amount\": \"\",'+
		'						\"Device_Plan_Start_Date\": \"\",'+
		'						\"Device_Plan_Term\": \"\",'+
		'						\"Device_Billing_System\": \"\",'+
		'						\"Device_Billing_System_Id\": \"\",'+
		'						\"Legacy_Link\": \"\",'+
		'						\"DECT_BaseStation\": \"\",'+
		'						\"DECT_Handset\": \"\",'+
		'						\"Quantity\": \"\",'+
		'						\"Error_Code\": \"\",'+
		'						\"Error_Description\": \"\",'+
		'						\"discount\": [{'+
		'							\"Discount_Name\": \"discount1\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"24\",'+
		'							\"Discount_Monthly_Amount\": \"25\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						},'+
		'						{'+
		'							\"Discount_Name\": \"discount2\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"12\",'+
		'							\"Discount_Monthly_Amount\": \"250\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						}]'+
		'					}'+
		'				},'+
		'				{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"serviceExtension\": [{'+
		'						\"Services_From\": \"0\",'+
		'						\"Services_To\": \"1\"'+
		'					},'+
		'					{'+
		'						\"Services_From\": \"\",'+
		'						\"Services_To\": \"\"'+
		'					}]'+
		'				},'+
		'				{'+
		'					\"relationshipType\": \"contains\",'+
		'					\"device\": {'+
		'						\"Device_Type\": \"Switch\",'+
		'						\"Device_Ownership\": \"\",'+
		'						\"Device_Model\": \"Yealink245\",'+
		'						\"Device_Name\": \"\",'+
		'						\"SKU\": \"REP1234\",'+
		'						\"Device_Payment_Type\": \"\",'+
		'						\"Device_Monthly_Amount\": \"\",'+
		'						\"Device_Plan_Start_Date\": \"\",'+
		'						\"Device_Plan_Term\": \"\",'+
		'						\"Device_Billing_System\": \"\",'+
		'						\"Device_Billing_System_Id\": \"\",'+
		'						\"Legacy_Link\": \"\",'+
		'						\"DECT_BaseStation\": \"\",'+
		'						\"DECT_Handset\": \"\",'+
		'						\"Quantity\": \"\",'+
		'						\"Error_Code\": \"\",'+
		'						\"Error_Description\": \"\",'+
		'						\"discount\": [{'+
		'							\"Discount_Name\": \"discount1\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"24\",'+
		'							\"Discount_Monthly_Amount\": \"25\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						},'+
		'						{'+
		'							\"Discount_Name\": \"discount2\",'+
		'							\"Discount_Start_Date\": \"12/02/2016\",'+
		'							\"Discount_Term\": \"12\",'+
		'							\"Discount_Monthly_Amount\": \"250\",'+
		'							\"Discount_Percent_Amount\": \"\"'+
		'						}]'+
		'					}'+
		'				}'+
		'				]'+
		'			},'+
		'			{'+
		'				\"Service_Id\": \"0399000011\",'+
		'				\"service_Type\": \"Voice\",'+
		'				\"Last_Replicator_Update_Date\": \"14/06/2017\",'+
		'				\"Error_Code\": \"\",'+
		'				\"Error_Description\": \"\",'+
		'				\"serviceCharacteristic\": [{'+
		'					\"name\": \"ADSL_Bearer_Id\",'+
		'					\"value\": \"\"'+
		'				},'+
		'				{'+
		'					\"name\": \"VOIP_Platform\",'+
		'					\"value\": \"BW\"'+
		'				},'+
		'				{'+
		'					\"name\": \"User_Type\",'+
		'					\"value\": \"Fax\"'+
		'				},'+
		'				{'+
		'					\"name\": \"IP_Type\",'+
		'					\"value\": \"\"'+
		'				}],'+
		'				\"planCharacteristic\": [{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				},'+
		'				{'+
		'					\"Plan_Deal_Type\": \"\",'+
		'					\"Plan_Name\": \"\",'+
		'					\"Plan_Term\": \"\",'+
		'					\"Plan_Commercial_Type\": \"\",'+
		'					\"Plan_Monthly_Amount\": \"\",'+
		'					\"Plan_Start_Date\": \"\",'+
		'					\"Instalments_Billed\": \"\",'+
		'					\"Instalments_Remaining\": \"\",'+
		'					\"Legacy_String\": \"\",'+
		'					\"discount\": {'+
		'						\"Discount_Name\": \"serviceDiscount2\",'+
		'						\"Discount_Monthly_Amount\": \"23\",'+
		'						\"Discount_Percent_Amount\": \"\",'+
		'						\"Discount_Start_Date\": \"08/02/2017\",'+
		'						\"Discount_Term\": \"\"'+
		'					}'+
		'				}]'+
		'			}]'+
		'		}]'+
		'	}]'+
		'}';
                
        return jsonString;
    }

    private static String getCustomerServices_Error() {
       /* String jsonString = '{' + 
            ' \"CIDN\": \"212\", ' +
            ' \"ADBOR_Id\": \"111\", ' +
            ' \"Enterprise_Id\": \"553\", ' +
            ' \"Error_Code\": \"\", ' +
            ' \"Error_Description\": \"\" ' +
        '}';*/
        String jsonString = '{' +
            '	\"CIDN\": \"212\",'+
		'	    \"Correlation_Id\": \"\",'+
        '       \"Error_Code\": \"\", ' +
        '       \"Error_Description\": \"\", ' +
		'	\"Site\": [{'+
		'		\"ADBOR_Id\": \"111\",'+
		'		\"Error_Code\": \"\",'+
		'		\"Error_Description\": \"\"'+
        '        }]'
            +'}';

        return jsonString;
    }
            
    private static String getCustomerSites_Error() {
        String jsonString = '{' + 
            ' \"CIDN\": \"212\", ' +
            ' \"Enterprise_Id\": \"553\", ' +
            ' \"Error_Code\": \"\", ' +
            ' \"Error_Description\": \"\" ' +
        '}';
        
        return jsonString;
    }
    
    static testMethod void test() {
    	Test.startTest();
	  	String jsonString=getCustomerSites_Error();
        Test.stopTest();
        system.assert(jsonString!=null);
    }
}
/*Story number: EDGE-206
  Description: Test class for cs_SigmaToCSJSON 	
*/

@isTest
public class Test_cs_SigmaToCSJSON {
    public static testMethod void testParse() {
        String json = '{' +
            '  "package": {' +
            '    "name": "Connected Workplace",' +
            '    "externalId": "85776ed4-e9eb-49d3-8af5-4fbdda0df6e9",' +
            '    "specId": "OF_000021",' +
            '    "products": [' +
            '      {' +
            '        "name": "Connected Workplace",' +
            '        "type": "Default_Product_Specification",' +
            '        "isProvisionable": "false",' +
            '        "externalId": "931e7c04-7568-4bdb-99cb-d65a141da925",' +
            '        "specId": "PS_000055",' +
            '        "startDate": "2017-10-25T13:00:00.000Z",' +
            '        "endDate": "2099-12-30T13:00:00.000Z",' +
            '        "products": [' +
            '          {' +
            '            "name": "IP VPN",' +
            '            "type": "Default_Product_Specification",' +
            '            "isProvisionable": "true",' +
            '            "externalId": "d8ad2efe-981f-4076-a82f-608228b0986a",' +
            '            "specId": "PS_000028",' +
            '            "startDate": "2017-10-25T13:00:00.000Z",' +
            '            "endDate": "2099-12-30T13:00:00.000Z",' +
            '            "attributes": [' +
            '              {' +
            '                "name": "Customer Facing Service Id",' +
            '                "type": "ui",' +
            '                "default": ""' +
            '              }' +
            '            ],' +
            '            "products": [' +
            '              {' +
            '                "name": "Managed Radius",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "false",' +
            '                "externalId": "19ec8043-0de6-453d-b847-7f210a0e9fca",' +
            '                "specId": "PS_000053",' +
            '                "startDate": "2017-10-25T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "attributes": [' +
            '                  {' +
            '                    "name": "Customer Facing Service Id",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  }' +
            '                ]' +
            '              },' +
            '              {' +
            '                "name": "IP Wireless",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "true",' +
            '                "externalId": "312de153-be15-4305-b5cf-8ac8a291b288",' +
            '                "specId": "PS_000018",' +
            '                "startDate": "2017-10-25T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "attributes": [' +
            '                  {' +
            '                    "name": "Customer Facing Service Id",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  }' +
            '                ]' +
            '              }' +
            '            ]' +
            '          },' +
            '          {' +
            '            "name": "IP Site",' +
            '            "type": "Default_Product_Specification",' +
            '            "isProvisionable": "false",' +
            '            "externalId": "00d686c2-6da9-4c48-8e88-cb2d66dbda63",' +
            '            "specId": "PS_000049",' +
            '            "startDate": "2017-11-01T13:00:00.000Z",' +
            '            "endDate": "2099-12-30T13:00:00.000Z",' +
            '            "attributes": [' +
            '              {' +
            '                "name": "Zone",' +
            '                "type": "uiLOV",' +
            '                "values": [' +
            '                  "4",' +
            '                  "1",' +
            '                  "3",' +
            '                  "2"' +
            '                ],' +
            '                "default": ""' +
            '              }' +
            '            ],' +
            '            "products": [' +
            '              {' +
            '                "name": "Access",' +
            '                "type": "Default_Product_Group",' +
            '                "isProvisionable": "false",' +
            '                "externalId": "c00bb65b-8d84-4cbd-8cf8-53a6a3e85826",' +
            '                "specId": "PG_000037",' +
            '                "startDate": "2017-10-26T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "products": [' +
            '                  {' +
            '                    "name": "NBN Ethernet",' +
            '                    "type": "Default_Product_Specification",' +
            '                    "isProvisionable": "false",' +
            '                    "externalId": "7d7d7dc5-44ee-4950-a38b-e2bb5dad8316",' +
            '                    "specId": "PS_000025",' +
            '                    "startDate": "2017-10-25T13:00:00.000Z",' +
            '                    "endDate": "2099-12-30T13:00:00.000Z",' +
            '                    "attributes": [' +
            '                      {' +
            '                        "name": "Customer Facing Service Id",' +
            '                        "type": "ui",' +
            '                        "default": ""' +
            '                      }' +
            '                    ]' +
            '                  },' +
            '                  {' +
            '                    "name": "NBN Broadband",' +
            '                    "type": "Default_Product_Specification",' +
            '                    "isProvisionable": "false",' +
            '                    "externalId": "3ca3fb7e-ee79-4247-a8b8-2c8ee4e337a1",' +
            '                    "specId": "PS_000026",' +
            '                    "startDate": "2017-10-25T13:00:00.000Z",' +
            '                    "endDate": "2099-12-30T13:00:00.000Z",' +
            '                    "attributes": [' +
            '                      {' +
            '                        "name": "Customer Facing Service Id",' +
            '                        "type": "ui",' +
            '                        "default": ""' +
            '                      }' +
            '                    ]' +
            '                  },' +
            '                  {' +
            '                    "name": "Telstra Fibre",' +
            '                    "type": "Default_Product_Specification",' +
            '                    "isProvisionable": "true",' +
            '                    "externalId": "07cbfa3f-f93a-4962-83fb-c2c41b156cd4",' +
            '                    "specId": "PS_000027",' +
            '                    "startDate": "2017-10-25T13:00:00.000Z",' +
            '                    "endDate": "2099-12-30T13:00:00.000Z",' +
            '                    "attributes": [' +
            '                      {' +
            '                        "name": "Customer Facing Service Id",' +
            '                        "type": "ui",' +
            '                        "default": ""' +
            '                      }' +
            '                    ]' +
            '                  }' +
            '                ]' +
            '              },' +
            '              {' +
            '                "name": "Port",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "true",' +
            '                "externalId": "95f3f970-3828-4bae-b219-b8b2089ddf02",' +
            '                "specId": "PS_000030",' +
            '                "startDate": "2017-10-26T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "attributes": [' +
            '                  {' +
            '                    "name": "Bandwidth",' +
            '                    "type": "sdLOV",' +
            '                    "values": [' +
            '                      "10 MB",' +
            '                      "20 MB"' +
            '                    ],' +
            '                    "default": ""' +
            '                  },' +
            '                  {' +
            '                    "name": "Customer Facing Service Id",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  }' +
            '                ]' +
            '              },' +
            '              {' +
            '                "name": "User",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "false",' +
            '                "externalId": "f2e195ae-049a-4c3f-bb08-eed2cba1ff89",' +
            '                "specId": "PS_000074",' +
            '                "startDate": "2017-11-23T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "attributes": [' +
            '                  {' +
            '                    "name": "Zone",' +
            '                    "type": "uiLOV",' +
            '                    "values": [' +
            '                      "4",' +
            '                      "1",' +
            '                      "3",' +
            '                      "2"' +
            '                    ],' +
            '                    "default": ""' +
            '                  },' +
            '                  {' +
            '                    "name": "Contract Term",' +
            '                    "type": "ui",' +
            '                    "values": [' +
            '                      "36 Months"' +
            '                    ],' +
            '                    "default": ""' +
            '                  },' +
            '                  {' +
            '                    "name": "User Type",' +
            '                    "type": "uiLOV",' +
            '                    "values": [' +
            '                      "Standard",' +
            '                      "Analogue"' +
            '                    ],' +
            '                    "default": ""' +
            '                  },' +
            '                  {' +
            '                    "name": "Customer Facing Service Id",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  },' +
            '                  {' +
            '                    "name": "Quantity",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  }' +
            '                ],' +
            '                "charges": [' +
            '                  {' +
            '                    "type": "RC",' +
            '                    "currency": "AUD",' +
            '                    "frequency": "Monthly",' +
            '                    "prices": [' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "2359abc9-8088-4e56-a5c0-19de77555527",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "150",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "2"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Standard"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "be0eeda7-12b5-4a77-9711-31f3719d1fb4",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "50",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "2"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Analogue"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "e758b74e-0514-411f-9f7e-6a2e58ebfa78",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "250",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "4"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Standard"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "846e795f-f43b-4992-9f09-c3641ad11c8f",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "150",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "1"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Standard"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "9d4ff31b-816f-484d-8b04-c54f782a727d",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "100",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "3"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Analogue"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "158b0886-564e-401f-9a18-d7e11f37c150",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "200",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "3"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Standard"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "13cfc030-10d2-4764-a77f-e09be33d3140",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "150",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "4"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Analogue"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "36 months",' +
            '                        "externalId": "4cdc86b0-1e7c-4cb5-9c66-edf3c861e8ee",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "50",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Zone",' +
            '                            "value": "1"' +
            '                          },' +
            '                          {' +
            '                            "name": "User_Type",' +
            '                            "value": "Analogue"' +
            '                          }' +
            '                        ]' +
            '                      }' +
            '                    ]' +
            '                  }' +
            '                ]' +
            '              },' +
            '              {' +
            '                "name": "Managed Device",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "true",' +
            '                "externalId": "e242acd2-e15c-4aaf-83d2-5a7a2fa883ff",' +
            '                "specId": "PS_000073",' +
            '                "startDate": "2017-11-22T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "attributes": [' +
            '                  {' +
            '                    "name": "Customer Facing Service Id",' +
            '                    "type": "ui",' +
            '                    "default": ""' +
            '                  }' +
            '                ],' +
            '                "products": [' +
            '                  {' +
            '                    "name": "Maintenance",' +
            '                    "type": "Default_Product_Specification",' +
            '                    "isProvisionable": "false",' +
            '                    "externalId": "7e667b64-485d-4b20-a715-93bd1770c123",' +
            '                    "specId": "PS_000076",' +
            '                    "startDate": "2017-11-23T13:00:00.000Z",' +
            '                    "endDate": "2099-12-30T13:00:00.000Z",' +
            '                    "attributes": [' +
            '                      {' +
            '                        "name": "Customer Facing Service Id",' +
            '                        "type": "ui",' +
            '                        "default": ""' +
            '                      }' +
            '                    ]' +
            '                  },' +
            '                  {' +
            '                    "name": "Device Management",' +
            '                    "type": "Default_Product_Specification",' +
            '                    "isProvisionable": "false",' +
            '                    "externalId": "eea28b0a-b41c-4b56-919a-679923e96d10",' +
            '                    "specId": "PS_000077",' +
            '                    "startDate": "2017-11-23T13:00:00.000Z",' +
            '                    "endDate": "2099-12-30T13:00:00.000Z",' +
            '                    "attributes": [' +
            '                      {' +
            '                        "name": "Customer Facing Service Id",' +
            '                        "type": "ui",' +
            '                        "default": ""' +
            '                      }' +
            '                    ]' +
            '                  }' +
            '                ]' +
            '              },' +
            '              {' +
            '                "name": "Bandwidth Clip On",' +
            '                "type": "Default_Product_Specification",' +
            '                "isProvisionable": "false",' +
            '                "externalId": "ab9cf67f-6ec4-48c4-b217-d26f46780ff5",' +
            '                "specId": "PS_000078",' +
            '                "startDate": "2017-11-23T13:00:00.000Z",' +
            '                "endDate": "2099-12-30T13:00:00.000Z",' +
            '                "charges": [' +
            '                  {' +
            '                    "type": "RC",' +
            '                    "currency": "AUD",' +
            '                    "frequency": "Monthly",' +
            '                    "prices": [' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "",' +
            '                        "externalId": "4cb0e507-866f-4ee7-a200-247089c3af5f",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "600",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Bandwidth",' +
            '                            "value": "20 MB"' +
            '                          }' +
            '                        ]' +
            '                      },' +
            '                      {' +
            '                        "startdate": "2017-11-24",' +
            '                        "enddate": "2099-12-31",' +
            '                        "term": "",' +
            '                        "externalId": "b8e0749d-de1b-4eb9-8296-345e3a777774",' +
            '                        "billingId": "",' +
            '                        "rateExcludeGST": "300",' +
            '                        "attributes": [' +
            '                          {' +
            '                            "name": "Bandwidth",' +
            '                            "value": "10 MB"' +
            '                          }' +
            '                        ]' +
            '                      }' +
            '                    ]' +
            '                  }' +
            '                ]' +
            '              }' +
            '            ]' +
            '          }' +
            '        ]' +
            '      }' +
            '    ]' +
            '  }' +
            '}';
        cs_SigmaToCSJSON obj = cs_SigmaToCSJSON.parse(json);
        system.debug('ashish check obj' + obj);
        System.assert(obj != null);
    }
}
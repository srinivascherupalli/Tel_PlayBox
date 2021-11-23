@isTest
	public class Test_SigmaToJSON{
		public static testmethod void testParse() {
			String json=		'{'+
			'  "package": {'+
			'    "name": "Marketable offer Name",'+
			'    "externalId": "Sigma GUID as External ID (do we still need this?)",'+
			'    "specId": "Sigma unique spec ID. Should be unique for all envs (mapped to CS PD if required)",'+
			'    "products": ['+
			'      {'+
			'        "name": "Product Name",'+
			'        "type": "Product/Group",'+
			'        "isProvisionable": "true/false",'+
			'        "specId": "Sigma Spec ID (mapped to CS PD if required)",'+
			'        "startDate": "Product Marketable Start Date in CS",'+
			'        "endDate": "Product Marketable End Date in CS",'+
			'        "attributes": ['+
			'          {'+
			'            "name": "Name of the attribute",'+
			'            "type": "User Input/System Defined/uiLOV/sdLOV. This need to discuss with Sigma more",'+
			'            "values": "[]",'+
			'            "default": "Default Value"'+
			'          }'+
			'        ],'+
			'        "charge": ['+
			'          {'+
			'            "type": "OC/RC",'+
			'            "currency": "AUD",'+
			'            "frequency": "Monthly/Weekly/Yearly",'+
			'            "price": ['+
			'              {'+
			'                "attributes": ['+
			'                  {'+
			'                    "name": "Attribute Name (this will be the custom field label?)",'+
			'                    "value": "Attribute value"'+
			'                  }'+
			'                ],'+
			'                "startDate": "Price Start Date in CS",'+
			'                "endDate": "Price End Date in CS",'+
			'                "term": "contract term (int)",'+
			'                "externalId": "Sigma GUID as External ID. This will be use as price external ID for CS pricing model (do we still need this?)",'+
			'                "billingId": "Sigma unique spec ID for billing. Should be unique for all envs. Not for SC 1",'+
			'                "rateExcludeGST": "price(amount)"'+
			'              }'+
			'            ]'+
			'          }'+
			'        ],'+
			'        "products": ['+
			'          {'+
			'            "name": "Product Name",'+
			'            "template": "Product/Group",'+
			'            "isProvisionable": "True/False",'+
			'            "specId": "Sigma Spec ID (mapped to CS PD if required)",'+
			'            "startDate": "Product Marketable Start Date in CS",'+
			'            "endDate": "Product Marketable End Date in CS",'+
			'            "attributes": ['+
			'              {'+
			'                "name": "Name of the attribute",'+
			'                "type": "User Input/System Defined/uiLOV/sdLOV. This need to discuss with Sigma more",'+
			'                "listOfValues": "[]",'+
			'                "default": "Default Value"'+
			'              }'+
			'            ],'+
			'            "charge": ['+
			'              {'+
			'                "type": "OC/RC",'+
			'                "currency": "AUD",'+
			'                "frequency": "Monthly/Weekly/Yearly",'+
			'                "price": ['+
			'                  {'+
			'                    "attributes": ['+
			'                      {'+
			'                        "name": "Attribute Name (this will be the custom field label?)",'+
			'                        "value": "Attribute value"'+
			'                      }'+
			'                    ],'+
			'                    "startDate": "Price Start Date in CS",'+
			'                    "endDate": "Price End Date in CS",'+
			'                    "term": "???",'+
			'                    "externalId": "Sigma GUID as External ID. This will be use as price external ID for CS pricing model (do we still need this?)",'+
			'                    "billingId": "Sigma unique spec ID for billing. Should be unique for all envs. Not for SC 1",'+
			'                    "rateExcludeGST": "price(amount)"'+
			'                  }'+
			'                ]'+
			'              }'+
			'            ],'+
			'            "products": []'+
			'          }'+
			'        ]'+
			'      }'+
			'    ],'+
			'    "charge": []'+
			' }'+
			' }';
			sigmaToJSON obj = sigmaToJSON.parse(json);
            
            /*sigmaToJSON jsonobj = new sigmaToJSON();
            jsonobj = obj;
            sigmaToJSON.cls_package jsonobjPack = new sigmaToJSON.cls_package();
            jsonobjPack = jsonobj.package_x;
			
            sigmaToJSON.cls_package.cls_products_package[] packprodatt= new sigmaToJSON.cls_package.cls_products_package[]{};
            //packprodatt =  jsonobjPack.package_x.products.attributes;
            
            system.debug('');*/
			System.assert(obj != null);
           
		}
	}
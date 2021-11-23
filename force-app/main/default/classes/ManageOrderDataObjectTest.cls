@isTest
public with sharing class ManageOrderDataObjectTest
{
	@isTest
	public static void testManagerOrderDTO(){

		//String json = dataSetup();
		String json = '{ '+
			'	"version": "1", '+
			'	"systemId": "CloudSense", '+
			'	"externalId": "Salesforce_Order_Number_Persisted_For_Lifecycle", '+
			'	"requestedCompletionDate": "2017-10-24T06:08-11:00", '+
			'	"orderSpecificationCode": "CloudSense_CPO", '+
			'	"orderCharacteristic": [ '+
			'		{ '+
			'			"value":"2017-02-24T06:08-11:00", '+
			'			"name":"Order_Submit_Date" 		 '+	
			'		}, '+
			'		{ '+
			'			"value":"Solution Manager", '+
			'			"name":"Project_Contact_Title"			 '+
			'		} '+
			'	], '+
			'	"relatedParty": [{ '+
			'	  "id": "Salesforce_Account_Number_Persisted_For_Lifecycle", '+
			'	  "name": "John Doe", '+
			'	  "type": "Consumer", '+
			'	  "role": "customer", '+
			'	  "href": "http://serverlocation:port/partyManagement/customer/345221" '+
			'	}], '+
			'	"orderItem": [ '+
			'	{ '+
			'		"id": "Salesforce_Device_Service_Number_Persisted_For_Lifecycle", '+
			'		"action": "Create", '+
			'		"requestedCompletionDate": "2017-10-23T06:32-11:00", '+
			'		"billingAccount": [ '+
			'		{ '+
			'			"id": "Billing_Account_Number", '+
			'			"accountType": "Billing Account" '+
			'		}], '+
			'		"appointment": { '+
			'			"id": "Appointment_Number", '+
			'			"category": "ADSL/Telstra", '+
			'			"startDate": "2017-04-19T16:42:23-04:00", '+
			'			"endDate": "2017-06-19T00:00:00-04:00"         '+
			'		}, '+
			'		"product": { '+
			'			"id": "Salesforce_Technical_Service_LineItem_Number_Persisted_For_Lifecycle", '+
			'			"action": "add", '+
			'			"productSpecification": { '+
			'			  "code": "Device_SIGMA_Product_Spec_Id" '+
			'			}, '+
			'			"productCharacteristic": [ '+
			'				{ '+
			'				  "value":"Switch", '+
			'				  "name":"Product_Group_Name"                   '+
			'				}, '+
			'				{ '+
			'				  "value": "Add", '+
			'				  "name": "Scenario_Type" '+
			'				}			 '+
			'			], '+
			'			"place": [ '+
			'			{ '+
			'				"role": "Installation", '+
			'				"address": { '+
			'					"id": "Salesforce_Address_Id", '+
			'					"type": "Postal", '+
			'					"street1": "Brevoort Place", '+
			'					"city": "Ellerslie", '+
			'					"stateOrProvince": "Victoria", '+
			'					"postCode": "3000", '+
			'					"country": "Australia", '+
			'					"buildingName": "Ovolo", '+
			'					"streetType": "Lane", '+
			'					"streetName": "Eagle Street", '+
			'					"streetNr": "225", '+
			'					"streetSuffix": "St", '+
			'					"locality": "Walker", '+
			'					"geocode": { '+
			'						"latitude": "-88.506381", '+
			'						"longitude": "-50.25214" '+
			'					} '+
			'				}, '+
			'				"contact": [ '+
			'				{ '+
			'					"id": "Salesforce_Contact_Id", '+
			'					"gender": "male", '+
			'					"type":"Site Contact", '+
			'					"givenName":"John", '+
			'					"familyName":"Doe", '+
			'					"title":"Mr.", '+
			'					"contactMedium": [ '+
			'						{ '+
			'							"type":"Email", '+
			'							"medium":{ '+
			'								"emailAddress":"john@domain.com" '+
			'							} '+ 
			'						}, '+
			'						{ '+
			'							"type":"Telephone", '+
			'							"medium":{ '+
			'								"number1":"+43664123456 7 " '+
			'							} '+
			'						}, '+
			'						{ '+
			'							"type":"Mobile", '+
			'							"medium":{ '+
			'								"number1":"+436641234567 " '+
			'							} '+
			'						} '+
			'					]		 '+								
			'				}] '+
			'			}],			 '+
			'			"productRelationship": [ '+
			'				{ '+
			'					"type": "contains", '+
			'					"product": { '+
			'						"id": "Salesforce_Technical_Service_LineItem_Number_Persisted_For_Lifecycle", '+
			'						"action": "add", '+
			'						"productSpecification": { '+
			'						  "code": "Managment_SIGMA_Product_Spec_Id" '+
			'						}, '+
			'						"productCharacteristic": [ '+
			'							{ '+
			'							  "value":"Switch", '+
			'							  "name":"Product_Group_Name" '+
			'							}, '+
			'							{ '+
			'							  "value": "Add", '+
			'							  "name": "Scenario_Type" '+
			'							}			 '+
			'						] '+
			'					} '+
			'				}, '+
			'				{ '+
			'					"type": "contains", '+
			'					"product": { '+
			'						"id": "Salesforce_Access_Service_Number_Persisted_For_Lifecycle", '+
			'						"action": "add", '+
			'						"productSpecification": { '+
			'						  "code": "Maintenance_SIGMA_Product_Spec_Id" '+
			'						}, '+
			'						"productCharacteristic": [ '+
			'							{ '+
			'							  "value":"Switch", '+
			'							  "name":"Product_Group_Name" '+
			'							}, '+
			'							{ '+
			'							  "value": "Add", '+
			'							  "name": "Scenario_Type" '+
			'							} '+
			'						] '+
			'					} '+
			'				} '+
			'			] '+
			'		} '+
			'	}, '+
			'	{ '+
			'		"id": "Salesforce_Access_Service_Number_Persisted_For_Lifecycle", '+
			'		"action": "Create", '+
			'		"requestedCompletionDate": "2017-10-23T06:32-11:00", '+
			'		"billingAccount": [ '+
			'		{ '+
			'			"id": "Billing_Account_Number", '+
			'			"accountType": "Billing Account" '+
			'		}], '+
			'		"appointment": { '+
			'			"id": "Appointment_Number", '+
			'			"category": "ADSL/Telstra", '+
			'			"startDate": "2017-05-19T16:42:23-04:00", '+
			'			"endDate": "2017-05-19T00:00:00-04:00"       '+  
			'		}, '+
			'		"product": { '+
			'			"id": "Salesforce_Service_Number_Persisted_For_Lifecycle", '+
			'			"action": "add", '+
			'			"productSpecification": { '+
			'			  "code": "Access_SIGMA_Product_Spec_Id" '+
			'			}, '+
			'			"productCharacteristic": [ '+
			'				{ '+
			'				  "value":"NBNN", '+
			'				  "name":"Product_Group_Name" '+
			'				}, '+
			'				{ '+
			'				  "value": "Add", '+
			'				  "name": "Scenario_Type" '+
			'				}			 '+
			'			], '+
			'			"place": [ '+
			'			{ '+
			'				"role": "Installation", '+
			'				"address": { '+
			'					"id": "Salesforce_Address_Id", '+
			'					"type": "Postal", '+
			'					"street1": "Brevoort Place", '+
			'					"city": "Ellerslie", '+
			'					"stateOrProvince": "Victoria", '+
			'					"postCode": "3000", '+
			'					"country": "Australia", '+
			'					"buildingName": "Ovolo", '+
			'					"streetType": "Lane", '+
			'					"streetName": "Eagle Street", '+
			'					"streetNr": "225", '+
			'					"streetSuffix": "St", '+
			'					"locality": "Walker", '+
			'					"geocode": { '+
			'						"latitude": "-88.506381", '+
			'						"longitude": "-50.25214" '+
			'					} '+
			'				}, '+
			'				"contact": [ '+
			'				{ '+
			'					"id": "Salesforce_Contact_Id", '+
			'					"gender": "male", '+
			'					"type":"Site Contact", '+
			'					"givenName":"John", '+
			'					"familyName":"Doe", '+
			'					"title":"Mr.", '+
			'					"contactMedium": [ '+
			'						{ '+
			'							"type":"Email",'+
			'							"medium":{'+
			'								"emailAddress":"john@domain.com"'+
			'							}'+
			'						},'+
			'						{'+
			'							"type":"Telephone",'+
			'							"medium":{'+
			'								"number":"+436641234567 "'+
			'							}'+
			'						},'+
			'						{'+
			'							"type":"Mobile",'+
			'							"medium":{'+
			'								"number":"+436641234567 "'+
			'							}'+
			'						}'+
			'					]	'+									
			'				}]'+
			'			}]'+
			'		}'+
			'	}]'+
			'}';

		ManageOrderDataObject.ProductOrder moDTO = new ManageOrderDataObject.ProductOrder();
		System.debug(ManageOrderDataObject.ProductOrder.class);
		System.debug(json);
		moDTO = (ManageOrderDataObject.ProductOrder) System.JSON.deserialize(json, ManageOrderDataObject.ProductOrder.class);

		System.debug(moDTO.version);
		System.debug(moDTO.systemId);
		System.debug(moDTO.externalId);
		System.debug(moDTO.requestedCompletionDate);
		System.debug(moDTO.orderSpecificationCode);
        
        
        System.assertEquals(moDTO.marketType , null);
        System.assertEquals(moDTO.orderReasonCode ,  null);
        //System.assert(moDTO.orderCharacteristic.size() > 0);
        //System.assert(moDTO.relatedParty.size() > 0);
        System.assertEquals(moDTO.orderRelationship , null);
        //System.assert(moDTO.orderItem.size() > 0);
		System.assertEquals(moDTO.orderCharacteristic[0].value , '2017-02-24T06:08-11:00');
		System.assertEquals(moDTO.orderCharacteristic[0].name , 'Order_Submit_Date');
        System.assertEquals(moDTO.relatedParty[0].id , 'Salesforce_Account_Number_Persisted_For_Lifecycle');
        System.assertEquals(moDTO.relatedParty[0].name , 'John Doe');
        System.assertEquals(moDTO.relatedParty[0].type , 'Consumer');
        System.assertEquals(moDTO.relatedParty[0].role , 'customer');
        System.assertEquals(moDTO.relatedParty[0].hRef , 'http://serverlocation:port/partyManagement/customer/345221');
        System.assertEquals(moDTO.orderItem[0].id , 'Salesforce_Device_Service_Number_Persisted_For_Lifecycle');
        System.assertEquals(moDTO.orderItem[0].version , null);
        System.assertEquals(moDTO.orderItem[0].requestedCompletionDate , '2017-10-23T06:32-11:00');
        System.assertEquals(moDTO.orderItem[0].action , 'Create') ;
        //System.assert(moDTO.orderItem[0].billingAccount.size() > 0);
        System.assertEquals(moDTO.orderItem[0].orderItemCharacteristic , null);
        System.assertEquals(moDTO.orderItem[0].billingAccount[0].id , 'Billing_Account_Number');
        System.assertEquals(moDTO.orderItem[0].billingAccount[0].name , null);
        System.assertEquals(moDTO.orderItem[0].billingAccount[0].href , null);
        System.assertEquals(moDTO.orderItem[0].billingAccount[0].accountType , 'Billing Account');
        
     	System.assertEquals(moDTO.orderItem[0].appointment.id  , 'Appointment_Number') ;
        System.assertEquals(moDTO.orderItem[0].appointment.href , null);
        System.assertEquals(moDTO.orderItem[0].appointment.category , 'ADSL/Telstra') ;
        System.assertEquals(moDTO.orderItem[0].appointment.startDate , '2017-04-19T16:42:23-04:00');
        System.assertEquals(moDTO.orderItem[0].appointment.endDate , '2017-06-19T00:00:00-04:00')  ;
        
      	System.assertEquals(moDTO.orderItem[0].Product.id    , 'Salesforce_Technical_Service_LineItem_Number_Persisted_For_Lifecycle') ;
        System.assertEquals(moDTO.orderItem[0].Product.action , 'add');
        //System.assert(moDTO.orderItem[0].Product.productCharacteristic.size() > 0);
        //System.assert(moDTO.orderItem[0].Product.productRelationship.size() > 0);
        //System.assert(moDTO.orderItem[0].Product.place.size() > 0);
        System.assertEquals(moDTO.orderItem[0].Product.productRelationship[0].type   , 'contains')  ;
      	System.assertEquals(moDTO.orderItem[0].Product.productRelationship[0].product.id  , 'Salesforce_Technical_Service_LineItem_Number_Persisted_For_Lifecycle')   ;
      	System.assertEquals(moDTO.orderItem[0].Product.productRelationship[0].product.action  , 'add')   ;
        //System.assert(moDTO.orderItem[0].Product.productRelationship[0].code  == null)   ;
        System.assertEquals(moDTO.orderItem[0].Product.productSpecification.code , 'Device_SIGMA_Product_Spec_Id');
        
        System.assertEquals(moDTO.orderItem[0].Product.place[0].role , 'Installation');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.id    , 'Salesforce_Address_Id') ;
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.href  , null) ;
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.type   , 'Postal');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.street1 , 'Brevoort Place');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.street2 , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.city   , 'Ellerslie');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.stateOrProvince , 'Victoria');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.postCode , '3000');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.country  , 'Australia');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.room     , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.apartment , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.floor    , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.buildingName , 'Ovolo');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.streetType , 'Lane');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.streetName , 'Eagle Street');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.streetNr   , '225');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.streetSuffix , 'St');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.locality   , 'Walker');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.town       , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.county     , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.geocode.latitude , '-88.506381');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].address.geocode.longitude , '-50.25214');
        
      	System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].id     , 'Salesforce_Contact_Id');
        //System.assert(moDTO.orderItem[0].Product.place[0].contact[0].name   == null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].gender , 'male');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].givenName , 'John');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].middleName , null);
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].familyName , 'Doe');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].title , 'Mr.');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].type   , 'Site Contact');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].contactMedium[0].type , 'Email');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].contactMedium[0].medium.emailAddress  , 'john@domain.com');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].contactMedium[1].type , 'Telephone');
        System.assertEquals(moDTO.orderItem[0].Product.place[0].contact[0].contactMedium[1].medium.number1  , '+43664123456 7 ');

        
        
	}
}
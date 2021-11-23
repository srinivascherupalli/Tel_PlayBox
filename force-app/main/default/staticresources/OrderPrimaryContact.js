/*----------------------------------------------------------
  1. Arinjay Singh		22-06-2020		EDGE-155244 			Spring 20 JS Upgrade refactoring	
 ------------------------------------------------------------**/

window.onInitOETab["Order primary Contact"] = function(){
	console.log("Order Primary Contact onInitOETab");
};

window.onInitOESchema["Order primary Contact"] = function(guid){

		let updateMap = {};
			updateMap[guid] = [
				{ name: "BasketId",  value: window.basketId }
			];
		Utils.updateOEConfigurations(updateMap);

	console.log("Order Primary Contact onInitOESchema", this, guid);

	window.rulesUpdateMap[guid] = [];

	var Rules = [
	{
		// Rule in place of lookup calculation
		Id: 0,
		SfId: null,
		Predicates: [
			{
				attName: "Order Primary Contact",
				operator: "!=",
				attValue: "",
				group: "0", 
				groupConjuction: null, 
				conjuction: null
			}
		],
		IfTrue: function(){
			let inputMap = {
					object: 'contact',
					id: Utils.getAttributeValue('Order Primary Contact', guid)
				},
				callback = function(values){
					let updateMap = [
						{ name: "phone_shadow", value: values.response[0].Phone },
						{ name: "mobile_shadow", value: values.response[0].MobilePhone },
						{ name: "last_name_shadow", value: values.response[0].LastName },
						{ name: "email_shadow", value: values.response[0].Email },
						{ name: "first_name_shadow", value: values.response[0].Name }
					];
					Utils.updateOEPayload(updateMap, guid);
					return Promise.resolve(true);
				};
			return Utils.remoteAction(inputMap, callback);
		},
		Else: function(){
			let updateMap = [
				{ name: "phone_shadow", value: "" },
				{ name: "mobile_shadow", value: "" },
				{ name: "last_name_shadow", value: "" },
				{ name: "email_shadow", value: "" },
				{ name: "first_name_shadow", value: "" }
			];
			Utils.updateOEPayload(updateMap, guid);
			return Promise.resolve(true);
		}
	},
	{
		Id: 1,
		SfId: 1851,
		Delay: true,
		Predicates: [
			{
				attName: "Order Primary Contact",
				operator: "!=",
				attValue: "",
				group: "0", 
				groupConjuction: "&&", 
				conjuction: null
			},
			
			{
				attName: "last_name_shadow",
				operator: "==",
				attValue: "",
				group: "1", 
				groupConjuction: null, 
				conjuction: "||"
			},
			{
				attName: "email_shadow",
				operator: "==",
				attValue: "",
				group: "1", 
				groupConjuction: null, 
				conjuction: "||"
			},
			{
				attName: "first_name_shadow",
				operator: "==",
				attValue: "",
				group: "1", 
				groupConjuction: null, 
				conjuction: null
			}
		],
		IfTrue: function(){
			/*
				To Code : 
				
				Mark Configuration Invalid [First Name, Last Name, Phone Number and E-mail ID are mandatory for a contact to be Order Primary Contact, Please update the contact details prior to selection]
			*/
			console.log(Date.now(), 'A SAD SE GLEDAJU SHADOWI');
			Utils.markOEConfigurationInvalid(guid, 'First Name, Last Name, Phone Number and E-mail ID are mandatory for a contact to be Order Primary Contact, Please update the contact details prior to selection');
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 2,
				SfId: 1852,
				Delay: true,
				Predicates: [
					
		{
			attName: "phone_shadow",
			operator: "==",
			attValue: "",
			group: "0", 
			groupConjuction: null, 
			conjuction: "&&"
		},
		{
			attName: "mobile_shadow",
			operator: "==",
			attValue: "",
			group: "0", 
			groupConjuction: null, 
			conjuction: ""
		}
		],
		IfTrue: function(){
			/*
				To Code : 
				
				Mark Configuration Invalid [First Name, Last Name, Phone Number and E-mail ID are mandatory for a contact to be Order Primary Contact, Please update the contact details prior to selection]
			*/
			console.log(Date.now(), 'A SAD SE GLEDAJU SHADOWI');
			Utils.markOEConfigurationInvalid(guid, 'First Name, Last Name, Phone Number and E-mail ID are mandatory for a contact to be Order Primary Contact, Please update the contact details prior to selection');
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
		}
		
	];
	return Rules;
};

window.noPredicate["Order primary Contact"] = async function(guid){
// EDGE-155244 Spring 20 changes added async to function definition 
	var orderPrimaryContact = Utils.getAttributeValue('Order Primary Contact', window.activeSchemaConfigGuid);

    var attributeUpdateMap = {};
	attributeUpdateMap[window.activeGuid] = [
		{
			name: "Orderprimarycontactid",
			value: {
				value: orderPrimaryContact,
				displayValue: orderPrimaryContact
			}
		}
	];
	console.log('Orderprimarycontactid: ', attributeUpdateMap)
// EDGE-155244 Spring 20 changes start here 
	//CS.SM.updateConfigurationAttribute(Utils.getConfigName(), attributeUpdateMap).then( component => console.log('updateConfigurationAttribute: ', component));
	let solution = await CS.SM.getActiveSolution();
	let parentConfig = Utils.getConfigName();
	let component = await solution.getComponentByName(parentConfig);
	//const config = await component.updateConfigurationAttribute(guid, attributeUpdateMap ,true );
	let keys = Object.keys(attributeUpdateMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], attributeUpdateMap[keys[i]], true); 
	}
// EDGE-155244 Spring 20 changes Ends here 
};	
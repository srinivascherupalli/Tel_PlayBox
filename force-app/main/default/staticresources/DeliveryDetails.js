/*----------------------------------------------------------
  1. Rohit Tripathi 	11-05-2020   	INC000092814557			Customer Contact - Phone number is not mandatory in B2BFORCE causing failure in downstream
  2. Laxmi Rahate		18-05-2020		EDGE-147799 			Added code to skip Validation when Delivery enrichment not needed	
  3. Arinjay Singh		22-06-2020		EDGE-155244 			Spring 20 JS Upgrade refactoring	
  4. Laxmi Rahate		16-Oct-2020		EDGE-174219				Addressing the issue of undefined
  5. Jamil				09-Nov-2021								Added as Part of R34 Fix
 ------------------------------------------------------------**/
 window.onInitOETab["Delivery details"] = function(){
	console.log("Delivery Details onInitOETab");
};
window.onInitOESchema["Delivery details"] = async function(guid){

	console.log("Delivery Details onInitOESchema", this, guid);
	window.rulesUpdateMap[guid] = [];
		let updateMap = {};
		updateMap[guid] = [
			{ name: "Basketid",  value: window.basketId }
		];
		await Utils.updateOEConfigurations(updateMap);

		var Rules = [
		{
			Id: 0,
			SfId: 1933,
			Predicates: [
				{
					attName: "DeliveryAddress",
					operator: "!=",
					attValue: "",
					group: "0", 
					groupConjuction: null, 
					conjuction: "&&"
				},
				{
					attName: "DeliveryContact",
					operator: "!=",
					attValue: "",
					group: "0", 
					groupConjuction: null, 
					conjuction: null
				}
			],
			IfTrue: function(){
				Utils.updateOEPayload([{ name: "IsDeliveryDetailsEnriched", value: true }], guid);
				return Promise.resolve(true);
			},
			Else: async function(){
				
				// Laxmi --------------Added Code for EDGE-147799
				/**if (Utils.getConfigName() === 'Mobile Subscription'){
						var shippingRequired =  Utils.getConfigAttributeValue('ShippingRequired');
						var deviceShipping =  Utils.getConfigAttributeValue('DeviceShipping');
						if (shippingRequired === 'FALSE' && deviceShipping === 'FALSE') { 
						Utils.updateOEPayload([{ name: "IsDeliveryDetailsEnriched", value: true }], guid);
						}
					}**/
					
					// EDGE-1472219 Changes 
				if (Utils.getConfigName() === 'Enterprise Mobility'  || Utils.getConfigName() === 'Mobile Subscription' ){
						var SimAvailabilityType =  Utils.getConfigAttributeValue('SimAvailabilityType');
						if ( SimAvailabilityType != "" && (!(SimAvailabilityType.toLowerCase()).includes ('new')) ) { 
						//console.log ( ' making it optional!!!!!!!!!!!!!!!!');
						Utils.updateOEPayload([
						{ name: "IsDeliveryDetailsEnriched", value:true }
						//{ name: "DeliveryContact", required: false  }, // Made it optional 
						//{ name: "DeliveryAddress",  required: false  } 
	
						], guid);

						}
						//else
						/**Utils.updateOEPayload([
						//{ name: "IsDeliveryDetailsEnriched", value:false  },
						{ name: "DeliveryContact", required: true   }, // Made it optional 
						{ name: "DeliveryAddress",  required: true   }
	
						], guid); **/
					}					
					//Changes END			
				//let solution = await CS.SM.getActiveSolution();
				//let currentBasket =  await CS.SM.getActiveBasket(); 
				
				//await currentBasket.updateSolution (solution.id);
				return Promise.resolve(true);
			}
	},
	{
		Id: 1,
		SfId: 1932,
		Predicates: [
			{
				attName: "DeliveryAddress",
				operator: "!=",
				attValue: "",
				group: "0", 
				groupConjuction: null, 
				conjuction: null
			}
		],
		IfTrue: async function(){
			let inputMap = {
					object: 'address',
					id: await Utils.getAttributeValue('DeliveryAddress', guid)
				},
				callback = function(values){
					console.log('DeliveryAddress updateOEPayload', values);
					Utils.updateOEPayload([
						{ name: "Address", value: values.response[0].Name },
						{ name: "ADBOIRId", value: values.response[0].Address_ID__c },
						{ name: "City", value: values.response[0].cscrm__City__c },
						{ name: "Postcode", value: values.response[0].cscrm__Zip_Postal_Code__c },
						{ name: "Street", value: values.response[0].Street_calc__c }
					], guid);
				};
			await Utils.remoteAction(inputMap, callback);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 2,
		SfId: 1931,
		Predicates: [
			{
				attName: "DeliveryContact",
				operator: "!=",
				attValue: "",
				group: "0", 
				groupConjuction: null, 
				conjuction: null
			}
		],
		IfTrue: async function(){
			let inputMap = {
					object: 'contact',
					id: await Utils.getAttributeValue('DeliveryContact', guid)
				},
				callback = function(values){
					console.log(values);
					Utils.updateOEPayload([
						{ name: "FirstName", value: values.response[0].FirstName || '' },
						{ name: "LastName", value: values.response[0].LastName },
						{ name: "Mobile", value: values.response[0].MobilePhone || '' }, // Laxmi Addedd  || '' to address undefined issue
						{ name: "Phone", value: values.response[0].Phone   || '' },  // Laxmi Addedd  || '' to address undefined issue
						{ name: "Email", value: values.response[0].Email  || '' }, // Laxmi Addedd  || '' to address undefined issue
						{ name: "Name", value: values.response[0].Name }
					], guid);
					return Promise.resolve(true);
				};
			return  await Utils.remoteAction(inputMap, callback);			
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	// Change for INC000092814557 by Rohit --> Start
    {
			Id: 3,
			SfId: 1934,
			Predicates: [
				{
					attName: "Phone",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: "&&",
					conjuction: "||" 
				},
				{
					attName: "Phone",
					operator: "==",
					attValue: "undefined",
					group: "0",
					groupConjuction: "&&",
					conjuction: "" 
				},
				{
					attName: "DeliveryContact",
					operator: "!=",
					attValue: "",
					group: "1",
					groupConjuction: null,
					conjuction: "" 
				}
			],
			IfTrue: function(){
				//Utils.markOEConfigurationInvalid(guid, 'Selected delivery contact does not have email id or phone number; Please update the contact details');
				CS.SM.displayMessage ('Selected delivery contact does not have email id or phone number; Please update the contact details');
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 4,
			SfId: 1935,
			Predicates: [
				{
					attName: "Email",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: "&&",
					conjuction: "||" 
				},{
					attName: "Email",
					operator: "==",
					attValue: "undefined",
					group: "0",
					groupConjuction: "&&",
					conjuction: "" 
				},
				{
					attName: "DeliveryContact",
					operator: "!=",
					attValue: "",
					group: "1",
					groupConjuction: null,
					conjuction: "" 
				}
			],
			IfTrue: function(){
				//Utils.markOEConfigurationInvalid(guid, 'Selected delivery contact does not have email id or phone number; Please update the contact details');
				CS.SM.displayMessage ('Selected delivery contact does not have email id or phone number; Please update the contact details');
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		}
		
		
		// Change for INC000092814557 by Rohit --> End

	];
	return Rules;
};

window.noPredicate["Delivery details"] = async function(guid){
	// Spring 20 changes added async to function definition 
	let parentConfig = Utils.getConfigName(),
		updateMap = {};
		updateMap[window.activeGuid] = [];

		updateMap[window.activeGuid].push({ name: 'SiteDeliveryContact', value: await Utils.getAttributeValue('DeliveryContact', guid), displayValue: await Utils.getAttributeValue('DeliveryContact', guid)})
		updateMap[window.activeGuid].push({ name: 'SiteDeliveryAddress', value: await Utils.getAttributeValue('DeliveryAddress', guid), displayValue: await Utils.getAttributeValue('DeliveryAddress', guid)})

		if ( ( Utils.getAttributeValue('DeliveryContact', guid)!==null ||await Utils.getAttributeValue('DeliveryContact', guid)!=='' ) &&  ( await Utils.getAttributeValue('DeliveryAddress', guid)!==null || await Utils.getAttributeValue('DeliveryAddress', guid)!=='' ) ){

				if (Utils.getConfigName() === 'Mobile Subscription'){
						var SimAvailabilityTypeVal =  Utils.getConfigAttributeValue('SimAvailabilityType');
						var deviceShipping =  Utils.getConfigAttributeValue('DeviceShipping');
						if ( (   !((SimAvailabilityTypeVal.toLowerCase()).includes ('new'))   && SimAvailabilityTypeVal!='' )&& deviceShipping === 'FALSE') { 
						Utils.updateOEPayload([{ name: "IsDeliveryDetailsEnriched", value: true }], guid);
						}
					}

					else {
						updateMap[window.activeGuid].push({ name: 'isDeliveryEnrichmentNeededAtt',value: false});
						console.log ( 'Setting the value of theisDeliveryEnrichmentNeededAtt from Delivery Details ' );
					}
	
			}
// EDGE-155244 Spring 20 changes starts here 
/* 	CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function(component){
		console.log(component);
	}); */

	
	//let component; Commented As Part R34 OE Fix.
	let solution = await CS.SM.getActiveSolution();
	/*for (let comp of Object.values(solution.components)) {
		for(let config of Object.values(comp.schema.configurations)){
			if(config.name.trim() == parentConfig){
				component = comp;
			}
		}
	} */ // Commented As part of R34 Fix.
	let component = await solution.getComponentBySchemaName(parentConfig); //Jamil: Added as Part of R34 Fix.

	//const config = await component.updateConfigurationAttribute(guid, updateMap ,true );
	var complock = component.commercialLock;
	if(complock) component.lock('Commercial', false);
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
	}
	if(complock) component.lock('Commercial', true);
	component.validate();
// EDGE-155244 Spring 20 changes ends here 
	return Promise.resolve(true);
};	
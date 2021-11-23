/*----------------------------------------------------------
  1. Ankit Goswami 		10/06/2020  	INC000093064228 Change error msg
  2. Arinjay Singh		22-06-2020		EDGE-155244 			Spring 20 JS Upgrade refactoring	

  3. Manish Berad       14/08/2020      EDGE-165632            Update Error message text & Automate CRD Date for mobiles on Order Enrichment screen for CMP
 ------------------------------------------------------------**/
window.onInitOETab["Customer requested Dates"] = function(){
	console.log("Customer Requested Dates onInitOETab");
	// On top header breadcrumb click
};
window.onInitOETab["Customer requested Dates Mobility"] = function(){
	console.log("Customer Requested Dates Mobility onInitOETab");
	// On top header breadcrumb click
};
window.onInitOETab["Customer Requested Dates TID"] = function(){
	console.log("Customer Requested Dates TID onInitOETab");
	// On top header breadcrumb click
};
window.onInitOESchema["Customer requested Dates"] = async function(guid){
	var configName = Utils.getConfigName() ;	
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(configName);
	//const config = await component.updateConfigurationAttribute(guid, updateMap ,true );
	var complock = component.commercialLock;
	if(complock) component.lock('Commercial', false);

	
	// just before runnign of rules - return Rules for calculation
	// Set row init values - set values not fetched from OE prior to rule execution, often needed for Rules to run properly

	console.log ('getConfigName ', configName);
	console.log('(new Date()).setHours(0,0,0,0)',(new Date()).setHours(0,0,0,0));
	let updateMap = {};
	updateMap[guid] = [
		{ name: "CommercialPDName", value: configName },
		{ name: "ChangeType", value: Utils.getConfigAttributeValue('ChangeType') },
	];
	await Utils.updateOEConfigurations(updateMap);

        //EDGE-165632  Automate CRD Date for mobiles on Order Enrichment screen for CMP
		/////////////////
		let nbCRD = await Utils.getAttributeValue('Not Before CRD', guid);
		let pfCRD = await Utils.getAttributeValue('Preferred CRD', guid);
		
		let updateMapNew = {};
		updateMapNew[guid] = [];
		//let solution = await CS.SM.getActiveSolution();
		comp = 	await solution.getComponentByName(configName); 
		//console.log("Customer Requested Dates Comp name ",comp.name);//Mobile Subscription
		//console.log("Customer Requested Dates Comp solutionName ",comp.solutionName);
		if((configName==="Mobile Subscription" || configName === "NextGenMobileDevice" || configName === "Enterprise Mobility") ){ //Added NGEM by laxmi
			if (nbCRD === "0" || nbCRD === "" || nbCRD === 0){
				console.log ('getConfigName55 ',nbCRD);
				updateMapNew[guid].push({
				name: 'Not Before CRD',
				showInUi: true,
				displayValue:Utils.formatDate((new Date()).setHours(0,0,0,0)),
				value:Utils.formatDate((new Date()).setHours(0,0,0,0))
				});		
				Utils.updateOEConfigurations(updateMapNew);
			}
			
			if  ((  configName === "Enterprise Mobility"  ||  configName === "NextGenMobileDevice"  )&& (nbCRD === "0" || nbCRD === "" || nbCRD === 0) &&  (pfCRD === "0" || pfCRD === "" || pfCRD === 0) ) 
				
			{
				console.log ('Updating Preferred CRD only in case of NGEM!!!!!!!!!!!' );
				updateMapNew[guid].push({
				name: 'Preferred CRD',
				showInUi: true,
				displayValue:Utils.formatDate((new Date()).setHours(0,0,0,0)),
				value:Utils.formatDate((new Date()).setHours(0,0,0,0))
				});		
				Utils.updateOEConfigurations(updateMapNew);				
			}
		}
	/////////////////////	
	console.log("Customer Requested Dates onInitOESchema", this, guid);
	window.rulesUpdateMap[guid] = [];
	var Rules = [
		{
			Id: 0,
			SfId: 1929,
			Predicates: [
				{
					attName: "ChangeType",
					operator: "==",
					attValue: "Cancel",
					group: "0", 
					groupConjuction: "", 
					conjuction: ""
				}
			],
			IfTrue: function(){
				Utils.updateOEPayload([{ name: "Not Before CRD", readOnly: true, required: false },{ name: "Preferred CRD", readOnly: true, required: false }], guid);
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 4,
			SfId: 1922,
			Predicates: [
				{
					attName: "Preferred CRD",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: null,
					conjuction: "||" 
				},
				{
					attName: "Preferred CRD",
					operator: "<",
					attValue: await Utils.getAttributeValue('Not Before CRD', guid), // Not Before CRD
					group: "0",
					groupConjuction: null,
					conjuction: null 
				}
			],
			IfTrue: async function(){
				let nbCRD = await Utils.getAttributeValue('Not Before CRD', guid);
				Utils.updateOEPayload([{ name: "Preferred CRD", showInUi: true, 
												readOnly: false, 
												value: Utils.formatDate(nbCRD), 
												displayValue: Utils.formatDate(nbCRD)}], 												
												guid);
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 5,
			SfId: 1920,
			Predicates: [
				{
					attName: "ChangeType",
					operator: "!=",
					attValue: "Cancel",
					group: "0",
					groupConjuction: null,
					conjuction: "&&" 
				},
				{
					attName: "Not Before CRD",
					operator: "<",
					attValue: (new Date()).setHours(0,0,0,0), // $Today //Changed by Venkat from Time.now() to resolve the issue with seconds for the same date.
					group: "0",
					groupConjuction: null,
					conjuction: null
				}
			],//EGE-98229 Added Below COndiftion for TID - For TID the validation has to be 30 days
			IfTrue: function(){
	if (Utils.getConfigName() === 'Internet Site'){
					Utils.markOEConfigurationInvalid(guid, 'Not Before CRD must be greater than 30 days from now!');
				}
			  else
			  {
				//EDGE-165632  Update Error message text
			    Utils.markOEConfigurationInvalid(guid, 'Not Before CRD can not be a past date.');
			  }
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 7,
			SfId: 1921,
			Predicates: [
				{
					attName: "Preferred CRD",
					operator: "<",
					attValue: await Utils.getAttributeValue('Not Before CRD', guid), // Not Before CRD
					group: "0",
					groupConjuction: null,
					conjuction: null 
				}
			],
			IfTrue: function(){
				Utils.markOEConfigurationInvalid(guid, 'Preferred CRD must be at least Not Before CRD or later');
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		}
	];
	return Rules;
};
window.onInitOESchema["Customer requested Dates Mobility"] = async function(guid){
	// just before runnign of rules - return Rules for calculation
	// Set row init values - set values not fetched from OE prior to rule execution, often needed for Rules to run properly
	console.log ('getConfigName ', Utils.getConfigName());
	let updateMap = {};
	updateMap[guid] = [
		{ name: "CommercialPDName", value: Utils.getConfigName() },
		{ name: "ChangeType", value: Utils.getConfigAttributeValue('ChangeType') }
	];
	Utils.updateOEConfigurations(updateMap);
	console.log("Customer Requested Dates Mobility onInitOESchema", this, guid);
	window.rulesUpdateMap[guid] = [];
	var Rules = [
		{
			Id: 2,
			SfId: 1926,
			Predicates: [
				{
					attName: "Not Before CRD Mobility",
					operator: "<",
					attValue: (new Date()).setHours(0,0,0,0), // $Today //Changed by Venkat from Time.now() to resolve the issue with seconds for the same date.,
					group: "0",
					groupConjuction: null,
					conjuction: "||"
				},
				{
					attName: "Not Before CRD Mobility",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: null,
					conjuction: null
				}
			],
			IfTrue: function(){
				//Utils.updateOEPayload([{ name: "Not Before CRD Mobility", showInUi: true, readOnly: false, value: Utils.formatDate(Date.now()), displayValue: Utils.formatDate(Date.now())}], guid);
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 3,
			SfId: 1928,
			Predicates: [
				{
					attName: "Preferred CRD Mobility",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: null,
					conjuction: "||"
				},
				{
					attName: "Preferred CRD Mobility",
					operator: "<",
					attValue: await Utils.getAttributeValue('Not Before CRD Mobility', guid), // Not Before CRD Mobility
					group: "0",
					groupConjuction: null,
					conjuction: null
				}
			],
			IfTrue: async function(){
				let pcrd = await Utils.getAttributeValue('Not Before CRD Mobility', guid);
				Utils.updateOEPayload([{ name: "Preferred CRD Mobility", showInUi: true, readOnly: false, value: Utils.formatDate(), displayValue: Utils.formatDate(pcrd)}], guid);
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 6,
			SfId: 1925,
			Predicates: [
				{
					attName: "Not Before CRD Mobility",
					operator: "<",
					attValue: (new Date()).setHours(0,0,0,0), // $Today //Changed by Venkat from Time.now() to resolve the issue with seconds for the same date.,
					group: "0",
					groupConjuction: null,
					conjuction: null
				}
			],
			IfTrue: function(){
				Utils.markOEConfigurationInvalid(guid, 'Not Before CRD Mobility must be greater than today');
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		}
	];
	return Rules;
};
window.noPredicate["Customer requested Dates"] = async function(guid) {
	// Spring 20 changes added async to function definition 
	// runs after all rules are calculated
	let parentConfig = Utils.getConfigName();
	let	updateMap = {};
	updateMap[window.activeGuid] = [];
	updateMap[window.activeGuid].push({
		name: 'Not Before CRD',
		value: await Utils.getAttributeValue('Not Before CRD', guid),
		displayValue: await Utils.getAttributeValue('Not Before CRD', guid)
	});
	updateMap[window.activeGuid].push({
		name: 'Preferred CRD',
		value: await Utils.getAttributeValue('Preferred CRD', guid),
		displayValue: await Utils.getAttributeValue('Preferred CRD', guid)
	});
	updateMap[window.activeGuid].push({
		name: 'Notes',
		value: await Utils.getAttributeValue('Notes', guid),
		displayValue: await Utils.getAttributeValue('Notes', guid)
	})
	// Spring 20 changes start here 
	/*	console.log('Customer Requested Dates updateMap', updateMap); 	
		CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function (component) {
		console.log('Customer Requested Dates', component);
	}); */
	let component;
	let solution = await CS.SM.getActiveSolution();
	for (let comp of Object.values(solution.components)) {
		for(let config of Object.values(comp.schema.configurations)){
			if(config.name.trim() == parentConfig){
				component = comp;
			}
		}
	}
	//let component = await solution.findComponentsByConfiguration(parentConfig);
	//const config = await component.updateConfigurationAttribute(guid, updateMap ,true );
	let keys = Object.keys(updateMap);	
	var complock = component.commercialLock;
	if (complock) 
		component.lock('Commercial', false);
	for (let i = 0; i < keys.length; i++) {		
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
	}
	if (complock) {
		component.lock('Commercial', true);
	}
	component.validate();
	// Spring 20 changes ends here 
 return Promise.resolve(true);
};
window.noPredicate["Customer requested Dates Mobility"] = async function(guid) {
	// Spring 20 changes added async to function definition 
	// runs after all rules are calculated
	let parentConfig = Utils.getConfigName(),
		updateMap = {};
	updateMap[window.activeGuid] = [];
	updateMap[window.activeGuid].push({
		name: 'Not Before CRD',
		value: await Utils.getAttributeValue('Not Before CRD Mobility', guid),
		displayValue: await Utils.getAttributeValue('Not Before CRD Mobility', guid)
	});
	updateMap[window.activeGuid].push({
		name: 'Preferred CRD',
		value: await Utils.getAttributeValue('Preferred CRD Mobility', guid),
		displayValue: await Utils.getAttributeValue('Preferred CRD Mobility', guid)
	});
	updateMap[window.activeGuid].push({
		name: 'Notes',
		value: await Utils.getAttributeValue('Notes', guid),
		displayValue: await Utils.getAttributeValue('Notes', guid)
	})
// EDGE-155244 Spring 20 changes start here 

/* 	CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function (component) {
		console.log('Customer Requested Dates', component);
	}); */
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(parentConfig);
	//const config = await component.updateConfigurationAttribute(guid, updateMap ,true );
	var complock = component.commercialLock;
	if(complock) component.lock('Commercial', false);
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
	}
	if(complock) component.lock('Commercial', true);
	// EDGE-155244 Spring 20 changes ends here 
	 return Promise.resolve(true);
};
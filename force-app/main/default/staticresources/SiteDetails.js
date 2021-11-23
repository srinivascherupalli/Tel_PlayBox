/******************************************************************************************
Change Version History
Version No	Author 			        Date
1 			Sandeep Y               Jun-2020          EDGE-155248 Spring 20 Changes 
*****************************************************************************************/
window.onInitOETab["Site details"] = function(){
	console.log("Site Details onInitOETab");
	
};
// Funcprimarycontact [attribute] fetch via remoteAction
window.onInitOESchema["Site details"] = async function(guid){//added async 
	// Update OE attributes

	let updateMap = {};
	updateMap[guid] = [
		{ name: "BasketId",  value: window.basketId },
		{ name: "BasketStageSite",  value: window.basketStage },
		{ name: "SiteID",  value: window.siteId }
		];
	await Utils.updateOEConfigurations(updateMap);//added await 

	console.log("Site Details onInitOESchema", this, guid);
	window.rulesUpdateMap[guid] = [];



	var Rules = [
		/*
	{
		Id: 1,
		SfId: 1843,
		Predicates: [
			{
				attName: "Primary Site Contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: null,
				conjuction: "&&"
			},
			{
				attName: "Funcprimarycontact",
				operator: "!==",
				attValue: "",
				group: "0",
				groupConjuction: null,
				conjuction: null
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "Primary Site Contact", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Funcprimarycontact', guid), displayValue: Utils.getAttributeDisplayValue('Funcprimarycontact', guid) },
				{ name: "Site Delivery Contact", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Funcprimarycontact', guid), displayValue: Utils.getAttributeDisplayValue('Funcprimarycontact', guid) },
				{ name: "PrimaryOld", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Funcprimarycontact', guid), displayValue: Utils.getAttributeDisplayValue('Funcprimarycontact', guid) },
				{ name: "SiteDelOld", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Funcprimarycontact', guid), displayValue: Utils.getAttributeDisplayValue('Funcprimarycontact', guid) }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 2,
		SfId: 1850,
		Predicates: [
			{
				attName: "BasketStageSite",
				operator: "==",
				attValue: "Submitted",
				group: "0", 
				groupConjuction: "", 
				conjuction: ""
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "After Hours Site Contact", readOnly: true, required: false },
				{ name: "Project Contact", readOnly: true, required: false },
				{ name: "Technical contact", readOnly: true, required: false },
				{ name: "Primary Site Contact", readOnly: true, required: false }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 3,
		SfId: 1842,
		Predicates: [
			{
				attName: "PrimaryOld",
				operator: "!=",
				attValue: Utils.getAttributeValue('Primary Site Contact', guid),
				group: "0", 
				groupConjuction: "", 
				conjuction: ""
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "Site Delivery Contact", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Primary Site Contact', guid), displayValue: Utils.getAttributeDisplayValue('Primary Site Contact', guid) },
				{ name: "PrimaryOld", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Primary Site Contact', guid), displayValue: Utils.getAttributeDisplayValue('Primary Site Contact', guid) },
				{ name: "PrimaryNew", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Funcprimarycontact', guid), displayValue: Utils.getAttributeDisplayValue('Funcprimarycontact', guid) },
				{ name: "SiteDelNew", showInUi: false, readOnly: false, value: Utils.getAttributeValue('Primary Site Contact', guid), displayValue: Utils.getAttributeDisplayValue('Primary Site Contact', guid) }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 4,
		SfId: 1844,
		Predicates: [
			{
				attName: "Project Contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: null,
				conjuction: "&&"
			},
			{
				attName: "Technical contact",
				operator: "!==",
				attValue: "",
				group: "0",
				groupConjuction: null,
				conjuction: null
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload(
				[{ name: "Project Contact", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Technical contact', guid), displayValue: Utils.getAttributeDisplayValue('Technical contact', guid)  }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 5,
		SfId: 1847,
		Predicates: [
			{
				attName: "Project Contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: "", 
				conjuction: "&&"
			},
			{
				attName: "Projconold",
				operator: "!==",
				attValue: "",
				group: "0",
				groupConjuction: null,
				conjuction: null
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "Project Contact", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Projconold', guid), displayValue: Utils.getAttributeDisplayValue('Projconold', guid)  }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 6,
		SfId: 1845,
		Predicates: [
			{
				attName: "Technical contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: "", 
				conjuction: ""
			}
		],
		IfTrue: function(){ return Promise.resolve(true);},
		Else: function(){return Promise.resolve(true);}
	},
	{
		Id: 7,
		SfId: 1848,
		Predicates: [
			{
				attName: "After Hours Site Contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: "", 
				conjuction: "&&"
			},
			{
				attName: "Afterhourconold",
				operator: "!==",
				attValue: "",
				group: "0",
				groupConjuction: null,
				conjuction: null
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "After Hours Site Contact", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Afterhourconold', guid), displayValue: Utils.getAttributeDisplayValue('Afterhourconold', guid)  }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	},
	{
		Id: 8,
		SfId: 1846,
		Predicates: [
			{
				attName: "Site Delivery Contact",
				operator: "==",
				attValue: "",
				group: "0", 
				groupConjuction: "", 
				conjuction: "&&"
			},
			{
				attName: "SiteDelOld",
				operator: "!==",
				attValue: "",
				group: "0",
				groupConjuction: null,
				conjuction: null
			}
		],
		IfTrue: function(){
			Utils.updateOEPayload([
				{ name: "Site Delivery Contact", showInUi: false, readOnly: false, value: Utils.getAttributeValue('SiteDelOld', guid), displayValue: Utils.getAttributeDisplayValue('SiteDelOld', guid) }
			], guid);
			return Promise.resolve(true);
		},
		Else: function(){
			return Promise.resolve(true);
		}
	}*/
	];
	return Rules;
};

window.noPredicate["Site details"] = async function(guid){
	// Spring 20 change added async to function definition 
	let updateMap = {};
		updateMap[window.activeGuid] = [];

	let updateMapOE = {};
		updateMapOE[guid] = [
			{ name: "Techconold", showInUi: false, readOnly: false, value: await Utils.getAttributeValue('Technical Contact', guid), displayValue: await Utils.getAttributeDisplayValue('Technical Contact', guid)},//added await 
			{ name: "Projconold", showInUi: false, readOnly: false, value: await Utils.getAttributeValue('Project Contact', guid), displayValue: await Utils.getAttributeDisplayValue('Project Contact', guid)},//added await 
			{ name: "Afterhourconold", showInUi: false, readOnly: false, value: await Utils.getAttributeValue('After Hours Site Contact', guid), displayValue: await Utils.getAttributeDisplayValue('After Hours Site Contact', guid) }//added await 
			];
	await Utils.updateOEConfigurations(updateMapOE);//added await

	// Update Config attributes
	updateMap[window.activeGuid] = [
	  { name: "Primarycontactid", value: await Utils.getAttributeValue('Primary Site Contact', guid)},//added await 
	  { name: "Technicalcontactid", value: await Utils.getAttributeValue('Technical Contact', guid)},  //added await  
	  { name: "AfterHourscontactid", value: await Utils.getAttributeValue('After Hours Site Contact', guid)}, //added await   
	  { name: "SiteDeliverycontactid", value: await Utils.getAttributeValue('Site Delivery Contact', guid)},  //added await  
	  { name: "Projectcontactid", value: await Utils.getAttributeValue('Project Contact', guid)}   //added await 
	];
// EDGE-155248 Spring 20 Changes Starts here 

/* 	CS.SM.updateConfigurationAttribute(Utils.getConfigName(), updateMap).then(function(component){
		console.log(component);
	}); */
	let parentConfig = Utils.getConfigName()
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(parentConfig);
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
		component.lock('Commercial', false);
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
		//component.lock('Commercial', true);
	}
	console.log(component);
	// EDGE-155248 Spring 20 Changes Ends here 
};
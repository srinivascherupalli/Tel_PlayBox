/******************************************************************************************
 * Author	   : CloudSense Team
 Change Version History
Version No	Author 			Date        Change Description 
1 			Venkat		 	18-Sept-19	Initial file  - EDGE 108257,EDGE 114158, EDGE 107435
2			Aditya			15-May-20	Edge-144971 - For displaying value on Tenancy OE
 ********************/


window.onInitOETab["Tenancy Contact Details"] = function(){
	console.log("Tenancy Contact Details onInitOETab");
	// On top header breadcrumb click
};



window.onInitOESchema["Tenancy Contact Details"] = async function(guid){
	// just before runnign of rules - return Rules for calculation
	// Set row init values - set values not fetched from OE prior to rule execution, often needed for Rules to run properly
	console.log ('getConfigName ', Utils.getConfigName());
	let updateMap = {};
		updateMap[guid] = [
			{ name: "CommercialPDName", value: Utils.getConfigName() },
			{ name: "ChangeType", value: Utils.getConfigAttributeValue('ChangeType') }
		];
		 
		Utils.updateOEConfigurations(updateMap);

	console.log("Tenancy Contact Details onInitOETab", this, guid);
	window.rulesUpdateMap[guid] = [];

	var Rules = [
		{
			Id: 0,
			SfId: 1900,
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
				Utils.updateOEPayload([{ name: "TenancyPrimaryContact", readOnly: true, required: false }], guid);
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		},
		{
			Id: 1,
			SfId: 1901,
			Predicates: [
				{
					attName: "TenancyPrimaryContact",
					operator: "==",
					attValue: "",
					group: "0",
					groupConjuction: null,
					conjuction: null
				}
			],
			IfTrue: function(){
                Utils.markOEConfigurationInvalid(guid, 'Tenancy Primary Contact should be provided');
				return Promise.resolve(false);
			},
			Else: async function(){
               // Edge-144971 - For displaying value on Tenancy OE
                Utils.updateOEPayload([{ name: "TenancyPrimaryContact", showInUi: true, readOnly: false, value: await Utils.getAttributeValue('TenancyPrimaryContact', guid), displayValue: await Utils.getAttributeDisplayValue('TenancyPrimaryContact', guid)}], guid);
				return Promise.resolve(true);
			}
		}
		
		
	];
	return Rules;
};

window.noPredicate["Tenancy Contact Details"] = async function(guid) {
	// runs after all rules are calculated
	let parentConfig = Utils.getConfigName(),
		updateMap = {};
	updateMap[window.activeGuid] = [];


	updateMap[window.activeGuid].push({
        name: 'Tenancy Primary Contact',
        // Edge-144971 - For displaying value on Tenancy OE
		value: await Utils.getAttributeValue('TenancyPrimaryContact', guid),
		displayValue: await Utils.getAttributeDisplayValue('TenancyPrimaryContact', guid)
	});

	let solution = await CS.SM.getActiveSolution();
    const component = solution.findComponentsByConfiguration(window.activeGuid);
    let keys = Object.keys(updateMap);
	
	var complock = component.commercialLock;
	if (complock){
			component.lock('Commercial', false);
	}
	for (let i = 0; i < keys.length; i++) {
		await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
	}
	if (complock) {
			component.lock('Commercial', true);
	}

	//CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function (component) {
	//	console.log('Tenancy Primary Contact', component);
	//});
};
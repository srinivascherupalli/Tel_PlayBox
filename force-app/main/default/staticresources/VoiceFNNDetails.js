/******************************************************************************************
* Author	   : 
Change Version History
Version No	Author 			        Date

1 			Sandeep Yelane          26-JUn-2020         Spring20 Upgrade

*****************************************************************************************/
window.onInitOETab["Voice FNN Details"] = function(){
	console.log("Voice FNN Details onInitOETab");
};
window.onInitOESchema["Voice FNN Details"] = function(guid){

	//noPredicate(guid);
	window.rulesUpdateMap[guid] = [];

	var Rules = [
			{
				Id: 0,
				SfId: 1971,
				Predicates: [
					{
						attName: "BasketStageVFNN",
						operator: "==",
						attValue: "Submitted",
						group: "0", 
						groupConjuction: null, 
						conjuction: null
					}
				],
				IfTrue: function(){
					// Set Configuration Name [Voice Number] NOT APPLICABLE
					Utils.updateOEPayload([{ name: "FromFNN", readOnly: true }, { name: "ToFNN", readOnly: true }], guid);
					return Promise.resolve(true);
				},
				Else: function(){
					return Promise.resolve(true);
				}
			},
			{
				Id: 1,
				SfId: 1970,
				Predicates: [
					{
						attName: "IPOldconfigidVFNN",
						operator: "!=",
						attValue: "",
						group: "0", 
						groupConjuction: null, 
						conjuction: "&&"
					},
					{
						attName: "IPChangeTypeVFNN",
						operator: "!=",
						attValue: "",
						group: "0", 
						groupConjuction: null, 
						conjuction: null
					}
				],
				IfTrue: function(){
					Utils.updateOEPayload([{ name: "FromFNN", readOnly: true }, { name: "ToFNN", readOnly: true }], guid);
					return Promise.resolve(true);
				},
				Else: function(){
					return Promise.resolve(true);
				}
			},
			{
				Id: 2,
				SfId: 1968,
				Predicates: [
					{
						attName: "Migrated",
						operator: "==",
						attValue: "No",
						group: "0", 
						groupConjuction: null, 
						conjuction: null
					}
				],
				IfTrue: function(){
					/*
						CS.binding.getBindings('Plan_0')[0].element.parent().parent().parent().css({'display': 'none'});
						CS.binding.getBindings('Legacy_Offer_Name_0')[0].element.parent().parent().parent().css({'display': 'none'});
					*/
					return Promise.resolve(true);
				},
				Else: function(){
					Utils.updateOEPayload([{ name: "FromFNN", readOnly: true }, { name: "ToFNN", readOnly: true }], guid);
					return Promise.resolve(true);
				}
			}
		];
	return Rules;
};

window.noPredicate["Voice FNN Details"] = async function(guid){
//Spring 20 Upgrade add async to the function definition  
	let updateMapOE = {};
		updateMapOE[guid] = [
			{ name: "Migrated", readOnly: true }
			];
	Utils.updateOEConfigurations(updateMapOE);

	let parentConfig = Utils.getConfigName(),
		updateMap = {};
		updateMap[window.activeGuid] = [];
		updateMap[window.activeGuid].push({ name: 'Voicefnnfrom', value: { value: Utils.getAttributeValue('FromFNN', guid) }});
		updateMap[window.activeGuid].push({ name: 'Voicefnnto', value: { value: Utils.getAttributeValue('ToFNN', guid) }});

	//Spring 20 Upgrade Starts Here 
/* 		CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function(component){
		console.log(component);
	}); */
	 let solution = await CS.SM.getActiveSolution();
	 let component = await solution.getComponentByName(parentConfig);
	 let keys = Object.keys(updateMap);
	 for (let i = 0; i < keys.length; i++) {
		 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
	 }
//Spring 20 Upgrade Ends Here 

};
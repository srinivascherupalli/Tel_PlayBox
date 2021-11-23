window.onInitOETab["Wifi Access Point"] = function(){
	console.log("Wifi Access Point onInitOETab");
};

window.onInitOESchema["Wifi Access Point"] = function(guid){
	console.log("Wifi Access Point onInitOESchema", this, guid);
	window.rulesUpdateMap[guid] = [];
	
	var Rules = [
		{
			Id: 0,
			SfId: 1965,
			Predicates: [
				{
					attName: "OldconfigidWifi",
					operator: "!=",
					attValue: "",
					group: "0", 
					groupConjuction: "", 
					conjuction: ""
				}
			],
			IfTrue: function(){
				Utils.updateOEPayload([{ name: "WifiModel", readOnly: true, required: false },{ name: "Number of SSIDs", readOnly: true, required: false }], guid);
				return Promise.resolve(true);
			},
			Else: function(){
			return Promise.resolve(true);
			}
		},
		{
			Id: 1,
			SfId: 1966,
			Predicates: [
				{
					attName: "Quantity",
					operator: "<",
					attValue: "1",
					group: "0", 
					groupConjuction: "", 
					conjuction: ""
				}
			],
			IfTrue: function(){
				Utils.markOEConfigurationInvalid(guid, 'Quantity cannot be less than 1');
				return Promise.resolve(true);
			},
			Else: function(){
				return Promise.resolve(true);
			}
		}
	];
	return Rules;
};

window.noPredicate["Wifi Access Point"] = function(guid){};		
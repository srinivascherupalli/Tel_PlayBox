window.onInitOETab["Wifi Access Point Accessory"] = function(){
	console.log("Wifi Access Point Accessory onInitOETab");
};
window.onInitOESchema["Wifi Access Point Accessory"] = function(guid){

	window.rulesUpdateMap[guid] = [];

	var Rules = [];
	return Rules;
};

window.noPredicate["Wifi Access Point Accessory"] = function(guid){};
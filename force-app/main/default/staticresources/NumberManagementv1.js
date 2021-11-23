window.onInitOETab["NumberManagementv1"] = function () {
    try {
        //remove Add / Delete buttons
        //document.getElementsByClassName('section-header')[0].style.display = "none";
    } catch (error) {
        
    }
};

window.onInitOESchema["NumberManagementv1"] = function(guid){

    console.log("NumberManagementv1", this, guid);    
	window.rulesUpdateMap[guid] = [];
	var Rules = [];
	return Rules;
};

window.noPredicate["NumberManagementv1"] = function(guid){
};
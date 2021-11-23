window.onInitOETab["MobileNumberManagementv1"] = function () {
    try {
        //remove Add / Delete buttons
        //document.getElementsByClassName('section-header')[0].style.display = "none";
    } catch (error) {

    }
};

window.onInitOESchema["MobileNumberManagementv1"] = async function(guid){

    console.log("MobileNumberManagementv1", this, guid);
    window.rulesUpdateMap[guid] = [];
    var Rules = [];
    return Rules;
};

window.noPredicate["MobileNumberManagementv1"] = function(guid){
};
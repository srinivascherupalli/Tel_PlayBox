window.onInitOETab["Site and Contacts"] = function () {//EDGE-137491 Component name changed
    try {
        console.log("onInitOETab Site and Contacts ");
        //remove Add / Delete buttons
        document.getElementsByClassName('section-header')[0].setAttribute('style','display:block !important');
        updateOEProductCheckbox();
    } catch (error) {
        console.log('onInitOETab: '+error)
    }
};

window.onInitOESchema["Site and Contacts"] = function(guid){
    
    console.log("onInitOESchema Site and Contacts", this, guid);
    updateOEProductCheckbox();
    window.rulesUpdateMap[guid] = [];
    var Rules = [];
    return Rules;
};

window.noPredicate["Site and Contacts"] = function(guid){
};

function updateOEProductCheckbox() {
    var activeObjects = document.getElementsByClassName('oe-product-checkbox-wrapper');
    for (var i = 0; i < activeObjects.length; i++) {
        document.getElementsByClassName('oe-product-checkbox-wrapper')[i].setAttribute('style','visibility:visible !important');
    }
}
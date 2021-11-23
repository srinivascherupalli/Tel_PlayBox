window.onInitOETab["Tenancy"] = function () {
    try {
        console.log("onInitOETab Tenancy ");
        //remove Add / Delete buttons
        document.getElementsByClassName('section-header')[0].setAttribute('style','display:block !important');
        updateOEProductCheckbox();
        var element = document.getElementById("OperationUserSelMsg");
        if(element)
            element.parentNode.removeChild(element);//EDGE-137491          
    } catch (error) {
        console.log('onInitOETab: '+error)
    }
};
window.onInitOETab["Technical Details"] = function () {
    try {
        console.log("onInitOETab Technical Details ");
        //remove Add / Delete buttons
        document.getElementsByClassName('section-header')[0].setAttribute('style','display:none !important');
        var element = document.getElementById("OperationUserSelMsg");
        if(element)
            element.parentNode.removeChild(element);//EDGE-137491          
    } catch (error) {
        console.log('onInitOETab: '+error)
    }
};

window.onInitOESchema["Tenancy"] = function(guid){
    
    console.log("onInitOESchema Tenancy", this, guid);
    updateOEProductCheckbox();
    window.rulesUpdateMap[guid] = [];
    var Rules = [];
    return Rules;
};

window.noPredicate["Tenancy"] = function(guid){
};

function updateOEProductCheckbox() {
    var activeObjects = document.getElementsByClassName('oe-product-checkbox-wrapper');
    for (var i = 0; i < activeObjects.length; i++) {
        document.getElementsByClassName('oe-product-checkbox-wrapper')[i].setAttribute('style','visibility:visible !important');
    }
}
/*----------------------------------------------------------
  1. Sandeep Yelane		26-06-2020		EDGE-155255 			Spring 20 JS Upgrade refactoring	
  2. Pallavi D          12.08.2020      EDGE-169832
 ------------------------------------------------------------**/
 window.onInitOETab["Subscription"] = function () {//EDGE-137491 component name changed
    try {
        console.log("onInitOETab Network Services ");
        //remove Add / Delete buttons
        document.getElementsByClassName('section-header')[0].setAttribute('style','display:block !important');
        updateOEProductCheckbox();
		removeOpsUserMsg();//EDGE-137491
    } catch (error) {
        console.log('onInitOETab: '+error)
    }
};

window.onInitOESchema["Subscription"] = function(guid){      
      updateOEProductCheckbox();
     window.rulesUpdateMap[guid] = [];
   	 var oeMap = [];
   		var Rules=[];
     	var basketHasTC =false;    	
    	var basketsol =window.basketsolutions;
    	basketsol.forEach((comp) => {
                        if(comp.OfferId=='DMCAT_Offer_000618')  {// EDGE-169832
            				basketHasTC=true;
           					 console.log('basketHasTC'+basketHasTC);
       					}
      		  });
    	
      		if(!basketHasTC){  
                console.log('basketHasTC in'+basketHasTC);
                    Rules = [
                                {
                                    Id: 1,
                                    SfId: 1901,
                                    Predicates: [
                                        {
                                            attName: "Network",
                                            operator: "==",
                                            attValue: "",
                                            group: "0",
                                            groupConjuction: null,
                                            conjuction: null
                                        }
                                    ],
                                    IfTrue: function(){
                                        Utils.markOEConfigurationInvalid(guid, 'Please select a Subscription.');
                                        return Promise.resolve(false);
                                    },
                                    Else: function(){
                                        //Utils.updateOEPayload([{ name: "Network", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Network', guid), displayValue: Utils.getAttributeValue('Network', guid)}], guid);
                                        return Promise.resolve(true);
                                    }
                                }
                            ];
						}
                       else{
                           var message='Telstra Collaboration Subscriptions ordered as part of this basket will be included in this Professional Services by default and do not need to be selected.';
                            var finmessage='<div id="TCPSNetworkAlert" ><br/><div class="slds-box slds-text-body_regular slds-theme_shade slds-size_7-of-8 slds-align_absolute-center slds-text_medium" style="border: 2px solid #098deb;background-color:#f0f8fc;font-family:Salesforce Sans"><lightning:icon iconName="utility:info_alt" alternativeText="Utility image" title="Image" ></lightning:icon> '+message + '</div><br/></div>';
                            var InfoMsgTCPS = document.createElement('p'); // is a node
                            InfoMsgTCPS.innerHTML = finmessage;
                            var config = Array.prototype.slice.call(document.querySelectorAll('app-specification-editor-attribute input')).filter(function(item){ return item.value == guid; });
                            if(config){
                            
                                if(document.getElementsByClassName("modal-header-secondary")[0].innerHTML.indexOf(message)==-1){                             
                                    document.getElementsByClassName("modal-header-secondary")[0].appendChild(InfoMsgTCPS);
                                }
                            }
						}    
      return Rules;
};

window.noPredicate["Subscription"] = async function(guid){
    // Spring 20 changes added async to function definition 
    	// runs after all rules are calculated
	let parentConfig = Utils.getConfigName(),
		updateMap = {};
	updateMap[window.activeGuid] = [];
	updateMap[window.activeGuid].push({
		name: 'Network',
		value: await Utils.getAttributeValue('Network', guid),
		displayValue:await Utils.getAttributeValue('Network', guid)
	});
// EDGE-155255 Spring 20 Changes Start
/* 	CS.SM.updateConfigurationAttribute(parentConfig, updateMap).then(function (component) {
		console.log('Subscription', component);
    }); */
    let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(parentConfig);
	//const config = await component.updateConfigurationAttribute(guid, updateMap ,true );
	let keys = Object.keys(updateMap);
	for (let i = 0; i < keys.length; i++) {
        component.lock('Commercial',false);
        await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
        //component.lock('Commercial',true);
	}
    console.log('Subscription', component);
// EDGE-155255 Spring 20 Changes End
};
window.onInitOETab["Operations User"] = function () {//EDGE-137491 component name changed
    try {
         removeSubscriptionMsg();
        console.log("OE  Tab Operations User Selection");
        //remove Add / Delete buttons     
        var element = document.getElementById("TCPSNetworkAlert");
        if(element)
    	  element.parentNode.removeChild(element);
        
        document.getElementsByClassName('section-header')[0].setAttribute('style','display:none !important');
    } catch (error) {
        console.log('onInitOETab: '+error)
    }
};

window.onInitOETab["Site and Contacts"] = function () {//EDGE-137491 component name changed
    var element = document.getElementById("TCPSNetworkAlert");
    if(element)
    	element.parentNode.removeChild(element);
		removeOpsUserMsg();//EDGE-137491
};
//EDGE-137491 Start
window.onInitOESchema["Operations User"] = function () {
	try{
        var message='Select the user who will be responsible for assigning the tasks associated with this Professional Services order.';
        var finmessage='<div id="OperationUserSelMsg" ><br/><div class="slds-box slds-text-body_regular slds-theme_shade slds-size_7-of-8 slds-align_absolute-center slds-text_medium" style="border: 2px solid #098deb;background-color:#f0f8fc;font-family:Salesforce Sans"><lightning:icon iconName="utility:info_alt" alternativeText="Utility image" title="Image" ></lightning:icon> '+message + '</div><br/></div>';
        var InfoMsgTCPS = document.createElement('p'); // is a node
        InfoMsgTCPS.innerHTML = finmessage;

        if(document.getElementsByClassName("modal-header-secondary")[0].innerHTML.indexOf(message)==-1){                             
            document.getElementsByClassName("modal-header-secondary")[0].appendChild(InfoMsgTCPS);
        }
    } catch (error) {
        console.log('onInitOESchemaOpsUsr: '+error);
    }		
};
function removeSubscriptionMsg() {
    var element = document.getElementById("TCPSNetworkAlert");
    if(element)
        element.parentNode.removeChild(element);    
}
function removeOpsUserMsg() {
    var element = document.getElementById("OperationUserSelMsg");
    if(element)
        element.parentNode.removeChild(element);    
}
//EDGE-137491 End
function updateOEProductCheckbox() {
    var activeObjects = document.getElementsByClassName('oe-product-checkbox-wrapper');
    for (var i = 0; i < activeObjects.length; i++) {
        document.getElementsByClassName('oe-product-checkbox-wrapper')[i].setAttribute('style','visibility:visible !important');
    }
}
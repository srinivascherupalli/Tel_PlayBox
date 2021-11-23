/*-------------------------------------------------------------------------------------------------------
  1. Sandeep Yelane		26-06-2020		EDGE-155255 			Spring 20 JS Upgrade refactoring	
  2. Pallavi D          12.08.2020      EDGE-169832
  3. Pooja Gupta        11-Sep-202      EDGE-171653             JS Optimization
  4.RaviTeja]           06-11-2020      EDGE-186075             Hiding Operation user message for Customer Reference Number tab             
 --------------------------------------------------------------------------------------------------------**/
window.onInitOETab["Subscription"] = function () {
	//EDGE-137491 component name changed
	try {
		//console.log("onInitOETab Network Services ");//Commented by Pooja_RF
		//remove Add / Delete buttons
		document.getElementsByClassName("section-header")[0].setAttribute("style", "display:block !important");
		updateOEProductCheckbox(); //It's use
		removeOpsUserMsg(); //EDGE-137491
	} catch (error) {
		console.log("onInitOETab: " + error);
	}
};

window.onInitOETab["Customer Reference Number"] = function () {
	try {
		removeOpsUserMsg();  //EDGE-186075
	} catch (error) {
		console.log("onInitOETab: " + error);
	}
};

window.onInitOESchema["Subscription"] = function (guid) {
	updateOEProductCheckbox();
	window.rulesUpdateMap[guid] = [];
	//var oeMap = [];//Commented by Pooja_RF
	let Rules = []; // changed var to let--RF
	let basketHasTC = false; // changed var to let--RF
	let basketsol = window.basketsolutions; // changed var to let--RF
	basketsol.forEach((comp) => {
		if (comp.OfferId == "DMCAT_Offer_000618") {
			// EDGE-169832
			basketHasTC = true;
			//console.log('basketHasTC'+basketHasTC);//Commented by Pooja_RF
		}
	});

	if (!basketHasTC) {
		//console.log('basketHasTC in'+basketHasTC);//Commented by Pooja_RF
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
				IfTrue: function () {
					Utils.markOEConfigurationInvalid(guid, "Please select a Subscription.");
					return Promise.resolve(false);
				},
				Else: function () {
					//Utils.updateOEPayload([{ name: "Network", showInUi: true, readOnly: false, value: Utils.getAttributeValue('Network', guid), displayValue: Utils.getAttributeValue('Network', guid)}], guid);
					return Promise.resolve(true);
				}
			}
		];
	} else {
		let message = "Telstra Collaboration Subscriptions ordered as part of this basket will be included in this Professional Services by default and do not need to be selected."; // changed var to let--RF
		let finmessage =
			'<div id="TCPSNetworkAlert" ><br/><div class="slds-box slds-text-body_regular slds-theme_shade slds-size_7-of-8 slds-align_absolute-center slds-text_medium" style="border: 2px solid #098deb;background-color:#f0f8fc;font-family:Salesforce Sans"><lightning:icon iconName="utility:info_alt" alternativeText="Utility image" title="Image" ></lightning:icon> ' +
			message +
			"</div><br/></div>"; // changed var to let--RF
		let InfoMsgTCPS = document.createElement("p"); // is a node // changed var to let--RF
		InfoMsgTCPS.innerHTML = finmessage;
		let config = Array.prototype.slice.call(document.querySelectorAll("app-specification-editor-attribute input")).filter(function (item) {
			return item.value == guid;
		}); // changed var to let--RF
		if (config) {
			if (document.getElementsByClassName("modal-header-secondary")[0].innerHTML.indexOf(message) == -1) {
				document.getElementsByClassName("modal-header-secondary")[0].appendChild(InfoMsgTCPS);
			}
		}
	}
	return Rules;
};

window.noPredicate["Subscription"] = async function (guid) {
	// Spring 20 changes added async to function definition
	// runs after all rules are calculated
	let parentConfig = Utils.getConfigName(),
		updateMap = {};
	let network = await Utils.getAttributeValue("Network", guid); //RF++
	updateMap[window.activeGuid] = [];
	updateMap[window.activeGuid].push({
		name: "Network",
		value: /*await Utils.getAttributeValue('Network', guid)*/ network, //RF++
		displayValue: /*await Utils.getAttributeValue('Network', guid)*/ network //RF++
	});

	// EDGE-155255 Spring 20 Changes Start
	let solution = await CS.SM.getActiveSolution();
	let component = await solution.getComponentByName(parentConfig);
	//let keys = Object.keys(updateMap); //RF--
	//for (let i = 0; i < keys.length; i++) { //RF--
	component.lock("Commercial", false);
	//await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); //RF--
	await component.updateConfigurationAttribute(window.activeGuid, updateMap, true); //RF++
	//}
	//console.log('Subscription', component); //RF--
	// EDGE-155255 Spring 20 Changes End
};

window.onInitOETab["Operations User"] = function () {
	//EDGE-137491 component name changed
	try {
		removeSubscriptionMsg();
		console.log("OE  Tab Operations User Selection");
		//remove Add / Delete buttons
		let element = document.getElementById("TCPSNetworkAlert"); //var to let
		if (element) element.parentNode.removeChild(element);

		document.getElementsByClassName("section-header")[0].setAttribute("style", "display:none !important");
	} catch (error) {
		console.log("onInitOETab: " + error);
	}
};

window.onInitOETab["Site and Contacts"] = function () {
	//EDGE-137491 component name changed
	let element = document.getElementById("TCPSNetworkAlert"); // changed var to let--RF
	if (element) element.parentNode.removeChild(element);
	removeOpsUserMsg(); //EDGE-137491

	//Moved from PSEnrich--start
	try {
		//console.log("onInitOETab Site and Contacts ");//Commented by Pooja_RF
		//remove Add / Delete buttons
		document.getElementsByClassName("section-header")[0].setAttribute("style", "display:block !important");
		updateOEProductCheckbox();
	} catch (error) {
		console.log("onInitOETab: " + error);
	}
	//Moved from PSEnrich--end
};

//Moved from PSEnrich--start
window.onInitOESchema["Site and Contacts"] = function (guid) {
	//Can we move this to PSNetwork???
	//console.log("onInitOESchema Site and Contacts", this, guid);//Commented by Pooja_RF
	updateOEProductCheckbox();
	window.rulesUpdateMap[guid] = [];
	let Rules = []; // changed var to let--RF
	return Rules;
};
//Moved from PSEnrich--end

//EDGE-137491 Start
window.onInitOESchema["Operations User"] = function () {
	try {
		let message = "Select the user who will be responsible for assigning the tasks associated with this Professional Services order."; // changed var to let--RF
		let finmessage =
			'<div id="OperationUserSelMsg" ><br/><div class="slds-box slds-text-body_regular slds-theme_shade slds-size_7-of-8 slds-align_absolute-center slds-text_medium" style="border: 2px solid #098deb;background-color:#f0f8fc;font-family:Salesforce Sans"><lightning:icon iconName="utility:info_alt" alternativeText="Utility image" title="Image" ></lightning:icon> ' +
			message +
			"</div><br/></div>"; // changed var to let--RF
		let InfoMsgTCPS = document.createElement("p"); // is a node // changed var to let--RF
		InfoMsgTCPS.innerHTML = finmessage;

		if (document.getElementsByClassName("modal-header-secondary")[0].innerHTML.indexOf(message) == -1) {
			document.getElementsByClassName("modal-header-secondary")[0].appendChild(InfoMsgTCPS);
		}
	} catch (error) {
		console.log("onInitOESchemaOpsUsr: " + error);
	}
};
function removeSubscriptionMsg() {
	let element = document.getElementById("TCPSNetworkAlert"); // changed var to let--RF
	if (element) element.parentNode.removeChild(element);
}
function removeOpsUserMsg() {
	let element = document.getElementById("OperationUserSelMsg"); // changed var to let--RF
	if (element) element.parentNode.removeChild(element);
}
//EDGE-137491 End

function updateOEProductCheckbox() {
	let activeObjects = document.getElementsByClassName("oe-product-checkbox-wrapper"); // changed var to let--RF
	for (let i = 0; i < activeObjects.length; i++) {
		// changed var to let--RF
		document.getElementsByClassName("oe-product-checkbox-wrapper")[i].setAttribute("style", "visibility:visible !important");
	}
}

/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[IoTConn_Main] loaded');

var IOTCONNECTIVITY_COMPONENTS = {
	solutionname: "IoT connectivity",
	iotPlans: "IoT Plans",
	comittedDataSolutionEditableFields: ["SharedPlan"],
    solutionNonEditableAttributeListForCancel: ["OfferName","Solution Name","BillingAccountLookup"],
    subscriptionNonEditableAttributeListForCancel: ["SelectPlanType", "Select Plan", "OfferType", "SIM Type", "SharedPlan"],
};
var sharedDataPlan = "Shared Data Plan";

RegisterPluginAdapter.execute(IOTCONNECTIVITY_COMPONENTS.solutionname, 'IOTConnectivity_Plugin');
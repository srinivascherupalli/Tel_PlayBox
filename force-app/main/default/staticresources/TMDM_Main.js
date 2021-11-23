/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[TMDM_Main] loaded');

const TENANCY_COMPONENT_NAMES = {
	solution: "Telstra Mobile Device Management - VMware", //'Telstra Mobile Device Management Tenancy',
	tenancy: "Platform"
};
var solution = "";
var tenancyAPIdone = false;
var updateVendorName = false;
var isVendorNull = false;
var offerName = "DMCAT_Offer_000681"; //EDGE-119833
var DEFAULTSOLUTIONNAME_TMDM = "Telstra Mobile Device Management - VMware"; //Added as part of EDGE-149887
var c = 0;
var billingAccount = "";

RegisterPluginAdapter.execute(TENANCY_COMPONENT_NAMES.solution, 'TMDM_Plugin');
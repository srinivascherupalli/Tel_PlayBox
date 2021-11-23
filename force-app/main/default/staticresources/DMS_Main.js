/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[DMS_Main] loaded');

const DMS_COMPONENT_NAMES = {
	solution: "Digital Managed Service",
	tenancy: "DMS Product"
};
var mdmtenancyid = null;
var solution = "";
var isTypeNew = false;
var tenancyAPIdone = false;
var offerName = "DMCAT_Offer_001540";
var DEFAULTSOLUTIONNAME_DMS = "Digital Managed Service";
var c = 0;
var billingAccount = "";
var communitySiteId = "";

RegisterPluginAdapter.execute(DMS_COMPONENT_NAMES.solution, 'Tenancy_Plugin');
/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[EnterpriseManagedService_Main] loaded');

var EMS_COMPONENT_NAMES = {
    solution: "Adaptive Mobility Managed Services",
    mobilityPlatformMgmt: "Endpoint Management - Platform Management", //DIGI-809 name change
    userSupport: "Endpoint Management - User Support" //DIGI-809 name change
};
var communitySiteId;
var changetypeMACsolution = null;

//currentSolution?
//parentBillingAccountATT?
//BasketChange?
//basketId?
//basketStage?
//basketChangeType?

RegisterPluginAdapter.execute(EMS_COMPONENT_NAMES.solution, 'EMS_Plugin');
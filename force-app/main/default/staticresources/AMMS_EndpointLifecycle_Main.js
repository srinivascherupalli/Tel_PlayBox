/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[AMMS_EndpointLifecycle_Main] loaded');

var EndpointLifecycle_COMPONENTS = {			
	solution: 'Adaptive Mobility Managed Services Modular - Endpoint Lifecycle',
	LifecycleManagement: 'Endpoint Lifecycle'
};
let inputMapAMMS = {};

RegisterPluginAdapter.execute(EndpointLifecycle_COMPONENTS.solution, 'EndpointLifecycle_Plugin');
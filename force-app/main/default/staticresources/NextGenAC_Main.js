/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[NextGenAC_Main] loaded');

var NextGenFC_COMPONENTS = {			
	solution: 'Adaptive Mobility Care',
	AdaptiveCare: 'Adaptive Care'
};
let inputMap = {};

RegisterPluginAdapter.execute(NextGenFC_COMPONENTS.solution, 'NGMAC_Plugin');
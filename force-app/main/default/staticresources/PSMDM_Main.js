/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[PSMDM_Main] loaded');

const PSMDM_COMPONENT_NAMES = {
	solution: 'T-MDM Professional Services',
	UC: 'Configurations', //'T-MDM Professional Services'
	OfferName: 'T-MDM Professional Services'
};
var DEFAULTSOLUTIONNAME_TMDM_PS = 'Professional Services';  //Added as part of EDGE-149887
var DEFUALTOFFERNAME_TMDM_PS = 'Professional Services-MDM Config'; //Added as part of EDGE-149887
 
RegisterPluginAdapter.execute(PSMDM_COMPONENT_NAMES.solution, 'PSMDM_Plugin');
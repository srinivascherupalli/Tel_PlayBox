/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[VeloCloud_Main] loaded');

var communitySiteIdVelo;
var VELOCLOUD_COMPONENTS = {
	VeloCloudSol: 'VeloCloud Tenancy', 
	VeloCloudTenancy: 'VeloCloud Tenancy',		//DN: NO LONGER IN USE?
};
var executeSaveVeloCloud = false;
var saveVeloCloud = false;
var DEFAULTSOLUTIONNAME_VELO = 'VeloCloud Tenancy';  
var DEFAULTOFFERNAME_VELO = 'VeloCloud Tenancy'; 
var saveVeloTenancy = false; 

RegisterPluginAdapter.execute(VELOCLOUD_COMPONENTS.VeloCloudSol, 'VeloCloud_Plugin');
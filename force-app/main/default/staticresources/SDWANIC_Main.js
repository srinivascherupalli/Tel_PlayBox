/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[SDWANIC_Main] loaded');

var SDWANVPN_COMPONENTS = {
    InterConnectSol: 'VCG Interconnect solution',//DIGI-26454
    InterConnect: 'VeloCloud SDWAN-VPN Interconnect',
	opportunityType: 'MACs (Moves, Adds & Change)'
};

var executeSaveSDWANInterCon = false;
var DEFAULTSOLUTIONNAME_SDWANInterCon = 'VeloCloud SDWAN-VPN Interconnect solution';  
var DEFAULTOFFERNAME_SDWANInterCon = 'VeloCloud SDWAN-VPN Interconnect';

RegisterPluginAdapter.execute(SDWANVPN_COMPONENTS.InterConnectSol, 'Interconnect_Plugin');

/*
 * CreatedBy: Don Navarro
 * Created Date: 09/09/2021
 * Centralised code that will handle the registration of plugin for each product
 */
console.log('[CS_PluginAdapter] loaded');

const RegisterPluginAdapter = {};

RegisterPluginAdapter.execute = function(solutionName, pluginName){
	if (!CS || !CS.SM){
		throw Error('Solution Console API not loaded');
	}
	
	if (CS.SM.registerPlugin){
		console.log('[CS_PluginAdapter] CS.SM.registerPlugin start...');
		
		window.document.addEventListener('SolutionConsoleReady', function () {
			CS.SM.registerPlugin(solutionName).then(function(pluginObject){
				console.log('[CS_PluginAdapter] registering plugin for ' + solutionName);
				updatePlugin(pluginObject, pluginName);
			});
		});
		console.log('[CS_PluginAdapter] ...end CS.SM.registerPlugin');
	}
}

function updatePlugin(pluginObject, pluginName){	
	console.log('[CS_PluginAdapter] updatePlugin for ' + pluginName + ' start...');
	
	switch(pluginName){
		case 'FPV_Plugin':
			FPV_Plugin.execute(pluginObject);
			break;
		case 'AM_Plugin':
			AM_Plugin.execute(pluginObject);
			break;
		case 'DOP_Plugin':
			DOP_Plugin.execute(pluginObject);
			break;
		case 'EMS_Plugin':
			EMS_Plugin.execute(pluginObject);
			break;
		case 'EMP_Plugin':
			EMP_Plugin.execute(pluginObject);
			break;
		case 'TMDM_Plugin':
			TMDM_Plugin.execute(pluginObject);
			break;
		case 'UCT_Plugin':
			UCT_Plugin.execute(pluginObject);
			break;
		case 'AN_Plugin':
			AN_Plugin.execute(pluginObject);
			break;
		case 'CurrProdCat_Plugin':
			CurrProdCat_Plugin.execute(pluginObject);
			break;
		case 'NGMAC_Plugin':
			NGMAC_Plugin.execute(pluginObject);
			break;
		case 'PSMDM_Plugin':
			PSMDM_Plugin.execute(pluginObject);
			break;
		case 'SecureEdge_Plugin':
			SES_Plugin.execute(pluginObject);
			break;
		case 'VeloCloud_Plugin':
			VeloCloud_Plugin.execute(pluginObject);
			break;
		case 'IOT_Plugin':
			IOT_Plugin.execute(pluginObject);
			break;
		case 'IOTAccount_Plugin':
			IOTACCT_Plugin.execute(pluginObject);
			break;
		case 'IOTConnectivity_Plugin':
			IOTCONN_Plugin.execute(pluginObject);
			break;
		case 'UCE_Plugin':
			UCE_Plugin.execute(pluginObject);
			break;
		case 'Tenancy_Plugin':
			DMS_Plugin.execute(pluginObject);
			break;
		case 'SDWAN_Plugin':
			SDWAN_Plugin.execute(pluginObject);
			break;
		case 'EndpointLifecycle_Plugin':
			EndpointLifecycle_Plugin.execute(pluginObject);
			break;
		case 'Interconnect_Plugin':
			Interconnect_Plugin.execute(pluginObject);
			break;
	}
	console.log('[CS_PluginAdapter] ...end updatePlugin for ' + pluginName);
}
/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[SecureEdge_Main] loaded');

var SecureEdge_COMPONENTS = {
	SecureEdgeSol: 'SecureEdge',
    SecureEdgeCloud : 'SecureEdge Cloud',					//DN: NO LONGER IN USE?
    SecureEdgeTenancy :'SecureEdge Cloud Tenancy',			//DN: NO LONGER IN USE?
	SecureEdgeCloudRemote : 'SecureEdge Cloud Remote',
    ExternalIP : 'External IP Address', // DIGI-10035
    opportunityType: 'MACs (Moves, Adds & Change)', //DIGI-10035
    relatedProduct : 'External IP Address',
    MACDSolutionNonEditableFields: ['BillingAccountLookup', 'Contract Term'], //DIGI-10035 
    MACDCancelSolutionFields: ['CancellationReason', 'DisconnectionDate'], //DIGI-10035
    SecureEdgeCloudRemoteMACDSolutionNonEditableFields : ['RemoteWorkerQuantity']
};
var executeSaveSecureEdge = false;							//DN: NO LONGER IN USE?
var saveSecureEdge = false;									//DN: NO LONGER IN USE?
var DEFAULTSOLUTIONNAME_SecureEdge = 'SecureEdge';  
var DEFAULTOFFERNAME_SecureEdge = 'SecureEdge Security';	//DN: TO BE REPURPOSED WHEN REGISTERING PLUGIN
var saveSecureEdgeCloud = false; 							//DN: NO LONGER IN USE?

RegisterPluginAdapter.execute(DEFAULTOFFERNAME_SecureEdge, 'SecureEdge_Plugin');
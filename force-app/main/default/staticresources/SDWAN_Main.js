/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[SDWAN_Main] loaded');

var SDWAN_COMPONENTS = {
	solution: 'SD-WAN Adapt S1 Solution',
	SDWAN_ADAPT_S1: 'SD-WAN Adapt S1',
	childComponent: 'SD-WAN Adapt S1',
	planeNames: ['SD-WAN Adapt S1 – Extra Small', 'SD-WAN Adapt S1 – Small', 'SD-WAN Adapt S1 – Medium'], //DPG-3514//DPG-4692
	lteModeSmallMedium: [CommonUtills.createOptionItem("Active"), CommonUtills.createOptionItem("Hot Standby"), CommonUtills.createOptionItem("Backup")], // DPG-3514 //DPG-5565
	lteModeLargeExtraLarge: [CommonUtills.createOptionItem("NA")],
	relatedProduct: 'Enterprise Wireless', //DPG-3514
	lteModeconditionalXSM: ['Hot Standby', 'Backup'], //DPG-4692 //DPG-5565
	lteModeAttributeName: 'LTE Mode',
	opportunityType: 'MACs (Moves, Adds & Change)', //DPG-5387/DPG-5649
	MACDSolutionEditableFields: ['CancellationReason', 'DisconnectionDate'], //DIGI-926
	MACDSolutionNonEditableFields: ['Site', 'BillingAccountLookup'], //DIGI-926
	MACDSolutionChildNonEditableFields: ['Plan Name', 'Contract Term', 'LTE Mode'] //DIGI-926
};
var executeSaveSDWAN = false;
var allowSaveSDWAN = false;
var currentSDWANSolution;
var DEFAULTSOLUTIONNAME_SDWAN = 'SD-WAN Adapt S1 Solution';
let modbasketChangeType;
var tenguId;	//DN: Added
var tenId;		//DN: Added
var secgu_ID;	//DN: Added

//Register Plugin
var currentSolution;

RegisterPluginAdapter.execute(DEFAULTSOLUTIONNAME_SDWAN, 'SDWAN_Plugin');
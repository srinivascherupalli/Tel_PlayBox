/*******************************************************************************************************************************************
Sr.No.		Author 			Date	Sprint   	Story number		Description
1.		Aman Soni	3-June-2020	20.08(New JS)	EDGE-148729		Next Generation Mobility Controller JS
2.		Laxmi Rahate	5-June-2020	20.09		EDGE-150795		Enabling Order Enrichment
3.          	Shubhi		8-June-2020	20.08		EDGE-148662		Enabling one fund and POS
4.		Ankit		26-june-2020	20.09		EDGE-148733		Enabling Device Id on MACD
5.      	Shubhi		26-Jun-2020	20.09		Edge-149830 		Redemption on device and devicecare
6.     		Aman Soni	23-June-2020	20.09		EDGE-148667		Invoked inValidateDeviceCareConfigOnEligibility,UpdateChildFromParentAtt
7		Laxmi Rahate	30-Jun-2020	20.09		EDGE-154021 		Handling OE for MAC and Cancel
8.		Laxmi Rahate	16-Jul-2020	20.10		EDGE-154663		Method call to save OE details on PC
9.          	Arinjay         20-Jul-20202    20.10           EDGE-164211    		Spring 20 Upgrade
10.         	Aman Soni	20-July-2020	20.10	        EDGE-154026 	    	Added Code for Next Gen Plan
11.		Laxmi Rahate	22-July-2020    20.10		EDGE-154663		Added method call to set value for INT ROAM on PC
12.         	Gnana           22-July-2020    20.10           EDGE-155181        	Extened EDGE-154663 code to support OE for Next Gen EM Plan
13		Laxmi Rahate 	30-July-2020    20.10		EDGE-154680		MAC for Mobility Features
14. 		Gnana		31-July-2020	20.10		EDGE-155182		Modifed to support MAC for Next Gen EM Plan OE
15     		Colombo         25-Aug-2020     20.11     				post upgrade js upliftment
16      	Shubhi/samish   28-july-2020    20.12           EDGE-165013
17.     	Shubhi/Hitesh   28.July.2020    20.12           EDGE-157919,EDGE-157747,EDGE-157745
18.     	Shubhi          28.July.2020    20.12           EDGE-157797		(Ir Month Pass)
19.     	Gnana           31-Aug-2020     20.12           EDGE-154688 		(NGEM Plan Cancel)
20.    		Aman Soni     	31-Aug-2020    	20.12       	EDGE-157745 		DefaultMsgBank,DefaultBDD
20.    		Aman Soni     	31-Aug-2020    	20.12       	EDGE-160039 		RoundingOffAttribute
21.         	shubhi          05-09-2020      20.12           EDGE-160037             addonmac 
22.          	Aarathi/Manish  04-09-2020      20.12           EDGE-164351         	Apple Care Cancellation
23.          	Gunjan Aswani  	23-09-2020      20.12           JS Refactoring
24.		Laxmi Rahate	17-09-2020	20.13					Vimal's Suggestions
25.		Hitesh		17-Sept-2020	20.13		EDGE-174694 		to add IR month pass as related product and remove it as attribute	
26.	   	Laxmi /Dheeraj  21-Sep-2020	20.13
27.		Aman Soni	  24/09/2020	20.13		 EDGE-164619 	Added by Aman Soni	
28.     Aditya		  07.10.2020    20.14		EDGE-170011 Removal of "Use Existing SIM" check box
29 		Laxmi		  14-10-2020	20.14		EDGE-174219 - OE  Framework Changes
30.     Shubhi		20-10-2020      20.14       EDGE-179365
31.     Vijay 		  17/10/2020				EDGE-169456 Removal of Pricing attributes from the UI
32.     Shweta K          4/11/2020                 EDGE-18565
33. 	Pooja Bhat	 	05/08/2020		20.15		EDGE-175750
34.      Laxmi Rahate		25-Nov-2020		20.15            Removed Refctored code and added loop for updatign configuration
35.		Arinjay Singh		28-Nov-2020		20.15		EDGE 191833		Config Error messages
36.     Payal Popat         18/12/2020      20.17       EDGE-178219 - Updated to hide DisconnectionDate 
37.     Krunal/Ila          11-Dec-2020     20.16       DPG-3358        Mobile Accessory changes
38.     Shubhi V			4/01/2020		20.17		INC000094689212
39.     Krunal Taak        13/01/2021       20.16       updateConfigName_AccessoryAllConfig and updateConfigName_AccessoryperConfig
40.     Kamlesh            18/01/2021       21.01       EDGE-191955 - Added validation to remind user to click on validate and save once OE is done
41.     Aditya             27/01/2021	    21.01	Edge-170422
42.     Krunal Taak        29/01/2021       21.01    DPG-4184 - OE changes for Accessory & NGMAHideShowOnContractTermL34 to 39 changes
43.     Krunal Taak        08/02/2021       21.01    DPG-4270 - Removed Quantity Field for Hide/Show (mobile accessory)
44.		Akanksha Jain	   08/02/2021		20.16	 EDGE-170544 Added change type Inflight Amend in afterAttributeUpdated
45. 	Mahima			   05/02/2021		21.02		DPG-4154, 4071
46.     Shubhi			   12/02/2021		21.02	 EDGE-203210
47.     Krunal Taak        17/02/2021       21.03       Calling Helper method 'CalculationforDeviceCompAtts' for MobileAccessory
48.		Aman Soni		   17/02/2021		21.03		EDGE-203220
49.		Hitesh Gandhi	   22/02/2021		21.03	EDGE-191075 added changes for setting SiteDeliveryAddressName and SiteDeliveryContactName
50.		Radhika Uppal 	   23/02/2021		21.03 	 EDGE-199772
51.     Hitesh Gandhi	   01/03/2021		21.03	EDGE-200723,EDGE-208312 added fix for Add \ Delete of Delivery Details on attribute update of SimAvailabilityType
52.		Aman Soni		   10/03/2021		21.04		EDGE-208907  Bug Fix 
53.     Aditya			   22/03/2021		21.04	EDGE-207583
54.		Aman Soni		   07/04/2021		21.05		EDGE-213112  Bug Fix 
55.		Aman Soni		   12/04/2021		21.05		EDGE-207355  validate BAN on configurations in case of Migration Journey
56.     Pawan Singh        16/04/2021                   EDGE-213750  Defect fix , updated getAttributeValue mehtod.
57.     Vamsi Krishna V    21APR2021        21.06       EDGE-207354
58. 	Mahima G		   14/06/2021		21.08		DPG-5776
59.     Antun Bartonicek   07/06/2021		21.06		EDGE-198536 performance improvements
60. 	Mahima G		   14/06/2021		21.08		APN Cancel
61.     Krunal Taak		   09/06/2021       21.08       DPG-5621
62.     Monali Mukherjee   09/06/2021       21.08       DPG-5626
63.		Aman Soni		   24/06/2021	    21.09		Remove ChangeType on Main component of Adaptive Mobility solution for EDGE-224779
64. 	Aman Soni		   13/07/2021		21.09		Added for DPG-6175
65. 	Mahima G		   07/07/2021		21.08		TON Disconnect
66. 	Mahima G		   21/07/2021		21.10		DPG-6155- APN Modify in MAC
67.		shubhi V		   21/09/2021       21.13		DIGI-16898 - mac discounts
68.     Krunal Taak        13/10/2021       21.15       DIGI-26615 - Handling Promotions Special Scenario
69. 	Vasu			   26/10/2021		21.14		DIGI-456 Bypass standard order enrichment
70. 	Mahima 			   11/3/2021	    21.15		Passed newValue as parameter in SoftdeleteBoltonMethod- DIGI-37564 - Mahima
63. 	Vasu			   26/10/2021		21.14		DIGI-456 Bypass standard order enrichment
64.	   Vijay			   07/11/2021		21.15		DIGI-456 Commented toggle remote action and add window.isToggled condition
********************************************************************************************************************************************/
/*Please try to add comments at the start of each block. Do not add in the middle of code or block*/
console.log('::::::: Next Generation Mobility controller resource ::::::');
var mainCompName;
var compName;
var basketType = '';
var NGDListOfLists = [];

//Added NGDHideShowOnChangeSolutionDeviceL12,NGDHideShowOnChangeSolutionDeviceL13 as part of EDGE-148733 by Ankit || Added nextGenPlan by Aman Soni for EDGE-154026 || Added NGEMPlanHideShowAttsInMACL18, NGEMPlanHideShowAttsInMACL19 by Aman Soni for EDGE-154238
var NXTGENCON_COMPONENT_NAMES = {
	nxtGenMainSol: 'Adaptive Mobility', //EDGE-165013 added by shubhi 
	nextGenDevice: 'Device',
	nextGenAccessory: 'Accessory',
	mobDeviceCare: 'Mobile Device Care',
	nextGenPlan: 'Enterprise Mobility',
	dataFeatures: 'Data Features',
	internationalDirectDial: 'Calling & Messaging Features',
	messageBank: 'Voicemail Features',
	transitionDevice: "Transition Device",
    transitionAccessory: "Transition Accessory",
    dataCustomConfig: "Enterprise Mobility Data-Custom",//DPG- 5298 fix
    dataCustom: "Data Custom",//DPG- 5298 fix
	nextGenAccelerator:'Accelerator', //DPG-4795: Ila
	telstraOneNumber:"Telstra One Number", // DPG-5728 Mahima
	internationalRoamingMonthPass: 'International Roaming Month Pass',// hitesh added
	NGDEmptyAttOnDevType: ['MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'ManufacturerString', 'ModelString', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnManfacture: ['MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'ModelString', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnModel: ['MobileHandsetColour', 'PaymentTypeLookup', 'ContractTerm', 'MobileHandsetColour', 'PaymentTypeString', 'ContractTermString', 'InContractDeviceEnrollEligibility', 'DeviceEnrollment'],
	NGDEmptyAttOnColor: ['ContractTerm', 'PaymentTypeString', 'ContractTermString'],
	MDCEmptyAttOnPlan: ['DeviceCarePaymentTypeLookup'],
	NGEMPlanEmptyAttOnPlanType: ['Select Plan'],
	NGDEmptyAttOnPayType: ['ContractTerm', 'ContractTermString'],
	NGEMEmptyAttIRonPlan: ['IR_MonthPass', 'IR_MonthPassRC', 'IR_MonthPassRC Inc GST'],
	NGDRoundOffAttribute: ['OC', 'RC', 'OneOffChargeGST', 'InstalmentChargeIncGST'],
	NGDHideShowOnPayTypeHRepL0: ['TotalFundAvailable', 'RedeemFund', 'RedeemFundIncGST'],// Removed 'OneOffChargeGST', 'OC', as part of Pricing Service enablement EDGE-169456 //EDGE-175750: Added RedeemFundIncGST
	NGDHideShowOnPayTypePurcL1: [],//Removed 'RC', 'InstalmentChargeIncGST' as part of Pricing Service enablement  EDGE-169456
	NGDHideSpaceAttributesS2L2: [],//Removed 'Space2' as part of Pricing Service enablement EDGE-169456
	NGDHideSpaceAttributesS35467L3: [],//Removed 'Space3', 'Space5', 'Space4', 'Space6', 'Space7' as part of Pricing Service enablement EDGE-169456
	NGDHideSpaceAttributesS2345L4: [],//Removed 'Space2', 'Space3', 'Space4', 'Space5', 'Space6', 'Space7' as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnContractTermL5: ['ContractTerm'],//Removed 'OneOffChargeGST', 'OC', 'TotalFundAvailable', 'RedeemFund', 'RC', 'InstalmentChargeIncGST',  as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnDeviceEnrollmentL6: ['DeviceEnrollment'],//Removed 'OneOffChargeGST', 'OC' as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnTaxTreatmentL7: ['DeviceEnrollment'],
	NGDHideShowOnTaxTreatmentL8: [],
	NGDHideShowOnChangeSolutionMainL9: ['Marketable Offer'],//Removed ChangeType for EDGE-224779 by Aman Soni
	NGDHideShowOnChangeSolutionDeviceL10: ['ChangeType'],//Removed ChangeType for EDGE-224779 by Aman Soni //Added for DPG-6175 by Aman Soni
	NGDHideShowOnChangeSolutionDeviceL11: ['Device Type', 'MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeString'],
	NGDHideShowOnChangeSolutionDeviceL12: ['DeviceID'],//, Removed 'Space9', 'Space10', 'Space11' as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnChangeSolutionDeviceL13: ['DeviceID', 'ContractTerm'],//, Removed 'Space10', 'Space11' as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnChangeSolutionDeviceL14: ['DeviceCarePlanLookup', 'DeviceCarePaymentTypeLookup', 'RedeemFund', 'RedeemFundIncGST'],    //EDGE-175750: Added RedeemFundIncGST
	NGDHideShowOnChangeSolutionDeviceL15: ['DeviceEnrollment'],
	NGDHideShowOnChangeSolutionDeviceL16: [ 'EarlyTerminationCharge', 'TotalFundAvailable'],//Removed 'Space3', 'Space2', 'Space12', as part of Pricing Service enablement EDGE-169456
	NGDHideShowOnChangeSolutionDeviceL17: ['RedeemFund','RedeemFundIncGST','CancellationReason'],   //EDGE-175750: Added RedeemFundIncGST //EDGE-178219 Remove DisconnectionDate
	NGEMPlanHideShowAttsInMACL18: ['SelectPlanType','Space1','Space2','Space3','Space4'],
	NGEMPlanHideShowAttsIRonPlan19: [],//Removed 'IR_MonthPassRC','IR_MonthPassRC Inc GST' as part of Pricing Service enablement, EDGE-169456,  EDGE-157797 EDGE-174694 Hitesh Not in use as part onwards, 
	EmptyIddAttListonPlanChange: ['InternationalDirectDial', 'IDD ChargeLookup'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyMBAttListonPlanChange: ['MessageBank'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyDFAttListonPlanChange: ['UnshapeUserChargeLookup'],//EDGE-157919,EDGE-157747,EDGE-157745
	EmptyIRAttListonPlanChange: ['IR_MonthPassAssoc', 'IR_MonthPass', 'IR_MonthPassAllowance'], // EDGE- 174694 Hitesh added
	EmptyDFAttListonPlanTypeChangeWireless: ['UnshapeUserRC', 'UnshapeUserRC_Inc_GST', 'UnshapeUserChargeLookup'],
	EmptyDFAttListonPlanTypeChangeHDBB: ['AutoDataTopup', 'ADTChargeNRC', 'ADT Charge GST', 'ADTChargeLookup'],
	EmptyDataFeatUnshapeRCS: ['UnshapeUserRC', 'UnshapeUserRC_Inc_GST'],//Added by Aman Soni for EDGE-166327
	NGEMPlanHideShowAttsCancel20: ['ChangeType', 'DisconnectionDate', 'CancellationReason'],//EDGE-154688

	NGEMPlanHideShowAttsCancel21: [],//Removed EDGE-154688   'Space3','Space4' as part of Pricing Service enablement EDGE-169456
	NGEMPlanHideShowAttsCancel22: ['SelectPlanType', 'Select Plan','isPortOutReversal'],//EDGE-154688   Removed  'IR_MonthPass','IR_MonthPassRC Inc GST' as part of Pricing Service enablement EDGE-169456
	NGEMPlanHideShowAttsCancel23: ['DisconnectionDate', 'CancellationReason'],//EDGE-154688
	NGEMPlanHideShowAttsCancel24: ['IR_MonthPassAssoc'],//Added by Aman Soni for EDGE-157797
	NGEMPlanHideShowAttsCancel25: ['Select Plan'],
	NGEMPlanHideShowAttsCancel26: ['AutoDataTopup'],//Removed 'ADTChargeNRC','ADT Charge GST' as part of Pricing Service enablement EDGE-169456
	NGEMPlanHideShowAttsCancel27: ['UnshapeUser'],
	NGEMPlanHideShowAttsCancel28: [],//Removed 'Space2' as part of Pricing Service enablement EDGE-169456
	NGEMPlanHideShowAttsCancel29: ["BillingAccountLookup"], //Added for EDGE-207352
	NGEMPlanHideShowAtts30: ['RedeemFund'],//Removed 'Space7','Space8','Space9' as part of Pricing Service enablement EDGE-169456
	NGEMTransDeviceHideShowAtts31: ['ContractTerm'],
	NGEMTransDeviceHideShowAtts32: ['EarlyTerminationCharge'],
	NGEMTransDeviceHideShowAtts33: ['OC', 'RC'],
	NGMAHideShowOnContractTermL34: ['TotalFundAvailable','RedeemFund'], //Purhcase Show Mobile Accessory DPG-3358 //Removed 'OC','OneOffChargeGST'//'Quantity', - DPG-4270
	NGMAHideShowOnContractTermL35: [], //Purhcase Hide Mobile Accessory DPG-3358 //Removed 'RC'
	NGMAHideShowOnContractTermL36: [], //HRO Show Mobile Accessory DPG-3358 //Removed 'RC' //'Quantity' - DPG-4270
	NGMAHideShowOnContractTermL37: ['TotalFundAvailable','RedeemFund'], //HRO Hide Mobile Accessory DPG-3358 //Removed 'OC','OneOffChargeGST'
	NGMAHideShowOnContractTermL38: ['ContractTerm'], // Show / Hide Mobile Accessory make mandatory DPG-3358
	NGMAHideShowOnContractTermL39: ['ContractTerm','Quantity','TotalFundAvailable','RedeemFund'], //Hide all when Paymenttypeshadow is blank // Removed 'RC','OC','OneOffChargeGST'
	//Edge-170422 start --------
	InflightPlanHideShow40:['InternationalDirectDial'],
	InflightPlanHideShow41:['UnshapeUser','BusinessDemandData'],
	InflightCMHideShow42:['MessageBankAddonAssoc'],
	InflightVMHideShow:[],
	InflightDFHideShow:[],
	InflightIRHideShow:[],
	InflightDeviceHideShow1:[],
	InflightDeviceHideShow2:[],
	InflightTransitionDeviceHideShow:[],
	InflightDevicecareHideShow:[],
	//Edge-170422 end -----
	////Edge-195101 start --------
	InflightAccessoryHideShow43:['AccessoriesType','AccessoryModel','PaymentTypeLookup','Quantity','TotalFundAvailable','RedeemFund','ContractTerm'],
	//Edge-195101 end -----
	// EDGE-197578 start
	NGDHideShowOnChangeTypeNoFaultL44: ['CancellationReason','ChargeReversal'],
	NGDHideShowOnChangeTypeNoFaultL45: ['Device Type', 'MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeString','ContractTerm','FundReversal'],
	NGDHideShowOnChangeTypeNoFaultL46: ['EarlyTerminationCharge', 'TotalFundAvailable','RedeemFund','RedeemFundIncGST','DeviceEnrollment'],
	NGDHideShowOnChangeTypeNoFaultL47: ['CancellationReason','ChargeReversal','FundReversal'],
	NGDHideShowOnChangeTypeNoFaultL48: ['Device Type','MobileHandsetManufacturer', 'MobileHandsetModel', 'MobileHandsetColour', 'PaymentTypeString','FundReversal','ChargeReversal'],
	NGDHideShowOnChangeTypeNoFaultL49: ['ChargeReversal','FundReversal'],
	NGDHideShowOnChangeTypeNoFaultL50: ['PRE Discounts','EarlyTerminationCharge'],									
	// EDGE-197578 End
	//Added by Mahima DPG-5776-start
	NGEMPlanHideShowAttsAccPlan50: ['Accelerator'],
    //Added by Mahima DPG-5776-end
	NGEMPlanHideShowAttsAccCancel51: ['RedeemFund','CancellationReason','DisconnectionDate'], //Krunal DPG-5621
	NGEMPlanHideShowAttsAccCancel52: ['AccessoriesType','AccessoryModel','PaymentTypeLookup','ContractTerm','EarlyTerminationCharge', 'EarlyTerminationChargeIncGST'], //Krunal DPG-5621
	NGEMPlanHideShowAttsAccPaidout53: ['AccessoriesType','AccessoryModel','PaymentTypeLookup'], //Krunal DPG-5621
    //Added by Mahima APN Cancel-start
	NGEMPlanHideShowAttsApnPlan54: ['DC_addonAssoc','APN Type','PreferredChk'],
    //Added by Mahima APN Cancel-end
		// Added by Mahima- Ton -Cancel- DPG-5728-Start
		NGEMPlanHideShowAttsTONPlan55: ['TON Product Option']
		// Added by Mahima- Ton -Cancel- DPG-5728-end
};

//Added NGDHideShowOnChangeSolutionDeviceL12,NGDHideShowOnChangeSolutionDeviceL13 as part of EDGE-148733 by Ankit
NGDListOfLists = [NXTGENCON_COMPONENT_NAMES.NGDHideShowOnPayTypeHRepL0,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnPayTypePurcL1, NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS2L2,
NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS35467L3, NXTGENCON_COMPONENT_NAMES.NGDHideSpaceAttributesS2345L4,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnContractTermL5, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnDeviceEnrollmentL6,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnTaxTreatmentL7, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnTaxTreatmentL8,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionMainL9, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL10,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL11, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL12,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL13, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL14,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL15, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL16,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionDeviceL17, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsInMACL18,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsIRonPlan19, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel20,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel21, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel22,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel23, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel24, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel25,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel26, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel27,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel28, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsCancel29, NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAtts30,
NXTGENCON_COMPONENT_NAMES.NGEMTransDeviceHideShowAtts31, NXTGENCON_COMPONENT_NAMES.NGEMTransDeviceHideShowAtts32, NXTGENCON_COMPONENT_NAMES.NGEMTransDeviceHideShowAtts33,NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL34,NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL35,NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL36,

NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL37,NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL38,NXTGENCON_COMPONENT_NAMES.NGMAHideShowOnContractTermL39,
NXTGENCON_COMPONENT_NAMES.InflightPlanHideShow40,NXTGENCON_COMPONENT_NAMES.InflightPlanHideShow41,NXTGENCON_COMPONENT_NAMES.InflightCMHideShow42,
////Edge-195101 start --------
NXTGENCON_COMPONENT_NAMES.InflightAccessoryHideShow43,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL44,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL45,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL46,
NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL47,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL48,NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL49,

NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsAccPlan50,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsAccCancel51,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsAccCancel52,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsAccPaidout53,NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsApnPlan54,
NXTGENCON_COMPONENT_NAMES.NGEMPlanHideShowAttsTONPlan55]

////Edge-195101 ends --------]; // NGEMPlanHideShowAttsIRonPlan19 : EDGE-157797, NGEMPlanHideShowAttsCancel20 : EDGE-154688
//34 - 39 DPG-3358  //Edge-170422 added new lists // // EDGE-197578 list from 44 to 50!


var NextGenMobController = {

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterSolutionLoaded
	* Invoked When: when solution is loaded or when invoked after a Solution is set as Active
	* Parameters  : previousSolution, loadedSolution
	***********************************************************************************/
	// Arinjay JSUpgrade 
	AfterSolutionLoaded: async function (previousSolution, loadedSolution) {
		await Utils.loadSMOptions();
		if (loadedSolution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol)) {
			await Utils.updateCustomButtonVisibilityForBasketStage();
			// DPG-456 added by vasu start  // Commented by  vijay || start
			/*let inputmap = {};
			inputMap['OrderEnrichment'] = 'oeAM';
			let isOrderToggled = false;
			var activeSolution =await CS.SM.getActiveBasket();
			await activeSolution.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				isOrderToggled = values['oeAM'];
			});*/
			// DPG-456 added by vasu end // Commented by  vijay || start
			if(!window.isToggled){ // Added by  vijay 
				await Utils.addDefaultGenericOEConfigs(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);// EDGE-150795	
            }else{
                 CommonUtills.oeErrorOrderEnrichment();// Added by  vijay 
            }			
			await NextGenMobHelper.HideShowAttLst_MainSolution(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeSolutionMainL9);

			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
				//Added by Aman Soni as a part of EDGE-148729 || Start
				await NextGenMobHelper.updateConfigName_DeviceAllConfig(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
				await NextGenMobHelper.updateConfigName_AccessoryAllConfig(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //added by Krunal Taak
				//await NextGenMobHelper.HideShowAttributeLstOnSaveNOnLoad(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice, NGDListOfLists);
				//NextGenMobHelper.NGDDeviceEnrolmentOnLoadNSave(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
				NextGenMobHelper.UpdateChildFromParentAtt(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice, NXTGENCON_COMPONENT_NAMES.mobDeviceCare);//Invoked UpdateChildFromParentAtt as a part of EDGE-148667 by Aman
				
				//Added for EDGE-207355 by Aman Soni || Start
				if(window.OpportunityType === "Migration"){
					await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
					await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
				}
				//Added for EDGE-207355 by Aman Soni || End
			}
			if (window.BasketChange === 'Change Solution' && window.basketStage !== 'Contract Accepted') {
				await CommonUtills.updateSolutionNameOnOLoad(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol);//For EDGE-207354 on 21APR2021 by Vamsi
				await NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
                await NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //For DPG-5626 by Monali
                await NextGenMobHelper.updateDeviceIdOnConfig(NXTGENCON_COMPONENT_NAMES.transitionAccessory); //For DPG-5626 by Monali
               // await NextGenMobHelper.updatePurchaseOrderNoOnConfig(NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //For DPG-5626 by Mo
			   //digi-27111
				//await CommonUtills.getmainSolutionSubNumber(); // added by shubhi for EDGE-185011 // Commented as per suggesstion 
				//await NextGenMobHelper.UpdateRelatedConfigForChild();
				NextGenMobHelper.updateDeviceIdOnConfig(compName);
				//EDGE-150795
				//Added by Aman Soni as a part of EDGE-148729 || End
				await NextGenMobHelper.UpdateRelatedConfigForChild();
				await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice, 'AfterSolutionLoaded', null);
				await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenPlan, 'AfterSolutionLoaded', null);
				await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.transitionDevice, 'AfterSolutionLoaded', null);

				await NextGenMobHelper.updateISPOSReversalRequired();//EDGE-164351
				await NextGenMobHelper.handleReloadinMacd(NGDListOfLists);
				await NextGenMobHelper.handleReloadinMacdTransDevice(NGDListOfLists);
                //---DPG-5621 Krunal
                await NextGenMobHelper.handleReloadinMacdAccessory(NGDListOfLists);
				await NextGenMobHelper.handleReloadinMacdTransAccessory(NGDListOfLists);
                //---DPG-5621 Krunal
			}
			//Added by Aman Soni as a part of EDGE-148729 || End
			if(window.basketRecordType==='Inflight Change'){ //&& window.amendType !== 'Non-Commercial'){
				await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenDevice,'ReplaceConfig');
				await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenPlan,'ReplacedConfig');
				////Edge-195101 start --------
				await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenAccessory,'ReplaceConfig');
				////Edge-195101 ends --------
				await InflightBasketUtils.handleReloadVisibilityinInflight();

			}
			//Added by Aman Soni for EDGE-208907 || EDGE-213112 || Start
			if(window.basketRecordType != 'Inflight Change' && window.BasketChange != 'Change Solution' && (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft')){
				await NextGenMobHelper.DeviceAndPlanCount();
			}
			//Added by Aman Soni for EDGE-208907 || EDGE-213112 || End

			if (window.basketStage === "Contract Accepted") {
				await NextGenMobHelper.setNextGenEMTabsVisibility(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenDevice, true);
                await NextGenMobHelper.setNextGenEMTabsVisibility(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenAccessory, true); //DPG-5621 Krunal
				await NextGenMobHelper.DeleteDeliveryDetails_MAC(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol, NXTGENCON_COMPONENT_NAMES.nextGenPlan);// Hitesh GAndhi EDGE-200723
			}
		}
		return Promise.resolve(true);
	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterAttributeUpdated
	* Invoked When: invoked after an Attribute is updated
	* Parameters  : componentName, guid, attribute, oldValue, newValue
	***********************************************************************************/
	// Arinjay JSUpgrade
	AfterAttributeUpdated: async function (componentName, configuration, guid, attribute, oldValue, newValue) {
		try {
			let DeviceConfigId = '';
			let relatedGuid = '';
			let OldVal = oldValue;
			let newVal = newValue;
			let keys;
			let varConfig = '';
			let solution = await CS.SM.getActiveSolution();
			let mainCompName = NXTGENCON_COMPONENT_NAMES.nxtGenMainSol
			if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
				//Added by Aman Soni for EDGE-154028 || Start
				if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan) {
					let component = await solution.getComponentByName(componentName);

					//Added by Aman Soni for Soft Delete functionality for IR Month Pass || Start
					//let config = await component.getConfiguration(guid);
					let irComp = await component.getComponentByName(NXTGENCON_COMPONENT_NAMES.internationalRoamingMonthPass);
					let irConfig = await irComp.getConfiguration(guid);
					let irChangeType;
					if (irConfig) {
						irChangeType = irConfig.getAttribute("ChangeType");
						if (irChangeType && newValue === 'Cancel') {
							let deletedConfiguration = irComp.softDeleteMACConfiguration(irConfig);
							console.log('deletedConfiguration', deletedConfiguration);
						}
					}
					//Added by Aman Soni for Soft Delete functionality for IR Month Pass || End					
					
                    //Added by Mahima Gandhe for Soft Delete functionality for Accelerator || Start -DPG-5636
					//let config = await component.getConfiguration(guid);
					console.log('SoftDelete For Accelerator');
					let accComp = await component.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenAccelerator);
					if(accComp){
						let accConfig = await accComp.getConfiguration(guid);
						let accChangeType;
						if (accConfig) {
							accChangeType = accConfig.getAttribute("ChangeType");
							let accCarryForwardDiscount = accConfig.getAttribute("CarryForwardDiscount"); //DIGI-26615
							let planattributename = 'ignoreDiscountIDForChild'; //DIGI-26615
							if (accChangeType && newValue === 'Cancel') {
								await NextGenMobHelper.updateParentAttributefromChild(componentName,planattributename,'Accelerator',accCarryForwardDiscount.value,accConfig.parentConfiguration);//DIGI-26615
								let deletedConfiguration = accComp.softDeleteMACConfiguration(accConfig);
								console.log('deletedConfiguration', deletedConfiguration);
							}
						}}
					//Added by Mahima Gandhe for Soft Delete functionality for Accelerator || End -DPG-5636

					////Added by Mahima Gandhe for Soft Delete functionality for APN || Start
					console.log('SoftDelete For APN');
					let apnComp = await component.getComponentByName(NXTGENCON_COMPONENT_NAMES.dataCustom);
					if(apnComp){
						let apnConfig = await apnComp.getConfiguration(guid);
						let apnChangeType;
						if (apnConfig) {
							apnChangeType = apnConfig.getAttribute("ChangeType");
							if (apnChangeType && newValue === 'Cancel') {
								let deletedConfiguration = apnComp.softDeleteMACConfiguration(apnConfig);
								console.log('deletedConfigurationAPN', deletedConfiguration);
							}
												//DPG-6155- APN Modify in MAC- Mahima-start
												else if (apnChangeType && newValue==='Modify'){
													NextGenMobHelper.HideShowAttributeLst(false, true, apnConfig.parentConfiguration, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataCustom, NGDListOfLists[10], false, true, false);
													NextGenMobHelper.HideShowAttributeLst(false, true, apnConfig.parentConfiguration, mainCompName,NXTGENCON_COMPONENT_NAMES.nextGenPlan,NXTGENCON_COMPONENT_NAMES.dataCustom, NGDListOfLists[54], false, true, false);										
												}
												//DPG-6155- APN Modify in MAC- Mahima-end
											}}
						//Added by Mahima Gandhe for Soft Delete functionality for APN || End
							//Added by Mahima Gandhe DPG-5728 for Soft Delete functionality for TON || Start
							await NextGenMobHelper.SoftDeletePlanBoltOn(component,guid,NXTGENCON_COMPONENT_NAMES.telstraOneNumber,newValue);					
	
						//Added by Mahima Gandhe DPG-5728 for Soft Delete functionality for TON || End

						switch (attribute.name) {
						//Added for EDGE-164619 by Aman Soni || Start
						case 'isPortOutReversal':
							await NextGenMobHelper.NGEM_handlePortOutReversalOnAttUpd(guid);
							break;
						//Added for EDGE-164619 by Aman Soni || End
						case 'SelectPlanType':
							await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGEMPlanEmptyAttOnPlanType);
							if (attribute.displayValue === NGEMPLans.Enterprise_Wireless) {
								await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGEMEmptyAttIRonPlan);
								await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeWireless, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
							}
							await NextGenMobHelper.HideShowAttLst_NGEMPlan(guid, mainCompName, componentName, NGDListOfLists);// added  for EDGE-157797 by shubhi

							//Added by Shubhi for EDGE-166327 || Start
							if (attribute.displayValue && attribute.displayValue != '' && attribute.displayValue !== NGEMPLans.Handheld) {
								await NextGenMobHelper.autoDeleterelatedProductonPlanChange(attribute.displayValue, guid, component);
							}
							//Added by Shubhi for EDGE-166327 || End
							if (attribute.displayValue && attribute.displayValue != '' && attribute.displayValue === NGEMPLans.Mobile_Broadband) {
								await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeHDBB, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
								await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
							}
							//Added by Aman Soni for EDGE-166327 || Start
							if (attribute.displayValue && attribute.displayValue != '' && attribute.displayValue === NGEMPLans.Handheld) {
								CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, NEXTGENMOB_COMPONENT_NAMES.IDD, false, 1);
								CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, NEXTGENMOB_COMPONENT_NAMES.Message_Bank, false, 1);
								CommonUtills.addRelatedProductonConfigurationAdd(component, configuration, component.name, NEXTGENMOB_COMPONENT_NAMES.Data_Features, false, 1);
								await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanTypeChangeHDBB, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
								await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
							}
							await NextGenMobHelper.CalcforNGEMPlanCompAtts(guid, mainCompName, componentName);
							//Added by Aman Soni for EDGE-166327 || End			
							await NextGenMobHelper.Update_UnshapeUser_OnDataFeat(guid);
							break;
						case 'Select Plan':
							let planValue = newValue;
							let config_p = await component.getConfiguration(guid);
							if (config_p.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenPlan)) {
								await NextGenMobHelper.UpdatePlanAllowance(guid, planValue);

								//EDGE-157919,EDGE-157747,EDGE-157745,160037shubhi start------------
								await NextGenMobHelper.updatechildAttfromParent('Select Plan', attribute.value, false, false, guid, componentName);
								if (configuration && !configuration.replacedConfigId) {
									await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyIddAttListonPlanChange, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.IDD);
									await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyMBAttListonPlanChange, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Message_Bank);
									await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyDFAttListonPlanChange, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
									await NextGenMobHelper.emptyChildAttfromParent(NXTGENCON_COMPONENT_NAMES.EmptyIRAttListonPlanChange, guid, componentName, NEXTGENMOB_COMPONENT_NAMES.IRMonthPass);// Hitesh added to blank out IR month pass on plan change
									await NextGenMobHelper.defaultAddonsonPlanChange(planValue, guid, component, configuration);
								} else if (configuration && configuration.replacedConfigId) {
									NextGenMobHelper.autoUpdateAddonAfterPlanChangeinMac(planValue, guid, component, NEXTGENMOB_COMPONENT_NAMES.IDD, 'InternationalDirectDial', 'DMCAT_RecurringCharge_001258');
									NextGenMobHelper.autoUpdatedatafeaturesonPlanChangeinMac(planValue, guid, component, NEXTGENMOB_COMPONENT_NAMES.Data_Features);
									NextGenMobHelper.autoUpdateAddonAfterPlanChangeinMac(planValue, guid, component, NEXTGENMOB_COMPONENT_NAMES.Message_Bank, 'MessageBankAddonAssoc', 'DMCAT_RecurringCharge_001240');
									NextGenMobHelper.autoUpdateAddonAfterPlanChangeinMac(planValue, guid, component, NEXTGENMOB_COMPONENT_NAMES.IRMonthPass, 'IR_MonthPassAssoc', 'DMCAT_RecurringCharge_001279'); // Hitesh added to update attrib on change
								}
								await NextGenMobHelper.CalcforNGEMPlanCompAtts(guid, mainCompName, componentName);
								configuration.validate(); //added by shubhi for EDGE-179365
							}
							//EDGE-157919,EDGE-157747,EDGE-157745,160037 shubhi end---------------	
							break;
						case 'SelectPlanName':
							await NextGenMobHelper.updateConfigNameNGEMPlan(componentName, guid);
							break;
						//EDGE-185652 Commented this
						// case 'PlanTypeString':
						// 	await NextGenMobHelper.updateConfigNameNGEMPlan(componentName, guid);
						// break;


						case 'SelectPlanType':
							await NextGenMobHelper.CalcforNGEMPlanCompAtts(guid, mainCompName, componentName);
							break;

						case 'RC':
							await NextGenMobHelper.CalcforNGEMPlanCompAtts(guid, mainCompName, componentName);
							break;
						case 'ChangeType':
							if (newValue === 'Cancel' || newValue === 'Modify') {
								await NextGenMobHelper.HideShowAttLst_NGEMPlan(guid, mainCompName, componentName, NGDListOfLists);
								await NextGenMobHelper.ChangeOptionValueNGEMPlan(guid);
							}
							break;
						case 'IDD Charge GST':
							await NextGenMobHelper.RoundingOffAttribute(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.internationalDirectDial, 'IDD Charge GST');
							break;
						case 'MessageBank RC (Inc. GST)':
							await NextGenMobHelper.RoundingOffAttribute(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.messageBank, 'MessageBank RC (Inc. GST)');
							break;
						case 'UnshapeUserRC_Inc_GST':
							await NextGenMobHelper.RoundingOffAttribute(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.dataFeatures, 'UnshapeUserRC_Inc_GST');
							break;
						case 'BDD Charge GST':
							await NextGenMobHelper.RoundingOffAttribute(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.dataFeatures, 'BDD Charge GST');
							break;
						case 'ADT Charge GST':
							await NextGenMobHelper.RoundingOffAttribute(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.dataFeatures, 'ADT Charge GST');
							break;
							await NextGenMobHelper.Update_UnshapeUser_OnDataFeat(guid);
						//Added by Aman Soni for EDGE-160039 || End
						//Added by Mahima - 5298- start
                        case 'DataCustomAPN':
                            console.log('inside DataCustomAPN');
                            await NextGenMobHelper.updatePreferredChkBoxAPN(guid);
                            break;
                        //Added by Mahima - 5298- end
                          //added by shubhi for DIGI-16898 start
						  case 'ContainedDiscounts':
                            var enableTED423 = window.FeatureEligibilityMap["enableTED423"];
                            if(enableTED423 && enableTED423.EnableForAll__c==='true' && attribute.value === 'true')
                            	await CommonUtills.updateCarryForwardDiscountonRelatedProduct(componentName,configuration);
                            break;
                        // DIGI-16898 end                             
					}
					
				}
				//Added by Aman Soni for EDGE-154028 || End

				if (componentName === NEXTGENMOB_COMPONENT_NAMES.nextGenDevice) {
					switch (attribute.name) {
						case 'Device Type':
							await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnDevType);
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							break;

						case 'MobileHandsetManufacturer':
							await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnManfacture);
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							break;

						case 'MobileHandsetModel':
							await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnModel);
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							break;

						case 'MobileHandsetColour':
							await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnColor);
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							break;

						case 'DeviceSKU':
							NextGenMobHelper.UpdateChildFromParentAtt(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare);
							break;

						case 'PaymentTypeString':
							NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDEmptyAttOnPayType);
							RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); //Edge-149830
							await NextGenMobHelper.updateConfigName_DeviceperConfig(componentName, guid); // dynamic name shubhi
							if (attribute.value === 'Hardware Repayment') {
								await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
							}
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							await NextGenMobHelper.CalculationforDeviceCompAtts(guid, mainCompName, componentName);
							await NextGenMobHelper.CalcForDeviceCareCompAtts(guid, mainCompName, componentName);
							break;

						case 'ContractTermString':
							await NextGenMobHelper.CalculationforDeviceCompAtts(guid, mainCompName, componentName);
							break;

						case 'DeviceCarePlanLookup':
							await NextGenMobHelper.CalcForDeviceCareCompAtts(guid, mainCompName, componentName);
							break;

						case 'ChangeType':
							if (newValue === 'Cancel') {
								await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
								RedemptionUtilityCommon.updateTotalOneFundBalance(guid,componentName); //Edge-149830
								await CommonUtills.updateDiscountDate(componentName,guid); //EDGE-178219 - Method to update DisconnectionDate as Today's Date
								NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName); //EDGE-178219- Added for ETC calculations
							}
							else if (newValue === 'PaidOut') {
								await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
							}else if(newValue==='Inflight Cancel'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Inflight Cancel', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice); //EDGE-203210
								let component = await solution.getComponentByName(componentName);
								let deletedConfiguration = component.softDeleteMACConfiguration(configuration);
								console.log('deletedConfiguration', deletedConfiguration);
							}else if(newValue==='Rollback Cancel'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Rollback Cancel', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice); //EDGE-193068
							}else if(newValue==='Rollback New'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Rollback New', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice); //EDGE-193068
								let component = await solution.getComponentByName(componentName);
								let deletedConfiguration = component.softDeleteMACConfiguration(configuration);//EDGE-199772
								console.log('deletedConfiguration', deletedConfiguration);
							}else if(newValue==='Inflight Amend'){
								await NextGenMobHelper.updatechisldAttfromParent('ChangeType', 'Inflight Amend', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenDevice); //EDGE-203210
							}
							// EDGE-197578 start
							else if(newValue==='No Fault Return'){
								await NextGenMobHelper.updateFundReversalAtt(guid, mainCompName, componentName);
								await NextGenMobHelper.updateFundReversalAttChild(guid, mainCompName, componentName);
								await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
								await NextGenMobHelper.EmptyAttributeLst(guid, componentName, NXTGENCON_COMPONENT_NAMES.NGDHideShowOnChangeTypeNoFaultL50);
								
							}
							// EDGE-197578 end
							
							break;

						case 'DisconnectionDate':
							NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							break;

						case 'RedeemFund':
							
							await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, newValue); //Edge-149830
							await RedemptionUtilityCommon.calculateBasketRedemption(); //Edge-149830
							if (newValue >= 0) {
								await RedemptionUtilityCommon.validateBasketRedemptions(true, NEXTGENMOB_COMPONENT_NAMES.nextGenDevice, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Edge-149830
							}
							NextGenMobHelper.CalcDeviceRedeemFundGST(guid, newValue, componentName); 	//EDGE-175750: Added
							try{
								await NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							}catch(e){

							}
							break;
						case 'EarlyTerminationCharge':
							NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							break;

						case 'InContractDeviceEnrollEligibility':
							await NextGenMobHelper.NGDDeviceEnrolmentOnAttUpdate(guid, mainCompName, componentName);
							break;

						case 'DeviceCareEligibility':
							if (solution && solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol) && (solution.components && Object.values(solution.components).length > 0)) {
								let compConfig = await solution.getConfigurations();
								let config = solution.getConfiguration(guid);
								DeviceConfigId = config.guid;
								if (config.relatedProductList && config.relatedProductList.length > 0) {
									config.relatedProductList.forEach((relatedConfig) => {
										if (relatedConfig.guid) {
											relatedGuid = relatedConfig.guid;
										}
									});
								}
								await NextGenMobHelper.inValidateDeviceCareConfigOnEligibility(DeviceConfigId, relatedGuid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
								break;

							}
					}
				}
				//---Mobility Accessory
				if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenAccessory){
				console.log("Inside Next Generation Mobility afterAttributeUpdated -- Accessory");
					switch(attribute.name){
						case 'RedeemFund':
							NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							await RedemptionUtilityCommon.updateRedeemCheckNeededFlag(guid, componentName, newValue); //Edge-149830
							debugger;
							await RedemptionUtilityCommon.calculateBasketRedemption(); //Edge-149830
							if (newValue >= 0) {
								
								await RedemptionUtilityCommon.validateBasketRedemptions(false, NEXTGENMOB_COMPONENT_NAMES.nextGenAccessory, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare);//Dpg-3509-- added by Mahima  // Device care added - Mahima- 4154            
							}
						NextGenMobHelper.CalcDeviceRedeemFundGST(guid, newValue, componentName); 	//EDGE-175750: Added

                            //DPG-4154
                            await NextGenMobHelper.CalcForDeviceCareCompAtts(guid, mainCompName, componentName);

						break;
						//Added by Ila for Accessory DPG-3358
						case 'PaymentTypeShadow':
						console.log("Inside Next Generation Mobility afterAttributeUpdated -- PaymentTypeShadow");
							await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);

							await NextGenMobHelper.updateConfigName_AccessoryperConfig(componentName, guid); //added by krunal Taak
							await NextGenMobHelper.CalculationforDeviceCompAtts(guid, mainCompName, componentName); //added by krunal Taak
							break;
							//DPG-4154-Mahima Device care -Accessory
						case 'ContractTermShadow':
							await NextGenMobHelper.CalculationforDeviceCompAtts(guid, mainCompName, componentName); //added by krunal Taak
							break;
						case 'PaymentTypeString':                            
							RedemptionUtilityCommon.updateTotalOneFundBalance(guid, componentName); 
                        case 'AccessorySKU':
                            console.log('inside Accessory SKU');
							NextGenMobHelper.UpdateChildFromParentAtt(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.mobDeviceCare);
							break;
						case 'ChangeType':
							if(newValue==='Inflight Cancel'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Inflight Cancel', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //EDGE-203210
								let component = await solution.getComponentByName(componentName);
								let deletedConfiguration = component.softDeleteMACConfiguration(configuration);
								console.log('deletedConfiguration', deletedConfiguration);
							}else if(newValue==='Rollback Cancel'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Rollback Cancel', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //EDGE-193068
							}else if(newValue==='Rollback New'){
								await NextGenMobHelper.updatechildAttfromParent('ChangeType', 'Rollback New', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //EDGE-193068
								let component = await solution.getComponentByName(componentName);
								let deletedConfiguration = component.softDeleteMACConfiguration(configuration);
								console.log('deletedConfiguration', deletedConfiguration);
							}else if(newValue==='Inflight Amend'){
								await NextGenMobHelper.updatechisldAttfromParent('ChangeType', 'Inflight Amend', false, false, guid, NXTGENCON_COMPONENT_NAMES.nextGenAccessory); //EDGE-203210
							}
                            //--krunal DPG-5621
							else if (newValue === 'Cancel') {
								await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
								RedemptionUtilityCommon.updateTotalOneFundBalance(guid,componentName); //Edge-149830
								await CommonUtills.updateDiscountDate(componentName,guid); //EDGE-178219 - Method to update DisconnectionDate as Today's Date
								NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName); //EDGE-178219- Added for ETC calculations
							}
                            /*DN: commented out; only in COPADOCI02 and not yet in master
							else if (newValue === 'Active' || newValue === 'PaidOut') {
								await NextGenMobHelper.HideShowAttLst_NGEMDevice(guid, mainCompName, componentName, NGDListOfLists);
								//RedemptionUtilityCommon.updateTotalOneFundBalance(guid,componentName); //Edge-149830
							}*/
							//--krunal DPG-5621
							break;
                            
							//Krunal DPG-5621
							case 'EarlyTerminationCharge':
								NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							break;
                            
							case 'DisconnectionDate':
								NextGenMobHelper.CalculateTotalETCValue(guid, mainCompName);
							break;	
							//Krunal DPG-5621
							

					}
				}
				if (componentName === NEXTGENMOB_COMPONENT_NAMES.transitionDevice){
					switch (attribute.name) {
						case 'ChangeType':
							if (newValue === 'Cancel' || newValue === 'Active') {
								await NextGenMobHelper.HideShowAttLst_TransDevice(guid, mainCompName, componentName, NGDListOfLists);
								console.log('configuration.id--->', configuration.id)
								await NextGenMobHelper.UpdateETCTnasitionDevice(configuration.id, guid, configuration, componentName);

							}
							if (newValue === 'PaidOut') {
								await NextGenMobHelper.HideShowAttLst_TransDevice(guid, mainCompName, componentName, NGDListOfLists);
							}
							break;
						
						//Added for EDGE-207355 by Aman Soni || Start
						case 'BillingAccountLookup':
						if(window.OpportunityType === "Migration" && (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft')){
							await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionDevice);
						}
						break;
						//Added for EDGE-207355 by Aman Soni || End

					}
				}
				
				//Added for EDGE-207355 by Aman Soni || Start
				if(componentName === NEXTGENMOB_COMPONENT_NAMES.transitionAccessory){
					switch (attribute.name){						
												//DPG-6180 Fix start || Ila
												case 'ChangeType':
													if (newValue === 'Cancel' || newValue === 'Active') {
														await NextGenMobHelper.HideShowAttLst_TransAccessory(guid, mainCompName, componentName, NGDListOfLists);
														console.log('configuration.id--->', configuration.id)
														await NextGenMobHelper.UpdateETCTnasitionAccessory(configuration.id, guid, configuration, componentName);
						
													}
													if (newValue === 'PaidOut') {
														await NextGenMobHelper.HideShowAttLst_TransAccessory(guid, mainCompName, componentName, NGDListOfLists);
													}
													break;
													//DPG-6180 Fix end || Ila						
						case 'BillingAccountLookup':
						if(window.OpportunityType === "Migration" && (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft')){
							await NextGenMobHelper.validateConfigsInMigrationScenario(NEXTGENMOB_COMPONENT_NAMES.transitionAccessory);
						}
						break;
                        
						/*DN: commented out; only in COPADOCI02 and not yet in master
                        case 'ChangeType':
                            if (newValue === 'Cancel' || newValue === 'Active') {
                               // await NextGenMobHelper.HideShowAttLst_TransDevice(guid, mainCompName, componentName, NGDListOfLists);
                                console.log('configuration.id transitionAccessory ChangeType--->', configuration.id)
                                await NextGenMobHelper.UpdateETCTnasitionAccessory(configuration.id, guid, configuration, componentName);
                                
                            }*/
					}
				}
				//Added for EDGE-207355 by Aman Soni || End

				//Added by Aman Soni for EDGE-154026 || Start 
				if (componentName === NXTGENCON_COMPONENT_NAMES.nxtGenMainSol) {
					switch (attribute.name) {
						case 'Marketable Offer':
							if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
								await NextGenMobHelper.MandateCompBasedOnOfferName();
								await NextGenMobHelper.InValidateNGEMPlanOnOfferChange(guid);
								await NextGenMobHelper.DeviceAndPlanCount();
								CommonUtills.updateSolutionfromOffer(guid);


							}
							break;
							// EDGE-207351 Start---->
						case 'BillingAccountLookup':
							if (window.basketStage === 'Commercial Configuration' || window.basketStage === 'Draft') {
								await CHOWNUtils.getParentBillingAccount(NEXTGENMOB_COMPONENT_NAMES.solutionname);
								if(parentBillingAccountATT){
								CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NXTGENCON_COMPONENT_NAMES.nextGenPlan,oldValue);
								CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NXTGENCON_COMPONENT_NAMES.nextGenDevice,oldValue);
								CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NXTGENCON_COMPONENT_NAMES.nextGenAccessory,oldValue);
								CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NXTGENCON_COMPONENT_NAMES.transitionDevice,oldValue);
								CommonUtills.updateCompAttfromSolution('BillingAccountLookup', parentBillingAccountATT, false, true, '', NEXTGENMOB_COMPONENT_NAMES.transitionAccessory,oldValue);
								}
							}
							break;
							// EDGE-207351 End---->
					}
				}

				if (attribute.name === 'DeviceCarePlanLookup') {
					await NextGenMobHelper.EmptyRelProdAttLst(guid, mainCompName, componentName, NEXTGENMOB_COMPONENT_NAMES.mobDeviceCare, NXTGENCON_COMPONENT_NAMES.MDCEmptyAttOnPlan);
					await NextGenMobHelper.validateDeviceConfig(guid, mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice);
				}

				if (attribute.name === 'UnshapeUser' && attribute.value === false) {
					await NextGenMobHelper.EmptyRelProdAttLst(guid, mainCompName, componentName, NXTGENCON_COMPONENT_NAMES.dataFeatures, NXTGENCON_COMPONENT_NAMES.EmptyDataFeatUnshapeRCS);
				}
			}
			//Added by Aman Soni for EDGE-154026 || End
			//Added as part of EDGE-155181
			if (window.basketStage === 'Contract Accepted') {
				let configGUID, schemaName, relConfigIDCall, relConfigIDData, changeTypeVal, comp;
				//var useExistingSIM = '';
				let SimAvailabilityTypeVal = ''; // EDGE-174219
				if (componentName === 'Customer requested Dates' || componentName === 'Delivery details' || componentName === 'Enterprise Mobility Features') {
					//Added By Shweta : replace OE.getConfigGuidForOEGUID (guid) to configuration.parentConfiguration;
					//configGUID = await OE.getConfigGuidForOEGUID (guid);
					configGUID = configuration.parentConfiguration; // Changed as per suggestion from Vimal			
					schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
					//console.log ( 'schemaName ----------------------', schemaName);
					if (schemaName.includes("Device") && newValue !== 0 && newValue !== '' && newValue !== null) {
						comp = solution.getComponentByName('Device');

						/**	if (comp) {
	
								let config = comp.getConfiguration(configGUID);
								if (config) {
									let changeTypeAttrib = CommonUtills.getAttribute(config,'ChangeType');
									if(changeTypeAttrib)
										changeTypeVal = changeTypeAttrib.value;
									//changeTypeVal = await NextGenMobHelper.getAttributeValue ('ChangeType','Device',configGUID ) ; 
								}
	
							}**/
						//Commented by laxmi as changeTypeVal wasnt getting populated
						changeTypeVal = await NextGenMobHelper.getAttributeValue('ChangeType', 'Device', configGUID, undefined, comp); //EDGE-198536 added last two params

						SimAvailabilityTypeVal = "New";
                        console.log('--in DPG-Device--'+schemaName+'--comp--'+comp+'--newValue--'+newValue);

					} else if (schemaName.includes("Enterprise") && newValue !== 0 && newValue !== '' && newValue !== null) {
						comp = solution.getComponentByName(schemaName);

						/**if (comp) {

							let config = comp.getConfiguration(configGUID);
							if (config) {
								let changeTypeAttrib = CommonUtills.getAttribute(config,'ChangeType');
								if(changeTypeAttrib)
									changeTypeVal = changeTypeAttrib.value;
								let useExistingSIMAttrib = CommonUtills.getAttribute(config,'UseExitingSIM');
								if(useExistingSIMAttrib)
								useExistingSIM = useExistingSIMAttrib.value;
								//changeTypeVal = await NextGenMobHelper.getAttributeValue ('ChangeType','Device',configGUID ) ; 
							}

						}**/
						// Commented by laxmi as changeTypeVal wasnt getting populated
						changeTypeVal = await NextGenMobHelper.getAttributeValue('ChangeType', schemaName, configGUID, undefined, comp); //EDGE-198536 added last to params
						SimAvailabilityTypeVal = await NextGenMobHelper.getAttributeValue('SimAvailabilityType', schemaName, configGUID, undefined, comp); //EDGE-198536 added last to params // Added for EDGE-174219

						//Commented as a part of EDGE-170011
						//useExistingSIM = await NextGenMobHelper.getAttributeValue ('UseExitingSIM',schemaName,configGUID ) ; // Added for EDGE-166670
						//EDGE-174219
						//console.log ( 'useExistingSIM -------------',useExistingSIM);
					}
                    else if (schemaName.includes("MobileAccessory") && newValue !== 0 && newValue !== '' && newValue !== null) {
						comp = solution.getComponentByName('Accessory');
						changeTypeVal = await NextGenMobHelper.getAttributeValue('ChangeType', 'Accessory', configGUID, undefined, comp); //EDGE-198536 added last to params
						SimAvailabilityTypeVal = "New";
					}//DPG-4184 Krunal
                    
					//phone = await NextGenMobHelper.getAttributeValue ('Phone','Enterprise Mobility',configGUID ) ; 
					if (schemaName.includes("NextGenMobileDevice")) {
						comp = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
						//comp.lock('Commercial', false); // Added by laxmi to address lock issue
					} else
						if (schemaName.includes("Enterprise")) {
							comp = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenPlan);
							//comp.lock('Commercial', false); // Added by laxmi to address lock issue
						}
                    else if (schemaName.includes("MobileAccessory")) {
							comp = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenAccessory);
						}//DPG-4184 Krunal

					// if(comp){
					// 	let cmpConfig = await comp.getConfigurations();
					// 	if (cmpConfig && Object.values(cmpConfig).length > 0) {	
					// 		for (var j=0; j< Object.values(cmpConfig).length; j++) {
					// 			var config = Object.values(cmpConfig)[j];							
					// 			if (config.guid === configGUID) {
					// 					varConfig = config;
					// 					break;						
					// 			}
					// 		}
					// 	}
					// }

					// The above unwanted iteration is replaced by the following : 
					varConfig = comp.getConfiguration(configGUID);
					// Arinjay 24 Oct Brought the folowing blocks inside main OE Condition it was executing always 
					if (componentName === 'Customer requested Dates' && attribute.name === 'Not Before CRD' && newValue !== 0) {
						var notBeforeCRDValidation = new Date();
						notBeforeCRDValidation.setHours(0, 0, 0, 0);
						notBeforeCRDValidation = Utils.formatDate(notBeforeCRDValidation);

						if (Utils.formatDate(newValue) < notBeforeCRDValidation) {
							//Utils.markOEConfigurationInvalid(guid, 'Not Before CRD cannot be a past Date');
							CS.SM.displayMessage('Not Before CRD cannot be a past Date');
							newValue = ''; // Blanking out the value when its past Date
							varConfig.status = false;
							varConfig.statusMessage = 'Not Before CRD cannot be a past Date.';//EDGE-154502			

						} else {
							varConfig.status = true;
							varConfig.statusMessage = '';//EDGE-154502	
						}
						//notBeforeCRDAttVal = Utils.formatDate(newValue);
						notBeforeCRDAttVal = newValue;
						console.log('Value of preferredCRD ------------------ ', preferredCRD + '       notBeforeCRD  ' + notBeforeCRD);
						let updateConfigMap = {};
						updateConfigMap[configGUID] = [{
							name: 'Not Before CRD',
							value: newValue,
							displayValue: newValue
						}];

						if (configGUID && updateConfigMap) {
							var commerciallock = comp.commercialLock;

							if (commerciallock) await comp.lock('Commercial', false);
							let keys = Object.keys(updateConfigMap);
							for (let i = 0; i < keys.length; i++) {
								await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
							} //added as found issue with the optimized code
							if (commerciallock) comp.lock('Commercial', true);
						}
						let updateMapNew = {};
						let updateConfigMapPC = {};

						preferredCRDAttVal = await Utils.getAttributeValue('Preferred CRD', guid);

						if (preferredCRDAttVal === '' || preferredCRDAttVal < notBeforeCRDAttVal || preferredCRDAttVal === '0' || preferredCRDAttVal === 0 || preferredCRDAttVal === NaN) {
							if (!updateMapNew[guid])
								updateMapNew[guid] = [];
							updateMapNew[guid].push({
								name: 'Preferred CRD',
								showInUi: true,
								displayValue: newValue,
								value: newValue
							});
							if (guid && updateMapNew) {
								let keys = Object.keys(updateMapNew);
								var commerciallock = comp.commercialLock;
								if (commerciallock) await comp.lock('Commercial', false);
								for (let h = 0; h < keys.length; h++) {
									await comp.updateOrderEnrichmentConfigurationAttribute(configGUID, keys[h], updateMapNew[keys[h]], true)
								}
								if (commerciallock) comp.lock('Commercial', true);
							}

							updateConfigMapPC[configGUID] = [{
								name: 'Preferred CRD',
								value: notBeforeCRDAttVal,
								displayValue: notBeforeCRDAttVal
							}];
							if (configGUID && updateConfigMapPC) {
								var commerciallock = comp.commercialLock;

								if (commerciallock) await comp.lock('Commercial', false);

								let keys = Object.keys(updateConfigMapPC);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPC[keys[i]], true);
								} //added as found issue with the optimized code						
								if (commerciallock) comp.lock('Commercial', true);
							}
						}
					}

					if (componentName === 'Customer requested Dates' && newValue !== 0) {
						if (attribute.name === 'Preferred CRD') {
							let updateConfigMapPref = {};
							updateConfigMapPref[configGUID] = [{
								name: 'Preferred CRD',
								value: newValue,
								displayValue: newValue
							}];
							if (updateConfigMapPref && configGUID) {
								var commerciallock = comp.commercialLock;

								if (commerciallock) await comp.lock('Commercial', false);
								let keys = Object.keys(updateConfigMapPref);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
								}	//added as found issue with the optimized code						
								if (commerciallock) comp.lock('Commercial', true);
							}
						}
						else if (attribute.name === 'Notes') {
							let updateConfigMapPref = {};
							updateConfigMapPref[configGUID] = [{
								name: 'Notes',
								value: newValue,
								displayValue: newValue
							}];
							if (updateConfigMapPref && configGUID) {
								var commerciallock = comp.commercialLock;
								if (commerciallock) await comp.lock('Commercial', false);

								let keys = Object.keys(updateConfigMapPref);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
								}
								//await comp.updateConfigurationAttribute(configGUID, updateConfigMapPref, true); 
								if (commerciallock) comp.lock('Commercial', true);
							}
						}
					}
					//Commented as a part of EDGE-170011
					//else if (componentName === 'Delivery details' && newValue !== 0 && newValue !== '' && changeTypeVal === 'New' && useExistingSIM !== 'true'){
					else if (componentName === 'Delivery details' && newValue !== 0 && newValue !== '' && (changeTypeVal === 'New' ||changeTypeVal ==='Inflight Amend') && (SimAvailabilityTypeVal === "" || SimAvailabilityTypeVal === undefined || SimAvailabilityTypeVal.toLowerCase().includes('new'))) { // Added check for SIMAvail for EDGE-174219 // EDGE-170544 added Inflight Amend Change Type // EDGE-191075 added changes for setting SiteDeliveryContactName
						if (attribute.name === 'DeliveryContact') {
							let updateConfigMapPref = {};
                       
                        //  EDGE-213750 : defect fix  start
						/*	var FirstName = await Utils.getAttributeValue('FirstName', guid);
							var LastName = await Utils.getAttributeValue('LastName', guid);*/
                        
                            var FirstName = await Utils.getAttributeValue_generic('FirstName', guid, configGUID);
							var LastName = await Utils.getAttributeValue_generic('LastName', guid, configGUID);

						//  EDGE-213750 end	
							updateConfigMapPref[configGUID] = [{
								name: 'SiteDeliveryContact',
								value: newValue,
								displayValue: newValue
							},
							{
								name: 'SiteDeliveryContactName',
								value: FirstName + ' ' + LastName,
								displayValue: FirstName + ' ' + LastName
							}];
							if (updateConfigMapPref && configGUID) {
								var commerciallock = comp.commercialLock;
								if (commerciallock) await comp.lock('Commercial', false);

								let keys = Object.keys(updateConfigMapPref);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
								}//added as found issue with the optimized code

								if (commerciallock) comp.lock('Commercial', true);
							}
                        //  EDGE-213750 start : defect fix 
						/*	phone = await Utils.getAttributeValue('Phone', guid);
							email = await Utils.getAttributeValue('Email', guid);*/
                            phone = await Utils.getAttributeValue_generic('Phone', guid, configGUID);
							email = await Utils.getAttributeValue_generic('Email', guid, configGUID);
                        
                        // EDGE-213750 end
							if (phone === 'undefined' || phone === undefined || phone === '' || email === '' || email === undefined || email === '') {
								CS.SM.displayMessage('Selected delivery contact does not have email id or phone number; Please update the contact details');
								newValue = '';
								varConfig.status = false;
								varConfig.statusMessage = 'Selected delivery contact does not have email id or phone number; Please update the contact details';
							}
							else {
								varConfig.status = true;
								varConfig.statusMessage = '';
							}
						}
						else if (attribute.name === 'DeliveryAddress') {// EDGE-191075 added changes for setting SiteDeliveryAddressName
							let updateConfigMapPref = {};
                        // EDGE-213750 start : defect fix
						//	var AddressName = await Utils.getAttributeValue('Address Name', guid);
                            var AddressName = await Utils.getAttributeValue_generic('Address Name', guid, configGUID);
                        // EDGE-213750 end
							let AddressNamevalue = AddressName.length === 0 ?'': AddressName;  //EDGE-207583
							updateConfigMapPref[configGUID] = [{
								name: 'SiteDeliveryAddress',
								value: newValue,
								displayValue: newValue
							},
							{
								name: 'SiteDeliveryAddressName',
								value: AddressNamevalue,
								displayValue: AddressNamevalue
							}];
							if (updateConfigMapPref && configGUID) {
								var commerciallock = comp.commercialLock;
								if (commerciallock) await comp.lock('Commercial', false);

								let keys = Object.keys(updateConfigMapPref);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
								}//added as found issue with the optimized code

								if (commerciallock) comp.lock('Commercial', true);

							}
						}
					}
					else if (componentName === 'Enterprise Mobility Features' && newValue !== 0 && (changeTypeVal === 'New' || changeTypeVal === 'Inflight Amend')) // EDGE-170544 added Inflight Amend Change Type
					{
						if (attribute.name === 'InternationalRoaming') {
							let updateConfigMapPref = {};
							let intROAMVAl = "";
							if (newValue === true)
								intROAMVAl = "true";
							else
								intROAMVAl = "false";
							updateConfigMapPref[configGUID] = [{
								name: 'INTROAM',
								value: intROAMVAl,
								displayValue: intROAMVAl
							}];
							if (configGUID && updateConfigMapPref) {

								var commerciallock = comp.commercialLock;
								if (commerciallock) await comp.lock('Commercial', false);
								keys = Object.keys(updateConfigMapPref);
								for (let i = 0; i < keys.length; i++) {
									await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
								}
								if (commerciallock) comp.lock('Commercial', true);

							}
						}
						else if (attribute.name === 'mmsEnabled') {
							relConfigIDCall = await OE.getRelatedConfigID(configGUID, 'Calling & Messaging Features');
							if (relConfigIDCall !== undefined && relConfigIDCall !== 'undefined') {
								let updateConfigMapPref = {};
								var mmsEnabled = "";
								if (newValue === true)
									mmsEnabled = "true";
								else
									mmsEnabled = "false";
								updateConfigMapPref[relConfigIDCall] = [{
									name: 'MMS Eligibility',
									value: mmsEnabled,
								}];
								if (relConfigIDCall && updateConfigMapPref) {
									var commerciallock = comp.commercialLock;
									if (commerciallock) await comp.lock('Commercial', false);
									keys = Object.keys(updateConfigMapPref);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
									}
									if (commerciallock) comp.lock('Commercial', true);

								}
							}
						}
						else if (attribute.name === 'msgRestriction') {
							relConfigIDCall = await OE.getRelatedConfigID(configGUID, 'Calling & Messaging Features');
							if (relConfigIDCall !== undefined && relConfigIDCall !== 'undefined') {
								console.log('msgRestriction ----------------- + Config ID', newValue);
								let updateConfigMapPref = {};
								updateConfigMapPref[relConfigIDCall] = [{
									name: 'Message Restriction',
									value: newValue
								}];

								if (relConfigIDCall && updateConfigMapPref) {
									var commerciallock = comp.commercialLock;
									if (commerciallock) await comp.lock('Commercial', false);
									keys = Object.keys(updateConfigMapPref);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
									}
									if (commerciallock) comp.lock('Commercial', true);

								}
							}

						} else if (attribute.name === 'callRestriction') {
							//configGUID = await OE.getConfigGuidForOEGUID (guid);
							configGUID = configuration.parentConfiguration;
							schemaName = await Utils.getSchemaNameForConfigGuid(configGUID);
							relConfigIDCall = await OE.getRelatedConfigID(configGUID, 'Calling & Messaging Features'); // Laxmi changed the name of the schema as part latest changes
							if (relConfigIDCall !== undefined && relConfigIDCall !== 'undefined') {
								console.log('callRestriction ----------------- + Config ID', newValue);
								let updateConfigMapPref = {};
								updateConfigMapPref[relConfigIDCall] = [{
									name: 'Call Restriction',
									value: newValue,
								}];
								if (relConfigIDCall && updateConfigMapPref) {
									var commerciallock = comp.commercialLock;
									if (commerciallock) await comp.lock('Commercial', false);
									keys = Object.keys(updateConfigMapPref);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
									}
									if (commerciallock) comp.lock('Commercial', true);

								}
							}
						} else if (attribute.name === 'dataBarring') {
							relConfigIDData = await OE.getRelatedConfigID(configGUID, 'Data Features'); // Laxmi changed the name of the schema as part latest changes
							if (relConfigIDData !== undefined && relConfigIDData !== 'undefined') {
								console.log('dataBarring ----------------- + Config ID', newValue + relConfigIDData);
								let updateConfigMapPref = {};
								updateConfigMapPref[relConfigIDData] = [{
									name: 'Data Barring',
									value: newValue,

								}];
								if (relConfigIDData && updateConfigMapPref) {
									var commerciallock = comp.commercialLock;
									if (commerciallock) await comp.lock('Commercial', false);
									keys = Object.keys(updateConfigMapPref);
									for (let i = 0; i < keys.length; i++) {
										await comp.updateConfigurationAttribute(keys[i], updateConfigMapPref[keys[i]], true);
									}
									if (commerciallock) await comp.lock('Commercial', true);

								}
							}
						}
					}
                    //EDGE-191955
                    varConfig.status = false;
					varConfig.statusMessage = 'Click on Validate and Save to save your changes.';
                    //END - 191955
					// EDGE 191833 : Fix for config error messages
					configuration.validate();
					varConfig.validate();
					// Arinjay 
					// window.afterAttributeUpdatedOE(componentName, guid, attribute, oldValue, newValue);
					//window.afterAttributeUpdatedOE_AM(solution, schemaName, componentName, guid, attribute, oldValue, newValue);
				}
				//EDGE-150795 END
				
				if (componentName === NXTGENCON_COMPONENT_NAMES.nextGenPlan && attribute.name === 'SimAvailabilityType') // Hitesh Gandhi EDGE-200723,EDGE-208312 added to add \ delete DeliveryDetails based on SimAvailabilityType attribute update.
				{
					// DPG-456 added by vasu start //Commented By Vijay || start
					/*let inputmap = {};
					inputMap['oeAM'] = '';
					let isOrderToggled = false;
					var activeSolution =await CS.SM.getActiveBasket();
					await activeSolution.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
						isOrderToggled = values['oeAM'];
					});*///Commented By Vijay || end
					if(!window.isToggled){// DPG-456 added by vasu 
					
						if (newValue === '' || newValue === 'New SIM')
						{	
							await NextGenMobHelper.addDeliveryDetails(mainCompName,componentName,guid);
						}
						else

						{
							await NextGenMobHelper.deleteDeliveryDetails(mainCompName, componentName,guid);						
						}
					}
				}				


			}
		}
		catch (error) {
			console.log('ERROR After Attrib Update', error);
		}
		return Promise.resolve(true);
	},

	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : BeforeSave
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	BeforeSave: function () {

	},
	/************************************************************************************
	* Author	  : Aman Soni
	* Method Name : AfterSave
	* Invoked When: multiple occurrences
	* Parameters  : N/A
	***********************************************************************************/
	//Arinjay JSUpgrade
	AfterSave: async function (solution1, configurationsProcessed, saveOnlyAttachment) {
		try {
			let solution = await CS.SM.getActiveSolution();
			if (solution && (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nxtGenMainSol) || (solution.name.includes(NXTGENCON_COMPONENT_NAMES.nextGenDevice))) && (solution.components && Object.values(solution.components).length > 0)) {
				let mainCompName = NXTGENCON_COMPONENT_NAMES.nxtGenMainSol;
				//let comp = await solution.getComponentByName(NXTGENCON_COMPONENT_NAMES.nextGenDevice);
				let compName = NXTGENCON_COMPONENT_NAMES.nextGenDevice;
				//EDGE-185652 commented this Shweta 
				//await NextGenMobHelper.updateConfigName_DeviceAllConfig(compName);
				//Added by Aman Soni as a part of EDGE-148729 || End
				if (window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft') {
					//EDGE-148662
					RedemptionUtils.calculateBasketRedemption(activeNGEMBasket, basketNum);
				}				
				//Added by Aman Soni as a part of EDGE-148729 || Start  
				if (window.BasketChange === 'Change Solution' && (window.basketStage === 'Commercial Configuration' || window.basketStage==='Draft')) { ////INC000094689212 added condition
					await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenDevice, 'AfterSave', null);
					await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenPlan, 'AfterSave', null);
					await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.transitionDevice, 'AfterSave', null);
                    //await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.nextGenAccessory, 'AfterSave', null); //DPG-5621 - krunal
                    //await NextGenMobHelper.checkConfigurationSubscriptionStatusNGEM(mainCompName, NXTGENCON_COMPONENT_NAMES.transitionAccessory, 'AfterSave', null); //DPG-5621 - krunal
					await NextGenMobHelper.HideShowAttributeLstOnSaveOnMac(NGDListOfLists);
					await NextGenMobHelper.updateISPOSReversalRequired();//EDGE-164351
					await NextGenMobHelper.handleReloadinMacdTransDevice(NGDListOfLists);
                    await NextGenMobHelper.handleReloadinMacdTransAccessory(NGDListOfLists);//DPG-5621 - krunal
				}else if(	window.basketRecordType==='Inflight Change'){
					await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenDevice,'ReplaceConfig');
					await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenPlan,'ReplacedConfig');
					await InflightBasketUtils.handleReloadinInflight(NXTGENCON_COMPONENT_NAMES.nextGenAccessory,'ReplaceConfig');
					await InflightBasketUtils.handleReloadVisibilityinInflight();
				}			
				//Added by Aman Soni as a part of EDGE-148729 || End
			}
		}
		catch (error) {
			console.log(error);
		}
		return Promise.resolve(true);
	},
}
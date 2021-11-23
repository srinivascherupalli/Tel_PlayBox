// Mock response to be removed once actual response is in place.

/*let mockResponse = [{Chargeremaining: "12",
	DMcatid: "DMCAT_ProductSpecification_001389",
	Durationremaining: "10",
	Subscriptionid: "a3T2N000000JsXQUA0",
	configurationID: "a3T2N000000JsXCUA0"},
	{Chargeremaining: "10",
		DMcatid: "DMCAT_ProductSpecification_001211",
		Durationremaining: "10",
		Subscriptionid: "a4g2N0000007BNRQA2",
		configurationID: "a3T2N000000JsXQUA0"},
	{Chargeremaining: "10",
		DMcatid: "DMCAT_ProductSpecification_001211",
		Durationremaining: "10",
		Subscriptionid: "a4g2N0000007BNRQA2",
		configurationID: "a3T2N000000JsXVUA0"},
	{Chargeremaining: "10",
		DMcatid: "DMCAT_ProductSpecification_001389",
		Durationremaining: "10",
		Subscriptionid: "a4g2N0000007BNRQA2",
		configurationID: "a3T2N000000JsXaUAK"}];
*/

// Component Name map
var COMP_NAME ={
	Device :"DMCAT_ProductSpecification_001211",
	Accessory: "DMCAT_ProductSpecification_001389",
	Transition_Device: "DMCAT_ProductSpecification_001342",
	Transition_Accessory:"DMCAT_ProductSpecification_001455"
}

var RemainingAmount ={
	GetTermandAmount: async function () {
		//var test =await CS.SM.getActiveSolution();
		//est.getComponentByName('Device');
		//var test1=test.schema.getConfigurations();
		let inputMap={}
		let configurations ;
		//let guid=configurations.guid
		let currentBasket = await CS.SM.getActiveBasket();
		inputMap["GetBasket"] = currentBasket.basketId;
		//CS.SM.alertMessage('MACD product cannot be removed from the Basket', 'warning');
		currentBasket.performRemoteAction("RemainingamountdetailsHelper", inputMap).then(async (result) => {
			configurations = JSON.parse(result["GetBasket"]);
			console.log(configurations);
			await this.updateTermAndAmount(configurations);
			if(configurations =="Message1"){
				CS.SM.displayMessage('A request to retrieve the remaining term and amount is being processed. You will receive a notification once it is completed','info');
			}
			if(configurations =="Message2"){
				CS.SM.displayMessage('A request to retrieve the remaining term and amount is already fulfilled. You can proceed with your basket journey','info');
			}
		})
	},
	//Method to update Term and Amount for Device, Accessory, Transition device and Transition Accessory
	updateTermAndAmount: async function(configurations){
		let activeSolution = await CS.SM.getActiveSolution();
		let allConfigs = await activeSolution.getAllConfigurations();
		let deviceComp = await activeSolution.getComponentByName('Device');
		let accessaryComp = await activeSolution.getComponentByName('Accessory');
		let TDeviceComp = await activeSolution.getComponentByName('Transition Device');
		let TAccessaryComp = await activeSolution.getComponentByName('Transition Accessory');


		let updateDeviceConfigMap = {};
		let updateAccessaryConfigMap = {};
		let updateTDeviceConfigMap = {};
		let updateTAccessaryConfigMap = {};
		for(var respRec of configurations){
			for (var config of Object.values(allConfigs)){
				if(respRec.configurationID === config.id && respRec.DMcatid === COMP_NAME.Device){
					updateDeviceConfigMap[config.guid] =[];
					updateDeviceConfigMap[config.guid].push({
						name:'RemainingTerm',
						value:respRec.Durationremaining,
						showInUI: true,
						displayValue:respRec.Durationremaining
					},{
						name:'EarlyTerminationCharge',
						values:respRec.Chargeremaining,
						showInUI: true,
						displayValue:respRec.Chargeremaining
					});
				}
				if(respRec.configurationID === config.id && respRec.DMcatid === COMP_NAME.Accessory){
					updateAccessaryConfigMap[config.guid] =[];
					updateAccessaryConfigMap[config.guid].push({
						name:'RemainingTerm',
						value:respRec.Durationremaining,
						showInUI: true,
						displayValue:respRec.Durationremaining
					},{
						name:'EarlyTerminationCharge',
						value:respRec.Chargeremaining,
						showInUI: true,
						displayValue:respRec.Chargeremaining
					});
				}
				if(respRec.configurationID === config.id && respRec.DMcatid === COMP_NAME.Transition_Accessory){
					updateTAccessaryConfigMap[config.guid] =[];
					updateTAccessaryConfigMap[config.guid].push({
						name:'ContractTerm',
						value:respRec.Durationremaining,
						displayValue:respRec.Durationremaining
					},{
						name:'RemainingTerm',
						value:respRec.Durationremaining,
						showInUI: true,
						displayValue:respRec.Durationremaining
					},{
						name:'OC',
						value:respRec.Chargeremaining,
						showInUI: true,
						displayValue:respRec.Chargeremaining
					})
				}
				if(respRec.configurationID === config.id && respRec.DMcatid === COMP_NAME.Transition_Device){
					updateTDeviceConfigMap[config.guid] =[];
					updateTDeviceConfigMap[config.guid].push({
						name:'RemainingTerm',
						value:respRec.Durationremaining,
						showInUI: true,
						displayValue:respRec.Durationremaining
					},
					{
						name:'ContractTerm',
						value:respRec.Durationremaining,
						displayValue:respRec.Durationremaining
					},
					{
						name:'EarlyTerminationCharge',
						value:respRec.Chargeremaining,
						showInUI: true,
						displayValue:respRec.Chargeremaining
					});

				}
			}
		}
		if(updateDeviceConfigMap) {
			let keys = Object.keys(updateDeviceConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await deviceComp.updateConfigurationAttribute(keys[i], updateDeviceConfigMap[keys[i]], true);
			}
		}
		if(updateAccessaryConfigMap) {
			let keys = Object.keys(updateAccessaryConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await accessaryComp.updateConfigurationAttribute(keys[i], updateAccessaryConfigMap[keys[i]], true);
			}
		}
		if(updateTAccessaryConfigMap) {
			let keys = Object.keys(updateTAccessaryConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await TDeviceComp.updateConfigurationAttribute(keys[i], updateTAccessaryConfigMap[keys[i]], true);
			}
		}
		if(updateTDeviceConfigMap) {
			let keys = Object.keys(updateTDeviceConfigMap);
			for (let i = 0; i < keys.length; i++) {
				await TAccessaryComp.updateConfigurationAttribute(keys[i], updateTDeviceConfigMap[keys[i]], true);
			}
		}
	},
	//	DIGI-25050 BDS Sync callout to retrieve remaining term, amount on MACD Cancel
	getTermAmountSync: async function (configIds) {
		console.log('inside getTermAmountSync for DIGI-25050');
		console.log('config id list====' + configIds);
		let successmessage ="Successfully updated remaining term and balance due";
		let errormessage ="Failed to retrieve the remaining term and Balance due for the below configurations in the basket " +"\r\n";
		let inputMap = {}
		let configurations ;
		let currentBasket = await CS.SM.getActiveBasket();
	//	console.log('basket id====' + currentBasket.basketId);
		console.log('config id ====' + configIds);
		inputMap["GetConfig"] = configIds;
	//	inputMap["GetConfig"] = currentBasket.basketId;
		console.log('input map====' + inputMap);

		currentBasket.performRemoteAction("RemainingTermAmountSyncHelper", inputMap).then(async (result) => {
			configurations = JSON.parse(result["GetTermAmount"]);
			console.log('configurations====='+configurations);
					for(var response of configurations ){
						if(response.isSuccess ){
						   await this.updateTermAndAmount(configurations);
						   CS.SM.displayMessage(successmessage,'success');
						   
						}
						else{
							 errormessage+="-"+response.config_name;
							 CS.SM.displayMessage(errormessage,'error');
						}
				   }
			   
		})

		}
  
}

/*----------------------------------------------------------
  1. Ankit Goswami 	18jan2020   	EDGE 127667		Created Generic java script 
  2. Aman Soni 		28Feb2020  	EDGE-135278		Added setSubBillingAccountNumberOnCLI method to get BillingAccountNumber on CLI from subscription as a part of 
  3. Ankit Goswami 	23Apr2020   	EDGE-140967    		Added UpdateValueForSolution method for attributeupdate
  4. Aman Soni		19-May-2020	EDGE-148455  		To capture Billing Account	
  5. Shubhi		19-May-2020	EDGE-148455  		Added setAccountID method to capture AccountId at Main component level
  6. Arinjay            30-May-2020     WDGE-155244             Spring 20 changes
  7. Gnana		18-Jul-2020				CS Spring'20 Upgrade
  8. Aditya		21-Jul-2020	Edge:142084		Enable New Solution in MAC Basket
  9.Manish Berad 03-09-2020 EDGE-168275: As a Sales Enterprise, Partner, R2R user when I am doing a Device Payout within Repayment period 	then system should force cancellation of associated Device Care if it is within 30 days Trial period
  10. Vishal Arbune 03-09-2020 EDGE-164350 As sales / partner / R2R user, while cancelling device care system should be able to check if its with in 30 days of  apple care activation or not based on that relevant message to be displayed
 ------------------------------------------------------------**/
 console.log('CommonUtills static resource');
window.BasketChange='' ;
 // Gnana : CS Spring'20 Upgrade
 var CommonUtillsVariables = {
    SIGNIFICANT_ATTRIBUTELIST : ['CountHS','CountMS','CountUser','PlanTRC','ProductStatus','RecurringPrice','TOC','TotalContractValue','TotalOneOffCharge','TotalRecurringPrice','TRC']
 };
 
 var CommonUtills = {
  
	 /************************************************************************************
		* Author	: Manish Berad
		* Method Name : getIsMbDeviceCareCancellationPossible
		* Invoked When: change type is updated on Device for offer Adaptive Mobility
		* Description : EDGE-168275: As a Sales Enterprise, Partner, R2R user when I am doing a Device Payout within Repayment period 	then system should force cancellation of associated Device Care if it is within 30 days Trial period
		* Parameters :null
		***********************************************************************************/
		getIsDeviceCancellationPossible:async function(newValue){
			let loadedSolution = await CS.SM.getActiveSolution();
			let currentBasket =  await CS.SM.getActiveBasket(); 
			let cmpName=loadedSolution.getComponentByName('Device');
			if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
				if(cmpName.schema && cmpName.schema.configurations && Object.values(cmpName.schema.configurations).length > 0) {
					Object.values(cmpName.schema.configurations).forEach(async (config) => {
						let configguid=config.guid;
						let confiiIId=config.id;
						let repConfigId=config.replacedConfigId; 
						if(repConfigId && configguid){
							let relatedProductChType;
							let freeCancellationPeriod;
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0) {
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
									relatedProductChType= relatedProductAttr.filter(obj => {
										return obj.name === 'ChangeType'
											});
									freeCancellationPeriod= relatedProductAttr.filter(obj => {
										return obj.name === 'Free Cancellation Period'
											});		
								});
							}	
							
							let payTypeLookup;
							let manufacturer;
							let devType;
							let ChanngeTypeAtr;
							if (config.attributes && Object.values(config.attributes).length > 0) {
								let attribs = Object.values(config.attributes);
								payTypeLookup = attribs.filter(obj => {
									return obj.name === 'PaymentTypeString'
										});
								manufacturer = attribs.filter(obj => {
									return obj.name === 'MobileHandsetManufacturer'
										});
								devType = attribs.filter(obj => {
									return obj.name === 'Device Type'
										});
								ChanngeTypeAtr = attribs.filter(obj => {
									return obj.name === 'ChangeType'
										});
							}
							let inputMap = {};
								inputMap['getChildServicesForDeviceCare'] =repConfigId;
							currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
								let diviceCareServices = result["getChildServicesForDeviceCare"];
								let initialActivationDate=diviceCareServices.Initial_Activation_Date__c;
								let csordStatus=diviceCareServices.csord__Status__c;
								if (initialActivationDate && csordStatus==='Connected'){
									let serviceStartDate =new Date(initialActivationDate);
									let freeCancelPeriod=freeCancellationPeriod[0].displayValue;
									serviceStartDate.setDate(serviceStartDate.getDate()+parseInt(freeCancelPeriod));
									let todaysDate=(new Date()).setHours(0,0,0,0);
									if(todaysDate<serviceStartDate){
										isFreeCancellationPossible=true;
									}else{
										isFreeCancellationPossible=false;
									}
									if(isFreeCancellationPossible){
										let cnfg = cmpName.getConfiguration(configguid);
										if (confiiIId && ChanngeTypeAtr[0].displayValue === 'Cancel' 
											&& relatedProductChType[0].displayValue!=='Cancel'){
												cnfg.status = false;
												cnfg.statusMessage = 'AppleCare+ must also be cancelled for this device under the Related Products tab';
												errorTobeDisplayed = 'AppleCare+ must also be cancelled for this device under the Related Products tab';
											}else if(confiiIId && ChanngeTypeAtr[0].displayValue !== 'Cancel' 
													 && relatedProductChType[0].displayValue!=='Cancel'){
														 cnfg.status = false;
														 cnfg.statusMessage = 'AppleCare+ must also be cancelled for this device under the Related Products tab';
														 errorTobeDisplayed = 'AppleCare+ must also be cancelled for this device under the Related Products tab';
													 }
													 
													 if(ChanngeTypeAtr[0].displayValue === 'Active' || relatedProductChType[0].displayValue==='Cancel'){
														 cnfg.status = true;
														 cnfg.statusMessage = '';
														 errorTobeDisplayed = '';
													 }
										
										if (confiiIId && ChanngeTypeAtr[0].displayValue === 'Cancel' && relatedProductChType[0].displayValue==='Cancel'){
												
												var  updateMap = [];
												updateMap[configguid] = [];
												updateMap[configguid] = [{
													name: 'ChangeType',
														value: "Cancel",
															displayValue: "Cancel",
																readOnly: false
																	}];
												
												let keys = Object.keys(updateMap);
												for (let i = 0; i < keys.length; i++) {
													cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
												}
												
											} 
									}else{
										/*var  updateMap = [];
										updateMap[configguid] = [];
										updateMap[configguid] = [{
											name: 'ChangeType',
												value: "PayOut",
													displayValue: "Cancel",
														readOnly: false
															}];
										
										let keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
										}*/
										
									}
								}
							});
						}
						
					});
				}
				
			}
		},
  
	 /************************************************************************************
	  * Author	: Ankit Goswami
	  * Method Name : hideSubmitSolutionFromOverviewTab
	  * Invoked When: multiple occurrences
	  * Description : On Overview tab hides part of a screen displayig Submit Solution
	  * Parameters : N/A
	  ***********************************************************************************/
	 attrVisiblityControl: async function(componentName, ListofattributeMap) {
		 let updateMap = {};
		 ListofattributeMap.forEach((value, attrName, map)=> {
		 updateMap[attrName] = [];
		 Object.keys(value).forEach(valueKey => {
			 value[valueKey].forEach(attrVisiblity => {
					 updateMap[attrName].push({
						 name: valueKey,
					 //  value: {
							 readOnly: attrVisiblity.IsreadOnly,
							 showInUi: attrVisiblity.isVisible,
							 required: attrVisiblity.isRequired,
					 //  }
					 });	
				 });	
			 });
		 
		 });
		 //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
		 //Spring 20
	 let product = await CS.SM.getActiveSolution();
	 let component = await product.getComponentByName(componentName); 
	 //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true); 
	 let keys = Object.keys(updateMap);
	 component.lock('Commercial', false);
	 for (let i = 0; i < keys.length; i++) {
		 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
	 }
	 },
	 /************************************************************************************
	  * Author	: Ankit Goswami
	  * Method Name : UpdateValueForSolution
	  * Invoked When: multiple occurrences
	  * Description : Update the value of attribut EDGE-140967
	  * Parameters :Component Name, Map of guid with attributes Name and value
	  ***********************************************************************************/
	 UpdateValueForSolution: async function (componentName,ListofattributeMap) {
	 let updateMap = {};
	 ListofattributeMap.forEach((ValueMap, guid, map)=> {
	 updateMap[guid] = [];
	 ValueMap.forEach((Value, Key, map) => {
				 updateMap[guid].push({
					 name: Key,
				 // value: {
				 value: Value
				 // }
			 });	
		 });
	 });
	 let product = await CS.SM.getActiveSolution();
	 let component = await product.getComponentByName(componentName); 
	 //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true); 
	 //Arinjay
	 let keys = Object.keys(updateMap);
	 for (let i = 0; i < keys.length; i++) {
		 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
	 }
	 //await CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
	 },  // Updated for Edge 138108 MAC Consumption based
   
   /************************************************************************************
	  * Author	: Ankit Goswami
	  * Method Name : remainingTermEnterpriseMobilityUpdate
	  * Invoked When: multiple occurrences
	  * Description : Update the value of attribut EDGE-140967
	  * Parameters :config,contractTerm,configId,componentName,hookname
	  ***********************************************************************************/
	 remainingTermEnterpriseMobilityUpdate : async function(config,contractTerm,configId,componentName,hookname){
		 //Spring 20
		 let solution = await CS.SM.getActiveSolution();
		 let currentBasket =  await CS.SM.getActiveBasket(); 
		 
		 var ContractTypeValueStr = '';
		 if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS){
			 if (config.attributes && Object.values(config.attributes).length > 0) {
				 ContractTypeValue = Object.values(config.attributes).filter(a => {
					 return a.name === 'ContractType'
				 });
				 ContractTypeValueStr = ContractTypeValue[0].displayValue;
			 }
		 }
 		 
		if (ContractTypeValueStr !== 'Purchase'){
			 if( parseInt(contractTerm)!= 0 ){
				 let inputMap = {};
				 var originalDiscount = 0;
				 inputMap['getServiceForMAC'] = config.id;
                 let component =  await solution.getComponentByName(componentName); 
				 await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
					 var serviceStartDateString = result["getServiceForMAC"];
					 if (serviceStartDateString) {
						 var serviceStartDate = new Date(JSON.parse(serviceStartDateString));
						 var oneDay = 24*60*60*1000;
						 var today = new Date();
						 today.setHours(0,0,0,0);
						 serviceStartDate.setHours(0,0,0,0);
						 var remainingTerm = 0;
						 var remainingTerm = Math.ceil((contractTerm*30  - ((today - serviceStartDate)/oneDay)) / 30);
						 if(remainingTerm < 0 ||  isNaN(remainingTerm) || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm ==="null"){
							 remainingTerm = 0;
						 }
						 var updateRemainingTermMap = {};	// Reset Plan bonus and remaining term.
						 updateRemainingTermMap[config.guid] =[]; 
						 if( remainingTerm <= 0 || isNaN(remainingTerm) || remainingTerm === NaN || remainingTerm === undefined || remainingTerm === "" || remainingTerm ==="null" || remainingTerm ===null){
							updateRemainingTermMap[config.guid].push({
							 name: "RemainingTerm",
							 // value: {
								 value: 0,
								 showInUi: true,
								 readOnly: true,
								 displayValue: 0
							 // }
							 });
							 updateRemainingTermMap[config.guid].push({
							 name: "ServiceStartDate",
							 // value: {
								 value: serviceStartDate,
								 showInUi: false,
								 readOnly: true,
								 displayValue: serviceStartDate
							 // }
							 });
							 updateRemainingTermMap[config.guid].push({
							 name: "DeviceStatus",
							 // value: {
								 showInUi: true,
								 value: 'PaidOut',
								 displayValue : 'PaidOut'
							 // }
							 });
							 
							 
						 }
						 else{
						 // Set computed value.
						 updateRemainingTermMap[config.guid].push({
								 name: "RemainingTerm",
									 // value: {
									 value: remainingTerm,
									 showInUi: true,
										 readOnly: true,
									 displayValue: remainingTerm
									 // }
								 });
								 updateRemainingTermMap[config.guid].push({
								 name: "ServiceStartDate",
									 // value: {
									 value: serviceStartDate,
									 showInUi: false,
									 readOnly: true,
									 displayValue: serviceStartDate
									 // }
								 });
							 // 93656 Defect 20/8/19  ends
							
						 }
						 //CS.SM.updateConfigurationAttribute(componentName, updateRemainingTermMap, false).then(); 
						 //Spring 20
						 if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS)
						 {
							 UpdateVisibilityBasedonContracttype(config,hookname,remainingTerm,componentName);
						 }
                  		
						 //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateRemainingTermMap, false); 
						 let keys = Object.keys(updateRemainingTermMap);
						 for (let i = 0; i < keys.length; i++) {
							  component.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], false); 
						 }
					 }
				 });
			 }
			 else{
				 var remainingTerm = 0;
				 var updateRemainingTermMap = {};
				 updateRemainingTermMap[config.guid].push({
					 name: 'RemainingTerm',
					 // value: {
						 value: 0,
						 displayValue: 0
					 // }
				 });
				 //CS.SM.updateConfigurationAttribute(componentName, updateRemainingTermMap, false).then();
				 //Spring 20
				 let component = await solution.getComponentByName(componentName); 
				 //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateRemainingTermMap, false); 
				 let keys = Object.keys(updateRemainingTermMap);
				 for (let i = 0; i < keys.length; i++) {
					 await component.updateConfigurationAttribute(keys[i], updateRemainingTermMap[keys[i]], false); 
				 }
 
				 if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS)
				 {
					 UpdateVisibilityBasedonContracttype(config,hookname,remainingTerm,componentName);
				 }
			 }   
		 }
	 	else {
		 var remainingTerm = 0;
		 if (componentName === NEXTGENUC_COMPONENTS.DevicesMTS || componentName === NEXTGENUC_COMPONENTS.AccessoryMTS)
		 {
			 UpdateVisibilityBasedonContracttype(config,hookname,remainingTerm,componentName);
		 }
		 }
	 // Edge 138108 MAC Consumption based
	 return Promise.resolve(true);  
	 },
	 setAttributesReadonlyValue: async function(componentName,ListofattributeMap){
		 let updateMap = {};
		 ListofattributeMap.forEach((value, attrName, map)=> {
		 updateMap[attrName] = [];
		 Object.keys(value).forEach(valueKey => {
			 value[valueKey].forEach(attrVisiblity => {
					 updateMap[attrName].push({
						 name: valueKey,
						 // value: {
							 readOnly: attrVisiblity.IsreadOnly
						 // }
					 });	
				 });	
			 });
		 });
		 //CS.SM.updateConfigurationAttribute(componentName, updateMap, true);
		 let solution = await CS.SM.getActiveSolution();
		 let component = await solution.getComponentByName(componentName); 
		 //const config = await component.updateConfigurationAttribute(component.configuration.guid, updateMap, true);    
		 let keys = Object.keys(updateMap);
		 for (let i = 0; i < keys.length; i++) {
			 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
		 }
	 },
	  //Added by Aman Soni as a part of EDGE-135278 || Start
	 setSubBillingAccountNumberOnCLI: async function(componentName,Attname,solutionComponent){
		 let componentMap = {};
		 let updateMap = {};
		 //Spring 20
		 let solution = await CS.SM.getActiveSolution();
		 let component = await solution.getComponentByName(componentName); 
		 let currentBasket =  await CS.SM.getActiveBasket(); 
		 //Added by Aman Soni as a part of EDGE-148455 || Start         
		 if(solutionComponent){
			 //Spring 20 commented
			 //await CS.SM.getActiveSolution().then((solution) => {
			 var cta = Object.values(Object.values(solution.schema.configurations)[0].attributes).filter(a => {
				 return a.name === 'ChangeType' 
			 });
			 if(cta && cta.length > 0){
				 if(!componentMap[solution.name])
				 componentMap[solution.name] = [];
			 
				 if(solution.schema.configurations[0].replacedConfigId)
					 componentMap[solution.name].push({'id': Object.values(solution.schema.configurations)[0].replacedConfigId,'guid': Object.values(solution.schema.configurations)[0].guid,'ChangeTypeValue':cta[0].value});
				 else
					 componentMap[solution.name].push({'id': Object.values(solution.schema.configurations)[0].id,'guid': Object.values(solution.schema.configurations)[0].guid,'ChangeTypeValue':cta[0].value});
			 }
			 //});
		 }
		 //Added by Aman Soni as a part of EDGE-148455 || End
		 else if(!solutionComponent){        
		 //await CS.SM.getActiveSolution().then((solution) => {
		 if (solution && /*solution.type &&*/ solution.components && Object.values(solution.components).length > 0) {
			 Object.values(solution.components).forEach((comp) => {
				 if ((comp.name === componentName) &&
					 comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
						 Object.values(comp.schema.configurations).forEach((config) => {
						 if (config.replacedConfigId || config.id) {
							 var cta = Object.values(config.attributes).filter(a => {
									 return a.name === 'ChangeType' 
							 });
							 if (cta && cta.length > 0) {
								 if (!componentMap[comp.name])
									 componentMap[comp.name] = [];
 
								 if (config.replacedConfigId)
									 componentMap[comp.name].push({'id':config.replacedConfigId, 'guid': config.guid,'ChangeTypeValue':cta[0].value});
								 else
									 componentMap[comp.name].push({'id':config.id, 'guid': config.guid,'ChangeTypeValue':cta[0].value});
							 }
						 }
					 });
				 }
			 });
		 }
	 }
		 //});
 
		 if (Object.keys(componentMap).length > 0) {
			 var parameter = '';
			 Object.keys(componentMap).forEach(key => {
				 if (parameter) {
					 parameter = parameter + ',';
				 }
				 parameter = parameter + componentMap[key].map(e => e.id).join();
			 });
 
 
			 let inputMap = {};
			 inputMap['GetSubscriptionForConfiguration'] = parameter;
			 
			 var statuses;
			 await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(values => {
				 if (values['GetSubscriptionForConfiguration'])
					 statuses = JSON.parse(values['GetSubscriptionForConfiguration']);
			 });
			 
			 if (statuses){
				 Object.keys(componentMap).forEach(async comp => {
					 componentMap[comp].forEach(element => {
						 var billingAccount = '';//Added by Aman Soni as a part of EDGE-148455
						 var billingAccountNumber = '';
						 var initialActivationDate = '';
						 var status = statuses.filter(v => {
							 return v.csordtelcoa__Product_Configuration__c === element.id
						 });
						 if (status && status.length > 0) {
							 billingAccount=status[0].Billing_Account__c;//Added by Aman Soni as a part of EDGE-148455
							 billingAccountNumber=(status[0].Billing_Account__r != null && status[0].Billing_Account__r != undefined) ?  status[0].Billing_Account__r.Billing_Account_Number__c : '';
							 initialActivationDate = status[0].initialActivationDate__c;
						 }
						 if(element.ChangeTypeValue !== 'New' && Attname ==='BillingAccountNumber' && billingAccountNumber != '' && billingAccountNumber!=null){
								 updateMap[element.guid] =[{
								 name: Attname,
								 // value: {
									 value: billingAccountNumber,
									 displayValue: billingAccountNumber
								 // }
							 }];	
						 }else if(element.ChangeTypeValue !== 'New' && Attname ==='initialActivationDate' && initialActivationDate != '' && initialActivationDate!=null){
								 updateMap[element.guid] =[{
								 name: Attname,
								 // value: {
									 value: initialActivationDate,
									 displayValue: initialActivationDate
								 // }
							 }];	
						 }
						  //Added by Aman Soni as a part of EDGE-148455 || Start
						 else if(element.ChangeTypeValue !== 'New' && Attname ==='BillingAccountLookup' && billingAccount != '' && billingAccount!=null){
						 updateMap[element.guid] =[{
						 name: Attname,
						 // Arinjay commented 07 Aug 
						 //value: {
							 value: billingAccount,
							 displayValue: billingAccountNumber
						 //}
					 }];
				 }
				//Added by Aman Soni as a part of EDGE-148455 || Start
					 });
					 //CS.SM.updateConfigurationAttribute(comp, updateMap, true).then();
					 //Spring 20
					 //const config = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 
					 let keys = Object.keys(updateMap);
					 for (let i = 0; i < keys.length; i++) {
						 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
					 }
				 });
			 }
		 }
		 return Promise.resolve(true);
	  },
	  //Added by Aman Soni as a part of EDGE-135278 || End
		  //Added by shubhi edge-148455 start ----------------
	  /************************************************************************************
	   * Author	: shubhi Vijayvergia
	   * Method Name : setAccountID
	   * Invoked When: onload after remote action
	   * Description : to set account id 
	   * Parameters : solutionName, accountIdValue
	   ***********************************************************************************/
	  setAccountID : async function (solutionName,accIdValue){
		 let updateMap={};
		 let product = await CS.SM.getActiveSolution();
		 //CS.SM.getActiveSolution().then((product) => {
			if(product && product.name == solutionName && product.schema.configurations && accIdValue!=null){
				 Object.values(product.schema.configurations).forEach((cfg) => {
					updateMap[cfg.guid] = [{
						name: "AccountID",
						//value: {
							value: accIdValue
						//}
					}]
				 });
				 //CS.SM.updateConfigurationAttribute(solutionName, updateMap, false);
				 //Arinjay
				 let component = await product.getComponentByName(solutionName); 
				 let keys = Object.keys(updateMap);   
				 component.lock('Commercial',false);
				 for (let i = 0; i < keys.length; i++) {
					 await component.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
				 }
				 //component.lock('Commercial',true);    
			}
		 //});
		return Promise.resolve(true);
	},
 
	//Added as part of EDGE-149887
	getAttributeValues: async function(attributeNameList,SolutionName) {
		var returnAttrVal = {};
		let solution = await CS.SM.getActiveSolution();
		//await CS.SM.getActiveSolution().then((solution) => {
			if (/*solution.type &&*/ solution.name.includes(SolutionName)) {
				Object.values(solution.schema.configurations).forEach((config) =>{
					if (config.attributes && Object.values(config.attributes).length > 0) {
						attributeNameList.forEach((attributeInput) =>{
							var attrVal = Object.values(config.attributes).filter(att => { return att.name === attributeInput});
							if(attrVal && attrVal.length>0 && attrVal[0].value && attrVal[0].value !== undefined && attrVal[0].value !== ""){
								returnAttrVal[attributeInput] = attrVal[0].value;
							}
						});  
					}
				});
			}
		//});
		return returnAttrVal;
	},
 
	//Added as part of EDGE-149887
	getAttributeDisplayValues: async function(attributeNameList,SolutionName) {
		var returnAttrVal = {};
		//await CS.SM.getActiveSolution().then((solution) => {
		 let solution = await CS.SM.getActiveSolution();
		 if (/*solution.type &&*/ solution.name.includes(SolutionName)) {
			 Object.values(solution.schema.configurations).forEach((config) =>{
				 if (config.attributes && Object.values(config.attributes).length > 0) {
					 attributeNameList.forEach((attributeInput) =>{
						 var attrVal = Object.values(config.attributes).filter(att => { return att.name === attributeInput});
						 if(attrVal && attrVal.length>0 && attrVal[0].displayValue && attrVal[0].displayValue !== undefined && attrVal[0].displayValue !== ""){
							 returnAttrVal[attributeInput] = attrVal[0].displayValue;
						 }
					 });  
				 }
			 });
		 }
		//});
		return returnAttrVal;
	},
		
	/************************************************************************************
		* Author	: vishal Arbune
		* Method Name : getIsMbDeviceCareCancellationPossible
		* Invoked When: change type is updated on Mobile Device care for offer Adaptive Mobility
		* Description : EDGE-164350 As sales / partner / R2R user, while cancelling device care system should be able to check if its with in 30 days of  apple care activation or not based on that relevant message to be displayed
		* Parameters :null
		***********************************************************************************/
		getChildServicesMobileDeviceCare:async function(){
			let loadedSolution = await CS.SM.getActiveSolution();
			let currentBasket =  await CS.SM.getActiveBasket(); 
			let cmpName=loadedSolution.getComponentByName('Device');
			if (loadedSolution.name.includes(NEXTGENMOB_COMPONENT_NAMES.solutionname)) {
				if(cmpName.schema && cmpName.schema.configurations && Object.values(cmpName.schema.configurations).length > 0) {
					Object.values(cmpName.schema.configurations).forEach(async (config) => {
						let configguid=config.guid;
						let confiiIId=config.id;
						let repConfigId=config.replacedConfigId; 
						let relProdguid;
						if(repConfigId && configguid){
							let relatedProductChType;
							let freeCancellationPeriod;
							if (config.relatedProductList && Object.values(config.relatedProductList).length > 0){
								Object.values(config.relatedProductList).forEach(async (relatedConfig) => {
									relProdguid=relatedConfig.guid;
									let relatedProductAttr = Object.values(relatedConfig.configuration.attributes);
									relatedProductChType= relatedProductAttr.filter(obj => {
										return obj.name === 'ChangeType'
											});
											freeCancellationPeriod= relatedProductAttr.filter(obj => {
										return obj.name === 'Free Cancellation Period'
											});	
								});
							}

							let payTypeLookup;
							if (config.attributes && Object.values(config.attributes).length > 0) {
								let attribs = Object.values(config.attributes);
								payTypeLookup = attribs.filter(obj => {
									return obj.name === 'PaymentTypeString'
										});
							}
							
							let inputMap = {};
								inputMap['getChildServicesForDeviceCare'] =repConfigId;
							currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
								let diviceCareServices = result["getChildServicesForDeviceCare"];
								let initialActivationDate=diviceCareServices.Initial_Activation_Date__c;
								let csordStatus=diviceCareServices.csord__Status__c;
								
								if (initialActivationDate && csordStatus==='Connected'){
									let serviceStartDate =new Date(initialActivationDate);
									let freeCancelPeriod=freeCancellationPeriod[0].displayValue;
									serviceStartDate.setDate(serviceStartDate.getDate()+parseInt(freeCancelPeriod));
									let todaysDate=(new Date()).setHours(0,0,0,0);
									if(todaysDate<serviceStartDate){
										isFreeCancellationPossible=true;
									}else{
										isFreeCancellationPossible=false;
									}
									if(isFreeCancellationPossible){
										if(relProdguid && relatedProductChType[0].displayValue!=='Cancel'){
											var optionValues = [];
											optionValues = ["Active", "Cancel"];
											var  updateMap = [];
											updateMap[relProdguid] = [];
											updateMap[relProdguid] = [{
												name: 'ChangeType',
													value: "Active",
														displayValue: "Active",
															readOnly: false,
															showInUi:true,
																options: optionValues
																	}];
											
											let keys = Object.keys(updateMap);
											for (let i = 0; i < keys.length; i++) {
												cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
											}
										}
										
													//EDGE-168275
										if (payTypeLookup && payTypeLookup[0] && payTypeLookup[0].displayValue !== null && payTypeLookup[0].displayValue !== '' && payTypeLookup[0].displayValue === 'Hardware Repayment') {
												var optionValues = [];
												optionValues = [
												"Active","Cancel"
												];
												
												var  NGEMdev = [];
												NGEMdev[configguid] = [];
												NGEMdev[configguid] = [{
													name: 'ChangeType',
														value: "Active",
														displayValue: "Active",
														readOnly: false,
														options: optionValues
												}];
												let keys = Object.keys(NGEMdev);
												for (let i = 0; i < keys.length; i++) {
													 cmpName.updateConfigurationAttribute(keys[i], NGEMdev[keys[i]], true); 
												}
											
										}
										
									}else{
										var  updateMap = [];
										updateMap[relProdguid] = [];
										updateMap[relProdguid] = [{
											name: 'ChangeType',
												value: "PaidOut",
													displayValue: "PaidOut",
													showInUi:true,
														readOnly: true
															}];
										
										let keys = Object.keys(updateMap);
										for (let i = 0; i < keys.length; i++) {
											cmpName.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
										}
										
										
										//EDGE-168275 start
										/*let cnfg = cmpName.getConfiguration(configguid);
										cnfg.status = true;
										cnfg.statusMessage = '';
										errorTobeDisplayed = '';
										
										var  updateMapDevice = [];
										updateMapDevice[configguid] = [];
										updateMapDevice[configguid] = [{
											name: 'ChangeType',
												value: "PayOut",
													displayValue: "Pay Out",
														readOnly: false
															}];
										
										let keys1 = Object.keys(updateMapDevice);
										for (let i = 0; i < keys1.length; i++) {
											cmpName.updateConfigurationAttribute(keys1[i], updateMapDevice[keys1[i]], true); 
										}*/
										////EDGE-168275 end
									}
								}
							});
						}
					});
				}
				
			}
		},
		
	// Gnana : Added as part of CS Spring'20 Upgrade
	// This performs remote action to update Basket Oppty Sync Flag
	updateBasketOppySynFlag: async function() {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		let inputMap = {};
		inputMap['updateBasketOppySynFlag'] = currentBasket.basketId;
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
		});
	},
            
	// Aditya : Added as part of CS Spring'20 Upgrade
	// This performs remote action to update Basket Stage to Draft
	updateBasketStageToDraft: async function() {
		let currentBasket =  await CS.SM.getActiveBasket(); 
		let inputMap = {};
		inputMap['updateBasketStageToDraft'] = currentBasket.basketId;
		await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
		});
	},
            
    // Gnana : Added as part of CS Spring'20 Upgrade
	// This performs remote action to update Basket Stage to Commerical Configuration
	updateBasketDetails: async function () {
		let currentBasket = await CS.SM.getActiveBasket();
		let inputMap = {};
		if (currentBasket.basketStageValue != "Contract Accepted") { //'EDGE-164565.  Condition Added to avoid Sync flag update to false while saving OE data
			inputMap['updateBasketDetails'] = currentBasket.basketId;
			await currentBasket.performRemoteAction('SolutionActionHelper', inputMap).then(result => {
			});
		}
	},
		
	 /************************************************************************************
	  * Author	: shubhi Vijayvergia
	  * Method Name : setBillingAccountonChild
	  * Invoked When: on parent attribute change
	  * Description : on parent attribute change 
	  * Parameters : componentName, accountIdValue, childAttributeName
	  ***********************************************************************************/
	 /* setBillingAccountonChild : function(componentname,parentAttributeValue,childAttributenme){
		console.log('inside child billing acc update'+parentAttributeValue);
		CS.SM.getActiveSolution().then((product) => {
			if(product && product.schema.configurations){
				if (product.components) {
					product.components.forEach((comp) => {
						let updateMap = {};
						let isUpdate=false;
						if (comp.name===componentname && comp.schema.configurations && comp.schema.configurations.length > 0) {
							comp.schema.configurations.forEach((cfg) => {
								updateMap[cfg.guid] = [{
								name: childAttributenme,
								value: {
									value: parentAttributeValue
								}
								}]
								isUpdate=true;                               
							 });
							if(isUpdate=true){
								   CS.SM.updateConfigurationAttribute(componentname, updateMap, false);
								return Promise.resolve(true); 
							}
							
						}
						 
					});
				}
			}
		});
	}, */
	 
// Aditya: Edge:142084, Enable New Solution in MAC Basket
setBasketChange :async function (){
 //CS.SM.getActiveSolution().then((product) => {
    let product = await CS.SM.getActiveSolution();
	   if(product && product.schema && Object.values(product.schema.configurations)[0].replacedConfigId){
		window.BasketChange = 'Change Solution';
	   }
  // });
   return Promise.resolve(true);
},
/************************************************************************************
	 * Author	: shubhi Vijayvergia 
	 * edge     :166327
	 * Method Name : autoaddRelatedproduct,
	 * Invoked When: on parent config uis added
	 * Description :  on parent config uis added
	 * Parameters :component, configuration,componentname,relatedComponentsnameList,skiphooks
 ***********************************************************************************/
addRelatedProductonConfigurationAdd: async function(component, configuration,componentname,relatedComponentsname,skiphooks,max){
	let solution= await CS.SM.getActiveSolution();
	let listOfRelatedProducts = configuration.getRelatedProducts();
	var rpcount=0;
	Object.values(listOfRelatedProducts).forEach(rp => {
		if (rp.name === relatedComponentsname) {
			rpcount++;
		}
	});	
	if (rpcount< max) {
		const relatedProduct = await component.createRelatedProduct(relatedComponentsname);
		await component.addRelatedProduct(configuration.guid, relatedProduct,skiphooks); 
	}		
	return Promise.resolve(true);
    }
}
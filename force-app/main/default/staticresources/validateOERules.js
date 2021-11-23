/*
Author: shubhi Vijayvergia, Ankit Goswami
Jira : EDGE:140755, EDGE-137466, EDGE-142924
Description :  Js for order enrichment rules for UI (new Java script)
1. ankit goswami 11/05/2020 EDGE-147597 Solve data issue for old bulk functionlity
2. Laxmi Rahate - EDGE-142321, EDGE-147799  - Port Out Reversal Checks
3. Arinjay Singh  	02-July-2020		EDFE-155244 JSPlugin Upgrade
4. Pooja Bhat		22-Jul-2020 		Spring20 Upgrade - Clearing the CRD Order Enrichment incase of MACD - Moved this log from MACD Observer

*/
console.log('Inside validateOERules::::::');
var validateOERules ={
	// method added by shubhi as apart of EDGE-137466 rules to calculate when and what enrichment detials are needed 
	checkOERequirementsforMACD : async function(solutionName,componentName,relatedProductname){
		console.log('Inside validateOERules');
		var updateconfigMap={};
		var needsUpdate=false;
		//await CS.SM.getActiveSolution().then((product) => {
		//Sprint 20
		let product = await CS.SM.getActiveSolution();
		if (product.name === solutionName) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if(comp.name === componentName){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							//if(comp.schema.changeType==='Change Request'){
							Object.values(comp.schema.configurations).forEach((config) => {								
								var changeTypeVal = '';
								var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
									return ChangeType.name === 'ChangeType' 
								});	
								if(ChangeType.length >0 &&  ChangeType[0].value && ChangeType[0].value != null){
									changeTypeVal=ChangeType[0].value;
								}
								
								// Added by Laxmi
								
								var shippingRequired = Object.values(config.attributes).filter(shippingRequired =>{
									return shippingRequired.name === 'ShippingRequired' 
								});		

								var deviceShipping = Object.values(config.attributes).filter(deviceShipping =>{
									return deviceShipping.name === 'DeviceShipping' 
								});

								if(shippingRequired.length >0 &&  shippingRequired[0].value && shippingRequired[0].value != null){
									shippingReq=shippingRequired[0].value;
								}									
								
								if(deviceShipping.length >0 &&  deviceShipping[0].value && deviceShipping[0].value != null){
									deviceShip=deviceShipping[0].value;
								}									
																	
								// Laxmi Changes END									
								
								var isRelatedDeviceadded=false;
								var isMobilePlanadded=false;
								if(config.replacedConfigId===undefined || config.replacedConfigId ===null){
									isMobilePlanadded=true;
								}
								if(changeTypeVal ==='Modify'){
									if (config.relatedProductList && config.relatedProductList.length > 0) {
										config.relatedProductList.forEach((relatedConfig) => {
											if(relatedConfig.configuration.replacedConfigId ===undefined || relatedConfig.configuration.replacedConfigId ===null){
												if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
													Object.values(relatedConfig.configuration.attributes).forEach((ChangeTypeAttribute) => {
														if(ChangeTypeAttribute.name==='ChangeTypeDevice' && ChangeTypeAttribute.value !=='PayOut'){
															isRelatedDeviceadded=true;	
														}
													});
												}
											}	
										});
									}										
								}
								updateconfigMap[config.guid]=[];
								//if((changeTypeVal==='Modify' && isRelatedDeviceadded===true) || isMobilePlanadded ===true){//EDGE-142321
								if(shippingReq === 'TRUE' || deviceShip === 'TRUE'  ) {
									
									updateconfigMap[config.guid].push({
										name: 'isDeliveryEnrichmentNeededAtt',
										//value: {
											value: true
										//}
									});
									updateconfigMap[config.guid].push({
										name: 'isDeliveryDetailsRequired',
										//value: {
											value: true
										//}
									});
									needsUpdate=true;
								}else{
									updateconfigMap[config.guid].push({
										name: 'isDeliveryDetailsRequired',
										//value: {
											value: false
										//}
									});
									//EDGE-147597 added by ankit || start
									updateconfigMap[config.guid].push({
										name: 'isDeliveryEnrichmentNeededAtt',
										//value: {
											value: false
										//}
									});
										//EDGE-147597 added by ankit || End
									needsUpdate=true;
								}
							});
							//}
						}
					}
				});
			}
		}
		//});
        console.log('@@@@@@validateOERules updateconfigMap-->');
        console.log(updateconfigMap);
        if(needsUpdate=true && updateconfigMap){
			 //CS.SM.updateConfigurationAttribute(componentName, updateconfigMap, true);
			 //Spring 20
			let component = await product.getComponentByName(componentName); 
			let keys = Object.keys(updateconfigMap);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateconfigMap[keys[i]], true); 
			}

        }
	},
	// EDGE-137466 method end
	//
	// method added by shubhi as apart of EDGE-137466 rules to reset CRD date to blank when and what enrichment detials are needed 
	resetCRDDatesinCaseOfModify : async function(solutionName,componentName){
		console.log('Inside validateOERules');
		var updateconfigMapCRD={};
		var updateMapNew = {};
		
		var needsUpdateCRD=false;
		//await CS.SM.getActiveSolution().then((product) => {
		//Spring 20
		let product = await CS.SM.getActiveSolution();
		if (product.name === solutionName) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if(comp.name === componentName){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							if(comp.schema.changeType==='Change Request'){
								Object.values(comp.schema.configurations).forEach(async (config) => {								
									var changeTypeVal = '';
									var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
										return ChangeType.name === 'ChangeType' 
									});	
									if(ChangeType.length >0 &&  ChangeType[0].value && ChangeType[0].value != null){
										changeTypeVal=ChangeType[0].value;
									}
									if(changeTypeVal ==='Modify'){
										updateconfigMapCRD[config.guid]=[];
										updateMapNew[config.guid]=[];	
										updateconfigMapCRD[config.guid].push({
											name: 'Not Before CRD',
											//value: {
												value:'',
												displayValue:''	
											//}
										});
										updateconfigMapCRD[config.guid].push({
											name: 'Preferred CRD',
											//value: {
												value:'',
												displayValue:''		
											//}
										});
										updateconfigMapCRD[config.guid].push({
											name: 'isCRDEnrichmentNeededAtt',
											//value: {
												value: true
											//}
										});
										
										needsUpdateCRD=true;	
										if (config.orderEnrichmentList) {
											config.orderEnrichmentList.forEach((oe) => {
												//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
												if (!updateMapNew[oe.guid])
													updateMapNew[oe.guid] = [];
												updateMapNew[oe.guid].push({name: 'Not Before CRD', value: '',displayValue:'' },{name: 'Preferred CRD', value: '',displayValue:''});
												//}	
											});
										}							
									}
									if(updateMapNew){
										//CS.SM.updateOEConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, config.guid, updateMapNew, true);
										//console.log ( ' Blanked Out OE Attributes as well for CRD' + updateMapNew );		
									}										
								});
							}
						}
					}
				});
			}
		}
		//});
        console.log(updateconfigMapCRD);
        if(needsUpdateCRD=true && updateconfigMapCRD){
			//CS.SM.updateConfigurationAttribute(componentName, updateconfigMapCRD, true);
			//Spring 20
			let component = await product.getComponentByName(componentName); 
			let keys = Object.keys(updateconfigMapCRD);
			for (let i = 0; i < keys.length; i++) {
				await component.updateConfigurationAttribute(keys[i], updateconfigMapCRD[keys[i]], true); 
			}
			//CS.SM.updateConfigurationAttribute(componentName, updateconfigMapCRD, true).then(component => console.log('updateconfigMapCRD Attribute Update', component));
			console.log('@@@@@@validateOERules updateconfigMapCRD-->' + updateconfigMapCRD);
		 
        }
	
	},
	resetCRDDatesinOESchema : async function(solutionName,componentName){
		console.log('Inside validateOERules');
		//await CS.SM.getActiveSolution().then((product) => {
		//Spring 20
		let product = await CS.SM.getActiveSolution();
		if (product.name === solutionName) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if(comp.name === componentName){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							if(comp.schema.changeType==='Change Request'){
								Object.values(comp.schema.configurations).forEach(async (config) => {								
									var changeTypeVal = '';
									var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
										return ChangeType.name === 'ChangeType' 
									});	
									var isDeliveryEnrichmentNeededAtt = Object.values(config.attributes).filter(att =>{
										return att.name === 'isDeliveryEnrichmentNeededAtt' 
									});	
									var isCRDEnrichmentNeededAtt = Object.values(config.attributes).filter(att =>{
										return att.name === 'isCRDEnrichmentNeededAtt' 
									});	            			
									if(ChangeType.length >0 &&  ChangeType[0].value && ChangeType[0].value != null){
										changeTypeVal=ChangeType[0].value;
									}
									var updateMap = {};
									if(changeTypeVal ==='Modify' && (isCRDEnrichmentNeededAtt[0].value==='true' || isCRDEnrichmentNeededAtt[0].value===true)){
										if (config.orderEnrichmentList) {
											config.orderEnrichmentList.forEach((oe) => {
												var PreferdCRDAttribute = Object.values(oe.attributes).filter(a => {
														return a.name === 'Not Before CRD'
												});
												var NotPreferdCRDAttribute = Object.values(oe.attributes).filter(a => {
														return a.name=== 'Preferred CRD'
												});
												if ((PreferdCRDAttribute && PreferdCRDAttribute.length > 0) || (NotPreferdCRDAttribute && NotPreferdCRDAttribute.length > 0)){
														if (!updateMap[oe.guid])
														updateMap[oe.guid] = [];
													updateMap[oe.guid].push({name: 'Not Before CRD', value: ''},{name: 'Preferred CRD', value: ''},{name: 'Notes', value: ''});
													
													console.log ( 'resetCRDDatesinOESchema------blanked out CRD dates');
												}	
											});
										}
										if(updateMap) {
											//CS.SM.updateOEConfigurationAttribute(componentName, config.guid, updateMap, true);	
											//Spring 20
											let keys = Object.keys(updateMap);
											for(var h=0; h< updateMap.length;h++){
												await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMap[keys[h]],true)
											}
										}									
									}
								});
							}
						}
					}
				});
			}
		}
		//});
	},
	resetDeliverDetailsinOESchema : async function(solutionName,componentName){
		console.log('Inside validateOERules');
		//await CS.SM.getActiveSolution().then((product) => {
		//Spring 20
		let product = await CS.SM.getActiveSolution();
		if (product.name === solutionName) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if(comp.name === componentName){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							if(comp.schema.changeType==='Change Request'){
								Object.values(comp.schema.configurations).forEach(async (config) => {								
									var changeTypeVal = '';
									var ChangeType = Object.values(config.attributes).filter(ChangeType =>{
										return ChangeType.name === 'ChangeType' 
									});	
									var isDeliveryEnrichmentNeededAtt = Object.values(config.attributes).filter(att =>{
										return att.name === 'isDeliveryEnrichmentNeededAtt' 
									});	
									var isCRDEnrichmentNeededAtt = Object.values(config.attributes).filter(att =>{
										return att.name === 'isCRDEnrichmentNeededAtt' 
									});
									if(ChangeType.length >0 &&  ChangeType[0].value && ChangeType[0].value != null){
										changeTypeVal=ChangeType[0].value;
									}
									var isRelatedDeviceadded=false;
									var isMobilePlanadded=false;
									if(config.replacedConfigId===undefined || config.replacedConfigId ===null){
										isMobilePlanadded=true;
									}
									if(changeTypeVal ==='Modify'){
										if (config.relatedProductList && config.relatedProductList.length > 0) {
											config.relatedProductList.forEach((relatedConfig) => {
												if(relatedConfig.configuration.replacedConfigId ===undefined || relatedConfig.configuration.replacedConfigId ===null){
													if (relatedConfig.configuration.attributes && Object.values(relatedConfig.configuration.attributes).length > 0) {	
														Object.values(relatedConfig.configuration.attributes).forEach((ChangeTypeAttribute) => {
															if(ChangeTypeAttribute.name==='ChangeTypeDevice' && ChangeTypeAttribute.value !=='PayOut'){
																isRelatedDeviceadded=true;	
															}
														});
													}
												}	
											});
										}										
									}
									var updateMapNew = {};
									if(((changeTypeVal==='Modify' && isRelatedDeviceadded===true) || isMobilePlanadded ===true) && (isDeliveryEnrichmentNeededAtt[0].value==='true' || isDeliveryEnrichmentNeededAtt[0].value===true)){
										if (config.orderEnrichmentList) {
											config.orderEnrichmentList.forEach((oe) => {
												var DeliveryConAttribute = Object.values(oe.attributes).filter(a => {
														return a.name === 'DeliveryContact'
												});
												var DeliveryAddAttribute = Object.values(oe.attributes).filter(a => {
														return a.name=== 'DeliveryAddress'
												});
												if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
														if (!updateMapNew[oe.guid])
														updateMapNew[oe.guid] = [];
													updateMapNew[oe.guid].push({name: 'DeliveryContact', value: ''},{name: 'DeliveryAddress', value: ''});
												}	
											});
										}
										if(updateMapNew) {
											//CS.SM.updateOEConfigurationAttribute(componentName, config.guid, updateMapNew, true);	
											//Spring 20
											let keys = Object.keys(updateMapNew);
											for(var h=0; h< updateMapNew.length;h++){
												await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
											}
										}									
									}
								});
							}
						}
					}
				});
			}
		}
		//});
	},
	//Spring20 Upgrade - Clearing the CRD Order Enrichment incase of MACD - Moved this log from MACD Observer
	resetCRDDatesinOESchema_ALL : async function(solutionName,componentName){
		console.log('Inside validateOERules');
		let product = await CS.SM.getActiveSolution();
		if (product.name === solutionName) {
			if (product.components && Object.values(product.components).length > 0) {
				for(const comp of Object.values(product.components)) {
					if(comp.name === componentName){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							if(comp.schema.changeType==='Change Request'){
								for(const config of Object.values(comp.schema.configurations)) {
									if (config.orderEnrichmentList) {
										for(const oe of config.orderEnrichmentList) {
											if(oe.name === 'Customer Requested Dates 1') {
												product.deleteOrderEnrichmentConfiguration(config.guid,oe.guid,false);
											}
										}
									}								
								}
							}
						}
					}
				}
			}
		}
	},
	// CHanged below method - for EDGE-147799
	MandateOESchemaOnAccepted : async function(){
		console.log('@@@@@@@@Inside MandateOESchemaOnAccepted');
		
		//await CS.SM.getActiveSolution().then((product) => {
		//Spring 20
		let simAvailabilityVal = 'FALSE';
		let product = await CS.SM.getActiveSolution();
		if (product.name === ENTERPRISE_COMPONENTS.enterpriseMobility) {
			if (product.components && Object.values(product.components).length > 0) {
				Object.values(product.components).forEach((comp) => {
					if(comp.name === ENTERPRISE_COMPONENTS.mobileSubscription){		
						if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
							//if(comp.schema.changeType==='Change Request'){
							Object.values(comp.schema.configurations).forEach(async (config) => {								
								// if (!updateMap[config.guid])
								// 	updateMap[config.guid] = [];
								var simAvailability = Object.values(config.attributes).filter(att =>{
									return att.name === 'SimAvailabilityType' 
								});
								
								var deviceShipping  = Object.values(config.attributes).filter(att =>{
									return att.name === 'DeviceShipping' 
								});
								
								var simAvailabilityVar = simAvailability[0].value;
								var deviceShippingVal = deviceShipping[0].value;
								if((simAvailabilityVar.toLowerCase()).includes ('new'))
									simAvailabilityVal = 'TRUE';								
								var updateMapNew = {};
								if (config.orderEnrichmentList) {
									config.orderEnrichmentList.forEach((oe) => {
										//if ((DeliveryConAttribute && DeliveryConAttribute.length > 0) || (DeliveryAddAttribute && DeliveryAddAttribute.length > 0)){
										if (!updateMapNew[oe.guid])
											updateMapNew[oe.guid] = [];
										if (simAvailabilityVal === 'FALSE' &&  deviceShippingVal === 'FALSE')	{
											console.log( 'Both Attribute Values are FALSE, made OE DeliveryDetails Optional' );
											updateMapNew[oe.guid].push({name: 'DeliveryContact', required: false},{name: 'DeliveryAddress', required: false});
										}else
										console.log( 'DeliveryAddress OE Isnt Optional' );
										//}	
									});
								}
								if(updateMapNew) {
									//Spring 20
									//CS.SM.updateOEConfigurationAttribute(ENTERPRISE_COMPONENTS.mobileSubscription, config.guid, updateMapNew, true);
									let keys = Object.keys(updateMapNew);
									for(var h=0; h< keys.length;h++){
										await comp.updateOrderEnrichmentConfigurationAttribute(config.guid,keys[h],updateMapNew[keys[h]],true)
									}
								}
							});
						}
					}
				});
			}
		}
		//});
	}
}
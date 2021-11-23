/******************************************************************************************
Version No	Author 			     Date				Edge
Shubhi Vijayvergia				24/11/2020			EDGE-185011
Shubhi V            			15-12-2020          Edge-185856 
shubhi value					15/01/2020			EDGE-198439
Shubhi v                        22/04/2021          EDGE-207352 
*******************/
console.log('Load reActivateServiceUtils');
var ReactivateServiceUtils = {
    
    invokeReactivateService : async function(category,componentName,solutionName){
    await ReactivateServiceUtils.getmainSolutionSubNumber(); //Edge-185856 
    var offerId='';
    var urlparams='';
    let solutionAM = await CS.SM.getActiveSolution();
    if(solutionAM.name.includes(solutionName)){
    let solConfigs = solutionAM.getConfigurations();
    for(var solConfig of Object.values(solConfigs)){
        if(solConfig.guid){
        offerId = solConfig.getAttribute("OfferId");
        break;
        }
    }
    let comp=solutionAM.getComponentByName(componentName);
    let configurations=comp.getConfigurations();
    let alreadyPresentMisdns=[];
    for(var planConfig of Object.values(configurations)){
        let misdnatt=planConfig.getAttribute('CustomerFacingServiceId');
        let SubScenario=planConfig.getAttribute('SubScenario');
        if(misdnatt && misdnatt.value && SubScenario && SubScenario.value && SubScenario.value==='Reactivate' ){
            alreadyPresentMisdns.push(misdnatt.value);
        }
    }
	//EDGE-198439------------------------start
	urlparams = "c__ReactivateServiceVF?basketid=" +basketId +
		"&offerId=" +offerId.value +
		"&category="+category+
		"&caller="+'solutionconsole'+
		"&subscriptionNumber="+window.subscriptionNumber+
		"&alreadyPresentMisdns="+alreadyPresentMisdns
	}
	//EDGE-198439 prm fix-------------------
	let url = window.location.href; 
	var redirectURI = "/apex/";    var redirectURI = "/apex/";                              
	if(communitySiteId) {
		if (url.includes("partners.enterprise.telstra.com.au")) 
			redirectURI = "/apex/";
		else redirectURI = "/partners/apex/";
	}
    url = redirectURI +urlparams;
	return url;
	//EDGE-198439-------------------------end
	},
    handleReactivateServiceIframe : async function(data){
        let misdndata=JSON.parse(data);
        let componentName='';
        if(data.includes('AdaptiveMobility')){
            componentName= NEXTGENMOB_COMPONENT_NAMES.nextGenPlan;
        }else{
            componentName= ENTERPRISE_COMPONENTS.mobileSubscription;
        }
        let solution = await CS.SM.getActiveSolution();	
        let comp = await solution.getComponentByName(componentName);
        // EDGE-207352  start-----------------------------
        let msidnsMap={};
        msidnsMap=misdndata["data"];
        console.log('misdnmap-->');
        console.log(msidnsMap);
        if(comp){				
            //for(var msidn of msidnsMap){
            for (let misdn of msidnsMap) {
                  
                const configuration = comp.createConfiguration(
                    [{name: "CustomerFacingServiceId", value: { value: misdn.key, displayValue: misdn.key}}, 
                    {name: "SubScenario", value: { value: 'Reactivate', displayValue: 'Reactivate'}},
                    {name: "BillingAccountLookup", value:{value:misdn.value.Id, displayValue : misdn.value.Billing_Account_Number__c, lookup:misdn.value}} //// EDGE-207352  end-----------------------------
                    ]);
                await comp.addConfiguration(configuration);	
                let configName = configuration.configurationName;
                let spaceIndex = parseInt(configName.match(/\d+(?!.*\d)/));
                configuration.configurationName=configName+misdn.key+"_" + spaceIndex ;
            }
        }
        
    }, 	 
	/*******************************************************************************************************
       * Author	  : Shubhi
       * Method Name : getmainSolutionSubNumber
       * Invoked When: onload
       * Description : get main Solution SubNumber from main pc id
       * Jira		: EDGE-185011
    ******************************************************************************************************/
	getmainSolutionSubNumber: async function () {
		let solution = await CS.SM.getActiveSolution(); 
		let configurations=await solution.getConfigurations();
		let currentBasket=await CS.SM.getActiveBasket(); 
		for(var solConfig of Object.values(configurations)){
			if(solConfig.guid && solConfig.replacedConfigId && solConfig.replacedConfigId!='' && solConfig.replacedConfigId!=null){
				let inputMap = {};
				inputMap["getmainSubscriptionNumber"] = solConfig.id;
				await currentBasket.performRemoteAction("ReactivateServiceSC", inputMap).then((result) => {
					subscriptionNumber = result["getmainSubscriptionNumber"];
					console.log('*****getmainSubscriptionNumber****'+subscriptionNumber);
				});
			}
					
		}
		return Promise.resolve(true);
					
	},
	/*******************************************************************************************************
       * Author	  : Shubhi
       * Method Name : resetSubscenarioonConfigurationadded To mac basket	
       * Invoked When: onload
       * Description : get main Solution SubNumber from main pc id
       * Jira		: EDGE-185011/Edge-185856 
    ******************************************************************************************************/
	resetSubscenario: async function (configid,componentName) {
		let solution = await CS.SM.getActiveSolution();	
		let comp = await solution.getComponentByName(componentName);
		let config = await comp.getConfiguration(configid);
		let updateMapConfig = {};
		updateMapConfig[config.guid]=[];
		let SubScenario=config.getAttribute('SubScenario');//Edge-185856 
		if(SubScenario && SubScenario.value==='Reactivate'){
			updateMapConfig[config.guid].push({
				name: 'SubScenario',
				value: '',
				displayValue: ''
			});
			let keys = Object.keys(updateMapConfig);
			for (let i = 0; i < keys.length; i++) {
				comp.updateConfigurationAttribute(keys[i], updateMapConfig[keys[i]], true);
			}
		}		
		return Promise.resolve(true);
	},
                
}
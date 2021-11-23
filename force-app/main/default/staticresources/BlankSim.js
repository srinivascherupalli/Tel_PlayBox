/******************************************************************************************
 * Author	   : Colombo Team
 Change Version History
Version No	Author 			Date        Change Description 
1.
 ********************/
var communitySiteIdUC;
var BlankSim_COMPONENTS = {
	mainSolution: "SIM", 
	blankSim: "Blank SIM"
};
var eSimCount=0;
var simCardCount=0;
if (!CS || !CS.SM) {
	throw Error("Solution Console Api not loaded?");
}

if (CS.SM.registerPlugin) {
	console.log("Blank SIM Plugin");
	window.document.addEventListener("SolutionConsoleReady", async function () {
		console.log("SolutionConsoleReady");
		await CS.SM.registerPlugin("SIM").then(async (blankSimPlugin) => {
			updateBlankSimPlugin(blankSimPlugin);
		});
	});
}

function updateBlankSimPlugin(blankSimPlugin) {
	//console.log("inside hooks", UCTenancyPlugin);
	window.document.addEventListener("SolutionSetActive", async function (e) {
		let loadedSolution = await CS.SM.getActiveSolution();
		if (loadedSolution.componentType && loadedSolution.name.includes(BlankSim_COMPONENTS.mainSolution)) {
			let currentBasket= await CS.SM.getActiveBasket();
			await CommonUtills.getBasketData(currentBasket);
			await calculateSimCounts();
			if (basketStage === "Submitted") {
					activeEMSolution.lock("Commercial", true);
			}
		}
		return Promise.resolve(true);
	});

	/**
	 * Hook executed before we save the complex product to SF. We need to resolve the promise as a
	 * boolean. The save will continue only if the promise resolve with true.
	 * Updated by : Venkata Ramanan G
	 * To create case for the configuration in case the business criteria w.r.t to pricing has met
	 * @param {Object} complexProduct
	 */
	blankSimPlugin.afterSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		CommonUtills.unlockSolution();
		if (basketStage !== "Submitted") 
            CommonUtills.updateBasketDetails(); //Gnana: CS Spring'20 Upgrade
		Utils.hideSubmitSolutionFromOverviewTab();
        CommonUtills.lockSolution();   
		return Promise.resolve(true);
	};
    blankSimPlugin.beforeSave = async function (solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		var isConfgvalid=true;
		isConfgvalid=await calculateSimCounts();
		//prod validate and save fix start-----------
		let inputMap = {};
	    inputMap["allowHardStop"] = "";
        let curbasket = await CS.SM.getActiveBasket();
	    await curbasket.performRemoteAction("SolutionActionHelper", inputMap).then((response) => {
		    var result = response["AllowHardStop"];
		    if(result==="true"){
			  //allowHardStop=true;
			  if(solution && solution.error===true && allowHardStop===true){
				  return Promise.resolve(false);
				}
			}
		});
		//prod validate and save fix end-----------
		if(!isConfgvalid){
			return Promise.resolve(false);
		}
		return Promise.resolve(true);
	};

	blankSimPlugin.afterAttributeUpdated = async function (component, configuration, attribute, oldValueMap) {
		console.log("Attribute Update - After", component.name, configuration.guid, attribute, oldValueMap.value, attribute.value);
        CommonUtills.unlockSolution();
		if(attribute.name==='Quantity'){
			if(attribute.value>100){
				configuration.status=false;
				configuration.statusMessage='Total quantity per SIM type cannot exceed 100';
			}else{
				configuration.status=true;
			}
		}
		CommonUtills.lockSolution();
		    
		return Promise.resolve(true);
	};

	//Aditya: Spring Update for changing basket stage to Draft
	blankSimPlugin.afterSolutionDelete = function (solution) {
		if (basketStage !== "Submitted") {
            CommonUtills.updateBasketStageToDraft();
        }else{
            return Promise.resolve(false);
        }
		return Promise.resolve(true);
	};
}

async function calculateSimCounts(){
	  let allowSaveCount=true;
      let solution = await CS.SM.getActiveSolution();
      let comp=await solution.getComponentByName(BlankSim_COMPONENTS.blankSim);
      let configs=await comp.getConfigurations();
	  eSimCount=0;
	  simCardCount=0;
	  let invalid_ESimConfigList=[];
	  let invalid_SimCardConfigList=[];
      for(var config of Object.values(configs)){
        let simTypeAttval=config.getAttribute('Type');
        let quantity=config.getAttribute('Quantity');
		if(simTypeAttval.value==='eSIM'){
			eSimCount+=Number(quantity.value);
			invalid_ESimConfigList.push(config);
		}else if(simTypeAttval.value==='SIM card'){
			simCardCount+=Number(quantity.value);
			invalid_SimCardConfigList.push(config);
		}
      }
	  if(eSimCount>100){
		for(var config of invalid_ESimConfigList){
			config.status=false;
			config.statusMessage='Total quantity per SIM type cannot exceed 100';
			allowSaveCount=false;
		}
	  }
	  if(simCardCount>100){
		for(var config of invalid_SimCardConfigList){
			config.status=false;
			config.statusMessage='Total quantity per SIM type cannot exceed 100';
			allowSaveCount=false;
		}
	  }
	  if(allowSaveCount===true){
		for(var config of Object.values(configs)){
			config.status=true;
            config.statusMessage='';
		}
          await solution.validate();
	  }
	  return allowSaveCount;        
} 

/*******************************************************************************************************
* Author	  : Shubhi
* Method Name : stopSaveonErrorinSolution
* Invoked When: beforesave hook
* Description : hard stop user form saving wrong configuration
* Parameters  :
* Jira		: EDGE-185990
******************************************************************************************************/
 async function  stopSaveonErrorinSolution() {
	  let curbasket = await CS.SM.getActiveBasket();
	  let inputMap = {};
	  let allowHardStop=false;
	  inputMap["allowHardStop"] = "";
	  let solution = await CS.SM.getActiveSolution();
	  await curbasket.performRemoteAction("SolutionActionHelper", inputMap).then((response) => {
		  var result = response["AllowHardStop"];
		  if(result==="true"){
			  //allowHardStop=true;
			  if(solution && solution.error===true && allowHardStop===true){
				  allowHardStop=solution.error;
				  return allowHardStop;
			  }
		  }
	  });
	  
  }        
            
            
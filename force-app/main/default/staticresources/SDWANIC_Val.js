/*
 * Handles all validation logic
 */
console.log('[SDWANIC_Val] loaded');

if (!CS || !CS.SM){
    throw error('Solution Console API not loaded?');
}
const SDWANIC_Val = {};

SDWANIC_Val.beforeSave = async function(solution, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
	try {
		let currentSolution = await CS.SM.getActiveSolution();
		
		if (window.basketStage === "Contract Accepted" || window.basketStage === "Enriched" || window.basketStage === "Submitted") {
			currentSolution.lock("Commercial", false);
		}
		//SDWANIC_Val.beforeSave();
		console.log('currentSolution for SDWANIC_Val ==>' + currentSolution);
		//await SDWANIC_Val.InterConnectVerification(); //Commenting as part of DIGI-26454 
		
		let checkFlag1 = await SDWANIC_Val.InterConnectPopValidation();
		let checkFlag = await SDWANIC_Val.PoPCheckAccount();
		
		if (checkFlag == true || checkFlag1 == true) {
			CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
			return false;
		} else {
			return true;
		}
	} catch (error) {
		console.log('[SDWANIC_UI] beforeSave() exception: ' + error);
		//return false;
	}
	//return true;
};

/***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectVerification
     * Invoked When: Before Save on clicking on Validate and Save
     * Description : To display simple message 	- DIGI-18412
     * Parameters  : None	
     ***********************************************************************************************************************************/
/* Commenting as part of DIGI-26454 
SDWANIC_Val.InterConnectVerification = async function() {
	try {
		var VPN_ID;
        let currentSolution = await CS.SM.getActiveSolution();

        Object.values(currentSolution.schema.configurations).forEach((config) => {
            if (config.guid) {
                let attribs = Object.values(config.attributes);
                VPN_ID = attribs.filter((c) => {
                    return c.name === "VPN ID";
                });
            }
        });
        console.log('VPN ID ==>' + VPN_ID);
        if (VPN_ID[0].displayValue === null || VPN_ID[0].displayValue === "" || VPN_ID[0].displayValue === " ") {
            CS.SM.displayMessage("Please enter the IP-VPN ID of customer for which the interconnect is required", "error");
        }
            //return Promise.resolve(true);
	} catch (error) {
		console.log('[SDWANIC_Val] InterConnectVerification() exception: ' + error);
	}
	return Promise.resolve(true);
};
*/
/***********************************************************************************************************************************	
     * Author	   	 : Payel
     * Method Name : InterConnectPopValidation
     * Invoked When: Before Save on clicking on Validate and Save
     * Description : To display simple Validation message 	- DIGI-18412
***********************************************************************************************************************************/
SDWANIC_Val.InterConnectPopValidation = async function() {
	try {
		var iPop;
        var i;
        var iPop_arr = new Array();
        var checkFlag1 = false;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = currentComponent.getConfigurations();
        Object.values(currentComponent.schema.configurations).forEach((configs) => {
            if (configs.guid) {
                let attribs = Object.values(configs.attributes);
                iPop = attribs.filter((c) => {
                    return c.name === "PoP";
                });
            }
            iPop_arr.push(iPop[0].displayValue);
        });
        console.log('PoP ==>' + iPop);
        console.log('iPop_arr ==>' + iPop_arr);
        for (i = 0; i <= iPop_arr.length; i++) {
    for (j = 0; j <= iPop_arr.length; j++) {
		if(i !== j) {
			if (iPop_arr[i] === iPop_arr[j] && iPop_arr[i] !== undefined && iPop_arr[j] !== undefined ) {
			checkFlag1 = true;            
        }
		}
    } 
    }
    /*if (checkFlag1 = true)
    {
    	CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
    }
        //return Promise.resolve(true);*/
        return checkFlag1;
	} catch (error) {
		console.log('[SDWANIC_Val] InterConnectPopValidation() exception: ' + error);
	}
	//return Promise.resolve(true);
};

/***********************************************************************************************************************************
* Author	  : Payel
* Method Name : PoPCheckAccount
* Invoked When: On Clicking on Validate and Save (Before Save)
* Description : Checks whether any Basket on the CIDN has an active subscription with the same POP
* Parameters  : 
***********************************************************************************************************************************/
SDWANIC_Val.PoPCheckAccount = async function() {
	try {
		var iPop_arr = new Array();
              var i;
              var iPop;
              var checkFlag = false;
        let currentSolution = await CS.SM.getActiveSolution();
        let currentComponent = currentSolution.getComponentByName(SDWANVPN_COMPONENTS.InterConnect);
        let configs = currentComponent.getConfigurations();
        Object.values(currentComponent.schema.configurations).forEach((configs) => {
            if (configs.guid) {
                let attribs = Object.values(configs.attributes);
                iPop = attribs.filter((c) => {
                    return c.name === "PoP";
                });
            }
    		if (configs.replacedConfigId == undefined || configs.replacedConfigId == null || configs.replacedConfigId == "")
            {
            iPop_arr.push(iPop[0].displayValue);
            }
            //iPop_arr.push(iPop[0].displayValue);
        });
        console.log('PoP ==>' + iPop);
        console.log('iPop_arr ==>' + iPop_arr);
		let inputMap = {};
                  inputMap['GetInterConDetails'] = accountId;
				  await currentBasket.performRemoteAction('SDWANServiceTenancyHandler', inputMap).then(result => {
                      console.log('GetInterConDetails finished with response: ', result);
					  var PoPattr = JSON.parse(result["GetInterConDetails"]);
                      console.log('GetInterConDetails: ', PoPattr);
                       console.log('GetInterConDetails: ', PoPattr[0]);
                       Object.values(PoPattr).forEach((pOp) => {
                               console.log(pOp.PoP);
							  iPop_arr.push(pOp.PoP);
							  console.log(iPop_arr);
							  
		          });

         });
         for (i = 0; i <= iPop_arr.length; i++) {
    for (j = 0; j <= iPop_arr.length; j++) {
		if(i !== j) {
			if (iPop_arr[i] === iPop_arr[j] && iPop_arr[i] !== undefined && iPop_arr[j] !== undefined ) {
				checkFlag = true;            
        }
		}
    } 
    }
   /* if (checkFlag == true)
    {
    	CS.SM.displayMessage("Duplicate PoP selected for the interconnect. Please correct", "error");
    }*/
    return checkFlag;
	} catch (error) {
		console.log('[SDWANIC_Val] PoPCheckAccount() exception: ' + error);
	}
	//return Promise.resolve(true);
};

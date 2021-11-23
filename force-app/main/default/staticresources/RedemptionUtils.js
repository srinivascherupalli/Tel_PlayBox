/******************************************************************************************
Author	   : Romil Anand && Vishal Arbune
Change Version History
Version No	    Author 			Date           Story
    1.         Vishal Arbune   01-10-2019      EDGE-113083 : Show available OneFund balance from CIDN at the time of basket creation
	2.         Romil Anand     02-10-2019      EDGE-115925 : Calculation of Total Basket amount on Validate & Save
	3.         Romil Anand     05-10-2019      EDGE-114977 : UI changes to be made on Subscription page
	4.         Romil Anand     10-10-2019      EDGE-113570 : Redemption amount cannot be more than the Charge Amount
	5.         Romil Anand     12-10-2019      EDGE-113091 : Show Fund balance details on Subscription page for each Solution in the Basket
	6.         Vishal Arbune   13-10-2019      EDGE-112359 : Cloudsense Opportunity basket flow
	7.         Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
	8.         Romil Anand     25-12-2019      EDGE-118038 : Eligible Redeemable charges (from Sigma to CS)-New Scenario
	9.         Romil Anand     25-10-2019      EDGE-119323 : GST Calculation of Net Charge while Redemption
	10.        Romil Anand     22-10-2019      EDGE-127941 : Calculate Total Contract Value for a Basket
	11.        Romil Anand     20-10-2019      EDGE-116121 : Cancellation of CS Basket before Order submission
	12.        Romil Anand     15-01-2020      EDGE-130075 : Redeeming One Funds for Cancel Journey for NGUC
	13.        Romil Anand     15-01-2020      EDGE-130859 : Redeeming One Funds for Cancel Journey for CMP
    14. 	   Romil Anand     24-04-2020	   EDGE-144161 : Enabling Redemption as Discount for Device Payout and NGUC 
    15.        Aditya Pareek   15-05-2020      Edge-144971 : Updated by Aditya for setting Redeem fund vlaue as 0
    16. 	   Romil Ananad    26-05-2020	   EDGE-150132 : added OR part by Romil
    17.		   Ankit Goswami   01-06-2020	   EDGE-152069 : Fix issue For show Check OneFund 
    18.        Shubhi	       08-June-2020	   EDGE-148662 : Enabling one fund and POS
    19.        Arinjay Singh   02-July-2020    EDGE-155244 : JSPlugin Upgrade  and Merge with 20.08
	20.        shubhi		13-08-2020		EDGE-169593 js ugrade issue fixes
******************************************************************************************/
window.currentFundBalance=0.00;
window.basket=0.00;
window.basketlevelRedemption=0.00;
window.deductBalanceConfig=0.00;
var Redemption_COMPONENT_NAMES = { //EDGE-148662 updated name due to conflict
    DOPsolution: 'Device Outright Purchase',
    solution: 'Device Outright Purchase',
    enterpriseMobility: 'Corporate Mobile Plus',
	mobileSubscription: 'Mobile Subscription',
    NGUC: 'Telstra Collaboration',
    deviceOutRight: 'Mobile Device',
    device:'Device',
    DevicesMTS:'Devices',
    Device: 'Unified Communication Device',
    AccessoryMTS:'Accessories',
    Accessory: 'Accessory',
    inactiveSIM: 'Inactive SIM',
    NextGenEM:'Next Generation Enterprise Mobility', //EDGE-148662
	nextGenEM_Device:'Device' //EDGE-148662
};
RedemptionUtils = {     
    /**************************************************************************************
     * Author	   : Vishal Arbune
     * Method Name : displayCurrentFundBalanceAmt
     * Invoked When: On loading of Solution
     * Description : Fetch the Fund Balance From CIDN level
     **************************************************************************************/
    displayCurrentFundBalanceAmt : async function()
    {
        let currentBasket=await CS.SM.getActiveBasket();
	await CS.SM.getBasketName().then(cart => { //EDGE-169593
	        let inputMap = {};
		    	inputMap['GetBasket'] = cart;
   			currentBasket.performRemoteAction('FundBalanceAmountHelper', inputMap).then(result => {
        	window.currentFundBalance = JSON.parse(result["GetBasket"]);
        		//console.log('currentFundBalance---------',currentFundBalance);
       			return Promise.resolve(true);
    		});
            return Promise.resolve(true);
    	}); 
                       		return Promise.resolve(true);
    },
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : calculateBasketRedemption
     * Invoked When: On loading of Solution
     * Description : Fetching the basket Redemption Amount from PC's level
     **************************************************************************************/	
    calculateBasketRedemption : async function() 
    {
        let currentBasket = await CS.SM.getActiveBasket(); 
        await CS.SM.getBasketName().then(cart => { //EDGE-169593
            let inputMap = {};
            inputMap['GetBasket'] = cart;
            //console.log('GetBasket GetBasket: ', inputMap);
            currentBasket.performRemoteAction('BasketRedemptionHelper', inputMap).then(result => {
                window.basket = JSON.parse(result["GetBasket"]);
                window.basketlevelRedemption=JSON.parse(result["GetBasket"]);
                //console.log('basketlevelRedemption : ',window.basketlevelRedemption);  
                return Promise.resolve(true);          
            });
        });
    },
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmount
     * Invoked When: On loading of Solution
     * Description : Sets Mobile Subscription configuration name
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    populatebasketAmount: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/ (product.name === Redemption_COMPONENT_NAMES.DOPsolution||product.name ===  Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight ||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {   //EDGE-148662             			
                        populatebasketAmountCommon(comp);               
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true)
    },
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforAccessory
     * Invoked When: On loading of Solution
     * Description : Sets Mobile Subscription configuration name
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    populatebasketAmountforAccessory: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/ product.name === Redemption_COMPONENT_NAMES.NGUC) {
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name===Redemption_COMPONENT_NAMES.AccessoryMTS) {                			
                        populatebasketAmountCommon(comp);                                
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true);
    },
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populateNullValues
     * Invoked When: On Cloning of Solution
     * Description : Sets Redemption Values to Null
     * Parameters  : configuration guid or left empty if doing for all configs
     * Updated:    : Updated by Aditya for Edge-144971(Value and Display Value)
     * *   * Updated:    : Updated by Shubhi for Edge-144971(Value and Display Value)
     **************************************************************************************/
    populateNullValues: async function(componentName,configuration) 
    {
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        mobSubsConfigGUID = configuration.guid;				
        if(mobSubsConfigGUID !==""){
            updateConfigMap[mobSubsConfigGUID] = [
            {
                name: 'TotalFundAvailable',
                // value: {
                    value: currentFundBalance,
                    displayValue: currentFundBalance
            // }
            },{
                    name: 'RedeemFund',
                    // value: {
                        value: 0.00,
                        displayValue: 0.00
                    // }
                }
            ];
            //CS.SM.updateConfigurationAttribute(componentName, updateConfigMap, true);
            // Spring 20
            let product = await CS.SM.getActiveSolution();
            let component = await product.getComponentByName(componentName); 
            //const config = await component.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap, true); 
            let keys = Object.keys(updateConfigMap);
            for (let i = 0; i < keys.length; i++) {
                await component.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
            }
        }
        return Promise.resolve(true);
    },
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : displayRemainingBalanceAmt
     * Invoked When: On 49ing of checkonefund button
     * Description : Calculates the dynamic balance
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
   displayRemainingBalanceAmt: async function() 
    { 
        var showbalance=0.00;
		var totalRedemption=0.00;
		if(CS.SM.basketStageValue==='Draft'||CS.SM.basketStageValue==='Commercial Configuration'||CS.SM.basketStageValue==='Quote'||CS.SM.basketStageValue==='Contract Initiated'){
            //CS.SM.getActiveSolution().then((product) => {
            let product = await CS.SM.getActiveSolution();
            if (product && product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight ||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS||comp.name===Redemption_COMPONENT_NAMES.AccessoryMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {   //EDGE-148662              			 
                        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
                            Object.values(comp.schema.configurations).forEach((subsConfig) => {
                                //if(((subsConfig.configurationName.includes('Device'))&& (!subsConfig.configurationName.includes('Handset'))&&(!subsConfig.configurationName.includes('Power')) &&(!subsConfig.configurationName.includes('IAD')))||subsConfig.configurationName.includes('Accessory')) {  
                                if(!subsConfig.id || subsConfig.id==='' || subsConfig.id===null) {
                                    var fundRedeemed=0;
                                    mobSubsConfigGUID = subsConfig.guid;
                                    var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                                    if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "" && RedeemFund[0].displayValue >=0)
                                        fundRedeemed =fundRedeemed + parseFloat(RedeemFund[0].displayValue);
                                    fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                                    if(fundRedeemed <= window.currentFundBalance)
                                    {
                                        totalRedemption= parseFloat(totalRedemption) + fundRedeemed;
                                        showbalance=parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
                                    } 
                                }
                            });	
                        }                                
                    }
                    else if (comp.name === Redemption_COMPONENT_NAMES.mobileSubscription) {                			
                        if (comp.schema && comp.schema.configurations && comp.schema.configurations.length > 0 ) {
                            comp.schema.configurations.forEach((subsConfig) => {
                                    var fundRedeemed=0;
                                    mobSubsConfigGUID = subsConfig.guid;
                                    var RedeemFund = subsConfig.attributes.filter(att => { return att.name === "RedeemFund"});
                                    var ChangeTypeOnPlan = subsConfig.attributes.filter(att => { return att.name === "ChangeType"});
                                    if(ChangeTypeOnPlan && ChangeTypeOnPlan.length>0 && ChangeTypeOnPlan[0].value==='Modify'){	
                                        if(subsConfig && subsConfig.relatedProductList.length>0){
                                            subsConfig.relatedProductList.forEach((Reletedplanconfig) => {
                                                var ChangeTypeOnDevice = Reletedplanconfig.configuration.attributes.filter(att => { return att.name === "ChangeTypeDevice"});
                                                var RedeemFundDevice = Reletedplanconfig.configuration.attributes.filter(att => { return att.name === "RedeemFund"});
                                                if(ChangeTypeOnDevice[0].value==='PayOut'){
                                                    if(RedeemFundDevice && RedeemFundDevice.length>0 && RedeemFundDevice[0].displayValue && RedeemFundDevice[0].displayValue !== undefined && RedeemFundDevice[0].displayValue !== "" && RedeemFundDevice[0].displayValue >=0)
                                                            fundRedeemed =fundRedeemed + parseFloat(RedeemFundDevice[0].displayValue);
                                                }
                                            });
                                        }
                                    }else if(ChangeTypeOnPlan && ChangeTypeOnPlan.length>0 && ChangeTypeOnPlan[0].value==='Cancel'){
                                        if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "" && RedeemFund[0].displayValue >=0)
                                        fundRedeemed =fundRedeemed + parseFloat(RedeemFund[0].displayValue);
                                    }
                                    fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                                    if(fundRedeemed <= window.currentFundBalance)
                                    {
                                    totalRedemption= parseFloat(totalRedemption) + fundRedeemed;
                                    showbalance=parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
                                    } 
                                
                            });	
                        }                                
                    }
                });
                showbalance=parseFloat(window.currentFundBalance) - (parseFloat(window.basketlevelRedemption) + totalRedemption);
                if(showbalance>=0)
                {
                    CS.SM.displayMessage('Available OneFund Balance '+showbalance,'success');
                }
                else
                {
                    CS.SM.displayMessage('There is an Error in the Configuration or other Solution Configuration.','error');
                }         
            }
            // }).then(
            //     () => Promise.resolve(true)
            // );
            return Promise.resolve(true);
		}
		else{
		     CS.SM.displayMessage('Available OneFund Balance '+currentFundBalance,'success');
        }
    },
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforSaved
     * Invoked When: On loading of Solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    populatebasketAmountforSaved: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/ (product.name === Redemption_COMPONENT_NAMES.DOPsolution||product.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight ||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {  //EDGE-148662 
                        populatebasketAmountforSavedCommon(comp);                                 
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true);
    },
 /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforSavedAccessory
     * Invoked When: On loading of Solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    populatebasketAmountforSavedAccessory: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution();
        if (/*product.type &&*/ (product.name === Redemption_COMPONENT_NAMES.DOPsolution||product.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product && product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS) { 
                        populatebasketAmountforSavedCommon(comp);                       
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return  Promise.resolve(true);
    },
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : checkRedeemDiscountonload
     * Invoked When: on load of solution
     * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
     * Parameters  : checks for all config
     **************************************************************************************/
    checkRedeemDiscountonload: async function(solutionName)
	{
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution(); // Spring 20
        if (product && /*product.type &&*/ (product.name === Redemption_COMPONENT_NAMES.DOPsolution||product.name === Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                var IsUpdateAttribute=false;
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS||comp.name === Redemption_COMPONENT_NAMES.deviceOutRight || Redemption_COMPONENT_NAMES.nextGenEM_Device) {  //EDGE-148662  
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
                                Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                                mobSubsConfigGUID=subsConfig.guid;	
                                var redeemFundCheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded"});
                                if(redeemFundCheckNeeded && redeemFundCheckNeeded[0] && redeemFundCheckNeeded[0].value ===true) 
                                {
                                    IsUpdateAttribute = true;		
                                }
                                if(IsUpdateAttribute){
                                    //CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
                                    // Spring 20
                                    let cnfg = await comp.getConfiguration(subsConfig.guid); 
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                                }
                                else {
                                    //CS.SM.updateConfigurationStatus(comp.name, subsConfig.guid, true);
                                    // Spring 20
                                    let cnfg = await comp.getConfiguration(subsConfig.guid); 
                                    cnfg.status = true;
                                }
                            });	
                        }   
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true);
	},
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : CheckRedeemFundDiscount
     * Invoked When: whenever redemption value gets populated.
     * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
     * Parameters  : configuration guid and componentName 
     **************************************************************************************/
    CheckRedeemFundDiscount: async function(guid,componentName)
    {
		var IsUpdateAttribute = false;
		var IsUpadateRequired=false;
		let updateMapFund =  new Map();
        //await CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach((comp) => {
                if (comp.name === componentName) {                			
                    if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
                        Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                            var fundRedeemed=0;
                            let componentMapNew =   new Map();
                            if(subsConfig.guid===guid)
                            {	
                                var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                                if(RedeemFund[0].displayValue >0) 
                                {
                                    IsUpdateAttribute = true;		
                                }
                                else
                                {
                                    IsUpdateAttribute = false;
                                }
                                if(IsUpdateAttribute){
                                    componentMapNew.set('IsRedeemFundCheckNeeded',true);
                                    //CS.SM.updateConfigurationStatus(componentName, subsConfig.guid, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
                                    // Spring 20
                                    let cnfg = await comp.getConfiguration(subsConfig.guid); 
                                    cnfg.status = false;
                                    cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                                }
                                else {
                                        componentMapNew.set('IsRedeemFundCheckNeeded',false);
                                        //CS.SM.updateConfigurationStatus(componentName, subsConfig.guid, true);
                                        // Spring 20
                                        let cnfg = await comp.getConfiguration(subsConfig.guid); 
                                        cnfg.status = true;
                                    }
                                }
                                
                        });	
                    } 
                    if(componentMapNew && Object.values(componentMapNew).length>0){
                        updateMapFund.set(subsConfig.guid,componentMapNew);	// by shubhi to fix async execution
                    }
                    if(updateMapFund)
                        CommonUtills.UpdateValueForSolution(componentName,updateMapFund)
                }
            });
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return  Promise.resolve(true);
    },
        /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : CheckRedeemDiscountValidation
     * Invoked When: whenever response from MS will come.
     * Description : Enabling Redemption as Discount for Device Payout and NGUC EDGE-144161
     * Parameters  : componentName
     **************************************************************************************/
    CheckRedeemDiscountValidation: async function(componentName)
    {
		var IsUpdateAttribute = false;
		var IsUpadateRequired=false;
        let updateMapFund =  new Map();
        let product = await CS.SM.getActiveSolution(); // Spring 20
        //CS.SM.getActiveSolution().then((product) => {
        if (product.components && Object.values(product.components).length > 0) {
            Object.values(product.components).forEach((comp) => {
                if (comp.name === componentName &&basketChangeType !== 'Change Solution'&& (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight 
                    ||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS ||comp.name===Redemption_COMPONENT_NAMES.AccessoryMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) ){  //EDGE-148662               			
                    populatebasketAmountCommon(comp);
                    populatebasketAmountforSavedCommon(comp);
                }
                else if(comp.name === componentName && basketChangeType === 'Change Solution'&&(comp.name === Redemption_COMPONENT_NAMES.DevicesMTS
                    ||comp.name===Redemption_COMPONENT_NAMES.AccessoryMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) ){  //EDGE-148662
                    populatebasketAmountforCancelCommon(comp);
                }
            });
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true);
    },
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : checkConfigurationStatus
     * Invoked When: before saving the solution
     * Description : Check the configuration status and mark it valid or invalid on the basis of that
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    checkConfigurationStatus: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/ (product.name === Redemption_COMPONENT_NAMES.DOPsolution || product.name === Redemption_COMPONENT_NAMES.NGUC||
            product.name === Redemption_COMPONENT_NAMES.enterpriseMobility || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.deviceOutRight ||comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {  //EDGE-148662            			
                            checkConfigurationStatusCommon(comp);                        
                    }
                    if(comp.name === Redemption_COMPONENT_NAMES.mobileSubscription){
                        checkConfigurationStatusCommon(comp);
                        if (comp.relatedComponents && Object.values(comp.relatedComponents).length > 0) {
                            Object.values(comp.relatedComponents).forEach((relatedcomp) => {
                                checkConfigurationStatusCommon(relatedcomp); 
                            });
                        }
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return  Promise.resolve(true);
    },  
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : checkConfigurationStatusforAccessory
     * Invoked When: before saving the solution
     * Description : Check the configuration status and mark it valid or invalid on the basis of that
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
    checkConfigurationStatusforAccessory: async function() 
    {
        //CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/  (product.name === Redemption_COMPONENT_NAMES.NGUC)) {
            if (product.components && Object.values(product.components).length > 0) {
                var mobSubsConfigGUID = "";
                Object.values(product.components).forEach((comp) => {
                    if(comp.name===Redemption_COMPONENT_NAMES.AccessoryMTS){
                        checkConfigurationStatusCommon(comp);
                    }
                });		
            }
        }
        // }).then(
        //     () => Promise.resolve(true)
        // );
        return Promise.resolve(true);
    },
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketforCancelCMPScenario
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
    populatebasketAmountforCancelCMP: async function() {
        let updateConfigMap = {};
        if (basketChangeType !== 'Change Solution') {
            return;
        }
        let product = await CS.SM.getActiveSolution();
        if (/*product.type &&*/ product.name===Redemption_COMPONENT_NAMES.enterpriseMobility) {
            if (product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.mobileSubscription) {  
                        populatebasketAmountforCancellationCMP(comp); 
                    }
                });
            }
        }
        return Promise.resolve(true);   
    },    
 /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketforModifyCMPScenario
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
    populatebasketAmountforModifyCMP: async function() {
        let updateConfigMap = {};
        var parentConfigGUID="";
        var parentComponentName="";
        if (basketChangeType !== 'Change Solution') {
            return;
        }
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution();
        if (product && /*product.type &&*/ product.name===Redemption_COMPONENT_NAMES.enterpriseMobility) {
            if (product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.mobileSubscription) { 
                        if (comp.relatedComponents && Object.values(comp.relatedComponents).length > 0) {
                            Object.values(comp.relatedComponents).forEach((relatedcomp) => {
                            populatebasketAmountforModCMP(relatedcomp); 
                        });
                        }
                    }
                });
            }
        }
        //});
        return Promise.resolve(true);
    },    
     /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketforCancelScenario
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
    populatebasketAmountforCancel: async function() {
        let updateConfigMap = {};
        if (basketChangeType !== 'Change Solution') {
            return;
        }
        //CS.SM.getActiveSolution().then((product) => {
        let product = await CS.SM.getActiveSolution(); // Spring 20
        if (product && /*product.type &&*/ (product.name===Redemption_COMPONENT_NAMES.NGUC || Redemption_COMPONENT_NAMES.NextGenEM)) { //EDGE-148662
            if (product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.DevicesMTS || Redemption_COMPONENT_NAMES.nextGenEM_Device) {  //EDGE-148662           			
                        populatebasketAmountforCancelCommon(comp);                        
                    }
                });
            }
        }
        //});
        return Promise.resolve(true);
    },
 /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketforCancelAccessoryScenario
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : it allows to edit the saved configuration
     * Parameters  : configuration guid or left empty if doing for all configs
 **************************************************************************************/
    populatebasketAmountforCancelAccessory: async function() {
        let updateConfigMap = {};
        if (basketChangeType !== 'Change Solution') {
            return;
        }
        //CS.SM.getActiveSolution().then((product) => {
        // Spring 20
        let product = await CS.SM.getActiveSolution();
        if (/*product.type &&*/ (product.name===Redemption_COMPONENT_NAMES.NGUC)) {
            if (product && product.components && Object.values(product.components).length > 0) {
                Object.values(product.components).forEach((comp) => {
                    if (comp.name === Redemption_COMPONENT_NAMES.AccessoryMTS) {            			
                        populatebasketAmountforCancelCommon(comp);                        
                    }
                });
            }
        }
        //});
        return Promise.resolve(true);
    },
}
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : checkConfigurationStatusforCommon
     * Invoked When: before saving the solution
     * Description : Check the configuration status and mark it valid or invalid on the basis of that
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/
     function checkConfigurationStatusCommon(comp) {
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        // Spring 20
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                var checkonefund=false;
                mobSubsConfigGUID = subsConfig.guid;				
                var configStatus = subsConfig.status;
                    if(configStatus===false)
                    {
                        checkonefund=true;
                    }else
                    {
                        checkonefund=false;
                    }
                if(mobSubsConfigGUID !==""){
                    updateConfigMap[mobSubsConfigGUID] = [
                        {
                        name: 'CheckOneFund',
                        // value: {
                            value: checkonefund,
                            displayValue: checkonefund
                        // }
                    }
                    ];
                    //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true);  
                    // Spring 20
                    //const config = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap, true); 
                    let keys = Object.keys(updateConfigMap);
                    var complock = comp.commercialLock;
                    if (complock)
                        comp.lock('Commercial', false);

                    for (let i = 0; i < keys.length; i++) {
                        
                        await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                    if (complock) {
                        comp.lock('Commercial', true);
                    }
                }
            });	
        }
     }
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforCancelCMP
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : Populate the values in Subscription level
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/  
     function populatebasketAmountforCancellationCMP(comp) {
		let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        var mobSubsConfigRelatedGUID="";
		if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
			Object.values(comp.schema.configurations).forEach((subsConfig) => {
				var fundRedeemed=0,
				netPriceIncGST=0,
				etc=0,
				debitFundCheck=false,
				quant=0,
				netPriceExcGST=0,
				totalcharge=0,
				custredeem=0,
				changeDeviceType='';
				mobSubsConfigGUID = subsConfig.guid;
				var changeType = Object.values(subsConfig.attributes).filter(att => { 
					return att.name === "ChangeType"
				});
				if(changeType[0].displayValue==='Cancel'){
					if (subsConfig.relatedProductList && Object.values(subsConfig.relatedProductList).length > 0) {
						Object.values(subsConfig.relatedProductList).forEach((relatedcomp) => {
							if (relatedcomp.schema && relatedcomp.schema.configurations && Object.values(relatedcomp.schema.configurations).length > 0) {
								Object.values(relatedcomp.schema.configurations).forEach(async (relatedconfig) => {
									mobSubsConfigRelatedGUID = relatedconfig.guid;
									changeDeviceType = Object.values(relatedconfig.attributes).filter(att => { return att.name === "ChangeTypeDevice"});		
									var earlyTC = Object.values(subsConfig.attributes).filter(att => { return att.name === "EarlyTerminationCharge"});
									if(earlyTC && earlyTC.length>0 && earlyTC[0].displayValue && earlyTC[0].displayValue !== undefined && earlyTC[0].displayValue !== "")
										etc = parseFloat(earlyTC[0].displayValue).toFixed(2);
									var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity"});
									if(quantity && quantity.length>0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
										quant = Math.trunc(quantity[0].displayValue);
									var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
									if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "")
										fundRedeemed = parseFloat(RedeemFund[0].displayValue);
										fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
									var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment"});
										var updateMap=[];
										if(taxtreatment && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="GST Applicable")
										{
											totalcharge = parseFloat(etc * 1.1).toFixed(2);
											if(quant!==0){
												netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
											}else
											{
												netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
											}
												netPriceExcGST=parseFloat(netPriceIncGST/1.1).toFixed(2);
												updateMap[mobSubsConfigGUID] = [{
													name: "OneOffChargeGST",
													//  value: {
														 label: 'Balance Due On Device (Inc GST)',
														 value:totalcharge,
														 displayValue : totalcharge
													// }
												}];
												updateMap[mobSubsConfigRelatedGUID] = [{
													name: "OneOffChargeGST",
													//  value: {
														 label: 'Balance Due On Device (Inc GST)',
														 value:totalcharge,
														 displayValue : totalcharge
													// }
												}];
										}
										else if(taxtreatment && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="TAX Exempt")
										{
                                        totalcharge = parseFloat(etc * 1).toFixed(2);
                                        if(quant!==0){
                                        netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                                        }
                                        else
                                        {
                                            netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
                                        }
                                        netPriceExcGST=parseFloat(netPriceIncGST/1).toFixed(2);
                                        updateMap[mobSubsConfigGUID] = [{
                                                name: "OneOffChargeGST",
                                                //  value: {
                                                    showInUi: false,
                                                    label: 'Balance Due On Device (Inc GST)',
                                                    value:'NA',
                                                    displayValue : 'NA'
                                                // }
                                            }];
                                                updateMap[mobSubsConfigRelatedGUID] = [{
                                                name: "OneOffChargeGST",
                                                //  value: {
                                                    showInUi: false,
                                                    label: 'Balance Due On Device (Inc GST)',
                                                    value:'NA',
                                                    displayValue : 'NA'
                                                // }
                                            }];
                                        }

                                        //const config1 = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateMap ,true );
                                        let keys = Object.keys(updateMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                                        }
                        
										//CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
										if(quant!==0){
											custredeem= totalcharge*quant;
										}                       
										else{
											custredeem=totalcharge;
										}
										if(fundRedeemed > custredeem){
											debitFundCheck=true;
										}
										else if(fundRedeemed<0){
                                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
                                            cnfg.status = false; 
                                            cnfg.statusMessage = 'Please Put the Valid Amount'; 
											//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
											return Promise.resolve(false);
										}
									if(!debitFundCheck && fundRedeemed>=0){
										basketRedemp= window.basket + fundRedeemed;
										window.basket=basketRedemp;
										if((currentFundBalance - basketRedemp)<0)
										{
											basketRedemp=window.basket - fundRedeemed;
											netPriceIncGST = totalcharge;
											//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
											return Promise.resolve(false);
										}
										else
										{
                                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
                                            cnfg.status = true; 
											//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
											window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
										}
									}
									else
									{
                                        netPriceIncGST = totalcharge;
                                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
                                        cnfg.status = false; 
                                        cnfg.statusMessage = 'You can not redeem amount greater than Balance Due and OneFund Balance'; 
									    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Balance Due and OneFund Balance');
										return Promise.resolve(false);
                                    }
                                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID);
                                    cnfg.status = true; 
									//CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
									window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
									if(mobSubsConfigGUID !=="" && mobSubsConfigRelatedGUID !==""){
										updateConfigMap[mobSubsConfigGUID] = [
										   {
											name: 'BasketRedemptionAmount',
											// value: {
												value: window.basket,
												displayValue: window.basket
											// }
										},{
											name: 'TotalFundAvailable',
											// value: {
												value: currentFundBalance,
												displayValue: currentFundBalance
											// }
										},{
											name: 'FundAvailable',
											// value: {
												value: deductBalanceConfig,
												displayValue: deductBalanceConfig
											// }
										},{
											name: 'NetPriceIncGST',
											// value: {
												value: netPriceIncGST,
												displayValue: netPriceIncGST
											// }
										},{
											name: 'NetPriceExcGST',
											// value: {
													value: netPriceExcGST,
													displayValue: netPriceExcGST
												}
											// }
										];
										if(changeDeviceType[0].displayValue==='PayOut'){
											updateConfigMap[mobSubsConfigRelatedGUID] = [
											   {
												name: 'BasketRedemptionAmount',
												// value: {
													value: window.basket,
													displayValue: window.basket
												// }
											},{
												name: 'RedeemFund',
												// value: {
													value: fundRedeemed,
													displayValue: fundRedeemed
												// }
											},{
												name: 'TotalFundAvailable',
												// value: {
													value: currentFundBalance,
													displayValue: currentFundBalance
												// }
											},{
												name: 'FundAvailable',
												// value: {
													value: deductBalanceConfig,
													displayValue: deductBalanceConfig
												// }
											},{
												name: 'NetPriceIncGST',
												// value: {
													value: netPriceIncGST,
													displayValue: netPriceIncGST
												// }
											},{
												name: 'NetPriceExcGST',
												// value: {
														value: netPriceExcGST,
														displayValue: netPriceExcGST
													}
												// }
											];
                                        }
                                        //const config = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap ,true ); 
                                        let keys = Object.keys(updateConfigMap);
                                        for (let i = 0; i < keys.length; i++) {
                                            await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
                                        }
                                        //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true);   
									}    
								});
							}
						});
					}
				}                      
            });  
        }
    }
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforModCMP
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : Populate the values in Subscription level
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/  
    function populatebasketAmountforModCMP(comp) {
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                var fundRedeemed=0,netPriceIncGST=0,etc=0,debitFundCheck=false,quant=0,netPriceExcGST=0,totalcharge=0,custredeem=0;
                mobSubsConfigGUID = subsConfig.guid;				
                var changeDeviceType = Object.values(subsConfig.attributes).filter(att => { return att.name === "ChangeTypeDevice"});
                if(changeDeviceType[0].displayValue ==='PayOut') {
                    var earlyTC = Object.values(subsConfig.attributes).filter(att => { return att.name === "EarlyTerminationCharge"});
                    if(earlyTC && earlyTC.length>0 && earlyTC[0].displayValue && earlyTC[0].displayValue !== undefined && earlyTC[0].displayValue !== "")
                        etc = parseFloat(earlyTC[0].displayValue).toFixed(2);
                    var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity"});
                    if(quantity && quantity.length>0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
                        quant = Math.trunc(quantity[0].displayValue);
                    var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                    if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "")
                        fundRedeemed = parseFloat(RedeemFund[0].displayValue);
                        fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                    var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment"});
                    {
                        var updateMap=[];
                        if(taxtreatment && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="GST Applicable")
                        {
                            totalcharge = parseFloat(etc * 1.1).toFixed(2);
                            if(quant!==0){
                                netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                            }
                            else
                            {
                                netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
                            }
                            netPriceExcGST=parseFloat(netPriceIncGST/1.1).toFixed(2);
                            updateMap[mobSubsConfigGUID] = [{
                                name: "OneOffChargeGST",
                                    // value: {
                                    label: 'Balance Due On Device (Inc GST)',
                                    value:totalcharge,
                                    displayValue : totalcharge
                                // }
                            }];
                        }
                        else if(taxtreatment && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="TAX Exempt")
                        {
                            totalcharge = parseFloat(etc * 1).toFixed(2);
                            if(quant!==0){
                                netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                            }
                            else
                            {
                                netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
                            }
                            netPriceExcGST=parseFloat(netPriceIncGST/1).toFixed(2);
                            updateMap[mobSubsConfigGUID] = [{
                                name: "OneOffChargeGST",
                                // value: {
                                showInUi: false,
                                label: 'Balance Due On Device (Inc GST)',
                                value:'NA',
                                displayValue : 'NA'
                                // }
                            }];
                        }
                        //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        //const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateMap, true); 
                        let keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                        }
                    }
                    if(quant!==0){
                        custredeem= totalcharge*quant;
                    }                       
                    else
                    {
                        custredeem=totalcharge;
                    }
                    if(fundRedeemed > custredeem){
                        debitFundCheck=true;
                    }
                    else if(fundRedeemed<0){
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'Please Put the Valid Amount';
                        return Promise.resolve(false);
                    }
                    if(!debitFundCheck && fundRedeemed>=0){
                        basketRedemp= window.basket + fundRedeemed;
                        window.basket=basketRedemp;
                        if((currentFundBalance - basketRedemp)<0)
                        {
                            basketRedemp=window.basket - fundRedeemed;
                            netPriceIncGST = totalcharge;
                            //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                            return Promise.resolve(false);
                        }
                        else
                        {
                            //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                            cnfg.status = true;
                            window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                        }
                }
                else
                {
                    netPriceIncGST = totalcharge;
                    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Balance Due and OneFund Balance');
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = false;
                    cnfg.statusMessage = 'You can not redeem amount greater than Balance Due and OneFund Balance';
                    return Promise.resolve(false);
                }
                //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                cnfg.status = true;

                window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                if(mobSubsConfigGUID !==""){
                    updateConfigMap[mobSubsConfigGUID] = [
                        {
                        name: 'BasketRedemptionAmount',
                        // value: {
                            value: window.basket,
                            displayValue: window.basket
                        // }
                    },{
                        name: 'TotalFundAvailable',
                        // value: {
                            value: currentFundBalance,
                            displayValue: currentFundBalance
                        // }
                    },{
                        name: 'FundAvailable',
                        // value: {
                            value: deductBalanceConfig,
                            displayValue: deductBalanceConfig
                        // }
                    },{
                        name: 'NetPriceIncGST',
                        // value: {
                            value: netPriceIncGST,
                            displayValue: netPriceIncGST
                        // }
                    },{
                        name: 'NetPriceExcGST',
                        // value: {
                                value: netPriceExcGST,
                                displayValue: netPriceExcGST
                            // }
                        }
                    ];
                    //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true); 
                    //const cnfg = await comp.updateConfigurationAttribute(comp.configuration.guid, updateConfigMap, true); 
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
                    }
                }    
                }   
            });
        }
    }
      /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforCancelCommon
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : Populate the values in Subscription level
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/  
     function populatebasketAmountforCancelCommon(comp) {
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                var fundRedeemed=0,netPriceIncGST=0,etc=0,debitFundCheck=false,quant=0,netPriceExcGST=0,totalcharge=0,custredeem=0;
                mobSubsConfigGUID = subsConfig.guid;				
                var ChangeType = Object.values(subsConfig.attributes).filter(att =>{return att.name === 'ChangeType'});
                if(ChangeType && ChangeType[0] && (ChangeType[0].value==='Cancel' || ChangeType[0].value==='PayOut')){
                var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded"});
                var earlyTC = Object.values(subsConfig.attributes).filter(att => { return att.name === "EarlyTerminationCharge"});
                if(earlyTC && earlyTC.length>0 && earlyTC[0].displayValue && earlyTC[0].displayValue !== undefined && earlyTC[0].displayValue !== "")
                etc = parseFloat(earlyTC[0].displayValue).toFixed(2);
                var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity"});
                if(quantity && quantity.length>0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
                quant = Math.trunc(quantity[0].displayValue);
                var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "")
                fundRedeemed = parseFloat(RedeemFund[0].displayValue);
                fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment"});
                var updateMap=[];
                if(taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="GST Applicable")
                {
                    totalcharge = parseFloat(etc * 1.1).toFixed(2);
                    if(quant!==0){
                    netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                    }
                    else
                    {
                        netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
                    }
                    netPriceExcGST=parseFloat(netPriceIncGST/1.1).toFixed(2);
                    updateMap[mobSubsConfigGUID] = [{
                            name: "OneOffChargeGST",
                                // value: {
                                    label: 'Balance Due On Device (Inc GST)',
                                    value:totalcharge,
                                    displayValue : totalcharge
                            // }
                        }];
                }
                else if(taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue && taxtreatment[0].displayValue !== undefined && taxtreatment[0].displayValue !== "" && taxtreatment[0].displayValue ==="TAX Exempt")
                {
                    totalcharge = parseFloat(etc * 1).toFixed(2);
                    if(quant!==0){
                    netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                    }
                    else
                    {
                        netPriceIncGST = parseFloat((totalcharge)- (fundRedeemed)).toFixed(2);
                    }
                    netPriceExcGST=parseFloat(netPriceIncGST/1).toFixed(2);
                    updateMap[mobSubsConfigGUID] = [{
                            name: "OneOffChargeGST",
                                // value: {
                                showInUi: false,
                                label: 'Balance Due On Device (Inc GST)',
                                value:'NA',
                                displayValue : 'NA'
                            // }
                        }];
                }
                //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                // Spring 20
                //const cnfg = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateMap, true); 
                let keys = Object.keys(updateMap);
                for (let i = 0; i < keys.length; i++) {
                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                }
                if(quant!==0){
                    custredeem= totalcharge*quant;
                }                       
                else
                {
                    custredeem=totalcharge;
                }
                if(fundRedeemed > custredeem){
                    debitFundCheck=true;
                }
                else if(fundRedeemed<0){
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
                        // Spring 20
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'Please Put the Valid Amount';
                        return Promise.resolve(false);
                }
                if(!debitFundCheck && fundRedeemed>=0){
                    basketRedemp= window.basket + fundRedeemed;
                    window.basket=basketRedemp;
                    if((currentFundBalance - basketRedemp)<0)
                    {
                        basketRedemp=window.basket - fundRedeemed;
                        netPriceIncGST = totalcharge;
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                        return Promise.resolve(false);
                    }
                    else
                    {
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                        window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                    }
                }
                else
                {
                    netPriceIncGST = totalcharge;
                    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Balance Due and OneFund Balance');
                    // Spring 20
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = false;
                    cnfg.statusMessage = 'You can not redeem amount greater than Balance Due and OneFund Balance';
                    return Promise.resolve(false);
                }
                if(redeemcheckNeeded[0] && (redeemcheckNeeded[0].value=== false || redeemcheckNeeded[0].value==='false' ))
                {
                    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = true;
                }
                window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                if(mobSubsConfigGUID !==""){
                    updateConfigMap[mobSubsConfigGUID] = [
                        {
                        name: 'BasketRedemptionAmount',
                        // value: {
                            value: window.basket,
                            displayValue: window.basket
                        // }
                    },{
                        name: 'TotalFundAvailable',
                        // value: {
                            value: currentFundBalance,
                            displayValue: currentFundBalance
                        // }
                    },{
                        name: 'FundAvailable',
                        // value: {
                            value: deductBalanceConfig,
                            displayValue: deductBalanceConfig
                        // }
                    },{
                        name: 'NetPriceIncGST',
                        // value: {
                            value: netPriceIncGST,
                            displayValue: netPriceIncGST
                        // }
                    },{
                        name: 'NetPriceExcGST',
                        // value: {
                                value: netPriceExcGST,
                                displayValue: netPriceExcGST
                            // }
                        }
                    ];
                    //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true); 
                    // Spring 20
                    //const cnfg  = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap, true); 
                    let keys = Object.keys(updateConfigMap);
                    for (let i = 0; i < keys.length; i++) {
                        await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
                    }
                }    
            }
                // }   
            });
        }
     }
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountforSavedCommon
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : Populate the values in Subscription level
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/  
     function populatebasketAmountforSavedCommon(comp) {
        if (basketChangeType === 'Change Solution') {
            return;
        }
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        var totalfundRedeemed=0; //EDGE-150132 added  part by Romil
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
                if(subsConfig.id && subsConfig.id!=='' && subsConfig.id!==null) { 
                var fundRedeemed=0,netPriceIncGST=0,oneOff=0,debitFundCheck=false,quant=0,netPriceExcGST=0,totalcharge=0;
                mobSubsConfigGUID = subsConfig.guid;				
                var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded"});
                var totalfundAvailable = Object.values(subsConfig.attributes).filter(att => { return att.name === "TotalFundAvailable"});
                var onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "OneOffCharge"});
                if(onceOffCharge.length>0)
                {
                    if(onceOffCharge && onceOffCharge.length>0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
                    oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
                }
                else
                {
                    onceOffCharge=Object.values(subsConfig.attributes).filter(att => { return att.name === "OC"});
                    if(onceOffCharge && onceOffCharge.length>0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
                    oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
                }
                var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity"});
                    if(quantity && quantity.length>0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
                    quant = Math.trunc(quantity[0].displayValue);
                var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                    if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "")
                    fundRedeemed = parseFloat(RedeemFund[0].displayValue);
                    fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                totalfundRedeemed=totalfundRedeemed+fundRedeemed;//EDGE-150132 added  part by Romil
                var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment"});
                var updateMap=[];
                if(taxtreatment&& taxtreatment[0] && taxtreatment[0].displayValue =="GST Applicable")
                {
                    totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
                    netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                    netPriceExcGST=parseFloat(netPriceIncGST/1.1).toFixed(2);
                    updateMap[mobSubsConfigGUID] = [{
                            name: "OneOffChargeGST",
                                // value: {
                                showInUi: true,
                                value:totalcharge,
                                displayValue : totalcharge
                            // }
                        }];
                }
                else if(taxtreatment && taxtreatment[0] && taxtreatment[0].displayValue =="TAX Exempt")
                {
                    totalcharge = parseFloat(oneOff * 1).toFixed(2);
                    netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                    netPriceExcGST=parseFloat(netPriceIncGST/1).toFixed(2);
                    updateMap[mobSubsConfigGUID] = [{
                            name: "OneOffChargeGST",
                                // value: {
                                showInUi: false,
                                value:'NA',
                                displayValue : 'NA'
                            // }
                        }];
                }
                //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                // Spring 20
                //const cnfg = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateMap, true); 
                let keys = Object.keys(updateMap);
                var complock = comp.commercialLock;
                if (complock)
                    comp.lock('Commercial', false);

                for (let i = 0; i < keys.length; i++) {                   

                    await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true);
                }
                if (complock) {
                    comp.lock('Commercial', true);
                }
                if(fundRedeemed > (totalcharge*quant)){
                    debitFundCheck=true;
                }
                /*else if(fundRedeemed>totalfundAvailable[0].displayValue||totalfundRedeemed>totalfundAvailable[0].displayValue){//EDGE-150132 added OR part by Romil
                    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                    // Spring 20
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = false;
                    cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
                    return Promise.resolve(false);
                }*/		
                else if(fundRedeemed<0){
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
                        // Spring 20
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'Please Put the Valid Amount';
                        return Promise.resolve(false);
                }
                if(!debitFundCheck && fundRedeemed>=0){
                    basketRedemp= window.basket + fundRedeemed;
                    window.basket=basketRedemp;
                    if((currentFundBalance - basketRedemp)<0)
                    {
                        basketRedemp=window.basket - fundRedeemed;
                        netPriceIncGST = totalcharge;
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
                        return Promise.resolve(false);
                    }
                    else
                    {
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                        window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                    }
                }
                else
                {
                    netPriceIncGST = totalcharge;
                    //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                    // Spring 20
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = false;
                    cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
                    return Promise.resolve(false);
                }
                if(redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value === false || redeemcheckNeeded[0].value ==='false') )
                {
                   // CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                   // Spring 20
                   let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                   cnfg.status = true;
                }
                else{
                    if(fundRedeemed !=0)
                    {
                        //CS.SM.updateConfigurationStatus(comp.name, mobSubsConfigGUID, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                        return Promise.resolve(false);
                    }
                }
                window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                if(mobSubsConfigGUID !==""){
                    updateConfigMap[mobSubsConfigGUID] = [
                        {
                        name: 'BasketRedemptionAmount',
                        // value: {
                            value: window.basket,
                            displayValue: window.basket
                        // }
                    },{
                        name: 'TotalFundAvailable',
                        // value: {
                            value: currentFundBalance,
                            displayValue: currentFundBalance
                        // }
                    },{
                        name: 'FundAvailable',
                        // value: {
                            value: deductBalanceConfig,
                            displayValue: deductBalanceConfig
                        // }
                    },{
                        name: 'NetPriceIncGST',
                        // value: {
                            value: netPriceIncGST,
                            displayValue: netPriceIncGST
                        // }
                    },{
                        name: 'NetPriceExcGST',
                        // value: {
                                value: netPriceExcGST,
                                displayValue: netPriceExcGST
                            // }
                        }
                    ];
                    //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true);
                    // Spring 20
                    //const cnfg = await comp.updateConfigurationAttribute(mobSubsConfigGUID, updateConfigMap, true); 
                    let keys = Object.keys(updateConfigMap);
                    var complock = comp.commercialLock;
                    if (complock)
                        comp.lock('Commercial', false);
                        
                    for (let i = 0; i < keys.length; i++) {
                        
                        await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true);
                    }
                    if (complock) {
                        comp.lock('Commercial', true);
                    }
                    //CS.SM.updateConfigurationStatus(comp.name,updateConfigMap,true);
                    let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                    cnfg.status = true;
                    return Promise.resolve(true);
                }
            }
        });
    }
    }   
    /**************************************************************************************
     * Author	   : Romil Anand
     * Method Name : populatebasketAmountCommon
     * Invoked When: attribute update,before and on loading of saving the solution
     * Description : Populate the values in Subscription level
     * Parameters  : configuration guid or left empty if doing for all configs
     **************************************************************************************/  
     function populatebasketAmountCommon(comp) {
        if (basketChangeType === 'Change Solution') {
            return;
        }
        let updateConfigMap = {};
        var mobSubsConfigGUID = "";
        if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0 ) {
            Object.values(comp.schema.configurations).forEach(async (subsConfig) => {
            //if((((subsConfig.configurationName.includes('Device'))||subsConfig.configurationName.includes('Accessory'))&& (!subsConfig.configurationName.includes('Handset')) &&(!subsConfig.configurationName.includes('IAD')))) {  
            if(!subsConfig.id || subsConfig.id==='' || subsConfig.id===null) { 
                var fundRedeemed=0,netPriceIncGST=0,oneOff=0,debitFundCheck=false,quant=0,netPriceExcGST=0,totalcharge=0;
                mobSubsConfigGUID = subsConfig.guid;				
                var redeemcheckNeeded = Object.values(subsConfig.attributes).filter(att => { return att.name === "IsRedeemFundCheckNeeded"});
                var onceOffCharge = Object.values(subsConfig.attributes).filter(att => { return att.name === "OneOffCharge"});
                if(onceOffCharge.length>0)
                {
                    if(onceOffCharge && onceOffCharge.length>0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
                    oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
                }
                else
                {
                    onceOffCharge=Object.values(subsConfig.attributes).filter(att => { return att.name === "OC"});
                    if(onceOffCharge && onceOffCharge.length>0 && onceOffCharge[0].displayValue && onceOffCharge[0].displayValue !== undefined && onceOffCharge[0].displayValue !== "")
                    oneOff = parseFloat(onceOffCharge[0].displayValue).toFixed(2);
                }
                var quantity = Object.values(subsConfig.attributes).filter(att => { return att.name === "Quantity"});
                    if(quantity && quantity.length>0 && quantity[0].displayValue && quantity[0].displayValue !== undefined && quantity[0].displayValue !== "")
                    quant = Math.trunc(quantity[0].displayValue);
                var RedeemFund = Object.values(subsConfig.attributes).filter(att => { return att.name === "RedeemFund"});
                    if(RedeemFund && RedeemFund.length>0 && RedeemFund[0].displayValue && RedeemFund[0].displayValue !== undefined && RedeemFund[0].displayValue !== "")
                    fundRedeemed = parseFloat(RedeemFund[0].displayValue);
                    fundRedeemed = Math.round(fundRedeemed * 100) / 100; 
                var taxtreatment = Object.values(subsConfig.attributes).filter(att => { return att.name === "taxTreatment"});
                {
                    var updateMap=[];
                        if(taxtreatment[0] && taxtreatment[0].displayValue ==="GST Applicable")
                        {
                            totalcharge = parseFloat(oneOff * 1.1).toFixed(2);
                            netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                            netPriceExcGST=parseFloat(netPriceIncGST/1.1).toFixed(2);
                            updateMap[mobSubsConfigGUID] = [{
                                    name: "OneOffChargeGST",
                                        // value: {
                                        showInUi: true,
                                        value:totalcharge,
                                        displayValue: totalcharge
                                    // }
                                }];
                        }
                        else if(taxtreatment[0] && taxtreatment[0].displayValue ==="TAX Exempt")
                        {
                            totalcharge = parseFloat(oneOff * 1).toFixed(2);
                            netPriceIncGST = parseFloat((totalcharge*quant)- (fundRedeemed)).toFixed(2);
                            netPriceExcGST=parseFloat(netPriceIncGST/1).toFixed(2);
                            updateMap[mobSubsConfigGUID] = [{
                                    name: "OneOffChargeGST",
                                        // value: {
                                        showInUi: false,
                                        value:'NA',
                                        displayValue : 'NA'
                                    // }
                                }];
                        }
                        //CS.SM.updateConfigurationAttribute(comp.name, updateMap, true);
                        // Spring 20
                        //const cnfg = await comp.updateConfigurationAttribute(subsConfig.guid, updateMap, true); 
                        let keys = Object.keys(updateMap);
                        for (let i = 0; i < keys.length; i++) {
                            await comp.updateConfigurationAttribute(keys[i], updateMap[keys[i]], true); 
                        }
                    }
                    if(fundRedeemed > (totalcharge*quant)){
                        debitFundCheck=true;
                    }
                    else if(fundRedeemed<0 ){
                            //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'Please Put the Valid Amount');
                            //Spring 20
                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                            cnfg.status = false;
                            cnfg.statusMessage = 'Please Put the Valid Amount';
                            return Promise.resolve(false);
                    }
                    if(!debitFundCheck && fundRedeemed>=0){
                        basketRedemp= window.basket + fundRedeemed;
                        window.basket=basketRedemp;
                        if((currentFundBalance - basketRedemp)<0)
                        {
                            basketRedemp=window.basket - fundRedeemed;
                            netPriceIncGST = totalcharge;
                            //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                            // Spring 20
                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                            cnfg.status = false;
                            cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
                            return Promise.resolve(false);
                        }
                        else
                        {
                            //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                            window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                        }
                    }
                    else
                    {
                        netPriceIncGST = totalcharge;
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,false,'You can not redeem amount greater than Charge amount and OneFund Balance');
                        // Spring 20
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = false;
                        cnfg.statusMessage = 'You can not redeem amount greater than Charge amount and OneFund Balance';
                        return Promise.resolve(false); 
                    }
                    if(redeemcheckNeeded && redeemcheckNeeded[0] && (redeemcheckNeeded[0].value=== false || redeemcheckNeeded[0].value=== 'false' ))
                    {
                        //CS.SM.updateConfigurationStatus(comp.name,mobSubsConfigGUID,true);
                        //Spring 20
                        let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                        cnfg.status = true;
                    }
                    else{
                        if(fundRedeemed !=0)
                        {
                            //CS.SM.updateConfigurationStatus(comp.name, mobSubsConfigGUID, false,'Please Click on "Generate Net Price" to update pricing of items in the basket');
                            let cnfg = await comp.getConfiguration(mobSubsConfigGUID); 
                            cnfg.status = false;
                            cnfg.statusMessage = 'Please Click on "Generate Net Price" to update pricing of items in the basket';
                            return Promise.resolve(false);
                        }
					}
                    window.deductBalanceConfig=parseFloat(currentFundBalance - basketRedemp).toFixed(2);
                    if(mobSubsConfigGUID !==""){
                        updateConfigMap[mobSubsConfigGUID] = [
                            {
                            name: 'BasketRedemptionAmount',
                            // value: {
                                value: window.basket,
                                displayValue: window.basket
                            // }
                            },{
                                name: 'TotalFundAvailable',
                                // value: {
                                    value: currentFundBalance,
                                    displayValue: currentFundBalance
                                // }
                            },{
                                name: 'FundAvailable',
                                // value: {
                                    value: deductBalanceConfig,
                                    displayValue: deductBalanceConfig
                                // }
                            },{
                                name: 'NetPriceIncGST',
                                // value: {
                                    value: netPriceIncGST,
                                    displayValue: netPriceIncGST
                                // }
                            },{
                                name: 'NetPriceExcGST',
                                // value: {
                                        value: netPriceExcGST,
                                        displayValue: netPriceExcGST
                                    }
                                // }
                            ];
                            //CS.SM.updateConfigurationAttribute(comp.name, updateConfigMap, true);
                            // Spring 20
                            // const config = await comp.updateConfigurationAttribute(comp.configuration.guid, updateConfigMap, true); 
                            let keys = Object.keys(updateConfigMap);
                            for (let i = 0; i < keys.length; i++) {
                                await comp.updateConfigurationAttribute(keys[i], updateConfigMap[keys[i]], true); 
                            }
                            return Promise.resolve(true);
                        }
                    }
                });	
            }
        }
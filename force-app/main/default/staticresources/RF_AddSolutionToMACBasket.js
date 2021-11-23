//R34 Generic plugin to check and add mainPc if needed
if (CS.SM.registerPlugin) { 
    if (!CS || !CS.SM) {
    throw Error("Solution Console Api not loaded?");
    }
    window.document.addEventListener('SolutionSetActive', async function(e) {
        console.log('Generic method invoked');
    let solution = e.detail.solution;
    //get main PC
    let mainPc = Object.values(solution.schema.configurations)[0];//safe as there will be only one main pc
    //check if it is MACD and if mainPc has been added to MAC basket
    if (solution.isMACD && !mainPc.isMacBasketEditable()) {
    let basket = await CS.SM.getActiveBasket();
     await basket.addConfigurationsToMACBasket(solution.id,[mainPc.guid]);
    console.log('Main PC was auto-added to MACD basket');
    }
    });
    }
    
    
    

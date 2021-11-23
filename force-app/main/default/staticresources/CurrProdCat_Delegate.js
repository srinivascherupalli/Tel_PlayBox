/*
 * Act as a delegate that will handle the hooks and route it to the corresponding module for further processing
 */
console.log('[CurrProdCat_Delegate] loaded');

const AN_Plugin = {};

AN_Plugin.execute = function(productPlugin) {
	document.addEventListener("click", function(e) {
		console.log('[CurrProdCat_Delegate] addEventListener("click") start...');
		
		try {
			e = e || window.event;
			let target = e.target;
			let text = target.textContent || target.innerText;
		} catch (error) {
			console.log('[CurrProdCat_Delegate] addEventListener("click") exception: ' + error);
		}
		console.log('[CurrProdCat_Delegate] ...end addEventListener("click")');
	}, false);
    let isCeaseSaleFlagOn = ''; //P2OB-11731
	
	window.document.addEventListener("SolutionSetActive", async function (e) {
		console.log('[CurrProdCat_Delegate] addEventListener("SolutionSetActive") start...');
		var retVal = false;
		
		try {
            retVal = AN_IO.solutionSetActive();
        } catch (error) {
            console.log('[CurrProdCat_Delegate] addEventListener("SolutionSetActive") exception: ' + error);
        }
		console.log('[CurrProdCat_Delegate] ...end addEventListener("SolutionSetActive")');
		return Promise.resolve(retVal);
	});
	
	productPlugin.afterConfigurationAdd = async function(componentName, guid) {
		console.log('[CurrProdCat_Delegate] afterConfigurationAdd() start...');
		var retVal = true;
		
		try {
			retVal = AN_UI.afterConfigurationAdd(guid);
		} catch (error) {
			console.log('[CurrProdCat_Delegate] afterConfigurationAdd() exception: ' + error);
		}
		console.log('[CurrProdCat_Delegate] ...end afterConfigurationAdd()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterAttributeUpdated = async function(component, configuration, attribute, oldValueMap) {
		console.log('[CurrProdCat_Delegate] afterAttributeUpdated() start...');
		var retVal = false;
		
		try {
			retVal = AN_UI.afterAttributeUpdated(configuration, attribute, oldValueMap);
		} catch (error) {
			console.log('[CurrProdCat_Delegate] afterAttributeUpdated() exception: ' + error);
		}
		console.log('[CurrProdCat_Delegate] ...end afterAttributeUpdated()');
		return Promise.resolve(retVal);
	};
	
	productPlugin.afterSave = async function(result, configurationsProcessed, saveOnlyAttachment, configurationGuids) {
		console.log('[CurrProdCat_Delegate] afterSave() start...');
		
		try {
			AN_UI.afterSave();
		} catch (error) {
			console.log('[CurrProdCat_Delegate] afterSave() exception: ' + error);
		}
		console.log('[CurrProdCat_Delegate] ...end afterSave()');
	};
};



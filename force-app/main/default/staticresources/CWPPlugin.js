    
    
/**************************************************************************************
 * Author	   : Ramesh Somalagari
 * Method Name : hideOrDisplayAttribute 
 * Invoked When: "Message Bank" filed value is changed. 
 * Description : Hide/Display the attribute based on the showInUi.
 * Parameters  : 
 **************************************************************************************/
    function hideOrDisplayAttribute(guid,componentName,hideAttributeName,showInUi){
		console.log("==>"+guid,componentName,hideAttributeName,showInUi);
        var updateMap = {};
		updateMap[guid] = [{name:hideAttributeName,value: {showInUi: showInUi}}];
        CS.SM.updateConfigurationAttribute(componentName, updateMap, true).then(component => console.log('Hide the attributes in UI', component));
    }

/**************************************************************************************
 * Author	   : Ramesh Somalagari
 * Method Name : initHideOrShowTheAttibute 
 * Invoked When: After Solution loaded.
 * Description : Hide/Display the attribute based on the "Message Bank" field value.
 * Parameters  : NA
 **************************************************************************************/
    function initHideOrShowTheAttibute(){
        CS.SM.getActiveSolution().then((currentSolution) => {
            if (currentSolution.type && currentSolution.name === COMPONENT_NAMES.solution) {
                if (currentSolution.components && currentSolution.components.length > 0) {
                    currentSolution.components.forEach((comp) => {
                        if (comp.name === COMPONENT_NAMES.mobility) {
                           if(comp.schema && comp.schema.configurations){
                                comp.schema.configurations.forEach((config) => {
                                    var guid = config.guid;
                                    config.attributes.forEach((att) => {
                                        if(att.name === COMPONENT_NAMES.mobilityEditableAttributeList[0]){
                                            var showInUi = true;
                                            if(att.displayValue && att.displayValue.toUpperCase() == "VOICE TO TEXT"){
                                                showInUi = false;         
                                            }                                                              
                                            var updateMap = {};
                                            updateMap[guid] = [{name:"MessageBankUnitPrice",value: {showInUi: showInUi}}];
                                            console.log("updateMap :: ", updateMap);  
                                            CS.SM.updateConfigurationAttribute(COMPONENT_NAMES.mobility, updateMap, true).then(component => console.log('Hide the attributes in UI', component));
                                        }
                                    }); 
                            });
                           }
                            
                        }					
                    });
                }			
                
            }
        }).then(
            () => Promise.resolve(true)
        );
    }
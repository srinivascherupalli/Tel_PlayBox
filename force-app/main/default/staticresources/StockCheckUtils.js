/******************************************************************************************
Updates:
1 		RaviTeja			01-June-2020 	EDGE-146972 -adedd postMessageToStockCheck method
2       Aditya              10-June-2020    EDGE-150065 - added for Next Generation Mobility
3       Arinjay             25-July-2020    JSUgrade
5.          Shubhi /samish             28-july-2020    20.12          //EDGE-165013
6.		Sandhya				10-Dec-2020		// INC000094260232 Fix
7.      Shresth Dixit       02-Feb-2021     DPG-3510
*******************/
console.log('Load stockcheck utils');
var ngucVariables = {

    NGUC_OFFER_NAME: 'Adaptive Collaboration',
    NGUC_PROF_SERV_OFFR_NAME: 'Adaptive Collaboration Professional Services',
    NGUC_TENANCY_OFFER_NAME: 'Adaptive Collaboration Tenancy'
};
//List of Solution Names need to consider for Stock Check
var componentnames_Stockcheck = ['Corporate Mobile Plus', ngucVariables.NGUC_OFFER_NAME, 'Connected Workplace', 'Device Outright Purchase', 'Adaptive Mobility'] //INC000094260232 Fix , DIGI-3208
//Map of Solution Names with components to be considered for Stock Check
var devicecomp_Stockcheck = new Map([
    ["Corporate Mobile Plus", ['Mobile Subscription']],
    [ngucVariables.NGUC_OFFER_NAME, ['Devices', 'Accessories']],  // DIGI-3208
    ["Connected Workplace", ['CWP Mobile Subscription']],
    ["Device Outright Purchase", ['Mobile Device']],
    ["Adaptive Mobility", ['Device', 'Accessory']]//Shubhi  //EDGE-165013 //DPG-3510
]);
//List of Attributes to be considered for getting the device type selections
var attribbuteList_Stockcheck = ['PaymentTypeLookup', 'ContractType', 'AccessoryModel'];//DPG-3510

var stockcheckUtils = {
    /*******Start- EDGE-146972--Get the Device details for Stock Check before validate and Save as well******************/
    postMessageToStockCheck: async function (caller, solutionID) {
        console.log('Load stockcheck utils' + caller + solutionID);

        let guidCompMap = {};

        //await CS.SM.getSolutions().then((products) => {
        let currentBasket = await CS.SM.getActiveBasket();
        let products = await currentBasket.getSolutions()
        Object.values(products).forEach((product) => {
            console.log('product.name' + product.name);
            if (componentnames_Stockcheck.includes(product.name)) {
                var deviceComponent = devicecomp_Stockcheck.get(product.name);
                if (product.components && Object.values(product.components).length > 0) {
                    Object.values(product.components).forEach((comp) => {
                        if (deviceComponent.includes(comp.name)) {
                            if (comp.schema && comp.schema.configurations && Object.values(comp.schema.configurations).length > 0) {
                                Object.values(comp.schema.configurations).forEach((config) => {
                                    var guid = config.guid;
                                    let attnameToattMap = {};
                                    Object.values(config.attributes).forEach((att) => {
                                        if (attribbuteList_Stockcheck.includes(att.name)) {
                                            attnameToattMap[att.name] = att;
                                        }
                                    });
                                    guidCompMap[guid] = attnameToattMap;
                                });

                                Object.values(comp.schema.configurations).forEach((product) => {
                                    product.relatedProductList.forEach((relatedConfig) => {
                                        var guid = relatedConfig.guid;
                                        let attnameToattMap = {};
                                        Object.values(relatedConfig.configuration.attributes).forEach((attribute) => {
                                            if (attribbuteList_Stockcheck.includes(attribute.name)) {
                                                attnameToattMap[attribute.name] = attribute;
                                            }
                                        });
                                        guidCompMap[guid] = attnameToattMap;
                                    });
                                })
                            }
                        }
                    });
                }
            }
        });
        //});
        var ifrm = [];
        ifrm = document.getElementsByClassName('frame ng-star-inserted');
        let iframepayload = {
            command: solutionID,
            data: guidCompMap,
            caller: caller,
        };
        if (ifrm.length > 0)
            ifrm[0].contentWindow.postMessage(iframepayload, '*');
    }
    /*********************************************End- EDGE-146972*********************************/
}
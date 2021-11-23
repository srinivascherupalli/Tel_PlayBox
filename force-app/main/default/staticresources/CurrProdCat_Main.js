/*
 * Main plugin; aim to make it as lightweight as possible (esp. if we can skip loading rest of the files)
 */
console.log('[CurrProdCat_Main] loaded');

var AN_COMPONENTS = {
    solution: 'Standard Product Solution',
    StandardProduct: 'StandardProduct'
};

RegisterPluginAdapter.execute(AN_COMPONENTS.solution, 'AN_Plugin');
// Array with lookup product IDs         
    	var relatedProductsIds = new Array( );
    	var lookups = false;
    
    	// Renders lookups controls (Select2 drop down list)
    	var renderLookups = function() {
    		
			if(relatedProductsIds != undefined)
			{
				for (var i = 0; i < relatedProductsIds.length; i++) {
					try{
						CS.InlineEdit.initSll(relatedProductsIds[i]);
						}
					catch (err){
						console.log(err);
					}
				}
			}
    	}
    	
    	var renderTimer = function () {
    		
    		var rel  = document.getElementById('relatedListTableID');
    
    		if (rel && lookups && $('#relatedListTableID div[class*="select2-container"]').length == 0 && relatedProductsIds) {
    
    			renderLookups();
     
    			/*if (!(CS.rulesTimer == undefined && CS.lookupQueriesAreQueued() == false)) {
    			
    				console.log('Debug: Clearing rtm');
    				clearInterval(rtm);
    			}*/
    		}
    	}
    	
    	var rtm = setInterval(renderTimer, 200);
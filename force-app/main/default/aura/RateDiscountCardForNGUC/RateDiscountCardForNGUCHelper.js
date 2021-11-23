({
	createJson : function(component){
        var json_Data = [];
        var jsonsio_Data = [];
        var existingJson;
        if(component.get("v.jsonsoi"))
        	existingJson = JSON.parse(component.get("v.jsonsoi"));
        var isNewbasket = component.get("v.isNewBasket");
        var rateCardMapVal = component.get("v.RateCardMap");
		
		rateCardMapVal.forEach(function(rateCardVal){
            var wrapSIO = {};
            if(existingJson){
                existingJson.forEach(function(item){
                    if(rateCardVal.value[0].rateCardCode == item['rateGroupIdentifier'])
                    	wrapSIO = item;
                });
            }
            console.log('wrapSIO--',wrapSIO);
            	var isDisabled =false;
                wrapSIO.name = rateCardVal.key;
                    if(isNewbasket){
                        wrapSIO.expectedSIO = (rateCardVal.value[0].expectedSIO != null?rateCardVal.value[0].expectedSIO:0);
                    }else{
                        wrapSIO.actualSIO = (rateCardVal.value[0].actualSIO!=null?rateCardVal.value[0].actualSIO:0);
                    	if(wrapSIO.previousRate == null || wrapSIO.previousRate == 0)
							wrapSIO.previousRate = wrapSIO.currentRate;
                    }
                        
                    rateCardVal.value.forEach(function(Value){
                    	wrapSIO.rateCardId = Value.rateCardId;
                        wrapSIO.rateGroupIdentifier = Value.rateCardCode;
                        wrapSIO.rateCardName = Value.rateCardName;
                        if(isNewbasket && wrapSIO.expectedSIO >= Value.rangeFrom && wrapSIO.expectedSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        }else if(!isNewbasket && wrapSIO.actualSIO >= Value.rangeFrom && wrapSIO.actualSIO <= Value.rangeTo){
                            wrapSIO.currentRate = parseFloat(Value.recurringCharge);
                        }
                        wrapSIO.previousRate = (wrapSIO.previousRate!=null?wrapSIO.previousRate:0);
                        wrapSIO.currentRate = (wrapSIO.currentRate != null?wrapSIO.currentRate:0);
                        wrapSIO.actualSIO = (wrapSIO.actualSIO != null?wrapSIO.actualSIO:0);
                        if(Value.isSIODisabled)
                            isDisabled = true;
                    });
                      console.log('wrapSIO---',wrapSIO);

                      jsonsio_Data.push(wrapSIO);
                      if(!isDisabled)
                        json_Data.push(wrapSIO);
            		
               
            });
        component.set("v.jsonsoi",JSON.stringify(jsonsio_Data));
        var guid=component.get("v.guid");
        let pageloadPayload={
        	command: 'RateCard' ,
        	data: JSON.stringify(json_Data),
        	caller : "Business Calling",
        	guid : guid
        };
        window.parent.postMessage(pageloadPayload,"*");
	}

})
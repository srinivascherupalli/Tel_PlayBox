/*----------------------------------------------------------
1.		21-Jul-2020		  Laxmi Rahate	  EDGE-154663 Created JS for NG EM
 ------------------------------------------------------------**/
window.onInitOETab["Enterprise Mobility Features"] = function(){
	
	console.log("Enterprise features onInitOETab");
/***
var planType = "";
planType = Utils.getConfigAttributeValue('PlanTypeString' );
console.log ( 'planType ---------',planType);	
	
if (planType === "Enterprise Wireless" || planType ===  "Mobile Broadband" ) {
var updateMapNew = {}
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction", readOnly:false, value : "NA"	});
	updateMapNew[guid].push({name: "msgRestriction", readOnly:false, value : "barMoSms",displayValue : "Bar outgoing SMS"		});


	 CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', window.activeGuid,updateMapNew, true);		
	
}else if (planType === 'Handheld' ) {
	 var updateMapNew = {}
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction",  value : "barNone", displayValue : "No restrictions"	});
	
	updateMapNew[guid].push({name: "msgRestriction",  value : "barNone", displayValue : "No message barring"	});
	
	 CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility',  window.activeGuid,updateMapNew, true);			
	
}	
**/
	
};
window.onInitOESchema["Enterprise Mobility Features"] = async function(guid){
  

  console.log("Mobility Features onInitOESchema", this, guid);
    

/**  
var planType = "";
planType = Utils.getConfigAttributeValue('PlanTypeString' );
console.log ( 'planType ---------',planType);
var configGUID = await OE.getConfigGuidForOEGUID (guid);
console.log ( 'configGUID in NGEMMObFeatures ---------',planType);

/***
if (planType === "Enterprise Wireless"  || planType === "Mobile Broadband" )  {
var updateMapNew = {}
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "dataBarring", value : "barNone" ,displayValue : "No Data Barring" , readOnly:true	});
	await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, true);	
	updateMapNew[guid] = [];
		// Thsi is done beacuse of CS issue - default values arent gettign set unless those are made readonly hence updatign the map with readonly and then again making that editable

	updateMapNew[guid].push({name: "dataBarring", value : "barNone" ,displayValue : "No Data Barring" , readOnly:false	});
	await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, true);	
	
	console.log ( 'dataBarring updated ---- ', updateMapNew);
	
}
**/


/**
if (planType === "Enterprise Wireless" || planType ===  "Mobile Broadband" ) {
var updateMapNew = {}
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction", value : "NA",showInUI:true,readOnly:true	});
	updateMapNew[guid].push({name: "msgRestriction",  value : "barMoSms",displayValue : "Bar outgoing SMS",showInUI:true,readOnly:true		});

	//await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, true);	
		// Thsi is done beacuse of CS issue - default values arent gettign set unless those are made readonly hence updatign the map with readonly and then again making that editable
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction", value : "NA",showInUI:true,readOnly:false	});
	updateMapNew[guid].push({name: "msgRestriction",  value : "barMoSms",displayValue : "Bar outgoing SMS",showInUI:true,readOnly:false		});

	//await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, true);
	console.log ( 'callRestriction updated ---- ', updateMapNew);
	
}else if (planType === 'Handheld' ) {
	 var updateMapNew = {}
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction",  value : "barNone", displayValue : "No restrictions",showInUI:true, readOnly:true	});
	
	updateMapNew[guid].push({name: "msgRestriction",  value : "barNone", displayValue : "No message barring",showInUI:true,readOnly:true	});
	
	//await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, false);	
	// Thsi is done beacuse of CS issue - default values arent gettign set unless those are made readonly hence updatign the map with readonly and then again making that editable

	updateMapNew[guid] = [];
	updateMapNew[guid].push({name: "callRestriction",  value : "barNone", displayValue : "No restrictions",showInUI:true, readOnly:false	});
	
	updateMapNew[guid].push({name: "msgRestriction",  value : "barNone", displayValue : "No message barring",showInUI:true,readOnly:false	});	
	//await CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, false);	
	
	console.log ( 'callRestriction updated for handheld ---- ', updateMapNew);
	
}

**/

//updateMapNew[guid].push({name: "callRestriction", readOnly:true, displayValue : "Please select" , showInUI:false	});
//CS.SM.updateOEConfigurationAttribute('Next Generation Enterprise Mobility', configGUID,updateMapNew, true);		
	
/**if (planType === "Enterprise Wireless" ) {
	
	 if (!updateMapNew[guid])
		updateMapNew[guid] = [];
updateMapNew[guid].push({name: "InternationalRoaming", readOnly:true, value : "No"	});

}



**/


	window.rulesUpdateMap[guid] = [];
	var Rules = [];
	return Rules;
};

window.noPredicate["Enterprise Mobility Features"] = function(guid){


};
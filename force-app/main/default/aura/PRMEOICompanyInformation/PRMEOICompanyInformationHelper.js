({
	 //get Industry Picklist Value
    getIndustryVerticalpicklist: function(component, event) {
        var action = component.get("c.getIndustryVertical");
        console.log("getIndustryVerticalpicklist");
                console.log("getIndustryVerticalpicklist");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                        console.log("SUCCESS");

                var industryMap = [];
                for(var key in result){
                    industryMap.push({key: key, value: result[key]});

                }
                component.set("v.industryMap", industryMap);

            }
        });
        $A.enqueueAction(action);
    },
    getpicklistvalues: function(component, event,Field) {
    var action = component.get("c.getPicklistvalues");
     action.setParams({ "FieldAPIName" : Field });

         
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result'+result);
                var plValues = [];
               
                
                /*for (var i = 0; i < result.length; i++) {
                    plValues.push({
                        label: result[i],
                        value: result[i]
                    });
                }*/
                
                     for(var key in result){
                    	plValues.push({key: key, value: result[key]});
                }
                
                if(Field == 'Partner_categories__c' )
               		 component.set("v.PartnercategoriesList", plValues);
                
                if(Field == 'Source_Info_Telstra_Channel_Partner_prog__c')
                     component.set("v.TCPProgramoptions", plValues);
				
                if(Field == 'Annual_Revenue__c')
                     component.set("v.AnnualRevenueMap", plValues);
            }
        });
        $A.enqueueAction(action);
    
    
},
    validateABN: function(component, event) {
        console.log('validateABN'+component.get("v.leadRec.ABN__c"));
       

        var ABN=component.get("v.leadRec.ABN__c");       
        if(ABN!=undefined){
        component.set("v.spinner",true);
        var action = component.get("c.callABNService");
        
        /*action.setParams({ "sABN" : component.get("v.leadRec.ABN__c"),
                          "leadId": component.get("v.LeadrecordId")});*/
        action.setParams({ "sABN" : component.get("v.leadRec.ABN__c")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state is->'+state);
            if (state === "ERROR") {
                var errors = response.getError()
                        console.log("Error: " + errors[0].message);
                        // Show error message
            }
            console.log('returnvalue->'+response.getReturnValue());
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.spinner",false);
                result=JSON.parse(result);
               // if(result.status=='Active'){
                component.set("v.leadRec.ABN_Registered_Name__c",result.entityName);
                component.set("v.leadRec.Entity_Age_Years__c",result.noOfYrsInBusiness);
                /*if(result.leadStatus = 'Declined'){
                    component.set("v.leadRec.Status",result.leadStatus);
                    component.set("v.leadRec.Declined_Reason__c",result.declineReason);
                }*/
                var businessNames=result.listBusinessName;
 				console.log('businessNames'+businessNames);
                    var businessNamesmap= [];
                console.log('businessNames.length'+businessNames.length);                    
                    if(businessNames.length>1){
                    	businessNamesmap.push({key:'' , value: "- Please Select -"});  
                    
                
                for(var key in businessNames){   
                                        //businessNamesmap.push({key: key, value: businessNames[key]});
										businessNamesmap.push({key: businessNames[key], value: businessNames[key]});
                }  
               
                component.set("v.BusinessnamelistMap", businessNamesmap);  
                        console.log('greater than 1'+businessNamesmap);
                    }
                else{
                    businessNamesmap.push({key: businessNames[0], value: businessNames[0]});
                    component.set("v.leadRec.Company",businessNames[0]);
                    //component.set("v.BusinessnamelistMap",businessNames[0]);
                    console.log('les than 1'+businessNamesmap);
                }
                var numberofyears=component.get("v.leadRec.Entity_Age_Years__c");
                //}
                var appEvent = $A.get("e.c:PRMEOIEvent");
       			 console.log("firing");
        		appEvent.setParams({
            		"ABNResult" : result,
                    "Bnameslist":businessNamesmap
           		 });
        	appEvent.fire();   

            }
        });
            console.log('firing action');
        $A.enqueueAction(action);
    }
    },
    
    //Added by Hawaii for P2OB-8478
    checkCompanyValidation : function(component, event, size){
        var appEvent = $A.get("e.c:PRMEOIEvent");
        if(size==="1-5"){
            component.set('v.IsCompanySizeInValid',true);
            component.set('v.CompanySizeErrorMessage', 'Does not meet company size eligibility criteria');
            appEvent.setParams({
            "IsValidCompanySize" : false
           });
        } else {
            component.set('v.IsCompanySizeInValid',false);
            appEvent.setParams({
            "IsValidCompanySize" : true
           });
        }
        
        appEvent.fire();  
    }
     
})
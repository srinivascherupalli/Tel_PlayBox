({
    // v1.4 method to fetch details of the selected partner lookup
    fetchPartnerDetails :function (component, event, partnerRecordId){
        console.log('HELPER called****'+partnerRecordId);
        var action = component.get("c.returnSelectedPartner");
        action.setParams({
            partnerId : partnerRecordId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var accountInstance = response.getReturnValue(); 
                // If Opportunity Optimization is enabled display new set of messages
                //if(component.get("v.blnOpportunityOptimization")){
                // v1.4 adding logic to check partner principal contact's user is active
                console.log('HELPER account.PartnerPrincipalContact__c**********'+accountInstance.PartnerPrincipalContact__c);
                console.log('HELPER Account_Status__c**********'+accountInstance.Account_Status__c);
                console.log('HELPER Partner_Type__c**********'+accountInstance.Partner_Type__c);
                if(accountInstance.PartnerPrincipalContact__c != undefined){
                    var principalContactId;
                    if(accountInstance.Partner_Type__c == 'Nominate'
                    && accountInstance.Account_Status__c != 'Active'){
                        console.log('HELPER Non onboarded nominate use case******');
                        principalContactId = accountInstance.Primary_Distributor__r.PartnerPrincipalContact__c;
                    }else{
                        console.log('HELPER ***Others Use case***');
                        principalContactId = accountInstance.PartnerPrincipalContact__c;
                    }
                    console.log('HELPER principalContactId******'+principalContactId);
                    var action1 = component.get("c.returnPartnerUser");
                    action1.setParams({
                        partnerPrincipalContactId : principalContactId
                    });

                    action1.setCallback(this, function(response){
                        var state = response.getState();
                        if(state === 'SUCCESS'){
                            var userInstance = response.getReturnValue();
                            console.log('HELPER userInstance*****'+userInstance);
                            if(userInstance == undefined || userInstance == null
                            || (userInstance != undefined && userInstance != null
                            && !userInstance.IsActive)){
                                component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").noPartnerUserErrorMessage); // v1.4
                                component.set("v.saveDisabled",true);
                                //component.set("v.blnOpportunityOptimization",true);
                                console.log('HELPER ***USER RESULT UNDEFINED');
                            }else{
                                console.log('HELPER ***USER RESULT NOT UNDEFINED');
                            }
                        }else if (state === 'ERROR'){
                            console.log('HELPER Something went wrong. Error');
                        }else{
                            console.log('HELPER Something went wrong, Please check with your admin');
                        }
                    });
                    $A.enqueueAction(action1);
                }else{
                    // display ERROR MESSAGE
                    component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").noPartnerUserErrorMessage); // v1.4
                    component.set("v.saveDisabled",true);
                    //component.set("v.blnOpportunityOptimization",true);
                }
                // end of v1.4
                if(component.get("v.blnOpportunityOptimization")){
                    if(accountInstance.Account_Status__c == 'Active'){
                        console.log('HELPER Selected account is ACTIVE**********');
                        component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").onboardedPartnerMessage); // P2OB-4957 - custom setting field to wrapper class
                    }else{
                        // For non onboarded nominate account display Distributor name with whom Opportunity will be shared
                        if(accountInstance.Partner_Type__c == 'Nominate'
                        && accountInstance.Primary_Distributor__c != null
                        && accountInstance.Primary_Distributor__r.Account_Status__c == 'Active'){
                            var nomMsg = component.get("v.objPartnerAutoTagging").nonOnboarderNominateMessage; // P2OB-4957 - custom setting field to wrapper class
                            nomMsg = nomMsg.replace('{!distributorName}',accountInstance.Primary_Distributor__r.Name);
                            component.set("v.OppOptimizationMessage",nomMsg); 
                        }else{
                            component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").nonOnboarderTaggedPartnerMessage); // P2OB-4957 - custom setting field to wrapper class
                            component.set("v.blnNonOnbordedPartnerSuccessMessage",true); // P2OB-5227
                        }
                    }
                }else{
                    // If partner auto tagging is disabled and partner is inactive then display new message
                    console.log('HELPER Opp optimization DISABLED**********'+accountInstance.Account_Status__c);
                    if(accountInstance.Account_Status__c != 'Active'){
                        component.set("v.blnOptOptimizationMessage", true);
                        component.set("v.OppOptimizationMessage",component.get("v.objPartnerAutoTagging").nonOnboarderPartnerErrorMessage); // P2OB-4957 - custom setting field to wrapper class
                        component.set("v.saveDisabled",true);
                    }
                }
            }else if (state === 'ERROR'){
                console.log('HELPER Something went wrong. Error');
            }else{
                console.log('HELPER Something went wrong, Please check with your admin');
            }
        });
        $A.enqueueAction(action);
    },
})
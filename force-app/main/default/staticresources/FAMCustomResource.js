/**********************************************************************************************************
* Author      : Cloud Sense Team
Change Version History
Version No    Author                        Date                 Change Description
1            Adityen Krishnan               27/07/2020           New - FAM Custom Resource
2            Payal Popat                    30/10/2020           EDGE-185605 - Added functionality for Quote

3            Aarathi Iyer                   01/12/2020           EDGE 177928 - Added condition to redirect to partners

4            Vishal Arbune                  15/12/2020           EDGE-186881 - Changes to Deal escalation flow for Partner users for FA as per Final DO

5            Manuga Kale	             18/12/2020           EDGE-188476   partner user should be able to create a Frame Agreement
6            Manish Berad                31/01/2021           EDGE-196353 EDGE-200473 
7            Manish Berad                18/02/2021           EDGE-201623 Auto creation of Deal opportunity for FA Revision on click of FA create new revision button on FA screen.
8            Madhu Gaurav                18/02/2021           EDGE-198838 - Removed activeFrameAgreement["Mark_as_Variation__c"] condition from escalateFunction().																		
9.          Manish Berad                 11/03/2021         EDGE-199307	As a Sales/Partner user when I have created Deal Opportunity, Then 		I MUST capture "Opportunity Primary Contact role" (Validation) while creating a New Frame Agreement		
10.         Vishal Arbune                10/03/2021         EDGE-203940 : <FA Delegation> As a Deal Approver I should be able to Re-score a deal
11          Shashank Jadhav             11/03/2021           EDGE-203808   Changes related to the FundConsole Tab Functionality	
12.         Manuga Kale                  22/03/2021         EDGE-210615 : Defect fix		
13. 		Shivaprasad Patil 		     23/03/2021			EDGE-203808: Changes related Fund Console UI
14.         Mohammed Zeeshan Moulvi		 24/03/2021         EDGE-205103 : Added BOH Quality Check in delegationHierarchy
15.			Shashank Jadhav				 31/03/2021         EDGE-212284 : Defect fix of fund data decimal error
16.			Manish B					 07/04/2021         EDGE-203284 && EDGE-203941
17.         Parmanand Shete				05/04/2021		    EDGE-210317 : Added confirm on quoteRedirection and GenerateContract
18. 		Shivaprasad					21/04/2021			EDGE-203808 : Changes to display Flexi Fund Contribution/Handle warning message when no products
19.			Parmanand Shete				22/04/2021			EDGE-211114	: Added onBeforeSaveFrameAgreement hook and validateFundConsoleCustomData fuction
20. 		Shivaprasad Patil			26/04/2021			EDGE-203818 : Set status of FA to draft on change of Fund Console
21.         Pradeep Mudenur             27/05/2021          EDGE-216677 : For Migration setting FA status and DPR status to Scored on FA save. 
                                                            Setting the Final_Delegation_Outcome to BOH Quality Check
22.		    Parmanand Shete				01/06/2021			EDGE-219118
23.		    Parmanand Shete				24/06/2021			EDGE-220072
22.		    Shivaprasad Patil			24/06/2021			EDGE-225251: <Tech Story>Cosmetic updates to Fund Console
23. 		Shashank Jadhav				24/06/2021			Fixed issue of setFundConsoleCustomData, moved logic to onBeforeSaveFrameAgreement
24. 		Aakil Bhardwaj				24/06/2021			EDGE-220832:Managing fund console availability as per user profile and FA stage
25. 		Shashidhar Kumar			24/06/2021			EDGE-219471: Option to edit contract term per product family in fund console UI
25. 		Shivaprasad					25/06/2021			EDGE-219475: Added Fund Expiry Field(Fund Term) per product family in fund console UI
26. 		Shivaprasad 				09/07/2021 			EDGE-220833: Update JSON when Products are deleted
27. 		Shivaprasad					21/07/2021			EDGE-229289: is Allocated and minimum spent per month is missing out in variation FA
28.         Madhu Gaurav                06/08/2021			DIGI-5250:  changes in validateFundConsoleCustomData method
29.			Shivaprasad					09/08/2021			EDGE-229735: Cosmetic Changes
30.			Parmanand Shete				09/08/2021			DIGI-6147: Custom Confirm implementation
31. 		Shivaprasad       			31/08/2021  		DIGI-2608/14506 :As a Sales or Partner users, the FA escalation recall button should be available  														certain conditions are met.
32.        Manish Berad                 01/09/2021          DIGI-9984: As a Sales or Partner user, I would like the system to warn me if one of the companies cannot be added to the related BSA so that I adhere to the business rules
*************************************************************************************************************/
let opptyData;
let opportunityId;
let accountId;
let queryString;
let FARecId;
let userDetails;
let activeFrameAgreement;
let queueMembers;
let delegationHierarchy = {
    undefined: 1,
    '': 1,
    'Migration': 0, //Added EDGE-186492
    'Partner': 0,   //Added EDGE-186881
    'Account Executive': 1,
    'BOH Quality Check': 1,
    'Sales Specialist': 2,
    'Sales Manager': 3,
    'Sales General Manager': 4,
    'Customized Pricing': 5,
    'No Discount Offerable': 6
};
let enableFundConsole = true; //EDGE-203808-Added enableFundConsole variable to define fund console flow.

window.FAM.subscribe('onFaSelect', data => {
    document.addEventListener('click', async function (e) {
        e = e || window.event;
        var target = e.target || e.srcElement;
        var text = target.textContent || target.innerText;
		
		if(window.FAM.api.hasOwnProperty('getActiveFrameAgreement'))
		{
		activeFrameAgreement = await window.FAM.api.getActiveFrameAgreement();
		}
				
		if(activeFrameAgreement['Final_Delegation_Outcome__c'] === 'Customized Pricing' && activeFrameAgreement["csconta__Status__c"] === "Sent for Approval"){
				if(document.getElementsByClassName('icon-undo').length > 0){
					document.getElementsByClassName('approval-card__body')[0].childNodes[0].style.display = 'none';
            	document.getElementsByClassName('approval-card__body')[0].childNodes[1].style.display = 'none';
				document.getElementsByClassName('icon-undo')[0].parentElement.style.display = 'none';
				}
			} //DIGI-2608/14506
			
        if (text == 'Custom') {
            
            if (((delegationHierarchy[userDetails['Delegation_Role__c']] > delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']]) ||
                !Object.keys(delegationHierarchy).includes(activeFrameAgreement['Final_Delegation_Outcome__c'] || activeFrameAgreement['isPrimary__c '] || activeFrameAgreement['Final_Delegation_Outcome__c'] === 'No Discount Offerable')
            ) && activeFrameAgreement['Final_Delegation_Outcome__c'] !== 'Customized Pricing') {
                //await window.FAM.api.updateFrameAgreement(activeFa.Id, "csconta__Status__c", 'Approved');
                if (document.getElementById('escalate') != undefined)
                    document.getElementById('escalate').style.display = 'none';
            }
            if (delegationHierarchy[userDetails['Delegation_Role__c']] >= delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']] && activeFrameAgreement["csconta__Status__c"] === "Sent for Approval") {
                //await window.FAM.api.updateFrameAgreement(FARecId, "csconta__Status__c", "Sent for Approval");
                if (document.getElementById('approve') != undefined) {
                    if (document.getElementById('approve').style.display == 'block') {
                        document.getElementById('approve').style.display = 'block';
                    }
                }
                if (document.getElementById('reject') != undefined) {
                    if (document.getElementById('reject').style.display == 'block') {
                        document.getElementById('reject').style.display = 'block';
                    }
                }
            } else {
                if (document.getElementById('approve') != undefined)
                    document.getElementById('approve').style.display = 'none';
                if (document.getElementById('reject') != undefined)
                    document.getElementById('reject').style.display = 'none';
            }
        }
    }, false);
    return new Promise(async resolve => {
        queryString = window.location.search;
        let urlParams = new URLSearchParams(queryString);
        opportunityId = urlParams.get('opportunity');
        accountId = urlParams.get('account');
        let opportunityName = urlParams.get('opportunityName');
        FARecId = window.location.href.substring(
            window.location.href.lastIndexOf('/') + 1
        );
        let frameOrigin = urlParams.get('sfdcIFrameOrigin'); // added as a part of EDGE-185605
        activeFrameAgreement = await window.FAM.api.getActiveFrameAgreement();
        var className = 'FAMActionHelper';
        var inputMap = {
            method: 'getUserDetails'
        };

        if(activeFrameAgreement['Final_Delegation_Outcome__c'] === 'Customized Pricing' && activeFrameAgreement["csconta__Status__c"] === "Sent for Approval"){
            if(document.getElementsByClassName('icon-undo').length > 0){
				document.getElementsByClassName('approval-card__body')[0].childNodes[0].style.display = 'none';
            	document.getElementsByClassName('approval-card__body')[0].childNodes[1].style.display = 'none';
                document.getElementsByClassName('icon-undo')[0].parentElement.style.display = 'none';
            }
        } //DIGI-2608/14506
        
        userDetails = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
        userDetails = JSON.parse(userDetails);

        //expect messages from Deal Score
        window.addEventListener('message', handleDealScoreIframeMessage);
        //set opp, will be persisted on user save
        data[0].Opportunity__c = data[0].Opportunity__c || opportunityId; //set only if not already set

        window.FAM.registerMethod('CustomCancel', () => {
            var result = cancelFrameAgreement();
            return Promise.resolve(result);
        });
        //Sync Contract Button EDGE-185053
        window.FAM.registerMethod('CustomContractSync', () => {
            var result = CustomContractSync();
            return Promise.resolve(result);
        });
		
		//DIGI-12373
        window.FAM.registerMethod('CustomUnlockFA', () => {
            var result = CustomUnlockFA();
            return Promise.resolve(result);
        });

        //deal score cutom button
        window.FAM.registerMethod("iFrameFunction", () => {
            return new Promise(async resolve => {
                var activeFa = await window.FAM.api.getActiveFrameAgreement();
                //first save FA
                //Adding if condition for defect fix EDGE-210615
                if (activeFa.csconta__Status__c !== 'Sent for Approval') {
                    await window.FAM.api.saveFrameAgreement(activeFa.Id);
                }
                //refresh
                var className = 'FAMActionHelper';
                var data = {
                    method: 'refreshDelegatedPricing',
                    faId: activeFa.Id
                };
                var response = await window.FAM.api.performAction(className, JSON.stringify(data));
                if (response == "true") {
                    // Resolve url
                    //added condition to redirect to partner page - EDGE 177928 
                    if (window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")) {
                        resolve(window.location.origin + "/partners/c__GetDealScoreVF?FrameId=" + activeFa.Id);
                    }
                    else {
                        resolve("/apex/c__GetDealScoreVF?FrameId=" + activeFa.Id);
                    }
                } else if (response == "false") {
                    showToastMessage('warning', 'Warning!', 'Please add Products in Frame Agreements Configuration.', 5000);
                } else if (JSON.stringify(response) != '{}' && JSON.stringify(response) != {}) {//Defect-EDGE-212284
                    console.log('Response= ' + JSON.stringify(response));
                    showToastMessage('error', 'Error!', 'Something went wrong. Please reach out to Support Team', 5000);
                }
            });
        });
        /*
        * Modified By: Payal Popat (EDGE-185605)
        * Purpose : Used to generate quote and redirect user to quote
        */
        window.FAM.registerMethod("quoteRedirection", async () => {
			
			try {
				var className = 'FAMActionHelper';
				var inputMap = {
					method: 'quoteGeneration',
					faId: FARecId
				};
				var quoteGenerateRspse = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
				quoteGenerateRspse = JSON.parse(quoteGenerateRspse);
				if (quoteGenerateRspse["success"] !== null && quoteGenerateRspse["success"] != '') {
					var redirectURL = window.location.origin;
					if (frameOrigin !== null) {
						redirectURL = frameOrigin + '/lightning/r/Quote/' + quoteGenerateRspse["Id"] + '/view';
					} else if (window.location.href.includes("partners") && !redirectURL.includes("partners.enterprise.telstra.com.au")) {
						redirectURL = redirectURL + "/partners/" + quoteGenerateRspse["Id"];
					} else {
						redirectURL = redirectURL + "/" + quoteGenerateRspse["Id"];
					}
					showToastMessage('success', 'Success!', quoteGenerateRspse["success"], 5000);//'Quote Generated Sucessfully'
					return Promise.resolve(redirectURL);
				}
				else {
					//error message: 'Quote generation failed: Please try again and contact your admin if the issue persist'
					showToastMessage('error', 'Error!', quoteGenerateRspse["errorMessage"], 5000);
					return Promise.resolve(window.location.href); //unrecoverable error, finish
				}
			} catch (e) {
				//error message: 'Quote generation failed: Please try again and contact your admin if the issue persist'
				showToastMessage('error', 'Error!', 'Something went wrong...', 5000);
				return Promise.resolve(window.location.href); //unrecoverable error, finish
			}
        });

        window.FAM.registerMethod("escalateFunction", async () => {
			const confirm = await ui.confirm('If you proceed, Frame Agreement will be locked. No further change possible. Do you want to proceed?');
			if (confirm) {
				var activeFrameAgreement=await window.FAM.api.getActiveFrameAgreement();//DIGI-11010
				if (activeFrameAgreement['Final_Delegation_Outcome__c'] === 'Customized Pricing') {
					return new Promise(resolve => {
						if (window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")) {
							resolve(window.location.origin + "/partners/c__FA_createCaseForOpportunityVF?FrameId=" + FARecId + "&OpportunityId=" + opportunityId + "&AccountId=" + accountId);
						}
						else {
							resolve("/apex/c__FA_createCaseForOpportunityVF?FrameId=" + FARecId + "&OpportunityId=" + opportunityId + "&AccountId=" + accountId);
						}
					});
				}
				//validate description
				if (activeFrameAgreement["Description__c"] === undefined ||
					(activeFrameAgreement["Description__c"] !== undefined && activeFrameAgreement["Description__c"].length < 50)) {
					showToastMessage('error', 'Error!', 'Notes length must be greater than 50.', 5000);
					return Promise.resolve(false); //unrecoverable error, finish
				}

				//check if deal approver is required
				if (delegationHierarchy[userDetails['Delegation_Role__c']] < delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']]) {
					//logged in user delegation role is below required delegation outcome
					if (activeFrameAgreement["Deal_Approver__c"]) {
						var className = 'FAMActionHelper';
						var inputMap = {
							method: 'getDealApproverDetails',
							dealApproverId: activeFrameAgreement["Deal_Approver__c"]
						};
						let dealApprover = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
						dealApprover = JSON.parse(dealApprover);
						if (delegationHierarchy[dealApprover['Delegation_Role__c']] < delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']]) {
							showToastMessage('error', 'Error!', 'Selected Deal Approver is lower in the Role Hierarchy than the Final Delegation Outcome.', 5000);
							return Promise.resolve(false); //unrecoverable error, finish
						}
					} else {
						showToastMessage('error', 'Error!', 'Please select Deal Approver', 5000);
						return Promise.resolve(false); //unrecoverable error, finis
					}
				}


				var className = 'FAMActionHelper';
				var inputMap = {
					method: 'generateOpportunityTeamMember',
					faId: FARecId
				};
				let response = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
				if (response == 'success') {
					showToastMessage('success', 'Success!', 'Opportunity Team Member created successfully.', 5000);
					await window.FAM.api.updateFrameAgreement(FARecId, "is_Deal_Escalated__c", true);
					await window.FAM.api.saveFrameAgreement(FARecId);
					await window.FAM.api.refreshFa(FARecId);
				}
				else {
					showToastMessage('error', 'Error!', 'Error in creating the Opportunity Team Member.', 5000);
				}
			}else{
				return Promise.resolve(false); //unrecoverable error, finish
			}
        });
		
        window.FAM.registerMethod("approveFunction", async () => {
            window.FAM.api.setStatusOfFrameAgreement(FARecId, 'Approved');
        });
		
        window.FAM.registerMethod("rejectFunction", async () => {
            window.FAM.api.setStatusOfFrameAgreement(FARecId, 'Rejected');
        });



        /*
        * created By: Manish Berad 
        * Purpose : EDGE-201623 Auto creation of Deal opportunity for FA Revision on click of create new revision button from FA screen
        */
        window.FAM.registerMethod("CustomCreateNewFARevision", async data1 => {
            return new Promise(async resolve => {
                let activeFa = await window.FAM.api.getActiveFrameAgreement();
                window.FAM.api.createNewVersionOfFrameAgreement(activeFa.Id).then(async result => {
                    var className = 'FAMActionHelper';
                    var data = {
                        method: 'createDealOppAndOppContactRol',
                        faId: result.Id
                    };
                    var response = await window.FAM.api.performAction(className, JSON.stringify(data));
                    response = JSON.parse(response);
                    if (response.newOpportunityId != null) {
                        if (window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")) {
                            resolve(window.location.origin + "/partners/csfam__FAMEditor?account=" + response.acountId + "&opportunity=" + response.newOpportunityId + "#/agreement/" + response.newFrameAggrementId);
                        }
                        else {

                            /*Ashish: T-55794 access eindow.top to change the url from within iframe*/
                            window.top.location.href = window.location.origin + "/apex/csfam__FAMEditor?account=" + response.acountId + "&opportunity=" + response.newOpportunityId + "#/agreement/" + response.newFrameAggrementId;
                        }
                    }
                    if (response.errorMessage !== null && response.errorMessage !== '') {/*Ashish: added additional check for errormessage*/

                        window.FAM.api.toast('error', 'Error!', response.errorMessage, 5000);
                        throw new Error(response.errorMessage);
                    }
                    //return Promise.resolve(result);
                    //resolve(data1);
                });
            })
        });
        //////////



        window.FAM.registerMethod("GenerateContract", async () => {
            var activeFa = await window.FAM.api.getActiveFrameAgreement();
            
			//DIGI-9984...start
			var className = 'FAMActionHelper';
			var inputMap = {
				method: 'ValidateInitiateContractAction',
				FrameId: activeFa.Id
			};
			let getInitiateContractWarning = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
			let warningRes = JSON.parse(getInitiateContractWarning);

			if(warningRes.message!='success' && warningRes.warning!='success' ){
				window.FAM.api.toast('error', 'Error!',warningRes.message , 7000); 
				throw new Error(warningRes.message);
			}
			//DIGI-9984...end
			
			//EDGE-190520 FAM Contract Initiation   
			var className = 'DelegatedPricingController';
			var inputMap = {
				method: 'getDocuSignRestrictedFlag',
				acId: accountId
			};
			let docuSignRestricted = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
			let accDetails = JSON.parse(docuSignRestricted);
			let docsignflag = accDetails['APTPS_DocuSign_Restricted__c'];
			let AccountOwnerId = accDetails['OwnerId'];
			let AccountOwnerName = accDetails['Owner'].Name;
			console.log('##docsignflag ' + docsignflag + AccountOwnerName + AccountOwnerId);
			if (docsignflag == true) {
				return new Promise(resolve => {
					if (window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")) {
						resolve(window.location.origin + "/partners/apex/c__FA_createCaseToInitiateContract?FrameId=" + FARecId + "&OpportunityId=" + opportunityId);
					}
					else {
						resolve("/apex/c__FA_createCaseToInitiateContract?FrameId=" + FARecId + "&OpportunityId=" + opportunityId);
					}
				});
			} else {
				return new Promise(resolve => {
					// return '{"displayInDialog":true, "size":"m","modalTitle": "' + modalTitle +'", "redirectURL":"' + ShowURL +'", "status":"ok","text":"Select Signatories"}';  
					if (window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")) {
						resolve(window.location.origin + "/partners/apex/c__ContractSignatoriesSetup?FrameId=" + FARecId + "&AccountId=" + accountId + "&AccountOwnerId=" + AccountOwnerId + "&AccountOwnerName=" + AccountOwnerName);
					}
					else {
						resolve("/apex/c__ContractSignatoriesSetup?FrameId=" + FARecId + "&AccountId=" + accountId + "&AccountOwnerId=" + AccountOwnerId + "&AccountOwnerName=" + AccountOwnerName);
					}
				});
			}
            
        });
        resolve(data);
    });
});

//START OF EDGE-216677:Register the Method updateDPRtoScored :Osaka:PradeepM
window.FAM.registerMethod('updateDPRtoScored', () => {
    var result = updateDPRtoScored();
    return Promise.resolve(result);
});
window.FAM.registerMethod('updateFA', () => {
    var result = updateFA();
    return Promise.resolve(result);
});
//END OF EDGE-216677

window.FAM.subscribe('onLoad', async (data) => {
    if (userDetails) {
        if (delegationHierarchy[userDetails['Delegation_Role__c']] >= delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']]) {
            window.FAM.api.setStatusOfFrameAgreement(FARecId, 'Sent for Approval');
        }
    }
    //get queue members only once for all FAMs
    await getQueueMembers();
    return Promise.resolve(data);
});
window.FAM.subscribe('onBeforeActivation', async data => {
	//DIGI-15700
			showToastMessage('warning', 'Warning!','Contract activation in progress. Do not click Activate button again or close/refresh this window. Please wait for "Decomposition Successful" message.', 5000);
			
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    var className = 'FAMActionHelper';
    var actionData = {
        method: 'beforeActivationValidation',
        faId: activeFa.Id
    };
    var validationMsg = await window.FAM.api.performAction(className, JSON.stringify(actionData));
    if (validationMsg !== '') {
        window.FAM.api.toast('error', 'Activation failed', validationMsg);
        //only way to abort activation is to throw the error - DO NOT REMOVE
        throw new Error('Activation aborted with message: ' + validationMsg);
    } else {
        return Promise.resolve(data);
    }
});
window.FAM.subscribe('onAfterActivation', async data => {
    await postActivationActions();
    return Promise.resolve(data);
});



//should be supported in future EDGE-188476 start
window.FAM.subscribe('onBeforeCreateFrameAgreement', async data => {
    return new Promise(async resolve => {
        queryString = window.location.search;
        let urlParams = new URLSearchParams(queryString);
        opportunityId = urlParams.get('opportunity');
        var optyId = opportunityId;
        if (optyId === null) {//EDGE-201623
            window.FAM.api.toast('error', 'Error!', 'New Frame Agreement cannot be created without creating Deal Opportunity.', 5000); throw new Error('New Frame Agreement cannot be created without creating Deal Opportunity.');
        } else {

            var className = 'FAMActionHelper';
            var inputMap = {
                method: 'validateOnBeforeCreateFrameAgreement',
                OppId: opportunityId
            };

            let opptyData = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
            opptyData = JSON.parse(opptyData);
            if (opptyData.oppRecord.Pricing_Method__c === 'Delegated Pricing') {
                if (opptyData.oppRecord.Partner_Opportunity_Verification__c === 'Verification Required' || opptyData.oppRecord.Partner_Opportunity_Verification__c === 'Declined') {
                    window.FAM.api.toast('error', 'Error!', 'New Delegated Pricing Opportunity is Pending for Approval or Declined', 5000); throw new Error('New Delegated Pricing Opportunity is Pending for Approval or Declined');
                } else if (opptyData.isOppContactRole === false) {//EDGE-199307
                    window.FAM.api.toast('error', 'Error!', 'Please add primary Opportunity Contact Role to the Delegated Pricing Opportunity before creating New Frame Agreement.', 5000);
                    throw new Error('Please add primary Opportunity Contact Role to the Delegated Pricing Opportunity before creating New Frame Agreement.');

                } else if (opptyData.isFAactive === true) {//EDGE-203941
                    window.FAM.api.toast('error', 'Error!', opptyData.activeFAMessage, 5000);
                    throw new Error(opptyData.activeFAMessage);

                } else if (opptyData.oppRecord.StageName === 'Closed Won' || opptyData.oppRecord.StageName === 'Closed Lost') {//EDGE-203941

                    window.FAM.api.toast('error', 'Error!', 'Delegated Pricing Opportunity Stage is marked as Closed Won or Closed Lost.', 5000);
                    throw new Error('Delegated Pricing Opportunity Stage is marked as Closed Won or Closed Lost.');
                }
                data.Opportunity__c = data.Opportunity__c || opportunityId; //set only if not already set
                resolve(data);
                //console.log('data--->' ,data)		
            } else {
                window.FAM.api.toast('error', 'Error!', 'Pricing Method on opportunity is not Delegated Pricing.', 5000);
                throw new Error('Pricing Method on opportunity is not Delegated Pricing.');
            }
            if (opptyData.errorMessage !== null && opptyData.errorMessage !== '') {/*added additional check for errormessage*/
                window.FAM.api.toast('error', 'Error!', opptyData.errorMessage, 5000);
                throw new Error(opptyData.errorMessage);
            }
        }

    })
});
//EDGE-188476 end



window.FAM.subscribe('onAfterAddProducts', data => {
    //Deal score data affected by this change so we need to reset status back to Draft
    setStatusToDraft();
    return Promise.resolve(data);
});
//EDGE-220833
window.FAM.subscribe('onAfterDeleteProducts', data => {
    //Deal score data affected by this change so we need to reset status back to Draft
    setStatusToDraft();
    return new Promise(async resolve => {
		
		var activeFa = await window.FAM.api.getActiveFrameAgreement();
        
        await window.FAM.api.saveFrameAgreement(activeFa.Id);
        var className = 'FAMActionHelper';
        var data1 = {
            method: 'getDPRRecords',
            faId: activeFa.Id
        };
		
		
        var response1 = await window.FAM.api.performAction(className, JSON.stringify(data1));
		
        var parsedResponse = JSON.parse(response1);
        let responseLength = Object.keys(parsedResponse).length;
		
		
        console.log('responseLength::' + responseLength);

		var customData = {
                        fundConsoleData: []
                    };
		
        if (responseLength > 0) {
			
		parsedResponse = JSON.parse(response1);
        console.log(parsedResponse);
			
		for (let i = 0; i < parsedResponse.length; i++) {
        var row = parsedResponse[i];
        let minSpendperMonth = (row.Minimum_Spend_per_Month__c > 0 || row.Minimum_Spent_per_Month_Manual__c == undefined) ? row.Minimum_Spend_per_Month__c : row.Minimum_Spent_per_Month_Manual__c;//EDGE-229289
        let totalSpentoverContract = row.Total_Spend_over_Contract_Term__c;        
        let fundAmount = row.Fund_Amount__c;
        let fundExpiry = row.Fund_Term__c;
        let IsAllocated = row.isAllocated__c;
        let contractStartDate = row.ContractStartDate__c;
        let contractEndDate = row.ContractEndDate__c;
        let fContri = row.Fund_Contribution__c;
        let cTerm = row.PF_Contract_Term__c;
        let pFamily = row.Product_Family__c;
        let fcType = row.Fund_Type__c;
        let fundIncrementFreq = row.Fund_Increment_Frequency__c;
        
		
		
		let fcdata = {
                                "productFamily": pFamily,
                                "fundType": fcType,
                                "fundIncrementFrequency": fundIncrementFreq,
                                "fundExpiry": fundExpiry,
                                "contractTerm": cTerm,
                                "fundContribution": fContri,
                                "advanceFundAmount": fundAmount,
                                "minimumSpendPerMonth": minSpendperMonth,
                                "totalSpentOverContractTerm": totalSpentoverContract,
								"isAllocated":IsAllocated,//EDGE-229289
								"ContractStartDate":contractStartDate,
								"ContractEndDate":contractEndDate
                            };
		
			customData.fundConsoleData.push(fcdata);
		}//For End
			console.log(customData);
			var strCustomData = JSON.stringify(customData);
			console.log('Stringified JSON Array==' + strCustomData);
			//data._ui.attachment.custom = JSON.parse(strCustomData);
			var finalOutput = JSON.parse(strCustomData);
            window.FAM.api.setCustomData(activeFa.Id, finalOutput).then(result => {
                console.log('SetCustomData::' + JSON.stringify(finalOutput));
                window.FAM.api.saveFrameAgreement(activeFa.Id).then(result => {}, reject => {});
            });
        }// If End
        else if (!response1 || responseLength == 0) {
            showToastMessage('warning', 'Warning!', 'No Products', 5000);
        }
                    
		});
})

window.FAM.subscribe('onAfterNegotiate', data => {
    //Deal score data affected by this change so we need to reset status back to Draft
    setStatusToDraft();
    return Promise.resolve(data);
});
// start DIGI-6147
const ui = {
  confirm: async (message) => createConfirm(message)
}
const createConfirm = (message) => {
  return new Promise((complete, failed)=>{
	var modelDiv = document.createElement("DIV");
	modelDiv.setAttribute('Id','custommodel');
	modelDiv.style.display='block';
	modelDiv.style.position ='fixed';
	modelDiv.style.zIndex = 999;
	modelDiv.style.paddingTop='100px';
	modelDiv.style.top = 0;
	modelDiv.style.left = 0;
	modelDiv.style.width = '100%';
	modelDiv.style.height = '100%';
	modelDiv.style.overflow = 'auto';
	modelDiv.style.backgroundColor = 'rgb(0,0,0)';
	modelDiv.style.backgroundColor = 'rgba(0,0,0,0.4)';
	
	var modelcontent = document.createElement("DIV");
	modelcontent.style.backgroundColor='#fefefe';
	modelcontent.style.margin = 'auto';
	modelcontent.style.padding = '35px';
	modelcontent.style.width = '50%';
	modelcontent.style.borderRadius = '5px'
	var modelText = document.createElement("p");
	modelText.innerHTML = message;
	modelText.style.marginBottom = '25px';
	modelcontent.appendChild(modelText);
	var yesButton = document.createElement('input');
    yesButton.type = 'button';
    yesButton.value = 'OK';
	yesButton.style.float = 'right';
    yesButton.style.backgroundColor= 'blue';
    yesButton.style.color='white';
    yesButton.style.borderRadius= '5px';
    yesButton.style.padding = '5px';
    yesButton.style.margin= '0px 5px';
	yesButton.style.width= '60px';
	yesButton.onclick = function(event) {
		//yesClick();
		var modal = document.getElementById("custommodel");
		modal.style.display = "none";
		modal.remove();
		complete(true);
	}
	var spanModel = document.createElement('span');
	spanModel.style.height = '20px';
	spanModel.style.display='block';
	
	
	var noButton = document.createElement('input');
	noButton.type = 'button';
	noButton.value = 'Cancel';
	noButton.style.float = 'right';
	noButton.style.backgroundColor= 'white';
    noButton.style.color='blue';
    noButton.style.borderRadius= '5px';
    noButton.style.padding = '5px';
    noButton.style.margin= '0px 5px';
	noButton.onclick = function(event) {
		//noClick();
		var modal = document.getElementById("custommodel");
		modal.style.display = "none";
		modal.remove();
		complete(false);
	}
	
	spanModel.appendChild(noButton);
	spanModel.appendChild(yesButton);
	modelcontent.appendChild(spanModel);
	
	
	modelDiv.appendChild(modelcontent);
	
	var fam = document.getElementById('fam');
	fam.appendChild(modelDiv);
    
  });
}
//end DIGI-6147
async function setStatusToDraft() {
    let statusValuesForIgnore = ['Scored'];
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    //EDGE-203940
    //is current user queue member?
    //Removed If block as Enterprise_Pricing_User_1 queue members (ideally Pricing Admins) and deal approvers should be able to re-score a deal by changing the discount again and again.
    if (activeFa.csconta__Status__c !== 'Draft') {
        //reset if not Draft already
        await window.FAM.api.setStatusOfFrameAgreement(activeFa.Id, 'Draft');
        //EDGE-196353 start 
        var className = 'FAMActionHelper';
        var data = {
            method: 'updateDPRtoDraft',
            faId: activeFa.Id
        };
        var response = await window.FAM.api.performAction(className, JSON.stringify(data));
        //EDGE-196353 end
    }
}

/*async function refreshDelegatedPricing() {
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    //first save FA
    await window.FAM.api.saveFrameAgreement(activeFa.Id);
    //refresh
    var className = 'FAMActionHelper';
    var data = {
        method: 'refreshDelegatedPricing',
        faId: activeFa.Id
    };
    var response = await window.FAM.api.performAction(className, JSON.stringify(data));
    if(response){
    	
                // Resolve url
                //added condition to redirect to partner page - EDGE 177928 
                 if(window.location.href.includes("partners") && !window.location.href.includes("partners.enterprise.telstra.com.au")){
                    resolve(window.location.origin + "/partners/c__GetDealScoreVF?FrameId=" + activeFa.Id);
                }
                else{
                    resolve("/apex/c__GetDealScoreVF?FrameId=" + activeFa.Id);
                }
       
    }
}*/
async function cancelFrameAgreement() {
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    //first save FA
    await window.FAM.api.saveFrameAgreement(activeFa.Id);
    //refresh
    var className = 'FAMActionHelper';
    var data = {
        method: 'cancelFrameAgreement',
        faId: activeFa.Id
    };
    var response = await window.FAM.api.performAction(className, JSON.stringify(data));
    //refresh FA to reflect status change
    await window.FAM.api.refreshFa(activeFa.Id);
    return response;
}

async function postActivationActions() {
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    var className = 'FAMActionHelper';
    var data = {
        method: 'activateFrameAgreement',
        faId: activeFa.Id
    };
    var response = await window.FAM.api.performAction(className, JSON.stringify(data));
    return response;
}

async function handleDealScoreIframeMessage(e) {
    let supportedCallerNames = ['FA_createCaseForOpportunityVF', 'GetDealScoreVF', 'FA_createCaseToInitiateContract', 'TestTest']; //TestTest needs to be removed once GetDealScoreVF logic is fixed to send proper caller value
    var message = {};
    var eventData = {};
    eventData = e['data'];
    message = eventData['data'];
    type = eventData['command'];
    let callerName = eventData['caller'];

    //basic sanity check if message is intended for us
    if (!supportedCallerNames.includes(callerName)) {
        //not for us
        return;
    }
    //refresh FA to reflect status change
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    //Update the Status and Final delegation outcome Fields

    //EDGE-203940
    var className = 'FAMActionHelper';
    var data = {
        method: 'getIsDealEscalatedFlag',
        faId: activeFa.Id
    };
    var response = await window.FAM.api.performAction(className, JSON.stringify(data));

    if (message) {
        if (message["Delegated_Pricing_Request__c"]) {
            let delegatedPricing = JSON.parse(message["Delegated_Pricing_Request__c"]);
            await window.FAM.api.updateFrameAgreement(activeFa.Id, "Final_Delegation_Outcome__c", delegatedPricing["Final_Delegation_Outcome__c"]);

            //EDGE-203940: Added response check in below condition.
            if (delegationHierarchy[userDetails['Delegation_Role__c']] >= delegationHierarchy[delegatedPricing['Final_Delegation_Outcome__c']] && response == 'false') {
                await window.FAM.api.updateFrameAgreement(activeFa.Id, "csconta__Status__c", "Approved");
                await window.FAM.api.updateFrameAgreement(activeFa.Id, "isPrimary__c", true);
				await window.FAM.api.updateFrameAgreement(activeFa.Id, "allowEdit__c", true);
            } else {
                await window.FAM.api.updateFrameAgreement(activeFa.Id, "csconta__Status__c", delegatedPricing["Deal_Status__c"]);
                await window.FAM.api.updateFrameAgreement(activeFa.Id, "isPrimary__c", true);
            }
            await window.FAM.api.saveFrameAgreement(activeFa.Id);
            await window.FAM.api.refreshFa(activeFa.Id);
        }
        if (message == 'Agreement Status set to Scored.') {
            await window.FAM.api.refreshFa(activeFa.Id);
        }

    }
    if (callerName == 'FA_createCaseForOpportunityVF') {
        if (type == 'SUCCESS') {
            showToastMessage(type, type, message, 5000);
            //await window.FAM.api.setStatusOfFrameAgreement(activeFa.Id,'Sent for Approval');
            await window.FAM.api.updateFrameAgreement(activeFa.Id, "is_Deal_Escalated__c", true);
            await window.FAM.api.saveFrameAgreement(activeFa.Id);
            await window.FAM.api.refreshFa(activeFa.Id);
        } else {
            showToastMessage(type, type, message, 5000);
        }
    }
    if (callerName == 'GetDealScoreVF') {
        showToastMessage(type, type, message, 5000);
    }
    if (callerName == 'FA_createCaseToInitiateContract') {
        if (type == 'SUCCESS') {
            await window.FAM.api.setStatusOfFrameAgreement(activeFa.Id, 'Contract Initiated');
        }
        showToastMessage(type, type, message, 5000);
    }

    //deal score will change the status so refresh FA to instantly see that change
    //await window.FAM.api.refreshFa(activeFa.Id);
}
// General method to show the Toast message
async function showToastMessage(msgType, msgHeader, msgBody, interval) {
    window.FAM.api.toast(msgType, msgHeader, msgBody, interval);
}

async function getQueueMembers() {
    if (!queueMembers) {
        var className = 'FAMActionHelper';
        var inputMap = {
            method: 'getQueueUsers'
        };
        queueMembers = await window.FAM.api.performAction(className, JSON.stringify(inputMap));
        queueMembers = JSON.parse(queueMembers);
    }
}

async function CustomUnlockFA(){
	var activeFa = await window.FAM.api.getActiveFrameAgreement();
	setStatusToDraft();
	await window.FAM.api.updateFrameAgreement(activeFa.Id, "allowEdit__c", false);
}
// Method to update Fa status to Contract Synched
async function CustomContractSync() {
    console.log('CustomContractSync called');
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    //first save FA
    await window.FAM.api.saveFrameAgreement(activeFa.Id);
    //refresh
    var className = 'FAMActionHelper';
    var data = {
        method: 'CustomContractSync',
        faId: activeFa.Id
    };
    var response = await window.FAM.api.performAction(className, JSON.stringify(data));
    //refresh FA to reflect status change
    await window.FAM.api.refreshFa(activeFa.Id);
    return response;
}

//START OF EDGE-216677:Creating a function updateDPRtoScored :Osaka:PradeepM
async function updateDPRtoScored() {
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    if (activeFa.csconta__Status__c !== 'Scored') {
        //reset if not scored already
        //  await window.FAM.api.setStatusOfFrameAgreement(activeFa.Id, 'Scored');
        var className = 'FAMActionHelper';
        var data = {
            method: 'updateDPRtoScored',
            faId: activeFa.Id
        };
        var response = await window.FAM.api.performAction(className, JSON.stringify(data));
    }
}

async function updateFA() {
    var activeFa = await window.FAM.api.getActiveFrameAgreement();
    if (activeFa.csconta__Status__c !== 'Scored') {
        //reset if not scored already
        //await window.FAM.api.setStatusOfFrameAgreement(activeFa.Id, 'Scored');
        var className = 'FAMActionHelper';
        var data = {
            method: 'updateFA',
            faId: activeFa.Id
        };
        var response = await window.FAM.api.performAction(className, JSON.stringify(data));
        // await window.FAM.api.saveFrameAgreement(activeFa.Id);
        await window.FAM.api.refreshFa(activeFa.Id);
    }
}
//END OF EDGE-216677

//EDGE-203808-Updated by Shivaprasad for FundConsole Custom Tab-Start
/********************************************************************
 * Function    : changeHandler
 * Description : Event to handle data on Change in Fund Console table
 ********************************************************************/

async function changeHandler(val, minSpend, minSpendCalc, IsAllocated, totalSpend, advanceAmount, fCont, fundFreq, advFundContri, flexContri, conTerm, i, onLoad, fundExpiry) {

    if (!onLoad) {
        console.log('Inside Change handler onLoad value is:' + onLoad);
        setStatusToDraft();
    }

    if (val == 'Advance') {

        document.getElementById("fContriId" + i).value = parseFloat(advFundContri).toFixed(1); //EDGE-229735
        
        let selectobject = document.getElementById("fundFreqId" + i);
        selectobject.options.length = 0;

        let option2 = document.createElement("option");
        let option3 = document.createElement("option");

        option2.value = 'Annual In Advance';
        option2.text = 'Annual In Advance';
        option3.value = 'All In Advance';
        option3.text = 'All In Advance';

        selectobject.add(option2);
        selectobject.add(option3);


        if (fundFreq === 'None' || fundFreq === 'Monthly In Arrear' || fundFreq === undefined) {
            
            document.getElementById('fundFreqId' + i).value = "Annual In Advance";
        }
        else {
            
            document.getElementById('fundFreqId' + i).value = fundFreq;
        }

        let selectobject4 = document.getElementById("fundExpiryId" + i);
        selectobject4.options.length = 0;

        let option5 = document.createElement("option");
        let option6 = document.createElement("option");
        let option7 = document.createElement("option");
        let option8 = document.createElement("option");

        option5.value = '6';
        option5.text = '6 Months';
        option6.value = '12';
        option6.text = '12 Months';
        option7.value = '24';
        option7.text = '24 Months';
        option8.value = '36';
        option8.text = '36 Months';

        selectobject4.add(option5);
        selectobject4.add(option6);
        selectobject4.add(option7);
        selectobject4.add(option8);



        if (document.getElementById('fundFreqId' + i).value === 'Annual In Advance') {
            document.getElementById('fundExpiryId' + i).value = '12';
            document.getElementById("fundExpiryId" + i).disabled = true;
        }
        else if (document.getElementById('fundFreqId' + i).value === 'All In Advance') {
            document.getElementById('fundExpiryId' + i).value = fundExpiry;
            document.getElementById("fundExpiryId" + i).disabled = false;
        }
        document.getElementById("advFundAmount" + i).value = advanceAmount;
		document.getElementById('pfct' + i).value = conTerm;
        document.getElementById("MinMonthlyCommittmentId" + i).value = minSpend;//EDGE-211114
        document.getElementById("ttlSpentOverCPId" + i).value = totalSpend;//EDGE-211114
        document.getElementById('fContriId' + i).disabled = true;
        document.getElementById('advFundAmount' + i + '').disabled = false;
        document.getElementById('fundFreqId' + i + '').disabled = false;
        //EDGE-211114 start
        if (minSpendCalc > 0) {
            document.getElementById("MinMonthlyCommittmentId" + i).disabled = true;
        } else {
            document.getElementById("MinMonthlyCommittmentId" + i).disabled = false;
        }
        //EDGE-211114 end

        document.getElementById("ttlSpentOverCPId" + i).disabled = true;
    } else if (val == 'Flexi') {
        let selectobject2 = document.getElementById("fundFreqId" + i);
        selectobject2.options.length = 0;
        let option4 = document.createElement("option");
        option4.value = 'Monthly In Arrear';
        option4.text = 'Monthly In Arrear';
        selectobject2.add(option4);
        let selectobject5 = document.getElementById("fundExpiryId" + i);
        selectobject5.options.length = 0;

        let option9 = document.createElement("option");

        option9.value = '12';
        option9.text = '12 Months';

        selectobject5.add(option9);
        document.getElementById("fContriId" + i).value = parseFloat(flexContri).toFixed(1); //EDGE-229735
        document.getElementById('fundFreqId' + i).value = "Monthly In Arrear";
        document.getElementById('advFundAmount' + i).value = "-";
		document.getElementById('pfct' + i).value = conTerm;
        document.getElementById("MinMonthlyCommittmentId" + i).value = minSpend;//EDGE-211114
        document.getElementById("ttlSpentOverCPId" + i).value = totalSpend;//EDGE-211114
        document.getElementById('fundExpiryId' + i).value = '12';
        document.getElementById("fundExpiryId" + i).disabled = true;
        document.getElementById("fContriId" + i).disabled = true;
        document.getElementById("MinMonthlyCommittmentId" + i).disabled = true;
        document.getElementById("ttlSpentOverCPId" + i).disabled = true;
        document.getElementById('advFundAmount' + i).disabled = true;
        document.getElementById('fundFreqId' + i).disabled = true;
    } else if (val == 'No Fund') {
        let selectobject3 = document.getElementById("fundFreqId" + i);
        selectobject3.options.length = 0;
        let option5 = document.createElement("option");
        option5.value = 'None';
        option5.text = '-';
        selectobject3.add(option5);
        let selectobject6 = document.getElementById("fundExpiryId" + i);
        selectobject6.options.length = 0;

        let option10 = document.createElement("option");

        option10.value = '12';
        option10.text = '12 Months';

        selectobject6.add(option10);
        document.getElementById("fContriId" + i).value = "-";
        document.getElementById("fundFreqId" + i).value = "None";
        document.getElementById("advFundAmount" + i).value = "-";
		document.getElementById('pfct' + i).value = conTerm;
        document.getElementById("MinMonthlyCommittmentId" + i).value = minSpend;//EDGE-211114
        document.getElementById("ttlSpentOverCPId" + i).value = totalSpend;//EDGE-211114
        document.getElementById('fundExpiryId' + i).value = '12';
        document.getElementById("fundExpiryId" + i).disabled = true;
        document.getElementById('fContriId' + i).disabled = true;
        document.getElementById('fcTypeId' + i).disabled = false;
        document.getElementById("MinMonthlyCommittmentId" + i).disabled = true;
        document.getElementById("ttlSpentOverCPId" + i).disabled = true;
        document.getElementById('advFundAmount' + i).disabled = true;
        document.getElementById('fundFreqId' + i).disabled = true;
    }
    
}

/********************************************************************
 * Function    : changeFundHandler
 * Description : Calculates Fund % in Fund Console table
 ********************************************************************/
function changeFundHandler(val, totalSpend, i) {
    setStatusToDraft();
	totalSpend = document.getElementById("ttlSpentOverCPId" + i).value;
    let fundContriPercent = 0;
    if (totalSpend != 0 && totalSpend != undefined) {
        fundContriPercent = (val / totalSpend) * 100;
    }

    document.getElementById("fContriId" + i).value = fundContriPercent.toFixed(1); //EDGE-229735

}
/********************************************************************
 * Function    : minSpendChangedHandler
 * Description : Calculates Total spent over contract term on fund Console table
 ********************************************************************/
function minSpendChangedHandler(val, conTerm, i) {
    setStatusToDraft();
	conTerm = document.getElementById("pfct" + i).value;
    let totalSpent = 0;
    totalSpent = val * conTerm;
    document.getElementById("ttlSpentOverCPId" + i).value = totalSpent/*.toFixed(2)*/; //EDGE-229735

    val = document.getElementById("advFundAmount" + i).value;
    changeFundHandler(val, totalSpent, i);
}
/********************************************************************
* Function    : changeContractTermHandler
* Description : Calculates Total spent over contract term in Fund Console table
* EDGE-219471
********************************************************************/
function changeContractTermHandler(val, i) {
    setStatusToDraft();
    let totalMinSpent = 0;
    let famt = 0;
    let minSpend = document.getElementById("MinMonthlyCommittmentId" + i).value;
    totalMinSpent = val * minSpend;
    document.getElementById("ttlSpentOverCPId" + i).value = totalMinSpent/*.toFixed(2)*/; //EDGE-229735
    famt = document.getElementById("advFundAmount" + i).value;
    let fundType = document.getElementById('fcTypeId' + i).value;

    if (fundType == 'Advance') {
        changeFundHandler(famt, totalMinSpent, i);
    }
}
/********************************************************************
* Function    : changeFundFreqHandler
* Description : Calculates Total spent over contract term in Fund Console table
* EDGE-219475
********************************************************************/
function changeFundFreqHandler(val, fundExpiry, i) {
    setStatusToDraft();

    if (val === 'Annual In Advance') {
        document.getElementById('fundExpiryId' + i).value = '12';
        document.getElementById("fundExpiryId" + i).disabled = true;
    }
    else if (val === 'All In Advance') {
        document.getElementById('fundExpiryId' + i).value = fundExpiry;
        document.getElementById("fundExpiryId" + i).disabled = false;
    }
}
/********************************************************************
 * Function    : onLoadTable
 * Description : Set default values on load in Fund Console table
 ********************************************************************/
async function onLoadTable(parsedResponse) {
    for (let i = 0; i < parsedResponse.length; i++) {
        let data = parsedResponse[i];
        let fundType = data.Fund_Type__c;
        let cTerm = data.PF_Contract_Term__c;
        let minSpend = (data.Minimum_Spend_per_Month__c > 0 || data.Minimum_Spent_per_Month_Manual__c == undefined ) ? data.Minimum_Spend_per_Month__c : data.Minimum_Spent_per_Month_Manual__c;//EDGE-220072
        let minSpendCalc = data.Minimum_Spend_per_Month__c;
        let totalSpend = data.Total_Spend_over_Contract_Term__c;
        let advanceAmount = (data.Fund_Amount__c == "" || data.Fund_Amount__c == null || data.Fund_Amount__c == undefined) ? data.Fund_Amount_Calc__c : data.Fund_Amount__c;
        let fCont = data.Fund_Contribution__c;

        //EDGE-219118
        let IsAllocated = data.isAllocated__c;
        let ContractStartDate = data.ContractStartDate__c;
        let ContractEndDate = data.ContractEndDate__c;

        let fundFreq = data.Fund_Increment_Frequency__c;
        let advFundContri = data.Advance_Fund_Amount_Percent__c;
        let flexContri = data.Flexi_Fund_Amount_Percent__c;
        let fundExpiry = (data.Fund_Term__c == "" || data.Fund_Term__c == null || data.Fund_Term__c == undefined) ? 12 : data.Fund_Term__c;

        if (!data.Fund_Type__c) {
            console.log('Inside On Load, when no fund type');
            document.getElementById("fContriId" + i).value = parseFloat(fCont).toFixed(1); //EDGE-229735
            document.getElementById('fundFreqId' + i).value = "Monthly In Arrear";
            document.getElementById('advFundAmount' + i).value = "-";
            document.getElementById('pfct' + i).value = cTerm;
            document.getElementById("MinMonthlyCommittmentId" + i).value = minSpend;//EDGE-211114
            document.getElementById("ttlSpentOverCPId" + i).value = totalSpend;//EDGE-211114
            document.getElementById('fundExpiryId' + i).value = '12';
            document.getElementById("fundExpiryId" + i).disabled = true;
            document.getElementById('advFundAmount' + i).disabled = true;
            document.getElementById("fContriId" + i).disabled = true;
            document.getElementById("MinMonthlyCommittmentId" + i).disabled = true;
            document.getElementById("ttlSpentOverCPId" + i).disabled = true;
            document.getElementById('fundFreqId' + i).disabled = true;
        } else {
            console.log('Inside On Load,fund type true');
            let onLoad = "true";
            changeHandler(fundType, minSpend, minSpendCalc, IsAllocated, totalSpend, advanceAmount, fCont, fundFreq, advFundContri, flexContri, cTerm, i, onLoad, fundExpiry);
        }
        //EDGE-220832 Start
        var activeFa = await window.FAM.api.getActiveFrameAgreement();
        var isFAEditable = await window.FAM.api.isAgreementEditable(activeFa.Id);
        //if (((delegationHierarchy[userDetails['Delegation_Role__c']] >= delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']] && activeFrameAgreement["csconta__Status__c"] != "Sent for Approval") || delegationHierarchy[userDetails['Delegation_Role__c']] <= delegationHierarchy[activeFrameAgreement['Final_Delegation_Outcome__c']]) && (userDetails['id'] != activeFrameAgreement['Deal_Approver__c'] && (activeFrameAgreement['csconta__Status__c'] != "Sent for Approval")) && (activeFrameAgreement["csconta__Status__c"] != "Scored" && activeFrameAgreement["csconta__Status__c"] != "Draft"))
		if(!isFAEditable || IsAllocated){
            document.getElementById('advFundAmount' + i).disabled = true;
            document.getElementById("fContriId" + i).disabled = true;
            document.getElementById("MinMonthlyCommittmentId" + i).disabled = true;
            document.getElementById("ttlSpentOverCPId" + i).disabled = true;
            document.getElementById('fundFreqId' + i).disabled = true;
            document.getElementById('fcTypeId' + i).disabled = true;
            document.getElementById('pfct' + i).disabled = true;
            document.getElementById('fundExpiryId' + i).disabled = true;
			document.getElementById('IsAllocated' + i).disabled = true;
			document.getElementById('ContractStartDate' + i).disabled = true;
			document.getElementById('ContractEndDate' + i).disabled = true;
        }	
        //EDGE-220832 End
		
		//EDGE-211114 start
        if((fundType == 'Advance' && minSpendCalc <=0) && isFAEditable) {
            document.getElementById("MinMonthlyCommittmentId" + i).disabled = false;
        }
        //EDGE-211114 
    }
}
/***********************************************************************************
 * Function    : createFCTableRows
 * Description : Create rows based on different product family in Fund Console table
 **********************************************************************************/
function createFCTableRows(parsedResponse) {
    let tableRow = "";
    for (let i = 0; i < parsedResponse.length; i++) {
        var row = parsedResponse[i];
        let minSpend = (row.Minimum_Spend_per_Month__c > 0 || row.Minimum_Spent_per_Month_Manual__c == undefined) ? row.Minimum_Spend_per_Month__c : row.Minimum_Spent_per_Month_Manual__c;//EDGE-220072
        let minSpendCalc = row.Minimum_Spend_per_Month__c;
        let totalSpend = row.Total_Spend_over_Contract_Term__c;
        //let advanceAmount = row.Fund_Amount__c;
        let advanceAmount = (row.Fund_Amount__c == "" || row.Fund_Amount__c == null || row.Fund_Amount__c == undefined) ? row.Fund_Amount_Calc__c : row.Fund_Amount__c;
        let fundExpiry = (row.Fund_Term__c == "" || row.Fund_Term__c == null || row.Fund_Term__c == undefined) ? 12 : row.Fund_Term__c;

        //EDGE-219118
        let IsAllocated = row.isAllocated__c;
        let ContractStartDate = row.ContractStartDate__c;
        let ContractEndDate = row.ContractEndDate__c;
        
        let fCont = row.Fund_Contribution__c;
        let cTerm = row.PF_Contract_Term__c;
        let prodFamily = row.Product_Family__c;
        let fundType = row.Fund_Type__c;
        let fundFreq = row.Fund_Increment_Frequency__c;
        let advFundContri = row.Advance_Fund_Amount_Percent__c;
        let flexContri = row.Flexi_Fund_Amount_Percent__c;

        tableRow += '<tr  class="slds-hint-parent">';
        tableRow +=
            '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap" title="Adaptive Mobility" id="prodFamId' + i + '" value="">' + row.Product_Family__c + '</div>' +
            '</td>';
        if (row.Fund_Type__c) {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fcTypeId' + i + '" onchange="changeHandler(this.value,' + minSpend + ',' + minSpendCalc + ',' + IsAllocated + ',' + totalSpend + ',' + advanceAmount + ',' + "'" + fCont + "'" + ',' + "'" + fundFreq + "'" + ',' + "'" + advFundContri + "'" + ',' + "'" + flexContri + "'" + ',' + cTerm + ',' + i + ',' + "'" + false + "'" + ',' + "'" + fundExpiry + "'" + ')">' +
                '<option value="Advance" ' + ((row.Fund_Type__c == 'Advance') ? ' selected ' : '') + ' >Advance</option>' +
                '<option value="Flexi" ' + ((row.Fund_Type__c == 'Flexi') ? ' selected ' : '') + '>Flexi</option>' +
                '<option value="No Fund" ' + ((row.Fund_Type__c == 'No Fund') ? ' selected ' : '') + '>No Fund</option>' +
                '</select>' +
                '</td>';
        } else {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fcTypeId' + i + '" onchange="changeHandler(this.value)">' +
                '<option value="Advance" >Advance</option>' +
                '<option value="Flexi" selected>Flexi</option>' +
                '<option value="No Fund">No Fund</option>' +
                '</select>' +
                '</td>';
        }
        if (row.Fund_Increment_Frequency__c) {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fundFreqId' + i + '" onchange="changeFundFreqHandler(this.value,' + "'" + fundExpiry + "'" + ',' + i + ')">' +
                '<option value="All in Advance" ' + ((row.Fund_Increment_Frequency__c == 'All in Advance') ? 'selected' : '') + '>All in Advance</option>' +
                '<option value="Annual in Advance" ' + ((row.Fund_Increment_Frequency__c == 'Annual in Advance') ? 'selected' : '') + '>Annual in Advance</option>' +
                '<option value="Monthly In Arrear" ' + ((row.Fund_Increment_Frequency__c == 'Monthly In Arrear' && row.Fund_Type__c == 'Flexi') ? 'selected' : '') + '>Monthly In Arrear</option>' +
                '</select>' +
                '</td>';
        } else {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fundFreqId' + i + '">' +
                '<option value="Monthly In Arrear">Monthly In Arrear</option>' +
                '<option value="All in Advance">All in Advance</option>' +
                '<option value="Annual in Advance">Annual in Advance</option>' +
                '</select>' +
                '</td>';
        }
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="text" style="text-align:center !important;" id="pfct' + i + '"  name="Contract Term" onkeypress="return isNumber(event,this.value)" onchange="changeContractTermHandler(this.value,' + i + ')" value= ' + cTerm + '></div>' +
            '</td>';
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="text" style="text-align:center !important;" id="fContriId' + i + '"  name="fundContri" value= ' + fCont + '></div>' +
            '</td>';
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="text" style="text-align:center !important;" id="advFundAmount' + i + '"  name="fundAmount" onkeypress="return isNumber(event,this.value)" onchange="changeFundHandler(this.value,' + totalSpend + ',' + i + ')" value= ' + advanceAmount + '></div>' +
            '</td>';
        if (row.Fund_Term__c) {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fundExpiryId' + i + '" onchange="setStatusToDraft()">' +
                '<option value="6" ' + ((row.Fund_Term__c == '6') ? 'selected' : '') + '>6 Months</option>' +
                '<option value="12" ' + ((row.Fund_Term__c == '12') ? 'selected' : '') + '>12 Months</option>' +
                '<option value="24" ' + ((row.Fund_Term__c == '24') ? 'selected' : '') + '>24 Months</option>' +
                '<option value="36" ' + ((row.Fund_Term__c == '36') ? 'selected' : '') + '>36 Months</option>' +
                '</select>' +
                '</td>';
        } else {
            tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
                '<select class="slds-select slds-cell-wrap" id="fundExpiryId' + i + '">' +
                '<option value="6">6 Months</option>' +
                '<option value="12" selected>12 Months</option>' +
                '<option value="24">24 Months</option>' +
                '<option value="36">36 Months</option>' +
                '</select>' +
                '</td>';
        }
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="text" style="text-align:center !important;" id="MinMonthlyCommittmentId' + i + '"  name="MinMonthlyCommittment" onkeypress="return isNumber(event,this.value)" onchange="minSpendChangedHandler(this.value,' + cTerm + ',' + i + ')" value= ' + minSpend + '></div>' +
            '</td>' +
            '<td class="slds-text-align_center slds-truncate slds-cell-wrap">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="text" style="text-align:center !important;" id="ttlSpentOverCPId' + i + '"  name="ttlSpentOverCP" value= ' + totalSpend + '></div>' +
            '</td>';
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap" style="visibility: hidden;">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="checkbox" id="IsAllocated' + i + '"  name="IsAllocated" value= ' + IsAllocated + '></div>' +
            '</td>';
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap" style="visibility: hidden;">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="datetime" id="ContractStartDate' + i + '"  name="ContractStartDate" value= ' + ContractStartDate + '></div>' +
            '</td>';
        tableRow += '<td class="slds-text-align_center slds-truncate slds-cell-wrap" style="visibility: hidden;">' +
            '<div class="slds-truncate slds-cell-wrap"><input type="datetime" id="ContractEndDate' + i + '"  name="ContractEndDate" value= ' + ContractEndDate + '></div>' +
            '</td>';
        tableRow += "</tr>";
    }
    return tableRow;
}

/****************************************************************
 * Function    : setFundConsoleCustomData
 * Description : Set Custom data of Fund Console in FA attachment
 ***************************************************************/
function setFundConsoleCustomData(faID) {
    console.log('Inside Set Custom Data');
    console.log('Inside Set Custom Data - faID' + faID);
    var table = document.getElementById("fundConsoleTable");
    console.log('table-->' + table);
    var customData = {
        fundConsoleData: []
    };
    if (table != null && table != undefined) {
        var numRows = document.getElementById("fundConsoleTable").tBodies[0].rows.length;
        console.log('numRows:' + numRows);
        for (let i = 0; i < numRows; i++) {
            console.log('Inside For Loop');
            if (document.getElementById('prodFamId' + i) != null && document.getElementById('prodFamId' + i) != undefined) {
                var pFamily = document.getElementById('prodFamId' + i).innerHTML;
                console.log('pFamily:' + pFamily);
            }
            if (document.getElementById('fContriId' + i) != null && document.getElementById('fContriId' + i) != undefined) {
                var fContri = document.getElementById('fContriId' + i).value;
                console.log('fContri:' + fContri);
            }
            if (document.getElementById('pfct' + i) != null && document.getElementById('pfct' + i) != undefined) {
                var cTerm = document.getElementById('pfct' + i).value;
                console.log('cTerm:' + cTerm);
            }
            if (document.getElementById('fcTypeId' + i) != null && document.getElementById('fcTypeId' + i) != undefined) {
                var fcType = document.getElementById('fcTypeId' + i).value;
                console.log('fcType:' + fcType);
            }
            if (document.getElementById('fundFreqId' + i) != null && document.getElementById('fundFreqId' + i) != undefined) {
                var e = document.getElementById('fundFreqId' + i);
                var fundIncrementFreq = e.options[e.selectedIndex].value;
                console.log('fundIncrementFreq:' + fundIncrementFreq);
            }
            if (document.getElementById('fundExpiryId' + i) != null && document.getElementById('fundExpiryId' + i) != undefined) {
                var e = document.getElementById('fundExpiryId' + i);
                var fundExpiry = e.options[e.selectedIndex].value;
                console.log('fundExpiry:' + fundExpiry);
            }
            if (document.getElementById('advFundAmount' + i) != null && document.getElementById('advFundAmount' + i) != undefined) {
                var fundAmount = document.getElementById('advFundAmount' + i).value;
                console.log('fundAmount:' + fundAmount);
            }
            if (document.getElementById('MinMonthlyCommittmentId' + i) != null && document.getElementById('MinMonthlyCommittmentId' + i) != undefined) {
                var minSpendperMonth = document.getElementById('MinMonthlyCommittmentId' + i).value;
                console.log('minSpendperMonth:' + minSpendperMonth);
            }
            if (document.getElementById('ttlSpentOverCPId' + i) != null && document.getElementById('ttlSpentOverCPId' + i) != undefined) {
                var totalSpentoverContract = document.getElementById('ttlSpentOverCPId' + i).value;
                console.log('totalSpentoverContract:' + totalSpentoverContract);
            }

            let fcdata = {
                "productFamily": pFamily,
                "fundType": fcType,
                "fundIncrementFrequency": fundIncrementFreq,
                "fundExpiry": fundExpiry,
                "contractTerm": cTerm,
                "fundContribution": fContri,
                "advanceFundAmount": fundAmount,
                "minimumSpendPerMonth": minSpendperMonth,
                "totalSpentOverContractTerm": totalSpentoverContract,
                "isAllocated": false
            };
            //EDGE-219118
            var IsAllocated = '', ContractStartDate = '', ContractEndDate = '';
            if (document.getElementById('IsAllocated' + i) != null && document.getElementById('IsAllocated' + i) != undefined) {
                if (document.getElementById('IsAllocated' + i).value != 'undefined') {
                    fcdata.isAllocated = JSON.parse(document.getElementById('IsAllocated' + i).value);
                }
            }
            if (document.getElementById('ContractStartDate' + i) != null && document.getElementById('ContractStartDate' + i) != undefined) {
                if (document.getElementById('ContractStartDate' + i).value != 'undefined') {
                    fcdata.ContractStartDate = document.getElementById('ContractStartDate' + i).value;
                }
                console.log('ContractStartDate:' + ContractStartDate);
            }
            if (document.getElementById('ContractEndDate' + i) != null && document.getElementById('ContractEndDate' + i) != undefined) {
                if (document.getElementById('ContractEndDate' + i).value != 'undefined') {
                    fcdata.ContractEndDate = document.getElementById('ContractEndDate' + i).value;
                }
                console.log('ContractEndDate:' + ContractEndDate);
            }
            customData.fundConsoleData.push(fcdata);
        }
        if (faID != null && faID != undefined) {
            console.log('faID:' + faID);
            console.log(customData);
            var strCustomData = JSON.stringify(customData);
            console.log('Stringified JSON Array==' + strCustomData);
            var finalOutput = JSON.parse(strCustomData);
            return finalOutput;
            /*
            await window.FAM.api.setCustomData(faID, finalOutput).then(result => {
                console.log('SetCustomData::' + JSON.stringify(finalOutput));
                //window.FAM.api.saveFrameAgreement(faID).then(result => {}, reject => {}); //EDGE-223872-Commented to avoid status changes issue 
            });
            */
        }
    }
}
//EDGE-203808-Updated by Shivaprasad for FundConsole Custom Tab-End
//EDGE-203808-Updated by Shivaprasad for Fund Console Custom Tab - Start
/*
* Modified By: Shivaprasad Patil (EDGE-203808)
* Purpose : Used to handle fund console tab data
*/
window.FAM.registerMethod("fundConsoleMethod", id => {
    return new Promise(async resolve => {
        var activeFa = await window.FAM.api.getActiveFrameAgreement();
        //first save FA
        //await window.FAM.api.saveFrameAgreement(activeFa.Id);
        var className = 'FAMActionHelper';
        var data1 = {
            method: 'getDPRRecords',
            faId: activeFa.Id
        };
        var response1 = await window.FAM.api.performAction(className, JSON.stringify(data1));
        var parsedResponse = JSON.parse(response1);
        let responseLength = Object.keys(parsedResponse).length;

        console.log('responseLength::' + responseLength);


        if (responseLength > 0) {
            parsedResponse = JSON.parse(response1);
            console.log(parsedResponse);
            //showToastMessage('success', 'Success!', 'Fetched data');//debugger;
        }
        else if (!response1 || responseLength == 0) {
            showToastMessage('warning', 'Warning!', 'Add products and Save, before entering fund details', 5000);
        }

        var table = "<div>" +
            '<style>table, th, td {table-layout: fixed; width: 100%; border:1px gray; border-collapse:collapse; box-sizing: border-box; font-family: "Salesforce Sans", sans-serif;} th, td {padding: 8px; background-color:white; border-bottom: 1px solid #ddd;} th {color:#2F4F4F; font-weight: 400; font-size: 0.8125rem; white-space: pre-wrap;} td{font-size: 0.875rem;} select,input { height: 20px; width: 100%; -webkit-border-radius: 0; border: 0; outline: 1px solid #ccc; outline-offset: -1px;}</style>' +
            '<table id="fundConsoleTable" class="slds-table slds-table_cell-buffer slds-table_bordered slds-table_header-fixed slds-table_fixed-layout slds-table_resizable-cols">' +
            '<thead>' +
            '<tr class="slds-line-height_reset">' +
            '<th class="slds-table_bordered" aria-label="Product Family" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Product Family</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Fund Type" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Fund Type</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Fund Increment Frequency" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Fund Increment Frequency</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Contract Term" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Contract Term(Months)</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Fund Contribution" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Fund Contribution (%)</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Fund Amount" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Fund Amount</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Fund Expiry" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Fund Expiry</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Minimum Spend per Month" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Minimum Spend per Month</span>' +
            '</div>' +
            '</th>' +
            '<th class="slds-table_bordered" aria-label="Total Spend over Contract Term" aria-sort="none" scope="col">' +
            '<div class="slds-truncate slds-cell-wrap">' +
            '<span class="slds-truncate slds-cell-wrap">Total Spend over Contract Term</span>' +
            '</div>' +
            '</th>' +
            '</tr>' +
            '</thead>';
        if (parsedResponse != null && parsedResponse != undefined) {
            table += '<tbody style="text-align:center">' + createFCTableRows(parsedResponse) + '</tbody>';
        }

        table += '</table>' + "</div>";

        if (document.getElementById("fundConsoleTab") != null) {
            document.getElementById("fundConsoleTab").innerHTML += table.trim();
        }

        resolve();

        if (parsedResponse != null && parsedResponse != undefined) {
            onLoadTable(parsedResponse);
        }
    });

});
//EDGE-203808-Updated by Shivaprasad for FundConsole Custom Tab-End

//EDGE-203808-For FundConsole Custom Tab -Start
/*************************************************************
 * Function    : onAfterSaveFrameAgreement
 * Description : EDGE-203808 Create/Update the DPR records and update the FundConsole Records
 *************************************************************/
window.FAM.subscribe("onAfterSaveFrameAgreement", (data) => {

    return new Promise(resolve => {
        console.log('window.enableFundConsole==>' + window.enableFundConsole);
        console.log('enableFundConsole==>' + enableFundConsole);
        if (enableFundConsole == true) {



            window.FAM.api.getActiveFrameAgreement().then(async function (response) {
                frameAgreementRecord = response;
                console.log('frameAgreementRecord==>' + frameAgreementRecord.Id);
                /* //Commented by Shashank-Start
                if(frameAgreementRecord.Id != null && frameAgreementRecord.Id != undefined){
                setFundConsoleCustomData(frameAgreementRecord.Id);
                }*///Commented by Shashank-End


                //refresh
                var className = 'FAMActionHelper';
                var data = {
                    method: 'refreshDelegatedPricing',
                    faId: frameAgreementRecord.Id
                };
                var response = window.FAM.api.performAction(className, JSON.stringify(data));
                console.log('response-->' + response);
                //START OF EDGE-216677:Making changes as per the requirement:Osaka:PradeepM
                if (userDetails.Profile.Name == 'Migration BOH user') {
                    var activeFa = await window.FAM.api.getActiveFrameAgreement();
                    //	await window.FAM.api.updateFrameAgreement(activeFa.Id, "Final_Delegation_Outcome__c", "BOH Quality Check");
                    //    await window.FAM.api.updateFrameAgreement(activeFa.Id, "Scored");

                    updateFA();
                    updateDPRtoScored();
                    //	await window.FAM.api.refreshFa(activeFa.Id);
                }
                //END OF EDGE-216677
                if (response == "true") {
                    //  await window.FAM.api.saveFrameAgreement(activeFa.Id);
                    // await window.FAM.api.refreshFa(activeFa.Id);
                    console.log('Refreshed delegated Pricing ');

                } else if (response == "false") {
                    showToastMessage('warning', 'Warning!', 'Please add Products in Frame Agreements Configuration.', 5000);


                } else if (JSON.stringify(response) != '{}' && JSON.stringify(response) != {}) {//Defect-EDGE-212284
                    console.log('Response= ' + JSON.stringify(response));
                    showToastMessage('error', 'Error!', 'Something went wrong. Please reach out to Support Team', 5000);


                }
                window.FAM.api.refreshFa(frameAgreementRecord.Id);
            });
        }
        resolve(data);
    });
})
//EDGE-203808-For FundConsole Custom Tab-End
//EDGE-211114 start
/*************************************************************
 * Function    : onBeforeSaveFrameAgreement
 * Description : EDGE-211114 hook to handle FA and fund console before save
 *************************************************************/
window.FAM.subscribe("onBeforeSaveFrameAgreement", (data) => {
    return new Promise(resolve => {
        console.log('window.enableFundConsole==>' + window.enableFundConsole);
        console.log('enableFundConsole==>' + enableFundConsole);
        if (enableFundConsole == true) {
            window.FAM.api.getActiveFrameAgreement().then(function (response) {
                frameAgreementRecord = response;
                console.log('frameAgreementRecord==>' + frameAgreementRecord.Id);
                var valid = validateFundConsoleCustomData(frameAgreementRecord);
                if (valid) {
                    return Promise.resolve(false);
                } else {
                    //Added by Shashank-Start
                    console.log('Inside Set Custom Data');
                    //console.log('Inside Set Custom Data - faID' + faID);
                    var table = document.getElementById("fundConsoleTable");
                    console.log('table-->' + table);
                    var customData = {
                        fundConsoleData: []
                    };
                    if (table != null && table != undefined) {
                        var numRows = document.getElementById("fundConsoleTable").tBodies[0].rows.length;
                        console.log('numRows:' + numRows);
                        for (let i = 0; i < numRows; i++) {
                            console.log('Inside For Loop');
                            if (document.getElementById('prodFamId' + i) != null && document.getElementById('prodFamId' + i) != undefined) {
                                var pFamily = document.getElementById('prodFamId' + i).innerHTML;
                                console.log('pFamily:' + pFamily);
                            }
                            if (document.getElementById('fContriId' + i) != null && document.getElementById('fContriId' + i) != undefined) {
                                var fContri = document.getElementById('fContriId' + i).value;
                                console.log('fContri:' + fContri);
                            }
                            if (document.getElementById('pfct' + i) != null && document.getElementById('pfct' + i) != undefined) {
                                var cTerm = document.getElementById('pfct' + i).value;
                                console.log('cTerm:' + cTerm);
                            }
                            if (document.getElementById('fcTypeId' + i) != null && document.getElementById('fcTypeId' + i) != undefined) {
                                var fcType = document.getElementById('fcTypeId' + i).value;
                                console.log('fcType:' + fcType);
                            }
                            if (document.getElementById('fundFreqId' + i) != null && document.getElementById('fundFreqId' + i) != undefined) {
                                var e = document.getElementById('fundFreqId' + i);
                                var fundIncrementFreq = e.options[e.selectedIndex].value;
                                console.log('fundIncrementFreq:' + fundIncrementFreq);
                            }
                            if (document.getElementById('fundExpiryId' + i) != null && document.getElementById('fundExpiryId' + i) != undefined) {
                                var e = document.getElementById('fundExpiryId' + i);
                                var fundExpiry = e.options[e.selectedIndex].value;
                                console.log('fundExpiry:' + fundExpiry);
                            }
                            if (document.getElementById('advFundAmount' + i) != null && document.getElementById('advFundAmount' + i) != undefined) {
                                var fundAmount = document.getElementById('advFundAmount' + i).value;
                                console.log('fundAmount:' + fundAmount);
                            }
                            if (document.getElementById('MinMonthlyCommittmentId' + i) != null && document.getElementById('MinMonthlyCommittmentId' + i) != undefined) {
                                var minSpendperMonth = document.getElementById('MinMonthlyCommittmentId' + i).value;
                                console.log('minSpendperMonth:' + minSpendperMonth);
                            }
                            if (document.getElementById('ttlSpentOverCPId' + i) != null && document.getElementById('ttlSpentOverCPId' + i) != undefined) {
                                var totalSpentoverContract = document.getElementById('ttlSpentOverCPId' + i).value;
                                console.log('totalSpentoverContract:' + totalSpentoverContract);
                            }
							
                            let fcdata = {
                                "productFamily": pFamily,
                                "fundType": fcType,
                                "fundIncrementFrequency": fundIncrementFreq,
                                "fundExpiry": fundExpiry,
                                "contractTerm": cTerm,
                                "fundContribution": fContri,
                                "advanceFundAmount": fundAmount,
                                "minimumSpendPerMonth": minSpendperMonth,
                                "totalSpentOverContractTerm": totalSpentoverContract,
								"isAllocated":false
                            };
							//EDGE-219118
							var IsAllocated = '',ContractStartDate='',ContractEndDate='';
							if (document.getElementById('IsAllocated' + i) != null && document.getElementById('IsAllocated' + i) != undefined) {
								if(document.getElementById('IsAllocated' + i).value != 'undefined'){
									fcdata.isAllocated = JSON.parse(document.getElementById('IsAllocated' + i).value);
								}
							}
							if (document.getElementById('ContractStartDate' + i) != null && document.getElementById('ContractStartDate' + i) != undefined) {
								if(document.getElementById('ContractStartDate' + i).value != 'undefined'){
									fcdata.ContractStartDate = document.getElementById('ContractStartDate' + i).value;
								}
								console.log('ContractStartDate:' + ContractStartDate);
							}
							if (document.getElementById('ContractEndDate' + i) != null && document.getElementById('ContractEndDate' + i) != undefined) {
								if(document.getElementById('ContractEndDate' + i).value != 'undefined'){
									fcdata.ContractEndDate = document.getElementById('ContractEndDate' + i).value;
								}
								console.log('ContractEndDate:' + ContractEndDate);
							}
							
                            customData.fundConsoleData.push(fcdata);
                        }
                        if (frameAgreementRecord.Id != null && frameAgreementRecord.Id != undefined) {
                            console.log('frameAgreementRecord.Id:' + frameAgreementRecord.Id);
                            console.log(customData);
                            var strCustomData = JSON.stringify(customData);
                            console.log('Stringified JSON Array==' + strCustomData);
                            data._ui.attachment.custom = JSON.parse(strCustomData);

                            /*
                            await window.FAM.api.setCustomData(faID, finalOutput).then(result => {
                                console.log('SetCustomData::' + JSON.stringify(finalOutput));
                                //window.FAM.api.saveFrameAgreement(faID).then(result => {}, reject => {}); //EDGE-223872-Commented to avoid status changes issue 
                            });
                            */
                        }
                    }
                    //data._ui.attachment.custom = fundData;
                    //Added by Shashank-End

                    console.log('data=' + data);
                    console.log('data=' + JSON.stringify(data));
                    resolve(data);
                }

            });
        }
    });
})
/****************************************************************
 * Function    : validateFundConsoleCustomData
 * Description : validate Fund Console
 ***************************************************************/
function validateFundConsoleCustomData(fa) {
    console.log('Inside Set Custom Data');
    console.log('Inside Set Custom Data - fa' + fa);
    var table = document.getElementById("fundConsoleTable");
    console.log('table-->' + table);
    var valueToReturn = false;
    if (table != null && table != undefined) {
        var numRows = document.getElementById("fundConsoleTable").tBodies[0].rows.length;
        console.log('numRows:' + numRows);

        for (let i = 0; i < numRows; i++) {
            console.log('Inside For Loop');
            if (document.getElementById('fcTypeId' + i) != null && document.getElementById('fcTypeId' + i) != undefined) {
                var fundType = document.getElementById('fcTypeId' + i).value;
                var minSpendperMonth = 0; var fundAmount = 0;
                if (document.getElementById('MinMonthlyCommittmentId' + i) != null && document.getElementById('MinMonthlyCommittmentId' + i) != undefined) {
                    minSpendperMonth = document.getElementById('MinMonthlyCommittmentId' + i).value;
                }
                if (document.getElementById('MinMonthlyCommittmentId' + i) != null && document.getElementById('MinMonthlyCommittmentId' + i) != undefined) {
                    fundAmount = document.getElementById('advFundAmount' + i).value;
                }
                if (fundType == 'Advance' && (minSpendperMonth <= 0 || fundAmount <= 0)) {
                    showToastMessage('error', 'Error!', 'Please provide an amount greater than $0 under Minimum Spend per Month and Fund Amount for Advance Fund', 5000);
                    valueToReturn = true;
                }
				//start DIGI-5250
				if (document.getElementById('fundFreqId' + i) != null && document.getElementById('fundFreqId' + i) != undefined) {
                    var e = document.getElementById('fundFreqId' + i);
                    var fundIncrementFreq = e.options[e.selectedIndex].value;
                }
                if (document.getElementById('fundExpiryId' + i) != null && document.getElementById('fundExpiryId' + i) != undefined) {
                    var e = document.getElementById('fundExpiryId' + i);
                    var fundExpiry = e.options[e.selectedIndex].value;
                } 
				if (document.getElementById('pfct' + i) != null && document.getElementById('pfct' + i) != undefined) {
                    var cTerm = document.getElementById('pfct' + i).value;
                }
                if((fundType == 'Flexi') || (fundType == 'Advance' && fundIncrementFreq == 'All In Advance')){
                    if(!(JSON.parse(cTerm)>= JSON.parse(fundExpiry))){
					    showToastMessage('error', 'Error!', 'Please ensure contract term has a greater or equal number of months than the fund expiry', 5000);
                         valueToReturn = true; 
                    }
                }
                if(cTerm <= 0 || !(Number.isInteger(JSON.parse(cTerm))) ||cTerm.includes(".")) {
                        showToastMessage('error', 'Error!', 'Please ensure contract term is a positive integer', 5000);
                        valueToReturn = true; 
                }	
				//end DIGI-5250
            }
        }
        return valueToReturn;
    }
}
function isNumber(evt, val) {
    evt = (evt) ? evt : window.event;
    var charCode = (evt.which) ? evt.which : evt.keyCode;
    if (charCode != 46 && charCode > 31 && (charCode < 48 || charCode > 57)) {
        return false;
    } else if (val.includes(".") && charCode == 46) {
        return false;
    }
    return true;
}
//EDGE-211114 End

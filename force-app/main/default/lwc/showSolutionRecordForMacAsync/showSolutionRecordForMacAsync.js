import {LightningElement,track,api,wire} from 'lwc';
import getSolutionView from "@salesforce/apex/ShowSolutionsOnMACButtonController.getSolutionView";
import processChangeSolution from "@salesforce/apex/ShowSolutionsOnMACButtonController.processChangeSolution";//EDGE-224786
import addSolutionTomacBasket from "@salesforce/apex/ShowSolutionsOnMACButtonController.addSolutionTomacBasket";//EDGE-224786
import getBasketDetails_new from "@salesforce/apex/ShowSolutionsOnMACButtonController.getBasketDetails_new";
import createContactInOpportunity from "@salesforce/apex/ShowSolutionsOnMACButtonController.createContactInOpportunity";
import getJobStatus from "@salesforce/apex/ShowSolutionsOnMACButtonController.getJobStatus";
import getOpportunityId from "@salesforce/apex/ShowSolutionsOnMACButtonController.getOpportunityId";
import getSolnAddStatus from "@salesforce/apex/ShowSolutionsOnMACButtonController.getSolnAddStatus";

import {
    NavigationMixin
} from 'lightning/navigation';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import isBillingAccountValid from "@salesforce/apex/ShowSolutionsOnMACButtonController.isBillingAccountValid"; //EDGE-147513 added by shubhi
import CreateMacOPtyAndBasket from "@salesforce/apex/CreateMacOPty_Basket.CreateMacOPtyAndBasket"; ////EDGE-154023 added by shubhi
import postSelectiveMACDProcessing from "@salesforce/apex/ShowSolutionsOnMACButtonController.postSelectiveMACDProcessing";
import createHerokuMACDSolution from "@salesforce/apex/ShowSolutionsOnMACButtonController.createHerokuMACDSolution";
import checkExistingMac from "@salesforce/apex/ShowSolutionsOnMACButtonController.checkExistingMac";
const actions = [{
    label: 'Show details',
    name: 'show_details'
}];

export default class ShowSolutionRecordForMacAsync extends NavigationMixin(LightningElement) {
    @api MacOpptyBasketCreationStatus;
@api MACDBasketID;
@api selectedRowsMap = [];
@api MACDOpportunityID;
@api basketId;
@api accountId;
@api accountName;
@api isParallelProcessingEnabled;
@api redirectToSolution;
@api selectedSalesSupportCaseId; //added by manish as part of EDGE-172345
@api createMacOppResponse;
@track listOfSolutionIds = []; //Added as part of EDGE-144681
@track index = 0;
@track OpptyId = '';
@track selectedRows;
@track SolutionID;
@track returnData;
@api disablebtn;
@api disableAddbtn; ///added by shubhi /EDGE-154023
@api status;
@api solnSuccessCount = 0;
@api solnAddError = false;
@api selectedContact;
@track columns;
@track error;
@api isAddStatusError = false;
@track data;
@track bShowModal = false;
@track filter; //added as part of EDGE-138655
@track filteredData; //added as part of EDGE-138655
@track selectedRowsCount = 0; //added as part of EDGE-138655
@track NoSearchRecord = false; //added as part of EDGE-138655
@track selectionRows = [];
@track allSelectedRows = [];
@track selection = [];
@track selectedSolsNotShown = [];
//Ramya
@track macSolution = [];
@track showMacError = false;
conRecId;
disablebtnValLwc = true;
disableAddbtnValLwc = true;
/*EDGE-132715 Start*/
@track tNowCaseRefStr = '';
@track assuranceProfFlg = false;
@api
get assuranceProfileFlag() {
    return this.assuranceProfileFlag;
}
set assuranceProfileFlag(value) {
    if (value == 'false')
        this.assuranceProfFlg = false;
    else
        this.assuranceProfFlg = true;
}
@api
get tNowCaseRef() {
    return this.__tNowCaseRef;
}
set tNowCaseRef(value) {
    console.log('inside tNowCaseRef Setter Method');
    this.tNowCaseRefStr = value;
    if (this.selectedRows != '' && this.selectedRows != undefined && this.selectedRows != null && this.selectedRows.length > 0 &&
        !this.disablebtnValLwc && (!this.assuranceProfFlg || (this.assuranceProfFlg && value != '' &&
            value != null && value != undefined && this.tnowCaseRefvalidate(value)))) {
        this.disablebtn = false;
    } else
        this.disablebtn = true;
    if ((this.selectedRows != '' && this.selectedRows != null && this.selectedRows.length != 0) || this.disablebtnValLwc || this.basketId)
        this.disableAddbtn = true;
    else
        this.disableAddbtn = false;
} /*EDGE-132715 End*/

@api methodtoGetDisablebtn(disablebtnVal) {
    this.disablebtnValLwc = disablebtnVal;
    console.log('Inside LWC Method --->methodtoGetDisablebtn', disablebtnVal);

    if (this.selectedRows == undefined || disablebtnVal)
        this.disablebtn = true;
    else if (this.selectedRows.length > 0 && !disablebtnVal &&
        (!this.assuranceProfFlg ||
            (this.assuranceProfFlg && this.tNowCaseRefStr != '' &&
                this.tNowCaseRefStr != null && this.tNowCaseRefStr != undefined &&
                this.tnowCaseRefvalidate(this.tNowCaseRefStr)))) { //Changed for EDGE-132715
        console.log('LWC Method Selected Rows Lenght ', this.selectedRows.length);
        this.disablebtn = false;
    }
    //EDGE-154023 added by shubhi
    if ((this.selectedRows != '' && this.selectedRows != null && this.selectedRows.length != 0) || this.disablebtnValLwc || this.basketId)
        this.disableAddbtn = true;
    else
        this.disableAddbtn = false;
}
@api addSolutionOrSkip(isValid, conId) {
    console.log('Inside   addSolutionOrSkip  ', isValid, conId);
    this.conRecId = conId;
    if (isValid)
        //this.addSelected();
        this.addSelected_new();
}
//EDGE-154023 added by shubhi
@api addNewSolution(isValid, conId) {
    console.log('Inside   addSolutionOrSkip  ', isValid, conId);
    this.conRecId = conId;
    if (isValid)
        this.addCreateOptyAndbasket();
    else
        console.log('validation Failed ', isValid);

}

renderedCallback() {
    console.log('Inside rendered Callback');
}
getSolutionViews() {
    getSolutionView({
            basketId: this.basketId,
            accountId: this.accountId
        })
        .then(result => {

            this.data = result;
            this.filteredData = result;
            /* eslint-disable no-console */

        })
        .catch(error => {
            console.log('error is -->', this.error);
        });
}

connectedCallback() {
    this.disablebtn = true;
    // this.accountId = "0012N00000DuGTx";
    this.getSolutionViews();
    /* eslint-disable no-console */
    this.columns = [{
            type: 'showSub',
            label: 'Solution Name',
            fieldName: 'SolutionName',
            initialWidth: 270,
            typeAttributes: {
                attrA: {
                    fieldName: 'SolutionID'
                },
                attrB: {
                    fieldName: 'SolutionName'
                },
            }
        },
        {
            label: 'Created Date',
            fieldName: 'createdDate',
            type: 'text',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'status',
            type: 'text',
            sortable: true
        },
        {
            label: 'Total Recurring Charges',
            fieldName: 'totalRC',
            type: 'text',
            sortable: true
        },
        {
            label: 'Total One-Off Charges',
            fieldName: 'totalOC',
            type: 'text',
            sortable: true
        },
        {
            label: 'Total Contract Value',
            fieldName: 'totalCV',
            type: 'text',
            sortable: true
        },
        {
            label: 'Created By',
            fieldName: 'createdBy',
            type: 'text',
            sortable: true
        },
        {
            type: 'action',
            typeAttributes: {
                rowActions: actions,
                menuAlignment: 'left'
            }
        },
    ];
}

handleRowAction(event) {
    console.log('inside handle row action...');
    const action = event.detail.action;
    const row = event.detail.row;
    switch (action.name) {
        case 'SOLUTIONNAME':
            //alert(('Showing Details: ' + JSON.stringify(row));
            break;
    }

}

showpoponsub(event) {
    console.log(' showSubPopup event.rowId -->', event.detail.rowId);
    console.log(' showSubPopup event.attrA -->', event.detail.solId);
    //this.bShowModal=true;
    var solID = event.detail.solId;
    this.dispatchEvent(new CustomEvent('openModalPopup', {
        detail: {
            solID
        }
    }));
    // Remove the row
}

closeModal() {
    // to close modal window set 'bShowModal' tarck value as false
    this.bShowModal = false;
}

handleRowSelection(event) {
    this.listOfSolutionIds = [];
    this.finalselection = [];
    const row = event.detail.row;
    console.log('Selected Row -->', row);
    this.selectedRows = this.template.querySelector('c-show-sub-cell-button-helper').getSelectedRows();
    console.log('this.selectedRows...' + this.selectedRows);
    if (this.selectedRows.length == 0) {
        this.selection = [];
    }
    for (var solData of this.selectedRows) {
        if (solData.SolutionID && solData.SolutionID != null && solData.SolutionID != '') {
            this.listOfSolutionIds.push(solData.SolutionID);
        }
    }

    let selectionRows = this.template.querySelector('c-show-sub-cell-button-helper').getSelectedRows();
    console.log('selectionRows...' + selectionRows);
    // Modified as part of EDGE-213656 - start
    // let allSelectedRows = this.selection;
    let allSelectedRows = [selectionRows?.map(row => row.SolutionID)];
    // for(let k=0; k<selectionRows.length; k++){
    //     allSelectedRows.push(selectionRows[k].SolutionID);
    // }
    console.log('allSelectedRows...' + allSelectedRows);
    // this.selection = [];
    this.selection.splice(0, 1);
    this.selection.push(...allSelectedRows);
    // this.selection=[...new Set(this.selection)];
    // Modified as part of EDGE-213656 - end
    console.log("==current row---" + JSON.stringify(this.selection));

    //Added as part of EDGE-144681 - Start
    /*for (var i = 0; i < this.selectedRows.length; i++) {    
            if (this.selectedRows[i] != null) {
                //this.listOfSolutionIds.push({key:this.selectedRows[i].SolutionID,value:this.selectedRows[i].SolutionID});
                this.listOfSolutionIds.push(this.selectedRows[i].SolutionID);
            }
        }*/
    //Added as part of EDGE-144681 - Start
    console.log('Total Selected Rows-->', this.listOfSolutionIds);
    console.log('Selected Rows Length -->', this.selectedRows.length);
    console.log('disablebtnValLwc -->', this.disablebtnValLwc);
    console.log('assuranceProfFlg -->', this.assuranceProfFlg);
    console.log('tNowCaseRef -->', this.tNowCaseRef);
    console.log('tNowCaseRefStr -->', this.tNowCaseRefStr);
    console.log('selectedSalesSupportCaseId -->', this.selectedSalesSupportCaseId);
    this.selectedRowsCount = this.selectedRows.length;
    /*if(this.selectedContact != null && this.selectedContact != '')
        this.disablebtn = false;*/
    if (this.selectedRows.length > 0 && !this.disablebtnValLwc &&
        (!this.assuranceProfFlg ||
            (this.assuranceProfFlg && this.tNowCaseRefStr != '' &&
                this.tNowCaseRefStr != null && this.tNowCaseRefStr != undefined &&
                this.tnowCaseRefvalidate(this.tNowCaseRefStr)))) { //Changed for EDGE-132715
        this.disablebtn = false;
    }
    if (this.selectedRows == '' || this.selectedRows == null || this.selectedRows.length == 0) {
        this.disablebtn = true;
    }
    //EDGE-154023 added by shubhi
    if (this.selectedRows.length > 0 || this.disablebtnValLwc || this.basketId)
        this.disableAddbtn = true;
    else
        this.disableAddbtn = false;
}

/*checkForExistingMac() {
    console.log('Inside checkForExistingMac ...', this.listOfSolutionIds);
    var selSolutionId = this.listOfSolutionIds;
    var mac
    checkExistingMac({
        solutionId: selSolutionId,
    }).then(result => {
        this.macSolution = result;
        console.log('Mac Solution', this.macSolution);

    }).catch(error => {
        console.log('331 -->', error);
    });
}
*/
checkAndAddSelected() {
    console.log('Inside checkAndAddSelected ...', this.listOfSolutionIds);
    if(!this.isParallelProcessingEnabled){
        checkExistingMac({
            solutionId: this.listOfSolutionIds,
        }).then(result => {
            var startTimeAsh = performance.now();
        console.log('startTimeAsh-----   ' + startTimeAsh);
        console.log('Mac Solution', this.macSolution);
        console.log('this.macSolution.length'+this.macSolution.length);
            if (result.length > 0) {
                
                this.showMacError = true;
                //alert(this.showMacError)
            } else {
                this.checkIsBillingValid();
            }

        }).catch(error => {
            console.log('error is0 -->', error);
        });
    }
    else{
        this.checkIsBillingValid();
    }        
        
    }
    checkIsBillingValid(){
        this.showMacError = false;
        this.disablebtn = true
        this.SolutionID = this.listOfSolutionIds;
        const solId = this.SolutionID;
        const lenghtofrecord = this.selectedRows.length;
        //DPG-1915
        const solName = this.selectedRows[0].SolutionName
        console.log('this.selectedRows[0].SolutionName' + solName);
        console.log('this.SolutionID' + this.SolutionID);
        //DPG-1915-- sent solName in detail	
        //EDGE-147513 added by shubhi start ---------
        var isBillingaccvalid = true;
        isBillingAccountValid({
            solutionIdSet: this.listOfSolutionIds,
        }).then(result => {
            isBillingaccvalid = result;
            this.dispatchEvent(new CustomEvent('ChangeSolution', {
                detail: {
                    lenghtofrecord,
                    isBillingaccvalid,
                    solName
                } ////EDGE-147513
            }));
        }).catch(error => {
            console.log('error is0 -->', error);
            this.dispatchEvent(new CustomEvent('ChangeSolution', {
                detail: {
                    lenghtofrecord,
                    isBillingaccvalid
                } ////EDGE-147513
            }));
        }); ////EDGE-147513 added by shubhi end---------
    }

addSelected() {
    console.log('Inside add Selected ...', this.listOfSolutionIds);
    console.log('selectedSalesSupportCaseId ...', this.selectedSalesSupportCaseId);
    // console.log('Inside add Selected , total record -->', this.selectedRows[0].SolutionID);
    //this.SolutionID = this.selectedRows[0].SolutionID;
    this.SolutionID = this.listOfSolutionIds;
    const solId = this.SolutionID;
    const lenghtofrecord = this.selectedRows.length;

    console.log('Selected Solutions...' + this.listOfSolutionIds);
    if (this.tNowCaseRefStr == undefined) { //EDGE-132715
        this.tNowCaseRefStr = '';
    }
    //EDGE-172345
    if (this.selectedSalesSupportCaseId == undefined) {
        this.selectedSalesSupportCaseId = '';
    }
    console.log('Inside getBasketDetails ...', this.listOfSolutionIds);
    getBasketDetails({
            //solIdList: this.listOfSolutionIds,

            solIdList: this.listOfSolutionIds,
            accountId: this.accountId,
            sourceBasketId: this.basketId,
            tnowRefId: this.tNowCaseRefStr,
            salesSupportCaseId: this.selectedSalesSupportCaseId //EDGE-172345
        })
        .then(getBasketDetailsResult => {

            console.log('Return Basket response:', getBasketDetailsResult);
            this.basketId = getBasketDetailsResult.targetBasketId;
            this.createMacOppResponse = getBasketDetailsResult;

            getOpportunityId({
                    basketId: this.basketId
                })
                .then(result1 => {
                    console.log('Return Oppty ID is ', result1);

                    const OppId = result1;
                    this.OpptyId = result1; 
                    // window.OpptyId =result1;
                    console.log('Return Cont ID is ', this.conRecId);
                    createContactInOpportunity({
                            'OppId': this.OpptyId,
                            'conId': this.conRecId
                        })
                        .then(result => {
                            console.log('Its Successs for createContactInOpportunity', result);
                        })
                        .catch(error => {
                            console.log('Failure for createContactInOpportunity', result);
                        });

                    var refreshIntervalId = setInterval(function() {
                        getJobStatus({
                                OpptyId: this.OpptyId
                            })
                            .then(result2 => {
                                console.log('Return Result is ', result2);
                                if (result2 == 'SUCCESS') {
                                    //AB: post upgrade changes start
                                    console.log('Starting postSelectiveMACDProcessing');
                                    postSelectiveMACDProcessing({
                                        'basketId': this.createMacOppResponse.targetBasketId,
                                        'targetSolutionId': this.createMacOppResponse.targetSolutionId
                                    }).then(result3 => { // added by shubhi for INC000093944610 start ---
                                        console.log('Starting createHerokuMACDSolution' + result3);
                                        var responsemap = JSON.parse(result3);
                                        var res = responsemap['idmap'];
                                        var idValue = res[this.createMacOppResponse.replacedMainConfigurationId];
                                        var targetmainconfigid = idValue;
                                        clearInterval(refreshIntervalId);
                                        this.status = result2;
                                        var mesg = responsemap['message'];
                                        if (mesg == 'Successfully added') {
                                            createHerokuMACDSolution({
                                                'replacedSolutionId': this.createMacOppResponse.replacedSolutionId,
                                                'targetSolutionId': this.createMacOppResponse.targetSolutionId,
                                                'basketId': this.createMacOppResponse.targetBasketId,
                                                'targetMainConfig': targetmainconfigid
                                            });
                                            //AB: post upgrade changes end
                                            console.log('Before Firing Event this.basketId->', this.basketId);
                                            const bID = this.basketId;
                                            this.dispatchEvent(new CustomEvent('completejob', {
                                                detail: {
                                                    bID,
                                                    OppId
                                                }
                                            }));
                                        } else {
                                            this.dispatchEvent(new CustomEvent('jobfailed', {}));
                                        }
                                        //this.promiseFunc(this.basketId);
                                    }); // added by shubhi for INC000093944610 end ---
                                } else if (result2 == 'Error') {
                                    console.log('inside error..');
                                    this.dispatchEvent(new CustomEvent('jobfailed', {

                                    }));
                                }

                            })
                            .catch(errorss => {
                                console.log('error is2 -->', errorss);
                            });

                    }.bind(this), 5000);



                })
                .catch(error => {
                    console.log('error is1 -->', error);
                });


        })


        .catch(error => {
            console.log('error is0 -->506', error);
        });
}

addSelected_new() {
    console.log('Inside add Selected ...', this.listOfSolutionIds);
    console.log('selectedSalesSupportCaseId ...', this.selectedSalesSupportCaseId);
    // console.log('Inside add Selected , total record -->', this.selectedRows[0].SolutionID);
    //this.SolutionID = this.selectedRows[0].SolutionID;

    this.SolutionID = this.listOfSolutionIds;
    //const solId = this.SolutionID;
    const lenghtofrecord = this.selectedRows.length;

    console.log('Selected Solutions...' + this.listOfSolutionIds);
    if (this.tNowCaseRefStr == undefined) { //EDGE-132715
        this.tNowCaseRefStr = '';
    }
    //EDGE-172345
    if (this.selectedSalesSupportCaseId == undefined) {
        this.selectedSalesSupportCaseId = '';
    }

    if (this.selectedRows[this.index] != null) {
        console.log('calling loopSolutions...' + this.selectedRows[this.index].SolutionID);
        //test();
        this.loopSolutions(this.selectedRows[this.index].SolutionID);
    } else {
        console.log('selected rows is null');
        /*var refreshStatusIntervalId = setInterval(function() {
            var tempList = [];
            this.selectedRowsMap.forEach(solutionRec => {
                if (solutionRec["status"] == 'open') {
                    //alert((solutionRec["count"]);
                    if (solutionRec["count"] <= 3) {
                        //alert((solutionRec["count"]);
                        tempList.push(solutionRec);
                    } else {
                        //alert(('in 546');
                        this.isAddStatusError = true;
                    }


                }
            });
            this.selectedRowsMap = tempList;
            if (this.selectedRowsMap.length > 0 && this.isAddStatusError == false) {
                this.selectedRowsMap.forEach(solutionRec => {
                    //alert((solutionRec["Id"]);
                    getSolnAddStatus({
                        solId: solutionRec["Id"]
                    }).then(response => {
                        if (response == 'success') {
                            solutionRec["status"] = 'success'

                        } else if (response == 'inProgress') {
                            solutionRec["count"] += 1;
                        } else if (response == 'error') {
                            solutionRec["count"] += 1;
                        }
                    }).catch(errorss => {
                        console.log('error is2 -->', errorss);
                    });
                });
            } else if (this.isAddStatusError) {
                //alert(('isAddStatusError -> '+this.isAddStatusError);
                clearInterval(refreshStatusIntervalId);
                this.dispatchEvent(new CustomEvent('jobfailed', {

                }));
            } else {
                clearInterval(refreshStatusIntervalId);
                console.log('End of Solution...');
                console.log('Before Firing Event this.basketId->', this.basketId);
                const bID = this.basketId;
                const OppId = this.OpptyIdId;
                var endTimeAsh2 = performance.now();
                console.log(`Call to processChangeSolution took ${endTimeAsh2} milliseconds`)
                this.dispatchEvent(new CustomEvent('completejob', {
                    detail: {
                        bID,
                        OppId
                    }
                }));
            }


        }.bind(this), 5000);

*/
    }
}

loopSolutions(solutionId) {
    //for (i = 0; i < this.listOfSolutionIds.length; i++){
    //this.listOfSolutionIds.forEach(solId => {
    console.log('Processing solId...' + solutionId);
    console.log('this.basketId...' + this.basketId);
    this.getBasketDetailsAsync(solutionId, this.accountId, this.basketId, this.tNowCaseRefStr, this.selectedSalesSupportCaseId, this.conRecId);
    //});
    //}
}

getBasketDetailsAsync(solId, accId, bId, tnow, caseId, contId) {
    this.isAddStatusError = false;
    var stTimeAsh = performance.now()
    //console.log(`Call to run macd creation took ${stTimeAsh} milliseconds`)
    var optyCreationCheckInterval = setInterval(function() {
        if (this.MacOpptyBasketCreationStatus != 'In-Progress') {
            clearInterval(optyCreationCheckInterval);
            //alert('In Sycn Mode');
            if (this.MacOpptyBasketCreationStatus == 'completed') {
                addSolutionTomacBasket({
                        sourceBasketId: this.MACDBasketID,
                        solId: solId
                    })
                    .then(getBasketDetailsResult => {
                            console.log('Return Basket response:', getBasketDetailsResult);
                            this.createMacOppResponse = getBasketDetailsResult;
                            this.OpptyId = this.createMacOppResponse.opportunityId;
                            createHerokuMACDSolution({
                                'replacedSolutionId': this.createMacOppResponse.replacedSolutionId,
                                'targetSolutionId': this.createMacOppResponse.targetSolutionId,
                                'basketId': this.createMacOppResponse.targetBasketId,
                                'targetMainConfig': null
                            });
                            this.index++;
                            if (this.selectedRows[this.index] != null) {
                                this.loopSolutions(this.selectedRows[this.index].SolutionID);
                            } else {
                                var refreshStatusIntervalId = setInterval(function() {
                                    var tempList = [];
                                    this.selectedRowsMap.forEach(solutionRec => {
                                        if (solutionRec["status"] == 'open') {
                                            if (solutionRec["count"] <= 3) {
                                                tempList.push(solutionRec);
                                            } else {
                                                this.isAddStatusError = true;
                                            }


                                        }
                                    });
                                    this.selectedRowsMap = tempList;
                                    if (this.selectedRowsMap.length > 0 && this.isAddStatusError == false) {
                                        this.selectedRowsMap.forEach(solutionRec => {
                                            getSolnAddStatus({
                                                solId: solutionRec["Id"]
                                            }).then(response => {
                                                var endTimeAsh5 = performance.now()
                                                console.log(`Call to run macd creation took ${endTimeAsh5-stTimeAsh} milliseconds`)
                                                console.log('ThirdAPI Response-------> '+response);
                                                if (response == 'success') {
                                                    solutionRec["status"] = 'success'

                                                } else if (response == 'inProgress') {
                                                    solutionRec["count"] += 1;
                                                } else if (response == 'error') {
                                                    solutionRec["count"] += 1;
                                                }
                                            }).catch(errorss => {
                                                console.log('error is2 -->', errorss);
                                            });
                                        });
                                    } else if (this.isAddStatusError) {
                                        clearInterval(refreshStatusIntervalId);
                                        this.dispatchEvent(new CustomEvent('jobfailed', {

                                        }));
                                    } else {
                                        clearInterval(refreshStatusIntervalId);
                                        const bID = this.basketId;
                                        const OppId = this.OpptyIdId;
                                        var endTimeAsh2 = performance.now();
                                        this.dispatchEvent(new CustomEvent('completejob', {
                                            detail: {
                                                bID,
                                                OppId
                                            }
                                        }));
                                        //.redirectFunc();
                                    }


                                }.bind(this), 5000);
                            }
                    }).catch(error => {
                        console.log('error is0785 -->', error);
                        this.dispatchEvent(new CustomEvent('jobfailed', {

                        }));
                    });
            } else {
                this.dispatchEvent(new CustomEvent('jobfailed', {

                }));
            }

        }
    }.bind(this), 1000);
    return true;
}

promiseFunc(basket) {
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            recordId: basket,
            actionName: 'view'
        }
    });


}

@api sendEvent() {
    this.dispatchEvent(new CustomEvent('completejob', {
        detail: this.basketId,
    }));

}
//added as paer of EDGE-138655
filterData(event) {
    console.log('inside filtereddate...' + event.target.value);
    console.log('1 selection inside filter...' + this.selection);
    if (event.target.value) {
        var data = this.data,
            term = event.target.value,
            results = data,
            regex;
        try {
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            //added new regex to filter with deviceId as part of EDGE-149079
            results = data.filter(row => regex.test(row.SolutionName) ||
                regex.test(row.status) || regex.test(row.totalRC) ||
                regex.test(row.totalOC) || regex.test(row.totalCV) ||
                regex.test(row.createdBy) || regex.test(row.createdDate) || regex.test(row.site) || regex.test(row.mobile) || regex.test(row.fixedNo) || regex.test(row.deviceId));
        } catch (e) {
            // invalid regex, use full list
        }
        this.filteredData = results;
        console.log('this.selection--------- ' + this.selection);
        let resSolutionIds = results?.map(s => s.SolutionID);
        let selectedSolsAllRaw = this.selection;
        let selectedSolsAll = [];

        for (let i = selectedSolsAllRaw.length - 1; i >= 0; i--) {
            if (typeof selectedSolsAllRaw[i] == 'object') {
                selectedSolsAll.concat(selectedSolsAllRaw[i]);
            } else {
                if (selectedSolsAllRaw[i].includes(',')) selectedSolsAll.concat(selectedSolsAllRaw[i].split(','));
                else selectedSolsAll.push(selectedSolsAllRaw[i]);
            }
        }

        selectedSolsAll = Array.from(new Set(selectedSolsAllRaw));

        let selectedSolutionIds = selectedSolsAll;
       
        let selectedSolutionsLeftOut = this.selectedSolsNotShown;

        // In case there are less results
        selectedSolutionIds?.forEach(solId => {
            // Check whether the new data contains the selected solution, and if not, add it to array if not present already
            if (!resSolutionIds.includes(solId) && !selectedSolutionsLeftOut.includes(solId)) selectedSolutionsLeftOut.push(solId);
        });

        // In case there are more results
        for (let i = selectedSolutionsLeftOut.length - 1; i >= 0; i--) {
            // Check whether the solution is within results but not within selected solutions, and if true
            // add it to the selected solutions and remove from the left out array
            if (resSolutionIds.includes(selectedSolutionsLeftOut[i]) && !selectedSolutionIds.includes(selectedSolutionsLeftOut[i])) {
                selectedSolutionIds.push(selectedSolutionsLeftOut[i]);
                selectedSolutionsLeftOut.splice(i, 1);
            }
        }

        console.log('selectedSolutionsLeftOut ' + selectedSolutionsLeftOut);
        console.log('selectedSolutionIds ' + selectedSolutionIds);

        this.selectedSolsNotShown = selectedSolutionsLeftOut;
        this.selection.splice(0, 1);
        this.selection.push(...selectedSolutionIds);

        console.log('this.filteredData' + JSON.stringify(this.filteredData));
        if (this.filteredData.length == 0) {
            this.NoSearchRecord = true;
        } else {
            this.NoSearchRecord = false;
        }
    } else {
        this.NoSearchRecord = false;
        console.log('Cleared filter values');
        this.filteredData = this.data;
        
    }
    console.log('2 selection inside filter...' + this.selection);
}
getSolnStatusMethod(solnId) {
    getSolnAddStatus({
        solId: solnId
    }).then(response => {
        if (response == 'success') {
            this.solnSuccessCount++;
            clearInterval(refreshIntervalId);
        } else if (response == 'error') {
            this.solnAddError = true;
            clearInterval(refreshIntervalId);
        }
    }).catch(errorss => {
        console.log('error is2 -->', errorss);
    });
}
/*EDGE-132715 Start*/
@api tnowCaseRefvalidate(inpTxt) {
    if (inpTxt == '' || inpTxt == null || inpTxt == undefined) {
        return false;
    }
    var regExp = /(TNC\d\d\d\d\d\d\d\d\d)|(tnc\d\d\d\d\d\d\d\d\d)|(GESPO\d\d\d\d\d\d\d\d\d)|(gespo\d\d\d\d\d\d\d\d\d)|(TBAPO\d\d\d\d\d\d\d\d\d)|(tbapo\d\d\d\d\d\d\d\d\d)/;
    if (inpTxt.match(regExp)) {
        return true;
    } else {
        return false;
    }
} /*EDGE-132715 End*/
//EDGE-154023 added by shubhi start---------------
checkAndCreateNewSolution() {

    this.disableAddbtn = true;
    console.log('Inside checkAndCreateNewSolution ...', this.listOfSolutionIds);
    this.dispatchEvent(new CustomEvent('AddSolution', {
        detail: {}
    }));
}
addCreateOptyAndbasket() {
    console.log('Inside addCreateOptyAndbasket ...');
    var contactId = this.conRecId
    CreateMacOPtyAndBasket({
            conId: contactId,
            accountId: this.accountId
        }).then(result => {
            this.basketid = result;
            const bID = result;
            const OppId = '';
            this.error = undefined;
            if (bID && bID != '') {
                this.dispatchEvent(new CustomEvent('completejob', {
                    detail: {
                        bID,
                        OppId
                    }
                }));
            } else {
                this.dispatchEvent(new CustomEvent('jobfailed', {}));
            }
        })
        .catch(error => {
            this.error = error;
            console.log('error is --->' + error);
            this.dispatchEvent(new CustomEvent('jobfailed', {}));
        });
}
////EDGE-154023 added by shubhi end----------------------------
}
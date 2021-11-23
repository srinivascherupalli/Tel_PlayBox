/*
---------------------------------------------------------------------
Name        : TransferHardwareRepayment Js
Description : Helper Component 
Author      : Aman Soni
Story       : EDGE-191076/EDGE-191077 (Sprint 21.01/21.02)
======================================================================
No.  Developer				Story(Sprint)			Description
1.	 Aman Soni				EDGE-203220(21.03) 		Allow user to auto remove configs from solution in case of Transition
----------------------------------------------------------------------
*/
import {LightningElement,track,api,wire} from 'lwc';
import getBasketOpptyType from "@salesforce/apex/GetSyncTransitionDevice.getBasketOpptyType";
import getServiceAddOns from "@salesforce/apex/GetSyncTransitionDevice.getServiceAddOns";
import getLegacyBillAccount from "@salesforce/apex/GetSyncTransitionDevice.getLegacyBillAccount";
import getFilteredRecForSelectedBAN from "@salesforce/apex/GetSyncTransitionDevice.getFilteredRecForSelectedBAN";
import getSynRemPendingRecs from "@salesforce/apex/GetSyncTransitionDevice.getSynRemPendingRecs";
import getSyncPendingRecsForTransition from "@salesforce/apex/GetSyncTransitionDevice.getSyncPendingRecsForTransition";//Added for EDGE-203220
export default class TransferHardwareRepayment extends LightningElement {
	
	showDataTable=false;
	@api basketId;
	@api opptyType;
	@api solutionId;
	@api legacyBAN;
	@api instanceIDString;
	@api category;
	@api contractType;
	@api mainBAN;
    @api tableName;  
	@api recorddata;
	@api billingAccountNumber;
	@api instanceIdList = [];
	@api instanceIdParsedList = [];
	@track value;
	@track error;
	@track toasttitle;
    @track toastmsg
	@track toastvariant;
	@track isLoaded = false;
	@track enableUpdateBtn = true;
	@track selectedList = [];
	@track cnfgsForAddOnsTobeRemoved = [];
	@track servAddOnIdsonRemove = [];
	@track addOnListOnRemove = [];
	@track cnfgsForAddOnsTobeAdded = [];
	@track billAccountAllValues = [];
	@track isAccessory= false;
	@track isDevice= false;

	//initialize component
	connectedCallback(){
		this.instanceIdList = instanceIDString.split(',');
		this.instanceIdParsedList = JSON.parse(JSON.stringify(this.instanceIdList));
		this.billingAccountNumber = billingAccountNumber;
		this.getBasketOpptyType();
		this.getResult();
		//Added for EDGE-203220(20.03) by Aman Soni || Start
		if(this.opptyType != 'Migration' && this.instanceIdParsedList.length > 0){
			this.getTransRecsToRemove();
		}
		//Added for EDGE-203220(20.03) by Aman Soni || End	
	}

	//get Opportunity Type of the basket
	getBasketOpptyType(){
		getBasketOpptyType({basketId : this.basketId})
		.then(result => {
				this.opptyType = result;
				if(this.category === 'Transition Device'){
					this.isDevice=true;
					if(this.opptyType === 'Migration'){
						this.tableName = 'TransferHardwareRepayment_DevMigration';
					}else{
						this.tableName = 'TransferHardwareRepayment_DevTransition';
					}
				}
				// Mahima- DPG-3889,4083
				if(this.category === 'Transition Accessory'){
					this.isAccessory=true;
					if(this.opptyType === 'Migration'){
						this.tableName = 'TransferAccessoryRepayment_DevMigration';
					}else{
						this.tableName = 'TransferAccessoryRepayment_DevTransition';
					}
				}
				console.log('Component-->',category, ' ', 'Oppty Type-->',this.opptyType,' ', 'Table Name-->',this.tableName);
		})
		.catch(error =>{
			console.log('Error in getBasketOpptyType-->',error);
		});
	}
	
	//method to fetch table records
    getResult(){
		getServiceAddOns({basketId : this.basketId, solutionId : this.solutionId, contractType : this.contractType, category : this.category, instIdList : this.instanceIdParsedList})
		.then(result => {
			if(result !=null && result != undefined){
				this.recorddata = result; 
				this.showDataTable=true;
			}
		})
		.catch(error =>{
			console.log('Error in getResult-->',error);
		});
	}

	//Method to auto remove configs in case of opptyType 'Transition' || Added for EDGE-203220 by Aman Soni
	getTransRecsToRemove(){	
		getSyncPendingRecsForTransition({basketId : this.basketId, solutionId : this.solutionId, contractType : this.contractType, category : this.category, instIdList : this.instanceIdParsedList})
		.then(result => {
			if(result !=null && result != undefined){
				for(var res of result){
					this.cnfgsForAddOnsTobeRemoved.push(res);
					this.addOnListOnRemove.push(res.Id);
				}
				if(this.cnfgsForAddOnsTobeRemoved.length > 0 && this.addOnListOnRemove.length > 0){
					this.updateServAddOnRemForMigration();
				}
			}
		})
		.catch(error =>{
			console.log('Error in getTransRecsToRemove-->',error);
		});
	}
	
	//method to List out Unique Legacy Billing Accounts
	@wire(getLegacyBillAccount, {basketId: '$basketId', solutionId: '$solutionId', category : '$category', contractType : '$contractType'}) 
    ListBillAccounts({data,error}){
		if(data){ 
			this.billAccountAllValues = data;
			this.billAccountAllValues = data.map(record => ({label:record , value:record}));
		} else {
			this.error = error;
		}
	}
	//property to List out Unique Legacy Billing Accounts in LWC Combobox
    get legacyBillAccoptions(){
        return this.billAccountAllValues;
    }
	
	//Invoked when Legacy Billing Account in Combobox is changed
    handleChange(event){
		this.showDataTable=false;	
		this.value = event.detail.value;
		this.mainBAN = this.value;
			getFilteredRecForSelectedBAN({basketId : this.basketId, solutionId : this.solutionId, contractType : this.contractType, category : this.category, mainBAN : this.mainBAN, instIdList : this.instanceIdParsedList})
			.then(resultBAN => {
				if(resultBAN !=null && resultBAN != undefined){
					this.recorddata = resultBAN;
					this.showDataTable=true;					
				}
			})
			.catch(error =>{
				console.log('Exception in handleChange-->', error);
			});
    }
	
	//Invoked when a row is checked/unchecked
	getselectedrowlist(event){
		var recordData  = event.detail;
		this.selectedList = JSON.parse(recordData.selectedRow);
		if(this.selectedList.length > 0){
			this.enableUpdateBtn=false;
			for(var rec of this.selectedList){
				var firstSelected = this.selectedList[0].legacyBillingAccount;
				if(firstSelected != rec.legacyBillingAccount && this.opptyType === 'Migration'){
					if(this.category === 'Transition Device'){
						this.setToastvalues('Error', 'Only one legacy billing account devices can be added in a single order', 'error');
					}else if(this.category === 'Transition Accessory'){
						this.setToastvalues('Error', 'Only one legacy billing account accessories can be added in a single order', 'error');
					}
					return;
				} 
			}
		}
		else{
            this.enableUpdateBtn=true;
		}
	}
	
	//Handle operations on click of 'Remove From Solution' button
	handleRemove(event){
		//START: Modified for EDGE-215103: Removed the check for Migration, it should work for Transition as well
		if(this.selectedList.length > 0){
			for(var record of this.selectedList){
				if(record.isgreyedout === false){
					this.setToastvalues('Error', 'Select only from the greyed out records if trying to remove', 'error');
					return;
				}else{
					this.servAddOnIdsonRemove.push(record.Id);
					this.cnfgsForAddOnsTobeRemoved.push(record);
				}
			}
		}
		if(this.cnfgsForAddOnsTobeRemoved.length > 0 && this.servAddOnIdsonRemove.length > 0){
			this.addOnListOnRemove = JSON.stringify(this.servAddOnIdsonRemove);
			this.updateServAddOnRemForMigration();
		}
		//END for EDGE-215103
	}

	//Update Service Add Ons with 'Ready for Sync/Sync Removal Completed' status 
	updateServAddOnRemForMigration(){
		getSynRemPendingRecs({basketId : this.basketId, addOnList : this.addOnListOnRemove})
		this.removeConfigs();
		//START: Modified for EDGE-215103: Removed the check for Migration, it should work for Transition as well
		if(this.isLoaded === true){	
			window.parent.postMessage("close", '*');
			sessionStorage.setItem("close", "close");
		}
		//END for EDGE-215103
	}

	//Remove Configurations from Solution against the selected devices
	removeConfigs(){
		var selectedData = JSON.stringify(this.cnfgsForAddOnsTobeRemoved);
		let payload =
		{
			command: 'removeConfigsforSelectedDevices',
			data: selectedData,
			caller: this.category
		};

		this.isLoaded = true;
		window.parent.postMessage(payload, '*') ;
		sessionStorage.setItem("payload", payload);
	}

	//close Iframe on Click of Cancel button
	handleCancel(event) {
		window.parent.postMessage("close", '*');
		sessionStorage.setItem("close", "close");
	}

	//Handle operations on click of 'Add To Solution' button
	handleAdd(event){
		this.cnfgsForAddOnsTobeAdded = [];
		if(this.selectedList.length > 0){
			for(var sel of this.selectedList){
				var firstSel = this.selectedList[0].legacyBillingAccount;
				var isEligible = false;
				if(this.opptyType === 'Migration'){
					if(sel.isgreyedout === true){
						this.setToastvalues('Error', 'Do not select already added records (marked in greyed)', 'error');
						return;
					}else if(sel.isgreyedout === false && sel.legacyBillingAccount != undefined && this.legacyBAN != undefined && this.legacyBAN != '' && sel.legacyBillingAccount != this.legacyBAN){
						if(this.category === 'Transition Device'){
							this.setToastvalues('Error', 'Only one legacy billing account devices can be added in a single order', 'error');
						}else if(this.category === 'Transition Accessory'){
							this.setToastvalues('Error', 'Only one legacy billing account accessories can be added in a single order', 'error');
						}
						return;	
					}else if(sel.isgreyedout === false && sel.legacyBillingAccount != undefined  && this.legacyBAN === '' && sel.legacyBillingAccount != firstSel){
						if(this.category === 'Transition Device'){
							this.setToastvalues('Error', 'Only one legacy billing account devices can be added in a single order', 'error');
						}else if(this.category === 'Transition Accessory'){
							this.setToastvalues('Error', 'Only one legacy billing account accessories can be added in a single order', 'error');
						}
						return;	
					}else if(sel.isgreyedout === false && ((sel.legacyBillingAccount === this.legacyBAN) || (this.legacyBAN === '' || this.legacyBAN === undefined))){
						isEligible = true;
						this.cnfgsForAddOnsTobeAdded.push(sel);
					}
				}else{
					if(sel.isgreyedout === true){
						this.setToastvalues('Error', 'Do not select already added records (marked in greyed)', 'error');
						return;
					}else{
						isEligible = true;
						this.cnfgsForAddOnsTobeAdded.push(sel);
					}
				}
			}
		}

		if(this.cnfgsForAddOnsTobeAdded.length > 0  && isEligible){
			this.createConfigs();
			if(this.isLoaded === true){	
				window.parent.postMessage("close", '*');
				sessionStorage.setItem("close", "close");
			}
		}
	} 

	//Create Configurations against Selected Devices 
	createConfigs(){
		var selectedData = JSON.stringify(this.cnfgsForAddOnsTobeAdded);
		let payload =
		{
			command: 'createConfigsforSelectedDevices',
			data: selectedData,
			caller: this.category
		};
		this.isLoaded = true;
		window.parent.postMessage(payload, '*');
		sessionStorage.setItem("payload", payload);
	}

	//Handle Error/Success Validations
	setToastvalues(toasttitle, toastmsg, toastvariant){
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}
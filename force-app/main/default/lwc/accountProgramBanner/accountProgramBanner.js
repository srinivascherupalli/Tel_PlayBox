import { LightningElement, api, track, wire } from "lwc";
import getPartnerAdmins from "@salesforce/apex/AccountProgramcontroller.accountProgramlwc"; 
// import Banner_Image from '@salesforce/resourceUrl/styles';
//import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import Id from '@salesforce/user/Id';
//import NAME_FIELD from '@salesforce/schema/User.FirstName';

import getLoggedInUserLicense from "@salesforce/apex/AccountProgramcontroller.getLoggedInUserLicense"; 
import getCMDTRecords from "@salesforce/apex/AccountProgramcontroller.getCustomMetaDataValues";

//import Banner_display_Transition_1 from '@salesforce/label/c.Banner_display_Transition_1';
/*
const columns = [ 
    { label: "Operations User", fieldName: "assignee", type: "text" },
    { label: "Tenancy ID", fieldName: "subscriptionName", type: "text" }
  ];
  
const fields = [NAME_FIELD]
*/
export default class AccountProgramBanner extends LightningElement {
		
	@track Banner_message_1; // = Banner_message_1;
	@track Banner_display_Transition; // = Banner_display_Transition;
	@track Banner_display_Migration; // = Banner_display_Migration;
	@track Banner_display_Transition_customer; // = Banner_display_Transition_customer;
	@track Banner_display_Migration_customer; // = Banner_display_Migration_customer;
	@track Banner_display_Transition_1; // = Banner_display_Transition_1;
  
	@api recordId;
	@track data = [];
	@track error;
       //@track columns = columns;
	@track show = false;
	@track EnableDate;
	@api fcrId;
	@track isCompleted = false;
	@track isMigration = false;
	
	//@track showNewProgram = false;
	//START : DIGI-1520 
	@track textMessage = '';
	@track textMessage1 = '';
	
	@track scenario1 = false;
	@track scenario2 = false;
	@track scenario3 = false;
	@track scenario4 = false;

	@track show = false;
	@track isInternalUser = true;
	/*	
	@wire(getCMDTRecords)
	wiredResult(result) { 
		console.log('result@@@ '+ JSON.stringify(result));
		if (result.data) {
				 
				var conts = result.data;
			
				console.log('Data@@@ '+ JSON.stringify(result.data));
				for(let key in conts) {
						// Preventing unexcepted data						
						if(key === 'Banner_message_1'){
								this.Banner_message_1 = conts[key].Value__c;
						}
						else if(key === 'Banner_display_Transition'){
								this.Banner_display_Transition = conts[key].Value__c;
						}
						else if(key === 'Banner_display_Migration'){
								this.Banner_display_Migration = conts[key].Value__c;
						}
						else if(key === 'Banner_display_Transition_customer'){
								this.Banner_display_Transition_customer = conts[key].Value__c;
						}
						else if(key === 'Banner_display_Migration_customer'){
								this.Banner_display_Migration_customer = conts[key].Value__c;
						}
						else if(key === 'Banner_display_Transition_1'){
								this.Banner_display_Transition_1 = conts[key].Value__c;
						}						
					 
						console.log('key@@@ '+ key);
						console.log('key@@@ '+ conts[key]);
						console.log('value@@@ '+ conts[key].Value__c);	
						
						console.log('this.Banner_message_1@@@ '+ this.Banner_message_1);
						console.log('this.Banner_display_Transition@@@ '+ this.Banner_display_Transition);
						console.log('this.Banner_display_Migration@@@ '+ this.Banner_display_Migration);
				}
		 }
	} */
	//END : DIGI-1520 	
	connectedCallback(){
		console.log('accountProgramBanner Id in connectedcallback method*****'+this.recordId);
		this.getLoggedInUserdetails();
		this.getCMDTDetailRecords();		
		//eval("$A.get('e.force:refreshView').fire();");
	}
	//DIGI-1520 END 
	
//DIGI-1520 START 
	getCMDTDetailRecords(){
			getCMDTRecords()
					.then(result => {
						console.log('result@@@ '+ JSON.stringify(result));
					if(result){

							var conts = result;

							console.log('Data@@@ '+ JSON.stringify(result));
							for(let key in conts) {
									// Preventing unexcepted data						
									if(key === 'Banner_message_1'){
											this.Banner_message_1 = conts[key].Value__c;
									}
									else if(key === 'Banner_display_Transition'){
											this.Banner_display_Transition = conts[key].Value__c;
									}
									else if(key === 'Banner_display_Migration'){
											this.Banner_display_Migration = conts[key].Value__c;
									}
									else if(key === 'Banner_display_Transition_customer'){
											this.Banner_display_Transition_customer = conts[key].Value__c;
									}
									else if(key === 'Banner_display_Migration_customer'){
											this.Banner_display_Migration_customer = conts[key].Value__c;
									}
									else if(key === 'Banner_display_Transition_1'){
											this.Banner_display_Transition_1 = conts[key].Value__c;
									}						

									console.log('key@@@ '+ key);
									console.log('key@@@ '+ conts[key]);
									console.log('value@@@ '+ conts[key].Value__c);	

									console.log('this.Banner_message_1@@@ '+ this.Banner_message_1);
									console.log('this.Banner_display_Transition@@@ '+ this.Banner_display_Transition);
									console.log('this.Banner_display_Migration@@@ '+ this.Banner_display_Migration);
									console.log('this.Banner_display_Transition_customer@@@ '+ this.Banner_display_Transition_customer);
									console.log('this.Banner_display_Migration_customer@@@ '+ this.Banner_display_Migration_customer);
							}
		 		 					 
					}
					else{
							 	
					}		
					
					
			})
			.catch(error =>{
					console.log('Error in getResult-->',error);
			});
			return this.getPartnerAdminDetails();
	}
		
	getPartnerAdminDetails(){
		setTimeout(() => {
				getPartnerAdmins({
					accId : this.recordId
				})
				.then(result => {
					// this.EnableDate = result;
					//START: EDGE-213096
					console.log('result@@@'+ result);
					console.log('result.Digital_Program_Type__c@@@ '+ result.Digital_Program_Type__c);
				
					var programRec = result;
					var status = result.Status__c;
					var inputDate = result.Digital_Products_Start_Date__c;
					var programType = result.Digital_Program_Type__c;
					
				  console.log('programType@@@ '+ programType);
											
					//END: EDGE-213096
					var dArr = inputDate.split("-");  // ex input "2010-01-18"
					//this.EnableDate = dArr[2]+ "-" +dArr[1]+ "-" +dArr[0]; //ex out: "18/01/10"

					this.EnableDate= dArr[2]+'/'+dArr[1]+'/'+dArr[0];

					//START: EDGE-213096     
					if(result !== undefined && result !== null)
					{
						if(status === 'Completed'){
							this.isCompleted = true;
						}

						console.log('this.Banner_message_111@@@ '+ this.Banner_message_1);
						console.log('this.Banner_display_Transition11@@@ '+ this.Banner_display_Transition);
						console.log('this.Banner_display_Migration11@@@ '+ this.Banner_display_Migration);
						//END: EDGE-213096
						//START : EDGE-207350
						//START : DIGI-1520 
						if(programType === 'Transition'){
							if(status !== 'Completed' && inputDate != null){
								this.scenario1 = true;
								this.textMessage = this.Banner_message_1 + ' '+ this.EnableDate +' '+this.Banner_display_Transition;
								this.textMessage1 = this.Banner_display_Transition_1;
								console.log('***scenario1****');
							}
							else if(status === 'Completed' && inputDate != null){
								this.scenario3 = true;
								this.textMessage = this.Banner_display_Transition_customer; 
								console.log('***scenario3****');
							}
						}				
						else if(programType === 'Migration'){
							if(status !== 'Completed' && inputDate != null){
								this.scenario2 = true;
								this.textMessage = this.Banner_message_1 + ' '+ this.EnableDate +' '+ this.Banner_display_Migration; 
								console.log('***scenario2****');
							}
							else if(status === 'Completed' && inputDate != null){
								this.scenario4 = true;
								this.textMessage = this.Banner_display_Migration_customer;
								console.log('***scenario4****');
							}	
						}
						//END : DIGI-1520 
						this.show = true;
						console.log('***accountProgramBanner Be set****');

					}
					this.error = undefined;

					console.log('result.isEnabled__c*****'+this.isEnabled__c);
					/*
					if(result.isEnabled__c == undefined){
						this.disabledMessage = this.label.distributionModelDisabledMessage;
						console.log('***disabledMessageWill Be set****');
					}
					*/
					console.log('SUCCESS***accountProgramBanner***'+this.isEnabled__c);
				})
				.catch(error => {
					this.error = error;

					console.log('FAIL***accountProgramBanner***'+this.error);
				});
  		}, 4000);
	}
	/*
    @wire(getPartnerAdmins, { recordId: "$recordId" })
  async wiredContacts({ error, data }) {
	    debugger;
    if (data !== undefined && data != null && data !== '') {
      this.data = data;
      this.error = undefined;
	  this.EnableDate =  data;
    } else {
      this.error = error;
      this.data = undefined;
	 
    }
	
	console.log('SUCCESS***EnableDate***'+this.EnableDate);
  }

  @wire(getRecord, { recordId: '$userId', fields })
  user;

  get name() {
    return getFieldValue(this.user.data, NAME_FIELD);
  }*/
	//DIGI-1520 START 
	getLoggedInUserdetails(){
		getLoggedInUserLicense()
			.then(result => {
			if(result ){
					this.isInternalUser = result;						 
			}
			else{
					this.isInternalUser = false;		
			}
		
		})
		.catch(error =>{
			console.log('Error in getResult-->',error);
		});
	}
}
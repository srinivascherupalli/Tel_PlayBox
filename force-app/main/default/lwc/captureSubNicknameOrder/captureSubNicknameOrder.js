/*
---------------------------------------------------------------------
Name        : CaptureSubNicknameOrder Js
Description : Helper Component 
Author      : Aman Soni
Story       : EDGE-199911(Sprint 21.04)
======================================================================
No.  Developer				Story(Sprint)			Description
1.					
----------------------------------------------------------------------
*/
import {LightningElement,track,api} from 'lwc';
import getSubscriptionsRecords  from "@salesforce/apex/CaptureSubNicknameOrderClass.getSubscriptionsRecords";
import toBeUpdatedSubNicknames  from "@salesforce/apex/CaptureSubNicknameOrderClass.toBeUpdatedSubNicknames";
export default class CaptureSubNicknameOrder extends LightningElement{
    showDataTable=false;
    @track selectedSubNickList = [];
    @track finalNickNameList = [];
    @track toasttitle;
    @track toastmsg
    @track toastvariant;
    @track isLoaded = false;
    @api orderId;
    @api recorddata;
    @api tableName; //DIGI-1767 - CaptureSubNicknameOrderVF.Vfp Removing the hardcoded value for tableName
    mapOfIdObject;
    validateNicknames;

    //initialize component on load
	connectedCallback(){
		this.getResult();
	}

    //method to fetch table records
    getResult(){
		getSubscriptionsRecords({orderId : this.orderId})
		.then(result => {
			if(result != undefined && result.length > 0){
				this.recorddata = result;
                this.showDataTable=true;
                var subsMap = new Map();
                for (var i = 0; i < result.length; i++) {
                    subsMap.set(result[i].Id, result[i]);
                }
                this.mapOfIdObject = subsMap;
			}
		})
		.catch(error =>{
			console.log('Error in getResult-->',error);
		});
	}

    //Update table Data
    updatedata(event){
        console.log('!!Inside Updatedata!!');
        var recData = event.detail;
        var inlineUpdateSubNickname = JSON.parse(recData.recordsString);
        this.selectedSubNickList.push(inlineUpdateSubNickname[0]);
        var regNickname = inlineUpdateSubNickname[0].nickname;
        var regexPattern = /^[a-zA-Z0-9- ']*$/;
        var isMatched = regNickname.match(regexPattern);
        if(isMatched === null){
            this.setToastvalues('Error', 'Valid characters for Nickname are a-zA-Z0-9 - \']', 'error');
        }
        var subNickRec = JSON.parse(JSON.stringify(this.selectedSubNickList));
        for(var i = 0; i < subNickRec.length; i++){
            this.mapOfIdObject.set(subNickRec[i].id, subNickRec[i]);
        }
    }

    //Navigate to Order on click of "Back To Order" button
	backToOrder(){
        var url='';
        url=JSON.stringify(window.location.href);
        console.log('url-->'+url);
        if(url.includes('partners.enterprise.telstra.com.au')){
            window.location.href = '/' + this.orderId;
        }
        else if(url.includes('/partners/')){
            window.location.href = '/partners/' + this.orderId;
        }
        else{
            window.location.href = '/' + this.orderId;
        }
	}

    //Save the changes on click of "Save" button
	saveRecords(){
        console.log('!!Inside Save!!');
        this.finalNickNameList = [];
        this.validateNicknames  = this.mapOfIdObject;
        for(var rec of this.validateNicknames.values()){
            if(rec.nickname != undefined){
                var recNickname = rec.nickname;
                var regPattern = /^[a-zA-Z0-9- ']*$/;
                var isValid = recNickname.match(regPattern);
                if(isValid === null){
                    this.setToastvalues('Error', 'Please remove special characters from nickname(s); valid characters are a-zA-Z0-9 - \']', 'error');
                    return; 
                }else{
                    this.finalNickNameList.push(rec);
                }
            }
        }
        if(this.finalNickNameList.length > 0){
            this.isLoaded = true;
            toBeUpdatedSubNicknames({subscriptions : JSON.stringify(this.finalNickNameList)})
            .then(resultSub => {
                if(resultSub != undefined && resultSub.length>0){
                    this.setToastvalues('Success', 'Nicknames saved successfully', 'success');
                    this.isLoaded = false;
                    return;  					
                }
            })
            .catch(error =>{
                console.log('Exception in saveRecords-->', error);
            }); 
        }
	}
    
    //Method for Toast Messages
    setToastvalues(toasttitle, toastmsg, toastvariant){
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}
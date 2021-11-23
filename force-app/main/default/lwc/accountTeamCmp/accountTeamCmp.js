/*******************************************************************
Created By          :   Sravanthi
Created Date        :   26-August-2021
Story               :   TEAM SFO Sprint 21.12 DIGI-8926
Desc                :   This is used for to fetch Account Team details and render Teams Component          
Lastmodified        :   DIGI-22590 :: Sprint 21.13 - implemented actual error messages for FIELD_CUSTOM_VALIDATION_EXCEPTIONs
***********************************************************************/
import { LightningElement, api, wire, track } from 'lwc';
import TEAMROLE_FIELD from '@salesforce/schema/AccountTeamMember.TeamMemberRole';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import getAccountTeamDetails from '@salesforce/apex/GetTeamDetailsController.getAccTeam'
import saveAccTeam from '@salesforce/apex/GetTeamDetailsController.saveAccTeam'
import userId from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DEFAULTTEAMPRESENT_ERROR from '@salesforce/label/c.AccountTeamDefaultTeamPresentError';
import DEFAULTTEAMABSENT_ERROR from '@salesforce/label/c.AccountTeamDefaultTeamAbsentError';
import OFFSHOREUSER_ERROR from '@salesforce/label/c.AccountTeamOffshoreUserError';
import DEFAULTSAVE_ERROR from '@salesforce/label/c.AccountTeamSaveError';
import DEFAULTLOAD_ERROR from '@salesforce/label/c.AccountTeamLoadError';

export default class AccountTeamCmp extends  NavigationMixin(LightningElement) {

    @api accountId;
    @track accTeamExisting = [];
    @track defaultTeam = [];
    @track ErrorMsg;
    @track isNonAccOwner =true;
    @track defTeamalreadypresentError = '';
    @track defTeamalreadyabsentError = '';

    title = 'Edit account team';
    offshoreAccount = false;
    @track isSpinner;
    
    @wire(getPicklistValues,

        {
            recordTypeId: '01228000000XckuAAC',
            fieldApiName: TEAMROLE_FIELD

        }

    )
    teamMemberRolePicklist;

    connectedCallback() {
        this.isSpinner = true;
        const getTeamInputs = { AccountId: this.accountId, userId: userId };
        getAccountTeamDetails(getTeamInputs)
            .then(result => {
                var userIdList =[];
                var defusercount =0;
                var isAccessOnlyRead =false;
                if (result) {
                    if(result.loggedInUserAccOwnerOrAdmin){
                        this.isNonAccOwner =false;
                    }
                    
                    if (result.OffshoreRestrictedUser) {
                        this.ErrorMsg= OFFSHOREUSER_ERROR;
                    }
                    else {
                        if (result.existingAccTeam) {
                            result.existingAccTeam.forEach(element => {
                               
                                this.accTeamExisting.push({
                                    'AccessLevel': element.AccountAccessLevel,
                                    'TeamMemberRole': element.TeamMemberRole,
                                    'UserId': element.UserId,
                                    'UserName': element.User.Name,
                                    'Id': element.Id,
                                    'exists': true
                                });
                                userIdList.push(element.UserId);
                            });
                        }
                        if (result.userdefaultAccTeam) {
                            var nonACCownerRead ;
                            result.userdefaultAccTeam.forEach(element => {
                                if(this.isNonAccOwner ){
                                    nonACCownerRead = 'Read';
                                }
                                else{
                                    nonACCownerRead =element.AccountAccessLevel;
                                }
                                if (userIdList.includes(element.UserId)) {
                                    this.defaultTeam.push({
                                        'AccessLevel': nonACCownerRead,
                                        'TeamMemberRole': element.TeamMemberRole,
                                        'UserId': element.UserId,
                                        'UserName': element.User.Name,
                                        'Id': element.Id,
                                        'exists': true,
                                        'isSelected': false,
                                        'alreadyTeam': true
                                    });
                                    defusercount =defusercount+1;
                                }
                                else {
                                    this.defaultTeam.unshift({
                                        'AccessLevel': nonACCownerRead,
                                        'TeamMemberRole': element.TeamMemberRole,
                                        'UserId': element.UserId,
                                        'UserName': element.User.Name,
                                        'Id': element.Id,
                                        'exists': true,
                                        'isSelected': false,
                                        'alreadyTeam': false
                                    });
                                }
                            });
                        }
                        if(this.defaultTeam.length == defusercount && this.defaultTeam.length!=0){
                            this.defTeamalreadypresentError = DEFAULTTEAMPRESENT_ERROR;
                        }
                        else if(this.defaultTeam.length == 0){
                            this.defTeamalreadyabsentError = DEFAULTTEAMABSENT_ERROR;
                        }

                    }
                }
                this.isSpinner =false;
            })
            .catch(error => {
                console.error(error);
                this.ErrorMsg= DEFAULTLOAD_ERROR;
                this.isSpinner =false;
            }
            )
    }

    SaveTeams(event) {
        this.isSpinner =true;
        var accteamList =[];
        var accteamDeleteList =[];
        var userIDLst =[];
        if (event.detail.teamList) {
            event.detail.teamList.forEach(element => {
                if (element.AccessLevel != '' && element.TeamMemberRole != '' && element.UserId.length > 10) {
                    accteamList.push({
                        'Id': element.Id.length > 10 ? element.Id : null,
                        'AccountAccessLevel': element.AccessLevel,
                        'TeamMemberRole': element.TeamMemberRole,
                        'UserId': element.UserId,
                        'AccountId': this.accountId
                    })
                    
                
                    
                    //for account team chatter 
                    if(!element.exists){
                        userIDLst.push(element.UserId);
                    }
                    //for default team chatter 
                    if(element.default){
                        userIDLst.push(element.UserId);
                    }
                }
            });
        }

        if(event.detail.teamMemTobeDeletedList){
        event.detail.teamMemTobeDeletedList.forEach(element=>{
            
            if(element.Id.length > 10){
            accteamDeleteList.push({
                'Id': element.Id,
                'AccountAccessLevel': element.AccessLevel,
                'TeamMemberRole': element.TeamMemberRole,
                'UserId': element.UserId,
                'AccountId': this.accountId
            })}
        });}
        var idList =[];
        if(userIDLst.length >0){
            idList= userIDLst;
        }
        else{
            idList= null;
        }
        const inputs ={ saveteamList: accteamList , teamMemToDeleteList : accteamDeleteList , userIdssaveList : idList ,AccountId :this.accountId}
        saveAccTeam(inputs)
            .then(
                result => {
                    if (result == 'success') {
                       
                        this.showsuccessToast();
                        this[NavigationMixin.Navigate]({
                            type: 'standard__recordPage',
                            attributes: {
                                recordId: this.accountId,
                                objectApiName: 'Account',
                                actionName: 'view'
                            }
                        });
                    }
                    else if( result.includes('offshore restricted')){
                        this.ErrorMsg= result;
                    }
                   
                }
            )
            .catch(error => {
                console.error(error);
                //DIGI-22590 :: Sprint 21.13
                if (typeof error.body.message === 'string' && error.body.message.includes('FIELD_CUSTOM_VALIDATION_EXCEPTION,')) {
                    this.ErrorMsg = error.body.message.split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1].trim().split(':')[0];
                }else{
                    this.ErrorMsg= DEFAULTSAVE_ERROR;
                }
            })
            
            this.isSpinner =false;
    }
    showsuccessToast() {
        const event = new ShowToastEvent({
            title: 'Success!',
            message: 'The record has been saved successfully.',
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}
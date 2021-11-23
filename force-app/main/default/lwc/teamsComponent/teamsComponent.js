/*******************************************************************
Created By          :   Sravanthi
Created Date        :   26-August-2021
Story               :   TEAM SFO Sprint 21.12 DIGI-8926
Desc                :   This is used for Teams Component Display            
***********************************************************************/
import { api, LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import DELETEMEMBER_ERROR from '@salesforce/label/c.AccountTeamDeleteConfirmation';
import REMOVEALL_ERROR from '@salesforce/label/c.AccountTeamRemoveALLConfirmation';

export default class TeamsComponent extends NavigationMixin(LightningElement) {
    @api teamMemberRoleoptions;
    @api teamListParent; // This is the existing sobject team which is passed from parent component.
    @api defaultTeamListParent;  // This is users default sobject team which is passed from parent component.
    @api title; // Title of the component
    @api isDefaultTeamCmp = false; // Trigger User default team component
    @api recordId;
    @api isErrorMsg;
    @api isNonAccOwner = false;
    @api defTeamPresentError = ''; //  Error messasge for user default team already presnet in team 
    @api defTeamAbsentError = '';//  Error messasge for user default team is not setup by user
    @api sobjectName;
    @track isModalOpen = false;
    @track selectAll;
    @track teamList = [];
    @track selectOneUserError='';
   
    filterstring = 'isActive= true  AND Name  !=\' \'';
    confirmationSaveButton = 'Save';
    confirmationHeader = '';
    teamMemIndexTobeDeleted;
    teamMemTobeDeletedList = [];
    confirmationPopUpMessage;

    acessLeveloptionsReadWrite = [
        { label: 'Read Only', value: 'Read' },
        { label: 'Read/Write', value: 'Edit' }
    ];


    connectedCallback() {
        if (this.teamListParent) {
            this.teamListParent.forEach(element => {
                this.teamList.push({
                    'AccessLevel': element.AccessLevel,
                    'TeamMemberRole': element.TeamMemberRole,
                    'UserId': element.UserId,
                    'UserName': element.UserName,
                    'Id': element.Id,
                    'exists': element.exists //This will make the lookup on user as readonly
                });
            });
        }

        if (this.teamList.length == 0) {
            this.onAddRow();
        }
    }

    onAddDefaultTeam() {
        if (this.defTeamPresentError != '') {
            this.isErrorMsg = this.defTeamPresentError;
        }
        else if (this.defTeamAbsentError != '') {
            this.isErrorMsg = this.defTeamAbsentError;
        }
        else {
            this.isDefaultTeamCmp = true;
            if (this.defaultTeamListParent) {
                this.teamList = [];
                this.defaultTeamListParent.forEach(element => {
                    this.teamList.push({
                        'AccessLevel': element.AccessLevel,
                        'TeamMemberRole': element.TeamMemberRole,
                        'UserId': element.UserId,
                        'UserName': element.UserName,
                        'Id': element.Id,
                        'exists': element.exists, //This will make the lookup on user as readonly
                        'isSelected': element.isSelected, // this is used when user selects from default list team to make it default
                        'alreadyTeam': element.alreadyTeam // this is used to make the row readonly when the  user from default team is already present in team
                    })
                });
            }
        }
    }

    handlerecordselection(event) {
        let userId = event.detail.selectedRecordId;
        let accessIndex = event.target.dataset.index;
        this.teamList[accessIndex].UserId = userId;
    }

    handleChange(event) {
        let value = event.target.value;
        let accessIndex = event.target.dataset.index;
        if (event.target.name == 'accesslevel') {
            this.teamList[accessIndex].AccessLevel = value;
            if(this.teamList[accessIndex].exists){
                this.teamList[accessIndex].isChanged =true;
            }
        }
        else if (event.target.name == 'teamrole') {
            this.teamList[accessIndex].TeamMemberRole = value;
            if(this.teamList[accessIndex].exists){
                this.teamList[accessIndex].isChanged =true;
            }
        }
    }

    cancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: this.sobjectName,
                actionName: 'view'
            }
        });
    }

    onAddRow() {
        let tempArray = [];
        var listSize = this.teamList.length + 1;
        var accessLevel='';
        if(this.isNonAccOwner){
            accessLevel = 'Read';
        }
        tempArray.push({
            'AccessLevel': accessLevel,
            'TeamMemberRole': '',
            'UserId': listSize,
            'UserName': '',
            'Id': listSize,
            'isChanged':true
        });
        this.teamList = this.teamList.concat(tempArray);
    }
    save() {
        var saveTeamList = [];
        if (this.isDefaultTeamCmp) {
            this.teamList.forEach(element => {
                if (element.isSelected) {
                    saveTeamList.push({
                        'AccessLevel': element.AccessLevel,
                        'TeamMemberRole': element.TeamMemberRole,
                        'UserId': element.UserId,
                        'UserName': element.UserName,
                        'Id': '1',
                        'exists':element.exists,
                        'default':true
                    });
                }
            });
            if(saveTeamList.length == 0){
                this.selectOneUserError = 'Please select at least one user to add.';
            }
            else{
                this.selectOneUserError = '';
            }
        }
        else {
            this.teamList.forEach(element => {
                if (element.isChanged) {
                    saveTeamList.push({
                        'AccessLevel': element.AccessLevel,
                        'TeamMemberRole': element.TeamMemberRole,
                        'UserId': element.UserId,
                        'UserName': element.UserName,
                        'Id': element.Id,
                        'exists':element.exists
                    });
                }
            });
        }
        if(!this.isDefaultTeamCmp || (this.isDefaultTeamCmp && this.selectOneUserError=='')){
            const saveEvt = new CustomEvent('saveteam', {
                detail: { teamList: saveTeamList, teamMemTobeDeletedList: this.teamMemTobeDeletedList }
            });
            this.dispatchEvent(saveEvt);
            this.teamMemTobeDeletedList = [];
        }
    }


    openModal(message, header) {
        this.isModalOpen = true;
        this.confirmationPopUpMessage = message;
        this.confirmationHeader = header;
    }

    onRemoveSave() {
        if (this.confirmationSaveButton == 'Delete') {
            this.onRemoveSingle();
        }
        else if (this.confirmationSaveButton == 'Remove') {
            this.onRemoveAllConfirm();
        }

    }

    closeModal() {
        this.isModalOpen = false;
        this.teamMemIndexTobeDeleted = null;

    }

    removeTeam(event) {
        this.teamMemIndexTobeDeleted = event.target.dataset.index;
        this.confirmationSaveButton = 'Delete';
        var Message = DELETEMEMBER_ERROR;
        this.openModal(Message, 'Record Delete Confirmation');
    }

    onselectAll(event) {

        var tempListvar = [];
        this.teamList.forEach(team => {
            var select;
            if (team.alreadyTeam) {
                select = false;
            }
            else {
                select = event.target.checked;
            }
            tempListvar.push({
                'AccessLevel': team.AccessLevel,
                'TeamMemberRole': team.TeamMemberRole,
                'UserId': team.UserId,
                'UserName': team.UserName,
                'Id': team.Id,
                'exists': team.exists,
                'isSelected': select,
                'alreadyTeam': team.alreadyTeam
            });
        });
        this.selectAll = event.target.checked;
        this.teamList = tempListvar;
    }
    onselect(event) {
        var index = event.target.dataset.index;
        this.teamList[index].isSelected = event.target.checked;
    }

    onRemoveSingle() {

        if (this.teamList[this.teamMemIndexTobeDeleted] && this.teamList[this.teamMemIndexTobeDeleted].Id && this.teamList[this.teamMemIndexTobeDeleted].Id.toString().length > 5) {
            this.teamMemTobeDeletedList.push(this.teamList[this.teamMemIndexTobeDeleted]);
        }
        this.teamList.splice(this.teamMemIndexTobeDeleted, 1);
        this.teamMemIndexTobeDeleted = null;
        this.isModalOpen = false;
    }

    onRemoveAllConfirm() {
        const saveEvt = new CustomEvent('saveteam', {
            detail: { teamList: null, teamMemTobeDeletedList: this.teamList }
        });
        this.dispatchEvent(saveEvt);
    }

    onRemoveAll() {
        this.confirmationSaveButton = 'Remove';
        var Message = REMOVEALL_ERROR;
        this.openModal(Message, 'Remove team members?');
    }



}
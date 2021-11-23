import { LightningElement , track , api } from 'lwc';
import inlineUpdateNotifications from '@salesforce/apex/NotificationPreferenceCtrl.inlineUpdateNotifications';
import updateBulkNotifications from '@salesforce/apex/NotificationPreferenceCtrl.updateBulkNotifications';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
export default class NotificationPreferenceresult extends LightningElement {
    @api recordsdata=[];  
    @api recordata=[]; 
    @track error; 
    @track check; 
    @track commType;


    @track optin = true;


    @track contactId;
    @track contactName;
    @track accountRecordId;  
    @track fieldreadonly = false;
    @track isLoaded = false;
    @track enableUpdateBtn = true;
    @track selectedList = [];
    @track inlineUpdatedata;
    @track toasttitle;
    @track toastmsg
    @track toastvariant;





    @track contactfilterStr='Contact_Status__c=\'Active\'';
    @track contactdatafilter;
    connectedCallback(){
        this.getdata(this.recordata);





    }
    @api
    getdata(notificationdata){
        this.recordata = notificationdata;




        this.isLoaded = false;
        if(this.recordata!=null || this.recordata!=undefined){
            this.isLoaded = true;
            var notificationObject = JSON.parse(JSON.stringify(this.recordata));
            this.accountRecordId  = notificationObject.accId;
            this.contactfilterStr += ' AND accountid=\''+this.accountRecordId+'\''; 
            this.contactfilterStr += ' AND Authority__c=\'Full Authority\'';
            this.contactdatafilter = ' AND accountid=\''+this.accountRecordId+'\'' +' AND Authority__c=\'Full Authority\''; 





            this.recordsdata = notificationObject.notificationList; 
            console.log("this.recordsdata", this.recordsdata);
            this.check=true;
            this.isLoaded = false;
        }  


        this.isLoaded = false;  



    }


    onContactSelection(event){
        this.contactName = event.detail.selectedValue;  
        this.contactId = event.detail.selectedRecordId; 




    }
 
    getNotificationDetails(){
        
        getAllNotifications()
        .then(result => {




            this.recordata = result;
            this.check = true;
            console.log(' this.recordata', this.recordata);
        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
    }
    getselectedrowlist(event){
        var recordData  = event.detail;
        this.selectedList = JSON.parse(recordData.selectedRow);
        if(this.selectedList.length>0){
            this.enableUpdateBtn=false;
        }
        else{
            this.enableUpdateBtn=true;
        }
        console.log("selectedList: ",this.selectedList);

    }
    updatedata(event){
        var recordData  = event.detail;
        this.inlineUpdatedata = recordData.recordsString;

		var inlineUpdateNotification=JSON.parse(recordData.recordsString);



        if(inlineUpdateNotification[0].Communication_Method__c =='EMAIL' && (inlineUpdateNotification[0].Contact_Id__c==null || inlineUpdateNotification[0].Contact_Id__c==undefined || inlineUpdateNotification[0].Contact_Id__c=='')){
         
			this.setToastvalues('Error', 'Auth reps email address is required for Email notifications. Please select an Auth Rep contact', 'error');
            return;
        }

        if(inlineUpdateNotification[0].Communication_Method__c =='SMS' && (inlineUpdateNotification[0].Contact_Id__c!=null && inlineUpdateNotification[0].Contact_Id__c!='')){

			this.setToastvalues('Error', 'Contact is not required. SMS Notifications will be sent to the mobile number associated to the service', 'error');
            return;
        }
        if(inlineUpdateNotification[0].IsActive__c ==false && inlineUpdateNotification[0].Notification_Type__c=='IR Welcome'){
			this.setToastvalues('Error', 'IR Welcome notifications cannot be Opted Out', 'error');
            return;



        }



        inlineUpdateNotifications({
            selectedNotifications : this.inlineUpdatedata
        })
        .then(result => {
            console.log('result data:',result);




            if(result != 'Success'){
				this.setToastvalues('Error', result, 'error'); ////EDGE-170965
                
			}




        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })

    }
    get options() {
        return [
            { label: 'Email', value: 'Email' },
            { label: 'SMS', value: 'SMS' }
        ];
    }
    handleCommchange(event){
        this.value = event.detail.value;
    }
    selectCheckbox(event){
        this.optin = event.detail.checked;
    }



    handleUpdateNotification(event){
        var updateData = {optin:this.optin, contactId:this.contactId, ComMethod:this.value};
        //EDGE-170965:Validation on Edit notification

             for(var i=0;i< this.selectedList.length;i++)  { 
            if(this.value =='Email' && (this.contactId ==null ||  this.contactId ==undefined)){
                this.setToastvalues('Error', 'Auth reps email address is required for Email notifications. Please select an Auth Rep contact', 'error');
                return;
            }

            if(this.value=='SMS' && (this.selectedList[i].Contact_Id__c!=null && this.selectedList[i].Contact_Id__c!=undefined && this.selectedList[i].Contact_Id__c!='')){
                this.setToastvalues('Error', 'Contact is not required. SMS Notifications will be sent to the mobile number associated to the service', 'error');



                return;
            }
            if((this.value=='EMAIL' || this.value==undefined) && this.selectedList[i].Communication_Method__c=='SMS' && (this.contactId!=null &&  this.contactId!=undefined)  ){
                this.setToastvalues('Error', 'Contact is not required. SMS Notifications will be sent to the mobile number associated to the service', 'error');




                return;
            }
             if(this.selectedList[i].Notification_Type__c=='IR Welcome' && this.optin==false){
                this.setToastvalues('Error', 'IR Welcome notifications cannot be Opted Out', 'error');
                return;
            }
            
        }



      


        console.log('selectedList:',this.selectedList);
        console.log('JSON.stringify(this.selectedList):',JSON.stringify(this.selectedList));
        console.log('JSON.stringify(updateData):',JSON.stringify(updateData));
        updateBulkNotifications({
            selectedNotifications : JSON.stringify(this.selectedList),
            updateDetails  : JSON.stringify(updateData)
        })
        .then(result => {
            console.log('result data:',result);




            if(result != 'Success'){
				this.setToastvalues('Error', result, 'error'); //EDGE-170965:Validation
            
            }
            else{
                this.createRefreshEvent();
            }
            this.selectedList=[];
            this.enableUpdateBtn=true;



        })
        .catch(error => {
            console.log('error data:',error);
            this.error = error;
        })
    }
    setToastvalues(toasttitle, toastmsg, toastvariant) {
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }





    createRefreshEvent(){
        // Creates the event with the data.
        console.log("in createRefreshEvent");
        const selectedEvent = new CustomEvent("callrefreshvaluechange");
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }






}
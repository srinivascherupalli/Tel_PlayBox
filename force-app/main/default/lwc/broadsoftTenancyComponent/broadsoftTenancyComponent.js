import { LightningElement,track,api } from 'lwc';
import BW_OptionsErrorMessage from '@salesforce/label/c.BW_OptionsErrorMessage';
import getLegacyServices from '@salesforce/apex/BroadsoftTenancyController.getLegacyServices';

export default class BroadsoftTenancyComponent extends LightningElement {
    value = '';
    category='Broadsoft Tenancy';
    @track tenancyOptions='';
    @track legacyId='';
    @track toasttitle;
    @track toastmsg;
    @track toastvariant;
    @api basketid;
    @track error;
    @track loadspinner = false;
    @track showLegacyTable = false;
    @track legacyDetailWrapper;
    @track legacyDetailsList = [];
   
    get options() {
        return [
            { label: 'New Tenancy', value: 'New' },
            { label: 'Choose from Legacy Tenancies', value: 'Legacy' },
        ];
    }
    handleOptionChange(event) {
        //const selectedOption = event.detail.value;
        this[event.target.name] = event.target.value;
        if(this[event.target.name]=='Legacy'){
            //make callout
            this.getServicesCallout();
        }
        //INC000097815664---Fix
        if(this[event.target.name]=='New'){
            this.legacyId = '';
            this.showLegacyTable = false;
        }
        if(event.target.name=='legacyId'){
            this.legacyId = event.target.value;
            console.log('this.legacyId : ',this.legacyId);
        }
        console.log('Option selected with value: ' + this[event.target.name]);
    }

    getServicesCallout(){
        this.loadspinner = true;
        getLegacyServices({
            basketid: this.basketid,  
        })
            .then(result => {
                this.legacyDetailWrapper = result;
                console.log('result on create result: ', result);
                if(this.legacyDetailWrapper!=null || this.legacyDetailWrapper!=undefined){
                    if(this.legacyDetailWrapper.message!='Success'){
                        this.setToastvalues('Error', this.legacyDetailWrapper.message, 'error');
                    }
                    else{
                       this.legacyDetailsList  = this.legacyDetailWrapper.legacyDetails;
                       this.legacyId = this.legacyDetailWrapper.legacyDetails[0].legacyId;
                       this.showLegacyTable = true;
                    }
                }
                this.loadspinner = false;
               
            })
            .catch(error => {
                console.log('error data:', error);
                this.error = error;
                this.loadspinner = false;
            })
    }
    handleClick(event) {
        if(this.tenancyOptions==undefined || this.tenancyOptions==''){
            console.log('Option selected with value: ' + this.tenancyOptions);
            //Show error message.
            this.setToastvalues('Error', BW_OptionsErrorMessage, 'error');

        }
        else{
            //EDGE:220237 called on Add Tenancy
            var tenancyMap = new Map();
            tenancyMap.set('Info', 'Tenancy product for Adaptive Collaboration');
            tenancyMap.set('LegacyTenancyId',this.legacyId);
            console.log(tenancyMap);
            let payload =
            {
                command: 'createBroadsoftTenancy',
                data: tenancyMap, //selectedMsidns,
                caller: this.category
            };
            window.parent.postMessage(payload, '*');
            sessionStorage.setItem("payload", payload);
            this.handleClose();
        }	
	}
    //EDGE:220237 called to close window
    handleClose(event) {
		window.parent.postMessage("close", '*');
		sessionStorage.setItem("close", "close");
	}
      /**********************************************************************************************************
    EDGE        - 216668
    Method      - setToastvalues
    Description - set toast values
    Author      - Kalashree Borgaonkar
    ************************************************************************************************************/
    setToastvalues(toasttitle, toastmsg, toastvariant) {
        this.toasttitle = toasttitle;
        this.toastmsg = toastmsg;
        this.toastvariant = toastvariant;
        this.template.querySelector('c-lwc-custom-toast').showCustomNotice();
    }
}
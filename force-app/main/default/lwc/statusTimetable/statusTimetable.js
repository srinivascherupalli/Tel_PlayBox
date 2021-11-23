/*
*@Created Date : 16/12/2020
*@CreatedBy : Kamlesh Kumar
*@EDGE - 189844 
*/
import { LightningElement,api,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class StatusTimetable extends NavigationMixin(LightningElement) {
   
    @api headertitle;
    @api asyncstatus;
    @api progressbartitle;
    @api progressbarcolor;
    @api timetabletitle;
    @api statustitle;
    @api progresstitle;
    @api isstatuscompleted;
    @api isstatusinprogress;
    @api isstatuserror;
    @api timetable;
    @api isstatusrunning;
    @api closewindow;
    @api closewindowandredirect;
    @api currentbatchcompleted;
    @track showCloseButton = false;
    @track isModalOpen = true;
    
    renderedCallback() {
        if(this.isstatuscompleted || this.isstatuserror) {
            this.showCloseButton = true;
        }
    }

    closeModal() {
        if(this.closewindowandredirect) {
            
           var lwcMessage = 'navigateToRecord';
            this.dispatchEvent(new CustomEvent('closesignal', 
    {
        detail: { data:  lwcMessage},
        bubbles: true,
        composed: true,
    }));
    // let message = 'testing';
    //     this.template.querySelector('iframe').contentWindow.postMessage(message, this.origin);

        }

        else if(this.closewindow) {
            var lwcMessage = 'close';
            this.dispatchEvent(new CustomEvent('closesignal', 
    {
        detail: { data:  lwcMessage},
        bubbles: true,
        composed: true,
    }));
    // let message = 'testing';
    //     this.template.querySelector('iframe').contentWindow.postMessage(message, this.origin);
        }
        
    }

}
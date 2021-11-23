import { LightningElement,track,api } from 'lwc';
export default class ProgressBar extends LightningElement {
    @api lstopp;
    @track error;

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = `c-vertical-progress-indicator .slds-icon-text-default {
            fill: white!important;
        }`;
        this.template.querySelector('lightning-icon').appendChild(style);
    }
    
}
import { LightningElement, track } from 'lwc';

export default class search extends LightningElement {
    @track searchKey;
    handleChange(event){
        this.searchKey = event.target.value;
        event.preventDefault();
        const searchEvent = new CustomEvent('searchaccounts', {detail: this.searchKey});
        console.log('********dispatching searchEvent*********'+this.searchKey);
        this.dispatchEvent(searchEvent);
    }
}
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PRMQuickAction extends NavigationMixin(LightningElement) {

    toggleQuickCreate = () => {
        let ulDOM = this.template.querySelectorAll("ul");
        if (ulDOM.length > 0) {
            if (ulDOM[0].firstChild.className === "close") {
                ulDOM[0].firstChild.className = "open";
            } else {
                ulDOM[0].firstChild.className = "close";
            }
        }
    }

    // Navigate to new Record Page

    newRecord(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: event.target.dataset.id,
                actionName: 'new'
            }
        });
    }
}
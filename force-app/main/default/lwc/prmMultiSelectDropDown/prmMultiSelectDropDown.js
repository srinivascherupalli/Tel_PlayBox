import { LightningElement, track, api } from 'lwc';

export default class PrmMultiSelectDropDown extends LightningElement {
    @track dropDownBuild;
    @api
    get dropDownValue() {
        return this.dropDownBuild;
    }
    set dropDownValue(value) {
        this.dropDownBuild = value.map(obj => {
            return { id: obj.id, value: obj.value, selected: obj.selected };
        });
    }

    dropVal = [];
    handleSelection = (event) => {
        event.preventDefault();
        this.options = this.dropDownBuild.map(op => {
            if (event.target.dataset.id == op.id) {
                op.selected = !op.selected;
            }
            return op;
        });

        // 1. Create a custom event that bubbles.
        const selectEvent = new CustomEvent('categorychange', {
            detail: this.options
        });
        // 2. Fire the custom event
        this.dispatchEvent(selectEvent);
    }

}
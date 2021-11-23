import { LightningElement, api } from 'lwc';
import template from './showSubCellButton.html';

export default class showSubCellButton extends LightningElement {
    @api rowId;
    @api attrA;
    @api attrB;
    render() {
        console.log('Inside showSubCellButton');
        return template;
    }
   handleClick() {
    console.log('Inside showSubCellButton handleClick',this.rowId,this.attrA,this.attrB);
    this.dispatchEvent(new CustomEvent('showpoponsub', {
        composed: true,
        bubbles: true,
        cancelable: true,
        detail: {
            rowId: this.rowId,
            solId: this.attrA
        },
    }));
}
}
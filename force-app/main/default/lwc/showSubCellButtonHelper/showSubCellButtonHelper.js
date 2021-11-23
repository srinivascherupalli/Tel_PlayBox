import LightningDatatable from 'lightning/datatable';
import showSubTemplate from './showSubTemplate.html';
/* eslint-disable no-console */
console.log('Inside showSubCellButtonHelper')
export default class showSubCellButtonHelper extends LightningDatatable  {
    
    static customTypes = {
        showSub: {
            template: showSubTemplate,
            typeAttributes: ['attrA', 'attrB'],
        }
    };
}
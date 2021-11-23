import { LightningElement, api, track } from 'lwc';

export default class PrmPaginationComp extends LightningElement {
    // Api considered as a reactive public property.  
    @api totalrecords;
    @api currentpage;
    @api pagesize;
    //@api pageNumber;
    @api pageSizeOption;
    // Following are the private properties to a class.  
    lastpage = false;
    firstpage = false;

    // getter  
    get showFirstButton() {
        if (this.currentpage == 1) {
            return true;
        }
        return false;
    }
    // getter  
    get showLastButton() {
        if (Math.ceil(this.totalrecords / this.pagesize) == this.currentpage) {
            return true;
        }
        return false;
    }

    get recordNoCount() {
        let recordCountList = [];
        for (let i = 1; i <= Math.ceil(this.totalrecords / this.pagesize); i++) {
            recordCountList.push({ value: i });
        }
        return recordCountList;
    }
    //Fire events based on the button actions  
    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }
    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handleChange = (event) => {
        this.dispatchEvent(new CustomEvent('pagesize', {
            detail: event.target.value
        }));
    }

    handlePageClickChange = (event) => {
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('pagecountchange', {
            detail: event.target.dataset.id
        }))
    }
}
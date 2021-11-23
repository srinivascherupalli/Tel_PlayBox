import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getListViewIds from '@salesforce/apex/ReturnListViewDetails.getNBAListViewsInfo';
import NBALogo from '@salesforce/resourceUrl/EinsteinNextBestActionImage';

export default class NavigateToListViewFromHomePage extends NavigationMixin(LightningElement) {
    @api listViewIds;
    @track selectedListView;
    @track error;
    @track reachCustomer;
    NBALogoUrl = NBALogo;

    constructor() {
        super();
        getListViewIds()
            .then((result) => {
                this.listViewIds = result;
                // console.log('listViewIds '+result.length());
            })
            .catch(error => {
                this.error = 'Error received: code' + error.errorCode + ', ' +
                    'message ' + error.body.message;
            });
    }

    navigateToListView(event) {
        //alert(event.target.getAttribute('data-item'));

        console.log(event.target.dataset.item);
        console.log(this.error);
        console.log(this.listViewIds);
        var id = event.target.dataset.item;

        var fileobj = this.listViewIds.find(obj => obj.listViewId === id)
        console.log(fileobj);
        // Navigate to the Contact object's Recent list view.
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: fileobj.objectName,
                actionName: 'list'
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.

                filterName: fileobj.listViewId //'Recent' // or by 18 char '00BT0000002TONQMA4' event.currentTarget.dataset.item
            }
        });
    }
}
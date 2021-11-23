import { LightningElement, wire } from 'lwc';
// import Banner_Image from '@salesforce/resourceUrl/styles';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.FirstName';

const fields = [NAME_FIELD]
export default class PrmHeaderBanner extends LightningElement {
  // Bannerimage1 = Banner_Image + '/img/banner1.jpg';
  userId = Id;

  @wire(getRecord, { recordId: '$userId', fields })
  user;

  get name() {
    return getFieldValue(this.user.data, NAME_FIELD);
  }
}
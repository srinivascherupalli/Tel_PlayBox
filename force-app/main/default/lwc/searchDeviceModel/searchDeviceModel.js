import { LightningElement, api } from 'lwc';

export default class SearchDeviceModel extends LightningElement {
  @api isPartnerUser;
  /*----------------------------------------------------------------------
 EDGE        -150172
 Method      -closeModal
 Description -close Modal on click of close icon on Modal
 Author      -Dheeraj Bhatt
 -----------------------------------------------------------------------*/
  closeModal() {
    const closeModal = new CustomEvent('close');
    this.dispatchEvent(closeModal);
  }
}
import {  LightningElement, track} from 'lwc';
import { NavigationMixin} from 'lightning/navigation';
import IMAGES from '@salesforce/resourceUrl/Fulfillment_Menu_Images';
import TCPS_FLI_URLPROD from '@salesforce/label/c.TCPS_FLI_URL_PROD';
import TCPS_FLI_URL_SANDBOX from '@salesforce/label/c.TCPS_FLI_URL';
import PSMDM_FLI_URLPROD from '@salesforce/label/c.PSMDM_FLI_URL_PROD';
import PSMDM_FLI_URL_SANDBOX from '@salesforce/label/c.PSMDM_FLI_URL';

export default class ProfessionalServices_Menu_Component extends NavigationMixin(LightningElement) {
       
    @track TCPS_FLI_URL;
    @track PSMDM_FLI_URL;
    @track inputValue;
    TCImage =IMAGES +'/Solution_TelstraCollaboration.png';
    MDMImage =IMAGES +'/TMDMImage.png';
  
    connectedCallback() {        
        var redirectURL = window.location.href;
        console.log('redirectURL'+redirectURL); 
        if(redirectURL.includes('partners.enterprise.telstra.com.au') == true){
           this.TCPS_FLI_URL=TCPS_FLI_URLPROD;    //'/s/fulfilment-items-access'
           this.PSMDM_FLI_URL=PSMDM_FLI_URLPROD;  //'/s/psmdm-engineering-user-list' 
         }
         else{
            this.TCPS_FLI_URL=TCPS_FLI_URL_SANDBOX;   //'/partners/s/fulfilment-items-access';
            this.PSMDM_FLI_URL=PSMDM_FLI_URL_SANDBOX; //'/partners/s/psmdm-engineering-user-list'
        }
  
      }


}
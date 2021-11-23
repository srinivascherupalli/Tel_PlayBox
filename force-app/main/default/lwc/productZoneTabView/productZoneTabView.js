/**
   *  Description of the purpose of the method.
   *  @name                              : productZoneTabView
   *  @description                       : This LWC is used to display the Product Zone details in tab view
   *  @return 				 	         : - 
   *  @Jira Story Ref                    : DIGI-15723
   *  @createdBy  				         : Ajith Kumar, Nitin Kumar
**/
import { LightningElement,api, track, wire } from 'lwc';
import refreshProductChargeZoneInfo from '@salesforce/apex/ChargeProductZoneHandler.refreshProductChargeZoneInfo';
import LOCALE from '@salesforce/i18n/locale';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

const columnsProductAvailability = [
    { label: 'Product', fieldName: 'name',type:'text' },
    { label: 'Availability', fieldName: 'availability', type: 'text' }
];

const columnsVendorMaintenance = [
	{ label: 'Vendor', fieldName: 'vendor',type:'text' },
    { label: 'Availability', fieldName: 'availability', type: 'text' }
];
export default class ProductZoneTabView extends LightningElement {

@track loaded=false;
@api recordId;
results;
data;
productAvailability;
maintenanceAvailability;
zone;
sla;
mdn;
lastVerificationDate;
formattedDate;
activeSections=['ProductZoneInfo'];
columnsProductAvailability=columnsProductAvailability;
columnsVendorMaintenance = columnsVendorMaintenance;


connectedCallback(){
    this.getProductChargezoneInfo();
}
    
//DIGI-15723 Method to fetch the product Zone response from apex class
getProductChargezoneInfo(){
    refreshProductChargeZoneInfo({siteRecordId: this.recordId,isImmediate:false})//DIGI-15723 changed from fetchProductChargeZoneInfo to refreshProductChargeZoneInfo method
        .then(result => {
            this.loaded=true;
            this.results=result;
            //DIGI-15723 Checking the status code to show toast message if response is not 200 or 201
            if(this.results.statusCode!=200 && this.results.statusCode!=201){
                this.dispatchEvent(              
                    new ShowToastEvent({
                        message: 'Could not retrieve Product Zone Information. Hit ‘Refresh’ to try again.',
                        variant: 'error'
                    })
                )
            }
            else{
                if(this.results.lastVerificationDate){
                    this.lastVerificationDate=this.getDate(this.results.lastVerificationDate);
                }
                if(this.results.zone){              
                    this.productAvailability=this.results.zone.products;
                    this.zone=this.results.zone.rental;
                    this.mdn=this.results.zone.mdn;
                    this.sla=this.results.zone.sla;
                }
                if(this.results.maintenance){
                    this.maintenanceAvailability=this.results.maintenance;
                }
            }
        })
        .catch(error => {
            this.loaded=true;
            this.error=error;
            this.dispatchEvent(              
                new ShowToastEvent({
                    message: 'Could not retrieve Product Zone Information. Hit ‘Refresh’ to try again.',
                    variant: 'error'
                })
            )
        });
}
//DIGI-15723 Method called on click of refresh button from product Zone tab
handleRefresh(){
     this.loaded=false;
     refreshProductChargeZoneInfo({siteRecordId: this.recordId,isImmediate:true}) //DIGI-15723 added one boolean parameter
    .then(result =>{
        this.data=result;
        this.loaded=true;
        //DIGI-15723 Checking the status code to show toast message if response is not 200 or 201
        if(this.data.statusCode!=200 && this.data.statusCode!=201){
            this.dispatchEvent(              
                new ShowToastEvent({
                    message: 'Could not retrieve Product Zone Information. Hit ‘Refresh’ to try again.',
                    variant: 'error'
                })
            )
        }
        else{
            if(this.data.lastVerificationDate){
                this.lastVerificationDate=this.getDate(this.data.lastVerificationDate);
            }
            if(this.data.zone){
                this.productAvailability=this.data.zone.products;;
                this.zone=this.data.zone.rental;
                this.mdn=this.data.zone.mdn;
                this.sla=this.data.zone.sla;               
            }
            if(this.data.maintenance){
                this.maintenanceAvailability=this.data.maintenance;
            }
        }
    })
    .catch(error => {
        this.loaded=true;
        this.error=error;
        this.dispatchEvent(              
            new ShowToastEvent({
                message: 'Could not retrieve Product Zone Information. Hit ‘Refresh’ to try again.',
                variant: 'error'
            })
        )
    });
}

//DIGI-15723 Method to get the Date format
getDate(dateValue){
    if(dateValue){
        var dateFormat=new Date(dateValue);
        let formatter = new Intl.DateTimeFormat(LOCALE, {
            year: "numeric" ,                
            month: "2-digit",                
            day: "2-digit",                
            hour: "2-digit",                
            minute: "2-digit",                
            hour12: "true"                
            }) 
        this.formattedDate = formatter.format(dateFormat);
        return this.formattedDate;
    }
    else return null;        
}
}
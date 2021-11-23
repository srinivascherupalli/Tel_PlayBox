import { LightningElement, track, api } from 'lwc';
import getTopProductCategories from '@salesforce/apex/PRMProductCategoryContr.getTopProductCategories';
import getBaseURL from '@salesforce/apex/salesup_ThankYouScreenController.returnBaseUrl';
//import categoryLandingUrl from '@salesforce/label/c.PRMCategoryLandingUrl';
import { reduceErrors } from 'c/ldsUtils';
export default class PRMProductCategories extends LightningElement {
    
    // Array of Product Categories to be displayed
    @track productCategories=[];
    //Categories to fetch from server
    @api categoryName;
    //Categories to exclude - Added by Team Hawaii for P2OB-9636
    @api excludeCategory;
    //Clone product categories for pagination
    cloneProductCategories = [];
    //Show view all button
    @track showViewAllButton = false;
    //Landing Page URL
    @track landingURL;
    //Categories per row
    //@api tilesPerRow;
    //Image Url
    @track imageUrl;
    //CategoryView
    @track categoryAtTop=true;
    //Include View All
    @api viewAllCategories=false;
    //Number of Categories to Display
    @api categoriesToDisplay;
    //Header Name
    @api headerName;
    hasRendered  = false;
    baseURL; // DIGI-15298

    connectedCallback(){
        this.getCategories();
        // DIGI-15298 : adding baseurl invocation to get base url dunamically across all environments
        getBaseURL()
        .then(result => {
            this.baseURL = result+'/s/category-landing';
            console.log('*****base url*****'+this.baseURL);
        })
        .catch(error => {
        });
    }



    /*renderedCallback(){
        if(this.hasRendered){
            //console.log('getHtmlContent'+getHtmlContent);
            const getHtmlContent = this.template.querySelectorAll('ul');
            console.log('getHtmlContent'+getHtmlContent);
            if(getHtmlContent != undefined){
                getHtmlContent.classList.add('active');
            }
        }
            
            
            this.template.querySelectorAll('li').classList.add('slds-size_1-of-4');
            this.template.querySelector('li').classList.remove('slds-size_1-of-3');
        
    }*/

    getLandingPage = (event) => {
        event.preventDefault();
        //Api Name of Selected Product
        let productName = event.currentTarget.dataset.id;
        //this.landingURL=categoryLandingUrl+'?categoryName='+productName+'&defaultFieldValues='+this.categoryName+','+productName; // DIGI-15298 OLD CODE
        this.landingURL=this.baseURL+'?categoryName='+productName+'&defaultFieldValues='+this.categoryName+','+productName; // DIGI-15298
        window.location.href = this.landingURL;
    }

    // Call apex to get categories 
    getCategories(){
        getTopProductCategories({categoryName : this.categoryName}).then(result =>{
            if(result){

                this.productCategories=result;
                let offSetSart;
                let offSetEnd;
                //Added by Team Hawaii for P2OB-9636
                let forNavigation = false;
                let excludedValues;
                if(this.excludeCategory !== null && this.excludeCategory !== "" && this.excludeCategory !== undefined)
                {
                    forNavigation = true;
                    excludedValues = this.excludeCategory.split(",");
                }
                let tempCategories = Object.values(this.productCategories);
                
                //this.imageUrl="background-image:url('https://tpcdev-telstra.cs152.force.com/partners/sfsites/c/resource/retaillive/retaillive/images/Data&IP.png');"

                //Added by Team Hawaii for P2OB-9636
                if(forNavigation)
                {

                for(let i=0; i < excludedValues.length; i++){
                    let category = excludedValues[i];
                    let index = this.productCategories.map(function(e) { return e.categoryApi; }).indexOf(category);
                    if(index >= 0){
                        tempCategories.splice(index,1);
                    }
                }
            }

                this.productCategories = tempCategories;
                this.cloneProductCategories = this.productCategories;

                if(this.viewAllCategories===false){
                    offSetSart = 0;
                    offSetEnd = this.categoriesToDisplay;
                    this.productCategories = this.cloneProductCategories.slice(offSetSart, offSetEnd);
                }

                if(this.cloneProductCategories.length > this.categoriesToDisplay && this.viewAllCategories===false){
                    this.showViewAllButton = true;
                }
                this.hasRendered  = true;
            }
        }).catch(error => {
            this.errors = reduceErrors(error); // code to execute if the promise is rejected
            this.productCategories = [];
        });
    }
        //View all Handler
        showAllCategories = (event) => {
                event.preventDefault();
                this.showViewAllButton = false;
                this.productCategories = this.cloneProductCategories;
                
        }
}
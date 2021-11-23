/*
Created By : Team Hawaii
Created Date : 26 August 2020
Jira No : P2OB-8035
Description : Intermediate component to navigate on Category Landing Page
*/
import { LightningElement,wire,api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import categoryLandingUrl from '@salesforce/label/c.PRMCategoryLandingUrl';
import UserType_User from '@salesforce/schema/User.UserType';
import Id from '@salesforce/user/Id';
const fields = [UserType_User];

export default class prmCategoryLandingPageNavigator extends LightningElement {

    //Design property to store Top category name
    @api selectedItem = '';
    //Design property to store second category name used in url generation
    @api defaultFieldValues = '';
    //Type of User
    usertType = '';
    //Id of Login User
    userId = Id;
    error = '';
    
    //wire adapter to get a user's data(UserType field value).
    @wire(getRecord, { recordId: '$userId', fields })
    wireuser({
        error,
        data
    }){
        if (error) {
           this.error = error ; 
        } else if (data) {
            //User type of login user
            this.usertType = data.fields.UserType.value;
            if(this.usertType == 'PowerPartner'){
                window.location.href = categoryLandingUrl + '?categoryName='+this.selectedItem
                  +'&defaultFieldValues='+this.defaultFieldValues;
                
            }
        }
    }

}
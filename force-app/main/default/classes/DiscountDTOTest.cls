/*
* @Author : Shubhi
* @Date : 26 Nov 2019
* @Desc : Discount DTO
* @Jira : Edge-120132
*@TestClass: DiscountDTOTest */

@isTest
public class DiscountDTOTest {
    
    @isTest static void DiscountDTOTestMethod(){
        DiscountDTO dto=new DiscountDTO();
        dto.discountName='Test';
        dto.description='description';
        dto.discAmount='100';
        dto.discDuration='2';
        dto.promotionID='Test';
        dto.startDate=String.valueof(Date.today()-1);
        dto.endDate=String.valueof(date.today()+1);
        //EDGE-140157 nguc modify start
        dto.initialActivationDate=String.valueof(date.today()+1);
        dto.remainingTerm='2';
        dto.status='Active';
       //EDGE-140157 nguc modify end
        system.assert(dto.startDate==String.valueof(Date.today()-1));
    }     
}
({
    listAction : function(component, event, helper) {
        //change the image names,header,description etc as required
        var name=['PhoenixBannerV6'];
        var header=['Banner1'];
        var description=['Description1'];
        var AlternativeText=['Text1'];
        var ImageUrl=['https://teamtelstra.sharepoint.com/:v:/s/salesdigitisation/EaUpVqOBJ6pPnQwhMXZ7m80Boxesfk8V5bmwOZM4o7P15w?e=nPb9Rc','Salesforce','_blank'];
        var b=['1','2'];
        var list1=[];
        var a=name.length;
        var today=new Date();        
        var fromDatetime = new Date("05/14/2019 00:00:00"); 
        var toDatetime = new Date("05/25/2019 00:00:00");            
        if(today>=fromDatetime && today<=toDatetime){
            component.set("v.displayBanner",true);
        }       
        for(var i=0;i<a;i++){
            list1.push({image:$A.get('$Resource.'+name[i]),Header:header[i],Description:description[i],AlterText:AlternativeText[i],imgUrl:ImageUrl[i]}) ;           
        }
        component.set("v.lstimg",list1);
    }
})
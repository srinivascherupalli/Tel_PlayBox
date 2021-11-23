({
    rerender : function(cmp, helper) {
       this.superRerender();
       var displayBadge = cmp.get("v.showBadge");
       if(displayBadge)
       {
           var invoiceTableData=  cmp.get("v.paginationList");   
           var mapKey = cmp.get("v.chargeId");
           for(var j=0;j<invoiceTableData.length;j++)
           {
               if(invoiceTableData[j].Chargeid === mapKey)
               {
                   invoiceTableData[j].badgeClass = cmp.get("v.badgeCount");//'utility:choice';
                   invoiceTableData[j].buttonLabel =cmp.get("v.badgeCount");//
                   if(cmp.get("v.badgeCount")!==0)
                   {
                    invoiceTableData[j].labelVariant ='brand';   
                   }
                   else
                   {invoiceTableData[j].labelVariant ='';}
               } 
           }
           cmp.set("v.paginationList",invoiceTableData);
           //console.log('paginationList',invoiceTableData);
           cmp.set("v.showBadge",false);
       }
   },
})
public class TelstraService {
    
   public String billingAccount { get; set; }
   public String singleBiller { get; set; }
   public String silentLine { get; set; }
   public String plan { get; set; }
   public String serviceAddress { get; set; }
   public String dataPlan { get; set; }
   public String serviceNumber { get; set; }
   public String cidn { get; set; }

   public TelstraService(){ 
       // empty constructor 
   }
       
   public TelstraService(String aCIDN, String bAccount, String sBiller, String sLine, String aPlan, String anAddress, String aDataPlan, String sNumber) {
      billingAccount = bAccount;
      singleBiller = sBiller;
      silentLine = sLine;
      plan = aPlan;
      serviceAddress = anAddress;
      dataPlan = aDataPlan;
      serviceNumber = sNumber;
      cidn = aCIDN;
   }   
}
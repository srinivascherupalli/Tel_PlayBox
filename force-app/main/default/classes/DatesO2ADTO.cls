public class DatesO2ADTO
{
    public List<DatesO2A> datesO2AList;
        public class DatesO2A {
        public String Sale_Order_ID;
        public String Order_Item_ID;
        public String telstraCommittedDate;
        public String currentForecastedDeliveryDate;
        public String productCompletionDate;
        public String productCancellationDate;
        public String ServiceActivationDate;
        public String ServiceDeactivationDate;
        public String DesignCompletionDate;
        public String InstallationDate;
        public String EquipmentDeliveredDate;
        public String CustomerOrderAcceptanceDate;
        public String EstimatedDeliveryDate;
        public String EquipmentOrderedDate;
        }
    public static DatesO2ADTO parse(String json) {
       return (DatesO2ADTO) System.JSON.deserialize(json, DatesO2ADTO.class);
}
}
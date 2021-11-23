public class WrapperCompare implements Comparable {

    private static Map<String, Integer> ordering = new Map<String, Integer>{
            'Product Requirements Validation' => 6,
            'Product Preparation' => 5,
            'Site Visit And Installation' => 4,
            'Product Activation And Testing' => 3,
            'Customer Order Acceptance' => 2,
            'Product Finalization and Testing' => 1,
            'Product Completion Notice' => 0
            };

    public String sob {get; private set;}
    public Integer order;

    public WrapperCompare(String sob) {
        this.sob = sob;
        this.order = ordering.get(sob);
        if (this.order == null) this.order = -1;
    }

    public Integer compareTo(Object o) {
        WrapperCompare that = (WrapperCompare) o;
        return that.order - this.order;
    }
}
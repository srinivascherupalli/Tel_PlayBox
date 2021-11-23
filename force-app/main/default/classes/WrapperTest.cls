public class WrapperTest implements Comparable {

    private static Map<String, Integer> ordering = new Map<String, Integer>{
            'Products Requirements Validation' => 5,
            'Product Preparation' => 4,
            'Site visit and Installation' => 3,
            'Product Activation and Testing' => 2,
            'Customer Order Acceptance' => 1,
            'Product Completion Notice' => 0
            };

    public String sob {get; private set;}
    private Integer order;

    public WrapperTest(String sob) {
        this.sob = sob;
        this.order = ordering.get(sob);
        if (this.order == null) this.order = -1;
    }

    public Integer compareTo(Object o) {
        WrapperTest that = (WrapperTest) o;
        return that.order - this.order;
    }
}
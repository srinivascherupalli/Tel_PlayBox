global virtual class OnlineOrderingResponse {
	public OnlineOrderingResponse() {
		// do nothing
	}

	public String code     { get; set; }
    public String message  { get; set; }
    public boolean isError { get; set; }
    
    public boolean hasError() {
    	return isError;
    }

}
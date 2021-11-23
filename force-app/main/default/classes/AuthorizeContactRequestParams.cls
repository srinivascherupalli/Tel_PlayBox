public with sharing class AuthorizeContactRequestParams {
	public AuthorizeContactRequestParams(String email, String cidn) {
		this.emailId = email;
		this.CIDN = cidn;
	}
	
	public String emailId { get; set; }
	public String CIDN    { get; set; }
}
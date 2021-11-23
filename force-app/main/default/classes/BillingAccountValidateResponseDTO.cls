/**
 * Class for billing account validate response DTO.
 */
public class BillingAccountValidateResponseDTO {


	/**
	 * Class for flexcab response.
	 */
	public class FlexcabResponse {
		public Product product;
	}

	/**
	 * Class for owner.
	 */
	public class Owner {
		public Party party;
	}

	/**
	 * Class for party.
	 */
	public class Party {
		public String cidn;
		public String invoiceArrangementID;
		public String customerCourtesyTitle;
		public String customerRoleName;
		public String nameRoleCode;
		public String customerGivenName;
		public String customerTradingName;
		public String companyNumber;
		public String ownershipCode;
		public String dateofBirth;
		public String driversLicence;
		public String addressTypeDescription;
		public String addressName;
		public String addressNumber;
		public String addressNumberSuffix;
		public String startStreetNumber;
		public String endStreetNumber;
		public String streetNumberSuffix;
		public String streetName;
		public String streetTypeDescription;
		public String streetNameSuffix;
		public String localityName;
		public String postCode;
		public String stateAbbreviation;
		public String addressLineOne;
		public String addressLineTwo;
		public String addressLineThree;
		public String internationalPostCode;
		public String countryCode;
		public String contactTelephoneNumber;
		public String contactExtensionNumber;
		public String employerName;
		public String orgUnit;
		public String customerJobFunction;
		public String rentalorOwnershipIndicator;
		public String writtenAuthorityIndicator;
		public String portfolioCode;
		public String abn;
		public String masterID;
		public String authorizedRepresentativeDisplayName;
		public String authorizedRepresentativeEndDate;
		public String returnCode;
		public String sqlCode;
		public String errorCode;
		public String errorType;
		public String errorDescription;
	}

	public FlexcabError flexcabError;
	public FlexcabResponse flexcabResponse;

	/**
	 * Class for flexcab error.
	 */
	public class FlexcabError {

		public String timeStamp;
		public String osName;
		public String processName;
		public String moduleName;
		public String moduleLocation;
		public String errorCode;
		public String errorTextLength;
		public String errorText;
	}

	/**
	 * Class for product.
	 */
	public class Product {
		public Owner owner;
	}


	/**
	 * Parses the provided Json text
	 *
	 * @param      json  The json
	 *
	 * @return     BillingAccountValidateResponseDTO object
	 */
	public static BillingAccountValidateResponseDTO parse(String json) {
		return (BillingAccountValidateResponseDTO) System.JSON.deserialize(json, BillingAccountValidateResponseDTO.class);
	}

}
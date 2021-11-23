/**
 * Class for mock bill acc validate response generator.
 */
@isTest
global class MockBillAccValidateResponseGenerator implements HTTPCalloutMock {

	/**
	 * respond method
	 *
	 * @param      req   The request
	 *
	 * @return     HttpResponse object
	 */
	global HttpResponse respond(HttpRequest req) {

		HttpResponse res = new HttpResponse();

		res.setHeader('Content-Type', 'application/json');

		String endPoint = req.getEndpoint();

		if (endPoint.contains('/managebilling/rest/validate')) {

			String reqBody = req.getBody();

			BillingAccountValidateRequestDTO billReq = BillingAccountValidateRequestDTO.parse(reqBody);

			String js = '';

			if (billReq.Product.owner.Party.ID == '0123456789123' && billReq.Product.Account.ID == '0123456789' ) {

				js = respJSON_Invalid();

			} else if (billReq.Product.owner.Party.ID == '0123456789124' && billReq.Product.Account.ID == '0123456788' ) {

				js = respJSON_TechnicalError();

			} else {

				js = respJSON_Normal();

			}

			res.setBody(js);


		} else if (endPoint.contains('token')) {
			res.setBody('{ "access_token": "tElsAddR32156teSt","expires_in": "2000"}');
		}
		res.setStatusCode(200);
		return res;
	}

	/**
	 *  Invalid billing account response JSON
	 *
	 * @return     JSON string
	 */
	public String respJSON_Invalid() {

		String json = '{' +
		              '        \"flexcabResponse\": {' +
		              '            \"product\": {' +
		              '                \"owner\": {' +
		              '                    \"party\": {' +
		              '                        \"writtenAuthorityIndicator\": null,' +
		              '                        \"streetTypeDescription\": null,' +
		              '                        \"streetNumberSuffix\": null,' +
		              '                        \"streetNameSuffix\": null,' +
		              '                        \"streetName\": null,' +
		              '                        \"stateAbbreviation\": null,' +
		              '                        \"startStreetNumber\": null,' +
		              '                        \"sqlCode\": null,' +
		              '                        \"returnCode\": null,' +
		              '                        \"rentalorOwnershipIndicator\": null,' +
		              '                        \"postCode\": null,' +
		              '                        \"portfolioCode\": null,' +
		              '                        \"ownershipCode\": null,' +
		              '                        \"orgUnit\": null,' +
		              '                        \"nameRoleCode\": null,' +
		              '                        \"masterID\": null,' +
		              '                        \"localityName\": null,' +
		              '                        \"invoiceArrangementID\": null,' +
		              '                        \"internationalPostCode\": null,' +
		              '                        \"errorType\": null,' +
		              '                        \"errorDescription\": \"Billing Account not matching\",' +
		              '                        \"errorCode\": \"ER-001\",' +
		              '                        \"endStreetNumber\": null,' +
		              '                        \"employerName\": null,' +
		              '                        \"driversLicence\": null,' +
		              '                        \"dateofBirth\": null,' +
		              '                        \"customerTradingName\": null,' +
		              '                        \"customerRoleName\": null,' +
		              '                        \"customerJobFunction\": null,' +
		              '                        \"customerGivenName\": null,' +
		              '                        \"customerCourtesyTitle\": null,' +
		              '                        \"countryCode\": null,' +
		              '                        \"contactTelephoneNumber\": null,' +
		              '                        \"contactExtensionNumber\": null,' +
		              '                        \"companyNumber\": null,' +
		              '                        \"cidn\": null,' +
		              '                        \"authorizedRepresentativeEndDate\": null,' +
		              '                        \"authorizedRepresentativeDisplayName\": null,' +
		              '                        \"addressTypeDescription\": null,' +
		              '                        \"addressNumberSuffix\": null,' +
		              '                        \"addressNumber\": null,' +
		              '                        \"addressName\": null,' +
		              '                        \"addressLineTwo\": null,' +
		              '                        \"addressLineThree\": null,' +
		              '                        \"addressLineOne\": null,' +
		              '                        \"abn\": null' +
		              '                    }' +
		              '                }' +
		              '            }' +
		              '        },' +
		              '        \"flexcabError\": {' +
		              '            \"timeStamp\": null,' +
		              '            \"processName\": null,' +
		              '            \"osName\": null,' +
		              '            \"moduleName\": null,' +
		              '            \"moduleLocation\": null,' +
		              '            \"errorTextLength\": null,' +
		              '            \"errorText\": null,' +
		              '            \"errorCode\": null' +
		              '        }' +
		              '    }';

		return json;
	}

	/**
	 * Technical error in billing gateway response JSON
	 *
	 * @return     JSON string
	 */
	public String respJSON_TechnicalError() {

		String json = '{' +
		              '        \"flexcabResponse\": {' +
		              '            \"product\": {' +
		              '                \"owner\": {' +
		              '                    \"party\": {' +
		              '                        \"writtenAuthorityIndicator\": null,' +
		              '                        \"streetTypeDescription\": null,' +
		              '                        \"streetNumberSuffix\": null,' +
		              '                        \"streetNameSuffix\": null,' +
		              '                        \"streetName\": null,' +
		              '                        \"stateAbbreviation\": null,' +
		              '                        \"startStreetNumber\": null,' +
		              '                        \"sqlCode\": null,' +
		              '                        \"returnCode\": null,' +
		              '                        \"rentalorOwnershipIndicator\": null,' +
		              '                        \"postCode\": null,' +
		              '                        \"portfolioCode\": null,' +
		              '                        \"ownershipCode\": null,' +
		              '                        \"orgUnit\": null,' +
		              '                        \"nameRoleCode\": null,' +
		              '                        \"masterID\": null,' +
		              '                        \"localityName\": null,' +
		              '                        \"invoiceArrangementID\": null,' +
		              '                        \"internationalPostCode\": null,' +
		              '                        \"errorType\": null,' +
		              '                        \"errorDescription\": null,' +
		              '                        \"errorCode\": null,' +
		              '                        \"endStreetNumber\": null,' +
		              '                        \"employerName\": null,' +
		              '                        \"driversLicence\": null,' +
		              '                        \"dateofBirth\": null,' +
		              '                        \"customerTradingName\": null,' +
		              '                        \"customerRoleName\": null,' +
		              '                        \"customerJobFunction\": null,' +
		              '                        \"customerGivenName\": null,' +
		              '                        \"customerCourtesyTitle\": null,' +
		              '                        \"countryCode\": null,' +
		              '                        \"contactTelephoneNumber\": null,' +
		              '                        \"contactExtensionNumber\": null,' +
		              '                        \"companyNumber\": null,' +
		              '                        \"cidn\": null,' +
		              '                        \"authorizedRepresentativeEndDate\": null,' +
		              '                        \"authorizedRepresentativeDisplayName\": null,' +
		              '                        \"addressTypeDescription\": null,' +
		              '                        \"addressNumberSuffix\": null,' +
		              '                        \"addressNumber\": null,' +
		              '                        \"addressName\": null,' +
		              '                        \"addressLineTwo\": null,' +
		              '                        \"addressLineThree\": null,' +
		              '                        \"addressLineOne\": null,' +
		              '                        \"abn\": null' +
		              '                    }' +
		              '                }' +
		              '            }' +
		              '        },' +
		              '        \"flexcabError\": {' +
		              '            \"timeStamp\": null,' +
		              '            \"processName\": null,' +
		              '            \"osName\": null,' +
		              '            \"moduleName\": null,' +
		              '            \"moduleLocation\": null,' +
		              '            \"errorTextLength\": null,' +
		              '            \"errorText\": \"Technical Error\",' +
		              '            \"errorCode\": \"ER-001\"' +
		              '        }' +
		              '    }';

		return json;

	}

	/**
	 * success billing gateway response JSON
	 *
	 * @return     JSON string
	 */
	public String respJSON_Normal() {

		String json = '{' +
		              '        \"flexcabResponse\": {' +
		              '            \"product\": {' +
		              '                \"owner\": {' +
		              '                    \"party\": {' +
		              '                        \"writtenAuthorityIndicator\": null,' +
		              '                        \"streetTypeDescription\": null,' +
		              '                        \"streetNumberSuffix\": null,' +
		              '                        \"streetNameSuffix\": null,' +
		              '                        \"streetName\": null,' +
		              '                        \"stateAbbreviation\": null,' +
		              '                        \"startStreetNumber\": null,' +
		              '                        \"sqlCode\": null,' +
		              '                        \"returnCode\": null,' +
		              '                        \"rentalorOwnershipIndicator\": null,' +
		              '                        \"postCode\": null,' +
		              '                        \"portfolioCode\": null,' +
		              '                        \"ownershipCode\": null,' +
		              '                        \"orgUnit\": null,' +
		              '                        \"nameRoleCode\": null,' +
		              '                        \"masterID\": null,' +
		              '                        \"localityName\": null,' +
		              '                        \"invoiceArrangementID\": null,' +
		              '                        \"internationalPostCode\": null,' +
		              '                        \"errorType\": null,' +
		              '                        \"errorDescription\": null,' +
		              '                        \"errorCode\": null,' +
		              '                        \"endStreetNumber\": null,' +
		              '                        \"employerName\": null,' +
		              '                        \"driversLicence\": null,' +
		              '                        \"dateofBirth\": null,' +
		              '                        \"customerTradingName\": null,' +
		              '                        \"customerRoleName\": null,' +
		              '                        \"customerJobFunction\": null,' +
		              '                        \"customerGivenName\": null,' +
		              '                        \"customerCourtesyTitle\": null,' +
		              '                        \"countryCode\": null,' +
		              '                        \"contactTelephoneNumber\": null,' +
		              '                        \"contactExtensionNumber\": null,' +
		              '                        \"companyNumber\": null,' +
		              '                        \"cidn\": null,' +
		              '                        \"authorizedRepresentativeEndDate\": null,' +
		              '                        \"authorizedRepresentativeDisplayName\": null,' +
		              '                        \"addressTypeDescription\": null,' +
		              '                        \"addressNumberSuffix\": null,' +
		              '                        \"addressNumber\": null,' +
		              '                        \"addressName\": null,' +
		              '                        \"addressLineTwo\": null,' +
		              '                        \"addressLineThree\": null,' +
		              '                        \"addressLineOne\": null,' +
		              '                        \"abn\": null' +
		              '                    }' +
		              '                }' +
		              '            }' +
		              '        },' +
		              '        \"flexcabError\": {' +
		              '            \"timeStamp\": null,' +
		              '            \"processName\": null,' +
		              '            \"osName\": null,' +
		              '            \"moduleName\": null,' +
		              '            \"moduleLocation\": null,' +
		              '            \"errorTextLength\": null,' +
		              '            \"errorText\": null,' +
		              '            \"errorCode\": null' +
		              '        }' +
		              '    }';

		return json;
	}
}
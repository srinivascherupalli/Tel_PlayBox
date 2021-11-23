/*
 * International Telephone Input v14.0.2
 * https://github.com/jackocnr/intl-tel-input.git
 * Licensed under the MIT license
 */

// wrap in UMD
(function(factory) {
    var intlTelInput = factory(window, document);
    if (typeof module === "object" && module.exports) module.exports = intlTelInput; else window.intlTelInput = intlTelInput;
})(function(window, document, undefined) {
    "use strict";
    return function() {
        // Array of country objects for the flag dropdown.
        // Here is the criteria for the plugin to support a given country/territory
        // - It has an iso2 code: https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2
        // - It has it's own country calling code (it is not a sub-region of another country): https://en.wikipedia.org/wiki/List_of_country_calling_codes
        // - It has a flag in the region-flags project: https://github.com/behdad/region-flags/tree/gh-pages/png
        // - It is supported by libphonenumber (it must be listed on this page): https://github.com/googlei18n/libphonenumber/blob/master/resources/ShortNumberMetadata.xml
        // Each country array has the following information:
        // [
        //    Country name,
        //    iso2 code,
        //    International dial code,
        //    Order (if >1 country with same dial code),
        //    Area codes
        // ]
        var allCountries = [ [ "Afghanistan (‫افغانستان‬‎)", "af", "93" ], [ "Albania (Shqipëri)", "al", "355" ], [ "Algeria (‫الجزائر‬‎)", "dz", "213" ], [ "American Samoa", "as", "1684" ], [ "Andorra", "ad", "376" ], [ "Angola", "ao", "244" ], [ "Anguilla", "ai", "1264" ], [ "Antigua and Barbuda", "ag", "1268" ], [ "Argentina", "ar", "54" ], [ "Armenia (Հայաստան)", "am", "374" ], [ "Aruba", "aw", "297" ], [ "Australia", "au", "61", 0 ], [ "Austria (Österreich)", "at", "43" ], [ "Azerbaijan (Azərbaycan)", "az", "994" ], [ "Bahamas", "bs", "1242" ], [ "Bahrain (‫البحرين‬‎)", "bh", "973" ], [ "Bangladesh (বাংলাদেশ)", "bd", "880" ], [ "Barbados", "bb", "1246" ], [ "Belarus (Беларусь)", "by", "375" ], [ "Belgium (België)", "be", "32" ], [ "Belize", "bz", "501" ], [ "Benin (Bénin)", "bj", "229" ], [ "Bermuda", "bm", "1441" ], [ "Bhutan (འབྲུག)", "bt", "975" ], [ "Bolivia", "bo", "591" ], [ "Bosnia and Herzegovina (Босна и Херцеговина)", "ba", "387" ], [ "Botswana", "bw", "267" ], [ "Brazil (Brasil)", "br", "55" ], [ "British Indian Ocean Territory", "io", "246" ], [ "British Virgin Islands", "vg", "1284" ], [ "Brunei", "bn", "673" ], [ "Bulgaria (България)", "bg", "359" ], [ "Burkina Faso", "bf", "226" ], [ "Burundi (Uburundi)", "bi", "257" ], [ "Cambodia (កម្ពុជា)", "kh", "855" ], [ "Cameroon (Cameroun)", "cm", "237" ], [ "Canada", "ca", "1", 1, [ "204", "226", "236", "249", "250", "289", "306", "343", "365", "387", "403", "416", "418", "431", "437", "438", "450", "506", "514", "519", "548", "579", "581", "587", "604", "613", "639", "647", "672", "705", "709", "742", "778", "780", "782", "807", "819", "825", "867", "873", "902", "905" ] ], [ "Cape Verde (Kabu Verdi)", "cv", "238" ], [ "Caribbean Netherlands", "bq", "599", 1 ], [ "Cayman Islands", "ky", "1345" ], [ "Central African Republic (République centrafricaine)", "cf", "236" ], [ "Chad (Tchad)", "td", "235" ], [ "Chile", "cl", "56" ], [ "China (中国)", "cn", "86" ], [ "Christmas Island", "cx", "61", 2 ], [ "Cocos (Keeling) Islands", "cc", "61", 1 ], [ "Colombia", "co", "57" ], [ "Comoros (‫جزر القمر‬‎)", "km", "269" ], [ "Congo (DRC) (Jamhuri ya Kidemokrasia ya Kongo)", "cd", "243" ], [ "Congo (Republic) (Congo-Brazzaville)", "cg", "242" ], [ "Cook Islands", "ck", "682" ], [ "Costa Rica", "cr", "506" ], [ "Côte d’Ivoire", "ci", "225" ], [ "Croatia (Hrvatska)", "hr", "385" ], [ "Cuba", "cu", "53" ], [ "Curaçao", "cw", "599", 0 ], [ "Cyprus (Κύπρος)", "cy", "357" ], [ "Czech Republic (Česká republika)", "cz", "420" ], [ "Denmark (Danmark)", "dk", "45" ], [ "Djibouti", "dj", "253" ], [ "Dominica", "dm", "1767" ], [ "Dominican Republic (República Dominicana)", "do", "1", 2, [ "809", "829", "849" ] ], [ "Ecuador", "ec", "593" ], [ "Egypt (‫مصر‬‎)", "eg", "20" ], [ "El Salvador", "sv", "503" ], [ "Equatorial Guinea (Guinea Ecuatorial)", "gq", "240" ], [ "Eritrea", "er", "291" ], [ "Estonia (Eesti)", "ee", "372" ], [ "Ethiopia", "et", "251" ], [ "Falkland Islands (Islas Malvinas)", "fk", "500" ], [ "Faroe Islands (Føroyar)", "fo", "298" ], [ "Fiji", "fj", "679" ], [ "Finland (Suomi)", "fi", "358", 0 ], [ "France", "fr", "33" ], [ "French Guiana (Guyane française)", "gf", "594" ], [ "French Polynesia (Polynésie française)", "pf", "689" ], [ "Gabon", "ga", "241" ], [ "Gambia", "gm", "220" ], [ "Georgia (საქართველო)", "ge", "995" ], [ "Germany (Deutschland)", "de", "49" ], [ "Ghana (Gaana)", "gh", "233" ], [ "Gibraltar", "gi", "350" ], [ "Greece (Ελλάδα)", "gr", "30" ], [ "Greenland (Kalaallit Nunaat)", "gl", "299" ], [ "Grenada", "gd", "1473" ], [ "Guadeloupe", "gp", "590", 0 ], [ "Guam", "gu", "1671" ], [ "Guatemala", "gt", "502" ], [ "Guernsey", "gg", "44", 1 ], [ "Guinea (Guinée)", "gn", "224" ], [ "Guinea-Bissau (Guiné Bissau)", "gw", "245" ], [ "Guyana", "gy", "592" ], [ "Haiti", "ht", "509" ], [ "Honduras", "hn", "504" ], [ "Hong Kong (香港)", "hk", "852" ], [ "Hungary (Magyarország)", "hu", "36" ], [ "Iceland (Ísland)", "is", "354" ], [ "India (भारत)", "in", "91" ], [ "Indonesia", "id", "62" ], [ "Iran (‫ایران‬‎)", "ir", "98" ], [ "Iraq (‫العراق‬‎)", "iq", "964" ], [ "Ireland", "ie", "353" ], [ "Isle of Man", "im", "44", 2 ], [ "Israel (‫ישראל‬‎)", "il", "972" ], [ "Italy (Italia)", "it", "39", 0 ], [ "Jamaica", "jm", "1", 4, [ "876", "658" ] ], [ "Japan (日本)", "jp", "81" ], [ "Jersey", "je", "44", 3 ], [ "Jordan (‫الأردن‬‎)", "jo", "962" ], [ "Kazakhstan (Казахстан)", "kz", "7", 1 ], [ "Kenya", "ke", "254" ], [ "Kiribati", "ki", "686" ], [ "Kosovo", "xk", "383" ], [ "Kuwait (‫الكويت‬‎)", "kw", "965" ], [ "Kyrgyzstan (Кыргызстан)", "kg", "996" ], [ "Laos (ລາວ)", "la", "856" ], [ "Latvia (Latvija)", "lv", "371" ], [ "Lebanon (‫لبنان‬‎)", "lb", "961" ], [ "Lesotho", "ls", "266" ], [ "Liberia", "lr", "231" ], [ "Libya (‫ليبيا‬‎)", "ly", "218" ], [ "Liechtenstein", "li", "423" ], [ "Lithuania (Lietuva)", "lt", "370" ], [ "Luxembourg", "lu", "352" ], [ "Macau (澳門)", "mo", "853" ], [ "Macedonia (FYROM) (Македонија)", "mk", "389" ], [ "Madagascar (Madagasikara)", "mg", "261" ], [ "Malawi", "mw", "265" ], [ "Malaysia", "my", "60" ], [ "Maldives", "mv", "960" ], [ "Mali", "ml", "223" ], [ "Malta", "mt", "356" ], [ "Marshall Islands", "mh", "692" ], [ "Martinique", "mq", "596" ], [ "Mauritania (‫موريتانيا‬‎)", "mr", "222" ], [ "Mauritius (Moris)", "mu", "230" ], [ "Mayotte", "yt", "262", 1 ], [ "Mexico (México)", "mx", "52" ], [ "Micronesia", "fm", "691" ], [ "Moldova (Republica Moldova)", "md", "373" ], [ "Monaco", "mc", "377" ], [ "Mongolia (Монгол)", "mn", "976" ], [ "Montenegro (Crna Gora)", "me", "382" ], [ "Montserrat", "ms", "1664" ], [ "Morocco (‫المغرب‬‎)", "ma", "212", 0 ], [ "Mozambique (Moçambique)", "mz", "258" ], [ "Myanmar (Burma) (မြန်မာ)", "mm", "95" ], [ "Namibia (Namibië)", "na", "264" ], [ "Nauru", "nr", "674" ], [ "Nepal (नेपाल)", "np", "977" ], [ "Netherlands (Nederland)", "nl", "31" ], [ "New Caledonia (Nouvelle-Calédonie)", "nc", "687" ], [ "New Zealand", "nz", "64" ], [ "Nicaragua", "ni", "505" ], [ "Niger (Nijar)", "ne", "227" ], [ "Nigeria", "ng", "234" ], [ "Niue", "nu", "683" ], [ "Norfolk Island", "nf", "672" ], [ "North Korea (조선 민주주의 인민 공화국)", "kp", "850" ], [ "Northern Mariana Islands", "mp", "1670" ], [ "Norway (Norge)", "no", "47", 0 ], [ "Oman (‫عُمان‬‎)", "om", "968" ], [ "Pakistan (‫پاکستان‬‎)", "pk", "92" ], [ "Palau", "pw", "680" ], [ "Palestine (‫فلسطين‬‎)", "ps", "970" ], [ "Panama (Panamá)", "pa", "507" ], [ "Papua New Guinea", "pg", "675" ], [ "Paraguay", "py", "595" ], [ "Peru (Perú)", "pe", "51" ], [ "Philippines", "ph", "63" ], [ "Poland (Polska)", "pl", "48" ], [ "Portugal", "pt", "351" ], [ "Puerto Rico", "pr", "1", 3, [ "787", "939" ] ], [ "Qatar (‫قطر‬‎)", "qa", "974" ], [ "Réunion (La Réunion)", "re", "262", 0 ], [ "Romania (România)", "ro", "40" ], [ "Russia (Россия)", "ru", "7", 0 ], [ "Rwanda", "rw", "250" ], [ "Saint Barthélemy", "bl", "590", 1 ], [ "Saint Helena", "sh", "290" ], [ "Saint Kitts and Nevis", "kn", "1869" ], [ "Saint Lucia", "lc", "1758" ], [ "Saint Martin (Saint-Martin (partie française))", "mf", "590", 2 ], [ "Saint Pierre and Miquelon (Saint-Pierre-et-Miquelon)", "pm", "508" ], [ "Saint Vincent and the Grenadines", "vc", "1784" ], [ "Samoa", "ws", "685" ], [ "San Marino", "sm", "378" ], [ "São Tomé and Príncipe (São Tomé e Príncipe)", "st", "239" ], [ "Saudi Arabia (‫المملكة العربية السعودية‬‎)", "sa", "966" ], [ "Senegal (Sénégal)", "sn", "221" ], [ "Serbia (Србија)", "rs", "381" ], [ "Seychelles", "sc", "248" ], [ "Sierra Leone", "sl", "232" ], [ "Singapore", "sg", "65" ], [ "Sint Maarten", "sx", "1721" ], [ "Slovakia (Slovensko)", "sk", "421" ], [ "Slovenia (Slovenija)", "si", "386" ], [ "Solomon Islands", "sb", "677" ], [ "Somalia (Soomaaliya)", "so", "252" ], [ "South Africa", "za", "27" ], [ "South Korea (대한민국)", "kr", "82" ], [ "South Sudan (‫جنوب السودان‬‎)", "ss", "211" ], [ "Spain (España)", "es", "34" ], [ "Sri Lanka (ශ්‍රී ලංකාව)", "lk", "94" ], [ "Sudan (‫السودان‬‎)", "sd", "249" ], [ "Suriname", "sr", "597" ], [ "Svalbard and Jan Mayen", "sj", "47", 1 ], [ "Swaziland", "sz", "268" ], [ "Sweden (Sverige)", "se", "46" ], [ "Switzerland (Schweiz)", "ch", "41" ], [ "Syria (‫سوريا‬‎)", "sy", "963" ], [ "Taiwan (台灣)", "tw", "886" ], [ "Tajikistan", "tj", "992" ], [ "Tanzania", "tz", "255" ], [ "Thailand (ไทย)", "th", "66" ], [ "Timor-Leste", "tl", "670" ], [ "Togo", "tg", "228" ], [ "Tokelau", "tk", "690" ], [ "Tonga", "to", "676" ], [ "Trinidad and Tobago", "tt", "1868" ], [ "Tunisia (‫تونس‬‎)", "tn", "216" ], [ "Turkey (Türkiye)", "tr", "90" ], [ "Turkmenistan", "tm", "993" ], [ "Turks and Caicos Islands", "tc", "1649" ], [ "Tuvalu", "tv", "688" ], [ "U.S. Virgin Islands", "vi", "1340" ], [ "Uganda", "ug", "256" ], [ "Ukraine (Україна)", "ua", "380" ], [ "United Arab Emirates (‫الإمارات العربية المتحدة‬‎)", "ae", "971" ], [ "United Kingdom", "gb", "44", 0 ], [ "United States", "us", "1", 0 ], [ "Uruguay", "uy", "598" ], [ "Uzbekistan (Oʻzbekiston)", "uz", "998" ], [ "Vanuatu", "vu", "678" ], [ "Vatican City (Città del Vaticano)", "va", "39", 1 ], [ "Venezuela", "ve", "58" ], [ "Vietnam (Việt Nam)", "vn", "84" ], [ "Wallis and Futuna (Wallis-et-Futuna)", "wf", "681" ], [ "Western Sahara (‫الصحراء الغربية‬‎)", "eh", "212", 1 ], [ "Yemen (‫اليمن‬‎)", "ye", "967" ], [ "Zambia", "zm", "260" ], [ "Zimbabwe", "zw", "263" ], [ "Åland Islands", "ax", "358", 1 ] ];
        // loop over all of the countries above, restructuring the data to be objects with named keys
        for (var i = 0; i < allCountries.length; i++) {
            var c = allCountries[i];
            allCountries[i] = {
                name: c[0],
                iso2: c[1],
                dialCode: c[2],
                priority: c[3] || 0,
                areaCodes: c[4] || null
            };
        }
        window.intlTelInputGlobals = {
            instances: {}
        };
        // these vars persist through all instances of the plugin
        var id = 0, defaults = {
            // whether or not to allow the dropdown
            allowDropdown: true,
            // if there is just a dial code in the input: remove it on blur, and re-add it on focus
            autoHideDialCode: true,
            // add a placeholder in the input with an example number for the selected country
            autoPlaceholder: "polite",
            // modify the auto placeholder
            customPlaceholder: null,
            // append menu to specified element
            dropdownContainer: null,
            // don't display these countries
            excludeCountries: [],
            // format the input value during initialisation and on setNumber
            formatOnDisplay: true,
            // geoIp lookup function
            geoIpLookup: null,
            // inject a hidden input with this name, and on submit, populate it with the result of getNumber
            hiddenInput: "",
            // initial country
            initialCountry: "",
            // localized country names e.g. { 'de': 'Deutschland' }
            localizedCountries: null,
            // don't insert international dial codes
            nationalMode: true,
            // display only these countries
            onlyCountries: [],
            // number type to use for placeholders
            placeholderNumberType: "MOBILE",
            // the countries at the top of the list. defaults to united states and united kingdom
            preferredCountries: [ "us", "gb" ],
            // display the country dial code next to the selected flag so it's not part of the typed number
            separateDialCode: false,
            // specify the path to the libphonenumber script to enable validation/formatting
            utilsScript: "",
        }, // https://en.wikipedia.org/wiki/List_of_North_American_Numbering_Plan_area_codes#Non-geographic_area_codes
        regionlessNanpNumbers = [ "800", "822", "833", "844", "855", "866", "877", "880", "881", "882", "883", "884", "885", "886", "887", "888", "889" ];
        // keep track of if the window.load event has fired as impossible to check after the fact
        window.addEventListener("load", function() {
            // UPDATE: use a public static field so we can fudge it in the tests
            window.intlTelInputGlobals.windowLoaded = true;
        });
        // utility function to iterate over an object. can't use Object.entries or native forEach because of IE11
        var forEachProp = function(obj, callback) {
            var keys = Object.keys(obj);
            for (var i = 0; i < keys.length; i++) {
                callback(keys[i], obj[keys[i]]);
            }
        };
        // run a method on each instance of the plugin
        var forEachInstance = function(method) {
            forEachProp(window.intlTelInputGlobals.instances, function(key, value) {
                window.intlTelInputGlobals.instances[key][method]();
            });
        };
        // this is our plugin class that we will create an instance of
        var Iti = function(input, options) {
            var that = this;
            this.id = id++;
            this.telInput = input;
            // process specified options / defaults
            // alternative to Object.assign, which isn't supported by IE11
            var customOptions = options || {};
            this.options = {};
            forEachProp(defaults, function(key, value) {
                that.options[key] = customOptions.hasOwnProperty(key) ? customOptions[key] : value;
            });
            this.hadInitialPlaceholder = Boolean(input.getAttribute("placeholder"));
        };
        // define our class methods on the prototype
        Iti.prototype = {
            _init: function() {
                var that = this;
                // if in nationalMode, disable options relating to dial codes
                if (this.options.nationalMode) {
                    this.options.autoHideDialCode = false;
                }
                // if separateDialCode then doesn't make sense to A) insert dial code into input (autoHideDialCode), and B) display national numbers (because we're displaying the country dial code next to them)
                if (this.options.separateDialCode) {
                    this.options.autoHideDialCode = this.options.nationalMode = false;
                }
                // we cannot just test screen size as some smartphones/website meta tags will report desktop resolutions
                // Note: for some reason jasmine breaks if you put this in the main Plugin function with the rest of these declarations
                // Note: to target Android Mobiles (and not Tablets), we must find "Android" and "Mobile"
                this.isMobile = /Android.+Mobile|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
                if (this.isMobile) {
                    // trigger the mobile dropdown css
                    document.body.classList.add("iti-mobile");
                    // on mobile, we want a full screen dropdown, so we must append it to the body
                    if (!this.options.dropdownContainer) {
                        this.options.dropdownContainer = document.body;
                    }
                }
                // these promises get resolved when their individual requests complete
                // this way the dev can do something like iti.promise.then(...) to know when all requests are complete
                if (typeof Promise !== "undefined") {
                    var autoCountryPromise = new Promise(function(resolve, reject) {
                        that.resolveAutoCountryPromise = resolve;
                        that.rejectAutoCountryPromise = reject;
                    });
                    var utilsScriptPromise = new Promise(function(resolve, reject) {
                        that.resolveUtilsScriptPromise = resolve;
                        that.rejectUtilsScriptPromise = reject;
                    });
                    this.promise = Promise.all([ autoCountryPromise, utilsScriptPromise ]);
                } else {
                    // prevent errors when Promise doesn't exist
                    this.resolveAutoCountryPromise = this.rejectAutoCountryPromise = this.resolveUtilsScriptPromise = this.rejectUtilsScriptPromise = function() {};
                }
                // in various situations there could be no country selected initially, but we need to be able to assume this variable exists
                this.selectedCountryData = {};
                // process all the data: onlyCountries, excludeCountries, preferredCountries etc
                this._processCountryData();
                // generate the markup
                this._generateMarkup();
                // set the initial state of the input value and the selected flag
                this._setInitialState();
                // start all of the event listeners: autoHideDialCode, input keydown, selectedFlag click
                this._initListeners();
                // utils script, and auto country
                this._initRequests();
            },
            /********************
   *  PRIVATE METHODS
   ********************/
            // prepare all of the country data, including onlyCountries, excludeCountries and preferredCountries options
            _processCountryData: function() {
                // process onlyCountries or excludeCountries array if present
                this._processAllCountries();
                // process the countryCodes map
                this._processCountryCodes();
                // process the preferredCountries
                this._processPreferredCountries();
                // translate countries according to localizedCountries option
                if (this.options.localizedCountries) {
                    this._translateCountriesByLocale();
                }
                // sort countries by name
                if (this.options.onlyCountries.length || this.options.localizedCountries) {
                    this.countries.sort(this._countryNameSort);
                }
            },
            // add a country code to this.countryCodes
            _addCountryCode: function(iso2, dialCode, priority) {
                if (!this.countryCodes.hasOwnProperty(dialCode)) {
                    this.countryCodes[dialCode] = [];
                }
                var index = priority || 0;
                this.countryCodes[dialCode][index] = iso2;
            },
            // process onlyCountries or excludeCountries array if present
            _processAllCountries: function() {
                if (this.options.onlyCountries.length) {
                    var lowerCaseOnlyCountries = this.options.onlyCountries.map(function(country) {
                        return country.toLowerCase();
                    });
                    this.countries = allCountries.filter(function(country) {
                        return lowerCaseOnlyCountries.indexOf(country.iso2) > -1;
                    });
                } else if (this.options.excludeCountries.length) {
                    var lowerCaseExcludeCountries = this.options.excludeCountries.map(function(country) {
                        return country.toLowerCase();
                    });
                    this.countries = allCountries.filter(function(country) {
                        return lowerCaseExcludeCountries.indexOf(country.iso2) === -1;
                    });
                } else {
                    this.countries = allCountries;
                }
            },
            // Translate Countries by object literal provided on config
            _translateCountriesByLocale: function() {
                for (var i = 0; i < this.countries.length; i++) {
                    var iso = this.countries[i].iso2.toLowerCase();
                    if (this.options.localizedCountries.hasOwnProperty(iso)) {
                        this.countries[i].name = this.options.localizedCountries[iso];
                    }
                }
            },
            // sort by country name
            _countryNameSort: function(a, b) {
                return a.name.localeCompare(b.name);
            },
            // process the countryCodes map
            _processCountryCodes: function() {
                this.countryCodes = {};
                for (var i = 0; i < this.countries.length; i++) {
                    var c = this.countries[i];
                    this._addCountryCode(c.iso2, c.dialCode, c.priority);
                    // area codes
                    if (c.areaCodes) {
                        for (var j = 0; j < c.areaCodes.length; j++) {
                            // full dial code is country code + dial code
                            this._addCountryCode(c.iso2, c.dialCode + c.areaCodes[j]);
                        }
                    }
                }
            },
            // process preferred countries - iterate through the preferences, fetching the country data for each one
            _processPreferredCountries: function() {
                this.preferredCountries = [];
                for (var i = 0; i < this.options.preferredCountries.length; i++) {
                    var countryCode = this.options.preferredCountries[i].toLowerCase(), countryData = this._getCountryData(countryCode, false, true);
                    if (countryData) {
                        this.preferredCountries.push(countryData);
                    }
                }
            },
            // create a DOM element
            _createEl: function(name, attrs, container) {
                var el = document.createElement(name);
                if (attrs) {
                    forEachProp(attrs, function(key, value) {
                        el.setAttribute(key, value);
                    });
                }
                if (container) container.appendChild(el);
                return el;
            },
            // generate all of the markup for the plugin: the selected flag overlay, and the dropdown
            _generateMarkup: function() {
                // prevent autocomplete as there's no safe, cross-browser event we can react to, so it can easily put the plugin in an inconsistent state e.g. the wrong flag selected for the autocompleted number, which on submit could mean the wrong number is saved (esp in nationalMode)
                this.telInput.setAttribute("autocomplete", "off");
                // containers (mostly for positioning)
                var parentClass = "intl-tel-input";
                if (this.options.allowDropdown) {
                    parentClass += " allow-dropdown";
                }
                if (this.options.separateDialCode) {
                    parentClass += " separate-dial-code";
                }
                var wrapper = this._createEl("div", {
                    "class": parentClass
                });
                this.telInput.parentNode.insertBefore(wrapper, this.telInput);
                this.flagsContainer = this._createEl("div", {
                    "class": "flag-container"
                }, wrapper);
                wrapper.appendChild(this.telInput);
                // selected flag (displayed to left of input)
                this.selectedFlag = this._createEl("div", {
                    "class": "selected-flag",
                    role: "combobox",
                    "aria-owns": "country-listbox"
                }, this.flagsContainer);
                this.selectedFlagInner = this._createEl("div", {
                    "class": "iti-flag"
                }, this.selectedFlag);
                if (this.options.separateDialCode) {
                    this.selectedDialCode = this._createEl("div", {
                        "class": "selected-dial-code"
                    }, this.selectedFlag);
                }
                if (this.options.allowDropdown) {
                    // make element focusable and tab navigable
                    this.selectedFlag.setAttribute("tabindex", "0");
                    this.dropdownArrow = this._createEl("div", {
                        "class": "iti-arrow"
                    }, this.selectedFlag);
                    // country dropdown: preferred countries, then divider, then all countries
                    this.countryList = this._createEl("ul", {
                        "class": "country-list hide",
                        id: "country-listbox",
                        "aria-expanded": "false",
                        role: "listbox"
                    });
                    if (this.preferredCountries.length) {
                        this._appendListItems(this.preferredCountries, "preferred");
                        this._createEl("li", {
                            "class": "divider",
                            role: "separator",
                            "aria-disabled": "true"
                        }, this.countryList);
                    }
                    this._appendListItems(this.countries, "standard");
                    // create dropdownContainer markup
                    if (this.options.dropdownContainer) {
                        this.dropdown = this._createEl("div", {
                            "class": "intl-tel-input iti-container"
                        });
                        this.dropdown.appendChild(this.countryList);
                    } else {
                        this.flagsContainer.appendChild(this.countryList);
                    }
                }
                if (this.options.hiddenInput) {
                    var hiddenInputName = this.options.hiddenInput;
                    var name = this.telInput.getAttribute("name");
                    if (name) {
                        var i = name.lastIndexOf("[");
                        // if input name contains square brackets, then give the hidden input the same name,
                        // replacing the contents of the last set of brackets with the given hiddenInput name
                        if (i !== -1) hiddenInputName = name.substr(0, i) + "[" + hiddenInputName + "]";
                    }
                    this.hiddenInput = this._createEl("input", {
                        type: "hidden",
                        name: hiddenInputName
                    });
                    wrapper.appendChild(this.hiddenInput);
                }
            },
            // add a country <li> to the countryList <ul> container
            _appendListItems: function(countries, className) {
                // we create so many DOM elements, it is faster to build a temp string
                // and then add everything to the DOM in one go at the end
                var tmp = "";
                // for each country
                for (var i = 0; i < countries.length; i++) {
                    var c = countries[i];
                    // open the list item
                    tmp += "<li class='country " + className + "' id='iti-item-" + c.iso2 + "' role='option' data-dial-code='" + c.dialCode + "' data-country-code='" + c.iso2 + "'>";
                    // add the flag
                    tmp += "<div class='flag-box'><div class='iti-flag " + c.iso2 + "'></div></div>";
                    // and the country name and dial code
                    tmp += "<span class='country-name'>" + c.name + "</span>";
                    tmp += "<span class='dial-code'>+" + c.dialCode + "</span>";
                    // close the list item
                    tmp += "</li>";
                }
                this.countryList.insertAdjacentHTML("beforeend", tmp);
            },
            // set the initial state of the input value and the selected flag by:
            // 1. extracting a dial code from the given number
            // 2. using explicit initialCountry
            // 3. picking the first preferred country
            // 4. picking the first country
            _setInitialState: function() {
                var val = this.telInput.value;
                var dialCode = this._getDialCode(val);
                var isRegionlessNanp = this._isRegionlessNanp(val);
                // if we already have a dial code, and it's not a regionlessNanp, we can go ahead and set the flag, else fall back to the default country
                if (dialCode && !isRegionlessNanp) {
                    this._updateFlagFromNumber(val);
                } else if (this.options.initialCountry !== "auto") {
                    // see if we should select a flag
                    if (this.options.initialCountry) {
                        this._setFlag(this.options.initialCountry.toLowerCase());
                    } else {
                        if (dialCode && isRegionlessNanp) {
                            // has intl dial code, is regionless nanp, and no initialCountry, so default to US
                            this._setFlag("us");
                        } else {
                            // no dial code and no initialCountry, so default to first in list
                            this.defaultCountry = this.preferredCountries.length ? this.preferredCountries[0].iso2 : this.countries[0].iso2;
                            if (!val) {
                                this._setFlag(this.defaultCountry);
                            }
                        }
                    }
                    // if empty and no nationalMode and no autoHideDialCode then insert the default dial code
                    if (!val && !this.options.nationalMode && !this.options.autoHideDialCode && !this.options.separateDialCode) {
                        this.telInput.value = "+" + this.selectedCountryData.dialCode;
                    }
                }
                // NOTE: if initialCountry is set to auto, that will be handled separately
                // format
                if (val) {
                    // this wont be run after _updateDialCode as that's only called if no val
                    this._updateValFromNumber(val);
                }
            },
            // initialise the main event listeners: input keyup, and click selected flag
            _initListeners: function() {
                this._initKeyListeners();
                if (this.options.autoHideDialCode) {
                    this._initFocusListeners();
                }
                if (this.options.allowDropdown) {
                    this._initDropdownListeners();
                }
                if (this.hiddenInput) {
                    this._initHiddenInputListener();
                }
            },
            // update hidden input on form submit
            _initHiddenInputListener: function() {
                var that = this;
                this._handleHiddenInputSubmit = function() {
                    that.hiddenInput.value = that.getNumber();
                };
                var form = this.telInput.form;
                if (form) form.addEventListener("submit", this._handleHiddenInputSubmit);
            },
            // iterate through parent nodes to find the closest label ancestor, if it exists
            _getClosestLabel: function() {
                var el = this.telInput;
                while (el && el.tagName !== "LABEL") el = el.parentNode;
                return el;
            },
            // initialise the dropdown listeners
            _initDropdownListeners: function() {
                var that = this;
                // hack for input nested inside label (which is valid markup): clicking the selected-flag to open the dropdown would then automatically trigger a 2nd click on the input which would close it again
                this._handleLabelClick = function(e) {
                    // if the dropdown is closed, then focus the input, else ignore the click
                    if (that.countryList.classList.contains("hide")) {
                        that.telInput.focus();
                    } else {
                        e.preventDefault();
                    }
                };
                var label = this._getClosestLabel();
                if (label) label.addEventListener("click", this._handleLabelClick);
                // toggle country dropdown on click
                this._handleClickSelectedFlag = function() {
                    // only intercept this event if we're opening the dropdown
                    // else let it bubble up to the top ("click-off-to-close" listener)
                    // we cannot just stopPropagation as it may be needed to close another instance
                    if (that.countryList.classList.contains("hide") && !that.telInput.disabled && !that.telInput.readOnly) {
                        that._showDropdown();
                    }
                };
                this.selectedFlag.addEventListener("click", this._handleClickSelectedFlag);
                // open dropdown list if currently focused
                this._handleFlagsContainerKeydown = function(e) {
                    var isDropdownHidden = that.countryList.classList.contains("hide");
                    if (isDropdownHidden && [ "ArrowUp", "ArrowDown", " ", "Enter" ].indexOf(e.key) !== -1) {
                        // prevent form from being submitted if "ENTER" was pressed
                        e.preventDefault();
                        // prevent event from being handled again by document
                        e.stopPropagation();
                        that._showDropdown();
                    }
                    // allow navigation from dropdown to input on TAB
                    if (e.key === "Tab") that._closeDropdown();
                };
                this.flagsContainer.addEventListener("keydown", this._handleFlagsContainerKeydown);
            },
            // init many requests: utils script / geo ip lookup
            _initRequests: function() {
                var that = this;
                // if the user has specified the path to the utils script, fetch it on window.load, else resolve
                if (this.options.utilsScript && !window.intlTelInputUtils) {
                    // if the plugin is being initialised after the window.load event has already been fired
                    if (window.intlTelInputGlobals.windowLoaded) {
                        window.intlTelInputGlobals.loadUtils(this.options.utilsScript);
                    } else {
                        // wait until the load event so we don't block any other requests e.g. the flags image
                        window.addEventListener("load", function() {
                            window.intlTelInputGlobals.loadUtils(that.options.utilsScript);
                        });
                    }
                } else {
                    this.resolveUtilsScriptPromise();
                }
                if (this.options.initialCountry === "auto") {
                    this._loadAutoCountry();
                } else {
                    this.resolveAutoCountryPromise();
                }
            },
            // perform the geo ip lookup
            _loadAutoCountry: function() {
                var that = this;
                // 3 options:
                // 1) already loaded (we're done)
                // 2) not already started loading (start)
                // 3) already started loading (do nothing - just wait for loading callback to fire)
                if (window.intlTelInputGlobals.autoCountry) {
                    this.handleAutoCountry();
                } else if (!window.intlTelInputGlobals.startedLoadingAutoCountry) {
                    // don't do this twice!
                    window.intlTelInputGlobals.startedLoadingAutoCountry = true;
                    if (typeof this.options.geoIpLookup === "function") {
                        this.options.geoIpLookup(function(countryCode) {
                            window.intlTelInputGlobals.autoCountry = countryCode.toLowerCase();
                            // tell all instances the auto country is ready
                            // TODO: this should just be the current instances
                            // UPDATE: use setTimeout in case their geoIpLookup function calls this callback straight away (e.g. if they have already done the geo ip lookup somewhere else). Using setTimeout means that the current thread of execution will finish before executing this, which allows the plugin to finish initialising.
                            setTimeout(function() {
                                forEachInstance("handleAutoCountry");
                            });
                        }, function() {
                            forEachInstance("rejectAutoCountryPromise");
                        });
                    }
                }
            },
            // initialize any key listeners
            _initKeyListeners: function() {
                var that = this;
                // update flag on keyup
                this._handleKeyupEvent = function() {
                    if (that._updateFlagFromNumber(that.telInput.value)) {
                        that._triggerCountryChange();
                    }
                };
                this.telInput.addEventListener("keyup", this._handleKeyupEvent);
                // update flag on cut/paste events (now supported in all major browsers)
                this._handleClipboardEvent = function() {
                    // hack because "paste" event is fired before input is updated
                    setTimeout(that._handleKeyupEvent);
                };
                this.telInput.addEventListener("cut", this._handleClipboardEvent);
                this.telInput.addEventListener("paste", this._handleClipboardEvent);
            },
            // adhere to the input's maxlength attr
            _cap: function(number) {
                var max = this.telInput.getAttribute("maxlength");
                return max && number.length > max ? number.substr(0, max) : number;
            },
            // listen for mousedown, focus and blur (for autoHideDialCode feature)
            _initFocusListeners: function() {
                var that = this;
                // mousedown decides where the cursor goes, so if we're focusing we must preventDefault as we'll be inserting the dial code, and we want the cursor to be at the end no matter where they click
                this._handleMousedownFocusEvent = function(e) {
                    if (that.telInput !== document.activeElement && !that.telInput.value) {
                        e.preventDefault();
                        // but this also cancels the focus, so we must trigger that manually
                        that.telInput.focus();
                    }
                };
                this.telInput.addEventListener("mousedown", this._handleMousedownFocusEvent);
                this._handleKeypressPlusEvent = function(e) {
                    if (e.key === "+") that.telInput.value = "";
                };
                // on focus: if empty, insert the dial code for the currently selected flag
                this._handleFocusEvent = function(e) {
                    if (!that.telInput.value && !that.telInput.readOnly && that.selectedCountryData.dialCode) {
                        // insert the dial code
                        that.telInput.value = "+" + that.selectedCountryData.dialCode;
                        // after auto-inserting a dial code, if the first key they hit is '+' then assume they are entering a new number, so remove the dial code. use keypress instead of keydown because keydown gets triggered for the shift key (required to hit the + key), and instead of keyup because that shows the new '+' before removing the old one
                        that.telInput.addEventListener("keypress", that._handleKeypressPlusEvent);
                        // after tabbing in, make sure the cursor is at the end we must use setTimeout to get outside of the focus handler as it seems the selection happens after that
                        setTimeout(function() {
                            var len = that.telInput.value.length;
                            that.telInput.setSelectionRange(len, len);
                        });
                    }
                };
                this.telInput.addEventListener("focus", this._handleFocusEvent);
                // on blur or form submit: if just a dial code then remove it
                this._handleSubmitOrBlurEvent = function() {
                    that._removeEmptyDialCode();
                };
                var form = this.telInput.form;
                if (form) form.addEventListener("submit", this._handleSubmitOrBlurEvent);
                this.telInput.addEventListener("blur", this._handleSubmitOrBlurEvent);
            },
            _removeEmptyDialCode: function() {
                var startsPlus = this.telInput.value.charAt(0) === "+";
                if (startsPlus) {
                    var numeric = this._getNumeric(this.telInput.value);
                    // if just a plus, or if just a dial code
                    if (!numeric || this.selectedCountryData.dialCode == numeric) {
                        this.telInput.value = "";
                    }
                }
                // remove the keypress listener we added on focus
                this.telInput.removeEventListener("keypress", this._handleKeypressPlusEvent);
            },
            // extract the numeric digits from the given string
            _getNumeric: function(s) {
                return s.replace(/\D/g, "");
            },
            // trigger a custom event on the input
            _trigger: function(name) {
                // have to use old school document.createEvent as IE11 doesn't support `new Event()` syntax
                var e = document.createEvent("Event");
                e.initEvent(name, true, true);
                //can bubble, and is cancellable
                this.telInput.dispatchEvent(e);
            },
            // show the dropdown
            _showDropdown: function() {
                this.countryList.classList.remove("hide");
                this.countryList.setAttribute("aria-expanded", "true");
                this._setDropdownPosition();
                // update highlighting and scroll to active list item
                var activeItem = this.countryList.querySelector(".active");
                if (activeItem) {
                    this._highlightListItem(activeItem);
                    this._scrollTo(activeItem);
                }
                // bind all the dropdown-related listeners: mouseover, click, click-off, keydown
                this._bindDropdownListeners();
                // update the arrow
                this.dropdownArrow.classList.add("up");
                this._trigger("open:countrydropdown");
            },
            // make sure the el has the className or not, depending on the value of shouldHaveClass
            _toggleClass: function(el, className, shouldHaveClass) {
                if (shouldHaveClass && !el.classList.contains(className)) el.classList.add(className); else if (!shouldHaveClass && el.classList.contains(className)) el.classList.remove(className);
            },
            // decide where to position dropdown (depends on position within viewport, and scroll)
            _setDropdownPosition: function() {
                var that = this;
                if (this.options.dropdownContainer) {
                    this.options.dropdownContainer.appendChild(this.dropdown);
                }
                if (!this.isMobile) {
                    var pos = this.telInput.getBoundingClientRect(), // windowTop from https://stackoverflow.com/a/14384091/217866
                    windowTop = window.pageYOffset || document.documentElement.scrollTop, inputTop = pos.top + windowTop, dropdownHeight = this.countryList.offsetHeight, // dropdownFitsBelow = (dropdownBottom < windowBottom)
                    dropdownFitsBelow = inputTop + this.telInput.offsetHeight + dropdownHeight < windowTop + window.innerHeight, dropdownFitsAbove = inputTop - dropdownHeight > windowTop;
                    // by default, the dropdown will be below the input. If we want to position it above the input, we add the dropup class.
                    this._toggleClass(this.countryList, "dropup", !dropdownFitsBelow && dropdownFitsAbove);
                    // if dropdownContainer is enabled, calculate postion
                    if (this.options.dropdownContainer) {
                        // by default the dropdown will be directly over the input because it's not in the flow. If we want to position it below, we need to add some extra top value.
                        var extraTop = !dropdownFitsBelow && dropdownFitsAbove ? 0 : this.telInput.offsetHeight;
                        // calculate placement
                        this.dropdown.style.top = "" + (inputTop + extraTop) + "px";
                        this.dropdown.style.left = "" + (pos.left + document.body.scrollLeft) + "px";
                        // close menu on window scroll
                        this._handleWindowScroll = function() {
                            that._closeDropdown();
                        };
                        window.addEventListener("scroll", this._handleWindowScroll);
                    }
                }
            },
            // iterate through parent nodes to find the closest list item
            _getClosestListItem: function(target) {
                var el = target;
                while (el && el !== this.countryList && !el.classList.contains("country")) el = el.parentNode;
                // if we reached the countryList element, then return null
                return el === this.countryList ? null : el;
            },
            // we only bind dropdown listeners when the dropdown is open
            _bindDropdownListeners: function() {
                var that = this;
                // when mouse over a list item, just highlight that one
                // we add the class "highlight", so if they hit "enter" we know which one to select
                this._handleMouseoverCountryList = function(e) {
                    // handle event delegation, as we're listening for this event on the countryList
                    var listItem = that._getClosestListItem(e.target);
                    if (listItem) that._highlightListItem(listItem);
                };
                this.countryList.addEventListener("mouseover", this._handleMouseoverCountryList);
                // listen for country selection
                this._handleClickCountryList = function(e) {
                    var listItem = that._getClosestListItem(e.target);
                    if (listItem) that._selectListItem(listItem);
                };
                this.countryList.addEventListener("click", this._handleClickCountryList);
                // click off to close
                // (except when this initial opening click is bubbling up)
                // we cannot just stopPropagation as it may be needed to close another instance
                var isOpening = true;
                this._handleClickOffToClose = function() {
                    if (!isOpening) that._closeDropdown();
                    isOpening = false;
                };
                document.documentElement.addEventListener("click", this._handleClickOffToClose);
                // listen for up/down scrolling, enter to select, or letters to jump to country name.
                // use keydown as keypress doesn't fire for non-char keys and we want to catch if they
                // just hit down and hold it to scroll down (no keyup event).
                // listen on the document because that's where key events are triggered if no input has focus
                var query = "", queryTimer = null;
                this._handleKeydownOnDropdown = function(e) {
                    // prevent down key from scrolling the whole page,
                    // and enter key from submitting a form etc
                    e.preventDefault();
                    // up and down to navigate
                    if (e.key === "ArrowUp" || e.key === "ArrowDown") that._handleUpDownKey(e.key); else if (e.key === "Enter") that._handleEnterKey(); else if (e.key === "Escape") that._closeDropdown(); else if (/^[a-zA-ZÀ-ÿ ]$/.test(e.key)) {
                        // jump to countries that start with the query string
                        if (queryTimer) clearTimeout(queryTimer);
                        query += e.key.toLowerCase();
                        that._searchForCountry(query);
                        // if the timer hits 1 second, reset the query
                        queryTimer = setTimeout(function() {
                            query = "";
                        }, 1e3);
                    }
                };
                document.addEventListener("keydown", this._handleKeydownOnDropdown);
            },
            // highlight the next/prev item in the list (and ensure it is visible)
            _handleUpDownKey: function(key) {
                var current = this.countryList.querySelector(".country.highlight");
                var next = key === "ArrowUp" ? current.previousElementSibling : current.nextElementSibling;
                if (next) {
                    // skip the divider
                    if (next.classList.contains("divider")) {
                        next = key === "ArrowUp" ? next.previousElementSibling : next.nextElementSibling;
                    }
                    this._highlightListItem(next);
                    this._scrollTo(next);
                }
            },
            // select the currently highlighted item
            _handleEnterKey: function() {
                var currentCountry = this.countryList.querySelector(".country.highlight");
                if (currentCountry) {
                    this._selectListItem(currentCountry);
                }
            },
            // find the first list item whose name starts with the query string
            _searchForCountry: function(query) {
                for (var i = 0; i < this.countries.length; i++) {
                    if (this._startsWith(this.countries[i].name, query)) {
                        var listItem = this.countryList.querySelector("#iti-item-" + this.countries[i].iso2);
                        // update highlighting and scroll
                        this._highlightListItem(listItem);
                        this._scrollTo(listItem, true);
                        break;
                    }
                }
            },
            // check if string a starts with string b
            _startsWith: function(a, b) {
                return a.substr(0, b.length).toLowerCase() == b;
            },
            // update the input's value to the given val (format first if possible)
            // NOTE: this is called from _setInitialState, handleUtils and setNumber
            _updateValFromNumber: function(number) {
                if (this.options.formatOnDisplay && window.intlTelInputUtils && this.selectedCountryData) {
                    var format = !this.options.separateDialCode && (this.options.nationalMode || number.charAt(0) != "+") ? intlTelInputUtils.numberFormat.NATIONAL : intlTelInputUtils.numberFormat.INTERNATIONAL;
                    number = intlTelInputUtils.formatNumber(number, this.selectedCountryData.iso2, format);
                }
                number = this._beforeSetNumber(number);
                this.telInput.value = number;
            },
            // check if need to select a new flag based on the given number
            // Note: called from _setInitialState, keyup handler, setNumber
            _updateFlagFromNumber: function(number) {
                // if we're in nationalMode and we already have US/Canada selected, make sure the number starts with a +1 so _getDialCode will be able to extract the area code
                // update: if we dont yet have selectedCountryData, but we're here (trying to update the flag from the number), that means we're initialising the plugin with a number that already has a dial code, so fine to ignore this bit
                if (number && this.options.nationalMode && this.selectedCountryData.dialCode == "1" && number.charAt(0) != "+") {
                    if (number.charAt(0) != "1") {
                        number = "1" + number;
                    }
                    number = "+" + number;
                }
                // try and extract valid dial code from input
                var dialCode = this._getDialCode(number), countryCode = null, numeric = this._getNumeric(number);
                if (dialCode) {
                    // check if one of the matching countries is already selected
                    var countryCodes = this.countryCodes[this._getNumeric(dialCode)], alreadySelected = countryCodes.indexOf(this.selectedCountryData.iso2) !== -1, // check if the given number contains a NANP area code i.e. the only dialCode that could be extracted was +1 (instead of say +1204) and the actual number's length is >=4
                    isNanpAreaCode = dialCode == "+1" && numeric.length >= 4, nanpSelected = this.selectedCountryData.dialCode == "1";
                    // only update the flag if:
                    // A) NOT (we currently have a NANP flag selected, and the number is a regionlessNanp)
                    // AND
                    // B) either a matching country is not already selected OR the number contains a NANP area code (ensure the flag is set to the first matching country)
                    if (!(nanpSelected && this._isRegionlessNanp(numeric)) && (!alreadySelected || isNanpAreaCode)) {
                        // if using onlyCountries option, countryCodes[0] may be empty, so we must find the first non-empty index
                        for (var j = 0; j < countryCodes.length; j++) {
                            if (countryCodes[j]) {
                                countryCode = countryCodes[j];
                                break;
                            }
                        }
                    }
                } else if (number.charAt(0) == "+" && numeric.length) {
                    // invalid dial code, so empty
                    // Note: use getNumeric here because the number has not been formatted yet, so could contain bad chars
                    countryCode = "";
                } else if (!number || number == "+") {
                    // empty, or just a plus, so default
                    countryCode = this.defaultCountry;
                }
                if (countryCode !== null) {
                    return this._setFlag(countryCode);
                }
                return false;
            },
            // check if the given number is a regionless NANP number (expects the number to contain an international dial code)
            _isRegionlessNanp: function(number) {
                var numeric = this._getNumeric(number);
                if (numeric.charAt(0) == "1") {
                    var areaCode = numeric.substr(1, 3);
                    return regionlessNanpNumbers.indexOf(areaCode) !== -1;
                }
                return false;
            },
            // remove highlighting from other list items and highlight the given item
            _highlightListItem: function(listItem) {
                var prevItem = this.countryList.querySelector(".country.highlight");
                if (prevItem) prevItem.classList.remove("highlight");
                listItem.classList.add("highlight");
            },
            // find the country data for the given country code
            // the ignoreOnlyCountriesOption is only used during init() while parsing the onlyCountries array
            _getCountryData: function(countryCode, ignoreOnlyCountriesOption, allowFail) {
                var countryList = ignoreOnlyCountriesOption ? allCountries : this.countries;
                for (var i = 0; i < countryList.length; i++) {
                    if (countryList[i].iso2 == countryCode) {
                        return countryList[i];
                    }
                }
                if (allowFail) {
                    return null;
                } else {
                    throw new Error("No country data for '" + countryCode + "'");
                }
            },
            // select the given flag, update the placeholder and the active list item
            // Note: called from _setInitialState, _updateFlagFromNumber, _selectListItem, setCountry
            _setFlag: function(countryCode) {
                var prevCountry = this.selectedCountryData.iso2 ? this.selectedCountryData : {};
                // do this first as it will throw an error and stop if countryCode is invalid
                this.selectedCountryData = countryCode ? this._getCountryData(countryCode, false, false) : {};
                // update the defaultCountry - we only need the iso2 from now on, so just store that
                if (this.selectedCountryData.iso2) {
                    this.defaultCountry = this.selectedCountryData.iso2;
                }
                this.selectedFlagInner.setAttribute("class", "iti-flag " + countryCode);
                // update the selected country's title attribute
                var title = countryCode ? this.selectedCountryData.name + ": +" + this.selectedCountryData.dialCode : "Unknown";
                this.selectedFlag.setAttribute("title", title);
                if (this.options.separateDialCode) {
                    var dialCode = this.selectedCountryData.dialCode ? "+" + this.selectedCountryData.dialCode : "", parent = this.telInput.parentNode;
                    if (prevCountry.dialCode) {
                        parent.classList.remove("iti-sdc-" + (prevCountry.dialCode.length + 1));
                    }
                    if (dialCode) {
                        parent.classList.add("iti-sdc-" + dialCode.length);
                    }
                    this.selectedDialCode.innerHTML = dialCode;
                }
                // and the input's placeholder
                this._updatePlaceholder();
                // update the active list item
                if (this.options.allowDropdown) {
                    var prevItem = this.countryList.querySelector(".country.active");
                    if (prevItem) {
                        prevItem.classList.remove("active");
                        prevItem.setAttribute("aria-selected", "false");
                    }
                    if (countryCode) {
                        var nextItem = this.countryList.querySelector("#iti-item-" + countryCode);
                        nextItem.classList.add("active");
                        nextItem.setAttribute("aria-selected", "true");
                        this.countryList.setAttribute("aria-activedescendant", nextItem.getAttribute("id"));
                    }
                }
                // return if the flag has changed or not
                return prevCountry.iso2 !== countryCode;
            },
            // update the input placeholder to an example number from the currently selected country
            _updatePlaceholder: function() {
                var shouldSetPlaceholder = this.options.autoPlaceholder === "aggressive" || !this.hadInitialPlaceholder && this.options.autoPlaceholder === "polite";
                if (window.intlTelInputUtils && shouldSetPlaceholder) {
                    var numberType = intlTelInputUtils.numberType[this.options.placeholderNumberType], placeholder = this.selectedCountryData.iso2 ? intlTelInputUtils.getExampleNumber(this.selectedCountryData.iso2, this.options.nationalMode, numberType) : "";
                    placeholder = this._beforeSetNumber(placeholder);
                    if (typeof this.options.customPlaceholder === "function") {
                        placeholder = this.options.customPlaceholder(placeholder, this.selectedCountryData);
                    }
                    this.telInput.setAttribute("placeholder", placeholder);
                }
            },
            // called when the user selects a list item from the dropdown
            _selectListItem: function(listItem) {
                // update selected flag and active list item
                var flagChanged = this._setFlag(listItem.getAttribute("data-country-code"));
                this._closeDropdown();
                this._updateDialCode(listItem.getAttribute("data-dial-code"), true);
                // focus the input
                this.telInput.focus();
                // put cursor at end - this fix is required for FF and IE11 (with nationalMode=false i.e. auto inserting dial code), who try to put the cursor at the beginning the first time
                var len = this.telInput.value.length;
                this.telInput.setSelectionRange(len, len);
                if (flagChanged) {
                    this._triggerCountryChange();
                }
            },
            // close the dropdown and unbind any listeners
            _closeDropdown: function() {
                this.countryList.classList.add("hide");
                this.countryList.setAttribute("aria-expanded", "false");
                // update the arrow
                this.dropdownArrow.classList.remove("up");
                // unbind key events
                document.removeEventListener("keydown", this._handleKeydownOnDropdown);
                document.documentElement.removeEventListener("click", this._handleClickOffToClose);
                this.countryList.removeEventListener("mouseover", this._handleMouseoverCountryList);
                this.countryList.removeEventListener("click", this._handleClickCountryList);
                // remove menu from container
                if (this.options.dropdownContainer) {
                    if (!this.isMobile) window.removeEventListener("scroll", this._handleWindowScroll);
                    if (this.dropdown.parentNode) this.dropdown.parentNode.removeChild(this.dropdown);
                }
                this._trigger("close:countrydropdown");
            },
            // check if an element is visible within it's container, else scroll until it is
            _scrollTo: function(element, middle) {
                var container = this.countryList, // windowTop from https://stackoverflow.com/a/14384091/217866
                windowTop = window.pageYOffset || document.documentElement.scrollTop, containerHeight = container.offsetHeight, containerTop = container.getBoundingClientRect().top + windowTop, containerBottom = containerTop + containerHeight, elementHeight = element.offsetHeight, elementTop = element.getBoundingClientRect().top + windowTop, elementBottom = elementTop + elementHeight, newScrollTop = elementTop - containerTop + container.scrollTop, middleOffset = containerHeight / 2 - elementHeight / 2;
                if (elementTop < containerTop) {
                    // scroll up
                    if (middle) {
                        newScrollTop -= middleOffset;
                    }
                    container.scrollTop = newScrollTop;
                } else if (elementBottom > containerBottom) {
                    // scroll down
                    if (middle) {
                        newScrollTop += middleOffset;
                    }
                    var heightDifference = containerHeight - elementHeight;
                    container.scrollTop = newScrollTop - heightDifference;
                }
            },
            // replace any existing dial code with the new one
            // Note: called from _selectListItem and setCountry
            _updateDialCode: function(newDialCode, hasSelectedListItem) {
                var inputVal = this.telInput.value, newNumber;
                // save having to pass this every time
                newDialCode = "+" + newDialCode;
                if (inputVal.charAt(0) == "+") {
                    // there's a plus so we're dealing with a replacement (doesn't matter if nationalMode or not)
                    var prevDialCode = this._getDialCode(inputVal);
                    if (prevDialCode) {
                        // current number contains a valid dial code, so replace it
                        newNumber = inputVal.replace(prevDialCode, newDialCode);
                    } else {
                        // current number contains an invalid dial code, so ditch it
                        // (no way to determine where the invalid dial code ends and the rest of the number begins)
                        newNumber = newDialCode;
                    }
                } else if (this.options.nationalMode || this.options.separateDialCode) {
                    // don't do anything
                    return;
                } else {
                    // nationalMode is disabled
                    if (inputVal) {
                        // there is an existing value with no dial code: prefix the new dial code
                        newNumber = newDialCode + inputVal;
                    } else if (hasSelectedListItem || !this.options.autoHideDialCode) {
                        // no existing value and either they've just selected a list item, or autoHideDialCode is disabled: insert new dial code
                        newNumber = newDialCode;
                    } else {
                        return;
                    }
                }
                this.telInput.value = newNumber;
            },
            // try and extract a valid international dial code from a full telephone number
            // Note: returns the raw string inc plus character and any whitespace/dots etc
            _getDialCode: function(number) {
                var dialCode = "";
                // only interested in international numbers (starting with a plus)
                if (number.charAt(0) == "+") {
                    var numericChars = "";
                    // iterate over chars
                    for (var i = 0; i < number.length; i++) {
                        var c = number.charAt(i);
                        // if char is number (https://stackoverflow.com/a/8935649/217866)
                        if (!isNaN(parseInt(c, 10))) {
                            numericChars += c;
                            // if current numericChars make a valid dial code
                            if (this.countryCodes[numericChars]) {
                                // store the actual raw string (useful for matching later)
                                dialCode = number.substr(0, i + 1);
                            }
                            // longest dial code is 4 chars
                            if (numericChars.length == 4) {
                                break;
                            }
                        }
                    }
                }
                return dialCode;
            },
            // get the input val, adding the dial code if separateDialCode is enabled
            _getFullNumber: function() {
                var val = this.telInput.value.trim(), dialCode = this.selectedCountryData.dialCode, prefix, numericVal = this._getNumeric(val), // normalized means ensure starts with a 1, so we can match against the full dial code
                normalizedVal = numericVal.charAt(0) == "1" ? numericVal : "1" + numericVal;
                if (this.options.separateDialCode) {
                    // when using separateDialCode, it is visible so is effectively part of the typed number
                    prefix = "+" + dialCode;
                } else if (val && val.charAt(0) != "+" && val.charAt(0) != "1" && dialCode && dialCode.charAt(0) == "1" && dialCode.length == 4 && dialCode != normalizedVal.substr(0, 4)) {
                    // ensure national NANP numbers contain the area code
                    prefix = dialCode.substr(1);
                } else {
                    prefix = "";
                }
                return prefix + val;
            },
            // remove the dial code if separateDialCode is enabled
            // also cap the length if the input has a maxlength attribute
            _beforeSetNumber: function(number) {
                if (this.options.separateDialCode) {
                    var dialCode = this._getDialCode(number);
                    if (dialCode) {
                        // US dialCode is "+1", which is what we want
                        // CA dialCode is "+1 123", which is wrong - should be "+1" (as it has multiple area codes)
                        // AS dialCode is "+1 684", which is what we want (as it doesn't have area codes)
                        // Solution: if the country has area codes, then revert to just the dial code
                        if (this.selectedCountryData.areaCodes !== null) {
                            dialCode = "+" + this.selectedCountryData.dialCode;
                        }
                        // a lot of numbers will have a space separating the dial code and the main number, and some NANP numbers will have a hyphen e.g. +1 684-733-1234 - in both cases we want to get rid of it
                        // NOTE: don't just trim all non-numerics as may want to preserve an open parenthesis etc
                        var start = number[dialCode.length] === " " || number[dialCode.length] === "-" ? dialCode.length + 1 : dialCode.length;
                        number = number.substr(start);
                    }
                }
                return this._cap(number);
            },
            // trigger the 'countrychange' event
            _triggerCountryChange: function() {
                this._trigger("countrychange");
            },
            /**************************
   *  SECRET PUBLIC METHODS
   **************************/
            // this is called when the geoip call returns
            handleAutoCountry: function() {
                if (this.options.initialCountry === "auto") {
                    // we must set this even if there is an initial val in the input: in case the initial val is invalid and they delete it - they should see their auto country
                    this.defaultCountry = window.intlTelInputGlobals.autoCountry;
                    // if there's no initial value in the input, then update the flag
                    if (!this.telInput.value) {
                        this.setCountry(this.defaultCountry);
                    }
                    this.resolveAutoCountryPromise();
                }
            },
            // this is called when the utils request completes
            handleUtils: function() {
                // if the request was successful
                if (window.intlTelInputUtils) {
                    // if there's an initial value in the input, then format it
                    if (this.telInput.value) {
                        this._updateValFromNumber(this.telInput.value);
                    }
                    this._updatePlaceholder();
                }
                this.resolveUtilsScriptPromise();
            },
            /********************
   *  PUBLIC METHODS
   ********************/
            // remove plugin
            destroy: function() {
                var form = this.telInput.form;
                if (this.options.allowDropdown) {
                    // make sure the dropdown is closed (and unbind listeners)
                    this._closeDropdown();
                    this.selectedFlag.removeEventListener("click", this._handleClickSelectedFlag);
                    this.flagsContainer.removeEventListener("keydown", this._handleFlagsContainerKeydown);
                    // label click hack
                    var label = this._getClosestLabel();
                    if (label) label.removeEventListener("click", this._handleLabelClick);
                }
                // unbind hiddenInput listeners
                if (this.hiddenInput && form) form.removeEventListener("submit", this._handleHiddenInputSubmit);
                // unbind autoHideDialCode listeners
                if (this.options.autoHideDialCode) {
                    this.telInput.removeEventListener("mousedown", this._handleMousedownFocusEvent);
                    this.telInput.removeEventListener("focus", this._handleFocusEvent);
                    if (form) form.removeEventListener("submit", this._handleSubmitOrBlurEvent);
                    this.telInput.removeEventListener("blur", this._handleSubmitOrBlurEvent);
                }
                // unbind all events: key events, and focus/blur events if autoHideDialCode=true
                this.telInput.removeEventListener("keyup", this._handleKeyupEvent);
                this.telInput.removeEventListener("cut", this._handleClipboardEvent);
                this.telInput.removeEventListener("paste", this._handleClipboardEvent);
                // remove markup (but leave the original input)
                var wrapper = this.telInput.parentNode;
                wrapper.parentNode.insertBefore(this.telInput, wrapper);
                wrapper.parentNode.removeChild(wrapper);
                delete window.intlTelInputGlobals.instances[this.id];
            },
            // get the extension from the current number
            getExtension: function() {
                if (window.intlTelInputUtils) {
                    return intlTelInputUtils.getExtension(this._getFullNumber(), this.selectedCountryData.iso2);
                }
                return "";
            },
            // format the number to the given format
            getNumber: function(format) {
                if (window.intlTelInputUtils) {
                    return intlTelInputUtils.formatNumber(this._getFullNumber(), this.selectedCountryData.iso2, format);
                }
                return "";
            },
            // get the type of the entered number e.g. landline/mobile
            getNumberType: function() {
                if (window.intlTelInputUtils) {
                    return intlTelInputUtils.getNumberType(this._getFullNumber(), this.selectedCountryData.iso2);
                }
                return -99;
            },
            // get the country data for the currently selected flag
            getSelectedCountryData: function() {
                return this.selectedCountryData;
            },
            // get the validation error
            getValidationError: function() {
                if (window.intlTelInputUtils) {
                    return intlTelInputUtils.getValidationError(this._getFullNumber(), this.selectedCountryData.iso2);
                }
                return -99;
            },
            // validate the input val - assumes the global function isValidNumber (from utilsScript)
            isValidNumber: function() {
                var val = this._getFullNumber().trim(), countryCode = this.options.nationalMode ? this.selectedCountryData.iso2 : "";
                return window.intlTelInputUtils ? intlTelInputUtils.isValidNumber(val, countryCode) : null;
            },
            // update the selected flag, and update the input val accordingly
            setCountry: function(countryCode) {
                countryCode = countryCode.toLowerCase();
                // check if already selected
                if (!this.selectedFlagInner.classList.contains(countryCode)) {
                    this._setFlag(countryCode);
                    this._updateDialCode(this.selectedCountryData.dialCode, false);
                    this._triggerCountryChange();
                }
            },
            // set the input value and update the flag
            setNumber: function(number) {
                // we must update the flag first, which updates this.selectedCountryData, which is used for formatting the number before displaying it
                var flagChanged = this._updateFlagFromNumber(number);
                this._updateValFromNumber(number);
                if (flagChanged) {
                    this._triggerCountryChange();
                }
            },
            // set the placeholder number typ
            setPlaceholderNumberType: function(type) {
                this.options.placeholderNumberType = type;
                this._updatePlaceholder();
            }
        };
        /********************
 *  STATIC METHODS
 ********************/
        // get the country data object
        window.intlTelInputGlobals.getCountryData = function() {
            return allCountries;
        };
        // inject a <script> element to load utils.js
        var injectScript = function(path, handleSuccess, handleFailure) {
            // inject a new script element into the page
            var script = document.createElement("script");
            script.onload = function() {
                forEachInstance("handleUtils");
                if (handleSuccess) handleSuccess();
            };
            script.onerror = function() {
                forEachInstance("rejectUtilsScriptPromise");
                if (handleFailure) handleFailure();
            };
            script.className = "iti-load-utils";
            script.async = true;
            script.src = path;
            document.body.appendChild(script);
        };
        // load the utils script
        window.intlTelInputGlobals.loadUtils = function(path) {
            // 2 options:
            // 1) not already started loading (start)
            // 2) already started loading (do nothing - just wait for the onload callback to fire, which will trigger handleUtils on all instances, invoking each of their resolveUtilsScriptPromise functions)
            if (!window.intlTelInputUtils && !window.intlTelInputGlobals.startedLoadingUtilsScript) {
                // only do this once
                window.intlTelInputGlobals.startedLoadingUtilsScript = true;
                // if we have promises, then return a promise
                if (typeof Promise !== "undefined") {
                    return new Promise(function(resolve, reject) {
                        injectScript(path, resolve, reject);
                    });
                } else injectScript(path);
            }
            return null;
        };
        // default options
        window.intlTelInputGlobals.defaults = defaults;
        // version
        window.intlTelInputGlobals.version = "14.0.2";
        // convenience wrapper
        return function(input, options) {
            var iti = new Iti(input, options);
            iti._init();
            window.intlTelInputGlobals.instances[iti.id] = iti;
            return iti;
        };
    }();
});
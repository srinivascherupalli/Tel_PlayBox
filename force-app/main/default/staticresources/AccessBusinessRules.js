// AccessBusinessRules
var ACCESS_TYPES = {
    telstrFibreAccess: "Telstra Fibre Access",
    nbn: "NBN Access",
    mobileAccess: "Mobile Access",
    noAccess: "CWP solution cannot be sold for this site"
};

var ACCESS_TYPE_RULES = [
    // 3 - 4
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: true},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: true},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: true},

    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.mobileAccess], MobileBackup: false},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.mobileAccess], MobileBackup: false},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.mobileAccess], MobileBackup: false},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.mobileAccess], MobileBackup: false},
    {UsersFrom: 3, UsersTo: 4, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.mobileAccess], MobileBackup: false},

    // 5 - 7
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},

    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 5, UsersTo: 7, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    // 8 - 17
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},

    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 8, UsersTo: 17, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    // 18 - 36
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'yes', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},

    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'CAT1',WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: 'no', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 18, UsersTo: 36, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    // 37 - 56
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.nbn, ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},

    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 37, UsersTo: 56, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    // 57 - 78
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: 'na', NBNCompatibility: 'yes', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.nbn], MobileBackup: false},

    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 57, UsersTo: 78, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

    // 79 - 131
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'yes', NBNTechnologyType: 'FTTP', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},

    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'yes', NBNTechnologyType: 'FTTB', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess, ACCESS_TYPES.nbn], MobileBackup: false},
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'yes', NBNTechnologyType: 'FTTN', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'yes', NBNTechnologyType: 'FTTC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[], MobileBackup: false},

    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'yes', NBNTechnologyType: 'HFC', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'', WorkCostFrom:null, WorkCostTo:null, TelstraFibreCompatibility: '', AccessType:[], MobileBackup: false},
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT1', WorkCostFrom:0, WorkCostTo:0, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:null, WorkCostTo:500, TelstraFibreCompatibility: 'yes', AccessType:[ACCESS_TYPES.telstrFibreAccess], MobileBackup: false},
    {UsersFrom: 79, UsersTo: 131, NBNAvailability: 'no', NBNTechnologyType: '', VacantCopperPairAvailable: '', NBNCompatibility: 'no', WidefeasCategory:'CAT2,CAT3,CAT4', WorkCostFrom:500, WorkCostTo:null, TelstraFibreCompatibility: 'no', AccessType:[ACCESS_TYPES.noAccess], MobileBackup: false},

];

function getAccessTypeRule(users, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable, NBNCompatibility, WidefeasCategory, WorkCost, TelstraFibreCompatibility) {

    console.log('getAccessTypeRule',users, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable, NBNCompatibility, WidefeasCategory, WorkCost, TelstraFibreCompatibility);

    if (NBNAvailability)
        NBNAvailability = NBNAvailability.toLowerCase();

    if (VacantCopperPairAvailable)
        VacantCopperPairAvailable = VacantCopperPairAvailable.toLowerCase();

    if (NBNCompatibility)
        NBNCompatibility = NBNCompatibility.toLowerCase();

    if (TelstraFibreCompatibility)
        TelstraFibreCompatibility = TelstraFibreCompatibility.toLowerCase();

    for (var i=0; i<ACCESS_TYPE_RULES.length; i++) {
        var rule = ACCESS_TYPE_RULES[i];

        if (users < rule.UsersFrom || users > rule.UsersTo)
            continue;

        //if (rule.NBNAvailability && NBNAvailability !==rule.NBNAvailability)
        //continue;

        //if (rule.NBNTechnologyType && NBNTechnologyType !==rule.NBNTechnologyType)
        //continue;

        //if (rule.VacantCopperPairAvailable && VacantCopperPairAvailable !==rule.VacantCopperPairAvailable)
        //continue;

        if (rule.NBNCompatibility && NBNCompatibility !==rule.NBNCompatibility)
            continue;

        if (rule.TelstraFibreCompatibility && rule.TelstraFibreCompatibility !== TelstraFibreCompatibility)
            continue;

        //if (WidefeasCategory && rule.WidefeasCategory && !rule.WidefeasCategory.includes(WidefeasCategory))
        // continue;

        //if (!WidefeasCategory && rule.WidefeasCategory)
        // continue;

        //if (WorkCost) {
        //if (rule.WorkCostFrom && WorkCost <= rule.WorkCostFrom)
        //continue;

        // if (rule.WorkCostTo && WorkCost >= rule.WorkCostTo)
        //continue;
        //} else {
        //if (rule.WorkCostFrom || rule.WorkCostTo)
        //  continue;
        //}

        return rule;
    }
    return null;
};

function getNBNCompatibilityRule(users, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable) {

    console.log('getNBNCompatibilityRule inside',users, NBNAvailability, NBNTechnologyType, VacantCopperPairAvailable);

    if (NBNAvailability)
        NBNAvailability = NBNAvailability.toLowerCase();

    if (VacantCopperPairAvailable)
        VacantCopperPairAvailable = VacantCopperPairAvailable.toLowerCase();

    for (var i=0; i<ACCESS_TYPE_RULES.length; i++) {
        var rule = ACCESS_TYPE_RULES[i];

        if (users < rule.UsersFrom || users > rule.UsersTo)
            continue;
        if(NBNAvailability == 'yes'){

            if (rule.NBNAvailability && NBNAvailability !==rule.NBNAvailability)
                continue;
    
            if (rule.NBNTechnologyType && NBNTechnologyType !==rule.NBNTechnologyType)
                continue;
            if (rule.VacantCopperPairAvailable && rule.VacantCopperPairAvailable!='na' && VacantCopperPairAvailable !==rule.VacantCopperPairAvailable)
                continue;
            if(rule.NBNCompatibility == 'yes'){
                return 'Yes';
            }else{
                return 'No';
            }
        }else{
            return 'No';
        }
    }
    return null;
};
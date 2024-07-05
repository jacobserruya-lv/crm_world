public with sharing class TWIST_DateUtils {

    private static final Set<String> localesWithEnglishDateFormat = new Set<String> {
        'eng-ca',
        'fra-ca',
        'jpn-jp',
        'eng-e1',
        'eng-us',
        'eng-kw',
        'eng-ae',
        'eng-gb',
        'eng-nl'
    };
    private static final Set<String> localesWithFrenchDateFormat = new Set<String> {
        'fra-fr',
        'por-br',
        'esp-mx',
        'deu-de',
        'esp-es',
        'ita-it',
        'rus-ru',
        'ara-ae',
        'zhs-cn',
        'kor-kr',
        'zht-hk',
        'eng-sg',
        'zht-tw',
        'tha-th',
        'vie-vn',
        'eng-id',
        'ind-id',
        'eng-au'
    };

    @testVisible private static final String dateSeparator = '/';
    @testVisible private static final String dayPlaceholder = 'day';
    @testVisible private static final String monthPlaceholder = 'month';
    @testVisible private static final String yearPlaceholder = 'year';

    public static String getDateFormatByLangCountry(String langCountry) {
        if (doesLangCountryMatchEnglishDateFormat(langCountry)) {
            return String.format('{0}{1}{2}{3}{4}', new List<String> {
                yearPlaceholder,
                dateSeparator,
                monthPlaceholder,
                dateSeparator,
                dayPlaceholder
            });
        }
        if (doesLangCountryMatchFrenchDateFormat(langCountry)) {
            return String.format('{0}{1}{2}{3}{4}', new List<String> {
                dayPlaceholder,
                dateSeparator,
                monthPlaceholder,
                dateSeparator,
                yearPlaceholder
            });
        }
        return String.format('{0}{1}{2}{3}{4}', new List<String> {
            monthPlaceholder,
            dateSeparator,
            dayPlaceholder,
            dateSeparator,
            yearPlaceholder
        });
    }

    private static Boolean doesLangCountryMatchEnglishDateFormat(String langCountry) {
        return localesWithEnglishDateFormat.contains(langCountry);
    }

    private static Boolean doesLangCountryMatchFrenchDateFormat(String langCountry) {
        return localesWithFrenchDateFormat.contains(langCountry);
    }

}
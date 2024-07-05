const config = {
    "FilterCriterion": {
        "management_zone_level": 282,
        "management_zone_level_1": 285,
        "management_zone_level_2": 288,
        "management_zone_level_3": 291,
        "default_store": 38,
        "prefered_ca": 509,
        "gender": 7,
        "clientTypology": 4,
        "subSegmentation": 518,
        "segmentation10k": 401,
        "is_10k_this_year": 514,
        "is_50k": 402,
        "is_10k": [
            0,
            1
        ],
        "is_potential_10k": [
            2,
            3
        ],
        "is_prospect": [
            7
        ],
        "contactable_by_sms_or_chat": 31,
        "contactable_by_phone": 30,
        "contactable_by_email": 28,
        "contactable_by_at_least_one_chan": [
            "contactable_by_sms_or_chat",
            "contactable_by_phone",
            "contactable_by_email"
        ],
        "has_purchase": 29,
        "has_purchase_12mr": 515,
        "has_purchase_ytd": 516,
        "productCategory": {
            "type": 120,
            "gender": 115,
            "macroFunction": 110,
            "macroMaterial": 112,
            "model": 114,
            "isHighEnd": 348
        },
        "product_categories": {
            "PFM": {
                "type": "z09"
            },
            "WAT": {
                "type": "z03"
            },
            "ACC": {
                "type": "z02"
            },
            "Watch_Jewelry": {
                "type": "z07"
            },
            "ObjNomade_Hardsided": {
                "macroFunction": "hardsided"
            },
            "Leather_bag": {
                "type": "z01",
                "macroFunction": "city bags",
                "macroMaterial": "leather"
            },
            "men_rtw": {
                "type": "z05",
                "gender": "men"
            },
            "women_rtw": {
                "type": "z05",
                "gender": "women"
            },
            "Travel": {
                "macroFunction": "travel"
            },
            "capucines": {
                "type": "z01",
                "model": "capucines"
            },
            "JEW": {
                "type": [
                    "z07",
                    "z03"
                ],
                "isHighEnd": true
            },
            "USD_HE_exotics": {
                "macroMaterial": "exotic leather"
            },
            "men_shoe": {
                "type": "z04",
                "gender": "men"
            },
            "women_shoe": {
                "type": "z04",
                "gender": "women"
            },
            "LG": {
                "type": "z01"
            }
        }
    },
    "SegmentationValues": {
        "is_10k": [
            0,
            1
        ],
        "is_potential_10k": [
            2,
            3
        ],
        "is_prospect": [
            7
        ]
    },
    "GenderOptions": {
        "0": "u",
        "1": "f",
        "2": "m",
        "3": "o"
    },
    "LogicalOperator": {
        "AND": 1,
        "OR": 2
    },
    "SetsOperator": {
        "Intersect": 1,
        "Union": 2,
        "Except": 3
    },
    "ComparisonOperator": {
        "EqualTo": 1,
        "NotEqualTo": 2,
        "LessThan": 3,
        "GreaterThan": 4,
        "LessThanOrEqual": 5,
        "GreaterThanOrEqual": 6,
        "In": 7,
        "NotIn": 8,
        "Between": 9,
        "Contains": 10,
        "StartsWith": 11,
        "EndsWith": 12,
        "IsEmpty": 13,
        "IsNotEmpty": 14
    },
    "AggregationFunctionIdOptions": {
        "COUNT": 1,
        "SUM": 2
    },
    "AggregationOperatorIdOptions": {
        "LessThanOrEqual": 5,
        "GreaterThanOrEqual": 6,
        "Between": 9
    },
    "AggregationCriterionIdOptions": {
        "DreamIds": 2
    }
}
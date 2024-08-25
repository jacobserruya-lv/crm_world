import * as Types from "./ct_types";

export class MarketingEngineQueryBuilder {
  /**
   * @param {Types.QueryConfig} queryConfig
  */
  constructor(queryConfig) {
    this.AggregationCriterionIdOptions = queryConfig.AggregationCriterionIdOptions;
    this.AggregationFunctionIdOptions = queryConfig.AggregationFunctionIdOptions;
    this.AggregationOperatorIdOptions = queryConfig.AggregationOperatorIdOptions;
    this.ComparisonOperator = queryConfig.ComparisonOperator;
    this.FilterCriterion = queryConfig.FilterCriterion;
    this.GenderOptions = queryConfig.GenderOptions;
    this.LogicalOperator = queryConfig.LogicalOperator;
    this.SetsOperator = queryConfig.SetsOperator;
  }

  /**
   * @param {Types.Storage} storage
  */
  createCTQuery = ({
    storeHierarchy,
    clientFilters,
    purchaseHistory
  }) => {
    const storeHierarchyPredicates = this.#createStoreHierarchyPredicates(storeHierarchy || {});
    const clientFiltersPredicates = this.#createClientFiltersPredicates(clientFilters || {});
    const { 
      exclude: purchaseHistoryToExcludePredicate,
      include: purchaseHistoryToIncludePredicate,
      purchaseValuePredicate
    } = this.#createPurchaseHistoryPredicates(purchaseHistory || {});

    const mainQueryPredicates = [
      ...storeHierarchyPredicates,
      ...clientFiltersPredicates
    ];
    
    if (purchaseHistoryToIncludePredicate) {
      mainQueryPredicates.push(purchaseHistoryToIncludePredicate);

      if (purchaseValuePredicate) {
        mainQueryPredicates.push(purchaseValuePredicate);
      }
    }

    if (!mainQueryPredicates.length) {
      mainQueryPredicates.push({
        "PredicateType": "true-predicate",
        "CriterionId": 1
      });
    }

    const mainSet = this.#predicatedSet({
      predicate: this.#predicatesGroup({
        predicates: mainQueryPredicates
      })
    });

    const exceptSetPredicates = [
      {
        "PredicateType": "true-predicate",
        "CriterionId": 1
      },
      purchaseHistoryToExcludePredicate
    ];

    if (purchaseValuePredicate) {
      exceptSetPredicates.push(purchaseValuePredicate);
    }

    const exceptSet = purchaseHistoryToExcludePredicate ? this.#predicatedSet({
      predicate: this.#predicatesGroup({
        predicates: exceptSetPredicates
      })
    }) : null;

    const querySet = exceptSet ? this.#setsGroup({sets: [ mainSet, exceptSet ]}) : mainSet;

    return {
      selectionCriterionIds: null,
      targetCriterionId: null,
      creatorUserId: null,
      set: querySet 
    }; 
  }

  /**
   * @param {Types.StoreHierarchy} storeHierarchy
   */
  #createStoreHierarchyPredicates = ({
    prefered_ca,
    userSelectionApplied,
    userSettingsApplied,
    ...managementZoneLevels
  }) => {
    const storeHierarchyPredicates = Object.entries(managementZoneLevels)
      .filter(([_, zoneLevel]) => !!zoneLevel)
      .map(([key, zoneLevel]) => this.#simplePredicate({
        valueType: "Text",
        criterionId: this.FilterCriterion[key],
        operatorId: this.ComparisonOperator.EqualTo,
        values: [zoneLevel]
      })
    );

    if (prefered_ca?.length) {
      storeHierarchyPredicates.push(
        this.#simplePredicate({
          valueType: "Text",
          criterionId: this.FilterCriterion.prefered_ca,
          operatorId: this.ComparisonOperator.In,
          values: prefered_ca.map((ca) => ca.employeeNumber)
        })
      );
    }

    return storeHierarchyPredicates;
  };

  /**
   * @param {Types.ClientFilters} clientFilters
   */
  #createClientFiltersPredicates = (clientFilters) => {
    const clientFiltersPredicates = [];

    if (clientFilters.gender?.length) {
      clientFiltersPredicates.push(
        this.#createGenderFiltersPredicates(clientFilters)
      );
    }

    if (clientFilters.contactableValue?.length) {
      clientFiltersPredicates.push(
        this.#createContactableFiltersPredicates(clientFilters)
      );
    }

    if (clientFilters.segmentationValue?.length) {
      clientFiltersPredicates.push(
        this.#createNewSegmentationFiltersPredicates(clientFilters)
      );
    }

    return clientFiltersPredicates;
  };

  /**
   * @param {Types.ClientFilters} clientFilters
   */
  #createGenderFiltersPredicates = ({
    gender: genderFilters
  }) => {
    return this.#simplePredicate({
      valueType: "Text",
      criterionId: this.FilterCriterion.gender,
      operatorId: this.ComparisonOperator.In,
      values: Object.values(genderFilters).map((v) => this.GenderOptions[v])
    });
  };

  /**
   * @param {Types.ClientFilters} clientFilters
   */
  #createContactableFiltersPredicates = ({
    contactableValue: contactableFilters
  }) => {
    const atLeastOneChan = contactableFilters.indexOf("contactable_by_at_least_one_chan") > -1;
    const appliedContactableByFilters = atLeastOneChan ? this.FilterCriterion['contactable_by_at_least_one_chan'] : contactableFilters;

    return this.#predicatesGroup({
      predicates: appliedContactableByFilters.map((contactableBy) =>
        this.#simplePredicate({
          valueType: "Boolean",
          criterionId: this.FilterCriterion[contactableBy],
          operatorId: this.ComparisonOperator.EqualTo,
          values: [true]
        })
      ),
      operatorId: atLeastOneChan
        ? this.LogicalOperator.OR
        : this.LogicalOperator.AND
    });
  };

  /**
   * @param {Types.ClientFilters} clientFilters
   */
  #createSegmentationFiltersPredicates = ({
    segmentationValue: segmentationFilters
  }) => {
    const is10kOrPotential10k = seg => seg === "is_10k" || seg === "is_potential_10k";
    const isProspect = seg => seg === 'is_prospect';

    // Should be only is_10k And is_potential_10k
    const seg10kFilters = segmentationFilters.filter(is10kOrPotential10k);

    // is_prospect as Integer
    const isProspectFilter = segmentationFilters.find(isProspect);
    
    // Should be is_10k_this_year ANd is_50k
    const otherSegmentationFilters = segmentationFilters.filter(seg => !is10kOrPotential10k(seg) && !isProspect(seg));

    const segmentationPredicatesList = otherSegmentationFilters.map((seg) =>
      this.#simplePredicate({
        valueType: "Boolean",
        criterionId: this.FilterCriterion[seg],
        operatorId: this.ComparisonOperator.EqualTo,
        values: [true]
      })
    );

    if (seg10kFilters?.length) {
      segmentationPredicatesList.push(
        this.#simplePredicate({
          valueType: "Integer",
          criterionId: this.FilterCriterion.segmentation10k,
          operatorId: this.ComparisonOperator.In,
          values: seg10kFilters.map((seg) => this.FilterCriterion[seg]).flat(Infinity)
        })
      );
    }

    if (isProspectFilter) {
      segmentationPredicatesList.push(
        this.#simplePredicate({
          valueType: "Integer",
          criterionId: this.FilterCriterion.clientTypology,
          operatorId: this.ComparisonOperator.In,
          values: this.FilterCriterion.is_prospect
        })
      );
    }

    return this.#predicatesGroup({
      predicates: segmentationPredicatesList,
      operatorId: this.LogicalOperator.OR
    });
  };

  /**
   * @param {Types.ClientFilters} clientFilters
   */
  #createNewSegmentationFiltersPredicates = ({
    segmentationValue: segmentationFilters
  }) => {
    const segmentationPredicatesList = [];
    const isProspect = seg => seg === 'is_prospect'; // Not a sub segment, but 
    const isProspectFilter = segmentationFilters.find(isProspect);
    const subSegmentationValues = segmentationFilters.filter((seg) => !isProspect(seg));

    if (isProspectFilter) {
      segmentationPredicatesList.push(
        this.#simplePredicate({
          valueType: "Integer",
          criterionId: this.FilterCriterion.clientTypology,
          operatorId: this.ComparisonOperator.In,
          values: this.FilterCriterion.is_prospect
        })
      );
    }

    if (subSegmentationValues.length) {
      segmentationPredicatesList.push(
        this.#simplePredicate({
          valueType: "Text",
          criterionId: this.FilterCriterion.subSegmentation,
          operatorId: this.ComparisonOperator.In,
          values: subSegmentationValues
        })
      );
    }

    return this.#predicatesGroup({
      predicates: segmentationPredicatesList,
      operatorId: this.LogicalOperator.OR
    });
  };

  /**
   * @param {Types.PurchaseHistory} purchaseHistory
   */
  #createPurchaseHistoryPredicates = ({ productCategories, purchaseValue }) => {
    const productCategoriesIncludePredicates = [];
    const productCategoriesExcludePredicates = [];

    productCategories?.forEach((category) => {
      const categoryFilters = this.FilterCriterion.product_categories[category.value];

      const categoryPredicates = Object.entries(categoryFilters).map(
        ([key, value]) => this.#simplePredicate({
          valueType:  key === "isHighEnd" ? "Boolean" : "Text",
          criterionId: this.FilterCriterion.productCategory[key],
          operatorId: key === "isHighEnd" ? this.ComparisonOperator.EqualTo : this.ComparisonOperator.In,
          values: Array.isArray(value) ? value : [value]
        })
      );

      const categoryPredicate = categoryPredicates.length > 1 ? this.#predicatesGroup({ predicates: categoryPredicates }) : categoryPredicates[0];

      if (category.exclude.state) {
        productCategoriesExcludePredicates.push(categoryPredicate);
      } else {
        productCategoriesIncludePredicates.push(categoryPredicate);
      }
    });

    return {
      include: productCategoriesIncludePredicates.length ? this.#aggregatePredicate({
        predicate: this.#predicatesGroup({
          operatorId: this.LogicalOperator.OR,
          predicates: productCategoriesIncludePredicates
        })
      }) : null,
      exclude: productCategoriesExcludePredicates.length ? this.#aggregatePredicate({
        predicate: this.#predicatesGroup({
          operatorId: this.LogicalOperator.OR,
          predicates: productCategoriesExcludePredicates
        })
      }) : null,
      purchaseValuePredicate: purchaseValue && purchaseValue !== "has_purchase" ? this.#simplePredicate({ 
        valueType: 'Boolean',
        criterionId: this.FilterCriterion[purchaseValue],
        operatorId: this.ComparisonOperator.EqualTo,
        values: [true]
      }) : null
    };
  };

  /**
   * @param {Object} options
   * @param {'Text' | 'Boolean' | 'Date' | 'Integer'} options.valueType
   * @param {number} options.criterionId
   * @param {number} options.operatorId
   * @param {Array} options.values
   */
  #simplePredicate = ({ valueType, criterionId, operatorId, values = [] }) => ({
      PredicateType: 'simple-predicate',
      ValueType: valueType,
      CriterionId: criterionId,
      OperatorId: operatorId,
      Values: values
  });

  /**
   * @param {Object} options
   * @param {number} options.operatorId
   * @param {Array} options.predicates
   */
  #predicatesGroup = ({ operatorId = this.LogicalOperator.AND, predicates = [] }) => ({
    PredicateType: 'predicates-group',
    OperatorId: operatorId,
    Predicates: predicates
  });

  /**
   * @param {Object} options
   * @param {PredicatedGroup | PredicatedSimple} options.predicate
   * @param {number} options.groupingCriterionId
   * @param {number} options.aggregationFunctionId
   * @param {number} options.aggregationCriterionId
   * @param {number} options.operatorId
   * @param {Array} options.values
   */
  #aggregatePredicate = ({ 
    predicate,
    aggregationCriterionId = this.AggregationCriterionIdOptions.DreamIds,
    aggregationFunctionId = this.AggregationFunctionIdOptions.COUNT,
    operatorId = this.AggregationOperatorIdOptions.GreaterThanOrEqual,
    groupingCriterionId = 2,
    values = [1]
  }) => ({
    PredicateType: 'aggregate-predicate',
    Predicate: predicate,
    Aggregate: {
      GroupingCriterionId: groupingCriterionId,
      AggregationFunctionId: aggregationFunctionId,
      AggregationCriterionId: aggregationCriterionId,
      OperatorId: operatorId,
      Values: values
    }
  });

  /**
   * @param {Object} options
   * @param {PredicatedGroup | PredicatedSimple | AggregatePredicate} options.predicate
   */
  #predicatedSet = ({ 
    predicate
  }) => ({
    setType: 'predicate-set',
    predicate: predicate
  });

  /**
   * @param {Object} options
   * @param {Array<PredicatedSet>} options.sets
   * @param {number} options.operatorId
  */
  #setsGroup = ({ 
    sets = [],
    operatorId = this.SetsOperator.Except
  }) => ({
    setType: 'sets-group',
    operatorId: operatorId,
    sets: sets
  });
}
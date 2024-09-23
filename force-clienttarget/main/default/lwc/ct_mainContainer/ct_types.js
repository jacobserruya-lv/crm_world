/**
 * @typedef {Object} PreferredCa
 * @property {string} clients
 * @property {number} id
 * @property {string} employeeNumber
 * @property {[{
 *  label: string,
 *  value: string
 * }]} options
 */

/**
 * @typedef {Object} StoreHierarchy
 * @property {boolean} userSettingsApplied
 * @property {boolean} userSelectionApplied
 * @property {string} management_zone_level
 * @property {string} management_zone_level_1
 * @property {string} management_zone_level_2
 * @property {string} management_zone_level_3
 * @property {string} default_store
 * @property {[PreferredCa]} prefered_ca
 */

/**
 * @typedef {Object} ClientFilters
 * @property {string[]} gender
 * @property {string[]} segmentationValue
 * @property {string[]} contactableValue
 */

/**
 * @typedef {Object} PurchaseHistory
 * @property {'has_purchase' | 'has_purchase_12mr' | 'has_purchase_ytd'}  purchaseValue
 * @property {[{
 *   id: string,
 *   name: string,
 *   value: string,
 *   include: { label, state },
 *   exclude: { label, state }
 *  }]} productCategories
 */

/**
 * @typedef {Object} Storage
 * @property {[string]} dreamIdList
 * @property {[string]} clientList
 * @property {Object} clientListInfo
 * @property {StoreHierarchy} storeHierarchy
 * @property {ClientFilters} clientFilters
 * @property {PurchaseHistory} purchaseHistory
 * @property {Object} eventInfo
 * @property {Object} campaignInfo
 */

/**
 * @typedef {Object} ProductCategory
 * @property {string | [string] | undefined} type
 * @property {string | undefined} gender
 * @property {string | undefined} model
 * @property {string | undefined} macroMaterial
 * @property {string | undefined} macroFunction
 * @property {string | undefined} isHighEnd
 */

/**
 * @typedef {Object} QueryConfig
 * @property {{
 *  management_zone_level: number,
 *  management_zone_level_1: number,
 *  management_zone_level_2: number,
 *  management_zone_level_3: number,
 *  default_store: number,
 *  prefered_ca: number,
 *  gender: number,
 *  clientTypology: number,
 *  subSegmentation: number,
 *  segmentation10k: number,
 *  is_10k: [number],
 *  is_potential_10k: [number],
 *  is_10k_this_year: number,
 *  is_prospect: [number],
 *  is_50k: number,
 *  contactable_by_sms_or_chat: number,
 *  contactable_by_phone: number,
 *  contactable_by_email: number,
 *  contactable_by_at_least_one_chan: [string],
 *  has_purchase: number,
 *  has_purchase_12mr: number,
 *  has_purchase_ytd: number,
 *  productCategory: ProductCategory,
 *  product_categories: {
 *    PFM: ProductCategory,
 *    WAT: ProductCategory,
 *    ACC: ProductCategory,
 *    Watch_Jewelry: ProductCategory,
 *    ObjNomade_Hardsided: ProductCategory,
 *    Leather_bag: ProductCategory,
 *    men_rtw: ProductCategory,
 *    women_rtw: ProductCategory,
 *    Travel: ProductCategory,
 *    capucines: ProductCategory,
 *    JEW: ProductCategory,
 *    USD_HE_exotics: ProductCategory,
 *    men_shoe: ProductCategory,
 *    women_shoe: ProductCategory,
 *    LG: ProductCategory
 *  }
 *}} FilterCriterion
 * @property {{ AND: number, OR: number }} LogicalOperator
 * @property {{ Intersect: number, Union: number, Except: number }} SetsOperator
 * @property {{ COUNT: number, SUM: number }} AggregationFunctionIdOptions
 * @property {{ LessThanOrEqual: number, GreaterThanOrEqual: number, Between: number }} AggregationOperatorIdOptions
 * @property {{ DreamIds: number }} AggregationCriterionIdOptions
 * @property {{
 *  EqualTo: number,
 *  NotEqualTo: number,
 *  LessThan: number,
 *  GreaterThan: number,
 *  LessThanOrEqual: number,
 *  GreaterThanOrEqual: number,
 *  In: number,
 *  NotIn: number,
 *  Between: number,
 *  Contains: number,
 *  StartsWith: number,
 *  EndsWith: number,
 *  IsEmpty: number,
 *  IsNotEmpty: number
 * }} ComparisonOperator
 * @property {{
 *  0: string,
 *  1: string,
 *  2: string,
 *  3: string
 * }} GenderOptions
 */

/**
 * @typedef {Object} MtEngineResponse
 * @property {[{
 *  dream_id: number,
 *  first_transaction_date_hist: date
 *  contactable_by_email: boolean
 * }]} Contacts
 */

export default {};
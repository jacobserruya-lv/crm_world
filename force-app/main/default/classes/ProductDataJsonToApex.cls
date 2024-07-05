// Created by Balink 2018
// Desciption: Parse REsponse from WS ATG

public class ProductDataJsonToApex {

		public String code {get;set;} 
		public List<Content> content {get;set;} 


	public static void consumeObject(JSONParser parser) {
		Integer depth = 0;
		do {
			JSONToken curr = parser.getCurrentToken();
			if (curr == JSONToken.START_OBJECT || 
				curr == JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == JSONToken.END_OBJECT ||
				curr == JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

	public class Hierarchy {
		public String categoryTranslated {get;set;} 
		public String genderTranslated {get;set;} 
		public String category {get;set;} 
		public String gender {get;set;} 
        public String subCategory {get;set;}
        public String subCategoryTranslated {set;get;}

		public Hierarchy(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'categoryTranslated') {
							categoryTranslated = parser.getText();
						} else if (text == 'genderTranslated') {
							genderTranslated = parser.getText();
						} else if (text == 'category') {
							category = parser.getText();
						} else if (text == 'gender') {
							gender = parser.getText();
                        } else if (text == 'subCategory') {
                            subCategory = parser.getText();
                        } else if (text == 'subCategoryTranslated') {
                            subCategoryTranslated = parser.getText();    
						} else {
							System.debug(LoggingLevel.WARN, 'Hierarchy consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class PersonalizationOffers {

		public PersonalizationOffers(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						{
							System.debug(LoggingLevel.WARN, 'PersonalizationOffers consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	/*public class ModelSize {
		public String definitionId {get;set;} 
		public String value {get;set;} 
		public Integer priority {get;set;} 

		public ModelSize(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'definitionId') {
							definitionId = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else if (text == 'priority') {
							priority = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'ModelSize consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}*/
	
	public class Personalization {
		public Boolean hs {get;set;} 
		public Boolean mom {get;set;} 
		public Boolean engravable {get;set;} 
		public List<PersonalizationOffers> personalizationOffers {get;set;} 

		public Personalization(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'hs') {
							hs = parser.getBooleanValue();
						} else if (text == 'mom') {
							mom = parser.getBooleanValue();
						} else if (text == 'engravable') { 
							engravable = parser.getBooleanValue();
						} else if (text == 'personalizationOffers') {
							personalizationOffers = new List<PersonalizationOffers>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								personalizationOffers.add(new PersonalizationOffers(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'Personalization consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	//public class Wrapper_ProduactVariation {
		

		public ProductDataJsonToApex(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'code') {
							code = parser.getText();
						} else if (text == 'content') {
							content = new List<Content>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								content.add(new Content(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	//}
	
	public class Content {
		public String status {get;set;} 
		public Hierarchy hierarchy {get;set;} 
		public String skuId {get;set;} 
		public Detail detail {get;set;} 
		public List<ModelVariation> modelVariation {get;set;} 
		public General general {get;set;} 
		public Commerce commerce {get;set;} 
		public List<Variances> variances {get;set;} 
		public Personalization personalization {get;set;} 
		public CrossSell crossSell {get;set;} 
		public String name {get;set;} 

		public Content(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'status') {
							status = parser.getText();
						} else if (text == 'hierarchy') {
							hierarchy = new Hierarchy(parser);
						} else if (text == 'skuId') {
							skuId = parser.getText();
						} else if (text == 'detail') {
							detail = new Detail(parser);
						} else if (text == 'modelVariation') {
							modelVariation = new List<ModelVariation>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								modelVariation.add(new ModelVariation(parser));
							}
						} else if (text == 'general') {
							general = new General(parser);
						} else if (text == 'commerce') {
							commerce = new Commerce(parser);
						} else if (text == 'variances') {
							variances = new List<Variances>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								variances.add(new Variances(parser));
							}
						} else if (text == 'personalization') {
							personalization = new Personalization(parser);
						} else if (text == 'crossSell') {
							crossSell = new CrossSell(parser);
						} else if (text == 'name') {
							name = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Content consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class General {
		public List<String> otherMedia {get;set;} 
		public String description {get;set;} 
		public String relativeUrl {get;set;} 
		public String howToWear {get;set;} 
		public Material material {get;set;} 
		public String careLink {get;set;} 
		public Material marketingColor {get;set;} 
		public String mainMediaUrl {get;set;} 
		public String url {get;set;}
        public Material size {get;set;} 

		public General(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'otherMedia') {
							otherMedia = new List<String>();
							//while (parser.nextToken() != JSONToken.END_ARRAY) {
							//	otherMedia.add(new String(parser));
							//}
						} else if (text == 'description') {
							description = parser.getText();
						} else if (text == 'relativeUrl') {
							relativeUrl = parser.getText();
						} else if (text == 'howToWear') {
							howToWear = parser.getText();
						} else if (text == 'material') {
							material = new Material(parser);
						} else if (text == 'careLink') {
							careLink = parser.getText();
						} else if (text == 'marketingColor') {
							marketingColor = new Material(parser);
                        } else if (text == 'size') {
                            size = new Material(parser);
						} else if (text == 'mainMediaUrl') {
							mainMediaUrl = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'General consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Commerce {
		public String formattedPrice {get;set;} 
		public Boolean sellableOnline {get;set;} 
		public Integer price {get;set;} 
		public String currency_price {get;set;} 

		public Commerce(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'formattedPrice') {
							formattedPrice = parser.getText();
						} else if (text == 'sellableOnline') {
							sellableOnline = parser.getBooleanValue();
						} else if (text == 'price') {
							price = parser.getIntegerValue();
						} else if (text == 'currency_price' || text == 'currency') {
							currency_price = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Commerce consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Material {
		public String icon {get;set;} 
		public String definitionId {get;set;} 
		public String value {get;set;} 
		public Integer priority {get;set;} 

		public Material(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'icon') {
							icon = parser.getText();
						} else if (text == 'definitionId') {
							definitionId = parser.getText();
						} else if (text == 'value') {
							value = parser.getText();
						} else if (text == 'priority') {
							priority = parser.getIntegerValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Material consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class ModelVariation {
		public String skuId {get;set;} 
		public Material material {get;set;} 
		public Material modelSize {get;set;} 
		public String mainMediaUrl {get;set;} 

		public ModelVariation(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'skuId') {
							skuId = parser.getText();
						} else if (text == 'material') {
							material = new Material(parser);
						} else if (text == 'modelSize') {
							modelSize = new Material(parser);
						} else if (text == 'mainMediaUrl') {
							mainMediaUrl = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'ModelVariation consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
    public class CrossSell {
		public List<RelatedSku> familySku {get;set;} 
		public List<RelatedSku> relatedSku {get;set;} 
		
		public CrossSell(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'familySku') {
							familySku = new List<RelatedSku>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								familySku.add(new RelatedSku(parser));
							}
						} else if (text == 'relatedSku') {
							relatedSku = new List<RelatedSku>();
							while (parser.nextToken() != JSONToken.END_ARRAY) {
								relatedSku.add(new RelatedSku(parser));
							}
						} else {
							System.debug(LoggingLevel.WARN, 'CrossSell consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    
    public class RelatedSku {
		public String skuId {get;set;} 
		public String mainMediaUrl {get;set;} 

		public RelatedSku(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'skuId') {
							skuId = parser.getText();
						}else if (text == 'mainMediaUrl') {
							mainMediaUrl = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'RelatedSku consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
    
	public class Detail {
		public String height {get;set;} 
		public String width {get;set;} 
		public String dimensionsUnit {get;set;} 
		public String longDescription {get;set;} 
		public String length {get;set;} 

		public Detail(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'height') {
							height = parser.getText();
						} else if (text == 'width') {
							width = parser.getText();
						} else if (text == 'dimensionsUnit') {
							dimensionsUnit = parser.getText();
						} else if (text == 'longDescription') {
							longDescription = parser.getText();
						} else if (text == 'length') {
							length = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Detail consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class Variances {
		public String skuId {get;set;} 
		public Material marketingColor {get;set;} 
        public Material size {get;set;}
		public String mainMediaUrl {get;set;} 

		public Variances(JSONParser parser) {
			while (parser.nextToken() != JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != JSONToken.VALUE_NULL) {
						if (text == 'skuId') {
							skuId = parser.getText();
						} else if (text == 'marketingColor') {
							marketingColor = new Material(parser);
                        } else if (text == 'size') {
							size = new Material(parser);
						} else if (text == 'mainMediaUrl') {
							mainMediaUrl = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Variances consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static ProductDataJsonToApex parse(String json) {
		return new ProductDataJsonToApex(System.JSON.createParser(json));
	}
}
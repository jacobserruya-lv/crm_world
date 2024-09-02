/**
 * https://github.com/JPipkin/SFDC-Record-Type-Picklist/blob/master/src/classes/RTPL_PicklistValues.cls
 * Copyright 2018 OpFocus, Inc
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
 * files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
 * modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the 
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
 * IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
public with sharing class ICX_PicklistValuesParser {

	@AuraEnabled public Map<String,PicklistValues> picklistFieldValues;


	public class PicklistValues {
		@AuraEnabled public Map<String,Integer> controllerValues;
		@AuraEnabled public PicklistValue defaultValue;
		@AuraEnabled public String url;
		@AuraEnabled public PicklistValue[] values;
	}

	public class PicklistValue {
		@AuraEnabled public PicklistAttribute attributes;
		@AuraEnabled public String label;
		@AuraEnabled public String value;
		@AuraEnabled public Integer[] validFor;
	}

	public class PicklistAttribute {
		@AuraEnabled public Boolean converted;
		@AuraEnabled public String picklistAttributesValueType;
		@AuraEnabled public Boolean closed;
		@AuraEnabled public Double defaultProbability;
		@AuraEnabled public String forecastCategoryName;
		@AuraEnabled public Boolean won;
	}
}
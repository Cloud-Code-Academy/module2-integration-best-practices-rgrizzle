/**
 * @description Wrapper class to deserialize the JSON response from the Exchange Rate API
 * Students will implement the properties and methods to process the data
 */
public class ExchangeRateWrapper {
    
    // TODO: Implement properties to match the JSON structure of the API response
    // Sample response:
    // {
    //   "base_code": "USD",
    //   "time_last_update_unix": 1740690001,
    //   "conversion_rates": {
    //     "EUR": 0.9488,
    //     "GBP": 0.8393,
    //     "JPY": 136.57,
    //     ...
    //   }
    // }
    
    // Add properties for base currency
    public String base_code;
    
    // Add property for time last updated
    public String time_last_update_unix;
    
    // Add property for rates (using a map)
    public Map<String, Decimal> conversion_rates;

    // Add property for external ID
    // This is an ID you will generate to uniquely identify the exchange rate record
    // This does not come from the API response
    public String externalId; 
    // baseCurrency + '_' + targetCurrency
    
    /**
     * @description Converts the wrapper data to a list of Exchange_Rate__c records
     * @return List<Exchange_Rate__c> The list of exchange rate records
     */
    public List<Exchange_Rate__c> toExchangeRates() {
        // TODO: Implement the method to convert the wrapper data to Exchange_Rate__c records
        // 1. Create a list to hold the Exchange_Rate__c records
        List<Exchange_Rate__c> exchangeRates = new List<Exchange_Rate__c>();

        // 2. Iterate through the rates map
        for(String currencyCode : conversion_rates.keySet()) {
            Decimal rate = conversion_rates.get(currencyCode);

        // 3. For each rate, create an Exchange_Rate__c record
            Exchange_Rate__c er = new Exchange_Rate__c();
            er.Base_Currency__c = base_code;
            er.Target_Currency__c = currencyCode;
            er.Rate__c = rate;
            er.External_Id__c = base_code + '-' + currencyCode;

            exchangeRates.add(er);

        }

        // 4. Return the list of records
        
        return exchangeRates; // Replace with actual implementation
    }
    
    /**
     * @description Static method to parse the JSON response into the wrapper class
     * @param jsonResponse The JSON response from the API
     * @return ExchangeRateWrapper The parsed wrapper instance
     */
    public static ExchangeRateWrapper parse(String jsonResponse) {
        // TODO: Implement the method to parse the JSON response
        // Use JSON.deserialize or JSON.deserializeStrict to parse the response
        try {
            return (ExchangeRateWrapper) JSON.deserialize(jsonResponse, ExchangeRateWrapper.class);
        } catch (Exception e){
            return null; 
        }
        

    }
}
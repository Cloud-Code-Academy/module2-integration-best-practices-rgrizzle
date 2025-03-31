/**
 * @description Service class that handles API callouts to the Exchange Rate API
 * Students will implement the methods to make callouts and process responses
 */
public class ExchangeRateService {
    
    // The named credential to use for the callout
    private static final String NAMED_CREDENTIAL = 'ExchangeRate_API';
    
    // The base currency to use for exchange rates
    private static final String BASE_CURRENCY = 'USD';
    
    /**
     * @description Makes a callout to the Exchange Rate API to get the latest exchange rates
     * @return ExchangeRateWrapper containing the response data
     */
    public static ExchangeRateWrapper getLatestRates() {
        // TODO: Implement the method to make a callout to the Exchange Rate API
        String endpoint = 'callout:' + NAMED_CREDENTIAL + '/latest/' + BASE_CURRENCY;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();

        try{
            HttpResponse response = http.send(request);

            if(response.getStatusCode() == 200){
                return (ExchangeRateWrapper) JSON.deserialize(response.getBody(), ExchangeRateWrapper.class);
            } else {
                System.debug('Error: ' + response.getStatusCode());
                throw new CalloutException('Error: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Callout Exception: ' + e.getMessage());
            throw new CalloutException('Error: ' + e.getMessage());
        }

    }
    
    /**
     * @description Processes the exchange rate data and creates or updates records
     * @param rateData The wrapper containing exchange rate data
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> processRates(ExchangeRateWrapper rateData) {
        // TODO: Implement the method to process rates and create/update records
        System.debug('rateData: ' + rateData);
        List<Exchange_Rate__c> exchangeRatesToUpsert = new List<Exchange_Rate__c>();

        Set<String> targetCurrencies = new Set<String>();

        for(String targetCurrency : rateData.conversion_rates.keySet()) {
            targetCurrencies.add(targetCurrency);
        }
        System.debug('targetCurrencies Set: ' + targetCurrencies);

        List<Exchange_Rate__c> exsistingRecords = [SELECT Id, Base_Currency__c, Target_Currency__c
                                                   FROM Exchange_Rate__c
                                                   WHERE Base_Currency__c = :rateData.base_code
                                                   AND Target_Currency__c IN :targetCurrencies
                                                   ];

        Map<String, Exchange_Rate__c> targetCurrencyToExistingRecordMap = new Map<String, Exchange_Rate__c>();

        for(Exchange_Rate__c er : exsistingRecords) {
            targetCurrencyToExistingRecordMap.put(er.Target_Currency__c, er);
        }

            for(String targetCurrency : rateData.conversion_rates.keySet()) {
                Decimal rate = rateData.conversion_rates.get(targetCurrency);

                Exchange_Rate__c existingRecord = targetCurrencyToExistingRecordMap.get(targetCurrency);

                if(existingRecord != null) {
                    existingRecord.Rate__c = rate;
                    existingRecord.Last_Updated__c = DateTime.now();
                    exchangeRatesToUpsert.add(existingRecord);
                } else {
                Exchange_Rate__c newRecord = new Exchange_Rate__c();
                newRecord.Base_Currency__c = rateData.base_code;
                newRecord.Target_Currency__c = targetCurrency;
                newRecord.Rate__c = rate;
                newRecord.External_Id__c = rateData.base_code + '-' + targetCurrency;
                newRecord.Name = rateData.base_code + '-' + targetCurrency;
                newRecord.Last_Updated__c = DateTime.now();
                exchangeRatesToUpsert.add(newRecord);
                }
            }
        
        upsert exchangeRatesToUpsert;
        System.debug('ExchangeRatesToUpsert: ' + exchangeRatesToUpsert);
        return exchangeRatesToUpsert;
    }

    
    /**
     * @description Combines getting and processing rates into a single operation
     * @return List<Exchange_Rate__c> The list of records created or updated
     */
    public static List<Exchange_Rate__c> updateExchangeRates() {
        // TODO: Implement the method to get and process rates
        // 1. Call getLatestRates to retrieve the data
        ExchangeRateWrapper rateData = getLatestRates();
        // 2. Call processRates to create/update records
        List<Exchange_Rate__c> exchangeRates = processRates(rateData);
        // 3. Return the processed records
        return exchangeRates; // Replace with actual implementation
    }
    }


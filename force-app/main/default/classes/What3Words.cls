/**
 * @description Classe Apex pour l'intégration avec l'API what3words
 * @author Assistant AI
 * @version 1.0
 */
public with sharing class What3Words {
    
    // Configuration de l'API
    private static final String API_KEY = 'ISDZLT5G';
    private static final String API_ENDPOINT_CONVERT_TO_3WA = 'https://api.what3words.com/v3/convert-to-3wa';
    private static final String API_ENDPOINT_AUTOSUGGEST = 'https://api.what3words.com/v3/autosuggest';
    private static final Integer TIMEOUT_MS = 10000; // 10 secondes
    
    /**
     * @description Retourne des suggestions what3words à partir d'une saisie utilisateur
     * @param input Chaîne tapée par l'utilisateur (ex: "filled.count.so")
     * @param clipToCountry Code pays ISO2 optionnel pour filtrer (ex: "FR")
     * @return Liste de suggestions autosuggest
     */
    @AuraEnabled(cacheable=true)
    public static List<AutoSuggestItem> getAutoSuggest(String input, String clipToCountry) {
        try {
            // Validation
            if (String.isBlank(input)) {
                throw new What3WordsException('Le paramètre input est requis');
            }
            
            // Construction de l'URL
            String url = API_ENDPOINT_AUTOSUGGEST +
                         '?key=' + API_KEY +
                         '&input=' + EncodingUtil.urlEncode(input, 'UTF-8') +
                         '&n-results=7';
            
            if (!String.isBlank(clipToCountry)) {
                url += '&clip-to-country=' + EncodingUtil.urlEncode(clipToCountry, 'UTF-8');
            }
            
            // Requête HTTP
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            request.setTimeout(TIMEOUT_MS);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('Accept', 'application/json');
            
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                return parseAutosuggestResponse(response.getBody());
            } else {
                throw new What3WordsException('Erreur API autosuggest: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
        } catch (What3WordsException e) {
            throw e;
        } catch (Exception e) {
            throw new What3WordsException('Erreur lors de l\'appel à l\'API autosuggest: ' + e.getMessage());
        }
    }

    /**
     * @description Convertit des coordonnées GPS en adresse what3words pour la carte interactive
     * @param latitude Latitude en degrés décimaux
     * @param longitude Longitude en degrés décimaux
     * @return String Les 3 mots what3words
     */
    @AuraEnabled(cacheable=false)
    public static String getWhat3WordsFromCoords(Double latitude, Double longitude) {
        try {
            // Validation des paramètres
            if (latitude == null || longitude == null) {
                throw new What3WordsException('Les coordonnées latitude et longitude sont requises');
            }
            
            if (latitude < -90 || latitude > 90) {
                throw new What3WordsException('La latitude doit être comprise entre -90 et 90 degrés');
            }
            
            if (longitude < -180 || longitude > 180) {
                throw new What3WordsException('La longitude doit être comprise entre -180 et 180 degrés');
            }
            
            // Construction de l'URL de l'API
            String url = API_ENDPOINT_CONVERT_TO_3WA + 
                        '?key=' + API_KEY + 
                        '&coordinates=' + latitude + ',' + longitude +
                        '&format=json';
            
            // Configuration de la requête HTTP
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            request.setTimeout(TIMEOUT_MS);
            request.setHeader('Content-Type', 'application/json');
            
            // Exécution de la requête
            HttpResponse response = http.send(request);
            
            // Traitement de la réponse
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                if (responseMap.containsKey('words')) {
                    return (String) responseMap.get('words');
                }
                return 'Adresse non trouvée';
            } else {
                throw new What3WordsException('Erreur API: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
            
        } catch (What3WordsException e) {
            throw e;
        } catch (Exception e) {
            throw new What3WordsException('Erreur lors de l\'appel à l\'API what3words: ' + e.getMessage());
        }
    }

    /**
     * @description Convertit des coordonnées GPS en adresse what3words
     * @param latitude Latitude en degrés décimaux
     * @param longitude Longitude en degrés décimaux
     * @return What3WordsResponse Réponse de l'API contenant l'adresse
     */
    @AuraEnabled(cacheable=true)
    public static What3WordsResponse getWhat3WordsAddress(Double latitude, Double longitude) {
        try {
            // Validation des paramètres
            if (latitude == null || longitude == null) {
                throw new What3WordsException('Les coordonnées latitude et longitude sont requises');
            }
            
            if (latitude < -90 || latitude > 90) {
                throw new What3WordsException('La latitude doit être comprise entre -90 et 90 degrés');
            }
            
            if (longitude < -180 || longitude > 180) {
                throw new What3WordsException('La longitude doit être comprise entre -180 et 180 degrés');
            }
            
            // Construction de l'URL de l'API
            String url = API_ENDPOINT_CONVERT_TO_3WA + 
                        '?key=' + API_KEY + 
                        '&coordinates=' + latitude + ',' + longitude +
                        '&format=json';
            
            // Configuration de la requête HTTP
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(url);
            request.setMethod('GET');
            request.setTimeout(TIMEOUT_MS);
            request.setHeader('Content-Type', 'application/json');
            
            // Exécution de la requête
            HttpResponse response = http.send(request);
            
            // Traitement de la réponse
            if (response.getStatusCode() == 200) {
                String responseBody = response.getBody();
                return parseResponse(responseBody);
            } else {
                throw new What3WordsException('Erreur API: ' + response.getStatusCode() + ' - ' + response.getStatus());
            }
            
        } catch (What3WordsException e) {
            throw e;
        } catch (Exception e) {
            throw new What3WordsException('Erreur lors de l\'appel à l\'API what3words: ' + e.getMessage());
        }
    }
    
    /**
     * @description Parse la réponse JSON autosuggest en liste d'objets AutoSuggestItem
     */
    private static List<AutoSuggestItem> parseAutosuggestResponse(String responseBody) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            List<AutoSuggestItem> results = new List<AutoSuggestItem>();
            if (responseMap == null) {
                return results;
            }
            if (responseMap.containsKey('suggestions')) {
                List<Object> suggestions = (List<Object>) responseMap.get('suggestions');
                for (Object sObj : suggestions) {
                    Map<String, Object> s = (Map<String, Object>) sObj;
                    AutoSuggestItem item = new AutoSuggestItem();
                    if (s.containsKey('words')) item.words = (String) s.get('words');
                    if (s.containsKey('country')) item.country = (String) s.get('country');
                    if (s.containsKey('nearestPlace')) item.nearestPlace = (String) s.get('nearestPlace');
                    if (s.containsKey('rank')) item.rank = ((s.get('rank') == null) ? null : Integer.valueOf(String.valueOf(s.get('rank'))));
                    if (s.containsKey('language')) item.language = (String) s.get('language');
                    if (s.containsKey('distanceToFocusKm')) item.distanceToFocusKm = ((s.get('distanceToFocusKm') == null) ? null : Decimal.valueOf(String.valueOf(s.get('distanceToFocusKm'))));
                    results.add(item);
                }
            }
            return results;
        } catch (Exception e) {
            throw new What3WordsException('Erreur lors du parsing de la réponse autosuggest: ' + e.getMessage());
        }
    }

    /**
     * @description Parse la réponse JSON de l'API
     * @param responseBody Corps de la réponse JSON
     * @return What3WordsResponse Objet parsé
     */
    private static What3WordsResponse parseResponse(String responseBody) {
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            
            What3WordsResponse result = new What3WordsResponse();
            
            // Extraction des données principales
            if (responseMap.containsKey('words')) {
                result.words = (String) responseMap.get('words');
            }
            
            if (responseMap.containsKey('country')) {
                result.country = (String) responseMap.get('country');
            }
            
            if (responseMap.containsKey('square')) {
                Map<String, Object> squareMap = (Map<String, Object>) responseMap.get('square');
                if (squareMap != null && squareMap.containsKey('coordinates')) {
                    List<Object> coords = (List<Object>) squareMap.get('coordinates');
                    if (coords.size() >= 2) {
                        result.squareLat = (Double) coords[0];
                        result.squareLng = (Double) coords[1];
                    }
                }
            }
            
            if (responseMap.containsKey('language')) {
                result.language = (String) responseMap.get('language');
            }
            
            if (responseMap.containsKey('locale')) {
                result.locale = (String) responseMap.get('locale');
            }
            
            return result;
            
        } catch (Exception e) {
            throw new What3WordsException('Erreur lors du parsing de la réponse: ' + e.getMessage());
        }
    }
    
    /**
     * @description Classe de réponse pour l'API what3words
     */
    public class What3WordsResponse {
        @AuraEnabled public String words;
        @AuraEnabled public String country;
        @AuraEnabled public Double squareLat;
        @AuraEnabled public Double squareLng;
        @AuraEnabled public String language;
        @AuraEnabled public String locale;
        
        public What3WordsResponse() {
            this.words = '';
            this.country = '';
            this.language = '';
            this.locale = '';
        }
    }
    
    /**
     * @description Élément de suggestion pour autosuggest
     */
    public class AutoSuggestItem {
        @AuraEnabled public String words;
        @AuraEnabled public String country;
        @AuraEnabled public String nearestPlace;
        @AuraEnabled public Integer rank;
        @AuraEnabled public String language;
        @AuraEnabled public Decimal distanceToFocusKm;
    }
    
    /**
     * @description Exception personnalisée pour les erreurs what3words
     */
    public class What3WordsException extends Exception {}
}

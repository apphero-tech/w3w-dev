/**
 * @description Classe de test pour la classe What3Words
 * @author Assistant AI
 * @version 1.0
 */
@isTest
private class What3WordsTest {
    
    /**
     * @description Test de la méthode getWhat3WordsAddress avec des coordonnées valides
     */
    @isTest
    static void testGetWhat3WordsAddressValid() {
        // Arrange
        Double latitude = 48.8584; // Paris
        Double longitude = 2.2945;
        
        // Mock de la réponse HTTP
        Test.setMock(HttpCalloutMock.class, new What3WordsMock());
        
        // Act
        Test.startTest();
        What3Words.What3WordsResponse result = What3Words.getWhat3WordsAddress(latitude, longitude);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'La réponse ne doit pas être null');
        System.assertEquals('filled.count.soap', result.words, 'Les mots what3words doivent correspondre');
        System.assertEquals('FR', result.country, 'Le pays doit être FR');
        System.assertEquals('en', result.language, 'La langue doit être en');
    }
    
    /**
     * @description Test avec des coordonnées invalides (latitude hors limites)
     */
    @isTest
    static void testGetWhat3WordsAddressInvalidLatitude() {
        // Arrange
        Double latitude = 100.0; // Latitude invalide
        Double longitude = 2.2945;
        
        // Act & Assert
        try {
            What3Words.getWhat3WordsAddress(latitude, longitude);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (What3Words.What3WordsException e) {
            System.assert(e.getMessage().contains('latitude'), 'Le message d\'erreur doit mentionner la latitude');
        }
    }
    
    /**
     * @description Test avec des coordonnées invalides (longitude hors limites)
     */
    @isTest
    static void testGetWhat3WordsAddressInvalidLongitude() {
        // Arrange
        Double latitude = 48.8584;
        Double longitude = 200.0; // Longitude invalide
        
        // Act & Assert
        try {
            What3Words.getWhat3WordsAddress(latitude, longitude);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (What3Words.What3WordsException e) {
            System.assert(e.getMessage().contains('longitude'), 'Le message d\'erreur doit mentionner la longitude');
        }
    }
    
    /**
     * @description Test avec des coordonnées null
     */
    @isTest
    static void testGetWhat3WordsAddressNullCoordinates() {
        // Arrange
        Double latitude = null;
        Double longitude = null;
        
        // Act & Assert
        try {
            What3Words.getWhat3WordsAddress(latitude, longitude);
            System.assert(false, 'Une exception aurait dû être levée');
        } catch (What3Words.What3WordsException e) {
            System.assert(e.getMessage().contains('requises'), 'Le message d\'erreur doit indiquer que les coordonnées sont requises');
        }
    }
    
    /**
     * @description Test avec des coordonnées aux limites
     */
    @isTest
    static void testGetWhat3WordsAddressBoundaryValues() {
        // Arrange - Coordonnées aux limites valides
        Double latitude = 90.0;
        Double longitude = 180.0;
        
        // Mock de la réponse HTTP
        Test.setMock(HttpCalloutMock.class, new What3WordsMock());
        
        // Act
        Test.startTest();
        What3Words.What3WordsResponse result = What3Words.getWhat3WordsAddress(latitude, longitude);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'La réponse ne doit pas être null avec des coordonnées aux limites');
    }
    
    /**
     * @description Test de la classe de réponse What3WordsResponse
     */
    @isTest
    static void testWhat3WordsResponse() {
        // Arrange
        What3Words.What3WordsResponse response = new What3Words.What3WordsResponse();
        
        // Act
        response.words = 'test.words.here';
        response.country = 'US';
        response.language = 'en';
        response.locale = 'en';
        response.squareLat = 40.7128;
        response.squareLng = -74.0060;
        
        // Assert
        System.assertEquals('test.words.here', response.words, 'Les mots doivent être correctement assignés');
        System.assertEquals('US', response.country, 'Le pays doit être correctement assigné');
        System.assertEquals('en', response.language, 'La langue doit être correctement assignée');
        System.assertEquals('en', response.locale, 'La locale doit être correctement assignée');
        System.assertEquals(40.7128, response.squareLat, 'La latitude du carré doit être correctement assignée');
        System.assertEquals(-74.0060, response.squareLng, 'La longitude du carré doit être correctement assignée');
    }
    
    /**
     * @description Test de la méthode getAutoSuggest avec une saisie partielle
     */
    @isTest
    static void testGetAutoSuggestValid() {
        // Arrange
        String input = 'filled.count.so';
        String country = 'FR';
        
        // Mock autosuggest
        Test.setMock(HttpCalloutMock.class, new What3WordsAutosuggestMock());
        
        // Act
        Test.startTest();
        List<What3Words.AutoSuggestItem> results = What3Words.getAutoSuggest(input, country);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, results, 'Les résultats ne doivent pas être null');
        System.assert(results.size() > 0, 'Il doit y avoir au moins une suggestion');
        System.assertEquals('filled.count.soap', results[0].words, 'Première suggestion attendue');
        System.assertEquals('FR', results[0].country, 'Le pays doit être FR');
        System.assertEquals(1, results[0].rank, 'Le rang doit être 1');
        System.assertEquals('Paris', results[0].nearestPlace, 'Le lieu proche doit être Paris');
    }

    /**
     * @description Test de la validation d'entrée vide pour getAutoSuggest
     */
    @isTest
    static void testGetAutoSuggestInvalidInput() {
        try {
            What3Words.getAutoSuggest('', 'FR');
            System.assert(false, 'Une exception aurait dû être levée pour input vide');
        } catch (What3Words.What3WordsException e) {
            System.assert(e.getMessage().contains('input'), 'Le message doit mentionner input');
        }
    }

    /**
     * @description Mock HTTP pour les tests
     */
    private class What3WordsMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            // Vérifier que l'URL contient les paramètres attendus
            System.assert(request.getEndpoint().contains('api.what3words.com'), 'L\'endpoint doit être correct');
            System.assert(request.getEndpoint().contains('ISDZLT5G'), 'La clé API doit être présente');
            System.assert(request.getMethod() == 'GET', 'La méthode doit être GET');
            
            // Créer une réponse mock
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            
            // Réponse JSON simulée
            String responseBody = '{"words":"filled.count.soap","country":"FR","square":{"coordinates":[48.8584,2.2945]},"language":"en","locale":"en"}';
            response.setBody(responseBody);
            
            return response;
        }
    }

    /**
     * @description Mock HTTP pour autosuggest
     */
    private class What3WordsAutosuggestMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            System.assert(request.getEndpoint().contains('autosuggest'), 'Doit appeler l\'endpoint autosuggest');
            System.assert(request.getMethod() == 'GET', 'La méthode doit être GET');
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            String responseBody = '{"suggestions": [{"words": "filled.count.soap", "country": "FR", "nearestPlace": "Paris", "rank": 1, "language": "fr", "distanceToFocusKm": 0.2}, {"words": "filled.count.soon", "country": "FR", "nearestPlace": "Paris", "rank": 2, "language": "fr", "distanceToFocusKm": 0.3}]}';
            response.setBody(responseBody);
            return response;
        }
    }
}

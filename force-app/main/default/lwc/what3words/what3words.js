import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import getWhat3WordsFromCoords from '@salesforce/apex/What3Words.getWhat3WordsFromCoords';
import LEAFLET_JS from '@salesforce/resourceUrl/leafletJS';
import LEAFLET_CSS from '@salesforce/resourceUrl/leafletCSS';

export default class What3words extends LightningElement {
    @track currentWords = '';
    @track currentLat = '';
    @track currentLng = '';
    @track isLoading = false;

    map;
    debounceTimer;
    leafletLoaded = false;

    connectedCallback() {
        this.loadLeafletResources();
    }

    disconnectedCallback() {
        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }
        if (this.map) {
            this.map.remove();
        }
    }

    async loadLeafletResources() {
        try {
            // Charger Leaflet CSS et JS depuis les Static Resources
            await Promise.all([
                loadStyle(this, LEAFLET_CSS),
                loadScript(this, LEAFLET_JS)
            ]);
            
            this.leafletLoaded = true;
            this.initializeMap();
        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('Erreur lors du chargement de Leaflet:', error);
        }
    }

    initializeMap() {
        const mapContainer = this.template.querySelector('.map-container');
        if (!mapContainer || !this.leafletLoaded) return;

        // Créer un div pour la carte
        const mapDiv = document.createElement('div');
        mapDiv.id = 'leaflet-map';
        mapDiv.style.height = '400px';
        mapDiv.style.width = '100%';
        mapContainer.appendChild(mapDiv);

        // Initialiser la carte Leaflet
        this.map = L.map('leaflet-map').setView([48.8584, 2.2945], 13); // Paris par défaut

        // Debug logging pour le chargement des tuiles
        // eslint-disable-next-line no-console
        console.log('Initialisation de la carte Leaflet');

        // Essayer d'abord OpenStreetMap avec gestion d'erreur
        this.loadTileLayer();

        // Event listeners pour la carte
        this.map.on('mousemove', (e) => {
            this.handleMapMouseMove(e);
        });

        this.map.on('click', (e) => {
            this.handleMapClick(e);
        });
    }

    loadTileLayer() {
        // Essayer OpenStreetMap en premier
        // eslint-disable-next-line no-console
        console.log('Tentative de chargement des tuiles OpenStreetMap...');
        
        const osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            attribution: '© OpenStreetMap contributors',
            maxZoom: 19,
            subdomains: ['a', 'b', 'c']
        });

        // Ajouter des event listeners pour debug
        osmLayer.on('loading', () => {
            // eslint-disable-next-line no-console
            console.log('Chargement des tuiles OpenStreetMap en cours...');
        });

        osmLayer.on('load', () => {
            // eslint-disable-next-line no-console
            console.log('Tuiles OpenStreetMap chargées avec succès');
        });

        osmLayer.on('tileerror', (error) => {
            // eslint-disable-next-line no-console
            console.error('Erreur de chargement des tuiles OpenStreetMap:', error);
            // eslint-disable-next-line no-console
            console.log('Vérifiez les Remote Site Settings pour OpenStreetMap');
        });

        osmLayer.addTo(this.map);
    }

    handleMapMouseMove(e) {
        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }

        this.debounceTimer = setTimeout(() => {
            const lat = e.latlng.lat.toFixed(6);
            const lng = e.latlng.lng.toFixed(6);
            this.currentLat = lat;
            this.currentLng = lng;
            this.fetchWhat3Words(parseFloat(lat), parseFloat(lng));
        }, 500);
    }

    handleMapClick(e) {
        if (this.currentWords) {
            const url = `https://w3w.co/${this.currentWords}`;
            window.open(url, '_blank');
        }
    }

    async fetchWhat3Words(lat, lng) {
        try {
            this.isLoading = true;
            const words = await getWhat3WordsFromCoords({ latitude: lat, longitude: lng });
            this.currentWords = words || 'Adresse non trouvée';
        } catch (error) {
            // eslint-disable-next-line no-console
            console.error('Erreur what3words:', error);
            this.currentWords = 'Erreur de récupération';
        } finally {
            this.isLoading = false;
        }
    }
}
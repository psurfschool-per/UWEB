// Service Worker for UWEB
// Provides caching and offline functionality

const CACHE_NAME = 'uweb-v1.0.0';
const STATIC_CACHE_NAME = 'uweb-static-v1.0.0';
const DYNAMIC_CACHE_NAME = 'uweb-dynamic-v1.0.0';

// Files to cache immediately
const STATIC_FILES = [
    '/',
    '/index.html',
    '/servicios.html',
    '/portafolio.html',
    '/precios.html',
    '/contacto.html',
    '/styles.css',
    '/script.js',
    '/assets/images/og-image.jpg',
    '/manifest.json'
];

// Files to cache dynamically
const DYNAMIC_FILES = [
    '/assets/images/',
    '/assets/data/',
    '/politicas/'
];

// Install event - cache static files
self.addEventListener('install', event => {
    console.log('Service Worker: Installing...');
    
    event.waitUntil(
        caches.open(STATIC_CACHE_NAME)
            .then(cache => {
                console.log('Service Worker: Caching static files');
                return cache.addAll(STATIC_FILES);
            })
            .then(() => {
                console.log('Service Worker: Static files cached');
                return self.skipWaiting();
            })
            .catch(error => {
                console.error('Service Worker: Error caching static files', error);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
    console.log('Service Worker: Activating...');
    
    event.waitUntil(
        caches.keys()
            .then(cacheNames => {
                return Promise.all(
                    cacheNames.map(cacheName => {
                        if (cacheName !== STATIC_CACHE_NAME && cacheName !== DYNAMIC_CACHE_NAME) {
                            console.log('Service Worker: Deleting old cache', cacheName);
                            return caches.delete(cacheName);
                        }
                    })
                );
            })
            .then(() => {
                console.log('Service Worker: Activated');
                return self.clients.claim();
            })
    );
});

// Fetch event - serve cached files or fetch from network
self.addEventListener('fetch', event => {
    const { request } = event;
    const url = new URL(request.url);
    
    // Skip non-GET requests
    if (request.method !== 'GET') {
        return;
    }
    
    // Skip external requests
    if (url.origin !== location.origin) {
        return;
    }
    
    event.respondWith(
        caches.match(request)
            .then(cachedResponse => {
                if (cachedResponse) {
                    console.log('Service Worker: Serving from cache', request.url);
                    return cachedResponse;
                }
                
                // Not in cache, fetch from network
                return fetch(request)
                    .then(networkResponse => {
                        // Check if we should cache this response
                        if (shouldCache(request.url)) {
                            const responseClone = networkResponse.clone();
                            
                            caches.open(DYNAMIC_CACHE_NAME)
                                .then(cache => {
                                    cache.put(request, responseClone);
                                    console.log('Service Worker: Cached new resource', request.url);
                                });
                        }
                        
                        return networkResponse;
                    })
                    .catch(error => {
                        console.error('Service Worker: Fetch failed', error);
                        
                        // Return offline page for HTML requests
                        if (request.headers.get('accept').includes('text/html')) {
                            return caches.match('/offline.html');
                        }
                        
                        // Return placeholder for images
                        if (request.headers.get('accept').includes('image/')) {
                            return new Response(
                                '<svg width="400" height="300" xmlns="http://www.w3.org/2000/svg"><rect width="100%" height="100%" fill="#f0f0f0"/><text x="50%" y="50%" text-anchor="middle" dy=".3em" fill="#999">Imagen no disponible</text></svg>',
                                { headers: { 'Content-Type': 'image/svg+xml' } }
                            );
                        }
                        
                        throw error;
                    });
            })
    );
});

// Helper function to determine if a resource should be cached
function shouldCache(url) {
    // Cache images, CSS, JS, and HTML files
    return url.includes('/assets/') || 
           url.endsWith('.css') || 
           url.endsWith('.js') || 
           url.endsWith('.html') ||
           url.includes('/politicas/');
}

// Background sync for form submissions
self.addEventListener('sync', event => {
    if (event.tag === 'contact-form-sync') {
        event.waitUntil(
            // Handle offline form submissions
            handleOfflineFormSubmission()
        );
    }
});

// Handle offline form submissions
async function handleOfflineFormSubmission() {
    try {
        // Get stored form data from IndexedDB
        const formData = await getStoredFormData();
        
        if (formData) {
            // Try to submit the form
            const response = await fetch('/submit-contact', {
                method: 'POST',
                body: formData
            });
            
            if (response.ok) {
                // Clear stored data on successful submission
                await clearStoredFormData();
                console.log('Service Worker: Offline form submitted successfully');
            }
        }
    } catch (error) {
        console.error('Service Worker: Error submitting offline form', error);
    }
}

// Placeholder functions for IndexedDB operations
async function getStoredFormData() {
    // Implementation would use IndexedDB to retrieve stored form data
    return null;
}

async function clearStoredFormData() {
    // Implementation would clear stored form data from IndexedDB
}

// Push notification handling (for future use)
self.addEventListener('push', event => {
    if (event.data) {
        const data = event.data.json();
        
        const options = {
            body: data.body,
            icon: '/assets/images/icon-192x192.png',
            badge: '/assets/images/badge-72x72.png',
            vibrate: [200, 100, 200],
            data: {
                url: data.url || '/'
            }
        };
        
        event.waitUntil(
            self.registration.showNotification(data.title, options)
        );
    }
});

// Handle notification clicks
self.addEventListener('notificationclick', event => {
    event.notification.close();
    
    event.waitUntil(
        clients.openWindow(event.notification.data.url || '/')
    );
});

console.log('Service Worker: Loaded');
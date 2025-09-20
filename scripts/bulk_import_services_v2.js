// Bulk import services to Firestore
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin SDK with service account
initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

// Get list of categories first to validate sub-services
async function getCategories() {
  const snapshot = await db.collection('serviceCategories').get();
  const categories = new Map();
  
  snapshot.forEach(doc => {
    const data = doc.data();
    categories.set(doc.id, {
      id: doc.id,
      name: data.name,
      subCategories: data.subCategories || []
    });
  });
  
  return categories;
}

// Validate that the service belongs to a valid category and sub-service
function validateService(service, categories) {
  const category = categories.get(service.categoryId);
  if (!category) {
    throw new Error(`Invalid category ID: ${service.categoryId}`);
  }
  
  if (service.subService && !category.subCategories.includes(service.subService)) {
    throw new Error(
      `Invalid sub-service "${service.subService}" for category ${category.name}`,
    );
  }
  
  return true;
}

const services = [
  {
    name: 'Standard Home Cleaning (Small)',
    description: 'Professional cleaning service for 1-2 bedroom homes. Includes dusting, mopping, bathroom cleaning, and kitchen sanitization.',
    price: 2000,
    priceMax: 4000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Standard Home Cleaning',
    image: 'https://example.com/cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Trained & vetted cleaners',
      'All cleaning supplies included',
      'Eco-friendly options available',
      'Flexible scheduling'
    ],
    providerId: 'provider1',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    propertySize: 'small',
  },
  {
    name: 'Deep Home Cleaning Service',
    description: 'Thorough deep cleaning including hard-to-reach areas, appliances, and detailed sanitization.',
    price: 4000,
    priceMax: 6800,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Deep Cleaning',
    image: 'https://example.com/deep-cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Deep furniture cleaning',
      'Window washing included',
      'Appliance cleaning',
      'Cabinet organization',
      'Intensive bathroom sanitation'
    ],
    providerId: 'provider2',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Move-in/Move-out Cleaning',
    description: 'Comprehensive cleaning service for moving in or out of a property.',
    price: 5000,
    priceMax: 8000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Move-in/Move-out Cleaning',
    image: 'https://example.com/move-cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Deep cleaning',
      'Cabinet and drawer cleaning',
      'Appliance cleaning',
      'Window cleaning',
      'Move-related cleaning'
    ],
    providerId: 'provider3',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Emergency Plumbing Service',
    description: 'Fast response plumbing service for urgent issues like leaks, blockages, and emergencies.',
    price: 1500,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Emergency Plumbing',
    image: 'https://example.com/emergency-plumbing.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      '24/7 emergency response',
      'Licensed plumbers',
      'Quick issue diagnosis',
      'Common parts in stock',
      'Warranty on repairs'
    ],
    providerId: 'provider4',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Water Heater Installation',
    description: 'Installation and maintenance of water heaters, including solar and electric systems.',
    price: 10000,
    priceMax: 25000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Water Heater Installation & Maintenance',
    image: 'https://example.com/water-heater.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'New installation',
      'System replacement',
      'Maintenance service',
      'Quality equipment',
      'Extended warranty available'
    ],
    providerId: 'provider5',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Light Fixture Installation',
    description: 'Professional installation of light fixtures and electrical points.',
    price: 2000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'electrical',
    categoryName: 'Electrical Services',
    subService: 'Light Fixture Installation',
    image: 'https://example.com/electrical.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Licensed electricians',
      'Safety certified',
      'Modern equipment',
      'Warranty on work'
    ],
    providerId: 'provider6',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Circuit Breaker Installation',
    description: 'Professional installation and maintenance of circuit breakers.',
    price: 4000,
    priceMax: 8000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'electrical',
    categoryName: 'Electrical Services',
    subService: 'Circuit Breaker Installation',
    image: 'https://example.com/circuit-breaker.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Licensed electricians',
      'Safety certified',
      'Quality equipment',
      'Warranty service'
    ],
    providerId: 'provider7',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
];

async function importServices() {
  console.log('Fetching categories...');
  const categories = await getCategories();
  console.log(`Found ${categories.size} categories`);
  
  let importCount = 0;
  let errorCount = 0;
  
  for (const service of services) {
    try {
      validateService(service, categories);
      
      // Add additional service metadata
      const enrichedService = {
        ...service,
        createdAt: new Date(),
        updatedAt: new Date(),
        // Ensure proper linking to category
        categoryRef: db.collection('serviceCategories').doc(service.categoryId)
      };

      const docRef = await db.collection('services').add(enrichedService);
      console.log(`✅ Imported service: ${service.name} (ID: ${docRef.id})`);
      importCount++;
      
    } catch (err) {
      console.error(`❌ Error importing ${service.name}:`, err.message);
      errorCount++;
    }
  }

  console.log('\nImport Summary:');
  console.log(`✅ Successfully imported: ${importCount} services`);
  console.log(`❌ Failed to import: ${errorCount} services`);
}

// Run the import
importServices()
  .then(() => console.log('Import process complete'))
  .catch(err => console.error('Fatal error:', err));
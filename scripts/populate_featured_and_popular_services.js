// Script to populate Firestore with featured and popular services
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin SDK
initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

// Sample featured services data
const featuredServices = [
  {
    name: 'Standard Home Cleaning (Small)',
    description: 'Professional cleaning service for 1-2 bedroom homes. Includes dusting, mopping, bathroom cleaning, and kitchen sanitization.',
    price: 2000,
    priceMax: 4000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Regular Home Cleaning',
    image: 'https://example.com/cleaning.jpg',
    isFeatured: true,
    isPopular: false,
    bookingCount: 1250,
    reviewCount: 245,
    rating: 4.8,
    images: [],
    features: [
      'Trained & vetted cleaners',
      'All cleaning supplies included',
      'Eco-friendly options available',
      'Flexible scheduling'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-1'
  },
  {
    name: 'Deep Cleaning Service',
    description: 'Thorough deep cleaning including hard-to-reach areas, appliances, and detailed sanitization.',
    price: 3000,
    priceMax: 6800,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Deep Cleaning',
    image: 'https://example.com/deep-cleaning.jpg',
    isFeatured: true,
    isPopular: false,
    bookingCount: 890,
    reviewCount: 180,
    rating: 4.7,
    images: [],
    features: [
      'Deep furniture cleaning',
      'Window washing included',
      'Appliance cleaning',
      'Cabinet organization',
      'Intensive bathroom sanitation',
      'Behind/under furniture cleaning'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-2'
  },
  {
    name: 'Home Salon Service',
    description: 'Professional beauty services in the comfort of your home.',
    price: 1500,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'beauty-personal-care',
    categoryName: 'Beauty & Personal Care',
    subService: 'Hair Styling',
    image: 'https://example.com/home-salon.jpg',
    isFeatured: true,
    isPopular: false,
    bookingCount: 500,
    reviewCount: 120,
    rating: 4.6,
    images: [],
    features: [
      'Professional stylists',
      'Wide range of beauty services',
      'Home convenience',
      'Premium products used'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-3'
  }
];

// Sample popular services data
const popularServices = [
  {
    name: 'Carpet Cleaning Service',
    description: 'Professional carpet cleaning using advanced methods and safe products.',
    price: 1000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'per_unit',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Carpet & Upholstery Cleaning',
    image: 'https://via.placeholder.com/300x200?text=Carpet+Cleaning',
    isFeatured: false,
    isPopular: true,
    bookingCount: 720,
    reviewCount: 156,
    rating: 4.6,
    images: [
      'https://via.placeholder.com/300x200?text=Carpet+Cleaning',
      'https://via.placeholder.com/300x200?text=Upholstery+Cleaning'
    ],
    features: [
      'Stain removal',
      'Deep fabric cleaning',
      'Dust mite treatment',
      'Deodorizing',
      'Quick drying process'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-1'
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
    image: 'https://via.placeholder.com/300x200?text=Plumbing+Emergency',
    isFeatured: false,
    isPopular: true,
    bookingCount: 1500,
    reviewCount: 320,
    rating: 4.9,
    images: [
      'https://via.placeholder.com/300x200?text=Plumbing+Emergency',
      'https://via.placeholder.com/300x200?text=Pipe+Repair'
    ],
    features: [
      '24/7 emergency response',
      'Licensed plumbers',
      'Quick issue diagnosis',
      'Common parts in stock',
      'Warranty on repairs'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-2'
  },
  {
    name: 'General Handyman Services',
    description: 'Professional handyman for various home repairs and maintenance.',
    price: 2000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'hourly',
    categoryId: 'home-repairs',
    categoryName: 'Home Repairs & Maintenance',
    subService: 'General Handyman',
    image: 'https://via.placeholder.com/300x200?text=Handyman',
    isFeatured: false,
    isPopular: true,
    bookingCount: 800,
    reviewCount: 110,
    rating: 4.5,
    images: [
      'https://via.placeholder.com/300x200?text=Handyman',
      'https://via.placeholder.com/300x200?text=Repairs'
    ],
    features: [
      'General repairs',
      'Furniture assembly',
      'Fixture installation',
      'Minor plumbing',
      'Minor electrical'
    ],
    location: null,
    active: true,
    providerId: 'test-provider-3'
  }
];

async function importServices(services) {
  for (const service of services) {
    try {
      const collectionName = services === featuredServices ? 'featured_services' : 'popular_services';
      const docRef = await db.collection(collectionName).add({
        ...service,
        createdAt: new Date(),
        updatedAt: new Date()
      });
      console.log(`Imported to ${collectionName}: ${service.name} (ID: ${docRef.id})`);
    } catch (err) {
      console.error(`Error importing ${service.name}:`, err);
    }
  }
}

async function main() {
  console.log('Importing featured services...');
  await importServices(featuredServices);
  console.log('Importing popular services...');
  await importServices(popularServices);
  console.log('Featured and popular services import complete.');
}

main();
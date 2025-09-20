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
    throw new Error(`Invalid sub-service "${service.subService}" for category ${category.name}`);
  }
  
  return true;
}

// Comprehensive service data for Nairobi market with proper categorization and pricing
const services = [
  // Cleaning & Housekeeping Services
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
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    propertySize: 'small',
    frequencyOptions: ['one-time', 'weekly', 'bi-weekly', 'monthly'],
  },
  {
    name: 'Standard Home Cleaning (Medium)',
    description: 'Professional cleaning service for 3-4 bedroom homes.',
    price: 4000,
    priceMax: 6000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Regular Home Cleaning',
    image: 'https://example.com/cleaning-medium.jpg',
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
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
    propertySize: 'medium',
    frequencyOptions: ['one-time', 'weekly', 'bi-weekly', 'monthly'],
  },
  {
    name: 'Standard Home Cleaning (Large)',
    description: 'Professional cleaning service for 5+ bedroom homes or luxury residences.',
    price: 6000,
    priceMax: 10000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Regular Home Cleaning',
    image: 'https://example.com/cleaning-large.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Trained & vetted cleaners',
      'All cleaning supplies included',
      'Eco-friendly options available',
      'Flexible scheduling',
      'Multiple cleaners assigned'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
    propertySize: 'large',
    frequencyOptions: ['one-time', 'weekly', 'bi-weekly', 'monthly'],
  },
  {
    name: 'Deep Cleaning Service',
    description: 'Thorough deep cleaning including hard-to-reach areas, appliances, and detailed sanitization. Includes everything in standard cleaning plus extra services.',
    price: 3000,
    priceMax: 6800,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
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
      'Intensive bathroom sanitation',
      'Behind/under furniture cleaning'
    ],
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    propertySize: 'any',
    pricingFactors: ['size', 'condition']
  },
  {
    name: 'Post-Construction Cleaning',
    description: 'Specialized cleaning service for newly constructed or renovated properties. Includes debris removal, paint cleanup, and detailed cleaning.',
    price: 10000,
    priceMax: 25000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Post-Construction Cleaning',
    image: 'https://example.com/post-construction.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Debris removal',
      'Paint removal',
      'Dust removal',
      'Window cleaning',
      'Floor cleaning',
      'Professional equipment'
    ],
    isFeatured: false,
    isPopular: false,
    location: null,
    active: true,
    pricingFactors: ['size', 'debris-amount', 'access']
  },
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
    image: 'https://example.com/carpet-cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Stain removal',
      'Deep fabric cleaning',
      'Dust mite treatment',
      'Deodorizing',
      'Quick drying process'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
    pricingFactors: ['size', 'material', 'stains']
  },
  {
    name: 'Commercial Office Cleaning',
    description: 'Professional cleaning services for offices and commercial spaces.',
    price: 3000,
    priceMax: 7000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning-housekeeping',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Commercial Cleaning',
    image: 'https://example.com/office-cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'After-hours service available',
      'Professional equipment',
      'Trained staff',
      'Regular quality checks',
      'Customizable cleaning plans'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
    contractOptions: ['one-time', 'monthly'],
    pricingFactors: ['square-footage', 'frequency']
  },

  // Plumbing Services
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
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    emergencyResponse: true
  },
  {
    name: 'Drain Unclogging Service',
    description: 'Professional drain cleaning and unclogging service.',
    price: 2000,
    priceMax: 7000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Drain Cleaning',
    image: 'https://example.com/drain-cleaning.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'High-pressure water jetting',
      'CCTV inspection',
      'Root removal',
      'Preventive maintenance'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true
  },
  {
    name: 'Toilet Installation/Repair',
    description: 'Professional toilet installation and repair services.',
    price: 3000,
    priceMax: 7000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Toilet Services',
    image: 'https://example.com/toilet-service.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Quality parts',
      'Professional installation',
      'Warranty service',
      'Complete testing'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true
  },
  {
    name: 'Water Heater Services',
    description: 'Installation and maintenance of water heaters, including solar and electric systems.',
    price: 10000,
    priceMax: 25000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Water Heater',
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
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true
  },

  // Electrical Services
  {
    name: 'General Electrical Service',
    description: 'Licensed electricians for installations and repairs.',
    price: 2000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'hourly',
    categoryId: 'electrical',
    categoryName: 'Electrical Services',
    subService: 'General Electrical',
    image: 'https://example.com/electrical.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Licensed electricians',
      'Safety certified',
      'Emergency service',
      'Modern equipment',
      'Warranty on work'
    ],
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    emergencyResponse: true
  },
  {
    name: 'Generator Installation & Maintenance',
    description: 'Professional generator and inverter installation and maintenance services.',
    price: 5000,
    priceMax: 15000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'electrical',
    categoryName: 'Electrical Services',
    subService: 'Generator Services',
    image: 'https://example.com/generator.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Professional installation',
      'Maintenance plans',
      'Emergency repairs',
      'Quality parts',
      'Warranty service'
    ],
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true
  },

  // Pest Control Services
  {
    name: 'General Pest Control',
    description: 'Comprehensive pest control for common household pests.',
    price: 3000,
    priceMax: 8000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'pest-control',
    categoryName: 'Pest Control',
    subService: 'General Pest Control',
    image: 'https://example.com/pest-control.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Safe treatments',
      'Preventive measures',
      'Follow-up service',
      'Pet-friendly options'
    ],
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
    frequencyOptions: ['one-time', 'quarterly', 'monthly']
  },

  // Moving Services
  {
    name: 'Local Moving Service',
    description: 'Professional moving service for homes and offices within Nairobi.',
    price: 5000,
    priceMax: 15000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'moving',
    categoryName: 'Moving & Transportation',
    subService: 'Local Moving',
    image: 'https://example.com/moving.jpg',
    rating: 0,
    reviewCount: 0,
    bookingCount: 0,
    images: [],
    features: [
      'Professional movers',
      'Packing service',
      'Furniture protection',
      'Insurance available',
      'Same-day service'
    ],
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true
  },
  // Cleaning & Housekeeping
  {
    name: 'Standard Home Cleaning',
    description: 'Professional home cleaning service for 1-2 bedroom homes. Includes dusting, mopping, bathroom cleaning, and kitchen sanitization.',
    price: 2000,
    priceMax: 4000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Regular Home Cleaning',
    image: 'https://example.com/cleaning.jpg',
    rating: 4.8,
    reviewCount: 245,
    bookingCount: 1250,
    images: [],
    features: [
      'Trained & vetted cleaners',
      'Eco-friendly products available',
      'All cleaning supplies included',
      'Flexible scheduling',
      'Satisfaction guaranteed'
    ],
    providerId: 'provider1',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Deep Home Cleaning',
    description: 'Thorough deep cleaning service including hard-to-reach areas, appliances, and detailed sanitization.',
    price: 4000,
    priceMax: 6000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Deep Cleaning',
    image: 'https://example.com/deep-cleaning.jpg',
    rating: 4.7,
    reviewCount: 180,
    bookingCount: 890,
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
    name: 'Carpet & Upholstery Cleaning',
    description: 'Professional carpet and upholstery cleaning using advanced cleaning methods and safe products.',
    price: 1000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'per_unit',
    categoryId: 'cleaning',
    categoryName: 'Cleaning & Housekeeping',
    subService: 'Carpet Cleaning',
    image: 'https://example.com/carpet-cleaning.jpg',
    rating: 4.6,
    reviewCount: 156,
    bookingCount: 720,
    images: [],
    features: [
      'Stain removal',
      'Deep fabric cleaning',
      'Dust mite treatment',
      'Deodorizing',
      'Quick drying process'
    ],
    providerId: 'provider3',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
  // Plumbing Services
  {
    name: 'Emergency Plumbing Service',
    description: 'Fast response plumbing service for urgent issues like leaks, blockages, and plumbing emergencies.',
    price: 1500,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Emergency Plumbing',
    image: 'https://example.com/plumbing.jpg',
    rating: 4.9,
    reviewCount: 320,
    bookingCount: 1500,
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
    description: 'Professional installation and maintenance of water heaters, including solar and electric systems.',
    price: 10000,
    priceMax: 25000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'plumbing',
    categoryName: 'Plumbing & Water Services',
    subService: 'Water Heater Services',
    image: 'https://example.com/water-heater.jpg',
    rating: 4.7,
    reviewCount: 145,
    bookingCount: 450,
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
  // Electrical Services
  {
    name: 'Electrical Repair & Installation',
    description: 'Licensed electricians for all electrical repairs, installations, and maintenance work.',
    price: 2000,
    priceMax: 5000,
    currency: 'KES',
    pricingType: 'hourly',
    categoryId: 'electrical',
    categoryName: 'Electrical Services',
    subService: 'General Electrical',
    image: 'https://example.com/electrical.jpg',
    rating: 4.8,
    reviewCount: 210,
    bookingCount: 980,
    images: [],
    features: [
      'Licensed electricians',
      'Safety certified',
      'Emergency service',
      'Modern equipment',
      'Warranty on work'
    ],
    providerId: 'provider6',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  // Gardening Services
  {
    name: 'Garden Maintenance',
    description: 'Complete garden maintenance including lawn mowing, trimming, and general upkeep.',
    price: 3000,
    priceMax: 7000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'gardening',
    categoryName: 'Gardening & Landscaping',
    subService: 'Regular Maintenance',
    image: 'https://example.com/gardening.jpg',
    rating: 4.6,
    reviewCount: 180,
    bookingCount: 750,
    images: [],
    features: [
      'Lawn mowing',
      'Edge trimming',
      'Weed control',
      'Plant care',
      'Garden cleaning'
    ],
    providerId: 'provider7',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
  // Moving Services
  {
    name: 'Local Moving Service',
    description: 'Professional moving service for homes and offices within Nairobi.',
    price: 5000,
    priceMax: 15000,
    currency: 'KES',
    pricingType: 'fixed',
    categoryId: 'moving',
    categoryName: 'Moving & Transportation',
    subService: 'Local Moving',
    image: 'https://example.com/moving.jpg',
    rating: 4.7,
    reviewCount: 165,
    bookingCount: 620,
    images: [],
    features: [
      'Professional movers',
      'Packing service',
      'Furniture protection',
      'Insurance available',
      'Same-day service'
    ],
    providerId: 'provider8',
    isFeatured: true,
    isPopular: true,
    location: null,
    active: true,
  },
  {
    name: 'Pipe Leak Repair',
    description: 'Fast and reliable repair for any pipe leaks in your home.',
    price: 90,
    priceMax: 120,
    currency: 'KES',
    pricingType: 'hourly',
    categoryId: '2',
    categoryName: 'Plumbing',
    subService: 'Leak Detection',
    image: 'https://img.icons8.com/?size=100&id=12237&format=png&color=000000',
    rating: 4.7,
    reviewCount: 180,
    bookingCount: 900,
    images: [],
    features: ['Certified plumbers', '30-day guarantee'],
    providerId: 'provider2',
    isFeatured: false,
    isPopular: true,
    location: null,
    active: true,
  },
  // Add more services here...
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

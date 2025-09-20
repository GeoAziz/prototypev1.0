// Script to populate service categories in Firebase
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'poafix'
});

const db = admin.firestore();

const serviceCategories = [
  {
    id: 'cleaning',
    name: 'Cleaning & Housekeeping',
    description: 'Professional cleaning services for your home and office',
    icon: 'cleaning_services',
    color: '#4CAF50',
    isFeatured: true,
    isPopular: true,
    subCategories: [
      'Standard Home Cleaning',
      'Deep Cleaning', 
      'Move-in/Move-out Cleaning',
      'Carpet & Rug Cleaning',
      'Window Cleaning',
      'Laundry & Ironing'
    ],
    searchKeywords: ['cleaning', 'housekeeping', 'maid', 'janitor', 'sanitization']
  },
  {
    id: 'plumbing',
    name: 'Plumbing & Water Services', 
    description: 'Expert plumbing solutions for all your water-related needs',
    icon: 'plumbing',
    color: '#2196F3',
    isFeatured: true,
    isPopular: true,
    subCategories: [
      'Leak Detection & Repair',
      'Tap/Sink/Toilet Installation & Repair',
      'Drain Unclogging',
      'Emergency Plumbing',
      'Water Heater Installation & Maintenance'
    ],
    searchKeywords: ['plumbing', 'pipes', 'leak', 'toilet', 'sink', 'water']
  },
  {
    id: 'electrical',
    name: 'Electrical Services',
    description: 'Safe and certified electrical work for your property',
    icon: 'electrical_services',
    color: '#FF9800',
    isFeatured: true,
    isPopular: false,
    subCategories: [
      'Light Fixture Installation',
      'Socket & Switch Repairs',
      'House/Office Rewiring',
      'Emergency Electrical Services'
    ],
    searchKeywords: ['electrical', 'wiring', 'lights', 'switches', 'power']
  },
  {
    id: 'gardening',
    name: 'Gardening & Outdoor Maintenance',
    description: 'Keep your outdoor spaces beautiful and well-maintained',
    icon: 'yard',
    color: '#8BC34A',
    isFeatured: false,
    isPopular: true,
    subCategories: [
      'Lawn Mowing',
      'Tree Trimming & Cutting',
      'Garden Cleanups',
      'Landscaping Design'
    ],
    searchKeywords: ['garden', 'lawn', 'landscaping', 'trees', 'outdoor']
  },
  {
    id: 'beauty',
    name: 'Beauty & Personal Care (At Home)',
    description: 'Professional beauty services in the comfort of your home',
    icon: 'face',
    color: '#E91E63',
    isFeatured: false,
    isPopular: false,
    subCategories: [
      'Haircut & Styling',
      'Braiding & Weaving',
      'Manicure & Pedicure',
      'Massage Therapy'
    ],
    searchKeywords: ['beauty', 'hair', 'nails', 'massage', 'spa']
  }
];

async function populateCategories() {
  console.log('🚀 Starting category population...');
  
  try {
    for (const category of serviceCategories) {
      const { id, ...categoryData } = category;
      
      // Add timestamps
      categoryData.createdAt = admin.firestore.FieldValue.serverTimestamp();
      categoryData.updatedAt = admin.firestore.FieldValue.serverTimestamp();
      
      await db.collection('serviceCategories').doc(id).set(categoryData, { merge: true });
      console.log(`✅ Added/Updated category: ${category.name} (ID: ${id})`);
    }
    
    console.log('\n🎉 Category population completed successfully!');
    console.log(`📊 Total categories: ${serviceCategories.length}`);
    
  } catch (error) {
    console.error('❌ Error populating categories:', error);
  }
}

// Run the population
populateCategories();
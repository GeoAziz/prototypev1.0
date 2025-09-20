// Import additional home services
const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin SDK
initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();


// Define service categories structure
const serviceCategories = [
  {
    id: 'cleaning',
    name: 'Cleaning & Housekeeping',
    subCategories: [
      'Standard Home Cleaning',
      'Deep Cleaning',
      'Move-in/Move-out Cleaning',
      'Carpet & Rug Cleaning',
      'Upholstery/Sofa Cleaning',
      'Post-Construction Cleaning',
      'Window Cleaning',
      'Laundry & Ironing'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day'],
      frequency: ['one-time', 'weekly', 'bi-weekly', 'monthly'],
      duration: {
        'Standard Home Cleaning': '2-3 hours',
        'Deep Cleaning': '4-6 hours',
        'Carpet & Rug Cleaning': '1-2 hours per room'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any', 'male', 'female'],
      toolsProvided: true,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'Liability insurance required',
      equipment: ['Vacuum cleaner', 'Cleaning supplies', 'Safety equipment'],
      certification: 'Professional cleaning certification preferred'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '50% within 24 hours',
      noShow: '100% charge'
    }
  },
  {
    id: 'plumbing',
    name: 'Plumbing & Water Services',
    subCategories: [
      'Leak Detection & Repair',
      'Tap/Sink/Toilet Installation & Repair',
      'Drain Unclogging',
      'Pipe Replacement',
      'Shower & Bathtub Repair',
      'Water Heater Installation & Maintenance',
      'Emergency Plumbing',
      'Exhauster/Septic Services'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day', 'emergency'],
      frequency: ['one-time', 'maintenance-contract'],
      duration: {
        'Leak Repair': '1-2 hours',
        'Installation': '2-4 hours',
        'Emergency Service': '30-60 minutes response'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: false
    },
    requirements: {
      insurance: 'Professional liability insurance required',
      equipment: ['Professional tools', 'Diagnostic equipment', 'Safety gear'],
      certification: 'Licensed plumber required'
    },
    cancellationPolicy: {
      freeCancellation: '12 hours before',
      cancellationFee: '50% within 12 hours',
      noShow: '100% charge',
      emergency: 'No cancellation for emergency calls'
    }
  },
  {
    id: 'electrical',
    name: 'Electrical Services',
    subCategories: [
      'Light Fixture Installation',
      'Socket & Switch Repairs',
      'House/Office Rewiring',
      'Generator & Inverter Setup',
      'Circuit Breaker Installation',
      'Emergency Electrical Services'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day', 'emergency'],
      frequency: ['one-time', 'maintenance-contract'],
      duration: {
        'Light Installation': '1-2 hours',
        'Rewiring': '4-8 hours',
        'Emergency Service': '30-60 minutes response'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: false
    },
    requirements: {
      insurance: 'Professional liability insurance required',
      equipment: ['Professional tools', 'Testing equipment', 'Safety gear'],
      certification: 'Licensed electrician required'
    },
    cancellationPolicy: {
      freeCancellation: '12 hours before',
      cancellationFee: '50% within 12 hours',
      noShow: '100% charge',
      emergency: 'No cancellation for emergency calls'
    }
  },
  {
    id: 'gardening',
    name: 'Gardening & Outdoor Maintenance',
    subCategories: [
      'Lawn Mowing',
      'Tree Trimming & Cutting',
      'Garden Cleanups',
      'Landscaping Design',
      'Flower Bed Maintenance',
      'Fence Repair',
      'Irrigation System Installation'
    ],
    serviceOptions: {
      urgency: ['scheduled'],
      frequency: ['one-time', 'weekly', 'bi-weekly', 'monthly'],
      duration: {
        'Lawn Mowing': '1-2 hours',
        'Tree Service': '2-4 hours',
        'Landscaping': 'Project dependent'
      },
      location: ['Karen', 'Lavington', 'Runda', 'Muthaiga', 'Kitisuru'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'General liability insurance required',
      equipment: ['Professional tools', 'Safety equipment', 'Landscaping tools'],
      certification: 'Professional landscaping experience required'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '30% within 24 hours',
      noShow: '50% charge'
    }
  },
  {
    id: 'beauty',
    name: 'Beauty & Personal Care (At Home)',
    subCategories: [
      'Haircut & Styling',
      'Braiding & Weaving',
      'Manicure & Pedicure',
      'Massage Therapy',
      'Makeup Services',
      'Skincare Treatments',
      'Beard Grooming'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day'],
      frequency: ['one-time', 'weekly', 'monthly'],
      duration: {
        'Haircut': '1-2 hours',
        'Braiding': '2-4 hours',
        'Massage': '1-2 hours',
        'Makeup': '1-2 hours'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['male', 'female'],
      toolsProvided: true,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'Professional liability insurance',
      equipment: ['Professional tools', 'Beauty products', 'Sanitation supplies'],
      certification: 'Cosmetology/Beauty therapy certification required'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '50% within 24 hours',
      noShow: '100% charge'
    }
  },
  {
    id: 'repairs',
    name: 'Home Repairs & Maintenance',
    subCategories: [
      'Painting (Interior & Exterior)',
      'Carpentry (Furnishing, Repairs)',
      'Roofing Repair',
      'Tiling & Flooring',
      'Wall Plastering',
      'Ceiling Repair',
      'General Handyman Services',
      'Door/Window Repair',
      'Locksmith Services'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day', 'emergency'],
      frequency: ['one-time', 'maintenance-contract'],
      duration: {
        'Painting': 'Project dependent',
        'Carpentry': 'Project dependent',
        'General Repairs': '2-4 hours',
        'Emergency': '1 hour response'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'Liability and workers compensation insurance',
      equipment: ['Professional tools', 'Safety equipment', 'Specialized tools'],
      certification: 'Trade certification as applicable'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '30% within 24 hours',
      noShow: '50% charge',
      emergency: 'No cancellation for emergency calls'
    }
  },
  {
    id: 'pest',
    name: 'Pest Control',
    subCategories: [
      'Bedbug Treatment',
      'Cockroach/Fly/Rodent Control',
      'Fumigation Services',
      'Termite Treatment',
      'Mosquito Control',
      'Snake & Wildlife Removal'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'emergency'],
      frequency: ['one-time', 'quarterly', 'annual'],
      duration: {
        'General Treatment': '2-3 hours',
        'Fumigation': '4-6 hours',
        'Emergency': '1 hour response'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'Pest control liability insurance',
      equipment: ['Professional equipment', 'Safety gear', 'EPA-approved chemicals'],
      certification: 'Pest control certification required'
    },
    cancellationPolicy: {
      freeCancellation: '48 hours before',
      cancellationFee: '50% within 48 hours',
      noShow: '100% charge'
    }
  },
  {
    id: 'moving',
    name: 'Moving, Hauling & Delivery',
    subCategories: [
      'Local Household Moving',
      'Office Relocation',
      'Furniture Disassembly/Assembly',
      'Packing Services',
      'Event Setup & Takedown',
      'Trash/Rubbish Removal',
      'Same-day Delivery Services'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day'],
      frequency: ['one-time'],
      duration: {
        'Local Moving': '4-8 hours',
        'Office Moving': 'Project dependent',
        'Delivery': '1-3 hours'
      },
      location: ['All Nairobi areas'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: false
    },
    requirements: {
      insurance: 'Moving and cargo insurance required',
      equipment: ['Moving truck', 'Moving equipment', 'Packing materials'],
      certification: 'Valid commercial driving license'
    },
    cancellationPolicy: {
      freeCancellation: '48 hours before',
      cancellationFee: '30% within 48 hours',
      noShow: '50% charge'
    }
  },
  {
    id: 'tech',
    name: 'Appliance & Tech Services',
    subCategories: [
      'TV Wall Mounting',
      'AC Installation & Repair',
      'Fridge & Freezer Repair',
      'Washing Machine Servicing',
      'Microwave & Oven Repairs',
      'Phone, Tablet, Laptop Repair',
      'CCTV Installation'
    ],
    serviceOptions: {
      urgency: ['scheduled', 'same-day'],
      frequency: ['one-time', 'maintenance-contract'],
      duration: {
        'TV Mounting': '1-2 hours',
        'AC Service': '2-3 hours',
        'Appliance Repair': '1-3 hours'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['any'],
      toolsProvided: true,
      ecoFriendly: false
    },
    requirements: {
      insurance: 'Professional liability insurance',
      equipment: ['Professional tools', 'Diagnostic equipment', 'Spare parts'],
      certification: 'Appliance repair certification required'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '30% within 24 hours',
      noShow: '50% charge'
    }
  },
  {
    id: 'tutoring',
    name: 'Tutoring & Home Lessons',
    subCategories: [
      'Academic Tutoring (Primary/Secondary)',
      'Adult Education',
      'Language Lessons (French, Swahili, English)',
      'Music Lessons (Piano, Guitar, etc.)',
      'Coding for Kids/Teens',
      'Vocational Training (Sewing, Cooking, etc.)'
    ],
    serviceOptions: {
      urgency: ['scheduled'],
      frequency: ['one-time', 'weekly', 'monthly'],
      duration: {
        'Academic Tutoring': '1-2 hours',
        'Music Lessons': '1 hour',
        'Language Lessons': '1-2 hours'
      },
      location: ['CBD', 'Karen', 'Westlands', 'Kilimani', 'Lavington'],
      providerGender: ['male', 'female'],
      toolsProvided: false,
      ecoFriendly: true
    },
    requirements: {
      insurance: 'Professional liability insurance recommended',
      equipment: ['Teaching materials', 'Learning aids'],
      certification: 'Teaching certification or relevant qualifications required'
    },
    cancellationPolicy: {
      freeCancellation: '24 hours before',
      cancellationFee: '50% within 24 hours',
      noShow: '100% charge'
    }
  }
];

async function setupCategories() {
  const batch = db.batch();
  
  for (const category of serviceCategories) {
    console.log(`[SetupCategories] Writing category: id=${category.id}, name=${category.name}`);
    const categoryRef = db.collection('serviceCategories').doc(category.id);
    batch.set(categoryRef, {
      id: category.id,
      name: category.name,
      image: `https://example.com/${category.id}.jpg`,
      icon: category.id === 'cleaning' ? 'cleaning_services' :
            category.id === 'plumbing' ? 'plumbing' :
            category.id === 'electrical' ? 'electrical_services' :
            category.id === 'gardening' ? 'yard' :
            category.id === 'beauty' ? 'spa' :
            category.id === 'repairs' ? 'handyman' :
            category.id === 'pest' ? 'pest_control' :
            category.id === 'moving' ? 'local_shipping' :
            category.id === 'tech' ? 'devices' :
            category.id === 'tutoring' ? 'school' : 'category',
      description: `Professional ${category.name.toLowerCase()} services, expertly delivered to meet your needs.`,
      baseFeatures: [
        'Trained & vetted staff',
        'Quality guaranteed',
        'Flexible scheduling',
        'Insurance coverage'
      ],
      priceRanges: {
        'Standard Service': {
          base: 2000,
          max: 5000,
          type: 'fixed',
          unit: 'per visit'
        },
        'Premium Service': {
          base: 4000,
          max: 8000,
          type: 'fixed',
          unit: 'per visit'
        }
      },
      subCategories: category.subCategories,
      serviceOptions: category.serviceOptions,
      requirements: category.requirements,
      cancellationPolicy: category.cancellationPolicy,
      createdAt: new Date(),
      updatedAt: new Date()
    });
  }

  try {
    await batch.commit();
    console.log('Successfully set up service categories');
  } catch (error) {
    console.error('Error setting up categories:', error);
  }
}


// Clean up existing categories
async function cleanupCategories() {
  console.log('Cleaning up existing categories...');
  const snapshot = await db.collection('serviceCategories').get();
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  await batch.commit();
  console.log(`Deleted ${snapshot.size} existing categories`);
}

// Run cleanup and setup
async function initialize() {
  try {
    await cleanupCategories();
    await setupCategories();
    console.log('Successfully initialized categories with updated structure');
  } catch (error) {
    console.error('Error during initialization:', error);
  }
}

initialize();
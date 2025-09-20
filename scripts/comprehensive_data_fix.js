// Comprehensive data fix script
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'poafix'
});

const db = admin.firestore();

// Complete mapping of invalid categoryIds to correct ones
const categoryIdMapping = {
  'cat1': 'cleaning',
  'cat2': 'plumbing', 
  'cat3': 'electrical',
  'cat4': 'gardening',
  'cat5': 'beauty',
  'cat6': 'repairs',
  'cat7': 'pest',
  'cat8': 'moving',
  'cat9': 'tech',
  'cat10': 'tutoring',
  'tech-appliance': 'tech',
  'tech-appliances': 'tech',
  'cleaning-housekeeping': 'cleaning',
  'plumbing-water': 'plumbing',
  'electrical-services': 'electrical',
  'gardening-outdoor': 'gardening',
  'beauty-personal': 'beauty',
  'home-repairs': 'repairs',
  'pest-control': 'pest',
  'moving-delivery': 'moving',
  'tutoring-education': 'tutoring'
};

// SubService normalization mapping
const subServiceMapping = {
  // Cleaning
  'Regular Home Cleaning': 'Standard Home Cleaning',
  'Carpet Cleaning': 'Carpet & Rug Cleaning',
  'Standard Cleaning': 'Standard Home Cleaning',
  
  // Plumbing
  'Toilet Services': 'Tap/Sink/Toilet Installation & Repair',
  'Water Heater': 'Water Heater Installation & Maintenance',
  'Water Heater Services': 'Water Heater Installation & Maintenance',
  
  // Electrical
  'Generator Services': 'Generator & Inverter Setup',
  'General Electrical': 'Socket & Switch Repairs',
  
  // Gardening
  'Regular Maintenance': 'Lawn Mowing',
  
  // Moving
  'Local Moving': 'Local Household Moving',
  
  // Repairs
  'Painting': 'Painting (Interior & Exterior)',
  
  // Beauty
  'Hair Services': 'Haircut & Styling',
  'Nail Services': 'Manicure & Pedicure',
  
  // Tutoring
  'Academic Tutoring': 'Academic Tutoring (Primary/Secondary)'
};

async function comprehensiveDataFix() {
  try {
    console.log('🔧 Starting comprehensive data fix...');
    
    // Get all services
    const servicesSnapshot = await db.collection('services').get();
    const batch = db.batch();
    let updateCount = 0;
    
    console.log(`📊 Found ${servicesSnapshot.size} services to process`);
    
    for (const doc of servicesSnapshot.docs) {
      const data = doc.data();
      const updates = {};
      let needsUpdate = false;
      
      // Fix categoryId
      if (data.categoryId && categoryIdMapping[data.categoryId]) {
        updates.categoryId = categoryIdMapping[data.categoryId];
        needsUpdate = true;
        console.log(`🔄 Fixing categoryId: ${data.categoryId} → ${updates.categoryId} for "${data.name}"`);
      }
      
      // Fix subService
      if (data.subService && subServiceMapping[data.subService]) {
        updates.subService = subServiceMapping[data.subService];
        needsUpdate = true;
        console.log(`🔄 Fixing subService: ${data.subService} → ${updates.subService} for "${data.name}"`);
      }
      
      // Infer categoryId for services without it or with invalid ones
      if (!data.categoryId || (!categoryIdMapping[data.categoryId] && !['cleaning', 'plumbing', 'electrical', 'gardening', 'beauty', 'repairs', 'pest', 'moving', 'tech', 'tutoring'].includes(data.categoryId))) {
        const inferred = inferCategoryFromService(data);
        if (inferred) {
          updates.categoryId = inferred;
          needsUpdate = true;
          console.log(`🎯 Inferred categoryId: ${inferred} for "${data.name}"`);
        }
      }
      
      // Infer subService if missing
      if (!data.subService) {
        const inferred = inferSubServiceFromService(data, updates.categoryId || data.categoryId);
        if (inferred) {
          updates.subService = inferred;
          needsUpdate = true;
          console.log(`🎯 Inferred subService: ${inferred} for "${data.name}"`);
        }
      }
      
      if (needsUpdate) {
        batch.update(doc.ref, updates);
        updateCount++;
        
        // Commit in batches of 500 (Firestore limit)
        if (updateCount % 400 === 0) {
          await batch.commit();
          console.log(`✅ Committed batch of ${updateCount} updates`);
        }
      }
    }
    
    // Final commit
    if (updateCount % 400 !== 0) {
      await batch.commit();
    }
    
    console.log(`✅ Updated ${updateCount} services total`);
    
    // Verify the fixes
    console.log('\n🔍 Running final verification...');
    await verifyAndReport();
    
  } catch (error) {
    console.error('❌ Error in comprehensive data fix:', error);
  }
}

function inferCategoryFromService(data) {
  const name = (data.name || '').toLowerCase();
  const description = (data.description || '').toLowerCase();
  const subService = (data.subService || '').toLowerCase();
  const text = `${name} ${description} ${subService}`;
  
  if (text.includes('clean') || text.includes('laundry') || text.includes('carpet') || text.includes('window')) {
    return 'cleaning';
  } else if (text.includes('plumb') || text.includes('leak') || text.includes('pipe') || text.includes('toilet') || text.includes('water') || text.includes('tap') || text.includes('sink')) {
    return 'plumbing';
  } else if (text.includes('electric') || text.includes('light') || text.includes('socket') || text.includes('switch') || text.includes('power') || text.includes('wire')) {
    return 'electrical';
  } else if (text.includes('garden') || text.includes('lawn') || text.includes('tree') || text.includes('landscape') || text.includes('mow')) {
    return 'gardening';
  } else if (text.includes('hair') || text.includes('beauty') || text.includes('massage') || text.includes('manicure') || text.includes('pedicure') || text.includes('makeup')) {
    return 'beauty';
  } else if (text.includes('repair') || text.includes('handyman') || text.includes('paint') || text.includes('carpenter') || text.includes('roof') || text.includes('tile') || text.includes('fix')) {
    return 'repairs';
  } else if (text.includes('pest') || text.includes('fumigat') || text.includes('bedbug') || text.includes('cockroach') || text.includes('termite')) {
    return 'pest';
  } else if (text.includes('moving') || text.includes('delivery') || text.includes('haul') || text.includes('relocat') || text.includes('transport')) {
    return 'moving';
  } else if (text.includes('tv') || text.includes('appliance') || text.includes('ac ') || text.includes('air condition') || text.includes('fridge') || text.includes('microwave') || text.includes('tech') || text.includes('cctv')) {
    return 'tech';
  } else if (text.includes('tutor') || text.includes('lesson') || text.includes('education') || text.includes('teach') || text.includes('learn') || text.includes('academic')) {
    return 'tutoring';
  }
  
  return null;
}

function inferSubServiceFromService(data, categoryId) {
  const name = (data.name || '').toLowerCase();
  const description = (data.description || '').toLowerCase();
  const text = `${name} ${description}`;
  
  switch (categoryId) {
    case 'cleaning':
      if (text.includes('deep') || text.includes('move') || text.includes('construction')) return 'Deep Cleaning';
      if (text.includes('carpet') || text.includes('rug')) return 'Carpet & Rug Cleaning';
      if (text.includes('window')) return 'Window Cleaning';
      if (text.includes('laundry') || text.includes('iron')) return 'Laundry & Ironing';
      return 'Standard Home Cleaning';
      
    case 'plumbing':
      if (text.includes('emergency') || text.includes('24/7')) return 'Emergency Plumbing';
      if (text.includes('leak')) return 'Leak Detection & Repair';
      if (text.includes('toilet') || text.includes('sink') || text.includes('tap')) return 'Tap/Sink/Toilet Installation & Repair';
      if (text.includes('water heater') || text.includes('heater')) return 'Water Heater Installation & Maintenance';
      return 'Leak Detection & Repair';
      
    case 'electrical':
      if (text.includes('emergency')) return 'Emergency Electrical Services';
      if (text.includes('light') || text.includes('fixture')) return 'Light Fixture Installation';
      if (text.includes('socket') || text.includes('switch')) return 'Socket & Switch Repairs';
      return 'Socket & Switch Repairs';
      
    case 'gardening':
      if (text.includes('lawn') || text.includes('mow')) return 'Lawn Mowing';
      if (text.includes('tree') || text.includes('trim')) return 'Tree Trimming & Cutting';
      if (text.includes('design') || text.includes('landscape')) return 'Landscaping Design';
      return 'Lawn Mowing';
      
    case 'beauty':
      if (text.includes('hair') || text.includes('cut') || text.includes('style')) return 'Haircut & Styling';
      if (text.includes('manicure') || text.includes('nail')) return 'Manicure & Pedicure';
      if (text.includes('massage')) return 'Massage Therapy';
      return 'Haircut & Styling';
      
    case 'repairs':
      if (text.includes('paint')) return 'Painting (Interior & Exterior)';
      if (text.includes('carpenter') || text.includes('wood')) return 'Carpentry (Furnishing, Repairs)';
      if (text.includes('handyman') || text.includes('general')) return 'General Handyman Services';
      return 'General Handyman Services';
      
    case 'tech':
      if (text.includes('tv') || text.includes('mount')) return 'TV Wall Mounting';
      if (text.includes('ac') || text.includes('air')) return 'AC Installation & Repair';
      if (text.includes('fridge') || text.includes('freezer')) return 'Fridge & Freezer Repair';
      return 'TV Wall Mounting';
      
    case 'tutoring':
      if (text.includes('academic') || text.includes('school')) return 'Academic Tutoring (Primary/Secondary)';
      if (text.includes('language')) return 'Language Lessons (French, Swahili, English)';
      if (text.includes('music')) return 'Music Lessons (Piano, Guitar, etc.)';
      return 'Academic Tutoring (Primary/Secondary)';
      
    default:
      return null;
  }
}

async function verifyAndReport() {
  try {
    const servicesSnapshot = await db.collection('services').get();
    const categoriesSnapshot = await db.collection('serviceCategories').get();
    
    const validCategoryIds = new Set(categoriesSnapshot.docs.map(doc => doc.id));
    let validServicesCount = 0;
    let invalidServicesCount = 0;
    
    const categoryStats = {};
    
    servicesSnapshot.forEach(doc => {
      const data = doc.data();
      if (data.categoryId && validCategoryIds.has(data.categoryId)) {
        validServicesCount++;
        if (!categoryStats[data.categoryId]) {
          categoryStats[data.categoryId] = { total: 0, subServices: new Set() };
        }
        categoryStats[data.categoryId].total++;
        if (data.subService) {
          categoryStats[data.categoryId].subServices.add(data.subService);
        }
      } else {
        invalidServicesCount++;
      }
    });
    
    console.log('\n📊 FINAL VERIFICATION REPORT');
    console.log('='.repeat(50));
    console.log(`✅ Valid services: ${validServicesCount}`);
    console.log(`❌ Invalid services: ${invalidServicesCount}`);
    console.log(`📈 Success rate: ${((validServicesCount / (validServicesCount + invalidServicesCount)) * 100).toFixed(1)}%`);
    
    console.log('\n📋 Category Distribution:');
    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryData = categoryDoc.data();
      const stats = categoryStats[categoryDoc.id] || { total: 0, subServices: new Set() };
      console.log(`  ${categoryData.name}: ${stats.total} services, ${stats.subServices.size} sub-services used`);
    }
    
  } catch (error) {
    console.error('❌ Error in verification:', error);
  }
}

// Run the comprehensive fix
comprehensiveDataFix();
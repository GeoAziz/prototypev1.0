// Fix data consistency between categories and services
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'poafix'
});

const db = admin.firestore();

// Mapping of old categoryIds to new ones (if needed)
const categoryMapping = {
  'home-repairs': 'repairs',
  'tech-appliances': 'tech',
  'beauty-personal': 'beauty',
  'tutoring-education': 'tutoring',
  // Add any other mappings found
};

// SubService mapping to match categories exactly
const subServiceMapping = {
  'Academic Tutoring': 'Academic Tutoring (Primary/Secondary)',
  'Emergency Plumbing': 'Emergency Plumbing',
  'General Handyman': 'General Handyman Services',
  'Standard Cleaning': 'Standard Home Cleaning',
  'Deep Cleaning': 'Deep Cleaning',
  // Add more mappings as needed
};

async function fixDataConsistency() {
  try {
    console.log('🔧 Starting data consistency fix...');
    
    // Get all services
    const servicesSnapshot = await db.collection('services').get();
    const batch = db.batch();
    let updateCount = 0;
    
    console.log(`Found ${servicesSnapshot.size} services to check`);
    
    for (const doc of servicesSnapshot.docs) {
      const data = doc.data();
      const updates = {};
      let needsUpdate = false;
      
      // Fix categoryId if needed
      if (data.categoryId && categoryMapping[data.categoryId]) {
        updates.categoryId = categoryMapping[data.categoryId];
        needsUpdate = true;
        console.log(`📝 Updating categoryId: ${data.categoryId} → ${updates.categoryId} for service ${data.name}`);
      }
      
      // Fix subService if needed
      if (data.subService && subServiceMapping[data.subService]) {
        updates.subService = subServiceMapping[data.subService];
        needsUpdate = true;
        console.log(`📝 Updating subService: ${data.subService} → ${updates.subService} for service ${data.name}`);
      }
      
      // Ensure categoryId exists for services that don't have it
      if (!data.categoryId) {
        // Try to infer from subService or service name
        const serviceName = data.name?.toLowerCase() || '';
        const subService = data.subService?.toLowerCase() || '';
        
        if (serviceName.includes('clean') || subService.includes('clean')) {
          updates.categoryId = 'cleaning';
          needsUpdate = true;
        } else if (serviceName.includes('plumb') || subService.includes('plumb')) {
          updates.categoryId = 'plumbing';
          needsUpdate = true;
        } else if (serviceName.includes('electric') || subService.includes('electric')) {
          updates.categoryId = 'electrical';
          needsUpdate = true;
        } else if (serviceName.includes('garden') || subService.includes('garden')) {
          updates.categoryId = 'gardening';
          needsUpdate = true;
        } else if (serviceName.includes('beauty') || serviceName.includes('hair') || serviceName.includes('massage')) {
          updates.categoryId = 'beauty';
          needsUpdate = true;
        } else if (serviceName.includes('repair') || serviceName.includes('handyman')) {
          updates.categoryId = 'repairs';
          needsUpdate = true;
        } else if (serviceName.includes('pest') || serviceName.includes('fumigat')) {
          updates.categoryId = 'pest';
          needsUpdate = true;
        } else if (serviceName.includes('moving') || serviceName.includes('delivery')) {
          updates.categoryId = 'moving';
          needsUpdate = true;
        } else if (serviceName.includes('tech') || serviceName.includes('appliance') || serviceName.includes('tv') || serviceName.includes('ac')) {
          updates.categoryId = 'tech';
          needsUpdate = true;
        } else if (serviceName.includes('tutor') || serviceName.includes('lesson') || serviceName.includes('education')) {
          updates.categoryId = 'tutoring';
          needsUpdate = true;
        }
        
        if (updates.categoryId) {
          console.log(`📝 Inferred categoryId: ${updates.categoryId} for service ${data.name}`);
        }
      }
      
      if (needsUpdate) {
        batch.update(doc.ref, updates);
        updateCount++;
      }
    }
    
    if (updateCount > 0) {
      await batch.commit();
      console.log(`✅ Updated ${updateCount} services`);
    } else {
      console.log('✅ No updates needed');
    }
    
    // Verify the fixes
    console.log('\n🔍 Verifying fixes...');
    await verifyData();
    
  } catch (error) {
    console.error('❌ Error fixing data consistency:', error);
  }
}

async function verifyData() {
  try {
    // Check if all services have valid categoryIds
    const servicesSnapshot = await db.collection('services').get();
    const categoriesSnapshot = await db.collection('serviceCategories').get();
    
    const validCategoryIds = new Set(categoriesSnapshot.docs.map(doc => doc.id));
    const invalidServices = [];
    
    servicesSnapshot.forEach(doc => {
      const data = doc.data();
      if (!data.categoryId || !validCategoryIds.has(data.categoryId)) {
        invalidServices.push({
          id: doc.id,
          name: data.name,
          categoryId: data.categoryId,
          subService: data.subService
        });
      }
    });
    
    if (invalidServices.length > 0) {
      console.log(`⚠️  Found ${invalidServices.length} services with invalid categoryIds:`);
      invalidServices.slice(0, 5).forEach(service => {
        console.log(`  - ${service.name} (categoryId: ${service.categoryId})`);
      });
    } else {
      console.log('✅ All services have valid categoryIds');
    }
    
    // Check subService consistency
    for (const categoryDoc of categoriesSnapshot.docs) {
      const categoryData = categoryDoc.data();
      const categoryId = categoryDoc.id;
      const subCategories = categoryData.subCategories || [];
      
      const categoryServicesSnapshot = await db.collection('services')
        .where('categoryId', '==', categoryId)
        .get();
      
      const usedSubServices = new Set();
      categoryServicesSnapshot.forEach(doc => {
        const serviceData = doc.data();
        if (serviceData.subService) {
          usedSubServices.add(serviceData.subService);
        }
      });
      
      console.log(`\n📋 Category: ${categoryData.name} (${categoryId})`);
      console.log(`  - Services: ${categoryServicesSnapshot.size}`);
      console.log(`  - Defined subCategories: ${subCategories.length}`);
      console.log(`  - Used subServices: ${usedSubServices.size}`);
      
      // Find mismatches
      const unused = subCategories.filter(sub => !usedSubServices.has(sub));
      const undefined = Array.from(usedSubServices).filter(sub => !subCategories.includes(sub));
      
      if (unused.length > 0) {
        console.log(`  ⚠️  Unused subCategories: ${unused.slice(0, 3).join(', ')}${unused.length > 3 ? '...' : ''}`);
      }
      if (undefined.length > 0) {
        console.log(`  ⚠️  Undefined subServices: ${undefined.slice(0, 3).join(', ')}${undefined.length > 3 ? '...' : ''}`);
      }
    }
    
  } catch (error) {
    console.error('❌ Error verifying data:', error);
  }
}

// Run the fix
fixDataConsistency();
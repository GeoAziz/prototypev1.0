// Comprehensive Sub-Service Population Script
// This script creates detailed services under each sub-service type
// Prices based on Kenyan market research

// Firebase Admin SDK configuration
const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: 'poafix'
});

const db = admin.firestore();

// Comprehensive Service Data by Sub-Service
const servicesByCategory = {
  "cleaning": {
    categoryName: "Cleaning & Housekeeping",
    subServices: {
      "Standard Home Cleaning": [
        {
          name: "Basic Weekly Cleaning Service",
          description: "Regular weekly cleaning for your home including dusting, vacuuming, and mopping",
          price: 4000,
          pricingType: "per-session",
          currency: "KES",
          duration: 3,
          features: ["Dusting all surfaces", "Vacuuming carpets", "Mopping floors", "Bathroom cleaning", "Kitchen basics"],
          rating: 4.2,
          reviewCount: 156,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/cleaning1.jpg"],
          priceRange: { min: 3000, max: 5000 }
        },
        {
          name: "Premium Home Cleaning Package",
          description: "Comprehensive home cleaning with premium products and detailed attention",
          price: 9000,
          pricingType: "per-session", 
          currency: "KES",
          duration: 4,
          features: ["Deep dusting", "Floor polishing", "Kitchen deep clean", "Appliance cleaning", "Organizing"],
          rating: 4.7,
          reviewCount: 203,
          bookingCount: 124,
          active: true,
          images: ["https://example.com/cleaning2.jpg"],
          priceRange: { min: 6000, max: 12000 }
        },
        {
          name: "Eco-Friendly Home Cleaning",
          description: "Environmentally safe cleaning using organic and non-toxic products",
          price: 4800,
          pricingType: "per-session",
          currency: "KES", 
          duration: 3,
          features: ["Organic products", "Chemical-free", "Safe for pets", "Allergen-free", "Green certified"],
          rating: 4.5,
          reviewCount: 98,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/eco-cleaning.jpg"],
          priceRange: { min: 4000, max: 6000 }
        },
        {
          name: "Student Budget Cleaning",
          description: "Affordable cleaning service perfect for students and budget-conscious clients",
          price: 2500,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Basic cleaning", "Essential areas only", "Quick service", "Budget-friendly"],
          rating: 4.0,
          reviewCount: 45,
          bookingCount: 78,
          active: true,
          images: ["https://example.com/budget-cleaning.jpg"],
          priceRange: { min: 2000, max: 3500 }
        }
      ],
      "Deep Cleaning": [
        {
          name: "Move-in/Move-out Deep Cleaning",
          description: "Thorough deep cleaning service for moving situations, ensuring pristine condition",
          price: 12000,
          pricingType: "per-session",
          currency: "KES",
          duration: 6,
          features: ["Inside appliances", "Cabinet deep clean", "Baseboard cleaning", "Light fixture cleaning", "Deep sanitization"],
          rating: 4.6,
          reviewCount: 134,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/deep-clean1.jpg"],
          priceRange: { min: 8000, max: 15000 }
        },
        {
          name: "Spring Deep Cleaning Service",
          description: "Seasonal deep cleaning to refresh your entire home from top to bottom",
          price: 10000,
          pricingType: "per-session",
          currency: "KES",
          duration: 5,
          features: ["Seasonal refresh", "Window cleaning", "Deep carpet clean", "Closet organization", "Air vent cleaning"],
          rating: 4.4,
          reviewCount: 87,
          bookingCount: 56,
          active: true,
          images: ["https://example.com/spring-clean.jpg"],
          priceRange: { min: 8000, max: 12000 }
        },
        {
          name: "Post-Construction Deep Clean",
          description: "Specialized cleaning after construction or renovation work",
          price: 15000,
          pricingType: "per-session",
          currency: "KES",
          duration: 8,
          features: ["Dust removal", "Paint residue cleaning", "Construction debris", "Safety cleaning", "Final polish"],
          rating: 4.3,
          reviewCount: 67,
          bookingCount: 34,
          active: true,
          images: ["https://example.com/construction-clean.jpg"],
          priceRange: { min: 12000, max: 18000 }
        }
      ],
      "Carpet & Rug Cleaning": [
        {
          name: "Steam Carpet Cleaning",
          description: "Professional steam cleaning for deep carpet sanitization and stain removal",
          price: 3000,
          pricingType: "per-carpet",
          currency: "KES",
          duration: 2,
          features: ["Hot water extraction", "Stain removal", "Sanitization", "Fast drying", "Eco-friendly"],
          rating: 4.5,
          reviewCount: 123,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/steam-carpet.jpg"],
          priceRange: { min: 2000, max: 4000 }
        },
        {
          name: "Dry Carpet Cleaning",
          description: "Quick dry cleaning method perfect for delicate carpets and busy schedules",
          price: 2500,
          pricingType: "per-carpet",
          currency: "KES",
          duration: 1,
          features: ["No water", "Quick dry", "Gentle on fabric", "Immediate use", "Stain treatment"],
          rating: 4.2,
          reviewCount: 89,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/dry-carpet.jpg"],
          priceRange: { min: 2000, max: 3500 }
        }
      ],
      "Window Cleaning": [
        {
          name: "Residential Window Cleaning",
          description: "Professional window cleaning for homes, inside and outside",
          price: 500,
          pricingType: "per-window",
          currency: "KES",
          duration: 1,
          features: ["Inside & outside", "Screen cleaning", "Sill wiping", "Streak-free", "Safety equipment"],
          rating: 4.4,
          reviewCount: 156,
          bookingCount: 234,
          active: true,
          images: ["https://example.com/window-clean.jpg"],
          priceRange: { min: 300, max: 700 }
        }
      ],
      "Laundry & Ironing": [
        {
          name: "Wash & Fold Service",
          description: "Complete laundry service including washing, drying, and folding",
          price: 300,
          pricingType: "per-kg",
          currency: "KES",
          duration: 1,
          features: ["Wash & dry", "Folding", "Fabric softener", "Stain treatment", "Same day"],
          rating: 4.3,
          reviewCount: 201,
          bookingCount: 345,
          active: true,
          images: ["https://example.com/laundry.jpg"],
          priceRange: { min: 150, max: 500 }
        }
      ]
    }
  },
  "plumbing": {
    categoryName: "Plumbing Services",
    subServices: {
      "Leak Detection & Repair": [
        {
          name: "Emergency Leak Repair",
          description: "24/7 emergency leak detection and repair service",
          price: 5500,
          pricingType: "per-job",
          currency: "KES",
          duration: 2,
          features: ["24/7 availability", "Quick response", "Professional tools", "Warranty included", "Emergency service"],
          rating: 4.6,
          reviewCount: 89,
          bookingCount: 156,
          active: true,
          images: ["https://example.com/leak-repair.jpg"],
          priceRange: { min: 3000, max: 8000 }
        },
        {
          name: "Pipe Leak Detection Service",
          description: "Advanced leak detection using modern equipment and techniques",
          price: 4000,
          pricingType: "per-job",
          currency: "KES",
          duration: 3,
          features: ["Advanced detection", "Non-invasive", "Accurate location", "Detailed report", "Recommendation"],
          rating: 4.4,
          reviewCount: 67,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/leak-detection.jpg"],
          priceRange: { min: 2000, max: 6000 }
        }
      ],
      "Tap/Sink/Toilet Installation & Repair": [
        {
          name: "Kitchen Sink Installation",
          description: "Professional kitchen sink installation with plumbing connections",
          price: 8500,
          pricingType: "per-installation",
          currency: "KES",
          duration: 4,
          features: ["Complete installation", "Plumbing connections", "Testing", "Cleanup", "Warranty"],
          rating: 4.5,
          reviewCount: 78,
          bookingCount: 45,
          active: true,
          images: ["https://example.com/sink-install.jpg"],
          priceRange: { min: 5000, max: 12000 }
        },
        {
          name: "Toilet Repair & Replacement",
          description: "Complete toilet repair and replacement service",
          price: 7000,
          pricingType: "per-job",
          currency: "KES",
          duration: 3,
          features: ["Diagnosis", "Parts replacement", "Full installation", "Testing", "Cleanup"],
          rating: 4.3,
          reviewCount: 123,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/toilet-repair.jpg"],
          priceRange: { min: 4000, max: 10000 }
        }
      ],
      "Emergency Plumbing": [
        {
          name: "24/7 Emergency Plumbing",
          description: "Round-the-clock emergency plumbing service for urgent issues",
          price: 7500,
          pricingType: "per-callout",
          currency: "KES",
          duration: 2,
          features: ["24/7 service", "Rapid response", "Emergency repairs", "All equipment", "Priority service"],
          rating: 4.7,
          reviewCount: 156,
          bookingCount: 234,
          active: true,
          images: ["https://example.com/emergency-plumb.jpg"],
          priceRange: { min: 5000, max: 10000 }
        }
      ],
      "Water Heater Installation & Maintenance": [
        {
          name: "Electric Water Heater Installation",
          description: "Professional electric water heater installation and setup",
          price: 22500,
          pricingType: "per-installation",
          currency: "KES",
          duration: 6,
          features: ["Complete installation", "Electrical connections", "Safety checks", "Testing", "Warranty"],
          rating: 4.5,
          reviewCount: 89,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/water-heater.jpg"],
          priceRange: { min: 15000, max: 30000 }
        },
        {
          name: "Solar Water Heater Setup",
          description: "Eco-friendly solar water heater installation and configuration",
          price: 30000,
          pricingType: "per-installation",
          currency: "KES",
          duration: 8,
          features: ["Solar installation", "Eco-friendly", "Energy savings", "Professional setup", "Maintenance guide"],
          rating: 4.6,
          reviewCount: 67,
          bookingCount: 34,
          active: true,
          images: ["https://example.com/solar-heater.jpg"],
          priceRange: { min: 20000, max: 40000 }
        }
      ]
    }
  },
  "electrical": {
    categoryName: "Electrical Services",
    subServices: {
      "Light Fixture Installation": [
        {
          name: "Ceiling Fan Installation",
          description: "Professional ceiling fan installation with electrical connections",
          price: 4750,
          pricingType: "per-installation",
          currency: "KES",
          duration: 3,
          features: ["Complete installation", "Electrical wiring", "Balancing", "Testing", "Safety check"],
          rating: 4.4,
          reviewCount: 123,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/ceiling-fan.jpg"],
          priceRange: { min: 2500, max: 7000 }
        },
        {
          name: "Chandelier Installation",
          description: "Elegant chandelier installation with proper electrical setup",
          price: 5500,
          pricingType: "per-installation",
          currency: "KES",
          duration: 4,
          features: ["Secure mounting", "Electrical connections", "Testing", "Cleanup", "Support warranty"],
          rating: 4.6,
          reviewCount: 67,
          bookingCount: 45,
          active: true,
          images: ["https://example.com/chandelier.jpg"],
          priceRange: { min: 3000, max: 8000 }
        },
        {
          name: "LED Light Setup",
          description: "Energy-efficient LED lighting installation and configuration",
          price: 4000,
          pricingType: "per-installation",
          currency: "KES",
          duration: 2,
          features: ["LED installation", "Energy efficient", "Dimmer compatible", "Long-lasting", "Warranty"],
          rating: 4.3,
          reviewCount: 89,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/led-lights.jpg"],
          priceRange: { min: 2000, max: 6000 }
        }
      ],
      "Socket & Switch Repairs": [
        {
          name: "Power Socket Installation",
          description: "New power socket installation with safety features",
          price: 3250,
          pricingType: "per-socket",
          currency: "KES",
          duration: 2,
          features: ["Safe installation", "Quality materials", "Testing", "GFCI option", "Warranty"],
          rating: 4.4,
          reviewCount: 156,
          bookingCount: 123,
          active: true,
          images: ["https://example.com/socket-install.jpg"],
          priceRange: { min: 1500, max: 5000 }
        },
        {
          name: "Dimmer Switch Setup",
          description: "Smart dimmer switch installation for lighting control",
          price: 3500,
          pricingType: "per-switch",
          currency: "KES",
          duration: 2,
          features: ["Dimmer control", "Smart compatible", "Easy operation", "Energy saving", "Modern design"],
          rating: 4.5,
          reviewCount: 78,
          bookingCount: 56,
          active: true,
          images: ["https://example.com/dimmer-switch.jpg"],
          priceRange: { min: 2000, max: 5000 }
        }
      ],
      "Emergency Electrical Services": [
        {
          name: "Power Outage Diagnosis",
          description: "Emergency electrical diagnosis and power restoration service",
          price: 6500,
          pricingType: "per-callout",
          currency: "KES",
          duration: 3,
          features: ["24/7 service", "Quick diagnosis", "Emergency repairs", "Safety priority", "Rapid response"],
          rating: 4.7,
          reviewCount: 134,
          bookingCount: 189,
          active: true,
          images: ["https://example.com/power-outage.jpg"],
          priceRange: { min: 3000, max: 10000 }
        },
        {
          name: "Electrical Safety Inspection",
          description: "Comprehensive electrical safety inspection and certification",
          price: 4500,
          pricingType: "per-inspection",
          currency: "KES",
          duration: 4,
          features: ["Safety inspection", "Detailed report", "Recommendations", "Certification", "Peace of mind"],
          rating: 4.6,
          reviewCount: 89,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/safety-inspection.jpg"],
          priceRange: { min: 3000, max: 6000 }
        }
      ]
    }
  },
  "gardening": {
    categoryName: "Gardening & Outdoor Maintenance",
    subServices: {
      "Lawn Mowing": [
        {
          name: "Weekly Lawn Mowing",
          description: "Regular weekly lawn mowing service to keep your grass pristine",
          price: 2000,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Edge trimming", "Grass collection", "Pattern mowing", "Equipment included", "Weather backup"],
          rating: 4.3,
          reviewCount: 167,
          bookingCount: 234,
          active: true,
          images: ["https://example.com/lawn-mowing.jpg"],
          priceRange: { min: 1000, max: 3000 }
        },
        {
          name: "Bi-weekly Lawn Care",
          description: "Professional bi-weekly lawn maintenance and care service",
          price: 1800,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Mowing", "Edging", "Basic fertilizing", "Weed check", "Cleanup"],
          rating: 4.2,
          reviewCount: 123,
          bookingCount: 156,
          active: true,
          images: ["https://example.com/lawn-care.jpg"],
          priceRange: { min: 1200, max: 2500 }
        }
      ],
      "Tree Trimming & Cutting": [
        {
          name: "Hedge Trimming Service",
          description: "Professional hedge trimming and shaping for beautiful landscapes",
          price: 3500,
          pricingType: "per-session",
          currency: "KES",
          duration: 3,
          features: ["Precision trimming", "Shape maintenance", "Cleanup included", "Professional tools", "Seasonal timing"],
          rating: 4.5,
          reviewCount: 89,
          bookingCount: 67,
          active: true,
          images: ["https://example.com/hedge-trim.jpg"],
          priceRange: { min: 2000, max: 5000 }
        },
        {
          name: "Tree Pruning",
          description: "Expert tree pruning for health, safety, and aesthetic appeal",
          price: 10000,
          pricingType: "per-tree",
          currency: "KES",
          duration: 4,
          features: ["Health pruning", "Safety trimming", "Shape improvement", "Cleanup", "Expert advice"],
          rating: 4.6,
          reviewCount: 78,
          bookingCount: 45,
          active: true,
          images: ["https://example.com/tree-pruning.jpg"],
          priceRange: { min: 5000, max: 15000 }
        }
      ],
      "Landscaping Design": [
        {
          name: "Garden Design Consultation",
          description: "Professional garden design consultation and planning service",
          price: 12500,
          pricingType: "per-consultation",
          currency: "KES",
          duration: 3,
          features: ["Design consultation", "Plant recommendations", "Layout planning", "Budget estimation", "3D visualization"],
          rating: 4.7,
          reviewCount: 56,
          bookingCount: 34,
          active: true,
          images: ["https://example.com/garden-design.jpg"],
          priceRange: { min: 5000, max: 20000 }
        }
      ]
    }
  },
  "beauty": {
    categoryName: "Beauty & Personal Care",
    subServices: {
      "Haircut & Styling": [
        {
          name: "Men's Haircut at Home",
          description: "Professional men's haircut service in the comfort of your home",
          price: 1000,
          pricingType: "per-session",
          currency: "KES",
          duration: 1,
          features: ["Professional cut", "Styling", "Beard trim", "Hair wash", "Home service"],
          rating: 4.4,
          reviewCount: 234,
          bookingCount: 345,
          active: true,
          images: ["https://example.com/mens-haircut.jpg"],
          priceRange: { min: 500, max: 1500 }
        },
        {
          name: "Women's Styling Service",
          description: "Complete women's hair styling and treatment service at home",
          price: 2000,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Cut & style", "Blow dry", "Treatment", "Consultation", "Premium products"],
          rating: 4.6,
          reviewCount: 189,
          bookingCount: 267,
          active: true,
          images: ["https://example.com/womens-styling.jpg"],
          priceRange: { min: 1000, max: 3000 }
        },
        {
          name: "Kids Haircut Service",
          description: "Fun and gentle haircut service specially designed for children",
          price: 800,
          pricingType: "per-session",
          currency: "KES",
          duration: 1,
          features: ["Kid-friendly", "Gentle approach", "Fun experience", "Parent supervision", "Quick service"],
          rating: 4.5,
          reviewCount: 156,
          bookingCount: 234,
          active: true,
          images: ["https://example.com/kids-haircut.jpg"],
          priceRange: { min: 500, max: 1200 }
        }
      ],
      "Manicure & Pedicure": [
        {
          name: "Basic Manicure Service",
          description: "Essential manicure service for healthy and beautiful nails",
          price: 1400,
          pricingType: "per-session",
          currency: "KES",
          duration: 1,
          features: ["Nail shaping", "Cuticle care", "Polish application", "Hand massage", "Base & top coat"],
          rating: 4.3,
          reviewCount: 123,
          bookingCount: 167,
          active: true,
          images: ["https://example.com/basic-manicure.jpg"],
          priceRange: { min: 800, max: 2000 }
        },
        {
          name: "Gel Manicure at Home",
          description: "Long-lasting gel manicure service performed at your location",
          price: 2500,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Gel polish", "UV/LED curing", "Long-lasting", "Chip resistant", "Professional finish"],
          rating: 4.6,
          reviewCount: 89,
          bookingCount: 134,
          active: true,
          images: ["https://example.com/gel-manicure.jpg"],
          priceRange: { min: 1500, max: 3500 }
        },
        {
          name: "Luxury Spa Pedicure",
          description: "Premium pedicure service with spa-quality treatment and relaxation",
          price: 3000,
          pricingType: "per-session",
          currency: "KES",
          duration: 2,
          features: ["Foot soak", "Exfoliation", "Massage", "Polish", "Luxury treatment"],
          rating: 4.7,
          reviewCount: 67,
          bookingCount: 89,
          active: true,
          images: ["https://example.com/luxury-pedicure.jpg"],
          priceRange: { min: 2000, max: 4000 }
        }
      ],
      "Massage Therapy": [
        {
          name: "Relaxation Massage",
          description: "Soothing relaxation massage to relieve stress and tension",
          price: 4000,
          pricingType: "per-session",
          currency: "KES",
          duration: 1,
          features: ["Stress relief", "Muscle relaxation", "Aromatherapy", "Calming environment", "Professional therapist"],
          rating: 4.5,
          reviewCount: 156,
          bookingCount: 189,
          active: true,
          images: ["https://example.com/relaxation-massage.jpg"],
          priceRange: { min: 2000, max: 6000 }
        },
        {
          name: "Deep Tissue Massage",
          description: "Therapeutic deep tissue massage for muscle recovery and pain relief",
          price: 5000,
          pricingType: "per-session",
          currency: "KES",
          duration: 1,
          features: ["Deep pressure", "Muscle recovery", "Pain relief", "Therapeutic", "Recovery focused"],
          rating: 4.6,
          reviewCount: 89,
          bookingCount: 123,
          active: true,
          images: ["https://example.com/deep-tissue.jpg"],
          priceRange: { min: 3000, max: 7000 }
        }
      ]
    }
  }
};

// Function to populate services
async function populateServices() {
  console.log("🚀 Starting service population...");
  
  try {
    for (const [categoryId, categoryData] of Object.entries(servicesByCategory)) {
      console.log(`\n📂 Processing category: ${categoryData.categoryName}`);
      
      for (const [subServiceName, services] of Object.entries(categoryData.subServices)) {
        console.log(`  📋 Processing sub-service: ${subServiceName}`);
        
        for (const service of services) {
          const serviceData = {
            ...service,
            categoryId: categoryId,
            categoryName: categoryData.categoryName,
            subService: subServiceName,
            createdAt: new Date(),
            updatedAt: new Date(),
            available: true,
            location: "Nairobi, Kenya", // Default location
            tags: [categoryId, subServiceName.toLowerCase().replace(/\s+/g, '_')],
            bookingSettings: {
              advanceBooking: 24, // hours
              cancellationPolicy: "24 hours",
              instantBooking: true
            }
          };
          
          // Add to Firestore
          const docRef = await db.collection('services').add(serviceData);
          console.log(`    ✅ Added service: ${service.name} (ID: ${docRef.id})`);
        }
      }
    }
    
    console.log("\n🎉 Service population completed successfully!");
    console.log("\n📊 Summary:");
    
    // Calculate totals
    let totalServices = 0;
    let totalSubServices = 0;
    
    for (const categoryData of Object.values(servicesByCategory)) {
      totalSubServices += Object.keys(categoryData.subServices).length;
      for (const services of Object.values(categoryData.subServices)) {
        totalServices += services.length;
      }
    }
    
    console.log(`- Categories: ${Object.keys(servicesByCategory).length}`);
    console.log(`- Sub-services: ${totalSubServices}`);
    console.log(`- Total services: ${totalServices}`);
    
  } catch (error) {
    console.error("❌ Error populating services:", error);
  }
}

// Run the population
populateServices();
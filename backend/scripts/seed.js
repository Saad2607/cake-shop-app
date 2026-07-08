/**
 * Seed MongoDB with demo users and cakes.
 * Prices are in Indian Rupees (INR).
 * basePrice = price for the FIRST size in the sizes array (e.g. 1kg → 2kg costs 2×).
 * Run: npm run seed (from backend folder)
 */
require('dotenv').config();
const bcrypt = require('bcryptjs');
const { connectDatabase } = require('../src/config/database');
const User = require('../src/models/User');
const Cake = require('../src/models/Cake');

const CAKES = [
  {
    name: 'Chocolate Fudge Birthday Cake',
    description: 'Rich chocolate layers with fudge frosting. Perfect for birthdays.',
    category: 'BIRTHDAY',
    basePrice: 899,
    imageUrl: '',
    flavors: ['Chocolate', 'Vanilla'],
    sizes: ['500g', '1kg', '2kg'],
    rating: 4.5,
    inStock: true,
  },
  {
    name: 'Vanilla Dream Wedding Cake',
    description: 'Elegant three-tier vanilla cake with buttercream roses.',
    category: 'WEDDING',
    basePrice: 9999,
    imageUrl: '',
    flavors: ['Vanilla', 'Strawberry'],
    sizes: ['2kg', '3kg', '5kg'],
    rating: 4.8,
    inStock: true,
  },
  {
    name: 'Red Velvet Cupcake Box',
    description: 'Box of 12 premium red velvet cupcakes with cream cheese frosting.',
    category: 'CUPCAKE',
    basePrice: 549,
    imageUrl: '',
    flavors: ['Red Velvet'],
    sizes: ['6 pcs', '12 pcs', '24 pcs'],
    rating: 4.6,
    inStock: true,
  },
  {
    name: 'Custom Photo Cake',
    description: 'Upload your photo and we print it on a delicious buttercream cake.',
    category: 'CUSTOM',
    basePrice: 2499,
    imageUrl: '',
    flavors: ['Vanilla', 'Chocolate', 'Red Velvet'],
    sizes: ['1kg', '2kg'],
    rating: 4.7,
    inStock: true,
  },
  {
    name: 'Christmas Fruit Cake',
    description: 'Traditional spiced fruit cake with nuts and dried fruits.',
    category: 'SEASONAL',
    basePrice: 1899,
    imageUrl: '',
    flavors: ['Fruit', 'Spice'],
    sizes: ['500g', '1kg'],
    rating: 4.4,
    inStock: true,
  },
  {
    name: 'Strawberry Shortcake',
    description: 'Light sponge with fresh strawberries and whipped cream.',
    category: 'BIRTHDAY',
    basePrice: 999,
    imageUrl: '',
    flavors: ['Strawberry', 'Vanilla'],
    sizes: ['500g', '1kg'],
    rating: 4.5,
    inStock: true,
  },
  {
    name: 'Black Forest Gateau',
    description: 'Classic German cake with cherries, chocolate, and whipped cream.',
    category: 'BIRTHDAY',
    basePrice: 1299,
    imageUrl: '',
    flavors: ['Chocolate', 'Cherry'],
    sizes: ['1kg', '2kg'],
    rating: 4.9,
    inStock: true,
  },
  {
    name: 'Butterscotch Crunch Cake',
    description: 'Caramel butterscotch layers topped with crunchy praline and fresh cream.',
    category: 'BIRTHDAY',
    basePrice: 849,
    imageUrl: '',
    flavors: ['Butterscotch', 'Vanilla'],
    sizes: ['500g', '1kg', '2kg'],
    rating: 4.6,
    inStock: true,
  },
  {
    name: 'Mango Alphonso Mousse Cake',
    description: 'Seasonal Alphonso mango mousse on soft sponge — summer favourite.',
    category: 'SEASONAL',
    basePrice: 1199,
    imageUrl: '',
    flavors: ['Mango', 'Vanilla'],
    sizes: ['500g', '1kg'],
    rating: 4.7,
    inStock: true,
  },
  {
    name: 'Oreo Chocolate Overload',
    description: 'Dark chocolate cake loaded with Oreo crumble and cookies-and-cream frosting.',
    category: 'BIRTHDAY',
    basePrice: 949,
    imageUrl: '',
    flavors: ['Chocolate', 'Oreo'],
    sizes: ['500g', '1kg', '2kg'],
    rating: 4.8,
    inStock: true,
  },
  {
    name: 'Gulab Jamun Fusion Cake',
    description: 'Indian fusion: saffron sponge with gulab jamun pieces and rabdi cream.',
    category: 'BIRTHDAY',
    basePrice: 1399,
    imageUrl: '',
    flavors: ['Saffron', 'Mawa'],
    sizes: ['1kg', '2kg'],
    rating: 4.8,
    inStock: true,
  },
  {
    name: 'Blueberry Cheesecake Jar',
    description: 'Set of 6 individual blueberry cheesecake jars — perfect for parties.',
    category: 'CUPCAKE',
    basePrice: 699,
    imageUrl: '',
    flavors: ['Blueberry', 'Cheese'],
    sizes: ['3 pcs', '6 pcs', '12 pcs'],
    rating: 4.5,
    inStock: true,
  },
  {
    name: 'Chocolate Truffle Cupcake Box',
    description: 'Belgian chocolate truffle cupcakes with ganache swirl.',
    category: 'CUPCAKE',
    basePrice: 599,
    imageUrl: '',
    flavors: ['Dark Chocolate', 'Truffle'],
    sizes: ['6 pcs', '12 pcs'],
    rating: 4.7,
    inStock: true,
  },
  {
    name: 'Classic White Wedding Cake',
    description: 'Two-tier ivory fondant cake with pearl finish and fresh florals.',
    category: 'WEDDING',
    basePrice: 7499,
    imageUrl: '',
    flavors: ['Vanilla', 'Raspberry'],
    sizes: ['2kg', '3kg', '5kg'],
    rating: 4.9,
    inStock: true,
  },
  {
    name: 'Rose Gold Anniversary Cake',
    description: 'Elegant rose-gold drip cake with macarons — ideal for anniversaries.',
    category: 'WEDDING',
    basePrice: 4599,
    imageUrl: '',
    flavors: ['Vanilla', 'Rose'],
    sizes: ['1.5kg', '2kg', '3kg'],
    rating: 4.7,
    inStock: true,
  },
  {
    name: 'Cartoon Theme Kids Cake',
    description: 'Customisable cartoon character buttercream cake for kids birthdays.',
    category: 'CUSTOM',
    basePrice: 1999,
    imageUrl: '',
    flavors: ['Vanilla', 'Chocolate'],
    sizes: ['1kg', '1.5kg', '2kg'],
    rating: 4.6,
    inStock: true,
  },
  {
    name: 'Corporate Logo Cake',
    description: 'Edible logo print on premium sponge — launches, events & corporate gifting.',
    category: 'CUSTOM',
    basePrice: 2999,
    imageUrl: '',
    flavors: ['Vanilla', 'Chocolate', 'Red Velvet'],
    sizes: ['2kg', '3kg'],
    rating: 4.5,
    inStock: true,
  },
  {
    name: 'Diwali Mithai Fusion Cake',
    description: 'Festive cake with kaju katli layers, pistachio cream and gold dust.',
    category: 'SEASONAL',
    basePrice: 1699,
    imageUrl: '',
    flavors: ['Pistachio', 'Saffron'],
    sizes: ['500g', '1kg'],
    rating: 4.6,
    inStock: true,
  },
  {
    name: 'New Year Champagne Cake',
    description: 'Sparkling-themed champagne sponge with berry compote and gold accents.',
    category: 'SEASONAL',
    basePrice: 2199,
    imageUrl: '',
    flavors: ['Champagne', 'Berry'],
    sizes: ['1kg', '2kg'],
    rating: 4.5,
    inStock: true,
  },
  {
    name: 'Tiramisu Coffee Cake',
    description: 'Italian tiramisu layers with espresso soak and mascarpone cream.',
    category: 'BIRTHDAY',
    basePrice: 1149,
    imageUrl: '',
    flavors: ['Coffee', 'Mascarpone'],
    sizes: ['500g', '1kg'],
    rating: 4.8,
    inStock: true,
  },
  {
    name: 'Ferrero Rocher Dream Cake',
    description: 'Hazelnut chocolate cake with Ferrero Rocher topping and Nutella filling.',
    category: 'BIRTHDAY',
    basePrice: 1499,
    imageUrl: '',
    flavors: ['Hazelnut', 'Chocolate'],
    sizes: ['1kg', '2kg'],
    rating: 4.9,
    inStock: true,
  },
  {
    name: 'Pineapple Fresh Cream Cake',
    description: 'Light sponge with fresh pineapple chunks and whipped cream — all-time classic.',
    category: 'BIRTHDAY',
    basePrice: 799,
    imageUrl: '',
    flavors: ['Pineapple', 'Vanilla'],
    sizes: ['500g', '1kg', '2kg'],
    rating: 4.4,
    inStock: true,
  },
  {
    name: 'Rainbow Unicorn Cake',
    description: 'Colourful rainbow layers with unicorn horn topper — kids party favourite.',
    category: 'BIRTHDAY',
    basePrice: 1599,
    imageUrl: '',
    flavors: ['Vanilla', 'Mixed Fruit'],
    sizes: ['1kg', '1.5kg'],
    rating: 4.7,
    inStock: true,
  },
  {
    name: 'Belgian Chocolate Éclair Box',
    description: 'Premium chocolate éclairs filled with vanilla custard — box of 8.',
    category: 'CUPCAKE',
    basePrice: 649,
    imageUrl: '',
    flavors: ['Chocolate', 'Vanilla'],
    sizes: ['4 pcs', '8 pcs'],
    rating: 4.6,
    inStock: true,
  },
];

const CAKE_IMAGES = {
  'Chocolate Fudge Birthday Cake': 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80',
  'Vanilla Dream Wedding Cake': 'https://images.unsplash.com/photo-1535254973040-607b474cb50d?w=800&q=80',
  'Red Velvet Cupcake Box': 'https://images.unsplash.com/photo-1614707267537-b87a0323b629?w=800&q=80',
  'Custom Photo Cake': 'https://images.unsplash.com/photo-1563729787504-d2d5b1c7ee25?w=800&q=80',
  'Christmas Fruit Cake': 'https://images.unsplash.com/photo-1607926967395-65471121b817?w=800&q=80',
  'Strawberry Shortcake': 'https://images.unsplash.com/photo-1565958011703-14f058988770?w=800&q=80',
  'Black Forest Gateau': 'https://images.unsplash.com/photo-1621303833534-6d8927f4a978?w=800&q=80',
  'Butterscotch Crunch Cake': 'https://images.unsplash.com/photo-1586788680434-30d324b2d3ea?w=800&q=80',
  'Mango Alphonso Mousse Cake': 'https://images.unsplash.com/photo-1621961798959-8c0e40a4cde8?w=800&q=80',
  'Oreo Chocolate Overload': 'https://images.unsplash.com/photo-1606890736304-750ef4f5cbbb?w=800&q=80',
  'Gulab Jamun Fusion Cake': 'https://images.unsplash.com/photo-1589302168068-964664d93dc0?w=800&q=80',
  'Blueberry Cheesecake Jar': 'https://images.unsplash.com/photo-1533134242443-674d894fe966?w=800&q=80',
  'Chocolate Truffle Cupcake Box': 'https://images.unsplash.com/photo-1486427944299-d1955d23e34d?w=800&q=80',
  'Classic White Wedding Cake': 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=800&q=80',
  'Rose Gold Anniversary Cake': 'https://images.unsplash.com/photo-1464349095439-e9a21285b5f6?w=800&q=80',
  'Cartoon Theme Kids Cake': 'https://images.unsplash.com/photo-1542826438-be43ddbfc114?w=800&q=80',
  'Corporate Logo Cake': 'https://images.unsplash.com/photo-1558636508-e0db3814bd1d?w=800&q=80',
  'Diwali Mithai Fusion Cake': 'https://images.unsplash.com/photo-1607926967395-65471121b817?w=800&q=80',
  'New Year Champagne Cake': 'https://images.unsplash.com/photo-1576618148400-f54bed99fcfc?w=800&q=80',
  'Tiramisu Coffee Cake': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?w=800&q=80',
  'Ferrero Rocher Dream Cake': 'https://images.unsplash.com/photo-1606313564200-e75d5e30476e?w=800&q=80',
  'Pineapple Fresh Cream Cake': 'https://images.unsplash.com/photo-1588195538326-c5b1e5b80caa?w=800&q=80',
  'Rainbow Unicorn Cake': 'https://images.unsplash.com/photo-1563729787504-d2d5b1c7ee25?w=800&q=80',
  'Belgian Chocolate Éclair Box': 'https://images.unsplash.com/photo-1488477181946-6428a0291773?w=800&q=80',
};

for (const cake of CAKES) {
  if (CAKE_IMAGES[cake.name]) {
    cake.imageUrl = CAKE_IMAGES[cake.name];
  }
}

async function seed() {
  await connectDatabase();

  console.log('Seeding users...');
  const existingCustomer = await User.findOne({ email: 'customer@test.com' });

  if (!existingCustomer) {
    await User.create({
      name: 'Demo Customer',
      email: 'customer@test.com',
      phone: '+919876543210',
      passwordHash: await bcrypt.hash('test123', 10),
      role: 'CUSTOMER',
    });
    await User.create({
      name: 'Admin User',
      email: 'admin@cakeshop.com',
      phone: '+911234567890',
      passwordHash: await bcrypt.hash('admin123', 10),
      role: 'ADMIN',
    });
    console.log('Users created.');
  } else {
    console.log('Users already exist, skipping.');
  }

  console.log('Seeding cakes (prices in INR)...');
  for (const cake of CAKES) {
    await Cake.findOneAndUpdate({ name: cake.name }, cake, {
      upsert: true,
      new: true,
      setDefaultsOnInsert: true,
    });
  }
  const total = await Cake.countDocuments();
  console.log(`${CAKES.length} products in seed file · ${total} total in database.`);

  console.log('Seed complete!');
  process.exit(0);
}

seed().catch((err) => {
  console.error('Seed failed:', err);
  process.exit(1);
});

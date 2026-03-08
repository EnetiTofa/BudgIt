const List<String> commonNzBusinesses = [
  // Retail - General, Department & Big Box
  "The Warehouse",

  "Kmart",

  "Farmers",

  "Briscoes",

  "Rebel Sport",

  "Smiths City",

  "Bed Bath & Beyond",

  "Spotlight",

  "SaveMart",

  "EziBuy",

  "Postie",

  "Stevens",

  "acquisitions",

  // Retail - Fashion, Apparel & Footwear
  "Hallenstein Brothers",

  "Glassons",

  "Cotton On",

  "H&M",

  "Zara",

  "Nike",

  "Adidas",

  "Puma",

  "Skechers",

  "Converse",

  "Vans",

  "Dr. Martens",

  "Country Road",

  "Witchery",

  "Max",

  "Barkers",

  "Rodd & Gunn",

  "Kathmandu",

  "Macpac",

  "Icebreaker",

  "Swanndri",

  "Just Jeans",

  "Jay Jays",

  "Dotti",

  "Portmans",

  "Bendon",

  "Peter Alexander",

  "AS Colour",

  "Amazon Surf",

  "North Beach",

  "Billabong",

  "Quiksilver",

  "Rip Curl",

  "Boardertown",

  "Hannahs",

  "Number One Shoes",

  "Platypus Shoes",

  "Merchant 1948",

  "Mi Piaci",

  "Shoe Clinic",

  "The Athlete's Foot",

  // Retail - Electronics, Books & Specialty
  "Noel Leeming",

  "Harvey Norman",

  "JB Hi-Fi",

  "PB Tech",

  "Apple",

  "Samsung",

  "Microsoft",

  "Computer Lounge",

  "Mighty Ape",

  "Whitcoulls",

  "Paper Plus",

  "Warehouse Stationery",

  "Typo",

  "EB Games",

  "Zing Pop Culture",

  "Toyworld",

  "LEGO Store",

  "Jaycar Electronics",

  "Rockshop",

  "MusicWorks",

  "Michael Hill",

  "Pascoes the Jewellers",

  "Walker & Hall",

  "Pandora",

  "The Body Shop",

  "Lush",

  "Mecca",

  "Sephora",

  // Online Marketplaces & Retail
  "Trade Me",

  "Amazon",

  "eBay",

  "ASOS",

  "The Iconic",

  "AliExpress",

  "Etsy",

  "Shein",

  // Supermarkets, Grocery & Liquor
  "Woolworths New Zealand",

  "PAK'nSAVE",

  "New World",

  "Four Square",

  "FreshChoice",

  "SuperValue",

  "The Mad Butcher",

  "Farro Fresh",

  "Moore Wilson's",

  "Huckleberry",

  "Commonsense Organics",

  "Tai Ping Supermarket",

  "Liquorland",

  "Super Liquor",

  "The Bottle-O",

  "Glengarry Wines",

  // Hardware, Home & Garden
  "Bunnings Warehouse",

  "Mitre 10",

  "Placemakers",

  "ITM",

  "Guthrie Bowron",

  "Resene ColorShop",

  "Dulux",

  "Kings Plant Barn",

  "Palmers Garden Centre",

  "Oderings Garden Centre",

  "Stihl Shop",

  "Freedom Furniture",

  "Nood",

  "Early Settler",

  "Big Save Furniture",

  "Nick Scali Furniture",

  // Automotive & Petrol Stations
  "Z Energy",

  "BP",

  "Mobil",

  "Gull",

  "Waitomo",

  "Challenge",

  "Repco",

  "Supercheap Auto",

  "BNT",

  "Beaurepaires",

  "Tony's Tyre Service",

  "Midas",

  "Pit Stop",

  "VTNZ",

  "VINZ",

  "Bridgestone",

  "Novus Glass",

  "Smith & Smith",

  "Turners Cars",

  "2Cheap Cars",

  // Banks & Financial Services
  "ANZ",

  "ASB",

  "BNZ",

  "Westpac",

  "Kiwibank",

  "TSB Bank",

  "The Co-operative Bank",

  "Heartland Bank",

  "Rabobank",

  "HSBC",

  "Gem Finance",

  "Latitude Financial Services",

  "PayPal",

  "Sharesies",

  "Hatch",

  "Jarden",

  "Forsyth Barr",

  // Utilities & Communications
  "Spark",

  "One NZ",

  "2degrees",

  "Skinny",

  "Slingshot",

  "Orcon",

  "Contact Energy",

  "Mercury Energy",

  "Genesis Energy",

  "Meridian Energy",

  "Powershop",

  "Electric Kiwi",

  "Flick Electric Co.",

  "Vector",

  "Orion",

  "Chorus",

  // Restaurants, Cafes & Fast Food
  "McDonald's",

  "KFC",

  "Burger King",

  "Domino's",

  "Pizza Hut",

  "Subway",

  "Wendy's",

  "Carl's Jr.",

  "Hell Pizza",

  "Pita Pit",

  "St Pierre's Sushi",

  "Mad Mex",

  "Zambrero",

  "Taco Bell",

  "Nando's",

  "BurgerFuel",

  "Sal's Pizza",

  "The Coffee Club",

  "Starbucks",

  "Katsubi",

  "Columbus Coffee",

  "Coffee Culture",

  "Robert Harris Coffee Roasters",

  "Muffin Break",

  "Mojo Coffee",

  "Tank Juice",

  "Lone Star",

  "Cobb & Co",

  "Speight's Ale House",

  "Joe's Garage",

  "Denny's",

  "Wagamama",

  "Uber Eats",

  // Travel & Transport
  "Air New Zealand",

  "Jetstar",

  "Qantas",

  "Emirates",

  "Singapore Airlines",

  "Sounds Air",

  "Uber",

  "Ola",

  "DiDi",

  "InterCity",

  "Bluebridge Cook Strait Ferries",

  "Interislander",

  "Auckland Transport",

  "Metlink (Wellington)",

  "Metro (Christchurch)",

  "Hertz",

  "Avis",

  "Budget Rent a Car",

  "Europcar",

  "Go Rentals",

  "Jucy Rentals",

  "Maui Motorhomes",

  "Wilson Parking",

  "ParkMate",

  "Lime",

  "Beam",

  "Booking.com",

  "Expedia",

  "Airbnb",

  "Webjet",

  "House of Travel",

  "Flight Centre",

  // Health, Fitness & Pharmacy
  "Chemist Warehouse",

  "Unichem",

  "Life Pharmacy",

  "Bargain Chemist",

  "Health 2000",

  "Southern Cross Healthcare",

  "Lumino The Dentists",

  "Specsavers",

  "OPSM",

  "Bailey Nelson",

  "Triton Hearing",

  "Bay Audiology",

  "Les Mills",

  "CityFitness",

  "Jetts Fitness",

  "Snap Fitness",

  "Anytime Fitness",

  "F45 Training",

  // Entertainment, Media & Subscriptions
  "Event Cinemas",

  "HOYTS",

  "Reading Cinemas",

  "Sky TV",

  "Netflix",

  "Disney+",

  "Neon",

  "Amazon Prime Video",

  "Apple TV+",

  "Spotify",

  "Apple Music",

  "YouTube",

  "TVNZ",

  "ThreeNow",

  "NZME (for NZ Herald)",

  "Stuff",

  "Ticketmaster",

  "Ticketek",

  "Eventfinda",

  "SkyCity",

  "Te Papa Tongarewa",

  "Auckland Museum",

  "Kelly Tarlton's",

  "Rainbow's End",

  "Weta Workshop",

  "Google (Play Store, etc.)",

  "Sony (PlayStation)",

  "Xbox (Microsoft)",

  "Steam",

  // Services
  "NZ Post",

  "CourierPost",

  "DHL",

  "FedEx",

  "Aramex",

  "AA (Automobile Association)",

  "Barfoot & Thompson",

  "Harcourts",

  "Ray White",

  "Bayleys",

  "LJ Hooker",

  "Public Trust",

  "Green Acres",

  "Lawn Rite",

  // Insurance
  "Southern Cross",

  "AMI Insurance",

  "State Insurance",

  "AA Insurance",

  "Tower Insurance",

  "FMG (Farmers' Mutual Group)",

  "Vero",

  "Youi",

  "Cove Insurance",

  "TINZ (Travel Insurance NZ)",
];

import 'package:flutter/material.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A helper class to associate an icon with a searchable name.
class IconDefinition {
  final String name;
  final IconData icon;

  const IconDefinition({required this.name, required this.icon});
}

/// A central repository for all icons used within the app.
class AppIcons {
  static const IconData defaultIcon = Icons.label_outline;

  /// The main map of categorized icons, used to build the tabbed UI.
  static const Map<String, List<IconDefinition>> categorizedIcons = {
    'Food & Drink': _foodAndDrink,
    'Shopping': _shopping,
    'Travel & Transport': _travelAndTransport,
    'Home & Utilities': _homeAndUtilities,
    'Finance & Bills': _financeAndBills,
    'Health & Wellness': _healthAndWellness,
    'Entertainment': _entertainment,
    'Personal': _personal,
    'Tech & Brands': _techAndBrands,
    'Other': _other,
  };

  // --- Private Icon Lists by Category ---

  static const List<IconDefinition> _foodAndDrink = [
    IconDefinition(name: 'restaurant dining food', icon: Icons.restaurant_menu_outlined),
    IconDefinition(name: 'cafe coffee tea cup', icon: Icons.local_cafe_outlined),
    IconDefinition(name: 'fastfood burger fries', icon: Icons.fastfood_outlined),
    IconDefinition(name: 'bar drink alcohol cocktail', icon: Icons.local_bar_outlined),
    IconDefinition(name: 'cake dessert pastry birthday', icon: Icons.cake_outlined),
    IconDefinition(name: 'pizza slice italian', icon: EvaIcons.pieChartOutline),
    IconDefinition(name: 'ice cream gelato', icon: Icons.icecream_outlined),
    IconDefinition(name: 'grocery food carrot', icon: Icons.local_grocery_store_outlined),
    IconDefinition(name: 'bakery bread pretzel', icon: Icons.bakery_dining_outlined),
    IconDefinition(name: 'fish seafood', icon: Icons.set_meal_outlined),
    IconDefinition(name: 'ramen noodles soup', icon: Icons.ramen_dining_outlined),
    IconDefinition(name: 'wine bottle glass', icon: Icons.wine_bar_outlined),
    IconDefinition(name: 'tapas takeout', icon: Icons.tapas_outlined),
    IconDefinition(name: 'breakfast egg bacon', icon: Icons.breakfast_dining_outlined),
    IconDefinition(name: 'kebab bbq grill', icon: Icons.kebab_dining_outlined),
    IconDefinition(name: 'fruit apple pear', icon: EvaIcons.colorPaletteOutline),
  ];

  static const List<IconDefinition> _shopping = [
    IconDefinition(name: 'shopping cart online', icon: Icons.shopping_cart_outlined),
    IconDefinition(name: 'basket market', icon: Icons.shopping_basket_outlined),
    IconDefinition(name: 'bag purchase retail', icon: Icons.shopping_bag_outlined),
    IconDefinition(name: 'style clothes fashion apparel', icon: Icons.style_outlined),
    IconDefinition(name: 'mall department store', icon: Icons.local_mall_outlined),
    IconDefinition(name: 't-shirt clothing', icon: EvaIcons.shoppingBagOutline),
    IconDefinition(name: 'gift card present voucher', icon: Icons.card_giftcard_outlined),
    IconDefinition(name: 'tag price label discount sale', icon: EvaIcons.pricetagsOutline),
    IconDefinition(name: 'receipt proof of purchase', icon: Icons.receipt_outlined),
    IconDefinition(name: 'storefront shop boutique', icon: Icons.storefront_outlined),
    IconDefinition(name: 'credit card pay', icon: Icons.credit_card_outlined),
    IconDefinition(name: 'flower florist bouquet', icon: Icons.local_florist_outlined),
    IconDefinition(name: 'bookstore library books', icon: Icons.menu_book_outlined),
    IconDefinition(name: 'hardware tools', icon: Icons.hardware_outlined),
    IconDefinition(name: 'pharmacy drugstore', icon: Icons.local_pharmacy_outlined),
    IconDefinition(name: 'furniture home decor', icon: Icons.chair_outlined),
    IconDefinition(name: 'jewelry ring diamond', icon: EvaIcons.sunOutline),
  ];

  static const List<IconDefinition> _travelAndTransport = [
    IconDefinition(name: 'car auto vehicle ride', icon: Icons.directions_car_outlined),
    IconDefinition(name: 'gas station fuel petrol', icon: Icons.local_gas_station_outlined),
    IconDefinition(name: 'train subway metro rail', icon: Icons.train_outlined),
    IconDefinition(name: 'bus public transport coach', icon: Icons.directions_bus_outlined),
    IconDefinition(name: 'taxi cab lyft uber', icon: Icons.local_taxi_outlined),
    IconDefinition(name: 'flight plane airport travel', icon: Icons.flight_outlined),
    IconDefinition(name: 'boat ship ferry cruise', icon: Icons.directions_boat_outlined),
    IconDefinition(name: 'bicycle bike cycling', icon: Icons.pedal_bike_outlined),
    IconDefinition(name: 'motorcycle scooter', icon: Icons.motorcycle_outlined),
    IconDefinition(name: 'hotel motel accommodation bed', icon: Icons.hotel_outlined),
    IconDefinition(name: 'luggage suitcase bag', icon: Icons.luggage_outlined),
    IconDefinition(name: 'passport visa identity', icon: EvaIcons.personOutline),
    IconDefinition(name: 'map navigation directions location', icon: Icons.map_outlined),
    IconDefinition(name: 'parking', icon: Icons.local_parking_outlined),
    IconDefinition(name: 'ev station electric car charging', icon: Icons.ev_station_outlined),
    IconDefinition(name: 'tramway', icon: Icons.tram_outlined),
    IconDefinition(name: 'sailing sailboat', icon: Icons.sailing_outlined),
  ];

  static const List<IconDefinition> _homeAndUtilities = [
    IconDefinition(name: 'home house mortgage property', icon: Icons.home_outlined),
    IconDefinition(name: 'lightbulb electricity power', icon: Icons.lightbulb_outline),
    IconDefinition(name: 'water drop utility bill', icon: Icons.water_drop_outlined),
    IconDefinition(name: 'wifi internet broadband', icon: Icons.wifi_outlined),
    IconDefinition(name: 'phone mobile cell plan', icon: Icons.phone_iphone_outlined),
    IconDefinition(name: 'power plug socket', icon: Icons.power_outlined),
    IconDefinition(name: 'tv television cable streaming', icon: Icons.tv_outlined),
    IconDefinition(name: 'key rent lease locksmith', icon: Icons.vpn_key_outlined),
    IconDefinition(name: 'cleaning broom mop vacuum', icon: Icons.cleaning_services_outlined),
    IconDefinition(name: 'laundry washing machine', icon: EvaIcons.pantoneOutline),
    IconDefinition(name: 'gardening plant lawn', icon: Icons.yard_outlined),
    IconDefinition(name: 'tools diy repair', icon: Icons.build_outlined),
    IconDefinition(name: 'heating ac air conditioning', icon: Icons.hvac_outlined),
    IconDefinition(name: 'recycling trash waste', icon: Icons.recycling_outlined),
    IconDefinition(name: 'sofa couch furniture', icon: Icons.chair_alt_outlined),
    IconDefinition(name: 'plumbing pipe faucet', icon: Icons.plumbing_outlined),
  ];

  static const List<IconDefinition> _financeAndBills = [
    IconDefinition(name: 'receipt bill transaction', icon: Icons.receipt_long_outlined),
    IconDefinition(name: 'credit card payment plastic', icon: Icons.credit_card_outlined),
    IconDefinition(name: 'bank account transfer banking', icon: Icons.account_balance_outlined),
    IconDefinition(name: 'invoice quote fee', icon: Icons.request_quote_outlined),
    IconDefinition(name: 'paid money cash currency', icon: Icons.paid_outlined),
    IconDefinition(name: 'savings piggy bank investment', icon: Icons.savings_outlined),
    IconDefinition(name: 'chart graph stocks market', icon: Icons.bar_chart_outlined),
    IconDefinition(name: 'atm withdrawal cash machine', icon: Icons.atm_outlined),
    IconDefinition(name: 'wallet purse', icon: Icons.account_balance_wallet_outlined),
    IconDefinition(name: 'insurance health life car', icon: Icons.health_and_safety_outlined),
    IconDefinition(name: 'loan debt mortgage', icon: EvaIcons.trendingUp),
    IconDefinition(name: 'tax government', icon: Icons.price_check_outlined),
    IconDefinition(name: 'coins change', icon: EvaIcons.award),
    IconDefinition(name: 'calculator math budget', icon: Icons.calculate_outlined),
  ];

  static const List<IconDefinition> _healthAndWellness = [
    IconDefinition(name: 'medical doctor hospital physician', icon: Icons.medical_services_outlined),
    IconDefinition(name: 'fitness center gym workout exercise', icon: Icons.fitness_center_outlined),
    IconDefinition(name: 'spa wellness massage relaxation', icon: Icons.spa_outlined),
    IconDefinition(name: 'monitor heart health cardiology', icon: Icons.monitor_heart_outlined),
    IconDefinition(name: 'pharmacy pills medicine prescription', icon: EvaIcons.thermometerOutline),
    IconDefinition(name: 'first aid cross emergency', icon: EvaIcons.plusCircleOutline),
    IconDefinition(name: 'dentist tooth dental', icon: EvaIcons.activity),
    IconDefinition(name: 'running jogging cardio', icon: Icons.directions_run_outlined),
    IconDefinition(name: 'meditation yoga mental health', icon: Icons.self_improvement_outlined),
    IconDefinition(name: 'ambulance emergency services', icon: Icons.emergency_outlined),
    IconDefinition(name: 'psychology therapy counseling', icon: Icons.psychology_outlined),
    IconDefinition(name: 'glasses eyewear optician', icon: EvaIcons.eyeOutline),
    IconDefinition(name: 'weight scale', icon: Icons.monitor_weight_outlined),
  ];

  static const List<IconDefinition> _entertainment = [
      IconDefinition(name: 'theaters movie film cinema', icon: Icons.theaters_outlined),
      IconDefinition(name: 'sports games gaming esports', icon: Icons.sports_esports_outlined),
      IconDefinition(name: 'music note song concert album', icon: Icons.music_note_outlined),
      IconDefinition(name: 'ticket activity event admission', icon: Icons.local_activity_outlined),
      IconDefinition(name: 'attractions theme park amusement', icon: Icons.attractions_outlined),
      IconDefinition(name: 'beach vacation holiday sand sun', icon: Icons.beach_access_outlined),
      IconDefinition(name: 'book library reading novel', icon: Icons.book_outlined),
      IconDefinition(name: 'controller joystick console', icon: EvaIcons.videoOutline),
      IconDefinition(name: 'camera photography photo', icon: Icons.camera_alt_outlined),
      IconDefinition(name: 'art museum gallery painting', icon: Icons.palette_outlined),
      IconDefinition(name: 'hiking trekking mountains nature', icon: Icons.hiking_outlined),
      IconDefinition(name: 'dice board games gambling', icon: EvaIcons.cubeOutline),
      IconDefinition(name: 'celebration party confetti', icon: Icons.celebration_outlined),
      IconDefinition(name: 'nightclub dance dj', icon: Icons.nightlife_outlined),
      IconDefinition(name: 'stadium sports concert', icon: Icons.stadium_outlined),
  ];

  static const List<IconDefinition> _personal = [
    IconDefinition(name: 'haircut salon barber grooming', icon: Icons.content_cut_outlined),
    IconDefinition(name: 'beauty cosmetics makeup skincare', icon: Icons.face_retouching_natural_outlined),
    IconDefinition(name: 'pets dog cat animal vet', icon: Icons.pets_outlined),
    IconDefinition(name: 'school education college tuition', icon: Icons.school_outlined),
    IconDefinition(name: 'child care kids baby daycare', icon: Icons.child_care_outlined),
    IconDefinition(name: 'charity donation favorite giving', icon: Icons.favorite_outline),
    IconDefinition(name: 'family parents children', icon: Icons.people_outline),
    IconDefinition(name: 'wedding marriage ceremony', icon: FontAwesomeIcons.ring),
    IconDefinition(name: 'graduation diploma university', icon: EvaIcons.awardOutline),
    IconDefinition(name: 'hobbies hobby', icon: Icons.interests_outlined),
    IconDefinition(name: 'laundry dry cleaning', icon: Icons.local_laundry_service_outlined),
    IconDefinition(name: 'postage stamps mail', icon: Icons.local_post_office_outlined),
    IconDefinition(name: 'subscription recurring service', icon: Icons.subscriptions_outlined),
  ];

  static const List<IconDefinition> _techAndBrands = [
    IconDefinition(name: 'youtube', icon: FontAwesomeIcons.youtube),
    IconDefinition(name: 'apple', icon: FontAwesomeIcons.apple),
    IconDefinition(name: 'spotify', icon: FontAwesomeIcons.spotify),
    IconDefinition(name: 'amazon', icon: FontAwesomeIcons.amazon),
    IconDefinition(name: 'google', icon: FontAwesomeIcons.google),
    IconDefinition(name: 'visa', icon: FontAwesomeIcons.ccVisa),
    IconDefinition(name: 'paypal', icon: FontAwesomeIcons.paypal),
    IconDefinition(name: 'facebook meta', icon: FontAwesomeIcons.facebook),
    IconDefinition(name: 'microsoft windows', icon: FontAwesomeIcons.microsoft),
    IconDefinition(name: 'x twitter', icon: FontAwesomeIcons.xTwitter),
    IconDefinition(name: 'snapchat', icon: FontAwesomeIcons.snapchat),
    IconDefinition(name: 'linkedin', icon: FontAwesomeIcons.linkedin),
    IconDefinition(name: 'reddit', icon: FontAwesomeIcons.redditAlien),
    IconDefinition(name: 'pinterest', icon: FontAwesomeIcons.pinterest),
    IconDefinition(name: 'tiktok', icon: FontAwesomeIcons.tiktok),
    IconDefinition(name: 'instagram', icon: FontAwesomeIcons.instagram),
    IconDefinition(name: 'netflix', icon: EvaIcons.filmOutline),
    IconDefinition(name: 'discord', icon: EvaIcons.messageCircleOutline),
    IconDefinition(name: 'twitch', icon: FontAwesomeIcons.twitch),
    IconDefinition(name: 'disney', icon: FontAwesomeIcons.fortAwesome),
    IconDefinition(name: 'playstation sony', icon: FontAwesomeIcons.playstation),
    IconDefinition(name: 'xbox', icon: FontAwesomeIcons.xbox),
    IconDefinition(name: 'steam', icon: FontAwesomeIcons.steam),
    IconDefinition(name: 'android', icon: FontAwesomeIcons.android),
  ];

  static const List<IconDefinition> _other = [
    IconDefinition(name: 'work office business', icon: Icons.business_center_outlined),
    IconDefinition(name: 'leaf nature environment ecology', icon: Icons.eco_outlined),
    IconDefinition(name: 'security lock insurance safety', icon: Icons.security_outlined),
    IconDefinition(name: 'briefcase portfolio project', icon: EvaIcons.briefcaseOutline),
    IconDefinition(name: 'calendar date event appointment', icon: EvaIcons.calendarOutline),
    IconDefinition(name: 'flag country nation', icon: Icons.flag_outlined),
    IconDefinition(name: 'law legal court government', icon: Icons.gavel_outlined),
    IconDefinition(name: 'science lab chemistry flask', icon: Icons.science_outlined),
    IconDefinition(name: 'weather sun cloud rain snow', icon: Icons.cloud_outlined),
    IconDefinition(name: 'construction hammer wrench', icon: Icons.construction_outlined),
    IconDefinition(name: 'fire flame', icon: Icons.local_fire_department_outlined),
    IconDefinition(name: 'miscellaneous other', icon: Icons.more_horiz_outlined),
    IconDefinition(name: 'sync synchronize', icon: EvaIcons.sync),
    IconDefinition(name: 'archive box', icon: EvaIcons.archiveOutline),
  ];

  /// A flattened list of all icons for global searching.
  static final List<IconDefinition> allIcons = categorizedIcons.values.expand((list) => list).toList();
}
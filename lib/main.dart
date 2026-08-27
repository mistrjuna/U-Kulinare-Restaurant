import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() {
  runApp(const KulinareApp());
}

class KulinareApp extends StatelessWidget {
  const KulinareApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definice reálných firemních barev z grafiky
    const goldColor = Color(0xFFC5A869);
    const darkColor = Color(0xFF1A1A1A);
    const lightBg = Color(0xFFF7F5F0);

    return MaterialApp(
      title: 'U Kulináře',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: lightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: goldColor,
          primary: goldColor,
          onPrimary: Colors.white,
          primaryContainer: goldColor.withOpacity(0.2),
          onPrimaryContainer: darkColor,
          secondaryContainer: darkColor,
          onSecondaryContainer: Colors.white,
          surface: Colors.white,
          background: lightBg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBg,
          foregroundColor: darkColor,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const WeeklyDailyMenuPage(),
    const StandardMenuPage(),
    const ContactPage(),
    const ReservationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildSplitFloatingBar(),
    );
  }

  Widget _buildSplitFloatingBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(40),
              color: const Color(0xFF1A1A1A),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildIconItem(0, Icons.restaurant),
                    const SizedBox(width: 4),
                    _buildIconItem(1, Icons.menu_book),
                    const SizedBox(width: 4),
                    _buildIconItem(2, Icons.phone),
                  ],
                ),
              ),
            ),
            Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFFC5A869),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => setState(() => _currentIndex = 3),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.calendar_month,
                    color: _currentIndex == 3 ? Colors.white : Colors.white70,
                    size: 26,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(int index, IconData iconData) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFC5A869) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          iconData,
          color: isSelected ? Colors.white : Colors.white54,
          size: 26,
        ),
      ),
    );
  }
}

class HeaderLogo extends StatelessWidget {
  const HeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60.0, bottom: 20.0),
        child: Image.network(
          'image_e228ab.png',
          height: 70,
          errorBuilder: (context, error, stackTrace) => Column(
            children: [
              const Text(
                'U KULINÁŘE',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: Color(0xFF1A1A1A)),
              ),
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                color: const Color(0xFFC5A869),
                child: const Text(
                  'RESTAURANT & PENSION',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// 1. POLEDNÍ MENU VČETNĚ NAPOJENÍ NA MENICKA.CZ
class WeeklyDailyMenuPage extends StatelessWidget {
  const WeeklyDailyMenuPage({super.key});

  Future<List<Map<String, String>>> fetchTodayMenicka() async {
    final url = Uri.parse('https://www.menicka.cz/api/iframe/?id=6405');
    List<Map<String, String>> menu = [];

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        },
      );

      if (response.statusCode == 200) {
        // Dekódování češtiny z latin1/windows-1250
        String responseBody = latin1.decode(response.bodyBytes);
        var document = parser.parse(responseBody);

        var jidla = document.querySelectorAll('.menicka');

        for (var jidlo in jidla) {
          String nazev = jidlo.querySelector('.nazev')?.text.trim() ?? '';
          String cena = jidlo.querySelector('.cena')?.text.trim() ?? '';

          if (nazev.isNotEmpty) {
            menu.add({'title': nazev, 'price': cena});
          }
        }
        return menu;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentWeekday = DateTime.now().weekday;
    final List<String> days = [
      "Pondělí",
      "Úterý",
      "Středa",
      "Čtvrtek",
      "Pátek"
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const HeaderLogo(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Text('Týdenní menu',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 8),
        ...List.generate(5, (index) {
          final int dayIndex = index + 1;
          final bool isToday = dayIndex == currentWeekday;
          final String dayName = days[index];

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: isToday,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                collapsedShape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Row(
                  children: [
                    Text(
                      dayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                        color: isToday
                            ? const Color(0xFFC5A869)
                            : const Color(0xFF1A1A1A),
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC5A869),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text("DNES",
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      )
                    ]
                  ],
                ),
                children: [
                  if (isToday)
                    FutureBuilder<List<Map<String, String>>>(
                      future: fetchTodayMenicka(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFFC5A869))),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                                'Dnešní menu se nepodařilo načíst z Menicka.cz.',
                                style: TextStyle(color: Colors.grey)),
                          );
                        }
                        return Column(
                          children: snapshot.data!
                              .map((item) => Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 16, bottom: 12),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                            child: Text(item['title']!,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500))),
                                        const SizedBox(width: 16),
                                        Text(item['price']!,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFC5A869))),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text("Menu pro tento den se připravuje...",
                          style: TextStyle(color: Colors.grey)),
                    )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

// 2. STÁLÝ LÍSTEK
class StandardMenuPage extends StatefulWidget {
  const StandardMenuPage({super.key});

  @override
  State<StandardMenuPage> createState() => _StandardMenuPageState();
}

class _StandardMenuPageState extends State<StandardMenuPage> {
  String selectedCategory = "Polévky";

  final List<String> categories = [
    "Polévky",
    "Saláty",
    "Pinsa",
    "Hlavní chod",
    "Burgery",
    "Mexico",
    "Speciality z grilu",
    "Přílohy & Omáčky",
    "Žvanec k pivu",
    "Dezerty"
  ];

  final Map<String, String> allergensMap = {
    'A1a':
        'Obiloviny obsahující lepek a výrobky z nich (nejedná se o celiakii)',
    'A2': 'Korýši a výrobky z nich',
    'A3': 'Vejce a výrobky z nich',
    'A4': 'Ryby a výrobky z nich',
    'A5': 'Podzemnice olejná (arašídy) a výrobky z nich',
    'A6': 'Sójové boby (sója) a výrobky z nich',
    'A7': 'Mléko a výrobky z něj',
    'A8': 'Skořápkové plody a výrobky z nich (všechny druhy ořechů)',
    'A9': 'Celer a výrobky z něj',
    'A10': 'Hořčice a výrobky z ní',
    'A11': 'Sezamová semena a výrobky z nich',
    'A12': 'Oxid siřičitý a siřičitany',
    'A13': 'Vlčí bob (lupina) a výrobky z něj',
    'A14': 'Měkkýši a výrobky z nich',
  };

  final List<Map<String, dynamic>> allItems = [
    {
      "category": "Polévky",
      "name": "Sopa de frijoles negros",
      "desc":
          "ostrá fazolová polévka s chilli, čokoláda, zakysaná smetana, tortillové chipsy",
      "price": "85 Kč",
      "allergens": ["A7"]
    },
    {
      "category": "Polévky",
      "name": "Gulášová polévka",
      "desc": "vepřové a hovězí maso, brambory, kořenová zelenina",
      "price": "75 Kč",
      "allergens": ["A1a", "A9"]
    },
    {
      "category": "Saláty",
      "name": "Salát Coleslaw",
      "desc": "bílé zelí, smetana, cibule, kořenová zelenina (200g)",
      "price": "99 Kč",
      "allergens": ["A7", "A9"]
    },
    {
      "category": "Saláty",
      "name": "Variace salátů",
      "desc":
          "s grilovaným hermelínem, blue cheese dip, cibulové kroužky (200g)",
      "price": "259 Kč",
      "allergens": ["A1a", "A4", "A9"]
    },
    {
      "category": "Saláty",
      "name": "Caesar salát",
      "desc":
          "ančovičkový dresink, grilované kuřecí prso, slanina, parmazán, opečený toast (200g)",
      "price": "265 Kč",
      "allergens": ["A1a", "A3", "A4", "A7", "A10"]
    },
    {
      "category": "Pinsa",
      "name": "Pinsa Margherita",
      "desc":
          "rajčatové sugo, mozarella, rukola, cherry rajčata, olivový olej, balsamico",
      "price": "269 Kč",
      "allergens": ["A1a", "A4", "A9"]
    },
    {
      "category": "Pinsa",
      "name": "Pinsa s hermelínem",
      "desc":
          "bazalkové pesto s pistáciemi, hermelín, mozzarella, brusinky, parmská šunka, bazalka, olivový olej",
      "price": "289 Kč",
      "allergens": ["A1a", "A4", "A9"]
    },
    {
      "category": "Pinsa",
      "name": "Pinsa Prosciutto Crudo",
      "desc":
          "rajčatové sugo, mozzarella, parmská šunka, rukola, cherry rajčata, parmazán, olivový olej, balsamico",
      "price": "299 Kč",
      "allergens": ["A1a", "A4", "A9"]
    },
    {
      "category": "Hlavní chod",
      "name": "Vepřová líčka",
      "desc": "na černém pivě, špekové knedlíky, kyselá červená cibulka (200g)",
      "price": "269 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Hlavní chod",
      "name": "Konfitované kachní stehno",
      "desc": "červené zelí, bramborové knedlíky (1ks)",
      "price": "285 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Hlavní chod",
      "name": "Pečená vepřová žebra",
      "desc": "zelný salát, BBQ omáčka, opečené pečivo (500g)",
      "price": "399 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Hlavní chod",
      "name": "Smažené řízečky z vepřové panenky",
      "desc": "restované brambory, zelný salát (200g)",
      "price": "299 Kč",
      "allergens": ["A1a", "A3", "A7", "A9"]
    },
    {
      "category": "Hlavní chod",
      "name": "Smažený kuřecí řízek",
      "desc": "restované brambory, malý míchaný salátek (200g)",
      "price": "249 Kč",
      "allergens": ["A1a", "A3", "A7", "A9"]
    },
    {
      "category": "Hlavní chod",
      "name": "Farmářské hranolky s trhaným masem",
      "desc":
          "vepřové maso, červené zelí, rukola, BBQ omáčka, chipotle majonéza (100g)",
      "price": "229 Kč",
      "allergens": ["A3", "A6"]
    },
    {
      "category": "Burgery",
      "name": "Bacon Burger",
      "desc":
          "mleté hovězí maso, opečená slanina, chipotle majonéza, BBQ omáčka, kyselé okurky, rajče, salát, hranolky (200g)",
      "price": "299 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Burgery",
      "name": "Cheese Burger",
      "desc":
          "mleté hovězí maso, chedar, chipotle majonéza, BBQ omáčka, rajče, salát, hranolky (200g)",
      "price": "299 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Burgery",
      "name": "Texas Burger",
      "desc":
          "mleté hovězí maso, opečená slanina, chedar, chipotle majonéza, BBQ omáčka, jalapenos papričky, rajče, salát, cibulové kroužky, hranolky (200g)",
      "price": "329 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Burgery",
      "name": "Farmářský Burger",
      "desc":
          "mleté hovězí maso, opečená slanina, chipotle majonéza, sázené vejce, cibulové kroužky, kyselé okurky, rajče, salát, hranolky (200g)",
      "price": "339 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Burgery",
      "name": "Beef Burger",
      "desc":
          "trhané konfitované hovězí maso s cibulovou marmeládou, chipotle majonéza, BBQ omáčka, salát, kyselé okurky, opečená slanina, rajče, hranolky (200g)",
      "price": "339 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Burgery",
      "name": "Molten Smash Burger",
      "desc":
          "mleté hovězí maso, slaninová marmeláda, chipotle majonéza, BBQ omáčka, chedar, opečená slanina, kyselé okurky, rajče, salát, hranolky, chedarová omáčka (200g)",
      "price": "369 Kč",
      "allergens": ["A1a", "A3", "A6", "A7"]
    },
    {
      "category": "Mexico",
      "name": "Quesadillas de pollo",
      "desc":
          "opečená pšeničná tortilla, trhané kuřecí maso, sýr, jalapenos papričky, BBQ omáčka, podáváme se salátem a dipem ze zakysané smetany s česnekem a chilli (1ks)",
      "price": "289 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Mexico",
      "name": "Flautas",
      "desc":
          "smažené pšeničné tortilly, trhané kuřecí maso, sýr, podáváme se salátem a dipem ze zakysané smetany s česnekem a chilli (2ks)",
      "price": "289 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Mexico",
      "name": "Enchiladas",
      "desc":
          "pšeničné tortilly, trhané kuřecí maso, ostrá omáčka Verde, salát, balkánský sýr, jalapenos papričky, dip ze zakysané smetany s česnekem a chilli (3ks)",
      "price": "289 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Mexico",
      "name": "Tacos",
      "desc":
          "kukuřičné tortilly, ostré trhané vepřové maso, kyselá červená cibulka, jalapenos papričky, balkánský sýr, guacamole dip, salát (3ks)",
      "price": "319 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Mexico",
      "name": "Fajitas",
      "desc":
          "grilovaný filírovaný hovězí rump steak, cibule, paprika, pikantní koření, salsa guacamole, ostrá rajčatová a smetanová s česnekem a chilli, opečené tortilly, jalapenos papričky, tortillové chipsy (pro dvě osoby) (300g)",
      "price": "849 Kč",
      "allergens": ["A1a", "A7"]
    },
    {
      "category": "Speciality z grilu",
      "name": "Kuřecí prso s grilovanou zeleninou",
      "desc": "bazalkové pesto a rukola (200g)",
      "price": "289 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Speciality z grilu",
      "name": "Filírovaná vepřová panenka sous vide",
      "desc": "fazolové lusky a demi glace (200g)",
      "price": "349 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Speciality z grilu",
      "name": "Duroc Steak",
      "desc": "vepřová kotleta se smetanovou omáčkou a zeleným pepřem (300g)",
      "price": "299 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Speciality z grilu",
      "name": "Hovězí Rump Steak",
      "desc": "fazolové lusky a demi glace (300g)",
      "price": "599 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Speciality z grilu",
      "name": "Hovězí Rib Eye Steak",
      "desc": "fazolové lusky a demi glace (300g)",
      "price": "699 Kč",
      "allergens": ["A1a", "A6", "A7"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Restované brambory",
      "desc": "(150g)",
      "price": "65 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Hranolky",
      "desc": "(150g)",
      "price": "65 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Farmářské hranolky",
      "desc": "(150g)",
      "price": "69 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Opečená ciabatta",
      "desc": "(6ks)",
      "price": "75 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Fazolové lusky s cibulí a slaninou",
      "desc": "(200g)",
      "price": "119 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Grilovaná zelenina",
      "desc": "(200g)",
      "price": "119 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Malý zeleninový salát",
      "desc": "(100g)",
      "price": "99 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Pečivo",
      "desc": "(1ks)",
      "price": "10 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Demi glace s červeným vínem",
      "desc": "",
      "price": "90 Kč",
      "allergens": ["A9", "A12"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Smetanová omáčka se zeleným pepřem",
      "desc": "",
      "price": "80 Kč",
      "allergens": ["A1a", "A6", "A7", "A12"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Tatarská omáčka",
      "desc": "",
      "price": "35 Kč",
      "allergens": ["A3", "A10", "A12"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "BBQ omáčka",
      "desc": "",
      "price": "35 Kč",
      "allergens": ["A6", "A9"]
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Salsa dle výběru",
      "desc": "",
      "price": "35 Kč",
      "allergens": []
    },
    {
      "category": "Přílohy & Omáčky",
      "name": "Kečup",
      "desc": "",
      "price": "35 Kč",
      "allergens": ["A1a", "A6"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Hovězí tatarák à la chef",
      "desc":
          "lanýžový olej, česnekové aioli, variace salátů, parmazán, topinky (120g)",
      "price": "249 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Pikantní kuřecí křidélka",
      "desc":
          "marinovaná v chilli omáčce, dip ze zakysané smetany s česnekem a chilli (300g)",
      "price": "239 Kč",
      "allergens": ["A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Utopenec",
      "desc": "s cibulí, feferonkou a pečivem (100g)",
      "price": "119 Kč",
      "allergens": ["A1a", "A3"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Rillettes",
      "desc":
          "pečené trhané vepřové maso ve vlastní šťávě, opečené pečivo (100g)",
      "price": "139 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Paštika z kachních jater",
      "desc": "s máslem, opečené pečivo (100g)",
      "price": "129 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Naložený sýr",
      "desc": "bazalka, olivy, chilli papričky, pečivo (100g)",
      "price": "119 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Buffalo hranolky",
      "desc": "zapečené se slaninou, sýr, BBQ omáčka, blue cheese dip (100g)",
      "price": "159 Kč",
      "allergens": ["A6", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "BBQ Chips",
      "desc": "smažené bramborové lupínky, BBQ omáčka (150g)",
      "price": "99 Kč",
      "allergens": ["A6"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Smažené cibulové kroužky",
      "desc": "dip ze zakysané smetany s česnekem a chilli (200g)",
      "price": "149 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Tortilové chipsy",
      "desc": "se sýrovou, nebo rajčatovou omáčkou (150g)",
      "price": "149 Kč",
      "allergens": ["A6", "A7"]
    },
    {
      "category": "Žvanec k pivu",
      "name": "Nachos Guacamole",
      "desc":
          "tortillové chipsy se sýrem, BBQ omáčka, kukuřice, jalapenos papričky, kyselá červená cibulka, salsa pico de gallo, guacamole (100g)",
      "price": "179 Kč",
      "allergens": ["A6"]
    },
    {
      "category": "Dezerty",
      "name": "Čokoládový fondán",
      "desc": "ovocná omáčka, zmrzlina",
      "price": "159 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Dezerty",
      "name": "Americké lívance",
      "desc": "javorový sirup, sladká zakysaná smetana",
      "price": "149 Kč",
      "allergens": ["A1a", "A3", "A7"]
    },
    {
      "category": "Dezerty",
      "name": "Zmrzlina",
      "desc": "(1 kopeček)",
      "price": "40 Kč",
      "allergens": ["A7"]
    },
  ];

  void _showAllergenDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFFC5A869)),
              const SizedBox(width: 8),
              Text('Alergen $code',
                  style: const TextStyle(color: Color(0xFF1A1A1A))),
            ],
          ),
          content: Text(
            allergensMap[code] ?? 'Neznámý alergen',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ZAVŘÍT',
                  style: TextStyle(
                      color: Color(0xFFC5A869), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems =
        allItems.where((item) => item['category'] == selectedCategory).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const HeaderLogo(),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text('Stálý lístek',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A))),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: categories.map((cat) {
              final isSelected = selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat,
                    style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF1A1A1A),
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                onSelected: (bool selected) {
                  setState(() => selectedCategory = cat);
                },
                selectedColor: const Color(0xFFC5A869),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: isSelected
                          ? const Color(0xFFC5A869)
                          : Colors.black12),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        ...filteredItems.map((item) {
          final List<String> itemAllergens =
              List<String>.from(item['allergens'] ?? []);
          final String desc = item['desc']?.toString() ?? '';

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Text(item['name']!,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A)))),
                    Text(item['price']!,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC5A869))),
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(desc,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3)),
                ],
                if (itemAllergens.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: itemAllergens
                        .map((code) => GestureDetector(
                              onTap: () => _showAllergenDialog(context, code),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFF1A1A1A).withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(code,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A1A))),
                              ),
                            ))
                        .toList(),
                  )
                ]
              ],
            ),
          );
        }),
      ],
    );
  }
}

// 3. REZERVACE
class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  DateTime? selectedDate;

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFC5A869),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bool isToday = selectedDate != null &&
        selectedDate!.year == now.year &&
        selectedDate!.month == now.month &&
        selectedDate!.day == now.day;

    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const HeaderLogo(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Rezervace stolu',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon:
                    const Icon(Icons.calendar_today, color: Color(0xFFC5A869)),
                label: Text(
                  selectedDate == null
                      ? 'Vyberte datum rezervace'
                      : '${selectedDate!.day}. ${selectedDate!.month}. ${selectedDate!.year}',
                  style: const TextStyle(
                      color: Color(0xFF1A1A1A), fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFC5A869), width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              if (isToday)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.phone_in_talk,
                          size: 48, color: Color(0xFFC5A869)),
                      SizedBox(height: 16),
                      Text(
                        'Rezervace na dnešek prosím volejte přímo do restaurace na tel.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      Text('379 482 328',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFC5A869))),
                    ],
                  ),
                )
              else if (selectedDate != null)
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Jméno a příjmení',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          labelText: 'E-mailová adresa',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                    labelText: 'Počet osob',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none)))),
                        const SizedBox(width: 16),
                        Expanded(
                            child: TextField(
                                decoration: InputDecoration(
                                    labelText: 'Čas příchodu (např. 18:30)',
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide.none)))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                          labelText: 'Předpokládaný čas strávený v restauraci',
                          hintText: 'např. 2 hodiny',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Rezervace odeslána na ukulinare@seznam.cz a potvrzení na váš e-mail.'),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          backgroundColor: const Color(0xFFC5A869),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Odeslat rezervaci',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// 4. KONTAKTNÍ STRÁNKA
class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 120),
      children: [
        const HeaderLogo(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kontakt & Kde nás najdete',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 16),

              // Kartička s adresou a telefonem
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFC5A869)),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('Náměstí Míru 51, 344 01 Domažlice',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Color(0xFFC5A869)),
                        SizedBox(width: 12),
                        Text('+420 379 482 328',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.email, color: Color(0xFFC5A869)),
                        SizedBox(width: 12),
                        Text('ukulinare@seznam.cz',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Otevírací doba
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_filled,
                            color: Color(0xFFC5A869)),
                        SizedBox(width: 12),
                        Text('Otevírací doba',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pondělí – Čtvrtek',
                            style: TextStyle(fontSize: 15)),
                        Text('10:30 – 22:00',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Pátek – Sobota', style: TextStyle(fontSize: 15)),
                        Text('10:30 – 23:00',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Neděle', style: TextStyle(fontSize: 15)),
                        Text('11:00 – 21:00',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:tikme/l10n/cupertino_localizations_so.dart';
import 'package:tikme/l10n/material_localizations_so.dart';
import 'package:tikme/screens/DeepLinkVideoScreen.dart';
import 'package:tikme/screens/add_video_screen.dart';
import 'package:tikme/screens/feed_screen.dart';
import 'package:tikme/screens/inbox_screen.dart';
import 'package:tikme/screens/login_screen.dart';
import 'package:tikme/screens/profile_screen.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/providers/theme_provider.dart';
import 'package:tikme/providers/language_provider.dart';
import 'package:tikme/services/chat_service.dart';
import 'package:tikme/services/storage_service.dart';
import 'package:tikme/theme/theme.dart';
import 'package:app_links/app_links.dart';

// Global key for accessing router state
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// GoRouter configuration
GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/feed',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return HomeScreen(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            redirect: (BuildContext context, GoRouterState state) async {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              if (!authService.isSignedIn) {
                return '/login';
              }
              // Check if we have a saved route and redirect to it
              final lastRoute = await StorageService.getLastRoute();
              if (lastRoute != null &&
                  lastRoute != '/' &&
                  lastRoute != '/feed') {
                return lastRoute;
              }
              return null; // Stay on the current path (which defaults to /feed)
            },
            builder: (BuildContext context, GoRouterState state) {
              return const FeedScreen();
            },
          ),
          GoRoute(
            path: '/feed',
            builder: (BuildContext context, GoRouterState state) {
              return const FeedScreen();
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (BuildContext context, GoRouterState state) {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              return ProfileScreen(
                username: authService.username ?? 'MeTube User',
                profileImageUrl:
                    authService.userAvatarUrl ??
                    'https://www.gravatar.com/avatar/?d=mp',
              );
            },
          ),
          GoRoute(
            path: '/add_video',
            builder: (BuildContext context, GoRouterState state) {
              return const AddVideoScreen();
            },
          ),
          GoRoute(
            path: '/inbox',
            builder: (BuildContext context, GoRouterState state) {
              return const InboxScreen();
            },
          ),
          GoRoute(
            path: '/video/:videoId',
            builder: (BuildContext context, GoRouterState state) {
              final videoId = state.pathParameters['videoId']!;
              return DeepLinkVideoScreen(videoId: videoId);
            },
          ),
        ],
      ),

      // Add deep link video route outside the shell (full screen)
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loggedIn = authService.isSignedIn;
      final goingToLogin = state.uri.path == '/login';

      // If not logged in and not going to login, redirect to login
      if (!loggedIn && !goingToLogin) {
        return '/login';
      }
      // If logged in and going to login, redirect to feed
      if (loggedIn && goingToLogin) {
        final lastRoute = await StorageService.getLastRoute();
        return lastRoute ?? '/feed';
      }
      // No redirect needed
      return null;
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = await AuthService.create();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        Provider(create: (context) => ChatService(authService)),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _router = createRouter();
    _appLinks = AppLinks();
    _initAppLinks();
  }

  void _initAppLinks() async {
    try {
      print('🔄 Initializing deep links...');

      // Setup real-time deep link stream first
      _setupRealTimeDeepLinks();

      // Check for initial deep link (app cold start)
      await _checkInitialDeepLink();

      print('✅ Deep links initialization complete');
    } catch (e) {
      print('❌ Error initializing deep links: $e');
    }
  }

  void _setupRealTimeDeepLinks() {
    print('👂 Setting up real-time deep link listener...');

    // Listen for real-time deep links from native
    NativeDeepLinkService.setupDeepLinkStream((deepLink) {
      print('🎯 Real-time deep link received: $deepLink');
      _processAndNavigateToDeepLink(deepLink);
    });

    // Also listen to app_links streams as backup
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        print('📨 AppLinks stream received: $uri');
        _handleDeepLink(uri);
      }
    });
  }

  Future<void> _checkInitialDeepLink() async {
    print('🔍 Checking for initial deep link...');

    final String? nativeLink = await NativeDeepLinkService.getInitialLink();

    if (nativeLink != null) {
      print('🎯 Initial deep link found: $nativeLink');
      _processAndNavigateToDeepLink(nativeLink);
    } else {
      print('❌ No initial deep link found');
    }
  }

  void _processAndNavigateToDeepLink(String link) {
    print('🔗 Processing deep link: $link');

    // Extract clean tikme:// link
    String? extractedLink = _extractTikmeLink(link);
    if (extractedLink == null) {
      print('❌ No tikme link found in: $link');
      return;
    }

    final uri = Uri.tryParse(extractedLink);
    if (uri != null) {
      print('🚀 Processing deep link URI: $uri');
      _handleDeepLink(uri);
    }
  }

  String? _extractTikmeLink(String text) {
    if (text.contains('tikme://')) {
      final startIndex = text.indexOf('tikme://');
      // Extract the substring starting from tikme://
      final substringFromTikme = text.substring(startIndex);
      // Find the end of the link (space, newline, or end of string) in the substring
      final endMatch = RegExp(r'[\s\n]').firstMatch(substringFromTikme);
      final endIndex = endMatch?.start ?? substringFromTikme.length;
      final cleanLink = substringFromTikme.substring(0, endIndex);
      print('🔧 Extracted clean link: $cleanLink');
      return cleanLink;
    }
    return null;
  }

  void _handleDeepLink(Uri uri) {
    print('🎯 HANDLING DEEP LINK: $uri');
    print('   📱 Scheme: ${uri.scheme}');
    print('   🏠 Host: ${uri.host}');
    print('   🛣️ Path: ${uri.path}');
    print('   🔢 Path segments: ${uri.pathSegments}');

    if (uri.scheme == 'tikme' && uri.host == 'video') {
      final videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : '';
      print('🎥 Video ID extracted: "$videoId"');

      if (videoId.isNotEmpty) {
        _navigateToVideoInRunningApp(videoId);
      } else {
        print('❌ No video ID found in path');
      }
    } else {
      print('❌ Unhandled deep link format');
    }
  }

  void _navigateToVideoInRunningApp(String videoId) {
    print('🚀 Navigating to video in running app: $videoId');

    // Use GoRouter to navigate to the video screen
    // This will work whether the app is in home, profile, or any other screen
    _router.push('/video/$videoId');
    print('✅ Navigation completed for video: $videoId');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp.router(
      title: AppLocalizations.of(context)?.appTitle ?? 'TikMe',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MaterialLocalizationSo.delegate,
        CupertinoLocalizationSo.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('so', ''), // Somali
        Locale('am', ''), // Amharic
      ],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Widget child;
  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _currentBackPressTime;

  @override
  void initState() {
    super.initState();
    _saveCurrentRoute();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _saveCurrentRoute();
  }

  void _saveCurrentRoute() {
    // Save the current route whenever it changes
    final currentLocation = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    if (currentLocation.isNotEmpty) {
      StorageService.saveLastRoute(currentLocation);
    }
  }

  Future<bool> _onWillPop() async {
    final currentIndex = _calculateSelectedIndex(context);

    // If not on home tab (feed), navigate to home instead of exiting
    if (currentIndex != 0) {
      context.go('/feed');
      return false;
    }
    DateTime now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pressAgainToExit),
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    if (location.startsWith('/feed') || location.startsWith('/video/')) {
      return 0;
    }
    if (location.startsWith('/add_video')) {
      return 1;
    }
    if (location.startsWith('/inbox')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0; // Default to home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/add_video');
        break;
      case 2:
        context.go('/inbox');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final authService = Provider.of<AuthService>(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: AppLocalizations.of(context)!.feed,
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_outlined),
              selectedIcon: const Icon(Icons.add),
              label: AppLocalizations.of(context)!.upload,
            ),
            NavigationDestination(
              icon: const Icon(Icons.chat_outlined),
              selectedIcon: const Icon(Icons.chat),
              label: AppLocalizations.of(context)!.inbox,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(Icons.person),
              label: AppLocalizations.of(context)!.profile,
            ),
          ],
          height: 60,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          selectedIndex: _calculateSelectedIndex(context),
        ),
      ),
    );
  }
}

class NativeDeepLinkService {
  static const platform = MethodChannel('com.example.tikme/deep_links');
  static const messageChannel = BasicMessageChannel<String>(
    'com.example.tikme/deep_links_stream',
    StringCodec(),
  );

  static Future<String?> getInitialLink() async {
    try {
      print('🔗 Calling native getInitialLink...');
      final String? initialLink = await platform.invokeMethod('getInitialLink');
      print('🔗 Native getInitialLink returned: $initialLink');
      return initialLink;
    } on PlatformException catch (e) {
      print("❌ Failed to get initial link: '${e.message}'.");
      return null;
    }
  }

  static void setupDeepLinkStream(Function(String) onDeepLinkReceived) {
    messageChannel.setMessageHandler((message) async {
      print('🔗 Real-time deep link received: $message');
      if (message != null) {
        onDeepLinkReceived(message);
      }
      // Return empty string to satisfy the Future<String> return type
      return '';
    });
  }

  static Future<Map<dynamic, dynamic>?> getIntentDetails() async {
    try {
      print('🔗 Calling native getIntentDetails...');
      final Map<dynamic, dynamic>? details = await platform.invokeMethod(
        'getIntentDetails',
      );
      print('🔗 Native getIntentDetails returned: $details');
      return details;
    } on PlatformException catch (e) {
      print("❌ Failed to get intent details: '${e.message}'.");
      return null;
    }
  }
}

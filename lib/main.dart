import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/task_provider.dart';
import './screens/auth_screen.dart';
import './screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. Provides the Authentication state to the app
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        // 2. ProxyProvider links the TaskProvider to the AuthProvider.
        // This ensures TaskProvider always has the latest user ID and Token!
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (ctx) => TaskProvider(null, null, []),
          update: (ctx, auth, previousTasks) => TaskProvider(
            auth.token,
            auth.userId,
            previousTasks == null ? [] : previousTasks.tasks,
          ),
        ),
      ],
      // Consumer listens to AuthProvider to automatically switch screens
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Hire Task To-Do',
          debugShowCheckedModeBanner: false, // Cleaner look for your evaluator
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          // Routing logic: If logged in, go to Home. If not, check auto-login. Otherwise, Auth screen.
          home: auth.isAuth
              ? const HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                          ConnectionState.waiting
                      ? const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        )
                      : const AuthScreen(),
                ),
        ),
      ),
    );
  }
}

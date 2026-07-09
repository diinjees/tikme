import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tikme/providers/theme_provider.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/providers/language_provider.dart';
import 'package:tikme/services/storage_service.dart';

import 'about_app_screen.dart'; // Import the new AboutAppScreen

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authService = Provider.of<AuthService>(context, listen: false);
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    void showChangeEmailDialog() {
      final TextEditingController emailController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(appLocalizations.changeEmail),
            content: TextField(
              controller: emailController,
              decoration: InputDecoration(hintText: appLocalizations.emailHint),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appLocalizations.cancelButton),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.requestEmailChange(emailController.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.confirmationEmailSent),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.failedToChangeEmail(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(appLocalizations.changeButton),
              ),
            ],
          );
        },
      );
    }

    void showChangeUsernameDialog() {
      final TextEditingController usernameController = TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(appLocalizations.changeUsername),
            content: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                hintText: appLocalizations.newUsernameHint,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appLocalizations.cancelButton),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await authService.changeUsername(usernameController.text);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.usernameChangedSuccessfully,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.failedToChangeUsername(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(appLocalizations.changeButton),
              ),
            ],
          );
        },
      );
    }

    void showChangePasswordDialog() {
      final TextEditingController oldPasswordController =
          TextEditingController();
      final TextEditingController newPasswordController =
          TextEditingController();
      final TextEditingController confirmPasswordController =
          TextEditingController();
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(appLocalizations.changePassword),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.oldPasswordHint,
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.newPasswordHint,
                  ),
                  obscureText: true,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    hintText: appLocalizations.confirmNewPasswordHint,
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(appLocalizations.cancelButton),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text !=
                      confirmPasswordController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(appLocalizations.newPasswordsDoNotMatch),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  try {
                    await authService.changePassword(
                      oldPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text,
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.passwordChangedSuccessfully,
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          appLocalizations.failedToChangePassword(e.toString()),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(appLocalizations.changeButton),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.settingsButton)),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text(appLocalizations.emailHint),
            subtitle: Text(
              authService.userEmail ?? appLocalizations.noEmailSet,
            ),
          ),
          ListTile(
            title: Text(appLocalizations.changeEmail),
            onTap: showChangeEmailDialog,
          ),
          ListTile(
            title: Text(appLocalizations.changeUsername),
            onTap: showChangeUsernameDialog,
          ),
          ListTile(
            title: Text(appLocalizations.changePassword),
            onTap: showChangePasswordDialog,
          ),
          ListTile(
            title: Text(appLocalizations.logout),
            onTap: () async {
              await StorageService.clearLastRoute();
              authService.signOut();
              // ignore: use_build_context_synchronously
              GoRouter.of(context).go('/login');
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(appLocalizations.darkMode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
          ListTile(
            title: Text(appLocalizations.systemTheme),
            onTap: () {
              themeProvider.setSystemTheme();
            },
          ),
          ListTile(
            title: Text(appLocalizations.language),
            trailing: DropdownButton<Locale>(
              value: languageProvider.locale,
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  languageProvider.setLocale(newLocale);
                }
              },
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('so'), child: Text('Soomaali')),
                DropdownMenuItem(value: Locale('am'), child: Text('Amharic')),
              ],
            ),
          ),
          ListTile(
            title: Text(appLocalizations.about),
            subtitle: Text(appLocalizations.appVersion('1.0.0')),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tikme/l10n/app_localizations.dart';
import 'package:tikme/services/auth_service.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _newPasswordConfirmController =
      TextEditingController();

  void _changeEmail() async {
    try {
      await Provider.of<AuthService>(
        context,
        listen: false,
      ).requestEmailChange(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.confirmationEmailSent),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToChangeEmail(e)),
        ),
      );
    }
  }

  void _changePassword() async {
    try {
      await Provider.of<AuthService>(context, listen: false).changePassword(
        _oldPasswordController.text,
        _newPasswordController.text,
        _newPasswordConfirmController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.passwordChangedSuccessfully,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToChangePassword(e),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.account)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newemail,
              ),
            ),
            ElevatedButton(
              onPressed: _changeEmail,
              child: Text(AppLocalizations.of(context)!.changeEmail),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _oldPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.oldPasswordHint,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.newPasswordHint,
              ),
              obscureText: true,
            ),
            TextField(
              controller: _newPasswordConfirmController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.confirmNewPasswordHint,
              ),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text(AppLocalizations.of(context)!.changePassword),
            ),
          ],
        ),
      ),
    );
  }
}

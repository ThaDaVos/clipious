import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:invidious/app/states/app.dart';
import 'package:invidious/settings/states/server_settings.dart';
import 'package:invidious/utils.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../models/db/server.dart';
import 'settings.dart';

@RoutePage()
class ManageSingleServerScreen extends StatelessWidget {
  final Server server;

  const ManageSingleServerScreen({super.key, required this.server});

  void showLogInWithCookiesDialog(BuildContext context) async {
    var locals = AppLocalizations.of(context)!;
    TextEditingController userController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    var cubit = context.read<ServerSettingsCubit>();

    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: userController,
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.username,
                    AutofillHints.email
                  ],
                  decoration: InputDecoration(label: Text(locals.username))),
              TextField(
                obscureText: true,
                autocorrect: false,
                controller: passwordController,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(label: Text(locals.password)),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(locals.cancel),
              onPressed: () {
                //Put your code here which you want to execute on Cancel button click.
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(locals.ok),
              onPressed: () async {
                try {
                  await cubit.logInWithCookie(
                      userController.text, passwordController.text);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                } catch (err) {
                  if (context.mounted) {
                    showAlertDialog(context, locals.error,
                        [Text(locals.wrongUsernamePassword)]);
                  }
                  rethrow;
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var locals = AppLocalizations.of(context)!;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    SettingsThemeData theme = settingsTheme(colorScheme);

    return BlocProvider(
      create: (context) => ServerSettingsCubit(
          ServerSettingsState(server: server), context.read<AppCubit>()),
      child: BlocBuilder<ServerSettingsCubit, ServerSettingsState>(
        builder: (context, state) {
          var server = state.server;
          var cubit = context.read<ServerSettingsCubit>();
          bool isLoggedIn =
              (server.authToken != null && server.authToken!.isNotEmpty) ||
                  (server.sidCookie != null && server.sidCookie!.isNotEmpty);
          return Scaffold(
              appBar: AppBar(
                title: Text(server.url),
              ),
              backgroundColor: colorScheme.surface,
              body: SafeArea(
                bottom: false,
                child: SettingsList(
                    lightTheme: theme,
                    darkTheme: theme,
                    sections: [
                      SettingsSection(tiles: [
                        SettingsTile.switchTile(
                          initialValue: server.inUse,
                          onToggle: cubit.useServer,
                          title: Text(locals.useThisServer),
                          enabled: !server.inUse,
                        )
                      ]),
                      SettingsSection(
                          title: Text(locals.authentication),
                          tiles: [
                            SettingsTile(
                              leading: server.authToken?.isNotEmpty ?? false
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.token),
                              enabled: !isLoggedIn,
                              title: Text(locals.tokenLogin),
                              value: Text(server.authToken?.isNotEmpty ?? false
                                  ? locals.loggedIn
                                  : locals.tokenLoginDescription),
                              onPressed: (context) async {
                                await cubit.logInWithToken();
                              },
                            ),
                            SettingsTile(
                              leading: server.sidCookie?.isNotEmpty ?? false
                                  ? const Icon(Icons.check)
                                  : const Icon(Icons.cookie_outlined),
                              enabled: !isLoggedIn,
                              title: Text(locals.cookieLogin),
                              value: Text(server.sidCookie?.isNotEmpty ?? false
                                  ? locals.loggedIn
                                  : locals.cookieLoginDescription),
                              onPressed: showLogInWithCookiesDialog,
                            ),
                            SettingsTile(
                              leading: const Icon(Icons.exit_to_app),
                              enabled: isLoggedIn,
                              title: Text(locals.logout),
                              onPressed: (context) => cubit.logOut(),
                            )
                          ]),
                      SettingsSection(title: const Text(''), tiles: [
                        SettingsTile(
                          enabled: state.canDelete,
                          onPressed: (context) async {
                            await cubit.deleteServer();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                          leading: Icon(
                            Icons.delete,
                            color: state.canDelete
                                ? Colors.red
                                : Colors.red.withOpacity(0.5),
                          ),
                          title: Text(
                            locals.delete,
                            style: TextStyle(
                                color: state.canDelete
                                    ? Colors.red
                                    : Colors.red.withOpacity(0.5)),
                          ),
                        )
                      ])
                    ]),
              ));
        },
      ),
    );
  }
}

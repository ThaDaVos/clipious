import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invidious/app/states/app.dart';
import 'package:invidious/settings/states/server_list_settings.dart';
import 'package:invidious/settings/views/tv/components/manage_server_inner.dart';
import 'package:invidious/utils/views/tv/components/tv_overscan.dart';

@RoutePage()
class TvSettingsManageServersScreen extends StatelessWidget {
  const TvSettingsManageServersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
          create: (BuildContext context) => ServerListSettingsCubit(
              const ServerListSettingsState(publicServers: [], dbServers: []),
              context.read<AppCubit>()),
          child: const TvOverscan(child: TvManageServersInner())),
    );
  }
}

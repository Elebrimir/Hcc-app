// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/providers/user_provider.dart';
import 'package:hcc_app/pages/home_page.dart';
import 'package:hcc_app/pages/dashboard_page.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final firebaseUser = userProvider.firebaseUser;

    // Muestra un indicador de carga mientras el estado inicial se resuelve (opcional pero recomendado)
    // Firebase authStateChanges puede tardar un momento inicial en determinar el estado.
    // Si UserProvider tuviera un estado isLoading, lo podríamos usar aquí.
    // Por ahora, asumimos que null significa 'no autenticado' o 'aún comprobando'.

    // Decide qué página mostrar basado en si hay un usuario autenticado
    if (firebaseUser == null) {
      // Si no hay usuario, muestra la HomePage (con botones de login/registro)
      return const HomePage();
    } else {
      // Si hay usuario, muestra el DashboardPage
      return const DashboardPage();
    }

    // Alternativa más concisa usando context.watch (requiere provider ^6.0.0):
    // final firebaseUser = context.watch<UserProvider>().firebaseUser;
    // return firebaseUser == null ? const HomePage() : const DashboardPage();
  }
}

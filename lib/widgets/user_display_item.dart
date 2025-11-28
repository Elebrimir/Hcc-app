// Copyright (c) 2025 HCC. All rights reserved.
// Use of this source code is governed by an GNU GENERAL PUBLIC LICENSE
// license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hcc_app/models/user_model.dart';
import 'package:hcc_app/providers/user_provider.dart';

class UserDisplayItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;

  const UserDisplayItem({super.key, required this.user, this.onTap});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final loggedInUser = userProvider.userModel;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 3.0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    user.image == null
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                backgroundImage:
                    (user.image != null && user.image!.isNotEmpty)
                        ? NetworkImage(user.image!)
                        : null,
                child:
                    (user.image == null)
                        ? Text(
                          _getInitials(user),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer,
                          ),
                        )
                        : null,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFullName(user),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (user.role != null && user.role!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4.0),
                          Text(
                            'Rol: ${user.role}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    // Rol
                    if (loggedInUser?.role == 'Admin')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email: ${user.email}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                          Text(
                            'Es va unir el: ${user.createdAt?.toDate().day}/${user.createdAt?.toDate().month}/${user.createdAt?.toDate().year}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const Icon(Icons.person_pin_rounded, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  String _getFullName(UserModel user) {
    final name = user.name ?? '';
    final lastname = user.lastname ?? '';
    final fullName = '$name $lastname'.trim();
    return fullName.isEmpty ? 'Usuario sin nombre' : fullName;
  }

  String _getInitials(UserModel user) {
    final nameInitial =
        user.name?.isNotEmpty == true ? user.name![0].toUpperCase() : null;
    final lastnameInitial =
        user.lastname?.isNotEmpty == true
            ? user.lastname![0].toUpperCase()
            : null;

    if (nameInitial != null && lastnameInitial != null) {
      return '$nameInitial$lastnameInitial';
    } else if (nameInitial != null) {
      return nameInitial;
    } else if (lastnameInitial != null) {
      return lastnameInitial;
    } else {
      return '?';
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterrun/view/auth_page.dart';
import 'package:flutterrun/view/home_page.dart';

import '../providers/auth_provider.dart';



class StatusPage extends ConsumerWidget {

  @override
  Widget build(BuildContext context, ref) {
    final authData = ref.watch(authStream);
    return Scaffold(
      body: authData.when(
          data: (data){
            if(data == null){
              return AuthPage();
            }else{
              return HomePage();
            }
          },
          error: (err, stack) => Center(child: Text('$err')),
          loading: () => Center(child: CircularProgressIndicator())
      ),
    );
  }
}

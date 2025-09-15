import 'package:flutter/material.dart';

class ServiceProviderListScreen extends StatelessWidget {
  const ServiceProviderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Providers')),
      body: ListView.separated(
        itemCount: 4,
        separatorBuilder: (context, index) => Divider(),
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.easeIn,
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 6),
              ],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.person)),
              title: Text('Provider #${index + 1}'),
              subtitle: Text('Specialty: Cleaning'),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

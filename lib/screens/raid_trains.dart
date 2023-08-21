import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:yaml/yaml.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;



class RaidTrains extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List>(
      future: fetchData($accessToken),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return buildContent(snapshot.data ?? []);
        }
      },
    );
  }

  // Future<Map<String, String>> getStreamerIcons(String accessToken, List<String> streamerNames) async {
  // final response = await http.get(
  //   Uri.parse('https://api.twitch.tv/helix/users?login=${streamerNames.join(",")}'),
  //   headers: {
  //     'Client-Id': clientId,
  //     'Authorization': 'Bearer $accessToken',
  //   },
  // );

  Future<Map<String, String>> getStreamerIcons(String accessToken, List<String> streamerNames) async {
  final response = await http.get(
    Uri.parse('https://api.twitch.tv/helix/users?login=${streamerNames.join(",")}'),
    headers: {
      'Client-Id': 'YOUR_CLIENT_ID',
      'Authorization': 'Bearer $accessToken',
    },
  );

  Map<String, String> icons = {};

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final users = data['data'] as List;

    for (var user in users) {
      icons[user['login']] = user['profile_image_url'];
    }
  } else {
    print('Failed to get streamer data. Status code: ${response.statusCode}');
  }

  return icons;
}
Future<List> fetchData(String accessToken) async {
  var yamlString = await rootBundle.loadString('assets/raid_trains.yaml');
  var yamlList = loadYaml(yamlString);

  // Generate a list of all streamer names in your YAML data
  List<String> streamerNames = [];
  for (var hostData in yamlList) {
    streamerNames.add(hostData['host']);
    for (var raid in hostData['raids']) {
      for (var day in raid['days']) {
        for (var event in day['events']) {
          streamerNames.add(event['user']);
        }
      }
    }
  }

  // Remove duplicate names
  streamerNames = streamerNames.toSet().toList();

  // Fetch the profile image URLs for all streamers
  Map<String, String> icons = await getStreamerIcons(accessToken, streamerNames);

  // Add the profile_image_url to each streamer in your YAML data
  for (var hostData in yamlList) {
    String hostName = hostData['host'];
    hostData['profile_image_url'] = icons[hostName];
    
    for (var raid in hostData['raids']) {
      for (var day in raid['days']) {
        for (var event in day['events']) {
          String streamerName = event['user'];
          event['profile_image_url'] = icons[streamerName];
        }
      }
    }
  }
  
  return yamlList;
}

  Future<void> _launchURL(Uri url) async {
    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }

  String getStatus(DateTime start, DateTime end) {
    DateTime now = DateTime.now();
    if (now.isBefore(start)) {
      return 'UPCOMING';
    } else if (now.isAfter(end)) {
      return 'COMPLETED';
    } else {
      return 'ACTIVE';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Colors.grey;
      case 'UPCOMING':
        return Colors.blue;
      case 'ACTIVE':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget buildContent(List hostsData) {
    return ListView.builder(
      itemCount: hostsData.length,
      itemBuilder: (context, index) {
        Map hostData = hostsData[index];
        String host = hostData['host'];
        
        List<Map> raids = List<Map>.from(hostData['raids']);
        DateTime hostStart = DateTime.now().add(Duration(days: 10));
        DateTime hostEnd = DateTime(2000);
        for (Map raid in raids) {
          if (raid.containsKey('days')) {
            List<Map> days = List<Map>.from(raid['days']);
            for (Map day in days) {
              List<Map> events = List<Map>.from(day['events']);
              for (Map event in events) {
                DateTime eventTime = DateFormat("EEEE, MMMM d, y HH:mm").parse(event['time']);
                if (eventTime.isBefore(hostStart)) {
                  hostStart = eventTime;
                }
                if (eventTime.isAfter(hostEnd)) {
                  hostEnd = eventTime;
                }
              }
            }
          }
        }
        
        String hostStatus = getStatus(hostStart, hostEnd);
        Color hostStatusColor = getStatusColor(hostStatus);

        return Card(
          margin: EdgeInsets.all(8.0),
          child: ExpansionTile(
            title: Row(
              children: [
                Text(
                  'Host: $host',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10), // Add some space between the two Text widgets
                Text(
                  '($hostStatus)', // The status text in parentheses
                  style: TextStyle(fontSize: 16, color: hostStatusColor),
                ),
              ],
            ),
            children: raids.map<Widget>((raid) {
              return buildRaid(raid);
            }).toList(),
          ),
        );
      },
    );
  }
  
  Widget buildRaid(Map raid) {
    String raidName = raid['name'];
    DateTime raidStart = DateTime.now().add(Duration(days: 10));
    DateTime raidEnd = DateTime(2000);
    
    if (raid.containsKey('days')) {
      List<Map> days = List<Map>.from(raid['days']);
      for (Map day in days) {
        List<Map> events = List<Map>.from(day['events']);
        for (Map event in events) {
          DateTime eventTime = DateFormat("EEEE, MMMM d, y HH:mm").parse(event['time']);
          if (eventTime.isBefore(raidStart)) {
            raidStart = eventTime;
          }
          if (eventTime.isAfter(raidEnd)) {
            raidEnd = eventTime;
          }
        }
      }
    }

    String raidStatus = getStatus(raidStart, raidEnd);
    Color raidStatusColor = getStatusColor(raidStatus);

    return ExpansionTile(
      title: Row(
      children: [
        Text(
          raidName,
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(width: 10), // Add some space between the two Text widgets
        Text(
          '($raidStatus)', // The status text in parentheses
          style: TextStyle(fontSize: 16, color: raidStatusColor),
        ),
      ],
    ),
      children: raid.containsKey('days') ?
        List<Map>.from(raid['days']).map<Widget>((day) {
          return buildDay(day);
        }).toList()
        :
        buildEventList(List<Map>.from(raid['events']))
    );
  }
  
  Widget buildDay(Map day) {
    String dayName = day['day'];
    List<Map> events = List<Map>.from(day['events']);
    DateTime dayStart = DateTime.now().add(Duration(days: 10));
    DateTime dayEnd = DateTime(2000);
    
    for (Map event in events) {
      DateTime eventTime = DateFormat("EEEE, MMMM d, y HH:mm").parse(event['time']);
      if (eventTime.isBefore(dayStart)) {
        dayStart = eventTime;
      }
      if (eventTime.isAfter(dayEnd)) {
        dayEnd = eventTime;
      }
    }

    String dayStatus = getStatus(dayStart, dayEnd);
    Color dayStatusColor = getStatusColor(dayStatus);

    return ExpansionTile(
      title: Text(
        dayName,
        style: TextStyle(fontSize: 18, color: dayStatusColor),
      ),
      children: buildEventList(events),
    );
  }
  
  List<Widget> buildEventList(List<Map> events) {
    return events.map<Widget>((event) {
      String convertedTime = DateFormat.yMMMMd().add_jm().format(
        DateFormat("EEEE, MMMM d, y HH:mm").parse(event['time']).toLocal()
      );
      return ListTile(
        leading: Icon(Icons.event),
        title: Text('Time: $convertedTime'),
        subtitle: GestureDetector(
          child: Text('${event['user']}',
            style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          onTap: () {
            _launchURL(Uri.parse('https://www.${event['link']}'));
          },
        ),
      );
    }).toList();
  }
}

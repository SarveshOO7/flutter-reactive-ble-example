import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
import 'package:stream_provider_ble/src/ble/ble_device_interactor.dart';

class DeviceInteractorScreen extends StatelessWidget {
  final String deviceId;
  const DeviceInteractorScreen({Key? key, required this.deviceId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Consumer2<ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, connectionStateUpdate, deviceInteractor, __) {
            if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connected) {
              return DeviceInteractor(
                deviceId: deviceId,
                deviceInteractor: deviceInteractor,
              );
            } else if (connectionStateUpdate.connectionState ==
                DeviceConnectionState.connecting) {
              return const Text('connecting');
            } else {
              return const Text('error');
            }
          },
        ),
      ),
    );
  }
}

class DeviceInteractor extends StatefulWidget {
  final BleDeviceInteractor deviceInteractor;

  final String deviceId;
  const DeviceInteractor(
      {Key? key, required this.deviceInteractor, required this.deviceId})
      : super(key: key);

  @override
  State<DeviceInteractor> createState() => _DeviceInteractorState();
}

class _DeviceInteractorState extends State<DeviceInteractor> {
  final Uuid _myServiceUuid =
      Uuid.parse("1359814B-D0CC-4CBF-A41E-4BBD88676A11");
  final Uuid _myCharacteristicUuid =
      Uuid.parse("5DBE15E7-DED0-47A8-86ED-ADB4B133BE74");

  Stream<List<int>>? subscriptionStream;
  int score = 0;
  final List<bool> _selectedOption = <bool>[true, false];
  bool isSettingBoard = true;
  bool isPlayingGame = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('connected'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: subscriptionStream != null
                  ? null
                  : () async {
                      setState(() {
                        subscriptionStream =
                            widget.deviceInteractor.subScribeToCharacteristic(
                          QualifiedCharacteristic(
                              characteristicId: _myCharacteristicUuid,
                              serviceId: _myServiceUuid,
                              deviceId: widget.deviceId),
                        );
                      });
                    },
              child: const Text('subscribe'),
            ),
            const SizedBox(
              width: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('disconnect'),
            ),
          ],
        ),
        subscriptionStream != null
            ? StreamBuilder<List<int>>(
                stream: subscriptionStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(snapshot.data.toString()),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 4,
                          children: List.generate(
                            16,
                            (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.blue)),
                                child: Text("1"),
                                // child: Container(
                                //   height: 42.0,
                                //   width: 42.0,
                                //   color: Colors.red,
                                // ),
                                onPressed: () {
                                  print("Button " +
                                      index.toString() +
                                      " pressed");
                                },
                              ),
                            ),
                          ),
                        ),
                        Text("Score:" + score.toString()),
                        ToggleButtons(
                          direction: Axis.horizontal,
                          onPressed: (int index) {
                            setState(() {
                              // The button that is tapped is set to true, and the others to false.
                              for (int i = 0; i < _selectedOption.length; i++) {
                                _selectedOption[i] = i == index;
                              }
                              isSettingBoard = _selectedOption[0];
                              isPlayingGame = _selectedOption[1];
                            });
                          },
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8)),
                          selectedBorderColor: Colors.blue[700],
                          selectedColor: Colors.white,
                          fillColor: Colors.blue[200],
                          color: Colors.blue[400],
                          constraints: const BoxConstraints(
                            minHeight: 40.0,
                            minWidth: 80.0,
                          ),
                          isSelected: _selectedOption,
                          children: const [
                            Text("Set Board"),
                            Text("Play Game"),
                          ],
                        ),
                      ],
                    );
                  }
                  return const Text('No data yet');
                })
            : const Text('Stream not initalized'),
      ],
    );
  }
}

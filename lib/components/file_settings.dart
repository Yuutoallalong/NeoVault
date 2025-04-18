import 'package:flutter/material.dart';

Widget fileSettings(
    {required BuildContext context,
    required TextEditingController messageController,
    required TextEditingController passwordController,
    required bool switchStatus,
    required Function(bool) switchOnChanged,
    required Function(int) daysLeftOnChanged,
    required GlobalKey formKey,
    required String hintText,
    required int dayLeft}) {
  return Column(
    children: [
      TextField(
        controller: messageController,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Color(0xff626272)),
            filled: true,
            fillColor: Color(0xFFF7F6FB),
            border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(20)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 16)),
      ),
      const SizedBox(
        height: 20,
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: Color(0xff626272),
                    size: 26,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Text(
                    "Expiration date",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                children: [
                  DropdownButton<int>(
                    value: dayLeft,
                    items: [7, 14, 30, 60, 90].map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(
                          "$value day(s)",
                          style: TextStyle(
                            color: Color(0xff626272),
                            fontSize: 16,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        daysLeftOnChanged(newValue);
                      }
                    },
                    icon: Icon(Icons.edit, color: Color(0xff626272)),
                    underline: SizedBox(),
                  )
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, color: Color(0xff626272)),
                  const SizedBox(
                    width: 12,
                  ),
                  Text("Password",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: switchStatus,
                  onChanged: switchOnChanged,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      switchStatus
          ? Form(
              key: formKey,
              child: TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Color(0xff5992b7),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16)),
                style: TextStyle(color: Colors.white),
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Password cannot be empty';
                //   }
                //   return null;
                // },
              ))
          : const SizedBox(
              height: 0,
            ),
      const SizedBox(
        height: 20,
      ),
    ],
  );
}

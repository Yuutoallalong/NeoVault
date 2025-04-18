import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/components/back_leading_button.dart';
import 'package:my_app/components/file_settings.dart';
import 'package:my_app/provider/file_picker_provider.dart';
import 'package:my_app/models/fileInfo.dart';
import 'package:my_app/provider/user_provider.dart';

// Create a provider for the current file being viewed
final currentFileProvider =
    FutureProvider.family<FileInfo?, String>((ref, fileId) {
  return ref.read(fileProvider.notifier).fetchFileById(fileId);
});

class Detail extends ConsumerStatefulWidget {
  final String fileId;
  const Detail({Key? key, required this.fileId}) : super(key: key);

  @override
  ConsumerState<Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<Detail> {
  final messageController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  bool switchStatus = false;
  int dayLeft = 7;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Explicitly fetch the data and update controllers when it completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentFileProvider(widget.fileId).future).then((fileInfo) {
        if (fileInfo != null && mounted) {
          setState(() {
            dayLeft = fileInfo.daysLeft;
            switchStatus = fileInfo.locked;
            messageController.text = fileInfo.description;
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateControllersFromFileData();
  }

  // Update controllers when file data is available
  void _updateControllersFromFileData() {
    final fileAsync = ref.watch(currentFileProvider(widget.fileId));

    fileAsync.whenData((fileInfo) {
      if (fileInfo != null && mounted) {
        setState(() {
          dayLeft = fileInfo.daysLeft;
          switchStatus = fileInfo.locked;

          // Only set the controller text if it's empty or different
          if (messageController.text != fileInfo.description) {
            messageController.text = fileInfo.description;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the file data
    final fileAsync = ref.watch(currentFileProvider(widget.fileId));

    return Scaffold(
      appBar: AppBar(
        leading: backLeadingButton(context: context),
        title: Text(
          "Neovault",
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: fileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ${err.toString()}')),
        data: (fileInfo) {
          if (fileInfo == null) {
            return const Center(child: Text('File not found'));
          }

          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ListView(
                  children: [
                    const SizedBox(height: 180),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.file_present, size: 120),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileInfo.name,
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                maxLines: 2,
                              ),
                              Text(
                                "size: ${(fileInfo.size / 1024).toStringAsFixed(2)} KB",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xff626272)
                                      .withAlpha((255 * 0.6).toInt()),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    fileSettings(
                      context: context,
                      messageController: messageController,
                      passwordController: passwordController,
                      switchStatus: switchStatus,
                      switchOnChanged: (bool value) {
                        setState(() {
                          switchStatus = value;
                          if (!value) {
                            passwordController.clear();
                          }
                        });
                      },
                      daysLeftOnChanged: (int value) {
                        setState(() {
                          dayLeft = value;
                        });
                      },
                      formKey: formKey,
                      hintText: "Add a message (optional)",
                      dayLeft: dayLeft,
                    ),
                    const SizedBox(height: 50),
                    // Delete button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Color(0xffff2c21).withAlpha((255 * 0.72).toInt()),
                      ),
                      onPressed: isLoading ? null : _handleDelete,
                      child: Text('Delete'),
                    ),
                    const SizedBox(height: 10),
                    // Save button
                    ElevatedButton(
                      onPressed: isLoading ? null : _handleSave,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // Handle save button press
  void _handleSave() async {
    // Validate form if needed
    if (switchStatus &&
        formKey.currentState != null &&
        !formKey.currentState!.validate()) {
      return;
    }

    // Get current file info to check if it's currently locked
    final fileAsync = ref.watch(currentFileProvider(widget.fileId));
    final currentFile = await fileAsync.value;

    // Check if we need to collect old password (turning off password protection)
    if (currentFile != null && currentFile.locked && !switchStatus) {
      // We're turning off password protection, need to prompt for old password
      final oldPassword = await _promptForOldPassword();
      if (oldPassword == null || oldPassword.isEmpty) {
        // User cancelled password entry or didn't provide one
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Password required to remove protection')));
        return;
      }

      // Call save with the old password
      _saveWithPassword(oldPassword: oldPassword);
    } else if (currentFile != null &&
        currentFile.locked &&
        switchStatus &&
        passwordController.text.isNotEmpty) {
      // Changing existing password - need old password
      final oldPassword = await _promptForOldPassword();
      if (oldPassword == null || oldPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Current password required to change password')));
        return;
      }

      // Call save with both passwords
      _saveWithPassword(oldPassword: oldPassword);
    } else {
      // Regular save without needing old password
      _saveWithPassword();
    }
  }

  // Helper function to show password prompt
  Future<String?> _promptForOldPassword() async {
    final passwordController = TextEditingController();
    final completer = Completer<String?>();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Password Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter current password'),
            SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Current Password',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete(null); // Cancelled
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete(passwordController.text);
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );

    return completer.future;
  }

// Function that actually saves with the right parameters
  void _saveWithPassword({String? oldPassword}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final fileNotifier = ref.read(fileProvider.notifier);
      final success = await fileNotifier.updateFileSettings(
        fileId: widget.fileId,
        description: messageController.text,
        daysLeft: dayLeft,
        locked: switchStatus,
        password: switchStatus && passwordController.text.isNotEmpty
            ? passwordController.text
            : null,
        oldPassword: oldPassword, // Pass the old password when provided
      );

      if (!mounted) return;

      if (success) {
        // Refresh the file data after successful update
        ref.refresh(currentFileProvider(widget.fileId));

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Saved')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to save. Check password and try again.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Handle delete button press
  void _handleDelete() async {
    final user = ref.watch(userProvider);
    final userEmail = user!.email;
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete File'),
            content: Text('Are you sure you want to delete this file?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fileNotifier = ref.read(fileProvider.notifier);
      final success = await fileNotifier.deleteFile(widget.fileId, user.id);

      if (!mounted) return;

      if (success) {
        // Invalidate the provider cache after deletion
        ref.invalidate(fileProvider);

        // เพิ่มบรรทัดนี้เพื่อรีเฟรชข้อมูลผู้ใช้หลังจากลบไฟล์สำเร็จ
        await ref.read(userProvider.notifier).setUser(userEmail);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('File deleted')));
        Navigator.of(context)
            .pop(true); // ส่งค่า true กลับไปเพื่อบอกว่าลบสำเร็จ
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to delete file')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error occurred')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    messageController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
